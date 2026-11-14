FUNCTION_BLOCK FieldbusLevelSensor IMPLEMENTS I_LevelSensor
VAR
    _FieldbusLevel     : REFERENCE TO DINT;
    _IsCommunicationOk : REFERENCE TO BOOL;
    _TankHeight        : REAL;
    _IsConfigured      : BOOL;
END_VAR
(* FieldbusLevelSensor: a level sensor that reports its reading over a fieldbus, in 0.1 mm. *)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains      : BOOL;
    bInCopyCode       : BOOL;
    FieldbusLevel     : REFERENCE TO DINT;   // process data from the sensor, 0.1 mm
    IsCommunicationOk : REFERENCE TO BOOL;
    TankHeight        : REAL;                // mm
END_VAR
_FieldbusLevel REF= FieldbusLevel;
_IsCommunicationOk REF= IsCommunicationOk;
_TankHeight := TankHeight;
_IsConfigured := __ISVALIDREF(FieldbusLevel) AND __ISVALIDREF(IsCommunicationOk) AND TankHeight > 0.0;

PROPERTY PUBLIC IsValid : BOOL
GET: IsValid := _IsConfigured AND_THEN _IsCommunicationOk;

PROPERTY PUBLIC Level : REAL
GET:
IF IsValid THEN
    Level := LIMIT(0.0, DINT_TO_REAL(_FieldbusLevel) / 10.0 / _TankHeight * 100.0, 100.0);
ELSE
    Level := 0.0;
END_IF
