FUNCTION_BLOCK SingleSolenoidCylinder EXTENDS ActuatorBase
VAR
    _Solenoid        : REFERENCE TO BOOL;
    _ExtendedSensor  : REFERENCE TO BOOL;
    _RetractedSensor : REFERENCE TO BOOL;
END_VAR
(*
    SingleSolenoidCylinder

    One solenoid with spring return: energized extends, de-energized retracts.
    An end sensor at each end.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains    : BOOL;
    bInCopyCode     : BOOL;
    Name            : STRING(32);
    MoveTimeout     : TIME;
    Solenoid        : REFERENCE TO BOOL;
    ExtendedSensor  : REFERENCE TO BOOL;
    RetractedSensor : REFERENCE TO BOOL;
END_VAR
_Solenoid REF= Solenoid;
_ExtendedSensor REF= ExtendedSensor;
_RetractedSensor REF= RetractedSensor;
Configure(Name := Name, MoveTimeout := MoveTimeout);

METHOD PROTECTED IsWired : BOOL
IsWired := __ISVALIDREF(_Solenoid) AND __ISVALIDREF(_ExtendedSensor) AND __ISVALIDREF(_RetractedSensor);

METHOD PROTECTED DriveOutputs
VAR_INPUT
    Target : E_ActuatorTarget;
END_VAR
_Solenoid := Target = E_ActuatorTarget.Extended;   // anything else: the spring retracts it

METHOD PROTECTED IsAtPosition : BOOL
VAR_INPUT
    Position : E_ActuatorTarget;
END_VAR
CASE Position OF
    E_ActuatorTarget.Extended:
        IsAtPosition := _ExtendedSensor AND NOT _RetractedSensor;
    E_ActuatorTarget.Retracted:
        IsAtPosition := _RetractedSensor AND NOT _ExtendedSensor;
ELSE
    IsAtPosition := FALSE;
END_CASE

METHOD PROTECTED DriveSafe
_Solenoid := FALSE;                                 // the spring takes it to the retracted end
