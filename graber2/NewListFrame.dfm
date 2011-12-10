object fNewList: TfNewList
  Left = 0
  Top = 0
  Width = 476
  Height = 330
  Align = alClient
  TabOrder = 0
  object VSplitter: TcxSplitter
    AlignWithMargins = True
    Left = 153
    Top = 34
    Width = 8
    Height = 293
    Margins.Left = 0
    Margins.Right = 0
    MinSize = 150
    Control = gRes
    ExplicitLeft = 137
    ExplicitTop = 42
    ExplicitHeight = 288
  end
  object pButtons: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 470
    Height = 25
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitLeft = 0
    ExplicitTop = 0
    ExplicitWidth = 476
    object btnOk: TcxButton
      Left = 0
      Top = 0
      Width = 75
      Height = 25
      Caption = 'btnOk'
      TabOrder = 0
      OnClick = btnOkClick
    end
    object btnCancel: TcxButton
      Left = 81
      Top = 0
      Width = 75
      Height = 25
      Caption = 'btnCancel'
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
  object gRes: TcxGrid
    AlignWithMargins = True
    Left = 3
    Top = 34
    Width = 150
    Height = 293
    Margins.Right = 0
    Align = alLeft
    TabOrder = 2
    object gResTableView1: TcxGridTableView
      NavigatorButtons.ConfirmDelete = False
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      DataController.Data = {
        8C0000000F00000044617461436F6E74726F6C6C657231020000001200000054
        6378537472696E6756616C75655479706512000000546378537472696E675661
        6C75655479706503000000445855464D540000050000004900740065006D0031
        0001445855464D540000050000004900740065006D00320001445855464D5400
        00050000004900740065006D00330001}
      NewItemRow.SeparatorWidth = 2
      OptionsCustomize.ColumnFiltering = False
      OptionsCustomize.ColumnGrouping = False
      OptionsCustomize.ColumnMoving = False
      OptionsCustomize.ColumnSorting = False
      OptionsView.ColumnAutoWidth = True
      OptionsView.GroupByBox = False
      OptionsView.Header = False
      object gResTableView1Column1: TcxGridColumn
        PropertiesClassName = 'TcxLabelProperties'
        Options.Filtering = False
        Options.ShowEditButtons = isebAlways
      end
      object gResTableView1Column2: TcxGridColumn
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkEllipsis
          end>
        Properties.ViewStyle = vsButtonsAutoWidth
        MinWidth = 19
        Options.ShowEditButtons = isebAlways
        Options.HorzSizing = False
        Options.Moving = False
        Options.Sorting = False
        Width = 19
      end
    end
    object gResTableView2: TcxGridTableView
      NavigatorButtons.ConfirmDelete = False
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsView.ColumnAutoWidth = True
      OptionsView.GroupByBox = False
      OptionsView.Header = False
    end
    object gResLevel1: TcxGridLevel
      GridView = gResTableView1
    end
    object gResLevel2: TcxGridLevel
      GridView = gResTableView2
    end
  end
end
