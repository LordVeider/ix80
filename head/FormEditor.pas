unit FormEditor;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//Главное окно программы и редактор кода

interface

uses
  Common, Logic, Instructions, Parser, Visualizer, Typelib,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ToolWin, Vcl.ComCtrls,
  Vcl.ImgList, Vcl.StdCtrls, SyncObjs, Vcl.Grids, Vcl.ExtDlgs;
type
  TfrmEditor = class(TForm)
    tlbMain: TToolBar;
    menuMain: TMainMenu;
    miSource: TMenuItem;
    miMem: TMenuItem;
    miHelp: TMenuItem;
    miView: TMenuItem;
    miSourceNew: TMenuItem;
    miSourceOpen: TMenuItem;
    miN1: TMenuItem;
    miFileExit: TMenuItem;
    btnTextNew: TToolButton;
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
    btnMemAssembly: TToolButton;
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
    btnNextCmd: TToolButton;
    btn8: TToolButton;
    btnTextSaveAs: TToolButton;
    btn9: TToolButton;
    miViewArrangeHD: TMenuItem;
    miViewArrangeFHD: TMenuItem;
    miSourceSave: TMenuItem;
    miSourceSaveAs: TMenuItem;
    miN3: TMenuItem;
    miMemLoad: TMenuItem;
    miMemSave: TMenuItem;
    miMemClear: TMenuItem;
    miMemAssembly: TMenuItem;
    miN4: TMenuItem;
    miRun: TMenuItem;
    miRunReal: TMenuItem;
    miRunStep: TMenuItem;
    miNextStep: TMenuItem;
    miNextCmd: TMenuItem;
    miStop: TMenuItem;
    miN5: TMenuItem;
    miViewArrange: TMenuItem;
    miViewScheme: TMenuItem;
    miViewMem: TMenuItem;
    procedure btnShowMemoryClick(Sender: TObject);
    procedure btnShowSchemeClick(Sender: TObject);
    procedure btnTextOpenClick(Sender: TObject);
    procedure btnRunRealClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure miHelpAboutClick(Sender: TObject);
    procedure btnMemClearClick(Sender: TObject);
    procedure btnMemAssemblyClick(Sender: TObject);
    procedure btnNextStepClick(Sender: TObject);
    procedure btnNextCmdClick(Sender: TObject);
    procedure btnRunStepClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure miViewArrangeFHDClick(Sender: TObject);
    procedure miViewArrangeHDClick(Sender: TObject);
    procedure btnDumpLoadClick(Sender: TObject);
    procedure btnDumpSaveClick(Sender: TObject);
    procedure btnTextNewClick(Sender: TObject);
    procedure btnTextSaveClick(Sender: TObject);
    procedure btnTextSaveAsClick(Sender: TObject);
    procedure miFileExitClick(Sender: TObject);
  private
    { Private declarations }
    CurrentTextFile: String;
    procedure ManageControls(var Message: TMessage); message WM_CONTROLS;
    procedure RemoteControl(var Message: TMessage); message WM_REMCTRL;
    procedure UpdateValue(var Message: TMessage); message WM_VALUE;
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

procedure TfrmEditor.btnTextNewClick(Sender: TObject);
begin
  redtMsg.Lines.Clear;
  redtCode.Lines.Clear;
  CurrentTextFile := '';
end;

procedure TfrmEditor.btnTextOpenClick(Sender: TObject);
begin
  dlgOpenMain.Title := 'Загрузить исходный код из файла';
  dlgOpenMain.Filter := 'Файлы исходного кода (*.asm)|*.asm|Все файлы (*.*)|*.*';
  dlgOpenMain.InitialDir := GetCurrentDir;
  if dlgOpenMain.Execute then
  begin
    redtMsg.Lines.Clear;
    redtCode.Lines.Clear;
    redtCode.Lines.LoadFromFile(dlgOpenMain.FileName);
    CurrentTextFile := dlgOpenMain.FileName;
  end;
end;

procedure TfrmEditor.btnTextSaveClick(Sender: TObject);
begin
  if CurrentTextFile <> '' then
    redtCode.Lines.SaveToFile(CurrentTextFile)
  else
    btnTextSaveAsClick(Sender);
end;

procedure TfrmEditor.btnTextSaveAsClick(Sender: TObject);
begin
  dlgSaveMain.Title := 'Сохранить исходный код в файл';
  dlgSaveMain.Filter := 'Файлы исходного кода (*.asm)|*.asm|Все файлы (*.*)|*.*';
  dlgSaveMain.DefaultExt := 'asm';
  dlgSaveMain.InitialDir := GetCurrentDir;
  if dlgSaveMain.Execute then
  begin
    redtCode.Lines.SaveToFile(dlgSaveMain.FileName);
    CurrentTextFile := dlgSaveMain.FileName;
  end;
end;

procedure TfrmEditor.btnDumpLoadClick(Sender: TObject);
begin
  dlgOpenMain.Title := 'Загрузить дамп памяти из файла';
  dlgOpenMain.Filter := 'Файлы дампов памяти (*.dmp)|*.dmp|Все файлы (*.*)|*.*';
  dlgOpenMain.InitialDir := GetCurrentDir;
  if dlgOpenMain.Execute then
  begin
    if not Assigned(MEM) then
      MEM := TMemory.Create;
    MEM.LoadFromFile(dlgOpenMain.FileName);
    VIS.UpdateMemory(MEM.Cells);
  end;
end;

procedure TfrmEditor.btnDumpSaveClick(Sender: TObject);
begin
  dlgSaveMain.Title := 'Сохранить дамп памяти в файл';
  dlgSaveMain.Filter := 'Файлы дампов памяти (*.dmp)|*.dmp|Все файлы (*.*)|*.*';
  dlgSaveMain.DefaultExt := 'dmp';
  dlgSaveMain.InitialDir := GetCurrentDir;
  if Assigned(MEM) then
    if dlgSaveMain.Execute then
      MEM.SaveToFile(dlgSaveMain.FileName);
end;

procedure TfrmEditor.btnMemClearClick(Sender: TObject);
begin
  if Assigned(MEM) then
  begin
    FreeAndNil(MEM);
    MEM := TMemory.Create;
    VIS.UpdateMemory(MEM.Cells);
  end;
end;

procedure TfrmEditor.btnMemAssemblyClick(Sender: TObject);
var
  LineIndex: Integer;
  CommandCode: String;
  Address: Word;
  RegParser: TRegularParser;
  CmdCnt, ErrCnt: Integer;
begin
  VIS.SetVisLevel(0);
  if not Assigned(MEM) then
    MEM := TMemory.Create;
  RegParser := TRegularParser.Create;
  Address := 0;
  CmdCnt := 0;
  ErrCnt := 0;
  redtMsg.Lines.Clear;
  for LineIndex := 0 to redtCode.Lines.Count-1 do
    with RegParser, redtCode.Lines do
      if not Strings[LineIndex].Trim.IsEmpty then
      begin
        Inc(CmdCnt);
        if ParseCommand(Strings[LineIndex], CommandCode) then
        begin
          if ErrCnt = 0 then
            if not WriteCode(CommandCode, MEM, Address) then
              redtMsg.Lines.Add('Ошибка записи команды в память (строка: ' + IntToStr(LineIndex + 1) + ')');
        end
        else
        begin
          Inc(ErrCnt);
          redtMsg.Lines.Add('Ошибка трансляции команды (строка: ' + IntToStr(LineIndex + 1) + ')');
        end;
      end;
  if ErrCnt > 0 then
    redtMsg.Lines.Add('Трансляция программы не завершена')
  else
    redtMsg.Lines.Add('Программа успешно транслирована в память');
  redtMsg.Lines.Add(Format('Ошибок: %d%sВсего обработано команд: %d', [ErrCnt, #13#10, CmdCnt]));
  Vis.UpdateMemory(MEM.Cells);
end;

procedure TfrmEditor.btnRunRealClick(Sender: TObject);
begin
  VIS.SetVisLevel(1);
  if Assigned(MEM) then
  begin
    SendMessage(Application.MainForm.Handle, WM_CONTROLS, 0, 0);
    if not Assigned(CPU) then
      CPU := TProcessor.Create(VIS, MEM, 0);
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
      CPU := TProcessor.Create(VIS, MEM, 0);
    CPU.OnTerminate := OnTerm;
    CPU.CmdInit;
    CPU.StepInit;
    CPU.Start;
  end;
end;

procedure TfrmEditor.btnNextCmdClick(Sender: TObject);
begin
  CPU.CmdSkip;
end;

procedure TfrmEditor.btnNextStepClick(Sender: TObject);
begin
  CPU.StepSkip;
end;

procedure TfrmEditor.btnStopClick(Sender: TObject);
begin
  VIS.SetVisLevel(0);
  CPU.Terminate;
  CPU.CmdSkip;
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

procedure TfrmEditor.miFileExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmEditor.miHelpAboutClick(Sender: TObject);
begin
  frmAbout.ShowModal;
end;

procedure TfrmEditor.miViewArrangeFHDClick(Sender: TObject);
begin
  frmEditor.Left := 10;
  frmEditor.Top := 10;
  frmScheme.Left := frmEditor.Left + frmEditor.Width + 10;
  frmScheme.Top := 10;
  frmMemory.Left := frmScheme.Left + frmScheme.Width + 10;
  frmMemory.Top := 10;
end;

procedure TfrmEditor.miViewArrangeHDClick(Sender: TObject);
begin
  frmEditor.Left := 10;
  frmEditor.Top := 10;
  frmScheme.Left := 40;
  frmScheme.Top := 40;
  frmMemory.Left := frmScheme.Left + frmScheme.Width + 10;
  frmMemory.Top := 40;
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
  //Свои контролы
  btnRunReal.Enabled              := NewState;
  btnRunStep.Enabled              := NewState;
  btnStop.Enabled                 := not NewState;
  btnNextCmd.Enabled              := not NewState;
  btnNextStep.Enabled             := not NewState;
  btnMemClear.Enabled             := NewState;
  btnMemAssembly.Enabled          := NewState;
  //
  btnTextNew.Enabled              := NewState;
  btnTextOpen.Enabled             := NewState;
  btnTextSave.Enabled             := NewState;
  btnTextSaveAs.Enabled           := NewState;
  btnDumpLoad.Enabled             := NewState;
  //Меню
  miSourceNew.Enabled             := btnTextNew.Enabled;
  miSourceOpen.Enabled            := btnTextOpen.Enabled;
  miSourceSave.Enabled            := btnTextSave.Enabled;
  miSourceSaveAs.Enabled          := btnTextSaveAs.Enabled;
  miMemLoad.Enabled               := btnDumpLoad.Enabled;
  miMemClear.Enabled              := btnMemClear.Enabled;
  miMemAssembly.Enabled           := btnMemAssembly.Enabled;
  miRunReal.Enabled               := btnRunReal.Enabled;
  miRunStep.Enabled               := btnRunStep.Enabled;
  miStop. Enabled                 := btnStop.Enabled;
  miNextCmd.Enabled               := btnNextCmd.Enabled;
  miNextStep.Enabled              := btnNextStep.Enabled;
  //Удаленные контролы
  frmScheme.btnNextStep.Visible   := btnNextStep.Enabled;
  frmScheme.btnNextCmd.Visible    := btnNextCmd.Enabled;
  frmScheme.btnStop.Visible       := btnStop.Enabled;
end;

procedure TfrmEditor.RemoteControl(var Message: TMessage);
begin
  case Message.WParam of
    1: btnNextStep.Click;
    2: btnNextCmd.Click;
    3: btnStop.Click;
  end;
end;

procedure TfrmEditor.UpdateValue;
begin
  //WParamHi - код
  //WParamLo - значение
  //LParamLo - адрес
  with Message do
    case WParamHi of
      6:          begin     //Память
                    if Assigned(MEM) then
                    begin
                      MEM.Write(LParamLo, Lo(WParamLo));
                      VIS.UpdateMemory(MEM.Cells);
                      VIS.HighlightMemoryCell(LParamLo);
                      end;
                  end;
      0..5, 7..9: begin     //Регистры общего назначения, временные, аккумулятор
                    if Assigned(CPU) then
                    begin
                      //CPU.SetDataReg(TDataReg(WParamHi), Lo(WParamLo));
                      CPU.Registers.DataRegisters[TDataReg(WParamHi)] := Lo(WParamLo);
                      VIS.UpdateScheme(CPU.Registers);
                      VIS.HighlightDataReg(TDataReg(WParamHi));
                    end;
                    //VIS.HighlightMemoryCell(LParamLo);
                  end;
      11:         begin     //Stack Pointer
                    if Assigned(CPU) then
                    begin
                      CPU.Registers.SP := WParamLo;
                      VIS.UpdateScheme(CPU.Registers);
                      VIS.HighlightStackPointer;
                    end;
                  end;
      12:         begin     //Program Counter
                    if Assigned(CPU) then
                    begin
                      CPU.Registers.PC := WParamLo;
                      VIS.UpdateScheme(CPU.Registers);
                      VIS.HighlightProgramCounter;
                    end;
                  end;
    end;
end;

end.
