///////////////////////////////////////////////////////////////////////////////
// LameXP - Audio Encoder Front-End
// Copyright (C) 2004-2010 LoRd_MuldeR <MuldeR2@GMX.de>
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
// http://www.gnu.org/licenses/gpl-2.0.txt
///////////////////////////////////////////////////////////////////////////////

unit Win7Taskbar;

//////////////////////////////////////////////////////////////////////////////
interface
//////////////////////////////////////////////////////////////////////////////

uses
  Forms, Types, Windows, SysUtils, ComObj, Controls, Graphics;

const
  TASKBAR_CID: TGUID = '{56FDF344-FD6D-11d0-958A-006097C9A090}';

type
  TTaskBarProgressState = (tbpsNone, tbpsIndeterminate, tbpsNormal, tbpsError, tbpsPaused);

  twin7taskbar = class(tobject)
  private
    FState: TTaskBarProgressState;
    FMax,FCurrent: UInt64;
    FTag: Integer;
    procedure SetState(AValue: TTaskBarProgressState);
    procedure SetMax(AValue: UInt64);
    procedure SetCurrent(AValue: UInt64);
  public
    property State: TTaskBarProgressState read FState write SetState;
    property Max: UInt64 read FMax write SetMax;
    property Current: UInt64 read FCurrent write SetCurrent;
    property Tag: Integer read FTag write FTag;
    procedure SetProgress(ACurrent,AMax: UInt64);
    constructor Create;
  end;

function InitializeTaskbarAPI: Boolean;
function SetTaskbarProgressState(const AState: TTaskBarProgressState): Boolean;
function SetTaskbarProgressValue(const ACurrent:UInt64; const AMax: UInt64): Boolean;
function SetTaskbarOverlayIcon(const AIcon: THandle; const ADescription: String): Boolean; overload;
function SetTaskbarOverlayIcon(const AIcon: TIcon; const ADescription: String): Boolean; overload;
function SetTaskbarOverlayIcon(const AList: TImageList; const IconIndex: Integer; const ADescription: String): Boolean; overload;

var
  w7taskbar: twin7taskbar;

//////////////////////////////////////////////////////////////////////////////
implementation
//////////////////////////////////////////////////////////////////////////////

function GetWineAvail: boolean;
var H: cardinal;
begin
  Result := False;
  H := LoadLibrary('ntdll.dll');
  if H > 0 then
  begin
  Result := Assigned(GetProcAddress(H, 'wine_get_version'));
  FreeLibrary(H);
  end;
end;


const
  TBPF_NOPROGRESS = 0;
  TBPF_INDETERMINATE = 1;
  TBPF_NORMAL = 2;
  TBPF_ERROR = 4;
  TBPF_PAUSED = 8;


type
  ITaskBarList3 = interface(IUnknown)
  ['{EA1AFB91-9E28-4B86-90E9-9E9F8A5EEFAF}']
    function HrInit(): HRESULT; stdcall;
    function AddTab(hwnd: THandle): HRESULT; stdcall;
    function DeleteTab(hwnd: THandle): HRESULT; stdcall;
    function ActivateTab(hwnd: THandle): HRESULT; stdcall;
    function SetActiveAlt(hwnd: THandle): HRESULT; stdcall;
    function MarkFullscreenWindow(hwnd: THandle; fFullscreen: Boolean): HRESULT; stdcall;
    function SetProgressValue(hwnd: THandle; ullCompleted: UInt64; ullTotal: UInt64): HRESULT; stdcall;
    function SetProgressState(hwnd: THandle; tbpFlags: Cardinal): HRESULT; stdcall;
    function RegisterTab(hwnd: THandle; hwndMDI: THandle): HRESULT; stdcall;
    function UnregisterTab(hwndTab: THandle): HRESULT; stdcall;
    function SetTabOrder(hwndTab: THandle; hwndInsertBefore: THandle): HRESULT; stdcall;
    function SetTabActive(hwndTab: THandle; hwndMDI: THandle; tbatFlags: Cardinal): HRESULT; stdcall;
    function ThumbBarAddButtons(hwnd: THandle; cButtons: Cardinal; pButtons: Pointer): HRESULT; stdcall;
    function ThumbBarUpdateButtons(hwnd: THandle; cButtons: Cardinal; pButtons: Pointer): HRESULT; stdcall;
    function ThumbBarSetImageList(hwnd: THandle; himl: THandle): HRESULT; stdcall;
    function SetOverlayIcon(hwnd: THandle; hIcon: THandle; pszDescription: PChar): HRESULT; stdcall;
    function SetThumbnailTooltip(hwnd: THandle; pszDescription: PChar): HRESULT; stdcall;
    function SetThumbnailClip(hwnd: THandle; var prcClip: TRect): HRESULT; stdcall;
  end;

//////////////////////////////////////////////////////////////////////////////

var
  GlobalTaskBarInterface: ITaskBarList3;


function InitializeTaskbarAPI: Boolean;
var
  Unknown: IInterface;
  Temp: ITaskBarList3;
begin
  if Assigned(GlobalTaskBarInterface) then
  begin
    Result := True;
    Exit;
  end;


  try
    Unknown := CreateComObject(TASKBAR_CID);
    if Assigned(Unknown) then
    begin
      Temp := Unknown as ITaskBarList3;
      if Temp.HrInit() = S_OK then
      begin
        GlobalTaskBarInterface := Temp;
      end;
    end;
  except
    GlobalTaskBarInterface := nil;
  end;


  Result := Assigned(GlobalTaskBarInterface);
end;


function CheckAPI:Boolean;
begin
  Result := Assigned(GlobalTaskBarInterface);
end;


//////////////////////////////////////////////////////////////////////////////


function SetTaskbarProgressState(const AState: TTaskBarProgressState): Boolean;
var
  Flag: Cardinal;
begin
  Result := False;


  if CheckAPI then
  begin
    case AState of
      tbpsIndeterminate: Flag := TBPF_INDETERMINATE;
      tbpsNormal: Flag := TBPF_NORMAL;
      tbpsError: Flag := TBPF_ERROR;
      tbpsPaused: Flag := TBPF_PAUSED;
    else
      Flag := TBPF_NOPROGRESS;
    end;
    Result := GlobalTaskBarInterface.SetProgressState(Application.Handle, Flag) = S_OK;
  end;
end;


function SetTaskbarProgressValue(const ACurrent:UInt64; const AMax: UInt64): Boolean;
begin
  Result := False;


  if CheckAPI then
  begin
    Result := GlobalTaskBarInterface.SetProgressValue(Application.Handle, ACurrent, AMax) = S_OK;
  end;
end;


function SetTaskbarOverlayIcon(const AIcon: THandle; const ADescription: String): Boolean;
begin
  Result := False;


  if CheckAPI then
  begin
    Result := GlobalTaskBarInterface.SetOverlayIcon(Application.Handle, AIcon, PChar(ADescription)) = S_OK;
  end;
end;


function SetTaskbarOverlayIcon(const AIcon: TIcon; const ADescription: String): Boolean;
begin
  Result := False;


  if CheckAPI then
  begin
    if Assigned(AIcon) then
    begin
      Result := SetTaskbarOverlayIcon(AIcon.Handle, ADescription);
    end else begin
      Result := SetTaskbarOverlayIcon(THandle(nil), ADescription);
    end;
  end;
end;


function SetTaskbarOverlayIcon(const AList: TImageList; const IconIndex: Integer; const ADescription: String): Boolean;
var
  Temp: TIcon;
begin
  Result := False;


  if CheckAPI then
  begin
    if (IconIndex >= 0) and (IconIndex < AList.Count) then
    begin
      Temp := TIcon.Create;
      try
        AList.GetIcon(IconIndex, Temp);
        Result := SetTaskbarOverlayIcon(Temp, ADescription);
      finally
        Temp.Free;
      end;
    end else begin
      Result := SetTaskbarOverlayIcon(nil, ADescription);
    end;
  end;
end;

//////////////////////////////////////////////////////////////////////////////

procedure twin7taskbar.SetState(AValue: TTaskBarProgressState);
begin
  FState := AValue;
  SetTaskbarProgressState(FState);
  
{  if FState <> tbpsNone then
    SetProgress(FCurrent,FMax);    }
end;

procedure twin7taskbar.SetMax(AValue: UInt64);
begin
  FMax := AValue;
  if State <> tbpsNone then
    SetTaskbarProgressValue(FCurrent, FMax);
end;

procedure twin7taskbar.SetCurrent(AValue: UInt64);
begin
  FCurrent := AValue;
  if State <> tbpsNone then
    SetTaskbarProgressValue(FCurrent, FMax);
end;

procedure twin7taskbar.SetProgress(ACurrent,AMax: UInt64);
begin
  FMax := AMax;
  FCurrent := ACurrent;
  if State <> tbpsNone then
    SetTaskbarProgressValue(FCurrent, FMax);
end;

constructor twin7taskbar.Create;
begin
  FCurrent := 0;
  FMax := 100;
  FState := tbpsNone;
end;

//////////////////////////////////////////////////////////////////////////////

initialization

  GlobalTaskBarInterface := nil;

  if (Win32MajorVersion >= 6) and (Win32MinorVersion > 0)
  and InitializeTaskbarAPI then
    w7taskbar := twin7taskbar.Create
  else
    w7taskbar := nil;

finalization

  GlobalTaskBarInterface := nil;

  if assigned(w7taskbar) then
    w7taskbar.Free;

//////////////////////////////////////////////////////////////////////////////

end.

