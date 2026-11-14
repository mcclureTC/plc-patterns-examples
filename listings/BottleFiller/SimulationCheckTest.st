FUNCTION_BLOCK SimulationCheckTest EXTENDS TestBase
VAR
    _OnDesk    : SimulationCheck(IsOnMachine := FALSE);
    _OnMachine : SimulationCheck(IsOnMachine := TRUE);
    _Ok        : BOOL;
END_VAR
(*
    SimulationCheckTest

    Every device that isn't final hardware is listed; only on the machine
    is that a fault.
*)

METHOD PUBLIC Run
_Ok := _OnDesk.AddDevice(Name := 'Tank valve', Source := E_DeviceSource.Simulation);
_Ok := _OnDesk.AddDevice(Name := 'Lift', Source := E_DeviceSource.FinalHardware) AND _Ok;
_Ok := _OnDesk.AddDevice(Name := 'Tank level', Source := E_DeviceSource.SimilarHardware) AND _Ok;
Check(_Ok, 'every device is accepted');
Check(_OnDesk.NotFinalCount = 2 AND _OnDesk.NotFinalDevices = 'Tank valve, Tank level',
      'the devices that are not final hardware are listed');
Check(NOT _OnDesk.HasFault, 'on a desk, that is not a fault');

_OnMachine.AddDevice(Name := 'Lift', Source := E_DeviceSource.FinalHardware);
Check(NOT _OnMachine.HasFault, 'on the machine, final hardware is no fault');
_OnMachine.AddDevice(Name := 'Tank valve', Source := E_DeviceSource.Simulation);
Check(_OnMachine.HasFault, 'on the machine, a simulated device is a fault');
