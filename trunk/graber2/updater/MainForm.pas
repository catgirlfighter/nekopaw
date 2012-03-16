unit MainForm;

interface

uses
  Messages, SysUtils, Dialogs, Forms, Windows,
  INIFiles, UPDUnit, ShellAPI, Classes, Controls, StdCtrls,
  Gauges;

type
  Tmf = class(TForm)
    gttl: TGauge;
    gfile: TGauge;
    ltext: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    UPDServ: String;
    fName: string;
    { Private declarations }
  protected
    procedure UPDCHECK(var Msg: TMessage); message CM_UPDATE;
    procedure UPDPROG(var Msg: TMessage); message CM_UPDATEPROGRESS;
  public
    procedure LoadSettings;
    { Public declarations }
  end;

var
  mf: Tmf;

implementation

uses common;

{$R *.dfm}

procedure tmf.UPDCHECK(var Msg: TMessage);
begin
  case Msg.WParam of
    0: MessageDlg('Download error',mtError,[mbOk],0);
  end;

  if FileExists(ExtractFilePath(paramstr(0)) + 'graber2.exe') then
  ShellExecute(Handle, 'open',PWidechar(ExtractFilePath(paramstr(0))
    + 'graber2.exe'), nil, nil, SW_SHOWNORMAL);

  Close;
  //ShowMessage('Finished');
end;

procedure tmf.UPDPROG(var Msg: TMessage);
var
  s: ^string;
begin
  case Msg.WParam of
    0:
    begin
      gttl.MaxValue := Msg.LParam;
      gttl.Progress := 0;
    end;
    1: gttl.Progress := Msg.LParam;
    2:
    begin
      gfile.MaxValue := Msg.LParam;
      gfile.Progress := 0;
    end;
    3:
    begin
      gfile.Progress := Msg.LParam;
      ltext.Caption := fname + ' (' + GetBTString(gfile.Progress) + '/'
        + GetBTString(gfile.MaxValue) + ') '
        + IntToStr(gttl.Progress) + '/' + IntToStr(gttl.MaxValue)
    end;
    4:
    begin
     s := Pointer(Msg.LParam);
     fname := s^;
     ltext.Caption := s^;
    end;
  end;
end;

procedure Tmf.FormCreate(Sender: TObject);
var
  t: TUPDThread;
begin
  LoadSettings;

  t := TUPDThread.Create;
  t.MsgHWND := Self.Handle;
  t.ListURL := UPDServ;
  t.Job := UPD_DOWNLOAD_UPDATES;
  t.FreeOnTerminate := true;
  SetEvent(t.Event);
end;

procedure Tmf.LoadSettings;
var
  INI: TINIFile;
begin
  INI := TINIFIle.Create(extractfilepath(paramstr(0)) + 'settings.ini');
  UPDServ := INI.ReadString('settings','updserver',
    'http://nekopaw.googlecode.com/svn/trunk/release/graber2/');
  INI.WriteInteger('settings','delupd',1);
  INI.Free;
end;

end.
