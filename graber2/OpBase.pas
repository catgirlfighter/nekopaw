unit OpBase;

interface

uses Windows, SysUtils, Messages, GraberU, INIFiles, Classes, Common,
  MyHTTP, MyINIFile, Dialogs, Forms, Variants, UITypes;

var
  // FullResList: TResourceList;
  TagDump: TPictureTagList;
  GlobalSettings: TSettingsRec;
  IgnoreList, AddFields, BlackList: TDSArray;
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

procedure LoadProfileSettings(pname: string = ''); overload;
procedure LoadProfileSettings(ini: tINIFile); overload;

procedure SaveProfileSettings;
procedure LoadResourceSettings(const r: TResourceList); overload;
procedure LoadResourceSettings(const r: TResourceList;
  const ini: tINIFile); overload;
procedure SaveResourceSettings(r: TResource; AINI: tINIFile = nil;
  default: boolean = false); overload;
procedure SaveResourceSettings(r: TResourceList; AINI: tINIFile = nil);
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
procedure SetConSettings(r: TResourceList; list: boolean = true;
  pics: boolean = true);
procedure SaveFavResource(r: TResource; ini: tINIFile = nil);
procedure SaveCurrentProfile;

implementation

uses LangString, EncryptStrings, AES;

// var
// erclass: terrorclass;

procedure terrorclass.OnError(Sender: TObject; Msg: string);
begin
  MessageDLG('Error in initiation: ' + Msg, mtError, [mbOk], 0);
end;

procedure LoadResourceSettings(const r: TResourceList; const ini: tINIFile);
var
  i, j, n: integer;
  pref, s: string;
  rec: thttprec;
begin
  pref := 'resource-';
  n := r[0].Fields.Count;

  r[0].NameFormat := ini.ReadString('defaultresource', 'NameFormat',
    '$rootdir$\pics\$tag$\');

  for i := 1 to r.Count - 1 do
  begin
    if ini.ValueExists(pref + r[i].Name, 'Favorite') then
      r[i].Favorite := ini.ReadBool(pref + r[i].Name, 'Favorite', false);

    r[i].Inherit := ini.ReadBool(pref + r[i].Name, 'Inherit', true);
    if not r[i].Inherit then
    begin
      r[i].NameFormat := ini.ReadString(pref + r[i].Name, 'NameFormat', '');
    end;

    r[i].Fields['login'] := ini.ReadString(pref + r[i].Name, 'login', '');
    s := ini.ReadString(pref + r[i].Name, 'password', '');
    if s <> '' then
      r[i].Fields['password'] := trim(DecryptString(s, KeyString), #0);

    rec := r[i].HTTPRec;

    rec.StartCount := ini.ReadInteger(pref + r[i].Name, 'StartCount', 0);
    rec.MaxCount := ini.ReadInteger(pref + r[i].Name, 'MaxCount', 0);

    r[i].HTTPRec := rec;

    r[i].ThreadCounter.UseUserSettings := ini.ReadBool(pref + r[i].Name,
      'UseUserSettings', false);
    r[i].ThreadCounter.UserSettings.MaxThreadCount :=
      ini.ReadInteger(pref + r[i].Name, 'UserMaxThreadCount', 0);
    r[i].ThreadCounter.UserSettings.PageDelay :=
      ini.ReadInteger(pref + r[i].Name, 'UserPageDelay', 0);
    r[i].ThreadCounter.UserSettings.PicDelay :=
      ini.ReadInteger(pref + r[i].Name, 'UserPicDelay', 0);

    // h := r[i].HTTPRec;
    r[i].ThreadCounter.UseProxy := ini.ReadInteger(pref + r[i].Name,
      'UseProxy', -1);

    for j := n to r[i].Fields.Count - 1 do
      if r[i].Fields.Items[j].restype <> ftNone then
      begin
        r[i].Fields.Items[j].resvalue :=
          strnull(ini.ReadString(pref + r[i].Name, r[i].Fields.Items[j].resname,
          r[i].Fields.Items[j].resvalue));
      end;

  end;
end;

procedure LoadResourceSettings(const r: TResourceList);
var
  ini: tINIFile;
begin
  ini := tINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  try
    LoadResourceSettings(r, ini);
  finally
    ini.Free;
  end;
end;

procedure SaveResourceSettings(r: TResource; AINI: tINIFile = nil;
  default: boolean = false);
var
  j { ,n } : integer;
  rname, s: string;
  ini: tINIFile;
begin
  if Assigned(AINI) then
    ini := AINI
  else
    ini := tINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  try
    if default then
      rname := 'defaultresource'
    else
    begin
      rname := 'resource-' + r.Name;
      // INI.WriteBool(rname, 'Favorite', r.Favorite);
    end;
    ini.WriteBool(rname, 'Inherit', r.Inherit);

    if not r.Inherit then
    begin
      ini.WriteBool(rname, 'Inherit', r.Inherit);
      ini.WriteString(rname, 'NameFormat', r.NameFormat);
    end
    else
    begin
      ini.DeleteKey(rname, 'Inherit');
      ini.DeleteKey(rname, 'NameFormat');
    end;

    s := nullstr(r.Fields['login']);
    if s <> '' then
      ini.WriteString(rname, 'Login', '"' + s + '"')
    else
      ini.DeleteKey(rname, 'Login');

    s := nullstr(r.Fields['password']);
    if s <> '' then
      ini.WriteString(rname, 'Password', EncryptString(s, KeyString))
    else
      ini.DeleteKey(rname, 'Password');

    if default then // all default finished there
      Exit;

    if Assigned(r.ThreadCounter) then
    begin
      ini.WriteBool(rname, 'UseUserSettings', r.ThreadCounter.UseUserSettings);
      ini.WriteInteger(rname, 'UserMaxThreadCount',
        r.ThreadCounter.UserSettings.MaxThreadCount);
      ini.WriteInteger(rname, 'UserPageDelay',
        r.ThreadCounter.UserSettings.PageDelay);
      ini.WriteInteger(rname, 'UserPicDelay',
        r.ThreadCounter.UserSettings.PicDelay);
      ini.WriteInteger(rname, 'UseProxy', r.ThreadCounter.UseProxy);
    end;

    ini.WriteInteger(rname, 'StartCount', r.HTTPRec.StartCount);
    ini.WriteInteger(rname, 'MaxCount', r.HTTPRec.MaxCount);

    for j := 1 to r.Fields.Count - 1 do
      if not(r.Fields.Items[j].restype in [ftNone, ftMultiEdit]) then
      begin
        ini.WriteString(rname, r.Fields.Items[j].resname,
          '"' + vartostr(nullstr(r.Fields.Items[j].resvalue)) + '"');
      end;
  finally
    if not Assigned(AINI) then
      ini.Free;
  end;
end;

procedure SaveResourceSettings(r: TResourceList; AINI: tINIFile = nil);
var
  i: integer;
  ini: tINIFile;
begin
  if Assigned(AINI) then
    ini := AINI
  else
    ini := tINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  try
    for i := 0 to r.Count - 1 do
      if r[i].IsNew then
        SaveResourceSettings(r[i], AINI);
  finally
    if not Assigned(AINI) then
      ini.Free;
  end;
end;

procedure LoadProfileSettings(pname: string = '');
var
  ini: tINIFile;
  dlu: integer;
begin
  ini := tINIFile.Create(IncludeTrailingPathDelimiter(rootdir) +
    'settings.ini');
  try
    if pname = '' then
      profname := ini.ReadString('settings', 'profile', profname)
    else
      profname := pname;
    GlobalSettings.IncSkins := ini.ReadBool('settings', 'incskins', false);
    GlobalSettings.IsNew := ini.ReadBool('settings', 'isnew', false);
    if GlobalSettings.IsNew then
      ini.DeleteKey('settings', 'isnew');
    dlu := ini.ReadInteger('settings', 'delupd', 0);
    if dlu = 1 then
    begin
      while FileExists(IncludeTrailingPathDelimiter(rootdir) +
        'NPUpdater.exe') do
      begin
        DeleteFile(IncludeTrailingPathDelimiter(rootdir) + 'NPUpdater.exe');
        Application.ProcessMessages;
      end;
      ini.DeleteKey('settings', 'delupd');
    end;
  finally
    ini.Free;
  end;

  ini := tINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  try
    LoadProfileSettings(ini);
  finally
    ini.Free;
  end;
end;

procedure LoadProfileSettings(ini: tINIFile);
var
  v: TStringList;
  i: integer;
begin
  with GlobalSettings do
  begin
    // OneInstance := INI.ReadBool('global','oneinstance',true);

    // Trayicon := INI.ReadBool('GUI','trayicon',true);
    // HideToTray := INI.ReadBool('GUI','hidetotray',true);
    // SaveConfirm := INI.ReadBool('GUI','saveconfirm',true);

    AutoUPD := ini.ReadBool('settings', 'autoupd', true);
    ShowWhatsNew := ini.ReadBool('settings', 'showwhatsnew', true);
    UseLookAndFeel := ini.ReadBool('settings', 'uselookandfeel', false);
    SkinName := ini.ReadString('settings', 'skinname', '');
    UPDServ := ini.ReadString('settings', 'updserver',
      'https://raw.githubusercontent.com/catgirlfighter/nekopaw/master/release/graber2/');
    CHKServ := ini.ReadString('settings', 'updserver',
      'http://code.google.com/p/nekopaw/');
    langname := ini.ReadString('settings', 'language', '');
    MenuCaptions := ini.ReadBool('settings', 'menucaptions', false);
    Tips := ini.ReadBool('settings', 'tips', true);
    UseDist := ini.ReadBool('settings', 'dist', true);
    WriteEXIF := ini.ReadBool('Settings', 'WriteEXIF', false);
    UseBlackList := ini.ReadBool('Settings', 'UseBlackList', false);
    SemiJob := tSemiListJob(ini.ReadInteger('Settings', 'SemiJob', 0));
    GlobalSettings.UncheckBlacklisted := ini.ReadBool('Settings',
      'UncheckBlacklisted', true);
    GlobalSettings.StopSignalTimer := ini.ReadInteger('Settings',
      'StopSignalTimer', 0);

    ShowSettings := langname = '';

    if ShowSettings then
      langname := 'English';

    with GUI do
    begin
      NewListFavorites := ini.ReadBool('gui', 'NewListFavorites', true);
      NewListShowHint := ini.ReadBool('gui', 'NewListShowHint', true);
      FormWidth := ini.ReadInteger('gui', 'windowwidth', 610);
      FormHeight := ini.ReadInteger('gui', 'windowheight', 420);
      FormState := ini.ReadBool('gui', 'windowmaximized', false);
      PanelPage := ini.ReadInteger('gui', 'panelpage', 0);
      PanelWidth := ini.ReadInteger('gui', 'panelwidth', 185);
      LastUsedSet := ini.ReadString('gui', 'lastusedresourceset', '');
      LastUsedFields := ini.ReadString('gui', 'lastusedgridfields',
        '@resource,@label');
      LastUsedGrouping := ini.ReadString('gui', 'lastusedgridgrouping', '');
    end;

    with Downl do
    begin
      ThreadCount := ini.ReadInteger('download', 'threadcount', 1);
      Retries := ini.ReadInteger('download', 'retries', 5);
      UsePerRes := ini.ReadBool('download', 'useperresource', true);
      PerResThreads := ini.ReadInteger('download', 'perresourcethreadcount', 2);
      PicThreads := ini.ReadInteger('download', 'picturethreadcount', 1);
      // SDALF := INI.ReadBool('download', 'SDALF', false);
      AutoUncheckInvisible := ini.ReadBool('download',
        'AutoUncheckInvisible', false);
      Debug := false;
    end;

    idThrottler.BitsPerSec := ini.ReadInteger('download', 'Speed', 0);

    with Proxy do
    begin
      UseProxy := ini.ReadInteger('proxy', 'useproxy', 0);
      ptype := tProxyType(ini.ReadInteger('proxy', 'type', 0));
      Host := ini.ReadString('proxy', 'host', '');
      Port := ini.ReadInteger('proxy', 'port', 0);
      Auth := ini.ReadBool('proxy', 'authetication', false);
      Login := ini.ReadString('proxy', 'login', '');
      Password := ini.ReadString('proxy', 'password', '');
      if Password <> '' then
        Password := DecryptString(Password, KeyString);
      UsePac := ini.ReadBool('proxy', 'UsePAC', false);
      // PACFile := INI.ReadString('proxy','PACFile','');
      PACHost := ini.ReadString('proxy', 'PACHost', '');
    end;

    v := TStringList.Create;
    try
      ini.ReadSection('IgnoreList', v); // loading ignore "doubles" list

      if (v.Count = 0) and ShowSettings then
      begin
        SetLength(IgnoreList, 2);
        IgnoreList[0][0] := 'MD5 dublicates';
        IgnoreList[0][1] := 'md5=md5';
        IgnoreList[1][0] := 'URL dublicates';
        IgnoreList[1][1] := 'url=url';
      end
      else
      begin
        SetLength(IgnoreList, v.Count);
        for i := 0 to v.Count - 1 do
        begin
          IgnoreList[i][0] := v[i];
          IgnoreList[i][1] := ini.ReadString('ignorelist', v[i], '');
          { Checking old format }
          if pos('=', CopyTo(IgnoreList[i][1], ';', ['""'], [], false)) = 0 then
          begin
            IgnoreList[i][1] := IgnoreList[i][0] + '=' + IgnoreList[i][1];
            IgnoreList[i][0] := 'rule' + IntToStr(i + 1);
          end;

        end;
      end;

      ini.ReadSection('fields', v); // additional fields

      if v.Count = 0 then
      begin

      end
      else
      begin
        SetLength(AddFields, v.Count);

        for i := 0 to v.Count - 1 do
        begin
          AddFields[i][0] := v[i];
          AddFields[i][1] := ini.ReadString('fields', v[i], '');
        end;
      end;

      ini.ReadSection('blacklist', v); // black list

      if v.Count = 0 then
      begin

      end
      else
      begin
        SetLength(BlackList, v.Count);

        for i := 0 to v.Count - 1 do
        begin
          BlackList[i][0] := DeleteTo(v[i], '_');
          BlackList[i][1] := ini.ReadString('blacklist', v[i], '');
        end;
      end;

    finally
      v.Free;
    end;

  end;
end;

procedure SaveProfileSettings;
var
  ini: tINIFile;
  i: integer;

begin
  ini := tINIFile.Create(IncludeTrailingPathDelimiter(rootdir) +
    'settings.ini');
  try
    ini.WriteString('settings', 'profile', profname);
    ini.WriteBool('settings', 'incskins', GlobalSettings.IncSkins);
  finally
    ini.Free;
  end;

  ini := tINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);

  if not FileExists(ini.FileName) then
  begin
    with TStringStream.Create('[Settings]', TEncoding.Unicode) do
    begin
      SaveToFile(ini.FileName);
      Free;
    end;
  end;

  try
    with GlobalSettings do
    begin

      ini.WriteString('Settings', 'Language', langname);
      ini.WriteBool('Settings', 'AutoUPD', AutoUPD);
      // INI.WriteBool('Settings', 'IncSkins', IncSkins);
      ini.WriteBool('Settings', 'ShowWhatsNew', ShowWhatsNew);
      ini.WriteBool('Settings', 'UseLookAndFeel', UseLookAndFeel);
      ini.WriteString('Settings', 'SkinName', SkinName);
      ini.WriteBool('Settings', 'MenuCaptions', MenuCaptions);
      ini.WriteBool('Settings', 'Tips', Tips);
      ini.WriteBool('Settings', 'Dist', UseDist);
      ini.WriteBool('Settings', 'WriteEXIF', GlobalSettings.WriteEXIF);
      ini.WriteBool('Settings', 'UseBlackList', GlobalSettings.UseBlackList);
      ini.WriteInteger('Settings', 'SemiJob', integer(GlobalSettings.SemiJob));
      ini.WriteBool('Settings', 'UncheckBlacklisted',
        GlobalSettings.UncheckBlacklisted);
      ini.WriteInteger('Settings', 'StopSignalTimer',
        GlobalSettings.StopSignalTimer);

      with Downl do
      begin
        ini.WriteInteger('Download', 'ThreadCount', ThreadCount);
        ini.WriteInteger('Download', 'Retries', Retries);
        ini.WriteBool('Download', 'UsePerResource', UsePerRes);
        ini.WriteInteger('Download', 'PerResourceThreadCount', PerResThreads);
        ini.WriteInteger('Download', 'PictureThreadCount', PicThreads);
        ini.WriteBool('Download', 'AutoUncheckInvisible', AutoUncheckInvisible);
      end;

      ini.WriteInteger('Download', 'Speed', idThrottler.BitsPerSec);

      with Proxy do
      begin
        ini.WriteInteger('Proxy', 'UseProxy', UseProxy);
        ini.WriteInteger('Proxy', 'Type', integer(ptype));
        ini.WriteString('Proxy', 'Host', Host);
        ini.WriteInteger('Proxy', 'Port', Port);
        ini.WriteBool('Proxy', 'Authetication', Auth);
        ini.WriteString('Proxy', 'Login', Login);
        if Password <> '' then
          ini.WriteString('Proxy', 'Password', EncryptString(Password,
            KeyString))
        else
          ini.WriteString('Proxy', 'Password', '');

        ini.WriteBool('Proxy', 'UsePAC', UsePac);
        ini.WriteString('Proxy', 'PACHost', PACHost);
      end;

      ini.EraseSection('ignorelist');

      for i := 0 to length(IgnoreList) - 1 do
        ini.WriteString('IgnoreList', IgnoreList[i][0], IgnoreList[i][1]);

      ini.EraseSection('BlackList');

      for i := 0 to length(BlackList) - 1 do
        ini.WriteString('BlackList', IntToStr(i) + '_' + BlackList[i][0],
          BlackList[i][1]);

    end;
  finally
    ini.Free;
  end;
end;

procedure SaveGUISettings(values: tGUIValues);
var
  ini: tINIFile;

begin
  ini := tINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  try
    with GlobalSettings.GUI do
    begin
      if gvSizes in values then
      begin
        ini.WriteInteger('GUI', 'WindowWidth', FormWidth);
        ini.WriteInteger('GUI', 'WindowHeight', FormHeight);
        ini.WriteBool('GUI', 'WindowMaximized', FormState);
        ini.WriteInteger('GUI', 'PanelPage', PanelPage);
        ini.WriteInteger('GUI', 'PanelWidth', PanelWidth);
      end;
      if gvResSet in values then
        ini.WriteString('GUI', 'LastUsedResourceSet', LastUsedSet);
      ini.WriteBool('GUI', 'NewListFavorites', NewListFavorites);
      ini.WriteBool('GUI', 'NewListShowHint', NewListShowHint);
      if gvGridFields in values then
      begin
        ini.WriteString('GUI', 'LastUsedGridFields', LastUsedFields);
        ini.WriteString('GUI', 'LastUsedGridGrouping', LastUsedGrouping);
      end;
    end;
  finally
    ini.Free;
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
  ini: tINIFile;
  Items: TStringList;
  i: integer;
begin
  ini := tINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  try
    Items := TStringList.Create;
    try
      ini.ReadSection('pathlist', Items);
      for i := 0 to Items.Count - 1 do
        Items[i] := ini.ReadString('pathlist', Items[i], '');
      result := Items.Text;
    finally
      Items.Free;
    end;
  finally
    ini.Free;
  end;
end;

procedure SavePathList(list: TStrings);
var
  i: integer;
  ini: tINIFile;
begin
  ini := tINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  try
    for i := 0 to list.Count - 1 do
      ini.WriteString('pathlist', 'item' + IntToStr(i), list[i]);
  finally
    ini.Free;
  end;

end;

procedure LoadFavList(dest: TStrings);
var
  ini: tINIFile;
  // items: tstringlist;
  i: integer;
begin
  ini := tINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  try
    // items := tstringlist.Create;
    dest.Clear;
    // try
    ini.ReadSection('favtaglist', dest);
    for i := 0 to dest.Count - 1 do
      dest[i] := ini.ReadString('favtaglist', dest[i], '');
    // result := items.Text;
    // finally
    // items.Free;
    // end;
  finally
    ini.Free;
  end;
end;

procedure SaveFavList(src: TStrings);
var
  i: integer;
  ini: tINIFile;
begin
  ini := tINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);
  ini.EraseSection('favtaglist');
  try
    for i := 0 to src.Count - 1 do
      ini.WriteString('favtaglist', 'item' + IntToStr(i), src[i]);
  finally
    ini.Free;
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

procedure SetConSettings(r: TResourceList; list: boolean = true;
  pics: boolean = true);
var
  ps: tproxyrec;
  h: tMyIdHTTP;
  s: String;
begin
  ps := GlobalSettings.Proxy;

  if ps.UsePac and (length(ps.PACHost) > 0) and
    Assigned(r.ThreadHandler.PACParser) and
    (not r.ThreadHandler.PACParser.Initiated or r.ThreadHandler.PACParser.Reload)
  then
  begin
    h := CreateHTTP;
    try
      s := h.Get(ps.PACHost);
      r.ThreadHandler.PACParser.LoadScript(PANSIChar(ANSIString(s)));
    finally
      h.Free;
    end;
  end;

  if list then
  begin
    if GlobalSettings.Downl.UsePerRes then
      r.MaxThreadCount := GlobalSettings.Downl.PerResThreads
    else
      r.MaxThreadCount := 0;

    if GlobalSettings.Proxy.UseProxy in [0, 1, 2] then
      ps.UseProxy := GlobalSettings.Proxy.UseProxy
    else
      ps.UseProxy := 0;

    r.ThreadHandler.Proxy := ps;

    r.ThreadHandler.ThreadCount := GlobalSettings.Downl.ThreadCount;
    r.ThreadHandler.Retries := GlobalSettings.Downl.Retries;

    r.PictureList.IgnoreList := CopyDSArray(IgnoreList);
    r.PictureList.UseBlackList := GlobalSettings.UseBlackList;

    if r.PictureList.UseBlackList then
      r.PictureList.BlackList := CopyDSArray(BlackList);
  end;

  if pics then
  begin
    r.DWNLDHandler.Proxy := GlobalSettings.Proxy;

    if GlobalSettings.Proxy.UseProxy in [0, 1, 3] then
      ps.UseProxy := GlobalSettings.Proxy.UseProxy
    else
      ps.UseProxy := 0;

    r.DWNLDHandler.Proxy := ps;

    r.DWNLDHandler.ThreadCount := GlobalSettings.Downl.PicThreads;
    r.DWNLDHandler.Retries := GlobalSettings.Downl.Retries;

    r.UseDistribution := GlobalSettings.UseDist;
    r.WriteEXIF := GlobalSettings.WriteEXIF;
    r.UncheckBlacklisted := GlobalSettings.UncheckBlacklisted;
  end;

  if pics and list then
    r.LogMode := GLOBAL_LOGMODE;
end;

procedure SaveFavResource(r: TResource; ini: tINIFile = nil);
begin
  if not Assigned(ini) then
    ini := tINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + profname);

  try

    ini.WriteBool('resource-' + r.Name, 'Favorite', r.Favorite);

  finally
    if Assigned(ini) then
      ini.Free;
  end;

end;

procedure SaveCurrentProfile;
var
  ini: tINIFile;
begin
  ini := tINIFile.Create(IncludeTrailingPathDelimiter(rootdir) +
    'settings.ini');
  try
    ini.WriteString('settings', 'profile', profname);
    // INI.WriteBool('settings', 'incskins', GlobalSettings.IncSkins);
  finally
    ini.Free;
  end;
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

resources_dir := IncludeTrailingPathDelimiter(rootdir) + 'resources';

TagDump := TPictureTagList.Create;
if FileExists(IncludeTrailingPathDelimiter(rootdir) + 'tagdump.txt') then
  TagDump.LoadListFromFile(IncludeTrailingPathDelimiter(rootdir) +
    'tagdump.txt');

// LoadResourceSettings;

GlobalFavList := TStringList.Create;

LoadFavList(GlobalFavList);

finalization

ResourceGroupsList.Free;
GlobalFavList.Free;
// FullResList.Free;
TagDump.Free;
// erclass.Free;

end.
