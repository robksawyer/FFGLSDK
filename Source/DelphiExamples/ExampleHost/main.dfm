object fmMain: TfmMain
  Left = 558
  Top = 202
  Width = 865
  Height = 709
  Caption = 'FreeFrame Delphi Host Test Container'
  Color = clTeal
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lAPIversion: TLabel
    Left = 7
    Top = 629
    Width = 51
    Height = 13
    Caption = 'APIversion'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object previewpanel: TPanel
    Left = 8
    Top = 8
    Width = 465
    Height = 201
    Color = clMoneyGreen
    TabOrder = 0
    object lbAviStatus: TLabel
      Left = 240
      Top = 40
      Width = 101
      Height = 13
      Caption = 'AviStatus: not loaded'
    end
    object Label7: TLabel
      Left = 8
      Top = 8
      Width = 46
      Height = 13
      Caption = 'Video File'
    end
    object ebAVIFilename: TEdit
      Left = 59
      Top = 6
      Width = 289
      Height = 21
      TabOrder = 0
      OnChange = ebAVIFilenameChange
    end
    object bBrowse: TButton
      Left = 360
      Top = 5
      Width = 75
      Height = 25
      Caption = '0 - Browse'
      TabOrder = 1
      OnClick = bBrowseClick
    end
    object GroupBox2: TGroupBox
      Left = 240
      Top = 64
      Width = 113
      Height = 87
      Caption = ' VideoInfoStruct '
      TabOrder = 2
      object lVideoWidth: TLabel
        Left = 13
        Top = 16
        Width = 28
        Height = 13
        Caption = 'Width'
      end
      object lVideoHeight: TLabel
        Left = 13
        Top = 32
        Width = 31
        Height = 13
        Caption = 'Height'
      end
      object lBitDepth: TLabel
        Left = 13
        Top = 48
        Width = 44
        Height = 13
        Caption = 'Bit Depth'
      end
      object lOrientation: TLabel
        Left = 13
        Top = 64
        Width = 51
        Height = 13
        Caption = 'Orientation'
      end
    end
    object Panel3: TPanel
      Left = 16
      Top = 32
      Width = 209
      Height = 161
      Caption = 'dib panel'
      TabOrder = 3
      object PaintBox1: TPaintBox
        Left = 8
        Top = 7
        Width = 192
        Height = 144
      end
    end
  end
  object pnInfo: TPanel
    Left = 480
    Top = 8
    Width = 369
    Height = 665
    Color = clMoneyGreen
    TabOrder = 1
    object lProfile: TLabel
      Left = 124
      Top = 488
      Width = 29
      Height = 13
      Caption = 'Profile'
    end
    object Label3: TLabel
      Left = 13
      Top = 488
      Width = 108
      Height = 13
      Caption = 'Plugin processing time:'
    end
    object lbpname: TLabel
      Left = 8
      Top = 616
      Width = 40
      Height = 13
      Caption = 'lbpname'
    end
    object lbpvalue: TLabel
      Left = 96
      Top = 640
      Width = 40
      Height = 13
      Caption = 'lbpvalue'
    end
    object Label2: TLabel
      Left = 3
      Top = 4
      Width = 350
      Height = 13
      Caption = 
        'Plugins must be in a plugins subdirectory of the  directory wher' +
        'e this .exe is'
    end
    object lbTime: TLabel
      Left = 200
      Top = 416
      Width = 115
      Height = 13
      Caption = 'Time Acceleration (1.00)'
    end
    object Label8: TLabel
      Left = 223
      Top = 376
      Width = 113
      Height = 13
      Caption = '(Time Controls: Do NOT'
    end
    object Label9: TLabel
      Left = 215
      Top = 392
      Width = 128
      Height = 13
      Caption = 'effect Video in this testbed)'
    end
    object cbPlugins: TComboBox
      Left = 16
      Top = 28
      Width = 337
      Height = 21
      Style = csDropDownList
      DropDownCount = 25
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbPluginsChange
    end
    object bProcessFrame: TButton
      Left = 8
      Top = 426
      Width = 137
      Height = 25
      Caption = 'Step Frame Process'
      TabOrder = 1
      OnClick = bProcessFrameClick
    end
    object bPlayAndProcess: TButton
      Left = 8
      Top = 368
      Width = 137
      Height = 25
      Caption = 'Play and Process'
      TabOrder = 2
      OnClick = bPlayAndProcessClick
    end
    object cbPluginProcessFrames: TCheckBox
      Left = 8
      Top = 349
      Width = 129
      Height = 17
      Caption = 'Plugin Process Frames'
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
    object bDeInitPlugin: TButton
      Left = 8
      Top = 455
      Width = 137
      Height = 25
      Caption = 'Shutdown Plugin'
      TabOrder = 4
      OnClick = bDeInitPluginClick
    end
    object bStop: TButton
      Left = 8
      Top = 397
      Width = 139
      Height = 25
      Caption = 'Stop'
      TabOrder = 5
      OnClick = bStopClick
    end
    object Memo1: TMemo
      Left = 16
      Top = 104
      Width = 337
      Height = 241
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      Lines.Strings = (
        'Memo1')
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 6
    end
    object lbParams: TListBox
      Left = 16
      Top = 512
      Width = 345
      Height = 97
      ItemHeight = 13
      TabOrder = 7
      OnClick = lbParamsClick
    end
    object sbParam: TScrollBar
      Left = 96
      Top = 616
      Width = 145
      Height = 16
      PageSize = 0
      TabOrder = 8
      OnChange = sbParamChange
    end
    object btnReload: TButton
      Left = 232
      Top = 65
      Width = 123
      Height = 25
      Caption = 'Reload Plugin'
      TabOrder = 9
      OnClick = btnReloadClick
    end
    object cbVerify: TCheckBox
      Left = 256
      Top = 616
      Width = 97
      Height = 17
      Caption = 'Verify'
      Checked = True
      State = cbChecked
      TabOrder = 10
      OnClick = cbVerifyClick
    end
    object cbTest32Bit: TCheckBox
      Left = 224
      Top = 349
      Width = 121
      Height = 17
      Caption = 'Test 32bit'
      TabOrder = 11
      OnClick = cbTest32BitClick
    end
    object sbTime: TScrollBar
      Left = 200
      Top = 432
      Width = 161
      Height = 16
      Min = -100
      PageSize = 0
      TabOrder = 12
      OnChange = sbTimeChange
    end
    object sbATime: TScrollBar
      Left = 200
      Top = 480
      Width = 161
      Height = 16
      Max = 10000
      PageSize = 0
      TabOrder = 13
    end
    object cbATime: TCheckBox
      Left = 200
      Top = 456
      Width = 161
      Height = 17
      Caption = 'Enable Abs Time (0>10 secs)'
      TabOrder = 14
    end
  end
  object Panel1: TPanel
    Left = 8
    Top = 216
    Width = 465
    Height = 177
    Color = clMoneyGreen
    TabOrder = 2
    object Label1: TLabel
      Left = 240
      Top = 8
      Width = 49
      Height = 13
      Caption = 'GL Output'
    end
    object cbCheckers: TCheckBox
      Left = 240
      Top = 32
      Width = 97
      Height = 17
      Caption = 'Checker Board'
      TabOrder = 0
      OnClick = cbCheckersClick
    end
    object btnGrabFrame: TButton
      Left = 240
      Top = 64
      Width = 89
      Height = 25
      Caption = 'Grab Frame'
      TabOrder = 1
      OnClick = btnGrabFrameClick
    end
    object Panel4: TPanel
      Left = 16
      Top = 8
      Width = 209
      Height = 161
      Caption = 'Panel4'
      TabOrder = 2
      object glpanel: TPanel
        Left = 8
        Top = 7
        Width = 192
        Height = 144
        Caption = 'opengl panel'
        TabOrder = 0
      end
    end
    object Memo2: TMemo
      Left = 240
      Top = 96
      Width = 209
      Height = 73
      Lines.Strings = (
        'Plugins are only rendered to the '
        'frameBuffer in this testbed, most hosts '
        'will probably use a FBO and mixdown '
        'onto their frameBuffers.'
        'This is not currently available here.')
      ReadOnly = True
      TabOrder = 3
    end
    object Memo3: TMemo
      Left = 336
      Top = 8
      Width = 113
      Height = 81
      Lines.Strings = (
        'GL Output renders a '
        'square section from '
        'the bottom left of your '
        'AVI. eg. 128x128'
        'or 256x256')
      ReadOnly = True
      TabOrder = 4
    end
  end
  object Panel2: TPanel
    Left = 8
    Top = 400
    Width = 465
    Height = 217
    Color = clMoneyGreen
    TabOrder = 3
    object Label4: TLabel
      Left = 104
      Top = 192
      Width = 23
      Height = 13
      Caption = 'RGB'
    end
    object Label5: TLabel
      Left = 328
      Top = 192
      Width = 27
      Height = 13
      Caption = 'Alpha'
    end
    object Label6: TLabel
      Left = 16
      Top = 8
      Width = 73
      Height = 13
      Caption = 'Grabbed Frame'
    end
    object Panel5: TPanel
      Left = 16
      Top = 24
      Width = 209
      Height = 161
      Caption = 'RGB Panel'
      TabOrder = 0
      object pbRGB: TPaintBox
        Left = 8
        Top = 7
        Width = 192
        Height = 144
      end
    end
    object Panel6: TPanel
      Left = 240
      Top = 24
      Width = 209
      Height = 161
      Caption = 'Alpha Panel'
      TabOrder = 1
      object pbAlpha: TPaintBox
        Left = 8
        Top = 7
        Width = 192
        Height = 144
      end
    end
  end
  object odAVI: TOpenDialog
    Left = 16
    Top = 96
  end
  object tPlay: TTimer
    Enabled = False
    Interval = 40
    OnTimer = tPlayTimer
    Left = 16
    Top = 48
  end
end
