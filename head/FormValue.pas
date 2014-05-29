unit FormValue;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ImgList, Common;

type
  TfrmValue = class(TForm)
    edtHex: TLabeledEdit;
    edtBin: TLabeledEdit;
    edtDec: TLabeledEdit;
    rbHex: TRadioButton;
    rbBin: TRadioButton;
    rbDec: TRadioButton;
    btnApply: TButton;
    btnCancel: TButton;
    lblValueName: TLabel;
    ilButtons: TImageList;
    procedure rbHexClick(Sender: TObject);
    procedure edtHexKeyPress(Sender: TObject; var Key: Char);
    procedure edtBinKeyPress(Sender: TObject; var Key: Char);
    procedure edtDecKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    DoubleOperand: Boolean;
  end;

var
  frmValue: TfrmValue;

implementation

{$R *.dfm}

procedure TfrmValue.edtHexKeyPress(Sender: TObject; var Key: Char);
begin
  try
    if DoubleOperand then
    begin
      edtBin.Text := FormatOperandWord(edtHex.Text + 'H', SBIN);
      edtDec.Text := FormatOperandWord(edtHex.Text + 'H', SDEC);
    end
    else
    begin
      edtBin.Text := FormatOperandByte(edtHex.Text + 'H', SBIN);
      edtDec.Text := FormatOperandByte(edtHex.Text + 'H', SDEC);
    end;
  except
    edtBin.Text := 'Некорректное значение';
    edtDec.Text := 'Некорректное значение';
  end;
end;

procedure TfrmValue.edtBinKeyPress(Sender: TObject; var Key: Char);
begin
  try
    if DoubleOperand then
    begin
      edtHex.Text := FormatOperandWord(edtBin.Text + 'B', SHEX);
      edtDec.Text := FormatOperandWord(edtBin.Text + 'B', SDEC);
    end
    else
    begin
      edtHex.Text := FormatOperandByte(edtBin.Text + 'B', SHEX);
      edtDec.Text := FormatOperandByte(edtBin.Text + 'B', SDEC);
    end;
  except
    edtHex.Text := 'Некорректное значение';
    edtDec.Text := 'Некорректное значение';
  end;
end;

procedure TfrmValue.edtDecKeyPress(Sender: TObject; var Key: Char);
begin
  try
    if DoubleOperand then
    begin
      edtHex.Text := FormatOperandWord(edtDec.Text, SHEX);
      edtBin.Text := FormatOperandWord(edtDec.Text, SBIN);
    end
    else
    begin
      edtHex.Text := FormatOperandByte(edtDec.Text, SHEX);
      edtBin.Text := FormatOperandByte(edtDec.Text, SBIN);
    end;
  except
    edtBin.Text := 'Некорректное значение';
    edtHex.Text := 'Некорректное значение';
  end;
end;

procedure TfrmValue.rbHexClick(Sender: TObject);
begin
  if rbHex.Checked then
  begin
    edtHex.Enabled := True;
    edtDec.Enabled := False;
    edtBin.Enabled := False;
  end
  else if rbBin.Checked then
  begin
    edtHex.Enabled := False;
    edtDec.Enabled := False;
    edtBin.Enabled := True;
  end
  else if rbDec.Checked then
  begin
    edtHex.Enabled := False;
    edtDec.Enabled := True;
    edtBin.Enabled := False;
  end;
end;

end.
