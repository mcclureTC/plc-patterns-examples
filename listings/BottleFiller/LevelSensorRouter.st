FUNCTION_BLOCK LevelSensorRouter IMPLEMENTS I_LevelSensor, I_Cyclic
VAR
    _Name   : STRING(32);
    _Source : E_DeviceSource;
    _Chosen : I_LevelSensor;
END_VAR
(*
    LevelSensorRouter

    One I_LevelSensor in front of up to four candidates, chosen once by
    the site setting. A source with no candidate (0) is never valid.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains    : BOOL;
    bInCopyCode     : BOOL;
    Name            : STRING(32);
    Source          : E_DeviceSource;
    FinalHardware   : I_LevelSensor;
    SimilarHardware : I_LevelSensor;
    Simulation      : I_LevelSensor;
    Test            : I_LevelSensor;
END_VAR
_Name := Name;
_Source := Source;
CASE Source OF
    E_DeviceSource.FinalHardware:   _Chosen := FinalHardware;
    E_DeviceSource.SimilarHardware: _Chosen := SimilarHardware;
    E_DeviceSource.Simulation:      _Chosen := Simulation;
    E_DeviceSource.Test:            _Chosen := Test;
END_CASE

METHOD PUBLIC CyclicLogic
VAR
    Cyclic : I_Cyclic;
END_VAR
IF _Chosen <> 0 AND_THEN __QUERYINTERFACE(_Chosen, Cyclic) THEN
    Cyclic.CyclicLogic();              // only the chosen candidate runs
END_IF

PROPERTY PUBLIC Level : REAL
GET:
IF _Chosen <> 0 THEN
    Level := _Chosen.Level;
ELSE
    Level := 0.0;
END_IF

PROPERTY PUBLIC IsValid : BOOL
GET: IsValid := _Chosen <> 0 AND_THEN _Chosen.IsValid;

PROPERTY PUBLIC Name : STRING
GET: Name := _Name;

PROPERTY PUBLIC Source : E_DeviceSource
GET: Source := _Source;
