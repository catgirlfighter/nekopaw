unit StartFrame;

interface

uses
  {base}
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, ExtCtrls,
  {devexp}
  cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, cxControls,
  cxContainer, cxEdit, dxSkinsCore, cxHeader, cxImage,
  cxButtons, dxGDIPlusClasses,
  {graber2}
  common;

const
  IconWidth = 300;
  IconHeight = 300;
  Sps = 4;
  ButtonWidth = 150;
  ButtonHeight = 25;

type
  TfStart = class(TFrame)
    bNew: TcxButton;
    bLoad: TcxButton;
    bSettings: TcxButton;
    iIcon: TImage;
    bExit: TcxButton;
    procedure FrameResize(Sender: TObject);
    procedure bNewClick(Sender: TObject);
    procedure bExitClick(Sender: TObject);
    procedure bSettingsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses MainForm, GraberU;

{$R *.dfm}

procedure TfStart.bExitClick(Sender: TObject);
begin
  PostMessage(mf.Handle,WM_CLOSE,0,0);
end;

procedure TfStart.bNewClick(Sender: TObject);
begin
  PostMessage(mf.Handle,CM_NEWLIST,0,0);
end;

procedure TfStart.bSettingsClick(Sender: TObject);
begin
  PostMessage(Application.MainForm.Handle,CM_SHOWSETTINGS,0,0);
end;

procedure TfStart.FrameResize(Sender: TObject);
begin
  bNew.SetBounds((Width - ButtonWidth - sps*4 - IconWidth) div 2,
                 (Height - ButtonHeight*3 - sps*8) div 2,
                 ButtonWidth,ButtonHeight);
  bLoad.SetBounds(bNew.Left,bNew.BoundsRect.Bottom + sps*4,ButtonWidth,ButtonHeight);
  bSettings.SetBounds(bNew.Left,bLoad.BoundsRect.Bottom + sps*4,ButtonWidth,ButtonHeight);
  bExit.SetBounds(bNew.Left,bSettings.BoundsRect.Bottom + sps*4,ButtonWidth,ButtonHeight);
  iIcon.SetBounds(bNew.BoundsRect.Right + sps*4, (Height - IconHeight) div 2, IconWidth,IconHeight);
//  bAdvanced.SetBounds(iIcon.BoundsRect.Right + sps*2,iIcon.BoundsRect.Bottom - ButtonHeight,ButtonWidth,ButtonHeight);
end;

end.
