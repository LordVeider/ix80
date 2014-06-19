object frmValue: TfrmValue
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = #1047#1085#1072#1095#1077#1085#1080#1077
  ClientHeight = 130
  ClientWidth = 185
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = edtValueChange
  DesignSize = (
    185
    130)
  PixelsPerInch = 96
  TextHeight = 13
  object lblHex: TLabel
    Left = 8
    Top = 11
    Width = 169
    Height = 13
    AutoSize = False
    Caption = 'HEX:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblBin: TLabel
    Left = 8
    Top = 30
    Width = 169
    Height = 13
    AutoSize = False
    Caption = 'BIN:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblDec: TLabel
    Left = 8
    Top = 49
    Width = 169
    Height = 13
    AutoSize = False
    Caption = 'DEC:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblHexValue: TLabel
    Left = 40
    Top = 11
    Width = 169
    Height = 13
    AutoSize = False
    Caption = 'lblHex'
  end
  object lblBinValue: TLabel
    Left = 40
    Top = 30
    Width = 169
    Height = 13
    AutoSize = False
    Caption = 'lblHex'
  end
  object lblDecValue: TLabel
    Left = 40
    Top = 49
    Width = 169
    Height = 13
    AutoSize = False
    Caption = 'lblHex'
  end
  object btnCancel: TButton
    Left = 95
    Top = 97
    Width = 81
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1084#1077#1085#1080#1090#1100
    ImageIndex = 1
    Images = ilButtons
    TabOrder = 0
    OnClick = btnCancelClick
  end
  object edtValue: TEdit
    Left = 8
    Top = 68
    Width = 169
    Height = 21
    TabOrder = 1
    Text = '0'
    OnChange = edtValueChange
  end
  object btnApply: TButton
    Left = 8
    Top = 97
    Width = 81
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    ImageIndex = 0
    Images = ilButtons
    TabOrder = 2
    OnClick = btnApplyClick
  end
  object ilButtons: TImageList
    ColorDepth = cd32Bit
    Left = 440
    Top = 200
    Bitmap = {
      494C010102000800280010001000FFFFFFFF2110FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      00000000000000000000000000000000000000000000000000020000000C0000
      00160000001A0000001A0000001A0000001A0000001A0000001A0000001A0000
      001A000000170000000C000000020000000000000000000000020000000C0000
      00160000001A0000001A0000001A0000001A0000001A0000001A0000001A0000
      001A000000170000000C00000002000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000004000000170000
      002B0007004301220080003B00AB024600C4024600C4003B00AB012200800007
      00430000002D0000001800000004000000000000000000000004000000170000
      002B000007430000228000003BAB000046C4000046C400003BAB000022800000
      07430000002D0000001800000004000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000218
      004D055600BF108C07E31BBC0DF520D210FD20D210FD1BBC0DF5108C07E30556
      00BF0218004D0000000000000000000000000000000000000000000000000000
      184D000056BF07078CE30D0DBCF51010D2FD1010D2FD0D0DBCF507078CE30000
      56BF0000184D0000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000325004D0B6D
      03CD1FBD10F622D111FF21B610FF21D110FF21D110FF21D110FF21D110FF1CBB
      0EF6096D01CD0325004D000000000000000000000000000000000000254D0303
      6DCD1111BDF61111B6FF1010D1FF1010D1FF1010D1FF1010D1FF1010B6FF0E0E
      BBF601016DCD0000254D00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000010E001A0B6702BF25B9
      16F622C811FF21B210FFE6E6E6FF21B210FF21C810FF21C810FF21C810FF21C8
      10FF1DB50EF6096700BF010E001A000000000000000000000E1A020267BF1717
      BAF61111B2FFDCDCDCFF1010B2FF1010C8FF1010C8FF1010B2FFEEEEEEFF1010
      B2FF0E0EB5F6000067BF00000E1A000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000053A006C1E9610E325C0
      14FF21AD10FFDEDEDEFFE2E2E2FFE6E6E6FF21AD10FF21BE10FF21BE10FF21BE
      10FF21BE10FF138F07E3053A006C000000000000000000003A6C121296E21515
      C1FFD1D1D1FFD6D6D6FFDCDCDCFF1010ADFF1010ADFFEAEAEAFFEEEEEEFFEEEE
      EEFF1010BEFF07078FE300003A6C000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000095B00A738B529F522AE
      11FFD5D5D5FFDADADAFFDEDEDEFFE2E2E2FFE6E6E6FF21A810FF21B410FF21B4
      10FF21B410FF1FA810F5095B00A7000000000000000000005BA72C2CB8F51111
      B4FF1010B4FFD1D1D1FFD6D6D6FFDCDCDCFFE2E2E2FFE6E6E6FFEAEAEAFF1010
      B4FF1010B4FF1111A8F500005BA7000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000C7000C44FC63EFDA9D7
      A2FFD5D5D5FFEBEBEBFF21A510FFDEDEDEFFE2E2E2FFE6E6E6FF21A310FF21AA
      10FF21AA10FF27AC16FD0C7000C40000000000000000000070C44343CBFD2525
      B5FF1313ABFF1010AAFFD1D1D1FFD6D6D6FFDCDCDCFFE2E2E2FF1010AAFF1010
      AAFF1010AAFF1717ADFD000070C4000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000C7300C452C941FD3BB3
      2AFFF8F8F8FF2CA81BFF22A211FF219F10FFDEDEDEFFE2E2E2FFE6E6E6FF219E
      10FF21A110FF2BA81AFD0C7300C40000000000000000000073C44848CFFD3232
      BBFF2D2DB8FF12129FFFCECECEFFD1D1D1FFD6D6D6FFDCDCDCFF10109EFF1010
      A1FF1010A1FF1C1CAAFD000073C4000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000B6500A74DC33CF546BE
      35FF3DB52CFF46BE35FF40B92FFF36AF25FF2CA41BFFE2E2E2FFE3E3E3FFE7E7
      E7FF259E14FF31A921F50B6500A70000000000000000000065A74343CAF53636
      BFFF2222ABFFFFFFFFFFF7F7F7FFE8E8E8FFDEDEDEFFDBDBDBFFDDDDDDFF1010
      9BFF1515A0FF2525ADF5000065A7000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000843006C36AA27E353CB
      42FF4DC53CFF4DC53CFF4DC53CFF4DC53CFF4DC53CFF43BB32FFFFFFFFFFA7E2
      9EFF51C940FF2FA420E30843006C00000000000000000000436C2D2DB0E34848
      D1FFFFFFFFFFFFFFFFFFFFFFFFFF4141CAFF4141CAFFFFFFFFFFFFFFFFFFFFFF
      FFFF4646CFFF2525A8E30000436C000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000210001A127D05BF58CF
      48F657CF46FF56CE45FF56CE45FF56CE45FF56CE45FF56CE45FF49C138FF51C9
      40FF53CA42F6127C03BF0210001A00000000000000000000101A05057EBF5252
      DAF65050D9FFFFFFFFFF4E4ED7FF4E4ED7FF4E4ED7FF4E4ED7FFFFFFFFFF4F4F
      D8FF4B4BD4F605057DBF0000101A000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000632004D1B8C
      0BCD5BD24AF662DA51FF5ED64DFF5ED64DFF5ED64DFF5ED64DFF61D950FF59D1
      48F6198C09CD0632004D000000000000000000000000000000000000324D0C0C
      8ECD5757DFF65E5EE7FF5A5AE3FF5A5AE3FF5A5AE3FF5A5AE3FF5E5EE7FF5454
      DCF60C0C8CCD0000324D00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000633
      004D148205BF3AB229E35AD34AF569E158FD69E157FD5AD24AF539B128E31482
      05BF0633004D0000000000000000000000000000000000000000000000000000
      334D060682BF3030B9E35858E0F56868F1FD6767F0FD5757DFF52F2FB8E30606
      82BF0000334D0000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000211001A0848006C0E6F00A6108200C4108200C40E6F00A60848006C0211
      001A000000000000000000000000000000000000000000000000000000000000
      00000000111A0000486C00006FA6000082C4000082C400006FA60000486C0000
      111A000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF0080018001000000008001800100000000
      E007E00700000000C003C0030000000080018001000000008001800100000000
      8001800100000000800180010000000080018001000000008001800100000000
      80018001000000008001800100000000C003C00300000000E007E00700000000
      F00FF00F00000000FFFFFFFF0000000000000000000000000000000000000000
      000000000000}
  end
end
