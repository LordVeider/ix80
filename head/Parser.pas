unit Parser;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//Парсер команд (на основе регулярных выражений)

interface

uses
  Logic, Instructions, Common, Typelib,
  Classes, SysUtils, RegularExpressions;

type
  TRegularParser = class
  private
    RegEx: TRegEx;
  public
    constructor Create;
    function ParseCommand(TextLine: String; var CommandCode: String): Boolean;  //Разбор текста команды
    function WriteCode
      (CommandCode: String; Memory: TMemory; var Address: Word): Boolean;       //Загрузка команды в память
  end;

implementation

{ TRegularParser }

constructor TRegularParser.Create;
const
  F_REGEX = '^([A-Za-z]{2,4})((\s)+(\-?[abcdefhlmABCDEHLMpswPSW0-9]*)(\s*,\s*(\-?[abcdefhlmABCDEHLMpswPSW0-9]*))?)?(\s*;.*)?$';
begin
  RegEx := TRegEx.Create(F_REGEX);
end;

function TRegularParser.ParseCommand;
var
  Cmd, Op1, Op2: String;
  Command: TInstruction;
  Match: TMatch;
begin
  //Синтаксический анализ
  Match := RegEx.Match(TextLine);                                               //Сравниваем с регуляркой
  if Match.Success then                                                         //Синтаксис верный
  begin
    Result := True;
    //Разбор команды
    with Match.Groups do
    begin
      Cmd := Item[1].Value;                                                     //Оператор
      if Count > 4 then Op1 := Item[4].Value;                                   //Первый операнд (если есть)
      if Count > 6 then Op2 := Item[6].Value;                                   //Второй операнд (если есть)
    end;
    CommandCode := Cmd + '#' + Op1 + '#' + Op2;
    //Поиск команды в матрице
    Command := InstrSet.FindByMnemonic(Cmd);
    if Assigned(Command) then                                                   //Команда найдена
      CommandCode := Command.FullCode(Op1, Op2)
    else
    begin
      Command := InstrSet.FindByMnemonic(Cmd, True);
      if Assigned(Command) then                                                 //Команды условного перехода обрабатываем особым способом
        CommandCode := Command.FullCode(Copy(Cmd, 2, Cmd.Length - 1), Op1)
      else
        Result := False;                                                        //Неизвестная команда
    end;
  end
  else
    Result := False;                                                            //Синтаксическая ошибка
end;

function TRegularParser.WriteCode;
var
  Bits: Byte;
begin
  try
    Bits := 0;
    //Записываем в память двоичный код команды
    repeat
      Memory.Write(Address, NumStrToInt(Copy(CommandCode, Bits + 1, 8), SBIN));
      Address := Address + 1;
      Bits := Bits + 8;
    until Bits = CommandCode.Length;
    Result := True;
  except
    Result := False;
  end;
end;

end.
