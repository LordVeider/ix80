unit FormValue;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//Форма редактирования значения

interface

uses
  Common,
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
    procedure edtValueChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    Verified: Boolean;
  public
    { Public declarations }
    FMemory: TForm;
    Address: Word;
    procedure LoadValue;
    procedure UnloadValue;
    procedure UpdateValue;
  end;

var
  frmValue: TfrmValue;

implementation

{$R *.dfm}

uses
  FormScheme, FormMemory;

procedure TfrmValue.FormShow(Sender: TObject);
begin
  LoadValue;
end;

procedure TfrmValue.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  edtValue.Text := '0';
  Address := 0;
end;

procedure TfrmValue.edtValueChange(Sender: TObject);
begin
  UpdateValue;
end;

procedure TfrmValue.LoadValue;
begin
  {if Assigned(FMemory) then
    with TfrmMemory(FMemory) do
    begin
      Address := grdNewMem.Row - 1;
      edtValue.Text := IntToStr(Memory.ReadMemory(Address));
    end;}
end;

procedure TfrmValue.UnloadValue;
begin
  {if Assigned(FMemory) then
    with TfrmMemory(FMemory) do
    begin
      Memory.WriteMemory(Address, NumStrToIntAuto(edtValue.Text));
    end;}
end;

procedure TfrmValue.UpdateValue;
begin
  try
    lblHexValue.Caption := ConvertNumStrAuto(edtValue.Text, SHEX);
    lblBinValue.Caption := ConvertNumStrAuto(edtValue.Text, SBIN, 16);
    lblDecValue.Caption := ConvertNumStrAuto(edtValue.Text, SDEC);
    Verified := True;
  except
    lblHexValue.Caption := 'Ошибка ввода';
    lblBinValue.Caption := 'Ошибка ввода';
    lblDecValue.Caption := 'Ошибка ввода';
    Verified := False;
  end;
end;

procedure TfrmValue.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmValue.btnApplyClick(Sender: TObject);
begin
  {if Verified then
  begin
    UnloadValue;
    Close;
    if Assigned(FMemory) then
      with TfrmMemory(FMemory) do
          DrawMemory;
  end;}
end;

end.
