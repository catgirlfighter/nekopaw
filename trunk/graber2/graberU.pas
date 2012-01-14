unit graberU;

interface

uses Classes, Messages, SysUtils, Variants, Windows, idHTTP, MyXMLParser,
  DateUtils, MyHTTP;

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

  THREAD_STOP = 0;
  THREAD_START = 1;
  THREAD_FINISH = 2;

  JOB_STOPDOWNLOAD = 0;
  JOB_GETPICTURES = 1;
  JOB_DOWNLOADPICTURES = 2;

  SAVEFILE_VERSION = 0;

  LIST_SCRIPT = 'listscript';
  DOWNLOAD_SCRIPT = 'downloadscript';

type

  TProxyRec = record
    UseProxy: boolean;
    Host: string;
    Port: longint;
    Auth: boolean;
    Login: string;
    Password: string;
    SavePWD: boolean;
  end;

  TDownloadRec = record
    ThreadCount: integer;
    Retries: integer;
    Interval: integer;
    BeforeU: boolean;
    BeforeP: boolean;
    AfterP: boolean;
    Debug: boolean;
  end;

  TSettingsRec = record
    Proxy: TProxyRec;
    Downl: TDownloadRec;
    OneInstance: boolean;
    TrayIcon: boolean;
    HideToTray: boolean;
    SaveConfirm: boolean;
  end;

  THTTPMethod = (hmGet, hmPost);

  THTTPRec = record
    DefUrl: String;
    Url: string;
    Method: THTTPMethod;
    Counter, Count: integer;
  end;

  TListValue = class(TObject)
  private
    FName: String;
    FValue: Variant;
  public
    constructor Create;
    property Name: String read FName write FName;
    property Value: Variant read FValue write FValue;
  end;

  TValueList = class(TList)
  private
    FNodouble: boolean;
  protected
    function Get(Index: integer): TListValue;
    function GetValue(ItemName: String): Variant;
    procedure SetValue(ItemName: String; Value: Variant); virtual;
    function FindItem(ItemName: String): TListValue;
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    destructor Destroy; override;
    procedure Assign(List: TValueList; AOperator: TListAssignOp = laCopy);
    constructor Create;
//    procedure Add(ItemName: String; Value: Variant);
    property Items[Index: integer]: TListValue read Get;
    property ItemByName[ItemName: String]: TListValue read FindItem;
    property Values[ItemName: String]: Variant read GetValue
      write SetValue; default;
    property Count;
    property NoDouble: Boolean read FNoDouble write FNoDouble;
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
    function NotEmpty: boolean;
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

  TFieldType = (ftNone, ftString, ftNumber, ftCombo, ftCheck);

  PResourceField = ^TResourceField;

  TResourceField = record
    resname: string;
    restype: TFieldType;
    resvalue: Variant;
    resitems: string;
  end;

  TResourceFields = class(TList)
  protected
    function Get(Index: integer): TResourceField;
    procedure Put(Index: integer; Value: TResourceField);
    function GetValue(ItemName: String): Variant;
    procedure SetValue(ItemName: String; Value: Variant);
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    procedure Assign(List: TResourceFields; AOperator: TListAssignOp = laCopy);
    function AddField(resname: string; restype: TFieldType; resvalue: Variant;
      resitems: String): integer;
    property Items[Index: integer]: TResourceField read Get write Put;
    property Values[ItemName: String]: Variant read GetValue
      write SetValue; default;
  end;

  TThreadEvent = function(t: TDownloadThread): integer of object;

  TDownloadThread = class(TThread)
  private
    FHTTP: TMyIdHTTP;
    FEventHandle: THandle;
    FJob: integer;
    FJobComplete: TThreadEvent;
    FFinish: TThreadEvent;
    FErrorString: String;
    FErrorCode: integer;
    FInitialScript: TScriptSection;
    FBeforeScript: TScriptSection;
    FAfterScript: TScriptSection;
    FXMLScript: TScriptSection;
    FFields: TResourceFields;
    FDownloadRec: TDownloadRec;
    FHTTPRec: THTTPRec;
    FPictureList: TPictureList;
    FSectors: TValueList;
    FXML: TMyXMLParser;
    FPicture: TTPicture;
    FPicLink: TTPicture;
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
  public
    procedure Execute; override;
    constructor Create;
    destructor Destroy; override;
    procedure AddPicture;
    procedure ProcHTTP;
    procedure SetSectors(Value: TValueList);
    procedure LockList;
    procedure UnlockList;
    property HTTP: TMyIdHTTP read FHTTP;
    property Job: integer read FJob write FJob;
    property EventHandle: THandle read FEventHandle;
    property Error: String read FErrorString;
    property ErrorCode: integer read FErrorCode;
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
    property PictureList: TPictureList read FPictureList write FPictureList;
  end;

  TJobEvent = procedure(t: TDownloadThread) of object;

  TThreadHandler = class(TThreadList)
  private
    FQueue: TResourceLinkList;
    FCount: integer;
    FFinishThreads: boolean;
    FFinishQueue: boolean;
    FCreateJob: TJobEvent;
    FProxy: TProxyRec;
    FCookie: TMyCookieList;
    FOnAllThreadsFinished: TNotifyEvent;
  protected
    function Finish(t: TDownloadThread): integer;
    procedure CheckIdle;
    procedure AddToQueue(R: TResource);
    procedure ThreadTerminate(ASender: TObject);
  public
    procedure CreateThreads(acount: integer);
    procedure FinishThreads(Force: boolean = false);
    constructor Create;
    destructor Destroy; override;
    procedure FinishQueue;
    property CreateJob: TJobEvent read FCreateJob write FCreateJob;
    property Count: integer read FCount;
    property Proxy: TProxyRec read FProxy write FProxy;
    property Cookies: TMyCookieList read FCookie write FCookie;
    property OnAllThreadsFinished: TNotifyEvent read FOnAllThreadsFinished
      write FOnAllThreadsFinished;
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
    function Add(TagName: String): TPictureTag;
    function Find(TagName: String): integer;
    procedure ClearZeros;
    property Items;
    property Count;
  end;

  TPictureEvent = procedure(APicture: TTPicture) of object;

  TTPicture = class(TObject)
  private
    FParent: TTPicture;
    FMeta: TValueList;
    FLinked: TPictureLinkList;
    FTags: TPictureTagLinkList;
    FChecked: boolean;
    FFinished: boolean;
    FRemoved: boolean;
  protected
    procedure SetParent(Item: TTPicture);
    procedure SetRemoved(Value: boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Assign(Value: TTPicture);
    property Removed: boolean read FRemoved write SetRemoved;
    property Finished: boolean read FFinished;
    property Checked: boolean read FChecked write FChecked;
    property Parent: TTPicture read FParent write SetParent;
    property Tags: TPictureTagLinkList read FTags;
    property Meta: TValueList read FMeta;
    property Linked: TPictureLinkList read FLinked;
  end;

  TPictureLinkList = class(TList)
  private
    FOnAddPicture: TPictureEvent;
    FBeforePictureList: TNotifyEvent;
    FAfterPictureList: TNotifyEvent;
  protected
    function Get(Index: integer): TTPicture;
    procedure Put(Index: integer; Item: TTPicture);
  public
    procedure Add(APicture: TTPicture);
    procedure BeginAddList;
    procedure EndAddList;
    property OnAddPicture: TPictureEvent read FOnAddPicture write FOnAddPicture;
    property Items[Index: integer]: TTPicture read Get write Put; default;
    property OnBeginAddList: TNotifyEvent read FBeforePictureList write FBeforePictureList;
    property OnEndAddList: TNotifyEvent read FAfterPictureList write FAfterPictureList;
  end;


  TPictureList = class(TPictureLinkList)
  private
    FTags: TPictureTagList;
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    constructor Create;
    destructor Destroy; override;
    property Tags: TPictureTagList read FTags;
    property Items;
    property Count;
  end;

  TResourceEvent = procedure(R: TResource) of object;

  TResource = class(TObject)
  private
    FFileName: String;
    FResName: String;
    // FURL: String;
    FIconFile: String;
    FParent: TResource;
    FLoginPrompt: boolean;
    FInherit: boolean;
    FJobInitiated: boolean;
    FFields: TResourceFields;
    FSectors: TValueList;
    FInitialScript: TScriptSection;
    FBeforeScript: TScriptSection;
    FAfterScript: TScriptSection;
    FXMLScript: TScriptSection;
    FDownloadSet: TDownloadRec;
    FPictureList: TPictureList;
    FHTTPRec: THTTPRec;
    FAddToQueue: TResourceEvent;
    FOnJobFinished: TResourceEvent;
    FJobFinished: boolean;
    FPicFieldList: TStringList;
  protected
    procedure DeclorationEvent(Values: TValueList; LinkedObj: TObject);
    function JobComplete(t: TDownloadThread): integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(FName: String);
    function CreateFullFieldList: TStringList;
    procedure CreateJob(t: TDownloadThread);
    procedure StartJob(JobType: integer);
    procedure Assign(R: TResource);
    property FileName: String read FFileName;
    property Name: String read FResName write FResName;
    // property Url: String read FURL;
    property IconFile: String read FIconFile;
    property Fields: TResourceFields read FFields;
    property Parent: TResource read FParent write FParent;
    property Inherit: boolean read FInherit write FInherit;
    property Sectors: TValueList read FSectors;
    property LoginPrompt: boolean read FLoginPrompt;
    property DownloadSet: TDownloadRec read FDownloadSet write FDownloadSet;
    property HTTPRec: THTTPRec read FHTTPRec write FHTTPRec;
    property PictureList: TPictureList read FPictureList;
    property JobInitiated: boolean read FJobInitiated;
    property InitialScript: TScriptSection read FInitialScript;
    property BeforeScript: TScriptSection read FBeforeScript;
    property AfterScript: TScriptSection read FBeforeScript;
    property XMLScript: TScriptSection read FXMLScript;
    property AddToQueue: TResourceEvent read FAddToQueue write FAddToQueue;
    property JobFinished: boolean read FJobFinished;
    property OnJobFinished: TResourceEvent read FOnJobFinished
      write FOnJobFinished;
    property PicFieldList: TStringList read FPicFieldList;
  end;

  TResourceLinkList = class(TList)
  protected
    function Get(Index: integer): TResource;
  public
    property Items[Index: integer]: TResource read Get; default;
  end;

  TResourceList = class(TResourceLinkList)
  private
    FThreadHandler: TThreadHandler;
    FOnAddPicture: TPictureEvent;
    FOnStartJob: TNotifyEvent;
    FOnEndJob: TNotifyEvent;
    FOnBeginPicList: TNotifyEvent;
    FOnEndPicList: TNotifyEvent;
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
    procedure JobFinished(R: TResource);
    procedure AddToQueue(R: TResource);
    procedure SetOnPictureAdd(Value: TPictureEvent);
    procedure OnHandlerFinished(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure StartJob(JobType: integer);
    procedure CopyResource(R: TResource);
    function FullPicFieldList: TStringList;
    property ThreadHandler: TThreadHandler read FThreadHandler;
    procedure LoadList(Dir: String);
    property OnAddPicture: TPictureEvent read FOnAddPicture write SetOnPictureAdd;
    property OnStartJob: TNotifyEvent read FOnStartJob write FOnStartJob;
    property OnEndJob: TNotifyEvent read FOnEndJob write FOnEndJob;
    property OnBeginPicList: TNotifyEvent read FOnBeginPicList write FOnBeginPicList;
    property OnEndPicList: TNotifyEvent read FOnEndPicList write FOnEndPicList;
  end;

implementation

uses LangString, common;

function CalcValue(s: String; VE: TValueEvent; Lnk: TObject): Variant;
const
  op = ['(', ')', '+', '-', '<', '>', '=', '!', '/', '\', '&', ',', '?', '~',
    '|', ' ', #9, #13, #10];
  p = ['$', '#'];
  isl: array [0 .. 1] of string = ('""', '''''');

var
  n1, n2: integer;
  cstr: string;
  rstr: Variant;

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

      n2 := CharPosEx(s, op, [], n1 + 1);

      if n2 = 0 then
        cstr := Copy(s, n1 + 1, length(s) - n1)
      else
        cstr := Copy(s, n1 + 1, n2 - n1 - 1);

      rstr := null;

      VE(s[n1], cstr, rstr, Lnk);

      if rstr = null then
        rstr := '""'
      else
        try
          rstr := rstr + 0
        except
          rstr := '"' + rstr + '"';
        end;


      cstr := s[n1] + cstr;
      s := Replace(s, cstr, rstr, false, true);

      n2 := n1 + length(rstr) - 1;
    end;
  end;

  Result := MathCalcStr(s);
end;

// TListValue

constructor TListValue.Create;
begin
  inherited;
  FName := '';
  FValue := '';
end;

// TPictureValue

{ constructor TPictureValue.Create;
  begin
  inherited;
  FState := pvsNone;
  end; }

// TValueList

constructor TValueList.Create;
begin
  FNodouble := true;
end;

destructor TValueList.Destroy;
begin
  inherited;
end;

procedure TValueList.Notify(Ptr: Pointer; Action: TListNotification);
var
  p: TListValue;
begin
  case Action of
    lnDeleted:
      begin
        p := Ptr;
        p.Free;
      end;
  end;
end;

function TValueList.Get(Index: integer): TListValue;
begin
  Result := inherited Get(Index);
end;

function TValueList.GetValue(ItemName: String): Variant;
var
  p: TListValue;
begin
  p := FindItem(ItemName);
  if p = nil then
    Result := null
  else
    Result := p.Value;
end;

procedure TValueList.SetValue(ItemName: String; Value: Variant);
var
  p: TListValue;
begin
  if ItemName = '' then
    Exit;
  if FNoDouble then
  begin
    p := FindItem(ItemName);
    if p = nil then
    begin
      p := TListValue.Create;
      p.Name := ItemName;
      p.Value := Value;
      inherited Add(p);
    end
    else
      p.Value := Value;
  end else
  begin
    p := TListValue.Create;
    p.Name := ItemName;
    p.Value := Value;
    inherited Add(p);
  end;
end;

function TValueList.FindItem(ItemName: String): TListValue;
var
  i: integer;
begin
  ItemName := LowerCase(ItemName);
  for i := 0 to Count - 1 do
  begin
    Result := inherited Get(i);
    if LowerCase(Result.Name) = ItemName then
      Exit;
  end;
  Result := nil;
end;

{procedure TValueList.Add(ItemName: String; Value: Variant);
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
end;  }

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

function TScriptSection.NotEmpty: boolean;
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
  i, l, n, p: integer;
  v1, v2, tmp: string;
  Child: TScriptSection;
  newstring: boolean;
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
        end else
          inc(i);
      '^':
        begin
          newstring := false;
          n := CharPos(s, '{', isl, i + 1);

          if n = 0 then
            raise Exception.Create(Format(_SCRIPT_READ_ERROR_,
              [Format(_INCORRECT_DECLORATION_,[IntToStr(i)])]));

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
              [Format(_INCORRECT_DECLORATION_,[IntToStr(i)])]));
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
              [Format(_INCORRECT_DECLORATION_,[IntToStr(i)])]));

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
              [Format(_INCORRECT_DECLORATION_,[IntToStr(i)])]));
          end;

          Child.ParseValues(Copy(s, i, n - i));
          FConditions.Add(Child);

          i := n + 1;
        end;
    else
      begin

        n := CharPos(s, ';', isl, i + 1);

        //n := CharPos(s, '=', isl, i + 1);

          if n = 0 then
            raise Exception.Create(Format(_SCRIPT_READ_ERROR_,
              [Format(_INCORRECT_DECLORATION_,[IntToStr(i)])]));

        //v2 := v2;

        v1 := TrimEx(Copy(s, i, n - i), EmptyS);

        i := n + 1;

        n := CharPos(v1,'=',isl);

        if n = 1 then
          raise Exception.Create(Format(_SCRIPT_READ_ERROR_,
            [_INCORRECT_DECLORATION_ + IntToStr(i)]));

        if n > 0 then
        begin
          v2 := TrimEx(Copy(v1, 1, n - 1), EmptyS);
          Delete(v1,1,n);
        end else
        begin
          v2 := CopyTo(v1,'(');

          if v2 = '' then
            raise Exception.Create(Format(_SCRIPT_READ_ERROR_,
              [_INCORRECT_DECLORATION_ + IntToStr(i)]))
          else if v2[1] = '$' then
            v2[1] := '@'
          else
            v2 := '@' + v2;

          v1 := CopyFromTo(s,'(',')',true);
        end;

        Declorations[v2] := v1;

        //i := n + 1;


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
          Calced.Items[i].Value := CalcValue(Declorations.Items[i].Value,
            VE, Lnk);

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

// TResource

procedure TResource.Assign(R: TResource);
begin
  // FDownloadSet := R.DownloadSet;
  FFileName := R.FileName;
  FIconFile := R.IconFile;
  FInherit := R.Inherit;
  FFields.Assign(R.Fields);
  if FInherit then
    FFields.Assign(R.Parent.Fields, laOr);
  FLoginPrompt := R.LoginPrompt;
  FResName := R.Name;
  FSectors.Assign(R.Sectors);
  FPicFieldLIst.Assign(R.PicFieldList);
  // FURL := R.Url;

  FHTTPRec.DefUrl := R.HTTPRec.DefUrl;
  FHTTPRec.Url := '';
  FHTTPRec.Method := hmGet;
  FHTTPRec.Counter := 0;
  FHTTPRec.Count := 0;
end;

constructor TResource.Create;
begin
  inherited;
  FFileName := '';
  // FURL := '';
  FIconFile := '';
  FParent := nil;
  FPictureList := TPictureList.Create;
  FInherit := true;
  FLoginPrompt := false;
  FFields := TResourceFields.Create;
  FFields.AddField('tag', ftString, null, '');
  FSectors := TValueList.Create;
  FInitialScript := TScriptSection.Create;
  FPicFieldList := TStringList.Create;
  FBeforeScript := nil;
  FAfterScript := nil;
  FXMLScript := nil;
  FAddToQueue := nil;
  FJobFinished := false;
end;

destructor TResource.Destroy;
begin
  FPictureList.Free;
  FSectors.Free;
  FFields.Free;
  FPicFieldList.Free;
{  if Assigned(FPictureList) then
    FPictureList.Free;   }
  inherited;
end;

procedure TResource.StartJob(JobType: integer);
begin
  FJobInitiated := false;
  FJobFinished := false;
  if not Assigned(FInitialScript) then
    FInitialScript := TScriptSection.Create;

  case JobType of
    JOB_GETPICTURES:
      FInitialScript.ParseValues(FSectors[LIST_SCRIPT]);
    JOB_DOWNLOADPICTURES:
      FInitialScript.ParseValues(FSectors[DOWNLOAD_SCRIPT]);
  end;
  AddToQueue(Self);
end;

function TResource.CreateFullFieldList: TStringList;
begin
  Result := nil;
end;

procedure TResource.CreateJob(t: TDownloadThread);
begin
  t.JobComplete := JobComplete;
  if not JobInitiated then
  begin
    t.InitialScript := InitialScript;
  end;
  t.BeforeScript := BeforeScript;
  t.AfterScript := AfterScript;
  t.XMLScript := XMLScript;
  t.HTTPRec := HTTPRec;
  t.DownloadRec := DownloadSet;
  t.Sectors := FSectors;
  t.Fields := FFields;
  t.PictureList := FPictureList;
  inc(FHTTPRec.Counter);
end;

procedure TResource.DeclorationEvent(Values: TValueList; LinkedObj: TObject);

  procedure ProcValue(ItemName: String; ItemValue: Variant);
  var
    s,v: String;
  begin
    if ItemName = '$main.url' then
      FHTTPRec.DefUrl := ItemValue
    else if ItemName = '$main.icon' then
      FIconFile := ItemValue
    else if ItemName = '$main.authorization' then
      FLoginPrompt := true
    else if ItemName = '@picture.fields' then
    begin
      FPicFieldList.Clear;
      s := ItemValue;
      while s <> '' do
      begin
        v := GetNextS(s,',');
        FPicFieldList.Add(lowercase(v));
      end;
    end else
      raise Exception.Create(Format(_INCORRECT_DECLORATION_,[ItemName]));

  end;

var
  i: integer;
  t: TListValue;
begin
  for i := 0 to Values.Count - 1 do
  begin
    t := Values.Items[i];
    ProcValue(LowerCase(t.Name), t.Value);
  end;
end;

function TResource.JobComplete(t: TDownloadThread): integer;
var
  i: integer;

begin
  if not JobInitiated then
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
      AddToQueue(Self);

    FJobInitiated := true;
  end;

  if { (HTTPRec.Count > 0) and } (HTTPRec.Counter >= HTTPRec.Count) then
  begin
    FJobFinished := true;
    FOnJobFinished(Self);
  end;

  Result := THREAD_START;
end;

procedure TResource.LoadFromFile(FName: String);

const
  isl: array [0 .. 2] of string = ('""', '''''', '{}');

  procedure GetSectors(s: string; R: TValueList);
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

  function nullstr(n: Variant): string;
  begin
    if n = null then
      Result := ''
    else
      Result := n;
  end;

var
  mainscript: TScriptSection;
  s, tmps: String;
  f: textfile;
begin
  if not fileexists(FName) then
    raise Exception.Create(Format(_NO_FILE_, [FName]));
  Assignfile(f, FName);
  s := '';
  try
    Reset(f);
    while not eof(f) do
    begin
      readln(f, tmps);
      s := s + tmps + #13#10;
    end;
  finally
    CloseFile(f);
  end;

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
      raise Exception.Create(e.Message);
    end;
  end;

  FFileName := FName;
  FResName := ChangeFileExt(ExtractFileName(FName), '');
end;

// TResourceLinkList

function TResourceLinkList.Get(Index: integer): TResource;
begin
  Result := inherited Get(Index);
end;

// TResourceList

procedure TResourceList.CopyResource(R: TResource);
var
  NR: TResource;
begin
  NR := TResource.Create;
  NR.AddToQueue := AddToQueue;
  NR.OnJobFinished := JobFinished;
  NR.Assign(R);
  NR.PictureList.OnAddPicture := FOnAddPicture;
  NR.PictureList.OnBeginAddList := FOnBeginPicList;
  NR.PictureList.OnEndAddList := FOnEndPicList;
  Add(NR);
end;

constructor TResourceList.Create;
begin
  inherited;
  FThreadHandler := TThreadHandler.Create;
  FThreadHandler.OnAllThreadsFinished := OnHandlerFinished;
end;

destructor TResourceList.Destroy;
begin
  FThreadHandler.Free;
  inherited;
end;

function TResourceList.FullPicFieldList: TStringList;
var
  i,j: integer;
  l: TStringList;

begin
  Result := TStringList.Create;
  if Count < 1 then
    Exit;
  Result.Assign(Items[0].PicFieldList);
  for i := 1 to Count -1 do
  begin
    l := Items[i].PicFieldList;
    for j := 0 to l.Count -1 do
      if Result.IndexOf(l[j]) > -1 then
        Result.Add(l[j]);

  end;

end;

procedure TResourceList.JobFinished(R: TResource);
var
  i: integer;

begin
  for i := 0 to Count - 1 do
    if not Items[i].JobFinished then
      Exit;
  ThreadHandler.FinishQueue;
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
    JOB_STOPDOWNLOAD:
      FThreadHandler.FinishThreads(false);
    JOB_GETPICTURES, JOB_DOWNLOADPICTURES:
      for i := 0 to Count - 1 do
        Items[i].StartJob(JobType);
  end;
  if Assigned(FOnStartJob) then
    FOnStartJob(Self);
end;

procedure TResourceList.AddToQueue(R: TResource);
begin
  FThreadHandler.AddToQueue(R);
end;

procedure TResourceList.SetOnPictureAdd(Value: TPictureEvent);
var
  i: integer;
begin
  FOnAddPicture := Value;
  for I := 0 to Count-1 do
    Items[i].PictureList.OnAddPicture := FOnAddPicture;
end;

procedure TResourceList.OnHandlerFinished(Sender: TObject);
begin
  if (FThreadHandler.Count = 0) and Assigned(FOnEndJob) then
    FOnEndJob(Self);
end;

procedure TResourceList.LoadList(Dir: String);
var
  a: TSearchRec;
  R: TResource;

begin
  Clear;
  R := TResource.Create;
  R.Inherit := false;
  R.Name := _GENERAL_;
  Add(R);

  R := nil;

  if not DirectoryExists(Dir) then
    raise Exception.Create(Format(_NO_DIRECTORY_, [Dir]));

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
          { /*/*/ Надо сделать уведомление об ошибке /*/*/ }
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
    try
      Synchronize(DoFinish);
      case Job of
        THREAD_STOP:
          begin
            ResetEvent(FEventHandle);
            WaitForSingleObject(FEventHandle, INFINITE);
            Continue;
          end;
        THREAD_FINISH:
          Break;
      end;

      FInitialScript.Process(SE, DE, FE, VE, VE);
      ProcHTTP;
      Synchronize(DoJobComplete);
    except
      Break;
    end;
  end;
end;

procedure TDownloadThread.AddPicture;
begin
  FPicLink := TTPicture.Create;
  FPicLink.Assign(FPicture);
  FPictureList.Add(FPicLink);
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
  FPictureList := nil;
  FSectors := TValueList.Create;
  FPicture := TTPicture.Create;
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
  FPicture.Free;
  inherited;
end;

procedure TDownloadThread.DoJobComplete;
begin
  FJobComplete(Self);
end;

procedure TDownloadThread.DoFinish;
begin
  FJob := Finish(Self);
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
  s: string;
  // i: integer;

begin
  // Value := lowrcase(Value);
  Result := '';
  case ValS of
    '#':
      if Assigned(LinkedObj) and (LinkedObj is TTag) then
      begin
        t := LinkedObj as TTag;
        Result := t.Attrs.Value(Value);
      end;
    '$':
      if Value = 'main.url' then
        Result := HTTPRec.DefUrl
      else if Value = 'thread.count' then
        Result := HTTPRec.Count
      else if Value = 'thread.counter' then
        Result := HTTPRec.Counter
      else
        Result := Fields[Value];
    '@':
      begin
        s := CopyTo(Value, '(');
        if s = 'unixtime' then
          Result := UnixToDateTime(CalcValue(CopyFromTo(Value, '(', ')'), VE,
            LinkedObj));
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
          s := LowerCase(Value);
          v1 := GetNextS(s, '(');
          s := GetNextS(s, ')');
          if v1 = 'csv' then
          begin
            v1 := GetNextS(s, ',');
            v1 := CalcValue(v1, VE, LinkedObj);
            v2 := GetNextS(s, ',');
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
              FPicture.Tags.Add(FPictureList.Tags.Add(s));
            end;
          end;
        end
        else
          p.Meta[Copy(Name, 2, length(Name) - 1)] :=
            CalcValue(Value, VE, LinkedObj);
    end;

  end;

  procedure ProcValue(const Name: String; Value: Variant);
  var
    // p: TTPicture;
    s, v1, v2: string;
    n: integer;

  begin
    if Name = '$thread.url' then
      FHTTPRec.Url := Value
    else if Name = '$thread.xml' then
      FXMLScript.ParseValues(FSectors[Value])
    else if Name = '$thread.count' then
      FHTTPRec.Count := Trunc(Value)
    else if Name = '$thread.counter' then
      FHTTPRec.Counter := Trunc(Value)
    else if Name = '@thread.execute' then
      ProcHTTP
    else if Name = '@addpicture' then
    begin
      FPicture.Clear;
      s := Value;
      while s <> '' do
      begin
        n := CharPos(s,',',['""','''''','()']);
        if n = 0 then
          n := length(s) + 1;
        v1 := TrimEx(Copy(s,1,n - 1),[#9,#10,#13,' ']);
        Delete(s,1,n);

        //v1 := GetNextS(s, ',', '"');

        v2 := TrimEx(GetNextS(v1, '='),[#9,#10,#13,' ']);
        if v1 = '' then
        begin
          v1 := CopyFromTo(v2, '(', ')', true);
          v2 := '@' + CopyTo(v2, '(');
        end;
        PicValue(FPicture, v2, v1);
      end;
        Synchronize(AddPicture);
    end else
      raise Exception.Create(Format(_INCORRECT_DECLORATION_,[Name]));
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

procedure TDownloadThread.LockList;
begin
  FPictureList.BeginAddList;
end;

procedure TDownloadThread.ProcHTTP;
var
  s: string;

begin
  FBeforeScript.Process(SE, DE, FE, VE, VE);
  try
    s := FHTTP.Get(CalcValue(FHTTPRec.Url,VE,nil));
    inc(FHTTPRec.Counter);
  finally
  end;
  FXML.Parse(s);
  Synchronize(LockList);
  FXMLScript.Process(SE,DE,FE,VE,VE,FXML.TagList);
  Synchronize(UnlockList);
  FAfterScript.Process(SE,DE,FE,VE,VE);
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
  FPictureList.EndAddList;
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
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    Items[i].Free;
  inherited;
end;

function TPictureTagList.Add(TagName: String): TPictureTag;
begin
  if Find(TagName) > -1 then
  begin
    Result := nil;
    Exit;
  end;

  Result := TPictureTag.Create;
  Result.Attribute := taNone;
  Result.Name := TagName;

  inherited Add(Result);
end;

function TPictureTagList.Find(TagName: String): integer;
var
  i: integer;
begin
  TagName := LowerCase(TagName);
  for i := 0 to Count - 1 do
    if LowerCase(Items[i].Name) = TagName then
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

procedure TTPicture.Assign(Value: TTPicture);
begin
  FChecked := Value.Checked;
  FFinished := Value.Finished;
  FLinked.Assign(Value.Linked);
  FMeta.Assign(Value.Meta);
  FParent := Value.Parent;
  FRemoved := false;
  FTags.Assign(Value.Tags);
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
  FFinished := false;
  FParent := nil;
  FMeta := TValueList.Create;
  FLinked := TPictureLinkList.Create;
  FTags := TPictureTagLinkList.Create;
end;

destructor TTPicture.Destroy;
begin
  FMeta.Free;
  FLinked.Free;
  FTags.Free;
  inherited;
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

procedure TTPicture.SetRemoved(Value: boolean);
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

procedure TPictureLinkList.Add(APicture: TTPicture);
begin
  inherited Add(APicture);
  if Assigned(FOnAddPicture) then
    FOnAddPicture(APicture);
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

// TTPictureList

constructor TPictureList.Create;
begin
  inherited;
  FTags := TPictureTagList.Create;
end;

destructor TPictureList.Destroy;
begin
  FTags.Free;
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
        p.Parent := nil;
        if p.Tags <> nil then
        begin
          for i := 0 to p.Tags.Count - 1 do
            p.Tags[i].Linked.Remove(p);
        end;
        if p.Linked <> nil then
          for i := 0 to p.Linked.Count - 1 do
            Remove(p.Linked[i]);
        p.Free;
      end;
  end;
end;

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
          with List.Items[i] do
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

procedure TResourceFields.Notify(Ptr: Pointer; Action: TListNotification);
begin
  case Action of
    lnDeleted:
      Dispose(Ptr);
  end;
end;

function TResourceFields.Get(Index: integer): TResourceField;
var
  p: PResourceField;
begin
  p := inherited Items[Index];
  Result := p^;
end;

procedure TResourceFields.Put(Index: integer; Value: TResourceField);
var
  p: PResourceField;
begin
  p := inherited Items[Index];
  p^ := Value;
end;

function TResourceFields.GetValue(ItemName: String): Variant;
var
  i: integer;
begin
  ItemName := LowerCase(ItemName);
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
  p: TResourceField;
begin
  ItemName := LowerCase(ItemName);
  for i := 0 to Count - 1 do
    if Items[i].resname = ItemName then
    begin
      p := Items[i];
      p.resvalue := Value;
      Items[i] := p;
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
  p.resname := LowerCase(resname);
  p.restype := restype;
  p.resvalue := resvalue;
  p.resitems := resitems;
  Result := Add(p);
end;

procedure TThreadHandler.CreateThreads(acount: integer);
var
  d: TDownloadThread;

begin
  FFinishQueue := false;
  FFinishThreads := false;
  FQueue.Clear;
  while Count < acount do
  begin
    inc(FCount);
    d := TDownloadThread.Create;
    d.FreeOnTerminate := true;
    d.Finish := Finish;
    d.OnTerminate := ThreadTerminate;
    with d.HTTP.ProxyParams do
    begin
      ProxyServer := Proxy.Host;
      ProxyPort := Proxy.Port;
      BasicAuthentication := Proxy.Auth;
      ProxyUserName := Proxy.Login;
      ProxyPassword := Proxy.Password;
    end;
    d.HTTP.CookieList := FCookie;
    Add(d);
  end;
end;

function TThreadHandler.Finish(t: TDownloadThread): integer;
begin
  if FFinishThreads then
    Result := THREAD_FINISH
  else if FQueue.Count > 0 then
  begin
    FQueue[0].CreateJob(t);
    FQueue.Delete(0);
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
      if p.Job = THREAD_STOP then
        SetEvent(p.EventHandle);
    end;
  finally
    UnlockList;
  end;
end;

procedure TThreadHandler.FinishThreads(Force: boolean);
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
      if p.Job = THREAD_STOP then
        SetEvent(p.EventHandle);
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

procedure TThreadHandler.AddToQueue(R: TResource);
begin
  FQueue.Add(R);
  CheckIdle;
end;

procedure TThreadHandler.CheckIdle;
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
      if p.Job = THREAD_STOP then
      begin
        SetEvent(p.EventHandle);
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
  FQueue := TResourceLinkList.Create;
  FFinishThreads := true;
end;

destructor TThreadHandler.Destroy;
begin
  FQueue.Free;
  inherited;
end;

end.
