FUNCTION_BLOCK TankModel IMPLEMENTS I_LevelSensor, I_Cyclic
VAR
    _Inflow       : I_FillValve;
    _Outflow      : I_FillValve;
    _Clock        : I_Clock;
    _FillRate     : REAL;              // percent per second, inflow valve open
    _DrainRate    : REAL;              // percent per second, outflow valve open
    _Level        : REAL;
    _LastNow      : LTIME;
    _IsStarted    : BOOL;
    _IsConfigured : BOOL;
END_VAR
(*
    TankModel

    A simulated tank: the level rises while the inflow valve is open and
    falls while the outflow valve is open. Reads both through
    I_FillValve, so it works with simulated and real valves alike.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains : BOOL;
    bInCopyCode  : BOOL;
    Inflow       : I_FillValve;
    Outflow      : I_FillValve;
    Clock        : I_Clock;
    FillRate     : REAL;
    DrainRate    : REAL;
    StartLevel   : REAL;
END_VAR
_Inflow := Inflow;
_Outflow := Outflow;
_Clock := Clock;
_FillRate := FillRate;
_DrainRate := DrainRate;
_Level := StartLevel;
_IsConfigured := Inflow <> 0 AND Outflow <> 0 AND Clock <> 0;

METHOD PUBLIC CyclicLogic
VAR
    Now     : LTIME;
    Seconds : REAL;
END_VAR
IF NOT _IsConfigured THEN
    RETURN;
END_IF
Now := _Clock.Now;
IF NOT _IsStarted THEN
    _IsStarted := TRUE;
    _LastNow := Now;
    RETURN;
END_IF
Seconds := LREAL_TO_REAL(LTIME_TO_LREAL(Now - _LastNow) / 1.0E9);   // LTIME counts nanoseconds
_LastNow := Now;
IF _Inflow.IsOpen THEN
    _Level := _Level + _FillRate * Seconds;
END_IF
IF _Outflow.IsOpen THEN
    _Level := _Level - _DrainRate * Seconds;
END_IF
_Level := LIMIT(0.0, _Level, 100.0);

PROPERTY PUBLIC Level : REAL
GET: Level := _Level;

PROPERTY PUBLIC IsValid : BOOL
GET: IsValid := _IsConfigured;
