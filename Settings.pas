unit Settings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, dxSkinsCore, Menus, StdCtrls, cxButtons, cxLabel,
  cxMaskEdit, cxSpinEdit, cxCheckBox, cxTextEdit, cxGroupBox, dxGDIPlusClasses,
  ExtCtrls;

type
  TfmSettings = class(TForm)
    gbProxy: TcxGroupBox;
    chbHTTPProxy: TcxCheckBox;
    eProxyPort: TcxSpinEdit;
    chbProxyAuth: TcxCheckBox;
    gbWork: TcxGroupBox;
    eProxyHost: TcxTextEdit;
    eProxyLogin: TcxTextEdit;
    eProxyPwd: TcxTextEdit;
    lThreadCount: TcxLabel;
    eThreadCount: TcxSpinEdit;
    chbProxySavePwd: TcxCheckBox;
    lRetries: TcxLabel;
    eRetries: TcxSpinEdit;
    chbDebugMode: TcxCheckBox;
    cxGroupBox1: TcxGroupBox;
    chbTrayIcon: TcxCheckBox;
    chbHide: TcxCheckBox;
    chbKeepInstance: TcxCheckBox;
    chbSaveConfirm: TcxCheckBox;
    btnOk: TcxButton;
    btnCancel: TcxButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmSettings: TfmSettings;

implementation

{$R *.dfm}

end.
