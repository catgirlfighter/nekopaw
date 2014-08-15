program NPUpdater;

uses
  Forms,
  MainForm in 'MainForm.pas' {mf},
  UPDUnit in '..\UPDUnit.pas',
  MyHTTP in '..\MyHTTP.pas',
  Common in '..\common.pas',
  LangString in '..\LangString.pas',
  IdHTTP in '..\IdHTTP.pas',
  MyXMLParser in '..\MyXMLParser.pas',
  ZIP in '..\ZIP.pas',
  pac in '..\pac.pas';
{  GraberU in '..\GraberU.pas',
  md5 in '..\md5.pas'; }

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tmf, mf);
  Application.Run;
end.
