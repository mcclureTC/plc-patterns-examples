FUNCTION_BLOCK DoubleSolenoidCylinder EXTENDS ActuatorBase
VAR
    _ExtendCoil      : REFERENCE TO BOOL;
    _RetractCoil     : REFERENCE TO BOOL;
    _ExtendedSensor  : REFERENCE TO BOOL;
    _RetractedSensor : REFERENCE TO BOOL;
END_VAR
(*
    DoubleSolenoidCylinder

    One coil per direction. With both coils off, the valve holds the cylinder
    where it is. An end sensor at each end.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains    : BOOL;
    bInCopyCode     : BOOL;
    Name            : STRING(32);
    MoveTimeout     : TIME;
    ExtendCoil      : REFERENCE TO BOOL;
    RetractCoil     : REFERENCE TO BOOL;
    ExtendedSensor  : REFERENCE TO BOOL;
    RetractedSensor : REFERENCE TO BOOL;
END_VAR
_ExtendCoil REF= ExtendCoil;
_RetractCoil REF= RetractCoil;
_ExtendedSensor REF= ExtendedSensor;
_RetractedSensor REF= RetractedSensor;
Configure(Name := Name, MoveTimeout := MoveTimeout);

METHOD PROTECTED IsWired : BOOL
IsWired := __ISVALIDREF(_ExtendCoil) AND __ISVALIDREF(_RetractCoil)
       AND __ISVALIDREF(_ExtendedSensor) AND __ISVALIDREF(_RetractedSensor);

METHOD PROTECTED DriveOutputs
VAR_INPUT
    Target : E_ActuatorTarget;
END_VAR
_ExtendCoil := Target = E_ActuatorTarget.Extended;
_RetractCoil := Target = E_ActuatorTarget.Retracted;  // None: both off, so it holds

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
_ExtendCoil := FALSE;                               // both off: the cylinder stays where it is
_RetractCoil := FALSE;
