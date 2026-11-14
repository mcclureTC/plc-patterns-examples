{attribute 'qualified_only'}
{attribute 'strict'}
{attribute 'to_string'}
TYPE E_LineState :
(
    Stopped      := 0,
    Filling      := 10,
    Transferring := 20,
    Faulted      := 900
);
END_TYPE
