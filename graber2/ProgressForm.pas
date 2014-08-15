unit ProgressForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxProgressBar;

type
  TfProgress = class(TForm)
    pBar: TcxProgressBar;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    fCloseCall: tNotifyEvent;
  public
    procedure SetPos(aPos, aMax: int64);
    procedure SetText(fText: String);
    property CloseCall: tNotifyEvent read fCloseCall write fCloseCall;
    { Public declarations }
  end;

//var
//  fProgress: TfProgress;

implementation

{$R *.dfm}

procedure TfProgress.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  ModalResult := mrCancel;
  CanClose :=  false;
  if assigned(fCloseCall) then
    fCloseCall(Sender);
end;

procedure TfProgress.FormCreate(Sender: TObject);
begin
  ModalResult := mrNone;
end;

procedure TfProgress.SetPos(aPos, aMax: int64);
begin
  PbAR.Properties.Max := aMax;
  pBaR.Position := aPos;
end;

procedure TfProgress.SetText(fText: String);
begin
  if fText = '' then
    pBar.Properties.ShowTextStyle := cxtsPercent
  else
  begin
    pBar.Properties.ShowTextStyle := cxtstext;
    pBar.Properties.Text := fText;
  end;
  Application.ProcessMessages;
end;

end.
