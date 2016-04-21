unit MySensors;


interface

uses classes, sysutils;

const
  PROTOCOL_VERSION = 2;
  MAX_MESSAGE_LENGTH = 32;
  HEADER_SIZE = 7;
  MAX_PAYLOAD = (MAX_MESSAGE_LENGTH - HEADER_SIZE);

  FIRMWARE_BLOCK_SIZE = 16;
  BROADCAST_ADDRESS = 255;
  NODE_SENSOR_ID = 255;
  COMMAND_NONE = -1;

  C_PRESENTATION = 0;
  C_SET = 1;
  C_REQ = 2;
  C_INTERNAL = 3;
  C_STREAM = 4;

  V_TEMP = 0;
  V_HUM = 1;
  V_LIGHT = 2;
  V_DIMMER = 3;
  V_PRESSURE = 4;
  V_FORECAST = 5;
  V_RAIN = 6;
  V_RAINRATE = 7;
  V_WIND = 8;
  V_GUST = 9;
  V_DIRECTION = 10;
  V_UV = 11;
  V_WEIGHT = 12;
  V_DISTANCE = 13;
  V_IMPEDANCE = 14;
  V_ARMED = 15;
  V_TRIPPED = 16;
  V_WATT = 17;
  V_KWH = 18;
  V_SCENE_ON = 19;
  V_SCENE_OFF = 20;
  V_HEATER = 21;
  V_HEATER_SW = 22;
  V_LIGHT_LEVEL = 23;
  V_VAR1 = 24;
  V_VAR2 = 25;
  V_VAR3 = 26;
  V_VAR4 = 27;
  V_VAR5 = 28;
  V_UP = 29;
  V_DOWN = 30;
  V_STOP = 31;
  V_IR_SEND = 32;
  V_IR_RECEIVE = 33;
  V_FLOW = 34;
  V_VOLUME = 35;
  V_LOCK_STATUS = 36;
  V_DUST_LEVEL = 37;
  V_VOLTAGE = 38;
  V_CURRENT = 39;

  I_BATTERY_LEVEL = 0;
  I_TIME = 1;
  I_VERSION = 2;
  I_ID_REQUEST = 3;
  I_ID_RESPONSE = 4;
  I_INCLUSION_MODE = 5;
  I_CONFIG = 6;
  I_FIND_PARENT = 7;
  I_FIND_PARENT_RESPONSE = 8;
  I_LOG_MESSAGE = 9;
  I_CHILDREN = 10;
  I_SKETCH_NAME = 11;
  I_SKETCH_VERSION = 12;
  I_REBOOT = 13;
  I_GATEWAY_READY = 14;
  I_DEBUG = 999;

  S_DOOR = 0;
  S_MOTION = 1;
  S_SMOKE = 2;
  S_LIGHT = 3;
  S_DIMMER = 4;
  S_COVER = 5;
  S_TEMP = 6;
  S_HUM = 7;
  S_BARO = 8;
  S_WIND = 9;
  S_RAIN = 10;
  S_UV = 11;
  S_WEIGHT = 12;
  S_POWER = 13;
  S_HEATER = 14;
  S_DISTANCE = 15;
  S_LIGHT_LEVEL = 16;
  S_ARDUINO_NODE = 17;
  S_ARDUINO_REPEATER_NODE = 18;
  S_LOCK = 19;
  S_IR = 20;
  S_WATER = 21;
  S_AIR_QUALITY = 22;
  S_CUSTOM = 23;
  S_DUST = 24;
  S_SCENE_CONTROLLER = 25;

  ST_FIRMWARE_CONFIG_REQUEST = 0;
  ST_FIRMWARE_CONFIG_RESPONSE = 1;
  ST_FIRMWARE_REQUEST = 2;
  ST_FIRMWARE_RESPONSE = 3;
  ST_SOUND = 4;
  ST_IMAGE = 5;
  ST_DEBUG = 999;

  P_STRING = 0;
  P_BYTE = 1;
  P_INT16 = 2;
  P_UINT16 = 3;
  P_LONG32 = 4;
  P_ULONG32 = 5;
  P_CUSTOM = 6;
  P_FLOAT32 = 7;

type
  TMySensorsMsg = record
    node_id: integer;
    sensor_id: integer;
    command: integer;
    sensor: integer;
    ack: integer;
    sub_type: integer;
    presentation_sub_type: integer;
    data_sub_type: integer;
    internal_sub_type: integer;
    stream_sub_type: integer;
    payload: string;
    timestamp: TDateTime;
    mensagem: string;
    function json: string;
    function sub_type_descr: string;
    function ack_descr: string;
    function command_descr: string;
    function presentation_descr: string;
    function data_descr: string;
    function internal_descr: string;
    function stream_descr: string;
  end;

function DecodeMySensorMsg(msg: string)
  : TMySensorsMsg;

function EncodeMySensorMsg(node_id,
  sensor_id: integer;
  command: integer;
  ack: integer;
  sub_type: integer;
  payload: string): string; overload;
function EncodeMySensorMsg(const Att: TMySensorsMsg): string; overload;

implementation


function ifStr(b: boolean; t, f: string)
  : string;
begin
  if b then
    result := t
  else
    result := f;

end;

function EncodeMySensorMsg(node_id,
  sensor_id: integer;
  command: integer;
  ack: integer;
  sub_type: integer;
  payload: string)
  : string;
begin
  result := intToStr(node_id) + ';' +
    intToStr(sensor_id) + ';' +
    intToStr(command) + ';' +
    intToStr(ack) + ';' +
    intToStr(sub_type) + ';' +
    payload + #$A;
end;

function EncodeMySensorMsg(const Att: TMySensorsMsg): string;
begin
  result := EncodeMySensorMsg(Att.node_id, Att.sensor_id, Att.command,
    Att.ack, Att.sub_type, Att.payload);
end;

function DecodeMySensorMsg(msg: string)
  : TMySensorsMsg;
var
  List: TStrings;
  function stringEntre(s: string; ini: string; fim: string): string;
  begin
    result := copy(s, pos(ini, s), 255);
    result := copy(result, 1, pos(fim, s));
  end;

begin
  List := TStringList.Create;
  try
    ExtractStrings([';'], [], pWideChar(msg), List);
    result.timestamp := now;
    result.node_id := StrToIntDef(List[0], COMMAND_NONE);
    result.sensor_id := StrToIntDef(List[1], COMMAND_NONE);
    result.command := StrToIntDef(List[2], COMMAND_NONE);
    result.ack := StrToIntDef(List[3], COMMAND_NONE);
    result.sub_type := StrToIntDef(List[4], COMMAND_NONE);
    result.data_sub_type := COMMAND_NONE;
    result.internal_sub_type := COMMAND_NONE;
    result.presentation_sub_type := COMMAND_NONE;
    result.stream_sub_type := COMMAND_NONE;
    result.mensagem := msg;
    case result.command of
      C_PRESENTATION:
        result.presentation_sub_type := result.sub_type;
      C_SET, C_REQ:
        result.data_sub_type := result.sub_type;
      C_INTERNAL:
        result.internal_sub_type := result.sub_type;
      C_STREAM:
        result.stream_sub_type := result.sub_type;
    end;
    result.payload := '';
    try // alguns comandos nao envia este dado.
      if result.internal_sub_type = I_DEBUG then
        result.payload := stringEntre(msg, '{', '}')
      else
        result.payload := List[5];
    except
    end;

  finally
    List.Free;
  end;

end;

{ TMySensorsMsg }

function TMySensorsMsg.ack_descr: string;
begin
  case command of
    C_REQ:
      if ack = 0 then
        result := 'unknow'
      else
        result := 'request';
    C_SET:
      if ack = 0 then
        result := 'normal'
      else
        result := 'ack';
  else
    result := '';
  end;
end;

function TMySensorsMsg.command_descr: string;
begin
  case command of
    C_PRESENTATION:
      result := 'presentation';
    C_SET:
      result := 'set';
    C_REQ:
      result := 'req';
    C_INTERNAL:
      result := 'internal';
    C_STREAM:
      result := 'stream';
  end;
end;

function TMySensorsMsg.data_descr: string;
begin
  case data_sub_type of
    COMMAND_NONE:
      result := '';
    V_TEMP:
      result := 'V_TEMP'
        ;
    V_HUM:
      result := 'V_HUM'
        ;
    V_LIGHT:
      result := 'V_LIGHT'
        ;
    V_DIMMER:
      result := 'V_DIMMER'
        ;
    V_PRESSURE:
      result := 'V_PRESSURE'
        ;
    V_FORECAST:
      result := 'V_FORECAST'
        ;
    V_RAIN:
      result := 'V_RAIN'
        ;
    V_RAINRATE:
      result := 'V_RAINRATE'
        ;
    V_WIND:
      result := 'V_WIND'
        ;
    V_GUST:
      result := 'V_GUST'
        ;
    V_DIRECTION:
      result := 'V_DIRECTION'
        ;
    V_UV:
      result := 'V_UV'
        ;
    V_WEIGHT:
      result := 'V_WEIGHT'
        ;
    V_DISTANCE:
      result := 'V_DISTANCE'
        ;
    V_IMPEDANCE:
      result := 'V_IMPEDANCE'
        ;
    V_ARMED:
      result := 'V_ARMED'
        ;
    V_TRIPPED:
      result := 'V_TRIPPED'
        ;
    V_WATT:
      result := 'V_WATT'
        ;
    V_KWH:
      result := 'V_KWH'
        ;
    V_SCENE_ON:
      result := 'V_SCENE_ON'
        ;
    V_SCENE_OFF:
      result := 'V_SCENE_OFF'
        ;
    V_HEATER:
      result := 'V_HEATER'
        ;
    V_HEATER_SW:
      result := 'V_HEATER_SW'
        ;
    V_LIGHT_LEVEL:
      result := 'V_LIGHT_LEVEL'
        ;
    V_VAR1:
      result := 'V_VAR1'
        ;
    V_VAR2:
      result := 'V_VAR2'
        ;
    V_VAR3:
      result := 'V_VAR3'
        ;
    V_VAR4:
      result := 'V_VAR4'
        ;
    V_VAR5:
      result := 'V_VAR5'
        ;
    V_UP:
      result := 'V_UP'
        ;
    V_DOWN:
      result := 'V_DOWN'
        ;
    V_STOP:
      result := 'V_STOP'
        ;
    V_IR_SEND:
      result := 'V_IR_SEND'
        ;
    V_IR_RECEIVE:
      result := 'V_IR_RECEIVE'
        ;
    V_FLOW:
      result := 'V_FLOW'
        ;
    V_VOLUME:
      result := 'V_VOLUME'
        ;
    V_LOCK_STATUS:
      result := 'V_LOCK_STATUS'
        ;
    V_DUST_LEVEL:
      result := 'V_DUST_LEVEL'
        ;
    V_VOLTAGE:
      result := 'V_VOLTAGE'
        ;
    V_CURRENT:
      result := 'V_CURRENT'
        ;
  else
    result := 'unknow';
  end;
end;

function TMySensorsMsg.internal_descr: string;
begin
  case internal_sub_type of
    COMMAND_NONE:
      result := '';
    I_BATTERY_LEVEL:
      result := 'I_BATTERY_LEVEL'
        ;
    I_TIME:
      result := 'I_TIME'
        ;
    I_VERSION:
      result := 'I_VERSION'
        ;
    I_ID_REQUEST:
      result := 'I_ID_REQUEST'
        ;
    I_ID_RESPONSE:
      result := 'I_ID_RESPONSE'
        ;
    I_INCLUSION_MODE:
      result := 'I_INCLUSION_MODE'
        ;
    I_CONFIG:
      result := 'I_CONFIG'
        ;
    I_FIND_PARENT:
      result := 'I_FIND_PARENT'
        ;
    I_FIND_PARENT_RESPONSE:
      result := 'I_FIND_PARENT_RESPONSE'
        ;
    I_LOG_MESSAGE:
      result := 'I_LOG_MESSAGE'
        ;
    I_CHILDREN:
      result := 'I_CHILDREN'
        ;
    I_SKETCH_NAME:
      result := 'I_SKETCH_NAME'
        ;
    I_SKETCH_VERSION:
      result := 'I_SKETCH_VERSION'
        ;
    I_REBOOT:
      result := 'I_REBOOT'
        ;
    I_GATEWAY_READY:
      result := 'I_GATEWAY_READY'
        ;
    I_DEBUG:
      result := 'I_DEBUG';
  else
    result := 'unknow';
  end;
end;

function TMySensorsMsg.json: string;
  function QuotedStr2(s: string)
    : string;
  begin
    result := '"' + s + '"';
  end;

begin
  result := '{ "node_id":' + intToStr(node_id) +
    ', "sensor_id":' + intToStr(sensor_id) +
    ', "command": ' + QuotedStr2(command_descr) +
    ', "ack":' + QuotedStr2(ack_descr) +
    ', "vsub-type": ' + intToStr(sub_type) +
    ', "sub-type": ' + QuotedStr2(sub_type_descr) +
    ', "presentation-type": ' + QuotedStr2(presentation_descr) +
    ', "data-type": ' + QuotedStr2(data_descr) +
    ', "internal-type": ' + QuotedStr2(internal_descr) +
    ', "stream-type": ' + QuotedStr2(stream_descr) +
    ', "payload": ' + QuotedStr2(payload) +
    '}';

end;

function TMySensorsMsg.presentation_descr: string;
begin
  case presentation_sub_type of
    COMMAND_NONE:
      result := '';
    // S_NONE : result := '';
    S_DOOR:
      result := 'S_DOOR'
        ;
    S_MOTION:
      result := 'S_MOTION'
        ;
    S_SMOKE:
      result := 'S_SMOKE'
        ;
    S_LIGHT:
      result := 'S_LIGHT'
        ;
    S_DIMMER:
      result := 'S_DIMMER'
        ;
    S_COVER:
      result := 'S_COVER'
        ;
    S_TEMP:
      result := 'S_TEMP'
        ;
    S_HUM:
      result := 'S_HUM'
        ;
    S_BARO:
      result := 'S_BARO'
        ;
    S_WIND:
      result := 'S_WIND'
        ;
    S_RAIN:
      result := 'S_RAIN'
        ;
    S_UV:
      result := 'S_UV'
        ;
    S_WEIGHT:
      result := 'S_WEIGHT'
        ;
    S_POWER:
      result := 'S_POWER'
        ;
    S_HEATER:
      result := 'S_HEATER'
        ;
    S_DISTANCE:
      result := 'S_DISTANCE'
        ;
    S_LIGHT_LEVEL:
      result := 'S_LIGHT_LEVEL'
        ;
    S_ARDUINO_NODE:
      result := 'S_ARDUINO_NODE'
        ;
    S_ARDUINO_REPEATER_NODE:
      result := 'S_ARDUINO_REPEATER_NODE'
        ;
    S_LOCK:
      result := 'S_LOCK'
        ;
    S_IR:
      result := 'S_IR'
        ;
    S_WATER:
      result := 'S_WATER'
        ;
    S_AIR_QUALITY:
      result := 'S_AIR_QUALITY'
        ;
    S_CUSTOM:
      result := 'S_CUSTOM'
        ;
    S_DUST:
      result := 'S_DUST'
        ;
    S_SCENE_CONTROLLER:
      result := 'S_SCENE_CONTROLLER'
        ;
  else
    result := 'unknow';
  end;
end;

function TMySensorsMsg.stream_descr: string;
begin
  case stream_sub_type of
    COMMAND_NONE:
      result := '';
    ST_FIRMWARE_CONFIG_REQUEST:
      result := 'ST_FIRMWARE_CONFIG_REQUEST'; // = 0;
    ST_FIRMWARE_CONFIG_RESPONSE:
      result := 'ST_FIRMWARE_CONFIG_RESPONSE'; // = 1;
    ST_FIRMWARE_REQUEST:
      result := 'ST_FIRMWARE_REQUEST'; // = 2;
    ST_FIRMWARE_RESPONSE:
      result := 'ST_FIRMWARE_RESPONSE'; // = 3;
    ST_SOUND:
      result := 'ST_SOUND'; // = 4;
    ST_IMAGE:
      result := 'ST_IMAGE'; // = 5;
    ST_DEBUG:
      result := 'ST_DEBUG';
  end;
end;

function TMySensorsMsg.sub_type_descr: string;
begin
  case command of
    C_PRESENTATION:
      result := presentation_descr;
    C_SET, C_REQ:
      result := data_descr;
    C_INTERNAL:
      result := internal_descr;
    C_STREAM:
      result := stream_descr;
  end;
end;

end.
