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
    sensor_id: integer;
    presentation_id: integer;
  end;

  TThreadListHelper = class(TThreadList)
  public
    function count: integer;
    procedure delete(idx: integer);
  end;

  TMySensorsSensors = class(TThreadListHelper)
  private
    function GetItems(idx: integer): TMySensorsSensor;
    procedure SetItems(idx: integer; const Value: TMySensorsSensor);
  public
    property Items[idx: integer]: TMySensorsSensor read GetItems write SetItems;
    function Find(sensor_id: integer): TMySensorsSensor;
    Function AddSensor(sensor_id: integer): TMySensorsSensor;

  end;

  TMySensorsNode = class(TObject)
    Node_id: integer;
    timeStamp: TDatetime;
    UltimaMsg: TMySensorsMsg;
    Sensors: TMySensorsSensors;
  public
    NivelBateria: string;
    Repetidor: Boolean;
    RepetidorVersao: string;
    modulo_nome: string;
    modulo_versao: string;
    constructor create;
    destructor destroy; override;
    function FindSensor(sensor_id: integer): TMySensorsSensor;
    function AddSensor(sensor_id: integer): TMySensorsSensor;
  end;

  TMySensorsNodes = class(TThreadListHelper)
  private
    function GetItems(idx: integer): TMySensorsNode;
    procedure SetItems(idx: integer; const Value: TMySensorsNode);
  public
    destructor destroy;
    function Find(Node_id, sensor_id: integer): TMySensorsSensor; overload;
    function Find(Node_id: integer): TMySensorsNode; overload;
    property Items[idx: integer]: TMySensorsNode read GetItems write SetItems;
    function AddNode(Node_id: integer): TMySensorsNode;
  end;

  TMySensors = class(TComponent)
  private
    FAtivo:boolean;
    FGateway: TMySensorsGatewayClass;
    FModelo: TMySensorsGateway;
    procedure SetModelo(const Value: TMySensorsGateway);
    function GetAtivo: Boolean;
    procedure SetAtivo(const Value: Boolean);
    procedure SetGateway(const Value: TMySensorsGatewayClass);virtual;
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
    FOnDataEvento: TMySensorsMessageEvent;
    FOnPresentationEvento: TMySensorsMessageEvent;
    FOnNodeSensorEvento: TMySensorsMessageEvent;
    FOnStreamEvento: TMySensorsMessageEvent;
    procedure SetusarFila(const Value: Boolean);
    procedure SetPorta(const Value: string); virtual;
    function GetPorta: string; virtual;
    function GetPortaConfig: string; virtual;
    procedure SetPortaConfig(const Value: string); virtual;
    procedure SetOnEventoRecebido(const Value: TMySensorsMessageEvent);
    procedure SetOnInternalEvento(const Value: TMySensorsMessageEvent);
    procedure SetOnDataEvento(const Value: TMySensorsMessageEvent);
    procedure SetOnPresentationEvento(const Value: TMySensorsMessageEvent);
    procedure SetOnNodeSensorEvento(const Value: TMySensorsMessageEvent);
    procedure SetOnStreamEvento(const Value: TMySensorsMessageEvent);
    procedure GetNodes(const Value: TMySensorsNodes);

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
    emInclusaoDeModulos: Boolean;
    property Porta: string read GetPorta write SetPorta;
    property PortaConfig: string read GetPortaConfig write SetPortaConfig;
    function GetModelo: TMySensorsGateway; virtual;
    function WriteString(cmd: string): Boolean; virtual;
    function RegisterNode(Node_id: integer): TMySensorsNode;
    procedure RegisterSensor(Node_id, sensor_id: integer);
    property Nodes: TMySensorsNodes write GetNodes;
    procedure SendRebootSensores(selfID: integer);
    procedure sendRebootMessage(att: TMySensorsMsg);
    procedure sendConfig(att: TMySensorsMsg);
    procedure sendTime(destination, sensor: integer);

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
    property OnLeEvento: TNotifyEvent read FOnLeEvento write SetOnLeEvento;
    property OnLeFila: TNotifyEvent read FOnLeFila write SetOnLeFila;
    property usarFila: Boolean read FusarFila write SetusarFila;
    property OnEventoRecebido: TMySensorsMessageEvent read FOnEventoRecebido
      write SetOnEventoRecebido;
    property OnInternalEvento: TMySensorsMessageEvent read FOnInternalEvento
      write SetOnInternalEvento;
    property OnDataEvento: TMySensorsMessageEvent read FOnDataEvento
      write SetOnDataEvento;
    property OnPresentationEvento: TMySensorsMessageEvent
      read FOnPresentationEvento write SetOnPresentationEvento;
    property OnStreamEvento: TMySensorsMessageEvent read FOnStreamEvento
      write SetOnStreamEvento;
    property OnNodeSensorEvento: TMySensorsMessageEvent read FOnNodeSensorEvento
      write SetOnNodeSensorEvento;

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

//var
//  SensorSerialGateway: TMySensorSerialGateway;

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
  RegisterComponents('Sensors', [TMySensors,TMySensorSerialGateway, TMySensorEthernetGateway]);
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

procedure TMySensorsGatewayClass.sendRebootMessage(att: TMySensorsMsg);
var
  cmd: string;
begin
  cmd := EncodeMySensorMsg(att.Node_id, NODE_SENSOR_ID, C_INTERNAL, 1,
    I_REBOOT, '1');
  WriteString(cmd);
end;

procedure TMySensorsGatewayClass.SendRebootSensores(selfID: integer);
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
          att.payload := '1';
          msg := EncodeMySensorMsg(att);
          WriteString(msg);
          sleep(200);
        end;
      end;
    end);
end;

procedure TMySensorsGatewayClass.sendConfig(att: TMySensorsMsg);
var
  cmd: string;
begin
  cmd := EncodeMySensorMsg(att.Node_id, NODE_SENSOR_ID, C_INTERNAL, 0, I_CONFIG,
    'M'); // M-Metric
  WriteString(cmd);
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
  FNodes.AddNode(id);

  WriteString(cmd);
end;

procedure TMySensorsGatewayClass.sendTime(destination, sensor: integer);
var
  cmd: string;
begin
  cmd := EncodeMySensorMsg(destination, sensor, C_INTERNAL, 0, I_TIME,
    FormatDateTime('hh:mm:ss', Now));
  WriteString(cmd);
end;

procedure TMySensorsGatewayClass.AddFila(sTexto: string);
var
  att: TMySensorsMsg;
  node: TMySensorsNode;
  sensor: TMySensorsSensor;
begin
  if FusarFila then
  begin
    if FFila.count > 1000 then
      FFila.delete(0);
    FFila.Add(sTexto);
  end;
  att := DecodeMySensorMsg(sTexto);

  if assigned(FOnEventoRecebido) then
    FOnEventoRecebido(self, att);

  node := FNodes.Find(att.Node_id);
  if emInclusaoDeModulos and (not assigned(node)) then
  begin
    if Now > FEntrouInclusaoModulos + strToTime('00:01:00') then
      emInclusaoDeModulos := false;
    if emInclusaoDeModulos then
      node := RegisterNode(att.Node_id);
  end;
  if not assigned(node) then
    exit; // modulo não registrado

  sensor := node.FindSensor(att.sensor_id);
  if not assigned(sensor) then
  begin
    RegisterSensor(att.Node_id, att.sensor_id);
  end;

  case att.internal_sub_type of
    I_SKETCH_NAME:
      node.modulo_nome := att.payload;
    I_SKETCH_VERSION:
      node.modulo_versao := att.payload;

    I_REBOOT:
      begin
        sendRebootMessage(att);
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
      sendConfig(att);
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
          node.RepetidorVersao := att.payload;
        end;
        exit;
      end;
  end;

  if att.internal_sub_type > COMMAND_NONE then
    if assigned(FOnInternalEvento) then
      FOnInternalEvento(self, att);

  if att.data_sub_type > COMMAND_NONE then
    if assigned(FOnDataEvento) then
      FOnDataEvento(self, att);

  if att.presentation_sub_type > COMMAND_NONE then
    if assigned(FOnPresentationEvento) then
      FOnPresentationEvento(self, att);

  if att.stream_sub_type > COMMAND_NONE then
    if assigned(FOnStreamEvento) then
      FOnStreamEvento(self, att);

  if att.Node_id = NODE_SENSOR_ID then
    if assigned(FOnNodeSensorEvento) then
      FOnNodeSensorEvento(self, att);

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
  emInclusaoDeModulos := true;
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

procedure TMySensorsGatewayClass.GetNodes(const Value: TMySensorsNodes);
begin

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
begin

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

procedure TMySensorsGatewayClass.SetOnDataEvento(const Value
  : TMySensorsMessageEvent);
begin
  FOnDataEvento := Value;
end;

procedure TMySensorsGatewayClass.SetOnEventoRecebido
  (const Value: TMySensorsMessageEvent);
begin
  FOnEventoRecebido := Value;
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

procedure TMySensorsGatewayClass.SetOnPresentationEvento
  (const Value: TMySensorsMessageEvent);
begin
  FOnPresentationEvento := Value;
end;

procedure TMySensorsGatewayClass.SetOnStreamEvento
  (const Value: TMySensorsMessageEvent);
begin
  FOnStreamEvento := Value;
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

function TMySensorsGatewayClass.RegisterNode(Node_id: integer): TMySensorsNode;
begin
  result := FNodes.Find(Node_id);
  if assigned(result) then
    exit;
  result := FNodes.AddNode(Node_id);
end;

procedure TMySensorsGatewayClass.RegisterSensor(Node_id, sensor_id: integer);
var
  node: TMySensorsNode;
begin
  node := FNodes.Find(Node_id);
  if not assigned(node) then
  begin
    raise exception.create('Node não existe');
  end;
  node.AddSensor(sensor_id);
end;

procedure TMySensorsGatewayClass.SaveBatteryLevel(att: TMySensorsMsg);
var
  node: TMySensorsNode;
begin
  node := FNodes.Find(att.Node_id);
  if assigned(node) then
    node.NivelBateria := att.payload;
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
  if (Operation = opRemove)  then
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
     SetModelo( FGateway.GetModelo  );
end;

procedure TMySensors.SetModelo(const Value: TMySensorsGateway);
begin
{  if assigned(FGateway) then
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

function TMySensorsNodes.AddNode(Node_id: integer): TMySensorsNode;
begin
  result := Find(Node_id);
  if result = nil then
  begin
    result := TMySensorsNode.create;
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

constructor TMySensorsNode.create;
begin
  inherited;
  Sensors := TMySensorsSensors.create;
end;

destructor TMySensorsNode.destroy;
begin
  Sensors.free;
  inherited;
end;

function TMySensorsNode.FindSensor(sensor_id: integer): TMySensorsSensor;
begin
  result := Sensors.Find(sensor_id);
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

function TThreadListHelper.count: integer;
begin
  try
    result := LockList.count;
  finally
    UnlockList;
  end;

end;

procedure TThreadListHelper.delete(idx: integer);
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

initialization

FLock := TCriticalSection.create;

finalization

FLock.free;

end.
