unit LoginForm;

interface

uses
  {std}
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls,
  {devex}
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, cxButtons, cxLabel, cxTextEdit, dxSkinsCore,
  dxSkinsDefaultPainters, cxImage, Vcl.ExtCtrls, Math;

type
  TLoginCallBack = procedure(Sender: TObject; N: integer;
    Login, Password, CAPTCHA: String; const Cancel: boolean) of object;

  TfLogin = class(TForm)
    eLogin: TcxTextEdit;
    lLogin: TcxLabel;
    ePassword: TcxTextEdit;
    lPassword: TcxLabel;
    bOk: TcxButton;
    bCancel: TcxButton;
    eCAPTCHA: TcxTextEdit;
    lCAPTCHA: TcxLabel;
    iCAPTCHA: TImage;
    procedure bOkClick(Sender: TObject);
    procedure bCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FN: integer;
  public
    procedure Execute(N: integer; ACaption, Login, Password: String;
      CAPTCHA: tStream; CallBack: TLoginCallBack);
    procedure SetLang;
    procedure resetCAPTCHA(CAPTCHA: tStream);
    property N: integer read FN;
    { Public declarations }
  end;

var
  fLogin: TfLogin = nil;

implementation

uses LangString, common;

{$R *.dfm}

var
  FCallBack: TLoginCallBack;

procedure TfLogin.bCancelClick(Sender: TObject);
begin
  FCallBack(Self, FN, eLogin.Text, ePassword.Text, eCAPTCHA.Text, true);
  // Close;
end;

procedure TfLogin.bOkClick(Sender: TObject);
begin
  FCallBack(Self, FN, eLogin.Text, ePassword.Text, eCAPTCHA.Text, false);
  bOk.Enabled := false;
end;

procedure TfLogin.Execute(N: integer; ACaption, Login, Password: String;
  CAPTCHA: tStream; CallBack: TLoginCallBack);
begin
  Caption := ACaption;
  eLogin.Text := Login;
  ePassword.Text := Password;
  FN := N;
  FCallBack := CallBack;

  resetCAPTCHA(CAPTCHA);

  ShowModal;
end;

procedure TfLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  fLogin := nil;
end;

procedure TfLogin.FormCreate(Sender: TObject);
begin
  SetLang;
end;

procedure TfLogin.resetCAPTCHA(CAPTCHA: tStream);
var
  buff: array [0 .. 10] of byte;
begin
  if Assigned(CAPTCHA) then
  begin
    CAPTCHA.Position := 0;
    CAPTCHA.Read(buff[0], 11);
    CAPTCHA.Position := 0;
    DrawImage(iCAPTCHA, CAPTCHA, ImageFormat(@buff[0]));
    lCAPTCHA.Top := iCAPTCHA.Top + iCAPTCHA.Height + 9;
    eCAPTCHA.Top := iCAPTCHA.Top + iCAPTCHA.Height + 8;
    ClientHeight := iCAPTCHA.Top + iCAPTCHA.Height + eCAPTCHA.Height  + bOk.Height + 8 * 3;
    ClientWidth := MAX(eLogin.Left + eLogin.Width + 8, iCAPTCHA.Width + 8 * 2);
    iCAPTCHA.Left := (ClientWidth - iCAPTCHA.Width) div 2;
    iCAPTCHA.Visible := true;
    lCAPTCHA.Visible := true;
    eCAPTCHA.Visible := true;
  end
  else
  begin
    iCAPTCHA.Visible := false;
    lCAPTCHA.Visible := false;
    eCAPTCHA.Visible := false;
    eCAPTCHA.Text := '';
    ClientHeight := eLogin.Height * 2 + bOk.Height + 8 * 4;
    ClientWidth := eLogin.Left + eLogin.Width + 8;
  end;
end;

procedure TfLogin.SetLang;
begin
  lLogin.Caption := lang('_LOGIN_');
  lPassword.Caption := lang('_PASSWORD_');
  bOk.Caption := lang('_OK_');
  bCancel.Caption := lang('_CANCEL_');
end;

end.
