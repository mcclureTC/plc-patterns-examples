FUNCTION_BLOCK FakeClock IMPLEMENTS I_Clock
VAR
    _Now : LTIME;
END_VAR
(*
    FakeClock

    Stands still until the test moves it.
*)

METHOD PUBLIC Advance
VAR_INPUT
    Duration : LTIME;
END_VAR
_Now := _Now + Duration;

PROPERTY PUBLIC Now : LTIME
GET: Now := _Now;
