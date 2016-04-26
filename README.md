Delphi & Arduino - MySensors <hr>

Biblioteca de component Delphi que implementa o protocolo  <a href="http://www.mysensors.org"> MySensors.org </a>

1) instalar a biblioteca no Delphi;
2) Componentes
  
  // cria infraestrutura para troca de informações com o Gateway
  TMySensors = class(TComponent)
  private
  public
    function Ativar: Boolean;
    procedure Desativar;
  published
    property Ativo: Boolean read GetAtivo;
    property Gateway: TMySensorsGatewayClass read FGateway write SetGateway;
    property Modelo: TMySensorsGateway read FModelo write SetModelo;
 end;

  // Gateway Serial
  TMySensorSerialGateway = class(TMySensorsGatewayClass)
  private
  public
    function GetModelo: TMySensorsGateway; override;
  published
    property Porta;
    property PortaConfig;
    property TimeOut: integer read FTimeOut write SetTimeOut;
    property Intervalo: integer read FIntervalo write SetIntervalo;
  end;
  
3) Criar: a) TMySensors   b) TMySensorSerialGateway
          - Ligar o Gateway com o TMySensors
          - Configurar a porta serial
          
4) ao iniciar a aplicar ->    MySensors1.Ativar;


Dependências: ACBrSerial
          
          
          
  
  
