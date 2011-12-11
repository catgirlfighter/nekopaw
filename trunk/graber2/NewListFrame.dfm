object fNewList: TfNewList
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  TabOrder = 0
  object VSplitter: TcxSplitter
    AlignWithMargins = True
    Left = 153
    Top = 34
    Width = 8
    Height = 267
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
    object btnOk: TcxButton
      Left = 0
      Top = 0
      Width = 75
      Height = 25
      Caption = 'btnOk'
      TabOrder = 0
      OnClick = btnOkClick
    end
    object btnCancel: TcxButton
      Left = 81
      Top = 0
      Width = 75
      Height = 25
      Caption = 'btnCancel'
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
  object gRes: TcxGrid
    AlignWithMargins = True
    Left = 3
    Top = 34
    Width = 150
    Height = 267
    Margins.Right = 0
    Align = alLeft
    TabOrder = 2
    object tvRes: TcxGridTableView
      NavigatorButtons.ConfirmDelete = False
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      NewItemRow.SeparatorWidth = 2
      OptionsCustomize.ColumnFiltering = False
      OptionsCustomize.ColumnGrouping = False
      OptionsCustomize.ColumnMoving = False
      OptionsCustomize.ColumnSorting = False
      OptionsView.ColumnAutoWidth = True
      OptionsView.GroupByBox = False
      OptionsView.Header = False
      object gRescName: TcxGridColumn
        PropertiesClassName = 'TcxLabelProperties'
        Options.Filtering = False
        Options.ShowEditButtons = isebAlways
      end
      object gRescButton: TcxGridColumn
        PropertiesClassName = 'TcxButtonEditProperties'
        Properties.Buttons = <
          item
            Default = True
            Kind = bkGlyph
          end>
        Properties.ViewStyle = vsButtonsAutoWidth
        MinWidth = 19
        Options.ShowEditButtons = isebAlways
        Options.HorzSizing = False
        Options.Moving = False
        Options.Sorting = False
        Width = 19
      end
    end
    object lvlRes1: TcxGridLevel
      GridView = tvRes
    end
  end
  object pcMain: TcxPageControl
    Left = 161
    Top = 31
    Width = 290
    Height = 273
    ActivePage = tsList
    Align = alClient
    TabOrder = 3
    ClientRectBottom = 273
    ClientRectRight = 290
    ClientRectTop = 24
    object tsList: TcxTabSheet
      Caption = 'tsList'
      ImageIndex = 0
      object gFull: TcxGrid
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 287
        Height = 243
        Margins.Right = 0
        Align = alLeft
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
          OptionsView.ColumnAutoWidth = True
          OptionsView.DataRowHeight = 21
          OptionsView.GroupByBox = False
          OptionsView.Header = False
          object tvFullID: TcxGridColumn
            DataBinding.ValueType = 'Integer'
            Visible = False
          end
          object tvFullcButton: TcxGridColumn
            PropertiesClassName = 'TcxButtonEditProperties'
            Properties.Buttons = <
              item
                Default = True
                Kind = bkGlyph
              end>
            Properties.ViewStyle = vsButtonsAutoWidth
            MinWidth = 21
            Options.ShowEditButtons = isebAlways
            Options.HorzSizing = False
            Options.Moving = False
            Options.Sorting = False
            Width = 21
          end
          object tvFullcIcon: TcxGridColumn
            PropertiesClassName = 'TcxImageProperties'
            MinWidth = 21
            Options.HorzSizing = False
            Width = 21
          end
          object tvFullcName: TcxGridColumn
            PropertiesClassName = 'TcxLabelProperties'
            Options.Filtering = False
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
    end
  end
  object EditRepository: TcxEditRepository
    Left = 392
    Top = 80
    object EditRepositoryLabel1: TcxEditRepositoryLabel
    end
  end
end
