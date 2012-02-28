object mf: Tmf
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'nekopaw updater'
  ClientHeight = 97
  ClientWidth = 449
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object gttl: TGauge
    Left = 8
    Top = 30
    Width = 433
    Height = 25
    Progress = 0
  end
  object gfile: TGauge
    Left = 8
    Top = 61
    Width = 433
    Height = 25
    Progress = 0
  end
  object ltext: TLabel
    Left = 8
    Top = 11
    Width = 433
    Height = 13
    AutoSize = False
  end
end
