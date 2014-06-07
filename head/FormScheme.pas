unit FormScheme;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//Визуальная схема процессора

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.Grids, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ImgList, Common, Logic, InstructionSet;

type
  TfrmScheme = class(TForm)
    grScheme: TGroupBox;
    edtA: TEdit;
    edtB: TEdit;
    edtBuf: TEdit;
    edtC: TEdit;
    edtD: TEdit;
    edtE: TEdit;
    edtH: TEdit;
    edtIR: TEdit;
    edtL: TEdit;
    edtPC: TEdit;
    edtSP: TEdit;
    edtW: TEdit;
    edtZ: TEdit;
    grdPSW: TStringGrid;
    imgSchemeBackground: TImage;
    grLog: TGroupBox;
    redtLog: TRichEdit;
    procedure redtLogChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure DrawProcessor(Processor: TProcessor);
  end;

var
  frmScheme: TfrmScheme;

implementation

{$R *.dfm}

uses
  FormEditor;

{ TfrmScheme }

procedure TfrmScheme.DrawProcessor(Processor: TProcessor);
begin
  with Processor do
  begin
    edtA.Text := GetDataReg(RA).ToString;
    edtB.Text := GetDataReg(RB).ToString;
    edtC.Text := GetDataReg(RC).ToString;
    edtD.Text := GetDataReg(RD).ToString;
    edtE.Text := GetDataReg(RE).ToString;
    edtH.Text := GetDataReg(RH).ToString;
    edtL.Text := GetDataReg(RL).ToString;
    edtW.Text := GetDataReg(RW).ToString;
    edtZ.Text := GetDataReg(RZ).ToString;
    edtSP.Text := IntToNumStr(GetStackPointer, SHEX, 4) + 'H';
    edtPC.Text := IntToNumStr(GetProgramCounter, SHEX, 4) + 'H';
    edtIR.Text := IntToNumStr(GetInstRegister, SHEX, 2) + 'H';
    with grdPSW do
    begin
      ColWidths[3] := 24;
      ColWidths[7] := 24;
      Cells[0,0] := 'S';
      Cells[1,0] := 'Z';
      Cells[2,0] := '0';
      Cells[3,0] := 'AC';
      Cells[4,0] := '0';
      Cells[5,0] := 'P';
      Cells[6,0] := '1';
      Cells[7,0] := 'CY';
      Cells[0,1] := GetFlag(FS).ToString;
      Cells[1,1] := GetFlag(FZ).ToString;
      Cells[2,1] := '0';
      Cells[3,1] := GetFlag(FAC).ToString;
      Cells[4,1] := '0';
      Cells[5,1] := GetFlag(FP).ToString;
      Cells[6,1] := '1';
      Cells[7,1] := GetFlag(FCY).ToString;
    end;
  end;
end;

procedure TfrmScheme.redtLogChange(Sender: TObject);
begin
  redtLog.SetFocus;
  redtLog.SelStart := redtLog.GetTextLen;
  redtLog.Perform(EM_SCROLLCARET, 0, 0);
end;

end.
