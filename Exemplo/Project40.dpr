program Project40;

uses
  Vcl.Forms,
  Unit48 in 'Unit48.pas' {Form48};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm48, Form48);
  Application.Run;
end.
