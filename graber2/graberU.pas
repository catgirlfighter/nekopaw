unit graberU;

interface

uses Classes, Messages, Windows, SysUtils, SyncObjs, Variants, VarUtils,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  MyXMLParser, DateUtils, MyHTTP, StrUtils, md5, DB;

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
  end;

  TFormatRec = record
    ListFormat: String;
    PicFormat: String;
  end;

  TSettingsRec = record
    Proxy: TProxyRec;
    Downl: TDownloadRec;
    Formats: TFormatRec;
    UPDServ: String;
    OneInstance: Boolean;
    TrayIcon: Boolean;
    HideToTray: Boolean;
    SaveConfirm: Boolean;
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
  TScriptSectionList = class;

  TScriptEvent = procedure(const Parent: String; const Parametres: TValueList;
    var LinkedObj: TObject) of object;

  TValueEvent = procedure(const ValS: Char; const Value: String;
    var Result: Variant; var LinkedObj: TObject) of object;

  TDeclorationEvent = procedure(Values: TValueList; LinkedObj: TObject)
    of object;

  TFinishEvent = procedure(Parent: String; LinkedObj: TObject) of object;

  TScriptSection = class(TObject)
  private
    FParent: String;
    FParametres: TValueList;
    FDeclorations: TValueList;
    FConditions: TScriptSectionList;
    FChildSections: TScriptSectionList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ParseValues(s: string);
    procedure Process(const SE: TScriptEvent; const DE: TDeclorationEvent;
      FE: TFinishEvent; const VE: TValueEvent; PVE: TValueEvent = nil;
      LinkedObj: TObject = nil);
    procedure Clear;
    procedure Assign(s: TScriptSection);
    function NotEmpty: Boolean;
    property Parent: String read FParent write FParent;
    property Parametres: TValueList read FParametres;
    property Conditions: TScriptSectionList read FConditions;
    property Declorations: TValueList read FDeclorations;
    property ChildSections: TScriptSectionList read FChildSections;
  end;

  TScriptSectionList = class(TList)
  private
    function Get(Index: integer): TScriptSection;
  public
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
    procedure Assign(s: TScriptSectionList);
    property Items[Index: integer]: TScriptSection read Get; default;
  end;

  TDownloadThread = class;
  TResourceLinkList = class;
  TResource = class;
  TTPicture = class;
  TPictureLinkList = class;
  TPictureList = class;
  // TResource = class;

  TFieldType = (ftNone, ftString, ftReadOnly, ftNumber, ftCombo, ftCheck);

  PResourceField = ^TResourceField;

  TResourceField = record
    resname: string;
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
    function AddField(resname: string; restype: TFieldType; resvalue: Variant;
      resitems: String): integer;
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
    FCS: TCriticalSection;
    FResource: TResource;
    FMaxRetries: Integer;
    FRetries: integer;
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
    procedure SE(const Parent: String; const Parametres: TValueList;
      var LinkedObj: TObject);
    procedure VE(const ValS: Char; const Value: String; var Result: Variant;
      var LinkedObj: TObject);
    procedure DE(Values: TValueList; LinkedObj: TObject);
    procedure FE(Parent: String; LinkedObj: TObject);
    procedure IdHTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure IdHTTPWork(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure PicChanged;
  public
    procedure Execute; override;
    constructor Create;
    destructor Destroy; override;
    procedure AddPicture;
    procedure ProcHTTP;
    procedure SetSectors(Value: TValueList);
    procedure LockList;
    procedure UnlockList;
    procedure ProcPic;
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
    property CSection: TCriticalSection read FCS write FCS;
    property Resource: TResource read FResource write FResource;
    property MaxRetries: integer read FMaxRetries write FMaxRetries;
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
    FCS: TCriticalSection;
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
  public
    Attribute: TTagAttribute;
    Name: String;
    constructor Create;
    destructor Destroy; override;
    property Linked: TPictureLinkList read FLinked;
  end;

  TPictureTagLinkList = class(TList)
  protected
    function Get(Index: integer): TPictureTag;
    procedure Put(Index: integer; Item: TPictureTag);
  public
    property Items[Index: integer]: TPictureTag read Get write Put; default;
    property Count;
  end;

  TPictureTagList = class(TPictureTagLinkList)
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(TagName: String; p: TTPicture): TPictureTag;
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
    FOrig: TTPicture;
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
    procedure MakeFileName(Format: String);
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
    property Orig: TTPicture read FOrig write FOrig;
    property Resource: TResource read FResource write FResource;
    property Size: Int64 read FSize write FSize;
    property Pos: Int64 read FPos write FPos;
    property OnPicChanged: TPicChangeEvent read FPicChange write FPicChange;
    property Changes: TPicChanges read FChanges write FChanges;
    property BookMark: Integer read FBookMark write FBookMark;
    // property Obj: TObject read FObj write FObj;
  end;

  TPicCounter = record
    OK,ERR,SKP,IGN,EXS,FSH: Word;
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

  TPictureList = class(TPictureLinkList)
  private
    FTags: TPictureTagList;
    FOnAddPicture: TPictureEvent;
    //FCheckDouble: TCheckFunction;
    FNameFormat: String;
    FPicChange: TPicChangeEvent;
    FMetaContainer: TTagedList;
    FIgnoreList: TDSArray;
    FParentsCount,FChildsCount: integer;
    FDoublesTickCount: integer;
    procedure SetPicChange(Value: TPicChangeEvent);
  protected
    procedure DeallocateMeta;
    procedure AddPicMeta(pic: TTPicture; MetaName: String; MetaValue: Variant);
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
    property Link;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(APicture: TTPicture; Resource: TResource): integer;
    procedure AddPicList(APicList: TPictureList; Orig: Boolean);
    function CopyPicture(Pic: TTPicture; Child: boolean = false): TTPicture;
    function CheckDoubles(pic: TTPicture): boolean;
//    function TrackPos(Value: integer): integer;
    property Tags: TPictureTagList read FTags;
    property Items;
    property Count;
    //property Resource;
    property OnAddPicture: TPictureEvent read FOnAddPicture write FOnAddPicture;
    //property CheckDouble: TCheckFunction read FCheckDouble write FCheckDouble;
    property NameFormat: String read FNameFormat write FNameFormat;
    procedure Clear; override;
    property OnPicChanged: TPicChangeEvent read FPicChange write SetPicChange;
    property IgnoreList: TDSArray read FIgnoreList write FIgnoreList;
    property Meta: TTagedList read FMetaContainer;
    property ParensCount: integer read FParentsCount;
    property ChildsCount: integer read FChildsCount;
    property DoublestickCount: integer read FDoublesTickCount;
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
    procedure DeclorationEvent(Values: TValueList; LinkedObj: TObject);
    function JobComplete(t: TDownloadThread): integer;
    function StringFromFile(fname: string): string;
    function PicJobComplete(t: TDownloadThread): integer;
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
    property FileName: String read FFileName;
    property Name: String read FResName write FResName;
    // property Url: String read FURL;
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
    procedure SetOnError(Value: TLogEvent);
    function GetPicsFinished: Boolean;
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
    procedure JobFinished(R: TResource);
    //procedure AddToQueue(R: TResource);
    //procedure SetOnPictureAdd(Value: TPictureEvent);
    procedure OnHandlerFinished(Sender: TObject);
    function CreateJob(t: TDownloadThread): Boolean;
    function GetListFinished: Boolean;
    //function CheckDouble(Pic: TTPicture; x,y: integer): Boolean;
    function CreateDWNLDJob(t: TDownloadThread): Boolean;
    procedure PicJobFinished(R: TResource);
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
  end;

implementation

uses LangString, common;

function CalcValue(s: String; VE: TValueEvent; Lnk: TObject;
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
  op = ['(', ')', '+', '-', '<', '>', '=', '!', '/', '\', '&', ',', '?', '~',
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
begin
  if Assigned(VE) then
  begin
    n1 := CharPos(s, ';', isl);

    while n1 > 0 do
    begin
      n2 := CharPos(s, #13, [], n1 + 1);
      if n2 = 0 then
        raise Exception.Create(Format(_SCRIPT_READ_ERROR_,
          [_INCORRECT_DECLORATION_ + '''' + s + '''']));
      Delete(s, n1, n2 - n1);
      n1 := CharPos(s, ';', isl);
    end;

    n2 := 0;

    while true do
    begin
      n1 := CharPosEx(s, p, isl, n2 + 1);

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
      if s[n1] = '@' then
      begin
        n2 := CharPos(s, '(', ['()', '""'], n1 + 1);
        if n2 = 0 then
          n2 := CharPosEx(s, op, [], n1 + 1)
        else
          n2 := CharPosEx(s, op - ['(', ')'], ['()'], n1 + 1);
      end
      else
        n2 := CharPosEx(s, op, [], n1 + 1);

      if n2 = 0 then
        cstr := Copy(s, n1 + 1, length(s) - n1)
      else
        cstr := Copy(s, n1 + 1, n2 - n1 - 1);

      rstr := null;
      // end;
      VE(s[n1], cstr, rstr, Lnk);

      if rstr = null then
        rstr := '""'
      else
      begin
        tmp := VarType(rstr);
        if (tmp = varOleStr) or (tmp = varString) or (tmp = varUString) then
        begin
          vt := VarToWideStr(rstr);
          VRESULT := VarR8FromStr(vt, VAR_LOCALE_USER_DEFAULT, 0, vt2);
          if VRESULT <> VAR_OK then
            rstr := '''' + doubles(rstr, '''') + ''''
          else
            rstr := vt2;
        end
        else if VarType(rstr) = varDate then
          rstr := '''' + doubles(VarToStr(rstr), '''') + ''''
        else
          rstr := VarAsType(rstr, varDouble);
      end;

      cstr := s[n1] + cstr;
      s := Replace(s, cstr, rstr, true);

      n2 := n1 + length(rstr) - 1;
    end;
  end;

  if NoMath then
    Result := s
  else
    Result := MathCalcStr(s);
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
  case AOperator of
    laCopy:
      begin
        Clear;
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
  p^ := Value;
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

// TScriptSection

constructor TScriptSection.Create;
begin
  inherited;
  FParent := '';
  FParametres := TValueList.Create;
  FParametres.NoDouble := false;
  FDeclorations := TValueList.Create;
  FDeclorations.NoDouble := false;
  FConditions := TScriptSectionList.Create;
  FChildSections := TScriptSectionList.Create;
end;

destructor TScriptSection.Destroy;
begin
  FParametres.Free;
  FDeclorations.Free;
  FConditions.Free;
  FChildSections.Free;
  inherited;
end;

function TScriptSection.NotEmpty: Boolean;
begin
  Result := (Declorations.Count > 0) or (Conditions.Count > 0) or
    (ChildSections.Count > 0);
end;

procedure TScriptSection.ParseValues(s: string);

const
  EmptyS = [#9, #10, #13, ' '];

  isl: array [0 .. 3] of string = ('''''', '""', '()', '{}');

  Cons = ['=', '<', '>', '!'];

var
  i, l, n, p { ,tmpi1,tmpi2 } : integer;
  v1, v2, tmp: string;
  Child: TScriptSection;
  newstring: Boolean;

begin
  FConditions.Clear;
  FDeclorations.Clear;
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
          n := CharPos(s, #13, [], i + 1);

          if n = 0 then
            n := l;

          i := n + 1;
        end
        else
          inc(i);
      '^':
        begin
          newstring := false;
          n := CharPos(s, '{', isl, i + 1);

          if n = 0 then
            raise Exception.Create(Format(_SCRIPT_READ_ERROR_,
              [Format(_INCORRECT_DECLORATION_, [IntToStr(i)])]));

          tmp := TrimEx(Copy(s, i, n - i), EmptyS);

          Child := TScriptSection.Create;
          Child.Parent := GetNextS(tmp, '#');
          while tmp <> '' do
          begin
            v1 := GetNextS(tmp, '#');
            p := CheckStrPos(v1, Cons, true);
            if p > 0 then
              v2 := TrimEx(Copy(v1, 1, p), EmptyS);

            if v2 <> '' then
              if p = 0 then
                Child.Parametres[v2] := ''
              else
                Child.Parametres[v2] :=
                  TrimEx(Copy(s, p + 1, length(v2) - p - 1), EmptyS);
          end;

          i := n + 1;

          n := CharPos(s, '}', isl, i);

          if n = 0 then
          begin
            Child.Free;
            raise Exception.Create(Format(_SCRIPT_READ_ERROR_,
              [Format(_INCORRECT_DECLORATION_, [IntToStr(i)])]));
          end;

          Child.ParseValues(Copy(s, i, n - i));
          FChildSections.Add(Child);

          i := n + 1;
        end;
      '?':
        begin
          n := CharPos(s, '{', isl, i + 1);

          if n = 0 then
            raise Exception.Create(Format(_SCRIPT_READ_ERROR_,
              [Format(_INCORRECT_DECLORATION_, [IntToStr(i)])]));

          tmp := TrimEx(Copy(s, i, n - i), EmptyS);

          Child := TScriptSection.Create;
          Child.Parent := Parent;
          Child.Parametres.Assign(Parametres);
          Child.Parent := tmp;

          i := n + 1;

          n := CharPos(s, '}', isl, i);

          if n = 0 then
          begin
            Child.Free;
            raise Exception.Create(Format(_SCRIPT_READ_ERROR_,
              [Format(_INCORRECT_DECLORATION_, [IntToStr(i)])]));
          end;

          Child.ParseValues(Copy(s, i, n - i));
          FConditions.Add(Child);

          i := n + 1;
        end;
    else
      begin

        n := CharPos(s, ';', isl, i + 1);

        // n := CharPos(s, '=', isl, i + 1);

        if n = 0 then
          raise Exception.Create(Format(_SCRIPT_READ_ERROR_,
            [Format(_INCORRECT_DECLORATION_, [IntToStr(i)])]));

        // v2 := v2;

        v1 := TrimEx(Copy(s, i, n - i), EmptyS);

        i := n + 1;

        n := CharPos(v1, '=', isl);

        if n = 1 then
          raise Exception.Create(Format(_SCRIPT_READ_ERROR_,
            [_INCORRECT_DECLORATION_ + IntToStr(i)]));

        if n > 0 then
        begin
          v2 := TrimEx(Copy(v1, 1, n - 1), EmptyS);
          Delete(v1, 1, n);
        end
        else
        begin
          v2 := CopyTo(v1, '(');

          if v2 = '' then
            raise Exception.Create(Format(_SCRIPT_READ_ERROR_,
              [_INCORRECT_DECLORATION_ + IntToStr(i)]))
          else if v2[1] = '$' then
            v2[1] := '@'
          else
            v2 := '@' + v2;

          { tmpi1 := CharPos(v1,'(',['()']);
            tmpi2 := CharPos(v1,')',['()'],tmpi1+1); }

          v1 := CopyFromTo(v1, '(', ')', ['()', '""', '''''']);
        end;

        Declorations[v2] := v1;

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

begin
  Lnk := LinkedObj;

  if Assigned(SE) then
  begin
    Calced := TValueList.Create;
    Calced.Assign(Parametres);

    if Assigned(PVE) then
      for i := 0 to Calced.Count - 1 do
        Calced.Items[i].Value := CalcValue(Calced.Items[i].Value, PVE, Lnk);

    SE(Parent, Calced, Lnk);

    if not Assigned(DE) then
      FreeAndNil(Calced);
  end;

  if Assigned(DE) then
  begin
    if not Assigned(SE) then
      Calced := TValueList.Create;

    if Assigned(Lnk) and (Lnk is TList) then
      for j := 0 to (Lnk as TList).Count - 1 do
      begin
        Calced.Assign(Declorations);
        for i := 0 to Calced.Count - 1 do
          if not CharInSet(Calced.Items[i].Name[1], ['@']) then
            Calced.Items[i].Value := CalcValue(Declorations.Items[i].Value, VE,
              (Lnk as TList)[j]);

        DE(Calced, (Lnk as TList)[j]);
      end
    else
    begin
      Calced.Assign(Declorations);
      for i := 0 to Calced.Count - 1 do
        if not CharInSet(Calced.Items[i].Name[1], ['@']) then
          Calced.Items[i].Value :=
            CalcValue(Declorations.Items[i].Value, VE, Lnk);

      DE(Calced, Lnk);
    end;

    FreeAndNil(Calced);
  end;

  for i := 0 to Conditions.Count - 1 do
    with Conditions[i] do
      if (length(Parent) > 0) then
      begin
        if CalcValue(Parent, VE, Lnk) then
          Conditions[i].Process(SE, DE, FE, VE, PVE, Lnk);
      end;

  for i := 0 to ChildSections.Count - 1 do
    ChildSections[i].Process(SE, DE, FE, VE, PVE, Lnk);

  if Assigned(FE) then
    FE(Parent, Lnk);

end;

procedure TScriptSection.Assign(s: TScriptSection);
begin
  if s = nil then
    Clear
  else
  begin
    FParent := s.Parent;
    FParametres.Assign(s.Parametres);
    FDeclorations.Assign(s.Declorations);
    FConditions.Assign(s.Conditions);
    FChildSections.Assign(s.ChildSections);
  end;
end;

procedure TScriptSection.Clear;
begin
  FParent := '';
  Conditions.Clear;
  Declorations.Clear;
  ChildSections.Clear;
end;

// TScriptSectionList

procedure TScriptSectionList.Notify(Ptr: Pointer; Action: TListNotification);
var
  p: TScriptSection;
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

procedure TScriptSectionList.Assign(s: TScriptSectionList);
var
  i: integer;
  p: TScriptSection;
begin
  Clear;
  if Assigned(s) then
    for i := 0 to s.Count - 1 do
    begin
      p := TScriptSection.Create;
      p.Assign(s[i]);
      Add(p);
    end;
end;

function TScriptSectionList.Get(Index: integer): TScriptSection;
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
  FFields := TResourceFields.Create;
  FFields.AddField('tag', ftString, null, '');
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
  isl: array [0 .. 2] of string = ('""', '''''', '{}');

var
  n1, n2: integer;
  pr: String;

begin
  pr := '';
  R.Clear;
  n2 := 0;
  while true do
  begin
    n1 := CharPos(s, '[', isl, n2 + 1);

    if n1 = 0 then
    begin
      if pr <> '' then
        R[pr] := Copy(s, n2 + 1, length(s) - n2);
      Break;
    end;

    if pr <> '' then
      R[pr] := Copy(s, n2 + 1, n1 - n2 - 1);

    // Delete(s, 1, n1);

    n2 := CharPos(s, ']', isl, n1 + 1);

    if n2 = 0 then
      Break;

    pr := Copy(s, n1 + 1, n2 - n1 - 1);

    if CheckStr(pr, ['A' .. 'Z', 'a' .. 'z']) then
      raise Exception.Create(Format(_SCRIPT_READ_ERROR_,
        [_SYMBOLS_IN_SECTOR_NAME_]));

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
          if not Assigned(FInitialScript) then
            FInitialScript := TScriptSection.Create;

          FInitialScript.ParseValues(FSectors[LIST_SCRIPT]);

          FJobList.Add(0, JOB_LIST);
        end;
      end;
    JOB_PICS:
      begin
        //FPictureList.Reset;

        FPictureList.ResetCursors;

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

procedure TResource.DeclorationEvent(Values: TValueList; LinkedObj: TObject);
// loading main settings of resoruce
  procedure ProcValue(ItemName: String; ItemValue: Variant);
  var
    s, v: String;
    FSct: TValueList;
    FSS: TScriptSection;
    i: integer;
    // f: TResourceField;
  begin
    if ItemName = '$main.url' then
      FHTTPRec.DefUrl := ItemValue
    else if ItemName = '$main.icon' then
      FIconFile := ItemValue
    else if ItemName = '$main.loginprompt' then
      FLoginPrompt := true
    else if ItemName = '$main.short' then
      FShort := ItemValue
    else if ItemName = '$main.template' then
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
    else if ItemName = '@picture.fields' then
    begin
      FPicFieldList.Clear;
      s := ItemValue;
      while s <> '' do
      begin
        v := GetNextS(s, ',');
        FPicFieldList.Add(lowercase(v));
      end;
    end
    else if ItemName[1] = '$' then
    begin
      Delete(ItemName, 1, 1);
      i := Fields.FindField(ItemName);
      if i = -1 then
        Fields.AddField(ItemName, ftNone, ItemValue, '')
      else
        Fields.Items[i].resvalue := ItemValue;
    end
    else
      raise Exception.Create(Format(_INCORRECT_DECLORATION_, [ItemName]));

  end;

var
  i: integer;
  t: TListValue;
begin
  for i := 0 to Values.Count - 1 do
  begin
    t := Values.Items[i];
    ProcValue(lowercase(t.Name), t.Value);
  end;
end;

function TResource.JobComplete(t: TDownloadThread): integer;
// procedure, called when thread finish it job
var
  i: integer;
  //s: LongInt;
begin
  try
    if t.InitialScript.NotEmpty then
    begin
      t.InitialScript := nil;

      if t.BeforeScript.NotEmpty then
      begin
        if not Assigned(FBeforeScript) then
          FBeforeScript := TScriptSection.Create;
        FBeforeScript.Assign(t.BeforeScript);
      end;
      if t.AfterScript.NotEmpty then
      begin
        if not Assigned(FAfterScript) then
          FAfterScript := TScriptSection.Create;
        FAfterScript.Assign(t.AfterScript);
      end;
      if t.XMLScript.NotEmpty then
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
    if t.ReturnValue = THREAD_COMPLETE then
      case t.Job of
        JOB_LIST:
          begin
            inc(FJobList.FOkCount);
            FJobList[t.JobId].Status := JOB_FINISHED;
            if t.PictureList.Count > 0 then
            begin
              for i := 0 to t.PictureList.Count -1 do
                FPictureList.Add(t.PictureList[i].Orig);
              if Assigned(PictureList.Link.OnEndAddList) then
                PictureList.Link.OnEndAddList(t.PictureList);
              //s := GetTickCount;
              //FOnError(Self, IntToStr(GetTickCount - s) + ' ms');
            end;
          end;
        JOB_ERROR:
          begin
            inc(FJobList.FErrCount);
            FJobList[t.JobId].Status := JOB_ERROR;
            if Assigned(FOnError) then
              FOnError(Self, t.Error);
          end;
      end
    else
    begin
      inc(FJobList.FErrCount);
      FJobList[t.JobId].Status := JOB_ERROR;
    end;

    if Assigned(FOnPageComplete) then
      FOnPageComplete(Self);

    if (FJobList.AllFinished) and (FJobList.eol) then
      FOnJobFinished(Self);

    dec(FCurrThreadCount);
    Result := THREAD_START;
  end;
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
    raise Exception.Create(Format(_NO_FILE_, [fname]));

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
              t.Picture.OnPicChanged(t.Picture, [pcChecked]);
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
              t.Picture.OnPicChanged(t.Picture, []);
            if Assigned(FOnError) then
              FOnError(Self, t.Error);
          end;
      end
    else
    begin
      t.Picture.Status := JOB_ERROR;
      inc(PictureList.Link.FPicCounter.ERR);
      inc(PictureList.FPicCounter.ERR);
      if Assigned(t.Picture.OnPicChanged) then
        t.Picture.OnPicChanged(t.Picture, []);
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
  NR.OnJobFinished := JobFinished;
  NR.OnPicJobFinished := PicJobFinished;
  NR.Assign(R);
  NR.PictureList.Link := PictureList;
  NR.CheckIdle := ThreadHandler.CheckIdle;
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
    FQueueIndex := 0;

  // queue of tasks

  // check new task
  // from current to end

  for i := FQueueIndex to Count - 1 do
  begin
    R := Items[i];
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
          'i','p' : p.ValueType := ftInteger;
          'd' : p.ValueType := ftDateTime;
          'b' : p.ValueType := ftBoolean;
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
      FThreadHandler.FinishThreads(false);
    JOB_STOPPICS:
      FDwnldHandler.FinishThreads(false);
    JOB_LIST:
      if ListFinished then
      begin
        if AllFinished then
          Exit;
        FQueueIndex := 0;
        ThreadHandler.CreateThreads;
        for i := 0 to Count - 1 do
        begin
          with Items[i] do
          begin
            MaxThreadCount := MaxThreadCount;
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

        // FFinished := false;
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
        // FFinished := false;
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
    if (FThreadHandler.Count = 0) and Assigned(FJobChanged) then
      FJobChanged(Self, JOB_STOPLIST)
    else
  else if Sender = FDwnldHandler then
    if (FDwnldHandler.Count = 0) and Assigned(FJobChanged) then
      FJobChanged(Self, JOB_STOPPICS)
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
  if not DirectoryExists(Dir) then
  begin
    if Assigned(FOnError) then
      FOnError(Self, Format(_NO_DIRECTORY_, [Dir]));
    Exit;
  end;

  Clear;

  R := TResource.Create;
  R.Inherit := false;
  R.Name := _GENERAL_;
  Add(R);

  R := nil;

  Dir := IncludeTrailingPathDelimiter(Dir);

  if FindFirst(Dir + '*.cfg', faAnyFile, a) = 0 then
  begin
    repeat
      try
        R := TResource.Create;
        R.LoadFromFile(Dir + a.Name);
        R.Parent := Items[0];
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
  while not terminated do
  begin
    // FErrorString := '';
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
          Break;
      end;
      try
        // Self.ReturnValue := -1;

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

        if FInitialScript.NotEmpty then
          FInitialScript.Process(SE, DE, FE, VE, VE)
        else
          ProcHTTP;

        if Job = JOB_PICS then
          ProcPic;

        Self.ReturnValue := THREAD_COMPLETE;
      finally
        Synchronize(DoJobComplete);
        FPicList.Clear;
        FPicture := nil;
      end;
    except
      on e: Exception do
      begin
        FErrorString := e.Message;
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

constructor TDownloadThread.Create;
begin
  FEventHandle := CreateEvent(nil, true, false, nil);
  FFinish := nil;
  inherited Create(false);
  FHTTP := CreateHTTP;
  FInitialScript := TScriptSection.Create;
  FBeforeScript := TScriptSection.Create;
  FAfterScript := TScriptSection.Create;
  FXMLScript := TScriptSection.Create;
  FFields := TResourceFields.Create;
  FXML := TMyXMLParser.Create;
  // FPictureList := nil;
  FPicList := TPictureList.Create;
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

procedure TDownloadThread.SE(const Parent: String; const Parametres: TValueList;
  var LinkedObj: TObject);
var
  l, s: TTagList;
  i: integer;
  a: TAttrList;

begin
  if (Parent <> '') and (Parent[1] = '^') and Assigned(LinkedObj) and
    (LinkedObj is TTagList) then
  begin
    l := TTagList.Create;
    s := LinkedObj as TTagList;

    a := TAttrList.Create;

    for i := 0 to Parametres.Count - 1 do
      a.Add(Parametres.Items[i].Name, Parametres.Items[i].Value);

    s.GetList(Copy(Parent, 2, length(Parent) - 1), a, l);

    a.Free;

    LinkedObj := l;
  end;
end;

procedure TDownloadThread.VE(const ValS: Char; const Value: String;
  var Result: Variant; var LinkedObj: TObject);
var
  t: TTag;
  s, tmp: string;
  // i: integer;

begin
  // Value := lowrcase(Value);
  Result := '';
  case ValS of
    '#':
      if Assigned(LinkedObj) and (LinkedObj is TTag) then
        Result := ClearHTML((LinkedObj as TTag).Attrs.Value(Value));
    '$':
      if Pos('picture%', Value) = 1 then
      begin
        s := Value;
        tmp := GetNextS(s, '%');
        Result := FPicture.Meta[s];
      end
      else if Value = 'main.url' then
        Result := HTTPRec.DefUrl
      else if Value = 'thread.count' then
        Result := HTTPRec.Count
      else if Value = 'thread.counter' then
        Result := HTTPRec.Counter
      else
        Result := Fields[Value];
    '@':
      begin
        s := TrimEx(CopyTo(Value, '('), [#13, #10, #9, ' ']);
        if SameText(s,'calc') then
          Result := CalcValue(trim(CalcValue(CopyFromTo(Value, '(', ')'), VE,
            LinkedObj, true), ''''), VE, LinkedObj)
        else if SameText(s,'httpencode') then
          Result := STRINGENCODE(StringDecode(CalcValue(CopyFromTo(Value, '(',
            ')'), VE, LinkedObj)))
        else if s = 'emptyname' then
          Result := emptyname(StringDecode(CalcValue(CopyFromTo(Value, '(',
            ')'), VE, LinkedObj)))
        else if s = 'unixtime' then
          Result := UnixToDateTime(CalcValue(CopyFromTo(Value, '(', ')'), VE,
            LinkedObj))
        else if s = 'vartime' then
        begin
          s := CopyFromTo(Value, '(', ')', ['()', '""']);
          Result := DateTimeStrEval(CalcValue(CopyTo(s, ',', ['""'], true), VE,
            LinkedObj), CalcValue(CopyTo(s, ',', ['""'], true), VE, LinkedObj),
            CalcValue(CopyTo(s, ',', ['""'], true), VE, LinkedObj));
        end else if s = 'trim' then
        begin
          s := CopyFromTo(Value, '(', ')', ['()', '""']);
          tmp := CopyTo(s,',',['""'],true);
          if s = '' then
            Result := trim(CalcValue(tmp,VE,LinkedObj),' ')
          else begin
            s := CalcValue(s,VE,LinkedObj);
            Result := trim(CalcValue(tmp,VE,LinkedObj),s[1]);
          end;
        end else if SameText(s,'JSONTime') then
        begin
          if (LinkedObj is TTag) then
            with (LinkedObj as TTag) do
            begin
              s := CopyFromTo(Value, '(', ')');
              t := Childs.FirstItemByName(s);
              if Assigned(t) then
                Result := UnixToDateTime(StrToInt(t.Attrs.Value('s')));
            end;

        end;

      end;
    '%':
      begin
        Result := FPicture.Meta[Value];
      end;
  else
    begin
      raise Exception.Create(Format(_INCORRECT_DECLORATION_, [Value]));
    end;
  end;
end;

procedure TDownloadThread.DE(Values: TValueList; LinkedObj: TObject);

  procedure PicValue(p: TTPicture; const Name: String; Value: Variant);
  var
    s, v1, v2: string;
    del, ins: Char;

  begin
    case Name[1] of
      '%':
        if Name = '%tags' then
        begin
          s := lowercase(Value);
          v1 := GetNextS(s, '(');
          s := GetNextS(s, ')');
          if v1 = 'csv' then
          begin
            v1 := GetNextS(s, ',');
            v1 := trim(CalcValue(v1, VE, LinkedObj));
            v2 := trim(trim(GetNextS(s, ','), ' '), '"');
            if v2 = '' then
              del := #0
            else
              del := v2[1];
            v2 := GetNextS(s, ',');
            if v2 = '' then
              ins := #0
            else
              ins := v2[1];
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
    s, v1, v2: string;
    n: integer;

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
    else if SameText(Name,'$picture.displaylabel') then
      FPicture.DisplayLabel := Value
    else if SameText(Name,'$picture.filename') then
      FPicture.PicName := Value
    else if SameText(Name,'$thread.result') then
      FHTTPRec.Theor := Value
    else if SameText(Name,'$thread.referer') then
      FHTTPRec.Referer := Value
    else if SameText(Name,'$thread.checkcookie') then
      FHTTPRec.CookieStr := Value
    else if SameText(Name,'$thread.login') then
      FHTTPRec.LoginStr := Value
    else if SameText(Name,'@addpicture') then
    begin
      { if FAddPic then
        Synchronize(AddPicture); }
      AddPicture;
      s := Value;
      while s <> '' do
      begin
        n := CharPos(s, ',', ['""', '''''', '()']);
        if n = 0 then
          n := length(s) + 1;
        v1 := TrimEx(Copy(s, 1, n - 1), [#9, #10, #13, ' ']);
        Delete(s, 1, n);

        // v1 := GetNextS(s, ',', '"');

        v2 := TrimEx(GetNextS(v1, '='), [#9, #10, #13, ' ']);
        if v1 = '' then
        begin
          v1 := CopyFromTo(v2, '(', ')', true);
          v2 := '@' + CopyTo(v2, '(');
        end;
        PicValue(FPicture, v2, v1);
      end;
      // FAddPic := true;
      // Synchronize(AddPicture);
    end
    else
      raise Exception.Create(Format(_INCORRECT_DECLORATION_, [Name]));
  end;

var
  i: integer;

begin
  for i := 0 to Values.Count - 1 do
    ProcValue(Values.Items[i].Name, Values.Items[i].Value);
end;

procedure TDownloadThread.FE(Parent: String; LinkedObj: TObject);
begin
  if (Parent <> '') and (Parent[1] = '^') and Assigned(LinkedObj) then
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
  FRetries := 0;
  while true do
    try
      FBeforeScript.Process(SE, DE, FE, VE, VE);
      // FHTTP.ResponseCode := 0;
      try
        Url := CalcValue(FHTTPRec.Url, VE, nil);
        FHTTP.Request.Referer := FHTTPRec.Referer;
        s := FHTTP.Get(Url);
        inc(FHTTPRec.Counter);
      except
        on e: Exception do
          if (FHTTP.ResponseCode = 404){ or (FHTTP.ResponseCode = -1) }then
          begin
            FErrorString := Url + ': ' + e.Message;
            FJob := JOB_ERROR;
            Break;
          end
          else if FRetries < FMaxRetries then
          begin
            Inc(FRetries);
            Continue;
          end else
            Break;
      end;

      if SameText(FHTTPRec.ParseMethod,'xml') then
        FXML.Parse(s)
      else if SameText(FHTTPRec.ParseMethod,'json') then
        FXML.JSON(FHTTPREC.JSONItem,s)
      else raise Exception.Create(Format(_UNKNOWNMETHOD_,[FHTTPRec.ParseMethod]));

      {FXMl.TagList.ExportToFile(ExtractFilePath(paramstr(0))
        + IntToStr(FHTTPRec.Counter) + '.xml');}

      // Synchronize(LockList);
      FXMLScript.Process(SE, DE, FE, VE, VE, FXML.TagList);
      { if FAddPic then
        Synchronize(AddPicture); }
      { if FAddPic then
        AddPicture; }
      // Synchronize(UnlockList);
      FAfterScript.Process(SE, DE, FE, VE, VE);

      CSection.Enter;
      try
        FLPicList.AddPicList(FPicList,true);
      finally
        CSection.Leave;
      end;

      Break;
    except
      on e: Exception do
      begin
        FErrorString := e.Message;
        FJob := JOB_ERROR;
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

  try
    Dir := ExtractFileDir(FPicture.FileName);

    FCS.Enter;
    try
      if fileexists(FPicture.FileName) then
      begin
        { FPicture.Size := 1;
          FPicture.Pos; }
        FPicture.Changes := [pcSize, pcProgress];
        Synchronize(PicChanged);
        Exit;
      end;

      if not DirectoryExists(Dir) then
        CreateDirExt(Dir);

      f := TFileStream.Create(FPicture.FileName, fmCreate);
    finally
      FCS.Leave;
    end;

    try
      //HTTP.Request.ContentRangeStart := f.Size;
      HTTP.Request.Referer := FHTTPRec.Referer;
      HTTP.Get(HTTPRec.Url, f);


      if ReturnValue = THREAD_FINISH then
      begin
        FJOB := JOB_CANCELED;
      end;

      if FPicture.Size <> f.Size then
      begin
        f.Free;
        DeleteFile(FPicture.FileName);
        if ReturnValue <> THREAD_FINISH then
          SetHTTPError(HTTPRec.Url + ': ' +_INCORRECT_FILESIZE_);
      end else
        f.Free;

    except
      on e: Exception do
      begin
        f.Free;
        DeleteFile(FPicture.FileName);
        SetHTTPError(HTTPRec.Url + ': ' + e.Message);
      end;
    end;
  except
    on e: Exception do
    begin
      if Assigned(f) then
        f.Free;
      if fileexists(FPicture.FileName) then
        DeleteFile(FPicture.FileName);
      FErrorString := e.Message;
      FJob := JOB_ERROR;
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

function TPictureTagLinkList.Get(Index: integer): TPictureTag;
begin
  Result := inherited Get(Index);
end;

procedure TPictureTagLinkList.Put(Index: integer; Item: TPictureTag);
begin
  inherited Put(Index, Item);
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

function TPictureTagList.Add(TagName: String; p: TTPicture): TPictureTag;
var
  n: integer;
begin
  n := Find(TagName);
  if n = -1 then
  begin
    Result := TPictureTag.Create;
    Result.Attribute := taNone;
    Result.Name := TagName;
    inherited Add(Result)
  end
  else
    Result := Items[n];

  if Assigned(p) then
  begin
    p.Tags.Add(Result);
    Result.Linked.Add(p);
  end;
end;

function TPictureTagList.Find(TagName: String): integer;
var
  i: integer;
begin
  TagName := lowercase(TagName);
  for i := 0 to Count - 1 do
    if lowercase(Items[i].Name) = TagName then
    begin
      Result := i;
      Exit;
    end;
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
procedure TTPicture.MakeFileName(Format: String);
// check names
  function ParamCheck(s: String; main: Boolean): String;
  var
    n: TListValue;

  begin
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
      else
        Result := s
    else
    begin
      n := Meta.FindItem(s) as TListValue;

      if n = nil then
        Result := ValidFName(s)
      else
        Result := ValidFName(VarToStr(n.Value));
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
        s := Replace(s, s[i] + key + s[n], rsl);
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
      FFileName := ParseSections(FResource.NameFormat)
  else
    FFileName := ParseSections(Format);
end;

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
  APicture.MakeFileName(FNameFormat);
  if Assigned(FOnAddPicture) then
    FOnAddPicture(APicture);
end;

procedure TPictureList.SetPicChange(Value: TPicChangeEvent);
var
  i: integer;
begin
  FPicChange := Value;
  for i := 0 to Count - 1 do
    Items[i].OnPicChanged := Value;
end;

procedure TPictureList.AddPicList(APicList: TPictureList; Orig: Boolean);
var
  i, j: integer;
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
          t := CopyPicture(APicList[i]);
          Inc(FParentsCount);
          t.BookMark := FParentsCount;
          if Orig then
            APicList[i].Orig := t;
          for j := 0 to APicList[i].Linked.Count - 1 do
            if not CheckDoubles(APicList[i].Linked[j]) then
            begin
              ch := CopyPicture(APicList[i].Linked[j]);
              Inc(FChildsCount);
              ch.BookMark := FChildsCount;
              if Orig then
                APicList[i].Linked[j].Orig := ch;
              t.Linked.Add(ch);
              ch.Parent := t;
            end;
        end;
        inc(i);
      end
      else
      begin
         if Orig then
          APicList.Delete(i)
        else
          inc(i);
        Inc(FPicCounter.IGN);
      end;
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
    Insert(FParentsCount + FChildsCount,Result)
  else
    Insert(FParentsCount,Result);

  Result.Resource := Pic.Resource;
  Result.OnPicChanged := OnPicChanged;
  Result.List := Self;
  Result.MakeFileName(FNameFormat);
  if Assigned(FOnAddPicture) then
    FOnAddPicture(Result);
end;

constructor TPictureList.Create;
begin
  inherited;
  FTags := TPictureTagList.Create;
  FMetaContainer := TTagedList.Create;
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
  inherited;
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
      inc(FPicCOunter.SKP);

  FCursor := i;

  for i := i to Count - 1 do
    if (Items[i].Checked) then
    begin
      Items[i].Status := JOB_NOJOB;
      if Items[i].Size <> 0 then
      begin
        Items[i].Size := 0;
        if Assigned(Items[i].OnPicChanged) then
          Items[i].OnPicChanged(Items[i],[pcSize,pcProgress]);
      end;
    end else
      inc(FPicCounter.SKP);

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
  end;
end;

function TPictureList.CheckDoubles(pic: TTPicture): boolean;
var
  i: integer;
  s1 { ,s2 } : Variant;
  m: TMetaList;
  pos: integer;
begin
  for i := 0 to length(FIgnoreList) - 1 do
  begin
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
        raise Exception.Create(FIgnoreList[i][0] + ','
                               + FIgnoreList[i][1] + ': ' + e.Message);
      end;
    end;
  end;
  Result := false;
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
            AddField(resname, restype, resvalue, resitems);
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
  raise Exception.Create(Format(_NO_FIELD_, [ItemName]));
end;

function TResourceFields.AddField(resname: string; restype: TFieldType;
  resvalue: Variant; resitems: String): integer;
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
    d.CSection := FCS;
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
  FCS := TCriticalSection.Create;
end;

destructor TThreadHandler.Destroy;
begin
  FCS.Free;
  inherited;
  // FQueue.Free;
  // inherited;
end;

end.
