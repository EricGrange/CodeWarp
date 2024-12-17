object AboutCodeWarpBox: TAboutCodeWarpBox
  Left = 169
  Top = 115
  HelpContext = 10
  BorderStyle = bsDialog
  Caption = 'About...'
  ClientHeight = 216
  ClientWidth = 472
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  HelpFile = 'CodeWarp.hlp'
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 15
  object Label2: TLabel
    Left = 0
    Top = 0
    Width = 249
    Height = 33
    Alignment = taCenter
    AutoSize = False
    Caption = 'Code Warp'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -29
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Bevel1: TBevel
    Left = 37
    Top = 39
    Width = 177
    Height = 9
    Shape = bsTopLine
  end
  object Bevel2: TBevel
    Left = 256
    Top = 8
    Width = 9
    Height = 201
    Shape = bsLeftLine
  end
  object Label5: TLabel
    Left = 264
    Top = 6
    Width = 66
    Height = 15
    Caption = 'Code Entries'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsUnderline]
    ParentFont = False
  end
  object Label6: TLabel
    Left = 368
    Top = 6
    Width = 32
    Height = 15
    Caption = 'Scope'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsUnderline]
    ParentFont = False
  end
  object Label7: TLabel
    Left = 368
    Top = 108
    Width = 23
    Height = 15
    Caption = 'Files'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsUnderline]
    ParentFont = False
  end
  object StaticText1: TStaticText
    Left = 1
    Top = 52
    Width = 249
    Height = 15
    Alignment = taCenter
    AutoSize = False
    Caption = '24.12'
    TabOrder = 0
  end
  object StaticText2: TStaticText
    Left = 1
    Top = 108
    Width = 249
    Height = 57
    Alignment = taCenter
    AutoSize = False
    Caption = 
      'CodeWarp is distributed as FreeWare,'#13#10'feel free to distribute an' +
      'd copy as long as'#13#10'you do not alter/strip/modify it.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMaroon
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
  object Button1: TButton
    Left = 92
    Top = 184
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Ok'
    Default = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button3: TButton
    Left = 8
    Top = 184
    Width = 57
    Height = 25
    Caption = 'O&ptions'
    TabOrder = 3
    OnClick = Button3Click
  end
  object Panel1: TPanel
    Left = 264
    Top = 24
    Width = 100
    Height = 193
    BevelOuter = bvNone
    Enabled = False
    TabOrder = 4
  end
  object BBHelp: TBitBtn
    Left = 192
    Top = 184
    Width = 57
    Height = 25
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      0400000000006801000000000000000000001000000010000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333336633
      3333333333333FF3333333330000333333364463333333333333388F33333333
      00003333333E66433333333333338F38F3333333000033333333E66333333333
      33338FF8F3333333000033333333333333333333333338833333333300003333
      3333446333333333333333FF3333333300003333333666433333333333333888
      F333333300003333333E66433333333333338F38F333333300003333333E6664
      3333333333338F38F3333333000033333333E6664333333333338F338F333333
      0000333333333E6664333333333338F338F3333300003333344333E666433333
      333F338F338F3333000033336664333E664333333388F338F338F33300003333
      E66644466643333338F38FFF8338F333000033333E6666666663333338F33888
      3338F3330000333333EE666666333333338FF33333383333000033333333EEEE
      E333333333388FFFFF8333330000333333333333333333333333388888333333
      0000}
    NumGlyphs = 2
    TabOrder = 5
    OnClick = BBHelpClick
  end
  object LBCode: TListBox
    Left = 265
    Top = 21
    Width = 97
    Height = 187
    Style = lbOwnerDrawFixed
    BorderStyle = bsNone
    ItemHeight = 17
    Items.Strings = (
      '09interface'
      '01class'
      '23dispinterface'
      '10record'
      '02implementation'
      '03procedure'
      '04function'
      '05constructor'
      '06destructor'
      '07class procedure'
      '08class function')
    TabOrder = 6
    OnDrawItem = LBCodeDrawItem
  end
  object ListBox1: TListBox
    Left = 368
    Top = 23
    Width = 97
    Height = 68
    Style = lbOwnerDrawFixed
    BorderStyle = bsNone
    ItemHeight = 17
    Items.Strings = (
      '11private'
      '12protected'
      '13public'
      '14published')
    TabOrder = 7
    OnDrawItem = LBCodeDrawItem
  end
  object ListBox2: TListBox
    Left = 368
    Top = 125
    Width = 97
    Height = 85
    Style = lbOwnerDrawFixed
    BorderStyle = bsNone
    ItemHeight = 17
    Items.Strings = (
      '15Current Project'
      '16Pascal Unit'
      '17Delphi Form'
      '18Packet'
      '21VCL Source')
    TabOrder = 8
    OnDrawItem = LBCodeDrawItem
  end
end
