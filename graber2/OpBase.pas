unit OpBase;

interface

uses SysUtils, Messages, GraberU;

const
  UNIQUE_ID = 'GRABER2LOCK';

  CM_EXPROW = WM_USER + 1;
  CM_NEWLIST = WM_USER + 2;
  CM_APPLYNEWLIST = WM_USER + 3;
  CM_CANCELNEWLIST = WM_USER + 4;
  CM_EDITLIST = WM_USER + 5;
  CM_APPLYEDITLIST = WM_USER + 6;
  CM_CLOSETAB = WM_USER + 7;
  CM_SHOWSETTINGS = WM_USER + 8;
  CM_APPLYSETTINGS = WM_USER + 9;
  CM_CANCELSETTINGS = WM_USER + 10;

  SAVEFILE_VERSION = 0;

type

  TProxyRec = record
    UseProxy: boolean;
    Host: string;
    Port: longint;
    Auth: boolean;
    Login: string;
    Password: string;
    SavePWD: Boolean;
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
    OneInstance: Boolean;
    TrayIcon: Boolean;
    HideToTray: Boolean;
    SaveConfirm: Boolean;
  end;

var
  FullResList: TResourceList;
  GlobalSettings: TSettingsRec;
  rootdir: string;

implementation

initialization

  FullResList := TResourceList.Create;
  rootdir := ExtractFileDir(paramstr(0));

finalization

  FullResList.Free;

end.
