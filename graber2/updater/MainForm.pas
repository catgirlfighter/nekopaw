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
    CHKServ: String;
    fName: string;
    t: TUPDThread;
    IncSkins: Boolean;
    { Private declarations }
  protected
    procedure UPDCHECK(var Msg: TMessage); message CM_UPDATE;
    procedure UPDPROG(var Msg: TMessage); message CM_UPDATEPROGRESS;
  public
    procedure LoadSettings;
    procedure ProgressDone;
    { Public declarations }
  end;

var
  mf: Tmf;

implementation

uses common;

{$R *.dfm}

procedure Tmf.UPDCHECK(var Msg: TMessage);
begin
  case Msg.WParam of
    0:
      begin
        lLog.Items.Add(t.Error);
        MessageDlg('Update finished with error', mtError, [mbok], 0);
      end;
    2:
      lLog.Items.Add('Nothing new');
  else
    begin
      pttl.Position := pttl.Max;
      lLog.Items.Add('Update finished');
      ProgressDone;
      //LoadLibrary('');
    end;
  end;
  // t.Free;
  lLog.ItemIndex := lLog.Items.Count - 1;
  bOk.Enabled := true;
end;

procedure Tmf.UPDPROG(var Msg: TMessage);
var
  s: ^string;
begin
  case Msg.WParam of
    UPD_FILECOUNT:
      begin
        pttl.Max := Msg.LParam;
        pttl.Position := 0;
        lLog.Items.Add(IntToStr(pttl.Max) + ' new items');
      end;
    UPD_FILEPOS:
      pttl.Position := Msg.LParam;
    UPD_FILESIZE:
      begin
        pcurr.Max := Msg.LParam;
        pcurr.Position := 0;
      end;
    UPD_FILEPROGRESS:
      begin
        pcurr.Position := Msg.LParam;
        lLog.Items[lLog.Items.Count - 1] := fName + ' (' +
          GetBTString(pcurr.Position) + '/' + GetBTString(pcurr.Max) + ')';
      end;
    UPD_FILENAME:
      begin
        s := Pointer(Msg.LParam);
        fName := s^;
        lLog.ItemIndex := lLog.Items.Add(s^);
      end;
    UPD_FILEDELETED:
      begin
        s := Pointer(Msg.LParam);
        fName := s^;
        lLog.ItemIndex := lLog.Items.Add(s^ + ' deleted');
      end;
    UPD_FILEUNZIP:
      begin
        s := Pointer(Msg.LParam);
        fName := s^;
        lLog.ItemIndex := lLog.Items.Add(s^ + ' extracting');
      end;
    UPD_DWDONE:
      begin
        lLog.Items.Add('------------');
      end;
  end;
end;

procedure Tmf.bOkClick(Sender: TObject);
begin
  if FileExists(ExtractFilePath(paramstr(0)) + 'graber2.exe') then
    ShellExecute(Handle, 'open', PWidechar(ExtractFilePath(paramstr(0)) +
      'graber2.exe'), nil, nil, SW_SHOWNORMAL);

  Close;
end;

procedure Tmf.FormCreate(Sender: TObject);
begin
  LoadSettings;

  t := TUPDThread.Create;
  t.MsgHWND := Self.Handle;
  t.IncSkins := IncSkins;
  t.ListURL := UPDServ;
  t.CheckURL := CHKServ;
  t.Job := UPD_DOWNLOAD_UPDATES;
  t.FreeOnTerminate := true;
  SetEvent(t.Event);
end;

procedure Tmf.LoadSettings;
var
  INI: TINIFile;
begin
  INI := TINIFile.Create(ExtractFilePath(paramstr(0)) + 'settings.ini');
  IncSkins := INI.ReadBool('settings', 'incskins', false);
  UPDServ := INI.ReadString('settings', 'updserver',
    'http://nekopaw.googlecode.com/svn/trunk/release/graber2/');
  CHKServ := INI.ReadString('settings', 'chkserver',
    'http://code.google.com/p/nekopaw/');
  INI.WriteInteger('settings', 'delupd', 1);
  INI.Free;
end;

procedure Tmf.ProgressDone;
var
  INI: TINIFile;
begin
  INI := TINIFile.Create(ExtractFilePath(paramstr(0)) + 'settings.ini');
  INI.WriteBool('settings', 'IsNew', true);
  INI.Free;
end;

end.
