unit ThreadUtils;

interface

uses SysUtils, Classes, Windows;

type
  tThreadQueue = class(tThreadList)
  protected
    procedure CallNext(l: TList);
  public
    // constructor Create;
    function Enter: THandle;
    // you can use handle to make Timers that can be dismissed from queue
    procedure Leave;
    function Count: Integer;
    destructor Destroy; override;
    procedure Dismiss(Index: Integer = -1);
  end;

implementation

procedure tThreadQueue.Leave;
var
  l: TList;
  h: THandle;
begin
  l := LockList;
  try
    if l.Count > 0 then
    begin
      h := THandle(l[0]);
      CloseHandle(h); // Dismiss
      l.Delete(0);
      CallNext(l);
    end;
  finally
    UnlockList;
  end;
end;

procedure tThreadQueue.CallNext(l: TList);
var
  h: THandle;
begin
  if l.Count > 0 then
  begin
    h := THandle(l[0]);
    SetEvent(h); // NEXT
  end;
end;

function tThreadQueue.Enter: THandle;
var
  h: THandle;
  l: TList;
  B: Boolean;
begin
  h := CreateEvent(nil, True, False, nil);
  l := LockList;
  try
    B := l.Add(Pointer(h)) = 0;
  finally
    UnlockList;
  end;

  // if thread not first in list then wait
  if not B then
    B := WaitForSingleObject(h, INFINITE) = WAIT_OBJECT_0;
  //WAIT_OBJECT_0 means thread got his turn from previous, alse something bad happened (handle closed)

  if not B then
  begin
    Result := 0;
    l := LockList;
    try
      CallNext(l);
    finally
      UnlockList;
    end;
  end
  else
  begin
    ResetEvent(h);
    Result := h;
  end;
end;

function tThreadQueue.Count: Integer; // better to avoid an use of it
var
  l: TList;
begin
  l := LockList;
  try
    Result := l.Count;
  finally
    UnlockList;
  end;
end;

destructor tThreadQueue.Destroy;
begin
  Dismiss;
  inherited;
end;

procedure tThreadQueue.Dismiss(Index: Integer = -1); //Dismiss all handles or chosen one
var
  i: Integer;
  h: THandle;
  l: TList;
begin
  if index = -1 then
  begin

    l := LockList;
    try

      for i := 0 to l.Count - 1 do
      begin
        h := THandle(l[i]);
        CloseHandle(h);
      end;

      l.Clear;
      // Counter := 0;

    finally
      UnlockList;
    end;
  end
  else
  begin
    l := LockList;
    try
      h := THandle(l[index]);
      CloseHandle(h);
      // it should singal to thread that it dismissed, and thread should leave control to next one
      l.Delete(index);
      // threads should not opperate with their position in list after Unlock
    finally
      UnlockList;
    end;

  end;
end;

end.
