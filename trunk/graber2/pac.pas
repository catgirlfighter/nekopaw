unit pac;

interface

uses SysUtils, StrUtils, SyncObjs, Windows, Dialogs;

type

  tpacparser_error_printer = function(const fmt: pansichar; argp: va_list): integer; cdecl;
  ppacparser_error_printer = ^tpacparser_error_printer;
  tpacparser_set_error_printer = procedure(func: ppacparser_error_printer); cdecl;
  tpacparser_init = function: integer; cdecl;{ stdcall;
    external 'pac.dll' name 'pacparser_init'; }
  tpacparser_cleanup = procedure; cdecl;{ stdcall; external 'pac.dll'; }

  tpacparser_version = function: pansichar; cdecl;
  { cdecl; stdcall; external 'pac.dll'; }

  tpacparser_parse_pac_string = function(const pacstring: pansichar
    // PAC string to parse
    ): integer;  cdecl;{ stdcall; external 'pac.dll'; }
  tpacparser_find_proxy = function(const url, // URL to find proxy for
    host: pansichar // Host part of the URL
    ): pansichar;  cdecl;{ stdcall; external 'pac.dll'; }

  tPACParser = class
  private
    fINIT: Boolean;
    fReIn: Boolean;
    fCS: tCriticalSection;
    fDLLHandle: Cardinal;
    _init: tpacparser_init;
    _cleanup: tpacparser_cleanup;
    _version: tpacparser_version;
    _parse_pac_string: tpacparser_parse_pac_string;
    _find_proxy: tpacparser_find_proxy;
    _set_error_printer: tpacparser_set_error_printer;
  protected
    procedure LoadLib;
    function GetProc(s: pansichar): Pointer;
    procedure doInit;
    function pacparser_init: integer;
  public
    procedure LoadScript(s: ANSIString);
    function GetProxy(const url, host: ANSIString): UnicodeString;
    constructor Create;
    destructor Destroy; override;
    property Initiated: Boolean read fINIT;
    property Reload: Boolean read fReIn write fReIn;
  end;

implementation

{ **** tPACPARSER ******* }

function error_printer(const fmt: pansichar; argp: va_list): integer; cdecl;
var
  r: array[0..1024] of ANSIChar;
  //f: PWideChar;
begin

//  ShowMessage('derp');
  //f := PWideChar(WideString(ANSIString(fmt)));
  wvsprintfA(r,fmt,argp);
  raise Exception.Create(String(r));
end;

procedure tPACParser.LoadLib;
begin
  fDLLHandle := LoadLibrary('pac.dll');

  if fDLLHandle = 0 then
    raise Exception.Create('Cannot access to pac.dll');

  @_init := GetProc('pacparser_init');
  @_cleanup := GetProc('pacparser_cleanup');
  @_version := GetProc('pacparser_version');
  @_parse_pac_string := GetProc('pacparser_parse_pac_string');
  @_find_proxy := GetProc('pacparser_find_proxy');
  @_set_error_printer := GetProc('pacparser_set_error_printer');
  _set_error_printer(@error_printer);
end;

function tPACParser.GetProc(s: pansichar): Pointer;
begin
  Result := GetProcAddress(fDLLHandle, s);
  if Result = nil then
    raise Exception.Create('Cannot load method "' + s + '"');
end;

procedure tPACParser.doInit;
var
  w: integer;
begin
  if not fINIT then
  begin
    LoadLib;
    try
      w := pacparser_init;
      if w = 0 then
        raise Exception.Create('PAC parser initialisation error');
      fINIT := True;
    except
      FreeLibrary(fDLLHandle);
      raise;
    end;
  end;

end;

function tPACParser.pacparser_init: integer;
var
  w: word;
begin
  w := Get8087CW;
  Set8087CW($133F);
  try
    Result := _init;
  finally
    Set8087CW(w);
  end;
end;

procedure tPACParser.LoadScript(s: ANSIString);
var
  w: integer;
  //d: va_list;
begin
  doInit;
  w := _parse_pac_string(PANSICHAR(s));
  if w = 0 then
    raise Exception.Create('PAC parser loading script error');
  fReIn := false;
end;

function tPACParser.GetProxy(const url: ANSIString; const host: ANSIString)
  : UnicodeString;
var
  i: integer;
begin
  fCS.Enter;
  try
    Result := UnicodeString(_find_proxy(pansichar(url), pansichar(host)));
    i := pos(';', Result);
    if i > 0 then
      Result := Copy(Result, 1, i - 1);

    i := pos('proxy ', lowercase(Result));
    if i > 0 then
      delete(Result, 1, i + 5);
  finally
    fCS.Leave;
  end;

end;

constructor tPACParser.Create;
begin
  inherited;
  fCS := tCriticalSection.Create;
end;

destructor tPACParser.Destroy;
begin
  fCS.Free;
  if fINIT then
  begin
    _cleanup;
    FreeLibrary(fDLLHandle);
  end;

  inherited;
end;

end.
