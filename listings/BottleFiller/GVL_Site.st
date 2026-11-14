{attribute 'qualified_only'}
VAR_GLOBAL
    // Edited by hand for each site. A release never overwrites this file.
    // Read at start-up only: a change takes effect after a PLC restart, and
    // until then SiteCheck reports it as a fault.
    Switches : ST_SiteSwitches := (UseFillValveHardware   := FALSE,
                                   UseBottleLevelHardware := FALSE,
                                   UseLiftHardware        := FALSE,
                                   UseSlideHardware       := FALSE,
                                   UseGripperHardware     := FALSE,
                                   IsOnMachine            := FALSE);
END_VAR
