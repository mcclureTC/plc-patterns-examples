PROGRAM TestMain
VAR
    LineTest    : LineRunsStopsAndFaultsTest;
    ValveTest   : SimulatedValveTakesItsTravelTimeTest;
    CheckTest   : SimulationCheckTest;
    HasRun      : BOOL;
    AllPassed   : BOOL;
    FailedCount : INT;
END_VAR

// Each test runs once, on the first scan. None of them touches the machine's
// instances or its I/O. Read AllPassed, FailedCount and each test's
// LastFailure in a watch window.
IF NOT HasRun THEN
    HasRun := TRUE;
    LineTest.Run();
    ValveTest.Run();
    CheckTest.Run();
    AllPassed := LineTest.HasPassed AND ValveTest.HasPassed AND CheckTest.HasPassed;
    FailedCount := LineTest.FailedCount + ValveTest.FailedCount + CheckTest.FailedCount;
END_IF
