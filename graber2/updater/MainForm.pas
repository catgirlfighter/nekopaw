unit MainForm;

interface

uses
  Messages, SysUtils, Dialogs, Forms, Windows,
  INIFiles, UPDUnit, ShellAPI, Classes, Controls, StdCtrls, ComCtrls, XPMan;

type
  Tmf = class(TForm)
    pttl: TProgressBar;
    pcurr: TProgressBar;
    bOk: TButton;
    lLog: TListBox;
    XPManifest1: TXPManifest;
    procedure FormCreate(Sender: TObject);
    procedure bOkClick(Sender: TObject);
  private
    UPDServ: String;
    fName: string;
    t: TUPDThread;
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
    0: lLog.Items.Add(t.Error);
    2: lLog.Items.Add('Nothing new');
    else
    begin
      pttl.Position := pttl.Max;
      lLog.Items.Add('Update finished');
    end;
  end;

  t.Free;
  bOk.Enabled := true;
end;

procedure tmf.UPDPROG(var Msg: TMessage);
var
  s: ^string;
begin
  case Msg.WParam of
    0:
    begin
      pttl.Max := Msg.LParam;
      pttl.Position := 0;
      lLog.Items.Add(IntToStr(pttl.Max) + ' new items');
    end;
    1: pttl.Position := Msg.LParam;
    2:
    begin
      pcurr.Max := Msg.LParam;
      pcurr.Position := 0;
    end;
    3:
    begin
      pcurr.Position := Msg.LParam;
      lLog.Items[lLog.Items.Count-1] := fname
        + ' (' + GetBTString(pcurr.Position) + '/'
        + GetBTString(pcurr.Max) + ')';
    end;
    4:
    begin
     s := Pointer(Msg.LParam);
     fname := s^;
     lLog.Items.Add(s^);
    end;
  end;
end;

procedure Tmf.bOkClick(Sender: TObject);
begin
  if FileExists(ExtractFilePath(paramstr(0)) + 'graber2.exe') then
  ShellExecute(Handle, 'open',PWidechar(ExtractFilePath(paramstr(0))
    + 'graber2.exe'), nil, nil, SW_SHOWNORMAL);

  Close;
end;

procedure Tmf.FormCreate(Sender: TObject);
begin
  LoadSettings;

  t := TUPDThread.Create;
  t.MsgHWND := Self.Handle;
  t.ListURL := UPDServ;
  t.Job := UPD_DOWNLOAD_UPDATES;
  t.FreeOnTerminate := false;
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
