unit Logic;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//Основная программная логика
//Процессор, память, система команд

interface

uses
  Common;

const
  CPU_STACK_SIZE    = 255;                  //Глубина стека ЦП
  CMD_DATA          = '#MOV#MVI#LXI#LDA#STA#LDAX#STAX#LHLD#SHLD#XCHG#SPHL#PUSH#POP#XTHL#';
  CMD_MATH          = '#ADD#ADC#ADI#ACI#INR#DAD#INX#DAA#SUB#SBB#SUI#SBI#DCR#DCX#CMP#CPI#ANA#ORA#XRA#ANI#ORI#XRI#CMA#RAL#RAR#RLC#RRC#';
  CMD_CTRL          = '#JMP#CALL#RET#PCHL#RST#JNC#JC#JNZ#JZ#JP#JM#JO#JPE#CNC#CC#CNZ#CZ#CP#CM#CO#CPE#RNC#RC#RNZ#RZ#RP#RM#RO#RPE#NOP#HLT#CTS#CMC#';

type
  TMemoryCell = record
    Command: Pointer;                       //Объект "команда" (для ячеек, содержащих команды)
    Numeric: Byte;                          //Цифровое содержимое ячейки памяти
  end;
  TMemoryCells = array [Word] of TMemoryCell;
  TMemory = class
  private
    Cells: TMemoryCells;                    //Массив данных
  public
    procedure ShowNewMem;                                                       //Отобразить содержимое памяти на экране
    procedure WriteMemoryObject(Address: Word; Value: TMemoryCell);             //Записать в память ячейку
    function ReadMemoryObject(Address: Word): TMemoryCell;                      //Считать из памяти ячейку
    procedure WriteMemory(Address: Word; Value: Byte);                          //Записать в память цифровое значение
    function ReadMemory(Address: Word): Byte;                                   //Считать из памяти цифровое значение
  end;

  TFlagsNames = (FS, FZ, FAC, FP, FC);
  TFlagsRegister = array [TFlagsNames] of Boolean;
  TDataRegistersNames = (RA, RB, RC, RD, RE, RH, RL, RW, RZ);
  TDataRegisters = array [TDataRegistersNames] of Byte;
  TRegisters = record
    DataRegisters: TDataRegisters;          //Регистры данных (8 bit)
    SP: Word;                               //Указатель стека (16 bit)
    PC: Word;                               //Счетчик команд (16 bit)
    PSW: TFlagsRegister;                    //Регистр признаков (8 bit)
    IR: Byte;                               //Регистр команд (8 bit)
  end;

  TProcessor = class
  private
    Memory: TMemory;                        //Память
    Registers: TRegisters;                  //Регистры
    procedure InitDataRegisters;            //Инициализация регистров
  public
    constructor Create(Memory: TMemory);
    procedure InitCpu(EntryPoint: Word);    //Инициализация процессора
    procedure Run;                          //Запустить выполнение
    procedure ShowRegisters;                //Отобразить содержимое регистров на экране
    function DataRegisterNameByTextName(Value: String): TDataRegistersNames;                  //Имя регистра по текстовому имени
    procedure SetDataRegister(DataRegisterName: TDataRegistersNames; Value: Byte);            //Установить значение регистра
    function GetDataRegister(DataRegisterName: TDataRegistersNames): Byte;                    //Получить значение регистра
    procedure SetDataRegisterPair(DataRegisterPairName: TDataRegistersNames; Value: Word);    //Установить значение регистровой пары
    function GetDataRegisterPair(DataRegisterPairName: TDataRegistersNames): Word;            //Получить значение регистровой пары
    //procedure GetRegisterAddresationValue(
    function GetStackPointer: Word;                                                           //Получить значение указателя стека
    function GetProgramCounter: Word;                                                         //Получить значение счетчика команд
    function GetInstructionRegister: Byte;                                                    //Получить значение регистра команд
    procedure SetFlag(FlagName: TFlagsNames; Value: Boolean);                                 //Установить флаг
    function GetFlag(FlagName: TFlagsNames): Boolean;                                         //Проверить состояние флага
  end;

  TAddresationType = (ATREG, ATMEM, ATADDR, ATD8, ATD16);

  TCommand = class                          //Команда (базовый класс)
  private
    Name: String;                           //Текстовое имя команды
    Op1, Op2: String;                       //Операнды в текстовом виде
    Description: String;                    //Краткое текстовое описание команды (для визуализации)
    FlagsCheck: TFlagsRegister;             //Проверяемые флаги
    FlagsSet: TFlagsRegister;               //Устанавливаемые флаги
    CommandCode: String;                    //Двоичный код команды
    function CaseAddresationType(Op: String): TAddresationType;                 //Выбор типа адресации из мнемоники оператора
  public
    constructor Create(Name: String; Op1, Op2: String);
    function ShowSummary: String;
    function Size: Integer;                                                     //Размер двоичного кода команды в байтах
    function WriteToMemory(Memory: TMemory; Address: Word): Word;               //Записать команду в память
    procedure Execute(Processor: TProcessor);                                   //Выполнить команду на процессоре
  end;

  TMathCommand = class(TCommand)            //Команды арифметики и логики
  public
    constructor Create(Name: String; Op1, Op2: String);
  end;
  TDataCommand = class(TCommand)            //Команды пересылки данных
  public
    constructor Create(Name: String; Op1, Op2: String);
    procedure Execute(Processor: TProcessor);
  end;
  TCtrlCommand = class(TCommand)            //Команды переходов и управления
  public
    constructor Create(Name: String; Op1, Op2: String);
  end;
  TCommandParser = class                    //Анализатор исходного кода
  public
    function ParseCommand(TextLine: String; var Command: TCommand): Boolean;    //Разбор текста команды
  end;

implementation

uses
  SysUtils, Dialogs, TypInfo, FormScheme;

{ TProcessor }

constructor TProcessor.Create(Memory: TMemory);
begin
  Self.Memory := Memory;
end;

procedure TProcessor.InitDataRegisters;
var
  i: byte;
begin
  with Registers do
  begin
    {A := 0;
    B := 0;
    C := 0;
    D := 0;
    E := 0;
    H := 0;
    L := 0;
    W := 0;
    Z := 0;}
    for i := 1 to 9 do
      DataRegisters[TDataRegistersNames(i)] := 0;
  end;
end;

function TProcessor.DataRegisterNameByTextName;
var
  CurReg: TDataRegistersNames;
begin
  //Преобразуем текстовое обозначение регистра в его обозначение из TDataRegistersNames
  for CurReg := Low(TDataRegistersNames) to High(TDataRegistersNames) do
    if 'R' + Value = GetEnumName(TypeInfo(TDataRegistersNames), Ord(CurReg)) then
      Result := CurReg;
end;

procedure TProcessor.SetDataRegister;
begin
  Registers.DataRegisters[DataRegisterName] := Value;
end;

function TProcessor.GetDataRegister;
begin
  Result := Registers.DataRegisters[DataRegisterName];
end;

procedure TProcessor.SetDataRegisterPair;
begin
  //Определяем регистровую пару и записываем отдельно старший и младший байты
  case DataRegisterPairName of
    RB: begin
         SetDataRegister(RB, Hi(Value));
         SetDataRegister(RC, Lo(Value));
       end;
    RD: begin
         SetDataRegister(RD, Hi(Value));
         SetDataRegister(RE, Lo(Value));
       end;
    RH: begin
         SetDataRegister(RH, Hi(Value));
         SetDataRegister(RL, Lo(Value));
       end;
  end;
end;

function TProcessor.GetDataRegisterPair;
begin
  //Определяем регистровую пару и преобразуем два байта в Word
  case DataRegisterPairName of
    RB: Result := GetDataRegister(RC) + (GetDataRegister(RB) shl 8);
    RD: Result := GetDataRegister(RE) + (GetDataRegister(RD) shl 8);
    RH: Result := GetDataRegister(RL) + (GetDataRegister(RH) shl 8);
  end;
end;

function TProcessor.GetStackPointer: Word;
begin
  Result := Registers.SP;
end;

function TProcessor.GetProgramCounter: Word;
begin
  Result := Registers.PC;
end;

function TProcessor.GetInstructionRegister: Byte;
begin
  Result := Registers.IR;
end;

procedure TProcessor.SetFlag(FlagName: TFlagsNames; Value: Boolean);
begin
  Registers.PSW[FlagName] := Value;
end;

function TProcessor.GetFlag(FlagName: TFlagsNames): Boolean;
begin
  Result := Registers.PSW[FlagName];
end;

procedure TProcessor.InitCpu(EntryPoint: Word);
begin
  InitDataRegisters;                //Инициализируем регистры данных
  Registers.PC := EntryPoint;       //Инициализируем счетчик команд на указанную точку входа
end;

procedure TProcessor.Run;
var
  bri: integer;
begin
  bri := 0;
  repeat
    if Assigned(Memory.Cells[Registers.PC].Command) then
      if TCommand(Memory.Cells[Registers.PC].Command) is TDataCommand then
        TDataCommand(Memory.Cells[Registers.PC].Command).Execute(Self);
    inc(bri);
  until (Memory.Cells[Registers.PC].Numeric = 0) or (bri > 50);

end;

procedure TProcessor.ShowRegisters;
begin
  frmScheme.DrawProcessor(Self);
end;

{ TMemory }

procedure TMemory.ShowNewMem;
begin
  frmScheme.DrawMemory(Self);
end;

procedure TMemory.WriteMemoryObject;
begin
  Cells[Address] := Value;
end;

function TMemory.ReadMemoryObject;
begin
  Result := Cells[Address];
end;

procedure TMemory.WriteMemory(Address: Word; Value: Byte);
begin
  Cells[Address].Numeric := Value;
end;

function TMemory.ReadMemory(Address: Word): Byte;
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
  CommandSize: Integer;
begin
  CommandSize := 0;
  //Записываем в память объект
  CurrentCell.Command := Self;
  Memory.WriteMemoryObject(Address, CurrentCell);
  //Записываем в память двоичный код команды
  repeat
    Memory.WriteMemory(Address + CommandSize, BinStringToByte(Copy(CommandCode, CommandSize*8 + 1, 8)));
    Inc(CommandSize);
  until CommandSize = Size;
  //Возвращаем следующий свободный адрес памяти
  Result := Address + CommandSize;
end;

function TCommand.CaseAddresationType(Op: String): TAddresationType;
begin
  if Op = 'M' then          //Indirect memory addresation
    Result := ATMEM
  else                      //Registry addresation
    Result := ATREG;
end;

procedure TCommand.Execute;
begin
  //
end;

function TCommand.Size: Integer;
begin
  Result := Length(CommandCode) div 8;
end;

function TCommand.ShowSummary: String;
begin
  Result := 'Command: #' + Name + '#, OP1: #' + Op1 + '#, OP2: #' + Op2 + '#, Code: #' + CommandCode + '#';
end;

{ TMathCommand }

constructor TMathCommand.Create(Name, Op1, Op2: String);
begin
  inherited;
  //Сложение
  if Name = 'ADD' then
    CommandCode := '10000' + AddresationCode(Op1)
  else if Name = 'ADI' then
    CommandCode := '11000110'
  else if Name = 'ADC' then
    CommandCode := '10001' + AddresationCode(Op1)
  else if Name = 'ACI' then
    CommandCode := '11001110'
  //Вычитание
  else if Name = 'SUB' then
    CommandCode := '10010' + AddresationCode(Op1)
  else if Name = 'SUI' then
    CommandCode := '11010110'
  else if Name = 'SBB' then
    CommandCode := '10011' + AddresationCode(Op1)
  else if Name = 'SBI' then
    CommandCode := '11011110'
  //Логические операции
  else if Name = 'ANA' then
    CommandCode := '10100' + AddresationCode(Op1)
  else if Name = 'ANI' then
    CommandCode := '11100110'
  else if Name = 'XRA' then
    CommandCode := '10101' + AddresationCode(Op1)
  else if Name = 'XRI' then
    CommandCode := '11101110'
  else if Name = 'ORA' then
    CommandCode := '10110' + AddresationCode(Op1)
  else if Name = 'ORI' then
    CommandCode := '11110110'
  //Сравнение
  else if Name = 'CMP' then
    CommandCode := '10111' + AddresationCode(Op1)
  else if Name = 'CPI' then
    CommandCode := '11111110'
  //Инкремент/декремент
  else if Name = 'INR' then
    CommandCode := '00' + AddresationCode(Op1) + '100'
  else if Name = 'INX' then
    CommandCode := '00' + AddresationCode(Op1, True) + '0011'
  else if Name = 'DCR' then
    CommandCode := '00' + AddresationCode(Op1) + '101'
  else if Name = 'DCX' then
    CommandCode := '00' + AddresationCode(Op1, True) + '1011';
end;

{ TDataCommand }

constructor TDataCommand.Create;
begin
  inherited;
  if Name = 'MOV' then
    CommandCode := '01' + AddresationCode(Op1) + AddresationCode(Op2)
  else if Name = 'MVI' then
    CommandCode := '00' + AddresationCode(Op1) + '110' + DirectData(Op2)
  else if Name = 'LXI' then
    CommandCode := '00' + AddresationCode(Op1, True) + '0001' + DirectData(Op2, True)
  else if Name = 'LDA' then
    CommandCode := '00111010' + MemoryPointer(Op1)
  else if Name = 'LHLD' then
    CommandCode := '00101010' + MemoryPointer(Op1)
  else if Name = 'LDAX' then
    CommandCode := '00' + AddresationCode(Op1, True) + '1010'
  else if Name = 'XCHG' then
    CommandCode := '11101011'
  else if Name = 'STA' then
    CommandCode := '00110010' + MemoryPointer(Op1)
  else if Name = 'SHLD' then
    CommandCode := '00100010' + MemoryPointer(Op1)
  else if Name = 'STAX' then
    CommandCode := '00' + AddresationCode(Op1, True) + '0010';
end;

procedure TDataCommand.Execute(Processor: TProcessor);
begin
  if Name = 'MVI' then
  begin
    if CaseAddresationType(Op1) = ATMEM then
      Processor.Memory.WriteMemory(Processor.GetDataRegisterPair(RH), StrToInt(Op2))
    else if CaseAddresationType(Op1) = ATREG then
      Processor.SetDataRegister(Processor.DataRegisterNameByTextName(Op1), StrToInt(Op2));
  end;
  {if Name = 'MOV' then
  begin
    if CaseAddresationType(Op1) = ATMEM then
      Processor.Memory.WriteMemory(Processor.GetDataRegisterPair(RH), StrToInt(Op2))
    else if CaseAddresationType(Op1) = ATREG then
      Processor.SetDataRegister(Processor.DataRegisterNameByTextName(Op1), StrToInt(Op2));
  end}
  Processor.Registers.PC := Processor.Registers.PC + Size;
end;

{ TCtrlCommand }

constructor TCtrlCommand.Create(Name, Op1, Op2: String);
begin
  inherited;
  if Name = 'HLT' then
    CommandCode := '01110110';
end;

{ TCommandParser }

function TCommandParser.ParseCommand;
var
  Cmd, Op1, Op2: String;
  NextDelimeter: Integer;
begin
  try
    Result := True;
    //Синтаксический анализ
    NextDelimeter := Pos(#32, TextLine);    //Ищем пробел в строке
    if NextDelimeter = 0 then               //Операндов нет
      Cmd := TextLine
    else                                    //Операнды есть
    begin
      Cmd := Copy(TextLine, 1, NextDelimeter - 1);
      Delete(TextLine, 1, NextDelimeter);
      NextDelimeter := Pos(#44, TextLine);  //Ищем запятую в строке
      if NextDelimeter = 0 then             //Операнд один
        Op1 := TextLine
      else                                  //Операндов два
      begin
        Op1 := Copy(TextLine, 1, NextDelimeter - 1);
        Delete(TextLine, 1, NextDelimeter + 1);
        Op2 := TextLine;
      end;
    end;
    //Семантический анализ
    if Pos(Cmd, CMD_DATA) > 0 then          //Команда пересылки
      Command := TDataCommand.Create(Cmd, Op1, Op2)
    else if Pos(Cmd, CMD_MATH) > 0 then     //Команда арифметики-логики
      Command := TMathCommand.Create(Cmd, Op1, Op2)
    else if Pos(Cmd, CMD_CTRL) > 0 then     //Команда перехода или управления
      Command := TCtrlCommand.Create(Cmd, Op1, Op2)
    else
      Result := False;                      //Ошибка в коде команды
   except
    Result := False;                        //Синтаксическая ошибка
  end;
end;

end.
