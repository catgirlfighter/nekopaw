program Graber2;

uses
  Forms,
  common in 'common.pas',
  MainForm in 'MainForm.pas' {mf},
  graberU in 'graberU.pas' {graber comps},
  StartFrame in 'StartFrame.pas' {fStart: TFrame},
  NewListFrame in 'NewListFrame.pas' {fNewList: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'nekopaw grabber';
  Application.CreateForm(Tmf, mf);
  Application.Run;
end.
