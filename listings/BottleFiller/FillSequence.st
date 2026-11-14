FUNCTION_BLOCK FillSequence
VAR
    _LevelSensor      : I_LevelSensor;
    _FillValve        : I_FillValve;
    _TargetLevel      : REAL := 80.0;
    _CurrentStep      : E_FillStep := E_FillStep.Idle;
    _IsStartRequested : BOOL;
    _IsResetRequested : BOOL;
    _IsConfigured     : BOOL;
END_VAR
(*
    FillSequence

    Opens the fill valve, waits for the target level, closes the valve.
    Talks only to I_LevelSensor and I_FillValve, injected through FB_init.

    Call CyclicLogic() once per cycle. Start() and Reset() are requests,
    seen during the next CyclicLogic() call.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains : BOOL;
    bInCopyCode  : BOOL;
    LevelSensor  : I_LevelSensor;
    FillValve    : I_FillValve;
END_VAR
_LevelSensor := LevelSensor;
_FillValve := FillValve;
_IsConfigured := LevelSensor <> 0 AND FillValve <> 0;

METHOD PUBLIC Start
_IsStartRequested := TRUE;

METHOD PUBLIC Reset
_IsResetRequested := TRUE;

METHOD PUBLIC CyclicLogic
IF NOT _IsConfigured THEN
    _CurrentStep := E_FillStep.Error;   // not wired: fail safe, never call through 0
    RETURN;
END_IF

CASE _CurrentStep OF
    E_FillStep.Idle, E_FillStep.Done:
        IF _IsStartRequested THEN
            _CurrentStep := E_FillStep.Opening;
        END_IF

    E_FillStep.Opening:
        _FillValve.Open();
        IF _FillValve.IsOpen THEN
            _CurrentStep := E_FillStep.Filling;
        ELSIF _FillValve.HasFault THEN
            _CurrentStep := E_FillStep.Error;
        END_IF

    E_FillStep.Filling:
        IF NOT _LevelSensor.IsValid OR _FillValve.HasFault THEN
            _CurrentStep := E_FillStep.Error;
        ELSIF _LevelSensor.Level >= _TargetLevel THEN
            _CurrentStep := E_FillStep.Closing;
        END_IF

    E_FillStep.Closing:
        _FillValve.Close();
        IF _FillValve.IsClosed THEN
            _CurrentStep := E_FillStep.Done;
        ELSIF _FillValve.HasFault THEN
            _CurrentStep := E_FillStep.Error;
        END_IF

    E_FillStep.Error:
        _FillValve.Close();             // the one promise every valve keeps
        IF _IsResetRequested AND _FillValve.IsClosed THEN
            _CurrentStep := E_FillStep.Idle;
        END_IF
END_CASE

_IsStartRequested := FALSE;
_IsResetRequested := FALSE;

PROPERTY PUBLIC TargetLevel : REAL
GET: TargetLevel := _TargetLevel;
SET: _TargetLevel := LIMIT(0.0, TargetLevel, 100.0);

PROPERTY PUBLIC CurrentStep : E_FillStep
GET: CurrentStep := _CurrentStep;

PROPERTY PUBLIC IsBusy : BOOL
GET:
IsBusy := _CurrentStep = E_FillStep.Opening
            OR _CurrentStep = E_FillStep.Filling
            OR _CurrentStep = E_FillStep.Closing;

PROPERTY PUBLIC IsDone : BOOL
GET: IsDone := _CurrentStep = E_FillStep.Done;

PROPERTY PUBLIC HasError : BOOL
GET: HasError := _CurrentStep = E_FillStep.Error;
