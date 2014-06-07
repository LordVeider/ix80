unit Logic;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//�������� ����������� ������ �������� ���������������

interface

uses
  Common, Instructions,
  Classes, SyncObjs, SysUtils, Dialogs, TypInfo;

type
  TMemory = class
  private
    Cells: array [Word] of Int8;                    //������ ������
  public
    procedure ShowNewMem;                                                       //���������� ���������� ������ �� ������
    procedure WriteMemory(Address: Word; Value: Int8);                          //�������� � ������ �������� ��������
    function ReadMemory(Address: Word): Int8;                                   //������� �� ������ �������� ��������
  end;

  TDataRegisters = array [TDataReg] of Int8;
  TRegisters = record
    DataRegisters: TDataRegisters;          //�������� ������ (8 bit)
    SP: Word;                               //��������� ����� (16 bit)
    PC: Word;                               //������� ������  (16 bit)
    AB: Word;                               //����� ������    (16 bit)
    IR: Byte;                               //������� ������  (8 bit)
  end;

  TProcessor = class(TThread)
  private
    HltState: Boolean;
    Memory: TMemory;                        //������
    Registers: TRegisters;                  //��������
    procedure InitDataRegisters;            //������������� ���������
    procedure InitFlags;                    //������������� �������� ������
  public
    StopSection: TEvent;

    constructor Create(Memory: TMemory);
    procedure Execute; override;

    procedure InitCpu(EntryPoint: Word);                                        //������������� ����������
    procedure ShowRegisters;                                                    //���������� ���������� ��������� �� ������
    procedure PerformALU(Value: Int8);                                          //��������� �������� �� ���

    function GetDataReg(DataReg: TDataReg): Int8;                       //�������� �������� ��������
    function GetRegAddrValue(DataReg: TDataReg): Int8;                            //���������� �������� �� ����������� ���������
    function GetRegPair(RegPair: TRegPair): Word;                         //�������� �������� ����������� ����
    procedure SetDataReg(DataReg: TDataReg; Value: Int8);               //���������� �������� ��������
    procedure SetRegAddrValue(DataReg: TDataReg; Value: Int8);                    //�������� �������� �� ����������� ���������
    procedure SetRegPair(RegPair: TRegPair; Value: Word);                 //���������� �������� ����������� ����

    function GetStackPointer: Word;                                             //�������� �������� ��������� �����
    function GetProgramCounter: Word;                                           //�������� �������� �������� ������
    function GetInstRegister: Byte;                                             //�������� �������� �������� ������
    procedure SetStackPointer(Value: Word);                                     //���������� �������� ��������� �����
    procedure SetProgramCounter(Value: Word);                                   //���������� �������� �������� ������
    procedure SetInstRegister(Value: Byte);                                     //���������� �������� �������� ������

    function GetFlag(FlagName: TFlag): Boolean;                                 //�������� ��������� �����
    procedure SetFlag(FlagName: TFlag);                                         //���������� ����

    procedure ExecuteCommand(Instr: TInstruction; B1, B2, B3: Byte);
    procedure ExecuteSystemCommand(Instr: TInstruction; B1, B2, B3: Byte);
    procedure ExecuteDataCommand(Instr: TInstruction; B1, B2, B3: Byte);
    procedure ExecuteStackCommand(Instr: TInstruction; B1, B2, B3: Byte);
    procedure ExecuteArithmCommand(Instr: TInstruction; B1, B2, B3: Byte);
    procedure ExecuteLogicCommand(Instr: TInstruction; B1, B2, B3: Byte);
    procedure ExecuteControlCommand(Instr: TInstruction; B1, B2, B3: Byte);
    procedure ExecuteBranchCommand(Instr: TInstruction; B1, B2, B3: Byte);
  end;

implementation

uses
  FormScheme, FormMemory, FormEditor;

{ TProcessor }

constructor TProcessor.Create(Memory: TMemory);
begin
  inherited Create(True);
  Self.Memory := Memory;
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
  Op1, Op2, Op3: String;
  i: Integer;
  NewBit: Int8;
  Carry, Parity: Int8;
begin
  InitFlags;
  Op1 := IntToNumStr(GetDataReg(RA), SBIN, 8);
  Op2 := IntToNumStr(Value, SBIN, 8);
  Op3 := '';
  Carry := 0;
  Parity := 0;
  for i := 8 downto 1 do
  begin
    //������� ���
    NewBit := StrToInt(Op1[i]) + StrToInt(Op2[i]) + Carry;
    //���� �������� 2 - ���������
    if NewBit > 1 then
    begin
      Carry := 1;
      NewBit := NewBit mod 2;
    end
    else
      Carry := 0;
    //������� ���������� ������
    if NewBit = 1 then
      Inc(Parity);
    //���������� ���� ���������������� ��������
    if (i = 4) and (Carry = 1) then
      SetFlag(FAC);
    //�������� ���������
    Op3 := IntToStr(NewBit) + Op3;
  end;
  //���������� �����
  if NewBit = 1 then                    //������������� ���������
    SetFlag(FS);
  if Parity = 0 then                    //������� ���������
    SetFlag(FZ)
  else if Parity mod 2 = 0 then         //������ ���������� ������
    SetFlag(FP);
  if Carry = 1 then                     //������� �� �������� �������
    SetFlag(FCY);
  //��������� �����������
  SetDataReg(RA, NumStrToInt(Op3, SBIN));
end;

function TProcessor.GetDataReg;
begin
  Result := Registers.DataRegisters[DataReg];
end;

function TProcessor.GetRegAddrValue;
begin
  if DataReg = RM then
    Result := Memory.ReadMemory(GetRegPair(RPHL))
  else
    Result := GetDataReg(DataReg);
end;

function TProcessor.GetRegPair;
begin
  if RegPair = RPSP then
    Result := GetStackPointer
  else
  begin
    case RegPair of
      RPBC: Result := MakeWord(Registers.DataRegisters[RB], Registers.DataRegisters[RC]);
      RPDE: Result := MakeWord(Registers.DataRegisters[RD], Registers.DataRegisters[RE]);
      RPHL: Result := MakeWord(Registers.DataRegisters[RH], Registers.DataRegisters[RL]);
      RPSW: Result := MakeWord(Registers.DataRegisters[RA], Registers.DataRegisters[RF]);
    end;
  end;
end;

procedure TProcessor.SetDataReg;
begin
  Registers.DataRegisters[DataReg] := Value;
end;

procedure TProcessor.SetRegAddrValue;
begin
  if DataReg = RM then
    Memory.WriteMemory(GetRegPair(RPHL), Value)
  else
    SetDataReg(DataReg, Value);
end;

procedure TProcessor.SetRegPair;
var
  HiReg, LoReg: TDataReg;
begin
  if RegPair = RPSP then
    SetStackPointer(Value)
  else
  begin
    case RegPair of
      RPBC: begin HiReg := RB; LoReg := RC; end;
      RPDE: begin HiReg := RD; LoReg := RE; end;
      RPHL: begin HiReg := RH; LoReg := RL; end;
      RPSW: begin HiReg := RA; LoReg := RF; end;
    end;
    Registers.DataRegisters[HiReg] := Hi(Value);
    Registers.DataRegisters[LoReg] := Lo(Value);
  end;
end;

function TProcessor.GetStackPointer;
begin
  Result := Registers.SP;
end;

function TProcessor.GetProgramCounter;
begin
  Result := Registers.PC;
end;

function TProcessor.GetInstRegister;
begin
  Result := Registers.IR;
end;

procedure TProcessor.SetStackPointer;
begin
  Registers.SP := Value;
end;

procedure TProcessor.SetProgramCounter;
begin
  Registers.PC := Value;
end;

procedure TProcessor.SetInstRegister;
begin
  Registers.IR := Value;
end;

procedure TProcessor.InitFlags;
begin
  Registers.DataRegisters[RF] := 2; //00000010
end;

function TProcessor.GetFlag;
var
  Shift: Byte;
begin
  //���������� ���
  case FlagName of
    FS:  Shift := 7;
    FZ:  Shift := 6;
    FAC: Shift := 4;
    FP:  Shift := 2;
    FCY: Shift := 0;
  end;
  //��������� ���
  Result := (Registers.DataRegisters[RF] shr Shift) and 1 = 1;
end;

procedure TProcessor.SetFlag;
var
  Shift: Byte;
begin
  //���������� ���
  case FlagName of
    FS:  Shift := 7;
    FZ:  Shift := 6;
    FAC: Shift := 4;
    FP:  Shift := 2;
    FCY: Shift := 0;
  end;
  //������ ���
  Registers.DataRegisters[RF] := Registers.DataRegisters[RF] or (1 shl Shift);
end;

procedure TProcessor.InitCpu(EntryPoint: Word);
begin
  InitDataRegisters;                //�������������� �������� ������
  Registers.PC := EntryPoint;       //�������������� ������� ������ �� ��������� ����� �����
  HltState := False;
end;

procedure TProcessor.ShowRegisters;
begin
  frmScheme.DrawProcessor(Self);
end;

procedure TProcessor.ExecuteCommand;
begin
  //��������� ����� ������
  frmScheme.redtLog.Lines.Add(Instr.Summary);
  //����� ���� �������
  case Instr.Group of
    ICSystem:   ExecuteSystemCommand(Instr, B1, B2, B3);
    ICData:     ExecuteDataCommand(Instr, B1, B2, B3);
    ICStack:    ExecuteStackCommand(Instr, B1, B2, B3);
    ICArithm:   ExecuteArithmCommand(Instr, B1, B2, B3);
    ICLogic:    ExecuteLogicCommand(Instr, B1, B2, B3);
    ICControl:  ExecuteControlCommand(Instr, B1, B2, B3);
    ICBranch:   ExecuteBranchCommand(Instr, B1, B2, B3);
  end;
end;

procedure TProcessor.ExecuteSystemCommand;
begin
  with Instr do
  case Code of
    $76: {HLT}  begin
                  HltState := True;
                end;
  end;
end;

procedure TProcessor.ExecuteDataCommand;
var
  Temp16: Word;
begin
  with Instr, Memory do
  case Code of
    $40: {MOV}  begin
                  SetRegAddrValue(ExReg(B1), GetRegAddrValue(ExReg(B1, True)));
                end;
    $06: {MVI}  begin
                  SetRegAddrValue(ExReg(B1), B2);
                end;
    $01: {LXI}  begin
                  SetRegPair(ExPair(B1), MakeWord(B3, B2));
                end;
    $3A: {LDA}  begin
                  SetDataReg(RA, ReadMemory(MakeWord(B3, B2)));
                end;
    $32: {STA}  begin
                  WriteMemory(MakeWord(B3, B2), GetDataReg(RA));
                end;
    $0A: {LDAX} begin
                  SetDataReg(RA, ReadMemory(GetRegPair(RPHL)));
                end;
    $02: {STAX} begin
                  WriteMemory(GetRegPair(RPHL), GetDataReg(RA));
                end;
    $2A: {LHLD} begin
                  SetDataReg(RL, ReadMemory(MakeWord(B3, B2)));
                  SetDataReg(RH, ReadMemory(MakeWord(B3, B2) + 1));
                end;
    $22: {SHLD} begin
                  WriteMemory(MakeWord(B3, B2), GetDataReg(RL));
                  WriteMemory(MakeWord(B3, B2) + 1, GetDataReg(RH));
                end;
    $EB: {XCHG} begin
                  Temp16 := GetRegPair(RPHL);
                  SetRegPair(RPHL, GetRegPair(RPDE));
                  SetRegPair(RPDE, Temp16);
                end;
  end;
end;

procedure TProcessor.ExecuteStackCommand;
var
  Temp8: Int8;
begin
  with Instr, Memory do
  case Code of
    $F9: {SPHL} begin
                  SetStackPointer(GetRegPair(RPHL));
                end;
    $E3: {XTHL} begin
                  Temp8 := GetDataReg(RL);
                  SetDataReg(RL, ReadMemory(GetStackPointer));
                  WriteMemory(GetStackPointer, Temp8);
                  Temp8 := GetDataReg(RH);
                  SetDataReg(RH, ReadMemory(GetStackPointer + 1));
                  WriteMemory(GetStackPointer + 1, Temp8);
                end;
  end;
end;

procedure TProcessor.ExecuteArithmCommand;
begin
  with Instr, Memory do
  case Code of
    $80: {ADD}  begin
                  PerformALU(GetRegAddrValue(ExReg(B1)));
                end;
  end;
end;

procedure TProcessor.ExecuteLogicCommand;
begin

end;

procedure TProcessor.ExecuteControlCommand;
begin

end;

procedure TProcessor.ExecuteBranchCommand;
begin

end;

procedure TProcessor.Execute;
var
  s: string;
  c: integer;

  CurrentAddr: Word;
  CurrentInstr: TInstruction;
  B1, B2, B3: Byte;
begin
  inherited;
  FreeOnTerminate := True;
  //with Processor do
  begin
    //���� �� �������� HLT ��� ������� �� ����������� ������ - ������ �������
    repeat
      //������ ������ ���� ����������
      CurrentAddr := GetProgramCounter;
      B1 := Memory.ReadMemory(CurrentAddr);

      //���� ���������� � �������
      CurrentInstr := InstrSet.FindByCode(B1);
      if not Assigned(CurrentInstr) then
        CurrentInstr := InstrSet.FindByCode(B1, True);

      //���������� �������
      if Assigned(CurrentInstr) then
      begin
        //���� ���� ������ ������������� ������ - ��� ���
        if Assigned(StopSection) then
          StopSection.WaitFor(INFINITE);

        //������������� ������� ������
        SetInstRegister(B1);

        //������ ������ � ������ ���� ���������� (���� ����)
        if CurrentInstr.Size > 1 then
        begin
          B2 := Memory.ReadMemory(CurrentAddr + 1);
          SetDataReg(RW, B2);
          if CurrentInstr.Size > 2 then
          begin
            B3 := Memory.ReadMemory(CurrentAddr + 2);
            SetDataReg(RZ, B3);
          end
        end;

        //������������� ������� ������
        SetProgramCounter(CurrentAddr + CurrentInstr.Size);

        //��������� ����� ������
        ShowRegisters;
        Memory.ShowNewMem;

        //���������� ������ ������������� ������
        if Assigned(StopSection) then
          StopSection.ResetEvent;

        //��������� �������
        ExecuteCommand(CurrentInstr, B1, B2, B3);
      end;
    until HltState or Terminated;
    //���������� ������ �������������
    if Assigned(StopSection) then
      FreeAndNil(StopSection);
    //TODO: ������� � ��������� �����
    with frmEditor do
    begin
      btnRunReal.Enabled := True;
      btnRunStep.Enabled := True;
      btnStop. Enabled := False;
      btnNextCommand.Enabled := False;
      btnMemClear.Enabled := True;
      btnMemUnload.Enabled := True;
    end;
  end;
end;

{ TMemory }

procedure TMemory.ShowNewMem;
begin
  frmMemory.Memory := Self;
  frmMemory.DrawMemory;
end;

function TMemory.ReadMemory(Address: Word): Int8;
begin
  Result := Cells[Address];
end;

procedure TMemory.WriteMemory(Address: Word; Value: Int8);
begin
  Cells[Address] := Value;
end;

end.
