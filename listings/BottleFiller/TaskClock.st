FUNCTION_BLOCK TaskClock IMPLEMENTS I_Clock
VAR
    _CycleTime : LTIME;
    _Now       : LTIME;
END_VAR
(*
    TaskClock

    Advances by the task's cycle time on every CyclicLogic() call. Call it
    once per scan, first, before anything that reads Now.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains : BOOL;
    bInCopyCode  : BOOL;
    CycleTime    : LTIME;
END_VAR
_CycleTime := CycleTime;

METHOD PUBLIC CyclicLogic
_Now := _Now + _CycleTime;

PROPERTY PUBLIC Now : LTIME
GET: Now := _Now;
