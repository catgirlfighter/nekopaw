object fStoping: TfStoping
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsToolWindow
  Caption = 'Stoping...'
  ClientHeight = 100
  ClientWidth = 180
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Lbl: TLabel
    Left = 8
    Top = 24
    Width = 164
    Height = 13
    AutoSize = False
    Caption = 'Waiting...'
  end
  object Button: TButton
    Left = 48
    Top = 56
    Width = 75
    Height = 25
    Caption = 'Force'
    Default = True
    ModalResult = 1
    TabOrder = 0
    OnClick = ButtonClick
  end
  object Timer: TTimer
    Enabled = False
    OnTimer = TimerTimer
    Left = 136
    Top = 56
  end
end
