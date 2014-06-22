unit FormValue;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//Форма редактирования значения

interface

uses
  Common, Typelib,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ImgList;

type
  TfrmValue = class(TForm)
    btnCancel: TButton;
    ilButtons: TImageList;
    lblHex: TLabel;
    lblBin: TLabel;
    lblDec: TLabel;
    edtValue: TEdit;
    lblHexValue: TLabel;
    lblBinValue: TLabel;
    lblDecValue: TLabel;
    btnApply: TButton;
    lblUns: TLabel;
    lblUnsValue: TLabel;
    procedure edtValueChange(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
  private
    { Private declarations }
    Verified: Boolean;
  public
    { Public declarations }
    procedure UpdateValue;
  end;

var
  frmValue: TfrmValue;

implementation

{$R *.dfm}

uses
  FormScheme, FormMemory;

procedure TfrmValue.edtValueChange(Sender: TObject);
begin
  UpdateValue;
end;

procedure TfrmValue.UpdateValue;
begin
  try
    lblHexValue.Caption := ConvertNumStrAuto(edtValue.Text, SHEX);
    lblBinValue.Caption := ConvertNumStrAuto(edtValue.Text, SBIN, 16);
    lblDecValue.Caption := IntToStr(Int8(NumStrToIntAuto(edtValue.Text)));
    lblUnsValue.Caption := IntToStr(Byte(NumStrToIntAuto(edtValue.Text)));
    Verified := True;
  except
    lblHexValue.Caption := 'Ошибка ввода';
    lblBinValue.Caption := 'Ошибка ввода';
    lblDecValue.Caption := 'Ошибка ввода';
    lblUnsValue.Caption := 'Ошибка ввода';
    Verified := False;
  end;
end;

procedure TfrmValue.btnApplyClick(Sender: TObject);
begin
  if Verified then
    ModalResult := mrOk
  else
    ModalResult := mrNone;
end;

procedure TfrmValue.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
