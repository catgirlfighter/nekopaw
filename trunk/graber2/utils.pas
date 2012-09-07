unit utils;

interface

uses
  {std}
  SysUtils, Classes, Math, Variants, Dialogs, Windows, ShellAPI,
  {devex}
  cxGridCustomTableView, cxGraphics, cxEdit,
  cxDataUtils, cxGridCommon, cxGridTableView, cxEditRepositoryItems,
  cxExtEditRepositoryItems, cxVGrid,
  cxButtonEdit, cxDropDownEdit, cxMRUEdit, cxmycombobox,
  {graber}
  GraberU, common, OpBase, ImgList, Controls;

type
  Tdm = class(TDataModule)
    EditRepository: TcxEditRepository;
    erLabel: TcxEditRepositoryLabel;
    erButton: TcxEditRepositoryButtonItem;
    erAuthButton: TcxEditRepositoryButtonItem;
    erCheckBox: TcxEditRepositoryCheckBoxItem;
    erSpinEdit: TcxEditRepositorySpinItem;
    erCombo: TcxEditRepositoryComboBoxItem;
    erPassword: TcxEditRepositoryTextItem;
    erFloatEdit: TcxEditRepositoryCurrencyItem;
    erRDFloatEdit: TcxEditRepositoryCurrencyItem;
    erRDTextEdit: TcxEditRepositoryTextItem;
    erRDPassword: TcxEditRepositoryTextItem;
    erRDCheckBox: TcxEditRepositoryCheckBoxItem;
    erPathBrowse: TcxEditRepositoryButtonItem;
    erURLText: TcxEditRepositoryButtonItem;
    il: TcxImageList;
    erPathText: TcxEditRepositoryMRUItem;
    procedure erPathBrowsePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure erURLTextPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditRepositoryMRUItem1PropertiesButtonClick(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
  private
    ertagedit: TcxMyEditRepositoryComboBoxItem;
    { Private declarations }
  protected
    procedure OnGetTagItems(Sender: TObject; SearchWord: string;
      Items: TStrings);
  public
    function CreateCategory(vg: TcxVerticalGrid; AName, ACaption: String;
      Collapsed: boolean = false): TcxCategoryRow;
    function CreateField(vg: TcxVerticalGrid; AName,ACaption,ComboItems: string;
      FieldType: TFieldType; Category: TcxCategoryRow; DefaultValue: Variant;
      ReadOnly: Boolean = false): TcxEditorRow;
    { Public declarations }
  end;

var
  dm: Tdm;

function GetBestFitWidth(a: TcxCustomGridTableItem; FirstRec: integer): Integer;
procedure BestFitWidths(a: TcxGridTableView; FirstRec: integer = 0);

implementation

uses PathEditorForm, LangString;

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
    tmp := TrimEx(CopyTo(s,',',['""'],[],true),[' ','"']);
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

procedure tdm.OnGetTagItems(Sender: TObject; SearchWord: string; Items: TStrings);
begin
  Items.Text := tagdump.ContinueSearch(SearchWord);
end;

function Tdm.CreateField(vg: TcxVerticalGrid; AName,ACaption,ComboItems: string;
  FieldType: TFieldType; Category: TcxCategoryRow; DefaultValue: Variant;
  ReadOnly: boolean = false): TcxEditorRow;
var
  cb: TcxEditRepositoryComboBoxItem;
begin
  Result := vg.AddChild(Category, TcxEditorRow) as TcxEditorRow;
  Result.Name := AName;
  Result.Properties.Caption := ACaption;
  if FieldType <> ftIndexCombo then
    Result.Properties.Value := DefaultValue;
  //else
  //  Result.Properties.ItemIndex := DefaultValue;
  case FieldType of
    ftString:
      if ReadOnly then
        if pos('://',DefaultValue) > 0 then
          Result.Properties.RepositoryItem := erURLText
        else
          Result.Properties.RepositoryItem := erRDTextEdit;
    ftPassword:
      if  ReadOnly then
        Result.Properties.RepositoryItem := erRDPassword
      else
        Result.Properties.RepositoryItem := erPassword;
{    ftReadOnly:
      Result.Properties.RepositoryItem := erReadOnlyText;    }
    ftNumber:
      if ReadOnly then
        Result.Properties.RepositoryItem := erRDTextEdit
      else
        Result.Properties.RepositoryItem := erSpinEdit;
    ftFloatNumber:
      if ReadOnly then
        Result.Properties.RepositoryItem := erRDFloatEdit
      else
        Result.Properties.RepositoryItem := erFloatEdit;
    ftCombo,ftIndexCombo:
      begin
        //erCombo.Properties.Items.Clear;
        cb := TcxEditRepositoryComboBoxItem.Create(result);
        cb.Properties.DropDownListStyle := lsFixedList;
        //cb.Assign(erCombo);
        StringToList(comboitems, cb.Properties.Items);
        Result.Properties.RepositoryItem := cb;
        if FieldType = ftIndexCombo then
          Result.Properties.Value := cb.Properties.Items[DefaultValue];
      end;
    ftCheck:
    begin
      if ReadOnly then
        Result.Properties.RepositoryItem := erRDCheckBox
      else
        Result.Properties.RepositoryItem := erCheckBox;
      Result.Properties.Value := VarAsType(Result.Properties.Value,varBoolean);
    end;
    ftPathText:
    begin
      if ReadOnly then
        Result.Properties.RepositoryItem := erPathBrowse
      else
        Result.Properties.RepositoryItem := erPathText;
    end;
    ftTagText:
      Result.Properties.RepositoryItem := ertagedit;
  end;
end;

procedure Tdm.DataModuleCreate(Sender: TObject);
begin
  erPathText.Properties.Items.Text := LoadPathList;
  erPathText.Properties.IncrementalSearch := false;
  ertagedit := TcxMyEditRepositoryComboBoxItem.Create(erpathtext.Owner);
  ertagedit.Properties.WordMode := true;
  ertagedit.Properties.Spacer := ' ';
  ertagedit.Properties.OnBeforeGetItems := OnGetTagItems;
  ertagedit.Properties.IncrementalSearch := false;
  //erPathText.Properties.LookupItems.Text := '';
end;

procedure Tdm.EditRepositoryMRUItem1PropertiesButtonClick(Sender: TObject);
var
  fields: tstringlist;
  items: tstrings;
  n: integer;
  s: string;
begin
//  Pos
//  SameText
  fields := tstringlist.Create;
  try
    FullResList.GetAllPictureFields(fields,true);
    s := (Sender as tcxMRUEdit).Text;
    (Sender as tcxMRUEdit).Text :=
      ExecutePathEditor((Sender as tcxMRUEdit).Text,(Sender as tcxMRUEdit).Properties.Items,nil,fields);
    (Sender as tcxMRUEdit).PostEditValue;

    if s <> (Sender as tcxMRUEdit).Text then
    begin
      items := (Sender as tcxMRUEdit).Properties.Items;
      n := IndexOfStr(items,(Sender as tcxMRUEdit).Text);
      if n <> -1 then
        items.Move(n,0)
      else
      begin
        if items.Count > 4 then
          items.Delete(5);
        items.Insert(0,(Sender as tcxMRUEdit).Text);
      end;
      SavePathList(items);
    end;

  finally
    fields.Free;
  end;
end;

procedure Tdm.erPathBrowsePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var
  s: string;
  begin
  case AButtonIndex of
    1:
    begin
      s := (Sender as tcxbuttonedit).Text;
      if FileExists(s) then
        ShellExecute(0, nil, PCHAR(s){'EXPLORER'}, nil{PCHAR('/select, "' + s + '"')},
        nil, SW_SHOWNORMAL)
      else
        MessageDlg(format(lang('_NO_FILE_'),[s]), mtInformation, [mbOk], 0);
    end;
    0:
    begin
        s := (Sender as tcxbuttonedit).Text;
        if fileexists(s) then
          ShellExecute(0, nil, 'EXPLORER',PChar('/select, "' + s + '"'),
          nil, SW_SHOWNORMAL)
        else
          if ShellExecute(0, nil, PChar(ExtractFilePath(s)),
          nil, nil, SW_SHOWNORMAL) < 33 then
            if ShellExecute(0, nil,
            PChar(ExtractFilePath(ExtractFileDir(s))), nil, nil,
            SW_SHOWNORMAL) < 33 then
              MessageDlg(format(lang('_NO_DIRECTORY_'),[s]), mtInformation, [mbOk], 0);
    end;
  end;
end;

procedure Tdm.erURLTextPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  ShellExecute(0,nil,
    PCHAR((Sender as tcxbuttonedit).Text),
    nil,nil,SW_SHOWNORMAL);
end;

end.
