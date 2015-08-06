unit GridFrame;

interface

uses
  {std}
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, DB, ExtCtrls, DateUtils, math, UITypes,
  {devex}
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxDBData,
  cxCurrencyEdit, cxCheckBox, cxGridCustomPopupMenu, cxGridPopupMenu, dxBar,
  cxBarEditItem, cxClasses, cxEditRepositoryItems, cxExtEditRepositoryItems,
  dxStatusBar, cxGridLevel, cxGridCustomTableView, cxGridTableView,
  cxGridCustomView, cxGridDBTableView, cxGrid, dxSkinsCore,
  dxSkinsDefaultPainters, dxSkinscxPCPainter, dxSkinsdxStatusBarPainter,
  dxSkinsdxBarPainter, cxNavigator, dxBarExtItems,
  {graber}
  graberU, common, ProgressForm;

type

  PDUInt64 = ^DUInt64;

  DUInt64 = packed record
    V1: UInt64;
    V2: UInt64;
  end;

  TmycxOnGetExpandable = procedure(MasterDataRow: TcxGridMasterDataRow;
    var Expandable: Boolean) of object;

  TcxGridTableView = class(cxGridTableView.TcxGridTableView)
  private
    fOnGetExpandable: TmycxOnGetExpandable;
  protected
    function GetViewDataClass: TcxCustomGridViewDataClass; override;
  public
    constructor Create(AOwner: TComponent); override;
    property OnGetExpandable: TmycxOnGetExpandable read fOnGetExpandable
      write fOnGetExpandable;
  end;

  TcxGridViewData = class(cxGridTableView.TcxGridViewData)
  protected
    function GetRecordClass(const ARecordInfo: TcxRowInfo)
      : TcxCustomGridRecordClass; override;
  end;

  TmycxGridMasterDataRow = class(TcxGridMasterDataRow)
  protected
    function GetExpandable: Boolean; override;
  end;

  tTickMeter = record
    Tick: Word;
    Size: Word;
    LowDate: TDateTime;
  end;

  tTickCounter = record
    TA: array [0 .. 99] of tTickMeter;
    TAPos: Byte;
    TAMax: Byte;
    // AVGSpeed: Word;
    TickSum: Extended;
    SizeSum: Extended;
    FDate: TDateTime;
    LowDate, HighDate: TDateTime;
  end;

  TfGrid = class(TFrame)
    GridLevel1: TcxGridLevel;
    Grid: TcxGrid;
    GridLevel2: TcxGridLevel;
    cxEditRepository1: TcxEditRepository;
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
    iState: TcxEditRepositoryImageComboBoxItem;
    sBar: TdxStatusBar;
    bbAutoUnch: TdxBarButton;
    GridPopup: TcxGridPopupMenu;
    vChildGrid: TcxGridTableView;
    bbWriteEXIF: TdxBarButton;
    bbUncheckBlacklisted: TdxBarButton;
    bbCheckBlacklisted: TdxBarButton;
    SignalTimer: TTimer;
    procedure bbColumnsClick(Sender: TObject);
    procedure bbFilterClick(Sender: TObject);
    procedure vGrid1FocusedRecordChanged(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    { procedure vdGetRecordCount(Sender: TCustomVirtualDataset;
      var Count: Integer);
      procedure vdGetFieldValue(Sender: TCustomVirtualDataset; Field: TField;
      Index: Integer; var Value: Variant); }
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
    procedure GridLevel2GetGridView(Sender: TcxGridLevel;
      AMasterRecord: TcxCustomGridRecord; var AGridView: TcxCustomGridView);
    procedure vGridDataControllerDetailExpanded(ADataController
      : TcxCustomDataController; ARecordIndex: Integer);
    procedure vChildGridEditValueChanged(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem);
    procedure vChildGridFocusedItemChanged(Sender: TcxCustomGridTableView;
      APrevFocusedItem, AFocusedItem: TcxCustomGridTableItem);
    procedure GridFocusedViewChanged(Sender: TcxCustomGrid;
      APrevFocusedView, AFocusedView: TcxCustomGridView);
    procedure bbCheckBlacklistedClick(Sender: TObject);
    procedure bbUncheckBlacklistedClick(Sender: TObject);
    procedure SignalTimerTimer(Sender: TObject);
  private
    // FList: TList;
    // FFieldList: TStringList;
    // FPageComplete: TNotifyEvent;
    FTagUpdate: TTagUpdateEvent;
    FPicChanged: TPictureNotifyEvent;
    FFieldList: TStringList;
    FChangesList: TList;

    { columns }
    FCheckColumn: TcxGridColumn;
    FIdColumn: TcxGridColumn;
    FLabelColumn: TcxGridColumn;
    FProgressColumn: TcxGridColumn;
    FSizeColumn: TcxGridColumn;
    FPosColumn: TcxGridColumn;
    FResColumn: TcxGridColumn;

    { child columns }
    FChildCheckColumn: TcxGridColumn;
    FChildIdColumn: TcxGridColumn;
    FChildLabelColumn: TcxGridColumn;
    FChildProgressColumn: TcxGridColumn;
    FChildSizeColumn: TcxGridColumn;
    FChildPosColumn: TcxGridColumn;
    FChildResColumn: TcxGridColumn;

    FOnLog: TLogEvent;
    FOnError: TLogEvent;
    fUpdCnt: Integer;
    fTimeString: string;
    fTickCounter: tTickCounter;
    fSignalTimer: Integer;
    fLoading: Boolean;
    fCallBackProgress: tCallbackProgress;
    fProgress: tfProgress;
    fWindowList: TTaskWindowList;
    fAutorun: boolean;
    procedure DoOnError(Sender: TObject; Msg: String; Data: Pointer);
  public
    ResList: TResourceList;
    procedure vGridRecordExpandable(MasterDataRow: TcxGridMasterDataRow;
      var Expandable: Boolean);
    procedure Reset(fCB: tCallbackProgress = nil);
    // procedure CreateList;
    // procedure OnPicAdd(APicture: TTPicture);
    // procedure CheckField(ch,s: string; value: variant);
    procedure OnStartJob(Sender: TObject; Action: Integer);
    // procedure OnEndJob(Sender: TObject);
    function AddField(g: TcxGridTableView; s: string; base: Boolean = false)
      : TcxGridColumn;
    // procedure OnBeginPicList(Sender: TObject);
    procedure OnEndPicList(Sender: TObject);
    procedure Relise;
    procedure SetLang;
    procedure OnListPicChanged(Pic: TTPicture; Changes: TPicChanges);
    procedure SetColWidths;
    procedure updatefocusedrecord(rec: TcxCustomGridRecord);
    procedure ForceStop(Sender: TObject);
    procedure ForcePicsStop(Sender: TObject);
    procedure SetSettings(list, pics: Boolean);
    procedure SelectAll(b: Boolean);
    procedure SelectSelected(b: Boolean);
    procedure SelectFiltered(b: Boolean);
    procedure InverseSelection;
    procedure SaveFields;
    procedure updatepic(Pic: TTPicture);
    procedure doUpdates;
    procedure UncheckInvisible;
    procedure updatechecks;
    procedure SetMenus;
    function Busy: Byte;
    function getprogress: DUInt64;
    procedure sendprogress;
    procedure SetChildColWidths(clone: TcxGridTableView);
    procedure FillRecord(dc: tcxGridDataController; RecNo: Integer;
      Pic: TTPicture);
    procedure DeleteMD5Doubles;
    procedure Log(s: string);
    procedure SetList(l: TResourceList);
    procedure Recheck(n: Integer);
    procedure CalcStats;
    procedure ResetTickCounter;
    procedure AddTick(ASize: Word; DTStart, DTEnd: TDateTime);
    procedure SelectBlacklisted(b: Boolean);
    procedure OnSendStop(Sender: TObject; Msg: String; Data: Pointer);
    procedure CallbackCloseCall(Sendet: TObject);
    procedure ApplyChanges(r: TResourceList);
    property OnPicChanged: TPictureNotifyEvent read FPicChanged
      write FPicChanged;
    // property OnPageComplete: TNotifyEvent read FPageComplete write FPageComplete;
    property OnTagUpdate: TTagUpdateEvent read FTagUpdate write FTagUpdate;
    property OnLog: TLogEvent read FOnLog write FOnLog;
    property OnError: TLogEvent read FOnError write FOnError;
    property Loading: Boolean read fLoading write fLoading;
    property Autorun: Boolean read fAutorun write fAutorun;
    { Public declarations }
  end;

  TcxGridSiteAccess = class(TcxGridSite);
  TcxGridPopupMenuAccess = class(TcxGridPopupMenu);

implementation

uses LangString, utils, OpBase;

{$R *.dfm}

function DateTimeToMilliseconds(const ADateTime: TDateTime): Int64;
var
  LTimeStamp: TTimeStamp;
begin
  LTimeStamp := DateTimeToTimeStamp(ADateTime);
  Result := LTimeStamp.Date;
  Result := (Result * MSecsPerDay) + LTimeStamp.Time;
end;

{ TmycxGridTableView }

constructor TcxGridTableView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  OnGetExpandable := nil;
end;

function TcxGridTableView.GetViewDataClass: TcxCustomGridViewDataClass;
begin
  Result := TcxGridViewData;
end;

{ TmycxGridViewData }

function TcxGridViewData.GetRecordClass(const ARecordInfo: TcxRowInfo)
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
  if Assigned((GridView as TcxGridTableView).OnGetExpandable) then
    (GridView as TcxGridTableView).OnGetExpandable(Self, Result)
  else
    Result := inherited GetExpandable;
end;

{ TfGrid }

procedure TfGrid.DoOnError(Sender: TObject; Msg: String; Data: Pointer);
begin
  if Assigned(OnError) then
    OnError(Self, Msg, Data);
end;

procedure TfGrid.vGridRecordExpandable(MasterDataRow: TcxGridMasterDataRow;
  var Expandable: Boolean);
begin
  Expandable := TTPicture(Integer(MasterDataRow.Values[FIdColumn.Index]))
    .Linked.Count > 0;
  // lLabel.Caption := TTPicture(Integer(MasterDataRow.Values[fIdColumn.Index])).Linked.Count > 0;
end;

function TfGrid.AddField(g: TcxGridTableView; s: string; base: Boolean = false)
  : TcxGridColumn;
var
  n: string;

begin
  n := GetNextS(s, ':');

  Result := g.CreateColumn;
  Result.Caption := n;

  if s <> '' then
    case s[1] of
      'i':
        Result.DataBinding.ValueType := 'Integer';
      'l':
        Result.DataBinding.ValueType := 'LargeInt';
      'd':
        Result.DataBinding.ValueType := 'DateTime';
      'b':
        Result.DataBinding.ValueType := 'Boolean';
      'f':
        Result.DataBinding.ValueType := 'Float';
      'p':
        Result.DataBinding.ValueType := 'Float';
      'v':
        Result.DataBinding.ValueType := 'Variant';
    else
      Result.DataBinding.ValueType := 'String';
    end
  else
    Result.DataBinding.ValueType := 'String';

  if SameText(s, 'b') then
    if base then
      Result.RepositoryItem := iPicChecker
    else
      Result.RepositoryItem := iCheckBox
  else if SameText(s, 'f') then
    Result.RepositoryItem := iFloatEdit
  else if SameText(s, 'p') then
    Result.RepositoryItem := iPBar
  else
    Result.RepositoryItem := iLabel;
  // result.DataBinding.ValueType := 'String';
end;

procedure TfGrid.AddTick(ASize: Word; DTStart, DTEnd: TDateTime);
var
  ntick: Word;
begin
  with fTickCounter do
  begin
    if LowDate = 0 then
      LowDate := DTStart;

    if HighDate = 0 then
      HighDate := DTEnd;

    ntick := Max(0, DateTimeToMilliseconds(LowDate) - DateTimeToMilliseconds
      (DTStart)) + Max(0, DateTimeToMilliseconds(DTEnd) - DateTimeToMilliseconds
      (HighDate));

    if (DTEnd > HighDate) then
      HighDate := DTEnd;

    TickSum := TickSum - TA[TAPos].Tick + ntick;
    SizeSum := SizeSum - TA[TAPos].Size + ASize;

    if TA[TAPos].LowDate > LowDate then
      LowDate := TA[TAPos].LowDate;

    TA[TAPos].Tick := ntick;
    TA[TAPos].Size := ASize;
    TAPos := (TAPos + 1) mod 100;
    if TAMax < 100 then
      inc(TAMax);
  end;
end;

procedure TfGrid.ApplyChanges(r: TResourceList);
var
  i: Integer;
  rs: tResource;
begin
  i := 0;
  while i < ResList.Count do
  begin
    ResList[i].NameFormat := r[i].NameFormat;
    if not Assigned(ResList[i].MainResource) then
      ResList[i].ThreadCounter^ := r[i].ThreadCounter^;
    inc(i);
  end;

  while i < r.Count do
  begin
    rs := ResList[ResList.CopyResource(r[i])];
    if Assigned(r[i].MainResource) then
      if Assigned(r[i].MainResource.MainResource) then
        rs.MainResource := r[i].MainResource.MainResource
      else
      begin
        rs.MainResource := r[i].MainResource;
        rs.SetThreadCounter(r[i].MainResource.ThreadCounter);
      end
    else
    begin
      r[i].MainResource := rs;
      rs.SetThreadCounter(r[i].ThreadCounter);
    end;
    inc(i);
  end;
end;

procedure TfGrid.bbAutoUnchClick(Sender: TObject);
begin
  GlobalSettings.Downl.AutoUncheckInvisible := bbAutoUnch.Down;
end;

procedure TfGrid.bbCheckAllClick(Sender: TObject);
begin
  SelectAll(true);
end;

procedure TfGrid.bbCheckBlacklistedClick(Sender: TObject);
begin
  SelectBlacklisted(true);
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
  TcxGridPopupMenuAccess(GridPopup)
    .GridOperationHelper.DoShowColumnCustomizing(true);
end;

procedure TfGrid.bbDALFClick(Sender: TObject);
begin
  // GlobalSettings.Downl.SDALF := bbDALF.Down;
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

procedure TfGrid.bbUncheckBlacklistedClick(Sender: TObject);
begin
  SelectBlacklisted(false);
end;

procedure TfGrid.bbUncheckFilteredClick(Sender: TObject);
begin
  SelectFiltered(false);
end;

procedure TfGrid.bbUncheckSelectedClick(Sender: TObject);
begin
  SelectSelected(false);
end;

function TfGrid.Busy: Byte;
begin
  if not ResList.ListFinished then
    Result := 1
  else if not ResList.PicsFinished then
    Result := 2
  else
    Result := 0;
end;

procedure TfGrid.CalcStats;
var
  n: Word;
begin
  with fTickCounter do
  begin
    if TickSum > 0 then
      sBar.Panels[1].Text := GetBtString(SizeSum / TickSum { / TAMax } * 1000)
    else
      sBar.Panels[1].Text := '';

    n := SecondsBetween(Date + Time, FDate);
    if (FDate > 0) and (n > 10) then
      sBar.Panels[2].Text := TimeString(n)
    else
      sBar.Panels[2].Text := '';
  end;

end;

procedure TfGrid.CallbackCloseCall(Sendet: TObject);
begin
  ResList.StartJob(JOB_STOPLIST);
end;

// procedure TfGrid.CreateList;
// begin
// { if not Assigned(FFieldList) then
// FFieldList := TStringList.Create; }
// if not Assigned(ResList) then
// begin
// ResList := TResourceList.Create;
// ResList.PictureList.OnPicChanged := OnListPicChanged;
// ResList.OnJobChanged := OnStartJob;
// ResList.PictureList.OnEndAddList := OnEndPicList;
// FPicChanged := nil;
//
// end
// else
// ResList.Clear;
// end;

procedure TfGrid.DeleteMD5Doubles;
var
  i, n, c: Integer;
  md5list: tMetaList;
  // p: ttpicture;
begin
  if MessageDlg(lang('_CONFIRM_DELETEMD5_'), mtConfirmation, [mbYes, mbNo], 0)
    <> mrYes then
    Exit;

  c := 0;
  md5list := tMetaList.Create;
  md5list.ValueType := DB.ftString;
  try
    with ResList.PictureList do
    begin
      ResList.PictureList.LockList{('deletemd5')};
      try
        for i := 0 to ResList.PictureList.Count - 1 do
        begin
          if Assigned(ItemList[i].MD5) then
            if md5list.FindPosition(ItemList[i].MD5^, n) then
            begin
              ItemList[i].DeleteFile;
              inc(c);
            end
            else
              md5list.Add(ItemList[i].MD5^, n);
        end;
      finally
        ResList.PictureList.UnlockList;
      end;
    end;
    Log(Format(lang('_DELETED_COUNT_'), [c]));
  finally
    md5list.Free;
  end;
end;

procedure TfGrid.doUpdates;
var
  i: Integer;
  Pic: TTPicture;
  r: tResource;
  btw: Int64;
  ndt: TDateTime;
begin
  vGrid.BeginUpdate;
  try
    i := 0;
    r := nil;
    while i < FChangesList.Count do
    begin
      Pic := FChangesList[i];
      updatepic(Pic);
      inc(i);
      if Assigned(r) then
        if (r <> Pic.Resource) then
        begin
          if Assigned(ResList.OnPageComplete) then
            ResList.OnPageComplete(r);
          r := Pic.Resource;
        end
        else
      else
        r := Pic.Resource;
    end;

    if Assigned(r) and Assigned(ResList.OnPageComplete) then
      ResList.OnPageComplete(r);

    with ResList.PictureList do
    begin

      sBar.Panels[1].Text := fTimeString;

      if i > 0 then
      begin

        if (PicCounter.FSH - PicCounter.EXS) = 0 then
          // fTimeString := '???'
        else if fUpdCnt <> (PicCounter.FSH - PicCounter.EXS - PicCounter.ERR)
        then
        begin
          btw := SecondsBetween(ResList.PictureStartTime, Date + Time);
          with PicCounter do
            ndt := IncSecond(Date + Time,
              Trunc(btw / FSH * (Count - SKP - FSH + EXS + ERR)));
          if SecondsBetween(fTickCounter.FDate, ndt) > 5 then
            fTickCounter.FDate := ndt;
          fUpdCnt := PicCounter.FSH - PicCounter.EXS - PicCounter.ERR;
        end;

        sBar.Panels[3].Text := 'TTL ' + IntToStr(Count) + ' OK ' +
          IntToStr(PicCounter.OK) + ' SKP ' + IntToStr(PicCounter.SKP) + ' EXS '
          + IntToStr(PicCounter.EXS) + ' ERR ' + IntToStr(PicCounter.ERR);

        if ResList.ListFinished and
          ((ResList.PictureList.Count - ResList.PictureList.PicCounter.SKP) > 0)
        then
          sBar.Panels[0].Text := FormatFloat('0.00%',
            ResList.PictureList.PicCounter.FSH / (ResList.PictureList.Count -
            ResList.PictureList.PicCounter.SKP) * 100);
      end;

      CalcStats;

      FChangesList.Clear;
    end;
  finally
    vGrid.EndUpdate;
    sendprogress;
  end;
end;

procedure TfGrid.FillRecord(dc: tcxGridDataController; RecNo: Integer;
  Pic: TTPicture);
var
  j, idx: Integer;
  n: TListValue;
  clm: TcxGridColumn;
begin
  if Assigned(Pic.Parent) { or (dc.RecordCount <= RecNo) } then
    Exit;

  for j := 0 to Pic.Meta.Count - 1 do
  begin
    n := Pic.Meta.Items[j];
    idx := FFieldList.IndexOf(n.Name);
    if idx <> -1 then
    begin
      clm := FFieldList.Objects[idx] as TcxGridColumn;
      case clm.DataBinding.ValueType[1] of
        'S':
          dc.Values[RecNo, clm.Index] := VarToStr(n.Value);
        'B':
          dc.Values[RecNo, clm.Index] := n.Value;
        'I', 'L':
          dc.Values[RecNo, clm.Index] := n.Value;
        'F':
          dc.Values[RecNo, clm.Index] := n.Value;
        'D':
          dc.Values[RecNo, clm.Index] := VarToDateTime(n.Value);
      end;
    end
    else
    begin
      IF Assigned(ResList.OnError) then
        ResList.OnError(Self, Pic.Resource.Name + ': field ' + n.Name +
          ' does not declared in field list', nil);
    end;
  end;
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
  Result.V1 := ResList.PictureList.PicCounter.FSH;
  Result.V2 := ResList.PictureList.Count - ResList.PictureList.PicCounter.SKP;
end;

procedure TfGrid.GridFocusedViewChanged(Sender: TcxCustomGrid;
  APrevFocusedView, AFocusedView: TcxCustomGridView);
begin
  updatefocusedrecord((AFocusedView as TcxGridTableView).Controller.FocusedRow);
end;

procedure TfGrid.GridLevel2GetGridView(Sender: TcxGridLevel;
  AMasterRecord: TcxCustomGridRecord; var AGridView: TcxCustomGridView);
begin
  PostMessage(Handle, CM_EXPROW, Integer(AMasterRecord), Integer(AGridView));
end;

procedure TfGrid.InverseSelection;
var
  i: Integer;
  b: Boolean;
begin
  if not ResList.PicsFinished then
    Exit;

  vGrid.BeginUpdate;
  try
    with ResList.PictureList do
    begin
      ResList.PictureList.LockList{('inverse')};
      try
        for i := 0 to vGrid.DataController.RecordCount - 1 do
        begin
          b := not vGrid.DataController.Values[i, FCheckColumn.Index];
          vGrid.DataController.Values[i, FCheckColumn.Index] := b;
          ItemList[i].Checked := b;
          if ItemList[i].Linked.Count > 0 then
            Recheck(i);
        end;
      finally
        ResList.PictureList.UnlockList;
      end;
    end;
    vGrid.DataController.Post(true);
  finally
    vGrid.EndUpdate;
  end;
end;

procedure TfGrid.Log(s: string);
begin
  if Assigned(OnLog) then
    OnLog(Self, s, nil);
end;

procedure TfGrid.OnEndPicList(Sender: TObject);
var
  c, i { , j, idx } : Integer;
  t1, t3: Integer;
  // n: TListValue;
  // clm: TcxGridColumn;
  cnc: Boolean;
begin
  t1 := GetTickCount;
  vGrid.BeginUpdate;
  try
    cnc := false;
    c := vGrid.DataController.RecordCount;

    vGrid.DataController.RecordCount := ResList.PictureList.ParentCount;

    with vGrid.DataController, ResList do
    begin
      PictureList.LockList{('endpic')};
      try
        for i := c to RecordCount - 1 do
        begin
          Values[i, FCheckColumn.Index] := PictureList.ItemList[i].Checked;
          Values[i, FIdColumn.Index] := Integer(PictureList.ItemList[i]);
          Values[i, FResColumn.Index] := PictureList.ItemList[i].Resource.Name;
          Values[i, FLabelColumn.Index] := PictureList.ItemList[i].DisplayLabel;
          FillRecord(vGrid.DataController, i, PictureList.ItemList[i]);

          if Assigned(fCallBackProgress) and (i mod 1000 = 0) then
            fCallBackProgress(i + 1, RecordCount, cnc);

        end;
      finally
        PictureList.UnlockList;
      end;
    end;

    if Assigned(fCallBackProgress) then
      fCallBackProgress(vGrid.DataController.RecordCount,
        vGrid.DataController.RecordCount, cnc);

  finally
    vGrid.EndUpdate;
  end;

  // ShowMessage('r1');
  if c = 0 then
    BestFitWidths(vGrid, vGrid.DataController.RecordCount - 1000);
  // ShowMessage('r2');

  t3 := GetTickCount;

  if ResList.PicsFinished then
    sBar.Panels[3].Text := 'TTL ' + IntToStr(ResList.PictureList.Count) +
      ' IGN ' + IntToStr(ResList.PictureList.PicCounter.IGN) + ' BLK ' +
      IntToStr(ResList.PictureList.PicCounter.BLK) + ' TBL ' + IntToStr(t3 - t1)
      + 'ms' + ' DBL ' + IntToStr(ResList.PictureList.DoublestickCount) + 'ms';

  if fAutorun and not fLoading and ResList.PicsFinished and not ResList.PostProcDelayed and
    (GlobalSettings.SemiJob <> sljNone) and (ResList.Count > 0) then
    begin
      fAutorun := false;
      case GlobalSettings.SemiJob of
        sljPostProc:
          ResList.StartJob(JOB_POSTPROCESS);
        sljPics:
          ResList.StartJob(JOB_PICS);
      end;
    end;
end;

procedure TfGrid.OnListPicChanged(Pic: TTPicture; Changes: TPicChanges);
begin
  Pic.Changes := Pic.Changes + Changes;
  if Pic.LastPos > 0 then
    AddTick(Pic.Pos - Pic.LastPos, Pic.DTStart, Pic.DTEnd);

  if updTimer.Enabled then
  begin
    if FChangesList.IndexOf(Pic) = -1 then
      FChangesList.Add(Pic);
  end
  else
  //begin
    //ResList.PictureList.LockList;
    //try
      updatepic(Pic);
    //finally
    //  ResList.PictureList.UnlockList;
    //end;
  //end;
end;

procedure TfGrid.OnSendStop(Sender: TObject; Msg: String; Data: Pointer);
begin
  if Boolean(Data) and (GlobalSettings.StopSignalTimer > 0) then
  begin
    OnError(Self, 'Stop signal sent with a reason: ' + Msg + '. Restart after '
      + IntToStr(GlobalSettings.StopSignalTimer) + ' sec', nil);
    fSignalTimer := GlobalSettings.StopSignalTimer;
    SignalTimer.Enabled := true;
  end
  else
    OnError(Self, 'Stop signal sent with a reason: ' + Msg, nil);

  ResList.StartJob(JOB_STOPPICS);
end;

procedure TfGrid.OnStartJob(Sender: TObject; Action: Integer);
var
  c: Integer;
begin
  {
    if (Action = JOB_LIST) and (ResList.PicsFinished)
    or (Action = JOB_PICS) and (ResList.ListFinished) then
    PostMessage(Application.MainForm.Handle,CM_STARTJOB,Integer(Self.Parent),0)
    else if (Action = JOB_STOPLIST) and (ResList.PicsFinished)
    or (Action = JOB_STOPPICS) and (ResList.ListFinished) then
    PostMessage(Application.MainForm.Handle,CM_ENDJOB,Integer(Self.Parent),0);
  }
  if Action in [JOB_PICS, JOB_POSTPROCESS] then
    SignalTimer.Enabled := false;
  case Action of
    JOB_LOGIN:
      begin
        Loading := true;
        try
          Application.ModalStarted;
          Application.CreateForm(tfProgress, fProgress);

          // if Assigned(fProgress) then
          fProgress.CloseCall := CallbackCloseCall;
          // if Assigned(fProgress) then
          fProgress.SetText(lang('_LOGGINGIN_'));
          Screen.FocusedForm := fProgress;
          // if Assigned(fProgress) then
          fWindowList := DisableTaskWindows(0);
          // if Assigned(fProgress) then
          fProgress.Show;
          // if Assigned(fProgress) then
          SendMessage(fProgress.Handle, CM_ACTIVATE, 0, 0);
        finally
          Loading := false;
        end;
        if ResList.ListFinished then
          OnStartJob(Sender, JOB_STOPLIST);
      end;
    JOB_POSTPROCESS:
      begin
        vGrid.OptionsData.Editing := false;
        vChildGrid.OptionsData.Editing := false;
        SetColWidths;
        FSizeColumn.Visible := true;
        FPosColumn.Visible := true;
        FProgressColumn.Visible := true;
        FChildSizeColumn.Visible := true;
        FChildPosColumn.Visible := true;
        FChildProgressColumn.Visible := true;
        updTimer.Enabled := true;
      end;
    JOB_LIST:
      begin
        if ResList.PicsFinished and updTimer.Enabled then
          updTimer.Enabled := false;

        sBar.Panels[0].Text := lang('_ON_AIR_');
        PostMessage(Application.MainForm.Handle, CM_STARTJOB,
          Integer(Self.Parent), 0);
      end;
    JOB_PICS:
      begin
        // vGrid.BeginUpdate;
        // fTotalSize := 0;
        // fCurrentSize := 0;

        updTimer.Enabled := true;
        vGrid.OptionsData.Editing := false;
        vChildGrid.OptionsData.Editing := false;
        SetColWidths;
        FSizeColumn.Visible := true;
        FPosColumn.Visible := true;
        FProgressColumn.Visible := true;
        FChildSizeColumn.Visible := true;
        FChildPosColumn.Visible := true;
        FChildProgressColumn.Visible := true;
        // vGrid.EndUpdate;
        sBar.Panels[0].Text := lang('_ON_AIR_');
        PostMessage(Application.MainForm.Handle, CM_STARTJOB,
          Integer(Self.Parent), 1);
      end;
    JOB_STOPLIST:
      begin

        if not Loading and Assigned(fProgress) then
        begin
          EnableTaskWindows(fWindowList);
          // SendMessage(fProgress.Handle, CM_DEACTIVATE, 0, 0);
          // Screen.FocusedForm := nil;
          // if GetActiveWindow <> Handle then ActiveWindow := 0;
          Application.ModalFinished;
          FreeAndNil(fProgress);
          Exit;
        end;

        c := TagDump.Count;
        TagDump.CopyTagList(ResList.PictureList.Tags);

        if c <> TagDump.Count then
          SaveTagDump;

        if ResList.PicsFinished then
        begin
          // if not ResList.Canceled and GlobalSettings.Downl.SDALF then
          // ResList.StartJob(JOB_PICS);
          sBar.Panels[0].Text := '';

          // FSizeColumn.Visible := false;
          // FPosColumn.Visible := false;
          // FChildSizeColumn.Visible := false;
          // FChildPosColumn.Visible := false;
        end;

        PostMessage(Application.MainForm.Handle, CM_ENDJOB,
          Integer(Self.Parent), 0);
      end;
    JOB_STOPPICS:
      begin
        updTimer.Enabled := false;
        if FChangesList.Count > 0 then
          doUpdates;
        FSizeColumn.Visible := false;
        FPosColumn.Visible := false;
        FChildSizeColumn.Visible := false;
        FChildPosColumn.Visible := false;
        vGrid.OptionsData.Editing := true;
        vChildGrid.OptionsData.Editing := true;

        if ResList.ListFinished then
        begin
          sBar.Panels[0].Text := '';
          sBar.Panels[1].Text := '';
          sBar.Panels[2].Text := '';
        end;

        PostMessage(Application.MainForm.Handle, CM_ENDJOB,
          Integer(Self.Parent), 1);
      end;
  end;
end;

procedure TfGrid.Relise;
begin
  // vd.Close
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
  // FList.Free;
  // FFieldList.Free;
  { vGrid.BeginUpdate;
    vGrid.DataController.RecordCount := 0;
    vGrid.ClearItems;
    vGrid.EndUpdate; }
  // vGrid.Free;
end;

procedure TfGrid.Reset(fCB: tCallbackProgress = nil);

var
  i: Integer;
  c: TcxGridColumn;
  p: tMetaList;
  def, grp: TStringList;
  // b: boolean;

  procedure CreateBaseFields(g: TcxGridTableView;
    var CheckColumn: TcxGridColumn; var IdColumn: TcxGridColumn;
    var ProgressColumn: TcxGridColumn; var SizeColumn: TcxGridColumn;
    var PosColumn: TcxGridColumn; var LabelColumn: TcxGridColumn;
    var ResColumn: TcxGridColumn; DefPos: Boolean = true);
  begin
    CheckColumn := AddField(g, 'checked:b', true);
    CheckColumn.Caption := '';
    with CheckColumn.Options do
    begin
      HorzSizing := false;
      Filtering := false;
      Grouping := false;
      Moving := false;
      Sorting := false;
    end;
    CheckColumn.Width := 20;
    CheckColumn.VisibleForCustomization := false;

    IdColumn := AddField(g, 'id:i');
    IdColumn.Visible := false;
    IdColumn.VisibleForCustomization := false;

    ResColumn := AddField(g, '');
    if DefPos then
    begin
      ResColumn.Visible := def.IndexOf('@resource') > -1;
      ResColumn.GroupIndex := grp.IndexOf('@resource');
    end
    else
      ResColumn.Visible := false;

    LabelColumn := AddField(g, '');
    if DefPos then
    begin
      LabelColumn.Visible := def.IndexOf('@label') > -1;
      LabelColumn.GroupIndex := grp.IndexOf('@label');
    end
    else
      LabelColumn.Visible := true;

    PosColumn := AddField(g, '');
    with PosColumn.Options do
    begin
      HorzSizing := false;
      Grouping := false;
      Moving := false;
      Sorting := false;
    end;
    PosColumn.Visible := false;
    PosColumn.Width := 60;
    PosColumn.VisibleForCustomization := false;

    SizeColumn := AddField(g, '');
    with SizeColumn.Options do
    begin
      HorzSizing := false;
      Filtering := false;
      Grouping := false;
      Moving := false;
      Sorting := false;
    end;
    SizeColumn.Visible := false;
    SizeColumn.Width := 60;
    SizeColumn.VisibleForCustomization := false;

    ProgressColumn := AddField(g, ':v');
    ProgressColumn.OnGetProperties := vGridColumn1GetProperties;
    with ProgressColumn.Options do
    begin
      HorzSizing := false;
      Grouping := false;
      Moving := false;
      Sorting := false;
    end;
    ProgressColumn.Editing := false;
    ProgressColumn.Visible := false;
    ProgressColumn.Width := 60;
    ProgressColumn.VisibleForCustomization := false;
    ProgressColumn.OnGetFilterValues := vGridColumn1GetFilterValues;
  end;

begin
  // EXIT;

  Grid.BeginUpdate;
  try
    def := TStringList.Create;
    grp := TStringList.Create;
    try
      def.Text := StrToStrList(GlobalSettings.GUI.LastUsedFields, ',');
      grp.Text := StrToStrList(GlobalSettings.GUI.LastUsedGrouping, ',');
      vGrid.ClearItems;
      vChildGrid.ClearItems;

      CreateBaseFields(vGrid, FCheckColumn, FIdColumn, FProgressColumn,
        FSizeColumn, FPosColumn, FLabelColumn, FResColumn);

      CreateBaseFields(vChildGrid, FChildCheckColumn, FChildIdColumn,
        FChildProgressColumn, FChildSizeColumn, FChildPosColumn,
        FChildLabelColumn, FChildResColumn, false);

      if not Assigned(FFieldList) then
        FFieldList := TStringList.Create
      else
        FFieldList.Clear;

      for i := 0 to ResList.PictureList.Meta.Count - 1 do
        if ResList.PictureList.Meta.Items[i].Name <> '' then
        begin
          FFieldList.Add(ResList.PictureList.Meta.Items[i].Name);
          p := ResList.PictureList.Meta.Items[i].Value;
          case p.ValueType of
            DB.ftString:
              c := AddField(vGrid, ResList.PictureList.Meta.Items[i].Name);
            ftBoolean:
              c := AddField(vGrid, ResList.PictureList.Meta.Items[i]
                .Name + ':b');
            ftInteger:
              c := AddField(vGrid, ResList.PictureList.Meta.Items[i]
                .Name + ':i');
            ftFloat:
              c := AddField(vGrid, ResList.PictureList.Meta.Items[i]
                .Name + ':f');
            ftDateTime:
              begin
                c := AddField(vGrid, ResList.PictureList.Meta.Items[i]
                  .Name + ':d');
                c.DateTimeGrouping := dtgByDate;
              end
          else
            c := AddField(vGrid, ResList.PictureList.Meta.Items[i].Name);
          end;
          FFieldList.Objects[FFieldList.Count - 1] := c;
          c.Visible := def.IndexOf(FFieldList[FFieldList.Count - 1]) > -1;
          c.GroupIndex := grp.IndexOf(FFieldList[FFieldList.Count - 1]);
        end;

      FPosColumn.Index := vGrid.ItemCount;
      FSizeColumn.Index := vGrid.ItemCount;
      FProgressColumn.Index := vGrid.ItemCount;

      if not Assigned(FChangesList) then
        FChangesList := TList.Create;

      vGrid.OnGetExpandable := vGridRecordExpandable;

      fCallBackProgress := fCB;
      try
        OnEndPicList(nil);
      finally
        fCallBackProgress := nil;
      end;

    finally
      grp.Free;
      def.Free;
    end;
  finally
    Grid.EndUpdate;
  end;
end;

procedure TfGrid.ResetTickCounter;
var
  i: Integer;
begin
  with fTickCounter do
  begin
    TAPos := 0;
    TAMax := 0;
    TickSum := 0;
    SizeSum := 0;
    FDate := 0;
    LowDate := 0;
    HighDate := 0;

    for i := 0 to 99 do
    begin
      TA[i].Tick := 0;
      TA[i].Size := 0;
    end;
  end;
end;

procedure TfGrid.SaveFields;
var
  i: Integer;
  s: string;
  c: TcxGridColumn;
begin
  if FResColumn.Visible then // fields
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
    for i := 0 to FFieldList.Count - 1 do
    begin
      c := FFieldList.Objects[i] as TcxGridColumn;
      if c.Visible then
        if s = '' then
          s := FFieldList[i]
        else
          s := s + ',' + FFieldList[i];
    end;
  end;
  GlobalSettings.GUI.LastUsedFields := s;

  s := ''; // grouping

  for i := 0 to vGrid.GroupedColumnCount - 1 do
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
    else if s = '' then
      s := c.Caption
    else
      s := s + ',' + c.Caption;
  end;

  GlobalSettings.GUI.LastUsedGrouping := s;

  SaveGUISettings([gvGridFields]);
end;

procedure TfGrid.SelectAll(b: Boolean);
var
  i: Integer;
begin
  if not ResList.PicsFinished then
    Exit;

  vGrid.BeginUpdate;
  try
    with ResList.PictureList do
    begin
      ResList.PictureList.LockList{('selAll')};
      try
        for i := 0 to vGrid.DataController.RecordCount - 1 do
        begin
          vGrid.DataController.Values[i, FCheckColumn.Index] := b;
          ItemList[i].Checked := b;
          if ItemList[i].Linked.Count > 0 then
            Recheck(i);
        end;
      finally
        ResList.PictureList.UnlockList;
      end;
    end;
    vGrid.DataController.Post(true);
  finally
    vGrid.EndUpdate;
  end;
end;

procedure TfGrid.SelectBlacklisted(b: Boolean);
var
  i: Integer;
begin
  if not ResList.PicsFinished then
    Exit;

  vGrid.BeginUpdate;
  try
    with ResList.PictureList do
    begin
      ResList.PictureList.LockList{('selBL')};
      try
        for i := 0 to vGrid.DataController.RecordCount - 1 do
          if ResList.PictureList.CheckBlackList(ResList.PictureList[i]) then
          begin
            vGrid.DataController.Values[i, FCheckColumn.Index] := b;
            ItemList[i].Checked := b;
            if ItemList[i].Linked.Count > 0 then
              Recheck(i);
          end;
      finally
        ResList.PictureList.UnlockList;
      end;
    end;
    vGrid.DataController.Post(true);
  finally
    vGrid.EndUpdate;
  end;
end;

procedure TfGrid.SelectFiltered(b: Boolean);
var
  i: Integer;
begin
  if not ResList.PicsFinished then
    Exit;

  vGrid.BeginUpdate;
  try
    ResList.PictureList.LockList{('selFil')};
    try
      with ResList.PictureList do
      begin
        for i := 0 to vGrid.ViewData.RowCount - 1 do
        begin
          vGrid.DataController.Values[vGrid.ViewData.Rows[i].RecordIndex,
            FCheckColumn.Index] := b;
          ItemList[vGrid.ViewData.Rows[i].RecordIndex].Checked := b;
          if ItemList[i].Linked.Count > 0 then
            Recheck(i);
        end;
      end;
    finally
      ResList.PictureList.UnlockList;
    end;
    vGrid.DataController.Post(true);
  finally
    vGrid.EndUpdate;
  end;
end;

procedure TfGrid.SelectSelected(b: Boolean);
var
  i: Integer;
  Pic: TTPicture;
begin
  if not ResList.PicsFinished then
    Exit;

  vGrid.BeginUpdate;
  try
    ResList.PictureList.LockList{('SelSel')};
    try
      with ResList.PictureList do
        if Grid.FocusedView = vGrid then
          for i := 0 to vGrid.Controller.SelectedRecordCount - 1 do
          begin
            vGrid.Controller.SelectedRecords[i].Values[FCheckColumn.Index] := b;
            ItemList[vGrid.Controller.SelectedRecords[i].RecordIndex]
              .Checked := b;
            if ItemList[i].Linked.Count > 0 then
              Recheck(i);
          end
        else
          with (Grid.FocusedView as TcxGridTableView) do
            for i := 0 to Controller.SelectedRecordCount - 1 do
            begin
              Pic := TTPicture
                (Integer(Controller.SelectedRecords[i].Values
                [FChildIdColumn.Index]));
              Controller.SelectedRecords[i].Values
                [FChildCheckColumn.Index] := b;
              Pic.Checked := b;
              Pic.Parent.Checked := true;
              Pic.Parent.Changes := [pcChecked];
              updatepic(Pic.Parent);
            end;
    finally
      ResList.PictureList.UnlockList;
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
  p := getprogress;
  SendMessage(Application.MainForm.Handle, CM_JOBPROGRESS, Integer(Self.Parent),
    Integer(@p));
end;

procedure TfGrid.SetColWidths;
begin
  FSizeColumn.Width := 60;
  FPosColumn.Width := 60;
  FProgressColumn.Width := 60;
  FChildSizeColumn.Width := 60;
  FChildPosColumn.Width := 60;
  FChildProgressColumn.Width := 60;
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
  bbCheckBlacklisted.Caption := lang('_CH_BLACKLISTED_');
  bbCheckBlacklisted.Hint := bbUncheckBlacklisted.Caption;
  bbUncheckBlacklisted.Caption := lang('_CH_BLACKLISTED_');
  bbUncheckBlacklisted.Hint := bbUncheckBlacklisted.Caption;
  bbInverseChecked.Caption := lang('_INVERSE_');
  bbInverseChecked.Hint := bbInverseChecked.Caption;
  bbAdditional.Caption := lang('_ADDITIONAL_');
  bbAdditional.Hint := bbAdditional.Caption;
  bbDALF.Caption := lang('_SDALF_');
  bbDALF.Hint := bbDALF.Caption;
  bbAutoUnch.Caption := lang('_AUTOUNCHECKINVISIBLE_');
  bbDALF.Hint := bbAutoUnch.Caption;
  bbWriteEXIF.Caption := lang('_WRITEEXIF_');
  bbWriteEXIF.Hint := bbWriteEXIF.Caption;

  FResColumn.Caption := lang('_RESNAME_');
  FLabelColumn.Caption := lang('_PICTURELABEL_');
  FPosColumn.Caption := lang('_DOWNLOADED_');
  FSizeColumn.Caption := lang('_SIZE_');

  FProgressColumn.Caption := lang('_PROGRESS_');
  vGrid.OptionsView.NoDataToDisplayInfoText := lang('_GRIDNODATA_');
end;

procedure TfGrid.SetList(l: TResourceList);
begin
  // if not Assigned(ResList) then
  // begin
  fAutorun := false;
  ResList := l;
  ResList.PictureList.OnPicChanged := OnListPicChanged;
  ResList.OnJobChanged := OnStartJob;
  ResList.PictureList.OnEndAddList := OnEndPicList;
  ResList.OnError := DoOnError;
  ResList.OnSendStop := OnSendStop;
  FPicChanged := nil;

  // end
  // else
  // ResList.Clear;
end;

procedure TfGrid.SetChildColWidths(clone: TcxGridTableView);
begin
  // FChildSizeColumn.Width := 60;
  // FChildPosColumn.Width := 60;
  // FChildProgressColumn.Width := 60;
  // clone.Columns[FChildSizeColumn.Index].Options := FChildSizeColumn.Options;
  clone.Columns[FChildSizeColumn.Index].Width := FChildSizeColumn.Width;

  // clone.Columns[FChildPosColumn.Index].Options := FChildPosColumn.Options;
  clone.Columns[FChildPosColumn.Index].Width := FChildPosColumn.Width;

  // clone.Columns[FChildProgressColumn.Index].Options.HorzSizing := false;
  clone.Columns[FChildProgressColumn.Index].Width := FChildProgressColumn.Width;
  // for i := 0 to clone.ColumnCount -1 do
  // begin
  // clone.Columns[i].Width := 10;
  // end;
  // (clone.Items[FChildProgressColumn.Index] as tcxGridColumn).Visible := false;
end;

procedure TfGrid.SetMenus;
var
  i: Integer;
begin
  if GlobalSettings.MenuCaptions then
    for i := 0 to BarManager.ItemCount - 1 do
      if BarManager.Items[i] is TdxBarButton then
        (BarManager.Items[i] as TdxBarButton).PaintStyle := psCaptionGlyph
      else if BarManager.Items[i] is TdxBarSubItem then
        (BarManager.Items[i] as TdxBarSubItem).ShowCaption := true
      else
    else
      for i := 0 to BarManager.ItemCount - 1 do
        if BarManager.Items[i] is TdxBarButton then
          (BarManager.Items[i] as TdxBarButton).PaintStyle := psStandard
        else if BarManager.Items[i] is TdxBarSubItem then
          (BarManager.Items[i] as TdxBarSubItem).ShowCaption := false;
end;

procedure TfGrid.SetSettings(list, pics: Boolean);
begin
  SetConSettings(ResList, list, pics);
  // bbDALF.Down := GlobalSettings.Downl.SDALF;
  bbAutoUnch.Down := GlobalSettings.Downl.AutoUncheckInvisible;
end;

procedure TfGrid.SignalTimerTimer(Sender: TObject);
begin
  if fSignalTimer > 0 then
    dec(fSignalTimer)
  else
  begin
    SignalTimer.Enabled := false;
    ResList.StartJob(JOB_PICS);
  end;
end;

procedure TfGrid.UncheckInvisible;
var
  i: Integer;
begin
  vGrid.BeginUpdate;
  try
    ResList.PictureList.LockList{('UnInvi')};
    try
      with ResList.PictureList do
        for i := 0 to vGrid.DataController.RecordCount - 1 do
          if vGrid.DataController.FilteredIndexByRecordIndex[i] = -1 then
          begin
            vGrid.DataController.Values[i, FCheckColumn.Index] := false;
            ItemList[i].Checked := false;
          end;

    finally
      ResList.PictureList.UnlockList;
    end;
    vGrid.DataController.Post(true);
  finally
    vGrid.EndUpdate;
  end;
end;

procedure TfGrid.Recheck(n: Integer);
var
  // n: Integer;
  i: Integer;
  p: TTPicture;
begin
  // if AItem.Index <> FCheckColumn.Index then
  // Exit;
  // n := vGrid.DataController.FocusedRecordIndex;
  vGrid.BeginUpdate;
  try

    if n > -1 then
    begin
      p := ResList.PictureList.LockList(n{,'recheck'});
      try
        p.Checked := vGrid.DataController.Values[n, FCheckColumn.Index];
        if p.Linked.Count > 0 then
          for i := 0 to p.Linked.Count - 1 do
          begin
            p.Linked.ItemList[i].Checked := vGrid.DataController.Values
              [n, FCheckColumn.Index];
            p.Linked.ItemList[i].Changes := [pcChecked];
            updatepic(p.Linked[i]);
          end;
      finally
        ResList.PictureList.UnlockList;
      end;
    end;
  finally
    vGrid.EndUpdate;
  end;
end;

procedure TfGrid.updatechecks;
var
  i: Integer;
//  p: TTPicture;
begin
  vGrid.BeginUpdate;
  try
    ResList.PictureList.LockList{('updChecks')};
    try
      with ResList.PictureList do
        for i := 0 to vGrid.DataController.RecordCount - 1 do
        begin
          vGrid.DataController.Values[i, FPosColumn.Index] := null;
          vGrid.DataController.Values[i, FSizeColumn.Index] := null;
          if not ItemList[i].Checked and vGrid.DataController.Values[i, 0] then
          begin
            vGrid.DataController.Values[i, FProgressColumn.Index] := 'SKIP';
            vGrid.DataController.Values[i, FCheckColumn.Index] := false;
          end
          else
            vGrid.DataController.Values[i, FProgressColumn.Index] := null;
        end;
    finally
      ResList.PictureList.UnlockList;
    end;
  finally
    vGrid.EndUpdate;
  end;
end;

procedure TfGrid.updatefocusedrecord;
var
  n: variant;
  // p: TcxCustomGridRow;
begin
  if Assigned(FPicChanged) { and vd.Active } then
  begin
    // p := vGrid.Controller.FocusedRow;

    if Assigned(rec) and rec.IsData then
      n := rec.Values[FIdColumn.Index]
    else
      n := null;
    if n <> null then
      FPicChanged(Self, TTPicture(Integer(n)));
  end;
end;

procedure TfGrid.updatepic(Pic: TTPicture);
var
  n: Integer;
  Changes: TPicChanges;
  dc: tcxGridDataController;
  sc, pc, prgc, lc, cc: TcxGridColumn;
begin
  // Exit;
  // Pic.Changes

  Changes := Pic.Changes;

  dc := vGrid.DataController;

  if Assigned(Pic.Parent) then
  begin
    n := Pic.Parent.BookMark - 1;

    dc := tcxGridDataController(dc.GetDetailDataController(n, 0));

    if not Assigned(dc) or (dc.RecordCount < Pic.BookMark) then
      Exit;

    sc := FChildSizeColumn;
    pc := FChildPosColumn;
    prgc := FChildProgressColumn;
    lc := FChildLabelColumn;
    cc := FChildCheckColumn;
  end
  else
  begin
    sc := FSizeColumn;
    pc := FPosColumn;
    prgc := FProgressColumn;
    lc := FLabelColumn;
    cc := FCheckColumn;
  end;

  // ADetailDC := TcxGridDataController(ADataController.GetDetailDataController(ARecordIndex, 0));

  n := Pic.BookMark - 1;

  with dc do
  begin
    if pcData in Changes then
    begin
      FillRecord(dc, n, Pic);

      if (Grid.FocusedView = dc.GridView) and (dc.FocusedRecordIndex = n) then
        FPicChanged(Self, Pic);
    end;

    if pcSize in Changes then
    begin
      if not(pcProgress in Changes) then
        Values[n, pc.Index] := null;

      if Pic.Size = 0 then
        Values[n, sc.Index] := null
      else
        Values[n, sc.Index] := GetBtString(Pic.Size);
    end;

    if pcProgress in Changes then
    begin
      if (Pic.Pos = 0) or (Pic.Pos = Pic.Size) then
        Values[n, pc.Index] := null
      else
        Values[n, pc.Index] := GetBtString(Pic.Pos);

      case Pic.Status of
        JOB_NOJOB:
          Values[n, prgc.Index] := null;
        JOB_DELAY:
          Values[n, prgc.Index] := 'DELAY';
        JOB_INPROGRESS:
          if (Pic.Size = 0) and (Pic.Linked.Count = 0) then
            Values[n, prgc.Index] := 'START'
          else if (Pic.Linked.Count = 0) then
            Values[n, prgc.Index] := Pic.Pos / Pic.Size * 100
          else
            Values[n, prgc.Index] := Pic.Linked.PicCounter.FSH /
              Pic.Linked.Count * 100;
        // FormatFloat('00.00%',);
        JOB_FINISHED, JOB_POSTFINISHED:
          if (Pic.Size = 0) and (Pic.Linked.Count = 0) then
            Values[n, prgc.Index] := 'SKIP'
          else if (Pic.Linked.Count = 0) then
            Values[n, prgc.Index] := 'OK'
          else if Pic.Linked.PicCounter.ERR > 0 then
            Values[n, prgc.Index] := 'ERROR'
          else if Pic.Linked.PicCounter.OK = 0 then
            Values[n, prgc.Index] := 'SKIP'
          else
            Values[n, prgc.Index] := 'OK';
        JOB_ERROR:
          Values[n, prgc.Index] := 'ERROR';
        JOB_CANCELED:
          Values[n, prgc.Index] := 'ABORT';
        JOB_REFRESH, JOB_POSTPROCINPROGRESS:
          Values[n, prgc.Index] := 'REFRESH';
        JOB_BLACKLISTED:
          Values[n, prgc.Index] := 'BLACKLISTED';
      end;
    end;

    if pcLabel in Changes then
      Values[n, lc.Index] := Pic.DisplayLabel;

    if pcChecked in Changes then
      Values[n, cc.Index] := Pic.Checked;
  end;

  Pic.Changes := [];
end;

procedure TfGrid.updTimerTimer(Sender: TObject);
begin
  updTimer.Enabled := false;
  doUpdates;
  updTimer.Enabled := true;
end;

procedure TfGrid.vChildGridEditValueChanged(Sender: TcxCustomGridTableView;
  AItem: TcxCustomGridTableItem);
var
  n: Integer;
  Pic: TTPicture;
begin
  if AItem.Index <> FChildCheckColumn.Index then
    Exit;
  n := Sender.DataController.FocusedRecordIndex;
  if n > -1 then
  begin
    Pic := TTPicture(Integer(Sender.DataController.Values[n,
      FChildIdColumn.Index]));
    Pic.Checked := Sender.DataController.Values[n, AItem.Index];
    Pic.Parent.Checked := true;
    Pic.Parent.Changes := [pcChecked];
    updatepic(Pic.Parent);

    // ResList.PictureList[n].Checked := vGrid.DataController.Values
    // [n, AItem.Index];
  end;
end;

procedure TfGrid.vChildGridFocusedItemChanged(Sender: TcxCustomGridTableView;
  APrevFocusedItem, AFocusedItem: TcxCustomGridTableItem);
begin
  Sender.OptionsData.Editing := ResList.PicsFinished and
    (AFocusedItem <> FChildProgressColumn);
end;

procedure TfGrid.vdBeforeOpen(DataSet: TDataSet);
begin
  vGrid.BeginUpdate;
  vGrid.EndUpdate;
end;

procedure TfGrid.vGrid1FocusedRecordChanged(Sender: TcxCustomGridTableView;
  APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
  ANewItemRecordFocusingChanged: Boolean);

begin
  // AFocusedRecord.is
  if APrevFocusedRecord <> AFocusedRecord then
    updatefocusedrecord(AFocusedRecord);
end;

procedure TfGrid.vGridColumn1GetFilterValues(Sender: TcxCustomGridTableItem;
  AValueList: TcxDataFilterValueList);
begin
  AValueList.Clear;
  AValueList.Add(fviAll, 0, 'ALL', true);
  AValueList.Add(fviBlanks, 0, 'BLANK', true);
  AValueList.Add(fviNonBlanks, 0, 'NONBLANK', true);
  AValueList.Add(fviValue, 'OK', 'OK', true);
  AValueList.Add(fviValue, 'SKIP', 'SKIP', true);
  AValueList.Add(fviValue, 'ERROR', 'ERROR', true);
  AValueList.Add(fviValue, 'START', 'START', true);
  AValueList.Add(fviValue, 'ABORT', 'ABORT', true);
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

procedure TfGrid.vGridDataControllerDetailExpanded(ADataController
  : TcxCustomDataController; ARecordIndex: Integer);
var
  ADetailDC: tcxGridDataController;
  AMasterRecord: TcxCustomGridRecord;
  viewClone: TcxGridTableView;
  i: Integer;
  // str: string;
  ARowIndex: Integer;
  Pic: TTPicture;
begin
  ADetailDC := tcxGridDataController(ADataController.GetDetailDataController
    (ARecordIndex, 0));
  ARowIndex := ADataController.GetRowIndexByRecordIndex(ARecordIndex, false);
  if ARowIndex < 0 then
    Exit;
  AMasterRecord := tcxGridDataController(ADataController)
    .GridView.ViewData.Records[ARowIndex];
  viewClone := TcxGridTableView(ADetailDC.GridView);

  viewClone.DataController.BeginUpdate;
  try
    ResList.PictureList.LockList{('detailExpanded')};
    try
      Pic := TTPicture(Integer(AMasterRecord.Values[FIdColumn.Index]));
      // viewClone.DataController.RecordCount := 5;
      //
      // for i:=0 to viewClone.DataController.RecordCount-1 do
      // viewClone.DataController.Values[i,FChildLabelColumn.Index] := 'Row: '+inttostr(i+1);
      viewClone.DataController.RecordCount := Pic.Linked.Count;
      for i := 0 to Pic.Linked.Count - 1 do
      begin
        viewClone.DataController.Values[i, FChildIdColumn.Index] :=
          Integer(Pic.Linked[i]);
        viewClone.DataController.Values[i, FChildCheckColumn.Index] :=
          Pic.Linked.ItemList[i].Checked;
        viewClone.DataController.Values[i, FChildLabelColumn.Index] :=
          Pic.Linked.ItemList[i].DisplayLabel;
        updatepic(Pic.Linked[i]);
      end;
    finally
      ResList.PictureList.UnlockList;
    end;

  finally
    viewClone.DataController.EndUpdate;
    // SetChildColWidths(viewClone);
  end;
end;

procedure TfGrid.vGridEditValueChanged(Sender: TcxCustomGridTableView;
  AItem: TcxCustomGridTableItem);
var
  n: Integer;
  p: TTPicture;
  // i: Integer;
begin
  if AItem.Index <> FCheckColumn.Index then
    Exit;
  n := vGrid.DataController.FocusedRecordIndex;
  p := ResList.PictureList.LockList(n{,'ValueChanged'});
  try
    if n > -1 then
    begin
      p.Checked := vGrid.DataController.Values[n, AItem.Index];
      if p.Linked.Count > 0 then
        Recheck(n);
    end;
  finally
    ResList.PictureList.UnlockList;
  end;
end;

procedure TfGrid.vGridFocusedItemChanged(Sender: TcxCustomGridTableView;
  APrevFocusedItem, AFocusedItem: TcxCustomGridTableItem);
begin
  Sender.OptionsData.Editing := ResList.PicsFinished and
    (AFocusedItem <> FProgressColumn);

end;

end.
