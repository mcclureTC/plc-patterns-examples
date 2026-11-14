FUNCTION_BLOCK DrainTankCommand IMPLEMENTS I_Command
VAR CONSTANT
    EmptyLevel : REAL := 2.0;          // percent
END_VAR
VAR
    _DrainValve   : I_FillValve;
    _Level        : I_LevelSensor;
    _Clock        : I_Clock;
    _Timeout      : LTIME;
    _StartedAt    : LTIME;
    _State        : E_OperationState;
    _FaultText    : STRING;
    _IsConfigured : BOOL;
END_VAR
(*
    DrainTankCommand

    Opens the drain valve until the tank reads empty. Ends in Error if the
    level sensor is invalid, the valve faults, or the tank isn't empty
    within the timeout. Every ending closes the drain valve.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains : BOOL;
    bInCopyCode  : BOOL;
    DrainValve   : I_FillValve;     // any on/off valve with feedback fits this contract
    Level        : I_LevelSensor;
    Clock        : I_Clock;
    Timeout      : LTIME;
END_VAR
_DrainValve := DrainValve;
_Level := Level;
_Clock := Clock;
_Timeout := Timeout;
_IsConfigured := DrainValve <> 0 AND Level <> 0 AND Clock <> 0;

METHOD PUBLIC Start
IF _State = E_OperationState.Busy THEN
    RETURN;
END_IF
IF NOT _IsConfigured THEN
    _State := E_OperationState.Error;
    _FaultText := 'Drain command not wired';
    RETURN;
END_IF
_StartedAt := _Clock.Now;
_FaultText := '';
_State := E_OperationState.Busy;
_DrainValve.Open();

METHOD PUBLIC CyclicLogic
IF _State <> E_OperationState.Busy THEN
    RETURN;
END_IF

IF NOT _Level.IsValid THEN
    Finish(Outcome := E_OperationState.Error, Text := 'Level sensor invalid');
ELSIF _DrainValve.HasFault THEN
    Finish(Outcome := E_OperationState.Error, Text := _DrainValve.FaultText);
ELSIF _Level.Level <= EmptyLevel THEN
    Finish(Outcome := E_OperationState.Done, Text := '');
ELSIF _Clock.Now - _StartedAt >= _Timeout THEN
    Finish(Outcome := E_OperationState.Error, Text := 'Tank did not empty in time');
END_IF

METHOD PUBLIC Abort
IF _State = E_OperationState.Busy THEN
    Finish(Outcome := E_OperationState.Error, Text := 'Aborted');
END_IF

METHOD PRIVATE Finish
VAR_INPUT
    Outcome : E_OperationState;
    Text    : STRING;
END_VAR
_DrainValve.Close();                 // every ending, good or bad, leaves the drain closed
_State := Outcome;
_FaultText := Text;

PROPERTY PUBLIC Name : STRING
GET: Name := 'Drain tank';

PROPERTY PUBLIC State : E_OperationState
GET: State := _State;

PROPERTY PUBLIC FaultText : STRING
GET: FaultText := _FaultText;
