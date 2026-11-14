{attribute 'qualified_only'}
{attribute 'strict'}
{attribute 'to_string'}
TYPE E_ActuatorTarget :
(
    None      := 0,     // no move commanded yet; what the outputs do is up to the actuator
    Extended  := 10,
    Retracted := 20
);
END_TYPE
