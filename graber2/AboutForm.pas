unit AboutForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, cxLabel, ShellAPI;

type
  TfmAbout = class(TForm)
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    procedure FormCreate(Sender: TObject);
    procedure cxLabel5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmAbout: TfmAbout;

implementation

{$R *.dfm}

procedure TfmAbout.cxLabel5Click(Sender: TObject);
begin
  ShellExecute(Handle,nil,'http://code.google.com/p/nekopaw/',
  nil,nil,SW_SHOWNORMAL);
end;

procedure TfmAbout.FormCreate(Sender: TObject);
begin
  Caption := 'About ' + Application.MainForm.Caption;
  cxLabel1.Caption := Application.MainForm.Caption;
end;

end.
