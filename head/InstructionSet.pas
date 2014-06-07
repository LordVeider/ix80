unit InstructionSet;

interface

uses
  System.SysUtils, System.Generics.Collections, Classes, Common;

type
  TFlag = (FS, FZ, FAC, FP, FCY);
  TDataReg = (RB, RC, RD, RE, RH, RL, RM, RA, RW, RZ, RF);
  TRegPair = (RPBC, RPDE, RPHL, RPSP, RPSW);

  TInstrClass = (ICSystem, ICData, ICStack, ICArithm, ICLogic, ICControl, ICBranch);
  TInstrFormat = (IFOnly, IFRegCenter, IFRegEnd, IFRegDouble, IFRegPair, IFCondition);

  TInstruction = class
  private
    function Mask: String;
  public
    Code: Byte;
    Group: TInstrClass;
    Size: Byte;
    Format: TInstrFormat;
    Mnemonic: String;
    Description: String;
    constructor Create
      (Code: Byte; Group: TInstrClass; Size: Byte; Format: TInstrFormat; Mnemonic: String; Description: String = '');
    function MainCode(Op1: String = ''; Op2: String = ''): String;
    function FullCode(Op1: String = ''; Op2: String = ''): String;
    function Summary: String;
    function ExReg(Code: Byte; Tail: Boolean): TDataReg;
    function ExPair(Code: Byte): TRegPair;
  end;

  TInstructionSet = class
  public
    List: TList<TInstruction>;
    constructor Create;
    procedure Add
      (Code: Byte; Group: TInstrClass; Size: Byte; Format: TInstrFormat; Mnemonic: String; Description: String = '');
    function FindByCode(Code: Byte; Masked: Boolean = False): TInstruction;
    function FindByMnemonic(Mnemonic: String; Masked: Boolean = False): TInstruction;
  end;

var
  InstrSet: TInstructionSet;

implementation

function FormatRegister(Value: String): String;
begin
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

function FormatPair(Value: String): String;
begin
  case Value[1] of
    'B': Result := '00';
    'D': Result := '01';
    'H': Result := '10';
    else if (Value = 'PSW') or (Value = 'SP') then
      Result := '11';
  end;
end;

function FormatCondition(Value: String): String;
begin
  if      Value = 'NZ'  then Result := '000'
  else if Value = 'Z'   then Result := '001'
  else if Value = 'NC'  then Result := '010'
  else if Value = 'C'   then Result := '011'
  else if Value = 'PO'  then Result := '100'
  else if Value = 'PE'  then Result := '101'
  else if Value = 'P'   then Result := '110'
  else if Value = 'M'   then Result := '111';
end;

function MaskCompare(Value, Mask: String): Boolean;
var
  Index: Byte;
begin
  Result := True;
  for Index := 1 to 8 do
    if Value[Index] <> Mask[Index] then
      if not (Mask[Index] in ['D', 'S', 'R', 'P', 'C']) then
        Result := False;
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

function TInstruction.MainCode(Op1, Op2: String): String;
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

function TInstruction.FullCode(Op1, Op2: String): String;
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

function TInstruction.Summary: String;
begin
  Result := 'Команда: ' + Mnemonic + ' - ' + Description;
end;

function TInstruction.ExReg;
begin
  if not Tail then
    Code := Code shr 3;
  Code := Code shl 5;
  Code := Code shr 5;
  Result := TDataReg(Code);
end;

function TInstruction.ExPair;
begin
  Code := Code shl 2;
  Code := Code shr 6;
  Result := TRegPair(Code);
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
    if CurrentInstr.Mnemonic = Mnemonic then
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
  Add($00,  ICSystem,     1, IFOnly,      'NOP'   );
  Add($76,  ICSystem,     1, IFOnly,      'HLT'   );
  //Команды пересылки данных
  Add($40,  ICData,       1, IFRegDouble, 'MOV'   );
  Add($06,  ICData,       2, IFRegCenter, 'MVI',  'Непосредственная загрузка числа в регистр'   );
  Add($01,  ICData,       3, IFRegPair,   'LXI'   );
  Add($3A,  ICData,       3, IFOnly,      'LDA'   );
  Add($32,  ICData,       3, IFOnly,      'STA'   );
  Add($0A,  ICData,       1, IFRegPair,   'LDAX'  );
  Add($02,  ICData,       1, IFRegPair,   'STAX'  );
  Add($2A,  ICData,       3, IFOnly,      'LHLD'  );
  Add($22,  ICData,       3, IFOnly,      'SHLD'  );
  Add($EB,  ICData,       1, IFOnly,      'XCHG'  );
  //Команды работы со стеком
  Add($C1,  ICStack,      1, IFRegPair,   'POP'   );
  Add($C5,  ICStack,      1, IFRegPair,   'PUSH'  );
  Add($F9,  ICStack,      1, IFOnly,      'SPHL'  );
  Add($E3,  ICStack,      1, IFOnly,      'XTHL'  );
  //Арифметические команды
  //Сложение
  Add($80,  ICArithm,     1, IFRegEnd,    'ADD'   );
  Add($88,  ICArithm,     1, IFRegEnd,    'ADC'   );
  Add($C6,  ICArithm,     2, IFOnly,      'ADI'   );
  Add($CE,  ICArithm,     2, IFOnly,      'ACI'   );
  //Вычитание
  Add($90,  ICArithm,     1, IFRegEnd,    'SUB'   );
  Add($98,  ICArithm,     1, IFRegEnd,    'SBB'   );
  Add($D6,  ICArithm,     2, IFOnly,      'SUI'   );
  Add($DE,  ICArithm,     2, IFOnly,      'SBI'   );
  //Инкремент/декремент
  Add($04,  ICArithm,     1, IFRegCenter, 'INR'   );
  Add($05,  ICArithm,     1, IFRegCenter, 'DCR'   );
  Add($03,  ICArithm,     1, IFRegPair,   'INX'   );
  Add($0B,  ICArithm,     1, IFRegPair,   'DCX'   );
  //Специальные операции
  Add($09,  ICArithm,     1, IFRegPair,   'DAD'   );
  Add($27,  ICArithm,     1, IFOnly,      'DAA'   );
  //Логические команды
  //Двоичная логика
  Add($A0,  ICLogic,      1, IFRegEnd,    'ANA'   );
  Add($B0,  ICLogic,      1, IFRegEnd,    'ORA'   );
  Add($A8,  ICLogic,      1, IFRegEnd,    'XRA'   );
  Add($E6,  ICLogic,      2, IFOnly,      'ANI'   );
  Add($F6,  ICLogic,      2, IFOnly,      'ORI'   );
  Add($EE,  ICLogic,      2, IFOnly,      'XRI'   );
  //Сравнение
  Add($B8,  ICLogic,      1, IFRegEnd,    'CMP'   );
  Add($FE,  ICLogic,      2, IFOnly,      'CPI'   );
  //Сдвиг
  Add($07,  ICLogic,      1, IFOnly,      'RLC'   );
  Add($0F,  ICLogic,      1, IFOnly,      'RRC'   );
  Add($17,  ICLogic,      1, IFOnly,      'RAL'   );
  Add($1F,  ICLogic,      1, IFOnly,      'RAR'   );
  //Специальные операции
  Add($2F,  ICLogic,      1, IFOnly,      'CMA'   );
  Add($3F,  ICLogic,      1, IFOnly,      'CMC'   );
  Add($37,  ICLogic,      1, IFOnly,      'STC'   );
  //Команды переходов и передачи управления
  //Безусловные переходы
  Add($C3,  ICControl,    3, IFOnly,      'JMP'   );
  Add($CD,  ICControl,    3, IFOnly,      'CALL'  );
  Add($C9,  ICControl,    1, IFOnly,      'RET'   );
  Add($C7,  ICControl,    1, IFOnly,      'RST'   );
  Add($E9,  ICControl,    1, IFOnly,      'PCHL'  );
  //Условные переходы
  //Добавим позже
end;

end.
