FUNCTION_BLOCK ModuleGroup EXTENDS EquipmentGroup IMPLEMENTS I_Cyclic
VAR
    _Cyclics : ARRAY[0..MaxChildren - 1] OF I_Cyclic;
END_VAR
(*
    ModuleGroup

    An EquipmentGroup that also runs its children: one CyclicLogic() call
    runs every child that implements I_Cyclic, in the order they were
    added, between this module's own BeforeChildren() and AfterChildren().
    A station with logic of its own extends it and overrides the hooks.
*)

METHOD PUBLIC AddChild : BOOL
VAR_INPUT
    Child : I_Diagnosable;
END_VAR
VAR
    Cyclic : I_Cyclic;
END_VAR
IF NOT SUPER^.AddChild(Child := Child) THEN
    AddChild := FALSE;
    RETURN;
END_IF
IF __QUERYINTERFACE(Child, Cyclic) THEN
    _Cyclics[_Count - 1] := Cyclic;   // the slot SUPER^.AddChild() just filled
END_IF
AddChild := TRUE;

METHOD PUBLIC FINAL CyclicLogic
VAR
    i : DINT;
END_VAR
BeforeChildren();
FOR i := 0 TO _Count - 1 DO
    IF _Cyclics[i] <> 0 THEN
        _Cyclics[i].CyclicLogic();
    END_IF
END_FOR
AfterChildren();

METHOD PROTECTED BeforeChildren      // decide what the children should do this scan

METHOD PROTECTED AfterChildren       // read what they reported this scan
