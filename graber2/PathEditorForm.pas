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
  common, dxSkinsCore, dxSkinsDefaultPainters, cxMaskEdit, cxButtonEdit,
  cxListBox, cxDropDownEdit, cxMRUEdit;

type
  TfPathEditor = class(TForm)
    Panel1: TPanel;
    bOk: TcxButton;
    bCancel: TcxButton;
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
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    PopupMenu1: TPopupMenu;
    cbPath: TcxMRUEdit;
    N11: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
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
    procedure N9Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure ePathPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure N11Click(Sender: TObject);
    procedure N13Click(Sender: TObject);
    procedure N12Click(Sender: TObject);

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

function ExecutePathEditor(Value: string; Paths,Vars,Fields: TStrings): string;

implementation

uses LangString;

var
  fvars,ffields: tstrings;

{$R *.dfm}

function ExecutePathEditor(Value: string; Paths,Vars,Fields: TStrings): string;
var
  item: TMenuItem;
  i: integer;
  s,tmp: string;
begin
  Application.CreateForm(TfPathEditor,fPathEditor);
  with fPathEditor do
  begin
    SetLang;
    cbPath.Text := Value;
    cbPath.Properties.Items.Assign(Paths);

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
        s := fields[i];
        tmp := GetNextS(s,':');
        fields[i] := tmp;
        item.Caption := '%' + tmp + '%';
        tmp := GetNextS(s,':'); tmp := GetNextS(s,':');
        if tmp <> '' then
          if (tmp[1] = '$') then
            item.Caption := item.Caption + ' - '
              + lang('_' + Copy(tmp,2,length(tmp)-1) + '_')
          else
            item.Caption := item.Caption + ' - ' + tmp;
        item.OnClick := FieldClick;
        pmFields.Items.Add(item);
      end;
    end;

    fPathEditor.SetFocusedControl(cbPath);
    cbPath.SelStart := Length(cbPath.Text);

    ShowModal;
    if ModalResult = mrOk then
      Result := cbPath.Text
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
  dPath.Path := GetAcceptablePath(cbPath.Text);
  if dPath.Execute then
  begin
    s := cbPath.Text;
    s := ExcludeTrailingPathDelimiter(DeleteTo(s,'$rootdir$',false));
    n := CharPosEx(s,['<','%','$'],[],[]);
    if n = 0 then
      cbPath.Text := IncludeTrailingPathDelimiter(dPath.Path)
    else
    begin
      s := ReverseString(s);
      n := PosEx(PathDelim,s,length(s) - n);
      if n > 0 then
        s := Copy(s,1,n);

      cbPath.Text := IncludeTrailingPathDelimiter(dPath.Path)
        + ReverseString(ExcludeTrailingPathDelimiter(s));
    end;
    cbPath.SelStart := Length(cbPath.Text);
    cbPath.SetFocus;
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

procedure TfPathEditor.N12Click(Sender: TObject);
begin
  SetValue('$date$');
end;

procedure TfPathEditor.ePathPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  case AButtonIndex of
    //0: ePath.Properties.p\
    3: bBrowseClick(nil);
  end;
end;

procedure TfPathEditor.FieldClick(Sender: TObject);
begin
  if assigned(ffields) then
    SetValue('%' + ffields[(sender as TComponent).Tag] + '%');
end;

procedure TfPathEditor.lHelpClick(Sender: TObject);
begin
  ShellExecute(Handle,nil,
    'http://code.google.com/p/nekopaw/wiki/NekopawGUI#Name_formating',
    nil,nil,SW_SHOWNORMAL);
end;

procedure TfPathEditor.lwiki1Click(Sender: TObject);
begin
  ShellExecute(Handle,nil,
    'https://code.google.com/p/nekopaw/wiki/NekopawGUI#datetime_format',
    nil,nil,SW_SHOWNORMAL);
end;

procedure TfPathEditor.lwiki2Click(Sender: TObject);
begin
  ShellExecute(Handle,nil,
    'https://code.google.com/p/nekopaw/wiki/NekopawGUI#string-number_format',
    nil,nil,SW_SHOWNORMAL);
end;

procedure TfPathEditor.N11Click(Sender: TObject);
begin
  SetValue('$md5$');
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
  s := DeleteTo(DeleteTo(cbPath.Text,':\'),'$rootdir$',false);
  while (length(s) > 0) and (s[1] = PathDelim) do
    delete(s,1,1);
  cbPath.Text := IncludeTrailingPathDelimiter('$rootdir$') + s;
  cbPath.SetFocus;
end;

procedure TfPathEditor.N7Click(Sender: TObject);
begin
  SetValue('$nn$');
end;

procedure TfPathEditor.N8Click(Sender: TObject);
begin
  SetValue('$fn$');
end;

procedure TfPathEditor.N9Click(Sender: TObject);
begin
  SetValue('$fnn$');
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
  N7.Caption := '$nn$ - ' + lang('_HINT_NN_');
  N8.Caption := '$fn$ - ' + lang('_HINT_FN_');
  N9.Caption := '$fnn[(N)]$ - ' + lang('_HINT_FNN_');
  N10.Caption := '$tags[(N)]$ - ' + lang('_HINT_TAGS_');
  N11.Caption := '$md5$ - ' + lang('_HINT_MD5_');
  N12.Caption := '$date$ - ' + lang('_HINT_DATE_');
  N13.Caption := '$time$ - ' + lang('_HINT_TIME_');
end;

procedure TfPathEditor.SetValue(s: string);
///var
//  n: integer;
begin
  //n := cbPath.SelStart;
  cbPath.SelText := s;
  cbPath.SetFocus;
  //cbPath.SelLength := 0;
end;

procedure TfPathEditor.N13Click(Sender: TObject);
begin
  SetValue('$time$');
end;

procedure TfPathEditor.N10Click(Sender: TObject);
begin
  SetValue('$tags$');
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
