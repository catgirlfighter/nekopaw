(* ************************************************ *)
(* *)
(* Advanced Encryption Standard (AES) *)
(* Interface Unit v1.0 *)
(* *)
(* *)
(* Copyright (c) 2002 Jorlen Young *)
(* *)
(* *)
(* *)
(* 说明： *)
(* *)
(* 基于 ElASE.pas 单元封装 *)
(* *)
(* 这是一个 AES 加密算法的标准接口。 *)
(* 通过两个函数 EncryptString 和 DecryptString *)
(* 可以轻松得对字符串进行加密。 *)
(* *)
(* 作者：杨泽晖      2004.12.03 *)
(* *)
(* ************************************************ *)

{ 2012.02.02 fixed by catgirlfighter for UNICODE strings }

unit AES;

interface

uses
  SysUtils, Classes, Math, ElAES;

{ function StrToHex(Value: AnsiString): AnsiString;
  function HexToStr(Value: AnsiString): AnsiString; }

function StreamToHex(f: TStream): String;
procedure HexToStream(s: string; f: TStream);

function EncryptString(Value: String; Key: String): String;
function DecryptString(Value: String; Key: String): String;

implementation

{ function StrToHex(Value: AnsiString): AnsiString;
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
  end; }

function HexN(s: Char): Byte;
begin
  Result := 0;
  case s of
    // '0': result := 0;
    '1':
      Result := 1;
    '2':
      Result := 2;
    '3':
      Result := 3;
    '4':
      Result := 4;
    '5':
      Result := 5;
    '6':
      Result := 6;
    '7':
      Result := 7;
    '8':
      Result := 8;
    '9':
      Result := 9;
    'A':
      Result := 10;
    'B':
      Result := 11;
    'C':
      Result := 12;
    'D':
      Result := 13;
    'E':
      Result := 14;
    'F':
      Result := 15;
  end;
end;

function StreamToHex(f: TStream): String;
var
  i: integer;
  b: Byte;
begin
  f.Position := 0;
  Result := '';
  for i := 0 to f.Size - 1 do
  begin
    f.ReadBuffer(b, 1);
    Result := Result + IntToHex(b, 2);
  end;
end;

procedure HexToStream(s: string; f: TStream);

var
  i: integer;
  n: Byte;

begin
  s := UPPERCASE(s);
  for i := 1 to length(s) do
    if i mod 2 = 1 then
      n := HexN(s[i]) * 16
    else
    begin
      n := n + HexN(s[i]);
      f.WriteBuffer(n, 1);
    end;
end;

{ Value and Key length must be > 0 }
function EncryptString(Value: String; Key: String): String;
var
  SS, DS: TStringStream;
  AESKey: TAESKey128;
begin
  Result := '';
  SS := TStringStream.Create(Value);
  DS := TStringStream.Create('');
  try
    // DS.WriteBuffer(Size, SizeOf(Size)); WTF???
    FillChar(AESKey, SizeOf(AESKey), 0);
    Move(PChar(Key)^, AESKey, Min(SizeOf(AESKey),
      SizeOf(Key[1]) * length(Key)));
    EncryptAESStreamECB(SS, 0, AESKey, DS);
    Result := StreamToHex(DS);
  finally
    SS.Free;
    DS.Free;
  end;
end;

{ Value and Key length must be > 0 }
function DecryptString(Value: String; Key: String): String;
var
  SS: TStringStream;
  DS: TStringStream;
  AESKey: TAESKey128;
begin
  Result := '';
  SS := TStringStream.Create('');
  HexToStream(Value, SS);
  DS := TStringStream.Create('');
  try
    // SS.ReadBuffer(Size, SizeOf(Size)); WTF???
    FillChar(AESKey, SizeOf(AESKey), 0);
    Move(PChar(Key)^, AESKey, Min(SizeOf(AESKey),
      SizeOf(Key[1]) * length(Key)));
    DecryptAESStreamECB(SS, 0 { SS.Size - SS.Position } , AESKey, DS);
    Result := DS.DataString;
  finally
    SS.Free;
    DS.Free;
  end;
end;

end.
