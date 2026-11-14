FUNCTION_BLOCK FakeFillValve IMPLEMENTS I_FillValve
VAR
    _Name      : STRING(32);
    _OpenCount : DINT;
END_VAR
(*
    FakeFillValve

    Test double for I_FillValve. Counts Open() calls, reports its own name,
    and is always open.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains : BOOL;
    bInCopyCode  : BOOL;
    Name         : STRING(32);
END_VAR
_Name := Name;

METHOD PUBLIC Open
_OpenCount := _OpenCount + 1;

METHOD PUBLIC Close

PROPERTY PUBLIC IsOpen : BOOL
GET: IsOpen := TRUE;

PROPERTY PUBLIC IsClosed : BOOL
GET: IsClosed := FALSE;

PROPERTY PUBLIC Name : STRING
GET: Name := _Name;

PROPERTY PUBLIC HasFault : BOOL
GET: HasFault := FALSE;

PROPERTY PUBLIC FaultText : STRING
GET: FaultText := '';

PROPERTY PUBLIC OpenCount : DINT
GET: OpenCount := _OpenCount;
