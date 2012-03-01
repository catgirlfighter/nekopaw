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
  cxDataUtils{, dxSkinsCore, dxSkinsDefaultPainters, dxSkinscxPCPainter,
  dxSkinsdxStatusBarPainter, dxSkinsdxBarPainter};

type

  TfGrid = class(TFrame)
    GridLevel1: TcxGridLevel;
    Grid: TcxGrid;
    GridLevel2: TcxGridLevel;
    vChilds: TcxGridDBTableView;
    cxEditRepository1: TcxEditRepository;
    iTextEdit: TcxEditRepositoryTextItem;
    md: TdxMemData;
    vGrid: TcxGridDBTableView;
    ds: TDataSource;
    sBar: TdxStatusBar;
    BarManager: TdxBarManager;
    BarControl: TdxBarDockControl;
    TableActions: TdxBar;
    bbColumns: TdxBarButton;
    GridPopup: TcxGridPopupMenu;
    bbFilter: TdxBarButton;
    dxBarButton1: TdxBarButton;
    iPicChecker: TcxEditRepositoryCheckBoxItem;
    iCheckBox: TcxEditRepositoryCheckBoxItem;
    iPBar: TcxEditRepositoryProgressBar;
    bbDoubles: TdxBarButton;
    vGrid1: TcxGridTableView;
    procedure bbColumnsClick(Sender: TObject);
    procedure bbFilterClick(Sender: TObject);
    procedure vGridFocusedRecordChanged(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    procedure dsDataChange(Sender: TObject; Field: TField);
    procedure bbDoublesClick(Sender: TObject);
  private
    //FList: TList;
    FFieldList: TStringList;
    FPicChanged: TPictureNotifyEvent;
    FCheckColumn: tcxGridDBColumn;
    FIdColumn: tcxGridDBColumn;
    FLabelColumn: tcxGridDBColumn;
    FProgressColumn: tcxGridDBColumn;
    FSizeColumn: tcxGridDBColumn;
    FPosColumn: tcxGridDBColumn;
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
    function AddField(s: string;chu: string = ''; base: boolean = false): TcxGridDBColumn;
    procedure OnBeginPicList(Sender: TObject);
    procedure OnEndPicList(Sender: TObject);
    procedure Relise;
    procedure SetLang;
    procedure OnListPicChanged(Pic: TTPicture; Changes: TPicChanges);
    procedure SetColWidths;
    procedure updatefocusedrecord;
    property OnPicChanged: TPictureNotifyEvent read FPicChanged write FPicChanged;
    { Public declarations }
  end;

  TcxGridSiteAccess = class(TcxGridSite);
  TcxGridPopupMenuAccess = class(TcxGridPopupMenu);
implementation

uses LangString, utils;

{$R *.dfm}

function TfGrid.AddField(s: string;chu: string = ''; base: boolean = false): TcxGridDBColumn;
var
  f: TField;
  n: string;

begin
  n := GetNextS(s,':');

  if s <> '' then
    case s[1] of
      'i','p' : f := TIntegerField.Create(md);
      'd' : f := TDateTimeField.Create(md);
      'b' : f := TBooleanField.Create(md);
    else
    begin
      f := TStringField.Create(md);
      f.Size := 256;
    end end
  else
  begin
    f := TStringField.Create(md);
    f.Size := 256;
  end;
  //f := TStringField.Create(md);
  f.FieldName := chu + n;
  f.DisplayLabel := n;

  f.FieldKind := fkData;
  f.DataSet := md;
  result := vGrid.CreateColumn;
  result.DataBinding.FieldName := f.FieldName;
  if f is TBooleanField then
    if base then
      result.RepositoryItem := iPicChecker
    else
      result.RepositoryItem := iCheckBox
  else if s = 'p' then
    result.RepositoryItem := iPBar
  else
    result.RepositoryItem := iTextEdit;
  //result.DataBinding.ValueType := 'String';
end;

procedure TfGrid.bbColumnsClick(Sender: TObject);
begin
  TcxGridPopupMenuAccess(GridPopup).GridOperationHelper.DoShowColumnCustomizing(True);
end;

procedure TfGrid.bbDoublesClick(Sender: TObject);
begin
  vGrid.BeginUpdate;
  md.DisableControls;
  ResList.UncheckDoubles;
  md.EnableControls;
  vGrid.EndUpdate;
end;

procedure TfGrid.bbFilterClick(Sender: TObject);
begin
  if bbFilter.Down then
    vGrid.FilterBox.Visible := fvAlways
  else
    vGrid.FilterBox.Visible := fvNonEmpty;
end;

procedure TfGrid.CreateList;
begin
{  Grid.LookAndFeel.SkinName := '';
  Grid.LookAndFeel.Kind := lfFlat;
  Grid.LookAndFeel.NativeStyle := true;
  with TcxGridSiteAccess(Grid.ActiveView.Site) do
  begin
    VScrollBar.LookAndFeel.MasterLookAndFeel := nil;
    HScrollBar.LookAndFeel.MasterLookAndFeel := nil;
  end;
  if not Assigned(FList) then
    FList := TList.Create
  else
    FList.Clear;}
  if not Assigned(FFieldList) then
    FFieldList := TStringList.Create;
  if not Assigned(ResList) then
  begin
    ResList := TResourceList.Create;
    ResList.PictureList.OnPicChanged := OnListPicChanged;
    //ResList.OnAddPicture := OnPicAdd;
    ResList.OnJobChanged := OnStartJob;
    //ResList.OnEndJob := OnEndJob;
    //ResList.OnBeginPicList := OnBeginPicList;
    ResList.PictureList.OnEndAddList := OnEndPicList;
    FPicChanged := nil;
  end else
    ResList.Clear;
end;

procedure TfGrid.dsDataChange(Sender: TObject; Field: TField);
var
  p: TTPicture;
begin

  if Assigned(Field) and (Field.FieldName = 'checked') then
  begin
    p := Pointer(Integer(md.FieldByName('id').Value));
    p.Checked := Field.Value;
  end;
end;

procedure TfGrid.OnBeginPicList(Sender: TObject);
begin

end;

procedure TfGrid.OnEndPicList(Sender: TObject);
var
  i,j: integer;
  APicture: TTPicture;
  //r,c: integer;
  t: integer;
  n: variant;
  FList: TPictureLinkList;
begin
{  if FStartSender <> Sender then
    Exit;   }
  FList := Sender as TPictureLinkList;

  vGrid.BeginUpdate;
  //if vgrid.
  n := md.CurRec;
  //vgrid.Controller.FocusedRow.Selected := false;
{  if n <> -1 then
    n := vgrid.ViewData.Records[n].Values[0];   }
  t := vgrid.Controller.FocusedRecordIndex - vgrid.Controller.TopRecordIndex;
//  b := vgrid.Controller.
  md.DisableControls;
  //r := vGrid.DataController.RecordCount;
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
          {c := FFieldList.IndexOf(APicture.Meta.Items[i].Name);
          c := (FFieldList.Objects[c] as TcxGridColumn).Index;
          vGrid.DataController.Values[r,c] := APicture.Meta.Items[i].Value;   }
          //vGrid.
          md.FieldValues['.' + APicture.Meta.Items[i].Name] := APicture.Meta.Items[i].Value;
{          md.FieldValues['fname'] := APicture.PicName;
          md.FieldValues['fext'] := APicture.Ext; }
      end;
      md.Post;
      APicture.Orig.BookMark := md.RecNo;
    except
      md.Cancel;
    end;
  end;
  //FList.Clear;
  //md.CurRec := n;
  md.EnableControls;
//  if vgrid.DataController.RecordCount > 0 then
  //vgrid.DataController.Groups.FullCollapse;
  if n > -1 then
    BestFitWidths(vGrid);
  vGrid.EndUpdate;

  if n < 0 then
  begin
    BestFitWidths(vGrid);
    n := 0;
  end;

    vgrid.DataController.FocusedRecordIndex := n;
    vgrid.Controller.TopRecordIndex := vgrid.Controller.FocusedRecordIndex - t;

  //BestFitWidths(vChilds);
  //md.CurRec := n;
  {    if n <> -1 then
    begin
      vgrid.DataController.FocusedRecordIndex := n;
      vGrid.Controller.FocusedRecord.Selected := true;
    end;    }
  //vgrid.DataController.FocusedRecordIndex := n;

  sBar.Panels[1].Text := _COUNT_ + ' ' + IntToStr(vGrid.DataController.RecordCount);
end;

procedure TfGrid.OnPicAdd(APicture: TTPicture);
begin
  //FList.Add(APicture);
end;

procedure TfGrid.OnListPicChanged(Pic: TTPicture; Changes: TPicChanges);
var
  n: integer;

begin
  //(pcProgress,pcSize,pcLabel,pcDeleted,pcChecked)
  //md.CurRec := md. ( 'id',Integer(Pic),[]);
  //md.CurRec := md.GetRecNoByFieldValue(Integer(Pic),'id');



{  if pcDelete in Changes then
  begin
    md.Delete;
    Exit;
  end;   }

{  n := vGrid.DataController.FindRecordIndexByText(0,FIdColumn.Index,
        IntToStr(Integer(pic)),false,false,true); }
  if Pic.BookMark = 0 then
    Exit;

  vGrid.BeginUpdate;

  n := md.RecNo;

  md.RecNo := Pic.BookMark;

  md.Edit;

  //md.GetCurrentRecord;
  try
    if pcSize in Changes then
      if Pic.Size = 0 then
        md.FieldValues['size'] := null
      else
        md.FieldValues['size'] := GetBTString(Pic.Size);

    if pcProgress in Changes then
    begin
      if Pic.Pos = 0 then
        md.FieldValues['pos'] := null
      else
        md.FieldValues['pos'] := GetBTString(Pic.Pos);
      if Pic.Size = 0 then
        md.FieldValues['progress'] := 100
      else
        md.FieldValues['progress'] := Pic.Pos/Pic.Size * 100;
    end;

{    if pcLabel in Changes then
      md.FieldValues['label'] := Pic.DisplayLabel;    }

    if pcChecked in Changes then
      md.FieldValues['checked'] := Pic.Checked;

{    if md.State in [dsEdit] then
      md.Post;    }

    //VGrid.ViewData.se

    //vGrid.DataController.PostEditingData;
    md.Post;

    md.RecNo := n;

    vGrid.EndUpdate;

    Pic.Changes := [];

  finally
//    md.Post;
  end;
end;

procedure TfGrid.OnStartJob(Sender: TObject; Action: integer);
begin
  PostMessage(Application.MainForm.Handle,CM_STARTJOB,Integer(Self.Parent),0);
  case Action of
    JOB_LIST:
      sBar.Panels[0].Text := _ON_AIR_;
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
      sBar.Panels[0].Text := _ON_AIR_;
    end;
    JOB_STOPLIST:
      if ResList.PicsFinished then
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
  ResList.Free;
  //FList.Free;
  FFieldList.Free;
  vGrid.BeginUpdate;
  vGrid.DataController.RecordCount := 0;
  vGrid.ClearItems;
  vGrid.EndUpdate;
  //vGrid.Free;
end;

procedure TfGrid.Reset;
var
  i: integer;
  c: tcxGridDBColumn;
begin
  Grid.BeginUpdate;
  vGrid.ClearItems;
  vChilds.ClearItems;
  md.DisableControls;
  md.Close;
  FFieldList := ResList.FullPicFieldList;
  //FFieldList.Insert(0,'resname');
  //c := vGrid.CreateColumn;
  //c.Visible := false;

  FCHeckColumn := AddField('checked:b','',true);
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

  c := AddField('parent:i');
  c.Visible := false;
  c.VisibleForCustomization := false;
{  c.SortOrder := soAscending;
  c.Width := 20;    }

   vgrid.DataController.KeyFieldNames := 'RecId';

  c := vGrid.CreateColumn;
  c.DataBinding.FieldName := 'RecId';
  c.DataBinding.Field.DisplayLabel := _RESID_;

  c := AddField('resname');
  c.DataBinding.Field.DisplayLabel := _RESNAME_;
  c.GroupBy(0);

  FLabelColumn := AddField('label');
  FLabelColumn.DataBinding.Field.DisplayLabel := _PICTURELABEL_;

{  c := AddField('fname'); c.Visible := false;
  c.DataBinding.Field.DisplayLabel := _FILENAME_;

  c := AddField('fext'); c.Visible := false;
  c.DataBinding.Field.DisplayLabel := _EXTENSION_;   }
  //c := AddField('savename');

  for i := 0 to FFieldList.Count -1 do
  begin
    c := AddField(FFieldList[i],'.');
    c.Visible := false;
    FFieldList.Objects[i] := c;
  end;
  //l.Free;

  FPosColumn := AddField('pos');
  with FPosColumn.Options do
  begin
    HorzSizing := false;
    Filtering := false;
    Grouping := false;
    Moving := false;
    Sorting := false;
  end;
  //FPosColumn.Width := 20;
  //FPosColumn.MinWidth := 20;
  FPosColumn.Visible := false;
  FPosColumn.VisibleForCustomization := false;

  FSizeColumn := AddField('size');
  with FSizeColumn.Options do
  begin
    HorzSizing := false;
    Filtering := false;
    Grouping := false;
    Moving := false;
    Sorting := false;
  end;
  //FSizeColumn.Width := 20;
  //FSizeColumn.MinWidth := 20;
  FSizeColumn.Visible := false;
  FSizeColumn.VisibleForCustomization := false;

  FProgressColumn := AddField('progress:p');
  with FProgressColumn.Options do
  begin
    HorzSizing := false;
    Filtering := false;
    Grouping := false;
    Moving := false;
    Sorting := false;
  end;
  //FProgressColumn.Width := 20;
  //FPosColumn.MinWidth := 20;
  FProgressColumn.Visible := false;
  FProgressColumn.VisibleForCustomization := false;

  md.Open;
  md.EnableControls;
  Grid.EndUpdate;
end;

procedure TfGrid.SetColWidths;
begin
  FSizeColumn.Width := 60;
  FPosColumn.Width := 60;
  FProgressColumn.Width := 60;
end;

procedure TfGrid.SetLang;
begin
  bbColumns.Caption := _COLUMNS_;
  bbFilter.Caption := _FILTER_;
  bbDoubles.Caption := _DOUBLES_;
end;

procedure TfGrid.updatefocusedrecord;
var
  n: variant;

begin
  if Assigned(FPicChanged) then
  begin
    n := md.FieldValues['id'];
    if n <> null then
      FPicChanged(Self,TTPicture(Integer(n)));
  end;
end;

procedure TfGrid.vGridFocusedRecordChanged(Sender: TcxCustomGridTableView;
  APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
  ANewItemRecordFocusingChanged: Boolean);

begin
  updatefocusedrecord;
end;

end.
