unit Logic;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//Основная программная логика эмуляции микропроцессора

interface

uses
  Common, Instructions,
  Classes, SyncObjs, SysUtils, Dialogs, TypInfo;

type
  TMemory = class
  private
    Cells: array [Word] of Int8;                    //Массив данных
  public
    procedure ShowNewMem;                                                       //Отобразить содержимое памяти на экране
    procedure WriteMemory(Address: Word; Value: Int8);                          //Записать в память цифровое значение
    function ReadMemory(Address: Word): Int8;                                   //Считать из памяти цифровое значение
  end;

  TDataRegisters = array [TDataReg] of Int8;
  TRegisters = record
    DataRegisters: TDataRegisters;          //Регистры данных (8 bit)
    SP: Word;                               //Указатель стека (16 bit)
    PC: Word;                               //Счетчик команд  (16 bit)
    AB: Word;                               //Буфер адреса    (16 bit)
    IR: Byte;                               //Регистр команд  (8 bit)
  end;

  TProcessor = class(TThread)
  private
    HltState: Boolean;
    Memory: TMemory;                        //Память
    Registers: TRegisters;                  //Регистры
    procedure InitDataRegisters;            //Инициализация регистров
    procedure InitFlags;                    //Инициализация регистра флагов
  public
    StopSection: TEvent;

    constructor Create(Memory: TMemory);
    procedure Execute; override;

    procedure InitCpu(EntryPoint: Word);                                        //Инициализация процессора
    procedure ShowRegisters;                                                    //Отобразить содержимое регистров на экране
    procedure PerformALU(Value: Int8);                                          //Выполнить операцию на АЛУ

    function GetDataReg(DataReg: TDataReg): Int8;                       //Получить значение регистра
    function GetRegAddrValue(DataReg: TDataReg): Int8;                            //Установить значение по регистровой адресации
    function GetRegPair(RegPair: TRegPair): Word;                         //Получить значение регистровой пары
    procedure SetDataReg(DataReg: TDataReg; Value: Int8);               //Установить значение регистра
    procedure SetRegAddrValue(DataReg: TDataReg; Value: Int8);                    //Получить значение по регистровой адресации
    procedure SetRegPair(RegPair: TRegPair; Value: Word);                 //Установить значение регистровой пары

    function GetStackPointer: Word;                                             //Получить значение указателя стека
    function GetProgramCounter: Word;                                           //Получить значение счетчика команд
    function GetInstRegister: Byte;                                             //Получить значение регистра команд
    procedure SetStackPointer(Value: Word);                                     //Установить значение указателя стека
    procedure SetProgramCounter(Value: Word);                                   //Установить значение счетчика команд
    procedure SetInstRegister(Value: Byte);                                     //Установить значение регистра команд

    function GetFlag(FlagName: TFlag): Boolean;                                 //Получить состояние флага
    procedure SetFlag(FlagName: TFlag);                                         //Установить флаг

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
    //Считаем бит
    NewBit := StrToInt(Op1[i]) + StrToInt(Op2[i]) + Carry;
    //Если получили 2 - переносим
    if NewBit > 1 then
    begin
      Carry := 1;
      NewBit := NewBit mod 2;
    end
    else
      Carry := 0;
    //Считаем количество единиц
    if NewBit = 1 then
      Inc(Parity);
    //Выставляем флаг вспомогательного переноса
    if (i = 4) and (Carry = 1) then
      SetFlag(FAC);
    //Конечный результат
    Op3 := IntToStr(NewBit) + Op3;
  end;
  //Выставляем флаги
  if NewBit = 1 then                    //Отрицательный результат
    SetFlag(FS);
  if Parity = 0 then                    //Нулевой результат
    SetFlag(FZ)
  else if Parity mod 2 = 0 then         //Четное количество единиц
    SetFlag(FP);
  if Carry = 1 then                     //Перенос из старшего разряда
    SetFlag(FCY);
  //Обновляем аккумулятор
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
  //Определяем бит
  case FlagName of
    FS:  Shift := 7;
    FZ:  Shift := 6;
    FAC: Shift := 4;
    FP:  Shift := 2;
    FCY: Shift := 0;
  end;
  //Считываем бит
  Result := (Registers.DataRegisters[RF] shr Shift) and 1 = 1;
end;

procedure TProcessor.SetFlag;
var
  Shift: Byte;
begin
  //Определяем бит
  case FlagName of
    FS:  Shift := 7;
    FZ:  Shift := 6;
    FAC: Shift := 4;
    FP:  Shift := 2;
    FCY: Shift := 0;
  end;
  //Меняем бит
  Registers.DataRegisters[RF] := Registers.DataRegisters[RF] or (1 shl Shift);
end;

procedure TProcessor.InitCpu(EntryPoint: Word);
begin
  InitDataRegisters;                //Инициализируем регистры данных
  Registers.PC := EntryPoint;       //Инициализируем счетчик команд на указанную точку входа
  HltState := False;
end;

procedure TProcessor.ShowRegisters;
begin
  frmScheme.DrawProcessor(Self);
end;

procedure TProcessor.ExecuteCommand;
begin
  //Временный вывод данных
  frmScheme.redtLog.Lines.Add(Instr.Summary);
  //Выбор типа команды
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
    //Пока не получили HLT или команду на уничтожение потока - читаем команды
    repeat
      //Читаем первый байт инструкции
      CurrentAddr := GetProgramCounter;
      B1 := Memory.ReadMemory(CurrentAddr);

      //Ищем инструкцию в матрице
      CurrentInstr := InstrSet.FindByCode(B1);
      if not Assigned(CurrentInstr) then
        CurrentInstr := InstrSet.FindByCode(B1, True);

      //Инструкция найдена
      if Assigned(CurrentInstr) then
      begin
        //Если есть объект синхронизации потока - ждём его
        if Assigned(StopSection) then
          StopSection.WaitFor(INFINITE);

        //Устанавливаем регистр команд
        SetInstRegister(B1);

        //Читаем второй и третий байт инструкции (если есть)
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

        //Устанавливаем счетчик команд
        SetProgramCounter(CurrentAddr + CurrentInstr.Size);

        //Обновляем вывод данных
        ShowRegisters;
        Memory.ShowNewMem;

        //Сбрасываем объект синхронизации потока
        if Assigned(StopSection) then
          StopSection.ResetEvent;

        //Исполняем команду
        ExecuteCommand(CurrentInstr, B1, B2, B3);
      end;
    until HltState or Terminated;
    //Уничтожаем объект синхронизации
    if Assigned(StopSection) then
      FreeAndNil(StopSection);
    //TODO: вынести в отдельный метод
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
