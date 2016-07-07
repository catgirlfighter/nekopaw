program Graber2;

{$R *.dres}

uses
  Forms,
  SysUtils,
  myidhttp in 'myidhttp.pas',
  common in 'common.pas',
  pac in 'pac.pas',
  md5 in 'md5.pas',
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
  PathEditorForm in 'PathEditorForm.pas' {fPathEditor},
  NewDoublesRuleForm in 'NewDoublesRuleForm.pas' {fmDoublesNewRule},
  cxmymultirow in 'cxmymultirow.pas',
  win7taskbar in 'win7taskbar.pas',
  Balloon in 'Balloon.pas',
  MyINIFile in 'MyINIFile.pas',
  TextEditorForm in 'TextEditorForm.pas' {fTextEdit},
  Newsv2Form in 'Newsv2Form.pas' {fmNewsv2},
  ThreadUtils in 'ThreadUtils.pas',
  ProgressForm in 'ProgressForm.pas' {fProgress},
  SelectFieldsForm in 'SelectFieldsForm.pas' {fmSelectFields};

{$R *.res}

begin
  Application.Initialize;

  FormatSettings.DecimalSeparator := '.';

  // Application.MainFormOnTaskbar := True;
  Application.Title := 'nekopaw grabber';

  // FullResList[0].NameFormat := GlobalSettings.Formats.PicFormat;
  // FullResList.PicFileFormat := GlobalSettings.Formats.PicFormat;

  Application.CreateForm(Tmf, mf);
  Application.CreateForm(Tdm, dm);
  Application.CreateForm(TfmDoublesNewRule, fmDoublesNewRule);
  Application.CreateForm(TfTextEdit, fTextEdit);
  Application.CreateForm(TfmSelectFields, fmSelectFields);
  //Application.CreateForm(TfProgress, fProgress);
  // Application.CreateForm(TfmNewsv2, fmNewsv2);
  // Application.CreateForm(TfWhatsNew, fWhatsNew);
  // Application.CreateForm(TfPathEditor, fPathEditor);
  // Application.CreateForm(TfLogin, fLogin);
  Application.Run;

end.
