unit graberU;

interface

uses Classes, Types, Messages, Windows, SysUtils, SyncObjs, Variants, VarUtils,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  MyXMLParser, DateUtils, IdException, MyHTTP, IdHTTPHeaderInfo, StrUtils, DB,
  IdStack, idSocks, IdSSLOpenSSL, Math, Dialogs, CCR.EXIF, CCR.EXIF.XMPUtils,
  ThreadUtils, IdExceptionCore, zLib, pac;

const
  UNIQUE_ID = 'GRABER2LOCK';

  CM_EXPROW = WM_USER + 1;
  CM_NEWLIST = WM_USER + 2;
  CM_APPLYNEWLIST = WM_USER + 3;
  CM_CANCELNEWLIST = WM_USER + 4;
  CM_EDITLIST = WM_USER + 5;
  CM_APPLYEDITLIST = WM_USER + 6;
  CM_CLOSETAB = WM_USER + 7;
  CM_SHOWSETTINGS = WM_USER + 8;
  CM_APPLYSETTINGS = WM_USER + 9;
  CM_CANCELSETTINGS = WM_USER + 10;
  CM_STARTJOB = WM_USER + 11;
  CM_ENDJOB = WM_USER + 12;
  CM_LANGUAGECHANGED = WM_USER + 15;
  CM_WHATSNEW = WM_USER + 16;
  CM_STYLECHANGED = WM_USER + 17;
  CM_REFRESHRESINFO = WM_USER + 18;
  CM_REFRESHPIC = WM_USER + 19;
  CM_MENUSTYLECHANGED = WM_USER + 20;
  CM_JOBPROGRESS = WM_USER + 21;
  CM_LOGMODECHANGED = WM_USER + 22;
  CM_LOADLIST = WM_USER + 23;
  CM_CHANGELIST = WM_USER + 24;

  THREAD_STOP = 0;
  THREAD_START = 1;
  THREAD_FINISH = 2;
  THREAD_PROCESS = 3;
  THREAD_COMPLETE = 4;
  THREAD_DOAGAIN = 5;

  JOB_ERROR = 255;
  JOB_NOJOB = 0;
  JOB_LIST = 1;
  JOB_PICS = 2;
  JOB_FINISHED = 3;
  JOB_INPROGRESS = 4;
  JOB_STOPLIST = 5;
  JOB_STOPPICS = 6;
  JOB_SKIP = 7;
  JOB_CANCELED = 8;
  JOB_LOGIN = 9;
  JOB_RESTART = 10;
  JOB_POSTPROCESS = 11;
  JOB_REFRESH = 12;
  JOB_DELAY = 13;
  JOB_POSTFINISHED = 14;
  JOB_POSTPROCINPROGRESS = 15;
  JOB_BLACKLISTED = 16;

  SAVEFILE_VERSION: Integer = 0;

  LIST_SCRIPT = 'listscript'; // default section for getting list script
  DOWNLOAD_SCRIPT = 'dwscript'; // default section for download picture script

type
  doublestring = record
    val1, val2: string;
  end;

  TArrayOfString = array of doublestring;
  TBoolProcedureOfObject = procedure(Value: Boolean = false) of object;
  TLogEvent = procedure(Sender: TObject; Msg: String; Data: Pointer) of object;
  tSemiListJob = (sljNone, sljPostProc, sljPics);
  tPostProcJob = (ppjNone, ppjJob, ppjDelayed);
  tProxyType = (ptHTTP, ptSOCKS4, ptSOCKS5);

  tEXIFRec = record
    UseEXIF: Boolean;
    Author: String;
    Title: String;
    Theme: String;
    Score: String;
    Keywords: String;
    Comment: String;
  end;

  TProxyRec = record
    ptype: tProxyType;
    UseProxy: byte;
    Host: string;
    Port: longint;
    Auth: Boolean;
    Login: string;
    Password: string;
    SavePWD: Boolean;
    UsePAC: Boolean;
    PACHost: String;
  end;

  TDownloadRec = record
    ThreadCount: Integer;
    UsePerRes: Boolean;
    PerResThreads: Integer;
    PicThreads: Integer;
    Retries: Integer;
    // Interval: integer;
    // BeforeU: boolean;
    // BeforeP: boolean;
    // AfterP: boolean;
    Debug: Boolean;
    // SDALF: Boolean;
    AutoUncheckInvisible: Boolean;
  end;

  TGUISettings = record
    NewListFavorites: Boolean;
    NewListShowHint: Boolean;
    FormWidth, FormHeight: Integer;
    PanelPage: Integer;
    PanelWidth: Integer;
    FormState: Boolean;
    LastUsedSet: string;
    LastUsedFields: String;
    LastUsedGrouping: String;
  end;

  TSettingsRec = record
    GUI: TGUISettings;
    Proxy: TProxyRec;
    Downl: TDownloadRec;
    // Formats: TFormatRec;
    AutoUPD: Boolean;
    IncSkins: Boolean;
    CHKServ: String;
    UPDServ: String;
    OneInstance: Boolean;
    TrayIcon: Boolean;
    HideToTray: Boolean;
    SaveConfirm: Boolean;
    ShowWhatsNew: Boolean;
    UseLookAndFeel: Boolean;
    SkinName: String;
    IsNew: Boolean;
    MenuCaptions: Boolean;
    Tips: Boolean;
    UseDist: Boolean;
    UseBlackList: Boolean;
    WriteEXIF: Boolean;
    SemiJob: tSemiListJob;
    UncheckBlacklisted: Boolean;
    StopSignalTimer: Integer;
  end;

  TScriptsRec = record
    Login: String;
    List: String;
    Download: String;
  end;

  TPicNameTemplate = record
    Name: string;
    Ext: string;
    ExtFromHeader: Boolean;
  end;

  TTagTemplate = record
    Spacer: String;
    Separator: String;
    Isolator: String;
  end;

  THTTPMethod = (hmGet, hmPost);

  THTTPRec = record
    // UseProxy: shortint;
    DefUrl: String;
    Url: string;
    Post: String;
    Referer: string;
    ParseMethod: string;
    JSONItem: String;
    CookieStr: string;
    LoginStr: string;
    LoginPost: string;
    LoginResult: Boolean;
    UseTryExt: Boolean;
    TryExt: string;
    Encoding: TEncoding;
    PicTemplate: TPicNameTemplate;
    TagTemplate: TTagTemplate;
    EXIFTemplate: tEXIFRec;
    Method: THTTPMethod;
    StartCount, MaxCount, AddToMax, Count: Integer;
    Theor: word;
    PageByPage: Boolean;
    TryAgain: Boolean;
    AcceptError: Boolean;
    PageDelay: Integer;
    PicDelay: Integer;
    DelayPostProc: Boolean;
    AddUnchecked: Boolean;
    // CheckFNameExt: Boolean;
  end;

  TPicChange = (pcProgress, pcSize, pcLabel, pcDelete, pcChecked, pcData);

  TPicChanges = Set of TPicChange;

  TCallBackProgress = procedure(aPos, aMax: int64; var Cancel: Boolean) of object;

  // TXMPPacketHelper = class(TXMPPacket)
  // public
  // property UpdatePolicy;
  // end;

  TTagedListValue = class(TObject)
  private
    FName: String;
    FValue: Pointer;
  public
    property Name: String read FName write FName;
    property Value: Pointer read FValue write FValue;
  end;

  TTagedList = class(TList)
  private
    FNodouble: Boolean;
  protected
    function Get(Index: Integer): TTagedListValue;
    function GetValue(ItemName: String): Pointer;
    procedure SetValue(ItemName: String; Value: Pointer);
    function FindItem(ItemName: String): TTagedListValue;
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    destructor Destroy; override;
    procedure Assign(List: TTagedList; AOperator: TListAssignOp = laCopy);
    constructor Create;
    // procedure Add(ItemName: String; Value: Variant);
    property Items[Index: Integer]: TTagedListValue read Get;
    property ItemByName[ItemName: String]: TTagedListValue read FindItem;
    property Values[ItemName: String]: Pointer read GetValue
      write SetValue; default;
    property Count;
    property NoDouble: Boolean read FNodouble write FNodouble;
  end;

  // TListValue

  TListValue = class(TTagedListValue)
  private
    FMy: Boolean;
  protected
    function GetValue: Variant;
    procedure SetValue(Value: Variant);
    function GetLink: PVariant;
    procedure SetLink(Value: PVariant);
  public
    constructor Create;
    destructor Destroy; override;
    property Value: Variant read GetValue write SetValue;
    property ValueLink: PVariant read GetLink write SetLink;
  end;

  TValueList = class(TTagedList)
  protected
    function Get(ItemIndex: Integer): TListValue;
    function GetValue(ItemName: String): Variant;
    procedure SetValue(ItemName: String; Value: Variant);
    procedure Assign(List: TValueList; AOperator: TListAssignOp = laCopy);
    function GetLink(ItemName: String): PVariant;
    procedure SetLink(ItemName: String; Value: PVariant); // Dispose OLD VALUE
  public
    procedure SaveToStream(fStream: tStream);
    property Items[ItemIndex: Integer]: TListValue read Get;
    property Values[ItemName: String]: Variant read GetValue
      write SetValue; default;
    property Links[ItemName: String]: PVariant read GetLink write SetLink;

  end;

  TMetaList = class(TList)
  private
    FType: DB.TFieldType;
    FVariantType: TVarType;
    procedure SetValueType(Value: DB.TFieldType);
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    function FindPosition(Value: Variant; var i: Integer): Boolean;
    function Add(Value: Variant; Pos: Integer): PVariant;
    destructor Destroy; override;
    property ValueType: DB.TFieldType read FType write SetValueType;
    property VariantType: TVarType read FVariantType;
  end;

  TScriptSection = class;
  TScriptItemList = class;

  TScriptItemKind = (sikNone, sikProcedure, sikDecloration, sikSection,
    sikCondition, sikCycle, sikGroup);

  TScriptEvent = function(const Item: TScriptSection;
    const parameters: TValueList; LinkedObj: TObject; var ResultObj: TObject)
    : Boolean of object;

  TValueEvent = procedure(ItemName: String; var Result: Variant;
    var LinkedObj: TObject) of object;

  TDeclorationEvent = procedure(ItemName: String; ItemValue: Variant;
    LinkedObj: TObject) of object;

  TFinishEvent = procedure(const Item: TScriptSection; LinkedObj: TObject)
    of object;

  TScriptItem = class(TObject)
  private
    FName: String;
    FValue: Variant;
    FKind: TScriptItemKind;
  public
    procedure Assign(s: TScriptItem); virtual;
    function AsString(level: byte = 0): String; virtual;
    property Kind: TScriptItemKind read FKind write FKind;
    property Name: String read FName write FName;
    property Value: Variant read FValue write FValue;
  end;

  PWorkItem = ^TWorkItem;

  TWorkItem = record
    Section: TScriptSection;
    Obj: TObject;
  end;

  TWorkList = class(TList)
  protected
    function Get(Index: Integer): PWorkItem;
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    function Add(Section: TScriptSection; Obj: TObject): Integer;
    destructor Destroy; override;
    property Items[Index: Integer]: PWorkItem read Get;
  end;

  TScriptSection = class(TScriptItem)
  private
    Fparameters: TValueList;
    FChildSections: TScriptItemList;
    FNoParam: Boolean;
    FInUse: Boolean;
    fSectionName: String;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ParseValues(s: string);
    procedure Process(const SE: TScriptEvent; const DE: TDeclorationEvent;
      FE: TFinishEvent; const VE: TValueEvent; PVE: TValueEvent = nil;
      LinkedObj: TObject = nil);
    procedure Clear;
    procedure Assign(s: TScriptItem); override;
    function Empty: Boolean;
    function AsString(level: byte = 0): String; override;
    procedure SaveToFile(FName: string);
    property parameters: TValueList read Fparameters;
    property ChildSections: TScriptItemList read FChildSections;
    property NoParameters: Boolean read FNoParam write FNoParam;
    property InUse: Boolean read FInUse;
    property SectionName: String read fSectionName write fSectionName;
  end;

  TScriptItemList = class(TList)
  private
    function Get(Index: Integer): TScriptItem;
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    procedure Assign(s: TScriptItemList);
    destructor Destroy; override;
    function AsString(level: byte = 0): String;
    property Items[Index: Integer]: TScriptItem read Get; default;
  end;

  TDownloadThread = class;
  TResourceLinkList = class;
  TResource = class;
  TTPicture = class;
  TPictureLinkList = class;
  TPictureList = class;
  // TResource = class;

  TFieldType = (ftNone, ftString, ftPassword, ftNumber, ftFloatNumber, ftCombo,
    ftIndexCombo, ftCheck, ftPathText, ftTagText, ftMultiEdit, ftCSVList);

  PResourceField = ^TResourceField;

  TResourceField = record
    InMulti: Boolean;
    resname: string;
    restitle: string;
    restype: TFieldType;
    resvalue: Variant;
    resitems: string;
  end;

  TResourceFields = class(TList)
  protected
    function Get(Index: Integer): PResourceField;
    // procedure Put(Index: integer; Value: TResourceField);
    function GetValue(ItemName: String): Variant;
    procedure SetValue(ItemName: String; Value: Variant);
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    procedure Assign(List: TResourceFields; AOperator: TListAssignOp = laCopy);
    function AddField(resname: string; restitle: string; restype: TFieldType;
      resvalue: Variant; resitems: String; InMulti: Boolean): Integer;
    function FindField(resname: String): Integer;
    destructor Destroy; override;
    property Items[Index: Integer]: PResourceField read Get { write Put };
    property Values[ItemName: String]: Variant read GetValue
      write SetValue; default;
  end;

  TThreadEvent = function(t: TDownloadThread): Integer of object;

  TDownloadThread = class(TThread)
  private
    FHTTP: TMyIdHTTP;
    FEventHandle: THandle;
    FSSLHandler: TIdSSLIOHandlerSocketOpenSSL;
    FJob: Integer;
    // FThreadJob: integer;
    FJobComplete: TThreadEvent;
    FFinish: TThreadEvent;
    FErrorString: String;
    // FErrorCode: integer;
    FInitialScript: TScriptSection;
    FBeforeScript: TScriptSection;
    FAfterScript: TScriptSection;
    FXMLScript: TScriptSection;
    FErrorScript: TScriptSection;
    FPostProc: TScriptSection;
    FFields: TResourceFields;
    FDownloadRec: TDownloadRec;
    FHTTPRec: THTTPRec;
    FPicList: TPictureList;
    FLPicList: TPictureList;
    FSectors: TValueList;
    FXML: TMyXMLParser;
    FPicture: TTPicture;
    FChild: TTPicture;
    FLnkPic: TTPicture;
    FSTOPERROR: Boolean;
    FJobId: Integer;
    FJobIDX: Integer;
    FCSData: TCriticalSection;
    FCSFiles: TCriticalSection;
    FResource: TResource;
    FMaxRetries: Integer;
    FRetries: Integer;
    FPicsAdded: Boolean;
    FURLList: TArrayOfString;
    FLogMode: Boolean;
    FSkipMe: Boolean;
    fSocksInfo: tidSocksInfo;
    FStopSignal: Boolean;
    fStopSignalTimer: Boolean;
    fStopMessage: String;
    fResultURL: String;
  protected
    procedure SetInitialScript(Value: TScriptSection);
    procedure SetBeforeScript(Value: TScriptSection);
    procedure SetAfterScript(Value: TScriptSection);
    procedure SetXMLScript(Value: TScriptSection);
    procedure SetPostProcScript(Value: TScriptSection);
    procedure SeFields(Value: TResourceFields);
    procedure DoJobComplete;
    procedure DoFinish;
    function SE(const Item: TScriptSection; const parameters: TValueList;
      LinkedObj: TObject; var ResultObj: TObject): Boolean;
    procedure VE(Value: String; var Result: Variant; var LinkedObj: TObject);
    procedure DE(ItemName: String; ItemValue: Variant; LinkedObj: TObject);
    procedure FE(const Item: TScriptSection; LinkedObj: TObject);
    procedure IdHTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: int64);
    procedure IdHTTPWork(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: int64);
    procedure PicChanged;
    procedure ProcHTTP;
    procedure ProcPic;
    procedure ProcLogin;
    function AddURLToList(s: String; Referer: String = ''): Integer;
    procedure ProcPost;
    function TrackRedirect(Url: String): String;
    procedure WriteEXIF(s: tStream);
  public
    procedure Execute; override;
    constructor Create;
    destructor Destroy; override;
    function AddPicture: TTPicture;
    procedure ClonePicture;
    procedure SetSectors(Value: TValueList);
    procedure LockList;
    procedure UnlockList;
    procedure SetHTTPError(s: string);
    function AddChild: TTPicture;
    property HTTP: TMyIdHTTP read FHTTP;
    property SSL: TIdSSLIOHandlerSocketOpenSSL read FSSLHandler;
    property Socks: tidSocksInfo read fSocksInfo;
    property Job: Integer read FJob write FJob;
    property EventHandle: THandle read FEventHandle;
    property Error: String read FErrorString;
    // property ErrorCode: integer read FErrorCode;
    property Finish: TThreadEvent read FFinish write FFinish;
    property InitialScript: TScriptSection read FInitialScript
      write SetInitialScript;
    property BeforeScript: TScriptSection read FBeforeScript
      write SetBeforeScript;
    property AfterScript: TScriptSection read FBeforeScript
      write SetAfterScript;
    property XMLScript: TScriptSection read FXMLScript write SetXMLScript;
    property PostProcessScript: TScriptSection read FPostProc
      write SetPostProcScript;
    property Fields: TResourceFields read FFields write SeFields;
    property DownloadRec: TDownloadRec read FDownloadRec write FDownloadRec;
    property HTTPRec: THTTPRec read FHTTPRec write FHTTPRec;
    property JobComplete: TThreadEvent read FJobComplete write FJobComplete;
    property Sectors: TValueList read FSectors write SetSectors;
    property PictureList: TPictureList read FPicList { write FPictureList };
    property LPictureList: TPictureList read FLPicList write FLPicList;
    property STOPERROR: Boolean read FSTOPERROR write FSTOPERROR;
    property JobId: Integer read FJobId write FJobId;
    property JobIdx: Integer read FJobIDX write FJobIDX;
    property Picture: TTPicture read FPicture write FPicture;
    property LnkPic: TTPicture read FLnkPic write FLnkPic;
    property CSData: TCriticalSection read FCSData write FCSData;
    property CSFiles: TCriticalSection read FCSFiles write FCSFiles;
    property Resource: TResource read FResource write FResource;
    property MaxRetries: Integer read FMaxRetries write FMaxRetries;
    property PicsAdded: Boolean read FPicsAdded;
    property URLList: TArrayOfString read FURLList;
    property LogMode: Boolean read FLogMode write FLogMode;
    property StopSignal: Boolean read FStopSignal;
    property StopMessage: String read fStopMessage;
    property StopSignalTimer: Boolean read fStopSignalTimer;
  end;

  TJobEvent = function(t: TDownloadThread): Boolean of object;

  TThreadHandler = class(TThreadList)
  private
    FCount: Integer;
    FFinishThreads: Boolean;
    FFinishQueue: Boolean;
    FCreateJob: TJobEvent;
    FProxy: TProxyRec;
    FCookie: TMyCookieList;
    fPACParser: tPACParser;
    FOnAllThreadsFinished: TNotifyEvent;
    FOnError: TLogEvent;
    FThreadCount: Integer;
    FCSData: TCriticalSection;
    FCSFiles: TCriticalSection;
    FRetries: Integer;
    FLogMode: Boolean;
    fTag: Integer;
  protected
    function Finish(t: TDownloadThread): Integer;
    procedure CheckIdle(ALL: Boolean = false);
    // procedure AddToQueue(R: TResource);
    procedure ThreadTerminate(ASender: TObject);
    procedure SetProxy(t: TDownloadThread);
  public
    procedure CreateThreads;
    procedure FinishThreads(Force: Boolean = false);
    constructor Create;
    destructor Destroy; override;
    procedure FinishQueue;
    property Finishing: Boolean read FFinishThreads;
    property CreateJob: TJobEvent read FCreateJob write FCreateJob;
    property Count: Integer read FCount;
    property Proxy: TProxyRec read FProxy write FProxy;
    // property SSLProxy: TProxyRec read FProxy write FProxy;
    // property SOCKSProxy: TProxyRec read FProxy write FProxy;
    property Cookies: TMyCookieList read FCookie write FCookie;
    property OnAllThreadsFinished: TNotifyEvent read FOnAllThreadsFinished
      write FOnAllThreadsFinished;
    property OnError: TLogEvent read FOnError write FOnError;
    property ThreadCount: Integer read FThreadCount write FThreadCount;
    property Retries: Integer read FRetries write FRetries;
    property LogMode: Boolean read FLogMode write FLogMode;
    property Tag: Integer read fTag write fTag;
    property PACParser: tPACParser read fPACParser write fPACParser;
    // property FinishThreads: boolean read FFinishThread;
  end;

  TTagAttribute = (taNone, taArtist, taCharacter, taCopyright, taAmbiguous);

  TPictureTag = class(TObject)
  private
    FLinked: TPictureLinkList;
    fTag: Integer;
    fIgnore: Boolean;
    fSaveIndex: Integer;
    FName: String;
    // fAttribute: tAttribute;
  public
    // property Attribute: TTagAttribute read fAttribute write fAttribute;
    property Name: String read FName write FName;
    constructor Create;
    destructor Destroy; override;
    property Linked: TPictureLinkList read FLinked;
    property Tag: Integer read fTag write fTag;
    property Ignore: Boolean read fIgnore write fIgnore;
    property SaveIndex: Integer read fSaveIndex write fSaveIndex;
  end;

  TPictureTagLinkList = class(TList)
  private
    fsearchstack: TPictureTagLinkList;
    fSearchWord: String;
    fInSearch: Boolean;
    fTagTemplate: TTagTemplate;
    // fSpacer: String;
    // fIsolator: String;
    // fSeparator: String;
  protected
    function FindPosition(Value: String; var Index: Integer): Boolean;
    function Get(Index: Integer): TPictureTag;
    procedure Put(Index: Integer; Item: TPictureTag);
  public
    constructor Create;
    function StartSearch(Value: string; fmt: TTagTemplate;
      cnt: Integer = 5): string;
    function ContinueSearch(Value: string; fmt: TTagTemplate;
      cnt: Integer = 5): string;
    destructor Destroy; override;
    procedure Clear; override;
    property Items[Index: Integer]: TPictureTag read Get write Put; default;
    property Count;
    function AsString(fmt: TTagTemplate; cnt: Integer = 0;
      List: Boolean = false): String; overload;
    function AsString(cnt: Integer = 0; List: Boolean = false): String;
      overload;
    function AsString(Separator, Isolator, Spacer: string; cnt: Integer = 0;
      List: Boolean = false): String; overload;
    // property Spacer: String read fSpacer write fSpacer;
    // property Isolator: String read fIsolator write fIsolator;
    // property Separator: String read fSeparator write fSeparator;
    property TagTemplate: TTagTemplate read fTagTemplate write fTagTemplate;
    property InSearch: Boolean read fInSearch;
    procedure SaveToStream(fStream: tStream);
  end;

  TTagUpdateEvent = procedure(Sender: TObject; TagList: TPictureTagLinkList)
    of object;

  TPictureTagList = class(TPictureTagLinkList)
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(TagName: String; p: TTPicture = nil): Integer; overload;
    function Add(TagName: String; p: TTPicture; Template: TTagTemplate)
      : Integer; overload;
    function Find(TagName: String): Integer;
    procedure ClearZeros;
    procedure LoadListFromFile(FName: string);
    procedure CopyTagList(t: TPictureTagList);
    procedure SaveToFile(FName: string);
    procedure SavePrepare;
    procedure SaveToStream(fStream: tStream);
    procedure LoadFromStream(fStream: tStream; fversion: Integer);
    property Items;
    property Count;
  end;

  tNameCounter = record
    Counter: word;
    Last: TTPicture;
    First: TTPicture;
  end;

  pNameCounter = ^tNameCounter;

  TPictureEvent = procedure(APicture: TTPicture) of object;
  // TResourcePictureEvent = procedure (AResource: TResource; APicture: TTPicture) of object;
  TPictureNotifyEvent = procedure(Sender: TObject; APicture: TTPicture)
    of object;

  TPicChangeEvent = procedure(APicture: TTPicture; Changes: TPicChanges)
    of object;

  TTPicture = class(TObject)
  private
    FParent: TTPicture;
    FMeta: TValueList;
    FLinked: TPictureLinkList;
    FTags: TPictureTagLinkList;
    FChecked: Boolean;
    FStatus: Integer;
    FRemoved: Boolean;
    // FQueueN: integer;
    FList: TPictureList;
    FResource: TResource;
    fResourceIndex: Integer;
    FDisplayLabel: String;
    FPicName: String;
    FFileName: String;
    FOrigFileName: String;
    FNameCounter: pNameCounter;
    FNameUpdated: Boolean;
    FPrevPic: TTPicture;
    FNextPic: TTPicture;
    FNameNo: Integer;
    FNameRemake: Boolean;
    FFactFileName: String;
    FExt: String;
    FSize: int64;
    FPos: int64;
    FLastPos: int64;
    fDTStart, fDTEnd: TDateTime;

    FPicChange: TPicChangeEvent;
    FChanges: TPicChanges;
    FBookMark: Integer;
    FIndex: Integer;
    FPostProc: Boolean;
    FMD5: PVariant;
    // fSaveIndex: integer;
    // FMD5Double: boolean;
  protected
    procedure SetParent(Item: TTPicture);
    procedure SetRemoved(Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Assign(Value: TTPicture; Links: Boolean = false);
    // procedure MakeFileName(Format: String);
    procedure SetPicName(Value: String);
    procedure MakeMD5(s: tStream);
    procedure DeleteFile;
    procedure SaveToStream(fStream: tStream);
    procedure LoadFromStream(fStream: tStream; fversion: Integer);
    property Removed: Boolean read FRemoved write SetRemoved;
    { removed from list, i.e. deleted and prepare to be freed from memory }
    property Status: Integer read FStatus write FStatus;
    { working status, OK, ERROR etc }
    property Checked: Boolean read FChecked write FChecked;
    property Parent: TTPicture read FParent write SetParent;
    { parent picture aka album }
    property Tags: TPictureTagLinkList read FTags; { picture's tags }
    property Meta: TValueList read FMeta; { picture's metadata (fields) }
    property Linked: TPictureLinkList read FLinked;
    { linked pictures (aka chields) to current picture }
    // property QueueN: integer read FQueueN write FQueueN;       {number in queue}
    property List: TPictureList read FList write FList;
    { main pictures list, when picture in }
    property DisplayLabel: String read FDisplayLabel write FDisplayLabel;
    { name of picture, displayed in table's field "label" }
    property FileName: String read FFileName write FFileName;
    { picture's save name with full path (logical, made BEFORE picture downloaded,
      but AFTER name dublicate search) }
    property OriginalFileName: String read FOrigFileName write FOrigFileName;
    { picture's save name with full path (BEFORE name dublicate search) }
    property FactFileName: String read FFactFileName write FFactFileName;
    { picture's real save name with full path (made AFTER picture downloaded) }
    property Ext: String read FExt; { picture's file's extension }
    property PicName: String read FPicName write SetPicName;
    { picture's "preinstalled" file's name, without ext and path }
    property Resource: TResource read FResource write FResource;
    property ResourceIndex: Integer read fResourceIndex write fResourceIndex;
    { resource picture attached to }
    property Size: int64 read FSize write FSize;
    { pictures' size (sued when downloading) }
    property Pos: int64 read FPos write FPos;
    { picture's current downloaded amount of bytes }
    property Lastpos: int64 read FLastPos write FLastPos;
    { pic's last pos (in prevous size get) }
    property OnPicChanged: TPicChangeEvent read FPicChange write FPicChange;
    property Changes: TPicChanges read FChanges write FChanges;
    { current changes list, sued to update visible data in table }
    property BookMark: Integer read FBookMark write FBookMark;
    { position in table }
    property Index: Integer read FIndex write FIndex;
    { position in pictures list }
    property PostProcessed: Boolean read FPostProc write FPostProc;
    { picture is postprocessed }
    property MD5: PVariant read FMD5;
    { REAL MD5, made AFTER picture is downloaded, but BEFORE saving EXIF }
    property NeedNameRemake: Boolean read FNameRemake write FNameRemake;
    { picture need filename remake AFTER it downloded, i.e. if you need to get ext from header or to get REAL md5 in name }
    property NameCounter: pNameCounter read FNameCounter write FNameCounter;
    { $fn$ counter }
    property NameNo: Integer read FNameNo write FNameNo;
    { number in $fn$ counter }
    property prevPic: TTPicture read FPrevPic write FPrevPic;
    { prev. for curr. pic in $fn$ counter }
    property nextPic: TTPicture read FNextPic write FNextPic;
    { next to curr. pic in $fn$ counter }
    property NameUpdated: Boolean read FNameUpdated write FNameUpdated;
    { source data for filename have been changed and filename should be updated }
    property DTStart: TDateTime read fDTStart write fDTStart;
    property DTEnd: TDateTime read fDTEnd write fDTEnd;
    { index number for saving to the file }
    // property SaveIndex: integer read fSaveIndex write fSaveIndex;
  end;

  TPicCounter = record
    OK, ERR, SKP, UNCH, IGN, EXS, FSH, BLK: word;
  end;

  TPictureLinkList = class(TList)
  private
    FBeforePictureList: TNotifyEvent;
    FAfterPictureList: TNotifyEvent;
    FLinkedOn: TPictureList;
    FFinishCursor: Integer;
    FCursor: Integer;
    FPostCursor: Integer;
    FPostFinishCursor: Integer;
    FPicCounter: TPicCounter;
    FChildMode: Boolean;
    FLastJobIdx: Integer;
    FLastPostJobIdx: Integer;
    FParentCount, FChildCount: Integer;
  protected
    function Get(Index: Integer): TTPicture;
    procedure Put(Index: Integer; Item: TTPicture);
    procedure SetParentsCount(Value: Integer);
    procedure SetChildsCount(Value: Integer);
  public
    procedure BeginAddList;
    procedure EndAddList;
    procedure ResetCursors;
    procedure ResetPicCounter;
    procedure CheckExists;
    procedure RestartCursor(AFrom: Integer = 0);
    procedure RestartPostCursor(AFrom: Integer = 0);
    procedure ResetPost;
    // procedure ResetPost;
    property Items[Index: Integer]: TTPicture read Get write Put; default;
    property OnBeginAddList: TNotifyEvent read FBeforePictureList
      write FBeforePictureList;
    property OnEndAddList: TNotifyEvent read FAfterPictureList
      write FAfterPictureList;
    property Link: TPictureList read FLinkedOn write FLinkedOn;
    function AllFinished(incerrs: Boolean = true;
      incposts: Boolean = false): Boolean;
    function PostProcessFinished: Boolean;
    function NextJob(Status: Integer): TTPicture;
    function NextPostProcJob: TTPicture;
    function eol: Boolean;
    function posteol: Boolean;
    procedure Reset;
    property Cursor: Integer read FCursor;
    property LastJobIdx: Integer read FLastJobIdx;
    property LastPostJobIdx: Integer read FLastPostJobIdx;
    property PostProccessCursor: Integer read FPostCursor;
    property PicCounter: TPicCounter read FPicCounter;
    property ChildMode: Boolean read FChildMode write FChildMode;
    property ParentCount: Integer read FParentCount;
    property ChildCount: Integer read FChildCount;
    procedure SaveToCSV(FName: string); overload;
    procedure SaveToCSV(fStream: tStream); overload;
  end;

  TDoubleString = array [0 .. 1] of String;

  TDSArray = array of TDoubleString;

  TCheckFunction = function(Pic: TTPicture): Boolean of object;
  TSameNamesEvent = procedure(Sender: TObject; FFileName: String);
  TResourceList = class;

  TPictureList = class(TPictureLinkList)
  private
    FTags: TPictureTagList;
    FNameFormat: String;
    FPicChange: TPicChangeEvent;
    FMetaContainer: TTagedList;
    FIgnoreList: TDSArray;
    FUseBlackList: Boolean;
    FBlackList: TDSArray;
    FDoublesTickCount: Integer;
    FDirList: TStringList;
    FFileNames: TStringList;
    FMakeNames: Boolean;
    FSameNames: TSameNamesEvent;
    fResourceList: TResourceList;
    function DirNumber(Dir: String): word;
    procedure disposeDirList;
    procedure SetPicChange(Value: TPicChangeEvent);
    // function fNameNumber(FileName: String): pNameCounter;
    function AddfName(APic: TTPicture; FName: string; InstUp: Boolean)
      : pNameCounter;
    function AddfNamePatch(APic: TTPicture; FName: string; InstUp: Boolean)
      : pNameCounter;
    function fNameDec(APic: TTPicture; FName: string; InstUp: Boolean)
      : pNameCounter;
    function fNamePatchDec(APic: TTPicture; FName: string): pNameCounter;
  protected
    procedure DeallocateMeta;
    procedure AddPicMeta(Pic: TTPicture; MetaName: String; MetaValue: Variant);
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
    property Link;
  public
    constructor Create(makenames: Boolean);
    destructor Destroy; override;
    function Add(APicture: TTPicture; Resource: TResource): Integer;
    procedure AddPicList(APicList: TPictureList; ParentPic: TTPicture = nil);
    function CopyPicture(Pic: TTPicture; Child: Boolean = false): TTPicture;
    function CheckDoubles(Pic: TTPicture): Boolean;
    procedure MakePicFileName(Index: Integer; Format: String; Child: Boolean;
      InstUp: Boolean = false);
    function CheckBlackList(Pic: TTPicture): Boolean;
    procedure SaveToStream(fStream: tStream; fCB: TCallBackProgress);
    procedure LoadFromStream(fStream: tStream; fversion: Integer;
      fCB: TCallBackProgress);
    property Tags: TPictureTagList read FTags;
    property Items;
    property Count;
    property NameFormat: String read FNameFormat write FNameFormat;
    procedure Clear; override;
    property OnPicChanged: TPicChangeEvent read FPicChange write SetPicChange;
    property OnSameFileNames: TSameNamesEvent read FSameNames write FSameNames;
    property IgnoreList: TDSArray read FIgnoreList write FIgnoreList;
    property UseBlackList: Boolean read FUseBlackList write FUseBlackList;
    property BlackList: TDSArray read FBlackList write FBlackList;
    property Meta: TTagedList read FMetaContainer;
    property ParentCount;
    property ChildCount;
    property DoublestickCount: Integer read FDoublesTickCount;
    property makenames: Boolean read FMakeNames;
    property ResourceList: TResourceList read fResourceList write fResourceList;
  end;

  TResourceEvent = procedure(R: TResource) of object;

  TJobRec = record
    // LPic: TTPicture;
    id: Integer;
    Url: string;
    Referer: string;
    // Kind: integer;
    Status: Integer;
  end;

  PJobRec = ^TJobRec;

  TJobList = class(TList)
  private
    FLastAdded: PJobRec;
    FCursor: Integer;
    FFinishCursor: Integer;
    FOkCount: Integer;
    FErrCount: Integer;
  protected
    function Get(Value: Integer): PJobRec;
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    function Add(id: Integer): Integer;
    function AllFinished(incerrs: Boolean = true): Boolean;
    function NextJob(Status: Integer): Integer;
    function LastJob(Status: Integer): Integer;
    function eol: Boolean;
    destructor Destroy; override;
    property Items[Index: Integer]: PJobRec read Get; default;
    procedure Reset;
    procedure Clear; override;
    property Cursor: Integer read FCursor;
    property FinishCursor: Integer read FFinishCursor;
    property ErrorCount: Integer read FErrCount;
    property OkCount: Integer read FOkCount;
  end;

  tGeneralSettings = record
    MaxThreadCount: Integer;
    PicDelay: Integer;
    PageDelay: Integer;
  end;

  pThreadCounter = ^tThreadCounter;

  tThreadCounter = record
    DefinedSettings: tGeneralSettings;
    UseProxy: shortint;
    UserSettings: tGeneralSettings;
    UseUserSettings: Boolean;
    MaxThreadCount: Integer;
    CurrThreadCount: Integer;
    PictureThreadCount: Integer;
    Queue: tThreadQueue;
    // PageDelay: integer;
    // PicDelay: integer;
    CurrentResource: TResource;
    LastPageTime: TDateTime;
    LastPicTime: TDateTime;
  end;

  // tResourceList = class;

  TResource = class(TObject)
  private
    fNew: Boolean;
    FFavorite: Boolean;
    fUserFav: Boolean;
    FCheatSheet: String;
    FKeywordHint: String;
    FFileName: String;
    FResName: String;
    // FURL: String;
    // fSpacer: Char;
    FIconFile: String;
    FShort: String;
    FNameFormat: String;
    FRelogin: Boolean;
    FParent: TResource;
    FMainResource: TResource;
    FLoginPrompt: Boolean;
    FInherit: Boolean;
    FJobInitiated: Boolean;
    FKeepQueue: Boolean;
    FFields: TResourceFields;
    FSectors: TValueList;
    FInitialScript: TScriptSection;
    FBeforeScript: TScriptSection;
    FAfterScript: TScriptSection;
    FXMLScript: TScriptSection;
    FPicScript: TScriptSection;
    FPostProc: TScriptSection;
    FDownloadRec: TDownloadRec;
    FPictureList: TPictureLinkList;
    FScripts: TScriptsRec;
    FHTTPRec: THTTPRec;
    FOnJobFinished: TResourceEvent;
    FOnPicJobFinished: TResourceEvent;
    FPicFieldList: TStringList;
    FCheckIdle: TBoolProcedureOfObject;
    FPicCheckIdle: TBoolProcedureOfObject;
    FNextPage: Boolean;
    FOnError: TLogEvent;
    FThreadCounter: pThreadCounter;
    FJobList: TJobList;
    FOnPageComplete: TNotifyEvent;
    // FTemplateFile: String;
    FKeywordList: TStringList;
    fResourceList: TResourceList;
    fSaveIndex: Integer;
    fLoadFailed: Boolean;
    procedure SetFavorite(Value: Boolean);
  protected
    procedure DeclorationEvent(ItemName: String; ItemValue: Variant;
      LinkedObj: TObject);
    function JobComplete(t: TDownloadThread): Integer;
    function StringFromFile(FName: string): string;
    function PicJobComplete(t: TDownloadThread): Integer;
    function LoginJobComplete(t: TDownloadThread): Integer;
    function PostProcJobComplete(t: TDownloadThread): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadConfigFromFile(FName: String);
    function CreateFullFieldList: TStringList;
    procedure CreateJob(t: TDownloadThread);
    procedure StartJob(JobType: Integer);
    procedure Assign(R: TResource);
    procedure GetSectors(s: string; R: TValueList);
    function CanAddThread: Boolean;
    procedure CreatePicJob(t: TDownloadThread);
    procedure CreateLoginJob(t: TDownloadThread);
    function FormatTagString(Tag: String; OldFormat: TTagTemplate): String;
    function RestoreTagString(Tag: String; NewFormat: TTagTemplate): String;
    procedure CreatePostProcJob(t: TDownloadThread);
    procedure ApplyInherit(R: TResource);
    procedure SetThreadCounter(Value: pThreadCounter);
    procedure FreeThreadCounter;
    function PageDelayed: Boolean;
    function PicDelayed: Boolean;
    procedure SaveToStream(fStream: tStream);
    procedure LoadFromStream(fStream: tStream; fversion: word);
    function ResetRelogin: boolean;
    property CheatSheet: String read FCheatSheet write FCheatSheet;
    property FileName: String read FFileName;
    property Name: String read FResName write FResName;
    // property TemplateFile: String read FTemplateFile;
    // property Url: String read FURL;
    property Relogin: Boolean read FRelogin{ write FRelogin};
    property IconFile: String read FIconFile;
    property Fields: TResourceFields read FFields;
    property Parent: TResource read FParent write FParent;
    property MainResource: TResource read FMainResource write FMainResource;
    property Inherit: Boolean read FInherit write FInherit;
    property KeepQueue: Boolean read FKeepQueue;
    property NameFormat: String read FNameFormat write FNameFormat;
    property Sectors: TValueList read FSectors;
    property LoginPrompt: Boolean read FLoginPrompt;
    property DownloadSet: TDownloadRec read FDownloadRec write FDownloadRec;
    property HTTPRec: THTTPRec read FHTTPRec write FHTTPRec;
    // property UseProxy: shortint read fUseProxy write fUseProxy;
    property ScriptStrings: TScriptsRec read FScripts;
    property PictureList: TPictureLinkList read FPictureList;
    property JobInitiated: Boolean read FJobInitiated;
    property InitialScript: TScriptSection read FInitialScript;
    property BeforeScript: TScriptSection read FBeforeScript;
    property AfterScript: TScriptSection read FBeforeScript;
    property XMLScript: TScriptSection read FXMLScript;
    property PostProcess: TScriptSection read FPostProc;
    // property AddToQueue: TResourceEvent read FAddToQueue write FAddToQueue;
    // property JobFinished: boolean read FJobFinished;
    property OnJobFinished: TResourceEvent read FOnJobFinished
      write FOnJobFinished;
    property OnPicJobFinished: TResourceEvent read FOnPicJobFinished
      write FOnPicJobFinished;
    property PicFieldList: TStringList read FPicFieldList;
    property CheckIdle: TBoolProcedureOfObject read FCheckIdle write FCheckIdle;
    property PicCheckIdle: TBoolProcedureOfObject read FPicCheckIdle
      write FPicCheckIdle;
    property NextPage: Boolean read FNextPage write FNextPage;
    property OnError: TLogEvent read FOnError write FOnError;
    property ThreadCounter: pThreadCounter read FThreadCounter;
    property JobList: TJobList read FJobList;
    property Short: String read FShort;
    property OnPageComplete: TNotifyEvent read FOnPageComplete
      write FOnPageComplete;
    property KeywordList: TStringList read FKeywordList;
    property Favorite: Boolean read FFavorite write SetFavorite;
    property KeywordHint: String read FKeywordHint write FKeywordHint;
    property ResourceList: TResourceList read fResourceList write fResourceList;
    property SaveIndex: Integer read fSaveIndex write fSaveIndex;
    property LoadFailed: Boolean read fLoadFailed;
    property IsNew: Boolean read fNew write fNew;
  end;

  TResourceLinkList = class(TList)
  protected
    function Get(Index: Integer): TResource;
  public
    procedure GetAllResourceFields(List: TStrings);
    procedure GetAllPictureFields(List: TStrings; withparam: Boolean = false);

    property Items[Index: Integer]: TResource read Get; default;
  end;

  TActionNotifyEvent = procedure(Sender: TObject; Action: Integer) of object;

  TResourceMode = (rmNormal, rmLogin { , rmPostProcess } );

  TResourceList = class(TResourceLinkList)
  private
    FThreadHandler: TThreadHandler;
    FDwnldHandler: TThreadHandler;
    FJobChanged: TActionNotifyEvent;
    FQueueIndex: Integer;
    FPicQueue: Integer;
    FPageMode: Boolean;
    FMode: TResourceMode;
    FOnError: TLogEvent;
    FMaxThreadCount: Integer;
    // FListFileFormat: String;
    FPictureList: TPictureList;
    FOnResPageComplete: TNotifyEvent;
    FStopTick: DWORD;
    FStopPicsTick: DWORD;
    FCanceled: Boolean;
    FLogMode: Boolean;
    fUseDist: Boolean;
    fWriteEXIF: Boolean;
    FListStart: TDateTime;
    FPicStart: TDateTime;
    fPicDW: Boolean;
    fSemiListJob: tSemiListJob;
    fPostProcDelayed: Boolean;
    fUncheckBlacklisted: Boolean;
    fOnSendStop: TLogEvent;
    procedure SetOnPageComplete(Value: TNotifyEvent);
    procedure SetOnError(Value: TLogEvent);
    function GetPicsFinished: Boolean;
    procedure SetLogMode(Value: Boolean);
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
    procedure JobFinished(R: TResource);
    procedure PicJobFinished(R: TResource);
    procedure OnHandlerFinished(Sender: TObject);
    function CreateJob(t: TDownloadThread): Boolean;
    function GetListFinished: Boolean;
    // function CheckDouble(Pic: TTPicture; x,y: integer): Boolean;
    function CreateDWNLDJob(t: TDownloadThread): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure StartJob(JobType: Integer);
    function CopyResource(R: TResource): Integer;
    procedure CreatePicFields;
    procedure NextPage;
    procedure SetPageMode(Value: Boolean);
    procedure SetMaxThreadCount(Value: Integer);
    function AllFinished: Boolean;
    function AllPicsFinished: Boolean;
    procedure UncheckDoubles;
    function ItemByName(AName: String): TResource;
    function PostProcessFinished(incdelay: Boolean = false): Boolean;
    procedure ApplyInherit;
    procedure HandleKeywordList;
    procedure HandleParentLinks;
    procedure SaveToStream(fStream: tStream; fCB: TCallBackProgress);
    procedure SaveToFile(FName: string; fCB: TCallBackProgress);
    procedure LoadFromStream(fStream: tStream; fversion: word;
      fCB: TCallBackProgress);
    procedure LoadFromFile(FName: string; fCB: TCallBackProgress);
    function CreateResource: Integer;
    function NeedRelogin: boolean;
    function findByName(rname: string): integer;
    property ThreadHandler: TThreadHandler read FThreadHandler;
    property DWNLDHandler: TThreadHandler read FDwnldHandler;
    procedure LoadList(Dir: String);
    property OnJobChanged: TActionNotifyEvent read FJobChanged
      write FJobChanged;
    property ListFinished: Boolean read GetListFinished;
    property PicsFinished: Boolean read GetPicsFinished;
    property OnError: TLogEvent read FOnError write SetOnError;
    property MaxThreadCount: Integer read FMaxThreadCount
      write SetMaxThreadCount;
    // property ListFileFormat: String read FListFileFormat write FListFileFormat;
    property PictureList: TPictureList read FPictureList;
    property OnPageComplete: TNotifyEvent read FOnResPageComplete
      write SetOnPageComplete;
    property Canceled: Boolean read FCanceled write FCanceled;
    property LogMode: Boolean read FLogMode write SetLogMode;
    property UseDistribution: Boolean read fUseDist write fUseDist;
    property WriteEXIF: Boolean read fWriteEXIF write fWriteEXIF;
    property ListStartTime: TDateTime read FListStart;
    property PictureStartTime: TDateTime read FPicStart;
    property PicDW: Boolean read fPicDW;
    property SimListJob: tSemiListJob read fSemiListJob write fSemiListJob;
    property PostProcDelayed: Boolean read fPostProcDelayed;
    property UncheckBlacklisted: Boolean read fUncheckBlacklisted
      write fUncheckBlacklisted;
    property OnSendStop: TLogEvent read fOnSendStop write fOnSendStop;
    property Mode: TResourceMode read fMode;
  end;

function strFind(Value: string; List: TStringList; var Index: Integer): Boolean;
function tagFmt(Spacer, Separator, Isolator: String): TTagTemplate;
procedure WriteStr(s: String; fStream: tStream);
function ReadStr(fStream: tStream): String;
procedure WriteVar(s: Variant; fStream: tStream);
function ReadVar(fStream: tStream): Variant;

implementation

uses {LangString,} common, MD5;

{$IFDEF NEKODEBUG}

var
  debugpath: string;
  debugthreads: string;
  debuggui: string;
{$ENDIF}

function CalcValue(s: Variant; VE: TValueEvent; Lnk: TObject;
  NoMath: Boolean = false): Variant;

  function doubles(s: string; ch: Char): string;
  var
    i: Integer;
  begin
    i := PosEx(ch, s);
    while i <> 0 do
    begin
      Insert(ch, s, i + 1);
      i := PosEx(ch, s, i + 2);
    end;
    Result := s;
  end;

const
  op = ['(', ')', '+', '-', '<', '>', '=', '!', '*', '/', '\', '&', ',', '?',
    '~', '|', ' ', #9, #13, #10];
  p = ['$', '%', '#', '@'];
  isl: array [0 .. 1] of string = ('""', '''''');
var
  n1, n2: Integer;
  cstr: string;
  rstr: Variant;
  vt: WideString;
  vt2: Double;
  VRESULT: HRESULT;
  tmp: Integer;
  rsv: Variant;
  b, NKey: Boolean;

begin
  rsv := s;

  if Assigned(VE) then
  begin
    n1 := CharPos(s, ';', isl, []);

    while n1 > 0 do
    begin
      n2 := CharPos(s, #13, [], [], n1 + 1);
      if n2 = 0 then
        raise Exception.Create('scpirt read error: ' +
          'incorrect decloartion near "' + s + '"');
      s := DeleteEx(s, n1, n2 - n1);
      n1 := CharPos(s, ';', isl, []);
    end;

    n2 := 0;

    while true do
    begin
      n1 := CharPosEx(s, p, isl, [], n2 + 1);

      if n1 = 0 then
        Break;

      { if s[n1] = '@' then
        begin
        n2 := CharPos(s,'(',isl,n1+1);
        cstr := TrimEx(Copy(s,n1,n2-n1),[#13,#10,#9,' ']);
        n1 := n2;
        n2 := CharPos(s,')',isl,n1+1);
        rstr := Copy(s,n1,n2-n1-1);
        end else
        begin }
      if VarToStr(s)[n1] = '@' then
      begin
        n2 := CharPos(s, '(', ['""'], ['()'], n1 + 1);
        if n2 = 0 then
          n2 := CharPosEx(s, op, [], ['""'], n1 + 1)
        else
          n2 := CharPosEx(s, op - ['('], ['""'], ['()'], n1 + 1);
      end
      else if VarToStr(s)[n1] = '#' then
        n2 := CharPosEx(s, op, ['""'], [], n1 + 1)
      else
        n2 := CharPosEx(s, op, [], [], n1 + 1);

      if n2 = 0 then
        cstr := Copy(s, n1, length(s) - n1 + 1)
      else
        cstr := Copy(s, n1, n2 - n1);

      NKey := (n1 > 1) and SameText(VarToStr(s)[n1 - 1], 'N');

      rstr := null;
      // end;
      VE(cstr, rstr, Lnk);

      tmp := VarType(rstr);

      if (rstr <> null) and (s = VarToStr(s)[n1] + cstr) and
        not((tmp = varOleStr) or (tmp = varString) or (tmp = varUString)) then
      begin
        Result := rstr;
        Exit;
      end
      else if rstr = null then
        rstr := '""'
      else
      begin
        b := (Pos('(', trim(rstr)) = 1);
        if ((tmp = varOleStr) or (tmp = varString) or (tmp = varUString)) then
        begin
          vt := VarToWideStr(rstr);

          if not NKey and (Pos(' ', SysUtils.trim(rstr)) = 0) then
            VRESULT := VarR8FromStr(@vt[1], VAR_LOCALE_USER_DEFAULT, 0, vt2)
          else
            VRESULT := 1;

          if (VRESULT <> VAR_OK) or (b) then
            rstr := '''' + doubles(rstr, '''') + ''''
          else
            rstr := vt2;
        end
        else if VarType(rstr) = varDate then
          rstr := '''' + doubles(VarToStr(rstr), '''') + ''''
        else
          rstr := VarAsType(rstr, varDouble);
      end;

      // cstr := VarToStr(s)[n1] + cstr;
      if NKey then
        s := StringReplace(s, 'n' + cstr, rstr, [rfReplaceAll, rfIgnoreCase])
      else
        s := StringReplace(s, cstr, rstr, [rfReplaceAll, rfIgnoreCase]);

      // n2 := n1 + length(rstr) - 1;
      n2 := 0;
    end;
  end;

  if NoMath then
    Result := s
  else
    try
      Result := MathCalcStr(s);
    except
      on e: Exception do
      begin
        e.Message := 'Error when calculating string (' + VarToStr(rsv) + '): ' +
          e.Message;
        raise;
      end;
    end;
end;

function gVal(Value: string): string;
begin
  Result := TrimEx(CopyFromTo(Value, '(', ')', ['""'], ['()']),
    [#9, #10, #13, ' ']);
end;

function nVal(var Value: string; sep: Char = ','): string;
begin
  Result := TrimEx(CopyTo(Value, sep, ['""'], ['()'], true),
    [#9, #10, #13, ' ']);
end;

// TListValue

{ constructor TListValue.Create;
  begin
  inherited;
  FName := '';
  FValue := '';
  end; }

// TPictureValue

{ constructor TPictureValue.Create;
  begin
  inherited;
  FState := pvsNone;
  end; }

// TValueList

constructor TTagedList.Create;
begin
  FNodouble := true;
end;

destructor TTagedList.Destroy;
// var
// i: integer;
begin
  // for i := 0 to Count-1 do
  // Items[i].Free;
  Clear;
  inherited;
end;

procedure TTagedList.Notify(Ptr: Pointer; Action: TListNotification);
var
  p: TTagedListValue;
begin
  case Action of
    lnDeleted:
      begin
        p := Ptr;
        p.Free;
      end;
  end;
end;

function TTagedList.Get(Index: Integer): TTagedListValue;
begin
  Result := inherited Get(Index);
end;

function TTagedList.GetValue(ItemName: String): Pointer;
var
  p: TTagedListValue;
begin
  p := FindItem(ItemName);
  if p = nil then
    Result := nil
  else
    Result := p.Value;
end;

procedure TTagedList.SetValue(ItemName: String; Value: Pointer);
var
  p: TTagedListValue;
begin
  if ItemName = '' then
    Exit;

  if FNodouble then
  begin
    p := FindItem(ItemName);
    if p = nil then
    begin
      // New(p);
      p := TTagedListValue.Create;
      p.Name := ItemName;
      p.Value := Value;
      inherited Add(p);
    end
    else
      p.Value := Value;
  end
  else
  begin
    // New(p);
    p := TTagedListValue.Create;
    p.Name := ItemName;
    p.Value := Value;
    inherited Add(p);
  end;
end;

function TTagedList.FindItem(ItemName: String): TTagedListValue;
var
  i: Integer;
begin
  if ItemName = '' then
  begin
    Result := nil;
    Exit;
  end;

  for i := 0 to Count - 1 do
  begin
    Result := inherited Get(i);
    if SameText(Result.Name, ItemName) then
      Exit;
  end;
  Result := nil;
end;

{ procedure TValueList.Add(ItemName: String; Value: Variant);
  var
  n: TListValue;

  begin
  if FNoDouble then
  SetValue(ItemName,Value)
  else
  begin
  n := TListValue.Create;
  n.Name := ItemName;
  n.Value := Value;
  inherited Add(n);
  end;
  end; }

procedure TTagedList.Assign(List: TTagedList; AOperator: TListAssignOp);
var
  i: Integer;
  p: TTagedListValue;
begin
  case AOperator of
    laCopy:
      begin
        Clear;
        Capacity := List.Capacity;
        for i := 0 to List.Count - 1 do
        begin
          // New(p);
          p := TTagedListValue.Create;
          p.Name := List.Items[i].Name;
          p.Value := List.Items[i].Value;
          inherited Add(p);
        end;
      end;
    laAnd:
      ;
    laOr:
      begin
        for i := 0 to List.Count - 1 do
          Values[List.Items[i].Name] := List.Items[i].Value;
      end;
    laXor:
      ;
    laSrcUnique:
      ;
    laDestUnique:
      ;
  end;

end;

// TListValue

function TListValue.GetValue: Variant;
begin
  Result := PVariant(inherited Value)^;
end;

procedure TListValue.SetValue(Value: Variant);
begin
  PVariant(inherited Value)^ := Value;
end;

function TListValue.GetLink: PVariant;
begin
  Result := PVariant(inherited Value);
end;

procedure TListValue.SetLink(Value: PVariant);
begin
  if FMy then
    Dispose(PVariant(inherited Value));

  inherited Value := Value;
  FMy := false;
end;

constructor TListValue.Create;
var
  p: PVariant;
begin
  inherited;
  New(p);
  FValue := p;
  FMy := true;
end;

destructor TListValue.Destroy;
var
  p: PVariant;
begin
  if FMy then
  begin
    p := FValue;
    Dispose(p);
  end;
  inherited;
end;

// TValueList

function TValueList.Get(ItemIndex: Integer): TListValue;
begin
  Result := (inherited Items[ItemIndex]) as TListValue;
end;

function TValueList.GetValue(ItemName: String): Variant;
var
  p: TTagedListValue;

begin
  p := FindItem(ItemName);

  if p = nil then
    Result := null
  else
    Result := (p as TListValue).Value;
end;

function TValueList.GetLink(ItemName: String): PVariant;
var
  p: TTagedListValue;

begin
  p := FindItem(ItemName);

  if p = nil then
    Result := nil
  else
    Result := (p as TListValue).ValueLink;
end;

procedure TValueList.SetValue(ItemName: String; Value: Variant);
var
  p: TListValue;
begin
  if ItemName = '' then
    Exit;
  if FNodouble then
  begin
    p := (FindItem(ItemName) as TListValue);
    if p = nil then
    begin
      // New(p);
      p := TListValue.Create;
      p.Name := ItemName;
      p.Value := Value;
      inherited Add(p);
    end
    else
      p.Value := Value;
  end
  else
  begin
    // New(p);
    p := TListValue.Create;
    p.Name := ItemName;
    p.Value := Value;
    inherited Add(p);
  end;
end;

procedure TValueList.SaveToStream(fStream: tStream);
var
  i: Integer;
begin
  fStream.WriteData(Count);
  for i := 0 to Count - 1 do
  begin
    WriteStr(Items[i].Name, fStream);
    WriteVar(Items[i].Value, fStream);
  end;

end;

procedure TValueList.SetLink(ItemName: String; Value: PVariant);
var
  p: TListValue;
begin
  if ItemName = '' then
    Exit;
  if FNodouble then
  begin
    p := (FindItem(ItemName) as TListValue);
    if p = nil then
    begin
      // New(p);
      p := TListValue.Create;
      p.Name := ItemName;
      p.ValueLink := Value;
      inherited Add(p);
    end
    else
      p.ValueLink := Value;
  end
  else
  begin
    // New(p);
    p := TListValue.Create;
    p.Name := ItemName;
    p.ValueLink := Value;
    inherited Add(p);
  end;
end;

procedure TValueList.Assign(List: TValueList; AOperator: TListAssignOp);
var
  i: Integer;
  p: TListValue;
begin
  { if not Assigned(List) then
    Exit; }

  case AOperator of
    laCopy:
      begin
        Clear;
        FNodouble := List.NoDouble;
        Capacity := List.Capacity;
        for i := 0 to List.Count - 1 do
        begin
          // New(p);
          p := TListValue.Create;
          p.Name := List.Items[i].Name;
          p.Value := List.Items[i].Value;
          inherited Add(p);
        end;
      end;
    laAnd:
      ;
    laOr:
      begin
        FNodouble := FNodouble and List.NoDouble;
        for i := 0 to List.Count - 1 do
          Values[List.Items[i].Name] := List.Items[i].Value;
      end;
    laXor:
      ;
    laSrcUnique:
      ;
    laDestUnique:
      ;
  end;

end;

// TMetaList

procedure TMetaList.SetValueType(Value: DB.TFieldType);
begin
  FType := Value;
  case FType of
    ftInteger:
      FVariantType := varInteger;
    ftLargeInt:
      FVariantType := varInt64;
    ftBoolean:
      FVariantType := varBoolean;
    DB.ftString:
      FVariantType := varUString;
    ftDateTime:
      FVariantType := varDate;
    ftFloat:
      FVariantType := varDouble;
  end;
end;

procedure TMetaList.Notify(Ptr: Pointer; Action: TListNotification);
var
  p: PVariant;
begin
  case Action of
    lnDeleted:
      begin
        p := Ptr;
        Dispose(p);
      end;
  end;
end;

destructor TMetaList.Destroy;
begin
  Clear;
  inherited;
end;

function TMetaList.FindPosition(Value: Variant; var i: Integer): Boolean;
var
  Hi, Lo: Integer;

begin
  if Count = 0 then
  begin
    Result := false;
    i := 0;
    Exit;
  end;
  try
    if (FVariantType <> varUString) and (VarToStr(Value) = '') then
      Value := 0;

    Value := VarAsType(Value, FVariantType);
  except
    on e: Exception do
    begin
      e.Message := '"' + Value + '" - ' + e.Message;
      raise;
    end;
  end;

  Hi := Count;
  Lo := 0;
  i := Hi div 2;

  try
    while (Hi - Lo) > 0 do
    begin
      if Value = PVariant(Items[i])^ then
        Break
      else if Value < PVariant(Items[i])^ then
        Hi := i - 1
      else
        Lo := i + 1;

      i := Lo + ((Hi - Lo) div 2);
    end;

    if (i < Count) and (Value > PVariant(Items[i])^) then
      inc(i);

    Result := (i < Count) and VarSameValue(Value, PVariant(Items[i])^);
  except
    on e: Exception do
    begin
      e.Message := e.Message + ' (' + VarToStr(PVariant(Items[i])^) + ') - (' +
        VarToStr(Value) + ')';
      raise;
    end;
  end;
end;

function TMetaList.Add(Value: Variant; Pos: Integer): PVariant;
var
  p: PVariant;

begin
  New(p);
  if (FVariantType <> varUString) and (VarToStr(Value) = '') then
    Value := 0;
  p^ := VarAsType(Value, FVariantType);
  Insert(Pos, p);
  Result := p;
end;

// TPictureValueList

{ function TPictureValueList.Get(Index: integer): TPictureValue;
  begin
  Result := ( inherited Get(Index)) as TPictureValue;
  end;

  procedure TPictureValueList.SetValue(ItemName: String; Value: Variant);
  var
  p: TPictureValue;
  begin
  p := FindItem(ItemName);
  if p = nil then
  begin
  p := TPictureValue.Create;
  p.Name := ItemName;
  p.Value := Value;
  end
  else
  p.Value := Value;
  end;

  function TPictureValueList.FindItem(ItemName: String): TPictureValue;
  begin
  Result := ( inherited FindItem(ItemName)) as TPictureValue;
  end;

  function TPictureValueList.GetState(ItemName: String): TPictureValueState;
  var
  p: TPictureValue;
  begin
  p := FindItem(ItemName);
  if p <> nil then
  Result := p.State
  else
  Result := pvsNone;
  end;

  procedure TPictureValueList.SetState(ItemName: String;
  Value: TPictureValueState);
  var
  p: TPictureValue;
  begin
  p := FindItem(ItemName);
  if p <> nil then
  p.State := Value;
  end; }

// TWorkList

destructor TWorkList.Destroy;
begin
  Clear;
  Inherited;
end;

function TWorkList.Get(Index: Integer): PWorkItem;

begin
  Result := inherited Get(Index);
end;

procedure TWorkList.Notify(Ptr: Pointer; Action: TListNotification);
var
  p: PWorkItem;
begin
  case Action of
    lnDeleted:
      begin
        p := Ptr;
        Dispose(p);
      end;
  end;
end;

function TWorkList.Add(Section: TScriptSection; Obj: TObject): Integer;
var
  p: PWorkItem;

begin
  New(p);
  p.Section := Section;
  p.Obj := Obj;
  Result := inherited Add(p);
end;

// TScriptItem

procedure TScriptItem.Assign(s: TScriptItem);
begin
  FName := s.Name;
  FValue := s.Value;
  Kind := s.Kind;
end;

function TScriptItem.AsString(level: byte = 0): String;
begin
  case Kind of
    sikProcedure:
      Result := StringOfChar(' ', level) + FName + ';' + #13#10;
    sikDecloration:
      Result := StringOfChar(' ', level) + FName + '=' + FValue + ';' + #13#10;
  end;
end;

// TScriptSection

constructor TScriptSection.Create;
begin
  inherited;
  FName := '';
  Fparameters := TValueList.Create;
  Fparameters.NoDouble := false;
  FChildSections := TScriptItemList.Create;
  FNoParam := false;
  FInUse := false;
end;

destructor TScriptSection.Destroy;
begin
  Fparameters.Free;
  FChildSections.Free;
  inherited;
end;

function TScriptSection.Empty: Boolean;
begin
  Result := // (Declorations.Count > 0) or (Conditions.Count > 0) or
    (ChildSections.Count = 0);
end;

procedure TScriptSection.ParseValues(s: string);

const
  EmptyS = [#9, #10, #13, ' '];

  isl: array [0 .. 1] of string = ('''''', '""');
  brk: array [0 .. 2] of string = ('()', '{}', '[]');
  Cons = ['=', '<', '>', '!'];

var
  i, l, n, p { ,tmpi1,tmpi2 } : Integer;
  v1, v2, tmp: string;
  Child: TScriptSection;
  ChItem: TScriptItem;
  newstring: Boolean;

begin
  if InUse then
    Exit;

  FChildSections.Clear;
  i := 1;
  l := length(s);
  newstring := true;

  while i <= l do
  begin
    case s[i] of
      #10:
        begin
          newstring := true;
          inc(i);
        end;
      #9, #13, ' ':
        inc(i);
      ';':
        if newstring then
        begin
          n := CharPos(s, #13, [], [], i + 1);

          if n = 0 then
            n := l;

          i := n + 1;
        end
        else
          inc(i);
      '`':
        begin
          n := CharPos(s, '`', [], [], i + 1);

          if n = 0 then
            n := l;

          i := n + 1;
        end;
      '^':
        begin
          newstring := false;
          n := CharPos(s, '{', isl, brk, i + 1);

          if n = 0 then
            { raise Exception.Create(Format(lang('_SCRIPT_READ_ERROR_'),
              [Format(lang('_INCORRECT_DECLORATION_'), [IntToStr(i)])])); }
            raise Exception.Create('Script read error: ' +
              'Can''t find { after ' + Copy(s, i, 15));

          tmp := TrimEx(Copy(s, i + 1, n - i - 1), EmptyS);

          Child := TScriptSection.Create;
          Child.Name := trim(GetNextS(tmp, '#'), '^');
          if Child.Name = '' then
            Child.Kind := sikGroup
          else
          begin
            Child.Kind := sikSection;
            if Child.Name[length(Child.Name)] = '!' then
            begin
              Child.NoParameters := true;
              Child.Name := Copy(Child.Name, 1, length(Child.Name) - 1);
            end;
          end;
          while tmp <> '' do
          begin
            v1 := GetNextS(tmp, '#');
            p := CheckStrPos(v1, Cons, true);
            if p > 0 then
              v2 := TrimEx(Copy(v1, 1, p), EmptyS);

            if v2 <> '' then
              if p = 0 then
                Child.parameters[v2] := ''
              else
                Child.parameters[v2] :=
                  TrimEx(Copy(v1, p + 1, length(v1) - p), EmptyS);
          end;

          i := n + 1;

          n := CharPos(s, '}', isl, brk, i);

          if n = 0 then
          begin
            Child.Free;
            raise Exception.Create('Script read error: ' +
              'Can''t find } after ' + Copy(s, i, 15));
          end;

          Child.ParseValues(Copy(s, i, n - i));
          FChildSections.Add(Child);

          i := n + 1;
        end;
      '?':
        begin
          n := CharPos(s, '{', isl, brk, i + 1);

          if n = 0 then
            { raise Exception.Create(Format(lang('_SCRIPT_READ_ERROR_'),
              [Format(lang('_INCORRECT_DECLORATION_'), [IntToStr(i)])])); }
            raise Exception.Create('Script read error: ' +
              'Can''t find { after ' + Copy(s, i, 15));

          tmp := SysUtils.trim(Copy(s, i + 1, n - i - 1));

          Child := TScriptSection.Create;
          // Child.Parent := Parent;
          Child.Kind := sikCondition;
          Child.parameters.Assign(parameters);
          Child.Name := tmp;

          i := n + 1;

          n := CharPos(s, '}', isl, brk, i);

          if n = 0 then
          begin
            Child.Free;
            { raise Exception.Create(Format(lang('_SCRIPT_READ_ERROR_'),
              [Format(lang('_INCORRECT_DECLORATION_'), [IntToStr(i)])])); }
            raise Exception.Create('Script read error: ' +
              'Can''t find } after ' + Copy(s, i, 15));
          end;

          Child.ParseValues(Copy(s, i, n - i));
          FChildSections.Add(Child);

          i := n + 1;
        end;
      ':':
        begin
          n := CharPos(s, '{', isl, brk, i + 1);

          if n = 0 then
            { raise Exception.Create(Format(lang('_SCRIPT_READ_ERROR_'),
              [Format(lang('_INCORRECT_DECLORATION_'), [IntToStr(i)])])); }
            raise Exception.Create('Script read error: ' +
              'Can''t find { after ' + Copy(s, i, 15));

          tmp := TrimEx(Copy(s, i + 1, n - i - 1), EmptyS);

          Child := TScriptSection.Create;
          // Child.Parent := Parent;
          Child.Kind := sikCycle;
          Child.parameters.Assign(parameters);
          Child.Name := tmp;

          i := n + 1;

          // Child.Parameters.)/

          n := CharPos(s, '}', isl, brk, i);

          if n = 0 then
          begin
            Child.Free;
            { raise Exception.Create(Format(lang('_SCRIPT_READ_ERROR_'),
              [Format(lang('_INCORRECT_DECLORATION_'), [IntToStr(i)])])); }
            raise Exception.Create('Script read error: ' +
              'Can''t find } after ' + Copy(s, i, 15));
          end;

          Child.ParseValues(Copy(s, i, n - i));
          FChildSections.Add(Child);

          i := n + 1;
        end;
    else
      begin

        n := CharPos(s, ';', isl, brk, i + 1);

        // n := CharPos(s, '=', isl, i + 1);

        if n = 0 then
          { raise Exception.Create(Format(lang('_SCRIPT_READ_ERROR_'),
            [Format(lang('_INCORRECT_DECLORATION_'), [IntToStr(i)])])); }
          raise Exception.Create('Script read error: ' + 'Can''t find ; after '
            + Copy(s, i, 15));
        // v2 := v2;

        v1 := TrimEx(Copy(s, i, n - i), EmptyS);

        i := n + 1;

        n := CharPos(v1, '=', isl, brk);

        if n = 1 then
          { raise Exception.Create(Format(lang('_SCRIPT_READ_ERROR_'),
            [lang('_INCORRECT_DECLORATION_') + IntToStr(i)])); }
          raise Exception.Create('Script read error: ' +
            'Incorrect decloration near ' + Copy(s, i, 15));

        if n > 0 then
        begin
          v2 := TrimEx(Copy(v1, 1, n - 1), EmptyS);
          v1 := DeleteEx(v1, 1, n);
        end
        else
        begin
          v2 := CopyTo(v1, '(');

          if v2 = '' then
            { raise Exception.Create(Format(lang('_SCRIPT_READ_ERROR_'),
              [lang('_INCORRECT_DECLORATION_') + IntToStr(i)])) }
            raise Exception.Create('Script read error: ' +
              'Incorrect decloration near ' + Copy(s, i, 15))
          else if v2[1] = '$' then
            v2[1] := '@'
          else if v2[1] <> '@' then
            v2 := '@' + v2;

          { tmpi1 := CharPos(v1,'(',['()']);
            tmpi2 := CharPos(v1,')',['()'],tmpi1+1); }

          v1 := CopyFromTo(v1, '(', ')', ['""', ''''''], ['()']);
        end;

        ChItem := TScriptItem.Create;
        if v2[1] = '@' then
          ChItem.Kind := sikProcedure
        else
          ChItem.Kind := sikDecloration;
        // Declorations[v2] := trim(v1);
        ChItem.Name := v2;
        ChItem.Value := trim(v1);
        ChildSections.Add(ChItem);
        // i := n + 1;

      end;
    end;
  end;
end;

procedure TScriptSection.Process(const SE: TScriptEvent;
  const DE: TDeclorationEvent; FE: TFinishEvent; const VE: TValueEvent;
  PVE: TValueEvent = nil; LinkedObj: TObject = nil);

var
  Calced: TValueList;
  i, j, loopcounter: Integer;
  ALnk, Lnk: TObject;
  Obj: TObject;
  cont: Boolean;
begin
  if InUse then
    Exit;

  FInUse := true;
  ALnk := nil;
  try
    Lnk := LinkedObj;
    try
      // Lnk := LinkedObj; //try

      if Assigned(SE) then
      begin
        Calced := TValueList.Create;
        try
          try
            Calced.Assign(parameters);

            if Assigned(PVE) then
              for i := 0 to Calced.Count - 1 do
                Calced.Items[i].Value := CalcValue(Calced.Items[i].Value, PVE,
                  LinkedObj);

            cont := SE(Self, Calced, LinkedObj, ALnk);

            if Assigned(ALnk) then
              Lnk := ALnk;

            // Lnk.Free;
            // Exit;
          except
            on e: Exception do
            begin
              e.Message := ('Script section item parameters calculation error: '
                + e.Message);
              cont := false;
              raise;
            end;
          end;
        finally
          Calced.Free;
        end;
      end
      else
        cont := true;

      // try

      if cont then
      begin
        // j := 0;

        if Assigned(Lnk) and (Lnk is TWorkList) then
          with (Lnk as TWorkList) do
            for i := 0 to Count - 1 do
              Items[i].Section.Process(SE, DE, FE, VE, PVE, Items[i].Obj)
        else
        begin
          if (Kind <> sikNone) and Assigned(Lnk) and (Lnk is TList) and
            ((Lnk as TList).Count > 0) then
          begin
            j := 0;
            Obj := (Lnk as TList)[j];
            inc(j);
          end
          else
          begin
            j := -1;
            Obj := Lnk;
          end;

          repeat
            for i := 0 to ChildSections.Count - 1 do
              case ChildSections[i].Kind of
                sikSection, sikGroup:
                  (ChildSections[i] as TScriptSection).Process(SE, DE, FE, VE,
                    PVE, Obj);
                sikCondition:
                  if (length(ChildSections[i].Name) > 0) then
                    if CalcValue(ChildSections[i].Name, VE, Obj) then
                      (ChildSections[i] as TScriptSection)
                        .Process(SE, DE, FE, VE, PVE, Obj);
                sikCycle:
                  if (length(ChildSections[i].Name) > 0) then
                  begin
                    loopcounter := 0;
                    while CalcValue(ChildSections[i].Name, VE, Obj) do
                    begin
                      if loopcounter = MAXINT then
                        raise Exception.Create
                          ('Cycle is reached iteration maximum ' + '(' +
                          IntToStr(MAXINT) + ': ' + ChildSections[i].Name);

                      (ChildSections[i] as TScriptSection)
                        .Process(SE, DE, FE, VE, PVE, Obj);

                      inc(loopcounter);
                    end;
                  end;
                sikProcedure:
                  DE(ChildSections[i].Name, ChildSections[i].Value, Obj);
                sikDecloration:
                  DE(ChildSections[i].Name, CalcValue(ChildSections[i].Value,
                    VE, Obj), Obj);
              end;

            if (j > -1) and { (lnk is tlist) and } ((Lnk as TList).Count > j)
            then
            begin
              Obj := (Lnk as TList)[j];
              inc(j);
            end
            else
              j := -1;
          until j = -1;

        end;

      end;

    finally
      if Assigned(FE) then
        FE(Self, ALnk);
    end;

  finally
    FInUse := false;
  end;
end;

procedure TScriptSection.SaveToFile(FName: string);
var
  s: TStringList;
begin
  s := TStringList.Create;
  try
    s.Text := AsString;
    s.SaveToFile(FName);
  finally
    s.Free;
  end;
end;

procedure TScriptSection.Assign(s: TScriptItem);
begin
  if s = nil then
    Clear
  else
  begin
    inherited Assign(s);
    if s is TScriptSection then
    begin

      // FParent := s.Parent;
      fSectionName := (s as TScriptSection).SectionName;
      FNoParam := (s as TScriptSection).NoParameters;
      Fparameters.Assign((s as TScriptSection).parameters);
      // FKind := s.Kind;
      // FDeclorations.Assign(s.Declorations);
      // FConditions.Assign(s.Conditions);
      FChildSections.Assign((s as TScriptSection).ChildSections);
    end;
  end;
end;

// TScriptItemKind = (sikNone, sikProcedure, sikDecloration, sikSection,
// sikCondition, sikCycle, sikGroup);

function TScriptSection.AsString(level: byte = 0): String;
var
  i: Integer;
begin
  case Kind of
    sikNone:
      Result := FChildSections.AsString;
    sikProcedure:
      Result := StringOfChar(' ', level) + FName;
    sikDecloration:
      Result := StringOfChar(' ', level) + FName + '=' + FValue;
    sikSection:
      begin
        Result := StringOfChar(' ', level) + '^' + FName;
        for i := 0 to Fparameters.Count - 1 do
          Result := Result + '#' + Fparameters.Items[i].Name + '="' +
            Fparameters.Items[i].Value + '"';
        Result := Result + '{' + #13#10 + FChildSections.AsString(level + 1) +
          StringOfChar(' ', level) + '}';
      end;
    sikCondition:
      begin
        Result := StringOfChar(' ', level) + '?(' + FName + ')';
        // for i := 0 to FParameters.Count-1 do
        // Result := Result + '#' + FParameters.Items[i].Name + '="' + FParameters.Items[i].Value + '"';
        Result := Result + '{' + #13#10 + FChildSections.AsString(level + 1) +
          StringOfChar(' ', level) + '}';
      end;
    sikCycle:
      begin
        Result := StringOfChar(' ', level) + ':(' + FName + ')';
        // for i := 0 to FParameters.Count-1 do
        // Result := Result + '#' + FParameters.Items[i].Name + '="' + FParameters.Items[i].Value + '"';
        Result := Result + '{' + #13#10 + FChildSections.AsString(level + 1) +
          StringOfChar(' ', level) + '}';
      end;
    sikGroup:
      begin
        // Result := '' + FName + ')';
        // for i := 0 to FParameters.Count-1 do
        // Result := Result + '#' + FParameters.Items[i].Name + '="' + FParameters.Items[i].Value + '"';
        Result := '^{' + #13#10 + FChildSections.AsString(level + 1) +
          StringOfChar(' ', level) + '}';
      end;
  end;
  Result := Result + #13#10;
end;

procedure TScriptSection.Clear;
begin
  FName := '';
  // Conditions.Clear;
  // Declorations.Clear;
  ChildSections.Clear;
end;

// TScriptSectionList

procedure TScriptItemList.Notify(Ptr: Pointer; Action: TListNotification);
var
  p: TScriptItem;
begin
  case Action of
    lnAdded:
      ;
    lnExtracted:
      ;
    lnDeleted:
      begin
        p := Ptr;
        p.Free;
      end;
  end;
end;

procedure TScriptItemList.Assign(s: TScriptItemList);
var
  i: Integer;
  p: TScriptItem;

begin
  p := nil;
  Clear;
  if Assigned(s) then
    for i := 0 to s.Count - 1 do
    begin
      { if s[i].ClassType = TScriptSection then
        begin
        p := TScriptSection.Create;
        (p as TScriptSection).Assign((s[i] as TScriptSection));
        end else if s[i].ClassType = TScriptItem then
        begin
        p := TScriptItem.Create;
        p.Parent := s[i].Parent;
        p.Value := s[i].Value;
        end; }
      if s[i].ClassType = TScriptSection then
        p := TScriptSection.Create
      else if s[i].ClassType = TScriptItem then
        p := TScriptItem.Create
      else
        Continue;

      p.Assign(s[i]);
      Add(p);
    end;
end;

function TScriptItemList.AsString(level: byte = 0): String;
var
  i: Integer;
begin
  if Count = 0 then
  begin
    Result := '';
    Exit;
  end;

  Result := Items[0].AsString(level);

  for i := 1 to Count - 1 do
    Result := Result + Items[i].AsString(level);
end;

destructor TScriptItemList.Destroy;
begin
  Clear;
  inherited;
end;

function TScriptItemList.Get(Index: Integer): TScriptItem;
begin
  Result := inherited Get(Index);
end;

// TJobList

function TJobList.AllFinished(incerrs: Boolean): Boolean;
var
  i: Integer;
begin
  { if not(FLastAdded.status in [JOB_ERROR,JOB_FINISHED]) then
    begin
    Result := false;
    Exit;
    end; }

  for i := FFinishCursor to Count - 1 do
    if incerrs and not(Items[i].Status in [JOB_ERROR, JOB_FINISHED]) or
      not incerrs and not(Items[i].Status in [JOB_FINISHED]) then
    begin
      FFinishCursor := i;
      Result := false;
      Exit;
    end;

  FFinishCursor := Count;

  Result := true;
end;

function TJobList.NextJob(Status: Integer): Integer;
var
  i: Integer;

begin
  if FCursor < Count then
  begin
    Result := -1;

    for i := FCursor to Count - 1 do
      if (Items[FCursor].Status = JOB_NOJOB) then
      begin
        Items[FCursor].Status := JOB_INPROGRESS;
        Result := i;
        FCursor := i + 1;
        Break;
      end;

    for i := FCursor to Count - 1 do
      if (Items[i].Status = JOB_NOJOB) then
      begin
        FCursor := i;
        Exit;
      end;

    FCursor := Count;
  end
  else
    Result := -1;
end;

function TJobList.LastJob(Status: Integer): Integer;
begin
  if FCursor = Count - 1 then
    Result := NextJob(Status)
  else if Items[Count - 1].Status = JOB_NOJOB then
  begin
    Items[Count - 1].Status := JOB_INPROGRESS;
    Result := Count - 1;
  end
  else
    Result := -1;
end;

procedure TJobList.Reset;
var
  i: Integer;

begin
  FErrCount := 0;
  FOkCount := 0;
  FFinishCursor := 0;

  i := 0;

  for i := i to Count - 1 do
    if Items[i].Status <> JOB_FINISHED then
      Break
    else
      inc(FOkCount);

  FCursor := i;

  for i := i to Count - 1 do
    if Items[i].Status <> JOB_FINISHED then
      Items[i].Status := JOB_NOJOB
    else
      inc(FOkCount);

  AllFinished;
end;

procedure TJobList.Clear;
begin
  inherited Clear;
  Reset;
end;

destructor TJobList.Destroy;
begin
  inherited Clear;
  inherited;
end;

function TJobList.eol: Boolean;
begin
  Result := not(FCursor < Count);
end;

function TJobList.Get(Value: Integer): PJobRec;
begin
  Result := inherited Get(Value);
end;

procedure TJobList.Notify(Ptr: Pointer; Action: TListNotification);
var
  p: PJobRec;
begin
  case Action of
    lnDeleted:
      begin
        p := Ptr;
        Dispose(p);
      end;
  end;
end;

function TJobList.Add(id: Integer): Integer;
begin
  New(FLastAdded);
  // FLastAdded.LPic := Nil;
  FLastAdded.id := id;
  // FLastAdded.Kind := Kind;
  FLastAdded.Url := '';
  FLastAdded.Referer := '';
  FLastAdded.Status := JOB_NOJOB;
  Result := inherited Add(FLastAdded);
end;

// TResource

procedure TResource.ApplyInherit(R: TResource);
var
  p: TResource;
  n: Integer;
  i: Integer;
begin
  p := R.Parent;

  if Assigned(p) then
    while Assigned(p.Parent) do
      p := p.Parent;

  if FInherit and Assigned(p) then
  begin
    // FFields.Assign(R.Parent.Fields, laOr);
    if (FKeywordList.Count = 0) then
    begin
      if (p.KeywordList.Count = 0) then
      begin
        n := p.Fields.FindField('tag');
        if (n > -1) and (VarToStr(p.Fields.Items[n].resvalue) <> '') then
          FFields['tag'] :=
            FormatTagString(VarToStr(p.Fields.Items[n].resvalue),
            p.HTTPRec.TagTemplate);
      end
      else
        for i := 0 to p.KeywordList.Count - 1 do
          FKeywordList.Add(FormatTagString(p.KeywordList[i],
            p.HTTPRec.TagTemplate));
    end;

    FNameFormat := p.NameFormat;
  end
  else
  begin
    if FNameFormat = '' then
      FNameFormat := R.NameFormat;

    if (VarToStr(FFields['tag']) = '') then
      if (FKeywordList.Count = 0) then
        if (p.KeywordList.Count = 0) then
        begin
          n := p.Fields.FindField('tag');
          if (n > -1) and (VarToStr(p.Fields.Items[n].resvalue) <> '') then
            FFields['tag'] :=
              FormatTagString(VarToStr(p.Fields.Items[n].resvalue),
              p.HTTPRec.TagTemplate);
        end
        else
          for i := 0 to p.KeywordList.Count - 1 do
            FKeywordList.Add(FormatTagString(p.KeywordList[i],
              p.HTTPRec.TagTemplate));
  end;
end;

procedure TResource.Assign(R: TResource);
begin
  // FDownloadSet := R.DownloadSet;
  FCheatSheet := R.CheatSheet;
  FKeywordHint := R.KeywordHint;
  FFileName := R.FileName;
  // FTemplateName := R
  FIconFile := R.IconFile;
  FInherit := R.Inherit;
  // FMaxThreadCount := R.MaxThreadCount;
  // FDefinedMaxThreadCount := R.DefinedMaxThreadCount;
  FHTTPRec.TagTemplate := R.HTTPRec.TagTemplate;
  FFields.Assign(R.Fields);
  FScripts := R.ScriptStrings;

  ApplyInherit(R);

  FLoginPrompt := R.LoginPrompt;
  FResName := R.Name;
  // fSpacer := R.TagsSpacer;
  FSectors.Assign(R.Sectors);
  FPicFieldList.Assign(R.PicFieldList);
  // FURL := R.Url;
  FShort := R.Short;
  FHTTPRec.DefUrl := R.HTTPRec.DefUrl;
  FHTTPRec.Url := R.HTTPRec.DefUrl;
  FHTTPRec.Referer := R.HTTPRec.Referer;
  FHTTPRec.CookieStr := R.HTTPRec.CookieStr;
  FHTTPRec.LoginStr := R.HTTPRec.LoginStr;
  FHTTPRec.LoginPost := R.HTTPRec.LoginPost;
  FHTTPRec.Method := R.HTTPRec.Method;
  FHTTPRec.ParseMethod := R.HTTPRec.ParseMethod;
  // FHTTPRec.Counter := 0;
  FHTTPRec.Count := 0;
  FHTTPRec.PageByPage := R.HTTPRec.PageByPage;
  FHTTPRec.TryExt := R.HTTPRec.TryExt;
  FHTTPRec.UseTryExt := R.HTTPRec.UseTryExt;
  FHTTPRec.Encoding := R.HTTPRec.Encoding;
  FHTTPRec.PicTemplate := R.HTTPRec.PicTemplate;
  FHTTPRec.EXIFTemplate := R.HTTPRec.EXIFTemplate;
  FHTTPRec.DelayPostProc := R.HTTPRec.DelayPostProc;
  FHTTPRec.AddUnchecked := R.HTTPRec.AddUnchecked;
  FHTTPRec.StartCount := R.HTTPRec.StartCount;
  FHTTPRec.MaxCount := R.HTTPRec.MaxCount;
  FHTTPRec.AddToMax := R.HTTPRec.AddToMax;
  // TTPRec.CheckFNameExt := R.HTTPRec.CheckFNameExt;
end;

function TResource.CanAddThread: Boolean;
begin
  with FThreadCounter^ do
    Result := (not FKeepQueue or (CurrentResource = nil) or
      (CurrentResource = Self)) and
      ((MaxThreadCount = 0) or (MaxThreadCount > 0) and
      (CurrThreadCount < MaxThreadCount));
end;

constructor TResource.Create;
begin
  inherited;
  FFileName := '';
  // FURL := '';
  FIconFile := '';
  FParent := nil;
  FMainResource := nil;
  FPictureList := TPictureLinkList.Create;
  // FPictureList.Resource := Self;
  FInherit := true;
  FLoginPrompt := false;
  FRelogin := false;
  FFields := TResourceFields.Create;
  FFields.AddField('tag', '', ftString, null, '', false);
  FFields.AddField('login', '', ftNone, null, '', false);
  FFields.AddField('password', '', ftNone, null, '', false);
  FKeywordList := TStringList.Create;
  FSectors := TValueList.Create;
  FPicFieldList := TStringList.Create;
  FInitialScript := nil;
  FBeforeScript := nil;
  FAfterScript := nil;
  FXMLScript := nil;
  FPicScript := nil;
  FPostProc := nil;
  fResourceList := nil;
  FHTTPRec.ParseMethod := 'xml';
  FHTTPRec.UseTryExt := false;
  FHTTPRec.TryExt := '';
  FHTTPRec.PicTemplate.Name := '';
  FHTTPRec.PicTemplate.Ext := '';
  FHTTPRec.TagTemplate.Spacer := '_';
  FHTTPRec.TagTemplate.Separator := ' ';
  FHTTPRec.TagTemplate.Isolator := '';
  FHTTPRec.Encoding := TEncoding.UTF8;
  FHTTPRec.EXIFTemplate.UseEXIF := false;
  FHTTPRec.DelayPostProc := false;
  FHTTPRec.AddUnchecked := false;
  FHTTPRec.StartCount := 0;
  FHTTPRec.MaxCount := 0;
  FHTTPRec.AddToMax := 0;
  // fHTTPRec.CheckFNameExt := true;
  FNextPage := false;
  FKeepQueue := false;
  FThreadCounter := nil;

  FJobList := TJobList.Create;
  with FScripts do
  begin
    Login := '';
    List := LIST_SCRIPT;
    Download := DOWNLOAD_SCRIPT;
  end;
  // FJobFinished := false;
end;

destructor TResource.Destroy;
begin
  FJobList.Free;
  FPictureList.Free;
  FSectors.Free;
  FFields.Free;
  FKeywordList.Free;
  FPicFieldList.Free;
  if Assigned(FInitialScript) then
    FInitialScript.Free;
  if Assigned(FBeforeScript) then
    FBeforeScript.Free;
  if Assigned(FAfterScript) then
    FAfterScript.Free;
  if Assigned(FXMLScript) then
    FXMLScript.Free;
  if Assigned(FPicScript) then
    FPicScript.Free;
  if FMainResource = nil then
    FreeThreadCounter;
  { if Assigned(FPictureList) then
    FPictureList.Free; }
  inherited;
end;

function TResource.FormatTagString(Tag: String;
  OldFormat: TTagTemplate): String;
var
  s: string;
begin
  Result := '';

  while Tag <> '' do
  begin
    s := GetNextS(Tag, OldFormat.Separator, OldFormat.Isolator);
    if Result = '' then
      Result := FHTTPRec.TagTemplate.Isolator + ReplaceStr(s, OldFormat.Spacer,
        FHTTPRec.TagTemplate.Spacer) + FHTTPRec.TagTemplate.Isolator
    else
      Result := Result + FHTTPRec.TagTemplate.Separator +
        FHTTPRec.TagTemplate.Isolator + ReplaceStr(s, OldFormat.Spacer,
        FHTTPRec.TagTemplate.Spacer) + FHTTPRec.TagTemplate.Isolator;
  end;
end;

function TResource.ResetRelogin: boolean;
begin
  //N := Pointer(idx);
  if fRelogin or Assigned(MainResource) then
  begin
    fRelogin := false;
    Exit(false);
  end;

  if ((ScriptStrings.Login <> '') or (HTTPRec.CookieStr <> '')) and
    (LoginPrompt or (VarToStr(Fields['login']) <> '')) then
  begin
    //N.Parent.Fields.Assign(N.Fields);
    fRelogin := true;
    Result := true;
  end else
  begin
    fRelogin := false;
    Result := false;
  end;
end;

function TResource.RestoreTagString(Tag: String;
  NewFormat: TTagTemplate): String;
var
  s: string;
begin
  Result := '';

  while Tag <> '' do
  begin
    s := GetNextS(Tag, FHTTPRec.TagTemplate.Separator,
      FHTTPRec.TagTemplate.Isolator);
    if Result = '' then
      Result := NewFormat.Isolator + ReplaceStr(s, FHTTPRec.TagTemplate.Spacer,
        NewFormat.Spacer) + NewFormat.Isolator
    else
      Result := Result + NewFormat.Separator + NewFormat.Isolator +
        ReplaceStr(s, FHTTPRec.TagTemplate.Spacer, NewFormat.Spacer) +
        NewFormat.Isolator;
  end;
end;

procedure TResource.FreeThreadCounter;
begin
  if Assigned(FThreadCounter) then
  begin
    FThreadCounter.Queue.Free;
    Dispose(FThreadCounter);
  end;

  FThreadCounter := nil;
end;

procedure TResource.GetSectors(s: string; R: TValueList);
const
  isl: array [0 .. 2] of string = ('""', '''''', '``');
  brk: array [0 .. 1] of string = ('{}', '()');
var
  n1, n2: Integer;
  pr: String;

begin
  pr := '';
  R.Clear;
  n2 := 0;
  while true do
  begin
    n1 := CharPos(s, '[', isl, brk, n2 + 1);

    if n1 = 0 then
    begin
      if pr <> '' then
        R[pr] := Copy(s, n2 + 1, length(s) - n2);
      Break;
    end;

    if pr <> '' then
      R[pr] := Copy(s, n2 + 1, n1 - n2 - 1);

    // Delete(s, 1, n1);

    n2 := CharPos(s, ']', isl, brk, n1 + 1);

    if n2 = 0 then
      Break;

    pr := Copy(s, n1 + 1, n2 - n1 - 1);

    if CheckStr(pr, ['A' .. 'Z', 'a' .. 'z', '0' .. '9']) then
      raise Exception.Create
        ('script read error: incorrect symbols in section name (' + pr + ')');

    // Delete(s, 1, n2);
  end;
end;

// function TResource.GetThreadCounter: TThreadCounter;
// begin
// Result := FThreadCounter^;
// end;

// procedure TResource.SetMaxThreadCount(Value: integer);
// begin
// with FThreadCounter^ do
// if (DefinedMaxThreadCount > 0)
// and (DefinedMaxThreadCount < Value) then
// MaxThreadCount := DefinedMaxThreadCount
// else
// MaxThreadCount := Value;
// end;

procedure TResource.SaveToStream(fStream: tStream);
var
  i: Integer;
begin
  WriteStr(ExtractFileName(FFileName), fStream);
  WriteStr(FNameFormat, fStream);
  fStream.WriteData(FJobInitiated);
  if Assigned(FPostProc) then
    WriteStr(FPostProc.SectionName, fStream)
  else
    WriteStr('', fStream);
  if Assigned(FXMLScript) then
    WriteStr(FXMLScript.SectionName, fStream)
  else
    WriteStr('', fStream);
  fStream.WriteData(FKeepQueue);

  if Assigned(MainResource) then // MainResource
    fStream.WriteData(MainResource.SaveIndex)
  else
  begin
    fStream.WriteData(Integer(-1));
    with FThreadCounter^ do
    begin
      fStream.WriteData(DefinedSettings.MaxThreadCount);
      fStream.WriteData(DefinedSettings.PicDelay);
      fStream.WriteData(DefinedSettings.PageDelay);
      fStream.WriteData(UseUserSettings);
      fStream.WriteData(UserSettings.MaxThreadCount);
      fStream.WriteData(UserSettings.PicDelay);
      fStream.WriteData(UserSettings.PageDelay);
      fStream.WriteData(UseProxy);
    end;
  end;

  fStream.WriteData(FFields.Count);
  for i := 0 to FFields.Count - 1 do
  begin
    WriteStr(FFields.Items[i].resname, fStream);
    WriteVar(FFields.Items[i].resvalue, fStream);
  end;

  WriteStr(FHTTPRec.DefUrl, fStream);
  WriteStr(FHTTPRec.Url, fStream);
  WriteStr(FHTTPRec.Post, fStream);
  WriteStr(FHTTPRec.Referer, fStream);
  WriteStr(FHTTPRec.ParseMethod, fStream);
  WriteStr(FHTTPRec.JSONItem, fStream);
  WriteStr(FHTTPRec.CookieStr, fStream);
  WriteStr(FHTTPRec.LoginStr, fStream);
  WriteStr(FHTTPRec.LoginPost, fStream);
  fStream.WriteData(FHTTPRec.LoginResult);
  fStream.WriteData(FHTTPRec.UseTryExt);

  if FHTTPRec.Encoding = TEncoding.Default then
    fStream.WriteData(byte(0))
  else if FHTTPRec.Encoding = TEncoding.ASCII then
    fStream.WriteData(byte(1))
  else if FHTTPRec.Encoding = TEncoding.UTF7 then
    fStream.WriteData(byte(2))
  else if FHTTPRec.Encoding = TEncoding.UTF8 then
    fStream.WriteData(byte(3))
  else if FHTTPRec.Encoding = TEncoding.UNICODE then
    fStream.WriteData(byte(4));

  WriteStr(FHTTPRec.PicTemplate.Name, fStream);
  WriteStr(FHTTPRec.PicTemplate.Ext, fStream);
  fStream.WriteData(FHTTPRec.PicTemplate.ExtFromHeader);

  WriteStr(FHTTPRec.TagTemplate.Spacer, fStream);
  WriteStr(FHTTPRec.TagTemplate.Separator, fStream);
  WriteStr(FHTTPRec.TagTemplate.Isolator, fStream);

  fStream.WriteData(FHTTPRec.EXIFTemplate.UseEXIF);
  WriteStr(FHTTPRec.EXIFTemplate.Author, fStream);
  WriteStr(FHTTPRec.EXIFTemplate.Title, fStream);
  WriteStr(FHTTPRec.EXIFTemplate.Theme, fStream);
  WriteStr(FHTTPRec.EXIFTemplate.Score, fStream);
  WriteStr(FHTTPRec.EXIFTemplate.Keywords, fStream);
  WriteStr(FHTTPRec.EXIFTemplate.Comment, fStream);

  fStream.WriteData(byte(FHTTPRec.Method));
  fStream.WriteData(FHTTPRec.StartCount);
  fStream.WriteData(FHTTPRec.MaxCount);
  fStream.WriteData(FHTTPRec.AddToMax);
  fStream.WriteData(FHTTPRec.Count);
  fStream.WriteData(FHTTPRec.Theor);
  fStream.WriteData(FHTTPRec.PageByPage);
  fStream.WriteData(FHTTPRec.TryAgain);
  fStream.WriteData(FHTTPRec.AcceptError);
  fStream.WriteData(FHTTPRec.PageDelay);
  fStream.WriteData(FHTTPRec.PicDelay);
  fStream.WriteData(FHTTPRec.DelayPostProc);
  fStream.WriteData(FHTTPRec.AddUnchecked);

  fStream.WriteData(FJobList.Count);
  for i := 0 to FJobList.Count - 1 do
  begin
    fStream.WriteData(FJobList[i].id);
    fStream.WriteData(FJobList[i].Status = JOB_FINISHED);
    WriteStr(FJobList[i].Url, fStream);
    WriteStr(FJobList[i].Referer, fStream);
  end;

end;

procedure TResource.SetFavorite(Value: Boolean);
begin
  FFavorite := Value;
  fUserFav := true;
end;

procedure TResource.SetThreadCounter(Value: pThreadCounter);
begin
  FThreadCounter := Value;
end;

procedure TResource.StartJob(JobType: Integer);
begin

  if not Assigned(FThreadCounter) then
    raise Exception.Create('Thread counter not assigned');

  case JobType of
    JOB_LIST:
      begin

        if (ThreadCounter.DefinedSettings.MaxThreadCount > 0) and
          ((ThreadCounter.DefinedSettings.MaxThreadCount <
          ThreadCounter.MaxThreadCount) or (ThreadCounter.MaxThreadCount = 0))
        then
          ThreadCounter.MaxThreadCount :=
            ThreadCounter.DefinedSettings.MaxThreadCount;

        if ThreadCounter.UseUserSettings and
          (ThreadCounter.UserSettings.MaxThreadCount > 0) and
          ((ThreadCounter.DefinedSettings.MaxThreadCount <
          ThreadCounter.MaxThreadCount) or (ThreadCounter.MaxThreadCount = 0))
        then
          ThreadCounter.MaxThreadCount :=
            ThreadCounter.UserSettings.MaxThreadCount;

        FHTTPRec.PageDelay := ThreadCounter.DefinedSettings.PageDelay;

        if ThreadCounter.UseUserSettings and
          (ThreadCounter.UserSettings.PageDelay > FHTTPRec.PageDelay) then
          FHTTPRec.PageDelay := ThreadCounter.UserSettings.PageDelay;

        FJobList.Reset;

        if (FJobList.Count > 0) and (FJobList.AllFinished(false)) then
          Exit;

        FJobInitiated := FJobList.Count > 0;

        if not FJobInitiated then
        begin
          // FHTTPRec.Counter := 0;
          if not Assigned(FInitialScript) then
            FInitialScript := TScriptSection.Create;

          FInitialScript.SectionName := FScripts.List;
          FInitialScript.ParseValues(FSectors[FScripts.List]);

          FJobList.Add(0);
        end;

        FHTTPRec.Count := FJobList.Count;
      end;
    JOB_LOGIN:
      begin

        ThreadCounter.MaxThreadCount := 1;

        if FScripts.Login <> '' then
        begin
          if not Assigned(FInitialScript) then
            FInitialScript := TScriptSection.Create;

          FInitialScript.SectionName := FScripts.Login;
          FInitialScript.ParseValues(FSectors[FScripts.Login]);
        end
        else if Assigned(FInitialScript) then
          FInitialScript.Clear;
      end;
    JOB_PICS:
      begin

        StartJob(JOB_POSTPROCESS);

        FHTTPRec.PicDelay := ThreadCounter.DefinedSettings.PicDelay;

        if ThreadCounter.UseUserSettings then
          if ThreadCounter.UserSettings.PicDelay > FHTTPRec.PicDelay then
            FHTTPRec.PicDelay := ThreadCounter.UserSettings.PicDelay;

        FPictureList.Reset;

        if not Assigned(FPicScript) then
        begin
          FPicScript := TScriptSection.Create;
          FPicScript.SectionName := FScripts.Download;
          FPicScript.ParseValues(FSectors[FScripts.Download]);
        end;

        // if (FPictureList.Count = 0) or (FPictureList.AllFinished(false,true)) then
        // Exit;

      end;
    JOB_POSTPROCESS:
      begin
        FPictureList.ResetPost;

        // if not Assigned(FPostProc) or (FPictureList.Count = 0) or
        // (FPictureList.PostProcessFinished) then
        // Exit;

        // FPictureThreadCount := 0;
      end;
  end;
end;

function TResource.StringFromFile(FName: string): string;
var
  f: TFileStream;
  ss: TStringStream;
  s: AnsiString;
begin
  f := TFileStream.Create(FName, FmOpenRead);
  try
    if f.Size > 0 then
    begin
      SetLength(s, f.Size);
      f.Read(s[1], 2);
    end;

    // f.Position := 0;

    if (Ord(s[1]) = $FF) and (Ord(s[2]) = $FE) then
      ss := TStringStream.Create(Result, TEncoding.UNICODE)
    else
      ss := TStringStream.Create;
    try
      ss.LoadFromStream(f);
      Result := ss.DataString;
    finally
      ss.Free;
    end;
  finally
    f.Free;
  end;
end;

function TResource.CreateFullFieldList: TStringList;
begin
  Result := nil;
end;

procedure TResource.CreateJob(t: TDownloadThread);
{ var
  n: integer; }
var
  id: Integer;
begin
  // t.JobId := ;

  if not JobInitiated then
  begin
    t.InitialScript := InitialScript;
    FJobInitiated := true;
  end
  else
    t.InitialScript := nil;

  t.HTTPRec := HTTPRec;

  if FHTTPRec.PageByPage then
    id := FJobList.LastJob(JOB_LIST)
  else
    id := -1;

  if id = -1 then
    id := FJobList.NextJob(JOB_LIST);

  if id > -1 then
  begin
    t.JobId := FJobList[id].id;

    if t.JobId = -1 then
    begin
      t.FHTTPRec.Url := '"' + FJobList[id].Url + '"';
      t.FHTTPRec.Referer := FJobList[id].Referer;
    end;
  end;

  t.JobIdx := id;
  t.JobComplete := JobComplete;

  // else
  // t.HTTPRec.Counter := t.JobId;
  t.BeforeScript := BeforeScript;
  t.AfterScript := AfterScript;
  t.XMLScript := XMLScript;
  t.DownloadRec := DownloadSet;
  t.Sectors := FSectors;
  t.LPictureList := FPictureList.Link;
  t.Fields := FFields;
  t.Resource := Self;
  t.Job := JOB_LIST;
  // inc(FHTTPRec.Counter);
  inc(FThreadCounter.CurrThreadCount);

  if not Assigned(FThreadCounter.CurrentResource) then
    FThreadCounter.CurrentResource := Self;

end;

procedure TResource.CreateLoginJob(t: TDownloadThread);
begin
  t.JobId := -1;
  t.JobIdx := 0;
  t.JobComplete := LoginJobComplete;
  t.InitialScript := nil;
  t.BeforeScript := nil;
  t.AfterScript := nil;
  t.XMLScript := nil;
  t.HTTPRec := HTTPRec;
  t.DownloadRec := DownloadSet;
  t.Sectors := FSectors;
  t.Fields := FFields;
  t.Resource := Self;
  t.Job := JOB_LOGIN;
  t.InitialScript := InitialScript;
  inc(FThreadCounter.CurrThreadCount);
end;

procedure TResource.CreatePicJob(t: TDownloadThread);
begin
  t.Picture := FPictureList.NextJob(JOB_PICS);
  t.JobIdx := FPictureList.LastJobIdx;
  t.JobComplete := PicJobComplete;
  t.InitialScript := FPicScript;
  t.DownloadRec := DownloadSet;
  t.HTTPRec := HTTPRec;
  t.Sectors := FSectors;
  t.LPictureList := FPictureList.Link;
  t.Fields := FFields;
  t.Resource := Self;
  t.Job := JOB_PICS;
  inc(FThreadCounter.PictureThreadCount);
end;

procedure TResource.CreatePostProcJob(t: TDownloadThread);
begin
  t.Picture := FPictureList.NextJob(JOB_POSTPROCESS);
  t.JobIdx := FPictureList.LastPostJobIdx;
  t.JobComplete := PostProcJobComplete;
  t.InitialScript := nil;
  t.PostProcessScript := FPostProc;
  t.DownloadRec := DownloadSet;
  t.HTTPRec := HTTPRec;
  t.Sectors := FSectors;
  t.LPictureList := FPictureList.Link;
  t.Fields := FFields;
  t.Resource := Self;
  t.Job := JOB_POSTPROCESS;
  inc(FThreadCounter.PictureThreadCount);
end;

// procedure TResource.SetSpacer(Value: Char);
// begin
{
  fSpacer := Value;
  if Assigned(fPictureList) then
  fPictureList.Tags.
}
// end;

procedure TResource.DeclorationEvent(ItemName: String; ItemValue: Variant;
  LinkedObj: TObject);
// loading main settings of resoruce

  function Clc(Value: Variant): Variant;
  begin
    Result := CalcValue(Value, nil, LinkedObj);
  end;

  procedure FillField(p: PResourceField; s: string; h: string = '');
  var
    v: string;
  begin
    if h = '' then
      v := Clc(nVal(s))
    else
      v := h;

    if SameText(v, 'textedit') then
      p.restype := ftString
    else if SameText(v, 'passwordedit') then
      p.restype := ftPassword
    else if SameText(v, 'integeredit') then
      p.restype := ftNumber
    else if SameText(v, 'floatedit') then
      p.restype := ftFloatNumber
    else if SameText(v, 'listbox') then
      p.restype := ftCombo
    else if SameText(v, 'indexlistbox') then
      p.restype := ftIndexCombo
    else if SameText(v, 'checkbox') then
      p.restype := ftCheck
    else if SameText(v, 'csvList') then
      p.restype := ftCSVList;

    p.resvalue := Clc(nVal(s));

    p.resitems := s;
  end;

  procedure ProcValue(ItemName: String; ItemValue: Variant);
  var
    s, v: String;
    FSct: TValueList;
    FSS: TScriptSection;
    i: Integer;
    f, p: PResourceField;
  begin
    if SameText(ItemName, '$main.url') then
      FHTTPRec.DefUrl := ItemValue
    else if SameText(ItemName, '$main.cheatsheet') then
      FCheatSheet := ItemValue
    else if SameText(ItemName, '$main.icon') then
      FIconFile := ItemValue
    else if SameText(ItemName, '$main.loginprompt') then
      FLoginPrompt := Boolean(ItemValue)
    else if SameText(ItemName, '$main.loginscript') then
      FScripts.Login := ItemValue
    else if SameText(ItemName, '$main.listscript') then
      FScripts.List := ItemValue
    else if SameText(ItemName, '$main.downloadscript') then
      FScripts.Download := ItemValue
    else if SameText(ItemName, '$main.short') then
      FShort := ItemValue
    else if SameText(ItemName, '$main.checkcookie') then
      FHTTPRec.CookieStr := ItemValue
    else if SameText(ItemName, '$main.login') then
      FHTTPRec.LoginStr := ItemValue
    else if SameText(ItemName, '$main.addtomax') then
      FHTTPRec.AddToMax := ItemValue
    else if SameText(ItemName, '$main.loginpost') then
      FHTTPRec.LoginPost := ItemValue
    else if SameText(ItemName, '$main.pagebypage') then
      FHTTPRec.PageByPage := ItemValue
    else if SameText(ItemName, '$main.threadcount') then
      ThreadCounter.DefinedSettings.MaxThreadCount := ItemValue
    else if SameText(ItemName, '$main.pagedelay') then
      // FHTTPRec.PageDelay := ItemValue
      ThreadCounter.DefinedSettings.PageDelay := ItemValue
    else if SameText(ItemName, '$main.picdelay') then
      // FHTTPRec.PicDelay := ItemValue
      ThreadCounter.DefinedSettings.PicDelay := ItemValue
    else if SameText(ItemName, '$main.keepqueue') then
      FKeepQueue := ItemValue
    else if SameText(ItemName, '$main.keywordhint') then
      FKeywordHint := ItemValue
    else if SameText(ItemName, '$main.favorite') then
      if not fUserFav then
        FFavorite := Boolean(ItemValue)
      else
    else if SameText(ItemName, '$picture.template.name') then
      FHTTPRec.PicTemplate.Name := ItemValue
    else if SameText(ItemName, '$picture.template.ext') then
      FHTTPRec.PicTemplate.Ext := ItemValue
    else if SameText(ItemName, '$main.extfromheader') then
      FHTTPRec.PicTemplate.ExtFromHeader := ItemValue
    else if SameText(ItemName, '$tags.spacer') then
      FHTTPRec.TagTemplate.Spacer := VarToStr(ItemValue)

    else if SameText(ItemName, '$tags.separator') then
      FHTTPRec.TagTemplate.Separator := VarToStr(ItemValue)
    else if SameText(ItemName, '$main.encoding') then
      if SameText('UTF8', ItemValue) then
        FHTTPRec.Encoding := TEncoding.UTF8
      else if SameText('DEFAULT', ItemValue) then
        FHTTPRec.Encoding := TEncoding.Default
      else if SameText('ASCII', ItemValue) then
        FHTTPRec.Encoding := TEncoding.ASCII
      else if SameText('UTF7', ItemValue) then
        FHTTPRec.Encoding := TEncoding.UTF7
      else if SameText('UNICODE', ItemValue) then
        FHTTPRec.Encoding := TEncoding.UNICODE
      else
        raise Exception.Create('Unknown encoding: ' + ItemValue)
    else if SameText(ItemName, '$tags.isolator') then
      if length(ItemValue) > 0 then
        FHTTPRec.TagTemplate.Isolator := VarToStr(ItemValue)
      else
    else if SameText(ItemName, '$picture.exif.author') then
      FHTTPRec.EXIFTemplate.Author := ItemValue
    else if SameText(ItemName, '$picture.exif.title') then
      FHTTPRec.EXIFTemplate.Title := ItemValue
    else if SameText(ItemName, '$picture.exif.theme') then
      FHTTPRec.EXIFTemplate.Theme := ItemValue
    else if SameText(ItemName, '$picture.exif.score') then
      FHTTPRec.EXIFTemplate.Score := ItemValue
    else if SameText(ItemName, '$picture.exif.keywords') then
      FHTTPRec.EXIFTemplate.Keywords := ItemValue
    else if SameText(ItemName, '$picture.exif.comment') then
      FHTTPRec.EXIFTemplate.Comment := ItemValue
    else if SameText(ItemName, '$main.delaypostprocess') then
      FHTTPRec.DelayPostProc := ItemValue
      // else if SameText(ItemName, '$main.checkfilenameext') then
      // FHTTPRec.CheckFNameExt := ItemValue
    else if SameText(ItemName, '$main.template') then
    begin
      s := StringFromFile(ExtractFilePath(FFileName) + ItemValue);
      FSct := TValueList.Create;
      try
        GetSectors(s, FSct);
        FSS := TScriptSection.Create;
        try
          FSS.ParseValues(FSct['main']);
          FSS.Process(nil, DeclorationEvent, nil, nil);
        finally
          FSS.Free;
        end;
        for i := 0 to FSct.Count - 1 do
        begin
          FSectors[FSct.Items[i].Name] := nullstr(FSectors[FSct.Items[i].Name])
            + #13#10 + FSct.Items[i].Value;
        end;
      finally
        FSct.Free;
      end;
    end
    else if SameText(ItemName, '@picture.fields') then
    begin
      FPicFieldList.Clear;
      s := ItemValue;
      while s <> '' do
      begin
        v := GetNextS(s, ',');
        FPicFieldList.Add(lowercase(TrimEx(v, [' ', #9, #10, #13])));
      end;
    end
    else if SameText(ItemName, '@addfield') then
    begin
      s := ItemValue;
      f := Fields.Items[Fields.AddField(Clc(nVal(s)), '', ftNone, null,
        '', false)];
      f.restitle := Clc(nVal(s));

      v := Clc(nVal(s));

      if SameText(v, 'multiedit') then
      begin
        f.restype := ftMultiEdit;
        i := 0;
        while s <> '' do
        begin
          inc(i);
          v := gVal(nVal(s));
          p := Fields.Items[Fields.AddField(f.resname + '[' + IntToStr(i) + ']',
            '', ftNone, null, '', true)];
          p.restitle := f.restitle;
          FillField(p, v);
        end;
        f.resvalue := i;
      end
      else
        FillField(f, s, v);
    end
    else if ItemName[1] = '$' then
    begin
      ItemName := DeleteEx(ItemName, 1, 1);
      i := Fields.FindField(ItemName);
      if i = -1 then
        Fields.AddField(ItemName, '', ftNone, ItemValue, '', false)
      else
        Fields.Items[i].resvalue := ItemValue;
    end
    else
      raise Exception.Create('incorrect decloration: ' + ItemName);

  end;

{ var
  i: integer;
  t: TListValue; }
begin
  { for i := 0 to Values.Count - 1 do
    begin
    t := Values.Items[i]; }
  ProcValue(ItemName, ItemValue);
  // end;
end;

function TResource.JobComplete(t: TDownloadThread): Integer;
// procedure, called when thread finish it job
var
  i, n: Integer;
  // s: LongInt;
begin
  try
    if (t.ReturnValue = THREAD_COMPLETE) and (t.Job <> JOB_ERROR) and
      not t.InitialScript.Empty then
    begin
      t.InitialScript := nil;

      if not t.BeforeScript.Empty then
      begin
        if not Assigned(FBeforeScript) then
          FBeforeScript := TScriptSection.Create;
        FBeforeScript.Assign(t.BeforeScript);
      end;

      if not t.AfterScript.Empty then
      begin
        if not Assigned(FAfterScript) then
          FAfterScript := TScriptSection.Create;
        FAfterScript.Assign(t.AfterScript);
      end;

      if not t.XMLScript.Empty then
      begin
        if not Assigned(FXMLScript) then
          FXMLScript := TScriptSection.Create;
        FXMLScript.Assign(t.XMLScript);
      end;

      if not t.PostProcessScript.Empty then
      begin
        if not Assigned(FPostProc) then
          FPostProc := TScriptSection.Create;
        FPostProc.Assign(t.PostProcessScript);
      end;

      FFields.Assign(t.Fields);
      HTTPRec := t.HTTPRec;

      for i := FJobList.Cursor to HTTPRec.Count - 1 do
        FJobList.Add(i);

      for i := 0 to length(t.URLList) - 1 do
      begin
        n := FJobList.Add(-1);
        FJobList[n].Url := t.URLList[i].val1;
        FJobList[n].Referer := t.URLList[i].val2;
      end;

      CheckIdle(true);

      // FJobInitiated := true;
    end
    else if length(t.URLList) > 0 then
    begin
      for i := 0 to length(t.URLList) - 1 do
      begin
        n := FJobList.Add(-1);
        FJobList[n].Url := t.URLList[i].val1;
        FJobList[n].Referer := t.URLList[i].val2;
      end;
      CheckIdle(true);
    end
    else if FHTTPRec.PageByPage and (t.JobIdx = FJobList.Count - 1) then
    begin
      FHTTPRec.Count := t.HTTPRec.Count;

      for i := FJobList.Count to HTTPRec.Count - 1 do
        FJobList.Add(i);

      CheckIdle(true);
    end;

  finally

    if (t.PicsAdded) then
    begin
      if Assigned(PictureList.Link.OnEndAddList) then
        PictureList.Link.OnEndAddList(Self);
    end;

    if t.ReturnValue = THREAD_COMPLETE then
      case t.Job of
        JOB_LIST:
          begin
            inc(FJobList.FOkCount);
            FJobList[t.JobIdx].Status := JOB_FINISHED;
          end;
        JOB_ERROR:
          begin
            if not t.InitialScript.Empty then
              FJobList.Clear
            else if t.JobIdx > 0 then
            begin
              inc(FJobList.FErrCount);
              FJobList[t.JobIdx].Status := JOB_ERROR;
            end;
            if Assigned(FOnError) then
              FOnError(Self, t.Error, nil);
          end;
      end
    else
    begin
      if not t.InitialScript.Empty then
        FJobList.Clear
      else
      begin
        if t.ReturnValue = THREAD_FINISH then
          FJobList[t.JobIdx].Status := JOB_CANCELED
        else
        begin
          inc(FJobList.FErrCount);
          FJobList[t.JobIdx].Status := JOB_ERROR;
        end;
      end;
    end;

    if Assigned(FOnPageComplete) then
      FOnPageComplete(Self);

    if (FJobList.AllFinished) and (FJobList.eol) then
    begin
      if FThreadCounter.CurrentResource = Self then
        FThreadCounter.CurrentResource := nil;

      FOnJobFinished(Self);
    end;

    dec(FThreadCounter.CurrThreadCount);
    Result := THREAD_START;

    // if Assigned(PostProcess) and not HTTPRec.DelayPostProc
    // and not PictureList.PostProcessFinished
    // and ResourceList.PicsFinished then
    // ResourceList.StartJob(JOB_POSTPROCESS);

  end;
end;

function TResource.LoginJobComplete(t: TDownloadThread): Integer;
begin
  if (t.ReturnValue <> THREAD_COMPLETE) or (t.Job = JOB_ERROR) then
  begin
    if t.ReturnValue = THREAD_FINISH then
      FOnError(Self, t.Resource.Name + ' login is canceled', nil)
    else if Assigned(FOnError) then
      if t.Error = '' then
        FOnError(Self, t.Resource.Name + ' unknown login error', nil)
      else
        FOnError(Self, t.Resource.Name + ' error: ' + t.Error, nil);
  end else
    FRelogin := false;
  FHTTPRec.LoginResult := t.HTTPRec.LoginResult;
  dec(FThreadCounter.CurrThreadCount);
  FOnJobFinished(Self);
  Result := THREAD_START;
end;

function TResource.PostProcJobComplete(t: TDownloadThread): Integer;
begin

  if not Assigned(t.Picture) then
  begin
    Result := THREAD_STOP;
    dec(FThreadCounter.PictureThreadCount);
    Exit;
  end;

  if not(t.ReturnValue in [THREAD_COMPLETE, THREAD_FINISH]) or
    (t.Job = JOB_ERROR) then
    if Assigned(FOnError) then
      FOnError(Self, t.Error, t.Picture);

  t.Picture.Size := 0;
  t.Picture.Lastpos := 0;
  t.Picture.Pos := 0;

  if t.ReturnValue = THREAD_COMPLETE then
    case t.Job of
      JOB_POSTPROCESS:
        begin
          t.Picture.PostProcessed := true;

          if t.PicsAdded then
            PictureList.RestartPostCursor(t.JobIdx);

          if Assigned(ResourceList) and ResourceList.UncheckBlacklisted and
            PictureList.Link.CheckBlackList(t.Picture) then
          begin
            t.Picture.Checked := false;
            t.Picture.Status := JOB_BLACKLISTED;
          end;

          if Assigned(t.Picture.OnPicChanged) then
            t.Picture.OnPicChanged(t.Picture, [pcProgress, pcData, pcChecked]);

          if t.Picture.Checked and ResourceList.PicDW then
            if t.PicsAdded then
            begin
              t.Picture.Status := JOB_NOJOB;
              PictureList.RestartCursor(t.JobIdx);
              PicCheckIdle(true);
            end
            else
            begin
              t.JobComplete := PicJobComplete;
              t.InitialScript := FPicScript;
              t.Job := JOB_PICS;
              t.Picture.Status := JOB_INPROGRESS;

              if t.ReturnValue = THREAD_COMPLETE then
                t.ReturnValue := THREAD_DOAGAIN;

              Result := THREAD_START;
              Exit;

            end
          else
          begin
            if t.Picture.Checked then
              t.Picture.Status := JOB_POSTFINISHED;
            if (FPictureList.PostProcessFinished) then
              FOnPicJobFinished(Self);
          end;

        end;
      JOB_CANCELED:
        t.Picture.Status := JOB_NOJOB;
    end
  else if t.ReturnValue = THREAD_FINISH then
  begin
    t.Picture.Status := JOB_CANCELED;
  end
  else
    t.Picture.Status := JOB_ERROR;

  dec(FThreadCounter.PictureThreadCount);
  Result := THREAD_START;
end;

procedure TResource.LoadConfigFromFile(FName: String);

var
  mainscript: TScriptSection;
  s: String;
begin
  if not fileexists(FName) then
    raise Exception.Create('file does not exist: ' + FName);

  // FTemplateFile := FName;
  FFileName := FName;
  s := StringFromFile(FName);

  GetSectors(s, FSectors);

  // mainscript := nil;

  if not Assigned(FThreadCounter) then
  begin
    New(FThreadCounter);
    // FThreadCounter.DefinedMaxThreadCount := 0;
    FThreadCounter.MaxThreadCount := 0;
    FThreadCounter.CurrThreadCount := 0;
    FThreadCounter.PictureThreadCount := 0;
    FThreadCounter.CurrentResource := nil;
    FThreadCounter.LastPageTime := 0;
    FThreadCounter.LastPicTime := 0;

    FThreadCounter.DefinedSettings.MaxThreadCount := 0;
    FThreadCounter.DefinedSettings.PicDelay := 0;
    FThreadCounter.DefinedSettings.PageDelay := 0;

    FThreadCounter.UserSettings.MaxThreadCount := 0;
    FThreadCounter.UserSettings.PicDelay := 0;
    FThreadCounter.UserSettings.PageDelay := 0;
    FThreadCounter.Queue := tThreadQueue.Create;
  end;

  mainscript := TScriptSection.Create;
  try
    try
      mainscript.SectionName := 'main';
      mainscript.ParseValues(Sectors['main']);
      mainscript.Process(nil, DeclorationEvent, nil, nil);
    except
      on e: Exception do
      begin
        e.Message := 'Resource load error (' + FName + '): ' + e.Message;
        raise;
      end;
    end;
  finally
    mainscript.Free;
  end;

  FResName := ChangeFileExt(ExtractFileName(FName), '');
end;

procedure TResource.LoadFromStream(fStream: tStream; fversion: word);
var
  path: string;
  i, n: Integer;
  rname: string;
  rvalue: Variant;
  b: byte;
  bl: Boolean;
begin
  path := ExtractFilePath(paramstr(0)) + 'resources\';
  FFileName := path + ReadStr(fStream);
  if not fileexists(FFileName) then
    raise Exception.Create('Resource file ' + FFileName + ' does not exist');
  LoadConfigFromFile(FFileName);
  FNameFormat := ReadStr(fStream);
  fStream.ReadData(FJobInitiated);
  rname := ReadStr(fStream);
  if rname <> '' then
  begin
    if not Assigned(FPostProc) then
      FPostProc := TScriptSection.Create;

    FPostProc.SectionName := rname;
    FPostProc.ParseValues(VarToStr(FSectors[rname]));
  end;

  rname := ReadStr(fStream);
  if rname <> '' then
  begin
    if not Assigned(FXMLScript) then
      FXMLScript := TScriptSection.Create;

    FXMLScript.SectionName := rname;
    FXMLScript.ParseValues(VarToStr(FSectors[rname]));
  end;

  // WriteStr(fPostProc.SectionName);
  // WriteStr(fXMLScript.SectionName);
  fStream.ReadData(FKeepQueue);
  fStream.ReadData(n);

  if n = -1 then
    with FThreadCounter^ do
    begin
      fStream.ReadData(DefinedSettings.MaxThreadCount);
      fStream.ReadData(DefinedSettings.PicDelay);
      fStream.ReadData(DefinedSettings.PageDelay);
      fStream.ReadData(UseUserSettings);
      fStream.ReadData(UserSettings.MaxThreadCount);
      fStream.ReadData(UserSettings.PicDelay);
      fStream.ReadData(UserSettings.PageDelay);
      fStream.ReadData(UseProxy);
    end
  else
  begin
    MainResource := ResourceList[n];
    FreeThreadCounter;
    FThreadCounter := MainResource.ThreadCounter;
  end;

  fStream.ReadData(n);

  for i := 0 to n - 1 do
  begin
    rname := ReadStr(fStream);
    rvalue := ReadVar(fStream);
    n := Fields.FindField(rname);
    if n = -1 then
      Fields.AddField(rname, '', ftNone, rvalue, '', false)
    else
      Fields.Items[n].resvalue := rvalue;
  end;

  FHTTPRec.DefUrl := ReadStr(fStream);
  FHTTPRec.Url := ReadStr(fStream);
  FHTTPRec.Post := ReadStr(fStream);
  FHTTPRec.Referer := ReadStr(fStream);
  FHTTPRec.ParseMethod := ReadStr(fStream);
  FHTTPRec.JSONItem := ReadStr(fStream);
  FHTTPRec.CookieStr := ReadStr(fStream);
  FHTTPRec.LoginStr := ReadStr(fStream);
  FHTTPRec.LoginPost := ReadStr(fStream);
  fStream.ReadData(FHTTPRec.LoginResult);
  fStream.ReadData(FHTTPRec.UseTryExt);

  fStream.ReadData(b);
  case b of
    0:
      FHTTPRec.Encoding := TEncoding.Default;
    1:
      FHTTPRec.Encoding := TEncoding.ASCII;
    2:
      FHTTPRec.Encoding := TEncoding.UTF7;
    3:
      FHTTPRec.Encoding := TEncoding.UTF8;
    4:
      FHTTPRec.Encoding := TEncoding.UNICODE;
  else
    raise Exception.Create('Unknown encoding');
  end;

  FHTTPRec.PicTemplate.Name := ReadStr(fStream);
  FHTTPRec.PicTemplate.Ext := ReadStr(fStream);
  fStream.ReadData(FHTTPRec.PicTemplate.ExtFromHeader);

  FHTTPRec.TagTemplate.Spacer := ReadStr(fStream);
  FHTTPRec.TagTemplate.Separator := ReadStr(fStream);
  FHTTPRec.TagTemplate.Isolator := ReadStr(fStream);

  fStream.ReadData(FHTTPRec.EXIFTemplate.UseEXIF);
  FHTTPRec.EXIFTemplate.Author := ReadStr(fStream);
  FHTTPRec.EXIFTemplate.Title := ReadStr(fStream);
  FHTTPRec.EXIFTemplate.Theme := ReadStr(fStream);
  FHTTPRec.EXIFTemplate.Score := ReadStr(fStream);
  FHTTPRec.EXIFTemplate.Keywords := ReadStr(fStream);
  FHTTPRec.EXIFTemplate.Comment := ReadStr(fStream);

  fStream.ReadData(byte(FHTTPRec.Method));
  fStream.ReadData(FHTTPRec.StartCount);
  fStream.ReadData(FHTTPRec.MaxCount);
  fStream.ReadData(FHTTPRec.AddToMax);
  fStream.ReadData(FHTTPRec.Count);
  fStream.ReadData(FHTTPRec.Theor);
  fStream.ReadData(FHTTPRec.PageByPage);
  fStream.ReadData(FHTTPRec.TryAgain);
  fStream.ReadData(FHTTPRec.AcceptError);
  fStream.ReadData(FHTTPRec.PageDelay);
  fStream.ReadData(FHTTPRec.PicDelay);
  fStream.ReadData(FHTTPRec.DelayPostProc);
  fStream.ReadData(FHTTPRec.AddUnchecked);

  fStream.ReadData(n);
  for i := 0 to n - 1 do
    with FJobList[FJobList.Add(0)]^ do
    begin
      fStream.ReadData(id);
      fStream.ReadData(bl);
      if bl then
        Status := JOB_FINISHED;
      Url := ReadStr(fStream);
      Referer := ReadStr(fStream);
    end;
  ResetRelogin;
end;

function TResource.PageDelayed: Boolean;
begin
  Result := MillisecondsBetween(ThreadCounter.LastPageTime, Date + Time) <
    FHTTPRec.PageDelay;
end;

function TResource.PicDelayed: Boolean;
begin
  Result := MillisecondsBetween(ThreadCounter.LastPicTime, Date + Time) <
    FHTTPRec.PicDelay;
end;

function TResource.PicJobComplete(t: TDownloadThread): Integer;
begin
  if not Assigned(t.Picture) then
  begin
    Result := THREAD_STOP;
    Exit;
  end;

  try
    inc(PictureList.Link.FPicCounter.FSH);
    inc(PictureList.FPicCounter.FSH);
    if Assigned(t.Picture.Parent) then
      inc(t.Picture.Parent.Linked.FPicCounter.FSH);

    if t.ReturnValue = THREAD_COMPLETE then
      case t.Job of
        JOB_PICS:
          begin
            if t.PicsAdded then
            begin
              t.Picture.Status := JOB_NOJOB;
              t.Picture.Size := 0;
              t.Picture.Lastpos := 0;
              t.Picture.Pos := 0;
              PictureList.RestartCursor(t.JobIdx);
              PicCheckIdle(true);
            end
            else
            begin
              t.Picture.Status := JOB_FINISHED;

              t.Picture.Checked := false;

              if t.Picture.Size = 0 then
              begin
                inc(PictureList.Link.FPicCounter.EXS);
                inc(PictureList.FPicCounter.EXS);
                if Assigned(t.Picture.Parent) then
                  inc(t.Picture.Parent.Linked.FPicCounter.EXS);
              end
              else
              begin
                inc(PictureList.Link.FPicCounter.OK);
                inc(PictureList.FPicCounter.OK);
                if Assigned(t.Picture.Parent) then
                  inc(t.Picture.Parent.Linked.FPicCounter.OK);
              end;

            end;

            if Assigned(t.Picture.OnPicChanged) then
              t.Picture.OnPicChanged(t.Picture,
                [pcChecked, pcProgress, pcData]);
          end;
        JOB_CANCELED:
          t.Picture.Status := JOB_NOJOB;

        JOB_ERROR:
          begin
            t.Picture.Status := JOB_ERROR;
            inc(PictureList.Link.FPicCounter.ERR);
            inc(PictureList.FPicCounter.ERR);

            if Assigned(t.Picture.Parent) then
            begin
              inc(t.Picture.Parent.Linked.FPicCounter.ERR);

              if Assigned(t.Picture.Parent.OnPicChanged) then
                t.Picture.Parent.OnPicChanged(t.Picture.Parent, [pcProgress]);
            end;

            if Assigned(t.Picture.OnPicChanged) then
              t.Picture.OnPicChanged(t.Picture, [pcProgress]);

            if Assigned(FOnError) then
              FOnError(Self, t.Error, t.Picture);
          end;
      end
    else if t.ReturnValue = THREAD_FINISH then
    begin
      t.Picture.Status := JOB_CANCELED;
      if Assigned(t.Picture.OnPicChanged) then
        t.Picture.OnPicChanged(t.Picture, [pcProgress]);

      if Assigned(t.Picture.Parent) then
      begin
        t.Picture.Parent.Status := JOB_CANCELED;

        if Assigned(t.Picture.Parent.OnPicChanged) then
          t.Picture.Parent.OnPicChanged(t.Picture.Parent, [pcProgress]);
      end;
    end
    else
    begin
      t.Picture.Status := JOB_ERROR;
      inc(PictureList.Link.FPicCounter.ERR);
      inc(PictureList.FPicCounter.ERR);
      if Assigned(t.Picture.OnPicChanged) then
        t.Picture.OnPicChanged(t.Picture, [pcProgress]);

      // stopsignal executed
      if t.StopSignal then
        if Assigned(ResourceList.OnSendStop) then
          ResourceList.OnSendStop(Self, t.StopMessage,
            Pointer(t.StopSignalTimer));
    end;

    if Assigned(t.Picture.Parent) then
    begin
      if (t.Picture.Parent.Linked.AllFinished(true, true)) then
      begin
        if t.Picture.Parent.Linked.PicCounter.ERR = 0 then
        begin
          t.Picture.Parent.Checked := false;
          t.Picture.Parent.Status := JOB_FINISHED;
        end
        else
          t.Picture.Parent.Status := JOB_ERROR;
        PictureList.RestartCursor(t.Picture.Parent.BookMark - 1);

      end;

      if Assigned(t.Picture.Parent.OnPicChanged) then
        t.Picture.Parent.OnPicChanged(t.Picture.Parent,
          [pcChecked, pcProgress]);
    end;

    if (FPictureList.eol) and (FPictureList.AllFinished(true, true)) then
    begin
      FOnPicJobFinished(Self);
    end;

  finally
    Result := THREAD_START;
    dec(FThreadCounter.PictureThreadCount);
  end;
end;

// TResourceLinkList

function TResourceLinkList.Get(Index: Integer): TResource;
begin
  Result := inherited Get(Index);
end;

procedure TResourceLinkList.GetAllResourceFields(List: TStrings);
var
  n, i, j: Integer;
begin
  if Count < 0 then
    Exit;
  if Items[0].FileName = '' then
    n := Items[0].Fields.Count
  else
    n := 0;

  for i := 0 to Count - 1 do
    for j := n to Items[i].Fields.Count - 1 do
    begin
      if (Items[i].Fields.Items[j].restype <> ftNone) and
        (List.IndexOf(Items[i].Fields.Items[j].resname) = -1) then
        List.Add(Items[i].Fields.Items[j].resname);
    end;

end;

procedure TResourceLinkList.GetAllPictureFields(List: TStrings;
  withparam: Boolean = false);
var
  i, j: Integer;
  l: TStringList;
  s: string;

  function AddItem(s: string): Integer;
  var
    i: Integer;
    R: string;
    n1, n2: string;
    d1, d2: string;
  begin
    R := s;
    n1 := GetNextS(s, ':');
    GetNextS(s, ':');
    d1 := s;
    for i := 0 to List.Count - 1 do
    begin
      s := List[i];
      n2 := GetNextS(s, ':');
      GetNextS(s, ':');
      d2 := s;
      if SameText(n1, n2) then
      begin
        if d2 = '' then
          List[i] := R;
        Result := i;
        Exit;
      end;
    end;

    Result := List.Add(R);
  end;

begin
  for i := 0 to Count - 1 do
  begin
    l := Items[i].PicFieldList;
    for j := 0 to l.Count - 1 do
    begin
      if withparam then
        AddItem(l[j])
      else
      begin
        s := CopyTo(l[j], ':');
        if List.IndexOf(s) = -1 then
          List.Add(s);
      end;
    end;
  end;
end;

// TResourceList

function TResourceList.AllFinished: Boolean;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Items[i].JobList.Reset;
    if (Items[i].JobList.Count = 0) or not Items[i].JobList.AllFinished(false)
    then
    begin
      Result := false;
      Exit;
    end;
  end;
  Result := true;
end;

function TResourceList.PostProcessFinished(incdelay: Boolean = false): Boolean;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if (not Items[i].HTTPRec.DelayPostProc or incdelay) and
      Assigned(Items[i].PostProcess) and not Items[i].PictureList.PostProcessFinished
    then
    begin
      Result := false;
      Exit;
    end;

  Result := true;
end;

function TResourceList.CopyResource(R: TResource): Integer;
var
  NR: TResource;
begin
  if not Assigned(R) then
    raise Exception.Create('copied resource is not assigned');

  NR := TResource.Create;
  // NR.AddToQueue := AddToQueue;
  NR.Assign(R);
  NR.PictureList.Link := PictureList;
  NR.CheckIdle := ThreadHandler.CheckIdle;
  NR.PicCheckIdle := DWNLDHandler.CheckIdle;
  NR.OnJobFinished := JobFinished;
  NR.OnPicJobFinished := PicJobFinished;
  NR.OnError := FOnError;
  NR.OnPageComplete := OnPageComplete;
  NR.ResourceList := Self;
  if NR.HTTPRec.DelayPostProc then
    fPostProcDelayed := true;
  // NR.PictureList.CheckDouble := CheckDouble;
  Result := Add(NR);
end;

constructor TResourceList.Create;
begin
  inherited;
  FThreadHandler := TThreadHandler.Create;
  FThreadHandler.OnAllThreadsFinished := OnHandlerFinished;
  FThreadHandler.CreateJob := CreateJob;
  FThreadHandler.Tag := 2;
  // FFinished := True;
  FDwnldHandler := TThreadHandler.Create;
  FDwnldHandler.OnAllThreadsFinished := OnHandlerFinished;
  FDwnldHandler.CreateJob := CreateDWNLDJob;
  FPictureList := TPictureList.Create(true);
  FPictureList.ResourceList := Self;
  FDwnldHandler.Tag := 3;
  fPostProcDelayed := false;
  fUncheckBlacklisted := true;

  FMaxThreadCount := 0;
  FMode := rmNormal;
  fPicDW := false;
end;

function TResourceList.CreateDWNLDJob(t: TDownloadThread): Boolean;

var
  // R { , DR } : TResource;
  i: Integer;
  n: Integer;

  function NextNotEOL(n: Integer): Integer;
  var
    i: Integer;

  begin
    if not fUseDist then
      dec(n);

    for i := n + 1 to Count - 1 do
    begin
      if fPicDW and not Items[i].PictureList.eol or
        Assigned(Items[i].PostProcess) and not(Items[i].PictureList.posteol)
      then
        Exit(i);
    end;

    for i := 0 to n do
    begin
      if fPicDW and not Items[i].PictureList.eol or
        Assigned(Items[i].PostProcess) and not(Items[i].PictureList.posteol)
      then
        Exit(i);
    end;

    Result := n;

  end;

  function doCreateJob(n: Integer; R: TResource;
    DoNextNotEOL: Boolean = false): Boolean;
  begin
    if (n > R.ThreadCounter.PictureThreadCount) then
    begin
      // if Assigned(r.PostProcess) then
      // R.PictureList.PostEOL;
      //
      // if fPicDW then
      // R.PictureList.eol;

      if Assigned(R.PostProcess) and not(R.PictureList.posteol) and
        not(fPicDW and (R.PictureList.PostProccessCursor > R.PictureList.Cursor))
      then
      begin
        R.CreatePostProcJob(t);
        if DoNextNotEOL then
          FPicQueue := NextNotEOL(FPicQueue);
        Exit(true);
      end
      else if fPicDW and not R.PictureList.eol then
      begin
        R.CreatePicJob(t);
        if DoNextNotEOL then
          FPicQueue := NextNotEOL(FPicQueue);
        Exit(true);
      end;
    end;

    Result := false;
  end;

begin
  // DR := R;

  // queue of tasks

  // check new task
  // from current to end

  if Items[FPicQueue].PictureList.eol then
    FPicQueue := NextNotEOL(FPicQueue);

  n := Items[FPicQueue].ThreadCounter.PictureThreadCount;

  for i := FPicQueue + 1 to Count - 1 do
    if doCreateJob(n, Items[i]) then
      Exit(true);

  // from start to current

  for i := 0 to FPicQueue - 1 do
    if doCreateJob(n, Items[i]) then
      Exit(true);
  { begin
    R := Items[i];
    if (n > R.ThreadCounter.PictureThreadCount) then
    if Assigned(Items[i].PostProcess) and not(Items[i].PictureList.posteol) then
    begin
    R.CreatePostProcJob(t);
    Exit(true);
    end
    else if fPicDW and not R.PictureList.eol then
    begin
    R.CreatePicJob(t);
    Exit(true);
    end;
    end;
  }

  Result := doCreateJob(DWNLDHandler.Count + 1, Items[FPicQueue], true);

  { R := Items[FPicQueue];

    if Assigned(R.PostProcess) and not R.PictureList.posteol then
    begin
    R.CreatePostProcJob(t);
    FPicQueue := NextNotEOL(FPicQueue);
    Result := true;
    Exit;
    end else if fPicDW and not R.PictureList.eol then
    begin
    R.CreatePicJob(t);
    FPicQueue := NextNotEOL(FPicQueue);
    Exit(true);
    end;
  }
  // if no task then result = false

  // Result := false;
end;

function TResourceList.AllPicsFinished: Boolean;
begin
  FPictureList.Reset;
  if not FPictureList.AllFinished(false) then
  begin
    Result := false;
    Exit;
  end;
  Result := true;
end;

procedure TResourceList.ApplyInherit;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    Items[i].ApplyInherit(Items[i].Parent);
end;

function TResourceList.CreateJob(t: TDownloadThread): Boolean;
var
  R, DR: TResource;
  i: Integer;

begin
  DR := nil;

  if FQueueIndex > Count - 1 then
    if FMode = rmLogin then
    begin
      Result := false;
      Exit;
    end
    else
      FQueueIndex := 0;

  // queue of tasks

  // check new task
  // from current to end

  for i := FQueueIndex to Count - 1 do
  begin
    R := Items[i];
    if FMode = rmLogin then
      if R.Relogin and ((R.ScriptStrings.Login <> '') or
        (R.HTTPRec.CookieStr <> '') and
        (t.HTTP.CookieList.GetCookieValue(R.HTTPRec.CookieStr,
        trim(DeleteTo(DeleteTo(lowercase(R.HTTPRec.DefUrl), ':/'), 'www.'), '/')
        ) = '')) then
      begin
        R.CreateLoginJob(t);
        Result := true;
        FQueueIndex := i + 1;
        Exit;
      end
      else
    else if (not(FPageMode and not R.NextPage) and
      (not R.JobInitiated or (not R.JobList.eol))) and R.CanAddThread then
      if not R.PageDelayed or (R.ThreadCounter.CurrThreadCount = 0) then
      begin
        R.CreateJob(t);
        R.NextPage := false;
        Result := true;

        if fUseDist then
          FQueueIndex := i + 1
        else
          FQueueIndex := i;

        Exit;
      end
      else if not Assigned(DR) or
        (R.ThreadCounter.LastPageTime < DR.ThreadCounter.LastPageTime) then
      begin
        DR := R;

        if fUseDist then
          FQueueIndex := i + 1
        else
          FQueueIndex := i;
      end;
  end;

  // from start to current
  if FMode = rmNormal then
    for i := 0 to FQueueIndex - 1 do
    begin
      R := Items[i];
      if (not(FPageMode and not R.NextPage) and
        (not R.JobInitiated or (not R.JobList.eol))) and R.CanAddThread then
        if not R.PageDelayed or (R.ThreadCounter.CurrThreadCount = 0) then
        begin
          R.CreateJob(t);
          R.NextPage := false;
          Result := true;

          if fUseDist then
            FQueueIndex := i + 1
          else
            FQueueIndex := i;

          Exit;
        end
        else if not Assigned(DR) or
          (R.ThreadCounter.LastPageTime < DR.ThreadCounter.LastPageTime) then
        begin
          DR := R;

          if fUseDist then
            FQueueIndex := i + 1
          else
            FQueueIndex := i;
        end;
    end;

  // if no task then result = false

  if Assigned(DR) then
  begin
    DR.CreateJob(t);
    DR.NextPage := false;
    Result := true;
    // inc(FQueueIndex);
    Exit;
  end;

  Result := false;

  if FMode = rmLogin then
    FThreadHandler.FinishQueue;

end;

procedure TResourceList.SetMaxThreadCount(Value: Integer);
begin
  FMaxThreadCount := Value;
end;

procedure TResourceList.SetOnPageComplete(Value: TNotifyEvent);
var
  i: Integer;
begin
  FOnResPageComplete := Value;
  for i := 0 to Count - 1 do
    Items[i].OnPageComplete := Value;
end;

procedure TResourceList.SetOnError(Value: TLogEvent);
var
  i: Integer;
begin
  FOnError := Value;
  FThreadHandler.OnError := Value;
  FDwnldHandler.OnError := Value;
  for i := 0 to Count - 1 do
    Items[i].OnError := Value;
end;

function TResourceList.GetListFinished: Boolean;
begin
  Result := (ThreadHandler.Count = 0) { and
    ((FMode <> rmPostProcess) or (DWNLDHandler.Count = 0)) };
end;

function TResourceList.GetPicsFinished: Boolean;
begin
  Result := (DWNLDHandler.Count = 0) { or (FMode = rmPostProcess) };
end;

procedure TResourceList.HandleKeywordList;
var
  i, j, l: Integer;
  n: Integer;
begin
  // at first handle "general" keyword list

  n := Count - 1;
  for i := 0 to n do
    if (Items[i].KeywordList.Count > 0) then
    begin
      Items[i].Fields['tag'] := Items[i].KeywordList[0];
      for j := 1 to Items[i].KeywordList.Count - 1 do
      begin
        l := CopyResource(Items[i]);
        Items[l].Fields['tag'] := Items[i].KeywordList[j];
        Items[l].Parent := Items[i].Parent;
      end;
    end;
end;

procedure TResourceList.HandleParentLinks;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    if Items[i].Parent.MainResource = nil then
      Items[i].Parent.MainResource := Items[i]
    else
      Items[i].MainResource := Items[i].Parent.MainResource;
    Items[i].SetThreadCounter(Items[i].Parent.ThreadCounter);

    Items[i].Parent := nil;
  end;
end;

function TResourceList.ItemByName(AName: String): TResource;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if SameText(Items[i].Name, AName) then
    begin
      Result := Items[i];
      Exit;
    end;
  Result := nil;
end;

destructor TResourceList.Destroy;
// var
// i: integer;
begin
  FThreadHandler.Free;
  FDwnldHandler.Free;
  FPictureList.Free;

  // for i := 0 to Count -1 do
  // Items[i].Free;
  Clear;
  inherited;
end;

function TResourceList.findByName(rname: string): integer;
var
  i: integer;
begin
  for i := 0 to Count-1 do
    if Sametext(rname,Items[i].Name) then
      Exit(i);
  Result := -1
end;

procedure TResourceList.CreatePicFields;
var
  i, j: Integer;
  l, f: TStringList;
  p: TMetaList;
  s, n: string;
begin
  f := TStringList.Create;
  try
    if Count < 1 then
      Exit;
    f.Assign(Items[0].PicFieldList);
    for i := 1 to Count - 1 do
    begin
      l := Items[i].PicFieldList;
      for j := 0 to l.Count - 1 do
        if f.IndexOf(l[j]) = -1 then
          f.Add(l[j]);
    end;

    for i := 0 to f.Count - 1 do
    begin
      s := f[i];
      n := GetNextS(s, ':');

      p := FPictureList.Meta[n];
      if p = nil then
      begin
        p := TMetaList.Create;
        if s <> '' then
          case s[1] of
            'i':
              p.ValueType := ftInteger;
            'd':
              p.ValueType := ftDateTime;
            'b':
              p.ValueType := ftBoolean;
            'f', 'p':
              p.ValueType := ftFloat;
          else
            p.ValueType := DB.ftString;
          end
        else
          p.ValueType := DB.ftString;
        FPictureList.Meta[n] := p;
      end;
    end;

    // l.Free;
  finally
    f.Free;
  end;
end;

function TResourceList.CreateResource: Integer;
var
  R: TResource;
begin
  R := TResource.Create;
  R.PictureList.Link := PictureList;
  R.CheckIdle := ThreadHandler.CheckIdle;
  R.PicCheckIdle := DWNLDHandler.CheckIdle;
  R.OnJobFinished := JobFinished;
  R.OnPicJobFinished := PicJobFinished;
  R.OnError := FOnError;
  R.OnPageComplete := OnPageComplete;
  R.ResourceList := Self;
  Result := Add(R);
  { if not Assigned(R) then
    raise Exception.Create('copied resource is not assigned');

    NR := TResource.Create;
    // NR.AddToQueue := AddToQueue;
    NR.Assign(R);
    NR.PictureList.Link := PictureList;
    NR.CheckIdle := ThreadHandler.CheckIdle;
    NR.PicCheckIdle := DWNLDHandler.CheckIdle;
    NR.OnJobFinished := JobFinished;
    NR.OnPicJobFinished := PicJobFinished;
    NR.OnError := FOnError;
    NR.OnPageComplete := OnPageComplete;
    NR.ResourceList := Self;
    if NR.HTTPRec.DelayPostProc then
    fPostProcDelayed := true;
    // NR.PictureList.CheckDouble := CheckDouble;
    Result := Add(NR); }
end;

procedure TResourceList.JobFinished(R: TResource);
var
  i: Integer;

begin
  if FMode = rmLogin then
  begin
    if (R.ScriptStrings.Login = '') and
      (ThreadHandler.Cookies.GetCookieValue(R.HTTPRec.CookieStr,
      trim(DeleteTo(DeleteTo(lowercase(R.HTTPRec.DefUrl), ':/'), 'www.'), '/'))
      = '') or (R.ScriptStrings.Login <> '') and not(R.HTTPRec.LoginResult) then
      if Assigned(FOnError) then
        FOnError(Self, R.Name + ': login is failed', nil);

    for i := 0 to Count - 1 do
      if Items[i].Relogin then
        Exit;

    FStopTick := 0;
    ThreadHandler.FinishQueue;
  end
  else
  begin
    if { not ThreadHandler.Finishing and } not PicsFinished then
      FDwnldHandler.CheckIdle(true);

    for i := 0 to Count - 1 do
      if not Items[i].JobList.AllFinished then
        Exit;

    FStopTick := 0;
    ThreadHandler.FinishQueue;
  end;

end;

function TResourceList.NeedRelogin: boolean;
var
  i: integer;
begin
  for i := 0 to Count-1 do
    if Items[i].Relogin then
      Exit(true);
  Result := false;
end;

procedure TResourceList.NextPage;
var
  i: Integer;

begin
  for i := 0 to Count - 1 do
    if not Items[i].JobList.eol then
    begin
      Items[i].NextPage := true;
      ThreadHandler.CheckIdle;
    end;
end;

procedure TResourceList.Notify(Ptr: Pointer; Action: TListNotification);
var
  p: TResource;
begin
  case Action of
    lnDeleted:
      begin
        p := Ptr;
        p.Free;
      end;
  end;
end;

procedure TResourceList.StartJob(JobType: Integer);
var
  i: Integer;
  pf: Boolean;

begin
  case JobType of
    JOB_STOPLIST:
      begin
        if FStopTick = 0 then
        begin
          FStopTick := GetTickCount;
          FThreadHandler.FinishThreads(false);
          if not PicsFinished and not PicDW then
            FDwnldHandler.FinishThreads(false);
          // if FMode = rmPostProcess then
          // FDwnldHandler.FinishThreads(false);
        end
        else if (FStopTick - GetTickCount) > 5000 then
        begin
          FStopTick := 0;
          FThreadHandler.FinishThreads(true);
          if not PicsFinished and not PicDW then
            FDwnldHandler.FinishThreads(true);
          for i := 0 to Count - 1 do
            if Assigned(Items[i].ThreadCounter) then
              Items[i].ThreadCounter.Queue.Dismiss;
          // if FMode = rmPostProcess then
          // FDwnldHandler.FinishThreads(true);
        end;
        FCanceled := true;
      end;
    JOB_STOPPICS:
      begin
        if FStopPicsTick = 0 then
        begin
          FStopPicsTick := GetTickCount;
          FDwnldHandler.FinishThreads(false);
        end
        else if (FStopPicsTick - GetTickCount) > 5000 then
        begin
          FStopPicsTick := 0;
          FDwnldHandler.FinishThreads(true);
          for i := 0 to Count - 1 do
            Items[i].ThreadCounter.Queue.Dismiss;
        end;
        FCanceled := true;
        fPicDW := false;
      end;
    JOB_LIST:
      if ListFinished then
      begin
        for i := 0 to Count - 1 do
         if Items[i].Relogin then
         begin
           StartJOB(JOB_LOGIN);
           Exit;
         end;

        FMode := rmNormal;

        if AllFinished then
        begin
          for i := 0 to Count - 1 do
            Items[i].PictureList.ResetPost;

          if not PicDW and not PostProcessFinished(true) then
          begin
            StartJob(JOB_POSTPROCESS);
            if Assigned(FJobChanged) then
              FJobChanged(Self, JobType);
            Exit;
          end
          else
            Exit;
        end;

        FQueueIndex := 0;
        ThreadHandler.CreateThreads;
        for i := 0 to Count - 1 do
        begin
          with Items[i] do
          begin
            ThreadCounter.MaxThreadCount := MaxThreadCount;
            StartJob(JobType);
            if not FPageMode and (not JobList.eol) then
              ThreadHandler.CheckIdle;
          end;
        end;

        if Assigned(FJobChanged) then
          FJobChanged(Self, JobType);

        if FPageMode then
          NextPage;

        FListStart := Date + Time;

        FCanceled := false;
      end;
    JOB_LOGIN:
      if ListFinished then
      begin
        pf := false;
        for i := 0 to Count - 1 do
        begin
          pf := pf or Items[i].Relogin;
          if Items[i].Relogin then
            with Items[i] do
              // ThreadCounter.MaxThreadCount := 1;
              StartJob(JobType);
        end;

        if not pf then
          Exit;

        FQueueIndex := 0;
        FMode := rmLogin;
        ThreadHandler.CreateThreads;
        ThreadHandler.CheckIdle;

        if Assigned(FJobChanged) then
          FJobChanged(Self, JobType);

        FListStart := Date + Time;

        FCanceled := false;
      end;
    JOB_PICS:
      if PicsFinished or not fPicDW then
      begin
        if { ListFinished and } AllPicsFinished then
          Exit;
        // FPictureList.Reset;
        fPicDW := true;

        pf := PicsFinished;

        if PicsFinished then
        begin
          FPicQueue := 0;
          FDwnldHandler.CreateThreads;
        end;

        for i := 0 to Count - 1 do
        begin
          with Items[i] do
          begin
            // MaxThreadCount := MaxThreadCount;
            { if Inherit then
              PictureList.NameFormat := PicFileFormat; }
            Items[i].FHTTPRec.EXIFTemplate.UseEXIF := WriteEXIF;
            if pf then
              FPictureList.ResetPost;
            StartJob(JobType);
            if not FPictureList.eol then
              FDwnldHandler.CheckIdle(true)
            else if (FPicQueue = i) and PicsFinished then
              inc(FPicQueue);
          end;
        end;

        if Assigned(FJobChanged) then
          FJobChanged(Self, JobType);

        FPicStart := Date + Time;

        FCanceled := false;
      end;
    JOB_POSTPROCESS:
      if PicsFinished and not ThreadHandler.Finishing then
      begin
        if PostProcessFinished(true) then
          Exit;

        FPicQueue := 0;
        // FMode := rmPostProcess;
        FDwnldHandler.CreateThreads;
        for i := 0 to Count - 1 do
          if not Items[i].PictureList.PostProcessFinished then
          begin
            Items[i].StartJob(JobType);
            FDwnldHandler.CheckIdle;
          end
          else if i = FPicQueue then
            inc(FPicQueue);

        if Assigned(FJobChanged) then
          FJobChanged(Self, JobType);

        FPicStart := Date + Time;

        FCanceled := false;
      end;
  end;
  // ThreadHandler.CheckIdle(true);
end;

procedure TResourceList.UncheckDoubles;
{ var
  i,j: integer; }
begin
  { for i := 0 to Count -1 do
    for j := Items[i].PictureList.Count-1 downto 0 do
    if Items[i].PictureList[j].Checked then
    CheckDouble(Items[i].PictureList[j],i,j + 1); }
  // Result := false;
end;

{ procedure TResourceList.AddToQueue(R: TResource);
  begin
  FThreadHandler.AddToQueue(R);
  end; }

procedure TResourceList.SetPageMode(Value: Boolean);
begin
  if ListFinished then
    FPageMode := Value;
end;

procedure TResourceList.OnHandlerFinished(Sender: TObject);
begin
  if Sender = FThreadHandler then
    if (FThreadHandler.Count = 0) then
    begin
      FStopTick := 0;
      if Assigned(FJobChanged) and ListFinished then
        FJobChanged(Self, JOB_STOPLIST);
      if FMode = rmLogin then
        FMode := rmNormal;
    end
    else
  else if Sender = FDwnldHandler then
    if (FDwnldHandler.Count = 0) then
    begin
      FStopPicsTick := 0;
      if Assigned(FJobChanged) then
        FJobChanged(Self, JOB_STOPPICS);
    end;
end;

procedure TResourceList.PicJobFinished(R: TResource);
var
  i: Integer;

begin
  for i := 0 to Count - 1 do
    if not Items[i].PictureList.AllFinished(true, true) or not ListFinished then
      Exit;
  // fPicDW := false;
  FStopPicsTick := 0;
  FDwnldHandler.FinishQueue;
  // if FMode = rmPostProcess then
  // FThreadHandler.FinishQueue;
end;

procedure TResourceList.LoadFromFile(FName: string; fCB: TCallBackProgress);
var
  f: TFileStream;
  z: tDecompressionStream;
  v: Integer;
begin
  f := TFileStream.Create(FName, FmOpenRead);
  try
    z := tDecompressionStream.Create(f, 15);
    try
      z.ReadData(v);
      // f.ReadData(v);
      LoadFromStream(z, v, fCB);
    finally
      z.Free;
    end;
  finally
    f.Free;
  end;
end;

procedure TResourceList.LoadFromStream(fStream: tStream; fversion: word;
  fCB: TCallBackProgress);
var
  b: byte;
  w: Integer;
  i: Integer;
  R: TResource;
begin
  fStream.ReadData(FMaxThreadCount);
  fStream.ReadData(fPostProcDelayed);
  fStream.ReadData(b);
  fSemiListJob := tSemiListJob(b);
  fStream.ReadData(fUncheckBlacklisted);
  fStream.ReadData(fUseDist);
  fStream.ReadData(fWriteEXIF);
  fStream.ReadData(w);

  for i := 0 to w - 1 do
  begin
    R := Items[CreateResource];
    R.LoadFromStream(fStream, fversion);
  end;
  CreatePicFields;

  PictureList.LoadFromStream(fStream, fversion, fCB);
  {
    for i := 0 to PictureList.Count - 1 do
    begin
    w := PictureList[i].ResourceIndex;
    PictureList[i].Resource := Items[w];
    Items[w].PictureList.Add(PictureList[i]);
    if Assigned(Items[w].Parent) then
    inc(Items[w].PictureList.FChildCount)
    else
    inc(Items[w].PictureList.FParentCount);
    end;
  }
end;

procedure TResourceList.LoadList(Dir: String);
var
  a: TSearchRec;
  R: TResource;

begin
  Clear;

  R := TResource.Create;
  r.IsNew := true;
  R.Inherit := false;
  R.Name := 'general';
  R.PictureList.Link := PictureList;
  R.CheckIdle := ThreadHandler.CheckIdle;
  R.PicCheckIdle := DWNLDHandler.CheckIdle;
  R.OnJobFinished := JobFinished;
  R.OnPicJobFinished := PicJobFinished;
  R.OnError := FOnError;
  R.OnPageComplete := OnPageComplete;
  Add(R);

  R := nil;

  if not DirectoryExists(Dir) then
  begin
    if Assigned(FOnError) then
      FOnError(Self, 'directory does not exist: ' + Dir, nil);
    Exit;
  end;
  Dir := IncludeTrailingPathDelimiter(Dir);

  if FindFirst(Dir + '*.cfg', faAnyFile, a) = 0 then
  begin
    repeat
      try
        R := TResource.Create;
        R.LoadConfigFromFile(Dir + a.Name);
        R.Parent := Items[0];
        R.PictureList.Link := PictureList;
        R.CheckIdle := ThreadHandler.CheckIdle;
        R.PicCheckIdle := DWNLDHandler.CheckIdle;
        R.OnJobFinished := JobFinished;
        R.OnPicJobFinished := PicJobFinished;
        R.OnError := FOnError;
        R.OnPageComplete := OnPageComplete;
        R.ResourceList := Self;
        Add(R);
      except
        on e: Exception do
        begin
          if Assigned(FOnError) then
            FOnError(Self, e.Message, nil);
          if Assigned(R) then
            R.Free;
        end;

      end;
    until FindNext(a) <> 0;

  end;
end;

procedure TResourceList.SaveToFile(FName: string; fCB: TCallBackProgress);
var
  z: tCompressionStream;
  f: TFileStream;
begin
  f := TFileStream.Create(FName, fmCreate or fmOpenWrite);
  try
    z := tCompressionStream.Create(f, zcFastest, 15);
    try
      z.WriteData(SAVEFILE_VERSION);
      // f.WriteData(SAVEFILE_VERSION);
      SaveToStream(z, fCB);
    finally
      z.Free;
    end;
  finally
    f.Free;
  end;
end;

procedure TResourceList.SaveToStream(fStream: tStream; fCB: TCallBackProgress);
var
  i: Integer;
begin
  fStream.WriteData(FMaxThreadCount);
  fStream.WriteData(fPostProcDelayed);
  fStream.WriteData(byte(fSemiListJob));
  fStream.WriteData(fUncheckBlacklisted);
  fStream.WriteData(fUseDist);
  fStream.WriteData(fWriteEXIF);

  for i := 0 to Count - 1 do
  begin
    // if Assigned(fCB) then
    // fCB(i+1,Count);
    Items[i].SaveIndex := i;
  end;

  // PictureList.SavePrepare;

  fStream.WriteData(Count);
  for i := 0 to Count - 1 do
    Items[i].SaveToStream(fStream);

  PictureList.SaveToStream(fStream, fCB);

end;

procedure TResourceList.SetLogMode(Value: Boolean);
begin
  FLogMode := Value;
  FThreadHandler.LogMode := Value;
  FDwnldHandler.LogMode := Value;
end;

// TDownloadThread

procedure TDownloadThread.Execute;
var
  oldstat: Integer;
begin
  // ReturnValue := THREAD_STOP;

  while not terminated do
  begin
    // FErrorString := '';
    if not(ReturnValue in [THREAD_DOAGAIN]) then
    begin
      FPicture := nil;
      FResource := nil;
    end;

    FURLList := nil;
    FPostProc.Clear;
    FErrorScript.Clear;
    FPicList.Clear;
    FPicsAdded := false;
    FHTTP.HandleRedirects := true;
    FSkipMe := false;
    FStopSignal := false;
    fResultURL := '';

    try

      Synchronize(DoFinish);

      case ReturnValue of
        THREAD_PROCESS:
          Continue;
        THREAD_STOP:
          begin
            ResetEvent(FEventHandle);
            WaitForSingleObject(FEventHandle, INFINITE);
            Continue;
          end;
        THREAD_FINISH:
          begin
            Break;
          end;
      end;

      if not Assigned(FResource) then
        raise Exception.Create('thread.execute: resource not assigned, ' +
          ' job = ' + IntToStr(FJob) + ', return = ' + IntToStr(ReturnValue));

      try
        if Job in [JOB_PICS, JOB_POSTPROCESS] then
        begin
          if not Assigned(FPicture) then
            raise Exception.Create
              ('thread.execute: picture for picture job not assigned');
          oldstat := FPicture.Status;
          FPicture.Status := JOB_REFRESH;
          FPicture.Changes := [pcProgress];
          Synchronize(PicChanged);
          FPicture.Status := oldstat;
          HTTP.OnWorkBegin := IdHTTPWorkBegin;
          HTTP.OnWork := IdHTTPWork;
        end
        else
        begin
          HTTP.OnWorkBegin := nil;
          HTTP.OnWork := nil;
        end;

        if Job = JOB_LOGIN then
          if not FInitialScript.Empty then
          begin
            FInitialScript.Process(SE, DE, FE, VE, VE);
          end
          else
            ProcLogin
        else if Job = JOB_POSTPROCESS then
          ProcPost
        else
        begin
          if not FInitialScript.Empty then
          begin
            FInitialScript.Process(SE, DE, FE, VE, VE);

            if StopSignal then
              raise Exception.Create(fStopMessage);

          end
          else if Job = JOB_LIST THEN
            ProcHTTP;

          if (Job = JOB_PICS) and (ReturnValue <> THREAD_FINISH) then
            ProcPic;

        end;

        if Self.ReturnValue <> THREAD_FINISH then
          Self.ReturnValue := THREAD_COMPLETE
      finally

        Synchronize(DoJobComplete);

      end;
    except
      on e: Exception do
      begin
        if Assigned(FResource) then
          FErrorString := FResource.Name + ': ' + e.Message
        else
          FErrorString := e.Message;

        if FSTOPERROR then
          Break
        else
          FSTOPERROR := true;
      end;
    end;
  end;
end;

function TDownloadThread.AddChild: TTPicture;
// var
// pic: TTPicture;
begin
  FChild := TTPicture.Create;
  FChild.Checked := not FHTTPRec.AddUnchecked;
  FChild.Parent := FPicture;
  if not(Job in [JOB_PICS, JOB_POSTPROCESS]) then
    FPicture.Linked.Add(FChild);
  FPicList.Add(FChild, FResource);
  Result := FChild;
end;

function TDownloadThread.AddPicture: TTPicture;
begin
  FPicture := TTPicture.Create;
  FPicture.Checked := not FHTTPRec.AddUnchecked;;
  FPicList.Add(FPicture, FResource);
  Result := FPicture;
end;

function TDownloadThread.AddURLToList(s: String; Referer: String = ''): Integer;
begin
  SetLength(FURLList, length(FURLList) + 1);
  FURLList[length(FURLList) - 1].val1 := s;
  FURLList[length(FURLList) - 1].val2 := Referer;
  Result := length(FURLList) - 1;
end;

procedure TDownloadThread.ClonePicture;
var
  fpic: TTPicture;
begin
  fpic := TTPicture.Create;
  fpic.Checked := true;
  fpic.Assign(FPicture, true);
  FPicList.Add(fpic, FResource);
  FPicture := fpic;
end;

constructor TDownloadThread.Create;
begin
  ReturnValue := THREAD_STOP;
  FEventHandle := CreateEvent(nil, true, false, nil);
  FFinish := nil;
  inherited Create(false);
  FHTTP := CreateHTTP;
  FSSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(FHTTP);
  // fSSLHandler.Owner := fHTTP;
  FHTTP.IOHandler := FSSLHandler;
  fSocksInfo := tidSocksInfo.Create(FSSLHandler);
  // fSocksInfo.Owner := fSSLHandler;
  FSSLHandler.TransparentProxy := fSocksInfo;
  FInitialScript := TScriptSection.Create;
  FBeforeScript := TScriptSection.Create;
  FAfterScript := TScriptSection.Create;
  FXMLScript := TScriptSection.Create;
  FErrorScript := TScriptSection.Create;
  FPostProc := TScriptSection.Create;
  FFields := TResourceFields.Create;
  FXML := TMyXMLParser.Create;
  FPicList := TPictureList.Create(false);
  FPicture := nil;
  FSectors := TValueList.Create;
  FSTOPERROR := false;
  FJobComplete := nil;
  FURLList := nil;
end;

destructor TDownloadThread.Destroy;
begin
  CloseHandle(FEventHandle);
  FInitialScript.Free;
  FBeforeScript.Free;
  FAfterScript.Free;
  FXMLScript.Free;
  FPostProc.Free;
  FErrorScript.Free;
  FFields.Free;
  FXML.Free;
  FHTTP.Free;
  // FSSLHandler.Free;
  // fSocksInfo.Free;
  FPicList.Free;
  FSectors.Free;
  inherited;
end;

procedure TDownloadThread.DoJobComplete;
begin
  if Assigned(FJobComplete) then
    FJobComplete(Self);
end;

procedure TDownloadThread.DoFinish;
begin
  ReturnValue := Finish(Self);
end;

function TDownloadThread.SE(const Item: TScriptSection;
  const parameters: TValueList; LinkedObj: TObject;
  var ResultObj: TObject): Boolean;

  function copytag(s: ttag): ttag;
  begin
    Result := ttag.Create(s.Name, s.Kind);
    Result.Attrs.Assign(s.Attrs);
    Result.Childs.CopyList(s.Childs, Result);
    Result.Tag := s.Tag;
  end;

var
  l, s: TTagList;
  p: TWorkList;
  i, j: Integer;
  a: array of TAttrList;
  Tags: array of string;
  // tmp: ttag;
begin
  if Assigned(LinkedObj) and ((LinkedObj is TTagList) or (LinkedObj is ttag))
  then
  begin
    if (LinkedObj is ttag) then
      if (LinkedObj as ttag).Tag = 0 then
      begin
        // tmp := (LinkedObj as TTag).Name;
        s := (LinkedObj as ttag).Childs;
      end
      else
      begin
        Result := true;
        (LinkedObj as ttag).Tag := 0;
        Exit;
      end
    else
      s := LinkedObj as TTagList;

    // l := nil;
    // tmp := ttag.Create('derp',tktext);

    // l.Add(tmp);
    // l := nil;
    case Item.Kind of
      sikSection:
        begin
          l := TTagList.Create;
          try
            SetLength(a, 1);

            a[0] := TAttrList.Create;
            try
              for i := 0 to parameters.Count - 1 do
                a[0].Add(Copy(parameters.Items[i].Name, 1,
                  length(parameters.Items[i].Name) - 1),
                  VarToStr(parameters.Items[i].Value),
                  parameters.Items[i].Name[length(parameters.Items[i].Name)]);

              // if Item.NoParameters then
              // a[0].NoParameters := Item.NoParameters;

              a[0].NoParameters := Item.NoParameters;
              s.GetList(Item.Name, a[0], l);
            finally
              a[0].Free;
              SetLength(a, 0);
            end;

            ResultObj := l;

            Result := l.Count > 0;
          except
            l.Free;
            raise;
          end;
        end;
      sikGroup:
        begin
          l := TTagList.Create;
          try

            SetLength(Tags, Item.ChildSections.Count);
            SetLength(a, Item.ChildSections.Count);

            for j := 0 to Item.ChildSections.Count - 1 do
              a[j] := nil;

            for j := 0 to Item.ChildSections.Count - 1 do
              with (Item.ChildSections[j] as TScriptSection) do
              begin
                // Tags[j] :=  Item.ChildSections[j].ClassName;
                Tags[j] := Name;
                a[j] := TAttrList.Create;
                a[j].Tag := Integer(Item.ChildSections[j]);

                for i := 0 to parameters.Count - 1 do
                  a[j].Add(Copy(parameters.Items[i].Name, 1,
                    length(parameters.Items[i].Name) - 1),
                    VarToStr(CalcValue(parameters.Items[i].Value, VE, LinkedObj)
                    ), parameters.Items[i].Name
                    [length(parameters.Items[i].Name)]);

                a[j].NoParameters := NoParameters;
              end;

            try

              s.GetGroupList(Tags, a, l);

            finally
              for j := 0 to length(a) - 1 do
                if Assigned(a[j]) then
                  a[j].Free;

              SetLength(Tags, 0);
              SetLength(a, 0);
            end;

            p := TWorkList.Create;
            try
              for j := 0 to l.Count - 1 do
                p.Add(TScriptSection(l[j].Tag), copytag(l[j]));

              ResultObj := p;
              Result := p.Count > 0;

            except
              on e: Exception do
              begin
                p.Free;
                Result := false;
                raise;
              end;
            end;

          finally
            l.Free;
          end;
        end;
    else
      Result := true;
    end; // case Item.Kind
  end
  else
    Result := true;
end;

procedure TDownloadThread.VE(Value: String; var Result: Variant;
  var LinkedObj: TObject);

  function Clc(Value: Variant): Variant;
  begin
    Result := CalcValue(Value, VE, LinkedObj);
  end;

var
  t: ttag;
  s, tmp: string;
  p1, p2, p3, p4: string;
  n, n2, i: Integer;
  c: Char;
begin
  // Value := lowrcase(Value);
  Result := '';
  c := Copy(Value, 1, 1)[1];
  Delete(Value, 1, 1);
  { if LinkedObj is TTagList then
    Exit; }
  try
    case c of
      '#':
        if Assigned(LinkedObj) and (LinkedObj is ttag) then
          Result := ClearHTML((LinkedObj as ttag)
            .Attrs.Value(trim(Value, '"')));
      { else
        raise Exception.Create('Tag' + ValS + Value + ': invalid class type '
        + LinkedObj.ClassName); }
      '$':
        if Pos('picture%', Value) = 1 then
        begin
          s := Value;
          tmp := GetNextS(s, '%');
          Result := FPicture.Meta[s];
        end
        else if SameText(Value, 'main.checkcookie') then
          Result := HTTPRec.CookieStr
        else if SameText(Value, 'picture.haveparent') then
          Result := Assigned(FPicture.Parent)
        else if SameText(Value, 'picture.postprocessed') then
          Result := FPicture.PostProcessed
        else if SameText(Value, 'picture.filename') then
          Result := FPicture.PicName
        else if SameText(Value, 'main.url') then
          Result := HTTPRec.DefUrl
        else if SameText(Value, 'main.login') then
          Result := HTTPRec.LoginStr
        else if SameText(Value, 'main.loginpost') then
          Result := HTTPRec.LoginPost
        else if SameText(Value, 'thread.skip') then
          Result := FSkipMe
        else if SameText(Value, 'thread.loginresult') then
          Result := HTTPRec.LoginResult
        else if SameText(Value, 'thread.url') then
          Result := HTTPRec.Url
        else if SameText(Value, 'thread.resulturl') then
          Result := fResultURL
        else if SameText(Value, 'thread.count') then
          if HTTPRec.StartCount = 0 then
            Result := HTTPRec.Count
          else
            Result := HTTPRec.StartCount - 1 + HTTPRec.Count
        else if SameText(Value, 'thread.result') then
          Result := HTTPRec.Theor
        else if SameText(Value, 'thread.counter') then
          if HTTPRec.StartCount = 0 then
            Result := FJobIDX
          else
            Result := HTTPRec.StartCount - 1 + FJobIDX
        else if SameText(Value, 'thread.loginresult') then
          Result := FHTTPRec.LoginResult
        else if SameText(Value, 'thread.http.urlparams') then
          Result := trim(FHTTP.Url.GetPathAndParams, '/')
        else if SameText(Value, 'thread.http.code') then
          Result := FHTTP.ResponseCode
        else if SameText(Value, 'main.pagebypage') then
          Result := HTTPRec.PageByPage
        else if SameText(Value, 'thread.canceled') then
          Result := ReturnValue = THREAD_FINISH
        else if Fields.FindField(Value) > -1 then
          Result := Fields[Value]
        else
          raise Exception.Create('unknown variable: ' + c + Value);
      '@':
        begin
          s := TrimEx(CopyTo(Value, '('), [#13, #10, #9, ' ']);
          if SameText(s, 'picture.tags') then
          begin
            if not Assigned(FPicture) then
              raise Exception.Create('Picture not assigned');

            Result := FPicture.Tags.AsString(Clc(gVal(Value)), '', ' ');
          end
          else if SameText(s, 'text') then
            if Assigned(LinkedObj) and (LinkedObj is ttag) then
            begin
              // Result := TrimEx(ClearHTML((LinkedObj as ttag).GetText(txkCurrent,
              // false)), [' ', #13, #10])  ;
              s := trim(ClearHTML((LinkedObj as ttag)
                .GetText(txkCurrent, false)));
              Result := s;
            end
            else
              Result := ''
          else if SameText(s, 'calc') then
            Result := Clc(trim(Clc(gVal(Value)), ''''))
          else if SameText(s, 'httpencode') then
            Result := { isolate(isolate( } STRINGENCODE(Clc(gVal(Value)))
            { ,''''),'"') }
          else if SameText(s, 'isolate') then
          begin
            s := gVal(Value);
            Result := isolate(Clc(nVal(s)), String(Clc(nVal(s)))[1]);
          end
          else if SameText(s, 'htmlencode') then
            Result := STRINGENCODE(Clc(gVal(Value)), true)
          else if SameText(s, 'emptyname') then
            Result := emptyname(StringDecode(Clc(gVal(Value))))
          else if SameText(s, 'unixtime') then
            Result := UnixToDateTime(Clc(gVal(Value)))
          else if SameText(s, 'lowcase') then
            Result := lowercase(Clc(gVal(Value)))
          else if SameText(s, 'thread.trackredirect') then
            Result := TrackRedirect(Clc(gVal(Value)))
          else if SameText(s, 'removevars') then
          begin
            Result := CopyTo(CopyTo(Clc(gVal(Value)), '?', [], []),
              '#', [], []);
          end
          else if SameText(s, 'removedomain') then
            Result := RemoveURLDomain(Clc(gVal(Value)))
          else if SameText(s, 'boolstr') then
            if Clc(gVal(Value)) then
              Result := 'True'
            else
              Result := 'False'
          else if SameText(s, 'boolint') then
          begin
            Result := Clc(gVal(Value));
            if SameText(Result, 'True') then
              Result := 1
            else if SameText(Result, 'False') then
              Result := 0;
          end
          else if SameText(s, 'min') then
          begin
            s := gVal(Value);
            Result := Min(Clc(nVal(s)), Clc(nVal(s)));
          end
          else if SameText(s, 'checkproto') then
          begin
            s := gVal(Value);
            Result := CheckProto(Clc(nVal(s)), Clc(nVal(s)));
          end
          else if SameText(s, 'max') then
          begin
            s := gVal(Value);
            Result := Max(Clc(nVal(s)), Clc(nVal(s)));
          end
          else if SameText(s, 'getext') then
          begin
            s := gVal(Value);
            Result := trim(ExtractFileExt(Clc(nVal(s))), '.');
          end
          else if SameText(s, 'charinset') then
          begin
            s := gVal(Value);

            p1 := Clc(nVal(s));
            p2 := Clc(nVal(s));
            p3 := Clc(nVal(s));
            Result := CharInSet(p1[1], [p2[1] .. p3[1]]);
          end
          else if SameText(s, 'changename') then
          begin
            s := gVal(Value);
            tmp := Clc(nVal(s));
            s := Clc(nVal(s));
            Result := ChangeFileExt(tmp, s + ExtractFileExt(tmp));
          end
          else if SameText(s, 'changeext') then
          begin
            s := gVal(Value);
            p2 := lowercase(Clc(nVal(s)));
            p1 := Clc(nVal(s));
            if p2 = '' then
              Result := ChangeFileExt(p1, '')
            else
              Result := ChangeFileExt(p1, '.' + p2);
          end
          else if SameText(s, 'changefilename') then
          begin
            s := gVal(Value);
            tmp := Clc(nVal(s));
            Result := ChangeFileExt(Clc(nVal(s)),
              '.' + lowercase(Clc(nVal(s))));
          end
          else if SameText(s, 'isempty') then
          begin
            s := gVal(Value);
            Result := Clc(nVal(s));
            if VarToStr(Result) = '' then
              Result := 1
            else
              Result := 0;
          end
          else if SameText(s, 'ifempty') then
          begin
            s := gVal(Value);
            Result := Clc(nVal(s));
            if VarToStr(Result) = '' then
              Result := Clc(nVal(s));
          end
          else if SameText(s, 'cookie') then
          begin
            s := gVal(Value);
            Result := FHTTP.CookieList.GetCookieValue(Clc(nVal(s)),
              GetURLDomain(HTTPRec.DefUrl));
            // FHTTP.CookieList.ChangeCookie(GetURLDomain(HTTPRec.DefUrl),
            // Clc(nVal(s)) + '=' + Clc(nVal(s)) + ';');
          end
          else if SameText(s, 'domaincookie') then
          begin
            s := gVal(Value);
            Result := FHTTP.CookieList.GetCookieValue(Clc(nVal(s)),
              Clc(nVal(s)));
            // FHTTP.CookieList.ChangeCookie(GetURLDomain(HTTPRec.DefUrl),
            // Clc(nVal(s)) + '=' + Clc(nVal(s)) + ';');
          end
          else if SameText(s, 'urlvar') then
          begin
            s := gVal(Value);
            Result := ClearHTML(StringDecode(GetURLVarValue(Clc(nVal(s)),
              Clc(nVal(s)))));
          end
          else if SameText(s, 'addurlvar') then
          begin
            s := gVal(Value);
            Result := ClearHTML(StringDecode(AddURLVar(Clc(nVal(s)),
              Clc(nVal(s)), Clc(nVal(s)))));
          end
          else if SameText(s, 'abs') then
          begin
            s := gVal(Value);
            Result := abs(Clc(nVal(s)));
          end
          else if SameText(s, 'length') then
          begin
            s := gVal(Value);
            Result := length(VarToStr(Clc(nVal(s))));
          end
          else if SameText(s, 'pos') then
          begin
            s := gVal(Value);
            Result := Pos(Clc(nVal(s)), Clc(nVal(s)));
          end
          else if SameText(s, 'copy') then
          begin
            s := gVal(Value);
            Result := Copy(Clc(nVal(s)), Integer(Clc(nVal(s))),
              Integer(Clc(nVal(s))));
          end
          else if SameText(s, 'copyto') then
          begin
            s := gVal(Value);
            Result := CopyTo(Clc(nVal(s)), Clc(nVal(s)));
          end
          else if SameText(s, 'copytoex') then
          begin
            s := gVal(Value);
            Result := CopyTo(Clc(nVal(s)), Clc(nVal(s)), false, true);
          end
          else if SameText(s, 'copybackto') then
          begin
            s := gVal(Value);
            Result := CopyTo(Clc(nVal(s)), Clc(nVal(s)), true);
          end
          else if SameText(s, 'copybacktoex') then
          begin
            s := gVal(Value);
            Result := CopyTo(Clc(nVal(s)), Clc(nVal(s)), true, true);
          end
          else if SameText(s, 'copyfrom') then
          begin
            s := gVal(Value);
            Result := CopyFromTo(Clc(nVal(s)), Clc(nVal(s)), '');
          end
          else if SameText(s, 'copyfromtoex') then
          begin
            s := gVal(Value);
            Result := CopyFromTo(Clc(nVal(s)), Clc(nVal(s)),
              Clc(nVal(s)), true);
          end
          else if SameText(s, 'deleteto') then
          begin
            s := gVal(Value);
            Result := DeleteTo(Clc(nVal(s)), Clc(nVal(s)), false);
          end
          else if SameText(s, 'deletetoex') then
          begin
            s := gVal(Value);
            Result := DeleteTo(Clc(nVal(s)), Clc(nVal(s)), false, true);
          end
          else if SameText(s, 'detelebackto') then
          begin

          end
          else if SameText(s, 'deletefromto') then
          begin
            s := gVal(Value);
            Result := DeleteFromTo(Clc(nVal(s)), Clc(nVal(s)), Clc(nVal(s)),
              false, true);
          end
          else if SameText(s, 'replace') then
          begin
            s := gVal(Value);
            tmp := StringReplace(Clc(nVal(s)), Clc(nVal(s)), Clc(nVal(s)),
              [rfReplaceAll, rfIgnoreCase]);
            Result := tmp;
          end
          else if SameText(s, 'vartime') then
          begin
            s := gVal(Value);
            Result := DateTimeStrEval(Clc(nVal(s)), Clc(nVal(s)), Clc(nVal(s)));
          end
          else if SameText(s, 'datepart') then
            Result := DateOf(StrToDateTime(Clc(gVal(Value))))
          else if SameText(s, 'timepart') then
            Result := TimeOf(StrToDateTime(Clc(gVal(Value))))
          else if SameText(s, 'date') then
            Result := Date
          else if SameText(s, 'time') then
            Result := Time
          else if SameText(s, 'endoftheyear') then
            Result := StartOfTheDay
              (EndOfTheYear(StrToDateTime(Clc(gVal(Value)))))
          else if SameText(s, 'formatdatetime') then
          begin
            s := gVal(Value);
            Result := FormatDateTime(Clc(nVal(s)), StrToDateTime(Clc(nVal(s))));
          end
          else if SameText(s, 'listitem') then
          begin
            s := gVal(Value);
            n := Clc(nVal(s));
            i := 0;
            while s <> '' do
            begin
              tmp := Clc(nVal(s));
              if n = i then
              begin
                Result := tmp;
                Exit;
              end
              else
                inc(i);
            end;
          end
          else if SameText(s, 'trim') then
          begin
            s := gVal(Value);
            tmp := nVal(s);
            if s = '' then
              Result := SysUtils.trim(Clc(tmp))
            else
            begin
              s := Clc(s);
              Result := trim(Clc(tmp), s[1]);
            end;
          end
          else if SameText(s, 'trimapp') then
            Result := TrimEx(Clc(gVal(Value)), ['(', ')'])
          else if SameText(s, 'JSONTime') then
          begin
            if Assigned(LinkedObj) and (LinkedObj is ttag) then
              with (LinkedObj as ttag) do
              begin
                s := gVal(Value);
                t := Childs.FirstItemByName(s);
                if Assigned(t) then
                  Result := UnixToDateTime(StrToInt(t.Attrs.Value('s')));
              end;
          end
          else if SameText(s, 'queue') then
          begin
            // i := 0;
            s := gVal(Value);
            n := Clc(nVal(s));
            while s <> '' do
            begin
              n2 := Clc(nVal(s));
              if (n - n2 > 0) then
                n := n - n2
              else
                Break;
            end;
            Result := n;
          end
          else if SameText(s, 'queueindex') then
          begin
            Result := 1;
            i := 0;
            s := gVal(Value);
            n := Clc(nVal(s));
            while s <> '' do
            begin
              inc(i);
              n2 := Clc(nVal(s));
              n := n - n2;
              if n <= 0 then
              begin
                Result := i;
                Break;
              end;
            end;
          end
          else if SameText(s, 'getnextpos') then
          begin
            s := gVal(Value);
            p1 := Clc(nVal(s));
            p2 := Clc(nVal(s));
            p3 := Clc(nVal(s));
            p4 := Clc(nVal(s));
            if StrToInt(p2) > length(p1) then
              Result := 0
            else
            begin
              if p3 = '' then
                p3 := ';';

              n := CharPos(p1, p3[1], [p3], [], StrToInt(p2));
              if n = 0 then
                Result := length(p1) + 1
              else
                Result := n;
            end;
          end
          else if SameText(s, 'getvalue') then
          begin
            s := gVal(Value);
            p1 := Clc(nVal(s));
            p2 := Clc(nVal(s));
            p3 := Clc(nVal(s));
            p4 := Clc(nVal(s));
            s := Copy(p1, StrToInt(p2) + 1, StrToInt(p3) - StrToInt(p2) - 1);
            Result := Copy(p1, StrToInt(p2) + 1,
              StrToInt(p3) - StrToInt(p2) - 1);
          end
          else
            raise Exception.Create('unknown method: ' + c + s);
        end;
      '%':
        begin
          Result := FPicture.Meta[Value];
        end;
    else
      begin
        raise Exception.Create('unknown value: ' + c + Value);
      end;
    end;
  except
    on e: Exception do
    begin;
      e.Message := 'making value error (' + c + Value + '): ' + e.Message;
      raise;
    end;
  end;
  // tmp := VarToStr(Result); //for watching
end;

procedure TDownloadThread.WriteEXIF(s: tStream);
var
  buff: array [0 .. 10] of byte;
  // ext: string;
  EXIF: tExifData;
  // XMP: tXMPPacket;
  v: Variant;
  R: TObject;
  st: string;
begin
  // xmp.

  if not FHTTPRec.EXIFTemplate.UseEXIF then
    Exit;

  s.Position := 0;
  s.Read(buff[0], 11);

  if ImageFormat(@buff[0]) = 'jpeg' then
  begin
    s.Position := 0;
    EXIF := tExifData.Create;
    // MPPacketHelper(EXIF.XMPPacket).UpdatePolicy := xwAlwaysUpdate;
    try
      EXIF.LoadFromGraphic(s);
      // EXIF.XMPPacket.
      R := nil;

      with FHTTPRec.EXIFTemplate do
      begin
        if Author <> '' then
        begin
          // VE(Author,v,r);
          st := VarToStr(CalcValue(Author, VE, R));
          EXIF.Author := st;
          // EXIF.LoadFromGraphic()
        end;

        if Title <> '' then
        begin
          // VE(Title,v,r);
          EXIF.Title := VarToStr(CalcValue(Title, VE, R));
        end;

        if Theme <> '' then
        begin
          // VE(Theme,v,r);
          EXIF.Subject := VarToStr(CalcValue(Theme, VE, R));
        end;
        if Comment <> '' then
        begin
          // Comment VE(Comment,v,r);
          EXIF.Comments := VarToStr(CalcValue(Comment, VE, R));
        end;

        if Keywords <> '' then
        begin
          // VE(Keywords,v,r);
          EXIF.Keywords := VarToStr(CalcValue(Keywords, VE, R));
        end;

        if Score <> '' then
        begin
          v := VarToStr(CalcValue(Score, VE, R));
          case Integer(v) of
            0:
              EXIF.UserRating := urUndefined;
            1:
              EXIF.UserRating := urOneStar;
            2:
              EXIF.UserRating := urTwoStars;
            3:
              EXIF.UserRating := urThreeStars;
            4:
              EXIF.UserRating := urFourStars;
            5:
              EXIF.UserRating := urFiveStars;
          else
            if v > 5 then
              EXIF.UserRating := urFiveStars
            else
              EXIF.UserRating := urUndefined;
          end;
        end;

        EXIF.SaveToGraphic(s);
        // EXIF.XMPPacket.SaveToGraphic(s);
        // EXIF.XMPPacket.SaveToFile('log\xmp.xmp');
      end;

    finally
      EXIF.Free;
    end;
  end;

end;

procedure TDownloadThread.DE(ItemName: String; ItemValue: Variant;
  LinkedObj: TObject);

  function Clc(Value: Variant): Variant;
  begin
    Result := CalcValue(Value, VE, LinkedObj);
  end;

  procedure PicValue(p: TTPicture; const Name: String; Value: Variant);
  var
    s, v1, v2: string;
    del, ins: Char;

  begin
    case Name[1] of
      '$':
        if SameText(Name, '$label') then
          FPicture.DisplayLabel := CalcValue(Value, VE, LinkedObj)
        else if SameText(Name, '$filename') then
          FPicture.PicName := CalcValue(Value, VE, LinkedObj);
      '%':
        if SameText(Name, '%tags') then
        begin
          s := lowercase(Value);
          v1 := trim(CopyTo(s, '(', ['""'], ['()'], true));
          s := trim(CopyTo(s, ')', ['""'], ['()'], true));
          if v1 = 'csv' then
          begin
            v1 := CopyTo(s, ',', ['""'], ['()'], true); // GetNextS(s, ',');
            v1 := ReplaceStr(trim(CalcValue(v1, VE, LinkedObj)), #13#10, ' ');
            v2 := trim(CopyTo(s, ',', ['""'], ['()'], true));
            if v2 = '' then
              del := #0
            else
              del := VarToStr(CalcValue(v2, VE, LinkedObj))[1];
            v2 := trim(CopyTo(s, ',', ['""'], ['()'], true));
            if v2 = '' then
              ins := #0
            else
              ins := VarToStr(CalcValue(v2, VE, LinkedObj))[1];
            while v1 <> '' do
            begin
              s := GetNextS(v1, del, ins);
              if s <> '' then
                FPicList.Tags.Add(s, FPicture, FHTTPRec.TagTemplate);
              // FPicture.Tags.Add(FPictureList.Tags.Add(s,nil));
            end;
          end;
        end
        else
        begin
          p.Meta[Copy(Name, 2, length(Name) - 1)] :=
            CalcValue(Value, VE, LinkedObj);
          if p.Meta.Count = 1 then
            p.DisplayLabel := p.Meta.Items[0].Value;
        end;
    end;

  end;

  procedure ProcValue(const Name: String; Value: Variant);
  var
    // p: TTPicture;
    s, v1, v2, r1, r2, r3 { , r4 } : string;
    n: Integer;
    fcln: TTPicture;
    sl: TStringList;
  begin
    if SameText(Name, '$thread.url') then
      FHTTPRec.Url := Value
    else if SameText(Name, '$thread.xml') then
    begin
      FXMLScript.SectionName := VarToStr(Value);
      FXMLScript.ParseValues(VarToStr(FSectors[Value]));
    end
    else if SameText(Name, '$thread.onerror') then
      FErrorScript.ParseValues(VarToStr(FSectors[Value]))
    else if SameText(Name, '$thread.postprocess') then
    begin
      FPostProc.SectionName := VarToStr(Value);
      FPostProc.ParseValues(VarToStr(FSectors[Value]));
    end
    else if SameText(Name, '$thread.xmlcontent') then
      FHTTPRec.ParseMethod := Value
    else if SameText(name, '$thread.method') then
      if SameText('get', Value) then
        FHTTPRec.Method := hmGet
      else if SameText('post', Value) then
        FHTTPRec.Method := hmPost
      else
        raise Exception.Create('unknown method "' + Value + '"')
    else if SameText(name, '$thread.post') then
      FHTTPRec.Post := Value
    else if SameText(Name, '$thread.jsonitem') then
      FHTTPRec.JSONItem := Value
    else if SameText(Name, '$thread.tryext') then
    begin
      FHTTPRec.TryExt := Value;
      FHTTPRec.UseTryExt := FHTTPRec.TryExt <> '';
    end
    else if SameText(Name, '$thread.loginresult') then
      FHTTPRec.LoginResult := Value
    else if SameText(Name, '$thread.count') then
    begin
      if FHTTPRec.MaxCount = 0 then
        FHTTPRec.Count := Trunc(Value)
      else
        FHTTPRec.Count := Min(Trunc(Value), FHTTPRec.MaxCount +
          FHTTPRec.AddToMax);

      if FHTTPRec.StartCount > 0 then
        // FHTTPRec.Count := Trunc(Value)
        // else
        FHTTPRec.Count := FHTTPRec.Count - FHTTPRec.StartCount + 1
    end
    else if SameText(Name, '$thread.counter') then
      raise Exception.Create('Can not assign value for ' + Name)
    else if SameText(Name, '$main.pagebypage') then
      FHTTPRec.PageByPage := CalcValue(Value, VE, LinkedObj)
    else if SameText(Name, '@thread.sendstop') then
    begin
      FStopSignal := true;
      s := Value;
      fStopMessage := Clc(nVal(s));
      fStopSignalTimer := Clc(nVal(s));
    end
    else if SameText(Name, '@thread.execute') then
    begin
      ProcHTTP;
      if FJob = JOB_ERROR then
        raise Exception.Create(Error);
    end
    else if SameText(Name, '@addtag') then
      if Assigned(FPicture) then
        if Job in [JOB_PICS, JOB_POSTPROCESS] then
        begin
          CSData.Enter;
          FLPicList.Tags.Add(CalcValue(Value, VE, LinkedObj), FPicture,
            FHTTPRec.TagTemplate);
          CSData.Leave;
        end
        else
          FPicList.Tags.Add(CalcValue(Value, VE, LinkedObj), FPicture,
            FHTTPRec.TagTemplate)
      else
        raise Exception.Create('Picture not assigned')
    else if SameText(Name, '$picture.displaylabel') then
    begin
      FPicture.DisplayLabel := Value;
      FPicture.Changes := FPicture.Changes + [pcLabel];
    end
    else if SameText(Name, '$picture.filename') then
      FPicture.PicName := Value
    else if SameText(Name, '$child.filename') then
      FChild.PicName := Value
    else if SameText(Name, '$thread.extfromheader') then
      FHTTPRec.PicTemplate.ExtFromHeader := Value
    else if SameText(Name, '$thread.result') then
      FHTTPRec.Theor := Value
    else if SameText(Name, '$thread.referer') then
      FHTTPRec.Referer := Value
    else if SameText(Name, '$thread.tryagain') then
      FHTTPRec.TryAgain := Value
    else if SameText(Name, '$thread.accepterror') then
      FHTTPRec.AcceptError := Value
    else if SameText(Name, '$thread.HandleRedirects') then
      FHTTP.HandleRedirects := Value
    else if SameText(Name, '$thread.Skip') then
      FSkipMe := Value
    else if SameText(Name, '$thread.addunchecked') then
      FHTTPRec.AddUnchecked := Value
      // else if SameText(ItemName, '$thread.checkfilenameext') then
      // FHTTPRec.CheckFNameExt := Value
    else if SameText(Name, '@picture.makename') then
      if Job in [JOB_PICS, JOB_POSTPROCESS] then
      begin
        // if not Assigned(FPicture.Parent) then
        CSData.Enter;
        try
          FPicture.NameUpdated := true;
          // FLPicList.MakePicFileName(FPicture.Index, FLPicList.NameFormat, Assigned(FPicture.Parent));
        finally
          CSData.Leave;
        end;
        // else
      end
      else
    else if SameText(Name, '@createcookie') then
    begin
      s := Value;
      // v1 := Clc(nVal(s));
      // v2 := Clc(nVal(s));
      FHTTP.CookieList.ChangeCookie(GetURLDomain(HTTPRec.DefUrl),
        VarToStr(Clc(nVal(s))) + '=' + VarToStr(Clc(nVal(s))));
    end
    else if SameText(Name, '@addurl') then
    begin
      s := Value;
      v1 := Clc(nVal(s));
      v2 := VarToStr(Clc(nVal(s)));
      AddURLToList(v1, v2);
    end
    else if SameText(Name, '@addurlcsvlist') then
    begin
      s := Value;
      r1 := Clc(nVal(s));
      r2 := Clc(nVal(s));
      r3 := Clc(nVal(s));
      sl := TStringList.Create;
      try
        sl.Text := strtostrlist(r1);
        for n := 0 to sl.Count - 1 do
          AddURLToList(r2 + sl[n] + r3);

      finally
        sl.Free
      end;
    end
    else if SameText(Name, '@addpicture') or SameText(Name, '@addchild') then
    begin
      if SameText(Name, '@addpicture') then
        fcln := AddPicture
      else
        fcln := AddChild;

      s := Value;
      while s <> '' do
      begin
        n := CharPos(s, ',', ['""', ''''''], ['()']);
        if n = 0 then
          n := length(s) + 1;
        v1 := TrimEx(Copy(s, 1, n - 1), [#9, #10, #13, ' ']);
        s := DeleteEx(s, 1, n);

        v2 := TrimEx(GetNextS(v1, '='), [#9, #10, #13, ' ']);
        if v1 = '' then
        begin
          v1 := CopyFromTo(v2, '(', ')', true);
          v2 := '@' + CopyTo(v2, '(');
        end;
        PicValue(fcln, v2, v1);
      end
    end
    else if SameText(Name, '@clonepic') then
    begin
      { if FAddPic then
        Synchronize(AddPicture); }
      s := Value;

      r1 := nVal(s);
      r2 := nVal(s);
      // r3 := s;
      fcln := FPicture;

      while CalcValue(r1, VE, LinkedObj) do
      begin
        ClonePicture;
        r3 := s;
        while r3 <> '' do
        begin

          v1 := nVal(r3);
          v2 := nVal(v1, '=');
          if v1 = '' then
          begin
            v1 := gVal(v2);
            v2 := CopyTo(v2, '(');
          end;
          PicValue(FPicture, v2, v1);
        end;

        v2 := r2;
        v1 := nVal(v2, '=');

        DE(v1, CalcValue(v2, VE, LinkedObj), LinkedObj);
        FPicture := fcln;
      end;
      // FAddPic := true;
      // Synchronize(AddPicture);
    end
    else if Name[1] = '%' then
      if Assigned(FPicture) then
        if SameText(Name, '%tags') then
        begin
          // if Job in [JOB_PICS, JOB_POSTPROCESS] then
          // begin
          // CSData.Enter;
          // FLPicList.Tags.Add(CalcValue(Value, VE, LinkedObj), FPicture);
          // CSData.Leave;
          // end
          // else
          // FPicList.Tags.Add(CalcValue(Value, VE, LinkedObj), FPicture)

          s := lowercase(Value);
          v1 := CopyTo(s, '(', ['""'], ['()'], true);
          s := CopyTo(s, ')', ['""'], ['()'], true);
          if v1 = 'csv' then
          begin
            v1 := CopyTo(s, ',', ['""'], ['()'], true); // GetNextS(s, ',');
            v1 := ReplaceStr(trim(CalcValue(v1, VE, LinkedObj)), #13#10, ' ');
            v2 := trim(CopyTo(s, ',', ['""'], ['()'], true));
            if v2 = '' then
              r1 := #0
            else
              r1 := VarToStr(CalcValue(v2, VE, LinkedObj))[1];
            v2 := trim(CopyTo(s, ',', ['""'], ['()'], true));
            if v2 = '' then
              r2 := #0
            else
              r2 := VarToStr(CalcValue(v2, VE, LinkedObj))[1];
            while v1 <> '' do
            begin
              s := GetNextS(v1, r1, r2);
              if s <> '' then
                if Job in [JOB_PICS, JOB_POSTPROCESS] then
                begin
                  CSData.Enter;
                  try
                    // V
                    FLPicList.Tags.Add(s, FPicture, FHTTPRec.TagTemplate);
                  finally
                    CSData.Leave;
                  end;
                end
                else
                  // V
                  FPicList.Tags.Add(s, FPicture, FHTTPRec.TagTemplate);

              // FPicture.Tags.Add(FPictureList.Tags.Add(s,nil));
            end;
          end;
        end
        else if Job in [JOB_PICS, JOB_POSTPROCESS] then
        begin
          CSData.Enter;
          FLPicList.AddPicMeta(FPicture, trim(name, '%'), Value);
          CSData.Leave;
        end
        else
          FPicture.Meta[trim(name, '%')] := Value
      else
        raise Exception.Create('Picture not assigned')
    else if Name[1] = '$' then
    begin
      s := DeleteEx(Name, 1, 1);
      n := Fields.FindField(s);
      if n = -1 then
        Fields.AddField(s, '', ftNone, Value, '', false)
      else
        Fields.Items[n].resvalue := Value;
    end
    else
      raise Exception.Create('incorrect decloration: ' + Name);
  end;

begin
  // if not (LinkedObj is TTagList) then
  try
    ProcValue(ItemName, ItemValue);
  except
    on e: Exception do
    begin
      e.Message := ItemName + '(' + VarToStr(ItemValue) + '): ' + e.Message;
      raise;
    end;
  end;
end;

procedure TDownloadThread.FE(const Item: TScriptSection; LinkedObj: TObject);
begin
  if (Item.Kind in [sikSection, sikGroup]) and Assigned(LinkedObj) and
    (LinkedObj is TTagList) or (LinkedObj is TWorkList) then
    LinkedObj.Free;
end;

procedure TDownloadThread.IdHTTPWorkBegin(ASender: TObject;
  AWorkMode: TWorkMode; AWorkCountMax: int64);
begin
  if ReturnValue = THREAD_FINISH then
    HTTP.Disconnect;

  FPicture.DTStart := Date + Time;
  FPicture.DTEnd := 0;

  if HTTP.Response.ContentRangeEnd = -1 then
    FPicture.Size := AWorkCountMax
  else
    FPicture.Size := HTTP.Response.ContentRangeEnd + 1;
  FPicture.Changes := FPicture.Changes + [pcSize];
  Synchronize(PicChanged);
end;

procedure TDownloadThread.IdHTTPWork(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: int64);
begin
  if ReturnValue = THREAD_FINISH then
    HTTP.Disconnect;

  FPicture.Lastpos := FPicture.Pos;
  if (HTTP.Response.ContentRangeStart = -1) or
    (HTTP.Response.ContentRangeStart = 0) then
    FPicture.Pos := AWorkCount
  else
    FPicture.Pos := HTTP.Response.ContentRangeStart + FPicture.Pos - 1;
  FPicture.Changes := FPicture.Changes + [pcProgress];

  FPicture.DTEnd := Date + Time;

  Synchronize(PicChanged);

  FPicture.DTStart := Date + Time;

  { if Assigned(FPicture.OnPicChanged) then
    Synchronize(FPicture.OnPicChanged(FPicture,[pcProgress])); }
end;

procedure TDownloadThread.LockList;
begin
  FPicList.BeginAddList;
end;

procedure TDownloadThread.PicChanged;
begin
  if Assigned(FPicture.OnPicChanged) then
    FPicture.OnPicChanged(FPicture, FPicture.Changes);
end;

procedure TDownloadThread.ProcHTTP; // process PAGE request with text content
var // used if need to parse content
  h: THandle;
  Result: TStringStream;
  tmp, Url: string;
  Post: TStringList;
  debug_name: string;
  ms: int64;
  i: Integer;

  // t: tTag;
begin
  FRetries := 0;
  Result := TStringStream.Create('', FHTTPRec.Encoding);
  try
    while true do
      try
        FBeforeScript.Process(SE, DE, FE, VE, VE);

        if FHTTPRec.Url = '' then
          raise Exception.Create('URL template is empty');

        try
          try
            FHTTP.Disconnect;
          except
          end;
          // Url := '';

          Url := CheckProto(CalcValue(FHTTPRec.Url, VE, nil), FHTTPRec.Referer);

          FHTTP.Request.Referer := FHTTPRec.Referer;

          Result.Clear;

          if FHTTPRec.PageDelay > 0 then
          begin
            h := FResource.ThreadCounter.Queue.Enter;
            try
              if (ReturnValue = THREAD_FINISH) then
                Break;

              CSData.Enter;
              try
                ms := MillisecondsBetween(FResource.ThreadCounter.LastPageTime,
                  Date + Time);
                if ms < FHTTPRec.PageDelay then
                  FResource.ThreadCounter.LastPageTime :=
                    IncMillisecond(Date + Time, FHTTPRec.PageDelay - ms)
                else
                  FResource.ThreadCounter.LastPageTime := Date + Time;
              finally
                CSData.Leave;
              end;

              if ms < FHTTPRec.PageDelay then
                WaitForSingleObject(h, FHTTPRec.PageDelay - ms);

              if (ReturnValue = THREAD_FINISH) then
                Break;
              // end;
            finally
              FResource.ThreadCounter.Queue.Leave;
            end;
          end;

          if FHTTPRec.Method = hmPost then
          begin
            Post := TStringList.Create;
            try
              if FHTTPRec.Post = '' then
              begin
                GetPostStrings(Url, Post);
                Url := CopyTo(Url, '?');
              end
              else
              begin
                tmp := CalcValue(FHTTPRec.Post, VE, nil);
                GetPostStrings(tmp, Post);
              end;

              try
                FHTTP.Post(Url, Post, Result);
                FHTTP.Disconnect;
              except
                if (FHTTP.ResponseCode = 302) then
                else
                  raise;
              end;
            finally
              Post.Free;
            end;
          end
          else
          begin
            if not FHTTP.HandleRedirects then
              FHTTP.Get(Url, Result, [302])
            else
              FHTTP.Get(Url, Result);
            FHTTP.Disconnect;
          end;

          if (ReturnValue = THREAD_FINISH) then
            Break;

          fResultURL := Url;

        except
          on e: Exception do
          begin
            if (ReturnValue = THREAD_FINISH) then
              Break;

            FHTTPRec.TryAgain := false;
            FHTTPRec.AcceptError := true;

            FErrorScript.Process(SE, DE, FE, VE, VE);

            if FHTTPRec.TryAgain then
              Continue;

            if FHTTPRec.AcceptError then
              if (FHTTP.ResponseCode = 404) or (FHTTP.ResponseCode = 503) or
                (FHTTP.ResponseCode = 410) then
              begin
                SetHTTPError(Url + ': ' + e.Message);
                Break;
              end
              else if (FRetries < FMaxRetries) then
              begin
                inc(FRetries);
                Continue;
              end
              else
              begin
                SetHTTPError(Url + ': ' + e.Message);
                Break;
              end;

          end;
        end;

        if SameText(FHTTPRec.ParseMethod, 'xml') then
          FXML.Parse(Result.DataString)
        else if SameText(FHTTPRec.ParseMethod, 'html') then
          FXML.Parse(Result.DataString, true)
        else if SameText(FHTTPRec.ParseMethod, 'json') then
          FXML.JSON(FHTTPRec.JSONItem, Result.DataString)
        else
          raise Exception.Create('unknown method: ' + FHTTPRec.ParseMethod);

        // ----  //

        if LogMode then
        begin
          debug_name := ValidFName(emptyname(Url));
          if debug_name = '' then
            debug_name := IntToStr(FJobIDX);

          // FXMLScript.SaveToFile(ExtractFilePath(paramstr(0)) + 'log\' +
          // debug_name + '.script');

          FXML.TagList.Insert(0, ttag.Create(#13#10, tkText));
          FXML.TagList.Insert(0,
            ttag.Create('Response:' + #13#10 + FHTTP.Response.RawHeaders.Text,
            tkComment));
          FXML.TagList.Insert(0, ttag.Create(#13#10, tkText));
          FXML.TagList.Insert(0,
            ttag.Create('Request:' + #13#10 + FHTTP.Request.RawHeaders.Text,
            tkComment));
          FXML.TagList.Insert(0, ttag.Create(#13#10, tkText));
          FXML.TagList.Insert(0,
            ttag.Create(CheckProto(CalcValue(FHTTPRec.Url, VE, nil),
            FHTTPRec.Referer), tkComment));
          i := 0;
          repeat
            inc(i);
            tmp := ExtractFilePath(paramstr(0)) + 'log\' + debug_name + '_' +
              IntToStr(i) + '.html';
          until not fileexists(tmp);

          FXML.TagList.ExportToFile(tmp, [tcsContent, tcsHelp]);
          FHTTP.CookieList.SaveToFile(ExtractFilePath(paramstr(0)) + 'log\' +
            debug_name + '_' + IntToStr(i) + '.cookie');
          Result.SaveToFile(ExtractFilePath(paramstr(0)) + 'log\' + debug_name +
            '_' + IntToStr(i) + '.raw');
          // SaveStrToFile('<!-- ' + Url + '-->' + #13#10 + Result.DataString,
          // ExtractFilePath(paramstr(0)) + 'log\' + debug_name + '.src');
        end;
        // ---- //

        FXMLScript.Process(SE, DE, FE, VE, VE, FXML.TagList);

        FAfterScript.Process(SE, DE, FE, VE, VE);

        if ReturnValue = THREAD_FINISH then
          Break;

        if Assigned(FLPicList) and (FPicList.Count > 0) then
        begin
          CSData.Enter;
          try
            if Job in [JOB_PICS, JOB_POSTPROCESS] then
              FLPicList.AddPicList(FPicList, FPicture)
            else
              FLPicList.AddPicList(FPicList);
            FPicList.Clear;
            FPicsAdded := true;
          finally
            CSData.Leave;
          end;
        end;

        Break;
      except
        on e: Exception do
        begin
          SetHTTPError(FResource.Name + ': ' + e.Message);
          Break;
        end;
      end;

  finally
    Result.Free;
  end;
end;

procedure TDownloadThread.ProcPic;
// used to download and save BINARY data, like pictures
const
  buff_size = 22;

var
  debug_name: string;
  f: TFileStream;
  // m: tMemoryStream;
  buff: array [0 .. 10] of byte;
  // Range: TIdEntityRange;
  fdir: string;
  FExt: string;
  { tmp, } FName: string;
  Url: string;
  ms: int64;
  not_resume: Boolean;
  h: THandle;
  // frec: tSearchRec;

  function makeName: String;
  begin

    // feature to make name by template, like %filename%.%ext%
    // need if you can't make name for picture in getting list
    if (FHTTPRec.PicTemplate.Name <> '') then
      Result := ReplaceStr(FPicture.FileName, FHTTPRec.PicTemplate.Name,
        FPicture.PicName)
    else
      Result := FPicture.FileName;

    if (FHTTPRec.PicTemplate.Ext <> '') then
      if (FExt = '') then
        Result := ReplaceStr(Result, FHTTPRec.PicTemplate.Ext, FPicture.Ext)
      else
        Result := ReplaceStr(Result, FHTTPRec.PicTemplate.Ext, FExt);
  end;

begin

  if FSkipMe then
  begin
    // CSData.Enter; try
    FPicture.Status := JOB_SKIP;
    FPicture.Changes := FPicture.Changes + [pcProgress];
    Synchronize(PicChanged);
    Exit;
    // finally
    // CSData.Leave;
    // end;
  end;

  if HTTPRec.Url = '' then
  begin
    SetHTTPError(FPicture.DisplayLabel + ': can not get url for picture');
    Exit;
  end;

  not_resume := false;
  f := nil;
  FRetries := 0;
  FExt := '';

  while true do
  begin
    try
      // feature to add childs to album
      // common version - if a picture download error occurs, must be executed
      // script to check childs for picture (it is not a picture, but album)
      // check realisation in pixiv.net.csg

      // after try to get picture iteration resets
      // and if new iteration get new pictures in list, then
      // new pictures must be added as childs and thread job must be finished

      if not Assigned(f) then
      begin

        if FPicsAdded then
          Break;

        // if name need update, then update it

        if FPicture.NameUpdated then
        begin
          CSData.Enter;
          try
            FLPicList.MakePicFileName(FPicture.Index, FLPicList.NameFormat,
              Assigned(FPicture.Parent));
          finally
            CSData.Leave;
          end;
        end;

        // feature to try diffirent exts, if it's unknown from start

        if (FHTTPRec.TryExt <> '') { and not Assigned(m) } then
          FExt := CopyTo(FHTTPRec.TryExt, ',', [], [], true);

        if { FHTTPRec.CheckFNameExt and } FHTTPRec.PicTemplate.ExtFromHeader or
          FPicture.NeedNameRemake then
          FName := IncludeTrailingPathDelimiter
            (FindExistingDir(ExtractFileDir(FPicture.FileName))) +
            GetGUIDString + '.tmp'
        else
          FName := makeName;

        fdir := ExtractFileDir(FName);

        FCSFiles.Enter;
        try

          if ExtractFileName(FName) = '' then
          begin
            SetHTTPError(HTTPRec.Url + ': can not get file name');
            Exit;
          end
          else if { HTTPRec.CheckFNameExt and } fileexists(FName)
          { or not HTTPRec.CheckFNameExt and (FindFirst(ChangeFileExt(FName,'.*'),faAnyFile,frec)=0) }
          then
            if { HTTPRec.CheckFNameExt and } FHTTPRec.PicTemplate.ExtFromHeader
            then
              raise Exception.Create(HTTPRec.Url + ': ' + ExtractFileName(FName)
                + ' WTF random name exists???')
            else
            begin
              FPicture.Size := 0;
              FPicture.Pos := 0;
              FPicture.Changes := FPicture.Changes +
                [pcSize, pcProgress, pcData];
              FPicture.FactFileName := FName;
              // call picture changed to change it in visible table
              f := TFileStream.Create(FName, FmOpenRead);
              try
                FPicture.MakeMD5(f);
              finally
                FreeAndNil(f);
              end;

              Synchronize(PicChanged);
              Exit;
            end;

          if not DirectoryExists(fdir) then
            CreateDirExt(fdir);

          // feature to get ext AFTER it downloaded
          // some resources uses wrong ext or not use it at all
          // this feature allows to get ext by content
          // if feature enabled, picture downloaded to the memory, and after it to the drive

          if not Assigned(f) then
            f := TFileStream.Create(FName, fmCreate);

        finally
          FCSFiles.Leave;
        end;
      end;

      try
        HTTP.Request.Referer := FHTTPRec.Referer;

        // checkproto - allows to make full urls from short '//:url/page','/page' and other using referer

        if FExt = '' then
          Url := CheckProto(HTTPRec.Url, HTTPRec.Referer)
        else
          Url := CheckProto(ReplaceStr(HTTPRec.Url, FHTTPRec.PicTemplate.Ext,
            FExt), HTTPRec.Referer);

        // Delay feature for retarted resources
        // 2.0.2.115 NOW is a queue

        if FHTTPRec.PicDelay > 0 then
        begin

          // if ms < FHTTPRec.PicDelay then
          // begin
          FPicture.Status := JOB_DELAY;
          FPicture.Pos := 0;
          FPicture.Size := 0;
          FPicture.Changes := FPicture.Changes + [pcSize, pcProgress];
          Synchronize(PicChanged);

          h := FResource.ThreadCounter.Queue.Enter;
          try

            if ReturnValue = THREAD_FINISH then
            begin
              FJob := JOB_CANCELED;
              Break;
            end;

            // while true do
            // begin
            CSData.Enter;
            try // critical sections prevent from collisions and "at the same time checking"
              ms := MillisecondsBetween(FResource.ThreadCounter.LastPicTime,
                Date + Time);
              if ms < FHTTPRec.PicDelay then
                FResource.ThreadCounter.LastPicTime :=
                  IncMillisecond(Date + Time, FHTTPRec.PicDelay - ms)
              else
                FResource.ThreadCounter.LastPicTime := Date + Time;
            finally
              CSData.Leave;
            end;

            if ms < FHTTPRec.PicDelay then
              WaitForSingleObject(h, FHTTPRec.PicDelay - ms);

            if ReturnValue = THREAD_FINISH then
            begin
              FJob := JOB_CANCELED;
              Break;
            end;

          finally
            FResource.ThreadCounter.Queue.Leave;
          end;

        end;

        FPicture.Status := JOB_INPROGRESS;
        FPicture.Changes := FPicture.Changes + [pcSize, pcProgress];
        Synchronize(PicChanged);

        // error generating
        // randomize;
        // if random(5) = 1 then
        // url := 'hurrdurr/509s.gif';

        // HTTP.ReadTimeout := 60;

        if Assigned(f) and (f.Size > 0) then
        begin
          // HTTP.Socket.
          HTTP.IOHandler := nil;
          try
            HTTP.Request.Range := 'bytes=' + IntToStr(f.Size) + '-';
            HTTP.ReadTimeout := 10000;
            try
              HTTP.Head(Url);
            finally
              HTTP.Disconnect;
            end;
          finally
            HTTP.IOHandler := FSSLHandler;
          end;
          // HTTP.Response.ResponseCode
          if HTTP.ResponseCode <> 206 then
          begin
            HTTP.Request.Range := '';
            f.Seek(0, soBeginning);
          end
          else
            f.Seek(f.Size, soBeginning);

        end;

        try
          HTTP.Get(Url, f);
        finally
          HTTP.Disconnect;
        end;

        if LogMode then
        begin
          debug_name := ValidFName(emptyname(Url));
          if debug_name = '' then
            debug_name := IntToStr(FJobIDX);
          StreamToFile(f, ExtractFilePath(paramstr(0)) + 'log\' + debug_name
            + '.bin');
        end;

        if ReturnValue = THREAD_FINISH then
          FJob := JOB_CANCELED;

        if FPicture.Size <> f.Size then
          // if downloaded file size not equal with "internet" file size
          // then is error (server inerrupted downloading without messages)
          raise Exception.Create(HTTPRec.Url + ': incorrect filesize')
        else
        begin

          if FHTTPRec.PicTemplate.ExtFromHeader { or FPicture.NeedNameRemake }
          then
          begin
            f.Position := 0; // read ext from BINARY
            f.Read(buff[0], buff_size);
            FExt := ImageFormat(@buff[0]);
            if FExt = '' then
            begin
              not_resume := true;
              raise Exception.Create
                (HTTPRec.Url + ': can not get file extension');
            end;
          end;

          if (FExt <> '') and (FHTTPRec.PicTemplate.Ext <> '') then
            FPicture.PicName := FPicture.PicName + '.' + FExt;

          FPicture.MakeMD5(f);
          try
            WriteEXIF(f);
          except
            not_resume := true;
            raise;
          end;
          FreeAndNil(f);

          if FHTTPRec.PicTemplate.ExtFromHeader or FPicture.NeedNameRemake
          { or FHTTPRec.UseTryExt } then
          begin
            FCSData.Enter;
            try
              FLPicList.MakePicFileName(FPicture.Index, FLPicList.NameFormat,
                Assigned(FPicture.Parent));

              if fileexists(FPicture.FileName) and (FPicture.FileName <> FName)
              then
              begin
                DeleteFile(FName);
                FPicture.Size := 0;
                FPicture.Pos := 0;
                FPicture.Changes := FPicture.Changes +
                  [pcSize, pcProgress, pcData];
                FPicture.FactFileName := FPicture.FileName { tmp };
                // call picture changed to change it in visible table
                Synchronize(PicChanged);
                Exit;
              end;

              fdir := ExtractFileDir(FPicture.FileName { tmp } );

              if not DirectoryExists(fdir) then
                if not CreateDirExt(fdir) then
                  raise Exception.Create(SysErrorMessage(GetLastError));

              if not RenameFile(FName, FPicture.FileName { tmp } ) then
              begin
                DeleteFile(FName);
                raise Exception.Create(SysErrorMessage(GetLastError));
              end;

            finally
              FCSData.Leave;
            end;

            FName := FPicture.FileName { tmp };
          end;

          FPicture.FactFileName := FName;
          // saving "real" name, file name on the drive
        end;

        Break;

      except
        on e: EIdReadTimeout do
        begin
          if (FRetries >= FMaxRetries) or (ReturnValue = THREAD_FINISH) then
          begin
            FreeAndNil(f);
            DeleteFile(FName);
          end;

          // FPicture.Size := 0;
          FPicture.Pos := 0;

          if (ReturnValue = THREAD_FINISH) then
            Break;

          if { not not_resume and } (FRetries < FMaxRetries) then
            inc(FRetries)
          else
          begin
            SetHTTPError(HTTPRec.Url + ': ' + e.Message);
            Break;
          end;
        end;
        on e: EIdSocketError do
        begin
          // if (FRetries >= FMaxRetries) or (ReturnValue = THREAD_FINISH) then
          // begin
          FreeAndNil(f);
          DeleteFile(FName);
          // end;

          FPicture.Size := 0;
          FPicture.Pos := 0;

          if (ReturnValue = THREAD_FINISH) then
            Break;

          if e.LastError = 10054 then
            // if is "disconnect gracefully" error then just disconnect and try again
            try
              HTTP.Disconnect
            except
            end
          else if { not not_resume and } (FRetries < FMaxRetries) then
            inc(FRetries)
          else
          begin
            SetHTTPError(HTTPRec.Url + ': ' + e.Message);
            Break;
          end;
        end;
        on e: Exception do
        begin
          if Assigned(f) then
            FreeAndNil(f);
          DeleteFile(FName);
          FPicture.Size := 0;
          FPicture.Pos := 0;

          if (ReturnValue = THREAD_FINISH) then
            Break;

          if not not_resume then
          begin
            FHTTPRec.TryAgain := false;
            FErrorScript.Process(SE, DE, FE, VE, VE);

            if FHTTPRec.TryAgain then
              Continue;
          end;

          if not not_resume and (HTTP.ResponseCode <> 404) and
            (HTTP.ResponseCode <> 503) and (HTTP.ResponseCode <> 410) and
            (FRetries < FMaxRetries) then
            inc(FRetries) // 404 not need to retry
          else if FHTTPRec.TryExt <> '' then
            FRetries := 0
          else
          begin
            SetHTTPError(HTTPRec.Url + ': ' + e.Message);
            Break;
          end;
        end;
      end; // on http except

    except
      on e: Exception do
      begin
        if Assigned(f) then
          FreeAndNil(f);

        DeleteFile(FName);

        FPicture.Size := 0;
        FPicture.Pos := 0;
        SetHTTPError(e.Message);
        Break;
      end;
    end; // on other except

  end; // while true

end;

procedure TDownloadThread.ProcPost;
begin
  FPostProc.Process(SE, DE, FE, VE, VE);
end;

procedure TDownloadThread.ProcLogin;
// login process, simple version of ProcHTTP
var
  Url: string;
  poststr: string;
  // s: string;
  Post: TStringList;
begin
  try
    try
      FHTTP.Disconnect;
    except
    end;
    Url := CalcValue(FHTTPRec.LoginStr, VE, nil);
    if Url = '' then
      Exit;

    FHTTP.Request.Referer := FHTTPRec.Referer;
    Post := TStringList.Create;
    try
      if FHTTPRec.LoginPost = '' then
      begin
        GetPostStrings(Url, Post);
        Url := CopyTo(Url, '?');
      end
      else
      begin
        poststr := CalcValue(FHTTPRec.LoginPost, VE, nil);
        GetPostStrings(poststr, Post);
      end;
      FHTTP.Post(Url, Post);
    finally
      Post.Free;
    end;
  except
    on e: Exception do
    begin
      SetHTTPError(e.Message);
    end;
  end;
end;

procedure TDownloadThread.SetInitialScript(Value: TScriptSection);
begin
  if Value = nil then
    FInitialScript.Clear
  else
    FInitialScript.Assign(Value);
end;

procedure TDownloadThread.SetSectors(Value: TValueList);
begin
  if Value = nil then
    FSectors.Clear
  else
    FSectors.Assign(Value);
end;

procedure TDownloadThread.SetBeforeScript(Value: TScriptSection);
begin
  if Value = nil then
    FBeforeScript.Clear
  else
    FBeforeScript.Assign(Value);
end;

procedure TDownloadThread.SetHTTPError(s: string);
begin
  FErrorString := s;
  FJob := JOB_ERROR;
end;

procedure TDownloadThread.SetAfterScript(Value: TScriptSection);
begin
  if Value = nil then
    FAfterScript.Clear
  else
    FAfterScript.Assign(Value);
end;

procedure TDownloadThread.SetXMLScript(Value: TScriptSection);
begin
  if Value = nil then
    FXMLScript.Clear
  else
    FXMLScript.Assign(Value);
end;

function TDownloadThread.TrackRedirect(Url: String): String;
begin
  try
    // FHTTP.HTTPOptions := [hoNoProtocolErrorException];
    FHTTP.HandleRedirects := false;
    try
      Result := Url;

      try
        FHTTP.Head(Result, [404, 302]);
      except
        on e: EIdConnClosedGracefully do
        begin
        end;
        on e: Exception do
          raise;
      end;

      while FHTTP.ResponseCode = 302 do
      begin
        Result := FHTTP.Response.Location;
        try
          FHTTP.Head(Result)
        except
          on e: EIdConnClosedGracefully do
          begin
          end;
          on e: Exception do
            raise;
        end;
      end;

      if FHTTP.ResponseCode = 404 then
        Result := '';

    except
      on e: Exception do
      begin
        if FHTTP.ResponseCode = 404 then
          Result := ''
        else
          raise;
      end;
    end;
  finally
    FHTTP.HandleRedirects := true;
  end;
end;

procedure TDownloadThread.SetPostProcScript(Value: TScriptSection);
begin
  if Value = nil then
    FPostProc.Clear
  else
    FPostProc.Assign(Value);
end;

procedure TDownloadThread.UnlockList;
begin
  FPicList.EndAddList;
end;

procedure TDownloadThread.SeFields(Value: TResourceFields);
begin
  if Value = nil then
    Fields.Clear
  else
    Fields.Assign(Value);
end;


// TPictureTag

constructor TPictureTag.Create;
begin
  inherited;
  FLinked := TPictureLinkList.Create;
  fIgnore := false;
end;

destructor TPictureTag.Destroy;
begin
  FLinked.Free;
  inherited;
end;

// TPictureTagLinkList

procedure TPictureTagLinkList.Clear;
begin
  inherited Clear;
  fInSearch := false;
  if Assigned(fsearchstack) then
    fsearchstack.Clear;
end;

function TPictureTagLinkList.ContinueSearch(Value: string; fmt: TTagTemplate;
  cnt: Integer = 5): string;
begin
  if Value = '' then
  begin
    Result := '';
    Exit;
  end;
  // value := lowercase(value);

  if (length(fSearchWord) > 0) and SameText(Copy(Value, 1, length(fSearchWord)),
    fSearchWord) then
    if length(Value) = length(fSearchWord) then
      Result := fsearchstack.AsString(fmt, cnt, true)
    else if Assigned(fsearchstack) and fsearchstack.InSearch then
      Result := fsearchstack.ContinueSearch(Value, fmt, cnt)
    else
      Result := fsearchstack.StartSearch(Value, fmt, cnt)
  else
    Result := StartSearch(Value, fmt, cnt);
end;

constructor TPictureTagLinkList.Create;
begin
  inherited;
  fsearchstack := nil;
  with fTagTemplate do
  begin
    Spacer := '_';
    Isolator := '';
    Separator := ' ';
  end;
end;

destructor TPictureTagLinkList.Destroy;
begin
  if Assigned(fsearchstack) then
    FreeAndNil(fsearchstack);
end;

function TPictureTagLinkList.FindPosition(Value: String;
  var Index: Integer): Boolean;
var
  Hi, Lo: Integer;

begin
  if Count = 0 then
  begin
    Result := false;
    index := 0;
    Exit;
  end;
  // try
  // Value := VarAsType(Value,FVariantType);
  // except
  // on e: exception do
  // raise Exception.Create('"' + Value + '" - ' + e.Message);
  // end;

  Hi := Count;
  Lo := 0;
  index := Hi div 2;

  try
    while (Hi - Lo) > 0 do
    begin
      if Value = Items[index].Name then
        Break
      else if Value < Items[index].Name then
        Hi := index - 1
      else
        Lo := index + 1;

      index := Lo + ((Hi - Lo) div 2);
    end;

    if (index < Count) and (Value > Items[index].Name) then
      inc(index);

    Result := (index < Count) and SameText(Value, (Items[index].Name));
  except
    on e: Exception do
    begin
      e.Message := e.Message + ' tag(' + Items[index].Name + ') - (' +
        Value + ')';
      raise;
    end;
  end;
end;

function TPictureTagLinkList.Get(Index: Integer): TPictureTag;
begin
  Result := inherited Get(Index);
end;

procedure TPictureTagLinkList.Put(Index: Integer; Item: TPictureTag);
begin
  inherited Put(Index, Item);
end;

function TPictureTagLinkList.StartSearch(Value: string; fmt: TTagTemplate;
  cnt: Integer = 5): string;
var
  i: Integer;

begin
  Value := ReplaceStr(lowercase(Value), fmt.Spacer, fTagTemplate.Spacer);

  fSearchWord := Value;

  if Assigned(fsearchstack) then
    fsearchstack.Clear
  else
    fsearchstack := TPictureTagLinkList.Create;

  fInSearch := true;

  Result := '';
  for i := 0 to Count - 1 do
    if not Items[i].Ignore and (Pos(Value, lowercase(Items[i].Name)) > 0) then
      fsearchstack.Add(Items[i]);

  Result := fsearchstack.AsString(fmt, cnt, true);
end;

function TPictureTagLinkList.AsString(fmt: TTagTemplate; cnt: Integer = 0;
  List: Boolean = false): String;

// function makename(s: string): string;
// begin
// Result := ReplaceStr(s, '_', fSpacer);
// end;

var
  i: Integer;
begin
  if cnt = 0 then
    cnt := Count
  else
    cnt := Min(cnt, Count);
  if cnt > 0 then
  begin
    if not List then
    begin
      Result := fmt.Isolator + ReplaceStr(Items[0].Name, fTagTemplate.Spacer,
        fmt.Spacer) + fmt.Isolator;
      for i := 1 to cnt - 1 do
        Result := Result + fmt.Separator + fmt.Isolator +
          ReplaceStr(Items[i].Name, fTagTemplate.Spacer, fmt.Spacer) +
          fmt.Isolator
        // makename(Items[i].Name)
    end
    else
    begin
      Result := ReplaceStr(Items[0].Name, fTagTemplate.Spacer, fmt.Spacer);
      for i := 1 to cnt - 1 do
        Result := Result + #13#10 + ReplaceStr(Items[i].Name,
          fTagTemplate.Spacer, fmt.Spacer);
    end;
  end;
end;

function TPictureTagLinkList.AsString(cnt: Integer = 0;
  List: Boolean = false): String;
var
  fmt: TTagTemplate;
begin
  // fmt.Separator := fSeparator;
  // fmt.Spacer := fSpacer;
  // fmt.Isolator := fIsolator;
  fmt := fTagTemplate;
  Result := AsString(fmt, cnt, List);
end;

function TPictureTagLinkList.AsString(Separator, Isolator, Spacer: string;
  cnt: Integer = 0; List: Boolean = false): String;
var
  fmt: TTagTemplate;
begin
  fmt.Separator := Separator;
  fmt.Spacer := Spacer;
  fmt.Isolator := Isolator;
  Result := AsString(fmt, cnt, List);
end;

procedure TPictureTagLinkList.SaveToStream(fStream: tStream);
var
  i: Integer;
begin
  fStream.WriteData(Count);
  for i := 0 to Count - 1 do
    WriteStr(Items[i].Name, fStream);

end;

// TPictureTagList

constructor TPictureTagList.Create;
begin
  inherited;
end;

destructor TPictureTagList.Destroy;
// var
// i: integer;
begin
  // for i := 0 to Count - 1 do
  // Items[i].Free;
  Clear;
  inherited;
end;

function TPictureTagList.Add(TagName: String; p: TTPicture): Integer;
var
  n: Integer;
  t: TPictureTag;
  IGN: Boolean;
begin
  // **** ///
  // EXIT;

  if length(TagName) = 0 then
  begin
    Result := -1;
    Exit;
  end
  else if TagName[1] = #9 then
  begin
    IGN := true;
    System.Delete(TagName, 1, 1);
  end
  else
    IGN := false;

  TagName := lowercase(TagName);

  if not FindPosition(TagName, n) then
  begin
    t := TPictureTag.Create;
    // t.Attribute := taNone;
    t.Name := TagName;
    t.Ignore := IGN; // ignore in StartSearch
    inherited Insert(n, t);
    Result := n;
  end
  else
  begin
    t := Items[n];
    Result := n;
  end;

  if Assigned(p) then
  begin
    p.Tags.FindPosition(t.Name, n);
    p.Tags.Insert(n, t);
    t.Linked.Add(p);
  end;
end;

function TPictureTagList.Add(TagName: String; p: TTPicture;
  Template: TTagTemplate): Integer;
begin
  Result := Add(ReplaceStr(TagName, Template.Spacer, fTagTemplate.Spacer), p);
end;

function TPictureTagList.Find(TagName: String): Integer;
begin
  if not FindPosition(TagName, Result) then
    Result := -1;
end;

procedure TPictureTagList.LoadFromStream(fStream: tStream; fversion: Integer);
var
  i, c: Integer;
begin
  fStream.ReadData(c);
  for i := 0 to c - 1 do
    Add(ReadStr(fStream));
end;

procedure TPictureTagList.LoadListFromFile(FName: string);
var
  s: TStringList;
  i: Integer;
begin
  s := TStringList.Create;
  try
    s.LoadFromFile(FName);
    for i := 0 to s.Count - 1 do
      Add(s[i]);
  finally
    s.Free;
  end;
end;

procedure TPictureTagList.ClearZeros;
var
  i: Integer;
begin
  i := 0;
  while i < Count - 1 do
    if Items[i].Linked.Count < 1 then
      Delete(i);
end;

procedure TPictureTagList.CopyTagList(t: TPictureTagList);
var
  i: Integer;
begin
  for i := 0 to t.Count - 1 do
    Add(t[i].Name, nil, t.TagTemplate);
  // Add(ReplaceStr(t[i].Name, Spacer, t.Spacer), nil);
end;

procedure TPictureTagList.Notify(Ptr: Pointer; Action: TListNotification);
var
  p: TPictureTag;
begin
  case Action of
    lnDeleted:
      begin
        p := Ptr;
        p.Free;
      end;
  end;
end;

procedure TPictureTagList.SavePrepare;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    Items[i].SaveIndex := i;
end;

procedure TPictureTagList.SaveToFile(FName: string);
var
  s: TStringList;
  i: Integer;
  e: TEncoding;
begin
  s := TStringList.Create;
  try
    for i := 0 to Count - 1 do
    if Items[i].Ignore then
      s.Add(#9 + Items[i].Name)
    else
      s.Add(Items[i].Name);
    e := TUnicodeEncoding.Create;
    s.SaveToFile(FName, e);
    e.Free;
  finally
    s.Free;
  end;
end;

procedure TPictureTagList.SaveToStream(fStream: tStream);
var
  i: Integer;
begin
  fStream.WriteData(Count);
  for i := 0 to Count - 1 do
    WriteStr(Items[i].Name, fStream);
end;

// TTPicture

procedure TTPicture.Assign(Value: TTPicture; Links: Boolean);
begin
  FChecked := Value.Checked;
  FStatus := Value.Status;
  FDisplayLabel := Value.DisplayLabel;
  FPicName := Value.PicName;
  FExt := Value.Ext;
  FMeta.Clear;
  // FMeta.Assign(Value.Meta);
  FRemoved := false;

  if Links then
  begin
    FLinked.Assign(Value.Linked);
    FMeta.Assign(Value.Meta);
    FTags.Assign(Value.Tags);
  end;

end;

procedure TTPicture.Clear;
begin
  FLinked.Clear;
  FParent := nil;
  FMeta.Clear;
  FTags.Clear;
end;

constructor TTPicture.Create;
begin
  inherited;
  FNameRemake := false;
  FChecked := false;
  FRemoved := false;
  FStatus := JOB_NOJOB;
  FParent := nil;
  FMeta := TValueList.Create;
  FLinked := TPictureLinkList.Create;
  FLinked.ChildMode := true;
  FTags := TPictureTagLinkList.Create;
  FDisplayLabel := '';
  FFactFileName := '';
  FBookMark := 0;
  FPostProc := false;
  FMD5 := nil;
  FNameCounter := nil;
  FNameNo := 0;
  FPrevPic := nil;
  FNextPic := nil;
  fResourceIndex := -1;
  // FObj := nil;
end;

procedure TTPicture.DeleteFile;
begin
  SysUtils.DeleteFile(FactFileName);
  FactFileName := '';
  FMD5 := nil;
end;

destructor TTPicture.Destroy;
begin
  FMeta.Free;
  FLinked.Free;
  FTags.Free;
  { if Assigned(FObj) then
    Obj.Free; }
  inherited;
end;

procedure TTPicture.LoadFromStream(fStream: tStream; fversion: Integer);
var
  c, i, n: Integer;
  m: TMetaList;
  b: Boolean;
  mName: String;
  mValue: Variant;
  t: TPictureTag;
begin
  fStream.ReadData(fResourceIndex);

  fStream.ReadData(c);
  if c > -1 then
    Parent := List[c];

  FResource := List.ResourceList[ResourceIndex];
  List.ResourceList[ResourceIndex].PictureList.Add(Self);
  if Assigned(Parent) then
    inc(List.ResourceList[ResourceIndex].PictureList.FChildCount)
  else
    inc(List.ResourceList[ResourceIndex].PictureList.FParentCount);

  fStream.ReadData(FChecked);
  FDisplayLabel := ReadStr(fStream);
  FExt := ReadStr(fStream);
  FFactFileName := ReadStr(fStream);
  FFileName := ReadStr(fStream);
  mValue := ReadVar(fStream);
  if tVarData(mValue).VType <> varEmpty then
  begin
    m := FList.Meta.Items[0].Value;

    if not m.FindPosition(mValue, i) then
      FMD5 := m.Add(mValue, i)
    else
      FMD5 := m[i];
  end;

  FOrigFileName := ReadStr(fStream);
  FPicName := ReadStr(fStream);
  fStream.ReadData(FPostProc);
  fStream.ReadData(b);
  if b then
    FStatus := JOB_FINISHED;

  fStream.ReadData(c);
  for i := 0 to c - 1 do
  begin
    mName := ReadStr(fStream);
    mValue := ReadVar(fStream);
    FList.AddPicMeta(Self, mName, mValue);
  end;

  fStream.ReadData(c);
  for i := 0 to c - 1 do
  begin
    fStream.ReadData(c);
    t := FList.Tags[c];
    Tags.FindPosition(t.Name, n);
    Tags.Insert(n, t);
    t.Linked.Add(Self);
  end;

  {
    if Assigned(Parent) then // parent
    fStream.WriteData(Parent.Index)
    else
    fStream.WriteData(integer(-1));
    fStream.WriteData(Checked);
    WriteStr(DisplayLabel, fStream);
    WriteStr(Ext, fStream);
    WriteStr(FactFileName, fStream);
    WriteStr(FileName, fStream);
    if Assigned(MD5) then // possible MD5
    WriteVar(MD5^, fStream)
    else
    WriteVar(Unassigned, fStream);
    WriteStr(OriginalFileName, fStream);
    WriteStr(PicName, fStream);
    fStream.WriteData(PostProcessed);
    fStream.WriteData(Status = JOB_FINISHED);
    Meta.SaveToStream(fStream);

    fStream.WriteData(Tags.Count);
    for i := 0 to Tags.Count - 1 do
    fStream.WriteData(Tags[i].SaveIndex);
  }
end;

procedure TTPicture.MakeMD5(s: tStream);
var
  m: TMetaList;
  i: Integer;
  v: Variant;
begin
  v := lowercase(MD5DigestToStr(MD5Stream(s)));
  m := FList.Meta.Items[0].Value;

  if not m.FindPosition(v, i) then
    FMD5 := m.Add(v, i)
  else
    FMD5 := m[i];
end;

procedure TTPicture.SaveToStream(fStream: tStream);
var
  i: Integer;
begin
  fStream.WriteData(Resource.SaveIndex);
  if Assigned(Parent) then // parent
    fStream.WriteData(Parent.Index)
  else
    fStream.WriteData(Integer(-1));
  fStream.WriteData(Checked);
  WriteStr(DisplayLabel, fStream);
  WriteStr(Ext, fStream);
  WriteStr(FactFileName, fStream);
  WriteStr(FileName, fStream);
  if Assigned(MD5) then // possible MD5
    WriteVar(MD5^, fStream)
  else
    WriteVar(Unassigned, fStream);
  WriteStr(OriginalFileName, fStream);
  WriteStr(PicName, fStream);
  fStream.WriteData(PostProcessed);
  fStream.WriteData(Status = JOB_FINISHED);
  Meta.SaveToStream(fStream);

  fStream.WriteData(Tags.Count);
  for i := 0 to Tags.Count - 1 do
    fStream.WriteData(Tags[i].SaveIndex);
end;

procedure TTPicture.SetParent(Item: TTPicture);
begin
  FParent := Item;
end;

procedure TTPicture.SetPicName(Value: String);
begin
  FExt := trim(ExtractFileExt(Value), '.');
  // if SameText(FExt, 'jpeg') then
  // FExt := DeleteEx(FExt, 3, 1);
  FPicName := ChangeFileExt(Value, '');
end;

procedure TTPicture.SetRemoved(Value: Boolean);
begin
  FRemoved := Value;
end;

// TTPictureLinkList

procedure TPictureLinkList.EndAddList;
begin
  if Assigned(FAfterPictureList) then
    FAfterPictureList(Self);
end;

function TPictureLinkList.Get(Index: Integer): TTPicture;
begin
  Result := inherited Get(Index);
end;

procedure TPictureLinkList.Put(Index: Integer; Item: TTPicture);
begin
  inherited Put(Index, Item);
end;

procedure TPictureLinkList.SetParentsCount(Value: Integer);
begin
  FParentCount := Value;
end;

procedure TPictureLinkList.SetChildsCount(Value: Integer);
begin
  FChildCount := Value;
end;

procedure TPictureLinkList.BeginAddList;
begin
  if Assigned(FBeforePictureList) then
    FBeforePictureList(Self);
end;

procedure TPictureLinkList.CheckExists;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    if Items[i].Checked and fileexists(Items[i].FileName) then
    begin
      Items[i].Checked := false;
      // if Assigned(Items[i].OnPicChanged) then
      // Items[i].OnPicChanged(Items[i],[pcChecked]);
    end;
  end;
end;

function TPictureLinkList.PostProcessFinished: Boolean;
var
  i: Integer;
begin
  for i := FPostFinishCursor to Count - 1 do
    if Items[i].Checked and not Items[i].PostProcessed then
    begin
      FPostFinishCursor := i;
      Result := false;
      Exit;
    end;

  FPostFinishCursor := Count;
  Result := true;
end;

function TPictureLinkList.AllFinished(incerrs: Boolean;
  incposts: Boolean): Boolean;
var
  i: Integer;
  dp: set of byte;

  function rule(p: TTPicture): Boolean;
  begin
    Result := not(p.Status in dp) and p.Checked;
  end;

begin
  dp := [JOB_SKIP, JOB_BLACKLISTED, JOB_FINISHED];

  if incerrs then
    dp := dp + [JOB_ERROR];

  if incposts then
    dp := dp + [JOB_POSTFINISHED];

  for i := FFinishCursor to Count - 1 do
    if rule(Items[i]) and ((Items[i].Linked.Count = 0) or
      not Items[i].Linked.AllFinished(incerrs, incposts)) and
      (not Assigned(Items[i].Parent) or ChildMode and rule(Items[i].Parent))
    then
    begin
      FFinishCursor := i;
      Result := false;
      Exit;
    end;

  FFinishCursor := Count;
  FCursor := Count;
  Result := true;
end;

function TPictureLinkList.NextJob(Status: Integer): TTPicture;
var
  i: Integer;

begin
  if Status = JOB_POSTPROCESS then
  begin
    Result := NextPostProcJob;
    Exit;
  end;

  if FCursor < Count then
  begin
    Result := nil;

    for i := FCursor to Count - 1 do
      if ((Items[i].Status in [JOB_NOJOB, JOB_POSTFINISHED]) or
        (Items[i].Status = JOB_INPROGRESS) and (Items[i].Linked.Count > 0) and
        (not Items[i].Linked.eol)) and (Items[i].Checked) then
        // if not Assigned(Items[i].Parent) then
        if (Items[i].Linked.Count > 0) then
          if not(Items[i].Linked.eol) then
          begin
            Result := Items[i].Linked.NextJob(Status);
            if Assigned(Result) then
            begin
              Items[i].Status := JOB_INPROGRESS;
              FLastJobIdx := i;
              // FCursor := i;
              Break;
            end;
          end
          else
        else if (not Assigned(Items[i].Parent)) or ChildMode then
        begin
          Items[i].Status := JOB_INPROGRESS;
          Result := Items[i];
          FLastJobIdx := i;
          // FCursor := i + 1;
          Break;
        end;

    RestartCursor(FCursor);
    // for i := FCursor to Count - 1 do
    // if (Items[i].Status = JOB_NOJOB) and (Items[i].Checked) then
    // begin
    // FCursor := i;
    // Exit;
    // end;
    //
    // FCursor := Count;
    // Result := nil;
  end
  else
    Result := nil;
end;

function TPictureLinkList.NextPostProcJob: TTPicture;
var
  i: Integer;

begin
  Result := nil;

  for i := FPostCursor to Count - 1 do
    if (Items[i].Checked and not Items[i].PostProcessed) and
      not Assigned(Items[i].Parent) and (Items[i].Status = JOB_NOJOB) then
    begin
      Result := Items[i];
      Items[i].Status := JOB_POSTPROCINPROGRESS;
      FLastPostJobIdx := i;
      FPostCursor := i + 1;
      Break;
    end;

  try
    for i := FPostCursor to Count - 1 do
      if (Items[i].Checked and not Items[i].PostProcessed) and
        not Assigned(Items[i].Parent) and (Items[i].Status = JOB_NOJOB) then
      begin
        FPostCursor := i;
        Exit;
      end;

    FPostCursor := Count;
  finally
    if FCursor <= FPostCursor then
      RestartCursor(FCursor);
  end;

  // Result := nil;
end;

function TPictureLinkList.eol: Boolean;
begin
  Result := not(FCursor < ParentCount);
end;

function TPictureLinkList.posteol: Boolean;
begin
  Result := not(FPostCursor < ParentCount);
end;

procedure TPictureLinkList.SaveToCSV(FName: string);
var
  f: TFileStream;
begin
  f := TFileStream.Create(FName, fmCreate or fmOpenWrite);
  try
    f.WriteData($FEFF);
    SaveToCSV(f);
  finally
    f.Free;
  end;
end;

procedure TPictureLinkList.SaveToCSV(fStream: tStream);
var
  i: Integer;
  s: UnicodeString;
  fmt: TTagTemplate;
begin
  fmt.Spacer := '_';
  fmt.Separator := ' ';
  fmt.Isolator := '';
  for i := 0 to Count - 1 do
    if length(Items[i].FactFileName) > 0 then
    begin
      if Assigned(Items[i].MD5) then

        s := '"' + Items[i].FactFileName + '";"' + VarToStr(Items[i].MD5^) +
          '";"' + Items[i].Tags.AsString(fmt) + '";' + #13#10;
      fStream.Write(s[1], length(s) * 2);

      // fStream.Write(#13#10,2);

    end;
end;

// TTPictureList

function TPictureList.Add(APicture: TTPicture; Resource: TResource): Integer;
begin
  Result := inherited Add(APicture);
  APicture.OnPicChanged := OnPicChanged;
  APicture.Resource := Resource;
  APicture.List := Self;
  { if (FNameFormat <> '')
    and (APicture.Resource.NameFormat <> '')
    and (APicture.FileName <> '') then
    APicture.MakeFileName(FNameFormat); }
  // MakePicFileName(Result, NameFormat);
  // if Assigned(FOnAddPicture) then
  // FOnAddPicture(APicture);
end;

function TPictureList.DirNumber(Dir: String): word;
var
  n: Integer;
  v: PWORD;
begin
  Dir := lowercase(Dir);
  n := FDirList.IndexOf(Dir);
  if n = -1 then
  begin
    New(v);
    v^ := 0;
    n := FDirList.Add(Dir);
    FDirList.Objects[n] := TObject(v);
  end
  else
  begin
    v := PWORD(FDirList.Objects[n]);
    v^ := v^ + 1;
  end;

  Result := v^;
end;

procedure TPictureList.disposeDirList;
var
  v: pNameCounter;
  v2: PWORD;
  i: Integer;
  // s: PString;
begin
  for i := 0 to FDirList.Count - 1 do
  begin
    v2 := PWORD(FDirList.Objects[i]);
    Dispose(v2);
  end;

  for i := 0 to FFileNames.Count - 1 do
    if Assigned(FFileNames.Objects[i]) then
    begin
      v := pNameCounter(FFileNames.Objects[i]);
      Dispose(v);
    end;
end;

function TPictureList.fNameDec(APic: TTPicture; FName: string; InstUp: Boolean)
  : pNameCounter;
var
  LPic: TTPicture;
begin
  LPic := APic.NameCounter.Last;

  dec(LPic.NameCounter.Counter);

  if Assigned(LPic) then
  begin
    if (LPic.prevPic = nil) and (LPic <> LPic.NameCounter.First) then
      raise Exception.Create('fnamedec:lpic.prev=nil&lpic<>first(fname=' +
        FName + ')');

    if LPic <> APic then
    begin
      LPic.NameNo := APic.NameNo;

      // change prevpic's link to next

      // LPic.prevPic.nextPic := nil;

      if LPic.prevPic = APic then
      begin
        // if Assigned(APic.prevPic) then
        // APic.prevPic.nextPic := LPic;
      end
      else
      begin
        LPic.NameCounter.Last := LPic.prevPic;
        LPic.prevPic.nextPic := nil;
        LPic.nextPic := APic.nextPic;
        LPic.nextPic.prevPic := LPic;
      end;

      LPic.prevPic := APic.prevPic;

      if Assigned(LPic.prevPic) then
        LPic.prevPic.nextPic := LPic
      else
        LPic.NameCounter.First := LPic;

      if APic.NameNo > 0 then
        fNamePatchDec(APic, APic.FileName);
    end
    else
    begin
      LPic.NameCounter.Last := LPic.prevPic;
      LPic.nextPic := nil;
      if (LPic.NameCounter.First = LPic) and (LPic.NameCounter.Last = nil) then
        LPic.NameCounter.First := nil;

      LPic := nil;
    end;
  end;

  APic.prevPic := nil;
  APic.NameCounter := nil;
  APic.NameNo := 0;

  if Assigned(LPic) then
    if InstUp then
    begin
      MakePicFileName(LPic.Index, NameFormat, Assigned(LPic.Parent));
      LPic.NameUpdated := false;
    end
    else
      LPic.NameUpdated := true;

  Result := APic.NameCounter;
end;

function TPictureList.fNamePatchDec(APic: TTPicture; FName: string)
  : pNameCounter;
var
  n: Integer;
  v: pNameCounter;
  LPic: TTPicture;
begin
  if strFind(FName, FFileNames, n) then
  begin
    v := pNameCounter(FFileNames.Objects[n]);

    if Assigned(v) then // if data for patch exists, then we should
      // make new "real" owner for it

      if APic.NameCounter <> v then // patch for own source is not a patch
      begin
        // if lpic.prevPic = nil then
        // raise Exception.Create('fnamepatchdec:lpic.prevpic=nil');
        v^.Counter := v^.Counter - 1;
        LPic := v^.Last;
        v^.First.prevPic := LPic;
        v^.First := LPic;
        LPic.NameNo := 0;
        v^.Last := LPic.prevPic;
        LPic.prevPic := nil;
        MakePicFileName(LPic.Index, NameFormat, Assigned(LPic.Parent));
      end
      else
    else
      FFileNames.Delete(n); // else just remove patch

    Result := v;
  end
  else
    Result := nil;
end;

procedure TPictureList.LoadFromStream(fStream: tStream; fversion: Integer;
  fCB: TCallBackProgress);
var
  i, c: Integer;
  p: TTPicture;
  cancel: boolean;
begin
  cancel := false;
  FTags.LoadFromStream(fStream, fversion);
  fStream.ReadData(c);

  //if Assigned(fCB) then
  //  fCB(0, c);

  for i := 0 to c - 1 do
  begin
    p := TTPicture.Create;
    p.Index := i;
    Add(p, nil);
    p.LoadFromStream(fStream, fversion);
    if Assigned(p.Parent) then
    begin
      p.Parent.Linked.Add(p);
      inc(p.Parent.Linked.FParentCount);
      p.BookMark := p.Parent.Linked.Count;
      inc(FChildCount);
    end
    else
    begin
      inc(FParentCount);
      p.BookMark := FParentCount;
    end;
    if Assigned(fCB) and (i mod 1000 = 0) then
    begin
      fCB(i + 1, c, cancel);
      if cancel then
        raise Exception.Create('Loading aborted');
    end;
  end;
  if Assigned(fCB) then
    fCB(c, c, cancel);
end;

procedure TPictureList.SaveToStream(fStream: tStream; fCB: TCallBackProgress);
var
  i: Integer;
  cancel: boolean;
begin
  cancel := false;
  FTags.SavePrepare;
  FTags.SaveToStream(fStream);

  fStream.WriteData(Count);
  for i := 0 to Count - 1 do
  begin
    Items[i].SaveToStream(fStream);
    if Assigned(fCB) and (i mod 1000 = 0) then
    begin
      fCB(i + 1, Count, cancel);
      if cancel then raise Exception.Create('Saving aborted');
    end;
  end;

  if Assigned(fCB) then
    fCB(Count, Count, cancel);
end;

procedure TPictureList.SetPicChange(Value: TPicChangeEvent);
var
  i: Integer;
begin
  FPicChange := Value;
  for i := 0 to Count - 1 do
    Items[i].OnPicChanged := Value;
end;

function TPictureList.AddfName(APic: TTPicture; FName: string; InstUp: Boolean)
  : pNameCounter;
var
  n: Integer;
  v: pNameCounter;
  R: Boolean;
begin
  R := strFind(FName, FFileNames, n);

  if R then
    v := pNameCounter(FFileNames.Objects[n])
  else
    v := nil;

  if R and Assigned(v) then
  begin
    if Assigned(FSameNames) then
      FSameNames(Self, FName);

    // v := pNameCounter(FFileNames.Objects[n]);

    if APic.NameCounter = v then
    begin
    end
    else
    begin
      if Assigned(APic.NameCounter) then
        fNameDec(APic, APic.FileName, InstUp);

      if Assigned(v.Last) then
      begin
        v.Last.nextPic := APic;
        APic.prevPic := v.Last;
        v.Last := APic;
      end
      else if Assigned(v.First) then
        raise Exception.Create('v.last not assigned (counter=' +
          IntToStr(v.Counter) + ',fname=' + FName + ')')
      else
      begin
        v.First := APic;
        v.Last := APic;
      end;

      v.Counter := v.Counter + 1;
      APic.NameCounter := v;
      APic.NameNo := v.Counter;
    end;

  end
  else
  begin
    New(v);
    if not R then
    begin
      v^.Counter := 0;
      FFileNames.Insert(n, FName);
      FFileNames.Objects[n] := TObject(v);

      if Assigned(APic.NameCounter) then
        fNameDec(APic, APic.FileName, InstUp);
    end
    else
    begin
      v^.Counter := 1;
      FFileNames.Objects[n] := TObject(v);
    end;

    APic.prevPic := nil;
    v^.First := APic;
    v^.Last := APic;
    APic.NameCounter := v;
    APic.NameNo := v^.Counter;
  end;

  Result := v;
end;

function TPictureList.AddfNamePatch(APic: TTPicture; FName: string;
  InstUp: Boolean): pNameCounter;
var
  n: Integer;
  v: pNameCounter;
begin
  if not Assigned(APic.NameCounter) then
    v := AddfName(APic, FName, InstUp)
  else if not strFind(FName, FFileNames, n) then
  begin
    v := nil;

    FFileNames.Insert(n, FName);
    FFileNames.Objects[n] := TObject(v);
  end
  else
    v := pNameCounter(FFileNames.Objects[n]);
  Result := v;
end;

procedure TPictureList.AddPicList(APicList: TPictureList;
  ParentPic: TTPicture = nil);
var
  i, j { , v } : Integer;
  n: DWORD;
  t, ch: TTPicture;
begin
  i := 0;
  n := GetTickCount;
  try
    while i < APicList.Count do
      if UseBlackList and CheckBlackList(APicList[i]) then
      begin
        inc(i);
        inc(FPicCounter.BLK);
      end
      else

        if not CheckDoubles(APicList[i]) then
      begin
        if not Assigned(APicList[i].Parent) then
        begin
          t := CopyPicture(APicList[i], false);
          t.BookMark := ParentCount;

          for j := 0 to APicList[i].Linked.Count - 1 do
          // if not CheckDoubles(APicList[i].Linked[j]) then
          begin
            ch := CopyPicture(APicList[i].Linked[j], true);
            ch.BookMark := j + 1;
            t.Linked.Add(ch);
            inc(t.Linked.FParentCount);
            ch.Parent := t;
            ch.PostProcessed := true;
          end;
        end
        else if APicList[i].Parent = ParentPic then
        begin
          t := CopyPicture(APicList[i], true);
          t.PostProcessed := true;
          t.Parent := ParentPic;
          t.BookMark := ParentPic.Linked.Add(t) + 1;
          inc(ParentPic.Linked.FParentCount);
        end;
        inc(i);
      end
      else
      begin
        inc(i);
        inc(FPicCounter.IGN);
      end;

  finally
    FDoublesTickCount := GetTickCount - n;
  end;
end;

procedure TPictureList.AddPicMeta(Pic: TTPicture; MetaName: String;
  MetaValue: Variant);
var
  v: PVariant;
  n: Integer;
  p: TMetaList;
begin
  try
    p := FMetaContainer[MetaName];

    if p = nil then
    begin
      p := TMetaList.Create;
      FMetaContainer[MetaName] := p;
    end;

    if p.FindPosition(MetaValue, n) then
      v := p[n]
    else
      v := p.Add(MetaValue, n);

    Pic.Meta.SetLink(MetaName, v);
  except
    on e: Exception do
    begin
      e.Message := MetaName + ': ' + e.Message;
      raise;
    end;
  end;
end;

function TPictureList.CopyPicture(Pic: TTPicture; Child: Boolean): TTPicture;
var
  i: Integer;
begin
  if not Assigned(Pic) then
  begin
    Result := nil;
    Exit;
  end;

  Result := TTPicture.Create;
  Result.Assign(Pic);

  for i := 0 to Pic.Meta.Count - 1 do
    AddPicMeta(Result, Pic.Meta.Items[i].Name, Pic.Meta.Items[i].Value);

  for i := 0 to Pic.Tags.Count - 1 do
    Tags.Add(Pic.Tags[i].Name, Result, Pic.Resource.HTTPRec.TagTemplate);

  if Child then
  begin
    i := ParentCount + ChildCount;
    Insert(i, Result);
    Result.Index := ChildCount;
    inc(FChildCount);
  end
  else
  begin
    i := ParentCount;
    Insert(i, Result);
    inc(FParentCount);
    Result.Index := i;
  end;

  Result.Resource := Pic.Resource;
  Result.Resource.PictureList.Add(Result);
  if Child then
    inc(Result.Resource.PictureList.FChildCount)
  else
    inc(Result.Resource.PictureList.FParentCount);
  Result.OnPicChanged := OnPicChanged;
  Result.List := Self;

  // Result.MakeFileName(FNameFormat);

  MakePicFileName(i, NameFormat, false);
  // if Assigned(FOnAddPicture) then
  // FOnAddPicture(Result);
end;

constructor TPictureList.Create(makenames: Boolean);
var
  md5item: TTagedListValue;
  md5meta: TMetaList;
begin
  inherited Create;
  FTags := TPictureTagList.Create;

  md5meta := TMetaList.Create;
  // md5meta.VariantType := varUString;
  md5meta.ValueType := DB.ftString;
  md5item := TTagedListValue.Create;
  md5item.Name := '';
  md5item.Value := md5meta;
  FMetaContainer := TTagedList.Create;
  FMetaContainer.Add(md5item);

  if makenames then
  begin
    FDirList := TStringList.Create;
    FFileNames := TStringList.Create;
  end;

  FMakeNames := makenames;
  FIgnoreList := nil;
  FParentCount := 0;
  FChildCount := 0;
  FChildMode := false;
end;

destructor TPictureList.Destroy;
begin
  Clear;
  FTags.Free;
  DeallocateMeta;
  FMetaContainer.Free;
  if makenames then
  begin
    disposeDirList;
    FDirList.Free;
    FFileNames.Free;
  end;
  inherited;
end;

procedure TPictureList.MakePicFileName(Index: Integer; Format: String;
  Child: Boolean; InstUp: Boolean = false);
const
  FN_LN = 199;
var
  fncounter: byte;
  fnoext: Boolean;

  // check names
  function ParamCheck(Pic: TTPicture; bfr, bfr2, s2, aft, aft2: String;
    level: byte; main, b: Boolean; var Value: Variant): Boolean;

    function formatstr(Value: Variant; aformat: string; d: byte): string;
    var
      t: Integer;
      pt, ndr: Boolean;
    begin
      case d of
        // 0: begin pt := false; dr := true; end;
        1:
          begin
            pt := true;
            ndr := true;
          end;
        2:
          begin
            pt := true;
            ndr := false;
          end;
      else
        begin
          pt := false;
          ndr := true;
        end;
      end;

      if (aformat = '') then
        Result := ValidFName(Value, pt, ndr)
      else if VarIsType(Value, varDate) then
        Result := ValidFName(FormatDateTime(aformat, Value), pt, ndr)
      else
      begin
        t := CharPosEx(s2, ['d', 'e', 'f', 'g', 'n', 'm', 'p', 's', 'u', 'x',
          'D', 'E', 'F', 'G', 'N', 'M', 'P', 'S', 'U', 'X'], [], []);
        case lowercase(s2[t])[1] of
          'd', 'u', 'x':
            Result := ValidFName(SysUtils.Format('%' + s2, [Trunc(Value)]
              ), pt, ndr);
          'e', 'f', 'g', 'n', 'm':
            Result := ValidFName(SysUtils.Format('%' + s2, [Double(Value)]
              ), pt, ndr);
          's':
            Result := ValidFName(SysUtils.Format('%' + s2, [VarToStr(Value)]
              ), pt, ndr);
          'p':
            begin
              s2[t] := 'x';
              Result := ValidFName(SysUtils.Format('%' + s2, [Trunc(Value)]
                ), pt, ndr);
            end;
          // s2[2] := 'x';
        end;
        // Result := ValidFName(SysUtils.Format('%'+s2,[VarToStr(n.Value])));
      end;
    end;

  var
    n: TListValue;
    s, p, tmp: string;
    c: Integer;
    d: byte; // path mode; 0 - not a path, 1 - path without drive, 2 - path with drive
    // nc: pNameCounter;
  begin
    Result := true;
    tmp := s2;
    s := GetNextS(s2, ':');
    p := CopyFromTo(s, '(', ')', true);
    if p <> '' then
      s := CopyTo(s, '(');
    d := 0;
    if main then
      if SameText(s, 'nn') then
        Value := IndexOf(Pic) + 1
      else if SameText(s, 'fnn') then
      begin
        if p <> '' then
          c := Max(StrToInt(p), 1)
        else
          c := 1;
        Value := (DirNumber(ExtractFilePath(bfr + bfr2)) div c) + 1
      end
      else if SameText(s, 'fn') then
        if (level < 1) then
        begin
          inc(fncounter);
          Value := null;
          Result := false;
          Exit;
        end
        else if fncounter = 1 then
        begin
          Value := 0;
          // repeat

          if b and (Value = 0) then
            p := bfr + aft
          else
            p := bfr + bfr2 + formatstr(Value, s2, 0) + aft2 + aft;

          if ExtractFileName(p) = '' then
          begin
            Value := null;
            Exit;
          end;

          if fnoext then
            p := p + '.' + Pic.Ext;

          { nc := } AddfName(Pic, p, InstUp); // fNameNumber(p);

          Value := Pic.NameNo;

          if (Value = 0) and b then
          begin
            Value := null;
            Exit;
          end;
        end
        else
        begin
          dec(fncounter);
          if b then
          begin
            Value := null;
            Exit;
          end
          else
            Value := 0;
        end
      else if SameText(s, 'md5') then
        if not Assigned(Pic.MD5) then
        begin
          Pic.NeedNameRemake := true;
          Value := '$md5$';
          // Result := false;
          // Exit;
        end
        else
          Value := Pic.MD5^
      else if SameText(s, 'rname') then
        Value := Pic.Resource.Name
      else if SameText(s, 'short') then
        Value := Pic.Resource.Short
      else if SameText(s, 'fname') then
        Value := ValidFName(Pic.PicName)
      else if SameText(s, 'ext') then
        Value := Pic.Ext
      else if SameText(s, 'date') then
        Value := Date
      else if SameText(s, 'time') then
        Value := Time
      else if SameText(s, 'rootdir') then
      begin
        Value := ExtractFileDir(paramstr(0));
        d := 2;
      end
      else if SameText(s, 'tag') then
        with Pic.Tags do
          // Value := VarToStr(Pic.Resource.Fields['tag'])
          Value := Pic.Resource.RestoreTagString
            (VarToStr(Pic.Resource.Fields['tag']), TagTemplate)
      else if SameText(s, 'tags') then
      begin
        if p = '' then
          c := 0
        else
          c := StrToInt(p);
        Value := Pic.Tags.AsString(c);
      end

      else
      begin
        Value := null;
        Result := false;
        Exit;
      end
    else
    begin
      n := Pic.Meta.FindItem(s) as TListValue;
      d := 1;

      if n = nil then
      begin
        Value := null;
        Result := false;
        Exit;
      end
      else
        Value := n.Value;
    end;

    Value := formatstr(Value, s2, d);
  end;

// check keywords: $main$, %editional%, if b then result = '' if key = ''
  function ParseValues(Pic: TTPicture; bfr, s, aft: String; level: byte;
    b: Boolean = true): String;
  var
    i, n: Integer;
    genval, // generic (%%) value exists
    gvalrs, // generic (%%) value have result
    conval, // constant ($$) value exists
    havers, // have result
    hghlvl: Boolean; // if $$ not generated then it must be genetared leter
    key: string;
    rsl: Variant;
    isl: array of string;
    brk: array of string;
  begin
    genval := false;
    gvalrs := false;
    conval := false;
    havers := false;
    hghlvl := false;
    SetLength(isl, 0);
    if not b then
    begin
      SetLength(brk, 1);
      brk[0] := '<>';
    end
    else
      SetLength(brk, 0);

    n := CharPosEx(s, ['$', '%'], isl, brk);

    while n <> 0 do
    begin
      i := n;
      n := CharPosEx(s, ['$', '%'], isl, brk, i + 1);

      if n = 0 then
        Break
      else if s[i] <> s[n] then
        Continue;

      key := Copy(s, i + 1, n - i - 1);

      if not genval and (s[i] = '%') then
        genval := true
      else if not conval and (s[i] = '$') then
        conval := true;

      if ParamCheck(Pic, bfr, Copy(s, 1, i - 1), key, aft,
        Copy(s, n + 1, length(s) - n), level, s[i] = '$', b, rsl) then
      begin
        if (VarToStr(rsl) <> '') then
        begin
          havers := true;
          if (s[i] = '%') then
            gvalrs := true;
        end;

        s := StringReplace(s, s[i] + key + s[n], VarToStr(rsl), []);
      end
      else
      begin
        if b and (level < 1) and (s[i] = '$') then
          hghlvl := true;
        Continue;
      end;

      n := CharPosEx(s, ['$', '%'], isl, brk, i + 1);
    end;

    if b then
      if genval and not gvalrs then
        Result := ''
      else if hghlvl then
        Result := '<' + s + '>'
      else if havers then
        Result := s
      else
        Result := ''
    else
      Result := s;

  end;

// check "<>" sections
  function ParseSections(Pic: TTPicture; s: string): string;
  var
    i, n, l, level: Integer;
  begin
    // s := ParseValues(pic,s, false);
    fncounter := 0;
    for level := 0 to 1 do
    begin
      if (level = 1) and (fncounter = 0) then
        Break;

      l := length(s);
      n := PosEx('<', s);
      i := 1;

      Result := '';

      while n <> 0 do
      begin
        Result := Result + ParseValues(Pic, Result, Copy(s, i, n - i),
          Copy(s, n + 1, l - n { - 1 } ), level, false);
        i := n;

        n := PosEx('>', s, i + 1);

        if n <> 0 then
        begin
          Result := Result + ParseValues(Pic, Result, Copy(s, i + 1, n - i - 1),
            Copy(s, n + 1, l - n { - 1 } ), level);
          i := n + 1;
        end;

        n := PosEx('<', s, i);
      end;

      Result := Result + ParseValues(Pic, Result, Copy(s, i, l - i + 1), '',
        level, false);
      s := Result;
    end;
  end;

// check file and directories lengths
  procedure Checklength(Pic: TTPicture);
  var
    s, s1, s2: string;
  begin
    s2 := Pic.FileName;
    s := '';

    while s2 <> '' do
    begin
      s1 := CopyTo(s2, '\', [], [], true);

      if length(s1) > FN_LN then
        if s2 = '' then
        begin
          s1 := ChangeFileExt(s1, '');

          SetLength(s1, FN_LN - 12);

          s1 := ParseSections(Pic, s1 + '<($fn$)>.$ext$');
        end
        else
          SetLength(s1, FN_LN);

      if s2 = '' then
        s := s + s1
      else { if length(s + s1) > 317 then
          begin

          end else }
        s := s + s1 + '\';

    end;

    Pic.FileName := s;
  end;

// make name
  procedure makeName(Pic: TTPicture);
  begin

    if Format = '' then
      if NameFormat = '' then
        if Pic.Resource.NameFormat = '' then
          Pic.FileName := ''
        else
          Format := Pic.Resource.NameFormat
      else
        Format := NameFormat;

    fnoext := System.Pos('$ext$', ExtractFileName(lowercase(Format))) = 0;
    if System.Pos('$fn$', ExtractFileName(lowercase(Format))) = 0 then
      if fnoext then
        Format := Format + '<($fn$)>'
      else
        Format := ChangeFileExt(Format, '') + '<($fn$)>' +
          ExtractFileExt(Format);

    // if Assigned(Pic.NameCounter) then
    // fNameDec(Pic.NameCounter,Pic.NameNo);

    Pic.FileName := ParseSections(Pic, Format);

    if ExtractFileName(Pic.FileName) = '' then
    begin
      fnoext := false;
      if Pic.PicName <> '' then
        if Pic.Ext <> '' then
          Pic.FileName := ParseSections(Pic,
            Pic.FileName + '$fname$<($fn$)>.$ext$')
        else
          Pic.FileName := ParseSections(Pic, Pic.FileName + '$fname$<($fn$)>')
      else if Pic.Ext <> '' then
        Pic.FileName := ParseSections(Pic, Pic.FileName + '$fn$.$ext$')
      else
        Pic.FileName := ParseSections(Pic, Pic.FileName + '$fn$')
    end
    else if fnoext and (Pic.Ext <> '') then
      Pic.FileName := Pic.FileName + '.' + Pic.Ext;

    Checklength(Pic);
    AddfNamePatch(Pic, Pic.FileName, InstUp);
    Pic.NameUpdated := false;

  end;

var
  i: Integer;

begin
  if not makenames then
    Exit;

  if index = -1 then
    for i := 0 to Count - 1 do
      makeName(Items[i])
  else if Child then
    makeName(Items[ParentCount + index])
  else
    makeName(Items[index])
end;

procedure TPictureList.Notify(Ptr: Pointer; Action: TListNotification);
var
  p: TTPicture;
  i: Integer;
begin
  case Action of
    lnDeleted:
      begin
        p := Ptr;
        p.Removed := true;
        { if Assigned(p.OnPicChanged) then
          p.OnPicChanged(p, [pcDelete]); }
        p.Parent := nil;
        if p.Tags <> nil then
        begin
          for i := 0 to p.Tags.Count - 1 do
            p.Tags[i].Linked.Remove(p);
        end;
        { if p.Linked <> nil then
          for i := 0 to p.Linked.Count - 1 do
          Remove(p.Linked[i]); }
        p.Free;
      end;
  end;
end;

procedure TPictureList.DeallocateMeta;
var
  i: Integer;
  p: TMetaList;
begin
  for i := 0 to FMetaContainer.Count - 1 do
  begin
    p := FMetaContainer.Items[i].Value;
    p.Free;
  end;
  FMetaContainer.Clear;
end;

procedure TPictureLinkList.Reset;
var
  i: Integer;

begin
  ResetPicCounter;

  FLastJobIdx := -1;
  FFinishCursor := 0;
  // FPostCursor := 0;
  // FPostFinishCursor := 0;

  i := 0;

  for i := i to Count - 1 do
    if (Items[i].Checked) then
      Break
    else
      inc(FPicCounter.UNCH);

  FCursor := i;

  for i := i to Count - 1 do
    if (not Assigned(Items[i].Parent) or ChildMode) and (Items[i].Checked) then
    begin
      Items[i].Status := JOB_NOJOB;
      if Items[i].Size <> 0 then
      begin
        Items[i].Pos := 0;
        Items[i].Size := 0;
        if Assigned(Items[i].OnPicChanged) then
          Items[i].OnPicChanged(Items[i], [pcSize, pcProgress]);
      end;
      if Items[i].Linked.Count > 0 then
      begin
        Items[i].Linked.Reset;
        if Items[i].Linked.eol then
        begin
          Items[i].Checked := false;
          if Assigned(Items[i].OnPicChanged) then
            Items[i].OnPicChanged(Items[i], [pcSize, pcProgress, pcChecked]);
        end;
      end;
    end
    else
      inc(FPicCounter.UNCH);

  AllFinished(true, true);
  // PostProcessFinished;
end;

procedure TPictureLinkList.ResetCursors;
begin
  FCursor := 0;
  FFinishCursor := 0;
  FPostCursor := 0;
  FPostFinishCursor := 0;

  ResetPicCounter;
  AllFinished(true, true);
  PostProcessFinished;
end;

procedure TPictureLinkList.ResetPicCounter;
begin
  with FPicCounter do
  begin
    OK := 0;
    ERR := 0;
    SKP := 0;
    IGN := 0;
    EXS := 0;
    FSH := 0;
    UNCH := 0;
    BLK := 0;
  end;
end;

procedure TPictureLinkList.ResetPost;
var
  i: Integer;
begin
  FPostFinishCursor := 0;
  PostProcessFinished;
  FPostCursor := FPostFinishCursor;
  for i := FPostCursor to ParentCount - 1 do
    if not Items[i].PostProcessed then
      Items[i].Status := JOB_NOJOB;
end;

procedure TPictureLinkList.RestartCursor(AFrom: Integer = 0);
var
  i: Integer;
begin
  // if FCursor < AFrom then
  // Exit
  // else
  if AFrom < FCursor then
    FCursor := AFrom;
  for i := FCursor to Count - 1 do
    if (((Items[i].Status in [JOB_NOJOB, JOB_POSTFINISHED]) or
      (Items[i].Status = JOB_INPROGRESS) and (Items[i].Linked.Count > 0) and
      not Items[i].Linked.eol) and (Items[i].Checked)) and
      (not Assigned(Items[i].Parent) or ChildMode) then
    begin
      FCursor := i;
      Exit;
    end;
  FCursor := Count;
end;

procedure TPictureLinkList.RestartPostCursor(AFrom: Integer = 0);
var
  i: Integer;
begin
  // if FCursor < AFrom then
  // Exit
  // else
  if AFrom < FPostCursor then
    FPostCursor := AFrom;
  for i := FPostCursor to Count - 1 do
    if Items[i].Checked and not Items[i].PostProcessed then
    begin
      FPostCursor := i;
      Exit;
    end;
  FPostCursor := Count;
end;

function TPictureList.CheckBlackList(Pic: TTPicture): Boolean;
var
  i, l: Integer;
begin
  for i := 0 to length(FBlackList) - 1 do
    if SameText(FBlackList[i][0], 'tags') then
      if Pic.Tags.FindPosition(FBlackList[i][1], l) then
      begin
        Result := true;
        Exit;
      end
      else
    else if SameText(VarToStr(Pic.Meta[FBlackList[i][0]]), FBlackList[i][1])
    then
    begin
      Result := true;
      Exit;
    end;
  Result := false;
end;

function TPictureList.CheckDoubles(Pic: TTPicture): Boolean;
var
  i: Integer;
  sstr, rstr, srfield, chfield: String;
  v1: Variant;
  m: TMetaList;
  Pos: Integer;
begin
  Result := false;
  for i := 0 to length(FIgnoreList) - 1 do
  begin
    sstr := trim(FIgnoreList[i][1]);
    while sstr <> '' do
    begin
      Result := false;
      rstr := trim(CopyTo(sstr, ';', ['""'], [], true));
      srfield := trim(CopyTo(rstr, '=', ['""'], [], true));
      v1 := Pic.Meta[srfield];
      if VarToStr(v1) <> '' then
        while rstr <> '' do
        begin
          chfield := trim(CopyTo(rstr, ',', ['""'], [], true));
          m := FMetaContainer[chfield];
          if Assigned(m) and (m.FindPosition(v1, Pos)) then
          begin
            Result := true;
            Break;
          end;
        end;

      if not Result then
        Break;
    end;

    if Result then
      Break;

  end;
end;

procedure TPictureList.Clear;
begin
  inherited Clear;
  ResetPicCounter;
  FTags.Clear;
  DeallocateMeta;
  FMetaContainer.Clear;
  FCursor := 0;
  FParentCount := 0;
  FChildCount := 0;
end;

// TRESOUCEFIELDS

procedure TResourceFields.Assign(List: TResourceFields;
  AOperator: TListAssignOp);
var
  i: Integer;
  // p: PResourceField;

begin
  case AOperator of
    laCopy:
      begin
        Clear;
        Capacity := List.Capacity;
        for i := 0 to List.Count - 1 do
        begin
          // New(p);
          with List.Items[i]^ do
            AddField(resname, restitle, restype, resvalue, resitems, InMulti);
          // Add(p);
        end;
      end;
    laAnd:
      ;
    laOr:
      begin
        for i := 0 to List.Count - 1 do
          Values[List.Items[i].resname] := List.Items[i].resvalue;
      end;
    laXor:
      ;
    laSrcUnique:
      ;
    laDestUnique:
      ;
  end;

end;

destructor TResourceFields.Destroy;
begin
  Clear;
  inherited;
end;

function TResourceFields.FindField(resname: String): Integer;
var
  i: Integer;
begin
  resname := lowercase(resname);
  for i := 0 to Count - 1 do
    if Items[i].resname = resname then
    begin
      Result := i;
      Exit;
    end;
  Result := -1;
end;

procedure TResourceFields.Notify(Ptr: Pointer; Action: TListNotification);
var
  p: PResourceField;
begin
  case Action of
    lnDeleted:
      begin
        p := Ptr;
        Dispose(p);
      end;
  end;
end;

function TResourceFields.Get(Index: Integer): PResourceField;
begin
  Result := inherited Items[Index];
end;

{ procedure TResourceFields.Put(Index: integer; Value: TResourceField);
  var
  p: PResourceField;
  begin
  p := inherited Items[Index];
  p^ := Value;
  end; }

function TResourceFields.GetValue(ItemName: String): Variant;
var
  i: Integer;
begin
  ItemName := lowercase(ItemName);
  for i := 0 to Count - 1 do
    if Items[i].resname = ItemName then
    begin
      Result := Items[i].resvalue;
      Exit;
    end;
  Result := null;
end;

procedure TResourceFields.SetValue(ItemName: String; Value: Variant);
var
  i: Integer;

begin
  ItemName := lowercase(ItemName);
  for i := 0 to Count - 1 do
    if Items[i].resname = ItemName then
    begin
      Items[i].resvalue := Value;
      Exit;
    end;
  raise Exception.Create('field does not exist: ' + ItemName);
end;

function TResourceFields.AddField(resname: string; restitle: string;
  restype: TFieldType; resvalue: Variant; resitems: String;
  InMulti: Boolean): Integer;
var
  p: PResourceField;
begin
  if resname = '' then
  begin
    Result := -1;
    Exit;
  end;
  New(p);
  p.InMulti := InMulti;
  p.resname := lowercase(resname);
  p.restitle := restitle;
  p.restype := restype;
  p.resvalue := resvalue;
  p.resitems := resitems;
  Result := Add(p);
end;

procedure TThreadHandler.CreateThreads;
var
  d: TDownloadThread;
begin
  // if acount = -1 then
  // acount := FThreadCount;

  FFinishQueue := false;
  FFinishThreads := false;
  // FQueue.Clear;
  while Count < FThreadCount do
  begin
    inc(FCount);
    d := TDownloadThread.Create;
    d.CSData := FCSData;
    d.CSFiles := FCSFiles;
    d.FreeOnTerminate := true;
    d.Finish := Finish;
    d.OnTerminate := ThreadTerminate;
    d.HTTP.CookieList := FCookie;
    d.HTTP.PACParser := PACParser;
    d.MaxRetries := Retries;
    d.LogMode := LogMode;
    Add(d);
  end;
end;

function TThreadHandler.Finish(t: TDownloadThread): Integer;
begin
  if t.STOPERROR then
  begin
    if Assigned(FOnError) then
      FOnError(Self, t.Error, nil);
    t.STOPERROR := false;
  end;

  if FFinishThreads then
    Result := THREAD_FINISH
  else if (t.ReturnValue = THREAD_DOAGAIN) or CreateJob(t) then
  begin
    Result := THREAD_START;
    if not Assigned(t.Resource) and Assigned(FOnError) then
      OnError(Self, 'threadhandler: thread.resource = nil', nil);
    SetProxy(t);
  end
  else if FFinishQueue then
    Result := THREAD_FINISH
  else
    Result := THREAD_STOP;
end;

procedure TThreadHandler.FinishQueue;
var
  i: Integer;
  l: TList;
  p: TDownloadThread;

begin
  FFinishQueue := true;
  l := LockList;
  try
    for i := 0 to l.Count - 1 do
    begin
      p := l[i];
      if p.ReturnValue = THREAD_STOP then
        SetEvent(p.EventHandle);
    end;
  finally
    UnlockList;
  end;
end;

procedure TThreadHandler.FinishThreads(Force: Boolean);
var
  i: Integer;
  p: TDownloadThread;
  l: TList;

begin
  if FCount = 0 then
    Exit;

  FFinishThreads := true;
  l := LockList;
  try
    for i := 0 to l.Count - 1 do
    begin
      p := l[i];
      if p.ReturnValue = THREAD_STOP then
        SetEvent(p.EventHandle)
      else
        p.ReturnValue := THREAD_FINISH;
      if Force { and p.HTTP.Connected } then
        p.HTTP.Disconnect;
    end;
  finally
    UnlockList;
  end;
end;

procedure TThreadHandler.ThreadTerminate(ASender: TObject);
begin
  Remove(ASender);
  dec(FCount);
  if (FCount = 0) then
  begin
    FFinishThreads := false;
    if Assigned(FOnAllThreadsFinished) then
      FOnAllThreadsFinished(Self);
  end;
end;

procedure TThreadHandler.SetProxy(t: TDownloadThread);
begin
  if not Assigned(t.Resource) then
    Exit;

  if Proxy.UsePAC and (Proxy.PACHost <> '') then
  begin
    t.HTTP.UsePAC := Proxy.UsePAC;
    Exit;
  end;

  if (t.Resource.ThreadCounter.UseProxy = -1) and (Proxy.UseProxy > 0) or
    (t.Resource.ThreadCounter.UseProxy = 1) or
    (t.Resource.ThreadCounter.UseProxy > 0) and
    (t.Resource.ThreadCounter.UseProxy = Tag) then
    case Proxy.ptype of
      ptHTTP:
        with t.HTTP.ProxyParams do
        begin
          // UseProxy := true;
          t.Socks.Host := '';
          ProxyServer := Proxy.Host;
          ProxyPort := Proxy.Port;
          BasicAuthentication := Proxy.Auth;
          ProxyUserName := Proxy.Login;
          ProxyPassword := Proxy.Password;
        end;
      ptSOCKS4, ptSOCKS5:
        begin
          t.HTTP.ProxyParams.ProxyServer := '';
          t.Socks.Host := Proxy.Host;
          t.Socks.Port := Proxy.Port;

          if Proxy.Auth then
          begin
            t.Socks.Authentication := saUsernamePassword;
            t.Socks.Username := Proxy.Login;
            t.Socks.Password := Proxy.Password;
          end;

          if Proxy.ptype = ptSOCKS4 then
            t.Socks.Version := svSocks4
          else
            t.Socks.Version := svSocks5;
        end;
    end
  else
  begin
    t.HTTP.ProxyParams.ProxyServer := '';
    t.Socks.Host := '';
  end;

end;

procedure TThreadHandler.CheckIdle(ALL: Boolean = false);
var
  l: TList;
  i: Integer;
  p: TDownloadThread;

begin
  l := LockList;
  try
    for i := 0 to l.Count - 1 do
    begin
      p := l[i];
      if p.ReturnValue = THREAD_STOP then
      begin
        p.ReturnValue := THREAD_PROCESS;
        SetEvent(p.EventHandle);
        if not ALL then
          Break;
      end;
    end;
  finally
    UnlockList;
  end;
end;

constructor TThreadHandler.Create;
begin
  inherited;
  FCount := 0;
  // FQueue := TResourceLinkList.Create;
  FFinishThreads := true;
  FOnError := nil;
  FCSData := TCriticalSection.Create;
  FCSFiles := TCriticalSection.Create;
end;

destructor TThreadHandler.Destroy;
begin
  FCSData.Free;
  FCSFiles.Free;
  inherited;
  // FQueue.Free;
  // inherited;
end;

function strFind(Value: string; List: TStringList; var Index: Integer): Boolean;
var
  Hi, Lo: Integer;

begin
  if List.Count = 0 then
  begin
    Result := false;
    index := 0;
    Exit;
  end;

  Hi := List.Count;
  Lo := 0;
  index := Hi div 2;

  try
    while (Hi - Lo) > 0 do
    begin
      if SameText(Value, List[index]) then
        Break
      else if lowercase(Value) < lowercase(List[index]) then
        Hi := index - 1
      else
        Lo := index + 1;

      index := Lo + ((Hi - Lo) div 2);
    end;

    if (index < List.Count) and (Value > List[index]) then
      inc(index);

    Result := (index < List.Count) and SameText(Value, (List[index]));
  except
    on e: Exception do
    begin
      e.Message := e.Message + ' tag(' + List[index] + ') - (' + Value + ')';
      raise;
    end;
  end;
end;

function tagFmt(Spacer, Separator, Isolator: String): TTagTemplate;
begin
  Result.Spacer := Spacer;
  Result.Separator := Separator;
  Result.Isolator := Isolator;
end;

procedure WriteStr(s: String; fStream: tStream);
var
  w: word;
begin
  w := length(s) * SizeOf(Char);
  // fStream.WriteData(w);
  fStream.Write(w, SizeOf(word));
  fStream.Write(s[1], w);
  // fStream.WriteData(0);
end;

function ReadStr(fStream: tStream): String;
var
  w: word;
begin
  // fStream.ReadData(w);
  fStream.Read(w, SizeOf(word));
  SetLength(Result, w div SizeOf(Char));
  if w > 0 then
    fStream.Read(Result[1], w);
end;

procedure WriteVar(s: Variant; fStream: tStream);
var
  VType: word;
  vSize: word;
  vData: Pointer;

begin
  // VarAsType(
  // p := VarArrayLock(s); try
  // w := VarArrayHighBound(s,1) - VarArrayLowBound(s,1) + 1;
  VType := tVarData(s).VType;
  fStream.WriteData(VType);
  case VType of
    varEmpty:
      begin
        vSize := 0;
        vData := nil;
      end;
    varNull:
      begin
        vSize := 0;
        vData := nil;
      end;
    varSmallInt:
      begin
        vSize := SizeOf(SmallInt);
        vData := @tVarData(s).VSmallInt;
      end;
    varInteger:
      begin
        vSize := SizeOf(Integer);
        vData := @tVarData(s).VInteger;
      end;
    varSingle:
      begin
        vSize := SizeOf(Single);
        vData := @tVarData(s).VSingle;
      end;
    varDouble:
      begin
        vSize := SizeOf(Double);
        vData := @tVarData(s).VDouble;
      end;
    varCurrency:
      begin
        vSize := SizeOf(Currency);
        vData := @tVarData(s).VCurrency;
      end;
    varDate:
      begin
        vSize := SizeOf(TDateTime);
        vData := @tVarData(s).VDate;
      end;
    varOleStr:
      begin
        vSize := length(WideString(Pointer(tVarData(s).VOleStr))) *
          SizeOf(WideChar);
        vData := Pointer(tVarData(s).VOleStr);
      end;
    varBoolean:
      begin
        vSize := SizeOf(WordBool);
        vData := @tVarData(s).VBoolean;
      end;
    varShortInt:
      begin
        vSize := SizeOf(shortint);
        vData := @tVarData(s).VShortInt;
      end;
    varByte:
      begin
        vSize := SizeOf(byte);
        vData := @tVarData(s).VByte;
      end;
    varWord:
      begin
        vSize := SizeOf(word);
        vData := @tVarData(s).VWord;
      end;
    varLongWord:
      begin
        vSize := SizeOf(LongWord);
        vData := @tVarData(s).VLongWord;
      end;
    varInt64:
      begin
        vSize := SizeOf(int64);
        vData := @tVarData(s).VInt64;
      end;
    varUInt64:
      begin
        vSize := SizeOf(UInt64);
        vData := @tVarData(s).VUInt64;
      end;
    varString:
      begin
        vSize := length(AnsiString(tVarData(s).VString));
        vData := tVarData(s).VString;
      end;
    varUString:
      begin
        vSize := length(UnicodeString(tVarData(s).VUString)) * SizeOf(WideChar);
        vData := tVarData(s).VUString;
      end;
    varDispatch:
      raise Exception.Create('Type "Dispatch" is not supported');
    varUnknown:
      raise Exception.Create('Type "Unknown" is not supported');
    varAny:
      raise Exception.Create('Type "Any" is not supported');
  else
    raise Exception.Create('Unknown type of data');
  end;

  if (VType = varOleStr) or (VType = varString) or (VType = varUString) then
    fStream.WriteData(vSize);
  fStream.Write(vData^, vSize);
end;

function ReadVar(fStream: tStream): Variant;
var
  w, sz: word;
  v: pVarData;
begin
  // SetVarType(
  // SetLength(s, 0);
  v := @tVarData(Result);
  Result := Unassigned;
  fStream.ReadData(w);
  v.VType := w;
  case w of
    varEmpty:
      ;

    varNull:
      Result := null;

    varSmallInt:
      fStream.ReadData(v.VSmallInt);

    varInteger:
      fStream.ReadData(v.VInteger);

    varSingle:
      fStream.ReadData(v.VSingle);

    varDouble:
      fStream.ReadData(v.VDouble);

    varCurrency:
      fStream.Read(v.VCurrency, SizeOf(Currency));

    varDate:
      fStream.Read(v.VDate, SizeOf(TDateTime));

    varOleStr:
      begin
        fStream.ReadData(sz);
        SetLength(WideString(Pointer(v.VOleStr)), sz div SizeOf(WideChar));
        fStream.Read(v.VOleStr^, sz);
      end;

    varBoolean:
      fStream.Read(v.VBoolean, SizeOf(WordBool));

    varShortInt:
      fStream.ReadData(v.VShortInt);

    varByte:
      fStream.ReadData(v.VByte);

    varWord:
      fStream.ReadData(v.VWord);

    varLongWord:
      fStream.ReadData(v.VLongWord);

    varInt64:
      fStream.ReadData(v.VInt64);

    varUInt64:
      fStream.ReadData(v.VUInt64);

    varString:
      begin
        fStream.ReadData(sz);
        SetLength(AnsiString(v.VString), sz);
        fStream.Read(v.VString^, sz);
      end;

    varUString:
      begin
        fStream.ReadData(sz);
        SetLength(UnicodeString(v.VUString), sz div SizeOf(WideChar));
        fStream.Read(v.VUString^, sz);
      end;

    varDispatch:
      raise Exception.Create('Type "Dispatch" is not supported');

    varUnknown:
      raise Exception.Create('Type "Unknown" is not supported');

    varAny:
      raise Exception.Create('Type "Any" is not supported');
  else
    raise Exception.Create('Unknown type of data');
  end;
end;

initialization

{$IFDEF NEKODEBUG}
  debugpath := ExtractFilePath(paramstr(0)) + 'log\';
CreateDirExt(debugpath);
debugthreads := debugpath + 'threads.txt';
debuggui := debugpath + 'gui.txt';
if fileexists(debugthreads) then
  DeleteFile(debugthreads);
if fileexists(debuggui) then
  DeleteFile(debuggui);
{$ENDIF}

end.
