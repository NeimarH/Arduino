unit MySensorsClass;

interface

uses
  System.SysUtils, System.Classes, synaser, MySensors, ACBrBase;

type
  TMySensorsGateway = (sgNone, sgSerial, sgEthernet);

  TMySensorsGatewayClass = class;

  TMySensorsMessageEvent = procedure(sender: TObject; msg: TMySensorsMsg)
    of object;

  TMySensorsSensor = class(TObject)
  private
    Fsensor_id: integer;
    FAttribute: TMySensorsMsg;
    procedure Setsensor_id(const Value: integer);
    procedure SetPayload(const Value: string);
    procedure SetAttribute(const Value: TMySensorsMsg);
    function GetPayload: string;
  public
    property sensor_id: integer read Fsensor_id write Setsensor_id;
    property Attribute: TMySensorsMsg read FAttribute write SetAttribute;
    property Payload : string read GetPayload write SetPayload;
  end;

  TThreadListHelper<T: class> = class(TThreadList)
  public
    function count: integer;
    procedure delete(idx: integer);
  end;

  TMySensorsSensors = class(TThreadListHelper<TMySensorsSensor>)
  private
    function GetItems(idx: integer): TMySensorsSensor;
    procedure SetItems(idx: integer; const Value: TMySensorsSensor);
  public
    property Items[idx: integer]: TMySensorsSensor read GetItems write SetItems;
    function Find(sensor_id: integer): TMySensorsSensor;
    Function AddSensor(sensor_id: integer): TMySensorsSensor;

  end;

  TMySensorsNode = class(TComponent)
  private
    FNode_id: integer;
    FtimeStamp: TDatetime;
    FSensors: TMySensorsSensors;
    FUltimaMsg: TMySensorsMsg;
    procedure SetNode_id(const Value: integer);
    procedure SetSensors(const Value: TMySensorsSensors);
    procedure SettimeStamp(const Value: TDatetime);
    procedure SetUltimaMsg(const Value: TMySensorsMsg);

  public
    NivelBateria: string;
    Repetidor: Boolean;
    RepetidorVersao: string;
    modulo_nome: string;
    modulo_versao: string;
    constructor create(AOwnder: TComponent);
    destructor destroy; override;
    function FindSensor(sensor_id: integer): TMySensorsSensor;
    function AddSensor(sensor_id: integer): TMySensorsSensor;
    property Node_id: integer read FNode_id write SetNode_id;
    property timeStamp: TDatetime read FtimeStamp write SettimeStamp;
    property UltimaMsg: TMySensorsMsg read FUltimaMsg write SetUltimaMsg;
    property Sensors: TMySensorsSensors read FSensors write SetSensors;

  end;

  TMySensorsNodes = class(TThreadListHelper<TMySensorsNode>)
  private
    function GetItems(idx: integer): TMySensorsNode;
    procedure SetItems(idx: integer; const Value: TMySensorsNode);
  public
    destructor destroy;
    function Find(Node_id, sensor_id: integer): TMySensorsSensor; overload;
    function Find(Node_id: integer): TMySensorsNode; overload;
    property Items[idx: integer]: TMySensorsNode read GetItems write SetItems;
    function AddNode(AOwner: TComponent; Node_id: integer): TMySensorsNode;
  end;

  TMySensors = class(TComponent)
  private
    FAtivo: Boolean;
    FGateway: TMySensorsGatewayClass;
    FModelo: TMySensorsGateway;
    procedure SetModelo(const Value: TMySensorsGateway);
    function GetAtivo: Boolean;
    procedure SetAtivo(const Value: Boolean);
    procedure SetGateway(const Value: TMySensorsGatewayClass); virtual;
  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    constructor create(ow: TComponent); override;
    destructor destroy; override;
    function Ativar: Boolean;
    procedure Desativar;
  published
    property Ativo: Boolean read GetAtivo;
    property Gateway: TMySensorsGatewayClass read FGateway write SetGateway;
    property Modelo: TMySensorsGateway read FModelo write SetModelo;

  end;

  TMySendsosAcceptIDEvent = procedure(sender: TObject; ANodeID: integer;
    var AAccept: Boolean) of object;
  TMySendsosAcceptSensorIDEvent = procedure(sender: TObject;
    ANodeID, ASensorID: integer; var AAccept: Boolean) of object;
  TMySensorsAddSensorEvent = procedure(sender: TObject; ANode: TMySensorsNode;
    Asensor: TMySensorsSensor) of object;
  TMySensorsAddNodeEvent = procedure(sender: TObject; ANode: TMySensorsNode)
    of object;
  TMySensorsOLogEvento = procedure(sender: TObject; const ATexto: string;
    var AContinuar: Boolean) of object;
  TMySensorsPayloadChanged = procedure(sender: TObject;
    Asensor: TMySensorsSensor) of object;

  TMySensorsGatewayClass = class(TComponent)
  private
    FLock: TObject;
    FUltimoEvento: string;
    fs_Sufixo: string;
    FusarFila: Boolean;
    FPorta: string;
    FPortaConfig: string;
    FOnEventoRecebido: TMySensorsMessageEvent;
    FOnInternalEvento: TMySensorsMessageEvent;
    FOnReqEvento: TMySensorsMessageEvent;
    FOnPresentationEvento: TMySensorsMessageEvent;
    FOnNodeSensorEvento: TMySensorsMessageEvent;
    FOnStreamEvento: TMySensorsMessageEvent;
    FOnAddSensorEvent: TMySensorsAddSensorEvent;
    FOnAddNodeEvent: TMySensorsAddNodeEvent;
    FOnBeforeAddNode: TMySendsosAcceptIDEvent;
    FOnBeforeAddSensorEvent: TMySendsosAcceptSensorIDEvent;
    FOnTextoEvento: TMySensorsOLogEvento;
    FOnSetEvento: TMySensorsMessageEvent;
    FOnEventoEnviado: TMySensorsMessageEvent;
    FOnPayloadChanged: TMySensorsPayloadChanged;
    FInclusaoDeModulos: Boolean;
    FOnInclusaoModoAlterado: TNotifyEvent;
    procedure SetusarFila(const Value: Boolean);
    procedure SetPorta(const Value: string); virtual;
    function GetPorta: string; virtual;
    function GetPortaConfig: string; virtual;
    procedure SetPortaConfig(const Value: string); virtual;
    procedure SetOnEventoRecebido(const Value: TMySensorsMessageEvent);
    procedure SetOnInternalEvento(const Value: TMySensorsMessageEvent);
    procedure SetOnReqEvento(const Value: TMySensorsMessageEvent);
    procedure SetOnPresentationEvento(const Value: TMySensorsMessageEvent);
    procedure SetOnNodeSensorEvento(const Value: TMySensorsMessageEvent);
    procedure SetOnStreamEvento(const Value: TMySensorsMessageEvent);
    function GetNodes:TMySensorsNodes;
    procedure SetOnAddSensorEvent(const Value: TMySensorsAddSensorEvent);
    procedure SetOnAddNodeEvent(const Value: TMySensorsAddNodeEvent);
    procedure SetOnBeforeAddNode(const Value: TMySendsosAcceptIDEvent);
    procedure SetOnBeforeAddSensorEvent(const Value
      : TMySendsosAcceptSensorIDEvent);
    procedure SetOnTextoEvento(const Value: TMySensorsOLogEvento);
    procedure SetOnSetEvento(const Value: TMySensorsMessageEvent);
    procedure SetOnEventoEnviado(const Value: TMySensorsMessageEvent);
    procedure SetOnPayloadChanged(const Value: TMySensorsPayloadChanged);
    procedure SetInclusaoDeModulos(const Value: Boolean);
    procedure SetOnInclusaoModoAlterado(const Value: TNotifyEvent);
  protected
    FEntrouInclusaoModulos: TDatetime;
    FNodes: TMySensorsNodes;
    FIniFile: string;
    FFila: TStringList;
    FAtivo: Boolean;
    FOnLeEvento: TNotifyEvent;
    FOnLeFila: TNotifyEvent;
    procedure SaveBatteryLevel(att: TMySensorsMsg);
    procedure AddFila(sTexto: string); virtual;
    procedure SetUltimoEvento(const Value: string);
    procedure SetOnLeEvento(const Value: TNotifyEvent);
    procedure SetOnLeFila(const Value: TNotifyEvent);
    function GetFilaCount: integer;
    procedure sendIdRequest(att: TMySensorsMsg);
    procedure Lock;
    procedure UnLock;
    procedure Sincronizar(const AProc: TProc);

  public

    property InclusaoDeModulos: Boolean read FInclusaoDeModulos write SetInclusaoDeModulos;
    property Porta: string read GetPorta write SetPorta;
    property PortaConfig: string read GetPortaConfig write SetPortaConfig;
    function GetModelo: TMySensorsGateway; virtual;
    function WriteString(cmd: string): Boolean; virtual;
    function RegisterNode(Node_id: integer): TMySensorsNode;
    function RegisterSensor(Node_id, sensor_id: integer): TMySensorsSensor;
    property Nodes: TMySensorsNodes read GetNodes;
    procedure EnviarCMD(att: TMySensorsMsg);
    procedure EnviarReiniciarSensores(selfID: integer);
    procedure EnviarReiniciarMemsagem(att: TMySensorsMsg);
    procedure EnviarMetric(att: TMySensorsMsg);
    procedure EnviarHora(destination, sensor: integer);
    procedure PerguntarPinNumero(node:TMySensorsNode);

    procedure LoadConfig(sIniFile: string); virtual;
    constructor create(ow: TComponent); override;
    destructor destroy; override;

    function LerFila: AnsiString;
    function Ativo: Boolean;
    function Ativar: Boolean; virtual;
    procedure Desativar; virtual;

    property UltimoEvento: string read FUltimoEvento write SetUltimoEvento;
    property FilaCount: integer read GetFilaCount;
    procedure ApagarFila;

  published
    Property Modelo: TMySensorsGateway read GetModelo;
    // property OnLeEvento: TNotifyEvent read FOnLeEvento write SetOnLeEvento;
    // property OnLeFila: TNotifyEvent read FOnLeFila write SetOnLeFila;
    // property usarFila: Boolean read FusarFila write SetusarFila;

    property OnLogEvento: TMySensorsOLogEvento read FOnTextoEvento
      write SetOnTextoEvento;

    property OnEventoRecebido: TMySensorsMessageEvent read FOnEventoRecebido
      write SetOnEventoRecebido;
    property OnEventoEnviado: TMySensorsMessageEvent read FOnEventoEnviado
      write SetOnEventoEnviado;

    property OnPresentationEvento: TMySensorsMessageEvent
      read FOnPresentationEvento write SetOnPresentationEvento;
    property OnInternalEvento: TMySensorsMessageEvent read FOnInternalEvento
      write SetOnInternalEvento;
    property OnSetEvento: TMySensorsMessageEvent read FOnSetEvento
      write SetOnSetEvento;
    property OnReqEvento: TMySensorsMessageEvent read FOnReqEvento
      write SetOnReqEvento;
    property OnStreamEvento: TMySensorsMessageEvent read FOnStreamEvento
      write SetOnStreamEvento;

    property OnNodeSensorEvento: TMySensorsMessageEvent read FOnNodeSensorEvento
      write SetOnNodeSensorEvento;

    property OnAfterAddSensorEvento: TMySensorsAddSensorEvent
      read FOnAddSensorEvent write SetOnAddSensorEvent;
    property OnAfterAddNodeEvento: TMySensorsAddNodeEvent read FOnAddNodeEvent
      write SetOnAddNodeEvent;
    property OnBeforeAddNodeEvento: TMySendsosAcceptIDEvent
      read FOnBeforeAddNode write SetOnBeforeAddNode;
    property OnBeforeAddSensorEvento: TMySendsosAcceptSensorIDEvent
      read FOnBeforeAddSensorEvent write SetOnBeforeAddSensorEvent;

    property OnPayloadChanged: TMySensorsPayloadChanged read FOnPayloadChanged
      write SetOnPayloadChanged;

    property OnInclusaoModoAlterado:TNotifyEvent read FOnInclusaoModoAlterado write SetOnInclusaoModoAlterado;

  end;

  TMySensorEthernetGateway = class(TMySensorsGatewayClass)
  private
    FIP: string;
    procedure SetIP(const Value: string);
  public
    function GetModelo: TMySensorsGateway; override;
  published
    property IP: string read FIP write SetIP;
  end;

  TMySensorSerialGateway = class(TMySensorsGatewayClass)
  private
    fsTimer: TACBrThreadTimer;
    Serial: TBlockSerial;
    FTimeOut: integer;

    fsHardFlow: Boolean;
    fsSoftFlow: Boolean;
    fsParity: Char;
    fsData: integer;
    fsBaud: integer;
    fsStop: integer;
    FIntervalo: integer;
    procedure LeSerial(sender: TObject);
    function GetPortaConfig: string; override;
    procedure SetPortaConfig(const Value: string); override;
    procedure SetTimeOut(const Value: integer);
    procedure ConfiguraSerial;
    function DeviceToString(OnlyException: Boolean): String;
    procedure SetParamsString(const Value: String);
    procedure SetDefaultValues;
    procedure SetIntervalo(const Value: integer);
    function Ativar: Boolean; override;
    procedure Desativar; override;
    procedure LoadConfig(sIniFile: string); override;
    function WriteString(cmd: string): Boolean; override;

    { Private declarations }
  public
    { Public declarations }
    constructor create(ow: TComponent); override;
    destructor destroy; override;
    function GetModelo: TMySensorsGateway; override;
    // property Device: TACBrDevice read FDevice;

  published
    property Porta;
    property PortaConfig;
    property TimeOut: integer read FTimeOut write SetTimeOut;
    property Intervalo: integer read FIntervalo write SetIntervalo;

  end;

Procedure Register;

// var
// SensorSerialGateway: TMySensorSerialGateway;

var
  MySensorsSaveRepeatedValue: array [0 .. 46] of Boolean;

implementation

uses
  System.Threading,
  System.SyncObjs,
{$IFDEF IHOMEWARE}
  iniFilesEx,
{$ENDIF}
  iniFiles;

var
  FLock: TCriticalSection;

Procedure Register;
begin
  RegisterComponents('Sensors', [TMySensors, TMySensorSerialGateway,
    TMySensorEthernetGateway]);
end;

function Now: TDatetime;
begin // torna Now  ThreadSafe
  FLock.Acquire;
  try
    try
      result := System.SysUtils.Now;
    except
    end;
  finally
    FLock.Release;
  end;
end;

procedure TMySensorsGatewayClass.EnviarReiniciarMemsagem(att: TMySensorsMsg);
begin
  att.TxRx := txCommand;
  att.command := C_INTERNAL;
  att.sub_type := I_REBOOT;
  att.Payload := '1';
  att.ack := 1;
  EnviarCMD(att);
end;

procedure TMySensorsGatewayClass.EnviarReiniciarSensores(selfID: integer);
begin
  TTask.run(
    procedure
    var
      i: integer;
      att: TMySensorsMsg;
      msg: string;
    begin
      for i := 0 to 254 do
      begin
        if i <> selfID then
        begin
          att.Node_id := i;
          att.sensor_id := NODE_SENSOR_ID;
          att.command := C_INTERNAL;
          att.sub_type := I_REBOOT;
          att.ack := 1;
          att.Payload := '1';
          att.TxRx := txCommand;
          EnviarCMD(att);
          sleep(200);
        end;
      end;
    end);
end;

procedure TMySensorsGatewayClass.EnviarMetric(att: TMySensorsMsg);
var
  cmd: string;
begin
  att.TxRx := txCommand;
  att.ack := 0;
  att.command := C_INTERNAL;
  att.sub_type := I_CONFIG;
  att.Payload := 'M';
  EnviarCMD(att);
end;

procedure TMySensorsGatewayClass.sendIdRequest(att: TMySensorsMsg);
var
  cmd: String;
  id: integer;
begin
  id := FNodes.count - 1;
  inc(id);
  cmd := EncodeMySensorMsg(BROADCAST_ADDRESS, NODE_SENSOR_ID, C_INTERNAL, 0,
    I_ID_RESPONSE, IntToStr(id));
  FNodes.AddNode(self, id);

  WriteString(cmd);
  if assigned(FOnEventoEnviado) then
    FOnEventoEnviado(self, att);

end;

procedure TMySensorsGatewayClass.EnviarHora(destination, sensor: integer);
var
  cmd: string;
  att: TMySensorsMsg;
begin
  att.Node_id := destination;
  att.sensor_id := sensor;
  att.command := C_INTERNAL;
  att.ack := 0;
  att.sub_type := I_TIME;
  att.Payload := FormatDateTime('hh:mm:ss', Now);
  EnviarCMD(att);
end;

procedure TMySensorsGatewayClass.AddFila(sTexto: string);
var
  att: TMySensorsMsg;
  node: TMySensorsNode;
  sensor: TMySensorsSensor;
  continuar: Boolean;
  oldPayload:string;
begin

  TMonitor.Enter(FLock);
  try
    TThread.Synchronize(TThread.Current,
      procedure
      begin
        continuar := true;
        if assigned(FOnTextoEvento) then
          FOnTextoEvento(self, sTexto, continuar);
        if not continuar then
          exit;

        if FusarFila then
        begin
          if FFila.count > 1000 then
            FFila.delete(0);
          FFila.Add(sTexto);
        end;

        att := DecodeMySensorMsg(sTexto);
        att.TxRx := rxCommand;

        if assigned(FOnEventoRecebido) then
          FOnEventoRecebido(self, att);

        node := FNodes.Find(att.Node_id);
        if FInclusaoDeModulos and (not assigned(node)) then
        begin
          if Now > FEntrouInclusaoModulos + strToTime('00:02:00') then
            InclusaoDeModulos := false;
          if FInclusaoDeModulos then
            node := RegisterNode(att.Node_id);
        end;
        if not assigned(node) then
          exit; // modulo não registrado

        sensor := node.FindSensor(att.sensor_id);
        if not assigned(sensor) then
        begin
          sensor := RegisterSensor(att.Node_id, att.sensor_id);
          if sensor = nil then
            exit;
        end;

        oldPayload := sensor.payload;
        sensor.Attribute := att;

        case att.internal_sub_type of
          I_SKETCH_NAME:
            node.modulo_nome := att.Payload;
          I_SKETCH_VERSION:
            node.modulo_versao := att.Payload;

          I_REBOOT:
            begin
              EnviarReiniciarMemsagem(att);
              exit;
            end;
          I_BATTERY_LEVEL:
            begin
              SaveBatteryLevel(att);
              exit;
            end;
          I_ID_REQUEST:
            begin
              sendIdRequest(att);
              exit;
            end;
          I_CONFIG:
            EnviarMetric(att);
          // I_GATEWAY_READY:
          // SendRebootSensores(att.Node_id);
        end;

        case att.presentation_sub_type of
          S_ARDUINO_REPEATER_NODE:
            begin
              node := FNodes.Find(att.Node_id);
              if assigned(node) then
              begin
                node.Repetidor := true;
                node.RepetidorVersao := att.Payload;
              end;
              exit;
            end;
        end;

        case att.command of
          C_PRESENTATION:
            if assigned(FOnPresentationEvento) then
              FOnPresentationEvento(self, att);

          C_SET:
            if assigned(FOnSetEvento) then
              FOnSetEvento(self, att);
          C_REQ:
            if assigned(FOnReqEvento) then
              FOnReqEvento(self, att);
          C_INTERNAL:
            if assigned(FOnInternalEvento) then
              FOnInternalEvento(self, att);
          C_STREAM:
            if assigned(FOnStreamEvento) then
              FOnStreamEvento(self, att);

        end;

        if att.Node_id = NODE_SENSOR_ID then
          if assigned(FOnNodeSensorEvento) then
            FOnNodeSensorEvento(self, att);

        if assigned(sensor) then
        begin
          if (att.command = C_SET) and assigned(FOnPayloadChanged) and
            ((MySensorsSaveRepeatedValue[att.sub_type]) or
            (att.Payload <> oldPayload)) then
          begin
            sensor.Attribute := att;
            FOnPayloadChanged(self, sensor);
          end
          else
            sensor.Attribute := att;
        end;

      end);
  finally
    TMonitor.exit(FLock);
  end;
end;

procedure TMySensorsGatewayClass.ApagarFila;
begin
  FFila.Clear;
end;

function TMySensorSerialGateway.Ativar: Boolean;
begin
  try
    fsTimer.Enabled := false;
    Serial.CloseSocket; { Fecha se ficou algo aberto }
    Serial.DeadlockTimeout := (TimeOut * 1000);
    Serial.Connect(FPorta);
    ConfiguraSerial;
    Serial.Purge; { Limpa Buffer de envio e recepção }
    fsTimer.Enabled := true;
  except
    on E: ESynaSerError do
    begin
      try
        Serial.RaiseExcept := false;
        Serial.CloseSocket;
      finally
        Serial.RaiseExcept := true;
      end;

{$IFDEF MSWINDOWS}
      // SysErrorMessage() em Windows retorna String em ANSI, convertendo para UTF8 se necessário
      // E.Message := ACBrStr(E.Message);
{$ENDIF}
      raise;
    end
    else
      raise;
  end;
  FAtivo := true;
end;

function TMySensorsGatewayClass.Ativar: Boolean;
begin

end;

function TMySensorsGatewayClass.Ativo: Boolean;
begin
  result := FAtivo;
end;

constructor TMySensorsGatewayClass.create(ow: TComponent);
begin
  inherited;
  FLock := TObject.create;
  FEntrouInclusaoModulos := Now;
  FInclusaoDeModulos := true;
  FNodes := TMySensorsNodes.create;
  FFila := TStringList.create;
  FusarFila := true;
  fs_Sufixo := #$A;

end;

procedure TMySensorsGatewayClass.Desativar;
begin

end;

destructor TMySensorsGatewayClass.destroy;
begin
  FFila.free;
  FNodes.free;
  FLock.free;
  inherited;
end;

procedure TMySensorSerialGateway.Desativar;
begin
  if not Ativo then
    exit;
  fsTimer.Enabled := false;
  Serial.RaiseExcept := false;
  Serial.CloseSocket;
  FAtivo := false;
end;

destructor TMySensorSerialGateway.destroy;
begin
  try
    Desativar;
  finally
    Serial.free;
    fsTimer.free;
  end;
  inherited;
end;

function TMySensorsGatewayClass.GetFilaCount: integer;
begin
  result := FFila.count;
end;

function TMySensorsGatewayClass.GetModelo: TMySensorsGateway;
begin
  result := sgNone;
end;

function TMySensorsGatewayClass.GetNodes:TMySensorsNodes;
begin
  result :=FNodes;
end;

function TMySensorsGatewayClass.GetPorta: string;
begin
  result := FPorta;
end;

function TMySensorSerialGateway.GetModelo: TMySensorsGateway;
begin
  result := sgSerial;
end;

function TMySensorSerialGateway.GetPortaConfig: string;
begin
  FPortaConfig := DeviceToString(false);
  result := FPortaConfig;
end;

function TMySensorsGatewayClass.GetPortaConfig: string;
begin
  result := FPortaConfig;
end;

procedure TMySensorSerialGateway.LeSerial(sender: TObject);
var
  leitura: String;
  OldRaiseExcept: Boolean;
  n: integer;
begin
  fsTimer.Enabled := false;
  try
    with Serial do
    begin
      if InstanceActive then
      begin
        n := -1;
        while n <> 0 do
        begin
          Lock;
          try
            n := WaitingDataEx;
          finally
            UnLock;
          end;
          if n = 0 then
            break;
          leitura := '';
          if fs_Sufixo <> '' then
          begin
            OldRaiseExcept := RaiseExcept;
            try
              RaiseExcept := false;
              Lock;
              try
                leitura := RecvTerminated(200, fs_Sufixo);
              finally
                UnLock;
              end;
              if leitura <> '' then
                leitura := leitura + fs_Sufixo;
            finally
              RaiseExcept := OldRaiseExcept;
            end;
          end
          else
            try
              Lock;
              leitura := RecvPacket(200);
            finally
              UnLock;
            end;

          if leitura <> '' then
          begin
            Sincronizar(
              procedure
              begin
                Try
                  SetUltimoEvento(leitura);
                  AddFila(leitura);
                  if assigned(FOnLeEvento) then
                    FOnLeEvento(self);
                except
                end;
              end);
          end;

        end;
      end;
    end;
  finally
    fsTimer.Enabled := true;
  end;
end;

procedure TMySensorSerialGateway.LoadConfig(sIniFile: string);
begin
  if sIniFile = '' then
    sIniFile := FIniFile;
  inherited LoadConfig(sIniFile);

  if sIniFile <> '' then
    with TIniFile.create(sIniFile) do
      try
        FPorta := ReadString('MySensors', 'Porta', FPorta);
        FPortaConfig := ReadString('MySensors', 'PortaConfig', FPortaConfig);
      finally
        free;
      end;
end;

procedure TMySensorSerialGateway.ConfiguraSerial;
begin
  if not Serial.InstanceActive then
    exit;
  Serial.Config(fsBaud, fsData, fsParity, fsStop, fsSoftFlow, fsHardFlow);
  Serial.RTS := true;
  Serial.DTR := false;

end;

constructor TMySensorSerialGateway.create(ow: TComponent);
begin
  inherited;
  FIniFile := 'MySensors.ini';
  Serial := TBlockSerial.create();
  SetDefaultValues;
  fsTimer := TACBrThreadTimer.create();
  fsTimer.OnTimer := LeSerial;
  Intervalo := 1000;
end;

procedure TMySensorSerialGateway.SetPortaConfig(const Value: string);
begin
  SetParamsString(Value);
end;

procedure TMySensorSerialGateway.SetTimeOut(const Value: integer);
begin
  FTimeOut := Value;
end;

function TMySensorSerialGateway.WriteString(cmd: string): Boolean;
begin
  inherited WriteString(cmd);
  Lock;
  try
    Serial.SendString(cmd);
  finally
    UnLock;
  end;
end;

procedure TMySensorsGatewayClass.SetUltimoEvento(const Value: string);
begin
  FUltimoEvento := Value;
end;

procedure TMySensorsGatewayClass.SetusarFila(const Value: Boolean);
begin
  FusarFila := Value;
end;

procedure TMySensorsGatewayClass.Sincronizar(const AProc: TProc);
begin
  AProc;
  { TTask.run(
    procedure
    begin
    tthread.Queue(tthread.CurrentThread,
    procedure
    begin
    AProc;
    end);
    end);
  }
end;

procedure TMySensorsGatewayClass.UnLock;
begin
  System.TMonitor.exit(FLock);
end;

function TMySensorsGatewayClass.WriteString(cmd: string): Boolean;
var
  continuar: Boolean;
begin
  continuar := true;
  if assigned(FOnTextoEvento) then
    FOnTextoEvento(self, cmd, continuar);
  if not continuar then
    abort;
end;

function TMySensorSerialGateway.DeviceToString(OnlyException: Boolean): String;
Var
  sStop, sHandShake: String;
begin
  result := '';

  if (not OnlyException) or (fsBaud <> 9600) then
    result := result + ' BAUD=' + IntToStr(fsBaud);

  if (not OnlyException) or (fsData <> 8) then
    result := result + ' DATA=' + IntToStr(fsData);

  if (not OnlyException) or (fsParity <> 'N') then
    result := result + ' PARITY=' + fsParity;

  if (not OnlyException) or (fsStop <> 0) then
  begin
    if fsStop = 2 then
      sStop := '2'
    else if fsStop = 1 then
      sStop := '1,5'
    else
      sStop := '1';

    result := result + ' STOP=' + sStop;
  end;

  { if (not OnlyException) or (fsHandShake <> hsNenhum) then
    begin
    if fsHandShake = hsXON_XOFF then
    sHandShake := 'XON/XOFF'
    else if fsHandShake = hsDTR_DSR then
    sHandShake := 'DTR/DSR'
    else if fsHandShake = hsRTS_CTS then
  } sHandShake := 'RTS/CTS';

  result := result + ' HANDSHAKE=' + sHandShake;
  // end;

  if fsHardFlow then
    result := result + ' HARDFLOW';

  if fsSoftFlow then
    result := result + ' SOFTFLOW';

  { if (not OnlyException) or (MaxBandwidth > 0) then
    result := result + ' MAXBANDWIDTH=' + IntToStr(MaxBandwidth);
  }
  result := Trim(result);
end;

procedure TMySensorSerialGateway.SetDefaultValues;
begin
  fsHardFlow := false;
  fsSoftFlow := false;
  // fsHandShake:= hsNenhum ;

  fsBaud := 115200;
  fsParity := 'N';
  fsData := 8;
  fsStop := 1;

  // PosImp.X   := 0 ;
  // PosImp.Y   := 0 ;
end;

procedure TMySensorSerialGateway.SetIntervalo(const Value: integer);
var
  old: Boolean;
begin
  FIntervalo := Value;
  old := fsTimer.Enabled;
  fsTimer.Enabled := false;
  fsTimer.Interval := Value;
  fsTimer.Enabled := old;
end;

procedure TMySensorsGatewayClass.SetInclusaoDeModulos(const Value: Boolean);
begin
  if FInclusaoDeModulos = Value then exit;
  FInclusaoDeModulos := Value;
  if value then
     FEntrouInclusaoModulos := now;
  if assigned(FOnInclusaoModoAlterado) then
     OnInclusaoModoAlterado(self);
end;

procedure TMySensorsGatewayClass.SetOnAddNodeEvent
  (const Value: TMySensorsAddNodeEvent);
begin
  FOnAddNodeEvent := Value;
end;

procedure TMySensorsGatewayClass.SetOnAddSensorEvent
  (const Value: TMySensorsAddSensorEvent);
begin
  FOnAddSensorEvent := Value;
end;

procedure TMySensorsGatewayClass.SetOnBeforeAddNode
  (const Value: TMySendsosAcceptIDEvent);
begin
  FOnBeforeAddNode := Value;
end;

procedure TMySensorsGatewayClass.SetOnBeforeAddSensorEvent
  (const Value: TMySendsosAcceptSensorIDEvent);
begin
  FOnBeforeAddSensorEvent := Value;
end;

procedure TMySensorsGatewayClass.SetOnReqEvento(const Value
  : TMySensorsMessageEvent);
begin
  FOnReqEvento := Value;
end;

procedure TMySensorsGatewayClass.SetOnEventoEnviado
  (const Value: TMySensorsMessageEvent);
begin
  FOnEventoEnviado := Value;
end;

procedure TMySensorsGatewayClass.SetOnEventoRecebido
  (const Value: TMySensorsMessageEvent);
begin
  FOnEventoRecebido := Value;
end;

procedure TMySensorsGatewayClass.SetOnInclusaoModoAlterado(
  const Value: TNotifyEvent);
begin
  FOnInclusaoModoAlterado := Value;
end;

procedure TMySensorsGatewayClass.SetOnInternalEvento
  (const Value: TMySensorsMessageEvent);
begin
  FOnInternalEvento := Value;
end;

procedure TMySensorsGatewayClass.SetOnLeEvento(const Value: TNotifyEvent);
begin
  FOnLeEvento := Value;
end;

procedure TMySensorsGatewayClass.SetOnLeFila(const Value: TNotifyEvent);
begin
  FOnLeFila := Value;
end;

procedure TMySensorsGatewayClass.SetOnNodeSensorEvento
  (const Value: TMySensorsMessageEvent);
begin
  FOnNodeSensorEvento := Value;
end;

procedure TMySensorsGatewayClass.SetOnPayloadChanged
  (const Value: TMySensorsPayloadChanged);
begin
  FOnPayloadChanged := Value;
end;

procedure TMySensorsGatewayClass.SetOnPresentationEvento
  (const Value: TMySensorsMessageEvent);
begin
  FOnPresentationEvento := Value;
end;

procedure TMySensorsGatewayClass.SetOnSetEvento(const Value
  : TMySensorsMessageEvent);
begin
  FOnSetEvento := Value;
end;

procedure TMySensorsGatewayClass.SetOnStreamEvento
  (const Value: TMySensorsMessageEvent);
begin
  FOnStreamEvento := Value;
end;

procedure TMySensorsGatewayClass.SetOnTextoEvento
  (const Value: TMySensorsOLogEvento);
begin
  FOnTextoEvento := Value;
end;

procedure TMySensorsGatewayClass.SetPorta(const Value: string);
begin
  FPorta := Value;
end;

procedure TMySensorsGatewayClass.SetPortaConfig(const Value: string);
begin

end;

procedure TMySensorSerialGateway.SetParamsString(const Value: String);
Var
  S, Linha: String;
  Function GetValue(LinhaParametros, Parametro: String): String;
  Var
    P: integer;
    Sub: String;
  begin
    result := '';
    P := pos(Parametro, LinhaParametros);

    if P > 0 then
    begin
      Sub := Trim(copy(LinhaParametros, P + Length(Parametro), 200));
      if copy(Sub, 1, 1) = '=' then
        Sub := Trim(copy(Sub, 2, 200));

      P := pos(' ', Sub);
      if P = 0 then
        P := Length(Sub);

      result := Trim(copy(Sub, 1, P));
    end;
  end;

begin
  SetDefaultValues;

  Linha := Trim(UpperCase(Value));

  fsBaud := StrToIntDef(GetValue(Linha, 'BAUD'), fsBaud);

  S := GetValue(Linha, 'PARITY');
  if S <> '' then
    if S[1] in ['O', 'E', 'M', 'S', 'N'] then
      fsParity := S[1];

  fsData := StrToIntDef(GetValue(Linha, 'DATA'), fsData);

  S := GetValue(Linha, 'STOP');
  { if S = '1' then }
  fsStop := { s } 1;
  { else if S = '1,5' then
    fsStop := s1eMeio
    else if S = '2' then
    fsStop := s2;
  }
  { fsHardFlow := (pos('HARDFLOW', Linha) > 0); }
  { fsSoftFlow := (pos('SOFTFLOW', Linha) > 0); }

  { S := GetValue(Linha, 'HANDSHAKE');
    if S = 'XON/XOFF' then
    fsHandShake := hsXON_XOFF
    else if S = 'DTR/DSR' then
    fsHandShake := hsDTR_DSR
    else if S = 'RTS/CTS' then
    fsHandShake := hsRTS_CTS;
  }

  { S := GetValue(Linha, 'MAXBANDWIDTH');
    MaxBandwidth := StrToIntDef(S, MaxBandwidth);
  }
end;

function TMySensorsGatewayClass.LerFila: AnsiString;
begin
  result := '';
  if FFila.count > 0 then
  begin
    result := FFila[0];
    FFila.delete(0);

    SetUltimoEvento(result);
    result := FUltimoEvento;
    if assigned(FOnLeFila) then
      FOnLeFila(self);
  end
end;

procedure TMySensorsGatewayClass.LoadConfig(sIniFile: string);
begin
  FIniFile := sIniFile;
end;

procedure TMySensorsGatewayClass.Lock;
begin
  System.TMonitor.Enter(FLock);
end;

procedure TMySensorsGatewayClass.PerguntarPinNumero(node: TMySensorsNode);
var att:TMySensorsMsg;
    i:integer;
begin
    att.node_id := node.Node_id;
    att.command := C_REQ;
    att.sub_type  := V_LIGHT_LEVEL;
    att.TxRx := txCommand;
    att.payload := '1';
    att.ack := 0;
    for I := 0 to node.Sensors.count-1 do
     if node.Sensors.Items[i].sensor_id<255 then
      begin  // pede o numero de pinagem de todos os sensores no node;
       att.sensor_id := node.Sensors.Items[i].sensor_id;
       EnviarCMD(att);
      end;
end;

function TMySensorsGatewayClass.RegisterNode(Node_id: integer): TMySensorsNode;
var
  continua: Boolean;
begin
  result := nil;
  continua := true;
  if assigned(FOnBeforeAddNode) then
    FOnBeforeAddNode(self, Node_id, continua);
  if not continua then
    exit;
  result := FNodes.Find(Node_id);
  if assigned(result) then
    exit;
  result := FNodes.AddNode(self, Node_id);
  if assigned(FOnAddNodeEvent) then
    FOnAddNodeEvent(self, result);
end;

function TMySensorsGatewayClass.RegisterSensor(Node_id, sensor_id: integer)
  : TMySensorsSensor;
var
  node: TMySensorsNode;
  continua: Boolean;
begin
  result := nil;
  continua := true;
  if assigned(FOnBeforeAddSensorEvent) then
    FOnBeforeAddSensorEvent(self, Node_id, sensor_id, continua);
  if not continua then
    exit;

  node := FNodes.Find(Node_id);
  if not assigned(node) then
  begin
    raise exception.create('Node não existe');
  end;
  result := node.AddSensor(sensor_id);
  if assigned(FOnAddSensorEvent) then
    FOnAddSensorEvent(self, node, result);
end;

procedure TMySensorsGatewayClass.SaveBatteryLevel(att: TMySensorsMsg);
var
  node: TMySensorsNode;
begin
  node := FNodes.Find(att.Node_id);
  if assigned(node) then
    node.NivelBateria := att.Payload;
end;

procedure TMySensorsGatewayClass.EnviarCMD(att: TMySensorsMsg);
var
  msg: string;
begin
  msg := EncodeMySensorMsg(att);
  WriteString(msg);
  if assigned(FOnEventoEnviado) then
    FOnEventoEnviado(self, att);
end;

{ TMySensors }

function TMySensors.Ativar: Boolean;
begin
  if assigned(FGateway) then
    FGateway.Ativar;
end;

constructor TMySensors.create(ow: TComponent);
begin
  inherited;
  Modelo := sgNone;
end;

procedure TMySensors.Desativar;
begin
  if assigned(FGateway) then
    FGateway.Desativar;
end;

destructor TMySensors.destroy;
begin
  inherited;
end;

function TMySensors.GetAtivo: Boolean;
begin
  result := FAtivo;
  if assigned(FGateway) then
    result := FGateway.Ativo;
end;

procedure TMySensors.Notification(AComponent: TComponent;
Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) then
    if FGateway = AComponent then
      FGateway := nil;

end;

procedure TMySensors.SetAtivo(const Value: Boolean);
begin
  FAtivo := Value;
  if assigned(FGateway) then
    FGateway.FAtivo := true;

end;

procedure TMySensors.SetGateway(const Value: TMySensorsGatewayClass);
begin
  FGateway := Value;
  if assigned(FGateway) then
    SetModelo(FGateway.GetModelo);
end;

procedure TMySensors.SetModelo(const Value: TMySensorsGateway);
begin
  { if assigned(FGateway) then
    FGateway.free;
    case Value of
    sgSerial:
    FGateway := TSensorSerialGateway.create(self);
    sgEthernet:
    FGateway := TSensorEthernetGateway.create(self);
    else
    FGateway := TMySensorsGatewayClass.create(self);
    end;
    FGateway.Name := 'MyGateway1';
  }
  FModelo := Value;
  if assigned(FGateway) then
    FGateway.LoadConfig('');
end;

{ TMySensorsNodes<TMySensorsNode> }

function TMySensorsNodes.AddNode(AOwner: TComponent; Node_id: integer)
  : TMySensorsNode;
begin
  result := Find(Node_id);
  if result = nil then
  begin
    result := TMySensorsNode.create(AOwner);
    result.Node_id := Node_id;
    result.timeStamp := Now;
    Add(result);
  end;
end;

destructor TMySensorsNodes.destroy;
var
  obj: TObject;
begin
  while count > 0 do
  begin
    obj := Items[0];
    freeAndNil(obj);
    delete(0);
  end;
  inherited;
end;

function TMySensorsNodes.Find(Node_id: integer): TMySensorsNode;
var
  i: integer;
begin
  result := nil;
  for i := 0 to count - 1 do
    if Items[i].Node_id = Node_id then
    begin
      result := Items[i];
      exit;
    end;

end;

function TMySensorsNodes.Find(Node_id, sensor_id: integer): TMySensorsSensor;
var
  i: integer;
  node: TMySensorsNode;
begin
  result := nil;
  for i := 0 to count - 1 do
  begin
    if (Items[i].Node_id = Node_id) then
    begin
      node := Items[i];
      result := node.FindSensor(sensor_id);
      exit;
    end;
  end;
end;

function TMySensorsNodes.GetItems(idx: integer): TMySensorsNode;
begin
  try
    result := TMySensorsNode(LockList.Items[idx]);
  finally
    UnlockList;
  end;
end;

procedure TMySensorsNodes.SetItems(idx: integer; const Value: TMySensorsNode);
begin
  try
    LockList.Items[idx] := Value;
  finally
    UnlockList;
  end;

end;

{ TMySensorsNode }

function TMySensorsNode.AddSensor(sensor_id: integer): TMySensorsSensor;
begin
  result := Sensors.AddSensor(sensor_id);
end;

constructor TMySensorsNode.create(AOwnder: TComponent);
begin
  inherited;
  FSensors := TMySensorsSensors.create;
end;

destructor TMySensorsNode.destroy;
begin
  FSensors.free;
  inherited;
end;

function TMySensorsNode.FindSensor(sensor_id: integer): TMySensorsSensor;
begin
  result := FSensors.Find(sensor_id);
end;

procedure TMySensorsNode.SetNode_id(const Value: integer);
begin
  FNode_id := Value;
end;

procedure TMySensorsNode.SetSensors(const Value: TMySensorsSensors);
begin
  FSensors := Value;
end;

procedure TMySensorsNode.SettimeStamp(const Value: TDatetime);
begin
  FtimeStamp := Value;
end;

procedure TMySensorsNode.SetUltimaMsg(const Value: TMySensorsMsg);
begin
  FUltimaMsg := Value;
end;

{ TMySensorsSensors }

function TMySensorsSensors.AddSensor(sensor_id: integer): TMySensorsSensor;
begin
  result := Find(sensor_id);
  if result = nil then
  begin
    result := TMySensorsSensor.create;
    result.sensor_id := sensor_id;
    Add(result);
  end;
end;

function TMySensorsSensors.Find(sensor_id: integer): TMySensorsSensor;
var
  i: integer;
begin
  result := nil;
  for i := 0 to count - 1 do
    if Items[i].sensor_id = sensor_id then
    begin
      result := Items[i];
      exit;
    end;
end;

function TMySensorsSensors.GetItems(idx: integer): TMySensorsSensor;
begin
  try
    result := TMySensorsSensor(LockList.Items[idx]);
  finally
    UnlockList;
  end;

end;

procedure TMySensorsSensors.SetItems(idx: integer;
const Value: TMySensorsSensor);
begin
  try
    LockList.Items[idx] := Value;
  finally
    UnlockList;
  end;

end;

{ TThreadListHelper }

function TThreadListHelper<T>.count: integer;
begin
  try
    result := LockList.count;
  finally
    UnlockList;
  end;

end;

procedure TThreadListHelper<T>.delete(idx: integer);
begin
  try
    LockList.delete(idx);
  finally
    UnlockList;
  end;

end;

{ TSensorEthernetGateway }

function TMySensorEthernetGateway.GetModelo: TMySensorsGateway;
begin
  result := sgEthernet;
end;

procedure TMySensorEthernetGateway.SetIP(const Value: string);
begin
  FIP := Value;
end;

{ TMySensorsSensor }

function TMySensorsSensor.GetPayload: string;
begin
   result := Attribute.payload;
end;

procedure TMySensorsSensor.SetAttribute(const Value: TMySensorsMsg);
begin
  FAttribute := Value;
end;

procedure TMySensorsSensor.SetPayload(const Value: string);
begin
  FAttribute.Payload := Value;
end;


procedure TMySensorsSensor.Setsensor_id(const Value: integer);
begin
  Fsensor_id := Value;
end;

initialization

FLock := TCriticalSection.create;

FillChar(MySensorsSaveRepeatedValue, sizeof(MySensorsSaveRepeatedValue), false);

finalization

FLock.free;

end.
