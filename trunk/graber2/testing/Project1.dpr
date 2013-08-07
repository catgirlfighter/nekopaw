program Project1;

uses
  FastMM4,
  Forms,
  unit_win7taskbar in 'unit_win7taskbar.pas',
  common in '..\common.pas',
  MyIDURI in '..\MyIdURI.pas',
  MyHTTP in '..\MyHTTP.pas',
  IdHTTP in '..\IdHTTP.pas' ,
  MyXMLParser in '..\MyXMLParser.pas',
  Unit1 in 'Unit1.pas' {FORM1},
  GraberU in '..\GraberU.pas',
  MD5 in '..\MD5.pas',
  CCR.EXIF in '..\CCR.EXIF.pas',
  CCR.EXIF.BaseUtils in '..\CCR.EXIF.BaseUtils.pas';


{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
