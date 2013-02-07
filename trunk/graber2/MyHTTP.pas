unit MyHTTP;

interface

uses IdHTTP, IdInterceptThrottler, Classes, SysUtils, SyncObjs, Strutils,
  Variants, Common;

type
  TMyCookieList = class(TStringList)
    private
      FCS: TCriticalSection;
    protected
      property CS: TCriticalSection read FCS write FCS;
    public
      constructor Create;
      destructor Destroy; override;
      function GetCookieValue(CookieName,CookieDomain: string): string;
      function GetCookieByValue(CookieName,CookieDomain: string): string;
      procedure DeleteCookie(CookieDomain: string);
      procedure ChangeCookie(CookieDomain,CookieString: String);
      function GetCookiesByDomain(domain: string): string;
      //property Lines[index:integer]: String read Get;
  end;

  TMyIdHTTP = class(TIdCustomHTTP)
    private
      FCookieList: TMyCookieList;
      procedure SetCookieList(Value: TMyCookieList);
    protected
      procedure DoSetCookies(AURL: String; ARequest: TIdHTTPRequest);
      procedure DoProcessCookies(ARequest: TIdHTTPRequest; AResponse: TIdHTTPResponse);
    public
{      procedure Get(AURL: string; AResponseContent: TStream;
        AIgnoreReplies: array of SmallInt);  }
      function Get(AURL: string; AResponse: TStream = nil): string;
      function Post(AURL: string; ASource: TStrings): string; overload;
      procedure Post(AURL: string; ASource: TStrings; AResponse: TStream); overload;
      procedure ReadCookies(url: string; AResponse: TIdHTTPResponse);
      procedure WriteCookies(url: string; ARequest: TIdHTTPRequest);
      property CookieList: TMyCookieList read FCookieList write SetCookieList;
  end;

  function CreateHTTP{(AOwner: TComponent)}: TMyIdHTTP;
  function RemoveURLDomain(url: string) : string;
  function GetUrlVarValue(URL,Variable: String): String;
  function AddURLVar(URL,Variable: String; Value: Variant): String;
  function GetURLDomain(url: string): string;
  procedure GetPostStrings(s: string; outs: TStrings);

var
  idThrottler: tidInterceptThrottler;

implementation

procedure GetPostStrings(s: string; outs: TStrings);
var
  tmp: string;
begin
  s := trim(CopyFromTo(s, '?', ''));
  while s <> '' do
  begin
    tmp := GetNextS(s, '&');
    outs.Add(tmp);
  end;
end;

function CreateHTTP{(AOwner: TComponent)}: TMyIdHTTP;
begin
  Result := TMyIdHTTP.Create{(AOwner)};
  Result.Intercept := idThrottler;
  Result.HandleRedirects := true;
  Result.AllowCookies := False;
  Result.Request.UserAgent :=  'Mozilla/5.0 (Windows NT 6.1; rv:18.0) Gecko/20100101 Firefox/18.0';
//  Result.Request.AcceptLanguage := 'en-us,en;q=0.8';
//  Result.Request.AcceptEncoding := 'gzip, deflate';
//  Result.Request.Accept := 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8';
end;

{var
  cs: TCriticalSection;    }

function GetUrlVarValue(URL,Variable: String): String;
var
  s: string;
begin
  URL := CopyFromTo(URL,'?','');
  while url <> '' do
  begin
    s := GetNextS(URL,'&');
    Result := GetNextS(S,'=');
    if SameText(Result,Variable) then
    begin
      Result := S;
      Exit;
    end;
  end;
  Result := '';
end;

function AddURLVar(URL,Variable: String; Value: Variant): String;
begin
  if pos('?',URL) > 0 then
    Result := URL + '&' + Variable + '=' + VarToStr(Value)
  else
    Result := URL + '?' + Variable + '=' + VarToStr(Value);
end;

function GetCookieName(Cookie: string): string;
  var i: integer;
begin
  Result:='';
  i:=Pos('=',Cookie);
  if i=0 then Exit;
  Result:=Copy(Cookie,1,i-1);
end;

function GetCookieDomain(Cookie: string): string;
  var i,j: integer;
begin
  Result:=''; Cookie := lowercase(Cookie);
  i:=Pos('domain=',Cookie);
  if i=0 then Exit;
  j := PosEx('www.',Cookie,i + 1);
  if j > 0 then
    i := i + 4;
  j:=CharPos(Cookie,';',[],[],i);
  if j=0 then j:=Length(Cookie)+1;
  Result:=Copy(Cookie,i+7,j-i-7);
  // Remove dot
{  if (Result<>'') and (Result[1]='.') then
    Result:=Copy(Result,2,Length(Result)-1);  }
end;

function RemoveURLDomain(url: string) : string;
var
  n: integer;
begin
  Result := url;
  n := pos('://',Result);
  if n > 0 then
  begin
    Delete(Result,1,n+2);
    n := pos('/',Result);
    Delete(Result,1,n);
  end;

end;

function GetURLDomain(url: string): string;
begin
  Result:=DeleteTo(url,'://');
  Result := CopyFromTo(Result,'www.','/');
end;

function GetCookieValue(Cookie: String): string;
begin
  Result:='';
  if Pos('=',Cookie) = 0 then Exit;
  Result := CopyFromTo(Cookie,'=',';');
end;

function SameDomain(s1,s2: string): boolean;
begin
  if s1 = s2 then
    Result := true
  else if (s1[1] = '.')and (pos(trim(s1,'.'),s2) > 0) then
      Result := true
  else if (s2[1] = '.') and (pos(trim(s2,'.'),s1) > 0) then
    Result := true
  else
    Result := false;
end;

constructor TMyCookieList.Create;
begin
  inherited;
  FCS := TCriticalSection.Create;
end;

destructor TMyCookieList.Destroy;
begin
  FCS.Free;
  inherited;
end;

procedure TMyCookieList.ChangeCookie(CookieDomain,CookieString: String);

  function DelleteIfExist(Cookie: string): boolean;
    var i: integer;
  begin
    Result:=false;
    for i := 0 to Count - 1 do
    if (SameDomain(GetCookieDomain(Strings[i]),GetCookieDomain(Cookie)))
    and (GetCookieName(Strings[i])=GetCookieName(Cookie)) then
    begin
      Delete(i);
      Exit;
    end;
  end;

begin
  FCS.Enter;
  try
    if GetCookieDomain(CookieString)='' then
      CookieString := CookieString + '; domain=' + CookieDomain;
    DelleteIfExist(CookieString);
    Add(CookieString);
  finally
    FCS.Leave;
  end;
end;

function TMyCookieList.GetCookiesByDomain(domain: string): string;
var
  i,j: integer;
  s: string;
begin
  result := '';
  //if (length(domain) > 0) and ((pos('www.',lowercase(domain)) = 1)){ or (url[1] = '.'))} then
  //  domain:= DeleteTo(domain,'.');
  FCS.Enter;
  try
    for i := 0 to Count - 1 do
    begin
      s := GetCookieDomain(Strings[i]);
      if SameDomain(s,domain) then
      begin
        j:=Pos(';',Strings[i]);
        Result := Result + Copy(Strings[i],1,j)+' ';
      end;
    end;
  finally
    FCS.Leave;
  end;
end;

procedure TMyCookieList.DeleteCookie(CookieDomain: string);
var i: integer;
begin
  //Result := '';
  FCS.Enter;
  try
    for i := 0 to Self.Count - 1 do
    if SameDomain(GetCookieDomain(Self[i]),CookieDomain)
    {and (GetCookieName(Self[i])=CookieName)} then
    begin
      //Result := MyHTTP.GetCookieValue(Self[i]);
      //Exit;
      Self.Delete(i);
    end;
  finally
    FCS.Leave;
  end;
end;

function TMyCookieList.GetCookieValue(CookieName,CookieDomain: string): string;
var i: integer;

begin
  Result := '';
  FCS.Enter;
  try
    for i := 0 to Self.Count - 1 do
    if SameDomain(GetCookieDomain(Self[i]),CookieDomain)
    and (GetCookieName(Self[i])=CookieName) then
    begin
      Result := MyHTTP.GetCookieValue(Self[i]);
      Exit;
    end;
  finally
    FCS.Leave;
  end;
end;

function TMyCookieList.GetCookieByValue(CookieName,CookieDomain: string): string;
var i: integer;
begin
  Result := '';
  FCS.Enter;
  try
    for i := 0 to Self.Count - 1 do
    if SameDomain(GetCookieDomain(Self[i]),CookieDomain)
    and (GetCookieName(Self[i])=CookieName) then
    begin
      Result := Self[i];
      Exit
    end;
  finally
    FCS.Leave;
  end;
end;

function TMyIdHTTP.Get(AURL: string; AResponse: TStream): string;
begin
  if AResponse = nil then
    Result := inherited Get(AURL)
  else
    inherited Get(AURL,AResponse);
end;

function TMyIdHTTP.Post(AURL: string; ASource: TStrings): string;
begin
  Result := inherited Post(AURL,ASource);
end;

procedure TMyIdHTTP.Post(AURL: string; ASource: TStrings; AResponse: TStream);
begin
  inherited Post(AURL,ASource,AResponse);
end;

procedure TMyIdHTTP.ReadCookies(url: string; AResponse: TIdHTTPResponse);
  var i: integer;
      Cookie: string;

begin
  for i := 0 to AResponse.RawHeaders.Count - 1 do
  if Pos('Set-Cookie: ',AResponse.RawHeaders[i])>0 then
  begin
    Cookie := SysUtils.StringReplace(AResponse.RawHeaders[i],'Set-Cookie: ','',[]);
    FCookieList.ChangeCookie(GetURLDomain(url),Cookie);
  end;
end;

procedure TMyIdHTTP.WriteCookies(url: string;  ARequest: TIdHTTPRequest);
  var Cookies: string;
begin
  URL := GetURLDomain(URL);

  Cookies := CookieList.GetCookiesByDomain(url);

  if Cookies <> '' then
  begin
    Cookies:='Cookie: '+Copy(Cookies,1,Length(Cookies)-2);
//    ARequest.RawHeaders.Clear;
    ARequest.RawHeaders.Add(Cookies);
  end;
end;

procedure TMyIdHTTP.DoSetCookies(AURL: String; ARequest: TIdHTTPRequest);
begin
  //cs.Acquire;
  //try
    WriteCookies(AURL,ARequest);
  //finally
  //  cs.Release;
  //end;
end;

procedure TMyIdHTTP.DoProcessCookies(ARequest: TIdHTTPRequest; AResponse: TIdHTTPResponse);
begin
  //cs.Acquire;
  //try
    ReadCookies(ARequest.Host,AResponse);
  //finally
  //  cs.Release;
  //end;
//  WriteCookies(ARequest.Host,ARequest);
end;

procedure TMyIdHTTP.SetCookieList(Value: TMyCookieList);
begin
  if Value = nil then
  begin
    OnSetCookies := nil;
    OnProcessCookies := nil;
  end else
  begin
    OnSetCookies := DoSetCookies;
    OnProcessCookies := DoProcessCookies;
  end;
  FCookieList := Value;
end;

initialization

  idThrottler := tidInterceptThrottler.Create(nil);
  //cs := TCriticalSection.Create;

finalization

  idThrottler.Free;
  //cs.Free;

end.
