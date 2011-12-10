unit Unit5;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SpTBXControls, StdCtrls, SpTBXEditors, SpTBXItem;

type
  TfmLogin = class(TForm)
    lLogin: TSpTBXLabel;
    eLogin: TSpTBXEdit;
    lPassword: TSpTBXLabel;
    ePassword: TSpTBXEdit;
    Ok: TSpTBXButton;
    Cancel: TSpTBXButton;
    chbSavePwd: TSpTBXCheckBox;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmLogin: TfmLogin;

implementation

{$R *.dfm}

procedure TfmLogin.FormShow(Sender: TObject);
begin
  if eLogin.Text = '' then
    eLogin.SetFocus
  else
    ePassword.SetFocus;
end;

end.
