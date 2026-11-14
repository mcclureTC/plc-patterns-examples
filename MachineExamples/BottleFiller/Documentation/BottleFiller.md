# BottleFiller

The bottle filler from the Machine Examples tab on mccluretc.github.io ("A bottle filler built as a module tree"), as a TwinCAT 3 PLC project.

Each bottle gets a measured dose. The filling station fills a small dosing tank to its target level, then drains it into the bottle below. The pick-and-place then moves the full bottle to the outfeed, and the next bottle rolls in. The line repeats until Stop is pressed, and Stop finishes the bottle in progress. A fault anywhere stops all new commands; when the fault has cleared the line is Stopped and waits for Start.

Every block in the project is listed on a page of the site, and the site's listings are generated from these files. Every device can be real or simulated, chosen per device in GVL_Site, so the whole machine runs on a PC with no I/O.

## Environment

| | |
|---|---|
| TwinCAT version | 3.1 Build 4026 (record the exact build you validate with) |
| Target platform | Any TwinCAT 3 target; a PC with the runtime trial license runs the simulated machine |
| Task | PlcTask, 10 ms, priority 20, calls MAIN then TestMain |

## Libraries

| Library | Version | Used for |
|---|---|---|
| Tc2_Standard | resolved by the Library Manager; record it | TON (valve and actuator supervision), R_TRIG (operator buttons), CONCAT (fault texts) |

## Licenses required on the target

| Number | Product | Why |
|---|---|---|
| TC1200 | TC3 PLC | The PLC runtime. Verify against the current Beckhoff catalog. |

## Where each block comes from

| Folder | Blocks | Page |
|---|---|---|
| Framework | I_Diagnosable, I_Resettable, I_Cyclic, EquipmentGroup, ModuleGroup | Composite |
| Framework | I_EquipmentModule | Equipment modules |
| Framework | I_Clock, TaskClock | Testing time |
| Framework | I_Command, E_OperationState | Command; Execute / Busy / Done / Error |
| Shared | I_Actuator, E_ActuatorTarget, ActuatorBase (plus I_Cyclic, as Composite describes), SingleSolenoidCylinder, DoubleSolenoidCylinder, Gripper | Template Method |
| Shared | ActuatorRouter, SimulatedActuator | Supporting code |
| Filling | I_FillValve | Interface segregation |
| Filling | SolenoidValve | Supporting code (the complete version) |
| Filling | FillValveRouter, SimulatedValve, TankModel | Simulation by interface swap |
| Filling | I_LevelSensor, FieldbusLevelSensor | Open/closed |
| Filling | LevelSensorRouter | Supporting code |
| Filling | FillSequence, E_FillStep | Dependency inversion |
| Filling | DrainTankCommand | Command |
| Filling | FillingModule | Equipment modules |
| PickAndPlace | PickAndPlaceSequence, E_PickStep | Supporting code |
| PickAndPlace | PickAndPlaceModule | Equipment modules |
| Line | LineModule, E_LineState | Equipment modules |
| Site | E_DeviceSource, SimulationCheck | Simulation by interface swap |
| Site, GVLs | GVL_Site, GVL_Sim, GVL_Io, GVL_Hmi | This machine |
| Tests | TestBase | Anatomy of a test |
| Tests | FakeClock | Testing time |
| Tests | FakeEquipmentModule | Supporting code |
| Tests | LineRunsStopsAndFaultsTest | Equipment modules |
| Tests | SimulatedValveTakesItsTravelTimeTest, SimulationCheckTest | Simulation by interface swap |
| (root) | MAIN | The bottle filler page |

## Structure

The tree is built by MAIN, and run by one call, Line.CyclicLogic():

| Level | Instance | Type | Runs first, in BeforeChildren() | Children, in order |
|---|---|---|---|---|
| Machine | Line | LineModule | The state machine | Sources, Filling, PickAndPlace |
| Check | Sources | SimulationCheck | (nothing to run) | none |
| Station | Filling | FillingModule | TankFill, then Dose | TankValve, DrainValve (routers) |
| Station | PickAndPlace | PickAndPlaceModule | PickPlace | LiftCylinder, SlideCylinder, PartGripper (routers) |

The line's states (E_LineState): Stopped, Filling, Transferring, Faulted. A stop request is a flag, IsStopping, taken when the transfer finishes. MAIN also runs TankLevel, the level router, before the line, because the level sensor isn't a device of the tree.

## Simulation

Each device has a real and a simulated candidate behind a router. GVL_Site chooses, per device; as delivered, every device is Simulation.

| Device | Router | Real | Simulated | Failure hook (GVL_Sim) |
|---|---|---|---|---|
| Tank valve | TankValve : FillValveRouter | SolenoidValve | SimulatedValve, 400 ms travel | TankValveStuck: the valve stops answering; the fill waits (FillSequence has no timeout) |
| Drain valve | DrainValve : FillValveRouter | SolenoidValve | SimulatedValve, 400 ms travel | DrainValveStuck: the dose times out after 30 s and the line faults |
| Tank level | TankLevel : LevelSensorRouter | FieldbusLevelSensor | TankModel: rises 20 % per second while the tank valve is open, falls 25 % per second while the drain valve is open | none |
| Lift | LiftCylinder : ActuatorRouter | SingleSolenoidCylinder | SimulatedActuator, 400 ms travel | LiftStuck: the move times out after 1 s and the line faults |
| Slide | SlideCylinder : ActuatorRouter | DoubleSolenoidCylinder | SimulatedActuator, 800 ms travel | SlideStuck |
| Gripper | PartGripper : ActuatorRouter | Gripper | SimulatedActuator, 150 ms travel | GripperStuck |

- GVL_Site holds constants, so a change takes effect with the next download.
- Only the chosen candidate runs: the routers run it.
- A failure hook acts only while its device's source is Simulation.
- SimulationCheck lists every device that isn't FinalHardware in GVL_Hmi.NotFinalDevices. With IsOnMachine set, each of them is a fault.

## Running it

1. Add the project to a TwinCAT solution, check Tc2_Standard in the Library Manager, build, and activate on a target or on the local PC.
2. Log in. TestMain runs the tests on the first scan: TestMain.AllPassed should be TRUE and TestMain.FailedCount 0. Each test's LastFailure names the first check that failed.
3. Pulse GVL_Hmi.StartButton. Watch GVL_Hmi.LineState go Filling, Transferring, Filling; MAIN.SimTank.Level rises to 80 % and drains each cycle. Pulse GVL_Hmi.StopButton to stop at the end of the bottle.
4. Set GVL_Sim.LiftStuck TRUE. The line goes Faulted and GVL_Hmi.FaultText names the device. Clear the hook, pulse ResetButton, then StartButton.

## Before connecting real hardware

- Link every GVL_Io variable to the right terminal channel. TankSensorOk must be the sensor's own valid bit, or a status derived from the terminal's WcState; a frozen reading must not count as valid.
- Set each device's source in GVL_Site to FinalHardware only once its I/O is linked and checked, and set IsOnMachine TRUE on the machine.
- A real device whose I/O isn't connected still runs: its inputs simply never change, and its supervision reports it (for example "Move did not finish in time").
- Check the timeouts against the real valves and cylinders: FaultDelay, MoveTimeout, the gripper's settle time and the dose's 30 s.
- Emergency stop, guarding and any other safety function belong in the safety controller. Nothing in this project is a safety function; Faulted stops new commands, it does not stop motion.

## On the website

The page "A bottle filler built as a module tree" (https://mccluretc.github.io/MachineExamples/module-tree/) walks through how these blocks combine, and why. Its listings, and those of the pages above, are generated from these files; see the repository README.

## Conventions

PascalCase names, _PascalCase private fields, no Hungarian notation, no code in function block bodies, no VAR_INPUT or VAR_OUTPUT on function blocks, dependencies through FB_init, and CyclicLogic() as the cyclic method.
