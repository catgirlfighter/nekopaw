unit rpVersionInfo; //версия 1.0 3/8/98 записана и проверена в Delphi 3.
(*Автор Rick Peterson, данный компонент распространяется свободно

и освобожден от платы за использование. В случае изменения
авторского кода просьба прислать измененный код. Сообщайте пожалуйста
обо всех найденных ошибках. Адрес для писем - rickpet@airmail.net. *)

interface

uses

  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  TypInfo;

type
{$M+}
  (* Видели директиву $M+??? Это заставляет Delphi включать в код RTTI-информацию для

  перечислимых типов. В основном допускает работу с перечислимыми типами как
  со строками с помощью GetEnumName *)
  TVersionType = (vtCompanyName, vtFileDescription, vtFileVersion,
    vtInternalName,
    vtLegalCopyright, vtLegalTradeMark, vtOriginalFileName,
    vtProductName, vtProductVersion, vtComments);
{$M-}

  TrpVersionInfo = class(TComponent)
    (* Данный компонент позволяет получать информацию о версии вашего приложения

    во время его выполенния *)
  private
    FVersionInfo: array[0..ord(high(TVersionType))] of string;
  protected
    function GetCompanyName: string;
    function GetFileDescription: string;
    function GetFileVersion: string;
    function GetInternalName: string;
    function GetLegalCopyright: string;
    function GetLegalTradeMark: string;
    function GetOriginalFileName: string;
    function GetProductName: string;
    function GetProductVersion: string;
    function GetComments: string;
    function GetVersionInfo(VersionType: TVersionType): string; virtual;
    procedure SetVersionInfo; virtual;
  public
    constructor Create(AOwner: TComponent); override;
  published
    (* Использовать это очень просто - Label1.Caption := VersionInfo1.FileVersion

    Примечание: Все свойства - только для чтения, поэтому они недоступны в
    Инспекторе Объектов *)
    property CompanyName: string read GetCompanyName;
    property FileDescription: string read GetFileDescription;
    property FileVersion: string read GetFileVersion;
    property InternalName: string read GetInternalName;
    property LegalCopyright: string read GetLegalCopyright;
    property LegalTradeMark: string read GetLegalTradeMark;
    property OriginalFileName: string read GetOriginalFileName;
    property ProductName: string read GetProductName;
    property ProductVersion: string read GetProductVersion;
    property Comments: string read GetComments;
  end;

procedure Register;

implementation

constructor TrpVersionInfo.Create(AOwner: TComponent);
begin

  inherited Create(AOwner);
  SetVersionInfo;
end;

function TrpVersionInfo.GetCompanyName: string;
begin

  result := GeTVersionInfo(vtCompanyName);
end;

function TrpVersionInfo.GetFileDescription: string;
begin

  result := GeTVersionInfo(vtFileDescription);
end;

function TrpVersionInfo.GetFileVersion: string;
begin

  result := GeTVersionInfo(vtFileVersion);
end;

function TrpVersionInfo.GetInternalName: string;
begin

  result := GeTVersionInfo(vtInternalName);
end;

function TrpVersionInfo.GetLegalCopyright: string;
begin

  result := GeTVersionInfo(vtLegalCopyright);
end;

function TrpVersionInfo.GetLegalTradeMark: string;
begin

  result := GeTVersionInfo(vtLegalTradeMark);
end;

function TrpVersionInfo.GetOriginalFileName: string;
begin
  result := GeTVersionInfo(vtOriginalFileName);
end;

function TrpVersionInfo.GetProductName: string;
begin
  result := GeTVersionInfo(vtProductName);
end;

function TrpVersionInfo.GetProductVersion: string;
begin
  result := GeTVersionInfo(vtProductVersion);
end;

function TrpVersionInfo.GetComments: string;
begin
  result := GeTVersionInfo(vtComments);
end;

function TrpVersionInfo.GeTVersionInfo(VersionType: TVersionType): string;
begin
  result := FVersionInfo[ord(VersionType)];
end;

procedure TrpVersionInfo.SeTVersionInfo;
var
  sAppName, sVersionType: string;
  iAppSize, iLenOfValue, i: Cardinal;
  pcBuf, pcValue: PWideChar;
begin
  sAppName := Application.ExeName;
  iAppSize := GetFileVersionInfoSize(PChar(sAppName), iAppSize);
  if iAppSize > 0 then
  begin
    pcBuf := AllocMem(iAppSize);
    GetFileVersionInfo(PChar(sAppName), 0, iAppSize, pcBuf);
    for i := 0 to Ord(High(TVersionType)) do
    begin
      sVersionType := GetEnumName(TypeInfo(TVersionType), i);
      sVersionType := Copy(sVersionType, 3, length(sVersionType));
      if VerQueryValue(pcBuf, PChar('StringFileInfo\040904E4\' +
        sVersionType), Pointer(pcValue), iLenOfValue) then
        FVersionInfo[i] := pcValue;
    end;
    FreeMem(pcBuf, iAppSize);
  end;
end;

procedure Register;
begin
  RegisterComponents('FreeWare', [TrpVersionInfo]);
end;

end.

