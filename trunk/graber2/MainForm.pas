unit MainForm;

interface

uses
  {base}
  Windows, Messages, SysUtils, Variants, Classes,
  Graphics, Controls, Forms,
  Dialogs, DB, ActnList, ExtCtrls, ImgList, rpVersionInfo,
  AppEvnts, Types, ShellAPI, Math,
  StrUtils, {IdBaseComponent, IdIntercept, IdInterceptThrottler,}
  {devex}
  cxPC, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxPCdxBarPopupMenu, cxEdit,
  cxContainer, dxBar, cxClasses, dxDockControl, cxLabel, cxTextEdit, cxMemo,
  cxCheckListBox, cxInplaceContainer, cxVGrid, dxNavBarCollns, dxNavBarBase,
  dxNavBar, dxDockPanel, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, dxSkinsdxNavBarPainter, dxSkinsdxDockControlPainter,
  dxSkinsdxBarPainter, dxSkinsForm, cxMaskEdit, cxButtonEdit,
  cxGridCustomTableView,
  {graber2}
  common, OpBase, graberU, MyHTTP, UPDUnit, Balloon, Vcl.Menus;

{ skins }
{ dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel,
  dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue,
  dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus,
  dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008,
  dxSkinTheAsphaltWorld, dxSkinsDefaultPainters, dxSkinValentine, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinXmas2008Blue, dxSkinsForm, dxSkinscxPCPainter,
  dxSkinsdxNavBarPainter, dxSkinsdxDockControlPainter, dxSkinsdxBarPainter }

type

  TLogRec = record
    Frame,Data: Pointer;
  end;

  pLogRec = ^tLogRec;

  TMycxTabSheet = class(TcxTabSheet)
  private
    FTimer: TTimer;
    FStartFrame, FEndFrame, FCurrentFrame: Integer;
    FLoop: Boolean;
    FRName: String;
    procedure OnTimer(Sender: TObject);
  public
    MainFrame: TFrame;
    SecondFrame: TFrame;
    property RName: String read FRName write FRName;
    procedure SetIcon(AStartFrame: Integer; AEndFrame: Integer = -1;
      Loop: Boolean = false);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TcxPageControl = class(cxPC.TcxPageControl);

  Tmf = class(TForm)
    ds: TdxDockSite;
    DockManager: TdxDockingManager;
    BarManager: TdxBarManager;
    bmbMain: TdxBar;
    dpTable: TdxDockPanel;
    dxLayoutDockSite2: TdxLayoutDockSite;
    dpTags: TdxDockPanel;
    dpCurTags: TdxDockPanel;
    dsTable: TdxLayoutDockSite;
    dsTags: TdxTabContainerDockSite;
    dpLog: TdxDockPanel;
    dxLayoutDockSite4: TdxLayoutDockSite;
    dpErrors: TdxDockPanel;
    dsLogs: TdxTabContainerDockSite;
    pcTables: TcxPageControl;
    bbStartList: TdxBarButton;
    bbStartPics: TdxBarButton;
    bbSettings: TdxBarButton;
    bbNew: TdxBarButton;
    mLog: TcxMemo;
    mErrors: TcxMemo;
    ApplicationEvents1: TApplicationEvents;
    nvCur: TdxNavBar;
    nbgCurMain: TdxNavBarGroup;
    nbgCurTags: TdxNavBarGroup;
    nbgCurMainControl: TdxNavBarGroupControl;
    vgCurMain: TcxVerticalGrid;
    nbgCurTagsControl: TdxNavBarGroupControl;
    chlbTags: TcxCheckListBox;
    vINFO: TrpVersionInfo;
    lUPD: TcxLabel;
    nvTags: TdxNavBar;
    nbgTagsMain: TdxNavBarGroup;
    nbgTagsTags: TdxNavBarGroup;
    dxNavBarGroupControl1: TdxNavBarGroupControl;
    vgTagsMain: TcxVerticalGrid;
    dxNavBarGroupControl2: TdxNavBarGroupControl;
    chlbFullTags: TcxCheckListBox;
    MainBarControl: TdxBarDockControl;
    dxSkinController: TdxSkinController;
    chlbtagsfilter: TcxButtonEdit;
    bbAdvanced: TdxBarSubItem;
    bbDeleteMD5Doubles: TdxBarButton;
    fLogPopup: TPopupMenu;
    COPY1: TMenuItem;
    GOTO1: TMenuItem;
    SELECTALL1: TMenuItem;
    CLEAR1: TMenuItem;
    bbSignalTimer: TdxBarButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    { procedure gLevel2GetGridView(Sender: TcxGridLevel;
      AMasterRecord: TcxCustomGridRecord; var AGridView: TcxCustomGridView); }
    procedure bbSettingsClick(Sender: TObject);
    procedure bbNewClick(Sender: TObject);
    procedure pcTablesChange(Sender: TObject);
    procedure bbStartListClick(Sender: TObject);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure bbStartPicsClick(Sender: TObject);
    procedure testoClick(Sender: TObject);
    procedure pcTablesCanCloseEx(Sender: TObject; ATabIndex: Integer;
      var ACanClose: Boolean);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure chlbFullTagsClickCheck(Sender: TObject; AIndex: Integer;
      APrevState, ANewState: TcxCheckBoxState);
    procedure bbDeleteMD5DoublesClick(Sender: TObject);
    procedure ApplicationEvents1Minimize(Sender: TObject);
    procedure ApplicationEvents1Deactivate(Sender: TObject);
    procedure COPY1Click(Sender: TObject);
    procedure fLogPopupPopup(Sender: TObject);
    procedure GOTO1Click(Sender: TObject);
    procedure CLEAR1Click(Sender: TObject);
    procedure bbSignalTimerClick(Sender: TObject);

  private
    mFrame: TFrame;
    FOldCaption: String;
    fErrLogObj: array of pLogRec;
    // tvMain: TmycxGridTableView;
  protected
    // procedure EXPANDROW(var Msg: TMessage); message CM_EXPROW;
    procedure WMActivate(var Msg: TWMActivate); message WM_ACTIVATE;
    procedure NEWLIST(var Msg: TMessage); message CM_NEWLIST;
    procedure APPLYNEWLIST(var Msg: TMessage); message CM_APPLYNEWLIST;
    procedure CANCELNEWLIST(var Msg: TMessage); message CM_CANCELNEWLIST;
    procedure SHOWSETTINGS(var Msg: TMessage); message CM_SHOWSETTINGS;
    procedure CANCELSETTINGS(var Msg: TMessage); message CM_CANCELSETTINGS;
    procedure APPLYSETTINGS(var Msg: TMessage); message CM_APPLYSETTINGS;
    procedure STARTJOB(var Msg: TMessage); message CM_STARTJOB;
    procedure ENDJOB(var Msg: TMessage); message CM_ENDJOB;
    procedure UPDATECHECK(var Msg: TMessage); message CM_UPDATE;
    procedure LANGUAGECHANGED(var Msg: TMessage); message CM_LANGUAGECHANGED;
    procedure WHATSNEW(var Msg: TMessage); message CM_WHATSNEW;
    procedure STYLECHANGED(var Msg: TMessage); message CM_STYLECHANGED;
    procedure WREFRESHPIC(var Msg: TMessage); message CM_REFRESHPIC;
    procedure WREFRESHRESINFO(var Msg: TMessage); message CM_REFRESHRESINFO;
    procedure MENUSTYLECHANGED(var Msg: TMessage); message CM_MENUSTYLECHANGED;
    procedure JOBPROGRESS(var Msg: TMessage); message CM_JOBPROGRESS;
    procedure LOGMODECHANGED(var Msg: TMessage); message CM_LOGMODECHANGED;
    // procedure dxTabClose(Sender: TdxCustomDockControl);
    // procedure APPLYEDITLIST(var Msg: TMessage); message CM_APPLYNEWLIST;
  private
    TabList: TList;
    dsFirstShow: Boolean;
    SttPanel: TMycxTabSheet;
    // FCookie: TMyCookieList;
    FCurPic: TTPicture;
    FBalloon: TBalloon;
    { Private declarations }
  public
    // OldState: TmfState;
    { procedure tvMainRecordExpandable(MasterDataRow: TcxGridMasterDataRow;
      var Expandable: Boolean); }
    function CreateTab(pc: TcxPageControl; Enc: Boolean = true): TMycxTabSheet;
    procedure ShowDs;
    procedure HideDs;
    procedure CloseTab(t: TcxTabSheet);
    // procedure OnTabClose(ASender: TObject; ATabSheet: TcxTabSheet);
    procedure ShowPanels;
    procedure OnError(Sender: TObject; Msg: String; Data: Pointer);
    procedure OnLog(Sender: TObject; Msg: String; Data: Pointer);
    procedure Setlang;
    procedure PicInfo(Sender: TObject; a: TTPicture);
    procedure CheckUpdates;
    procedure StartUpdate;
    procedure ChangeResInfo;
    procedure RefreshResInfo(Sender: TObject);
    function CloseAllTabs: Boolean;
    procedure RefreshTags(Sender: TObject; t: TPictureTagLinkList);
    procedure DoPicInfo(Sender: TObject; a: TTPicture);
    procedure DoRefreshResInfo(Sender: TObject);
    procedure ChangeTags;
    procedure updateTab;
    procedure AddTag(name: string; add: Boolean);
    procedure ShowBalloon;
    procedure OnBalloonExitTimer(Sender: TObject);
    procedure HideBalloon;

    { Public declarations }
  end;

var
  mf: Tmf;
  hWndTip: THandle;

implementation

uses StartFrame, NewListFrame, LangString, SettingsFrame, GridFrame, utils,
  AboutForm, win7taskbar, LoginForm, Newsv2Form, fontScale;
{$R *.dfm}

procedure TMycxTabSheet.OnTimer(Sender: TObject);
begin
  inc(FCurrentFrame);
  if FCurrentFrame > FEndFrame then
  begin
    FCurrentFrame := FStartFrame;
    if not FLoop then
      FTimer.Enabled := false;
  end;
  ImageIndex := FCurrentFrame;
end;

procedure TMycxTabSheet.SetIcon(AStartFrame: Integer; AEndFrame: Integer = -1;
  Loop: Boolean = false);
begin
  ImageIndex := FStartFrame;
end;

constructor TMycxTabSheet.Create(AOwner: TComponent);
begin
  inherited;
  MainFrame := nil;
  SecondFrame := nil;
  FTimer := TTimer.Create(Self);
  FTimer.Enabled := false;
  FTimer.Interval := 50;
  FTimer.OnTimer := OnTimer;
  FLoop := false;
end;

destructor TMycxTabSheet.Destroy;
begin
  FTimer.Free;
  { if Assigned(MainFrame) then
    begin
    if (MainFrame is TfGrid) then
    (MainFrame as TfGrid).Relise;
    MainFrame.Free;
    end;
    if Assigned(SecondFrame) then
    SecondFrame.Free; }
  inherited;
end;

{ procedure TcxPageControl.DoClose;
  begin
  if Assigned(FOnPageClose) then
  FOnPageClose(Self, ActivePage)
  else
  inherited;
  end; }

{ TmycxGridTableView }

{ constructor TmycxGridTableView.Create(AOwner: TComponent);
  begin
  inherited Create(AOwner);
  OnGetExpandable := nil;
  end;

  function TmycxGridTableView.GetViewDataClass: TcxCustomGridViewDataClass;
  begin
  Result := TmycxGridViewData;
  end; }

{ TmycxGridViewData }

{ function TmycxGridViewData.GetRecordClass(ARecordInfo: TcxRowInfo)
  : TcxCustomGridRecordClass;
  begin
  Result := inherited GetRecordClass(ARecordInfo);
  if Result = TcxGridMasterDataRow then
  Result := TmycxGridMasterDataRow;
  end; }

{ TmycxGridGroupRow }

{ function TmycxGridMasterDataRow.GetExpandable: Boolean;
  begin
  Result := false;
  if Assigned((GridView as TmycxGridTableView).OnGetExpandable) then
  (GridView as TmycxGridTableView).OnGetExpandable(Self, Result) else Result
  := inherited GetExpandable;
  end; }

{ Tmf }

{ procedure Tmf.tvMainRecordExpandable(MasterDataRow: TcxGridMasterDataRow;
  var Expandable: Boolean);
  begin
  Expandable := MasterDataRow.RecordIndex > 0;
  end; }

{ procedure Tmf.EXPANDROW(var Msg: TMessage);
  var
  mr: TcxCustomGridRecord;
  gv: TcxGridTableView;
  cl: TcxCustomGridView;
  begin
  if not((TObject(Msg.WParam) is TcxCustomGridRecord) and
  (TObject(Msg.LParam) is TcxGridTableView)) then
  Exit;
  mr := TcxCustomGridRecord(Msg.WParam);
  gv := TcxGridTableView(Msg.LParam);
  cl := gv.Clones[gv.CloneCount - 1];
  cl.BeginUpdate;
  try
  if mr.RecordIndex = 1 then

  with cl.DataController do
  begin
  cl.DataController.RecordCount := 2;
  cl.DataController.Values[0, 1] := 'album1url1';
  cl.DataController.Values[1, 1] := 'album1url2';
  end;
  finally
  cl.EndUpdate;
  end;
  end; }

procedure Tmf.WMActivate(var Msg: TWMActivate);
begin
  inherited;
  if (Msg.Active in [1, 2]) and assigned(w7taskbar) and
    (w7taskbar.State = tbpsError) then
    w7taskbar.State := tbpsNone;
end;

procedure Tmf.NEWLIST(var Msg: TMessage);
var
  n: TMycxTabSheet;
  f: TfNewList;
  l: TResourceList;
begin
  // if assigned(FullResList.OnJobChanged) then
  // begin
  // MessageDlg(lang('_BUSY_MAIN_LIST_'), mtInformation, [mbOk], 0);
  // Exit;
  // end;

  n := CreateTab(pcTables);
  n.ImageIndex := 0;
  f := TfNewList.Create(n);
  f.Setlang;
  f.State := lfsNew;
  // FullResList.OnError := f.OnErrorEvent;
  // FullResList.OnJobChanged := f.JobStatus;
  f.OnError := OnError;
  // f.Tag := integer(n);
  // n.Tag := integer(f);
  n.SecondFrame := f;
  f.Parent := n;

  l := TResourceList.Create;
  f.ActualResList := l;
  f.LoadItems;
  pcTables.Change;
  ShowDs;
end;

procedure Tmf.OnBalloonExitTimer(Sender: TObject);
begin
  FBalloon := nil;
end;

procedure Tmf.OnError(Sender: TObject; Msg: String; Data: Pointer);
var
  n: integer;
  p: pLogRec;
begin
  if mErrors.Lines.Count = 0 then
  begin
    n := 0;
    mErrors.Lines[0] := FormatDateTime('hh:nn:ss', Time) + ' ' +
    { Sender.ClassName + ': ' + } Msg;
  end else
  begin
    n := mErrors.Lines.add(FormatDateTime('hh:nn:ss', Time) + ' ' +
      { Sender.ClassName + ': ' + } Msg);
  end;

  setlength(fErrLogObj,mErrors.Lines.Count);

  if Assigned(Data) then
  begin
    New(p);
    p.Frame := Sender;
    p.Data := Data;
    fErrLogObj[n] := p;
  end else
    fErrLogObj[n] := 0;

  if assigned(mFrame) and (mFrame is tfStart) then
    MessageDlg(Msg, mtError, [mbOk], 0)
  else
    dsLogs.AutoHide := false;

  dsLogs.ActiveChild := dpErrors;
end;

procedure Tmf.OnLog(Sender: TObject; Msg: String; Data: Pointer);
begin
  if mLog.Lines.Count = 0 then
    mLog.Lines[0] := FormatDateTime('hh:nn:ss', Time) + ' ' +
    { Sender.ClassName + ': ' + } Msg
  else
    mLog.Lines.add(FormatDateTime('hh:nn:ss', Time) + ' ' +
      { Sender.ClassName + ': ' + } Msg);

  if assigned(mFrame) and (mFrame is tfStart) then
    // MessageDlg(Msg,mtError,[mbOk],0)
  else
    dsLogs.AutoHide := false;

  dsLogs.ActiveChild := dpLog;
end;

procedure Tmf.pcTablesCanCloseEx(Sender: TObject; ATabIndex: Integer;
  var ACanClose: Boolean);
begin
  ACanClose := false;
  CloseTab(pcTables.Pages[ATabIndex]);
end;

procedure Tmf.pcTablesChange(Sender: TObject);
begin
  updateTab;
  ChangeTags;
  HideBalloon;
end;

procedure Tmf.PicInfo(Sender: TObject; a: TTPicture);
var
  i: Integer;
  // r: TcxEditorRow;

  function VrType(a: variant): TFieldType;
  begin
    case VarType(a) of
      varInteger, varInt64:
        Result := ftNumber;
      varBoolean:
        Result := ftCheck;
      varUString, varDate:
        Result := ftString;
      varDouble:
        Result := ftFloatNumber;
    else
      Result := ftString;
    end;
  end;

begin
  if Sender = nil then
    FCurPic := nil
  else if ((pcTables.ActivePage as TMycxTabSheet).MainFrame <> Sender) { or
    (FCurPic = a) } then
    Exit
  else
    FCurPic := a;

  vgCurMain.BeginUpdate; try

    if FCurPic = nil then
    begin
      vgCurMain.ClearRows;
      chlbTags.Clear;
      Exit;
    end;

    vgCurMain.ClearRows;
    dm.CreateField(vgCurMain, 'vgiRName', lang('_RESNAME_'), '', ftString, nil,
      a.Resource.name, true);

    if a.Linked.Count > 0 then
      dm.CreateField(vgCurMain, 'vgiName', lang('_FILENAME_'), '', ftString,
        nil, '', true)
    else
      dm.CreateField(vgCurMain, 'vgiName', lang('_FILENAME_'), '', ftString,
        nil, a.PicName + '.' + a.Ext, true);

    if (a.FactFileName = '') then
      if a.Linked.Count > 0 then
        dm.CreateField(vgCurMain, 'vgiSavePath', lang('_SAVEPATH_'), '',
          ftPathText, nil, ExtractFilePath(a.Linked[0].FileName), true)
      else
        dm.CreateField(vgCurMain, 'vgiSavePath', lang('_SAVEPATH_'), '',
          ftPathText, nil, a.FileName, true)
    else
      dm.CreateField(vgCurMain, 'vgiSavePath', lang('_SAVEPATH_'), '',
        ftPathText, nil, a.FactFileName, true);

    for i := 0 to a.Meta.Count - 1 do
      with a.Meta.Items[i] do
        dm.CreateField(vgCurMain, 'avgi' + Name, Name, '', VrType(Value), nil,
          VarToStr(Value), true);

    if assigned(a.MD5) then
      dm.CreateField(vgCurMain, 'vgiMD5', lang('_MD5_'), '', ftString, nil,
        a.MD5^, true);

  finally
    vgCurMain.EndUpdate;
  end;

  chlbTags.Items.BeginUpdate; try

    chlbTags.Clear;

    for i := 0 to a.Tags.Count - 1 do
      chlbTags.AddItem(a.Tags[i].name + ' (' +
        IntTOStr(a.Tags[i].Linked.Count) + ')');

  finally
    chlbTags.Items.EndUpdate;
  end;
end;

procedure Tmf.RefreshResInfo(Sender: TObject);
var
  i: Integer;
  c: TcxEditorRow;
begin
  // EXIT;
  // vgTagsMain.ClearRows;
  if (pcTables.ActivePage is TMycxTabSheet) and
    ((pcTables.ActivePage as TMycxTabSheet).MainFrame is tfGrid) then
    with ((pcTables.ActivePage as TMycxTabSheet).MainFrame as tfGrid) do
    begin
      // for i := 0 to ResList.Count -1 do
      if (Sender is TResource) then
      begin
        i := ResList.IndexOf(Sender);
        if i = -1 then
          Exit;

        vgTagsMain.BeginUpdate;
        try
          c := (vgTagsMain.RowByName('vgT' + IntTOStr(i)) as TcxEditorRow);
          c.Properties.Value := ifn(ResList.ListFinished,
            ifn(ResList.PicsFinished, '', // if pics
            IntTOStr(ResList[i].PictureList.PicCounter.FSH + ResList[i]
            .PictureList.PicCounter.SKP + ResList[i]
            .PictureList.PicCounter.UNCH) + '/' +
            IntTOStr(ResList[i].PictureList.Count) +
            ifn(ResList[i].PictureList.PicCounter.ERR > 0,
            ' err ' + IntTOStr(ResList[i].PictureList.PicCounter.ERR), '')),

            IntTOStr(ResList[i].JobList.OkCount) + '/' // if pages
            + IntTOStr(ResList[i].JobList.Count) + ' (' +
            IntTOStr(ResList[i].HTTPRec.Theor) + ')' +
            ifn(ResList[i].JobList.ErrorCount > 0,
            ' err ' + IntTOStr(ResList[i].JobList.ErrorCount), ''));

          c.Visible := ifn(ResList.ListFinished, ifn(ResList.PicsFinished, true,
            not(ResList[i].PictureList.PicCounter.FSH + ResList[i]
            .PictureList.PicCounter.SKP + ResList[i]
            .PictureList.PicCounter.UNCH = ResList[i].PictureList.Count)),
            not(ResList[i].JobList.OkCount = ResList[i].JobList.Count));
        finally
          vgTagsMain.EndUpdate;
        end;
      end;

    end;
end;

procedure Tmf.RefreshTags(Sender: TObject; t: TPictureTagLinkList);
var
  l, i: Integer;
  ACheckItem: TcxCheckListBoxItem;
  // t: tpicturetaglinklist;
begin
  // EXIT;

  if (pcTables.ActivePage is TMycxTabSheet) and
    ((pcTables.ActivePage as TMycxTabSheet).MainFrame = Sender) then
    with ((pcTables.ActivePage as TMycxTabSheet).MainFrame as tfGrid) do
    begin
      chlbFullTags.Items.BeginUpdate;
      try
        // chlbFullTags.Clear;

        // t := (sender as tpicturetaglist);
        l := t.Count - 1;
        for i := 0 to l do
          // if (n < chlbFullTags.Items.Count)and(chlbFullTags.Items[n].Tag = Integer(ResList.PictureList.Tags[i])) then
          if (t[i].Tag > -1) then
            // if (t[i].Tag < chlbFullTags.Items.Count)
            // and(chlbFullTags.Items[t[i].Tag].Tag = Integer(
            // ResList.PictureList.Tags[t[i].Tag])) then
            if (ResList.PictureList.Tags[t[i].Tag].Tag <> 0) then
            begin
              ACheckItem := TcxCheckListBoxItem
                (ResList.PictureList.Tags[t[i].Tag].Tag);
              ACheckItem.Text := ResList.PictureList.Tags[t[i].Tag].name + ' ('
                + IntTOStr(ResList.PictureList.Tags[t[i].Tag]
                .Linked.Count) + ')';
            end
            else
            begin
              ACheckItem := chlbFullTags.Items.Insert(t[i].Tag)
                as TcxCheckListBoxItem;
              ACheckItem.Text := ResList.PictureList.Tags[t[i].Tag].name + ' ('
                + IntTOStr(ResList.PictureList.Tags[t[i].Tag]
                .Linked.Count) + ')';
              ACheckItem.Tag := Integer(ResList.PictureList.Tags[t[i].Tag]);
              ResList.PictureList.Tags[t[i].Tag].Tag := Integer(ACheckItem);
            end;

      finally
        chlbFullTags.Items.EndUpdate;
      end;
    end;
end;

procedure Tmf.AddTag(name: string; add: Boolean);
begin

end;

procedure Tmf.ApplicationEvents1Deactivate(Sender: TObject);
begin
  HideBalloon;
end;

procedure Tmf.ApplicationEvents1Exception(Sender: TObject; E: Exception);
begin
  OnError(Sender, E.Message, nil);
end;

procedure Tmf.ApplicationEvents1Minimize(Sender: TObject);
begin
  HideBalloon;
end;

procedure Tmf.APPLYNEWLIST(var Msg: TMessage);
var
  n: TMycxTabSheet;
  f: TfNewList;
  f2: tfGrid;

begin
  n := TMycxTabSheet(Msg.WParam);

  f := n.SecondFrame as TfNewList; // TfNewList(n.Tag);
  f.ResetItems;
  f.ActualResList.ApplyInherit;
  f.ActualResList.HandleKeywordList;

  f2 := tfGrid.Create(n) as tfGrid;
  f2.SetList(f.ActualResList);
  // f2.CreateList;
  f2.OnError := OnError;
  f2.OnLog := OnLog;

  if (VarToStr(f.FullResList[0].Fields['tag']) <> '') then
    n.Caption := trim(f.FullResList[0].Fields['tag'])
  else if (f.ActualResList.Count < 2) and
    (VarToStr(f.ActualResList[0].Fields['tag']) <> '') then
      n.Caption := trim(
      f.ActualResList[0].RestoreTagString(
      f.ActualResList[0].Fields['tag'],
      f.FullResList[0].HTTPRec.TagTemplate));

  f2.ResList.OnPageComplete := DoRefreshResInfo;

  SaveResourceSettings(f.FullResList[0], nil, true);

  f.Release;

  SaveResourceSettings(f.ActualResList);
  SaveProfileSettings;

  FreeAndNil(n.SecondFrame);

  f2.Reset;
  n.MainFrame := f2;
  f2.Parent := n;
  f2.ResList.ThreadHandler.Cookies := dm.Cookie;
  f2.ResList.DWNLDHandler.Cookies := dm.Cookie;
  //f2.ResList.UncheckBlacklisted := GlobalSettings.UncheckBlacklisted;
  f2.OnPicChanged := DoPicInfo;
  f2.SetSettings(true,true);
  f2.Setlang;
  f2.SetMenus;
  ShowPanels;
  f2.ResList.STARTJOB(JOB_LIST);
end;

procedure Tmf.APPLYSETTINGS(var Msg: TMessage);
var
  // n: TdxDockPanel;
  f: TfSettings;
begin
  f := SttPanel.MainFrame as TfSettings;
  SaveProfileSettings;
  SaveResourceSettings(f.FullResList);
  f.OnClose;
  CloseTab(SttPanel as TcxTabSheet);
  // SttPanel := nil;
end;

procedure Tmf.bbDeleteMD5DoublesClick(Sender: TObject);
var
  f: TFrame;
begin
  HideBalloon;
  f := TFrame((pcTables.ActivePage as TMycxTabSheet).MainFrame);
  if f is tfGrid then
    (f as tfGrid).DeleteMD5Doubles;
end;

procedure Tmf.bbNewClick(Sender: TObject);
begin
  PostMessage(Handle, CM_NEWLIST, 0, 0);
end;

procedure Tmf.bbSettingsClick(Sender: TObject);
begin
  PostMessage(Handle, CM_SHOWSETTINGS, 0, 0);
end;

procedure Tmf.bbStartListClick(Sender: TObject);
var
  f: TFrame;
  ff: tfGrid;
begin
  HideBalloon;
  f := TFrame((pcTables.ActivePage as TMycxTabSheet).MainFrame);
  if f is tfGrid then
  begin
    ff := f as tfGrid;
    with ff do
    begin
      vGrid.DataController.Post;
      if ResList.ListFinished
      and (ResList.PicsFinished or ResList.PicDW) then
      begin
        //if ResList.PicsFinished then
        SetSettings(true,ResList.PicsFinished);
        ResList.STARTJOB(JOB_LIST);
      end
      else
        ResList.STARTJOB(JOB_STOPLIST);
    end;
  end;
end;

procedure Tmf.bbStartPicsClick(Sender: TObject);
var
  f: TFrame;

begin
  HideBalloon;
  f := TFrame((pcTables.ActivePage as TMycxTabSheet).MainFrame);
  if f is tfGrid then
    with (f as tfGrid) do
    begin
      // vGrid.DataController.Post;
      if ResList.PicsFinished or not ResList.PicDW then
      begin
        SetSettings(ResList.ListFinished,true);
        // vGrid.BeginUpdate;
        // try
        // ResList.PictureList.CheckExists;
        UpdateChecks;
        // finally
        // vGrid.EndUpdate;
        // end;
        if GlobalSettings.Downl.AutoUncheckInvisible then
          UncheckInvisible;
        ResList.STARTJOB(JOB_PICS);
      end
      else
        ResList.STARTJOB(JOB_STOPPICS);
    end;
end;

procedure Tmf.CANCELNEWLIST(var Msg: TMessage);
var
  n: TMycxTabSheet;
  // f: TfNewList;

begin
  n := Pointer(Msg.WParam);
  // FreeAndNil(n.SecondFrame);
  // FullResList.OnError := OnError;
  // FullResList.OnJobChanged := nil;
  CloseTab(n);
end;

procedure Tmf.CANCELSETTINGS(var Msg: TMessage);
var
  f: TfSettings;

begin
  // n := Pointer(Msg.WParam);
  f := SttPanel.MainFrame as TfSettings;
  f.OnClose;
  // f.Free;
  CloseTab(SttPanel);
end;

procedure Tmf.ChangeResInfo;
var
  i: Integer;
  c: TcxCustomRow;
  // ACheckItem: TcxCheckListBoxItem;
begin
  // EXIT;

  vgTagsMain.ClearRows;
  if (pcTables.ActivePage is TMycxTabSheet) and
    ((pcTables.ActivePage as TMycxTabSheet).MainFrame is tfGrid) then
    with ((pcTables.ActivePage as TMycxTabSheet).MainFrame as tfGrid) do
    begin
      vgTagsMain.BeginUpdate;
      try
        for i := 0 to ResList.Count - 1 do
        begin
          c := dm.CreateField(vgTagsMain, 'vgT' + IntTOStr(i),
            ResList[i].name + '(' + VarToStr(ResList[i].Fields['tag'] + ')'),
            '', ftString, nil, ifn(ResList.ListFinished,
            ifn(ResList.PicsFinished, '', // if pics
            IntTOStr(ResList[i].PictureList.PicCounter.FSH + ResList[i]
            .PictureList.PicCounter.SKP + ResList[i]
            .PictureList.PicCounter.UNCH) + '/' +
            IntTOStr(ResList[i].PictureList.Count) +
            ifn(ResList[i].PictureList.PicCounter.ERR > 0,
            ' err ' + IntTOStr(ResList[i].PictureList.PicCounter.ERR), '')),

            IntTOStr(ResList[i].JobList.OkCount) + '/' // if pages
            + IntTOStr(ResList[i].JobList.Count) + ' (' +
            IntTOStr(ResList[i].HTTPRec.Theor) + ')' +
            ifn(ResList[i].JobList.ErrorCount > 0,
            ' err ' + IntTOStr(ResList[i].JobList.ErrorCount), '')), true);

          c.Visible := ifn(ResList.ListFinished, ifn(ResList.PicsFinished, true,
            not(ResList[i].PictureList.PicCounter.FSH + ResList[i]
            .PictureList.PicCounter.SKP + ResList[i]
            .PictureList.PicCounter.UNCH = ResList[i].PictureList.Count)),
            not(ResList[i].JobList.OkCount = ResList[i].JobList.Count));
        end;
      finally
        vgTagsMain.EndUpdate;
      end;
    end;
end;

procedure Tmf.ChangeTags;
var
  i: Integer;
  // ACheckItem: TcxCheckListBoxItem;
begin

  if (pcTables.ActivePage is TMycxTabSheet) and
    ((pcTables.ActivePage as TMycxTabSheet).MainFrame is tfGrid) then
    with ((pcTables.ActivePage as TMycxTabSheet).MainFrame as tfGrid) do
    begin
      chlbFullTags.Items.BeginUpdate;
      try
        chlbFullTags.Clear;

        if ResList.ListFinished and ResList.PicsFinished then
          for i := 0 to ResList.PictureList.Tags.Count - 1 do
          begin
            chlbFullTags.AddItem(ResList.PictureList.Tags[i].name + ' (' +
              IntTOStr(ResList.PictureList.Tags[i].Linked.Count) + ')');
            // ACheckItem := chlbFullTags.Items.Add;
            // ACheckItem.Text := ResList.PictureList.Tags[i].Name + ' (' + IntToStr(ResList.PictureList.Tags[i].Linked.Count) + ')';
            // ACheckItem.Tag := Integer(ResList.PictureList.Tags[i]);
            // ResList.PictureList.Tags[i].Tag := Integer(ACheckItem);
          end;

      finally
        chlbFullTags.Items.EndUpdate;
      end;

    end;

end;

procedure Tmf.CheckUpdates;
var
  t: TUPDThread;
begin
  t := TUPDThread.Create;
  t.Job := UPD_CHECK_UPDATES;
  t.MsgHWND := Self.Handle;
  t.FreeOnTerminate := true;
  t.CheckURL := GlobalSettings.CHKServ;
  t.ListURL := GlobalSettings.UPDServ;
  lUPD.Show;
  lUPD.BringToFront;
  SetEvent(t.Event);
end;

procedure Tmf.chlbFullTagsClickCheck(Sender: TObject; AIndex: Integer;
  APrevState, ANewState: TcxCheckBoxState);
begin
  AddTag(chlbFullTags.Items[AIndex].Text, ANewState = cbsChecked);
end;

procedure Tmf.ENDJOB(var Msg: TMessage);
var
  i: Integer;
  p: DUint64;
begin
  if (pcTables.ActivePage <> nil) and (Integer(pcTables.ActivePage) = Msg.WParam)
  then
  begin
    updateTab;
    if Msg.LParam = 0 then
    begin
      ChangeTags;
      if ((pcTables.ActivePage as TMycxTabSheet).MainFrame as tfGrid)
        .vGrid.DataController.RecordCount > 0 then
        ShowBalloon;
    end;
  end;

  if assigned(w7taskbar) and (Msg.WParam = w7taskbar.Tag) then
  begin
    for i := 0 to TabList.Count - 1 do
      if TMycxTabSheet(TabList[i]).MainFrame is tfGrid then
        case (TMycxTabSheet(TabList[i]).MainFrame as tfGrid).Busy of
          1:
            begin
              w7taskbar.Tag := Integer(TabList[i]);
              w7taskbar.SetProgress(0, 100);
              w7taskbar.State := tbpsIndeterminate;
              Exit;
            end;
          2:
            begin
              w7taskbar.Tag := Integer(TabList[i]);
              p := (TMycxTabSheet(TabList[i]).MainFrame as tfGrid).getprogress;
              w7taskbar.State := tbpsNormal;
              w7taskbar.SetProgress(p.V1, p.V2);
              Exit;
            end;
        end;
    w7taskbar.Tag := 0;
    if mf.Active then
    begin
      w7taskbar.State := tbpsNone;
      w7taskbar.SetProgress(0, 100);
    end
    else
    begin
      w7taskbar.State := tbpsError;
      w7taskbar.SetProgress(100, 100);
    end;
  end;

  { t := TMycxTabSheet(Msg.WParam);
    t.SetIcon(0); }
end;

procedure Tmf.fLogPopupPopup(Sender: TObject);
var
  p: pLogRec;
  l: integer;
begin
  l := mErrors.CaretPos.Y;//mErrors.Perform(201,mErrors.SelStart,0);
  p := pLogRec(fErrLogObj[l]);
  GOTO1.Visible := Assigned(p);
{  if assigned(p) then
    if Assigned(pcTables.ActivePage)
    and Assigned(p.Data)
    and (TMycxTabSheet(pcTables.ActivePage).MainFrame is tfGrid)
    and(TMycxTabSheet(pcTables.ActivePage).MainFrame = p.Frame) then
      with tfGrid(TMycxTabSheet(pcTables.ActivePage).MainFrame) do
      begin
        if TObject(p.Data) is TTPicture then
        begin
          GOTO1.Visible := True;
          Exit;
          //pic := p.Data;
          //if Assigned(pic.Parent) then
          //  vGrid.DataController.FocusedRecordIndex := pic.BookMark
          //else
          //  vGrid.DataController.FocusedRecordIndex := pic.BookMark;
        end;
      end;
  GOTO1.Visible := False;   }
end;

procedure Tmf.UPDATECHECK(var Msg: TMessage);
begin
  lUPD.Hide;
  case Msg.WParam of
    // - 1: In XE3 cause error
    // CheckUpdates;
    0:
      OnError(Self, 'Update check is failed: ' + TUPDThread(Msg.LParam).Error, nil);
    1:
      if MessageDlg(lang('_NEWUPDATES_'), mtConfirmation, [mbYes, mbNo], 0) = mrYes
      then
        StartUpdate;
    2:
      ; // ALL OK;
    3:
      CheckUpdates;
  end;
end;

procedure Tmf.updateTab;
begin
  // EXIT;

  if (pcTables.ActivePage <> nil) and (pcTables.ActivePage is TMycxTabSheet)
  then
  begin
    if (TMycxTabSheet(pcTables.ActivePage).SecondFrame is TfNewList) then
    begin
      // pcTables.Options := pcTables.Options + [pcoCloseButton];
      bbStartList.Caption := lang('_STARTLIST_');
      bbStartList.ImageIndex := 3;
      bbStartPics.Caption := lang('_STARTPICS_');
      bbStartPics.ImageIndex := 5;
      bbStartList.Enabled := false;
      bbStartPics.Enabled := false;
      dsTags.Hide;
    end
    else if (TMycxTabSheet(pcTables.ActivePage).MainFrame is tfGrid) then
      with (TMycxTabSheet(pcTables.ActivePage).MainFrame as tfGrid) do
      begin
        bbStartList.Enabled := true;
        bbStartPics.Enabled := true;
        if SignalTimer.Enabled then bbSignalTimer.Visible := ivAlways
        else bbSignalTimer.Visible := ivNever;

        if ResList.ListFinished
        and (ResList.PicsFinished or ResList.PicDW) then
        begin
          bbStartList.Caption := lang('_STARTLIST_');
          bbStartList.ImageIndex := 3;
          //bbStartList.Enabled := true;
          //bbStartPics.Enabled := true;
          // Barmanager.sh
          // BalloonHint.ShowHint();
          // bmbMain.ItemLinks[2].

        end
        else
        begin
          bbStartList.Caption := lang('_STOPLIST_');
          bbStartList.ImageIndex := 4;
//          bbStartPics.Enabled := false;
        end;
//        bbStartList.Enabled := true;
        // bbStartPics.Enabled := true;

        if ResList.PicsFinished or not ResList.PicDW then
        begin
          bbStartPics.Caption := lang('_STARTPICS_');
          bbStartPics.ImageIndex := 5;
//          bbStartList.Enabled := true;
        end
        else
        begin
          bbStartPics.Caption := lang('_STOPPICS_');
          bbStartPics.ImageIndex := 6;
//          bbStartList.Enabled := false;
        end;

        // bbStartList.Enabled := true;

        // pcTables.Options := pcTables.Options + [pcoCloseButton];

        if not dsTags.AutoHide then
          dsTags.Show;

        { Screen.Cursor := crHourGlass;
          try
          vd.Open;
          finally
          Screen.Cursor := crDefault;
          end; }
        UpdateFocusedRecord(vGrid.Controller.FocusedRow);
        ChangeResInfo;
        // ChangeTags;
        // sBar.Panels[1].Text := 'TTL ' + IntToStr(vGrid.DataController.RecordCount);
      end
    else
    begin
      // dsTags.Hide;
      bbStartList.Caption := lang('_STARTLIST_');
      bbStartPics.Caption := lang('_STARTPICS_');
      bbStartList.Enabled := false;
      bbStartPics.Enabled := false;
      // pcTables.Options := pcTables.Options - [pcoCloseButton];
      dsTags.Hide;
    end;

    bbAdvanced.Enabled := bbStartPics.Enabled and bbStartList.Enabled;
  end;
end;

procedure Tmf.STARTJOB(var Msg: TMessage);
{ var
  t: TMycxTabSheet; }
begin
  HideBalloon;
  updateTab;
  if assigned(w7taskbar) and (w7taskbar.Tag = 0) then
  begin
    w7taskbar.Tag := Msg.WParam;
    w7taskbar.SetProgress(0, 100);
    case Msg.LParam of
      0:
        w7taskbar.State := tbpsIndeterminate;
      1:
        w7taskbar.State := tbpsNormal;
    end;
  end;

  { t := TMycxTabSheet(Msg.WParam);
    t.SetIcon(0,15,true); }
end;

procedure Tmf.LANGUAGECHANGED(var Msg: TMessage);
var
  i: Integer;
begin
  // LoadLang(IncludeTrailingPathDelimiter(ExtractFilePath(paramstr(0))
  // + 'languages') + langname+'.ini');
  CreateLangINI(IncludeTrailingPathDelimiter(ExtractFilePath(paramstr(0)) +
    'languages') + langname + '.ini');

  Setlang;

  for i := 0 to pcTables.PageCount - 1 do
    if pcTables.Pages[i] is TMycxTabSheet then
      with (pcTables.Pages[i] as TMycxTabSheet) do
      begin
        if assigned(MainFrame) then
          if MainFrame is tfGrid then
            (MainFrame as tfGrid).Setlang
          else if MainFrame is TfNewList then
            (MainFrame as TfNewList).Setlang
          else if MainFrame is TfSettings then
            (MainFrame as TfSettings).Setlang;
        if assigned(SecondFrame) then
          if SecondFrame is TfNewList then
            (SecondFrame as TfNewList).Setlang;
      end;

  if assigned(SttPanel) then
    SttPanel.Caption := lang('_SETTINGS_');

end;

procedure Tmf.WHATSNEW(var Msg: TMessage);
begin
  if FileExists(IncludeTrailingPathDelimiter(rootdir) + 'versionlog.txt') then
    ShowNews(IncludeTrailingPathDelimiter(rootdir) + 'versionlog.txt');
  // ShowWhatsNew;
end;

procedure Tmf.STYLECHANGED(var Msg: TMessage);
begin
  dxSkinController.NativeStyle := GlobalSettings.UseLookAndFeel;
  dxSkinController.SkinName := GlobalSettings.SkinName;
  if dxSkinController.SkinName <> '' then
  begin
    nvTags.BeginUpdate;
    nvCur.BeginUpdate;
    try
      nvTags.View := 15;
      nvCur.View := 15;
      dxSkinController.UseSkins := true;
      // TdxNavBarSkinNavPanePainter(nvTags).SkinName := dxSkinController.SkinName;
      // TdxNavBarSkinNavPanePainter(nvCur).SkinName := dxSkinController.SkinName;
    finally
      nvTags.EndUpdate;
      nvCur.EndUpdate;
    end;
  end
  else
  begin
    dxSkinController.UseSkins := false;
    nvTags.View := 3;
    nvCur.View := 3;
  end;
end;

procedure Tmf.WREFRESHRESINFO(var Msg: TMessage);
begin
  RefreshResInfo(TObject(Msg.LParam));
end;

procedure Tmf.bbSignalTimerClick(Sender: TObject);
var
  f: TFrame;

begin
  HideBalloon;
  f := TFrame((pcTables.ActivePage as TMycxTabSheet).MainFrame);
  if f is tfGrid then
    with (f as tfGrid) do
    begin
      SignalTimer.Enabled := false;
      updateTab;
      //PostMessage(Application.MainForm.Handle, CM_ENDJOB,
      //Integer(Self.Parent), 0);
    end;
end;

procedure Tmf.WREFRESHPIC(var Msg: TMessage);
begin
  PicInfo(TObject(Msg.WParam), TTPicture(Msg.LParam));
end;

procedure Tmf.MENUSTYLECHANGED(var Msg: TMessage);
var
  i, j: Integer;
begin
  if GlobalSettings.MenuCaptions then
  begin
    for i := 0 to BarManager.ItemCount - 1 do
      if BarManager.Items[i] is TdxBarButton then
        (BarManager.Items[i] as TdxBarButton).PaintStyle := psCaptionGlyph
      else if BarManager.Items[i] is TdxBarSubItem then
        (BarManager.Items[i] as TdxBarSubItem).ShowCaption := true;

    for j := 0 to pcTables.PageCount - 1 do
      if pcTables.Pages[j] is TMycxTabSheet then
        with (pcTables.Pages[j] as TMycxTabSheet) do
        begin
          if assigned(MainFrame) then
            if MainFrame is tfGrid then
              (MainFrame as tfGrid).SetMenus;
        end;

  end
  else
  begin
    for i := 0 to BarManager.ItemCount - 1 do
      if BarManager.Items[i] is TdxBarButton then
        (BarManager.Items[i] as TdxBarButton).PaintStyle := psStandard
      else if BarManager.Items[i] is TdxBarSubItem then
        (BarManager.Items[i] as TdxBarSubItem).ShowCaption := false;

    for j := 0 to pcTables.PageCount - 1 do
      if pcTables.Pages[j] is TMycxTabSheet then
        with (pcTables.Pages[j] as TMycxTabSheet) do
        begin
          if assigned(MainFrame) then
            if MainFrame is tfGrid then
              (MainFrame as tfGrid).SetMenus;
        end;
  end;
end;

procedure Tmf.JOBPROGRESS(var Msg: TMessage);
var
  p: PDUInt64;
begin
  if assigned(w7taskbar) then
    if Msg.WParam = w7taskbar.Tag then
    begin
      p := PDUInt64(Msg.LParam);
      w7taskbar.SetProgress(p.V1, p.V2);
    end;
end;

procedure Tmf.LOGMODECHANGED(var Msg: TMessage);
begin
  Setlang;
end;

procedure Tmf.StartUpdate;
var
  f: tfileStream;
  // r: tresourcestream;
begin
  f := tfileStream.Create(IncludeTrailingPathDelimiter(rootdir) +
    'NPUpdater.exe', fmCreate);
  try
    // r := tresourcestream.Create(hInstance,'ZUPDATER','UPDATER');
    // try
    // r.SaveToStream(f);
    // finally
    // r.Free;
    // end;
    LoadFromRes(f, 'ZUPDATER');
  finally
    f.Free;
  end;

  ShellExecute(Handle, 'open', PWidechar(IncludeTrailingPathDelimiter(rootdir) +
    'NPUpdater.exe'), nil, nil, SW_SHOWNORMAL);
  Close;
end;

procedure Tmf.testoClick(Sender: TObject);
begin
  fmAbout.Show;
end;

procedure Tmf.CLEAR1Click(Sender: TObject);
begin
  //if MessageDlg(lang('_CLEARCONFIRM_'),mtConfirmation,[mbYes,mbNo],0) = mrYes then
  mErrors.Clear;
end;

function Tmf.CloseAllTabs: Boolean;
var
  i: Integer;
begin
  i := pcTables.PageCount;
  while i > 0 do
  begin
    CloseTab(pcTables.Pages[0]);
    if pcTables.PageCount = i then
    begin
      Result := false;
      Exit;
    end
    else
      i := pcTables.PageCount;
  end;
  Result := true;
end;

procedure Tmf.CloseTab(t: TcxTabSheet);
var
  f: TFrame;
begin
  HideBalloon;

  if t is TMycxTabSheet then
  begin
    f := (t as TMycxTabSheet).MainFrame;
    if f is tfGrid then
      with (f as tfGrid) do
        if not ResList.ListFinished or not ResList.PicsFinished then
        begin
          MessageDlg(lang('_TAB_IS_BUSY_'), mtError, [mbOk], 0);
          Exit;
        end
        else
          Relise;
    if (t as TMycxTabSheet).SecondFrame is TfNewList then
    begin
      ((t as TMycxTabSheet).SecondFrame as TfNewList).ActualResList.Free;
      ((t as TMycxTabSheet).SecondFrame as TfNewList).Release;
    end;
    FreeAndNil(f);
  end;

  t.Free;
  pcTables.Change;
  // FreeAndNil(t);
  TabList.Remove(t);
  if SttPanel = t then
    SttPanel := nil;
  if pcTables.PageCount = 0 then
    HideDs;
end;

procedure Tmf.COPY1Click(Sender: TObject);
begin
  mErrors.CopyToClipboard;
end;

function Tmf.CreateTab(pc: TcxPageControl; Enc: Boolean): TMycxTabSheet;
var
  n: TMycxTabSheet;

begin
  if assigned(mFrame) then
    FreeAndNil(mFrame);

  n := TMycxTabSheet.Create(Self);
  // n.ImageIndex := 0;
  n.Caption := lang('_NEWTABCAPTION_') + IntTOStr(TabList.Count + 1);
  // n.OnClose := dxTabClose;
  // n.Dockable := false;
  // n.ShowCaption := false;
  // n.CaptionButtons := [cbClose];
  n.PageControl := pc;
  pc.ActivePage := n;
  { if pc.PageCount < 2 then
    pc.HideTabs := true; }

  if Enc then
  begin
    // pc.Change;
    TabList.add(n);
  end;
  Result := n;

  ShowDs;
end;

procedure Tmf.DoPicInfo(Sender: TObject; a: TTPicture);
begin
  PostMessage(Handle, CM_REFRESHPIC, Integer(Sender), Integer(a));
end;

procedure Tmf.DoRefreshResInfo(Sender: TObject);
begin
  PostMessage(Handle, CM_REFRESHRESINFO, 0, Integer(Sender));
end;

procedure Tmf.Setlang;
begin
{$IFDEF DEBUG}
  if GLOBAL_LOGMODE then
    Caption := FOldCaption + ' ' + vINFO.FileVersion + 'α debug log'
  else
    Caption := FOldCaption + ' ' + vINFO.FileVersion + 'α debug';
{$ELSE}
  if GLOBAL_LOGMODE then
    Caption := FOldCaption + ' ' + vINFO.FileVersion + 'α log'
  else
    Caption := FOldCaption + ' ' + vINFO.FileVersion + 'α';
{$ENDIF}
  bbNew.Caption := lang('_NEWLIST_');
  bbStartList.Caption := lang('_STARTLIST_');
  bbStartPics.Caption := lang('_STARTPICS_');
  bbSettings.Caption := lang('_SETTINGS_');
  bbAdvanced.Caption := lang('_ADVANCED_');
  bbSignalTimer.Caption := lang('_DISABLESIGNALTIMER_');
  bbDeleteMD5Doubles.Caption := lang('_DELETEMD5DOUBLES_');
  dpLog.Caption := lang('_LOG_');
  dpErrors.Caption := lang('_ERRORS_');
  dpTags.Caption := lang('_COMMON_');
  dpCurTags.Caption := lang('_INFO_');
  nbgCurMain.Caption := lang('_GENERAL_');
  nbgTagsMain.Caption := lang('_GENERAL_');
  nbgCurTags.Caption := lang('_TAGS_');
  nbgTagsTags.Caption := lang('_TAGS_');

  COPY1.Caption := lang('_COPY_');
  GOTO1.Caption := lang('_GOTO_');
  SELECTALL1.Caption := lang('_SELECTALL_');
  CLEAR1.Caption := lang('_CLEAR_');
end;

procedure Tmf.ShowBalloon;
var
  p: TPoint;

begin
  // Bhint.Title := 'herp';
  // Bhint.Description := 'derp';
  // Bhint.ShowHint(ClientToScreen(bmbMain.ItemLinks[2].ItemRect.BottomRight));

  if not GlobalSettings.Tips or not Active or not Visible then
    Exit;

  if assigned(FBalloon) then
    FBalloon.Hide;

  p.X := bmbMain.ItemLinks[2].ItemRect.Left + 15;
  p.Y := bmbMain.ItemLinks[2].ItemRect.Bottom - 10;
  p := ClientToScreen(p);
  FBalloon := TBalloon.CreateNew(Self);
  FBalloon.OnRelease := OnBalloonExitTimer;
  FBalloon.ShowBalloon(p.X, p.Y, lang('_HINT_STARTDOWNLOAD_TITLE_'),
    lang('_HINT_STARTDOWNLOAD_DESCRIPTION_'), blnNone, 5, blnArrowBottomRight);
end;

procedure Tmf.ShowDs;
begin
  pcTables.Change;
  if not ds.Visible then
  begin
    // bmbMain.Visible := true;
    ds.Show;
  end;
end;

procedure Tmf.ShowPanels;
begin
  if not bmbMain.Visible then
    bmbMain.Visible := true;
  pcTables.Change;
  PicInfo(nil, nil);
  if not dsLogs.AutoHide then
    dsLogs.Visible := true;
end;

procedure Tmf.SHOWSETTINGS(var Msg: TMessage);
var
  // n: TdxDockPanel;
  f: TfSettings;

begin
  if assigned(SttPanel) then
  begin
    pcTables.ActivePage := SttPanel;
    Exit;
  end;

  if pcTables.PageCount = 0 then
  begin
    pcTables.HideTabs := true;
    // dpLog.Visible := false;
    // dpErrors.Visible := false;
  end;

  SttPanel := CreateTab(pcTables, false);
  SttPanel.ImageIndex := 1;
  SttPanel.Caption := lang('_SETTINGS_');

  f := TfSettings.Create(SttPanel);
  f.OnError := OnError;
  f.Setlang;
  f.CreateResources;
  f.LoadSettings;
  SttPanel.MainFrame := f;
  f.ResetButtons;
  f.Parent := SttPanel;
  ShowDs;
end;

procedure Tmf.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  try
    GlobalSettings.GUI.FormState := WindowState <> wsNormal;
    GlobalSettings.GUI.PanelPage := dsTags.ActiveChildIndex;
    GlobalSettings.GUI.PanelWidth := dsTags.Width;
    SaveGUISettings([gvSizes]);
  except
  end;
end;

procedure Tmf.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  try
    CanClose := CloseAllTabs;
  except
  end;
end;

procedure Tmf.FormCreate(Sender: TObject);
var
  tmp: TMessage;
begin
  Self.Scaled := false;
  StandardizeFormFont(Self);
  FOldCaption := Caption;
  { if GlobalSettings.UseLookAndFeel then
    dxSkinController.NativeStyle := true; }
  Self.SetBounds(Left, Top, GlobalSettings.GUI.FormWidth,
    GlobalSettings.GUI.FormHeight);
  dsTags.ActiveChildIndex := GlobalSettings.GUI.PanelPage;
  dsTags.Width := GlobalSettings.GUI.PanelWidth;
  STYLECHANGED(tmp);
  // ClientWidth := Globalsettings.GUI.FormWidth;
  // ClientHeight := Globalsettings.GUI.FormHeight;
  if GlobalSettings.GUI.FormState then
    WindowState := wsMaximized;

  Setlang;
  // pcTables.OnPageClose := OnTabClose;
  FBalloon := nil;
  // FullResList.OnError := OnError;
  dsFirstShow := true;
  SttPanel := nil;

  mFrame := tfStart.Create(Self);
  (mFrame as tfStart).Setlang;
  mFrame.Parent := Self;

  TabList := TList.Create;
  bmbMain.Visible := false;

  dsLogs.AutoHide := true;
  dsLogs.Hide;
  dsTags.Hide;
  FCurPic := nil;
  SendMessage(Handle, CM_MENUSTYLECHANGED, 0, 0);
  if OpBase.SHOWSETTINGS then
    PostMessage(Handle, CM_SHOWSETTINGS, 0, 0)
  else if GlobalSettings.AutoUPD then
    PostMessage(Handle, CM_UPDATE, 3, 0);
  if GlobalSettings.ShowWhatsNew and GlobalSettings.IsNew then
    PostMessage(Handle, CM_WHATSNEW, 0, 0);

  // CheckUpdates;
end;

procedure Tmf.FormDestroy(Sender: TObject);
begin
  if assigned(mFrame) then
    mFrame.Free;
  if assigned(SttPanel) then
    SttPanel.Free;
  TabList.Free;
  // FCookie.Free;
end;

procedure Tmf.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Shift = [ssCtrl]) and (Key = $57 { W } ) and
    (pcTables.ActivePageIndex <> -1) and (SttPanel <> pcTables.ActivePage) then
    CloseTab(pcTables.ActivePage);
end;

procedure Tmf.FormResize(Sender: TObject);
begin
  if WindowState = wsNormal then
  begin
    GlobalSettings.GUI.FormWidth := Width;
    GlobalSettings.GUI.FormHeight := Height;
  end;
end;

procedure Tmf.GOTO1Click(Sender: TObject);
var
  p: pLogRec;
  l,i: integer;
  pic: TTPicture;
  t: TMycxTabSheet;
  dc: tcxGridDataController;
begin
  l := mErrors.CaretPos.Y; //mErrors.Perform(201,mErrors.SelStart,0);
  if l < 0 then
    Exit;
  p := pLogRec(fErrLogObj[l]);
  if assigned(p) then
    for i := 0 to TabList.Count-1 do
    begin
      t := TabList[i];
      if (t.MainFrame = p.Frame)
      and (t.MainFrame is tfGrid)
      and not Assigned(t.SecondFrame) then
      begin
        pcTables.ActivePage := t;
        with tfGrid(t.MainFrame) do
        begin
          if TObject(p.Data) is TTPicture then
          begin
            pic := TTPicture(p.Data);
            vGrid.Controller.ClearSelection;
            if Assigned(pic.Parent) then
            begin
              //vGrid.Controller.FocusedRecordIndex := pic.Parent.BookMark-1;
              vGrid.ViewData.Records[pic.Parent.BookMark-1].Expand(false);
              dc := tcxGridDataController(vGrid.DataController.GetDetailDataController(pic.Parent.BookMark-1, 0));
              Grid.FocusedView := dc.GridView;
              dc.FocusedRecordIndex := pic.BookMark -1;
            end else
              vGrid.Controller.FocusedRecordIndex := pic.BookMark-1;
            //tMycxTabSheet(pcTables.ActivePage).MainFrame.SetFocus;
            Grid.SetFocus;
            vGrid.Focused := True;
            vGrid.Controller.FocusedRecord.Selected := True;
          end;
        end;
      end;
    end;

{    if Assigned(pcTables.ActivePage)
    and Assigned(p.Data)
    and (TMycxTabSheet(pcTables.ActivePage).MainFrame is tfGrid)
    and(TMycxTabSheet(pcTables.ActivePage).MainFrame = p.Frame) then
      with tfGrid(TMycxTabSheet(pcTables.ActivePage).MainFrame) do
      begin
        if TObject(p.Data) is TTPicture then
        begin
          pic := TTPicture(p.Data);
          vGrid.Controller.ClearSelection;
          if Assigned(pic.Parent) then
            vGrid.Controller.FocusedRecordIndex := pic.BookMark-1
          else
            vGrid.Controller.FocusedRecordIndex := pic.BookMark-1;
          //tMycxTabSheet(pcTables.ActivePage).MainFrame.SetFocus;
          Grid.SetFocus;
          vGrid.Focused := True;
          vGrid.Controller.FocusedRecord.Selected := True;
        end;
      end;
}
end;

{ procedure Tmf.gLevel2GetGridView(Sender: TcxGridLevel;
  AMasterRecord: TcxCustomGridRecord; var AGridView: TcxCustomGridView);

  begin
  PostMessage(Handle, CM_EXPROW, integer(AMasterRecord), integer(AGridView));
  end; }

procedure Tmf.HideBalloon;
begin
  if assigned(FBalloon) then
    FBalloon.Hide;
end;

procedure Tmf.HideDs;
begin
  if ds.Visible then
  begin
    ds.Hide;
    dsLogs.AutoHide := true;
    // dsTags.Hide;
    // dsLogs.Hide;
    bmbMain.Visible := false;
    pcTables.HideTabs := false;
    // dpLog.Visible := true;
    // dpErrors.Visible := true;
    mFrame := tfStart.Create(Self);
    (mFrame as tfStart).Setlang;
    mFrame.Parent := Self;
  end;
end;

end.
