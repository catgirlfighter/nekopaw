unit NewListFrame;

interface

uses
  {base}
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls,
  {devexp}
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxCustomData, cxStyles, cxTL, cxTextEdit, cxCheckBox, cxTLdxBarBuiltInMenu,
  dxSkinsCore, ExtCtrls, cxSplitter, cxInplaceContainer,
  cxButtons, dxSkinscxPCPainter, cxFilter, cxData, cxDataStorage, cxEdit,
  cxGridCustomTableView, cxGridTableView, cxGridCustomView, cxClasses,
  cxGridLevel, cxGrid,
  {graber2}
  common, cxButtonEdit, cxLabel;

type
  TListFrameState = (lfsNew, lfsEdit);

  TfNewList = class(TFrame)
    VSplitter: TcxSplitter;
    pButtons: TPanel;
    btnOk: TcxButton;
    btnCancel: TcxButton;
    gResLevel1: TcxGridLevel;
    gRes: TcxGrid;
    gResTableView1: TcxGridTableView;
    gResTableView1Column1: TcxGridColumn;
    gResLevel2: TcxGridLevel;
    gResTableView2: TcxGridTableView;
    gResTableView1Column2: TcxGridColumn;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure gResTableView1Column1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
  public
    State: TListFrameState;
    { Public declarations }
  end;

implementation

uses MainForm;

{$R *.dfm}

procedure TfNewList.btnCancelClick(Sender: TObject);
begin
  PostMessage(Parent.Handle, CM_CANCELNEWLIST, integer(Sender), 0);
end;

procedure TfNewList.btnOkClick(Sender: TObject);
begin
  case State of
    lfsNew:
      PostMessage(Parent.Handle, CM_APPLYNEWLIST, 0, 0);
    lfsEdit:
      PostMessage(Parent.Handle, CM_APPLYEDITLIST, 0, 0);
  end;

end;

procedure TfNewList.gResTableView1Column1PropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  MessageDlg('derp',mtInformation,[mbOk],0);
end;

end.
