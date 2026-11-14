FUNCTION_BLOCK ABSTRACT ActuatorBase IMPLEMENTS I_Actuator, I_Cyclic
VAR
    _Name         : STRING(32);
    _MoveTimeout  : TIME := T#2S;
    _Target       : E_ActuatorTarget;
    _IsInPosition : BOOL;
    _HasFault     : BOOL;
    _FaultText    : STRING(80);
    _MoveTimer    : TON;
    _SettleTimer  : TON;
END_VAR
(*
    ActuatorBase

    The move-and-supervise skeleton shared by every actuator. CyclicLogic() is
    the template: it drives toward the target, checks arrival, supervises the
    move time, goes safe on a fault and lets the actuator settle.

    Derived blocks implement IsWired, DriveOutputs, IsAtPosition and DriveSafe,
    may override SettleTime, and call Configure() from their FB_init.
*)

METHOD PUBLIC FINAL CyclicLogic
// Not wired: report it, touch nothing
IF NOT IsWired() THEN
    _HasFault := TRUE;
    _FaultText := 'I/O not wired';
    RETURN;
END_IF

// Faulted: only the safe outputs, until Reset()
IF _HasFault THEN
    DriveSafe();
    RETURN;
END_IF

// Drive toward the target, and check whether it has arrived
DriveOutputs(Target := _Target);
_IsInPosition := IsAtPosition(Position := _Target);

// Supervise the move: the same rule for every actuator
_MoveTimer(IN := (_Target <> E_ActuatorTarget.None) AND NOT _IsInPosition, PT := _MoveTimeout);
IF _MoveTimer.Q THEN
    _HasFault := TRUE;
    _FaultText := 'Move did not finish in time';
    DriveSafe();
    RETURN;
END_IF

// Let it settle before reporting the position
_SettleTimer(IN := _IsInPosition, PT := SettleTime);

METHOD PROTECTED ABSTRACT IsWired : BOOL

METHOD PROTECTED ABSTRACT DriveOutputs
VAR_INPUT
    Target : E_ActuatorTarget;
END_VAR

METHOD PROTECTED ABSTRACT IsAtPosition : BOOL
VAR_INPUT
    Position : E_ActuatorTarget;
END_VAR

METHOD PROTECTED ABSTRACT DriveSafe

PROPERTY PROTECTED SettleTime : TIME
GET: SettleTime := T#0S;           // most actuators report as soon as the sensor confirms

METHOD PROTECTED Configure
VAR_INPUT
    Name        : STRING(32);
    MoveTimeout : TIME;
END_VAR
_Name := Name;
_MoveTimeout := MoveTimeout;

METHOD PUBLIC Extend
MoveTo(Target := E_ActuatorTarget.Extended);

METHOD PUBLIC Retract
MoveTo(Target := E_ActuatorTarget.Retracted);

METHOD PRIVATE MoveTo
VAR_INPUT
    Target : E_ActuatorTarget;
END_VAR
IF _HasFault OR Target = _Target THEN
    RETURN;                        // faulted: Reset() first. Same target: keep the move running.
END_IF
_Target := Target;
_MoveTimer(IN := FALSE);           // every new move gets the full timeout
_SettleTimer(IN := FALSE);

METHOD PUBLIC Reset
_HasFault := FALSE;
_FaultText := '';
_Target := E_ActuatorTarget.None;
_MoveTimer(IN := FALSE);
_SettleTimer(IN := FALSE);

PROPERTY PUBLIC IsExtended : BOOL
GET: IsExtended := NOT _HasFault AND _Target = E_ActuatorTarget.Extended AND _SettleTimer.Q;

PROPERTY PUBLIC IsRetracted : BOOL
GET: IsRetracted := NOT _HasFault AND _Target = E_ActuatorTarget.Retracted AND _SettleTimer.Q;

PROPERTY PUBLIC HasFault : BOOL
GET: HasFault := _HasFault;

PROPERTY PUBLIC FaultText : STRING
GET: FaultText := _FaultText;

PROPERTY PUBLIC Name : STRING
GET: Name := _Name;
