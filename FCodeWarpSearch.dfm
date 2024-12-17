object CodeWarpSearch: TCodeWarpSearch
  Left = 194
  Top = 116
  HelpContext = 180
  BorderStyle = bsDialog
  Caption = 'CodeWarp Search'
  ClientHeight = 114
  ClientWidth = 300
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Sego UI'
  Font.Style = []
  HelpFile = 'CodeWarp.hlp'
  Position = poScreenCenter
  ShowHint = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 14
  object LASearchFrom: TLabel
    Left = 8
    Top = 8
    Width = 83
    Height = 14
    Caption = 'Searching from...'
  end
  object BUFind: TButton
    Left = 216
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Find...'
    Default = True
    TabOrder = 3
    OnClick = BUFindClick
  end
  object BUCancel: TButton
    Left = 216
    Top = 72
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object CBCaseSensitive: TCheckBox
    Left = 96
    Top = 64
    Width = 89
    Height = 17
    Caption = 'Case Sensitive'
    TabOrder = 2
    OnClick = CBSearchTextChange
  end
  object RBDive: TRadioButton
    Left = 8
    Top = 65
    Width = 65
    Height = 17
    Hint = 
      'Search the tree by diving as deep as possible, as soon as possib' +
      'le'
    Caption = 'Dive'
    Checked = True
    TabOrder = 0
    TabStop = True
    OnClick = CBSearchTextChange
  end
  object RBTraverse: TRadioButton
    Left = 8
    Top = 88
    Width = 65
    Height = 17
    Hint = 'Search the tree by fully traversing a depth before going deeper'
    Caption = 'Traverse'
    TabOrder = 1
    OnClick = CBSearchTextChange
  end
  object CBSearchText: TComboBox
    Left = 8
    Top = 32
    Width = 193
    Height = 22
    DropDownCount = 16
    TabOrder = 5
    OnChange = CBSearchTextChange
  end
end
