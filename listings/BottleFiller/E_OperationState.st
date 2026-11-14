{attribute 'qualified_only'}
{attribute 'strict'}
{attribute 'to_string'}
TYPE E_OperationState :
(
    Idle  := 0,     // never started
    Busy  := 1,
    Done  := 2,
    Error := 3
);
END_TYPE
