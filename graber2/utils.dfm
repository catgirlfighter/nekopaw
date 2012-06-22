object dm: Tdm
  OldCreateOrder = False
  Height = 401
  Width = 516
  object EditRepository: TcxEditRepository
    Left = 24
    Top = 8
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
    object erPassword: TcxEditRepositoryTextItem
      Properties.EchoMode = eemPassword
      Properties.PasswordChar = #9679
    end
    object erFloatEdit: TcxEditRepositoryCurrencyItem
      Properties.DisplayFormat = '0.##'
    end
    object erRDFloatEdit: TcxEditRepositoryCurrencyItem
      Properties.DisplayFormat = '0.##'
      Properties.ReadOnly = True
    end
    object erRDTextEdit: TcxEditRepositoryTextItem
      Properties.ReadOnly = True
    end
    object erRDPassword: TcxEditRepositoryTextItem
      Properties.EchoMode = eemPassword
      Properties.PasswordChar = #9679
    end
    object erRDCheckBox: TcxEditRepositoryCheckBoxItem
      Properties.ReadOnly = True
    end
  end
end
