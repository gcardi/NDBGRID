program Test;

uses
  System.SysUtils,
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  FormMain in 'FormMain.pas' {Form1},
  DataMod in 'DataMod.pas' {dmDatabase: TDataModule};

{$R *.res}

begin
  try
    Application.Initialize;
    Application.MainFormOnTaskBar := True;
    Application.CreateForm(TForm1, Form1);
    Application.Run;
  except
    on E: Exception do
      Application.ShowException(E);
  end;
end.
