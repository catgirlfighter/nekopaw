program Graber2;

uses
  Forms,
  MainFormU in 'MainFormU.pas' {mf},
  graberU in 'graberU.pas' {graber comps},
  StartFrame in 'StartFrame.pas' {fStart: TFrame},
  NewListForm in 'NewListForm.pas' {fGetList},
  Settings in 'Settings.pas' {fmSettings};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'nekopaw grabber';
  Application.CreateForm(Tmf, mf);
  Application.CreateForm(TfGetList, fGetList);
  Application.CreateForm(TfmSettings, fmSettings);
  Application.Run;
end.
