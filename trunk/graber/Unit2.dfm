object connsets: Tconnsets
  Left = 629
  Top = 133
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
  ClientHeight = 231
  ClientWidth = 220
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 220
    Height = 199
    ActivePage = TabSheet3
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'Imageboard Access'
    end
    object TabSheet2: TTabSheet
      Caption = 'Downloding'
      ImageIndex = 1
    end
    object TabSheet3: TTabSheet
      Caption = 'Proxy'
      ImageIndex = 2
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 199
    Width = 220
    Height = 32
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Button1: TButton
      Left = 4
      Top = 3
      Width = 83
      Height = 25
      Caption = 'Ok'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object Button2: TButton
      Left = 131
      Top = 3
      Width = 82
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
end
