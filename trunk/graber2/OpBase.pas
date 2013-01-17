unit OpBase;

interface

uses Windows, SysUtils, Messages, GraberU, INIFiles, Classes, Common, MyHTTP;

var
  FullResList: TResourceList;
  TagDump: TPictureTagList;
  GlobalSettings: TSettingsRec;
  IgnoreList,AddFields: TDSArray;
  GlobalFavList: TStringList;
  rootdir: string;
  profname: string = 'default.ini';
  langname: string = '';
  ShowSettings: boolean;

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

type
  tGUIValue = (gvSizes,gvResSet,gvGridFields);
  tGUIValues = set of tGUIValue;

procedure LoadProfileSettings;
procedure SaveProfileSettings;
procedure SaveResourceSettings(AINI: TINIFile = nil);
procedure SaveGUISettings(values: tGUIValues);
procedure FillDSArray(const a1: TDSArray; var a2: TDSArray);
function CopyDSArray(const a: TDSArray): TDSArray;
procedure DeleteDSArrayRec(var a: TDSArray; const index: integer);
procedure SaveTagDump;
function LoadPathList: String;
procedure SavePathList(list: TStrings);
procedure LoadFavList(dest: TStrings);
procedure SaveFavList(src: tStrings);

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

    FullResList[0].NameFormat := INI.ReadString('defaultresource','NameFormat','$rootdir$\pics\$tag$\');

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
        if not(FullResList[i].Fields.Items[j].restype in [ftNone,ftMultiEdit]) then
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
  i{,j}: integer;
  v: tstringlist;
  //s: string;
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
      SkinName := INI.ReadString('settings','skinname','');
      UPDServ := INI.ReadString('settings','updserver',
        'http://nekopaw.googlecode.com/svn/trunk/release/graber2/');
      langname := INI.ReadString('settings','language','');
      MenuCaptions := INI.ReadBool('settings','menucaptions',false);

      ShowSettings := langname = '';

      if ShowSettings then
        langname := 'English';

      with GUI do
      begin
        FormWidth := INI.ReadInteger('gui','windowwidth',610);
        FormHeight := INI.ReadInteger('gui','windowheight',420);
        FormState := INI.ReadBool('gui','windowmaximized',false);
        PanelPage := INI.ReadInteger('gui','panelpage',0);
        PanelWidth := INI.ReadInteger('gui','panelwidth',185);
        LastUsedSet := INI.ReadString('gui','lastusedresourceset','');
        LastUsedFields := INI.ReadString('gui','lastusedgridfields','@resource,@label');
        LastUsedGrouping := INI.ReadString('gui','lastusedgridgrouping','');
      end;

      with Downl do
      begin
        ThreadCount := INI.ReadInteger('download','threadcount',1);
        Retries := INI.ReadInteger('download','retries',5);
        UsePerRes := INI.ReadBool('download','useperresource',true);
        PerResThreads := INI.ReadInteger('download','perresourcethreadcount',2);
        PicThreads := INI.ReadInteger('download','picturethreadcount',1);
        SDALF := INI.ReadBool('download','SDALF',false);
        AutoUncheckInvisible := INI.ReadBool('download','AutoUncheckInvisible',false);
        Debug := false;
      end;

      idThrottler.BitsPerSec := INI.ReadInteger('download','Speed',0);

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

      v := tstringlist.Create;
      try
        INI.ReadSection('IgnoreList',v);

        if (v.Count = 0) and ShowSettings then
        begin
          SetLength(IgnoreList,1);
          IgnoreList[0][0] := 'md5Check';
          IgnoreList[0][1] := 'md5=md5';
        end else
        begin
          SetLength(IgnoreList,v.Count);
          for i := 0 to v.Count-1 do
          begin
            IgnoreList[i][0] := v[i];
            IgnoreList[i][1] := INI.ReadString('ignorelist',v[i],'');
            {Checking old format}
            if pos('=',CopyTo(IgnoreList[i][1],';',['""'],[],false)) = 0 then
            begin
              IgnoreList[i][1] := IgnoreList[i][0] + '=' +
                                  IgnoreList[i][1];
              IgnoreList[i][0] := 'rule' + IntToStr(i + 1);
            end;

          end;
        end;

        //v.Clear;
        INI.ReadSection('fields',v);

        if v.Count = 0 then
        begin

        end else
        begin
          SetLength(AddFields,v.Count);

          for i := 0 to v.Count-1 do
          begin
            AddFields[i][0] := v[i];
            AddFields[i][1] := INI.ReadString('fields',v[i],'');
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
  i: integer;

begin
  INI := TINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  try
    with GlobalSettings do
    begin

      INI.WriteString('Settings','Language',langname);
      INI.WriteBool('Settings','autoUPD',AutoUPD);
      INI.WriteBool('Settings','ShowWhatsNew',ShowWhatsNew);
      INI.WriteBool('Settings','UseLookAndFeel',UseLookAndFeel);
      INI.WriteString('Settings','SkinName',SkinName);
      INI.WriteBool('settings','menucaptions',MenuCaptions);

      with Downl do
      begin
        INI.WriteInteger('Download','ThreadCount',ThreadCount);
        INI.WriteInteger('Download','Retries',Retries);
        INI.WriteBool('Download','UsePerResource',UsePerRes);
        INI.WriteInteger('Download','PerResourceThreadCount',PerResThreads);
        INI.WriteInteger('Download','PictureThreadCount',PicThreads);
        INI.WriteBool('download','SDALF',SDALF);
        INI.WriteBool('download','AutoUncheckInvisible',AutoUncheckInvisible);
      end;

      INI.WriteInteger('download','Speed',idThrottler.BitsPerSec);

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
      INI.EraseSection('ignorelist');

      for i := 0 to length(ignorelist)-1 do
        INI.WriteString('IgnoreList',IgnoreList[i][0],IgnoreList[i][1]);

      if Assigned(FullResList) then
        SaveResourceSettings(INI);

    end;
  finally
    INI.Free;
  end;
end;

procedure SaveGUISettings(Values: tGUIValues);
var
  INI: TINIFile;

begin
  INI := TINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  try
    with GlobalSettings.GUI do
    begin
      if gvSizes in Values then
      begin
        INI.WriteInteger('GUI','WindowWidth',FormWidth);
        INI.WriteInteger('GUI','WindowHeight',FormHeight);
        INI.WriteBool('GUI','WindowMaximized',FormState);
        INI.WriteInteger('GUI','PanelPage',PanelPage);
        INI.WriteInteger('GUI','PanelWidth',PanelWidth);
      end;
      if gvResSet in Values then
        INI.WriteString('GUI','LastUsedResourceSet',LastUsedSet);
      if gvGridFields in Values then
      begin
        INI.WriteString('GUI','LastUsedGridFields',LastUsedFields);
        INI.WriteString('GUI','LastUsedGridGrouping',LastUsedGrouping);
      end;
    end;
  finally
    INI.Free;
  end;
end;

procedure FillDSArray(const a1: TDSArray; var a2: TDSArray);
var
  i: integer;
begin
  //result := nil;
  SetLength(a2,length(a1));
  for i := 0 to length(a1)-1 do
  begin
    a2[i][0] := a1[i][0];
    a2[i][1] := a1[i][1];
  end;
end;

function CopyDSArray(const a: TDSArray): TDSArray;
var
  i: integer;
begin
  result := nil;
  SetLength(result,length(a));
  for i := 0 to length(a)-1 do
  begin
    result[i][0] := a[i][0];
    result[i][1] := a[i][1];
  end;
end;

procedure DeleteDSArrayRec(var a: TDSArray; const index: integer);
var
  i: integer;
begin
  for i := index + 1 to length(a)-1 do
    a[i-1] := a[i];

  SetLength(a,length(a)-1);

end;


procedure SaveTagDump;
begin
    TagDump.SaveToFile(IncludeTrailingPathDelimiter(rootdir) + 'tagdump.txt');
end;

function LoadPathList: String;
var
  INI: TINIFile;
  items: tstringlist;
  i: integer;
begin
  INI := TINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  try
    items := tstringlist.Create;
    try
      INI.ReadSection('pathlist',items);
      for i := 0 to items.Count-1 do
        items[i] := INI.ReadString('pathlist',items[i],'');
      result := items.Text;
    finally
      items.Free;
    end;
  finally
    INI.Free;
  end;
end;

procedure SavePathList(list: TStrings);
var
  i: integer;
  ini: tinifile;
begin
  ini := tinifile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  try
    for i := 0 to list.Count-1 do
      ini.WriteString('pathlist','item'+IntToStr(i),list[i]);
  finally
    ini.Free;
  end;

end;

procedure LoadFavList(dest: TStrings);
var
  INI: TINIFile;
  //items: tstringlist;
  i: integer;
begin
  INI := TINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  try
  //  items := tstringlist.Create;
    dest.Clear;
  //  try
      INI.ReadSection('favtaglist',dest);
      for i := 0 to dest.Count-1 do
        dest[i] := INI.ReadString('favtaglist',dest[i],'');
  //   result := items.Text;
  //  finally
  //    items.Free;
  //  end;
  finally
    INI.Free;
  end;
end;

procedure SaveFavList(src: tStrings);
var
  i: integer;
  ini: tinifile;
begin
  ini := tinifile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  ini.EraseSection('favtaglist');
  try
    for i := 0 to src.Count-1 do
      ini.WriteString('favtaglist','item'+IntToStr(i),src[i]);
  finally
    ini.Free;
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
FullResList.LoadList(IncludeTrailingPathDelimiter(rootdir) + 'resources');

TagDump := TPictureTagList.Create;
if FileExists(IncludeTrailingPathDelimiter(rootdir) + 'tagdump.txt') then
  TagDump.LoadListFromFile(IncludeTrailingPathDelimiter(rootdir) + 'tagdump.txt');

LoadResourceSettings;

GlobalFavList := TStringlist.Create;

LoadFavList(GlobalFavlist);

//LoadLang(IncludeTrailingPathDelimiter(rootdir)+IncludeTrailingPathDelimiter('languages')+langname+'.ini');


finalization

GlobalFavList.Free;
FullResList.Free;
TagDump.Free;

end.
