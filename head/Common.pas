unit Common;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//Функции общего назначения

interface

uses
  Math, SysUtils;

type
  TNumSys = (SBIN, SDEC, SOCT, SHEX);

  function FormatAddrCode(Value: String; RP: Boolean = False): String;          //Получить двоичную строку (код регистра или пары)

  function HexToInt(Value: String): Integer;                                    //Строковый HEX в число
  function BinToInt(Value: String): Integer;                                    //Строковый BIN в число
  function IntToBin(Value: Integer; Digits: Integer): String;                   //Число в строковый BIN

  function ConvertNumStr
    (Value: String; BaseIn, BaseOut: TNumSys; Digits: Integer = 0): String;     //Преобразование в систему счисления
  function NumStrToInt
    (Value: String; Base: TNumSys): Integer;                                    //Преобразование к числу
  function ConvertNumStrAuto
    (Value: String; Base: TNumSys; Digits: Integer = 0): String;                //Преобразование в систему счисления (автовыбор исходной CC)
  function NumStrToIntAuto
    (Value: String): Integer;                                                   //Преобразование к числу (автовыбор исходной CC)
  function IntToNumStr
    (Value: Integer; Base: TNumSys; Digits: Integer = 0): String;               //Преобразование к строке
  function SwapBytes(Value: String): String;                                    //Поменять местами два байта в строке

  function ExtractReg(Code: Byte; Tail: Boolean = False): Byte;
  function ExtractRP(Code: Byte): Byte;

implementation

function ExtractReg;
begin
  if not Tail then
    Code := Code shr 3;
  Code := Code shl 5;
  Code := Code shr 5;
  Result := Code;
end;

function ExtractRP;
begin
  Code := Code shl 2;
  Code := Code shr 6;
  Result := Code;
end;

function HexToInt;
begin
  Result := StrToInt('$' + Value);
end;

function BinToInt;
var
  i: Integer;
begin
  Result := 0;
  if (Value.Length mod 8 = 0) AND (Value[1] = '1') then
    while Value.Length < 32 do
      Value := '1' + Value;
  for i := Value.Length downto 1 do
    if Value[i] = '1' then
      Result := Result + (1 shl (Value.Length - i));
end;

function IntToBin;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Digits-1 do
    if Value and (1 shl i) > 0 then
      Result := '1' + Result
    else
      Result := '0' + Result;
end;

function ConvertNumStr;
var
  Temp: Integer;
begin
  case BaseIn of
    SBIN: Temp := BinToInt(Value);
    SHEX: Temp := HexToInt(Value);
    SDEC: Temp := StrToInt(Value);
  end;
  case BaseOut of
    SBIN: Result := IntToBin(Temp, Digits);
    SHEX: Result := IntToHex(Temp, Digits);
    SDEC: Result := IntToStr(Temp);
  end;
end;

function NumStrToInt;
begin
  Result := StrToInt(ConvertNumStr(Value, Base, SDEC));
end;

function ConvertNumStrAuto;
begin
  if Value[Value.Length] = 'B' then
    Result := ConvertNumStr(Copy(Value, 1, Value.Length-1), SBIN, Base, Digits)
  else if Value[Value.Length] = 'H' then
    Result := ConvertNumStr(Copy(Value, 1, Value.Length-1), SHEX, Base, Digits)
  else
    Result := ConvertNumStr(Value, SDEC, Base, Digits);
end;

function NumStrToIntAuto;
begin
  Result := StrToInt(ConvertNumStrAuto(Value, SDEC));
end;

function IntToNumStr;
begin
  Result := ConvertNumStr(IntToStr(Value), SDEC, Base, Digits);
end;

function SwapBytes;
begin
  Result := Copy(Value, 9, 8) + Copy(Value, 1, 8);
end;

function FormatAddrCode;
begin
  if RP then
    case Value[1] of
      'B': Result := '00';
      'D': Result := '01';
      'H': Result := '10';
      else if (Value = 'PSW') or (Value = 'SP') then
        Result := '11';
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

end.
