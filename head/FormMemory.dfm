object frmMemory: TfrmMemory
  Left = 1510
  Top = 10
  Caption = #1055#1072#1084#1103#1090#1100
  ClientHeight = 651
  ClientWidth = 278
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCanResize = FormCanResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object grdMemory: TStringGrid
    Left = 0
    Top = 0
    Width = 278
    Height = 651
    Align = alClient
    ColCount = 3
    DefaultColWidth = 85
    DefaultRowHeight = 18
    FixedCols = 0
    RowCount = 65537
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
    ScrollBars = ssVertical
    TabOrder = 0
    OnDrawCell = grdMemoryDrawCell
    ExplicitHeight = 861
  end
end
