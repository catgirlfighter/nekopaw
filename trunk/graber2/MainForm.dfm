object mf: Tmf
  Left = 0
  Top = 0
  Caption = 'nekopaw grabber'
  ClientHeight = 425
  ClientWidth = 608
  Color = clBtnFace
  Constraints.MinHeight = 450
  Constraints.MinWidth = 600
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  DesignSize = (
    608
    425)
  PixelsPerInch = 96
  TextHeight = 13
  object ds: TdxDockSite
    Left = 0
    Top = 26
    Width = 608
    Height = 399
    Align = alClient
    DockingType = 5
    OriginalWidth = 608
    OriginalHeight = 399
    object dxLayoutDockSite4: TdxLayoutDockSite
      Left = 0
      Top = 0
      Width = 608
      Height = 249
      DockingType = 0
      OriginalWidth = 300
      OriginalHeight = 200
      object dsTable: TdxLayoutDockSite
        Left = 185
        Top = 0
        Width = 423
        Height = 249
        DockingType = 0
        OriginalWidth = 300
        OriginalHeight = 200
        object dxLayoutDockSite2: TdxLayoutDockSite
          Left = 0
          Top = 0
          Width = 423
          Height = 249
          DockingType = 0
          OriginalWidth = 300
          OriginalHeight = 200
        end
        object dpTable: TdxDockPanel
          Left = 0
          Top = 0
          Width = 423
          Height = 249
          AllowFloating = False
          AutoHide = False
          Caption = 'dpTable'
          Dockable = False
          ShowCaption = False
          DockingType = 0
          OriginalWidth = 185
          OriginalHeight = 140
          object pcTables: TcxPageControl
            Left = 0
            Top = 0
            Width = 419
            Height = 245
            Align = alClient
            TabOrder = 0
            Properties.CloseButtonMode = cbmEveryTab
            Properties.CustomButtons.Buttons = <>
            Properties.Images = dm.il
            Properties.Options = [pcoGoDialog]
            OnCanCloseEx = pcTablesCanCloseEx
            OnChange = pcTablesChange
            ClientRectBottom = 245
            ClientRectRight = 419
            ClientRectTop = 0
          end
        end
      end
      object dsTags: TdxTabContainerDockSite
        Left = 0
        Top = 0
        Width = 185
        Height = 249
        ActiveChildIndex = 0
        AllowFloating = False
        AutoHide = False
        Dockable = False
        ShowCaption = False
        TabsProperties.TabPosition = tpTop
        DockingType = 1
        OriginalWidth = 185
        OriginalHeight = 140
        object dpTags: TdxDockPanel
          Left = 0
          Top = 0
          Width = 181
          Height = 220
          AllowFloating = False
          AutoHide = False
          Caption = 'dpTags'
          Dockable = False
          DockingType = 0
          OriginalWidth = 185
          OriginalHeight = 140
          object nvTags: TdxNavBar
            Left = 0
            Top = 0
            Width = 181
            Height = 220
            Align = alClient
            ActiveGroupIndex = 0
            TabOrder = 0
            View = 1
            OptionsBehavior.NavigationPane.AllowCustomizing = False
            object nbgTagsMain: TdxNavBarGroup
              Caption = 'nbgTagsMain'
              SelectedLinkIndex = -1
              TopVisibleLinkIndex = 0
              OptionsGroupControl.ShowControl = True
              OptionsGroupControl.UseControl = True
              Links = <>
            end
            object nbgTagsTags: TdxNavBarGroup
              Caption = 'nbgTagsTags'
              SelectedLinkIndex = -1
              TopVisibleLinkIndex = 0
              OptionsGroupControl.ShowControl = True
              OptionsGroupControl.UseControl = True
              Links = <>
            end
            object dxNavBarGroupControl1: TdxNavBarGroupControl
              Left = 0
              Top = 19
              Width = 181
              Height = 182
              Caption = 'nbgCurMainControl'
              TabOrder = 1
              GroupIndex = 0
              OriginalHeight = 41
              object vgTagsMain: TcxVerticalGrid
                Left = 0
                Top = 0
                Width = 181
                Height = 182
                Align = alClient
                OptionsView.RowHeaderWidth = 84
                TabOrder = 0
                Version = 1
              end
            end
            object dxNavBarGroupControl2: TdxNavBarGroupControl
              Left = 0
              Top = 38
              Width = 181
              Height = 180
              Caption = 'nbgCurTagsControl'
              TabOrder = 5
              GroupIndex = 1
              OriginalHeight = 41
              object chlbFullTags: TcxCheckListBox
                Left = 0
                Top = 21
                Width = 181
                Height = 159
                Align = alClient
                AutoComplete = False
                EditValueFormat = cvfCaptions
                Items = <>
                TabOrder = 0
                OnClickCheck = chlbFullTagsClickCheck
              end
              object chlbtagsfilter: TcxButtonEdit
                Left = 0
                Top = 0
                Align = alTop
                Enabled = False
                Properties.Buttons = <
                  item
                    Caption = 'go'
                    Default = True
                    Kind = bkText
                  end>
                TabOrder = 1
                Width = 181
              end
            end
          end
        end
        object dpCurTags: TdxDockPanel
          Left = 0
          Top = 0
          Width = 181
          Height = 220
          AllowFloating = False
          AutoHide = False
          Caption = 'dpCurTags'
          Dockable = False
          DockingType = 0
          OriginalWidth = 185
          OriginalHeight = 140
          object nvCur: TdxNavBar
            Left = 0
            Top = 0
            Width = 181
            Height = 220
            Align = alClient
            ActiveGroupIndex = 0
            TabOrder = 0
            View = 1
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
              Height = 182
              Caption = 'nbgCurMainControl'
              TabOrder = 1
              GroupIndex = 0
              OriginalHeight = 41
              object vgCurMain: TcxVerticalGrid
                Left = 0
                Top = 0
                Width = 181
                Height = 182
                Align = alClient
                OptionsView.ShowEditButtons = ecsbAlways
                OptionsView.RowHeaderWidth = 86
                TabOrder = 0
                Version = 1
              end
            end
            object nbgCurTagsControl: TdxNavBarGroupControl
              Left = 0
              Top = 38
              Width = 181
              Height = 180
              Caption = 'nbgCurTagsControl'
              TabOrder = 5
              GroupIndex = 1
              OriginalHeight = 41
              object chlbTags: TcxCheckListBox
                Left = 0
                Top = 0
                Width = 181
                Height = 180
                Align = alClient
                EditValueFormat = cvfCaptions
                Items = <>
                Sorted = True
                TabOrder = 0
              end
            end
          end
        end
      end
    end
    object dsLogs: TdxTabContainerDockSite
      Left = 0
      Top = 249
      Width = 608
      Height = 150
      ActiveChildIndex = 0
      AllowFloating = False
      AutoHide = False
      CaptionButtons = [cbMaximize, cbHide]
      Dockable = False
      DockingType = 4
      OriginalWidth = 185
      OriginalHeight = 150
      object dpLog: TdxDockPanel
        Left = 0
        Top = 0
        Width = 604
        Height = 101
        AllowFloating = True
        AutoHide = False
        Caption = 'dpLog'
        Dockable = False
        DockingType = 0
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
          Height = 101
          Width = 604
        end
      end
      object dpErrors: TdxDockPanel
        Left = 0
        Top = 0
        Width = 604
        Height = 101
        AllowFloating = True
        AutoHide = False
        Caption = 'dpErrors'
        Dockable = False
        DockingType = 0
        OriginalWidth = 185
        OriginalHeight = 150
        object mErrors: TcxMemo
          Left = 0
          Top = 0
          Align = alClient
          PopupMenu = fLogPopup
          Properties.ReadOnly = True
          Properties.ScrollBars = ssVertical
          Style.Color = 14803455
          TabOrder = 0
          Height = 101
          Width = 604
        end
      end
    end
  end
  object lUPD: TcxLabel
    Left = 480
    Top = 0
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = 'Cheking updates'
    Visible = False
    Height = 17
    Width = 128
  end
  object MainBarControl: TdxBarDockControl
    Left = 0
    Top = 0
    Width = 608
    Height = 26
    Align = dalTop
    BarManager = BarManager
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
    Images = dm.il
    Options = [doActivateAfterDocking, doDblClickDocking, doFloatingOnTop, doTabContainerHasCaption, doTabContainerCanAutoHide, doSideContainerCanClose, doSideContainerCanAutoHide, doTabContainerCanInSideContainer, doImmediatelyHideOnAutoHide, doHideAutoHideIfActive, doRedrawOnResize]
    Left = 480
    Top = 40
    PixelsPerInch = 96
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
    ImageOptions.Images = dm.il
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
      DockControl = MainBarControl
      DockedDockControl = MainBarControl
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 264
      FloatTop = 192
      FloatClientWidth = 51
      FloatClientHeight = 22
      IsMainMenu = True
      ItemLinks = <
        item
          Visible = True
          ItemName = 'bbNew'
        end
        item
          Visible = True
          ItemName = 'bbLoad'
        end
        item
          Visible = True
          ItemName = 'bbSave'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'bbChange'
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
          ItemName = 'bbSignalTimer'
        end
        item
          BeginGroup = True
          Visible = True
          ItemName = 'bbAdvanced'
        end
        item
          Visible = True
          ItemName = 'bbSettings'
        end>
      MultiLine = True
      NotDocking = [dsNone, dsLeft, dsTop, dsRight, dsBottom]
      OneOnRow = True
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = True
    end
    object bbStartList: TdxBarButton
      Caption = 'bbStartList'
      Category = 0
      Hint = 'bbStartList'
      Visible = ivAlways
      ImageIndex = 3
      OnClick = bbStartListClick
    end
    object bbStartPics: TdxBarButton
      Caption = 'bbStartPics'
      Category = 0
      Hint = 'bbStartPics'
      Visible = ivAlways
      ImageIndex = 5
      OnClick = bbStartPicsClick
    end
    object bbSettings: TdxBarButton
      Caption = 'bbSettings'
      Category = 0
      Hint = 'bbSettings'
      Visible = ivAlways
      ImageIndex = 1
      OnClick = bbSettingsClick
    end
    object bbNew: TdxBarButton
      Caption = 'bbNew'
      Category = 0
      Hint = 'bbNew'
      Visible = ivAlways
      ImageIndex = 2
      OnClick = bbNewClick
    end
    object bbAdvanced: TdxBarSubItem
      Caption = '_ADVANCED_'
      Category = 0
      Visible = ivAlways
      ImageIndex = 21
      ShowCaption = False
      ItemLinks = <
        item
          Visible = True
          ItemName = 'bbDeleteMD5Doubles'
        end>
    end
    object bbDeleteMD5Doubles: TdxBarButton
      Caption = '_DELETEMD5DOUBLES_'
      Category = 0
      Hint = '_DELETEMD5DOUBLES_'
      Visible = ivAlways
      OnClick = bbDeleteMD5DoublesClick
    end
    object bbSignalTimer: TdxBarButton
      Caption = 'bbSignalTimer'
      Category = 0
      Hint = 'bbSignalTimer'
      Visible = ivNever
      ImageIndex = 24
      OnClick = bbSignalTimerClick
    end
    object bbSave: TdxBarButton
      Caption = 'bbSave'
      Category = 0
      Hint = 'bbSave'
      Visible = ivAlways
      ImageIndex = 26
      OnClick = bbSaveClick
    end
    object bbLoad: TdxBarButton
      Caption = 'bbLoad'
      Category = 0
      Hint = 'bbLoad'
      Visible = ivAlways
      ImageIndex = 27
      OnClick = bbLoadClick
    end
    object bbChange: TdxBarButton
      Caption = 'bbChange'
      Category = 0
      Hint = 'bbChange'
      Visible = ivAlways
      ImageIndex = 28
      OnClick = bbChangeClick
    end
  end
  object ApplicationEvents1: TApplicationEvents
    OnDeactivate = ApplicationEvents1Deactivate
    OnException = ApplicationEvents1Exception
    OnMinimize = ApplicationEvents1Minimize
    Left = 504
    Top = 176
  end
  object vINFO: TrpVersionInfo
    Left = 448
    Top = 112
  end
  object dxSkinController: TdxSkinController
    SkinName = 'UserSkin'
    UseSkins = False
    Left = 368
    Top = 96
  end
  object fLogPopup: TPopupMenu
    OnPopup = fLogPopupPopup
    Left = 224
    Top = 80
    object COPY1: TMenuItem
      Caption = '_COPY_'
      OnClick = COPY1Click
    end
    object GOTO1: TMenuItem
      Caption = '_GOTO_'
      OnClick = GOTO1Click
    end
    object SELECTALL1: TMenuItem
      Caption = '_SELECTALL_'
    end
    object CLEAR1: TMenuItem
      Caption = '_CLEAR_'
      OnClick = CLEAR1Click
    end
  end
  object dlgSave: TSaveDialog
    DefaultExt = '.nkp'
    Filter = 
      'CSV (name+md5+tags, only downloaded)|*.csv|NKP (full progress li' +
      'st)|*.nkp'
    FilterIndex = 2
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 328
    Top = 188
  end
  object dlgOpen: TOpenDialog
    DefaultExt = '.nkp'
    Filter = 'NKP (nekopaw grabber progress list)|*.nkp|ALL|*.*'
    Left = 276
    Top = 188
  end
end
