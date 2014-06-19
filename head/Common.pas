unit Common;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//Функции общего назначения

interface

uses
  Math, SysUtils,
  Winapi.Windows, Winapi.Messages;

const
  WM_BUT_EN = WM_USER + 1;
  WM_BUT_DIS = WM_USER + 2;

type
  TNumSys = (SBIN, SDEC, SOCT, SHEX);

function HexToInt(Value: String): Integer;                                      //Строковый HEX в число
function BinToInt(Value: String): Integer;                                      //Строковый BIN в число
function IntToBin(Value: Integer; Digits: Integer): String;                     //Число в строковый BIN

function ConvertNumStr
  (Value: String; BaseIn, BaseOut: TNumSys; Digits: Integer = 0): String;       //Преобразование в систему счисления
function NumStrToInt
  (Value: String; Base: TNumSys): Integer;                                      //Преобразование к числу
function ConvertNumStrAuto
  (Value: String; Base: TNumSys; Digits: Integer = 0): String;                  //Преобразование в систему счисления (автовыбор исходной CC)
function NumStrToIntAuto
  (Value: String): Integer;                                                     //Преобразование к числу (автовыбор исходной CC)
function IntToNumStr
  (Value: Integer; Base: TNumSys; Digits: Integer = 0): String;                 //Преобразование к строке

function SwapBytes(Value: String): String;                                      //Поменять местами два байта в строке
function MakeWordHL(HiByte, LoByte: Byte): Word;                                  //Преобразовать два байта в Word

function InvertBits(Value: String): String;                                  //Инвертировать двоичный код числа

implementation

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

function MakeWordHL;
begin
  Result := LoByte + (HiByte shl 8);
end;

function InvertBits;
var
  Digit: Byte;
begin
  Result := '';
  for Digit := 1 to Value.Length do
    Result := Result + IntToStr(IfThen(Value[Digit] = '1', 0, 1));
end;

end.
