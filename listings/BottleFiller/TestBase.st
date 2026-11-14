FUNCTION_BLOCK ABSTRACT TestBase
VAR
    _CheckCount  : INT;
    _FailedCount : INT;
    _LastFailure : STRING(255);
END_VAR
(*
    TestBase

    Shared bookkeeping for framework-free tests. A derived test implements
    Run() and calls Check() for everything it wants to verify.
*)

METHOD PUBLIC ABSTRACT Run

METHOD PROTECTED Check
VAR_INPUT
    Condition : BOOL;
    Message   : STRING(255);    // what should be true, not what went wrong
END_VAR
_CheckCount := _CheckCount + 1;
IF NOT Condition THEN
    _FailedCount := _FailedCount + 1;
    _LastFailure := Message;
END_IF

PROPERTY PUBLIC HasPassed : BOOL
GET: HasPassed := _CheckCount > 0 AND _FailedCount = 0;

PROPERTY PUBLIC FailedCount : INT
GET: FailedCount := _FailedCount;

PROPERTY PUBLIC LastFailure : STRING(255)
GET: LastFailure := _LastFailure;
