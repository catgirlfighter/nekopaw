unit MyHTTP;

interface

uses MyIdHTTP, IdInterceptThrottler, Classes, SysUtils, SyncObjs, Strutils,
  Variants, Common, IdURI, MyIdURI, idHTTPHeaderInfo, HTTPApp, pac;

type
  tIdProxyRec = record
    Auth: Boolean;
    User, Password, Host: String;
    Port: integer;
  end;

  TMyCookieList = class(TStringList)
  private
    FCS: TCriticalSection;
  protected
    property CS: TCriticalSection read FCS write FCS;
  public
    constructor Create;
    destructor Destroy; override;
    function GetCookieValue(CookieName, CookieDomain: string): string;
    function GetCookieByValue(CookieName, CookieDomain: string): string;
    procedure DeleteCookie(CookieDomain: string);
    procedure ChangeCookie(CookieDomain, CookieString: String);
    function GetCookiesByDomain(domain: string): string;
    procedure SaveToFile(const FileName: string); override;
    // property Lines[index:integer]: String read Get;
  end;

  TOnSetCookies = procedure(AURL: String; ARequest: TIdHTTPRequest) of object;
  TOnProcessCookies = procedure(ARequest: TIdHTTPRequest;
    AResponse: TIdHTTPResponse) of object;

  // TIDHTTPHelper = class helper for TIdHTTP
  // protected
  // FOnSetCookies: TOnSetCookies;
  // FOnProcessCookies: TOnProcessCookies;
  // public
  // property OnSetCookies: TOnSetCookies read FOnSetCookies write FOnSetCookies;
  // property OnProcessCookies: TOnProcessCookies read FOnProcessCookies write FOnProcessCookies;
  // end;

  TMyIdHTTP = class(TIdCustomHTTP)
  private
    FCookieList: TMyCookieList;
    fPACParser: tPACParser;
    fPAC: Boolean;
    procedure SetCookieList(Value: TMyCookieList);
  protected
    procedure DoSetCookies(AURL: String; ARequest: TIdHTTPRequest);
    procedure DoProcessCookies(ARequest: TIdHTTPRequest;
      AResponse: TIdHTTPResponse);
    procedure doPAC(AURL: String);
  public
    { procedure Get(AURL: string; AResponseContent: TStream;
      AIgnoreReplies: array of SmallInt); }
    function Get(AURL: string; AResponse: TStream = nil): string; overload;
    function Get(AURL: string; AIgnoreReplies: array of SmallInt)
      : string; overload;
    function Post(AURL: string; ASource: TStrings): string; overload;
    procedure Post(AURL: string; ASource: TStrings;
      AResponse: TStream); overload;
    procedure ReadCookies(url: string; AResponse: TIdHTTPResponse);
    procedure WriteCookies(url: string; ARequest: TIdHTTPRequest);
    property CookieList: TMyCookieList read FCookieList write SetCookieList;
    property PACParser: tPACParser read fPACParser write fPACParser;
    property UsePAC: Boolean read fPAC write fPAC;
    procedure Head(AURL: string; AIgnoreReplies: array of SmallInt); overload;
  end;

function CreateHTTP { (AOwner: TComponent) } : TMyIdHTTP;
function RemoveURLDomain(url: string): string;
function GetUrlVarValue(url, Variable: String): String;
function AddURLVar(url, Variable: String; Value: Variant): String;
function GetURLDomain(url: string): string;
procedure GetPostStrings(s: string; outs: TStrings);
function CheckProto(url, referer: string): string;
function GetProxyParams(const pp: tIdProxyConnectionInfo): tIdProxyRec;
procedure SetProxyParams(const pp: tIdProxyConnectionInfo;
  const p: tIdProxyRec);

var
  idThrottler: tidInterceptThrottler;

implementation

function CheckProto(url, referer: string): string;
var
  uri1, uri2: tiduri;
begin
  uri1 := tiduri.Create(url);
  try
    uri2 := tiduri.Create(referer);
    try

      if uri1.Protocol = '' then
        if uri2.Protocol = '' then
          uri1.Protocol := 'http'
        else
          uri1.Protocol := uri2.Protocol;

      if (uri1.Host = '') then
      begin
        uri1.Host := uri2.Host;

        if uri1.Path = '' then
          uri1.Path := uri2.Path;

      end;

      result := uri1.GetFullURI;

    finally
      uri2.Free;
    end;
  finally
    uri1.Free;
  end;
end;

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

function CreateHTTP { (AOwner: TComponent) } : TMyIdHTTP;
begin
  result := TMyIdHTTP.Create { (AOwner) };
  result.Intercept := idThrottler;
  result.HandleRedirects := true;
  result.AllowCookies := False;
  result.Request.UserAgent :=
    'Mozilla/5.0 (Windows NT 6.1; rv:23.0) Gecko/20100101 Firefox/23.0';
  result.ConnectTimeout := 10000;
  result.ReadTimeout := 10000;
  result.RedirectMaximum := 5;
  // result.ProxyParams
  // Result.Request.AcceptLanguage := 'en-us,en;q=0.8';
  // Result.Request.AcceptEncoding := 'gzip, deflate';
  // Result.Request.Accept := 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8';
end;

{ var
  cs: TCriticalSection; }

function GetUrlVarValue(url, Variable: String): String;
var
  s: string;
begin
  url := CopyFromTo(url, '?', '');
  while url <> '' do
  begin
    s := GetNextS(url, '&');
    result := GetNextS(s, '=');
    if SameText(result, Variable) then
    begin
      result := s;
      Exit;
    end;
  end;
  result := '';
end;

function AddURLVar(url, Variable: String; Value: Variant): String;
begin
  if pos('?', url) > 0 then
    result := url + '&' + Variable + '=' + VarToStr(Value)
  else
    result := url + '?' + Variable + '=' + VarToStr(Value);
end;

function GetCookieName(Cookie: string): string;
var
  i: integer;
begin
  result := '';
  i := pos('=', Cookie);
  if i = 0 then
    Exit;
  result := Copy(Cookie, 1, i - 1);
end;

function GetCookieDomain(Cookie: string): string;
var
  i, j: integer;
begin
  result := '';
  Cookie := lowercase(Cookie);
  i := pos('domain=', Cookie);
  if i = 0 then
    Exit;
  j := PosEx('www.', Cookie, i + 1);
  if j > 0 then
    i := i + 4;
  j := CharPos(Cookie, ';', [], [], i);
  if j = 0 then
    j := Length(Cookie) + 1;
  result := Copy(Cookie, i + 7, j - i - 7);
  // Remove dot
  { if (Result<>'') and (Result[1]='.') then
    Result:=Copy(Result,2,Length(Result)-1); }
end;

function RemoveURLDomain(url: string): string;
var
  n: integer;
begin
  result := url;
  n := pos('://', result);
  if n > 0 then
  begin
    Delete(result, 1, n + 2);
    n := pos('/', result);
    Delete(result, 1, n);
  end;

end;

function GetURLDomain(url: string): string;
begin
  result := DeleteTo(url, '://');
  result := CopyFromTo(result, 'www.', '/');
end;

function GetCookieValue(Cookie: String): string;
begin
  result := '';
  if pos('=', Cookie) = 0 then
    Exit;
  result := CopyFromTo(Cookie, '=', ';');
end;

function SameDomain(s1, s2: string): Boolean;
begin
  if s1 = s2 then
    result := true
  else if (s1[1] = '.') and (pos(trim(s1, '.'), s2) > 0) then
    result := true
  else if (s2[1] = '.') and (pos(trim(s2, '.'), s1) > 0) then
    result := true
  else
    result := False;
end;

function GetProxyParams(const pp: tIdProxyConnectionInfo): tIdProxyRec;
begin
  result.Auth := pp.BasicAuthentication;
  result.User := pp.ProxyUsername;
  result.Password := pp.ProxyPassword;
  result.Host := pp.ProxyServer;
  result.Port := pp.ProxyPort;
end;

procedure SetProxyParams(const pp: tIdProxyConnectionInfo;
  const p: tIdProxyRec);
begin
  pp.BasicAuthentication := p.Auth;
  pp.ProxyServer := p.Host;
  pp.ProxyPort := p.Port;
  pp.ProxyUsername := p.User;
  pp.ProxyPassword := p.Password;
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

procedure TMyCookieList.ChangeCookie(CookieDomain, CookieString: String);

  function DelleteIfExist(Cookie: string): Boolean;
  var
    i: integer;
  begin
    result := False;
    for i := 0 to Count - 1 do
      if (SameDomain(GetCookieDomain(Strings[i]), GetCookieDomain(Cookie))) and
        (GetCookieName(Strings[i]) = GetCookieName(Cookie)) then
      begin
        Delete(i);
        Exit;
      end;
  end;

begin
  FCS.Enter;
  try
    if GetCookieDomain(CookieString) = '' then
      CookieString := CookieString + '; domain=' + CookieDomain;
    DelleteIfExist(CookieString);
    Add(CookieString);
  finally
    FCS.Leave;
  end;
end;

procedure TMyCookieList.SaveToFile(const FileName: string);
begin
  FCS.Enter;
  inherited SaveToFile(FileName);
  FCS.Leave;
end;

function TMyCookieList.GetCookiesByDomain(domain: string): string;
var
  i, j: integer;
  s: string;
begin
  result := '';
  // if (length(domain) > 0) and ((pos('www.',lowercase(domain)) = 1)){ or (url[1] = '.'))} then
  // domain:= DeleteTo(domain,'.');
  FCS.Enter;
  try
    for i := 0 to Count - 1 do
    begin
      s := GetCookieDomain(Strings[i]);
      if SameDomain(s, domain) then
      begin
        j := pos(';', Strings[i]);
        result := result + Copy(Strings[i], 1, j) + ' ';
      end;
    end;
  finally
    FCS.Leave;
  end;
end;

procedure TMyCookieList.DeleteCookie(CookieDomain: string);
var
  i: integer;
begin
  // Result := '';
  FCS.Enter;
  try
    for i := 0 to Self.Count - 1 do
      if SameDomain(GetCookieDomain(Self[i]), CookieDomain)
      { and (GetCookieName(Self[i])=CookieName) } then
      begin
        // Result := MyHTTP.GetCookieValue(Self[i]);
        // Exit;
        Self.Delete(i);
      end;
  finally
    FCS.Leave;
  end;
end;

function TMyCookieList.GetCookieValue(CookieName, CookieDomain: string): string;
var
  i: integer;

begin
  // CookieDomain := CopyTo(CookieDomain,'/');
  result := '';
  FCS.Enter;
  try
    for i := 0 to Self.Count - 1 do
      if SameDomain(GetCookieDomain(Self[i]), CookieDomain) and
        (GetCookieName(Self[i]) = CookieName) then
      begin
        result := MyHTTP.GetCookieValue(Self[i]);
        Exit;
      end;
  finally
    FCS.Leave;
  end;
end;

function TMyCookieList.GetCookieByValue(CookieName, CookieDomain
  : string): string;
var
  i: integer;
begin
  result := '';
  FCS.Enter;
  try
    for i := 0 to Self.Count - 1 do
      if SameDomain(GetCookieDomain(Self[i]), CookieDomain) and
        (GetCookieName(Self[i]) = CookieName) then
      begin
        result := Self[i];
        Exit
      end;
  finally
    FCS.Leave;
  end;
end;

procedure TMyIdHTTP.Head(AURL: string; AIgnoreReplies: array of SmallInt);
begin
  // if fPAC and Assigned(fPACParser) then
  doPAC(AURL);

  DoRequest(Id_HTTPMethodHead, AURL, nil, nil, AIgnoreReplies);

  // if fPAC and Assigned(fPACParser) then
  // SetProxyParams(ProxyParams,p);
end;

function TMyIdHTTP.Get(AURL: string; AResponse: TStream): string;
begin
  doPAC(AURL);

  if AResponse = nil then
    result := inherited Get(AURL)
  else
  begin
    result := '';
    inherited Get(AURL, AResponse);
  end;
end;

function TMyIdHTTP.Get(AURL: string; AIgnoreReplies: array of SmallInt): string;
begin
  doPAC(AURL);
  result := inherited Get(AURL, AIgnoreReplies);
end;

function TMyIdHTTP.Post(AURL: string; ASource: TStrings): String;
begin
  doPAC(AURL);
  result := inherited Post(AURL, ASource);
end;

procedure TMyIdHTTP.Post(AURL: string; ASource: TStrings; AResponse: TStream);
begin
  doPAC(AURL);
  inherited Post(AURL, ASource, AResponse);
end;

procedure TMyIdHTTP.ReadCookies(url: string; AResponse: TIdHTTPResponse);
var
  i: integer;
  Cookie: string;

begin
  for i := 0 to AResponse.RawHeaders.Count - 1 do
    if ContainsText(AResponse.RawHeaders[i], 'Set-Cookie: ') then
    begin
      Cookie := SysUtils.StringReplace(AResponse.RawHeaders[i],
        'Set-Cookie: ', '', [rfIgnoreCase]);
      FCookieList.ChangeCookie(GetURLDomain(url), Cookie);
    end;
end;

procedure TMyIdHTTP.WriteCookies(url: string; ARequest: TIdHTTPRequest);
var
  Cookies: string;
begin
  url := GetURLDomain(url);

  Cookies := CookieList.GetCookiesByDomain(url);

  if Cookies <> '' then
  begin
    Cookies := 'Cookie: ' + Copy(Cookies, 1, Length(Cookies) - 2);
    // ARequest.RawHeaders.Clear;
    ARequest.RawHeaders.Add(Cookies);
  end;
end;

procedure TMyIdHTTP.DoSetCookies(AURL: String; ARequest: TIdHTTPRequest);
begin
  // cs.Acquire;
  // try
  WriteCookies(AURL, ARequest);
  // finally
  // cs.Release;
  // end;
end;

procedure TMyIdHTTP.doPAC(AURL: String);
var
  Host: string;
  Port, i: integer;
begin
  if not(fPAC and Assigned(fPACParser)) then
    Exit;

  Host := fPACParser.GetProxy(ANSIString(AURL), ANSIString(GetURLDomain(AURL)));
  if SameText(Host, 'direct') then
    Host := '';

  i := pos(':', Host);
  if i > 0 then
  begin
    Port := StrToInt(CopyFromTo(Host, ':', ''));
    Host := Copy(Host, 1, i - 1);
  end
  else
    Port := 80;

  with ProxyParams do
  begin
    BasicAuthentication := False;
    ProxyServer := Host;
    ProxyPort := Port;
    ProxyUsername := '';
    ProxyPassword := '';
  end;
end;

procedure TMyIdHTTP.DoProcessCookies(ARequest: TIdHTTPRequest;
  AResponse: TIdHTTPResponse);
begin
  ReadCookies(ARequest.Host, AResponse);
end;

procedure TMyIdHTTP.SetCookieList(Value: TMyCookieList);
begin
  if Value = nil then
  begin
    OnSetCookies := nil;
    OnProcessCookies := nil;
  end
  else
  begin
    OnSetCookies := DoSetCookies;
    OnProcessCookies := DoProcessCookies;
  end;
  FCookieList := Value;
end;

initialization

idThrottler := tidInterceptThrottler.Create(nil);
// cs := TCriticalSection.Create;

finalization

idThrottler.Free;
// cs.Free;

end.
