unit NewListForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  dxSkinsCore, Menus, StdCtrls, cxButtons, cxContainer, cxEdit, cxCheckListBox,
  dximctrl;

type
  TfGetList = class(TForm)
    btnOk: TcxButton;
    btnCancel: TcxButton;
    btnSettings: TcxButton;
    btnEdit: TcxButton;
    btnDelete: TcxButton;
    lbList: TdxImageListBox;
  private
    { Private declarations }
  public
    function Execute: Boolean;
    { Public declarations }
  end;

var
  fGetList: TfGetList;

implementation

{$R *.dfm}

function TfGetList.Execute: Boolean;
begin
  ShowModal;
  Result := ModalResult= mrOk;
end;

end.
