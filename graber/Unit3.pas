unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Controls, Forms,
  Dialogs, pngimage, GIFImg, ExtCtrls, IdHTTP, Graphics, StdCtrls, ComCtrls, math,
  types, hacks;

type

  TfPreview = class;

  TPreviewThread = class(TThread)
  private
    // atime: TDateTime;
    FHTTP: TMyIdHTTP;
    Form: TfPreview;
    furl: string;
    FImage: TImage;
    n: boolean;
    F: TMemoryStream;
    procedure SetDefPic;
    procedure SetRefPic;
    procedure SetPic;
  protected
    procedure Execute; override;
  end;

  TfPreview = class(TForm)
    iPreview: TImage;
    iCaption: TImage;
    timer: TTimer;
    procedure FormHide(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure timerTimer(Sender: TObject);
  private
    lCaption: String;
    furl,freferer: String;
    FPThread: TPreviewThread;
    procedure WMExitSizeMove(var Message: TMessage); message WM_EXITSIZEMOVE;
    { Private declarations }

  public
    procedure Execute(AURL: string; AReferer: String = ''; AName: String = '');
    procedure ThreadTerminate(Sender: TObject);
    { Public declarations }
  published
  end;

var
  fPreview: TfPreview;
  preview_window_left, preview_window_top, preview_window_undrag_left,
    preview_window_undrag_top: integer;
  preview_window_drag: boolean = true;

implementation

uses Unit1, Consts, common;
{$R *.dfm}

procedure ResetALPHA(PNG: TPNGIMAGE; BMP: TBITMAP);

  function CHECKQUAD(Q1, Q2: TRGBQUAD): boolean;
  begin
    result := (Q1.rgbBlue = Q2.rgbBlue) and (Q1.rgbGreen = Q2.rgbGreen) and
      (Q1.rgbRed = Q2.rgbRed);

  end;

const
  WHITEQUAD: TRGBQUAD = (rgbBlue: 255; rgbGreen: 255; rgbRed: 255;
    rgbReserved: 0);

  pWHITE = $FFFFFFFF;

type
  PRGBArray = ^TRGBArray;
  TRGBArray = array [WORD] of pRGBQuad;
var
  x, y: integer;
  DstAlpha: pByteArray;
begin
  for y := 0 to PNG.Height - 1 do
  begin
    DstAlpha := PNG.AlphaScanline[y];
    for x := 0 to PNG.Width - 1 do
      DstAlpha[x] := ROUND(MIN(1,BMP.Canvas.Pixels[x,y] / clWHITE + 0.6)*255);
  end;
end;

procedure DrawText(Canvas: TCanvas; ARect: TRect; AText: String);
const
  Alignments: array [TAlignment] of WORD = (DT_LEFT, DT_RIGHT, DT_CENTER);
  Ellipsis: array [TEllipsisPosition] of Longint = (0, DT_PATH_ELLIPSIS,
    DT_END_ELLIPSIS, DT_WORD_ELLIPSIS);
var
  DrawStyle: Longint;
  Brsh: TBrushStyle;
begin
  DrawStyle := DT_CENTER or DT_END_ELLIPSIS;
  Brsh := Canvas.Brush.Style;
  Canvas.Brush.Style := bsClear;
  SetTextColor(Canvas.Handle, RGB(255,255,255));
  DrawTextW(Canvas.Handle, AText, Length(AText), ARect, DrawStyle);
  Canvas.Brush.Style := Brsh;
end;

procedure SetText(IMG: TGRAPHIC; ARect: TRect; AText: String);
var
  BMP: TBITMAP;
begin
  with IMG as TPNGIMAGE do
  begin
    Canvas.Brush.Color := clBlack;
    Canvas.FillRect(ARect);
    DrawText(Canvas,ARect,AText);
  end;
  BMP := TBITMAP.Create;
  BMP.Assign(IMG);
  BMP.Transparent := false;
  with BMP do
  begin
    Canvas.Font.Assign((IMG as TPNGIMAGE).Canvas.Font);
    Canvas.Brush.Color := clBlack;
    Canvas.FillRect(ARect);
    DrawText(Canvas,ARect,AText);
  end;
  ResetALPHA(IMG as TPNGIMAGE,BMP);
  FreeAndNil(BMP);
end;

procedure TfPreview.WMExitSizeMove(var Message: TMessage);
begin
  if preview_window_drag then
  begin
    preview_window_left := Left - MainForm.Left;
    preview_window_top := Top - MainForm.Top;
  end
  else
  begin
    preview_window_undrag_left := Left;
    preview_window_undrag_top := Top;
  end;
  inherited;
end;

procedure TPreviewThread.SetDefPic;
begin
  FImage.Picture.Icon.Handle := LoadIcon(hInstance, 'ZIMAGE');
end;

procedure TPreviewThread.SetRefPic;
begin
  DrawImageFromRes(FImage, 'ZLOADING', '.gif');
end;

procedure TPreviewThread.SetPic;

const
  BF: TBlendFunction = (BlendOp: AC_SRC_OVER; BlendFlags: 0;
    SourceConstantAlpha: AC_SRC_NO_PREMULT_ALPHA;
    AlphaFormat: 100);

begin
  DrawImage(FImage, F, ImageFormat(F.Memory));
  Form.ClientWidth := Max(150, FImage.Picture.Width);
  Form.ClientHeight := Max(150, FImage.Picture.Height) { + 13 } ;

  if (Form.lCaption <> '') and (not(FImage.Picture.Graphic is TGIFIMAGE) or
     not TGIFIMAGE(FImage.Picture.Graphic).Animate) then
    with Form do
    begin
      iCaption.Width := ClientWidth;
      iCaption.Top := ClientHeight - 13;
      SetText(iCaption.Picture.Graphic, Rect(0, 0, ClientWidth, 12), lCaption);
      iCaption.Show;
    end;

end;

procedure TPreviewThread.Execute;
begin
  while not terminated do
  begin
    while not n do
    begin
      n := true;
      F := nil;
      if furl = '' then
        break;
      try
        synchronize(SetRefPic);
        F := TMemoryStream.Create;
        FHTTP.Get(furl, F);
        //Showmessage(FHTTP.Response.RawHeaders.Text);
        FHTTP.Disconnect;
        // FreeAndNil(FHTTP);
        if n then
          synchronize(SetPic);
        FreeAndNil(F);
      except
        if n then
          synchronize(SetDefPic);
        if Assigned(F) then
          FreeAndNil(F);
        { if Assigned(FHTTP) then
          FreeAndNil(FHTTP); }
      end;
    end;
    Suspended := true;
  end;
end;

procedure TfPreview.ThreadTerminate(Sender: TObject);
begin

end;

procedure TfPreview.timerTimer(Sender: TObject);
begin
  timer.Enabled := false;
  if Assigned(FPThread) then
  begin
    try
      FPThread.FHTTP.Disconnect;
      FPThread.FHTTP.Request.Referer := freferer;
      FPThread.furl := furl;
      if pos('https:',lowercase(furl)) = 1 then
        FPThread.FHTTP.IOHandler := MainForm.OpSSLHandler
      else
        FPThread.FHTTP.IOHandler := nil;
      FPThread.n := false;
      FPThread.Suspended := false;
    finally
    end;
  end;
end;

procedure TfPreview.Execute(AURL: string; AReferer: String = '';
  AName: String = '');
begin
  timer.Enabled := false;
  if SameText(furl,AURL) and (furl <> '') then
    Exit;
  iCaption.Hide;
  { if AName = '' then
    lCaption.Hide
    else
    begin
    lCaption.Caption := AName;
    lCaption.Show;
    end; }

  furl := AURL;

{  if MainForm.chbdebug.Checked then
  begin
    MainForm.log('preview = '+furl);
    MainForm.log('referer = ' + AReferer);
  end;   }

{  if pos('https:',lowercase(furl)) =1 then }


  if furl <> '' then
  begin
    lCaption := AName;
    freferer := AReferer;
    timer.Enabled := true;
  end
  else if furl = '' then
    iPreview.Picture.Icon.Handle := LoadIcon(hInstance, 'ZIMAGE');
end;

procedure TfPreview.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  MainForm.chbPreview.Checked := false;
end;

procedure TfPreview.FormCreate(Sender: TObject);
var
  PNG: TPNGIMAGE;
begin
  // iPreview
  // SetALPHA(lCaption.Canvas.Handle
  PNG := TPNGIMAGE.CreateBlank(COLOR_RGBALPHA, 8, 300, 13);
  // PNG.SetSize(300,13);
  // PNG.Canvas.Brush.Color := clTransparent;
//  PNG.Canvas.Brush.Color := clWHITE;
//  PNG.Canvas.FillRect(PNG.Canvas.ClipRect);
  // PNG.TransparentColor := clWhite;
  // PNG.TransparencyMode := ptmPartial;
  PNG.CreateAlpha;

  with PNG.Canvas.Font do
  begin
    Color := clWhite;
    Height := -11;
    Name := 'Arial Unicode MS';
    Orientation := 0;
    Pitch := fpDefault;
    Size := 8;
  end;

  // DrawText(PNG.Canvas,PNG.Canvas.ClipRect,'TEXT');


  // ResetAlpha(PNG);

  iCaption.Picture.Graphic := PNG;
  // iBlank := TBitmap.Create;
  // iBlank.Width := 300;
  // iBlank.Height := 300;
  // iBlank.Canvas.Brush.Color := clWhite;
  // iBlank.Canvas.FillRect(Rect(0,0,300,300));
  FPThread := TPreviewThread.Create(true);
  FPThread.FHTTP := MainForm.CreateHTTP(-1);
  FPThread.Form := Self;
  FPThread.FImage := iPreview;
  iPreview.Picture.Icon.Handle := LoadIcon(hInstance, 'ZIMAGE');
  if not preview_window_drag then
  begin
    Left := preview_window_undrag_left;
    Top := preview_window_undrag_top;
  end;

end;

procedure TfPreview.FormDestroy(Sender: TObject);
begin
  fPreview := nil;
end;

procedure TfPreview.FormHide(Sender: TObject);
begin
  try
    if Assigned(FPThread) then
    begin
      FPThread.FHTTP.Disconnect;
      furl := '';
    end;
  except
    furl := '';
  end;
end;

end.
