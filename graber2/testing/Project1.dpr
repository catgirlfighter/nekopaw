program Project1;

uses
  Forms,
  GraberU in '..\GraberU.pas',
  MyXMLParser in '..\MyXMLParser.pas',
  IdHTTP in '..\IdHTTP.pas',
  MyHTTP in '..\MyHTTP.pas',
  common in '..\common.pas',
  Unit1 in 'Unit1.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
