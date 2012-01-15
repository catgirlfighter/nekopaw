unit GridFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData,
  DBClient, cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, graberU, dxmdaset,
  cxEditRepositoryItems, common, ComCtrls, cxContainer, cxLabel, dxSkinsCore,
  dxSkinBlack, dxSkinBlue, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom,
  dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinPumpkin, dxSkinSeven,
  dxSkinSharp, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008,
  dxSkinsDefaultPainters, dxSkinValentine, dxSkinXmas2008Blue,
  dxSkinscxPCPainter, dxStatusBar;

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
  private
    FList: TList;
    FFieldList: TStringList;
    FStartSender: TObject;
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
    { Public declarations }
  end;

  TcxGridSiteAccess = class(TcxGridSite);

implementation

uses LangString;

{$R *.dfm}

function TfGrid.AddField(s: string;chu: string = ''): TcxGridDBColumn;
var
  f: TStringField;

begin
  f := TStringField.Create(md);
  f.FieldName := chu + s;
  f.DisplayLabel := s;
  f.Size := 128;
  f.FieldKind := fkData;
  f.DataSet := md;
  result := vGrid.CreateColumn;
  result.DataBinding.FieldName := f.FieldName;
  result.RepositoryItem := iTextEdit;
  //result.DataBinding.ValueType := 'String';
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
  if not Assigned(FList) then
    FList := TList.Create
  else
    FList.Clear;
  if not Assigned(FFieldList) then
    FFieldList := TStringList.Create;
  if not Assigned(ResList) then
  begin
    ResList := TResourceList.Create;
    ResList.OnAddPicture := OnPicAdd;
    ResList.OnStartJob := OnStartJob;
    ResList.OnEndJob := OnEndJob;
    ResList.OnBeginPicList := OnBeginPicList;
    ResList.OnEndPicList := OnEndPicList;
  end else
    ResList.Clear;
end;

procedure TfGrid.OnBeginPicList(Sender: TObject);
begin
//  vGrid.BeginUpdate;
//  md.DisableControls;
  FStartSender := Sender;
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
  n,t: integer;
begin
  if FStartSender <> Sender then
    Exit;

  vGrid.BeginUpdate;
  n := vgrid.DataController.FocusedRowIndex;
  //if vgrid.
  t := vgrid.Controller.TopRecordIndex;
  if n < 0 then
    n := 0;
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
      end;
      md.Post;
    except
      md.Cancel;
    end;
  end;
  FList.Clear;
  md.EnableControls;
//  if vgrid.DataController.RecordCount > 0 then
  vGrid.EndUpdate;
  if vgrid.DataController.RecordCount > 0 then
  begin
    vgrid.DataController.FocusedRowIndex := n;
    vGrid.Controller.TopRecordIndex := t;
  end;
  sBar.Panels[1].Text := 'Count = ' + IntToStr(vGrid.DataController.RecordCount);
end;

procedure TfGrid.OnPicAdd(APicture: TTPicture);
{var
  i: integer;
begin
  vGrid.BeginUpdate;
  md.Insert;
  try
    for i := 0 to APicture.Meta.Count-1 do
    begin
        md.FieldValues['.'+APicture.Meta.Items[i].Name] := APicture.Meta.Items[i].Value;
    end;
    md.Post;
  except
    md.Cancel;
  end;
  vGrid.EndUpdate;  }
begin
  FList.Add(APicture);
end;

procedure TfGrid.OnStartJob(Sender: TObject);
begin
  PostMessage(Application.MainForm.Handle,CM_STARTJOB,Integer(Self.Parent),0);
    sBar.Panels[0].Text := 'ON AIR';
end;

procedure TfGrid.Relise;
begin
  ResList.Free;
  FList.Free;
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
  c.SortOrder := soAscending;
  c.Width := 20;
//  c.Options.HorzSizing := false;
  c := AddField('resname');
  c.DataBinding.Field.DisplayLabel := _RESNAME_;
  c.GroupBy(0);
  for i := 0 to FFieldList.Count -1 do
    FFieldList.Objects[i] := AddField(FFieldList[i],'.');
  //l.Free;

  md.Open;
  md.EnableControls;
  Grid.EndUpdate;
end;

end.
