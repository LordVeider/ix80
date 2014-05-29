object frmNumeric: TfrmNumeric
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = #1057#1080#1089#1090#1077#1084#1099' '#1089#1095#1080#1089#1083#1077#1085#1080#1103
  ClientHeight = 148
  ClientWidth = 328
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object edtInput: TEdit
    Left = 8
    Top = 8
    Width = 153
    Height = 21
    TabOrder = 0
  end
  object edtOutput: TEdit
    Left = 167
    Top = 8
    Width = 153
    Height = 21
    ReadOnly = True
    TabOrder = 1
  end
  object rgInput: TRadioGroup
    Left = 8
    Top = 35
    Width = 153
    Height = 54
    Caption = #1048#1089#1093#1086#1076#1085#1072#1103
    ItemIndex = 0
    Items.Strings = (
      'BIN'
      'DEC'
      'HEX')
    TabOrder = 2
  end
  object rgOutput: TRadioGroup
    Left = 167
    Top = 35
    Width = 153
    Height = 54
    Caption = #1055#1086#1083#1091#1095#1072#1077#1084#1072#1103
    ItemIndex = 0
    Items.Strings = (
      'BIN'
      'DEC'
      'HEX')
    TabOrder = 3
  end
  object rgFormat: TRadioGroup
    Left = 8
    Top = 95
    Width = 153
    Height = 46
    Caption = #1060#1086#1088#1084#1072#1090' '#1087#1088#1077#1076#1089#1090#1072#1074#1083#1077#1085#1080#1103
    ItemIndex = 0
    Items.Strings = (
      #1041#1077#1079#1079#1085#1072#1082#1086#1074#1099#1081
      #1047#1085#1072#1082#1086#1074#1099#1081)
    TabOrder = 4
  end
  object btnMagic: TButton
    Left = 167
    Top = 95
    Width = 153
    Height = 46
    Caption = #1052#1040#1043#1048#1071
    TabOrder = 5
    OnClick = btnMagicClick
  end
end
