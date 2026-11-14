{attribute 'qualified_only'}
VAR_GLOBAL
    // From the HMI
    StartButton          : BOOL;
    StopButton           : BOOL;
    ResetButton          : BOOL;

    // To the HMI
    LineState            : E_LineState;
    IsStopping           : BOOL;
    FaultText            : STRING;
    SimulatedDevices     : STRING(255);     // empty when every device is real
    IsFillValveSimulated : BOOL;
    IsBottleLevelSimulated : BOOL;
    IsLiftSimulated      : BOOL;
    IsSlideSimulated     : BOOL;
    IsGripperSimulated   : BOOL;
END_VAR
