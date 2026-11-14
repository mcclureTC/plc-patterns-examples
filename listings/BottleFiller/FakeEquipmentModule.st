FUNCTION_BLOCK FakeEquipmentModule IMPLEMENTS I_EquipmentModule, I_Resettable
VAR
    _Name        : STRING(32);
    _IsCycleDone : BOOL;
    _HasFault    : BOOL;
    _StartCount  : DINT;
    _ResetCount  : DINT;
END_VAR
(*
    FakeEquipmentModule

    Test double for I_EquipmentModule. Counts the cycles it was asked for
    and the resets it received. A requested cycle finishes when the test
    calls FinishCycle(); a fault is reported while the test sets one.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains : BOOL;
    bInCopyCode  : BOOL;
    Name         : STRING(32);
END_VAR
_Name := Name;

METHOD PUBLIC StartCycle
_StartCount := _StartCount + 1;
_IsCycleDone := FALSE;

METHOD PUBLIC Reset
_ResetCount := _ResetCount + 1;

METHOD PUBLIC FinishCycle
_IsCycleDone := TRUE;

METHOD PUBLIC SetFault
VAR_INPUT
    IsActive : BOOL;
END_VAR
_HasFault := IsActive;

PROPERTY PUBLIC Name : STRING
GET: Name := _Name;

PROPERTY PUBLIC HasFault : BOOL
GET: HasFault := _HasFault;

PROPERTY PUBLIC FaultText : STRING
GET:
IF _HasFault THEN
    FaultText := 'Simulated fault';
ELSE
    FaultText := '';
END_IF

PROPERTY PUBLIC IsCycleDone : BOOL
GET: IsCycleDone := _IsCycleDone;

PROPERTY PUBLIC StartCount : DINT
GET: StartCount := _StartCount;

PROPERTY PUBLIC ResetCount : DINT
GET: ResetCount := _ResetCount;
