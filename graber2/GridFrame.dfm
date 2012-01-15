object fGrid: TfGrid
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object Grid: TcxGrid
    Left = 0
    Top = 0
    Width = 451
    Height = 284
    Align = alClient
    TabOrder = 0
    LookAndFeel.NativeStyle = False
    ExplicitHeight = 304
    object vChilds: TcxGridDBTableView
      NavigatorButtons.ConfirmDelete = False
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
    end
    object vGrid1: TcxGridTableView
      NavigatorButtons.ConfirmDelete = False
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsView.ColumnAutoWidth = True
      OptionsView.ExpandButtonsForEmptyDetails = False
      OptionsView.Footer = True
    end
    object vGrid: TcxGridDBTableView
      NavigatorButtons.ConfirmDelete = False
      DataController.DataSource = ds
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsData.Deleting = False
      OptionsData.Inserting = False
      OptionsView.ColumnAutoWidth = True
      OptionsView.ExpandButtonsForEmptyDetails = False
    end
    object GridLevel1: TcxGridLevel
      GridView = vGrid
      Options.TabsForEmptyDetails = False
      object GridLevel2: TcxGridLevel
        GridView = vChilds
      end
    end
  end
  object sBar: TdxStatusBar
    Left = 0
    Top = 284
    Width = 451
    Height = 20
    Panels = <
      item
        PanelStyleClassName = 'TdxStatusBarTextPanelStyle'
        MinWidth = 50
      end
      item
        PanelStyleClassName = 'TdxStatusBarTextPanelStyle'
      end>
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ExplicitTop = 259
  end
  object cxEditRepository1: TcxEditRepository
    Left = 240
    Top = 104
    object iTextEdit: TcxEditRepositoryTextItem
      Properties.ReadOnly = True
    end
  end
  object md: TdxMemData
    Indexes = <>
    SortOptions = []
    Left = 72
    Top = 80
  end
  object ds: TDataSource
    AutoEdit = False
    DataSet = md
    Left = 72
    Top = 128
  end
end
