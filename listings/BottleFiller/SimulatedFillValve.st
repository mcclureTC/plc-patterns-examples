FUNCTION_BLOCK SimulatedFillValve IMPLEMENTS I_FillValve, I_Resettable, I_Cyclic
VAR
    _Name          : STRING(32);
    _SwitchTime    : TIME;
    _FaultDelay    : TIME;
    _Command       : BOOL;
    _Feedback      : BOOL;
    _SwitchTimer   : TON;
    _MismatchTimer : TON;
    _IsStuck       : BOOL;
END_VAR
(*
    SimulatedFillValve

    A fill valve with no hardware: the feedback follows the command after
    SwitchTime. Supervised like the real valve: a fault while feedback and
    command disagree for longer than FaultDelay.

    Failure hook: SetStuck(TRUE) freezes the feedback where it is.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains : BOOL;
    bInCopyCode  : BOOL;
    Name         : STRING(32);
    SwitchTime   : TIME;
    FaultDelay   : TIME;
END_VAR
_Name := Name;
_SwitchTime := SwitchTime;
_FaultDelay := FaultDelay;

METHOD PUBLIC Open
_Command := TRUE;

METHOD PUBLIC Close
_Command := FALSE;

METHOD PUBLIC SetStuck
VAR_INPUT
    IsStuck : BOOL;
END_VAR
_IsStuck := IsStuck;

METHOD PUBLIC CyclicLogic
_SwitchTimer(IN := (_Command XOR _Feedback) AND NOT _IsStuck, PT := _SwitchTime);
IF _SwitchTimer.Q THEN
    _Feedback := _Command;
    _SwitchTimer(IN := FALSE);
END_IF
_MismatchTimer(IN := _Command XOR _Feedback, PT := _FaultDelay);

METHOD PUBLIC Reset
_MismatchTimer(IN := FALSE);

PROPERTY PUBLIC IsOpen : BOOL
GET: IsOpen := _Command AND _Feedback;

PROPERTY PUBLIC IsClosed : BOOL
GET: IsClosed := NOT (_Command OR _Feedback);

PROPERTY PUBLIC HasFault : BOOL
GET: HasFault := _MismatchTimer.Q;

PROPERTY PUBLIC FaultText : STRING
GET:
IF _MismatchTimer.Q THEN
    FaultText := 'Feedback does not match the command';
ELSE
    FaultText := '';
END_IF

PROPERTY PUBLIC Name : STRING
GET: Name := _Name;

PROPERTY PUBLIC IsStuck : BOOL
GET: IsStuck := _IsStuck;
