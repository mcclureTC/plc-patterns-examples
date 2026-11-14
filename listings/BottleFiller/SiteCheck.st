FUNCTION_BLOCK SiteCheck IMPLEMENTS I_Diagnosable, I_Cyclic
VAR
    _Switches         : REFERENCE TO ST_SiteSwitches;
    _Snapshot         : ST_SiteSwitches;
    _HasSnapshot      : BOOL;
    _HasChanged       : BOOL;
    _SimulatedCount   : DINT;
    _SimulatedDevices : STRING(255);
    _IsConfigured     : BOOL;
END_VAR
(*
    SiteCheck

    Keeps simulation off a production machine. Takes a copy of the site
    switches on its first scan and reports a fault, until the PLC restarts,
    if they change: the routers chose in FB_init and still hold the old
    choice. Reports a fault while any device is simulated on a machine
    marked IsOnMachine. AddSimulated() is called once per simulated device
    while wiring; SimulatedDevices names them for the HMI and for records.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains : BOOL;
    bInCopyCode  : BOOL;
    Switches     : REFERENCE TO ST_SiteSwitches;
END_VAR
_Switches REF= Switches;
_IsConfigured := __ISVALIDREF(Switches);

METHOD PUBLIC AddSimulated
VAR_INPUT
    Name : STRING(32);
END_VAR
_SimulatedCount := _SimulatedCount + 1;
IF _SimulatedCount = 1 THEN
    _SimulatedDevices := Name;
ELSE
    _SimulatedDevices := CONCAT(CONCAT(_SimulatedDevices, ', '), Name);
END_IF

METHOD PUBLIC CyclicLogic
IF NOT _IsConfigured THEN
    RETURN;
END_IF
IF NOT _HasSnapshot THEN
    _Snapshot := _Switches;
    _HasSnapshot := TRUE;
    RETURN;
END_IF
IF MEMCMP(pBuf1 := ADR(_Snapshot), pBuf2 := ADR(_Switches), n := SIZEOF(_Snapshot)) <> 0 THEN
    _HasChanged := TRUE;                        // latched until the PLC restarts
END_IF

PROPERTY PUBLIC Name : STRING
GET: Name := 'Site switches';

PROPERTY PUBLIC HasFault : BOOL
GET:
IF NOT _IsConfigured THEN
    HasFault := TRUE;
ELSE
    HasFault := _HasChanged OR (_Switches.IsOnMachine AND _SimulatedCount > 0);
END_IF

PROPERTY PUBLIC FaultText : STRING
GET:
IF NOT _IsConfigured THEN
    FaultText := 'Site switches not wired';
ELSIF _HasChanged THEN
    FaultText := 'Site switches changed; restart the PLC';
ELSIF _Switches.IsOnMachine AND _SimulatedCount > 0 THEN
    FaultText := CONCAT('Simulated on the machine: ', _SimulatedDevices);
ELSE
    FaultText := '';
END_IF

PROPERTY PUBLIC SimulatedDevices : STRING(255)
GET: SimulatedDevices := _SimulatedDevices;

PROPERTY PUBLIC SimulatedCount : DINT
GET: SimulatedCount := _SimulatedCount;
