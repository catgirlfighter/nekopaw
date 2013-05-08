object fTextEdit: TfTextEdit
  Left = 0
  Top = 0
  Caption = 'fTextEdit'
  ClientHeight = 311
  ClientWidth = 403
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
  object mText: TcxMemo
    Left = 0
    Top = 0
    Align = alClient
    Properties.ScrollBars = ssBoth
    TabOrder = 0
    Height = 275
    Width = 403
  end
  object Panel1: TPanel
    Left = 0
    Top = 275
    Width = 403
    Height = 36
    Align = alBottom
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 1
    object btnOk: TcxButton
      Left = 8
      Top = 6
      Width = 75
      Height = 25
      Caption = 'btnOk'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TcxButton
      Left = 89
      Top = 6
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'btnCancel'
      ModalResult = 2
      TabOrder = 1
    end
    object btnClear: TcxButton
      Left = 320
      Top = 6
      Width = 75
      Height = 25
      Caption = 'btnClear'
      TabOrder = 2
      OnClick = btnClearClick
    end
  end
end
