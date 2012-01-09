unit GridFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData,
  DBClient, cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, graberU;

type
  TfGrid = class(TFrame)
    vGrid: TcxGridDBTableView;
    GridLevel1: TcxGridLevel;
    Grid: TcxGrid;
    cds: TClientDataSet;
    GridLevel2: TcxGridLevel;
    vChilds: TcxGridDBTableView;
    cdsresname: TStringField;
  private
    { Private declarations }
  public
    ResList: TResourceList;
    procedure Reset;
    procedure CreateList;
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TfGrid.CreateList;
begin
  Grid.BeginUpdate;
  vGrid.ClearItems;
  vChilds.ClearItems;
  cds.DisableControls;
  if not cds.Active then
  begin
    cds.CreateDataSet;
    cds.Open;
  end;
  cds.EmptyDataSet;
  cds.FieldDefs.Clear;
  if Assigned(ResList) then
    ResList.Free;
  ResList := TResourceList.Create;
  cds.EnableConstraints;
  Grid.EndUpdate;
end;

procedure TfGrid.Reset;
begin

end;

end.
