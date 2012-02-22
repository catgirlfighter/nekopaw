unit LangString;

interface

uses SysUtils,INIFiles;

var

  _FILELANGUAGE_: String = 'English';

  (* DIALOG *)
  _OK_: String = 'Ok';
  _YES_: String = 'Yes';
  _NO_: String = 'No';
  _APPLY_: String = 'Apply';
  _CANCEL_: String = 'Cancel';
  _ALL_: String = 'All';
  _EXIT_: String = 'Exit';
  _PREVIOUSSTEP_: String = 'Previous step';
  _NEXTSTEP_: String = 'Next step';
  _FINISH_: String = 'Finish';

  (* ERRORS *)
  _ERROR_OCCURED_: String = 'Error occured: %s';
  _NO_DIRECTORY_: String = 'Directory ''%s'' not exists';
  _NO_FILE_: String = 'File ''%s'' not found';
  _FILE_READ_ERROR_: String = 'Error reading file: %s';
  _NO_FIELD_: String = 'Field "%s" not found';
  _SYMBOL_MISSED_: String = 'Can''t found symbol "%s" for #%d "%s" in "%s"';
  _OPERATOR_MISSED_: String = 'Must be an operator instead of #%d "%s" in "%s"';
  _OPERAND_MISSED_: String = 'Must be an oparand instead of #%d "%s" in "%s"';
  _INVALID_TYPECAST_: String = 'Invalid typecast for "%s" %s "%s" near #%d in "%s"';
  _INCORRECT_SYMBOL_: String = 'Incorrect value "%s" near #%d in "%s"';
  _TAB_IS_BUSY_: String = 'Tab is busy. You need to stop the work first';
  _SCRIPT_READ_ERROR_: String = 'Error reading script: %s';
  _SYMBOLS_IN_SECTOR_NAME_: String = 'Incorrect symbol in sector name';
  _INCORRECT_DECLORATION_: String = 'Incorrect decloration near symbol %s';
  _INCORRECT_FILESIZE_: String = 'Incorrect file size';

  (* OTHER *)
  _NEWLIST_: String = 'New list';
  _LOADLIST_: String = 'Load list';
  _SAVELIST_: String = 'Save list';
  _MAINCONFIG_: String = 'Main configuration';
  _EDITIONALCONFIG_: String ='Editionals';
  _TAGSTRING_: String = 'Tag';
  _INHERIT_: String = 'Inherit configuration';
  _SETTINGS_: String = 'Settings';
  _GENERAL_: String = 'General';
  _RESNAME_: String = 'Resource';
  _RESID_: String = '#';
  _PICTURELABEL_: String = 'Label';
  _COLUMNS_: String = 'Columns';
  _FILTER_: String = 'Filter';
  _ON_AIR_: String = 'ON AIR';
  _WORK_: String = 'Work';
  _THREADS_: String = 'Threads';
  _USE_PER_RES_: String = 'Threads per resource';
  _PER_RES_: String = 'Thr. per res.';
  _PIC_THREADS_: String = 'Pic. threads';
  _RETRIES_: String = 'Retries';
  _DEBUGMODE_: String = 'Debug';
  _PROXY_: String = 'Proxy';
  _USE_PROXY_: String = 'Use proxy';
  _AUTHORISATION_: String = 'Authorisation';
  _SAVE_PASSWORD_: String = 'Save password';
  _LOG_: String = 'Log';
  _ERRORS_: String = 'Errors';
  _STARTLIST_: String = 'Start getting list';
  _STOPLIST_: String = 'Stop getting list';
  _STARTPICS_: String = 'Start download pictures';
  _STOPPICS_: String = 'Stop download pictures';
  _NEWTABCAPTION_: String = 'New';
  _COUNT_: String = 'Count';
  _NAMEFORMAT_: String = 'Save file format';
  _SAVEPATH_: String = 'save path';
  _FILENAME_: String = 'File name';
  _EXTENSION_: String = 'Extension';
  _INFO_: String = 'Pic info';
  _TAGS_: String = 'Tags';
  _DOUBLES_: String = 'Doubles';

procedure LoadLang(FileName: String);

implementation

procedure LoadLang(FileName: String);
var
  INI: TINIFile;
begin

  if not FileExists(FileName) then
    Exit;

  INI := TINIFile.Create(FileName);
  _FILELANGUAGE_ := INI.ReadString('lang','_FILELANGUAGE_',_FILELANGUAGE_);
  (* DIALOG *)
  _OK_ := INI.ReadString('lang','_OK_',_OK_);
  _YES_ := INI.ReadString('lang','_YES_',_YES_);
  _NO_ := INI.ReadString('lang','_NO_',_NO_);
  _APPLY_ := INI.ReadString('lang','_APPLY_',_APPLY_);
  _CANCEL_ := INI.ReadString('lang','_CANCEL_',_CANCEL_);
  _ALL_ := INI.ReadString('lang','_ALL_',_ALL_);
  _EXIT_ := INI.ReadString('lang','_EXIT_',_EXIT_);
  _PREVIOUSSTEP_ := INI.ReadString('lang','_PREVIOUSSTEP_',_PREVIOUSSTEP_);
  _NEXTSTEP_ := INI.ReadString('lang','_NEXTSTEP_',_NEXTSTEP_);
  _FINISH_ := INI.ReadString('lang','_FINISH_',_FINISH_);

  (* ERRORS *)
  _ERROR_OCCURED_ := INI.ReadString('lang','_ERROR_OCCURED_',_ERROR_OCCURED_);
  _NO_DIRECTORY_ := INI.ReadString('lang','_NO_DIRECTORY_',_NO_DIRECTORY_);
  _NO_FILE_ := INI.ReadString('lang','_NO_FILE_',_NO_FILE_);
  _FILE_READ_ERROR_ := INI.ReadString('lang','_FILE_READ_ERROR_',_FILE_READ_ERROR_);
  _NO_FIELD_ := INI.ReadString('lang','_NO_FIELD_',_NO_FIELD_);
  _SYMBOL_MISSED_ := INI.ReadString('lang','_SYMBOL_MISSED_',_SYMBOL_MISSED_);
  _OPERATOR_MISSED_ := INI.ReadString('lang','_OPERATOR_MISSED_',_OPERATOR_MISSED_);
  _OPERAND_MISSED_ := INI.ReadString('lang','_OPERAND_MISSED_',_OPERAND_MISSED_);
  _INVALID_TYPECAST_ := INI.ReadString('lang','_INVALID_TYPECAST_',_INVALID_TYPECAST_);
  _INCORRECT_SYMBOL_ := INI.ReadString('lang','_INCORRECT_SYMBOL_',_INCORRECT_SYMBOL_);
  _TAB_IS_BUSY_ := INI.ReadString('lang','_TAB_IS_BUSY_',_TAB_IS_BUSY_);
  _SCRIPT_READ_ERROR_ := INI.ReadString('lang','_SCRIPT_READ_ERROR_',_SCRIPT_READ_ERROR_);
  _SYMBOLS_IN_SECTOR_NAME_ := INI.ReadString('lang','_SYMBOLS_IN_SECTOR_NAME_',_SYMBOLS_IN_SECTOR_NAME_);
  _INCORRECT_DECLORATION_ := INI.ReadString('lang','_INCORRECT_DECLORATION_',_INCORRECT_DECLORATION_);

  (* OTHER *)
  _NEWLIST_ := INI.ReadString('lang','_NEWLIST_',_NEWLIST_);
  _LOADLIST_ := INI.ReadString('lang','_LOADLIST_',_LOADLIST_);
  _SAVELIST_ := INI.ReadString('lang','_SAVELIST_',_SAVELIST_);
  _MAINCONFIG_ := INI.ReadString('lang','_MAINCONFIG_',_MAINCONFIG_);
  _EDITIONALCONFIG_ := INI.ReadString('lang','_EDITIONALCONFIG_',_EDITIONALCONFIG_);
  _TAGSTRING_ := INI.ReadString('lang','_TAGSTRING_',_TAGSTRING_);
  _INHERIT_ := INI.ReadString('lang','_INHERIT_',_INHERIT_);
  _SETTINGS_ := INI.ReadString('lang','_SETTINGS_',_SETTINGS_);
  _GENERAL_ := INI.ReadString('lang','_GENERAL_',_GENERAL_);
  _RESNAME_ := INI.ReadString('lang','_RESNAME_',_RESNAME_);
  _RESID_ := INI.ReadString('lang','_RESID_',_RESID_);
  _PICTURELABEL_ := INI.ReadString('lang','_PICTURELABEL_',_PICTURELABEL_);
  _COLUMNS_ := INI.ReadString('lang','_COLUMNS_',_COLUMNS_);
  _FILTER_ := INI.ReadString('lang','_FILTER_',_FILTER_);
  _ON_AIR_ := INI.ReadString('lang','_ON_AIR_',_ON_AIR_);
  _WORK_ := INI.ReadString('lang','_WORK_',_WORK_);
  _THREADS_ := INI.ReadString('lang','_THREADS_',_THREADS_);
  _USE_PER_RES_ := INI.ReadString('lang','_USE_PER_RES_',_USE_PER_RES_);
  _PER_RES_ := INI.ReadString('lang','_PER_RES_',_PER_RES_);
  _PIC_THREADS_ := INI.ReadString('lang','_PIC_THREADS_',_PIC_THREADS_);
  _RETRIES_ := INI.ReadString('lang','_RETRIES_',_RETRIES_);
  _DEBUGMODE_ := INI.ReadString('lang','_DEBUGMODE_',_DEBUGMODE_);
  _PROXY_ := INI.ReadString('lang','_PROXY_',_PROXY_);
  _USE_PROXY_ := INI.ReadString('lang','_USE_PROXY_',_USE_PROXY_);
  _AUTHORISATION_ := INI.ReadString('lang','_AUTHORISATION_',_AUTHORISATION_);
  _SAVE_PASSWORD_ := INI.ReadString('lang','_SAVE_PASSWORD_',_SAVE_PASSWORD_);
  _LOG_ := INI.ReadString('lang','_LOG_',_LOG_);
  _ERRORS_ := INI.ReadString('lang','_ERRORS_',_ERRORS_);
  _STARTLIST_ := INI.ReadString('lang','_STARTLIST_',_STARTLIST_);
  _STOPLIST_ := INI.ReadString('lang','_STOPLIST_',_STOPLIST_);
  _STARTPICS_ := INI.ReadString('lang','_STARTPICS_',_STARTPICS_);
  _STOPPICS_ := INI.ReadString('lang','_STOPPICS_',_STOPPICS_);
  _NEWTABCAPTION_ := INI.ReadString('lang','_NEWTABCAPTION_',_NEWTABCAPTION_);
  _COUNT_ := INI.ReadString('lang','_COUNT_',_COUNT_);
  _NAMEFORMAT_ := INI.ReadString('lang','_NAMEFORMAT_',_NAMEFORMAT_);
  _SAVEPATH_ :=  INI.ReadString('lang','_SAVEPATH_',_SAVEPATH_);
  _FILENAME_ :=  INI.ReadString('lang','_FILENAME_',_FILENAME_);
  _EXTENSION_ :=  INI.ReadString('lang','_EXTENSION_',_EXTENSION_);
  _INFO_ :=  INI.ReadString('lang','_INFO_',_INFO_);
  _TAGS_ :=  INI.ReadString('lang','_TAGS_',_TAGS_);
  _DOUBLES_ :=  INI.ReadString('lang','_DOUBLES_',_DOUBLES_);

  INI.Free;
end;

end.
