program Graber2;





{$R *.dres}

uses
  Forms,
  SysUtils,
  common in 'common.pas',
  MainForm in 'MainForm.pas' {mf},
  graberU in 'graberU.pas' {GraberU},
  StartFrame in 'StartFrame.pas' {fStart: TFrame},
  NewListFrame in 'NewListFrame.pas' {fNewList: TFrame},
  LangString in 'LangString.pas',
  OpBase in 'OpBase.pas',
  MyXMLParser in 'MyXMLParser.pas',
  SettingsFrame in 'SettingsFrame.pas' {fSettings: TFrame},
  GridFrame in 'GridFrame.pas' {fGrid: TFrame},
  MyHTTP in 'MyHTTP.pas',
  AES in 'AES.pas',
  ElAES in 'ElAES.pas',
  EncryptStrings in 'EncryptStrings.pas',
  utils in 'utils.pas' {dm: TDataModule},
  UPDUnit in 'UPDUnit.pas',
  LoginForm in 'LoginForm.pas' {fLogin},
  Whatsnewform in 'Whatsnewform.pas' {fWhatsNew},
  PathEditorForm in 'PathEditorForm.pas' {fPathEditor},
  NewDoublesRuleForm in 'NewDoublesRuleForm.pas' {fmDoublesNewRule},
  cxmymultirow in 'cxmymultirow.pas',
  win7taskbar in 'win7taskbar.pas',
  Balloon in 'Balloon.pas';

{$R *.res}

begin
  Application.Initialize;

  FormatSettings.DecimalSeparator := '.';

  //Application.MainFormOnTaskbar := True;
  Application.Title := 'nekopaw grabber';

  //FullResList[0].NameFormat := GlobalSettings.Formats.PicFormat;
  //FullResList.PicFileFormat := GlobalSettings.Formats.PicFormat;

  Application.CreateForm(Tmf, mf);
  Application.CreateForm(Tdm, dm);
  Application.CreateForm(TfmDoublesNewRule, fmDoublesNewRule);
  //Application.CreateForm(TfWhatsNew, fWhatsNew);
  //Application.CreateForm(TfPathEditor, fPathEditor);
  //Application.CreateForm(TfLogin, fLogin);
  Application.Run;

end.
