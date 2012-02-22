unit UPDUnit;

interface

uses SysUtils,Classes,MyHTTP,MyXMLParser,GraberU,Windows,rpVersionInfo;

type

  TUpdThread = class(TThread)
  private
    FHTTP: TMyIdHTTP;
    FHWND: HWND;
    FJob: Integer;
    FListURL: String;
    FString: String;
  public
    procedure Execute;
    function CheckUpdates(s: string): boolean;
    property Job: Integer read FJob write FJob;
    property ListURL: String read FListURL write FListURL;
    property Error: String read FString write FString;
    property MsgHWND: HWND read FHWND write FHWND;
  end;

implementation

function GetVersion(sFileName:string): string;
var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
begin
  VerInfoSize := GetFileVersionInfoSize(PChar(sFileName), Dummy);
  GetMem(VerInfo, VerInfoSize);
  GetFileVersionInfo(PChar(sFileName), 0, VerInfoSize, VerInfo);
  VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
  with VerValue^ do
  begin
    Result := IntToHEX(dwFileVersionMS shr 16,2);
    Result := Result + IntToHEX(dwFileVersionMS and $FFFF,2);
    Result := Result + IntToHEX(dwFileVersionLS shr 16,2);
    Result := Result + IntToHEX(dwFileVersionLS and $FFFF,2);
  end;
  FreeMem(VerInfo, VerInfoSize);
end;

function TUpdThread.CheckUpdates(s: string): boolean;
var
  xml: TMyXMLParser;
  items: TTagList;
  i: integer;
  root: string;
begin
  root := ExtractFilePath(paramstr(0));
  xml := TMyXMLParser.Create;
  xml.Parse(s);

  items := TTagList.Create;
  xml.TagList.GetList('item',nil,items);

  for i := 0 to items.Count-1 do
  begin
    if items[i].Attrs.Value('type') = 'exe' then
    begin

    end
    else if items[i].Attrs.Value('type') = 'txt' then
    begin

    end
  end;


  items.Free;
  xml.Free;
end;

procedure TUpdThread.Execute;
var
  s: string;

begin
  FHTTP := TmyIdHTTP.Create;
  ReturnValue := 0;
  try
    s := FHTTP.Get(FListURL);
    if CheckUpdates(s) then
      ReturnValue := 1
    else
      ReturnValue := 2;
  except on e: exception do
    FString := e.Message;
  end;
  FHTTP.Free;
  PostMessage(FHWND,CM_UPDATE,ReturnValue,0);
end;

end.
