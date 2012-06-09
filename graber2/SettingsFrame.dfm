object fSettings: TfSettings
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
  object pButtons: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 445
    Height = 25
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
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
  object tlList: TcxTreeList
    Left = 0
    Top = 31
    Width = 169
    Height = 273
    Align = alLeft
    Bands = <
      item
      end>
    OptionsData.Editing = False
    OptionsData.Deleting = False
    OptionsView.ColumnAutoWidth = True
    OptionsView.Headers = False
    TabOrder = 1
    OnFocusedNodeChanged = tlListFocusedNodeChanged
    ExplicitLeft = -3
    ExplicitTop = 34
    Data = {
      00000500170100000F00000044617461436F6E74726F6C6C6572310100000012
      000000546378537472696E6756616C75655479706504000000445855464D5400
      000900000049006E007400650072006600610063006500445855464D54000007
      0000005400680072006500610064007300445855464D54000005000000500072
      006F0078007900445855464D540000090000005200650073006F007500720063
      006500730004000000000000000802FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFF010000000800FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF020000
      000800FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF030000000800FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF1A0004000000}
    object tlcCaption: TcxTreeListColumn
      DataBinding.ValueType = 'String'
      Position.ColIndex = 0
      Position.RowIndex = 0
      Position.BandIndex = 0
      Summary.FooterSummaryItems = <>
      Summary.GroupFooterSummaryItems = <>
    end
  end
  object cxSplitter1: TcxSplitter
    Left = 169
    Top = 31
    Width = 3
    Height = 273
    ResizeUpdate = True
    Control = tlList
  end
  object pcMain: TcxPageControl
    Left = 172
    Top = 31
    Width = 279
    Height = 273
    ActivePage = cxTabSheet4
    Align = alClient
    HideTabs = True
    TabOrder = 3
    ClientRectBottom = 273
    ClientRectRight = 279
    ClientRectTop = 0
    object cxTabSheet1: TcxTabSheet
      Caption = 'cxTabSheet1'
      ImageIndex = 0
      object lcLanguage: TcxLabel
        Left = 6
        Top = 4
        AutoSize = False
        Caption = 'lcLanguage'
        Height = 17
        Width = 194
      end
      object cbLanguage: TcxComboBox
        Left = 206
        Top = 3
        Properties.DropDownListStyle = lsFixedList
        TabOrder = 1
        Width = 139
      end
    end
    object cxTabSheet2: TcxTabSheet
      Caption = 'cxTabSheet2'
      ImageIndex = 1
      object eThreads: TcxSpinEdit
        Left = 206
        Top = 3
        Properties.MaxValue = 50.000000000000000000
        Properties.MinValue = 1.000000000000000000
        TabOrder = 0
        Value = 1
        Width = 75
      end
      object chbUseThreadPerRes: TcxCheckBox
        Left = 6
        Top = 29
        Caption = 'chbUseThreadPerRes'
        TabOrder = 1
        Width = 275
      end
      object eThreadPerRes: TcxSpinEdit
        Left = 206
        Top = 57
        Properties.MaxValue = 50.000000000000000000
        Properties.MinValue = 1.000000000000000000
        TabOrder = 2
        Value = 1
        Width = 75
      end
      object ePicThreads: TcxSpinEdit
        Left = 206
        Top = 84
        Properties.MaxValue = 50.000000000000000000
        Properties.MinValue = 1.000000000000000000
        TabOrder = 3
        Value = 1
        Width = 75
      end
      object eRetries: TcxSpinEdit
        Left = 206
        Top = 111
        Properties.AssignedValues.MinValue = True
        Properties.MaxValue = 50.000000000000000000
        TabOrder = 4
        Width = 75
      end
      object lcThreads: TcxLabel
        Left = 6
        Top = 4
        AutoSize = False
        Caption = 'lcThreads'
        Height = 17
        Width = 194
      end
      object lcThreadPerRes: TcxLabel
        Left = 6
        Top = 58
        AutoSize = False
        Caption = 'lcThreadPerRes'
        Height = 17
        Width = 194
      end
      object lcPicThreads: TcxLabel
        Left = 6
        Top = 85
        AutoSize = False
        Caption = 'lcPicThreads'
        Height = 17
        Width = 194
      end
      object lcRetries: TcxLabel
        Left = 6
        Top = 112
        AutoSize = False
        Caption = 'lcRetries'
        Height = 17
        Width = 194
      end
    end
    object cxTabSheet3: TcxTabSheet
      Caption = 'cxTabSheet3'
      ImageIndex = 2
      object chbProxy: TcxCheckBox
        Left = 6
        Top = 3
        Caption = 'chbProxy'
        Properties.OnEditValueChanged = chbProxyPropertiesEditValueChanged
        TabOrder = 0
        Width = 323
      end
      object chbProxyAuth: TcxCheckBox
        Left = 6
        Top = 81
        Caption = 'chbProxyAuth'
        Properties.OnEditValueChanged = chbProxyAuthPropertiesEditValueChanged
        TabOrder = 1
        Width = 323
      end
      object eHost: TcxTextEdit
        Left = 206
        Top = 30
        TabOrder = 2
        Width = 123
      end
      object eProxyLogin: TcxTextEdit
        Left = 206
        Top = 102
        TabOrder = 3
        Width = 123
      end
      object ePort: TcxSpinEdit
        Left = 206
        Top = 57
        TabOrder = 4
        Width = 123
      end
      object eProxyPassword: TcxTextEdit
        Left = 206
        Top = 129
        Properties.EchoMode = eemPassword
        Properties.PasswordChar = #9679
        TabOrder = 5
        Width = 123
      end
      object chbProxySavePWD: TcxCheckBox
        Left = 206
        Top = 156
        Caption = 'chbProxySavePWD'
        TabOrder = 6
        Width = 123
      end
      object lcProxyHost: TcxLabel
        Left = 6
        Top = 31
        AutoSize = False
        Caption = 'lcProxyHost'
        Height = 17
        Width = 194
      end
      object lcProxyPort: TcxLabel
        Left = 6
        Top = 58
        AutoSize = False
        Caption = 'lcProxyPort'
        Height = 17
        Width = 194
      end
      object lcProxyLogin: TcxLabel
        Left = 6
        Top = 103
        AutoSize = False
        Caption = 'lcProxyLogin'
        Height = 17
        Width = 194
      end
      object lcProxyPassword: TcxLabel
        Left = 6
        Top = 130
        AutoSize = False
        Caption = 'lcProxyPassword'
        Height = 17
        Width = 194
      end
    end
    object cxTabSheet4: TcxTabSheet
      Caption = 'cxTabSheet4'
      ImageIndex = 3
      object vgSettings: TcxVerticalGrid
        Left = 0
        Top = 0
        Width = 279
        Height = 273
        Align = alClient
        OptionsView.GridLineColor = clBtnShadow
        OptionsView.RowHeaderWidth = 148
        TabOrder = 0
        Version = 1
      end
    end
  end
end
