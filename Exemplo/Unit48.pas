unit Unit48;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, MySensorsClass,MySensors, Vcl.StdCtrls,
  Vcl.ExtCtrls;

type
  TForm48 = class(TForm)
    MySensors1: TMySensors;
    MySensorSerialGateway1: TMySensorSerialGateway;
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    LabeledEdit1: TLabeledEdit;
    procedure MySensorSerialGateway1EventoRecebido(sender: TObject;
      msg: TMySensorsMsg);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form48: TForm48;

implementation

{$R *.dfm}

procedure TForm48.Button1Click(Sender: TObject);
begin
  if not MySensors1.Ativo then
  begin
     MySensorSerialGateway1.Porta := LabeledEdit1.text;
     MySensors1.Ativar
  end;
end;

procedure TForm48.Button2Click(Sender: TObject);
begin
   MySensors1.Desativar;
end;

procedure TForm48.MySensorSerialGateway1EventoRecebido(sender: TObject;
  msg: TMySensorsMsg);
begin
   memo1.Lines.Add(msg.json);
end;

end.
