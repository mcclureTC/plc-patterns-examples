FUNCTION_BLOCK SimulatedValve IMPLEMENTS I_FillValve, I_Cyclic
VAR
    _Name         : STRING(32);
    _Clock        : I_Clock;
    _TravelTime   : LTIME;
    _IsCommanded  : BOOL;              // TRUE: open requested
    _IsStuck      : BOOL;
    _IsAtOpen     : BOOL;
    _IsAtClosed   : BOOL := TRUE;
    _MoveStart    : LTIME;
    _IsMoving     : BOOL;
    _IsConfigured : BOOL;
END_VAR
(*
    SimulatedValve

    Stands in for a valve with position feedback. Reaches the commanded
    position after TravelTime, with neither end reported while it moves.
    SetStuck() makes it stop answering commands, as a sticking valve does.
    Has no I/O.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains : BOOL;
    bInCopyCode  : BOOL;
    Name         : STRING(32);
    Clock        : I_Clock;
    TravelTime   : LTIME;
END_VAR
_Name := Name;
_Clock := Clock;
_TravelTime := TravelTime;
_IsConfigured := Clock <> 0;

METHOD PUBLIC Open
_IsCommanded := TRUE;

METHOD PUBLIC Close
_IsCommanded := FALSE;

METHOD PUBLIC SetStuck
VAR_INPUT
    IsStuck : BOOL;
END_VAR
_IsStuck := IsStuck;

METHOD PUBLIC CyclicLogic
IF NOT _IsConfigured OR _IsStuck THEN
    RETURN;
END_IF
IF _IsCommanded <> _IsAtOpen AND NOT _IsMoving THEN
    _IsMoving := TRUE;                 // a new command: leave the end position
    _MoveStart := _Clock.Now;
    _IsAtOpen := FALSE;
    _IsAtClosed := FALSE;
END_IF
IF _IsMoving AND_THEN _Clock.Now - _MoveStart >= _TravelTime THEN
    _IsMoving := FALSE;
    _IsAtOpen := _IsCommanded;
    _IsAtClosed := NOT _IsCommanded;
END_IF

PROPERTY PUBLIC IsOpen : BOOL
GET: IsOpen := _IsAtOpen;

PROPERTY PUBLIC IsClosed : BOOL
GET: IsClosed := _IsAtClosed;

PROPERTY PUBLIC Name : STRING
GET: Name := _Name;

PROPERTY PUBLIC HasFault : BOOL
GET: HasFault := NOT _IsConfigured;

PROPERTY PUBLIC FaultText : STRING
GET: FaultText := SEL(_IsConfigured, 'Simulated valve has no clock', '');
