unit LangString;

interface

var

  (* DIALOG *)

  _YES_: String = 'Yes';
  _NO_: String = 'No';
  _APPLY_: String = 'Apply';
  _CANCEL_: String = 'Cancel';
  _ALL_: String = 'All';

  (* ERRORS *)
  _ERROR_OCCURED_: String = 'Error occured: %s';
  _NO_DIRECTORY_: String = 'Directory ''%s'' not exists';
  _NO_FILE_: String = 'File ''%s'' not found';
  _FILE_READ_ERROR_: String = 'Error reading file: %s';

  (* SCRIPT READ ERROR *)
  _SCRIPT_READ_ERROR_: String = 'Error reading script: %s';
  _SYMBOLS_IN_SECTOR_NAME_: String = 'Incorrect symbol in sector name';
  _INCORRECT_DECLORATION_: String = 'Incorrect decloration near symbol %s';


(* COMMONS *)
  _SYMBOL_MISSED_: String = 'Can''t found symbol "%s" for #%d';
  _OPERATOR_MISSED_: String = 'Must be an operator near #%d';
  _OPERAND_MISSED_: String = 'Must be an oparand near #%d';
  _INVALID_TYPECAST_: String = 'Invalid typecast for "%s" %s "%s" near %n';
  _INCORRECT_SYMBOL_: String = 'Incorrect symbol "%s" near %n';
implementation

end.
