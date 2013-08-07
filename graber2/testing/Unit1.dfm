object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 298
  ClientWidth = 447
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    447
    298)
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 8
    Top = 111
    Width = 431
    Height = 155
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object Button3: TButton
    Left = 170
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Button3'
    Enabled = False
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button2: TButton
    Left = 89
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Button2'
    TabOrder = 3
    OnClick = Button2Click
  end
  object Button4: TButton
    Left = 251
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Button4'
    Enabled = False
    TabOrder = 4
    OnClick = Button4Click
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 272
    Width = 431
    Height = 17
    TabOrder = 5
  end
  object Edit1: TEdit
    Left = 8
    Top = 82
    Width = 345
    Height = 21
    TabOrder = 6
    Text = 'Edit1'
  end
  object Button5: TButton
    Left = 359
    Top = 80
    Width = 75
    Height = 25
    Caption = 'Button5'
    TabOrder = 7
    OnClick = Button5Click
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 160
    Top = 64
  end
  object OpenDialog1: TOpenDialog
    Left = 304
    Top = 120
  end
end
