unit GridFrame;

interface

uses
  {std}
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, DB, ExtCtrls,
  {devex}
 cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxDBData,
  cxCurrencyEdit, cxCheckBox, cxGridCustomPopupMenu, cxGridPopupMenu, dxBar,
  cxBarEditItem, cxClasses, cxEditRepositoryItems, cxExtEditRepositoryItems,
  dxStatusBar, cxGridLevel, cxGridCustomTableView, cxGridTableView,
  cxGridCustomView, cxGridDBTableView, cxGrid, dxSkinsCore,
  dxSkinsDefaultPainters, dxSkinscxPCPainter,dxSkinsdxStatusBarPainter,
  dxSkinsdxBarPainter,
  {graber}
  graberU, common;

type

  PDUInt64 = ^DUInt64;
  DUInt64 = packed record
    V1: UInt64;
    V2: UInt64;
  end;

  TfGrid = class(TFrame)
    GridLevel1: TcxGridLevel;
    Grid: TcxGrid;
    GridLevel2: TcxGridLevel;
    vChilds: TcxGridDBTableView;
    cxEditRepository1: TcxEditRepository;
    vGrid1: TcxGridDBTableView;
    BarManager: TdxBarManager;
    BarControl: TdxBarDockControl;
    TableActions: TdxBar;
    bbColumns: TdxBarButton;
    bbFilter: TdxBarButton;
    iPicChecker: TcxEditRepositoryCheckBoxItem;
    iCheckBox: TcxEditRepositoryCheckBoxItem;
    iPBar: TcxEditRepositoryProgressBar;
    vGrid: TcxGridTableView;
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
    iFloatEdit: TcxEditRepositoryCurrencyItem;
    iLabel: TcxEditRepositoryLabel;
    updTimer: TTimer;
    vGridColumn1: TcxGridColumn;
    iState: TcxEditRepositoryImageComboBoxItem;
    sBar: TdxStatusBar;
    bbAutoUnch: TdxBarButton;
    GridPopup: TcxGridPopupMenu;
    procedure bbColumnsClick(Sender: TObject);
    procedure bbFilterClick(Sender: TObject);
    procedure vGrid1FocusedRecordChanged(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    {procedure vdGetRecordCount(Sender: TCustomVirtualDataset;
      var Count: Integer);
    procedure vdGetFieldValue(Sender: TCustomVirtualDataset; Field: TField;
      Index: Integer; var Value: Variant);    }
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
    procedure updTimerTimer(Sender: TObject);
    procedure vGridColumn1GetProperties(Sender: TcxCustomGridTableItem;
      ARecord: TcxCustomGridRecord; var AProperties: TcxCustomEditProperties);
    procedure bbAutoUnchClick(Sender: TObject);
    procedure vGridFocusedItemChanged(Sender: TcxCustomGridTableView;
      APrevFocusedItem, AFocusedItem: TcxCustomGridTableItem);
    procedure vGridColumn1GetFilterValues(Sender: TcxCustomGridTableItem;
      AValueList: TcxDataFilterValueList);
  private
    //FList: TList;
//    FFieldList: TStringList;
    //FPageComplete: TNotifyEvent;
    FTagUpdate: TTagUpdateEvent;
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
    FChangesList: TList;
    //FStartSender: TObject;
//    FN: Integer;
    //FFirstC: TcxDBGridColumn;
    { Private declarations }
  public
    ResList: TResourceList;
    procedure Reset;
    procedure CreateList;
    //procedure OnPicAdd(APicture: TTPicture);
//    procedure CheckField(ch,s: string; value: variant);
    procedure OnStartJob(Sender: TObject; Action: Integer);
//    procedure OnEndJob(Sender: TObject);
    function AddField(s: string; base: boolean = false): TcxGridColumn;
//    procedure OnBeginPicList(Sender: TObject);
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
    procedure SaveFields;
    procedure updatepic(pic: ttpicture);
    procedure doUpdates;
    procedure UncheckInvisible;
    procedure updatechecks;
    procedure SetMenus;
    function Busy: byte;
    function getprogress: DUInt64;
    procedure sendprogress;
    property OnPicChanged: TPictureNotifyEvent read FPicChanged write FPicChanged;
    //property OnPageComplete: TNotifyEvent read FPageComplete write FPageComplete;
    property OnTagUpdate: TTagUpdateEvent read FTagUpdate write FTagUpdate;
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
      'v' : result.DataBinding.ValueType := 'Variant';
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
    result.RepositoryItem := iLabel;
  //result.DataBinding.ValueType := 'String';
end;

procedure TfGrid.bbAutoUnchClick(Sender: TObject);
begin
  GlobalSettings.Downl.AutoUncheckInvisible := bbAutoUnch.Down;
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

function TfGrid.Busy: byte;
begin
  if not ResList.ListFinished then
    result := 1
  else if not ResList.PicsFinished then
    result := 2
  else
    result := 0;
end;

procedure TfGrid.CreateList;
begin
{  if not Assigned(FFieldList) then
    FFieldList := TStringList.Create;      }
  if not Assigned(ResList) then
  begin
    ResList := TResourceList.Create;
    ResList.PictureList.OnPicChanged := OnListPicChanged;
    ResList.OnJobChanged := OnStartJob;
    ResList.PictureList.OnEndAddList := OnEndPicList;
    FPicChanged := nil;
  end else
    ResList.Clear;
end;

procedure TfGrid.doUpdates;
var
  i: integer;
  pic: TTPicture;
  r: TResource;
begin
  vGrid.BeginUpdate;
  i := 0;
  r := nil;
  while i < FChangesList.Count do
  begin
    pic := FChangesList[i];
    updatepic(pic);
    inc(i);
    if Assigned(r) then
      if (r <> pic.Resource) then
      begin
        if Assigned(ResList.OnPageComplete) then
          ResList.OnPageComplete(r);
        r := pic.Resource;
      end else
    else
      r := pic.Resource;
  end;

  if Assigned(r) and Assigned(ResList.OnPageComplete) then
    ResList.OnPageComplete(r);

  if i > 0 then
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
  end;

  FChangesList.Clear;

  vGrid.EndUpdate;

  SendProgress;
end;

procedure TfGrid.ForcePicsStop(Sender: TObject);
begin
  ResList.DWNLDHandler.FinishThreads(true);
end;

procedure TfGrid.ForceStop(Sender: TObject);
begin

end;

function TfGrid.getprogress: DUInt64;
begin
  result.V1 := ResList.PictureList.PicCounter.FSH;
  result.V2 := ResList.PictureList.Count
               - ResList.PictureList.PicCounter.SKP;
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

procedure TfGrid.OnEndPicList(Sender: TObject);
var
  c,i,j,idx: integer;
  t1,t3: integer;
  n: TListValue;
  clm: TcxGridColumn;
begin
    t1 := GetTickCount;
    vGrid.BeginUpdate;

    c := vgrid.DataController.RecordCount;

    try

      vgrid.DataController.RecordCount := ResList.PictureList.Count;

      with vGrid.DataController,ResList do
        for i := c to RecordCount -1 do
        begin
          Values[i,FCheckColumn.Index] := PictureList[i].Checked;
          Values[i,FIDColumn.Index] := Integer(PictureList[i]);
          Values[i,FParentColumn.Index] := Integer(PictureList[i].Parent);
          Values[i,FResColumn.Index] := PictureList[i].Resource.Name;
          Values[i,FLabelColumn.Index] := PictureList[i].DisplayLabel;
          {if PictureList[i].Meta.Count <> FFieldLIst.Count then
            raise Exception.Create('Picture Meta does not equal to grid fields'); }
          for j := 0 to PictureList[i].Meta.Count -1 do
          begin
            n := PictureList[i].Meta.Items[j];
            idx := FFieldList.IndexOf(n.Name);
            if idx <> -1 then
            begin
              clm := FFieldList.Objects[idx] as tcxGridColumn;
              case clm.DataBinding.ValueType[1] of
                'S': Values[i,clm.Index] := VarToStr(n.Value);
                'B': Values[i,clm.Index] := n.Value;
                'I','L': Values[i,clm.Index] := n.Value;
                'F': Values[i,clm.Index] := n.Value;
                'D': Values[i,clm.Index] := VarToDateTime(n.Value);
              end;
            end else
            begin
              IF Assigned(OnError) then
                OnError(Self,PictureList[i].Resource.Name + ': field ' + n.Name +
                ' does not declared in field list');
            end;
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
end;

procedure TfGrid.OnListPicChanged(Pic: TTPicture; Changes: TPicChanges);
begin
  Pic.Changes := Pic.Changes + Changes;
  if not ResList.PicsFinished then
  begin
    if FChangesList.IndexOf(Pic) = -1 then
      FChangesList.Add(Pic);
  end else
    updatepic(pic);
end;

procedure TfGrid.OnStartJob(Sender: TObject; Action: integer);
var
  c: integer;
begin
{
  if (Action = JOB_LIST) and (ResList.PicsFinished)
  or (Action = JOB_PICS) and (ResList.ListFinished) then
    PostMessage(Application.MainForm.Handle,CM_STARTJOB,Integer(Self.Parent),0)
  else if (Action = JOB_STOPLIST) and (ResList.PicsFinished)
  or (Action = JOB_STOPPICS) and (ResList.ListFinished) then
    PostMessage(Application.MainForm.Handle,CM_ENDJOB,Integer(Self.Parent),0);
}
  case Action of
    JOB_LIST:
    begin
      sBar.Panels[0].Text := lang('_ON_AIR_');
      PostMessage(Application.MainForm.Handle,CM_STARTJOB,Integer(Self.Parent),0);
    end;
    JOB_PICS:
    begin
//      vGrid.BeginUpdate;
      updTimer.Enabled := true;
      vGrid.OptionsData.Editing := false;
      //FCheckColumn.Options.Editing := false;
//      iPicChecker.Properties.ReadOnly := true;
      SetColWidths;
      FSizeColumn.Visible := true;
      FPosColumn.Visible := true;
      FProgressColumn.Visible := true;
//      vGrid.EndUpdate;
      sBar.Panels[0].Text := lang('_ON_AIR_');
      PostMessage(Application.MainForm.Handle,CM_STARTJOB,Integer(Self.Parent),1);
    end;
    JOB_STOPLIST:
    begin
      if ResList.PicsFinished then
      begin
        if not ResList.Canceled
        and GlobalSettings.Downl.SDALF then
          ResList.StartJob(JOB_PICS);
        sBar.Panels[0].Text := '';
      end;
      PostMessage(Application.MainForm.Handle,CM_ENDJOB,Integer(Self.Parent),0);
      c := TagDump.Count;
      TagDump.CopyTagList(ResList.PictureList.Tags);
      if c <> TagDump.Count then
        SaveTagDump;
    end;
    JOB_STOPPICS:
    begin
      updTimer.Enabled := false;
      if FChangesList.Count > 0 then
        doUpdates;
      FSizeColumn.Visible := false;
      FPosColumn.Visible := false;
      //FProgressColumn.Visible := false;
      vGrid.OptionsData.Editing := true;
      //FCheckColumn.Options.Editing := true;
      if ResList.ListFinished then
        sBar.Panels[0].Text := '';
      PostMessage(Application.MainForm.Handle,CM_ENDJOB,Integer(Self.Parent),1);
    end;
  end;
end;

procedure TfGrid.Relise;
begin
  //vd.Close
  Screen.Cursor := crHourGlass;
  try
    SaveFields;
    if Assigned(ResList) then
      FreeAndNil(ResList);
    if Assigned(FFieldList) then
      FreeAndNil(FFieldList);
    if Assigned(FChangesList) then
      FreeAndNil(FChangesList);
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
  def,grp: tstringlist;
//  b: boolean;
begin
  //EXIT;

  Grid.BeginUpdate;
  def := TStringList.Create;
  grp := tStringList.Create;
  try
    def.Text := StrToStrList(GlobalSettings.GUI.LastUsedFields,',');
    grp.Text := StrToStrList(GLobalSettings.GUI.LastUsedGrouping,',');
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

    FResColumn := AddField('');
    FResColumn.Visible := def.IndexOf('@resource') > -1;
    FResColumn.GroupIndex := grp.IndexOf('@resource');
    //c.Caption := ;
  //  FResColumn.GroupBy(0);

    FLabelColumn := AddField('');
    FLabelColumn.Visible := def.IndexOf('@label') > -1;
    FLabelColumn.GroupIndex := grp.IndexOf('@label');
    //FLabelColumn.GroupIndex := 1;
    //FLabelColumn.Caption :=;

    FPosColumn := AddField('');
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

    FSizeColumn := AddField('');
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

    FProgressColumn := AddField(':v');
    fProgressColumn.OnGetProperties := vGridColumn1GetProperties;
    with FProgressColumn.Options do
    begin
      HorzSizing := false;
      //Filtering := false;
      Grouping := false;
      Moving := false;
      Sorting := false;
    end;
    //FProgressColumn.Editable := false;
    FProgressColumn.Editing := false;
    FProgressColumn.Visible := false;
    FProgressColumn.VisibleForCustomization := false;
    FProgressColumn.OnGetFilterValues := vGridColumn1GetFilterValues;

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
        ftDateTime:
        begin
          c := AddField(ResList.PictureList.Meta.Items[i].Name + ':d');
          c.DateTimeGrouping := dtgByDate;
        end
        else c := AddField(ResList.PictureList.Meta.Items[i].Name);
      end;
      //c := AddField(FFieldList[i],'.');
      FFieldList.Objects[i] := c;
      c.Visible := def.IndexOf(FFieldList[i]) > -1;
      c.GroupIndex := grp.IndexOf(FFieldList[i]);
      //FFieldList.Objects[i] := c;
    end;
    //l.Free;

    FPosColumn.Index := vGrid.ItemCount;
    FSizeColumn.Index := vGrid.ItemCount;
    fProgressColumn.Index := vGrid.ItemCount;

  {  if b then
      vd.Open;  }
  {  md.EnableControls;  }

    if not assigned(FChangesList) then
      FChangesList := TList.Create;

  finally
    grp.Free;
    def.Free;
    Grid.EndUpdate;
  end;
end;

procedure TfGrid.SaveFields;
var
  i: integer;
  s: string;
  c: tcxGridColumn;
begin
  if FResColumn.Visible then      //fields
    s := '@resource'
  else
    s := '';

  if FLabelColumn.Visible then
    if s = '' then
      s := '@label'
    else
      s := s + ',@label';

  if FFieldList.Count > 0 then
  begin
    for i := 0 to FFieldList.Count-1 do
    begin
      c := FFieldList.Objects[i] as tcxGridColumn;
      if c.Visible then
        if s = '' then
          s := FFieldList[i]
        else
          s := s + ',' + FFieldList[i];
    end;
  end;
  GlobalSettings.GUI.LastUsedFields := s;

  s := '';                                    //grouping

  for i := 0 to vGrid.GroupedColumnCount-1 do
  begin
    c := vGrid.GroupedColumns[i];
    if c = FResColumn then
      if s = '' then
        s := '@resource'
      else
        s := s + ',@resource'
    else if c = FLabelColumn then
      if s = '' then
        s := '@label'
      else
        s := s + ',@label'
    else
      if s = '' then
        s := c.Caption
      else
        s := s + ',' + c.Caption;
  end;

  GlobalSettings.GUI.LastUsedGrouping := s;

  SaveGUISettings([gvGridFields]);
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

procedure TfGrid.sendprogress;
var
  p: DUInt64;
begin
  p := GetProgress;
  SendMessage(Application.MainForm.Handle,CM_JOBPROGRESS,Integer(Self.Parent),Integer(@p));
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
  bbAutoUnch.Caption := lang('_AUTOUNCHECKINVISIBLE_');
  bbDALF.Hint := bbAutoUnch.Caption;

  FResColumn.Caption := lang('_RESNAME_');
  FLabelColumn.Caption := lang('_PICTURELABEL_');
  FPosColumn.Caption := lang('_DOWNLOADED_');
  FSizeColumn.Caption := lang('_SIZE_');

  FProgressColumn.Caption := lang('_PROGRESS_');
end;

procedure TfGrid.SetMenus;
var
  i: integer;
begin
  if GlobalSettings.MenuCaptions then
    for i := 0 to BarManager.ItemCount-1 do
      if BarManager.Items[i] is tdxBarButton then
        (BarManager.Items[i] as tdxBarButton).PaintStyle := psCaptionGlyph
      else if BarManager.Items[i] is tdxBarSubItem  then
        (BarManager.Items[i] as tdxBarSubItem).ShowCaption := true
      else
  else
    for i := 0 to BarManager.ItemCount-1 do
      if BarManager.Items[i] is tdxBarButton then
        (BarManager.Items[i] as tdxBarButton).PaintStyle := psStandard
      else if BarManager.Items[i] is tdxBarSubItem  then
        (BarManager.Items[i] as tdxBarSubItem).ShowCaption := false;
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
  ResList.PictureList.IgnoreList := CopyDSArray(IgnoreList);

  bbDALF.Down := GlobalSettings.Downl.SDALF;
  bbAutoUnch.Down := GlobalSettings.Downl.AutoUncheckInvisible;
end;

procedure TfGrid.UncheckInvisible;
var
  i: integer;
begin
  vGrid.BeginUpdate;
  for i := 0 to VGrid.DataController.RecordCount-1 do
    if VGrid.DataController.FilteredIndexByRecordIndex[i] = -1 then
    begin
      vGrid.DataController.Values[i,FCheckColumn.Index] := false;
      ResList.PictureList[i].Checked := false;
    end;

  vGrid.DataController.Post(true);
  vGrid.EndUpdate;
end;

procedure TfGrid.updatechecks;
var
  i: integer;
begin
  vGrid.BeginUpdate;
  try
  for i := 0 to vGrid.DataController.RecordCount-1 do
  begin
    vGrid.DataController.Values[i,FPosColumn.Index] := null;
    vGrid.DataController.Values[i,FSizeColumn.Index] := null;
    if not ResList.PictureList[i].Checked and vGrid.DataController.Values[i,0] then
    begin
      vGrid.DataController.Values[i,FProgressColumn.Index] := 'SKIP';
      vGrid.DataController.Values[i,FCheckColumn.Index] := false;
    end else
      vGrid.DataController.Values[i,FProgressColumn.Index] := null;
  end;
  finally
    vGrid.EndUpdate;
  end;
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

procedure TfGrid.updatepic(pic: ttpicture);
var
  n: integer;
  Changes: TPicChanges;

begin
    //Pic.Changes
    Changes := Pic.Changes;

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
            Values[n,FProgressColumn.Index] := Pic.Pos/Pic.Size * 100;
              //FormatFloat('00.00%',);
          JOB_FINISHED:
            if Pic.Size = 0 then
            begin
              Values[n,FProgressColumn.Index] := 'SKIP';
              //vGrid.EndUpdate;
              //Application.ProcessMessages;
              //vGrid.BeginUpdate;
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

    pic.Changes := [];
end;

procedure TfGrid.updTimerTimer(Sender: TObject);
begin
  updTimer.Enabled := false;
  doUpdates;
  updTimer.Enabled := true;
end;

procedure TfGrid.vdBeforeOpen(DataSet: TDataSet);
begin
  vGrid.BeginUpdate;
  vGrid.EndUpdate;
end;

{procedure TfGrid.vdGetFieldValue(Sender: TCustomVirtualDataset; Field: TField;
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
end;    }

procedure TfGrid.vGrid1FocusedRecordChanged(Sender: TcxCustomGridTableView;
  APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
  ANewItemRecordFocusingChanged: Boolean);

begin
  if APrevFocusedRecord <> AFocusedRecord then
    updatefocusedrecord;
end;

procedure TfGrid.vGridColumn1GetFilterValues(Sender: TcxCustomGridTableItem;
  AValueList: TcxDataFilterValueList);
begin
  AValueList.Clear;
  AValueList.Add(fviAll,0,'ALL',true);
  AValueList.Add(fviBlanks,0,'BLANK',true);
  AValueList.Add(fviNonBlanks,0,'NONBLANK',true);
  AValueList.Add(fviValue,'OK','OK',true);
  AValueList.Add(fviValue,'SKIP','SKIP',true);
  AValueList.Add(fviValue,'ERROR','ERROR',true);
  AValueList.Add(fviValue,'START','START',true);
  AValueList.Add(fviValue,'ABORT','ABORT',true);
end;

procedure TfGrid.vGridColumn1GetProperties(Sender: TcxCustomGridTableItem;
  ARecord: TcxCustomGridRecord; var AProperties: TcxCustomEditProperties);
var
  n: variant;

begin

  n := ARecord.Values[Sender.Index];
  if VarType(ARecord.Values[Sender.Index]) = varDouble then
    AProperties := iPBar.Properties
  else
    AProperties := iState.Properties;

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

procedure TfGrid.vGridFocusedItemChanged(Sender: TcxCustomGridTableView;
  APrevFocusedItem, AFocusedItem: TcxCustomGridTableItem);
begin
  Sender.OptionsData.Editing := ResList.PicsFinished and
    (AFocusedItem <> FProgressColumn);

end;

end.
