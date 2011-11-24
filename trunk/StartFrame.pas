unit StartFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, Menus, cxControls,
  cxContainer, cxEdit, dxSkinsCore, cxHeader, ActnList, cxImage, StdCtrls,
  cxButtons, dxGDIPlusClasses, ExtCtrls;

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
    procedure FrameResize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses MainFormU;

{$R *.dfm}

procedure TfStart.FrameResize(Sender: TObject);
begin

  bNew.SetBounds((Width - ButtonWidth - sps*4 - IconWidth) div 2,
                 (Height - ButtonHeight*3 - sps*8) div 2,
                 ButtonWidth,ButtonHeight);
  bLoad.SetBounds(bNew.Left,bNew.BoundsRect.Bottom + sps*4,ButtonWidth,ButtonHeight);
  bSettings.SetBounds(bNew.Left,bLoad.BoundsRect.Bottom + sps*4,ButtonWidth,ButtonHeight);

  iIcon.SetBounds(bNew.BoundsRect.Right + sps*4, (Height - IconHeight) div 2, IconWidth,IconHeight);
//  bAdvanced.SetBounds(iIcon.BoundsRect.Right + sps*2,iIcon.BoundsRect.Bottom - ButtonHeight,ButtonWidth,ButtonHeight);
end;

end.
