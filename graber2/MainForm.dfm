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
        Left = 185
        Top = 0
        Width = 423
        Height = 236
        DockType = 1
        OriginalWidth = 300
        OriginalHeight = 200
        object dxLayoutDockSite2: TdxLayoutDockSite
          Left = 0
          Top = 0
          Width = 423
          Height = 236
          ExplicitWidth = 458
          DockType = 1
          OriginalWidth = 300
          OriginalHeight = 200
        end
        object dpTable: TdxDockPanel
          Left = 0
          Top = 0
          Width = 423
          Height = 236
          AllowFloating = False
          AutoHide = False
          Caption = 'dpTable'
          Dockable = False
          ShowCaption = False
          ExplicitWidth = 458
          DockType = 1
          OriginalWidth = 185
          OriginalHeight = 140
          object pcTables: TcxPageControl
            Left = 0
            Top = 0
            Width = 419
            Height = 232
            Align = alClient
            Images = il
            Options = [pcoAlwaysShowGoDialogButton, pcoCloseButton, pcoGradient, pcoGradientClientArea, pcoRedrawOnResize]
            TabOrder = 0
            OnChange = pcTablesChange
            ExplicitWidth = 454
            ClientRectBottom = 232
            ClientRectRight = 419
            ClientRectTop = 0
          end
        end
      end
      object dsTags: TdxTabContainerDockSite
        Left = 0
        Top = 0
        Width = 185
        Height = 236
        ActiveChildIndex = 1
        AllowFloating = False
        AutoHide = False
        Dockable = False
        ShowCaption = False
        TabsPosition = tctpTop
        DockType = 2
        OriginalWidth = 185
        OriginalHeight = 140
        object dpTags: TdxDockPanel
          Left = 0
          Top = 0
          Width = 181
          Height = 208
          AllowFloating = False
          AutoHide = False
          Caption = 'dpTags'
          Dockable = False
          DockType = 1
          OriginalWidth = 185
          OriginalHeight = 140
        end
        object dpCurTags: TdxDockPanel
          Left = 0
          Top = 0
          Width = 181
          Height = 208
          AllowFloating = False
          AutoHide = False
          Caption = 'dpCurTags'
          Dockable = False
          DockType = 1
          OriginalWidth = 185
          OriginalHeight = 140
          object nvCur: TdxNavBar
            Left = 0
            Top = 0
            Width = 181
            Height = 208
            Align = alClient
            ActiveGroupIndex = 0
            TabOrder = 0
            View = 1
            ExplicitLeft = -2
            ExplicitTop = -4
            object nbgCurMain: TdxNavBarGroup
              Caption = 'nbgCurMain'
              SelectedLinkIndex = -1
              TopVisibleLinkIndex = 0
              OptionsGroupControl.ShowControl = True
              OptionsGroupControl.UseControl = True
              Links = <>
            end
            object nbgCurTags: TdxNavBarGroup
              Caption = 'nbgCurTags'
              SelectedLinkIndex = -1
              TopVisibleLinkIndex = 0
              OptionsGroupControl.ShowControl = True
              OptionsGroupControl.UseControl = True
              Links = <>
            end
            object nbgCurMainControl: TdxNavBarGroupControl
              Left = 0
              Top = 19
              Width = 181
              Height = 170
              Caption = 'nbgCurMainControl'
              TabOrder = 3
              GroupIndex = 0
              OriginalHeight = 41
              object vgCurMain: TcxVerticalGrid
                Left = 0
                Top = 0
                Width = 181
                Height = 170
                Align = alClient
                OptionsView.RowHeaderWidth = 86
                TabOrder = 0
                ExplicitLeft = 48
                ExplicitTop = 48
                ExplicitWidth = 150
                ExplicitHeight = 200
                Version = 1
              end
            end
            object nbgCurTagsControl: TdxNavBarGroupControl
              Left = 0
              Top = 38
              Width = 181
              Height = 170
              Caption = 'nbgCurTagsControl'
              TabOrder = 5
              GroupIndex = 1
              OriginalHeight = 41
              object chlbTags: TcxCheckListBox
                Left = 0
                Top = 0
                Width = 181
                Height = 170
                Align = alClient
                EditValueFormat = cvfCaptions
                Items = <>
                Sorted = True
                TabOrder = 0
                ExplicitLeft = 96
                ExplicitTop = 56
                ExplicitWidth = 121
                ExplicitHeight = 97
              end
            end
          end
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
        object mLog: TcxMemo
          Left = 0
          Top = 0
          Align = alClient
          Properties.ReadOnly = True
          Properties.ScrollBars = ssVertical
          Style.Color = clInfoBk
          TabOrder = 0
          Height = 102
          Width = 604
        end
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
        object mErrors: TcxMemo
          Left = 0
          Top = 0
          Align = alClient
          Properties.ReadOnly = True
          Properties.ScrollBars = ssVertical
          Style.Color = 14803455
          TabOrder = 0
          Height = 102
          Width = 604
        end
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
          ItemName = 'bbStartPics'
        end
        item
          Visible = True
          ItemName = 'bbSettings'
        end>
      NotDocking = [dsNone, dsLeft, dsTop, dsRight, dsBottom]
      OneOnRow = True
      Row = 0
      UseOwnFont = False
      UseRestSpace = True
      Visible = True
      WholeRow = False
    end
    object bbStartList: TdxBarButton
      Caption = 'bbStartList'
      Category = 0
      Hint = 'bbStartList'
      Visible = ivAlways
      OnClick = bbStartListClick
    end
    object bbStartPics: TdxBarButton
      Caption = 'bbStartPics'
      Category = 0
      Hint = 'bbStartPics'
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
      end
      item
        Image.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000002A2A2A63424242BF3D3D3DBF2020
          2063000000000000000000000000000000000000000000000000000000000000
          000000000000121212290606060E01010102767676EABDBDBDFFB2B2B2FF5454
          54EA010101020505050E0D0D0D29000000000000000000000000000000000000
          00004E4E4E9B6E6E6EFD5B5B5BE70C0C0C19777777E7CBCBCBFFC7C7C7FF5959
          59E709090919505050E74D4D4DFD2C2C2C9B0000000000000000000000004F4F
          4F7BBCBCBCFFDEDEDEFFA6A6A6FF7D7D7DF4848484FEC4C4C4FFC2C2C2FF6D6D
          6DFE696969F4A6A6A6FFD2D2D2FF808080FF2828287B00000000000000005454
          547DA5A5A5FED5D5D5FFC5C5C5FFCBCBCBFFD1D1D1FFC9C9C9FFC7C7C7FFCCCC
          CCFFC5C5C5FFBDBDBDFFCBCBCBFF6E6E6EFE3232327D00000000000000000000
          00005A5A5A85C5C5C5FFC1C1C1FFC5C5C5FFC7C7C7FFAAAAAAFFA7A7A7FFC1C1
          C1FFBEBEBEFFB5B5B5FFAAAAAAFF373737850000000000000000838383CD7F7F
          7FE3959595EECFCFCFFFC6C6C6FFCCCCCCFF7B7B7BC629292944272727446F6F
          6FC6C1C1C1FFBCBCBCFFB9B9B9FF5D5D5DEE4E4E4EE3434343CDBEBEBEFDE2E2
          E2FFD2D2D2FFC6C6C6FFCDCDCDFFB1B1B1FF2727274400000000000000002828
          2844A8A8A8FFC2C2C2FFB7B7B7FFC0C0C0FFD2D2D2FF606060FDC2C2C2FDE9E9
          E9FFD6D6D6FFC9C9C9FFCECECEFFA5A5A5FF2323234400000000000000002929
          2944ACACACFFC4C4C4FFBABABAFFC6C6C6FFDDDDDDFF6A6A6AFDA1A1A1CDAEAE
          AEE3B3B3B3EED8D8D8FFCDCDCDFFBCBCBCFF656565C620202044222222446F6F
          6FC6C3C3C3FFC2C2C2FFCDCDCDFF838383EE787878E3696969CD000000000000
          000067676785D4D4D4FFCCCCCCFFC9C9C9FFBABABAFF9C9C9CFFA1A1A1FFC2C2
          C2FFC6C6C6FFC1C1C1FFB7B7B7FF474747850000000000000000000000006363
          637DC3C3C3FEDCDCDCFFD4D4D4FFD9D9D9FFDBDBDBFFD6D6D6FFD4D4D4FFD9D9
          D9FFD2D2D2FFCBCBCBFFC8C8C8FF797979FE3737377D00000000000000006464
          647BDCDCDCFFEDEDEDFFDBDBDBFFBABABAF4BDBDBDFED6D6D6FFD4D4D4FFAFAF
          AFFEA5A5A5F4CBCBCBFFE7E7E7FFB7B7B7FF4343437B00000000000000000000
          00007F7F7F9BCCCCCCFDB7B7B7E713131319B0B0B0E7DEDEDEFFDDDDDDFFA1A1
          A1E7111111199C9C9CE7A6A6A6FD6363639B0000000000000000000000000000
          000000000000222222290B0B0B0E02020202B7B7B7EAE5E5E5FFE4E4E4FF9E9E
          9EEA010101020A0A0A0E1C1C1C29000000000000000000000000000000000000
          0000000000000000000000000000000000004F4F4F63959595BF939393BF4A4A
          4A63000000000000000000000000000000000000000000000000}
      end>
  end
  object cxLookAndFeelController1: TcxLookAndFeelController
    Left = 136
    Top = 72
  end
  object ApplicationEvents1: TApplicationEvents
    OnException = ApplicationEvents1Exception
    Left = 504
    Top = 176
  end
end
