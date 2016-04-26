object Form48: TForm48
  Left = 0
  Top = 0
  Caption = 'Form48'
  ClientHeight = 410
  ClientWidth = 753
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 24
    Top = 24
    Width = 577
    Height = 274
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object Button1: TButton
    Left = 640
    Top = 80
    Width = 75
    Height = 25
    Caption = 'Ativar'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 640
    Top = 111
    Width = 75
    Height = 25
    Caption = 'Desligar'
    TabOrder = 2
    OnClick = Button2Click
  end
  object LabeledEdit1: TLabeledEdit
    Left = 624
    Top = 53
    Width = 121
    Height = 21
    EditLabel.Width = 55
    EditLabel.Height = 13
    EditLabel.Caption = 'Porta Serial'
    TabOrder = 3
    Text = 'COM6'
  end
  object MySensors1: TMySensors
    Gateway = MySensorSerialGateway1
    Modelo = sgSerial
    Left = 64
    Top = 24
  end
  object MySensorSerialGateway1: TMySensorSerialGateway
    OnEventoRecebido = MySensorSerialGateway1EventoRecebido
    Porta = 'COM6'
    PortaConfig = 'BAUD=115200 DATA=8 PARITY=N STOP=1,5 HANDSHAKE=RTS/CTS'
    TimeOut = 0
    Intervalo = 1000
    Left = 200
    Top = 24
  end
end
