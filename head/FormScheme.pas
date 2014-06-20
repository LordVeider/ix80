unit FormScheme;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//Визуальная схема процессора

interface

uses
  Common, Typelib,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.Grids, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ImgList;

type
  TfrmScheme = class(TForm)
    pnlScheme: TPanel;
    grScheme: TGroupBox;
    imgIR: TImage;
    imgCD: TImage;
    imgBCD: TImage;
    imgALU: TImage;
    imgAcc: TImage;
    imgFlags: TImage;
    imgReg: TImage;
    imgData: TImage;
    imgSchemeBackground: TImage;
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
    edtFP: TEdit;
    edtFAC: TEdit;
    edtFCY: TEdit;
    edtFS: TEdit;
    edtFZ: TEdit;
    pnlDown: TPanel;
    grLog: TGroupBox;
    redtLog: TRichEdit;
    btnNextStep: TButton;
    ilButtons: TImageList;
    btnNextCmd: TButton;
    btnStop: TButton;
    procedure redtLogChange(Sender: TObject);
    procedure RegDblClick(Sender: TObject);
    procedure btnNextStepClick(Sender: TObject);
    procedure btnNextCmdClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmScheme: TfrmScheme;

implementation

{$R *.dfm}

uses
  FormValue;

{ TfrmScheme }

procedure TfrmScheme.RegDblClick(Sender: TObject);
var
  Code: Byte;
begin
  with frmValue do
  begin
    edtValue.Text := TEdit(Sender).Text;
    Left := Mouse.CursorPos.X;
    Top := Mouse.CursorPos.Y;
    if ShowModal = mrOk then
    begin
      if TEdit(Sender) = edtA then Code := 7;
      if TEdit(Sender) = edtB then Code := 0;
      if TEdit(Sender) = edtC then Code := 1;
      if TEdit(Sender) = edtD then Code := 2;
      if TEdit(Sender) = edtE then Code := 3;
      if TEdit(Sender) = edtH then Code := 4;
      if TEdit(Sender) = edtL then Code := 5;
      if TEdit(Sender) = edtW then Code := 8;
      if TEdit(Sender) = edtZ then Code := 9;
      if TEdit(Sender) = edtSP then Code := 11;
      if TEdit(Sender) = edtPC then Code := 12;
      SendMessage(Application.MainForm.Handle, WM_VALUE, MakeWParam(NumStrToIntAuto(edtValue.Text), Code), 0);
    end;
  end;
end;

procedure TfrmScheme.btnNextStepClick(Sender: TObject);
begin
  SendMessage(Application.MainForm.Handle, WM_REMCTRL, 1, 0);
end;

procedure TfrmScheme.btnNextCmdClick(Sender: TObject);
begin
  SendMessage(Application.MainForm.Handle, WM_REMCTRL, 2, 0);
end;

procedure TfrmScheme.btnStopClick(Sender: TObject);
begin
  SendMessage(Application.MainForm.Handle, WM_REMCTRL, 3, 0);
end;

procedure TfrmScheme.redtLogChange(Sender: TObject);
begin
  redtLog.SetFocus;
  redtLog.SelStart := redtLog.GetTextLen;
  redtLog.Perform(EM_SCROLLCARET, 0, 0);
end;

end.
