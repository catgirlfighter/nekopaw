unit NewListFrame;

interface

uses
  {base}
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls,
  {devexp}
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxCustomData, cxStyles, cxTL, cxTextEdit, cxCheckBox, cxTLdxBarBuiltInMenu,
  dxSkinsCore, ExtCtrls, cxSplitter, cxInplaceContainer,
  cxButtons, dxSkinscxPCPainter, cxFilter, cxData, cxDataStorage, cxEdit,
  cxGridCustomTableView, cxGridTableView, cxGridCustomView, cxClasses,
  cxGridLevel, cxGrid, cxButtonEdit, cxExtEditRepositoryItems, cxPC, cxLabel,
  cxImage, cxEditRepositoryItems, cxVGrid,
  {graber2}
  common;

type
  TListFrameState = (lfsNew, lfsEdit);

  TfNewList = class(TFrame)
    VSplitter: TcxSplitter;
    pButtons: TPanel;
    btnOk: TcxButton;
    btnCancel: TcxButton;
    lvlRes1: TcxGridLevel;
    gRes: TcxGrid;
    tvRes: TcxGridTableView;
    gRescName: TcxGridColumn;
    gRescButton: TcxGridColumn;
    pcMain: TcxPageControl;
    tsList: TcxTabSheet;
    tsSettings: TcxTabSheet;
    gFull: TcxGrid;
    tvFull: TcxGridTableView;
    tvFullcButton: TcxGridColumn;
    tvFullcName: TcxGridColumn;
    lvlFull1: TcxGridLevel;
    tvFullID: TcxGridColumn;
    EditRepository: TcxEditRepository;
    tvFullcIcon: TcxGridColumn;
    gRescID: TcxGridColumn;
    tgRescIcon: TcxGridColumn;
    erLabel: TcxEditRepositoryLabel;
    erButton: TcxEditRepositoryButtonItem;
    cxVerticalGrid1: TcxVerticalGrid;
    cxVerticalGrid1CategoryRow1: TcxCategoryRow;
    erAuthButton: TcxEditRepositoryButtonItem;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure gRescButtonGetProperties(Sender: TcxCustomGridTableItem;
      ARecord: TcxCustomGridRecord; var AProperties: TcxCustomEditProperties);
    procedure pcMainChange(Sender: TObject);
    procedure gRescButtonPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure tvFullcButtonPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure gRescNameGetProperties(Sender: TcxCustomGridTableItem;
      ARecord: TcxCustomGridRecord; var AProperties: TcxCustomEditProperties);
  private
    { Private declarations }
  protected
  public
    State: TListFrameState;
    procedure AddItem(index: Integer);
    procedure RemoveItem(index: Integer);
    { Public declarations }
  end;

var
  LList: array of TcxLabelProperties;

implementation

uses MainForm, OpBase;

{$R *.dfm}

function Min(n1, n2: Integer): Integer;
begin
  if n1 < n2 then
    Result := n1
  else
    Result := n2;
end;

procedure TfNewList.AddItem(index: Integer);
var
  i: Integer;
begin
  tvRes.BeginUpdate;
  tvFull.BeginUpdate;
  i := tvRes.DataController.RecordCount;
  tvRes.DataController.RecordCount := i + 1;
  tvRes.DataController.Values[i, 0] := tvFull.DataController.Values[index, 1];
  tvRes.DataController.Values[i, 1] := tvFull.DataController.Values[index, 2];
  tvRes.DataController.Values[i, 2] := tvFull.DataController.Values[index, 3];
  tvFull.DataController.DeleteRecord(index);
  tvRes.EndUpdate;
  tvFull.EndUpdate;

  btnOk.Enabled := tvRes.DataController.RowCount > 1;
end;

procedure TfNewList.btnCancelClick(Sender: TObject);
begin
  PostMessage(Application.MainForm.Handle, CM_CANCELNEWLIST,
    pButtons.Parent.Tag, 0);
end;

procedure TfNewList.btnOkClick(Sender: TObject);
begin
  case State of
    lfsNew:
      PostMessage(Application.MainForm.Handle, CM_APPLYNEWLIST, 0, 0);
    lfsEdit:
      PostMessage(Application.MainForm.Handle, CM_APPLYEDITLIST, 0, 0);
  end;

end;

procedure TfNewList.gRescButtonGetProperties(Sender: TcxCustomGridTableItem;
  ARecord: TcxCustomGridRecord; var AProperties: TcxCustomEditProperties);
begin
  if ARecord.Values[0] = 0 then
    AProperties := erLabel.Properties;
end;

procedure TfNewList.gRescButtonPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  RemoveItem(tvRes.DataController.FocusedRecordIndex);
end;

procedure TfNewList.gRescNameGetProperties(Sender: TcxCustomGridTableItem;
  ARecord: TcxCustomGridRecord; var AProperties: TcxCustomEditProperties);
begin
  if (ARecord.Values[0] <> null) and
    FullResList[ARecord.Values[0]].LoginPage.NeedAuth then
    AProperties := erAuthButton.Properties;
//  ARecord.Values[2] := ARecord.Values[0];
end;

procedure TfNewList.pcMainChange(Sender: TObject);
begin
  with (Sender as TcxPageControl) do
  begin
    gRescButton.Visible := ActivePage = tsList;
  end;
end;

procedure TfNewList.RemoveItem(index: Integer);
var
  i: Integer;
begin
  tvRes.BeginUpdate;
  tvFull.BeginUpdate;
  i := tvFull.DataController.RecordCount;
  tvFull.DataController.RecordCount := i + 1;
  tvFull.DataController.Values[i, 1] := tvRes.DataController.Values[index, 0];
  tvFull.DataController.Values[i, 2] := tvRes.DataController.Values[index, 1];
  tvFull.DataController.Values[i, 3] := tvRes.DataController.Values[index, 2];
  tvRes.DataController.DeleteRecord(index);
  tvRes.DataController.FocusedRecordIndex :=
    Min(index, tvRes.DataController.RecordCount - 1);
  tvRes.EndUpdate;
  tvFull.EndUpdate;

  btnOk.Enabled := tvRes.DataController.RowCount > 1;
end;

procedure TfNewList.tvFullcButtonPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  AddItem(tvFull.DataController.FocusedRecordIndex);
end;

initialization

end.
