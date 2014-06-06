unit InstructionSet;

interface

uses
  System.SysUtils, System.Generics.Collections, Classes, Common;

type
  TInstrClass = (ICSystem, ICData, ICStack, ICArithm, ICLogic, ICBranch);
  TInstrFormat = (IFOnly, IFRegCenter, IFRegEnd, IFRegDouble, IfRegPair);
  TInstruction = class
  public
    Code: Byte;
    Group: TInstrClass;
    Size: Byte;
    Format: TInstrFormat;
    Mnemonic: String;
    Description: String;
    constructor Create
      (Code: Byte; Group: TInstrClass; Size: Byte; Format: TInstrFormat; Mnemonic: String; Description: String = '');
    function Mask: String;
    function MainCode(Op1: String = ''; Op2: String = ''): String;
    function FullCode(Op1: String = ''; Op2: String = ''): String;
  end;
  TInstructionSet = class
  public
    List: TList<TInstruction>;
    constructor Create;
    procedure Add
      (Code: Byte; Group: TInstrClass; Size: Byte; Format: TInstrFormat; Mnemonic: String; Description: String = '');
    function FindByCode(Code: Byte): TInstruction;
    function FindByMask(Mask: String): TInstruction;
    function FindByMnemonic(Mnemonic: String): TInstruction;
  end;

var
  InstrSet: TInstructionSet;

implementation

function Masked(Value, Mask: String): Boolean;
var
  Index: Byte;
begin
  Result := True;
  for Index := 1 to 8 do
    if Value[Index] <> Mask[Index] then
      if not (Mask[Index] in ['D', 'S', 'R', 'P']) then
        Result := False;
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
    if CurrentInstr.Code = Code then
    begin
      Result := CurrentInstr;
      Break;
    end;
end;

function TInstructionSet.FindByMask;
var
  CurrentInstr: TInstruction;
begin
  Result := nil;
  for CurrentInstr in List do
    if Masked(Mask, CurrentInstr.Mask) then
    begin
      Result := CurrentInstr;
      Break;
    end;
end;

function TInstructionSet.FindByMnemonic(Mnemonic: String): TInstruction;
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

{ TInstruction }

constructor TInstruction.Create;
begin
  Self.Code := Code;
  Self.Group := Group;
  Self.Size :=Size;
  Self.Format := Format;
  Self.Mnemonic := Mnemonic;
  Self.Description := Description;
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
  end;
end;

function TInstruction.MainCode(Op1, Op2: String): String;
var
  s1: string;
begin
  case Format of
    IFOnly:       Result := Mask;
    IFRegCenter:  Result := StringReplace(Mask, 'DDD', FormatAddrCode(Op1), []);
    IFRegEnd:     Result := StringReplace(Mask, 'SSS', FormatAddrCode(Op1), []);
    IFRegDouble:  Result := StringReplace(StringReplace(Mask, 'DDD', FormatAddrCode(Op1), []), 'SSS', FormatAddrCode(Op2), []);
    IFRegPair:    Result := StringReplace(Mask, 'RP', FormatAddrCode(Op1, True), []);
  end;
end;

function TInstruction.FullCode(Op1, Op2: String): String;
var
  Op: String;
begin
  case Size of
    1: Result := MainCode(Op1, Op2);
    2: if Format = IFOnly then
         Result := MainCode(Op1, Op2) + ConvertNumStrAuto(Op1, SBIN, 8)
       else
         Result := MainCode(Op1, Op2) + ConvertNumStrAuto(Op2, SBIN, 8);
    3: if Format = IFOnly then
         Result := MainCode(Op1, Op2) + ConvertNumStrAuto(Op1, SBIN, 16)
       else
         Result := MainCode(Op1, Op2) + ConvertNumStrAuto(Op2, SBIN, 16);
    //16 БИТ НУЖНО В ОБРАТНОМ ПОРЯДКЕ!!!
  end;
end;

initialization

InstrSet := TInstructionSet.Create;
with InstrSet do
begin
  //Команды управления микропроцессором
  Add($0,   ICSystem,     1, IFOnly,      'NOP'   );
  Add($76,  ICSystem,     1, IFOnly,      'HLT'   );
  //Команды пересылки данных
  Add($40,  ICData,       1, IFRegDouble, 'MOV'   );
  Add($06,  ICData,       2, IFRegCenter, 'MVI'   );
  Add($01,  ICData,       3, IFRegPair,   'LXI'   );
  Add($01,  ICData,       3, IFOnly,      'LDA'   );
  Add($01,  ICData,       3, IFOnly,      'STA'   );
  Add($01,  ICData,       1, IFRegPair,   'LDAX'  );
  Add($01,  ICData,       1, IFRegPair,   'STAX'  );
  Add($01,  ICData,       3, IFOnly,      'LHLD'  );
  Add($01,  ICData,       3, IFOnly,      'SHLD'  );
  Add($01,  ICData,       1, IFOnly,      'XCHG'  );
end;

end.
