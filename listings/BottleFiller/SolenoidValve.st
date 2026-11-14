FUNCTION_BLOCK SolenoidValve IMPLEMENTS I_FillValve, I_Resettable, I_Cyclic
VAR
    _Name          : STRING(32) := 'Solenoid valve';
    _Output        : REFERENCE TO BOOL;
    _OpenFeedback  : REFERENCE TO BOOL;
    _FaultDelay    : TIME;
    _Command       : BOOL;
    _MismatchTimer : TON;
    _IsConfigured  : BOOL;
END_VAR
(*
    SolenoidValve

    Drives one solenoid valve and checks its open-feedback switch. A fault
    is reported while the feedback has disagreed with the command for
    longer than FaultDelay. Name can be set while wiring.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains : BOOL;
    bInCopyCode  : BOOL;
    Output       : REFERENCE TO BOOL;
    OpenFeedback : REFERENCE TO BOOL;
    FaultDelay   : TIME;
END_VAR
_Output REF= Output;
_OpenFeedback REF= OpenFeedback;
_FaultDelay := FaultDelay;
_IsConfigured := __ISVALIDREF(Output) AND __ISVALIDREF(OpenFeedback);

METHOD PUBLIC Open
_Command := TRUE;

METHOD PUBLIC Close
_Command := FALSE;

METHOD PUBLIC CyclicLogic
IF NOT _IsConfigured THEN
    RETURN;
END_IF
_Output := _Command;
_MismatchTimer(IN := _Command XOR _OpenFeedback, PT := _FaultDelay);

METHOD PUBLIC Reset
_MismatchTimer(IN := FALSE);                        // supervise again from now

PROPERTY PUBLIC IsOpen : BOOL
GET: IsOpen := _IsConfigured AND_THEN (_Command AND _OpenFeedback);

PROPERTY PUBLIC IsClosed : BOOL
GET: IsClosed := _IsConfigured AND_THEN NOT (_Command OR _OpenFeedback);

PROPERTY PUBLIC HasFault : BOOL
GET: HasFault := NOT _IsConfigured OR _MismatchTimer.Q;

PROPERTY PUBLIC FaultText : STRING
GET:
IF NOT _IsConfigured THEN
    FaultText := 'I/O not wired';
ELSIF _MismatchTimer.Q THEN
    FaultText := 'No feedback';
ELSE
    FaultText := '';
END_IF

PROPERTY PUBLIC Name : STRING
GET: Name := _Name;
SET: _Name := Name;
