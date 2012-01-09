object mf: Tmf
  Left = 0
  Top = 0
  Caption = 'nekopaw grabber'
  ClientHeight = 412
  ClientWidth = 608
  Color = clBtnFace
  Constraints.MinHeight = 450
  Constraints.MinWidth = 600
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object ds: TdxDockSite
    Left = 0
    Top = 28
    Width = 608
    Height = 384
    Align = alClient
    DockType = 0
    OriginalWidth = 608
    OriginalHeight = 384
    object dxLayoutDockSite4: TdxLayoutDockSite
      Left = 0
      Top = 0
      Width = 608
      Height = 234
      DockType = 1
      OriginalWidth = 300
      OriginalHeight = 200
      object dsTable: TdxLayoutDockSite
        Left = 150
        Top = 0
        Width = 458
        Height = 234
        DockType = 1
        OriginalWidth = 300
        OriginalHeight = 200
        object dxLayoutDockSite2: TdxLayoutDockSite
          Left = 0
          Top = 0
          Width = 458
          Height = 234
          DockType = 1
          OriginalWidth = 300
          OriginalHeight = 200
        end
        object dpTable: TdxDockPanel
          Left = 0
          Top = 0
          Width = 458
          Height = 234
          AllowFloating = True
          AutoHide = False
          Caption = 'dpTable'
          Dockable = False
          ShowCaption = False
          DockType = 1
          OriginalWidth = 185
          OriginalHeight = 140
          object pcTables: TcxPageControl
            Left = 0
            Top = 0
            Width = 454
            Height = 230
            Align = alClient
            Options = [pcoAlwaysShowGoDialogButton, pcoCloseButton, pcoGradient, pcoGradientClientArea, pcoRedrawOnResize]
            TabOrder = 0
            OnChange = pcTablesChange
            ClientRectBottom = 226
            ClientRectLeft = 4
            ClientRectRight = 450
            ClientRectTop = 4
          end
        end
      end
      object dsTags: TdxTabContainerDockSite
        Left = 0
        Top = 0
        Width = 150
        Height = 234
        ActiveChildIndex = 0
        AllowFloating = False
        AutoHide = False
        Dockable = False
        ShowCaption = False
        TabsPosition = tctpTop
        DockType = 2
        OriginalWidth = 150
        OriginalHeight = 140
        object dpTags: TdxDockPanel
          Left = 0
          Top = 0
          Width = 146
          Height = 200
          AllowFloating = True
          AutoHide = False
          Caption = 'dpTags'
          Dockable = False
          DockType = 1
          OriginalWidth = 150
          OriginalHeight = 140
        end
        object dpCurTags: TdxDockPanel
          Left = 0
          Top = 0
          Width = 146
          Height = 200
          AllowFloating = True
          AutoHide = False
          Caption = 'dpCurTags'
          Dockable = False
          DockType = 1
          OriginalWidth = 150
          OriginalHeight = 140
        end
      end
    end
    object dsLogs: TdxTabContainerDockSite
      Left = 0
      Top = 234
      Width = 608
      Height = 150
      ActiveChildIndex = 0
      AllowFloating = False
      AutoHide = False
      CaptionButtons = [cbMaximize, cbHide]
      Dockable = False
      DockType = 5
      OriginalWidth = 185
      OriginalHeight = 150
      object dpLog: TdxDockPanel
        Left = 0
        Top = 0
        Width = 604
        Height = 92
        AllowFloating = True
        AutoHide = False
        Caption = 'dpLog'
        Dockable = False
        DockType = 1
        OriginalWidth = 185
        OriginalHeight = 150
      end
      object dpErrors: TdxDockPanel
        Left = 0
        Top = 0
        Width = 604
        Height = 92
        AllowFloating = True
        AutoHide = False
        Caption = 'dpErrors'
        Dockable = False
        DockType = 1
        OriginalWidth = 185
        OriginalHeight = 150
      end
    end
  end
  object ActionList: TActionList
    Left = 496
    Top = 40
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
    object aLApplyNew: TAction
      Category = 'List'
      Caption = 'aLApplyNew'
    end
    object aLCancel: TAction
      Category = 'List'
      Caption = 'aLCancel'
    end
  end
  object DockManager: TdxDockingManager
    Color = clBtnFace
    DefaultHorizContainerSiteProperties.Dockable = True
    DefaultHorizContainerSiteProperties.ImageIndex = -1
    DefaultVertContainerSiteProperties.Dockable = True
    DefaultVertContainerSiteProperties.ImageIndex = -1
    DefaultTabContainerSiteProperties.Dockable = True
    DefaultTabContainerSiteProperties.ImageIndex = -1
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Options = [doActivateAfterDocking, doDblClickDocking, doFloatingOnTop, doTabContainerHasCaption, doTabContainerCanAutoHide, doSideContainerCanClose, doSideContainerCanAutoHide, doTabContainerCanInSideContainer, doImmediatelyHideOnAutoHide, doHideAutoHideIfActive, doRedrawOnResize]
    ViewStyle = vsUseLookAndFeel
    Left = 448
    Top = 40
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
    NotDocking = [dsNone]
    PopupMenuLinks = <>
    UseSystemFont = True
    Left = 408
    Top = 40
    DockControlHeights = (
      0
      0
      28
      0)
    object bmbMain: TdxBar
      AllowClose = False
      Caption = 'MainMenu'
      CaptionButtons = <>
      DockedDockingStyle = dsTop
      DockedLeft = 0
      DockedTop = 0
      DockingStyle = dsTop
      FloatLeft = 264
      FloatTop = 192
      FloatClientWidth = 51
      FloatClientHeight = 22
      ItemLinks = <
        item
          Visible = True
          ItemName = 'bbNew'
        end
        item
          Visible = True
          ItemName = 'bbStartList'
        end
        item
          Visible = True
          ItemName = 'bbStartDownload'
        end
        item
          Visible = True
          ItemName = 'bbStop'
        end
        item
          Visible = True
          ItemName = 'bbSettings'
        end>
      OneOnRow = True
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object bbStop: TdxBarButton
      Caption = 'bbStop'
      Category = 0
      Hint = 'bbStop'
      Visible = ivAlways
      OnClick = bbStopClick
    end
    object bbStartList: TdxBarButton
      Caption = 'bbStartGet'
      Category = 0
      Hint = 'bbStartGet'
      Visible = ivAlways
    end
    object bbStartDownload: TdxBarButton
      Caption = 'bbStartDownload'
      Category = 0
      Hint = 'bbStartDownload'
      Visible = ivAlways
    end
    object bbSettings: TdxBarButton
      Caption = 'bbSettings'
      Category = 0
      Hint = 'bbSettings'
      Visible = ivAlways
      OnClick = bbSettingsClick
    end
    object bbNew: TdxBarButton
      Caption = 'bbNew'
      Category = 0
      Hint = 'bbNew'
      Visible = ivAlways
      OnClick = bbNewClick
    end
  end
end
