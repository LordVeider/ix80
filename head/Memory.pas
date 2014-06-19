unit Memory;

interface

uses
  Common, Instructions, Visualizer, SysUtils;

type
  TMemory = class
  private
    Vis: TVisualizer;
  public
    Cells: TMemoryCells;                                                        //Массив данных
    constructor Create(Vis: TVisualizer);
    procedure WriteMemory(Address: Word; Value: Int8);                          //Записать в память цифровое значение
    function ReadMemory(Address: Word): Int8;                                   //Считать из памяти цифровое значение
  end;

implementation

{ TMemory }

constructor TMemory.Create(Vis: TVisualizer);
begin
  Self.Vis := Vis;
end;

function TMemory.ReadMemory;
begin
  Result := Cells[Address];
  Vis.ShowAddrBuf(Address);
  Vis.ShowMemoryCell(Address);
  Vis.AddLog(Format('ЧТЕНИЕ ПАМЯТИ; Адрес: %sH; Значение: %sH;', [IntToNumStr(Address, SHEX, 4), IntToNumStr(Result, SHEX, 2)]));
end;

procedure TMemory.WriteMemory;
begin
  Cells[Address] := Value;
  Vis.ShowAddrBuf(Address);
  Vis.ShowMemoryCell(Address);
  Vis.AddLog(Format('ЗАПИСЬ В ПАМЯТЬ; Адрес: %sH; Значение: %sH;', [IntToNumStr(Address, SHEX, 4), IntToNumStr(Value, SHEX, 2)]));
end;

end.
