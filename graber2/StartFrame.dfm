object fStart: TfStart
  Left = 0
  Top = 0
  Width = 544
  Height = 319
  Align = alClient
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  OnResize = FrameResize
  ExplicitWidth = 451
  ExplicitHeight = 304
  object iIcon: TImage
    Left = 32
    Top = 85
    Width = 300
    Height = 300
    Center = True
    Transparent = True
  end
  object bNew: TcxButton
    Left = 360
    Top = 85
    Width = 169
    Height = 25
    Caption = 'bNew'
    TabOrder = 0
    OnClick = bNewClick
  end
  object bLoad: TcxButton
    Left = 360
    Top = 129
    Width = 169
    Height = 25
    Caption = 'bLoad'
    TabOrder = 1
  end
  object bSettings: TcxButton
    Left = 360
    Top = 176
    Width = 169
    Height = 25
    Caption = 'bSettings'
    TabOrder = 2
    OnClick = bSettingsClick
  end
  object bExit: TcxButton
    Left = 360
    Top = 216
    Width = 169
    Height = 25
    Caption = 'bExit'
    TabOrder = 3
    OnClick = bExitClick
  end
end
