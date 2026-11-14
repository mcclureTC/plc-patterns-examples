FUNCTION_BLOCK FillValveRouter IMPLEMENTS I_FillValve, I_Cyclic
VAR
    _Name   : STRING(32);
    _Source : E_DeviceSource;
    _Chosen : I_FillValve;
END_VAR
(*
    FillValveRouter

    One I_FillValve in front of up to four candidates. The site setting,
    given once in FB_init, chooses which candidate answers and which one
    is run. A source with no candidate (0) reports a fault and is never
    open.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains    : BOOL;
    bInCopyCode     : BOOL;
    Name            : STRING(32);
    Source          : E_DeviceSource;
    FinalHardware   : I_FillValve;
    SimilarHardware : I_FillValve;
    Simulation      : I_FillValve;
    Test            : I_FillValve;
END_VAR
_Name := Name;
_Source := Source;
CASE Source OF
    E_DeviceSource.FinalHardware:   _Chosen := FinalHardware;
    E_DeviceSource.SimilarHardware: _Chosen := SimilarHardware;
    E_DeviceSource.Simulation:      _Chosen := Simulation;
    E_DeviceSource.Test:            _Chosen := Test;
END_CASE

METHOD PUBLIC CyclicLogic
VAR
    Cyclic : I_Cyclic;
END_VAR
IF _Chosen <> 0 AND_THEN __QUERYINTERFACE(_Chosen, Cyclic) THEN
    Cyclic.CyclicLogic();              // only the chosen candidate runs
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
GET: IsOpen := _Chosen <> 0 AND_THEN _Chosen.IsOpen;

PROPERTY PUBLIC IsClosed : BOOL
GET: IsClosed := _Chosen <> 0 AND_THEN _Chosen.IsClosed;

PROPERTY PUBLIC Name : STRING
GET: Name := _Name;

PROPERTY PUBLIC HasFault : BOOL
GET: HasFault := _Chosen = 0 OR_ELSE _Chosen.HasFault;

PROPERTY PUBLIC FaultText : STRING
GET:
IF _Chosen = 0 THEN
    FaultText := 'No device for this source';
ELSE
    FaultText := _Chosen.FaultText;
END_IF

PROPERTY PUBLIC Source : E_DeviceSource
GET: Source := _Source;
