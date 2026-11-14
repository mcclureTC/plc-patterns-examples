FUNCTION_BLOCK FillValveRouter IMPLEMENTS I_FillValve
VAR
    _Chosen     : I_FillValve;
    _IsHardware : BOOL;
END_VAR
(*
    FillValveRouter

    Chooses the real or the simulated fill valve once, in FB_init, from a
    site switch, and forwards every call to it. With no valve it fails safe:
    neither open nor closed, and faulted. Holds no logic of its own.

    The tree runs and resets Chosen, not the router.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains : BOOL;
    bInCopyCode  : BOOL;
    Simulated    : I_FillValve;
    Hardware     : I_FillValve;
    UseHardware  : BOOL;
END_VAR
_IsHardware := UseHardware;
IF UseHardware THEN
    _Chosen := Hardware;
ELSE
    _Chosen := Simulated;
END_IF

METHOD PUBLIC Open
IF _Chosen <> 0 THEN
    _Chosen.Open();
END_IF

METHOD PUBLIC Close
IF _Chosen <> 0 THEN
    _Chosen.Close();
END_IF

PROPERTY PUBLIC IsOpen : BOOL
GET: IsOpen := (_Chosen <> 0) AND_THEN _Chosen.IsOpen;

PROPERTY PUBLIC IsClosed : BOOL
GET: IsClosed := (_Chosen <> 0) AND_THEN _Chosen.IsClosed;

PROPERTY PUBLIC HasFault : BOOL
GET: HasFault := (_Chosen = 0) OR_ELSE _Chosen.HasFault;

PROPERTY PUBLIC FaultText : STRING
GET:
IF _Chosen = 0 THEN
    FaultText := 'No valve chosen';
ELSE
    FaultText := _Chosen.FaultText;
END_IF

PROPERTY PUBLIC Name : STRING
GET:
IF _Chosen = 0 THEN
    Name := 'Unassigned valve';
ELSE
    Name := _Chosen.Name;
END_IF

PROPERTY PUBLIC Chosen : I_FillValve
GET: Chosen := _Chosen;

PROPERTY PUBLIC IsSimulated : BOOL
GET: IsSimulated := NOT _IsHardware;
