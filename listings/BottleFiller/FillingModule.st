FUNCTION_BLOCK FillingModule EXTENDS ModuleGroup IMPLEMENTS I_EquipmentModule
VAR
    _Fill             : REFERENCE TO FillSequence;
    _Dose             : I_Command;
    _IsCycleRequested : BOOL;
    _IsFilling        : BOOL;
    _IsDosing         : BOOL;
    _HasDoseFault     : BOOL;
    _DoseFault        : STRING;
    _IsConfigured     : BOOL;
END_VAR
(*
    FillingModule

    The filling station. One cycle measures one dose: the fill sequence
    fills the dosing tank to its target level, then the dose command
    drains it into the bottle below. Runs both before its valves. It has
    a fault while a valve has one, the fill sequence has stopped with an
    error, or the last dose ended in Error; Reset() clears all three.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains : BOOL;
    bInCopyCode  : BOOL;
    Name         : STRING(32);                  // for EquipmentGroup
    Fill         : REFERENCE TO FillSequence;
    Dose         : I_Command;
END_VAR
_Fill REF= Fill;
_Dose := Dose;
_IsConfigured := __ISVALIDREF(Fill) AND Dose <> 0;

METHOD PUBLIC StartCycle
_IsCycleRequested := TRUE;

METHOD PROTECTED BeforeChildren
IF NOT _IsConfigured THEN
    RETURN;
END_IF

// A new cycle starts with the fill, once the station is free
IF _IsCycleRequested AND NOT _IsFilling AND NOT _IsDosing
   AND (_Fill.CurrentStep = E_FillStep.Idle OR _Fill.CurrentStep = E_FillStep.Done) THEN
    _Fill.Start();
    _IsFilling := TRUE;
    _IsCycleRequested := FALSE;
END_IF
_Fill.CyclicLogic();

// The tank is at its level: dose it into the bottle
IF _IsFilling AND _Fill.IsDone THEN
    _IsFilling := FALSE;
    _Dose.Start();
    _IsDosing := TRUE;
END_IF
IF _IsDosing THEN
    _Dose.CyclicLogic();
    IF _Dose.State = E_OperationState.Error THEN
        _HasDoseFault := TRUE;
        _DoseFault := _Dose.FaultText;
        _IsDosing := FALSE;
    ELSIF _Dose.State = E_OperationState.Done THEN
        _IsDosing := FALSE;
    END_IF
END_IF

METHOD PUBLIC Reset
SUPER^.Reset();                                 // the valves
IF NOT _IsConfigured THEN
    RETURN;
END_IF
_Fill.Reset();
IF _IsDosing THEN
    _Dose.Abort();                              // closes the drain valve
END_IF
_IsCycleRequested := FALSE;
_IsFilling := FALSE;
_IsDosing := FALSE;
_HasDoseFault := FALSE;
_DoseFault := '';

PROPERTY PUBLIC IsCycleDone : BOOL
GET:
IsCycleDone := _IsConfigured AND_THEN (NOT _IsCycleRequested AND NOT _IsFilling AND NOT _IsDosing
                                             AND _Dose.State = E_OperationState.Done);

PROPERTY PUBLIC HasFault : BOOL
GET:
IF NOT _IsConfigured THEN
    HasFault := TRUE;
ELSE
    HasFault := SUPER^.HasFault OR _Fill.HasError OR _HasDoseFault;
END_IF

PROPERTY PUBLIC FaultText : STRING
GET:
IF NOT _IsConfigured THEN
    FaultText := 'Filling station not wired';
ELSIF SUPER^.HasFault THEN
    FaultText := SUPER^.FaultText;              // the valve, by name
ELSIF _Fill.HasError THEN
    FaultText := 'Fill stopped; reset to continue';
ELSIF _HasDoseFault THEN
    FaultText := CONCAT('Dose: ', _DoseFault);
ELSE
    FaultText := '';
END_IF
