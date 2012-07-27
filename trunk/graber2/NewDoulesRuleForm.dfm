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
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 0
    ExplicitWidth = 378
    object bOk: TcxButton
      Left = 0
      Top = 0
      Width = 75
      Height = 25
      Caption = 'bOk'
      TabOrder = 0
    end
    object bCancel: TcxButton
      Left = 81
      Top = 0
      Width = 75
      Height = 25
      Caption = 'bCancel'
      TabOrder = 1
    end
    object lRuleName: TcxLabel
      Left = 0
      Top = 32
      Caption = 'lRuleName'
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
    Top = 60
    Width = 394
    Height = 226
    Align = alClient
    TabOrder = 1
    ExplicitTop = -1
    ExplicitWidth = 279
    ExplicitHeight = 273
    object tvValues: TcxGridTableView
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsCustomize.ColumnFiltering = False
      OptionsCustomize.ColumnGrouping = False
      OptionsCustomize.ColumnHidingOnGrouping = False
      OptionsCustomize.ColumnMoving = False
      OptionsCustomize.ColumnSorting = False
      OptionsData.CancelOnExit = False
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsSelection.CellSelect = False
      OptionsView.CellAutoHeight = True
      OptionsView.ColumnAutoWidth = True
      OptionsView.ExpandButtonsForEmptyDetails = False
      OptionsView.GroupByBox = False
      object cChWhat: TcxGridColumn
        Caption = 'Field'
        Width = 100
      end
      object cChWith: TcxGridColumn
        Caption = 'Compare with'
        Width = 292
      end
    end
    object gValuesLevel1: TcxGridLevel
      GridView = tvValues
    end
  end
end
