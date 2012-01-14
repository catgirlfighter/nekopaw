object fGrid: TfGrid
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  TabOrder = 0
  object Grid: TcxGrid
    Left = 0
    Top = 0
    Width = 451
    Height = 304
    Align = alClient
    TabOrder = 0
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
    object vChilds: TcxGridDBTableView
      NavigatorButtons.ConfirmDelete = False
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
    end
    object GridLevel1: TcxGridLevel
      GridView = vGrid
      Options.TabsForEmptyDetails = False
      object GridLevel2: TcxGridLevel
        GridView = vChilds
      end
    end
  end
  object ds: TDataSource
    DataSet = md
    Left = 48
    Top = 168
  end
  object md: TdxMemData
    Indexes = <>
    SortOptions = []
    Left = 48
    Top = 128
  end
  object cxEditRepository1: TcxEditRepository
    Left = 240
    Top = 104
    object iTextEdit: TcxEditRepositoryTextItem
      Properties.ReadOnly = True
    end
  end
end
