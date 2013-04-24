object fmNewsv2: TfmNewsv2
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'fmNewsv2'
  ClientHeight = 361
  ClientWidth = 578
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
  object tlList: TcxTreeList
    Left = 0
    Top = 41
    Width = 153
    Height = 320
    Align = alLeft
    Bands = <
      item
      end>
    Navigator.Buttons.CustomButtons = <>
    OptionsData.CancelOnExit = False
    OptionsData.Editing = False
    OptionsData.Deleting = False
    OptionsView.ColumnAutoWidth = True
    OptionsView.Headers = False
    TabOrder = 0
    OnFocusedNodeChanged = tlListFocusedNodeChanged
    object tlListColumn1: TcxTreeListColumn
      DataBinding.ValueType = 'String'
      Position.ColIndex = 0
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 578
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 1
    object bClose: TcxButton
      Left = 8
      Top = 9
      Width = 75
      Height = 25
      Caption = 'bClose'
      TabOrder = 0
      OnClick = bCloseClick
    end
  end
  object eText: TcxRichEdit
    Left = 153
    Top = 41
    Align = alClient
    ParentFont = False
    Properties.Alignment = taLeftJustify
    Properties.HideSelection = False
    Properties.ReadOnly = True
    Properties.ScrollBars = ssVertical
    Properties.SelectionBar = True
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -13
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 2
    Height = 320
    Width = 425
  end
end
