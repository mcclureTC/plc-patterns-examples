FUNCTION_BLOCK ActuatorRouter IMPLEMENTS I_Actuator
VAR
    _Chosen     : I_Actuator;
    _IsHardware : BOOL;
END_VAR
(*
    ActuatorRouter

    Chooses the real or the simulated actuator once, in FB_init, from a site
    switch, and forwards every call to it. With no actuator it fails safe:
    neither extended nor retracted, and faulted. Holds no logic of its own.

    The tree runs and resets Chosen, not the router.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains : BOOL;
    bInCopyCode  : BOOL;
    Simulated    : I_Actuator;
    Hardware     : I_Actuator;
    UseHardware  : BOOL;
END_VAR
_IsHardware := UseHardware;
IF UseHardware THEN
    _Chosen := Hardware;
ELSE
    _Chosen := Simulated;
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
GET: IsExtended := (_Chosen <> 0) AND_THEN _Chosen.IsExtended;

PROPERTY PUBLIC IsRetracted : BOOL
GET: IsRetracted := (_Chosen <> 0) AND_THEN _Chosen.IsRetracted;

PROPERTY PUBLIC HasFault : BOOL
GET: HasFault := (_Chosen = 0) OR_ELSE _Chosen.HasFault;

PROPERTY PUBLIC FaultText : STRING
GET:
IF _Chosen = 0 THEN
    FaultText := 'No actuator chosen';
ELSE
    FaultText := _Chosen.FaultText;
END_IF

PROPERTY PUBLIC Name : STRING
GET:
IF _Chosen = 0 THEN
    Name := 'Unassigned actuator';
ELSE
    Name := _Chosen.Name;
END_IF

PROPERTY PUBLIC Chosen : I_Actuator
GET: Chosen := _Chosen;

PROPERTY PUBLIC IsSimulated : BOOL
GET: IsSimulated := NOT _IsHardware;
