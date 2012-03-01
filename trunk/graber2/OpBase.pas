unit OpBase;

interface

uses Windows, SysUtils, Messages, GraberU, INIFiles, Classes, Common;

var
  FullResList: TResourceList;
  GlobalSettings: TSettingsRec;
  IgnoreList: TDSArray;
  rootdir: string;
  profname: string = 'default.ini';
  langname: string = 'English';

{  TProxyRec = record
    UseProxy: boolean;
    Host: string;
    Port: longint;
    Auth: boolean;
    Login: string;
    Password: string;
    SavePWD: boolean;
  end;

  TDownloadRec = record
    ThreadCount: integer;
    Retries: integer;
    Interval: integer;
    BeforeU: boolean;
    BeforeP: boolean;
    AfterP: boolean;
    Debug: boolean;
  end;

  TSettingsRec = record
    Proxy: TProxyRec;
    Downl: TDownloadRec;
    OneInstance: boolean;
    TrayIcon: boolean;
    HideToTray: boolean;
    SaveConfirm: boolean;
  end;}

procedure LoadProfileSettings;
procedure SaveProfileSettings;

implementation

uses LangString, EncryptStrings, AES;

procedure LoadProfileSettings;
var
  INI: TINIFile;
  i,j: integer;
  v: tstringlist;
  s: string;
  dlu: integer;
begin

  INI := TINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + 'settings.ini');
  profname := INI.ReadString('settings','profile',profname);
  GlobalSettings.UPDServ := INI.ReadString('settings','updserver',
    'http://nekopaw.googlecode.com/svn/trunk/release/graber2/');
  dlu := INI.ReadInteger('settings','delupd',0);
  if dlu = 1 then
  begin
    if FileExists(IncludeTrailingPathDelimiter(rootdir) + 'NPUpdater.exe') then
      DeleteFile(IncludeTrailingPathDelimiter(rootdir) + 'NPUpdater.exe');
    INI.DeleteKey('settings','delupd');
  end;

  INI.Free;

  INI := TINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);

  with GlobalSettings do
  begin
    //OneInstance := INI.ReadBool('global','oneinstance',true);

    //Trayicon := INI.ReadBool('GUI','trayicon',true);
    //HideToTray := INI.ReadBool('GUI','hidetotray',true);
    //SaveConfirm := INI.ReadBool('GUI','saveconfirm',true);

    langname := INI.ReadString('global','language',langname);

    with Downl do
    begin
      ThreadCount := INI.ReadInteger('download','threadcount',1);
      Retries := INI.ReadInteger('download','retires',5);
      UsePerRes := INI.ReadBool('download','useperresource',true);
      PerResThreads := INI.ReadInteger('download','perresourcethreadcount',2);
      PicThreads := INI.ReadInteger('download','picturethreadcount',1);
      Debug := false;
    end;

    with Proxy do
    begin
      UseProxy := INI.ReadBool('proxy','useproxy',false);
      Host := INI.ReadString('proxy','host','');
      Port := INI.ReadInteger('proxy','port',0);
      Auth := INI.ReadBool('proxy','authetication',false);
      Login := INI.ReadString('proxy','login','');
      Password := INI.ReadString('proxy','password','');
      if Password <> '' then
        Password := DecryptString(Password,KeyString);
    end;

    with Formats do
    begin
      ListFormat := INI.ReadString('formats','list','$rootdir$\lists\$tag$.ngl');
      PicFormat := INI.ReadString('formats','picture','$rootdir$\pics\$rname$\$fname$.$ext$');
    end;

    v := tstringlist.Create;
    INI.ReadSection('IgnoreList',v);
    j := 0;
    for i := 0 to v.Count-1 do
    begin
      s := INI.ReadString('IgnoreList',v[i],'');
      while s <> '' do
      begin
        inc(j);
        SetLength(IgnoreList,j);
        IgnoreList[j-1][0] := v[i];
        IgnoreList[j-1][1] := CopyTo(s,',',[],true);
      end;
    end;


    v.Free;
  end;
  INI.Free;
end;

procedure SaveProfileSettings;
var
  INI: TINIFile;

begin
  INI := TINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  with GlobalSettings do
  begin

    INI.WriteString('Global','Language',langname);

    with Downl do
    begin
      INI.WriteInteger('Download','ThreadCount',ThreadCount);
      INI.WriteInteger('Download','Retires',Retries);
      INI.WriteBool('Download','UsePerResource',UsePerRes);
      INI.WriteInteger('Download','PerResourceThreadCount',PerResThreads);
      INI.WriteInteger('Download','PictureThreadCount',PicThreads);
    end;

    with Proxy do
    begin
      INI.WriteBool('Proxy','UseProxy',UseProxy);
      INI.WriteString('Proxy','Host',Host);
      INI.WriteInteger('Proxy','Port',Port);
      INI.WriteBool('Proxy','Authetication',Auth);
      INI.WriteString('Proxy','Login',Login);
      if Password <> '' then
        INI.WriteString('Proxy','Password',EncryptString(Password,KeyString))
      else
        INI.WriteString('Proxy','Password',Password);
    end;

    with Formats do
    begin
      INI.WriteString('Formats','List',ListFormat);
      INI.WriteString('Formats','Picture',PicFormat);
    end;

  end;
  INI.Free;
end;

initialization

FullResList := TResourceList.Create;
rootdir := ExtractFileDir(paramstr(0));

if fileexists(IncludeTrailingPathDelimiter(rootdir) + profname) then
  LoadProfileSettings
else
begin
  LoadProfileSettings;
  SaveProfileSettings;
end;

LoadLang(IncludeTrailingPathDelimiter(rootdir)+IncludeTrailingPathDelimiter('languages')+langname+'.ini');

finalization

FullResList.Free;

end.
