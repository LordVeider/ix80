unit Logic;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//Основная программная логика эмуляции микропроцессора

interface

uses
  Common, Instructions, Visualizer, Typelib,
  Classes, SyncObjs, SysUtils, Dialogs, TypInfo, Math,
  Winapi.Windows, Winapi.Messages, Vcl.Forms;

type
  TMemory = class
  public
    Cells: TMemoryCells;                                                        //Массив данных
    function Read(Address: Word): Int8;                                         //Считать из памяти цифровое значение
    procedure Write(Address: Word; Value: Int8);                                //Записать в память цифровое значение
    function LoadFromFile(FileName: String): Boolean;
    function SaveToFile(FileName: String): Boolean;
  end;

  TProcessor = class(TThread)
  private
    HltState: Boolean;
    Memory: TMemory;                        //Память
    Vis: TVisualizer;

    StopCmd, StopStep: TEvent;              //Объекты синхронизации потоков
    StopFlag: Boolean;                      //Флаг пропуска визуализации шагов до следующей команды

    procedure CmdWait;
    procedure CmdDone;
    procedure StepWait;
    procedure StepDone;

    procedure InitDataRegisters;            //Инициализация регистров
    procedure InitFlags;                    //Инициализация регистра флагов

    procedure ExecuteCommand(Instr: TInstruction; B1, B2, B3: Byte);
    procedure ExecuteSystemCommand(Instr: TInstruction; B1, B2, B3: Byte);
    procedure ExecuteDataCommand(Instr: TInstruction; B1, B2, B3: Byte);
    procedure ExecuteArithmCommand(Instr: TInstruction; B1, B2, B3: Byte);
    procedure ExecuteLogicCommand(Instr: TInstruction; B1, B2, B3: Byte);
    procedure ExecuteBranchCommand(Instr: TInstruction; B1, B2, B3: Byte);
  public
    Registers: TRegisters;                  //Регистры
    constructor Create(Vis: TVisualizer; Memory: TMemory; EntryPoint: Word);
    procedure Execute; override;

    procedure CmdInit;
    procedure StepInit;
    procedure CmdSkip;
    procedure StepSkip;

    procedure PerformALU(OpCode: TOpCode; Size: Byte; Op1, Op2: String;
      var Op3: String; var Flags: TFlagArray);                                  //Выполнить операцию двоичной арифметики-логики
    procedure PerformALUOnReg
      (OpCode: TOpCode; Reg: TDataReg; Value: Int8; UseCarry: Boolean = False;
      AffectedFlags: TFlagSet = [FS, FZ, FAC, FP, FCY]);                        //Выполнить операцию на АЛУ над регистром
    procedure PerformRotate(Right, ThroughCarry: Boolean);                      //Выполнить сдвиг аккумулятора

    function GetMemory(Address: Word): Int8;                                    //Считать из памяти цифровое значение
    procedure SetMemory(Address: Word; Value: Int8);                            //Записать в память цифровое значение

    function GetDataReg(DataReg: TDataReg): Int8;                               //Получить значение регистра
    function GetRegAddrValue(DataReg: TDataReg): Int8;                          //Установить значение по регистровой адресации
    function GetRegPair(RegPair: TRegPair): Word;                               //Получить значение регистровой пары
    procedure SetDataReg(DataReg: TDataReg; Value: Int8);                       //Установить значение регистра
    procedure SetRegAddrValue(DataReg: TDataReg; Value: Int8);                  //Получить значение по регистровой адресации
    procedure SetRegPair(RegPair: TRegPair; Value: Word);                       //Установить значение регистровой пары

    function GetStackPointer: Word;                                             //Получить значение указателя стека
    function GetProgramCounter: Word;                                           //Получить значение счетчика команд
    function GetInstRegister: Byte;                                             //Получить значение регистра команд
    procedure SetStackPointer(Value: Word);                                     //Установить значение указателя стека
    procedure SetProgramCounter(Value: Word);                                   //Установить значение счетчика команд
    procedure SetInstRegister(Value: Byte);                                     //Установить значение регистра команд

    function GetFlag(FlagName: TFlag): Byte;                                    //Получить состояние флага
    procedure SetFlag(FlagName: TFlag; Value: Byte);                            //Установить флаг
    function CheckCondition(Condition: TCondition): Boolean;                    //Проверить условие

    procedure NotOperation;                                                     //Пропуск такта
    procedure HaltProcessor;                                                    //Подать сигнал останова
  end;

implementation

{ TMemory }

function TMemory.Read;
begin
  Result := Cells[Address];
end;

procedure TMemory.Write;
begin
  Cells[Address] := Value;
end;

function TMemory.LoadFromFile;
var
  F: TextFile;
  I: Word;
begin
  AssignFile(F, FileName);
  Reset(F);
  try
    try
      for I := 0 to 65535 do
        ReadLn(F, Cells[I]);
      Result := True;
    except
      Result := False;
    end;
  finally
    CloseFile(F);
  end;
end;

function TMemory.SaveToFile;
var
  F: TextFile;
  I: Word;
begin
  AssignFile(F, FileName);
  Rewrite(F);
  try
    try
      for I := 0 to 65535 do
        WriteLn(F, Cells[I]);
      Result := True;
    except
      Result := False;
    end;
  finally
    CloseFile(F);
  end;
end;

{ TProcessor }

constructor TProcessor.Create;
begin
  inherited Create(True);
  Self.Memory := Memory;
  Self.Vis := Vis;
  InitDataRegisters;                //Инициализируем регистры данных
  InitFlags;                        //Инициализируем флаги
  Registers.PC := EntryPoint;       //Инициализируем счетчик команд на указанную точку входа
  HltState := False;
  FreeOnTerminate := True;
end;

procedure TProcessor.CmdInit;
begin
  StopCmd := TEvent.Create(nil, False, False, '');
end;

procedure TProcessor.CmdWait;
begin
  if Assigned(StopCmd) then
    StopCmd.WaitFor(INFINITE);
end;

procedure TProcessor.CmdDone;
begin
  if Assigned(StopCmd) then
  begin
    StopCmd.ResetEvent;
    if Assigned(StopStep) then
    begin
      StopFlag := True;
      StopStep.ResetEvent;
    end;
  end;
end;

procedure TProcessor.CmdSkip;
begin
  if Assigned(StopCmd) then
  begin
    StopCmd.SetEvent;
    if Assigned(StopStep) then
    begin
      StopFlag := False;
      StopStep.SetEvent;
    end;
  end;
end;

procedure TProcessor.StepInit;
begin
  StopStep := TEvent.Create(nil, False, False, '');
  StopFlag := True;
end;

procedure TProcessor.StepWait;
begin
  if StopFlag then
    if Assigned(StopStep) then
      StopStep.WaitFor(INFINITE);
  Vis.UnhighlightScheme;
  Vis.UnhighlightMemory;
end;

procedure TProcessor.StepDone;
begin
  if Assigned(StopStep) then
    StopStep.ResetEvent;
end;

procedure TProcessor.StepSkip;
begin
  if Assigned(StopStep) then
    StopStep.SetEvent;
  if Assigned(StopCmd) then
    StopCmd.SetEvent;
end;

procedure TProcessor.NotOperation;
begin
  StepWait;
  Vis.AddLog('Пропуск такта');
  StepDone;
end;

procedure TProcessor.HaltProcessor;
begin
  StepWait;
  HltState := True;
  Vis.AddLog('Получен сигнал останова');
  StepDone;
end;

procedure TProcessor.InitDataRegisters;
var
  CurReg: TDataReg;
begin
  //Обнуляем содержимое регистров
  for CurReg := Low(TDataReg) to High(TDataReg) do
    Registers.DataRegisters[CurReg] := 0;
end;

procedure TProcessor.InitFlags;
begin
  Registers.DataRegisters[RF] := 2; //00000010
end;

procedure TProcessor.PerformALU;
var
  Digit: Byte;
  NewBit: Byte;
  Carry, Parity: Byte;
begin
  //Инициализируем переменные
  Op3 := '';
  Carry := Flags[FCY];
  Parity := 0;
  //Выполняем операции поразрядно
  for Digit := Size downto 1 do
  begin
    case OpCode of
      OCSumm: begin
                //Считаем сумму
                NewBit := StrToInt(Op1[Digit]) + (StrToInt(Op2[Digit]) + Carry);
                //Считаем перенос и пересчитываем бит
                Carry := IfThen(NewBit > 1, 1, 0);
                NewBit := NewBit mod 2;
                //Выставляем флаг вспомогательного переноса из 3 в 4 разряд
                if Digit = 5 then
                  Flags[FAC] := Carry;
              end;
      OCAnd: NewBit := StrToInt(Op1[Digit]) and StrToInt(Op2[Digit]);
      OCLor: NewBit := StrToInt(Op1[Digit]) or  StrToInt(Op2[Digit]);
      OCXor: NewBit := StrToInt(Op1[Digit]) xor StrToInt(Op2[Digit]);
    end;
    //Считаем количество единиц
    Parity := Parity + NewBit;
    //Конечный результат
    Op3 := IntToStr(NewBit) + Op3;
  end;
  //Выставляем флаги
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
  //Инициализируем переменные
  StepWait;
  Vis.HighlightALU;
  Vis.AddLog('Выполнение операции на АЛУ');
  StepDone;
  Op1 := IntToNumStr(GetRegAddrValue(Reg), SBIN, 8);
  Op2 := IntToNumStr(Value, SBIN, 8);
  Flags[FCY] := IfThen(UseCarry, GetFlag(FCY), 0);
  //Выполняем операцию на сумматоре
  PerformALU(OpCode, 8, Op1, Op2, Op3, Flags);
  //Обновляем аккумулятор
  SetRegAddrValue(Reg, NumStrToInt(Op3, SBIN));
  //Выставляем флаги
  if FS   in AffectedFlags then SetFlag(FS,   Flags[FS]);
  if FZ   in AffectedFlags then SetFlag(FZ,   Flags[FZ]);
  if FP   in AffectedFlags then SetFlag(FP,   Flags[FP]);
  if FAC  in AffectedFlags then SetFlag(FAC,  Flags[FAC]);
  if FCY  in AffectedFlags then SetFlag(FCY,  Flags[FCY]);
  Vis.UnhighlightALU;
end;

procedure TProcessor.PerformRotate;
var
  TempStr: String;
begin
  StepWait;
  Vis.HighlightALU;
  Vis.AddLog('Выполнение операции на АЛУ');
  StepDone;
  TempStr := IntToNumStr(GetDataReg(RA), SBIN, 8);
  if Right then               //Правый сдвиг
  begin
    if ThroughCarry then      //Сдвиг через флаг переноса
      TempStr := IntToStr(GetFlag(FCY)) + TempStr
    else
      TempStr := TempStr[8] + TempStr;
    SetFlag(FCY, StrToInt(TempStr[9]));
    Delete(TempStr, 9, 1);
  end
  else                        //Левый сдвиг
  begin
    if ThroughCarry then      //Сдвиг через флаг переноса
      TempStr := TempStr + IntToStr(GetFlag(FCY))
    else
      TempStr := TempStr + TempStr[8];
    SetFlag(FCY, StrToInt(TempStr[1]));
    Delete(TempStr, 1, 1);
  end;
  SetDataReg(RA, NumStrToInt(TempStr, SBIN));
  Vis.UnhighlightALU;
end;

function TProcessor.GetMemory(Address: Word): Int8;
begin
  StepWait;
  Result := Memory.Read(Address);
  Vis.HighlightDataBus(Address);
  Vis.HighlightMemoryCell(Address);
  Vis.AddLog(Format('Чтение памяти по адресу %sH; Значение: %sH;', [IntToNumStr(Address, SHEX, 4), IntToNumStr(Result, SHEX, 2)]));
  StepDone;
end;

procedure TProcessor.SetMemory(Address: Word; Value: Int8);
begin
  StepWait;
  Memory.Write(Address, Value);
  Vis.UpdateMemory(Memory.Cells);
  Vis.HighlightDataBus(Address);
  Vis.HighlightMemoryCell(Address);
  Vis.AddLog(Format('Запись в память по адресу %sH; Значение: %sH;', [IntToNumStr(Address, SHEX, 4), IntToNumStr(Value, SHEX, 2)]));
  StepDone;
end;

function TProcessor.GetDataReg;
begin
  StepWait;
  Result := Registers.DataRegisters[DataReg];
  Vis.HighlightDataReg(DataReg);
  Vis.AddLog(Format('Чтение регистра %s; Значение: %sH;',
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
    Vis.HighlightRegPair(RegPair);
    Vis.AddLog(Format('Чтение регистровой пары %s; Значение: %sH;',
      [Copy(GetEnumName(TypeInfo(TRegPair), Ord(RegPair)), 3, 2), IntToNumStr(Result, SHEX, 4)]));
  end;
  StepDone;
end;

procedure TProcessor.SetDataReg;
begin
  StepWait;
  Registers.DataRegisters[DataReg] := Value;
  Vis.UpdateScheme(Registers);
  Vis.HighlightDataReg(DataReg);
  Vis.AddLog(Format('Запись в регистр %s; Значение: %sH;',
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
    Vis.UpdateScheme(Registers);
    Vis.HighlightRegPair(RegPair);
    Vis.AddLog(Format('Запись в регистровую пару %s; Значение: %sH;',
      [Copy(GetEnumName(TypeInfo(TRegPair), Ord(RegPair)), 3, 2), IntToNumStr(Value, SHEX, 4)]));
  end;
  StepDone;
end;

function TProcessor.GetStackPointer;
begin
  StepWait;
  Result := Registers.SP;
  Vis.HighlightStackPointer;
  Vis.AddLog(Format('Чтение указателя стека; Значение: %sH;', [IntToNumStr(Result, SHEX, 4)]));
  StepDone;
end;

function TProcessor.GetProgramCounter;
begin
  StepWait;
  Result := Registers.PC;
  Vis.HighlightProgramCounter;
  Vis.AddLog(Format('Чтение счетчика команд; Значение: %sH;', [IntToNumStr(Result, SHEX, 4)]));
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
  Vis.UpdateScheme(Registers);
  Vis.HighlightStackPointer;
  Vis.AddLog(Format('Установка указателя стека; Значение: %sH;', [IntToNumStr(Value, SHEX, 4)]));
  StepDone;
end;

procedure TProcessor.SetProgramCounter;
begin
  StepWait;
  Registers.PC := Value;
  Vis.UpdateScheme(Registers);
  Vis.HighlightProgramCounter;
  Vis.AddLog(Format('Установка счетчика команд; Значение: %sH;', [IntToNumStr(Value, SHEX, 4)]));
  StepDone;
end;

procedure TProcessor.SetInstRegister;
begin
  StepWait;
  Registers.IR := Value;
  Vis.UpdateScheme(Registers);
  Vis.HighlightInstrRegister;
  Vis.AddLog(Format('Установка регистра команд; Значение: %sH;', [IntToNumStr(Value, SHEX, 2)]));
  StepDone;
end;

function TProcessor.GetFlag;
var
  Shift: Byte;
begin
  StepWait;
  //Определяем бит
  case FlagName of
    FS:  Shift := 7;
    FZ:  Shift := 6;
    FP:  Shift := 2;
    FAC: Shift := 4;
    FCY: Shift := 0;
  end;
  //Считываем бит
  with Registers do
    Result := (DataRegisters[RF] shr Shift) and 1;
  Vis.UpdateScheme(Registers);
  Vis.HighlightFlag(FlagName);
  Vis.AddLog(Format('Проверка флага %s; Состояние: %s;',
    [Copy(GetEnumName(TypeInfo(TFlag), Ord(FlagName)), 2, 2), IntToStr(Result)]));
  StepDone;
end;

procedure TProcessor.SetFlag;
var
  Shift: Byte;
begin
  StepWait;
  //Определяем бит
  case FlagName of
    FS:  Shift := 7;
    FZ:  Shift := 6;
    FP:  Shift := 2;
    FAC: Shift := 4;
    FCY: Shift := 0;
  end;
  //Меняем бит
  with Registers do
    if Value = 1 then
      DataRegisters[RF] := DataRegisters[RF] or (1 shl Shift)
    else
      DataRegisters[RF] := DataRegisters[RF] and not (1 shl Shift);
  Vis.UpdateScheme(Registers);
  Vis.HighlightFlag(FlagName);
  Vis.AddLog(Format('Установка флага %s; Состояние: %s;',
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
  //Очищаем лог и показываем начальные значения регистров
  Vis.ClearLog;
  Vis.UpdateScheme(Registers);
  //Пока не получили HLT или команду на уничтожение потока - читаем команды
  repeat
    //Очищаем хайлайты на схеме и памяти
    Vis.UnhighlightScheme;
    Vis.UnhighlightMemory;
    //Обновляем лог
    Vis.AddLog('ВЫБОРКА КОМАНДЫ:');
    //Если есть объект синхронизации потока - ждём его
    CmdWait;
    //Читаем первый байт инструкции
    CurrentAddr := GetProgramCounter;
    B1 := GetMemory(CurrentAddr);
    //Ищем инструкцию в матрице
    CurrentInstr := InstrSet.FindByCode(B1);
    if not Assigned(CurrentInstr) then
      CurrentInstr := InstrSet.FindByCode(B1, True);
    //Инструкция найдена
    if Assigned(CurrentInstr) then
    begin
      //Устанавливаем регистр команд
      SetInstRegister(B1);
      //Пишем в лог информацию о команде
      Vis.AddLog(CurrentInstr.Summary(B1));
      //Читаем второй и третий байт инструкции (если есть)
      if CurrentInstr.Size > 1 then
      begin
        B2 := GetMemory(CurrentAddr + 1);
        SetDataReg(RZ, B2);
        if CurrentInstr.Size > 2 then
        begin
          B3 := GetMemory(CurrentAddr + 2);
          SetDataReg(RW, B3);
        end
      end;
      //Устанавливаем счетчик команд
      SetProgramCounter(CurrentAddr + CurrentInstr.Size);
      //Исполняем команду
      ExecuteCommand(CurrentInstr, B1, B2, B3);
      //Разделитель в лог
      Vis.AddLog(LOG_LINE);
      //Сбрасываем объект синхронизации потока
      CmdDone;
    end;
  until HltState or Terminated;
  //Сбрасываем хайлайты
  Vis.UnhighlightScheme;
  Vis.UnhighlightALU;
  Vis.UnhighlightMemory;
  //Посылаем главной форме сообщение для разблокировки контролов
  SendMessage(Application.MainForm.Handle, WM_CONTROLS, 1, 0);
end;

procedure TProcessor.ExecuteCommand;
begin
  StepWait;
  Vis.HighlightInstrRegister;
  Vis.HighlightDecoder;
  Vis.AddLog('ИСПОЛНЕНИЕ КОМАНДЫ:');
  StepDone;
  //Выбор типа команды
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
    //Пересылки
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
    //Обмены
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
    //Специальные обмены
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
    //Команды работы со стеком
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
    //Сложение
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
    //Вычитание
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
    //Инкремент/декремент
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
    //Двоичная логика
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
    //Сдвиг
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
    //Специальные операции
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
                        SetMemory(CurrentSP - 1, Hi(CurrentPC));
                        SetMemory(CurrentSP - 2, Lo(CurrentPC));
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
