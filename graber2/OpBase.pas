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

procedure LoadResourceSettings;
var
  i,j,n: integer;
  pref,s: string;
  INI: TINIFile;
begin
  INI := TINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  try
    pref := 'resource-';
    n := FullResList[0].Fields.Count;

    FullResList[0].NameFormat := INI.ReadString('defaultresource','NameFormat','$rootdir$\pics\$tag$\$fname$.$ext$');

    for i := 1 to FullResList.Count -1 do
    begin
      FullResList[i].Inherit := INI.ReadBool(pref+FullResList[i].Name,'Inherit',true);
      if not FullResList[i].Inherit then
      begin
        FullResList[i].NameFormat := INI.ReadString(pref+FullResList[i].Name,'NameFormat','');
      end;

      FullResList[i].Fields['login'] := INI.ReadString(pref+FullResList[i].Name,'login','');
      s := INI.ReadString(pref+FullResList[i].Name,'password','');
      if s <> '' then
        FullResList[i].Fields['password'] := trim(DecryptString(s,KeyString),#0);

      for j := n to FullResList[i].Fields.Count-1 do
        if FullResList[i].Fields.Items[j].restype <> ftNone then
        begin
           FullResList[i].Fields.Items[j].resvalue :=
              strnull(INI.ReadString(pref+FullResList[i].Name,
              FullResList[i].Fields.Items[j].resname,
              FullResList[i].Fields.Items[j].resvalue));
        end;

    end;
  finally
    INI.Free;
  end;
end;

procedure SaveResourceSettings(AINI: TINIFile = nil);
var
  i,j,n: integer;
  pref,s: string;
  INI: TINIFile;
begin
  if Assigned(AINI) then
    INI := AINI
  else
    INI := TINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  try
    pref := 'resource-';
    n := FullResList[0].Fields.Count;

    INI.WriteString('defaultresource','NameFormat',FullResList[0].NameFormat);

    for i := 1 to FullResList.Count-1 do
    begin
      //if FullResList[n].Inherit then
      INI.WriteBool(pref+FullResList[i].Name,'Inherit',FullResList[i].Inherit);

      if not FullResList[i].Inherit then
      begin
        INI.WriteBool(pref+FullResList[i].Name,'Inherit',FullResList[i].Inherit);
        INI.WriteString(pref+FullResList[i].Name,'NameFormat',FullResList[i].NameFormat);
      end else
      begin
        INI.DeleteKey(pref+FullResList[i].Name,'Inherit');
        INI.DeleteKey(pref+FullResList[i].Name,'NameFormat');
      end;

      s := nullstr( FullResList[i].Fields['login']);
      if s<>'' then
        INI.WriteString(pref+FullResList[i].Name,'Login',s)
      else
        INI.DeleteKey(pref+FullResList[i].Name,'Login');

      s := nullstr(FullResList[i].Fields['password']);
      if s<>'' then
        INI.WriteString(pref+FullResList[i].Name,'Password',EncryptString(s,KeyString))
      else
        INI.DeleteKey(pref+FullResList[i].Name,'Password');

      for j := n to FullResList[i].Fields.Count-1 do
        if FullResList[i].Fields.Items[j].restype <> ftNone then
        begin
          INI.WriteString(pref+FullResList[i].Name,
            FullResList[i].Fields.Items[j].resname,
            nullstr(FullResList[i].Fields.Items[j].resvalue));
        end;
    end;
  finally
    if not Assigned(AINI) then
      INI.Free;
  end;
end;

procedure LoadProfileSettings;
var
  INI: TINIFile;
  i,j: integer;
  v: tstringlist;
  s: string;
  dlu: integer;
begin

  INI := TINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + 'settings.ini');
  try
    profname := INI.ReadString('settings','profile',profname);
    GlobalSettings.IsNew := INI.ReadBool('settings','isnew',false);
    if GlobalSettings.IsNew then
      INI.DeleteKey('settings','isnew');
    dlu := INI.ReadInteger('settings','delupd',0);
    if dlu = 1 then
    begin
      if FileExists(IncludeTrailingPathDelimiter(rootdir) + 'NPUpdater.exe') then
        DeleteFile(IncludeTrailingPathDelimiter(rootdir) + 'NPUpdater.exe');
      INI.DeleteKey('settings','delupd');
    end;
  finally
    INI.Free;
  end;

  INI := TINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  try
    with GlobalSettings do
    begin
      //OneInstance := INI.ReadBool('global','oneinstance',true);

      //Trayicon := INI.ReadBool('GUI','trayicon',true);
      //HideToTray := INI.ReadBool('GUI','hidetotray',true);
      //SaveConfirm := INI.ReadBool('GUI','saveconfirm',true);

      AutoUPD := INI.ReadBool('settings','autoupd',true);
      ShowWhatsNew := INI.ReadBool('settings','showwhatsnew',true);
      UseLookAndFeel := INI.ReadBool('settings','uselookandfeel',false);
      UPDServ := INI.ReadString('settings','updserver',
        'http://nekopaw.googlecode.com/svn/trunk/release/graber2/');
      langname := INI.ReadString('global','language',langname);

      with Downl do
      begin
        ThreadCount := INI.ReadInteger('download','threadcount',1);
        Retries := INI.ReadInteger('download','retires',5);
        UsePerRes := INI.ReadBool('download','useperresource',true);
        PerResThreads := INI.ReadInteger('download','perresourcethreadcount',2);
        PicThreads := INI.ReadInteger('download','picturethreadcount',1);
        SDALF := INI.ReadBool('download','SDALF',false);
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
  {
      with Formats do
      begin
        ListFormat := INI.ReadString('formats','list','$rootdir$\lists\$tag$.ngl');
        PicFormat := INI.ReadString('formats','picture','$rootdir$\pics\$rname$\$fname$.$ext$');
      end;
  }
      v := tstringlist.Create;
      try
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
      finally
        v.Free;
      end;
      //LoadResourceSettings(INI);
    end;
  finally
    INI.Free;
  end;
end;

procedure SaveProfileSettings;
var
  INI: TINIFile;

begin
  INI := TINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  try
    with GlobalSettings do
    begin

      INI.WriteString('Global','Language',langname);
      INI.WriteBool('Settings','autoUPD',AutoUPD);
      INI.WriteBool('Settings','ShowWhatsNew',ShowWhatsNew);
      INI.WriteBool('Settings','UseLookAndFeel',UseLookAndFeel);

      with Downl do
      begin
        INI.WriteInteger('Download','ThreadCount',ThreadCount);
        INI.WriteInteger('Download','Retires',Retries);
        INI.WriteBool('Download','UsePerResource',UsePerRes);
        INI.WriteInteger('Download','PerResourceThreadCount',PerResThreads);
        INI.WriteInteger('Download','PictureThreadCount',PicThreads);
        INI.WriteBool('download','SDALF',SDALF);
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
  {
      with Formats do
      begin
        INI.WriteString('Formats','List',ListFormat);
        INI.WriteString('Formats','Picture',PicFormat);
      end;
  }
      if Assigned(FullResList) then
        SaveResourceSettings(INI);

    end;
  finally
    INI.Free;
  end;
end;

initialization
rootdir := ExtractFileDir(paramstr(0));

if fileexists(IncludeTrailingPathDelimiter(rootdir) + profname) then
  LoadProfileSettings
else
begin
  LoadProfileSettings;
  SaveProfileSettings;
end;

CreateLangINI(IncludeTrailingPathDelimiter(rootdir)+IncludeTrailingPathDelimiter('languages')+langname+'.ini');

FullResList := TResourceList.Create;
FullResList.LoadList(rootdir + '\resources');

LoadResourceSettings;

//LoadLang(IncludeTrailingPathDelimiter(rootdir)+IncludeTrailingPathDelimiter('languages')+langname+'.ini');


finalization

FullResList.Free;

end.
