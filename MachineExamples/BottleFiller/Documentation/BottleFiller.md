# BottleFiller

The bottle filler from the Machine Examples tab on mccluretc.github.io ("A bottle filler built as a module tree"), as a TwinCAT 3 PLC project.

Empty bottles roll into the filler one at a time. The machine fills the bottle under the nozzle to a target level, then a pick-and-place moves the full bottle to the outfeed, and it repeats until Stop is pressed. Stop finishes the bottle in progress. A fault anywhere stops all new commands; when the fault has cleared the line is Stopped and waits for Start.

Every device can run real or simulated, chosen per device by a site switch, so the whole machine runs on a PC with no I/O.

## Environment

| | |
|---|---|
| TwinCAT version | 3.1 Build 4026 (record the exact build you validate with) |
| Target platform | Any TwinCAT 3 target; a PC with the runtime trial license runs the simulated machine |
| Task | PlcTask, 10 ms, priority 20, calls MAIN then TestMain |

## Libraries

| Library | Version | Used for |
|---|---|---|
| Tc2_Standard | resolved by the Library Manager; record it | TON (move, mismatch and simulation timers), R_TRIG (operator buttons), CONCAT (fault texts) |
| Tc2_System | resolved by the Library Manager; record it | GETCURTASKINDEXEX and _TaskInfo (the simulated level's cycle time), MEMCMP (site switch change detection) |

## Licenses required on the target

| Number | Product | Why |
|---|---|---|
| TC1200 | TC3 PLC | The PLC runtime. Verify against the current Beckhoff catalog. |

## Structure

The tree is built by MAIN, and run by one call, Line.CyclicLogic():

| Level | Instance | Type | Runs first, in BeforeChildren() | Children, in order |
|---|---|---|---|---|
| Machine | Line | LineModule | The state machine | Site, Filling, Transfer |
| Check | Site | SiteCheck | (not a module) | none |
| Station | Filling | FillingModule | FillSeq | the chosen fill valve |
| Station | Transfer | TransferModule | TransferSeq | the chosen lift, slide and gripper |

The line's states (E_LineState): Stopped, Filling, Transferring, Faulted. A stop request is a flag, IsStopping, taken when the transfer finishes.

Folders follow the machine areas:

- Framework: I_Diagnosable, I_Resettable, I_Cyclic, I_EquipmentModule, EquipmentGroup, ModuleGroup
- Shared: the actuators (I_Actuator, ActuatorBase and its three kinds), the simulated actuator and the actuator router
- Filling: the fill valve, the level sensor, each with its simulation and router, FillSequence and FillingModule
- Transfer: PickAndPlaceSequence and TransferModule
- Line: LineModule and E_LineState
- Site: the site switches, the failure hooks and SiteCheck
- GVLs: GVL_Io (the I/O) and GVL_Hmi (the HMI)
- Tests: TestBase, the test doubles, the tests and TestMain

Inside each function block, methods and properties sit in a folder named for the interface that declares them.

## Simulation

| Device | Real | Simulated | Failure hook (GVL_Sim) | Router | Switch (GVL_Site.Switches) |
|---|---|---|---|---|---|
| Fill valve | SolenoidValve | SimulatedFillValve: feedback follows the command after 200 ms | FillValveStuck: the feedback freezes, the valve faults after 2 s | FillValveRouter | UseFillValveHardware |
| Bottle level | FieldbusLevelSensor | SimulatedBottleLevel: rises 25 % per second while the valve is open; each fill starts with an empty bottle | BottleLevelSignalLost: the reading goes invalid | LevelSensorRouter | UseBottleLevelHardware |
| Lift | SingleSolenoidCylinder | SimulatedActuator, 400 ms travel | LiftStuck: the move times out | ActuatorRouter | UseLiftHardware |
| Slide | DoubleSolenoidCylinder | SimulatedActuator, 800 ms travel | SlideStuck | ActuatorRouter | UseSlideHardware |
| Gripper | Gripper | SimulatedActuator, 150 ms travel | GripperStuck | ActuatorRouter | UseGripperHardware |

- Every switch is FALSE as delivered: the whole machine is simulated.
- The routers choose once, in FB_init. Only the chosen device is added to the tree, so only it is run, reset and reported, and an unused device's I/O need not be linked.
- A failure hook acts only while its device is simulated.
- SiteCheck reports a fault, until the PLC restarts, if GVL_Site changes while running. With IsOnMachine set, any simulated device is a fault.
- GVL_Hmi.SimulatedDevices names every simulated device, and one flag per device marks it for the HMI. Write SimulatedDevices into any record the machine produces.

## Running it

1. Add the project to a TwinCAT solution, check the two libraries in the Library Manager, build, and activate on a target or on the local PC.
2. Log in. TestMain runs the tests on the first scan: TestMain.AllPassed should be TRUE and TestMain.FailedCount 0. Each test's LastFailure names the first check that failed.
3. Set GVL_Hmi.StartButton TRUE, then FALSE. Watch GVL_Hmi.LineState go Filling, Transferring, Filling. Set GVL_Hmi.StopButton to stop at the end of the bottle.
4. Set a failure hook in GVL_Sim, for example LiftStuck. The line goes Faulted and GVL_Hmi.FaultText names the device. Clear the hook, press ResetButton, then StartButton.

## Before connecting real hardware

- Link every GVL_Io variable to the right terminal channel. BottleSensorOk must be the sensor's own valid bit, or a status derived from the terminal's WcState; a frozen reading must not count as valid.
- Set each device's switch in GVL_Site to TRUE only once its I/O is linked and checked, and set IsOnMachine TRUE on the machine.
- Check the timeouts against the real valve and cylinders: FaultDelay, MoveTimeout and the gripper's settle time.
- Emergency stop, guarding and any other safety function belong in the safety controller. Nothing in this project is a safety function; Faulted stops new commands, it does not stop motion.
- Check the cycle time with _TaskInfo LastExecTime.

## On the website

The page "A bottle filler built as a module tree" (https://mccluretc.github.io/MachineExamples/module-tree/) walks through this project. Its listings are generated from these files; see the repository README.

## Conventions

PascalCase names, _PascalCase private fields, no Hungarian notation, no code in function block bodies, no VAR_INPUT or VAR_OUTPUT on function blocks, dependencies through FB_init, and CyclicLogic() as the cyclic method.
