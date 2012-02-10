unit GridFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData,
  DBClient, cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, graberU, dxmdaset,
  cxEditRepositoryItems, common, ComCtrls, cxContainer, cxLabel, dxStatusBar,
  dxBar, cxGridCustomPopupMenu, cxGridPopupMenu;

type
  TfGrid = class(TFrame)
    GridLevel1: TcxGridLevel;
    Grid: TcxGrid;
    GridLevel2: TcxGridLevel;
    vChilds: TcxGridDBTableView;
    cxEditRepository1: TcxEditRepository;
    iTextEdit: TcxEditRepositoryTextItem;
    vGrid1: TcxGridTableView;
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
    procedure bbColumnsClick(Sender: TObject);
    procedure bbFilterClick(Sender: TObject);
  private
    //FList: TList;
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
    procedure OnStartJob(Sender: TObject);
    procedure OnEndJob(Sender: TObject);
    function AddField(s: string;chu: string = ''): TcxGridDBColumn;
    procedure OnBeginPicList(Sender: TObject);
    procedure OnEndPicList(Sender: TObject);
    procedure Relise;
    procedure SetLang;
    { Public declarations }
  end;

  TcxGridSiteAccess = class(TcxGridSite);
  TcxGridPopupMenuAccess = class(TcxGridPopupMenu);
implementation

uses LangString;

{$R *.dfm}

function TfGrid.AddField(s: string;chu: string = ''): TcxGridDBColumn;
var
  f: TField;
  n: string;

begin
  n := GetNextS(s,':');

  if s <> '' then
    case s[1] of
      'i' : f := TIntegerField.Create(md);
      'd' : f := TDateTimeField.Create(md);
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
  result.RepositoryItem := iTextEdit;
  //result.DataBinding.ValueType := 'String';
end;

procedure TfGrid.bbColumnsClick(Sender: TObject);
begin
  TcxGridPopupMenuAccess(GridPopup).GridOperationHelper.DoShowColumnCustomizing(True);
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
  Grid.LookAndFeel.NativeStyle := true;    }
  with TcxGridSiteAccess(Grid.ActiveView.Site) do
  begin
    VScrollBar.LookAndFeel.MasterLookAndFeel := nil;
    HScrollBar.LookAndFeel.MasterLookAndFeel := nil;
  end;
{  if not Assigned(FList) then
    FList := TList.Create
  else
    FList.Clear;}
  if not Assigned(FFieldList) then
    FFieldList := TStringList.Create;
  if not Assigned(ResList) then
  begin
    ResList := TResourceList.Create;
    //ResList.OnAddPicture := OnPicAdd;
    ResList.OnStartJob := OnStartJob;
    ResList.OnEndJob := OnEndJob;
    //ResList.OnBeginPicList := OnBeginPicList;
    ResList.OnEndPicList := OnEndPicList;
  end else
    ResList.Clear;
end;

procedure TfGrid.OnBeginPicList(Sender: TObject);
begin
//  vGrid.BeginUpdate;
//  md.DisableControls;
  //FStartSender := Sender;
end;

procedure TfGrid.OnEndJob(Sender: TObject);
begin
  PostMessage(Application.MainForm.Handle,CM_ENDJOB,Integer(Self.Parent),0);
  sBar.Panels[0].Text := '';
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
  if n < 0 then
    n := 0;
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
      for i := 0 to APicture.Meta.Count-1 do
      begin
          {c := FFieldList.IndexOf(APicture.Meta.Items[i].Name);
          c := (FFieldList.Objects[c] as TcxGridColumn).Index;
          vGrid.DataController.Values[r,c] := APicture.Meta.Items[i].Value;   }
          //vGrid.
          md.FieldValues['.' + APicture.Meta.Items[i].Name] := APicture.Meta.Items[i].Value;
          md.FieldValues['resname'] := APicture.List.Resource.Name;
          md.FieldValues['label'] := APicture.DisplayLabel;
          md.FieldValues['id'] := Integer(APicture);
          md.FieldValues['parent'] := Integer(Apicture.Parent);
      end;
      md.Post;
    except
      md.Cancel;
    end;
  end;
  //FList.Clear;
  //md.CurRec := n;
  md.EnableControls;
//  if vgrid.DataController.RecordCount > 0 then
  //vgrid.DataController.Groups.FullCollapse;
  vGrid.EndUpdate;
  //md.CurRec := n;
  {    if n <> -1 then
    begin
      vgrid.DataController.FocusedRecordIndex := n;
      vGrid.Controller.FocusedRecord.Selected := true;
    end;    }
  //vgrid.DataController.FocusedRecordIndex := n;
  vgrid.DataController.FocusedRecordIndex := n;
  vgrid.Controller.TopRecordIndex := vgrid.Controller.FocusedRecordIndex - t;
  sBar.Panels[1].Text := _COUNT_ + ' ' + IntToStr(vGrid.DataController.RecordCount);
end;

procedure TfGrid.OnPicAdd(APicture: TTPicture);
begin
  //FList.Add(APicture);
end;

procedure TfGrid.OnStartJob(Sender: TObject);
begin
  PostMessage(Application.MainForm.Handle,CM_STARTJOB,Integer(Self.Parent),0);
    sBar.Panels[0].Text := _ON_AIR_;
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
  c := vGrid.CreateColumn;
  //c.Visible := false;
  c.DataBinding.FieldName := 'RecId';
  c.DataBinding.Field.DisplayLabel := _RESID_;

  vgrid.DataController.KeyFieldNames := 'RecId';

  c.SortOrder := soAscending;
  c.Width := 20;
//  c.Options.HorzSizing := false;
  c := AddField('resname');
  c.DataBinding.Field.DisplayLabel := _RESNAME_;
  c.GroupBy(0);

  c := AddField('label');
  c.DataBinding.Field.DisplayLabel := _PICTURELABEL_;

  c := AddField('id:i');
  c.Visible := false;
  c.VisibleForCustomization := false;

  c := AddField('parent:i');
  c.Visible := false;
  c.VisibleForCustomization := false;



  for i := 0 to FFieldList.Count -1 do
  begin
    c := AddField(FFieldList[i],'.');
    c.Visible := false;
    FFieldList.Objects[i] := c;
  end;
  //l.Free;

  md.Open;
  md.EnableControls;
  Grid.EndUpdate;
end;

procedure TfGrid.SetLang;
begin
  bbColumns.Caption := _COLUMNS_;
  bbFilter.Caption := _FILTER_;
end;

end.
