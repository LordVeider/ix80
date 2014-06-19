unit FormEditor;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//Главное окно программы и редактор кода

interface

uses
  Common, Processor, Memory, Instructions, Parser, Visualizer,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ToolWin, Vcl.ComCtrls,
  Vcl.ImgList, Vcl.StdCtrls, SyncObjs, Vcl.Grids;
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
    procedure btn9Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure EnableButtons(var Message: TMessage); message WM_BUT_EN;
    procedure DisableButtons(var Message: TMessage); message WM_BUT_DIS;
  public
    { Public declarations }
    procedure OnTerm(Sender: TObject);
  end;

var
  frmEditor: TfrmEditor;
  CPU: TProcessor;
  MEM: TMemory;
  VIS: TVisualizer;

implementation

{$R *.dfm}

uses
  FormScheme, FormMemory, FormAbout, FormValue;

procedure TfrmEditor.btn8Click(Sender: TObject);
begin
  //frmValue.Show;
end;

procedure TfrmEditor.btn9Click(Sender: TObject);
begin
  //vis := TVisualizer.Create;
  vis.ShowDataReg(RA);
  //ShowMessage(IntToNumStr(ExtractReg($58), SBIN, 8));
  //ShowMessage(InstrSet.FindByMnemonic('LXI').FullCode('D', '256'));
  //frmMemory.SwitchMode(not frmMemory.CompactMode);
end;

procedure TfrmEditor.btnMemClearClick(Sender: TObject);
begin
  {if Assigned(MEM) then
  begin
    FreeAndNil(MEM);
    frmMemory.Memory := MEM;
    frmMemory.DrawMemory;
  end;}
end;

procedure TfrmEditor.btnMemUnloadClick(Sender: TObject);
var
  LineIndex: Integer;
  CommandCode: String;
  Address: Word;
  Parser: TCommandParser;
  Success: Boolean;
begin
  VIS.SetVisLevel(0);
  if not Assigned(MEM) then
    MEM := TMemory.Create(VIS);
  redtMsg.Lines.Clear;
  Parser := TCommandParser.Create;
  Success := True;
  Address := 5;
  for LineIndex := 0 to redtCode.Lines.Count-1 do
  begin
    if Success then
    begin
      Success := Parser.ParseCommand(redtCode.Lines.Strings[LineIndex], CommandCode);
      if Success then
        Success := Parser.WriteCode(CommandCode, MEM, Address)
      else
        redtMsg.Lines.Add('Ошибка записи команды в память (строка: ' + IntToStr(LineIndex + 1) + ')');
    end
    else
    begin
      redtMsg.Lines.Add('Ошибка трансляции команды (строка: ' + IntToStr(LineIndex + 1) + ')');
    end;
  end;
  if Success then
    redtMsg.Lines.Add('Программа успешно транслирована в память');
  //MEM.ShowNewMem;
  Vis.OnlyUpdateMem(MEM.Cells);
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
  VIS.SetVisLevel(1);
  if Assigned(MEM) then
  begin
    //if not Assigned(VIS) then
    //  VIS := TVisualizer.Create;
    if not Assigned(CPU) then
      CPU := TProcessor.Create(VIS, MEM, 5);
    CPU.OnTerminate := OnTerm;
    //CPU.StopSection := TEvent.Create(nil, False, False, '');
    //CPU.StopSection.Enter;
      btnRunReal.Enabled := False;
      btnRunStep.Enabled := False;
      btnStop. Enabled := True;
      btnNextCommand.Enabled := False;
      btnMemClear.Enabled := False;
      btnMemUnload.Enabled := False;

//  ProcessorThread := TProcessorThread.Create(True);
//  ProcessorThread.OnTerminate := OnTerm;
//  ProcessorThread.Processor := Self;
//  ProcessorThread.Start;

    CPU.Start;
    //CPU.InitCpu(5);
    //CPU.Run;
    //CPU.ShowRegisters;
    //MEM.ShowNewMem;
  end;
end;

procedure TfrmEditor.btnRunStepClick(Sender: TObject);
begin
  VIS.SetVisLevel(2);
  if Assigned(MEM) then
  begin
    if not Assigned(CPU) then
      CPU := TProcessor.Create(VIS, MEM, 5);
    CPU.OnTerminate := OnTerm;
    CPU.StopCmd := TEvent.Create(nil, False, False, '');
      btnRunReal.Enabled := False;
      btnRunStep.Enabled := False;
      btnStop. Enabled := True;
      btnNextCommand.Enabled := True;
      btnMemClear.Enabled := False;
      btnMemUnload.Enabled := False;
    //CPU.StopSection.Enter;
    CPU.Start;
    //CPU.ShowRegisters;
    //MEM.ShowNewMem;

  end;
end;

procedure TfrmEditor.btnNextCommandClick(Sender: TObject);
begin
  if Assigned(CPU.StopCmd) then
  begin
    //CPU.StopSection.Leave;
    //CPU.StopSection.Enter;
    CPU.StopCmd.SetEvent;
  end;
end;

procedure TfrmEditor.btnNextStepClick(Sender: TObject);
begin
  //CPU.StopSection.Leave;
end;

procedure TfrmEditor.btnStopClick(Sender: TObject);
begin
  CPU.Terminate;
  if Assigned(CPU.StopCmd) then
    CPU.StopCmd.SetEvent;
end;

procedure TfrmEditor.btnShowMemoryClick(Sender: TObject);
begin
  with frmMemory do
  begin
    SwitchMode(not CompactMode);
    Show;
  end;
end;

procedure TfrmEditor.btnShowSchemeClick(Sender: TObject);
begin
  frmScheme.Show;
end;

procedure TfrmEditor.FormCreate(Sender: TObject);
begin
  VIS := TVisualizer.Create;
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
  //frmMemory.TrueMem := True;
  frmMemory.Show;
end;

procedure TfrmEditor.miHelpAboutClick(Sender: TObject);
begin
  frmAbout.ShowModal;
end;

procedure TfrmEditor.OnTerm(Sender: TObject);
begin
  CPU := nil;
end;

procedure TfrmEditor.EnableButtons(var Message: TMessage);
begin
      btnRunReal.Enabled := True;
      btnRunStep.Enabled := True;
      btnStop. Enabled := False;
      btnNextCommand.Enabled := False;
      btnMemClear.Enabled := True;
      btnMemUnload.Enabled := True;
end;

procedure TfrmEditor.DisableButtons(var Message: TMessage);
begin

end;

end.
