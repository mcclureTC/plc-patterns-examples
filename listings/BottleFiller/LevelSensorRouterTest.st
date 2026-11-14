FUNCTION_BLOCK LevelSensorRouterTest EXTENDS TestBase
VAR
    _Hardware     : FakeLevelSensor(Level := 10.0);
    _Simulated    : FakeLevelSensor(Level := 90.0);
    _ToHardware   : LevelSensorRouter(Simulated := _Simulated, Hardware := _Hardware, UseHardware := TRUE);
    _ToSimulation : LevelSensorRouter(Simulated := _Simulated, Hardware := _Hardware, UseHardware := FALSE);
    _ToNothing    : LevelSensorRouter(Simulated := 0, Hardware := 0, UseHardware := TRUE);
END_VAR
(*
    LevelSensorRouterTest

    Each switch setting reads its own sensor; a router with nothing to
    choose reports an invalid reading.
*)

METHOD PUBLIC Run
Check(_ToHardware.Level = 10.0 AND NOT _ToHardware.IsSimulated, 'hardware chosen: it reads the hardware');
Check(_ToSimulation.Level = 90.0 AND _ToSimulation.IsSimulated, 'simulation chosen: it reads the simulation');
Check(NOT _ToNothing.IsValid AND _ToNothing.Level = 0.0, 'nothing chosen: invalid, level 0');
