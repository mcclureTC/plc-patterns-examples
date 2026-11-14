FUNCTION_BLOCK PickAndPlaceModule EXTENDS ModuleGroup IMPLEMENTS I_EquipmentModule
VAR
    _Sequence         : REFERENCE TO PickAndPlaceSequence;
    _IsCycleRequested : BOOL;
    _IsConfigured     : BOOL;
END_VAR
(*
    PickAndPlaceModule

    The pick-and-place station. Runs its PickAndPlaceSequence, then its
    actuators. One StartCycle() moves one bottle from the filler to the
    outfeed. It has a fault while the sequence reports one, which includes
    every actuator's; Reset() resets both.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains : BOOL;
    bInCopyCode  : BOOL;
    Name         : STRING(32);                  // for EquipmentGroup
    Sequence     : REFERENCE TO PickAndPlaceSequence;
END_VAR
_Sequence REF= Sequence;
_IsConfigured := __ISVALIDREF(Sequence);

METHOD PUBLIC StartCycle
_IsCycleRequested := TRUE;

METHOD PROTECTED BeforeChildren
IF NOT _IsConfigured THEN
    RETURN;
END_IF
IF _IsCycleRequested
   AND (_Sequence.CurrentStep = E_PickStep.Idle OR _Sequence.CurrentStep = E_PickStep.Done) THEN
    _Sequence.Start();
    _IsCycleRequested := FALSE;
END_IF
_Sequence.CyclicLogic();                        // the sequence decides; the actuators move after it

METHOD PUBLIC Reset
SUPER^.Reset();                                 // the actuators
IF _IsConfigured THEN
    _Sequence.Reset();
END_IF
_IsCycleRequested := FALSE;

PROPERTY PUBLIC IsCycleDone : BOOL
GET: IsCycleDone := _IsConfigured AND_THEN (NOT _IsCycleRequested AND _Sequence.CurrentStep = E_PickStep.Done);

PROPERTY PUBLIC HasFault : BOOL
GET:
IF NOT _IsConfigured THEN
    HasFault := TRUE;
ELSE
    HasFault := SUPER^.HasFault OR _Sequence.HasFault;
END_IF

PROPERTY PUBLIC FaultText : STRING
GET:
IF NOT _IsConfigured THEN
    FaultText := 'Pick and place not wired';
ELSIF SUPER^.HasFault THEN
    FaultText := SUPER^.FaultText;              // the actuator, by name
ELSIF _Sequence.HasFault THEN
    FaultText := _Sequence.FaultText;
ELSE
    FaultText := '';
END_IF
