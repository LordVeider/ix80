unit FormScheme;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.Grids, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ImgList, Common, Logic;

type
  TfrmScheme = class(TForm)
    imgSchemeBackground: TImage;
    edtA: TEdit;
    edtIR: TEdit;
    edtW: TEdit;
    edtZ: TEdit;
    edtB: TEdit;
    edtC: TEdit;
    edtD: TEdit;
    edtE: TEdit;
    edtH: TEdit;
    edtL: TEdit;
    edtSP: TEdit;
    edtPC: TEdit;
    grdPSW: TStringGrid;
    grdNewMem: TStringGrid;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure DrawProcessor(Processor: TProcessor);
    procedure DrawMemory(Memory: TMemory);
  end;

var
  frmScheme: TfrmScheme;

implementation

{$R *.dfm}

{ TfrmScheme }

procedure TfrmScheme.DrawMemory(Memory: TMemory);
var
  i: Integer;
begin
  for i := 0 to 99 do
  begin
    grdNewMem.Cells[0, i] := WordToHexString(i) + 'H';
    if Assigned(Memory) then
    begin
      grdNewMem.Cells[1, i] := WordToHexString(Memory.ReadMemory(i));
      grdNewMem.Cells[2, i] := ByteToBinString(Memory.ReadMemory(i));
    end
    else
    begin
      grdNewMem.Cells[1, i] := WordToHexString(0);
      grdNewMem.Cells[2, i] := ByteToBinString(0);
    end;
  end;
end;

procedure TfrmScheme.DrawProcessor(Processor: TProcessor);
begin
  with Processor do
  begin
    edtA.Text := GetDataRegister(RA).ToString;
    edtB.Text := GetDataRegister(RB).ToString;
    edtC.Text := GetDataRegister(RC).ToString;
    edtD.Text := GetDataRegister(RD).ToString;
    edtE.Text := GetDataRegister(RE).ToString;
    edtH.Text := GetDataRegister(RH).ToString;
    edtL.Text := GetDataRegister(RL).ToString;
    edtW.Text := GetDataRegister(RW).ToString;
    edtZ.Text := GetDataRegister(RZ).ToString;
    edtSP.Text := WordToHexString(GetStackPointer) + 'H';
    edtPC.Text := WordToHexString(GetProgramCounter) + 'H';
    edtIR.Text := GetInstructionRegister.ToString;
    with grdPSW do
    begin
      Cells[0,0] := 'S';
      Cells[1,0] := 'Z';
      Cells[2,0] := '0';
      Cells[3,0] := 'AC';
      Cells[4,0] := '0';
      Cells[5,0] := 'P';
      Cells[6,0] := '1';
      Cells[7,0] := 'C';
      Cells[0,1] := GetFlag(FS).ToString;
      Cells[1,1] := GetFlag(FZ).ToString;
      Cells[2,1] := '0';
      Cells[3,1] := GetFlag(FAC).ToString;
      Cells[4,1] := '0';
      Cells[5,1] := GetFlag(FP).ToString;
      Cells[6,1] := '1';
      Cells[7,1] := GetFlag(FC).ToString;
    end;
  end;
end;

end.
