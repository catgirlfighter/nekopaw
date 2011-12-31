object MainForm: TMainForm
  Left = 280
  Top = 148
  Caption = 'imagegraber'
  ClientHeight = 523
  ClientWidth = 548
  Color = clBtnFace
  Constraints.MinHeight = 550
  Constraints.MinWidth = 556
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object splMenu: TSplitter
    Left = 0
    Top = 158
    Width = 548
    Height = 3
    Cursor = crVSplit
    Align = alTop
    AutoSnap = False
    MinSize = 1
    OnCanResize = splMenuCanResize
    OnMoved = splMenuMoved
    ExplicitLeft = 2
    ExplicitTop = 160
    ExplicitWidth = 552
  end
  object pcMenu: TSpTBXTabControl
    Left = 0
    Top = 0
    Width = 548
    Height = 158
    Align = alTop
    Constraints.MinHeight = 158
    ParentShowHint = False
    ShowHint = True
    OnMouseDown = pcMenuMouseDown
    ActiveTabIndex = 1
    OnActiveTabChange = pcMenuActiveTabChange
    OnActiveTabChanging = pcMenuActiveTabChanging
    ExplicitTop = 2
    HiddenItems = <>
    object TBControlItem3: TTBControlItem
      Control = iIcon
    end
    object tsiPicList: TSpTBXTabItem
      Caption = 'Get'
      Checked = True
      OnDrawCaption = tsiPicListDrawCaption
    end
    object tbiLoad: TSpTBXItem
      Caption = 'Load'
      OnClick = tbiLoadClick
    end
    object tbiSave: TSpTBXItem
      Caption = 'Save'
      OnClick = tbiSaveClick
    end
    object tsiMetadata: TSpTBXTabItem
      Caption = 'Metadata'
      OnDrawCaption = tsiPicListDrawCaption
    end
    object tsiDownloading: TSpTBXTabItem
      Caption = 'Download'
      OnDrawCaption = tsiPicListDrawCaption
    end
    object tsiSettings: TSpTBXTabItem
      Caption = 'Settings'
      OnDrawCaption = tsiPicListDrawCaption
    end
    object tbrasMenu: TSpTBXRightAlignSpacerItem
      CustomWidth = 124
    end
    object lblCaption: TSpTBXLabelItem
      Caption = 'graber'
    end
    object SpTBXItem1: TSpTBXItem
      ImageIndex = 2
      Images = il
      OnClick = SpTBXItem1Click
    end
    object tbiMenuHide: TSpTBXItem
      Hint = 'Hide panel'
      ImageIndex = 1
      Images = il
      Options = [tboShowHint]
      OnClick = tbiMenuHideClick
      FontSettings.Size = 90
    end
    object tbiMinimize: TSpTBXItem
      OnClick = tbiMinimizeClick
    end
    object tbiMaximize: TSpTBXItem
      OnClick = tbiMaximizeClick
    end
    object tbiClose: TSpTBXItem
      OnClick = tbiCloseClick
    end
    object iIcon: TImage
      Left = 0
      Top = 0
      Width = 22
      Height = 22
      Center = True
      OnMouseDown = iIconMouseDown
    end
    object Image1: TImage
      Left = 4
      Top = 2
      Width = 32
      Height = 32
    end
    object tsSettings: TSpTBXTabSheet
      Left = 0
      Top = 26
      Width = 548
      Height = 132
      Caption = 'Settings'
      ImageIndex = -1
      DesignSize = (
        548
        132)
      TabItem = 'tsiSettings'
      object iLain: TImage
        Left = 444
        Top = 7
        Width = 101
        Height = 122
        Anchors = [akRight, akBottom]
        Center = True
        Visible = False
        OnDblClick = iLainDblClick
      end
      object gbWindow: TGroupBox
        Left = 234
        Top = 4
        Width = 134
        Height = 123
        Caption = 'Window'
        TabOrder = 0
        object chbTrayIcon: TCheckBox
          Left = 8
          Top = 23
          Width = 114
          Height = 17
          Caption = 'show tray icon'
          TabOrder = 0
          OnClick = chbTrayIconClick
        end
        object chbTaskbar: TCheckBox
          Left = 8
          Top = 46
          Width = 114
          Height = 17
          Caption = 'hide on minimize'
          TabOrder = 1
          OnClick = chbTaskbarClick
        end
        object chbKeepInstance: TCheckBox
          Left = 8
          Top = 69
          Width = 114
          Height = 17
          Caption = 'keep one instance'
          TabOrder = 2
          OnClick = chbKeepInstanceClick
        end
        object chbSaveNote: TCheckBox
          Left = 8
          Top = 92
          Width = 124
          Height = 17
          Caption = 'save note on closing'
          Checked = True
          State = cbChecked
          TabOrder = 3
          OnClick = chbKeepInstanceClick
        end
      end
      object gbWork: TGroupBox
        Left = 200
        Top = 133
        Width = 226
        Height = 113
        Caption = 'Work'
        TabOrder = 1
        object lThreads: TLabel
          Left = 27
          Top = 23
          Width = 65
          Height = 13
          Caption = 'threads count'
        end
        object lRetries: TLabel
          Left = 26
          Top = 46
          Width = 109
          Height = 13
          Caption = 'count of retries on error'
        end
        object eThreadCount: TJvSpinEdit
          Left = 148
          Top = 20
          Width = 69
          Height = 21
          MaxValue = 50.000000000000000000
          MinValue = 1.000000000000000000
          Value = 1.000000000000000000
          TabOrder = 0
        end
        object chbOpenDrive: TCheckBox
          Left = 8
          Top = 68
          Width = 134
          Height = 17
          Caption = 'open cd-drive after end'
          TabOrder = 1
          OnClick = chbOpenDriveClick
        end
        object cbLetter: TJvDriveCombo
          Left = 148
          Top = 66
          Width = 69
          Height = 22
          DriveTypes = [dtCDROM]
          Offset = 1
          TabOrder = 2
        end
        object chbdebug: TCheckBox
          Left = 8
          Top = 91
          Width = 134
          Height = 17
          Caption = 'debug mode'
          TabOrder = 3
          OnClick = chbOpenDriveClick
        end
        object eRetries: TJvSpinEdit
          Left = 147
          Top = 44
          Width = 70
          Height = 21
          MaxValue = 50.000000000000000000
          TabOrder = 4
        end
      end
      object gbProxy: TGroupBox
        Left = 3
        Top = 4
        Width = 221
        Height = 123
        Caption = 'Proxy'
        TabOrder = 2
        object chbproxy: TCheckBox
          Left = 8
          Top = 23
          Width = 98
          Height = 17
          Caption = 'HTTP proxy'
          TabOrder = 0
          OnClick = chbproxyClick
        end
        object chbauth: TCheckBox
          Left = 112
          Top = 23
          Width = 102
          Height = 17
          Caption = 'Authentification'
          TabOrder = 1
          OnClick = chbauthClick
        end
        object chbsaveproxypwd: TCheckBox
          Left = 112
          Top = 97
          Width = 102
          Height = 17
          Caption = 'save password'
          TabOrder = 2
          OnClick = chbsavepwdClick
        end
        object eproxyserver: TJvEdit
          Left = 8
          Top = 43
          Width = 100
          Height = 21
          EmptyValue = 'gateway'
          DisabledColor = clBtnFace
          TabOrder = 3
        end
        object eproxypassword: TJvEdit
          Left = 112
          Top = 70
          Width = 100
          Height = 21
          EmptyValue = 'Password'
          DisabledColor = clBtnFace
          PasswordChar = #9679
          TabOrder = 4
        end
        object eproxylogin: TJvEdit
          Left = 112
          Top = 43
          Width = 100
          Height = 21
          EmptyValue = 'Login'
          DisabledColor = clBtnFace
          TabOrder = 5
        end
        object eproxyport: TJvSpinEdit
          Left = 8
          Top = 70
          Width = 100
          Height = 21
          CheckMinValue = True
          Value = 3128.000000000000000000
          TabOrder = 6
        end
      end
      object GroupBox1: TGroupBox
        Left = 4
        Top = 133
        Width = 190
        Height = 113
        Caption = 'Queries interval'
        TabOrder = 3
        object lQueryI: TLabel
          Left = 27
          Top = 23
          Width = 34
          Height = 13
          Caption = 'interval'
        end
        object eQueryI: TJvSpinEdit
          Left = 92
          Top = 20
          Width = 86
          Height = 21
          MaxValue = 10.000000000000000000
          Value = 3.000000000000000000
          TabOrder = 0
        end
        object chbBfGet: TCheckBox
          Left = 8
          Top = 44
          Width = 170
          Height = 17
          Caption = 'before getting url'
          TabOrder = 1
          OnClick = chbOpenDriveClick
        end
        object chbBfDwnld: TCheckBox
          Left = 8
          Top = 67
          Width = 170
          Height = 17
          Caption = 'before downloading pic'
          TabOrder = 2
          OnClick = chbOpenDriveClick
        end
        object chbAftDwnld: TCheckBox
          Left = 9
          Top = 90
          Width = 170
          Height = 17
          Caption = 'after downloading pic'
          TabOrder = 3
          OnClick = chbOpenDriveClick
        end
      end
    end
    object tsDownloading: TSpTBXTabSheet
      Left = 0
      Top = 26
      Width = 548
      Height = 132
      Caption = 'Download'
      ImageIndex = -1
      DesignSize = (
        548
        132)
      TabItem = 'tsiDownloading'
      object ldir: TLabel
        Left = 3
        Top = 7
        Width = 24
        Height = 13
        Caption = ' path'
      end
      object lIfExists: TLabel
        Left = 9
        Top = 35
        Width = 45
        Height = 13
        AutoSize = False
        Caption = 'if exists'
      end
      object btnGrab: TButton
        Left = 414
        Top = 3
        Width = 51
        Height = 23
        Anchors = [akTop, akRight]
        Caption = 'Grab!'
        Default = True
        TabOrder = 0
        OnClick = btnGrabClick
      end
      object chbdownloadalbums: TCheckBox
        Left = 9
        Top = 82
        Width = 144
        Height = 17
        Caption = 'download albums'
        TabOrder = 1
        OnClick = chbdownloadalbumsClick
      end
      object chbcreatenewdirs: TCheckBox
        Left = 9
        Top = 103
        Width = 144
        Height = 17
        Caption = 'create new dirs for albums'
        TabOrder = 2
      end
      object cbExistingFile: TComboBox
        Left = 52
        Top = 32
        Width = 101
        Height = 21
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 3
        Text = 'skip'
        Items.Strings = (
          'skip'
          'replace'
          'rename')
      end
      object chbTagsIn: TCheckBox
        Left = 173
        Top = 59
        Width = 66
        Height = 17
        Caption = 'all tags in'
        TabOrder = 4
        OnClick = chbNameFormatClick
      end
      object edir: TJvDirectoryEdit
        Left = 33
        Top = 4
        Width = 259
        Height = 21
        AcceptFiles = False
        DisabledColor = clBtnFace
        DialogKind = dkWin32
        AutoCompleteOptions = [acoAutoSuggest, acoAutoAppend]
        DialogOptionsWin32 = [odStatusAvailable, odEditBox, odNewDialogStyle]
        ClickKey = 0
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 5
        Text = 'edir'
      end
      object btnBrowse: TBitBtn
        Left = 298
        Top = 3
        Width = 23
        Height = 23
        Hint = 'Browse'
        Anchors = [akTop, akRight]
        DoubleBuffered = True
        Glyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          18000000000000030000C40E0000C40E0000000000000000000080FFFF80FFFF
          80FFFF80FFFF80FFFF80FFFF80FFFF80FFFF80FFFF80FFFF80FFFF80FFFF80FF
          FFD5D7D6D3D2CF80FFFF80FFFF80FFFF80FFFF80FFFF80FFFF80FFFF80FFFF80
          FFFF80FFFF80FFFF80FFFF80FFFFB1ACA9877280646786B9AEAB80FFFF80FFFF
          80FFFF80FFFF80FFFF80FFFF80FFFF80FFFF80FFFF80FFFF80FFFFB1ACA98F73
          7F6D7AB6378AE483ACD180FFFF80FFFF80FFFF80FFFF80FFFF80FFFF80FFFF80
          FFFF80FFFF80FFFFB1ADAA92747F6D79B53993E858C0FFBEE5FF80FFFF80FFFF
          80FFFF80FFFF80FFFF80FFFF80FFFF80FFFF80FFFFB6B0AE8F737E6D78B53B95
          EA57BFFFC9E6FD80FFFF80FFFF80FFFF80FFFFE7E8E9BBB5B6ADA5A7B4AFB0DA
          D9DBE9EDEE8F83856474B23993E957BFFFC5E4FD80FFFF80FFFF80FFFF80FFFF
          C1BDBF877D75C6AE99E1CBB1CFB7A0B9998A9D8583817B7D5695D457BDFDC8E6
          FD80FFFF80FFFF80FFFF80FFFFC1C1C18B7879F4EAE0FFFFFAFFFFE6FFFFD8FF
          FDCAF2CFA9B4928AC9CAC9DEEEFB80FFFF80FFFF80FFFF80FFFFECEFEF897672
          ECDED0FFFFFFFFFFFFFFFFFFFFFED5FFF4C0FFF6C3EDC8A3D4C5C180FFFF80FF
          FF80FFFF80FFFF80FFFFD0CCCDAA8C82FFFFE7FFFFFFFFFFFFFFFFFFFFFFDBFF
          F3C3FFE2B1FDEFBDE0C8BE80FFFF80FFFF80FFFF80FFFF80FFFFCEC7C9C0A690
          FFFFDCFFFFECFFFFF4FFFFF4FFFED3FFF1C0FFD6A6FEEFBDE2C8B6F9F4F580FF
          FF80FFFF80FFFF80FFFFD0CCD0BBA18FFFFFD1FFFDD2FFFED1FFFED1FFF9C7FF
          E5B2FFDFACFFF4C2E1C6B3F9F4F580FFFF80FFFF80FFFF80FFFFECECEDAB8F89
          FDEFBFFFF4C2FFECBBFFEEBDFFE0AEFFE4BBFFF8EAF8F0D3DEC7BA80FFFF80FF
          FF80FFFF80FFFF80FFFF80FFFFC8C0C2CDA68BFFF7C2FFEBB7FFDCAAFFE5B5FF
          FEF5FCFBFDDFC5B8F8F2EE80FFFF80FFFF80FFFF80FFFF80FFFF80FFFF80FFFF
          C4B8BAD4B097F8E2B4FFF4C4FDF0C5ECDFC2DAC0B9F0E7E480FFFF80FFFF80FF
          FF80FFFF80FFFF80FFFF80FFFF80FFFF80FFFFE5DEE0DDC2B9C4B6AABEAEA5E0
          D0CCF5EEEB80FFFF80FFFF80FFFF80FFFF80FFFF80FFFF80FFFF}
        ParentDoubleBuffered = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 6
        OnClick = btnBrowseClick
      end
      object btnDefDir: TBitBtn
        Left = 327
        Top = 3
        Width = 23
        Height = 23
        Hint = 'Set as default'
        Anchors = [akTop, akRight]
        DoubleBuffered = True
        Glyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          18000000000000030000120B0000120B0000000000000000000000F0FF00F0FF
          00F0FF00F0FF00F0FF00F0FF00F0FF00F0FF00F0FF00F0FF00F0FF00F0FF00F0
          FF00F0FF00F0FF00F0FF00F0FF00F0FFE8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8
          E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E8E800F0FF00F0FFD0D0D0
          7171715959595959595959595959595959595959595959595959595959595959
          59595959717171D0D0D000F0FF1D82B51B81B3187EB0167CAE1379AB1076A80D
          73A50B71A3086EA0066C9E046A9C02689A0167994141417171712287BA67CCFF
          2085B899FFFF6FD4FF6FD4FF6FD4FF6FD4FF3A66C43A66C46FD4FF6FD4FF3BA0
          D399FFFF016799595959258ABD67CCFF278CBF99FFFF7BE0FF7BE0FF7BE0FF7B
          E0FF1628AA0C14A177D8FB7BE0FF44A9DC99FFFF02689A595959288DC067CCFF
          2D92C599FFFF85EBFF85EBFF85EBFF3A66C4101CA41A2DAB2C4DB985EBFF4EB3
          E699FFFF046A9C5959592A8FC267CCFF3398CB99FFFF91F7FF91F7FF6AB3E30C
          15A171BFE876C7EB0C14A076C7EB57BCEF99FFFF066C9E5959592D92C56FD4FF
          3499CC99FFFF99FFFF8CE9F6101BA3416DC499FFFF99FFFF2F4FB81F34AD60C5
          F899FFFF086EA05959592F94C77BE0FF2D92C5FFFFFFFFFFFFFFFFFFFFFFFFFA
          FAFDFFFFFFFFFFFFF5F6FB0E15A15699DCFFFFFF0B71A37171713196C985EBFF
          81E6FF2D92C52D92C52D92C52D92C52D92C52D92C5288DC02489BC1446AA0B16
          A01B81B31B81B3D8D8D83398CB91F7FF8EF4FF8EF4FF8EF4FF8EF4FF8EF4FFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFF0B18A02C3082666666D2D2D23499CCFFFFFF
          99FFFF99FFFF99FFFF99FFFFFFFFFF258ABD2287BA1F84B71D82B51B81B3135A
          AA0D14A07F808FB6B6B600F0FF3499CCFFFFFFFFFFFFFFFFFFFFFFFF2A8FC2D0
          D0D000F0FF00F0FF00F0FF00F0FF00F0FF353BB07175C200F0FF00F0FF00F0FF
          3499CC3398CB3196C92F94C7E8E8E800F0FF00F0FF00F0FF00F0FF00F0FF00F0
          FF00F0FF00F0FF00F0FF00F0FF00F0FF00F0FF00F0FF00F0FF00F0FF00F0FF00
          F0FF00F0FF00F0FF00F0FF00F0FF00F0FF00F0FF00F0FF00F0FF}
        ParentDoubleBuffered = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 7
        OnClick = btnDefDirClick
      end
      object btnLoadDefDir: TBitBtn
        Left = 356
        Top = 3
        Width = 23
        Height = 23
        Hint = 'Load default'
        Anchors = [akTop, akRight]
        DoubleBuffered = True
        Glyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          18000000000000030000120B0000120B0000000000000000000000F0FF00F0FF
          00F0FF00F0FF00F0FF00F0FF00F0FFEECEA8EECEA800F0FF00F0FF00F0FF00F0
          FF00F0FF00F0FF00F0FF00F0FF00F0FFDFDFDFD6D6D6D6D6D6D6D6D6EECEA811
          6A01307001EECEA8D6D6D6D6D6D6D6D6D6D6D6D6DFDFDF00F0FF00F0FFC8C8C8
          8383836D6D6D6D6D6DEECEA8016A0148E07B48E07B1D6901EECEA86D6D6D6D6D
          6D6D6D6D838383C8C8C8DFDFDF1D82B51B81B3187EB0EECEA8056E0848E07B48
          E07B48E07B48E07B0E6701EECEA802689A0167994C4C4C8383832287BA67CCFF
          2085B8EECEA807740E3BD36E3BD36E3BD36E3BD36E3BD36E3BD36E046D07EECE
          A899FFFF0167996E6E6E258ABD67CCFFEECEA809791131C96131C96131C96131
          C96131C96131C96131C96131C961036D06EECEA802689A6D6D6D288DC067CCFF
          01670101670101670101670121B94121B94121B94121B9410167010167010167
          01016701046A9C6D6D6D2A8FC267CCFF3398CB99FFFF91F7FF01670115AD2715
          AD2715AD2715AD2701670191F7FF57BCEF99FFFF066C9E6D6D6D2D92C56FD4FF
          3499CC99FFFF99FFFF01670108A00E08A00E08A00E08A00E01670199FFFF60C5
          F899FFFF086EA06E6E6E2F94C77BE0FF2D92C5FFFFFFFFFFFF01670101670101
          6701016701016701016701FFFFFF81E6FFFFFFFF0B71A38C8C8C3196C985EBFF
          81E6FF2D92C52D92C52D92C52D92C52D92C52D92C5288DC02489BC2085B81C81
          B41B81B31B81B3DFDFDF3398CB91F7FF8EF4FF8EF4FF8EF4FF8EF4FF8EF4FFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFF167CAE8C8C8CDEDEDE00F0FF3499CCFFFFFF
          99FFFF99FFFF99FFFF99FFFFFFFFFF258ABD2287BA1F84B71D82B51B81B3187E
          B0DFDFDF00F0FF00F0FF00F0FF3499CCFFFFFFFFFFFFFFFFFFFFFFFF2A8FC2C8
          C8C800F0FF00F0FF00F0FF00F0FF00F0FF00F0FF00F0FF00F0FF00F0FF00F0FF
          3499CC3398CB3196C92F94C7DFDFDF00F0FF00F0FF00F0FF00F0FF00F0FF00F0
          FF00F0FF00F0FF00F0FF00F0FF00F0FF00F0FF00F0FF00F0FF00F0FF00F0FF00
          F0FF00F0FF00F0FF00F0FF00F0FF00F0FF00F0FF00F0FF00F0FF}
        ParentDoubleBuffered = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 8
        OnClick = btnLoadDefDirClick
      end
      object chbAutoDirName: TCheckBox
        Left = 173
        Top = 34
        Width = 97
        Height = 17
        Hint = '?s - res.name; ?t - tag string'
        Caption = 'auto dir name (&?)'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 9
        OnClick = chbAutoDirNameClick
      end
      object eAutoDirName: TEdit
        Left = 276
        Top = 32
        Width = 56
        Height = 21
        Hint = '?s - res.name; ?t - tag string'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 10
        Text = '?t\?s'
      end
      object chbSaveJPEGMeta: TCheckBox
        Left = 9
        Top = 59
        Width = 144
        Height = 17
        Caption = 'save meta to JPEG'
        Checked = True
        State = cbChecked
        TabOrder = 11
        OnClick = chbdownloadalbumsClick
      end
      object chbNameFormat: TCheckBox
        Left = 173
        Top = 82
        Width = 97
        Height = 17
        Hint = 
          '?a - author nicname, ?l - author loginname,  ?n - title, ?i - im' +
          'age id, ?p - page, ?t - tagtring'
        Caption = 'name format (&?)'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 12
        OnClick = chbNameFormatClick
      end
      object eNameFormat: TEdit
        Left = 276
        Top = 80
        Width = 56
        Height = 21
        Hint = 
          '?a - author nicname, ?l - author loginname,  ?n - title, ?i - im' +
          'age id, ?p[{text}/] - page string, ?t - tagtring'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 13
        Text = '?i?p_p/'
      end
      object cbTagsIn: TComboBox
        Left = 245
        Top = 57
        Width = 87
        Height = 21
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 14
        Text = 'filename'
        Items.Strings = (
          'filename'
          'csv file')
      end
      object chbOrigFNames: TCheckBox
        Left = 173
        Top = 103
        Width = 159
        Height = 17
        Caption = 'original filenames'
        TabOrder = 15
        OnClick = chbOrigFNamesClick
      end
      object chbQueryI2: TCheckBox
        Left = 346
        Top = 82
        Width = 97
        Height = 17
        Caption = 'query interval'
        Checked = True
        State = cbChecked
        TabOrder = 16
      end
      object chbIncFNames: TCheckBox
        Left = 346
        Top = 59
        Width = 159
        Height = 17
        Caption = 'incremental filenames'
        TabOrder = 17
      end
      object btnAuth2: TBitBtn
        Left = 385
        Top = 3
        Width = 23
        Height = 23
        Hint = 'Authentication'
        Anchors = [akTop, akRight]
        DoubleBuffered = True
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
        ParentDoubleBuffered = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 18
        OnClick = btnAuth2Click
      end
    end
    object tsMetadata: TSpTBXTabSheet
      Left = 0
      Top = 26
      Width = 548
      Height = 132
      Caption = 'Metadata'
      ImageIndex = -1
      DesignSize = (
        548
        132)
      TabItem = 'tsiMetadata'
      object lCntFilter: TLabel
        Left = 218
        Top = 64
        Width = 41
        Height = 13
        Caption = 'Cnt. filter'
      end
      object btnSelAll: TSpeedButton
        Left = 218
        Top = 23
        Width = 25
        Height = 25
        Hint = 'Select all'
        Glyph.Data = {
          3E020000424D3E0200000000000036000000280000000D0000000D0000000100
          18000000000008020000C40E0000C40E00000000000000000000000000000000
          000000000000BD9A78BD9A78BD9A78BD9A78BD9A78BD9A78BD9A78BD9A78BD9A
          7800000000000000000000000000BD9A78EFEBE6EFEBE6EFEBE6EFEBE6EFEBE6
          EFEBE6EFEBE6BD9A7800000000000000BD9A78BD9A78BD9A78BD9A78BD9A78BD
          9A78BD9A78BD9A78BD9A78EFEBE6BD9A7800000000000000BD9A78EFEBE6EFEB
          E6EFEBE6EFEBE6EFEBE6EFEBE6EFEBE6BD9A78EFEBE6BD9A7800BD9A78BD9A78
          BD9A78BD9A78BD9A78BD9A78BD9A78BD9A78BD9A78EFEBE6BD9A78EFEBE6BD9A
          7800BD9A78EFEBE6EFEBE6EFEBE6EFEBE6EFEBE6EFEBE6EFEBE6BD9A78EFEBE6
          BD9A78EFEBE6BD9A7800BD9A78EFEBE6EFEBE61E2D30EFEBE6EFEBE6EFEBE6EF
          EBE6BD9A78EFEBE6BD9A78EFEBE6BD9A7800BD9A78EFEBE61E2D301E2D301E2D
          30EFEBE6EFEBE6EFEBE6BD9A78EFEBE6BD9A78EFEBE6BD9A7800BD9A78EFEBE6
          1E2D30EFEBE61E2D301E2D30EFEBE6EFEBE6BD9A78EFEBE6BD9A78BD9A78BD9A
          7800BD9A78EFEBE6EFEBE6EFEBE6EFEBE61E2D301E2D30EFEBE6BD9A78EFEBE6
          BD9A7800000000000000BD9A78EFEBE6EFEBE6EFEBE6EFEBE6EFEBE61E2D30EF
          EBE6BD9A78BD9A78BD9A7800000000000000BD9A78EFEBE6EFEBE6EFEBE6EFEB
          E6EFEBE6EFEBE6EFEBE6BD9A7800000000000000000000000000BD9A78BD9A78
          BD9A78BD9A78BD9A78BD9A78BD9A78BD9A78BD9A780000000000000000000000
          0000}
        ParentShowHint = False
        ShowHint = True
        OnClick = btnSelAllClick
      end
      object btnDeselAll: TSpeedButton
        Left = 249
        Top = 23
        Width = 25
        Height = 25
        Hint = 'Deselect all'
        Glyph.Data = {
          3E020000424D3E0200000000000036000000280000000D0000000D0000000100
          18000000000008020000C40E0000C40E00000000000000000000000000000000
          000000000000BD9A78BD9A78BD9A78BD9A78BD9A78BD9A78BD9A78BD9A78BD9A
          7800000000000000000000000000BD9A78EFEBE6EFEBE6EFEBE6EFEBE6EFEBE6
          EFEBE6EFEBE6BD9A7800000000000000BD9A78BD9A78BD9A78BD9A78BD9A78BD
          9A78BD9A78BD9A78BD9A78EFEBE6BD9A7800000000000000BD9A78EFEBE6EFEB
          E6EFEBE6EFEBE6EFEBE6EFEBE6EFEBE6BD9A78EFEBE6BD9A7800BD9A78BD9A78
          BD9A78BD9A78BD9A78BD9A78BD9A78BD9A78BD9A78EFEBE6BD9A78EFEBE6BD9A
          7800BD9A78EFEBE6EFEBE6EFEBE6EFEBE6EFEBE6EFEBE6EFEBE6BD9A78EFEBE6
          BD9A78EFEBE6BD9A7800BD9A78EFEBE6EFEBE6EFEBE6EFEBE6EFEBE6EFEBE6EF
          EBE6BD9A78EFEBE6BD9A78EFEBE6BD9A7800BD9A78EFEBE6EFEBE6EFEBE6EFEB
          E6EFEBE6EFEBE6EFEBE6BD9A78EFEBE6BD9A78EFEBE6BD9A7800BD9A78EFEBE6
          EFEBE6EFEBE6EFEBE6EFEBE6EFEBE6EFEBE6BD9A78EFEBE6BD9A78BD9A78BD9A
          7800BD9A78EFEBE6EFEBE6EFEBE6EFEBE6EFEBE6EFEBE6EFEBE6BD9A78EFEBE6
          BD9A7800000000000000BD9A78EFEBE6EFEBE6EFEBE6EFEBE6EFEBE6EFEBE6EF
          EBE6BD9A78BD9A78BD9A7800000000000000BD9A78EFEBE6EFEBE6EFEBE6EFEB
          E6EFEBE6EFEBE6EFEBE6BD9A7800000000000000000000000000BD9A78BD9A78
          BD9A78BD9A78BD9A78BD9A78BD9A78BD9A78BD9A780000000000000000000000
          0000}
        ParentShowHint = False
        ShowHint = True
        OnClick = btnDeselAllClick
      end
      object btnSelInverse: TSpeedButton
        Left = 280
        Top = 23
        Width = 25
        Height = 25
        Hint = 'Inverse selection'
        Glyph.Data = {
          3E020000424D3E0200000000000036000000280000000D0000000D0000000100
          18000000000008020000C40E0000C40E00000000000000000000000000000000
          000000000000BD9A78BD9A78BD9A78BD9A78BD9A78BD9A78BD9A78BD9A78BD9A
          7800000000000000000000000000BD9A78EFEBE6EFEBE6EFEBE6EFEBE6EFEBE6
          EFEBE6EFEBE6BD9A7800000000000000000000000000BD9A78EFEBE6EFEBE680
          8080EFEBE6EFEBE6EFEBE6EFEBE6BD9A7800000000000000000000000000BD9A
          78EFEBE6808080808080808080EFEBE6EFEBE6EFEBE6BD9A7800BD9A78BD9A78
          BD9A78BD9A78BD9A78BD9A78BD9A78BD9A78BD9A78808080EFEBE6EFEBE6BD9A
          7800BD9A78EFEBE6EFEBE6EFEBE6EFEBE6EFEBE6EFEBE6EFEBE6BD9A78808080
          808080EFEBE6BD9A7800BD9A78EFEBE6EFEBE6808080EFEBE6EFEBE6EFEBE6EF
          EBE6BD9A78EFEBE6808080EFEBE6BD9A7800BD9A78EFEBE68080808080808080
          80EFEBE6EFEBE6EFEBE6BD9A78EFEBE6EFEBE6EFEBE6BD9A7800BD9A78EFEBE6
          808080EFEBE6808080808080EFEBE6EFEBE6BD9A78BD9A78BD9A78BD9A78BD9A
          7800BD9A78EFEBE6EFEBE6EFEBE6EFEBE6808080808080EFEBE6BD9A78000000
          00000000000000000000BD9A78EFEBE6EFEBE6EFEBE6EFEBE6EFEBE6808080EF
          EBE6BD9A7800000000000000000000000000BD9A78EFEBE6EFEBE6EFEBE6EFEB
          E6EFEBE6EFEBE6EFEBE6BD9A7800000000000000000000000000BD9A78BD9A78
          BD9A78BD9A78BD9A78BD9A78BD9A78BD9A78BD9A780000000000000000000000
          0000}
        ParentShowHint = False
        ShowHint = True
        OnClick = btnSelInverseClick
      end
      object chbPreview: TCheckBox
        Left = 218
        Top = 88
        Width = 87
        Height = 17
        Caption = 'show preview'
        TabOrder = 0
        OnClick = chbPreviewClick
      end
      object mPicInfo: TMemo
        Left = 312
        Top = 5
        Width = 233
        Height = 95
        Anchors = [akLeft, akTop, akRight, akBottom]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial Unicode MS'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 1
      end
      object pcTags: TPageControl
        Left = 3
        Top = 3
        Width = 209
        Height = 97
        ActivePage = tsTags
        Anchors = [akLeft, akTop, akBottom]
        TabOrder = 2
        object tsTags: TTabSheet
          Caption = 'Tags Cloud'
          object chblTagsCloud: TCheckListBox
            Left = 0
            Top = 0
            Width = 201
            Height = 69
            Align = alClient
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Arial Unicode MS'
            Font.Style = []
            ItemHeight = 15
            ParentFont = False
            PopupMenu = pmTags
            Sorted = True
            TabOrder = 0
          end
        end
        object tsRelated: TTabSheet
          Caption = 'Related'
          ImageIndex = 1
          object lbRelatedTags: TListBox
            Left = 0
            Top = 0
            Width = 201
            Height = 69
            Align = alClient
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Arial Unicode MS'
            Font.Style = []
            ItemHeight = 15
            ParentFont = False
            PopupMenu = pmTags
            Sorted = True
            TabOrder = 0
          end
        end
      end
      object eCFilter: TJvSpinEdit
        Left = 265
        Top = 61
        Width = 41
        Height = 21
        CheckMaxValue = False
        MinValue = 1.000000000000000000
        Value = 1.000000000000000000
        TabOrder = 3
        OnChange = eCFilterChange
      end
    end
    object tsPicsList: TSpTBXTabSheet
      Left = 0
      Top = 26
      Width = 548
      Height = 132
      Caption = 'Get'
      ImageIndex = -1
      DesignSize = (
        548
        132)
      TabItem = 'tsiPicList'
      object lCategory: TLabel
        Left = 15
        Top = 96
        Width = 41
        Height = 13
        Caption = 'category'
      end
      object lSavedTags: TLabel
        Left = 4
        Top = 68
        Width = 52
        Height = 13
        Caption = 'saved tags'
      end
      object lSite: TLabel
        Left = 5
        Top = 12
        Width = 51
        Height = 13
        Caption = 'destination'
      end
      object lTags: TLabel
        Left = 36
        Top = 40
        Width = 20
        Height = 13
        Caption = 'tags'
      end
      object lAfterFinish: TLabel
        Left = 342
        Top = 40
        Width = 48
        Height = 13
        Anchors = [akTop, akRight]
        Caption = 'after finish'
      end
      object chbByAuthor: TCheckBox
        Left = 62
        Top = 95
        Width = 32
        Height = 17
        Caption = 'uid'
        TabOrder = 8
        OnClick = chbByAuthorClick
      end
      object chbSavedTags: TCheckBox
        Left = 62
        Top = 67
        Width = 13
        Height = 17
        TabOrder = 3
        OnClick = chbSavedTagsClick
      end
      object euserid: TJvSpinEdit
        Left = 100
        Top = 93
        Width = 74
        Height = 21
        CheckMinValue = True
        TabOrder = 9
      end
      object chbInPools: TCheckBox
        Left = 62
        Top = 94
        Width = 73
        Height = 17
        Caption = 'in pools'
        TabOrder = 10
        OnClick = chbByAuthorClick
      end
      object btnTagEdit: TButton
        Left = 310
        Top = 37
        Width = 26
        Height = 21
        Anchors = [akTop, akRight]
        Caption = '...'
        TabOrder = 2
        OnClick = btnTagEditClick
      end
      object eSavedTags: TJvEdit
        Left = 81
        Top = 64
        Width = 255
        Height = 21
        EmptyValue = 'Saved tags'
        DisabledColor = clBtnFace
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 4
      end
      object eTag: TJvEdit
        Left = 62
        Top = 37
        Width = 242
        Height = 21
        EmptyValue = 'Tags'
        DisabledColor = clBtnFace
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 1
      end
      object btnListGet: TButton
        Left = 342
        Top = 7
        Width = 45
        Height = 24
        Anchors = [akTop, akRight]
        Caption = 'Get'
        Default = True
        TabOrder = 7
        OnClick = btnListGetClick
      end
      object cbSite: TComboBox
        Left = 62
        Top = 8
        Width = 244
        Height = 23
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial Unicode MS'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnChange = cbSiteChange
      end
      object btnCatEdit: TButton
        Left = 291
        Top = 93
        Width = 26
        Height = 21
        Anchors = [akTop, akRight]
        Caption = '...'
        TabOrder = 6
        OnClick = btnCatEditClick
      end
      object eCategory: TJvEdit
        Left = 62
        Top = 93
        Width = 223
        Height = 21
        EmptyValue = 'Categories'
        DisabledColor = clBtnFace
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 5
      end
      object chbQueryI1: TCheckBox
        Left = 62
        Top = 95
        Width = 97
        Height = 17
        Caption = 'query interval'
        Checked = True
        State = cbChecked
        TabOrder = 11
      end
      object cbAfterFinish: TComboBox
        Left = 396
        Top = 37
        Width = 141
        Height = 21
        Style = csDropDownList
        Anchors = [akTop, akRight]
        ItemIndex = 0
        TabOrder = 12
        Text = 'stay here'
        Items.Strings = (
          'stay here'
          'move to metadata'
          'move to downloading')
      end
      object btnAuth1: TBitBtn
        Left = 312
        Top = 8
        Width = 24
        Height = 23
        Hint = 'Authentication'
        Anchors = [akTop, akRight]
        DoubleBuffered = True
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
        ParentDoubleBuffered = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 13
        OnClick = btnAuth1Click
      end
      object cbByAuthor: TComboBox
        Left = 180
        Top = 93
        Width = 94
        Height = 21
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 14
        Text = 'works'
        OnChange = cbByAuthorChange
        Items.Strings = (
          'works'
          'favorites')
      end
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 504
    Width = 548
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object pnlMain: TSpTBXPanel
    Left = 0
    Top = 161
    Width = 548
    Height = 343
    Caption = 'pnlMain'
    Color = clBtnFace
    Align = alClient
    TabOrder = 2
    Borders = False
    object splLogs: TSplitter
      Left = 0
      Top = 240
      Width = 548
      Height = 3
      Cursor = crVSplit
      Align = alBottom
      Color = clBtnFace
      MinSize = 1
      ParentColor = False
      OnCanResize = splLogsCanResize
      ExplicitLeft = 2
      ExplicitTop = 237
      ExplicitWidth = 544
    end
    object pcLogs: TSpTBXTabControl
      Left = 0
      Top = 243
      Width = 548
      Height = 100
      Align = alBottom
      Constraints.MinHeight = 100
      ActiveTabIndex = 0
      OnActiveTabChanging = pcLogsActiveTabChanging
      HiddenItems = <>
      object tsiLog: TSpTBXTabItem
        Caption = 'Log'
        Checked = True
      end
      object tsiErrors: TSpTBXTabItem
        Caption = 'Errors'
      end
      object tbrasLogs: TSpTBXRightAlignSpacerItem
        CustomWidth = 322
      end
      object TBControlItem2: TTBControlItem
        Control = chbShutdown
      end
      object tbiLogsHide: TSpTBXItem
        Hint = 'Hide panel'
        ImageIndex = 0
        Images = il
        OnClick = tbiLogsHideClick
      end
      object chbShutdown: TSpTBXCheckBox
        Left = 400
        Top = 0
        Width = 121
        Height = 21
        Caption = 'shutdown after finish'
        TabOrder = 0
      end
      object tsLog: TSpTBXTabSheet
        Left = 0
        Top = 26
        Width = 548
        Height = 74
        Caption = 'Errors'
        ImageIndex = -1
        TabItem = 'tsiErrors'
        object merrors: TMemo
          Left = 2
          Top = 0
          Width = 542
          Height = 70
          Align = alClient
          BevelInner = bvNone
          BevelOuter = bvNone
          BorderStyle = bsNone
          Color = 14803455
          Ctl3D = False
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Arial Unicode MS'
          Font.Style = []
          ParentCtl3D = False
          ParentFont = False
          ReadOnly = True
          ScrollBars = ssBoth
          TabOrder = 0
        end
      end
      object tsErrors: TSpTBXTabSheet
        Left = 0
        Top = 26
        Width = 548
        Height = 74
        Caption = 'Log'
        ImageIndex = -1
        TabItem = 'tsiLog'
        object mlog: TMemo
          Left = 2
          Top = 0
          Width = 542
          Height = 70
          Align = alClient
          BorderStyle = bsNone
          Color = clInfoBk
          Ctl3D = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Arial Unicode MS'
          Font.Style = []
          ParentCtl3D = False
          ParentFont = False
          ReadOnly = True
          ScrollBars = ssBoth
          TabOrder = 0
        end
      end
    end
    object pnlGrid: TSpTBXPanel
      Left = 0
      Top = 44
      Width = 548
      Height = 196
      Color = clBtnFace
      Align = alClient
      TabOrder = 1
      BorderType = pbrSunken
      object bgimage: TImage
        Left = 2
        Top = 27
        Width = 544
        Height = 152
        Align = alClient
        Center = True
        ExplicitLeft = 0
        ExplicitTop = 8
        ExplicitWidth = 548
        ExplicitHeight = 167
      end
      object lRow: TLabel
        AlignWithMargins = True
        Left = 5
        Top = 180
        Width = 541
        Height = 13
        Margins.Top = 1
        Margins.Right = 0
        Margins.Bottom = 1
        Align = alBottom
        Color = clBtnFace
        ParentColor = False
        Visible = False
        ExplicitWidth = 3
      end
      object Grid: TAdvStringGrid
        Left = 2
        Top = 27
        Width = 544
        Height = 152
        Cursor = crDefault
        Align = alClient
        ColCount = 2
        Ctl3D = True
        DefaultRowHeight = 20
        DrawingStyle = gdsClassic
        FixedCols = 0
        RowCount = 2
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial Unicode MS'
        Font.Style = []
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goThumbTracking]
        ParentCtl3D = False
        ParentFont = False
        ScrollBars = ssBoth
        TabOrder = 0
        Visible = False
        OnExit = GridExit
        OnGetEditText = GridGetEditText
        OnKeyDown = GridKeyDown
        OnKeyUp = GridKeyUp
        OnSelectCell = GridSelectCell
        OnSetEditText = GridSetEditText
        ActiveRowShow = True
        ActiveRowColor = 16773612
        GridLineColor = 15527152
        GridFixedLineColor = 13947601
        OnDblClickCell = GridDblClickCell
        OnCanEditCell = GridCanEditCell
        OnCheckBoxChange = GridCheckBoxChange
        ActiveCellFont.Charset = DEFAULT_CHARSET
        ActiveCellFont.Color = clWindowText
        ActiveCellFont.Height = -11
        ActiveCellFont.Name = 'Tahoma'
        ActiveCellFont.Style = [fsBold]
        ActiveCellColor = 16575452
        ActiveCellColorTo = 16571329
        Bands.Active = True
        Bands.PrimaryColor = 16775928
        ControlLook.FixedGradientMirrorFrom = 16049884
        ControlLook.FixedGradientMirrorTo = 16247261
        ControlLook.FixedGradientHoverFrom = 16710648
        ControlLook.FixedGradientHoverTo = 16446189
        ControlLook.FixedGradientHoverMirrorFrom = 16049367
        ControlLook.FixedGradientHoverMirrorTo = 15258305
        ControlLook.FixedGradientDownFrom = 15853789
        ControlLook.FixedGradientDownTo = 15852760
        ControlLook.FixedGradientDownMirrorFrom = 15522767
        ControlLook.FixedGradientDownMirrorTo = 15588559
        ControlLook.FixedGradientDownBorder = 14007466
        ControlLook.DropDownHeader.Font.Charset = DEFAULT_CHARSET
        ControlLook.DropDownHeader.Font.Color = clWindowText
        ControlLook.DropDownHeader.Font.Height = -11
        ControlLook.DropDownHeader.Font.Name = 'Tahoma'
        ControlLook.DropDownHeader.Font.Style = []
        ControlLook.DropDownHeader.Visible = True
        ControlLook.DropDownHeader.Buttons = <>
        ControlLook.DropDownFooter.Font.Charset = DEFAULT_CHARSET
        ControlLook.DropDownFooter.Font.Color = clWindowText
        ControlLook.DropDownFooter.Font.Height = -11
        ControlLook.DropDownFooter.Font.Name = 'Tahoma'
        ControlLook.DropDownFooter.Font.Style = []
        ControlLook.DropDownFooter.Visible = True
        ControlLook.DropDownFooter.Buttons = <>
        Filter = <>
        FilterDropDown.Font.Charset = DEFAULT_CHARSET
        FilterDropDown.Font.Color = clWindowText
        FilterDropDown.Font.Height = -11
        FilterDropDown.Font.Name = 'Tahoma'
        FilterDropDown.Font.Style = []
        FilterDropDownClear = '(All)'
        FixedColWidth = 20
        FixedRowHeight = 20
        FixedFont.Charset = DEFAULT_CHARSET
        FixedFont.Color = clWindowText
        FixedFont.Height = -11
        FixedFont.Name = 'Tahoma'
        FixedFont.Style = [fsBold]
        FloatFormat = '%.2f'
        Look = glWin7
        Navigation.AdvanceAutoEdit = False
        PrintSettings.DateFormat = 'dd/mm/yyyy'
        PrintSettings.Font.Charset = DEFAULT_CHARSET
        PrintSettings.Font.Color = clWindowText
        PrintSettings.Font.Height = -11
        PrintSettings.Font.Name = 'Tahoma'
        PrintSettings.Font.Style = []
        PrintSettings.FixedFont.Charset = DEFAULT_CHARSET
        PrintSettings.FixedFont.Color = clWindowText
        PrintSettings.FixedFont.Height = -11
        PrintSettings.FixedFont.Name = 'Tahoma'
        PrintSettings.FixedFont.Style = []
        PrintSettings.HeaderFont.Charset = DEFAULT_CHARSET
        PrintSettings.HeaderFont.Color = clWindowText
        PrintSettings.HeaderFont.Height = -11
        PrintSettings.HeaderFont.Name = 'Tahoma'
        PrintSettings.HeaderFont.Style = []
        PrintSettings.FooterFont.Charset = DEFAULT_CHARSET
        PrintSettings.FooterFont.Color = clWindowText
        PrintSettings.FooterFont.Height = -11
        PrintSettings.FooterFont.Name = 'Tahoma'
        PrintSettings.FooterFont.Style = []
        PrintSettings.PageNumSep = '/'
        ScrollWidth = 16
        SearchFooter.Color = 16645370
        SearchFooter.ColorTo = 16767411
        SearchFooter.FindNextCaption = 'Find &next'
        SearchFooter.FindPrevCaption = 'Find &previous'
        SearchFooter.Font.Charset = DEFAULT_CHARSET
        SearchFooter.Font.Color = clWindowText
        SearchFooter.Font.Height = -11
        SearchFooter.Font.Name = 'Tahoma'
        SearchFooter.Font.Style = []
        SearchFooter.HighLightCaption = 'Highlight'
        SearchFooter.HintClose = 'Close'
        SearchFooter.HintFindNext = 'Find next occurence'
        SearchFooter.HintFindPrev = 'Find previous occurence'
        SearchFooter.HintHighlight = 'Highlight occurences'
        SearchFooter.MatchCaseCaption = 'Match case'
        ShowDesignHelper = False
        SortSettings.HeaderColor = 16579058
        SortSettings.HeaderColorTo = 16579058
        SortSettings.HeaderMirrorColor = 16380385
        SortSettings.HeaderMirrorColorTo = 16182488
        VAlignment = vtaCenter
        Version = '5.8.7.0'
        ColWidths = (
          20
          64)
      end
      object tbdGrid: TSpTBXDock
        Left = 2
        Top = 2
        Width = 544
        Height = 25
        AllowDrag = False
        object tbGrid: TSpTBXToolbar
          Left = 0
          Top = 0
          BorderStyle = bsNone
          DockMode = dmCannotFloatOrChangeDocks
          DockPos = 1
          Images = il
          Resizable = False
          ShowCaption = False
          ShrinkMode = tbsmNone
          Stretch = True
          TabOrder = 0
          Visible = False
          object tbsiCheck: TSpTBXSubmenuItem
            Caption = 'check'
            object tbiCheckAll: TSpTBXItem
              Caption = 'all'
              OnClick = TBXItem1Click
            end
            object tbiCheckSelected: TSpTBXItem
              Caption = 'selected'
              OnClick = TBXItem12Click
            end
            object tbiCheckByKeyword: TSpTBXItem
              Caption = 'by keyword'
              OnClick = TBXItem9Click
            end
            object tbiCheckByTags: TSpTBXItem
              Caption = 'by tags'
              OnClick = TBXItem5Click
            end
            object tbiCheckInverse: TSpTBXItem
              Caption = 'inverse'
              OnClick = TBXItem3Click
            end
          end
          object tbsiUncheck: TSpTBXSubmenuItem
            Caption = 'uncheck'
            object tbiUncheckAll: TSpTBXItem
              Caption = 'all'
              OnClick = TBXItem2Click
            end
            object tbiUncheckSelected: TSpTBXItem
              Caption = 'selected'
              OnClick = TBXItem13Click
            end
            object tbiUncheckByKeyword: TSpTBXItem
              Caption = 'by keyword'
              OnClick = TBXItem10Click
            end
            object tbiUncheckByTags: TSpTBXItem
              Caption = 'by tags'
              OnClick = TBXItem11Click
            end
          end
          object tbs1: TSpTBXSeparatorItem
          end
          object tbiPrevious: TSpTBXItem
            Caption = '< previous'
            OnClick = TBXItem6Click
          end
          object tbiNext: TSpTBXItem
            Caption = 'next >'
            OnClick = TBXItem7Click
          end
          object tbs2: TSpTBXSeparatorItem
          end
          object tbiGoto: TSpTBXItem
            Caption = 'go to'
            OnClick = TBXItem8Click
          end
          object tbras: TSpTBXRightAlignSpacerItem
            CustomWidth = 210
          end
          object TBControlItem1: TTBControlItem
            Control = chbautoscroll
          end
          object tbiGridClose: TSpTBXItem
            OnClick = tbiGridCloseClick
          end
          object chbautoscroll: TSpTBXCheckBox
            Left = 465
            Top = 0
            Width = 69
            Height = 21
            Caption = 'autoscroll'
            TabOrder = 0
            OnClick = chbAutoScrollClick
          end
        end
      end
    end
    object pnlPBar: TSpTBXPanel
      AlignWithMargins = True
      Left = 0
      Top = 0
      Width = 548
      Height = 41
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Caption = 'pnlPBar'
      Align = alTop
      TabOrder = 2
      DesignSize = (
        548
        41)
      object iStatIcon: TImage
        Left = 4
        Top = 5
        Width = 32
        Height = 32
      end
      object btnBrBrowse: TBitBtn
        Left = 442
        Top = 5
        Width = 34
        Height = 32
        Hint = 'Browse'
        Anchors = [akTop, akRight]
        DoubleBuffered = True
        Glyph.Data = {
          36060000424D3606000000000000360000002800000020000000100000000100
          18000000000000060000C30E0000C30E000000000000000000000000FF0000FF
          0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000
          FFD5D7D6D3D2CFFFFFFF0000FF0000FF0000FF0000FF0000FF0000FF0000FF00
          00FF0000FF0000FF0000FF0000FF0000FFD6D6D6D1D1D1FFFFFF0000FF0000FF
          0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FFB1AC
          A9877280646786B9AEAB0000FF0000FF0000FF0000FF0000FF0000FF0000FF00
          00FF0000FF0000FF0000FF0000FFACACAC7F7F7F727272AFAFAF0000FF0000FF
          0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FFB1ACA98F73
          7F6D7AB6378AE483ACD10000FF0000FF0000FF0000FF0000FF0000FF0000FF00
          00FF0000FF0000FF0000FFACACAC8080808D8D8D8D8D8DAAAAAA0000FF0000FF
          0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FFB1ADAA92747F6D79
          B53993E858C0FFBEE5FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF00
          00FF0000FF0000FFADADAD8181818C8C8C919191B0B0B0E0E0E00000FF0000FF
          0000FF0000FF0000FF0000FF0000FF0000FF0000FFB6B0AE8F737E6D78B53B95
          EA57BFFFC9E6FD0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF00
          00FF0000FFB0B0B07F7F7F8C8C8C939393AFAFAFE4E4E40000FF0000FF0000FF
          0000FFE7E8E9BBB5B6ADA5A7B4AFB0DAD9DBE9EDEE8F83856474B23993E957BF
          FFC5E4FD0000FF0000FF0000FF0000FF0000FFE8E8E8B7B7B7A8A8A8B1B1B1DA
          DADAECECEC878787868686919191AFAFAFE2E2E20000FF0000FF0000FF0000FF
          C1BDBF877D75C6AE99E1CBB1CFB7A0B9998A9D8583817B7D5695D457BDFDC8E6
          FD0000FF0000FF0000FF0000FF0000FFBFBFBF7C7C7CAAAAAAC5C5C5B3B3B399
          99998989897D7D7D959595AEAEAEE3E3E30000FF0000FF0000FF0000FFC1C1C1
          8B7879F4EAE0FFFFFAFFFFE6FFFFD8FFFDCAF2CFA9B4928AC9CAC9DEEEFB0000
          FF0000FF0000FF0000FF0000FFC1C1C17C7C7CE8E8E8FDFDFDF5F5F5EFEFEFE9
          E9E9C7C7C7969696C9C9C9EDEDED0000FF0000FF0000FF0000FFECEFEF897672
          ECDED0FFFFFFFFFFFFFFFFFFFFFED5FFF4C0FFF6C3EDC8A3D4C5C10000FF0000
          FF0000FF0000FF0000FFEEEEEE787878DBDBDBFFFFFFFFFFFFFFFFFFEEEEEEE1
          E1E1E3E3E3C1C1C1C6C6C60000FF0000FF0000FF0000FF0000FFD0CCCDAA8C82
          FFFFE7FFFFFFFFFFFFFFFFFFFFFFDBFFF3C3FFE2B1FDEFBDE0C8BE0000FF0000
          FF0000FF0000FF0000FFCDCDCD8E8E8EF5F5F5FFFFFFFFFFFFFFFFFFF1F1F1E2
          E2E2D4D4D4DEDEDEC9C9C90000FF0000FF0000FF0000FF0000FFCEC7C9C0A690
          FFFFDCFFFFECFFFFF4FFFFF4FFFED3FFF1C0FFD6A6FEEFBDE2C8B6F9F4F50000
          FF0000FF0000FF0000FFCACACAA2A2A2F1F1F1F7F7F7FBFBFBFBFBFBEDEDEDE0
          E0E0CBCBCBDEDEDEC6C6C6F6F6F60000FF0000FF0000FF0000FFD0CCD0BBA18F
          FFFFD1FFFDD2FFFED1FFFED1FFF9C7FFE5B2FFDFACFFF4C2E1C6B3F9F4F50000
          FF0000FF0000FF0000FFCFCFCF9F9F9FEDEDEDECECECECECECECECECE6E6E6D6
          D6D6D1D1D1E2E2E2C4C4C4F6F6F60000FF0000FF0000FF0000FFECECEDAB8F89
          FDEFBFFFF4C2FFECBBFFEEBDFFE0AEFFE4BBFFF8EAF8F0D3DEC7BA0000FF0000
          FF0000FF0000FF0000FFECECEC929292DFDFDFE2E2E2DCDCDCDEDEDED2D2D2D9
          D9D9F4F4F4E6E6E6C6C6C60000FF0000FF0000FF0000FF0000FF0000FFC8C0C2
          CDA68BFFF7C2FFEBB7FFDCAAFFE5B5FFFEF5FCFBFDDFC5B8F8F2EE0000FF0000
          FF0000FF0000FF0000FF0000FFC3C3C3A3A3A3E3E3E3DADADACFCFCFD7D7D7FB
          FBFBFCFCFCC5C5C5F2F2F20000FF0000FF0000FF0000FF0000FF0000FF0000FF
          C4B8BAD4B097F8E2B4FFF4C4FDF0C5ECDFC2DAC0B9F0E7E40000FF0000FF0000
          FF0000FF0000FF0000FF0000FF0000FFBCBCBCADADADD4D4D4E3E3E3E1E1E1D6
          D6D6C2C2C2E8E8E80000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF
          0000FFE5DEE0DDC2B9C4B6AABEAEA5E0D0CCF5EEEB0000FF0000FF0000FF0000
          FF0000FF0000FF0000FF0000FF0000FF0000FFE1E1E1C4C4C4B4B4B4AEAEAED2
          D2D2EEEEEE0000FF0000FF0000FF0000FF0000FF0000FF0000FF}
        NumGlyphs = 2
        ParentDoubleBuffered = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnClick = btnBrowseClick
      end
      object btnCancel: TButton
        Left = 482
        Top = 5
        Width = 62
        Height = 32
        Anchors = [akTop, akRight]
        Caption = 'Cancel'
        TabOrder = 1
        OnClick = btnCancelClick
      end
      object prgrsbr: TProgressBar
        Left = 42
        Top = 10
        Width = 394
        Height = 23
        Anchors = [akLeft, akTop, akRight]
        Smooth = True
        SmoothReverse = True
        TabOrder = 2
      end
    end
  end
  object VersionInfo: TrpVersionInfo
    Left = 220
    Top = 268
  end
  object IdAntiFreeze: TIdAntiFreeze
    Left = 372
    Top = 316
  end
  object AppEvents: TApplicationEvents
    OnException = AppEventsException
    OnRestore = AppEventsRestore
    Left = 320
    Top = 268
  end
  object pmTags: TPopupMenu
    Left = 356
    Top = 268
    object Copy1: TMenuItem
      Caption = 'Copy'
    end
  end
  object XPManifest: TXPManifest
    Left = 416
    Top = 384
  end
  object UpdateTimer: TTimer
    Enabled = False
    OnTimer = UpdateTimerTimer
    Left = 384
    Top = 384
  end
  object pmTray: TPopupMenu
    OnPopup = pmTrayPopup
    Left = 392
    Top = 265
    object Show1: TMenuItem
      Caption = 'Show'
      Default = True
      OnClick = Show1Click
    end
    object Hide1: TMenuItem
      Caption = 'Hide'
      OnClick = Hide1Click
    end
    object Close1: TMenuItem
      Caption = 'Close'
      OnClick = Close1Click
    end
  end
  object JvTrayIcon: TJvTrayIcon
    Animated = True
    IconIndex = 0
    PopupMenu = pmTray
    Visibility = [tvVisibleTaskBar, tvVisibleTaskList, tvRestoreClick]
    OnClick = JvTrayIconClick
    OnBalloonClick = JvTrayIconBalloonClick
    Left = 352
    Top = 384
  end
  object odList: TOpenDialog
    DefaultExt = '.igl'
    Filter = '*.igl|*.igl|*.*|*.*'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 288
    Top = 264
  end
  object sdList: TSaveDialog
    DefaultExt = '.igl'
    Filter = 
      'imagegraer format (igl)|*.igl|text (txt)|*.txt|names with tags (' +
      'csv)|*.csv|show all|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Left = 256
    Top = 264
  end
  object il: TImageList
    Left = 336
    Top = 320
    Bitmap = {
      494C0101030024004C0010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00008C8C8C0067696900757B7B00888C8D00878C8C00747A7A00676969008C8C
      8C00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000ACACAC006265
      6500ADB6B500F2FBF900FCFFFF00FFFFFF00FCFFFF00F5FFFF00E8F5F700A4AC
      AC0062656500ACACAC0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000ACACAC005F636400E6ED
      EC00BCC4C4005C7991004A74960069809000CAD3D000F1FFFF00EAFAFE00F7FF
      FF00E0ECED005F626300ACACAC00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000061636400E7F2F200929F
      A6000F5AA4001482EE00188AF700107BE30023588B00C0C8C600F3FFFF00EFFB
      FB00E9F1EC00E4ECE90065676700000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008F8F8F00AAB5B600D5DDDA00195A
      99001E93FF00238FFB00228EFA002391FF001383F2004F708C00E3E6E100607A
      8D002C5F8C0065819800939795008F9090000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007E808000EEFAFB008E9EA5000F71
      D0002391FF00228EF900228EF900228EF9001F91FF00336DA500637078000D72
      D6001E93FF000D77DF0059708400848381000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000767B7C00FFFFFF008A9AA1000F72
      D2002391FF00228EF900228EF900228EF9001E91FF0034679600435C7400198D
      FF00228FFC00198EFF0049739800797974000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000868C8D00FCFFFF00C1C9C700165B
      9E001F94FF002390FC00228FFB002394FF000D76DE007B8F9D00A9B1B3001161
      B1001484EF00095FB50091A2AC00909695000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000868C8D00F5FFFF00F1FDFD008594
      9C00125EA8001985EF001785EE000E6CC80048688400A6A9A4009BA3A6007E83
      83006E83940093A2A700F7FCFA00888E8F000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000767B7C00F5FFFF00E8F9FD00F6FF
      FF00AFB2AD0046536000546D7F00A1ABAF00868F92001561AB001175D2002C63
      9600C9CECB00FAFFFF00F6FFFF00767B7C000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007E808000E1F0F200EEFCFE00D4DF
      DE004E708F002669A5003E699000C3C5BE00386B99001A90FF002393FF000F7E
      EA00677F9200F6FFFF00E1F0F2007E8080000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008F8F8F00A3ADAF00FFFFFF006E82
      92000B74DD002297FF001486F70045637E003F6484001589FC002297FF000B72
      D80075899500FFFFFF00A3ADAF008F8F8F000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000063666600E8EFEE006781
      97001181F1002393FF001A8FFF003D699200B1B4B1002A5D8D001561A5004568
      8600E0E7E500E1EAEC0063666600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000ACACAC0065696900AAB3
      B3002A66A0001479D8000F5AA400909EA500FAFFFF00DAE3E100C5CDCC00F5FF
      FD00E2EDEE005F626300ACACAC00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000ACACAC00696A
      6A007F817F008D969B00C0CBCA00FCFFFF00F6FFFF00F9FFFF00EFFCFE00A5AE
      AF0062666600ACACAC0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00008E8E8E006E706E007D818100888C8D00878C8C00747A7A00676969008C8C
      8C00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFFFFFFF00F0000FFFFFFFFC0030000
      FFFFFFFF80010000FFFFFFFF80010000FFFFE00F00000000FFFFF01F00000000
      FFFFF83F00000000FEFFFC7F00000000FC7FFEFF00000000F83FFFFF00000000
      F01FFFFF00000000E00FFFFF00000000FFFFFFFF80010000FFFFFFFF80010000
      FFFFFFFFC0030000FFFFFFFFF00F000000000000000000000000000000000000
      000000000000}
  end
end
