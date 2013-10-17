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
    procedure bAboutClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure SetLang;
    { Public declarations }
  end;

implementation

uses MainForm, GraberU, LangString, AboutForm, win7taskbar;

{$R *.dfm}

procedure TfStart.bAboutClick(Sender: TObject);
begin
  fmAbout.Show;
end;

procedure TfStart.bExitClick(Sender: TObject);
begin
  PostMessage(mf.Handle, WM_CLOSE, 0, 0);
end;

procedure TfStart.bNewClick(Sender: TObject);
begin
  PostMessage(mf.Handle, CM_NEWLIST, 0, 0);
end;

procedure TfStart.bSettingsClick(Sender: TObject);
begin
  PostMessage(Application.MainForm.Handle, CM_SHOWSETTINGS, 0, 0);
end;

procedure TfStart.FrameResize(Sender: TObject);
begin
  bNew.SetBounds((Width - ButtonWidth - Sps * 4 - IconWidth) div 2,
    (Height - ButtonHeight * 3 - Sps * 8) div 2, ButtonWidth, ButtonHeight);
  bLoad.SetBounds(bNew.Left, bNew.BoundsRect.Bottom + Sps * 4, ButtonWidth,
    ButtonHeight);
  bSettings.SetBounds(bNew.Left, bLoad.BoundsRect.Bottom + Sps * 4, ButtonWidth,
    ButtonHeight);
  // bAbout.SetBounds(bNew.Left,bSettings.BoundsRect.Bottom + sps*4,ButtonWidth,ButtonHeight);
  iIcon.SetBounds(bNew.BoundsRect.Right + Sps * 4, (Height - IconHeight) div 2,
    IconWidth, IconHeight);
  bExit.SetBounds(bNew.Left, iIcon.BoundsRect.Bottom - ButtonHeight,
    ButtonWidth, ButtonHeight);

  // bAdvanced.SetBounds(iIcon.BoundsRect.Right + sps*2,iIcon.BoundsRect.Bottom - ButtonHeight,ButtonWidth,ButtonHeight);
end;

procedure TfStart.SetLang;
begin
  bNew.Caption := lang('_NEWLIST_');
  bLoad.Caption := lang('_LOADLIST_');
  bSettings.Caption := lang('_SETTINGS_');
  bExit.Caption := lang('_EXIT_');
end;

end.
