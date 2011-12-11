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
  cxGridLevel, cxGrid, cxButtonEdit, cxExtEditRepositoryItems, cxPC,
  {graber2}
  common, cxLabel, cxImage;

type
  TListFrameState = (lfsNew, lfsEdit);

  TfNewList = class(TFrame)
    VSplitter: TcxSplitter;
    pButtons: TPanel;
    btnOk: TcxButton;
    btnCancel: TcxButton;
    lvlRes1: TcxGridLevel;
    gRes: TcxGrid;
    tvRes: TcxGridTableView;
    gRescName: TcxGridColumn;
    gRescButton: TcxGridColumn;
    pcMain: TcxPageControl;
    tsList: TcxTabSheet;
    tsSettings: TcxTabSheet;
    gFull: TcxGrid;
    tvFull: TcxGridTableView;
    tvFullcButton: TcxGridColumn;
    tvFullcName: TcxGridColumn;
    lvlFull1: TcxGridLevel;
    tvFullID: TcxGridColumn;
    EditRepository: TcxEditRepository;
    EditRepositoryLabel1: TcxEditRepositoryLabel;
    tvFullcIcon: TcxGridColumn;
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

var
  LList: array of TcxLabelProperties;

implementation

uses MainForm, OpBase;

{$R *.dfm}

procedure TfNewList.btnCancelClick(Sender: TObject);
begin
  PostMessage(Parent.Handle, CM_CANCELNEWLIST, Integer(Sender), 0);
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
  MessageDlg('derp', mtInformation, [mbOk], 0);
end;

initialization



end.
