unit Visualizer;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//������ ������������

interface

uses
  FormScheme, FormMemory, Instructions, Common, Typelib,
  Classes, StdCtrls, ExtCtrls, Graphics, SysUtils;

type
  TVisualizer = class
  private
    VisLevel: Byte;                               //������� ������������ (0 - ������, 1 - ����, 2 - ��������)
  public
    procedure SetVisLevel(VisLevel: Byte);
    procedure CleanLog;
    procedure CleanSelection;
    procedure CleanSelectionMem;
    procedure OnlyUpdate(Regs: TRegisters);
    procedure OnlyUpdateMem(Cells: TMemoryCells);
    procedure ShowDataReg(DataReg: TDataReg);
    procedure ShowRegPair(RegPair: TRegPair);
    procedure ShowFlag(Flag: TFlag);
    procedure ShowStackPointer;
    procedure ShowProgramCounter;
    procedure ShowInstrRegister;
    procedure ShowAddrBuf(Addr: Word);
    procedure ShowALU;
    procedure ShowDecoder;
    procedure ShowMemoryCell(Addr: Word);
    procedure AddLog(Value: String);
  end;

implementation

{ TVisualizer }

procedure TVisualizer.SetVisLevel;
begin
  Self.VisLevel := VisLevel;
end;

procedure TVisualizer.CleanSelectionMem;
var
  Addr: Word;
begin
  for Addr := 0 to 65535 do
    frmMemory.SelectedCells[Addr] := False;
end;

procedure TVisualizer.OnlyUpdate(Regs: TRegisters);
begin
  with frmScheme, Regs do
  begin
    edtA.Text     := IntToNumStr(DataRegisters[RA], SHEX, 2) + 'H';
    edtW.Text     := IntToNumStr(DataRegisters[RW], SHEX, 2) + 'H';
    edtZ.Text     := IntToNumStr(DataRegisters[RZ], SHEX, 2) + 'H';
    edtB.Text     := IntToNumStr(DataRegisters[RB], SHEX, 2) + 'H';
    edtC.Text     := IntToNumStr(DataRegisters[RC], SHEX, 2) + 'H';
    edtD.Text     := IntToNumStr(DataRegisters[RD], SHEX, 2) + 'H';
    edtE.Text     := IntToNumStr(DataRegisters[RE], SHEX, 2) + 'H';
    edtH.Text     := IntToNumStr(DataRegisters[RH], SHEX, 2) + 'H';
    edtL.Text     := IntToNumStr(DataRegisters[RL], SHEX, 2) + 'H';
    edtSP.Text    := IntToNumStr(SP, SHEX, 4) + 'H';
    edtPC.Text    := IntToNumStr(PC, SHEX, 4) + 'H';
    edtIR.Text    := IntToNumStr(IR, SHEX, 2) + 'H';
    edtFS.Text    := IntToStr((DataRegisters[RF] shr 7) and 1);
    edtFZ.Text    := IntToStr((DataRegisters[RF] shr 6) and 1);
    edtFP.Text    := IntToStr((DataRegisters[RF] shr 2) and 1);
    edtFAC.Text   := IntToStr((DataRegisters[RF] shr 4) and 1);
    edtFCY.Text   := IntToStr((DataRegisters[RF] shr 0) and 1);
  end;
end;

procedure TVisualizer.OnlyUpdateMem(Cells: TMemoryCells);
begin
  with frmMemory do
  begin
    MemoryCells := Cells;
    grdMemory.Repaint;
  end;
end;

procedure TVisualizer.AddLog(Value: String);
begin
  if VisLevel > 0 then
  begin
    frmScheme.redtLog.Lines.Add(Value);
  end;
end;

procedure TVisualizer.CleanLog;
begin
  frmScheme.redtLog.Lines.Clear;
end;

procedure TVisualizer.CleanSelection;
var
  Cnt: Integer;
begin
  with frmScheme do
  begin
    for Cnt := 0 to ComponentCount - 1 do
      if Components[Cnt] is TEdit then
        TEdit(Components[Cnt]).Color := clWindow
      else if Components[Cnt] is TImage then
        if TImage(Components[Cnt]) <> imgSchemeBackground then
          TImage(Components[Cnt]).Hide;
  end;
end;

procedure TVisualizer.ShowAddrBuf(Addr: Word);
begin
  if VisLevel > 0 then
    frmScheme.edtBuf.Text := IntToNumStr(Addr, SHEX, 4) + 'H';
  if VisLevel > 1 then
  begin
    frmScheme.edtBuf.Color := HL_COLOR;
    frmScheme.imgData.Show;
  end;
end;

procedure TVisualizer.ShowALU;
begin
  if VisLevel > 1 then
    frmScheme.imgALU.Show;
end;

procedure TVisualizer.ShowMemoryCell(Addr: Word);
begin
  if VisLevel > 1 then
    frmMemory.SelectedCells[Addr] := True;
end;

procedure TVisualizer.ShowDataReg;
var
  CurrentEdit: TEdit;
begin
  if VisLevel > 1 then
    with frmScheme do
    begin
      case DataReg of
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
      CurrentEdit.Color := HL_COLOR;
      if DataReg = RA then
        imgAcc.Show
      else
        imgReg.Show;
    end;
end;

procedure TVisualizer.ShowDecoder;
begin
  if VisLevel > 1 then
    frmScheme.imgCD.Show;
end;

procedure TVisualizer.ShowFlag(Flag: TFlag);
var
  CurrentEdit: TEdit;
begin
  if VisLevel > 1 then
    with frmScheme do
    begin
      case Flag of
        FS:   CurrentEdit := edtFS;
        FZ:   CurrentEdit := edtFZ;
        FP:   CurrentEdit := edtFP;
        FAC:  CurrentEdit := edtFAC;
        FCY:  CurrentEdit := edtFCY;
      end;
      CurrentEdit.Color := HL_COLOR;
      imgFlags.Show;
    end;
end;

procedure TVisualizer.ShowRegPair(RegPair: TRegPair);
begin
  if VisLevel > 1 then
    with frmScheme do
      case RegPair of
        RPBC: begin
                ShowDataReg(RB);
                ShowDataReg(RC);
              end;
        RPDE: begin
                ShowDataReg(RD);
                ShowDataReg(RE);
              end;
        RPHL: begin
                ShowDataReg(RH);
                ShowDataReg(RL);
              end;
      end;
end;

procedure TVisualizer.ShowStackPointer;
begin
  if VisLevel > 1 then
    with frmScheme do
    begin
      edtSP.Color := HL_COLOR;
      imgReg.Show;
    end;
end;

procedure TVisualizer.ShowProgramCounter;
begin
  if VisLevel > 1 then
    with frmScheme do
    begin
      edtPC.Color := HL_COLOR;
      imgReg.Show;
    end;
end;

procedure TVisualizer.ShowInstrRegister;
begin
  if VisLevel > 1 then
    with frmScheme do
    begin
      edtIR.Color := HL_COLOR;
      imgIR.Show;
    end;
end;

end.
