unit Memory;

interface

uses
  Common, Instructions, Visualizer, SysUtils;

type
  TMemory = class
  private
    Vis: TVisualizer;
  public
    Cells: TMemoryCells;                                                        //������ ������
    constructor Create(Vis: TVisualizer);
    procedure WriteMemory(Address: Word; Value: Int8);                          //�������� � ������ �������� ��������
    function ReadMemory(Address: Word): Int8;                                   //������� �� ������ �������� ��������
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
  Vis.AddLog(Format('������ ������; �����: %sH; ��������: %sH;', [IntToNumStr(Address, SHEX, 4), IntToNumStr(Result, SHEX, 2)]));
end;

procedure TMemory.WriteMemory;
begin
  Cells[Address] := Value;
  Vis.ShowAddrBuf(Address);
  Vis.ShowMemoryCell(Address);
  Vis.AddLog(Format('������ � ������; �����: %sH; ��������: %sH;', [IntToNumStr(Address, SHEX, 4), IntToNumStr(Value, SHEX, 2)]));
end;

end.
