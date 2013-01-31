unit MyINIFile;

interface

uses SysUtils,Windows,RTLConsts,INIFiles;

type
  TINIFile = class(INIFiles.TIniFile)
  private
    FEncoding: TEncoding;
  public
    property Encoding: TEncoding read FEncoding write FEncoding;
    function ReadString(const Section, Ident, Default: WideString): WideString; reintroduce;
    procedure WriteString(const Section, Ident, Value: WideString); reintroduce;
  end;

implementation

function TINIFile.ReadString(const Section, Ident, Default: WideString): WideString;
var
  Buffer: array[0..2047] of WideChar;
begin
  SetString(Result, Buffer, GetPrivateProfileStringW(PWideChar(Section),
    PWideChar(Ident), PWideChar(Default), Buffer, Length(Buffer), PWideChar(FileName)));
end;

procedure TINIFile.WriteString(const Section, Ident, Value: WideString);
begin
  if not WritePrivateProfileStringW(PWideChar(Section), PWideChar(Ident),
                                   PWideChar(Value), PWideChar(FileName)) then
    raise EIniFileException.CreateResFmt(@SIniFileWriteError, [FileName]);
end;

end.
