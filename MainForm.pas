unit MainForm;

interface

uses
  {base}
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,
  {devex}
  dxDockControl, dxDockPanel, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinscxPCPainter,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData,
  cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, dxSkinsdxDockControlPainter,
  ActnList, cxCheckBox, cxTextEdit,
  {graber2}
  common;

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
    aLNew: TAction;
    aLLoad: TAction;
    aSettings: TAction;
    aIAdvanced: TAction;
    aISimple: TAction;
    ds: TdxDockSite;
    DockManager: TdxDockingManager;
    dpTags: TdxDockPanel;
    dxLayoutDockSite1: TdxLayoutDockSite;
    dpProgressLog: TdxDockPanel;
    dpErrorLog: TdxDockPanel;
    dxTabContainerDockSite1: TdxTabContainerDockSite;
    dpPicInfo: TdxDockPanel;
    dpGrid: TdxDockPanel;
    dxLayoutDockSite5: TdxLayoutDockSite;
    gLevel1: TcxGridLevel;
    Grid: TcxGrid;
    tvmMain: TcxGridTableView;
    gLevel2: TcxGridLevel;
    tvChild: TcxGridTableView;
    tvmMainChck: TcxGridColumn;
    tvmMainDName: TcxGridColumn;
    tvChildChck: TcxGridColumn;
    tvChildDName: TcxGridColumn;
    dxLayoutDockSite3: TdxLayoutDockSite;
    dxVertContainerDockSite2: TdxVertContainerDockSite;
    aLApplyNew: TAction;
    aLCancel: TAction;
    aStart: TAction;
    deStyleRepository: TcxStyleRepository;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure aLNewExecute(Sender: TObject);
    procedure gLevel2GetGridView(Sender: TcxGridLevel;
      AMasterRecord: TcxCustomGridRecord; var AGridView: TcxCustomGridView);
    procedure aLCancelExecute(Sender: TObject);
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
    procedure ShowGrid;
    // procedure APPLYEDITLIST(var Msg: TMessage); message CM_APPLYNEWLIST;
  private
    { Private declarations }
  public
    OldState: TmfState;
    procedure tvMainRecordExpandable(MasterDataRow: TcxGridMasterDataRow;
      var Expandable: Boolean);
    { Public declarations }
  end;

var
  mf: Tmf;

implementation

uses StartFrame, NewListFrame;
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
begin
  aLNewExecute(nil);
end;

procedure Tmf.APPLYNEWLIST(var Msg: TMessage);
begin
  ShowGrid;
end;

procedure Tmf.aStartExecute(Sender: TObject);
begin
  if Assigned(mFrame) then
    FreeAndNil(mFrame);

  if ds.Visible then
    ds.Hide;

  mFrame := TfStart.Create(Self);
  mFrame.Parent := Self;
end;

procedure Tmf.CANCELNEWLIST(var Msg: TMessage);
begin
  alCancelExecute(nil);
end;

procedure Tmf.dpGridCloseQuery(Sender: TdxCustomDockControl;
  var CanClose: Boolean);
begin
  CanClose := false;
  aStartExecute(nil);
end;

procedure Tmf.aLCancelExecute(Sender: TObject);
begin
  if tvMain.DataController.RecordCount > 0 then
    ShowGrid
  else
    aStartExecute(nil);
end;

procedure Tmf.aLNewExecute(Sender: TObject);
begin
  if Assigned(mFrame) then
    FreeAndNil(mFrame);

  if ds.Visible then
    ds.Hide;

  if Assigned(mFrame) then
    FreeAndNil(mFrame);

  if ds.Visible then
    ds.Hide;

  mFrame := TfNewList.Create(Self);
  mFrame.Parent := Self;

  {
    ds.Show;
    tvMain.DataController.RecordCount := 2;
    tvMain.ViewData.Rows[0].Values[1] := 'url1';
    tvMain.ViewData.Rows[1].Values[1] := 'album1'; }
end;

procedure Tmf.FormCreate(Sender: TObject);
begin
  // ds.Hide;

  mFrame := TfStart.Create(Self);
  mFrame.Parent := Self;

  tvMain := TmycxGridTableView(Grid.CreateView(TmycxGridTableView));
  tvMain.OnGetExpandable := tvMainRecordExpandable;
  tvMain.Assign(tvmMain);
  gLevel1.GridView := tvMain;
  tvmMain.Free;
end;

procedure Tmf.FormDestroy(Sender: TObject);
begin
  if Assigned(mFrame) then
    mFrame.Free;
end;

procedure Tmf.gLevel2GetGridView(Sender: TcxGridLevel;
  AMasterRecord: TcxCustomGridRecord; var AGridView: TcxCustomGridView);

begin
  PostMessage(handle, CM_EXPROW, Integer(AMasterRecord), Integer(AGridView));
end;

procedure Tmf.ShowGrid;
begin
  if Assigned(mFrame) then
    FreeAndNil(mFrame);

  ds.Show;
end;

end.
