object fGrid: TfGrid
  Left = 0
  Top = 0
  Width = 610
  Height = 385
  Align = alClient
  TabOrder = 0
  object Grid: TcxGrid
    Left = 0
    Top = 0
    Width = 610
    Height = 385
    Align = alClient
    TabOrder = 0
    object vGrid: TcxGridDBTableView
      NavigatorButtons.ConfirmDelete = False
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
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
  object cds: TClientDataSet
    Aggregates = <>
    FieldDefs = <>
    IndexDefs = <>
    Params = <>
    StoreDefs = True
    Left = 48
    Top = 121
    object cdsresname: TStringField
      FieldName = 'resname'
      Size = 128
    end
  end
end
