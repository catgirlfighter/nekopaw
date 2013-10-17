object fmDoublesNewRule: TfmDoublesNewRule
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'fmDoublesNewRule'
  ClientHeight = 286
  ClientWidth = 394
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 388
    Height = 54
    Align = alTop
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    object bOk: TcxButton
      Left = 0
      Top = 0
      Width = 75
      Height = 25
      Caption = 'bOk'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object bCancel: TcxButton
      Left = 81
      Top = 0
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'bCancel'
      ModalResult = 2
      TabOrder = 1
    end
    object lRuleName: TcxLabel
      Left = 0
      Top = 32
      Caption = 'lRuleName'
      Transparent = True
    end
    object eName: TcxTextEdit
      Left = 97
      Top = 31
      TabOrder = 3
      Width = 208
    end
  end
  object gValues: TcxGrid
    Left = 0
    Top = 86
    Width = 394
    Height = 200
    Align = alClient
    TabOrder = 1
    object tvValues: TcxGridTableView
      Navigator.Buttons.CustomButtons = <>
      OnEditValueChanged = tvValuesEditValueChanged
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsCustomize.ColumnFiltering = False
      OptionsCustomize.ColumnGrouping = False
      OptionsCustomize.ColumnHidingOnGrouping = False
      OptionsCustomize.ColumnMoving = False
      OptionsCustomize.ColumnSorting = False
      OptionsData.Appending = True
      OptionsData.CancelOnExit = False
      OptionsView.CellAutoHeight = True
      OptionsView.ColumnAutoWidth = True
      OptionsView.ExpandButtonsForEmptyDetails = False
      OptionsView.GroupByBox = False
      object cChWhat: TcxGridColumn
        Caption = 'Field'
        RepositoryItem = cComboBox
        Width = 100
      end
      object cChWith: TcxGridColumn
        Caption = 'Compare with'
        RepositoryItem = cComboBox
        Width = 292
      end
    end
    object gValuesLevel1: TcxGridLevel
      GridView = tvValues
    end
  end
  object bcValues: TdxBarDockControl
    Left = 0
    Top = 60
    Width = 394
    Height = 26
    Align = dalTop
    BarManager = BarManager
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
    PopupMenuLinks = <>
    UseSystemFont = True
    Left = 32
    Top = 144
    DockControlHeights = (
      0
      0
      0
      0)
    object DoublesActions: TdxBar
      AllowClose = False
      AllowCustomizing = False
      AllowQuickCustomizing = False
      Caption = 'Doubles'
      CaptionButtons = <>
      DockControl = bcValues
      DockedDockControl = bcValues
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 461
      FloatTop = 0
      FloatClientWidth = 64
      FloatClientHeight = 66
      ItemLinks = <
        item
          Visible = True
          ItemName = 'bbNewRule'
        end
        item
          Visible = True
          ItemName = 'bbDeleteRule'
        end>
      NotDocking = [dsNone, dsLeft, dsTop, dsRight, dsBottom]
      OneOnRow = True
      Row = 0
      UseOwnFont = False
      UseRestSpace = True
      Visible = True
      WholeRow = False
    end
    object bbNewRule: TdxBarButton
      Caption = 'New rule'
      Category = 0
      Hint = 'New rule'
      Visible = ivAlways
      ImageIndex = 16
      OnClick = bbNewRuleClick
    end
    object bbEditRule: TdxBarButton
      Caption = 'Edit rule'
      Category = 0
      Hint = 'Edit rule'
      Visible = ivAlways
    end
    object bbDeleteRule: TdxBarButton
      Caption = 'Delete rule'
      Category = 0
      Hint = 'Delete rule'
      Visible = ivAlways
      ImageIndex = 18
      OnClick = bbDeleteRuleClick
    end
  end
  object cxEditRepository1: TcxEditRepository
    Left = 152
    Top = 144
    object cComboBox: TcxEditRepositoryComboBoxItem
      Properties.ImmediatePost = True
      Properties.Sorted = True
      Properties.UseNullString = True
    end
  end
end
