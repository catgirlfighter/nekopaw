unit NewListFrame;

interface

uses
  {base}
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, INIFiles, ShellAPI, Clipbrd, Types, UITypes,
  {devexp}
  cxGraphics, cxControls, cxLookAndFeels, cxTextEdit,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, cxImage, cxLabel, cxButtonEdit, cxPCdxBarPopupMenu,
  cxEditRepositoryItems, cxInplaceContainer, cxVGrid, cxPC, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxClasses, cxGridCustomView, cxGrid,
  cxButtons, ExtCtrls, cxSplitter, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, cxDropDownEdit,
  {graber2}
  cxmymultirow, cxmycombobox, common, Graberu, cxCheckBox,
  cxExtEditRepositoryItems, cxContainer, cxNavigator, cxGridCustomLayoutView,
  cxGridCardView, dxBar, cxBarEditItem;

type
  TListFrameState = (lfsNew, lfsEdit);

  TcxTextEdit = class(cxTextEdit.TcxTextEdit);

  TfNewList = class(TFrame)
    VSplitter: TcxSplitter;
    pButtons: TPanel;
    btnPrevious: TcxButton;
    lvlRes1: TcxGridLevel;
    gRes: TcxGrid;
    tvRes: TcxGridTableView;
    gRescName: TcxGridColumn;
    gRescButton: TcxGridColumn;
    pcMain: TcxPageControl;
    tsList: TcxTabSheet;
    tsSettings: TcxTabSheet;
    gFull: TcxGrid;
    tvFull: TcxGridTableView;
    tvFullcButton: TcxGridColumn;
    tvFullcName: TcxGridColumn;
    lvlFull1: TcxGridLevel;
    tvFullID: TcxGridColumn;
    tvFullcIcon: TcxGridColumn;
    gRescID: TcxGridColumn;
    tgRescIcon: TcxGridColumn;
    vgSettings: TcxVerticalGrid;
    btnNext: TcxButton;
    EditRepository: TcxEditRepository;
    erAuthButton: TcxEditRepositoryButtonItem;
    erLabel: TcxEditRepositoryLabel;
    erEdit: TcxEditRepositoryTextItem;
    tvFullShort: TcxGridColumn;
    gResShort: TcxGridColumn;
    pmFavList: TPopupMenu;
    Label1: TLabel;
    lTip: TcxLabel;
    pmgFullCopy: TPopupMenu;
    COPY1: TMenuItem;
    pmgResCopy: TPopupMenu;
    COPY2: TMenuItem;
    AddFav1: TMenuItem;
    RemFav1: TMenuItem;
    TagList1: TMenuItem;
    gFullCardView1: TcxGridCardView;
    dxBarDockControl1: TdxBarDockControl;
    dxBarManager: TdxBarManager;
    dxBarManagerBar1: TdxBar;
    bbFavorite: TdxBarButton;
    bbAll: TdxBarButton;
    FAVORITE1: TMenuItem;
    dxBarSubItem1: TdxBarSubItem;
    cxBarEditItem1: TcxBarEditItem;
    lHint: TcxLabel;
    procedure pcMainChange(Sender: TObject);
    procedure gRescButtonPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure tvFullcButtonPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure gRescNameGetProperties(Sender: TcxCustomGridTableItem;
      ARecord: TcxCustomGridRecord; var AProperties: TcxCustomEditProperties);
    procedure tvResFocusedRecordChanged(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    procedure tsSettingsShow(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnPreviousClick(Sender: TObject);
    procedure erAuthButtonPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure tvFullcButtonGetProperties(Sender: TcxCustomGridTableItem;
      ARecord: TcxCustomGridRecord; var AProperties: TcxCustomEditProperties);
    procedure tvFullcNameGetProperties(Sender: TcxCustomGridTableItem;
      ARecord: TcxCustomGridRecord; var AProperties: TcxCustomEditProperties);
    procedure AddToFavoritesClick(Sender: TObject);
    procedure RemoveFromFavoritesClick(Sender: TObject);
    procedure ExecAddFavClick(Sender: TObject);
    procedure ExecRemFavClick(Sender: TObject);
    procedure SetFavoriteClick(Sender: TObject);
    procedure tvFullEditValueChanged(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem);
    procedure tvFullDataControllerFilterChanged(Sender: TObject);
    procedure tvFullKeyPress(Sender: TObject; var Key: Char);
    procedure ExecCheatSheetClick(Sender: TObject);
    procedure COPY1Click(Sender: TObject);
    procedure COPY2Click(Sender: TObject);
    procedure TagList1Click(Sender: TObject);
    procedure pmFavListPopup(Sender: TObject);
    procedure bbFavoriteClick(Sender: TObject);
    procedure bbAllClick(Sender: TObject);
    procedure FAVORITE1Click(Sender: TObject);
    procedure pmgFullCopyPopup(Sender: TObject);
    procedure lHintClick(Sender: TObject);
  private
    { Private declarations }
    FOnError: TLogEvent;
    // fPathList: TStringList;
    FAutoAdd: Boolean;
    FFullResList: TResourceList;
    FActualResList: TResourceList;
    fCurrItem: TResource;
  protected
    procedure OnTagstringButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure LoadFavs(pm: TMenuItem; Event: TNotifyEvent);
    function ResetRelogin(idx: Integer = 0): Boolean;
    procedure SetIntrfEnabled(b: Boolean);
    procedure LoginCallBack(Sender: TObject; N: Integer;
      Login, Password: String; const Cancel: Boolean);
    procedure refillRec(DataController: TcxGridDataController;
      RecordIndex, ItemOffset: Integer);
    procedure fillRec(r: TResourceList; DataController: TcxGridDataController;
      RecordIndex, ItemOffset: Integer; add: Boolean = false);
    procedure refillRecs;
  public
    State: TListFrameState;
    procedure AddItem(index: Integer);
    procedure RemoveItem(index: Integer);
    procedure CreateSettings(rs: TResource);
    procedure SaveSettings;
    procedure LoadItems(fPList: TResourceList = nil);
    procedure ResetItems;
    procedure SetLang;
    procedure OnErrorEvent(Sender: TObject; Msg: String; Data: Pointer);
    procedure JobStatus(Sander: TObject; Action: Integer);
    procedure SendMsg(Cancel: Boolean = false);
    procedure SaveSet;
    // procedure LoadLists;
    procedure Release;
    procedure ResetFav;
    procedure ResetRemFav;
    // procedure LoadSet;
    property OnError: TLogEvent read FOnError write FOnError;
    property FullResList: TResourceList read FFullResList;
    property ActualResList: TResourceList read FActualResList
      write FActualResList;
    { Public declarations }
  end;

implementation

uses OpBase, LangString, utils, LoginForm, TextEditorForm;

{$R *.dfm}
// const
// SJobNum: array[tSemiListJob] of byte = (0,1,2);
// NumSJob: array[0..2] of tSemiListJob = (sljNone,sljPostproc,sljPics);

var
  // LList: array of TcxLabelProperties;
  FLoggedOn: Boolean;

function Min(n1, n2: Integer): Integer;
begin
  if n1 < n2 then
    Result := n1
  else
    Result := n2;
end;

function TfNewList.ResetRelogin(idx: Integer = 0): Boolean;
var
  i: Integer;
  N: TResource;
begin
  Result := false;
  { for i := 0 to FullResList.Count - 1 do
    FullResList[i].Relogin := false; }
  if idx = 0 then
    for i := 1 to tvRes.DataController.RecordCount - 1 do
    begin
      N := Pointer(Integer(tvRes.DataController.Values[i, 0]));
      if not N.Parent.Relogin then
        N.Parent.Fields.Assign(N.Fields);
      Result := Result or N.Parent.ResetRelogin;
    end
  else
  begin
    N := Pointer(idx);
    // N.ResetRelogin;
    if not N.Parent.Relogin then
      N.Parent.Fields.Assign(N.Fields);
    Result := N.Parent.ResetRelogin;
  end;
end;

procedure TfNewList.ResetRemFav;
begin
  RemFav1.Clear;
  // pmFavList.Items.Clear;
  LoadFavs(RemFav1, RemoveFromFavoritesClick);
end;

procedure TfNewList.AddItem(index: Integer);
var
  i: Integer;
  // n: integer;
  r: TResource;
begin
  tvFull.BeginUpdate;
  try
    tvRes.BeginUpdate;
    try
      i := tvRes.DataController.RecordCount;
      tvRes.DataController.RecordCount := i + 1;
      r := ActualResList
        [ActualResList.CopyResource
        (TResource(Integer(tvFull.DataController.Values[index, 1])))];
      r.Parent := TResource(Integer(tvFull.DataController.Values[index, 1]));
      r.IsNew := True;
      tvRes.DataController.Values[i, 0] := Integer(r);
      { tvFull.DataController.Values[index, 1]; }
      tvRes.DataController.Values[i, 1] := tvFull.DataController.Values
        [index, 2];
      tvRes.DataController.Values[i, 2] := r.Name;
      { tvFull.DataController.Values
        [index, 3] };
      tvRes.DataController.Values[i, 3] := tvFull.DataController.Values
        [index, 4];
      // tvFull.DataController.DeleteRecord(index);
      if tvFull.DataController.RowCount = 0 then
        tvFull.DataController.FocusedRecordIndex := -1;
    finally
      tvRes.EndUpdate;
    end;
  finally
    tvFull.EndUpdate;
  end;

  btnNext.Enabled := tvRes.DataController.RowCount > 1;
end;

procedure TfNewList.AddToFavoritesClick(Sender: TObject);
var
  s: string;
  // rs: integer;
begin
  vgSettings.InplaceEditor.PostEditValue;
  s := FullResList[0].FormatTagString
    (VarToStr((vgSettings.RowByName('vgitag') as TcxEditorRow)
    .Properties.DisplayTexts[0]), fCurrItem.HTTPRec.TagTemplate);

  if trim(s) = '' then
    Exit;

  AddSorted(s, GlobalFavList);

  SaveFavList(GlobalFavList);
end;

procedure TfNewList.bbAllClick(Sender: TObject);
begin
  refillRecs;
end;

procedure TfNewList.bbFavoriteClick(Sender: TObject);
begin
  refillRecs;
end;

procedure TfNewList.btnNextClick(Sender: TObject);
begin
  if pcMain.ActivePage = tsSettings then
  begin
    FLoggedOn := True;
    if ResetRelogin then
    begin
      SetConSettings(FullResList);
      FullResList.StartJob(JOB_LOGIN)
    end
    else
      SendMsg;
  end
  else
  begin
    pcMain.ActivePage := tsSettings;
    if Assigned(Parent) then
      Application.MainForm.ActiveControl := vgSettings;
    // vgSettings.SetFocus;

    if tvRes.ViewData.RowCount < 3 then
      tvRes.Controller.FocusedRowIndex := 1
    else
      tvRes.Controller.FocusedRowIndex := 0;

    vgSettings.RowByName('vgitag').Focused := True;
  end;
end;

procedure TfNewList.btnPreviousClick(Sender: TObject);
begin
  if not FullResList.ListFinished then
  begin
    FullResList.StartJob(JOB_STOPLIST);
    FLoggedOn := false;
  end
  else if pcMain.ActivePage = tsSettings then
    pcMain.ActivePage := tsList
  else
    SendMsg(True);
end;

procedure TfNewList.lHintClick(Sender: TObject);
begin
  GlobalSettings.GUI.NewListShowHint := not GlobalSettings.GUI.NewListShowHint;

  if GlobalSettings.GUI.NewListShowHint then
    lHint.AutoSize := True
  else
  begin
    lHint.AutoSize := false;
    lHint.Height := lHint.Canvas.TextHeight('Example') + 6;
  end;
end;

procedure TfNewList.COPY1Click(Sender: TObject);
begin
  if Assigned(tvFull.Controller.FocusedItem) and
    (tvFull.DataController.RecordCount > 0) then

    if (tvRes.Controller.FocusedColumn.index in [0, 2]) then
      clipboard.AsText := VarToStr(tvFull.Controller.FocusedRow.Values[3])
    else
      clipboard.AsText := VarToStr(tvFull.Controller.FocusedItem.EditValue);
end;

procedure TfNewList.CreateSettings(rs: TResource);
var
  c: TcxCategoryRow;
  r: TcxCustomRow;
  i, d: Integer;
  s: string;
  // t: tcxMyEditRepositoryComboBoxItem;

begin
  if (vgSettings.Rows.Count > 0) and Assigned(fCurrItem) then
    SaveSettings;
  vgSettings.BeginUpdate;
  try
    vgSettings.ClearRows;

    if Assigned(rs) then
    begin
      fCurrItem := rs;
      vgSettings.Tag := Integer(fCurrItem);
    end
    else
    begin
      fCurrItem := FullResList[0];
      vgSettings.Tag := Integer(FullResList);
    end;

    if not Assigned(rs) then
    begin
      lHint.Visible := True;
      lHint.Caption := lang('_EXAMPLE_') + #13#10 + 'tag: tag_1 tag_2';

      c := dm.CreateCategory(vgSettings, 'vgimain', lang('_MAINCONFIG_'));

      if FullResList[0].KeywordList.Count > 0 then
        s := '<list>'
      else
        s := VarToStr(FullResList[0].Fields['tag']);
      dm.CreateField(vgSettings, 'vgitag', lang('_TAGSTRING_'), '',
        ftTagText, c, s);

      with (dm.ertagedit.Properties as TcxCustomEditProperties) do
      begin
        OnButtonClick := OnTagstringButtonClick;
        // Buttons[1].Visible := fCurrItem.isNew;
        Buttons[2].Visible := false;
        if (FullResList[0].KeywordList.Count > 0) then
        begin
          ReadOnly := True;
        end
        else
          ReadOnly := false;
      end;

      dm.CreateField(vgSettings, 'vgidwpath', lang('_SAVEPATH_'), '',
        ftPathText, c, fCurrItem.NameFormat);
      dm.CreateField(vgSettings, 'vgisdalf', lang('_LISTPW_'),
        '"' + lang('_NOTHING_') + '","' + lang('_SPPS_') + '","' +
        lang('_SPDS_') + '"', ftIndexCombo, c, Integer(GlobalSettings.SemiJob));
      dm.CreateField(vgSettings, 'vgiexif', lang('_WRITEEXIF_'), '', ftCheck, c,
        GlobalSettings.WriteEXIF);
    end
    else
      with fCurrItem do
      begin
        if KeywordHint = '' then
          lHint.Visible := false
        else
        begin
          lHint.Visible := True;
          lHint.Caption := lang('_EXAMPLE_') + #13#10 + KeywordHint;
        end;

        c := dm.CreateCategory(vgSettings, 'vgimain', lang('_MAINCONFIG_') + ' '
          + fCurrItem.Name);

        //if IsNew then
          (dm.CreateField(vgSettings, 'vgiinherit', lang('_INHERIT_'), '',
            ftCheck, c, false) as tcxEditorRow).Visible := IsNew;

        if KeywordList.Count > 0 then
          s := '<list>'
        else
          s := VarToStr(Fields['tag']);

        if ((s = '') or Inherit) and (KeywordList.Count = 0) and
          (FullResList[0].KeywordList.Count = 0) and
          (VarToStr(FullResList[0].Fields['tag']) <> '') then
          s := fCurrItem.FormatTagString(VarToStr(FullResList[0].Fields['tag']),
            FullResList[0].HTTPRec.TagTemplate) +
            fCurrItem.HTTPRec.TagTemplate.Separator;

        with dm.ertagedit.Properties, fCurrItem.HTTPRec do
        begin
          Spacer := TagTemplate.Spacer;
          Separator := TagTemplate.Separator;
          Isolator := TagTemplate.Isolator;
        end;

        dm.CreateField(vgSettings, 'vgitag', lang('_TAGSTRING_'), '',
          ftTagText, c, s);

        with (dm.ertagedit.Properties as TcxCustomEditProperties) do
        begin
          OnButtonClick := OnTagstringButtonClick;
          Buttons[1].Enabled := isNew;
          Buttons[2].Visible := fCurrItem.CheatSheet <> '';
          if not isNew or (KeywordList.Count > 0) then
          begin
            ReadOnly := True;
          end
          else
            ReadOnly := false;
        end;

        s := NameFormat;
        if (s = '') or Inherit then
          s := FullResList[0].NameFormat;

        dm.CreateField(vgSettings, 'vgidwpath', lang('_SAVEPATH_'), '',
          ftPathText, c, s);

        d := FullResList[0].Fields.Count;

        c := nil;

        r := nil;

        if fCurrItem.IsNew and (fCurrItem.Fields.Count > d) then
          with fCurrItem.Fields do
          begin
            for i := d to Count - 1 do
              if Items[i].restype <> ftNone then
              begin
                c := dm.CreateCategory(vgSettings, 'vgieditional',
                  lang('_EDITIONALCONFIG_'));
                Break;
              end
              else
                inc(d);

            for i := d to Count - 1 do
              if Items[i].restype <> ftNone then
                with fCurrItem.Fields.Items[i]^ do
                  if InMulti then
                    dm.CreateField(vgSettings, 'evgi' + resname, restitle,
                      resitems, restype, r, resvalue)
                  else
                    r := dm.CreateField(vgSettings, 'evgi' + resname, restitle,
                      resitems, restype, c, resvalue);
          end;

        c := dm.CreateCategory(vgSettings, 'vgispecial',
          lang('_SPECIALSETTINGS_'));
        if not Parent.ThreadCounter.UseUserSettings and
          (Parent.ThreadCounter.UseProxy = -1) and (HTTPRec.StartCount = 0) and
          (HTTPRec.MaxCount = 0) then
          c.Expanded := false;

        r := dm.CreateField(vgSettings, 'vgicountlimit', '', '',
          ftMultiEdit, c, null);
        dm.CreateField(vgSettings, 'vgimincount', lang('_COUNTLIMIT_'), '',
          ftNumber, r, HTTPRec.StartCount);
        dm.CreateField(vgSettings, 'vgimaxcount', '', '', ftNumber, r,
          HTTPRec.MaxCount);

        dm.CreateField(vgSettings, 'vgiproxy', lang('_USE_PROXY_'),
          lang('_PROXY_DEFAULT_') + ',' + lang('_PROXY_DISABLED_') + ',' +
          lang('_PROXY_ALWAYS_') + ',' + lang('_PROXY_LIST_') + ',' +
          lang('_PROXY_PICS_'), ftIndexCombo, c,
          Parent.ThreadCounter.UseProxy + 1);
        dm.CreateField(vgSettings, 'vgiinheritstt', lang('_OWNSETTINGS_'), '',
          ftCheck, c, Parent.ThreadCounter.UseUserSettings);
        dm.CreateField(vgSettings, 'vgithreadcount', lang('_THREAD_COUNT_'), '',
          ftNumber, c, Parent.ThreadCounter.UserSettings.MaxThreadCount);
        dm.CreateField(vgSettings, 'vgithreaddelay', lang('_QUERY_DELAY_'), '',
          ftNumber, c, Parent.ThreadCounter.UserSettings.PageDelay);
        dm.CreateField(vgSettings, 'vgipicdelay', lang('_PIC_DELAY_'), '',
          ftNumber, c, Parent.ThreadCounter.UserSettings.PicDelay);

      end;

    dm.ertagedit.Properties.Spacer := fCurrItem.HTTPRec.TagTemplate.Spacer;
    dm.ertagedit.Properties.Separator :=
      fCurrItem.HTTPRec.TagTemplate.Separator;
    dm.ertagedit.Properties.Isolator := fCurrItem.HTTPRec.TagTemplate.Isolator;

  finally
    vgSettings.EndUpdate;
  end;
end;

procedure TfNewList.erAuthButtonPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var
  N: Integer;
  r: TResource;
begin
  N := tvRes.DataController.Values[tvRes.DataController.FocusedRecordIndex, 0];
  r := Pointer(N);
  Application.CreateForm(TfLogin, fLogin);
  fLogin.Execute(N, Format(lang('_LOGINON_'), [r.Name]),
    nullstr(r.Fields['login']), nullstr(r.Fields['password']), LoginCallBack);
end;

procedure TfNewList.ExecAddFavClick(Sender: TObject);
begin
  ResetFav;
  pmFavList.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TfNewList.ExecCheatSheetClick(Sender: TObject);
begin
  if fCurrItem.CheatSheet <> '' then
    ShellExecute(0, nil, PCHAR(fCurrItem.CheatSheet), nil, nil, SW_SHOWNORMAL);
end;

procedure TfNewList.ExecRemFavClick(Sender: TObject);
begin
  ResetRemFav;
  pmFavList.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TfNewList.FAVORITE1Click(Sender: TObject);
var
  r: TResource;
begin
  if Assigned(tvFull.Controller.FocusedItem) and
    (tvFull.DataController.RecordCount > 0) then
  begin
    r := TResource(Integer(tvFull.Controller.FocusedRow.Values[1]));
    r.Favorite := not r.Favorite;
    SaveFavResource(r);
    if bbFavorite.Down and not r.Favorite then
      tvFull.Controller.DeleteSelection
    else
      refillRec(tvFull.DataController,
        tvFull.Controller.FocusedRow.RecordIndex, 1);
  end;
end;

procedure TfNewList.gRescButtonPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  RemoveItem(tvRes.DataController.FocusedRecordIndex);
end;

procedure TfNewList.gRescNameGetProperties(Sender: TcxCustomGridTableItem;
  ARecord: TcxCustomGridRecord; var AProperties: TcxCustomEditProperties);
begin
  if (ARecord.Values[0] <> null) and (ARecord.Values[0] <> 0) then
    AProperties := erAuthButton.Properties;
  // ARecord.Values[2] := ARecord.Values[0];
end;

procedure TfNewList.OnErrorEvent(Sender: TObject; Msg: String; Data: Pointer);
begin
  if FLoggedOn then
    FLoggedOn := false;
  if Assigned(FOnError) then
    FOnError(Sender, Msg, nil);
end;

procedure TfNewList.JobStatus(Sander: TObject; Action: Integer);
begin
  case Action of
    JOB_LOGIN:
      begin
        SetIntrfEnabled(false);
        lTip.Caption := Format(lang('_LOGGINGIN_PLEASEWAIT_'),
          [btnPrevious.Caption]);
      end;
    JOB_STOPLIST:
      begin
        SetIntrfEnabled(True);
        if Assigned(fLogin) then
          if FLoggedOn or FullResList.Canceled then
            fLogin.Close
          else
            fLogin.bOk.Enabled := True
        else if FLoggedOn then
          SendMsg;
      end;
  end;
end;

procedure TfNewList.fillRec(r: TResourceList;
  DataController: TcxGridDataController; RecordIndex, ItemOffset: Integer;
  add: Boolean = false);
var
  s: String;
  N: Integer;
begin
  with DataController do
  begin
    N := RecordCount;
    RecordCount := RecordCount + 1;
    Values[N, ItemOffset] := Integer(r[RecordIndex]);
    try
      if r[RecordIndex].IconFile <> '' then
      begin
        s := String(FileToStr(rootdir + '\resources\icons\' + r[RecordIndex].IconFile));
        Values[N, ItemOffset + 1] := s;
      end;

      if not bbFavorite.Down and r[RecordIndex].Favorite then
        if add then
          Values[N, ItemOffset + 2] := '[ ' + r[RecordIndex].Name + ' ] ☆'
        else
          Values[N, ItemOffset + 2] := r[RecordIndex].Name + ' ☆'
      else if add then
        Values[N, ItemOffset + 2] := '[ ' + r[RecordIndex].Name + ' ]'
      else
        Values[N, ItemOffset + 2] := r[RecordIndex].Name;
      Values[N, ItemOffset + 3] := r[RecordIndex].Short;
    except
    end;
  end;
end;

procedure TfNewList.refillRec(DataController: TcxGridDataController;
  RecordIndex, ItemOffset: Integer);
var
  s: String;
  r: TResource;
  // N: Integer;
begin
  with DataController do
  begin
    // N := RecordCount;
    // RecordCount := RecordCount + 1;
    // Values[N, ItemOffset] := Integer(r[RecordIndex]);
    r := TResource(Integer(Values[RecordIndex, ItemOffset]));

    try
      if r.IconFile <> '' then
      begin
        s := String(FileToStr(rootdir + '\resources\icons\' + r.IconFile));
        Values[RecordIndex, ItemOffset + 1] := s;
      end;

      if not bbFavorite.Down and r.Favorite then
        Values[RecordIndex, ItemOffset + 2] := r.Name + ' ☆'
      else
        Values[RecordIndex, ItemOffset + 2] := r.Name;

      Values[RecordIndex, ItemOffset + 3] := r.Short;
    except
    end;

  end;
end;

procedure TfNewList.LoadItems(fPList: TResourceList = nil);

var
  i: Integer;
  s: tstringlist;
  N: Integer;
begin
  // fPathList := TStringList.Create;
  if not Assigned(FullResList) then
  begin
    FFullResList := TResourceList.Create;
    vgSettings.Tag := Integer(FFullResList);
    dm.LoadFullResList(FFullResList);
    FFullResList.OnError := OnErrorEvent;
    FFullResList.OnJobChanged := JobStatus;
  end;

  if GlobalSettings.GUI.NewListShowHint then
    lHint.AutoSize := True
  else
  begin
    lHint.AutoSize := false;
    lHint.Height := lHint.Canvas.TextHeight('Example') + 6;
  end;

  bbAll.Down := not GlobalSettings.GUI.NewListFavorites;
  FAutoAdd := false;
  gFull.BeginUpdate;
  gRes.BeginUpdate;
  try
    // pic := TPicture.Create;

    with tvRes.DataController do
    begin
      RecordCount := 1;
      Values[0, 0] := 0;
      Values[0, 2] := lang('_GENERAL_');
    end;

    //if  then
    //begin

      s := tstringlist.Create;
      try
        s.Text := StrToStrList(GlobalSettings.GUI.LastUsedSet, ',');

        for i := 1 to FullResList.Count - 1 do
        begin

          if not bbFavorite.Down or bbFavorite.Down and FullResList[i].Favorite
          then
            fillRec(FullResList, tvFull.DataController, i, 1);

          if State = lfsNew then
          if s.IndexOf(FullResList[i].Name) <> -1 then
          begin
            with ActualResList[ActualResList.CopyResource(FullResList[i])] do
            begin
              Parent := FullResList[i];
              IsNew := True;
            end;
            fillRec(ActualResList, tvRes.DataController,
              ActualResList.Count - 1, 0)
          end;
        end;
      finally
        s.Free;
      end;
    //end
    //else
    if State = lfsEdit then
    begin
      for i := 0 to fPList.Count - 1 do
      begin
        ActualResList.CopyResource(fPList[i]);
        fillRec(ActualResList, tvRes.DataController,
          ActualResList.Count - 1, 0, True);

        N := FFullResList.findByName(fPList[i].Name);
        if N = -1 then
          raise Exception.Create('Unknown resource: ' + fPList[i].Name);

        ActualResList[i].Inherit := false;
        ActualResList[i].Parent := FFullResList[N];

        if not Assigned(fPList[i].MainResource) then
        begin
          FFullResList[N].MainResource := fPList[i];
          fFullResList[N].ThreadCounter^ := fPList[i].ThreadCounter^;
        end;

      end;
    end;

  finally
    gRes.EndUpdate;
  end;

  if tvRes.DataController.RecordCount > 1 then
    btnNext.Click;

  gFull.EndUpdate;
  tvFull.ApplyBestFit(tvFullShort);

  btnNext.Enabled := tvRes.DataController.RowCount > 1;
end;

procedure TfNewList.pcMainChange(Sender: TObject);
begin
  with (Sender as TcxPageControl) do
  begin

    gRescButton.Visible := ActivePage = tsList;
    // btnPrevious.Enabled := ActivePage = tsSettings;
    if ActivePage = tsSettings then
    begin
      btnPrevious.Caption := lang('_CHANGELIST_');
      btnNext.Caption := lang('_FINISH_')
    end
    else
    begin
      fCurrItem := nil;
      btnPrevious.Caption := lang('_CANCEL_');
      btnNext.Caption := lang('_CONTINUE_');
    end;
  end;
end;

procedure TfNewList.pmFavListPopup(Sender: TObject);
begin
  if fCurrItem.KeywordList.Count > 0 then
    TagList1.Caption := lang('_CHANGETAGLIST_')
  else
    TagList1.Caption := lang('_CREATETAGLIST_')
end;

procedure TfNewList.pmgFullCopyPopup(Sender: TObject);
begin
  if Assigned(tvFull.Controller.FocusedItem) and
    (tvFull.DataController.RecordCount > 0) then
    if TResource(Integer(tvFull.Controller.FocusedRow.Values[1])).Favorite then
      FAVORITE1.Caption := lang('_REMOVEFROMFAVORITES_')
    else
      FAVORITE1.Caption := lang('_ADDTOFAVORITES_')
  else
    FAVORITE1.Caption := lang('_ADDTOFAVORITES_')
end;

procedure TfNewList.refillRecs;
var
  i: Integer;
begin
  FAutoAdd := false;
  tvFull.DataController.Filter.Clear;
  tvFull.BeginUpdate;
  try
    tvFull.DataController.RecordCount := 0;
    for i := 1 to FullResList.Count - 1 do
      if not bbFavorite.Down or bbFavorite.Down and FullResList[i].Favorite then
        fillRec(FullResList, tvFull.DataController, i, 1);
  finally
    tvFull.EndUpdate;
  end;
end;

procedure TfNewList.Release;
var
  i: Integer;
begin
  for i := 0 to ActualResList.Count - 1 do
  begin
    if ActualResList[i].Parent.MainResource = nil then
      ActualResList[i].Parent.MainResource := ActualResList[i]
    else
      ActualResList[i].MainResource := ActualResList[i].Parent.MainResource;

    ActualResList[i].SetThreadCounter(ActualResList[i].Parent.ThreadCounter);

    ActualResList[i].Parent := nil;
  end;

  FFullResList.Free;
end;

procedure TfNewList.RemoveFromFavoritesClick(Sender: TObject);
begin
  // s := (Sender as TMenuItem).Caption;
  // RemSorted(s,GlobalFavList);
  GlobalFavList.Delete((Sender as TMenuItem).Tag);
  SaveFavList(GlobalFavList);
end;

procedure TfNewList.RemoveItem(index: Integer);

  function rem(index: Integer): boolean;
  var
    i: Integer;
  begin
    // i := tvFull.DataController.RecordCount;
    // tvFull.DataController.RecordCount := i + 1;
    // tvFull.DataController.Values[i, 1] := tvRes.DataController.Values[index, 0];;
    // tvFull.DataController.Values[i, 2] := tvRes.DataController.Values[index, 1];
    // tvFull.DataController.Values[i, 3] := tvRes.DataController.Values[index, 2];
    // tvFull.DataController.Values[i, 4] := tvRes.DataController.Values[index, 3];
    i := tvRes.DataController.Values[index, 0];
    if not TResource(Pointer(i)).IsNew then
    begin
      //MessageDlg(lang('_CANTREMLITEMS_'),mtError,[mbOk],0);
      Exit(false);
    end;

    ActualResList.Remove(Pointer(i));
    tvRes.DataController.DeleteRecord(index);
    Result := true;
  end;

var
  i: Integer;

begin
  { loop := index = 0;

    if loop then
    index := Min(1,tvRes.DataController.RecordCount -1); }

  tvFull.BeginUpdate;
  try
    tvRes.BeginUpdate;
    try
      { while index > tvRes.DataController.RecordCount-2 do
        begin


        if not loop then
        index := 0;
        end; }

      i := 1;
      if index = 0 then
        while i < tvRes.DataController.RecordCount  do
          if not rem(i) then
            inc(i)
          else

        //for i := 1 to tvRes.DataController.RecordCount - 1 do
        //  rem(1)
      else
        if not rem(index) then
        begin
          MessageDlg(lang('_CANTREMLITEMS_'),mtError,[mbOK],0);
          Exit;
        end;

      tvRes.DataController.FocusedRecordIndex :=
        Min(index, tvRes.DataController.RecordCount - 1);
    finally
      tvRes.EndUpdate;
    end;
  finally
    tvFull.EndUpdate;
  end;
  btnNext.Enabled := tvRes.DataController.RowCount > 1;
end;

procedure TfNewList.ResetFav;
var
  N: TMenuItem;
begin
  AddFav1.Clear;
  N := TMenuItem.Create(pmFavList);
  N.Caption := lang('_ADDTOFAVORITES_');
  N.OnClick := AddToFavoritesClick;
  AddFav1.add(N);
  N := TMenuItem.Create(pmFavList);
  N.Caption := '-';
  AddFav1.add(N);
  LoadFavs(AddFav1, SetFavoriteClick);
  ResetRemFav;
end;

procedure TfNewList.OnTagstringButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  case AButtonIndex of
    1:
      ExecAddFavClick(Sender);
    // 2: ExecRemFavClick(Sender);
    2:
      ExecCheatSheetClick(Sender);
  end;
end;

procedure TfNewList.LoadFavs(pm: TMenuItem; Event: TNotifyEvent);
var
  i { ,l } : Integer;
  N: TMenuItem;
begin
  // l := fCurrItem;
  for i := 0 to GlobalFavList.Count - 1 do
  begin
    N := TMenuItem.Create(pm);
    N.Caption := fCurrItem.FormatTagString(GlobalFavList[i],
      FullResList[0].HTTPRec.TagTemplate);
    N.OnClick := Event;
    N.Tag := i;
    pm.add(N);
  end;
end;

procedure TfNewList.ResetItems;
begin
  SaveSettings;
end;

procedure TfNewList.SaveSet;
var
  i: Integer;
  slist: tstringlist;
  s: string;
begin
  if tvRes.DataController.RecordCount > 1 then
  begin
    slist := tstringlist.Create;
    try
      slist.add(ActualResList[0].Name);
      for i := 1 to ActualResList.Count - 1 do
        if slist.IndexOf(ActualResList[i].Name) = -1 then
          slist.add(ActualResList[i].Name);

      s := slist[0];
      for i := 1 to slist.Count - 1 do
        s := s + ',' + slist[i];

    finally
      slist.Free;
    end;
  end
  else
    s := '';
  GlobalSettings.GUI.LastUsedSet := s;
  GlobalSettings.GUI.NewListFavorites := bbFavorite.Down;
  SaveGUISettings([gvResSet]);
end;

procedure TfNewList.SaveSettings;
var
  i, { n, } d: Integer;
  r: tcxMyMultiEditorRow;
  rec: thttprec;
begin
  // n := fCurrItem;
  with fCurrItem do
  begin
    Fields['tag'] := VarToStr((vgSettings.RowByName('vgitag') as TcxEditorRow)
      .Properties.Value);

    NameFormat := VarToStr((vgSettings.RowByName('vgidwpath') as TcxEditorRow)
      .Properties.Value);

    if fCurrItem = FullResList[0] then
    begin
      GlobalSettings.SemiJob :=
        tSemiListJob(IndexOfStr('"' + lang('_NOTHING_') + '","' + lang('_SPPS_')
        + '","' + lang('_SPDS_') + '"',
        (vgSettings.RowByName('vgisdalf') as TcxEditorRow).Properties.Value));
      GlobalSettings.WriteEXIF :=
        (vgSettings.RowByName('vgiexif') as TcxEditorRow).Properties.Value;
    end
    else { if fCurrItem > 0 then }
    begin
      Inherit := (vgSettings.RowByName('vgiinherit') as TcxEditorRow)
        .Properties.Value;

      d := FullResList[0].Fields.Count;

      if tvRes.ViewData.RowCount < 3 then
        FullResList[0].NameFormat := NameFormat;

      r := nil;

      if IsNew and (Fields.Count > d) then
        with Fields do
          for i := d to Count - 1 do
            if Items[i].restype <> ftNone then
            begin
              case Items[i].restype of
                ftMultiEdit:
                  r := vgSettings.RowByName('evgi' + Items[i].resname)
                    as tcxMyMultiEditorRow;
                ftIndexCombo:
                  if Items[i].InMulti then
                    Items[i].resvalue := IndexOfStr(Items[i].resitems,
                      r.Properties.Editors[StrToInt(CopyFromTo(Items[i].resname,
                      '[', ']', [], [])) - 1].Value)
                  else
                    Items[i].resvalue := IndexOfStr(Items[i].resitems,
                      (vgSettings.RowByName('evgi' + Items[i].resname)
                      as TcxEditorRow).Properties.Value);
              else
                if Items[i].InMulti then
                  Items[i].resvalue := r.Properties.Editors
                    [StrToInt(CopyFromTo(Items[i].resname, '[', ']', [], []))
                    - 1].Value
                else
                  Items[i].resvalue :=
                    (vgSettings.RowByName('evgi' + Items[i].resname)
                    as TcxEditorRow).Properties.Value;
              end;

            end;

      rec := HTTPRec;
      r := vgSettings.RowByName('vgicountlimit') as tcxMyMultiEditorRow;
      rec.StartCount := r.Properties.Editors[0].Value;
      rec.MaxCount := r.Properties.Editors[1].Value;
      HTTPRec := rec;

      Parent.ThreadCounter.UseProxy :=
        IndexOfStr(lang('_PROXY_DEFAULT_') + ',' + lang('_PROXY_DISABLED_') +
        ',' + lang('_PROXY_ALWAYS_') + ',' + lang('_PROXY_LIST_') + ',' +
        lang('_PROXY_PICS_'), (vgSettings.RowByName('vgiproxy') as TcxEditorRow)
        .Properties.Value) - 1;

      Parent.ThreadCounter.UseUserSettings :=
        (vgSettings.RowByName('vgiinheritstt') as TcxEditorRow)
        .Properties.Value;

      Parent.ThreadCounter.UserSettings.MaxThreadCount :=
        (vgSettings.RowByName('vgithreadcount') as TcxEditorRow)
        .Properties.Value;

      Parent.ThreadCounter.UserSettings.PageDelay :=
        (vgSettings.RowByName('vgithreaddelay') as TcxEditorRow)
        .Properties.Value;

      Parent.ThreadCounter.UserSettings.PicDelay :=
        (vgSettings.RowByName('vgipicdelay') as TcxEditorRow).Properties.Value;
    end;
  end;
end;

procedure TfNewList.SendMsg(Cancel: Boolean);
begin
  if Cancel then
  begin
    PostMessage(Application.MainForm.Handle, CM_CANCELNEWLIST,
      Integer(Parent), 0);
    Exit;
  end;

  SaveSet;
  //case State of
  //  lfsNew:
      PostMessage(Application.MainForm.Handle, CM_APPLYNEWLIST,
        Integer(Parent), 0);
  //  lfsEdit:
  //    PostMessage(Application.MainForm.Handle, CM_APPLYEDITLIST,
  //      Integer(Parent), 0);
  //end;
end;

procedure TfNewList.SetFavoriteClick(Sender: TObject);
// var
// s: string;
// n: integer;
begin
  vgSettings.InplaceEditor.EditValue := (Sender as TMenuItem).Caption;
  vgSettings.InplaceEditor.PostEditValue;
end;

procedure TfNewList.SetIntrfEnabled(b: Boolean);
begin
  gFull.Enabled := b;
  gRes.Enabled := b;
  btnNext.Enabled := b;
  vgSettings.Enabled := b;
  if b then
    lTip.Caption := '';
end;

procedure TfNewList.LoginCallBack(Sender: TObject; N: Integer;
  Login, Password: String; const Cancel: Boolean);
var
  r: TResource;
begin
  r := Pointer(N);
  if Cancel then
  begin
    FLoggedOn := false;
    if not FullResList.ListFinished then
      FullResList.StartJob(JOB_STOPLIST)
    else
      fLogin.Close;
  end
  else
  begin
    r.Fields['login'] := Login;
    r.Fields['password'] := Password;
    if ResetRelogin(N) then
    begin
      FLoggedOn := True;
      SetConSettings(FullResList);
      FullResList.StartJob(JOB_LOGIN);
    end
    else
      fLogin.Close;
  end;
end;

procedure TfNewList.COPY2Click(Sender: TObject);
begin
  if Assigned(tvRes.Controller.FocusedRow) then
    clipboard.AsText := VarToStr(tvRes.Controller.FocusedRow.Values[2]);
end;

procedure TfNewList.SetLang;
begin
  btnPrevious.Caption := lang('_PREVIOUSSTEP_');
  btnNext.Caption := lang('_NEXTSTEP_');
  bbFavorite.Caption := lang('_FAVORITES_');
  bbAll.Caption := lang('_ALL_');
  tvFull.FilterRow.InfoText := lang('_FILTERROWHINT_');
  tvFull.OptionsView.NoDataToDisplayInfoText := lang('_GRIDNODATA_');
  tvRes.OptionsView.NoDataToDisplayInfoText := lang('_GRIDNODATA_');
  COPY1.Caption := lang('_COPY_');
  COPY2.Caption := COPY1.Caption;
  AddFav1.Caption := lang('_FAVORITES_');
  RemFav1.Caption := lang('_REMOVEFROMFAVORITES_');
  TagList1.Caption := lang('_CREATETAGLIST_');
end;

procedure TfNewList.TagList1Click(Sender: TObject);
begin
  fTextEdit.mText.Lines.BeginUpdate;
  try
    fTextEdit.mText.Lines.Assign(fCurrItem.KeywordList);
  finally
    fTextEdit.mText.Lines.EndUpdate;
  end;
  if fTextEdit.Execute then
  begin
    fCurrItem.KeywordList.Assign(fTextEdit.mText.Lines);
    if fCurrItem.KeywordList.Count > 0 then
    begin
      (vgSettings.RowByName('vgitag') as TcxEditorRow)
        .Properties.RepositoryItem.Properties.ReadOnly := True;
      // (vgSettings.RowByName('vgitag') as TcxEditorRow).inProperties.Values[0] := '<list>';
      // (vgSettings.RowByName('vgitag') as TcxEditorRow).Properties.
      // vgSettings.InplaceEditor.RepositoryItem
      // vgSettings.InplaceEditor.RepositoryItem.Properties.ReadOnly := true;
      vgSettings.InplaceEditor.EditValue := '<list>';
      vgSettings.InplaceEditor.PostEditValue;
      vgSettings.InplaceEditor.InternalProperties.ReadOnly := True;
    end
    else
    begin
      (vgSettings.RowByName('vgitag') as TcxEditorRow)
        .Properties.RepositoryItem.Properties.ReadOnly := false;
      vgSettings.InplaceEditor.InternalProperties.ReadOnly := false;
      vgSettings.InplaceEditor.EditValue := '';
      vgSettings.InplaceEditor.PostEditValue;
      // (vgSettings.RowByName('vgitag') as TcxEditorRow)
      // .Properties.Value := '';
      // (vgSettings.RowByName('vgitag') as TcxEditorRow).Properties.
    end;

    // (vgSettings.RowByName('vgitag') as TcxEditorRow)
    // .Properties.Value readonly := true;
    // (Sender as tcxbuttonedit).PostEditValue;
  end;
end;

procedure TfNewList.tsSettingsShow(Sender: TObject);
begin
  if tvRes.Controller.FocusedRow = nil then
    tvRes.Controller.FocusedRowIndex := 0;
  if tvRes.Controller.FocusedRow.Values[0] = 0 then
    CreateSettings(nil)
  else
    CreateSettings(Pointer(Integer(tvRes.Controller.FocusedRow.Values[0])));
end;

procedure TfNewList.tvFullcButtonGetProperties(Sender: TcxCustomGridTableItem;
  ARecord: TcxCustomGridRecord; var AProperties: TcxCustomEditProperties);
begin
  if Assigned(ARecord) and (ARecord.RecordIndex = -1) then
    AProperties := erLabel.Properties;
end;

procedure TfNewList.tvFullcButtonPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  AddItem(tvFull.DataController.FocusedRecordIndex);
end;

procedure TfNewList.tvFullcNameGetProperties(Sender: TcxCustomGridTableItem;
  ARecord: TcxCustomGridRecord; var AProperties: TcxCustomEditProperties);
begin
  if Assigned(ARecord) and (ARecord.RecordIndex = -1) then
    AProperties := erEdit.Properties;
end;

procedure TfNewList.tvFullDataControllerFilterChanged(Sender: TObject);
begin
  if FAutoAdd then
  begin
    tvFull.DataController.Filter.Clear;
    FAutoAdd := false;
  end;

end;

procedure TfNewList.tvFullEditValueChanged(Sender: TcxCustomGridTableView;
  AItem: TcxCustomGridTableItem);
begin
  if Sender.ViewData.RecordCount = 1 then
  begin
    AddItem(Sender.DataController.FocusedRecordIndex);
    FAutoAdd := True;
  end;
end;

procedure TfNewList.tvFullKeyPress(Sender: TObject; var Key: Char);
begin
  if IsTextChar(Key) then
  begin
    tvFull.Controller.FocusedRow := tvFull.ViewData.FilterRow;

    if tvFull.Controller.FocusedColumnIndex < 2 then
      tvFull.Controller.FocusedColumnIndex := 2;
    tvFull.ViewData.FilterRow.Focused := True;
    // tvFull.Controller.EditingController.ShowEdit;

    // (tvFull.Controller.EditingController.Edit as TcxTextEdit).SetFocus;
    // (tvFull.Controller.EditingController.Edit as TcxTextEdit).EditingText := Key;
    // TcxTextEdit(tvFull.Controller.EditingController.Edit).KeyPress(Key);
    // (tvFull.Controller.EditingController.Edit as TcxTextEdit)
    // .SelStart := 1;
    // tvFull.Controller.EndUpdate;
  end;
end;

procedure TfNewList.tvResFocusedRecordChanged(Sender: TcxCustomGridTableView;
  APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
  ANewItemRecordFocusingChanged: Boolean);
var
  i: Integer;
begin
  i := AFocusedRecord.Values[0];
  if pcMain.ActivePage = tsSettings then
    if i = 0 then
      CreateSettings(nil)
    else
      CreateSettings(Pointer(i))
end;

initialization

end.
