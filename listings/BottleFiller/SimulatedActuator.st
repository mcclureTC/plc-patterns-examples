FUNCTION_BLOCK SimulatedActuator EXTENDS ActuatorBase
VAR
    _TravelTime   : TIME;
    _DrivenTarget : E_ActuatorTarget;
    _Travel       : TON;
    _IsStuck      : BOOL;
END_VAR
(*
    SimulatedActuator

    An actuator with no hardware: it reaches the commanded end TravelTime
    after the move starts. The supervision is ActuatorBase's, unchanged, so
    a move that never arrives faults exactly as a real one would.

    Failure hook: SetStuck(TRUE) stops it moving, so the move times out.
    Starts at neither end: the first move of each direction takes its
    travel time.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains : BOOL;
    bInCopyCode  : BOOL;
    Name         : STRING(32);
    MoveTimeout  : TIME;
    TravelTime   : TIME;
END_VAR
_TravelTime := TravelTime;
Configure(Name := Name, MoveTimeout := MoveTimeout);

METHOD PUBLIC SetStuck
VAR_INPUT
    IsStuck : BOOL;
END_VAR
_IsStuck := IsStuck;

METHOD PROTECTED IsWired : BOOL
IsWired := TRUE;                                    // nothing to wire

METHOD PROTECTED DriveOutputs
VAR_INPUT
    Target : E_ActuatorTarget;
END_VAR
IF Target <> _DrivenTarget THEN
    _DrivenTarget := Target;
    _Travel(IN := FALSE);                           // a new move starts from the beginning
END_IF
_Travel(IN := Target <> E_ActuatorTarget.None AND NOT _IsStuck, PT := _TravelTime);

METHOD PROTECTED IsAtPosition : BOOL
VAR_INPUT
    Position : E_ActuatorTarget;
END_VAR
IsAtPosition := Position <> E_ActuatorTarget.None AND Position = _DrivenTarget AND _Travel.Q;

METHOD PROTECTED DriveSafe
_Travel(IN := FALSE);

PROPERTY PUBLIC IsStuck : BOOL
GET: IsStuck := _IsStuck;
