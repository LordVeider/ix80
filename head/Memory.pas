unit Memory;

interface

type
  TMemory = class
  private
    Cells: array [Word] of Int8;            //Массив данных
  public
    procedure WriteMemory(Address: Word; Value: Int8);                          //Записать в память цифровое значение
    function ReadMemory(Address: Word): Int8;                                   //Считать из памяти цифровое значение
  end;

implementation

{ TMemory }

function TMemory.ReadMemory;
begin
  Result := Cells[Address];
end;

procedure TMemory.WriteMemory;
begin
  Cells[Address] := Value;
end;

end.
