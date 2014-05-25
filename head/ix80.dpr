program ix80;

uses
  Vcl.Forms,
  FormEditor in 'FormEditor.pas' {frmEditor},
  FormMemory in 'FormMemory.pas' {frmMemory},
  FormScheme in 'FormScheme.pas' {frmScheme},
  Common in 'Common.pas',
  Logic in 'Logic.pas',
  FormAbout in 'FormAbout.pas' {frmAbout};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmEditor, frmEditor);
  Application.CreateForm(TfrmMemory, frmMemory);
  Application.CreateForm(TfrmScheme, frmScheme);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.Run;
end.
