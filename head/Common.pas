unit Common;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//‘ункции общего назначени€

interface

uses
  Math, SysUtils;

type
  TNumeralSystems = (SBIN, SDEC, SOCT, SHEX);

  function Int8ToBinString(Value: Int8): String;                                  //ѕреобразовать байт в двоичную строку из 0 и 1
  function BinStringToInt8(Value: String): Int8;                                  //ѕреобразовать двоичную строку из 0 и 1 в байт
  function WordToBinString(Value: Word): String;                                  //ѕреобразовать Word в двоичную строку из 0 и 1
  function BinStringToWord(Value: String): Word;                                  //ѕреобразовать двоичную строку из 0 и 1 в Word
  function Int8ToHexString(Value: Int8): String;                                  //ѕреобразовать байт в шестнадцатеричную строку
  function HexStringToInt8(Value: String): Int8;                                  //ѕреобразовать шестнадцатеричную строку в байт
  function WordToHexString(Value: Word): String;                                  //ѕреобразовать Word в шестнадцатеричную строку
  function HexStringToWord(Value: String): Word;                                  //ѕреобразовать шестнадцатеричную строку в Word

  function FormatAddrCode(Value: String; RP: Boolean = False): String;            //ѕолучить двоичную строку (код регистра или пары)

  function FormatOperandInt8(Op: String; Sys: TNumeralSystems): String;           //ѕривести 8бит операнд к нужной системе счислени€
  function FormatOperandWord(Op: String; Sys: TNumeralSystems): String;           //ѕривести 16бит операнд к нужной системе счислени€

implementation

function Int8ToBinString;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to 7 do
  begin
    if Value and (1 shl i) > 0 then
      Result := '1' + Result
    else
      Result := '0' + Result;
  end;
end;

function BinStringToInt8;
var
  i: Integer;
begin
  Result := 0;
  while Value.Length < 8 do
    Value := '0' + Value;
  for i := 1 to 8 do
  begin
    Result := Result shl 1;
    if Value[i] = '1' then
      Result := Result or 1;
  end;
end;

function WordToBinString;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to 15 do
  begin
    if Value and (1 shl i) > 0 then
      Result := '1' + Result
    else
      Result := '0' + Result;
  end;
end;

function BinStringToWord;
var
  i: Integer;
begin
  Result := 0;
  while Value.Length < 16 do
    Value := '0' + Value;
  for i := 1 to 16 do
  begin
    Result := Result shl 1;
    if Value[i] = '1' then
      Result := Result or 1;
  end;
end;

function Int8ToHexString;
begin
  Result := IntToHex(Value, 2);
end;

function HexStringToInt8;
begin
  Result := StrToInt('$' + Value);
end;

function WordToHexString;
begin
  Result := IntToHex(Value, 4);
end;

function HexStringToWord;
begin
  Result := StrToInt('$' + Value);
end;

function FormatAddrCode;
begin
  if RP then
    case Value[1] of
      'B': Result := '00';
      'D': Result := '01';
      'H': Result := '10';
    end
  else
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

function FormatOperandInt8;
var
  Value: Int8;
begin
  if Op[Op.Length] = 'B' then
    Value := BinStringToInt8(Copy(Op, 1, Op.Length - 1))
  else if Op[Op.Length] = 'H' then
    Value := HexStringToInt8(Copy(Op, 1, Op.Length - 1))
  else
    Value := StrToInt(Op);
  if Sys = SBIN then
    Result := Int8ToBinString(Value)
  else if Sys = SHEX then
    Result := Int8ToHexString(Value)
  else
    Result := IntToStr(Value);
end;

function FormatOperandWord;
var
  Value: Word;
begin
  if Op[Op.Length] = 'B' then
    Value := BinStringToWord(Copy(Op, 1, Op.Length - 1))
  else if Op[Op.Length] = 'H' then
    Value := HexStringToWord(Copy(Op, 1, Op.Length - 1))
  else
    Value := StrToInt(Op);
  if Sys = SBIN then
    Result := WordToBinString(Value)
  else if Sys = SHEX then
    Result := WordToHexString(Value)
  else
    Result := IntToStr(Value);
end;

end.
