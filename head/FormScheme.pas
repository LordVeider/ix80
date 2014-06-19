unit FormScheme;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//Визуальная схема процессора

interface

uses
  Common,
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
    procedure redtLogChange(Sender: TObject);
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
  FormEditor;

{ TfrmScheme }

procedure TfrmScheme.redtLogChange(Sender: TObject);
begin
  redtLog.SetFocus;
  redtLog.SelStart := redtLog.GetTextLen;
  redtLog.Perform(EM_SCROLLCARET, 0, 0);
end;

end.
