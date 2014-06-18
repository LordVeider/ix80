unit Visualizer;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//Модуль визуализации

interface

uses
  FormScheme, FormMemory, Instructions,
  Classes, StdCtrls, Graphics;

type
  TVisualizer = class
  private
    FullVisMode: Boolean;
  public
    constructor Create(FullVisMode: Boolean = False);
    procedure CleanSelection;
    procedure ShowReg(Reg: TDataReg);
  end;

implementation

{ TVisualizer }

constructor TVisualizer.Create;
begin
  Self.FullVisMode := FullVisMode;
end;

procedure TVisualizer.CleanSelection;
var
  Cnt: Integer;
begin
  with frmScheme do
    for Cnt := 0 to ComponentCount - 1 do
      if Components[Cnt] is TEdit then
        TEdit(Components[Cnt]).Color := clWindow;
end;

procedure TVisualizer.ShowReg;
var
  CurrentEdit: TEdit;
begin
  with frmScheme do
    case Reg of
      RB: CurrentEdit := edtB;
      RC: CurrentEdit := edtC;
      RD: CurrentEdit := edtD;
      RE: CurrentEdit := edtE;
      RH: CurrentEdit := edtH;
      RL: CurrentEdit := edtL;
      RA: CurrentEdit := edtA;
      RW: CurrentEdit := edtW;
      RZ: CurrentEdit := edtZ;
    end;
  CurrentEdit.Color := clMoneyGreen;
end;

end.
