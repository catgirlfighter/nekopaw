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
    Top = 26
    Width = 608
    Height = 386
    Align = alClient
    DockType = 0
    OriginalWidth = 608
    OriginalHeight = 386
    object dxLayoutDockSite4: TdxLayoutDockSite
      Left = 0
      Top = 0
      Width = 608
      Height = 236
      DockType = 1
      OriginalWidth = 300
      OriginalHeight = 200
      object dsTable: TdxLayoutDockSite
        Left = 150
        Top = 0
        Width = 458
        Height = 236
        DockType = 1
        OriginalWidth = 300
        OriginalHeight = 200
        object dxLayoutDockSite2: TdxLayoutDockSite
          Left = 0
          Top = 0
          Width = 458
          Height = 236
          DockType = 1
          OriginalWidth = 300
          OriginalHeight = 200
        end
        object dpTable: TdxDockPanel
          Left = 0
          Top = 0
          Width = 458
          Height = 236
          AllowFloating = False
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
            Height = 232
            Align = alClient
            Images = il
            Options = [pcoAlwaysShowGoDialogButton, pcoCloseButton, pcoGradient, pcoGradientClientArea, pcoRedrawOnResize]
            TabOrder = 0
            OnChange = pcTablesChange
            ClientRectBottom = 232
            ClientRectRight = 454
            ClientRectTop = 0
          end
        end
      end
      object dsTags: TdxTabContainerDockSite
        Left = 0
        Top = 0
        Width = 150
        Height = 236
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
          Height = 208
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
          Height = 208
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
      Top = 236
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
        Height = 102
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
        Height = 102
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
    Font.Color = clBlack
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
      26
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
          ItemName = 'bbSettings'
        end>
      OneOnRow = True
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = False
    end
    object bbStartList: TdxBarButton
      Caption = 'bbStartGet'
      Category = 0
      Hint = 'bbStartGet'
      Visible = ivAlways
      OnClick = bbStartListClick
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
  object il: TcxImageList
    FormatVersion = 1
    DesignInfo = 7340444
    ImageInfo = <
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000020203037375
          89C0B8BED6F88D92B4EE7D8494EE67687CFF68697CEE8E92ABFF8E92ABFF8E92
          ABFF8E92ABFF8E92ABFF8E92ABFF8E92ABFF8E92ABFF8E92ABFF000000003637
          3A49E1EAF3FFCBD6E9FFAFBED5FF6E7284FF595968FF8789A0FF9094AEFF8E92
          ABFF8E92ABFF8E92ABFF8E92ABFF8E92ABFF8E92ABFF8E92ABFF000000002324
          252F9EA8B6E3D7E4F4FFBAC8E0FFA7B2C7FF5A5C6BFF6E7082FF9195AFFF8E92
          ABFF8E92ABFF8E92ABFF8E92ABFF8E92ABFF8E92ABFF8E92ABFF00000000666B
          7297AAB8CFFFB7C5DCFFB2BFD6FFB4C3D9FF929BACFF595B67FF8587A0FF9194
          AEFF8E92ABFF8E92ABFF8E92ABFF8E92ABFF8E92ABFF8E92ABFF000000002627
          29378F99ACF0B1BFD8FFACBAD0FF93A0B5FFB6C5DBFF6F737DFF636475FF9094
          AEFF8F93ACFF8E92ABFF8E92ABFF8E92ABFF8E92ABFF8E92ABFF00000000282A
          2B3BBCC3D1EED4E0F1FFC7D3E7FFA3B0C5FFB0BFD5FF737985FF51515CFF7577
          8AFF9195B0FF8F92ACFF8E92ABFF8E92ABFF8E92ABFF8E92ABFF28292A39AFB9
          C6EBE9F4FFFFDDE9F9FFBECCE2FFB3C2DBFFB4C1D6FF6A6E7CFF6A6B7EFF5C5C
          69FF797A8FFF9296B0FF8E92ABFF8E92ABFF8E92ABFF8E92ABFF000000004447
          4C7D9099AEFF8D96AAFF767E90FFA0ACC1FFA5B2C6FF727486FF9497B3FF888C
          A3FF676977FF7B7D92FF9194AEFF8E92ACFF8E92ABFF8E92ABFF000000004040
          447C82859DFF696B7EFF535464FF7F899BFF838C9DFF7F8197FF8F94AFFF8F94
          AEFF8E91AAFF7F8194FF818498FF8D90A9FF9094AEFF8E92ABFF000000004445
          4A92898CA5FF6D6F82FF5A5A6BFF5F6372FF676878FF9093ACFF8E92ABFF8E92
          ABFF8F92ACFF9194AEFF8A8DA3FF7B7E90FF86889CFF8E92ABFF000000005454
          5BA48A8DA7FF6E6F82FF5A5B6BFF585866FF808398FF9095AFFF8E92ABFF8E92
          ABFF8E92ABFF8F92ABFF8F93ACFF9194ADFF6E6F81FF696A79EE000000004847
          50AF9094ADFF6D6E80FF565764FF707284FF9094ADFF8E92ABFF8E92ABFF8E92
          ABFF8E92ABFF8E92ABFF9194ADFF8F93ACFF67687CFF67687CFF000000004646
          4FB09195B0FF757786FF686976FF9093ACFF8F93ACFF8E92ABFF8E92ABFF9094
          ADFF9095AEFF9195AFFF83869EFF656677FF5A5A67F767687CFF000000004949
          51AD8C90AAFF888CA2FF8D90A8FF9094AEFF8E92ADFF8F93AEFF8B8FA8FF8487
          9EFF828498FF6F7080EC4C4E54A82E2E31611313142200000000000000005353
          59A0878BA4FF9295B0FF8E92ACFF8B8FA7FF878A9EF76F707DD854555DB33435
          38701B1B1D390A0A0A1100000000000000000000000000000000000000002F30
          324C60616CBB62626EC455565E9C3233366419191A2302020203000000000000
          0000000000000000000000000000000000000000000000000000}
      end>
  end
  object cxLookAndFeelController1: TcxLookAndFeelController
    NativeStyle = False
    Left = 136
    Top = 72
  end
end
