unit FormMemory;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Common, Logic;

type
  TfrmMemory = class(TForm)
    grdMemory: TStringGrid;
    grdNewMem: TStringGrid;
    procedure FormShow(Sender: TObject);
    procedure grdNewMemDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Memory: TMemory;
    TrueMem: Boolean;
    procedure DrawMemory;
  end;

var
  frmMemory: TfrmMemory;

implementation

{$R *.dfm}

uses
  FormValue;

procedure TfrmMemory.DrawMemory;
var
  i, j: Integer;
begin
  if TrueMem then
  begin
    Width := 294;
    Height := 900;
    grdMemory.Visible := False;
    grdNewMem.Visible := True;
    grdNewMem.Cells[0, 0] := 'Address';
    grdNewMem.Cells[1, 0] := 'HEX';
    grdNewMem.Cells[2, 0] := 'BIN';
    for i := 1 to 100 do
    begin
      grdNewMem.Cells[0, i] := IntToNumStr(i-1, SHEX, 4) + 'H';
      if Assigned(Memory) then
      begin
        grdNewMem.Cells[1, i] := IntToNumStr(Memory.ReadMemory(i-1), SHEX, 2);
        grdNewMem.Cells[2, i] := IntToNumStr(Memory.ReadMemory(i-1), SBIN, 8);
      end
      else
      begin
        grdNewMem.Cells[1, i] := IntToNumStr(0, SHEX, 2);
        grdNewMem.Cells[2, i] := IntToNumStr(0, SBIN, 8);
      end;
    end;
  end
  else
  begin
    Width := 597;
    Height := 467;
    grdNewMem.Visible := False;
    grdMemory.Visible := True;
    with grdMemory do
    begin
      Cells[0, 0] := 'Off';
      Cells[1, 0] := '0';
      Cells[2, 0] := '1';
      Cells[3, 0] := '2';
      Cells[4, 0] := '3';
      Cells[5, 0] := '4';
      Cells[6, 0] := '5';
      Cells[7, 0] := '6';
      Cells[8, 0] := '7';
      Cells[9, 0] := '8';
      Cells[10, 0] := '9';
      Cells[11, 0] := 'A';
      Cells[12, 0] := 'B';
      Cells[13, 0] := 'C';
      Cells[14, 0] := 'D';
      Cells[15, 0] := 'E';
      Cells[16, 0] := 'F';
      Cells[0, 1] := '0000';
      Cells[0, 2] := '0010';
      Cells[0, 3] := '0020';
      Cells[0, 4] := '0030';
      Cells[0, 5] := '0040';
      Cells[0, 6] := '0050';
      Cells[0, 7] := '0060';
      Cells[0, 8] := '0070';
      Cells[0, 9] := '0080';
      Cells[0, 10] := '0090';
      Cells[0, 11] := '00A0';
      Cells[0, 12] := '00B0';
      Cells[0, 13] := '00C0';
      Cells[0, 14] := '00D0';
      Cells[0, 15] := '00E0';
      Cells[0, 16] := '00F0';
      Cells[0, 17] := '0100';
      Cells[0, 18] := '0110';
      Cells[0, 19] := '0120';
      Cells[0, 20] := '0130';
      Cells[0, 21] := '0140';
      Cells[0, 22] := '0150';
      Cells[0, 23] := '0160';
      Cells[0, 24] := '0170';
      Cells[0, 25] := '0180';
      for i := 1 to 16 do
        for j := 1 to 25 do
          Cells[i, j] := '00';
    end;
  end;
end;

procedure TfrmMemory.FormShow(Sender: TObject);
begin
  DrawMemory;
end;

procedure TfrmMemory.grdNewMemDblClick(Sender: TObject);
begin
  if Assigned(Memory) then
    if grdNewMem.Row > 0 then
    begin
      frmValue.FMemory := Self;
      frmValue.Address := grdNewMem.Row - 1;
      frmValue.Left := Mouse.CursorPos.X;
      frmValue.Top := Mouse.CursorPos.Y;
      frmValue.ShowModal;
    end;
end;

end.
