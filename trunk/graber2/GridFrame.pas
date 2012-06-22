unit GridFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData,
  DBClient, cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, graberU, dxmdaset,
  cxEditRepositoryItems, common, ComCtrls, cxContainer, cxLabel, dxStatusBar,
  dxBar, cxGridCustomPopupMenu, cxGridPopupMenu, cxExtEditRepositoryItems,
  Delphi.Extensions.VirtualDataset, cxCheckBox, cxBarEditItem, cxCurrencyEdit;

type

  TfGrid = class(TFrame)
    GridLevel1: TcxGridLevel;
    Grid: TcxGrid;
    GridLevel2: TcxGridLevel;
    vChilds: TcxGridDBTableView;
    cxEditRepository1: TcxEditRepository;
    iTextEdit: TcxEditRepositoryTextItem;
    vGrid1: TcxGridDBTableView;
    sBar: TdxStatusBar;
    BarManager: TdxBarManager;
    BarControl: TdxBarDockControl;
    TableActions: TdxBar;
    bbColumns: TdxBarButton;
    GridPopup: TcxGridPopupMenu;
    bbFilter: TdxBarButton;
    iPicChecker: TcxEditRepositoryCheckBoxItem;
    iCheckBox: TcxEditRepositoryCheckBoxItem;
    iPBar: TcxEditRepositoryProgressBar;
    vGrid: TcxGridTableView;
    dxBarButton1: TdxBarButton;
    bbSelect: TdxBarButton;
    bbUnselect: TdxBarButton;
    siCheck: TdxBarSubItem;
    siUncheck: TdxBarSubItem;
    dxBarSubItem3: TdxBarSubItem;
    dxBarSubItem4: TdxBarSubItem;
    bbCheckAll: TdxBarButton;
    bbCheckSelected: TdxBarButton;
    bbCheckFiltered: TdxBarButton;
    dxBarButton2: TdxBarButton;
    bbInverseChecked: TdxBarButton;
    bbUncheckAll: TdxBarButton;
    bbUncheckSelected: TdxBarButton;
    bbUncheckFiltered: TdxBarButton;
    dxBarListItem1: TdxBarListItem;
    cxBarEditItem1: TcxBarEditItem;
    cxBarEditItem2: TcxBarEditItem;
    bbAdditional: TdxBarSubItem;
    cxBarEditItem3: TcxBarEditItem;
    bbDALF: TdxBarButton;
    vGridColumn1: TcxGridColumn;
    iFloatEdit: TcxEditRepositoryCurrencyItem;
    procedure bbColumnsClick(Sender: TObject);
    procedure bbFilterClick(Sender: TObject);
    procedure vGrid1FocusedRecordChanged(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    procedure vdGetRecordCount(Sender: TCustomVirtualDataset;
      var Count: Integer);
    procedure vdGetFieldValue(Sender: TCustomVirtualDataset; Field: TField;
      Index: Integer; var Value: Variant);
    procedure vdBeforeOpen(DataSet: TDataSet);
    procedure vGridEditValueChanged(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem);
    procedure bbCheckAllClick(Sender: TObject);
    procedure bbUncheckAllClick(Sender: TObject);
    procedure bbCheckSelectedClick(Sender: TObject);
    procedure bbUncheckSelectedClick(Sender: TObject);
    procedure bbCheckFilteredClick(Sender: TObject);
    procedure bbUncheckFilteredClick(Sender: TObject);
    procedure bbInverseCheckedClick(Sender: TObject);
    procedure bbDALFClick(Sender: TObject);
  private
    //FList: TList;
//    FFieldList: TStringList;
    FPicChanged: TPictureNotifyEvent;
    FCheckColumn: tcxGridColumn;
    FIdColumn: tcxGridColumn;
    FParentColumn: tcxGridColumn;
    FLabelColumn: tcxGridColumn;
    FProgressColumn: tcxGridColumn;
    FSizeColumn: tcxGridColumn;
    FPosColumn: tcxGridColumn;
    FResColumn: tcxGridColumn;
    FFieldList: TStringList;
    //FStartSender: TObject;
//    FN: Integer;
    //FFirstC: TcxDBGridColumn;
    { Private declarations }
  public
    ResList: TResourceList;
    procedure Reset;
    procedure CreateList;
    procedure OnPicAdd(APicture: TTPicture);
//    procedure CheckField(ch,s: string; value: variant);
    procedure OnStartJob(Sender: TObject; Action: Integer);
//    procedure OnEndJob(Sender: TObject);
    function AddField(s: string; base: boolean = false): TcxGridColumn;
    procedure OnBeginPicList(Sender: TObject);
    procedure OnEndPicList(Sender: TObject);
    procedure Relise;
    procedure SetLang;
    procedure OnListPicChanged(Pic: TTPicture; Changes: TPicChanges);
    procedure SetColWidths;
    procedure updatefocusedrecord;
    procedure ForceStop(Sender: TObject);
    procedure ForcePicsStop(Sender: TObject);
    procedure SetSettings;
    procedure SelectAll(b: boolean);
    procedure SelectSelected(b: boolean);
    procedure SelectFiltered(b: boolean);
    procedure InverseSelection;
    property OnPicChanged: TPictureNotifyEvent read FPicChanged write FPicChanged;
    { Public declarations }
  end;

  TcxGridSiteAccess = class(TcxGridSite);
  TcxGridPopupMenuAccess = class(TcxGridPopupMenu);
implementation

uses LangString, utils, OpBase;

{$R *.dfm}

function TfGrid.AddField(s: string; base: boolean = false): TcxGridColumn;
var
  n: string;

begin
  n := GetNextS(s,':');

  result := vGrid.CreateColumn;
  result.Caption := n;

  if s <> '' then
    case s[1] of
      'i' : result.DataBinding.ValueType := 'Integer';
      'l' : result.DataBinding.ValueType := 'LargeInt';
      'd' : result.DataBinding.ValueType := 'DateTime';
      'b' : result.DataBinding.ValueType := 'Boolean';
      'f' : result.DataBinding.ValueType := 'Float';
      'p' : result.DataBinding.ValueType := 'Float';
    else
      result.DataBinding.ValueType := 'String';
    end
  else
    result.DataBinding.ValueType := 'String';

  if SameText(s,'b') then
    if base then
      result.RepositoryItem := iPicChecker
    else
      result.RepositoryItem := iCheckBox
  else if SameText(s,'f') then
    result.RepositoryItem := iFloatEdit
  else if SameText(s,'p') then
    result.RepositoryItem := iPBar
  else
    result.RepositoryItem := iTextEdit;
  //result.DataBinding.ValueType := 'String';
end;

procedure TfGrid.bbCheckAllClick(Sender: TObject);
begin
  SelectAll(true);
end;

procedure TfGrid.bbCheckFilteredClick(Sender: TObject);
begin
  SelectFiltered(true);
end;

procedure TfGrid.bbCheckSelectedClick(Sender: TObject);
begin
  SelectSelected(true);
end;

procedure TfGrid.bbColumnsClick(Sender: TObject);
begin
  TcxGridPopupMenuAccess(GridPopup).GridOperationHelper.DoShowColumnCustomizing(True);
end;

procedure TfGrid.bbDALFClick(Sender: TObject);
begin
  GlobalSettings.Downl.SDALF := bbDALF.Down;
end;

procedure TfGrid.bbFilterClick(Sender: TObject);
begin
  if bbFilter.Down then
    vGrid.FilterBox.Visible := fvAlways
  else
    vGrid.FilterBox.Visible := fvNonEmpty;
end;

procedure TfGrid.bbInverseCheckedClick(Sender: TObject);
begin
  InverseSelection;
end;

procedure TfGrid.bbUncheckAllClick(Sender: TObject);
begin
  SelectAll(false);
end;

procedure TfGrid.bbUncheckFilteredClick(Sender: TObject);
begin
  SelectFiltered(false);
end;

procedure TfGrid.bbUncheckSelectedClick(Sender: TObject);
begin
  SelectSelected(false);
end;

procedure TfGrid.CreateList;
begin
{  if not Assigned(FFieldList) then
    FFieldList := TStringList.Create;      }
  if not Assigned(ResList) then
  begin
    ResList := TResourceList.Create;
    //PDS.Open;
    ResList.PictureList.OnPicChanged := OnListPicChanged;
    ResList.OnJobChanged := OnStartJob;
    ResList.PictureList.OnEndAddList := OnEndPicList;
    FPicChanged := nil;
  end else
    ResList.Clear;
end;

procedure TfGrid.ForcePicsStop(Sender: TObject);
begin
  ResList.DWNLDHandler.FinishThreads(true);
end;

procedure TfGrid.ForceStop(Sender: TObject);
begin

end;

procedure TfGrid.InverseSelection;
var
  i: integer;
  b: boolean;
begin
  vGrid.BeginUpdate;
  try
    for i := 0 to vGrid.DataController.RecordCount-1 do
    begin
      b := not vGrid.DataController.Values[i,FCheckColumn.Index];
      vGrid.DataController.Values[i,FCheckColumn.Index] := b;
      ResList.PictureList[i].Checked := b;
    end;
    vGrid.DataController.Post(true);
  finally
    vGrid.EndUpdate;
  end;
end;

procedure TfGrid.OnBeginPicList(Sender: TObject);
begin

end;

procedure TfGrid.OnEndPicList(Sender: TObject);
var
{  i,j: integer;
  APicture: TTPicture;
  //r,c: integer;
  t: integer;
  n: variant; }
  //FList: TPictureLinkList;
  c,i,j: integer;
  t1,t3: integer;
  n: TListValue;
  clm: TcxGridColumn;
begin
//  if vd.Active then
//  begin
    t1 := GetTickCount;
    //ResList.OnError(Self,''
    vGrid.BeginUpdate;

    c := vgrid.DataController.RecordCount;

    try
{    vd.DisableControls;
    c := vd.RecNo;
    vd.RecNo := vGrid.DataController.RecordCount;
    vd.Resync([]);
    vd.RecNo := c;
    vd.EnableControls;
    vGrid.EndUpdate; }

      //FList := Sender as TPictureLinkList;

       vgrid.DataController.RecordCount := ResList.PictureList.Count;

      with vGrid.DataController,ResList do
        for i := c to RecordCount -1 do
        begin
          Values[i,FCheckColumn.Index] := PictureList[i].Checked;
          Values[i,FIDColumn.Index] := Integer(PictureList[i]);
          Values[i,FParentColumn.Index] := Integer(PictureList[i].Parent);
          Values[i,FResColumn.Index] := PictureList[i].Resource.Name;
          Values[i,FLabelColumn.Index] := PictureList[i].DisplayLabel;
          for j := 0 to PictureList[i].Meta.Count -1 do
          begin
            n := PictureList[i].Meta.Items[j];
            clm := FFieldList.Objects[FFieldList.IndexOf(n.Name)] as tcxGridColumn;
            case clm.DataBinding.ValueType[1] of
              'S': Values[i,clm.Index] := VarToStr(n.Value);
              'B': Values[i,clm.Index] := n.Value;
              'I','L': Values[i,clm.Index] := n.Value;
              'F': Values[i,clm.Index] := n.Value;
              'D': Values[i,clm.Index] := VarToDateTime(n.Value);
            end;
            {Values[i,( as TcxGridColumn).Index]
              := PictureList[i].Meta.Items[j].Value;}
          end;
        end;
    finally
      vGrid.EndUpdate;
    end;

    if c = 0 then
      BestFitWidths(vGrid);

    t3 := GetTickCount;
    sBar.Panels[1].Text := 'TTL ' + IntToStr(vGrid.DataController.RecordCount)
      + ' IGN '  + IntToStr(ResList.PictureList.PicCounter.IGN)
      + ' TBL ' + IntToStr(t3 - t1) + 'ms'
      + ' DBL '  + IntToStr(ResList.PictureList.DoublestickCount) + 'ms';


//  end;
{  FList := Sender as TPictureLinkList;

  vGrid.BeginUpdate;
  n := vd.CurRec;
  t := vgrid.Controller.FocusedRecordIndex - vgrid.Controller.TopRecordIndex;
  md.DisableControls;
  for j := 0 to FList.Count -1 do
  begin
    APicture := FList[j];
    md.Insert;
    try
      //r := vGrid.DataController.InsertRecord(r);
      md.FieldValues['checked'] := APicture.Checked;
      md.FieldValues['resname'] := APicture.Resource.Name;
      md.FieldValues['label'] := APicture.DisplayLabel;
      md.FieldValues['id'] := Integer(APicture.Orig);
      md.FieldValues['parent'] := Integer(Apicture.Orig.Parent);
      for i := 0 to APicture.Meta.Count-1 do
      begin
          md.FieldValues['.' + APicture.Meta.Items[i].Name] := APicture.Meta.Items[i].Value;
      end;
      md.Post;
      APicture.Orig.BookMark := md.RecNo;
    except
      md.Cancel;
    end;
  end;
  md.EnableControls;
  if n > -1 then
    BestFitWidths(vGrid);
  vGrid.EndUpdate;

  if n < 0 then
  begin
    BestFitWidths(vGrid);
    n := 0;
  end;

    vgrid.DataController.FocusedRecordIndex := n;
    vgrid.Controller.TopRecordIndex := vgrid.Controller.FocusedRecordIndex - t;}
  //BestFitWidths(vGrid);
end;

procedure TfGrid.OnPicAdd(APicture: TTPicture);
begin
  //FList.Add(APicture);
end;

procedure TfGrid.OnListPicChanged(Pic: TTPicture; Changes: TPicChanges);
var
  n{,c}: integer;

begin
    n := Pic.BookMark - 1;

    with vGrid.DataController do
    begin
      if pcSize in Changes then
        if Pic.Size = 0 then
          Values[n,FSizeColumn.Index] := null
        else
          Values[n,FSizeColumn.Index] := GetBTString(Pic.Size);

      if pcProgress in Changes then
      begin
        if (Pic.Pos = 0) or (Pic.Pos = Pic.Size) then
          Values[n,FPosColumn.Index] := null
        else
          Values[n,FPosColumn.Index] := GetBTString(Pic.Pos);

        case Pic.Status of
          JOB_INPROGRESS:
          if Pic.Size = 0 then
            Values[n,FProgressColumn.Index] := 'START'
          else
            Values[n,FProgressColumn.Index] :=
              FormatFloat('00.00%',Pic.Pos/Pic.Size * 100);
          JOB_FINISHED:
            if Pic.Size = 0 then
            begin
              Values[n,FProgressColumn.Index] := 'SKIP';
              Application.ProcessMessages;
            end else
              Values[n,FProgressColumn.Index] := 'OK';
          JOB_ERROR: Values[n,FProgressColumn.Index] := 'ERROR';
          JOB_CANCELED: Values[n,FProgressColumn.Index] := 'ABORT';
        end;
      end;

    if pcLabel in Changes then
      Values[n,FLabelColumn.Index] := Pic.DisplayLabel;

    if pcChecked in Changes then
      Values[n,FCheckColumn.Index] := Pic.Checked;
    end;

    if (pcChecked in Changes) or (Changes = []) then
    begin
      sBar.Panels[1].Text := 'TTL ' + IntToStr(ResList.PictureList.Count)
        + ' OK ' + IntToStr(ResList.PictureList.PicCounter.OK)
        + ' SKP ' + IntToStr(ResList.PictureList.PicCounter.SKP)
        + ' EXS ' + IntToStr(ResList.PictureList.PicCounter.EXS)
        + ' ERR ' + IntToStr(ResList.PictureList.PicCounter.ERR);

      if (ResList.PictureList.Count - ResList.PictureList.PicCounter.SKP) > 0 then
        sBar.Panels[0].Text := FormatFloat('0.00%',
                                           ResList.PictureList.PicCounter.FSH
                                        / (ResList.PictureList.Count
                                        -  ResList.PictureList.PicCounter.SKP)
                                        *  100);

      if Assigned(ResList.OnPageComplete) then
        ResList.OnPageComplete(Pic.Resource);
    end;
end;

procedure TfGrid.OnStartJob(Sender: TObject; Action: integer);
begin
  PostMessage(Application.MainForm.Handle,CM_STARTJOB,Integer(Self.Parent),0);
  case Action of
    JOB_LIST:
      sBar.Panels[0].Text := lang('_ON_AIR_');
    JOB_PICS:
    begin
//      vGrid.BeginUpdate;
      FCheckColumn.Options.Editing := false;
//      iPicChecker.Properties.ReadOnly := true;
      SetColWidths;
      FSizeColumn.Visible := true;
      FPosColumn.Visible := true;
      FProgressColumn.Visible := true;
//      vGrid.EndUpdate;
      sBar.Panels[0].Text := lang('_ON_AIR_');
    end;
    JOB_STOPLIST:
      if ResList.PicsFinished then
        if not ResList.Canceled
        and GlobalSettings.Downl.SDALF then
          ResList.StartJob(JOB_PICS)
        else
      else
        sBar.Panels[0].Text := '';
    JOB_STOPPICS:
    begin
      FSizeColumn.Visible := false;
      FPosColumn.Visible := false;
      FProgressColumn.Visible := false;
      FCheckColumn.Options.Editing := true;
      if ResList.ListFinished then
        sBar.Panels[0].Text := '';
    end;
  end;
end;

procedure TfGrid.Relise;
begin
  //vd.Close;
  Screen.Cursor := crHourGlass;
  try
    if Assigned(ResList) then
      FreeAndNil(ResList);
    if Assigned(FFieldList) then
      FreeAndNil(FFieldList);
  finally
    Screen.Cursor := crDefault;
  end;
  //FList.Free;
  //FFieldList.Free;
{  vGrid.BeginUpdate;
  vGrid.DataController.RecordCount := 0;
  vGrid.ClearItems;
  vGrid.EndUpdate; }
  //vGrid.Free;
end;

procedure TfGrid.Reset;
var
  i: integer;
  c: tcxGridColumn;
  p: TMetaList;
//  b: boolean;
begin
  Grid.BeginUpdate;
  vGrid.ClearItems;
  vChilds.ClearItems;

{  if vd.Active then
  begin
    vd.Close;
    b := true;
  end else
    b := false;

  vd.Fields.Clear;}

  ResList.CreatePicFields;
//  md.DisableControls;
//  FFieldList := ResList.FullPicFieldList;
  //FFieldList.Insert(0,'resname');
  //c := vGrid.CreateColumn;
  //c.Visible := false;

  FCHeckColumn := AddField('checked:b',true);
  FCHeckColumn.Caption := '';
  //c.Visible := false;
  with FCHeckColumn.Options do
  begin
    HorzSizing := false;
    Filtering := false;
    Grouping := false;
    Moving := false;
    Sorting := false;
  end;
  FCHeckColumn.Width := 20;
  FCHeckColumn.VisibleForCustomization := false;

  FIdColumn := AddField('id:i');
  FIdColumn.Visible := false;
  FIdColumn.VisibleForCustomization := false;

  FParentColumn := AddField('parent:i');
  FParentColumn.Visible := false;
  FParentColumn.VisibleForCustomization := false;
{  c.SortOrder := soAscending;
  c.Width := 20;    }

{   vgrid.DataController.KeyFieldNames := 'RecId';

  c := vGrid.CreateColumn;
  c.DataBinding.FieldName := 'RecId';
  c.DataBinding.Field.DisplayLabel := _RESID_;   }

  FResColumn := AddField(lang('_RESNAME_'));
  //c.Caption := ;
//  FResColumn.GroupBy(0);

  FLabelColumn := AddField(lang('_PICTURELABEL_'));
  //FLabelColumn.Caption :=;

  FPosColumn := AddField(lang('_DOWNLOADED_'));
  with FPosColumn.Options do
  begin
    HorzSizing := false;
    //Filtering := false;
    Grouping := false;
    Moving := false;
    Sorting := false;
  end;
  FPosColumn.Visible := false;
  FPosColumn.VisibleForCustomization := false;

  FSizeColumn := AddField(lang('_SIZE_'));
  with FSizeColumn.Options do
  begin
    HorzSizing := false;
    Filtering := false;
    Grouping := false;
    Moving := false;
    Sorting := false;
  end;
  FSizeColumn.Visible := false;
  FSizeColumn.VisibleForCustomization := false;

  FProgressColumn := AddField(lang('_PROGRESS_'));
  with FProgressColumn.Options do
  begin
    HorzSizing := false;
    //Filtering := false;
    Grouping := false;
    Moving := false;
    Sorting := false;
  end;
  FProgressColumn.Visible := false;
  FProgressColumn.VisibleForCustomization := false;

  if not Assigned(FFieldList) then
    FFieldList := TStringList.Create
  else
    FFieldList.Clear;

  for i := 0 to ResList.PictureList.Meta.Count -1 do
  begin
    FFieldList.Insert(i,ResList.PictureList.Meta.Items[i].Name);
    p := ResList.PictureList.Meta.Items[i].Value;
    case p.ValueType of
      DB.ftString: c := AddField(ResList.PictureList.Meta.Items[i].Name);
      ftBoolean: c := AddField(ResList.PictureList.Meta.Items[i].Name + ':b');
      ftInteger: c := AddField(ResList.PictureList.Meta.Items[i].Name + ':i');
      ftFloat: c := AddField(ResList.PictureList.Meta.Items[i].Name + ':f');
      ftDateTime: c := AddField(ResList.PictureList.Meta.Items[i].Name + ':d');
      else c := AddField(ResList.PictureList.Meta.Items[i].Name);
    end;
    //c := AddField(FFieldList[i],'.');
    FFieldList.Objects[i] := c;
    c.Visible := false;
    //FFieldList.Objects[i] := c;
  end;
  //l.Free;

  FPosColumn.Index := vGrid.ItemCount;
  FSizeColumn.Index := vGrid.ItemCount;
  fProgressColumn.Index := vGrid.ItemCount;

{  if b then
    vd.Open;  }
{  md.EnableControls;  }
  Grid.EndUpdate;
end;

procedure TfGrid.SelectAll(b: boolean);
var
  i: integer;
begin
  vGrid.BeginUpdate;
  try
    for i := 0 to vGrid.DataController.RecordCount-1 do
    begin
      vGrid.DataController.Values[i,FCheckColumn.Index] := b;
      ResList.PictureList[i].Checked := b;
    end;
    vGrid.DataController.Post(true);
  finally
    vGrid.EndUpdate;
  end;
end;

procedure TfGrid.SelectFiltered(b: boolean);
var
  i: integer;
begin
  vGrid.BeginUpdate;
  try
    for i := 0 to vGrid.ViewData.RowCount-1 do
    begin
      vGrid.DataController.Values
        [vGrid.ViewData.Rows[i].RecordIndex,FCheckColumn.Index] := b;
      ResList.PictureList
        [vGrid.ViewData.Rows[i].RecordIndex].Checked := b;
    end;
    vGrid.DataController.Post(true);
  finally
    vGrid.EndUpdate;
  end;
end;

procedure TfGrid.SelectSelected(b: boolean);
var
  i: integer;
begin
  vGrid.BeginUpdate;
  try
    for i := 0 to vGrid.ViewData.RowCount-1 do
    if vGrid.ViewData.Rows[i].Selected then
    begin
      vGrid.DataController.Values
        [vGrid.ViewData.Rows[i].RecordIndex,FCheckColumn.Index] := b;
      ResList.PictureList
        [vGrid.ViewData.Rows[i].RecordIndex].Checked := b;
    end;
    vGrid.DataController.Post(true);
  finally
    vGrid.EndUpdate;
  end;
end;

procedure TfGrid.SetColWidths;
begin
  FSizeColumn.Width := 60;
  FPosColumn.Width := 60;
  FProgressColumn.Width := 60;
end;

procedure TfGrid.SetLang;
begin
  bbColumns.Caption := lang('_COLUMNS_');
  bbColumns.Hint := bbColumns.Caption;
  bbFilter.Caption := lang('_FILTER_');
  bbFilter.Hint := bbFilter.Caption;
  siCheck.Caption := lang('_CHECK_');
  siCheck.Hint := siCheck.Caption;
  siUncheck.Caption := lang('_UNCHECK_');
  siUncheck.Hint := siUncheck.Caption;
  bbCheckAll.Caption := lang('_ALL_');
  bbCheckAll.Hint := bbCheckAll.Caption;
  bbUncheckAll.Caption := bbCheckAll.Caption;
  bbUncheckAll.Hint := bbCheckAll.Caption;
  bbCheckSelected.Caption := lang('_CH_SELECTED_');
  bbCheckSelected.Hint := bbCheckSelected.Caption;
  bbUncheckSelected.Caption := bbCheckSelected.Caption;
  bbUncheckSelected.Hint := bbCheckSelected.Caption;
  bbCheckFiltered.Caption := lang('_CH_FILTERED_');
  bbCheckFiltered.Hint := bbCheckFiltered.Caption;
  bbUncheckFiltered.Caption := bbCheckFiltered.Caption;
  bbUncheckFiltered.Hint := bbCheckFiltered.Caption;
  bbInverseChecked.Caption := lang('_INVERSE_');
  bbInverseChecked.Hint := bbInverseChecked.Caption;
  bbAdditional.Caption := lang('_ADDITIONAL_');
  bbAdditional.Hint := bbAdditional.Caption;
  bbDALF.Caption := lang('_SDALF_');
  bbDALF.Hint := bbDALF.Caption;
end;

procedure TfGrid.SetSettings;
begin
  if GlobalSettings.Downl.UsePerRes then
    ResList.MaxThreadCount := GlobalSettings.Downl.PerResThreads
  else
    ResList.MaxThreadCount := 0;

  ResList.ThreadHandler.Proxy := Globalsettings.Proxy;
  ResList.ThreadHandler.ThreadCount := GlobalSettings.Downl.ThreadCount;
  ResList.ThreadHandler.Retries := GlobalSettings.Downl.Retries;

  ResList.DWNLDHandler.Proxy := Globalsettings.Proxy;
  ResList.DWNLDHandler.ThreadCount := GlobalSettings.Downl.PicThreads;
  ResList.DWNLDHandler.Retries := GlobalSettings.Downl.Retries;
  ResList.PictureList.IgnoreList := IgnoreList;

  bbDALF.Down := GlobalSettings.Downl.SDALF;
end;

procedure TfGrid.updatefocusedrecord;
var
  n: variant;
  p: TcxCustomGridRow;
begin
  if Assigned(FPicChanged){ and vd.Active} then
  begin
    p := vGrid.Controller.FocusedRow;

    if Assigned(p) and p.IsData then
      n := p.Values[FIdColumn.Index]
    else
      n := null;
    if n <> null then
      FPicChanged(Self,TTPicture(Integer(n)));
  end;
end;

procedure TfGrid.vdBeforeOpen(DataSet: TDataSet);
begin
  vGrid.BeginUpdate;
  vGrid.EndUpdate;
end;

procedure TfGrid.vdGetFieldValue(Sender: TCustomVirtualDataset; Field: TField;
  Index: Integer; var Value: Variant);
var
  p: TTPicture;
begin
  p := ResList.PictureList[Index];
  case Field.FieldNo of
    1: Value := p.Checked;
    2: Value := Integer(p);
    3: Value := Integer(p.Parent);
    4: Value := Copy(p.Resource.Name,1,Field.Size);
    5: Value := Copy(p.DisplayLabel,1,Field.Size);
    6:
      if p.Size = 0 then
        Value := ''
      else
        Value := GetBtString(p.Pos);
    7:
      if p.Size = 0 then
        Value := ''
      else
        Value := GetBtString(p.Size);
    8:
      if p.Size = 0 then
        if p.Checked then
          Value := 0
        else
          Value := 100
      else
        Value := p.Pos / p.Size * 100;
    else
      case Field.DataType of
        DB.ftString: Value := Copy(VarToStr(p.Meta[Field.DisplayName]),1,Field.Size);
        ftBoolean: Value := p.Meta[Field.DisplayName];
        ftInteger: Value := p.Meta[Field.DisplayName];
        ftFloat: Value := p.Meta[Field.DisplayName];
        ftDateTime: Value := VarToDateTime(p.Meta[Field.DisplayName]);
      end;
  end;
end;

procedure TfGrid.vdGetRecordCount(Sender: TCustomVirtualDataset;
  var Count: Integer);
begin
  Count := ResList.PictureList.Count;
end;

procedure TfGrid.vGrid1FocusedRecordChanged(Sender: TcxCustomGridTableView;
  APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
  ANewItemRecordFocusingChanged: Boolean);

begin
  updatefocusedrecord;
end;

procedure TfGrid.vGridEditValueChanged(Sender: TcxCustomGridTableView;
  AItem: TcxCustomGridTableItem);
var
  n: integer;
begin
  if AItem.Index <> FCheckColumn.Index then
    Exit;
  n := vGrid.DataController.FocusedRecordIndex;
  if n > -1 then
  begin
    ResList.PictureList[n].Checked := vGrid.DataController.Values[n,AItem.Index];
  end;
end;

end.
