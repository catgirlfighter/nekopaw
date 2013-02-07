program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' , {FORM1}
  unit_win7taskbar in 'unit_win7taskbar.pas',
  common in '..\common.pas',
  MyHTTP in '..\MyHTTP.pas',
  IdHTTP in '..\IdHTTP.pas' ;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
