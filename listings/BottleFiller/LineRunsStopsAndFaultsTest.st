FUNCTION_BLOCK LineRunsStopsAndFaultsTest EXTENDS TestBase
VAR
    _Filler   : FakeEquipmentModule(Name := 'Filling');
    _Transfer : FakeEquipmentModule(Name := 'Transfer');
    _Line     : LineModule(Name := 'Line 1', Filler := _Filler, Transfer := _Transfer);
    _IsWired  : BOOL;
END_VAR
(*
    LineRunsStopsAndFaultsTest

    The line fills, then transfers, and repeats; a stop is taken at the end
    of the bottle; a fault stops all commands until it clears, and the line
    then waits for a new start.
*)

METHOD PUBLIC Run
// The fakes are children too, so the line sees their faults and resets them
_IsWired := _Line.AddChild(Child := _Filler) AND _Line.AddChild(Child := _Transfer);
Check(_IsWired, 'both stations added');

// Power-up: stopped, nothing commanded
_Line.CyclicLogic();
Check(_Line.State = E_LineState.Stopped AND _Filler.StartCount = 0, 'stopped at power-up');

// Start: one bottle is filled
_Line.Start();
_Line.CyclicLogic();
Check(_Line.State = E_LineState.Filling AND _Filler.StartCount = 1, 'start fills a bottle');

// The fill is not done yet: the line waits
_Line.CyclicLogic();
Check(_Line.State = E_LineState.Filling AND _Transfer.StartCount = 0, 'waits for the fill');

// The fill is done: the bottle is moved out
_Filler.FinishCycle();
_Line.CyclicLogic();
Check(_Line.State = E_LineState.Transferring AND _Transfer.StartCount = 1, 'then transfers');

// The transfer is done: the next bottle is filled
_Transfer.FinishCycle();
_Line.CyclicLogic();
Check(_Line.State = E_LineState.Filling AND _Filler.StartCount = 2, 'then fills the next bottle');

// Stop during a fill: the bottle is finished first
_Line.Stop();
_Line.CyclicLogic();
Check(_Line.State = E_LineState.Filling AND _Line.IsStopping, 'stop waits for the bottle');
_Filler.FinishCycle();
_Line.CyclicLogic();
Check(_Line.State = E_LineState.Transferring, 'the bottle is still moved out');
_Transfer.FinishCycle();
_Line.CyclicLogic();
Check(_Line.State = E_LineState.Stopped AND _Filler.StartCount = 2, 'then stops, with no new fill');

// A fault: nothing is commanded, not even a start
_Line.Start();
_Filler.SetFault(IsActive := TRUE);
_Line.CyclicLogic();
Check(_Line.State = E_LineState.Faulted AND _Filler.StartCount = 2, 'a fault blocks the start');

// Reset reaches every station
_Line.Reset();
Check(_Filler.ResetCount = 1 AND _Transfer.ResetCount = 1, 'reset reaches both stations');

// The fault clears: stopped, and waiting for a new start
_Filler.SetFault(IsActive := FALSE);
_Line.CyclicLogic();
Check(_Line.State = E_LineState.Stopped AND _Filler.StartCount = 2, 'stopped after the fault, no restart');
