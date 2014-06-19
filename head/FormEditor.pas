unit FormEditor;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//Главное окно программы и редактор кода

interface

uses
  Common, Logic, Instructions, Parser, Visualizer, Typelib,
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
    procedure ManageControls(var Message: TMessage); message WM_CONTROLS;
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
  //vis.ShowDataReg(RA);
  //ShowMessage(IntToNumStr(ExtractReg($58), SBIN, 8));
  //ShowMessage(InstrSet.FindByMnemonic('LXI').FullCode('D', '256'));
  //frmMemory.SwitchMode(not frmMemory.CompactMode);
  vis.CleanSelection;
end;

procedure TfrmEditor.btnMemClearClick(Sender: TObject);
begin
  if Assigned(MEM) then
    FreeAndNil(MEM);
  MEM := TMemory.Create(VIS);
  VIS.OnlyUpdateMem(MEM.Cells);
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
    SendMessage(Application.MainForm.Handle, WM_CONTROLS, 0, 0);
    if not Assigned(CPU) then
      CPU := TProcessor.Create(VIS, MEM, 5);
    CPU.OnTerminate := OnTerm;
    CPU.Start;
  end;
end;

procedure TfrmEditor.btnRunStepClick(Sender: TObject);
begin
  VIS.SetVisLevel(2);
  if Assigned(MEM) then
  begin
    SendMessage(Application.MainForm.Handle, WM_CONTROLS, 0, 0);
    if not Assigned(CPU) then
      CPU := TProcessor.Create(VIS, MEM, 5);
    CPU.OnTerminate := OnTerm;
    CPU.StopCmd := TEvent.Create(nil, False, False, '');
    CPU.StopStep := TEvent.Create(nil, False, False, '');
    CPU.Start;
  end;
end;

procedure TfrmEditor.btnNextCommandClick(Sender: TObject);
begin
  if Assigned(CPU.StopCmd) then
  begin
    CPU.StopCmd.SetEvent;
  end;
end;

procedure TfrmEditor.btnNextStepClick(Sender: TObject);
begin
  if Assigned(CPU.StopStep) then
  begin
    CPU.StopStep.SetEvent;
    CPU.StopCmd.SetEvent;
  end;
end;

procedure TfrmEditor.btnStopClick(Sender: TObject);
begin
  CPU.Terminate;
  if Assigned(CPU.StopCmd) then
  begin
    CPU.StopStep.SetEvent;
    CPU.StopCmd.SetEvent;
  end;
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

procedure TfrmEditor.ManageControls;
var
  NewState: Boolean;
begin
  NewState := Boolean(Message.WParam);
  btnRunReal.Enabled := NewState;
  btnRunStep.Enabled := NewState;
  btnStop. Enabled := not NewState;
  btnNextCommand.Enabled := not NewState;
  btnNextStep.Enabled := not NewState;
  btnMemClear.Enabled := NewState;
  btnMemUnload.Enabled := NewState;
end;

end.
