FUNCTION_BLOCK ActuatorRouter IMPLEMENTS I_Actuator, I_Cyclic
VAR
    _Name   : STRING(32);
    _Source : E_DeviceSource;
    _Chosen : I_Actuator;
END_VAR
(*
    ActuatorRouter

    One I_Actuator in front of up to four candidates, chosen once by the
    site setting. Only the chosen candidate is run. A source with no
    candidate (0) is never at either end, and reports a fault.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains    : BOOL;
    bInCopyCode     : BOOL;
    Name            : STRING(32);
    Source          : E_DeviceSource;
    FinalHardware   : I_Actuator;
    SimilarHardware : I_Actuator;
    Simulation      : I_Actuator;
    Test            : I_Actuator;
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

METHOD PUBLIC Extend
IF _Chosen <> 0 THEN
    _Chosen.Extend();
END_IF

METHOD PUBLIC Retract
IF _Chosen <> 0 THEN
    _Chosen.Retract();
END_IF

METHOD PUBLIC Reset
IF _Chosen <> 0 THEN
    _Chosen.Reset();
END_IF

PROPERTY PUBLIC IsExtended : BOOL
GET: IsExtended := _Chosen <> 0 AND_THEN _Chosen.IsExtended;

PROPERTY PUBLIC IsRetracted : BOOL
GET: IsRetracted := _Chosen <> 0 AND_THEN _Chosen.IsRetracted;

PROPERTY PUBLIC Name : STRING
GET: Name := _Name;

PROPERTY PUBLIC HasFault : BOOL
GET: HasFault := _Chosen = 0 OR_ELSE _Chosen.HasFault;

PROPERTY PUBLIC FaultText : STRING
GET:
IF _Chosen = 0 THEN
    FaultText := 'No device for this source';
ELSE
    FaultText := _Chosen.FaultText;
END_IF

PROPERTY PUBLIC Source : E_DeviceSource
GET: Source := _Source;
