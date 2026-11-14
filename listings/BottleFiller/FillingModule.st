FUNCTION_BLOCK FillingModule EXTENDS ModuleGroup IMPLEMENTS I_EquipmentModule
VAR
    _Sequence         : REFERENCE TO FillSequence;
    _IsCycleRequested : BOOL;
    _IsConfigured     : BOOL;
END_VAR
(*
    FillingModule

    The filling station. Runs its FillSequence, then its devices. One
    StartCycle() fills one bottle. It has a fault while any of its devices
    has one, or while the sequence has stopped with an error; Reset()
    resets both.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains : BOOL;
    bInCopyCode  : BOOL;
    Name         : STRING(32);                  // for EquipmentGroup
    Sequence     : REFERENCE TO FillSequence;
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
   AND (_Sequence.CurrentStep = E_FillStep.Idle OR _Sequence.CurrentStep = E_FillStep.Done) THEN
    _Sequence.Start();
    _IsCycleRequested := FALSE;
END_IF
_Sequence.CyclicLogic();                        // the sequence decides; the valve acts after it

METHOD PUBLIC Reset
SUPER^.Reset();                                 // the devices
IF _IsConfigured THEN
    _Sequence.Reset();
END_IF
_IsCycleRequested := FALSE;

PROPERTY PUBLIC IsCycleDone : BOOL
GET: IsCycleDone := _IsConfigured AND_THEN (NOT _IsCycleRequested AND _Sequence.IsDone);

PROPERTY PUBLIC HasFault : BOOL
GET:
IF NOT _IsConfigured THEN
    HasFault := TRUE;
ELSE
    HasFault := SUPER^.HasFault OR _Sequence.HasError;
END_IF

PROPERTY PUBLIC FaultText : STRING
GET:
IF NOT _IsConfigured THEN
    FaultText := 'Fill sequence not wired';
ELSIF SUPER^.HasFault THEN
    FaultText := SUPER^.FaultText;              // the device, by name
ELSIF _Sequence.HasError THEN
    FaultText := 'Fill sequence stopped; reset to continue';
ELSE
    FaultText := '';
END_IF
