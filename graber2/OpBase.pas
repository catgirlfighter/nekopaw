unit OpBase;

interface

uses Windows, SysUtils, Messages, GraberU, INIFiles, Classes, Common,
  MyHTTP, MyINIFile, Dialogs, Forms, Variants;

var
  // FullResList: TResourceList;
  TagDump: TPictureTagList;
  GlobalSettings: TSettingsRec;
  IgnoreList, AddFields: TDSArray;
  GlobalFavList, ResourceGroupsList: TStringList;
  rootdir: string;
  profname: string = 'default.ini';
  langname: string = '';
  resources_dir: string;
  ShowSettings: boolean;

type
  terrorclass = class
  public
    procedure OnError(Sender: TObject; Msg: String);
  end;

  tGUIValue = (gvSizes, gvResSet, gvGridFields);
  tGUIValues = set of tGUIValue;

procedure LoadProfileSettings;
procedure SaveProfileSettings;
procedure LoadResourceSettings(r: TResourceList);
procedure SaveResourceSettings(r: TResource; AINI: TINIFile = nil;
  default: boolean = false); overload;
procedure SaveResourceSettings(r: TResourceList; AINI: TINIFile = nil);
  overload;
procedure SaveGUISettings(values: tGUIValues);
procedure FillDSArray(const a1: TDSArray; var a2: TDSArray);
function CopyDSArray(const a: TDSArray): TDSArray;
procedure DeleteDSArrayRec(var a: TDSArray; const index: integer);
procedure SaveTagDump;
function LoadPathList: String;
procedure SavePathList(list: TStrings);
procedure LoadFavList(dest: TStrings);
procedure SaveFavList(src: TStrings);

var
  GLOBAL_LOGMODE: boolean;

procedure SetLogMode(Value: boolean);
procedure SetConSettings(r: TResourceList);

implementation

uses LangString, EncryptStrings, AES;

// var
// erclass: terrorclass;

procedure terrorclass.OnError(Sender: TObject; Msg: string);
begin
  MessageDLG('Error in initiation: ' + Msg, mtError, [mbOk], 0);
end;

procedure LoadResourceSettings(r: TResourceList);
var
  i, j, n: integer;
  pref, s: string;
  INI: TINIFile;
begin
  INI := TINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  try
    pref := 'resource-';
    n := r[0].Fields.Count;

    r[0].NameFormat := INI.ReadString('defaultresource', 'NameFormat',
      '$rootdir$\pics\$tag$\');

    for i := 1 to r.Count - 1 do
    begin
      r[i].Inherit := INI.ReadBool(pref + r[i].Name, 'Inherit', true);
      if not r[i].Inherit then
      begin
        r[i].NameFormat := INI.ReadString(pref + r[i].Name, 'NameFormat', '');
      end;

      r[i].Fields['login'] := INI.ReadString(pref + r[i].Name, 'login', '');
      s := INI.ReadString(pref + r[i].Name, 'password', '');
      if s <> '' then
        r[i].Fields['password'] := trim(DecryptString(s, KeyString), #0);

      r[i].ThreadCounter.UseUserSettings := INI.ReadBool(pref + r[i].Name,
        'UseUserSettings', false);
      r[i].ThreadCounter.UserSettings.MaxThreadCount :=
        INI.ReadInteger(pref + r[i].Name, 'UserMaxThreadCount', 0);
      r[i].ThreadCounter.UserSettings.PageDelay :=
        INI.ReadInteger(pref + r[i].Name, 'UserPageDelay', 0);
      r[i].ThreadCounter.UserSettings.PicDelay :=
        INI.ReadInteger(pref + r[i].Name, 'UserPicDelay', 0);

      for j := n to r[i].Fields.Count - 1 do
        if r[i].Fields.Items[j].restype <> ftNone then
        begin
          r[i].Fields.Items[j].resvalue :=
            strnull(INI.ReadString(pref + r[i].Name,
            r[i].Fields.Items[j].resname, r[i].Fields.Items[j].resvalue));
        end;

    end;
  finally
    INI.Free;
  end;
end;

procedure SaveResourceSettings(r: TResource; AINI: TINIFile = nil;
  default: boolean = false);
var
  j { ,n } : integer;
  rname, s: string;
  INI: TINIFile;
begin
  if Assigned(AINI) then
    INI := AINI
  else
    INI := TINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  try
    if default then
      rname := 'defaultresource'
    else
      rname := 'resource-' + r.Name;
    INI.WriteBool(rname, 'Inherit', r.Inherit);

    if not r.Inherit then
    begin
      INI.WriteBool(rname, 'Inherit', r.Inherit);
      INI.WriteString(rname, 'NameFormat', r.NameFormat);
    end
    else
    begin
      INI.DeleteKey(rname, 'Inherit');
      INI.DeleteKey(rname, 'NameFormat');
    end;

    s := nullstr(r.Fields['login']);
    if s <> '' then
      INI.WriteString(rname, 'Login', '"' + s + '"')
    else
      INI.DeleteKey(rname, 'Login');

    s := nullstr(r.Fields['password']);
    if s <> '' then
      INI.WriteString(rname, 'Password', EncryptString(s, KeyString))
    else
      INI.DeleteKey(rname, 'Password');

    if Assigned(r.ThreadCounter) then
    begin
      INI.WriteBool(rname, 'UseUserSettings', r.ThreadCounter.UseUserSettings);
      INI.WriteInteger(rname, 'UserMaxThreadCount',
        r.ThreadCounter.UserSettings.MaxThreadCount);
      INI.WriteInteger(rname, 'UserPageDelay',
        r.ThreadCounter.UserSettings.PageDelay);
      INI.WriteInteger(rname, 'UserPicDelay',
        r.ThreadCounter.UserSettings.PicDelay);
    end;

    for j := 1 to r.Fields.Count - 1 do
      if not(r.Fields.Items[j].restype in [ftNone, ftMultiEdit]) then
      begin
        INI.WriteString(rname, r.Fields.Items[j].resname,
          '"' + vartostr(nullstr(r.Fields.Items[j].resvalue)) + '"');
      end;
  finally
    if not Assigned(AINI) then
      INI.Free;
  end;
end;

procedure SaveResourceSettings(r: TResourceList; AINI: TINIFile = nil);
var
  i: integer;
  INI: TINIFile;
begin
  if Assigned(AINI) then
    INI := AINI
  else
    INI := TINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  try
    for i := 0 to r.Count - 1 do
      SaveResourceSettings(r[i], AINI);
  finally
    if not Assigned(AINI) then
      INI.Free;
  end;
end;

procedure LoadProfileSettings;
var
  INI: TINIFile;
  i { ,j } : integer;
  v: TStringList;
  // s: string;
  dlu: integer;
begin
  INI := TINIFile.Create(IncludeTrailingPathDelimiter(rootdir) +
    'settings.ini');
  try
    profname := INI.ReadString('settings', 'profile', profname);
    GlobalSettings.IsNew := INI.ReadBool('settings', 'isnew', false);
    if GlobalSettings.IsNew then
      INI.DeleteKey('settings', 'isnew');
    dlu := INI.ReadInteger('settings', 'delupd', 0);
    if dlu = 1 then
    begin
      while FileExists(IncludeTrailingPathDelimiter(rootdir) +
        'NPUpdater.exe') do
      begin
        DeleteFile(IncludeTrailingPathDelimiter(rootdir) + 'NPUpdater.exe');
        Application.ProcessMessages;
      end;
      INI.DeleteKey('settings', 'delupd');
    end;
  finally
    INI.Free;
  end;

  INI := TINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  try
    with GlobalSettings do
    begin
      // OneInstance := INI.ReadBool('global','oneinstance',true);

      // Trayicon := INI.ReadBool('GUI','trayicon',true);
      // HideToTray := INI.ReadBool('GUI','hidetotray',true);
      // SaveConfirm := INI.ReadBool('GUI','saveconfirm',true);

      AutoUPD := INI.ReadBool('settings', 'autoupd', true);
      ShowWhatsNew := INI.ReadBool('settings', 'showwhatsnew', true);
      UseLookAndFeel := INI.ReadBool('settings', 'uselookandfeel', false);
      SkinName := INI.ReadString('settings', 'skinname', '');
      UPDServ := INI.ReadString('settings', 'updserver',
        'http://nekopaw.googlecode.com/svn/trunk/release/graber2/');
      CHKServ := INI.ReadString('settings', 'updserver',
        'http://nekopaw.googlecode.com/');
      langname := INI.ReadString('settings', 'language', '');
      MenuCaptions := INI.ReadBool('settings', 'menucaptions', false);
      Tips := INI.ReadBool('settings', 'tips', true);
      UseDist := INI.ReadBool('settings', 'dist', true);
      WriteEXIF := INI.ReadBool('Settings','WriteEXIF',false);

      ShowSettings := langname = '';

      if ShowSettings then
        langname := 'English';

      with GUI do
      begin
        FormWidth := INI.ReadInteger('gui', 'windowwidth', 610);
        FormHeight := INI.ReadInteger('gui', 'windowheight', 420);
        FormState := INI.ReadBool('gui', 'windowmaximized', false);
        PanelPage := INI.ReadInteger('gui', 'panelpage', 0);
        PanelWidth := INI.ReadInteger('gui', 'panelwidth', 185);
        LastUsedSet := INI.ReadString('gui', 'lastusedresourceset', '');
        LastUsedFields := INI.ReadString('gui', 'lastusedgridfields',
          '@resource,@label');
        LastUsedGrouping := INI.ReadString('gui', 'lastusedgridgrouping', '');
      end;

      with Downl do
      begin
        ThreadCount := INI.ReadInteger('download', 'threadcount', 1);
        Retries := INI.ReadInteger('download', 'retries', 5);
        UsePerRes := INI.ReadBool('download', 'useperresource', true);
        PerResThreads := INI.ReadInteger('download',
          'perresourcethreadcount', 2);
        PicThreads := INI.ReadInteger('download', 'picturethreadcount', 1);
        SDALF := INI.ReadBool('download', 'SDALF', false);
        AutoUncheckInvisible := INI.ReadBool('download',
          'AutoUncheckInvisible', false);
        Debug := false;
      end;

      idThrottler.BitsPerSec := INI.ReadInteger('download', 'Speed', 0);

      with Proxy do
      begin
        UseProxy := INI.ReadBool('proxy', 'useproxy', false);
        Host := INI.ReadString('proxy', 'host', '');
        Port := INI.ReadInteger('proxy', 'port', 0);
        Auth := INI.ReadBool('proxy', 'authetication', false);
        Login := INI.ReadString('proxy', 'login', '');
        Password := INI.ReadString('proxy', 'password', '');
        if Password <> '' then
          Password := DecryptString(Password, KeyString);
      end;

      v := TStringList.Create;
      try
        INI.ReadSection('IgnoreList', v);

        if (v.Count = 0) and ShowSettings then
        begin
          SetLength(IgnoreList, 1);
          IgnoreList[0][0] := 'md5Check';
          IgnoreList[0][1] := 'md5=md5';
        end
        else
        begin
          SetLength(IgnoreList, v.Count);
          for i := 0 to v.Count - 1 do
          begin
            IgnoreList[i][0] := v[i];
            IgnoreList[i][1] := INI.ReadString('ignorelist', v[i], '');
            { Checking old format }
            if pos('=', CopyTo(IgnoreList[i][1], ';', ['""'], [], false)
              ) = 0 then
            begin
              IgnoreList[i][1] := IgnoreList[i][0] + '=' + IgnoreList[i][1];
              IgnoreList[i][0] := 'rule' + IntToStr(i + 1);
            end;

          end;
        end;

        // v.Clear;
        INI.ReadSection('fields', v);

        if v.Count = 0 then
        begin

        end
        else
        begin
          SetLength(AddFields, v.Count);

          for i := 0 to v.Count - 1 do
          begin
            AddFields[i][0] := v[i];
            AddFields[i][1] := INI.ReadString('fields', v[i], '');
          end;
        end;

      finally
        v.Free;
      end;
      // LoadResourceSettings(INI);
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

  if not FileExists(INI.FileName) then
  begin
    with TStringStream.Create('[Settings]', TEncoding.Unicode) do
    begin
      SaveToFile(INI.FileName);
      Free;
    end;
  end;

  try
    with GlobalSettings do
    begin

      INI.WriteString('Settings', 'Language', langname);
      INI.WriteBool('Settings', 'AutoUPD', AutoUPD);
      INI.WriteBool('Settings', 'ShowWhatsNew', ShowWhatsNew);
      INI.WriteBool('Settings', 'UseLookAndFeel', UseLookAndFeel);
      INI.WriteString('Settings', 'SkinName', SkinName);
      INI.WriteBool('Settings', 'MenuCaptions', MenuCaptions);
      INI.WriteBool('Settings', 'Tips', Tips);
      INI.WriteBool('Settings', 'Dist', UseDist);
      INI.WriteBool('Settings','WriteEXIF',GlobalSettings.WriteEXIF);

      with Downl do
      begin
        INI.WriteInteger('Download', 'ThreadCount', ThreadCount);
        INI.WriteInteger('Download', 'Retries', Retries);
        INI.WriteBool('Download', 'UsePerResource', UsePerRes);
        INI.WriteInteger('Download', 'PerResourceThreadCount', PerResThreads);
        INI.WriteInteger('Download', 'PictureThreadCount', PicThreads);
        INI.WriteBool('Download', 'SDALF', SDALF);
        INI.WriteBool('Download', 'AutoUncheckInvisible', AutoUncheckInvisible);
      end;

      INI.WriteInteger('download', 'Speed', idThrottler.BitsPerSec);

      with Proxy do
      begin
        INI.WriteBool('Proxy', 'UseProxy', UseProxy);
        INI.WriteString('Proxy', 'Host', Host);
        INI.WriteInteger('Proxy', 'Port', Port);
        INI.WriteBool('Proxy', 'Authetication', Auth);
        INI.WriteString('Proxy', 'Login', Login);
        if Password <> '' then
          INI.WriteString('Proxy', 'Password', EncryptString(Password,
            KeyString))
        else
          INI.WriteString('Proxy', 'Password', Password);
      end;
      {
        with Formats do
        begin
        INI.WriteString('Formats','List',ListFormat);
        INI.WriteString('Formats','Picture',PicFormat);
        end;
      }
      INI.EraseSection('ignorelist');

      for i := 0 to length(IgnoreList) - 1 do
        INI.WriteString('IgnoreList', IgnoreList[i][0], IgnoreList[i][1]);

      // if Assigned(FullResList) then
      // SaveResourceSettings(INI);

    end;
  finally
    INI.Free;
  end;
end;

procedure SaveGUISettings(values: tGUIValues);
var
  INI: TINIFile;

begin
  INI := TINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  try
    with GlobalSettings.GUI do
    begin
      if gvSizes in values then
      begin
        INI.WriteInteger('GUI', 'WindowWidth', FormWidth);
        INI.WriteInteger('GUI', 'WindowHeight', FormHeight);
        INI.WriteBool('GUI', 'WindowMaximized', FormState);
        INI.WriteInteger('GUI', 'PanelPage', PanelPage);
        INI.WriteInteger('GUI', 'PanelWidth', PanelWidth);
      end;
      if gvResSet in values then
        INI.WriteString('GUI', 'LastUsedResourceSet', LastUsedSet);
      if gvGridFields in values then
      begin
        INI.WriteString('GUI', 'LastUsedGridFields', LastUsedFields);
        INI.WriteString('GUI', 'LastUsedGridGrouping', LastUsedGrouping);
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
  // result := nil;
  SetLength(a2, length(a1));
  for i := 0 to length(a1) - 1 do
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
  SetLength(result, length(a));
  for i := 0 to length(a) - 1 do
  begin
    result[i][0] := a[i][0];
    result[i][1] := a[i][1];
  end;
end;

procedure DeleteDSArrayRec(var a: TDSArray; const index: integer);
var
  i: integer;
begin
  for i := index + 1 to length(a) - 1 do
    a[i - 1] := a[i];

  SetLength(a, length(a) - 1);

end;

procedure SaveTagDump;
begin
  TagDump.SaveToFile(IncludeTrailingPathDelimiter(rootdir) + 'tagdump.txt');
end;

function LoadPathList: String;
var
  INI: TINIFile;
  Items: TStringList;
  i: integer;
begin
  INI := TINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  try
    Items := TStringList.Create;
    try
      INI.ReadSection('pathlist', Items);
      for i := 0 to Items.Count - 1 do
        Items[i] := INI.ReadString('pathlist', Items[i], '');
      result := Items.Text;
    finally
      Items.Free;
    end;
  finally
    INI.Free;
  end;
end;

procedure SavePathList(list: TStrings);
var
  i: integer;
  INI: TINIFile;
begin
  INI := TINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  try
    for i := 0 to list.Count - 1 do
      INI.WriteString('pathlist', 'item' + IntToStr(i), list[i]);
  finally
    INI.Free;
  end;

end;

procedure LoadFavList(dest: TStrings);
var
  INI: TINIFile;
  // items: tstringlist;
  i: integer;
begin
  INI := TINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  try
    // items := tstringlist.Create;
    dest.Clear;
    // try
    INI.ReadSection('favtaglist', dest);
    for i := 0 to dest.Count - 1 do
      dest[i] := INI.ReadString('favtaglist', dest[i], '');
    // result := items.Text;
    // finally
    // items.Free;
    // end;
  finally
    INI.Free;
  end;
end;

procedure SaveFavList(src: TStrings);
var
  i: integer;
  INI: TINIFile;
begin
  INI := TINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  INI.EraseSection('favtaglist');
  try
    for i := 0 to src.Count - 1 do
      INI.WriteString('favtaglist', 'item' + IntToStr(i), src[i]);
  finally
    INI.Free;
  end;
end;

procedure SetLogMode(Value: boolean);
var
  d: string;

begin
  if GLOBAL_LOGMODE <> Value then
  begin
    GLOBAL_LOGMODE := Value;

    if Value then
    begin
      d := ExtractFilePath(paramstr(0)) + 'log';
      if not DirectoryExists(d) then
        CreateDirExt(d);
    end;
  end;
end;

procedure SetConSettings(r: TResourceList);
begin
  if GlobalSettings.Downl.UsePerRes then
    r.MaxThreadCount := GlobalSettings.Downl.PerResThreads
  else
    r.MaxThreadCount := 0;

  r.ThreadHandler.Proxy := GlobalSettings.Proxy;
  r.ThreadHandler.ThreadCount := GlobalSettings.Downl.ThreadCount;
  r.ThreadHandler.Retries := GlobalSettings.Downl.Retries;

  r.DWNLDHandler.Proxy := GlobalSettings.Proxy;
  r.DWNLDHandler.ThreadCount := GlobalSettings.Downl.PicThreads;
  r.DWNLDHandler.Retries := GlobalSettings.Downl.Retries;
  r.PictureList.IgnoreList := CopyDSArray(IgnoreList);

  r.LogMode := GLOBAL_LOGMODE;
  r.UseDistribution := GlobalSettings.UseDist;
  r.WriteEXIF := GlobalSettings.WriteEXIF;
end;

initialization

// erclass := terrorclass.Create;

rootdir := ExtractFileDir(paramstr(0));

if FileExists(IncludeTrailingPathDelimiter(rootdir) + profname) then
  LoadProfileSettings
else
begin
  LoadProfileSettings;

  SaveProfileSettings;
end;

CreateLangINI(IncludeTrailingPathDelimiter(rootdir) +
  IncludeTrailingPathDelimiter('languages') + langname + '.ini');

// FullResList := TResourceList.Create;
// FullResList.OnError := erclass.OnError;
// FullResList.LoadList(IncludeTrailingPathDelimiter(rootdir) + 'resources');
resources_dir := IncludeTrailingPathDelimiter(rootdir) + 'resources';

TagDump := TPictureTagList.Create;
if FileExists(IncludeTrailingPathDelimiter(rootdir) + 'tagdump.txt') then
  TagDump.LoadListFromFile(IncludeTrailingPathDelimiter(rootdir) +
    'tagdump.txt');

// LoadResourceSettings;

GlobalFavList := TStringList.Create;

LoadFavList(GlobalFavList);

// LoadLang(IncludeTrailingPathDelimiter(rootdir)+IncludeTrailingPathDelimiter('languages')+langname+'.ini');

finalization

ResourceGroupsList.Free;
GlobalFavList.Free;
// FullResList.Free;
TagDump.Free;
// erclass.Free;

end.
