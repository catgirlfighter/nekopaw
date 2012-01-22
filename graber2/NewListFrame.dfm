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
      Width = 75
      Height = 25
      Caption = 'btnPrevious'
      Enabled = False
      TabOrder = 0
      OnClick = btnPreviousClick
    end
    object btnNext: TcxButton
      Left = 81
      Top = 0
      Width = 75
      Height = 25
      Caption = 'btnNext'
      Enabled = False
      TabOrder = 1
      OnClick = btnNextClick
    end
  end
  object gRes: TcxGrid
    Left = 0
    Top = 31
    Width = 182
    Height = 273
    Margins.Right = 0
    Align = alLeft
    TabOrder = 2
    object tvRes: TcxGridTableView
      NavigatorButtons.ConfirmDelete = False
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
        OnGetProperties = gRescButtonGetProperties
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
    ActivePage = tsList
    Align = alClient
    HideTabs = True
    TabOrder = 3
    OnChange = pcMainChange
    ClientRectBottom = 273
    ClientRectRight = 261
    ClientRectTop = 0
    object tsList: TcxTabSheet
      Caption = 'tsList'
      ImageIndex = 0
      object gFull: TcxGrid
        Left = 0
        Top = 0
        Width = 261
        Height = 273
        Margins.Right = 0
        Align = alClient
        TabOrder = 0
        object tvFull: TcxGridTableView
          NavigatorButtons.ConfirmDelete = False
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
            SortIndex = 0
            SortOrder = soAscending
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
            Options.Editing = False
            Options.ShowEditButtons = isebAlways
          end
        end
        object lvlFull1: TcxGridLevel
          GridView = tvFull
          Options.DetailFrameWidth = 0
        end
      end
    end
    object tsSettings: TcxTabSheet
      Caption = 'tsSettings'
      ImageIndex = 1
      OnShow = tsSettingsShow
      ExplicitLeft = 4
      ExplicitTop = 4
      ExplicitWidth = 253
      ExplicitHeight = 265
      object vgSettings: TcxVerticalGrid
        Left = 0
        Top = 0
        Width = 261
        Height = 273
        Align = alClient
        OptionsView.GridLineColor = clBtnShadow
        OptionsView.RowHeaderWidth = 143
        TabOrder = 0
        ExplicitWidth = 253
        ExplicitHeight = 265
        Version = 1
      end
    end
  end
  object EditRepository: TcxEditRepository
    Left = 392
    Top = 80
    object erLabel: TcxEditRepositoryLabel
    end
    object erButton: TcxEditRepositoryButtonItem
      Properties.Buttons = <
        item
          Kind = bkGlyph
        end>
      Properties.ClickKey = 0
      Properties.ViewStyle = vsButtonsAutoWidth
    end
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
    end
    object erCheckBox: TcxEditRepositoryCheckBoxItem
      Properties.Alignment = taLeftJustify
    end
    object erSpinEdit: TcxEditRepositorySpinItem
    end
    object erCombo: TcxEditRepositoryComboBoxItem
      Properties.DropDownListStyle = lsFixedList
    end
  end
end
