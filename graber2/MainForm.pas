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
  common, OpBase, graberU;

type

  TcxTabSheetEvent = procedure(ASender: TObject; ATabSheet: TcxTabSheet)
    of object;

  TcxPageControl = class(cxPC.TcxPageControl)
  private
    FOnPageClose: TcxTabSheetEvent;
  protected
    procedure DoClose; override;
  public
    property OnPageClose: TcxTabSheetEvent read FOnPageClose write FOnPageClose;
  end;

  { TmycxOnGetExpandable = procedure(MasterDataRow: TcxGridMasterDataRow;
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
    end; }

  // TmfState = (msStart, msNewList, msGrid, msSettings);

  Tmf = class(TForm)
    ActionList: TActionList;
    aLLoad: TAction;
    aSettings: TAction;
    aIAdvanced: TAction;
    aISimple: TAction;
    aLApplyNew: TAction;
    aLCancel: TAction;
    ds: TdxDockSite;
    DockManager: TdxDockingManager;
    BarManager: TdxBarManager;
    bmbMain: TdxBar;
    bbStop: TdxBarButton;
    dpTable: TdxDockPanel;
    dxLayoutDockSite2: TdxLayoutDockSite;
    dpTags: TdxDockPanel;
    dpCurTags: TdxDockPanel;
    dsTable: TdxLayoutDockSite;
    dsTags: TdxTabContainerDockSite;
    dpLog: TdxDockPanel;
    dxLayoutDockSite4: TdxLayoutDockSite;
    dpErrors: TdxDockPanel;
    dsLogs: TdxTabContainerDockSite;
    pcTables: TcxPageControl;
    bbStartList: TdxBarButton;
    bbStartDownload: TdxBarButton;
    bbSettings: TdxBarButton;
    bbNew: TdxBarButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure gLevel2GetGridView(Sender: TcxGridLevel;
      AMasterRecord: TcxCustomGridRecord; var AGridView: TcxCustomGridView);
    procedure bbStopClick(Sender: TObject);
    procedure bbSettingsClick(Sender: TObject);
    procedure bbNewClick(Sender: TObject);
    procedure pcTablesChange(Sender: TObject);
  private
    mFrame: TFrame;
    // tvMain: TmycxGridTableView;
  protected
//    procedure EXPANDROW(var Msg: TMessage); message CM_EXPROW;
    procedure NEWLIST(var Msg: TMessage); message CM_NEWLIST;
    procedure APPLYNEWLIST(var Msg: TMessage); message CM_APPLYNEWLIST;
    procedure CANCELNEWLIST(var Msg: TMessage); message CM_CANCELNEWLIST;
    procedure SHOWSETTINGS(var Msg: TMessage); message CM_SHOWSETTINGS;
    procedure CANCELSETTINGS(var Msg: TMessage); message CM_CANCELSETTINGS;
    procedure APPLYSETTINGS(var Msg: TMessage); message CM_APPLYSETTINGS;
    procedure dxTabClose(Sender: TdxCustomDockControl);
    // procedure APPLYEDITLIST(var Msg: TMessage); message CM_APPLYNEWLIST;
  private
    TabList: TList;
    dsFirstShow: Boolean;
    SttPanel: TcxTabSheet;
    { Private declarations }
  public
    // OldState: TmfState;
    { procedure tvMainRecordExpandable(MasterDataRow: TcxGridMasterDataRow;
      var Expandable: Boolean); }
    function CreateTab(pc: TcxPageControl): TcxTabSheet;
    procedure ShowDs;
    procedure HideDs;
    procedure CloseTab(var t: TcxTabSheet);
    procedure OnTabClose(ASender: TObject; ATabSheet: TcxTabSheet);
    procedure ShowPanels;

    { Public declarations }
  end;

var
  mf: Tmf;

implementation

uses StartFrame, NewListFrame, LangString, SettingsFrame, GridFrame;
{$R *.dfm}

procedure TcxPageControl.DoClose;
begin
  if Assigned(FOnPageClose) then
    FOnPageClose(Self, ActivePage)
  else
    inherited;
end;

{ TmycxGridTableView }

{ constructor TmycxGridTableView.Create(AOwner: TComponent);
  begin
  inherited Create(AOwner);
  OnGetExpandable := nil;
  end;

  function TmycxGridTableView.GetViewDataClass: TcxCustomGridViewDataClass;
  begin
  Result := TmycxGridViewData;
  end; }

{ TmycxGridViewData }

{ function TmycxGridViewData.GetRecordClass(ARecordInfo: TcxRowInfo)
  : TcxCustomGridRecordClass;
  begin
  Result := inherited GetRecordClass(ARecordInfo);
  if Result = TcxGridMasterDataRow then
  Result := TmycxGridMasterDataRow;
  end; }

{ TmycxGridGroupRow }

{ function TmycxGridMasterDataRow.GetExpandable: Boolean;
  begin
  Result := false;
  if Assigned((GridView as TmycxGridTableView).OnGetExpandable) then
  (GridView as TmycxGridTableView).OnGetExpandable(Self, Result) else Result
  := inherited GetExpandable;
  end; }

{ Tmf }

{ procedure Tmf.tvMainRecordExpandable(MasterDataRow: TcxGridMasterDataRow;
  var Expandable: Boolean);
  begin
  Expandable := MasterDataRow.RecordIndex > 0;
  end; }

{procedure Tmf.EXPANDROW(var Msg: TMessage);
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
end;    }

procedure Tmf.NEWLIST(var Msg: TMessage);
var
  n: TcxTabSheet;
  f: TfNewList;

begin
  n := CreateTab(pcTables);
  f := TfNewList.Create(n);
  f.State := lfsNew;
  f.Tag := integer(n);
  n.Tag := integer(f);

  f.LoadItems;

  f.Parent := n;
  ShowDs;
end;

procedure Tmf.OnTabClose(ASender: TObject; ATabSheet: TcxTabSheet);
begin
  CloseTab(ATabSheet);
end;

procedure Tmf.pcTablesChange(Sender: TObject);
begin
  if pcTables.ActivePage <> nil then
    if not (TFrame(pcTables.ActivePage.Tag) is TfGrid) then
      dsTags.Hide
    else
      dsTags.Show;
end;

procedure Tmf.APPLYNEWLIST(var Msg: TMessage);
var
  n: TcxTabSheet;
  f: TfNewList;
  f2: TfGrid;
  i: integer;

begin
  n := TcxTabSheet(Msg.WParam);
  f := TfNewList(n.Tag);
  f2 := TfGrid.Create(n);
  n.Tag := integer(f2);
  f2.CreateList;
  with f.tvRes.DataController do
    for i := 0 to RecordCount - 1 do
      if Values[i, 0] <> 0 then
        f2.ResList.CopyResource(FullResList[Values[i, 0]]);
  f.Free;
  f2.ResList.ThreadHandler.CreateThreads(GlobalSettings.Downl.ThreadCount);
  f2.ResList.StartJob(JOB_GETPICTURES);
  f2.Parent := n;
  ShowPanels;
end;

procedure Tmf.APPLYSETTINGS(var Msg: TMessage);
var
  // n: TdxDockPanel;
  f: TfSettings;
begin
  // n := Pointer(Msg.WParam);
  f := TfSettings(SttPanel.Tag);

  with f, GlobalSettings do
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
  CloseTab(SttPanel);
  // SttPanel := nil;
end;

procedure Tmf.bbNewClick(Sender: TObject);
begin
  PostMessage(Handle,CM_NEWLIST,0,0);
end;

procedure Tmf.bbSettingsClick(Sender: TObject);
begin
  PostMessage(Handle,CM_SHOWSETTINGS,0,0);
end;

procedure Tmf.bbStopClick(Sender: TObject);
var
  f: TFrame;

begin
  f := TFrame(pcTables.ActivePage.Tag);
  if f is TfGrid then
    (f as TfGrid).ResList.ThreadHandler.FinishThreads;
end;

procedure Tmf.CANCELNEWLIST(var Msg: TMessage);
var
  n: TcxTabSheet;
  f: TfNewList;

begin
  n := Pointer(Msg.WParam);
  f := TfNewList(n.Tag);
  f.Free;
  CloseTab(n);
end;

procedure Tmf.CANCELSETTINGS(var Msg: TMessage);
var
  f: TfSettings;

begin
  // n := Pointer(Msg.WParam);
  f := TfSettings(SttPanel.Tag);
  f.Free;
  CloseTab(SttPanel);
end;

procedure Tmf.CloseTab(var t: TcxTabSheet);
var
  f: TFrame;
begin
  // pcTables.Tabs
  f := TFrame(t.Tag);
  if f is TfGrid then
    with (f as TfGrid) do
      if ResList.ThreadHandler.Count > 0 then
      begin
        MessageDlg(_TAB_IS_BUSY_,mtError,[mbOk],0);
        Exit;
      end else
        ResList.Free;
  t.Free;
  pcTables.Change;
  // FreeAndNil(t);
  TabList.Remove(t);
  if SttPanel = t then
    SttPanel := nil;
  if pcTables.TabCount = 0 then
    HideDs;
end;

function Tmf.CreateTab(pc: TcxPageControl): TcxTabSheet;
var
  n: TcxTabSheet;

begin
  if Assigned(mFrame) then
    FreeAndNil(mFrame);

  n := TcxTabSheet.Create(Self);
  n.Caption := 'New' + IntToStr(TabList.Count + 1);
  // n.OnClose := dxTabClose;
  // n.Dockable := false;
  // n.ShowCaption := false;
  // n.CaptionButtons := [cbClose];
  n.PageControl := pc;
  pc.ActivePage := n;
  pc.Change;
  { if pc.PageCount < 2 then
    pc.HideTabs := true; }

  TabList.Add(n);
  Result := n;

  ShowDs;
end;

procedure Tmf.dxTabClose(Sender: TdxCustomDockControl);
begin
  PostMessage(Application.MainForm.Handle, CM_CLOSETAB, integer(Sender), 0);
end;

procedure Tmf.ShowDs;
begin
  if not ds.Visible then
  begin
    // bmbMain.Visible := true;
    ds.Show;
  end;
end;

procedure Tmf.ShowPanels;
begin
  if not bmbMain.Visible then
    bmbMain.Visible := true;
  pcTables.Change;
    // dsLogs.Visible := true;
end;

procedure Tmf.SHOWSETTINGS(var Msg: TMessage);
var
  // n: TdxDockPanel;
  f: TfSettings;

begin
  if Assigned(SttPanel) then
  begin
    pcTables.ActivePage := SttPanel;
    Exit;
  end;
  SttPanel := CreateTab(pcTables);
  SttPanel.Caption := _SETTINGS_;
  f := TfSettings.Create(SttPanel);

  with f, GlobalSettings do
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
    chbOneInstance.Checked := OneInstance;
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
  pcTables.OnPageClose := OnTabClose;
  dsFirstShow := true;
  SttPanel := nil;
  // pTags := nil;
  // pCTags := nil;

  mFrame := TfStart.Create(Self);
  mFrame.Parent := Self;

  // globalpanel := tdxDockPanel.Create(Self);
  // globalpanel.Caption := 'globalpanel';
  // globalpanel.DockTo(ds,dtClient,1);
  TabList := TList.Create;
  bmbMain.Visible := false;

  dsLogs.AutoHide := true;
  dsLogs.Hide;
  dsTags.Hide;
  // tableds := tdxTabContainerDockSite.Create(Self);
  // tableds.

  // tableds.Dockable := false;
  // tableds.TabsPosition := tctpTop;
  // tableds.ShowCaption := false;
  // tableds.DockTo(ds, dtClient, 0);

  // tabledp := TdxDockPanel.Create(ds);
  // tabledp.Dockable := false;

  // tagds := CreateTags(ds);
  // tagds.Visible := false;

  // logds := CreateLogs(ds);
  // dsLogs.Hide;
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
    dsTags.Hide;
    dsLogs.Hide;
    bmbMain.Visible := false;
    mFrame := TfStart.Create(Self);
    mFrame.Parent := Self;
  end;
end;

end.
