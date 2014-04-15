unit MyXMLParser;

interface

uses
  Classes, SysUtils;

type
  TSetOfChar = Set of ANSIChar;

  TAttr = record
    Name: String;
    Value: String;
    Compare: Char;
    qtype: boolean;
  end;

  TAttrs = array of TAttr;

  TAttrList = class(TObject)
  private
    FAttrs: TAttrs;
    FTag: Integer;
    FNoParam: boolean;
    function GetCount: Integer;
    function GetNoParam: boolean;
  protected
    function GetAttr(AValue: Integer): TAttr;
  public
    procedure Assign(AAttrs: TAttrList);
    property Attribute[AValue: Integer]: TAttr read GetAttr; default;
    property Count: Integer read GetCount;
    procedure Add(AName: String; AValue: String; ACompVal: Char = #0;
      AQType: boolean = false);
    procedure Clear;
    function Value(AName: String): String;
    function IndexOf(AName: String): Integer;
    function AsString: String;
    constructor Create;
    destructor Destroy; override;
    property Tag: Integer read FTag write FTag;
    property NoParameters: boolean read GetNoParam write FNoParam;
  end;

  TTagList = class;

  TTagKind = (tkTag, tkInstruction, tkDeclaration, tkComment, tkText);

  TTextKind = (txkFullWithTags, txkFull, txkCurrent);

  TTagState = (tsNormal, tsOnlyText, tsClosable);
  TContentState = (csUnknown, csEmpty, csContent);

  TTag = class(TObject)
  private
    FParent: TTag;
    FName: String;
    FAttrList: TAttrList;
    // FText: String;
    FChilds: TTagList;
    FKind: TTagKind;
    FClosed: boolean;
    FTag: Integer;
    fState: TTagState;
    fCState: TContentState;
  protected
    procedure SetName(Value: String);
    procedure SetText(Value: String);
    function GetText: String; overload;
  public
    constructor Create(AName: String = ''; AKind: TTagKind = tkTag);
    destructor Destroy; override;
    function FindParent(TagString: String; ignoreState: boolean = false): TTag;
    function GetText(TextKind: TTextKind; AddOwnTag: boolean): string; overload;
    property Name: String read FName write SetName;
    property Attrs: TAttrList read FAttrList { write FAttrList };
    property Text: String read GetText write SetText;
    property Childs: TTagList read FChilds;
    property Parent: TTag read FParent write FParent;
    property Kind: TTagKind read FKind write FKind;
    property Closed: boolean read FClosed write FClosed;
    property Tag: Integer read FTag write FTag;
    property State: TTagState read fState write fState;
    property ContentState: TContentState read fCState write fCState;
  end;

  tTagCommentStates = (tcsContent, tcsHelp);
  tTagCommentState = set of tTagCommentStates;

  TTagList = class(TList)
  protected
    function Get(ItemIndex: Integer): TTag;
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    procedure GetList(Tag: String; AAttrs: TAttrList; AList: TTagList);
      overload;
    procedure GetList(Tags: array of string; AAttrs: array of TAttrList;
      AList: TTagList); overload;
    procedure CopyList(AList: TTagList; Parent: TTag);
    procedure ExportToFile(FName: string; Comments: tTagCommentState = []);
    function FirstItemByName(tagname: string): TTag;
    function Text(Comments: tTagCommentState): String; overload;
    function Text: String; overload;
    destructor Destroy; override;
    property Items[ItemName: Integer]: TTag read Get; default;
    function CreateChild(Parent: TTag; AName: String = '';
      TagKind: TTagKind = tkTag): TTag;
    function CopyTag(ATag: TTag; Parent: TTag = nil): TTag;
  end;

  TXMLOnTagEvent = procedure(ATag: TTag) of object;
  TXMLOnEndTagEvent = procedure(ATag: String) of object;
  TXMLOnContentEvent = procedure(ATag: TTag; AContent: String) of object;

  TMyXMLParser = class(TObject) // New realisation little beter then old
  private
    FOnStartTag, FOnEmptyTag, FOnEndTag: TXMLOnTagEvent;
    FOnContent: TXMLOnContentEvent;
    // : TXMLOnEndTagEvent;
    // : TXMLOnContentEvent;
    FTagList: TTagList;
  protected
    procedure CheckHTMLTag(Tag: TTag);
    function CheckHTMLStat(Tag: string): TContentState;
  public
    procedure JSON(starttag: string; const S: TStrings); overload;
    procedure JSON(starttag: string; S: String); overload;
    destructor Destroy; override;
    constructor Create;
    property OnStartTag: TXMLOnTagEvent read FOnStartTag write FOnStartTag;
    property OnEmptyTag: TXMLOnTagEvent read FOnEmptyTag write FOnEmptyTag;
    property OnEndTag: TXMLOnTagEvent read FOnEndTag write FOnEndTag;
    property OnContent: TXMLOnContentEvent read FOnContent write FOnContent;
    procedure Parse(S: String; html: boolean = false); overload;
    // need to make TStream parse
    procedure Parse(S: TStrings; html: boolean = false); overload;
    // can be useful to parse direct filestream without loading memory
    procedure LoadFromFile(FileName: String; html: boolean = false);
    property TagList: TTagList read FTagList;
  end;

procedure JSONParseChilds(Parent: TTag; TagList: TTagList; tagname, S: string);
procedure JSONParseValue(Tag: TTag; TagList: TTagList; S: string);
procedure JSONParseTag(Tag: TTag; TagList: TTagList; S: String);

implementation

{ COMMON }

function TrimEx(S: String; ch: Char = ' '): String; overload;
var
  i, l: Integer;
begin
  l := length(S);
  i := 1;
  while (i <= l) and (S[i] = ch) do
    inc(i);
  if i > l then
    Result := ''
  else
  begin
    while S[l] = ch do
      dec(l);
    Result := copy(S, i, l - i + 1);
  end;
end;

function TrimEx(S: String; ch: TSetOfChar): String; overload;
var
  i, l: Integer;
begin
  l := length(S);
  i := 1;
  while (i <= l) and (CharInSet(S[i], ch)) do
    inc(i);
  if i > l then
    Result := ''
  else
  begin
    while CharInSet(S[l], ch) do
      dec(l);
    Result := copy(S, i, l - i + 1);
  end;
end;

function CharPos(str: string; ch: Char; Isolators, Brackets: array of string;
  From: Integer = 1): Integer;
var
  i, j: Integer;
  // n: integer;
  { s1, } s2: Char;
  { b1, } b2: array of Char;
  st, br: TSetOfChar;
begin
  st := [];
  for i := 0 to length(Isolators) - 1 do
    st := st + [Isolators[i][1]];

  br := [];
  for i := 0 to length(Brackets) - 1 do
    br := br + [Brackets[i][1]];

  // setlength(b1,0);
  setlength(b2, 0);

  // n := 0;
  // s1 := #0;
  s2 := #0;

  for i := From to length(str) do
    if s2 <> #0 then
      if str[i] = s2 then
        s2 := #0
      else
    else if (length(b2) > 0) and (str[i] = b2[length(b2) - 1]) then
      setlength(b2, length(b2) - 1)
      // else
      // if CharInSet(str[i],br) then
      // begin
      // for j := 0 to length(Brackets) - 1 do
      // if (str[i] = Brackets[j][1]) then
      // begin
      // setlength(b2,length(b2)+1);
      // b2[length(b2)-1] := Brackets[j][2];
      // break;
      // end;
      // end else
    else if (length(b2) = 0) and (str[i] = ch) then
    begin
      Result := i;
      Exit;
    end
    else if CharInSet(str[i], st) then
    begin
      for j := 0 to length(Isolators) - 1 do
        if (str[i] = Isolators[j][1]) then
        begin
          // s1 := Isolators[j][1];
          s2 := Isolators[j][2];
          break;
        end;
      // inc(n);
    end
    else if CharInSet(str[i], br) then
    begin
      for j := 0 to length(Brackets) - 1 do
        if (str[i] = Brackets[j][1]) then
        begin
          // setlength(b1,length(b1)+1);
          setlength(b2, length(b2) + 1);
          // b1[length(b1)-1] := Brackets[j][1];
          b2[length(b2) - 1] := Brackets[j][2];
          break;
        end;
    end;
  Result := 0;
end;

function CopyTo(var Source: String; ATo: Char; Isl, Brk: array of string;
  cut: boolean = false): string;
var
  i: Integer;
begin
  i := CharPos(Source, ATo, Isl, Brk);
  if i = 0 then
    Result := copy(Source, 1, length(Source))
  else
    Result := copy(Source, 1, i - 1);
  if cut then
    if i = 0 then
      Delete(Source, 1, length(Source))
    else
      Delete(Source, 1, i);
end;

function GetNextS(var S: string; del: String = ';'; ins: String = ''): string;
var
  n: Integer;
begin
  Result := '';

  if ins <> #0 then
    while true do
    begin
      n := pos(ins, S);
      if (n > 0) and (pos(del, S) > n) then
      begin
        Result := Result + copy(S, 1, n - 1);
        Delete(S, 1, n + length(ins) - 1);
        n := pos(ins, S);
        case n of
          0:
            raise Exception.Create('Can''t find 2nd insulator ''' + ins + ''':'
              + #13#10 + S);
          1:
            Result := Result + copy(S, 1, n + length(ins) - 1);
        else
          Result := Result + copy(S, 1, n - 1);
        end;
        Delete(S, 1, n + length(ins) - 1);
      end
      else
        break;
    end;

  n := pos(del, S);
  if n > 0 then
  begin
    Result := Result + copy(S, 1, n - 1);
    Delete(S, 1, n + length(del) - 1);
  end
  else
  begin
    Result := Result + S;
    S := '';
  end;
end;

{ *********** JSON ******************** }

const
  JSONISL: array [0 .. 0] of string = ('""');
  JSONBRK: array [0 .. 1] of string = ('[]', '{}');

  // parse childs
procedure JSONParseChilds(Parent: TTag; TagList: TTagList; tagname, S: string);
var
  n: string;
  Tag: TTag;

begin
  while S <> '' do
  begin
    n := Trim(CopyTo(S, ',', JSONISL, JSONBRK, true));

    Tag := TagList.CreateChild(Parent);
    Tag.Name := tagname;
    // tag.Attrs := TAttrList.Create;

    if n <> '' then
      case n[1] of
        '[':
          JSONParseChilds(Tag, TagList, '', copy(n, 2, length(n) - 2));
        '{':
          JSONParseTag(Tag, TagList, copy(n, 2, length(n) - 2));
      else
        if CharPos(n, ':', JSONISL, JSONBRK) = -1 then
          Tag.Childs.CreateChild(Tag, n, tkText)
        else
          JSONParseValue(Tag, TagList, n);
      end;

    // JSONParseValue(tag,TagList,trim(n));
  end;
end;

// parsetag

procedure JSONParseValue(Tag: TTag; TagList: TTagList; S: string);
var
  tagname: string;
  Value: string;
  child: TTag;

begin

  if S = '' then
    raise Exception.Create('JSON Parse: empty value');
  // s := StringReplace(s,'\\','&#92;',[rfReplaceAll]);
  S := StringReplace(S, '\"', '&quot;', [rfReplaceAll]);

  tagname := TrimEx(CopyTo(S, ':', JSONISL, JSONBRK, true), [' ', '"']);
  S := TrimEx(S, [' ', '"']);

  if S = '' then
  begin
    Value := tagname;
    tagname := '';
  end
  else
    Value := S;

  case Value[1] of
    '{':
      begin
        child := TagList.CreateChild(Tag, tagname);
        // child.Name := tagname;
        // child.Attrs := TAttrList.Create;

        JSONParseTag(child, TagList, copy(Value, 2, length(Value) - 2));
      end;
    '[':
      JSONParseChilds(Tag, TagList, tagname, copy(Value, 2, length(Value) - 2));
  else
    begin
      if Tag = nil then
      begin
        Tag := TagList.CreateChild(nil);
        // tag.Attrs := TAttrList.Create;
      end;
      if tagname = '' then
        Tag.Childs.CreateChild(Tag, TrimEx(Value, '"'), tkText)
      else
        Tag.Attrs.Add(tagname, Value);
    end;
  end;

end;

procedure JSONParseTag(Tag: TTag; TagList: TTagList; S: String);

var
  n: string;

begin
  while S <> '' do
  begin
    n := Trim(CopyTo(S, ',', JSONISL, JSONBRK, true));

    JSONParseValue(Tag, TagList, n);
  end;
end;

{ *********** JSON ******************** }

procedure WriteList(List: TTagList; var S: String; Comments: tTagCommentState);
const
  qbool: array [boolean] of String = ('"', '''');

var
  i, j: Integer;
  tmp: string;
begin
  for i := 0 to List.Count - 1 do
  begin
    if List[i].Kind = tkText then
      S := S + List[i].Name
    else if (List[i].Kind = tkComment) then
      if tcsContent in Comments then
        S := S + '<!--' + List[i].Name + '-->'
      else
    else if List[i].Kind = tkDeclaration then
      S := S + '<!' + List[i].Name + '>'
    else if List[i].Kind = tkInstruction then
    begin
      tmp := List[i].Name;
      for j := 0 to List[i].Attrs.Count - 1 do
        tmp := tmp + ' ' + List[i].Attrs[j].Name + '=' +
          qbool[List[i].Attrs[j].qtype] + List[i].Attrs[j].Value +
          qbool[List[i].Attrs[j].qtype];
      S := S + '<?' + tmp + '?>';
    end
    else
    begin
      tmp := '<' + List[i].Name;
      for j := 0 to List[i].Attrs.Count - 1 do
        tmp := tmp + ' ' + List[i].Attrs[j].Name + '=' +
          qbool[List[i].Attrs[j].qtype] + List[i].Attrs[j].Value +
          qbool[List[i].Attrs[j].qtype];
      if not List[i].Closed and (List[i].Childs.Count = 0) and
        not(List[i].ContentState in [csContent]) then
        S := S + tmp + ' />'
      else
      begin
        S := S + (tmp + '>');
        WriteList(List[i].Childs, S, Comments);

        if (tcsHelp in Comments) and (List[i].Attrs.Count > 0) then
        begin
          S := S + '</' + List[i].Name + '><!--';

          for j := 0 to List[i].Attrs.Count - 1 do
            S := S + ' ' + List[i].Attrs[j].Name + '=' +
              qbool[List[i].Attrs[j].qtype] + List[i].Attrs[j].Value +
              qbool[List[i].Attrs[j].qtype];
          S := S + ' -->';

        end
        else
          S := S + '</' + List[i].Name + '>';
      end;
    end;
  end;

end;

procedure TTagList.Notify(Ptr: Pointer; Action: TListNotification);
var
  p: TTag;

begin
  case Action of
    lnDeleted:
      begin
        p := Ptr;
        // if p is TTag then
        p.Free;
      end;
  end;
end;

function TTagList.Text(Comments: tTagCommentState): String;
begin
  Result := '';
  WriteList(Self, Result, Comments);
end;

function TTagList.Text: String;
begin
  Result := Text([tcsContent]);
end;

function TTagList.Get(ItemIndex: Integer): TTag;
begin
  Result := inherited Get(ItemIndex);
end;

function CheckRule(v1, v2: string; r: Char): boolean;
var
  tmp: string;

begin
  if (v1 = '') then
  begin
    case r of
      '!':
        Result := v2 <> '';
      '=':
        Result := v2 = '';
    else
      raise Exception.Create('Check Rule: unknown operation "' + r + '"');
    end;
    Exit;
  end;

  if pos(' ', v2) > 0 then // string with spaces
  begin
    Result := SameText(v1, v2);
    Exit;
  end;

  while v1 <> '' do
  begin
    tmp := GetNextS(v1, ' '); // tags

    case r of
      '!':
        if SameText(tmp, v2) then
        begin
          Result := false;
          Exit;
        end;
    else
      if SameText(tmp, v2) then
      begin
        Result := true;
        Exit;
      end;
    end;

  end;

  case r of
    '!':
      Result := true;
    '=':
      Result := false;
  else
    raise Exception.Create('Check Rule: unknown operation "' + r + '"');
  end;

end;

procedure TTagList.GetList(Tag: String; AAttrs: TAttrList; AList: TTagList);

var
  i, j: Integer;
  b: boolean;
  S: string;

begin
  // if not Assigned(AAttrs) then
  // Exit;

  for i := 0 to Count - 1 do
    if (Items[i].Kind = tkTag) then
      if SameText(Items[i].Name, Tag) and
        not(Assigned(AAttrs) and AAttrs.NoParameters and
        (Items[i].Attrs.Count > 0)) then
      begin
        b := true;
        if Assigned(AAttrs) then
          for j := 0 to AAttrs.Count - 1 do
          begin
            S := Items[i].Attrs.Value(AAttrs[j].Name);
            if not CheckRule(S, AAttrs[j].Value, AAttrs[j].Compare) and
              not((AAttrs[j].Value = '') and (S <> '')) then
            begin
              b := false;
              break;
            end;
          end;

        if b then
          AList.CopyTag(Items[i])
        else
          Items[i].Childs.GetList(Tag, AAttrs, AList);
      end
      else
        Items[i].Childs.GetList(Tag, AAttrs, AList);

end;

procedure TTagList.GetList(Tags: array of string; AAttrs: array of TAttrList;
  AList: TTagList);
var
  i, j, l, lx: Integer;
  b: boolean;
  S: string;
  t: TTag;
begin
  // Tag := lowercase(Tag);
  lx := 0;

  if length(Tags) <> length(AAttrs) then
    raise Exception.Create('Incorrect tags and parameters count');
  for i := 0 to Count - 1 do
    if (Items[i].Kind = tkTag) then
    begin
      b := false;

      if lx = length(Tags) then
        lx := 0;

      for l := lx to length(Tags) - 1 do
        if SameText(Items[i].Name, Tags[l]) and
          not(AAttrs[l].NoParameters { and (Items[i].Attrs.Count > 0) } ) then
        begin
          b := true;
          if Assigned(AAttrs[l]) then
            for j := 0 to AAttrs[l].Count - 1 do
            begin
              S := Items[i].Attrs.Value(AAttrs[l][j].Name);
              if not CheckRule(S, AAttrs[l][j].Value, AAttrs[l][j].Compare) and
                not((AAttrs[l][j].Value = '') and (S <> '')) then
              begin
                b := false;
                break;
              end;
            end;

          if b then
          begin
            lx := l + 1;
            t := AList.CopyTag(Items[i]);
            t.Tag := AAttrs[l].Tag;
            break;
          end;
        end
        else
          break;

      // if not b then
      // Items[i].Childs.GetList(Tags,AAttrs,AList);
    end;
end;

function TTagList.CreateChild(Parent: TTag; AName: String = '';
  TagKind: TTagKind = tkTag): TTag;
begin
  if (TagKind in [tkText]) and (AName = '') then
  begin
    Result := nil;
    Exit;
  end;

  Result := TTag.Create(AName, TagKind);
  Result.Parent := Parent;
  if Parent <> nil then
    Parent.Childs.Add(Result)
  else
    Add(Result);
end;

destructor TTagList.Destroy;
begin
  Clear;
  inherited;
end;

procedure TTagList.ExportToFile(FName: string; Comments: tTagCommentState);

var
  S: tstringlist;
  st: string;
begin
  st := '';
  S := tstringlist.Create;
  try
    WriteList(Self, st, Comments);
    S.Text := st;
    S.SaveToFile(FName, TEncoding.UTF8);
  finally
    S.Free;
  end;
end;

function TTagList.FirstItemByName(tagname: string): TTag;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if SameText(Items[i].Name, tagname) then
    begin
      Result := Items[i];
      Exit;
    end;
  Result := nil;
end;

procedure TTagList.CopyList(AList: TTagList; Parent: TTag);
var
  i: Integer;

begin
  for i := 0 to AList.Count - 1 do
    CopyTag(AList[i], Parent);
end;

function TTagList.CopyTag(ATag: TTag; Parent: TTag = nil): TTag;
{ var
  p: TTag;
}
begin
  Result := CreateChild(Parent);
  Result.Name := ATag.Name;
  Result.Kind := ATag.Kind;
  // p.Text := ATag.Text;
  // p.Attrs := TAttrList.Create;
  Result.Attrs.Assign(ATag.Attrs);
  Result.Childs.CopyList(ATag.Childs, Result);
  Result.Tag := ATag.Tag;
  // Add(p);
end;

constructor TTag.Create(AName: String = ''; AKind: TTagKind = tkTag);
begin
  inherited Create;
  FChilds := TTagList.Create;
  FAttrList := TAttrList.Create;
  FParent := nil;
  Name := AName;
  FKind := AKind;
  FClosed := false;
  // FAttrList := TAttrList.Create;
  FTag := 0;
  fState := tsNormal;
  fCState := csUnknown;
end;

destructor TTag.Destroy;
begin
  FChilds.Free;
  FAttrList.Free;
  inherited;
end;

function TTag.FindParent(TagString: String; ignoreState: boolean = false): TTag;
var
  p: TTag;

begin
  // TagString := lowercase(TagString);
  if SameText(Name, TagString) then
  begin
    Result := Self;
    Exit;
  end
  else
  begin
    p := Parent;
    while Assigned(p) and (ignoreState or (p.State = tsClosable)) do
      if SameText(p.Name, TagString) then
      begin
        Result := p;
        Exit;
      end
      else
        p := p.Parent
  end;
  Result := nil;
end;

procedure TTag.SetName(Value: String);
begin
  FName := Value;
end;

function TTag.GetText(TextKind: TTextKind; AddOwnTag: boolean): string;
var
  i: Integer;

  function AttrString: String;
  begin
    if FAttrList.Count = 0 then
      Result := ''
    else
      Result := ' ' + FAttrList.AsString;
  end;

begin
  if FKind = tkText then
    Result := FName
  else
  begin
    Result := '';

    case TextKind of
      txkFullWithTags, txkFull:
        for i := 0 to Childs.Count - 1 do
          Result := Result + Childs[i].GetText(TextKind, AddOwnTag);
      txkCurrent:
        for i := 0 to Childs.Count - 1 do
          if Childs[i].Kind = tkText then
            Result := Result + Childs[i].Text;
    end;

    if AddOwnTag and (FKind = tkTag) then
      if Result = '' then
        Result := '<' + FName + AttrString + ' />'
      else
        Result := '<' + FName + AttrString + '>' + Result + '</' + FName + '>';
  end;
end;

function TTag.GetText: String;
begin
  Result := GetText(txkFull, false);
end;

procedure TTag.SetText(Value: String);
begin
  if FKind = tkText then
    FName := Value;
  { if Assigned(FParent) then
    FParent.Text := FParent.Text + Value; }
end;

function TAttrList.GetAttr(AValue: Integer): TAttr;
begin
  Result := FAttrs[AValue];
end;

function TAttrList.GetCount: Integer;
begin
  Result := length(FAttrs);
end;

function TAttrList.GetNoParam: boolean;
begin
  Result := FNoParam and not(Count > 0);
end;

procedure TAttrList.Add(AName: String; AValue: String; ACompVal: Char = #0;
  AQType: boolean = false);
begin
  if AName = '' then
    Exit;

  setlength(FAttrs, length(FAttrs) + 1);
  with FAttrs[length(FAttrs) - 1] do
  begin
    Name := AName;
    Value := AValue;
    Compare := ACompVal;
    qtype := AQType;
  end;
  // FNoParam := false;
end;

procedure TAttrList.Assign(AAttrs: TAttrList);
var
  i: Integer;

begin
  setlength(FAttrs, AAttrs.Count);
  for i := 0 to AAttrs.Count - 1 do
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
  for i := 0 to length(FAttrs) - 1 do
    if SameText(FAttrs[i].Name, AName) then
    begin
      Result := FAttrs[i].Value;
      Exit;
    end;
  Result := '';
end;

function TAttrList.IndexOf(AName: String): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to length(FAttrs) - 1 do
    if SameText(FAttrs[i].Name, AName) then
    begin
      Result := i;
      break;
    end;
end;

function TAttrList.AsString: String;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Count - 1 do
    if Result = '' then
      Result := Attribute[i].Name + '="' + Attribute[i].Value + '"'
    else
      Result := Result + ' ' + Attribute[i].Name + '="' + Attribute[i]
        .Value + '"'
end;

constructor TAttrList.Create;
begin
  inherited;
  FAttrs := nil;
  FNoParam := true;
end;

destructor TAttrList.Destroy;
begin
  FAttrs := nil;
  inherited;
end;

procedure TMyXMLParser.Parse(S: String; html: boolean = false);

var
  i: Integer; // counter
  l: Integer; // string length
  qt: byte; // 0 - no quotes, 1 - ", 2 - '
  istag: byte; // 0 - not a tag, 1 - searching tag bounds, 2 - creating tag
  lbr, rbr: Integer; // < and > pos
  lstart: Integer; // start copy position, is first symbol after tag ends
  ps, pe: Integer; // param's start and end
  tps, tpe: Integer; // remembered start and end of parameter before equal sign,
  // little fix to avoid stupid
  // using of isolator symbols inside isolated strings
  vs, ve: Integer; // value's start and end
  qtp: Integer; // quote pos, need to know, which type used last time
  eq: Integer; // equal sign pos
  isparam: boolean; // true - param part, false - value part;
  comm: byte; // is comment
  instr: boolean; // is xml instructions
  closetag: boolean; // is tag closing

  FTag: TTag; // current tag
  tmpTag: TTag; // temporary tag

  procedure tag_separate;
  begin
    if (istag <> 0) and (comm = 0) then // if is tag creating mode
    begin

      if isparam then
      begin
        if (pe < lbr) and (istag = 2) and not closetag then
        // create tag if it is tag name (first param)
          if Assigned(FTag) then
            FTag := FTag.Childs.CreateChild(FTag, copy(S, ps, i - ps), tkTag)
          else
            FTag := FTagList.CreateChild(FTag, copy(S, ps, i - ps), tkTag);

        if Assigned(FTag) and closetag then // if is tag closing
        begin // find what we closing, and return to it's parent

          if (FTag.State in [tsOnlyText]) // if is text only mode
            and not SameText(FTag.Name, copy(S, ps, i - ps)) then
          // and close tag not the same as current tag
            istag := 0 // just leave tag without actions
          else
          begin
            tmpTag := FTag.FindParent(copy(S, ps, i - ps), true);
            if Assigned(tmpTag) then
            begin
              tmpTag.Closed := true; // mark as "we are closed it with our hand"
              // not all tags closes by us, some of them just thrown opened
              // using it we can handle it
              FTag := tmpTag.Parent;
            end;
            closetag := false;
            if istag = 1 then
            // if is searching mode then not need to go into create mode
              istag := 0;
          end;
        end; // else
        // closetag := false;

        if pe < ps then
          pe := i - 1;

      end
      else if (vs > eq) then
      begin
        if (ve < eq) then
          ve := i - 1;
        isparam := true;
      end;

    end;

  end;

  procedure attr_add; // create parameter procedure
  begin // usualy call after SECOND parameter called or in the end of tag
    if (istag = 2) and (vs > eq) and (tps > lbr) and (tpe < eq) then
      if (qtp > eq) and (S[qtp] = '''') then
        FTag.Attrs.Add(copy(S, tps, tpe - tps + 1),
          copy(S, vs, ve - vs + 1), #0, true)
      else
        FTag.Attrs.Add(copy(S, tps, tpe - tps + 1), copy(S, vs, ve - vs + 1),
          #0, false);
  end;

begin
  // if not Assigned(FTagList) then
  // FTagList := TTagList.Create
  // else

  FTagList.Clear;

  i := 1;
  l := length(S);
  lstart := 1;
  qt := 0;
  eq := 0;
  istag := 0;
  lbr := 0;
  rbr := 0;
  ps := 0;
  pe := 0;
  qtp := 0;
  vs := 0;
  ve := 0;
  FTag := nil;
  comm := 0;
  instr := false;
  closetag := false;

  while i <= l do
  begin
    case S[i] of
      '<': // left bracket starts tag
        begin
          if qt = 0 then // ignore isolated brackets
          begin

            case istag of
              0:
                begin
                  if not Assigned(FTag)
                  // if is "OnlyText" State (ex. javascript content)
                    or not(FTag.State in [tsOnlyText]) or (i < l) and
                    (S[i + 1] = '/') then
                  begin
                    istag := 1;
                    // if is non-tag then going to "searching tag" mode
                    lbr := i;
                    ps := 0;
                    pe := 0;
                    tps := 0;
                    tpe := 0;
                    vs := 0;
                    ve := 0;
                    isparam := true;
                    instr := false;
                  end;
                end;
              1:
                if comm = 0 then
                  lbr := i; // if multiple '<' then all previous will be ignored (and going to the non-tag part)
              // it happens in bad xml and we're need to solve it somehow
              2:
                begin
                  isparam := true; // next text will be param
                  ps := 0;
                  pe := 0;
                  tps := 0;
                  tpe := 0;
                  vs := 0;
                  ve := 0;
                  instr := false;
                  // comm := false;
                end;
            end;
          end;
        end;
      '>': // right bracket ends tag
        begin
          if qt = 0 then // ignore isolated brackets
          begin
            // rbr := i;
            case istag of
              1:
                begin
                  if ps > lbr then
                  begin
                    rbr := i;

                    if Assigned(FTag) then
                    // add all non-tag text to the current tag
                      FTag.Childs.CreateChild(FTag,
                        copy(S, lstart, lbr - lstart), tkText)
                    else
                      FTagList.CreateChild(nil,
                        copy(S, lstart, lbr - lstart), tkText);

                    tag_separate;

                    if istag = 1 then
                    // can be changed in tag_separate if is tag closing
                    begin

                      istag := 2;
                      // if is searching tag mode then going to creating tag mode
                      i := lbr - 1;
                    end
                    else if not Assigned(FTag) or not(FTag.State in [tsOnlyText]
                      ) or FTag.Closed then
                      lstart := i + 1;
                  end
                  else if comm > 0 then
                  begin

                    if (comm = 3) and ((i - lbr) > 5) then
                      if (S[i - 1] = '-') and (S[i - 2] = '-') then
                      begin
                        rbr := i;

                        if Assigned(FTag) then
                        // add all non-tag text to the current tag
                        begin
                          FTag.Childs.CreateChild(FTag,
                            copy(S, lstart, lbr - lstart), tkText);
                          FTag.Childs.CreateChild(FTag,
                            copy(S, lbr + 4, i - lbr - 6), tkComment);
                        end
                        else
                        begin
                          FTagList.CreateChild(nil,
                            copy(S, lstart, lbr - lstart), tkText);
                          FTagList.CreateChild(nil,
                            copy(S, lbr + 4, i - lbr - 6), tkComment);
                        end;

                        comm := 0;
                        istag := 0;
                        lstart := i + 1;
                      end
                      else
                    else
                    begin
                      rbr := i;

                      if Assigned(FTag) then // add declaration string
                      begin
                        FTag.Childs.CreateChild(FTag,
                          copy(S, lstart, lbr - lstart), tkText);
                        FTag.Childs.CreateChild(FTag,
                          copy(S, lbr + 2, i - lbr - 2), tkDeclaration)
                      end
                      else
                      begin
                        FTagList.CreateChild(nil,
                          copy(S, lstart, lbr - lstart), tkText);
                        FTagList.CreateChild(nil, copy(S, lbr + 2, i - lbr - 2),
                          tkDeclaration);
                      end;

                      comm := 0;
                      istag := 0;
                      lstart := i + 1;
                    end;
                  end
                  else
                    istag := 0;
                end;
              2:
                begin
                  tag_separate;
                  if not closetag then
                  begin
                    attr_add;
                    if html then
                      CheckHTMLTag(FTag);
                    if (ps > lbr) then
                      if (S[ps] = '?') and instr then
                      begin
                        FTag.Kind := tkInstruction;
                        FTag := FTag.Parent;
                      end
                      else if (S[ps] = '/') and
                        not(FTag.ContentState in [csContent]) or
                        (FTag.ContentState in [csEmpty]) then
                      // if empty tag then
                        FTag := FTag.Parent; // return to the parent
                  end;

                  istag := 0;
                  // if is creating tag mode then exit to the non-tag mode

                  lstart := i + 1;
                end;
            end;
          end;
        end;
      '/': // means end of tag,if in the start of tag, then "end of the tag's content"
        begin // if in the end, then "end of the tag without content" aka "empty tag"

          if istag <> 0 then
            if (qt = 0) and (comm = 0) then // not quoted

              if lbr + 1 = i then // if in the start
              begin
                closetag := true; // mark it as is tag closing
                ps := i + 1; // next text must be param
              end
              else
              begin // mark it as parameter to check it comming in the end
                tag_separate;
                ps := i;
                pe := i;
              end;

        end;
      ' ', #13, #10, #9: // separator symbol, separate parameters
        begin
          if (istag <> 0) and (comm = 0) then
            if (ps = 0) then
              if (istag = 1) then
              // if param start is separator, then is invalid tag
                istag := 0
              else
                i := rbr
            else if (qt = 0) then // if is not quoted
              tag_separate;
        end;
      '=': // means next text will be value of previous parameter
        begin
          if (istag <> 0) then
            if (qt = 0) and (comm = 0) then
              if (ps = 0) or closetag then
              // if param start is separator, then is invalid tag
                if istag = 1 then
                  istag := 0
                else
                  i := rbr
              else // if is not quoted
              begin
                tag_separate;

                attr_add;

                eq := i;

                if tps <> ps then
                begin
                  tps := ps;
                  tpe := pe;
                  isparam := false;
                end;

              end;
        end;
      '?': // if is first symbol of the tag then is xml instructions
        begin

          if istag <> 0 then
            if (qt = 0) and (comm = 0) then // not quoted

              if lbr + 1 = i then // if in the start
              begin
                instr := true; // mark it as is xml instruction
                ps := i + 1; // next text must be param
              end

              else // if not in the start then
              begin // mark it as parameter to check it comming in the end
                tag_separate;
                ps := i;
                pe := i;
              end;

        end;
      '!': // if is first symbol of the tag  then is can be comment
        begin
          if istag <> 0 then
            if qt = 0 then // not quoted

              if lbr + 1 = i then // if in the start
              begin
                // comm := 1; //mark it as is comment start
                if ((l - i) > 1) and (S[i + 1] = '-') and (S[i + 2] = '-') then
                  comm := 3
                else
                  comm := 1;
              end
          //
          // else             //if not in the start then
          // begin            //mark it as parameter to check it comming in the end
          // tag_separate;
          // ps := i; pe := i;
          // end;
        end;
      // '-': //possible part of comment declaration
      // begin
      // if istag <> 0 then
      // if qt = 0 then  //not quoted
      // if (comm = 1) and (s[i-1] = '!')
      // or (comm = 2) and (s[i-1] = '-') then
      // inc(comm);
      // end;
      '"': // bracket 1
        begin
          if (istag <> 0) and (comm = 0) then
            case qt of
              0:
                if (vs < eq) then
                begin // if value not assigned
                  qtp := i;
                  qt := 1;
                  vs := i + 1;
                end
                else if (qtp > eq) and (S[qtp] = S[i]) then
                // else it is broken value assign (with isol symbols inside)
                  ve := i - 1;
              1:
                begin
                  qt := 0;
                  ve := i - 1;
                end;
            end;
        end;
      '''': // bracket 2
        begin
          if (istag <> 0) and (comm = 0) then
            case qt of
              0:
                if (vs < eq) then
                begin
                  qtp := i;
                  qt := 2;
                  vs := i + 1;
                end
                else if (qtp > eq) and (S[qtp] = S[i]) then
                  ve := i - 1;
              2:
                begin
                  qt := 0;
                  ve := i - 1;
                end;
            end;
        end;
    else
      begin
        if (istag <> 0) and (qt = 0) and (comm = 0) then
          if isparam then
            if (ps < lbr) or (ps <= pe) then
              ps := i
            else
          else if (vs < eq) then
            vs := i;

      end;
    end;

    inc(i);
  end;

  if l > rbr then
    if Assigned(FTag) then
      FTag.Childs.CreateChild(FTag, copy(S, rbr + 1, l - rbr), tkText)
    else
      FTagList.CreateChild(nil, copy(S, rbr + 1, l - rbr), tkText)

end;

procedure TMyXMLParser.CheckHTMLTag(Tag: TTag);
begin
  if Assigned(Tag) then
    if SameText(Tag.Name, 'script') then
      Tag.State := tsOnlyText
    else if SameText(Tag.Name, 'link') or SameText(Tag.Name, 'br') or
      SameText(Tag.Name, 'hr') or SameText(Tag.Name, 'meta') or
      SameText(Tag.Name, 'img') or SameText(Tag.Name, 'input') then
      Tag.ContentState := csEmpty
    else if SameText(Tag.Name, 'a') then
      Tag.ContentState := csContent;
  // else
  // Tag.ContentState := csUnknown;
end;

constructor TMyXMLParser.Create;
begin
  inherited;
  FTagList := TTagList.Create;
end;

destructor TMyXMLParser.Destroy;
begin
  // if Assigned(FTagList) then
  FTagList.Free;
  inherited;
end;

function TMyXMLParser.CheckHTMLStat(Tag: string): TContentState;
begin
  if SameText(Tag, 'link') or SameText(Tag, 'br') or SameText(Tag, 'hr') or
    SameText(Tag, 'meta') or SameText(Tag, 'img') or SameText(Tag, 'input') then
    Result := csEmpty
  else if SameText(Tag, 'a') then
    Result := csContent
  else
    Result := csUnknown;
end;

procedure TMyXMLParser.JSON(starttag: string; S: String);
var
  i: Integer;
begin
  // if not Assigned(FTagList) then
  // FTagList := TTagList.Create
  // else
  FTagList.Clear;

  JSONParseTag(nil, FTagList, S);

  for i := 0 to FTagList.Count - 1 do
    if FTagList[i].Name = '' then
      FTagList[i].Name := starttag;
end;

procedure TMyXMLParser.JSON(starttag: string; const S: TStrings);
begin
  JSON(starttag, S.Text);
end;

procedure TMyXMLParser.Parse(S: TStrings; html: boolean = false);
begin
  Parse(S.Text, html);
end;

procedure TMyXMLParser.LoadFromFile(FileName: String; html: boolean = false);
var
  S: tstringlist;
begin
  S := tstringlist.Create;
  try
    S.LoadFromFile(FileName);
    Parse(S, html);
  finally
    S.Free;
  end;
end;

end.
