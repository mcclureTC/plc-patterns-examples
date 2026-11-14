INTERFACE I_Command EXTENDS __SYSTEM.IQueryInterface

PROPERTY Name : STRING   // GET

METHOD Start                        // begin; ignored while Busy

METHOD CyclicLogic                  // one scan of work; called by the invoker while Busy

METHOD Abort                        // stop now and leave everything safe; ends in Error

PROPERTY State : E_OperationState   // GET

PROPERTY FaultText : STRING   // GET
