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
    function GetAttr(AValue: Integer): TAttr;
    function GetCount: Integer;
  public
    property Attribute[AValue: Integer]: TAttr read GetAttr; default;
    property Count: Integer read GetCount;
    procedure Add(AName: String; AValue: String);
    procedure Clear;
    function Value(AName: String): String;
    function IndexOf(AName: String): Integer;
    constructor Create;
    destructor Destroy; override;
  end;

  TXMLOnTagEvent = procedure(ATag: String; Attrs: TAttrList) of object;
  TXMLOnEndTagEvent = procedure(ATag: String) of object;
  TXMLOnContentEvent = procedure(AContent: String) of object;

  TMyXMLParser = class(TObject)
  private
    FOnStartTag, FOnEmptyTag: TXMLOnTagEvent;
    FOnEndTag: TXMLOnEndTagEvent;
    FOnContent: TXMLOnContentEvent;
  protected
  public
    property OnStartTag: TXMLOnTagEvent read FOnStartTag write FOnStartTag;
    property OnEmptyTag: TXMLOnTagEvent read FOnEmptyTag write FOnEmptyTag;
    property OnEndTag: TXMLOnEndTagEvent read FOnEndTag write FOnEndTag;
    property OnContent: TXMLOnContentEvent read FOnContent write FOnContent;
    procedure Parse(S: String); overload;
    procedure Parse(S: TStrings); overload;
  end;

implementation

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
    adata := REPLACE(adata, #13#10, ' ', false, true);
    adata := REPLACE(adata, #9, ' ', false, true);
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
        if Assigned(FOnEndTag) then
          FOnEndTag(copy(adata, li, length(adata) - li));
      0:
        if Assigned(FOnEmptyTag) then
          FOnEmptyTag(tagname, Attrs);
      1:
        if Assigned(FOnStartTag) then
          FOnStartTag(tagname, Attrs);
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
  i, li, l, state: Integer;
  txt: string;
  sr: string;

begin
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
    if Assigned(FOnContent) and (checkstr(txt)) then
      FOnContent(txt);
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
end;

procedure TMyXMLParser.Parse(S: TStrings);
begin
  Parse(S.Text);
end;

end.
