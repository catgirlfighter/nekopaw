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
  _NO_FIELD_: String = 'Field "%s" not found';

  (* SCRIPT READ ERROR *)
  _SCRIPT_READ_ERROR_: String = 'Error reading script: %s';
  _SYMBOLS_IN_SECTOR_NAME_: String = 'Incorrect symbol in sector name';
  _INCORRECT_DECLORATION_: String = 'Incorrect decloration near symbol %s';


(* COMMONS *)
  _SYMBOL_MISSED_: String = 'Can''t found symbol "%s" for #%d "%s" in "%s"';
  _OPERATOR_MISSED_: String = 'Must be an operator instead of #%d "%s" in "%s"';
  _OPERAND_MISSED_: String = 'Must be an oparand instead of #%d "%s" in "%s"';
  _INVALID_TYPECAST_: String = 'Invalid typecast for "%s" %s "%s" near #%d in "%s"';
  _INCORRECT_SYMBOL_: String = 'Incorrect value "%s" near #%d in "%s"';
  _TAB_IS_BUSY_: String = 'Tab is busy. You need to stop the work first';

  (* OTHER *)
  _MAINCONFIG_: String = 'Main configuration';
  _EDITIONALCONFIG_: String ='Editionals';
  _TAGSTRING_: String = 'Tag';
  _INHERIT_: String = 'Inherit configuration';
  _SETTINGS_: String = 'Settings';
  _GENERAL_: STring = 'General';
implementation

end.
