unit Common;

interface

uses
  Math, SysUtils;

function ByteToBinString(Value: Byte): String;
function BinStringToByte(Value: String): Byte;
function WordToBinString(Value: Word): String;
function WordToHexString(Value: Word): String;
function HexStringToWord(Value: String): Word;

function AddresationCode(Value: String; RP: Boolean = False): String;
function MemoryPointer(Value: String): String;
function DirectData(Value: String; X: Boolean = False): String;

implementation

function ByteToBinString;
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

function BinStringToByte;
var
  i: Integer;
begin
  Result := 0;
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

function WordToHexString;
begin
  Result := IntToHex(Value, 4);
end;

function HexStringToWord;
begin
  Result := StrToInt('$' + Value);
end;

function AddresationCode;
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

function MemoryPointer;
begin
  Result := WordToBinString(HexStringToWord(Copy(Value, 1, Value.Length - 1)));
end;

function DirectData;
begin
  if X then
    Result := WordToBinString(StrToInt(Value))
  else
    Result := ByteToBinString(StrToInt(Value));
end;

end.
