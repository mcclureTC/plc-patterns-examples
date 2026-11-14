FUNCTION_BLOCK PickAndPlaceSequence
VAR
    _Lift            : I_Actuator;
    _Slide           : I_Actuator;
    _Gripper         : I_Actuator;
    _CurrentStep      : E_PickStep;
    _FaultText        : STRING;
    _IsStartRequested : BOOL;
    _IsResetRequested : BOOL;
    _IsConfigured     : BOOL;
END_VAR
(*
    PickAndPlaceSequence

    Picks a part, slides across, places it and slides back. Moves three
    I_Actuator, injected through FB_init, and never knows what kind each
    one is.

    Call CyclicLogic() once per cycle. Start() and Reset() are requests,
    seen during the next CyclicLogic() call. After a reset it returns home the way a cycle ends:
    lift up, then slide in.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains : BOOL;
    bInCopyCode  : BOOL;
    Lift         : I_Actuator;      // extended = down
    Slide        : I_Actuator;      // extended = over the place position
    Gripper      : I_Actuator;      // extended = closed
END_VAR
_Lift := Lift;
_Slide := Slide;
_Gripper := Gripper;
_IsConfigured := Lift <> 0 AND Slide <> 0 AND Gripper <> 0;

METHOD PUBLIC Start
_IsStartRequested := TRUE;

METHOD PUBLIC Reset
_IsResetRequested := TRUE;

METHOD PUBLIC CyclicLogic
IF NOT _IsConfigured THEN
    _CurrentStep := E_PickStep.Error;      // not wired: never call through 0
    _FaultText := 'Pick and place not wired';
    RETURN;
END_IF

CASE _CurrentStep OF
    E_PickStep.Undefined:
        _CurrentStep := E_PickStep.Idle;

    E_PickStep.Idle, E_PickStep.Done:
        IF _IsStartRequested THEN
            _CurrentStep := E_PickStep.LowerToPick;
        END_IF

    E_PickStep.LowerToPick:   ExtendThen(Actuator := _Lift, NextStep := E_PickStep.Grip);
    E_PickStep.Grip:          ExtendThen(Actuator := _Gripper, NextStep := E_PickStep.RaiseWithPart);
    E_PickStep.RaiseWithPart: RetractThen(Actuator := _Lift, NextStep := E_PickStep.SlideOut);
    E_PickStep.SlideOut:      ExtendThen(Actuator := _Slide, NextStep := E_PickStep.LowerToPlace);
    E_PickStep.LowerToPlace:  ExtendThen(Actuator := _Lift, NextStep := E_PickStep.OpenGripper);
    E_PickStep.OpenGripper:   RetractThen(Actuator := _Gripper, NextStep := E_PickStep.RaiseEmpty);
    E_PickStep.RaiseEmpty:    RetractThen(Actuator := _Lift, NextStep := E_PickStep.SlideIn);
    E_PickStep.SlideIn:       RetractThen(Actuator := _Slide, NextStep := E_PickStep.Done);

    E_PickStep.Error:
        IF _IsResetRequested THEN
            _Lift.Reset(); _Slide.Reset(); _Gripper.Reset();
            _FaultText := '';
            _CurrentStep := E_PickStep.RaiseEmpty;   // go home the way a cycle ends
        END_IF
END_CASE

_IsStartRequested := FALSE;
_IsResetRequested := FALSE;

METHOD PRIVATE ExtendThen
VAR_INPUT
    Actuator : I_Actuator;
    NextStep : E_PickStep;
END_VAR
Actuator.Extend();
IF Actuator.IsExtended THEN
    _CurrentStep := NextStep;
ELSIF Actuator.HasFault THEN
    Fail(Actuator := Actuator);
END_IF

METHOD PRIVATE RetractThen
VAR_INPUT
    Actuator : I_Actuator;
    NextStep : E_PickStep;
END_VAR
Actuator.Retract();
IF Actuator.IsRetracted THEN
    _CurrentStep := NextStep;
ELSIF Actuator.HasFault THEN
    Fail(Actuator := Actuator);
END_IF

METHOD PRIVATE Fail
VAR_INPUT
    Actuator : I_Actuator;
END_VAR
_FaultText := CONCAT(CONCAT(Actuator.Name, ': '), Actuator.FaultText);
_CurrentStep := E_PickStep.Error;

PROPERTY PUBLIC CurrentStep : E_PickStep
GET: CurrentStep := _CurrentStep;

PROPERTY PUBLIC IsBusy : BOOL
GET:
IsBusy := _CurrentStep <> E_PickStep.Undefined AND _CurrentStep <> E_PickStep.Idle
            AND _CurrentStep <> E_PickStep.Done AND _CurrentStep <> E_PickStep.Error;

PROPERTY PUBLIC HasFault : BOOL
GET:
IF _IsConfigured THEN
    HasFault := _Lift.HasFault OR _Slide.HasFault OR _Gripper.HasFault;
END_IF
HasFault := HasFault OR _CurrentStep = E_PickStep.Error;

PROPERTY PUBLIC FaultText : STRING
GET: FaultText := _FaultText;
