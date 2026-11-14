TYPE ST_SiteSwitches :
STRUCT
    // TRUE: the real hardware. FALSE: the simulation.
    UseFillValveHardware   : BOOL;
    UseBottleLevelHardware : BOOL;
    UseLiftHardware        : BOOL;
    UseSlideHardware       : BOOL;
    UseGripperHardware     : BOOL;
    // TRUE on the real machine: any simulated device is then a fault
    IsOnMachine            : BOOL;
END_STRUCT
END_TYPE
