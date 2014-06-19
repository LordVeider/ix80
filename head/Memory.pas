unit Memory;

interface

type
  TMemory = class
  private
    Cells: array [Word] of Int8;            //������ ������
  public
    procedure WriteMemory(Address: Word; Value: Int8);                          //�������� � ������ �������� ��������
    function ReadMemory(Address: Word): Int8;                                   //������� �� ������ �������� ��������
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
