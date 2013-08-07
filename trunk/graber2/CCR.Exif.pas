{**************************************************************************************}
{                                                                                      }
{ CCR Exif - Delphi class library for reading and writing image metadata               }
{ Version 1.5.1                                                                        }
{                                                                                      }
{ The contents of this file are subject to the Mozilla Public License Version 1.1      }
{ (the "License"); you may not use this file except in compliance with the License.    }
{ You may obtain a copy of the License at http://www.mozilla.org/MPL/                  }
{                                                                                      }
{ Software distributed under the License is distributed on an "AS IS" basis, WITHOUT   }
{ WARRANTY OF ANY KIND, either express or implied. See the License for the specific    }
{ language governing rights and limitations under the License.                         }
{                                                                                      }
{ The Original Code is CCR.Exif.pas.                                                   }
{                                                                                      }
{ The Initial Developer of the Original Code is Chris Rolliston. Portions created by   }
{ Chris Rolliston are Copyright (C) 2009-2012 Chris Rolliston. All Rights Reserved.    }
{                                                                                      }
{**************************************************************************************}

{$I CCR.Exif.inc}
unit CCR.Exif;
{
  Notes:
  - In Exif-jargon, we have 'tags' and 'IFDs' (including 'sub-IFDs'). In the jargon of
    this unit, we have 'tags' and 'sections'.
  - The basic usage pattern is this: construct a TExifData instance; call LoadFromGraphic,
    which has file name, TStream and TGraphic/TBitmap overloads; read and write
    the published tag properties as you so wish; and call SaveToGraphic to persist the
    changes made. Supported graphic types are JPEG, PSD and TIFF. LoadFromGraphic (which
    is a function) returns True if the source was of a supported graphic type, False
    otherwise. In contrast, SaveToGraphic will simply raise an exception if the
    destination isn't of a supported type.
  - The idea is that, in general, if your sole concern is reading and/or writing Exif
    metadata, you only need to explicitly add CCR.Exif to your uses clause. This unit
    does still itself use the other ones (CCR.Exif.BaseUtils etc.) though.
  - You enumerate the tags of a section with the for-in syntax. No traditional indexing
    is provided so as to avoid confusing tag IDs with tag indices.
  - The enumerator implementation for TExifSection allows calling Delete on a tag while
    you are enumerating the container section.
  - When tags are loaded from a graphic, any associated XMP packet is loaded too, though
    XMP data is only actually parsed when required.
  - When setting a tag property, the default behaviour is for the loaded XMP packet
    to be updated if the equivalent XMP tag already exists. This can be changed however
    by setting the XMPWritePolicy property of TExifData.
  - Maker note rewriting is *not* supported in TExifData. While you can make changes to
    the loaded maker note tags, these changes won't ever be persisted.
  - When compiling in XE2, you need to set a 'FMX' global define for this unit to work
    properly in a FireMonkey application.
}
interface

uses
  Types, SysUtils, Classes, Contnrs, TypInfo, CCR.Exif.BaseUtils, CCR.Exif.IPTC,
  {$IFDEF VCL}Graphics, Jpeg,{$ENDIF}{$IFDEF FMX}FMX.Types,{$ENDIF}
  CCR.Exif.StreamHelper, CCR.Exif.TagIDs, CCR.Exif.TiffUtils, CCR.Exif.XMPUtils;

const
  SmallEndian = CCR.Exif.StreamHelper.SmallEndian;
  BigEndian = CCR.Exif.StreamHelper.BigEndian;

  xwAlwaysUpdate = CCR.Exif.XMPUtils.xwAlwaysUpdate;
  xwUpdateIfExists = CCR.Exif.XMPUtils.xwUpdateIfExists;
  xwRemove = CCR.Exif.XMPUtils.xwRemove;

type
  EInvalidJPEGHeader = CCR.Exif.BaseUtils.EInvalidJPEGHeader;
  ECCRExifException = CCR.Exif.BaseUtils.ECCRExifException;
  EInvalidTiffData = CCR.Exif.TiffUtils.EInvalidTiffData;

  TEndianness = CCR.Exif.StreamHelper.TEndianness;

const
  tdExifFraction = tdLongWordFraction;
  tdExifSignedFraction = tdLongIntFraction;
  leBadOffset = CCR.Exif.BaseUtils.leBadOffset;
  leBadTagCount = CCR.Exif.BaseUtils.leBadTagCount;
  leBadTagHeader = CCR.Exif.BaseUtils.leBadTagHeader;

  StandardExifThumbnailWidth   = 160;
  StandardExifThumbnailHeight  = 120;

type
{$IFDEF FMX}
  TGraphic = FMX.Types.TBitmap;

  TJPEGImage = class(FMX.Types.TBitmap, IStreamPersist)
  public
    constructor Create; reintroduce;
    procedure SaveToStream(Stream: TStream);
  end;
{$ENDIF}
{$IF NOT Declared(TJPEGImage)}
  {$DEFINE DummyTJpegImage}
  TJPEGImage = class(TInterfacedPersistent, IStreamPersist)
  strict private
    FData: TMemoryStream;
    FWidth, FHeight: Integer;
    FOnChange: TNotifyEvent;
    function GetWidth: Integer;
    function GetHeight: Integer;
    procedure SizeFieldsNeeded;
  protected
    procedure AssignTo(Dest: TPersistent); override;
    procedure Changed; virtual;
    function GetEmpty: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    property Empty: Boolean read GetEmpty;
    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;
{$IFEND}

  ENotOnlyASCIIError = class(EInvalidTiffData);

  TExifTag = class;
  TExifSection = class;
  TExtendableExifSection = class;
  TCustomExifData = class;
  TExifData = class;

  TExifTagID = TTiffTagID;
  TExifDataType = TTiffDataType;
  TExifDataTypes = TTiffDataTypes;

  PExifFraction = ^TExifFraction;
  TExifFraction = TTiffLongWordFraction;
  TExifSignedFraction = TTiffLongIntFraction;
{$Z2}
  TWindowsStarRating = (urUndefined, urOneStar, urTwoStars, urThreeStars,
    urFourStars, urFiveStars);
{$Z1}
  TExifTagChangeType = (tcData, tcDataSize, tcID);
  TExifPaddingTagSize = 2..High(LongInt);

  TExifTag = class(TNoRefCountInterfacedObject, IMetadataBlock, ITiffTag)
  strict private
    FAsStringCache: string;
    FData: Pointer;
    FDataStream: TUserMemoryStream;
    FDataType: TExifDataType;
    FElementCount: LongInt;
    FID: TExifTagID;
    FOriginalDataOffset: Int64;
    FOriginalDataSize: Integer;
    FWellFormed: Boolean;
    function GetAsString: string;
    procedure SetAsString(const Value: string);
    function GetDataSize: Integer; inline;
    procedure SetDataType(const NewDataType: TExifDataType);
    function GetElementAsString(Index: Integer): string;
    procedure SetElementCount(const NewCount: LongInt);
    procedure SetID(const Value: TExifTagID);
  protected
    { IMetadataBlock }
    function GetData: TCustomMemoryStream;
    function IsExifBlock(CheckID: Boolean = True): Boolean;
    function IsIPTCBlock(CheckID: Boolean = True): Boolean;
    function IsXMPBlock(CheckID: Boolean = True): Boolean;
    { ITiffTag }
    function GetDataType: TTiffDataType;
    function GetElementCount: Integer;
    function GetID: TTiffTagID;
    function GetOriginalDataOffset: LongWord;
    function GetParent: ITiffDirectory;
  protected
    FSection: TExifSection;
    procedure Changing(NewID: TExifTagID; NewDataType: TExifDataType;
      NewElementCount: LongInt; NewData: Boolean);
    procedure Changed(ChangeType: TExifTagChangeType); overload;
    procedure WriteHeader(Stream: TStream; Endianness: TEndianness; DataOffset: LongInt);
    procedure WriteOffsettedData(Stream: TStream; Endianness: TEndianness);
    constructor Create(Section: TExifSection; const Directory: IFoundTiffDirectory;
      Index: Integer); overload;
    property DataStream: TUserMemoryStream read FDataStream;
  public
    constructor Create(const Section: TExifSection; const ID: TExifTagID;
      DataType: TExifDataType; ElementCount: LongInt); overload;
    destructor Destroy; override;
    procedure Assign(Source: TExifTag);
    procedure Changed; overload; //call this if Data is modified directly
    procedure Delete; inline;
    function HasWindowsStringData: Boolean;
    function IsPadding: Boolean;
    procedure SetAsPadding(Size: TExifPaddingTagSize);
    procedure UpdateData(NewDataType: TExifDataType; NewElementCount: LongInt;
      const NewData); overload;
    procedure UpdateData(const NewData); overload;
    function ReadFraction(Index: Integer; const Default: TExifFraction): TExifFraction;
    function ReadLongWord(Index: Integer; const Default: LongWord): LongWord;
    function ReadWord(Index: Integer; const Default: Word): Word;
    {$IFDEF HasToString}
    function ToString: string; override;
    {$ENDIF}
    property AsString: string read GetAsString write SetAsString;
    property ElementAsString[Index: Integer]: string read GetElementAsString;
    property Data: Pointer read FData;
    property DataSize: Integer read GetDataSize;
    property DataType: TExifDataType read FDataType write SetDataType; //this needs to be loaded before AsString
    property ElementCount: LongInt read FElementCount write SetElementCount;
    property ID: TExifTagID read FID write SetID;
    property OriginalDataOffset: Int64 read FOriginalDataOffset;
    property OriginalDataSize: Integer read FOriginalDataSize;
    property Section: TExifSection read FSection;
    property WellFormed: Boolean read FWellFormed;
  end;

  TExifSectionLoadError = TMetadataLoadError;
  TExifSectionLoadErrors = TMetadataLoadErrors;

  TExifSectionKindEx = (esUserDefined, esGeneral, esDetails, esInterop, esGPS,
    esThumbnail, esMakerNote);
  TExifSectionKind = esGeneral..esMakerNote;

  TExifSection = class(TNoRefCountInterfacedObject, ITiffDirectory)
  public type
    TEnumerator = class sealed(TInterfacedObject, ITiffDirectoryEnumerator)
    private
      FCurrent: TExifTag;
      FIndex: Integer;
      FTags: TList;
      constructor Create(ATagList: TList);
      function GetCurrent: ITiffTag;
    public
      function MoveNext: Boolean;
      property Current: TExifTag read FCurrent;
    end;
  strict private class var
    LastSetDateTimeValue: TDateTime;
    LastSetDateTimeMainStr, LastSetDateTimeSubSecStr: string;
  strict private
    FFirstTagHeaderOffset: Int64;
    FKind: TExifSectionKindEx;
    FLoadErrors: TExifSectionLoadErrors;
    FModified: Boolean;
    FOwner: TCustomExifData;
    FTagList: TList;
    procedure DoSetFractionValue(TagID: TExifTagID; Index: Integer;
      DataType: TExifDataType; const Value);
  protected
    { ITiffDirectory }
    function FindTag(TagID: TTiffTagID; out ParsedTag: ITiffTag): Boolean;
    function GetEnumeratorIntf: ITiffDirectoryEnumerator;
    function ITiffDirectory.GetEnumerator = GetEnumeratorIntf;
    function GetIndex: Integer;
    function GetParent: ITiffDirectory;
    function GetTagCount: Integer;
    function LoadSubDirectory(OffsetTagID: TTiffTagID): ITiffDirectory;
    { other }
    constructor Create(AOwner: TCustomExifData; AKind: TExifSectionKindEx);
    function Add(ID: TExifTagID; DataType: TExifDataType; ElementCount: LongInt): TExifTag;
    procedure Changed;
    function CheckExtendable: TExtendableExifSection;
    procedure DoDelete(TagIndex: Integer; FreeTag: Boolean);
    function EnforceASCII: Boolean;
    function FindIndex(ID: TExifTagID; var TagIndex: Integer): Boolean;
    function ForceSetElement(ID: TExifTagID; DataType: TExifDataType;
      Index: Integer; const Value): TExifTag;
    procedure Load(const Directory: IFoundTiffDirectory; TiffImageSource: Boolean);
    procedure TagChanging(Tag: TExifTag; NewID: TExifTagID;
      NewDataType: TExifDataType; NewElementCount: LongInt; NewData: Boolean);
    procedure TagChanged(Tag: TExifTag; ChangeType: TExifTagChangeType);
    procedure TagDeleting(Tag: TExifTag);
    property FirstTagHeaderOffset: Int64 read FFirstTagHeaderOffset;
  public
    destructor Destroy; override;
    function GetEnumerator: TEnumerator;
    procedure Clear;
    function Find(ID: TExifTagID; out Tag: TExifTag): Boolean;
    function GetByteValue(TagID: TExifTagID; Index: Integer; Default: Byte;
      MinValue: Byte = 0; MaxValue: Byte = High(Byte)): Byte;
    function GetDateTimeValue(MainID, SubSecsID: TExifTagID): TDateTimeTagValue;
    function GetFractionValue(TagID: TExifTagID; Index: Integer): TExifFraction; overload;
    function GetFractionValue(TagID: TExifTagID; Index: Integer;
      const Default: TExifFraction): TExifFraction; overload;
    function GetLongIntValue(TagID: TExifTagID; Index: Integer): TLongIntTagValue; overload;
    function GetLongIntValue(TagID: TExifTagID; Index: Integer; Default: LongInt): LongInt; overload;
    function GetLongWordValue(TagID: TExifTagID; Index: Integer): TLongWordTagValue; overload;
    function GetLongWordValue(TagID: TExifTagID; Index: Integer; Default: LongWord): LongWord; overload;
    function GetSmallIntValue(TagID: TExifTagID; Index: Integer; Default: SmallInt;
      MinValue: SmallInt = Low(SmallInt); MaxValue: SmallInt = High(SmallInt)): SmallInt;
    function GetStringValue(TagID: TExifTagID; const Default: string = ''): string;
    function GetWindowsStringValue(TagID: TExifTagID; const Default: UnicodeString = ''): UnicodeString;
    function GetWordValue(TagID: TExifTagID; Index: Integer): TWordTagValue; overload;
    function GetWordValue(TagID: TExifTagID; Index: Integer; Default: Word;
      MinValue: Word = 0; MaxValue: Word = High(Word)): Word; overload;
    function IsExtendable: Boolean; inline;
    function Remove(ID: TExifTagID): Boolean; overload; //returns True if contained a tag with the specified ID
    procedure Remove(const IDs: array of TExifTagID); overload;
    function RemovePaddingTag: Boolean; //returns True if contained a padding tag
    function SetByteValue(TagID: TExifTagID; Index: Integer; Value: Byte): TExifTag;
    procedure SetDateTimeValue(MainID, SubSecsID: TExifTagID; const Value: TDateTimeTagValue);
    procedure SetFractionValue(TagID: TExifTagID; Index: Integer; const Value: TExifFraction);
    function SetLongWordValue(TagID: TExifTagID; Index: Integer; Value: LongWord): TExifTag;
    procedure SetSignedFractionValue(TagID: TExifTagID; Index: Integer;
      const Value: TExifSignedFraction);
    procedure SetStringValue(TagID: TExifTagID; const Value: string);
    procedure SetWindowsStringValue(TagID: TExifTagID; const Value: UnicodeString);
    function SetWordValue(TagID: TExifTagID; Index: Integer; Value: Word): TExifTag;
    function TagExists(ID: TExifTagID; ValidDataTypes: TExifDataTypes =
      [Low(TExifDataType)..High(TExifDataType)]; MinElementCount: LongInt = 1;
      MaxElementCount: LongInt = MaxLongInt): Boolean;
    function TryGetByteValue(TagID: TExifTagID; Index: Integer; var Value): Boolean;
    function TryGetLongWordValue(TagID: TExifTagID; Index: Integer; var Value): Boolean;
    function TryGetWordValue(TagID: TExifTagID; Index: Integer; var Value): Boolean;
    function TryGetStringValue(TagID: TExifTagID; var Value: string): Boolean;
    function TryGetWindowsStringValue(TagID: TExifTagID; var Value: UnicodeString): Boolean;
    property Count: Integer read GetTagCount;
    property Kind: TExifSectionKindEx read FKind;
    property LoadErrors: TExifSectionLoadErrors read FLoadErrors write FLoadErrors;
    property Modified: Boolean read FModified write FModified;
    property Owner: TCustomExifData read FOwner;
  end;

  TExifSectionClass = class of TExifSection;

  TExtendableExifSection = class(TExifSection)
  public
    function Add(ID: TExifTagID; DataType: TExifDataType;
      ElementCount: LongInt = 1): TExifTag;
    function AddOrUpdate(ID: TExifTagID; DataType: TExifDataType;
      ElementCount: LongInt): TExifTag; overload;
    function AddOrUpdate(ID: TExifTagID; DataType: TExifDataType;
      ElementCount: LongInt; const Data): TExifTag; overload;
    function AddOrUpdate(ID: TExifTagID; DataType: TExifDataType;
      const Source: IStreamPersist): TExifTag; overload;
    procedure Assign(Source: TExifSection);
    procedure CopyTags(Section: TExifSection);
  end;

  EInvalidMakerNoteFormat = class(EInvalidTiffData);

  TExifFlashMode = (efUnknown, efCompulsoryFire, efCompulsorySuppression, efAuto);
  TExifStrobeLight = (esNoDetectionFunction, esUndetected, esDetected);

  TWordBitEnum = 0..SizeOf(Word) * 8 - 1;
  TWordBitSet = set of TWordBitEnum;

  TExifFlashInfo = class(TPersistent)
  strict private const
    FiredBit = 0;
    NotPresentBit = 5;
    RedEyeReductionBit = 6;
  strict private
    FOwner: TCustomExifData;
    function GetBitSet: TWordBitSet;
    procedure SetBitSet(const Value: TWordBitSet);
    function GetFired: Boolean;
    procedure SetFired(Value: Boolean);
    function GetMode: TExifFlashMode;
    procedure SetMode(const Value: TExifFlashMode);
    function GetPresent: Boolean;
    procedure SetPresent(Value: Boolean);
    function GetRedEyeReduction: Boolean;
    procedure SetRedEyeReduction(Value: Boolean);
    function GetStrobeEnergy: TExifFraction;
    procedure SetStrobeEnergy(const Value: TExifFraction);
    function GetStrobeLight: TExifStrobeLight;
    procedure SetStrobeLight(const Value: TExifStrobeLight);
  public
    constructor Create(AOwner: TCustomExifData);
    procedure Assign(Source: TPersistent); override;
    function MissingOrInvalid: Boolean;
    property BitSet: TWordBitSet read GetBitSet write SetBitSet stored False;
  published
    property Fired: Boolean read GetFired write SetFired stored False;
    property Mode: TExifFlashMode read GetMode write SetMode stored False;
    property Present: Boolean read GetPresent write SetPresent stored False;
    property RedEyeReduction: Boolean read GetRedEyeReduction write SetRedEyeReduction stored False;
    property StrobeEnergy: TExifFraction read GetStrobeEnergy write SetStrobeEnergy stored False;
    property StrobeLight: TExifStrobeLight read GetStrobeLight write SetStrobeLight stored False;
  end;

  TExifVersionElement = 0..9;

  TCustomExifVersion = class abstract(TPersistent)
  strict private
    FOwner: TCustomExifData;
    function GetAsString: string;
    procedure SetAsString(const Value: string);
    function GetMajor: TExifVersionElement;
    procedure SetMajor(Value: TExifVersionElement);
    function GetMinor: TExifVersionElement;
    procedure SetMinor(Value: TExifVersionElement);
    function GetRelease: TExifVersionElement;
    procedure SetRelease(Value: TExifVersionElement);
    function GetValue(Index: Integer): TExifVersionElement;
    procedure SetValue(Index: Integer; Value: TExifVersionElement);
  strict protected
    FMajorIndex: Integer;
    FSectionKind: TExifSectionKind;
    FStoreAsChar: Boolean;
    FTagID: TExifTagID;
    FTiffDataType: TTiffDataType;
    procedure Initialize; virtual; abstract;
  public
    constructor Create(AOwner: TCustomExifData);
    procedure Assign(Source: TPersistent); override;
    function MissingOrInvalid: Boolean;
    {$IFDEF HasToString}
    function ToString: string; override;
    {$ENDIF}
    property AsString: string read GetAsString write SetAsString;
    property Owner: TCustomExifData read FOwner;
  published
    property Major: TExifVersionElement read GetMajor write SetMajor stored False;
    property Minor: TExifVersionElement read GetMinor write SetMinor stored False;
    property Release: TExifVersionElement read GetRelease write SetRelease stored False;
  end;

  TExifVersion = class(TCustomExifVersion)
  protected
    procedure Initialize; override;
  end;

  TFlashPixVersion = class(TCustomExifVersion)
  protected
    procedure Initialize; override;
  end;

  TGPSVersion = class(TCustomExifVersion)
  protected
    procedure Initialize; override;
  end;

  TInteropVersion = class(TCustomExifVersion)
  protected
    procedure Initialize; override;
  end;

{$Z2}
  TTiffOrientation = (toUndefined, toTopLeft, toTopRight, toBottomRight,
    toBottomLeft, toLeftTop{i.e., rotated}, toRightTop, toRightBottom, toLeftBottom);
  TExifOrientation = TTiffOrientation;
  TTiffResolutionUnit = (trNone = 1, trInch, trCentimetre);
  TExifResolutionUnit = TTiffResolutionUnit;

  TExifColorSpace = (csTagMissing = 0, csRGB = 1, csAdobeRGB = 2, csWideGamutRGB = $FFFD,
    csICCProfile = $FFFE, csUncalibrated = $FFFF);
  TExifContrast = (cnTagMissing = -1, cnNormal, cnSoft, cnHard);
  TExifExposureMode = (exTagMissing = -1, exAuto, exManual, exAutoBracket);
  TExifExposureProgram = (eeTagMissing = -1, eeUndefined, eeManual, eeNormal,
    eeAperturePriority, eeShutterPriority, eeCreative, eeAction, eePortrait, eeLandscape);
  TExifGainControl = (egTagMissing = -1, egNone, egLowGainUp, egHighGainUp, egLowGainDown, egHighGainDown);
  TExifLightSource = (elTagMissing = -1, elUnknown, elDaylight, elFluorescent,
    elTungsten, elFlash, elFineWeather = 9, elCloudyWeather, elShade, elDaylightFluorescent,
    elDayWhiteFluorescent, elCoolWhiteFluorescent, elWhiteFluorescent,
    elStandardLightA = 17, elStandardLightB, elStandardLightC, elD55, elD65,
    elD75, elD50, elISOStudioTungsten, elOther = 255);
  TExifMeteringMode = (emTagMissing = -1, emUnknown, emAverage, emCenterWeightedAverage,
    emSpot, emMultiSpot, emPattern, emPartial);
  TExifRendering = (erTagMissing = -1, erNormal, erCustom);
  TExifSaturation = (euTagMissing = -1, euNormal, euLow, euHigh);
  TExifSceneCaptureType = (ecTagMissing = -1, ecStandard, ecLandscape, ecPortrait, ecNightScene);
  TExifSensingMethod = (esTagMissing = -1, esMonochrome = 1, esOneChip, esTwoChip,
    esThreeChip, esColorSequential, esTrilinear = 7, esColorSequentialLinear); //esMonochrome was esUndefined before 0.9.7
  TExifSharpness = (ehTagMissing = -1, ehNormal, ehSoft, ehHard);
  TExifSubjectDistanceRange = (edTagMissing = -1, edUnknown, edMacro, edClose, edDistant);
  TExifWhiteBalanceMode = (ewTagMissing = -1, ewAuto, ewManual);
{$Z1}

  TCustomExifResolution = class(TPersistent)
  strict private
    FOwner: TCustomExifData;
    FSchema: TXMPNamespace;
    FSection: TExifSection;
    FXTagID, FYTagID, FUnitTagID: TExifTagID;
    FXName, FYName, FUnitName: UnicodeString;
    function GetUnit: TExifResolutionUnit;
    function GetX: TExifFraction;
    function GetY: TExifFraction;
    procedure SetUnit(const Value: TExifResolutionUnit);
    procedure SetX(const Value: TExifFraction);
    procedure SetY(const Value: TExifFraction);
  protected
    procedure GetTagInfo(var Section: TExifSectionKind; 
      var XTag, YTag, UnitTag: TExifTagID; var Schema: TXMPNamespace; 
      var XName, YName, UnitName: UnicodeString); virtual; abstract;
    property Owner: TCustomExifData read FOwner;
  public
    constructor Create(AOwner: TCustomExifData);
    procedure Assign(Source: TPersistent); override;
    function MissingOrInvalid: Boolean;
    {$IFDEF HasToString}
    function ToString: string; override;
    {$ENDIF}
    property Section: TExifSection read FSection;
  published
    property X: TExifFraction read GetX write SetX stored False;
    property Y: TExifFraction read GetY write SetY stored False;
    property Units: TExifResolutionUnit read GetUnit write SetUnit stored False;
  end;

  TImageResolution = class(TCustomExifResolution)
  protected
    procedure GetTagInfo(var Section: TExifSectionKind; 
      var XTag, YTag, UnitTag: TExifTagID; var Schema: TXMPNamespace; 
      var XName, YName, UnitName: UnicodeString); override;
  end;

  TFocalPlaneResolution = class(TCustomExifResolution)
  protected
    procedure GetTagInfo(var Section: TExifSectionKind; 
      var XTag, YTag, UnitTag: TExifTagID; var Schema: TXMPNamespace; 
      var XName, YName, UnitName: UnicodeString); override;
  end;

  TThumbnailResolution = class(TCustomExifResolution)
  protected
    procedure GetTagInfo(var Section: TExifSectionKind; 
      var XTag, YTag, UnitTag: TExifTagID; var Schema: TXMPNamespace; 
      var XName, YName, UnitName: UnicodeString); override;
  end;

  TISOSpeedRatings = class(TPersistent)
  strict private const
    XMPSchema = xsExif;
    XMPKind = xpSeqArray;
    XMPName = UnicodeString('ISOSpeedRatings');
  strict private
    FOwner: TCustomExifData;
    function GetAsString: string;
    procedure SetAsString(const Value: string);
    function GetCount: Integer;
    function GetItem(Index: Integer): Word;
    procedure SetCount(const Value: Integer);
    procedure SetItem(Index: Integer; const Value: Word);
  protected
    procedure Clear;
    function FindTag(VerifyDataType: Boolean; out Tag: TExifTag): Boolean;
    property Owner: TCustomExifData read FOwner;
  public
    constructor Create(AOwner: TCustomExifData);
    procedure Assign(Source: TPersistent); override;
    function MissingOrInvalid: Boolean;
    {$IFDEF HasToString}
    function ToString: string; override;
    {$ENDIF}
    property Items[Index: Integer]: Word read GetItem write SetItem; default;
  published
    property AsString: string read GetAsString write SetAsString stored False;
    property Count: Integer read GetCount write SetCount stored False;
  end;

  TExifFileSource = (fsUnknown, fsFilmScanner, fsReflectionPrintScanner, fsDigitalCamera);
  TExifSceneType = (esUnknown, esDirectlyPhotographed);

  TGPSLatitudeRef = (ltMissingOrInvalid, ltNorth, ltSouth);
  TGPSLongitudeRef = (lnMissingOrInvalid, lnWest, lnEast);
  TGPSAltitudeRef = (alTagMissing, alAboveSeaLevel, alBelowSeaLevel);
  TGPSStatus = (stMissingOrInvalid, stMeasurementActive, stMeasurementVoid);
  TGPSMeasureMode = (mmUnknown, mm2D, mm3D);
  TGPSSpeedRef = (srMissingOrInvalid, srKilometresPerHour, srMilesPerHour, srKnots); //Exif spec makes KM/h the default value
  TGPSDirectionRef = (drMissingOrInvalid, drTrueNorth, drMagneticNorth);
  TGPSDistanceRef = (dsMissingOrInvalid, dsKilometres, dsMiles, dsKnots);
{$Z2}
  TGPSDifferential = (dfTagMissing = -1, dfWithoutCorrection, dfCorrectionApplied);
{$Z1}
  TGPSCoordinate = class(TPersistent)
  strict private
    FOwner: TCustomExifData;
    FRefTagID, FTagID: TExifTagID;
    FXMPName: UnicodeString;
    function GetAsString: string;
    function GetDirectionChar: AnsiChar;
    function GetValue(Index: Integer): TExifFraction;
    procedure SetDirectionChar(NewChar: AnsiChar);
  protected
    procedure Assign(const ADegrees, AMinutes, ASeconds: TExifFraction;
      ADirectionChar: AnsiChar); reintroduce; overload;
    property Owner: TCustomExifData read FOwner;
    property RefTagID: TExifTagID read FRefTagID;
    property TagID: TExifTagID read FTagID;
    property XMPName: UnicodeString read FXMPName;
  public
    constructor Create(AOwner: TCustomExifData; ATagID: TExifTagID);
    procedure Assign(Source: TPersistent); overload; override;
    function MissingOrInvalid: Boolean;
    {$IFDEF HasToString}
    function ToString: string; override;
    {$ENDIF}
    property Degrees: TExifFraction index 0 read GetValue;
    property Minutes: TExifFraction index 1 read GetValue;
    property Seconds: TExifFraction index 2 read GetValue;
    property Direction: AnsiChar read GetDirectionChar write SetDirectionChar;
  published
    property AsString: string read GetAsString;
  end;

  TGPSLatitude = class(TGPSCoordinate)
  strict private
    function GetDirection: TGPSLatitudeRef;
  public
    procedure Assign(const ADegrees, AMinutes, ASeconds: TExifFraction;
      ADirection: TGPSLatitudeRef); reintroduce; overload;
    procedure Assign(ADegrees, AMinutes: LongWord; const ASeconds: TExifFraction;
      ADirection: TGPSLatitudeRef); reintroduce; overload; inline;
    procedure Assign(ADegrees, AMinutes: LongWord; const ASeconds: Currency;
      ADirection: TGPSLatitudeRef); reintroduce; overload; inline;
    procedure Assign(ADegrees, AMinutes, ASeconds: LongWord;
      ADirection: TGPSLatitudeRef); reintroduce; overload; inline;
    property Direction: TGPSLatitudeRef read GetDirection;
  end;

  TGPSLongitude = class(TGPSCoordinate)
  strict private
    function GetDirection: TGPSLongitudeRef;
  public
    procedure Assign(const ADegrees, AMinutes, ASeconds: TExifFraction;
      ADirection: TGPSLongitudeRef); reintroduce; overload;
    procedure Assign(ADegrees, AMinutes: LongWord; const ASeconds: TExifFraction;
      ADirection: TGPSLongitudeRef); reintroduce; overload; inline;
    procedure Assign(ADegrees, AMinutes: LongWord; const ASeconds: Currency;
      ADirection: TGPSLongitudeRef); reintroduce; overload; inline;
    procedure Assign(ADegrees, AMinutes, ASeconds: LongWord;
      ADirection: TGPSLongitudeRef); reintroduce; overload; inline;
    property Direction: TGPSLongitudeRef read GetDirection;
  end;

{ To add support for a different MakerNote format, you need to write a descendent of
  TExifMakerNote, implementing the protected version of FormatIsOK and probably
  GetIFDInfo too, before registering it via TExifData.RegisterMakerNoteType. }

  TExifDataOffsetsType = (doFromExifStart, doFromMakerNoteStart, doFromIFDStart,
    doCustomFormat); //!!!added doCustomFormat v1.5.0

  TExifMakerNote = class abstract
  strict private
    FDataOffsetsType: TExifDataOffsetsType;
    FEndianness: TEndianness;
    FTags: TExifSection;
  protected
    class function FormatIsOK(SourceTag: TExifTag;
      out HeaderSize: Integer): Boolean; overload; virtual; abstract;
    procedure GetIFDInfo(SourceTag: TExifTag; var ProbableEndianness: TEndianness;
      var DataOffsetsType: TExifDataOffsetsType); virtual;
    function GetFractionValue(TagID: Integer): TExifFraction;
    function GetTagAsString(TagID: Integer): string;
    //procedure RewriteSourceTag(Tag: TExifTag); virtual;
    //procedure WriteHeader(Stream: TStream); virtual; abstract;
    //procedure SaveToStream(Stream: TStream; const StartPos: Int64);
  public
    constructor Create(ASection: TExifSection);
    class function FormatIsOK(SourceTag: TExifTag): Boolean; overload;
    property DataOffsetsType: TExifDataOffsetsType read FDataOffsetsType;
    property Endianness: TEndianness read FEndianness;
    property Tags: TExifSection read FTags;
  end;

  TExifMakerNoteClass = class of TExifMakerNote;

  TUnrecognizedMakerNote = class sealed(TExifMakerNote)
  protected
    class function FormatIsOK(SourceTag: TExifTag; out HeaderSize: Integer): Boolean; override;
  end;

  THeaderlessMakerNote = class(TExifMakerNote) //special type tried as a last resort; also serves as a
  protected                                    //nominal base class for two of the concrete implementations
    class function FormatIsOK(SourceTag: TExifTag; out HeaderSize: Integer): Boolean; override;
  end;

  TCanonMakerNote = class(THeaderlessMakerNote)
  protected
    class function FormatIsOK(SourceTag: TExifTag; out HeaderSize: Integer): Boolean; override;
    procedure GetIFDInfo(SourceTag: TExifTag; var ProbableEndianness: TEndianness;
      var DataOffsetsType: TExifDataOffsetsType); override;
  end;

  TKodakMakerNote = class(TExifMakerNote) //!!!work in very early progress
  public type
    TTagSpec = record
      DataType: TTiffDataType;
      ElementCount: Byte;
      constructor Create(ADataType: TTiffDataType; AElementCount: Byte = 1);
    end;
    class var TagSpecs: array of TTagSpec;
    class procedure InitializeTagSpecs; static;
  protected
    const HeaderSize = 8;
    const BigEndianHeader: array[0..HeaderSize - 1] of AnsiChar = 'KDK INFO';
    class function FormatIsOK(SourceTag: TExifTag; out HeaderSize: Integer): Boolean; override;
    procedure GetIFDInfo(SourceTag: TExifTag; var Endianness: TEndianness;
      var DataOffsetsType: TExifDataOffsetsType); override;
  end experimental;

  TPanasonicMakerNote = class(TExifMakerNote)
  protected
    const Header: array[0..11] of AnsiChar = 'Panasonic';
    class function FormatIsOK(SourceTag: TExifTag; out HeaderSize: Integer): Boolean; override;
    procedure GetIFDInfo(SourceTag: TExifTag; var ProbableEndianness: TEndianness;
      var DataOffsetsType: TExifDataOffsetsType); override;
  end;

  TPentaxMakerNote = class(TExifMakerNote) //won't actually parse the structure, just identify it
  protected
    const Header: array[0..3] of AnsiChar = 'AOC'#0;
    class function FormatIsOK(SourceTag: TExifTag; out HeaderSize: Integer): Boolean; override;
  end;

  TNikonType1MakerNote = class(TExifMakerNote)
  protected
    const Header: array[0..7] of AnsiChar = 'Nikon'#0#1#0;
    class function FormatIsOK(SourceTag: TExifTag; out HeaderSize: Integer): Boolean; override;
  end;

  TNikonType2MakerNote = class(THeaderlessMakerNote)
  protected
    class function FormatIsOK(SourceTag: TExifTag; out HeaderSize: Integer): Boolean; override;
  end;

  TNikonType3MakerNote = class(TExifMakerNote)
  protected
    const HeaderStart: array[0..6] of AnsiChar = 'Nikon'#0#2;
    class function FormatIsOK(SourceTag: TExifTag; out HeaderSize: Integer): Boolean; override;
    procedure GetIFDInfo(SourceTag: TExifTag; var ProbableEndianness: TEndianness;
      var DataOffsetsType: TExifDataOffsetsType); override;
  public
    property ColorMode: string index ttNikonType3ColorMode read GetTagAsString;
    property Quality: string index ttNikonType3Quality read GetTagAsString;
    property WhiteBalance: string index ttNikonType3WhiteBalance read GetTagAsString;
    property Sharpening: string index ttNikonType3Sharpening read GetTagAsString;
    property FocusMode: string index ttNikonType3FocusMode read GetTagAsString;
    property FlashSetting: string index ttNikonType3FlashSetting read GetTagAsString;
    property AutoFlashMode: string index ttNikonType3AutoFlashMode read GetTagAsString;
    property MiscRatio: TExifFraction index ttNikonType3MiscRatio read GetFractionValue;
    property ISOSelection: string index ttNikonType3ISOSelection read GetTagAsString;
    property AutoExposureBracketComp: TExifFraction index ttNikonType3AutoExposureBracketComp read GetFractionValue;
    property SerialNumber: string index ttNikonType3SerialNumber read GetTagAsString;
    property ImageAdjustment: string index ttNikonType3ImageAdjustment read GetTagAsString;
    property ToneComp: string index ttNikonType3ToneComp read GetTagAsString;
    property AuxiliaryLens: string index ttNikonType3AuxiliaryLens read GetTagAsString;
    property DigitalZoom: TExifFraction index ttNikonType3DigitalZoom read GetFractionValue;
    property SceneMode: string index ttNikonType3SceneMode read GetTagAsString;
    property LightSource: string index ttNikonType3LightSource read GetTagAsString;
    property NoiseReduction: string index ttNikonType3NoiseReduction read GetTagAsString;
    property SceneAssist: string index ttNikonType3SceneAssist read GetTagAsString;
    property CameraSerialNumber: string index ttNikonType3CameraSerialNumber read GetTagAsString;
    property Saturation: string index ttNikonType3Saturation read GetTagAsString;
    property DigitalVarProgram: string index ttNikonType3DigitalVarProg read GetTagAsString;
    property ImageStabilization: string index ttNikonType3ImageStabilization read GetTagAsString;
    property AFResponse: string index ttNikonType3AFResponse read GetTagAsString;
    property CaptureVersion: string index ttNikonType3CaptureVersion read GetTagAsString;
  end;

  TSonyMakerNote = class(TExifMakerNote)
  protected
    const Header: array[0..7] of AnsiChar = 'SONY DSC';
    class function FormatIsOK(SourceTag: TExifTag; out HeaderSize: Integer): Boolean; override;
    procedure GetIFDInfo(SourceTag: TExifTag; var ProbableEndianness: TEndianness;
      var DataOffsetsType: TExifDataOffsetsType); override;
  end;

  EInvalidExifData = class(ECCRExifException);

  TJPEGMetaDataKind = (mkExif, mkIPTC, mkXMP);
  TJPEGMetadataKinds = set of TJPEGMetadataKind;

  TCustomExifData = class(TComponent)
  public type
    TEnumerator = record
    strict private
      FClient: TCustomExifData;
      FDoneFirst: Boolean;
      FSection: TExifSectionKind;
      function GetCurrent: TExifSection; {$IFDEF CanInline}inline;{$ENDIF}
    public
      constructor Create(AClient: TCustomExifData);
      function MoveNext: Boolean;
      property Current: TExifSection read GetCurrent;
    end;
    TMakerNoteTypePriority = (mtTestForLast, mtTestForFirst);
  strict private class var
    Diag35mm: Extended;
  strict private
    FAlwaysWritePreciseTimes: Boolean;
    FChangedWhileUpdating: Boolean;
    FEmbeddedIPTC: TIPTCData;
    FEndianness: TEndianness;
    FEnforceASCII: Boolean;
    FEnsureEnumsInRange: Boolean;
    FExifVersion: TCustomExifVersion;
    FFlash: TExifFlashInfo;
    FFlashPixVersion: TCustomExifVersion;
    FFocalPlaneResolution: TCustomExifResolution;
    FGPSLatitude, FGPSDestLatitude: TGPSLatitude;
    FGPSLongitude, FGPSDestLongitude: TGPSLongitude;
    FGPSVersion: TCustomExifVersion;
    FInteropVersion: TCustomExifVersion;
    FISOSpeedRatings: TISOSpeedRatings;
    FMakerNoteType: TExifMakerNoteClass;
    FMakerNoteValue: TExifMakerNote;
    FOffsetBase: Int64;
    FModified: Boolean;
    FResolution: TCustomExifResolution;
    FSections: array[TExifSectionKind] of TExifSection;
    FThumbnailOrNil: TJPEGImage;
    FThumbnailResolution: TCustomExifResolution;
    FUpdateCount: Integer;
    FXMPPacket: TXMPPacket;
    FOnChange: TNotifyEvent;
    FIgnoreXMP: Boolean;
    procedure SetEndianness(Value: TEndianness);
    function GetMakerNote: TExifMakerNote;
    function GetSection(Section: TExifSectionKind): TExifSection; //inline;
    procedure SetModified(Value: Boolean);
    function GetThumbnail: TJPEGImage;
    procedure SetThumbnail(Value: TJPEGImage);
    procedure ThumbnailChanged(Sender: TObject);
    function GetDateTime: TDateTimeTagValue;
    procedure SetDateTime(const Value: TDateTimeTagValue);
    function GetGeneralString(TagID: Integer): string;
    procedure SetGeneralString(TagID: Integer; const Value: string);
    function GetGeneralWinString(TagID: Integer): UnicodeString;
    procedure SetGeneralWinString(TagID: Integer; const Value: UnicodeString);
    function GetDetailsDateTime(TagID: Integer): TDateTimeTagValue;
    procedure SetDetailsDateTime(TagID: Integer; const Value: TDateTimeTagValue);
    function GetDetailsFraction(TagID: Integer): TExifFraction;
    procedure SetDetailsFraction(TagID: Integer; const Value: TExifFraction);
    function GetDetailsSFraction(TagID: Integer): TExifSignedFraction;
    procedure SetDetailsSFraction(TagID: Integer; const Value: TExifSignedFraction);
    function GetOffsetSchema: TLongIntTagValue;
    procedure SetOffsetSchema(const Value: TLongIntTagValue);
    function GetDetailsLongWord(TagID: Integer): TLongWordTagValue;
    function GetDetailsString(TagID: Integer): string;
    procedure SetDetailsString(TagID: Integer; const Value: string);
    function GetAuthor: UnicodeString;
    procedure SetAuthor(const Value: UnicodeString);
    function GetComments: UnicodeString;
    procedure SetComments(const Value: UnicodeString);
    function GetUserRating: TWindowsStarRating;
    procedure SetUserRating(const Value: TWindowsStarRating);
    procedure SetFlash(Value: TExifFlashInfo);
    procedure SetFocalPlaneResolution(Value: TCustomExifResolution);
    procedure SetResolution(Value: TCustomExifResolution);
    procedure SetThumbnailResolution(Value: TCustomExifResolution);
    procedure SetGPSVersion(Value: TCustomExifVersion);
    procedure SetGPSLatitude(Value: TGPSLatitude);
    procedure SetGPSLongitude(Value: TGPSLongitude);
    function GetGPSAltitudeRef: TGPSAltitudeRef;
    procedure SetGPSAltitudeRef(const Value: TGPSAltitudeRef);
    function GetGPSFraction(TagID: Integer): TExifFraction;
    procedure SetGPSFraction(TagID: Integer; const Value: TExifFraction);
    function GetGPSDateTimeUTC: TDateTimeTagValue;
    procedure SetGPSDateTimeUTC(const Value: TDateTimeTagValue);
    function GetGPSTimeStamp(const Index: Integer): TExifFraction;
    procedure SetGPSTimeStamp(const Index: Integer; const Value: TExifFraction);
    function GetGPSString(TagID: Integer): string;
    procedure SetGPSString(TagID: Integer; const Value: string);
    function GetGPSStatus: TGPSStatus;
    procedure SetGPSStatus(const Value: TGPSStatus);
    function GetGPSMeasureMode: TGPSMeasureMode;
    procedure SetGPSMeasureMode(const Value: TGPSMeasureMode);
    function GetGPSSpeedRef: TGPSSpeedRef;
    procedure SetGPSSpeedRef(const Value: TGPSSpeedRef);
    function GetGPSDirection(TagID: Integer): TGPSDirectionRef;
    procedure SetGPSDirection(TagID: Integer; Value: TGPSDirectionRef);
    procedure SetGPSDestLatitude(Value: TGPSLatitude);
    procedure SetGPSDestLongitude(Value: TGPSLongitude);
    function GetGPSDestDistanceRef: TGPSDistanceRef;
    procedure SetGPSDestDistanceRef(const Value: TGPSDistanceRef);
    function GetGPSDifferential: TGPSDifferential;
    procedure SetGPSDifferential(Value: TGPSDifferential);
    function GetColorSpace: TExifColorSpace;
    procedure SetColorSpace(Value: TExifColorSpace);
    function GetContrast: TExifContrast;
    procedure SetContrast(Value: TExifContrast);
    function GetOrientation(SectionKind: Integer): TExifOrientation;
    procedure SetOrientation(SectionKind: Integer; Value: TExifOrientation);
    procedure SetExifVersion(Value: TCustomExifVersion);
    procedure SetFlashPixVersion(Value: TCustomExifVersion);
    procedure SetInteropVersion(Value: TCustomExifVersion);
    function GetExposureProgram: TExifExposureProgram;
    procedure SetExposureProgram(const Value: TExifExposureProgram);
    function GetFileSource: TExifFileSource;
    procedure SetFileSource(const Value: TExifFileSource);
    function GetLightSource: TExifLightSource;
    procedure SetLightSource(const Value: TExifLightSource);
    function GetMeteringMode: TExifMeteringMode;
    procedure SetMeteringMode(const Value: TExifMeteringMode);
    function GetSaturation: TExifSaturation;
    procedure SetSaturation(Value: TExifSaturation);
    function GetSceneType: TExifSceneType;
    procedure SetSceneType(Value: TExifSceneType);
    function GetSensingMethod: TExifSensingMethod;
    procedure SetSensingMethod(const Value: TExifSensingMethod);
    function GetSharpness: TExifSharpness;
    procedure SetSharpness(Value: TExifSharpness);
    function GetSubjectLocation: TSmallPoint;
    procedure SetSubjectLocation(const Value: TSmallPoint);
    function GetRendering: TExifRendering;
    function GetFocalLengthIn35mmFilm: TWordTagValue;
    function GetExposureMode: TExifExposureMode;
    function GetSceneCaptureType: TExifSceneCaptureType;
    function GetWhiteBalance: TExifWhiteBalanceMode;
    procedure SetRendering(const Value: TExifRendering);
    procedure SetFocalLengthIn35mmFilm(const Value: TWordTagValue);
    procedure SetExposureMode(const Value: TExifExposureMode);
    procedure SetSceneCaptureType(const Value: TExifSceneCaptureType);
    procedure SetWhiteBalance(const Value: TExifWhiteBalanceMode);
    function GetGainControl: TExifGainControl;
    procedure SetGainControl(const Value: TExifGainControl);
    function GetSubjectDistanceRange: TExifSubjectDistanceRange;
    procedure SetSubjectDistanceRange(Value: TExifSubjectDistanceRange);
    procedure SetDetailsByteEnum(ID: TExifTagID; const XMPName: UnicodeString; const Value);
    procedure SetDetailsWordEnum(ID: TExifTagID; const XMPName: UnicodeString; const Value);
    procedure SetExifImageSize(ID: Integer; const NewValue: TLongWordTagValue);
    function GetInteropTypeName: string;
    procedure SetInteropTypeName(const Value: string);
    procedure SetISOSpeedRatings(Value: TISOSpeedRatings);
    function GetXMPWritePolicy: TXMPWritePolicy;
    procedure SetXMPWritePolicy(Value: TXMPWritePolicy);
  strict protected
    FMetadataInSource: TJPEGMetadataKinds;
    FXMPSegmentPosition, FXMPPacketSizeInSource: Int64;
    property MetadataInSource: TJPEGMetadataKinds read FMetadataInSource; //set in LoadFromGraphic
  protected
    const MaxThumbnailSize = $F000;
    class function SectionClass: TExifSectionClass; virtual;
    procedure AddFromStream(Stream: TStream; TiffImageSource: Boolean = False); 
    procedure Changed(Section: TExifSection); virtual;
    function GetEmpty: Boolean;
    function LoadFromGraphic(Stream: TStream): Boolean;
    procedure ResetMakerNoteType;
    property OffsetBase: Int64 read FOffsetBase;
    property Thumbnail: TJPEGImage read GetThumbnail write SetThumbnail stored False;
  private class var
    FMakerNoteClasses: TList;
  public
    class procedure RegisterMakerNoteType(AClass: TExifMakerNoteClass;
      Priority: TMakerNoteTypePriority = mtTestForFirst);
    class procedure RegisterMakerNoteTypes(const AClasses: array of TExifMakerNoteClass;
      Priority: TMakerNoteTypePriority = mtTestForFirst);
    class procedure UnregisterMakerNoteType(AClass: TExifMakerNoteClass);
  public
    constructor Create(AOwner: TComponent = nil); overload; override; 
    destructor Destroy; override;
    function GetEnumerator: TEnumerator;
    procedure Clear(XMPPacketToo: Boolean = True);
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure GetKeywords(Dest: TStrings); overload;
    procedure SetKeywords(const NewWords: array of UnicodeString); overload;
    procedure SetKeywords(NewWords: TStrings); overload;
    function HasMakerNote: Boolean;
    function HasThumbnail: Boolean; inline;
    procedure Rewrite;
    procedure SetAllDateTimeValues(const NewValue: TDateTimeTagValue);
    function ShutterSpeedInMSecs: Extended;
    function Updating: Boolean; reintroduce; inline;
    property EmbeddedIPTC: TIPTCData read FEmbeddedIPTC;
    property Endianness: TEndianness read FEndianness write SetEndianness;
    property MakerNote: TExifMakerNote read GetMakerNote;
    property Modified: Boolean read FModified write SetModified;
    property Sections[Section: TExifSectionKind]: TExifSection read GetSection; default;
    property XMPPacket: TXMPPacket read FXMPPacket;
    property IgnoreXMP: Boolean read fIgnoreXMP write fIgnoreXMP;
  published
    property AlwaysWritePreciseTimes: Boolean read FAlwaysWritePreciseTimes write FAlwaysWritePreciseTimes default False;
    property Empty: Boolean read GetEmpty;
    property EnforceASCII: Boolean read FEnforceASCII write FEnforceASCII default True;
    property EnsureEnumsInRange: Boolean read FEnsureEnumsInRange write FEnsureEnumsInRange default True;
    property XMPWritePolicy: TXMPWritePolicy read GetXMPWritePolicy write SetXMPWritePolicy default xwUpdateIfExists;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    { main dir tags }
    property CameraMake: string index ttMake read GetGeneralString write SetGeneralString stored False;
    property CameraModel: string index ttModel read GetGeneralString write SetGeneralString stored False;
    property Copyright: string index ttCopyright read GetGeneralString write SetGeneralString stored False;
    property DateTime: TDateTimeTagValue read GetDateTime write SetDateTime stored False;
    property ImageDescription: string index ttImageDescription read GetGeneralString write SetGeneralString stored False;
    property Orientation: TExifOrientation index Ord(esGeneral) read GetOrientation write SetOrientation stored False;
    property Resolution: TCustomExifResolution read FResolution write SetResolution stored False;
    property Software: string index ttSoftware read GetGeneralString write SetGeneralString stored False;
    { main dir tags set by Windows Explorer (XP+) }
    property Author: UnicodeString read GetAuthor write SetAuthor stored False; //falls back to ttArtist if nec
    property Comments: UnicodeString read GetComments write SetComments stored False; //falls back to ttUserComment in the Exif IFD if necessary
    property Keywords: UnicodeString index ttWindowsKeywords read GetGeneralWinString write SetGeneralWinString stored False; //see also Get/SetKeywords
    property Subject: UnicodeString index ttWindowsSubject read GetGeneralWinString write SetGeneralWinString stored False;
    property Title: UnicodeString index ttWindowsTitle read GetGeneralWinString write SetGeneralWinString stored False;
    property UserRating: TWindowsStarRating read GetUserRating write SetUserRating stored False;
    { sub dir tags }
    property ApertureValue: TExifFraction index ttApertureValue read GetDetailsFraction write SetDetailsFraction stored False;
    property BodySerialNumber: string index ttBodySerialNumber read GetDetailsString write SetDetailsString stored False;
    property BrightnessValue: TExifSignedFraction index ttBrightnessValue read GetDetailsSFraction write SetDetailsSFraction stored False;
    property CameraOwnerName: string index ttCameraOwnerName read GetDetailsString write SetDetailsString stored False;
    property ColorSpace: TExifColorSpace read GetColorSpace write SetColorSpace stored False;
    property Contrast: TExifContrast read GetContrast write SetContrast stored False;
    property CompressedBitsPerPixel: TExifFraction index ttCompressedBitsPerPixel read GetDetailsFraction write SetDetailsFraction stored False;
    property DateTimeOriginal: TDateTimeTagValue index ttDateTimeOriginal read GetDetailsDateTime write SetDetailsDateTime stored False;
    property DateTimeDigitized: TDateTimeTagValue index ttDateTimeDigitized read GetDetailsDateTime write SetDetailsDateTime stored False;
    property DigitalZoomRatio: TExifFraction index ttDigitalZoomRatio read GetDetailsFraction write SetDetailsFraction stored False;
    property ExifVersion: TCustomExifVersion read FExifVersion write SetExifVersion stored False;
    property ExifImageWidth: TLongWordTagValue index ttExifImageWidth read GetDetailsLongWord write SetExifImageSize stored False;
    property ExifImageHeight: TLongWordTagValue index ttExifImageHeight read GetDetailsLongWord write SetExifImageSize stored False;
    property ExposureBiasValue: TExifSignedFraction index ttExposureBiasValue read GetDetailsSFraction write SetDetailsSFraction stored False;
    property ExposureIndex: TExifFraction index ttExposureIndex read GetDetailsFraction write SetDetailsFraction stored False; //old Kodak camera tag
    property ExposureMode: TExifExposureMode read GetExposureMode write SetExposureMode stored False;
    property ExposureProgram: TExifExposureProgram read GetExposureProgram write SetExposureProgram stored False;
    property ExposureTime: TExifFraction index ttExposureTime read GetDetailsFraction write SetDetailsFraction stored False; //in secs
    property FileSource: TExifFileSource read GetFileSource write SetFileSource stored False;
    property Flash: TExifFlashInfo read FFlash write SetFlash stored False;
    property FlashPixVersion: TCustomExifVersion read FFlashPixVersion write SetFlashPixVersion stored False;
    property FNumber: TExifFraction index ttFNumber read GetDetailsFraction write SetDetailsFraction stored False;
    property FocalLength: TExifFraction index ttFocalLength read GetDetailsFraction write SetDetailsFraction stored False;
    property FocalLengthIn35mmFilm: TWordTagValue read GetFocalLengthIn35mmFilm write SetFocalLengthIn35mmFilm stored False;
    property FocalPlaneResolution: TCustomExifResolution read FFocalPlaneResolution write SetFocalPlaneResolution stored False;
    property GainControl: TExifGainControl read GetGainControl write SetGainControl stored False;
    property ImageUniqueID: string index ttImageUniqueID read GetDetailsString write SetDetailsString stored False;
    property ISOSpeedRatings: TISOSpeedRatings read FISOSpeedRatings write SetISOSpeedRatings;
    property LensMake: string index ttLensMake read GetDetailsString write SetDetailsString stored False;
    property LensModel: string index ttLensModel read GetDetailsString write SetDetailsString stored False;
    property LensSerialNumber: string index ttLensSerialNumber read GetDetailsString write SetDetailsString stored False;
    property LightSource: TExifLightSource read GetLightSource write SetLightSource stored False;
    property MaxApertureValue: TExifFraction index ttMaxApertureValue read GetDetailsFraction write SetDetailsFraction stored False;
    property MeteringMode: TExifMeteringMode read GetMeteringMode write SetMeteringMode stored False;
    property OffsetSchema: TLongIntTagValue read GetOffsetSchema write SetOffsetSchema stored False;
    property RelatedSoundFile: string index ttRelatedSoundFile read GetDetailsString write SetDetailsString stored False;
    property Rendering: TExifRendering read GetRendering write SetRendering stored False;
    property Saturation: TExifSaturation read GetSaturation write SetSaturation stored False;
    property SceneCaptureType: TExifSceneCaptureType read GetSceneCaptureType write SetSceneCaptureType stored False;
    property SceneType: TExifSceneType read GetSceneType write SetSceneType stored False;
    property SensingMethod: TExifSensingMethod read GetSensingMethod write SetSensingMethod stored False;
    property Sharpness: TExifSharpness read GetSharpness write SetSharpness stored False;
    property ShutterSpeedValue: TExifSignedFraction index ttShutterSpeedValue read GetDetailsSFraction write SetDetailsSFraction stored False; //in APEX; for display, you may well prefer to use ShutterSpeedInMSecs
    property SpectralSensitivity: string index ttSpectralSensitivity read GetDetailsString write SetDetailsString;
    property SubjectDistance: TExifFraction index ttSubjectDistance read GetDetailsFraction write SetDetailsFraction stored False;
    property SubjectDistanceRange: TExifSubjectDistanceRange read GetSubjectDistanceRange write SetSubjectDistanceRange stored False;
    property SubjectLocation: TSmallPoint read GetSubjectLocation write SetSubjectLocation stored False;
    property WhiteBalanceMode: TExifWhiteBalanceMode read GetWhiteBalance write SetWhiteBalance stored False;
    { sub dir tags whose data are rolled into the DateTime properties, so don't display them for the sake of it }
    property SubsecTime: string index ttSubsecTime read GetDetailsString write SetDetailsString stored False;
    property SubsecTimeOriginal: string index ttSubsecTimeOriginal read GetDetailsString write SetDetailsString stored False;
    property SubsecTimeDigitized: string index ttSubsecTimeDigitized read GetDetailsString write SetDetailsString stored False;
    { Interop }
    property InteropTypeName: string read GetInteropTypeName write SetInteropTypeName stored False;
    property InteropVersion: TCustomExifVersion read FInteropVersion write SetInteropVersion stored False;
    { GPS }
    property GPSVersion: TCustomExifVersion read FGPSVersion write SetGPSVersion stored False;
    property GPSLatitude: TGPSLatitude read FGPSLatitude write SetGPSLatitude;
    property GPSLongitude: TGPSLongitude read FGPSLongitude write SetGPSLongitude;
    property GPSAltitudeRef: TGPSAltitudeRef read GetGPSAltitudeRef write SetGPSAltitudeRef stored False;
    property GPSAltitude: TExifFraction index ttGPSAltitude read GetGPSFraction write SetGPSFraction stored False;
    property GPSSatellites: string index ttGPSSatellites read GetGPSString write SetGPSString stored False;
    property GPSStatus: TGPSStatus read GetGPSStatus write SetGPSStatus stored False;
    property GPSMeasureMode: TGPSMeasureMode read GetGPSMeasureMode write SetGPSMeasureMode stored False;
    property GPSDOP: TExifFraction index ttGPSDOP read GetGPSFraction write SetGPSFraction stored False;
    property GPSSpeedRef: TGPSSpeedRef read GetGPSSpeedRef write SetGPSSpeedRef stored False;
    property GPSSpeed: TExifFraction index ttGPSSpeed read GetGPSFraction write SetGPSFraction stored False;
    property GPSTrackRef: TGPSDirectionRef index ttGPSTrackRef read GetGPSDirection write SetGPSDirection stored False;
    property GPSTrack: TExifFraction index ttGPSTrack read GetGPSFraction write SetGPSFraction;
    property GPSImgDirectionRef: TGPSDirectionRef index ttGPSImgDirectionRef read GetGPSDirection write SetGPSDirection stored False;
    property GPSImgDirection: TExifFraction index ttGPSImgDirection read GetGPSFraction write SetGPSFraction;
    property GPSMapDatum: string index ttGPSMapDatum read GetGPSString write SetGPSString;
    property GPSDestLatitude: TGPSLatitude read FGPSDestLatitude write SetGPSDestLatitude;
    property GPSDestLongitude: TGPSLongitude read FGPSDestLongitude write SetGPSDestLongitude;
    property GPSDestBearingRef: TGPSDirectionRef index ttGPSDestBearingRef read GetGPSDirection write SetGPSDirection stored False;
    property GPSDestBearing: TExifFraction index ttGPSDestBearing read GetGPSFraction write SetGPSFraction stored False;
    property GPSDestDistanceRef: TGPSDistanceRef read GetGPSDestDistanceRef write SetGPSDestDistanceRef stored False;
    property GPSDestDistance: TExifFraction index ttGPSDestDistance read GetGPSFraction write SetGPSFraction stored False;
    property GPSDifferential: TGPSDifferential read GetGPSDifferential write SetGPSDifferential stored False;
    property GPSDateTimeUTC: TDateTimeTagValue read GetGPSDateTimeUTC write SetGPSDateTimeUTC stored False;
    { GPS tags whose data are rolled into the GPSDataTimeUTC property, so don't display them for the sake of it }
    property GPSDateStamp: string index ttGPSDateStamp read GetGPSString write SetGPSString stored False;
    property GPSTimeStampHour: TExifFraction index 0 read GetGPSTimeStamp write SetGPSTimeStamp stored False;
    property GPSTimeStampMinute: TExifFraction index 1 read GetGPSTimeStamp write SetGPSTimeStamp stored False;
    property GPSTimeStampSecond: TExifFraction index 2 read GetGPSTimeStamp write SetGPSTimeStamp stored False;
    { thumbnail tags }
    property ThumbnailOrientation: TExifOrientation index Ord(esThumbnail) read GetOrientation write SetOrientation stored False;
    property ThumbnailResolution: TCustomExifResolution read FThumbnailResolution
      write SetThumbnailResolution stored False;
  end;

  EExifDataPatcherError = class(ECCRExifException);
  ENoExifFileOpenError = class(EExifDataPatcherError);
  EIllegalEditOfExifData = class(EExifDataPatcherError);

  TExifDataPatcher = class(TCustomExifData) //only supports patching the Exif data in JPEG files
  strict private
    FOriginalEndianness: TEndianness;
    FPreserveFileDate: Boolean;
    FStream: TFileStream;
    function GetFileDateTime: TDateTime;
    procedure SetFileDateTime(const Value: TDateTime);
    function GetFileName: string;
  protected
    procedure CheckFileIsOpen;
    property Stream: TFileStream read FStream;
  public
    constructor Create(const AFileName: string); reintroduce; overload;
    destructor Destroy; override;
    { the following two methods originally had params typed to TJpegImage; these
      have been made more weakly typed for FMX compatibility }
    {$IF CompilerVersion >= 22}
    procedure GetImage<T: TPersistent, IStreamPersist>(Dest: T);
    procedure GetThumbnail<T: TPersistent, IStreamPersist>(Dest: T);
    {$ELSE}
    procedure GetImage(const Dest: IStreamPersist);
    procedure GetThumbnail(Dest: TPersistent);
    {$IFEND}
    procedure OpenFile(const JPEGFileName: string);
    procedure UpdateFile;
    procedure CloseFile(SaveChanges: Boolean = False);
    property FileDateTime: TDateTime read GetFileDateTime write SetFileDateTime;
  published
    property FileName: string read GetFileName write OpenFile;
    property PreserveFileDate: Boolean read FPreserveFileDate write FPreserveFileDate default False;
  end;

  TExifData = class(TCustomExifData, IStreamPersist, IStreamPersistEx, ITiffRewriteCallback)
  strict private
    FRemovePaddingTagsOnSave: Boolean;
    procedure GetGraphicSaveMethod(Stream: TStream; var Method: TGraphicSaveMethod);
    function GetSection(Section: TExifSectionKind): TExtendableExifSection; inline;
  protected
    procedure DefineProperties(Filer: TFiler); override;
    procedure DoSaveToJPEG(InStream, OutStream: TStream);
    procedure DoSaveToPSD(InStream, OutStream: TStream);
    procedure DoSaveToTIFF(InStream, OutStream: TStream);
    class function SectionClass: TExifSectionClass; override;
    { ITiffRewriteCallback }
    procedure AddNewTags(Rewriter: TTiffDirectoryRewriter);
    procedure RewritingOldTag(const Source: ITiffDirectory; TagID: TTiffTagID;
      DataType: TTiffDataType; var Rewrite: Boolean);
  public
    constructor Create(AOwner: TComponent = nil); override;
    procedure Assign(Source: TPersistent); override;
    {$IF Declared(TGraphic)}
    procedure CreateThumbnail(Source: TGraphic;
      ThumbnailWidth: Integer = StandardExifThumbnailWidth;
      ThumbnailHeight: Integer = StandardExifThumbnailHeight);
    procedure StandardizeThumbnail;
    {$IFEND}
    function LoadFromGraphic(Stream: TStream): Boolean; overload; inline;
    function LoadFromGraphic(const Graphic: IStreamPersist): Boolean; overload;
    function LoadFromGraphic(const FileName: string): Boolean; overload;
    procedure LoadFromStream(Stream: TStream);
    procedure RemoveMakerNote;
    procedure RemovePaddingTags;
    procedure SaveToGraphic(const FileName: string); overload;
    procedure SaveToGraphic(const Graphic: IStreamPersist); overload;
    procedure SaveToGraphic(const Stream: TStream); overload; // WHY THE HELL NOT DEFINED BEFORE???
    procedure SaveToStream(Stream: TStream);
    property Sections[Section: TExifSectionKind]: TExtendableExifSection read GetSection; default;
  {$IF DECLARED(TJPEGData)}
  public //deprecated methods - to be removed in a future release
    procedure LoadFromJPEG(JPEGStream: TStream); overload; deprecated {$IFDEF DepCom}'Use LoadFromGraphic'{$ENDIF};
    procedure LoadFromJPEG(JPEGImage: TJPEGImage); overload; inline; deprecated {$IFDEF DepCom}'Use LoadFromGraphic'{$ENDIF};
    procedure LoadFromJPEG(const FileName: string); overload; inline; deprecated {$IFDEF DepCom}'Use LoadFromGraphic'{$ENDIF};
    procedure SaveToJPEG(const JPEGFileName: string; Dummy: Boolean = True); overload; inline; deprecated {$IFDEF DepCom}'Use SaveToGraphic'{$ENDIF};
    procedure SaveToJPEG(JPEGImage: TJPEGImage); overload; inline; deprecated {$IFDEF DepCom}'Use SaveToGraphic'{$ENDIF};
  {$IFEND}
  published
    property RemovePaddingTagsOnSave: Boolean read FRemovePaddingTagsOnSave write
      FRemovePaddingTagsOnSave default True;
    property Thumbnail;
  end;

{$IFDEF VCL}
  TJPEGImageEx = class(TJPEGImage)
  public type
    TAssignOptions = set of (jaPreserveMetadata);
  strict private
    FChangedSinceLastLoad: Boolean;
    FExifData: TExifData;
    FIPTCData: TIPTCData;
    function GetXMPPacket: TXMPPacket;
    procedure ReloadTags;
  protected
    procedure Changed(Sender: TObject); override;
    procedure ReadData(Stream: TStream); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); overload; override;
    procedure Assign(Source: TBitmap; Options: TAssignOptions); reintroduce; overload;
    procedure CreateThumbnail(ThumbnailWidth, ThumbnailHeight: Integer); overload;
    procedure CreateThumbnail; overload; inline;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    function RemoveMetadata(Kinds: TJPEGMetadataKinds): TJPEGMetadataKinds; inline;
    function RemoveSegments(Markers: TJPEGMarkers): TJPEGMarkers; inline;
    function Segments(MarkersToLookFor: TJPEGMarkers = TJPEGSegment.AllMarkers): IJPEGHeaderParser; inline;
    property ExifData: TExifData read FExifData;
    property IPTCData: TIPTCData read FIPTCData;
    property XMPPacket: TXMPPacket read GetXMPPacket; //just a shortcut for ExifData.XMPPacket
  end;
{$ENDIF}

const
  stMeasurementInProgress = stMeasurementActive;
  stMeasurementInInterop = stMeasurementVoid;

function BinToHexStr(Data: Pointer; StartPos, Size: Integer): string; overload;
function BinToHexStr(MemStream: TCustomMemoryStream): string; overload; 

function ContainsOnlyASCII(const S: UnicodeString): Boolean; overload;
function ContainsOnlyASCII(const S: RawByteString): Boolean; overload;

function DateTimeToExifString(const DateTime: TDateTime): string;
function TryExifStringToDateTime(const S: string; var DateTime: TDateTime): Boolean; overload;

function HasExifHeader(Stream: TStream;
  MovePosOnSuccess: Boolean = False): Boolean; deprecated; //use Segment.HasExifHeader

function ProportionallyResizeExtents(const Width, Height: Integer;
  const MaxWidth, MaxHeight: Integer): TSize;

const
  AllJPEGMetaDataKinds = [Low(TJPEGMetaDataKind)..High(TJPEGMetaDataKind)];

function RemoveMetadataFromJPEG(const JPEGFileName: string;
  Kinds: TJPEGMetadataKinds = AllJPEGMetaDataKinds): TJPEGMetadataKinds; overload;
function RemoveMetadataFromJPEG(JPEGImage: TJPEGImage;
  Kinds: TJPEGMetadataKinds = AllJPEGMetaDataKinds): TJPEGMetadataKinds; overload;

implementation

uses
  SysConst, RTLConsts, Math, DateUtils, StrUtils, CCR.Exif.Consts;

type
  PExifFractionArray = ^TExifFractionArray;
  TExifFractionArray = array[0..High(TLongWordArray) div 2] of TExifFraction;

const
  NullFraction: TExifFraction = (PackedValue: 0);

{ general helper routines }

function BinToHexStr(Data: Pointer; StartPos, Size: Integer): string;
begin
  Result := BinToHexStr(@PAnsiChar(Data)[StartPos], Size);
end;

function BinToHexStr(MemStream: TCustomMemoryStream): string;
begin
  Result := BinToHexStr(MemStream.Memory, MemStream.Size);
end;

function ContainsOnlyASCII(const S: UnicodeString): Boolean;
var
  Ch: WideChar;
begin
  Result := True;
  for Ch in S do
    if Ord(Ch) > 128 then
    begin
      Result := False;
      Break;
    end;
end;

function ContainsOnlyASCII(const S: RawByteString): Boolean;
var
  Ch: AnsiChar;
begin
  Result := True;
  for Ch in S do
    if Ord(Ch) > 128 then
    begin
      Result := False;
      Break;
    end;
end;

{$IF CompilerVersion >= 22}
function DecimalSeparator: Char; inline; //avoid compiler warning about deprecated symbol
begin
  Result := FormatSettings.DecimalSeparator;
end;
{$IFEND}

{$IF Declared(TGraphic)}
function IsGraphicEmpty(AGraphic: TGraphic): Boolean; inline;
begin
  {$IFDEF VCL}
  Result := (AGraphic = nil) or AGraphic.Empty;
  {$ELSE}
  Result := (AGraphic = nil) or AGraphic.IsEmpty;
  {$ENDIF}
end;

procedure StretchDrawGraphic(AGraphic: TGraphic; ADest: TCanvas; const ARect: TRect);
begin
  if IsGraphicEmpty(AGraphic) then Exit;
  {$IFDEF VCL}
  ADest.StretchDraw(ARect, AGraphic);
  {$ELSE}
  ADest.DrawBitmap(AGraphic, RectF(0, 0, AGraphic.Width, AGraphic.Height),
    RectF(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom), 1);
  {$ENDIF}
end;
{$ELSE}
function IsGraphicEmpty(const AGraphic: TJPEGImage): Boolean; inline;
begin
  Result := (AGraphic = nil) or AGraphic.Empty;
end;
{$IFEND}

function GetGPSTagXMPName(TagID: TExifTagID): UnicodeString;
begin
  case TagID of
    ttGPSVersionID: Result := 'GPSVersionID';
    ttGPSLatitude: Result := 'GPSLatitude'; //includes ttGPSLatitudeRef
    ttGPSLongitude: Result := 'GPSLongitude'; //includes ttGPSLongitudeRef
    ttGPSAltitudeRef: Result := 'GPSAltitudeRef';
    ttGPSAltitude: Result := 'GPSAltitude';
    ttGPSTimeStamp: Result := 'GPSTimeStamp'; //includes GPSDateStamp
    ttGPSSatellites: Result := 'GPSSatellites';
    ttGPSStatus: Result := 'GPSStatus';
    ttGPSMeasureMode: Result :='GPSMeasureMode';
    ttGPSDOP: Result := 'GPSDOP';
    ttGPSSpeedRef: Result := 'GPSSpeedRef';
    ttGPSSpeed: Result := 'GPSSpeed';
    ttGPSTrackRef: Result := 'GPSTrackRef';
    ttGPSTrack: Result := 'GPSTrack';
    ttGPSImgDirectionRef: Result := 'GPSImgDirectionRef';
    ttGPSImgDirection: Result := 'GPSImgDirection';
    ttGPSMapDatum: Result := 'GPSMapDatum';
    ttGPSDestBearingRef: Result := 'GPSDestBearingRef';
    ttGPSDestBearing: Result := 'GPSDestBearing';
    ttGPSDestDistance: Result := 'GPSDestDistance';
    ttGPSDestLatitude: Result := 'GPSDestLatitude'; //includes ttGPSDestLatitudeRef
    ttGPSDestLongitude: Result := 'GPSDestLongitude'; //includes ttGPSDestLongitudeRef
    ttGPSDifferential: Result := 'GPSDifferential';
  else Result := '';
  end;
end;

function FindGPSTagXMPName(TagID: TExifTagID; out PropName: string): Boolean;
begin
  PropName := GetGPSTagXMPName(TagID);
  Result := (PropName <> '');
end;

function IsKnownExifTagInMainIFD(ID: TTiffTagID; DataType: TTiffDataType): Boolean; overload;
begin
  Result := False;
  case ID of
    ttImageDescription, ttMake, ttModel, ttOrientation, ttXResolution,
    ttYResolution, ttResolutionUnit, ttSoftware, ttDateTime, ttArtist,
    ttWhitePoint, ttPrimaryChromaticities, ttYCbCrCoefficients,
    ttYCbCrPositioning, ttReferenceBlackWhite, ttCopyright, ttIPTC, ttExifOffset,
    ttGPSOffset, ttPrintIM: Result := True;
    ttWindowsTitle, ttWindowsComments, ttWindowsAuthor, ttWindowsKeywords,
    ttWindowsSubject, ttWindowsRating, ttWindowsPadding:
      if DataType = tdByte then Result := True;
  end;
end;

function IsKnownExifTagInMainIFD(const TagInfo: TTiffTagInfo): Boolean; overload; inline;
begin
  Result := IsKnownExifTagInMainIFD(TagInfo.ID, TagInfo.DataType);
end;

function ProportionallyResizeExtents(const Width, Height: Integer;
  const MaxWidth, MaxHeight: Integer): TSize;
var
  XYAspect: Double;
begin
  if (Width = 0) or (Height = 0) then
  begin
    Result.cx := 0;
    Result.cy := 0;
    Exit;
  end;
  Result.cx := Width;
  Result.cy := Height;
  XYAspect := Width / Height;
  if Width > Height then
  begin
    Result.cx := MaxWidth;
    Result.cy := Round(MaxWidth / XYAspect);
    if Result.cy > MaxHeight then
    begin
      Result.cy := MaxHeight;
      Result.cx := Round(MaxHeight * XYAspect);
    end;
  end
  else
  begin
    Result.cy := MaxHeight;
    Result.cx := Round(MaxHeight * XYAspect);
    if Result.cx > MaxWidth then
    begin
      Result.cx := MaxWidth;
      Result.cy := Round(MaxWidth / XYAspect);
    end;
  end;
end;

{$IF DECLARED(TBitmap)}
function CreateNewBitmap(const AWidth, AHeight: Integer): TBitmap;
begin
  {$IFDEF VCL}
  Result := TBitmap.Create;
  Result.SetSize(AWidth, AHeight);
  {$ELSE}
  Result := TBitmap.Create(AWidth, AHeight);
  {$ENDIF}
end;

procedure CreateExifThumbnail(Source: TGraphic; Dest: TJPEGImage;
  MaxWidth: Integer = StandardExifThumbnailWidth;
  MaxHeight: Integer = StandardExifThumbnailHeight);
var
  Bitmap: TBitmap;
  R: TRect;
begin
  with ProportionallyResizeExtents(Source.Width, Source.Height, MaxWidth, MaxHeight) do
    R := Rect(0, 0, cx, cy);
  Bitmap := CreateNewBitmap(R.Right, R.Bottom);
  try
    StretchDrawGraphic(Source, Bitmap.Canvas, R);
    Dest.Assign(Bitmap);
  finally
    Bitmap.Free;
  end;
end;
{$IFEND}

function DoRemoveMetaDataFromJPEG(InStream, OutStream: TStream;
  KindsToRemove: TJPEGMetadataKinds): TJPEGMetadataKinds;
var
  Segment: IFoundJPEGSegment;
  StartCopyFrom: Int64;

  procedure DoCopyFrom(const EndPos, NextStartPosOffset: Int64);
  begin
    InStream.Position := StartCopyFrom;
    if (EndPos - StartCopyFrom) > 0 then
      OutStream.CopyFrom(InStream, EndPos - StartCopyFrom);
    StartCopyFrom := EndPos + NextStartPosOffset;
  end;
var
  Block: IAdobeResBlock;
  IsIPTCBlock: Boolean;
  MarkersToLookFor: TJPEGMarkers;
  SavedBlocks: IInterfaceList;
begin
  MarkersToLookFor := [jmApp1];
  if mkIPTC in KindsToRemove then Include(MarkersToLookFor, jmApp13);
  StartCopyFrom := InStream.Position;
  for Segment in JPEGHeader(InStream, MarkersToLookFor) do
  begin
    if (mkExif in KindsToRemove) and Segment.IsExifBlock then
      Include(Result, mkExif)
    else if (mkXMP in KindsToRemove) and Segment.IsXMPBlock then
      Include(Result, mkXMP)
    else
    begin
      IsIPTCBlock := False;
      SavedBlocks := nil;
      if mkIPTC in KindsToRemove then
        for Block in Segment do
          if Block.IsIPTCBlock then
            IsIPTCBlock := True
          else
          begin
            if SavedBlocks = nil then SavedBlocks := TInterfaceList.Create;
            SavedBlocks.Add(Block);
          end;
      if IsIPTCBlock then
      begin
        Include(Result, mkIPTC);
        DoCopyFrom(Segment.Offset, Segment.TotalSize);
        if SavedBlocks <> nil then
          WriteJPEGSegment(OutStream, CreateAdobeApp13Segment(SavedBlocks));
      end;
      Continue;
    end;
    DoCopyFrom(Segment.Offset, Segment.TotalSize);
  end;
  DoCopyFrom(InStream.Size, 0);
end;

function RemoveMetadataFromJPEG(const JPEGFileName: string;
  Kinds: TJPEGMetadataKinds = AllJPEGMetaDataKinds): TJPEGMetadataKinds; overload;
var
  InStream: TMemoryStream;
  OutStream: TFileStream;
begin
  if Kinds = [] then Exit;
  OutStream := nil;
  InStream := TMemoryStream.Create;
  try
    InStream.LoadFromFile(JPEGFileName);
    OutStream := TFileStream.Create(JPEGFileName, fmCreate);
    Result := DoRemoveMetaDataFromJPEG(InStream, OutStream, Kinds);
  finally
    OutStream.Free;
    InStream.Free;
  end;
end;

function RemoveMetaDataFromJPEG(JPEGImage: TJPEGImage;
  Kinds: TJPEGMetadataKinds = AllJPEGMetaDataKinds): TJPEGMetadataKinds; overload;
var
  InStream, OutStream: TMemoryStream;
begin
  if Kinds = [] then Exit;
  OutStream := nil;
  InStream := TMemoryStream.Create;
  try
    JPEGImage.SaveToStream(InStream);
    InStream.Position := 0;
    OutStream := TMemoryStream.Create;
    Result := DoRemoveMetaDataFromJPEG(InStream, OutStream, Kinds);
    if Result <> [] then
    begin
      OutStream.Position := 0;
      JPEGImage.LoadFromStream(OutStream);
    end;
  finally
    OutStream.Free;
    InStream.Free;
  end;
end;

{$IFDEF FMX}
constructor TJPEGImage.Create;
begin
  inherited Create(0, 0);
end;

procedure TJPEGImage.SaveToStream(Stream: TStream);
var
  Filter: TBitmapCodec;
begin
  Filter := DefaultBitmapCodecClass.Create;
  try
    Filter.SaveToStream(Stream, TBitmap(Self), 'jpeg');
  finally
    Filter.Free;
  end;
end;
{$ENDIF}

{ segment header checking }

function HasExifHeader(Stream: TStream; MovePosOnSuccess: Boolean = False): Boolean;
begin
  Result := Stream.TryReadHeader(TJPEGSegment.ExifHeader, SizeOf(TJPEGSegment.ExifHeader),
    not MovePosOnSuccess);
end;

{ Exif date/time strings }

function GetExifSubSecsString(const MSecs: Word): string; overload;
begin
  Result := Copy(Format('%d', [MSecs]), 1, 3);
end;

function GetExifSubSecsString(const DateTime: TDateTime): string; overload;
begin
  Result := GetExifSubSecsString(MilliSecondOf(DateTime));
end;

function DateTimeToExifString(const DateTime: TDateTime): string;
var
  Year, Month, Day, Hour, Minute, Second, MilliSecond: Word;
begin
  if DateTime = 0 then
    Result := StringOfChar(' ', 19)
  else
  begin
    DecodeDateTime(DateTime, Year, Month, Day, Hour, Minute, Second, MilliSecond);
    FmtStr(Result, '%.4d:%.2d:%.2d %.2d:%.2d:%.2d', [Year, Month, Day, Hour, Minute, Second]);
  end;
end;

function TryExifStringToDateTime(const S: string; var DateTime: TDateTime): Boolean;
var
  Year, Month, Day, Hour, Min, Sec: Integer;
begin //'2007:09:02 02:30:49'
  Result := (Length(S) = 19) and (S[5] = ':') and (S[8] = ':') and 
    TryStrToInt(Copy(S, 1, 4), Year) and
    TryStrToInt(Copy(S, 6, 2), Month) and
    TryStrToInt(Copy(S, 9, 2), Day) and
    TryStrToInt(Copy(S, 12, 2), Hour) and
    TryStrToInt(Copy(S, 15, 2), Min) and
    TryStrToInt(Copy(S, 18, 2), Sec) and
    TryEncodeDateTime(Year, Month, Day, Hour, Min, Sec, 0, DateTime);
end;

{ TExifTag }

constructor TExifTag.Create(const Section: TExifSection;
  const ID: TExifTagID; DataType: TExifDataType; ElementCount: Integer);
begin
  inherited Create;
  FDataType := DataType;
  FID := ID;
  FSection := Section;
  FElementCount := ElementCount;
  if FElementCount < 0 then FElementCount := 0;
  FData := AllocMem(DataSize);
  FDataStream := TUserMemoryStream.Create(FData, DataSize);
  FOriginalDataSize := DataSize;
  FWellFormed := True;
end;

constructor TExifTag.Create(Section: TExifSection;
  const Directory: IFoundTiffDirectory; Index: Integer);
var
  Info: TTiffTagInfo;
begin
  Info := Directory.TagInfo[Index];
  if Info.IsWellFormed then
    Create(Section, Info.ID, Info.DataType, Info.ElementCount)
  else
    Create(Section, Info.ID, tdUndefined, 0);
  FOriginalDataOffset := Info.DataOffset;
  FWellFormed := Info.IsWellFormed;
  if Info.ElementCount > 0 then Directory.Parser.LoadTagData(Info, FData^);
end;

destructor TExifTag.Destroy;
begin
  if Section <> nil then Section.TagDeleting(Self);
  if FData <> nil then FreeMem(FData);
  FDataStream.Free;
  inherited;
end;

procedure TExifTag.Assign(Source: TExifTag);
begin
  if Source = nil then
    ElementCount := 0
  else
  begin
    if (Source.Section <> Section) or (Section = nil) then
      ID := Source.ID;
    UpdateData(Source.DataType, Source.ElementCount, Source.Data^);
  end;
end;

procedure TExifTag.Changing(NewID: TExifTagID; NewDataType: TExifDataType;
  NewElementCount: LongInt; NewData: Boolean);
begin
  if Section <> nil then
    Section.TagChanging(Self, NewID, NewDataType, NewElementCount, NewData);
end;

procedure TExifTag.Changed(ChangeType: TExifTagChangeType);
begin
  if ChangeType in [tcData, tcDataSize] then FAsStringCache := '';
  if Section <> nil then Section.TagChanged(Self, ChangeType);
end;

procedure TExifTag.Changed;
begin
  Changed(tcData);
end;

function TExifSection.CheckExtendable: TExtendableExifSection;
begin
  if Self is TExtendableExifSection then
    Result := TExtendableExifSection(Self)
  else
    raise EIllegalEditOfExifData.CreateRes(@SIllegalEditOfExifData);
end;

procedure TExifTag.Delete;
begin
  Free;
end;

function NextElementStr(DataType: TExifDataType; var SeekPtr: PAnsiChar): string;
begin
  case DataType of
    tdAscii: Result := string(AnsiString(SeekPtr^));
    tdByte: Result := IntToStr(PByte(SeekPtr)^);
    tdWord: Result := IntToStr(PWord(SeekPtr)^);
    tdLongWord: Result := IntToStr(PLongWord(SeekPtr)^);
    tdShortInt: Result := IntToStr(PShortInt(SeekPtr)^);
    tdSmallInt: Result := IntToStr(PSmallInt(SeekPtr)^);
    tdLongInt, tdSubDirectory: Result := IntToStr(PLongInt(SeekPtr)^);
    tdSingle: Result := FloatToStr(PSingle(SeekPtr)^);
    tdDouble: Result := FloatToStr(PDouble(SeekPtr)^);
    tdLongWordFraction, tdLongIntFraction: Result := PExifFraction(SeekPtr).AsString;
  end;
  Inc(SeekPtr, TiffElementSizes[DataType]);
end;

function TExifTag.GetAsString: string;
var
  TiffStr: TiffString;
  I: Integer;
  SeekPtr: PAnsiChar;
begin
  if (FAsStringCache = '') and (ElementCount <> 0) then
    case DataType of
      tdAscii:
      begin
        SetString(TiffStr, PAnsiChar(FData), ElementCount - 1);
        FAsStringCache := string(TiffStr);
      end;
      tdUndefined: FAsStringCache := BinToHexStr(FData, DataSize);
    else
      if HasWindowsStringData then
        FAsStringCache := WideCharLenToString(FData, ElementCount div 2 - 1)
      else
      begin
        SeekPtr := FData;
        if ElementCount = 1 then
          FAsStringCache := NextElementStr(DataType, SeekPtr)
        else
          with TStringList.Create do
          try
            for I := 0 to ElementCount - 1 do
              Add(NextElementStr(DataType, SeekPtr));
            FAsStringCache := CommaText;
          finally
            Free;
          end;
      end;
    end;
  Result := FAsStringCache;
end;

procedure TExifTag.SetAsString(const Value: string);
var
  Buffer: TiffString;
  S: string;
  List: TStringList;
  SeekPtr: PAnsiChar;
  UnicodeStr: UnicodeString;
begin
  if Length(Value) = 0 then
    ElementCount := 0
  else
    case DataType of
      tdAscii:
      begin
        if (Section <> nil) and Section.EnforceASCII and not ContainsOnlyASCII(Value) then
          raise ENotOnlyASCIIError.CreateRes(@STagCanContainOnlyASCII);
        Buffer := TiffString(Value);
        UpdateData(tdAscii, Length(Buffer) + 1, PAnsiChar(Buffer)^); //ascii tag data includes null terminator
      end;
      tdUndefined:
      begin
        SetLength(Buffer, Length(Value) div 2);
        SeekPtr := PAnsiChar(Buffer);
        HexToBin(PChar(LowerCase(Value)), SeekPtr, Length(Buffer));
        UpdateData(tdUndefined, Length(Buffer), SeekPtr^);
      end;
    else
      if HasWindowsStringData then
      begin
        UnicodeStr := Value;
        UpdateData(tdByte, Length(UnicodeStr) * 2 + 1, UnicodeStr[1]);
      end
      else
      begin
        List := TStringList.Create;
        try
          List.CommaText := Value;
          SetLength(Buffer, List.Count * TiffElementSizes[DataType]);
          SeekPtr := PAnsiChar(Buffer);
          for S in List do
          begin
            {$RANGECHECKS ON}
            case DataType of
              tdByte: PByte(SeekPtr)^ := StrToInt(S);
              tdWord: PWord(SeekPtr)^ := StrToInt(S);
              tdLongWord: PLongWord(SeekPtr)^ := StrToInt64(S);
              tdShortInt: PShortInt(SeekPtr)^ := StrToInt(S);
              tdSmallInt: PSmallInt(SeekPtr)^ := StrToInt(S);
              tdLongInt, tdSubDirectory: PLongInt(SeekPtr)^ := StrToInt(S);
              tdLongWordFraction, tdLongIntFraction: PExifFraction(SeekPtr)^ :=
                TExifFraction.CreateFromString(S);
              tdSingle: PSingle(SeekPtr)^ := StrToFloat(S);
              tdDouble: PDouble(SeekPtr)^ := StrToFloat(S);
            end;
            {$IFDEF RangeCheckingOff}{$RANGECHECKS OFF}{$ENDIF}
            Inc(SeekPtr, TiffElementSizes[DataType]);
          end;
        finally
          List.Free;
        end;
        UpdateData(DataType, Length(Buffer), Pointer(Buffer)^);
      end;
    end;
  FAsStringCache := Value;
end;

{$IFDEF HasToString}
function TExifTag.ToString: string;
begin
  Result := AsString;
end;
{$ENDIF}

function TExifTag.GetDataSize: Integer;
begin
  Result := ElementCount * TiffElementSizes[DataType]
end;

function TExifTag.GetElementAsString(Index: Integer): string;
var
  SeekPtr: PAnsiChar;
begin
  if (Index < 0) or (Index >= ElementCount) then
    raise EListError.CreateFmt(SListIndexError, [Index]);
  SeekPtr := FData;
  Inc(SeekPtr, Index * TiffElementSizes[DataType]);
  Result := NextElementStr(DataType, SeekPtr);
end;

function TExifTag.HasWindowsStringData: Boolean;
begin
  Result := False;
  if (DataType = tdByte) and (Section <> nil) and (Section.Kind = esGeneral) then
    case ID of
      ttWindowsTitle, ttWindowsComments, ttWindowsAuthor, ttWindowsKeywords,
      ttWindowsSubject: Result := True;
    end;
end;

procedure TExifTag.SetDataType(const NewDataType: TExifDataType);
begin
  if NewDataType <> FDataType then
    UpdateData(NewDataType, ElementCount, PByte(nil)^);
end;

procedure TExifTag.SetElementCount(const NewCount: LongInt);
begin
  if NewCount <> FElementCount then
    UpdateData(DataType, NewCount, PByte(nil)^);
end;

procedure TExifTag.SetID(const Value: TExifTagID);
begin
  if Value = FID then Exit;
  Changing(Value, DataType, ElementCount, False);
  FID := Value;
  Changed(tcID);
end;

function TExifTag.IsPadding: Boolean;
begin
  Result := (ID = ttWindowsPadding) and (DataType = tdUndefined) and
    (ElementCount >= 2) and (PWord(Data)^ = ttWindowsPadding);
end;

function TExifTag.ReadFraction(Index: Integer; const Default: TExifFraction): TExifFraction;
begin
  if (DataType in [tdLongWordFraction, tdLongIntFraction]) and (Index >= 0) and
     (Index < ElementCount) then
    Result := PExifFractionArray(FData)[Index]
  else
    Result := Default;
end;

function TExifTag.ReadLongWord(Index: Integer; const Default: LongWord): LongWord;
begin
  if (Index < 0) or (Index >= ElementCount) then
    Result := Default
  else
    case DataType of
      tdByte, tdShortInt: Result := PByteArray(FData)[Index];
      tdWord, tdSmallInt: Result := PWordArray(FData)[Index];
      tdLongWord, tdLongInt: Result := PLongWordArray(FData)[Index];
    else Result := Default;
    end;
end;

function TExifTag.ReadWord(Index: Integer; const Default: Word): Word;
begin
  if (Index < 0) or (Index >= ElementCount) then
    Result := Default
  else
    case DataType of
      tdByte, tdShortInt: Result := PByteArray(FData)[Index];
      tdWord, tdSmallInt: Result := PWordArray(FData)[Index];
    else Result := Default;
    end;
end;

procedure TExifTag.SetAsPadding(Size: TExifPaddingTagSize);
begin
  ID := ttWindowsPadding;
  UpdateData(tdUndefined, Size, Pointer(nil)^);
  PWord(Data)^ := ttWindowsPadding;
  if Size > 2 then
    FillChar(PWordArray(Data)[1], Size - 2, 0);
end;

procedure TExifTag.UpdateData(const NewData);
begin
  Changing(ID, DataType, ElementCount, True);
  Move(NewData, FData^, DataSize);
  Changed(tcData);
end;

procedure TExifTag.UpdateData(NewDataType: TExifDataType;
  NewElementCount: Integer; const NewData);
const
  IntDataTypes = [tdByte, tdWord, tdLongWord, tdShortInt, tdSmallInt, tdLongWord];
var
  OldDataSize, NewDataSize, I: Integer;
  OldIntVals: array of LongWord;
begin
  if NewElementCount < 0 then NewElementCount := 0;
  if (@NewData = nil) and (NewDataType = DataType) and (NewElementCount = ElementCount) then
    Exit;
  OldDataSize := GetDataSize;
  NewDataSize := NewElementCount * TiffElementSizes[NewDataType];
  Changing(ID, NewDataType, NewElementCount, (@NewData <> nil));
  if (@NewData = nil) and (NewDataSize <> OldDataSize) and (DataType in IntDataTypes) and
     (NewDataType in IntDataTypes) and (ElementCount <> 0) and (NewElementCount <> 0) then
  begin
    SetLength(OldIntVals, FElementCount);
    for I := 0 to Min(FElementCount, NewElementCount) - 1 do
      Move(PByteArray(FData)[I * TiffElementSizes[DataType]], OldIntVals[I],
        TiffElementSizes[DataType]);
  end;
  ReallocMem(FData, NewDataSize);
  FDataStream.ChangeMemory(FData, NewDataSize);
  if NewDataSize > OldDataSize then
    FillChar(PByteArray(FData)[OldDataSize], NewDataSize - OldDataSize, 0);
  if @NewData <> nil then
    Move(NewData, FData^, NewDataSize)
  else if TiffElementSizes[FDataType] <> TiffElementSizes[NewDataType] then
  begin
    FillChar(FData^, Min(OldDataSize, NewDataSize), 0);
    if OldIntVals <> nil then
      for I := 0 to High(OldIntVals) do
        Move(OldIntVals[I], PByteArray(FData)[I * TiffElementSizes[DataType]],
          TiffElementSizes[DataType]);
  end;
  FDataType := NewDataType;
  FElementCount := NewElementCount;
  if NewDataSize <> OldDataSize then
    Changed(tcDataSize)
  else
    Changed(tcData);
end;

procedure TExifTag.WriteHeader(Stream: TStream; Endianness: TEndianness;
  DataOffset: LongInt);
var
  I: Integer;
begin
  Stream.WriteWord(ID, Endianness);
  Stream.WriteWord(Ord(DataType), Endianness);
  Stream.WriteLongInt(ElementCount, Endianness);
  if DataSize > 4 then
    Stream.WriteLongInt(DataOffset, Endianness)
  else
  begin
    case TiffElementSizes[DataType] of
      1: Stream.WriteBuffer(Data^, ElementCount);
      2: for I := 0 to ElementCount - 1 do
           Stream.WriteWord(PWordArray(Data)[I], Endianness);
      4: Stream.WriteLongWord(PLongWord(Data)^, Endianness);
    end;
    for I := 3 downto DataSize do
      Stream.WriteByte(0);
  end;
end;

procedure TExifTag.WriteOffsettedData(Stream: TStream; Endianness: TEndianness);
var
  I: Integer;
begin
  if DataSize <= 4 then Exit;
  if DataType = tdDouble then
    for I := 0 to ElementCount - 1 do
      Stream.WriteDouble(PDoubleArray(Data)[I], Endianness)
  else
    case TiffElementSizes[DataType] of
      1: Stream.WriteBuffer(Data^, ElementCount);
      2: for I := 0 to ElementCount - 1 do
           Stream.WriteWord(PWordArray(Data)[I], Endianness);
    else
      for I := 0 to DataSize div 4 - 1 do
        Stream.WriteLongWord(PLongWordArray(Data)[I], Endianness)
    end;
end;

{ TExifTag.IMetadataBlock }

function TExifTag.GetData: TCustomMemoryStream;
begin
  Result := FDataStream;
end;

function TExifTag.IsExifBlock(CheckID: Boolean = True): Boolean;
begin
  Result := False;
end;

function TExifTag.IsIPTCBlock(CheckID: Boolean = True): Boolean;
var
  Header: TIPTCTagInfo;
begin
  FDataStream.Seek(0, soFromBeginning);
  Result := (not CheckID or (ID = ttIPTC)) and
    TAdobeResBlock.TryReadIPTCHeader(FDataStream, Header, True);
end;

function TExifTag.IsXMPBlock(CheckID: Boolean = True): Boolean;
begin
  Result := False;
end;

{ TExifTag.ITiffTag }

function TExifTag.GetDataType: TTiffDataType;
begin
  Result := FDataType;
end;

function TExifTag.GetElementCount: Integer;
begin
  Result := FElementCount;
end;

function TExifTag.GetID: TTiffTagID;
begin
  Result := FID;
end;

function TExifTag.GetOriginalDataOffset: LongWord;
begin
  Result := FOriginalDataOffset;
end;

function TExifTag.GetParent: ITiffDirectory;
begin
  Result := FSection;
end;

{ TExifSection.TEnumerator }

constructor TExifSection.TEnumerator.Create(ATagList: TList);
begin
  FCurrent := nil;
  FIndex := 0;
  FTags := ATagList;
end;

function TExifSection.TEnumerator.GetCurrent: ITiffTag;
begin
  Result := Current;
end;

function TExifSection.TEnumerator.MoveNext: Boolean;
begin //allow deleting a tag when enumerating
  if (FCurrent <> nil) and (FIndex < FTags.Count) and (FCurrent = FTags.List[FIndex]) then
    Inc(FIndex);
  Result := FIndex < FTags.Count;
  if Result then FCurrent := FTags.List[FIndex];
end;

{ TExifSection }

constructor TExifSection.Create(AOwner: TCustomExifData; AKind: TExifSectionKindEx);
begin
  inherited Create;
  FOwner := AOwner;
  FTagList := TList.Create;
  FKind := AKind;
end;

destructor TExifSection.Destroy;
var
  I: Integer;
begin
  for I := FTagList.Count - 1 downto 0 do
    with TExifTag(FTagList.List[I]) do
    begin
      FSection := nil;
      Destroy;
    end;
  FTagList.Free;
  inherited;
end;

function TExifSection.Add(ID: TExifTagID; DataType: TExifDataType;
  ElementCount: Integer): TExifTag;
var
  I: Integer;
  Tag: TExifTag;
begin
  CheckExtendable;
  for I := 0 to FTagList.Count - 1 do
  begin
    Tag := FTagList.List[I];
    if Tag.ID = ID then
      raise ETagAlreadyExists.CreateResFmt(@STagAlreadyExists, [ID]);
    if Tag.ID > ID then
    begin
      Result := TExifTag.Create(Self, ID, DataType, ElementCount);
      FTagList.Insert(I, Result);
      Changed;
      Exit;
    end;
  end;
  Result := TExifTag.Create(Self, ID, DataType, ElementCount);
  FTagList.Add(Result);
  Changed;
end;

procedure TExifSection.Changed;
begin
  FModified := True;
  if (FOwner <> nil) and (FKind <> esUserDefined) then FOwner.Changed(Self);
end;

procedure TExifSection.Clear;
var
  I: Integer;
begin
  FLoadErrors := [];
  if FOwner <> nil then FOwner.BeginUpdate;
  try
    for I := FTagList.Count - 1 downto 0 do
      DoDelete(I, True);
  finally
    if FOwner <> nil then FOwner.EndUpdate;
  end;
end;

procedure TExifSection.DoDelete(TagIndex: Integer; FreeTag: Boolean);
var
  Tag: TExifTag;
begin
  Tag := FTagList[TagIndex];
  FTagList.Delete(TagIndex);
  Tag.FSection := nil;
  if (Tag.ID = ttMakerNote) and (FKind = esDetails) and (FOwner <> nil) then
    FOwner.ResetMakerNoteType;
  if FreeTag then Tag.Destroy;
  Changed;
end;

function TExifSection.EnforceASCII: Boolean;
begin
  Result := (FOwner <> nil) and FOwner.EnforceASCII;
end;

function TExifSection.Find(ID: TExifTagID; out Tag: TExifTag): Boolean;
var
  Index: Integer;
begin
  Result := FindIndex(ID, Index);
  if Result then
    Tag := FTagList.List[Index]
  else
    Tag := nil;
end;

function TExifSection.FindIndex(ID: TExifTagID; var TagIndex: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FTagList.Count - 1 do
    if TExifTag(FTagList.List[I]).ID >= ID then
    begin
      if TExifTag(FTagList.List[I]).ID = ID then
      begin
        TagIndex := I;
        Result := True;
      end;
      Exit;
    end;
end;

function TExifSection.FindTag(TagID: TTiffTagID; out ParsedTag: ITiffTag): Boolean;
var
  Obj: TExifTag;
begin
  Result := Find(TagID, Obj);
  if Result then ParsedTag := Obj;
end;

function TExifSection.ForceSetElement(ID: TExifTagID; DataType: TExifDataType;
  Index: Integer; const Value): TExifTag;
var
  Dest: PByte;
  NewValueIsDifferent: Boolean;
begin
  Assert(Index >= 0);
  if Find(ID, Result) then
    Result.UpdateData(DataType, Max(Result.ElementCount, Succ(Index)), PByte(nil)^)
  else
    Result := Add(ID, DataType, Succ(Index));
  Dest := @PByteArray(Result.Data)[Index * TiffElementSizes[DataType]];
  NewValueIsDifferent := not CompareMem(Dest, @Value, TiffElementSizes[DataType]);
  if NewValueIsDifferent then
  begin
    Move(Value, Dest^, TiffElementSizes[DataType]);
    Result.Changed;
  end;
end;

function TExifSection.LoadSubDirectory(OffsetTagID: TTiffTagID): ITiffDirectory;
begin
  Result := nil;
  if Owner <> nil then
    case Kind of
      esGeneral:
        case OffsetTagID of
          ttExifOffset: Result := Owner[esDetails];
          ttGPSOffset: Result := Owner[esGPS];
        end;
      esDetails: if OffsetTagID = ttInteropOffset then Result := Owner[esInterop];
    end;
  if Result = nil then
    raise EInvalidTiffData.CreateRes(@SInvalidOffsetTag);
end;

function TExifSection.GetTagCount: Integer;
begin
  Result := FTagList.Count;
end;

function TExifSection.GetEnumerator: TEnumerator;
begin
  Result := TEnumerator.Create(FTagList);
end;

function TExifSection.GetEnumeratorIntf: ITiffDirectoryEnumerator;
begin
  Result := GetEnumerator;
end;

function TExifSection.GetIndex: Integer;
begin
  case FKind of
    esGeneral: Result := 0;
    esDetails: Result := ttExifOffset;
    esInterop: Result := ttInteropOffset;
    esGPS: Result := ttGPSOffset;
    esThumbnail: Result := 1;
  else Result := -1;
  end;
end;

function TExifSection.GetParent: ITiffDirectory;
begin
  if Owner = nil then
    Result := nil
  else
    case FKind of
      esDetails, esGPS: Result := Owner[esGeneral];
      esInterop, esMakerNote: Result := Owner[esDetails];
    else Result := nil;
    end;
end;

function TExifSection.GetByteValue(TagID: TExifTagID; Index: Integer; Default: Byte;
  MinValue: Byte = 0; MaxValue: Byte = High(Byte)): Byte;
begin
  if not TryGetByteValue(TagID, Index, Result) or (Result < MinValue) or (Result > MaxValue) then
    Result := Default;
end;

function TExifSection.GetDateTimeValue(MainID, SubSecsID: TExifTagID): TDateTimeTagValue;
var
  DateTime: TDateTime;
  SubSecsTag: TExifTag;
  SubSecs: Integer;
  S: TiffString;
begin
  if not TryExifStringToDateTime(GetStringValue(MainID), DateTime) then
  begin
    Result := TDateTimeTagValue.CreateMissingOrInvalid;
    Exit;
  end;
  if (Owner <> nil) and (SubSecsID <> 0) and Owner[esDetails].Find(SubSecsID, SubSecsTag) and
    (SubSecsTag.ElementCount > 1) and (SubSecsTag.DataType = tdAscii) then
  begin
    SetLength(S, 3);
    FillChar(Pointer(S)^, 3, '0');
    Move(SubSecsTag.Data^, S[1], Max(3, SubSecsTag.ElementCount - 1));
    if TryStrToInt(string(S), SubSecs) then
      IncMilliSecond(DateTime, SubSecs);
  end;
  Result := DateTime;
end;

function TExifSection.GetFractionValue(TagID: TExifTagID; Index: Integer): TExifFraction;
begin
  Result := GetFractionValue(TagID, Index, NullFraction)
end;

function TExifSection.GetFractionValue(TagID: TExifTagID; Index: Integer;
  const Default: TExifFraction): TExifFraction;
var
  Tag: TExifTag;
begin
  if Find(TagID, Tag) and (Tag.DataType in [tdLongWordFraction,
     tdLongIntFraction]) and (Tag.ElementCount > Index) and (Index >= 0) then
    Result := PExifFractionArray(Tag.Data)[Index]
  else
    Result := Default;     
end;

function TExifSection.GetLongIntValue(TagID: TExifTagID; Index: Integer): TLongIntTagValue;
begin
  Result := 0; //needs initialising first
  if not TryGetLongWordValue(TagID, Index, Result) then
    Result := TLongIntTagValue.CreateMissingOrInvalid;
end;

function TExifSection.GetLongIntValue(TagID: TExifTagID; Index: Integer;
  Default: LongInt): LongInt;
begin
  if not TryGetLongWordValue(TagID, Index, Result) then
    Result := Default;
end;

function TExifSection.GetLongWordValue(TagID: TExifTagID; Index: Integer): TLongWordTagValue;
begin
  Result := 0; //needs initialising first
  if not TryGetLongWordValue(TagID, Index, Result) then
    Result := TLongWordTagValue.CreateMissingOrInvalid;
end;

function TExifSection.GetLongWordValue(TagID: TExifTagID; Index: Integer;
  Default: LongWord): LongWord;
begin
  if not TryGetLongWordValue(TagID, Index, Result) then
    Result := Default;
end;

function TExifSection.GetSmallIntValue(TagID: TExifTagID; Index: Integer; Default: SmallInt;
  MinValue: SmallInt = Low(SmallInt); MaxValue: SmallInt = High(SmallInt)): SmallInt;
begin
  if not TryGetWordValue(TagID, Index, Result) or (Result < MinValue) or (Result > MaxValue) then
    Result := Default;
end;

function TExifSection.GetStringValue(TagID: TExifTagID;
  const Default: string): string;
begin
  if not TryGetStringValue(TagID, Result) then
    Result := Default;
end;

function TExifSection.GetWindowsStringValue(TagID: TExifTagID;
  const Default: UnicodeString): UnicodeString;
begin
  if not TryGetWindowsStringValue(TagID, Result) then
    Result := Default;
end;

function TExifSection.GetWordValue(TagID: TExifTagID; Index: Integer): TWordTagValue;
begin
  Result := 0; //ensure default as NOT missing or invalid
  if not TryGetWordValue(TagID, Index, Result) then
    Result := TWordTagValue.CreateMissingOrInvalid;
end;

function TExifSection.GetWordValue(TagID: TExifTagID; Index: Integer; Default: Word;
  MinValue: Word = 0; MaxValue: Word = High(Word)): Word;
begin
  if not TryGetWordValue(TagID, Index, Result) or (Result < MinValue) or (Result > MaxValue) then
    Result := Default;
end;

function TExifSection.IsExtendable: Boolean;
begin
  Result := InheritsFrom(TExtendableExifSection);
end;

function CompareIDs(Item1, Item2: TExifTag): Integer;
begin
  Result := Item1.ID - Item2.ID;
end;

procedure TExifSection.Load(const Directory: IFoundTiffDirectory;
  TiffImageSource: Boolean);
var
  I: Integer;
  NewTag: TExifTag;
begin
  Clear;
  FLoadErrors := Directory.LoadErrors;
  if Directory.TagInfo = nil then
    FFirstTagHeaderOffset := 0
  else
  begin
    FFirstTagHeaderOffset := Directory.TagInfo[0].HeaderOffset;
    for I := 0 to High(Directory.TagInfo) do
      if not TiffImageSource or (Kind <> esGeneral) or IsKnownExifTagInMainIFD(Directory.TagInfo[I]) then
      begin
        NewTag := TExifTag.Create(Self, Directory, I);
        FTagList.Add(NewTag);
      end;
    FTagList.Sort(@CompareIDs);
  end;
  FModified := False;
end;

function TExifSection.Remove(ID: TExifTagID): Boolean;
var
  Index: Integer;
begin
  Result := FindIndex(ID, Index);
  if Result then DoDelete(Index, True);
end;

procedure TExifSection.Remove(const IDs: array of TExifTagID);
var
  I: Integer;
  ID: TExifTagID;
  Tag: TExifTag;
begin
  if Owner <> nil then Owner.BeginUpdate;
  try
    for I := FTagList.Count - 1 downto 0 do
    begin
      Tag := TExifTag(FTagList.List[I]);
      for ID in IDs do
        if ID = Tag.ID then
        begin
          DoDelete(I, True);
          Break;
        end;
    end;
  finally
    if Owner <> nil then Owner.EndUpdate;
  end;
end;

function TExifSection.RemovePaddingTag: Boolean;
var
  Tag: TExifTag;
begin
  Result := False;
  for Tag in Self do
    if Tag.IsPadding then
    begin
      Tag.Delete;
      Result := True;
      Exit;
    end;
end;

function TExifSection.SetByteValue(TagID: TExifTagID; Index: Integer; Value: Byte): TExifTag;
begin
  Result := ForceSetElement(TagID, tdByte, Index, Value);
end;

procedure TExifSection.SetDateTimeValue(MainID, SubSecsID: TExifTagID;
  const Value: TDateTimeTagValue);
var
  SubSecsTag: TExifTag;
begin
  if (Owner = nil) or (SubSecsID = 0) then
    SubSecsTag := nil
  else
    if not Owner[esDetails].Find(SubSecsID, SubSecsTag) then
      if not Value.MissingOrInvalid and Owner.AlwaysWritePreciseTimes then
        SubSecsTag := Owner[esDetails].Add(SubSecsID, tdAscii, 4)
      else
        SubSecsTag := nil;
  if Value.MissingOrInvalid then
  begin
    Remove(MainID);
    FreeAndNil(SubSecsTag);
  end
  else
  begin
    if Value <> LastSetDateTimeValue then
    begin
      LastSetDateTimeValue := Value;
      LastSetDateTimeMainStr := DateTimeToExifString(Value);
      LastSetDateTimeSubSecStr := GetExifSubSecsString(Value);
    end;
    SetStringValue(MainID, LastSetDateTimeMainStr);
    if SubSecsTag <> nil then
    begin
      SubSecsTag.DataType := tdAscii;
      SubSecsTag.AsString := LastSetDateTimeSubSecStr;
    end;
  end;
end;

procedure TExifSection.DoSetFractionValue(TagID: TExifTagID; Index: Integer;
  DataType: TExifDataType; const Value);
var
  Tag: TExifTag;
begin
  if Int64(Value) = 0 then //prefer deleting over setting null fractions
    if not Find(TagID, Tag) or (Tag.ElementCount <= Index) then
      Exit
    else if Tag.ElementCount = Succ(Index) then
    begin
      if Index = 0 then
        Tag.Delete
      else
        Tag.ElementCount := Index;
      Exit;
    end;
  ForceSetElement(TagID, DataType, Index, Value);
end;

procedure TExifSection.SetFractionValue(TagID: TExifTagID; Index: Integer;
  const Value: TExifFraction);
begin
  DoSetFractionValue(TagID, Index, tdExifFraction, Value);
end;

function TExifSection.SetLongWordValue(TagID: TExifTagID; Index: Integer; Value: LongWord): TExifTag;
begin
  Result := ForceSetElement(TagID, tdLongWord, Index, Value);
end;

procedure TExifSection.SetSignedFractionValue(TagID: TExifTagID; Index: Integer;
  const Value: TExifSignedFraction);
begin
  DoSetFractionValue(TagID, Index, tdExifFraction, Value);
end;

procedure TExifSection.SetStringValue(TagID: TExifTagID; const Value: string);
var
  ElemCount: Integer;
  Tag: TExifTag;
begin
  if Value = '' then
  begin
    Remove(TagID);
    Exit;
  end;
  if EnforceASCII and not ContainsOnlyASCII(Value) then
    raise ENotOnlyASCIIError.CreateRes(@STagCanContainOnlyASCII);
  ElemCount := Length(Value) + 1; //ascii tiff tag data includes null terminator
  if not Find(TagID, Tag) then
    Tag := Add(TagID, tdAscii, ElemCount);
  Tag.UpdateData(tdAscii, ElemCount, PAnsiChar(TiffString(Value))^)
end;

procedure TExifSection.SetWindowsStringValue(TagID: TExifTagID; const Value: UnicodeString);
var
  ElemCount: Integer;
  Tag: TExifTag;
begin
  if Value = '' then
  begin
    Remove(TagID);
    Exit;
  end;
  ElemCount := (Length(Value) + 1) * 2; //data includes null terminator
  if not Find(TagID, Tag) then
    Tag := Add(TagID, tdByte, ElemCount);
  Tag.UpdateData(tdByte, ElemCount, PWideChar(Value)^);
end;

function TExifSection.SetWordValue(TagID: TExifTagID; Index: Integer; Value: Word): TExifTag;
begin
  Result := ForceSetElement(TagID, tdWord, Index, Value);
end;

procedure TExifSection.TagChanging(Tag: TExifTag; NewID: TExifTagID;
  NewDataType: TExifDataType; NewElementCount: LongInt; NewData: Boolean);
var
  NewDataSize: Integer;
  OtherTag: TExifTag;
begin
  if (NewID <> Tag.ID) and CheckExtendable.Find(NewID, OtherTag) then //Changing of tag IDs is disallowed in patch
    raise ETagAlreadyExists.CreateFmt(STagAlreadyExists, [NewID]);    //mode to ensure sorting of IFD is preserved.
  NewDataSize := TiffElementSizes[NewDataType] * NewElementCount;
  if (NewDataSize > 4) and (NewDataSize > Tag.OriginalDataSize) then
    CheckExtendable;
  if (FKind = esDetails) and (Tag.ID = ttMakerNote) and (FOwner <> nil) then
    FOwner.ResetMakerNoteType
end;

procedure TExifSection.TagChanged(Tag: TExifTag; ChangeType: TExifTagChangeType);
var
  I: Integer;
begin
  if ChangeType = tcID then
    for I := FTagList.Count - 1 downto 0 do
      if Tag.ID > TExifTag(FTagList.List[I]).ID then
      begin
        FTagList.Move(FTagList.IndexOf(Tag), I + 1);
        Break;
      end;
  Changed;
end;

procedure TExifSection.TagDeleting(Tag: TExifTag);
begin
  DoDelete(FTagList.IndexOf(Tag), False);
end;

function TExifSection.TagExists(ID: TExifTagID; ValidDataTypes: TExifDataTypes;
  MinElementCount, MaxElementCount: LongInt): Boolean;
var
  Tag: TExifTag;
begin
  Result := Find(ID, Tag) and (Tag.DataType in ValidDataTypes) and
    (Tag.ElementCount >= MinElementCount) and (Tag.ElementCount <= MaxElementCount);
end;

function TExifSection.TryGetByteValue(TagID: TExifTagID; Index: Integer; var Value): Boolean;
var
  Tag: TExifTag;
begin
  Result := Find(TagID, Tag) and (Tag.DataType in [tdByte, tdShortInt, tdUndefined]) and
    (Tag.ElementCount > Index) and (Index >= 0);
  if Result then
    Byte(Value) := PByteArray(Tag.Data)[Index];
end;

function TExifSection.TryGetLongWordValue(TagID: TExifTagID; Index: Integer;
  var Value): Boolean;
var
  Tag: TExifTag;
begin
  Result := Find(TagID, Tag) and (Index < Tag.ElementCount) and (Index >= 0);
  if Result then
    case Tag.DataType of
      tdByte, tdShortInt: LongWord(Value) := PByteArray(Tag.Data)[Index];
      tdWord, tdSmallInt: LongWord(Value) := PWordArray(Tag.Data)[Index];
      tdLongWord, tdLongInt: LongWord(Value) := PLongWordArray(Tag.Data)[Index];
    else Result := False;
    end;
end;

function TExifSection.TryGetStringValue(TagID: TExifTagID; var Value: string): Boolean;
var
  Len: Integer;
  Tag: TExifTag;
  S: AnsiString;
begin
  Result := Find(TagID, Tag) and (Tag.DataType = tdAscii) and (Tag.ElementCount > 0);
  if Result then
  begin
    Len := Tag.ElementCount - 1;
    if PAnsiChar(Tag.Data)[Len] > ' ' then Inc(Len);
    SetString(S, PAnsiChar(Tag.Data), Len);
    Value := string(S); //for D2009+ compatibility
  end
end;

function TExifSection.TryGetWindowsStringValue(TagID: TExifTagID; var Value: UnicodeString): Boolean;
var
  Tag: TExifTag;
begin
  Result := Find(TagID, Tag) and (Tag.DataType = tdByte) and (Tag.ElementCount > 1); //should have at least 2 bytes since null terminated
  if Result then
    SetString(Value, PWideChar(Tag.Data), Tag.ElementCount div 2 - 1)
end;

function TExifSection.TryGetWordValue(TagID: TExifTagID; Index: Integer;
  var Value): Boolean;
var
  Tag: TExifTag;
begin
  Result := Find(TagID, Tag) and (Index < Tag.ElementCount) and (Index >= 0);
  if Result then
    case Tag.DataType of
      tdByte, tdShortInt: Word(Value) := PByteArray(Tag.Data)[Index];
      tdWord, tdSmallInt: Word(Value) := PWordArray(Tag.Data)[Index];
    else Result := False;
    end;
end;

{ TExtendableExifSection }

function TExtendableExifSection.Add(ID: TExifTagID; DataType: TExifDataType;
  ElementCount: LongInt): TExifTag;
begin
  Result := inherited Add(ID, DataType, ElementCount);
end;

function TExtendableExifSection.AddOrUpdate(ID: TExifTagID; DataType: TExifDataType;
  ElementCount: Integer): TExifTag;
begin
  if not Find(ID, Result) then
    Result := Add(ID, DataType, ElementCount);
  Result.UpdateData(DataType, ElementCount, Pointer(nil)^);
end;

function TExtendableExifSection.AddOrUpdate(ID: TExifTagID; DataType: TExifDataType;
  ElementCount: Integer; const Data): TExifTag;
begin
  if not Find(ID, Result) then
    Result := Add(ID, DataType, ElementCount);
  Result.UpdateData(DataType, ElementCount, Data);
end;

function TExtendableExifSection.AddOrUpdate(ID: TExifTagID; DataType: TExifDataType;
  const Source: IStreamPersist): TExifTag;
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    if Source <> nil then Source.SaveToStream(Stream);
    Result := AddOrUpdate(ID, DataType, Ceil(Stream.Size / TiffElementSizes[DataType]),
      Stream.Memory^);
  finally
    Stream.Free;
  end;
end;

procedure TExtendableExifSection.Assign(Source: TExifSection);
begin
  if Owner <> nil then Owner.BeginUpdate;
  try
    if Source = nil then
      Clear
    else
    begin
      Clear;
      CopyTags(Source)
    end
  finally
    if Owner <> nil then Owner.EndUpdate;
  end;
end;

procedure TExtendableExifSection.CopyTags(Section: TExifSection);
var
  Tag: TExifTag;
begin
  if Section <> nil then
    for Tag in Section do
      AddOrUpdate(Tag.ID, Tag.DataType, Tag.ElementCount, Tag.Data^)
end;

{ TExifFlashInfo }

function DoGetMode(const BitSet: TWordBitSet): TExifFlashMode;
begin
  if 4 in BitSet then
    if 3 in BitSet then
      Result := efAuto
    else
      Result := efCompulsorySuppression
  else
    if 3 in BitSet then
      Result := efCompulsoryFire
    else
      Result := efUnknown;
end;

function DoGetStrobeLight(const BitSet: TWordBitSet): TExifStrobeLight;
begin
  if 2 in BitSet then
    if 1 in BitSet then
      Result := esDetected
    else
      Result := esUndetected
  else
    Result := esNoDetectionFunction;
end;

constructor TExifFlashInfo.Create(AOwner: TCustomExifData);
begin
  inherited Create;
  FOwner := AOwner;
end;

procedure TExifFlashInfo.Assign(Source: TPersistent);
begin
  if not (Source is TExifFlashInfo) and (Source <> nil) then
  begin
    inherited;
    Exit;
  end;
  FOwner.BeginUpdate;
  try
    if Source = nil then
    begin
      BitSet := [];
      StrobeEnergy := NullFraction;
    end
    else
    begin
      BitSet := TExifFlashInfo(Source).BitSet;
      StrobeEnergy := TExifFlashInfo(Source).StrobeEnergy;
    end;
  finally
    FOwner.EndUpdate;
  end;
end;

function TExifFlashInfo.MissingOrInvalid: Boolean;
begin
  with FOwner[esDetails] do
    Result := not TagExists(ttFlash, [tdWord, tdSmallInt]) and
      not TagExists(ttFlashEnergy, [tdLongWordFraction, tdLongIntFraction]);
end;

function TExifFlashInfo.GetBitSet: TWordBitSet;
begin
  if not FOwner[esDetails].TryGetWordValue(ttFlash, 0, Result) then
    Result := [];
end;

procedure TExifFlashInfo.SetBitSet(const Value: TWordBitSet);
const
  XMPRoot = UnicodeString('Flash');
  StrobeLightValues: array[TExifStrobeLight] of Integer = (0, 2, 3);
var
  Root: TXMPProperty;
  ValueAsSource: Integer absolute Value;
begin
  if Value = [] then
  begin
    FOwner[esDetails].Remove(ttFlash);
    FOwner.XMPPacket.RemoveProperty(xsExif, XMPRoot);
    Exit;
  end;
  FOwner[esDetails].ForceSetElement(ttFlash, tdWord, 0, Value);
  if FOwner.XMPWritePolicy = xwRemove then
  begin
    FOwner.XMPPacket.RemoveProperty(xsExif, XMPRoot);
    Exit;
  end;
  if not FOwner.XMPPacket[xsExif].FindProperty(XMPRoot, Root) then
    if FOwner.XMPWritePolicy = xwUpdateIfExists then
      Exit
    else
      Root := FOwner.XMPPacket[xsExif].AddProperty(XMPRoot);
  Root.Kind := xpStructure;
  Root.UpdateSubProperty('Fired', FiredBit in Value);
  Root.UpdateSubProperty('Function', NotPresentBit in Value);
  Root.UpdateSubProperty('Mode', Ord(DoGetMode(Value)));
  Root.UpdateSubProperty('RedEyeMode', RedEyeReductionBit in Value);
  Root.UpdateSubProperty('Return', StrobeLightValues[DoGetStrobeLight(Value)]);
end;

function TExifFlashInfo.GetFired: Boolean;
begin
  Result := FiredBit in BitSet;
end;

procedure TExifFlashInfo.SetFired(Value: Boolean);
begin
  if Value then
    BitSet := BitSet + [FiredBit]
  else
    BitSet := BitSet - [FiredBit]
end;

function TExifFlashInfo.GetMode: TExifFlashMode;
begin
  Result := DoGetMode(BitSet);
end;

procedure TExifFlashInfo.SetMode(const Value: TExifFlashMode);
var
  Values: TWordBitSet;
begin
  Values := BitSet;
  if Value in [efCompulsorySuppression, efAuto] then
    Include(Values, 4)
  else
    Exclude(Values, 4);
  if Value in [efCompulsoryFire, efAuto] then
    Include(Values, 3)
  else
    Exclude(Values, 3);
  BitSet := Values;
end;

function TExifFlashInfo.GetPresent: Boolean;
begin
  Result := not (NotPresentBit in BitSet);
end;

procedure TExifFlashInfo.SetPresent(Value: Boolean);
begin
  if Value then
    BitSet := BitSet - [NotPresentBit]
  else
    BitSet := BitSet + [NotPresentBit]
end;

function TExifFlashInfo.GetRedEyeReduction: Boolean;
begin
  Result := RedEyeReductionBit in BitSet
end;

procedure TExifFlashInfo.SetRedEyeReduction(Value: Boolean);
begin
  if Value then
    BitSet := BitSet + [RedEyeReductionBit]
  else
    BitSet := BitSet - [RedEyeReductionBit]
end;

function TExifFlashInfo.GetStrobeLight: TExifStrobeLight;
begin
  Result := DoGetStrobeLight(BitSet);
end;

procedure TExifFlashInfo.SetStrobeLight(const Value: TExifStrobeLight);
var
  Values: TWordBitSet;
begin
  Values := BitSet;
  Include(Values, 2);
  case Value of
    esUndetected: Exclude(Values, 1);
    esDetected: Include(Values, 1);
  else
    Exclude(Values, 1);
    Exclude(Values, 2);
  end;
  BitSet := Values;
end;

function TExifFlashInfo.GetStrobeEnergy: TExifFraction;
begin
  Result := FOwner[esDetails].GetFractionValue(ttFlashEnergy, 0);
end;

procedure TExifFlashInfo.SetStrobeEnergy(const Value: TExifFraction);
begin
  FOwner[esDetails].SetFractionValue(ttFlashEnergy, 0, Value);
  FOwner.XMPPacket.UpdateProperty(xsExif, 'FlashEnergy', Value.AsString);
end;

{ TCustomExifVersion }

constructor TCustomExifVersion.Create(AOwner: TCustomExifData);
begin
  inherited Create;
  FOwner := AOwner;
  FMajorIndex := 1;
  FStoreAsChar := True;
  FTiffDataType := tdUndefined;
  Initialize;
end;

procedure TCustomExifVersion.Assign(Source: TPersistent);
begin
  if Source = nil then
    Owner[FSectionKind].Remove(FTagID)
  else if not (Source is TCustomExifVersion) then
    inherited
  else if TCustomExifVersion(Source).MissingOrInvalid then
    Owner[FSectionKind].Remove(FTagID)
  else
  begin
    Major := TCustomExifVersion(Source).Major;
    Minor := TCustomExifVersion(Source).Minor;
  end;
end;

function TCustomExifVersion.MissingOrInvalid: Boolean;
begin
  Result := (Major = 0);
end;

function TCustomExifVersion.GetAsString: string;
begin
  if MissingOrInvalid then
    Result := ''
  else
    FmtStr(Result, '%d%s%d%d', [Major, DecimalSeparator, Minor, Release]);
end;

procedure TCustomExifVersion.SetAsString(const Value: string);
var
  SeekPtr: PChar;

  function GetElement: TExifVersionElement;
  begin
    if SeekPtr^ = #0 then
      Result := 0
    else
    begin
      {$RANGECHECKS ON}
      Result := Ord(SeekPtr^) - Ord('0');
      {$IFDEF RangeCheckingOff}{$RANGECHECKS OFF}{$ENDIF}
      Inc(SeekPtr);
    end;
  end;
begin
  SeekPtr := Pointer(Value); //we *could* cast to a PChar and so be able to remove the
  if SeekPtr = nil then      //next five lines, but doing it this way gets the source
  begin                      //tag removed if the string is empty
    Assign(nil);
    Exit;
  end;
  Major := GetElement;
  if SeekPtr^ <> #0 then
  begin
    Inc(SeekPtr); //skip past separator, whatever that may precisely be
    Minor := GetElement;
    Release := GetElement;
  end
  else
  begin
    Minor := 0;
    Release := 0;
  end;
end;

{$IFDEF HasToString}
function TCustomExifVersion.ToString: string;
begin
  Result := AsString;
end;
{$ENDIF}

function TCustomExifVersion.GetValue(Index: Integer): TExifVersionElement;
var
  RawValue: Byte;
begin
  if not Owner[FSectionKind].TryGetByteValue(FTagID, Index, RawValue) then
    Result := 0
  else if RawValue >= Ord('0') then
    Result := RawValue - Ord('0')
  else
    Result := RawValue;
end;

procedure TCustomExifVersion.SetValue(Index: Integer; Value: TExifVersionElement);
var
  RawValue: Byte;
begin
  RawValue := Value;
  if FStoreAsChar then Inc(RawValue, Ord('0'));
  Owner[FSectionKind].ForceSetElement(FTagID, FTiffDataType, Index, RawValue);
end;

function TCustomExifVersion.GetMajor: TExifVersionElement;
begin
  Result := GetValue(FMajorIndex);
end;

function TCustomExifVersion.GetMinor: TExifVersionElement;
begin
  Result := GetValue(FMajorIndex + 1);
end;

function TCustomExifVersion.GetRelease: TExifVersionElement;
begin
  Result := GetValue(FMajorIndex + 2);
end;

procedure TCustomExifVersion.SetMajor(Value: TExifVersionElement);
begin
  SetValue(FMajorIndex, Value);
end;

procedure TCustomExifVersion.SetMinor(Value: TExifVersionElement);
begin
  SetValue(FMajorIndex + 1, Value);
end;

procedure TCustomExifVersion.SetRelease(Value: TExifVersionElement);
begin
  SetValue(FMajorIndex + 2, Value);
end;

{ TExifVersion }

procedure TExifVersion.Initialize;
begin
  FSectionKind := esDetails;
  FTagID := ttExifVersion;
end;

{ TFlashPixVersion }

procedure TFlashPixVersion.Initialize;
begin
  FSectionKind := esDetails;
  FTagID := ttFlashPixVersion;
end;

{ TGPSVersion }

procedure TGPSVersion.Initialize;
begin
  FMajorIndex := 0;
  FSectionKind := esGPS;
  FStoreAsChar := False;
  FTagID := ttGPSVersionID;
  FTiffDataType := tdByte;
end;

{ TInteropVersion }

procedure TInteropVersion.Initialize;
begin
  FSectionKind := esInterop;
  FTagID := ttInteropVersion;
end;

{ TCustomExifResolution }

constructor TCustomExifResolution.Create(AOwner: TCustomExifData);
var
  SectionKind: TExifSectionKind;
begin
  inherited Create;
  FOwner := AOwner;
  FXTagID := ttXResolution;
  FYTagID := ttYResolution;
  FUnitTagID := ttResolutionUnit;
  GetTagInfo(SectionKind, FXTagID, FYTagID, FUnitTagID, FSchema, FXName, FYName, FUnitName);
  FSection := AOwner[SectionKind];
end;

procedure TCustomExifResolution.Assign(Source: TPersistent);
begin
  if not (Source is TCustomExifResolution) and (Source <> nil) then
  begin
    inherited;
    Exit;
  end;
  FOwner.BeginUpdate;
  try
    if (Source = nil) or TCustomExifResolution(Source).MissingOrInvalid then
    begin
      Section.Remove(FXTagID);
      Section.Remove(FYTagID);
      Section.Remove(FUnitTagID);
      if FSchema <> xsUnknown then 
        FOwner.XMPPacket.RemoveProperties(FSchema, [FXName, FYName, FUnitName]);
    end
    else
    begin
      X := TCustomExifResolution(Source).X;
      Y := TCustomExifResolution(Source).Y;
      Units := TCustomExifResolution(Source).Units;
    end;
  finally
    FOwner.EndUpdate;
  end;
end;

function TCustomExifResolution.GetUnit: TExifResolutionUnit;
begin
  if not Section.TryGetWordValue(FUnitTagID, 0, Result) then
    Result := trNone;
end;

function TCustomExifResolution.GetX: TExifFraction;
begin
  Result := Section.GetFractionValue(FXTagID, 0);
end;

function TCustomExifResolution.GetY: TExifFraction;
begin
  Result := Section.GetFractionValue(FYTagID, 0);
end;

function TCustomExifResolution.MissingOrInvalid: Boolean;
begin
  Result := not Section.TagExists(FXTagID, [tdLongWordFraction, tdLongWordFraction]) or
    not Section.TagExists(FYTagID, [tdLongWordFraction, tdLongWordFraction]);
end;

procedure TCustomExifResolution.SetUnit(const Value: TExifResolutionUnit);
begin
  Section.SetWordValue(FUnitTagID, 0, Ord(Value));
  if FSchema <> xsUnknown then
    if Value = trNone then
      FOwner.XMPPacket.RemoveProperty(FSchema, FUnitName)
    else
      FOwner.XMPPacket.UpdateProperty(FSchema, FUnitName, Integer(Value));
end;

procedure TCustomExifResolution.SetX(const Value: TExifFraction);
begin
  Section.SetFractionValue(FXTagID, 0, Value);
  if FSchema <> xsUnknown then
    FOwner.XMPPacket.UpdateProperty(FSchema, FXName, Value.AsString);
end;

procedure TCustomExifResolution.SetY(const Value: TExifFraction);
begin
  Section.SetFractionValue(FYTagID, 0, Value);
  if FSchema <> xsUnknown then
    FOwner.XMPPacket.UpdateProperty(FSchema, FYName, Value.AsString);
end;

{$IFDEF HasToString}
function TCustomExifResolution.ToString: string;
begin
  if MissingOrInvalid then Exit('');
  case Units of
    trInch: Result := '"';
    trCentimetre: Result := 'cm';
  end;
  FmtStr(Result, '%g%s x %g%1:s', [X.Quotient, Result, Y.Quotient]);
end;
{$ENDIF}

{ TImageResolution }

procedure TImageResolution.GetTagInfo(var Section: TExifSectionKind; var XTag, YTag,
  UnitTag: TExifTagID; var Schema: TXMPNamespace; var XName, YName, UnitName: UnicodeString);
begin
  Section := esGeneral;
  Schema := xsTIFF;
  XName := 'XResolution';
  YName := 'YResolution';
  UnitName := 'ResolutionUnit';
end;

{ TFocalPlaneResolution }

procedure TFocalPlaneResolution.GetTagInfo(var Section: TExifSectionKind;
  var XTag, YTag, UnitTag: TExifTagID; var Schema: TXMPNamespace;
  var XName, YName, UnitName: UnicodeString);
begin
  Section := esDetails;
  XTag := ttFocalPlaneXResolution;
  YTag := ttFocalPlaneYResolution;
  UnitTag := ttFocalPlaneResolutionUnit;
  Schema := xsExif;
  XName := 'FocalPlaneXResolution';
  YName := 'FocalPlaneYResolution';
  UnitName := 'FocalPlaneResolutionUnit';
end;

{ TThumbnailResolution }

procedure TThumbnailResolution.GetTagInfo(var Section: TExifSectionKind;
  var XTag, YTag, UnitTag: TExifTagID; var Schema: TXMPNamespace;
  var XName, YName, UnitName: UnicodeString);
begin
  Section := esThumbnail;
end;

{ TISOSpeedRatings }

constructor TISOSpeedRatings.Create(AOwner: TCustomExifData);
begin
  FOwner := AOwner;
end;

procedure TISOSpeedRatings.Assign(Source: TPersistent);
var
  SourceTag, DestTag: TExifTag;
begin
  if Source = nil then
    Clear
  else if Source is TISOSpeedRatings then
  begin
    if not TISOSpeedRatings(Source).FindTag(True, SourceTag) then
      Clear
    else
    begin
      if FindTag(False, DestTag) then
        DestTag.UpdateData(tdWord, SourceTag.ElementCount, PWord(SourceTag.Data)^)
      else
      begin
        DestTag := FOwner[esDetails].Add(ttISOSpeedRatings, tdWord, SourceTag.ElementCount);
        Move(PWord(SourceTag.Data)^, DestTag.Data^, SourceTag.DataSize);
      end;
      FOwner.XMPPacket.UpdateProperty(XMPSchema, XMPName, XMPKind, DestTag.AsString);
    end;
  end
  else
    inherited;
end;

procedure TISOSpeedRatings.Clear;
begin
  FOwner[esDetails].Remove(ttISOSpeedRatings);
  FOwner.XMPPacket.RemoveProperty(XMPSchema, XMPName);
end;

function TISOSpeedRatings.FindTag(VerifyDataType: Boolean; out Tag: TExifTag): Boolean;
begin
  Result := FOwner[esDetails].Find(ttISOSpeedRatings, Tag);
  if Result and VerifyDataType and not (Tag.DataType in [tdWord, tdShortInt]) then
  begin
    Tag := nil;
    Result := False;
  end;
end;

function TISOSpeedRatings.GetAsString: string;
var
  Tag: TExifTag;
begin
  if FindTag(True, Tag) then
    Result := Tag.AsString
  else
    Result := '';
end;

function TISOSpeedRatings.GetCount: Integer;
var
  Tag: TExifTag;
begin
  if FindTag(True, Tag) then
    Result := Tag.ElementCount
  else
    Result := 0;
end;

function TISOSpeedRatings.GetItem(Index: Integer): Word;
var
  Tag: TExifTag;
begin
  if FindTag(True, Tag) and (Index < Tag.ElementCount) and (Index >= 0) then
    Result := PWordArray(Tag.Data)[Index]
  else
    Result := 0;
end;

function TISOSpeedRatings.MissingOrInvalid: Boolean;
var
  Tag: TExifTag;
begin
  Result := not FindTag(True, Tag);
end;

procedure TISOSpeedRatings.SetAsString(const Value: string);
var
  Tag: TExifTag;
begin
  if Value = '' then
  begin
    Assign(nil);
    Exit;
  end;
  if not FindTag(False, Tag) then
    Tag := FOwner[esDetails].Add(ttISOSpeedRatings, tdWord, 0);
  Tag.AsString := Value;
  FOwner.XMPPacket.UpdateProperty(XMPSchema, XMPName, XMPKind, Value);
end;

{$IFDEF HasToString}
function TISOSpeedRatings.ToString: string;
begin
  Result := AsString;
end;
{$ENDIF}

procedure TISOSpeedRatings.SetCount(const Value: Integer);
var
  Tag: TExifTag;
begin
  if Value <= 0 then
    Clear
  else if FindTag(False, Tag) then
    Tag.ElementCount := Value
  else
    FOwner[esDetails].Add(ttISOSpeedRatings, tdWord, Value);
end;

procedure TISOSpeedRatings.SetItem(Index: Integer; const Value: Word);
  procedure WriteXMP;
  begin
    with FOwner.XMPPacket[XMPSchema][XMPName] do
    begin
      Kind := XMPKind;
      Count := Max(Count, Succ(Index));
      SubProperties[Index].WriteValue(Value);
    end;
  end;
var
  Tag: TExifTag;
  Schema: TXMPSchema;
  Prop: TXMPProperty;
begin
  if not FindTag(True, Tag) or (Index >= Tag.ElementCount) then
    raise EListError.CreateFmt(SListIndexError, [Index]);
  FOwner[esDetails].ForceSetElement(ttISOSpeedRatings, tdWord, Index, Value);
  case FOwner.XMPWritePolicy of
    xwRemove: FOwner.XMPPacket.RemoveProperty(XMPSchema, XMPName);
    xwAlwaysUpdate: if FOwner.XMPPacket.FindSchema(XMPSchema, Schema) and
      Schema.FindProperty(XMPName, Prop) then WriteXMP;
  else WriteXMP;
  end
end;

{ TGPSCoordinate }

constructor TGPSCoordinate.Create(AOwner: TCustomExifData; ATagID: TExifTagID);
begin
  FOwner := AOwner;
  FRefTagID := Pred(ATagID);
  FTagID := ATagID;
  FXMPName := GetGPSTagXMPName(ATagID)
end;

procedure TGPSCoordinate.Assign(Source: TPersistent);
var
  SourceAsCoord: TGPSCoordinate absolute Source;
  SourceTag, DestTag: TExifTag;
begin
  if (Source <> nil) and not (Source is ClassType) then
  begin
    inherited;
    Exit;
  end;
  if (Source = nil) or not SourceAsCoord.Owner[esGPS].Find(FTagID, SourceTag) then
  begin
    FOwner[esGPS].Remove([FTagID, Pred(FTagID)]);
    FOwner.XMPPacket.RemoveProperty(xsExif, XMPName);
    Exit;
  end;
  FOwner.BeginUpdate;
  try
    if not FOwner[esGPS].Find(FTagID, DestTag) then
      DestTag := FOwner[esGPS].Add(FTagID, SourceTag.DataType, SourceTag.ElementCount);
    DestTag.Assign(SourceTag);
    Direction := SourceAsCoord.Direction;
  finally
    FOwner.EndUpdate;
  end;
end;

procedure TGPSCoordinate.Assign(const ADegrees, AMinutes, ASeconds: TExifFraction;
  ADirectionChar: AnsiChar);
var
  NewElemCount: Integer;
  Tag: TExifTag;
begin
  if ASeconds.MissingOrInvalid then NewElemCount := 2 else NewElemCount := 3;
  if FOwner[esGPS].Find(FTagID, Tag) then
    Tag.UpdateData(tdLongWordFraction, NewElemCount, PByte(nil)^)
  else
    Tag := FOwner[esGPS].Add(FTagID, tdLongWordFraction, NewElemCount);
  PExifFractionArray(Tag.Data)[0] := ADegrees;
  PExifFractionArray(Tag.Data)[1] := AMinutes;
  if NewElemCount > 2 then PExifFractionArray(Tag.Data)[2] := ASeconds;
  Tag.Changed;
  Direction := ADirectionChar;
end;

function TGPSCoordinate.MissingOrInvalid: Boolean;
var
  Mins, Degs: TExifFraction; //needed for D2006 compatibility - the D2006 compiler is buggy as hell with record methods
begin
  Mins := Minutes; Degs := Degrees;
  Result := Mins.MissingOrInvalid or Degs.MissingOrInvalid or (Direction = #0);
end;

function TGPSCoordinate.GetAsString: string;
var
  Direction: string;
  Degrees, Minutes, Seconds: TExifFraction;
begin
  Degrees := Self.Degrees;
  Minutes := Self.Minutes;
  Seconds := Self.Seconds;
  if Degrees.MissingOrInvalid or Minutes.MissingOrInvalid then
  begin
    Result := '';
    Exit;
  end;
  Direction := FOwner[esGPS].GetStringValue(RefTagID);
  if Seconds.MissingOrInvalid then
    FmtStr(Result, '%s,%g%s', [Degrees.AsString, Minutes.Quotient, Direction])
  else //if we do *exactly* what the XMP spec says, the value won't be round-trippable...
    FmtStr(Result, '%s,%s,%s%s', [Degrees.AsString, Minutes.AsString, Seconds.AsString, Direction]);
end;

{$IFDEF HasToString}
function TGPSCoordinate.ToString: string;
begin
  Result := AsString;
end;
{$ENDIF}

function TGPSCoordinate.GetDirectionChar: AnsiChar;
var
  Tag: TExifTag;
begin
  if FOwner[esGPS].Find(RefTagID, Tag) and (Tag.DataType = tdAscii) and (Tag.ElementCount >= 2) then
    Result := UpCase(PAnsiChar(Tag.Data)^)
  else
    Result := #0;
end;

procedure TGPSCoordinate.SetDirectionChar(NewChar: AnsiChar);
var
  ValueAsString, XMPValue: string;
  I: Integer;
begin
  if NewChar = #0 then 
  begin
    FOwner[esGPS].Remove(RefTagID);
    FOwner.XMPPacket.RemoveProperty(xsExif, XMPName);
    Exit;
  end;
  ValueAsString := string(UpCase(NewChar));
  XMPValue := AsString;
  FOwner[esGPS].SetStringValue(RefTagID, ValueAsString);
  for I := Length(XMPValue) downto 1 do
    if not CharInSet(XMPValue[I], ['A'..'Z', 'a'..'z']) then
    begin
      XMPValue := Copy(XMPValue, 1, I) + ValueAsString;
      FOwner.XMPPacket.UpdateProperty(xsExif, XMPName, XMPValue);
      Break;
    end; 
end;

function TGPSCoordinate.GetValue(Index: Integer): TExifFraction;
begin
  Result := FOwner[esGPS].GetFractionValue(TagID, Index);
end;

{ TGPSLatitude }

procedure TGPSLatitude.Assign(const ADegrees, AMinutes, ASeconds: TExifFraction;
  ADirection: TGPSLatitudeRef);
const
  DirectionChars: array[TGPSLatitudeRef] of AnsiChar = (#0, 'N', 'S');
begin
  Assign(ADegrees, AMinutes, ASeconds, DirectionChars[ADirection]);
end;

procedure TGPSLatitude.Assign(ADegrees, AMinutes: LongWord;
  const ASeconds: TExifFraction; ADirection: TGPSLatitudeRef);
begin
  Assign(TExifFraction.Create(ADegrees), TExifFraction.Create(AMinutes),
    ASeconds, ADirection);
end;

procedure TGPSLatitude.Assign(ADegrees, AMinutes: LongWord; const ASeconds: Currency;
  ADirection: TGPSLatitudeRef);
begin
  Assign(TExifFraction.Create(ADegrees), TExifFraction.Create(AMinutes),
    TExifFraction.Create(ASeconds), ADirection);
end;

procedure TGPSLatitude.Assign(ADegrees, AMinutes, ASeconds: LongWord;
  ADirection: TGPSLatitudeRef);
begin
  Assign(TExifFraction.Create(ADegrees), TExifFraction.Create(AMinutes),
    TExifFraction.Create(ASeconds), ADirection);
end;

function TGPSLatitude.GetDirection: TGPSLatitudeRef;
begin
  case inherited Direction of
    'N': Result := ltNorth;
    'S': Result := ltSouth;
  else Result := ltMissingOrInvalid;
  end;
end;

{ TGPSLongitude }

procedure TGPSLongitude.Assign(const ADegrees, AMinutes, ASeconds: TExifFraction;
  ADirection: TGPSLongitudeRef);
const
  DirectionChars: array[TGPSLongitudeRef] of AnsiChar = (#0, 'W', 'E');
begin
  Assign(ADegrees, AMinutes, ASeconds, DirectionChars[ADirection]);
end;

procedure TGPSLongitude.Assign(ADegrees, AMinutes: LongWord;
  const ASeconds: TExifFraction; ADirection: TGPSLongitudeRef);
begin
  Assign(TExifFraction.Create(ADegrees), TExifFraction.Create(AMinutes),
    ASeconds, ADirection);
end;

procedure TGPSLongitude.Assign(ADegrees, AMinutes: LongWord; const ASeconds: Currency;
  ADirection: TGPSLongitudeRef);
begin
  Assign(TExifFraction.Create(ADegrees), TExifFraction.Create(AMinutes),
    TExifFraction.Create(ASeconds), ADirection);
end;

procedure TGPSLongitude.Assign(ADegrees, AMinutes, ASeconds: LongWord;
  ADirection: TGPSLongitudeRef);
begin
  Assign(TExifFraction.Create(ADegrees), TExifFraction.Create(AMinutes),
    TExifFraction.Create(ASeconds), ADirection);
end;

function TGPSLongitude.GetDirection: TGPSLongitudeRef;
begin
  case inherited Direction of
    'W': Result := lnWest;
    'E': Result := lnEast;
  else Result := lnMissingOrInvalid;
  end;
end;

{ TCustomExifData.TEnumerator }

constructor TCustomExifData.TEnumerator.Create(AClient: TCustomExifData);
begin
  FClient := AClient;
  FDoneFirst := False;
  FSection := Low(TExifSectionKind);
end;

function TCustomExifData.TEnumerator.GetCurrent: TExifSection;
begin
  Result := FClient[FSection];
end;

function TCustomExifData.TEnumerator.MoveNext: Boolean;
begin
  Result := False;
  if not FDoneFirst then
    FDoneFirst := True
  else
  begin
    if FSection = High(TExifSectionKind) then Exit;
    Inc(FSection);
  end;
  Result := True;
end;

{ TCustomExifData }

type
  TContainedXMPPacket = class(TXMPPacket);

constructor TCustomExifData.Create(AOwner: TComponent = nil);
var
  Kind: TExifSectionKind;
begin
  inherited;
  FEmbeddedIPTC := TIPTCData.CreateAsSubComponent(Self);
  FEnforceASCII := True;
  FEnsureEnumsInRange := True;
  FExifVersion := TExifVersion.Create(Self);
  FFlashPixVersion := TFlashPixVersion.Create(Self);
  FGPSVersion := TGPSVersion.Create(Self);
  FGPSLatitude := TGPSLatitude.Create(Self, ttGPSLatitude);
  FGPSLongitude := TGPSLongitude.Create(Self, ttGPSLongitude);
  FGPSDestLatitude := TGPSLatitude.Create(Self, ttGPSDestLatitude);
  FGPSDestLongitude := TGPSLongitude.Create(Self, ttGPSDestLongitude);
  for Kind := Low(TExifSectionKind) to High(TExifSectionKind) do
    FSections[Kind] := SectionClass.Create(Self, Kind);
  FFlash := TExifFlashInfo.Create(Self);
  FFocalPlaneResolution := TFocalPlaneResolution.Create(Self);
  FInteropVersion := TInteropVersion.Create(Self);
  FISOSpeedRatings := TISOSpeedRatings.Create(Self);
  FResolution := TImageResolution.Create(Self);
  FThumbnailResolution := TThumbnailResolution.Create(Self);
  FXMPPacket := TContainedXMPPacket.CreateAsSubComponent(Self);
  ResetMakerNoteType;
  SetXMPWritePolicy(xwUpdateIfExists);
  FIgnoreXMP := true;
end;

destructor TCustomExifData.Destroy;
var
  Section: TExifSectionKind;
begin
  FUpdateCount := 1000;
  FreeAndNil(FMakerNoteValue);
  FThumbnailResolution.Free;
  FResolution.Free;
  FISOSpeedRatings.Free;
  FInteropVersion.Free;
  FGPSDestLongitude.Free;
  FGPSDestLatitude.Free;
  FGPSLongitude.Free;
  FGPSLatitude.Free;
  FGPSVersion.Free;
  FFocalPlaneResolution.Free;
  FFlash.Free;
  FFlashPixVersion.Free;
  FExifVersion.Free;
  for Section := Low(TExifSectionKind) to High(TExifSectionKind) do
    FSections[Section].Free;
  inherited;
  FThumbnailOrNil.Free;
end;

class function TCustomExifData.SectionClass: TExifSectionClass;
begin
  Result := TExifSection;
end;

class procedure TCustomExifData.RegisterMakerNoteType(AClass: TExifMakerNoteClass;
  Priority: TMakerNoteTypePriority);
begin
  if AClass = nil then Exit;
  FMakerNoteClasses.Remove(AClass);
  case Priority of
    mtTestForLast: FMakerNoteClasses.Insert(0, AClass);
    mtTestForFirst: FMakerNoteClasses.Add(AClass);
  end;
end;

class procedure TCustomExifData.RegisterMakerNoteTypes(
  const AClasses: array of TExifMakerNoteClass; Priority: TMakerNoteTypePriority);
var
  LClass: TExifMakerNoteClass;
begin
  for LClass in AClasses do
    RegisterMakerNoteType(LClass, Priority);
end;

class procedure TCustomExifData.UnregisterMakerNoteType(AClass: TExifMakerNoteClass);
begin
  FMakerNoteClasses.Remove(AClass)
end;

procedure TCustomExifData.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TCustomExifData.EndUpdate;
begin
  Dec(FUpdateCount);
  if (FUpdateCount = 0) and FChangedWhileUpdating then
  begin
    FChangedWhileUpdating := False;
    Changed(nil);
  end;
end;

function TCustomExifData.Updating: Boolean;
begin
  Result := (FUpdateCount > 0);
end;

procedure TCustomExifData.Changed(Section: TExifSection);
begin
  if FUpdateCount > 0 then
    FChangedWhileUpdating := True
  else
  begin
    FModified := True;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TCustomExifData.Clear(XMPPacketToo: Boolean = True);
var
  Section: TExifSection;
begin
  BeginUpdate;
  try
    FreeAndNil(FThumbnailOrNil);
    ResetMakerNoteType;
    for Section in FSections do
      Section.Clear;
    if XMPPacketToo then
      FXMPPacket.Clear;
  finally
    EndUpdate;
  end;
end;

function TCustomExifData.GetEmpty: Boolean;
var
  Section: TExifSection;
begin
  Result := False;
  for Section in FSections do
    if Section.Count > 0 then Exit;
  if HasThumbnail then Exit;
  Result := True;
end;

function TCustomExifData.GetEnumerator: TEnumerator;
begin
  Result := TEnumerator.Create(Self);
end;

procedure TCustomExifData.GetKeywords(Dest: TStrings);
var
  I, StartPos: Integer;
  S: UnicodeString;
begin
  Dest.BeginUpdate;
  try
    Dest.Clear;
    S := Keywords;
    StartPos := 1;
    for I := 1 to Length(S) do
      if S[I] = ';' then
      begin
        Dest.Add(Copy(S, StartPos, I - StartPos));
        StartPos := I + 1;
      end;
    Dest.Add(Copy(S, StartPos, MaxInt));
  finally
    Dest.EndUpdate;
  end;
end;

procedure TCustomExifData.SetKeywords(const NewWords: array of UnicodeString);
var
  I: Integer;
  MemStream: TMemoryStream;
  S: UnicodeString;
begin
  MemStream := TMemoryStream.Create;
  try
    for I := 0 to High(NewWords) do
    begin
      S := NewWords[I];
      MemStream.WriteBuffer(PWideChar(S)^, Length(S));
      if I < High(NewWords) then MemStream.WriteByte(';');
    end;
    SetString(S, PWideChar(MemStream.Memory), MemStream.Size);
    Keywords := S;
  finally
    MemStream.Free;
  end;
end;

procedure TCustomExifData.SetKeywords(NewWords: TStrings);
var
  DynArray: array of UnicodeString;
  I: Integer;
begin
  SetLength(DynArray, NewWords.Count);
  for I := 0 to High(DynArray) do
    DynArray[I] := NewWords[I];
  SetKeywords(DynArray);
end;

function TCustomExifData.GetMakerNote: TExifMakerNote;
begin
  if FMakerNoteValue = nil then
  begin
    BeginUpdate;
    try
      FMakerNoteValue := FMakerNoteType.Create(FSections[esMakerNote]);
      if (FMakerNoteType = THeaderlessMakerNote) and (FMakerNoteValue.Tags.Count = 0) then
      begin
        FMakerNoteType := TUnrecognizedMakerNote;
        FreeAndNil(FMakerNoteValue);
        FMakerNoteValue := TUnrecognizedMakerNote.Create(FSections[esMakerNote]);
      end;
    finally
      EndUpdate;
    end;
  end;
  Result := FMakerNoteValue;
end;

function TCustomExifData.GetSection(Section: TExifSectionKind): TExifSection;
begin
  Result := FSections[Section];
  if (Section = esMakerNote) and (FMakerNoteType <> TUnrecognizedMakerNote) then
    GetMakerNote; //MakerNote tags are lazy-loaded
end;

function TCustomExifData.GetThumbnail: TJPEGImage;
begin
  if FThumbnailOrNil = nil then
  begin
    FThumbnailOrNil := TJPEGImage.Create;
    FThumbnailOrNil.OnChange := ThumbnailChanged;
  end;
  Result := FThumbnailOrNil;
end;

function TCustomExifData.HasMakerNote: Boolean;
begin
  Result := FSections[esDetails].TagExists(ttMakerNote, [tdUndefined], 5)
end;

function TCustomExifData.HasThumbnail: Boolean;
begin
  Result := not IsGraphicEmpty(FThumbnailOrNil);
end;

function TCustomExifData.LoadFromGraphic(Stream: TStream): Boolean;
var
  Segment: IFoundJPEGSegment;
  PSDInfo: TPSDInfo;
  ResBlock: IAdobeResBlock;
begin
  FMetadataInSource := [];
  FXMPSegmentPosition := 0;
  FXMPPacketSizeInSource := 0;
  Result := False;
  BeginUpdate;
  try
    Clear;
    if HasJPEGHeader(Stream) then
    begin
      Result := True;
      for Segment in JPEGHeader(Stream, [jmApp1]) do
        if not (mkExif in MetadataInSource) and Segment.IsExifBlock then
        begin
          Include(FMetadataInSource, mkExif);
          AddFromStream(Segment.Data);
          Inc(FOffsetBase, Segment.OffsetOfData);
        end
        else if not (mkXMP in MetadataInSource) and Segment.IsXMPBlock
        and not IgnoreXMP then
        begin
          Include(FMetadataInSource, mkXMP);
          FXMPSegmentPosition := Segment.Offset;
          FXMPPacketSizeInSource := Segment.Data.Size;
          XMPPacket.DataToLazyLoad := Segment;
        end;
    end
    else if HasPSDHeader(Stream) then
    begin
      Result := True;
      for ResBlock in ParsePSDHeader(Stream, PSDInfo) do
        if not (mkExif in MetadataInSource) and ResBlock.IsExifBlock then
        begin
          Include(FMetadataInSource, mkExif);
          AddFromStream(ResBlock.Data);
        end
        else if not (mkXMP in MetadataInSource) and ResBlock.IsXMPBlock
        and not IgnoreXMP then
        begin
          Include(FMetadataInSource, mkXMP);
          FXMPPacketSizeInSource := ResBlock.Data.Size;
          XMPPacket.DataToLazyLoad := ResBlock;
        end;
    end
    else if HasTiffHeader(Stream) then
    begin
      Result := True;
      AddFromStream(Stream, True);
      if not Empty then Include(FMetadataInSource, mkExif);
      if not XMPPacket.Empty then Include(FMetadataInSource, mkXMP);
    end;
  finally
    FChangedWhileUpdating := False;
    EndUpdate;
    Modified := False;
  end;
end;

procedure TCustomExifData.AddFromStream(Stream: TStream; TiffImageSource: Boolean);
var
  Parser: ITiffParser;

  procedure LoadSubDir(Source: TExifSectionKind; OffsetID: TExifTagID; Dest: TExifSectionKind);
  var
    SubDir: IFoundTiffDirectory;
    Tag: TExifTag;
  begin
    if FSections[Source].Find(OffsetID, Tag) and Parser.ParseSubDirectory(Tag, SubDir) then
      FSections[Dest].Load(SubDir, TiffImageSource);
  end;
var
  Directory: IFoundTiffDirectory;
  ExifTag: TExifTag;
  I: Integer;
  TiffTag: ITiffTag;
begin
  if Stream.TryReadHeader(TJPEGSegment.ExifHeader, SizeOf(TJPEGSegment.ExifHeader)) then
    TiffImageSource := False;
  BeginUpdate;
  try
    Parser := ParseTiff(Stream);
    FOffsetBase := Parser.BasePosition;
    FEndianness := Parser.Endianness;
    for Directory in Parser do
      case Directory.Index of
        0:
        begin
          FSections[esGeneral].Load(Directory, TiffImageSource);
          if Directory.FindTag(ttIPTC, TiffTag) and TiffTag.IsIPTCBlock then
            EmbeddedIPTC.DataToLazyLoad := TiffTag;
          if (TiffImageSource or XMPPacket.Empty) and Directory.FindTag(ttXMP,
              TiffTag) and TiffTag.IsXMPBlock then
            XMPPacket.DataToLazyLoad := TiffTag;
        end;
        1:
        begin
          if not TiffImageSource or Directory.IsExifThumbailDirectory then
          begin
            FSections[esThumbnail].Load(Directory, TiffImageSource);
            GetThumbnail.OnChange := nil;
            if Directory.TryLoadExifThumbnail(FThumbnailOrNil) then
              FThumbnailOrNil.OnChange := ThumbnailChanged
            else
              SetThumbnail(nil);
          end;
          Break;
        end;
      end;
    LoadSubDir(esGeneral, ttExifOffset, esDetails);
    LoadSubDir(esGeneral, ttGPSOffset, esGPS);
    LoadSubDir(esDetails, ttInteropOffset, esInterop);
    if FSections[esDetails].Find(ttMakerNote, ExifTag) then
    begin
      FMakerNoteType := THeaderlessMakerNote;
      for I := FMakerNoteClasses.Count - 1 downto 0 do
        if TExifMakerNoteClass(FMakerNoteClasses.List[I]).FormatIsOK(ExifTag) then
        begin
          FMakerNoteType := FMakerNoteClasses.List[I];
          Break;
        end;
    end;
  finally
    FChangedWhileUpdating := False;
    EndUpdate;
    Modified := False;
  end;
end;

procedure TCustomExifData.Rewrite;
begin
  BeginUpdate;
  try
    CameraMake := CameraMake;
    CameraModel := CameraModel;
    Copyright := Copyright;
    DateTime := DateTime;
    ImageDescription := ImageDescription;
    Orientation := Orientation;
    Resolution := Resolution;
    Software := Software;
    Author := Author;
    Comments := Comments;
    Keywords := Keywords;
    Subject := Subject;
    Title := Title;
    UserRating := UserRating;
    ApertureValue := ApertureValue;
    BrightnessValue := BrightnessValue;
    ColorSpace := ColorSpace;
    Contrast := Contrast;
    CompressedBitsPerPixel := CompressedBitsPerPixel;
    DateTimeOriginal := DateTimeOriginal;
    DateTimeDigitized := DateTimeDigitized;
    DigitalZoomRatio := DigitalZoomRatio;
    ExifVersion := ExifVersion;
    ExifImageWidth := ExifImageWidth;
    ExifImageHeight := ExifImageHeight;
    ExposureBiasValue := ExposureBiasValue;
    ExposureIndex := ExposureIndex;
    ExposureMode := ExposureMode;
    ExposureProgram := ExposureProgram;
    ExposureTime := ExposureTime;
    FileSource := FileSource;
    Flash := Flash;
    FlashPixVersion := FlashPixVersion;
    FNumber := FNumber;
    FocalLength := FocalLength;
    FocalLengthIn35mmFilm := FocalLengthIn35mmFilm;
    FocalPlaneResolution := FocalPlaneResolution;
    GainControl := GainControl;
    ImageUniqueID := ImageUniqueID;
    ISOSpeedRatings := ISOSpeedRatings;
    LightSource := LightSource;
    MaxApertureValue := MaxApertureValue;
    MeteringMode := MeteringMode;
    RelatedSoundFile := RelatedSoundFile;
    Rendering := Rendering;
    Saturation := Saturation;
    SceneCaptureType := SceneCaptureType;
    SceneType := SceneType;
    SensingMethod := SensingMethod;
    Sharpness := Sharpness;
    ShutterSpeedValue := ShutterSpeedValue;
    SpectralSensitivity := SpectralSensitivity;
    SubjectDistance := SubjectDistance;
    SubjectDistanceRange := SubjectDistanceRange;
    SubjectLocation := SubjectLocation;
    GPSVersion := GPSVersion;
    GPSLatitude := GPSLatitude;
    GPSLongitude := GPSLongitude;
    GPSAltitudeRef := GPSAltitudeRef;
    GPSAltitude := GPSAltitude;
    GPSSatellites := GPSSatellites;
    GPSStatus := GPSStatus;
    GPSMeasureMode := GPSMeasureMode;
    GPSDOP := GPSDOP;
    GPSSpeedRef := GPSSpeedRef;
    GPSSpeed := GPSSpeed;
    GPSTrackRef := GPSTrackRef;
    GPSTrack := GPSTrack;
    GPSImgDirectionRef := GPSImgDirectionRef;
    GPSImgDirection := GPSImgDirection;
    GPSMapDatum := GPSMapDatum;
    GPSDestLatitude := GPSDestLatitude;
    GPSDestLongitude := GPSDestLongitude;
    GPSDestBearingRef := GPSDestBearingRef;
    GPSDestBearing := GPSDestBearing;
    GPSDestDistanceRef := GPSDestDistanceRef;
    GPSDestDistance := GPSDestDistance;
    GPSDifferential := GPSDifferential;
    GPSDateTimeUTC := GPSDateTimeUTC;
    ThumbnailOrientation := ThumbnailOrientation;
    ThumbnailResolution := ThumbnailResolution;
  finally
    EndUpdate;
  end;
end;

procedure TCustomExifData.SetAllDateTimeValues(const NewValue: TDateTimeTagValue);
begin
  BeginUpdate;
  try
    DateTime := NewValue;
    DateTimeOriginal := NewValue;
    DateTimeDigitized := NewValue;
  finally
    EndUpdate;
  end;
end;

procedure TCustomExifData.SetEndianness(Value: TEndianness);
begin
  if Value = FEndianness then Exit;
  FEndianness := Value;
  Changed(nil);
end;

procedure TCustomExifData.ResetMakerNoteType;
begin
  FMakerNoteType := TUnrecognizedMakerNote;
  FreeAndNil(FMakerNoteValue);
end;

procedure TCustomExifData.SetModified(Value: Boolean);
begin
  if Value then
    Changed(nil)
  else
    FModified := Value;
end;

procedure TCustomExifData.SetThumbnail(Value: TJPEGImage);
begin
  if IsGraphicEmpty(Value) then
    FreeAndNil(FThumbnailOrNil)
  else
    GetThumbnail.Assign(Value);
end;

function TCustomExifData.ShutterSpeedInMSecs: Extended;
var
  Apex: TExifSignedFraction;
begin
  Apex := ShutterSpeedValue;
  if Apex.MissingOrInvalid then
    Result := 0
  else
    Result := (1 / Power(2, Apex.Quotient)) * 1000;
end;

procedure TCustomExifData.ThumbnailChanged(Sender: TObject);
var
  Tag: TExifTag;
begin
  Modified := True;
  if Sender = FThumbnailOrNil then
    with Sections[esThumbnail] do
      if Find(ttImageWidth, Tag) or Find(ttImageHeight, Tag) then
      begin
        SetWordValue(ttImageWidth, 0, FThumbnailOrNil.Width);
        SetWordValue(ttImageHeight, 0, FThumbnailOrNil.Height);
      end;
end;

function TCustomExifData.GetXMPWritePolicy: TXMPWritePolicy;
begin
  Result := TContainedXMPPacket(XMPPacket).UpdatePolicy;
end;

procedure TCustomExifData.SetXMPWritePolicy(Value: TXMPWritePolicy);
begin
  TContainedXMPPacket(XMPPacket).UpdatePolicy := Value;
end;

{ TCustomExifData - tag getters }

function TCustomExifData.GetAuthor: UnicodeString;
begin
  Result := GetGeneralWinString(ttWindowsAuthor);
  if Result = '' then
    Result := GetGeneralString(ttArtist);
end;

function TCustomExifData.GetColorSpace: TExifColorSpace;
begin
  if FSections[esDetails].TryGetWordValue(ttColorSpace, 0, Result) then
    if not EnsureEnumsInRange then
      Exit
    else
      case Result of
        csRGB, csAdobeRGB, csWideGamutRGB, csICCProfile, csUncalibrated: Exit;
      end;
  Result := csTagMissing;
end;

type
  TExifUserCommentID = array[1..8] of AnsiChar;

const
  UCID_ASCI: TExifUserCommentID = 'ASCII'#0#0#0;
  UCID_Kanji: TExifUserCommentID = 'JIS'#0#0#0#0#0;
  UCID_Unicode: TExifUserCommentID = 'UNICODE'#0;

function TCustomExifData.GetComments: UnicodeString;
const
  IDSize = SizeOf(TExifUserCommentID);
var
  Tag: TExifTag;
  StrStart: PAnsiChar;
  StrByteLen: Integer;
  TiffStr: TiffString;
begin
  Result := GetGeneralWinString(ttWindowsComments);
  if (Result = '') and FSections[esDetails].Find(ttUserComment, Tag) and
     (Tag.DataType in [tdByte, tdUndefined]) and (Tag.ElementCount > 9) then
  begin
    StrStart := @PAnsiChar(Tag.Data)[IDSize];
    StrByteLen := Tag.ElementCount - IDSize;
    while (StrByteLen > 0) and (StrStart[StrByteLen - 1] in [#0..' ']) do
      Dec(StrByteLen);
    if CompareMem(Tag.Data, @UCID_Unicode, IDSize) then
      SetString(Result, PWideChar(StrStart), StrByteLen div 2)
    else if CompareMem(Tag.Data, @UCID_ASCI, IDSize) then
    begin
      SetString(TiffStr, StrStart, StrByteLen);
      Result := UnicodeString(TiffStr);
    end;
  end;
end;

function TCustomExifData.GetContrast: TExifContrast;
begin
  if FSections[esDetails].TryGetWordValue(ttContrast, 0, Result) then
    if not EnsureEnumsInRange then
      Exit
    else
      case Ord(Result) of
        Ord(Low(TExifContrast))..Ord(High(TExifContrast)): Exit;
      end;
  Result := cnTagMissing;
end;

procedure TCustomExifData.SetContrast(Value: TExifContrast);
begin
  SetDetailsWordEnum(ttContrast, 'Contrast', Value);
end;

function TCustomExifData.GetDetailsDateTime(TagID: Integer): TDateTimeTagValue;
var
  SubSecsID: TExifTagID;
begin
  case TagID of
    ttDateTimeOriginal: SubSecsID := ttSubsecTimeOriginal;
    ttDateTimeDigitized: SubSecsID := ttSubsecTimeDigitized;
  else SubSecsID := 0;
  end;
  Result := FSections[esDetails].GetDateTimeValue(TagID, SubSecsID);
end;

function TCustomExifData.GetDetailsFraction(TagID: Integer): TExifFraction;
begin
  Result := FSections[esDetails].GetFractionValue(TagID, 0)
end;

function TCustomExifData.GetDetailsSFraction(TagID: Integer): TExifSignedFraction;
begin
  Result := TExifSignedFraction(FSections[esDetails].GetFractionValue(TagID, 0))
end;

function TCustomExifData.GetOffsetSchema: TLongIntTagValue;
begin
  Result := FSections[esDetails].GetLongIntValue(ttOffsetSchema, 0)
end;

function TCustomExifData.GetDetailsLongWord(TagID: Integer): TLongWordTagValue;
begin
  Result := FSections[esDetails].GetLongWordValue(TagID, 0);
end;

function TCustomExifData.GetDetailsString(TagID: Integer): string;
begin
  Result := FSections[esDetails].GetStringValue(TagID)
end;

function TCustomExifData.GetFocalLengthIn35mmFilm: TWordTagValue;
var
  CCDWidth, CCDHeight, ResUnit, FinalValue: Extended;
  ExifWidth, ExifHeight: Integer;
  FocalLengthFrac: TExifFraction;
begin
  Result := FSections[esDetails].GetWordValue(ttFocalLengthIn35mmFilm, 0);
  if not Result.MissingOrInvalid then Exit;
  FocalLengthFrac := FocalLength;
  if FocalLengthFrac.MissingOrInvalid then Exit;
  ExifWidth := ExifImageWidth;
  ExifHeight := ExifImageHeight;
  if (ExifWidth = 0) or (ExifHeight = 0) then Exit;
  case FocalPlaneResolution.Units of
    trInch: ResUnit := 25.4;
    trCentimetre: ResUnit := 10.0;
  else Exit;
  end;
  CCDWidth := FocalPlaneResolution.X.Quotient;
  CCDHeight := FocalPlaneResolution.Y.Quotient;
  if (CCDWidth = 0) or (CCDHeight = 0) then Exit;
  CCDWidth := ExifWidth * ResUnit / CCDWidth;
  CCDHeight := ExifHeight * ResUnit / CCDHeight;
  if Diag35mm = 0 then
    Diag35mm := Sqrt(Sqr(24) + Sqr(36));
  FinalValue := FocalLengthFrac.Quotient * Diag35mm / Sqrt(Sqr(CCDWidth) + Sqr(CCDHeight));
  if InRange(FinalValue, 0, High(Word)) then
    Result := Trunc(FinalValue);
end;

function TCustomExifData.GetExposureMode: TExifExposureMode;
begin
  if FSections[esDetails].TryGetWordValue(ttExposureMode, 0, Result) then
    if not EnsureEnumsInRange then
      Exit
    else
      case Ord(Result) of
        Ord(Low(TExifExposureMode))..Ord(High(TExifExposureMode)): Exit;
      end;
  Result := exTagMissing;
end;

function TCustomExifData.GetExposureProgram: TExifExposureProgram;
begin
  if FSections[esDetails].TryGetWordValue(ttExposureProgram, 0, Result) then
    if not EnsureEnumsInRange then
      Exit
    else
      case Ord(Result) of
        Ord(Low(TExifExposureProgram))..Ord(High(TExifExposureProgram)): Exit;
      end;
  Result := eeTagMissing;
end;

function TCustomExifData.GetFileSource: TExifFileSource;
begin
  if FSections[esDetails].TryGetByteValue(ttFileSource, 0, Result) then
    if not EnsureEnumsInRange then
      Exit
    else
      case Ord(Result) of
        Ord(Low(TExifFileSource))..Ord(High(TExifFileSource)): Exit;
      end;
  Result := fsUnknown;
end;

function TCustomExifData.GetGainControl: TExifGainControl;
begin
  if FSections[esDetails].TryGetWordValue(ttGainControl, 0, Result) then
    if not EnsureEnumsInRange then
      Exit
    else
      case Ord(Result) of
        Ord(Low(TExifGainControl))..Ord(High(TExifGainControl)): Exit;
      end;
  Result := egTagMissing;
end;

function TCustomExifData.GetDateTime: TDateTimeTagValue;
begin
  Result := FSections[esGeneral].GetDateTimeValue(ttDateTime, ttSubsecTime);
end;

function TCustomExifData.GetGeneralString(TagID: Integer): string;
begin
  Result := FSections[esGeneral].GetStringValue(TagID)
end;

function TCustomExifData.GetGeneralWinString(TagID: Integer): UnicodeString;
begin
  Result := FSections[esGeneral].GetWindowsStringValue(TagID)
end;

function TCustomExifData.GetGPSAltitudeRef: TGPSAltitudeRef;
begin
  if FSections[esGPS].TryGetByteValue(ttGPSAltitudeRef, 0, Result) then
    if not EnsureEnumsInRange then
      Exit
    else
      case Ord(Result) of
        Ord(Low(TGPSAltitudeRef))..Ord(High(TGPSAltitudeRef)): Exit;
      end;
  Result := alTagMissing;
end;

function TCustomExifData.GetGPSDateTimeUTC: TDateTimeTagValue;
var
  DatePart, TimePart: TDateTime;
  Hour, Minute, Second: TExifFraction;
  S: string;
  Year, Month, Day: Integer;
begin
  S := GPSDateStamp;
  if (Length(S) <> 10) or not TryStrToInt(Copy(S, 1, 4), Year) or
      not TryStrToInt(Copy(S, 6, 2), Month) or not TryStrToInt(Copy(S, 9, 2), Day) or
      not TryEncodeDate(Year, Month, Day, DatePart) then
    DatePart := 0;
  Hour := GPSTimeStampHour;
  Minute := GPSTimeStampMinute;
  Second := GPSTimeStampSecond;
  if Hour.MissingOrInvalid or Minute.MissingOrInvalid or Second.MissingOrInvalid or
    not TryEncodeTime(Trunc(Hour.Quotient), Trunc(Minute.Quotient),
      Trunc(Second.Quotient), 0, TimePart) then
  begin
    if DatePart = 0 then
      Result := TDateTimeTagValue.CreateMissingOrInvalid
    else
      Result := DatePart;
    Exit;
  end;
  if DatePart = 0 then
  begin
    DatePart := DateTime;
    if DatePart = 0 then DatePart := DateTimeOriginal;
    DatePart := DateOf(DatePart);
  end;
  if DatePart >= 0 then
    Result := DatePart + TimePart
  else
    Result := DatePart - TimePart
end;

function TCustomExifData.GetGPSFraction(TagID: Integer): TExifFraction;
begin
  Result := FSections[esGPS].GetFractionValue(TagID, 0);
end;

function TCustomExifData.GetGPSDestDistanceRef: TGPSDistanceRef;
var
  S: string;
begin
  Result := dsMissingOrInvalid;
  if FSections[esGPS].TryGetStringValue(ttGPSDestDistanceRef, S) and (S <> '') then
    case UpCase(S[1]) of
      'K': Result := dsKilometres;
      'M': Result := dsMiles;
      'N': Result := dsKnots;
    end;
end;

function TCustomExifData.GetGPSDifferential: TGPSDifferential;
begin
  if FSections[esGPS].TryGetWordValue(ttGPSDifferential, 0, Result) then
    if not EnsureEnumsInRange then
      Exit
    else
      case Ord(Result) of
        Ord(Low(TGPSDifferential))..Ord(High(TGPSDifferential)): Exit;
      end;
  Result := dfTagMissing;
end;

function TCustomExifData.GetGPSDirection(TagID: Integer): TGPSDirectionRef;
var
  S: string;
begin
  Result := drMissingOrInvalid;
  if FSections[esGPS].TryGetStringValue(TagID, S) and (S <> '') then
    case UpCase(S[1]) of
      'T': Result := drTrueNorth;
      'M': Result := drMagneticNorth;
    end;
end;

function TCustomExifData.GetGPSMeasureMode: TGPSMeasureMode;
var
  S: string;
begin
  Result := mmUnknown;
  if FSections[esGPS].TryGetStringValue(ttGPSMeasureMode, S) and (S <> '') then
    case UpCase(S[1]) of
      '2': Result := mm2D;
      '3': Result := mm3D;
    end;
end;

function TCustomExifData.GetGPSSpeedRef: TGPSSpeedRef;
var
  S: string;
begin
  Result := srMissingOrInvalid;
  if FSections[esGPS].TryGetStringValue(ttGPSSpeedRef, S) and (S <> '') then
    case UpCase(S[1]) of
      'K': Result := srKilometresPerHour;
      'M': Result := srMilesPerHour;
      'N': Result := srKnots;
    end;
end;

function TCustomExifData.GetGPSStatus: TGPSStatus;
var
  S: string;
begin
  Result := stMissingOrInvalid;
  if FSections[esGPS].TryGetStringValue(ttGPSStatus, S) and (S <> '') then
    case UpCase(S[1]) of
      'A': Result := stMeasurementActive;
      'V': Result := stMeasurementVoid;
    end;
end;

function TCustomExifData.GetGPSString(TagID: Integer): string;
begin
  Result := FSections[esGPS].GetStringValue(TagID)
end;

function TCustomExifData.GetGPSTimeStamp(const Index: Integer): TExifFraction;
begin
  Result := FSections[esGPS].GetFractionValue(ttGPSTimeStamp, Index)
end;

function TCustomExifData.GetInteropTypeName: string;
begin
  Result := FSections[esInterop].GetStringValue(ttInteropIndex);
end;

procedure TCustomExifData.SetInteropTypeName(const Value: string);
begin
  FSections[esInterop].SetStringValue(ttInteropIndex, Value);
end;

function TCustomExifData.GetLightSource: TExifLightSource;
begin
  if FSections[esDetails].TryGetWordValue(ttLightSource, 0, Result) then
    if not EnsureEnumsInRange then
      Exit
    else
      case Ord(Result) of
        Ord(Low(TExifLightSource))..Ord(High(TExifLightSource)): Exit;
      end;
  Result := elTagMissing;
end;

function TCustomExifData.GetMeteringMode: TExifMeteringMode;
begin
  if FSections[esDetails].TryGetWordValue(ttMeteringMode, 0, Result) then
    if not EnsureEnumsInRange then
      Exit
    else
      case Ord(Result) of
        Ord(Low(TExifMeteringMode))..Ord(High(TExifMeteringMode)): Exit;
      end;
  Result := emTagMissing;
end;

function TCustomExifData.GetOrientation(SectionKind: Integer): TExifOrientation;
var
  Section: TExifSectionKind absolute SectionKind;
begin
  if FSections[Section].TryGetWordValue(ttOrientation, 0, Result) then
    if not EnsureEnumsInRange then
      Exit
    else
      case Ord(Result) of
        Ord(Low(TExifOrientation))..Ord(High(TExifOrientation)): Exit;
      end;
  Result := toUndefined;
end;

function TCustomExifData.GetRendering: TExifRendering;
begin
  if FSections[esDetails].TryGetWordValue(ttCustomRendered, 0, Result) then
    if not EnsureEnumsInRange then
      Exit
    else
      case Ord(Result) of
        Ord(Low(TExifRendering))..Ord(High(TExifRendering)): Exit;
      end;
  Result := erTagMissing;
end;

function TCustomExifData.GetSaturation: TExifSaturation;
begin
  if FSections[esDetails].TryGetWordValue(ttSaturation, 0, Result) then
    if not EnsureEnumsInRange then
      Exit
    else
      case Ord(Result) of
        Ord(Low(TExifSaturation))..Ord(High(TExifSaturation)): Exit;
      end;
  Result := euTagMissing;
end;

function TCustomExifData.GetSceneCaptureType: TExifSceneCaptureType;
begin
  if FSections[esDetails].TryGetWordValue(ttSceneCaptureType, 0, Result) then
    if not EnsureEnumsInRange then
      Exit
    else
      case Ord(Result) of
        Ord(Low(TExifSceneCaptureType))..Ord(High(TExifSceneCaptureType)): Exit;
      end;
  Result := ecTagMissing;
end;

function TCustomExifData.GetSceneType: TExifSceneType;
begin
  if FSections[esDetails].TryGetByteValue(ttSceneType, 0, Result) then
    if not EnsureEnumsInRange then
      Exit
    else
      case Ord(Result) of
        Ord(Low(TExifSceneType))..Ord(High(TExifSceneType)): Exit;
      end;
  Result := esUnknown;
end;

function TCustomExifData.GetSensingMethod: TExifSensingMethod;
begin
  if FSections[esDetails].TryGetWordValue(ttSensingMethod, 0, Result) then
    if not EnsureEnumsInRange then
      Exit
    else
      case Ord(Result) of
        Ord(Low(TExifSensingMethod))..Ord(High(TExifSensingMethod)): Exit;
      end;
  Result := esTagMissing;
end;

function TCustomExifData.GetSharpness: TExifSharpness;
begin
  if FSections[esDetails].TryGetWordValue(ttSharpness, 0, Result) then
    if not EnsureEnumsInRange then
      Exit
    else
      case Ord(Result) of
        Ord(Low(TExifSharpness))..Ord(High(TExifSharpness)): Exit;
      end;
  Result := ehTagMissing;
end;

function TCustomExifData.GetSubjectDistanceRange: TExifSubjectDistanceRange;
begin
  if FSections[esDetails].TryGetWordValue(ttSubjectDistanceRange, 0, Result) then
    if not EnsureEnumsInRange then
      Exit
    else
      case Ord(Result) of
        Ord(Low(TExifSubjectDistanceRange))..Ord(High(TExifSubjectDistanceRange)): Exit;
      end;
  Result := edTagMissing;
end;

function TCustomExifData.GetSubjectLocation: TSmallPoint;
var
  Tag: TExifTag;
begin
  if FSections[esDetails].Find(ttSubjectLocation, Tag) and
    (Tag.DataType in [tdWord, tdSmallInt]) and (Tag.ElementCount >= 2) then
    Result := PSmallPoint(Tag.Data)^
  else
  begin
    Result.x := -1;
    Result.y := -1;
  end;
end;

function TCustomExifData.GetUserRating: TWindowsStarRating;
const
  MinRating = Ord(Low(TWindowsStarRating));
  MaxRating = Ord(High(TWindowsStarRating));
var
  I: Integer;
begin
  if FSections[esGeneral].TryGetWordValue(ttWindowsRating, 0, Result) then
    if not EnsureEnumsInRange then
      Exit
    else
      case Ord(Result) of
        MinRating..MaxRating: Exit;
      end
  else
    if TryStrToInt(XMPPacket[xsXMPBasic].Properties['Rating'].ReadValue, I) then
      if not EnsureEnumsInRange or InRange(I, MinRating, MaxRating) then
      begin
        Result := TWindowsStarRating(I);
        Exit;
      end;
  Result := urUndefined;
end;

function TCustomExifData.GetWhiteBalance: TExifWhiteBalanceMode;
begin
  if FSections[esDetails].TryGetWordValue(ttWhiteBalance, 0, Result) then
    if not EnsureEnumsInRange then
      Exit
    else
      case Ord(Result) of
        Ord(Low(TExifWhiteBalanceMode))..Ord(High(TExifWhiteBalanceMode)): Exit;
      end;
  Result := ewTagMissing;
end;

{ TCustomExifData - tag setters }

procedure TCustomExifData.SetAuthor(const Value: UnicodeString);
var              //While it always writes both XMP properties, Windows Explorer always
  Tag: TExifTag; //set its own unicode Exif tag and clears the 'standard' ASCII one;
begin            //we'll be a bit more intelligent though.
  XMPPacket.UpdateSeqProperty(xsDublinCore, 'creator', Value);
  XMPPacket.UpdateProperty(xsTIFF, 'Artist', Value);
  if Length(Value) = 0 then
  begin
    FSections[esGeneral].Remove(ttArtist);
    FSections[esGeneral].Remove(ttWindowsAuthor);
    Exit;
  end;
  if not ContainsOnlyASCII(Value) then
    FSections[esGeneral].Remove(ttArtist)
  else
    if FSections[esGeneral].Find(ttArtist, Tag) then
    begin
      Tag.UpdateData(tdAscii, Length(Value), TiffString(Value)[1]);
      if not FSections[esGeneral].Find(ttWindowsAuthor, Tag) then
        Exit;
    end;
  FSections[esGeneral].SetWindowsStringValue(ttWindowsAuthor, Value);
end;

procedure TCustomExifData.SetColorSpace(Value: TExifColorSpace);
begin
  if Value = csTagMissing then
  begin
    FSections[esDetails].Remove(ttColorSpace);
    XMPPacket.RemoveProperty(xsExif, 'ColorSpace');
  end
  else
  begin
    FSections[esDetails].ForceSetElement(ttColorSpace, tdWord, 0, Value);
    XMPPacket.UpdateProperty(xsExif, 'ColorSpace', Ord(Value));
  end;
end;

procedure TCustomExifData.SetComments(const Value: UnicodeString);
var
  Tag: TExifTag;
  NewSize: Integer;
begin
  XMPPacket.UpdateProperty(xsExif, 'UserComment', xpAltArray, Value);
  if Length(Value) = 0 then
  begin
    FSections[esGeneral].Remove(ttWindowsComments);
    FSections[esDetails].Remove(ttUserComment);
  end
  else
  begin
    FSections[esGeneral].SetWindowsStringValue(ttWindowsComments, Value);
    if FSections[esGeneral].Find(ttUserComment, Tag) then
    begin
      NewSize := SizeOf(UCID_Unicode) + Length(Value) * 2;
      if (NewSize > Tag.OriginalDataSize) and not Tag.Section.IsExtendable then
        Tag.ElementCount := 0
      else
      begin
        Tag.UpdateData(tdByte, NewSize, PByte(nil)^);
        Move(UCID_Unicode, Tag.Data^, SizeOf(UCID_Unicode));
        Move(PWideChar(Value)^, PByteArray(Tag.Data)[SizeOf(UCID_Unicode)],
          NewSize - SizeOf(UCID_Unicode));
      end;
    end;
  end;
end;

procedure TCustomExifData.SetDetailsDateTime(TagID: Integer; const Value: TDateTimeTagValue);
var
  SubSecsID: TExifTagID;
  XMPName: string;
begin
  case TagID of
    ttDateTimeOriginal: SubSecsID := ttSubsecTimeOriginal;
    ttDateTimeDigitized: SubSecsID := ttSubsecTimeDigitized;
  else SubSecsID := 0;
  end;
  FSections[esDetails].SetDateTimeValue(TagID, SubSecsID, Value);
  case TagID of
    ttDateTimeOriginal: XMPName := 'DateTimeOriginal';
    ttDateTimeDigitized: XMPName := 'DateTimeDigitized';
  else Exit;
  end;
  XMPPacket.UpdateDateTimeProperty(xsExif, XMPName, Value, False);
end;

procedure TCustomExifData.SetDetailsFraction(TagID: Integer;
  const Value: TExifFraction);
var
  XMPName: string;
begin
  FSections[esDetails].SetFractionValue(TagID, 0, Value);
  case TagID of
    ttApertureValue: XMPName := 'ApertureValue';
    ttCompressedBitsPerPixel: XMPName := 'CompressedBitsPerPixel';
    ttDigitalZoomRatio: XMPName := 'DigitalZoomRatio';
    ttExposureBiasValue: XMPName := 'ExposureBiasValue';
    ttExposureTime: XMPName := 'ExposureTime';
    ttFNumber: XMPName := 'FNumber';
    ttMaxApertureValue: XMPName := 'MaxApertureValue';
    ttSubjectDistance: XMPName := 'SubjectDistance';
  else Exit;
  end;
  XMPPacket.UpdateProperty(xsExif, XMPName, Value.AsString);
end;

procedure TCustomExifData.SetDetailsSFraction(TagID: Integer;
  const Value: TExifSignedFraction);
var
  PropName: string;
begin
  FSections[esDetails].SetSignedFractionValue(TagID, 0, Value);
  case TagID of
    ttBrightnessValue: PropName := 'BrightnessValue';
    ttExposureBiasValue: PropName := 'ExposureBiasValue';
    ttShutterSpeedValue: PropName := 'ShutterSpeedValue';
  else Exit;
  end;
  XMPPacket.UpdateProperty(xsExif, PropName, Value.AsString);
end;

procedure TCustomExifData.SetOffsetSchema(const Value: TLongIntTagValue);
begin
  if Value.MissingOrInvalid then
    FSections[esDetails].Remove(ttOffsetSchema)
  else
    FSections[esDetails].ForceSetElement(ttOffsetSchema, tdLongInt, 0, Value)
end;

//procedure TCustomExifData.SetDetailsLongWord(TagID: Integer; const Value: LongWord);
//begin
//  FSections[esDetails].SetLongWordValue(TagID, 0, Value)
//end;

procedure TCustomExifData.SetDetailsString(TagID: Integer; const Value: string);
var
  XMPName: string;
begin
  FSections[esDetails].SetStringValue(TagID, Value);
  case TagID of
    ttImageUniqueID: XMPName := 'ImageUniqueID';
    ttRelatedSoundFile: XMPName := 'RelatedSoundFile';
    ttSpectralSensitivity: XMPName := 'SpectralSensitivity';
  else Exit;
  end;
  XMPPacket.UpdateProperty(xsExif, XMPName, Value);
end;

procedure TCustomExifData.SetFocalLengthIn35mmFilm(const Value: TWordTagValue);
const
  XMPName = UnicodeString('FocalLengthIn35mmFilm');
begin
  if Value.MissingOrInvalid then
  begin
    FSections[esDetails].Remove(ttFocalLengthIn35mmFilm);
    XMPPacket.RemoveProperty(xsExif, XMPName);
  end
  else
  begin
    FSections[esDetails].SetWordValue(ttFocalLengthIn35mmFilm, 0, Value);
    XMPPacket.UpdateProperty(xsExif, XMPName, Value);
  end;
end;

procedure TCustomExifData.SetDetailsWordEnum(ID: TExifTagID;
  const XMPName: UnicodeString; const Value);
begin
  if SmallInt(Value) = -1 then
  begin
    FSections[esDetails].Remove(ID);
    XMPPacket.RemoveProperty(xsExif, XMPName);
  end
  else
  begin
    FSections[esDetails].ForceSetElement(ID, tdWord, 0, Value);
    XMPPacket.UpdateProperty(xsExif, XMPName, Word(Value));
  end;
end;

procedure TCustomExifData.SetDetailsByteEnum(ID: TExifTagID; const XMPName: UnicodeString; const Value);
begin
  if Byte(Value) = 0 then
  begin
    FSections[esDetails].Remove(ID);
    XMPPacket.RemoveProperty(xsExif, XMPName);
  end
  else
  begin
    FSections[esDetails].ForceSetElement(ID, tdUndefined, 0, Value);
    XMPPacket.UpdateProperty(xsExif, XMPName, Byte(Value));
  end;
end;

procedure TCustomExifData.SetExifImageSize(ID: Integer; const NewValue: TLongWordTagValue);
const
  PropNames: array[ttExifImageWidth..ttExifImageHeight] of UnicodeString =
    ('PixelXDimension', 'PixelYDimension');
var
  Tag: TExifTag;
begin
  if NewValue.MissingOrInvalid then
  begin
    FSections[esDetails].Remove(ID);
    XMPPacket.RemoveProperty(xsExif, PropNames[ID]);
    Exit;
  end;
  Tag := nil;
  if (NewValue <= High(Word)) and FSections[esDetails].Find(ID, Tag) and
     (Tag.DataType = tdWord) and (Tag.ElementCount = 1) then
    Tag.UpdateData(NewValue)
  else if Tag <> nil then
    Tag.UpdateData(tdLongWord, 1, NewValue)
  else
    PLongWord(FSections[esDetails].Add(ID, tdLongWord, 1).Data)^ := NewValue;
  XMPPacket.UpdateProperty(xsExif, PropNames[ID], Integer(Int64(NewValue)));
end;

procedure TCustomExifData.SetExifVersion(Value: TCustomExifVersion);
begin
  FExifVersion.Assign(Value);
end;

procedure TCustomExifData.SetExposureMode(const Value: TExifExposureMode);
begin
  SetDetailsWordEnum(ttExposureMode, 'ExposureMode', Value);
end;

procedure TCustomExifData.SetExposureProgram(const Value: TExifExposureProgram);
begin
  SetDetailsWordEnum(ttExposureProgram, 'ExposureProgram', Value);
end;

procedure TCustomExifData.SetFlashPixVersion(Value: TCustomExifVersion);
begin
  FFlashPixVersion.Assign(Value);
end;

procedure TCustomExifData.SetFileSource(const Value: TExifFileSource);
begin
  SetDetailsByteEnum(ttFileSource, 'FileSource', Value);
end;

procedure TCustomExifData.SetFlash(Value: TExifFlashInfo);
begin
  FFlash.Assign(Value);
end;

procedure TCustomExifData.SetFocalPlaneResolution(Value: TCustomExifResolution);
begin
  FFocalPlaneResolution.Assign(Value);
end;

procedure TCustomExifData.SetGainControl(const Value: TExifGainControl);
begin
  SetDetailsWordEnum(ttGainControl, 'GainControl', Value);
end;

procedure TCustomExifData.SetDateTime(const Value: TDateTimeTagValue);
begin
  FSections[esGeneral].SetDateTimeValue(ttDateTime, ttSubsecTime, Value);
  XMPPacket.UpdateDateTimeProperty(xsTIFF, 'DateTime', Value, False);
end;

procedure TCustomExifData.SetGeneralString(TagID: Integer; const Value: string);
begin
  FSections[esGeneral].SetStringValue(TagID, Value);
  case TagID of
    ttCopyright: XMPPacket.UpdateProperty(xsDublinCore, 'rights', xpAltArray,
      Value);
    ttImageDescription:
      if (Value <> '') or (XMPWritePolicy = xwRemove) or
         not FSections[esDetails].TagExists(ttWindowsSubject) then
        XMPPacket.UpdateProperty(xsDublinCore, 'description', xpAltArray, Value);
    ttMake: XMPPacket.UpdateProperty(xsTIFF, 'Make', Value);
    ttModel: XMPPacket.UpdateProperty(xsTIFF, 'Model', Value);
    ttSoftware:
    begin
      XMPPacket.UpdateProperty(xsXMPBasic, 'creatortool', Value);
      XMPPacket.UpdateProperty(xsTIFF, 'Software', Value);
    end;
  end;
end;

procedure TCustomExifData.SetGeneralWinString(TagID: Integer;
  const Value: UnicodeString);
begin
  FSections[esGeneral].SetWindowsStringValue(TagID, Value);
  case TagID of
    ttWindowsKeywords:
    begin
      XMPPacket.UpdateBagProperty(xsDublinCore, 'subject', Value);
      XMPPacket.UpdateBagProperty(xsMicrosoftPhoto, 'LastKeywordXMP', Value);
    end;
    ttWindowsSubject: XMPPacket.UpdateProperty(xsDublinCore, 'description', xpAltArray, Value);
    ttWindowsTitle: XMPPacket.UpdateProperty(xsDublinCore, 'title', xpAltArray, Value);
  end;
end;

procedure TCustomExifData.SetGPSAltitudeRef(const Value: TGPSAltitudeRef);
begin
  if Value = alTagMissing then
  begin
    FSections[esGPS].Remove(ttGPSAltitudeRef);
    XMPPacket.RemoveProperty(xsExif, GetGPSTagXMPName(ttGPSAltitudeRef));
    Exit;
  end;
  FSections[esGPS].SetByteValue(ttGPSAltitudeRef, 0, Ord(Value));
  XMPPacket.UpdateProperty(xsExif, GetGPSTagXMPName(ttGPSAltitudeRef), Ord(Value));
end;

procedure TCustomExifData.SetGPSDateTimeUTC(const Value: TDateTimeTagValue);
const
  XMPName = UnicodeString('GPSTimeStamp');
var
  Year, Month, Day, Hour, Minute, Second, MSecond: Word;
begin
  BeginUpdate;
  try
    if Value.MissingOrInvalid then
    begin
      FSections[esGPS].Remove(ttGPSDateStamp);
      FSections[esGPS].Remove(ttGPSTimeStamp);
      XMPPacket.RemoveProperty(xsExif, XMPName);
      Exit;
    end;
    DecodeDateTime(Value, Year, Month, Day, Hour, Minute, Second, MSecond);
    GPSDateStamp := Format('%.4d:%.2d:%.2d', [Year, Month, Day]);
    GPSTimeStampHour := TExifFraction.Create(Hour, 1);
    GPSTimeStampMinute := TExifFraction.Create(Minute, 1);
    GPSTimeStampSecond := TExifFraction.Create(Second, 1);
    XMPPacket.UpdateDateTimeProperty(xsExif, XMPName, Value, False);
  finally
    EndUpdate;
  end;
end;

procedure TCustomExifData.SetGPSDestDistanceRef(const Value: TGPSDistanceRef);
const
  Strings: array[TGPSDistanceRef] of string = ('', 'K', 'M', 'N');
begin
  FSections[esGPS].SetStringValue(ttGPSDestDistanceRef, Strings[Value]);
  XMPPacket.UpdateProperty(xsExif, GetGPSTagXMPName(ttGPSDestDistanceRef), Strings[Value]);
end;

procedure TCustomExifData.SetGPSDestLatitude(Value: TGPSLatitude);
begin
  FGPSDestLatitude.Assign(Value);
end;

procedure TCustomExifData.SetGPSDestLongitude(Value: TGPSLongitude);
begin
  FGPSDestLongitude.Assign(Value);
end;

procedure TCustomExifData.SetGPSDifferential(Value: TGPSDifferential);
begin
  if Value = dfTagMissing then
  begin
    FSections[esGPS].Remove(ttGPSDifferential);
    XMPPacket.RemoveProperty(xsExif, GetGPSTagXMPName(ttGPSDifferential));
    Exit;
  end;
  FSections[esGPS].ForceSetElement(ttGPSDifferential, tdWord, 0, Value);
  XMPPacket.UpdateProperty(xsExif, GetGPSTagXMPName(ttGPSDifferential), Ord(Value));
end;

procedure TCustomExifData.SetGPSDirection(TagID: Integer; Value: TGPSDirectionRef);
const
  Strings: array[TGPSDirectionRef] of string = ('', 'T', 'M');
begin
  FSections[esGPS].SetStringValue(TagID, Strings[Value]);
  XMPPacket.UpdateProperty(xsExif, GetGPSTagXMPName(TagID), Strings[Value]);
end;

procedure TCustomExifData.SetGPSFraction(TagID: Integer; const Value: TExifFraction);
var
  XMPName: string;
begin
  FSections[esGPS].SetFractionValue(TagID, 0, Value);
  if FindGPSTagXMPName(TagID, XMPName) then 
    XMPPacket.UpdateProperty(xsExif, XMPName, Value.AsString);
end;

procedure TCustomExifData.SetGPSLatitude(Value: TGPSLatitude);
begin
  FGPSLatitude.Assign(Value);
end;

procedure TCustomExifData.SetGPSLongitude(Value: TGPSLongitude);
begin
  FGPSLongitude.Assign(Value);
end;

procedure TCustomExifData.SetGPSMeasureMode(const Value: TGPSMeasureMode);
const
  Strings: array[TGPSMeasureMode] of string = ('', '2', '3');
begin
  FSections[esGPS].SetStringValue(ttGPSMeasureMode, Strings[Value]);
  XMPPacket.UpdateProperty(xsExif, GetGPSTagXMPName(ttGPSMeasureMode), Strings[Value]);
end;

procedure TCustomExifData.SetGPSSpeedRef(const Value: TGPSSpeedRef);
const
  Strings: array[TGPSSpeedRef] of string = ('', 'K', 'M', 'N');
begin
  FSections[esGPS].SetStringValue(ttGPSSpeedRef, Strings[Value]);
  XMPPacket.UpdateProperty(xsExif, 'GPSSpeedRef', Strings[Value]);
end;

procedure TCustomExifData.SetGPSStatus(const Value: TGPSStatus);
const
  Strings: array[TGPSStatus] of string = ('', 'A', 'V');
begin
  FSections[esGPS].SetStringValue(ttGPSStatus, Strings[Value]);
  XMPPacket.UpdateProperty(xsExif, 'GPSStatus', Strings[Value]);
end;

procedure TCustomExifData.SetGPSString(TagID: Integer; const Value: string);
var
  XMPName: string;
begin
  FSections[esGPS].SetStringValue(TagID, Value);
  if FindGPSTagXMPName(TagID, XMPName) then 
    XMPPacket.UpdateProperty(xsExif, XMPName, Value);
end;

procedure TCustomExifData.SetGPSTimeStamp(const Index: Integer;
  const Value: TExifFraction);
begin
  FSections[esGPS].SetFractionValue(ttGPSTimeStamp, Index, Value);
  if FUpdateCount = 0 then
    XMPPacket.RemoveProperty(xsExif, GetGPSTagXMPName(ttGPSTimeStamp));
end;

procedure TCustomExifData.SetGPSVersion(Value: TCustomExifVersion);
begin
  FGPSVersion.Assign(Value);
end;

procedure TCustomExifData.SetInteropVersion(Value: TCustomExifVersion);
begin
  FInteropVersion.Assign(Value);
end;

procedure TCustomExifData.SetISOSpeedRatings(Value: TISOSpeedRatings);
begin
  if Value <> FISOSpeedRatings then FISOSpeedRatings.Assign(Value);
end;

procedure TCustomExifData.SetLightSource(const Value: TExifLightSource);
begin
  SetDetailsWordEnum(ttLightSource, 'LightSource', Value);
end;

procedure TCustomExifData.SetMeteringMode(const Value: TExifMeteringMode);
begin
  SetDetailsWordEnum(ttMeteringMode, 'MeteringMode', Value);
end;

procedure TCustomExifData.SetOrientation(SectionKind: Integer; Value: TExifOrientation);
var
  XMPValue: UnicodeString;
begin
  with FSections[TExifSectionKind(SectionKind)] do
    if Value = toUndefined then
      Remove(ttOrientation)
    else
      SetWordValue(ttOrientation, 0, Ord(Value));
  if TExifSectionKind(SectionKind) <> esGeneral then Exit;
  if Value = toUndefined then
    XMPValue := ''
  else
    XMPValue := IntToStr(Ord(Value));
  XMPPacket.UpdateProperty(xsTIFF, 'Orientation', XMPValue);
end;

procedure TCustomExifData.SetResolution(Value: TCustomExifResolution);
begin
  FResolution.Assign(Value);
end;

procedure TCustomExifData.SetRendering(const Value: TExifRendering);
begin
  SetDetailsWordEnum(ttCustomRendered, 'CustomRendered', Value);
end;

procedure TCustomExifData.SetSaturation(Value: TExifSaturation);
begin
  SetDetailsWordEnum(ttSaturation, 'Saturation', Value);
end;

procedure TCustomExifData.SetSceneCaptureType(const Value: TExifSceneCaptureType);
begin
  SetDetailsWordEnum(ttSceneCaptureType, 'SceneCaptureType', Value);
end;

procedure TCustomExifData.SetSceneType(Value: TExifSceneType);
begin
  SetDetailsByteEnum(ttSceneType, 'SceneType', Value);
end;

procedure TCustomExifData.SetSensingMethod(const Value: TExifSensingMethod);
begin
  SetDetailsWordEnum(ttSensingMethod, 'SensingMethod', Value);
end;

procedure TCustomExifData.SetSharpness(Value: TExifSharpness);
begin
  SetDetailsWordEnum(ttSharpness, 'Sharpness', Value);
end;

procedure TCustomExifData.SetSubjectDistanceRange(Value: TExifSubjectDistanceRange);
begin
  SetDetailsWordEnum(ttSubjectDistanceRange, 'SubjectDistanceRange', Value);
end;

procedure TCustomExifData.SetSubjectLocation(const Value: TSmallPoint);
const
  XMPName = UnicodeString('SubjectLocation');
var
  Tag: TExifTag;
begin
  if InvalidPoint(Value) then
  begin
    FSections[esDetails].Remove(ttSubjectDistance);
    XMPPacket.RemoveProperty(xsExif, XMPName);
  end
  else
  begin
    if not FSections[esDetails].Find(ttSubjectDistance, Tag) then
      Tag := FSections[esDetails].Add(ttSubjectDistance, tdWord, 2);
    Tag.UpdateData(tdWord, 2, Value);
    XMPPacket.UpdateSeqProperty(xsExif, XMPName, [IntToStr(Value.x), IntToStr(Value.y)]);
  end;
end;

procedure TCustomExifData.SetThumbnailResolution(Value: TCustomExifResolution);
begin
  FThumbnailResolution.Assign(Value);
end;

procedure TCustomExifData.SetUserRating(const Value: TWindowsStarRating);
const
  MSPhotoValues: array[TWindowsStarRating] of UnicodeString = ('', '1', '25', '50', '75', '99');
  XMPBasicValues: array[TWindowsStarRating] of UnicodeString = ('', '1', '2', '3', '4', '5');
begin
  if Value = urUndefined then
    FSections[esGeneral].Remove(ttWindowsRating)
  else
    FSections[esGeneral].SetWordValue(ttWindowsRating, 0, Ord(Value));
  XMPPacket.UpdateProperty(xsMicrosoftPhoto, 'Rating', MSPhotoValues[Value]);
  XMPPacket.UpdateProperty(xsXMPBasic, 'Rating', XMPBasicValues[Value]);
end;

procedure TCustomExifData.SetWhiteBalance(const Value: TExifWhiteBalanceMode);
begin
  SetDetailsWordEnum(ttWhiteBalance, 'WhiteBalance', Value);
end;

{ TExifDataPatcher }

constructor TExifDataPatcher.Create(const AFileName: string);
begin
  inherited Create;
  OpenFile(AFileName);
end;

destructor TExifDataPatcher.Destroy;
begin
  CloseFile;
  inherited;
end;

procedure TExifDataPatcher.CheckFileIsOpen;
begin
  if FStream = nil then
    raise ENoExifFileOpenError.CreateRes(@SNoFileOpenError);
end;

function TExifDataPatcher.GetFileDateTime: TDateTime;
begin
  CheckFileIsOpen;
  Result := FileDateToDateTime(FileGetDate(FStream.Handle));
end;

function TExifDataPatcher.GetFileName: string;
begin
  if FStream <> nil then
    Result := FStream.FileName
  else
    Result := '';
end;

{$IF CompilerVersion >= 22}
procedure TExifDataPatcher.GetImage<T>(Dest: T);
{$ELSE}
procedure TExifDataPatcher.GetImage(const Dest: IStreamPersist);
{$IFEND}
begin
  CheckFileIsOpen;
  FStream.Position := 0;
  Dest.LoadFromStream(FStream);
end;

{$IF CompilerVersion >= 22}
procedure TExifDataPatcher.GetThumbnail<T>(Dest: T);
{$ELSE}
procedure TExifDataPatcher.GetThumbnail(Dest: TPersistent);
{$IFEND}
begin
  CheckFileIsOpen;
  Dest.Assign(Thumbnail);
end;

procedure TExifDataPatcher.SetFileDateTime(const Value: TDateTime);
begin
  CheckFileIsOpen;
{$IFDEF MSWINDOWS}                                        {$WARN SYMBOL_PLATFORM OFF}
  FileSetDate(FStream.Handle, DateTimeToFileDate(Value)); {$WARN SYMBOL_PLATFORM ON}
{$ELSE}
  FileSetDate(FStream.FileName, DateTimeToFileDate(Value)); //!!!does this actually work?
{$ENDIF}
end;

procedure TExifDataPatcher.OpenFile(const JPEGFileName: string);
begin
  CloseFile;
  if JPEGFileName = '' then Exit;
  FStream := TFileStream.Create(JPEGFileName, fmOpenReadWrite);
  if not HasJPEGHeader(FStream) then
  begin
    FreeAndNil(FStream);
    raise EInvalidJPEGHeader.CreateResFmt(@SFileIsNotAValidJPEG, [JPEGFileName]);
  end;
  LoadFromGraphic(FStream);
  FOriginalEndianness := Endianness;
end;

procedure TExifDataPatcher.CloseFile(SaveChanges: Boolean);
begin
  if FStream = nil then Exit;
  if SaveChanges then UpdateFile;
  FreeAndNil(FStream);
  Clear;
  Modified := False;
end;

procedure TExifDataPatcher.UpdateFile;
var
  DataOffsetFix: Int64;
  OldDate: Integer;
  Section: TExifSection;
  SectionEndianness: TEndianness;
  Tag: TExifTag;
  XMPStream: TMemoryStream;
  Segment: IFoundJPEGSegment;
  BytesToRewrite: TBytes;
begin
  if (FStream = nil) or not Modified then Exit;
  OldDate := FileGetDate(FStream.Handle);
  for Section in Self do
    if Section.Modified or ((Endianness <> FOriginalEndianness) and (Section.Kind <> esMakerNote)) then
    begin
      if Section.Kind = esMakerNote then
      begin
        DataOffsetFix := -OffsetSchema;
        SectionEndianness := MakerNote.Endianness;
      end
      else
      begin
        DataOffsetFix := 0;
        SectionEndianness := Endianness;
      end;
      Stream.Position := OffsetBase + Section.FirstTagHeaderOffset;
      for Tag in Section do
        Tag.WriteHeader(Stream, SectionEndianness, Tag.OriginalDataOffset + DataOffsetFix);
      for Tag in Section do
      begin
        Stream.Position := OffsetBase + Tag.OriginalDataOffset;
        Tag.WriteOffsettedData(Stream, SectionEndianness);
      end;
      Section.Modified := False;
    end;
  if (mkXMP in MetadataInSource) or not XMPPacket.Empty then
  begin
    BytesToRewrite := nil;
    XMPStream := TMemoryStream.Create;
    try
      XMPStream.WriteBuffer(TJPEGSegment.XMPHeader, SizeOf(TJPEGSegment.XMPHeader));
      XMPPacket.SaveToStream(XMPStream);
      if XMPStream.Size <= FXMPPacketSizeInSource then
      begin
        Assert(mkXMP in MetadataInSource);
        XMPStream.Size := FXMPPacketSizeInSource;
        FillChar(PAnsiChar(XMPStream.Memory)[XMPStream.Size],
          FXMPPacketSizeInSource - XMPStream.Size, $20);
      end
      else
      begin
        if mkXMP in MetadataInSource then
          Stream.Position := FXMPSegmentPosition + SizeOf(TJPEGSegmentHeader) + FXMPPacketSizeInSource
        else
        begin
          Stream.Position := 0;
          for Segment in JPEGHeader(Stream) do
            if Segment.MarkerNum <> jmApp1 then Break;
          FXMPSegmentPosition := Stream.Position;
          Include(FMetadataInSource, mkXMP);
        end;
        FXMPPacketSizeInSource := XMPStream.Size;
        SetLength(BytesToRewrite, Stream.Size - Stream.Position);
        Stream.ReadBuffer(BytesToRewrite[0], Length(BytesToRewrite));
      end;
      Stream.Position := FXMPSegmentPosition;
      WriteJPEGSegment(Stream, jmApp1, XMPStream);
      if BytesToRewrite <> nil then
        Stream.WriteBuffer(BytesToRewrite[0], Length(BytesToRewrite));
    finally
      XMPStream.Free;
    end;
  end;
  FOriginalEndianness := Endianness;
  if PreserveFileDate then
    SetFileDateTime(OldDate);
  Modified := False;
end;

{ TExifData }

constructor TExifData.Create(AOwner: TComponent = nil);
begin
  inherited;
  FRemovePaddingTagsOnSave := True;
end;

procedure TExifData.Assign(Source: TPersistent);
var
  SourceData: TCustomExifData;
  Section: TExifSectionKind;
begin
  if Source = nil then
    Clear
  else if Source is TCustomExifData then
  begin
    BeginUpdate;
    try
      SourceData := TCustomExifData(Source);
      for Section := Low(TExifSectionKind) to High(TExifSectionKind) do
        Sections[Section].Assign(SourceData[Section]);
//      if SourceData is TExifData then
//        Thumbnail := TExifData(SourceData).FThumbnailOrNil
//      else if Sections[esThumbnail].Count = 0 then
//        SetThumbnail(nil);
    finally
      EndUpdate;
    end;
  end
  else
    inherited;
end;

{$IF Declared(TGraphic)}
procedure TExifData.CreateThumbnail(Source: TGraphic;
  ThumbnailWidth, ThumbnailHeight: Integer);
begin
  if IsGraphicEmpty(Source) then
    Thumbnail := nil
  else
    CreateExifThumbnail(Source, Thumbnail, ThumbnailWidth, ThumbnailHeight);
end;

procedure TExifData.StandardizeThumbnail;
var
  Image: TJPEGImage;
begin
  if not HasThumbnail then Exit;
  Image := Thumbnail;
  if (Image.Width > StandardExifThumbnailWidth) or
     (Image.Height > StandardExifThumbnailHeight) then
    CreateExifThumbnail(Image, Image);
end;
{$IFEND}

procedure TExifData.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineBinaryProperty('Data', LoadFromStream, SaveToStream, not Empty);
end;

function TExifData.GetSection(Section: TExifSectionKind): TExtendableExifSection;
begin
  Result := TExtendableExifSection(inherited Sections[Section]);
end;

function TExifData.LoadFromGraphic(Stream: TStream): Boolean;
begin
  Result := inherited LoadFromGraphic(Stream);
end;

function TExifData.LoadFromGraphic(const Graphic: IStreamPersist): Boolean;
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    Graphic.SaveToStream(Stream);
    Stream.Position := 0;
    Result := LoadFromGraphic(Stream)
  finally
    Stream.Free;
  end;
end;

function TExifData.LoadFromGraphic(const FileName: string): Boolean;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    Result := LoadFromGraphic(Stream);
  finally
    Stream.Free;
  end;
end;

{$IF DECLARED(TJPEGData)}
procedure TExifData.LoadFromJPEG(JPEGStream: TStream);
begin
  if HasJPEGHeader(JPEGStream) then
    LoadFromGraphic(JPEGStream)
  else
    raise EInvalidJPEGHeader.CreateRes(@SInvalidJPEGHeader);
end;

procedure TExifData.LoadFromJPEG(JPEGImage: TJPEGImage);
begin
  LoadFromGraphic(JPEGImage)
end;

procedure TExifData.LoadFromJPEG(const FileName: string);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    if HasJPEGHeader(Stream) then
      inherited LoadFromGraphic(Stream)
    else
      raise EInvalidJPEGHeader.CreateRes(@SInvalidJPEGHeader);
  finally
    Stream.Free;
  end;
end;
{$IFEND}

procedure TExifData.LoadFromStream(Stream: TStream);
begin
  Clear(False);
  AddFromStream(Stream);
end;

procedure TExifData.RemoveMakerNote;
begin
  Sections[esDetails].Remove(ttMakerNote);
end;

procedure TExifData.RemovePaddingTags;
var
  Section: TExifSection;
begin
  for Section in Self do
    Section.RemovePaddingTag;
end;

procedure TExifData.DoSaveToJPEG(InStream, OutStream: TStream);
var
  SavedPos: Int64;
  Segment: IFoundJPEGSegment;
  SOFData: PJPEGStartOfFrameData;
  Tag: TExifTag;
begin
  for Tag in Sections[esDetails] do
    case Tag.ID of
      ttExifImageWidth, ttExifImageHeight:
      begin
        SavedPos := InStream.Position;
        for Segment in JPEGHeader(InStream, TJPEGSegment.StartOfFrameMarkers) do
          if Segment.Data.Size >= SizeOf(TJPEGStartOfFrameData) then
          begin
            SOFData := Segment.Data.Memory;
            ExifImageWidth := SOFData.ImageWidth;
            ExifImageHeight := SOFData.ImageHeight;
            Break;
          end;
        InStream.Position := SavedPos;
        Break;
      end;
    end;
  UpdateApp1JPEGSegments(InStream, OutStream, Self, XMPPacket); //!!!IPTC (also TJPEGImageEx)  
end;

procedure TExifData.DoSaveToPSD(InStream, OutStream: TStream);
var
  Block: IAdobeResBlock;
  Info: TPSDInfo;
  NewBlocks: IInterfaceList;
  StartPos: Int64;
begin
  StartPos := InStream.Position;
  NewBlocks := TInterfaceList.Create;
  if not EmbeddedIPTC.Empty then
    NewBlocks.Add(CreateAdobeBlock(TAdobeResBlock.IPTCTypeID, EmbeddedIPTC));
  if not XMPPacket.Empty then
    NewBlocks.Add(CreateAdobeBlock(TAdobeResBlock.XMPTypeID, XMPPacket));
  for Block in ParsePSDHeader(InStream, Info) do
    if not Block.IsExifBlock and not Block.IsXMPBlock then NewBlocks.Add(Block);
  Sections[esGeneral].Remove([ttXMP, ttIPTC]); //!!!
  if not Empty then
    NewBlocks.Insert(0, CreateAdobeBlock(TAdobeResBlock.ExifTypeID, Self));
  WritePSDHeader(OutStream, Info.Header);
  WritePSDResourceSection(OutStream, NewBlocks);
  InStream.Position := StartPos + Info.LayersSectionOffset;
  OutStream.CopyFrom(InStream, InStream.Size - InStream.Position);
end;

procedure TExifData.AddNewTags(Rewriter: TTiffDirectoryRewriter);
begin
  if Sections[esDetails].Count <> 0 then
    Rewriter.AddSubDirectory(ttExifOffset, Sections[esDetails]); //!!! TExifSectionEx to implement the callback intf
  if Sections[esGPS].Count <> 0 then
    Rewriter.AddSubDirectory(ttGPSOffset, Sections[esGPS]);
end;

procedure TExifData.RewritingOldTag(const Source: ITiffDirectory; TagID: TTiffTagID;
  DataType: TTiffDataType; var Rewrite: Boolean);
begin
  if IsKnownExifTagInMainIFD(TagID, DataType) then Rewrite := False;
end;

procedure TExifData.DoSaveToTIFF(InStream, OutStream: TStream);
begin
  RewriteTiff(InStream, OutStream, Self);
end;

procedure TExifData.GetGraphicSaveMethod(Stream: TStream; var Method: TGraphicSaveMethod);
begin
  if HasJPEGHeader(Stream) then
    Method := DoSaveToJPEG
  else if HasPSDHeader(Stream) then
    Method := DoSaveToPSD
  else if HasTiffHeader(Stream) then
    Method := DoSaveToTIFF
end;

procedure TExifData.SaveToGraphic(const FileName: string);
begin
  DoSaveToGraphic(FileName, GetGraphicSaveMethod);
end;

procedure TExifData.SaveToGraphic(const Graphic: IStreamPersist);
begin
  DoSaveToGraphic(Graphic, GetGraphicSaveMethod);
end;

procedure TExifData.SaveToGraphic(const Stream: TStream);
begin
  DoSaveToGraphic(Stream, GetGraphicSaveMethod);
end;

{$IF DECLARED(TJPEGData)}
procedure TExifData.SaveToJPEG(const JPEGFileName: string; Dummy: Boolean = True);
begin
  SaveToGraphic(JPEGFileName);
end;

procedure TExifData.SaveToJPEG(JPEGImage: TJPEGImage);
begin
  SaveToGraphic(JPEGImage);
end;
{$IFEND}

type
  TSectionSavingInfo = record
    StartOffset, DirectorySize, OffsettedDataSize: Int64;
    function EndOffsetPlus1: LongWord; {$IFDEF CanInline}inline;{$ENDIF}
  end;

function TSectionSavingInfo.EndOffsetPlus1: LongWord;
begin
  Result := StartOffset + DirectorySize + OffsettedDataSize;
end;

{ TExifData.SaveToStream: sections are written out in TExifSection order, with a
  section's offsetted data immediately following its tag directory. If a MakerNote tag
  exists, then sections are saved around that tag's data.}
procedure TExifData.SaveToStream(Stream: TStream);
type
  TOffsetSectionKind = esDetails..esThumbnail;
const
  OffsetSectionKinds = [Low(TOffsetSectionKind)..High(TOffsetSectionKind)];
var
  BaseStreamPos: Int64;
  MakerNoteTag, MakerNoteOffsetTag: TExifTag;
  MakerNoteDataOffset: Int64;
  PreserveMakerNotePos: Boolean;
  OffsetTags: array[TOffsetSectionKind] of TExifTag;
  SavingInfo: array[TExifSectionKind] of TSectionSavingInfo;

  procedure InitSavingInfo(Kind: TExifSectionKind;
    const OffsettedSections: array of TOffsetSectionKind);
  const
    OffsetTagIDs: array[TOffsetSectionKind] of TExifTagID = (ttExifOffset,
      ttInteropOffset, ttGPSOffset, ttThumbnailOffset);
  var
    Client: TOffsetSectionKind;
    Tag: TExifTag;
  begin
    for Client in OffsettedSections do
      if (SavingInfo[Client].DirectorySize > 0) or (Client = Kind){as for thumbnail} then
        OffsetTags[Client] := Sections[Kind].AddOrUpdate(OffsetTagIDs[Client],
          tdLongWord, 1, PLongWord(nil)^)
      else
        Sections[Kind].Remove(OffsetTagIDs[Client]);
    if (Kind <> esGeneral) and (Sections[Kind].Count = 0) then Exit; //don't write out empty sections
    for Tag in Sections[Kind] do
      if Tag.DataSize > 4 then Inc(SavingInfo[Kind].OffsettedDataSize, Tag.DataSize);
    SavingInfo[Kind].DirectorySize := 2 + (TTiffTag.HeaderSize * Sections[Kind].Count) + 4; //length + tag recs + pos of next IFD
  end;

  procedure WriteDirectory(Kind: TExifSectionKind);
  var
    NextDataOffset: LongWord;
    Tag: TExifTag;
  begin
    if SavingInfo[Kind].DirectorySize = 0 then Exit;
    Stream.Position := BaseStreamPos + SavingInfo[Kind].StartOffset;
    Stream.WriteWord(Sections[Kind].Count, Endianness);
    NextDataOffset := SavingInfo[Kind].StartOffset + SavingInfo[Kind].DirectorySize;
    for Tag in Sections[Kind] do
      if (Tag = MakerNoteTag) and PreserveMakerNotePos then
        Tag.WriteHeader(Stream, Endianness, MakerNoteDataOffset)
      else
      begin
        Tag.WriteHeader(Stream, Endianness, NextDataOffset);
        if Tag.DataSize > 4 then
        begin
          if (Tag = MakerNoteTag) and (MakerNoteOffsetTag <> nil) then
            Inc(PLongInt(MakerNoteOffsetTag.Data)^, NextDataOffset - Tag.OriginalDataOffset);
          Inc(NextDataOffset, Tag.DataSize);
        end;
    end;
    if (Kind = esGeneral) and (SavingInfo[esThumbnail].DirectorySize <> 0) then
      Stream.WriteLongWord(SavingInfo[esThumbnail].StartOffset, Endianness)
    else
      Stream.WriteLongWord(0, Endianness);
    for Tag in Sections[Kind] do
      if (Tag <> MakerNoteTag) or not PreserveMakerNotePos then
        Tag.WriteOffsettedData(Stream, Endianness);
  end;
var
  Kind: TExifSectionKind;
  ThumbnailImageStream: TMemoryStream;
begin
  if RemovePaddingTagsOnSave then RemovePaddingTags;
  BaseStreamPos := Stream.Position;
  FillChar(OffsetTags, SizeOf(OffsetTags), 0);
  FillChar(SavingInfo, SizeOf(SavingInfo), 0);
  { initialise saving of the easy sections first }
  for Kind in [esInterop, esGPS] do
    InitSavingInfo(Kind, []);
  { initialise saving the details section, including maker note positioning }
  with Sections[esDetails] do
  begin
    MakerNoteOffsetTag := nil;
    PreserveMakerNotePos := Find(ttMakerNote, MakerNoteTag) and
      (MakerNoteTag.OriginalDataOffset <> 0) and (MakerNoteTag.DataSize > 4); //if size is 4 or less, then data isn't offsetted
    if PreserveMakerNotePos then //if Windows has moved it, put the maker note back, else keep it where it is
    begin
      MakerNoteDataOffset := MakerNoteTag.OriginalDataOffset;
      if Find(ttOffsetSchema, MakerNoteOffsetTag) and
         (MakerNoteOffsetTag.DataType = tdLongInt) and (MakerNoteOffsetTag.ElementCount = 1) and
         (MakerNoteDataOffset - PLongInt(MakerNoteOffsetTag.Data)^ > 0) then
      begin
        Dec(MakerNoteDataOffset, PLongInt(MakerNoteOffsetTag.Data)^);
        PLongInt(MakerNoteOffsetTag.Data)^ := 0;
      end
      else
        MakerNoteOffsetTag := nil;
    end;
  end;
  InitSavingInfo(esDetails, [esInterop]);
  if PreserveMakerNotePos then
    Dec(SavingInfo[esDetails].OffsettedDataSize, MakerNoteTag.DataSize);
  { initialise saving the thumbnail section }
  ThumbnailImageStream := nil;
  try
    if HasThumbnail then
    begin
      ThumbnailImageStream := TMemoryStream.Create;
      Thumbnail.SaveToStream(ThumbnailImageStream);
      ThumbnailImageStream.Position := 0;
      ThumbnailImageStream.Size := GetJPEGDataSize(ThumbnailImageStream);
      if ThumbnailImageStream.Size > MaxThumbnailSize then
      begin
        ThumbnailImageStream.Clear;
        {$IF DECLARED(StandardizeThumbnail)}
        StandardizeThumbnail;
        {$IFEND}
        {$IFDEF VCL}
        if Thumbnail.CompressionQuality > 90 then
          Thumbnail.CompressionQuality := 90;
        {$ENDIF}
        Thumbnail.SaveToStream(ThumbnailImageStream);
        Assert(ThumbnailImageStream.Size <= MaxThumbnailSize);
      end;
      with Sections[esThumbnail] do
      begin
        SetWordValue(ttCompression, 0, 6);
        SetLongWordValue(ttThumbnailSize, 0, ThumbnailImageStream.Size);
      end;
      InitSavingInfo(esThumbnail, [esThumbnail]);
      Inc(SavingInfo[esThumbnail].OffsettedDataSize, ThumbnailImageStream.Size);
    end;
    { initialise saving of the general section }
    InitSavingInfo(esGeneral, [esDetails, esGPS]);
    { calculate section positions }
    for Kind := Low(TExifSectionKind) to High(TExifSectionKind) do
    begin
      if Kind = esGeneral then
        SavingInfo[esGeneral].StartOffset := 8
      else
        SavingInfo[Kind].StartOffset := SavingInfo[Pred(Kind)].EndOffsetPlus1;
      if PreserveMakerNotePos and (SavingInfo[Kind].EndOffsetPlus1 > MakerNoteDataOffset) and
         (SavingInfo[Kind].StartOffset < MakerNoteDataOffset + MakerNoteTag.OriginalDataSize) then
        SavingInfo[Kind].StartOffset := MakerNoteDataOffset + MakerNoteTag.OriginalDataSize;
      if (Kind in OffsetSectionKinds) and (OffsetTags[Kind] <> nil) then
        if Kind = esThumbnail then
          PLongWord(OffsetTags[Kind].Data)^ := SavingInfo[Kind].EndOffsetPlus1 - ThumbnailImageStream.Size
        else
          PLongWord(OffsetTags[Kind].Data)^ := SavingInfo[Kind].StartOffset;
    end;
    { let's do the actual writing }
    WriteTiffHeader(Stream, Endianness);
    for Kind := Low(TExifSectionKind) to High(TExifSectionKind) do
      WriteDirectory(Kind);
    if ThumbnailImageStream <> nil then
      Stream.WriteBuffer(ThumbnailImageStream.Memory^, ThumbnailImageStream.Size);
    if PreserveMakerNotePos then
    begin
      Stream.Position := BaseStreamPos + MakerNoteDataOffset;
      Stream.WriteBuffer(MakerNoteTag.Data^, MakerNoteTag.DataSize);
    end;
  finally
    ThumbnailImageStream.Free;
  end;
end;

class function TExifData.SectionClass: TExifSectionClass;
begin
  Result := TExtendableExifSection;
end;

{$IFDEF VCL}

{ TJPEGImageEx }

type
  TIPTCDataAccess = class(TIPTCData);

constructor TJPEGImageEx.Create;
begin
  inherited;
  FExifData := TExifData.Create;
  FExifData.OnChange := Changed;
  FIPTCData := TIPTCData.Create;
end;

destructor TJPEGImageEx.Destroy;
begin
  FIPTCData.Free;
  FExifData.Free;
  inherited;
end;

procedure TJPEGImageEx.Assign(Source: TPersistent);
begin
  inherited;
  if not (Source is TBitmap) then
    ReloadTags
  else
  begin //don't cause a compress operation
    FExifData.Clear;
    FIPTCData.Clear;
  end;
  FChangedSinceLastLoad := False;
end;

procedure TJPEGImageEx.Assign(Source: TBitmap; Options: TAssignOptions);
var
  I: Integer;
  SavedSegments: TInterfaceList;
  Segment: IFoundJPEGSegment;
  InStream, OutStream: TMemoryStream;
begin
  if not (jaPreserveMetadata in Options) then
  begin
    Assign(Source);
    Exit;
  end;
  SavedSegments := nil;
  OutStream := nil;
  InStream := TMemoryStream.Create;
  try
    SaveToStream(InStream);
    InStream.Position := 0;
    SavedSegments := TInterfaceList.Create;
    for Segment in JPEGHeader(InStream, [jmApp1..jmAppSpecificLast]) do
      SavedSegments.Add(Segment);
    InStream.Clear;
    inherited Assign(Source);
    inherited SaveToStream(InStream);
    InStream.Position := 0;
    OutStream := TMemoryStream.Create;
    for Segment in JPEGHeader(InStream, [jmJFIF]) do
    begin
      OutStream.WriteBuffer(InStream.Memory^, Segment.Offset + Segment.TotalSize);
      for I := 0 to SavedSegments.Count - 1 do
        WriteJPEGSegment(OutStream, SavedSegments[I] as IJPEGSegment);
      OutStream.CopyFrom(InStream, InStream.Size - InStream.Position);
      OutStream.Position := 0;
      LoadFromStream(OutStream);
      Exit;
    end;
    Assert(False, 'No JFIF segment!'); //needs to be handled properly if change Source to TPersistent
    //InStream.Position := SizeOf(JPEGFileHeader);
  finally
    SavedSegments.Free;
    InStream.Free;
    OutStream.Free;
  end;
end;

procedure TJPEGImageEx.Changed(Sender: TObject);
begin
  FChangedSinceLastLoad := True;
  inherited;
end;

procedure TJPEGImageEx.CreateThumbnail(ThumbnailWidth, ThumbnailHeight: Integer);
begin
  if Empty then
    FExifData.Thumbnail := nil
  else
    CreateExifThumbnail(Self, FExifData.Thumbnail, ThumbnailWidth, ThumbnailHeight);
end;

procedure TJPEGImageEx.CreateThumbnail;
begin
  CreateThumbnail(StandardExifThumbnailWidth, StandardExifThumbnailHeight);
end;

function TJPEGImageEx.Segments(MarkersToLookFor: TJPEGMarkers): IJPEGHeaderParser;
begin
  Result := JPEGHeader(Self, MarkersToLookFor);
end;

function TJPEGImageEx.GetXMPPacket: TXMPPacket;
begin
  Result := FExifData.XMPPacket;
end;

procedure TJPEGImageEx.LoadFromStream(Stream: TStream);
begin
  inherited;
  ReloadTags;
end;

procedure TJPEGImageEx.ReadData(Stream: TStream);
begin
  inherited;
  ReloadTags;
end;

procedure TJPEGImageEx.ReloadTags;
var
  MemStream: TMemoryStream;
begin
  if Empty then
  begin
    FExifData.Clear;
    FIPTCData.Clear;
  end
  else
  begin
    MemStream := TMemoryStream.Create;
    try
      inherited SaveToStream(MemStream);
      MemStream.Position := 0;
      FExifData.LoadFromGraphic(MemStream);
      MemStream.Position := 0;
      FIPTCData.LoadFromGraphic(MemStream);
    finally
      MemStream.Free;
    end;
  end;
  FChangedSinceLastLoad := False;
end;

function TJPEGImageEx.RemoveMetadata(Kinds: TJPEGMetadataKinds): TJPEGMetadataKinds;
begin
  Result := RemoveMetadataFromJPEG(Self, Kinds);
end;

function TJPEGImageEx.RemoveSegments(Markers: TJPEGMarkers): TJPEGMarkers;
begin
  Result := RemoveJPEGSegments(Self, Markers);
end;

procedure TJPEGImageEx.SaveToStream(Stream: TStream);
var
  MemStream1, MemStream2: TMemoryStream;
begin
  if not FChangedSinceLastLoad or Empty then
  begin
    inherited;
    Exit;
  end;
  MemStream1 := TMemoryStream.Create;
  MemStream2 := TMemoryStream.Create;
  try
    inherited SaveToStream(MemStream1);
    MemStream1.Position := 0;
    FExifData.OnChange := nil; //the ExifImageWidth/Height properties may be updated when saving
    FExifData.DoSaveToJPEG(MemStream1, MemStream2);
    MemStream2.Position := 0;
    TIPTCDataAccess(FIPTCData).DoSaveToJPEG(MemStream2, Stream);
  finally
    FExifData.OnChange := Changed;
    MemStream1.Free;
    MemStream2.Free;
  end;
end;
{$ENDIF}

{ TExifMakerNote }

constructor TExifMakerNote.Create(ASection: TExifSection);
var
  BasePosition: Int64;
  HeaderSize: Integer;
  InternalOffset: Int64;
  SourceTag: TExifTag;
  Stream: TUserMemoryStream;
begin
  inherited Create;
  FTags := ASection;
  if ClassType = TUnrecognizedMakerNote then Exit;
  if not ASection.Owner[esDetails].Find(ttMakerNote, SourceTag) or not FormatIsOK(SourceTag,
    HeaderSize) then raise EInvalidMakerNoteFormat.CreateRes(@SInvalidMakerNoteFormat);
  FDataOffsetsType := doFromExifStart;
  FEndianness := Tags.Owner.Endianness;
  GetIFDInfo(SourceTag, FEndianness, FDataOffsetsType);
  case FDataOffsetsType of
    doCustomFormat: Exit;
    doFromExifStart: BasePosition := -SourceTag.OriginalDataOffset;
    doFromIFDStart: BasePosition := HeaderSize;
    doFromMakerNoteStart: BasePosition := 0;
  else
    raise EProgrammerNotFound.CreateRes(@SRangeError);
  end;
  if FDataOffsetsType = doFromIFDStart then
    InternalOffset := -8
  else
    InternalOffset := Tags.Owner.OffsetSchema;
  Stream := TUserMemoryStream.Create(SourceTag.Data, SourceTag.DataSize);
  try
    Tags.Load(ParseTiffDirectory(Stream, FEndianness, BasePosition,
      HeaderSize - BasePosition, InternalOffset), False);
    { When edited in Vista's Explorer, Exif data are *always* re-written in big endian
      format. Since MakerNotes are left 'as is', however, this means a parser can't rely
      on the container's endianness to determine the endianness of the MakerNote. So, if
      we get tag header load errors with the endianness suggested by GetIFDInfo, we'll
      try the other one too. }
    if (Tags.Count = 0) or ((Tags.LoadErrors <> []) and
      not (leBadOffset in Tags.LoadErrors) and (Tags.Count < 3)) then
    begin
      if FEndianness = SmallEndian then
        FEndianness := BigEndian
      else
        FEndianness := SmallEndian;
      Tags.Load(ParseTiffDirectory(Stream, FEndianness, BasePosition,
        HeaderSize - BasePosition, InternalOffset), False);
      if Tags.LoadErrors <> [] then Tags.Clear;
      if Tags.Count = 0 then Tags.LoadErrors := [leBadOffset];
    end;
  finally
    Stream.Free;
  end;
end;

class function TExifMakerNote.FormatIsOK(SourceTag: TExifTag): Boolean;
var
  HeaderSize: Integer;
begin
  Result := (SourceTag.DataType = tdUndefined) and (SourceTag.ElementCount >= 2) and
    FormatIsOK(SourceTag, HeaderSize);
end;

procedure TExifMakerNote.GetIFDInfo(SourceTag: TExifTag;
  var ProbableEndianness: TEndianness; var DataOffsetsType: TExifDataOffsetsType);
begin
end;

function TExifMakerNote.GetFractionValue(TagID: Integer): TExifFraction;
begin
  if (TagID >= Low(TTiffTagID)) and (TagID <= Low(TTiffTagID)) then
    Result := Tags.GetFractionValue(TTiffTagID(TagID), 0, NullFraction)
  else
    Result := NullFraction;
end;

function TExifMakerNote.GetTagAsString(TagID: Integer): string;
var
  Tag: TExifTag;
begin
  if (TagID >= Low(TTiffTagID)) and (TagID <= High(TTiffTagID)) and Tags.Find(TagID, Tag) then
    Result := Tag.AsString
  else
    Result := '';
end;

{ TUnrecognizedMakerNote }

class function TUnrecognizedMakerNote.FormatIsOK(SourceTag: TExifTag; out HeaderSize: Integer): Boolean;
begin
  Result := False;
end;

{ THeaderlessMakerNote }

class function THeaderlessMakerNote.FormatIsOK(SourceTag: TExifTag; out HeaderSize: Integer): Boolean;
begin
  HeaderSize := 0;
  Result := True;
end;

{ TCanonMakerNote }

class function TCanonMakerNote.FormatIsOK(SourceTag: TExifTag; out HeaderSize: Integer): Boolean;
begin
  HeaderSize := 0;
  Result := (SourceTag.Section.Owner.CameraMake = 'Canon'); //as no header, we'll look for something else
end;

procedure TCanonMakerNote.GetIFDInfo(SourceTag: TExifTag;
  var ProbableEndianness: TEndianness; var DataOffsetsType: TExifDataOffsetsType);
begin
  ProbableEndianness := SmallEndian;
end;

{ TKodakMakerNote }

class function TKodakMakerNote.FormatIsOK(SourceTag: TExifTag;
  out HeaderSize: Integer): Boolean;
begin
  HeaderSize := HeaderSize;
  Result := (SourceTag.ElementCount > HeaderSize) and
    (StrLComp(PAnsiChar(SourceTag.Data), 'KDK', 3) = 0);
end;

procedure TKodakMakerNote.GetIFDInfo(SourceTag: TExifTag;
  var Endianness: TEndianness; var DataOffsetsType: TExifDataOffsetsType);
var
  Buffer: array[Byte] of Byte;
  I: TTiffTagID;
begin
  DataOffsetsType := doCustomFormat;
  if CompareMem(SourceTag.Data, @BigEndianHeader, HeaderSize) then
    Endianness := BigEndian
  else
    Endianness := SmallEndian;
  Tags.Clear;
  SourceTag.DataStream.Position := HeaderSize;
  InitializeTagSpecs;
  for I := Low(TagSpecs) to High(TagSpecs) do
    if SourceTag.DataStream.TryReadBuffer(Buffer,
      TiffElementSizes[TagSpecs[I].DataType] * TagSpecs[I].ElementCount) then
    begin
      Tags.Add(I, TagSpecs[I].DataType, TagSpecs[I].ElementCount).UpdateData(Buffer);
      //SourceTag.DataStream.Seek(TiffElementSizes[DataType] mod 4, soCurrent); //fields aligned on 4 byte boundaries
    end
    else
    begin
      Tags.LoadErrors := [leBadOffset];
      Exit;
    end;
end;

constructor TKodakMakerNote.TTagSpec.Create(ADataType: TTiffDataType; AElementCount: Byte);
begin
  DataType := ADataType;
  ElementCount := AElementCount;
end;

class procedure TKodakMakerNote.InitializeTagSpecs;
begin
  if TagSpecs <> nil then Exit;
  SetLength(TagSpecs, 6);
  TagSpecs[0] := TTagSpec.Create(tdAscii, 8);//model
  TagSpecs[1] := TTagSpec.Create(tdByte);    //quality
  TagSpecs[2] := TTagSpec.Create(tdByte, 2); //burst mode + 1 byte padding
  TagSpecs[3] := TTagSpec.Create(tdWord); //width
  TagSpecs[4] := TTagSpec.Create(tdWord); //height
  TagSpecs[5] := TTagSpec.Create(tdWord); //year
end;

{ TPanasonicMakerNote }

class function TPanasonicMakerNote.FormatIsOK(SourceTag: TExifTag;
  out HeaderSize: Integer): Boolean;
begin
  HeaderSize := SizeOf(Header);
  Result := (SourceTag.ElementCount > HeaderSize) and
    CompareMem(SourceTag.Data, @Header, HeaderSize);
end;

procedure TPanasonicMakerNote.GetIFDInfo(SourceTag: TExifTag;
  var ProbableEndianness: TEndianness; var DataOffsetsType: TExifDataOffsetsType);
begin
  ProbableEndianness := SmallEndian;
end;

{ TPentaxMakerNote }

class function TPentaxMakerNote.FormatIsOK(SourceTag: TExifTag;
  out HeaderSize: Integer): Boolean;
begin
  HeaderSize := SizeOf(Header);
  Result := (SourceTag.ElementCount > HeaderSize) and
    CompareMem(SourceTag.Data, @Header, HeaderSize);
end;

{ TNikonType1MakerNote }

class function TNikonType1MakerNote.FormatIsOK(SourceTag: TExifTag;
  out HeaderSize: Integer): Boolean;
begin
  HeaderSize := SizeOf(Header);
  Result := (SourceTag.ElementCount > HeaderSize) and
    CompareMem(SourceTag.Data, @Header, HeaderSize);
end;

{ TNikonType2MakerNote }

class function TNikonType2MakerNote.FormatIsOK(SourceTag: TExifTag;
  out HeaderSize: Integer): Boolean;
begin
  HeaderSize := 0;
  Result := StartsStr('NIKON', SourceTag.Section.Owner.CameraMake); //can be NIKON or NIKON CORPORATION
end;

{ TNikonType3MakerNote }

class function TNikonType3MakerNote.FormatIsOK(SourceTag: TExifTag;
  out HeaderSize: Integer): Boolean;
begin
  HeaderSize := 18;
  Result := (SourceTag.ElementCount > HeaderSize) and
    CompareMem(SourceTag.Data, @HeaderStart, SizeOf(HeaderStart));
end;

procedure TNikonType3MakerNote.GetIFDInfo(SourceTag: TExifTag;
  var ProbableEndianness: TEndianness; var DataOffsetsType: TExifDataOffsetsType);
var
  SeekPtr: PAnsiChar;
begin
  SeekPtr := SourceTag.Data;
  if (SeekPtr[10] = 'M') and (SeekPtr[11] = 'M') then
    ProbableEndianness := BigEndian
  else
    ProbableEndianness := SmallEndian;
  DataOffsetsType := doFromIFDStart;
end;

{ TSonyMakerNote }

class function TSonyMakerNote.FormatIsOK(SourceTag: TExifTag;
  out HeaderSize: Integer): Boolean;
begin
  HeaderSize := 12;
  Result := (SourceTag.ElementCount > HeaderSize) and
    CompareMem(SourceTag.Data, @Header, SizeOf(Header));
end;

procedure TSonyMakerNote.GetIFDInfo(SourceTag: TExifTag;
  var ProbableEndianness: TEndianness; var DataOffsetsType: TExifDataOffsetsType);
begin
  if SourceTag.Section.Owner.CameraModel = 'DSLR-A100' then
    ProbableEndianness := BigEndian
  else
    ProbableEndianness := SmallEndian;
end;

{$IFDEF DummyTJpegImage}
constructor TJPEGImage.Create;
begin
  inherited Create;
  FData := TMemoryStream.Create;
end;

destructor TJPEGImage.Destroy;
begin
  FData.Free;
  inherited Destroy;
end;

procedure TJPEGImage.Assign(Source: TPersistent);
var
  SourceIntf: IStreamPersist;
begin
  if Source = nil then
  begin
    if FData.Size = 0 then Exit;
    FData.Clear;
    Changed;
    Exit;
  end;
  if Supports(Source, IStreamPersist, SourceIntf) then
  begin
    FData.Clear;
    SourceIntf.SaveToStream(FData);
    Changed;
    Exit;
  end;
  inherited;
end;

procedure TJPEGImage.AssignTo(Dest: TPersistent);
var
  DestIntf: IStreamPersist;
  TempStream: TMemoryStream;
begin
  if Supports(Dest, IStreamPersist, DestIntf) then
  begin
    TempStream := TMemoryStream.Create;
    try
      SaveToStream(TempStream);
      TempStream.Position := 0;
      DestIntf.LoadFromStream(TempStream);
    finally
      TempStream.Free;
    end;
    Exit;
  end;
  inherited;
end;

procedure TJPEGImage.Changed;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TJPEGImage.GetEmpty: Boolean;
begin
  Result := (FData.Size = 0);
end;

function TJPEGImage.GetWidth: Integer;
begin
  SizeFieldsNeeded;
  Result := FWidth;
end;

function TJPEGImage.GetHeight: Integer;
begin
  SizeFieldsNeeded;
  Result := FHeight;
end;

procedure TJPEGImage.LoadFromStream(Stream: TStream);
var
  JpegSize: Int64;
begin
  JpegSize := GetJPEGDataSize(Stream);
  if (JpegSize = 0) and (FData.Size = 0) then Exit;
  FWidth := 0;
  FData.Size := JpegSize;
  Stream.ReadBuffer(FData.Memory^, JpegSize);
  Changed;
end;

procedure TJPEGImage.SaveToStream(Stream: TStream);
begin
  if FData.Size <> 0 then
  begin
    Stream.WriteBuffer(FData.Memory^, FData.Size);
    Exit;
  end;
  WriteJPEGFileHeader(Stream);
  Stream.WriteByte(jmEndOfImage);
end;

procedure TJPEGImage.SizeFieldsNeeded;
var
  Header: PJPEGStartOfFrameData;
  Segment: IFoundJPEGSegment;
begin
  if (FWidth <> 0) or (FData.Size = 0) then Exit;
  FData.Position := 0;
  for Segment in JPEGHeader(FData, TJPEGSegment.StartOfFrameMarkers) do
    if Segment.Data.Size > SizeOf(TJPEGStartOfFrameData) then
    begin
      Header := Segment.Data.Memory;
      FWidth := Header.ImageWidth;
      FHeight := Header.ImageWidth;
      Exit;
    end;
end;
{$ENDIF}

initialization
  TCustomExifData.FMakerNoteClasses := TList.Create;
  TCustomExifData.FMakerNoteClasses.Add(TNikonType2MakerNote);
  TCustomExifData.FMakerNoteClasses.Add(TCanonMakerNote);
  TCustomExifData.FMakerNoteClasses.Add(TPentaxMakerNote);
  //TCustomExifData.FMakerNoteClasses.Add(TKodakMakerNote);
  TCustomExifData.FMakerNoteClasses.Add(TSonyMakerNote);
  TCustomExifData.FMakerNoteClasses.Add(TNikonType1MakerNote);
  TCustomExifData.FMakerNoteClasses.Add(TNikonType3MakerNote);
  TCustomExifData.FMakerNoteClasses.Add(TPanasonicMakerNote);
finalization
  TCustomExifData.FMakerNoteClasses.Free;
end.
