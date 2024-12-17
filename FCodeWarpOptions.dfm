object CodeWarpOptions: TCodeWarpOptions
  Left = 150
  Top = 111
  HelpContext = 60
  BorderStyle = bsDialog
  Caption = 'CodeWarp - Options'
  ClientHeight = 339
  ClientWidth = 497
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  HelpFile = 'CodeWarp.hlp'
  Position = poScreenCenter
  ShowHint = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Button1: TButton
    Left = 176
    Top = 306
    Width = 97
    Height = 25
    Cancel = True
    Caption = '&Ok'
    TabOrder = 1
    OnClick = Button1Click
  end
  object PageControl: TPageControl
    Left = 8
    Top = 8
    Width = 481
    Height = 292
    ActivePage = TSVCLPath
    HotTrack = True
    TabOrder = 0
    object TSParser: TTabSheet
      Caption = '&Class Parser'
      object Label10: TLabel
        Left = 9
        Top = 64
        Width = 84
        Height = 15
        Caption = 'Ignore/Include :'
      end
      object Label11: TLabel
        Left = 8
        Top = 152
        Width = 77
        Height = 15
        Caption = 'Mirror Entries :'
      end
      object CBIgnoreForwards: TCheckBox
        Left = 104
        Top = 64
        Width = 345
        Height = 17
        Hint = 
          'Check this option if you don'#39't want forward class declarations'#13#10 +
          'to be visible in the class tree'
        HelpContext = 90
        Caption = 'Ignore &forward declarations ("TMyClass = class;")'
        TabOrder = 1
      end
      object CBIgnoreEZInheritance: TCheckBox
        Left = 104
        Top = 88
        Width = 345
        Height = 17
        Hint = 
          'Check this option if you don'#39't want "easy" class declarations'#13#10't' +
          'o be visible in the class tree.'#13#10'This concerns only sub-classing' +
          's without any addition to'#13#10'the parent class.'
        HelpContext = 100
        Caption = 'Ignore &EZ inheritance ("TMyClass = class of (TOldClass);")'
        TabOrder = 2
      end
      object CBShowMethodsUnder: TCheckBox
        Left = 104
        Top = 175
        Width = 345
        Height = 17
        Hint = 
          'If this option is checked, procedure and functions wich'#13#10'are met' +
          'hods of a class will be visible in both the class tree'#13#10'and the ' +
          '"Procedures" and "Functions" entries'
        HelpContext = 125
        Caption = 'Mirror Class &Methods under "Procedures" && "Functions"'
        TabOrder = 5
      end
      object CBShowScope: TCheckBox
        Left = 104
        Top = 152
        Width = 345
        Height = 17
        Hint = 
          'Check this option if you want "private", "protected", etc.'#13#10'entr' +
          'ies in the class Tree.'#13#10'Scopes are always visible under the "Int' +
          'erface" entry.'
        HelpContext = 120
        Caption = 'Mirror Class Declaration &Scope in Class Tree'
        TabOrder = 4
      end
      object StaticText4: TStaticText
        AlignWithMargins = True
        Left = 8
        Top = 8
        Width = 457
        Height = 35
        Margins.Left = 8
        Margins.Top = 8
        Margins.Right = 8
        Margins.Bottom = 8
        Align = alTop
        AutoSize = False
        BorderStyle = sbsSunken
        Caption = 
          'These options control the class parser : what it sees or sees no' +
          't, and which entries are relevant to you, and where you should s' +
          'ee them.'
        Color = 12189695
        ParentColor = False
        TabOrder = 0
        Transparent = False
      end
      object CBIncludeRecordsInClassTree: TCheckBox
        Left = 104
        Top = 111
        Width = 345
        Height = 17
        Hint = 
          'Check if you want Record declarations to be visible'#13#10'in the clas' +
          's tree.'
        HelpContext = 110
        Caption = 'Include Record &Types in Class Tree'
        TabOrder = 3
      end
    end
    object TSEntries: TTabSheet
      Caption = '&Display'
      object Label8: TLabel
        Left = 8
        Top = 73
        Width = 82
        Height = 15
        Caption = 'Caption Filters :'
      end
      object Label9: TLabel
        Left = 8
        Top = 160
        Width = 44
        Height = 15
        Caption = 'Sorting :'
      end
      object CBHideMethodKind: TCheckBox
        Left = 96
        Top = 73
        Width = 265
        Height = 17
        Hint = 
          'Remove the method kind text from the entries display,'#13#10'ie. "proc' +
          'edure MyProc(a : Integer);"'#13#10'becomes "MyProc(a : Integer);"'
        HelpContext = 130
        Caption = 'Hide &method kind text ("procedure", "function", ...)'
        TabOrder = 1
      end
      object CBHideClassParameters: TCheckBox
        Left = 96
        Top = 96
        Width = 257
        Height = 17
        Hint = 
          'Removes the method/proc/func parameters from the entry text'#13#10'ie.' +
          ' "procedure MyProc(a : Integer);"'#13#10'becomes "procedure MyProc"'
        HelpContext = 130
        Caption = '&Hide method parameters, just keep class && name'
        TabOrder = 2
      end
      object CBSortTheNode: TCheckBox
        Left = 96
        Top = 160
        Width = 201
        Height = 17
        Hint = 
          'Check this options if you want the entries sorted in'#13#10'alphabetic' +
          'al order. By default, the code'#39's order is used.'
        HelpContext = 140
        Caption = '&Sort Code Nodes in alphabetical order'
        TabOrder = 4
      end
      object StaticText5: TStaticText
        AlignWithMargins = True
        Left = 8
        Top = 8
        Width = 457
        Height = 49
        Margins.Left = 8
        Margins.Top = 8
        Margins.Right = 8
        Margins.Bottom = 8
        Align = alTop
        AutoSize = False
        BorderStyle = sbsSunken
        Caption = 
          'These options adjust how the entries are displayed (with or with' +
          'out qualifier ? with or without parameters ?) and wether entries' +
          ' should be sorted in alphabetical order or kept ordered as they ' +
          'are in the source.'#13#10
        Color = 12189695
        ParentColor = False
        TabOrder = 0
        Transparent = False
      end
      object CBConsolidateMethodDeclarations: TCheckBox
        Left = 96
        Top = 120
        Width = 177
        Height = 17
        Hint = 
          'Consolidates methods/funcs/procs multiple-lines declarations int' +
          'o a single line.'
        HelpContext = 130
        Caption = 'C&onsolidate method declarations'
        TabOrder = 3
      end
    end
    object TSUI: TTabSheet
      Caption = 'CodeWarp &UI'
      object Label1: TLabel
        Left = 88
        Top = 209
        Width = 133
        Height = 15
        Caption = 'A double-click on a node'
      end
      object Label4: TLabel
        Left = 9
        Top = 107
        Width = 74
        Height = 15
        Caption = 'Default Entry :'
      end
      object Label5: TLabel
        Left = 8
        Top = 79
        Width = 75
        Height = 15
        Caption = 'ShortCut Key :'
      end
      object Label6: TLabel
        Left = 9
        Top = 132
        Width = 61
        Height = 15
        Caption = 'Cosmetics :'
      end
      object Label7: TLabel
        Left = 9
        Top = 209
        Width = 59
        Height = 15
        Caption = 'Behaviour :'
      end
      object RBWarpToCode: TRadioButton
        Left = 232
        Top = 209
        Width = 129
        Height = 17
        HelpContext = 170
        Caption = 'Warps to code &position'
        TabOrder = 6
      end
      object RBExpand: TRadioButton
        Left = 232
        Top = 232
        Width = 145
        Height = 17
        HelpContext = 170
        Caption = 'Exp&ands node or Warps'
        TabOrder = 7
      end
      object CBHeight: TCheckBox
        Left = 88
        Top = 149
        Width = 241
        Height = 17
        Hint = 
          'If this option is checked, the CodeWarp window will use '#13#10'the fu' +
          'll screen height, else, only 2/3 of the screen height.'
        HelpContext = 160
        Caption = '&Window Height = Full Screen Height'
        TabOrder = 4
      end
      object CBDefaultEntry: TComboBox
        Left = 88
        Top = 102
        Width = 185
        Height = 23
        HelpContext = 150
        Style = csDropDownList
        DropDownCount = 11
        ItemIndex = 0
        TabOrder = 2
        Text = 'Class Tree'
        Items.Strings = (
          'Class Tree'
          'Interface Entries'
          'Implementation Entries'
          'Procedures'
          'Functions'
          'Project Files'
          'Components/Packages'
          'Local Libraries'
          'VCL Source'
          'Closest Procedure/Method'
          'The Previously Focused')
      end
      object StaticText3: TStaticText
        AlignWithMargins = True
        Left = 8
        Top = 8
        Width = 457
        Height = 64
        Margins.Left = 8
        Margins.Top = 8
        Margins.Right = 8
        Margins.Bottom = 8
        Align = alTop
        AutoSize = False
        BorderStyle = sbsSunken
        Caption = 
          'These options adjust the appearance and behaviour of CodeWarp.'#13#10 +
          'You can choose invokation key (CTRL+W by default), which entry w' +
          'ill be focused when CodeWarp is invoked, popup size and double-c' +
          'lick handling ([Enter] key always warps).'
        Color = 12189695
        ParentColor = False
        TabOrder = 0
        Transparent = False
      end
      object CBRememberDrills: TCheckBox
        Left = 88
        Top = 131
        Width = 241
        Height = 17
        Caption = 'R&emember Drills between invokations'
        TabOrder = 3
      end
      object EDShortCut: TEdit
        Left = 89
        Top = 73
        Width = 121
        Height = 23
        Hint = 
          'CodeWarp invokation key (CTRL+W by default).'#13#10'See Delphi'#39's TextT' +
          'oShortCut function for more info.'
        TabOrder = 1
      end
      object CBToolBar: TCheckBox
        Left = 88
        Top = 167
        Width = 241
        Height = 17
        HelpContext = 160
        Caption = '&Activate Shorcut ToolBar'
        TabOrder = 5
      end
      object CBWarpPreview: TCheckBox
        Left = 88
        Top = 186
        Width = 241
        Height = 17
        HelpContext = 160
        Caption = 'Activate Warp Preview Wi&ndow'
        TabOrder = 8
      end
    end
    object TSVCLPath: TTabSheet
      Caption = '&VCL Path'
      object Label2: TLabel
        Left = 8
        Top = 67
        Width = 130
        Height = 15
        Caption = 'Delphi VCL Source Path :'
      end
      object RBNone: TRadioButton
        Left = 40
        Top = 97
        Width = 361
        Height = 17
        Hint = 'Check this option to remove the "VCL Source" Entry'
        HelpContext = 180
        Caption = '&None / Unavailable'
        TabOrder = 1
        OnClick = RBNoneClick
      end
      object RBDelphi11: TRadioButton
        Left = 40
        Top = 120
        Width = 393
        Height = 17
        Hint = 
          'Check this options if you installed Delphi 3 VCL Source in the d' +
          'efault path'
        HelpContext = 180
        Caption = 'C:\Program Files (x86)\Embarcadero\Studio\22.0\source'
        TabOrder = 2
        OnClick = RBDelphi11Click
      end
      object RBCustom: TRadioButton
        Left = 40
        Top = 166
        Width = 17
        Height = 17
        Hint = 'Check to specify a custom VCL path'
        HelpContext = 180
        TabOrder = 4
        OnClick = RBCustomClick
      end
      object EDPath: TEdit
        Left = 58
        Top = 163
        Width = 393
        Height = 23
        Hint = 'Enter your custom VCL path here'
        HelpContext = 180
        TabOrder = 5
        OnChange = EDPathChange
      end
      object StaticText2: TStaticText
        AlignWithMargins = True
        Left = 8
        Top = 8
        Width = 457
        Height = 50
        Margins.Left = 8
        Margins.Top = 8
        Margins.Right = 8
        Margins.Bottom = 8
        Align = alTop
        AutoSize = False
        BorderStyle = sbsSunken
        Caption = 
          'CodeWarp offers direct access to files stored within a directory' +
          ' structure.'#13#10'This entry allows to set the VCL source directory (' +
          'Pro or C/S version of Delphi required).'
        Color = 12189695
        ParentColor = False
        TabOrder = 0
        Transparent = False
      end
      object RBDelphi12: TRadioButton
        Left = 40
        Top = 143
        Width = 393
        Height = 17
        Hint = 
          'Check this options if you installed Delphi 4 VCL Source in the d' +
          'efault path'
        HelpContext = 180
        Caption = 'C:\Program Files (x86)\Embarcadero\Studio\23.0\source'
        TabOrder = 3
        OnClick = RBDelphi11Click
      end
    end
    object TSLocalLibs: TTabSheet
      Caption = '&Local Libs'
      object EDNewEntry: TEdit
        Left = 10
        Top = 227
        Width = 97
        Height = 23
        TabOrder = 0
      end
      object EDNewPath: TEdit
        Left = 114
        Top = 227
        Width = 209
        Height = 23
        TabOrder = 1
      end
      object BUAdd: TButton
        Left = 426
        Top = 226
        Width = 35
        Height = 21
        Caption = '&Add'
        TabOrder = 3
        OnClick = BUAddClick
      end
      object StaticText6: TStaticText
        AlignWithMargins = True
        Left = 8
        Top = 8
        Width = 457
        Height = 36
        Margins.Left = 8
        Margins.Top = 8
        Margins.Right = 8
        Margins.Bottom = 8
        Align = alTop
        AutoSize = False
        BorderStyle = sbsSunken
        Caption = 
          'CodeWarp offers direct access to files stored within a directory' +
          ' structure.'#13#10'This entry allows to set your Local Libraries (entr' +
          'y name and path).'
        Color = 12189695
        ParentColor = False
        TabOrder = 5
        Transparent = False
      end
      object LVLocalLibs: TListView
        AlignWithMargins = True
        Left = 8
        Top = 52
        Width = 457
        Height = 165
        Hint = 
          'Local Libs directories'#13#10'+ Use Add button to add a new entry.'#13#10'+ ' +
          'Use Del key to remove an entry.'#13#10'+ Double-Click to Edit Path'
        Margins.Left = 8
        Margins.Top = 0
        Margins.Right = 8
        Margins.Bottom = 45
        Align = alClient
        BorderStyle = bsNone
        Columns = <
          item
            Caption = 'Entry Name'
            Width = 100
          end
          item
            Caption = 'Entry Path'
            Width = 270
          end
          item
            Caption = 'Entry Filter'
            Width = 63
          end>
        ColumnClick = False
        HotTrack = True
        RowSelect = True
        PopupMenu = PMLocalLibs
        TabOrder = 4
        ViewStyle = vsReport
        OnDblClick = LVLocalLibsDblClick
        OnKeyDown = LVLocalLibsKeyDown
      end
      object EDNewFilter: TEdit
        Left = 331
        Top = 226
        Width = 89
        Height = 23
        Hint = 'File Filter'#13#10'example : '#39'*.pas;*.inc'#39
        TabOrder = 2
      end
    end
    object TabSheet2: TTabSheet
      HelpContext = 200
      Caption = '&Re-Parse'
      object Label3: TLabel
        Left = 8
        Top = 136
        Width = 120
        Height = 15
        Caption = 'Re-Parse Comparison :'
      end
      object RBParseAlways: TRadioButton
        Left = 142
        Top = 136
        Width = 243
        Height = 17
        Hint = 
          'Unit is parsed each time CodeWarp is invoked.'#13#10'This should be yo' +
          'ur option if you'#39're not having a look at the VCL.'
        HelpContext = 200
        Caption = '&Never compare, Always re-parse'
        TabOrder = 1
        OnClick = RBParseAlwaysClick
      end
      object RBParse8000: TRadioButton
        Tag = 1
        Left = 142
        Top = 159
        Width = 259
        Height = 17
        Hint = 
          'Really big units are not re-parsed (approx. 200k and more)'#13#10'I kn' +
          'ow just 2 cases : comctrls (391k) and dbtables (235k)'
        HelpContext = 200
        Caption = 'If Unit has more than &8000 lines'
        TabOrder = 2
        OnClick = RBParseAlwaysClick
      end
      object RBParse4000: TRadioButton
        Tag = 2
        Left = 142
        Top = 182
        Width = 243
        Height = 17
        Hint = 
          'Big units are not re-parsed (approx. 100k and more)'#13#10'There are s' +
          'ome of these in the VCL (classes, stdctrls...)'
        HelpContext = 200
        Caption = 'If Unit has more than &4000 lines'
        TabOrder = 3
        OnClick = RBParseAlwaysClick
      end
      object RBParse2000: TRadioButton
        Tag = 3
        Left = 142
        Top = 205
        Width = 243
        Height = 17
        Hint = 'Large units are not re-parsed (approx. 50k and more)'
        HelpContext = 200
        Caption = 'If Unit has more than &2000 lines'
        TabOrder = 4
        OnClick = RBParseAlwaysClick
      end
      object RBCompareAlways: TRadioButton
        Tag = 4
        Left = 142
        Top = 228
        Width = 259
        Height = 17
        Hint = 'Source Comparison is always performed before re-parsing'
        HelpContext = 200
        Caption = '&Always compare before parsing'
        TabOrder = 5
        OnClick = RBParseAlwaysClick
      end
      object StaticText1: TStaticText
        AlignWithMargins = True
        Left = 8
        Top = 8
        Width = 457
        Height = 110
        Margins.Left = 8
        Margins.Top = 8
        Margins.Right = 8
        Margins.Bottom = 8
        Align = alTop
        AutoSize = False
        BorderStyle = sbsSunken
        Caption = 
          'CodeWarp default behaviour is to fully re-parse the active unit ' +
          'each time it is invoked.'#13#10'This means that what you see in the tr' +
          'ee is always up-to-date, but can eat up some time if you'#39're on a' +
          ' slow computer and browsing a very large file (100 Ko or more, s' +
          'uch monsters exist in the VCL).'#13#10'CodeWarp can activate a compari' +
          'son mechanism before re-parsing a unit : it will re-parse and re' +
          '-build the tree only if something changed in the source.'#13#10'This o' +
          'ptions allows you tune the comparison mechanism activation for f' +
          'iles of a certain size.'
        Color = 12189695
        ParentColor = False
        TabOrder = 0
        Transparent = False
      end
    end
  end
  object BBHelp: TBitBtn
    Left = 456
    Top = 306
    Width = 33
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
    TabOrder = 2
    OnClick = BBHelpClick
  end
  object PMLocalLibs: TPopupMenu
    OnPopup = PMLocalLibsPopup
    Left = 380
    Top = 136
    object MIEditName: TMenuItem
      Caption = 'Edit Entry Name'
      OnClick = MIEditNameClick
    end
    object MIEditPath: TMenuItem
      Caption = 'Edit Entry Path'
      OnClick = LVLocalLibsDblClick
    end
    object MIEditFilter: TMenuItem
      Caption = 'Edit Entry Filter'
      OnClick = MIEditFilterClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object MIMoveUp: TMenuItem
      Caption = 'Move Entry Up'
      OnClick = MIMoveUpClick
    end
    object MIMoveDown: TMenuItem
      Caption = 'Move Entry Down'
      OnClick = MIMoveDownClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object MIRemoveEntry: TMenuItem
      Caption = 'Remove Entry'
      OnClick = MIRemoveEntryClick
    end
  end
end
