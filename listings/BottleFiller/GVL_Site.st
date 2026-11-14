{attribute 'qualified_only'}
VAR_GLOBAL CONSTANT
    // Edited for each controller; a release never overwrites this list.
    // FinalHardware on the machine. As delivered, everything is simulated.
    TankValveSource  : E_DeviceSource := E_DeviceSource.Simulation;
    DrainValveSource : E_DeviceSource := E_DeviceSource.Simulation;
    TankLevelSource  : E_DeviceSource := E_DeviceSource.Simulation;
    LiftSource       : E_DeviceSource := E_DeviceSource.Simulation;
    SlideSource      : E_DeviceSource := E_DeviceSource.Simulation;
    GripperSource    : E_DeviceSource := E_DeviceSource.Simulation;
    IsOnMachine      : BOOL := FALSE;   // TRUE on the real machine: anything not final is a fault
END_VAR
