unit Logic;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//Основная программная логика
//Процессор, память, система команд

interface

uses
  Common;

const
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

  TFlagsNames = (FS, FZ, FAC, FP, FCY);
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
    HltState: Boolean;
    Memory: TMemory;                        //Память
    Registers: TRegisters;                  //Регистры
    procedure InitDataRegisters;            //Инициализация регистров
  public
    constructor Create(Memory: TMemory);
    procedure InitCpu(EntryPoint: Word);    //Инициализация процессора
    procedure Run;                          //Запустить выполнение
    procedure ShowRegisters;                //Отобразить содержимое регистров на экране
    procedure PerformALU(Value: Byte);      //Выполнить операцию на АЛУ
    procedure SetDataReg(DataRegName: TDataRegistersNames; Value: Byte);        //Установить значение регистра
    function GetDataReg(DataRegName: TDataRegistersNames): Byte;                //Получить значение регистра
    procedure SetDataRP(DataRPName: TDataRegistersNames; Value: Word);          //Установить значение регистровой пары
    function GetDataRP(DataRPName: TDataRegistersNames): Word;                  //Получить значение регистровой пары
    function DataRegNameByTextName(TextName: String): TDataRegistersNames;      //Имя регистра по текстовому имени
    procedure SetRegAddrValue(Operand: String; Value: Byte);                    //Получить значение по регистровой адресации
    function GetRegAddrValue(Operand: String): Byte;                            //Установить значение по регистровой адресации
    procedure SetStackPointer(Value: Word);                                      //Установить значение указателя стека
    function GetStackPointer: Word;                                             //Получить значение указателя стека
    function GetProgramCounter: Word;                                           //Получить значение счетчика команд
    function GetInstRegister: Byte;                                             //Получить значение регистра команд
    procedure SetFlag(FlagName: TFlagsNames; Value: Boolean = True);            //Установить флаг
    function GetFlag(FlagName: TFlagsNames): Boolean;                           //Получить состояние флага
  end;

  TCommand = class                          //Команда (базовый класс)
  private
    Name: String;                           //Текстовое имя команды
    Op1, Op2: String;                       //Операнды в текстовом виде
    Description: String;                    //Краткое текстовое описание команды (для визуализации)
    FlagsCheck: TFlagsRegister;             //Проверяемые флаги
    FlagsSet: TFlagsRegister;               //Устанавливаемые флаги
    CommandCode: String;                    //Двоичный код команды
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
    procedure Execute(Processor: TProcessor);
  end;
  TDataCommand = class(TCommand)            //Команды пересылки данных
  public
    constructor Create(Name: String; Op1, Op2: String);
    procedure Execute(Processor: TProcessor);
  end;
  TCtrlCommand = class(TCommand)            //Команды переходов и управления
  public
    constructor Create(Name: String; Op1, Op2: String);
    procedure Execute(Processor: TProcessor);
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

procedure TProcessor.PerformALU;
var
  Op1, Op2, Op3: String;
  i: Integer;
  NewBit: Byte;
  Carry, Parity: Byte;
begin
  Op1 := ByteToBinString(GetDataReg(RA));
  Op2 := ByteToBinString(Value);
  Op3 := '';
  Carry := 0;
  Parity := 0;
  for i := 8 downto 1 do
  begin
    //Считаем бит
    NewBit := StrToInt(Op1[i]) + StrToInt(Op2[i]) + Carry;
    //Если получили 2 - переносим
    if NewBit = 2 then
    begin
      Carry := 1;
      NewBit := 0;
    end
    else
      Carry := 0;
    //Считаем количество единиц
    if NewBit = 1 then
      Inc(Parity);
    //Конечный результат
    Op3 := IntToStr(NewBit) + Op3;
  end;
  //Выставляем флаги
  if Parity = 0 then                    //Нулевой результат
    SetFlag(FZ)
  else if Parity mod 2 = 0 then         //Четное количество единиц
    SetFlag(FP);
  if Carry = 1 then                     //Перенос из старшего разряда
    SetFlag(FCY);
  //Обновляем аккумулятор
  SetDataReg(RA,BinStringToByte(Op3));
end;

function TProcessor.DataRegNameByTextName;
var
  CurReg: TDataRegistersNames;
begin
  //Преобразуем текстовое обозначение регистра в его обозначение из TDataRegistersNames
  for CurReg := Low(TDataRegistersNames) to High(TDataRegistersNames) do
    if 'R' + TextName = GetEnumName(TypeInfo(TDataRegistersNames), Ord(CurReg)) then
      Result := CurReg;
end;

procedure TProcessor.SetRegAddrValue;
begin
  if Operand = 'M' then             //Косвенная адресация памяти
    Memory.WriteMemory(GetDataRP(RH), Value)
  else                              //Регистровая адресация
    SetDataReg(DataRegNameByTextName(Operand), Value);
end;

function TProcessor.GetRegAddrValue;
begin
  if Operand = 'M' then             //Косвенная адресация памяти
    Result := Memory.ReadMemory(GetDataRP(RH))
  else                              //Регистровая адресация
    Result := GetDataReg(DataRegNameByTextName(Operand));
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
  //Определяем регистровую пару и записываем отдельно старший и младший байты
  case DataRPName of
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
  //Определяем регистровую пару и преобразуем два байта в Word
  case DataRPName of
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

function TProcessor.GetInstRegister: Byte;
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
  HltState := False;
end;

procedure TProcessor.Run;
var
  s: string;
  c: integer;
begin
  repeat
    if Assigned(Memory.Cells[Registers.PC].Command) then
    begin
      c := Registers.PC;
      s := TCommand(Memory.Cells[Registers.PC].Command).ShowSummary;
      if TCommand(Memory.Cells[Registers.PC].Command) is TDataCommand then
        TDataCommand(Memory.Cells[Registers.PC].Command).Execute(Self)
      else if TCommand(Memory.Cells[Registers.PC].Command) is TMathCommand then
        TMathCommand(Memory.Cells[Registers.PC].Command).Execute(Self)
      else if TCommand(Memory.Cells[Registers.PC].Command) is TCtrlCommand then
        TCtrlCommand(Memory.Cells[Registers.PC].Command).Execute(Self)
    end;
  until HltState;
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

procedure TCommand.Execute;
begin
  Processor.Registers.PC := Processor.Registers.PC + Size;
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
    CommandCode := '10000' + FormatAddrCode(Op1)
  else if Name = 'ADI' then
    CommandCode := '11000110'
  else if Name = 'ADC' then
    CommandCode := '10001' + FormatAddrCode(Op1)
  else if Name = 'ACI' then
    CommandCode := '11001110'
  //Вычитание
  else if Name = 'SUB' then
    CommandCode := '10010' + FormatAddrCode(Op1)
  else if Name = 'SUI' then
    CommandCode := '11010110'
  else if Name = 'SBB' then
    CommandCode := '10011' + FormatAddrCode(Op1)
  else if Name = 'SBI' then
    CommandCode := '11011110'
  //Логические операции
  else if Name = 'ANA' then
    CommandCode := '10100' + FormatAddrCode(Op1)
  else if Name = 'ANI' then
    CommandCode := '11100110'
  else if Name = 'XRA' then
    CommandCode := '10101' + FormatAddrCode(Op1)
  else if Name = 'XRI' then
    CommandCode := '11101110'
  else if Name = 'ORA' then
    CommandCode := '10110' + FormatAddrCode(Op1)
  else if Name = 'ORI' then
    CommandCode := '11110110'
  //Сравнение
  else if Name = 'CMP' then
    CommandCode := '10111' + FormatAddrCode(Op1)
  else if Name = 'CPI' then
    CommandCode := '11111110'
  //Инкремент/декремент
  else if Name = 'INR' then
    CommandCode := '00' + FormatAddrCode(Op1) + '100'
  else if Name = 'INX' then
    CommandCode := '00' + FormatAddrCode(Op1, True) + '0011'
  else if Name = 'DCR' then
    CommandCode := '00' + FormatAddrCode(Op1) + '101'
  else if Name = 'DCX' then
    CommandCode := '00' + FormatAddrCode(Op1, True) + '1011';
end;

procedure TMathCommand.Execute(Processor: TProcessor);
begin
  with Processor do
  begin
    if Name = 'ADD' then
    begin
      PerformALU(GetRegAddrValue(Op1));
    end;
  end;
  inherited;
end;

{ TDataCommand }

constructor TDataCommand.Create;
begin
  inherited;
  if Name = 'MOV' then
    CommandCode := '01' + FormatAddrCode(Op1) + FormatAddrCode(Op2)
  else if Name = 'MVI' then
    CommandCode := '00' + FormatAddrCode(Op1) + '110' + FormatOperandByte(Op2, SBIN)
  else if Name = 'LXI' then
    CommandCode := '00' + FormatAddrCode(Op1, True) + '0001' + FormatOperandWord(Op2, SBIN)
  else if Name = 'LDA' then
    CommandCode := '00111010' + FormatOperandWord(Op1, SBIN)
  else if Name = 'LHLD' then
    CommandCode := '00101010' + FormatOperandWord(Op1, SBIN)
  else if Name = 'LDAX' then
    CommandCode := '00' + FormatAddrCode(Op1, True) + '1010'
  else if Name = 'XCHG' then
    CommandCode := '11101011'
  else if Name = 'STA' then
    CommandCode := '00110010' + FormatOperandWord(Op1, SBIN)
  else if Name = 'SHLD' then
    CommandCode := '00100010' + FormatOperandWord(Op1, SBIN)
  else if Name = 'STAX' then
    CommandCode := '00' + FormatAddrCode(Op1, True) + '0010'
  else if Name = 'SPHL' then
    CommandCode := '11111001'
  else if Name = 'XTHL' then
    CommandCode := '11100011';
end;

procedure TDataCommand.Execute;
begin
  with Processor do
  begin
    if Name = 'MOV' then
      SetRegAddrValue(Op1, GetRegAddrValue(Op2))
    else if Name = 'MVI' then
      SetRegAddrValue(Op1, StrToInt(FormatOperandByte(Op2, SDEC)))
    else if Name = 'LXI' then
      SetDataRP(DataRegNameByTextName(Op1), StrToInt(FormatOperandWord(Op2, SDEC)))
    else if Name = 'LDA' then
      SetDataReg(RA, Memory.ReadMemory(StrToInt(FormatOperandWord(Op1, SDEC))))
    else if Name = 'LDAX' then
      SetDataReg(RA, Memory.ReadMemory(GetDataRP(DataRegNameByTextName(Op1))))
    else if Name = 'STA' then
      Memory.WriteMemory(StrToInt(FormatOperandWord(Op1, SDEC)), GetDataReg(RA))
    else if Name = 'STAX' then
      Memory.WriteMemory(GetDataRP(DataRegNameByTextName(Op1)), GetDataReg(RA))
    else if Name = 'LHLD' then
    begin
      SetDataReg(RL, Memory.ReadMemory(StrToInt(FormatOperandWord(Op1, SDEC))));
      SetDataReg(RH, Memory.ReadMemory(StrToInt(FormatOperandWord(Op1, SDEC))+1));
    end
    else if Name = 'SHLD' then
    begin
      Memory.WriteMemory(StrToInt(FormatOperandWord(Op1, SDEC)), GetDataReg(RL));
      Memory.WriteMemory(StrToInt(FormatOperandWord(Op1, SDEC))+1, GetDataReg(RH));
    end
    else if Name = 'XCHG' then
    begin
      SetDataRP(RW, GetDataRP(RH));
      SetDataRP(RH, GetDataRP(RD));
      SetDataRP(RD, GetDataRP(RW));
    end
    else if Name = 'SPHL' then
      SetStackPointer(GetDataRP(RH))
    else if Name = 'XTHL' then
    begin
      SetDataRP(RW, GetDataRP(RH));
      SetDataReg(RH, Memory.ReadMemory(GetStackPointer));
      SetDataReg(RL, Memory.ReadMemory(GetStackPointer + 1));
      Memory.WriteMemory(GetStackPointer, GetDataReg(RW));
      Memory.WriteMemory(GetStackPointer + 1, GetDataReg(RZ));
     end;
  end;
  inherited;
end;

{ TCtrlCommand }

constructor TCtrlCommand.Create;
begin
  inherited;
  if Name = 'HLT' then
    CommandCode := '01110110';
end;

procedure TCtrlCommand.Execute;
begin
  if Name = 'HLT' then
    Processor.HltState := True;
  inherited;
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
