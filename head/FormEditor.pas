unit FormEditor;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//Главное окно программы и редактор кода

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ToolWin, Vcl.ComCtrls,
  Vcl.ImgList, Vcl.StdCtrls, FormMemory, FormScheme, Common, Logic;

type
  TfrmEditor = class(TForm)
    tlbMain: TToolBar;
    menuMain: TMainMenu;
    miFile: TMenuItem;
    miEdit: TMenuItem;
    miHelp: TMenuItem;
    miView: TMenuItem;
    miFileNew: TMenuItem;
    miFileOpen: TMenuItem;
    miN1: TMenuItem;
    miFileExit: TMenuItem;
    btnNew: TToolButton;
    btnOpen: TToolButton;
    btnSave: TToolButton;
    btnSaveAs: TToolButton;
    btn1: TToolButton;
    btnCut: TToolButton;
    btnCopy: TToolButton;
    btnPaste: TToolButton;
    btn2: TToolButton;
    btnUndo: TToolButton;
    btnRedo: TToolButton;
    btn3: TToolButton;
    btnFind: TToolButton;
    btnReplace: TToolButton;
    btn4: TToolButton;
    btnRunReal: TToolButton;
    btnRunStep: TToolButton;
    btnStop: TToolButton;
    btn5: TToolButton;
    btnShowMemory: TToolButton;
    btnShowScheme: TToolButton;
    imglMain: TImageList;
    redtCode: TRichEdit;
    redtMsg: TRichEdit;
    dlgSaveMain: TSaveDialog;
    dlgOpenMain: TOpenDialog;
    sbarMain: TStatusBar;
    edtdec: TEdit;
    edtbin: TEdit;
    btn6: TButton;
    edthexsex: TEdit;
    btnMemUnload: TToolButton;
    btnMemClear: TToolButton;
    btn7: TToolButton;
    miHelpAbout: TMenuItem;
    procedure btnShowMemoryClick(Sender: TObject);
    procedure btnShowSchemeClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnRunRealClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btn6Click(Sender: TObject);
    procedure miHelpAboutClick(Sender: TObject);
    procedure btnMemClearClick(Sender: TObject);
    procedure btnMemUnloadClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmEditor: TfrmEditor;
  CPU: TProcessor;
  MEM: TMemory;

implementation

{$R *.dfm}

uses FormAbout;

procedure TfrmEditor.btn6Click(Sender: TObject);
var
  resbin, resdec, reshexsex: string;
begin
  //resdec := inttostr(BinStringToByte(edtbin.Text));
  //resbin := ByteToBinString(strtoint(edtdec.text));
  //reshexsex := FormatOperandWord(edthexsex.Text, SHEX);
  resbin := FormatOperandWord(edtdec.Text, SBIN);
  resdec := FormatOperandWord(edtbin.Text, SDEC);
  reshexsex := '';
  showmessage(resbin + #13#10 + resdec + #13#10 + reshexsex);
end;

procedure TfrmEditor.btnMemClearClick(Sender: TObject);
begin
  if Assigned(MEM) then
  begin
    FreeAndNil(MEM);
    frmScheme.DrawMemory(MEM);
  end;
end;

procedure TfrmEditor.btnMemUnloadClick(Sender: TObject);
var
  i: integer;
  par1: TCommandParser;
  tempc: TCommand;
  ad: Word;
begin
  ad := 5;
  if not Assigned(MEM) then
    MEM := TMemory.Create;
  redtMsg.Lines.Clear;
  par1 := TCommandParser.Create;
  for i := 0 to redtCode.Lines.Count-1 do
  begin
    if par1.ParseCommand(redtCode.Lines.Strings[i], tempc) then
    begin
      redtMsg.Lines.Add(tempc.ShowSummary);
      ad := tempc.WriteToMemory(MEM, ad);
    end
    else
      redtMsg.Lines.Add('error parsing command');
  end;
  MEM.ShowNewMem;
end;

procedure TfrmEditor.btnOpenClick(Sender: TObject);
begin
  if dlgOpenMain.Execute() then
  begin
    //
  end;
end;

procedure TfrmEditor.btnRunRealClick(Sender: TObject);
begin
  if Assigned(MEM) then
  begin
    if not Assigned(CPU) then
      CPU := TProcessor.Create(MEM);
    CPU.InitCpu(5);
    CPU.Run;
    CPU.ShowRegisters;
    MEM.ShowNewMem;
  end;
end;

procedure TfrmEditor.btnShowMemoryClick(Sender: TObject);
begin
  frmMemory.Show;
end;

procedure TfrmEditor.btnShowSchemeClick(Sender: TObject);
begin
  frmScheme.Show;
end;

procedure TfrmEditor.FormShow(Sender: TObject);
begin
  frmScheme.Show;
end;

procedure TfrmEditor.miHelpAboutClick(Sender: TObject);
begin
  frmAbout.ShowModal;
end;

end.
