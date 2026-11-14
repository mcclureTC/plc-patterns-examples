{attribute 'qualified_only'}
{attribute 'strict'}
{attribute 'to_string'}
TYPE E_PickStep :
(
    Undefined      := 0,
    Idle           := 10,
    LowerToPick    := 20,
    Grip           := 30,
    RaiseWithPart  := 40,
    SlideOut       := 50,
    LowerToPlace   := 60,
    OpenGripper    := 70,
    RaiseEmpty     := 80,
    SlideIn        := 90,
    Done           := 100,
    Error          := 900
);
END_TYPE
