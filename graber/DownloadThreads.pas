unit DownloadThreads;

interface

uses Windows, SysUtils, Classes, Controls, Contnrs, idComponent, idHTTP, MyXMLParser,
      CCR.EXIF, IdHTTPHeaderInfo, common, dateutils;

{const

  //Thread tasks
  TT_FINISH = 0;
  TT_GETURL = 1;
  TT_DOWNLOAD = 2;    }
type

{  TDWNLDStatus = (dsNone,dsOk,dsMiss,dsSkip,dsError,dsGet,dsDownload);

  tstats = record
    ok,
    err,
    miss,
    skip,
    del,
    ren,
    cmpl,
    sel: LONGWORD;
  end;  }

{  TTag = record
    Name: String;
    Count: Integer;
  end;

  TTags = array of TTag; }

  PRec = ^DRec;

  DRec = record
    title: string;
    size: int64;
    work: int64;
    chck: boolean;
    pageurl: string;
    URL: string;
    tags: TArrayOfWord;
    params: string;
    category: string;
    wtime: TDateTIme;
    postdate: string;
    preview: string;
  end;

  TThreadQueue = class(TObjectQueue)
  private
    FBusy: Boolean;
    FDelayPeriod: integer;
    FCanStart: Boolean;
    FTimeStart: TDateTime;
    FTimingReseted: boolean;
  public
    function AddThread(T: TThread): Boolean;
    procedure Proc(NoDelay: Boolean);
    constructor Create;
    procedure Wait;
    procedure ResetTiming;
    property DelayPeriod: Integer read FDelayPeriod write FDelayPeriod;
    property IsBusy: Boolean read FBusy;
  end;

implementation

//TThreadQueue

function TThreadQueue.AddThread(T: TThread): Boolean;
begin
  if FCanStart then
  begin
    Result := True;
    FCanStart := false;
  end else
  begin
    Result := false;
    Push(T);
  end;
end;

procedure TThreadQueue.Proc(NoDelay: Boolean);
begin
  FTimeStart := Date+Time;
  if FBusy then
    Exit;
  if Count > 0 then
    TThread(Pop).Resume
  else
    FCanStart := true;
end;

procedure TThreadQueue.ResetTiming;
begin
  FTimeStart := Date+Time;
  FTimingReseted := true;
end;

procedure TThreadQueue.Wait;
begin
  repeat
    FTimingReseted := false;
    if MillisecondsBetween(FTimeStart,Date+Time) < DelayPeriod then
    begin
      FBusy := True;
      _Delay(DelayPeriod-MillisecondsBetween(FTimeStart,Date+Time));
      FBusy := False;
    end;
  until not FTimingReseted;
end;

constructor TThreadQueue.Create;
begin
  inherited Create;
  FCanStart := True;
  FBusy := false;
  FTimeStart := 0;
  FTimingReseted := false;
end;

(*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*)

//TPicturesList



//TGraber

end.
