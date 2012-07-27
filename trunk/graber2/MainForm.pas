unit MainForm;

interface

uses
  {base}
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ActnList, ExtCtrls, ImgList, rpVersionInfo,
  AppEvnts, Types, ShellAPI, Math,
  {devex}
  cxPC, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxPCdxBarPopupMenu, cxEdit,
  cxContainer, dxBar, cxClasses, dxDockControl, cxLabel, cxTextEdit, cxMemo,
  cxCheckListBox, cxInplaceContainer, cxVGrid, dxNavBarCollns, dxNavBarBase,
  dxNavBar, dxDockPanel, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  dxSkinscxPCPainter, dxSkinsdxNavBarPainter, dxSkinsdxDockControlPainter,
  dxSkinsdxBarPainter, dxSkinsForm,
  {graber2}
  common, OpBase, graberU, MyHTTP, UPDUnit, cxMaskEdit, cxSpinEdit
  {skins}
  {dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel,
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
  dxSkinsdxNavBarPainter, dxSkinsdxDockControlPainter, dxSkinsdxBarPainter};

type

  TMycxTabSheet = class(TcxTabSheet)
    private
      FTimer: TTimer;
      FStartFrame,FEndFrame,FCurrentFrame: Integer;
      FLoop: Boolean;
      FRName: String;
      procedure OnTimer(Sender: TObject);
    public
      MainFrame: TFrame;
      SecondFrame: TFrame;
      property RName: String read FRName write FRName;
      procedure SetIcon(AStartFrame: integer; AEndFrame: integer = -1;
      Loop: boolean = false);
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
  end;

{
  TcxTabSheetEvent = procedure(ASender: TObject; ATabSheet: TcxTabSheet)
    of object;
}

  TcxPageControl = class(cxPC.TcxPageControl);
{
  private
    FOnPageClose: TcxTabSheetEvent;
  protected
    procedure DoClose; override;
  public
    property OnPageClose: TcxTabSheetEvent read FOnPageClose write FOnPageClose;
  end;
}

  { TmycxOnGetExpandable = procedure(MasterDataRow: TcxGridMasterDataRow;
    var Expandable: Boolean) of object;

    TmycxGridTableView = class(TcxGridTableView)
    private
    protected
    function GetViewDataClass: TcxCustomGridViewDataClass; override;
    public
    OnGetExpandable: TmycxOnGetExpandable;
    constructor Create(AOwner: TComponent); override;
    end;

    TmycxGridViewData = class(TcxGridViewData)
    protected
    function GetRecordClass(ARecordInfo: TcxRowInfo)
    : TcxCustomGridRecordClass; override;
    end;

    TmycxGridMasterDataRow = class(TcxGridMasterDataRow)
    protected
    function GetExpandable: Boolean; override;
    end; }

  // TmfState = (msStart, msNewList, msGrid, msSettings);

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
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
{    procedure gLevel2GetGridView(Sender: TcxGridLevel;
      AMasterRecord: TcxCustomGridRecord; var AGridView: TcxCustomGridView);   }
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
    procedure DockManagerActiveDockControlChanged(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cxSpinEdit1PropertiesEditValueChanged(Sender: TObject);
  private
    mFrame: TFrame;
    FOldCaption: String;
    // tvMain: TmycxGridTableView;
  protected
//    procedure EXPANDROW(var Msg: TMessage); message CM_EXPROW;
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
    //procedure dxTabClose(Sender: TdxCustomDockControl);
    // procedure APPLYEDITLIST(var Msg: TMessage); message CM_APPLYNEWLIST;
  private
    TabList: TList;
    dsFirstShow: Boolean;
    SttPanel: TMycxTabSheet;
    FCookie: TMyCookieList;
    CurPic: TTPicture;
    { Private declarations }
  public
    // OldState: TmfState;
    { procedure tvMainRecordExpandable(MasterDataRow: TcxGridMasterDataRow;
      var Expandable: Boolean); }
    function CreateTab(pc: TcxPageControl; Enc: boolean = true): TMycxTabSheet;
    procedure ShowDs;
    procedure HideDs;
    procedure CloseTab(t: TcxTabSheet);
//    procedure OnTabClose(ASender: TObject; ATabSheet: TcxTabSheet);
    procedure ShowPanels;
    procedure OnError(Sender: TObject; Msg: String);
    procedure Setlang;
    procedure PicInfo(Sender: TObject; a: TTPicture);
    procedure CheckUpdates;
    procedure StartUpdate;
    procedure ChangeResInfo;
    procedure RefreshResInfo(Sender: TObject);
    function CloseAllTabs: boolean;
    procedure RefreshTags(Sender: TObject; t: TPictureTagLinkList);

    { Public declarations }
  end;

var
  mf: Tmf;
  hWndTip: THandle;

implementation

uses StartFrame, NewListFrame, LangString, SettingsFrame, GridFrame, utils,
  AboutForm, Whatsnewform;
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

procedure TMycxTabSheet.SetIcon(AStartFrame: integer; AEndFrame: integer = -1;
      Loop: boolean = false);
begin
  //FTimer.Enabled := false;

{  FStartFrame := AStartFrame;
  FLoop := Loop;
  if not FTimer.Enabled or FTimer.Enabled and (AEndFrame > -1)
  and (FCurrentFrame < FStartFrame) then
    FCurrentFrame := FStartFrame;
  if (AEndFrame > -1) then
    FEndFrame := AEndFrame;
  if (ImageIndex <> FStartFrame) or (AEndFrame > -1) then
    FTimer.Enabled := true;   }
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
{  if Assigned(MainFrame) then
  begin
    if (MainFrame is TfGrid) then
      (MainFrame as TfGrid).Relise;
    MainFrame.Free;
  end;
  if Assigned(SecondFrame) then
    SecondFrame.Free;    }
  inherited;
end;

{procedure TcxPageControl.DoClose;
begin
  if Assigned(FOnPageClose) then
    FOnPageClose(Self, ActivePage)
  else
    inherited;
end;   }

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

{procedure Tmf.EXPANDROW(var Msg: TMessage);
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
end;    }

procedure Tmf.NEWLIST(var Msg: TMessage);
var
  n: TMycxTabSheet;
  f: TfNewList;

begin
  if Assigned(FullResList.OnJobChanged) then
  begin
    MessageDlg(lang('_BUSY_MAIN_LIST_'),mtInformation,[mbOk],0);
    Exit;
  end;


  n := CreateTab(pcTables);
  n.ImageIndex := 0;
  f := TfNewList.Create(n);
  f.SetLang;
  f.State := lfsNew;
  FullResList.OnError := f.OnErrorEvent;
  FullResList.OnJobChanged := f.JobStatus;
  f.OnError := OnError;
  //f.Tag := integer(n);
  //n.Tag := integer(f);
  n.SecondFrame := f;

  f.LoadItems;

  f.Parent := n;
  pcTables.Change;
  ShowDs;
end;

procedure Tmf.OnError(Sender: TObject; Msg: String);
begin
  if mErrors.Lines.Count = 0 then
    mErrors.Lines[0] := FormatDateTime('hh:nn:ss',Time) + ' ' + Msg
  else
    mErrors.Lines.Add(FormatDateTime('hh:nn:ss',Time) + ' ' + Msg);
  dsLogs.AutoHide := false;
  dsLogs.Show;
  dsLogs.ActiveChild := dpErrors;
end;

{procedure Tmf.OnTabClose(ASender: TObject; ATabSheet: TcxTabSheet);
begin
  CloseTab(ATabSheet);
end;  }

procedure Tmf.pcTablesCanCloseEx(Sender: TObject; ATabIndex: Integer;
  var ACanClose: Boolean);
begin
  ACanClose := false;
  CloseTab(pcTables.Pages[ATabIndex]);
end;

procedure Tmf.pcTablesChange(Sender: TObject);
begin
  if (pcTables.ActivePage <> nil) and (pcTables.ActivePage is TMycxtabSheet) then
  begin
    if (TMycxtabSheet(pcTables.ActivePage).SecondFrame is TfNewList) then
    begin
      //pcTables.Options := pcTables.Options + [pcoCloseButton];
      bbStartList.Caption := lang('_STARTLIST_');
      bbStartList.ImageIndex := 3;
      bbStartPics.Caption := lang('_STARTPICS_');
      bbStartPics.ImageIndex := 5;
      bbStartList.Enabled := false;
      bbStartPics.Enabled := false;
      dsTags.Hide;
    end
    else if (TMycxtabSheet(pcTables.ActivePage).MainFrame is TfGrid) then
    with (TMycxtabSheet(pcTables.ActivePage).MainFrame as TfGrid) do
    begin
      //dsTags.Show;
      if ResList.ListFinished then
      begin
        bbStartList.Caption := lang('_STARTLIST_');
        bbStartList.ImageIndex := 3;
        bbStartPics.Enabled := true;
      end else
      begin
        bbStartList.Caption := lang('_STOPLIST_');
        bbStartList.ImageIndex := 4;
        bbStartPics.Enabled := false;
      end;
      bbStartList.Enabled := true;
      //bbStartPics.Enabled := true;

      if ResList.PicsFinished then
      begin
        bbStartPics.Caption := lang('_STARTPICS_');
        bbStartPics.ImageIndex := 5;
        bbStartList.Enabled := true;
      end else
      begin
        bbStartPics.Caption := lang('_STOPPICS_');
        bbStartPics.ImageIndex := 6;
        bbStartList.Enabled := false;
      end;
      //bbStartList.Enabled := true;

      //pcTables.Options := pcTables.Options + [pcoCloseButton];

      if not dsTags.AutoHide then
        dsTags.Show;

{      Screen.Cursor := crHourGlass;
      try
        vd.Open;
      finally
        Screen.Cursor := crDefault;
      end;  }
      UpdateFocusedRecord;
      ChangeResInfo;
      //sBar.Panels[1].Text := 'TTL ' + IntToStr(vGrid.DataController.RecordCount);
    end else
    begin
      //dsTags.Hide;
      bbStartList.Caption := lang('_STARTLIST_');
      bbStartPics.Caption := lang('_STARTPICS_');
      bbStartList.Enabled := false;
      bbStartPics.Enabled := false;
      //pcTables.Options := pcTables.Options - [pcoCloseButton];
      dsTags.Hide;
    end;
  end;
end;

procedure Tmf.PicInfo(Sender: TObject; a: TTPicture);
var
  i: integer;
  //r: TcxEditorRow;

function VrType(a: variant): TFieldType;
begin
  case VarType(a) of
    varInteger,varInt64: Result := ftNumber;
    varBoolean: Result := ftCheck;
    varUString,varDate: Result := ftString;
    varDouble: Result := ftFloatNumber;
    else Result := ftString;
  end;
end;

begin
  if Sender = nil then
    CurPic := nil
  else if ((pcTables.ActivePage as tMycxTabSheet).MainFrame <> Sender)
     or (CurPic = a) then
    Exit
  else
    CurPic := a;

  if CurPic = nil then
  begin
    vgCurMain.ClearRows;
    chlbTags.Clear;
    Exit;
  end;

  vgCurMain.BeginUpdate;
  try
    vgCurMain.ClearRows;
    dm.CreateField(vgCurMain,'vgiRName',lang('_RESNAME_'),'',ftString,nil,
      a.Resource.Name,true);
    dm.CreateField(vgCurMain,'vgiName',lang('_FILENAME_'),'',ftString,nil,
      a.PicName + '.' + a.Ext,true);
    dm.CreateField(vgCurMain,'vgiSavePath',lang('_SAVEPATH_'),'',ftPathText,nil,
      a.FileName,true);
    for i := 0 to a.Meta.Count -1 do
      with a.Meta.Items[i] do
        dm.CreateField(vgCurMain,'avgi' + Name,Name,
          '',VrType(Value),nil,VarToStr(Value),true);
  finally
    vgCurMain.EndUpdate;
  end;

  chlbTags.Items.BeginUpdate;
  try
  chlbTags.Clear;

  for i := 0 to a.Tags.Count-1 do
    chlbTags.AddItem(a.Tags[i].Name + ' (' + IntTOStr(a.Tags[i].Linked.Count) + ')');

  finally
    chlbTags.Items.EndUpdate;
  end;
end;

procedure Tmf.RefreshResInfo(Sender: TObject);
var
  i: integer;
  c: TcxEditorRow;
begin

    //vgTagsMain.ClearRows;
    if (pcTables.ActivePage is TMycxTabSheet)
    and ((pcTables.ActivePage as TMycxTabSheet).MainFrame is tfGrid) then
    with ((pcTables.ActivePage as TMycxTabSheet).MainFrame as tfGrid) do
    begin
    //for i := 0 to ResList.Count -1 do
      if (Sender is TResource) then
      begin
        i := ResList.IndexOf(Sender);
        if i = -1 then
          Exit;

        vgTagsMain.BeginUpdate;
        try
          c := (vgTagsMain.RowByName('vgT' + IntToStr(i)) as  TcxEditorRow);
          c.Properties.Value :=
            ifn(ResList.ListFinished,
            ifn(ResList.PicsFinished,'',   //if pics
            IntToStr(ResList[i].PictureList.PicCounter.FSH
                     +ResList[i].PictureList.PicCounter.SKP
                     +ResList[i].PictureList.PicCounter.UNCH)
            + '/' + IntToStr(ResList[i].PictureList.Count)
            + ifn(ResList[i].PictureList.PicCounter.ERR > 0,
            ' err ' + IntToStr(ResList[i].PictureList.PicCounter.ERR),'')),

            IntToStr(ResList[i].JobList.OkCount) + '/'    //if pages
            + IntToStr(ResList[i].JobList.Count)
            + ' (' + IntToStr(ResList[i].HTTPRec.Theor) + ')'
            + ifn(ResList[i].JobList.ErrorCount > 0,
            ' err ' + IntToStr(ResList[i].JobList.ErrorCount),''));

            c.Visible :=
              ifn(ResList.ListFinished,
              ifn(ResList.PicsFinished,true,
                not(ResList[i].PictureList.PicCounter.FSH
                    +ResList[i].PictureList.PicCounter.SKP
                    +ResList[i].PictureList.PicCounter.UNCH
                    =ResList[i].PictureList.Count)),
                 not(ResList[i].JobList.OkCount
                     = ResList[i].JobList.Count));
        finally
          vgTagsMain.EndUpdate;
        end;
      end;

    end;
end;

procedure Tmf.RefreshTags(Sender: TObject; t: TPictureTagLinkList);
var
  l,i: integer;
  ACheckItem: TcxCheckListBoxItem;
  //t: tpicturetaglinklist;
begin
  if (pcTables.ActivePage is TMycxTabSheet)
  and ((pcTables.ActivePage as TMycxTabSheet).MainFrame = Sender) then
  with ((pcTables.ActivePage as TMycxTabSheet).MainFrame as tfGrid) do
  begin
    chlbFullTags.Items.BeginUpdate;
    try
    //chlbFullTags.Clear;

      //t := (sender as tpicturetaglist);
      l := t.Count-1;
      for i := 0 to l do
        //if (n < chlbFullTags.Items.Count)and(chlbFullTags.Items[n].Tag = Integer(ResList.PictureList.Tags[i])) then
        if (t[i].Tag > -1) then
          //if (t[i].Tag < chlbFullTags.Items.Count)
          //and(chlbFullTags.Items[t[i].Tag].Tag = Integer(
          //ResList.PictureList.Tags[t[i].Tag])) then
          if (ResList.PictureList.Tags[t[i].Tag].Tag <> 0) then
          begin
            ACheckItem := TcxCheckListBoxItem(ResList.PictureList.Tags[t[i].Tag].Tag);
            ACheckItem.Text := ResList.PictureList.Tags[t[i].Tag].Name +
              ' (' + IntToStr(ResList.PictureList.Tags[t[i].Tag].Linked.Count) + ')';
          end else
          begin
            ACheckItem := chlbFullTags.Items.Insert(t[i].Tag) as TcxCheckListBoxItem;
            ACheckItem.Text := ResList.PictureList.Tags[t[i].Tag].Name + ' (' + IntToStr(ResList.PictureList.Tags[t[i].Tag].Linked.Count) + ')';
            ACheckItem.Tag := Integer(ResList.PictureList.Tags[t[i].Tag]);
            ResList.PictureList.Tags[t[i].Tag].Tag := Integer(ACheckItem);
          end;

    finally
      chlbFullTags.Items.EndUpdate;
    end;
  end;
end;

procedure Tmf.ApplicationEvents1Exception(Sender: TObject; E: Exception);
begin
  OnError(Sender,E.Message);
end;

procedure Tmf.APPLYNEWLIST(var Msg: TMessage);
var
  n: TMycxTabSheet;
  f: TfNewList;
  f2: TfGrid;
  i: integer;

begin
  n := TMycxTabSheet(Msg.WParam);

  f := n.SecondFrame as tfNewList; //TfNewList(n.Tag);
  f2 := TfGrid.Create(n) as tfGrid;
  f2.CreateList;
  f2.ResList.OnError := OnError;

  f.ResetItems;

  if VarToStr(FullResList[0].Fields['tag']) <> '' then
    n.Caption := FullResList[0].Fields['tag'];

  f2.ResList.OnPageComplete := RefreshResInfo;
  //f2.OnTagUpdate := RefreshTags;

  with f.tvRes.DataController do
    for i := 0 to RecordCount - 1 do
      if Values[i, 0] <> 0 then
        f2.ResList.CopyResource(FullResList[Values[i, 0]]);

  FullResList.OnError := OnError;
  FullResList.OnJobChanged := nil;

  FreeAndNil(n.SecondFrame);
  f2.Reset;
  n.MainFrame := f2;
  f2.Parent := n;
  f2.ResList.ThreadHandler.Cookies := FCookie;
  f2.ResList.DWNLDHandler.Cookies := FCookie;
  f2.OnPicChanged := PicInfo;
  f2.SetSettings;
  f2.SetLang;

  f2.ResList.StartJob(JOB_LIST);
  //f2.vd.Open;
  ShowPanels;
end;

procedure Tmf.APPLYSETTINGS(var Msg: TMessage);
var
  // n: TdxDockPanel;
  f: TfSettings;
begin
  f := SttPanel.MainFrame as tfSettings;
  SaveProfileSettings;
  f.OnClose;
  CloseTab(SttPanel as TcxTabSheet);
  // SttPanel := nil;
end;

procedure Tmf.bbNewClick(Sender: TObject);
begin
  PostMessage(Handle,CM_NEWLIST,0,0);
end;

procedure Tmf.bbSettingsClick(Sender: TObject);
begin
  PostMessage(Handle,CM_SHOWSETTINGS,0,0);
end;

procedure Tmf.bbStartListClick(Sender: TObject);
var
  f: TFrame;

begin
  f := TFrame((pcTables.ActivePage as TMycxTabSheet).MainFrame);
  if f is TfGrid then
    with (f as TfGrid) do
    begin
      vGrid.DataController.Post;
      if ResList.ListFinished then
      begin
        SetSettings;
        ResList.StartJob(JOB_LIST);
      end else
        ResList.StartJob(JOB_STOPLIST);
    end;
end;

procedure Tmf.bbStartPicsClick(Sender: TObject);
var
  f: TFrame;

begin
  f := TFrame((pcTables.ActivePage as TMycxTabSheet).MainFrame);
  if f is TfGrid then
    with (f as TfGrid) do
    begin
      //vGrid.DataController.Post;
      if ResList.PicsFinished then
      begin
        SetSettings;
        //vGrid.BeginUpdate;
        //try
        //  ResList.PictureList.CheckExists;
          UpdateChecks;
        //finally
        //  vGrid.EndUpdate;
        //end;
        if GlobalSettings.Downl.AutoUncheckInvisible then
          UncheckInvisible;
        ResList.StartJob(JOB_PICS);
      end else
        ResList.StartJob(JOB_STOPPICS);
    end;
end;

procedure Tmf.CANCELNEWLIST(var Msg: TMessage);
var
  n: TMycxTabSheet;
  //f: TfNewList;

begin
  n := Pointer(Msg.WParam);
//  FreeAndNil(n.SecondFrame);
  FullResList.OnError := OnError;
  FullResList.OnJobChanged := nil;
  CloseTab(n);
end;

procedure Tmf.CANCELSETTINGS(var Msg: TMessage);
var
  f: TfSettings;

begin
  // n := Pointer(Msg.WParam);
  f := SttPanel.MainFrame as TfSettings;
  f.OnClose;
//  f.Free;
  CloseTab(SttPanel);
end;

procedure Tmf.ChangeResInfo;
var
  i: integer;
  c: TcxEditorRow;
  ACheckItem: TcxCheckListBoxItem;
begin
    vgTagsMain.ClearRows;
    if (pcTables.ActivePage is TMycxTabSheet)
    and ((pcTables.ActivePage as TMycxTabSheet).MainFrame is tfGrid) then
    with ((pcTables.ActivePage as TMycxTabSheet).MainFrame as tfGrid) do
    begin
      vgTagsMain.BeginUpdate;
      try
        for i := 0 to ResList.Count -1 do
        begin
          c := dm.CreateField(vgTagsMain,'vgT' + IntToStr(i),ResList[i].Name,
          '',ftString,nil,
            ifn(ResList.ListFinished,
            ifn(ResList.PicsFinished,'',   //if pics
            IntToStr(ResList[i].PictureList.PicCounter.FSH
                     +ResList[i].PictureList.PicCounter.SKP
                     +ResList[i].PictureList.PicCounter.UNCH)
            + '/' + IntToStr(ResList[i].PictureList.Count)
            + ifn(ResList[i].PictureList.PicCounter.ERR > 0,
            ' err ' + IntToStr(ResList[i].PictureList.PicCounter.ERR),'')),

            IntToStr(ResList[i].JobList.OkCount) + '/'    //if pages
            + IntToStr(ResList[i].JobList.Count)
            + ' (' + IntToStr(ResList[i].HTTPRec.Theor) + ')'
            + ifn(ResList[i].JobList.ErrorCount > 0,
            ' err ' + IntToStr(ResList[i].JobList.ErrorCount),''))
            ,true);

          c.Visible :=
            ifn(ResList.ListFinished,
            ifn(ResList.PicsFinished,true,
              not(ResList[i].PictureList.PicCounter.FSH
                  +ResList[i].PictureList.PicCounter.SKP
                  +ResList[i].PictureList.PicCounter.UNCH
                  =ResList[i].PictureList.Count)),
               not(ResList[i].JobList.OkCount
                   = ResList[i].JobList.Count));
        end;
      finally
        vgTagsMain.EndUpdate;
      end;

      chlbFullTags.Items.BeginUpdate;
      try
      chlbFullTags.Clear;

      for i := 0 to ResList.PictureList.Tags.Count-1 do
      begin
        ACheckItem := chlbFullTags.Items.Add;
        ACheckItem.Text := ResList.PictureList.Tags[i].Name + ' (' + IntToStr(ResList.PictureList.Tags[i].Linked.Count) + ')';
        ACheckItem.Tag := Integer(ResList.PictureList.Tags[i]);
        ResList.PictureList.Tags[i].Tag := Integer(ACheckItem);
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
  t.ListURL := GlobalSettings.UPDServ;
  lupd.Show;
  lupd.BringToFront;
  SetEvent(t.Event);
end;

procedure Tmf.ENDJOB(var Msg: TMessage);
{var
  t: TMycxTabSheet; }
begin
  pcTables.Change;
{  t := TMycxTabSheet(Msg.WParam);
  t.SetIcon(0); }
end;

procedure Tmf.UPDATECHECK(var Msg: TMessage);
begin
  lupd.Hide;
  case MSG.WParam of
    0: CheckUpdates;
    1:
      if MessageDLG(lang('_NEWUPDATES_'),mtConfirmation,[mbYes,mbNo],0) = mrYes then
        StartUpdate;
  end;
  ;
end;

procedure Tmf.STARTJOB(var Msg: TMessage);
{var
  t: TMycxTabSheet;  }
begin
  pcTables.Change;
{  t := TMycxTabSheet(Msg.WParam);
  t.SetIcon(0,15,true); }
end;

procedure Tmf.LANGUAGECHANGED(var Msg: TMessage);
var
  i: integer;
begin
  //LoadLang(IncludeTrailingPathDelimiter(ExtractFilePath(paramstr(0))
  //+ 'languages') + langname+'.ini');
  CreateLangINI(IncludeTrailingPathDelimiter(ExtractFilePath(paramstr(0))
  + 'languages') + langname+'.ini');

  SetLang;

  for i := 0 to pcTables.PageCount-1 do
    if pcTables.Pages[i] is tMycxTabSheet then
      with (pcTables.Pages[i] as tMycxTabSheet) do
      begin
        if Assigned(MainFrame) then
          if MainFrame is tfGrid then
            (MainFrame as tfGrid).SetLang
          else if MainFrame is tfNewList then
            (MainFrame as tfNewList).SetLang
          else if MainFrame is tfSettings then
            (MainFrame as tfSettings).SetLang;
        if Assigned(SecondFrame) then
          if SecondFrame is tfNewList then
            (SecondFrame as tfNewList).SetLang;
      end;

  if Assigned(SttPanel) then
    SttPanel.Caption := lang('_SETTINGS_');


end;

procedure Tmf.WHATSNEW(var Msg: TMessage);
begin
  ShowWhatsNew;
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
      //TdxNavBarSkinNavPanePainter(nvTags).SkinName := dxSkinController.SkinName;
      //TdxNavBarSkinNavPanePainter(nvCur).SkinName := dxSkinController.SkinName;
    finally
      nvTags.EndUpdate;
      nvCur.EndUpdate;
    end;
  end else
  begin
    dxSkinController.UseSkins := false;
    nvTags.View:= 3;
    nvCur.View := 3;
  end;
end;

procedure Tmf.StartUpdate;
var
  f: tfileStream;
  r: tresourcestream;
begin
  f := tfilestream.Create(IncludeTrailingPathDelimiter(rootdir)
    + 'NPUpdater.exe',fmCreate);
  try
    r := tresourcestream.Create(hInstance,'ZUPDATER','UPDATER');
    try
      r.SaveToStream(f);
    finally
      r.Free;
    end;
  finally
    f.Free;
  end;

  ShellExecute(Handle, 'open',PWidechar(IncludeTrailingPathDelimiter(rootdir)
    + 'NPUpdater.exe'), nil, nil, SW_SHOWNORMAL);
  Close;
end;

procedure Tmf.testoClick(Sender: TObject);
begin
  fmAbout.Show;
end;

function Tmf.CloseAllTabs: boolean;
var
  i: integer;
begin
  i := pcTables.PageCount;
  while i > 0 do
  begin
    CloseTab(pcTables.Pages[0]);
    if pcTables.PageCount = i then
    begin
      Result := false;
      exit;
    end else
      i := pcTables.PageCount;
  end;
  Result := true;
end;

procedure Tmf.CloseTab(t: TcxTabSheet);
var
  f: TFrame;
begin
  // pcTables.Tabs
  if t is TMycxTabSheet then
  begin
    f := (t as tMycxTabSheet).MainFrame;
    if f is TfGrid then
    with (f as TfGrid) do
      if not ResList.ListFinished
      or not ResList.PicsFinished then
      begin
        MessageDlg(lang('_TAB_IS_BUSY_'),mtError,[mbOk],0);
        Exit;
      end else
        Relise;
    if (t as tMycxTabSheet).SecondFrame is tfNewList then
    begin
      FullResList.OnError := OnError;
      FullResList.OnJobChanged := nil;
    end;
{    f := (t as tMycxTabSheet).MainFrame;
    if f is TfNewList then
    begin
      PostMessage(Handle, CM_CANCELNEWLIST, Integer(t), 0)
    end;      }
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

function Tmf.CreateTab(pc: TcxPageControl; Enc: boolean): TMycxTabSheet;
var
  n: TMycxTabSheet;

begin
  if Assigned(mFrame) then
    FreeAndNil(mFrame);

  n := TMycxTabSheet.Create(Self);
  //n.ImageIndex := 0;
  n.Caption := lang('_NEWTABCAPTION_') + IntToStr(TabList.Count + 1);
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
//    pc.Change;
    TabList.Add(n);
  end;
  Result := n;

  ShowDs;
end;

procedure Tmf.cxSpinEdit1PropertiesEditValueChanged(Sender: TObject);
begin
  pcTables.ActivePage

end;

procedure Tmf.DockManagerActiveDockControlChanged(Sender: TObject);
begin

end;

{procedure Tmf.dxTabClose(Sender: TdxCustomDockControl);
begin
  PostMessage(Application.MainForm.Handle, CM_CLOSETAB, integer(Sender), 0);
end;   }

procedure Tmf.Setlang;
begin
  {$IFDEF NEKODEBUG}
  Caption := FoldCaption + ' ' + VINFO.FileVersion + 'α debug';
  {$ELSE}
  Caption := FoldCaption + ' ' + VINFO.FileVersion + 'α';
  {$ENDIF}
  bbNew.Caption := lang('_NEWLIST_');
  bbStartList.Caption := lang('_STARTLIST_');
  bbStartPics.Caption := lang('_STARTPICS_');
  bbSettings.Caption := lang('_SETTINGS_');
  dpLog.Caption := lang('_LOG_');
  dpErrors.Caption := lang('_ERRORS_');
  dpTags.Caption := lang('_COMMON_');
  dpCurTags.Caption := lang('_INFO_');
  nbgCurMain.Caption := lang('_GENERAL_');
  nbgTagsMain.Caption := lang('_GENERAL_');
  nbgCurTags.Caption := lang('_TAGS_');
  nbgTagsTags.Caption := lang('_TAGS_');
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
  PicInfo(nil,nil);
  if not dsLogs.AutoHide then
    dsLogs.Visible := true;
end;

procedure Tmf.SHOWSETTINGS(var Msg: TMessage);
var
  // n: TdxDockPanel;
  f: TfSettings;

begin
  if Assigned(SttPanel) then
  begin
    pcTables.ActivePage := SttPanel;
    Exit;
  end;

  if pcTables.PageCount = 0 then
  begin
    pcTables.HideTabs :=  true;
    //dpLog.Visible := false;
    //dpErrors.Visible := false;
  end;


  SttPanel := CreateTab(pcTables, false);
  SttPanel.ImageIndex := 1;
  SttPanel.Caption := lang('_SETTINGS_');

  f := TfSettings.Create(SttPanel);
  FullResList.OnError := f.OnErrorEvent;
  FulLResList.OnJobChanged := f.JobStatus;
  f.OnError := OnError;
  f.SetLang;
  f.CreateResources;
{  dxSkinController.
  f.cbSkin.Properties.Items.Assign();   }
  f.LoadSettings;
{  f.GetLanguages;

  with f, GlobalSettings do
  begin
    chbProxy.Checked := Proxy.UseProxy;
    eHost.Text := Proxy.Host;
    ePort.Value := Proxy.Port;
    chbProxyAuth.Checked := Proxy.Auth;
    eProxyLogin.Text := Proxy.Login;
    eProxyPassword.Text := Proxy.Password;
    chbProxySavePWD.Checked := Proxy.SavePWD;

    eThreads.Value := Downl.ThreadCount;
    eRetries.Value := Downl.Retries;
    //chbDebug.Checked := Downl.Debug;

    chbUseThreadPerRes.Checked := Downl.UsePerRes;
    eThreadPerRes.EditValue := Downl.PerResThreads;
    ePicThreads.EditValue := Downl.PicThreads;

  end;                }

  //f.Tag := integer(SttPanel);
  SttPanel.MainFrame := f;
  //SttPanel.Tag := integer(f);
  f.ResetButons;
  f.Parent := SttPanel;
  ShowDs;
end;

procedure Tmf.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  GlobalSettings.GUI.FormState := WindowState <> wsNormal;
  GlobalSettings.GUI.PanelPage := dsTags.ActiveChildIndex;
  GlobalSettings.GUI.PanelWidth := dsTags.Width;
  SaveGUISettings([gvSizes]);
end;

procedure Tmf.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := CloseAllTabs;
end;

procedure Tmf.FormCreate(Sender: TObject);
var
  tmp: tMessage;
begin
  FOldCaption := Caption;
{  if GlobalSettings.UseLookAndFeel then
    dxSkinController.NativeStyle := true;  }
  Self.SetBounds(Left,Top,Globalsettings.GUI.FormWidth,
                          Globalsettings.GUI.FormHeight);
  dsTags.ActiveChildIndex := GlobalSettings.GUI.PanelPage;
  dsTags.Width := GlobalSettings.GUI.PanelWidth;
  StyleChanged(tmp);
  //ClientWidth := Globalsettings.GUI.FormWidth;
  //ClientHeight := Globalsettings.GUI.FormHeight;
  if Globalsettings.GUI.FormState then
    WindowState := wsMaximized;

  SetLang;
  //pcTables.OnPageClose := OnTabClose;
  FullResList.OnError := OnError;
  dsFirstShow := true;
  SttPanel := nil;
  FCookie := TMyCookieList.Create;
  FullResList.ThreadHandler.Cookies := FCookie;
  FullResList.ThreadHandler.ThreadCount := GlobalSettings.Downl.ThreadCount;
  FullResList.DWNLDHandler.Cookies := FCookie;
  FullResList.DWNLDHandler.ThreadCount := GlobalSettings.Downl.ThreadCount;

  mFrame := TfStart.Create(Self);
  (mFrame as TfStart).SetLang;
  mFrame.Parent := Self;

  TabList := TList.Create;
  bmbMain.Visible := false;

  dsLogs.AutoHide := true;
  dsLogs.Hide;
  dsTags.Hide;
  CurPic := nil;
  if GlobalSettings.AutoUPD then
    PostMessage(Handle,CM_UPDATE,0,0);
  if GlobalSettings.ShowWhatsNew and GlobalSettings.IsNew then
    PostMessage(Handle,CM_WHATSNEW,0,0);
  //CheckUpdates;
end;

procedure Tmf.FormDestroy(Sender: TObject);
begin
  if Assigned(mFrame) then
    mFrame.Free;
  if Assigned(SttPanel) then
    SttPanel.Free;
  TabList.Free;
  FCookie.Free;
end;

procedure Tmf.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Shift = [ssCtrl])
  and (key = $57 {W})
  and (pcTables.ActivePageIndex <> -1)
  and (SttPanel <> pcTables.ActivePage) then
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

{procedure Tmf.gLevel2GetGridView(Sender: TcxGridLevel;
  AMasterRecord: TcxCustomGridRecord; var AGridView: TcxCustomGridView);

begin
  PostMessage(Handle, CM_EXPROW, integer(AMasterRecord), integer(AGridView));
end;            }

procedure Tmf.HideDs;
begin
  if ds.Visible then
  begin
    ds.Hide;
    dsTags.Hide;
    dsLogs.Hide;
    bmbMain.Visible := false;
    pcTables.HideTabs := false;
    dpLog.Visible := true;
    dpErrors.Visible := true;
    mFrame := TfStart.Create(Self);
    (mFrame as TfStart).SetLang;
    mFrame.Parent := Self;
  end;
end;

end.
