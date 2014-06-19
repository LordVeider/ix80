unit FormAbout;

//ix80 Intel 8080 CPU Emulator & Demonstration Model
//Форма "О программе"

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Imaging.pngimage,
  Vcl.ExtCtrls;

type
  TfrmAbout = class(TForm)
    lblDesc: TLabel;
    imgLogo: TImage;
    lblHeader: TLabel;
    lblVersion: TLabel;
    lblLink: TLabel;
    procedure FormShow(Sender: TObject);
    procedure lblLinkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAbout: TfrmAbout;

implementation

{$R *.dfm}

procedure TfrmAbout.FormShow(Sender: TObject);
type
  TVersion = array [0 .. 3] of SmallInt;
var
  HR: HRSRC;
  Handle: THandle;
  V: ^TVersion;
begin
  HR := FindResource(MainInstance, '#1', RT_VERSION);
  Handle := LoadResource(MainInstance, HR);
  Integer(V) := Integer(LockResource(Handle)) + 48;
  lblVersion.Caption := Format('%s %s.%s.%s.%s', ['Версия', IntToStr(V[1]), IntToStr(V[0]), IntToStr(V[3]), IntToStr(V[2])]);
  UnlockResource(Handle);
  FreeResource(Handle);
end;

procedure TfrmAbout.lblLinkClick(Sender: TObject);
begin
  ShellExecute(0, 'Open', PChar(lblLink.Caption), nil, nil, SW_SHOW);
end;

end.
