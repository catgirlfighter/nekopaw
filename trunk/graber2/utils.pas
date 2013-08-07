unit utils;

interface

uses
  {std}
  SysUtils, Classes, Math, Variants, Dialogs, Windows, ShellAPI,
  ImgList, Controls, Forms,  Menus,
  {devex}
  cxGridCustomTableView, cxGraphics, cxEdit,
  cxDataUtils, cxGridCommon, cxGridTableView, cxEditRepositoryItems,
  cxExtEditRepositoryItems, cxVGrid,
  cxButtonEdit, cxDropDownEdit, cxMRUEdit,
  {graber}
  cxmycombobox, cxmymultirow,
  GraberU, common, OpBase, dxBar, ActnList, IdBaseComponent, IdIntercept,
  IdInterceptThrottler, MyHTTP;

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
    IdInterceptThrottler1: TIdInterceptThrottler;
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
  protected
    procedure OnGetTagItems(Sender: TObject; SearchWord: string;
      Items: TStrings);
  public
    ertagedit: TcxMyEditRepositoryComboBoxItem;
    function CreateCategory(vg: TcxVerticalGrid; AName, ACaption: String;
      Collapsed: boolean = false): TcxCategoryRow;
    function CreateField(vg: TcxVerticalGrid; AName,ACaption,ComboItems: string;
      FieldType: TFieldType; Category: TcxCustomRow; DefaultValue: Variant;
      ReadOnly: Boolean = false): TcxCustomRow;
    procedure LoadFullResList(r: tResourceList);
    property Cookie: TMyCookieList read FCookie;
    { Public declarations }
  end;

var
  dm: Tdm;

function GetBestFitWidth(a: TcxCustomGridTableItem; FirstRec: integer): Integer;
procedure BestFitWidths(a: TcxGridTableView; FirstRec: integer = 0);

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
var
  fmt: TTagTemplate;
begin
  with (sender as tcxmycombobox).Properties do
  begin
    fmt.Spacer := Spacer;
    fmt.Separator := Separator;
    fmt.Isolator := Isolator;
  end;
  Items.Text := tagdump.ContinueSearch(SearchWord,fmt);
//  ShowMessage(Sender.ClassName);
end;

function Tdm.CreateField(vg: TcxVerticalGrid; AName,ACaption,ComboItems: string;
  FieldType: TFieldType; Category: TcxCustomRow; DefaultValue: Variant;
  ReadOnly: boolean = false): TcxCustomRow;
var
  cb: TcxEditRepositoryComboBoxItem;
  p: tcxCustomRowProperties;

  procedure sp(p: tcxCustomRowProperties; value: variant);
  begin
    if p is tcxEditorRowProperties then
      (p as tcxEditorRowProperties).Value := value
    else if p is tcxEditorRowItemProperties then
      (p as tcxEditorRowItemProperties).Value := value;
  end;

  function pv(p: tcxCustomRowProperties): variant;
  begin
    if p is tcxEditorRowProperties then
      result := (p as tcxEditorRowProperties).Value
    else if p is tcxEditorRowItemProperties then
      result := (p as tcxEditorRowItemProperties).Value;
  end;

begin
  if not Assigned(Category) or (Category is tcxCategoryRow) then
  begin
    if FieldType = ftMultiEdit then
    begin
      Result := vg.AddChild(Category,tcxMyMultiEditorRow);
      (result as tcxMyMultiEditorRow).FirstEditorHeader := true;
      Result.Name:= AName;
      //p := (Result as tcxMyMultiEditorRow).Properties;
      //(p as tcxMultiEditorRowProperties).Caption := ACaption;
      Exit;
    end else
    begin
      Result := vg.AddChild(Category, TcxEditorRow);
      p := (Result as tcxEditorRow).Properties;
      (p as tcxEditorRowProperties).Caption := ACaption;
      Result.Name := AName;
    end
  end else if Category is tcxMyMultiEditorRow then
  begin
    Result := Category;
    p := (Category as tcxMyMultiEditorRow).Properties.Editors.Add;
    if (Category as tcxMultiEditorRow).Properties.Editors.Count = 1 then
      (p as tcxEditorRowItemProperties).Caption := ACaption;
  end else
  begin
    Result := nil;
    Exit;
  end;

  if FieldType <> ftIndexCombo then
    sp(p,DefaultValue);
  //else
  //  Result.Properties.ItemIndex := DefaultValue;
  with p as tcxCustomEditorRowProperties do
  case FieldType of
    ftString:
      if ReadOnly then
        if pos('://',DefaultValue) > 0 then
          RepositoryItem := erURLText
        else
          RepositoryItem := erRDTextEdit;
    ftPassword:
      if  ReadOnly then
        RepositoryItem := erRDPassword
      else
        RepositoryItem := erPassword;
{    ftReadOnly:
      Result.Properties.RepositoryItem := erReadOnlyText;    }
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
    ftCombo,ftIndexCombo:
      begin
        //erCombo.Properties.Items.Clear;
        cb := TcxEditRepositoryComboBoxItem.Create(result);
        cb.Properties.DropDownListStyle := lsFixedList;
        //cb.Assign(erCombo);
        StringToList(comboitems, cb.Properties.Items);
        RepositoryItem := cb;
        if FieldType = ftIndexCombo then
          sp(p,cb.Properties.Items[DefaultValue]);
      end;
    ftCheck:
    begin
      if ReadOnly then
        RepositoryItem := erRDCheckBox
      else
        RepositoryItem := erCheckBox;
      sp(p,VarAsType(pv(p),varBoolean));
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
//var
//  r: tresourcestream;
//  b: tdxBarItemLink;
begin
  FCookie := TmyCookieList.Create;
  erPathText.Properties.Items.Text := LoadPathList;
  erPathText.Properties.IncrementalSearch := false;

  ertagedit := TcxMyEditRepositoryComboBoxItem.Create(erpathtext.Owner);
  ertagedit.Properties.WordMode := true;
  ertagedit.Properties.Spacer := ' ';
  ertagedit.Properties.OnBeforeGetItems := OnGetTagItems;

  with  TcxCustomEditProperties(ertagedit.Properties).Buttons do
  begin
    with Add as tcxEditButton do
    begin
      Kind := bkEllipsis;
      //LoadFromRes(Glyph,'XFAVORITE');
    end;
    //with Add as tcxEditButton do
    //begin
    //  Kind := bkGlyph;
    //  LoadFromRes(Glyph,'XREMFAVORITE');
    //end;
    with Add as tcxEditButton do
    begin
      Kind := bktext;
      Caption := '?';
      Visible := false;
    end;
  end;

  //b := mf.dxFavPopup.ItemLinks.AddItem(tdxBarButton);
  //(b.Item as tdxBarCombo).ite;


  //ertagedit.Properties.IncrementalSearch := false;
  //erPathText.Properties.LookupItems.Text := '';
end;

procedure Tdm.DataModuleDestroy(Sender: TObject);
begin
  FCookie.Free;
end;

procedure Tdm.EditRepositoryMRUItem1PropertiesButtonClick(Sender: TObject);
var
  fields: tstringlist;
  items: tstrings;
  n: integer;
  s: string;
  //r: TResource;
  //rl: tresourceslist;
  o: TObject;
begin
//  Pos
//  SameText
  //fields := tstringlist.Create;
  //try
  //ShowMessage((Sender as TcxMRUEdit).Parent.ClassName + ' ' + (Sender as TcxMRUEdit).Parent.Name);
  //(Sender as tcxMRUEdit).


  fields := tstringlist.Create; try
  o := Pointer(((Sender as TcxMRUEdit).Parent as TcxVerticalGrid).Tag);
  if o is tresourcelist then
  begin
    (o as tresourcelist).GetAllPictureFields(fields,true);
  end else if o is tresource then
    fields.Assign((o as tresource).PicFieldList)
  else
    exit;

  //fields := r.PicFieldList; //try
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

  finally fields.Free; end;
end;

procedure Tdm.erCSVListEditPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  fTextEdit.mText.Lines.BeginUpdate; try
  fTextEdit.mText.Text := strtostrlist((Sender as tcxbuttonedit).Text);
  finally fTextEdit.mText.Lines.EndUpdate; end;
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
        ShellExecute(0, nil, PCHAR(s){'EXPLORER'}, nil{PCHAR('/select, "' + s + '"')},
        nil, SW_SHOWNORMAL)
      else if DirectoryExists(s) then
        ShellExecute(0, nil, PChar(s), nil, nil, SW_SHOWNORMAL)
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

procedure Tdm.LoadFullResList(r: tResourceList);
begin
  r.LoadList(resources_dir);
  LoadResourceSettings(r);
  r.ThreadHandler.Cookies := FCookie;
  r.ThreadHandler.ThreadCount := GlobalSettings.Downl.ThreadCount;
  r.DWNLDHandler.Cookies := FCookie;
  r.DWNLDHandler.ThreadCount := GlobalSettings.Downl.ThreadCount;
end;

end.
