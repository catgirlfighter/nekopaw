unit MyXMLParser;

interface

uses
  Classes, SysUtils, common;

type

  TAttr = record
    Name: String;
    Value: String;
  end;

  TAttrs = array of TAttr;

  TAttrList = class(TObject)
  private
    FAttrs: TAttrs;
    function GetCount: Integer;
  protected
    function GetAttr(AValue: Integer): TAttr;
  public
    procedure Assign(AAttrs: TAttrList);
    property Attribute[AValue: Integer]: TAttr read GetAttr; default;
    property Count: Integer read GetCount;
    procedure Add(AName: String; AValue: String);
    procedure Clear;
    function Value(AName: String): String;
    function IndexOf(AName: String): Integer;
    constructor Create;
    destructor Destroy; override;
  end;

  TTagList = class;

  TTag = class(TObject)
  private
    FParent: TTag;
    FName: String;
    FAttrList: TAttrList;
    FText: String;
    FChilds: TTagList;
  protected
    procedure SetName(Value: String);
    procedure SetText(Value: String);
  public
    constructor Create;
    destructor Destroy; override;
    function FindParent(TagString: String): TTag;
    property Name: String read FName write SetName;
    property Attrs: TAttrList read FAttrList write FAttrList;
    property Text: String read FText write SetText;
    property Childs: TTagList read FChilds;
    property Parent: TTag read FParent write FParent;
  end;

  TTagList = class(TList)
    protected
      function Get(ItemIndex: Integer): TTag;
      procedure Notify(Ptr: Pointer; Action: TListNotification); override;
    public
    procedure GetList(Tag: String; AAttrs: TAttrList; AList: TTagList);
    procedure CopyList(AList: TTagList; Parent: TTag);
    procedure ExportToFile(fname: string);
    function FirstItemByName(tagname: string): ttag;
      property Items[ItemName: integer]: TTag read Get; default;
      function CreateChild(Parent: TTag): TTag;
      procedure CopyTag(ATag: TTag; Parent: TTag = nil);
  end;

  TXMLOnTagEvent = procedure(ATag: TTag) of object;
  TXMLOnEndTagEvent = procedure(ATag: String) of object;
  TXMLOnContentEvent = procedure(ATag: TTag; AContent: String) of object;

  TMyXMLParser = class(TObject)
  private
    FOnStartTag, FOnEmptyTag, FOnEndTag: TXMLOnTagEvent;
    FOnContent: TXMLOnContentEvent;
//    : TXMLOnEndTagEvent;
//    : TXMLOnContentEvent;
    FTagList: TTagList;
  protected
  public
    procedure JSON(starttag: string; const S: TStrings); overload;
    procedure JSON(starttag: string; S: String); overload;
    property OnStartTag: TXMLOnTagEvent read FOnStartTag write FOnStartTag;
    property OnEmptyTag: TXMLOnTagEvent read FOnEmptyTag write FOnEmptyTag;
    property OnEndTag: TXMLOnTagEvent read FOnEndTag write FOnEndTag;
    property OnContent: TXMLOnContentEvent read FOnContent write FOnContent;
    procedure Parse(S: String); overload;
    procedure Parse(S: TStrings); overload;
    property TagList: TTagList read FTagList;
  end;

  procedure JSONParseChilds(parent: TTag; TagList: TTagList; tagname,s: string);
  procedure JSONParseValue(tag: ttag; TagList: TTagList; s: string);
  procedure JSONParseTag(tag: ttag; TagList: TTagList; S: String);

implementation

{*********** JSON ********************}

const
  JSONISL: array[0..2] of string = ('""','[]','{}');

//parse childs
procedure JSONParseChilds(parent: TTag; TagList: TTagList; tagname,s: string);
var
  n: string;
  tag: TTag;

begin
  while s <> '' do
  begin
    n := Trim(CopyTo(s,',',JSONISL,true));

    tag := TagList.CreateChild(parent);
    tag.Name := tagname;
    tag.Attrs := TAttrList.Create;

    if n <> '' then
    case n[1] of
      '[': JSONParseChilds(tag,TagList,'',Copy(n,2,Length(n)-2));
      '{': JSONParseTag(tag,TagList,Copy(n,2,Length(n)-2));
      else
        if CharPos(n,':',JSONISL) = -1 then
          tag.Text := n
        else
          JSONParseValue(tag,TagList,n);
    end;


    //JSONParseValue(tag,TagList,trim(n));
  end;
end;

//parsetag

procedure JSONParseValue(tag: ttag; TagList: TTagList; s: string);
var
  tagname: string;
  value: string;
  child: ttag;

begin

  if s = '' then
    raise Exception.Create('JSON Parse: empty value');

  tagname := TrimEx(CopyTo(s,':',JSONISL,true),[' ','"']);
  s := TrimEx(s,[' ','"']);

  if s = '' then
  begin
    value := tagname;
    tagname := '';
  end else
    value := s;

  case value[1] of
    '{':
    begin
      child := TagList.CreateChild(tag);
      child.Name := tagname;
      child.Attrs := TAttrList.Create;

      JSONParseTag(child,TagList,Copy(value,2,Length(value)-2));
    end;
    '[': JSONParseChilds(tag,TagList,tagname,Copy(value,2,Length(value)-2));
    else
    begin
      if tag = nil then
      begin
        tag := TagList.CreateChild(nil);
        tag.Attrs := TAttrList.Create;
      end;
      if tagname = '' then
        tag.Text := trim(value,'"')
      else
        tag.Attrs.Add(tagname,value);
    end;
  end;


end;

procedure JSONParseTag(tag: ttag; TagList: TTagList; S: String);

var
  n: string;

begin
  while s <> '' do
  begin
    n := Trim(CopyTo(s,',',JSONISL,true));

    JSONParseValue(tag,TagList,n);
  end;
end;

{*********** JSON ********************}

procedure TTagList.Notify(Ptr: Pointer; Action: TListNotification);
var
  p: TTag;

begin
  case Action of
    lnDeleted:
      begin
        p := Ptr;
        p.Free;
      end;
  end;
end;

function TTagList.Get(ItemIndex: Integer): TTag;
begin
  Result := inherited Get(ItemIndex);
end;

procedure TTagList.GetList(Tag: String; AAttrs: TAttrList; AList: TTagList);
var
  i,j: integer;
  b: boolean;
begin
  Tag := lowercase(Tag);
  for i := 0 to Count -1 do
  begin
    if Items[i].Name = Tag then
    begin
      b := true;
      if Assigned(AAttrs) then
        for j := 0 to AAttrs.Count -1 do
          if (Items[i].Attrs.Value(AAttrs[j].Name) <> AAttrs[j].Value) or
            not ((AAttrs[j].Value = '') and (Items[i].Attrs.Value(AAttrs[j].Name) <> '')) then
          begin
            b := false;
            Break;
          end;

      if b then
        AList.CopyTag(Items[i])
      else
        Items[i].Childs.GetList(Tag,AAttrs,AList);
    end else
      Items[i].Childs.GetList(Tag,AAttrs,AList);
  end;
end;

function TTagList.CreateChild(Parent: TTag): TTag;
begin
  Result := TTag.Create;
  Result.Parent := Parent;
  if Parent <> nil then
    Parent.Childs.Add(Result)
  else
    Add(Result);
end;

procedure TTagList.ExportToFile(fname: string);

  procedure WriteList(List: TTagList; s: tstringlist);
  var
    i,j: integer;
    tmp: string;
  begin
    for i := 0 to List.Count -1 do
    begin
      tmp := '<' + List[i].Name;
      for j := 0 to List[i].Attrs.Count-1 do
          tmp := tmp + ' ' + List[i].Attrs[j].Name + '="'
          + List[i].Attrs[j].Value + '"';
      if List[i].Childs.Count = 0 then
        s.Add(tmp + ' />')
      else
      begin
        s.Add(tmp + '>');
        WriteList(List[i].Childs,s);
        s.Add('</' + List[i].Name + '>');
      end;
    end;
  end;

var
  s: tstringlist;
begin
  s := tstringlist.Create;
  try
    WriteList(Self,s);
    s.SaveToFile(fname,TEncoding.UTF8);
  finally
    s.Free;
  end;
end;

function TTagList.FirstItemByName(tagname: string): ttag;
var
  i: integer;
begin
  for I := 0 to Count -1 do
    if SameText(Items[i].Name,tagname) then
    begin
      Result := Items[i];
      Exit;
    end;
  Result := nil;
end;

procedure TTagList.CopyList(AList: TTagList; Parent: TTag);
var
  i: integer;

begin
  for i := 0 to AList.Count -1 do
    CopyTag(AList[i],Parent);
end;

procedure TTagList.CopyTag(ATag: TTag; Parent: TTag = nil);
var
  p: TTag;

begin
  p := CreateChild(Parent);
  p.Name := ATag.Name;
  p.Text := ATag.Text;
  p.Attrs := TAttrList.Create;
  p.Attrs.Assign(ATag.Attrs);
  p.Childs.CopyList(ATag.Childs,p);
  //Add(p);
end;

constructor TTag.Create;
begin
  inherited;
  FChilds := TTagList.Create;
  FParent := nil;
  FText := '';
  //FAttrList := TAttrList.Create;
end;

destructor TTag.Destroy;
begin
  FChilds.Free;
  inherited;
end;

function TTag.FindParent(TagString: String): TTag;
var
  P: TTag;

begin
  TagString := lowercase(TagString);
  if Name = TagString then
  begin
    Result := Self.Parent;
    Exit;
  end else
  begin
    p := Parent;
    while p <> nil do
      if p.Name = TagString then
      begin
        Result := p;
        Exit;
      end else
        p := p.Parent;
  end;
  Result := Self;
end;

procedure TTag.SetName(Value: String);
begin
  FName := lowercase(Value);
end;

procedure TTag.SetText(Value: String);
begin
  FText := Value;
  {if Assigned(FParent) then
    FParent.Text := FParent.Text + Value;    }
end;

function TAttrList.GetAttr(AValue: Integer): TAttr;
begin
  Result := FAttrs[AValue];
end;

function TAttrList.GetCount: Integer;
begin
  Result := length(FAttrs);
end;

procedure TAttrList.Add(AName: String; AValue: String);
begin
  SetLength(FAttrs, length(FAttrs) + 1);
  with FAttrs[length(FAttrs) - 1] do
  begin
    Name := AName;
    Value := AValue;
  end;
end;

procedure TAttrList.Assign(AAttrs: TAttrList);
var
  i: integer;

begin
  SetLength(FAttrs, AAttrs.Count);
  for i := 0 to AAttrs.Count-1 do
  begin
    FAttrs[i].Name := AAttrs[i].Name;
    FAttrs[i].Value := AAttrs[i].Value;
  end;
end;

procedure TAttrList.Clear;
begin
  FAttrs := nil;
end;

function TAttrList.Value(AName: String): String;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to length(FAttrs) - 1 do
    if UPPERCASE(FAttrs[i].Name) = UPPERCASE(AName) then
    begin
      Result := FAttrs[i].Value;
      Break;
    end;
end;

function TAttrList.IndexOf(AName: String): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to length(FAttrs) - 1 do
    if UPPERCASE(FAttrs[i].Name) = UPPERCASE(AName) then
    begin
      Result := i;
      Break;
    end;
end;

constructor TAttrList.Create;
begin
  inherited;
  FAttrs := nil;
end;

destructor TAttrList.Destroy;
begin
  FAttrs := nil;
  inherited;
end;

procedure TMyXMLParser.Parse(S: String);
var
  FTag: TTag;

  procedure parsetag(adata: string);

    function trimquotes(S: string): string;
    begin
      S := trim(S);
      if (length(S) > 0) and CharInSet(S[1], ['"', '''']) then
        delete(S, 1, 1);
      if (length(S) > 0) and CharInSet(S[length(S)], ['"', '''']) then
        delete(S, length(S), 1);
      Result := S;
    end;

  var
    tagname: string;
    lastattr, attrparams: string;
    Attrs: TAttrList;
    i, li, l, state: Integer;
    stat: Integer;
  begin
    Attrs := TAttrList.Create;
    lastattr := '';
    tagname := '';
    stat := 1;
    adata := REPLACE(adata, #13#10, ' ', true);
    adata := REPLACE(adata, #9, ' ', true);
    // adata := REPLACE(adata,'  ',' ',false,true);
    adata := trim(adata) + ' ';
    li := 1;
    l := length(adata);
    state := 0;
    for i := 1 to l do
    begin
      if li > i then
        continue;
      case adata[i] of
        '/':
          case state of
            0:
              if tagname = '' then
              begin
                li := i + 1;
                stat := -1;
                Break;
              end
              else
              begin
                if (lastattr <> '') then
                  Attrs.Add(lastattr, attrparams);
                lastattr := copy(adata, li, i - li);
                attrparams := '';
                Attrs.Add(lastattr, attrparams);
                stat := 0;
                Break;
              end;
            1:
              if (i = l - 1) and
                ((state = 1) and (CharInSet(adata[i - 1], [' ', '"', ''''])) or
                (state = 0)) then
              begin
                attrparams := trimquotes(copy(adata, li, i - li));
                Attrs.Add(lastattr, attrparams);
                stat := 0;
                Break;
              end;
          end;
        ' ':
          case state of
            0:
              begin
                if (tagname = '') then
                begin
                  tagname := copy(adata, li, i - li);
                  if (length(tagname) > 0) and CharInSet(tagname[1], ['!']) then
                  begin
                    Attrs.Free;
                    Exit;
                  end;
                end
                else
                begin
                  if lastattr <> '' then
                    Attrs.Add(lastattr, attrparams);
                  lastattr := copy(adata, li, i - li);
                  attrparams := '';
                  if lastattr = '/' then
                  begin
                    stat := 0;
                    Break;
                  end;
                end;
                li := i + 1;
                while (li < l) and (adata[li] = ' ') do
                  inc(li);
              end;
            1:
              begin
                state := 0;
                attrparams := trimquotes(copy(adata, li, i - li));
                if i = l then
                  Attrs.Add(lastattr, attrparams);
                li := i + 1;
                while (li < l) and (adata[li] = ' ') do
                  inc(li);
              end;
          end;
        '=':
          if (tagname <> '') and (state = 0) then
          begin
            state := 1;
            if (li <> i) and (lastattr <> '') then
              Attrs.Add(lastattr, attrparams);
            lastattr := copy(adata, li, i - li);
            attrparams := '';
            li := i + 1;
            while (li < l) and (adata[li] = ' ') do
              inc(li);
          end;
        '"':
          if tagname <> '' then
            case state of
              1:
                state := 2;
              2:
                state := 1;
            end;
        '''':
          if tagname <> '' then
            case state of
              1:
                state := 3;
              3:
                state := 1;
            end;
      end;
    end;
    case stat of
      - 1:
      begin
        if Assigned(FOnEndTag) then
          //FOnEndTag(copy(adata, li, length(adata) - li));
          FOnEndTag(FTag);

        if Assigned(FTag) then
          FTag := FTag.FindParent(copy(adata, li, length(adata) - li));

      end;
      0:
      begin
        FTag := TagList.CreateChild(FTag);
        FTag.Name := tagname;
        FTag.Attrs := Attrs;

        if Assigned(FOnEmptyTag) then
          //FOnEmptyTag(tagname, Attrs);
          FOnEmptyTag(FTag);

        FTag := FTag.Parent;
      end;
      1:
      begin
        FTag := TagList.CreateChild(FTag);
        FTag.Name := tagname;
        FTag.Attrs := Attrs;

        if Assigned(FOnStartTag) then
          //FOnStartTag(tagname, Attrs);
          FOnStartTag(FTag);
      end;
    end;
    //Attrs.Free;
  end;

  function checkstr(S: string): boolean;
  var
    i: Integer;
  begin
    S := trim(S);
    Result := true;
    for i := 1 to length(S) do
      if not CharInSet(S[i], [' ', #13, #10]) then
        Exit;
    Result := false;
  end;

var
  i, li, l, state: Integer;
  txt: string;
  sr: string;

begin
  if not Assigned(FTagList) then
    FTagList := TTagList.Create
  else
    FTagList.Clear;

  FTag := nil;

//  try
    txt := '';
    state := 0;
    l := length(S);
    i := 1;
    li := 1;
    while true do
    begin
      while (i <= l) and (S[i] <> '<') do
        inc(i);
      txt := copy(S, li, i - li);
      if Assigned(FTag) then
        FTag.Text := FTag.Text + txt;
      if Assigned(FOnContent) and (checkstr(txt)) then
        FOnContent(FTag,txt);
      inc(i);
      li := i;
      if i >= l then
        Break;
      while (i <= l) and ((S[i] <> '>') or (state <> 0)) do
      begin
        case S[i] of
          '"':
            case state of
              0:
                state := 1;
              1:
                state := 0;
            end;
          '''':
            case state of
              0:
                state := 2;
              2:
                state := 0;
            end;
        end;
        inc(i)
      end;
      if i > l then
        Break;
      sr := copy(S, li, i - li);
      parsetag(sr);
      inc(i);
      li := i;
    end;
{  finally
    FTag.Free;
  end;   }
end;

procedure TMyXMLParser.JSON(starttag: string; S: String);
var
  i: integer;
begin
  if not Assigned(FTagList) then
    FTagList := TTagList.Create
  else
    FTagList.Clear;

  JSONParseTag(nil,FTagList,S);

  for i := 0 to FTagList.Count -1 do
    if FTagList[i].Name = '' then
      FTagList[i].Name := starttag;
end;

procedure TMyXMLParser.JSON(starttag: string; const S: TStrings);
begin
  JSON(starttag,s.Text);
end;

procedure TMyXMLParser.Parse(S: TStrings);
begin
  Parse(S.Text);
end;

end.
