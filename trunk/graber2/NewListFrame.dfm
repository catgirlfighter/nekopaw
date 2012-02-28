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
      Width = 95
      Height = 25
      Caption = 'btnPrevious'
      Enabled = False
      TabOrder = 0
      OnClick = btnPreviousClick
    end
    object btnNext: TcxButton
      Left = 101
      Top = 0
      Width = 95
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
      ExplicitWidth = 0
      ExplicitHeight = 0
      object vgSettings: TcxVerticalGrid
        Left = 0
        Top = 0
        Width = 261
        Height = 273
        Align = alClient
        OptionsView.GridLineColor = clBtnShadow
        OptionsView.RowHeaderWidth = 143
        TabOrder = 0
        Version = 1
      end
    end
  end
end
