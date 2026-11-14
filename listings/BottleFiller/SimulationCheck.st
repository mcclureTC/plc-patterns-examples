FUNCTION_BLOCK SimulationCheck IMPLEMENTS I_Diagnosable
VAR
    _IsOnMachine    : BOOL;
    _NotFinalCount  : DINT;
    _NotFinalNames  : STRING(255);
END_VAR
(*
    SimulationCheck

    Told, while wiring, the name and source of every routed device. Lists
    every device that isn't FinalHardware, for the HMI and the event log.
    On a controller whose site is the machine itself, each of them is a
    fault.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains : BOOL;
    bInCopyCode  : BOOL;
    IsOnMachine  : BOOL;
END_VAR
_IsOnMachine := IsOnMachine;

METHOD PUBLIC AddDevice : BOOL
VAR_INPUT
    Name   : STRING(32);
    Source : E_DeviceSource;
END_VAR
AddDevice := TRUE;
IF Source = E_DeviceSource.FinalHardware THEN
    RETURN;
END_IF
_NotFinalCount := _NotFinalCount + 1;
IF _NotFinalCount = 1 THEN
    _NotFinalNames := Name;
ELSE
    _NotFinalNames := CONCAT(CONCAT(_NotFinalNames, ', '), Name);
END_IF

PROPERTY PUBLIC Name : STRING
GET: Name := 'Device sources';

PROPERTY PUBLIC HasFault : BOOL
GET: HasFault := _IsOnMachine AND _NotFinalCount > 0;

PROPERTY PUBLIC FaultText : STRING
GET:
IF HasFault THEN
    FaultText := CONCAT('Not final hardware: ', _NotFinalNames);
ELSE
    FaultText := '';
END_IF

PROPERTY PUBLIC NotFinalDevices : STRING(255)
GET: NotFinalDevices := _NotFinalNames;

PROPERTY PUBLIC NotFinalCount : DINT
GET: NotFinalCount := _NotFinalCount;
