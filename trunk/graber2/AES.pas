(**************************************************)
(*                                                *)
(*     Advanced Encryption Standard (AES)         *)
(*     Interface Unit v1.0                        *)
(*                                                *)
(*                                                *)
(*     Copyright (c) 2002 Jorlen Young            *)
(*                                                *)
(*                                                *)
(*                                                *)
(*说明：                                          *)
(*                                                *)
(*   基于 ElASE.pas 单元封装                      *)
(*                                                *)
(*   这是一个 AES 加密算法的标准接口。            *)
(*   通过两个函数 EncryptString 和 DecryptString  *)
(*   可以轻松得对字符串进行加密。                 *)
(*                                                *)
(*   作者：杨泽晖      2004.12.03                 *)
(*                                                *)
(**************************************************)

{2012.02.02 fixed by catgirlfighter for UNICODE strings}

unit AES;

interface

uses
  SysUtils, Classes, Math, ElAES;

{function StrToHex(Value: AnsiString): AnsiString;
function HexToStr(Value: AnsiString): AnsiString;   }

function StreamToHex(f: TStream): String;
procedure HexToStream(s: string; f: TStream);

function EncryptString(Value: String; Key: String): String;
function DecryptString(Value: String; Key: String): String;

implementation

{function StrToHex(Value: AnsiString): AnsiString;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(Value) do
    Result := Result + IntToHex(Ord(Value[I]), 2);
end;

function HexToStr(Value: AnsiString): AnsiString;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(Value) do
  begin
    if ((I mod 2) = 1) then
      Result := Result + Chr(StrToInt('0x'+ Copy(Value, I, 2)));
  end;
end;     }

function HexN(S: Char): Byte;
begin
  Result := 0;
  case s of
    //'0': result := 0;
    '1': result := 1;
    '2': result := 2;
    '3': result := 3;
    '4': result := 4;
    '5': result := 5;
    '6': result := 6;
    '7': result := 7;
    '8': result := 8;
    '9': result := 9;
    'A': result := 10;
    'B': result := 11;
    'C': result := 12;
    'D': result := 13;
    'E': result := 14;
    'F': result := 15;
  end;
end;

function StreamToHex(f: TStream): String;
var
  i: integer;
  b: byte;
begin
  f.Position := 0;
  result := '';
  for i := 0 to f.Size-1 do
  begin
    f.ReadBuffer(b,1);
    result := result + IntToHex(b,2);
  end;
end;

procedure HexToStream(s: string; f: TStream);

var
  i: integer;
  n: byte;

begin
  s := UPPERCASE(s);
  for i := 1 to length(s) do
    if i mod 2 = 1 then
      n := HexN(s[i])*16
    else
    begin
      n := n + HexN(S[i]);
      f.WriteBuffer(n,1);
    end;
end;
                      {Value and Key length must be > 0}
function EncryptString(Value: String; Key: String): String;
var
  SS, DS: TStringStream;
  AESKey: TAESKey128;
begin
  Result := '';
  SS := TStringStream.Create(Value);
  DS   := TStringStream.Create('');
  try
    //DS.WriteBuffer(Size, SizeOf(Size)); WTF???
    FillChar(AESKey, SizeOf(AESKey), 0 );
    Move(PChar(Key)^, AESKey, Min( SizeOf(AESKey), SizeOf(Key[1]) * Length(Key)));
    EncryptAESStreamECB(SS, 0, AESKey, DS);
    Result := StreamToHex(DS);
  finally
    SS.Free;
    DS.Free;
  end;
end;
                      {Value and Key length must be > 0}
function DecryptString(Value: String; Key: String): String;
var
  SS: TStringStream;
  DS: TStringStream;
  AESKey: TAESKey128;
begin
  Result := '';
  SS := TStringStream.Create('');
  HexToStream(Value,ss);
  DS := TStringStream.Create('');
  try
    //SS.ReadBuffer(Size, SizeOf(Size)); WTF???
    FillChar(AESKey, SizeOf(AESKey), 0);
    Move(PChar(Key)^, AESKey, Min(SizeOf(AESKey), SizeOf(Key[1]) * Length(Key)));
    DecryptAESStreamECB(SS, 0 {SS.Size - SS.Position}, AESKey, DS);
    Result := DS.DataString;
  finally
    SS.Free;
    DS.Free;
  end;
end;

end.
