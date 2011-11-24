object fGetList: TfGetList
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'fGetList'
  ClientHeight = 261
  ClientWidth = 340
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    340
    261)
  PixelsPerInch = 96
  TextHeight = 13
  object btnOk: TcxButton
    Left = 255
    Top = 197
    Width = 77
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'btnOk'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TcxButton
    Left = 255
    Top = 228
    Width = 77
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Cancel = True
    Caption = 'btnCancel'
    ModalResult = 2
    TabOrder = 1
  end
  object btnSettings: TcxButton
    Left = 255
    Top = 8
    Width = 77
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'btnAdd'
    TabOrder = 2
  end
  object btnEdit: TcxButton
    Left = 255
    Top = 39
    Width = 77
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'btnEdit'
    TabOrder = 3
  end
  object btnDelete: TcxButton
    Left = 255
    Top = 70
    Width = 77
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'btnDelete'
    TabOrder = 4
  end
  object lbList: TdxImageListBox
    Left = 8
    Top = 8
    Width = 241
    Height = 245
    Alignment = taLeftJustify
    ImageAlign = dxliLeft
    ItemHeight = 0
    MultiLines = False
    VertAlignment = tvaCenter
    TabOrder = 5
    SaveStrings = ()
  end
end
