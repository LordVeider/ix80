unit InstructionSet;

interface

uses
  System.Generics.Collections, Classes, Common;

type
  TInstrSize = (ISSingle, ISDouble, ISTriple);
  TInstrClass = (ICSystem, ICData, ICStack, ICArithm, ICLogic, ICBranch);
  TInstrFormat = (IFOnly, IFRegCenter, IFRegEnd, IFRegDouble, IfRegPair);
  TInstruction = class
  public
    Code: Byte;
    Group: TInstrClass;
    Size: TInstrSize;
    Format: TInstrFormat;
    Mnemonic: String;
    Description: String;
    constructor Create
      (Code: Byte; Group: TInstrClass; Size: Byte; Format: TInstrFormat; Mnemonic: String; Description: String = '');
    function Mask: String;
  end;
  TInstructionSet = class
  public
    List: TList<TInstruction>;
    constructor Create;
    procedure Add
      (Code: Byte; Group: TInstrClass; Size: Byte; Format: TInstrFormat; Mnemonic: String; Description: String = '');
    function FindByCode(Code: Byte): TInstruction;
    function FindByMask(Mask: String): TInstruction;
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

{ TInstruction }

constructor TInstruction.Create;
begin
  Self.Code := Code;
  Self.Group := Group;
  Self.Size := TInstrSize(Size);
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

initialization

InstrSet := TInstructionSet.Create;
with InstrSet do
begin
  Add($0, ICSystem, 1, IFOnly, 'NOP');
  Add($76, ICSystem, 1, IFOnly, 'HLT');
  Add($40, ICData, 1, IFRegDouble, 'MOV');
end;

end.
