object fNewList: TfNewList
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
  object Label1: TLabel
    Left = 208
    Top = 144
    Width = 31
    Height = 13
    Caption = 'Label1'
  end
  object VSplitter: TcxSplitter
    Left = 182
    Top = 31
    Width = 8
    Height = 273
    Margins.Left = 0
    Margins.Right = 0
    MinSize = 150
    Control = gRes
  end
  object pButtons: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 445
    Height = 25
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object btnPrevious: TcxButton
      Left = 0
      Top = 0
      Width = 127
      Height = 25
      Caption = 'btnPrevious'
      TabOrder = 0
      OnClick = btnPreviousClick
    end
    object btnNext: TcxButton
      Left = 133
      Top = 0
      Width = 127
      Height = 25
      Caption = 'btnNext'
      Enabled = False
      TabOrder = 1
      OnClick = btnNextClick
    end
    object lTip: TcxLabel
      Left = 266
      Top = 5
      Transparent = True
    end
  end
  object gRes: TcxGrid
    Left = 0
    Top = 31
    Width = 182
    Height = 273
    Margins.Right = 0
    Align = alLeft
    PopupMenu = pmgResCopy
    TabOrder = 2
    object tvRes: TcxGridTableView
      Navigator.Buttons.CustomButtons = <>
      OnFocusedRecordChanged = tvResFocusedRecordChanged
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      NewItemRow.SeparatorWidth = 2
      OptionsCustomize.ColumnFiltering = False
      OptionsCustomize.ColumnGrouping = False
      OptionsCustomize.ColumnMoving = False
      OptionsCustomize.ColumnSorting = False
      OptionsData.Deleting = False
      OptionsData.Inserting = False
      OptionsView.ColumnAutoWidth = True
      OptionsView.DataRowHeight = 21
      OptionsView.GroupByBox = False
      OptionsView.Header = False
      object gRescID: TcxGridColumn
        DataBinding.ValueType = 'Integer'
        Visible = False
        SortIndex = 0
        SortOrder = soAscending
      end
      object tgRescIcon: TcxGridColumn
        PropertiesClassName = 'TcxImageProperties'
        MinWidth = 21
        Options.Editing = False
        Options.HorzSizing = False
        Width = 21
      end
      object gRescName: TcxGridColumn
        PropertiesClassName = 'TcxLabelProperties'
        OnGetProperties = gRescNameGetProperties
        Options.ShowEditButtons = isebAlways
        SortIndex = 1
        SortOrder = soAscending
      end
      object gResShort: TcxGridColumn
        Visible = False
      end
      object gRescButton: TcxGridColumn
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Caption = #8594
            Default = True
            Kind = bkText
          end>
        Properties.ViewStyle = vsButtonsAutoWidth
        Properties.OnButtonClick = gRescButtonPropertiesButtonClick
        MinWidth = 23
        Options.ShowEditButtons = isebAlways
        Options.HorzSizing = False
        Options.Moving = False
        Options.Sorting = False
        Width = 23
      end
    end
    object lvlRes1: TcxGridLevel
      GridView = tvRes
    end
  end
  object pcMain: TcxPageControl
    Left = 190
    Top = 31
    Width = 261
    Height = 273
    Align = alClient
    TabOrder = 3
    Properties.ActivePage = tsList
    Properties.CustomButtons.Buttons = <>
    Properties.HideTabs = True
    OnChange = pcMainChange
    ClientRectBottom = 273
    ClientRectRight = 261
    ClientRectTop = 0
    object tsList: TcxTabSheet
      Caption = 'tsList'
      ImageIndex = 0
      object gFull: TcxGrid
        Left = 0
        Top = 26
        Width = 261
        Height = 247
        Margins.Right = 0
        Align = alClient
        PopupMenu = pmgFullCopy
        TabOrder = 0
        object tvFull: TcxGridTableView
          OnKeyPress = tvFullKeyPress
          Navigator.Buttons.CustomButtons = <>
          OnEditValueChanged = tvFullEditValueChanged
          DataController.Filter.OnChanged = tvFullDataControllerFilterChanged
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          FilterRow.SeparatorWidth = 4
          FilterRow.Visible = True
          FilterRow.ApplyChanges = fracImmediately
          FilterRow.ApplyInputDelay = 0
          NewItemRow.SeparatorWidth = 2
          OptionsCustomize.ColumnFiltering = False
          OptionsCustomize.ColumnGrouping = False
          OptionsCustomize.ColumnMoving = False
          OptionsCustomize.ColumnSorting = False
          OptionsData.Deleting = False
          OptionsData.DeletingConfirmation = False
          OptionsData.Inserting = False
          OptionsView.ColumnAutoWidth = True
          OptionsView.DataRowHeight = 21
          OptionsView.GroupByBox = False
          OptionsView.Header = False
          object tvFullcButton: TcxGridColumn
            PropertiesClassName = 'TcxButtonEditProperties'
            Properties.Buttons = <
              item
                Caption = #8592
                Default = True
                Kind = bkText
              end>
            Properties.ViewStyle = vsButtonsOnly
            Properties.OnButtonClick = tvFullcButtonPropertiesButtonClick
            OnGetProperties = tvFullcButtonGetProperties
            MinWidth = 23
            Options.ShowEditButtons = isebAlways
            Options.HorzSizing = False
            Options.Moving = False
            Options.Sorting = False
            Width = 23
          end
          object tvFullID: TcxGridColumn
            DataBinding.ValueType = 'Integer'
            Visible = False
          end
          object tvFullcIcon: TcxGridColumn
            PropertiesClassName = 'TcxImageProperties'
            MinWidth = 21
            Options.Editing = False
            Options.HorzSizing = False
            Width = 21
          end
          object tvFullcName: TcxGridColumn
            PropertiesClassName = 'TcxLabelProperties'
            OnGetProperties = tvFullcNameGetProperties
            Options.Editing = False
            Options.ShowEditButtons = isebAlways
            SortIndex = 0
            SortOrder = soAscending
          end
          object tvFullShort: TcxGridColumn
            PropertiesClassName = 'TcxLabelProperties'
            OnGetProperties = tvFullcNameGetProperties
            Options.Editing = False
          end
        end
        object gFullCardView1: TcxGridCardView
          Navigator.Buttons.CustomButtons = <>
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.CardIndent = 7
        end
        object lvlFull1: TcxGridLevel
          GridView = tvFull
          Options.DetailFrameWidth = 0
        end
      end
      object dxBarDockControl1: TdxBarDockControl
        Left = 0
        Top = 0
        Width = 261
        Height = 26
        Align = dalTop
        AllowDocking = False
        BarManager = dxBarManager
      end
    end
    object tsSettings: TcxTabSheet
      Caption = 'tsSettings'
      ImageIndex = 1
      OnShow = tsSettingsShow
      object vgSettings: TcxVerticalGrid
        Left = 0
        Top = 18
        Width = 261
        Height = 255
        Align = alClient
        OptionsView.ShowEditButtons = ecsbAlways
        OptionsView.GridLineColor = clBtnShadow
        OptionsView.RowHeaderWidth = 125
        TabOrder = 0
        Version = 1
      end
      object lHint: TcxLabel
        Left = 0
        Top = 0
        Align = alTop
        ParentColor = False
        ParentFont = False
        Style.BorderColor = clInfoText
        Style.BorderStyle = ebsUltraFlat
        Style.Color = clInfoBk
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clInfoText
        Style.Font.Height = -11
        Style.Font.Name = 'Tahoma'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        Properties.LabelStyle = cxlsRaised
        Properties.WordWrap = True
        OnClick = lHintClick
        Width = 261
      end
    end
  end
  object EditRepository: TcxEditRepository
    Left = 32
    Top = 40
    object erAuthButton: TcxEditRepositoryButtonItem
      Properties.Buttons = <
        item
          Caption = 'a'
          Default = True
          Glyph.Data = {
            36030000424D3603000000000000360000002800000010000000100000000100
            18000000000000030000120B0000120B000000000000000000000000FF4AA1D6
            4399D04093CF97C7DF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000
            FF0000FF0000FF0000FF67BCE7C4EBF77FE1F69FE6F73F91CC8FC0D80000FF00
            00FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF44B0E3C6F4FB
            43D6F148DBF582E1F53D8FCB89BBD40000FF0000FF0000FF0000FF0000FF0000
            FF0000FF0000FF0000FF4EB4E4BBEFFA39D1F128C5EE4EDCF685E2F74093CE87
            B8D20000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF44B0E3F0FCFE
            B0EEFA43D8F428C8EE41D7F489E2F74093CF80B3CE0000FF0000FF0000FF0000
            FF0000FF0000FF0000FF91D1EF44B0E344B0E3ABEAF94ED8F32BC9EF3DD6F38A
            E1F74092CE4F94C2297DD62C85D85FA5CE0000FF0000FF0000FF0000FF0000FF
            44B0E3F1FCFEBBF1FB7BE4F628D2F037D4F583E0F63EA9E3A0F3FCA9F5FC2B82
            D75BA1CB0000FF0000FF0000FF0000FF91D1EF44B0E345B2E376C5EAACEEFA39
            D6F24DDBF565E4F73CCEF232C9EF85EFFB2B81D7579CC60000FF0000FF0000FF
            0000FF0000FFFEFEFF91D1EF6FC4EA80E5F73DD1F15DDBF569DFF650D7F334CD
            EF85EFFB297FD65399C50000FF0000FF0000FF0000FF0000FF44B0E3D5F7FC89
            E7F87EE4F77EE4F77EE4F782E5F747D6F238CEF0AEF5FC297CD60000FF0000FF
            0000FF0000FF0000FF44B0E3BEF2FB7EE4F77EE4F781E5F794E9F8BCF1FB8BDA
            F349DDF5C1F8FD3090DA0000FF0000FF0000FF0000FF0000FF44B0E3DEF8FC8D
            E7F87EE4F794E9F8BCE9F844B0E342ACE3EEFCFE3298DD6BB0D60000FF0000FF
            0000FF0000FF0000FF91D1EF44B0E3CEF5FC8DE7F8A1ECF944B0E344B0E3FFFF
            FF39A1DF6BB0D60000FF0000FF0000FF0000FF0000FF0000FF0000FF91D1EF44
            B0E3CEF5FC9EEBF9BEF2FBFEFFFF44B0E38BCCEB0000FF0000FF0000FF0000FF
            0000FF0000FF0000FF0000FF0000FF91D1EF44B0E3DEF8FCDEF8FC44B0E391D1
            EF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF00
            00FF91D1EF44B0E344B0E391D1EF0000FF0000FF0000FF0000FF}
          Kind = bkGlyph
        end>
      Properties.ClickKey = 0
      Properties.ReadOnly = True
      Properties.ViewStyle = vsHideCursor
      Properties.OnButtonClick = erAuthButtonPropertiesButtonClick
    end
    object erLabel: TcxEditRepositoryLabel
    end
    object erEdit: TcxEditRepositoryTextItem
    end
  end
  object pmFavList: TPopupMenu
    AutoHotkeys = maManual
    AutoPopup = False
    OnPopup = pmFavListPopup
    Left = 264
    Top = 152
    object AddFav1: TMenuItem
      Caption = 'AddFav'
    end
    object RemFav1: TMenuItem
      Caption = 'RemFav'
    end
    object TagList1: TMenuItem
      Caption = 'TagList'
      OnClick = TagList1Click
    end
  end
  object pmgFullCopy: TPopupMenu
    OnPopup = pmgFullCopyPopup
    Left = 232
    Top = 80
    object COPY1: TMenuItem
      Caption = '_COPY_'
      OnClick = COPY1Click
    end
    object FAVORITE1: TMenuItem
      Caption = '_FAVORITE_'
      OnClick = FAVORITE1Click
    end
  end
  object pmgResCopy: TPopupMenu
    Left = 56
    Top = 112
    object COPY2: TMenuItem
      Caption = '_COPY_'
      OnClick = COPY2Click
    end
  end
  object dxBarManager: TdxBarManager
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
    PopupMenuLinks = <>
    UseSystemFont = True
    Left = 244
    Top = 216
    DockControlHeights = (
      0
      0
      0
      0)
    object dxBarManagerBar1: TdxBar
      AllowClose = False
      AllowCustomizing = False
      AllowQuickCustomizing = False
      AllowReset = False
      Caption = 'ListBar'
      CaptionButtons = <>
      DockControl = dxBarDockControl1
      DockedDockControl = dxBarDockControl1
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 461
      FloatTop = 0
      FloatClientWidth = 0
      FloatClientHeight = 0
      ItemLinks = <
        item
          Visible = True
          ItemName = 'bbFavorite'
        end
        item
          Visible = True
          ItemName = 'bbAll'
        end>
      NotDocking = [dsNone, dsLeft, dsTop, dsRight, dsBottom]
      OneOnRow = True
      Row = 0
      UseOwnFont = False
      Visible = True
      WholeRow = True
    end
    object bbFavorite: TdxBarButton
      Caption = 'bbFavorite'
      Category = 0
      Hint = 'bbFavorite'
      Visible = ivAlways
      ButtonStyle = bsChecked
      GroupIndex = 1
      Down = True
      ImageIndex = 23
      OnClick = bbFavoriteClick
    end
    object bbAll: TdxBarButton
      Caption = 'bbAll'
      Category = 0
      Hint = 'bbAll'
      Visible = ivAlways
      ButtonStyle = bsChecked
      GroupIndex = 1
      ImageIndex = 11
      OnClick = bbAllClick
    end
    object dxBarSubItem1: TdxBarSubItem
      Caption = 'New SubItem'
      Category = 0
      Visible = ivAlways
      ItemLinks = <>
    end
    object cxBarEditItem1: TcxBarEditItem
      Align = iaRight
      Caption = 'New Item'
      Category = 0
      Hint = 'New Item'
      MergeKind = mkMergeByCaption
      Visible = ivAlways
      PropertiesClassName = 'TcxLabelProperties'
      BarStyleDropDownButton = False
      CanSelect = False
    end
  end
end
