unit GridFrame2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, dxBar, cxClasses,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxCustomData,
  cxStyles, cxTL, cxTextEdit, cxTLdxBarBuiltInMenu, cxEditRepositoryItems,
  cxExtEditRepositoryItems, cxEdit, cxInplaceContainer, cxTLData, graberU;

type
  TfGrid2 = class(TFrame)
    BarManager: TdxBarManager;
    TableActions: TdxBar;
    bbColumns: TdxBarButton;
    bbFilter: TdxBarButton;
    bbSelect: TdxBarButton;
    bbUnselect: TdxBarButton;
    siCheck: TdxBarSubItem;
    siUncheck: TdxBarSubItem;
    bbCheckAll: TdxBarButton;
    bbCheckSelected: TdxBarButton;
    bbCheckFiltered: TdxBarButton;
    bbInverseChecked: TdxBarButton;
    bbUncheckAll: TdxBarButton;
    bbUncheckSelected: TdxBarButton;
    bbUncheckFiltered: TdxBarButton;
    bbAdditional: TdxBarSubItem;
    bbDALF: TdxBarButton;
    bbAutoUnch: TdxBarButton;
    bbWriteEXIF: TdxBarButton;
    bbUncheckBlacklisted: TdxBarButton;
    bbCheckBlacklisted: TdxBarButton;
    BarControl: TdxBarDockControl;
    vTree: TcxVirtualTreeList;
    cxEditRepository1: TcxEditRepository;
    iPicChecker: TcxEditRepositoryCheckBoxItem;
    iCheckBox: TcxEditRepositoryCheckBoxItem;
    iPBar: TcxEditRepositoryProgressBar;
    iFloatEdit: TcxEditRepositoryCurrencyItem;
    iLabel: TcxEditRepositoryLabel;
    iState: TcxEditRepositoryImageComboBoxItem;
    procedure vTreeGetNodeValue(Sender: TcxCustomTreeList;
      ANode: TcxTreeListNode; AColumn: TcxTreeListColumn; var AValue: Variant);
    procedure vTreeGetChildCount(Sender: TcxCustomTreeList;
      AParentNode: TcxTreeListNode; var ACount: Integer);
  private
    { Private declarations }
    fRList: tResourceList;
  public
    procedure SetList(const l: tResourceList);
    procedure Reset;
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TfGrid2.Reset;
var
  c: TcxTreeListColumn;
begin
  vTree.BeginUpdate; try
    vTree.Clear;
    //vTree.
    //vTree.DataController
    //vTree.Count := fRList.PictureList.Count;
    c := vTree.CreateColumn;
    c.Caption.Text := 'Caption';
    c.Tag := 0;
    vTree.FullRefresh;
  finally
    vTree.EndUpdate;
  end;
end;

procedure TfGrid2.SetList(const l: tResourceList);
begin
  fRList := l;
end;

procedure TfGrid2.vTreeGetChildCount(Sender: TcxCustomTreeList;
  AParentNode: TcxTreeListNode; var ACount: Integer);
begin
  if not Assigned(fRList) then
    Exit;
  //ShowMessage(IntToStr(AParentNode.Level));
  if AParentNode.Level = -1 then
    ACount := fRList.PictureList.ParentCount
  else if AParentNode.Level = 0 then
    ACount := fRList.PictureList[AParentNode.Index].Linked.Count
  else
    ACount := 0;
end;

procedure TfGrid2.vTreeGetNodeValue(Sender: TcxCustomTreeList;
  ANode: TcxTreeListNode; AColumn: TcxTreeListColumn; var AValue: Variant);
begin
  if AColumn.Tag = 0 then
    if ANode.Level = 0 then
      AValue := fRList.PictureList[ANode.Index].DisplayLabel;


end;

end.
