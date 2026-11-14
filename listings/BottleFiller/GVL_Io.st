{attribute 'qualified_only'}
VAR_GLOBAL
    // Filling station
    FillValveCoil  AT %Q* : BOOL;
    FillValveOpen  AT %I* : BOOL;
    BottleLevel    AT %I* : DINT;           // level sensor process data, 0.1 mm
    BottleSensorOk AT %I* : BOOL;           // the sensor's valid bit; see the project document

    // Transfer station
    LiftValve      AT %Q* : BOOL;
    LiftDown       AT %I* : BOOL;
    LiftUp         AT %I* : BOOL;
    SlideOutCoil   AT %Q* : BOOL;
    SlideInCoil    AT %Q* : BOOL;
    SlideOut       AT %I* : BOOL;
    SlideIn        AT %I* : BOOL;
    GripperValve   AT %Q* : BOOL;
    GripperClosed  AT %I* : BOOL;
    GripperOpen    AT %I* : BOOL;
END_VAR
