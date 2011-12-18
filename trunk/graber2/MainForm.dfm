object mf: Tmf
  Left = 0
  Top = 0
  Caption = 'nekopaw grabber'
  ClientHeight = 373
  ClientWidth = 608
  Color = clBtnFace
  Constraints.MinHeight = 400
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
    Top = 0
    Width = 608
    Height = 373
    Visible = False
    Align = alClient
    DockType = 0
    OriginalWidth = 608
    OriginalHeight = 373
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
    object aStart: TAction
      Caption = 'aStart'
      OnExecute = aStartExecute
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
    ViewStyle = vsUseLookAndFeel
    Left = 448
    Top = 40
  end
  object BarManager: TdxBarManager
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
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
      0
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
          ItemName = 'dxBarButton1'
        end>
      OneOnRow = True
      Row = 0
      UseOwnFont = False
      Visible = False
      WholeRow = False
    end
    object dxBarButton1: TdxBarButton
      Caption = 'New Item'
      Category = 0
      Hint = 'New Item'
      Visible = ivAlways
    end
  end
end
