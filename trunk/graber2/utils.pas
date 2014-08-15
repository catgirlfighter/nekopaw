unit utils;

interface

uses
  {std}
  SysUtils, Classes, Math, Variants, Dialogs, Windows, ShellAPI,
  ImgList, Controls, Forms, Menus, UITypes,
  {devex}
  cxGridCustomTableView, cxGraphics, cxEdit,
  cxDataUtils, cxGridCommon, cxGridTableView, cxEditRepositoryItems,
  cxExtEditRepositoryItems, cxVGrid,
  cxButtonEdit, cxDropDownEdit, cxMRUEdit,
  {graber}
  cxmycombobox, cxmymultirow,  MyINIFile,
  GraberU, common, OpBase, dxBar, ActnList, MyHTTP, pac;

type
  TFavProc = procedure(Value: String);

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
    erCSVListEdit: TcxEditRepositoryButtonItem;
    procedure erPathBrowsePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure erURLTextPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditRepositoryMRUItem1PropertiesButtonClick(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure erCSVListEditPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure DataModuleDestroy(Sender: TObject);
    { Private declarations }
  private
    FCookie: TMyCookieList;
    fPACParser: tPACParser;
  protected
    procedure OnGetTagItems(Sender: TObject; SearchWord: string;
      Items: TStrings);
  public
    ertagedit: TcxMyEditRepositoryComboBoxItem;
    function CreateCategory(vg: TcxVerticalGrid; AName, ACaption: String;
      Collapsed: boolean = false): TcxCategoryRow;
    function CreateField(vg: TcxVerticalGrid;
      AName, ACaption, ComboItems: string; FieldType: TFieldType;
      Category: TcxCustomRow; DefaultValue: Variant; ReadOnly: boolean = false)
      : TcxCustomRow;
    procedure LoadFullResList(r: tResourceList; ini: tinifile = nil);
    property Cookie: TMyCookieList read FCookie;
    property PACParser: tPACParser read fPACParser;
    { Public declarations }
  end;

var
  dm: Tdm;

function GetBestFitWidth(a: TcxCustomGridTableItem; FirstRec: Integer): Integer;
procedure BestFitWidths(a: TcxGridTableView; FirstRec: Integer = 0);

implementation

uses PathEditorForm, LangString, MainForm, TextEditorForm;

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
    tmp := TrimEx(CopyTo(s, ',', ['""'], [], true), [' ', '"']);
    list.Add(tmp);
  end;
end;

function GetBestFitWidth(a: TcxCustomGridTableItem; FirstRec: Integer): Integer;
var
  ACanvas: TcxCanvas;
  AIsCalcByValue: boolean;
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
      if Result < 0 then
        Result := 0;
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
  AIsCalcByValue := a.GetProperties.GetEditValueSource(false) = evsValue;
  with AEditSizeProperties do
  begin
    MaxLineCount := 0;
    Width := -1;
  end;
  AEditViewData := TcxCustomGridTableItemAccess(a)
    .CreateEditViewData(a.GetProperties);
  try
    for I := Max(GetFirstRecordIndex, FirstRec) to GetLastRecordIndex do
    begin
      ARecord := TcxCustomGridTableItemAccess(a).ViewData.Records[I];
      if ARecord.HasCells then
      begin
        a.Styles.GetContentParams(ARecord, AParams);
        TcxCustomGridTableItemAccess(a).InitStyle(AEditViewData.Style,
          AParams, true);
        if AIsCalcByValue then
          AValue := ARecord.Values[a.Index]
        else
          AValue := ARecord.DisplayTexts[a.Index];
        AWidth := AEditViewData.GetEditContentSize(ACanvas, AValue,
          AEditSizeProperties).cx;
        if AWidth > Result then
          Result := AWidth;
      end;
    end;

    a.Styles.GetContentParams(nil, AParams);
    TcxCustomGridTableItemAccess(a).InitStyle(AEditViewData.Style,
      AParams, true);
    AWidth := AEditViewData.GetEditConstantPartSize(ACanvas,
      AEditSizeProperties, AEditMinContentSize).cx;
    if Result < AEditMinContentSize.cx then
      Result := AEditMinContentSize.cx;
    Inc(Result, AWidth);
  finally
    TcxCustomGridTableItemAccess(a).DestroyEditViewData(AEditViewData);
  end;
  if Result <> 0 then
    Inc(Result, 2 * cxGridEditOffset);
end;

procedure BestFitWidths(a: TcxGridTableView; FirstRec: Integer = 0);
var
  I: Integer;
  n: Integer;
begin
  if FirstRec < 0 then
    FirstRec := 0;
  for I := FirstRec to a.ColumnCount - 1 do
  begin
    if FirstRec <> 0 then
      n := a.Columns[I].Width
    else
      n := 0;

    a.Columns[I].Width := Max(n, GetBestFitWidth(a.Columns[I], FirstRec));
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

procedure Tdm.OnGetTagItems(Sender: TObject; SearchWord: string;
  Items: TStrings);
var
  fmt: TTagTemplate;
begin
  with (Sender as tcxmycombobox).Properties do
  begin
    fmt.Spacer := Spacer;
    fmt.Separator := Separator;
    fmt.Isolator := Isolator;
  end;
  Items.Text := tagdump.ContinueSearch(SearchWord, fmt);
  // ShowMessage(Sender.ClassName);
end;

function Tdm.CreateField(vg: TcxVerticalGrid;
  AName, ACaption, ComboItems: string; FieldType: TFieldType;
  Category: TcxCustomRow; DefaultValue: Variant; ReadOnly: boolean = false)
  : TcxCustomRow;
var
  cb: TcxEditRepositoryComboBoxItem;
  p: tcxCustomRowProperties;

  procedure sp(p: tcxCustomRowProperties; Value: Variant);
  begin
    if p is tcxEditorRowProperties then
      (p as tcxEditorRowProperties).Value := Value
    else if p is tcxEditorRowItemProperties then
      (p as tcxEditorRowItemProperties).Value := Value;
  end;

  function pv(p: tcxCustomRowProperties): Variant;
  begin
    if p is tcxEditorRowProperties then
      Result := (p as tcxEditorRowProperties).Value
    else if p is tcxEditorRowItemProperties then
      Result := (p as tcxEditorRowItemProperties).Value;
  end;

begin
  if not Assigned(Category) or (Category is TcxCategoryRow) then
  begin
    if FieldType = ftMultiEdit then
    begin
      Result := vg.AddChild(Category, tcxMyMultiEditorRow);
      (Result as tcxMyMultiEditorRow).FirstEditorHeader := true;
      Result.Name := AName;
      // p := (Result as tcxMyMultiEditorRow).Properties;
      // (p as tcxMultiEditorRowProperties).Caption := ACaption;
      Exit;
    end
    else
    begin
      Result := vg.AddChild(Category, TcxEditorRow);
      p := (Result as TcxEditorRow).Properties;
      (p as tcxEditorRowProperties).Caption := ACaption;
      Result.Name := AName;
    end
  end
  else if Category is tcxMyMultiEditorRow then
  begin
    Result := Category;
    p := (Category as tcxMyMultiEditorRow).Properties.Editors.Add;
    if (Category as tcxMultiEditorRow).Properties.Editors.Count = 1 then
      (p as tcxEditorRowItemProperties).Caption := ACaption;
  end
  else
  begin
    Result := nil;
    Exit;
  end;

  if FieldType <> ftIndexCombo then
    sp(p, DefaultValue);
  // else
  // Result.Properties.ItemIndex := DefaultValue;
  with p as tcxCustomEditorRowProperties do
    case FieldType of
      ftString:
        if ReadOnly then
          if pos('://', DefaultValue) > 0 then
            RepositoryItem := erURLText
          else
            RepositoryItem := erRDTextEdit;
      ftPassword:
        if ReadOnly then
          RepositoryItem := erRDPassword
        else
          RepositoryItem := erPassword;
      { ftReadOnly:
        Result.Properties.RepositoryItem := erReadOnlyText; }
      ftNumber:
        if ReadOnly then
          RepositoryItem := erRDTextEdit
        else
          RepositoryItem := erSpinEdit;
      ftFloatNumber:
        if ReadOnly then
          RepositoryItem := erRDFloatEdit
        else
          RepositoryItem := erFloatEdit;
      ftCombo, ftIndexCombo:
        begin
          // erCombo.Properties.Items.Clear;
          cb := TcxEditRepositoryComboBoxItem.Create(Result);
          cb.Properties.DropDownListStyle := lsFixedList;
          // cb.Assign(erCombo);
          StringToList(ComboItems, cb.Properties.Items);
          RepositoryItem := cb;
          if FieldType = ftIndexCombo then
            sp(p, cb.Properties.Items[DefaultValue]);
        end;
      ftCheck:
        begin
          if ReadOnly then
            RepositoryItem := erRDCheckBox
          else
            RepositoryItem := erCheckBox;
          sp(p, VarAsType(pv(p), varBoolean));
        end;
      ftPathText:
        begin
          if ReadOnly then
            RepositoryItem := erPathBrowse
          else
            RepositoryItem := erPathText;
        end;
      ftTagText:
        RepositoryItem := ertagedit;
      ftCSVList:
        RepositoryItem := erCSVListEdit;
    end;
end;

procedure Tdm.DataModuleCreate(Sender: TObject);
begin
  FCookie := TMyCookieList.Create;
  fPACParser := tPACParser.Create;
  erPathText.Properties.Items.Text := LoadPathList;
  erPathText.Properties.IncrementalSearch := false;

  ertagedit := TcxMyEditRepositoryComboBoxItem.Create(erPathText.Owner);
  ertagedit.Properties.WordMode := true;
  ertagedit.Properties.Spacer := ' ';
  ertagedit.Properties.OnBeforeGetItems := OnGetTagItems;

  with TcxCustomEditProperties(ertagedit.Properties).Buttons do
  begin
    with Add as tcxEditButton do
    begin
      Kind := bkEllipsis;
      // LoadFromRes(Glyph,'XFAVORITE');
    end;
    // with Add as tcxEditButton do
    // begin
    // Kind := bkGlyph;
    // LoadFromRes(Glyph,'XREMFAVORITE');
    // end;
    with Add as tcxEditButton do
    begin
      Kind := bktext;
      Caption := '?';
      Visible := false;
    end;
  end;

  // b := mf.dxFavPopup.ItemLinks.AddItem(tdxBarButton);
  // (b.Item as tdxBarCombo).ite;

  // ertagedit.Properties.IncrementalSearch := false;
  // erPathText.Properties.LookupItems.Text := '';
end;

procedure Tdm.DataModuleDestroy(Sender: TObject);
begin
  fPACParser.Free;
  FCookie.Free;
end;

procedure Tdm.EditRepositoryMRUItem1PropertiesButtonClick(Sender: TObject);
var
  fields: tstringlist;
  Items: TStrings;
  n: Integer;
  s: string;
  // r: TResource;
  // rl: tresourceslist;
  o: TObject;
begin
  // Pos
  // SameText
  // fields := tstringlist.Create;
  // try
  // ShowMessage((Sender as TcxMRUEdit).Parent.ClassName + ' ' + (Sender as TcxMRUEdit).Parent.Name);
  // (Sender as tcxMRUEdit).

  fields := tstringlist.Create;
  try
    o := Pointer(((Sender as TcxMRUEdit).Parent as TcxVerticalGrid).Tag);
    if o is tResourceList then
    begin
      (o as tResourceList).GetAllPictureFields(fields, true);
    end
    else if o is tresource then
      fields.Assign((o as tresource).PicFieldList)
    else
      Exit;

    // fields := r.PicFieldList; //try
    s := (Sender as TcxMRUEdit).Text;
    (Sender as TcxMRUEdit).Text :=
      ExecutePathEditor((Sender as TcxMRUEdit).Text, (Sender as TcxMRUEdit)
      .Properties.Items, nil, fields);
    (Sender as TcxMRUEdit).PostEditValue;

    if s <> (Sender as TcxMRUEdit).Text then
    begin
      Items := (Sender as TcxMRUEdit).Properties.Items;
      n := IndexOfStr(Items, (Sender as TcxMRUEdit).Text);
      if n <> -1 then
        Items.Move(n, 0)
      else
      begin
        if Items.Count > 4 then
          Items.Delete(5);
        Items.Insert(0, (Sender as TcxMRUEdit).Text);
      end;
      SavePathList(Items);
    end;

  finally
    fields.Free;
  end;
end;

procedure Tdm.erCSVListEditPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  fTextEdit.mText.Lines.BeginUpdate;
  try
    fTextEdit.mText.Text := strtostrlist((Sender as tcxbuttonedit).Text);
  finally
    fTextEdit.mText.Lines.EndUpdate;
  end;
  if fTextEdit.Execute then
  begin
    (Sender as tcxbuttonedit).EditValue := strlisttostr(fTextEdit.mText.Lines);
    (Sender as tcxbuttonedit).PostEditValue;
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
          ShellExecute(0, nil, PCHAR(s) { 'EXPLORER' } ,
            nil { PCHAR('/select, "' + s + '"') } , nil, SW_SHOWNORMAL)
        else if DirectoryExists(s) then
          ShellExecute(0, nil, PCHAR(s), nil, nil, SW_SHOWNORMAL)
        else
          MessageDlg(format(lang('_NO_FILE_'), [s]), mtInformation, [mbOk], 0);
      end;
    0:
      begin
        s := (Sender as tcxbuttonedit).Text;
        if FileExists(s) then
          ShellExecute(0, nil, 'EXPLORER', PCHAR('/select, "' + s + '"'), nil,
            SW_SHOWNORMAL)
        else if ShellExecute(0, nil, PCHAR(ExtractFilePath(s)), nil, nil,
          SW_SHOWNORMAL) < 33 then
          if ShellExecute(0, nil, PCHAR(ExtractFilePath(ExtractFileDir(s))),
            nil, nil, SW_SHOWNORMAL) < 33 then
            MessageDlg(format(lang('_NO_DIRECTORY_'), [ExtractFileDir(s)]),
              mtInformation, [mbOk], 0);
      end;
  end;
end;

procedure Tdm.erURLTextPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  ShellExecute(0, nil, PCHAR((Sender as tcxbuttonedit).Text), nil, nil,
    SW_SHOWNORMAL);
end;

procedure Tdm.LoadFullResList(r: tResourceList; ini: tinifile = nil);
begin
  r.LoadList(resources_dir);
  if assigned(ini) then
    LoadResourceSettings(r,ini)
  else
    LoadResourceSettings(r);
  r.ThreadHandler.Cookies := FCookie;
  //r.ThreadHandler.ThreadCount := GlobalSettings.Downl.ThreadCount;
  r.ThreadHandler.PACParser := PACParser;
  r.DWNLDHandler.Cookies := FCookie;
  //r.DWNLDHandler.ThreadCount := GlobalSettings.Downl.ThreadCount;
  r.DWNLDHandler.PACParser := PACParser;
end;

end.
