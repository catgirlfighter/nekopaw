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
    fbtntext: string;
    fticks: integer;
    fautoclose: boolean;
    { Private declarations }
  public
    procedure Execute(acaption,atext,btntext: string; shi,ticks: integer;
      autoclose: boolean = false; modal: boolean = false);
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

procedure TfStoping.Execute(acaption,atext,btntext: string; shi,ticks: integer;
  autoclose: boolean = false; modal: boolean = false);
begin
  caption := acaption;
  lbl.Caption := atext;
  fbtntext := btntext;
  Button.Enabled := false;
  fticks := ticks;
  fautoclose := autoclose;
  Button.Caption := fbtntext + '('+ IntToStr(fticks)+')';
  if modal then
  begin
    n := fticks;
    Timer.Interval := 1000;
    Timer.Enabled := true;
    ShowModal;
  end else
  begin
    Timer.Interval := shi;
    Timer.Enabled := true;
  end;
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
      Button.Caption := fbtntext + '('+ IntToStr(n)+')';
      dec(n);
    end else
    begin
      if fautoclose then
        Close
      else
        Button.Caption := trim(fbtntext);
      Timer.Enabled := false;
    end;
  end else
  begin
    Timer.Interval := 1000;
    n := fticks;
    Show;
  end;
end;

end.
