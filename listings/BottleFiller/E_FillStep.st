{attribute 'qualified_only'}
{attribute 'strict'}
{attribute 'to_string'}
TYPE E_FillStep :
(
    Undefined := 0,
    Idle      := 10,
    Opening   := 20,
    Filling   := 30,
    Closing   := 40,
    Done      := 50,
    Error     := 900
);
END_TYPE
