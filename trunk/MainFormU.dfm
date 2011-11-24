object mf: Tmf
  Left = 0
  Top = 0
  Caption = 'nekopaw grabber'
  ClientHeight = 453
  ClientWidth = 642
  Color = clBtnFace
  Constraints.MinHeight = 480
  Constraints.MinWidth = 640
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    642
    453)
  PixelsPerInch = 96
  TextHeight = 13
  object ds: TdxDockSite
    Left = 0
    Top = 0
    Width = 642
    Height = 453
    Align = alClient
    DockType = 0
    OriginalWidth = 642
    OriginalHeight = 453
    object dxLayoutDockSite3: TdxLayoutDockSite
      Left = 0
      Top = 0
      Width = 618
      Height = 429
      DockType = 1
      OriginalWidth = 300
      OriginalHeight = 200
      object dxLayoutDockSite1: TdxLayoutDockSite
        Left = 185
        Top = 0
        Width = 433
        Height = 429
        DockType = 1
        OriginalWidth = 300
        OriginalHeight = 200
        object dxLayoutDockSite5: TdxLayoutDockSite
          Left = 0
          Top = 0
          Width = 433
          Height = 429
          DockType = 1
          OriginalWidth = 300
          OriginalHeight = 200
        end
        object dpGrid: TdxDockPanel
          Left = 0
          Top = 0
          Width = 433
          Height = 429
          ParentShowHint = False
          ShowHint = False
          AllowFloating = False
          AutoHide = False
          Caption = 'dpGrid'
          CaptionButtons = [cbClose]
          OnCloseQuery = dpGridCloseQuery
          DockType = 1
          OriginalWidth = 185
          OriginalHeight = 140
          object Grid: TcxGrid
            Left = 0
            Top = 0
            Width = 429
            Height = 405
            Align = alClient
            TabOrder = 0
            object tvmMain: TcxGridTableView
              NavigatorButtons.ConfirmDelete = False
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsView.ColumnAutoWidth = True
              OptionsView.GroupByBox = False
              object tvmMainChck: TcxGridColumn
                DataBinding.ValueType = 'Boolean'
                Options.Filtering = False
                Options.FilteringFilteredItemsList = False
                Options.FilteringMRUItemsList = False
                Options.FilteringPopup = False
                Options.FilteringPopupMultiSelect = False
                Options.GroupFooters = False
                Options.Grouping = False
                Options.HorzSizing = False
                Options.Sorting = False
                Width = 20
              end
              object tvmMainDName: TcxGridColumn
                PropertiesClassName = 'TcxTextEditProperties'
                Properties.ReadOnly = True
                Options.Moving = False
                Options.Sorting = False
              end
            end
            object tvChild: TcxGridTableView
              NavigatorButtons.ConfirmDelete = False
              DataController.Summary.DefaultGroupSummaryItems = <>
              DataController.Summary.FooterSummaryItems = <>
              DataController.Summary.SummaryGroups = <>
              OptionsView.ColumnAutoWidth = True
              OptionsView.GroupByBox = False
              OptionsView.Header = False
              object tvChildChck: TcxGridColumn
                DataBinding.ValueType = 'Boolean'
                Options.Filtering = False
                Options.FilteringFilteredItemsList = False
                Options.FilteringMRUItemsList = False
                Options.FilteringPopup = False
                Options.FilteringPopupMultiSelect = False
                Options.IncSearch = False
                Options.GroupFooters = False
                Options.Grouping = False
                Options.HorzSizing = False
                Options.Moving = False
                Options.Sorting = False
                Width = 20
              end
              object tvChildDName: TcxGridColumn
                PropertiesClassName = 'TcxTextEditProperties'
                Properties.ReadOnly = True
                Options.Moving = False
                Options.Sorting = False
              end
            end
            object gLevel1: TcxGridLevel
              GridView = tvmMain
              Options.DetailFrameWidth = 0
              object gLevel2: TcxGridLevel
                GridView = tvChild
                OnGetGridView = gLevel2GetGridView
              end
            end
          end
        end
      end
      object dxVertContainerDockSite2: TdxVertContainerDockSite
        Left = 0
        Top = 0
        Width = 185
        Height = 429
        Visible = False
        ActiveChildIndex = -1
        AllowFloating = True
        AutoHide = False
        DockType = 2
        OriginalWidth = 185
        OriginalHeight = 140
        object dpTags: TdxDockPanel
          Left = -185
          Top = 0
          Width = 185
          Height = 429
          Visible = False
          AllowFloating = False
          AutoHide = True
          Caption = 'dpTags'
          CaptionButtons = [cbHide]
          ExplicitLeft = 0
          AutoHidePosition = 0
          DockType = 3
          OriginalWidth = 185
          OriginalHeight = 183
        end
        object dpPicInfo: TdxDockPanel
          Left = -185
          Top = 0
          Width = 185
          Height = 429
          Visible = False
          AllowFloating = False
          AutoHide = True
          Caption = 'dpPicInfo'
          CaptionButtons = [cbHide]
          ExplicitLeft = 0
          AutoHidePosition = 0
          DockType = 1
          OriginalWidth = 185
          OriginalHeight = 246
        end
      end
    end
    object dxTabContainerDockSite1: TdxTabContainerDockSite
      Left = 0
      Top = 0
      Width = 0
      Height = 140
      Visible = False
      ActiveChildIndex = 0
      AllowFloating = True
      AutoHide = True
      CaptionButtons = [cbMaximize, cbHide]
      AutoHidePosition = 3
      DockType = 5
      OriginalWidth = 185
      OriginalHeight = 140
      object dpProgressLog: TdxDockPanel
        Left = 0
        Top = 0
        Width = 0
        Height = 116
        AllowFloating = True
        AutoHide = False
        Caption = 'dpProgressLog'
        CaptionButtons = [cbHide]
        DockType = 1
        OriginalWidth = 185
        OriginalHeight = 140
      end
      object dpErrorLog: TdxDockPanel
        Left = 0
        Top = 0
        Width = 0
        Height = 116
        AllowFloating = True
        AutoHide = False
        Caption = 'dpErrorLog'
        CaptionButtons = [cbHide]
        DockType = 1
        OriginalWidth = 185
        OriginalHeight = 140
      end
    end
  end
  object ActionList: TActionList
    Left = 576
    Top = 8
    object aLNew: TAction
      Category = 'List'
      Caption = 'Create new list'
      OnExecute = aLNewExecute
    end
    object aLLoad: TAction
      Category = 'List'
      Caption = 'Load saved list'
    end
    object aSettings: TAction
      Caption = 'Settings'
    end
    object aIAdvanced: TAction
      Category = 'Interface'
      Caption = 'Advanced interface'
    end
    object aISimple: TAction
      Category = 'Interface'
      Caption = 'Simple interface'
    end
  end
  object DockManager: TdxDockingManager
    AutoHideInterval = 0
    AutoShowInterval = 1000
    Color = clBtnFace
    DefaultHorizContainerSiteProperties.Dockable = True
    DefaultHorizContainerSiteProperties.ImageIndex = -1
    DefaultVertContainerSiteProperties.Dockable = True
    DefaultVertContainerSiteProperties.ImageIndex = -1
    DefaultTabContainerSiteProperties.CaptionButtons = [cbHide]
    DefaultTabContainerSiteProperties.Dockable = True
    DefaultTabContainerSiteProperties.ImageIndex = -1
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ViewStyle = vsNET
    Left = 528
    Top = 8
  end
end
