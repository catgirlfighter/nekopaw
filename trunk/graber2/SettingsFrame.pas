unit SettingsFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxDropDownEdit, cxCustomData, cxStyles, cxTL, cxTLdxBarBuiltInMenu,
  cxInplaceContainer, cxMaskEdit, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, Menus, cxControls, cxTextEdit, cxContainer, cxEdit,
  cxVGrid, cxLabel, cxCheckBox, cxSpinEdit, cxPC, cxSplitter, StdCtrls,
  cxButtons, ExtCtrls, INIFiles;

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
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure chbProxyPropertiesEditValueChanged(Sender: TObject);
    procedure chbProxyAuthPropertiesEditValueChanged(Sender: TObject);
    procedure tlListFocusedNodeChanged(Sender: TcxCustomTreeList;
      APrevFocusedNode, AFocusedNode: TcxTreeListNode);
  private
    FLangList: TStringList;
    procedure CreateResFields(n: Integer);
    procedure SaveResFields;
    { Private declarations }
  public
    procedure ResetButons;
    procedure SetLang;
    procedure GetLanguages;
    procedure LoadSettings;
    procedure ApplySettings;
    procedure OnClose;
    procedure CreateResources;
    { Public declarations }
  end;

const
  def_items = 3;

implementation

uses GraberU, LangString, OpBase, utils;

{$R *.dfm}

procedure TfSettings.ApplySettings;
begin
  if pcMain.ActivePageIndex = 3 then
    SaveResFields;

  with GlobalSettings do
  begin
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
  i: integer;
  item: tcxTreeListNode;
begin
  for i := 1 to FulLResList.Count -1 do
  begin
    item := tlList.Items[3].AddChild;
    item.Values[0] := FullResList[i].Name;
  end;
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

procedure TfSettings.LoadSettings;
begin
  GetLanguages;

  with GlobalSettings do
  begin
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
end;

procedure TfSettings.ResetButons;
begin
  btnOk.Caption := _OK_;
  btnCancel.Caption := _CANCEL_;
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
  lcThreads.Caption := _THREAD_COUNT_;
  chbUseThreadPerRes.Caption := _USE_PER_RES_;
  lcThreadPerRes.Caption := _PER_RES_;
  lcPicThreads.Caption := _PIC_THREADS_;
  lcRetries.Caption := _RETRIES_;
  lcProxyHost.Caption := _HOST_;
  lcProxyPort.Caption := _PORT_;
  lcProxyLogin.Caption := _LOGIN_;
  lcProxyPassword.Caption := _PASSWORD_;
  lcLanguage.Caption := _LANGUAGE_;
  tlList.Items[0].Texts[0] := _INTERFACE_;
  tlList.Items[1].Texts[0] := _THREADS_;
  tlList.Items[2].Texts[0] := _PROXY_;
  tlList.Items[3].Texts[0] := _RESOURCES_;
  //chbDebug.Caption := _DEBUGMODE_;
//  gpProxy.Caption := _PROXY_;
  chbProxy.Caption := _USE_PROXY_;
  chbProxyAuth.Caption := _AUTHORISATION_;
  chbProxySavePwd.Caption := _SAVE_PASSWORD_;
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
    c := dm.CreateCategory(vgSettings,'vgimain',_MAINCONFIG_);
    //dm.CreateField(vgSettings,'vgitag',_TAGSTRING_,'',ftString,c,FullResList[n].Fields['tag']);
    dm.CreateField(vgSettings,'vgidwpath',_SAVEPATH_,'',ftString,c,FullResList[n].NameFormat);
  end
  else
  with FullResList[n] do begin
    c := dm.CreateCategory(vgSettings,'vgimain',_MAINCONFIG_ + ' ' +
      FullResList[n].Name);
    dm.CreateField(vgSettings,'vgiinherit',_INHERIT_,'',ftCheck,c,Inherit);

    {s := VarToStr(Fields['tag']);
    if (s = '') and Inherit then
      s := VarToStr(FullResList[0].Fields['tag']);
    dm.CreateField(vgSettings,'vgitag',_TAGSTRING_,'',ftString,c,s);  }

    s := NameFormat;
    if (s = '') and Inherit then
      s := FullResList[0].NameFormat;
    dm.CreateField(vgSettings,'vgidwpath',_SAVEPATH_,'',ftString,c,s);

    c := dm.CreateCategory(vgSettings,'vgiauth',_AUTHORISATION_,true);
    dm.CreateField(vgSettings,'vgilogin',_LOGIN_,'',ftString,c,
      FullResLIst[n].Fields['login']);
    dm.CreateField(vgSettings,'vgipassword',_PASSWORD_,'',ftPassword,c,
      FullResLIst[n].Fields['password']);

    d := FullResList[0].Fields.Count;

    c := nil;

    if FullResList[n].Fields.Count > d then
    begin
      with FullResList[n].Fields do
        for i := d to Count - 1 do
          if Items[i].restype <> ftNone then
          begin
            if not Assigned(c) then
              c := dm.CreateCategory(vgSettings,'vgieditional',_EDITIONALCONFIG_);
            with FullResList[n].Fields.Items[i]^ do
              dm.CreateField(vgSettings,'evgi' + resname,resname,resitems,restype,c,resvalue);

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

    if vgSettings.Tag > 0 then
    begin
      Inherit := (vgSettings.RowByName('vgiinherit') as TcxEditorRow)
        .Properties.Value;

      Fields['login'] := (vgSettings.RowByName('vgilogin') as TcxEditorRow)
        .Properties.Value;

      Fields['password'] := (vgSettings.RowByName('vgipassword') as TcxEditorRow)
        .Properties.Value;

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

end.
