FUNCTION_BLOCK LevelSensorRouter IMPLEMENTS I_LevelSensor
VAR
    _Chosen     : I_LevelSensor;
    _IsHardware : BOOL;
END_VAR
(*
    LevelSensorRouter

    Chooses the real or the simulated level sensor once, in FB_init, from a
    site switch, and forwards every read to it. With no sensor it fails
    safe: invalid, level 0. Holds no logic of its own.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains : BOOL;
    bInCopyCode  : BOOL;
    Simulated    : I_LevelSensor;
    Hardware     : I_LevelSensor;
    UseHardware  : BOOL;
END_VAR
_IsHardware := UseHardware;
IF UseHardware THEN
    _Chosen := Hardware;
ELSE
    _Chosen := Simulated;
END_IF

PROPERTY PUBLIC Level : REAL
GET:
IF _Chosen = 0 THEN
    Level := 0.0;
ELSE
    Level := _Chosen.Level;
END_IF

PROPERTY PUBLIC IsValid : BOOL
GET: IsValid := (_Chosen <> 0) AND_THEN _Chosen.IsValid;

PROPERTY PUBLIC Chosen : I_LevelSensor
GET: Chosen := _Chosen;

PROPERTY PUBLIC IsSimulated : BOOL
GET: IsSimulated := NOT _IsHardware;
