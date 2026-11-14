FUNCTION_BLOCK FakeLevelSensor IMPLEMENTS I_LevelSensor
VAR
    _Level : REAL;
END_VAR
(*
    FakeLevelSensor

    Test double for I_LevelSensor. Always valid, at the level it was given.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains : BOOL;
    bInCopyCode  : BOOL;
    Level        : REAL;
END_VAR
_Level := Level;

PROPERTY PUBLIC Level : REAL
GET: Level := _Level;

PROPERTY PUBLIC IsValid : BOOL
GET: IsValid := TRUE;
