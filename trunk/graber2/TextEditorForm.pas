unit TextEditorForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, dxSkinsCore, Menus, StdCtrls, cxButtons, ExtCtrls,
  cxTextEdit, cxMemo;

type
  TfTextEdit = class(TForm)
    mText: TcxMemo;
    Panel1: TPanel;
    btnOk: TcxButton;
    btnCancel: TcxButton;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    procedure SetLang;
    function Execute: boolean;
    { Public declarations }
  end;

var
  fTextEdit: TfTextEdit;

implementation

uses OpBase, LangString;

{$R *.dfm}

function TfTextEdit.Execute: boolean;
begin
  ShowModal;
  Result := ModalResult = mrOk;
end;

procedure TfTextEdit.FormCreate(Sender: TObject);
begin
  SetLang;
end;

procedure TfTextEdit.SetLang;
begin
  Caption := lang('_TEXTEDITOR_');
  btnOk.Caption := lang('_OK_');
  btnCancel.Caption := lang('_CANCEL_');
end;

end.
