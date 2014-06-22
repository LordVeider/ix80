unit Visualizer;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//Модуль визуализации

interface

uses
  FormScheme, FormMemory, Instructions, Common, Typelib,
  Classes, StdCtrls, ExtCtrls, Graphics, SysUtils;

type
  TVisualizer = class
  private
    VisLevel: Byte;                               //уровень визуализации (0 - ничего, 1 - логи, 2 - хайлайты)
  public
    procedure SetVisLevel(VisLevel: Byte);

    procedure ClearLog;
    procedure AddLog(Value: String);

    procedure UnhighlightScheme;
    procedure UnhighlightMemory;

    procedure UpdateScheme(Regs: TRegisters);
    procedure UpdateMemory(Cells: TMemoryCells);

    procedure HighlightALU;
    procedure UnhighlightALU;

    procedure HighlightDataReg(DataReg: TDataReg);
    procedure HighlightRegPair(RegPair: TRegPair);
    procedure HighlightFlag(Flag: TFlag);
    procedure HighlightStackPointer;
    procedure HighlightProgramCounter;
    procedure HighlightInstrRegister;

    procedure HighlightDecoder;

    procedure HighlightDataBus(Addr: Word);
    procedure HighlightMemoryCell(Addr: Word);
  end;

implementation

{ TVisualizer }

procedure TVisualizer.SetVisLevel;
begin
  Self.VisLevel := VisLevel;
end;

procedure TVisualizer.ClearLog;
begin
  frmScheme.redtLog.Lines.Clear;
end;

procedure TVisualizer.AddLog(Value: String);
begin
  if VisLevel > 0 then
  begin
    frmScheme.redtLog.Lines.Add(Value);
  end;
end;

procedure TVisualizer.UnhighlightScheme;
var
  Cnt: Integer;
begin
  with frmScheme do
  begin
    for Cnt := 0 to ComponentCount - 1 do
      if Components[Cnt] is TEdit then
        TEdit(Components[Cnt]).Color := clWindow
      else if Components[Cnt] is TImage then
        if (TImage(Components[Cnt]) <> imgSchemeBackground) then
          if (TImage(Components[Cnt]) <> imgALU) then
            TImage(Components[Cnt]).Hide
          else if imgALU.Tag = 0 then
            imgALU.Hide;
  end;
end;

procedure TVisualizer.UnhighlightMemory;
var
  Addr: Word;
begin
  with frmMemory do
  begin
    for Addr := 0 to 65535 do
      SelectedCells[Addr] := False;
    grdMemory.Repaint;
  end;
end;

procedure TVisualizer.UpdateScheme(Regs: TRegisters);
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

procedure TVisualizer.UpdateMemory(Cells: TMemoryCells);
begin
  with frmMemory do
  begin
    MemoryCells := Cells;
    grdMemory.Repaint;
  end;
end;

procedure TVisualizer.HighlightALU;
begin
  if VisLevel > 1 then
    with frmScheme do
    begin
      imgALU.Show;
      imgALU.Tag := 100;
    end;
end;

procedure TVisualizer.UnhighlightALU;
begin
  with frmScheme do
    imgALU.Tag := 0;
end;

procedure TVisualizer.HighlightDataReg;
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
      CurrentEdit.Color := COLOR_HL;
      if DataReg = RA then
        imgAcc.Show
      else
        imgReg.Show;
    end;
end;

procedure TVisualizer.HighlightRegPair(RegPair: TRegPair);
begin
  if VisLevel > 1 then
    with frmScheme do
      case RegPair of
        RPBC: begin
                HighlightDataReg(RB);
                HighlightDataReg(RC);
              end;
        RPDE: begin
                HighlightDataReg(RD);
                HighlightDataReg(RE);
              end;
        RPHL: begin
                HighlightDataReg(RH);
                HighlightDataReg(RL);
              end;
      end;
end;

procedure TVisualizer.HighlightFlag(Flag: TFlag);
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
      CurrentEdit.Color := COLOR_HL;
      imgFlags.Show;
    end;
end;

procedure TVisualizer.HighlightStackPointer;
begin
  if VisLevel > 1 then
    with frmScheme do
    begin
      edtSP.Color := COLOR_HL;
      imgReg.Show;
    end;
end;

procedure TVisualizer.HighlightProgramCounter;
begin
  if VisLevel > 1 then
    with frmScheme do
    begin
      edtPC.Color := COLOR_HL;
      imgReg.Show;
    end;
end;

procedure TVisualizer.HighlightInstrRegister;
begin
  if VisLevel > 1 then
    with frmScheme do
    begin
      edtIR.Color := COLOR_HL;
      imgIR.Show;
    end;
end;

procedure TVisualizer.HighlightDecoder;
begin
  if VisLevel > 1 then
    frmScheme.imgCD.Show;
end;

procedure TVisualizer.HighlightDataBus(Addr: Word);
begin
  if VisLevel > 0 then
    frmScheme.edtBuf.Text := IntToNumStr(Addr, SHEX, 4) + 'H';
  if VisLevel > 1 then
  begin
    frmScheme.edtBuf.Color := COLOR_HL;
    frmScheme.imgData.Show;
  end;
end;

procedure TVisualizer.HighlightMemoryCell(Addr: Word);
begin
  if VisLevel > 1 then
    with frmMemory do
    begin
      SelectedCells[Addr] := True;
      grdMemory.Repaint;
    end;
end;

end.
