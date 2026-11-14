FUNCTION_BLOCK FakeActuator IMPLEMENTS I_Actuator
VAR
    _Name         : STRING(32);
    _ExtendCount  : DINT;
    _RetractCount : DINT;
    _ResetCount   : DINT;
END_VAR
(*
    FakeActuator

    Test double for I_Actuator. Counts every call, reports its own name,
    and is always extended, so a test can tell which fake a router chose.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains : BOOL;
    bInCopyCode  : BOOL;
    Name         : STRING(32);
END_VAR
_Name := Name;

METHOD PUBLIC Extend
_ExtendCount := _ExtendCount + 1;

METHOD PUBLIC Retract
_RetractCount := _RetractCount + 1;

METHOD PUBLIC Reset
_ResetCount := _ResetCount + 1;

PROPERTY PUBLIC IsExtended : BOOL
GET: IsExtended := TRUE;

PROPERTY PUBLIC IsRetracted : BOOL
GET: IsRetracted := FALSE;

PROPERTY PUBLIC Name : STRING
GET: Name := _Name;

PROPERTY PUBLIC HasFault : BOOL
GET: HasFault := FALSE;

PROPERTY PUBLIC FaultText : STRING
GET: FaultText := '';

PROPERTY PUBLIC ExtendCount : DINT
GET: ExtendCount := _ExtendCount;

PROPERTY PUBLIC ResetCount : DINT
GET: ResetCount := _ResetCount;
