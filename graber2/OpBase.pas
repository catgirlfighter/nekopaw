unit OpBase;

interface

uses SysUtils, Messages, GraberU, INIFiles;

var
  FullResList: TResourceList;
  GlobalSettings: TSettingsRec;
  rootdir: string;

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

procedure LoadGlobalSettings;

implementation

procedure LoadGlobalSettings;
var
  INI: TINIFile;
begin
  INI := TINIFile.Create(IncludeTrailingPathDelimiter(rootdir) + 'settings.ini');
  with GlobalSettings do
  begin
    OneInstance := INI.ReadBool('global','oneinstance',true);
    Trayicon := INI.ReadBool('GUI','trayicon',true);
    HideToTray := INI.ReadBool('GUI','hidetotray',true);
    SaveConfirm := INI.ReadBool('GUI','saveconfirm',true);

    with Downl do
    begin
      ThreadCount := INI.ReadInteger('download','threadcount',1);
      Retries := INI.ReadInteger('download','retires',5);
      Interval := INI.ReadInteger('download','interval',3);
      BeforeU := INI.ReadBool('download','beforeurl',true);
      BeforeP := INI.ReadBool('download','beforepicture',false);
      AfterP := INI.ReadBool('download','afterpicture',false);
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
    end;
  end;
  INI.Free;
end;

initialization

FullResList := TResourceList.Create;
rootdir := ExtractFileDir(paramstr(0));

LoadGlobalSettings;

finalization

FullResList.Free;

end.
