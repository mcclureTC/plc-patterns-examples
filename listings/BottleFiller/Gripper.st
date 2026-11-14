FUNCTION_BLOCK Gripper EXTENDS SingleSolenoidCylinder
(*
    Gripper

    A single-solenoid gripper: Extend closes, Retract opens. After the closed
    sensor confirms, the jaws need a moment to build full grip pressure.
*)

PROPERTY PROTECTED SettleTime : TIME
GET: SettleTime := T#150MS;
