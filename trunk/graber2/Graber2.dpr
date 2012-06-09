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
  MyDataSet in 'MyDataSet.pas',
  AboutForm in 'AboutForm.pas' {fmAbout},
  LoginForm in 'LoginForm.pas' {fLogin};

{$R *.res}

begin
  Application.Initialize;

  FormatSettings.DecimalSeparator := '.';

  Application.MainFormOnTaskbar := True;
  Application.Title := 'nekopaw grabber';

  //FullResList[0].NameFormat := GlobalSettings.Formats.PicFormat;
  //FullResList.PicFileFormat := GlobalSettings.Formats.PicFormat;

  Application.CreateForm(Tmf, mf);
  Application.CreateForm(Tdm, dm);
  Application.CreateForm(TfmAbout, fmAbout);
  //Application.CreateForm(TfLogin, fLogin);
  Application.Run;

end.
