object fGrid2: TfGrid2
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  TabOrder = 0
  object BarControl: TdxBarDockControl
    Left = 0
    Top = 0
    Width = 451
    Height = 26
    Align = dalTop
    BarManager = BarManager
  end
  object vTree: TcxVirtualTreeList
    Left = 0
    Top = 26
    Width = 451
    Height = 278
    Hint = ''
    Align = alClient
    Bands = <
      item
      end>
    Navigator.Buttons.CustomButtons = <>
    OptionsCustomizing.BandCustomizing = False
    OptionsData.SmartLoad = True
    OptionsView.ColumnAutoWidth = True
    TabOrder = 5
    OnGetChildCount = vTreeGetChildCount
    OnGetNodeValue = vTreeGetNodeValue
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
    Left = 208
    Top = 192
    DockControlHeights = (
      0
      0
      0
      0)
    object TableActions: TdxBar
      AllowClose = False
      Caption = 'Table'
      CaptionButtons = <>
      DockControl = BarControl
      DockedDockControl = BarControl
      DockedLeft = 0
      DockedTop = 0
      FloatLeft = 461
      FloatTop = 0
      FloatClientWidth = 51
      FloatClientHeight = 88
      ItemLinks = <
        item
          Visible = True
          ItemName = 'siCheck'
        end
        item
          Visible = True
          ItemName = 'siUncheck'
        end
        item
          Visible = True
          ItemName = 'bbColumns'
        end
        item
          Visible = True
          ItemName = 'bbFilter'
        end
        item
          Visible = True
          ItemName = 'bbAdditional'
        end>
      NotDocking = [dsNone, dsLeft, dsTop, dsRight, dsBottom]
      OneOnRow = True
      Row = 0
      UseOwnFont = False
      UseRestSpace = True
      Visible = True
      WholeRow = False
    end
    object bbColumns: TdxBarButton
      Caption = 'bbColumns'
      Category = 0
      Hint = 'bbColumns'
      Visible = ivAlways
      ImageIndex = 9
    end
    object bbFilter: TdxBarButton
      Caption = 'bbFilter'
      Category = 0
      Hint = 'bbFilter'
      Visible = ivAlways
      ButtonStyle = bsChecked
      ImageIndex = 10
    end
    object bbSelect: TdxBarButton
      Caption = 'bbSelect'
      Category = 0
      Hint = 'bbSelect'
      Visible = ivAlways
    end
    object bbUnselect: TdxBarButton
      Caption = 'bbUnselect'
      Category = 0
      Hint = 'bbUnselect'
      Visible = ivAlways
    end
    object siCheck: TdxBarSubItem
      Caption = 'siCheck'
      Category = 0
      Visible = ivAlways
      ImageIndex = 7
      ShowCaption = False
      ItemLinks = <
        item
          Visible = True
          ItemName = 'bbCheckAll'
        end
        item
          Visible = True
          ItemName = 'bbCheckSelected'
        end
        item
          Visible = True
          ItemName = 'bbCheckFiltered'
        end
        item
          Visible = True
          ItemName = 'bbInverseChecked'
        end
        item
          Visible = True
          ItemName = 'bbCheckBlacklisted'
        end>
    end
    object siUncheck: TdxBarSubItem
      Caption = 'siUncheck'
      Category = 0
      Visible = ivAlways
      ImageIndex = 8
      ShowCaption = False
      ItemLinks = <
        item
          Visible = True
          ItemName = 'bbUncheckAll'
        end
        item
          Visible = True
          ItemName = 'bbUncheckSelected'
        end
        item
          Visible = True
          ItemName = 'bbUncheckFiltered'
        end
        item
          Visible = True
          ItemName = 'bbUncheckBlacklisted'
        end>
    end
    object bbCheckAll: TdxBarButton
      Caption = 'bbCheckAll'
      Category = 0
      Hint = 'bbCheckAll'
      Visible = ivAlways
    end
    object bbCheckSelected: TdxBarButton
      Caption = 'bbCheckSelected'
      Category = 0
      Hint = 'bbCheckSelected'
      Visible = ivAlways
    end
    object bbCheckFiltered: TdxBarButton
      Caption = 'bbCheckFiltered'
      Category = 0
      Hint = 'bbCheckFiltered'
      Visible = ivAlways
    end
    object bbInverseChecked: TdxBarButton
      Caption = 'bbInverseChecked'
      Category = 0
      Hint = 'bbInverseChecked'
      Visible = ivAlways
    end
    object bbUncheckAll: TdxBarButton
      Caption = 'bbUncheckAll'
      Category = 0
      Hint = 'bbUncheckAll'
      Visible = ivAlways
    end
    object bbUncheckSelected: TdxBarButton
      Caption = 'bbUncheckSelected'
      Category = 0
      Hint = 'bbUncheckSelected'
      Visible = ivAlways
    end
    object bbUncheckFiltered: TdxBarButton
      Caption = 'bbUncheckFiltered'
      Category = 0
      Hint = 'bbUncheckFiltered'
      Visible = ivAlways
    end
    object bbAdditional: TdxBarSubItem
      Caption = 'bbAdditional'
      Category = 0
      Visible = ivAlways
      ImageIndex = 11
      ShowCaption = False
      ItemLinks = <
        item
          Visible = True
          ItemName = 'bbDALF'
        end
        item
          Visible = True
          ItemName = 'bbAutoUnch'
        end
        item
          Visible = True
          ItemName = 'bbWriteEXIF'
        end>
    end
    object bbDALF: TdxBarButton
      Caption = 'bbDALF'
      Category = 0
      Hint = 'bbDALF'
      Visible = ivAlways
      ButtonStyle = bsChecked
      UnclickAfterDoing = False
    end
    object bbAutoUnch: TdxBarButton
      Caption = 'bbAutoUnch'
      Category = 0
      Hint = 'bbAutoUnch'
      Visible = ivAlways
      ButtonStyle = bsChecked
    end
    object bbWriteEXIF: TdxBarButton
      Caption = 'bbWriteEXIF'
      Category = 0
      Hint = 'bbWriteEXIF'
      Visible = ivAlways
    end
    object bbUncheckBlacklisted: TdxBarButton
      Caption = 'bbUncheckBlacklisted'
      Category = 0
      Hint = 'bbUncheckBlacklisted'
      Visible = ivAlways
    end
    object bbCheckBlacklisted: TdxBarButton
      Caption = 'bbCheckBlacklisted'
      Category = 0
      Hint = 'bbCheckBlacklisted'
      Visible = ivAlways
    end
  end
  object cxEditRepository1: TcxEditRepository
    Left = 240
    Top = 104
    object iPicChecker: TcxEditRepositoryCheckBoxItem
      Properties.ImmediatePost = True
    end
    object iCheckBox: TcxEditRepositoryCheckBoxItem
      Properties.ReadOnly = True
    end
    object iPBar: TcxEditRepositoryProgressBar
      Properties.AnimationPath = cxapPingPong
    end
    object iFloatEdit: TcxEditRepositoryCurrencyItem
      Properties.DisplayFormat = '0.00'
      Properties.EditFormat = '0.00'
      Properties.ReadOnly = True
      Properties.UseDisplayFormatWhenEditing = True
    end
    object iLabel: TcxEditRepositoryLabel
    end
    object iState: TcxEditRepositoryImageComboBoxItem
      Properties.Images = dm.il
      Properties.ImmediateDropDownWhenKeyPressed = False
      Properties.Items = <
        item
          Description = 'START'
          ImageIndex = 12
          Value = 'START'
        end
        item
          Description = 'OK'
          ImageIndex = 13
          Value = 'OK'
        end
        item
          Description = 'SKIP'
          ImageIndex = 14
          Value = 'SKIP'
        end
        item
          Description = 'ERROR'
          ImageIndex = 15
          Value = 'ERROR'
        end
        item
          Description = 'ABORT'
          ImageIndex = 19
          Value = 'ABORT'
        end
        item
          Description = 'REFRESH'
          ImageIndex = 20
          Value = 'REFRESH'
        end
        item
          Description = 'DELAY'
          ImageIndex = 22
          Value = 'DELAY'
        end
        item
          Description = 'BLACKLISTED'
          ImageIndex = 25
          Value = 'BLACKLISTED'
        end>
      Properties.ReadOnly = True
      Properties.ShowDescriptions = False
    end
  end
end
