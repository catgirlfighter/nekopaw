object fmAbout: TfmAbout
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'fmAbout'
  ClientHeight = 337
  ClientWidth = 401
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object cxLabel1: TcxLabel
    Left = 8
    Top = 8
    Caption = 'cxLabel1'
  end
  object cxLabel2: TcxLabel
    Left = 8
    Top = 31
    Caption = 
      'Thanks to all Anonymous and Steves Ballmers for new ideas and tr' +
      'oubleshooting '
  end
  object cxLabel3: TcxLabel
    Left = 8
    Top = 70
    AutoSize = False
    Caption = 'For new versions, with questions, suggestions and troubles'
    Properties.WordWrap = True
    Height = 19
    Width = 392
  end
  object cxLabel4: TcxLabel
    Left = 24
    Top = 87
    Caption = 'check project homepage'
  end
  object cxLabel5: TcxLabel
    Left = 40
    Top = 118
    Cursor = crHandPoint
    Caption = 'http://code.google.com/p/nekopaw/'
    Style.BorderColor = clBtnShadow
    Style.Shadow = False
    Style.TextColor = clBlue
    Style.TextStyle = [fsUnderline]
    Properties.LineOptions.Alignment = cxllaBottom
    OnClick = cxLabel5Click
  end
end
