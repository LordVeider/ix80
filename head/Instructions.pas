unit Instructions;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//Система команд микропроцессора

interface

uses
  Common, Typelib,
  Classes, TypInfo, System.SysUtils, System.Generics.Collections;

type
  TInstruction = class                                                          //Инструкция
  private
    function Mask: String;                                                      //Маска кода инструкции
  public
    Code: Byte;                                                                 //Уникальный код
    Group: TInstrGroup;                                                         //Группа
    Size: Byte;                                                                 //Размер в байтах
    Format: TInstrFormat;                                                       //Формат
    Mnemonic: String;                                                           //Мнемоника
    Description: String;                                                        //Описание
    constructor Create
      (Code: Byte; Group: TInstrGroup; Size: Byte; Format: TInstrFormat; Mnemonic: String; Description: String = '');
    function MainCode(Op1: String = ''; Op2: String = ''): String;              //Двоичный код первого байта
    function FullCode(Op1: String = ''; Op2: String = ''): String;              //Двоичный код всей команды
    function Summary: String;                                                   //Сводная информация
    function ExReg(Code: Byte; Second: Boolean = False): TDataReg;              //Извлечь двоичный код регистра
    function ExPair(Code: Byte): TRegPair;                                      //Извлечь двоичный код регистровой пары
    function ExCond(Code: Byte): TCondition;                                    //Извлечь двоичный код состояния
  end;

  TInstructionSet = class                                                       //Набор инструкций
  public
    List: TList<TInstruction>;                                                  //Список инструкций
    constructor Create;
    procedure Add
      (Code: Byte; Group: TInstrGroup; Size: Byte; Format: TInstrFormat; Mnemonic: String; Description: String = '');
    function FindByCode(Code: Byte; Masked: Boolean = False): TInstruction;                 //Поиск по коду или маске
    function FindByMnemonic(Mnemonic: String; Conditioned: Boolean = False): TInstruction;  //Поиск по мнемонике
  end;

var
  InstrSet: TInstructionSet;                                                    //Набор инструкций - глобальная переменная

implementation

function FormatRegister(Value: String): String;                                 //Двоичный код регистра из мнемоники
begin
  Result := '';
  case Value[1] of
    'B': Result := '000';
    'C': Result := '001';
    'D': Result := '010';
    'E': Result := '011';
    'H': Result := '100';
    'L': Result := '101';
    'M': Result := '110';
    'A': Result := '111';
  end;
end;

function FormatPair(Value: String): String;                                     //Двоичный код регистровой пары из мнемоники
begin
  Result := '';
  case Value[1] of
    'B': Result := '00';
    'D': Result := '01';
    'H': Result := '10';
    else if (Value = 'PSW') or (Value = 'SP') then
      Result := '11';
  end;
end;

function FormatCondition(Value: String): String;                                //Двоичный код состояния из мнемоники
var
  CurCond: TCondition;
begin
  Result := '';
  for CurCond := Low(TCondition) to High(TCondition) do
    if 'FC' + Value = GetEnumName(TypeInfo(TCondition), Ord(CurCond)) then
    begin
      Result := IntToNumStr(Byte(CurCond), SBIN, 3);
      break;
    end;
end;

function MaskCompare(Value, Mask: String): Boolean;                             //Сравнение двоичного кода по маске
var
  Index: Byte;
begin
  Result := True;
  for Index := 1 to 8 do
    if Value[Index] <> Mask[Index] then
      if not (Mask[Index] in ['D', 'S', 'R', 'P', 'C']) then
        Result := False;
end;

function ConditionCompare(Value, Mask: String): Boolean;                        //Сравнение мнемоники по маске состояний
begin
  Result := False;
  if Value[1] = Mask[1] then
    if FormatCondition(Copy(Value, 2, Value.Length - 1)) <> '' then
      Result := True;
end;

{ TInstruction }

constructor TInstruction.Create;
begin
  Self.Code         := Code;
  Self.Group        := Group;
  Self.Size         := Size;
  Self.Format       := Format;
  Self.Mnemonic     := Mnemonic;
  Self.Description  := Description;
end;

function TInstruction.Mask: String;
var
  BinStr: String;
begin
  BinStr := IntToNumStr(Code, SBIN, 8);
  case Format of
    IFOnly:       Result := BinStr;
    IFRegCenter:  Result := Copy(BinStr, 1, 2) + 'DDD' + Copy(BinStr, 6, 3);
    IFRegEnd:     Result := Copy(BinStr, 1, 5) + 'SSS';
    IFRegDouble:  Result := Copy(BinStr, 1, 2) + 'DDD' + 'SSS';
    IFRegPair:    Result := Copy(BinStr, 1, 2) + 'RP' + Copy(BinStr, 5, 4);
    IFCondition:  Result := Copy(BinStr, 1, 2) + 'CCC' + Copy(BinStr, 6, 3);
  end;
end;

function TInstruction.MainCode;
begin
  case Format of
    IFOnly:       Result := Mask;
    IFRegCenter:  Result := StringReplace(Mask, 'DDD', FormatRegister(Op1), []);
    IFRegEnd:     Result := StringReplace(Mask, 'SSS', FormatRegister(Op1), []);
    IFRegDouble:  Result := StringReplace(Mask, 'DDDSSS', FormatRegister(Op1) + FormatRegister(Op2), []);
    IFRegPair:    Result := StringReplace(Mask, 'RP', FormatPair(Op1), []);
    IFCondition:  Result := StringReplace(Mask, 'CCC', FormatCondition(Op1), []);
  end;
end;

function TInstruction.FullCode;
var
  Op: String;
begin
  if Size = 1 then
    Result := MainCode(Op1, Op2)
  else begin
    if Format = IFOnly then Op := Op1 else Op := Op2;
    if Size = 2 then
      Result := MainCode(Op1, Op2) + ConvertNumStrAuto(Op, SBIN, 8)
    else if Size = 3 then
      Result := MainCode(Op1, Op2) +  SwapBytes(ConvertNumStrAuto(Op, SBIN, 16));
  end;
end;

function TInstruction.Summary;
const
  F_SUMMARY = 'КОМАНДА %s: %s (группа: %s, размер: %d байт)';
var
  GroupText, FormatBase: String;
begin
  case Group of
    IGSystem:   GroupText := 'системные команды';
    IGData:     GroupText := 'команды пересылки';
    IGArithm:   GroupText := 'арифметические операции';
    IGLogic:    GroupText := 'логические операции';
    IGBranch:   GroupText := 'команды переходов';
  end;
  //Result := 'Команда: ' + Mnemonic + ' - ' + Description;
  Result := System.SysUtils.Format(F_SUMMARY, [Mnemonic, Description, GroupText, Size]);
end;

function TInstruction.ExReg;
begin
  if (Format = IFRegEnd) or (Second = True) then Code := Code shl 5
  else Code := Code shl 2;
  Code := Code shr 5;
  Result := TDataReg(Code);
end;

function TInstruction.ExPair;
begin
  Code := Code shl 2;
  Code := Code shr 6;
  Result := TRegPair(Code);
end;

function TInstruction.ExCond;
begin
  Code := Code shl 2;
  Code := Code shr 5;
  Result := TCondition(Code);
end;

{ TInstructionSet }

constructor TInstructionSet.Create;
begin
  List := TList<TInstruction>.Create;
end;

procedure TInstructionSet.Add;
var
  Instr: TInstruction;
begin
  Instr := TInstruction.Create(Code, Group, Size, Format, Mnemonic, Description);
  List.Add(Instr);
end;

function TInstructionSet.FindByCode;
var
  CurrentInstr: TInstruction;
begin
  Result := nil;
  for CurrentInstr in List do
    if (CurrentInstr.Code = Code)
    or (Masked and MaskCompare(IntToNumStr(Code, SBIN, 8), CurrentInstr.Mask)) then
    begin
      Result := CurrentInstr;
      Break;
    end;
end;

function TInstructionSet.FindByMnemonic;
var
  CurrentInstr: TInstruction;
begin
  Result := nil;
  for CurrentInstr in List do
    if (CurrentInstr.Mnemonic = Mnemonic)
    or (Conditioned and (CurrentInstr.Format = IFCondition) and ConditionCompare(Mnemonic, CurrentInstr.Mnemonic)) then
    begin
      Result := CurrentInstr;
      Break;
    end;
end;

initialization

InstrSet := TInstructionSet.Create;
with InstrSet do
begin
  //Команды управления микропроцессором
  Add($00,  IGSystem,     1, IFOnly,      'NOP',  'Нет операции'                                                            );
  Add($76,  IGSystem,     1, IFOnly,      'HLT',  'Останов'                                                                 );

  //Команды управления данными
  //Пересылки
  Add($40,  IGData,       1, IFRegDouble, 'MOV',  'Межрегистровая пересылка'                                                );
  Add($06,  IGData,       2, IFRegCenter, 'MVI',  'Непосредственная загрузка регистра'                                      );
  Add($01,  IGData,       3, IFRegPair,   'LXI',  'Непосредственная загрузка регистровой пары'                              );
  Add($3A,  IGData,       3, IFOnly,      'LDA',  'Загрузка аккумулятора из памяти (прямая адресация)'                      );
  Add($32,  IGData,       3, IFOnly,      'STA',  'Сохранение аккумулятора в память (прямая адресация)'                     );
  Add($0A,  IGData,       1, IFRegPair,   'LDAX', 'Загрузка аккумулятора из памяти (косвенная адресация)'                   );
  Add($02,  IGData,       1, IFRegPair,   'STAX', 'Сохранение аккумулятора в память (косвенная адресация)'                  );
  //Обмены
  Add($2A,  IGData,       3, IFOnly,      'LHLD', 'Загрузка регистровой пары HL из памяти'                                  );
  Add($22,  IGData,       3, IFOnly,      'SHLD', 'Сохранение регистровой пары HL в память'                                 );
  Add($EB,  IGData,       1, IFOnly,      'XCHG', 'Обмен регистровых пар DE и HL'                                           );
  //Специальные обмены
  Add($E9,  IGData,       1, IFOnly,      'PCHL', 'Загрузка счетчика команд из регистровой пары HL'                         );
  Add($F9,  IGData,       1, IFOnly,      'SPHL', 'Загрука указателя стека из регистровой пары HL'                          );
  Add($E3,  IGData,       1, IFOnly,      'XTHL', 'Обмен вершины стека с регистровой парой HL'                              );
  //Команды работы со стеком
  Add($C1,  IGData,       1, IFRegPair,   'POP',  'Загрузка регистровой пары из стека'                                      );
  Add($C5,  IGData,       1, IFRegPair,   'PUSH', 'Сохранение регистровой пары в стек'                                      );

  //Арифметические команды
  //Сложение
  Add($80,  IGArithm,     1, IFRegEnd,    'ADD',  'Сложение с регистром'                                                    );
  Add($88,  IGArithm,     1, IFRegEnd,    'ADC',  'Сложение с регистром (с учетом переноса)'                                );
  Add($C6,  IGArithm,     2, IFOnly,      'ADI',  'Сложение с непосредственным операндом'                                   );
  Add($CE,  IGArithm,     2, IFOnly,      'ACI',  'Сложение с непосредственным операндом (с учетом переноса)'               );
  //Вычитание
  Add($90,  IGArithm,     1, IFRegEnd,    'SUB',  'Вычитание регистра'                                                      );
  Add($98,  IGArithm,     1, IFRegEnd,    'SBB',  'Вычитание регистра (с учетом заема)'                                     );
  Add($D6,  IGArithm,     2, IFOnly,      'SUI',  'Вычитание непосредственного операнда'                                    );
  Add($DE,  IGArithm,     2, IFOnly,      'SBI',  'Вычитание непосредственного операнда (с учетом заема)'                   );
  //Инкремент/декремент
  Add($04,  IGArithm,     1, IFRegCenter, 'INR',  'Инкремент регистра'                                                      );
  Add($05,  IGArithm,     1, IFRegCenter, 'DCR',  'Декремент регистра'                                                      );
  Add($03,  IGArithm,     1, IFRegPair,   'INX',  'Инкремент регистровой пары'                                              );
  Add($0B,  IGArithm,     1, IFRegPair,   'DCX',  'Декремент регистровой пары'                                              );
  //Специальные операции
  Add($09,  IGArithm,     1, IFRegPair,   'DAD',  'Двойное сложение регистровых пар'                                        );
  Add($27,  IGArithm,     1, IFOnly,      'DAA',  'Двоично-десятичная (BCD) коррекция аккумулятора'                         );

  //Логические команды
  //Двоичная логика
  Add($A0,  IGLogic,      1, IFRegEnd,    'ANA',  'Логическое "И" с регистром'                                              );
  Add($B0,  IGLogic,      1, IFRegEnd,    'ORA',  'Логическое "ИЛИ" с регистром'                                            );
  Add($A8,  IGLogic,      1, IFRegEnd,    'XRA',  'Логическое "Исключающее ИЛИ" с регистром'                                );
  Add($E6,  IGLogic,      2, IFOnly,      'ANI',  'Логическое "И" с непосредственным операндом'                             );
  Add($F6,  IGLogic,      2, IFOnly,      'ORI',  'Логическое "ИЛИ" с непосредственным операндом'                           );
  Add($EE,  IGLogic,      2, IFOnly,      'XRI',  'Логическое "Исключающее ИЛИ" с непосредственным операндом'               );
  //Сравнение
  Add($B8,  IGLogic,      1, IFRegEnd,    'CMP',  'Сравнение с регистром'                                                   );
  Add($FE,  IGLogic,      2, IFOnly,      'CPI',  'Сравнение с непосредственным операндом'                                  );
  //Сдвиг
  Add($07,  IGLogic,      1, IFOnly,      'RLC',  'Сдвиг аккумулятора влево'                                                );
  Add($0F,  IGLogic,      1, IFOnly,      'RRC',  'Сдвиг аккумулятора вправо'                                               );
  Add($17,  IGLogic,      1, IFOnly,      'RAL',  'Сдвиг аккумулятора влево через флаг переноса'                            );
  Add($1F,  IGLogic,      1, IFOnly,      'RAR',  'Сдвиг аккумулятора вправо через флаг переноса'                           );
  //Специальные операции
  Add($2F,  IGLogic,      1, IFOnly,      'CMA',  'Инвертирование аккумулятора'                                             );
  Add($3F,  IGLogic,      1, IFOnly,      'CMC',  'Инвертирование флага переноса'                                           );
  Add($37,  IGLogic,      1, IFOnly,      'STC',  'Установка флага переноса'                                                );

  //Команды переходов и передачи управления
  //Безусловные переходы
  Add($C3,  IGBranch,     3, IFOnly,      'JMP',  'Безусловный переход'                                                     );
  Add($CD,  IGBranch,     3, IFOnly,      'CALL', 'Безусловный вызов подпрограммы'                                          );
  Add($C9,  IGBranch,     1, IFOnly,      'RET',  'Безусловный возврат из подпрограммы'                                     );
  //Условные переходы
  Add($C2,  IGBranch,     3, IFCondition, 'JCCC', 'Условный переход'                                                        );
  Add($C4,  IGBranch,     3, IFCondition, 'CCCC', 'Условный вызов подпрограммы'                                             );
  Add($C0,  IGBranch,     1, IFCondition, 'RCCC', 'Условный возврат из подпрограммы'                                        );
end;

end.
