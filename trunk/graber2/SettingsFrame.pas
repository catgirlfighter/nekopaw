unit SettingsFrame;

interface

uses
  {std}
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, INIFiles, ShellAPI, ImgList, ExtCtrls, StrUtils,
  {devex}
  cxPCdxBarPopupMenu, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, cxControls, cxCustomData, cxStyles, cxTL, cxTextEdit,
  cxTLdxBarBuiltInMenu, cxContainer, cxEdit, cxEditRepositoryItems, cxVGrid,
  cxSpinEdit, cxCheckBox, cxMaskEdit, cxDropDownEdit, cxLabel, cxPC, cxSplitter,
  cxInplaceContainer, StdCtrls, cxButtons, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, cxFilter, cxData, cxDataStorage, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxClasses, cxGridLevel, cxGrid,
  dxSkinsdxBarPainter, dxBar,
  {Graber}
  cxmymultirow, MyHTTP, Common, GraberU;
{
  dxSkinsdxBarPainter, dxBar, dxSkinBlack, dxSkinBlue,
  dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy,
  dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinPumpkin, dxSkinSeven,
  dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver,
  dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld,
  dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;
}

type
  TfSettings = class(TFrame)
    pButtons: TPanel;
    btnOk: TcxButton;
    btnCancel: TcxButton;
    tlList: TcxTreeList;
    cxSplitter1: TcxSplitter;
    tlcCaption: TcxTreeListColumn;
    pcMain: TcxPageControl;
    cxTabSheet2: TcxTabSheet;
    eThreads: TcxSpinEdit;
    chbUseThreadPerRes: TcxCheckBox;
    eThreadPerRes: TcxSpinEdit;
    ePicThreads: TcxSpinEdit;
    eRetries: TcxSpinEdit;
    lcThreads: TcxLabel;
    lcThreadPerRes: TcxLabel;
    lcPicThreads: TcxLabel;
    lcRetries: TcxLabel;
    cxTabSheet3: TcxTabSheet;
    chbProxy: TcxCheckBox;
    chbProxyAuth: TcxCheckBox;
    eHost: TcxTextEdit;
    eProxyLogin: TcxTextEdit;
    ePort: TcxSpinEdit;
    eProxyPassword: TcxTextEdit;
    chbProxySavePWD: TcxCheckBox;
    lcProxyHost: TcxLabel;
    lcProxyPort: TcxLabel;
    lcProxyLogin: TcxLabel;
    lcProxyPassword: TcxLabel;
    cxTabSheet4: TcxTabSheet;
    cxTabSheet1: TcxTabSheet;
    vgSettings: TcxVerticalGrid;
    lcLanguage: TcxLabel;
    cbLanguage: TcxComboBox;
    chbAutoUpdate: TcxCheckBox;
    lCheckNow: TcxLabel;
    cxEditRepository: TcxEditRepository;
    eAuthButton: TcxEditRepositoryButtonItem;
    cxTabSheet6: TcxTabSheet;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    btnApply: TcxButton;
    chbShowWhatsNew: TcxCheckBox;
    lSkin: TcxLabel;
    cbSkin: TcxComboBox;
    chbUseLookAndFeel: TcxCheckBox;
    cxTabSheet5: TcxTabSheet;
    gDoublesLevel1: TcxGridLevel;
    gDoubles: TcxGrid;
    tvDoubles: TcxGridTableView;
    cDoublesRuleName: TcxGridColumn;
    cDoublesRules: TcxGridColumn;
    eMemo: TcxEditRepositoryMemoItem;
    BarManager: TdxBarManager;
    DoublesActions: TdxBar;
    bcDoubles: TdxBarDockControl;
    bbNewRule: TdxBarButton;
    bbEditRule: TdxBarButton;
    bbDeleteRule: TdxBarButton;
    il: TcxImageList;
    chbMenuCaptions: TcxCheckBox;
    lHelp: TcxLabel;
    lcSpeed: TcxLabel;
    eSpeed: TcxSpinEdit;
    cxLabel6: TcxLabel;
    chbTips: TcxCheckBox;
    procedure btnOkClick(Sender: TObject);
    procedure chbProxyPropertiesEditValueChanged(Sender: TObject);
    procedure chbProxyAuthPropertiesEditValueChanged(Sender: TObject);
    procedure tlListFocusedNodeChanged(Sender: TcxCustomTreeList;
      APrevFocusedNode, AFocusedNode: TcxTreeListNode);
    procedure lCheckNowClick(Sender: TObject);
    procedure cxeAuthButtonPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cxLabel5Click(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure bbDeleteRuleClick(Sender: TObject);
    procedure bbNewRuleClick(Sender: TObject);
    procedure bbEditRuleClick(Sender: TObject);
    procedure lHelpClick(Sender: TObject);
  private
    FIgnList: TDSArray;
    FLangList: TStringList;
    FOnError: TLogEvent;
    function ResetRelogin(idx: integer): boolean;
    procedure CreateResFields(n: Integer);
    procedure SaveResFields;
    procedure LoginCallBack(Sender: TObject; N: integer; Login,Password: String;
      const Cancel: boolean);
    { Private declarations }
  public
    procedure ResetButons;
    procedure SetLang;
    procedure GetLanguages;
    procedure LoadSettings;
    procedure ApplySettings;
    procedure OnClose;
    procedure CreateResources;
    procedure OnErrorEvent(Sender: TObject; Msg: String);
    procedure JobStatus(Sander: TObject; Action: integer);
    procedure LoadDoubles;
    function CheckDoublesName(rulename: string): boolean;
    property OnError: TLogEvent read FOnError write FOnError;
    { Public declarations }
  end;

const
  def_items = 3;

implementation

uses UpdUnit, LangString, OpBase, utils, LoginForm, NewDoublesRuleForm;

{$R *.dfm}

var
  FLogedOn: boolean = false;
//  FLoginCanceled: boolean = false;

procedure TfSettings.ApplySettings;
begin
  if pcMain.ActivePageIndex = 3 then
    SaveResFields;

  FillDSArray(FIgnList,IgnoreList);

  with GlobalSettings do
  begin
    AutoUPD := chbAutoupdate.Checked;
    ShowWhatsNew := chbShowWhatsNew.Checked;

    Proxy.UseProxy := chbProxy.Checked;
    Proxy.Host := eHost.Text;
    Proxy.Port := ePort.Value;
    Proxy.Auth := chbProxyAuth.Checked;
    Proxy.Login := eProxyLogin.Text;
    Proxy.Password := eProxyPassword.Text;
    Proxy.SavePWD := chbProxySavePWD.Checked;

    Downl.ThreadCount := eThreads.Value;
    Downl.Retries := eRetries.Value;
    //Downl.Debug := chbDebug.Checked;

    Downl.UsePerRes := chbUseThreadPerRes.Checked;
    Downl.PerResThreads := eThreadPerRes.EditValue;
    Downl.PicThreads := ePicThreads.EditValue;

    idThrottler.BitsPerSec := eSpeed.Value * 8 * 1024;

    if (UseLookAndFeel <> chbUseLookAndFeel.Checked)
    or (SkinName <> cbSkin.Text) then
    begin
      UseLookAndFeel := chbUseLookAndFeel.Checked;
      if cbSkin.ItemIndex > 0 then
        SkinName := cbSkin.Text
      else
        SkinName := '';
      PostMessage(Application.MainForm.Handle,CM_STYLECHANGED,0,0);
    end;

    if MenuCaptions <> chbMenuCaptions.Checked then
    begin
      MenuCaptions := chbMenuCaptions.Checked;
      PostMessage(Application.MainForm.Handle,CM_MENUSTYLECHANGED,0,0);
    end;

    Tips := chbTips.Checked;

  end;

  if (cbLanguage.ItemIndex > -1)
  and not SameText(FLangList[cbLanguage.ItemIndex],langname) then
  begin
    langname := FLangList[cbLanguage.ItemIndex];
    PostMessage(Application.MainForm.Handle, CM_LANGUAGECHANGED,
      0, 0);
  end;

end;

procedure TfSettings.bbDeleteRuleClick(Sender: TObject);
var
  n: integer;
begin
  if tvDoubles.DataController.FocusedRecordIndex > -1 then
    if MessageDlg(lang('_DELETE_CONFIRM_'),mtConfirmation,[mbYes,mbNo],0) = mrYes then
    begin
      n := tvDoubles.DataController.FocusedRecordIndex;
      DeleteDSArrayRec(FIgnList,n);
      tvDoubles.DataController.DeleteRecord(n);
    end;
end;

procedure TfSettings.bbEditRuleClick(Sender: TObject);
var
  n: integer;
  picfields: tstringlist;
begin
  picfields := tstringlist.Create;
  try
    FullResList.GetAllPictureFields(picfields);
    n := tvDoubles.DataController.FocusedRecordIndex;
    if (n > -1)
    and fmDoublesNewRule.Execute(
          FIgnList[n][0],FIgnList[n][1],picfields,CheckDoublesName) then
    begin
      //SetLength(FIgnlist,n);
      FIgnList[n][0] := fmDoublesNewRule.RuleName;
      FIgnList[n][1] := trim(fmDoublesNewRule.ValueString,';');
      tvDoubles.BeginUpdate;
      try
        //tvDoubles.DataController.RecordCount := n;
        tvDoubles.DataController.Values[n,cDoublesRuleName.index]
           := FIgnList[n][0];
        tvDoubles.DataController.Values[n,cDoublesRules.index]
           := ReplaceStr(FIgnList[n][1],';',#13#10);
      finally
        tvDoubles.EndUpdate;
      end;
    end;
  finally
    picfields.Free;
  end;
end;

procedure TfSettings.bbNewRuleClick(Sender: TObject);
var
  picfields: tstringlist;
  n: integer;
begin
  n := tvDoubles.DataController.RecordCount+1;
  picfields := tstringlist.Create;
  try
    FullResList.GetAllPictureFields(picfields);
    if fmDoublesNewRule.Execute(
      'rule'+IntToStr(n),'',picfields,CheckDoublesName) then
    begin
      SetLength(FIgnlist,n);
      FIgnList[n-1][0] := fmDoublesNewRule.RuleName;
      FIgnList[n-1][1] := trim(fmDoublesNewRule.ValueString,';');
      tvDoubles.BeginUpdate;
      try
        tvDoubles.DataController.RecordCount := n;
        tvDoubles.DataController.Values[n-1,cDoublesRuleName.index]
           := FIgnList[n-1][0];
        tvDoubles.DataController.Values[n-1,cDoublesRules.index]
           := ReplaceStr(FIgnList[n-1][1],';',#13#10);
      finally
        tvDoubles.EndUpdate;
      end;
      tvDoubles.DataController.FocusedRecordIndex := n-1;
    end;
  finally
    picfields.free;
  end;
end;

procedure TfSettings.btnApplyClick(Sender: TObject);
begin
  ApplySettings;
  SaveProfileSettings;
end;

procedure TfSettings.btnCancelClick(Sender: TObject);
begin
  PostMessage(Application.MainForm.Handle, CM_CANCELSETTINGS,
    Integer(Self.Parent), 0);
end;

procedure TfSettings.btnOkClick(Sender: TObject);
begin
  ApplySettings;
  PostMessage(Application.MainForm.Handle, CM_APPLYSETTINGS,
    Integer(Self.Parent), 0);
end;

procedure TfSettings.chbProxyAuthPropertiesEditValueChanged(Sender: TObject);
begin
  eProxyLogin.Enabled := chbProxyAuth.Enabled and chbProxyAuth.Checked;
  eProxyPassword.Enabled := eProxyLogin.Enabled;
  chbProxySavePWD.Enabled := eProxyLogin.Enabled;
end;

procedure TfSettings.chbProxyPropertiesEditValueChanged(Sender: TObject);
begin
  eHost.Enabled := chbProxy.Checked;
  ePort.Enabled := chbProxy.Checked;
  chbProxyAuth.Enabled := chbProxy.Checked;
  eProxyLogin.Enabled := chbProxyAuth.Enabled and chbProxyAuth.Checked;
  eProxyPassword.Enabled := eProxyLogin.Enabled;
  chbProxySavePWD.Enabled := eProxyLogin.Enabled;
end;

procedure TfSettings.CreateResources;
var
  i,idx: integer;
  item: tcxTreeListNode;
  bmp: tbitmap;
begin
  bmp := TBitmap.Create;
  for i := 1 to FulLResList.Count -1 do
  begin
    item := tlList.Items[3].AddChild;
    item.Values[0] := FullResList[i].Name;
    if FullResList[i].IconFile <> '' then
      bmp.LoadFromFile(rootdir + '\resources\icons\' + FullResList[i].IconFile);
    idx := il.Add(bmp,nil);
    item.ImageIndex := idx;
  end;
end;

procedure TfSettings.cxeAuthButtonPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var
  n: integer;
begin
  n := tlList.FocusedNode.Index + 1;
  Application.CreateForm(TfLogin, fLogin);
  fLogin.Execute(n,
    Format(lang('_LOGINON_'),[FullResList[n].Name]),
    nullstr(FullResList[n].Fields['login']),
    nullstr(FullResList[n].Fields['password']),
    LoginCallback);
end;

procedure TfSettings.cxLabel5Click(Sender: TObject);
begin
  ShellExecute(Handle,nil,'http://code.google.com/p/nekopaw/',
    nil,nil,SW_SHOWNORMAL);
end;

procedure TfSettings.GetLanguages;
var
  ini: TINIFile;
  fs: TSearchRec;
  path: string;
begin
  FLangList := TStringList.Create;
  path := IncludeTrailingPathDelimiter(ExtractFilePath(paramstr(0))+'languages');
  if FindFirst(path + '*.ini',faAnyFile,fs) = 0 then
    repeat
      FLangList.Add(ChangeFileExt(fs.Name,''));
      INI := TINIFile.Create(path + fs.Name);
      cblanguage.Properties.Items.Add(INI.ReadString('lang','_FILELANGUAGE_',
        ChangeFileExt(fs.Name,'')));
      INI.Free;
      if SameText(ChangeFileExt(fs.Name,''),langname) then
        cbLanguage.ItemIndex := cbLanguage.Properties.Items.Count - 1;
    until FindNext(fs) <> 0;
end;

procedure TfSettings.lCheckNowClick(Sender: TObject);
begin
  PostMessage(Application.MainForm.Handle, CM_UPDATE,
    0, 0);
end;

procedure TfSettings.lHelpClick(Sender: TObject);
begin
  ShellExecute(Handle,nil,'http://code.google.com/p/nekopaw/wiki/NekopawGUI',
    nil,nil,SW_SHOWNORMAL);
end;

procedure TfSettings.LoadDoubles;
var
  i: integer;
begin
  tvDoubles.BeginUpdate;
  try
    tvDoubles.DataController.RecordCount := length(FIgnList);
    for i := 0 to length(FIgnList)-1 do
    begin
      tvDoubles.DataController.Values[i,cDoublesRuleName.Index] :=
        FIgnList[i][0];
      tvDoubles.DataController.Values[i,cDoublesRules.Index] :=
        ReplaceStr(FIgnList[i][1],';',#13#10);
    end;
  finally
    tvDoubles.EndUpdate;
  end;
  if tvDoubles.DataController.RecordCount > 0 then
    tvDoubles.DataController.FocusedRowIndex := 0;
  BestFitWidths(tvDoubles);
end;

procedure TfSettings.LoadSettings;
{var
  resnames,skinnames: tstringlist;}
begin
  GetLanguages;
  FillDSArray(IgnoreList,FIgnList);
  LoadDoubles;
  with GlobalSettings do
  begin
    chbAutoupdate.Checked := AutoUPD;
    chbShowWhatsNew.Checked := ShowWhatsNew;
    chbUseLookAndFeel.Checked := UseLookAndFeel;
    if SkinName = '' then
      cbSkin.ItemIndex := 0
    else
      cbSkin.Text := SkinName;
    chbMenuCaptions.Checked := MenuCaptions;
    chbTips.Checked := Tips;
{    resnames := tstringlist.Create;
    skinnames := tstringlist.Create;
    try
      dxSkinsPopulateSkinResources(hInstance,resnames,skinnames);
      cbSkin.Properties.Items.Assign(skinnames);
    finally
      resnames.Free;
      skinnames.Free;
    end;  }
    chbProxy.Checked := Proxy.UseProxy;
    eHost.Text := Proxy.Host;
    ePort.Value := Proxy.Port;
    chbProxyAuth.Checked := Proxy.Auth;
    eProxyLogin.Text := Proxy.Login;
    eProxyPassword.Text := Proxy.Password;
    chbProxySavePWD.Checked := Proxy.SavePWD;

    eThreads.Value := Downl.ThreadCount;
    eRetries.Value := Downl.Retries;
    //chbDebug.Checked := Downl.Debug;

    chbUseThreadPerRes.Checked := Downl.UsePerRes;
    eThreadPerRes.EditValue := Downl.PerResThreads;
    ePicThreads.EditValue := Downl.PicThreads;
    eSpeed.Value := idThrottler.BitsPerSec / 1024 / 8;
  end;

end;

procedure TfSettings.OnClose;
begin
  if Assigned(FLangList) then
    FLangList.Free;
  FullResList.OnError := nil;
  FullResList.OnJobChanged := nil;
end;

procedure TfSettings.ResetButons;
begin
  eHost.Enabled := chbProxy.Checked;
  ePort.Enabled := chbProxy.Checked;
  chbProxyAuth.Enabled := chbProxy.Checked;
  eProxyLogin.Enabled := chbProxyAuth.Enabled and chbProxyAuth.Checked;
  eProxyPassword.Enabled := eProxyLogin.Enabled;
  chbProxySavePWD.Enabled := eProxyLogin.Enabled;

  //chbHideToTray.Enabled := chbTrayIcon.Checked and chbTrayIcon.Enabled;
end;

procedure TfSettings.SetLang;
begin
//  gpWork.Caption := _WORK_;
  cxLabel1.Caption := 'About ' + Application.MainForm.Caption;
  btnOk.Caption := lang('_OK_');
  btnCancel.Caption := lang('_CANCEL_');
  btnApply.Caption := lang('_APPLY_');
  lcThreads.Caption := lang('_THREAD_COUNT_');
  chbUseThreadPerRes.Caption := lang('_USE_PER_RES_');
  lcThreadPerRes.Caption := lang('_PER_RES_');
  lcPicThreads.Caption := lang('_PIC_THREADS_');
  lcRetries.Caption := lang('_RETRIES_');
  lcProxyHost.Caption := lang('_HOST_');
  lcProxyPort.Caption := lang('_PORT_');
  lcProxyLogin.Caption := lang('_LOGIN_');
  lcProxyPassword.Caption := lang('_PASSWORD_');
  lcSpeed.Caption := lang('_SPEED_');
  lcLanguage.Caption := lang('_LANGUAGE_');
  tlList.Items[0].Texts[0] := lang('_INTERFACE_');
  tlList.Items[1].Texts[0] := lang('_THREADS_');
  tlList.Items[2].Texts[0] := lang('_PROXY_');
  tlList.Items[3].Texts[0] := lang('_RESOURCES_');
  tlList.Items[4].Texts[0] := lang('_DOUBLES_');
  tlList.Items[5].Texts[0] := lang('_ABOUT_');
  //chbDebug.Caption := _DEBUGMODE_;
//  gpProxy.Caption := _PROXY_;
  chbProxy.Caption := lang('_USE_PROXY_');
  chbProxyAuth.Caption := lang('_AUTHORISATION_');
  chbProxySavePwd.Caption := lang('_SAVE_PASSWORD_');
  chbAutoupdate.Caption := lang('_AUTOUPDATE_');
  lCheckNow.Caption := lang('_UPDATENOW_');
  chbShowWhatsNew.Caption := lang('_SHOW_WHATSNEW_');
  chbUseLookAndFeel.Caption := lang('_USELOOKANDFEEL_');
  lSkin.Caption := lang('_SKIN_');
  bbNewRule.Caption :=  lang('_CREATERULE_');
  bbEditRule.Caption :=  lang('_EDITRULE_');
  bbDeleteRule.Caption :=  lang('_DELETERULE_');
  cDoublesRuleName.Caption := lang('_RULENAME_');
  cDoublesRules.Caption := lang('_RULESTRING_');
  chbmenucaptions.Caption := lang('_MENUCAPTIONS_');
  chbTips.Caption := lang('_SHOWTIPS_');
  lHELP.Caption := lang('_HELP_');
end;

procedure TfSettings.tlListFocusedNodeChanged(Sender: TcxCustomTreeList;
  APrevFocusedNode, AFocusedNode: TcxTreeListNode);
begin
  if AFocusedNode.Parent = tlList.Root then
    pcMain.ActivePageIndex := AFocusedNode.Index
  else if AFocusedNode.Parent = tlList.Items[3] then
    pcMain.ActivePageIndex := 3;

  if Assigned(APrevFocusedNode)
  and((APrevFocusedNode = tlList.Items[3])
  or (APrevFocusedNode.Parent = tlList.Items[3])) then
    SaveResFields;

  if (AFocusedNode = tlList.Items[3]) then
    CreateResFields(0)
  else if (AFocusedNode.Parent = tlList.Items[3]) then
    CreateResFields(AFocusedNode.Index + 1);

end;

function TfSettings.CheckDoublesName(rulename: string): boolean;
var
  i: integer;
begin
  for i := 0 to length(FIgnList)-1 do
    if (i<>tvDoubles.DataController.FocusedRecordIndex)
    and SameText(rulename,FIgnList[i][0]) then
    begin
      Result := true;
      Exit;
    end;
  Result := false;
end;

procedure TfSettings.CreateResFields(n: Integer);
var
  c: TcxCategoryRow;
  r: TcxCustomRow;
  i, d: Integer;
  s: string;

begin
{
  if vgSettings.Rows.Count > 0 then
    SaveResFields;
}
  vgSettings.BeginUpdate;
  vgSettings.ClearRows;
  vgSettings.Tag := n;
  if n = 0 then
  begin
    c := dm.CreateCategory(vgSettings,'vgimain',lang('_MAINCONFIG_'));
    //dm.CreateField(vgSettings,'vgitag',_TAGSTRING_,'',ftString,c,FullResList[n].Fields['tag']);
    dm.CreateField(vgSettings,'vgidwpath',lang('_SAVEPATH_'),'',ftPathText,c,FullResList[n].NameFormat);
    dm.CreateField(vgSettings,'vgisdalf',lang('_SDALF_'),'',ftCheck,c,GlobalSettings.Downl.SDALF);
    dm.CreateField(vgSettings,'vgiautounch',lang('_AUTOUNCHECKINVISIBLE_'),'',ftCheck,c,GlobalSettings.Downl.AutoUncheckInvisible);
  end
  else
  with FullResList[n] do begin
    c := dm.CreateCategory(vgSettings,'vgimain',lang('_MAINCONFIG_') + ' ' +
      FullResList[n].Name);
    dm.CreateField(vgSettings,'vgiinherit',lang('_INHERIT_'),'',ftCheck,c,Inherit);

    {s := VarToStr(Fields['tag']);
    if (s = '') and Inherit then
      s := VarToStr(FullResList[0].Fields['tag']);
    dm.CreateField(vgSettings,'vgitag',_TAGSTRING_,'',ftString,c,s);  }

    s := NameFormat;
    if (s = '') or Inherit then
      s := FullResList[0].NameFormat;
    dm.CreateField(vgSettings,'vgidwpath',lang('_SAVEPATH_'),'',ftPathText,c,s);

{    c := dm.CreateCategory(vgSettings,'vgiauth',lang('_AUTHORISATION_'),true);
    dm.CreateField(vgSettings,'vgilogin',lang('_LOGIN_'),'',ftString,c,
      FullResLIst[n].Fields['login']);
    dm.CreateField(vgSettings,'vgipassword',lang('_PASSWORD_'),'',ftPassword,c,
      FullResLIst[n].Fields['password']);   }

    (dm.CreateField(vgSettings,'vgiauth',lang('_AUTHORISATION_'),'',ftString,c,'')
    as tcxEditorRow).Properties.RepositoryItem := eAuthButton;

    d := FullResList[0].Fields.Count;

    c := nil;
    r := nil;

    if FullResList[n].Fields.Count > d then
    begin
      if not Assigned(c) then
        c := dm.CreateCategory(vgSettings,'vgieditional',lang('_EDITIONALCONFIG_'));

      with FullResList[n].Fields do
        for i := d to Count - 1 do
          if Items[i].restype <> ftNone then
            with FullResList[n].Fields.Items[i]^ do
              if InMulti then
                dm.CreateField(vgSettings,'evgi' + resname,restitle,resitems,restype,r,resvalue)
              else
                r := dm.CreateField(vgSettings,'evgi' + resname,restitle,resitems,restype,c,resvalue);
    end;
  end;
  vgSettings.EndUpdate;
end;

procedure TfSettings.SaveResFields;
var
  i, n, d: Integer;
  r: tcxMyMultiEditorRow;

begin
  n := vgSettings.Tag;
  with FullResList[n] do
  begin
{    Fields['tag'] := (vgSettings.RowByName('vgitag') as TcxEditorRow)
      .Properties.Value;    }

    NameFormat := (vgSettings.RowByName('vgidwpath') as TcxEditorRow)
      .Properties.Value;

    if vgSettings.Tag = 0 then
    begin
      GlobalSettings.Downl.SDALF := (vgSettings.RowByName('vgisdalf') as TcxEditorRow)
        .Properties.Value;
      GlobalSettings.Downl.AutoUncheckInvisible :=
        (vgSettings.RowByName('vgiautounch') as TcxEditorRow).Properties.Value;
    end else if vgSettings.Tag > 0 then
    begin
      Inherit := (vgSettings.RowByName('vgiinherit') as TcxEditorRow)
        .Properties.Value;

{      Fields['login'] := (vgSettings.RowByName('vgilogin') as TcxEditorRow)
        .Properties.Value;

      Fields['password'] := (vgSettings.RowByName('vgipassword') as TcxEditorRow)
        .Properties.Value;   }

      d := FullResList[0].Fields.Count;
      r := nil;

      if Fields.Count > d then
        with Fields do
          for i := d to Count - 1 do
          if Items[i].restype <> ftNone then
          begin
            case Items[i].restype of
              ftMultiEdit:
                r := vgSettings.RowByName('evgi' + Items[i].resname) as tcxMyMultiEditorRow;
              ftIndexCombo:
                if Items[i].InMulti then
                  Items[i].resvalue := IndexOfStr(Items[i].resitems,r.Properties
                  .Editors[StrToInt(CopyFromTo(items[i].resname,'[',']',[],[]))-1].Value)
                else
                  Items[i].resvalue := IndexOfStr(Items[i].resitems,(vgSettings.RowByName('evgi' + Items[i].resname)
                    as TcxEditorRow).Properties.Value)
              else
                if Items[i].InMulti then
                  Items[i].resvalue := r.Properties
                  .Editors[StrToInt(CopyFromTo(items[i].resname,'[',']',[],[]))-1].Value
                else
                  Items[i].resvalue := (vgSettings.RowByName('evgi' + Items[i].resname)
                    as TcxEditorRow).Properties.Value;
            end;
          end;
    end;
  end;
end;

procedure TfSettings.LoginCallBack(Sender: TObject; N: integer; Login,Password: String;
    const Cancel: boolean);
begin
  if Cancel then
  begin
    FLogedOn := false;
    if not FullResList.ListFinished then
      FullResList.StartJob(JOB_STOPLIST)
    else
      fLogin.Close;
  end else
  begin
    FullResList[n].Fields['login'] := Login;
    FullResList[n].Fields['password'] := Password;
    if ResetRelogin(N) then
    begin
      FLogedOn := true;
      FullResLIst.StartJob(JOB_LOGIN);
    end else
      fLogin.Close;
  end;
end;

function TfSettings.ResetRelogin(idx: integer): boolean;
var
  i: integer;
  n: TResource;
begin
  Result := false;
  for i := 0 to FullResList.Count -1 do
    FullResList[i].Relogin := false;

  n := FullResList[idx{tvRes.DataController.Values[idx, 0]}];
  if(n.ScriptStrings.Login<>'')or(n.HTTPRec.CookieStr<>'')
  and(n.LoginPrompt or (nullstr(n.Fields['login'])<>''))then
  begin
    n.Relogin := true;
    Result := true;
  end;
end;

procedure TfSettings.OnErrorEvent(Sender: TObject; Msg: String);
begin
  if FLogedOn then
    FLogedOn := false;
  if Assigned(FOnError) then
    FOnError(Sender,Msg);
end;

procedure TfSettings.JobStatus(Sander: TObject; Action: integer);
begin
  if Action = JOB_STOPLIST then
    if Assigned(fLogin) then
      if FLogedOn or FullResList.Canceled then
        fLogin.Close
      else
        fLogin.bOk.Enabled := true;
end;

end.
