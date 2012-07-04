object fLogin: TfLogin
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'fLogin'
  ClientHeight = 97
  ClientWidth = 248
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object eLogin: TcxTextEdit
    Left = 112
    Top = 7
    TabOrder = 0
    Width = 129
  end
  object lLogin: TcxLabel
    Left = 8
    Top = 8
    Caption = 'lLogin'
    Transparent = True
  end
  object ePassword: TcxTextEdit
    Left = 112
    Top = 30
    Properties.EchoMode = eemPassword
    Properties.PasswordChar = #9679
    TabOrder = 2
    Width = 129
  end
  object lPassword: TcxLabel
    Left = 8
    Top = 31
    Caption = 'lPassword'
    Transparent = True
  end
  object bOk: TcxButton
    Left = 8
    Top = 65
    Width = 97
    Height = 25
    Caption = 'bOk'
    Default = True
    TabOrder = 4
    OnClick = bOkClick
  end
  object bCancel: TcxButton
    Left = 144
    Top = 65
    Width = 96
    Height = 25
    Caption = 'bCancel'
    TabOrder = 5
    OnClick = bCancelClick
  end
end
