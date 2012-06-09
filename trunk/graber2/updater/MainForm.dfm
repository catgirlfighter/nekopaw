object mf: Tmf
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'nekopaw updater'
  ClientHeight = 239
  ClientWidth = 289
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    289
    239)
  PixelsPerInch = 96
  TextHeight = 13
  object pttl: TProgressBar
    Left = 8
    Top = 8
    Width = 226
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object pcurr: TProgressBar
    Left = 8
    Top = 31
    Width = 226
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
  end
  object bOk: TButton
    Left = 240
    Top = 8
    Width = 41
    Height = 40
    Anchors = [akTop, akRight]
    Caption = 'Ok'
    Default = True
    Enabled = False
    ModalResult = 1
    TabOrder = 2
    OnClick = bOkClick
  end
  object lLog: TListBox
    Left = 8
    Top = 54
    Width = 273
    Height = 177
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 13
    TabOrder = 3
    ExplicitWidth = 249
  end
  object XPManifest1: TXPManifest
    Left = 136
    Top = 104
  end
end
