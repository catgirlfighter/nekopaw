object fmLogin: TfmLogin
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Authentication'
  ClientHeight = 172
  ClientWidth = 185
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lLogin: TSpTBXLabel
    Left = 8
    Top = 8
    Width = 35
    Height = 19
    Caption = 'Login:'
  end
  object eLogin: TSpTBXEdit
    Left = 8
    Top = 33
    Width = 169
    Height = 21
    TabOrder = 1
  end
  object lPassword: TSpTBXLabel
    Left = 8
    Top = 60
    Width = 56
    Height = 19
    Caption = 'Password:'
  end
  object ePassword: TSpTBXEdit
    Left = 8
    Top = 85
    Width = 169
    Height = 21
    PasswordChar = '*'
    TabOrder = 3
  end
  object Ok: TSpTBXButton
    Left = 8
    Top = 139
    Width = 65
    Height = 25
    Caption = 'Ok'
    TabOrder = 4
    Default = True
    ModalResult = 1
  end
  object Cancel: TSpTBXButton
    Left = 112
    Top = 139
    Width = 65
    Height = 25
    Caption = 'Cancel'
    TabOrder = 5
    Cancel = True
    ModalResult = 2
  end
  object chbSavePwd: TSpTBXCheckBox
    Left = 8
    Top = 112
    Width = 97
    Height = 21
    Caption = 'Save Password'
    TabOrder = 6
  end
end
