FUNCTION_BLOCK EquipmentGroup IMPLEMENTS I_Diagnosable, I_Resettable
VAR CONSTANT
    MaxChildren : DINT := 16;
END_VAR
VAR
    _Name        : STRING(32);
    _Children    : ARRAY[0..MaxChildren - 1] OF I_Diagnosable;
    _Resettables : ARRAY[0..MaxChildren - 1] OF I_Resettable;
    _Count       : DINT;
END_VAR
(*
    EquipmentGroup

    A named group of devices or other groups, behind the same interfaces
    as one device. It has a fault while any child has one, and reports
    the first faulted child's text, prefixed with that child's name.
    Reset() resets every child that implements I_Resettable.
    AddChild() is called while wiring, before the group is first asked.
*)

METHOD FB_init : BOOL
VAR_INPUT
    bInitRetains : BOOL;
    bInCopyCode  : BOOL;
    Name         : STRING(32);
END_VAR
_Name := Name;

METHOD PUBLIC AddChild : BOOL
VAR_INPUT
    Child : I_Diagnosable;
END_VAR
VAR
    Me         : I_Diagnosable;
    Resettable : I_Resettable;
    i          : DINT;
END_VAR
Me := THIS^;
IF Child = 0 OR Child = Me OR _Count >= MaxChildren THEN
    AddChild := FALSE;
    RETURN;
END_IF
FOR i := 0 TO _Count - 1 DO           // the same child only once
    IF _Children[i] = Child THEN
        AddChild := FALSE;
        RETURN;
    END_IF
END_FOR
_Children[_Count] := Child;
IF __QUERYINTERFACE(Child, Resettable) THEN
    _Resettables[_Count] := Resettable;
END_IF
_Count := _Count + 1;
AddChild := TRUE;

METHOD PUBLIC Reset
VAR
    i : DINT;
END_VAR
FOR i := 0 TO _Count - 1 DO
    IF _Resettables[i] <> 0 THEN
        _Resettables[i].Reset();
    END_IF
END_FOR

METHOD PRIVATE FirstFaultIndex : DINT
VAR
    i : DINT;
END_VAR
FOR i := 0 TO _Count - 1 DO
    IF _Children[i].HasFault THEN
        FirstFaultIndex := i;
        RETURN;
    END_IF
END_FOR
FirstFaultIndex := _Count;            // no child has a fault

METHOD PRIVATE DescribeFault : STRING
VAR_INPUT
    Index : DINT;
END_VAR
DescribeFault := '';
IF Index < _Count THEN
    DescribeFault := CONCAT(CONCAT(_Children[Index].Name, ': '), _Children[Index].FaultText);
END_IF

PROPERTY PUBLIC Name : STRING
GET: Name := _Name;

PROPERTY PUBLIC HasFault : BOOL
GET: HasFault := FirstFaultIndex() < _Count;

PROPERTY PUBLIC FaultText : STRING
GET: FaultText := DescribeFault(Index := FirstFaultIndex());

PROPERTY PUBLIC ChildCount : DINT
GET: ChildCount := _Count;
