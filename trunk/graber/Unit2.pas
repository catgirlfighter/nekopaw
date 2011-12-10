unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, ExtCtrls, ComCtrls;

type
  Tconnsets = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Button1: TButton;
    Button2: TButton;
    Panel1: TPanel;
    procedure cbproxyClick(Sender: TObject);
    procedure cbauthClick(Sender: TObject);
    procedure cbsaveproxypwdClick(Sender: TObject);
    procedure chbdownloadalbumsClick(Sender: TObject);
    procedure chbOpenDriveClick(Sender: TObject);
  private
    { Private declarations }
  public
    function Execute: boolean;
    procedure updateinterface;
    { Public declarations }
  end;

var
  connsets: Tconnsets;

implementation

uses Unit1;

{$R *.dfm}
var
  loading: boolean;

procedure Tconnsets.cbauthClick(Sender: TObject);
begin
 updateinterface;
end;

procedure Tconnsets.cbproxyClick(Sender: TObject);
begin
 updateinterface;
end;

procedure Tconnsets.cbsaveproxypwdClick(Sender: TObject);
begin
(Sender as TCheckBox).Checked := (Sender as TCheckBox).Checked
  and (loading or (MessageDlg('Password stored in not encrypted text form. Are you realy want to save password?',mtConfirmation,[mbYes,mbNo],0)=mrYes));
end;

procedure Tconnsets.chbdownloadalbumsClick(Sender: TObject);
begin
  updateinterface;
end;

procedure Tconnsets.chbOpenDriveClick(Sender: TObject);
begin
  updateinterface;
end;

function Tconnsets.Execute: boolean;
begin
  updateinterface;
  ShowModal;
  Result := ModalResult = mrOk;
end;

procedure Tconnsets.updateinterface;
begin

end;

end.
