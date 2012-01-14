unit GridFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData,
  DBClient, cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, graberU, dxmdaset,
  cxEditRepositoryItems;

type
  TfGrid = class(TFrame)
    vGrid: TcxGridDBTableView;
    GridLevel1: TcxGridLevel;
    Grid: TcxGrid;
    GridLevel2: TcxGridLevel;
    vChilds: TcxGridDBTableView;
    ds: TDataSource;
    md: TdxMemData;
    cxEditRepository1: TcxEditRepository;
    iTextEdit: TcxEditRepositoryTextItem;
  private
    FList: TList;
    { Private declarations }
  public
    ResList: TResourceList;
    procedure Reset;
    procedure CreateList;
    procedure OnPicAdd(APicture: TTPicture);
//    procedure CheckField(ch,s: string; value: variant);
    procedure OnStartJob(Sender: TObject);
    procedure OnEndJob(Sender: TObject);
    function AddField(ch,s: string): TcxGridDBColumn;
    procedure OnBeginPicList(Sender: TObject);
    procedure OnEndPicList(Sender: TObject);
    { Public declarations }
  end;

implementation

{$R *.dfm}

function TfGrid.AddField(ch,s: string): TcxGridDBColumn;
var
  f: TStringField;

begin
  f := TStringField.Create(md);
  f.FieldName := ch + s;
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
  if not Assigned(FList) then
    FList := TList.Create;
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
end;

procedure TfGrid.OnEndJob(Sender: TObject);
begin
  PostMessage(Application.MainForm.Handle,CM_ENDJOB,Integer(Self.Parent),0);
end;

procedure TfGrid.OnEndPicList(Sender: TObject);
var
  i,j: integer;
  APicture: TTPicture;
begin
  vGrid.BeginUpdate;
  md.DisableControls;
  for j := 0 to FList.Count -1 do
  begin
    APicture := FList[j];
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
  end;
  FList.Clear;
  md.EnableControls;
  vGrid.EndUpdate;
//  md.EnableControls;
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
end;

procedure TfGrid.Reset;
var
  l: TStringList;
  i: integer;
begin
  Grid.BeginUpdate;
  vGrid.ClearItems;
  vChilds.ClearItems;
  md.DisableControls;
  md.Close;
  AddField('','resname');
  l := ResList.FullPicFieldList;
  for i := 0 to l.Count -1 do
    AddField('.',l[i]);
  l.Free;

  md.Open;
  md.EnableControls;
  //cds.EnableConstraints;
  Grid.EndUpdate;
end;

end.
