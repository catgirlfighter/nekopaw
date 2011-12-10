unit common;

interface

uses Classes, SysUtils, Math, Forms, StdCtrls, ExtCtrls, ComCtrls, Controls, HTTPApp,
  ShellAPI, Windows, Graphics, JPEG, GIFImg, PNGImage, Messages,

  hacks;

const
  MENU_MIN_HEIGHT = 158;
  LOG_MIN_HEIGHT = 100;
  TABLIST_HEIGHT = 24;

  UNIQUE_ID = 'AVILGRABERLOCK';
  MSG_FORCERESTORE  = WM_USER + 1;
  MSG_UPDATELIST     = WM_USER + 2;

  SAVEFILE_VERSION = 2;

  ZLAINS = 12;

  RESOURCE_COUNT = 28;

  RP_GELBOORU = 11;
  RP_DONMAI_DANBOORU = 5;
  RP_KONACHAN = 13;
  RP_IMOUTO = 12;
  RP_PIXIV = 19;
  RP_SAFEBOORU = 21;
  RP_SANKAKU_CHAN = 22;
  RP_BEHOIMI = 1;
  RP_EHENTAI_G = 8;
  RP_EXHENTAI = 10;
  RP_PAHEAL_RULE34 = 17;
  RP_SANKAKU_IDOL = 23;
  RP_DEVIANTART = 4;
  RP_E621 = 9;
  RP_413CHAN_PONIBOORU = 0;
  RP_BOORU_II = 2;
  RP_ZEROCHAN = 27;
  RP_PAHEAL_RULE63 = 18;
  RP_PAHEAL_COSPLAY = 16;
  RP_XBOORU = 26;
  RP_WILDCRITTERS = 25;
  RP_BOORU_RULE34 = 3;
  RP_RMART = 20;
  RP_DONMAI_HIJIRIBE = 6;
  RP_DONMAI_SONOHARA = 7;
  RP_NEKOBOORU = 15;
  RP_THEDOUJIN = 24;
  RP_MINITOKYO = 14;

  RS_POOLS = [RP_BEHOIMI, RP_SANKAKU_CHAN, RP_IMOUTO, RP_DONMAI_DANBOORU,
  RP_SANKAKU_IDOL, RP_E621, RP_KONACHAN, RP_WILDCRITTERS, RP_DONMAI_HIJIRIBE,
  RP_DONMAI_SONOHARA, RP_NEKOBOORU];

  RS_GALLISTS = [RP_EHENTAI_G,RP_EXHENTAI,RP_THEDOUJIN,RP_MINITOKYO];

  //http://rmart.org/
  //http://macrochan.org/
  //http://www.animepaper.net/

  RESOURCE_URLS: array[0..RESOURCE_COUNT-1] of string =
              {00}('http://ponibooru.413chan.net/',
              {01} 'http://behoimi.org/',
              {02} 'http://ii.booru.org/',
              {03} 'http://rule34.booru.org/',
              {04} 'http://deviantart.com/',
              {05} 'http://danbooru.donmai.us/',
              {06} 'http://hijiribe.donmai.us/',
              {07} 'http://sonohara.donmai.us/',
              {08} 'http://g.e-hentai.org/',
              {09} 'http://e621.net/',
              {10} 'http://exhentai.org/',
              {11} 'http://gelbooru.com/',
              {12} 'http://oreno.imouto.org/',
              {13} 'http://konachan.com/',
              {14} 'http://www.minitokyo.net/',
              {15} 'http://nekobooru.net/',
              {16} 'http://cosplay.paheal.net/',
              {17} 'http://rule34.paheal.net/',
              {18} 'http://rule63.paheal.net/',
              {19} 'http://pixiv.net/',
              {20} 'http://rmart.org/',
              {21} 'http://safebooru.org/',
              {22} 'http://chan.sankakucomplex.com/',
              {23} 'http://idol.sankakucomplex.com/',
              {24} 'http://thedoujin.com/',
              {25} 'http://wildcritters.ws/',
              {26} 'http://xbooru.com/',
              {27} 'http://www.zerochan.net/');


  RVLIST: array [0 .. RESOURCE_COUNT - 1] of Integer =
    (RP_GELBOORU, RP_DONMAI_DANBOORU, RP_KONACHAN, RP_IMOUTO, RP_PIXIV,
    RP_SAFEBOORU, RP_SANKAKU_CHAN, RP_BEHOIMI, RP_EHENTAI_G, RP_EXHENTAI,
    RP_PAHEAL_RULE34, RP_SANKAKU_IDOL, RP_DEVIANTART, RP_E621,
    RP_413CHAN_PONIBOORU, RP_BOORU_II, RP_ZEROCHAN, RP_PAHEAL_RULE63,
    RP_PAHEAL_COSPLAY, RP_XBOORU, RP_WILDCRITTERS, RP_BOORU_RULE34, RP_RMART,
    RP_DONMAI_HIJIRIBE, RP_DONMAI_SONOHARA, RP_NEKOBOORU, RP_THEDOUJIN,
    RP_MINITOKYO);

  REV_RVLIST: array [0 .. RESOURCE_COUNT - 1] of Integer = (14, 7, 15, 21, 12, 1, 23, 24,
    8, 13, 9, 0, 3, 2, 27, 25, 18, 10, 17, 4, 22, 5, 6, 11, 26, 20, 19, 16);

type
  TArrayOfWord = array of word;
  TArrayOfString = array of string;

function Replace(src, s1, s2: string; rpslashes: boolean = false;  rpall: boolean = false): string;
function emptyname(s: string): string;
function deleteids(s: string;slsh: boolean = false): string;
function addstr(s1,s2: string): string;
function numstr(n: word; s1, s2, s3: string; engstyle: boolean = false): string;
function CreateDirExt(Dir: string): Boolean;
function ClearHTML(s: string): string;
function RadioGroupDlg(ACaption,AHint: String; AItems: array of String): Integer;
function DeleteTo(s: String; subs: string; casesens: boolean = true; re: boolean = false): string;
function DeleteFromTo(S, sub1, sub2: String; casesens: boolean = true): String;
function GetBtString(n: Extended): string;
function GetBtStringEx(n: Extended): string;
function diff(n1, n2: extended): extended;
function batchreplace(src: string; substr1: array of string; substr2: string): string;
function STRINGENCODE(S: STRING): STRING;
function STRINGDECODE(S: STRING): STRING;
function extracttags(S: TStrings): String;
function getnexts(var s: string; del: char= ';'; ins: char = #0): string;
procedure ImportTags(src: String; Dst: TStrings); overload;
function Trim(S: String; ch: char = ' '): String;
function StringToArrayOfWord(S: String): TArrayOfWord;
procedure AddSrtdd(var l: TArrayOfWord; s: Word);
function CopyTo(s, substr: string): string;
function CopyFromTo(S, sub1, sub2: String; re: boolean = false): String;
function ExtractFolder(s: string): string;
function MoveDir(const fromDir, toDir: string): Boolean;
procedure MultWordArrays(var a1: TArrayOfWord; a2: TArrayOfWord);
procedure _Delay(dwMilliseconds: Longint);
function ValidFName(FName: String; bckslsh: boolean = false): String;
function MemoDlg(ACaption,AHint,DefaultValue: String; OnPaste: TPreventNotifyEvent = nil): String;
function MultiInputDlg(ACaption: String; Captions, Values: array of string; Pwd: array of boolean): TArrayOfString;
function strlisttostr(s: tstringlist; del: char = ';'; ins: char = '"'): string;
function strtostrlist(s: string; del: char = ';'; ins: char = '"'): string;
function ArrayOfWordToString(S: TArrayOfWord): String;
procedure DrawImage(AImage: TImage; AStream: TStream; Ext: String);
procedure DrawImageFromRes(AImage: TImage; ResName, Ext: String);
procedure WriteLWToPChar(n: LongWord; p: PChar);
function ReadLWFromPChar(p: PChar): LongWord;
function PngToIcon(const Png: TPngImage; Background: TColor = clNone): HICON;
function ImageFormat(Start: Pointer): string;
function GetWinVersion: string;
procedure ShutDown;
function AddZeros(s: string; count: integer): string;

implementation

function clearhtml(s: string): string;    //Заебись

type
  tmnemonica = packed record
    m: string;
    a: word;
  end;

const
//http://ru.wikipedia.org/wiki/%D0%9C%D0%BD%D0%B5%D0%BC%D0%BE%D0%BD%D0%B8%D0%BA%D0%B8_%D0%B2_HTML
//2011-09-27

a: array[1..252] of tmnemonica = (
(m:'AElig';a:198),(m:'Aacute';a:193 ),(m:'Acirc'  ;a:194),(m:'Agrave';a:192),(m:'Alpha' ;a:913),
(m:'Aring';a:197),(m:'Atilde';a:195 ),(m:'Auml'   ;a:196),(m:'Beta'  ;a:914),(m:'Ccedil';a:199),
(m:'Chi'  ;a:935),(m:'Dagger';a:8225),(m:'Delta'  ;a:916),(m:'ETH'   ;a:208),(m:'Eacute';a:201),
(m:'Ecirc';a:202),(m:'Egrave';a:200 ),(m:'Epsilon';a:917),(m:'Eta'   ;a:919),(m:'Euml'  ;a:203),
(m:'Gamma';a:915),(m:'Iacute';a:205 ),(m:'Icirc'  ;a:206),(m:'Igrave';a:204),(m:'Iota'  ;a:921),
//25
(m:'Iuml'  ;a:207),(m:'Kappa'  ;a:922),(m:'Lambda';a:923 ),(m:'Mu'    ;a:924),(m:'Ntilde';a:209),
(m:'Nu'    ;a:925),(m:'OElig'  ;a:338),(m:'Oacute';a:211 ),(m:'Ocirc' ;a:212),(m:'Ograve';a:210),
(m:'Omega' ;a:937),(m:'Omicron';a:927),(m:'Oslash';a:216 ),(m:'Otilde';a:213),(m:'Ouml'  ;a:214),
(m:'Phi'   ;a:934),(m:'Pi'     ;a:928),(m:'Prime' ;a:8243),(m:'Psi'   ;a:936),(m:'Rho'   ;a:929),
(m:'Scaron';a:352),(m:'Sigma'  ;a:931),(m:'THORN' ;a:222 ),(m:'Tau'   ;a:932),(m:'Theta' ;a:920),
//50
(m:'Uacute';a:218 ),(m:'Ucirc' ;a:219),(m:'Ugrave';a:217 ),(m:'Upsilon';a:933 ),(m:'Uuml'   ;a:220 ),
(m:'Xi'    ;a:926 ),(m:'Yacute';a:221),(m:'Yuml'  ;a:376 ),(m:'Zeta'   ;a:918 ),(m:'aacute' ;a:225 ),
(m:'acirc' ;a:226 ),(m:'acute' ;a:180),(m:'aelig' ;a:230 ),(m:'agrave' ;a:224 ),(m:'alefsym';a:8501),
(m:'alpha' ;a:945 ),(m:'amp'   ;a:38 ),(m:'and'   ;a:8743),(m:'ang'    ;a:8736),(m:'aring'  ;a:229 ),
(m:'asymp' ;a:8776),(m:'atilde';a:227),(m:'auml'  ;a:228 ),(m:'bdquo'  ;a:8222),(m:'beta'   ;a:946 ),
//75
(m:'brvbar';a:166 ),(m:'bull'  ;a:8226),(m:'cap'  ;a:8745),(m:'ccedil';a:231 ),(m:'cedil';a:184 ),
(m:'cent'  ;a:162 ),(m:'chi'   ;a:967 ),(m:'circ' ;a:710 ),(m:'clubs' ;a:9827),(m:'cong' ;a:8773),
(m:'copy'  ;a:169 ),(m:'crarr' ;a:8629),(m:'cup'  ;a:8746),(m:'curren';a:164 ),(m:'dArr' ;a:8659),
(m:'dagger';a:8224),(m:'darr'  ;a:8595),(m:'deg'  ;a:176 ),(m:'delta' ;a:948 ),(m:'diams';a:9830),
(m:'divide';a:247 ),(m:'eacute';a:233 ),(m:'ecirc';a:234 ),(m:'egrave';a:232 ),(m:'empty';a:8709),
//100
(m:'emsp'  ;a:8195),(m:'ensp'  ;a:8194),(m:'epsilon';a:949 ),(m:'equiv' ;a:8801),(m:'eta'  ;a:951 ),
(m:'eth'   ;a:240 ),(m:'euml'  ;a:235 ),(m:'euro'   ;a:8364),(m:'exist' ;a:8707),(m:'fnof' ;a:402 ),
(m:'forall';a:8704),(m:'frac12';a:189 ),(m:'frac14' ;a:188 ),(m:'frac34';a:190 ),(m:'frasl';a:8260),
(m:'gamma' ;a:947 ),(m:'ge'    ;a:8805),(m:'gt'     ;a:62  ),(m:'hArr'  ;a:8660),(m:'harr' ;a:8596),
(m:'hearts';a:9829),(m:'hellip';a:8230),(m:'iacute' ;a:237 ),(m:'icirc' ;a:238 ),(m:'iexcl';a:161 ),
//125
(m:'igrave';a:236 ),(m:'image' ;a:8465),(m:'infin' ;a:8734),(m:'int'   ;a:8747),(m:'iota' ;a:953 ),
(m:'iquest';a:191 ),(m:'isin'  ;a:8712),(m:'iuml'  ;a:239 ),(m:'kappa' ;a:954 ),(m:'lArr' ;a:8656),
(m:'lambda';a:955 ),(m:'lang'  ;a:9001),(m:'laquo' ;a:171 ),(m:'larr'  ;a:8592),(m:'lceil';a:8968),
(m:'ldquo' ;a:8220),(m:'le'    ;a:8804),(m:'lfloor';a:8970),(m:'lowast';a:8727),(m:'loz'  ;a:9674),
(m:'lrm'   ;a:8206),(m:'lsaquo';a:8249),(m:'lsquo' ;a:8216),(m:'lt'    ;a:60  ),(m:'macr' ;a:175 ),
//150
(m:'mdash' ;a:8212),(m:'micro'  ;a:181 ),(m:'middot';a:183 ),(m:'minus' ;a:8722),(m:'mu'   ;a:956 ),
(m:'nabla' ;a:8711),(m:'nbsp'   ;a:160 ),(m:'ndash' ;a:8211),(m:'ne'    ;a:8800),(m:'ni'   ;a:8715),
(m:'not'   ;a:172 ),(m:'notin'  ;a:8713),(m:'nsub'  ;a:8836),(m:'ntilde';a:241 ),(m:'nu'   ;a:957 ),
(m:'oacute';a:243 ),(m:'ocirc'  ;a:244 ),(m:'oelig' ;a:339 ),(m:'ograve';a:242 ),(m:'oline';a:8254),
(m:'omega' ;a:969 ),(m:'omicron';a:959 ),(m:'oplus' ;a:8853),(m:'or'    ;a:8744),(m:'ordf' ;a:170 ),
//175
(m:'ordm' ;a:186 ),(m:'oslash';a:248 ),(m:'otilde';a:245 ),(m:'otimes';a:8855),(m:'ouml' ;a:246 ),
(m:'para' ;a:182 ),(m:'part'  ;a:8706),(m:'permil';a:8240),(m:'perp'  ;a:8869),(m:'phi'  ;a:966 ),
(m:'pi'   ;a:960 ),(m:'piv'   ;a:982 ),(m:'plusmn';a:177 ),(m:'pound' ;a:163 ),(m:'prime';a:8242),
(m:'prod' ;a:8719),(m:'prop'  ;a:8733),(m:'psi'   ;a:968 ),(m:'quot'  ;a:34  ),(m:'rArr' ;a:8658),
(m:'radic';a:8730),(m:'rang'  ;a:9002),(m:'raquo' ;a:187 ),(m:'rarr'  ;a:8594),(m:'rceil';a:8969),
//200
(m:'rdquo';a:8221),(m:'real'  ;a:8476),(m:'reg'  ;a:174 ),(m:'rfloor';a:8971),(m:'rho'   ;a:961 ),
(m:'rlm'  ;a:8207),(m:'rsaquo';a:8250),(m:'rsquo';a:8217),(m:'sbquo' ;a:8218),(m:'scaron';a:353 ),
(m:'sdot' ;a:8901),(m:'sect'  ;a:167 ),(m:'shy'  ;a:173 ),(m:'sigma' ;a:963 ),(m:'sigmaf';a:962 ),
(m:'sim'  ;a:8764),(m:'spades';a:9824),(m:'sub'  ;a:8834),(m:'sube'  ;a:8838),(m:'sum'   ;a:8721),
(m:'sup'  ;a:8835),(m:'sup1'  ;a:185 ),(m:'sup2' ;a:178 ),(m:'sup3'  ;a:179 ),(m:'supe'  ;a:8839),
//225
(m:'szlig' ;a:223 ),(m:'tau'   ;a:964),(m:'there4' ;a:8756),(m:'theta';a:952),(m:'thetasy';a:977 ),
(m:'thinsp';a:8201),(m:'thorn' ;a:254),(m:'tilde'  ;a:732 ),(m:'times';a:215),(m:'trade'  ;a:8482),
(m:'uArr'  ;a:8657),(m:'uacute';a:250),(m:'uarr'   ;a:8593),(m:'ucirc';a:251),(m:'ugrave' ;a:249 ),
(m:'uml'   ;a:168 ),(m:'upsih' ;a:978),(m:'upsilon';a:965 ),(m:'uuml' ;a:252),(m:'weierp' ;a:8472),
(m:'xi'    ;a:958 ),(m:'yacute';a:253),(m:'yen'    ;a:165 ),(m:'yuml' ;a:255),(m:'zeta'   ;a:950 ),
//250
(m:'zwj';a:8205),(m:'zwnj';a:8204)
//252
);

C_SEP = ';';
C_SPC = '&';
C_NUM = '#';
N_MLN =  7 ;
N_MNC = 252;
var
  i,l,t,spc,sep: integer;

function ChMnem(var s: string; const b,e: integer): boolean;
var
  i: integer;
  c: string;
begin
  Result := false;
  c := copy(s,b+1,e-b-1);
  i := 1;
  while i <= N_MNC do
  begin
    if a[i].m = c then
    begin
      s[b] := Char(a[i].a);
      Delete(s,b+1,e-b);
      Result := true;
    end else if a[i].m > c then
      break;
    inc(i);
  end;
end;

function ChNum(var s: string; const b,e: integer): boolean;
begin
  s[b] := Char(StrToInt(Copy(s,b+2,e-b-2)));
  Delete(s,b+1,e-b);
  Result := True;
end;

begin

  l := length(s);
  t := -1;
  i := 1;

  while i <= l do
  begin
    case t of
      -1:
        case s[i] of
          C_SPC:
            begin
              spc := i;
              t := 0;
            end;
        end;
      0..2:
        case s[i] of
          C_SPC:
            begin
              spc := i;
              t := 0;
            end;
          'A'..'F','a'..'f':
            case t of
              0: t := 1;
              1,2: ;
              else t := -1;
            end;
          'G'..'W','Y','Z','g'..'w','y','z':
            case t of
              0: t := 1;
              1: ;
              else t := -1;
            end;
          C_NUM:
            case t of
              0: t := 2;
              else t := -1;
            end;
          'X','x':
            case t of
              0: t := 1;
              1: ;
              2: if i-spc <> 3 then t := -1;
              else t := -1;
            end;
          '0'..'9':
            case t of
              2: ;
              else t := -1;
            end;
          C_SEP:
          begin
            case t of
              1: if (i - spc <= N_MLN) and ChMnem(s,spc,i) then dec(i,i-spc);
              2: if ChNum(s,spc,i) then dec(i,i-spc);
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
  p: integer;
begin
  p := length(s);
  while (p > 0) and not CharInSet(s[p],['/','=']) do
    dec(p);
  delete(s,1,p);
  result := s;
end;

function Replace(src, s1, s2: string; rpslashes: boolean = false; rpall: boolean = false): string;
var
  n: integer;
begin
  result := '';
  n := pos(s1,src);

  while n > 0 do
  begin
    if (copy(src,n,length(s2))=s2) and rpall and rpslashes then
      result := result + copy(src,1,n-1)
    else
      result := result + copy(src,1,n-1)+s2;
    delete(src,1,n+length(s1)-1);
    if rpall then
      n := pos(s1,src)
    else
    begin
      if rpslashes then
      begin
        n := pos('/',src);
        while n > 0 do
        begin
          delete(src,1,n);
          n := pos('/',src);
        end;
      end;
      n := 0;
    end;
  end;
  result := result + src;
end;

function deleteids(s: string; slsh: boolean): string;
var
  p: integer;
begin
  if not slsh then
  begin
    p := pos('?',s);
    delete(s,p,length(s)-p+1);
    result := s;
  end else
  begin
    p := length(s);
    while(p>0)and(s[p]<>'/')do
      dec(p);
    if p = 0 then
      result := s
    else
      result := Copy(s,1,p-1) + ExtractFileExt(s);
  end;
end;

function addstr(s1,s2: string): string;
var
  p: integer;
begin
  result := '';
  p := pos('/',s1);
  if p > 0 then
  begin
    if (length(s1)>p) and (s1[p+1]='/') then
    begin
      result := copy(s1,1,p+1);
      delete(s1,1,p+1);
    end;
    p := pos('/',s1);
    if p = 0 then
    begin
      s1 := s1+'/';
      p := length(s1);
    end;
    insert(s2,s1,p+1);
  end;
  result := result + s1;
end;

function numstr(n: word; s1, s2, s3: string; engstyle: boolean = false): string;
begin
  if engstyle then
    if (n > 1) or (n = 0) then
      result := 's'
    else
      result := ''
  else
    if ((n mod 100) div 10 = 1) then
      result := s3
    else
      case n mod 10 of
        1: result := s1;
        2..4: result := s2;
        5..9,0: result := s3;
      end;

end;

function CreateDirExt(Dir: string): Boolean;
var
  I, L: Integer;
  CurDir: string;
begin
  Result := DirectoryExists(Dir);
  if Result then
    Exit;
  if ExcludeTrailingPathDelimiter(Dir) = '' then
    exit;
  Dir := IncludeTrailingPathDelimiter(Dir);
  L := Length(Dir);
  for I := 1 to L do
  begin
    CurDir := CurDir + Dir[I];
    if Dir[I] = '\' then
    begin
      if not DirectoryExists(CurDir) then
        if not CreateDir(CurDir) then
          Exit;
    end;
  end;
  Result := True;
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

  result := FloatToStr(RoundTo(n,-2));

  case l of
    0: result := result + 'b';
    1: result := result + 'Kb';
    2: result := result + 'Mb';
    3: result := result + 'Gb';
    4: result := result + 'Tb';
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

  result := FloatToStr(RoundTo(n,-2));

  case l of
    0: result := 'b';
    1: result := 'Kb';
    2: result := 'Mb';
    3: result := 'Gb';
    4: result := 'Tb';
  end;

end;

function batchreplace(src: string; substr1: array of string;
  substr2: string): string;
var
  i: integer;
begin
  for i := 0 to length(substr1) - 1 do
    src := replace(src,substr1[i],substr2);
  result := src;
end;

function RadioGroupDlg(ACaption,AHint: String; AItems: array of String): Integer;
var
  F: TForm;
  L: TLabel;
  R: TRadioGroup;
  OkBtn,CancelBtn: TButton;
  i,n: integer;
begin

  Result := -1;

  if length(AItems) = 0 then
    Exit;
  F := TForm.Create(Application);
  F.Caption := ACaption;
  F.BorderStyle := bsDialog;
  F.Position := poMainFormCenter;
  L := TLabel.Create(F);
  L.Parent := F;
  if AHint = '' then
    L.Caption := 'Select value:'
  else
    L.Caption := AHint;
  L.Left := 4;
  L.Top := 4;
  R := TRadioGroup.Create(F);
  R.Parent := F;
  R.Top := L.Top + L.Height + 4;
  R.Left := 4;
  n := -1;
  for i := 0 to length(AItems)-1 do
  begin
    R.Items.Add(AItems[i]);
    if F.Canvas.TextWidth(AItems[i]) > n then
      n := F.Canvas.TextWidth(AItems[i]);
  end;
  R.ItemIndex := 0;
  R.Width := Max(n + 8 + 24,200);
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
    mrOk: Result := R.ItemIndex;
    else Result := -1;
  end;
  OkBtn.Free;
  CancelBtn.Free;
  L.Free;
  R.Free;
  F.Free;
end;

function MemoDlg(ACaption,AHint,DefaultValue: String;
  OnPaste: TPreventNotifyEvent = nil): String;
var
  F: TForm;
  L: TLabel;
  M: TMemo;
  OkBtn,CancelBtn: TButton;
begin

  Result := DefaultValue;

  F := TForm.Create(Application);
  F.Caption := ACaption;
  F.BorderStyle := bsDialog;
  F.Position := poMainFormCenter;
  L := TLabel.Create(F);
  L.Parent := F;
  if AHint = '' then
    L.Caption := 'Input text:'
  else
    L.Caption := AHint;
  L.Left := 4;
  L.Top := 4;
  M := TMemo.Create(F);
  M.Parent := F;
  M.Top := L.Top + L.Height + 4;
  M.Left := 4;

{  n := -1;
  for i := 0 to length(AItems)-1 do
  begin
    R.Items.Add(AItems[i]);
    if F.Canvas.TextWidth(AItems[i]) > n then
      n := F.Canvas.TextWidth(AItems[i]);
  end;  }
//  M.ItemIndex := 0;
  M.Width := {Max(n + 8 + 24,200)} 200;
  M.Height := {R.Items.Count * 20 + 12} 200;
  M.ScrollBars := ssBoth;
  M.OnPaste := OnPaste;
  M.Text := Result;
  F.ClientWidth := M.Left + M.Width + 4;


  OkBtn := TButton.Create(F);
  OkBtn.Parent := F;
  OkBtn.Caption := 'Ok';
  OkBtn.ModalResult := mrOk;
  OkBtn.Default := true;
  OkBtn.Left := 4;
  OkBtn.Top := M.Top + M.Height + 4;

  CancelBtn := TButton.Create(F);
  CancelBtn.Parent := F;
  CancelBtn.Caption := 'Cancel';
  CancelBtn.ModalResult := mrCancel;
  CancelBtn.Cancel := true;
  CancelBtn.Left := F.ClientWidth - CancelBtn.Width - 4;
  CancelBtn.Top := OkBtn.Top;

  F.ClientHeight := OkBtn.Top + OkBtn.Height + 4;
  F.ShowModal;
  case F.ModalResult of
    mrOk: Result := M.Text;
  end;
  OkBtn.Free;
  CancelBtn.Free;
  L.Free;
  M.Free;
  F.Free;
end;

function MultiInputDlg(ACaption: String; Captions, Values: array of string; PWD: array of boolean): TArrayOfString;
var
  F: TForm;
  L: array of TLabel;
  E: array of TEdit;
  OkBtn,CancelBtn: TButton;
  maxlwidth: integer;
  i: integer;
begin

  Result := nil;

  if length(Values) = 0 then
    Exit;

  F := TForm.Create(Application);
  F.Caption := ACaption;
  F.BorderStyle := bsDialog;
  F.Position := poMainFormCenter;

  maxlwidth := 0;

  SetLength(L,length(Values));
  SetLength(E,length(Values));

  for i := 0 to length(Captions) -1 do
  begin
    L[i] := TLabel.Create(F);
    L[i].Parent := F;
    L[i].Left := 4;
    L[i].Top := 8*(i+1) + 19*i;
    L[i].Caption := Captions[i];
    if L[i].Width > maxlwidth then
      maxlwidth := L[i].Width;
  end;

  for i := 0 to length(Values) -1 do
  begin
    E[i] := TEdit.Create(F);
    E[i].Parent := F;
    E[i].Top := 4*(i+1) + 23*i;
    E[i].Left := maxlwidth + 8;
    E[i].Text := Values[i];
  end;

  for i := 0 to length(PWD) -1 do
    if PWD[i] then
      E[i].PasswordChar := '*';

  F.ClientWidth := E[0].Left + E[0].Width + 4;

  OkBtn := TButton.Create(F);
  OkBtn.Parent := F;
  OkBtn.Caption := 'Ok';
  OkBtn.ModalResult := mrOk;
  OkBtn.Default := true;
  OkBtn.Left := 4;
  OkBtn.Top := E[length(Values)-1].Top + E[length(Values)-1].Height + 4;

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
    begin
     SetLength(Result,length(Values));
     for i:= 0 to length(Values) -1 do
      Result [i] := E[i].Text;
    end;
  end;

  OkBtn.Free;
  CancelBtn.Free;

  for i:= 0 to length(Values) -1 do
  begin
    FreeAndNil(L[i]);
    FreeAndNil(E[i]);
  end;

  L := nil;
  E := nil;
  FreeAndNil(F);
end;

function DeleteTo(s: String; subs: string; casesens: boolean = true; re: boolean = false): string;
var
  p: integer;
begin
  result := s;

  if casesens  then
  begin
    p := pos(subs,s);
    if p > 0 then
      delete(s,1,p+length(subs)-1);
  end else
  begin
    p := pos(UPPERCASE(subs),UPPERCASE(s));
    if p > 0 then
      delete(s,1,p+length(subs)-1);
  end;
  if re and (result = s) then
    result := ''
  else
    result := s;
end;

function diff(n1, n2: extended): extended;
begin
  if n2 = 0 then
    result := 0
  else
    result := n1/n2;
end;

function STRINGENCODE(S: STRING): STRING;
begin
  RESULT := HTTPENCODE(UTF8ENCODE(S));
end;

function STRINGDECODE(S: STRING): STRING;
begin
  RESULT := UTF8ToString(HTTPDECODE(S));
end;

function extracttags(S: TStrings): String;
var
  i,l: integer;
begin
  Result := '';
  l := S.Count - 1;
  for i := 0 to l do
    Result := Result + '"' + StringEncode(S[i]) + '" ';
end;

function getnexts(var s: string; del: char = ';'; ins: char = #0): string;
var
  n: integer;
begin
  Result := '';

  if ins <> #0 then
  while True do
  begin
    n := pos(ins,s);
    if (n > 0) and (pos(del,s) > n) then
    begin
      result := result + copy(s,1,n-1);
      delete (s,1,n);
      n := pos(ins,s);
      case n of
        0: raise Exception.Create('Can''t find 2nd insulator '''+ins+''':'+#13#10+S);
        1: result := result + copy(s,1,n);
        else result := result + copy(s,1,n-1);
      end;
      delete (s,1,n);
    end else
      break;
  end;


  n := pos(del,s);
  if n > 0 then
  begin
    result := result + copy(s,1,n-1);
    delete(s,1,n);
  end else
  begin
    result := result + s;
    s := '';
  end;
end;

procedure ImportTags(src: String; Dst: TStrings);
var
  S: string;
begin
  Dst.Clear;
  while SRC <> '' do
  begin
    S := StringDecode(trim(GetNextS(src,' ','"'),'"'));
    Dst.Add(S);
  end;
end;

function Trim(S: String; ch: char = ' '): String;
var
  I, L: Integer;
begin
  L := Length(S);
  I := 1;
  while (I <= L) and (S[I] = ch) do Inc(I);
  if I > L then Result := '' else
  begin
    while S[L] = ch do Dec(L);
    Result := Copy(S, I, L - I + 1);
  end;
end;

function StringToArrayOfWord(S: String): TArrayOfWord;
begin
  Result := nil;
  while s <> '' do
  begin
    SetLength(result,length(result)+1);
    result[length(result)-1] := StrToInt(GetNextS(S,' '));
    //result := result + [StrToInt(GetNextS(S,' '))];
  end;
end;


procedure AddSrtdd(var l: TArrayOfWord; s: Word);
var
  i,j: integer;
begin
  for i  := 0 to length(l)-1 do
      if l[i] > s then
      begin
      SetLength(l,length(l)+1);
      for j := length(l)-1 downto i+1 do
        l[j] := l[j-1];
      l[i] := s;
      Exit;
    end;
  SetLength(l,length(l)+1);
  l[length(l)-1] := s;
end;

function CopyTo(s, substr: string): string;
var
  i: integer;
begin
  i := pos(substr,S);
  if i = 0 then
    result := copy(s,1,length(s))
  else
    result := copy(s,1,i-1);
end;

function ArrayOfWordToString(S: TArrayOfWord): String;
var
  i: integer;
begin
  Result := '';
  for i := 0 to length(S)-1 do
      Result := Result + IntToStr(s[i]) + ' ';
end;

function CopyFromTo(S, sub1, sub2: String; re: boolean = false): String;
var
  l1,l2: integer;
  tmp: string;
begin
  tmp := s;
  result := '';

  l1 := pos(LOWERCASE(sub1),LOWERCASE(tmp));
  if l1 > 0 then
    delete(tmp,1,l1+length(sub1)-1)
  else if re then
    Exit;

  l2 := pos(LOWERCASE(sub2),LOWERCASE(tmp));
  if l2 = 0 then
    if re then
      Exit
    else
      l2 := length(s) + 1
  else
    l2 := l2 + length(s) - length(tmp);

  if l1 > 0 then
    result := Copy(s,l1 + length(sub1),l2 - l1 - length(sub1))
  else
    result := Copy(s,1,l2 - 1);
end;

function DeleteFromTo(S, sub1, sub2: String; casesens: boolean = true): String;
var
  l1,l2: integer;
  tmp: string;
begin
  tmp := s;
  l1 := pos(LOWERCASE(sub1),LOWERCASE(tmp));
  if l1 > 0 then
    delete(tmp,1,l1+length(sub1)-1);

  l2 := pos(LOWERCASE(sub2),LOWERCASE(tmp));
  if l2 > 0 then
    l2 := l2 + length(s) - length(tmp);

  if (l1>0)and(l2>0) then
    Delete(s,l1,l2 - l1 + length(sub2));

  result := S;
end;

function ExtractFolder(s: string): string;
var
  p1,p2: integer;
begin
  p1 := length(s);
  while (p1 > 0) and not(CharInSet(s[p1],['/','\'])) do
    dec(p1);
  p2 := p1 - 1;
  while (p2 > 0) and not(CharInSet(s[p2],['/','\'])) do
    dec(p2);
  result := copy(s,p2+1,p1-p2-1);
end;

function MoveDir(const fromDir, toDir: string): Boolean;
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc  := FO_MOVE;
    fFlags := FOF_FILESONLY;
    pFrom  := PChar(fromDir + #0);
    pTo    := PChar(toDir)
  end;
  Result := (0 = ShFileOperation(fos));
end;


procedure MultWordArrays(var a1: TArrayOfWord; a2: TArrayOfWord);
var
  i,la1,la2: integer;
begin
  la1 := length(a1);
  la2 := length(a2);
  SetLength(a1,la1+la2);

  for i := 0 to la2-1 do
    a1[la1+i] := a2[i];
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
  n = ['\','/',':','*','"','<','>','|','?'];
var
  i: integer;
begin
  for i := 1 to length(FName) do
    if CharInSet(FName[i],n) and (not bckslsh or (FName[i] <> '\')) then
      FName[i] := '_';
  Result := FName;
end;

function strlisttostr(s: tstringlist; del, ins: char): string;
var
  i,j: integer;
  s1,s2: string;
begin
  result := '';
  for i := 0 to s.Count - 1 do
  begin
    s2 := '';
    s1 := s[i];
    j := pos(ins,s1);
    while j > 0 do
    begin
      s2 := s2 + copy(s1,1,j)+ins;
      delete(s1,1,j);
      j := pos(ins,s1);
    end;
    s2 := s2 + s1;

    if (ins <> #0) and (pos(del,s2) > 0) then
      s2 := ins + s2 + ins;
    if i < s.Count-1 then
      result := result + s2 + del
    else
      result := result + s2;
  end;
end;

function strtostrlist(s: string; del, ins: char): string;
var
  ss: string;
begin
  result := '';
  while s <> '' do
  begin
    ss := GetNextS(s,del,ins);
    if s = '' then
      result := result + ss
    else
      result := result + ss + #13#10;
  end;
end;

procedure DrawImage(AImage: TImage; AStream: TStream; Ext: String);
var
  Graphic: TGraphic;
begin
  Ext := lowercase(Ext);
  delete(Ext, 1, 1);
  Graphic := nil;
  if (Ext = 'jpeg') or (Ext = 'jpg') then
    Graphic := TJPEGIMAGE.Create;
  if (Ext = 'png') then
    Graphic := TPNGIMAGE.Create;
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
  (p+0)^ := Char(n mod 256);
  (p+1)^ := Char(n div 256 mod 256);
  (p+2)^ := Char(n div 256 div 256 mod 256);
  (p+3)^ := Char(n div 256 div 256 div 256 mod 256);
end;

function ReadLWFromPChar(p: PChar): LongWord;
begin
  result := Ord((p+0)^)
            + Ord((p+1)^) * 256
            + Ord((p+2)^) * 256 * 256
            + Ord((p+3)^) * 256 * 256 * 256;
end;

function PngToIcon(const Png: TPngImage; Background: TColor): HICON;
const
  MaxRGBQuads = MaxInt div SizeOf(TRGBQuad) - 1;
type
  TRGBQuadArray = array[0..MaxRGBQuads] of TRGBQuad;
  PRGBQuadArray = ^TRGBQuadArray;
  TBitmapInfo4 = packed record
    bmiHeader: TBitmapV4Header;
    bmiColors: array[0..0] of TRGBQuad;
  end;

  function PngToIcon32(Png: TPngImage): HIcon;
  var
    ImageBits: PRGBQuadArray;
    BitmapInfo: TBitmapInfo4;
    IconInfo: TIconInfo;
    AlphaBitmap: HBitmap;
    MaskBitmap: TBitmap;
    X, Y: Integer;
    AlphaLine: PByteArray;
    HasAlpha, HasBitmask: Boolean;
    Color, TransparencyColor: TColor;
  begin
    //Convert a PNG object to an alpha-blended icon resource
    ImageBits := nil;

    //Allocate a DIB for the color data and alpha channel
    with BitmapInfo.bmiHeader do begin
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
      //Spin through and fill it with a wash of color and alpha.
      AlphaLine := nil;
      HasAlpha := Png.Header.ColorType in [COLOR_GRAYSCALEALPHA,
        COLOR_RGBALPHA];
      HasBitmask := Png.TransparencyMode = ptmBit;
      TransparencyColor := Png.TransparentColor;
      for Y := 0 to Png.Height - 1 do begin
        if HasAlpha then
          AlphaLine := Png.AlphaScanline[Png.Height - Y - 1];
        for X := 0 to Png.Width - 1 do begin
          Color := Png.Pixels[X, Png.Height - Y - 1];
          ImageBits^[Y * Png.Width + X].rgbRed := Color and $FF;
          ImageBits^[Y * Png.Width + X].rgbGreen := Color shr 8 and $FF;
          ImageBits^[Y * Png.Width + X].rgbBlue := Color shr 16 and $FF;
          if HasAlpha then
            ImageBits^[Y * Png.Width + X].rgbReserved := AlphaLine^[X]
          else if HasBitmask then
            ImageBits^[Y * Png.Width + X].rgbReserved := Integer(Color <>
              TransparencyColor) * 255;
        end;
      end;

      //Create an empty mask
      MaskBitmap := TBitmap.Create;
      try
        MaskBitmap.Width := Png.Width;
        MaskBitmap.Height := Png.Height;
        MaskBitmap.PixelFormat := pf1bit;
        MaskBitmap.Canvas.Brush.Color := clBlack;
        MaskBitmap.Canvas.FillRect(Rect(0, 0, MaskBitmap.Width,
          MaskBitmap.Height));

        //Create the alpha blended icon
        IconInfo.fIcon := True;
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

  function PngToIcon24(Png: TPngImage; Background: TColor): HIcon;
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

      //Draw the color bitmap
      ColorBitmap.Canvas.Brush.Color := Background;
      ColorBitmap.Canvas.FillRect(Rect(0, 0, Png.Width, Png.Height));
      Png.Draw(ColorBitmap.Canvas, Rect(0, 0, Png.Width, Png.Height));

      //Create the mask bitmap
      if Png.Header.ColorType in [COLOR_GRAYSCALEALPHA, COLOR_RGBALPHA] then
        for Y := 0 to Png.Height - 1 do begin
          AlphaLine := Png.AlphaScanline[Y];
          for X := 0 to Png.Width - 1 do
            if AlphaLine^[X] = 0 then
              SetPixelV(MaskBitmap.Canvas.Handle, X, Y, clWhite)
            else
              SetPixelV(MaskBitmap.Canvas.Handle, X, Y, clBlack);
        end
      else if Png.TransparencyMode = ptmBit then begin
        TransparencyColor := Png.TransparentColor;
        for Y := 0 to Png.Height - 1 do
          for X := 0 to Png.Width - 1 do
            if Png.Pixels[X, Y] = TransparencyColor then
              SetPixelV(MaskBitmap.Canvas.Handle, X, Y, clWhite)
            else
              SetPixelV(MaskBitmap.Canvas.Handle, X, Y, clBlack);
      end;

      //Create the icon
      IconInfo.fIcon := True;
      IconInfo.hbmColor := ColorBitmap.Handle;
      IconInfo.hbmMask := MaskBitmap.Handle;
      Result := CreateIconIndirect(IconInfo);
    finally
      ColorBitmap.Free;
      MaskBitmap.Free;
    end;
  end;

begin
  if GetComCtlVersion >= ComCtlVersionIE6 then begin
    //Windows XP or later, using the modern method: convert every PNG to
    //an icon resource with alpha channel
    Result := PngToIcon32(Png);
  end
  else begin
    //No Windows XP, using the legacy method: copy every PNG to a normal
    //bitmap using a fixed background color
    Result := PngToIcon24(Png, Background);
  end;
end;

function ImageFormat(Start: Pointer): string;
type
  ByteArray = array[0..10] of byte;

var
  PB: ^ByteArray absolute Start;
  PW: ^Word absolute Start;
  PL: ^DWord absolute Start;

begin
  if PL^ = $38464947 then
    begin
{    if PB^[4] = Ord('9') then Result := '.gif'
    else }Result := '.gif';
    end
  else if PW^ = $4D42 then Result := '.bmp'
  else if PL^ = $474E5089 then Result := '.png'
  else if PW^ = $D8FF then Result := '.jpeg'
  else Result := '';
end;

function GetWinVersion: string;
var
  VersionInfo: TOSVersionInfo;
  OSName: string;
begin
  // устанавливаем размер записи
  VersionInfo.dwOSVersionInfoSize := SizeOf( TOSVersionInfo );
  if Windows.GetVersionEx( VersionInfo ) then
  begin
    with VersionInfo do
    begin
      case dwPlatformId of
        VER_PLATFORM_WIN32s: OSName := 'Win32s';
        VER_PLATFORM_WIN32_WINDOWS: OSName := 'Windows 95';
        VER_PLATFORM_WIN32_NT: OSName := 'Windows NT';
      end; // case dwPlatformId
      Result := OSName + ' Version ' + IntToStr( dwMajorVersion ) + '.' + IntToStr( dwMinorVersion ) +
      #13#10' (Build ' + IntToStr( dwBuildNumber ) + ': ' + szCSDVersion + ')';
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
  if Pos('Windows NT', GetWinVersion) = 1 then // we've got to do a whole buch of things
  begin
    zero := 0;
    if not OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken) then
    begin
      MessageBox(0, 'Exit Error', 'OpenProcessToken() Failed', MB_OK);
      Exit;
    end; // if not OpenProcessToken( GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken)

    if not OpenProcessToken( GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken) then
    begin
      MessageBox(0, 'Exit Error', 'OpenProcessToken() Failed', MB_OK);
      Exit;
    end; // if not OpenProcessToken( GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken)

    // SE_SHUTDOWN_NAME
    if not LookupPrivilegeValue( nil, 'SeShutdownPrivilege' , tkp.Privileges[0].Luid ) then
    begin
      MessageBox(0, 'Exit Error', 'LookupPrivilegeValue() Failed', MB_OK);
      Exit;
    end; // if not LookupPrivilegeValue( nil, 'SeShutdownPrivilege' , tkp.Privileges[0].Luid )

    tkp.PrivilegeCount := 1;
    tkp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;

    AdjustTokenPrivileges(hToken, False, tkp, SizeOf( TTokenPrivileges ), tkpo, zero);
    if Boolean(GetLastError()) then
    begin
      MessageBox(0, 'Exit Error', 'AdjustTokenPrivileges() Failed', MB_OK);
      Exit;
    end // if Boolean( GetLastError() )
    else
      ExitWindowsEx( EWX_FORCE or EWX_SHUTDOWN, 0 );

  end // if OSVersion = 'Windows NT'
  else
  begin // just shut the machine down
    ExitWindowsEx( EWX_FORCE or EWX_SHUTDOWN, 0 );
  end; // else
end;

function AddZeros(s: string; count: integer): string;
var
  i: integer;
  j: integer;
begin
  j := 1;
  while (count div 10) > 0 do
  begin
    inc(j);
    count := count mod 10;
  end;
  result := s;
  for i  := 1 to j - length(s) do
    result := '0' + result;

end;

end.
