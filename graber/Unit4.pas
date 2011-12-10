unit Unit4;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, common;

type
  Taboutform = class(TForm)
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  aboutform: Taboutform;

implementation

{$R *.dfm}

procedure Taboutform.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure Taboutform.FormCreate(Sender: TObject);
begin
  DrawImageFromRes(Image1,'ZTAO','.png');
end;

procedure Taboutform.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
const SC_DRAGMOVE = $F012;
begin
  ReleaseCapture;
  Perform(WM_SYSCOMMAND, SC_DRAGMOVE, 0);
end;

procedure Taboutform.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
const SC_DRAGMOVE = $F012;
begin
  ReleaseCapture;
  Perform(WM_SYSCOMMAND, SC_DRAGMOVE, 0);
end;

end.
