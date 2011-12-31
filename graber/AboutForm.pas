unit AboutForm;

interface

uses
  Windows, Messages, ShellAPI, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, jpeg, ExtCtrls, StdCtrls;

type
  TfmAbout = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Button1: TButton;
    Label8: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label7Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmAbout: TfmAbout;

implementation

uses Unit1;

{$R *.dfm}

procedure TfmAbout.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TfmAbout.FormCreate(Sender: TObject);
begin
  Label1.Caption := MainForm.Caption;
end;

procedure TfmAbout.Label7Click(Sender: TObject);
begin
  ShellExecute(Handle,nil,'http://code.google.com/p/nekopaw/',
  nil,nil,SW_SHOWNORMAL);
end;

end.
