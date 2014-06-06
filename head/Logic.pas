unit Logic;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//�������� ����������� ������
//���������, ������, ������� ������

interface

uses
  Classes, SyncObjs, Common;

const
  CMD_DATA          = '#MOV#MVI#LXI#LDA#STA#LDAX#STAX#LHLD#SHLD#XCHG#';
  CMD_STCK          = '#PUSH#POP#SPHL#XTHL#';
  CMD_ARTH          = '#ADD#ADC#ADI#ACI#SUB#SBB#SUI#SBI#INR#INX#DCR#DCX#DAD#DAA#';
  CMD_LOGC          = '#ANA#ORA#XRA#ANI#ORI#XRI#CMP#CPI#RAL#RAR#RLC#RRC#CMA#CMC#STC#';
  CMD_CTRL          = '#JMP#CALL#RET#RST#PCHL#JNC#JC#JNZ#JZ#JP#JM#JPO#JPE#CNC#CC#CNZ#CZ#CP#CM#CPO#CPE#RNC#RC#RNZ#RZ#RP#RM#RPO#RPE#';
  CMD_SYST          = '#NOP#HLT#';

type
  TMemoryCell = record
    Command: Pointer;                       //������ "�������" (��� �����, ���������� �������)
    Numeric: Int8;                          //�������� ���������� ������ ������
  end;
  TMemoryCells = array [Word] of TMemoryCell;
  TMemory = class
  private
    Cells: TMemoryCells;                    //������ ������
  public
    procedure ShowNewMem;                                                       //���������� ���������� ������ �� ������
    procedure WriteMemoryObject(Address: Word; Value: TMemoryCell);             //�������� � ������ ������
    function ReadMemoryObject(Address: Word): TMemoryCell;                      //������� �� ������ ������
    procedure WriteMemory(Address: Word; Value: Int8);                          //�������� � ������ �������� ��������
    function ReadMemory(Address: Word): Int8;                                   //������� �� ������ �������� ��������
  end;

  TFlag = (FS, FZ, FAC, FP, FCY);
  //TDataRegName = (RA, RF, RB, RC, RD, RE, RH, RL, RW, RZ);
  TDataReg = (RB, RC, RD, RE, RH, RL, RM, RA, RW, RZ, RF);
  TDataRegisters = array [TDataReg] of Int8;
  TRegisters = record
    DataRegisters: TDataRegisters;          //�������� ������ (8 bit)
    SP: Word;                               //��������� ����� (16 bit)
    PC: Word;                               //������� ������  (16 bit)
    AB: Word;                               //����� ������    (16 bit)
    IR: Int8;                               //������� ������  (8 bit)
  end;

  TProcessor = class;

  TProcessorThread = class(TThread)
  private
    Processor: TProcessor;
  public
    procedure Execute; override;
  end;

  TProcessor = class
  private
    HltState: Boolean;
    Memory: TMemory;                        //������
    Registers: TRegisters;                  //��������
    procedure InitDataRegisters;            //������������� ���������
    procedure InitFlags;                    //������������� �������� ������
  public
    ProcessorThread: TProcessorThread;
    StopSection: TEvent;
    constructor Create(Memory: TMemory);
    procedure OnTerm(Sender: TObject);
    procedure InitCpu(EntryPoint: Word);                                        //������������� ����������
    procedure Run;                                                              //��������� ����������
    procedure ShowRegisters;                                                    //���������� ���������� ��������� �� ������
    procedure PerformALU(Value: Int8);                                          //��������� �������� �� ���
    procedure SetDataReg(DataRegName: TDataReg; Value: Int8);               //���������� �������� ��������
    function GetDataReg(DataRegName: TDataReg): Int8;                       //�������� �������� ��������
    procedure SetDataRP(DataRPName: TDataReg; Value: Word);                 //���������� �������� ����������� ����
    function GetDataRP(DataRPName: TDataReg): Word;                         //�������� �������� ����������� ����
    function DataRegNameInt8xtName(TextName: String): TDataReg;             //��� �������� �� ���������� �����
    procedure SetRegAddrValue(Operand: String; Value: Int8);                    //�������� �������� �� ����������� ���������
    function GetRegAddrValue(Operand: String): Int8;                            //���������� �������� �� ����������� ���������
    procedure SetStackPointer(Value: Word);                                     //���������� �������� ��������� �����
    function GetStackPointer: Word;                                             //�������� �������� ��������� �����
    function GetProgramCounter: Word;                                           //�������� �������� �������� ������
    function GetInstRegister: Int8;                                             //�������� �������� �������� ������
    procedure SetFlag(FlagName: TFlag);                                         //���������� ����
    function GetFlag(FlagName: TFlag): Boolean;                                 //�������� ��������� �����
  end;

  TCommand = class                          //������� (������� �����)
  private
    Name: String;                           //��������� ��� �������
    Op1, Op2: String;                       //�������� � ��������� ����
    Description: String;                    //������� ��������� �������� ������� (��� ������������)
    CommandCode: String;                    //�������� ��� �������
  public
    constructor Create(Name: String; Op1, Op2: String);
    function ShowSummary: String;
    function Size: Integer;                                                     //������ ��������� ���� ������� � ������
    function WriteToMemory(Memory: TMemory; Address: Word): Word;               //�������� ������� � ������
    procedure Execute(Processor: TProcessor);                                   //��������� ������� �� ����������
  end;

  TDataCommand = class(TCommand)            //������� ��������� ������
  public
    constructor Create(Name: String; Op1, Op2: String);
    procedure Execute(Processor: TProcessor);
  end;
  TStackCommand = class(TCommand)           //������� ��������� �� ������
  public
    constructor Create(Name: String; Op1, Op2: String);
    procedure Execute(Processor: TProcessor);
  end;
  TArithmCommand = class(TCommand)          //������� ����������
  public
    constructor Create(Name: String; Op1, Op2: String);
    procedure Execute(Processor: TProcessor);
  end;
  TLogicCommand = class(TCommand)           //������� ������
  public
    constructor Create(Name: String; Op1, Op2: String);
    procedure Execute(Processor: TProcessor);
  end;
  TCtrlCommand = class(TCommand)            //������� ��������� � �������� ����������
  public
    constructor Create(Name: String; Op1, Op2: String);
    procedure Execute(Processor: TProcessor);
  end;
  TSysCommand = class(TCommand)             //������� ���������� �����������
  public
    constructor Create(Name: String; Op1, Op2: String);
    procedure Execute(Processor: TProcessor);
  end;

  TCommandParser = class                    //���������� ��������� ����
  public
    function ParseCommand(TextLine: String; var Command: TCommand): Boolean;    //������ ������ �������
  end;

  TNewParser = class
  private
    function GetCode(Name, Op1, Op2: String; var CommandCode: String): Boolean;
  public
    function ParseCommand(TextLine: String; var CommandCode: String): Boolean;    //������ ������ �������
    function WriteCode(CommandCode: String; Memory: TMemory; var Address: Word): Boolean;
  end;

implementation

uses
  SysUtils, Dialogs, TypInfo, FormScheme, FormMemory, FormEditor;

{ TProcessor }

constructor TProcessor.Create(Memory: TMemory);
begin
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

function TProcessor.DataRegNameInt8xtName;
var
  CurReg: TDataReg;
begin
  //����������� ��������� ����������� �������� � ��� ����������� �� TDataRegistersNames
  for CurReg := Low(TDataReg) to High(TDataReg) do
    if 'R' + TextName = GetEnumName(TypeInfo(TDataReg), Ord(CurReg)) then
    begin
      Result := CurReg;
      Break;
    end;
end;

procedure TProcessor.SetRegAddrValue;
begin
  if Operand = 'M' then             //��������� ��������� ������
    Memory.WriteMemory(GetDataRP(RH), Value)
  else                              //����������� ���������
    SetDataReg(DataRegNameInt8xtName(Operand), Value);
end;

function TProcessor.GetRegAddrValue;
begin
  if Operand = 'M' then             //��������� ��������� ������
    Result := Memory.ReadMemory(GetDataRP(RH))
  else                              //����������� ���������
    Result := GetDataReg(DataRegNameInt8xtName(Operand));
end;

procedure TProcessor.SetDataReg;
begin
  Registers.DataRegisters[DataRegName] := Value;
end;

function TProcessor.GetDataReg;
begin
  Result := Registers.DataRegisters[DataRegName];
end;

procedure TProcessor.SetDataRP;
begin
  //���������� ����������� ���� � ���������� �������� ������� � ������� �����
  case DataRPName of
    RA: begin
          SetDataReg(RA, Hi(Value));
          SetDataReg(RF, Lo(Value));
        end;
    RB: begin
          SetDataReg(RB, Hi(Value));
          SetDataReg(RC, Lo(Value));
        end;
    RD: begin
          SetDataReg(RD, Hi(Value));
          SetDataReg(RE, Lo(Value));
        end;
    RH: begin
          SetDataReg(RH, Hi(Value));
          SetDataReg(RL, Lo(Value));
        end;
    RW: begin
          SetDataReg(RW, Hi(Value));
          SetDataReg(RZ, Lo(Value));
        end;
  end;
end;

function TProcessor.GetDataRP;
begin
  //���������� ����������� ���� � ����������� ��� ����� � Word
  case DataRPName of
    RA: Result := GetDataReg(RF) + (GetDataReg(RA) shl 8);
    RB: Result := GetDataReg(RC) + (GetDataReg(RB) shl 8);
    RD: Result := GetDataReg(RE) + (GetDataReg(RD) shl 8);
    RH: Result := GetDataReg(RL) + (GetDataReg(RH) shl 8);
    RW: Result := GetDataReg(RZ) + (GetDataReg(RW) shl 8);
  end;
end;

procedure TProcessor.SetStackPointer(Value: Word);
begin
  Registers.SP := Value;
end;

function TProcessor.GetStackPointer: Word;
begin
  Result := Registers.SP;
end;

function TProcessor.GetProgramCounter: Word;
begin
  Result := Registers.PC;
end;

function TProcessor.GetInstRegister: Int8;
begin
  Result := Registers.IR;
end;

procedure TProcessor.InitFlags;
begin
  Registers.DataRegisters[RF] := 2; //00000010
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

procedure TProcessor.InitCpu(EntryPoint: Word);
begin
  InitDataRegisters;                //�������������� �������� ������
  Registers.PC := EntryPoint;       //�������������� ������� ������ �� ��������� ����� �����
  HltState := False;
end;

procedure TProcessor.Run;
var
  s: string;
  c: integer;
begin
  //������ � ��������� �����
  ProcessorThread := TProcessorThread.Create(True);
  ProcessorThread.OnTerminate := OnTerm;
  ProcessorThread.Processor := Self;
  ProcessorThread.Start;
end;

procedure TProcessor.ShowRegisters;
begin
  frmScheme.DrawProcessor(Self);
end;

procedure TProcessor.OnTerm(Sender: TObject);
begin
  ProcessorThread := nil;
end;

{ TProcessorThread }

procedure TProcessorThread.Execute;
var
  s: string;
  c: integer;
begin
  inherited;
  FreeOnTerminate := True;
  with Processor do
  begin
    //���� �� �������� HLT ��� ������� �� ����������� ������ - ������ �������
    repeat
      if Assigned(Memory.Cells[Registers.PC].Command) then
      begin
        c := Registers.PC;
        s := TCommand(Memory.Cells[Registers.PC].Command).ShowSummary;
        if TCommand(Memory.Cells[Registers.PC].Command) is TDataCommand then
          TDataCommand(Memory.Cells[Registers.PC].Command).Execute(Processor)
        else if TCommand(Memory.Cells[Registers.PC].Command) is TStackCommand then
          TStackCommand(Memory.Cells[Registers.PC].Command).Execute(Processor)
        else if TCommand(Memory.Cells[Registers.PC].Command) is TArithmCommand then
          TArithmCommand(Memory.Cells[Registers.PC].Command).Execute(Processor)
        else if TCommand(Memory.Cells[Registers.PC].Command) is TLogicCommand then
          TLogicCommand(Memory.Cells[Registers.PC].Command).Execute(Processor)
        else if TCommand(Memory.Cells[Registers.PC].Command) is TCtrlCommand then
          TCtrlCommand(Memory.Cells[Registers.PC].Command).Execute(Processor)
        else if TCommand(Memory.Cells[Registers.PC].Command) is TSysCommand then
          TSysCommand(Memory.Cells[Registers.PC].Command).Execute(Processor)
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

procedure TMemory.WriteMemoryObject;
begin
  Cells[Address] := Value;
end;

function TMemory.ReadMemoryObject;
begin
  Result := Cells[Address];
end;

procedure TMemory.WriteMemory(Address: Word; Value: Int8);
begin
  Cells[Address].Numeric := Value;
end;

function TMemory.ReadMemory(Address: Word): Int8;
begin
  Result := Cells[Address].Numeric;
end;

{ TCommand }

constructor TCommand.Create;
begin
  Self.Name := Name;
  Self.Op1 := Op1;
  Self.Op2 := Op2;
end;

function TCommand.WriteToMemory;
var
  CurrentCell: TMemoryCell;
  CommandByte: Integer;
begin
  CommandByte := 0;
  //���������� � ������ ������
  CurrentCell.Command := Self;
  Memory.WriteMemoryObject(Address, CurrentCell);
  //���������� � ������ �������� ��� �������
  repeat
    Memory.WriteMemory(Address + CommandByte, NumStrToInt(Copy(CommandCode, CommandByte*8 + 1, 8), SBIN));
    Inc(CommandByte);
  until CommandByte = Size;
  //���������� ��������� ��������� ����� ������
  Result := Address + CommandByte;
end;

procedure TCommand.Execute;
begin
  //��������� ����� ������
  Processor.ShowRegisters;
  Processor.Memory.ShowNewMem;
  //���� ���� ������ ������������� ������ - ��� ���
  if Assigned(Processor.StopSection) then
    Processor.StopSection.WaitFor(INFINITE);
  //������������� ������ ���� ������� � IR, ������ � ������ - � WZ
  Processor.Registers.IR := NumStrToInt(Copy(CommandCode, 1, 8), SBIN);
  Processor.SetDataReg(RW, 0);
  Processor.SetDataReg(RZ, 0);
  if Size > 1 then
    Processor.SetDataReg(RW, NumStrToInt(Copy(CommandCode, 9, 8), SBIN));
  if Size > 2 then
    Processor.SetDataReg(RZ, NumStrToInt(Copy(CommandCode, 17, 8), SBIN));
  //����������� ������� ������
  Processor.Registers.PC := Processor.Registers.PC + Size;
  //���������� ������ ������������� ������
  if Assigned(Processor.StopSection) then
    Processor.StopSection.ResetEvent;
end;

function TCommand.Size: Integer;
begin
  Result := Length(CommandCode) div 8;
end;

function TCommand.ShowSummary: String;
begin
  Result := 'Command: #' + Name + '#, OP1: #' + Op1 + '#, OP2: #' + Op2 + '#, Code: #' + CommandCode + '#';
end;

{ TDataCommand }

constructor TDataCommand.Create;
begin
  inherited;
  //������� ��������� ������
  if Name = 'MOV' then
    CommandCode := '01' + FormatAddrCode(Op1) + FormatAddrCode(Op2)
  else if Name = 'MVI' then
    CommandCode := '00' + FormatAddrCode(Op1) + '110' + ConvertNumStrAuto(Op2, SBIN, 8)
  else if Name = 'LXI' then
    CommandCode := '00' + FormatAddrCode(Op1, True) + '0001' + ConvertNumStrAuto(Op2, SBIN, 16)
  else if Name = 'LDA' then
    CommandCode := '00111010' + ConvertNumStrAuto(Op1, SBIN, 16)
  else if Name = 'STA' then
    CommandCode := '00110010' + ConvertNumStrAuto(Op1, SBIN, 16)
  else if Name = 'LDAX' then
    CommandCode := '00' + FormatAddrCode(Op1, True) + '1010'
  else if Name = 'STAX' then
    CommandCode := '00' + FormatAddrCode(Op1, True) + '0010'
  else if Name = 'LHLD' then
    CommandCode := '00101010' + ConvertNumStrAuto(Op1, SBIN, 16)
  else if Name = 'SHLD' then
    CommandCode := '00100010' + ConvertNumStrAuto(Op1, SBIN, 16)
  else if Name = 'XCHG' then
    CommandCode := '11101011';
  //if NumStrToInt(Copy(CommandCode, 1, 8), SBIN) in [$2A..$2A] then
  //  ShowMessage(Name);
end;

procedure TDataCommand.Execute;
var
  Temp16: Word;
begin
  inherited;
  with Processor do
  begin
    if Name = 'MOV' then
      SetRegAddrValue(Op1, GetRegAddrValue(Op2))
    else if Name = 'MVI' then
      SetRegAddrValue(Op1, NumStrToIntAuto(Op2))
    else if Name = 'LXI' then
      SetDataRP(DataRegNameInt8xtName(Op1), NumStrToIntAuto(Op2))
    else if Name = 'LDA' then
      SetDataReg(RA, Memory.ReadMemory(NumStrToIntAuto(Op1)))
    else if Name = 'LDAX' then
      SetDataReg(RA, Memory.ReadMemory(GetDataRP(DataRegNameInt8xtName(Op1))))
    else if Name = 'STA' then
      Memory.WriteMemory(NumStrToIntAuto(Op1), GetDataReg(RA))
    else if Name = 'STAX' then
      Memory.WriteMemory(GetDataRP(DataRegNameInt8xtName(Op1)), GetDataReg(RA))
    else if Name = 'LHLD' then
    begin
      SetDataReg(RL, Memory.ReadMemory(NumStrToIntAuto(Op1)));
      SetDataReg(RH, Memory.ReadMemory(NumStrToIntAuto(Op1)+1));
    end
    else if Name = 'SHLD' then
    begin
      Memory.WriteMemory(NumStrToIntAuto(Op1), GetDataReg(RL));
      Memory.WriteMemory(NumStrToIntAuto(Op1)+1, GetDataReg(RH));
    end
    else if Name = 'XCHG' then
    begin
      Temp16 := GetDataRP(RH);
      SetDataRP(RH, GetDataRP(RD));
      SetDataRP(RD, Temp16);
    end;
  end;
end;

{ TStackCommand }

constructor TStackCommand.Create(Name, Op1, Op2: String);
begin
  inherited;
  //������� ������ �� ������
  if Name = 'PUSH' then
    CommandCode := '11' + FormatAddrCode(Op1, True) + '0101'
  else if Name = 'POP' then
    CommandCode := '11' + FormatAddrCode(Op1, True) + '0001'
  else if Name = 'SPHL' then
    CommandCode := '11111001'
  else if Name = 'XTHL' then
    CommandCode := '11100011';
end;

procedure TStackCommand.Execute(Processor: TProcessor);
var
  Temp16: Word;
begin
  inherited;
  with Processor do
  begin
    if Name = 'SPHL' then
      SetStackPointer(GetDataRP(RH))
    else if Name = 'XTHL' then
    begin
      Temp16 := GetDataRP(RH);
      SetDataReg(RH, Memory.ReadMemory(GetStackPointer));
      SetDataReg(RL, Memory.ReadMemory(GetStackPointer + 1));
      Memory.WriteMemory(GetStackPointer, Hi(Temp16));
      Memory.WriteMemory(GetStackPointer + 1, Lo(Temp16));
     end;
  end;
end;

{ TArithmCommand }

constructor TArithmCommand.Create(Name, Op1, Op2: String);
begin
  inherited;
  //��������
  if Name = 'ADD' then
    CommandCode := '10000' + FormatAddrCode(Op1)
  else if Name = 'ADI' then
    CommandCode := '11000110' + ConvertNumStrAuto(Op1, SBIN, 8)
  else if Name = 'ADC' then
    CommandCode := '10001' + FormatAddrCode(Op1)
  else if Name = 'ACI' then
    CommandCode := '11001110' + ConvertNumStrAuto(Op1, SBIN, 8)
  //���������
  else if Name = 'SUB' then
    CommandCode := '10010' + FormatAddrCode(Op1)
  else if Name = 'SUI' then
    CommandCode := '11010110' + ConvertNumStrAuto(Op1, SBIN, 8)
  else if Name = 'SBB' then
    CommandCode := '10011' + FormatAddrCode(Op1)
  else if Name = 'SBI' then
    CommandCode := '11011110' + ConvertNumStrAuto(Op1, SBIN, 8)
  //���������/���������
  else if Name = 'INR' then
    CommandCode := '00' + FormatAddrCode(Op1) + '100'
  else if Name = 'INX' then
    CommandCode := '00' + FormatAddrCode(Op1, True) + '0011'
  else if Name = 'DCR' then
    CommandCode := '00' + FormatAddrCode(Op1) + '101'
  else if Name = 'DCX' then
    CommandCode := '00' + FormatAddrCode(Op1, True) + '1011'
  //������� ��������
  else if Name = 'DAD' then
    CommandCode := '00' + FormatAddrCode(Op1, True) + '1001'
  //�������-���������� ���������
  else if Name = 'DAA' then
    CommandCode := '00100111';
end;

procedure TArithmCommand.Execute(Processor: TProcessor);
begin
  inherited;
  with Processor do
  begin
    if Name = 'ADD' then
    begin
      PerformALU(GetRegAddrValue(Op1));
    end;
  end;
end;

{ TLogicCommand }

constructor TLogicCommand.Create(Name, Op1, Op2: String);
begin
  inherited;
  //���������� ��������
  if Name = 'ANA' then
    CommandCode := '10100' + FormatAddrCode(Op1)
  else if Name = 'ANI' then
    CommandCode := '11100110' + ConvertNumStrAuto(Op1, SBIN, 8)
  else if Name = 'XRA' then
    CommandCode := '10101' + FormatAddrCode(Op1)
  else if Name = 'XRI' then
    CommandCode := '11101110' + ConvertNumStrAuto(Op1, SBIN, 8)
  else if Name = 'ORA' then
    CommandCode := '10110' + FormatAddrCode(Op1)
  else if Name = 'ORI' then
    CommandCode := '11110110' + ConvertNumStrAuto(Op1, SBIN, 8)
  //���������
  else if Name = 'CMP' then
    CommandCode := '10111' + FormatAddrCode(Op1)
  else if Name = 'CPI' then
    CommandCode := '11111110' + ConvertNumStrAuto(Op1, SBIN, 8)
  //�����
  else if Name = 'RLC' then
    CommandCode := '00000111'
  else if Name = 'RRC' then
    CommandCode := '00001111'
  else if Name = 'RAL' then
    CommandCode := '00010111'
  else if Name = 'RAR' then
    CommandCode := '00011111'
  //����������� �������
  else if Name = 'CMA' then
    CommandCode := '00101111'
  else if Name = 'CMC' then
    CommandCode := '00111111'
  else if Name = 'STC' then
    CommandCode := '00110111';
end;

procedure TLogicCommand.Execute(Processor: TProcessor);
begin
  inherited;
end;

{ TCtrlCommand }

constructor TCtrlCommand.Create(Name, Op1, Op2: String);
var
  Condition, Instruction: String;
begin
  inherited;
  //����������� ��������
  if Name = 'JMP' then
    CommandCode := '11000011' + ConvertNumStrAuto(Op1, SBIN, 16)
  else if Name = 'CALL' then
    CommandCode := '11001101' + ConvertNumStrAuto(Op1, SBIN, 16)
  else if Name = 'RET' then
    CommandCode := '11001001'
  //����������� �������
  else if Name = 'RST' then
    CommandCode := '11' + ConvertNumStrAuto(Op1, SBIN, 3) + '111'
  else if Name = 'PCHL' then
    CommandCode := '11101001'
  //�������� ��������
  else
  begin
    //���������� �������
    Condition := Copy(Name, 2, Name.Length-1);
    if      Condition   = 'NZ'  then Condition    := '000'
    else if Condition   = 'Z'   then Condition    := '001'
    else if Condition   = 'NC'  then Condition    := '010'
    else if Condition   = 'C'   then Condition    := '011'
    else if Condition   = 'PO'  then Condition    := '100'
    else if Condition   = 'PE'  then Condition    := '101'
    else if Condition   = 'P'   then Condition    := '110'
    else if Condition   = 'M'   then Condition    := '111';
    //���������� ��� ��������
    Instruction := Name[1];
    if      Instruction = 'J'   then Instruction  := '010'
    else if Instruction = 'C'   then Instruction  := '100'
    else if Instruction = 'R'   then Instruction  := '000';
    //�������� ��� �������
    CommandCode := '11' + Condition + Instruction;
  end;
end;

procedure TCtrlCommand.Execute(Processor: TProcessor);
begin
  inherited;
end;

{ TSysCommand }

constructor TSysCommand.Create;
begin
  inherited;
  if Name = 'HLT' then
    CommandCode := '01110110'
  else if Name = 'NOP' then
    CommandCode := '00000000';
end;

procedure TSysCommand.Execute;
begin
  inherited;
  if Name = 'HLT' then
    Processor.HltState := True;
end;

{ TCommandParser }

function TCommandParser.ParseCommand;
var
  Cmd, Op1, Op2: String;
  NextDelimeter: Integer;
begin
  try
    Result := True;
    //�������������� ������
    NextDelimeter := Pos(#59, TextLine);    //���� ����� � ������� � ������
    if NextDelimeter > 0 then               //���� �����������
      Delete(TextLine, Pos(#59, TextLine) - 1, TextLine.Length - Pos(#59, TextLine) + 2);
    NextDelimeter := Pos(#32, TextLine);    //���� ������ � ������
    if NextDelimeter = 0 then               //��������� ���
      Cmd := TextLine
    else                                    //�������� ����
    begin
      Cmd := Copy(TextLine, 1, NextDelimeter - 1);
      Delete(TextLine, 1, NextDelimeter);
      NextDelimeter := Pos(#44, TextLine);  //���� ������� � ������
      if NextDelimeter = 0 then             //������� ����
        Op1 := TextLine
      else                                  //��������� ���
      begin
        Op1 := Copy(TextLine, 1, NextDelimeter - 1);
        Delete(TextLine, 1, NextDelimeter + 1);
        Op2 := TextLine;
      end;
    end;
    //������������� ������
    if Pos(Cmd, CMD_DATA) > 0 then          //������� ���������
      Command := TDataCommand.Create(Cmd, Op1, Op2)
    else if Pos(Cmd, CMD_STCK) > 0 then     //������� �����
      Command := TStackCommand.Create(Cmd, Op1, Op2)
    else if Pos(Cmd, CMD_ARTH) > 0 then     //������� ����������
      Command := TArithmCommand.Create(Cmd, Op1, Op2)
    else if Pos(Cmd, CMD_LOGC) > 0 then     //������� ������
      Command := TLogicCommand.Create(Cmd, Op1, Op2)
    else if Pos(Cmd, CMD_CTRL) > 0 then     //������� ��������
      Command := TCtrlCommand.Create(Cmd, Op1, Op2)
    else if Pos(Cmd, CMD_SYST) > 0 then     //������� ����������
      Command := TSysCommand.Create(Cmd, Op1, Op2)
    else
      Result := False;                      //������ � ���� �������
   except
    Result := False;                        //�������������� ������
  end;
end;

{ TNewParser }

function TNewParser.ParseCommand;
var
  Cmd, Op1, Op2: String;
  NextDelimeter: Integer;
begin
  try
    Result := True;
    //�������������� ������
    NextDelimeter := Pos(#59, TextLine);    //���� ����� � ������� � ������
    if NextDelimeter > 0 then               //���� �����������
      Delete(TextLine, Pos(#59, TextLine) - 1, TextLine.Length - Pos(#59, TextLine) + 2);
    NextDelimeter := Pos(#32, TextLine);    //���� ������ � ������
    if NextDelimeter = 0 then               //��������� ���
      Cmd := TextLine
    else                                    //�������� ����
    begin
      Cmd := Copy(TextLine, 1, NextDelimeter - 1);
      Delete(TextLine, 1, NextDelimeter);
      NextDelimeter := Pos(#44, TextLine);  //���� ������� � ������
      if NextDelimeter = 0 then             //������� ����
        Op1 := TextLine
      else                                  //��������� ���
      begin
        Op1 := Copy(TextLine, 1, NextDelimeter - 1);
        Delete(TextLine, 1, NextDelimeter + 1);
        Op2 := TextLine;
      end;
    end;
    //������������� ������
    Result := GetCode(Cmd, Op1, Op2, CommandCode);
  except
    Result := False;                        //�������������� ������
  end;
end;

function TNewParser.WriteCode;
var
  Bits: Byte;
begin
  try
    Bits := 0;
    //���������� � ������ �������� ��� �������
    repeat
      Memory.WriteMemory(Address, NumStrToInt(Copy(CommandCode, Bits + 1, 8), SBIN));
      Address := Address + 1;
      Bits := Bits + 8;
    until Bits = CommandCode.Length;
    Result := True;
  except
    Result := False;
  end;
end;

function TNewParser.GetCode;
var
  Condition, Instruction: String;
begin
  CommandCode := '';
  //������� ��������� ������
  if Pos(Name, CMD_DATA) > 0 then
  begin
    if Name = 'MOV' then
      CommandCode := '01' + FormatAddrCode(Op1) + FormatAddrCode(Op2)
    else if Name = 'MVI' then
      CommandCode := '00' + FormatAddrCode(Op1) + '110' + ConvertNumStrAuto(Op2, SBIN, 8)
    else if Name = 'LXI' then
      CommandCode := '00' + FormatAddrCode(Op1, True) + '0001' + ConvertNumStrAuto(Op2, SBIN, 16)
    else if Name = 'LDA' then
      CommandCode := '00111010' + ConvertNumStrAuto(Op1, SBIN, 16)
    else if Name = 'STA' then
      CommandCode := '00110010' + ConvertNumStrAuto(Op1, SBIN, 16)
    else if Name = 'LDAX' then
      CommandCode := '00' + FormatAddrCode(Op1, True) + '1010'
    else if Name = 'STAX' then
      CommandCode := '00' + FormatAddrCode(Op1, True) + '0010'
    else if Name = 'LHLD' then
      CommandCode := '00101010' + ConvertNumStrAuto(Op1, SBIN, 16)
    else if Name = 'SHLD' then
      CommandCode := '00100010' + ConvertNumStrAuto(Op1, SBIN, 16)
    else if Name = 'XCHG' then
      CommandCode := '11101011';
  end
  //������� ������ �� ������
  else if Pos(Name, CMD_STCK) > 0 then
  begin
    if Name = 'PUSH' then
      CommandCode := '11' + FormatAddrCode(Op1, True) + '0101'
    else if Name = 'POP' then
      CommandCode := '11' + FormatAddrCode(Op1, True) + '0001'
    else if Name = 'SPHL' then
      CommandCode := '11111001'
    else if Name = 'XTHL' then
      CommandCode := '11100011';
  end
  //�������������� �������
  else if Pos(Name, CMD_ARTH) > 0 then
  begin
    //��������
    if Name = 'ADD' then
      CommandCode := '10000' + FormatAddrCode(Op1)
    else if Name = 'ADI' then
      CommandCode := '11000110' + ConvertNumStrAuto(Op1, SBIN, 8)
    else if Name = 'ADC' then
      CommandCode := '10001' + FormatAddrCode(Op1)
    else if Name = 'ACI' then
      CommandCode := '11001110' + ConvertNumStrAuto(Op1, SBIN, 8)
    //���������
    else if Name = 'SUB' then
      CommandCode := '10010' + FormatAddrCode(Op1)
    else if Name = 'SUI' then
      CommandCode := '11010110' + ConvertNumStrAuto(Op1, SBIN, 8)
    else if Name = 'SBB' then
      CommandCode := '10011' + FormatAddrCode(Op1)
    else if Name = 'SBI' then
      CommandCode := '11011110' + ConvertNumStrAuto(Op1, SBIN, 8)
    //���������/���������
    else if Name = 'INR' then
      CommandCode := '00' + FormatAddrCode(Op1) + '100'
    else if Name = 'INX' then
      CommandCode := '00' + FormatAddrCode(Op1, True) + '0011'
    else if Name = 'DCR' then
      CommandCode := '00' + FormatAddrCode(Op1) + '101'
    else if Name = 'DCX' then
      CommandCode := '00' + FormatAddrCode(Op1, True) + '1011'
    //������� ��������
    else if Name = 'DAD' then
      CommandCode := '00' + FormatAddrCode(Op1, True) + '1001'
    //�������-���������� ���������
    else if Name = 'DAA' then
      CommandCode := '00100111';
  end
  //���������� ��������
  else if Pos(Name, CMD_LOGC) > 0 then
  begin
    if Name = 'ANA' then
      CommandCode := '10100' + FormatAddrCode(Op1)
    else if Name = 'ANI' then
      CommandCode := '11100110' + ConvertNumStrAuto(Op1, SBIN, 8)
    else if Name = 'XRA' then
      CommandCode := '10101' + FormatAddrCode(Op1)
    else if Name = 'XRI' then
      CommandCode := '11101110' + ConvertNumStrAuto(Op1, SBIN, 8)
    else if Name = 'ORA' then
      CommandCode := '10110' + FormatAddrCode(Op1)
    else if Name = 'ORI' then
      CommandCode := '11110110' + ConvertNumStrAuto(Op1, SBIN, 8)
    //���������
    else if Name = 'CMP' then
      CommandCode := '10111' + FormatAddrCode(Op1)
    else if Name = 'CPI' then
      CommandCode := '11111110' + ConvertNumStrAuto(Op1, SBIN, 8)
    //�����
    else if Name = 'RLC' then
      CommandCode := '00000111'
    else if Name = 'RRC' then
      CommandCode := '00001111'
    else if Name = 'RAL' then
      CommandCode := '00010111'
    else if Name = 'RAR' then
      CommandCode := '00011111'
    //����������� �������
    else if Name = 'CMA' then
      CommandCode := '00101111'
    else if Name = 'CMC' then
      CommandCode := '00111111'
    else if Name = 'STC' then
      CommandCode := '00110111';
  end
  //������� �������� ����������
  else if Pos(Name, CMD_CTRL) > 0 then
  begin
    //����������� ��������
    if Name = 'JMP' then
      CommandCode := '11000011' + ConvertNumStrAuto(Op1, SBIN, 16)
    else if Name = 'CALL' then
      CommandCode := '11001101' + ConvertNumStrAuto(Op1, SBIN, 16)
    else if Name = 'RET' then
      CommandCode := '11001001'
    //����������� �������
    else if Name = 'RST' then
      CommandCode := '11' + ConvertNumStrAuto(Op1, SBIN, 3) + '111'
    else if Name = 'PCHL' then
      CommandCode := '11101001'
    //�������� ��������
    else
    begin
      //���������� �������
      Condition := Copy(Name, 2, Name.Length-1);
      if      Condition   = 'NZ'  then Condition    := '000'
      else if Condition   = 'Z'   then Condition    := '001'
      else if Condition   = 'NC'  then Condition    := '010'
      else if Condition   = 'C'   then Condition    := '011'
      else if Condition   = 'PO'  then Condition    := '100'
      else if Condition   = 'PE'  then Condition    := '101'
      else if Condition   = 'P'   then Condition    := '110'
      else if Condition   = 'M'   then Condition    := '111';
      //���������� ��� ��������
      Instruction := Name[1];
      if      Instruction = 'J'   then Instruction  := '010'
      else if Instruction = 'C'   then Instruction  := '100'
      else if Instruction = 'R'   then Instruction  := '000';
      //�������� ��� �������
      CommandCode := '11' + Condition + Instruction;
    end;
  end
  //������� ���������� ����������������
  else if Pos(Name, CMD_SYST) > 0 then
  begin
    if Name = 'HLT' then
      CommandCode := '01110110'
    else if Name = 'NOP' then
      CommandCode := '00000000';
  end;
  Result := CommandCode <> '';
end;

end.
