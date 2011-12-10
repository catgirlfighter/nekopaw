unit stoping_u;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfStoping = class(TForm)
    Lbl: TLabel;
    Button: TButton;
    Timer: TTimer;
    procedure TimerTimer(Sender: TObject);
    procedure ButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure Execute;
    procedure Stop;
    { Public declarations }
  end;

var
  fStoping: TfStoping;
  n: integer;

implementation

uses Unit1;

{$R *.dfm}

procedure TfStoping.ButtonClick(Sender: TObject);
begin
  MainForm.ForceStop;
  Close;
end;

procedure TfStoping.Execute;
begin
  Button.Enabled := false;
  Timer.Interval := 2000;
  TImer.Enabled := true;
end;

procedure TfStoping.Stop;
begin
  Timer.Enabled := false;
  Close;
end;

procedure TfStoping.TimerTimer(Sender: TObject);
begin
  if Visible then
  begin
    Button.Enabled := n = 0;
    if n > 0 then
    begin
      Button.Caption := 'Force ('+ IntToStr(n)+')';
      dec(n);
    end else
    begin
      Button.Caption := 'Force';
      Timer.Enabled := false;
    end;
  end else
  begin
    Timer.Interval := 1000;
    n := 5;
    Show;
  end;
end;

end.
