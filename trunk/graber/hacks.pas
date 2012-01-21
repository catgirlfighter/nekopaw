unit hacks;

interface

uses Windows, Messages, SysUtils, Classes, ComCtrls, CheckLst, StdCtrls,
  clipbrd, AdvGrid, unit_win7TaskBar, ShellAPI, Controls, JvTypes, JvDriveCtrls,
  Forms, TB2Item, SpTBXItem, IdHTTP, StrUtils;

type

  TVerticalScroll =  procedure (var Msg: TWMVScroll) of object;

  TAdvStringGrid = class(AdvGrid.TAdvStringGrid)
    private
      FIsAuto: Boolean;
      FOnVScroll: TVerticalScroll;
      procedure WMVScroll(var Msg: TWMVScroll); message WM_VSCROLL;
    public
      procedure AutoSetRow(AValue: Integer);
      constructor Create(AOwner: TComponent); override;
      procedure SetColumnReadOnly(c: integer; n: Boolean);
    published
      property IsAutoSelect: Boolean read FIsAuto;
      property OnVerticalScroll: TVerticalScroll read FOnVScroll write FOnVScroll;
  end;

  TCheckListBox = class(CheckLst.TCheckListBox)
    public
      procedure CheckInverse;
  end;

  TMyCookieList = class(TStringList)
    public
      function GetCookieValue(CookieName,CookieDomain: string): string;
      function GetCookieByValue(CookieName,CookieDomain: string): string;
    procedure DeleteCookie(CookieDomain: String);
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

      function Post(AURL: string; ASource: TStrings): string;
      procedure ReadCookies(url: string; AResponse: TIdHTTPResponse);
      procedure WriteCookies(url: string; ARequest: TIdHTTPRequest);
      property CookieList: TMyCookieList read FCookieList write SetCookieList;
  end;

  TPreventNotifyEvent = procedure(Sender: TObject; var Text: string; var Accept: Boolean) of object;

  TMemo = class(StdCtrls.TMemo)
   private
{     FPreventCut: Boolean;
     FPreventCopy: Boolean;
     FPreventPaste: Boolean;
     FPreventClear: Boolean;   }

{     FOnCut: TPreventNotifyEvent;
     FOnCopy: TPreventNotifyEvent;   }
     FOnPaste: TPreventNotifyEvent;
{     FOnClear: TPreventNotifyEvent;  }

{     procedure WMCut(var Message: TWMCUT); message WM_CUT;
     procedure WMCopy(var Message: TWMCOPY); message WM_COPY;  }
     procedure WMPaste(var Message: TWMPASTE); message WM_PASTE;
{     procedure WMClear(var Message: TWMCLEAR); message WM_CLEAR;  }
   protected
     { Protected declarations }
   public
     { Public declarations }
   published
{     property PreventCut: Boolean read FPreventCut write FPreventCut default False;
     property PreventCopy: Boolean read FPreventCopy write FPreventCopy default False;
     property PreventPaste: Boolean read FPreventPaste write FPreventPaste default False;
     property PreventClear: Boolean read FPreventClear write FPreventClear default False;   }
{     property OnCut: TPreventNotifyEvent read FOnCut write FOnCut;
     property OnCopy: TPreventNotifyEvent read FOnCopy write FOnCopy;    }
     property OnPaste: TPreventNotifyEvent read FOnPaste write FOnPaste;
{     property OnClear: TPreventNotifyEvent read FOnClear write FOnClear;  }
  end;

  TProgressBar = class(ComCtrls.TProgressBar)
    private
      FMainBar: Boolean;
    public
      procedure SetMainBar(AValue: Boolean);
      procedure SetStyle(Value: TProgressBarStyle);
      procedure SetPosition(Value: Integer);
      procedure SetState(Value: TProgressBarState);
      procedure UpdateStates;
    published
      property MainBar: Boolean read FMainBar write SetMainBar;
  end;

implementation

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
{  j := PosEx('www.',Cookie,i + 1);
  if j > 0 then
    i := i + 4;    }
  j:=PosEx(';',Cookie,i);
  if j=0 then j:=Length(Cookie)+1;
  Result:=Copy(Cookie,i+7,j-i-7);
  // Remove dot
{  if (Result<>'') and (Result[1]='.') then
    Result:=Copy(Result,2,Length(Result)-1);   }
end;

function GetURLDomain(url: string): string;
  var i,j,l: integer;
begin
  Result:=SysUtils.StringReplace(LowerCase(url),'http://','',[]);
//  Result:=SysUtils.StringReplace(Result,'www.','.',[]);
  if Pos('www.',Result) = 1 then
    i:=PosEx('.',Result,4)
  else
    i := Pos('.',Result);
  if i=0 then Exit;
  j:=PosEx('/',Result,i);
  if j=0 then j:=PosEx('\',Result,i);
  if j>0 then Result:=Copy(Result,1,j-1);
  j:=0;
  l:=Length(Result);
  for i:=1 to l do
    if Result[i]='.' then inc(j);
  if j>1 then
  begin
    j:=0;
    for i:=l downto 1 do
    if Result[i]='.' then
    begin
      inc(j);
      if j=2 then
      begin
        Result:=Copy(Result,i+1,l-1);
        Exit;
      end;
    end;
  end;
end;

function GetCookieValue(Cookie: String): string;
begin
  Result:='';
  if Pos('=',Cookie) = 0 then Exit;
  Result := CopyFromTo(Cookie,'=',';');
end;

//TMemo

{ procedure TMemo.WMCut(var Message: TWMCUT);
 var
   Accept: Boolean;
   Handle: THandle;
   HandlePtr: Pointer;
   CText: string;
 begin
   if FPreventCut then
     Exit;
   if SelLength = 0 then
     Exit;
   CText := Copy(Text, SelStart + 1, SelLength);
   try
     OpenClipBoard(Self.Handle);
     Accept := True;
     if Assigned(FOnCut) then
       FOnCut(Self, CText, Accept);
     if not Accept then
       Exit;
     Handle := GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE, Length(CText) + 1);
     if Handle = 0 then
       Exit;
     HandlePtr := GlobalLock(Handle);
     Move((PChar(CText))^, HandlePtr^, Length(CText));
     SetClipboardData(CF_TEXT, Handle);
     GlobalUnlock(Handle);
     CText := Text;
     Delete(CText, SelStart + 1, SelLength);
     Text := CText;
   finally
     CloseClipBoard;
   end;
 end;


 procedure TMemo.WMCopy(var Message: TWMCOPY);
 var
   Accept: Boolean;
   Handle: THandle;
   HandlePtr: Pointer;
   CText: string;
 begin
   if FPreventCopy then
     Exit;
   if SelLength = 0 then
     Exit;
   CText := Copy(Text, SelStart + 1, SelLength);
   try
     OpenClipBoard(Self.Handle);
     Accept := True;
     if Assigned(FOnCopy) then
       FOnCopy(Self, CText, Accept);
     if not Accept then
       Exit;
     Handle := GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE, Length(CText) + 1);
     if Handle = 0 then
       Exit;
     HandlePtr := GlobalLock(Handle);
     Move((PChar(CText))^, HandlePtr^, Length(CText));
     SetClipboardData(CF_TEXT, Handle);
     GlobalUnlock(Handle);
   finally
     CloseClipBoard;
   end;
 end;                                  }


 procedure TMemo.WMPaste(var Message: TWMPASTE);
 var
   Accept: Boolean;
   CText: string;
   LText: string;
 begin
    CText := clipboard.AsText;
    if CText = '' then
      Exit;

    Accept := True;

    LText := Ctext;

    if Assigned(FOnPaste) then
      FOnPaste(Self, CText, Accept);
    if not Accept then
      Exit
    else if CText <> LText then
      SelText := CText
    else
      inherited;
 end;


{ procedure TMemo.WMClear(var Message: TWMCLEAR);
 var
   Accept: Boolean;
   CText: string;
 begin
   if FPreventClear then
     Exit;
   if SelStart = 0 then
     Exit;
   CText  := Copy(Text, SelStart + 1, SelLength);
   Accept := True;
   if Assigned(FOnClear) then
     FOnClear(Self, CText, Accept);
   if not Accept then
     Exit;
   CText := Text;
   Delete(CText, SelStart + 1, SelLength);
   Text := CText;
 end;         }

//TProgressBar

procedure TProgressBar.SetMainBar(AValue: Boolean);
begin
  FMainBar := AValue;
  SetPosition(Position);
  SetState(State);
end;

procedure TProgressBar.SetStyle(Value: TProgressBarStyle);
const
  P: array[TProgressBarState] of TTaskBarProgressState = (tbpsNormal,tbpsError,tbpsPaused);

begin
  Style := Value;
  case Value of
    pbstNormal:
    begin
      if Position = 0 then
        SetTaskbarProgressState(tbpsNone)
      else
        SetTaskbarProgressState(P[State]);
    end;
    pbstMarquee:
    begin
      SetTaskBarProgressValue(0,100);
      SetTaskbarProgressState(tbpsIndeterminate);
    end;
  end;
end;

procedure TProgressBar.SetPosition(Value: Integer);
begin
  if Position = Value then
    Exit
  else
    Position := Value;
  if FMainBar then
  begin
    if (WIN32MajorVersion >= 6) then
    begin
      SetTaskbarProgressValue(Value, Max);
      if Value = 0 then
//        SetTaskBarProgressValue(0,100);
        SetTaskbarProgressState(tbpsNone);
    end;
  end;
end;

procedure TProgressBar.SetState(Value: TProgressBarState);
//TProgressBarState = (pbsNormal, pbsError, pbsPaused);
const
  P: array[TProgressBarState] of TTaskBarProgressState = (tbpsNormal,tbpsError,tbpsPaused);

//(tbpsNone, tbpsIndeterminate, tbpsNormal, tbpsError, tbpsPaused);
begin
  State := Value;
  if FMainBar then
    if (WIN32MajorVersion >= 6) then
      if (Value = pbsNormal) and (Style = pbstMarquee) then
        SetTaskbarProgressState(tbpsIndeterminate)
      else
        SetTaskbarProgressState(P[State]);
end;

procedure TProgressBar.UpdateStates;
const
  P: array[TProgressBarState] of TTaskBarProgressState = (tbpsNormal,tbpsError,tbpsPaused);
begin
  if FMainBar then
    if (WIN32MajorVersion >= 6) then
      if (Style = pbstMarquee) then
      begin
        SetTaskBarProgressValue(0,100);
        SetTaskbarProgressState(tbpsIndeterminate);
      end
      else
        if Position <> 0 then
        begin
        SetTaskBarProgressValue(Position,Max);
        SetTaskbarProgressState(P[State]);
      end;
{      else
        SetTaskbarProgressState(tbpsNone);}
end;

//TAdvStringGrid

procedure TAdvStringGrid.WMVScroll(var Msg: TWMVScroll);
begin
  inherited;
  if Assigned(FOnVScroll) then
    FOnVScroll(Msg);
end;

procedure TAdvStringGrid.AutoSetRow(AValue: Integer);
begin
  FIsAuto := true;
  if Row <>AValue then SetRowEx(AValue);
  FIsAuto := false;
end;

constructor TAdvStringGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOnVScroll := nil;
  FIsAuto := false;
end;

procedure TAdvStringGrid.SetColumnReadOnly(c: integer; n: Boolean);
var
  i: integer;
begin
  for i := FixedRows to RowCount - 1 do
    ReadOnly[c,i] := n;
end;

//TCheckListBox

procedure TCheckListBox.CheckInverse;
var
  I: Integer;
begin
  for I := 0 to Items.Count - 1 do
    Checked[i] := not Checked[i];
end;

function TMyCookieList.GetCookieValue(CookieName,CookieDomain: string): string;
var i: integer;
begin
  Result := '';
  for i := 0 to Self.Count - 1 do
  if (GetCookieDomain(Self[i])=CookieDomain)
  and (GetCookieName(Self[i])=CookieName) then
  begin
    Result := hacks.GetCookieValue(Self[i]);
    Exit
  end;
end;

procedure TMyCookieList.DeleteCookie(CookieDomain: String);
var i: integer;
begin
  //Result := '';
  CookieDomain := GetURLDomain(CookieDomain);
  i := 0;
  while i < Self.Count do
    if (GetCookieDomain(Self[i])=CookieDomain)
    {and (GetCookieName(Self[i])=CookieName)} then
      Delete(i)
    else
      inc(i);
end;

function TMyCookieList.GetCookieByValue(CookieName,CookieDomain: string): string;
var i: integer;
begin
  Result := '';
  for i := 0 to Self.Count - 1 do
  if (GetCookieDomain(Self[i])=CookieDomain)
  and (GetCookieName(Self[i])=CookieName) then
  begin
    Result := Self[i];
    Exit
  end;
end;

function TMyIdHTTP.Get(AURL: string; AResponse: TStream): string;
begin
{  if Assigned(FCookieList) then
    WriteCookies(AURL); }
  if AResponse = nil then
    Result := inherited Get(AURL)
  else
    inherited Get(AURL,AResponse);
{  if Assigned(FCookieList) then
    ReadCookies(AURL);  }
end;

function TMyIdHTTP.Post(AURL: string; ASource: TStrings): string;
begin
{  if Assigned(FCookieList) then
    WriteCookies(AURL);  }
  Result := inherited Post(AURL,ASource);
{  if Assigned(FCookieList) then
    ReadCookies(AURL);      }
end;

procedure TMyIdHTTP.ReadCookies(url: string; AResponse: TIdHTTPResponse);
  var i: integer;
      Cookie: string;

  function DelleteIfExist(Cookie: string): boolean;
    var i: integer;
  begin
    Result:=false;
    for i := 0 to FCookieList.Count - 1 do
    if (GetCookieDomain(FCookieList[i])=GetCookieDomain(Cookie))
    and (GetCookieName(FCookieList[i])=GetCookieName(Cookie)) then
    begin
      FCookieList.Delete(i);
      Exit;
    end;
  end;

begin
  for i := 0 to AResponse.RawHeaders.Count - 1 do
  if Pos('Set-Cookie: ',AResponse.RawHeaders[i])>0 then
  begin
    Cookie:=SysUtils.StringReplace(AResponse.RawHeaders[i],'Set-Cookie: ','',[]);
    if GetCookieDomain(Cookie)='' then Cookie:=Cookie+'; domain='+GetURLDomain(url);
    DelleteIfExist(Cookie);
    FCookieList.Add(Cookie);
  end;
end;

procedure TMyIdHTTP.WriteCookies(url: string;  ARequest: TIdHTTPRequest);
  var i,j: integer;
      Cookies: string;
      s: string;
begin
    URL := GetURLDomain(URL);
  if (length(url) > 0) and ((pos('www.',lowercase(url)) = 1) or (url[1] = '.')) then
    URL := DeleteTo(url,'.');

  for i := 0 to FCookieList.Count - 1 do
  begin
    s := GetCookieDomain(FCookieList[i]);
    if (length(s) > 0) and ((pos('www.',lowercase(s)) = 1) or (s[1] = '.')) then
      s := DeleteTo(s,'.');
    if s = url then
    begin
      j:=Pos(';',FCookieList[i]);
      Cookies:=Cookies+Copy(FCookieList[i],1,j)+' ';
    end;
  end;
  if Cookies<>'' then
  begin
    Cookies:='Cookie: '+Copy(Cookies,1,Length(Cookies)-2);
//    ARequest.RawHeaders.Clear;
    ARequest.RawHeaders.Add(Cookies);
  end;
end;

procedure TMyIdHTTP.DoSetCookies(AURL: String; ARequest: TIdHTTPRequest);
begin
  WriteCookies(AURL,ARequest);
end;

procedure TMyIdHTTP.DoProcessCookies(ARequest: TIdHTTPRequest; AResponse: TIdHTTPResponse);
begin
  ReadCookies(ARequest.Host,AResponse);
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

  if (Win32MajorVersion >= 6) and (Win32MinorVersion > 0) then
    InitializeTaskbarAPI;

end.
