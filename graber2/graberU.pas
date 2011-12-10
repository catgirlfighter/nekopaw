unit graberU;

interface

uses Classes, SysUtils, Windows, idHTTP;

type

  TListValue = class(TObject)
  private
    FName: String;
    FValue: String;
  public
    constructor Create;
    property Name: String read FName write FName;
    property Value: String read FValue write FValue;
  end;

  TValueList = class(TList)
  protected
    function Get(Index: Integer): TListValue;
    function GetValue(ItemName: String): String;
    procedure SetValue(ItemName: String; Value: String); virtual;
    function FindItem(ItemName: String): TListValue;
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    destructor Destroy; override;
    property Items[Index: Integer]: TListValue read Get;
    property ItemByName[ItemName: String]: TListValue read FindItem;
    property Values[ItemName: String]: String read GetValue write SetValue;
    default;
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
    procedure SetValue(ItemName: String; Value: String); override;
    function FindItem(ItemName: String): TPictureValue;
    function GetState(ItemName: String): TPictureValueState;
    procedure SetState(ItemName: String; Value: TPictureValueState);
  public
    property Items[Index: Integer]: TPictureValue read Get;
    property ItemByName[ItemName: String]: TPictureValue read FindItem;
    property State[ItemName: String]
      : TPictureValueState read GetState write SetState;
  end;

  TScriptSectionList = class;

  TSectionType = (stTag, stCondition);

  TScriptSection = class(TObject)
  private
    FSectionDescription: String;
    FSectionType: TSectionType;
    FDeclorations: TValueList;
    FChildSections: TScriptSectionList;
  public
    constructor Create;
    destructor Destroy; override;
    property SectionDescription
      : String read FSectionDescription write FSectionDescription;
    property SectionType: TSectionType read FSectionType write FSectionType;
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
    property RequestMethod
      : THTTPRequestMethod read FRequestMethod write FRequestMethod;
    property PostString: String read FPostString write FPostString;
    property Script: TScriptSection read FScript;
  end;

  TThreadDSettings = class(TDownloadSettings)
  private
    FPage: Integer;
  public
    constructor Create;
    property Page: Integer read FPage write FPage;
  end;

  TLoginDSettings = class(TDownloadSettings)
  private
    FLogin: String;
    FPassword: String;
    FNeedAuth: Boolean;
  public
    constructor Create;
    property Login: String read FLogin write FLogin;
    property Password: String read FLogin write FLogin;
    property NeedAuth: Boolean read FNeedAuth write FNeedAuth;
  end;

  TResource = class(TObject)
  private
    FFileName: String;
    FURL: String;
    FIconFile: String;
    FLoginPage: TLoginDSettings;
    FFirstPage: TDownloadSettings;
    FThread: TThreadDSettings;
  public
    constructor Create;
    destructor Destroy; override;
    property FileName: String read FFileName;
    property URL: String read FURL;
    property IconFile: String read FIconFile;
    property LoginPage: TLoginDSettings read FLoginPage;
    property FirstPage: TDownloadSettings read FFirstPage;
    property Thread: TThreadDSettings read FThread;
  end;

  TResourceLinkList = class(TList)
  protected
    function Get(Index: Integer): TResource;
  public
    property Items[Index: Integer]: TResource read Get; default;
  end;

  TResourceList = class(TList)
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
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
  result := inherited Get(Index);
end;

function TValueList.GetValue(ItemName: String): String;
var
  p: TListValue;
begin
  p := FindItem(ItemName);
  if p = nil then
    result := ''
  else
    result := p.Value;
end;

procedure TValueList.SetValue(ItemName: String; Value: String);
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
    result := inherited Get(i);
    if LowerCase(result.Name) = ItemName then
      Exit;
  end;
  result := nil;
end;

// TPictureValueList 

function TPictureValueList.Get(Index: Integer): TPictureValue;
begin
  result := ( inherited Get(Index)) as TPictureValue;
end;

procedure TPictureValueList.SetValue(ItemName: String; Value: String);
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
  result := ( inherited FindItem(ItemName)) as TPictureValue;
end;

function TPictureValueList.GetState(ItemName: String): TPictureValueState;
var
  p: TPictureValue;
begin
  p := FindItem(ItemName);
  if p <> nil then
    result := p.State
  else
    result := pvsNone;
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
  FSectionDescription := '';
  FSectionType := stTag;
  FDeclorations := TValueList.Create;
  FChildSections := TScriptSectionList.Create;
end;

destructor TScriptSection.Destroy;
begin
  FDeclorations.Free;
  FChildSections.Free;
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
  Page := 0;
end;

// TLoginDSettings 

constructor TLoginDSettings.Create;
begin
  inherited;
  FLogin := '';
  FPassword := '';
  FNeedAuth := false;
end;

// TResource 

constructor TResource.Create;
begin
  FFileName := '';
  FURL := '';
  FIconFile := '';
  FLoginPage := TLoginDSettings.Create;
  FFirstPage := TDownloadSettings.Create;
  FThread := TThreadDSettings.Create;
end;

destructor TResource.Destroy;
begin
  FLoginPage.Free;
  FFirstPage.Free;
  FThread.Free;
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
  FreeAndNil(FLinked);
  inherited;
end;

// TPictureTagLinkList 

function TPictureTagLinkList.Get(Index: Integer): TPictureTag;
begin
  result := inherited Get(Index);
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
    result := nil;
    Exit;
  end;

  result := TPictureTag.Create;
  result.Attribute := taNone;
  result.Name := TagName;

  inherited Add(result);
end;

function TPictureTagList.Find(TagName: String): Integer;
var
  i: Integer;
begin
  TagName := LowerCase(TagName);
  for i := 0 to Count - 1 do
    if LowerCase(Items[i].Name) = TagName then
    begin
      result := i;
      Exit;
    end;
  result := -1;
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
  FFinished := False;
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
  result := inherited Get(Index);
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
