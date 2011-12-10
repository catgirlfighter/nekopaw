{ Modified version of the standard gauges component to add some needed
  functionality.  It now allows Text to be entered into the gauge by setting
  the caption.  It also allows the font color to be adjusted.

  Modifications by

  Curtis White
  President, TechnoSoft
}

unit gauges;

interface

uses WinTypes, Messages, Classes,  Graphics, Controls, Forms, StdCtrls;

type

  TGaugeKind = (gkText, gkHorizontalBar, gkVerticalBar, gkPie, gkNeedle);

  TGauge = class(TGraphicControl)
  private
    FPainting: Boolean;
    FMinValue: Longint;
    FMaxValue: Longint;
    FCurValue: Longint;
    FKind: TGaugeKind;
    FShowText: Boolean;
    FShowPercent: Boolean;
    FBorderStyle: TBorderStyle;
    FForeColor: TColor;
    FBackColor: TColor;
    FCaption: String;
    procedure PaintBackground(AnImage: TBitmap);
    procedure PaintAsText(AnImage: TBitmap; PaintRect: TRect);
    procedure PaintAsNothing(AnImage: TBitmap; PaintRect: TRect);
    procedure PaintAsBar(AnImage: TBitmap; PaintRect: TRect);
    procedure PaintAsPie(AnImage: TBitmap; PaintRect: TRect);
    procedure PaintAsNeedle(AnImage: TBitmap; PaintRect: TRect);
    procedure SetGaugeKind(Value: TGaugeKind);
    procedure SetShowText(Value: Boolean);
    procedure SetShowPercent(Value: Boolean);
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetForeColor(Value: TColor);
    procedure SetBackColor(Value: TColor);
    procedure SetMinValue(Value: Longint);
    procedure SetMaxValue(Value: Longint);
    procedure SetProgress(Value: Longint);
    procedure SetCaption(Value: String);
    function GetPercentDone: Longint;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure AddProgress(Value: Longint);
    property PercentDone: Longint read GetPercentDone;
  published
    property Align;
    property Color;
    property Caption: String read FCaption write SetCaption;
    property Enabled;
    property Kind: TGaugeKind read FKind write SetGaugeKind default gkHorizontalBar;
    property ShowText: Boolean read FShowText write SetShowText default False;
    property ShowPercent: Boolean read FShowPercent write SetShowPercent default True;
    property Font;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property ForeColor: TColor read FForeColor write SetForeColor default clBlack;
    property BackColor: TColor read FBackColor write SetBackColor default clWhite;
    property MinValue: Longint read FMinValue write SetMinValue default 0;
    property MaxValue: Longint read FMaxValue write SetMaxValue default 100;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property Progress: Longint read FCurValue write SetProgress;
    property ShowHint;
    property Visible;
  end;

implementation

uses {WinProcs,} SysUtils;

type
  TBltBitmap = class(TBitmap)
    procedure MakeLike(ATemplate: TBitmap);
  end;

procedure TBltBitmap.MakeLike(ATemplate: TBitmap);
begin
  Width := ATemplate.Width;
  Height := ATemplate.Height;
  Canvas.Brush.Color := clWindowFrame;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(Rect(0, 0, Width, Height));
end;

{ This function solves for x in the equation "x is y% of z". }
function SolveForX(Y, Z: Longint): Integer;
begin
  SolveForX := Trunc( Z * (Y * 0.01) );
end;

{ This function solves for y in the equation "x is y% of z". }
function SolveForY(X, Z: Longint): Integer;
begin
  if Z = 0 then SolveForY := 0
  else SolveForY := Trunc( (X * 100) / Z );
end;

{ TGauge }
constructor TGauge.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csFramed, csOpaque];
  { default values }
  FMinValue := 0;
  FMaxValue := 100;
  FCurValue := 0;
  FKind := gkHorizontalBar;
  FShowText := False;
  FShowPercent := True;
  FBorderStyle := bsSingle;
  FForeColor := clBlack;
  FBackColor := clWhite;
  Width := 100;
  Height := 100;
  FPainting := false;
end;

function TGauge.GetPercentDone: Longint;
begin
  GetPercentDone := SolveForY(FCurValue - FMinValue, FMaxValue - FMinValue);
end;

procedure TGauge.Paint;
var
  TheImage: TBitmap;
  OverlayImage: TBltBitmap;
  PaintRect: TRect;
begin
  if FPainting then
    Exit;
  FPainting := True;
  with Canvas do
  begin
    TheImage := TBitmap.Create;
    try
      TheImage.Height := Height;
      TheImage.Width := Width;
      PaintBackground(TheImage);
      PaintRect := ClientRect;
      if FBorderStyle = bsSingle then InflateRect(PaintRect, -1, -1);
      OverlayImage := TBltBitmap.Create;
      try
        OverlayImage.MakeLike(TheImage);
        PaintBackground(OverlayImage);
        case FKind of
          gkText: PaintAsNothing(OverlayImage, PaintRect);
          gkHorizontalBar, gkVerticalBar: PaintAsBar(OverlayImage, PaintRect);
          gkPie: PaintAsPie(OverlayImage, PaintRect);
          gkNeedle: PaintAsNeedle(OverlayImage, PaintRect);
        end;
        TheImage.Canvas.CopyMode := cmSrcInvert;
        TheImage.Canvas.Draw(0, 0, OverlayImage);
        TheImage.Canvas.CopyMode := cmSrcCopy;
        if ShowText or ShowPercent then PaintAsText(TheImage, PaintRect);
      finally
        OverlayImage.Free;
      end;
      Canvas.CopyMode := cmSrcCopy;
      Canvas.Draw(0, 0, TheImage);
    finally
      TheImage.Destroy;
    end;
  end;
  FPainting := false;
end;

procedure TGauge.PaintBackground(AnImage: TBitmap);
var
  ARect: TRect;
begin
  with AnImage.Canvas do
  begin
//    CopyMode := Whiteness;
    ARect := Rect(0, 0, Width, Height);
    Brush.Color := clWhite;
    Rectangle(ARect);
//    CopyRect(ARect, Animage.Canvas, ARect);
//    CopyMode := cmSrcCopy;
  end;
end;

procedure TGauge.PaintAsText(AnImage: TBitmap; PaintRect: TRect);
var
  S: string;
  X, Y: Integer;
  B: TBitmap;
//  OverRect: TBltBitmap;
begin
//  OverRect := TBltBitmap.Create;
  B := TBitmap.Create;
  try
{    OverRect.MakeLike(AnImage);
    PaintBackground(OverRect);  }
    B.Assign(AnImage);
    PaintBackground(B);
    if ShowPercent and ShowText then
      S := Caption + ': ' + Format('%d%%', [PercentDone])
    else
    begin
      if ShowPercent then
        S := Format('%d%%', [PercentDone])
      else
        S := Caption;
    end;
    with B.Canvas do
    begin
      Brush.Style := bsClear;
      Font.Color := clBlack;
      with PaintRect do
      begin
        X := (Right - Left + 1 - TextWidth(S)) div 2;
        Y := (Bottom - Top + 1 - TextHeight(S)) div 2;
      end;
      TextRect(PaintRect, X, Y, S);
    end;
    AnImage.Canvas.CopyMode := cmSrcInvert;
    AnImage.Canvas.Draw(0, 0, B);
  finally
    B.Free;
  end;
end;

procedure TGauge.PaintAsNothing(AnImage: TBitmap; PaintRect: TRect);
begin
  with AnImage do
  begin
    Canvas.Brush.Color := BackColor;
    Canvas.FillRect(PaintRect);
  end;
end;

procedure TGauge.PaintAsBar(AnImage: TBitmap; PaintRect: TRect);
var
  FillSize: Longint;
  W, H: Integer;
begin
  W := PaintRect.Right - PaintRect.Left + 1;
  H := PaintRect.Bottom - PaintRect.Top + 1;
  with AnImage.Canvas do
  begin
    Brush.Color := BackColor;
    FillRect(PaintRect);
    Pen.Color := ForeColor;
    Pen.Width := 1;
    Brush.Color := ForeColor;
    case FKind of
      gkHorizontalBar:
        begin
          FillSize := SolveForX(PercentDone, W);
          if FillSize > W then FillSize := W;
          if FillSize > 0 then FillRect(Rect(PaintRect.Left, PaintRect.Top,
            FillSize, H));
        end;
      gkVerticalBar:
        begin
          FillSize := SolveForX(PercentDone, H);
          if FillSize >= H then FillSize := H - 1;
          FillRect(Rect(PaintRect.Left, H - FillSize, W, H));
        end;
    end;
  end;
end;

procedure TGauge.PaintAsPie(AnImage: TBitmap; PaintRect: TRect);
var
  MiddleX, MiddleY: Integer;
  Angle: Double;
  X, Y, W, H: Integer;
  OverRect: TBltBitmap;
begin
  W := PaintRect.Right - PaintRect.Left;
  H := PaintRect.Bottom - PaintRect.Top;
  if FBorderStyle = bsSingle then
  begin
    Inc(W);
    Inc(H);
  end;
  with AnImage.Canvas do
  begin
    Brush.Color := Color;
    FillRect(PaintRect);
    Brush.Color := BackColor;
    Pen.Color := ForeColor;
    Pen.Width := 1;
    Ellipse(PaintRect.Left, PaintRect.Top, W, H);
    if PercentDone > 0 then
    begin
      Brush.Color := ForeColor;
      MiddleX := W div 2;
      MiddleY := H div 2;
      Angle := (Pi * ((PercentDone / 50) + 0.5));
      Pie(PaintRect.Left, PaintRect.Top, W, H, Round(MiddleX * (1 - Cos(Angle))),
        Round(MiddleY * (1 - Sin(Angle))), MiddleX, 0);
    end;
  end;
end;

procedure TGauge.PaintAsNeedle(AnImage: TBitmap; PaintRect: TRect);
var
  MiddleX: Integer;
  Angle: Double;
  X, Y, W, H: Integer;
  OverRect: TBltBitmap;
begin
  with PaintRect do
  begin
    X := Left;
    Y := Top;
    W := Right - Left;
    H := Bottom - Top;
    if FBorderStyle = bsSingle then
    begin
      Inc(W);
      Inc(H);
    end;
  end;
  with AnImage.Canvas do
  begin
    Brush.Color := Color;
    FillRect(PaintRect);
    Brush.Color := BackColor;
    Pen.Color := ForeColor;
    Pen.Width := 1;
    Pie(X, Y, W, H * 2 - 1, X + W, PaintRect.Bottom - 1, X, PaintRect.Bottom - 1);
    MoveTo(X, PaintRect.Bottom);
    LineTo(X + W, PaintRect.Bottom);
    if PercentDone > 0 then
    begin
      Pen.Color := ForeColor;
      MiddleX := Width div 2;
      MoveTo(MiddleX, PaintRect.Bottom - 1);
      Angle := (Pi * ((PercentDone / 100)));
      LineTo(Round(MiddleX * (1 - Cos(Angle))), Round((PaintRect.Bottom - 1) *
        (1 - Sin(Angle))));
    end;
  end;
end;

procedure TGauge.SetGaugeKind(Value: TGaugeKind);
begin
  if Value <> FKind then
  begin
    FKind := Value;
    Refresh;
  end;
end;

procedure TGauge.SetShowText(Value: Boolean);
begin
  if Value <> FShowText then
  begin
    FShowText := Value;
    Refresh;
  end;
end;

procedure TGauge.SetShowPercent(Value: Boolean);
begin
  if Value <> FShowPercent then
  begin
    FShowPercent := Value;
    Refresh;
  end;
end;

procedure TGauge.SetBorderStyle(Value: TBorderStyle);
begin
  if Value <> FBorderStyle then
  begin
    FBorderStyle := Value;
    Refresh;
  end;
end;

procedure TGauge.SetForeColor(Value: TColor);
begin
  if Value <> FForeColor then
  begin
    FForeColor := Value;
    Refresh;
  end;
end;

procedure TGauge.SetBackColor(Value: TColor);
begin
  if Value <> FBackColor then
  begin
    FBackColor := Value;
    Refresh;
  end;
end;

procedure TGauge.SetMinValue(Value: Longint);
begin
  if Value <> FMinValue then
  begin
    FMinValue := Value;
    Refresh;
  end;
end;

procedure TGauge.SetMaxValue(Value: Longint);
begin
  if Value <> FMaxValue then
  begin
    FMaxValue := Value;
    Refresh;
  end;
end;

procedure TGauge.SetProgress(Value: Longint);
begin
  if (FCurValue <> Value) and (Value >= FMinValue) and (Value <= FMaxValue) then
  begin
    FCurValue := Value;
    Refresh;
  end;
end;

procedure TGauge.SetCaption(Value: String);
begin
  FCaption := Value;
//  Repaint;
end;

procedure TGauge.AddProgress(Value: Longint);
begin
  Progress := FCurValue + Value;
  Refresh;
end;

end.
