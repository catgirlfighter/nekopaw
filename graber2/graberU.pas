unit graberU;

interface

uses Classes, SysUtils, Variants, Windows, idHTTP, MyXMLParser;

type

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
  protected
    function Get(Index: Integer): TListValue;
    function GetValue(ItemName: String): Variant;
    procedure SetValue(ItemName: String; Value: Variant); virtual;
    function FindItem(ItemName: String): TListValue;
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    destructor Destroy; override;
    procedure Assign(List: TValueList; AOperator: TListAssignOp = laCopy);
    property Items[Index: Integer]: TListValue read Get;
    property ItemByName[ItemName: String]: TListValue read FindItem;
    property Values[ItemName: String]: Variant read GetValue
      write SetValue; default;
    property Count;
  end;

  TPictureValueState = (pvsNone, pvsKey, pvsNoduble);

  TPictureValue = class(TListValue)
  private
    FState: TPictureValueState;
  public
    constructor Create;
    property State: TPictureValueState read FState write FState;
  end;

  TPictureValueList = class(TValueList)
  protected
    function Get(Index: Integer): TPictureValue;
    procedure SetValue(ItemName: String; Value: Variant); override;
    function FindItem(ItemName: String): TPictureValue;
    function GetState(ItemName: String): TPictureValueState;
    procedure SetState(ItemName: String; Value: TPictureValueState);
  public
    property Items[Index: Integer]: TPictureValue read Get;
    property ItemByName[ItemName: String]: TPictureValue read FindItem;
    property State[ItemName: String]: TPictureValueState read GetState
      write SetState;
  end;

  TScriptSection = class;
  TScriptSectionList = class;

  TScriptEvent = procedure(const Parent: String; const Parametres: TValueList;
    var LinkedObj: TObject) of object;

  TValueEvent = procedure(const ValS: Char; const Value: String;
    var Result: Variant; var LinkedObj: TObject) of object;

  TDeclorationEvent = procedure(Values: TValueList) of object;

  TScriptSection = class(TObject)
  private
    FParent: String;
    FCondition: String;
    FParametres: TValueList;
    FDeclorations: TValueList;
    FConditions: TScriptSectionList;
    FChildSections: TScriptSectionList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ParseValues(s: string);
    procedure Process(const SE: TScriptEvent; const VE: TValueEvent;
      const DE: TDeclorationEvent; LinkedObj: TObject = nil);
    procedure Clear;
    property Parent: String read FParent write FParent;
    property Condition: String read FCondition write FCondition;
    property Parametres: TValueList read FParametres;
    property Conditions: TScriptSectionList read FConditions;
    property Declorations: TValueList read FDeclorations;
    property ChildSections: TScriptSectionList read FChildSections;
  end;

  TScriptSectionList = class(TList)
  private
    function Get(Index: Integer): TScriptSection;
  public
    property Items[Index: Integer]: TScriptSection read Get; default;
  end;

  THTTPRequestMethod = (rmGET, rmPOST);

  TDownloadSettings = class(TObject)
  private
    FURL: String;
    FAbsoluteURL: Boolean;
    FRequestMethod: THTTPRequestMethod;
    FPostString: String;
    FScript: TScriptSection;
  public
    constructor Create;
    destructor Destroy; override;
    property URL: String read FURL write FURL;
    property AbsoluteURL: Boolean read FAbsoluteURL write FAbsoluteURL;
    property RequestMethod: THTTPRequestMethod read FRequestMethod
      write FRequestMethod;
    property PostString: String read FPostString write FPostString;
    property Script: TScriptSection read FScript;
  end;

  TThreadDSettings = class(TDownloadSettings)
  private
    FPage: Integer;
    FCount: Integer;
    FCounter: Integer;
  public
    constructor Create;
    property Page: Integer read FPage write FPage;
    property Count: Integer read FCount write FCount;
    property Counter: Integer read FCounter write FCounter;
  end;

  TLoginDSettings = class(TDownloadSettings)
  private
    FAuth: Boolean;
    FLogin: String;
    FPassword: String;
  public
    constructor Create;
    property NeedAuth: Boolean read FAuth write FAuth;
    property Login: String read FLogin write FLogin;
    property Password: String read FLogin write FLogin;
  end;

  TResourceFields = class(TList)

  end;

  TResource = class(TObject)
  private
    FFileName: String;
    FResName: String;
    FURL: String;
    FIconFile: String;
    FParent: TResource;
    FFields: TResourceFields;
    FLoginPage: TLoginDSettings;
    FFirstPage: TDownloadSettings;
    FThread: TThreadDSettings;
    FInherit: Boolean;
  protected
    procedure ScriptEvent(const Parent: String; const Parametres: TValueList;
      var LinkedObj: TObject);
    procedure ValueEvent(const ValS: Char; const Value: String;
      var Result: Variant; var LinkedObj: TObject);
    procedure DeclorationEvent(Values: TValueList);
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(FName: String);
    property FileName: String read FFileName;
    property Name: String read FResName write FResName;
    property URL: String read FURL;
    property IconFile: String read FIconFile;
    property Fields: TResourceFields read FFields;
    property LoginPage: TLoginDSettings read FLoginPage;
    property FirstPage: TDownloadSettings read FFirstPage;
    property Thread: TThreadDSettings read FThread;
    property Parent: TResource read FParent write FParent;
    property Inherit: Boolean read FInherit write FInherit;
  end;

  TResourceLinkList = class(TList)
  protected
    function Get(Index: Integer): TResource;
  public
    property Items[Index: Integer]: TResource read Get; default;
  end;

  TResourceList = class(TResourceLinkList)
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    procedure LoadList(Dir: String);
  end;

  TDownloadThread = class(TThread)
  private
    FHTTP: TIdHTTP;
  public
    procedure Execute; override;
    property HTTP: TIdHTTP read FHTTP;
  end;

  TPictureLinkList = class;

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
    function Get(Index: Integer): TPictureTag;
    procedure Put(Index: Integer; Item: TPictureTag);
  public
    property Items[Index: Integer]: TPictureTag read Get write Put; default;
    property Count;
  end;

  TPictureTagList = class(TPictureTagLinkList)
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(TagName: String): TPictureTag;
    function Find(TagName: String): Integer;
    procedure ClearZeros;
    property Items;
    property Count;
  end;

  TTPicture = class(TObject)
  private
    FParent: TTPicture;
    FMeta: TPictureValueList;
    FLinked: TPictureLinkList;
    FTags: TPictureTagLinkList;
    FChecked: Boolean;
    FFinished: Boolean;
    FRemoved: Boolean;
  protected
    procedure SetParent(Item: TTPicture);
    procedure SetRemoved(Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    property Removed: Boolean read FRemoved write SetRemoved;
    property Finished: Boolean read FFinished;
    property Checked: Boolean read FChecked write FChecked;
    property Parent: TTPicture read FParent write SetParent;
    property Tags: TPictureTagLinkList read FTags;
    property Meta: TPictureValueList read FMeta;
    property Linked: TPictureLinkList read FLinked;
  end;

  TPictureLinkList = class(TList)
  protected
    function Get(Index: Integer): TTPicture;
    procedure Put(Index: Integer; Item: TTPicture);
  public
    property Items[Index: Integer]: TTPicture read Get write Put; default;
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

implementation

uses LangString, common;

// TListValue

constructor TListValue.Create;
begin
  inherited;
  FName := '';
  FValue := '';
end;

// TPictureValue

constructor TPictureValue.Create;
begin
  inherited;
  FState := pvsNone;
end;

// TValueList

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

function TValueList.Get(Index: Integer): TListValue;
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
  p := FindItem(ItemName);
  if p = nil then
  begin
    p := TListValue.Create;
    p.Name := ItemName;
    p.Value := Value;
    Add(p);
  end
  else
    p.Value := Value;
end;

function TValueList.FindItem(ItemName: String): TListValue;
var
  i: Integer;
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

procedure TValueList.Assign(List: TValueList; AOperator: TListAssignOp);
var
  i: Integer;
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
          Add(p);
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

function TPictureValueList.Get(Index: Integer): TPictureValue;
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
end;

// TScriptSection

constructor TScriptSection.Create;
begin
  inherited;
  FParent := '';
  FCondition := '';
  FParametres := TValueList.Create;
  FDeclorations := TValueList.Create;
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

procedure TScriptSection.ParseValues(s: string);

const
  EmptyS = [#9, #10, #13, ' ', '$'];

  isl: array [0 .. 7] of string = ('''''', '""', '()', '=;', '^.', '?.',
    '{}', '$=');

  Cons = ['=', '<', '>', '!'];

var
  i, l, n, p: Integer;
  v1, v2, tmp: string;
  Child: TScriptSection;
begin
  i := 1;
  l := length(s);
  while i <= l do
  begin
    case s[i] of
      #9, #10, #13, ' ':
        inc(i);
      '{':
        begin
          n := CharPos(s, '}', isl, i + 1);

          if n = 0 then
            raise Exception.Create(Format(_SCRIPT_READ_ERROR_,
              [_INCORRECT_DECLORATION_ + IntToStr(i)]));

          i := n + 1;
        end;
      '^':
        begin
          n := CharPos(s, ':', isl, i + 1);

          if n = 0 then
            raise Exception.Create(Format(_SCRIPT_READ_ERROR_,
              [_INCORRECT_DECLORATION_ + IntToStr(i)]));

          tmp := TrimEx(Copy(s, i + 1, n - i - 1), EmptyS);

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
                Child.Parametres[v2] := '!'
              else
                Child.Parametres[v2] :=
                  TrimEx(Copy(s, p + 1, length(v2) - p - 1), EmptyS);
          end;

          i := n + 1;

          n := CharPos(s, '.', isl, i);

          if n = 0 then
          begin
            Child.Free;
            raise Exception.Create(Format(_SCRIPT_READ_ERROR_,
              [_INCORRECT_DECLORATION_ + IntToStr(i)]));
          end;

          Child.ParseValues(Copy(s, i, n - i));

          i := n + 1;
        end;
      '?':
        begin
          n := CharPos(s, ':', isl, i + 1);

          if n = 0 then
            raise Exception.Create(Format(_SCRIPT_READ_ERROR_,
              [_INCORRECT_DECLORATION_ + IntToStr(i)]));

          tmp := TrimEx(Copy(s, i + 1, n - i - 1), EmptyS);

          Child := TScriptSection.Create;
          Child.Parent := Parent;
          Child.Parametres.Assign(Parametres);
          Child.Condition := tmp;

          i := n + 1;

          n := CharPos(s, '.', isl, i);

          if n = 0 then
          begin
            Child.Free;
            raise Exception.Create(Format(_SCRIPT_READ_ERROR_,
              [_INCORRECT_DECLORATION_ + IntToStr(i)]));
          end;

          Child.ParseValues(Copy(s, i, n - i));

          i := n + 1;
        end;
    else
      begin
        n := CharPos(s, '=', isl, i + 1);

        if n = 0 then
          raise Exception.Create(Format(_SCRIPT_READ_ERROR_,
            [_INCORRECT_DECLORATION_ + IntToStr(i)]));

        v1 := TrimEx(Copy(s, i, n - i), EmptyS);
        i := n + 1;

        n := CharPos(s, ';', isl, i);

        if n = 0 then
          raise Exception.Create(Format(_SCRIPT_READ_ERROR_,
            [_INCORRECT_DECLORATION_ + IntToStr(i)]));

        v2 := TrimEx(Copy(s, i, n - i), EmptyS);

        if v2 = '' then
          raise Exception.Create(Format(_SCRIPT_READ_ERROR_,
            [_INCORRECT_DECLORATION_ + IntToStr(i)]));

        Declorations[v1] := v2;

        i := n + 1;
      end;
    end;
  end;
end;

procedure TScriptSection.Process(const SE: TScriptEvent; const VE: TValueEvent;
  const DE: TDeclorationEvent; LinkedObj: TObject);

var
  Lnk: TObject;

  function CalcValue(s: String): Variant;
  const
    op = ['(', ')', '+', '-', '<', '>', '=', '!', '/', '\', '&', ',',
      '?', '~', '|', ' '];
    p = ['$', '%', '#', '@'];
    isl: array [0 .. 1] of string = ('""', '''''');

  var
    n1, n2: Integer;
    cstr: string;
    rstr: Variant;

  begin

    if not Assigned(VE) then
      Exit;

    n1 := CharPos(s, '{', isl);

    while n1 > 0 do
    begin
      n2 := CharPos(s, '}', [], n1 + 1);
      if n2 = 0 then
        raise Exception.Create(Format(_SYMBOL_MISSED_, ['}', n1]));
      Delete(s, n1, n2 - n1 + 1);
      n1 := CharPos(s, '{', isl);
    end;

    while true do
    begin
      n1 := CharPosEx(s, p, isl, n2 + 1);

      if n1 = 0 then
        Break;

      n2 := CharPosEx(s, op, [], n1 + 1);

      if n2 = 0 then
        cstr := Copy(s, n1 + 1, length(s) - n1 - 1)
      else
        cstr := Copy(s, n1 + 1, n2 - n1 - 2);

      rstr := null;
      VE(s[n1], cstr, rstr, Lnk);
      cstr := s[n1] + cstr;
      Replace(s, cstr, rstr, false, true);

      n2 := n1 + length(rstr) - 1;

    end;

    Result := MathCalcStr(s);

  end;

var
  Calced: TValueList;
  i: Integer;

begin
  if Assigned(SE) then
  begin
    Calced := TValueList.Create;
    Calced.Assign(Parametres);

    for i := 0 to Calced.Count - 1 do
      Calced.Items[i].Value := CalcValue(Calced.Items[i].Value);

    SE(Parent, Calced, LinkedObj);

    if not Assigned(DE) then
      FreeAndNil(Calced);
  end;

  if Assigned(DE) then
  begin
    if not Assigned(SE) then
      Calced := TValueList.Create;
    Calced.Assign(Declorations);

    for i := 0 to Calced.Count - 1 do
      Calced.Items[i].Value := CalcValue(Calced.Items[i].Value);

    DE(Calced);

    FreeAndNil(Calced);
  end;

  (* FINISH CONDITIONS DECLORATION *)

  (* FINISH CHILDSECTIONS DECLORATION *)

end;

procedure TScriptSection.Clear;
begin
  FParent := '';
  FCondition := '';
  Conditions.Clear;
  Declorations.Clear;
  ChildSections.Clear;
end;

// TScriptSectionList

function TScriptSectionList.Get(Index: Integer): TScriptSection;
begin
  Result := inherited Get(Index);
end;

// TDownloadSettings

constructor TDownloadSettings.Create;
begin
  inherited;
  FURL := '';
  FAbsoluteURL := false;
  FRequestMethod := rmGET;
  FPostString := '';
  FScript := TScriptSection.Create;
end;

destructor TDownloadSettings.Destroy;
begin
  FScript.Free;
  inherited;
end;

// TThreadDSettings

constructor TThreadDSettings.Create;
begin
  inherited;
  FPage := 0;
  FCount := 0;
  FCounter := 0;
end;

// TLoginDSettings

constructor TLoginDSettings.Create;
begin
  inherited;
  FAuth := false;
  FLogin := '';
  FPassword := '';
end;

// TResource

constructor TResource.Create;
begin
  inherited;
  FFileName := '';
  FURL := '';
  FIconFile := '';
  FParent := nil;
  FInherit := true;
  FFields := TResourceFields.Create;
  FLoginPage := TLoginDSettings.Create;
  FFirstPage := TDownloadSettings.Create;
  FThread := TThreadDSettings.Create;
end;

destructor TResource.Destroy;
begin
  FLoginPage.Free;
  FFirstPage.Free;
  FThread.Free;
  FFields.Free;
  inherited;
end;

procedure TResource.ScriptEvent(const Parent: String;
  const Parametres: TValueList; var LinkedObj: TObject);
begin

end;

procedure TResource.ValueEvent(const ValS: Char; const Value: String;
  var Result: Variant; var LinkedObj: TObject);
begin
  Result := ValS + Value;
end;

procedure TResource.DeclorationEvent(Values: TValueList);

  procedure ProcValue(ItemName: String; ItemValue: Variant);
  begin
    if ItemName = 'url' then
      FURL := ItemValue
    else if ItemName = 'icon' then
      FIconFile := ItemValue
    else if ItemName = 'loginpage.authorazation' then // LoginPage
      LoginPage.NeedAuth := StrToBool(ItemValue)
    else if ItemName = 'loginpage.login' then
      LoginPage.Login := ItemValue
    else if ItemName = 'loginpage.password' then
      LoginPage.Password := ItemValue
    else if ItemName = 'loginpage.url' then
      LoginPage.URL := ItemValue
    else if ItemName = 'loginpage.absoluteurl' then
      LoginPage.AbsoluteURL := ItemValue
    else if ItemName = 'loginpage.method' then
      if LowerCase(ItemValue) = 'post' then
        LoginPage.RequestMethod := rmPOST
      else
        LoginPage.RequestMethod := rmGET
    else if ItemName = 'firstpage.url' then // FirstPage
      FirstPage.URL := ItemValue
    else if ItemName = 'firstpage.absoluteurl' then
      FirstPage.AbsoluteURL := ItemValue
    else if ItemName = 'firstpage.method' then
      if LowerCase(ItemValue) = 'post' then
        FirstPage.RequestMethod := rmPOST
      else
        FirstPage.RequestMethod := rmGET
    else if ItemName = 'thread.url' then // Thread
      Thread.URL := ItemValue
    else if ItemName = 'thread.absoluteurl' then
      Thread.AbsoluteURL := ItemValue
    else if ItemName = 'thread.page' then
      Thread.Page := ItemValue
    else if ItemName = 'thread.count' then
      Thread.Count := ItemValue;
  end;

var
  i: Integer;
  t: TListValue;
begin
  for i := 0 to Values.Count - 1 do
  begin
    t := Values.Items[i];
    ProcValue(LowerCase(t.Name), t.Value);
  end;
end;

procedure TResource.LoadFromFile(FName: String);

const
  isl: array [0 .. 2] of string = ('""', '''''', '{}');

  function GetSectors(var s: string): TValueList;
  var
    n1, n2: Integer;
    pr: String;
  begin
    pr := '';
    Result := TValueList.Create;
    n2 := 0;
    while true do
    begin
      n1 := CharPos(s, '[', isl, n2 + 1);

      if n1 = 0 then
      begin
        if pr <> '' then
          Result[pr] := Copy(s, n2 + 1, length(s) - n2);
        Break;
      end;

      if pr <> '' then
        Result[pr] := Copy(s, n2 + 1, n1 - n2 - 1);

      // Delete(s, 1, n1);

      n2 := CharPos(s, ']', isl, n1 + 1);

      if n2 = 0 then
        Break;

      pr := Copy(s, n1 + 1, n2 - n1 - 1);

      if CheckStr(pr, ['A' .. 'Z', 'a' .. 'z']) then
      begin
        FreeAndNil(Result);
        raise Exception.Create(Format(_SCRIPT_READ_ERROR_,
          [_SYMBOLS_IN_SECTOR_NAME_]));
      end;

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
  sectors: TValueList;
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
      s := s + tmps;
    end;
  finally
    CloseFile(f);
  end;

  sectors := GetSectors(s);

  mainscript := nil;

  try
    mainscript := TScriptSection.Create;
    mainscript.ParseValues(sectors['main']);
    mainscript.Process(ScriptEvent, ValueEvent, DeclorationEvent);
  except
    on e: Exception do
    begin
      if Assigned(mainscript) then
        mainscript.Free;
      sectors.Free;
      raise e;
    end;
  end;

  FFileName := FName;
  FResName := ChangeFileExt(ExtractFileName(FName), '');

  LoginPage.Script.ParseValues(nullstr(sectors['loginpage']));
  FirstPage.Script.ParseValues(nullstr(sectors['firstpage']));
  Thread.Script.ParseValues(nullstr(sectors['thread']));

  sectors.Free;

end;

// TResourceLinkList

function TResourceLinkList.Get(Index: Integer): TResource;
begin
  Result := inherited Get(Index);
end;

// TResourceList

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

procedure TResourceList.LoadList(Dir: String);
var
  a: TSearchRec;
  r: TResource;

begin
  Clear;

  r := TResource.Create;
  r.Inherit := false;
  r.Name := _ALL_;
  Add(r);

  r := nil;

  if not DirectoryExists(Dir) then
    raise Exception.Create(Format(_NO_DIRECTORY_, [Dir]));

  Dir := IncludeTrailingPathDelimiter(Dir);

  if FindFirst(Dir + '*.cfg', faAnyFile, a) = 0 then
  begin
    repeat
      try
        r := TResource.Create;
        r.LoadFromFile(Dir + a.Name);
        Add(r);
      except
        on e: Exception do
        begin
          (* /*/*/ Надо сделать уведомление об ошибке /*/*/ *)
          if Assigned(r) then
            r.Free;
        end;

      end;
    until FindNext(a) <> 0;

  end;
end;


// TDownloadThread

procedure TDownloadThread.Execute;
begin

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

function TPictureTagLinkList.Get(Index: Integer): TPictureTag;
begin
  Result := inherited Get(Index);
end;

procedure TPictureTagLinkList.Put(Index: Integer; Item: TPictureTag);
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
  i: Integer;
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

function TPictureTagList.Find(TagName: String): Integer;
var
  i: Integer;
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
  i: Integer;
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

constructor TTPicture.Create;
begin
  inherited;
  FChecked := false;
  FRemoved := false;
  FFinished := false;
  FParent := nil;
  FMeta := TPictureValueList.Create;
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

procedure TTPicture.SetRemoved(Value: Boolean);
begin
  FRemoved := Value;
end;

// TTPictureLinkList

function TPictureLinkList.Get(Index: Integer): TTPicture;
begin
  Result := inherited Get(Index);
end;

procedure TPictureLinkList.Put(Index: Integer; Item: TTPicture);
begin
  inherited Put(Index, Item);
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
  i: Integer;
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

end.
