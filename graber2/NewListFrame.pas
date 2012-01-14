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
    vgSettings: TcxVerticalGrid;
    erAuthButton: TcxEditRepositoryButtonItem;
    erCheckBox: TcxEditRepositoryCheckBoxItem;
    erSpinEdit: TcxEditRepositorySpinItem;
    erCombo: TcxEditRepositoryComboBoxItem;
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
    procedure tvResFocusedRecordChanged(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    procedure tsSettingsShow(Sender: TObject);
  private
    { Private declarations }
  protected
  public
    State: TListFrameState;
    procedure AddItem(index: Integer);
    procedure RemoveItem(index: Integer);
    procedure CreateSettings(n: Integer);
    procedure SaveSettings;
    procedure LoadItems;
    procedure ResetItems;
    { Public declarations }
  end;

var
  LList: array of TcxLabelProperties;

implementation

uses OpBase, GraberU, LangString;

{$R *.dfm}

function Min(n1, n2: Integer): Integer;
begin
  if n1 < n2 then
    Result := n1
  else
    Result := n2;
end;

procedure StringToList(s: string; list: TStrings);
var
  tmp: string;
begin
  while s <> '' do
  begin
    tmp := GetNextS(s, ',');
    list.Add(tmp);
  end;
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
  PostMessage(Application.MainForm.Handle, CM_CANCELNEWLIST, Tag, 0);
end;

procedure TfNewList.btnOkClick(Sender: TObject);
begin
  case State of
    lfsNew:
      PostMessage(Application.MainForm.Handle, CM_APPLYNEWLIST, Tag, 0);
    lfsEdit:
      PostMessage(Application.MainForm.Handle, CM_APPLYEDITLIST, Tag, 0);
  end;
end;

procedure TfNewList.CreateSettings(n: Integer);
var
  c: TcxCategoryRow;
  r: TcxEditorRow;
  i, d: Integer;

begin
  if vgSettings.Rows.Count > 0 then
    SaveSettings;
  vgSettings.BeginUpdate;
  vgSettings.ClearRows;
  vgSettings.Tag := n;
  if n = 0 then
  begin
    c := vgSettings.Add(TcxCategoryRow) as TcxCategoryRow;
    c.Name := 'vgimain';
    c.Properties.Caption := _MAINCONFIG_;

    r := vgSettings.AddChild(c, TcxEditorRow) as TcxEditorRow;
    r.Name := 'vgitag';
    r.Properties.Caption := _TAGSTRING_;
    r.Properties.Value := FullResList[n].Fields['tag'];
  end
  else
  begin
    c := vgSettings.Add(TcxCategoryRow) as TcxCategoryRow;
    c.Name := 'vgimain';
    c.Properties.Caption := _MAINCONFIG_;

    r := vgSettings.AddChild(c, TcxEditorRow) as TcxEditorRow;
    r.Name := 'vgiinherit';
    r.Properties.Caption := _INHERIT_;
    r.Properties.RepositoryItem := erCheckBox;
    r.Properties.Value := FullResList[n].Inherit;

    r := vgSettings.AddChild(c, TcxEditorRow) as TcxEditorRow;
    r.Name := 'vgitag';
    r.Properties.Caption := _TAGSTRING_;
    r.Properties.Value := FullResList[n].Fields['tag'];
    r.Tag := Integer(vgSettings.RowByName('inherit'));

    d := FullResList[0].Fields.Count;

    c := nil;

    if FullResList[n].Fields.Count > d then
    begin
      with FullResList[n].Fields do
        for i := d to Count - 1 do
          if Items[i].restype <> ftNone then
          begin
            if not Assigned(c) then
            begin
              c := vgSettings.Add(TcxCategoryRow) as TcxCategoryRow;
              c.Name := 'vgieditional';
              c.Properties.Caption := _EDITIONALCONFIG_;
            end;
            r := vgSettings.AddChild(c, TcxEditorRow) as TcxEditorRow;
            r.Name := 'evgi' + Items[i].resname;
            r.Properties.Caption := Items[i].resname;
            case Items[i].restype of
              ftString:
                ;
              ftNumber:
                r.Properties.RepositoryItem := erSpinEdit;
              ftCombo:
                begin
                  erCombo.Properties.Items.Clear;
                  StringToList(Items[i].resitems, erCombo.Properties.Items);
                  r.Properties.RepositoryItem := erCombo;
                end;
              ftCheck:
                r.Properties.RepositoryItem := erCheckBox;
            end;
            r.Properties.Value := FullResList[n].Inherit;
          end;
    end;
  end;
  // FullResList[0].Fields
  vgSettings.EndUpdate;
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
  if (ARecord.Values[0] <> null) and FullResList[ARecord.Values[0]]
    .LoginPrompt then
    AProperties := erAuthButton.Properties;
  // ARecord.Values[2] := ARecord.Values[0];
end;

procedure TfNewList.LoadItems;
var
  i: Integer;
  s: ANSIString;
begin
  gFull.BeginUpdate;

  // pic := TPicture.Create;

  with tvRes.DataController do
  begin
    RecordCount := 1;
    Values[0, 0] := 0;
    Values[0, 2] := _GENERAL_;
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
          .IconFile, s);
        Values[i - 1, 2] := s;
      end;
      { FileToString(rootdir+'\resources\icons\'+FullResLIst[i].IconFile) };
      Values[i - 1, 3] := FullResList[i].Name;
      // tvFull.DataController.
    end;

  end;

  // pic.Free;
  gFull.EndUpdate;
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

procedure TfNewList.ResetItems;
begin
  if pcMain.ActivePage = tsSettings then
    SaveSettings;
end;

procedure TfNewList.SaveSettings;
var
  i, n, d: Integer;
  v: TResourceField;
begin
  n := vgSettings.Tag;
  with FullResList[n] do
  begin
    Fields['tag'] := (vgSettings.RowByName('vgitag') as TcxEditorRow)
      .Properties.Value;
    if vgSettings.Tag > 0 then
    begin
      Inherit := (vgSettings.RowByName('vgiinherit') as TcxEditorRow)
        .Properties.Value;
      d := FullResList[0].Fields.Count;
      if FullResList[n].Fields.Count > d then
        with FullResList[n].Fields do
          for i := d to Count - 1 do
          begin
            v := Items[i];
            v.resvalue := (vgSettings.RowByName('evgi' + Items[i].resname)
              as TcxEditorRow).Properties.Value;
            Items[i] := v;
          end;
    end;
  end;
end;

procedure TfNewList.tsSettingsShow(Sender: TObject);
begin
  if tvRes.Controller.FocusedRow = nil then
    tvRes.Controller.FocusedRowIndex := 0;
  CreateSettings(tvRes.Controller.FocusedRow.Values[0]);
end;

procedure TfNewList.tvFullcButtonPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  AddItem(tvFull.DataController.FocusedRecordIndex);
end;

procedure TfNewList.tvResFocusedRecordChanged(Sender: TcxCustomGridTableView;
  APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
  ANewItemRecordFocusingChanged: Boolean);
begin
  if pcMain.ActivePage = tsSettings then
    CreateSettings(AFocusedRecord.Values[0]);
end;

initialization

end.
