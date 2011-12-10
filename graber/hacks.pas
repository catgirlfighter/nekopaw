unit hacks;

interface

uses Windows, Messages, SysUtils, Classes, ComCtrls, CheckLst, StdCtrls,
  clipbrd, AdvGrid, unit_win7TaskBar, ShellAPI, Controls, JvTypes, JvDriveCtrls,
  Forms, TB2Item, SpTBXItem;

type

  TVerticalScroll =  procedure (var Msg: TWMVScroll) of object;

  TAdvStringGrid = class(AdvGrid.TAdvStringGrid)
    private
      FIsAuto: Boolean;
      FOnVScroll: TVerticalScroll;
      procedure WMVScroll(var Msg: TWMVScroll); message WM_VSCROLL;
    public
      procedure AutoSetRow(AValue: Integer);
      constructor Create(AOwner: TComponent); override;
      procedure SetColumnReadOnly(c: integer; n: Boolean);
    published
      property IsAutoSelect: Boolean read FIsAuto;
      property OnVerticalScroll: TVerticalScroll read FOnVScroll write FOnVScroll;
  end;

  TCheckListBox = class(CheckLst.TCheckListBox)
    public
      procedure CheckInverse;
  end;

  TPreventNotifyEvent = procedure(Sender: TObject; var Text: string; var Accept: Boolean) of object;

  TMemo = class(StdCtrls.TMemo)
   private
{     FPreventCut: Boolean;
     FPreventCopy: Boolean;
     FPreventPaste: Boolean;
     FPreventClear: Boolean;   }

{     FOnCut: TPreventNotifyEvent;
     FOnCopy: TPreventNotifyEvent;   }
     FOnPaste: TPreventNotifyEvent;
{     FOnClear: TPreventNotifyEvent;  }

{     procedure WMCut(var Message: TWMCUT); message WM_CUT;
     procedure WMCopy(var Message: TWMCOPY); message WM_COPY;  }
     procedure WMPaste(var Message: TWMPASTE); message WM_PASTE;
{     procedure WMClear(var Message: TWMCLEAR); message WM_CLEAR;  }
   protected
     { Protected declarations }
   public
     { Public declarations }
   published
{     property PreventCut: Boolean read FPreventCut write FPreventCut default False;
     property PreventCopy: Boolean read FPreventCopy write FPreventCopy default False;
     property PreventPaste: Boolean read FPreventPaste write FPreventPaste default False;
     property PreventClear: Boolean read FPreventClear write FPreventClear default False;   }
{     property OnCut: TPreventNotifyEvent read FOnCut write FOnCut;
     property OnCopy: TPreventNotifyEvent read FOnCopy write FOnCopy;    }
     property OnPaste: TPreventNotifyEvent read FOnPaste write FOnPaste;
{     property OnClear: TPreventNotifyEvent read FOnClear write FOnClear;  }
  end;

  TProgressBar = class(ComCtrls.TProgressBar)
    private
      FMainBar: Boolean;
    public
      procedure SetMainBar(AValue: Boolean);
      procedure SetStyle(Value: TProgressBarStyle);
      procedure SetPosition(Value: Integer);
      procedure SetState(Value: TProgressBarState);
      procedure UpdateStates;
    published
      property MainBar: Boolean read FMainBar write SetMainBar;
  end;

implementation

uses Unit1;

//TMemo

{ procedure TMemo.WMCut(var Message: TWMCUT);
 var
   Accept: Boolean;
   Handle: THandle;
   HandlePtr: Pointer;
   CText: string;
 begin
   if FPreventCut then
     Exit;
   if SelLength = 0 then
     Exit;
   CText := Copy(Text, SelStart + 1, SelLength);
   try
     OpenClipBoard(Self.Handle);
     Accept := True;
     if Assigned(FOnCut) then
       FOnCut(Self, CText, Accept);
     if not Accept then
       Exit;
     Handle := GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE, Length(CText) + 1);
     if Handle = 0 then
       Exit;
     HandlePtr := GlobalLock(Handle);
     Move((PChar(CText))^, HandlePtr^, Length(CText));
     SetClipboardData(CF_TEXT, Handle);
     GlobalUnlock(Handle);
     CText := Text;
     Delete(CText, SelStart + 1, SelLength);
     Text := CText;
   finally
     CloseClipBoard;
   end;
 end;


 procedure TMemo.WMCopy(var Message: TWMCOPY);
 var
   Accept: Boolean;
   Handle: THandle;
   HandlePtr: Pointer;
   CText: string;
 begin
   if FPreventCopy then
     Exit;
   if SelLength = 0 then
     Exit;
   CText := Copy(Text, SelStart + 1, SelLength);
   try
     OpenClipBoard(Self.Handle);
     Accept := True;
     if Assigned(FOnCopy) then
       FOnCopy(Self, CText, Accept);
     if not Accept then
       Exit;
     Handle := GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE, Length(CText) + 1);
     if Handle = 0 then
       Exit;
     HandlePtr := GlobalLock(Handle);
     Move((PChar(CText))^, HandlePtr^, Length(CText));
     SetClipboardData(CF_TEXT, Handle);
     GlobalUnlock(Handle);
   finally
     CloseClipBoard;
   end;
 end;                                  }


 procedure TMemo.WMPaste(var Message: TWMPASTE);
 var
   Accept: Boolean;
   CText: string;
   LText: string;
 begin
    CText := clipboard.AsText;
    if CText = '' then
      Exit;

    Accept := True;

    LText := Ctext;

    if Assigned(FOnPaste) then
      FOnPaste(Self, CText, Accept);
    if not Accept then
      Exit
    else if CText <> LText then
      SelText := CText
    else
      inherited;
 end;


{ procedure TMemo.WMClear(var Message: TWMCLEAR);
 var
   Accept: Boolean;
   CText: string;
 begin
   if FPreventClear then
     Exit;
   if SelStart = 0 then
     Exit;
   CText  := Copy(Text, SelStart + 1, SelLength);
   Accept := True;
   if Assigned(FOnClear) then
     FOnClear(Self, CText, Accept);
   if not Accept then
     Exit;
   CText := Text;
   Delete(CText, SelStart + 1, SelLength);
   Text := CText;
 end;         }

//TProgressBar

procedure TProgressBar.SetMainBar(AValue: Boolean);
begin
  FMainBar := AValue;
  SetPosition(Position);
  SetState(State);
end;

procedure TProgressBar.SetStyle(Value: TProgressBarStyle);
const
  P: array[TProgressBarState] of TTaskBarProgressState = (tbpsNormal,tbpsError,tbpsPaused);

begin
  Style := Value;
  case Value of
    pbstNormal:
    begin
      if Position = 0 then
        SetTaskbarProgressState(tbpsNone)
      else
        SetTaskbarProgressState(P[State]);
    end;
    pbstMarquee:
    begin
      SetTaskBarProgressValue(0,100);
      SetTaskbarProgressState(tbpsIndeterminate);
    end;
  end;
end;

procedure TProgressBar.SetPosition(Value: Integer);
begin
  if Position = Value then
    Exit
  else
    Position := Value;
  if FMainBar then
  begin
    if (WIN32MajorVersion >= 6) then
    begin
      SetTaskbarProgressValue(Value, Max);
      if Value = 0 then
//        SetTaskBarProgressValue(0,100);
        SetTaskbarProgressState(tbpsNone);
    end;
  end;
end;

procedure TProgressBar.SetState(Value: TProgressBarState);
//TProgressBarState = (pbsNormal, pbsError, pbsPaused);
const
  P: array[TProgressBarState] of TTaskBarProgressState = (tbpsNormal,tbpsError,tbpsPaused);

//(tbpsNone, tbpsIndeterminate, tbpsNormal, tbpsError, tbpsPaused);
begin
  State := Value;
  if FMainBar then
    if (WIN32MajorVersion >= 6) then
      if (Value = pbsNormal) and (Style = pbstMarquee) then
        SetTaskbarProgressState(tbpsIndeterminate)
      else
        SetTaskbarProgressState(P[State]);
end;

procedure TProgressBar.UpdateStates;
const
  P: array[TProgressBarState] of TTaskBarProgressState = (tbpsNormal,tbpsError,tbpsPaused);
begin
  if FMainBar then
    if (WIN32MajorVersion >= 6) then
      if (Style = pbstMarquee) then
      begin
        SetTaskBarProgressValue(0,100);
        SetTaskbarProgressState(tbpsIndeterminate);
      end
      else
        if Position <> 0 then
        begin
        SetTaskBarProgressValue(Position,Max);
        SetTaskbarProgressState(P[State]);
      end;
{      else
        SetTaskbarProgressState(tbpsNone);}
end;

//TAdvStringGrid

procedure TAdvStringGrid.WMVScroll(var Msg: TWMVScroll);
begin
  inherited;
  if Assigned(FOnVScroll) then
    FOnVScroll(Msg);
end;

procedure TAdvStringGrid.AutoSetRow(AValue: Integer);
begin
  FIsAuto := true;
  if Row <>AValue then SetRowEx(AValue);
  FIsAuto := false;
end;

constructor TAdvStringGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOnVScroll := nil;
  FIsAuto := false;
end;

procedure TAdvStringGrid.SetColumnReadOnly(c: integer; n: Boolean);
var
  i: integer;
begin
  for i := FixedRows to RowCount - 1 do
    ReadOnly[c,i] := n;
end;

//TCheckListBox

procedure TCheckListBox.CheckInverse;
var
  I: Integer;
begin
  for I := 0 to Items.Count - 1 do
    Checked[i] := not Checked[i];
end;

initialization

  if (Win32MajorVersion >= 6) and (Win32MinorVersion > 0) then
    InitializeTaskbarAPI;

end.
