unit SettingsFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, Menus, StdCtrls,
  cxButtons, ExtCtrls, cxControls, cxContainer, cxEdit, dxLayoutcxEditAdapters,
  cxCheckBox, cxTextEdit, cxLabel, dxLayoutControl, cxGroupBox, cxMaskEdit,
  cxSpinEdit, dxGDIPlusClasses, cxImage, common;

type
  TfSettings = class(TFrame)
    pButtons: TPanel;
    btnOk: TcxButton;
    btnCancel: TcxButton;
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    gpProxy: TdxLayoutGroup;
    chbProxy: TcxCheckBox;
    lcProxy: TdxLayoutItem;
    eHost: TcxTextEdit;
    lcHost: TdxLayoutItem;
    ePort: TcxSpinEdit;
    lcPort: TdxLayoutItem;
    lcProxyAuth: TdxLayoutItem;
    chbProxyAuth: TcxCheckBox;
    eProxyLogin: TcxTextEdit;
    lcProxyLogin: TdxLayoutItem;
    dxLayoutControl1Group3: TdxLayoutGroup;
    dxLayoutControl1Group1: TdxLayoutGroup;
    eProxyPassword: TcxTextEdit;
    lcProxyPassword: TdxLayoutItem;
    chbProxySavePWD: TcxCheckBox;
    dxLayoutControl1Item4: TdxLayoutItem;
    gpWindow: TdxLayoutGroup;
    chbTrayIcon: TcxCheckBox;
    dxLayoutControl1Item5: TdxLayoutItem;
    chbHideToTray: TcxCheckBox;
    dxLayoutControl1Item6: TdxLayoutItem;
    chbOneInstance: TcxCheckBox;
    dxLayoutControl1Item7: TdxLayoutItem;
    chbSaveConfirm: TcxCheckBox;
    dxLayoutControl1Item8: TdxLayoutItem;
    gpWork: TdxLayoutGroup;
    eThreads: TcxSpinEdit;
    lcThreads: TdxLayoutItem;
    eRetries: TcxSpinEdit;
    lcRetries: TdxLayoutItem;
    chbDebug: TcxCheckBox;
    dxLayoutControl1Item9: TdxLayoutItem;
    dxLayoutControl1SpaceItem1: TdxLayoutEmptySpaceItem;
    cxImage1: TcxImage;
    dxLayoutControl1Item10: TdxLayoutItem;
    eThreadPerRes: TcxSpinEdit;
    lcThreadPerRes: TdxLayoutItem;
    dxLayoutControl1Item2: TdxLayoutItem;
    chbUseThreadPerRes: TcxCheckBox;
    lcPicThreads: TdxLayoutItem;
    ePicThreads: TcxSpinEdit;
    dxLayoutControl1Group4: TdxLayoutGroup;
    dxLayoutControl1Group2: TdxLayoutGroup;
    dxLayoutControl1Group5: TdxLayoutGroup;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure chbProxyPropertiesEditValueChanged(Sender: TObject);
    procedure chbProxyAuthPropertiesEditValueChanged(Sender: TObject);
    procedure chbTrayIconClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure ResetButons;
    procedure SetLang;
    { Public declarations }
  end;

implementation

uses GraberU, LangString;

{$R *.dfm}

procedure TfSettings.btnCancelClick(Sender: TObject);
begin
  PostMessage(Application.MainForm.Handle, CM_CANCELSETTINGS,
    Integer(Self.Parent), 0);
end;

procedure TfSettings.btnOkClick(Sender: TObject);
begin
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

procedure TfSettings.chbTrayIconClick(Sender: TObject);
begin
  chbHideToTray.Enabled := chbTrayIcon.Checked and chbTrayIcon.Enabled;
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

  chbHideToTray.Enabled := chbTrayIcon.Checked and chbTrayIcon.Enabled;
end;

procedure TfSettings.SetLang;
begin
  gpWork.Caption := _WORK_;
  lcThreads.Caption := _THREADS_;
  chbUseThreadPerRes.Caption := _USE_PER_RES_;
  lcThreadPerRes.Caption := _PER_RES_;
  lcPicThreads.Caption := _PIC_THREADS_;
  lcRetries.Caption := _RETRIES_;
  chbDebug.Caption := _DEBUGMODE_;
  gpProxy.Caption := _PROXY_;
  chbProxy.Caption := _USE_PROXY_;
  chbProxyAuth.Caption := _AUTHORISATION_;
  chbProxySavePwd.Caption := _SAVE_PASSWORD_;
end;

end.
