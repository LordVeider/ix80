unit Memory;

interface

uses
  Instructions, Visualizer;

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
end;

procedure TMemory.WriteMemory;
begin
  Cells[Address] := Value;
end;

end.
