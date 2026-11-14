{attribute 'qualified_only'}
VAR_GLOBAL
    // Failure hooks for the simulated devices, set from the HMI or a watch
    // window. Each one acts only while its device is simulated.
    TankValveStuck  : BOOL;
    DrainValveStuck : BOOL;
    LiftStuck       : BOOL;
    SlideStuck      : BOOL;
    GripperStuck    : BOOL;
END_VAR
