unit FormEditor;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//Главное окно программы и редактор кода

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ToolWin, Vcl.ComCtrls,
  Vcl.ImgList, Vcl.StdCtrls, SyncObjs, FormMemory, FormScheme, Common, Logic, Vcl.Grids;

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
    btnTextOpen: TToolButton;
    btnTextSave: TToolButton;
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
    ilToolbar: TImageList;
    redtCode: TRichEdit;
    redtMsg: TRichEdit;
    dlgSaveMain: TSaveDialog;
    dlgOpenMain: TOpenDialog;
    sbarMain: TStatusBar;
    btnMemUnload: TToolButton;
    btnMemClear: TToolButton;
    btn7: TToolButton;
    miHelpAbout: TMenuItem;
    btnDumpLoad: TToolButton;
    btnDumpSave: TToolButton;
    miHelpUserGuide: TMenuItem;
    miHelpCommands: TMenuItem;
    miN2: TMenuItem;
    grdLines: TStringGrid;
    btn6: TToolButton;
    btnNextStep: TToolButton;
    btnNextCommand: TToolButton;
    btn8: TToolButton;
    btnTextSaveAs: TToolButton;
    btn9: TToolButton;
    procedure btnShowMemoryClick(Sender: TObject);
    procedure btnShowSchemeClick(Sender: TObject);
    procedure btnTextOpenClick(Sender: TObject);
    procedure btnRunRealClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure miHelpAboutClick(Sender: TObject);
    procedure btnMemClearClick(Sender: TObject);
    procedure btnMemUnloadClick(Sender: TObject);
    procedure btn8Click(Sender: TObject);
    procedure btnNextStepClick(Sender: TObject);
    procedure btnNextCommandClick(Sender: TObject);
    procedure btnRunStepClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
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

uses FormAbout, FormValue;

procedure TfrmEditor.btn8Click(Sender: TObject);
begin
  frmValue.Show;
end;

procedure TfrmEditor.btnMemClearClick(Sender: TObject);
begin
  if Assigned(MEM) then
  begin
    FreeAndNil(MEM);
    frmMemory.Memory := MEM;
    frmMemory.DrawMemory;
  end;
end;

procedure TfrmEditor.btnMemUnloadClick(Sender: TObject);
var
  i: integer;
  par1: TCommandParser;
  tempc: TCommand;
  ad: Word;
  compiled: Boolean;
begin
  compiled := True;
  ad := 5;
  if not Assigned(MEM) then
    MEM := TMemory.Create;
  redtMsg.Lines.Clear;
  par1 := TCommandParser.Create;
  for i := 0 to redtCode.Lines.Count-1 do
  begin
    if par1.ParseCommand(redtCode.Lines.Strings[i], tempc) then
    begin
      //redtMsg.Lines.Add(tempc.ShowSummary);
      ad := tempc.WriteToMemory(MEM, ad);
    end
    else
    begin
      redtMsg.Lines.Add('Ошибка: неверная команда (строка: ' + IntToStr(i+1) + ')');
      compiled := False;
    end;
  end;
  if compiled then
    redtMsg.Lines.Add('Программа успешно транслирована в память');
  MEM.ShowNewMem;
end;

procedure TfrmEditor.btnTextOpenClick(Sender: TObject);
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
    //CPU.StopSection := TEvent.Create(nil, False, False, '');
    //CPU.StopSection.Enter;
      btnRunReal.Enabled := False;
      btnRunStep.Enabled := False;
      btnStop. Enabled := True;
      btnNextCommand.Enabled := False;
      btnMemClear.Enabled := False;
      btnMemUnload.Enabled := False;
    CPU.InitCpu(5);
    CPU.Run;
    //CPU.ShowRegisters;
    //MEM.ShowNewMem;
  end;
end;

procedure TfrmEditor.btnRunStepClick(Sender: TObject);
begin
  if Assigned(MEM) then
  begin
    if not Assigned(CPU) then
      CPU := TProcessor.Create(MEM);
    CPU.StopSection := TEvent.Create(nil, False, False, '');
      btnRunReal.Enabled := False;
      btnRunStep.Enabled := False;
      btnStop. Enabled := True;
      btnNextCommand.Enabled := True;
      btnMemClear.Enabled := False;
      btnMemUnload.Enabled := False;
    //CPU.StopSection.Enter;
    CPU.InitCpu(5);
    CPU.Run;
    //CPU.ShowRegisters;
    //MEM.ShowNewMem;
  end;
end;

procedure TfrmEditor.btnNextCommandClick(Sender: TObject);
begin
  if Assigned(CPU.StopSection) then
  begin
    //CPU.StopSection.Leave;
    //CPU.StopSection.Enter;
    CPU.StopSection.SetEvent;
  end;
end;

procedure TfrmEditor.btnNextStepClick(Sender: TObject);
begin
  //CPU.StopSection.Leave;
end;

procedure TfrmEditor.btnStopClick(Sender: TObject);
begin
  CPU.ProcessorThread.Terminate;
  if Assigned(CPU.StopSection) then
    CPU.StopSection.SetEvent;
end;

procedure TfrmEditor.btnShowMemoryClick(Sender: TObject);
begin
  frmMemory.Hide;
  frmMemory.TrueMem := not frmMemory.TrueMem;
  frmMemory.Show;
end;

procedure TfrmEditor.btnShowSchemeClick(Sender: TObject);
begin
  frmScheme.Show;
end;

procedure TfrmEditor.FormShow(Sender: TObject);
var
  i: integer;
begin
  with grdLines do
  begin
    for i := 0 to 99 do
      Cells[0, i] := IntToStr(i+1);
  end;
  frmScheme.Show;
  frmMemory.TrueMem := True;
  frmMemory.Show;
end;

procedure TfrmEditor.miHelpAboutClick(Sender: TObject);
begin
  frmAbout.ShowModal;
end;

end.
