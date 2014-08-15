unit UPDUnit;

interface

uses Windows, SysUtils, Classes, Messages, MyHTTP, MyXMLParser, INIFiles,
  common, IdComponent, ZIP, ActiveX;

const
  CM_UPDATE = WM_USER + 13;
  CM_UPDATEPROGRESS = WM_USER + 14;
  UPD_CHECK_UPDATES = 0;
  UPD_DOWNLOAD_UPDATES = 1;

  UPD_FILECOUNT = 0;
  UPD_FILEPOS = 1;
  UPD_FILESIZE = 2;
  UPD_FILEPROGRESS = 3;
  UPD_FILENAME = 4;
  UPD_FILEDELETED = 5;
  UPD_FILEUNZIP = 6;
  UPD_DWDONE = 7;
type

  TUpdThread = class(TThread)
  private
    FHTTP: TMyIdHTTP;
    FHWND: HWND;
    FJob: Integer;
    FListURL: String;
    FCheckURL: String;
    FString: String;
    FEventHandle: THandle;
    fincSkins: Boolean;
    procedure IdHTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure IdHTTPWork(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
  public
    property Event: THandle read FEventHandle;
    procedure Execute; override;
    function CheckUpdates(s: string; items: TTagList): boolean;
    procedure DownloadUpdates(items: TTagList; HTTP: TMyIdHTTP);
    property Job: Integer read FJob write FJob;
    property CheckURL: String read FCheckURL write FCheckURL;
    property ListURL: String read FListURL write FListURL;
    property Error: String read FString write FString;
    property MsgHWND: HWND read FHWND write FHWND;
    property IncSkins: Boolean read fIncSkins write fIncSkins;
  end;

implementation

{ function GetVersion(sFileName:string): string;
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
  end; }

procedure TUpdThread.IdHTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCountMax: Int64);
begin
  SendMessage(FHWND, CM_UPDATEPROGRESS, UPD_FILESIZE, AWorkCountMax);
end;

procedure TUpdThread.IdHTTPWork(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  SendMessage(FHWND, CM_UPDATEPROGRESS, UPD_FILEPROGRESS, AWorkCount);
end;

function TUpdThread.CheckUpdates(s: string; items: TTagList): boolean;
var
  xml: TMyXMLParser;
  // items: TTagList;
  INI: TINIFile;
  i, j, v: Integer;
  root, fname: string;
  deleted: boolean;
begin
  root := ExtractFilePath(paramstr(0));
  xml := TMyXMLParser.Create;
  xml.Parse(s);

  // items := TTagList.Create;
  if incSkins then
    xml.TagList.GetList(['item','skin'], [nil,nil], items)
  else
    xml.TagList.GetList('item', nil, items);

  if items.Count = 0 then
    raise Exception.Create
      ('Result of parsing VERSION.XML is ZERO. It can not be ZERO');

  INI := TINIFile.Create(root + 'settings.ini');

  // result := false;

  i := 0;
  j := 0;
  while i < items.Count do
  begin
    fname := items[i].Attrs.Value('file');
    v := INI.ReadInteger('update', fname, -1);
    deleted := items[i].Attrs.Value('deleted') = '1';
    if deleted then
      if (v > -1) then
        case FJob of
          UPD_CHECK_UPDATES:
            inc(i);
          UPD_DOWNLOAD_UPDATES:
            begin
              if fileexists(ExtractFilePath(paramstr(0)) + fname) then
                DeleteFile(ExtractFilePath(paramstr(0)) + fname);
              INI.DeleteKey('update', fname);
              items.Delete(i);
              SendMessage(FHWND, CM_UPDATEPROGRESS, UPD_FILEDELETED, LongInt(@fname));
            end
        end
      else
        items.Delete(i)
    else if (StrToInt(items[i].Attrs.Value('version')) > v)
    { or (StrToInt(items[i].Attrs.Value('version')) = -1) } then
      inc(i)
    else if (StrToInt(items[i].Attrs.Value('version')) = -1) then
    begin
      inc(i);
      dec(j);
    end
    else
      items.Delete(i);
  end;

  result := i + j > 0;

  INI.Free;
  // items.Free;
  xml.Free;
end;

procedure TUpdThread.DownloadUpdates(items: TTagList; HTTP: TMyIdHTTP);
var
  i, v1, v2: Integer;
  root: string;
  aroot: string;
  fname, aname, pname, o, dir: string;
  f: TFileStream;
  INI: TINIFile;
  z: tzipfile;
begin
  root := ExtractFilePath(paramstr(0));
  aroot := IncludeTrailingPathDelimiter(root + 'update');

  if not DirectoryExists(aroot) then
    CreateDirExt(aroot);

  INI := TINIFile.Create(aroot + 'update.ini');
  CoInitialize(nil);

  SendMessage(FHWND, CM_UPDATEPROGRESS, UPD_FILECOUNT, items.Count);

  HTTP.OnWorkBegin := IdHTTPWorkBegin;
  HTTP.OnWork := IdHTTPWork;

  try // downloading
    for i := 0 to items.Count - 1 do
    begin
      SendMessage(FHWND, CM_UPDATEPROGRESS, UPD_FILEPOS, i);
      fname := items[i].Attrs.Value('file');
      v1 := StrToInt(items[i].Attrs.Value('version'));
      v2 := INI.ReadInteger('update', fname, -1);

      aname := items[i].Attrs.Value('archive');

      if aname <> '' then
        pname := aname
      else
        pname := fname;

      if (v1 > -1) and (v2 >= v1) and (fileexists(aroot + aname)) then
        Continue;

      SendMessage(FHWND, CM_UPDATEPROGRESS, UPD_FILENAME, LongInt(@fname));

      o := FListURL + StringReplace(pname, '\', '/', [rfReplaceAll]);

      dir := ExtractFilePath(aroot + pname);

      if not DirectoryExists(dir) then
        CreateDirExt(dir);

      f := TFileStream.Create(aroot + pname, fmCREATE);
      try  try
          HTTP.Get(o, f);
        finally
          f.Free;
        end;
      except
        if fileexists(aroot + pname) then
          DeleteFile(aroot + pname);
        raise;
      end;

      if v1 > -1 then
        INI.WriteInteger('update', fname, v1); // save "DOWNLOADED"
    end;

    FreeAndNil(INI);

    INI := TINIFile.Create(root + 'settings.ini');

    for i := 0 to items.Count - 1 do // Moving files to main dir
    begin
      fname := items[i].Attrs.Value('file');
      aname := items[i].Attrs.Value('archive');
      v1 := StrToInt(items[i].Attrs.Value('version'));

      if fileexists(root + fname) then
        DeleteFile(root + fname)
      else
      begin
        dir := ExtractFilePath(root + fname);

        if not DirectoryExists(dir) then
          CreateDirExt(dir);
      end;

      if aname <> '' then
      begin
        SendMessage(FHWND, CM_UPDATEPROGRESS, UPD_FILEUNZIP, LongInt(@aname));
        z := tzipfile.Create; try
        z.ExtractZipFile(aroot + aname,root);
        finally
          z.Free;
        end;
        DeleteFile(aroot + aname);
      end
      else
        MoveFile(PWideChar(aroot + fname), PWideChar(root + fname));

      INI.WriteInteger('update', fname, v1);
    end;
  finally
    CoUninitialize;
    if Assigned(INI) then
      INI.Free;
    HTTP.OnWorkBegin := nil;
    HTTP.OnWork := nil;
  end;
end;

procedure TUpdThread.Execute;
var
  s: string;
  items: TTagList;
begin
  WaitForSingleObject(FEventHandle, INFINITE);
  FHTTP := TMyIdHTTP.Create;
  items := TTagList.Create;
  try
    FHTTP.ConnectTimeout := 10000;
    FHTTP.ReadTimeout := 10000;
    ReturnValue := -1;
    try
      try
        if FCheckURL <> '' then
          FHTTP.Get(FCheckURL);
      except
      end;
      s := FHTTP.Get(FListURL + 'version.xml');

      // checking critical parts
      if s = '' then
        raise Exception.Create('VERSION.XML is EMPTY. It can not be EMPTY');

      case Job of
        UPD_CHECK_UPDATES:
          if CheckUpdates(s, items) then
            ReturnValue := 1
          else
            ReturnValue := 2;
        UPD_DOWNLOAD_UPDATES:
          begin
            if CheckUpdates(s, items) then
            begin
              DownloadUpdates(items, FHTTP);
              ReturnValue := 1;
            end
            else
              ReturnValue := 2;
          end;
      end;
    except
      on e: Exception do
      begin
        ReturnValue := 0;
        FString := e.Message;
      end;
    end;
  finally
    items.Free;
    FHTTP.Free;
    SendMessage(FHWND, CM_UPDATE, ReturnValue, Integer(Self));
  end;
end;

end.
