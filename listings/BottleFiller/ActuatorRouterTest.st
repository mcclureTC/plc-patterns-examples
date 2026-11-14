FUNCTION_BLOCK ActuatorRouterTest EXTENDS TestBase
VAR
    _Hardware      : FakeActuator(Name := 'Hardware');
    _Simulated     : FakeActuator(Name := 'Simulated');
    _ToHardware    : ActuatorRouter(Simulated := _Simulated, Hardware := _Hardware, UseHardware := TRUE);
    _ToSimulation  : ActuatorRouter(Simulated := _Simulated, Hardware := _Hardware, UseHardware := FALSE);
    _ToNothing     : ActuatorRouter(Simulated := 0, Hardware := 0, UseHardware := TRUE);
END_VAR
(*
    ActuatorRouterTest

    Each switch setting chooses its own actuator and forwards to it alone;
    a router with nothing to choose fails safe.
*)

METHOD PUBLIC Run
_ToHardware.Extend();
Check(_Hardware.ExtendCount = 1 AND _Simulated.ExtendCount = 0, 'hardware chosen: only the hardware moves');
Check(_ToHardware.Name = 'Hardware' AND NOT _ToHardware.IsSimulated, 'hardware chosen: it reports the hardware');

_ToSimulation.Extend();
Check(_Simulated.ExtendCount = 1 AND _Hardware.ExtendCount = 1, 'simulation chosen: only the simulation moves');
Check(_ToSimulation.Name = 'Simulated' AND _ToSimulation.IsSimulated, 'simulation chosen: it reports the simulation');

_ToSimulation.Reset();
Check(_Simulated.ResetCount = 1 AND _Hardware.ResetCount = 0, 'reset reaches the chosen actuator only');

_ToNothing.Extend();
Check(NOT _ToNothing.IsExtended AND NOT _ToNothing.IsRetracted AND _ToNothing.HasFault,
      'nothing chosen: neither end, and faulted');
