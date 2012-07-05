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
    Top = 26
    Width = 451
    Height = 258
    Align = alClient
    TabOrder = 0
    object vChilds: TcxGridDBTableView
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
    end
    object vGrid1: TcxGridDBTableView
      OnFocusedRecordChanged = vGrid1FocusedRecordChanged
      DataController.Summary.DefaultGroupSummaryItems = <
        item
          Kind = skCount
          DisplayText = 'Count:'
        end>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsData.Deleting = False
      OptionsData.Inserting = False
      OptionsView.ColumnAutoWidth = True
      OptionsView.ExpandButtonsForEmptyDetails = False
      OptionsView.HeaderEndEllipsis = True
    end
    object vGrid: TcxGridTableView
      OnEditValueChanged = vGridEditValueChanged
      OnFocusedRecordChanged = vGrid1FocusedRecordChanged
      DataController.Summary.DefaultGroupSummaryItems = <
        item
          Kind = skCount
          DisplayText = 'count'
        end>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsSelection.MultiSelect = True
      OptionsView.ColumnAutoWidth = True
      OptionsView.ExpandButtonsForEmptyDetails = False
    end
    object GridLevel1: TcxGridLevel
      GridView = vGrid
      Options.TabsForEmptyDetails = False
      object GridLevel2: TcxGridLevel
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
  end
  object BarControl: TdxBarDockControl
    Left = 0
    Top = 0
    Width = 451
    Height = 26
    Align = dalTop
    BarManager = BarManager
  end
  object cxEditRepository1: TcxEditRepository
    Left = 240
    Top = 104
    object iPicChecker: TcxEditRepositoryCheckBoxItem
      Properties.ImmediatePost = True
    end
    object iCheckBox: TcxEditRepositoryCheckBoxItem
      Properties.ReadOnly = True
    end
    object iPBar: TcxEditRepositoryProgressBar
      Properties.AnimationPath = cxapPingPong
    end
    object iFloatEdit: TcxEditRepositoryCurrencyItem
      Properties.DisplayFormat = '0.00'
      Properties.EditFormat = '0.00'
      Properties.ReadOnly = True
      Properties.UseDisplayFormatWhenEditing = True
    end
    object iLabel: TcxEditRepositoryLabel
    end
  end
  object BarManager: TdxBarManager
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    Categories.Strings = (
      'Default')
    Categories.ItemsVisibles = (
      2)
    Categories.Visibles = (
      True)
    PopupMenuLinks = <>
    UseSystemFont = True
    Left = 208
    Top = 192
    DockControlHeights = (
      0
      0
      0
      0)
    object TableActions: TdxBar
      Caption = 'Table'
      CaptionButtons = <>
      DockControl = BarControl
      DockedDockControl = BarControl
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 461
      FloatTop = 0
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'siCheck'
        end
        item
          Visible = True
          ItemName = 'siUncheck'
        end
        item
          Visible = True
          ItemName = 'bbColumns'
        end
        item
          Visible = True
          ItemName = 'bbFilter'
        end
        item
          Visible = True
          ItemName = 'bbAdditional'
        end>
      NotDocking = [dsNone, dsLeft, dsTop, dsRight, dsBottom]
      OneOnRow = True
      Row = 0
      UseOwnFont = False
      UseRestSpace = True
      Visible = True
      WholeRow = False
    end
    object bbColumns: TdxBarButton
      Caption = 'bbColumns'
      Category = 0
      Hint = 'bbColumns'
      Visible = ivAlways
      OnClick = bbColumnsClick
    end
    object bbFilter: TdxBarButton
      Caption = 'bbFilter'
      Category = 0
      Hint = 'bbFilter'
      Visible = ivAlways
      ButtonStyle = bsChecked
      OnClick = bbFilterClick
    end
    object dxBarButton1: TdxBarButton
      Caption = 'New Button'
      Category = 0
      Hint = 'New Button'
      Visible = ivAlways
    end
    object bbSelect: TdxBarButton
      Caption = 'bbSelect'
      Category = 0
      Hint = 'bbSelect'
      Visible = ivAlways
    end
    object bbUnselect: TdxBarButton
      Caption = 'bbUnselect'
      Category = 0
      Hint = 'bbUnselect'
      Visible = ivAlways
    end
    object siCheck: TdxBarSubItem
      Caption = 'siCheck'
      Category = 0
      Visible = ivAlways
      ItemLinks = <
        item
          Visible = True
          ItemName = 'bbCheckAll'
        end
        item
          Visible = True
          ItemName = 'bbCheckSelected'
        end
        item
          Visible = True
          ItemName = 'bbCheckFiltered'
        end
        item
          Visible = True
          ItemName = 'bbInverseChecked'
        end>
    end
    object siUncheck: TdxBarSubItem
      Caption = 'siUncheck'
      Category = 0
      Visible = ivAlways
      ItemLinks = <
        item
          Visible = True
          ItemName = 'bbUncheckAll'
        end
        item
          Visible = True
          ItemName = 'bbUncheckSelected'
        end
        item
          Visible = True
          ItemName = 'bbUncheckFiltered'
        end>
    end
    object dxBarSubItem3: TdxBarSubItem
      Caption = 'New SubItem'
      Category = 0
      Visible = ivAlways
      ItemLinks = <>
    end
    object dxBarSubItem4: TdxBarSubItem
      Caption = 'New SubItem'
      Category = 0
      Visible = ivAlways
      ItemLinks = <>
    end
    object bbCheckAll: TdxBarButton
      Caption = 'bbCheckAll'
      Category = 0
      Hint = 'bbCheckAll'
      Visible = ivAlways
      OnClick = bbCheckAllClick
    end
    object bbCheckSelected: TdxBarButton
      Caption = 'bbCheckSelected'
      Category = 0
      Hint = 'bbCheckSelected'
      Visible = ivAlways
      OnClick = bbCheckSelectedClick
    end
    object bbCheckFiltered: TdxBarButton
      Caption = 'bbCheckFiltered'
      Category = 0
      Hint = 'bbCheckFiltered'
      Visible = ivAlways
      OnClick = bbCheckFilteredClick
    end
    object dxBarButton2: TdxBarButton
      Caption = 'New Button'
      Category = 0
      Hint = 'New Button'
      Visible = ivAlways
    end
    object bbInverseChecked: TdxBarButton
      Caption = 'bbInverseChecked'
      Category = 0
      Hint = 'bbInverseChecked'
      Visible = ivAlways
      OnClick = bbInverseCheckedClick
    end
    object bbUncheckAll: TdxBarButton
      Caption = 'bbUncheckAll'
      Category = 0
      Hint = 'bbUncheckAll'
      Visible = ivAlways
      OnClick = bbUncheckAllClick
    end
    object bbUncheckSelected: TdxBarButton
      Caption = 'bbUncheckSelected'
      Category = 0
      Hint = 'bbUncheckSelected'
      Visible = ivAlways
      OnClick = bbUncheckSelectedClick
    end
    object bbUncheckFiltered: TdxBarButton
      Caption = 'bbUncheckFiltered'
      Category = 0
      Hint = 'bbUncheckFiltered'
      Visible = ivAlways
      OnClick = bbUncheckFilteredClick
    end
    object dxBarListItem1: TdxBarListItem
      Caption = 'New Item'
      Category = 0
      Visible = ivAlways
    end
    object cxBarEditItem1: TcxBarEditItem
      Caption = 'New Item'
      Category = 0
      Hint = 'New Item'
      Visible = ivAlways
      PropertiesClassName = 'TcxCheckBoxProperties'
    end
    object cxBarEditItem2: TcxBarEditItem
      Category = 0
      Visible = ivAlways
      ShowCaption = True
      PropertiesClassName = 'TcxCheckBoxProperties'
    end
    object bbAdditional: TdxBarSubItem
      Caption = 'bbAdditional'
      Category = 0
      Visible = ivAlways
      ItemLinks = <
        item
          Visible = True
          ItemName = 'bbDALF'
        end>
    end
    object cxBarEditItem3: TcxBarEditItem
      Caption = 'New Item'
      Category = 0
      Hint = 'New Item'
      Visible = ivAlways
      PropertiesClassName = 'TcxCheckBoxProperties'
    end
    object bbDALF: TdxBarButton
      Caption = 'bbDALF'
      Category = 0
      Hint = 'bbDALF'
      Visible = ivAlways
      ButtonStyle = bsChecked
      OnClick = bbDALFClick
    end
  end
  object GridPopup: TcxGridPopupMenu
    Grid = Grid
    PopupMenus = <>
    Left = 104
    Top = 200
  end
end
