unit FormMemory;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//Визуальная схема памяти

interface

uses
  Common, Typelib,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids;

type
  TfrmMemory = class(TForm)
    grdMemory: TStringGrid;
    procedure FormShow(Sender: TObject);
    procedure grdMemoryDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure grdMemoryDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    MemoryCells: TMemoryCells;
    SelectedCells: array [Word] of Boolean;
    CompactMode: Boolean;
    procedure SwitchMode(CompactMode: Boolean);
  end;

var
  frmMemory: TfrmMemory;

implementation

{$R *.dfm}

uses
  FormValue;

procedure TfrmMemory.grdMemoryDblClick(Sender: TObject);
var
  Addr: Word;
begin
  with grdMemory do
    if CompactMode then
      Addr := (Col-1) + (Row-1)*16
    else
      Addr := Row-1;
  with frmValue do
  begin
    edtValue.Text := IntToStr(MemoryCells[Addr]);
    if ShowModal = mrOk then
      SendMessage(Application.MainForm.Handle, WM_VALUE, MakeWParam(NumStrToIntAuto(edtValue.Text), 6), MakeLParam(Addr, 0));
  end;
end;

procedure TfrmMemory.grdMemoryDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  OutValue: String;
begin
  with grdMemory, Canvas do
  begin
    if CompactMode then
    begin
      if ACol+ARow = 0 then
        OutValue := 'Off'
      else if ARow = 0 then
        OutValue := IntToNumStr(ACol-1, SHEX, 1)
      else if ACol = 0 then
        OutValue := IntToNumStr((ARow-1)*16, SHEX, 4)
      else
      begin
        if SelectedCells[(ACol-1) + (ARow-1)*16] then
          Brush.Color := COLOR_HL;
        OutValue := IntToNumStr(MemoryCells[(ACol-1) + (ARow-1)*16], SHEX, 2);
      end;
    end
    else
    begin
      if ARow = 0 then
      case ACol of
        0: OutValue := 'Address';
        1: OutValue := 'HEX';
        2: OutValue := 'BIN';
        3: OutValue := 'Signed';
        4: OutValue := 'Unsigned';
      end
      else
      begin
        if SelectedCells[ARow-1] then
          Brush.Color := COLOR_HL;
        case ACol of
          0: OutValue := IntToNumStr(ARow-1, SHEX, 4) + 'H';
          1: OutValue := IntToNumStr(MemoryCells[ARow-1], SHEX, 2);
          2: OutValue := IntToNumStr(MemoryCells[ARow-1], SBIN, 8);
          3: OutValue := IntToStr(MemoryCells[ARow-1]);
          4: OutValue := IntToStr(Byte(MemoryCells[ARow-1]));
        end;
      end;
    end;
    Rect.Left := Rect.Left-4;
    FillRect(Rect);
    TextOut(Rect.Left+6, Rect.Top+2, OutValue);
  end;
end;

procedure TfrmMemory.SwitchMode(CompactMode: Boolean);
begin
  Self.CompactMode := CompactMode;
  with grdMemory do
    if CompactMode then
    begin
      Options := Options - [goRowSelect];
      RowCount := 4097;
      ColCount := 17;
      FixedCols := 1;
      DefaultColWidth := 20;
      ColWidths[0] := 36;
      Self.Constraints.MinWidth := 409;
      Self.Constraints.MaxWidth := 409;
    end
    else
    begin
      Options := Options + [goRowSelect];
      RowCount := 65537;
      ColCount := 5;
      FixedCols := 0;
      DefaultColWidth := 60;
      Self.Constraints.MinWidth := 341;
      Self.Constraints.MaxWidth := 341;
    end;
end;

procedure TfrmMemory.FormShow(Sender: TObject);
begin
  SwitchMode(CompactMode);
end;

end.
