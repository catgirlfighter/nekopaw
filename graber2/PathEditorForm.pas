unit PathEditorForm;

interface

uses
  {std}
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StrUtils, ExtCtrls, ShellAPI, Menus, StdCtrls,
  {devex}
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, cxLabel, cxTextEdit, cxButtons,
  cxShellBrowserDialog,
  {graber}
  common;

type
  TfPathEditor = class(TForm)
    Panel1: TPanel;
    bOk: TcxButton;
    bCancel: TcxButton;
    ePath: TcxTextEdit;
    bBrowse: TcxButton;
    dPath: TcxShellBrowserDialog;
    bVariables: TcxButton;
    pmVariables: TPopupMenu;
    N1: TMenuItem;
    lex1: TcxLabel;
    lex2: TcxLabel;
    bFields: TcxButton;
    lex3: TcxLabel;
    lex4: TcxLabel;
    lwiki1: TcxLabel;
    lwiki2: TcxLabel;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    pmFields: TPopupMenu;
    lHelp: TcxLabel;
    procedure bBrowseClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure lHelpClick(Sender: TObject);
    procedure lwiki1Click(Sender: TObject);
    procedure lwiki2Click(Sender: TObject);

  private
    procedure VarClick(Sender: TObject);
    procedure FieldClick(Sender: TObject);
    { Private declarations }
  public
    procedure SetLang;
    procedure SetValue(s: string);
    { Public declarations }
  end;

var
  fPathEditor: TfPathEditor;

function ExecutePathEditor(Value: string; Vars,Fields: TStringList): string;

implementation

uses LangString;

var
  fvars,ffields: tstringlist;

{$R *.dfm}

function ExecutePathEditor(Value: string; Vars,Fields: TStringList): string;
var
  item: TMenuItem;
  i: integer;
begin
  Application.CreateForm(TfPathEditor,fPathEditor);
  with fPathEditor do
  begin
    SetLang;
    ePath.Text := Value;

    fvars := vars;
    if Assigned(vars) then
    begin
      item := TMenuItem.Create(pmVariables);
      item.Caption := '-';
      pmVariables.Items.Add(item);
      for i := 0 to vars.Count-1 do
      begin
        item := TMenuItem.Create(pmVariables);
        item.Tag := i;
        item.Caption := '$' + vars[i] + '$';
        item.OnClick := VarClick;
        pmVariables.Items.Add(item);
      end;
    end;

    ffields := fields;
    if Assigned(fields) then
    begin
      for i := 0 to fields.Count-1 do
      begin
        item := TMenuItem.Create(pmFields);
        item.Tag := i;
        item.Caption := '%' + fields[i] + '%';
        item.OnClick := FieldClick;
        pmFields.Items.Add(item);
      end;
    end;

    fPathEditor.SetFocusedControl(ePath);
    ePath.SelStart := Length(ePath.Text);

    ShowModal;
    if ModalResult = mrOk then
      Result := ePath.Text
    else
      Result := Value;
    Free;
  end;
end;

procedure TfPathEditor.bBrowseClick(Sender: TObject);

  function GetAcceptablePath(path: string): string;
  var
    tmp: string;
  begin
//    path := ExcludeTrailingPathDelimiter(path);
    tmp := '';
    while (path <> '') and (tmp <> path)
    and not DirectoryExists(path) do
    begin
      tmp := path;
      path := ExcludeTrailingPathDelimiter(ExtractFileDir(path));
    end;
    result := path;
  end;

var
  n: integer;
  s: string;

begin
  dPath.Path := GetAcceptablePath(ePath.Text);
  if dPath.Execute then
  begin
    s := ePath.Text;
    s := ExcludeTrailingPathDelimiter(DeleteTo(s,'$rootdir$',false));
    n := CharPosEx(s,['<','%','$'],[]);
    if n = 0 then
      ePath.Text := IncludeTrailingPathDelimiter(dPath.Path)
    else
    begin
      s := ReverseString(s);
      n := PosEx(PathDelim,s,length(s) - n);
      if n > 0 then
        s := Copy(s,1,n);

      ePath.Text := IncludeTrailingPathDelimiter(dPath.Path)
        + ReverseString(ExcludeTrailingPathDelimiter(s));
    end;
    ePath.SelStart := Length(ePath.Text);
    ePath.SetFocus;
  end;
end;

procedure TfPathEditor.N3Click(Sender: TObject);
begin
  SetValue('$ext$');
end;

procedure TfPathEditor.VarClick(Sender: TObject);
begin
  if assigned(fvars) then
    SetValue('$' + fvars[(sender as TComponent).Tag] + '$');
end;

procedure TfPathEditor.FieldClick(Sender: TObject);
begin
  if assigned(ffields) then
    SetValue('%' + ffields[(sender as TComponent).Tag] + '%');
end;

procedure TfPathEditor.lHelpClick(Sender: TObject);
begin
  ShellExecute(Handle,nil,
    'http://code.google.com/p/nekopaw/wiki/NekopawGUI#Форматирование_имени_файла',
    nil,nil,SW_SHOWNORMAL);
end;

procedure TfPathEditor.lwiki1Click(Sender: TObject);
begin
  ShellExecute(Handle,nil,
    'https://code.google.com/p/nekopaw/wiki/NekopawGUI#Формат_даты_и_времени',
    nil,nil,SW_SHOWNORMAL);
end;

procedure TfPathEditor.lwiki2Click(Sender: TObject);
begin
  ShellExecute(Handle,nil,
    'https://code.google.com/p/nekopaw/wiki/NekopawGUI#Строко-числовой_формат',
    nil,nil,SW_SHOWNORMAL);
end;

procedure TfPathEditor.N1Click(Sender: TObject);
begin
  SetValue('$fname$');
end;

procedure TfPathEditor.N2Click(Sender: TObject);
begin
  SetValue('$rname$');
end;

procedure TfPathEditor.N6Click(Sender: TObject);
var
  s: string;
begin
  s := DeleteTo(DeleteTo(ePath.Text,':\'),'$rootdir$',false);
  while (length(s) > 0) and (s[1] = PathDelim) do
    delete(s,1,1);
  ePath.Text := IncludeTrailingPathDelimiter('$rootdir$') + s;
  ePath.SetFocus;
end;

procedure TfPathEditor.SetLang;
begin
  Caption := lang('_NAMEFORMAT_EDITOR_');
  bOk.Caption := lang('_OK_');
  bCancel.Caption := lang('_CANCEL_');
  lHelp.Caption := lang('_HELP_');
  lex1.Caption := lang('_NAMEFORMAT_EX1_');
  lex2.Caption := lang('_NAMEFORMAT_EX2_');
  lex3.Caption := lang('_NAMEFORMAT_EX3_');
  lex4.Caption := lang('_NAMEFORMAT_EX4_');
  bVariables.Caption := lang('_NAMEFORMAT_VARIABLES_');
  bFields.Caption := lang('_NAMEFORMAT_FIELDS_');
  N1.Caption := '$fname$ - ' + lang('_HINT_FNAME_');
  N2.Caption := '$rname$ - ' + lang('_HINT_RNAME_');
  N3.Caption := '$ext$ - ' + lang('_HINT_EXT_');
  N4.Caption := '$short$ - ' + lang('_HINT_SHORT_');
  N5.Caption := '$tag$ - ' + lang('_HINT_TAG_');
  N6.Caption := '$rootdir$ - ' + lang('_HINT_ROOTDIR_');
end;

procedure TfPathEditor.SetValue(s: string);
begin
  ePath.SelText := s;
  ePath.SetFocus;
end;

procedure TfPathEditor.N4Click(Sender: TObject);
begin
  SetValue('$short$');
end;

procedure TfPathEditor.N5Click(Sender: TObject);
begin
  SetValue('$tag$');
end;

end.
