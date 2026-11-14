PROGRAM TestMain
VAR
    LineTest        : LineRunsStopsAndFaultsTest;
    ActuatorTests   : ActuatorRouterTest;
    ValveTests      : FillValveRouterTest;
    LevelTests      : LevelSensorRouterTest;
    HasRun          : BOOL;
    AllPassed       : BOOL;
    FailedCount     : INT;
END_VAR

// Each test runs once, on the first scan. None of them touches the machine's
// instances or its I/O. Read AllPassed, FailedCount and each test's
// LastFailure in a watch window.
IF NOT HasRun THEN
    HasRun := TRUE;
    LineTest.Run();
    ActuatorTests.Run();
    ValveTests.Run();
    LevelTests.Run();
    AllPassed := LineTest.HasPassed AND ActuatorTests.HasPassed
                 AND ValveTests.HasPassed AND LevelTests.HasPassed;
    FailedCount := LineTest.FailedCount + ActuatorTests.FailedCount
                   + ValveTests.FailedCount + LevelTests.FailedCount;
END_IF
