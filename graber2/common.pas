unit common;

interface

uses Classes, Variants, SysUtils, Math, Forms, StdCtrls, ExtCtrls, ComCtrls,
  Controls, DateUtils,StrUtils,
  HTTPApp, ShellAPI, Windows, Graphics, JPEG, GIFImg, PNGImage, VarUtils;

type
  TArrayOfWord = array of word;
  TArrayOfString = array of string;
  TSetOfChar = Set of Char;

{function Replace(src, AFrom, ATo: string;    use SysUtils.StringReplace
  rpall: boolean = false): string;     }
function emptyname(s: string): string;
//function deleteids(s: string; slsh: boolean = false): string;
function addstr(s1, s2: string): string;
function numstr(n: word; s1, s2, s3: string; engstyle: boolean = false): string;
function CreateDirExt(Dir: string): boolean;
function ClearHTML(s: string): string;
function RadioGroupDlg(ACaption, AHint: String;
  AItems: array of String): Integer;
function DeleteTo(s: String; subs: string; casesens: boolean = true;
  re: boolean = false): string;
function DeleteFromTo(s, sub1, sub2: String; casesens: boolean = true;
  recursive: boolean = false): String;
function GetBtString(n: Extended): string;
function GetBtStringEx(n: Extended): string;

function diff(n1, n2: Extended): Extended;
function batchreplace(src: string; substr1: array of string;
  substr2: string): string;
function STRINGENCODE(s: STRING): STRING;
function STRINGDECODE(s: STRING): STRING;
function Trim(s: String; ch: Char = ' '): String;
function TrimEx(s: String; ch: TSetOfChar): String;
function CopyTo(s, substr: string; back: boolean = false; re: boolean = false): string; overload;
function CopyTo(Source: String; ATo: Char; Isl: array of string): string; overload;
function CopyTo(var Source: String; ATo: Char; Isl: array of string; cut: boolean = false): string; overload;
function CopyFromTo(s, sub1, sub2: String; re: boolean = false): String; overload;
function CopyFromTo(Source: String; AFrom,ATo: Char; Isl: array of string): String; overload;
function ExtractFolder(s: string): string;
function MoveDir(const fromDir, toDir: string): boolean;
procedure MultWordArrays(var a1: TArrayOfWord; a2: TArrayOfWord);
procedure _Delay(dwMilliseconds: Longint);
function ValidFName(FName: String; bckslsh: boolean = false): String;
function strlisttostr(s: tstringlist; del: Char = ';'; ins: Char = '"'): string;
function strtostrlist(s: string; del: Char = ';'; ins: Char = '"'): string;
procedure DrawImage(AImage: TImage; AStream: TStream; Ext: String);
procedure DrawImageFromRes(AImage: TImage; ResName, Ext: String);
procedure WriteLWToPChar(n: LongWord; p: PChar);
function ReadLWFromPChar(p: PChar): LongWord;
function PngToIcon(const Png: TPngImage; Background: TColor = clNone): HICON;
function ImageFormat(Start: Pointer): string;
function GetWinVersion: string;
procedure ShutDown;
function CheckStr(s: string; a: TSetOfChar; inv: boolean = false): boolean;
function CheckStrPos(s: string; a: TSetOfChar; inv: boolean = false): Integer;
function CharPos(str: string; ch: Char; Isolators: array of string;
  From: Integer = 1): Integer;
function CharPosEx(str: string; ch: TSetOfChar; Isolators: array of string;
  From: Integer = 1): Integer;
function GetNextS(var s: string; del: Char = ';'; ins: Char = #0): string;
function GetNextSEx(var s: string; del: TSetOfChar = [';'];
  ins: TSetOfChar = []): string;
procedure FileToString(FileName: String; var AValue: AnsiString);
function MathCalcStr(s: variant): variant;
function DateTimeStrEval(const DateTimeFormat: string;
  const DateTimeStr: string; locale: string): TDateTime;
function strnull(s: variant): variant;
function nullstr(Value: Variant): Variant;
function ifn(b: boolean; thn, els: variant): variant;
function DeleteEx(S: String; Index,Count: integer): String;
procedure SaveStrToFile(S, FileName: String; Add: boolean = false);

implementation

const
  _SYMBOL_MISSED_ = 'Cant found symbol "%s" for #%d "%s" in "%s"';
  _OPERATOR_MISSED_ = 'Must be an operator instead of #%d "%s" in "%s"';
  _OPERAND_MISSED_ = 'Must be an oparand instead of #%d "%s" in "%s"';
  _INVALID_TYPECAST_ = 'Invalid typecast for "%s" %s "%s" near #%d in "%s"';
  _INCORRECT_SYMBOL_ = 'Incorrect value "%s" near #%d in "%s"';

function ClearHTML(s: string): string; // Заебись

type
  tmnemonica = packed record
    m: string;
    a: word;
  end;

const
  // http://ru.wikipedia.org/wiki/%D0%9C%D0%BD%D0%B5%D0%BC%D0%BE%D0%BD%D0%B8%D0%BA%D0%B8_%D0%B2_HTML
  // 2011-09-27

  a: array [1 .. 252] of tmnemonica = ((m: 'AElig'; a: 198), (m: 'Aacute';
    a: 193), (m: 'Acirc'; a: 194), (m: 'Agrave'; a: 192), (m: 'Alpha'; a: 913),
    (m: 'Aring'; a: 197), (m: 'Atilde'; a: 195), (m: 'Auml'; a: 196),
    (m: 'Beta'; a: 914), (m: 'Ccedil'; a: 199), (m: 'Chi'; a: 935),
    (m: 'Dagger'; a: 8225), (m: 'Delta'; a: 916), (m: 'ETH'; a: 208),
    (m: 'Eacute'; a: 201), (m: 'Ecirc'; a: 202), (m: 'Egrave'; a: 200),
    (m: 'Epsilon'; a: 917), (m: 'Eta'; a: 919), (m: 'Euml'; a: 203),
    (m: 'Gamma'; a: 915), (m: 'Iacute'; a: 205), (m: 'Icirc'; a: 206),
    (m: 'Igrave'; a: 204), (m: 'Iota'; a: 921),
    // 25
    (m: 'Iuml'; a: 207), (m: 'Kappa'; a: 922), (m: 'Lambda'; a: 923), (m: 'Mu';
    a: 924), (m: 'Ntilde'; a: 209), (m: 'Nu'; a: 925), (m: 'OElig'; a: 338),
    (m: 'Oacute'; a: 211), (m: 'Ocirc'; a: 212), (m: 'Ograve'; a: 210),
    (m: 'Omega'; a: 937), (m: 'Omicron'; a: 927), (m: 'Oslash'; a: 216),
    (m: 'Otilde'; a: 213), (m: 'Ouml'; a: 214), (m: 'Phi'; a: 934), (m: 'Pi';
    a: 928), (m: 'Prime'; a: 8243), (m: 'Psi'; a: 936), (m: 'Rho'; a: 929),
    (m: 'Scaron'; a: 352), (m: 'Sigma'; a: 931), (m: 'THORN'; a: 222),
    (m: 'Tau'; a: 932), (m: 'Theta'; a: 920),
    // 50
    (m: 'Uacute'; a: 218), (m: 'Ucirc'; a: 219), (m: 'Ugrave'; a: 217),
    (m: 'Upsilon'; a: 933), (m: 'Uuml'; a: 220), (m: 'Xi'; a: 926),
    (m: 'Yacute'; a: 221), (m: 'Yuml'; a: 376), (m: 'Zeta'; a: 918),
    (m: 'aacute'; a: 225), (m: 'acirc'; a: 226), (m: 'acute'; a: 180),
    (m: 'aelig'; a: 230), (m: 'agrave'; a: 224), (m: 'alefsym'; a: 8501),
    (m: 'alpha'; a: 945), (m: 'amp'; a: 38), (m: 'and'; a: 8743), (m: 'ang';
    a: 8736), (m: 'aring'; a: 229), (m: 'asymp'; a: 8776), (m: 'atilde';
    a: 227), (m: 'auml'; a: 228), (m: 'bdquo'; a: 8222), (m: 'beta'; a: 946),
    // 75
    (m: 'brvbar'; a: 166), (m: 'bull'; a: 8226), (m: 'cap'; a: 8745),
    (m: 'ccedil'; a: 231), (m: 'cedil'; a: 184), (m: 'cent'; a: 162), (m: 'chi';
    a: 967), (m: 'circ'; a: 710), (m: 'clubs'; a: 9827), (m: 'cong'; a: 8773),
    (m: 'copy'; a: 169), (m: 'crarr'; a: 8629), (m: 'cup'; a: 8746),
    (m: 'curren'; a: 164), (m: 'dArr'; a: 8659), (m: 'dagger'; a: 8224),
    (m: 'darr'; a: 8595), (m: 'deg'; a: 176), (m: 'delta'; a: 948), (m: 'diams';
    a: 9830), (m: 'divide'; a: 247), (m: 'eacute'; a: 233), (m: 'ecirc';
    a: 234), (m: 'egrave'; a: 232), (m: 'empty'; a: 8709),
    // 100
    (m: 'emsp'; a: 8195), (m: 'ensp'; a: 8194), (m: 'epsilon'; a: 949),
    (m: 'equiv'; a: 8801), (m: 'eta'; a: 951), (m: 'eth'; a: 240), (m: 'euml';
    a: 235), (m: 'euro'; a: 8364), (m: 'exist'; a: 8707), (m: 'fnof'; a: 402),
    (m: 'forall'; a: 8704), (m: 'frac12'; a: 189), (m: 'frac14'; a: 188),
    (m: 'frac34'; a: 190), (m: 'frasl'; a: 8260), (m: 'gamma'; a: 947),
    (m: 'ge'; a: 8805), (m: 'gt'; a: 62), (m: 'hArr'; a: 8660), (m: 'harr';
    a: 8596), (m: 'hearts'; a: 9829), (m: 'hellip'; a: 8230), (m: 'iacute';
    a: 237), (m: 'icirc'; a: 238), (m: 'iexcl'; a: 161),
    // 125
    (m: 'igrave'; a: 236), (m: 'image'; a: 8465), (m: 'infin'; a: 8734),
    (m: 'int'; a: 8747), (m: 'iota'; a: 953), (m: 'iquest'; a: 191), (m: 'isin';
    a: 8712), (m: 'iuml'; a: 239), (m: 'kappa'; a: 954), (m: 'lArr'; a: 8656),
    (m: 'lambda'; a: 955), (m: 'lang'; a: 9001), (m: 'laquo'; a: 171),
    (m: 'larr'; a: 8592), (m: 'lceil'; a: 8968), (m: 'ldquo'; a: 8220),
    (m: 'le'; a: 8804), (m: 'lfloor'; a: 8970), (m: 'lowast'; a: 8727),
    (m: 'loz'; a: 9674), (m: 'lrm'; a: 8206), (m: 'lsaquo'; a: 8249),
    (m: 'lsquo'; a: 8216), (m: 'lt'; a: 60), (m: 'macr'; a: 175),
    // 150
    (m: 'mdash'; a: 8212), (m: 'micro'; a: 181), (m: 'middot'; a: 183),
    (m: 'minus'; a: 8722), (m: 'mu'; a: 956), (m: 'nabla'; a: 8711), (m: 'nbsp';
    a: 160), (m: 'ndash'; a: 8211), (m: 'ne'; a: 8800), (m: 'ni'; a: 8715),
    (m: 'not'; a: 172), (m: 'notin'; a: 8713), (m: 'nsub'; a: 8836),
    (m: 'ntilde'; a: 241), (m: 'nu'; a: 957), (m: 'oacute'; a: 243),
    (m: 'ocirc'; a: 244), (m: 'oelig'; a: 339), (m: 'ograve'; a: 242),
    (m: 'oline'; a: 8254), (m: 'omega'; a: 969), (m: 'omicron'; a: 959),
    (m: 'oplus'; a: 8853), (m: 'or'; a: 8744), (m: 'ordf'; a: 170),
    // 175
    (m: 'ordm'; a: 186), (m: 'oslash'; a: 248), (m: 'otilde'; a: 245),
    (m: 'otimes'; a: 8855), (m: 'ouml'; a: 246), (m: 'para'; a: 182),
    (m: 'part'; a: 8706), (m: 'permil'; a: 8240), (m: 'perp'; a: 8869),
    (m: 'phi'; a: 966), (m: 'pi'; a: 960), (m: 'piv'; a: 982), (m: 'plusmn';
    a: 177), (m: 'pound'; a: 163), (m: 'prime'; a: 8242), (m: 'prod'; a: 8719),
    (m: 'prop'; a: 8733), (m: 'psi'; a: 968), (m: 'quot'; a: 34), (m: 'rArr';
    a: 8658), (m: 'radic'; a: 8730), (m: 'rang'; a: 9002), (m: 'raquo'; a: 187),
    (m: 'rarr'; a: 8594), (m: 'rceil'; a: 8969),
    // 200
    (m: 'rdquo'; a: 8221), (m: 'real'; a: 8476), (m: 'reg'; a: 174),
    (m: 'rfloor'; a: 8971), (m: 'rho'; a: 961), (m: 'rlm'; a: 8207),
    (m: 'rsaquo'; a: 8250), (m: 'rsquo'; a: 8217), (m: 'sbquo'; a: 8218),
    (m: 'scaron'; a: 353), (m: 'sdot'; a: 8901), (m: 'sect'; a: 167), (m: 'shy';
    a: 173), (m: 'sigma'; a: 963), (m: 'sigmaf'; a: 962), (m: 'sim'; a: 8764),
    (m: 'spades'; a: 9824), (m: 'sub'; a: 8834), (m: 'sube'; a: 8838),
    (m: 'sum'; a: 8721), (m: 'sup'; a: 8835), (m: 'sup1'; a: 185), (m: 'sup2';
    a: 178), (m: 'sup3'; a: 179), (m: 'supe'; a: 8839),
    // 225
    (m: 'szlig'; a: 223), (m: 'tau'; a: 964), (m: 'there4'; a: 8756),
    (m: 'theta'; a: 952), (m: 'thetasy'; a: 977), (m: 'thinsp'; a: 8201),
    (m: 'thorn'; a: 254), (m: 'tilde'; a: 732), (m: 'times'; a: 215),
    (m: 'trade'; a: 8482), (m: 'uArr'; a: 8657), (m: 'uacute'; a: 250),
    (m: 'uarr'; a: 8593), (m: 'ucirc'; a: 251), (m: 'ugrave'; a: 249),
    (m: 'uml'; a: 168), (m: 'upsih'; a: 978), (m: 'upsilon'; a: 965),
    (m: 'uuml'; a: 252), (m: 'weierp'; a: 8472), (m: 'xi'; a: 958),
    (m: 'yacute'; a: 253), (m: 'yen'; a: 165), (m: 'yuml'; a: 255),
    (m: 'zeta'; a: 950),
    // 250
    (m: 'zwj'; a: 8205), (m: 'zwnj'; a: 8204)
    // 252
    );

  C_SEP = ';';
  C_SPC = '&';
  C_NUM = '#';
  N_MLN = 7;
  N_MNC = 252;
var
  i, l, t, spc: Integer;

  function ChMnem(var s: string; const b, e: Integer): boolean;
  var
    i: Integer;
    c: string;
  begin
    Result := false;
    c := copy(s, b + 1, e - b - 1);
    i := 1;
    while i <= N_MNC do
    begin
      if a[i].m = c then
      begin
        s[b] := Char(a[i].a);
        Delete(s, b + 1, e - b);
        Result := true;
      end
      else if a[i].m > c then
        break;
      inc(i);
    end;
  end;

  function ChNum(var s: string; const b, e: Integer): boolean;
  begin
    s[b] := Char(StrToInt(copy(s, b + 2, e - b - 2)));
    Delete(s, b + 1, e - b);
    Result := true;
  end;

begin

  l := length(s);
  t := -1;
  i := 1;
  spc := -1;
  while i <= l do
  begin
    case t of
      - 1:
        case s[i] of
          C_SPC:
            begin
              spc := i;
              t := 0;
            end;
        end;
      0 .. 2:
        case s[i] of
          C_SPC:
            begin
              spc := i;
              t := 0;
            end;
          'A' .. 'F', 'a' .. 'f':
            case t of
              0:
                t := 1;
              1, 2:
                ;
            else
              t := -1;
            end;
          'G' .. 'W', 'Y', 'Z', 'g' .. 'w', 'y', 'z':
            case t of
              0:
                t := 1;
              1:
                ;
            else
              t := -1;
            end;
          C_NUM:
            case t of
              0:
                t := 2;
            else
              t := -1;
            end;
          'X', 'x':
            case t of
              0:
                t := 1;
              1:
                ;
              2:
                if i - spc <> 3 then
                  t := -1;
            else
              t := -1;
            end;
          '0' .. '9':
            case t of
              2:
                ;
            else
              t := -1;
            end;
          C_SEP:
            begin
              case t of
                1:
                  if (i - spc <= N_MLN) and ChMnem(s, spc, i) then
                    dec(i, i - spc);
                2:
                  if ChNum(s, spc, i) then
                    dec(i, i - spc);
              end;
              t := -1;
            end;
        end;
    end;
    inc(i);
  end;

  Result := s;
end;

function emptyname(s: string): string;
var
  p: Integer;
begin
  p := length(s);
  while (p > 0) and not CharInSet(s[p], ['/', '=']) do
    dec(p);
  Delete(s, 1, p);
  Result := s;
end;

//use SysUtils.StringReplace
{function Replace(src, AFrom, ATo: string;
  rpall: boolean = false): string;
var
  n: Integer;
begin
  if AFrom = ATo then
  begin
    Result := src;
    Exit;
  end;

  Result := '';
  n := pos(AFrom, src);

  while n > 0 do
  begin
    Result := Result + copy(src, 1, n - 1) + Ato;
    Delete(src, 1, n + length(AFrom) - 1);
    if rpall then
      n := pos(AFrom, src)
    else
      n := 0;
  end;
  Result := Result + src;
end;    }

{function deleteids(s: string; slsh: boolean): string;
var
  p: Integer;
begin
  if not slsh then
  begin
    p := pos('?', s);
    Delete(s, p, length(s) - p + 1);
    Result := s;
  end
  else
  begin
    p := length(s);
    while (p > 0) and (s[p] <> '/') do
      dec(p);
    if p = 0 then
      Result := s
    else
      Result := copy(s, 1, p - 1) + ExtractFileExt(s);
  end;
end;      }

function addstr(s1, s2: string): string;
var
  p: Integer;
begin
  Result := '';
  p := pos('/', s1);
  if p > 0 then
  begin
    if (length(s1) > p) and (s1[p + 1] = '/') then
    begin
      Result := copy(s1, 1, p + 1);
      Delete(s1, 1, p + 1);
    end;
    p := pos('/', s1);
    if p = 0 then
    begin
      s1 := s1 + '/';
      p := length(s1);
    end;
    insert(s2, s1, p + 1);
  end;
  Result := Result + s1;
end;

function numstr(n: word; s1, s2, s3: string; engstyle: boolean = false): string;
begin
  if engstyle then
    if (n > 1) or (n = 0) then
      Result := 's'
    else
      Result := ''
  else if ((n mod 100) div 10 = 1) then
    Result := s3
  else
    case n mod 10 of
      1:
        Result := s1;
      2 .. 4:
        Result := s2;
      5 .. 9, 0:
        Result := s3;
    end;

end;

function CreateDirExt(Dir: string): boolean;
var
  i, l: Integer;
  CurDir: string;
begin
  Result := DirectoryExists(Dir);
  if Result then
    Exit;
  if ExcludeTrailingPathDelimiter(Dir) = '' then
    Exit;
  Dir := IncludeTrailingPathDelimiter(Dir);
  l := length(Dir);
  for i := 1 to l do
  begin
    CurDir := CurDir + Dir[i];
    if Dir[i] = '\' then
    begin
      if not DirectoryExists(CurDir) then
        if not CreateDir(CurDir) then
          Exit;
    end;
  end;
  Result := true;
end;

function GetBtString(n: Extended): string;
var
  l: byte;
begin
  l := 0;
  while n > 1000 do
  begin
    n := n / 1024;
    inc(l);
  end;

  Result := FloatToStr(RoundTo(n, -2));

  case l of
    0:
      Result := Result + 'b';
    1:
      Result := Result + 'Kb';
    2:
      Result := Result + 'Mb';
    3:
      Result := Result + 'Gb';
    4:
      Result := Result + 'Tb';
  end;

end;

function GetBtStringEx(n: Extended): string;
var
  l: byte;
begin
  l := 0;
  while n > 1000 do
  begin
    n := n / 1024;
    inc(l);
  end;

  Result := FloatToStr(RoundTo(n, -2));

  case l of
    0:
      Result := 'b';
    1:
      Result := 'Kb';
    2:
      Result := 'Mb';
    3:
      Result := 'Gb';
    4:
      Result := 'Tb';
  end;

end;

function batchreplace(src: string; substr1: array of string;
  substr2: string): string;
var
  i: Integer;
begin
  for i := 0 to length(substr1) - 1 do
    src := StringReplace(src, substr1[i], substr2,[]);
  Result := src;
end;

function RadioGroupDlg(ACaption, AHint: String;
  AItems: array of String): Integer;
var
  F: TForm;
  l: TLabel;
  R: TRadioGroup;
  OkBtn, CancelBtn: TButton;
  i, n: Integer;
begin

  Result := -1;

  if length(AItems) = 0 then
    Exit;
  F := TForm.Create(Application);
  F.Caption := ACaption;
  F.BorderStyle := bsDialog;
  F.Position := poMainFormCenter;
  l := TLabel.Create(F);
  l.Parent := F;
  if AHint = '' then
    l.Caption := 'Select value:'
  else
    l.Caption := AHint;
  l.Left := 4;
  l.Top := 4;
  R := TRadioGroup.Create(F);
  R.Parent := F;
  R.Top := l.Top + l.Height + 4;
  R.Left := 4;
  n := -1;
  for i := 0 to length(AItems) - 1 do
  begin
    R.Items.Add(AItems[i]);
    if F.Canvas.TextWidth(AItems[i]) > n then
      n := F.Canvas.TextWidth(AItems[i]);
  end;
  R.ItemIndex := 0;
  R.Width := Max(n + 8 + 24, 200);
  R.Height := R.Items.Count * 20 + 12;
  F.ClientWidth := R.Left + R.Width + 4;

  OkBtn := TButton.Create(F);
  OkBtn.Parent := F;
  OkBtn.Caption := 'Ok';
  OkBtn.ModalResult := mrOk;
  OkBtn.Default := true;
  OkBtn.Left := 4;
  OkBtn.Top := R.Top + R.Height + 4;

  CancelBtn := TButton.Create(F);
  CancelBtn.Parent := F;
  CancelBtn.Caption := 'Cancel';
  CancelBtn.ModalResult := mrCancel;
  CancelBtn.Cancel := true;
  CancelBtn.Left := OkBtn.Left + OkBtn.Width + 4;
  CancelBtn.Top := OkBtn.Top;

  F.ClientHeight := OkBtn.Top + OkBtn.Height + 4;
  F.ShowModal;
  case F.ModalResult of
    mrOk:
      Result := R.ItemIndex;
  else
    Result := -1;
  end;
  OkBtn.Free;
  CancelBtn.Free;
  l.Free;
  R.Free;
  F.Free;
end;

function DeleteTo(s: String; subs: string; casesens: boolean = true;
  re: boolean = false): string;
var
  p: Integer;
begin
  Result := s;

  if casesens then
  begin
    p := pos(subs, s);
    if p > 0 then
      Delete(s, 1, p + length(subs) - 1);
  end
  else
  begin
    p := pos(UPPERCASE(subs), UPPERCASE(s));
    if p > 0 then
      Delete(s, 1, p + length(subs) - 1);
  end;
  if re and (Result = s) then
    Result := ''
  else
    Result := s;
end;

function diff(n1, n2: Extended): Extended;
begin
  if n2 = 0 then
    Result := 0
  else
    Result := n1 / n2;
end;

function STRINGENCODE(s: STRING): STRING;
begin
  Result := String(HTTPENCODE(UTF8ENCODE(s)));
end;

function STRINGDECODE(s: STRING): STRING;
begin
  Result := UTF8ToString(HTTPDECODE(AnsiString(s)));
end;

function GetNextS(var s: string; del: Char = ';'; ins: Char = #0): string;
var
  n: Integer;
begin
  Result := '';

  if ins <> #0 then
    while true do
    begin
      n := pos(ins, s);
      if (n > 0) and (pos(del, s) > n) then
      begin
        Result := Result + copy(s, 1, n - 1);
        Delete(s, 1, n);
        n := pos(ins, s);
        case n of
          0:
            raise Exception.Create('Can''t find 2nd insulator ''' + ins + ''':'
              + #13#10 + s);
          1:
            Result := Result + copy(s, 1, n);
        else
          Result := Result + copy(s, 1, n - 1);
        end;
        Delete(s, 1, n);
      end
      else
        break;
    end;

  n := pos(del, s);
  if n > 0 then
  begin
    Result := Result + copy(s, 1, n - 1);
    Delete(s, 1, n);
  end
  else
  begin
    Result := Result + s;
    s := '';
  end;
end;

function GetNextSEx(var s: string; del: TSetOfChar = [';'];
  ins: TSetOfChar = []): string;
begin

end;

function Trim(s: String; ch: Char = ' '): String;
var
  i, l: Integer;
begin
  l := length(s);
  i := 1;
  while (i <= l) and (s[i] = ch) do
    inc(i);
  if i > l then
    Result := ''
  else
  begin
    while s[l] = ch do
      dec(l);
    Result := copy(s, i, l - i + 1);
  end;
end;

function TrimEx(s: String; ch: TSetOfChar): String;
var
  i, l: Integer;
begin
  l := length(s);
  i := 1;
  while (i <= l) and (CharInSet(s[i], ch)) do
    inc(i);
  if i > l then
    Result := ''
  else
  begin
    while CharInSet(s[l], ch) do
      dec(l);
    Result := copy(s, i, l - i + 1);
  end;
end;

function CopyTo(s, substr: string; back: boolean; re: boolean): string;
var
  i: Integer;
begin
  if back then
    s := ReverseString(s);

    i := pos(substr, s);

    if i = 0 then
      if re then
        Result := ''
      else
        Result := copy(s, 1, length(s))
    else
      Result := copy(s, 1, i - 1);

    if back then
      Result := ReverseString(Result);
  //end;
end;

function CopyTo(Source: String; ATo: Char; Isl: array of string): string;
var
  i: Integer;
begin
  i := CharPos(Source,ATo,Isl);
  if i = 0 then
    Result := copy(Source, 1, length(Source))
  else
    Result := copy(Source, 1, i - 1);
end;

function CopyTo(var Source: String; ATo: Char; Isl: array of string; cut: boolean = false): string;
var
  i: Integer;
begin
  i := CharPos(Source,ATo,Isl);
  if i = 0 then
    Result := copy(Source, 1, length(Source))
  else
    Result := copy(Source, 1, i - 1);
  if cut then
    if i = 0 then
      Delete(Source,1,length(Source))
    else
      Delete(Source,1,i);
end;

function CopyFromTo(s, sub1, sub2: String; re: boolean = false): String;
var
  l1, l2: Integer;
//  tmp: string;
begin
//  tmp := lowercase(s);
  Result := '';

  l1 := Pos(lowercase(sub1), lowercase(s));
  if (l1 = 0) and re then
//    Delete(tmp, 1, l1 + length(sub1) - 1)
    Exit;

  l2 := PosEx(lowercase(sub2),lowercase(s),l1 + 1);

  if l2 = 0 then
    if re then
      Exit
    else
      l2 := length(s) + 1;
{  else
    l2 := l2 + length(s) - length(tmp);    }

  if l1 > 0 then
    Result := copy(s, l1 + length(sub1), l2 - l1 - length(sub1))
  else
    Result := copy(s, 1, l2 - 1);
end;

function CopyFromTo(Source: String; AFrom,ATo: Char; Isl: array of string): String;
var
  n1,n2: integer;
begin

  n1 := CharPos(Source,AFrom,Isl);

  if n1 = 0 then
  begin
    Result := '';
    Exit;
  end;

  n2 := CharPos(Source,ATo,Isl,n1 + 1);

  if n2 = 0 then
  begin
    Result := '';
    Exit;
  end;

  Result := Copy(Source,n1+1,n2-n1-1);

end;

function DeleteFromTo(s, sub1, sub2: String; casesens: boolean = true;
  recursive: boolean = false): String;
var
  l1, l2: Integer;
begin
//  Result := '';

  sub1 := lowercase(sub1);
  sub2 := lowercase(sub2);

  l1 := pos(lowercase(sub1), lowercase(s));

  while l1 > 0 do
  begin
    l2 := PosEx(sub2, lowercase(s), l1 + 1);
    if (l1 > 0) and (l2 > 0) then
    begin
      Delete(s, l1, l2 - l1 + length(sub2));

      if recursive then
        l1 := PosEx(sub1, lowercase(s),l1)
      else
        l1 := 0;
    end else
      l1 := 0;
  end;

  Result := s;
end;

function ExtractFolder(s: string): string;
var
  p1, p2: Integer;
begin
  p1 := length(s);
  while (p1 > 0) and not(CharInSet(s[p1], ['/', '\'])) do
    dec(p1);
  p2 := p1 - 1;
  while (p2 > 0) and not(CharInSet(s[p2], ['/', '\'])) do
    dec(p2);
  Result := copy(s, p2 + 1, p1 - p2 - 1);
end;

function MoveDir(const fromDir, toDir: string): boolean;
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc := FO_MOVE;
    fFlags := FOF_FILESONLY;
    pFrom := PChar(fromDir + #0);
    pTo := PChar(toDir)
  end;
  Result := (0 = ShFileOperation(fos));
end;

procedure MultWordArrays(var a1: TArrayOfWord; a2: TArrayOfWord);
var
  i, la1, la2: Integer;
begin
  la1 := length(a1);
  la2 := length(a2);
  SetLength(a1, la1 + la2);

  for i := 0 to la2 - 1 do
    a1[la1 + i] := a2[i];
end;

procedure _Delay(dwMilliseconds: Longint);
var
  iStart, iStop: DWORD;
begin
  iStart := GetTickCount;
  repeat
    iStop := GetTickCount;
    Application.ProcessMessages;
  until (iStop - iStart) >= DWORD(dwMilliseconds);
end;

function ValidFName(FName: String; bckslsh: boolean): String;
const
  n = ['\', '/', ':', '*', '"', '<', '>', '|', '?'];
var
  i: Integer;
begin
  for i := 1 to length(FName) do
    if CharInSet(FName[i], n) and (not bckslsh or (FName[i] <> '\')) then
      FName[i] := '_';
  Result := FName;
end;

function strlisttostr(s: tstringlist; del, ins: Char): string;
var
  i, j: Integer;
  s1, s2: string;
begin
  Result := '';
  for i := 0 to s.Count - 1 do
  begin
    s2 := '';
    s1 := s[i];
    j := pos(ins, s1);
    while j > 0 do
    begin
      s2 := s2 + copy(s1, 1, j) + ins;
      Delete(s1, 1, j);
      j := pos(ins, s1);
    end;
    s2 := s2 + s1;

    if (ins <> #0) and (pos(del, s2) > 0) then
      s2 := ins + s2 + ins;
    if i < s.Count - 1 then
      Result := Result + s2 + del
    else
      Result := Result + s2;
  end;
end;

function strtostrlist(s: string; del, ins: Char): string;
var
  ss: string;
begin
  Result := '';
  while s <> '' do
  begin
    ss := GetNextS(s, del, ins);
    if s = '' then
      Result := Result + ss
    else
      Result := Result + ss + #13#10;
  end;
end;

procedure DrawImage(AImage: TImage; AStream: TStream; Ext: String);
var
  Graphic: TGraphic;
begin
  Ext := LOWERCASE(Ext);
  Delete(Ext, 1, 1);
  Graphic := nil;
  if (Ext = 'jpeg') or (Ext = 'jpg') then
    Graphic := TJPEGIMAGE.Create;
  if (Ext = 'png') then
    Graphic := TPngImage.Create;
  if (Ext = 'gif') then
  begin
    Graphic := TGIFIMAGE.Create;
  end;
  if not Assigned(Graphic) then
    Exit;
  AStream.Position := 0;
  Graphic.LoadFromStream(AStream);

  if (Graphic is TGIFIMAGE) then
    with TGIFIMAGE(Graphic) do
    begin
      if Transparent then
        AImage.Transparent := Transparent;
      if Images.Count > 0 then
        Animate := true;
    end;

  AImage.Picture.Graphic := Graphic;
end;

procedure DrawImageFromRes(AImage: TImage; ResName, Ext: String);
var
  F: TResourceStream;
begin
  F := TResourceStream.Create(hInstance, ResName, RT_RCDATA);
  DrawImage(AImage, F, Ext);
  F.Free;
end;

procedure WriteLWToPChar(n: LongWord; p: PChar);
begin
  (p + 0)^ := Char(n mod 256);
  (p + 1)^ := Char(n div 256 mod 256);
  (p + 2)^ := Char(n div 256 div 256 mod 256);
  (p + 3)^ := Char(n div 256 div 256 div 256 mod 256);
end;

function ReadLWFromPChar(p: PChar): LongWord;
begin
  Result := Ord((p + 0)^) + Ord((p + 1)^) * 256 + Ord((p + 2)^) * 256 * 256 +
    Ord((p + 3)^) * 256 * 256 * 256;
end;

function PngToIcon(const Png: TPngImage; Background: TColor): HICON;
const
  MaxRGBQuads = MaxInt div SizeOf(TRGBQuad) - 1;
type
  TRGBQuadArray = array [0 .. MaxRGBQuads] of TRGBQuad;
  PRGBQuadArray = ^TRGBQuadArray;

  TBitmapInfo4 = packed record
    bmiHeader: TBitmapV4Header;
    bmiColors: array [0 .. 0] of TRGBQuad;
  end;

  function PngToIcon32(Png: TPngImage): HICON;
  var
    ImageBits: PRGBQuadArray;
    BitmapInfo: TBitmapInfo4;
    IconInfo: TIconInfo;
    AlphaBitmap: HBitmap;
    MaskBitmap: TBitmap;
    X, Y: Integer;
    AlphaLine: PByteArray;
    HasAlpha, HasBitmask: boolean;
    Color, TransparencyColor: TColor;
  begin
    // Convert a PNG object to an alpha-blended icon resource
    ImageBits := nil;

    // Allocate a DIB for the color data and alpha channel
    with BitmapInfo.bmiHeader do
    begin
      bV4Size := SizeOf(BitmapInfo.bmiHeader);
      bV4Width := Png.Width;
      bV4Height := Png.Height;
      bV4Planes := 1;
      bV4BitCount := 32;
      bV4V4Compression := BI_BITFIELDS;
      bV4SizeImage := 0;
      bV4XPelsPerMeter := 0;
      bV4YPelsPerMeter := 0;
      bV4ClrUsed := 0;
      bV4ClrImportant := 0;
      bV4RedMask := $00FF0000;
      bV4GreenMask := $0000FF00;
      bV4BlueMask := $000000FF;
      bV4AlphaMask := $FF000000;
    end;
    AlphaBitmap := CreateDIBSection(0, PBitmapInfo(@BitmapInfo)^,
      DIB_RGB_COLORS, Pointer(ImageBits), 0, 0);
    try
      // Spin through and fill it with a wash of color and alpha.
      AlphaLine := nil;
      HasAlpha := Png.Header.ColorType in [COLOR_GRAYSCALEALPHA,
        COLOR_RGBALPHA];
      HasBitmask := Png.TransparencyMode = ptmBit;
      TransparencyColor := Png.TransparentColor;
      for Y := 0 to Png.Height - 1 do
      begin
        if HasAlpha then
          AlphaLine := Png.AlphaScanline[Png.Height - Y - 1];
        for X := 0 to Png.Width - 1 do
        begin
          Color := Png.Pixels[X, Png.Height - Y - 1];
          ImageBits^[Y * Png.Width + X].rgbRed := Color and $FF;
          ImageBits^[Y * Png.Width + X].rgbGreen := Color shr 8 and $FF;
          ImageBits^[Y * Png.Width + X].rgbBlue := Color shr 16 and $FF;
          if HasAlpha then
            ImageBits^[Y * Png.Width + X].rgbReserved := AlphaLine^[X]
          else if HasBitmask then
            ImageBits^[Y * Png.Width + X].rgbReserved :=
              Integer(Color <> TransparencyColor) * 255;
        end;
      end;

      // Create an empty mask
      MaskBitmap := TBitmap.Create;
      try
        MaskBitmap.Width := Png.Width;
        MaskBitmap.Height := Png.Height;
        MaskBitmap.PixelFormat := pf1bit;
        MaskBitmap.Canvas.Brush.Color := clBlack;
        MaskBitmap.Canvas.FillRect(Rect(0, 0, MaskBitmap.Width,
          MaskBitmap.Height));

        // Create the alpha blended icon
        IconInfo.fIcon := true;
        IconInfo.hbmColor := AlphaBitmap;
        IconInfo.hbmMask := MaskBitmap.Handle;
        Result := CreateIconIndirect(IconInfo);
      finally
        MaskBitmap.Free;
      end;
    finally
      DeleteObject(AlphaBitmap);
    end;
  end;

  function PngToIcon24(Png: TPngImage; Background: TColor): HICON;
  var
    ColorBitmap, MaskBitmap: TBitmap;
    X, Y: Integer;
    AlphaLine: PByteArray;
    IconInfo: TIconInfo;
    TransparencyColor: TColor;
  begin
    ColorBitmap := TBitmap.Create;
    MaskBitmap := TBitmap.Create;
    try
      ColorBitmap.Width := Png.Width;
      ColorBitmap.Height := Png.Height;
      ColorBitmap.PixelFormat := pf32bit;
      MaskBitmap.Width := Png.Width;
      MaskBitmap.Height := Png.Height;
      MaskBitmap.PixelFormat := pf32bit;

      // Draw the color bitmap
      ColorBitmap.Canvas.Brush.Color := Background;
      ColorBitmap.Canvas.FillRect(Rect(0, 0, Png.Width, Png.Height));
      Png.Draw(ColorBitmap.Canvas, Rect(0, 0, Png.Width, Png.Height));

      // Create the mask bitmap
      if Png.Header.ColorType in [COLOR_GRAYSCALEALPHA, COLOR_RGBALPHA] then
        for Y := 0 to Png.Height - 1 do
        begin
          AlphaLine := Png.AlphaScanline[Y];
          for X := 0 to Png.Width - 1 do
            if AlphaLine^[X] = 0 then
              SetPixelV(MaskBitmap.Canvas.Handle, X, Y, clWhite)
            else
              SetPixelV(MaskBitmap.Canvas.Handle, X, Y, clBlack);
        end
      else if Png.TransparencyMode = ptmBit then
      begin
        TransparencyColor := Png.TransparentColor;
        for Y := 0 to Png.Height - 1 do
          for X := 0 to Png.Width - 1 do
            if Png.Pixels[X, Y] = TransparencyColor then
              SetPixelV(MaskBitmap.Canvas.Handle, X, Y, clWhite)
            else
              SetPixelV(MaskBitmap.Canvas.Handle, X, Y, clBlack);
      end;

      // Create the icon
      IconInfo.fIcon := true;
      IconInfo.hbmColor := ColorBitmap.Handle;
      IconInfo.hbmMask := MaskBitmap.Handle;
      Result := CreateIconIndirect(IconInfo);
    finally
      ColorBitmap.Free;
      MaskBitmap.Free;
    end;
  end;

begin
  if GetComCtlVersion >= ComCtlVersionIE6 then
  begin
    // Windows XP or later, using the modern method: convert every PNG to
    // an icon resource with alpha channel
    Result := PngToIcon32(Png);
  end
  else
  begin
    // No Windows XP, using the legacy method: copy every PNG to a normal
    // bitmap using a fixed background color
    Result := PngToIcon24(Png, Background);
  end;
end;

function ImageFormat(Start: Pointer): string;
type
  ByteArray = array [0 .. 10] of byte;

var
  PB: ^ByteArray absolute Start;
  PW: ^word absolute Start;
  PL: ^DWORD absolute Start;

begin
  if PL^ = $38464947 then
  begin
    { if PB^[4] = Ord('9') then Result := '.gif'
      else } Result := '.gif';
  end
  else if PW^ = $4D42 then
    Result := '.bmp'
  else if PL^ = $474E5089 then
    Result := '.png'
  else if PW^ = $D8FF then
    Result := '.jpeg'
  else
    Result := '';
end;

function GetWinVersion: string;
var
  VersionInfo: TOSVersionInfo;
  OSName: string;
begin
  // устанавливаем размер записи
  VersionInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  if Windows.GetVersionEx(VersionInfo) then
  begin
    with VersionInfo do
    begin
      case dwPlatformId of
        VER_PLATFORM_WIN32s:
          OSName := 'Win32s';
        VER_PLATFORM_WIN32_WINDOWS:
          OSName := 'Windows 95';
        VER_PLATFORM_WIN32_NT:
          OSName := 'Windows NT';
      end; // case dwPlatformId
      Result := OSName + ' Version ' + IntToStr(dwMajorVersion) + '.' +
        IntToStr(dwMinorVersion) + #13#10' (Build ' + IntToStr(dwBuildNumber) +
        ': ' + szCSDVersion + ')';
    end; // with VersionInfo
  end // if GetVersionEx
  else
    Result := '';
end;

procedure ShutDown;
const
  SE_SHUTDOWN_NAME = 'SeShutdownPrivilege'; // Borland forgot this declaration
var
  hToken: THandle;
  tkp: TTokenPrivileges;
  tkpo: TTokenPrivileges;
  zero: DWORD;
begin
  if pos('Windows NT', GetWinVersion) = 1 then
  // we've got to do a whole buch of things
  begin
    zero := 0;
    if not OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or
      TOKEN_QUERY, hToken) then
    begin
      MessageBox(0, 'Exit Error', 'OpenProcessToken() Failed', MB_OK);
      Exit;
    end; // if not OpenProcessToken( GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken)

    if not OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or
      TOKEN_QUERY, hToken) then
    begin
      MessageBox(0, 'Exit Error', 'OpenProcessToken() Failed', MB_OK);
      Exit;
    end; // if not OpenProcessToken( GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken)

    // SE_SHUTDOWN_NAME
    if not LookupPrivilegeValue(nil, 'SeShutdownPrivilege',
      tkp.Privileges[0].Luid) then
    begin
      MessageBox(0, 'Exit Error', 'LookupPrivilegeValue() Failed', MB_OK);
      Exit;
    end; // if not LookupPrivilegeValue( nil, 'SeShutdownPrivilege' , tkp.Privileges[0].Luid )

    tkp.PrivilegeCount := 1;
    tkp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;

    AdjustTokenPrivileges(hToken, false, tkp, SizeOf(TTokenPrivileges),
      tkpo, zero);
    if boolean(GetLastError()) then
    begin
      MessageBox(0, 'Exit Error', 'AdjustTokenPrivileges() Failed', MB_OK);
      Exit;
    end // if Boolean( GetLastError() )
    else
      ExitWindowsEx(EWX_FORCE or EWX_SHUTDOWN, 0);

  end // if OSVersion = 'Windows NT'
  else
  begin // just shut the machine down
    ExitWindowsEx(EWX_FORCE or EWX_SHUTDOWN, 0);
  end; // else
end;

function CheckStr(s: string; a: TSetOfChar; inv: boolean = false): boolean;
var
  i: Integer;
begin
  for i := 1 to length(s) do
    if inv and CharInSet(s[i], a) or not inv and not CharInSet(s[i], a) then
    begin
      Result := true;
      Exit;
    end;

  Result := false;
end;

function CheckStrPos(s: string; a: TSetOfChar; inv: boolean = false): Integer;
var
  i: Integer;
begin
  for i := 1 to length(s) do
    if inv and CharInSet(s[i], a) or not inv and not CharInSet(s[i], a) then
    begin
      Result := i;
      Exit;
    end;

  Result := 0;
end;

function CharPos(str: string; ch: Char; Isolators: array of string;
  From: Integer = 1): Integer;
var
  i, j: Integer;
  n: integer;
  s1,s2: Char;
  st: TSetOfChar;
begin
  st := [];
  for i := 0 to length(Isolators) - 1 do
    st := st + [Isolators[i][1]];

  n := 0;
  s1 := #0;
  s2 := #0;

  for i := From to length(str) do
    if n > 0 then
      if str[i] = s2 then
        dec(n)
      else if str[i] = s1 then
        inc(n)
      else
    else if (str[i] = ch) then
    begin
      Result := i;
      Exit;
    end
    else if CharInSet(str[i], st) then
    begin
      for j := 0 to length(Isolators) - 1 do
        if (str[i] = Isolators[j][1]) then
        begin
          s1 := Isolators[j][1];
          s2 := Isolators[j][2];
          break;
        end;
      inc(n);
    end;
  Result := 0;
end;

function CharPosEx(str: string; ch: TSetOfChar; Isolators: array of string;
  From: Integer = 1): Integer;
var
  i, j: Integer;
  n: integer;
  s1,s2: Char;
  st: TSetOfChar;
begin
  st := [];
  for i := 0 to length(Isolators) - 1 do
    st := st + [Isolators[i][1]];

  n := 0;
  s1 := #0;
  s2 := #0;

  for i := From to length(str) do
    if n > 0 then
      if str[i] = s2 then
        dec(n)
      else if str[i] = s1 then
        inc(n)
      else
    else if CharInSet(str[i], ch) then
    begin
      Result := i;
      Exit;
    end
    else if CharInSet(str[i], st) then
    begin
      for j := 0 to length(Isolators) - 1 do
        if (str[i] = Isolators[j][1]) then
        begin
          s1 := Isolators[j][1];
          s2 := Isolators[j][2];
          break;
        end;
      inc(n);
    end;
  Result := 0;
end;

procedure FileToString(FileName: String; var AValue: AnsiString);
var
  AStream: TFileStream;
begin
  if not fileexists(FileName) then
  begin
    AValue := '';
    Exit;
  end;

  AStream := TFileStream.Create(FileName, fmOpenRead);
  try
    AStream.Position := 0;
    SetLength(AValue, AStream.Size);
    AStream.ReadBuffer(AValue[1], AStream.Size);
  finally
    AStream.Free;
  end;
end;

function MathCalcStr(s: variant): variant;
const
  ops = ['+', '-', '/', '|', '\', '*', '<', '=', '>', '!'];
  { lvl1 = ['+', '-'];
    lvl2 = ['*', '/', '|', '\'];
    lvl3 = ['<', '>', '!', '=']; }
  { p = 0 root
    p = 1 + -
    p = 2 * / | \
    p = 3 < = > ! }
  function Proc(const p: byte; var s: string; var i: Integer; const l: integer; var ls: variant;
    const isstring: boolean = false): variant;
  var
    n, tmp, lvl, tp: Integer;
    op: boolean;
    d: variant;
    tmpls: variant;
    vt: WideString;
    vt2: Double;
    VRESULT: HRESULT;
  label cc; // looooool

  begin
    Result := null;
    op := false;
    d := null;
    while i <= l do
      case s[i] of
        ' ',#13,#10,#9:
          inc(i);
        '"', '''':
          begin
            if op then
              raise Exception.Create(Format(_OPERATOR_MISSED_, [i,s[i],s]));

            Result := '';

            while true do
            begin
              n := CharPos(s, s[i], [], i + 1);

              if n = 0 then
                raise Exception.Create(Format(_SYMBOL_MISSED_, [s[i], i, s[i], s]));

              if (n < l) and (s[n + 1] = s[n]) then
              begin
                Result := Result + copy(s, i + 1, n - i);
                i := n + 1;
              end else
                Break;
            end;

            Result := Result + copy(s, i + 1, n - i - 1);

            i := n + 1;

            if p > 0 then
              break;

            op := true;
          end;
        '+', '-', '/', '|', '\', '*', '<', '=', '>', '!', '&', '~':
          begin
            if not op and (s[i] <> '!') then
              if s[i] = '-' then
                goto cc
              else
                raise Exception.Create(Format(_OPERAND_MISSED_, [i,s[i],s]));

            lvl := 0;
            case s[i] of
              '|':
                lvl := 1;
              '&':
                lvl := 2;
              '<', '>', '!', '=', '~':
                lvl := 3;
              '+', '-':
                lvl := 4;
              '*', '/':
                lvl := 5;
            end;

            if (lvl <= p) and not isstring then
              break;

            tmp := i;
            inc(i);
            d := Proc(lvl, s, i, l, ls, VarIsStr(Result));

            if d = null then
              break;

            if VarIsStr(d) and (p <> 0) then
            begin
              ls := d;
              Break;
            end;

            try
              case s[tmp] of
                '&':
                  Result := Result and d;
                '|':
                  Result := Result or d;
                '+':
                  if VarIsStr(Result) or VarIsStr(d) then
                    Result := VarToStr(Result) + VarToStr(d)
                  else
                    Result := Result + d;
                '-':
                  Result := Result - d;
                '*':
                  Result := Result * d;
                '/':
                  Result := Result / d;
                '<':
                  Result := Result < d;
                '>':
                  Result := Result > d;
                '=':
                  Result := Result = d;
                '~':
                  Result := pos(d,Result) > 0;
                '!':
                  if op then
                    Result := Result <> d
                  else
                    Result := not Result;
              end;

              if (ls <> null) then
                if (p <> 0) then
                  break
                else
                begin
                  Result := VarToStr(Result) + VarToStr(ls);
                  ls := null;
                end;

            except
              on e: exception do
              begin
                e.Message := Format(_INVALID_TYPECAST_,[VarToStr(Result),s[tmp],VarToStr(d),tmp,s]) +
                  #13#10 + e.Message;
                raise exception.Create(e.Message);
              end;
            end;
          end;
        '(':
          begin
            if op then
              raise Exception.Create(Format(_OPERATOR_MISSED_, [i,s[i],s]));

            n := CharPos(s, ')', [], i + 1);

            if n = 0 then
              raise Exception.Create(Format(_SYMBOL_MISSED_, [')', i, s[i], s]));

            inc(i);
            tmpls := null;
            Result := Proc(0, s, i, n - 1, tmpls);

            i := n + 1;

            op := true;
          end;
      else
        begin
        cc:
          if op then
            raise Exception.Create(Format(_OPERATOR_MISSED_, [i,s[i],s]));

          n := CharPosEx(s, ops + [' '], ['''''', '""', '()'], i + 1);

          if (n = 0) or (n > l) then
            n := l + 1;

          Result := copy(s, i, n - i);

          tp := VarType(Result);
          if (tp = varOleStr) or (tp = varString) or (tp = varUString) then
          begin
            vt := VarToWideStr(Result);
            VRESULT := VarR8FromStr(vt, VAR_LOCALE_USER_DEFAULT, 0, vt2);
            case VRESULT of
              VAR_OK:  // in this case the OS function has put the value into result
                Result := vt2;
              VAR_TYPEMISMATCH:
                if TryStrToFloat(vt, vt2) then
                  Result := vt2
                else
                   raise Exception.Create(Format(_INCORRECT_SYMBOL_,[result,i,s]));
              else raise Exception.Create(Format(_INCORRECT_SYMBOL_,[result,i,s]));
            end;
          end else
            Result := VarAsType(Result,varDouble);

          i := n;
          op := true;
        end;
      end;

  end;

var
  i: Integer;
//  s: variant;
  st: string;
  ls: variant;
  tp: word;
begin
  tp := VarType(s);
  if not((tp = varOleStr) or (tp = varString) or (tp = varUString)) then
  begin
    result := s;
    Exit;
  end else
    st := s;

  i := 1;
  ls := null;
  Result := Proc(0, st, i, length(s), ls);
end;

function DateTimeStrEval(const DateTimeFormat: string;
  const DateTimeStr: string; locale: string): TDateTime;
var
  i, ii, iii: integer;
  Retvar: TDateTime;
  Tmp,
    Fmt, Data, Mask, Spec: string;
  Year, Month, Day, Hour,
    Minute, Second, MSec: word;
  AmPm: integer;
  fs: TFormatSettings;
begin
  fs := TFormatSettings.Create(locale);
  Year := 1;
  Month := 1;
  Day := 1;
  Hour := 0;
  Minute := 0;
  Second := 0;
  MSec := 0;
  Fmt := UpperCase(DateTimeFormat);
  Data := UpperCase(DateTimeStr);
  i := 1;
  Mask := '';
  AmPm := 0;

  if length(DateTimeStr) < length(DateTimeFormat) then
  begin
    Result := 0.0;
    Exit;
  end;

  while i < length(Fmt) do
  begin
    if CharInSet(Fmt[i],['A', 'P', 'D', 'M', 'Y', 'H', 'N', 'S', 'Z']) then
    begin
      // Start of a date specifier
      Mask := Fmt[i];
      ii := i + 1;

      // Keep going till not valid specifier
      while true do
      begin
        if ii > length(Fmt) then
          Break; // End of specifier string
        Spec := Mask + Fmt[ii];

        if (Spec = 'DD') or (Spec = 'DDD') or (Spec = 'DDDD') or
          (Spec = 'MM') or (Spec = 'MMM') or (Spec = 'MMMM') or
          (Spec = 'YY') or (Spec = 'YYY') or (Spec = 'YYYY') or
          (Spec = 'HH') or (Spec = 'NN') or (Spec = 'SS') or
          (Spec = 'ZZ') or (Spec = 'ZZZ') or
          (Spec = 'AP') or (Spec = 'AM') or (Spec = 'AMP') or
          (Spec = 'AMPM') then
        begin
          Mask := Spec;
          inc(ii);
        end
        else
        begin
          // End of or Invalid specifier
          Break;
        end;
      end;

      // Got a valid specifier ? - evaluate it from data string
      if (Mask <> '') and (length(Data) > 0) then
      begin
        // Day 1..31
        if (Mask = 'DD') then
        begin
          Day := StrToIntDef(trim(copy(Data, 1, 2)), 0);
          delete(Data, 1, 2);
        end;

        // Day Sun..Sat (Just remove from data string)
        if Mask = 'DDD' then
          delete(Data, 1, 3);

        // Day Sunday..Saturday (Just remove from data string LEN)
        if Mask = 'DDDD' then
        begin
          Tmp := copy(Data, 1, 3);
          for iii := 1 to 7 do
          begin
            if Tmp = Uppercase(copy(fs.LongDayNames[iii], 1, 3)) then
            begin
              delete(Data, 1, length(fs.LongDayNames[iii]));
              Break;
            end;
          end;
        end;

        // Month 1..12
        if (Mask = 'MM') then
        begin
          Month := StrToIntDef(trim(copy(Data, 1, 2)), 0);
          delete(Data, 1, 2);
        end;

        // Month Jan..Dec
        if Mask = 'MMM' then
        begin
          Tmp := copy(Data, 1, 3);
          for iii := 1 to 12 do
          begin
            if Tmp = Uppercase(copy(fs.LongMonthNames[iii], 1, 3)) then
            begin
              Month := iii;
              delete(Data, 1, 3);
              Break;
            end;
          end;
        end;

        // Month January..December
        if Mask = 'MMMM' then
        begin
          Tmp := copy(Data, 1, 3);
          for iii := 1 to 12 do
          begin
            if Tmp = Uppercase(copy(fs.LongMonthNames[iii], 1, 3)) then
            begin
              Month := iii;
              delete(Data, 1, length(fs.LongMonthNames[iii]));
              Break;
            end;
          end;
        end;

        // Year 2 Digit
        if Mask = 'YY' then
        begin
          Year := StrToIntDef(copy(Data, 1, 2), 0);
          delete(Data, 1, 2);
          if Year < fs.TwoDigitYearCenturyWindow then
            Year := (YearOf(Date) div 100) * 100 + Year
          else
            Year := (YearOf(Date) div 100 - 1) * 100 + Year;
        end;

        // Year 4 Digit
        if Mask = 'YYYY' then
        begin
          Year := StrToIntDef(copy(Data, 1, 4), 0);
          delete(Data, 1, 4);
        end;

        // Hours
        if Mask = 'HH' then
        begin
          Hour := StrToIntDef(trim(copy(Data, 1, 2)), 0);
          delete(Data, 1, 2);
        end;

        // Minutes
        if Mask = 'NN' then
        begin
          Minute := StrToIntDef(trim(copy(Data, 1, 2)), 0);
          delete(Data, 1, 2);
        end;

        // Seconds
        if Mask = 'SS' then
        begin
          Second := StrToIntDef(trim(copy(Data, 1, 2)), 0);
          delete(Data, 1, 2);
        end;

        // Milliseconds
        if (Mask = 'ZZ') or (Mask = 'ZZZ') then
        begin
          MSec := StrToIntDef(trim(copy(Data, 1, 3)), 0);
          delete(Data, 1, 3);
        end;

        // AmPm A or P flag
        if (Mask = 'AP') then
        begin
          if Data[1] = 'A' then
            AmPm := -1
          else
            AmPm := 1;
          delete(Data, 1, 1);
        end;

        // AmPm AM or PM flag
        if (Mask = 'AM') or (Mask = 'AMP') or (Mask = 'AMPM') then
        begin
          if copy(Data, 1, 2) = 'AM' then
            AmPm := -1
          else
            AmPm := 1;
          delete(Data, 1, 2);
        end;

        Mask := '';
        i := ii;
      end;
    end
    else
    begin
      // Remove delimiter from data string
      if length(Data) > 1 then
        delete(Data, 1, 1);
      inc(i);
    end;
  end;

  if AmPm = 1 then
    Hour := Hour + 12;
  if not TryEncodeDateTime(Year, Month, Day, Hour, Minute, Second, MSec, Retvar) then
    Retvar := 0.0;
  Result := Retvar;
end;

function strnull(s: variant): variant;
begin
  if s = '' then
    result := null
  else
    result := s;
end;

function nullstr(Value: Variant): Variant;
begin
  if value = null then
    Result := ''
  else
    Result := Value;
end;

function ifn(b: boolean; thn, els: variant): variant;
begin
  if b then
    result := thn
  else
    result:= els;
end;

function DeleteEx(S: String; Index,Count: integer): String;
begin
  Delete(S,Index,Count);
  Result := S;
end;

procedure SaveStrToFile(S, FileName: String; add: boolean);
var
  l: tstringlist;
begin
  l := tstringlist.Create;
  try
    if add and FileExists(FileName) then
      l.LoadFromFile(FileName);
    l.Add(s);
    l.SaveToFile(FileName);
  finally
    l.Free
  end;
end;

end.
