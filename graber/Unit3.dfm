object fPreview: TfPreview
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'Preview'
  ClientHeight = 150
  ClientWidth = 150
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnHide = FormHide
  PixelsPerInch = 96
  TextHeight = 13
  object iPreview: TImage
    Left = 0
    Top = 0
    Width = 150
    Height = 150
    Align = alClient
    Center = True
    ExplicitLeft = 42
    ExplicitTop = 3
  end
  object iCaption: TImage
    Left = 0
    Top = 137
    Width = 150
    Height = 13
    Visible = False
  end
  object timer: TTimer
    Enabled = False
    Interval = 500
    OnTimer = timerTimer
    Left = 56
    Top = 48
  end
end
