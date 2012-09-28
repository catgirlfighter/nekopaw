unit MyXMLParser;

interface

uses
  Classes, SysUtils, StrUtils, common;

type

  TAttr = record
    Name: String;
    Value: String;
    Compare: Char;
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
    procedure Add(AName: String; AValue: String; FCompVal: Char = #0);
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

  TTagKind = (tkTag,tkText);

  TTextKind = (txkFullWithTags,txkFull,txkCurrent);

  TTagState = (tsNormal,tsOnlyText,tsClosable);

  TTag = class(TObject)
  private
    FParent: TTag;
    FName: String;
    FAttrList: TAttrList;
    //FText: String;
    FChilds: TTagList;
    FKind: TTagKind;
    FClosed: boolean;
    FTag: Integer;
    fState: TTagState;
  protected
    procedure SetName(Value: String);
    procedure SetText(Value: String);
    function GetText: String; overload;
  public
    constructor Create(AName: String = ''; AKind: TTagKind = tkTag);
    destructor Destroy; override;
    function FindParent(TagString: String; ignoreState: boolean = false): TTag;
    function GetText(TextKind: TTextKind; AddOwnTag: boolean): string;  overload;
    property Name: String read FName write SetName;
    property Attrs: TAttrList read FAttrList{ write FAttrList};
    property Text: String read GetText write SetText;
    property Childs: TTagList read FChilds;
    property Parent: TTag read FParent write FParent;
    property Kind: TTagKind read FKind write FKind;
    property Closed: Boolean read FClosed write FClosed;
    property Tag: Integer read FTag write FTag;
    property State: TTagState read fState write fState;
  end;

  TTagList = class(TList)
    protected
      function Get(ItemIndex: Integer): TTag;
      procedure Notify(Ptr: Pointer; Action: TListNotification); override;
    public
      procedure GetList(Tag: String; AAttrs: TAttrList; AList: TTagList); overload;
      procedure GetList(Tags: array of string; AAttrs: array of TAttrList;
        AList: TTagList); overload;
      procedure CopyList(AList: TTagList; Parent: TTag);
      procedure ExportToFile(fname: string);
      function FirstItemByName(tagname: string): ttag;
    function Text: String;
      property Items[ItemName: integer]: TTag read Get; default;
      function CreateChild(Parent: TTag; AName: String = '';
        TagKind: TTagKind = tkTag): TTag;
      function CopyTag(ATag: TTag; Parent: TTag = nil): TTag;
  end;

  TXMLOnTagEvent = procedure(ATag: TTag) of object;
  TXMLOnEndTagEvent = procedure(ATag: String) of object;
  TXMLOnContentEvent = procedure(ATag: TTag; AContent: String) of object;

  TMyXMLParser = class(TObject)  //Used old and stupid realisation, yeah
  private
    FOnStartTag, FOnEmptyTag, FOnEndTag: TXMLOnTagEvent;
    FOnContent: TXMLOnContentEvent;
//    : TXMLOnEndTagEvent;
//    : TXMLOnContentEvent;
    FTagList: TTagList;
  protected
    procedure CheckHTMLTag(tag: ttag);
    function CheckHTMLStat(tag: string): boolean;
  public
    procedure JSON(starttag: string; const S: TStrings); overload;
    procedure JSON(starttag: string; S: String); overload;
    property OnStartTag: TXMLOnTagEvent read FOnStartTag write FOnStartTag;
    property OnEmptyTag: TXMLOnTagEvent read FOnEmptyTag write FOnEmptyTag;
    property OnEndTag: TXMLOnTagEvent read FOnEndTag write FOnEndTag;
    property OnContent: TXMLOnContentEvent read FOnContent write FOnContent;
    procedure Parse(S: String; html: boolean = false); overload;
    procedure Parse(S: TStrings; html: boolean = false); overload;
    property TagList: TTagList read FTagList;
  end;

  procedure JSONParseChilds(parent: TTag; TagList: TTagList; tagname,s: string);
  procedure JSONParseValue(tag: ttag; TagList: TTagList; s: string);
  procedure JSONParseTag(tag: ttag; TagList: TTagList; S: String);

implementation

{*********** JSON ********************}

const
  JSONISL: array [0..0] of string = ('""');
  JSONBRK: array [0..1] of string = ('[]','{}');
//parse childs
procedure JSONParseChilds(parent: TTag; TagList: TTagList; tagname,s: string);
var
  n: string;
  tag: TTag;

begin
  while s <> '' do
  begin
    n := Trim(CopyTo(s,',',JSONISL,JSONBRK,true));

    tag := TagList.CreateChild(parent);
    tag.Name := tagname;
    //tag.Attrs := TAttrList.Create;

    if n <> '' then
    case n[1] of
      '[': JSONParseChilds(tag,TagList,'',Copy(n,2,Length(n)-2));
      '{': JSONParseTag(tag,TagList,Copy(n,2,Length(n)-2));
      else
        if CharPos(n,':',JSONISL,JSONBRK) = -1 then
          tag.Childs.CreateChild(tag,n,tkText)
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
  //s := StringReplace(s,'\\','&#92;',[rfReplaceAll]);
  s := StringReplace(s,'\"','&quot;',[rfReplaceAll]);

  tagname := TrimEx(CopyTo(s,':',JSONISL,JSONBRK,true),[' ','"']);
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
      child := TagList.CreateChild(tag,tagname);
      //child.Name := tagname;
      //child.Attrs := TAttrList.Create;

      JSONParseTag(child,TagList,Copy(value,2,Length(value)-2));
    end;
    '[': JSONParseChilds(tag,TagList,tagname,Copy(value,2,Length(value)-2));
    else
    begin
      if tag = nil then
      begin
        tag := TagList.CreateChild(nil);
        //tag.Attrs := TAttrList.Create;
      end;
      if tagname = '' then
        tag.Childs.CreateChild(tag,trim(value,'"'),tkText)
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
    n := Trim(CopyTo(s,',',JSONISL,JSONBRK,true));

    JSONParseValue(tag,TagList,n);
  end;
end;

{*********** JSON ********************}

procedure WriteList(List: TTagList; var s: String);
var
  i,j: integer;
  tmp: string;
begin
  for i := 0 to List.Count -1 do
  begin
    if List[i].Kind = tkText then
      s := s + List[i].Name
    else
    begin
      tmp := '<' + List[i].Name;
      for j := 0 to List[i].Attrs.Count-1 do
          tmp := tmp + ' ' + List[i].Attrs[j].Name + '="'
          + List[i].Attrs[j].Value + '"';
      if not List[i].Closed and (List[i].Childs.Count = 0) then
        s := s + (tmp + ' />')
      else
      begin
        s := s + (tmp + '>');
        WriteList(List[i].Childs,s);
        s := s + ('</' + List[i].Name + '>');
      end;
    end;
  end;

end;

procedure TTagList.Notify(Ptr: Pointer; Action: TListNotification);
var
  p: TObject;

begin
  case Action of
    lnDeleted:
      begin
          p := Ptr;
          if p is TTag then
            p.Free;
      end;
  end;
end;

function TTagList.Text: String;
begin
  Result := '';
  WriteList(Self,Result);
end;

function TTagList.Get(ItemIndex: Integer): TTag;
begin
  Result := inherited Get(ItemIndex);
end;

function CheckRule(v1,v2: string;r: char): boolean;
var
  tmp: string;

begin
  if (v1 = '') then
  begin
    Result := false;
    Exit;
  end;

  if Pos(' ',v2) > 0 then     //string with spaces
  begin
    Result := SameText(v1,v2);
    Exit;
  end;

  while v1 <> '' do
  begin
    tmp := GetNextS(v1,' ');  //tags

    case r of
      '!':
      if SameText(tmp,v2) then
      begin
        Result := false;
        Exit;
      end;
      else if SameText(tmp,v2) then
      begin
        Result := true;
        Exit;
      end;
    end;

  end;

  case r of
    '!': Result := true;
    else   Result := false;
  end;

end;

procedure TTagList.GetList(Tag: String; AAttrs: TAttrList; AList: TTagList);

var
  i,j: integer;
  b: boolean;
  s: string;

begin
  //Tag := lowercase(Tag);
  if Assigned(AAttrs) and AAttrs.NoParameters then
    AAttrs.NoParameters := true;

  for i := 0 to Count -1 do
    if (Items[i].Kind = tkTag) then
      if SameText(Items[i].Name,Tag)
      and not (Assigned(AAttrs) and AAttrs.NoParameters and (Items[i].Attrs.Count > 0)) then
      begin
        b := true;
        if Assigned(AAttrs) then
          for j := 0 to AAttrs.Count -1 do
          begin
            s := Items[i].Attrs.Value(AAttrs[j].Name);
              if not CheckRule(s,AAttrs[j].Value,AAttrs[j].Compare) and
              not ((AAttrs[j].Value = '') and (s <> '')) then
            begin
              b := false;
              Break;
            end;
          end;

        if b then
          AList.CopyTag(Items[i])
        else
          Items[i].Childs.GetList(Tag,AAttrs,AList);
      end else
        Items[i].Childs.GetList(Tag,AAttrs,AList);
end;

procedure TTagList.GetList(Tags: array of string; AAttrs: array of TAttrList;
  AList: TTagList);
var
  i,j,l: integer;
  b: boolean;
  s: string;
  t: ttag;
begin
  //Tag := lowercase(Tag);
  if length(Tags) <> length(AAttrs) then
    raise Exception.Create('Incorrect tags and parameters count');
    for i := 0 to Count -1 do
      if (Items[i].Kind = tkTag) then
      begin
        b := false;

        for l := 0 to Length(Tags)-1 do
          if SameText(Items[i].Name,Tags[l])
          and not(AAttrs[l].NoParameters and (Items[i].Attrs.Count > 0)) then
          begin
            b := true;
            if Assigned(AAttrs[l]) then
              for j := 0 to AAttrs[l].Count -1 do
              begin
                s := Items[i].Attrs.Value(AAttrs[l][j].Name);
                  if not CheckRule(s,AAttrs[l][j].Value,AAttrs[l][j].Compare) and
                  not ((AAttrs[l][j].Value = '') and (s <> '')) then
                begin
                  b := false;
                  Break;
                end;
              end;

            if b then
            begin
              t := AList.CopyTag(Items[i]);
              t.Tag := AAttrs[l].Tag;
            end;
          end;

        if not b then
          Items[i].Childs.GetList(Tags,AAttrs,AList);
      end;
end;

function TTagList.CreateChild(Parent: TTag; AName: String = '';
  TagKind: TTagKind = tkTag): TTag;
begin
  Result := TTag.Create(AName,TagKind);
  Result.Parent := Parent;
  if Parent <> nil then
    Parent.Childs.Add(Result)
  else
    Add(Result);
end;

procedure TTagList.ExportToFile(fname: string);

var
  s: tstringlist;
  st: string;
begin
  st := '';
  s := tstringlist.Create;
  try
    WriteList(Self,st);
    s.Text := st;
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

function TTagList.CopyTag(ATag: TTag; Parent: TTag = nil): TTag;
{var
  p: TTag;
              }
begin
  Result := CreateChild(Parent);
  Result.Name := ATag.Name;
  Result.Kind := ATag.Kind;
  //p.Text := ATag.Text;
  //p.Attrs := TAttrList.Create;
  Result.Attrs.Assign(ATag.Attrs);
  Result.Childs.CopyList(ATag.Childs,Result);
  Result.Tag := ATag.Tag;
  //Add(p);
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
  FAttrList := TAttrList.Create;
  FTag := 0;
  fState := tsnormal;
end;

destructor TTag.Destroy;
begin
  FChilds.Free;
  FAttrList.Free;
  inherited;
end;

function TTag.FindParent(TagString: String; ignoreState: boolean = false): TTag;
var
  P: TTag;

begin
//  TagString := lowercase(TagString);
  if SameText(Name,TagString) then
  begin
    Result := Self;
    Exit;
  end else
  begin
    p := Parent;
    while Assigned(p) and (ignoreState or (p.State = tsClosable)) do
      if SameText(p.Name,TagString) then
      begin
        Result := p;
        Exit;
      end else
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
  i: integer;

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
      txkFullWithTags,txkFull:
        for i := 0 to Childs.Count-1 do
          Result := Result + Childs[i].GetText(TextKind,AddOwntag);
      txkCurrent:
        for i := 0 to Childs.Count-1 do
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
  Result := GetText(txkFull,false);
end;

procedure TTag.SetText(Value: String);
begin
  if FKind = tkText then
    FName := Value;
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

function TAttrList.GetNoParam: boolean;
begin
  Result := FNoParam and not(Count > 0);
end;

procedure TAttrList.Add(AName: String; AValue: String; FCompVal: Char = #0);
begin
  SetLength(FAttrs, length(FAttrs) + 1);
  with FAttrs[length(FAttrs) - 1] do
  begin
    Name := AName;
    Value := AValue;
    Compare := FCompVal;
  end;
//  FNoParam := false;
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
    if SameText(FAttrs[i].Name,AName) then
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
    if SameText(FAttrs[i].Name,AName) then
    begin
      Result := i;
      Break;
    end;
end;

function TAttrList.AsString: String;
var
  i: integer;
begin
  Result := '';
  for i := 0 to Count-1 do
    if Result = '' then
      Result :=  Attribute[i].Name + '="' + Attribute[i].Value + '"'
    else
      Result := Result + ' ' + Attribute[i].Name + '="' + Attribute[i].Value + '"'
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
  FTag: TTag;

  function parsetag(adata: string): boolean;

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
    tmptag: ttag;
  begin
    Attrs := TAttrList.Create;
    lastattr := '';
    tagname := '';
    stat := 1;
//    adata := StringReplace(adata, #13, '', [rfReplaceAll]);
//    adata := StringReplace(adata, #10, ' ', [rfReplaceAll]);
//    adata := StringReplace(adata, #9, ' ', [rfReplaceAll]);
    // adata := REPLACE(adata,'  ',' ',false,true);
    adata := adata + ' ';
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
                if i = l - 1 then
                begin
                  tagname := copy(adata, li, i - li);
                  stat := 0;
                end else
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
                if (lastattr <> '') then
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
        ' ',#13,#10,#9:
          case state of
            0:
              begin
                if (tagname = '') then
                begin
                  tagname := copy(adata, li, i - li);
                  if (length(tagname) = 0)
                  or (length(tagname) > 0) and CharInSet(tagname[1], ['!']) then
                  begin
                    stat := 2;
                    Break;
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
                if (i = l) and (lastattr<>'') then
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

    if (stat = 1) and CheckHTMLStat(tagname) then
      stat := 0;

    case stat of
      - 1:
      begin
        result := not(Assigned(ftag) and (FTag.State = tsOnlyText))
                  or SameText(copy(adata, li, length(adata) - li),Ftag.Name);
        if result then
        begin
          if Assigned(FOnEndTag) then
            //FOnEndTag(copy(adata, li, length(adata) - li));
            FOnEndTag(FTag);

          if Assigned(FTag) then
          begin
            tmptag := FTag.FindParent(copy(adata, li, length(adata) - li),true);
            if Assigned(tmptag) then
            begin
              tmptag.Closed := true;
              FTag := tmptag.Parent;
              //FTag := FTag.Parent;
            end;
          end;
        end;
      end;
      0:
      begin
        result := not (Assigned(ftag) and (FTag.State = tsOnlyText));
        if result then
        begin
          FTag := TagList.CreateChild(FTag);
          FTag.Name := tagname;
          FTag.Attrs.Assign(Attrs);
          //Attrs.Free;

          if Assigned(FOnEmptyTag) then
            //FOnEmptyTag(tagname, Attrs);
            FOnEmptyTag(FTag);

          //FTag.Closed := true;
          FTag := FTag.Parent;
        end;
      end;
      1:
      begin
        result := not (Assigned(ftag) and (FTag.State = tsOnlyText));
        if result then
        begin
          FTag := TagList.CreateChild(FTag);
          FTag.Name := tagname;
          FTag.Attrs.Assign(Attrs);

          if html then
            CheckHTMLTag(FTag);

          //Attrs.Free;

          if Assigned(FOnStartTag) then
            //FOnStartTag(tagname, Attrs);
            FOnStartTag(FTag);
        end;
      end;
      else result := false;
    end;
    Attrs.Free;
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
  i, li, l, state,intag: Integer;
  txt: string;
  sr: string;

begin
  if not Assigned(FTagList) then
    FTagList := TTagList.Create
  else
    FTagList.Clear;

  FTag := nil;

//  try
    S := DeleteFromTo(S,'<!--','-->',true,true);
    txt := '';
    state := 0;
    intag := 0;
    l := length(S);
    i := 1;
    li := 1;
    while true do
    begin
      while (i <= l) and (S[i] <> '<')
      or ((i < l) and CharInSet(s[i+1],[' ',#13,#10,#9])) do
        inc(i);
      txt := copy(S, li, i - li);
      if trim(txt) <> '' then
      begin
        if Assigned(FTag) then
          FTag.Childs.CreateChild(FTag,txt,tkText);
        if Assigned(FOnContent) and (checkstr(txt)) then
          FOnContent(FTag,txt);
      end;
      inc(i);
      li := i;
      if i >= l then
        Break;
      while (i <= l) and ((S[i] <> '>') or (state <> 0) or (intag > 0)) do
      begin
        case S[i] of
          '<': if Assigned(ftag) and (ftag.State = tsOnlyText) then
                Break
               else
                inc(intag);
          '>': dec(intag);
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
        Break
      else if Assigned(ftag) and (ftag.State = tsOnlyText) and (s[i] = '<') then
        Continue;

      sr := copy(S, li, i - li);
      if parsetag(sr) then
      begin
        inc(i);
        li := i;
      end else
      begin
        i := li;
        li := li - 1;
      end;
    end;
{  finally
    FTag.Free;
  end;   }
end;

(*
procedure TMyXMLParser.Parse(S: String);
var
  part: string;
  Parent: TTag;
  Child: TTag;
  state: integer;
  val,attrname: string;

  procedure AddChild(Child,Parent: TTag);
  begin
    if Assigned(Child) then
      if Assigned(Parent) then
        Parent.Childs.Add(Child)
      else
        TagList.Add(Child);
  end;

begin
  Child := nil;
  while s <> '' do
  begin
    Part := CopyTo(S,'<',[],true); //text
    if (part <> '') then
    begin
      Child := TTag.Create(part,tkText);
      AddChild(Child,Parent);
    end;

    Part := CopyTo(S,'>',['''''','""'],true);  //tag
    if (Part <> '') then
    begin
      state := 0;
      val := trim(CopyTo(part,' ',['''''','""'],true));
      if (val <> '') then
      if val[1] = '!' then
      begin
        if part <> '' then
          Child := TTag.Create(val + ' ' + part,tkText)
        else
          Child := TTag.Create(val);
        AddChild(Child,Parent);
      end
      else
        begin
          Child := ttag.Create(val);
          AddChild(Child,Parent);
          while part <> '' do
          begin
            val := CopyTo(part,' ',['''''','""'],true);
            if val <> '' then
              case state of
                0:
                  if val = '=' then
                    state := 1
                  else
                  begin
                    if attrname <> '' then
                      Child.Attrs.Add(attrname,'');
                    attrname := val;
                  end;
                1:
                  begin
                    if attrname <> '' then
                      Child.Attrs.Add(attrname,val)
                    else
                      raise Exception.Create('XML parse error: unknown parameter for value '
                        + val);
                  end;
              end;
          end;
        end;
    end;

  end;

end;
*)

procedure TMyXMLParser.CheckHTMLTag(tag: ttag);
begin
  if SameText(tag.Name,'script') then
    tag.State := tsOnlyText
  {else
  if SameText(tag.Name,'td')
  or SameText(tag.Name,'tr') then
    tag.State := tsClosable;   }
end;

function TMyXMLParser.CheckHTMLStat(tag: string): boolean;
begin
  if SameText(tag,'link')
  or SameText(tag,'br')
  or SameText(tag,'hr')
  or SameText(tag,'meta')
  or SameText(tag,'img')
  or SameText(tag,'input')
  then
    result := true
  else
    result := false;
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

procedure TMyXMLParser.Parse(S: TStrings; html: boolean = false);
begin
  Parse(S.Text,html);
end;

end.
