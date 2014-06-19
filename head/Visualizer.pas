unit Visualizer;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//Модуль визуализации

interface

uses
  FormScheme, FormMemory, Instructions, Common,
  Classes, StdCtrls, Graphics, SysUtils;

type
  TVisualizer = class
  public
    procedure CleanSelection;
    procedure OnlyUpdate(Regs: TRegisters);
    procedure OnlyUpdateMem(Cells: TMemoryCells);
    procedure ShowReg(Reg: TDataReg);
  end;

implementation

{ TVisualizer }

procedure TVisualizer.OnlyUpdate(Regs: TRegisters);
begin
  with frmScheme, Regs do
  begin
    edtA.Text := IntToNumStr(DataRegisters[RA], SHEX, 2) + 'H';
    edtW.Text := IntToNumStr(DataRegisters[RW], SHEX, 2) + 'H';
    edtZ.Text := IntToNumStr(DataRegisters[RZ], SHEX, 2) + 'H';
    edtB.Text := IntToNumStr(DataRegisters[RB], SHEX, 2) + 'H';
    edtC.Text := IntToNumStr(DataRegisters[RC], SHEX, 2) + 'H';
    edtD.Text := IntToNumStr(DataRegisters[RD], SHEX, 2) + 'H';
    edtE.Text := IntToNumStr(DataRegisters[RE], SHEX, 2) + 'H';
    edtH.Text := IntToNumStr(DataRegisters[RH], SHEX, 2) + 'H';
    edtL.Text := IntToNumStr(DataRegisters[RL], SHEX, 2) + 'H';
    edtSP.Text := IntToNumStr(SP, SHEX, 4) + 'H';
    edtPC.Text := IntToNumStr(PC, SHEX, 4) + 'H';
    edtIR.Text := IntToNumStr(IR, SHEX, 2) + 'H';
    with grdPSW do
    begin
      ColWidths[3] := 26;
      ColWidths[4] := 26;
      Cells[0,0] := 'S';
      Cells[1,0] := 'Z';
      Cells[2,0] := 'P';
      Cells[3,0] := 'AC';
      Cells[4,0] := 'CY';
      Cells[0,1] := IntToStr((DataRegisters[RF] shr 7) and 1);
      Cells[1,1] := IntToStr((DataRegisters[RF] shr 6) and 1);
      Cells[2,1] := IntToStr((DataRegisters[RF] shr 2) and 1);
      Cells[3,1] := IntToStr((DataRegisters[RF] shr 4) and 1);
      Cells[4,1] := IntToStr((DataRegisters[RF] shr 0) and 1);
    end;
  end;
end;

procedure TVisualizer.OnlyUpdateMem(Cells: TMemoryCells);
begin
  with frmMemory do
  begin
    MemoryCells := Cells;
    grdVisMem.Repaint;
  end;
end;

procedure TVisualizer.CleanSelection;
var
  Cnt: Integer;
begin
  with frmScheme do
    for Cnt := 0 to ComponentCount - 1 do
      if Components[Cnt] is TEdit then
        TEdit(Components[Cnt]).Color := clWindow;
end;

procedure TVisualizer.ShowReg;
var
  CurrentEdit: TEdit;
begin
  with frmScheme do
    case Reg of
      RA: CurrentEdit := edtA;
      RB: CurrentEdit := edtB;
      RC: CurrentEdit := edtC;
      RD: CurrentEdit := edtD;
      RE: CurrentEdit := edtE;
      RH: CurrentEdit := edtH;
      RL: CurrentEdit := edtL;
      RW: CurrentEdit := edtW;
      RZ: CurrentEdit := edtZ;
    end;
  CurrentEdit.Color := clMoneyGreen;
end;

end.
