unit FormMemory;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids;

type
  TfrmMemory = class(TForm)
    grdMemory: TStringGrid;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMemory: TfrmMemory;

implementation

{$R *.dfm}

procedure TfrmMemory.FormShow(Sender: TObject);
var
  i, j: Integer;
begin
  with grdMemory do
  begin
    Cells[0, 0] := 'Off';
    Cells[1, 0] := '00';
    Cells[2, 0] := '01';
    Cells[3, 0] := '02';
    Cells[4, 0] := '03';
    Cells[5, 0] := '04';
    Cells[6, 0] := '05';
    Cells[7, 0] := '06';
    Cells[8, 0] := '07';
    Cells[9, 0] := '08';
    Cells[10, 0] := '09';
    Cells[11, 0] := '0A';
    Cells[12, 0] := '0B';
    Cells[13, 0] := '0C';
    Cells[14, 0] := '0D';
    Cells[15, 0] := '0E';
    Cells[16, 0] := '0F';
    Cells[0, 1] := '0000';
    Cells[0, 2] := '0010';
    Cells[0, 3] := '0020';
    Cells[0, 4] := '0030';
    Cells[0, 5] := '0040';
    Cells[0, 6] := '0050';
    Cells[0, 7] := '0060';
    Cells[0, 8] := '0070';
    for i := 1 to 16 do
      for j := 1 to 8 do
        Cells[i, j] := '00';
  end;
end;

end.
