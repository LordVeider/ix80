unit Parser;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//Парсер команд

interface

uses
  Logic, Instructions, Common,
  Classes, SysUtils;

type
  TCommandParser = class
  public
    function ParseCommand(TextLine: String; var CommandCode: String): Boolean;    //Разбор текста команды
    function WriteCode(CommandCode: String; Memory: TMemory; var Address: Word): Boolean;
  end;

implementation

{ TCommandParser }

function TCommandParser.ParseCommand;
var
  Cmd, Op1, Op2: String;
  NextDelimeter: Integer;
  Command: TInstruction;
begin
  try
    Result := True;
    //Синтаксический анализ
    NextDelimeter := Pos(#59, TextLine);    //Ищем точку с запятой в строке
    if NextDelimeter > 0 then               //Есть комментарий
      Delete(TextLine, Pos(#59, TextLine) - 1, TextLine.Length - Pos(#59, TextLine) + 2);
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
    Command := InstrSet.FindByMnemonic(Cmd);
    if Assigned(Command) then               //Команда найдена
      CommandCode := Command.FullCode(Op1, Op2)
    else
    begin
      Command := InstrSet.FindByMnemonic(Cmd, True);
      if Assigned(Command) then             //Команды условного перехода обрабатываем особым способом
        CommandCode := Command.FullCode(Copy(Cmd, 2, Cmd.Length - 1), Op1)
      else
      Result := False;                      //Семантическая ошибка
    end;
  except
    Result := False;                        //Синтаксическая ошибка
  end;
end;

function TCommandParser.WriteCode;
var
  Bits: Byte;
begin
  try
    Bits := 0;
    //Записываем в память двоичный код команды
    repeat
      Memory.WriteMemory(Address, NumStrToInt(Copy(CommandCode, Bits + 1, 8), SBIN));
      Address := Address + 1;
      Bits := Bits + 8;
    until Bits = CommandCode.Length;
    Result := True;
  except
    Result := False;
  end;
end;

end.
