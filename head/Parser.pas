unit Parser;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//������ ������ (�� ������ ���������� ���������)

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
    function ParseCommand(TextLine: String; var CommandCode: String): Boolean;  //������ ������ �������
    function WriteCode
      (CommandCode: String; Memory: TMemory; var Address: Word): Boolean;       //�������� ������� � ������
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
  //�������������� ������
  Match := RegEx.Match(TextLine);                                               //���������� � ����������
  if Match.Success then                                                         //��������� ������
  begin
    Result := True;
    //������ �������
    with Match.Groups do
    begin
      Cmd := Item[1].Value;                                                     //��������
      if Count > 4 then Op1 := Item[4].Value;                                   //������ ������� (���� ����)
      if Count > 6 then Op2 := Item[6].Value;                                   //������ ������� (���� ����)
    end;
    CommandCode := Cmd + '#' + Op1 + '#' + Op2;
    //����� ������� � �������
    Command := InstrSet.FindByMnemonic(Cmd);
    if Assigned(Command) then                                                   //������� �������
      CommandCode := Command.FullCode(Op1, Op2)
    else
    begin
      Command := InstrSet.FindByMnemonic(Cmd, True);
      if Assigned(Command) then                                                 //������� ��������� �������� ������������ ������ ��������
        CommandCode := Command.FullCode(Copy(Cmd, 2, Cmd.Length - 1), Op1)
      else
        Result := False;                                                        //����������� �������
    end;
  end
  else
    Result := False;                                                            //�������������� ������
end;

function TRegularParser.WriteCode;
var
  Bits: Byte;
begin
  try
    Bits := 0;
    //���������� � ������ �������� ��� �������
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
