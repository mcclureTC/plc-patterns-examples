{attribute 'qualified_only'}
VAR_GLOBAL
    // From the HMI
    StartButton      : BOOL;
    StopButton       : BOOL;
    ResetButton      : BOOL;

    // To the HMI
    LineState        : E_LineState;
    IsStopping       : BOOL;
    FaultText        : STRING;
    NotFinalDevices  : STRING(255);         // every device that isn't the machine's own; empty on the machine
END_VAR
