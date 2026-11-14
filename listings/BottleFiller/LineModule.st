FUNCTION_BLOCK LineModule EXTENDS ModuleGroup
VAR
    _Filler           : I_EquipmentModule;
    _Transfer         : I_EquipmentModule;
    _State            : E_LineState;
    _IsStartRequested : BOOL;
    _IsStopping       : BOOL;
    _IsConfigured     : BOOL;
END_VAR
(*
    LineModule

    The machine module. Fills a bottle, moves it out, and repeats until
    stopped. Commands its two stations in BeforeChildren(), before they
    run in the same scan.

    Start() starts the line. Stop() lets the bottle in progress finish.
    A fault anywhere in the tree stops commanding and shows Faulted; once
    the tree no longer reports a fault, the line is Stopped and waits for
    Start(). Reset(), inherited, resets the whole tree.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains : BOOL;
    bInCopyCode  : BOOL;
    Name         : STRING(32);                  // for EquipmentGroup
    Filler       : I_EquipmentModule;
    Transfer     : I_EquipmentModule;
END_VAR
_Filler := Filler;
_Transfer := Transfer;
_IsConfigured := Filler <> 0 AND Transfer <> 0;

METHOD PUBLIC Start
_IsStartRequested := TRUE;
_IsStopping := FALSE;                           // a start cancels a stop that hasn't been taken yet

METHOD PUBLIC Stop
IF _State <> E_LineState.Stopped THEN
    _IsStopping := TRUE;                        // taken when the bottle is out
END_IF

METHOD PROTECTED BeforeChildren
IF NOT _IsConfigured THEN
    _State := E_LineState.Faulted;
    RETURN;
END_IF

// A fault anywhere in the tree: command nothing
IF HasFault THEN
    _State := E_LineState.Faulted;
    _IsStopping := FALSE;
    _IsStartRequested := FALSE;
    RETURN;
END_IF

CASE _State OF
    E_LineState.Stopped:
        IF _IsStartRequested THEN
            _Filler.StartCycle();
            _State := E_LineState.Filling;
        END_IF

    E_LineState.Filling:
        IF _Filler.IsCycleDone THEN
            _Transfer.StartCycle();
            _State := E_LineState.Transferring;
        END_IF

    E_LineState.Transferring:
        IF _Transfer.IsCycleDone THEN
            IF _IsStopping THEN
                _IsStopping := FALSE;
                _State := E_LineState.Stopped;
            ELSE
                _Filler.StartCycle();           // the next bottle
                _State := E_LineState.Filling;
            END_IF
        END_IF

    E_LineState.Faulted:
        _State := E_LineState.Stopped;          // no fault any more; wait for Start
END_CASE

_IsStartRequested := FALSE;

PROPERTY PUBLIC State : E_LineState
GET: State := _State;

PROPERTY PUBLIC IsStopping : BOOL
GET: IsStopping := _IsStopping;
