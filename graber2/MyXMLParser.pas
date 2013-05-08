unit MyXMLParser;

interface

uses
  Classes, SysUtils, StrUtils, common;

type

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
      AQType: Boolean = false);
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

  TTagKind = (tkTag,tkInstruction,tkDeclaration,tkComment,tkText);

  TTextKind = (txkFullWithTags,txkFull,txkCurrent);

  TTagState = (tsNormal,tsOnlyText,tsClosable);
  TContentState = (csUnknown,csEmpty,csContent);

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
    fCState: tContentState;
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
    property ContentState: tContentState read fCState write fCState;
  end;

  tTagCommentStates = (tcsContent,tcsHelp);
  tTagCommentState = set of tTagCommentStates;

  TTagList = class(TList)
    protected
      function Get(ItemIndex: Integer): TTag;
      procedure Notify(Ptr: Pointer; Action: TListNotification); override;
    public
      procedure GetList(Tag: String; AAttrs: TAttrList; AList: TTagList); overload;
      procedure GetList(Tags: array of string; AAttrs: array of TAttrList;
        AList: TTagList); overload;
      procedure CopyList(AList: TTagList; Parent: TTag);
      procedure ExportToFile(fname: string; Comments: tTagCommentState);
      function FirstItemByName(tagname: string): ttag;
      function Text(Comments: tTagCommentState): String; overload;
      function Text: String; overload;
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
    function CheckHTMLStat(tag: string): TContentState;
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

procedure WriteList(List: TTagList; var s: String; Comments: tTagCommentState);
const
  qbool: array[Boolean] of String = ('"','''');

var
  i,j: integer;
  tmp: string;
begin
  for i := 0 to List.Count -1 do
  begin
    if List[i].Kind = tkText then
      s := s + List[i].Name
    else if(List[i].Kind = tkComment) then
      if tcsContent in Comments then
        s := s + '<!--' + List[i].Name + '-->'
      else
    else if List[i].Kind = tkDeclaration then
      s := s + '<!' + List[i].Name + '>'
    else if List[i].Kind = tkInstruction then
    begin
      tmp := List[i].Name;
      for j := 0 to List[i].Attrs.Count-1 do
          tmp := tmp + ' ' + List[i].Attrs[j].Name + '=' + qbool[List[i].Attrs[j].qtype]
          + List[i].Attrs[j].Value + qbool[List[i].Attrs[j].qtype];
      s := s + '<?' + tmp + '?>';
    end else
    begin
      tmp := '<' + List[i].Name;
      for j := 0 to List[i].Attrs.Count-1 do
          tmp := tmp + ' ' + List[i].Attrs[j].Name + '=' + qbool[List[i].Attrs[j].qtype]
          + List[i].Attrs[j].Value + qbool[List[i].Attrs[j].qtype];
      if not List[i].Closed and (List[i].Childs.Count = 0)
      and not (List[i].ContentState in [csContent]) then
        s := s + tmp + ' />'
      else
      begin
        s := s + (tmp + '>');
        WriteList(List[i].Childs,s,Comments);

        if (tcsHelp in Comments) and (List[i].Attrs.Count > 0) then
        begin
          s := s + '</' + List[i].Name + '><!--';

          for j := 0 to List[i].Attrs.Count-1 do
            s := s + ' ' + List[i].Attrs[j].Name + '=' + qbool[List[i].Attrs[j].qtype]
            + List[i].Attrs[j].Value + qbool[List[i].Attrs[j].qtype];
          s := s + ' -->';

        end else
          s := s + '</' + List[i].Name + '>';
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

function TTagList.Text(Comments: tTagCommentState): String;
begin
  Result := '';
  WriteList(Self,Result,Comments);
end;

function TTagList.Text: String;
begin
  Result := Text([tcsContent]);
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
    case r of
      '!': Result := v2 <> '';
      '=': Result := v2 = '';
      else raise Exception.Create('Check Rule: unknown operation "' + r + '"');
    end;
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
    '=': Result := false;
    else raise Exception.Create('Check Rule: unknown operation "' + r + '"');
  end;

end;

procedure TTagList.GetList(Tag: String; AAttrs: TAttrList; AList: TTagList);

var
  i,j: integer;
  b: boolean;
  s: string;

begin
  //if not Assigned(AAttrs) then
  //  Exit;

  for i := 0 to Count -1 do
    if (Items[i].Kind = tkTag) then
      if SameText(Items[i].Name,Tag)
      and not (Assigned(AAttrs) and AAttrs.NoParameters{ and (Items[i].Attrs.Count > 0)}) then
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
  i,j,l,lx: integer;
  b: boolean;
  s: string;
  t: ttag;
begin
  //Tag := lowercase(Tag);
  lx := 0;

  if length(Tags) <> length(AAttrs) then
    raise Exception.Create('Incorrect tags and parameters count');
    for i := 0 to Count -1 do
      if (Items[i].Kind = tkTag) then
      begin
        b := false;

        if lx = Length(Tags) then
          lx := 0;

        for l := lx to Length(Tags)-1 do
          if SameText(Items[i].Name,Tags[l])
          and not(AAttrs[l].NoParameters{ and (Items[i].Attrs.Count > 0)}) then
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
              lx := l + 1;
              t := AList.CopyTag(Items[i]);
              t.Tag := AAttrs[l].Tag;
              Break;
            end;
          end else
            Break;

        //if not b then
        //  Items[i].Childs.GetList(Tags,AAttrs,AList);
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

  Result := TTag.Create(AName,TagKind);
  Result.Parent := Parent;
  if Parent <> nil then
    Parent.Childs.Add(Result)
  else
    Add(Result);
end;

procedure TTagList.ExportToFile(fname: string; Comments: tTagCommentState);

var
  s: tstringlist;
  st: string;
begin
  st := '';
  s := tstringlist.Create;
  try
    WriteList(Self,st,Comments);
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

procedure TAttrList.Add(AName: String; AValue: String; ACompVal: Char = #0;
  AQType: Boolean = false);
begin
  if AName = '' then
    Exit;

  SetLength(FAttrs, length(FAttrs) + 1);
  with FAttrs[length(FAttrs) - 1] do
  begin
    Name := AName;
    Value := AValue;
    Compare := ACompVal;
    QType := AQType;
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

procedure tMyXMLParser.Parse(S: String; html: boolean = false);

var
  i: integer; //counter
  l: integer; //string length
  qt: byte; //0 - no quotes, 1 - ", 2 - '
  istag: byte; //0 - not a tag, 1 - searching tag bounds, 2 - creating tag
  lbr,rbr: integer;//< and > pos
  lstart: integer;// start copy position, is first symbol after tag ends
  ps,pe: integer; //param's start and end
  tps,tpe: integer; //remembered start and end of parameter before equal sign,
                    //little fix to avoid stupid
                    //using of isolator symbols inside isolated strings
  vs,ve: integer; //value's start and end
  qtp: integer;   //quote pos, need to know, which type used last time
  eq: integer; //equal sign pos
  isparam: boolean; //true - param part, false - value part;
  comm: byte; //is comment
  instr: boolean; //is xml instructions
  closetag: boolean; //is tag closing

  fTag: tTag; // current tag
  tmpTag: ttag; //temporary tag

  procedure tag_separate;
  begin
    if (istag <> 0) and (comm = 0) then //if is tag creating mode
    begin

      if isparam then
      begin
        if (pe < lbr) and (istag = 2) and not closetag then  //create tag if it is tag name (first param)
          if Assigned(fTag) then
            fTag := fTag.Childs.CreateChild(fTag,copy(s,ps,i-ps),tkTag)
          else
            fTag := fTagList.CreateChild(fTag,copy(s,ps,i-ps),tkTag);

        if Assigned(ftag) and closetag then  //if is tag closing
        begin                  //find what we closing, and return to it's parent

          if (fTag.State in [tsOnlyText])                //if is text only mode
          and not SameText(ftag.Name,copy(s, ps, i - ps)) then //and close tag not the same as current tag
            istag := 0                               //just leave tag without actions
          else
          begin
            tmptag := FTag.FindParent(copy(s, ps, i - ps),true);
            if Assigned(tmptag) then
            begin
              tmptag.Closed := true; //mark as "we are closed it with our hand"
                                     //not all tags closes by us, some of them just thrown opened
                                     //using it we can handle it
              FTag := tmptag.Parent;
            end;
            closetag := false;
            if istag = 1 then //if is searching mode then not need to go into create mode
              istag := 0;
          end;
        end;// else
          //  closetag := false;

        if pe < ps then
          pe := i - 1;
          
      end else if (vs > eq) then
      begin
        if (ve < eq) then
          ve := i - 1;
        isparam := true;
      end;
      
    end;

  end;

  procedure attr_add; //create parameter procedure
  begin               //usualy call after SECOND parameter called or in the end of tag
    if (istag = 2) and (vs > eq)
    and (tps > lbr) and (tpe < eq) then
      if (qtp > eq) and (s[qtp] = '''') then
        ftag.Attrs.Add(copy(s,tps,tpe-tps+1),copy(s,vs,ve-vs+1),#0,true)
      else
        ftag.Attrs.Add(copy(s,tps,tpe-tps+1),copy(s,vs,ve-vs+1),#0,false);
  end;

begin
  if not Assigned(FTagList) then
    FTagList := TTagList.Create
  else
    FTagList.Clear;

  i := 1; l := length(s); lstart := 1;
  qt := 0; eq := 0;
  istag := 0;
  lbr := 0; rbr := 0;
  ps := 0; pe := 0;
  qtp := 0;
  vs := 0; ve := 0;
  fTag := nil;
  comm := 0;
  instr := false;
  closetag := false;

  while i <= l do
  begin
    case s[i] of
      '<':           //left bracket starts tag
      begin
        if qt = 0 then //ignore isolated brackets
        begin

          case istag of
            0:
            begin
              if not Assigned(fTag) //if is "OnlyText" State (ex. javascript content)
              or not (fTag.State in [tsOnlyText])
              or (i < l) and (s[i+1] = '/') then
              begin
                istag := 1;  //if is non-tag then going to "searching tag" mode
                lbr := i;
                ps := 0; pe := 0; tps := 0; tpe := 0;
                vs := 0; ve := 0;
                isparam := true;
                instr := false;
              end;
            end;
            1: if comm = 0 then lbr := i;//if multiple '<' then all previous will be ignored (and going to the non-tag part)
                                         //it happens in bad xml and we're need to solve it somehow
            2:
            begin
              isparam := true; //next text will be param
              ps := 0; pe := 0; tps := 0; tpe := 0;
              vs := 0; ve := 0;
              instr := false;
              //comm := false;
            end;
          end;
        end;
      end;
      '>':          //right bracket ends tag
      begin
        if qt = 0 then   //ignore isolated brackets
        begin
          //rbr := i;
          case istag of
            1:
            begin
              if ps > lbr then
              begin
                rbr := i;

                if Assigned(fTag) then //add all non-tag text to the current tag
                  fTag.Childs.CreateChild(fTag,copy(s, lstart, lbr - lstart),tkText)
                else
                  fTagList.CreateChild(nil,copy(s, lstart, lbr - lstart),tkText);

                tag_separate;

                if istag = 1 then //can be changed in tag_separate if is tag closing
                begin            

                  istag := 2; //if is searching tag mode then going to creating tag mode
                  i := lbr - 1;
                end else
                  if not Assigned(fTag)
                  or not (fTag.State in [tsOnlyText])
                  or fTag.Closed then
                    lstart := i + 1;
              end else if comm > 0 then
              begin

                if (comm = 3) and ((i - lbr) > 5) then
                  if (s[i-1] = '-') and (s[i-2] = '-') then
                  begin
                    rbr := i;

                    if Assigned(fTag) then //add all non-tag text to the current tag
                    begin
                      fTag.Childs.CreateChild(fTag,copy(s, lstart, lbr - lstart),tkText);
                      fTag.Childs.CreateChild(fTag,copy(s, lbr + 4, i - lbr - 6),tkComment);
                    end else
                    begin
                      fTagList.CreateChild(nil,copy(s, lstart, lbr - lstart),tkText);
                      fTagList.CreateChild(nil,copy(s, lbr + 4, i - lbr - 6),tkComment);
                    end;

                    comm := 0;
                    istag := 0;
                    lstart := i + 1;
                  end else
                else
                begin
                  rbr := i;

                  if Assigned(fTag) then //add declaration string
                  begin
                    fTag.Childs.CreateChild(fTag,copy(s, lstart, lbr - lstart),tkText);
                    fTag.Childs.CreateChild(fTag,copy(s, lbr + 2, i - lbr -2),tkDeclaration)
                  end else
                  begin
                    fTagList.CreateChild(nil,copy(s, lstart, lbr - lstart),tkText);
                    fTagList.CreateChild(nil,copy(s, lbr + 2, i - lbr -2),tkDeclaration);
                  end;

                  comm := 0;
                  istag := 0;
                  lstart := i + 1;
                end;
              end else
                istag := 0;
            end;
            2:
            begin
              tag_separate;
              if not closetag then
              begin
                attr_add;
                if HTML then
                  CheckHTMLTag(fTag);
                if (ps > lbr) then
                  if (S[ps] = '?') and instr then
                  begin
                    fTag.Kind := tkInstruction;
                    fTag := fTag.Parent;
                  end else if (S[ps] = '/') 
                  and not (fTag.ContentState in [csContent])
                  or (fTag.ContentState in [csEmpty])
                   then//if empty tag then
                    fTag := fTag.Parent;               //return to the parent
              end;

              istag := 0;  //if is creating tag mode then exit to the non-tag mode

              lstart := i + 1;
            end;
          end;
        end;
      end;
      '/':  //means end of tag,if in the start of tag, then "end of the tag's content"
      begin //if in the end, then "end of the tag without content" aka "empty tag"

        if istag <> 0 then
          if (qt = 0) and (comm = 0) then  //not quoted

            if lbr + 1 = i then   //if in the start
            begin
              closetag := true; //mark it as is tag closing
              ps := i + 1; //next text must be param
            end
            else begin            //mark it as parameter to check it comming in the end
              tag_separate;
              ps := i; pe := i;
            end;

      end;
      ' ',#13,#10,#9: //separator symbol, separate parameters
      begin
        if (istag <> 0) and (comm = 0) then
          if (ps = 0) then
          if (istag = 1) then //if param start is separator, then is invalid tag
            istag := 0
          else
            i := rbr
          else if (qt = 0) then //if is not quoted
           tag_separate;
      end;
      '=': //means next text will be value of previous parameter
      begin
        if (istag <> 0) then
          if (qt = 0) and (comm = 0) then
            if (ps = 0) or closetag then //if param start is separator, then is invalid tag
              if istag = 1 then
                istag := 0
              else
                i := rbr
            else //if is not quoted
            begin
              tag_separate;

              attr_add;

              eq := i;
              
              if tps <> ps then
              begin              
                tps := ps; tpe := pe;
                isparam := false;
              end;

            end;
      end;
      '?': //if is first symbol of the tag then is xml instructions
      begin
      
        if istag <> 0 then
          if (qt = 0) and (comm = 0) then  //not quoted

            if lbr + 1 = i then   //if in the start
            begin
              instr := true; //mark it as is xml instruction
              ps := i + 1; //next text must be param
            end

            else             //if not in the start then
            begin            //mark it as parameter to check it comming in the end
              tag_separate;
              ps := i; pe := i;
            end;
            
      end;
      '!': //if is first symbol of the tag  then is can be comment
      begin
        if istag <> 0 then
          if qt = 0 then  //not quoted

            if lbr + 1 = i then   //if in the start
            begin
              //comm := 1; //mark it as is comment start
              if ((l - i) > 1) and (s[i+1] = '-')
              and (s[i+2] = '-') then
                comm := 3
              else
                comm := 1;
            end
            //
            //else             //if not in the start then
            //begin            //mark it as parameter to check it comming in the end
           //   tag_separate;
           //   ps := i; pe := i;
           // end;
      end;
      //'-': //possible part of comment declaration
      //begin
      //  if istag <> 0 then
      //    if qt = 0 then  //not quoted
      //      if (comm = 1) and (s[i-1] = '!')
      //      or (comm = 2) and (s[i-1] = '-') then
      //        inc(comm);
      //end;
      '"': // bracket 1
      begin
        if (istag <> 0) and (comm = 0) then
          case qt of
            0:
            if (vs < eq) then begin //if value not assigned
              qtp := i;
              qt := 1;
              vs := i + 1;
            end else if (qtp > eq) and (s[qtp] = s[i]) then //else it is broken value assign (with isol symbols inside)
              ve := i - 1;
            1:
            begin
              qt := 0;
              ve := i - 1;
            end;
          end;
      end;
      '''': //bracket 2
      begin
        if (istag <> 0) and (comm = 0)  then
          case qt of
            0:
            if (vs < eq) then begin
              qtp := i;
              qt := 2;
              vs := i + 1;
            end else if (qtp > eq) and (s[qtp] = s[i]) then
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
            if (ps < lbr) or (ps  <=  pe) then
              ps := i
            else
          else
            if (vs < eq) then
              vs := i;

      end;
    end;

    inc(i);
  end;

  if l > rbr then
    if Assigned(fTag) then
      fTag.Childs.CreateChild(fTag,copy(s, rbr + 1, l - rbr),tkText)
    else
      fTagList.CreateChild(nil,copy(s, rbr + 1, l - rbr),tkText)

end;

procedure TMyXMLParser.CheckHTMLTag(tag: ttag);
begin
  if Assigned(tag) then
    if SameText(tag.Name,'script') then
      tag.State := tsOnlyText
    else if SameText(tag.Name,'link')
    or SameText(tag.Name,'br')
    or SameText(tag.Name,'hr')
    or SameText(tag.Name,'meta')
    or SameText(tag.Name,'img')
    or SameText(tag.Name,'input')
    then
      Tag.ContentState := csEmpty
    else if SameText(tag.Name,'a') then
      Tag.ContentState := csContent;
    //else
    //  Tag.ContentState := csUnknown;
end;

function TMyXMLParser.CheckHTMLStat(tag: string): TContentState;
begin
  if SameText(tag,'link')
  or SameText(tag,'br')
  or SameText(tag,'hr')
  or SameText(tag,'meta')
  or SameText(tag,'img')
  or SameText(tag,'input')
  then
    result := csEmpty
  else if SameText(tag,'a') then
    result := csContent
  else
    result := csUnknown;
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
