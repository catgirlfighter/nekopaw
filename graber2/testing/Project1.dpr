program Project1;

uses
  Forms,
  unit_win7taskbar in 'unit_win7taskbar.pas',
  common in '..\common.pas',
  MyIDURI in '..\MyIdURI.pas',
  MyHTTP in '..\MyHTTP.pas',
  IdHTTP in '..\IdHTTP.pas' ,
  MyXMLParser in '..\MyXMLParser.pas',
  Unit1 in 'Unit1.pas' {FORM1};


{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
