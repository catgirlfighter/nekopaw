object fmSettings: TfmSettings
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'fmSettings'
  ClientHeight = 265
  ClientWidth = 497
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object gbProxy: TcxGroupBox
    Left = 8
    Top = 8
    Caption = 'gbProxy'
    TabOrder = 0
    Height = 137
    Width = 281
    object eProxyHost: TcxTextEdit
      Left = 16
      Top = 51
      TabOrder = 0
      Width = 121
    end
    object chbHTTPProxy: TcxCheckBox
      Left = 16
      Top = 24
      Caption = 'chbHTTPProxy'
      TabOrder = 1
      Width = 121
    end
    object eProxyPort: TcxSpinEdit
      Left = 16
      Top = 78
      TabOrder = 2
      Width = 121
    end
    object chbProxyAuth: TcxCheckBox
      Left = 143
      Top = 24
      Caption = 'chbProxyAuth'
      TabOrder = 3
      Width = 121
    end
    object eProxyLogin: TcxTextEdit
      Left = 143
      Top = 51
      TabOrder = 4
      Width = 121
    end
    object eProxyPwd: TcxTextEdit
      Left = 143
      Top = 78
      TabOrder = 5
      Width = 121
    end
    object chbProxySavePwd: TcxCheckBox
      Left = 143
      Top = 105
      Caption = 'chbProxySavePwd'
      TabOrder = 6
      Width = 121
    end
  end
  object gbWork: TcxGroupBox
    Left = 8
    Top = 151
    Caption = 'gbWork'
    TabOrder = 1
    Height = 106
    Width = 281
    object lThreadCount: TcxLabel
      Left = 16
      Top = 24
      Caption = 'lThreadCount'
    end
    object eThreadCount: TcxSpinEdit
      Left = 143
      Top = 23
      Properties.MaxValue = 50.000000000000000000
      Properties.MinValue = 1.000000000000000000
      TabOrder = 1
      Value = 1
      Width = 121
    end
    object chbDebugMode: TcxCheckBox
      Left = 16
      Top = 74
      Caption = 'chbDebugMode'
      TabOrder = 2
      Width = 121
    end
  end
  object lRetries: TcxLabel
    Left = 24
    Top = 202
    Caption = 'lRetries'
  end
  object eRetries: TcxSpinEdit
    Left = 151
    Top = 201
    TabOrder = 3
    Width = 121
  end
  object cxGroupBox1: TcxGroupBox
    Left = 295
    Top = 8
    Caption = 'gbWindow'
    TabOrder = 4
    Height = 137
    Width = 194
    object chbTrayIcon: TcxCheckBox
      Left = 16
      Top = 24
      Caption = 'chbTrayIcon'
      TabOrder = 0
      Width = 121
    end
    object chbHide: TcxCheckBox
      Left = 16
      Top = 51
      Caption = 'chbHide'
      TabOrder = 1
      Width = 121
    end
    object chbKeepInstance: TcxCheckBox
      Left = 16
      Top = 78
      Caption = 'chbKeepInstance'
      TabOrder = 2
      Width = 121
    end
    object chbSaveConfirm: TcxCheckBox
      Left = 16
      Top = 105
      Caption = 'chbSaveConfirm'
      TabOrder = 3
      Width = 121
    end
  end
  object btnOk: TcxButton
    Left = 391
    Top = 201
    Width = 98
    Height = 25
    Caption = 'btnOk'
    Default = True
    ModalResult = 1
    TabOrder = 5
  end
  object btnCancel: TcxButton
    Left = 391
    Top = 232
    Width = 98
    Height = 25
    Cancel = True
    Caption = 'btnCancel'
    ModalResult = 2
    TabOrder = 6
  end
end
