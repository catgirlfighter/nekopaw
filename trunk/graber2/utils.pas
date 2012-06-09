unit utils;

interface

uses
  SysUtils, Classes, cxGridCustomTableView, cxGraphics, cxEdit, Windows,
  cxDataUtils, cxGridCommon, cxGridTableView, cxEditRepositoryItems,
  cxExtEditRepositoryItems, cxVGrid, GraberU, common, Math;

type
  Tdm = class(TDataModule)
    EditRepository: TcxEditRepository;
    erLabel: TcxEditRepositoryLabel;
    erButton: TcxEditRepositoryButtonItem;
    erAuthButton: TcxEditRepositoryButtonItem;
    erCheckBox: TcxEditRepositoryCheckBoxItem;
    erSpinEdit: TcxEditRepositorySpinItem;
    erCombo: TcxEditRepositoryComboBoxItem;
    erReadOnlyText: TcxEditRepositoryTextItem;
    erPassword: TcxEditRepositoryTextItem;
  private
    { Private declarations }
  public
    function CreateCategory(vg: TcxVerticalGrid; AName, ACaption: String;
      Collapsed: boolean = false): TcxCategoryRow;
    function CreateField(vg: TcxVerticalGrid; AName,ACaption,ComboItems: string;
  FieldType: TFieldType; Category: TcxCategoryRow; DefaultValue: Variant): TcxEditorRow;
    { Public declarations }
  end;

var
  dm: Tdm;

function GetBestFitWidth(a: TcxCustomGridTableItem; FirstRec: integer): Integer;
procedure BestFitWidths(a: TcxGridTableView; FirstRec: integer = 0);

implementation

{$R *.dfm}
type
  TcxCustomGridTableItemAccess = class(TcxCustomGridTableItem);
  TcxCustomGridTablePainterAccess = class(TcxCustomGridTablePainter);

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

function GetBestFitWidth(a: TcxCustomGridTableItem; FirstRec: integer): Integer;
var
  ACanvas: TcxCanvas;
  AIsCalcByValue: Boolean;
  AEditSizeProperties: TcxEditSizeProperties;
  AParams: TcxViewParams;
  AEditViewData: TcxCustomEditViewData;
  I, AWidth: Integer;
  ARecord: TcxCustomGridRecord;
  AValue: Variant;
  AEditMinContentSize: TSize;

  function GetFirstRecordIndex: Integer;
  begin
    Result := a.GridView.OptionsBehavior.BestFitMaxRecordCount;
    if Result <> 0 then
    begin
      Result := TcxCustomGridTableItemAccess(a).Controller.TopRecordIndex;
      if Result < 0 then Result := 0;
    end;
  end;

  function GetLastRecordIndex: Integer;
  begin
    Result := a.GridView.OptionsBehavior.BestFitMaxRecordCount;
    if Result = 0 then
      Result := TcxCustomGridTableItemAccess(a).ViewData.RecordCount
    else
    begin
      Result := GetFirstRecordIndex + Result;
      if Result > TcxCustomGridTableItemAccess(a).ViewData.RecordCount then
        Result := TcxCustomGridTableItemAccess(a).ViewData.RecordCount;
    end;
    Dec(Result);
  end;

begin
  Result := 0;
  ACanvas := TcxCustomGridTablePainterAccess(a.GridView.Painter).Canvas;
  AIsCalcByValue := a.GetProperties.GetEditValueSource(False) = evsValue;
  with AEditSizeProperties do
  begin
    MaxLineCount := 0;
    Width := -1;
  end;
  AEditViewData := TcxCustomGridTableItemAccess(a).CreateEditViewData(a.GetProperties);
  try
    for I := Max(GetFirstRecordIndex,FirstRec) to GetLastRecordIndex do
    begin
      ARecord := TcxCustomGridTableItemAccess(a).ViewData.Records[I];
      if ARecord.HasCells then
      begin
        a.Styles.GetContentParams(ARecord, AParams);
        TcxCustomGridTableItemAccess(a).InitStyle(AEditViewData.Style, AParams, True);
        if AIsCalcByValue then
          AValue := ARecord.Values[a.Index]
        else
          AValue := ARecord.DisplayTexts[a.Index];
        AWidth := AEditViewData.GetEditContentSize(ACanvas, AValue, AEditSizeProperties).cx;
        if AWidth > Result then Result := AWidth;
      end;
    end;

    a.Styles.GetContentParams(nil, AParams);
    TcxCustomGridTableItemAccess(a).InitStyle(AEditViewData.Style, AParams, True);
    AWidth := AEditViewData.GetEditConstantPartSize(ACanvas, AEditSizeProperties,
      AEditMinContentSize).cx;
    if Result < AEditMinContentSize.cx then
      Result := AEditMinContentSize.cx;
    Inc(Result, AWidth);
  finally
    TcxCustomGridTableItemAccess(a).DestroyEditViewData(AEditViewData);
  end;
  if Result <> 0 then
    Inc(Result, 2 * cxGridEditOffset);
end;

procedure BestFitWidths(a: TcxGridTableView; FirstRec: integer = 0);
var
  i: integer;
  n: integer;
begin


  for i := FirstRec to a.ColumnCount -1 do
  begin
    if FirstRec <> 0 then
      n := a.Columns[i].Width
    else
      n := 0;

    a.Columns[i].Width := Max(n,GetBestFitWidth(a.Columns[i],FirstRec));
  end;
end;

function Tdm.CreateCategory(vg: TcxVerticalGrid; AName, ACaption: String;
      Collapsed: boolean = false): TcxCategoryRow;
begin
  Result := vg.Add(TcxCategoryRow) as TcxCategoryRow;
  if Collapsed then
    Result.Collapse(false);
  Result.Name := AName;
  Result.Properties.Caption := ACaption;
end;

function Tdm.CreateField(vg: TcxVerticalGrid; AName,ACaption,ComboItems: string;
  FieldType: TFieldType; Category: TcxCategoryRow; DefaultValue: Variant): TcxEditorRow;
begin
  Result := vg.AddChild(Category, TcxEditorRow) as TcxEditorRow;
  Result.Name := AName;
  Result.Properties.Caption := ACaption;
  case FieldType of
    ftString:
      ;
    ftPassword:
      Result.Properties.RepositoryItem := erPassword;
    ftReadOnly:
      Result.Properties.RepositoryItem := erReadOnlyText;
    ftNumber:
      Result.Properties.RepositoryItem := erSpinEdit;
    ftCombo:
      begin
        erCombo.Properties.Items.Clear;
        StringToList(comboitems, erCombo.Properties.Items);
        Result.Properties.RepositoryItem := erCombo;
      end;
    ftCheck:
      Result.Properties.RepositoryItem := erCheckBox;
  end;
  Result.Properties.Value := DefaultValue;
end;

end.
