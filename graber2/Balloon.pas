{
  Balloon - using Balloon-shaped windows in your Delphi programs
  Copyright (C) 2003 JWB Software

  Web:   http://people.zeelandnet.nl/famboek/delphi/
  Email: jwbsoftware@zeelandnet.nl
}

Unit Balloon;

Interface

Uses
  Types, Forms, Classes, Controls, StdCtrls, ExtCtrls, Windows, Graphics,
  Messages, SysUtils;

Type
  TBalloonType = (blnNone, blnInfo, blnError, blnWarning);
  TBalloonHoriz = (blnLeft, blnMiddle, blnRight);
  TBalloonVert = (blnTop, blnCenter, blnBottom);
  TBalloonPosition = (blnArrowTopLeft, blnArrowTopRight, blnArrowBottomLeft,
    blnArrowBottomRight);

Type
  TBalloon = Class(TCustomForm)
  private
    lblTitle: TLabel;
    lblText: TLabel;
    pnlAlign: TPanel;
    iconBitmap: TImage;
    tmrExit: TTimer;
    FOnRelease: TNotifyEvent;
    Procedure FormPaint(Sender: TObject);
  protected
    Procedure CreateParams(Var Params: TCreateParams); override;
    Procedure OnMouseClick(Sender: TObject);
    Procedure OnExitTimerEvent(Sender: TObject);
    Procedure OnChange(Sender: TObject);
    Procedure WndProc(Var Message: TMessage); override;
    procedure DoRelease;
  public
    property OnRelease: TNotifyEvent read FOnRelease write FOnRelease;
    Constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    Procedure ShowBalloon(blnLeft, blnTop: Integer; blnTitle, blnText: String;
      blnType: TBalloonType; blnDuration: Integer;
      blnPosition: TBalloonPosition);
    Procedure ShowControlBalloon(blnControl: TWinControl;
      blnHoriz: TBalloonHoriz; blnVert: TBalloonVert; blnTitle, blnText: String;
      blnType: TBalloonType; blnDuration: Integer);
  End;

Type
  TBalloonControl = Class(TComponent)
  private
    FTitle: String;
    FText: TStringList;
    FDuration, FPixelCoordinateX, FPixelCoordinateY: Integer;
    FHorizontal: TBalloonHoriz;
    FVertical: TBalloonVert;
    FPosition: TBalloonPosition;
    FControl: TWinControl;
    FBalloonType: TBalloonType;

    Balloon: TBalloon;

    procedure SetText(Value: TStringList);
  public
    procedure ShowControlBalloon;
    procedure HideControlBalloon;
    procedure ShowPixelBalloon;
  published
    property Text: TStringList read FText write SetText;
    property Title: String read FTitle write FTitle;
    property Duration: Integer read FDuration write FDuration;
    property Horizontal: TBalloonHoriz read FHorizontal write FHorizontal;
    property Vertical: TBalloonVert read FVertical write FVertical;
    property Position: TBalloonPosition read FPosition write FPosition;
    property Control: TWinControl read FControl write FControl;
    property PixelCoordinateX: Integer read FPixelCoordinateX
      write FPixelCoordinateX;
    property PixelCoordinateY: Integer read FPixelCoordinateY
      write FPixelCoordinateY;
    property BalloonType: TBalloonType read FBalloonType write FBalloonType;

    Constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;
  End;

Procedure Register;

Implementation

// {$R Balloon.res}

Procedure Register;
Begin
  RegisterComponents('Custom', [TBalloonControl]);
End;

Constructor TBalloonControl.Create(AOwner: TComponent);
Begin
  Inherited;

  FText := TStringList.Create;
End;

Destructor TBalloonControl.Destroy;
Begin
  FText.Free;

  Inherited;
End;

procedure TBalloonControl.SetText(Value: TStringList);
begin
  FText.Assign(Value);
end;

Procedure TBalloonControl.HideControlBalloon;
begin
  if Assigned(Balloon) and Balloon.Visible then
    Balloon.Release;
end;

Procedure TBalloonControl.ShowControlBalloon();
// Var
// Balloon: TBalloon;
Begin
  Balloon := TBalloon.CreateNew(Owner);
  Balloon.ShowControlBalloon(FControl, FHorizontal, FVertical, FTitle,
    Trim(FText.Text), FBalloonType, FDuration);
End;

Procedure TBalloonControl.ShowPixelBalloon();
// Var
// Balloon: TBalloon;
Begin
  Balloon := TBalloon.CreateNew(nil);
  Balloon.ShowBalloon(FPixelCoordinateX, FPixelCoordinateY, FTitle,
    Trim(FText.Text), FBalloonType, FDuration, FPosition);
End;

Procedure TBalloon.CreateParams(Var Params: TCreateParams);
Begin
  Inherited CreateParams(Params);

  Params.Style := (Params.Style and not WS_CAPTION) or WS_POPUP;
  Params.ExStyle := Params.ExStyle or WS_EX_TOOLWINDOW or WS_EX_NOACTIVATE or
    WS_EX_TOPMOST;
  Params.WndParent := GetDesktopWindow;
End;

procedure TBalloon.DoRelease;
begin
  if Assigned(FOnRelease) then
    FOnRelease(Self);
  Release;
end;

Procedure TBalloon.OnMouseClick(Sender: TObject);
Begin
  DoRelease;
End;

Procedure TBalloon.OnExitTimerEvent(Sender: TObject);
Begin
  DoRelease;
End;

Procedure TBalloon.OnChange(Sender: TObject);
Begin
  SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOMOVE or
    SWP_NOSIZE);
End;

Procedure TBalloon.WndProc(Var Message: TMessage);
Begin
  If (Message.Msg = WM_SIZE) and (Message.WParam = SIZE_MINIMIZED) Then
    Show;

  Inherited;
End;

Constructor TBalloon.CreateNew(AOwner: TComponent; Dummy: Integer = 0);
Begin
  Inherited;

  OnActivate := OnChange;
  OnDeactivate := OnChange;
  OnShow := OnChange;
  BorderStyle := bsNone;
  FormStyle := fsStayOnTop;
  OnPaint := FormPaint;
  Color := clInfoBk;
  Font.Name := 'Tahoma';

  pnlAlign := TPanel.Create(Self);
  lblTitle := TLabel.Create(Self);
  lblText := TLabel.Create(Self);
  iconBitmap := TImage.Create(Self);
  tmrExit := TTimer.Create(Self);

  OnClick := OnMouseClick;
  iconBitmap.OnClick := OnMouseClick;
  pnlAlign.OnClick := OnMouseClick;
  lblTitle.OnClick := OnMouseClick;
  lblText.OnClick := OnMouseClick;

  lblTitle.Parent := Self;
  lblTitle.ParentColor := True;
  lblTitle.ParentFont := True;
  lblTitle.AutoSize := True;
  lblTitle.Font.Style := [fsBold];
  lblTitle.Left := 34;
  lblTitle.Top := 12;

  lblText.Parent := Self;
  lblText.ParentColor := True;
  lblText.ParentFont := True;
  lblText.AutoSize := True;
  lblText.Left := 10;

  iconBitmap.Parent := Self;
  iconBitmap.Transparent := True;
  iconBitmap.Left := 10;
  iconBitmap.Top := 10;

  tmrExit.Enabled := False;
  tmrExit.Interval := 0;
  tmrExit.OnTimer := OnExitTimerEvent;
End;

Procedure TBalloon.FormPaint(Sender: TObject);
Var
  TempRegion: HRGN;
Begin
  With Canvas.Brush Do
  Begin
    Color := clBlack;
    Style := bsSolid;
  End;

  TempRegion := CreateRectRgn(0, 0, 1, 1);
  GetWindowRgn(Handle, TempRegion);
  FrameRgn(Canvas.Handle, TempRegion, Canvas.Brush.Handle, 1, 1);
  DeleteObject(TempRegion);
End;

Procedure TBalloon.ShowControlBalloon(blnControl: TWinControl;
  blnHoriz: TBalloonHoriz; blnVert: TBalloonVert; blnTitle, blnText: String;
  blnType: TBalloonType; blnDuration: Integer);
Var
  Rect: TRect;
  blnPosLeft, blnPosTop: Integer;
  blnPosition: TBalloonPosition;
Begin
  GetWindowRect(blnControl.Handle, Rect);

  blnPosTop := 0;
  blnPosLeft := 0;

  If blnVert = blnTop Then
    blnPosTop := Rect.Top;

  If blnVert = blnCenter Then
    blnPosTop := Rect.Top + Round((Rect.Bottom - Rect.Top) / 2);

  If blnVert = blnBottom Then
    blnPosTop := Rect.Bottom;

  If blnHoriz = blnLeft Then
    blnPosLeft := Rect.Left;

  If blnHoriz = blnMiddle Then
    blnPosLeft := Rect.Left + Round((Rect.Right - Rect.Left) / 2);

  If blnHoriz = blnRight Then
    blnPosLeft := Rect.Right;

  blnPosition := blnArrowBottomRight;

  If ((blnHoriz = blnRight) and (blnVert = blnBottom)) or
    ((blnHoriz = blnMiddle) and (blnVert = blnBottom)) Then
    blnPosition := blnArrowBottomRight;

  If (blnHoriz = blnLeft) and (blnVert = blnBottom) or
    ((blnHoriz = blnLeft) and (blnVert = blnCenter)) Then
    blnPosition := blnArrowBottomLeft;

  If (blnHoriz = blnLeft) and (blnVert = blnTop) or
    ((blnHoriz = blnMiddle) and (blnVert = blnTop)) Then
    blnPosition := blnArrowTopLeft;

  If (blnHoriz = blnRight) and (blnVert = blnTop) or
    ((blnHoriz = blnRight) and (blnVert = blnCenter)) Then
    blnPosition := blnArrowTopRight;

  ShowBalloon(blnPosLeft, blnPosTop, blnTitle, blnText, blnType, blnDuration,
    blnPosition);
End;

Procedure TBalloon.ShowBalloon(blnLeft, blnTop: Integer;
  blnTitle, blnText: String; blnType: TBalloonType; blnDuration: Integer;
  blnPosition: TBalloonPosition);
Var
  ArrowHeight, ArrowWidth: Integer;
  FormRegion, ArrowRegion: HRGN;
  Arrow: Array [0 .. 2] Of TPoint;
  ResName: String;
Begin
  ArrowHeight := 20;
  ArrowWidth := 20;

  lblTitle.Caption := blnTitle;

  If blnPosition = blnArrowBottomRight Then
    lblTitle.Top := lblTitle.Top + ArrowHeight;

  If blnPosition = blnArrowBottomLeft Then
    lblTitle.Top := lblTitle.Top + ArrowHeight;

  lblText.Top := lblTitle.Top + lblTitle.Height + 8;
  lblText.Caption := blnText;

  If blnPosition = blnArrowBottomRight Then
    iconBitmap.Top := iconBitmap.Top + ArrowHeight;

  If blnPosition = blnArrowBottomLeft Then
    iconBitmap.Top := iconBitmap.Top + ArrowHeight;

  Case blnType Of
    blnNone:
      ResName := '';
    blnError:
      ResName := 'ERROR';
    blnInfo:
      ResName := 'INFO';
    blnWarning:
      ResName := 'WARNING';
  Else
    ResName := 'INFO';
  End;

  if ResName <> '' then
    iconBitmap.Picture.Bitmap.LoadFromResourceName(HInstance, ResName)
  else
    lblTitle.Left := iconBitmap.Left;

  If blnPosition = blnArrowBottomRight Then
    ClientHeight := lblText.Top + lblText.Height + 10;
  If blnPosition = blnArrowBottomLeft Then
    ClientHeight := lblText.Top + lblText.Height + 10;
  If blnPosition = blnArrowTopLeft Then
    ClientHeight := lblText.Top + lblText.Height + 10 + ArrowHeight;
  If blnPosition = blnArrowTopRight Then
    ClientHeight := lblText.Top + lblText.Height + 10 + ArrowHeight;

  If (lblTitle.Left + lblTitle.Width) > (lblText.Left + lblText.Width) Then
    Width := lblTitle.Left + lblTitle.Width + 10
  Else
    Width := lblText.Left + lblText.Width + 10;

  If blnPosition = blnArrowTopLeft Then
  Begin
    Left := blnLeft - (Width - 20);
    Top := blnTop - (Height);
  End;

  If blnPosition = blnArrowTopRight Then
  Begin
    Left := blnLeft - 20;
    Top := blnTop - (Height);
  End;

  If blnPosition = blnArrowBottomRight Then
  Begin
    Left := blnLeft - 20;
    Top := blnTop - 2;
  End;

  If blnPosition = blnArrowBottomLeft Then
  Begin
    Left := blnLeft - (Width - 20);
    Top := blnTop - 2;
  End;

  FormRegion := 0;

  If blnPosition = blnArrowTopLeft Then
  Begin
    FormRegion := CreateRoundRectRgn(0, 0, Width,
      Height - (ArrowHeight - 2), 7, 7);

    Arrow[0] := Point(Width - ArrowWidth - 20, Height - ArrowHeight);
    Arrow[1] := Point(Width - 20, Height);
    Arrow[2] := Point(Width - 20, Height - ArrowHeight);
  End;

  If blnPosition = blnArrowTopRight Then
  Begin
    FormRegion := CreateRoundRectRgn(0, 0, Width,
      Height - (ArrowHeight - 2), 7, 7);

    Arrow[0] := Point(20, Height - ArrowHeight);
    Arrow[1] := Point(20, Height);
    Arrow[2] := Point(20 + ArrowWidth, Height - ArrowHeight);
  End;

  If blnPosition = blnArrowBottomRight Then
  Begin
    FormRegion := CreateRoundRectRgn(0, ArrowHeight + 2, Width, Height, 7, 7);

    Arrow[0] := Point(20, 2);
    Arrow[1] := Point(20, ArrowHeight + 2);
    Arrow[2] := Point(20 + ArrowWidth, ArrowHeight + 2);
  End;

  If blnPosition = blnArrowBottomLeft Then
  Begin
    FormRegion := CreateRoundRectRgn(0, ArrowHeight + 2, Width, Height, 7, 7);

    Arrow[0] := Point(Width - 20, 2);
    Arrow[1] := Point(Width - 20, ArrowHeight + 2);
    Arrow[2] := Point(Width - 20 - ArrowWidth, ArrowHeight + 2);
  End;

  ArrowRegion := CreatePolygonRgn(Arrow, 3, WINDING);

  CombineRgn(FormRegion, FormRegion, ArrowRegion, RGN_OR);
  DeleteObject(ArrowRegion);
  SetWindowRgn(Handle, FormRegion, True);

  Visible := False;
  ShowWindow(Handle, SW_SHOWNOACTIVATE);
  Visible := True;

  tmrExit.Interval := blnDuration * 1000;
  tmrExit.Enabled := True;
End;

End.
