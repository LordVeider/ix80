program ix80;

uses
  Vcl.Forms,
  FormEditor in 'FormEditor.pas' {frmEditor},
  FormMemory in 'FormMemory.pas' {frmMemory},
  FormScheme in 'FormScheme.pas' {frmScheme},
  Common in 'Common.pas',
  Logic in 'Logic.pas',
  FormAbout in 'FormAbout.pas' {frmAbout},
  FormValue in 'FormValue.pas' {frmValue},
  Instructions in 'Instructions.pas',
  Parser in 'Parser.pas',
  Visualizer in 'Visualizer.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'ix80';
  Application.CreateForm(TfrmEditor, frmEditor);
  Application.CreateForm(TfrmMemory, frmMemory);
  Application.CreateForm(TfrmScheme, frmScheme);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmValue, frmValue);
  Application.Run;
end.
