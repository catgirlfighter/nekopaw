unit MainForm;

interface

uses
  {base}
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ActnList, ExtCtrls,
  {devex}
  dxDockControl, dxDockPanel, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinscxPCPainter,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxDBData,
  cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, dxSkinsdxDockControlPainter,
  cxCheckBox, cxTextEdit, cxPC, dxBar, dxBarExtItems, cxContainer,
  cxMemo,
  {graber2}
  common, OpBase;

type

  TmycxOnGetExpandable = procedure(MasterDataRow: TcxGridMasterDataRow;
    var Expandable: Boolean) of object;

  TmycxGridTableView = class(TcxGridTableView)
  private
  protected
    function GetViewDataClass: TcxCustomGridViewDataClass; override;
  public
    OnGetExpandable: TmycxOnGetExpandable;
    constructor Create(AOwner: TComponent); override;
  end;

  TmycxGridViewData = class(TcxGridViewData)
  protected
    function GetRecordClass(ARecordInfo: TcxRowInfo)
      : TcxCustomGridRecordClass; override;
  end;

  TmycxGridMasterDataRow = class(TcxGridMasterDataRow)
  protected
    function GetExpandable: Boolean; override;
  end;

  TmfState = (msStart, msNewList, msGrid, msSettings);

  Tmf = class(TForm)
    ActionList: TActionList;
    aLLoad: TAction;
    aSettings: TAction;
    aIAdvanced: TAction;
    aISimple: TAction;
    aLApplyNew: TAction;
    aLCancel: TAction;
    aStart: TAction;
    ds: TdxDockSite;
    DockManager: TdxDockingManager;
    BarManager: TdxBarManager;
    bmbMain: TdxBar;
    dxBarButton1: TdxBarButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure gLevel2GetGridView(Sender: TcxGridLevel;
      AMasterRecord: TcxCustomGridRecord; var AGridView: TcxCustomGridView);
    procedure aStartExecute(Sender: TObject);
    procedure dpGridCloseQuery(Sender: TdxCustomDockControl;
      var CanClose: Boolean);
  private
    mFrame: TFrame;
    tvMain: TmycxGridTableView;
  protected
    procedure EXPANDROW(var Msg: TMessage); message CM_EXPROW;
    procedure NEWLIST(var Msg: TMessage); message CM_NEWLIST;
    procedure APPLYNEWLIST(var Msg: TMessage); message CM_APPLYNEWLIST;
    procedure CANCELNEWLIST(var Msg: TMessage); message CM_CANCELNEWLIST;
    procedure TABCLOSE(var Msg: TMessage); message CM_CLOSETAB;
    procedure SHOWSETTINGS(var Msg: TMessage); message CM_SHOWSETTINGS;
    procedure CANCELSETTINGS(var Msg: TMessage); message CM_CANCELSETTINGS;
    procedure APPLYSETTINGS(var Msg: TMessage); message CM_APPLYSETTINGS;
    procedure dxTabClose(Sender: TdxCustomDockControl);
    // procedure APPLYEDITLIST(var Msg: TMessage); message CM_APPLYNEWLIST;
  private
    tagds: tdxTabContainerDockSite;
    tableds: tdxTabContainerDockSite;
    logds: tdxTabContainerDockSite;
    TabList: TList;
    pTags: TdxDockPanel;
    pCTags: TdxDockPanel;
    pLog, pErrors: TdxDockPanel;
    mmLog: TcxMemo;
    mmErrors: TcxMemo;
    dsFirstShow: Boolean;
    SttPanel: TdxDockPanel;
    { Private declarations }
  public
    OldState: TmfState;
    procedure tvMainRecordExpandable(MasterDataRow: TcxGridMasterDataRow;
      var Expandable: Boolean);
    function CreateTab(ds: TdxCustomDockControl): TdxDockPanel;
    function CreateTags(ds: TdxCustomDockControl): tdxTabContainerDockSite;
    procedure ShowDs;
    procedure HideDs;
    procedure CloseTab(n: TdxDockPanel);
    function CreateLogs(ds: TdxCustomDockControl): tdxTabContainerDockSite;

    { Public declarations }
  end;

var
  mf: Tmf;

implementation

uses StartFrame, NewListFrame, LangString, SettingsFrame;
{$R *.dfm}
{ TmycxGridTableView }

constructor TmycxGridTableView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  OnGetExpandable := nil;
end;

function TmycxGridTableView.GetViewDataClass: TcxCustomGridViewDataClass;
begin
  Result := TmycxGridViewData;
end;

{ TmycxGridViewData }

function TmycxGridViewData.GetRecordClass(ARecordInfo: TcxRowInfo)
  : TcxCustomGridRecordClass;
begin
  Result := inherited GetRecordClass(ARecordInfo);
  if Result = TcxGridMasterDataRow then
    Result := TmycxGridMasterDataRow;
end;

{ TmycxGridGroupRow }

function TmycxGridMasterDataRow.GetExpandable: Boolean;
begin
  Result := false;
  if Assigned((GridView as TmycxGridTableView).OnGetExpandable) then
    (GridView as TmycxGridTableView).OnGetExpandable(Self, Result) else Result
      := inherited GetExpandable;
end;

{ Tmf }

procedure Tmf.tvMainRecordExpandable(MasterDataRow: TcxGridMasterDataRow;
  var Expandable: Boolean);
begin
  Expandable := MasterDataRow.RecordIndex > 0;
end;

procedure Tmf.EXPANDROW(var Msg: TMessage);
var
  mr: TcxCustomGridRecord;
  gv: TcxGridTableView;
  cl: TcxCustomGridView;
begin
  if not((TObject(Msg.WParam) is TcxCustomGridRecord) and
    (TObject(Msg.LParam) is TcxGridTableView)) then
    Exit;
  mr := TcxCustomGridRecord(Msg.WParam);
  gv := TcxGridTableView(Msg.LParam);
  cl := gv.Clones[gv.CloneCount - 1];
  cl.BeginUpdate;
  try
    if mr.RecordIndex = 1 then

      with cl.DataController do
      begin
        cl.DataController.RecordCount := 2;
        cl.DataController.Values[0, 1] := 'album1url1';
        cl.DataController.Values[1, 1] := 'album1url2';
      end;
  finally
    cl.EndUpdate;
  end;
end;

procedure Tmf.NEWLIST(var Msg: TMessage);
var
  // pic: TPicture;
  S: AnsiString;
  n: TdxDockPanel;
  f: TfNewList;
  i: integer;

begin
  if Assigned(mFrame) then
    FreeAndNil(mFrame);

  n := CreateTab(tableds);
  f := TfNewList.Create(n);
  f.State := lfsNew;
  f.Tag := integer(n);
  n.Tag := integer(f);

  with f do
  begin
    gFull.BeginUpdate;

    // pic := TPicture.Create;

    with tvRes.DataController do
    begin
      RecordCount := 1;
      Values[0, 0] := 0;
      Values[0, 2] := _ALL_;
    end;

    with tvFull.DataController do
    begin
      RecordCount := FullResList.Count - 1;
      for i := 1 to FullResList.Count - 1 do
      begin
        Values[i - 1, 1] := i;
        if FullResList[i].IconFile <> '' then
        begin
          { pic.LoadFromFile(rootdir + '\resources\icons\' + FullResList[i]
            .IconFile);
            SavePicture(pic, S); }
          FileToString(rootdir + '\resources\icons\' + FullResList[i]
            .IconFile, S);
          Values[i - 1, 2] := S;
        end;
        { FileToString(rootdir+'\resources\icons\'+FullResLIst[i].IconFile) };
        Values[i - 1, 3] := FullResList[i].Name;
        // tvFull.DataController.
      end;

    end;

    // pic.Free;
    gFull.EndUpdate;
  end;

  f.Parent := n;
  ShowDs;
end;

procedure Tmf.APPLYNEWLIST(var Msg: TMessage);
begin

end;

procedure Tmf.APPLYSETTINGS(var Msg: TMessage);
var
//  n: TdxDockPanel;
  f: TfSettings;
begin
//  n := Pointer(Msg.WParam);
  f := TfSettings(SttPanel.Tag);

  with f,GlobalSettings do
  begin
    Proxy.UseProxy := chbProxy.Checked;
    Proxy.Host := eHost.Text;
    Proxy.Port := ePort.Value;
    Proxy.Auth := chbProxyAuth.Checked;
    Proxy.Login := eProxyLogin.Text;
    Proxy.Password := eProxyPassword.Text;
    Proxy.SavePWD := chbProxySavePWD.Checked;

    Downl.ThreadCount := eThreads.Value;
    Downl.Retries := eRetries.Value;
    Downl.Debug := chbDebug.Checked;

    Downl.Interval := eInterval.Value;
    Downl.BeforeU := chbBeforeU.Checked;
    Downl.BeforeP := chbBeforeP.Checked;
    Downl.AfterP := chbAfterP.Checked;

    TrayIcon := chbTrayIcon.Checked;
    HideToTray := chbHideToTray.Checked;
    OneInstance := chbOneInstance.Checked;
    SaveConfirm := chbSaveConfirm.Checked;
  end;

  f.Free;
  SttPanel.Close;
  SttPanel := nil;
end;

procedure Tmf.aStartExecute(Sender: TObject);
begin
  if Assigned(mFrame) and not(mFrame is TfStart) then
    FreeAndNil(mFrame);

  ds.Hide;

  mFrame := TfStart.Create(Self);
  mFrame.Parent := Self;
end;

procedure Tmf.CANCELNEWLIST(var Msg: TMessage);
var
  n: TdxDockPanel;
  f: TfNewList;

begin
  n := Pointer(Msg.WParam);
  f := TfNewList(n.Tag);
  f.Free;
  n.Close;
end;

procedure Tmf.CANCELSETTINGS(var Msg: TMessage);
var
  f: TfSettings;

begin
//  n := Pointer(Msg.WParam);
  f := TfSettings(SttPanel.Tag);
  f.Free;
  SttPanel.Close;
  SttPanel := nil;
end;

procedure Tmf.TABCLOSE(var Msg: TMessage);
begin
  CloseTab(Pointer(Msg.WParam));
  if TabList.Count = 0 then
    HideDs;
end;

procedure Tmf.CloseTab(n: TdxDockPanel);
begin
  // n.DockTo(ds,dtBottom,-1);
  try
    n.Free;
  except
  end;
  // ShowMessage(n.Caption);
  TabList.Remove(n);
end;

function Tmf.CreateLogs(ds: TdxCustomDockControl): tdxTabContainerDockSite;
var
  n: tdxTabContainerDockSite;
begin
  n := tdxTabContainerDockSite.Create(Self);
  n.Height := 100;
  // n.ShowCaption := false;
  n.CaptionButtons := [cbHide];
  n.Dockable := false;
  // n.AutoHide := true;

  pErrors := TdxDockPanel.Create(Self);
  pErrors.Caption := 'pErrors';
  pErrors.Dockable := false;
  pErrors.DockTo(n, dtClient, 0);
  mmErrors := TcxMemo.Create(pErrors);
  mmErrors.Parent := pErrors;
  mmErrors.Align := alClient;
  mmErrors.Properties.ReadOnly := true;
  pLog := TdxDockPanel.Create(Self);
  pLog.Caption := 'pLog';
  pLog.Dockable := false;
  pLog.DockTo(n, dtClient, 0);
  mmLog := TcxMemo.Create(pLog);
  mmLog.Parent := pLog;
  mmLog.Align := alClient;
  mmLog.Properties.ReadOnly := true;

  n.DockTo(ds, dtBottom, 0);
  Result := n;
  // n.Visible := false;
  n.AutoHide := true;
  n.Hide;
  // mmLog := TcxMemo.
end;

function Tmf.CreateTab(ds: TdxCustomDockControl): TdxDockPanel;

var
  n: TdxDockPanel;

begin
  n := TdxDockPanel.Create(Self);
  n.Caption := 'tablepanel' + IntToStr(TabList.Count + 1);
  n.OnClose := dxTabClose;
  n.Dockable := false;
  n.ShowCaption := false;
  n.CaptionButtons := [cbClose];
  n.DockTo(ds, dtClient, TabList.Count);

  TabList.Add(n);
  Result := n;
end;

function Tmf.CreateTags(ds: TdxCustomDockControl): tdxTabContainerDockSite;
var
  ts: tdxTabContainerDockSite;
begin
  ts := tdxTabContainerDockSite.Create(Self);
  ts.Caption := 'tagpanel';
  ts.ShowCaption := false;
  ts.TabsPosition := tctpTop;
  ts.Width := 150;
  ts.Visible := false;
  ts.DockTo(ds, dtLeft, 0);

  if not Assigned(pCTags) then
    pCTags := TdxDockPanel.Create(Self);
  pCTags.Caption := 'pCTags';
  pCTags.DockTo(ts, dtClient, 0);

  if not Assigned(pTags) then
    pTags := TdxDockPanel.Create(Self);
  pTags.Caption := 'pTags';
  pTags.DockTo(ts, dtClient, 0);

  Result := ts;
end;

procedure Tmf.dpGridCloseQuery(Sender: TdxCustomDockControl;
  var CanClose: Boolean);
begin
  CanClose := false;
  aStartExecute(nil);
end;

procedure Tmf.dxTabClose(Sender: TdxCustomDockControl);
begin
  PostMessage(Application.MainForm.Handle, CM_CLOSETAB, integer(Sender), 0);
end;

procedure Tmf.ShowDs;
begin
  if not ds.Visible then
  begin
//    bmbMain.Visible := true;
    ds.Show;
  end;
end;

procedure Tmf.SHOWSETTINGS(var Msg: TMessage);
var
//  n: TdxDockPanel;
  f: TfSettings;

begin

  if Assigned(SttPanel) then
  begin
    SttPanel.Activate;
    Exit;
  end;

  if Assigned(mFrame) then
    FreeAndNil(mFrame);

  SttPanel := CreateTab(tableds);
  f := TfSettings.Create(SttPanel);

  with f,GlobalSettings do
  begin
    chbProxy.Checked := Proxy.UseProxy;
    eHost.Text := Proxy.Host;
    ePort.Value := Proxy.Port;
    chbProxyAuth.Checked := Proxy.Auth;
    eProxyLogin.Text := Proxy.Login;
    eProxyPassword.Text := Proxy.Password;
    chbProxySavePWD.Checked := Proxy.SavePWD;

    eThreads.Value := Downl.ThreadCount;
    eRetries.Value := Downl.Retries;
    chbDebug.Checked := Downl.Debug;

    eInterval.Value := Downl.Interval;
    chbBeforeU.Checked := Downl.BeforeU;
    chbBeforeP.Checked := Downl.BeforeP;
    chbAfterP.Checked := Downl.AfterP;

    chbTrayIcon.Checked := TrayIcon;
    chbHideToTray.Checked := HideToTray;
    chbOneInstance.Checked  := OneInstance;
    chbSaveConfirm.Checked := SaveConfirm;
  end;

  f.Tag := integer(SttPanel);
  SttPanel.Tag := integer(f);
  f.ResetButons;
  f.Parent := SttPanel;
  ShowDs;
end;

procedure Tmf.FormCreate(Sender: TObject);
begin
  dsFirstShow := true;
  SttPanel := nil;

  mFrame := TfStart.Create(Self);
  mFrame.Parent := Self;

  // globalpanel := tdxDockPanel.Create(Self);
  // globalpanel.Caption := 'globalpanel';
  // globalpanel.DockTo(ds,dtClient,1);

  pTags := nil;
  pCTags := nil;
  TabList := TList.Create;

  tableds := tdxTabContainerDockSite.Create(Self);
  // tableds.

  tableds.Dockable := false;
  tableds.TabsPosition := tctpTop;
  tableds.ShowCaption := false;
  tableds.DockTo(ds, dtClient, 0);

  tagds := CreateTags(ds);
  tagds.Visible := false;

  logds := CreateLogs(ds);

end;

procedure Tmf.FormDestroy(Sender: TObject);
begin
  if Assigned(mFrame) then
    mFrame.Free;
  TabList.Free;
end;

procedure Tmf.gLevel2GetGridView(Sender: TcxGridLevel;
  AMasterRecord: TcxCustomGridRecord; var AGridView: TcxCustomGridView);

begin
  PostMessage(Handle, CM_EXPROW, integer(AMasterRecord), integer(AGridView));
end;

procedure Tmf.HideDs;
begin
  if ds.Visible then
  begin
    ds.Hide;
    tagds.Hide;
    bmbMain.Visible := false;
    mFrame := TfStart.Create(Self);
    mFrame.Parent := Self;
  end;
end;

end.
