unit graberU;

interface

uses Classes, Messages, Windows, SysUtils, SyncObjs, Variants, VarUtils,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  MyXMLParser, DateUtils, MyHTTP, StrUtils, md5, DB, IdStack, IdSSLOpenSSL,
  Math;

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
  //CM_UPDATE = WM_USER + 13;
  //CM_UPDATEPROGRESS = WM_USER + 14;
  CM_LANGUAGECHANGED = WM_USER + 15;
  CM_WHATSNEW = WM_USER + 16;
  CM_STYLECHANGED = WM_USER + 17;
  CM_REFRESHRESINFO = WM_USER + 18;
  CM_REFRESHPIC = WM_USER + 19;

  THREAD_STOP = 0;
  THREAD_START = 1;
  THREAD_FINISH = 2;
  THREAD_PROCESS = 3;
  THREAD_COMPLETE = 4;

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

  SAVEFILE_VERSION = 0;

  LIST_SCRIPT = 'listscript';
  DOWNLOAD_SCRIPT = 'dwscript';

type

  TBoolProcedureOfObject = procedure(Value: Boolean = false) of object;
  TLogEvent = procedure(Sender: TObject; Msg: String) of object;

  TProxyRec = record
    UseProxy: Boolean;
    Host: string;
    Port: longint;
    Auth: Boolean;
    Login: string;
    Password: string;
    SavePWD: Boolean;
  end;

  TDownloadRec = record
    ThreadCount: integer;
    UsePerRes: Boolean;
    PerResThreads: integer;
    PicThreads: integer;
    Retries: integer;
    // Interval: integer;
    // BeforeU: boolean;
    // BeforeP: boolean;
    // AfterP: boolean;
    Debug: Boolean;
    SDALF: Boolean;
    AutoUncheckInvisible: boolean;
  end;

  TGUISettings = record
    FormWidth,FormHeight: integer;
    PanelPage: integer;
    PanelWidth: integer;
    FormState: Boolean;
    LastUsedSet: string;
    LastUsedFields: String;
    LastUsedGrouping: String;
  end;

  TSettingsRec = record
    GUI: TGUISettings;
    Proxy: TProxyRec;
    Downl: TDownloadRec;
    //Formats: TFormatRec;
    AutoUPD: boolean;
    UPDServ: String;
    OneInstance: Boolean;
    TrayIcon: Boolean;
    HideToTray: Boolean;
    SaveConfirm: Boolean;
    ShowWhatsNew: boolean;
    UseLookAndFeel: Boolean;
    SkinName: String;
    IsNew: boolean;
  end;

  THTTPMethod = (hmGet, hmPost);

  THTTPRec = record
    DefUrl: String;
    Url: string;
    Referer: string;
    ParseMethod: string;
    JSONItem: String;
    CookieStr: string;
    LoginStr: string;
    LoginPost: string;
    Method: THTTPMethod;
    Counter, Count: integer;
    Theor: Word;
  end;

  { TListValue = class(TObject)
    private
    FName: String;
    FValue: Variant;
    public
    constructor Create;
    property Name: String read FName write FName;
    property Value: Variant read FValue write FValue;
    end; }

  TPicChange = (pcProgress, pcSize, pcLabel, pcDelete, pcChecked);

  TPicChanges = Set of TPicChange;

//  PTagedListValue = ^TTagedListValue;

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
    function Get(Index: integer): TTagedListValue;
    function GetValue(ItemName: String): Pointer;
    procedure SetValue(ItemName: String; Value: Pointer);
    function FindItem(ItemName: String): TTagedListValue;
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    destructor Destroy; override;
    procedure Assign(List: TTagedList; AOperator: TListAssignOp = laCopy);
    constructor Create;
    // procedure Add(ItemName: String; Value: Variant);
    property Items[Index: integer]: TTagedListValue read Get;
    property ItemByName[ItemName: String]: TTagedListValue read FindItem;
    property Values[ItemName: String]: Pointer read GetValue
      write SetValue; default;
    property Count;
    property NoDouble: Boolean read FNodouble write FNodouble;
  end;

  //TListValue

  TListValue = class(TTagedListValue)
    private
      FMy: boolean;
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
    function Get(ItemIndex: integer): TListValue;
    function GetValue(ItemName: String): Variant;
    procedure SetValue(ItemName: String; Value: Variant);
    procedure Assign(List: TValueList; AOperator: TListAssignOp = laCopy);
    function GetLink(ItemName: String): PVariant;
    procedure SetLink(ItemName: String; Value: PVariant);
  public
    property Items[ItemIndex: Integer]: TListValue read Get;
    property Values[ItemName: String]: Variant read GetValue write SetValue; default;
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
    function FindPosition(Value: Variant; var i: integer): boolean;
    function Add(Value: Variant; Pos: integer): PVariant;
    property ValueType: DB.TFieldType read FType write SetValueType;
    property VariantType: TVarType read FVariantType;
  end;



  { TPictureValueState = (pvsNone, pvsKey, pvsNoduble);

    TPictureValue = class(TListValue)
    private
    FState: TPictureValueState;
    public
    constructor Create;
    property State: TPictureValueState read FState write FState;
    end;

    TPictureValueList = class(TValueList)
    protected
    function Get(Index: integer): TPictureValue;
    procedure SetValue(ItemName: String; Value: Variant); override;
    function FindItem(ItemName: String): TPictureValue;
    function GetState(ItemName: String): TPictureValueState;
    procedure SetState(ItemName: String; Value: TPictureValueState);
    public
    property Items[Index: integer]: TPictureValue read Get;
    property ItemByName[ItemName: String]: TPictureValue read FindItem;
    property State[ItemName: String]: TPictureValueState read GetState
    write SetState;
    end; }

  TScriptSection = class;
  TScriptItemList = class;

  TScriptItemKind = (sikNone,sikProcedure,sikDecloration,sikSection,sikCondition,sikGroup);

  TScriptEvent = function(const Item: TScriptSection; const Parametres: TValueList;
    var LinkedObj: TObject): boolean of object;

  TValueEvent = procedure(ItemName: String;
    var Result: Variant; var LinkedObj: TObject) of object;

  TDeclorationEvent = procedure(ItemName: String;
    ItemValue: Variant; LinkedObj: TObject)
    of object;

  TFinishEvent = procedure(const Item: TScriptSection; LinkedObj: TObject) of object;


  TScriptItem = class(TObject)
  private
    FName: String;
    FValue: Variant;
    FKind: TScriptItemKind;
  public
    procedure Assign(s: TScriptItem); virtual;
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
    function Get(Index: integer): PWorkItem;
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    function Add(Section: TScriptSection; Obj: TObject): integer;
    property Items[Index: integer]: PWorkItem read Get;
  end;

  TScriptSection = class(TScriptItem)
  private
    //FParent: String;
    FParametres: TValueList;
    //FDeclorations: TValueList;
    //FConditions: TScriptSectionList;
    FChildSections: TScriptItemList;
    FNoParam: Boolean;
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
    property Parameters: TValueList read FParametres;
    //property Conditions: TScriptSectionList read FConditions;
    //property Declorations: TValueList read FDeclorations;
    property ChildSections: TScriptItemList read FChildSections;
    property NoParameters: Boolean read FNoParam write FNoParam;
  end;

  TScriptItemList = class(TList)
  private
    function Get(Index: integer): TScriptItem;
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    procedure Assign(s: TScriptItemList);
    property Items[Index: integer]: TScriptItem read Get; default;
  end;

  TDownloadThread = class;
  TResourceLinkList = class;
  TResource = class;
  TTPicture = class;
  TPictureLinkList = class;
  TPictureList = class;
  // TResource = class;

  TFieldType = (ftNone, ftString, ftPassword, ftNumber, ftFloatNumber,
    ftCombo, ftCheck, ftPathText);

  PResourceField = ^TResourceField;

  TResourceField = record
    resname: string;
    restitle: string;
    restype: TFieldType;
    resvalue: Variant;
    resitems: string;
  end;

  TResourceFields = class(TList)
  protected
    function Get(Index: integer): PResourceField;
    // procedure Put(Index: integer; Value: TResourceField);
    function GetValue(ItemName: String): Variant;
    procedure SetValue(ItemName: String; Value: Variant);
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    procedure Assign(List: TResourceFields; AOperator: TListAssignOp = laCopy);
    function AddField(resname: string; restitle: string;
      restype: TFieldType; resvalue: Variant; resitems: String): integer;
    function FindField(resname: String): integer;
    property Items[Index: integer]: PResourceField read Get { write Put };
    property Values[ItemName: String]: Variant read GetValue
      write SetValue; default;
  end;

  TThreadEvent = function(t: TDownloadThread): integer of object;

  TDownloadThread = class(TThread)
  private
    FHTTP: TMyIdHTTP;
    FEventHandle: THandle;
    FSSLHandler: TIdSSLIOHandlerSocketOpenSSL;
    FJob: integer;
    // FThreadJob: integer;
    FJobComplete: TThreadEvent;
    FFinish: TThreadEvent;
    FErrorString: String;
    // FErrorCode: integer;
    FInitialScript: TScriptSection;
    FBeforeScript: TScriptSection;
    FAfterScript: TScriptSection;
    FXMLScript: TScriptSection;
    FFields: TResourceFields;
    FDownloadRec: TDownloadRec;
    FHTTPRec: THTTPRec;
    // FPictureList: TPictureList;
    FPicList: TPictureList;
    FLPicList: TPictureList;
    FSectors: TValueList;
    FXML: TMyXMLParser;
    FPicture: TTPicture;
    FLnkPic: TTPicture;
    FSTOPERROR: Boolean;
    FJobId: integer;
    FCSData: TCriticalSection;
    FCSFiles: TCriticalSection;
    FResource: TResource;
    FMaxRetries: Integer;
    FRetries: integer;
    FPicsAdded: boolean;
    // FPicLink: TTPicture;
    // FTagList: TStringList;
    // FPicList: TList;
    // FAddPic: Boolean;
    // FCookie: TCookieList;
  protected
    procedure SetInitialScript(Value: TScriptSection);
    procedure SetBeforeScript(Value: TScriptSection);
    procedure SetAfterScript(Value: TScriptSection);
    procedure SetXMLScript(Value: TScriptSection);
    procedure SeFields(Value: TResourceFields);
    procedure DoJobComplete;
    procedure DoFinish;
    function SE(const Item: TScriptSection; const Parametres: TValueList;
      var LinkedObj: TObject): boolean;
    procedure VE(Value: String; var Result: Variant;
      var LinkedObj: TObject);
    procedure DE(ItemName: String; ItemValue: Variant; LinkedObj: TObject);
    procedure FE(const Item: TScriptSection; LinkedObj: TObject);
    procedure IdHTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure IdHTTPWork(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure PicChanged;
    procedure ProcHTTP;
    procedure ProcPic;
    procedure ProcLogin;
  public
    procedure Execute; override;
    constructor Create;
    destructor Destroy; override;
    procedure AddPicture;
    procedure ClonePicture;
    procedure SetSectors(Value: TValueList);
    procedure LockList;
    procedure UnlockList;
    procedure SetHTTPError(s: string);
    property HTTP: TMyIdHTTP read FHTTP;
    property Job: integer read FJob write FJob;
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
    property Fields: TResourceFields read FFields write SeFields;
    property DownloadRec: TDownloadRec read FDownloadRec write FDownloadRec;
    property HTTPRec: THTTPRec read FHTTPRec write FHTTPRec;
    property JobComplete: TThreadEvent read FJobComplete write FJobComplete;
    property Sectors: TValueList read FSectors write SetSectors;
    property PictureList: TPictureList read FPicList { write FPictureList };
    property LPictureList: TPictureList read FLPicLIst write FLPicList;
    property STOPERROR: Boolean read FSTOPERROR write FSTOPERROR;
    property JobId: integer read FJobId write FJobId;
    property Picture: TTPicture read FPicture write FPicture;
    property LnkPic: TTPicture read FLnkPic write FLnkPic;
    property CSData: TCriticalSection read FCSData write FCSData;
    property CSFiles: TCriticalSection read FCSFiles write FCSFiles;
    property Resource: TResource read FResource write FResource;
    property MaxRetries: integer read FMaxRetries write FMaxRetries;
    property PicsAdded: boolean read FPicsAdded;
  end;

  TJobEvent = function(t: TDownloadThread): Boolean of object;

  TThreadHandler = class(TThreadList)
  private
    // FQueue: TResourceLinkList;
    FCount: integer;
    FFinishThreads: Boolean;
    FFinishQueue: Boolean;
    FCreateJob: TJobEvent;
    FProxy: TProxyRec;
    FCookie: TMyCookieList;
    FOnAllThreadsFinished: TNotifyEvent;
    FOnError: TLogEvent;
    FThreadCount: integer;
    FCSData: TCriticalSection;
    FCSFiles: TCriticalSection;
    FRetries: Integer;
  protected
    function Finish(t: TDownloadThread): integer;
    procedure CheckIdle(ALL: Boolean = false);
    // procedure AddToQueue(R: TResource);
    procedure ThreadTerminate(ASender: TObject);
  public
    procedure CreateThreads(acount: integer = -1);
    procedure FinishThreads(Force: Boolean = false);
    constructor Create;
    destructor Destroy; override;
    procedure FinishQueue;
    property CreateJob: TJobEvent read FCreateJob write FCreateJob;
    property Count: integer read FCount;
    property Proxy: TProxyRec read FProxy write FProxy;
    property Cookies: TMyCookieList read FCookie write FCookie;
    property OnAllThreadsFinished: TNotifyEvent read FOnAllThreadsFinished
      write FOnAllThreadsFinished;
    property OnError: TLogEvent read FOnError write FOnError;
    property ThreadCount: integer read FThreadCount write FThreadCount;
    property Retries: integer read FRetries write FRetries;
    // property FinishThreads: boolean read FFinishThread;
  end;

  TTagAttribute = (taNone, taArtist, taCharacter, taCopyright, taAmbiguous);

  TPictureTag = class(TObject)
  private
    FLinked: TPictureLinkList;
    FTag: Integer;
  public
    Attribute: TTagAttribute;
    Name: String;
    constructor Create;
    destructor Destroy; override;
    property Linked: TPictureLinkList read FLinked;
    property Tag: Integer read FTag write FTag;
  end;

  TPictureTagLinkList = class(TList)
  protected
    function FindPosition(Value: String; var index: integer): boolean;
    function Get(Index: integer): TPictureTag;
    procedure Put(Index: integer; Item: TPictureTag);
  public
    property Items[Index: integer]: TPictureTag read Get write Put; default;
    property Count;
    function AsString(cnt: integer = 0): String;
  end;

  TTagUpdateEvent = procedure(Sender: TObject; TagList: TPictureTagLinkList) of object;

  TPictureTagList = class(TPictureTagLinkList)
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(TagName: String; p: TTPicture): Integer;
    function Find(TagName: String): integer;
    procedure ClearZeros;
    property Items;
    property Count;
  end;

  TPictureEvent = procedure(APicture: TTPicture) of object;
  // TResourcePictureEvent = procedure (AResource: TResource; APicture: TTPicture) of object;
  TPictureNotifyEvent = procedure(Sender: TObject; APicture: TTPicture) of object;

  TPicChangeEvent = procedure(APicture: TTPicture; Changes: TPicChanges)
    of object;

  TTPicture = class(TObject)
  private
    FParent: TTPicture;
    FMeta: TValueList;
    FLinked: TPictureLinkList;
    FTags: TPictureTagLinkList;
    FChecked: Boolean;
    FStatus: integer;
    FRemoved: Boolean;
    FQueueN: integer;
    FList: TPictureList;
    FResource: TResource;
    FDisplayLabel: String;
    FPicName: String;
    FFileName: String;
    FExt: String;
    FMD5: TMD5Digest;
    //FOrig: TTPicture;
    FSize: Int64;
    FPos: Int64;
    FPicChange: TPicChangeEvent;
    FChanges: TPicChanges;
    FBookMark: integer;
    function GetMD5String: string;
//    FStatus: Integer;
    // FObj: TObject;
  protected
    procedure SetParent(Item: TTPicture);
    procedure SetRemoved(Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Assign(Value: TTPicture; Links: Boolean = false);
    //procedure MakeFileName(Format: String);
    procedure SetPicName(Value: String);
    property Removed: Boolean read FRemoved write SetRemoved;
    property Status: integer read FStatus write FStatus;
    property Checked: Boolean read FChecked write FChecked;
    property Parent: TTPicture read FParent write SetParent;
    property Tags: TPictureTagLinkList read FTags;
    property Meta: TValueList read FMeta;
    property Linked: TPictureLinkList read FLinked;
    property QueueN: integer read FQueueN write FQueueN;
    property List: TPictureList read FList write FList;
    property DisplayLabel: String read FDisplayLabel write FDisplayLabel;
    property FileName: String read FFileName write FFileName;
    property Ext: String read FExt;
    property md5: TMD5Digest read FMD5;
    property MD5String: String read GetMD5String;
    property PicName: String read FPicName write SetPicName;
    //property Orig: TTPicture read FOrig write FOrig;
    property Resource: TResource read FResource write FResource;
    property Size: Int64 read FSize write FSize;
    property Pos: Int64 read FPos write FPos;
    property OnPicChanged: TPicChangeEvent read FPicChange write FPicChange;
    property Changes: TPicChanges read FChanges write FChanges;
    property BookMark: Integer read FBookMark write FBookMark;
    // property Obj: TObject read FObj write FObj;
  end;

  TPicCounter = record
    OK,ERR,SKP,UNCH,IGN,EXS,FSH: Word;
  end;

  TPictureLinkList = class(TList)
  private
    FBeforePictureList: TNotifyEvent;
    FAfterPictureList: TNotifyEvent;
    FLinkedOn: TPictureList;
    FFinishCursor: integer;
    FCursor: integer;
    FPicCounter: TPicCounter;
    //FResource: TResource;
  protected
    function Get(Index: integer): TTPicture;
    procedure Put(Index: integer; Item: TTPicture);
  public
    procedure BeginAddList;
    procedure EndAddList;
    procedure ResetCursors;
    procedure ResetPicCounter;
    procedure CheckExists;
    property Items[Index: integer]: TTPicture read Get write Put; default;
    property OnBeginAddList: TNotifyEvent read FBeforePictureList
      write FBeforePictureList;
    property OnEndAddList: TNotifyEvent read FAfterPictureList
      write FAfterPictureList;
    property Link: TPictureList read FLinkedOn write FLinkedOn;
    function AllFinished(incerrs: Boolean = true): Boolean;
    function NextJob(Status: integer): TTPicture;
    function eol: Boolean;
    procedure Reset;
    property Cursor: integer read FCursor;
    property PicCounter: TPicCounter read FPicCounter;
  end;

  TDoubleString = array [0 .. 1] of String;

  TDSArray = array of TDoubleString;

  TCheckFunction = function(Pic: TTPicture): Boolean of object;
  TSameNamesEvent = procedure(Sender: TObject; FFileName: String);

  TPictureList = class(TPictureLinkList)
  private
    FTags: TPictureTagList;
    //FOnAddPicture: TPictureEvent;
    //FCheckDouble: TCheckFunction;
    FNameFormat: String;
    FPicChange: TPicChangeEvent;
    FMetaContainer: TTagedList;
    FIgnoreList: TDSArray;
    FParentsCount,FChildsCount: integer;
    FDoublesTickCount: integer;
    FDirList: TStringList;
    FFileNames: TStringList;
    FMakeNames: Boolean;
    FSameNames: TSameNamesEvent;
    function DirNumber(Dir: String): word;
    procedure disposeDirList;
    procedure SetPicChange(Value: TPicChangeEvent);
    function fNameNumber(FileName: String): word;
    procedure AddfName(FileName: String);
  protected
    procedure DeallocateMeta;
    procedure AddPicMeta(pic: TTPicture; MetaName: String; MetaValue: Variant);
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
    property Link;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(APicture: TTPicture; Resource: TResource): integer;
    procedure AddPicList(APicList: TPictureList);
    function CopyPicture(Pic: TTPicture; Child: boolean = false): TTPicture;
    function CheckDoubles(pic: TTPicture): boolean;
//    function MakeFileName(index: integer): string;
    procedure MakePicFileName(index: integer; Format: String);
//    function TrackPos(Value: integer): integer;
    property Tags: TPictureTagList read FTags;
    property Items;
    property Count;
    //property Resource;
    //property OnAddPicture: TPictureEvent read FOnAddPicture write FOnAddPicture;
    //property CheckDouble: TCheckFunction read FCheckDouble write FCheckDouble;
    property NameFormat: String read FNameFormat write FNameFormat;
    procedure Clear; override;
    property OnPicChanged: TPicChangeEvent read FPicChange write SetPicChange;
    property OnSameFileNames: TSameNamesEvent read FSameNames write FSameNames;
    property IgnoreList: TDSArray read FIgnoreList write FIgnoreList;
    property Meta: TTagedList read FMetaContainer;
    property ParensCount: integer read FParentsCount;
    property ChildsCount: integer read FChildsCount;
    property DoublestickCount: integer read FDoublesTickCount;
    property MakeNames: Boolean read FMakeNames write FMakeNames;
  end;

  TResourceEvent = procedure(R: TResource) of object;

  TJobRec = record
    id: integer;
    Url: string;
    kind: integer;
    Status: integer;
  end;

  PJobRec = ^TJobRec;

  TJobList = class(TList)
  private
    FLastAdded: PJobRec;
    FCursor: integer;
    FFinishCursor: integer;
    FOkCount: integer;
    FErrCount: Integer;
  protected
    function Get(Value: integer): PJobRec;
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    function Add(id, kind: integer): integer;
    function AllFinished(incerrs: Boolean = true): Boolean;
    function NextJob(Status: integer): integer;
    function eol: Boolean;
    property Items[Index: integer]: PJobRec read Get; default;
    procedure Reset;
    procedure Clear; override;
    property Cursor: integer read FCursor;
    property FinishCursor: integer read FFinishCursor;
    property ErrorCount: integer read FErrCount;
    property OkCount: integer read FOkCount;
  end;

  TResource = class(TObject)
  private
    FFileName: String;
    FResName: String;
    // FURL: String;
    FIconFile: String;
    FShort: String;
    FNameFormat: String;
    FRelogin: boolean;
    FParent: TResource;
    FLoginPrompt: Boolean;
    FInherit: Boolean;
    FJobInitiated: Boolean;
    FFields: TResourceFields;
    FSectors: TValueList;
    FInitialScript: TScriptSection;
    FBeforeScript: TScriptSection;
    FAfterScript: TScriptSection;
    FXMLScript: TScriptSection;
    FPicScript: TScriptSection;
    FDownloadSet: TDownloadRec;
    FPictureList: TPictureLinkList;
    FHTTPRec: THTTPRec;
    // FAddToQueue: TResourceEvent;
    FOnJobFinished: TResourceEvent;
    FOnPicJobFinished: TResourceEvent;
    // FJobFinished: boolean;
    FPicFieldList: TStringList;
    FCheckIdle: TBoolProcedureOfObject;
    FNextPage: Boolean;
    FOnError: TLogEvent;
    FMaxThreadCount: integer;
    FCurrThreadCount: integer;
    FPictureThreadCount: integer;
    FJobList: TJobList;
    FOnPageComplete: TNotifyEvent;
    { FPerPageMode: Boolean; }
  protected
    procedure DeclorationEvent(ItemName: String; ItemValue: Variant; LinkedObj: TObject);
    function JobComplete(t: TDownloadThread): integer;
    function StringFromFile(fname: string): string;
    function PicJobComplete(t: TDownloadThread): integer;
    function LoginJobComplete(t: TDownloadThread): integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(fname: String);
    function CreateFullFieldList: TStringList;
    procedure CreateJob(t: TDownloadThread);
    procedure StartJob(JobType: integer);
    procedure Assign(R: TResource);
    procedure GetSectors(s: string; R: TValueList);
    function CanAddThread: Boolean;
    procedure CreatePicJob(t: TDownloadThread);
    procedure CreateLoginJob(t: tDownloadThread);
    property FileName: String read FFileName;
    property Name: String read FResName write FResName;
    // property Url: String read FURL;
    property Relogin: boolean read FRelogin write FRelogin;
    property IconFile: String read FIconFile;
    property Fields: TResourceFields read FFields;
    property Parent: TResource read FParent write FParent;
    property Inherit: Boolean read FInherit write FInherit;
    property NameFormat: String read FNameFormat write FNameFormat;
    property Sectors: TValueList read FSectors;
    property LoginPrompt: Boolean read FLoginPrompt;
    property DownloadSet: TDownloadRec read FDownloadSet write FDownloadSet;
    property HTTPRec: THTTPRec read FHTTPRec write FHTTPRec;
    property PictureList: TPictureLinkList read FPictureList;
    property JobInitiated: Boolean read FJobInitiated;
    property InitialScript: TScriptSection read FInitialScript;
    property BeforeScript: TScriptSection read FBeforeScript;
    property AfterScript: TScriptSection read FBeforeScript;
    property XMLScript: TScriptSection read FXMLScript;
    // property AddToQueue: TResourceEvent read FAddToQueue write FAddToQueue;
    // property JobFinished: boolean read FJobFinished;
    property OnJobFinished: TResourceEvent read FOnJobFinished
      write FOnJobFinished;
    property OnPicJobFinished: TResourceEvent read FOnPicJobFinished
      write FOnPicJobFinished;
    property PicFieldList: TStringList read FPicFieldList;
    property CheckIdle: TBoolProcedureOfObject read FCheckIdle write FCheckIdle;
    property NextPage: Boolean read FNextPage write FNextPage;
    property OnError: TLogEvent read FOnError write FOnError;
    property CurrThreadCount: integer read FCurrThreadCount;
    property MaxThreadCount: integer read FMaxThreadCount write FMaxThreadCount;
    property PicThreadCount: integer read FPictureThreadCount;
    property JobList: TJobList read FJobList;
    property Short: String read FShort;
    property OnPageComplete: TNotifyEvent read FOnPageComplete write FOnPageComplete;
  end;

  TResourceLinkList = class(TList)
  protected
    function Get(Index: integer): TResource;
  public
    procedure GetAllResourceFields(List: TStrings);
    procedure GetAllPictureFields(List: TStrings; withparam: boolean = false);
    property Items[Index: integer]: TResource read Get; default;
  end;

  TActionNotifyEvent = procedure(Sender: TObject; Action: integer) of object;

  TResourceList = class(TResourceLinkList)
  private
    FThreadHandler: TThreadHandler;
    FDwnldHandler: TThreadHandler;
    //FOnAddPicture: TPictureEvent;
    FJobChanged: TActionNotifyEvent;
    // FOnEndJob: TActionNotifyEvent;
    //FOnBeginPicList: TNotifyEvent;
    //FOnEndPicList: TNotifyEvent;
    FQueueIndex: integer;
    FPicQueue: integer;
    FPageMode: Boolean;
    FLoginMode: Boolean;
    // FFinished: Boolean;
    // FOnLog: TLogEvent;
    FOnError: TLogEvent;
    FMaxThreadCount: integer;
    //FIgnoreList: TDSArray;
    FListFileFormat: String;
    //FPicChanged: TPicChangeEvent;
    FPictureList: TPictureList;
    // FPicFileFormat: String;
    // procedure SetPicFileFormat(Value: String);
    FOnResPageComplete: TNotifyEvent;
    FStopTick: DWORD;
    FStopPicsTick: DWORD;
    FCanceled: Boolean;
    procedure SetOnError(Value: TLogEvent);
    function GetPicsFinished: Boolean;
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
    procedure JobFinished(R: TResource);
    procedure PicJobFinished(R: TResource);
    //procedure AddToQueue(R: TResource);
    //procedure SetOnPictureAdd(Value: TPictureEvent);
    procedure OnHandlerFinished(Sender: TObject);
    function CreateJob(t: TDownloadThread): Boolean;
    function GetListFinished: Boolean;
    //function CheckDouble(Pic: TTPicture; x,y: integer): Boolean;
    function CreateDWNLDJob(t: TDownloadThread): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure StartJob(JobType: integer);
    procedure CopyResource(R: TResource);
    procedure CreatePicFields;
    procedure NextPage;
    procedure SetPageMode(Value: Boolean);
    procedure SetMaxThreadCount(Value: integer);
    function AllFinished: Boolean;
    function AllPicsFinished: Boolean;
    procedure UncheckDoubles;
    property ThreadHandler: TThreadHandler read FThreadHandler;
    property DWNLDHandler: TThreadHandler read FDwnldHandler;
    procedure LoadList(Dir: String);
{    property OnAddPicture: TPictureEvent read FOnAddPicture
      write SetOnPictureAdd; }
    property OnJobChanged: TActionNotifyEvent read FJobChanged
      write FJobChanged;
    //property OnEndJob: TNotifyEvent read FOnEndJob write FOnEndJob;
{    property OnBeginPicList: TNotifyEvent read FOnBeginPicList
      write FOnBeginPicList;
    property OnEndPicList: TNotifyEvent read FOnEndPicList write FOnEndPicList;
    property PageMode: Boolean read FPageMode write SetPageMode;    }
    property ListFinished: Boolean read GetListFinished;
    property PicsFinished: Boolean read GetPicsFinished;
    //property OnLog: TLogEvent read FOnLog write FOnLog;
    property OnError: TLogEvent read FOnError write SetOnError;
    property MaxThreadCount: integer read FMaxThreadCount
      write SetMaxThreadCount;
    //property PicIgnoreList: TDSArray read FIgnoreList write FIgnoreList;
    property ListFileForamt: String read FListFileFormat write FListFileFormat;
    //property PicFileFormat: String read FPicFileFormat write SetPicFileFormat;
    //property OnPicChanged: TPicChangeEvent read FPicChanged write FPicChanged;
    property PictureList: TPictureList read FPictureList;
    property OnPageComplete: TNotifyEvent read FOnResPageComplete write FOnResPageComplete;
    property Canceled: Boolean read FCanceled write FCanceled;
  end;

function strFind(Value: string; list: TStringList; var index: integer): boolean;

implementation

uses LangString, common;

{$IFDEF NEKODEBUG}
var
  debugpath: string;
  debugthreads: string;
{$ENDIF}

function CalcValue(s: variant; VE: TValueEvent; Lnk: TObject;
  NoMath: Boolean = false): Variant;

  function doubles(s: string; ch: Char): string;
  var
    i: integer;
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
  op = ['(', ')', '+', '-', '<', '>', '=', '!', '*' , '/', '\', '&', ',', '?', '~',
    '|', ' ', #9, #13, #10];
  p = ['$', '#', '@'];
  isl: array [0 .. 1] of string = ('""', '''''');
var
  n1, n2: integer;
  cstr: string;
  rstr: Variant;
  vt: WideString;
  vt2: Double;
  VRESULT: HRESULT;
  tmp: integer;
  rsv: variant;
  b: boolean;

begin
  rsv := s;
  if Assigned(VE) then
  begin
    n1 := CharPos(s, ';', isl,[]);

    while n1 > 0 do
    begin
      n2 := CharPos(s, #13, [], [], n1 + 1);
      if n2 = 0 then
        raise Exception.Create(Format(lang('_SCRIPT_READ_ERROR_'),
          [lang('_INCORRECT_DECLORATION_') + '''' + s + '''']));
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
          n2 := CharPosEx(s, op, [], [], n1 + 1)
        else
          n2 := CharPosEx(s, op - ['('], [], ['()'], n1 + 1);
      end
      else
        n2 := CharPosEx(s, op, [], [], n1 + 1);

      if n2 = 0 then
        cstr := Copy(s, n1, length(s) - n1 + 1)
      else
        cstr := Copy(s, n1, n2 - n1);

      rstr := null;
      // end;
      VE(cstr, rstr, Lnk);

      tmp := VarType(rstr);

      if (rstr <> null) and (s = VarToStr(s)[n1] + cstr) and not
      ((tmp = varOleStr) or (tmp = varString) or (tmp = varUString)) then
      begin
        result := rstr;
        Exit;
      end else if rstr = null then
        rstr := '""'
      else
      begin
        b := (pos('(',trim(rstr)) = 1);
        if ((tmp = varOleStr) or (tmp = varString) or (tmp = varUString)) then
        begin
          vt := VarToWideStr(rstr);
          VRESULT := VarR8FromStr(vt, VAR_LOCALE_USER_DEFAULT, 0, vt2);
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

      //cstr := VarToStr(s)[n1] + cstr;
      s := StringReplace(s, cstr, rstr, [rfReplaceAll]);

      //n2 := n1 + length(rstr) - 1;
      n2 := 0;
    end;
  end;

  if NoMath then
    Result := s
  else
    try
      Result := MathCalcStr(s);
    except on e: exception do
      raise Exception.Create('Error when calculating string ('
        + VarToStr(rsv) + '): ' + e.Message);
    end;
end;

function gVal(Value: string): string;
begin
  Result := TrimEx(CopyFromTo(Value, '(', ')',['""'],['()']),[#9, #10, #13, ' ']);
end;

function nVal(var Value: string; sep: char = ','): string;
begin
  Result := TrimEx(CopyTo(Value,sep,['""'],['()'],true),[#9, #10, #13, ' ']);
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
begin
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

function TTagedList.Get(Index: integer): TTagedListValue;
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
      //New(p);
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
    //New(p);
    p := TTagedListValue.Create;
    p.Name := ItemName;
    p.Value := Value;
    inherited Add(p);
  end;
end;

function TTagedList.FindItem(ItemName: String): TTagedListValue;
var
  i: integer;
begin
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
  i: integer;
  p: TTagedListValue;
begin
  case AOperator of
    laCopy:
      begin
        Clear;
        Capacity := List.Capacity;
        for i := 0 to List.Count - 1 do
        begin
          //New(p);
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

//TListValue

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

//TValueList

function TValueList.Get(ItemIndex: integer): TListValue;
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
      //New(p);
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
    //New(p);
    p := TListValue.Create;
    p.Name := ItemName;
    p.Value := Value;
    inherited Add(p);
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
      //New(p);
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
    //New(p);
    p := TListValue.Create;
    p.Name := ItemName;
    p.ValueLink := Value;
    inherited Add(p);
  end;
end;

procedure TValueList.Assign(List: TValueList; AOperator: TListAssignOp);
var
  i: integer;
  p: TListValue;
begin
{  if not Assigned(List) then
    Exit;                       }

  case AOperator of
    laCopy:
      begin
        Clear;
        FNoDouble := List.NoDouble;
        Capacity := List.Capacity;
        for i := 0 to List.Count - 1 do
        begin
          //New(p);
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
        FNoDouble := FNoDouble and List.NoDouble;
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

//TMetaList

procedure TMetaList.SetValueType(Value: DB.TFieldType);
begin
  FType := Value;
  case FType of
    ftInteger: FVariantType := varInteger;
    ftLargeInt: FVariantType := varInt64;
    ftBoolean: FVariantType := varBoolean;
    DB.ftString: FVariantType := varUString;
    ftDateTime: FVariantType := varDate;
    ftFloat: FVariantType := varDouble;
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

function TMetaList.FindPosition(Value: Variant; var i: integer): boolean;
var
  Hi,Lo: integer;

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
    Value := VarAsType(Value,FVariantType);
  except
    on e: exception do
      raise Exception.Create('"' + Value + '" - ' + e.Message);

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

      Result := (i < Count) and VarSameValue(Value,PVariant(Items[i])^);
  except
    on e: exception do
      raise Exception.Create(e.Message + ' (' + VarToStr(PVariant(Items[i])^) + ') - ('
                           + VarToStr(Value) + ')');
  end;
end;

function TMetaList.Add(Value: Variant; Pos: integer): PVariant;
var
  p: PVariant;

begin
  New(p);
  if (FVariantType <> varUString) and (VarToStr(Value) = '') then
    Value := 0;
  p^ := VarAsType(Value,FVariantType);
  Insert(Pos,p);
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

//TWorkList

function TWorkList.Get(Index: integer): PWorkItem;

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

function TWorkList.Add(Section: TScriptSection; Obj: TObject): integer;
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

// TScriptSection

constructor TScriptSection.Create;
begin
  inherited;
  FName := '';
  FParametres := TValueList.Create;
  FParametres.NoDouble := false;
  //FDeclorations := TValueList.Create;
  //FDeclorations.NoDouble := false;
  //FConditions := TScriptSectionList.Create;
  FChildSections := TScriptItemList.Create;
  FNoParam := false;
end;

destructor TScriptSection.Destroy;
begin
  FParametres.Free;
  //FDeclorations.Free;
  //FConditions.Free;
  FChildSections.Free;
  inherited;
end;

function TScriptSection.Empty: Boolean;
begin
  Result := //(Declorations.Count > 0) or (Conditions.Count > 0) or
    (ChildSections.Count = 0);
end;

procedure TScriptSection.ParseValues(s: string);

const
  EmptyS = [#9, #10, #13, ' '];

  isl: array [0 .. 1] of string = ('''''', '""');
  brk: array [0 .. 1] of string = ('()', '{}');
  Cons = ['=', '<', '>', '!'];

var
  i, l, n, p { ,tmpi1,tmpi2 } : integer;
  v1, v2, tmp: string;
  Child: TScriptSection;
  ChItem: TScriptItem;
  newstring: Boolean;

begin
  //FConditions.Clear;
  //FDeclorations.Clear;
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
      '^':
        begin
          newstring := false;
          n := CharPos(s, '{', isl, brk, i + 1);

          if n = 0 then
{            raise Exception.Create(Format(lang('_SCRIPT_READ_ERROR_'),
              [Format(lang('_INCORRECT_DECLORATION_'), [IntToStr(i)])]));}
            raise Exception.Create('Script read error: '
               + 'Can''t find { after ' + Copy(s,i,15));

          tmp := TrimEx(Copy(s, i + 1, n - i - 1), EmptyS);

          Child := TScriptSection.Create;
          Child.Name := Trim(GetNextS(tmp, '#'),'^');
          if Child.Name = '' then
            Child.Kind := sikGroup
          else
          begin
            Child.Kind := sikSection;
            if Child.Name[length(Child.Name)] = '!' then
            begin
              Child.NoParameters := true;
              Child.Name := Copy(Child.Name,1,length(Child.Name)-1);
            end;
          end;
          while tmp <> '' do
          begin
            v1 := GetNextS(tmp, '#');
            p := CheckStrPos(v1, Cons, true);
            if p > 0 then
              v2 := TrimEx(Copy(v1, 1, p-1), EmptyS);

            if v2 <> '' then
              if p = 0 then
                Child.Parameters[v2] := ''
              else
                Child.Parameters[v2] :=
                  TrimEx(Copy(v1, p + 1, length(v1) - p), EmptyS);
          end;

          i := n + 1;

          n := CharPos(s, '}', isl, brk, i);

          if n = 0 then
          begin
            Child.Free;
            raise Exception.Create('Script read error: '
               + 'Can''t find } after ' + Copy(s,i,15));
          end;

          Child.ParseValues(Copy(s, i, n - i));
          FChildSections.Add(Child);

          i := n + 1;
        end;
      '?':
        begin
          n := CharPos(s, '{', isl, brk, i + 1);

          if n = 0 then
{            raise Exception.Create(Format(lang('_SCRIPT_READ_ERROR_'),
              [Format(lang('_INCORRECT_DECLORATION_'), [IntToStr(i)])])); }
            raise Exception.Create('Script read error: '
               + 'Can''t find { after ' + Copy(s,i,15));              

          tmp := TrimEx(Copy(s, i + 1, n - i -1), EmptyS);

          Child := TScriptSection.Create;
          //Child.Parent := Parent;
          Child.Kind := sikCondition;
          Child.Parameters.Assign(Parameters);
          Child.Name := tmp;

          i := n + 1;

          n := CharPos(s, '}', isl, brk, i);

          if n = 0 then
          begin
            Child.Free;
{            raise Exception.Create(Format(lang('_SCRIPT_READ_ERROR_'),
              [Format(lang('_INCORRECT_DECLORATION_'), [IntToStr(i)])])); }
            raise Exception.Create('Script read error: '
               + 'Can''t find } after ' + Copy(s,i,15));               
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
{          raise Exception.Create(Format(lang('_SCRIPT_READ_ERROR_'),
            [Format(lang('_INCORRECT_DECLORATION_'), [IntToStr(i)])]));  }
            raise Exception.Create('Script read error: '
               + 'Can''t find ; after ' + Copy(s,i,15)); 
        // v2 := v2;

        v1 := TrimEx(Copy(s, i, n - i), EmptyS);

        i := n + 1;

        n := CharPos(v1, '=', isl, brk);

        if n = 1 then
{          raise Exception.Create(Format(lang('_SCRIPT_READ_ERROR_'),
            [lang('_INCORRECT_DECLORATION_') + IntToStr(i)]));  }
            raise Exception.Create('Script read error: '
               + 'Incorrect decloration near ' + Copy(s,i,15));

        if n > 0 then
        begin
          v2 := TrimEx(Copy(v1, 1, n - 1), EmptyS);
          v1 := DeleteEx(v1, 1, n);
        end
        else
        begin
          v2 := CopyTo(v1, '(');

          if v2 = '' then
{            raise Exception.Create(Format(lang('_SCRIPT_READ_ERROR_'),
              [lang('_INCORRECT_DECLORATION_') + IntToStr(i)]))     }
            raise Exception.Create('Script read error: '
               + 'Incorrect decloration near ' + Copy(s,i,15))
          else if v2[1] = '$' then
            v2[1] := '@'
          else if v2[1] <> '@' then
            v2 := '@' + v2;

          { tmpi1 := CharPos(v1,'(',['()']);
            tmpi2 := CharPos(v1,')',['()'],tmpi1+1); }

          v1 := CopyFromTo(v1, '(', ')', ['""', ''''''],['()']);
        end;

        ChItem := TScriptItem.Create;
        if v2[1] = '@' then
          ChItem.Kind := sikProcedure
        else
          ChItem.Kind := sikDecloration;
        //Declorations[v2] := trim(v1);
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
  i, j: integer;
  Lnk: TObject;
  obj: TObject;
  cont: boolean;

begin
  Lnk := LinkedObj;

  if Assigned(SE) then
  begin
    Calced := TValueList.Create;
    try
      Calced.Assign(Parameters);

      if Assigned(PVE) then
        for i := 0 to Calced.Count - 1 do
          Calced.Items[i].Value := CalcValue(Calced.Items[i].Value, PVE, Lnk);

      cont := SE(Self, Calced, Lnk);
    finally
      FreeAndNil(Calced);
    end;
  end else
    cont := true;

  if cont then
  begin
    //j := 0;

      if assigned(lnk) and (lnk is TWorkList) then
      with (lnk as TWorkList) do
        for i := 0 to Count -1 do
          Items[i].Section.Process(SE,DE,FE,VE,PVE,Items[i].Obj)
      else
      begin

        if (Kind <> sikNone)
        and assigned(lnk) and (lnk is tlist) and ((lnk as tlist).Count > 0) then
        begin
          j := 0;
          obj := (lnk as tlist)[j];
          inc(j);
        end else
        begin
          j := -1;
          obj := lnk;
        end;

        repeat
          for i := 0 to ChildSections.Count -1 do
            case ChildSections[i].Kind of
              sikSection,sikGroup:
                (ChildSections[i] as TScriptSection).Process(SE, DE, FE, VE, PVE, obj);
              sikCondition:
                if (length(ChildSections[i].Name) > 0) then
                  if CalcValue(ChildSections[i].Name, VE, obj) then
                    (ChildSections[i] as TScriptSection).Process(SE, DE, FE, VE, PVE, obj);
              sikProcedure:
                DE(ChildSections[i].Name,ChildSections[i].Value,obj);
              sikDecloration:
                  DE(ChildSections[i].Name,CalcValue(ChildSections[i].Value,VE,obj),obj);
            end;

          if (j > -1) and{ (lnk is tlist) and }((lnk as tlist).Count > j) then
          begin
            obj := (lnk as tlist)[j];
            inc(j);
          end else
            j := -1;
        until j = -1;

      end;

  end;

  if Assigned(FE) then
    FE(Self, Lnk);

end;

procedure TScriptSection.Assign(s: TScriptItem);
begin
  if s = nil then
    Clear
  else
  begin
    inherited Assign(S);
    if s is TScriptSection then
    begin

      //FParent := s.Parent;
      FNoParam := (s as TScriptSection).NoParameters;
      FParametres.Assign((s as TScriptSection).Parameters);
      //FKind := s.Kind;
      //FDeclorations.Assign(s.Declorations);
      //FConditions.Assign(s.Conditions);
      FChildSections.Assign((s as TScriptSection).ChildSections);
    end;
  end;
end;

procedure TScriptSection.Clear;
begin
  FName := '';
  //Conditions.Clear;
  //Declorations.Clear;
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
  i: integer;
  p: TScriptItem;

begin
  p := nil;
  Clear;
  if Assigned(s) then
    for i := 0 to s.Count - 1 do
    begin
{      if s[i].ClassType = TScriptSection then
      begin
        p := TScriptSection.Create;
        (p as TScriptSection).Assign((s[i] as TScriptSection));
      end else if s[i].ClassType = TScriptItem then
      begin
        p := TScriptItem.Create;
        p.Parent := s[i].Parent;
        p.Value := s[i].Value;
      end;   }
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

function TScriptItemList.Get(Index: integer): TScriptItem;
begin
  Result := inherited Get(Index);
end;

// TJobList

function TJobList.AllFinished(incerrs: Boolean): Boolean;
var
  i: integer;
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

function TJobList.NextJob(Status: integer): integer;
var
  i: integer;

begin
  if FCursor < Count then
  begin
    Result := -1;

    for i := FCursor to Count-1 do
      if (Items[FCursor].Status = JOB_NOJOB) then
      begin
        Items[FCursor].Status := JOB_INPROGRESS;
        Result := i;
        FCursor := i + 1;
        Break;
      end;

    for i := FCursor to Count-1 do
      if (Items[FCursor].Status = JOB_NOJOB) then
      begin
        FCursor := i;
        Exit;
      end;

    FCursor := Count;
  end
  else
    Result := -1;
end;

procedure TJobList.Reset;
var
  i: integer;

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

function TJobList.eol: Boolean;
begin
  Result := not(FCursor < Count);
end;

function TJobList.Get(Value: integer): PJobRec;
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

function TJobList.Add(id, kind: integer): integer;
begin
  New(FLastAdded);
  FLastAdded.id := id;
  FLastAdded.kind := kind;
  FLastAdded.Url := '';
  FLastAdded.Status := JOB_NOJOB;
  Result := inherited Add(FLastAdded);
end;

// TResource

procedure TResource.Assign(R: TResource);
begin
  // FDownloadSet := R.DownloadSet;
  FFileName := R.FileName;
  FIconFile := R.IconFile;
  FInherit := R.Inherit;
  FFields.Assign(R.Fields);
  if FInherit then
  begin
    FFields.Assign(R.Parent.Fields, laOr);
    FNameFormat := R.Parent.NameFormat;
  end
  else
    FNameFormat := R.NameFormat;
  FLoginPrompt := R.LoginPrompt;
  FResName := R.Name;
  FSectors.Assign(R.Sectors);
  FPicFieldList.Assign(R.PicFieldList);
  // FURL := R.Url;
  FShort := R.Short;
  FHTTPRec.DefUrl := R.HTTPRec.DefUrl;
  FHTTPRec.Url := '';
  FHTTPRec.Referer := '';
  FHTTPRec.CookieStr := '';
  FHTTPRec.LoginStr := '';
  FHTTPRec.LoginPost := '';
  FHTTPRec.Method := hmGet;
  FHTTPRec.ParseMethod := 'xml';
  FHTTPRec.Counter := 0;
  FHTTPRec.Count := 0;
end;

function TResource.CanAddThread: Boolean;
begin
  Result := (FMaxThreadCount = 0) or (FMaxThreadCount > 0) and
    (FCurrThreadCount < FMaxThreadCount);
end;

constructor TResource.Create;
begin
  inherited;
  FFileName := '';
  // FURL := '';
  FIconFile := '';
  FParent := nil;
  FPictureList := TPictureLinkList.Create;
  //FPictureList.Resource := Self;
  FInherit := true;
  FLoginPrompt := false;
  FRelogin := false;
  FFields := TResourceFields.Create;
  FFields.AddField('tag', '', ftString, null, '');
  FFields.AddField('login', '',ftNone,null,'');
  FFields.AddField('password', '',ftNone,null,'');
  FSectors := TValueList.Create;
  FPicFieldList := TStringList.Create;
  FInitialScript := nil;
  FBeforeScript := nil;
  FAfterScript := nil;
  FXMLScript := nil;
  FPicScript := nil;
  // FAddToQueue := nil;
  // FJobFinished := false;
  // FPerpageMode := false;
  FNextPage := false;
  FJobList := TJobList.Create;
  // FJobFinished := false;
end;

destructor TResource.Destroy;
begin
  FJobList.Free;
  FPictureList.Free;
  FSectors.Free;
  FFields.Free;
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
  { if Assigned(FPictureList) then
    FPictureList.Free; }
  inherited;
end;

procedure TResource.GetSectors(s: string; R: TValueList);
const
  isl: array [0 .. 1] of string = ('""', '''''');
  brk: array [0 .. 0] of string = ('{}');
var
  n1, n2: integer;
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

    if CheckStr(pr, ['A' .. 'Z', 'a' .. 'z']) then
      raise Exception.Create(Format(lang('_SCRIPT_READ_ERROR_'),
        [lang('_SYMBOLS_IN_SECTOR_NAME_')]));

    // Delete(s, 1, n2);
  end;
end;

procedure TResource.StartJob(JobType: integer);
begin
  case JobType of
    JOB_LIST:
      begin
        FJobList.Reset;

        if (FJobList.Count > 0) and (FJobList.AllFinished(false)) then
        begin
          // FJobFinished := true;
          Exit;
        end;

        FCurrThreadCount := 0;
        // FJobFinished := false;

        FJobInitiated := FJobList.Count > 0;
        if not FJobInitiated then
        begin
          FHTTPRec.Counter := 0;
          if not Assigned(FInitialScript) then
            FInitialScript := TScriptSection.Create;

          FInitialScript.ParseValues(FSectors[LIST_SCRIPT]);

          FJobList.Add(0, JOB_LIST);
        end;
      end;
{    JOB_LOGIN:
      begin
      end;        }
    JOB_PICS:
      begin
        //FPictureList.Reset;

        FPictureList.Reset;

        if (FPictureList.Count = 0) or (FPictureList.AllFinished(false)) then
        begin
          // FJobFinished := true;
          Exit;
        end;

        FPictureThreadCount := 0;
        // FJobFinished := false;

        // FJobInitiated := FJobList.Count > 0;
        if not Assigned(FPicScript) then
          FPicScript := TScriptSection.Create;

        FPicScript.ParseValues(FSectors[DOWNLOAD_SCRIPT]);

      end;
  end;

  // AddToQueue(Self);
end;

function TResource.StringFromFile(fname: string): string;
var
  f: TFileStream;
  s: AnsiString;

begin
  f := TFileStream.Create(fname, FmOpenRead);
  if f.Size > 0 then
  begin
    SetLength(s, f.Size);
    f.Read(s[1], f.Size);
  end;
  f.Free;
  Result := String(s);
end;

function TResource.CreateFullFieldList: TStringList;
begin
  Result := nil;
end;

procedure TResource.CreateJob(t: TDownloadThread);
{ var
  n: integer; }
begin
  // t.JobId := ;
  t.JobId := FJobList.NextJob(JOB_LIST);

  t.JobComplete := JobComplete;
  if not JobInitiated then
  begin
    t.InitialScript := InitialScript;
    FJobInitiated := true;
  end;
  t.BeforeScript := BeforeScript;
  t.AfterScript := AfterScript;
  t.XMLScript := XMLScript;
  t.HTTPRec := HTTPRec;
  t.DownloadRec := DownloadSet;
  t.Sectors := FSectors;
  t.LPictureList := FPictureList.Link;
  t.Fields := FFields;
  t.Resource := Self;
  t.Job := JOB_LIST;
  inc(FHTTPRec.Counter);
  inc(FCurrThreadCount);
end;

procedure TResource.CreateLoginJob(t: tDownloadThread);
begin
  t.JobId := 0;
  t.JobComplete := LoginJobComplete;
  t.InitialScript := nil;
  t.BeforeScript := nil;
  t.AfterScript := nil;
  t.XMLScript := nil;
  t.HTTPRec := HTTPRec;
  t.DownloadRec := DownloadSet;
  t.Fields := FFields;
  t.Resource := Self;
  t.Job := JOB_LOGIN;
  inc(FCurrThreadCount);
end;

procedure TResource.CreatePicJob(t: TDownloadThread);
begin
  // t.JobId := ;
  t.Picture := FPictureList.NextJob(JOB_PICS);
  t.JobComplete := PicJobComplete;
  t.InitialScript := FPicScript;
  { if not JobInitiated then
    begin
    t.InitialScript := InitialScript;
    FJobInitiated := True;
    end;
    t.BeforeScript := BeforeScript;
    t.AfterScript := AfterScript;
    t.XMLScript := XMLScript;
    t.HTTPRec := HTTPRec; }
  t.DownloadRec := DownloadSet;
  t.HTTPRec := HTTPRec;
  t.Sectors := FSectors;
  t.Fields := FFields;
  t.Resource := Self;
  t.Job := JOB_PICS;
  { inc(FHTTPRec.Counter);}
    inc(FPictureThreadCount);
end;

procedure TResource.DeclorationEvent(ItemName: String; ItemValue: Variant; LinkedObj: TObject);
// loading main settings of resoruce

  function Clc(Value: variant): variant;
  begin
    Result := CalcValue(Value, nil, LinkedObj);
  end;

  procedure ProcValue(ItemName: String; ItemValue: Variant);
  var
    s, v: String;
    FSct: TValueList;
    FSS: TScriptSection;
    i: integer;
    f: PResourceField;
  begin
    if SameText(ItemName,'$main.url') then
      FHTTPRec.DefUrl := ItemValue
    else if SameText(ItemName,'$main.icon') then
      FIconFile := ItemValue
    else if SameText(ItemName,'$main.loginprompt') then
      FLoginPrompt := Boolean(ItemValue)
    else if SameText(ItemName,'$main.short') then
      FShort := ItemValue
    else if SameText(ItemName,'$main.checkcookie') then
      FHTTPRec.CookieStr := ItemValue
    else if SameText(ItemName,'$main.login') then
      FHTTPRec.LoginStr := ItemValue
    else if SameText(ItemName,'$main.loginpost') then
      FHTTPRec.LoginPost := ItemValue
    else if SameText(ItemName,'$main.template') then
    begin
      s := StringFromFile(ExtractFilePath(paramstr(0)) + 'resources\' +
        ItemValue);
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
    else if SameText(ItemName,'@picture.fields') then
    begin
      FPicFieldList.Clear;
      s := ItemValue;
      while s <> '' do
      begin
        v := GetNextS(s, ',');
        FPicFieldList.Add(lowercase(TrimEx(v,[' ',#9,#10,#13])));
      end;
    end
    else if SameText(ItemName,'@addfield') then
    begin
      {
      TFieldType = (ftNone, ftString, ftPassword,
      ftNumber, ftFloatNumber,ftCombo, ftCheck);
      }
      s := ItemValue;
      f := Fields.Items[Fields.AddField(Clc(nVal(s)),'',ftNone,null,'')];
      f.restitle := Clc(nVal(s));
      f.resvalue := Clc(nVal(s));
      v := Clc(nVal(s));
      if sametext(v,'textedit') then
        f.restype := ftString
      else if sametext(v,'passwordedit') then
        f.restype := ftPassword
      else if sametext(v,'integeredit') then
        f.restype := ftNumber
      else if sametext(v,'floatedit') then
        f.restype := ftFloatNumber
      else if sametext(v,'listbox') then
        f.restype := ftCombo
      else if sametext(v,'checkbox') then
        f.restype := ftCheck;
      f.resitems := s;
    end
    else if ItemName[1] = '$' then
    begin
      ItemName := DeleteEx(ItemName, 1, 1);
      i := Fields.FindField(ItemName);
      if i = -1 then
        Fields.AddField(ItemName, '', ftNone, ItemValue, '')
      else
        Fields.Items[i].resvalue := ItemValue;
    end
    else
      raise Exception.Create(Format(lang('_INCORRECT_DECLORATION_'), [ItemName]));

  end;

{var
  i: integer;
  t: TListValue;     }
begin
{  for i := 0 to Values.Count - 1 do
  begin
    t := Values.Items[i];  }
    ProcValue(ItemName, ItemValue);
//  end;
end;

function TResource.JobComplete(t: TDownloadThread): integer;
// procedure, called when thread finish it job
var
  i: integer;
  //s: LongInt;
begin
  try
    if (t.ReturnValue = THREAD_COMPLETE)
    and (t.Job <> JOB_ERROR)
    and not t.InitialScript.Empty then
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
      FFields.Assign(t.Fields);
      HTTPRec := t.HTTPRec;

      for i := HTTPRec.Counter to HTTPRec.Count - 1 do
        FJobList.Add(HTTPRec.Counter, JOB_LIST);

      CheckIdle(true);

      // FJobInitiated := true;
    end;
  finally

    if (t.PicsAdded) and (t.PictureList.Count > 0)  then
    begin
      //for i := 0 to t.PictureList.Count -1 do
      //  FPictureList.Add(t.PictureList[i].Orig);
      if Assigned(Self) and t.PicsAdded then
        PictureList.Link.OnEndAddList(Self);
      //s := GetTickCount;
      //FOnError(Self, IntToStr(GetTickCount - s) + ' ms');
    end;

    if t.ReturnValue = THREAD_COMPLETE then
      case t.Job of
        JOB_LIST:
          begin
            inc(FJobList.FOkCount);
            FJobList[t.JobId].Status := JOB_FINISHED;
{
            if t.PictureList.Count > 0 then
            begin
              //for i := 0 to t.PictureList.Count -1 do
              //  FPictureList.Add(t.PictureList[i].Orig);
              if Assigned(Self) and t.PicsAdded then
                PictureList.Link.OnEndAddList(Self);
              //s := GetTickCount;
              //FOnError(Self, IntToStr(GetTickCount - s) + ' ms');
            end;
}
          end;
        JOB_ERROR:
          begin
            if not t.InitialScript.Empty then
              FJobList.Clear
            else
            begin
              inc(FJobList.FErrCount);
              FJobList[t.JobId].Status := JOB_ERROR;
            end;
            if Assigned(FOnError) then
              FOnError(Self, t.Error);
          end;
      end
    else
    begin
      if not t.InitialScript.Empty then
        FJobList.Clear
      else
      begin
        if t.ReturnValue = THREAD_FINISH then
          FJobList[t.JobId].Status := JOB_CANCELED
        else
        begin
          inc(FJobList.FErrCount);
          FJobList[t.JobId].Status := JOB_ERROR;
        end;
      end;
    end;

    if Assigned(FOnPageComplete) then
      FOnPageComplete(Self);

    if (FJobList.AllFinished) and (FJobList.eol) then
      FOnJobFinished(Self);

    dec(FCurrThreadCount);
    Result := THREAD_START;
  end;
end;

function TResource.LoginJobComplete(t: TDownloadThread): integer;
begin
  if (t.ReturnValue <> THREAD_COMPLETE)
  or (t.Job = JOB_ERROR) then
    if Assigned(FOnError) then
      FOnError(Self,t.Error);
  FRelogin := false;
  dec(FCurrThreadCount);
  FOnJobFinished(Self);
  Result := THREAD_START;
end;

procedure TResource.LoadFromFile(fname: String);

{ function nullstr(n: Variant): string;
  begin
  if n = null then
  Result := ''
  else
  Result := n;
  end; }

var
  mainscript: TScriptSection;
  s { , tmps } : String;
  // f: textfile;
begin
  if not fileexists(fname) then
    raise Exception.Create(Format(lang('_NO_FILE_'), [fname]));

  // Assignfile(f, FName);
  s := StringFromFile(fname);
  { try
    Reset(f);
    while not eof(f) do
    begin
    readln(f, tmps);
    s := s + tmps + #13#10;
    end;
    finally
    CloseFile(f);
    end; }

  GetSectors(s, FSectors);

  mainscript := nil;

  try
    mainscript := TScriptSection.Create;
    mainscript.ParseValues(Sectors['main']);
    mainscript.Process(nil, DeclorationEvent, nil, nil);
  except
    on e: Exception do
    begin
      if Assigned(mainscript) then
        mainscript.Free;
      if Assigned(FOnError) then
        FOnError(Self, e.Message);
    end;
  end;

  FFileName := fname;
  FResName := ChangeFileExt(ExtractFileName(fname), '');
end;

function TResource.PicJobComplete(t: TDownloadThread): integer;
begin
  try

    inc(PictureList.Link.FPicCounter.FSH);
    inc(PictureList.FPicCounter.FSH);

    if t.ReturnValue = THREAD_COMPLETE then
      case t.Job of
        JOB_PICS:
          begin
            t.Picture.Status := JOB_FINISHED;
            t.Picture.Checked := false;

            if t.Picture.Size = 0 then
            begin
              inc(PictureList.Link.FPicCounter.EXS);
              inc(PictureList.FPicCounter.EXS);
            end else
            begin
              inc(PictureList.Link.FPicCounter.OK);
              inc(PictureList.FPicCounter.OK);
            end;

            if Assigned(t.Picture.OnPicChanged) then
              t.Picture.OnPicChanged(t.Picture, [pcChecked,pcProgress]);
            { if t.PictureList.Count > 0 then
              begin
              PictureList.AddPicList(t.PictureList,true);
              if Assigned(PictureList.OnEndAddList) then
              PictureList.OnEndAddList(t.PictureList);
              end; }
          end;
        JOB_CANCELED:
            t.Picture.Status := JOB_NOJOB;
        JOB_ERROR:
          begin
            t.Picture.Status := JOB_ERROR;
            inc(PictureList.Link.FPicCounter.ERR);
            inc(PictureList.FPicCounter.ERR);
            if Assigned(t.Picture.OnPicChanged) then
              t.Picture.OnPicChanged(t.Picture, [pcProgress]);
            if Assigned(FOnError) then
              FOnError(Self, t.Error);
          end;
      end
    else if t.ReturnValue = THREAD_FINISH then
    begin
      t.Picture.Status := JOB_CANCELED;
{      t.Picture.Pos := 0;
      t.Picture.Size := 0;   }
      if Assigned(t.Picture.OnPicChanged) then
        t.Picture.OnPicChanged(t.Picture, [pcProgress]);
    end else begin
      t.Picture.Status := JOB_ERROR;
      inc(PictureList.Link.FPicCounter.ERR);
      inc(PictureList.FPicCounter.ERR);
      if Assigned(t.Picture.OnPicChanged) then
        t.Picture.OnPicChanged(t.Picture, [pcProgress]);
    end;

    if (FPictureList.eol) and (FPictureList.AllFinished) then
    begin
      // FJobFinished := true;
      FOnPicJobFinished(Self);
    end;

  finally
    Result := THREAD_START;
    dec(FPictureThreadCount);
  end;
end;

// TResourceLinkList

function TResourceLinkList.Get(Index: integer): TResource;
begin
  Result := inherited Get(Index);
end;

procedure TResourceLinkList.GetAllResourceFields(List: TStrings);
var
  n,i,j: integer;
begin
  if Count < 0 then
    Exit;
  if Items[0].FileName = '' then
    n := Items[0].Fields.Count
  else
    n := 0;

  for i := 0 to Count-1 do
    for j := n to Items[i].Fields.Count-1 do
    begin
      if (Items[i].Fields.Items[j].restype <> ftNone)
      and (List.IndexOf(Items[i].Fields.Items[j].resname) = -1) then
        List.Add(Items[i].Fields.Items[j].resname);
    end;

end;

procedure TResourceLinkList.GetAllPictureFields(List: TStrings; withparam: boolean = false);
var
  i,j: integer;
  l: TStringList;
  s: string;

  function AddItem(s: string): integer;
  var
    i: integer;
    r: string;
    n1,n2: string;
    d1,d2: string;
  begin
    r := s;
    n1 := GetNextS(s,':'); GetNextS(s,':');
    d1 := s;
    for i := 0 to List.Count - 1 do
    begin
      s := List[i];
      n2 := GetNextS(s,':'); GetNextS(s,':');
      d2 := s;
      if SameText(n1,n2) then
      begin
        if d2 = '' then
          List[i] := r;
        Result := i;
        Exit;
      end;
    end;

    Result := List.Add(r);
  end;

begin
//  List.Assign(Items[0].PicFieldList);
  for i := 0 to Count - 1 do
  begin
    l := Items[i].PicFieldList;
    for j := 0 to l.Count - 1 do
    begin
      if withparam then
        AddItem(l[j])
      else
      begin
        s := CopyTo(l[j],':');
        if List.IndexOf(s) = -1 then
          List.Add(s);
      end;
    end;
  end;
end;

// TResourceList

function TResourceList.AllFinished: Boolean;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
  begin
    Items[i].JobList.Reset;
    if (Items[i].JobList.Count = 0) or not Items[i].JobList.AllFinished
      (false) then
    begin
      Result := false;
      Exit;
    end;
  end;
  Result := true;
end;

procedure TResourceList.CopyResource(R: TResource);
var
  NR: TResource;
begin
  NR := TResource.Create;
  // NR.AddToQueue := AddToQueue;
  NR.Assign(R);
  NR.PictureList.Link := PictureList;
  NR.CheckIdle := ThreadHandler.CheckIdle;
  NR.OnJobFinished := JobFinished;
  NR.OnPicJobFinished := PicJobFinished;
  NR.OnError := FOnError;
  NR.OnPageComplete := OnPageComplete;
  // NR.PictureList.CheckDouble := CheckDouble;
  Add(NR);
end;

constructor TResourceList.Create;
begin
  inherited;
  FThreadHandler := TThreadHandler.Create;
  FThreadHandler.OnAllThreadsFinished := OnHandlerFinished;
  FThreadHandler.CreateJob := CreateJob;
  // FFinished := True;
  FDwnldHandler := TThreadHandler.Create;
  FDwnldHandler.OnAllThreadsFinished := OnHandlerFinished;
  FDwnldHandler.CreateJob := CreateDWNLDJob;
  FPictureList := TPictureList.Create;
{  FPictureList.OnAddPicture := FOnAddPicture;
  FPictureList.OnBeginAddList := FOnBeginPicList;
  FPictureList.OnEndAddList := FOnEndPicList;
  FPictureList.OnPicChanged := OnPicChanged; }
  FMaxThreadCount := 0;
  FLoginMode := false;
end;

function TResourceList.CreateDWNLDJob(t: TDownloadThread): Boolean;
var
  R: TResource;
  i: integer;
  n: integer;

  function NextNotEOL(n: integer): integer;
  var
    i: integer;

  begin
    for i := n + 1 to Count -1 do
    begin
      if not Items[i].PictureList.eol then
      begin
        Result := i;
        Exit;
      end;
    end;


    for i := 0 to n do
    begin
      if not Items[i].PictureList.eol then
      begin
        Result := i;
        Exit;
      end;
    end;

    Result := n;

  end;

begin


  // queue of tasks

  // check new task
  // from current to end

  n := Items[FPicQueue].PicThreadCount;

  for i := FPicQueue + 1 to Count - 1 do
  begin
    R := Items[i];
    if (n > R.PicThreadCount)
    and not R.PictureList.eol then
    begin
      R.CreatePicJob(t);
      // R.NextPage := false;
      Result := true;
      //inc(FPicQueue);
      Exit;
    end;
  end;

  // from start to current

  for i := 0 to FPicQueue - 1 do
  begin
    R := Items[i];
    if (n > R.PicThreadCount)
    and not R.PictureList.eol then
    begin
      R.CreatePicJob(t);
      // R.NextPage := false;
      Result := true;
      //inc(FPicQueue);
      Exit;
    end;
  end;

  R := Items[FPicQueue];
  if not R.PictureList.eol then
  begin
    R.CreatePicJob(t);
    FPicQueue := NextNotEOL(FPicQueue);
    Result := true;
    Exit;
  end;

  // if no task then result = false

  Result := false;
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

function TResourceList.CreateJob(t: TDownloadThread): Boolean;
var
  R: TResource;
  i: integer;

begin
  if FQueueIndex > Count - 1 then
    if FLoginMode then
    begin
      Result := false;
      Exit;
    end else
      FQueueIndex := 0;

  // queue of tasks

  // check new task
  // from current to end

  for i := FQueueIndex to Count - 1 do
  begin
    R := Items[i];
    if FLoginMode then
      if R.Relogin and (r.HTTPRec.CookieStr <> '') and
        (t.HTTP.CookieList.GetCookieValue(r.HTTPRec.CookieStr,
        trim(DeleteTo(DeleteTo(lowercase(r.HTTPRec.DefUrl), ':/'),'www.'), '/'))
        = '') then
      begin
        r.CreateLoginJob(t);
        Result := true;
        FQueueIndex := i + 1;
        Exit;
      end else
    else
      if (not(FPageMode and not R.NextPage) and
        (not R.JobInitiated or (not R.JobList.eol))) and R.CanAddThread then
      begin
        R.CreateJob(t);
        // R.NextPage := false;
        Result := true;
        inc(FQueueIndex);
        Exit;
      end;
  end;

  // from start to current
  if not FLoginMode then
    for i := 0 to FQueueIndex - 1 do
    begin
      R := Items[i];
      if (not(FPageMode and not R.NextPage) and
        (not R.JobInitiated or (not R.JobList.eol))) and R.CanAddThread then
      begin
        R.CreateJob(t);
        R.NextPage := false;
        Result := true;
        inc(FQueueIndex);
        Exit;
      end;
    end;

  // if no task then result = false

  Result := false;

  if FLoginMode then
    FThreadHandler.FinishQueue;

end;

procedure TResourceList.SetMaxThreadCount(Value: integer);
{ var
  i: integer; }
begin
  FMaxThreadCount := Value;
  { for i := 0 to Count -1 do
    if Items[i].JobFinished then
    Items[i].MaxThreadCount := Value; }
end;

procedure TResourceList.SetOnError(Value: TLogEvent);
var
  i: integer;
begin
  FOnError := Value;
  FThreadHandler.OnError := Value;
  FDWNLDHandler.OnError := Value;
  for i := 0 to Count - 1 do
    Items[i].OnError := Value;
end;

function TResourceList.GetListFinished: Boolean;
begin
  Result := ThreadHandler.Count = 0;
end;

function TResourceList.GetPicsFinished: Boolean;
begin
  Result := FDwnldHandler.Count = 0;
end;

destructor TResourceList.Destroy;
begin
  FThreadHandler.Free;
  FDWNLDHandler.Free;
  FPictureList.Free;
  inherited;
end;

procedure TResourceList.CreatePicFields;
var
  i, j: integer;
  l,f: TStringList;
  p: TMetaList;
  s,n: string;
begin
  f := TStringList.Create;
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

  for i := 0 to f.Count -1 do
  begin
    s := f[i];
    n := GetNextS(s,':');

    p := FPicturelist.Meta[n];
    if p = nil then
    begin
      p := TMetaList.Create;
      if s <> '' then
        case s[1] of
          'i' : p.ValueType := ftInteger;
          'd' : p.ValueType := ftDateTime;
          'b' : p.ValueType := ftBoolean;
          'f','p' : p.ValueType := ftFloat;
          else p.ValueType := DB.ftString;
        end
      else
        p.ValueType := DB.ftString;
      FPicturelist.Meta[n] := p;
    end;
  end;

//  l.Free;
  f.Free;
end;

procedure TResourceList.JobFinished(R: TResource);
var
  i: integer;

begin
  if FLoginMode then
  begin
    if ThreadHandler.Cookies.GetCookieValue(r.HTTPRec.CookieStr,
      trim(DeleteTo(DeleteTo(lowercase(r.HTTPRec.DefUrl), ':/'),'www.'), '/'))
      = '' then
      if Assigned(FOnError) then
        FOnError(Self,Format(lang('_ERROR_LOGIN_'),[r.Name]));

    for i := 0 to Count - 1 do
      if Items[i].Relogin then
        Exit;
  end
  else
    for i := 0 to Count - 1 do
      if not Items[i].JobList.AllFinished then
        Exit;
  ThreadHandler.FinishQueue;
end;

procedure TResourceList.NextPage;
var
  i: integer;

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

procedure TResourceList.StartJob(JobType: integer);
var
  i: integer;

begin
  case JobType of
    JOB_STOPLIST:
    begin
      if FStopTick = 0 then
      begin
        FStopTick := GetTickCount;
        FThreadHandler.FinishThreads(false);
      end else if (FStopTick - GetTickCount) > 5000 then
      begin
        FStopTick := 0;
        FThreadHandler.FinishThreads(true);
      end;
      FCanceled := true;
    end;
    JOB_STOPPICS:
    begin
      if FStopPicsTick = 0 then
      begin
        FStopPicsTick := GetTickCount;
        FDwnldHandler.FinishThreads(false);
      end else if (FStopPicsTick - GetTickCount) > 5000 then
      begin
        FStopPicsTick := 0;
        FDwnldHandler.FinishThreads(true);
      end;
      FCanceled := true;
    end;
    JOB_LIST:
      if ListFinished then
      begin
        FLoginMode := false;
        if AllFinished then
          Exit;
        FQueueIndex := 0;
        ThreadHandler.CreateThreads;
        for i := 0 to Count - 1 do
        begin
          with Items[i] do
          begin
            MaxThreadCount := Self.MaxThreadCount;
            { if Inherit then
              PictureList.NameFormat := PicFileFormat; }
            StartJob(JobType);
            if not FPageMode and (not JobList.eol) then
              ThreadHandler.CheckIdle;
          end;
        end;

        if Assigned(FJobChanged) then
          FJobChanged(Self, JobType);

        if FPageMode then
          NextPage;

        FCanceled := false;
      end;
    JOB_LOGIN:
      if ListFinished then
      begin
        FQueueIndex := 0;
        ThreadHandler.CreateThreads;
        for i := 0 to Count - 1 do
          with Items[i] do
          begin
            MaxThreadCount := Self.MaxThreadCount;
            StartJob(JobType);
          end;
        FLoginMode := true;
        ThreadHandler.CheckIdle;

        if Assigned(FJobChanged) then
          FJobChanged(Self, JobType);

        FCanceled := false;
      end;
    JOB_PICS:
      if PicsFinished then
      begin
        if AllPicsFinished then
          Exit;
        //FPictureList.Reset;
        FPicQueue := 0;
        FDwnldHandler.CreateThreads;
        for i := 0 to Count - 1 do
        begin
          with Items[i] do
          begin
            // MaxThreadCount := MaxThreadCount;
            { if Inherit then
              PictureList.NameFormat := PicFileFormat; }
            StartJob(JobType);
            if not FPictureList.eol then
              FDwnldHandler.CheckIdle
            else
              if FPicQueue = i then
                inc(FPicQueue);
          end;
        end;

        if Assigned(FJobChanged) then
          FJobChanged(Self, JobType);

        FCanceled := false;
      end;
  end;
  // ThreadHandler.CheckIdle(true);
end;

procedure TResourceList.UncheckDoubles;
{var
  i,j: integer;   }
begin
{  for i := 0 to Count -1 do
    for j := Items[i].PictureList.Count-1 downto 0 do
      if Items[i].PictureList[j].Checked then
        CheckDouble(Items[i].PictureList[j],i,j + 1); }
  //Result := false;
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
      if Assigned(FJobChanged) then
        FJobChanged(Self, JOB_STOPLIST);
      if FLoginMode then
        FLoginMode := false;
    end else
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
  i: integer;

begin
  for i := 0 to Count - 1 do
    if not Items[i].PictureList.AllFinished then
      Exit;
  FDwnldHandler.FinishQueue;
end;

procedure TResourceList.LoadList(Dir: String);
var
  a: TSearchRec;
  R: TResource;

begin
  Clear;

  R := TResource.Create;
  R.Inherit := false;
  R.Name := lang('_GENERAL_');
  R.PictureList.Link := PictureList;
  R.CheckIdle := ThreadHandler.CheckIdle;
  R.OnJobFinished := JobFinished;
  R.OnPicJobFinished := PicJobFinished;
  R.OnError := FOnError;
  R.OnPageComplete := OnPageComplete;
  Add(R);

  R := nil;

  if not DirectoryExists(Dir) then
  begin
    if Assigned(FOnError) then
      FOnError(Self, Format(lang('_NO_DIRECTORY_'), [Dir]));
    Exit;
  end;
  Dir := IncludeTrailingPathDelimiter(Dir);

  if FindFirst(Dir + '*.cfg', faAnyFile, a) = 0 then
  begin
    repeat
      try
        R := TResource.Create;
        R.LoadFromFile(Dir + a.Name);
        R.Parent := Items[0];
        R.PictureList.Link := PictureList;
        R.CheckIdle := ThreadHandler.CheckIdle;
        R.OnJobFinished := JobFinished;
        R.OnPicJobFinished := PicJobFinished;
        R.OnError := FOnError;
        R.OnPageComplete := OnPageComplete;
        Add(R);
      except
        on e: Exception do
        begin
          if Assigned(FOnError) then
            FOnError(Self, e.Message);
          if Assigned(R) then
            R.Free;
        end;

      end;
    until FindNext(a) <> 0;

  end;
end;


// TDownloadThread

procedure TDownloadThread.Execute;
begin
//  ReturnValue := THREAD_STOP;

  while not terminated do
  begin
    // FErrorString := '';
    FPicsAdded := false;
    try
      Synchronize(DoFinish);
      case ReturnValue of
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
        raise Exception.Create('thread.execute: resource not assigned');

      try
        if Job = JOB_PICS then
        begin
          FPicture.Changes := [];
          HTTP.OnWorkBegin := IdHTTPWorkBegin;
          HTTP.OnWork := IdHTTPWork;
        end
        else
        begin
          HTTP.OnWorkBegin := nil;
          HTTP.OnWork := nil;
        end;

        if Job = JOB_LOGIN then
          ProcLogin
        else
        begin
          if not FInitialScript.Empty then
          begin
            FInitialScript.Process(SE, DE, FE, VE, VE);
          end else
          begin
            if (FHTTPRec.Count = 0) and (FHTTPRec.Counter = 0) then
              FHTTPRec.Counter := 1;

            if Job = JOB_LIST THEN
              ProcHTTP;
          end;

          if Job = JOB_PICS then
            ProcPic;

        end;

        if Self.ReturnValue <> THREAD_FINISH then
          Self.ReturnValue := THREAD_COMPLETE
        {$IFDEF NEKODEBUG}else FCSFiles.Enter;SaveStrToFile('thread_'+Format('%p',[Pointer(Self)])+': threadaborted',debugthreads,true);FCSFiles.Leave;{$ENDIF}
      finally
        {$IFDEF NEKODEBUG}FCSFiles.Enter;if FJOB = JOB_ERROR then
        SaveStrToFile('thread_'+Format('%p',[Pointer(Self)])+': httperror ' + FERRORSTRING,debugthreads,true);FCSFiles.Leave;{$ENDIF}
        {$IFDEF NEKODEBUG}FCSFiles.Enter;SaveStrToFile('thread_'+Format('%p',[Pointer(Self)])+': startjobsynch',debugthreads,true);FCSFiles.Leave;{$ENDIF}
        Synchronize(DoJobComplete);
        {$IFDEF NEKODEBUG}FCSFiles.Enter;SaveStrToFile('thread_'+Format('%p',[Pointer(Self)])+': finishjobsynch',debugthreads,true);FCSFiles.Leave;{$ENDIF}
        FPicList.Clear;
        FPicture := nil;
      end;
    except
      on e: Exception do
      begin
        FErrorString := e.Message;

        {$IFDEF NEKODEBUG}FCSFiles.Enter;SaveStrToFile('thread_'+Format('%p',[Pointer(Self)])+': threaderror ' + FErrorString,debugthreads,true);FCSFiles.Leave;{$ENDIF}

        if FSTOPERROR then
          Break
        else
          FSTOPERROR := true;
      end;
    end;
  end;
end;

procedure TDownloadThread.AddPicture;
{ var
  i: integer; }
begin
  // FPicLink := TTPicture.Create;
  // FPicLink.Assign(FPicture);
  // FPictureList.Add(FPicLink);
  { for i := 0 to FTagList.Count -1 do
    FPictureList.Tags.Add(FTagList[i],FPicLink); }
  FPicture := TTPicture.Create;
  FPicture.Checked := true;
  // FPicture.Obj := TStringList.Create;
  FPicList.Add(FPicture,FResource);
  // FTagList.Clear;
  // FAddPic := false;
end;

procedure TDownloadThread.ClonePicture;
var
  fpic: TTPicture;
begin
  fpic := TTPicture.Create;
  Fpic.Checked := true;
  fpic.Assign(FPicture,true);
  FPicList.Add(fpic,FResource);
  FPicture := fpic;
end;

constructor TDownloadThread.Create;
begin
  FEventHandle := CreateEvent(nil, true, false, nil);
  FFinish := nil;
  inherited Create(false);
  FHTTP := CreateHTTP;
  FSSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create;
  FInitialScript := TScriptSection.Create;
  FBeforeScript := TScriptSection.Create;
  FAfterScript := TScriptSection.Create;
  FXMLScript := TScriptSection.Create;
  FFields := TResourceFields.Create;
  FXML := TMyXMLParser.Create;
  // FPictureList := nil;
  FPicList := TPictureList.Create;
  FPicList.MakeNames := false;
  FPicture := nil;
  FSectors := TValueList.Create;
  FSTOPERROR := false;
  // FTagList := TStringList.Create;
  // FPicList := TList.Create;
end;

destructor TDownloadThread.Destroy;
begin
  CloseHandle(FEventHandle);
  FInitialScript.Free;
  FBeforeScript.Free;
  FAfterScript.Free;
  FXMLScript.Free;
  FFields.Free;
  FXML.Free;
  FSSLHandler.Free;
  FHTTP.Free;
  //FPicture.Free;
  // FTagList.Free;
  FPicList.Free;
  inherited;
end;

procedure TDownloadThread.DoJobComplete;
begin
  FJobComplete(Self);
end;

procedure TDownloadThread.DoFinish;
begin
  ReturnValue := Finish(Self);
end;

function TDownloadThread.SE(const Item: TScriptSection; const Parametres: TValueList;
  var LinkedObj: TObject): boolean;

  function copytag(s: ttag): ttag;
  begin
    result := ttag.Create(s.Name,s.Kind);
    result.Attrs.Assign(s.Attrs);
    result.Childs.CopyList(s.Childs,Result);
    result.Tag := s.Tag;
  end;

var
  l,s: TTagList;
  p: TWorkList;
  i,j: integer;
  a: array of TAttrList;
  tags: array of string;
//  tmp: string;
begin
{  if Assigned(LinkedObj) then
    tmp := LinkedObj.ClassName;  }
  if {((Item.Kind = sikSection) and (Item.Name<>'') or (Item.Kind <> sikSection))
  and} Assigned(LinkedObj) and((LinkedObj is TTagList)
  or (LinkedObj is TTag)){ and ((LinkedObj as TTag).Tag = 0))} then
  begin
    if (LinkedObj is TTag) then
      if (LinkedObj as TTag).Tag = 0 then
      begin
        //tmp := (LinkedObj as TTag).Name;
        s := (LinkedObj as TTag).Childs;
      end else
      begin
        Result := true;
        (LinkedObj as TTag).Tag := 0;
        Exit;
      end
    else
      s := LinkedObj as TTagList;

    l := TTagList.Create;
    try
{
      if (LinkedObj is TTagList) then
        s := LinkedObj as TTagList
      else
        s := (LinkedObj as TTag).Childs;
}
      case Item.Kind of
        sikSection:
        begin
          setlength(a,1);

          a[0] := TAttrList.Create;
          try
            for i := 0 to Parametres.Count - 1 do
              a[0].Add(Parametres.Items[i].Name, VarToStr(Parametres.Items[i].Value));

            //if Item.NoParameters then
            //  a[0].NoParameters := Item.NoParameters;

            a[0].NoParameters := Item.NoParameters;
            s.GetList(Item.Name, a[0], l);
          finally
            a[0].Free;
            SetLength(a,0);
          end;

          LinkedObj := l;

          Result := l.Count > 0;
        end;
        sikGroup:
        begin
          SetLength(tags,Item.ChildSections.Count);
          SetLength(a,Item.ChildSections.Count);
          
          for j := 0 to Item.ChildSections.Count -1 do
            a[j] := nil;
          
          try
            for j := 0 to Item.ChildSections.Count -1 do
            with (Item.ChildSections[j] as TScriptSection) do
            begin
              tags[j] := Item.ChildSections[j].Name;
              a[j] := TAttrList.Create;
              a[j].Tag := Integer(Item.ChildSections[j]);

              for i := 0 to Parameters.Count - 1 do
                a[j].Add(Parametres.Items[i].Name,
                  VarToStr(CalcValue(Parametres.Items[i].Value,VE,LinkedObj)));

              a[j].NoParameters := NoParameters;
            end;

            s.GetList(tags,a,l);
            //j := 0;
            //while j < l.Count-1 do
            //begin
            //  l.Insert(j,Item);
            //  inc(j,2);
            //end;

            
          finally
            for j := 0 to Item.ChildSections.Count -1 do
              if Assigned(a[j]) then
                a[j].Free;
                
            SetLength(tags,0);
            SetLength(a,0);
          end;

          p := TWorkList.Create;
          try
            for j := 0 to l.Count-1 do
              p.Add(TScriptSection(l[j].Tag),copytag(l[j]));

            LinkedObj := p;
            Result := p.Count > 0;
            l.Free;
          except on e: exception do begin
            p.Free;
            raise Exception.Create(e.Message);
          end; end;
        end;
        else Result := true;
      end;
    except on e: exception do begin
      if Assigned(l) then
        l.Free;
      raise Exception.Create(e.Message);
    end; end;
  end
  else
    Result := true;
end;

procedure TDownloadThread.VE(Value: String;
  var Result: Variant; var LinkedObj: TObject);

  function Clc(Value: variant): variant;
  begin
    Result := CalcValue(Value, VE, LinkedObj);
  end;

var
  t: TTag;
  s, tmp: string;
  n,n2,i: integer;
  c: char;
begin
  // Value := lowrcase(Value);
  Result := '';
  c := Copy(Value,1,1)[1];
  Delete(Value,1,1);
{  if LinkedObj is TTagList then
    Exit;     }
  try
  case c of
    '#':
      if Assigned(LinkedObj) and (LinkedObj is TTag) then
        Result := ClearHTML((LinkedObj as TTag).Attrs.Value(Value));
{      else
        raise Exception.Create('Tag' + ValS + Value + ': invalid class type '
          + LinkedObj.ClassName);     }
    '$':
      if Pos('picture%', Value) = 1 then
      begin
        s := Value;
        tmp := GetNextS(s, '%');
        Result := FPicture.Meta[s];
      end
      else if SameText(Value,'main.url') then
        Result := HTTPRec.DefUrl
      else if SameText(Value,'thread.count') then
        Result := HTTPRec.Count
      else if SameText(Value,'thread.result') then
        Result := HTTPRec.Theor
      else if SameText(Value,'thread.counter') then
        Result := HTTPRec.Counter
      else
        if Fields.FindField(Result)>-1 then
          Result := Fields[Value]
        else
          raise Exception.Create('Unknown variable: ' + c + Value);
    '@':
      begin
        s := TrimEx(CopyTo(Value, '('), [#13, #10, #9, ' ']);
        if SameText(s,'text') then
          if Assigned(LinkedObj) and (LinkedObj is TTag) then
            Result := TrimEx(ClearHTML((LinkedObj as TTag).GetText(txkCurrent,false))
                              ,[' ',#13,#10])
          else
            Result := ''
        else if SameText(s,'calc') then
          Result := Clc(trim(Clc(gVal(Value)),''''))
        else if SameText(s,'httpencode') then
          Result := STRINGENCODE(StringDecode(Clc(gVal(Value))))
        else if SameText(s,'emptyname') then
          Result := emptyname(StringDecode(Clc(gVal(Value))))
        else if SameText(s,'unixtime') then
          Result := UnixToDateTime(Clc(gVal(Value)))
        else if SameText(s,'removevars') then
        begin
          Result := CopyTo(CopyTo(Clc(gVal(Value)),'?',[],[]),'#',[],[]);
        end else if SameText(s,'removedomain') then
          Result := RemoveURLDomain(Clc(gVal(Value)))
        else if SameText(s,'boolstr') then
          if Clc(gVal(Value)) then
            Result := 'True'
          else
            Result := 'False'
        else if SameText(s,'min') then
        begin
          s := gVal(Value);
          Result := Min(Clc(nVal(s)),Clc(nVal(s)));
        end
        else if SameText(s,'max') then
        begin
          s := gVal(Value);
          Result := Max(Clc(nVal(s)),Clc(nVal(s)));
        end
        else if SameText(s,'changename') then
        begin
          s := gVal(Value);
          tmp := Clc(nVal(s));
          s := Clc(nVal(s));
          Result := ChangeFileExt(tmp,s + ExtractFileExt(tmp));
        end
        else if SameText(s,'changeext') then
        begin
          s := gVal(Value);
          Result := ChangeFileExt(Clc(nVal(s)),'.'+lowercase(Clc(nVal(s))));
        end
        else if SameText(s,'isempty') then
        begin
          s := gVal(Value);
          Result := Clc(nVal(s));
          if VarToStr(Result) = '' then
            Result := Clc(nVal(s));
        end else if SameText(s,'urlvar') then
        begin
          s := gVal(Value);
          Result := ClearHTML(StringDecode(
            GetURLVarValue(Clc(nVal(s)),Clc(nVal(s)))));
        end else if SameText(s,'copyto') then
        begin
          s := gVal(Value);
          Result := CopyTo(Clc(nVal(s)),Clc(nVal(s)));
        end else if SameText(s,'copytoex') then
        begin
          s := gVal(Value);
          Result := CopyTo(Clc(nVal(s)),Clc(nVal(s)),false,true);
        end else if SameText(s,'copybackto') then
        begin
          s := gVal(Value);
          Result := CopyTo(Clc(nVal(s)),Clc(nVal(s)),true);
        end else if SameText(s,'copybacktoex') then
        begin
          s := gVal(Value);
          Result := CopyTo(Clc(nVal(s)),Clc(nVal(s)),true,true);
        end else if SameText(s,'copyfrom') then
        begin
          s := gVal(Value);
          Result := CopyFromTo(Clc(nVal(s)),Clc(nVal(s)),'');
        end else if SameText(s,'copyfromtoex') then
        begin
          s := gVal(Value);
          Result := CopyFromTo(Clc(nVal(s)),Clc(nVal(s)),Clc(nVal(s)),true);
        end else if SameText(s,'deleteto') then
        begin
          s := gVal(Value);
          Result := DeleteTo(Clc(nVal(s)),Clc(nVal(s)),false);
        end else if SameText(s,'deletetoex') then
        begin
          s := gVal(Value);
          Result := DeleteTo(Clc(nVal(s)),Clc(nVal(s)),false,true);
        end else if SameText(s,'deletefromto') then
        begin
          s := gVal(Value);
          Result := DeleteFromTo(Clc(nVal(s)),Clc(nVal(s)),Clc(nVal(s)),false,true);
        end else if SameText(s,'replace') then
        begin
          s := gVal(Value);
          Result := StringReplace(Clc(nVal(s)),Clc(nVal(s)),Clc(nVal(s)),
            [rfReplaceAll,rfIgnoreCase]);
        end else if SameText(s,'vartime') then
        begin
          s := gVal(Value);
          Result := DateTimeStrEval(Clc(nVal(s)), Clc(nVal(s)), Clc(nVal(s)));
        end else if SameText(s,'datepart') then
          Result := DateOf(StrToDateTime(Clc(gVal(Value))))
        else if SameText(s,'timepart') then
          Result := TimeOf(StrToDateTime(Clc(gVal(Value))))
        else if SameText(s,'trim') then
        begin
          s := gVal(Value);
          tmp := nVal(s);
          if s = '' then
            Result := TrimEx(Clc(tmp),[#9,#10,#13,' '])
          else begin
            s := Clc(s);
            Result := trim(Clc(tmp),s[1]);
          end;
        end else if SameText(s,'trimapp') then
          Result := TrimEx(Clc(gVal(Value)),['(',')'])
        else if SameText(s,'JSONTime') then
        begin
          if (LinkedObj is TTag) then
            with (LinkedObj as TTag) do
            begin
              s := gVal(Value);
              t := Childs.FirstItemByName(s);
              if Assigned(t) then
                Result := UnixToDateTime(StrToInt(t.Attrs.Value('s')));
            end;
        end else if SameText(s,'queue') then
        begin
          //i := 0;
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
        end else if SameText(s,'queueindex') then
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
        end;
      end;
    '%':
      begin
        Result := FPicture.Meta[Value];
      end;
    else
      begin
        raise Exception.Create('unknown value');
      end;
  end;
  except on e:exception do
    raise Exception.Create('Making value error (' + c + Value + '): ' + e.Message);
  end;
  //tmp := VarToStr(Result); //for watching
end;

procedure TDownloadThread.DE(ItemName: String; ItemValue: Variant; LinkedObj: TObject);

  function Clc(Value: variant): variant;
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
        if SameText(Name,'$label') then
          FPicture.DisplayLabel := CalcValue(Value,VE,LinkedObj)
        else if SameText(Name,'$filename') then
          FPicture.PicName := CalcValue(Value,VE,LinkedObj);
      '%':
        if SameText(Name,'%tags') then
        begin
          s := lowercase(Value);
          v1 := CopyTo(s, '(',['""'],['()'],true);
          s := CopyTo(s, ')',['""'],['()'],true);
          if v1 = 'csv' then
          begin
            v1 := CopyTo(s,',',['""'],['()'],true); //GetNextS(s, ',');
            v1 := trim(CalcValue(v1, VE, LinkedObj));
            v2 := trim(CopyTo(s,',',['""'],['()'],true));
            if v2 = '' then
              del := #0
            else
              del := VarToStr(CalcValue(v2,VE,LinkedObj))[1];
            v2 := trim(CopyTo(s,',',['""'],['()'],true));
            if v2 = '' then
              ins := #0
            else
              ins := VarToStr(CalcValue(v2,VE,LinkedObj))[1];
            while v1 <> '' do
            begin
              s := GetNextS(v1, del, ins);
              // FTagList.Add(s);
              FPicList.Tags.Add(s, FPicture);
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
    s,v1,v2,r1,r2,r3: string;
    n: integer;
    fcln: TTPicture;
  begin
    if SameText(Name,'$thread.url') then
      FHTTPRec.Url := Value
    else if SameText(Name,'$thread.xml') then
      FXMLScript.ParseValues(FSectors[Value])
    else if SameText(Name,'$thread.xmlcontent') then
      FHTTPRec.ParseMethod := Value
    else if SameText(Name,'$thread.jsonitem') then
      FHTTPRec.JSONItem := Value
    else if SameText(Name,'$thread.count') then
      FHTTPRec.Count := Trunc(Value)
    else if SameText(Name,'$thread.counter') then
      FHTTPRec.Counter := Trunc(Value)
    else if SameText(Name,'@thread.execute') then
      ProcHTTP
    else if SameText(Name,'@addtag') then
      if Assigned(FPicture) then
        FPicList.Tags.Add(CalcValue(Value,VE,LinkedObj),FPicture)
      else
        raise Exception.Create('Picture not assigned')
    else if SameText(Name,'$picture.displaylabel') then
      FPicture.DisplayLabel := Value
    else if SameText(Name,'$picture.filename') then
      FPicture.PicName := Value
    else if SameText(Name,'$thread.result') then
      FHTTPRec.Theor := Value
    else if SameText(Name,'$thread.referer') then
      FHTTPRec.Referer := Value
{    else if SameText(Name,'$thread.checkcookie') then
      FHTTPRec.CookieStr := Value
    else if SameText(Name,'$thread.login') then
      FHTTPRec.LoginStr := Value      }
    else if SameText(Name,'@createcookie') then
    begin
      s := Value;
      FHTTP.CookieList.ChangeCookie(GetURLDomain(HTTPRec.DefUrl),
      Clc(nVal(s))+'='+Clc(nVal(s)) + ';');
    end
    else if SameText(Name,'@addpicture') then
    begin
      AddPicture;
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
        PicValue(FPicture, v2, v1);
      end
    end
    else if SameText(Name,'@clonepic') then
    begin
      { if FAddPic then
        Synchronize(AddPicture); }
      s := Value;

      r1 := nVal(s);
      r2 := nVal(s);
      //r3 := s;
      fcln := FPicture;

      while CalcValue(r1,VE,LinkedObj) do
      begin
        ClonePicture;
        r3 := s;
        while r3 <> '' do
        begin

          v1 := nVal(r3);
          v2 := nVal(v1,'=');
          if v1 = '' then
          begin
            v1 := gVal(v2);
            v2 := CopyTo(v2, '(');
          end;
          PicValue(FPicture, v2, v1);
        end;

        v2 := r2;
        v1 := nVal(v2,'=');

        DE(v1,CalcValue(v2,VE,LinkedObj),LinkedObj);
        FPicture := fcln;
      end;
      // FAddPic := true;
      // Synchronize(AddPicture);
    end
    else if Name[1] = '%' then
      if Assigned(FPicture) then
        if SameText(Name,'%tags') then
        else
          FPicture.Meta[trim(name,'%')] := Value
      else
        raise Exception.Create('Picture not assigned')
    else if Name[1] = '$' then
    begin
      s := DeleteEx(Name, 1, 1);
      n := Fields.FindField(s);
      if n = -1 then
        Fields.AddField(s, '', ftNone, Value, '')
      else
        Fields.Items[n].resvalue := Value;
    end
    else
      raise Exception.Create(Format(lang('_INCORRECT_DECLORATION_'), [Name]));
  end;

begin
//  if not (LinkedObj is TTagList) then
    try
      ProcValue(ItemName, ItemValue);
    except on e: exception do
        raise Exception.Create(ItemName + '(' + VarToStr(ItemValue) + '): ' + e.Message);
    end;
end;

procedure TDownloadThread.FE(const Item: TScriptSection; LinkedObj: TObject);
begin
  if (Item.Kind in [sikSection,sikGroup]) and Assigned(LinkedObj)
  and (LinkedObj is TTagList) or (LinkedObj is TWorkList) then
    LinkedObj.Free;
end;

procedure TDownloadThread.IdHTTPWorkBegin(ASender: TObject;
  AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin

  if ReturnValue = THREAD_FINISH then
    HTTP.Disconnect;

  FPicture.Size := AWorkCountMax;
  FPicture.Changes := FPicture.Changes + [pcSize];
  Synchronize(PicChanged);
end;

procedure TDownloadThread.IdHTTPWork(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  if ReturnValue = THREAD_FINISH then
    HTTP.Disconnect;

  FPicture.Pos := AWorkCount;
  FPicture.Changes := FPicture.Changes + [pcProgress];
  Synchronize(PicChanged);
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

procedure TDownloadThread.ProcHTTP;
var
  s: string;
  Url: string;
begin

  {$IFDEF NEKODEBUG}FCSFiles.Enter;SaveStrToFile('thread_'+Format('%p',[Pointer(Self)])+': starthttp',debugthreads,true);FCSFiles.Leave;{$ENDIF}

  if (FHTTPRec.Counter >= FHTTPRec.Count)
    and (FHTTPRec.Counter > 0) then
    Exit;

  FRetries := 0;
  while true do
    try
      FBeforeScript.Process(SE, DE, FE, VE, VE);
      // FHTTP.ResponseCode := 0;
      try
        try
          FHTTP.Disconnect;
        except
        end;
        url := '';

        Url := CalcValue(FHTTPRec.Url, VE, nil);

        if SameText(Copy(URL,1,6),'https:') then
        begin
          FHTTP.IOHandler := FSSLHandler;
          FHTTP.ConnectTimeout := 0;
          FHTTP.ReadTimeout := 0;
        end else
          FHTTP.IOHandler := nil;

        FHTTP.Request.Referer := FHTTPRec.Referer;


        s := FHTTP.Get(Url);
        //FHTTP.Disconnect;
        inc(FHTTPRec.Counter);

      except
        on e: Exception do
        begin
          if (FHTTP.ResponseCode = 404){ or (FHTTP.ResponseCode = -1) }then
          begin
            SetHTTPError(url + ': ' + e.Message);
            Break;
          end
          else if FRetries < FMaxRetries then
          begin
            Inc(FRetries);
            Continue;
          end else
          begin
            SetHTTPError(url + ': ' + e.Message);
            Break;
          end;
        end;
      end;

      if SameText(FHTTPRec.ParseMethod,'xml') then
        FXML.Parse(s)
      else if SameText(FHTTPRec.ParseMethod,'json') then
        FXML.JSON(FHTTPREC.JSONItem,s)
      else raise Exception.Create(Format(lang('_UNKNOWNMETHOD_'),[FHTTPRec.ParseMethod]));

      // ----  //
      //FXML.TagList.ExportToFile(ExtractFilePath(paramstr(0))+'log\'+ValidFName(emptyname(url)));
      //SaveStrToFile(url+#13#10+s,ExtractFilePath(paramstr(0))+'log\'+ValidFName(emptyname(url)) + '.src');
      // ---- //

      FXMLScript.Process(SE, DE, FE, VE, VE, FXML.TagList);
      { if FAddPic then
        Synchronize(AddPicture); }
      { if FAddPic then
        AddPicture; }
      // Synchronize(UnlockList);

      FAfterScript.Process(SE, DE, FE, VE, VE);

      {$IFDEF NEKODEBUG}FCSFiles.Enter;SaveStrToFile('thread_'+Format('%p',[Pointer(Self)])+': picstolist',debugthreads,true);FCSFiles.Leave;{$ENDIF}

      if ReturnValue = THREAD_FINISH then
        Break;

      {$IFDEF NEKODEBUG}FCSFiles.Enter;SaveStrToFile('thread_'+Format('%p',[Pointer(Self)])+': picstolist',debugthreads,true);FCSFiles.Leave;{$ENDIF}

      CSData.Enter;
      try
        FLPicList.AddPicList(FPicList);
        FPicsAdded := true;
      finally
        CSData.Leave;
      end;

      {$IFDEF NEKODEBUG}FCSFiles.Enter;SaveStrToFile('thread_'+Format('%p',[Pointer(Self)])+': finishhttp',debugthreads,true);FCSFiles.Leave;{$ENDIF}

      Break;
    except
      on e: Exception do
      begin
        SetHTTPError(e.Message);
        Break;
      end;
    end;
end;

procedure TDownloadThread.ProcPic;
var
  f: TFileStream;
  Dir: string;

begin
  f := nil;
  FRetries := 0;
  while true do
  begin
    try
      Dir := ExtractFileDir(FPicture.FileName);

      FCSFiles.Enter;
      try

        if FileExists(FPicture.FileName) then
        begin
          { FPicture.Size := 1;
            FPicture.Pos; }
          FPicture.Changes := [pcSize, pcProgress];
          Synchronize(PicChanged);
          //FCS.Leave;
          Exit;
        end;

        if not DirectoryExists(Dir) then
        begin
          CreateDirExt(Dir);
        end;

        f := TFileStream.Create(FPicture.FileName, fmCreate);
      finally

        FCSFiles.Leave;
      end;

      try
        //HTTP.Request.ContentRangeStart := f.Size;
        HTTP.Request.Referer := FHTTPRec.Referer;

        if SameText(Copy(HTTPRec.Url,1,6),'https:') then
        begin
          FHTTP.IOHandler := FSSLHandler;
          FHTTP.ConnectTimeout := 0;
          FHTTP.ReadTimeout := 0;
        end else
          FHTTP.IOHandler := nil;

        FPicture.Changes := [pcSize, pcProgress];
        Synchronize(PicChanged);

        HTTP.Get(HTTPRec.Url, f);
        //HTTP.Disconnect;

        if ReturnValue = THREAD_FINISH then
        begin
          FJOB := JOB_CANCELED;

        end;

          //FPicture.Changes := [pcSize, pcProgress];
          //Synchronize(PicChanged);

        if FPicture.Size <> f.Size then
        begin
          f.Free;
          FPicture.Size := 0;
          FPicture.Pos := 0;
          DeleteFile(FPicture.FileName);
          if (ReturnValue = THREAD_FINISH) then
          //begin
          //  FPicture.Changes := [pcSize, pcProgress];
          //  Synchronize(PicChanged);
          //end
          else
            if (FRetries < FMAXRetries) then
            begin
              inc(FRetries);
              Continue;
            end else
              SetHTTPError(HTTPRec.Url + ': ' +lang('_INCORRECT_FILESIZE_'));
        end else
          f.Free;

        Break;

      except
        on e: EIdSocketError do
        begin
          f.Free;
          DeleteFile(FPicture.FileName);
          FPicture.Size := 0;
          FPicture.Pos := 0;
          if e.LastError = 10054 then
            try
              HTTP.Disconnect
            except
            end
          else
            if (FRetries < FMAXRetries) and (ReturnValue <> THREAD_FINISH) then
            begin
              inc(FRetries);
            end else
            begin
              SetHTTPError(HTTPRec.Url + ': ' + e.Message);
              Break;
            end;
        end;
        on e: Exception do
        begin
          f.Free;
          DeleteFile(FPicture.FileName);
          FPicture.Size := 0;
          FPicture.Pos := 0;
          if (HTTP.ResponseCode <> 404)
          and (FRetries < FMAXRetries) and (ReturnValue <> THREAD_FINISH) then
          begin
            inc(FRetries);
          end else
          begin
            SetHTTPError(HTTPRec.Url + ': ' + e.Message);
            Break;
          end;
        end;
      end; //on http except
    except
      on e: Exception do
      begin
        if Assigned(f) then
        begin
          f.Free;
          if fileexists(FPicture.FileName) then
            DeleteFile(FPicture.FileName);
        end;
        FPicture.Size := 0;
        FPicture.Pos := 0;
        SetHTTPError(e.Message);
        Break;
      end;
    end;  //on other except
  end; //while true

end;

procedure TDownloadThread.ProcLogin;

  procedure GetPostStrings(s:string;outs: TStrings);
  var
    tmp: string;
  begin
    s := trim(CopyFromTo(s,'?',''));
    while s <> '' do
    begin
      tmp := GetNextS(s,'&');
      outs.Add(tmp);
    end;
  end;

var
  url: string;
  poststr: string;
//  s: string;
  post: TStringList;
begin
  try
    try
      FHTTP.Disconnect;
    except
    end;
    Url := CalcValue(FHTTPRec.LoginStr, VE, nil);
    if Url = '' then
      Exit;
    if SameText(Copy(URL,1,6),'https:') then
    begin
      FHTTP.IOHandler := FSSLHandler;
      FHTTP.ConnectTimeout := 0;
      FHTTP.ReadTimeout := 0;
    end else
      FHTTP.IOHandler := nil;

    FHTTP.Request.Referer := FHTTPRec.Referer;
    post := TStringList.Create;
    try
      if FHTTPRec.LoginPost = '' then
      begin
        GetPostStrings(Url,post);
        Url := CopyTo(Url,'?');
      end else
      begin
        poststr := CalcValue(FHTTPRec.LoginPost, VE, nil);
        GetPostStrings(poststr,post);
      end;
      FHTTP.Post(Url,post);
    finally
      post.Free;
    end;
  except on e:exception do begin
    SetHTTPError(e.Message);
  end; end;
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
  FErrorString := S;
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
end;

destructor TPictureTag.Destroy;
begin
  FLinked.Free;
  inherited;
end;

// TPictureTagLinkList

function TPictureTagLinkList.FindPosition(Value: String; var index: integer): boolean;
var
  Hi,Lo: integer;

begin
  if Count = 0 then
  begin
    Result := false;
    index := 0;
    Exit;
  end;
  //try
  //  Value := VarAsType(Value,FVariantType);
  //except
  //  on e: exception do
  //    raise Exception.Create('"' + Value + '" - ' + e.Message);
  //end;

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

      Result := (index < Count) and SameText(Value,(Items[index].Name));
  except
    on e: exception do
      raise Exception.Create(e.Message + ' tag(' + Items[index].Name + ') - ('
                           + Value + ')');
  end;
end;

function TPictureTagLinkList.Get(Index: integer): TPictureTag;
begin
  Result := inherited Get(Index);
end;

procedure TPictureTagLinkList.Put(Index: integer; Item: TPictureTag);
begin
  inherited Put(Index, Item);
end;

function TPictureTagLinkList.AsString(cnt: integer = 0): String;
var
  i: integer;
begin
  if cnt = 0 then
    cnt := Count-1
  else
    cnt := Min(cnt,Count-1);
  if cnt > 0 then
  begin
    result := Items[0].Name;
    for i := 1 to cnt do
      result := result + ' ' + Items[i].Name;
  end;
end;

// TPictureTagList

constructor TPictureTagList.Create;
begin
  inherited;
end;

destructor TPictureTagList.Destroy;
begin
  { for i := 0 to Count - 1 do
    Items[i].Free; }
  inherited;
end;

function TPictureTagList.Add(TagName: String; p: TTPicture): Integer;
var
  n: integer;
  t: tPictureTag;
begin
  if not FindPosition(TagName,n) then
  begin
    t := TPictureTag.Create;
    t.Attribute := taNone;
    t.Name := TagName;
    inherited Insert(n,t);
    Result := n;
  end
  else
  begin
    t := Items[n];
    Result := n;
  end;

  if Assigned(p) then
  begin
    p.Tags.Add(t);
    t.Linked.Add(p);
  end;
end;

function TPictureTagList.Find(TagName: String): integer;
{var
  i: integer;  }
begin
{  TagName := lowercase(TagName);
  for i := 0 to Count - 1 do
    if lowercase(Items[i].Name) = TagName then
    begin
      Result := i;
      Exit;
    end;
  Result := -1; }
  if not FindPosition(TagName,Result) then
    Result := -1;
end;

procedure TPictureTagList.ClearZeros;
var
  i: integer;
begin
  i := 0;
  while i < Count - 1 do
    if Items[i].Linked.Count < 1 then
      Delete(i);
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

// TTPicture

procedure TTPicture.Assign(Value: TTPicture; Links: Boolean);
begin
  FChecked := Value.Checked;
  FStatus := Value.Status;
  FDisplayLabel := Value.DisplayLabel;
  FPicName := Value.PicName;
  FExt := Value.Ext;
  FMeta.Clear;
  //FMeta.Assign(Value.Meta);
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
  FChecked := false;
  FRemoved := false;
  FStatus := JOB_NOJOB;
  FParent := nil;
  FMeta := TValueList.Create;
  FLinked := TPictureLinkList.Create;
  FTags := TPictureTagLinkList.Create;
  FDisplayLabel := '';
  FBookMark := 0;
  // FObj := nil;
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

function TTPicture.GetMD5String: string;
begin
  Result := MD5DigestToStr(FMD5);
end;

// make file name
(*
procedure TTPicture.MakeFileName(Format: String);

// check names
  function ParamCheck(s2: String; main: Boolean): String;
  var
    n: TListValue;
    s: string;
    t: integer;

  begin
    s := GetNextS(s2,':');
    if main then
      if SameText(s, 'rname') then
        Result := Resource.Name
      else if SameText(s,'short') then
        Result := Resource.Short
      else if SameText(s, 'fname') then
        Result := ValidFName(FPicName)
      else if SameText(s, 'ext') then
        Result := Ext
      else if SameText(s, 'rootdir') then
        Result := ExtractFileDir(paramstr(0))
      else if SameText(s,'tag') then
        Result := ValidFName(VarToStr(Resource.Fields['tag']))
      else
        Result := s
    else
    begin
      n := Meta.FindItem(s) as TListValue;

      if n = nil then
        if s2 <> '' then
          Result := s+':'+s2
        else
          Result := s
      else
      begin
        if s2 = '' then
          Result := ValidFName(VarToStr(n.Value))
        else if VarIsType(n.Value,varDate) then
            Result := ValidFName(FormatDateTime(s2,n.Value))
          else
          begin
            t := CharPosEx(s2,['d','e','f','g','n','m','p','s','u','x',
                               'D','E','F','G','N','M','P','S','U','X'],[]);
            case lowercase(s2[t])[1] of
              'd','u','x':
                Result := ValidFName(SysUtils.Format('%'+s2,[Trunc(n.Value)]));
              'e','f','g','n','m':
                Result := ValidFName(SysUtils.Format('%'+s2,[Double(n.Value)]));
              's':
                Result := ValidFName(SysUtils.Format('%'+s2,[VarToStr(n.Value)]));
              'p':
              begin
                s2[t] := 'x';
                Result := ValidFName(SysUtils.Format('%'+s2,[Trunc(n.Value)]));
              end;
                //s2[2] := 'x';
            end;
            //Result := ValidFName(SysUtils.Format('%'+s2,[VarToStr(n.Value])));
          end;
      end;
    end;
  end;
// check keywords: $main$, %editional%, if b then result = '' if key = ''
  function ParseValues(s: String; b: Boolean = true): String;
  var
    i, n: integer;
    c: Boolean;
    key, rsl: string;
    isl: array of string;

  begin
    c := false;
    if not b then
    begin
      SetLength(isl,1);
      isl[0] := '<>';
    end else
      SetLength(isl,0);

    n := CharPosEx(s, ['$', '%'], isl);

    while n <> 0 do
    begin
      i := n;
      n := CharPosEx(s, ['$', '%'], isl, i + 1);

      if n = 0 then
        Break
      else if s[i] <> s[n] then
        Continue;

      key := Copy(s, i + 1, n - i - 1);
      rsl := ParamCheck(key, s[i] = '$');

      if rsl <> key then
      begin
        if not c and (rsl <> '') then
          c := true;
        s := StringReplace(s, s[i] + key + s[n], rsl,[]);
      end
      else
        Continue;

      n := CharPosEx(s, ['$', '%'], isl, i + 1);
    end;

    if b and not c then
      Result := ''
    else
      Result := s;

  end;

// check "<>" sections
  function ParseSections(s: string): string;
  var
    i, n, l: integer;
  begin
    s := ParseValues(s, false);

    l := length(s);
    n := PosEx('<', s);
    i := 1;

    Result := '';

    while n <> 0 do
    begin
      Result := Result + Copy(s, i, n - i);
      i := n;

      n := PosEx('>', s, i + 1);

      if n <> 0 then
      begin
        Result := Result + ParseValues(Copy(s, i + 1, n - i - 1));
        i := n + 1;
      end;

      n := PosEx('<', s, i);
    end;

    Result := Result + Copy(s, i, l - i + 1);
  end;

begin
  if Format = '' then
    if FResource.NameFormat = '' then
      FFileName := ''
    else
      Format := FResource.NameFormat;
{    if FResource.NameFormat = '' then
      FFileName := ''
    else
      FFileName := ParseSections(FResource.NameFormat)
  else
    FFileName := ParseSections(Format);  }
  FFileName := ParseSections(Format);


  if ExtractFileName(FFileName) = '' then
    FFileName := FFileName + FPicName + '.' + FExt
  else if System.Pos('$ext$',ExtractFileName(lowercase(Format))) = 0 then
    FFileName := FFileName + '.' + FExt;
{  else if trim(ExtractFileExt(FFileName),'.') <> '' then
    ChangeFileExt(FFileName,'.'+FExt);  }
end;
*)

procedure TTPicture.SetParent(Item: TTPicture);
begin
  if Parent = Item then
    Exit;
  if (Parent <> nil) and (not Parent.Removed) then
    Parent.Linked.Remove(Self);
  Parent := Item;
  if Parent <> nil then
    Parent.Linked.Add(Self);
end;

procedure TTPicture.SetPicName(Value: String);
begin
  FExt := trim(ExtractFileExt(Value), '.');
  if SameText(FExt,'jpeg') then
    FExt := DeleteEx(FExt,3,1);
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

function TPictureLinkList.Get(Index: integer): TTPicture;
begin
  Result := inherited Get(Index);
end;

procedure TPictureLinkList.Put(Index: integer; Item: TTPicture);
begin
  inherited Put(Index, Item);
end;

procedure TPictureLinkList.BeginAddList;
begin
  if Assigned(FBeforePictureList) then
    FBeforePictureList(Self);
end;

procedure TPictureLinkList.CheckExists;
var
  i: integer;
begin
  for i := 0 to Count -1 do
  begin
    if Items[i].Checked and FileExists(Items[i].FileName) then
    begin
      Items[i].Checked := false;
      //if Assigned(Items[i].OnPicChanged) then
      //  Items[i].OnPicChanged(Items[i],[pcChecked]);
    end;
  end;
end;

function TPictureLinkList.AllFinished(incerrs: Boolean = true): Boolean;
var
  i: integer;
begin
  { if not(FLastAdded.status in [JOB_ERROR,JOB_FINISHED]) then
    begin
    Result := false;
    Exit;
    end; }

  for i := FFinishCursor to Count - 1 do
    if (incerrs and not(Items[i].Status in [JOB_ERROR, JOB_FINISHED, JOB_SKIP])
      or not incerrs and not(Items[i].Status in [JOB_FINISHED, JOB_SKIP])) and
      Items[i].Checked then
    begin
      FFinishCursor := i;
      Result := false;
      Exit;
    end;

  FFinishCursor := Count;
  FCursor := Count;
  Result := true;
end;

function TPictureLinkList.NextJob(Status: integer): TTPicture;
var
  i: integer;

begin
  if FCursor < Count then
  begin
    Result := nil;

    for i := FCursor to Count-1 do
      if (Items[i].Status = JOB_NOJOB) and (Items[i].Checked) then
      begin
        Items[i].Status := JOB_INPROGRESS;
        Result := Items[i];
        FCursor := i + 1;
//        FCursor := i;
        Break;
      end;

    for i := FCursor to Count-1 do
      if (Items[i].Status = JOB_NOJOB) and (Items[i].Checked) then
      begin
        FCursor := i;
        Exit;
      end;

    FCursor := Count;
    //Result := nil;
  end
  else
    Result := nil;
end;

function TPictureLinkList.eol: Boolean;
begin
  Result := not(FCursor < Count);
end;

// TTPictureList

function TPictureList.Add(APicture: TTPicture; Resource: TResource): integer;
begin
  Result := inherited Add(APicture);
  APicture.OnPicChanged := OnPicChanged;
  APicture.Resource := Resource;
  APicture.List := Self;
  {if (FNameFormat <> '')
  and (APicture.Resource.NameFormat <> '')
  and (APicture.FileName <> '') then
    APicture.MakeFileName(FNameFormat);}
  //MakePicFileName(Result, NameFormat);
  //if Assigned(FOnAddPicture) then
  //  FOnAddPicture(APicture);
end;

function TPictureList.DirNumber(Dir: String): word;
var
  n: integer;
  v: PWORD;
begin
  dir := lowercase(dir);
  n := FDirList.IndexOf(dir);
  if n = -1 then
  begin
    New(v);
    v^ := 0;
    n := FDirList.Add(dir);
    FDirList.Objects[n] := TObject(v);
  end else
  begin
    v := PWORD(FDirList.Objects[n]);
    v^ := v^ + 1;
  end;

  Result := v^;
end;

procedure TPictureList.disposeDirList;
var
  v: PWORD;
  i: integer;
  //s: PString;
begin
  for i := 0 to FDirList.Count -1 do
  begin
    v := PWORD(FDirList.Objects[i]);
    Dispose(v);
  end;

  for i := 0 to FFileNames.Count -1 do
  begin
    v := PWORD(FFileNames.Objects[i]);
    Dispose(v);
  end;

end;

function TPictureList.fNameNumber(FileName: String): word;
var
  n: integer;
  v: PWORD;
begin
  //FileName := lowercase(FileName);
  //n := FDirList.IndexOf(FileName);
  if strFind(FileName,FFileNames,n) then
  //begin
  //  New(v);
  //  v^ := 0;
  //  n := FDirList.Add(dir);
  //  FDirList.Objects[n] := TObject(v);
  //end else
  begin
    v := PWORD(FFileNames.Objects[n]);
    v^ := v^ + 1;
    Result := v^;
  end else
    Result := 0;

end;

procedure TPictureList.SetPicChange(Value: TPicChangeEvent);
var
  i: integer;
begin
  FPicChange := Value;
  for i := 0 to Count - 1 do
    Items[i].OnPicChanged := Value;
end;

procedure TPictureList.AddfName(FileName: String);
var
  n: integer;
  v: PWORD;
begin
  if strFind(FileName,FFileNames,n) then
    if Assigned(FSameNames) then
      FSameNames(Self,FileName)
    else
  else
  begin
    New(v);
    v^ := 0;
    FFileNames.Insert(n,FileName);
    FFileNames.Objects[n] := TObject(v);
  end;
end;

procedure TPictureList.AddPicList(APicList: TPictureList);
var
  i, j{, v}: integer;
  n: DWORD;
  t, ch: TTPicture;
begin
  i := 0;
  n := GetTickCount;
  try
    while i < APicList.Count do
      if not CheckDoubles(APicList[i]) then
      begin
        if not Assigned(APicList[i].Parent) then
        begin
          t := CopyPicture(APicList[i],false);
          //Inc(FParentsCount);
          t.BookMark := FParentsCount;

          for j := 0 to APicList[i].Linked.Count - 1 do
            if not CheckDoubles(APicList[i].Linked[j]) then
            begin
              ch := CopyPicture(APicList[i].Linked[j]);
              //Inc(FChildsCount);
              ch.BookMark := FChildsCount;
              //if Orig then
              //  APicList[i].Linked[j].Orig := ch;
              t.Linked.Add(ch);
              ch.Parent := t;
            end;
          //if Orig then
          //  APicList[i].Orig := t;

        end;
        inc(i);
      end
      else
      begin
        //if Orig then
        //  APicList.Delete(i)
        //else
          inc(i);
        Inc(FPicCounter.IGN);
      end;

{
    if Orig then
      for j := 0 to APicList.Tags.Count-1 do
      begin
        if Tags.FindPosition(APicList.Tags[j].Name,v) then
          APicList.Tags[j].Tag := v
        else
          APicList.Tags[j].Tag := -1;
      end;
}

  finally
    FDoublesTickCount := GetTickCount - n;
  end;
end;

procedure TPictureList.AddPicMeta(pic: TTPicture; MetaName: String;
  MetaValue: Variant);
var
  v: PVariant;
  n: integer;
  p: TMetaList;
begin
  try
    p := FMetaContainer[MetaName];

    if p = nil then
    begin
      p := TMetaList.Create;
      FMetaContainer[MetaName] := p;
    end;

    if p.FindPosition(MetaValue,n) then
      v := p[n]
    else
      v := p.Add(MetaValue,n);

    Pic.Meta.SetLink(MetaName,v);
  except on e: Exception do
    raise Exception.Create({pic.Meta['url'] + #13#10 + }MetaName + ': '
                         + e.Message);
  end;
end;

function TPictureList.CopyPicture(Pic: TTPicture; Child: boolean): TTPicture;
var
  i: integer;
begin
  if not Assigned(Pic) then
  begin
    Result := nil;
    Exit;
  end;

  Result := TTPicture.Create;
  Result.Assign(Pic);

  for i := 0 to Pic.Meta.Count -1 do
    AddPicMeta(Result,Pic.Meta.Items[i].Name,Pic.Meta.Items[i].Value);

  for i := 0 to Pic.Tags.Count - 1 do
    Tags.Add(Pic.Tags[i].Name, Result);

  if Child then
  begin
    i := FParentsCount + FChildsCount;
    Insert(i,Result);
    inc(FChildsCount);
  end else
  begin
    i := FParentsCount;
    Insert(i,Result);
    inc(FParentsCount);
  end;

  Result.Resource := Pic.Resource;
  Result.Resource.PictureList.Add(Result);
  Result.OnPicChanged := OnPicChanged;
  Result.List := Self;
  //Result.MakeFileName(FNameFormat);

  MakePicFileName(i,NameFormat);
  //if Assigned(FOnAddPicture) then
  //  FOnAddPicture(Result);
end;

constructor TPictureList.Create;
begin
  inherited;
  FTags := TPictureTagList.Create;
  FMetaContainer := TTagedList.Create;
  FDirList := TStringList.Create;
  FFileNames := TStringList.Create;
  FMakeNames := true;
  FIgnoreList := nil;
  FParentsCount := 0;
  FChildsCount := 0;
end;

destructor TPictureList.Destroy;
begin
  Clear;
  FTags.Free;
  DeallocateMeta;
  FMetaContainer.Free;
  disposeDirList;
  FDirList.Free;
  FFileNames.Free;
  inherited;
end;

procedure TPictureList.MakePicFileName(index: integer; Format: String);

var
  fncounter: byte;
  fnoext: boolean;

{
  function FolderN(s: string; index: integer): integer;
  var
    i,l: integer;
//    v: PWord;
  begin
    l := length(s);
    s := lowercase(s);
    result := 0;
    for i := 0 to index-1 do
      if SameText(s,Copy(Items[i].FileName,1,l)) then
        inc(result);
  end;
}

// check names
  function ParamCheck(pic: TTPicture; bfr,bfr2,s2,aft,aft2: String; level: byte;
    main,b: Boolean; var Value: Variant): boolean;

    function formatstr(value: variant; aformat: string; d: boolean): string;
    var
      t: integer;
    begin
      if (aformat = '') then
        result := ValidFName(value,d)
      else
        if VarIsType(value,varDate) then
            Result := ValidFName(FormatDateTime(aformat,value),d)
          else
          begin
            t := CharPosEx(s2,['d','e','f','g','n','m','p','s','u','x',
                               'D','E','F','G','N','M','P','S','U','X'],[],[]);
            case lowercase(s2[t])[1] of
              'd','u','x':
                Result := ValidFName(SysUtils.Format('%'+s2,[Trunc(value)]),d);
              'e','f','g','n','m':
                Result := ValidFName(SysUtils.Format('%'+s2,[Double(value)]),d);
              's':
                Result := ValidFName(SysUtils.Format('%'+s2,[VarToStr(value)]),d);
              'p':
              begin
                s2[t] := 'x';
                Result := ValidFName(SysUtils.Format('%'+s2,[Trunc(value)]),d);
              end;
                //s2[2] := 'x';
            end;
            //Result := ValidFName(SysUtils.Format('%'+s2,[VarToStr(n.Value])));
          end;
    end;

  var
    n: TListValue;
    s,p,tmp: string;
    c: integer;
    d: boolean;

  begin
    Result := true;
    tmp := s2;
    s := GetNextS(s2,':');
    p := CopyFromTo(s,'(',')',true);
    if p <> '' then
      s := CopyTo(s,'(');
    d := false;
    if main then
      if SameText(s,'nn') then
        Value := IndexOf(pic) + 1
      else if SameText(s,'fnn') then
      begin
        if p <> '' then
          c := Max(StrToInt(p),1)
        else
          c := 1;
        Value := (DirNumber(ExtractFilePath(bfr+bfr2)) div c) + 1
      end else if SameText(s,'fn') then
        if level < 1 then
        begin
          inc(fncounter);
          Value := null;
          Result := false;
          Exit;
        end else
          if fncounter = 1 then
          begin
            Value := 0;
            repeat

              if b and (Value = 0) then
                p := bfr + aft
              else
                p := bfr + bfr2 + formatstr(Value,s2,false) + aft2 + aft;

              if fnoext then
                p := p + '.' + pic.Ext;

              c := FNameNumber(p);
              if Value > 0 then
              begin
                Value := c + 1;
                c := 0;
              end else
                if c > 0 then
                  inc(Value);
            until (c = 0);

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
            end else
              Value := 0;
          end
      else if SameText(s,'rname') then
        Value := pic.Resource.Name
      else if SameText(s,'short') then
        Value := pic.Resource.Short
      else if SameText(s, 'fname') then
        Value := ValidFName(pic.PicName)
      else if SameText(s, 'ext') then
        Value := pic.Ext
      else if SameText(s, 'rootdir') then
      begin
        Value := ExtractFileDir(paramstr(0));
        d := true;
      end
      else if SameText(s,'tag') then
        Value := VarToStr(pic.Resource.Fields['tag'])
      else if SameText(s,'tags') then
      begin
        if p = '' then
          c := 0
        else
          c := StrToInt(p);
        Value := Copy(pic.Tags.AsString(c),1,200);
      end

      else
      begin
        Value := null;
        Result := false;
        Exit;
      end
    else
    begin
      n := pic.Meta.FindItem(s) as TListValue;

      if n = nil then
      begin
        Value := null;
        Result := false;
        Exit;
      end else
        Value := n.Value;
    end;

    Value := formatstr(Value,s2,d);
  end;
// check keywords: $main$, %editional%, if b then result = '' if key = ''
  function ParseValues(pic: TTPicture; bfr,s,aft: String; level: byte; b: Boolean = true): String;
  var
    i, n: integer;
    c,hghlvl: Boolean;
    key: string;
    rsl: Variant;
    isl: array of string;
    brk: array of string;
  begin
    c := false;
    hghlvl := false;
    SetLength(isl,0);
    if not b then
    begin
      SetLength(brk,1);
      brk[0] := '<>';
    end else
      SetLength(brk,0);

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
      if ParamCheck(pic,bfr,Copy(s,1,i-1),
              key,
              aft,Copy(s,n + 1, length(s) - n - 1), level, s[i] = '$', b,rsl)
      then
      begin
        if not c and (VarToStr(rsl) <> '') then
          c := true;
        s := StringReplace(s, s[i] + key + s[n], VarToStr(rsl),[]);
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
      if not c then
        if hghlvl then
          Result := '<' + s + '>'
        else
          Result := ''
      else
        Result := s
    else
      Result := s;

  end;

// check "<>" sections
  function ParseSections(pic: TTPicture; s: string): string;
  var
    i, n, l, level: integer;
  begin
    //s := ParseValues(pic,s, false);
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
        Result := Result + ParseValues(pic, Result,
                            Copy(s, i, n - i),
                            Copy(s, n + 1, l - n -1),level,false);
        i := n;

        n := PosEx('>', s, i + 1);

        if n <> 0 then
        begin
          Result := Result + ParseValues(pic,Result,
                              Copy(s, i + 1, n - i - 1),
                              Copy(s, n + 1, l - n -1),level);
          i := n + 1;
        end;

        n := PosEx('<', s, i);
      end;

      Result := Result + ParseValues(pic,Result,
                          Copy(s, i, l - i + 1),'',level,false);
      s := Result;
    end;
  end;

  procedure MakeName(pic: TTPicture);
  begin
    //pic := Items[index];

    if Format = '' then
      if NameFormat = '' then
        if pic.Resource.NameFormat = '' then
          pic.FileName := ''
        else
          Format := pic.Resource.NameFormat
      else
        Format := NameFormat;
  {    if FResource.NameFormat = '' then
        FFileName := ''
      else
        FFileName := ParseSections(FResource.NameFormat)
    else
      FFileName := ParseSections(Format);  }
    fnoext := System.Pos('$ext$',ExtractFileName(lowercase(Format))) = 0;

    pic.FileName := ParseSections(pic,Format);

    if ExtractFileName(pic.FileName) = '' then
      pic.FileName := pic.FileName + ParseSections(pic,'$fname$<($fn$)>.$ext$')
    else if fnoext then
      pic.FileName := pic.FileName + '.' + pic.Ext;

    AddfName(pic.FileName);

  {  else if trim(ExtractFileExt(FFileName),'.') <> '' then
      ChangeFileExt(FFileName,'.'+FExt);  }
  end;

{
  procedure disposelist;
  var
    i: integer;
    v: PWORD;
  begin
    for i := 0 to folderlist.Count-1 do
    begin
      v := PWORD(folderlist.Objects[i]);
      Dispose(v);
    end;
  end;
}

var
  i: integer;

begin
  if not MakeNames then
    Exit;

  if index = -1 then
    for i := 0 to Count-1 do
      MakeName(Items[i])
  else
    MakeName(Items[index]);
end;

procedure TPictureList.Notify(Ptr: Pointer; Action: TListNotification);
var
  p: TTPicture;
  i: integer;
begin
  case Action of
    lnDeleted:
      begin
        p := Ptr;
        p.Removed := true;
{        if Assigned(p.OnPicChanged) then
          p.OnPicChanged(p, [pcDelete]);   }
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
  i: integer;
  p: TMetaList;
begin
  for i := 0 to FMetaContainer.Count-1 do
  begin
    p := FMetaContainer.Items[i].Value;
    p.Free;
  end;
  FMetaContainer.Clear;
end;

procedure TPictureLinkList.Reset;
var
  i: integer;

begin
  ResetPicCounter;

  FFinishCursor := 0;

  i := 0;

  for i := i to Count - 1 do
    if (Items[i].Checked) then
      Break
    else
    begin
      inc(FPicCounter.UNCH);
{      if Assigned(FLinkedOn) then
        inc(FLinkedOn.FPicCounter.SKP)
      else if Items[i].List <> Self then
        inc(Items[i].List.FPicCounter.SKP);   }
    end;

  FCursor := i;

  for i := i to Count - 1 do
    if (Items[i].Checked) then
    begin
      Items[i].Status := JOB_NOJOB;
      if Items[i].Size <> 0 then
      begin
        Items[i].Pos := 0;
        Items[i].Size := 0;
        if Assigned(Items[i].OnPicChanged) then
          Items[i].OnPicChanged(Items[i],[pcSize,pcProgress]);
      end;
    end else
    begin
      inc(FPicCounter.UNCH);
{      if Assigned(FLinkedOn) then
        inc(FLinkedOn.FPicCounter.SKP)
      else if Items[i].List <> Self then
        inc(Items[i].List.FPicCounter.SKP);
      Items[i].OnPicChanged(Items[i],[pcSize,pcProgress]);  }
    end;

  AllFinished;
end;

procedure TPictureLinkList.ResetCursors;
begin
  FCursor := 0;
  FFinishCursor := 0;

  ResetPicCounter;
  AllFinished;
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
  end;
end;

function TPictureList.CheckDoubles(pic: TTPicture): boolean;
var
  i: integer;
  //source,rule,srcfield,checkfield
  sstr, rstr, srfield, chfield  : String;
  v1: Variant;
  m: TMetaList;
  pos: integer;
begin
  result := false;
  for i := 0 to length(FIgnoreList) - 1 do
  begin
    sstr := trim(FIgnoreList[i][1]);
    while sstr <> '' do
    begin
      result := false;
      rstr := trim(CopyTo(sstr,';',['""'],[],true));
      srfield := trim(CopyTo(rstr,'=',['""'],[],true));
      v1 := Pic.Meta[srfield];
      if VarToStr(v1) <> '' then
        while rstr <> '' do
        begin
          chfield := trim(CopyTo(rstr,',',['""'],[],true));
          m := FMetaContainer[chfield];
          if Assigned(m) and (m.FindPosition(v1,pos)) then
          begin
            Result := true;
            break;
          end;
        end;

      if not result then
        break;
    end;

    if result then
      Break;

{
    s1 := Pic.Meta[FIgnoreList[i][0]];
    if (VarToStr(s1) <> '') then
    begin
      try
        m := FMetaContainer[FIgnoreList[i][1]];
        if Assigned(m) and (m.FindPosition(s1,pos)) then
        begin
          Result := true;
          Exit;
        end;
      except on e: exception do
        raise Exception.Create('Doubles searching('+FIgnoreList[i][0] + ','
                               + FIgnoreList[i][1] + '): ' + e.Message);
      end;
    end;
}
  end;
  //Result := false;
end;

procedure TPictureList.Clear;
begin
  inherited Clear;
  ResetPicCounter;
  FTags.Clear;
  DeallocateMeta;
  FMetaContainer.Clear;
  FCursor := 0;
  FParentsCount := 0;
  FChildsCount := 0;
end;

// TRESOUCEFIELDS

procedure TResourceFields.Assign(List: TResourceFields;
  AOperator: TListAssignOp);
var
  i: integer;
  p: PResourceField;

begin
  case AOperator of
    laCopy:
      begin
        Clear;
        Capacity := List.Capacity;
        for i := 0 to List.Count - 1 do
        begin
          New(p);
          with List.Items[i]^ do
            AddField(resname, restitle, restype, resvalue, resitems);
          Add(p);
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

function TResourceFields.FindField(resname: String): integer;
var
  i: integer;
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
begin
  case Action of
    lnDeleted:
      Dispose(Ptr);
  end;
end;

function TResourceFields.Get(Index: integer): PResourceField;
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
  i: integer;
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
  i: integer;

begin
  ItemName := lowercase(ItemName);
  for i := 0 to Count - 1 do
    if Items[i].resname = ItemName then
    begin
      Items[i].resvalue := Value;
      Exit;
    end;
  raise Exception.Create(Format(lang('_NO_FIELD_'), [ItemName]));
end;

function TResourceFields.AddField(resname: string; restitle: string;
  restype: TFieldType; resvalue: Variant; resitems: String): integer;
var
  p: PResourceField;
begin
  if resname = '' then
  begin
    Result := -1;
    Exit;
  end;
  New(p);
  p.resname := lowercase(resname);
  p.restype := restype;
  p.resvalue := resvalue;
  p.resitems := resitems;
  Result := Add(p);
end;

procedure TThreadHandler.CreateThreads(acount: integer = -1);
var
  d: TDownloadThread;

begin
  if acount = -1 then
    acount := FThreadCount;
  FFinishQueue := false;
  FFinishThreads := false;
  // FQueue.Clear;
  while Count < acount do
  begin
    inc(FCount);
    d := TDownloadThread.Create;
    d.CSData := FCSData;
    d.CSFiles := FCSFiles;
    d.FreeOnTerminate := true;
    d.Finish := Finish;
    d.OnTerminate := ThreadTerminate;
    if Proxy.UseProxy then
      with d.HTTP.ProxyParams do
      begin
        ProxyServer := Proxy.Host;
        ProxyPort := Proxy.Port;
        BasicAuthentication := Proxy.Auth;
        ProxyUserName := Proxy.Login;
        ProxyPassword := Proxy.Password;
      end;
    d.HTTP.CookieList := FCookie;
    d.MaxRetries := Retries;
    Add(d);
  end;
end;

function TThreadHandler.Finish(t: TDownloadThread): integer;
begin
  if t.STOPERROR then
  begin
    if Assigned(FOnError) then
      FOnError(Self, t.Error);
    t.STOPERROR := false;
  end;

  if FFinishThreads then
    Result := THREAD_FINISH
    // else if FQueue.Count > 0 then
  else if CreateJob(t) then
  begin
    { FQueue[0].CreateJob(t);
      FQueue.Delete(0); }
    Result := THREAD_START;
  end
  else if FFinishQueue then
    Result := THREAD_FINISH
  else
    Result := THREAD_STOP;
end;

procedure TThreadHandler.FinishQueue;
var
  i: integer;
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
  i: integer;
  p: TDownloadThread;
  l: TList;

begin
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
      if Force and p.HTTP.Connected then
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
  if (FCount = 0) and Assigned(FOnAllThreadsFinished) then
    FOnAllThreadsFinished(Self);
end;

{ procedure TThreadHandler.AddToQueue(R: TResource);
  begin
  FQueue.Add(R);
  CheckIdle;
  end; }

procedure TThreadHandler.CheckIdle(ALL: Boolean = false);
var
  l: TList;
  i: integer;
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

function strFind(Value: string; list: TStringList; var index: integer): boolean;
var
  Hi,Lo: integer;

begin
  if list.Count = 0 then
  begin
    Result := false;
    index := 0;
    Exit;
  end;
  //try
  //  Value := VarAsType(Value,FVariantType);
  //except
  //  on e: exception do
  //    raise Exception.Create('"' + Value + '" - ' + e.Message);
  //end;

  Hi := list.Count;
  Lo := 0;
  index := Hi div 2;

  try
    while (Hi - Lo) > 0 do
    begin
      if Value = list[index] then
        Break
      else if Value < list[index] then
        Hi := index - 1
      else
        Lo := index + 1;

      index := Lo + ((Hi - Lo) div 2);
    end;

    if (index < list.Count) and (Value > list[index]) then
      inc(index);

    Result := (index < list.Count) and SameText(Value,(list[index]));
  except
    on e: exception do
      raise Exception.Create(e.Message + ' tag(' + list[index] + ') - ('
                           + Value + ')');
  end;
end;

initialization

{$IFDEF NEKODEBUG}
  debugpath := ExtractFilePath(paramstr(0)) + 'log\';
  CreateDirExt(debugpath);
  debugthreads := debugpath + 'threads.txt';
  if fileexists(debugthreads) then
    DeleteFile(debugthreads);
{$ENDIF}

end.
