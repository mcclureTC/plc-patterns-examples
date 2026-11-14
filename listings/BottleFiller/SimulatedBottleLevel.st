FUNCTION_BLOCK SimulatedBottleLevel IMPLEMENTS I_LevelSensor, I_Cyclic
VAR
    _Valve         : I_FillValve;
    _RisePerSecond : REAL;
    _Level         : REAL;
    _WasOpen       : BOOL;
    _IsSignalLost  : BOOL;
    _IsConfigured  : BOOL;
END_VAR
(*
    SimulatedBottleLevel

    A bottle level with no hardware: rises at RisePerSecond while the fill
    valve is open. Each time the valve opens, a new, empty bottle is
    assumed to be under the nozzle.

    Failure hook: SetSignalLost(TRUE) makes the reading invalid.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains  : BOOL;
    bInCopyCode   : BOOL;
    Valve         : I_FillValve;
    RisePerSecond : REAL;              // percent of the bottle per second
END_VAR
_Valve := Valve;
_RisePerSecond := RisePerSecond;
_IsConfigured := Valve <> 0;

METHOD PUBLIC SetSignalLost
VAR_INPUT
    IsLost : BOOL;
END_VAR
_IsSignalLost := IsLost;

METHOD PUBLIC CyclicLogic
VAR
    IsOpen       : BOOL;
    CycleSeconds : REAL;
END_VAR
IF NOT _IsConfigured THEN
    RETURN;
END_IF
IsOpen := _Valve.IsOpen;
IF IsOpen THEN
    IF NOT _WasOpen THEN
        _Level := 0.0;                               // a new bottle for every fill
    END_IF
    // CycleTime is in 100 ns units
    CycleSeconds := UDINT_TO_REAL(_TaskInfo[GETCURTASKINDEXEX()].CycleTime) / 10000000.0;
    _Level := MIN(_Level + _RisePerSecond * CycleSeconds, 100.0);
END_IF
_WasOpen := IsOpen;

PROPERTY PUBLIC Level : REAL
GET:
IF _IsSignalLost THEN
    Level := 0.0;
ELSE
    Level := _Level;
END_IF

PROPERTY PUBLIC IsValid : BOOL
GET: IsValid := _IsConfigured AND NOT _IsSignalLost;

PROPERTY PUBLIC IsSignalLost : BOOL
GET: IsSignalLost := _IsSignalLost;
