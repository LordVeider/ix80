unit FormNumeric;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Common;

type
  TfrmNumeric = class(TForm)
    edtInput: TEdit;
    edtOutput: TEdit;
    rgInput: TRadioGroup;
    rgOutput: TRadioGroup;
    rgFormat: TRadioGroup;
    btnMagic: TButton;
    procedure btnMagicClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmNumeric: TfrmNumeric;

implementation

{$R *.dfm}

procedure TfrmNumeric.btnMagicClick(Sender: TObject);
begin
  //edtOutput.Text := Int8ToBinString(StrToInt(edtInput.Text));
  //edtOutput.Text := IntToBin(StrToInt(edtInput.Text), 8);
  //edtOutput.Text := IntToHex(StrToInt(edtInput.Text), 4);
  //edtOutput.Text := IntToStr(BinToInt(edtInput.Text, True));
  edtOutput.Text := IntToStr(HexToInt(edtInput.Text));
end;

end.
