unit Logic;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//�������� ����������� ������ �������� ���������������

interface

uses
  Common, Instructions, Visualizer, Typelib,
  Classes, SyncObjs, SysUtils, Dialogs, TypInfo, Math,
  Winapi.Windows, Winapi.Messages, Vcl.Forms;

type
  TMemory = class
  private
    Vis: TVisualizer;
  public
    Cells: TMemoryCells;                                                        //������ ������
    constructor Create(Vis: TVisualizer);
    procedure Write(Address: Word; Value: Int8);                          //�������� � ������ �������� ��������
    function Read(Address: Word): Int8;                                   //������� �� ������ �������� ��������
  end;

  TProcessor = class(TThread)
  private
    HltState: Boolean;
    Memory: TMemory;                        //������
    Vis: TVisualizer;
    Registers: TRegisters;                  //��������
    procedure InitDataRegisters;            //������������� ���������
    procedure InitFlags;                    //������������� �������� ������

    procedure StepWait;
    procedure StepDone;

    procedure ExecuteCommand(Instr: TInstruction; B1, B2, B3: Byte);
    procedure ExecuteSystemCommand(Instr: TInstruction; B1, B2, B3: Byte);
    procedure ExecuteDataCommand(Instr: TInstruction; B1, B2, B3: Byte);
    procedure ExecuteArithmCommand(Instr: TInstruction; B1, B2, B3: Byte);
    procedure ExecuteLogicCommand(Instr: TInstruction; B1, B2, B3: Byte);
    procedure ExecuteBranchCommand(Instr: TInstruction; B1, B2, B3: Byte);
  public
    StopCmd, StopStep: TEvent;              //������� ������������� �������
    SkipToNext: Boolean;                    //���� �������� ������������ ����� �� ��������� �������

    constructor Create(Vis: TVisualizer; Memory: TMemory; EntryPoint: Word);
    procedure Execute; override;

    procedure PerformALU(OpCode: TOpCode; Size: Byte; Op1, Op2: String;
      var Op3: String; var Flags: TFlagArray);                                  //��������� �������� �������� ����������-������
    procedure PerformALUOnReg
      (OpCode: TOpCode; Reg: TDataReg; Value: Int8; UseCarry: Boolean = False;
      AffectedFlags: TFlagSet = [FS, FZ, FAC, FP, FCY]);                        //��������� �������� �� ��� ��� ���������
    procedure PerformRotate(Right, ThroughCarry: Boolean);                      //��������� ����� ������������

    function GetMemory(Address: Word): Int8;                                    //������� �� ������ �������� ��������
    procedure SetMemory(Address: Word; Value: Int8);                            //�������� � ������ �������� ��������

    function GetDataReg(DataReg: TDataReg): Int8;                               //�������� �������� ��������
    function GetRegAddrValue(DataReg: TDataReg): Int8;                          //���������� �������� �� ����������� ���������
    function GetRegPair(RegPair: TRegPair): Word;                               //�������� �������� ����������� ����
    procedure SetDataReg(DataReg: TDataReg; Value: Int8);                       //���������� �������� ��������
    procedure SetRegAddrValue(DataReg: TDataReg; Value: Int8);                  //�������� �������� �� ����������� ���������
    procedure SetRegPair(RegPair: TRegPair; Value: Word);                       //���������� �������� ����������� ����

    function GetStackPointer: Word;                                             //�������� �������� ��������� �����
    function GetProgramCounter: Word;                                           //�������� �������� �������� ������
    function GetInstRegister: Byte;                                             //�������� �������� �������� ������
    procedure SetStackPointer(Value: Word);                                     //���������� �������� ��������� �����
    procedure SetProgramCounter(Value: Word);                                   //���������� �������� �������� ������
    procedure SetInstRegister(Value: Byte);                                     //���������� �������� �������� ������

    function GetFlag(FlagName: TFlag): Byte;                                    //�������� ��������� �����
    procedure SetFlag(FlagName: TFlag; Value: Byte);                            //���������� ����
    function CheckCondition(Condition: TCondition): Boolean;                    //��������� �������

    procedure NotOperation;                                                     //������� �����
    procedure HaltProcessor;                                                    //������ ������ ��������
  end;

implementation

{ TMemory }

constructor TMemory.Create(Vis: TVisualizer);
begin
  Self.Vis := Vis;
end;

function TMemory.Read;
begin
  Result := Cells[Address];
end;

procedure TMemory.Write;
begin
  Cells[Address] := Value;
end;

{ TProcessor }

constructor TProcessor.Create;
begin
  inherited Create(True);
  Self.Memory := Memory;
  Self.Vis := Vis;
  InitDataRegisters;                //�������������� �������� ������
  Registers.PC := EntryPoint;       //�������������� ������� ������ �� ��������� ����� �����
  HltState := False;
end;

procedure TProcessor.StepWait;
begin
  if Assigned(StopStep) then
    StopStep.WaitFor(INFINITE);
  Vis.CleanSelection;
  Vis.CleanSelectionMem;
end;

procedure TProcessor.StepDone;
begin
  if Assigned(StopStep) then
    StopStep.ResetEvent;
end;

procedure TProcessor.NotOperation;
begin
  StepWait;
  Vis.AddLog('������� �����');
  StepDone;
end;

procedure TProcessor.HaltProcessor;
begin
  StepWait;
  HltState := True;
  Vis.AddLog('������� ������ ��������');
  StepDone;
end;

procedure TProcessor.InitDataRegisters;
var
  CurReg: TDataReg;
begin
  for CurReg := Low(TDataReg) to High(TDataReg) do
    Registers.DataRegisters[CurReg] := 0;
end;

procedure TProcessor.PerformALU;
var
  Digit: Byte;
  NewBit: Byte;
  Carry, Parity: Byte;
begin
  Op3 := '';
  Carry := Flags[FCY];
  Parity := 0;
  for Digit := Size downto 1 do
  begin
    case OpCode of
      OCSumm: begin
                //������� �����
                NewBit := StrToInt(Op1[Digit]) + (StrToInt(Op2[Digit]) + Carry);
                //������� ������� � ������������� ���
                Carry := IfThen(NewBit > 1, 1, 0);
                NewBit := NewBit mod 2;
                //���������� ���� ���������������� �������� �� 3 � 4 ������
                if Digit = 5 then
                  Flags[FAC] := Carry;
              end;
      OCAnd: NewBit := StrToInt(Op1[Digit]) and StrToInt(Op2[Digit]);
      OCLor: NewBit := StrToInt(Op1[Digit]) or  StrToInt(Op2[Digit]);
      OCXor: NewBit := StrToInt(Op1[Digit]) xor StrToInt(Op2[Digit]);
    end;
    //������� ���������� ������
    Parity := Parity + NewBit;
    //�������� ���������
    Op3 := IntToStr(NewBit) + Op3;
  end;
  //���������� �����
  Flags[FS]   := NewBit;
  Flags[FZ]   := IfThen(Parity = 0, 1, 0);
  Flags[FP]   := IfThen(Parity mod 2 = 0, 1, 0);
  Flags[FAC]  := IfThen(OpCode = OCSumm, Flags[FAC], 0);
  Flags[FCY]  := IfThen(OpCode = OCSumm, Carry, 0);
end;

procedure TProcessor.PerformALUOnReg;
var
  Op1, Op2, Op3: String;
  Flags: TFlagArray;
begin
  Vis.ShowALU;
  Vis.AddLog('���������� �������� �� ���');
  //�������������� ����������
  Op1 := IntToNumStr(GetRegAddrValue(Reg), SBIN, 8);
  Op2 := IntToNumStr(Value, SBIN, 8);
  Flags[FCY] := IfThen(UseCarry, GetFlag(FCY), 0);
  //��������� �������� �� ���������
  PerformALU(OpCode, 8, Op1, Op2, Op3, Flags);
  //���������� �����
  if FS   in AffectedFlags then SetFlag(FS,   Flags[FS]);
  if FZ   in AffectedFlags then SetFlag(FZ,   Flags[FZ]);
  if FP   in AffectedFlags then SetFlag(FP,   Flags[FP]);
  if FAC  in AffectedFlags then SetFlag(FAC,  Flags[FAC]);
  if FCY  in AffectedFlags then SetFlag(FCY,  Flags[FCY]);
  //��������� �����������
  SetRegAddrValue(Reg, NumStrToInt(Op3, SBIN));
end;

procedure TProcessor.PerformRotate;
var
  TempStr: String;
begin
  Vis.ShowALU;
  TempStr := IntToNumStr(GetDataReg(RA), SBIN, 8);
  if Right then
  begin
    if ThroughCarry then
      TempStr := IntToStr(GetFlag(FCY)) + TempStr
    else
      TempStr := TempStr[8] + TempStr;
    SetFlag(FCY, StrToInt(TempStr[9]));
    Delete(TempStr, 9, 1);
  end
  else
  begin
    if ThroughCarry then
      TempStr := TempStr + IntToStr(GetFlag(FCY))
    else
      TempStr := TempStr + TempStr[8];
    SetFlag(FCY, StrToInt(TempStr[1]));
    Delete(TempStr, 1, 1);
  end;
  SetDataReg(RA, NumStrToInt(TempStr, SBIN));
end;

function TProcessor.GetMemory(Address: Word): Int8;
begin
  StepWait;
  Result := Memory.Read(Address);
  Vis.ShowAddrBuf(Address);
  Vis.ShowMemoryCell(Address);
  Vis.AddLog(Format('������ ������; �����: %sH; ��������: %sH;', [IntToNumStr(Address, SHEX, 4), IntToNumStr(Result, SHEX, 2)]));
  StepDone;
end;

procedure TProcessor.SetMemory(Address: Word; Value: Int8);
begin
  StepWait;
  Memory.Write(Address, Value);
  Vis.ShowAddrBuf(Address);
  Vis.ShowMemoryCell(Address);
  Vis.AddLog(Format('������ � ������; �����: %sH; ��������: %sH;', [IntToNumStr(Address, SHEX, 4), IntToNumStr(Value, SHEX, 2)]));
  StepDone;
end;

function TProcessor.GetDataReg;
begin
  StepWait;
  Result := Registers.DataRegisters[DataReg];
  Vis.ShowDataReg(DataReg);
  Vis.AddLog(Format('������ ��������; �������: %s; ��������: %sH;',
    [Copy(GetEnumName(TypeInfo(TDataReg), Ord(DataReg)), 2, 1), IntToNumStr(Result, SHEX, 2)]));
  StepDone;
end;

function TProcessor.GetRegAddrValue;
begin
  if DataReg = RM then
    Result := GetMemory(GetRegPair(RPHL))
  else
    Result := GetDataReg(DataReg);
end;

function TProcessor.GetRegPair;
begin
  StepWait;
  if RegPair = RPSP then
    Result := GetStackPointer
  else
  begin
    case RegPair of
      RPBC: Result := MakeWordHL(Registers.DataRegisters[RB], Registers.DataRegisters[RC]);
      RPDE: Result := MakeWordHL(Registers.DataRegisters[RD], Registers.DataRegisters[RE]);
      RPHL: Result := MakeWordHL(Registers.DataRegisters[RH], Registers.DataRegisters[RL]);
    end;
    Vis.ShowRegPair(RegPair);
    Vis.AddLog(Format('������ ����������� ����; ��������: %s; ��������: %sH;',
      [Copy(GetEnumName(TypeInfo(TRegPair), Ord(RegPair)), 3, 2), IntToNumStr(Result, SHEX, 2)]));
  end;
  StepDone;
end;

procedure TProcessor.SetDataReg;
begin
  StepWait;
  Registers.DataRegisters[DataReg] := Value;
  Vis.OnlyUpdate(Registers);
  Vis.ShowDataReg(DataReg);
  Vis.AddLog(Format('������ � �������; �������: %s; ��������: %sH;',
    [Copy(GetEnumName(TypeInfo(TDataReg), Ord(DataReg)), 2, 1), IntToNumStr(Value, SHEX, 2)]));
  StepDone;
end;

procedure TProcessor.SetRegAddrValue;
begin
  if DataReg = RM then
    SetMemory(GetRegPair(RPHL), Value)
  else
    SetDataReg(DataReg, Value);
end;

procedure TProcessor.SetRegPair;
var
  HiReg, LoReg: TDataReg;
begin
  StepWait;
  if RegPair = RPSP then
    SetStackPointer(Value)
  else
  begin
    case RegPair of
      RPBC: begin HiReg := RB; LoReg := RC; end;
      RPDE: begin HiReg := RD; LoReg := RE; end;
      RPHL: begin HiReg := RH; LoReg := RL; end;
    end;
    Registers.DataRegisters[HiReg] := Hi(Value);
    Registers.DataRegisters[LoReg] := Lo(Value);
    Vis.OnlyUpdate(Registers);
    Vis.ShowRegPair(RegPair);
    Vis.AddLog(Format('������ � ����������� ����; ��������: %s; ��������: %sH;',
      [Copy(GetEnumName(TypeInfo(TRegPair), Ord(RegPair)), 3, 2), IntToNumStr(Value, SHEX, 2)]));
  end;
  StepDone;
end;

function TProcessor.GetStackPointer;
begin
  StepWait;
  Result := Registers.SP;
  Vis.ShowStackPointer;
  Vis.AddLog(Format('������ ��������� �����; ��������: %sH;', [IntToNumStr(Result, SHEX, 4)]));
  StepDone;
end;

function TProcessor.GetProgramCounter;
begin
  StepWait;
  Result := Registers.PC;
  Vis.ShowProgramCounter;
  Vis.AddLog(Format('������ �������� ������; ��������: %sH;', [IntToNumStr(Result, SHEX, 4)]));
  StepDone;
end;

function TProcessor.GetInstRegister;
begin
  Result := Registers.IR;
end;

procedure TProcessor.SetStackPointer;
begin
  StepWait;
  Registers.SP := Value;
  Vis.OnlyUpdate(Registers);
  Vis.ShowStackPointer;
  Vis.AddLog(Format('��������� ��������� �����; ��������: %sH;', [IntToNumStr(Value, SHEX, 4)]));
  StepDone;
end;

procedure TProcessor.SetProgramCounter;
begin
  StepWait;
  Registers.PC := Value;
  Vis.OnlyUpdate(Registers);
  Vis.ShowProgramCounter;
  Vis.AddLog(Format('��������� �������� ������; ��������: %sH;', [IntToNumStr(Value, SHEX, 4)]));
  StepDone;
end;

procedure TProcessor.SetInstRegister;
begin
  StepWait;
  Registers.IR := Value;
  Vis.OnlyUpdate(Registers);
  Vis.ShowInstrRegister;
  Vis.AddLog(Format('��������� �������� ������; ��������: %sH;', [IntToNumStr(Value, SHEX, 2)]));
  StepDone;
end;

procedure TProcessor.InitFlags;
begin
  Registers.DataRegisters[RF] := 2; //00000010
end;

function TProcessor.GetFlag;
var
  Shift: Byte;
begin
  StepWait;
  //���������� ���
  case FlagName of
    FS:  Shift := 7;
    FZ:  Shift := 6;
    FP:  Shift := 2;
    FAC: Shift := 4;
    FCY: Shift := 0;
  end;
  //��������� ���
  with Registers do
    Result := (DataRegisters[RF] shr Shift) and 1;
  Vis.OnlyUpdate(Registers);
  Vis.ShowFlag(FlagName);
  Vis.AddLog(Format('�������� �����; ����: %s; ���������: %s;',
    [Copy(GetEnumName(TypeInfo(TFlag), Ord(FlagName)), 3, 2), IntToStr(Result)]));
  StepDone;
end;

procedure TProcessor.SetFlag;
var
  Shift: Byte;
begin
  StepWait;
  //���������� ���
  case FlagName of
    FS:  Shift := 7;
    FZ:  Shift := 6;
    FP:  Shift := 2;
    FAC: Shift := 4;
    FCY: Shift := 0;
  end;
  //������ ���
  with Registers do
    if Value = 1 then
      DataRegisters[RF] := DataRegisters[RF] or (1 shl Shift)
    else
      DataRegisters[RF] := DataRegisters[RF] and not (1 shl Shift);
  Vis.OnlyUpdate(Registers);
  Vis.ShowFlag(FlagName);
  Vis.AddLog(Format('��������� �����; ����: %s; ���������: %s;',
    [Copy(GetEnumName(TypeInfo(TFlag), Ord(FlagName)), 2, 2), IntToStr(Value)]));
  StepDone;
end;

function TProcessor.CheckCondition(Condition: TCondition): Boolean;
begin
  case Condition of
    FCNZ: Result := GetFlag(FZ)   = 0;
    FCZ:  Result := GetFlag(FZ)   = 1;
    FCNC: Result := GetFlag(FCY)  = 0;
    FCC:  Result := GetFlag(FCY)  = 1;
    FCPO: Result := GetFlag(FP)   = 0;
    FCPE: Result := GetFlag(FP)   = 1;
    FCP:  Result := GetFlag(FS)   = 0;
    FCM:  Result := GetFlag(FS)   = 1;
  end;
end;

procedure TProcessor.Execute;
var
  CurrentAddr: Word;
  CurrentInstr: TInstruction;
  B1, B2, B3: Byte;
begin
  inherited;
  FreeOnTerminate := True;
  //with Processor do
  begin
    Vis.CleanLog;
    Vis.OnlyUpdate(Registers);
    //���� �� �������� HLT ��� ������� �� ����������� ������ - ������ �������
    repeat
      Vis.CleanSelection;
      Vis.CleanSelectionMem;

      Vis.AddLog('������� �������:');

      //���� ���� ������ ������������� ������ - ��� ���
      if Assigned(StopCmd) then
        StopCmd.WaitFor(INFINITE);

      //������ ������ ���� ����������
      CurrentAddr := GetProgramCounter;
      B1 := GetMemory(CurrentAddr);

      //���� ���������� � �������
      CurrentInstr := InstrSet.FindByCode(B1);
      if not Assigned(CurrentInstr) then
        CurrentInstr := InstrSet.FindByCode(B1, True);

      //���������� �������
      if Assigned(CurrentInstr) then
      begin
        //������������� ������� ������
        SetInstRegister(B1);

        Vis.AddLog(CurrentInstr.Summary);

        //������ ������ � ������ ���� ���������� (���� ����)
        if CurrentInstr.Size > 1 then
        begin
          B2 := GetMemory(CurrentAddr + 1);
          SetDataReg(RW, B2);
          if CurrentInstr.Size > 2 then
          begin
            B3 := GetMemory(CurrentAddr + 2);
            SetDataReg(RZ, B3);
          end
        end;

        //������������� ������� ������
        SetProgramCounter(CurrentAddr + CurrentInstr.Size);

        //��������� ����� ������
        //ShowRegisters;
        Vis.OnlyUpdate(Registers);
        //Memory.ShowNewMem;
        Vis.OnlyUpdateMem(Memory.Cells);

        //���������� ������ ������������� ������
        if Assigned(StopCmd) then
          StopCmd.ResetEvent;

        //��������� �������
        ExecuteCommand(CurrentInstr, B1, B2, B3);
        Vis.AddLog(LOG_LINE);
      end;
    until HltState or Terminated;

    //���������� ������ �������������
    if Assigned(StopCmd) then
      FreeAndNil(StopCmd);

    //TODO: ������� � ��������� �����
    SendMessage(Application.MainForm.Handle, WM_CONTROLS, 1, 0);
  end;
end;

procedure TProcessor.ExecuteCommand;
begin
  //����� ���� �������
  StepWait;
  Vis.ShowInstrRegister;
  Vis.ShowDecoder;
  Vis.AddLog('���������� �������:');
  StepDone;
  //StepDone;
  case Instr.Group of
    IGSystem:   ExecuteSystemCommand(Instr, B1, B2, B3);
    IGData:     ExecuteDataCommand(Instr, B1, B2, B3);
    IGArithm:   ExecuteArithmCommand(Instr, B1, B2, B3);
    IGLogic:    ExecuteLogicCommand(Instr, B1, B2, B3);
    IGBranch:   ExecuteBranchCommand(Instr, B1, B2, B3);
  end;
  StepWait;
end;

procedure TProcessor.ExecuteSystemCommand;
begin
  with Instr do
  case Code of
    $00: {NOP}  begin
                  NotOperation;
                end;
    $76: {HLT}  begin
                  HaltProcessor;
                end;
  end;
end;

procedure TProcessor.ExecuteDataCommand;
var
  CurrentSP: Word;
  CurrentPC: Word;
  Temp8: Int8;
  Temp16: Word;
begin
  with Instr do
  case Code of
    //���������
    $40: {MOV}  begin
                  SetRegAddrValue(ExReg(B1), GetRegAddrValue(ExReg(B1, True)));
                end;
    $06: {MVI}  begin
                  SetRegAddrValue(ExReg(B1), B2);
                end;
    $01: {LXI}  begin
                  SetRegPair(ExPair(B1), MakeWordHL(B3, B2));
                end;
    $3A: {LDA}  begin
                  SetDataReg(RA, GetMemory(MakeWordHL(B3, B2)));
                end;
    $32: {STA}  begin
                  SetMemory(MakeWordHL(B3, B2), GetDataReg(RA));
                end;
    $0A: {LDAX} begin
                  SetDataReg(RA, GetMemory(GetRegPair(RPHL)));
                end;
    $02: {STAX} begin
                  SetMemory(GetRegPair(RPHL), GetDataReg(RA));
                end;
    //������
    $2A: {LHLD} begin
                  SetDataReg(RL, GetMemory(MakeWordHL(B3, B2)));
                  SetDataReg(RH, GetMemory(MakeWordHL(B3, B2) + 1));
                end;
    $22: {SHLD} begin
                  SetMemory(MakeWordHL(B3, B2), GetDataReg(RL));
                  SetMemory(MakeWordHL(B3, B2) + 1, GetDataReg(RH));
                end;
    $EB: {XCHG} begin
                  Temp16 := GetRegPair(RPHL);
                  SetRegPair(RPHL, GetRegPair(RPDE));
                  SetRegPair(RPDE, Temp16);
                end;
    //����������� ������
    $E9: {PCHL} begin
                  SetProgramCounter(GetRegPair(RPHL));
                end;
    $F9: {SPHL} begin
                  SetStackPointer(GetRegPair(RPHL));
                end;
    $E3: {XTHL} begin
                  CurrentSP := GetStackPointer;
                  Temp8 := GetDataReg(RL);
                  SetDataReg(RL, GetMemory(CurrentSP));
                  SetMemory(CurrentSP, Temp8);
                  Temp8 := GetDataReg(RH);
                  SetDataReg(RH, GetMemory(CurrentSP + 1));
                  SetMemory(CurrentSP + 1, Temp8);
                end;
    //������� ������ �� ������
    $C1: {POP}  begin
                  CurrentSP := GetStackPointer;
                  if ExPair(B1) = RPSP then   //POP PSW
                  begin
                    SetDataReg(RF, GetMemory(CurrentSP));
                    SetDataReg(RA, GetMemory(CurrentSP + 1));
                  end
                  else                        //POP RP
                  begin
                    SetRegPair(ExPair(B1), MakeWordHL(GetMemory(CurrentSP + 1), GetMemory(CurrentSP)));
                  end;
                  SetStackPointer(CurrentSP + 2);
                end;
    $C5: {PUSH} begin
                  CurrentSP := GetStackPointer;
                  if ExPair(B1) = RPSP then   //PUSH PSW
                  begin
                    SetMemory(CurrentSP - 1, GetDataReg(RA));
                    SetMemory(CurrentSP - 2, GetDataReg(RF));
                  end
                  else                        //PUSH RP
                  begin
                    SetMemory(CurrentSP - 1, Hi(GetRegPair(ExPair(B1))));
                    SetMemory(CurrentSP - 2, Lo(GetRegPair(ExPair(B1))));
                  end;
                  SetStackPointer(CurrentSP - 2);
                end;
  end;
end;

procedure TProcessor.ExecuteArithmCommand;
begin
  with Instr do
  case Code of
    //��������
    $80: {ADD}  begin
                  PerformALUOnReg(OCSumm, RA, GetRegAddrValue(ExReg(B1)));
                end;
    $88: {ADC}  begin
                  PerformALUOnReg(OCSumm, RA, GetRegAddrValue(ExReg(B1)), True);
                end;
    $C6: {ADI}  begin
                  PerformALUOnReg(OCSumm, RA, B2);
                end;
    $CE: {ACI}  begin
                  PerformALUOnReg(OCSumm, RA, B2, True);
                end;
    //���������
    $90: {SUB}  begin
                  PerformALUOnReg(OCSumm, RA, -GetRegAddrValue(ExReg(B1)));
                end;
    $98: {SBB}  begin
                  PerformALUOnReg(OCSumm, RA, -GetRegAddrValue(ExReg(B1)), True);
                end;
    $D6: {SUI}  begin
                  PerformALUOnReg(OCSumm, RA, -B2);
                end;
    $DE: {SBI}  begin
                  PerformALUOnReg(OCSumm, RA, -B2, True);
                end;
    //���������/���������
    $04: {INR}  begin
                  PerformALUOnReg(OCSumm, ExReg(B1), 1, False, [FZ, FS, FP, FAC]);
                end;
    $05: {DCR}  begin
                  PerformALUOnReg(OCSumm, ExReg(B1), -1, False, [FZ, FS, FP, FAC]);
                end;
  end;
end;

procedure TProcessor.ExecuteLogicCommand;
begin
  with Instr do
  case Code of
    //�������� ������
    $A0: {ANA}  begin
                  PerformALUOnReg(OCAnd, RA, GetRegAddrValue(ExReg(B1)));
                end;
    $B0: {ORA}  begin
                  PerformALUOnReg(OCLor, RA, GetRegAddrValue(ExReg(B1)));
                end;
    $A8: {XRA}  begin
                  PerformALUOnReg(OCXor, RA, GetRegAddrValue(ExReg(B1)));
                end;
    $E6: {ANI}  begin
                  PerformALUOnReg(OCAnd, RA, B2);
                end;
    $F6: {ORI}  begin
                  PerformALUOnReg(OCLor, RA, B2);
                end;
    $EE: {XRI}  begin
                  PerformALUOnReg(OCXor, RA, B2);
                end;
    //�����
    $07: {RLC}  begin
                  PerformRotate(False, False);
                end;
    $0F: {RRC}  begin
                  PerformRotate(True, False);
                end;
    $17: {RAL}  begin
                  PerformRotate(False, True);
                end;
    $1F: {RAR}  begin
                  PerformRotate(True, True);
                end;
    //����������� ��������
    $2F: {CMA}  begin
                  SetDataReg(RA, NumStrToInt(InvertBits(IntToNumStr(GetDataReg(RA), SBIN, 8)), SBIN));
                end;
    $3F: {CMC}  begin
                  SetFlag(FCY, IfThen(GetFlag(FCY) = 1, 0, 1));
                end;
    $37: {STC}  begin
                  SetFlag(FCY, 1);
                end;
  end;
end;

procedure TProcessor.ExecuteBranchCommand;
var
  CurrentSP: Word;
  CurrentPC: Word;
  ConditionChecked: Boolean;
begin
  with Instr do
    if (Format <> IFCondition) or CheckCondition(ExCond(B1)) then
    case Code of
      $C3, $C2: {JMP} begin
                        SetProgramCounter(MakeWordHL(B3, B2));
                      end;
      $CD, $C4: {CALL} begin
                        CurrentSP := GetStackPointer;
                        CurrentPC := GetProgramCounter;
                        SetMemory(CurrentSP - 1, GetDataReg(RA));
                        SetMemory(CurrentSP - 2, GetDataReg(RF));
                        SetStackPointer(CurrentSP - 2);
                        SetProgramCounter(MakeWordHL(B3, B2));
                      end;
      $C9, $C0: {RET} begin
                        CurrentSP := GetStackPointer;
                        SetProgramCounter(MakeWordHL(GetMemory(CurrentSP + 1), GetMemory(CurrentSP)));
                        SetStackPointer(CurrentSP + 2);
                      end;
    end;
end;

end.
