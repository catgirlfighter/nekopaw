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
    LookAndFeel.NativeStyle = False
    object vChilds: TcxGridDBTableView
      NavigatorButtons.ConfirmDelete = False
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
    end
    object vGrid1: TcxGridDBTableView
      NavigatorButtons.ConfirmDelete = False
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
      NavigatorButtons.ConfirmDelete = False
      OnEditValueChanged = vGridEditValueChanged
      OnFocusedRecordChanged = vGrid1FocusedRecordChanged
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
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
    object iTextEdit: TcxEditRepositoryTextItem
      Properties.AutoSelect = False
      Properties.ReadOnly = True
    end
    object iPicChecker: TcxEditRepositoryCheckBoxItem
      Properties.ImmediatePost = True
    end
    object iCheckBox: TcxEditRepositoryCheckBoxItem
      Properties.ReadOnly = True
    end
    object iPBar: TcxEditRepositoryProgressBar
      Properties.AnimationPath = cxapPingPong
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
          ItemName = 'bbColumns'
        end
        item
          Visible = True
          ItemName = 'bbFilter'
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
  end
  object GridPopup: TcxGridPopupMenu
    Grid = Grid
    PopupMenus = <>
    Left = 104
    Top = 200
  end
end
