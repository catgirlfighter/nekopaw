unit SettingsFrame;

interface

uses
  {std}
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, INIFiles, ShellAPI, ImgList, ExtCtrls,
  {devex}
  cxPCdxBarPopupMenu, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, cxControls, cxCustomData, cxStyles, cxTL, cxTextEdit,
  cxTLdxBarBuiltInMenu, cxContainer, cxEdit, cxEditRepositoryItems, cxVGrid,
  cxSpinEdit, cxCheckBox, cxMaskEdit, cxDropDownEdit, cxLabel, cxPC, cxSplitter,
  cxInplaceContainer, StdCtrls, cxButtons,
  {Graber}
  Common, GraberU;

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
    cxTabSheet5: TcxTabSheet;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    btnApply: TcxButton;
    ilIcons: TcxImageList;
    chbShowWhatsNew: TcxCheckBox;
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
  private
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
    property OnError: TLogEvent read FOnError write FOnError;
    { Public declarations }
  end;

const
  def_items = 3;

implementation

uses UpdUnit, LangString, OpBase, utils, LoginForm;

{$R *.dfm}

var
  FLogedOn: boolean = false;
//  FLoginCanceled: boolean = false;

procedure TfSettings.ApplySettings;
begin
  if pcMain.ActivePageIndex = 3 then
    SaveResFields;

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
  end;

  if (cbLanguage.ItemIndex > -1)
  and not SameText(FLangList[cbLanguage.ItemIndex],langname) then
  begin
    langname := FLangList[cbLanguage.ItemIndex];
    PostMessage(Application.MainForm.Handle, CM_LANGUAGECHANGED,
      0, 0);
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
    idx := ilIcons.Add(bmp,nil);
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

procedure TfSettings.LoadSettings;
begin
  GetLanguages;

  with GlobalSettings do
  begin
    chbAutoupdate.Checked := AutoUPD;
    chbShowWhatsNew.Checked := ShowWhatsNew;

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
  lcLanguage.Caption := lang('_LANGUAGE_');
  tlList.Items[0].Texts[0] := lang('_INTERFACE_');
  tlList.Items[1].Texts[0] := lang('_THREADS_');
  tlList.Items[2].Texts[0] := lang('_PROXY_');
  tlList.Items[3].Texts[0] := lang('_RESOURCES_');
  tlList.Items[4].Texts[0] := lang('_ABOUT_');
  //chbDebug.Caption := _DEBUGMODE_;
//  gpProxy.Caption := _PROXY_;
  chbProxy.Caption := lang('_USE_PROXY_');
  chbProxyAuth.Caption := lang('_AUTHORISATION_');
  chbProxySavePwd.Caption := lang('_SAVE_PASSWORD_');
  chbAutoupdate.Caption := lang('_AUTOUPDATE_');
  lCheckNow.Caption := lang('_UPDATENOW_');
  chbShowWhatsNew.Caption := lang('_SHOW_WHATSNEW_');
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

procedure TfSettings.CreateResFields(n: Integer);
var
  c: TcxCategoryRow;
  //r: TcxEditorRow;
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

    dm.CreateField(vgSettings,'vgiauth',lang('_AUTHORISATION_'),'',ftString,c,'')
      .Properties.RepositoryItem := eAuthButton;

    d := FullResList[0].Fields.Count;

    c := nil;

    if FullResList[n].Fields.Count > d then
    begin
      with FullResList[n].Fields do
        for i := d to Count - 1 do
          if Items[i].restype <> ftNone then
          begin
            if not Assigned(c) then
              c := dm.CreateCategory(vgSettings,'vgieditional',lang('_EDITIONALCONFIG_'));
            with FullResList[n].Fields.Items[i]^ do
              dm.CreateField(vgSettings,'evgi' + resname,restitle,resitems,restype,c,resvalue);

               ///derp
          end;
    end;
  end;
  vgSettings.EndUpdate;
end;

procedure TfSettings.SaveResFields;
var
  i, n, d: Integer;
begin
  n := vgSettings.Tag;
  with FullResList[n] do
  begin
{    Fields['tag'] := (vgSettings.RowByName('vgitag') as TcxEditorRow)
      .Properties.Value;    }

    NameFormat := (vgSettings.RowByName('vgidwpath') as TcxEditorRow)
      .Properties.Value;

    if vgSettings.Tag = 0 then
      GlobalSettings.Downl.SDALF := (vgSettings.RowByName('vgisdalf') as TcxEditorRow)
        .Properties.Value
    else if vgSettings.Tag > 0 then
    begin
      Inherit := (vgSettings.RowByName('vgiinherit') as TcxEditorRow)
        .Properties.Value;

{      Fields['login'] := (vgSettings.RowByName('vgilogin') as TcxEditorRow)
        .Properties.Value;

      Fields['password'] := (vgSettings.RowByName('vgipassword') as TcxEditorRow)
        .Properties.Value;   }

      d := FullResList[0].Fields.Count;

      if Fields.Count > d then
        with Fields do
          for i := d to Count - 1 do
          if Items[i].restype <> ftNone then

          begin
            Items[i].resvalue := (vgSettings.RowByName('evgi' + Items[i].resname)
              as TcxEditorRow).Properties.Value;
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
  if(n.HTTPRec.CookieStr<>'')and(n.LoginPrompt or (nullstr(n.Fields['login'])<>''))then
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
