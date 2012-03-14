unit Unit1;

interface

uses {manual}
  Windows, Contnrs, Messages, Graphics, Forms, SysUtils, INIFiles,
  Variants, ShellAPI, MMSystem, Math, clipbrd, DateUtils, idHTTP,
  IdComponent, idCookie, idURI, PNGImage, CCR.EXIF, MyXMLParser,
  PNGIconMaker, SYNCOBJS, DownloadThreads, common, SpTBXSkins,
  {automatic}
  JvComponentBase, JvTrayIcon, ExtCtrls, XPMan, ShellAnimations, Menus,
  AppEvnts, Dialogs, IdAntiFreezeBase, IdAntiFreeze, rpVersionInfo,
  IdBaseComponent, IdCookieManager, ComCtrls, StdCtrls, JvExStdCtrls,
  JvCombobox, JvDriveCtrls, JvToolEdit, Buttons, Controls, CheckLst, JvEdit,
  Mask, JvExMask, Grids, AdvObj, BaseGrid, AdvGrid, TB2Item,
  TB2Dock, TB2Toolbar, Classes, SpTBXItem, SpTBXControls, ImgList,
  SpTBXTabs, SpTBXDkPanels, JvSpin,
  {hacks}
  hacks, IdTCPConnection, IdTCPClient, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL, PlatformDefaultStyleActnCtrls,
  ActnPopup;

type

  { TArrayOfString = array of String; }

  dauthdata = record
    Login, Password: String;
  end;

  // TDoubleArrayOfString = array of array[0..1] of string;

  dPreLItem = record
    Name: String;
    URL: String;
    Preview: String;
    HasTorrent: Boolean;
    AType: String;
    chck: Boolean;
  end;

  TTag = record
    Name: String;
    Count: Integer;
  end;

  TTags = array of TTag;

  tms = (msWAIT, msSTART, msGET, msSKIP, msWORK, msWCOUNT, msFNAME, msOK, msFLS,
    msABRT, msMISS, msERR);

  tmssg = packed record
    key: tms;
    data: PWideChar;
    num: Integer;
    f: Boolean;
  end;

  pmssg = ^tmssg;

  { TAuthor = record
    id: Integer;
    Name: String;
    Count: Integer;
    end; }

  // TAuthors = array of TAuthor;

  TLogProc = procedure(s: string) of object;

  TProgProc = procedure(n: Integer) of object;

  TMyGrid = class(TStringGrid);

  TTBCustomItemAccess = class(TTBCustomItem);
  TSpTBXToolbarAccess = class(TSpTBXToolbar);
  TTBCustomDockableWindowAccess = class(TTBCustomDockableWindow);
  TSpTBXCustomTabSetAccess = class(TSpTBXCustomTabSet);

  TDownloadThread = class(TThread)
  private
    // autoscroll: ^Boolean;
    ThreadQueue: TThreadQueue;
    HTTP: TMyIdHTTP;
    num, errcount, curerrcount, zerocount: Integer;
    // destnum: integer;
    f: TFileStream;
    fname: string;
    CSection: TCriticalSection;
    // FOnProgress: TProgProc;
    // Grd: TAdvStringGrid;
    spth, nformat: string;
    XML: TMyXMLParser;
    createnewdirs, downloadalbums, tagsinfname, origfname, incfname: Boolean;
    savejpegmeta: Boolean;
    dwnld, IntBefGet, IntBefDwnld, IntAftDwnld, fullsize: Boolean;
    // LogErr, updatecaption: TLogProc;
    existingfile: Integer;
    tstart: Integer;
    nxt,tmp: string;
    procedure DwnldHTTPWork(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure DwnldHTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure XMLStartTagEvent(ATag: String; Attrs: TAttrList);
    procedure XMLEmptyTagEvent(ATag: String; Attrs: TAttrList);
    procedure XMLEndTagEvent(ATag: String);
    procedure XMLContentEvent(AContent: String);
    procedure AddToStack;
    procedure ProcStack;
    procedure StackWait;
    procedure StackReset;
    procedure SMSG(m: tms; f: Boolean = false; t: string = '');
  protected
    procedure Execute; override;
  public
    procedure FreeFile;
  end;

  TMainForm = class(TForm)
    VersionInfo: TrpVersionInfo;
    IdAntiFreeze: TIdAntiFreeze;
    AppEvents: TApplicationEvents;
    pmTags: TPopupMenu;
    Copy1: TMenuItem;
    XPManifest: TXPManifest;
    UpdateTimer: TTimer;
    pmTray: TPopupMenu;
    Show1: TMenuItem;
    Close1: TMenuItem;
    Hide1: TMenuItem;
    JvTrayIcon: TJvTrayIcon;
    odList: TOpenDialog;
    sdList: TSaveDialog;
    il: TImageList;
    pcMenu: TSpTBXTabControl;
    tsiPicList: TSpTBXTabItem;
    tsiMetadata: TSpTBXTabItem;
    tsiDownloading: TSpTBXTabItem;
    tsiSettings: TSpTBXTabItem;
    tbiMenuHide: TSpTBXItem;
    tsDownloading: TSpTBXTabSheet;
    ldir: TLabel;
    lIfExists: TLabel;
    btnGrab: TButton;
    chbdownloadalbums: TCheckBox;
    chbcreatenewdirs: TCheckBox;
    cbExistingFile: TComboBox;
    chbTagsIn: TCheckBox;
    edir: TJvDirectoryEdit;
    btnBrowse: TBitBtn;
    btnDefDir: TBitBtn;
    btnLoadDefDir: TBitBtn;
    chbAutoDirName: TCheckBox;
    eAutoDirName: TEdit;
    chbSaveJPEGMeta: TCheckBox;
    chbNameFormat: TCheckBox;
    eNameFormat: TEdit;
    cbTagsIn: TComboBox;
    chbOrigFNames: TCheckBox;
    chbQueryI2: TCheckBox;
    tsMetadata: TSpTBXTabSheet;
    lCntFilter: TLabel;
    btnSelAll: TSpeedButton;
    btnDeselAll: TSpeedButton;
    btnSelInverse: TSpeedButton;
    chbPreview: TCheckBox;
    mPicInfo: TMemo;
    pcTags: TPageControl;
    tsTags: TTabSheet;
    chblTagsCloud: TCheckListBox;
    tsRelated: TTabSheet;
    lbRelatedTags: TListBox;
    eCFilter: TJvSpinEdit;
    tsSettings: TSpTBXTabSheet;
    iLain: TImage;
    gbWindow: TGroupBox;
    chbTrayIcon: TCheckBox;
    chbTaskbar: TCheckBox;
    chbKeepInstance: TCheckBox;
    chbSaveNote: TCheckBox;
    gbWork: TGroupBox;
    lThreads: TLabel;
    lRetries: TLabel;
    eThreadCount: TJvSpinEdit;
    chbOpenDrive: TCheckBox;
    cbLetter: TJvDriveCombo;
    chbdebug: TCheckBox;
    eRetries: TJvSpinEdit;
    gbProxy: TGroupBox;
    chbproxy: TCheckBox;
    chbauth: TCheckBox;
    chbsaveproxypwd: TCheckBox;
    eproxyserver: TJvEdit;
    eproxypassword: TJvEdit;
    eproxylogin: TJvEdit;
    eproxyport: TJvSpinEdit;
    GroupBox1: TGroupBox;
    lQueryI: TLabel;
    eQueryI: TJvSpinEdit;
    chbBfGet: TCheckBox;
    chbBfDwnld: TCheckBox;
    chbAftDwnld: TCheckBox;
    tsPicsList: TSpTBXTabSheet;
    lCategory: TLabel;
    lSavedTags: TLabel;
    lSite: TLabel;
    lTags: TLabel;
    lAfterFinish: TLabel;
    chbByAuthor: TCheckBox;
    chbSavedTags: TCheckBox;
    euserid: TJvSpinEdit;
    chbInPools: TCheckBox;
    btnTagEdit: TButton;
    eSavedTags: TJvEdit;
    eTag: TJvEdit;
    btnListGet: TButton;
    cbSite: TComboBox;
    btnCatEdit: TButton;
    eCategory: TJvEdit;
    chbQueryI1: TCheckBox;
    cbAfterFinish: TComboBox;
    splMenu: TSplitter;
    Image1: TImage;
    iIcon: TImage;
    TBControlItem3: TTBControlItem;
    StatusBar: TStatusBar;
    pnlMain: TSpTBXPanel;
    pcLogs: TSpTBXTabControl;
    tsiLog: TSpTBXTabItem;
    tsiErrors: TSpTBXTabItem;
    TBControlItem2: TTBControlItem;
    tbiLogsHide: TSpTBXItem;
    chbShutdown: TSpTBXCheckBox;
    tsLog: TSpTBXTabSheet;
    merrors: TMemo;
    tsErrors: TSpTBXTabSheet;
    mlog: TMemo;
    splLogs: TSplitter;
    pnlGrid: TSpTBXPanel;
    bgimage: TImage;
    Grid: TAdvStringGrid;
    lRow: TLabel;
    tbdGrid: TSpTBXDock;
    tbGrid: TSpTBXToolbar;
    tbsiCheck: TSpTBXSubmenuItem;
    tbiCheckAll: TSpTBXItem;
    tbiCheckSelected: TSpTBXItem;
    tbiCheckByKeyword: TSpTBXItem;
    tbiCheckByTags: TSpTBXItem;
    tbiCheckInverse: TSpTBXItem;
    tbsiUncheck: TSpTBXSubmenuItem;
    tbiUncheckAll: TSpTBXItem;
    tbiUncheckSelected: TSpTBXItem;
    tbiUncheckByKeyword: TSpTBXItem;
    tbiUncheckByTags: TSpTBXItem;
    tbs1: TSpTBXSeparatorItem;
    tbiPrevious: TSpTBXItem;
    tbiNext: TSpTBXItem;
    tbs2: TSpTBXSeparatorItem;
    tbiGoto: TSpTBXItem;
    tbras: TSpTBXRightAlignSpacerItem;
    TBControlItem1: TTBControlItem;
    chbautoscroll: TSpTBXCheckBox;
    tbiClose: TSpTBXItem;
    tbiMaximize: TSpTBXItem;
    tbiMinimize: TSpTBXItem;
    tbiSave: TSpTBXItem;
    tbiLoad: TSpTBXItem;
    tbrasMenu: TSpTBXRightAlignSpacerItem;
    tbrasLogs: TSpTBXRightAlignSpacerItem;
    tbiGridClose: TSpTBXItem;
    pnlPBar: TSpTBXPanel;
    btnBrBrowse: TBitBtn;
    btnCancel: TButton;
    iStatIcon: TImage;
    prgrsbr: TProgressBar;
    chbIncFNames: TCheckBox;
    btnAuth1: TBitBtn;
    btnAuth2: TBitBtn;
    cbByAuthor: TComboBox;
    lblCaption: TSpTBXLabelItem;
    SpTBXItem1: TSpTBXItem;
    btnFindTag: TSpeedButton;
    fdTag: TFindDialog;
    chbFullSize: TCheckBox;
    Label1: TLabel;
    eConnTimeOut: TJvSpinEdit;
    Label2: TLabel;
    eContTimeOut: TJvSpinEdit;
    OpSSLHandler: TIdSSLIOHandlerSocketOpenSSL;
    pabOptionsList: TPopupActionBar;
    bOptions: TButton;
    InGalleriesNames1: TMenuItem;
    InGalleriesTags1: TMenuItem;
    N1: TMenuItem;
    Doujinshi1: TMenuItem;
    Manga1: TMenuItem;
    ArtistCG1: TMenuItem;
    GameCG1: TMenuItem;
    Western1: TMenuItem;
    NonH1: TMenuItem;
    Imageset1: TMenuItem;
    Cosplay1: TMenuItem;
    Asianporn1: TMenuItem;
    Misc1: TMenuItem;
    procedure btnBrowseClick(Sender: TObject);
    procedure btnGrabClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnListGetClick(Sender: TObject);
    procedure GridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure cbSiteChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure AppEventsException(Sender: TObject; E: Exception);
    procedure chbdownloadalbumsClick(Sender: TObject);
    procedure chbOpenDriveClick(Sender: TObject);
    procedure chbproxyClick(Sender: TObject);
    procedure chbauthClick(Sender: TObject);
    procedure chbsavepwdClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure chbPreviewClick(Sender: TObject);
    procedure TBXItem2Click(Sender: TObject);
    procedure TBXItem1Click(Sender: TObject);
    procedure TBXItem5Click(Sender: TObject);
    procedure TBXItem3Click(Sender: TObject);
    procedure TBXItem6Click(Sender: TObject);
    procedure TBXItem7Click(Sender: TObject);
    procedure TBXItem8Click(Sender: TObject);
    procedure TBXItem9Click(Sender: TObject);
    procedure TBXItem10Click(Sender: TObject);
    procedure chbAutoScrollClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure UpdateTimerTimer(Sender: TObject);
    procedure TBXItem11Click(Sender: TObject);
    procedure GridKeyDown(Sender: TObject; var key: Word; Shift: TShiftState);
    procedure GridSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure TBXItem12Click(Sender: TObject);
    procedure TBXItem13Click(Sender: TObject);
    procedure GridDblClickCell(Sender: TObject; ARow, ACol: Integer);
    procedure GridGetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: string);
    procedure GridKeyUp(Sender: TObject; var key: Word; Shift: TShiftState);
    procedure GridExit(Sender: TObject);
    procedure GridCheckBoxChange(Sender: TObject; ACol, ARow: Integer;
      State: Boolean);
    procedure GridCanEditCell(Sender: TObject; ARow, ACol: Integer;
      var CanEdit: Boolean);
    procedure chbByAuthorClick(Sender: TObject);
    procedure chbSavedTagsClick(Sender: TObject);
    procedure iLainDblClick(Sender: TObject);
    procedure eCFilterChange(Sender: TObject);
    procedure chbTrayIconClick(Sender: TObject);
    procedure cbTaskBarChange(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure Hide1Click(Sender: TObject);
    procedure Show1Click(Sender: TObject);
    procedure pmTrayPopup(Sender: TObject);
    procedure btnCatEditClick(Sender: TObject);
    procedure JvTrayIconBalloonClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure JvTrayIconClick(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AppEventsRestore(Sender: TObject);
    procedure chbKeepInstanceClick(Sender: TObject);
    procedure chbTaskbarClick(Sender: TObject);
    procedure btnTagEditClick(Sender: TObject);
    procedure btnDefDirClick(Sender: TObject);
    procedure btnLoadDefDirClick(Sender: TObject);
    procedure chbAutoDirNameClick(Sender: TObject);
    procedure chbNameFormatClick(Sender: TObject);
    procedure chbOrigFNamesClick(Sender: TObject);
    procedure pcMenuActiveTabChange(Sender: TObject; TabIndex: Integer);
    procedure btnSelAllClick(Sender: TObject);
    procedure btnDeselAllClick(Sender: TObject);
    procedure btnSelInverseClick(Sender: TObject);
    procedure pcMenuActiveTabChanging(Sender: TObject;
      TabIndex, NewTabIndex: Integer; var Allow: Boolean);
    procedure tbiMenuHideClick(Sender: TObject);
    procedure tbiLogsHideClick(Sender: TObject);
    procedure pcLogsActiveTabChanging(Sender: TObject;
      TabIndex, NewTabIndex: Integer; var Allow: Boolean);
    procedure splLogsCanResize(Sender: TObject; var NewSize: Integer;
      var Accept: Boolean);
    procedure splMenuCanResize(Sender: TObject; var NewSize: Integer;
      var Accept: Boolean);
    procedure splMenuMoved(Sender: TObject);
    procedure tbrasiMenuClick(Sender: TObject);
    procedure tbiCloseClick(Sender: TObject);
    procedure tbiMaximizeClick(Sender: TObject);
    procedure tbiMinimizeClick(Sender: TObject);
    procedure iIconMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tsiPicListDrawCaption(Sender: TObject; ACanvas: TCanvas;
      ClientAreaRect: TRect; State: TSpTBXSkinStatesType;
      var ACaption: WideString; var CaptionRect: TRect;
      var CaptionFormat: Cardinal; IsTextRotated: Boolean;
      const PaintStage: TSpTBXPaintStage; var PaintDefault: Boolean);
    procedure pcMenuMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tbiLoadClick(Sender: TObject);
    procedure tbiSaveClick(Sender: TObject);
    procedure tbiGridCloseClick(Sender: TObject);
    procedure btnAuth1Click(Sender: TObject);
    procedure cbByAuthorChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SpTBXItem1Click(Sender: TObject);
    procedure btnFindTagClick(Sender: TObject);
    procedure fdTagFind(Sender: TObject);
    procedure btnAuth2Click(Sender: TObject);
    procedure bOptionsClick(Sender: TObject);

  private
    FThreadList: TThreadList;
    FAutoScroll, FSavePWD: Boolean;
    FDrive: String;
    FNotMaximizedWidth: Integer;
    FNotMaximizedHeight: Integer;
    IconMaker: TPNGIconMaker;
    tstart, npp: Integer;
    DefFolder: string;
    hit: Boolean;
    hitcheck, xml_tmpi: Integer;
    xml_li: Boolean;
    tmp, tmpurl, nxt: string;
    FThreadQueue: TThreadQueue;
    GLISTANIM: TImageList;
    hFileMapObj: THandle;
    FPCMenuOldHeight, FPCLogOldHeight: Integer;
    FPreviousTab: Integer;
    FSHUTDOWN: Boolean;
    FCookies: TMyCookieList;
  protected
    procedure WMMove(var Message: TWMMove); message WM_MOVE;
    procedure WMSize(var Message: TWMSIZE); message WM_SIZE;
    procedure WMSysCommand(var Message: TWMSysCommand); message WM_SYSCOMMAND;
    procedure MSGForceRestore(var Message: TMessage); message MSG_FORCERESTORE;
    procedure MSGUpdateList(var Message: TMessage); message MSG_UPDATELIST;
    procedure CreateParams(var Params: TCreateParams); override;
  public
    AuthData: array [-1 .. RESOURCE_COUNT - 1] of dauthdata;
    CloseAfterFinish: Boolean;
    AutoMode: Boolean;
    AutoSave: Boolean;
    procedure XmlStartTag(ATag: String; Attrs: TAttrList);
    procedure XmlEndTag(ATag: String);
    procedure XmlEmptyTag(ATag: String; Attrs: TAttrList);
    procedure XmlContent(AContent: String);
    procedure HTTPWork(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    { procedure DwnldHTTPWork(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64); }
    procedure HTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    { procedure DwnldHTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64); }
    procedure log(s: string);
    procedure block(nn: Integer; prtype: Integer);
    procedure GridClear;
    function RowCount: Integer;
    procedure LogErr(s: String);
    // procedure GridAdd(s: string; checked: boolean = true);
    procedure saveparams;
    procedure saveoptions;
    procedure loadparams;
    procedure loadoptions;
    function AddN(aurl: string; achck: Boolean = true): Integer;
    procedure GenGrid;
    function CreateHTTP(AType: Integer = 0): TMyIdHTTP;
    procedure ThreadTerminate(Sender: TObject);
    { procedure TagThreadTerminate(Sender: TObject); }
    function CreateThread: TDownloadThread;
    procedure updatecaption(s: string = '');
    procedure InsertN(index: Integer);
    procedure DeleteN(index: Integer);
    procedure updateinterface;
    function GetNInfo(l: Integer): string;
    procedure GenTags;
    procedure GridScroll(var Msg: TWMHScroll);
    procedure GridCheck(v: Boolean);
    procedure GridCheckByKeyword(v: Boolean);
    procedure GridCheckByTag(v: Boolean);
    procedure GridCheckInverse;
    procedure GridCheckSelected(v: Boolean);
    procedure DWNLDProc(n: Integer);
    procedure CategoryPaste(Sender: TObject; var Text: string;
      var Accept: Boolean);
    procedure SetGridState(b: Boolean);
    procedure UpdateDataInterface;
    function Login(iindex: Integer): Boolean;
    procedure LoadFromFile(fname: string);
    procedure SaveToFile(fname: string; tp: Integer; Sender: TObject);
    procedure ForceStop;
    procedure updateskin;
    function UpdLogin(iindex: Integer): boolean;
  end;

var
  MainForm: TMainForm;
  curdest: Integer = -2;
  FSection: TCriticalSection;

function AddTags(s: String; spr: char = ' '): TArrayOfWord;
function extracttags2(s: TTags): String;
procedure ImportTags(src: String; var dst: TTags); overload;
function TagString(s: TArrayOfWord): String;
procedure CountTags(s: TArrayOfWord);
procedure ClearTags;

implementation

uses Unit3, Unit4, stoping_u, Unit5, AboutForm, md5;
{$R *.dfm}

var
  prgress: Integer = 0;
  prtype: Integer = -1;
  nm: Integer;
  n: array of drec;
  PreList: array of dPreLItem;
  curLain: byte;
  curPreItem: Integer;
  nok, nerr, nmiss, nskip, ncmpl, nsel: LONGWORD;
  curtag: string = '';
  curcategory: string = '';
  curByAuthor: Boolean = false;
  curInPools: Boolean = false;
  curuserid: Integer = -1;
  cpt: string;
  // mdown: Boolean = false;
  threadnum: byte = 0;
  loading: Boolean = false;
  saved: Boolean;
  finished: Boolean = true;
  gettags: Boolean = false;
  tags: TTags = nil;
  // Authors: TAuthors;

  // common

function GetCurrentGMT: TDateTime;
var
 y: TSystemTime;
begin
  GetSystemTime(y);
  result := SystemTimeToDateTime(y);
end;

function AddTags(s: String; spr: char = ' '): TArrayOfWord;

var
  i: Integer;
  s2: string;

begin
  result := nil;
  s := ClearHTML(trim(s, spr));
  while s <> '' do
  begin
    s2 := trim(GetNextS(s, spr));
    for i := 0 to Length(tags) - 1 do
      if lowercase(s2) = lowercase(tags[i].Name) then
      begin
        inc(tags[i].Count);
        Addsrtdd(result, i);
        s2 := '';
        Break;
      end;
    if s2 <> '' then
    begin
      SetLength(tags, Length(tags) + 1);
      with tags[Length(tags) - 1] do
      begin
        Name := s2;
        Count := 1;
      end;
      Addsrtdd(result, Length(tags) - 1);
    end;
  end;
end;

function extracttags2(s: TTags): String;
var
  i, l: Integer;
begin
  result := '';
  l := Length(s) - 1;
  for i := 0 to l do
    result := result + '"' + StringEncode(s[i].Name) + '" ';
end;

procedure ImportTags(src: String; var dst: TTags);
var
  s: string;
begin
  SetLength(dst, 0);
  while src <> '' do
  begin
    s := StringDecode(trim(GetNextS(src, ' ', '"'), '"'));
    SetLength(dst, Length(dst) + 1);
    with dst[Length(dst) - 1] do
    begin
      Name := s;
      Count := 0;
    end;
  end;
end;

function TagString(s: TArrayOfWord): String;
var
  i, l: Integer;
begin
  result := '';
  l := Length(s) - 1;
  for i := 0 to l do
    if result <> '' then
      result := result + ' ' + tags[s[i]].Name
    else
      result := tags[s[i]].Name;
end;

procedure CountTags(s: TArrayOfWord);
var
  i: Integer;
begin
  for i := 0 to Length(s) - 1 do
    inc(tags[s[i]].Count);
end;

procedure ClearTags;
var
  i, n: Integer;
begin
  n := 0;
  for i := 0 to Length(tags) - 1 do
    if tags[i].Count < 1 then
      inc(n)
    else if n > 0 then
      tags[i - n] := tags[i];
  SetLength(tags, Length(tags) - n);
end;

// TDownloadThread

procedure TDownloadThread.SMSG(m: tms; f: Boolean = false; t: string = '');
var
  Msg: pmssg;
begin
  New(Msg);
  // FillChar(msg,SizeOf(msg),0);
  Msg^.key := m;
  Msg^.num := num;
  if t <> '' then
    Msg^.data := PWideChar(t);
  Msg^.f := f;
  SendMessage(MainForm.Handle, MSG_UPDATELIST, 0, Integer(Msg));
end;

procedure TDownloadThread.Execute;

  function ISJPG(s: string): Boolean;
  begin
    s := UPPERCASE(s);
    result := (s = '.JPG') or (s = '.JPEG');
  end;

  function GetTagString(intTags: TArrayOfWord; ignore: array of string; del: char = ';';
    emp: char = ' '): string;
  var
    i, j, l: Integer;
    s: string;
  begin
    result := '';
    l := Length(intTags) - 1;
    for i := 0 to l do
    begin
      s := tags[intTags[i]].Name;
      for j := 0 to length(ignore) do
        if pos(ignore[j],s) = 1 then
          Continue;

      REPLACE(s, del, emp, false, true);
      if i < l then
        result := result + s + del
      else
        result := result + s;
    end;
  end;

  function chb(const b: Boolean; const s1, s2: string): string;
  begin
    if b then
      result := s1
    else
      result := s2;
  end;

  function chs(const s: string; a1, a2: string): string;
  begin
    if s = '' then
      result := s
    else
      result := a1 + s + a2;
  end;

  function FileExistsEx(fname: string): Boolean;
  begin
    result := fileexists(fname + '.jpeg') or fileexists(fname + '.png') or
      fileexists(fname + '.gif') or fileexists(fname + '.bmp');
  end;

var
  j: Integer;
  xcp: byte;
  o, es, expth, tagstr, formatdir: string;
  s: String;
  c: Boolean;
  EXIF: TEXIFDATA;
  arr: array [0 .. 10] of byte;
  ans: ANSIString;
begin
  try
    tstart := 8;
    EXIF := TEXIFDATA.Create;
    //CSection := TCriticalSection.Create;

    while (nm < Length(n)) and (prgress = 0) do
    begin
      num := nm;
      inc(nm);

      curerrcount := 0;

      if not(prgress = 0) then
        Break;

      if not n[num].chck then
      begin
        SMSG(msSKIP);
        continue;
      end;

      HTTP.Tag := num;

      case curdest of
        RP_IMOUTO, RP_KONACHAN, RP_DEVIANTART:
          xcp := 0;
        RP_EHENTAI_G, RP_EXHENTAI, RP_RMART:
          xcp := 4;
      else
        xcp := 1;
      end;

      case curdest of
        RP_BEHOIMI, RP_PIXIV, RP_PAHEAL_RULE34, RP_PAHEAL_RULE63,
          RP_PAHEAL_COSPLAY, RP_TENTACLERAPE:
          HTTP.Request.Referer := RESOURCE_URLS[curdest] + n[num].pageurl;
        RP_EHENTAI_G, RP_EXHENTAI:
          HTTP.Request.Referer := n[num].URL;
      else
        HTTP.Request.Referer := '';
      end;

      if curdest in [RP_EHENTAI_G, RP_EXHENTAI] then
      begin
        if IntBefGet then
        begin
          SMSG(msWAIT);
          Synchronize(AddToStack);
          if (prgress = 0) then
            Synchronize(StackWait);

          if not(prgress = 0) then
          begin
            SMSG(msABRT);
            Break;
          end;
        end;
        SMSG(msGET);

        nxt := '';
        tmp := '';

        s := HTTP.Get(n[num].URL);
        if HTTP.Connected then
          HTTP.Disconnect;

        CSection.Enter;
        CSection.Leave;

        if not(prgress = 0) then
        begin
          SMSG(msABRT);
          Break;
        end;

        Synchronize(ProcStack);

        XML.Parse(s);

        o := ClearHTML(nxt);

        if o = '' then
        if pos('Your IP address has been temporarily banned',s) > 0 then
        begin
          SMSG(msERR,true,n[num].URL + ': Empty pic url' + #13#10 + s);
          prgress := 2;
          //Continue;
        end else if pos('You are opening pages too fast',s) > 0 then
        begin
          SMSG(msERR,true,'You are opening pages too fast, thus placing a ' +
          'heavy load on the server. Back down, or your IP address will be ' +
          'automatically banned.');
          prgress := 2;
          //Continue;
        end else
        begin
          SMSG(msERR,true,n[num].URL + ': Empty pic url' + #13#10 + s);
          //Continue;
        end;

{        if tmp <> '' then
          o := ClearHTML(tmp); }

      end
      else
        o := n[num].URL;

        if not(prgress = 0) then
        begin
          SMSG(msABRT);
          Break;
        end;

      expth := spth;
      formatdir := '';

      c := false;
      j := 0;
      es := '';
      if tagsinfname then
      begin
        tagstr := ' ' + ValidFName(GetTagString(n[num].tags, ['rating:'],' ', '_'))
      end
      else
        tagstr := '';

      f := nil;

      while true do
        try
          if createnewdirs then
          begin
            CSection.Enter;
            try
              if curdest = RP_PIXIV then
                if c then
                begin
                  if (j = 0) then
                  begin
                    if nformat = '' then
                    begin
                      es := ChangeFileExt(emptyname(n[num].URL), '') + '\';
                      CreateDirExt(expth + es);
                    end
                    else
                      es := ChangeFileExt(ExtractFileName(fname), '') + '\';
                  end;
                end
                else
              else if curdest in RS_GALLISTS then
              begin
                es := ValidFName(ClearHTML(n[num].Params)) + '\';
                CreateDirExt(expth + es);
              end
              else if curdest = RP_DEVIANTART then
              begin
                es := REPLACE(DeleteTo(DeleteTo(n[num].category, '://'), '/'),
                  '/', '\', false, true);
                CreateDirExt(expth + es);
              end
              else if (curdest in RS_POOLS) and (n[num].title <> '') then
              begin
                es := ValidFName(ClearHTML(n[num].title)) + '\';
                CreateDirExt(expth + es);
              end;
            finally
              CSection.Leave;
            end;
          end;

          case curdest of
            RP_PIXIV:
              if c then
                o := ChangeFileExt(n[num].URL, '_big_p' + IntToStr(j) +
                  ExtractFileExt(n[num].URL));
            RP_DEVIANTART:
              case xcp of
                0:
                  o := RESOURCE_URLS[curdest] + 'download/' +
                    DownCopyTo('-',n[num].pageurl) +
                    '/' + emptyname(n[num].URL);
              end;
          end;

          if (curdest in [RP_EHENTAI_G, RP_EXHENTAI]) and not origfname then
            fname := expth + es + Copy(ChangeFileExt(emptyname(n[num].URL), '')
              + tagstr, 1, 128 - Length(ExtractFileExt(o))) + ExtractFileExt(o)
          else if curdest in [RP_RMART] then
            fname := expth + es + emptyname(REPLACE(o, '/Src/Image', ''))
          else if tagstr <> '' then
            fname := expth + es + Copy(ChangeFileExt(emptyname(o), '') + tagstr,
              1, 128 - Length(ExtractFileExt(o))) + ExtractFileExt(o)
          else if nformat = '' then
            fname := expth + es + emptyname(o)
          else
          begin
            fname := ValidFName
              (ClearHTML
              (REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(nformat, '?a',
              n[num].Params, false, true), '?l', ExtractFolder(o), false, true),
              '?n', chb(n[num].Params <> '', REPLACE(n[num].title,
              '/' + n[num].Params, ''), n[num].title), false, true), '?i',
              CopyTo(ChangeFileExt(emptyname(o), ''), '_'), false, true),
              '?p' + chs(CopyFromTo(nformat, '?p', '/'), '', '/'),
              chs(CopyFromTo(o, '_p', '.', true), CopyFromTo(nformat, '?p',
              '/'), ''), false, true), '?t', curtag, false, true)), true);
            formatdir := ExtractFilePath(fname);
            fname := spth + formatdir + es + Copy(ExtractFileName(fname), 1,
              128 - Length(ExtractFileExt(o))) + ExtractFileExt(o);
            CreateDirExt(ExtractFileDir(fname));
          end;

          if (curdest in [RP_THEDOUJIN, RP_EHENTAI_G, RP_EXHENTAI]) and
            (incfname) and (n[num].title <> '') then
            fname := ExtractFilePath(fname) + AddZeros(n[num].title, zerocount)
              + '_' + ExtractFileName(fname);

          if (curdest in [RP_EHENTAI_G,RP_EXHENTAI]) and (tmp <> '') then
            o := ClearHTML(tmp);

          CSection.Enter;
          try
            if fileexists(fname) or (curdest in [RP_RMART]) and
              FileExistsEx(fname) then
              if (existingfile = 0) or ((curdest = RP_PIXIV) and c) then
              begin
                if not c then
                begin
                  n[num].chck := false;

                  SMSG(msMISS, true);

                  if (n[num].URL <> o) and
                    not(curdest in [RP_EHENTAI_G, RP_EXHENTAI]) and
                    ((xcp > 1) or (curdest in [RP_IMOUTO])) then
                  begin
                    n[num].URL := o;
                    SMSG(msFNAME);

                  end;
                  Break;
                end
                else
                begin
                  inc(j);
                  continue;
                end;
              end
              else if (existingfile = 1) then
                deletefile(fname)
              else if (existingfile = 2) then
              begin
                j := 2;
                while fileexists(ExtractFilePath(fname) + ExtractFileName(fname)
                  + '(' + IntToStr(j) + ')' + ExtractFileExt(fname)) do
                  inc(j);
                fname := ExtractFilePath(fname) + ExtractFileName(fname) + '(' +
                  IntToStr(j) + ')' + ExtractFileExt(fname);
              end;

            if not(prgress = 0) then
            begin
              CSection.Leave;
              Break;
            end;

            f := TFileStream.Create(fname, fmCreate{ or fmOpenWrite});
          finally
            CSection.Leave;
          end;



          if IntBefDwnld then
          begin
            SMSG(msWAIT);
            Synchronize(AddToStack);
            if (prgress = 0) then
              Synchronize(StackWait);

            if not(prgress = 0) then
            begin
              SMSG(msABRT);
              Break;
            end;
          end;

          SMSG(msSTART);

          dwnld := true;

//          HTTP.Head(o);
//          HTTP.
//          fsize := HTTP.Response.ContentLength;
          HTTP.Get(o, f);
          if HTTP.Connected then
            HTTP.Disconnect;

          dwnld := false;

          if not(prgress = 0) then
          begin
            FreeFile;
            Break;
          end;

          if n[num].work <> f.Size then
            raise Exception.Create('Incorrect File Size: ' + IntToStr(n[num].work) + ' <> ' + IntToStr(f.Size));

          if (prgress = 0) and (curdest in [RP_EHENTAI_G,RP_EXHENTAI]) then
            if (f.Size < 1024) then
            begin
              f.Position := 0;
              SetLength(ans,f.Size);
              f.Read(ans[1],f.Size);
              if ans = 'Insufficient GP' then
              begin
                prgress := 2;
                raise Exception.Create('Can not download fullsizes. Insufficient GP');
              end else if ans = 'You can not access a file directly without specifying a gallery. Please get the full URL for this image.' then
                raise Exception.Create(o + ': ' + ans);
            end else
              {if (f.Size = 28658) and (MD5DigestToStr(MD5Stream(f)) = '88FE16AE482FADDB4CC23DF15722348C') then }
              if (pos('/img/509s.gif',o) > 0)
              or (pos('/img/509.gif',o) > 0) then
              begin
                prgress := 2;
                raise Exception.Create('509 Bandwidth Exceeded. You have temporarily reached the limit how many images you can browse. Wait a few hours or change an account and IP-adress.');
              end;

          if IntAftDwnld then
            Synchronize(StackReset);

          if curdest = RP_RMART then
          begin
            f.Position := 0;
            f.Read(arr[0], SizeOf(arr[0]) * 11);
            fname := ChangeFileExt(fname, ImageFormat(@arr));
            FreeAndNil(f);
            RenameFile(ChangeFileExt(fname, ''), fname);
          end
          else
            FreeAndNil(f);

          try
            if savejpegmeta and ISJPG(ExtractFileExt(fname)) then
            begin
              if curdest = RP_PIXIV then
                EXIF.title :=
                  ClearHTML(chb(n[num].Params <> '', REPLACE(n[num].title,
                  '/' + n[num].Params, ''), n[num].title))
              else
                EXIF.title := ClearHTML(n[num].title);
              EXIF.Keywords := ClearHTML(GetTagString(n[num].tags,['rating:']));
              case curdest of
                RP_DEVIANTART:
                  EXIF.Subject := es;
                RP_EHENTAI_G, RP_EXHENTAI:
                  EXIF.Subject := ClearHTML(n[num].Params);
                RP_PIXIV:
                  EXIF.Author := ClearHTML(n[num].Params);
              else
                EXIF.Subject := '';
              end;

              if pos('://', n[num].pageurl) > 0 then
                EXIF.Comments := ClearHTML(n[num].pageurl)
              else
                EXIF.Comments := RESOURCE_URLS[curdest] +
                  ClearHTML(trim(n[num].pageurl, '/'));
              EXIF.SaveToJPEG(fname);
            end;
          except
          end;

          if not c then
          begin
            if (n[num].URL <> o) and not(curdest in [RP_EHENTAI_G, RP_EXHENTAI])
              and ((xcp > 1) or (curdest in [RP_IMOUTO])) then
            begin
              n[num].URL := o;

              SMSG(msFNAME);

            end;
            n[num].chck := false;
            SMSG(msOK, true);
          end
          else
            SMSG(msOK);

          if c then
            inc(j)
          else
            Break;
        except
          on E: Exception do
          begin
            if HTTP.Connected then
              HTTP.Disconnect;
            FreeFile;
            if pos('404 Not Found', E.Message) > 0 then
            begin
              case xcp of
                0:
                  case curdest of
                    RP_DEVIANTART:
                      o := n[num].URL;
                  else
                    o := REPLACE(n[num].URL, '/image/', '/jpeg/');
                  end;
                1:
                  o := ChangeFileExt(n[num].URL, '.png');
                2:
                  o := ChangeFileExt(n[num].URL, '.gif');
                3:
                  o := ChangeFileExt(n[num].URL, '.jpeg');
                4, 5:
                  if downloadalbums then
                    case curdest of
                      RP_PIXIV:
                        begin
                          case xcp of
                            4:
                              c := true;
                            5:
                              if c then
                                o := REPLACE(o, '_big_p', '_p');
                          end;
                        end;
                    else
                      begin
                        SMSG(msERR, true, 'Line: ' + IntToStr(num) + ', ' +
                          n[num].URL + ' ' + E.Message);
                        Break;
                      end;
                    end
                  else
                  begin
                    SMSG(msERR, true, 'Line: ' + IntToStr(num) + ', ' +
                      n[num].URL + ' ' + E.Message);
                    Break;
                  end
              else
                begin
                  if c and (j > 0) then
                  begin
                    n[num].chck := false;
                    SMSG(msFLS, true, IntToStr(j));
                  end
                  else
                  begin
                    CSection.Enter;
                    try
                      if createnewdirs then
                        removedirectory(PWideChar(expth + es));
                      SMSG(msERR, true, 'Line: ' + IntToStr(num) + ', ' +
                        n[num].URL + ' ' + E.Message);
                    finally
                      CSection.Leave;
                    end;
                  end;
                  Break;
                end;
              end;
              inc(xcp);
            end
            else if (prgress = 0) then
            begin
              if curerrcount < errcount then
                SMSG(msERR, false, 'Line: ' + IntToStr(num) + ', ' + o + ' ' +
                  E.Message + ' retry ' + IntToStr(curerrcount + 1) + ' of ' +
                  IntToStr(errcount))
              else
                SMSG(msERR, true, 'Line: ' + IntToStr(num) + ', ' + o + ' ' +
                  E.Message);
              if curerrcount < errcount then
                inc(curerrcount)
              else
                Break;
            end
            else
              Break;
          end;
        end; // try on e
    end;

    if Assigned(f) then
      FreeAndNil(f);

    if curdest in [RP_EHENTAI_G, RP_EXHENTAI] then
      Synchronize(ProcStack);
    FreeAndNil(HTTP);
    FreeAndNil(XML);
    FreeAndNil(EXIF);
    //FreeAndNil(CSection);
  finally
  end;
end;

procedure TDownloadThread.FreeFile;
begin
  if Assigned(f) then
    FreeAndNil(f);
  if FileExists(fname) then
    DeleteFile(fname);
end;

procedure TDownloadThread.XMLStartTagEvent(ATag: String; Attrs: TAttrList);
begin
  case curdest of
    RP_EHENTAI_G, RP_EXHENTAI:
      if (tstart = 8) then
        if(ATag = 'div') then
          if ((Attrs.Value('class') = 'sn')
          or (Attrs.Value('class') = 'sb') or (Attrs.Value('class') = 'sa')) then
            tstart := 9
          else if fullsize and (Attrs.Value('class') = 'if') then
            tstart := 7
          else
        else
      else if (tstart = 7) and (ATag = 'a') then
      begin
        tstart := 6;
        tmp := Attrs.Value('href');
      end
      else if (tstart > 8) and (ATag = 'div') then
        inc(tstart);
  end;

end;

procedure TDownloadThread.XMLEmptyTagEvent(ATag: String; Attrs: TAttrList);
begin
  case curdest of
    RP_EHENTAI_G, RP_EXHENTAI:
      if (tstart = 8) and (ATag = 'img') and (Attrs.Value('class') = '') then
        nxt := Attrs.Value('src');
{    RP_RMART:
      if (tstart = 8) and (ATag = 'img') and
        (Attrs.Value('class') = 'view-image') then
        nxt := Attrs.Value('src');    }
  end;
end;

procedure TDownloadThread.XMLEndTagEvent(ATag: String);
begin
  case curdest of
    RP_EHENTAI_G, RP_EXHENTAI:
      if (ATag = 'div') then
        if (tstart > 8) then
          dec(tstart)
        else if (tstart = 7) then
          tstart := 8
        else
      else if (Atag = 'a') and (tstart = 6) then
        tstart := 7;

  end;
end;

procedure TDownloadThread.XMLContentEvent(AContent: String);
begin
  if tstart = 6 then
    if pos('download original',lowercase(AContent)) <> 1 then
      tmp := '';
end;

procedure TDownloadThread.AddToStack;
begin
  if not ThreadQueue.AddThread(Self) then
    Suspend;
end;

procedure TDownloadThread.ProcStack;
begin
  ThreadQueue.Proc(not(prgress = 0));
end;

procedure TDownloadThread.StackWait;
begin
  ThreadQueue.Wait;
end;

procedure TDownloadThread.StackReset;
begin
  ThreadQueue.ResetTiming;
end;

procedure TMainForm.WMMove(var Message: TWMMove);
begin
  inherited;
  if assigned(fPreview) and preview_window_drag then
  begin
    SetWindowPos(fPreview.Handle, 0, MainForm.Left + preview_window_left,
      MainForm.Top + preview_window_top, 0, 0, SWP_NOACTIVATE or SWP_NOSIZE);
  end;
end;

procedure TMainForm.WMSize(var Message: TWMSIZE);
begin
  inherited;
  with Message do
    if SizeType <> SIZE_MAXIMIZED then
    begin
      FNotMaximizedWidth := Width;
      FNotMaximizedHeight := Height;
    end;
end;

procedure TMainForm.WMSysCommand(var Message: TWMSysCommand);
begin
  // if Assigned(fPreview) then
  if (Message.CmdType and $FFF0 = SC_MAXIMIZE) then
  begin
    if assigned(fPreview) then
    begin
      tbiMaximize.ImageIndex := 3;
      preview_window_drag := false;
      SetWindowPos(fPreview.Handle, 0, preview_window_undrag_left,
        preview_window_undrag_top, 0, 0, SWP_NOACTIVATE or SWP_NOSIZE);
    end
  end
  else if (Message.CmdType and $FFF0 = SC_RESTORE) and
    (WindowState = wsMaximized) then
  begin
    tbiMaximize.ImageIndex := 1;
    if assigned(fPreview) then
      preview_window_drag := true;
  end;
  inherited;
end;

procedure TMainForm.MSGForceRestore(var Message: TMessage);
begin
  if JvTrayIcon.Active and not JvTrayIcon.ApplicationVisible then
    JvTrayIcon.ShowApplication
  else if WindowState = wsMinimized then
    Application.Restore
  else
    SetForegroundWindow(MainForm.Handle);
end;

procedure TMainForm.MSGUpdateList(var Message: TMessage);
var
  Msg: pmssg;
begin
  // tms = (msWAIT,msSTART,msGET,msSKIP,msWORK,msWCOUNT,msFNAME,msOK,msFLS,msABRT,msMISS,msERR);
  Msg := pmssg(Message.LParam);
  with Msg^ do
    case key of
      msWAIT:
        begin
          Grid.Rows[num + 1][2] := '';
          Grid.Rows[num + 1][3] := '';
          Grid.Rows[num + 1][4] := '';
          Grid.Rows[num + 1][5] := 'WAIT';
        end;
      msSTART:
        begin
          Grid.Rows[num + 1][2] := '';
          Grid.Rows[num + 1][3] := '';
          Grid.Rows[num + 1][4] := '';
          Grid.Rows[num + 1][5] := 'START';
          if (chbautoscroll.Checked) and (Grid.Row < num + 1) then
            Grid.AutoSetRow(num + 1);
        end;
      msGET:
        begin
          Grid.Rows[num + 1][2] := '';
          Grid.Rows[num + 1][3] := '';
          Grid.Rows[num + 1][4] := '';
          Grid.Rows[num + 1][5] := 'GET';
        end;
      msSKIP:
        begin
          Grid.Rows[num + 1][2] := '';
          Grid.Rows[num + 1][3] := '';
          Grid.Rows[num + 1][4] := '';
          Grid.Rows[num + 1][5] := '-';
        end;
      msFNAME:
        Grid.Rows[num + 1][1] := n[num].URL;
      msOK:
        begin
          Grid.Rows[num + 1][2] := '';
          Grid.Rows[num + 1][3] := '';
          Grid.Rows[num + 1][4] := '';
          Grid.Rows[num + 1][5] := 'OK';
          inc(nok);
        end;
      msFLS:
        begin
          Grid.Rows[num + 1][2] := '';
          Grid.Rows[num + 1][3] := '';
          Grid.Rows[num + 1][4] := '';
          Grid.Rows[num + 1][5] := Msg.data + ' FLS';
        end;
      msABRT:
        begin
          Grid.Rows[num + 1][2] := '';
          Grid.Rows[num + 1][3] := '';
          Grid.Rows[num + 1][4] := '';
          Grid.Rows[num + 1][5] := 'ABRT';
        end;
      msMISS:
        begin
          Grid.Rows[num + 1][2] := '';
          Grid.Rows[num + 1][3] := '';
          Grid.Rows[num + 1][4] := '';
          Grid.Rows[num + 1][5] := 'MISS';
          inc(nmiss);
        end;
      msERR:
        begin
          Grid.Rows[num + 1][2] := '';
          Grid.Rows[num + 1][3] := '';
          Grid.Rows[num + 1][4] := '';
          Grid.Rows[num + 1][5] := 'ERR';
          inc(nerr);
          LogErr(Msg.data);
        end;
      msWORK:
        begin
          Grid.Rows[num + 1][2] := GetBtString(n[num].work);
          Grid.Rows[num + 1][4] :=
            GetBtString(n[num].work / Max(MilliSecondsBetween(n[num].wtime,
            Date + Time), 1000) * 1000) + '/s';
          Grid.Rows[num + 1][5] :=
            FloatToStr(RoundTo(diff(n[num].work, n[num].size) * 100, -2)) + '%';
        end;
      msWCOUNT:
        begin
          Grid.Rows[num + 1][2] := '';
          Grid.Rows[num + 1][3] := GetBtString(n[num].size);
        end;
    end;
  if Msg.f then
  begin
    inc(ncmpl);
    if Msg.key <> msERR then
      Grid.SetCheckBoxState(0, Msg.num + 1, false);
  end;
  Dispose(Msg);
  DWNLDProc(ncmpl);
end;

procedure TMainForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    Style := (Style or WS_POPUP) and (not WS_DLGFRAME);
end;

procedure TMainForm.loadoptions;
var
  ini: TINIFile;
  i: Integer;
begin
  ini := TINIFile.Create(ExtractFilePath(paramstr(0)) + 'settings.ini');

  FSavePWD := ini.ReadBool('options', 'savepwd', false);
  // chbsavepath.Checked := ini.ReadBool('options', 'savepath',chbsavepath.Checked);
  cbExistingFile.ItemIndex := ini.ReadInteger('options', 'existingfile',
    cbExistingFile.ItemIndex);
  chbdownloadalbums.Checked := ini.ReadBool('options', 'downloadalbums',
    chbdownloadalbums.Checked);
  chbcreatenewdirs.Checked := ini.ReadBool('options', 'createnewdirs',
    chbcreatenewdirs.Checked);
  { chbDistByAuth.Checked := ini.ReadBool('options', 'distbyauth',
    chbDistByAuth.Checked); }
  chbNameFormat.Checked := ini.ReadBool('options', 'nameformatcheck',
    chbNameFormat.Checked);
  eNameFormat.Text := ini.ReadString('options', 'nameformat', eNameFormat.Text);
  eThreadCount.Value := ini.ReadInteger('options', 'threads',
    eThreadCount.AsInteger);
  chbOpenDrive.Checked := ini.ReadBool('options', 'opendrive',
    chbOpenDrive.Checked);
  FDrive := ini.ReadString('options', 'driveletter', '');
  chbproxy.Checked := ini.ReadBool('proxy', 'enabled', chbproxy.Checked);
  eproxyserver.Text := ini.ReadString('proxy', 'host', eproxyserver.Text);
  eproxyport.Value := ini.ReadInteger('proxy', 'port', eproxyport.AsInteger);
  chbauth.Checked := ini.ReadBool('proxy', 'auth', chbauth.Checked);
  eproxylogin.Text := ini.ReadString('proxy', 'login', eproxylogin.Text);
  chbsaveproxypwd.Checked := ini.ReadBool('proxy', 'savepwd',
    chbsaveproxypwd.Checked);
  eproxypassword.Text := ini.ReadString('proxy', 'pwd', eproxypassword.Text);
  chbPreview.Checked := ini.ReadBool('options', 'showpreview',
    chbPreview.Checked);
  cbAfterFinish.ItemIndex := ini.ReadInteger('options', 'afterend',
    cbAfterFinish.ItemIndex);
  eCFilter.Value := ini.ReadInteger('options', 'cntfilter', eCFilter.AsInteger);
  chbTagsIn.Checked := ini.ReadBool('options', 'tagsincheck',
    chbTagsIn.Checked);
  cbTagsIn.ItemIndex := ini.ReadInteger('options', 'tagsin',
    cbTagsIn.ItemIndex);
  case ini.ReadInteger('options', 'byauthor', -1) of
    - 1:
      begin
        chbByAuthor.Checked := false;
        cbByAuthor.ItemIndex := 0;
      end;
    0:
      begin
        chbByAuthor.Checked := true;
        cbByAuthor.ItemIndex := 0;
      end;
    1:
      begin
        chbByAuthor.Checked := true;
        cbByAuthor.ItemIndex := 1;
      end;
  end;
  chbSavedTags.Checked := ini.ReadBool('options', 'savedtagschecked',
    chbSavedTags.Checked);
  eSavedTags.Text := StringDecode(ini.ReadString('options', 'savedtags',
    eSavedTags.Text));
  chbTrayIcon.Checked := ini.ReadBool('options', 'trayicon',
    chbTrayIcon.Checked);
  chbTaskbar.Checked := ini.ReadBool('options', 'taskbar', chbTaskbar.Checked);
  chbKeepInstance.Checked := ini.ReadBool('options', 'keepinstance',
    chbKeepInstance.Checked);
  chbSaveNote.Checked := ini.ReadBool('options', 'savenote',
    chbSaveNote.Checked);

  chbAutoDirName.Checked := ini.ReadBool('options', 'autodirname',
    chbAutoDirName.Checked);
  eAutoDirName.Text := ini.ReadString('options', 'autodirnameformat',
    eAutoDirName.Text);
  chbSaveJPEGMeta.Checked := ini.ReadBool('options', 'savejpegmeta',
    chbSaveJPEGMeta.Checked);
  chbOrigFNames.Checked := ini.ReadBool('options', 'origfnames',
    chbOrigFNames.Checked);
  chbIncFNames.Checked := ini.ReadBool('options', 'incfnames',
    chbIncFNames.Checked);
  chbFullSize.Checked := ini.ReadBool('options', 'fullsize',
    chbFullSize.Checked);

  eQueryI.Value := ini.ReadFloat('options', 'queryinterval',
    eQueryI.Value);
  // eQueryI2.Value := eQueryI.Value;

{  chbQueryI1.Checked := ini.ReadBool('options', 'checkqueryinterval1',
    chbQueryI1.Checked);
  chbQueryI2.Checked := ini.ReadBool('options', 'checkqueryinterval2',
    chbQueryI2.Checked); }
{  chbBfGet.Checked := ini.ReadBool('options', 'checkbeforeget',
    chbBfGet.Checked);}
  chbBfDwnld.Checked := ini.ReadBool('options', 'checkbeforedwnld',
    chbBfDwnld.Checked);
  chbAftDwnld.Checked := ini.ReadBool('options', 'checkbafterdwnld',
    chbAftDwnld.Checked);
  eRetries.AsInteger := ini.ReadInteger('options', 'retries',
    eRetries.AsInteger);
  eConnTimeOut.Value := ini.ReadFloat('options','ConnTimeout',eConnTimeOut.Value);
  eContTimeOut.Value := ini.ReadFloat('options','ContTimeout',eContTimeOut.Value);

  InGalleriesNames1.Checked := ini.ReadBool('exhentai','InNames',InGalleriesNames1.Checked);
  InGalleriesTags1.Checked := ini.ReadBool('exhentai','InTags',InGalleriesTags1.Checked);
  Doujinshi1.Checked := ini.ReadBool('exhentai','Doujinshi',Doujinshi1.Checked);
  Manga1.Checked := ini.ReadBool('exhentai','Manga',Manga1.Checked);
  ArtistCG1.Checked := ini.ReadBool('exhentai','ArtistCG',ArtistCG1.Checked);
  GameCG1.Checked := ini.ReadBool('exhentai','GameCG',GameCG1.Checked);
  Western1.Checked := ini.ReadBool('exhentai','Western',Western1.Checked);
  NonH1.Checked := ini.ReadBool('exhentai','NonH',NonH1.Checked);
  Imageset1.Checked := ini.ReadBool('exhentai','Imageset',Imageset1.Checked);
  Cosplay1.Checked := ini.ReadBool('exhentai','Cosplay',Cosplay1.Checked);
  Asianporn1.Checked := ini.ReadBool('exhentai','Asianporn',Asianporn1.Checked);
  Misc1.Checked := ini.ReadBool('exhentai','Misc',Misc1.Checked);

  for i := 0 to RESOURCE_COUNT - 1 do
  begin
    AuthData[RVLIST[i]].Login := ini.ReadString('authdata' + IntToStr(i),
      'login', '');
    AuthData[RVLIST[i]].Password := ini.ReadString('authdata' + IntToStr(i),
      'pwd', '');
  end;

  ini.Free;
end;

procedure TMainForm.loadparams;
const
  WStates: array [0 .. 2] of TWindowState = (wsNormal, wsMinimized,
    wsMaximized);

var
  ini: TINIFile;
  tmpI: Integer;
begin

  ini := TINIFile.Create(ExtractFilePath(paramstr(0)) + 'settings.ini');

  DefFolder := ini.ReadString('parametres', 'dir', 'C:\');
  cbSite.ItemIndex := ini.ReadInteger('parametres', 'destination',
    cbSite.ItemIndex);
  cbSiteChange(nil);
  ClientWidth := ini.ReadInteger('parametres', 'width', Width);
  ClientHeight := ini.ReadInteger('parametres', 'height', Height);
  tmpI := ini.ReadInteger('parametres', 'windowstate', 0);

  preview_window_left := ini.ReadInteger('previewwindow', 'left', Width + 5);
  preview_window_top := ini.ReadInteger('previewwindow', 'top', 0);
  preview_window_undrag_left := ini.ReadInteger('previewwindow', 'undragleft',
    Screen.WorkAreaWidth - 200);
  preview_window_undrag_top := ini.ReadInteger('previewwindow',
    'undragtop', 50);

  preview_window_drag := WStates[tmpI] = wsNormal;

  WindowState := WStates[tmpI];

  if ini.ReadBool('parametres', 'loghided', false) then
    tbiLogsHideClick(nil);

  chbautoscroll.Checked := ini.ReadBool('grid', 'autoscroll',
    chbautoscroll.Checked);

  ini.Free;
end;

procedure TMainForm.log(s: string);
begin
  if mlog.Lines.Count = 100 then
    mlog.Lines.Delete(0);
  if mlog.Lines[0] = '' then
    mlog.Lines[0] := DateTimeToStr(Date + Time) + ' ' + VarToStr(s)
  else
    mlog.Lines.Add(DateTimeToStr(Date + Time) + ' ' + VarToStr(s));
end;

procedure TMainForm.LogErr(s: String);
begin
  pcLogs.ActiveTabIndex := 1;
  if merrors.Lines[0] = '' then
    merrors.Lines[0] := DateTimeToStr(Date + Time) + ' ' + s
  else
    merrors.Lines.Add(DateTimeToStr(Date + Time) + ' ' + s);
end;

function TMainForm.Login(iindex: Integer): Boolean;
var
  HTTP: TMyIdHTTP;
  s: TStringList;
  // authr: TArrayOfString;
  fs: TFormatSettings;
begin
  result := false;
  case iindex of
    RP_PIXIV:
      if (FCookies.GetCookieValue('PHPSESSID', '.pixiv.net')
        = '') then
      begin
        log('Login on resource');
        repeat
          if (AuthData[iindex].Login = '') or
            (AuthData[iindex].Password = '') then
            if AutoMode then
            begin
              LogErr('AutoMode: login and password is needed');
              Exit;
            end
            else
              UpdLogin(iindex);

          if AuthData[iindex].Password = '' then
            Exit;
          s := TStringList.Create;
          s.Add('mode=login');
          s.Add('pixiv_id=' + AuthData[iindex].Login);
          s.Add('pass=' + AuthData[iindex].Password);
          s.Add('skip=1');
          HTTP := CreateHTTP;
          try
            s.Text := HTTP.Post('http://www.pixiv.net/', s);
            HTTP.Disconnect;
          except
            on E: Exception do
              if E.Message <> 'Connection Closed Gracefully.' then
              begin
                MessageDlg(E.Message,mtError,[mbOk],0);
                Exit;
              end;
          end;
          HTTP.Free;
          s.Free;
          if FCookies.GetCookieValue('PHPSESSID', '.pixiv.net')
            = '' then
          begin
            MessageDlg('Incorrect login or password', mtError, [mbOk], 0);
            AuthData[cbSite.ItemIndex].Password := '';
            { LogErr(
              'Can''t login to imageboard, check authorisation info for errors');
              Exit; }
          end
          else
          begin
            log('Loged ok');
            Break;
          end;
        until (AuthData[iindex].Login <> '') and
          (AuthData[iindex].Password <> '');
      end
      else if chbdebug.Checked then
      begin
        log('cookie data = ' + FCookies.GetCookieValue('PHPSESSID', '.pixiv.net'));
      end;
    RP_EXHENTAI:
      begin
        if FCookies.GetCookieValue('ipb_member_id',
          '.e-hentai.org') = '' then
        begin
          log('Login on resource');
          repeat
            if (AuthData[iindex].Login = '') or
              (AuthData[iindex].Password = '') then
              if AutoMode then
              begin
                LogErr('AutoMode: login and password is needed');
                Exit;
              end
              else
                UpdLogin(iindex);
            if AuthData[iindex].Password = '' then
              Exit;
            s := TStringList.Create;
            s.Add('ipb_login_username=' + AuthData[iindex].Login);
            s.Add('ipb_login_password=' + AuthData[iindex].Password);
            s.Add('ipb_login_submit=Login%21');
            HTTP := CreateHTTP;
            try
              s.Text := HTTP.Post('http://e-hentai.org/bounce_login.php', s);
              HTTP.Disconnect;
            except
              on E: Exception do
                if E.Message <> 'Connection Closed Gracefully.' then
                begin
                  MessageDlg(E.Message,mtError,[mbOk],0);
                  Exit;
                end;
            end;
            HTTP.Free;
            s.Free;
            if FCookies.GetCookieValue('ipb_member_id',
              '.e-hentai.org') = '' then
            begin
              MessageDlg('Incorrect login or password', mtError, [mbOk], 0);
              AuthData[iindex].Password := '';
            end
            else
            begin
              FCookies.Add(Replace(FCookies.GetCookieByValue('ipb_member_id','.e-hentai.org'),'e-hentai.org','exhentai.org'));
              FCookies.Add(Replace(FCookies.GetCookieByValue('ipb_pass_hash','.e-hentai.org'),'e-hentai.org','exhentai.org'));
//              HTTP.Get(RESOURCE_URLS[iindex]);
              log('Loged ok');
              Break;
            end;
          until (AuthData[iindex].Login <> '') and
            (AuthData[iindex].Password <> '');
        end;
      end;
    RP_DEVIANTART:
    begin
      if FCookies.GetCookieValue('userinfo', '.deviantart.com') = '' then
      begin
        HTTP := CreateHTTP;
        HTTP.Get(RESOURCE_URLS[iindex]);
        HTTP.Free;
      end;

      if AuthData[iindex].Login <> '' then
        if (FCookies.GetCookieValue('auth', '.deviantart.com')
          = '') then
        begin
          log('Login on resource');
          repeat
            if (AuthData[iindex].Login = '') then
              Break
            else if (AuthData[iindex].Password = '') then
              if AutoMode then
              begin
                LogErr('AutoMode: login and password is needed');
                Exit;
              end
              else
                UpdLogin(iindex);

            if AuthData[iindex].Password = '' then
              Exit;
            s := TStringList.Create;
            s.Add('ref=');
            s.Add('username=' + AuthData[iindex].Login);
            s.Add('password=' + AuthData[iindex].Password);
            s.Add('action=Login');
            HTTP := CreateHTTP;
            HTTP.IOHandler := OpSSLHandler;
            HTTP.Request.Referer := 'http://www.deviantart.com/';
            try
              s.Text := HTTP.Post('https://www.deviantart.com/users/login', s);
              if chbdebug.Checked then
                s.SaveToFile(ExtractFilePath(paramstr(0))+'logs\tmplogin.html');
              HTTP.Disconnect;
            except
              on E: Exception do
                if E.Message <> 'Connection Closed Gracefully.' then
                begin
                  MessageDlg(E.Message,mtError,[mbOk],0);
                  Exit;
                end;
            end;
            HTTP.Free;
            s.Free;

            if (FCookies.GetCookieValue('auth', '.deviantart.com')
              = '') then
            begin
              MessageDlg('Incorrect login or password', mtError, [mbOk], 0);
              AuthData[cbSite.ItemIndex].Password := '';
            end
            else
            begin
              log('Loged ok');
              Break;
            end;
          until (AuthData[iindex].Login <> '') and
            (AuthData[iindex].Password <> '');
        end
        else if chbdebug.Checked then
        begin
          log('cookie data = ' + FCookies.GetCookieValue('auth',
            '.deviantart.com'));
        end;
    end;
{      if FCookies.GetCookieValue('userinfo', '.deviantart.com')
        = '' then
      begin
        HTTP := CreateHTTP;
        HTTP.Get(RESOURCE_URLS[iindex]);
        HTTP.Free;
      end;  }
    RP_RMART:
      if FCookies.GetCookieValue('PageSize', 'rmart.org') <> '100' then
      begin
        fs := TFormatSettings.Create(1033);
        FCookies.Add('PageSize=100; path=/; expires=' +
          FormatDateTime('ddd, dd-mmm-yyyy hh:nn:ss', IncYear(GetCurrentGMT),
          fs) + ' GMT; domain=rmart.org');
        FCookies.Add('ThumbSize=6; path=/; expires=' +
          FormatDateTime('ddd, dd-mmm-yyyy hh:nn:ss', IncYear(GetCurrentGMT),
          fs) + ' GMT; domain=rmart.org');
      end;
    RP_ZEROCHAN:
      if AuthData[iindex].Login <> '' then
        if (FCookies.GetCookieValue('z_id', '.zerochan.net')
          = '') or (FCookies.GetCookieValue('z_id',
          '.zerochan.net') = '0') then
        begin
          log('Login on resource');
          repeat
            if (AuthData[iindex].Login = '') then
              Break
            else if (AuthData[iindex].Password = '') then
              if AutoMode then
              begin
                LogErr('AutoMode: login and password is needed');
                Exit;
              end
              else
                UpdLogin(iindex);

            if AuthData[iindex].Password = '' then
              Exit;
            s := TStringList.Create;
            s.Add('ref=/');
            s.Add('name=' + AuthData[iindex].Login);
            s.Add('password=' + AuthData[iindex].Password);
            s.Add('login=Login');
            HTTP := CreateHTTP;
            HTTP.Request.Referer := 'http://www.zerochan.net/login?ref=%2F';
            try
              s.Text := HTTP.Post('http://www.zerochan.net/login?ref=%2F', s);
              if chbdebug.Checked then
                s.SaveToFile(ExtractFilePath(paramstr(0))+'logs\tmplogin.html');
              HTTP.Disconnect;
            except
              on E: Exception do
                if E.Message <> 'Connection Closed Gracefully.' then
                begin
                  MessageDlg(E.Message,mtError,[mbOk],0);
                  Exit;
                end;
            end;
            HTTP.Free;
            s.Free;

            if (FCookies.GetCookieValue('z_id', '.zerochan.net')
              = '') or (FCookies.GetCookieValue('z_id',
              '.zerochan.net') = '0') then
            begin
              MessageDlg('Incorrect login or password', mtError, [mbOk], 0);
              AuthData[cbSite.ItemIndex].Password := '';
            end
            else
            begin
              log('Loged ok');
              Break;
            end;
          until (AuthData[iindex].Login <> '') and
            (AuthData[iindex].Password <> '');
        end
        else if chbdebug.Checked then
        begin
          log('cookie data = ' + FCookies.GetCookieValue('z_id',
            '.zerochan.net'));
        end;

    RP_MINITOKYO:
      if AuthData[iindex].Login <> '' then
        if (FCookies.GetCookieValue('minitokyo_id', '.minitokyo.net')
          = '') then
        begin
          log('Login on resource');
          repeat
            if (AuthData[iindex].Login = '') then
              Break
            else if (AuthData[iindex].Password = '') then
              if AutoMode then
              begin
                LogErr('AutoMode: login and password is needed');
                Exit;
              end
              else
                UpdLogin(iindex);

            if AuthData[iindex].Password = '' then
              Exit;
            s := TStringList.Create;
            s.Add('username=' + AuthData[iindex].Login);
            s.Add('password=' + AuthData[iindex].Password);
            s.Add('login=Login');
            HTTP := CreateHTTP;
            HTTP.Request.Referer := 'http://my.minitokyo.net/login';
            try
              s.Text := HTTP.Post('http://my.minitokyo.net/login', s);
              if chbdebug.Checked then
                s.SaveToFile(ExtractFilePath(paramstr(0))+'logs\tmplogin.html');
              HTTP.Disconnect;
            except
              on E: Exception do
                if E.Message <> 'Connection Closed Gracefully.' then
                begin
                  MessageDlg(E.Message,mtError,[mbOk],0);
                  Exit;
                end;
            end;
            HTTP.Free;
            s.Free;

            if (FCookies.GetCookieValue('minitokyo_id', '.minitokyo.net')
              = '') then
            begin
              MessageDlg('Incorrect login or password', mtError, [mbOk], 0);
              AuthData[cbSite.ItemIndex].Password := '';
            end
            else
            begin
              log('Loged ok');
              Break;
            end;
          until (AuthData[iindex].Login <> '') and
            (AuthData[iindex].Password <> '');
        end
        else if chbdebug.Checked then
        begin
          log('cookie data = ' + FCookies.GetCookieValue('minitokyo_id',
            '.minitokyo.net'));
        end;
  end;
  result := true;
end;

procedure TMainForm.pmTrayPopup(Sender: TObject);
begin
  Show1.Visible := not JvTrayIcon.ApplicationVisible;
  Hide1.Visible := JvTrayIcon.ApplicationVisible;
end;

function TMainForm.RowCount: Integer;
begin
  if Grid.Rows[1][1] = '' then
    result := 0
  else
    result := Grid.RowCount - 1;
end;

procedure TMainForm.btnAuth1Click(Sender: TObject);
begin
  if UpdLogin(cbSite.ItemIndex) then
    FCookies.DeleteCookie(RESOURCE_URLS[cbSite.ItemIndex]);
end;

procedure TMainForm.btnAuth2Click(Sender: TObject);
begin
  if UpdLogin(curdest) then
    FCookies.DeleteCookie(RESOURCE_URLS[curdest]);
end;

procedure TMainForm.btnBrowseClick(Sender: TObject);
begin
  if ShellExecute(Handle, 'open', PChar(IncludeTrailingPathDelimiter(edir.Text)
    ), nil, nil, SW_SHOWNORMAL) < 33 then
  begin
    if ShellExecute(Handle, 'open',
      PChar(ExtractFilePath(ExcludeTrailingPathDelimiter(edir.Text))), nil, nil,
      SW_SHOWNORMAL) < 33 then
      MessageDlg('Directory does not exist', mtInformation, [mbOk], 0);
  end;
end;

procedure TMainForm.btnListGetClick(Sender: TObject);
var
  s, categories: TStringList;
  ss: string;
  i: Integer;
  HTTP: TMyIdHTTP;
  XML: TMyXMLParser;
  tmptag: string;
  authr: TArrayOfString;
  curerrcount: Integer;
label xit;
begin
  { if cbSite.itemIndex in [9,10] then
    begin
    MessageDlg('Currently not working, see it in later builds',mtInformation,[mbOk],0);
    Exit;
    end; }

  if cbSite.ItemIndex < 0 then
  begin
    MessageDlg('Please select destination', mtInformation, [mbOk], 0);
    cbSite.SetFocus;
    Exit;
  end;

  curPreItem := 0;
  curerrcount := 0;

  merrors.Clear;

  // eQueryI.Value := eQueryI2.Value;

  saveparams;
  saveoptions;

  chbSavedTagsClick(chbSavedTags);
  tmptag := trim(eTag.Text);

  if (pos('http://', lowercase(tmptag)) = 1) and
    (cbSite.ItemIndex in [RP_EHENTAI_G, RP_EXHENTAI]) and (tstart = 0) and
    (Length(PreList) = 0) then
  begin
    while tmptag <> '' do
    begin
      ss := GetNextS(tmptag, ' ');
      if pos('http://', lowercase(ss)) = 1 then
      begin
        i := Length(PreList);
        SetLength(PreList, i + 1);
        PreList[i].URL := ss;
        PreList[i].chck := true;
        PreList[i].Preview := '';
        curdest := cbSite.ItemIndex;
      end;
    end;
    tstart := -1;
    tmptag := trim(eTag.Text);
    curtag := tmptag;
  end
  else if chbSavedTags.Checked then
    tmptag := trim(eSavedTags.Text) + ' ' + tmptag;

  ss := '';

  // Grid.read

  while (curPreItem < Length(PreList)) and not(PreList[curPreItem].chck) do
    inc(curPreItem);

  if (cbSite.ItemIndex = RP_PIXIV) and chbByAuthor.Checked then
    if euserid.Value = 0 then
    begin
      if not AutoMode then
      begin
        MessageDlg('User ID is missing.', mtInformation, [mbOk], 0);
        euserid.SetFocus;
      end;
      Exit;
    end
    else
  else if not((cbSite.ItemIndex in RS_GALLISTS) or
    (cbSite.ItemIndex in RS_POOLS) and chbInPools.Checked) or (tstart <> -1) or
    (Length(PreList) = 0) then
    if trim(tmptag) = '' then
    begin
      MessageDlg('Tag is missing.', mtInformation, [mbOk], 0);
      eTag.SetFocus;
      Exit;
    end
    else
  else if (cbSite.ItemIndex = curdest) and (curPreItem >= Length(PreList)) then
  begin
    if not AutoMode then
    begin
      MessageDlg('No selected albmus. Click "Clear" (close button near ' +
      '"autoscroll") if you want to restart', mtInformation, [mbOk], 0);
    end;
    Exit;
  end;

  hitcheck := 1;

  if (length(n) > 0) and not((curdest in RS_GALLISTS) or (cbSite.ItemIndex in RS_POOLS) and
    curInPools) and (cbSite.ItemIndex = curdest) and (tmptag = curtag) and
    ((cbSite.ItemIndex <> RP_DEVIANTART) or (eCategory.Text <> curcategory)) and
    ((cbSite.ItemIndex <> RP_PIXIV) or not chbByAuthor.Checked or
    (chbByAuthor.Checked <> curByAuthor) or (euserid.Value <> curuserid)) then
  begin
    if not AutoMode then
    begin
      hitcheck := RadioGroupDlg('List refresh', 'Select refresh mode:',
        ['Quick refresh', 'Full refresh']);
      case hitcheck of
        - 1:
          Exit;
      end;
    end
    else
      hitcheck := 0;
  end;

  block(0, 1);

  nm := 0;

  with JvTrayIcon do
    if Active then
      Icons := GLISTANIM;

  prgrsbr.Max := 100;
  prgrsbr.SetStyle(pbstMarquee);
  ss := '';
  saved := true;

  tmp := '';
  xml_tmpi := 0;
  HTTP := nil;
  s := nil;
  XML := nil;

  try

    log('Geting pictures list from "' + RESOURCE_URLS[cbSite.ItemIndex] +
      '" by tag "' + tmptag + '"');

    if not Login(cbSite.ItemIndex) then
    begin
      prgress := -1;
      goto xit;
    end;

    HTTP := CreateHTTP;
    HTTP.Request.Referer := '';
    s := TStringList.Create;

    case cbSite.ItemIndex of
      RP_GELBOORU:
        nxt := 'http://gelbooru.com/index.php?page=post&s=list&tags=' +
          StringEncode(tmptag);
      RP_DONMAI_DANBOORU, RP_DONMAI_HIJIRIBE, RP_DONMAI_SONOHARA:
        if chbInPools.Checked then
          if (curdest = cbSite.ItemIndex) and (curtag = tmptag) and
            (tstart = -1) and (Length(PreList) > 0) then
            nxt := ''
          else
          begin
            nxt := RESOURCE_URLS[cbSite.ItemIndex] + 'pool?query=' +
              StringEncode(tmptag);
            tstart := 0;
          end
        else
          nxt := RESOURCE_URLS[cbSite.ItemIndex] + 'post?tags=' +
            StringEncode(tmptag);
      RP_KONACHAN:
        if chbInPools.Checked then
          if (curdest = cbSite.ItemIndex) and (curtag = tmptag) and
            (tstart = -1) and (Length(PreList) > 0) then
            nxt := ''
          else
          begin
            nxt := 'http://konachan.com/pool?query=' + StringEncode(tmptag);
            tstart := 0;
          end
        else
          nxt := 'http://konachan.com/post?searchDefault=Search&tags=' +
            StringEncode(tmptag);
      RP_IMOUTO:
        if chbInPools.Checked then
          if (curdest = cbSite.ItemIndex) and (curtag = tmptag) and
            (tstart = -1) and (Length(PreList) > 0) then
            nxt := ''
          else
          begin
            nxt := 'http://oreno.imouto.org/pool?query=' + StringEncode(tmptag);
            tstart := 0;
          end
        else
          nxt := 'http://oreno.imouto.org/post?searchDefault=Search&tags=' +
            StringEncode(tmptag);
      RP_PIXIV:
        if not chbByAuthor.Checked then
          nxt := 'http://www.pixiv.net/search.php?s_mode=s_tag&word=' +
            StringEncode(tmptag)
        else
          case cbByAuthor.ItemIndex of
            0:
              nxt := 'http://www.pixiv.net/member_illust.php?id=' +
                StringEncode(euserid.Text) + '&tag=' + StringEncode(tmptag);
            1:
              nxt := 'http://www.pixiv.net/bookmark.php?id=' +
                StringEncode(euserid.Text);
          end;
      RP_SAFEBOORU:
        nxt := 'http://safebooru.org/index.php?page=post&s=list&tags=' +
          StringEncode(tmptag);
      RP_SANKAKU_CHAN, RP_SANKAKU_IDOL, RP_WILDCRITTERS, RP_NEKOBOORU:
        if chbInPools.Checked then
          if (curdest = cbSite.ItemIndex) and (curtag = tmptag) and
            (tstart = -1) and (Length(PreList) > 0) then
            nxt := ''
          else
          begin
            nxt := RESOURCE_URLS[cbSite.ItemIndex] + 'pool?query=' +
              StringEncode(tmptag);
            tstart := 0;
          end
        else
          nxt := RESOURCE_URLS[cbSite.ItemIndex] + 'post?tags=' +
            StringEncode(tmptag);
      RP_BEHOIMI:
        if chbInPools.Checked then
          if (curdest = cbSite.ItemIndex) and (curtag = tmptag) and
            (tstart = -1) and (Length(PreList) > 0) then
            nxt := ''
          else
          begin
            nxt := 'http://behoimi.org/pool?query=' + StringEncode(tmptag);
            tstart := 0;
          end
        else
          nxt := 'http://behoimi.org/post?tags=' + StringEncode(tmptag);
      RP_EHENTAI_G,RP_EXHENTAI:
        if (curdest = cbSite.ItemIndex) and (curtag = tmptag) and (tstart = -1)
          and (Length(PreList) > 0) then
          nxt := ''
        else
        begin
          nxt := RESOURCE_URLS[cbSite.ItemIndex] + '?'
            + ifn(doujinshi1.Checked,'f_doujinshi=1&','')
            + ifn(manga1.Checked,'f_manga=1&','')
            + ifn(artistcg1.Checked,'f_artistcg=1&','')
            + ifn(gamecg1.Checked,'f_gamecg=1&','')
            + ifn(western1.Checked,'f_western=1&','')
            + ifn(nonh1.Checked,'f_non-h=1&','')
            + ifn(imageset1.Checked,'f_imageset=1&','')
            + ifn(cosplay1.Checked,'f_cosplay=1&','')
            + ifn(asianporn1.Checked,'f_asianporn=1&','')
            + ifn(misc1.Checked,'f_misc=1&','')
            + 'f_apply=Apply+Filter&advsearch=1&'
            + ifn(InGalleriesNames1.Checked,'f_sname=on&','')
            + ifn(InGalleriesTags1.Checked,'f_stags=on&','')
            + 'f_srdd=2&f_sfdd=favall&&f_search=' + StringEncode(tmptag);
          tstart := 0;
        end;
      RP_PAHEAL_RULE34:
        nxt := 'http://rule34.paheal.net/post/list/' +
          StringEncode(tmptag) + '/1';
      RP_DEVIANTART:
        begin
          categories := TStringList.Create;
          categories.Text := strtostrlist(eCategory.Text);
          for i := 0 to categories.Count - 1 do
          begin
            categories[curPreItem] := REPLACE(categories[curPreItem], '\', '/',
              false, true);
            if categories[curPreItem][Length(categories[curPreItem])]
              <> '/' then
              categories[curPreItem] := categories[curPreItem] + '/';
            if categories[curPreItem][1] = '/' then
              categories[curPreItem] :=
                CopyFromTo(categories[curPreItem], '/', '');
          end;
          eCategory.Text := strlisttostr(categories);
          if categories.Count > 0 then
            nxt := 'http://browse.deviantart.com/' + categories[0] +
              '?order=5&q=' + StringEncode(tmptag)
          else
            nxt := 'http://browse.deviantart.com/?order=5&q=' +
              StringEncode(tmptag);
        end;
      RP_E621:
        if chbInPools.Checked then
          if (curdest = cbSite.ItemIndex) and (curtag = tmptag) and
            (tstart = -1) and (Length(PreList) > 0) then
            nxt := ''
          else
          begin
            nxt := 'http://e621.net/pool?query=' + StringEncode(tmptag);
            tstart := 0;
          end
        else
          nxt := 'http://e621.net/post?commit=Search&tags=' +
            StringEncode(tmptag);
      RP_413CHAN_PONIBOORU,RP_PAHEAL_RULE63, RP_PAHEAL_COSPLAY,
      RP_TENTACLERAPE:
        nxt := RESOURCE_URLS[cbSite.ItemIndex] + 'post/list/' +
          StringEncode(tmptag) + '/1';
      RP_BOORU_II,RP_TBIB:
        nxt := RESOURCE_URLS[cbSite.ItemIndex] + 'index.php?page=post&s=list&tags=' +
          StringEncode(tmptag);
      RP_ZEROCHAN:
        nxt := 'http://www.zerochan.net/search?q=' + StringEncode(tmptag)
          + '&s=id';

      RP_XBOORU:
        nxt := 'http://xbooru.com/index.php?page=post&s=list&tags=' +
          StringEncode(tmptag);
      RP_XXX_RULE34:
        nxt := 'http://rule34.xxx/index.php?page=post&s=list&tags=' +
          StringEncode(tmptag);
      RP_RMART:
        nxt := 'http://rmart.org/?q=' + StringEncode(tmptag);
      RP_THEDOUJIN:
        nxt := 'http://thedoujin.com/index.php/categories/index?tags=' +
          StringEncode(tmptag) + '&commit=';
      RP_MINITOKYO:
        if (curdest = cbSite.ItemIndex) and (curtag = tmptag) and (tstart = -1)
          and (Length(PreList) > 0) then
          nxt := ''
        else
        begin
          nxt := RESOURCE_URLS[cbSite.ItemIndex] + 'search?q=' +
            StringEncode(tmptag);
          tstart := 0;
        end;
    end;

    if hitcheck = 1 then
    begin
      nm := 0;
      n := nil;
      tags := nil;
      lbRelatedTags.Clear;
    end;

    if not(((cbSite.ItemIndex in RS_GALLISTS) or (cbSite.ItemIndex in RS_POOLS)
      and chbInPools.Checked) and (curtag = tmptag) and (tstart = -1)) then
    begin
      tstart := 0;
      PreList := nil;
    end;

    curdest := -2;
    if euserid.Value < 0 then
      euserid.Value := 0;
    curuserid := -1;
    curtag := '';
    curcategory := '';
    curByAuthor := false;
    curInPools := false;

    GridClear;
    chblTagsCloud.Clear;

    DrawImageFromRes(bgimage, 'ZTAO', '.png');

    finished := false;
    XML := TMyXMLParser.Create;
    XML.OnStartTag := XmlStartTag;
    XML.OnEmptyTag := XmlEmptyTag;
    XML.OnEndTag := XmlEndTag;
    XML.OnContent := XmlContent;

    gettags := true;

    if Length(PreList) > 0 then
    begin
      nxt := PreList[curPreItem].URL;
      PreList[curPreItem].chck := false;
    end;

    i := 0;
    npp := 0;

    while true do
    begin
      hit := false;
      while nxt <> '' do
      begin
        inc(i);
        updatecaption('[p' + IntToStr(i) + ']');
        while true do
          try
            if not(prgress = 0) then
              Break;

            if nxt[1] = '?' then
              nxt := CopyTo(HTTP.Request.URL, '?') + nxt;

            if chbdebug.Checked then
              log(nxt);

            s.Text := HTTP.Get(REPLACE(ClearHTML(nxt), ' ', '+', false, true));
            HTTP.Disconnect;

            if chbdebug.Checked then
              s.SaveToFile(ExtractFilePath(paramstr(0)) + 'logs\tmp' +
                IntToStr(nm) + '.html');

            case cbSite.ItemIndex of
              RP_GELBOORU:
                if pos('You are viewing an advertisement...',s.Text) > 0 then
                begin
                  Log('Porno-banner accepted');
                  fStoping.Execute('Waiting...','Watching porno-banner :3','Wait ',0,10,true,true);
                  HTTP.Request.Referer := ClearHTML(nxt);
                  HTTP.Get('http://gelbooru.com/intermission.php');
                  HTTP.Request.Referer := '';
                  Continue;
                end;
              RP_EHENTAI_G, RP_EXHENTAI:
                if pos('Please wait', s.Text) > 0 then
                begin
                  if not Application.Active then
                    JvTrayIcon.BalloonHint('Error on getting list',
                      'Please wait at least three seconds between searching or '
                      + 'changing pages in search results.', btError);
                  with JvTrayIcon do
                    if Active then
                    begin
                      Icons := nil;
                      Icon.Handle :=
                        LoadIcon(hInstance, PWideChar('ZGLISTERROR'));
                    end;
                  if not AutoMode then
                    MessageDlg('Please wait at least three seconds between ' +
                      'searching or changing pages in search results.', mtError,
                      [mbOk], 0)
                  else
                    LogErr('Please wait at least three seconds between ' +
                      'searching or changing pages in search results.');
                  prgress := -1;
                  Break;
                end;
            end;
            Break;
          except
            on E: Exception do
            begin
              if E.Message <> 'Connection Closed Gracefully.' then
              begin
                if HTTP.Connected then
                  HTTP.Disconnect;

                if (pos('404 Not Found', E.Message) > 0) or AutoMode then
                begin
                  LogErr(ClearHTML(nxt) + ': ' + E.Message);
                  Break;
                end
                else if curerrcount < eRetries.AsInteger then
                begin
                  inc(curerrcount);
                  LogErr(ClearHTML(nxt) + ': ' + E.Message + ' retry ' +
                    IntToStr(curerrcount) + ' of ' + eRetries.Text);
                end
                else
                begin
                  LogErr(ClearHTML(nxt) + ': ' + E.Message);
                  with JvTrayIcon do
                    if Active then
                    begin
                      Icons := nil;
                      Icon.Handle :=
                        LoadIcon(hInstance, PWideChar('ZGLISTERROR'));
                    end;
                  if not Application.Active then
                    JvTrayIcon.BalloonHint('Error on getting list',
                      E.Message, btError);
                  if MessageDlg('Error on getting list:' + #13#10 + E.Message +
                    #13#10 + 'You can try to continue loading', mtError,
                    [mbRetry, mbAbort], 0) = mrAbort then
                  begin
                    prgress := -1;
                    Break;
                  end;
                  with JvTrayIcon do
                    if Active then
                      Icons := GLISTANIM;
                end;
              end;
            end;
          end;

        if not(prgress = 0) then
          Break;

        nxt := '';
        curerrcount := 0;
        xml_tmpi := -1;

        XML.Parse(s.Text);

        if (cbSite.ItemIndex = RP_DEVIANTART) and (pos('&offset=', nxt) > 0) and
          (StrToInt(DeleteTo(nxt, '&offset=')) >= 2500) or
          (cbSite.ItemIndex = RP_ZEROCHAN) and (pos('?o=', nxt) > 0) then
        begin
          LogErr('query limit exceeded');
          nxt := '';
        end;

        if (cbSite.ItemIndex in [RP_EHENTAI_G, RP_EXHENTAI]) then
          case tstart of
            - 1:
              begin
                ss := CopyFromTo(nxt, ' - ', ' of ');
                if ss = CopyFromTo(nxt, ' of ', ' images') then
                  nxt := ''
                else
                begin
                  if chbQueryI1.Checked then
                    _delay(eQueryI.AsInteger * 1000);
                  nxt := PreList[curPreItem].URL + '?p=' + IntToStr(i);
                end;
              end;
          end;

        gettags := false;

        if assigned(categories) and (categories.Count > 0) then
          StatusBar.SimpleText := categories[curPreItem] + ', ' + 'page ' +
            IntToStr(i) + ', ' + IntToStr(nm) + ' picture' +
            numstr(nm, '', '', '', true)
        else if assigned(PreList) and not assigned(n) then
          StatusBar.SimpleText := 'Page ' + IntToStr(i) + ', ' +
            IntToStr(Length(PreList)) + ' album' + numstr(nm, '', '', '', true)
        else
          StatusBar.SimpleText := 'Page ' + IntToStr(i) + ', ' + IntToStr(nm) +
            ' picture' + numstr(nm, '', '', '', true);

        if hit then
          Break;

        if (cbSite.ItemIndex in [RP_EHENTAI_G, RP_EXHENTAI]) then
          if (tstart = 0) and (nxt <> '') then
          begin
            StatusBar.SimpleText := StatusBar.SimpleText + ', ' +
              IntToStr(Max(eQueryI.AsInteger, 3)) + ' sec pause';
            _delay(Max(eQueryI.AsInteger * 1000, 3000));
          end;
      end;

      if (cbSite.ItemIndex in RS_GALLISTS) or (cbSite.ItemIndex in RS_POOLS) and
        chbInPools.Checked then
      begin
        if tstart = 0 then
          Break
        else if (tstart = -1) then
        begin
          while (curPreItem < Length(PreList)) and
            not(PreList[curPreItem].chck) do
            inc(curPreItem);
          if curPreItem < Length(PreList) then
          begin
            npp := 0;
            PreList[curPreItem].chck := false;
            nxt := PreList[curPreItem].URL;
          end
          else
          begin
            PreList := nil;
            tstart := 0;
            Break;
          end;
          i := 0;
        end
        else
      end
      else if cbSite.ItemIndex in [RP_DEVIANTART] then
      begin
        npp := 0;
        inc(curPreItem);
        if curPreItem < categories.Count then
          nxt := 'http://browse.deviantart.com/' + categories[curPreItem] +
            '?order=5&q=' + StringEncode(tmptag)
        else
        begin
          FreeAndNil(categories);
          Break;
        end;
      end
      else
        Break;

      if not(prgress = 0) then
        Break;
    end;

    if prgress = 2 then
    begin
      n := nil;
      PreList := nil;
    end;

    GenTags;
    GenGrid;

    curdest := cbSite.ItemIndex;
    curtag := tmptag;

    if curdest = RP_DEVIANTART then
      curcategory := eCategory.Text
    else if curdest = RP_PIXIV then
    begin
      curByAuthor := chbByAuthor.Checked;
      curuserid := euserid.AsInteger;
    end
    else if (curdest in RS_POOLS) then
      curInPools := chbInPools.Checked;

    if ((curdest in RS_GALLISTS) or (cbSite.ItemIndex in RS_POOLS) and
      chbInPools.Checked) and (tstart = 0) and (Length(PreList) > 0) then
      tstart := -1;

    if not(((curdest in RS_GALLISTS) or (cbSite.ItemIndex in RS_POOLS) and
      chbInPools.Checked) and (tstart = -1)) then
    begin
      tstart := 0;
      finished := true;
    end;

    if prgress = 0 then
      prgress := 1;

  xit:

    prgrsbr.SetStyle(pbstNormal);

    block(prgress, 1);

    case prgress of
      - 1:
        DrawImageFromRes(bgimage, 'ZERROR', '.png');
      2:
        begin
          log('Aborted by user');
          DrawImageFromRes(bgimage, 'ZNYA', '.png');
        end;
      // 1: DrawImageFromRes(BgImage,'ZNYA','.png');
      1:
        begin
          if ((curdest in RS_GALLISTS) or (curdest in RS_POOLS) and
            chbInPools.Checked) and (tstart = -1) then
          begin
            pcMenu.ActivePage := tsPicsList;
            log('Found ' + IntToStr(RowCount) + ' item' + numstr(RowCount, '',
              '', '', true) + '.');
            if not AutoMode then
              MessageDlg
                ('This is a first step, for next step you need check wanted' +
                ' albums and click "Get" again. For restart click "Clear".',
                mtInformation, [mbOk], 0);
            log('This is the first step, for next step you need check wanted albums and'
              + ' click "Get" again. For restart click "Clear"');
          end
          else
          begin
            log('Found ' + IntToStr(nm) + ' new picture' + numstr(nm, '', '',
              '', true));
            if RowCount > 0 then
              case cbAfterFinish.ItemIndex of
                0:
                  pcMenu.ActivePage := tsPicsList;
                1:
                  pcMenu.ActivePage := tsMetadata;
                2:
                  pcMenu.ActivePage := tsDownloading;
              end
            else
            begin
              DrawImageFromRes(bgimage, 'ZNOTHING', '.png');
              pcMenu.ActivePage := tsPicsList;
            end;
          end;

          saved := false;

          sdList.FileName := eTag.Text + sdList.DefaultExt;

          if hitcheck = 1 then
            chbAutoDirNameClick(nil);

          log('List loading completed without critical errors');
          if not Application.Active then
            JvTrayIcon.BalloonHint('Done', 'List is done', btInfo);
        end;
    end;

    try
      if assigned(s) then
        FreeAndNil(s);
      FreeAndNil(HTTP);
    except
    end;

  except
    on E: Exception do
    begin
      // btnListClearClick(nil);
      DrawImageFromRes(bgimage, 'ZERROR', '.png');
      LogErr('Error on getting list: ' + E.Message);
      prgrsbr.SetState(pbsNormal);
      prgrsbr.SetStyle(pbstNormal);
      block(-1, 1);
      if assigned(categories) then
        FreeAndNil(categories);
      if assigned(s) then
        FreeAndNil(s);
      if assigned(HTTP) then
        FreeAndNil(HTTP);
      if assigned(XML) then
        FreeAndNil(XML);
    end;
  end;

end;

procedure TMainForm.SaveToFile(fname: string; tp: Integer; Sender: TObject);
var
  f: textfile;
  i: Integer;
begin
  try
    case tp of
      0, 1, 4:
        begin
          if curdest < 0 then
          begin
            MessageDlg('Can''t save in this format, because list is not ' +
              'loaded or downloaded not completely / with errors.',
              mtInformation, [mbOk], 0);
            Exit;
          end;
          assignfile(f, fname);
          rewrite(f);
          writeln(f, '*fileversion:', SAVEFILE_VERSION);
          write(f, REV_RVLIST[curdest], ';', StringEncode(curtag), ';');

          case curdest of
            RP_DEVIANTART:
              write(f, StringEncode(eCategory.Text), ';');
            RP_PIXIV:
              write(f, curByAuthor, ';', curuserid, ';');
            RP_EHENTAI_G, RP_EXHENTAI:
              write(f, chbOrigFNames.Checked, ';');
          end;

          // if chbsavepath.Checked and (Sender = nil) then
          write(f, StringEncode(edir.Text));

          write(f, ';', trim(extracttags2(tags)), ';',
            trim(extracttags(lbRelatedTags.Items)), ';' { ,
              ';',trim(AuthorsToString)) } );

          if curdest in (RS_POOLS - [RP_SANKAKU_IDOL, RP_SANKAKU_CHAN]) then
            write(f, curInPools, ';');

          writeln(f);
          for i := 0 to Length(n) - 1 do
            writeln(f, n[i].URL, ';', n[i].chck, ';',
              { n[i].author,';', } StringEncode(n[i].title), ';',
              StringEncode(n[i].Params), ';', StringEncode(n[i].postdate), ';',
              n[i].Preview, ';', StringEncode(ClearHTML(n[i].pageurl)), ';',
              StringEncode(ClearHTML(n[i].category)), ';',
              ArrayOfWordToString(n[i].tags));
          closefile(f);

          saved := true;
        end;
      2:
        begin
          assignfile(f, fname);
          rewrite(f);
          for i := 0 to Length(n) - 1 do
            writeln(f, n[i].URL);
          closefile(f);
        end;
      3:
        begin
          assignfile(f, fname);
          rewrite(f);
          for i := 0 to Length(n) - 1 do
            if curdest = RP_RMART then
              writeln(f, emptyname(REPLACE(n[i].URL, '/Src/Image', '')) + ';' +
                ClearHTML(TagString(n[i].tags)))
            else
              writeln(f, emptyname(n[i].URL) + ';' +
                ClearHTML(TagString(n[i].tags)));
          closefile(f);
        end;
    end;
    sdList.FileName := ExtractFileName(fname);
    saved := false;
    log('List "' + ExtractFileName(fname) + '" saved');
  except
    on E: Exception do
    begin
      closefile(f);
      LogErr('Error on saving file: ' + E.Message);
    end;
  end;
end;

procedure TMainForm.ForceStop;
var
  i: Integer;
  l: TList;
begin
  if assigned(FThreadList) then
  begin
    l := FThreadList.LockList;
    for i := 0 to l.Count - 1 do
      try
        with TDownloadThread(l[i]) do
         if HTTP.Connected then
        begin
          HTTP.Disconnect;
          FreeFile;
        end;
      except
      end;
    FThreadList.UnlockList;
  end;

end;

procedure TMainForm.cbByAuthorChange(Sender: TObject);
begin
  eTag.Enabled := TComboBox(Sender).ItemIndex < 1;
  btnTagEdit.Enabled := TComboBox(Sender).ItemIndex < 1;
end;

procedure TMainForm.cbSiteChange(Sender: TObject);
begin
  chbByAuthor.Visible := cbSite.ItemIndex = RP_PIXIV;
  chbInPools.Visible := cbSite.ItemIndex
    in (RS_POOLS - [RP_SANKAKU_CHAN, RP_SANKAKU_IDOL]);
  cbByAuthor.Visible := cbSite.ItemIndex = RP_PIXIV;
  euserid.Visible := cbSite.ItemIndex = RP_PIXIV;
  lCategory.Visible := cbSite.ItemIndex = RP_DEVIANTART;
  eCategory.Visible := cbSite.ItemIndex = RP_DEVIANTART;
  btnCatEdit.Visible := cbSite.ItemIndex = RP_DEVIANTART;
  chbQueryI1.Visible := cbSite.ItemIndex in [RP_EHENTAI_G, RP_EXHENTAI];
  chbQueryI1.Visible := cbSite.ItemIndex in [RP_EHENTAI_G, RP_EXHENTAI];
  bOptions.Visible := cbSite.ItemIndex in [RP_EHENTAI_G, RP_EXHENTAI];
end;

procedure TMainForm.cbTaskBarChange(Sender: TObject);
begin
  case TComboBox(Sender).ItemIndex of
    0:
      JvTrayIcon.Visibility := JvTrayIcon.Visibility + [tvVisibleTaskList] -
        [tvAutoHide];
    1:
      JvTrayIcon.Visibility := JvTrayIcon.Visibility + [tvVisibleTaskList] +
        [tvAutoHide];
    2:
      JvTrayIcon.Visibility := JvTrayIcon.Visibility - [tvVisibleTaskList] -
        [tvAutoHide];
  end;
end;

procedure TMainForm.chbauthClick(Sender: TObject);
begin
  updateinterface;
end;

procedure TMainForm.chbAutoDirNameClick(Sender: TObject);
begin
  updateinterface;
  if chbAutoDirName.Checked then
    if pos('http://', lowercase(curtag)) > 0 then
      edir.Text := DefFolder +
        trim(ValidFName(REPLACE(REPLACE(eAutoDirName.Text, '?s',
        CopyFromTo(cbSite.Items[curdest], '//', '/')), '?t', ''), true), '\')
    else
      edir.Text := DefFolder +
        trim(ValidFName(REPLACE(REPLACE(eAutoDirName.Text, '?s',
        CopyFromTo(cbSite.Items[curdest], '//', '/')), '?t', curtag),
        true), '\')
  else if Sender <> nil then
    edir.Text := DefFolder;
end;

procedure TMainForm.chbAutoScrollClick(Sender: TObject);
begin
  FAutoScroll := TCheckBox(Sender).Checked;
  if FAutoScroll and (prgress = 0) and (nm < Grid.RowCount) and
    (nm > Grid.Row) then
    Grid.AutoSetRow(nm);
end;

procedure TMainForm.chbByAuthorClick(Sender: TObject);
begin
  euserid.Enabled := (cbSite.ItemIndex = RP_PIXIV) and
    TCheckBox(Sender).Checked;
  cbByAuthor.Enabled := (cbSite.ItemIndex = RP_PIXIV) and
    TCheckBox(Sender).Checked;
end;

procedure TMainForm.chbdownloadalbumsClick(Sender: TObject);
begin
  chbcreatenewdirs.Enabled := TCheckBox(Sender).Checked;
  // updateinterface;
end;

procedure TMainForm.chbOpenDriveClick(Sender: TObject);
begin
  updateinterface;
end;

procedure TMainForm.bOptionsClick(Sender: TObject);
var
  p: TPoint;
begin
  p := bOptions.ClientToScreen(Point(0,bOptions.Height));
  pabOptionsList.Popup(p.X,p.Y);
end;

procedure TMainForm.chbOrigFNamesClick(Sender: TObject);
begin
  if not loading and TCheckBox(Sender).Checked and
    (cbExistingFile.ItemIndex <> 2) and
    (MessageDlg('In this mode filenames may be the same. Do you want to set ' +
    'rename mode on existing?', mtWarning, [mbYes, mbNo], 0) = mrYes) then
    cbExistingFile.ItemIndex := 2;
end;

procedure TMainForm.chbPreviewClick(Sender: TObject);
begin
  if assigned(fPreview) then
    if chbPreview.Checked then
    begin
      // fPreview.Show;
      // SetFocus;
      ShowWindow(fPreview.Handle, SW_SHOWNOACTIVATE);
      if (curdest > -1) and (RowCount > 0) then
        if Length(n) > 0 then
          fPreview.Execute(n[Grid.Row - 1].Preview, RESOURCE_URLS[curdest] +
            n[Grid.Row - 1].pageurl, n[Grid.Row - 1].title)
        else if Length(PreList) > 0 then
          fPreview.Execute(PreList[Grid.Row - 1].Preview,
            PreList[Grid.Row - 1].URL);
    end
    else
      ShowWindow(fPreview.Handle, SW_HIDE);
end;

procedure TMainForm.chbproxyClick(Sender: TObject);
begin
  updateinterface;
end;

procedure TMainForm.chbSavedTagsClick(Sender: TObject);
var
  s: string;
  i: Integer;
begin
  if TCheckBox(Sender).Checked then
  begin
    i := pos(eSavedTags.Text, eTag.Text);
    if (i > 0) and ((i = 1) or (eTag.Text[i - 1] = ' ')) and
      ((i - 1 + Length(eSavedTags.Text) = Length(eTag.Text)) or
      (eTag.Text[i + 1] = ' ')) then
    begin
      s := eTag.Text;
      Delete(s, i, i - 1 + Length(eSavedTags.Text));
      eTag.Text := s;
    end;
  end;
  eSavedTags.Enabled := TCheckBox(Sender).Checked;
end;

procedure TMainForm.chbsavepwdClick(Sender: TObject);
begin
  (Sender as TCheckBox).Checked := (Sender as TCheckBox).Checked and
    (loading or
    (MessageDlg
    ('Password stored in not encrypted text form. Are you realy want to save password?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes));
end;

procedure TMainForm.chbTaskbarClick(Sender: TObject);
begin
  with JvTrayIcon do
    if TCheckBox(Sender).Checked then
      Visibility := Visibility + [tvAutoHide]
    else
      Visibility := Visibility - [tvAutoHide];
end;

procedure TMainForm.chbTrayIconClick(Sender: TObject);
begin
  JvTrayIcon.Active := TCheckBox(Sender).Checked;
  updateinterface;
end;

procedure TMainForm.chbKeepInstanceClick(Sender: TObject);
var
  P: PChar;
begin
  if TCheckBox(Sender).Checked then
  begin
    hFileMapObj := CreateFileMapping(MAXDWORD, nil, PAGE_READWRITE, 0, 4,
      UNIQUE_ID);
    P := MapViewOfFile(hFileMapObj, FILE_MAP_WRITE, 0, 0, 0);
    WriteLWToPChar(MainForm.Handle, P);
    UnmapViewOfFile(P);
  end
  else if hFileMapObj <> 0 then
    CloseHandle(hFileMapObj);
end;

procedure TMainForm.chbNameFormatClick(Sender: TObject);
begin
  updateinterface;
end;

procedure TMainForm.Close1Click(Sender: TObject);
begin
  Close;
end;

function TMainForm.CreateHTTP(AType: Integer = 0): TMyIdHTTP;
// 0: simple
// 1: downloading
begin
  result := TMyIdHTTP.Create(Self);
  result.HandleRedirects := true;
//  result.CookieManager := CookieManager;
  result.AllowCookies := False;
  result.CookieList := FCookies;
  result.ConnectTimeout := Trunc(eConnTimeOut.Value * 1000);
  result.ReadTimeout := Trunc(eContTimeOut.Value * 1000);
  result.Request.UserAgent :=
    'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; en)';
  if chbproxy.Checked then
  begin
    result.ProxyParams.ProxyServer := eproxyserver.Text;
    result.ProxyParams.ProxyPort := eproxyport.AsInteger;
    result.ProxyParams.BasicAuthentication := chbauth.Checked;
    result.ProxyParams.ProxyUsername := eproxylogin.Text;
    result.ProxyParams.ProxyPassword := eproxypassword.Text;
  end;
  case AType of
    0:
      begin
        result.OnWorkBegin := HTTPWorkBegin;
        result.OnWork := HTTPWork;
      end;
  end;
end;

function TMainForm.CreateThread: TDownloadThread;
begin
  result := TDownloadThread.Create(true);
  // Result.Form := Form1;
  // Result.autoscroll := @FAutoScroll;
  // Result.destnum := curdest;
  // Result.Grd := Grid;
  // Result.StatusBar := StatusBar;
  // Result.PB := prgrsbr;
  result.CSection := FSection;
  result.spth := edir.Text;
  // result.LogErr := LogErr;
  result.HTTP := CreateHTTP(1);
  result.HTTP.OnWorkBegin := result.DwnldHTTPWorkBegin;
  result.HTTP.OnWork := result.DwnldHTTPWork;

  result.IntBefGet := chbQueryI2.Visible and chbQueryI2.Checked and
    chbBfGet.Checked;
  result.IntBefDwnld := chbQueryI2.Visible and chbQueryI2.Checked and
    chbBfDwnld.Checked;
  result.IntAftDwnld := chbQueryI2.Visible and chbQueryI2.Checked and
    chbAftDwnld.Checked;

  if curdest in [RP_EHENTAI_G, RP_EXHENTAI] then
  begin
    FThreadQueue.DelayPeriod := Trunc(eQueryI.Value * 1000);
    result.ThreadQueue := FThreadQueue;
    result.XML := TMyXMLParser.Create;
    result.XML.OnStartTag := result.XMLStartTagEvent;
    result.XML.OnEndTag := result.XMLEndTagEvent;
    result.XML.OnEmptyTag := result.XMLEmptyTagEvent;
    result.XML.OnContent := result.XMLContentEvent;
  end;

  result.downloadalbums := chbdownloadalbums.Checked;
  result.createnewdirs := chbcreatenewdirs.Checked;
  { result.distbyauth := chbDistByAuth.Checked and
    (curdest in [RP_PIXIV]); }
  result.errcount := eRetries.AsInteger;
  if (curdest in [RP_PIXIV]) and chbNameFormat.Checked then
    result.nformat := eNameFormat.Text
  else
    result.nformat := '';
  result.tagsinfname := chbTagsIn.Visible and chbTagsIn.Checked and
    (cbTagsIn.ItemIndex = 0); { and not
    (curdest in [RP_PIXIV, RP_EHENTAI_G, RP_EXHENTAI, RP_DEVIANTART]); }
  result.savejpegmeta := chbSaveJPEGMeta.Checked;
  result.existingfile := cbExistingFile.ItemIndex;
  result.origfname := chbOrigFNames.Checked and chbOrigFNames.Visible;
  result.incfname := chbIncFNames.Checked and chbIncFNames.Visible;
  result.zerocount := Length(n);
  result.fullsize := chbFullSize.Checked;
  // result.updatecaption := updatecaption;
  result.FreeOnTerminate := true;
  result.OnTerminate := ThreadTerminate;
  // result.FOnProgress := DWNLDProc;
  inc(threadnum);
  result.Start;
end;

procedure TMainForm.saveoptions;
var
  ini: TINIFile;
  i: Integer;

begin
  ini := TINIFile.Create(ExtractFilePath(paramstr(0)) + 'settings.ini');

  ini.WriteInteger('options', 'afterend', cbAfterFinish.ItemIndex);
  if trim(eSavedTags.Text) = '' then
  begin
    if Length(eSavedTags.Text) > 0 then
      eSavedTags.Text := '';
    if chbSavedTags.Checked then
      chbSavedTags.Checked := false;
  end;
  ini.WriteBool('options', 'savedtagschecked', chbSavedTags.Checked);
  ini.WriteString('options', 'savedtags', StringEncode(eSavedTags.Text));
  if chbByAuthor.Checked then
    ini.WriteInteger('options', 'byauthor', cbByAuthor.ItemIndex)
  else
    ini.WriteInteger('options', 'byauthor', -1);
  ini.WriteFloat('options', 'queryinterval', eQueryI.Value);
{  ini.WriteBool('options', 'checkqueryinterval1', chbQueryI1.Checked);
  ini.WriteBool('options', 'checkqueryinterval2', chbQueryI2.Checked);
  ini.WriteBool('options', 'checkbeforeget', chbBfGet.Checked);        }
  ini.WriteBool('options', 'checkbeforedwnld', chbBfDwnld.Checked);
  ini.WriteBool('options', 'checkbafterdwnld', chbAftDwnld.Checked);

  ini.WriteInteger('options', 'cntfilter', eCFilter.AsInteger);
  ini.WriteBool('options', 'showpreview', chbPreview.Checked);

  // ini.WriteBool('options', 'savepath', chbsavepath.Checked);
  ini.WriteBool('options', 'autodirname', chbAutoDirName.Checked);
  ini.WriteString('options', 'autodirnameformat', eAutoDirName.Text);
  ini.WriteInteger('options', 'existingfile', cbExistingFile.ItemIndex);
  ini.WriteBool('options', 'savejpegmeta', chbSaveJPEGMeta.Checked);
  ini.WriteBool('options', 'downloadalbums', chbdownloadalbums.Checked);
  ini.WriteBool('options', 'createnewdirs', chbcreatenewdirs.Checked);
  ini.WriteBool('options', 'origfnames', chbOrigFNames.Checked);
  ini.WriteBool('options', 'incfnames', chbIncFNames.Checked);
  ini.WriteBool('options', 'fullsize', chbFullSize.Checked);
  ini.WriteBool('options', 'nameformatcheck', chbNameFormat.Checked);
  ini.WriteString('options', 'nameformat', eNameFormat.Text);
  ini.WriteBool('options', 'tagsincheck', chbTagsIn.Checked);
  ini.WriteInteger('options', 'tagsin', cbTagsIn.ItemIndex);

  ini.WriteInteger('options', 'threads', eThreadCount.AsInteger);
  ini.WriteBool('options', 'opendrive', chbOpenDrive.Checked);
  ini.WriteString('options', 'driveletter', FDrive);
  ini.WriteBool('options', 'trayicon', chbTrayIcon.Checked);
  ini.WriteBool('options', 'taskbar', chbTaskbar.Checked);
  ini.WriteBool('options', 'keepinstance', chbKeepInstance.Checked);
  ini.WriteBool('options', 'savenote', chbSaveNote.Checked);
  ini.WriteInteger('options', 'retries', eRetries.AsInteger);
  ini.WriteFloat('options','ConnTimeout',eConnTimeOut.Value);
  ini.WriteFloat('options','ContTimeout',eContTimeOut.Value);

  ini.WriteBool('exhentai','InNames',InGalleriesNames1.Checked);
  ini.WriteBool('exhentai','InTags',InGalleriesTags1.Checked);
  ini.WriteBool('exhentai','Doujinshi',Doujinshi1.Checked);
  ini.WriteBool('exhentai','Manga',Manga1.Checked);
  ini.WriteBool('exhentai','ArtistCG',ArtistCG1.Checked);
  ini.WriteBool('exhentai','GameCG',GameCG1.Checked);
  ini.WriteBool('exhentai','Western',Western1.Checked);
  ini.WriteBool('exhentai','NonH',NonH1.Checked);
  ini.WriteBool('exhentai','Imageset',Imageset1.Checked);
  ini.WriteBool('exhentai','Cosplay',Cosplay1.Checked);
  ini.WriteBool('exhentai','Asianporn',Asianporn1.Checked);
  ini.WriteBool('exhentai','Misc',Misc1.Checked);

  { if (cbSite.ItemIndex > -1) and
    (pcMenu.ActivePage = tsSettings) then
    begin
    AuthData[cbSite.ItemIndex].Login := eusername.Text;
    AuthData[cbSite.ItemIndex].Password := epassword.Text;
    end; }

  if FSavePWD then
    ini.WriteBool('options', 'savepwd', FSavePWD)
  else
    ini.DeleteKey('options', 'savepwd');

  if chbproxy.Checked then
  begin
    ini.WriteBool('proxy', 'enabled', chbproxy.Checked);
    ini.WriteString('proxy', 'host', eproxyserver.Text);
    ini.WriteInteger('proxy', 'port', eproxyport.AsInteger);
    if chbauth.Checked then
    begin
      ini.WriteBool('proxy', 'auth', chbauth.Checked);
      ini.WriteString('proxy', 'login', eproxylogin.Text);
      if chbsaveproxypwd.Checked then
      begin
        ini.WriteBool('proxy', 'savepwd', chbsaveproxypwd.Checked);
        ini.WriteString('proxy', 'pwd', eproxypassword.Text);
      end
      else
      begin
        ini.DeleteKey('proxy', 'savepwd');
        ini.DeleteKey('proxy', 'pwd');
      end;
    end
    else
    begin
      ini.DeleteKey('proxy', 'auth');
      ini.DeleteKey('proxy', 'login');
      ini.DeleteKey('proxy', 'savepwd');
      ini.DeleteKey('proxy', 'pwd');
    end;
  end
  else
  begin
    ini.DeleteKey('proxy', 'enabled');
    ini.DeleteKey('proxy', 'host');
    ini.DeleteKey('proxy', 'port');
    ini.DeleteKey('proxy', 'auth');
    ini.DeleteKey('proxy', 'login');
    ini.DeleteKey('proxy', 'savepwd');
    ini.DeleteKey('proxy', 'pwd');
  end;

  for i := 0 to RESOURCE_COUNT - 1 do
  begin
    ini.WriteString('authdata' + IntToStr(REV_RVLIST[i]), 'login',
      AuthData[i].Login);
    if FSavePWD then
      ini.WriteString('authdata' + IntToStr(REV_RVLIST[i]), 'pwd',
        AuthData[i].Password)
    else
      ini.DeleteKey('authdata' + IntToStr(REV_RVLIST[i]), 'pwd')
  end;

  ini.Free;
end;

procedure TMainForm.saveparams;
const
  WStates: array [TWindowState] of Integer = (0, 1, 2);

var
  ini: TINIFile;
begin
  ini := TINIFile.Create(ExtractFilePath(paramstr(0)) + 'settings.ini');

  ini.WriteString('parametres', 'dir', DefFolder);
  ini.WriteInteger('parametres', 'destination', cbSite.ItemIndex);
  ini.WriteInteger('parametres', 'width', FNotMaximizedWidth);
  ini.WriteInteger('parametres', 'height', FNotMaximizedHeight);
  ini.WriteInteger('parametres', 'windowstate', WStates[WindowState]);
  ini.WriteBool('parametres', 'loghided',
    pcLogs.Constraints.MaxHeight = TABLIST_HEIGHT);

  ini.WriteInteger('previewwindow', 'left', preview_window_left);
  ini.WriteInteger('previewwindow', 'top', preview_window_top);

  ini.WriteInteger('previewwindow', 'undragleft', preview_window_undrag_left);
  ini.WriteInteger('previewwindow', 'undragtop', preview_window_undrag_top);

  ini.WriteBool('grid', 'autoscroll', chbautoscroll.Checked);

  ini.Free;
end;

procedure TMainForm.SetGridState(b: Boolean);
begin
  if b then
  begin
    Grid.ClearCols(2, 4);
    Grid.ColCount := 6;
    Grid.Cells[2, 0] := 'Dwnlded';
    Grid.Cells[3, 0] := 'Size';
    Grid.Cells[4, 0] := 'Speed';
    Grid.Cells[5, 0] := 'Prgrss';
  end
  else
    Grid.ColCount := 2;
  FormResize(nil);
end;

procedure TMainForm.Show1Click(Sender: TObject);
begin
  JvTrayIcon.ShowApplication;
end;

procedure TMainForm.splLogsCanResize(Sender: TObject; var NewSize: Integer;
  var Accept: Boolean);
begin
  Accept := pcLogs.Constraints.MaxHeight = 0;
  if Accept then
    if (NewSize > pnlMain.Height - pnlGrid.Constraints.MinHeight -
      splLogs.Height) then
      NewSize := pnlMain.Height - pnlGrid.Constraints.MinHeight - splLogs.Height
    else if (NewSize < pcLogs.Constraints.MinHeight) then
      NewSize := pcLogs.Constraints.MinHeight;
end;

procedure TMainForm.splMenuCanResize(Sender: TObject; var NewSize: Integer;
  var Accept: Boolean);
var
  ns: Integer;
  a: Boolean;
begin
  Accept := pcMenu.Constraints.MaxHeight = 0;
  if Accept and (NewSize > MainForm.ClientHeight - pnlMain.Constraints.MinHeight
    - StatusBar.Height - splMenu.Height) then
  begin
    NewSize := MainForm.ClientHeight - pnlMain.Constraints.MinHeight -
      StatusBar.Height - splMenu.Height;
  end;
  ns := pcLogs.Height;
  splLogsCanResize(nil, ns, a);
  if a then
    pcLogs.Height := ns;
end;

procedure TMainForm.splMenuMoved(Sender: TObject);
var
  ns: Integer;
  a: Boolean;
begin
  ns := pcLogs.Height;
  splLogsCanResize(nil, ns, a);
  if a then
    pcLogs.Height := ns;
end;

procedure TMainForm.SpTBXItem1Click(Sender: TObject);
begin
  fmAbout.Show;
end;

procedure TMainForm.tbiLoadClick(Sender: TObject);
begin
  if odList.Execute then
  begin
    block(0, 0);

    loading := true;

    hitcheck := -1;

    nm := 0;

    LoadFromFile(odList.FileName);

    block(1, 0);
    loading := false;
  end;
end;

procedure TMainForm.tbiLogsHideClick(Sender: TObject);
var
  tmp: Boolean;
begin
  if pcLogs.Constraints.MinHeight = LOG_MIN_HEIGHT then
  begin
    pcLogsActiveTabChanging(pcLogs, pcLogs.ActiveTabIndex, -1, tmp);
    FPCLogOldHeight := pcLogs.Height;
    pcLogs.ActiveTabIndex := -1;
    pcLogs.Constraints.MinHeight := TABLIST_HEIGHT;
    pcLogs.Constraints.MaxHeight := TABLIST_HEIGHT;
    // splLogs.Visible := false;
    tbiLogsHide.ImageIndex := 1;
  end
  else
  begin
    pcLogsActiveTabChanging(pcLogs, -1, 0, tmp);
    pcLogs.ActiveTabIndex := 0;
  end;
end;

procedure TMainForm.tbiCloseClick(Sender: TObject);
begin
  SendMessage(MainForm.Handle, WM_SYSCOMMAND, SC_Close, 0);
end;

procedure TMainForm.tbiGridCloseClick(Sender: TObject);
begin
  if MessageDlg('Are you realy want to clear list?', mtConfirmation,
    [mbYes, mbNo], 0) = mrYes then
  begin
    n := nil;
    tags := nil;
    // Authors := nil;
    PreList := nil;
    curdest := -1;
    curtag := '';
    curcategory := '';
    DrawImageFromRes(bgimage, 'ZNYA', '.png');
    GenGrid;
    GenTags;
    lbRelatedTags.Clear;
    euserid.Value := 0;
    UpdateDataInterface;
    block(1, 0);
  end;
end;

procedure TMainForm.tbiMaximizeClick(Sender: TObject);
begin
  if WindowState = wsMaximized then
  begin
    tbiMaximize.ImageIndex := 1;
    SendMessage(MainForm.Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
  end
  else
  begin
    tbiMaximize.ImageIndex := 3;
    SendMessage(MainForm.Handle, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
  end;
end;

procedure TMainForm.tbiMenuHideClick(Sender: TObject);
var
  tmp: Boolean;
begin
  if pcMenu.Constraints.MinHeight = MENU_MIN_HEIGHT then
  begin
    pcMenuActiveTabChanging(pcMenu, pcMenu.ActiveTabIndex, -1, tmp);
    FPreviousTab := pcMenu.ActiveTabIndex;
    FPCMenuOldHeight := pcMenu.Height;
    pcMenu.ActiveTabIndex := -1;
    pcMenu.Constraints.MinHeight := TABLIST_HEIGHT;
    pcMenu.Constraints.MaxHeight := TABLIST_HEIGHT;
    splMenu.Visible := false;
    tbiMenuHide.ImageIndex := 0;
  end
  else
  begin
    pcMenuActiveTabChanging(pcMenu, -1, FPreviousTab, tmp);
    pcMenu.ActiveTabIndex := FPreviousTab;
  end;
end;

procedure TMainForm.tbiMinimizeClick(Sender: TObject);
begin
  SendMessage(MainForm.Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
end;

procedure TMainForm.tbiSaveClick(Sender: TObject);
begin
  if Length(n) = 0 then
  begin
    MessageDlg('Image list just little too empty.', mtInformation, [mbOk], 0);
    Exit;
  end;

  if sdList.Execute then
  begin
    block(0, 0);
    SaveToFile(sdList.FileName, sdList.FilterIndex, nil);
    block(1, 0);
  end;
end;

procedure TMainForm.tbrasiMenuClick(Sender: TObject);
const
  SC_DRAGMOVE = $F012;
begin
  ShowMessage('Push me, baby');
end;

procedure TMainForm.btnSelAllClick(Sender: TObject);
begin
  case pcTags.ActivePageIndex of
    0:
      chblTagsCloud.CheckAll(cbChecked);
    { 2:
      chblTagsAuthors.CheckAll(cbChecked); }
  end;
end;

procedure TMainForm.btnDeselAllClick(Sender: TObject);
begin
  case pcTags.ActivePageIndex of
    0:
      chblTagsCloud.CheckAll(cbUnchecked);
    { 2:
      chblTagsAuthors.CheckAll(cbUnchecked); }
  end;
end;

procedure TMainForm.btnFindTagClick(Sender: TObject);
begin
  fdTag.Execute(Self.Handle);
end;

procedure TMainForm.btnSelInverseClick(Sender: TObject);
begin
  case pcTags.ActivePageIndex of
    0:
      chblTagsCloud.CheckInverse;
    2:
      chblTagsCloud.CheckInverse;
  end;
end;

procedure TMainForm.pcLogsActiveTabChanging(Sender: TObject;
  TabIndex, NewTabIndex: Integer; var Allow: Boolean);
begin
  case TabIndex of
    - 1:
      if pcLogs.Constraints.MaxHeight = TABLIST_HEIGHT then
      begin
        pcLogs.Constraints.MinHeight := LOG_MIN_HEIGHT;
        pcLogs.Constraints.MaxHeight := 0;
        pcLogs.Height := FPCLogOldHeight;
        // splLogs.Visible := true;
        tbiLogsHide.ImageIndex := 0;
      end;
  end;
end;

procedure TMainForm.pcMenuActiveTabChange(Sender: TObject; TabIndex: Integer);
begin
  case TabIndex of
    1:
      if cbSite.Enabled and cbSite.Visible and not loading then
        cbSite.SetFocus;
    4:
      begin
        if not(prgress = 0) then
        begin
          if (Length(n) > 0) then
            mPicInfo.Text := GetNInfo(Grid.Row - 1)
          else
            mPicInfo.Clear;
          if assigned(fPreview) then
            if chbPreview.Checked then
            begin
              ShowWindow(fPreview.Handle, SW_SHOWNOACTIVATE);
              // SetFocus;
              if (RowCount > 0) and (curdest > -1) then
                if Length(n) > 0 then
                  fPreview.Execute(n[Grid.Row - 1].Preview,
                    RESOURCE_URLS[curdest] + n[Grid.Row - 1].pageurl,
                    n[Grid.Row - 1].title)
                else if Length(PreList) > 0 then
                  fPreview.Execute(PreList[Grid.Row - 1].Preview,
                    PreList[Grid.Row - 1].URL)
                else
              else
                fPreview.Execute('');
            end;
        end;
      end;
    6:
      begin
        splMenu.Hide;
        pnlMain.Hide;
        FPCMenuOldHeight := pcMenu.Height;
        pcMenu.Align := alClient;
        iLain.Visible := true;
        { eusername.Text := AuthData[cbSite.ItemIndex].Login;
          epassword.Text := AuthData[cbSite.ItemIndex].Password; }
      end;
  end;
end;

procedure TMainForm.pcMenuActiveTabChanging(Sender: TObject;
  TabIndex, NewTabIndex: Integer; var Allow: Boolean);
begin
  case NewTabIndex of
    2:
      begin
        Allow := false;
      end;
    3:
      begin
        Allow := false;
      end;
  else
    case TabIndex of
      - 1:
        if pcMenu.Constraints.MaxHeight = TABLIST_HEIGHT then
        begin
          pcMenu.Constraints.MinHeight := MENU_MIN_HEIGHT;
          pcMenu.Constraints.MaxHeight := 0;
          pcMenu.Height := FPCMenuOldHeight;
          splMenu.Visible := true;
          tbiMenuHide.ImageIndex := 1;
        end;
      4:
        if NewTabIndex <> 4 then
        begin
          ShowWindow(fPreview.Handle, SW_HIDE);
          fPreview.OnHide(nil);
        end;
      6:
        if (NewTabIndex <> 6) then
        begin
          if cbSite.ItemIndex > -1 then
          begin
            { AuthData[cbSite.ItemIndex].Login := eusername.Text;
              AuthData[cbSite.ItemIndex].Password := epassword.Text; }
          end;
          iLain.Visible := false;
          pcMenu.Align := alTop;
          pcMenu.Height := FPCMenuOldHeight;
          pnlMain.Show;
          splMenu.Show;
          FormResize(nil);
        end;
    end;
  end;
end;

procedure TMainForm.pcMenuMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  TransparentClick: Boolean;
  P: TPoint;
  f: TForm;
begin
  // Move the Parent Form if the toolbar client area or an item with
  // tbisClicksTransparent itemstyle is clicked (like a TBXLabelItem)
  // if not (csDesigning in ComponentState) then begin
  // TitleBar := pcMenu;
  f := MainForm;
  // if not Assigned(F) or not Assigned(TitleBar) then Exit;
  // if not TitleBar.IsActive then Exit;

  if assigned(pcMenu.View.Selected) then
    TransparentClick := tbisClicksTransparent
      in TTBCustomItemAccess(pcMenu.View.Selected.Item).ItemStyle
  else
    TransparentClick := true;

  case Button of
    mbLeft:
      if TransparentClick then
      begin
        if ssDouble in Shift then
        begin
          // Maximize or restore when double clicking the toolbar
          // if TitleBar.Options.Maximize and not TitleBar.FixedSize then
          tbiMaximize.Click;
        end
        else if f.WindowState <> wsMaximized then
        begin
          // Drag the form when dragging the toolbar
          ReleaseCapture;
          SendMessage(f.Handle, WM_SYSCOMMAND, $F012, 0);
        end;
        // Exit; // Do not process transparent clicks
      end
      { else
        if (ssDouble in Shift) and TitleBar.Options.SystemMenu then begin
        // Close the form when the system menu button is double clicked
        IV := pcMenu.View.ViewerFromPoint(Point(X, Y));
        if Assigned(IV) and (IV.Item = pcMenu.Options.SystemButton) then begin
        F.Close;
        Exit; // Do not process transparent clicks
        end;
        end };
    mbRight:
      if TransparentClick { and TitleBar.Options.SystemMenu } then
      begin
        P := ClientToScreen(Point(X, Y));
        SpShowSystemPopupMenu(MainForm, P);
        // Exit; // Do not process transparent clicks
      end;
  end;
  // end;

end;

procedure TMainForm.ThreadTerminate(Sender: TObject);
var
  f: textfile;
  i: Integer;
begin
  FThreadList.Remove(Sender);
  dec(threadnum);
  if threadnum = 0 then
  begin
    fStoping.Stop;
    FreeAndNil(FThreadList);
    if (prgress = 2) then
      log('Downloading aborted')
    else
    begin
      if chbTagsIn.Visible and chbTagsIn.Checked and
        (cbTagsIn.ItemIndex = 1) then
      begin
        assignfile(f, IncludeTrailingPathDelimiter(edir.Text) +
          ValidFName(curtag + ' [' +
          trim(DeleteTo(DeleteTo(RESOURCE_URLS[curdest], ':/'), 'www.'), '/') +
          '] ' + FormatDateTime('yyyy-mm-dd', Date) + '.csv'));
        rewrite(f);
        for i := 0 to Length(n) - 1 do
          if curdest = RP_RMART then
            writeln(f, emptyname(REPLACE(n[i].URL, '/Src/Image', '')) + ';' +
              ClearHTML(TagString(n[i].tags)))
          else
            writeln(f, emptyname(n[i].URL) + ';' +
              ClearHTML(TagString(n[i].tags)));
        closefile(f);
      end;

      if not Application.Active then
        JvTrayIcon.BalloonHint('Completed',
          'Pictures downloading is completed', btInfo);
      log('Downloading completed without critical errors');
      if chbShutdown.Checked then
      begin
        FSHUTDOWN := true;
        Shutdown;
      end
      else if CloseAfterFinish then
        Close
      else if cbLetter.Enabled then
      begin
        mciSendString(PChar('open ' + FDrive +
          ': type cdaudio alias GraberDrive' + FDrive + ' shareable wait'), nil,
          0, Handle);
        mciSendString(PChar('Set GraberDrive' + FDrive + ' door open wait'),
          nil, 0, Handle);
      end;
      prgress := 1;
    end;

    if AutoMode then
      AutoMode := false;
    SetGridState(false);
    DWNLDProc(0);
    block(1, 2);
  end;
end;

procedure TMainForm.tsiPicListDrawCaption(Sender: TObject; ACanvas: TCanvas;
  ClientAreaRect: TRect; State: TSpTBXSkinStatesType; var ACaption: WideString;
  var CaptionRect: TRect; var CaptionFormat: Cardinal; IsTextRotated: Boolean;
  const PaintStage: TSpTBXPaintStage; var PaintDefault: Boolean);
begin
  PaintDefault := false;
  // ACanvas.tex
  Canvas.Font.Color := clBtnHighlight;
  SpDrawXPText(ACanvas, ACaption, ClientAreaRect, CaptionFormat or DT_VCENTER or
    DT_CENTER);
end;

procedure TMainForm.updatecaption(s: string = '');
begin
  if s = '' then
    Application.title := cpt
  else
    Application.title := s + ' ' + cpt;
end;

procedure TMainForm.updateinterface;
begin
  chbauth.Enabled := chbproxy.Enabled and chbproxy.Checked;
  eproxylogin.Enabled := chbauth.Enabled and chbauth.Checked;
  eproxypassword.Enabled := chbauth.Enabled and chbauth.Checked;
  chbsaveproxypwd.Enabled := eproxypassword.Enabled;
  eproxyport.Enabled := chbproxy.Enabled and chbproxy.Checked;
  eproxyserver.Enabled := chbproxy.Enabled and chbproxy.Checked;
  cbLetter.Enabled := chbOpenDrive.Enabled and chbOpenDrive.Checked;
  chbTaskbar.Enabled := chbTrayIcon.Enabled and chbTrayIcon.Checked;
  eAutoDirName.Enabled := chbAutoDirName.Checked and chbAutoDirName.Enabled;
  eNameFormat.Enabled := chbNameFormat.Checked and chbNameFormat.Enabled;
  cbTagsIn.Enabled := chbTagsIn.Checked and chbTagsIn.Enabled;
end;

procedure TMainForm.updateskin;
var
  btnFace, { btnHighlight, } btnShadow, wnd, menu, menuBar, menuHilight,
    menuText, highlightText: TColor;
  btnFace2, btnHot1, btnHot2, btnNrml: TColor;
begin
  btnFace := GETSYSCOLOR(COLOR_BTNFACE);;
  btnFace2 := MIN($FFFFFF, btnFace + $101010);
  btnHot1 := MIN($FFFFFF, btnFace + $080808);
  btnHot2 := Max($000000, btnFace - $080808);
  btnNrml := Max($000000, btnFace - $101010);
  // btnHighlight := GETSYSCOLOR(COLOR_BTNHIGHLIGHT);
  btnShadow := GETSYSCOLOR(COLOR_BTNSHADOW);
  wnd := GETSYSCOLOR(COLOR_WINDOW);
  menu := GETSYSCOLOR(COLOR_MENU);
  menuBar := GETSYSCOLOR(COLOR_MENUBAR);
  menuHilight := GETSYSCOLOR(COLOR_MENUHILIGHT);
  menuText := GETSYSCOLOR(COLOR_MENUTEXT);
  highlightText := GETSYSCOLOR(COLOR_HIGHLIGHTTEXT);

  SkinManager.SetSkin('graberskin');
  with CurrentSkin do
  begin
    // CurrentSkin.LoadFromFile(ExtractFileDir(paramstr(0))+'skin.skn');
    SkinName := '';
    SkinAuthor := '';

    // ---- Single State ----//
    Options(skncDock, sknsNormal).Body.Fill(0, wnd, clNone, clNone, clNone);

    Options(skncDockablePanel, sknsNormal).Body.Fill(0, wnd, clNone,
      clNone, clNone);

    Options(skncDockablePanelTitleBar, sknsNormal).Body.Fill(0, wnd, clNone,
      clNone, clNone);
    with Options(skncPanel, sknsNormal) do
    begin
      Borders.Fill(0, btnShadow, btnShadow, clNone, clNone);
      Body.Fill(0, wnd, clNone, clNone, clNone);
    end;

    Options(skncPopup, sknsNormal).Body.Fill(0, menu, clNone, clNone, clNone);
    Options(skncPopup, sknsNormal).Borders.Fill(0, btnShadow, btnShadow,
      clNone, clNone);
    Options(skncMenuItem, sknsHotTrack).Body.Fill(0, menuHilight, clNone,
      clNone, clNone);
    Options(skncMenuItem, sknsNormal).TextColor := menuText;
    Options(skncMenuItem, sknsHotTrack).TextColor := highlightText;

    Options(skncStatusBar, sknsNormal).Body.Fill(0, wnd, clNone,
      clNone, clNone);

    Options(skncSplitter, sknsNormal).Body.Fill(0, wnd, clNone, clNone, clNone);

    Options(skncToolbar, sknsNormal).Body.Fill(0, menuBar, clNone,
      clNone, clNone);

    CopyOptions(skncToolbar, skncMenuBar);

    // Options(skncWindow, sknsNormal).Borders.Fill(0, $808080, $808080, $C0C0C0, $DDD9D2);

    // Options(skncWindowTitleBar, sknsNormal).Body.Fill(0, clBtnFace, clNone, clNone, clNone);

    // ---- Elements ----//
    Options(skncToolbarGrip, sknsNormal).Body.Fill(0, wnd, clWhite,
      clNone, clNone);

    Options(skncStatusBarGrip, sknsNormal).Body.Fill(0, wnd, clWhite,
      clNone, clNone);

    // Options(skncSeparator, sknsNormal).Body.Fill(0, $869999, clNone, clNone, clNone);

    // Options(skncEdit, sknsNormal).Body.Fill(1, btnFace, btnNrml, clNone, clNone);

    //

    Options(skncButton, sknsNormal).Borders.Fill(2, btnShadow, btnShadow,
      clNone, clNone);
    Options(skncButton, sknsHotTrack).Body.Fill(1, btnHot1, btnHot2,
      clNone, clNone);
    Options(skncButton, sknsHotTrack).Borders.Fill(2, clBtnShadow, clBtnShadow,
      clNone, clNone);
    Options(skncButton, sknsPushed).Body.Fill(1, btnFace2, btnFace,
      clNone, clNone);
    Options(skncButton, sknsPushed).Borders.Fill(2, btnShadow, btnShadow,
      clNone, clNone);
    Options(skncButton, sknsDisabled).Body.Fill(1, btnFace, btnNrml,
      clNone, clNone);
    Options(skncButton, sknsDisabled).Borders.Fill(2, clBtnShadow, clBtnShadow,
      clNone, clNone);

    // ---- Buttons ----//

    Options(skncToolBarItem, sknsNormal).Body.Fill(1, btnFace, btnNrml,
      clNone, clNone);
    Options(skncToolBarItem, sknsNormal).Borders.Fill(2, clNone, clNone,
      btnShadow, btnShadow);
    Options(skncToolBarItem, sknsHotTrack).Body.Fill(1, btnHot1, btnHot2,
      clNone, clNone);
    Options(skncToolBarItem, sknsHotTrack).Borders.Fill(2, clNone, clNone,
      clBtnShadow, clBtnShadow);
    Options(skncToolBarItem, sknsPushed).Body.Fill(1, btnFace2, btnFace,
      clNone, clNone);
    Options(skncToolBarItem, sknsPushed).Borders.Fill(2, clNone, clNone,
      btnShadow, btnShadow);
    Options(skncToolBarItem, sknsDisabled).Body.Fill(1, btnFace, btnNrml,
      clNone, clNone);
    Options(skncToolBarItem, sknsDisabled).Borders.Fill(2, clNone, clNone,
      clBtnShadow, clBtnShadow);

    Options(skncButton, sknsNormal).Body.Fill(1, btnFace, btnNrml,
      clNone, clNone);
    Options(skncButton, sknsNormal).Borders.Fill(2, btnShadow, btnShadow,
      clNone, clNone);
    Options(skncButton, sknsHotTrack).Body.Fill(1, btnHot1, btnHot2,
      clNone, clNone);
    Options(skncButton, sknsHotTrack).Borders.Fill(2, clBtnShadow, clBtnShadow,
      clNone, clNone);
    Options(skncButton, sknsPushed).Body.Fill(1, btnFace2, btnFace,
      clNone, clNone);
    Options(skncButton, sknsPushed).Borders.Fill(2, btnShadow, btnShadow,
      clNone, clNone);
    Options(skncButton, sknsDisabled).Body.Fill(1, btnFace, btnNrml,
      clNone, clNone);
    Options(skncButton, sknsDisabled).Borders.Fill(2, clBtnShadow, clBtnShadow,
      clNone, clNone);

    Options(skncCheckBox, sknsNormal).Body.Fill(1, btnFace, btnNrml,
      clNone, clNone);
    Options(skncCheckBox, sknsNormal).Borders.Fill(2, btnShadow, btnShadow,
      clNone, clNone);
    Options(skncCheckBox, sknsDisabled).Body.Fill(1, btnFace, btnNrml,
      clNone, clNone);
    Options(skncCheckBox, sknsDisabled).Borders.Fill(2, btnShadow, btnShadow,
      clNone, clNone);
    Options(skncCheckBox, sknsChecked).Body.Fill(1, btnFace2, btnFace,
      clNone, clNone);
    Options(skncCheckBox, sknsChecked).Borders.Fill(2, btnShadow, btnShadow,
      clNone, clNone);
    Options(skncCheckBox, sknsHotTrack).Body.Fill(1, btnHot1, btnHot2,
      clNone, clNone);
    Options(skncCheckBox, sknsHotTrack).Borders.Fill(2, btnShadow, btnShadow,
      clNone, clNone);
    Options(skncCheckBox, sknsCheckedAndHotTrack).Body.Fill(1, btnFace2,
      btnFace, clNone, clNone);
    Options(skncCheckBox, sknsCheckedAndHotTrack).Borders.Fill(2, btnShadow,
      btnShadow, clNone, clNone);
    Options(skncCheckBox, sknsPushed).Body.Fill(1, btnFace2, btnFace,
      clNone, clNone);
    Options(skncCheckBox, sknsPushed).Borders.Fill(2, btnShadow, btnShadow,
      clNone, clNone);
    // ---- Editors ----//
    // Options(skncEditFrame, sknsNormal).Borders.Fill(1, clNone, clNone, $D0D0D0, $D0D0D0);
    // Options(skncEditFrame, sknsDisabled).Borders.Fill(1, clNone, clNone, $99A8AC, $99A8AC);
    // Options(skncEditFrame, sknsHotTrack).Borders.Fill(1, clNone, clNone, $94A0A0, $94A0A0);

    // CopyOptions(skncToolbarItem, skncEditButton);
    // Options(skncEditButton, sknsNormal).TextColor := clBlack;

    // ---- Tabs ----//
    Options(skncTab, sknsNormal).Body.Fill(1, btnFace, btnNrml, clNone, clNone);
    Options(skncTab, sknsNormal).Borders.Fill(2, btnShadow, btnShadow,
      clNone, clNone);
    Options(skncTab, sknsChecked).Body.Fill(1, btnFace2, btnFace,
      clNone, clNone);
    Options(skncTab, sknsChecked).Borders.Fill(2, btnShadow, btnShadow,
      clNone, clNone);
    Options(skncTab, sknsHotTrack).Body.Fill(1, btnHot1, btnHot2,
      clNone, clNone);
    Options(skncTab, sknsHotTrack).Borders.Fill(2, btnShadow, btnShadow,
      clNone, clNone);
    Options(skncTab, sknsCheckedAndHotTrack).Body.Fill(1, btnFace2, btnFace,
      clNone, clNone);
    Options(skncTab, sknsCheckedAndHotTrack).Borders.Fill(2, btnShadow,
      btnShadow, clNone, clNone);
    Options(skncTab, sknsDisabled).Body.Fill(1, btnFace, btnNrml,
      clNone, clNone);
    Options(skncTab, sknsDisabled).Borders.Fill(2, btnShadow, btnShadow,
      clNone, clNone);

    // TabBackground: Only Normal state is used
    Options(skncTabBackground, sknsNormal).Body.Fill(0, btnFace, clNone,
      clNone, clNone);
    Options(skncTabBackground, sknsNormal).Borders.Fill(0, btnShadow, btnShadow,
      clNone, clNone);

    // ---- ProgressBar ----//
    // ProgressBar: Only Normal and HotTrack states are used
    // HotTrack represents the selection
    // Options(skncProgressBar, sknsNormal).Body.Fill(0, $809090, clNone, clNone, clNone);
    // Options(skncProgressBar, sknsNormal).Borders.Fill(0, $5A6666, $5A6666, clNone, clNone);
    // Options(skncProgressBar, sknsHotTrack).Body.Fill(0, $94A0A0, clNone, clNone, clNone);
    // Options(skncProgressBar, sknsHotTrack).Borders.Fill(1, $5A6666, $5A6666, clNone, clNone);

    // ---- TrackBar ----//
    // TrackBar: Only Normal and HotTrack states are used
    // HotTrack represents the selection
    CopyOptions(skncProgressBar, skncTrackBar);

    // TrackBarButton: Only Normal and Pushed states are used

    // ---- Header ----//
  end;
  SkinManager.BroadcastSkinNotification;
end;

procedure TMainForm.UpdateTimerTimer(Sender: TObject);
begin
  StatusBar.SimpleText := 'OK ' + IntToStr(nok) + ' MISS ' + IntToStr(nmiss) +
    ' ERR ' + IntToStr(nerr) + ' SKIP ' + IntToStr(nskip) + ' TTL ' +
    IntToStr(nok + nmiss + nerr + nskip) + ' OVERALL ' +
    FloatToStr(RoundTo(diff(ncmpl, nsel) * 100, -2)) + '%';
end;

function TMainForm.UpdLogin(iindex: Integer): boolean;
begin
  Result := false;
  with fmLogin do
  begin
    Caption := 'Login to  ' + cbSite.Items[iindex];
    eLogin.Text := AuthData[iindex].Login;
    ePassword.Text := AuthData[iindex].Password;
    chbSavePWD.Checked := FSavePWD;
    ShowModal;
    if ModalResult = mrOK then
    begin
      Result := true;
      AuthData[iindex].Login := eLogin.Text;
      AuthData[iindex].Password := ePassword.Text;
      FSavePWD := chbSavePWD.Checked;
    end;
  end;
end;

procedure TMainForm.btnCancelClick(Sender: TObject);
begin
  if (prgress = 0) and
    (MessageDlg('Program working. Are you realy want to cancel?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
  begin
    prgress := 2;
    if assigned(FThreadList) then
      fStoping.Execute('Closing...','Waiting...','Force ',2000,5);
  end;
end;

procedure TMainForm.btnCatEditClick(Sender: TObject);
var
  s: TStringList;
begin
  s := TStringList.Create;
  s.Text := MemoDlg('Categories list', 'input list:',
    strtostrlist(eCategory.Text), CategoryPaste);
  if s.Text <> '' then
    eCategory.Text := strlisttostr(s);
  FreeAndNil(s);
end;

procedure TMainForm.btnTagEditClick(Sender: TObject);
var
  s: TStringList;
begin
  s := TStringList.Create;
  s.Text := MemoDlg('Tags list', 'input list:', strtostrlist(eTag.Text, ' ',
    #0), CategoryPaste);
  if s.Text <> '' then
    eTag.Text := strlisttostr(s, ' ', #0);
  FreeAndNil(s);
end;

procedure TMainForm.btnGrabClick(Sender: TObject);
var
  i: Integer;
  // s: TStringList;
  // SHTTP: TidHTTP;
begin
  if threadnum > 0 then
    Exit;
  if (curdest < 0) and not AutoMode then
  begin
    MessageDlg('First you must get a list', mtInformation, [mbOk], 0);
    Exit;
  end;
  edir.Text := IncludeTrailingPathDelimiter(edir.Text);
  block(0, 2);

  if JvTrayIcon.Active then
    JvTrayIcon.Icon := IconMaker.MakeIcon(0);

  FDrive := cbLetter.Drive;

  // eQueryI2.Value := eQueryI.Value;

  saveparams;
  saveoptions;
  log('Downloading pictures from ' + cbSite.Text);

  if not AutoMode then
    merrors.Clear;

  nok := 0;
  nerr := 0;
  nmiss := 0;
  nskip := 0;
  ncmpl := 0;
  nsel := 0;

  prgrsbr.SetState(pbsNormal);

  for i := 0 to Length(n) - 1 do
    if n[i].chck then
      inc(nsel);

  if nsel > 0 then
    try
      if not DirectoryExists(ExtractFileDir(edir.Text)) then
        CreateDirExt(ExtractFileDir(edir.Text));
    except
      on E: Exception do
      begin
        LogErr('Can''t create path for saving: ' + E.Message);
        Exit;
      end;
    end;

  try
    Login(curdest);

    nm := 0;

    if not(prgress = 0) then
    begin
      block(1, 2);
      Exit;
    end;

    prgrsbr.Max := nsel;
    SetGridState(true);

    if nsel > 0 then
    begin
      FThreadList := TThreadList.Create;
      for i := 1 to MIN(nsel, eThreadCount.AsInteger) do
        FThreadList.Add(CreateThread);
      saved := false;
    end
    else
    begin
      prgrsbr.Position := 0;
      SetGridState(false);
      block(1, 2);
      if AutoMode then
        AutoMode := false;
    end;

    saved := false;

  except
    on E: Exception do
    begin

      LogErr('Error: ' + E.Message);
      prgress := -1;
      if threadnum = 0 then
      begin
        prgrsbr.Position := 0;
        SetGridState(false);
        block(-1, 2);
        if AutoMode then
          AutoMode := false;
      end;
    end;
  end;
end;

procedure TMainForm.XmlStartTag(ATag: String; Attrs: TAttrList);
begin
  case cbSite.ItemIndex of
    RP_GELBOORU, RP_BOORU_II, RP_XXX_RULE34, RP_TBIB:
      begin
        if (ATag = 'a') then
          if tstart = 1 then
            tmpurl := Attrs.Value('href')
          else if Attrs.Value('alt') = 'next' then
            nxt := Attrs.Value('href');
        if (ATag = 'span') and (pos('thumb', Attrs.Value('class')) > 0) then
          tstart := 1;
      end;
    RP_DONMAI_DANBOORU, RP_DONMAI_HIJIRIBE, RP_DONMAI_SONOHARA, RP_BEHOIMI,
      RP_WILDCRITTERS, RP_NEKOBOORU:
      if chbInPools.Checked then
        if (tstart = 0) then
          if (ATag = 'div') and (Attrs.Value('id') = 'pool-index') then
            tstart := 1
          else if (ATag = 'div') and (Attrs.Value('class') = 'pagination') then
            tstart := 3
          else
        else if (tstart = 1) then
          if (ATag = 'div') then
            tstart := -2
          else if (ATag = 'td') then
            tstart := 2
          else
        else if (tstart = 2) then
          if (ATag = 'a') and
            not((xml_tmpi > 0) and (PreList[xml_tmpi - 1].AType = '')) then
          begin
            xml_tmpi := Length(PreList) + 1;
            SetLength(PreList, xml_tmpi);
            PreList[xml_tmpi - 1].Name := '';
            PreList[xml_tmpi - 1].AType := '';
            PreList[xml_tmpi - 1].URL := RESOURCE_URLS[cbSite.ItemIndex] +
              trim(Attrs.Value('href'), '/');
            PreList[xml_tmpi - 1].chck := false;
            PreList[xml_tmpi - 1].Preview := '';
          end
          else
        else if (tstart = 3) and (ATag = 'a') then
        begin
          tmp := Attrs.Value('href');
          tstart := 4;
        end
        else if (tstart = -1) then
          if (ATag = 'span') and (pos('thumb', Attrs.Value('class')) > 0) then
            tstart := 5
          else if (ATag = 'div') and (Attrs.Value('class') = 'pagination') then
            tstart := 6
          else
        else if tstart = 5 then
          if (ATag = 'a') then
            tmpurl := Attrs.Value('href')
          else if (ATag = 'img') and (pos('preview', Attrs.Value('class')) > 0)
            and (emptyname(Attrs.Value('src')) <> 'download-preview.png') then
          begin
            if pos('://', Attrs.Value('src')) > 0 then
              xml_tmpi :=
                AddN(REPLACE(REPLACE(Attrs.Value('src'), '/preview/', '/'),
                '/ssd/', '/'))
            else
              xml_tmpi := AddN(RESOURCE_URLS[cbSite.ItemIndex] +
                trim(REPLACE(REPLACE(Attrs.Value('src'), '/preview/', '/'),
                '/ssd/', '/'), '/'));
            if xml_tmpi <> -1 then
            begin
              n[xml_tmpi].title := PreList[curPreItem].Name;
              n[xml_tmpi].pageurl := tmpurl;
              if pos('://', Attrs.Value('src')) > 0 then
                n[xml_tmpi].Preview := Attrs.Value('src')
              else
                n[xml_tmpi].Preview := RESOURCE_URLS[cbSite.ItemIndex] +
                  trim(Attrs.Value('src'), '/');
              n[xml_tmpi].tags :=
                AddTags(CopyTo(Attrs.Value('alt'), ' score:'));
            end
            else
          end
          else
        else if (tstart = 6) and (ATag = 'a') then
        begin
          tmp := Attrs.Value('href');
          tstart := 7;
        end
        else

      else if (ATag = 'img') and (pos('preview', Attrs.Value('class')) > 0) and
        (emptyname(Attrs.Value('src')) <> 'download-preview.png') then
      begin
        if pos('://', Attrs.Value('src')) > 0 then
          xml_tmpi := AddN(REPLACE(REPLACE(Attrs.Value('src'), '/preview/',
            '/'), '/ssd/', '/'))
        else
          xml_tmpi := AddN(RESOURCE_URLS[cbSite.ItemIndex] +
            trim(REPLACE(REPLACE(Attrs.Value('src'), '/preview/', '/'), '/ssd/',
            '/'), '/'));
        if xml_tmpi <> -1 then
        begin
          if pos('://', Attrs.Value('src')) > 0 then
            n[xml_tmpi].Preview := Attrs.Value('src')
          else
            n[xml_tmpi].Preview := RESOURCE_URLS[cbSite.ItemIndex] +
              trim(Attrs.Value('src'), '/');
          n[xml_tmpi].tags := AddTags(CopyTo(Attrs.Value('alt'), ' score:'));
          n[xml_tmpi].pageurl := tmpurl;
        end;
      end
      else if (ATag = 'div') and (Attrs.Value('class') = 'pagination') then
        tstart := 1
      else if (ATag = 'span') and (pos('thumb', Attrs.Value('class')) > 0) then
        tstart := 3
      else if (ATag = 'a') then
        case (tstart) of
          1:
            begin
              tmp := Attrs.Value('href');
              tstart := 2;
            end;
          3:
            tmpurl := Attrs.Value('href');
        end;
    RP_KONACHAN, RP_IMOUTO:
      begin
        if chbInPools.Checked then
          if (tstart = 0) then
            if (ATag = 'div') and (Attrs.Value('id') = 'pool-index') then
              tstart := 1
            else if (ATag = 'div') and
              (Attrs.Value('class') = 'pagination') then
              tstart := 3
            else
          else if (tstart = 1) then
            if (ATag = 'div') then
              tstart := -2
            else if (ATag = 'td') then
              tstart := 2
            else
          else if (tstart = 2) then
            if (ATag = 'a') then
            begin
              xml_tmpi := Length(PreList) + 1;
              SetLength(PreList, xml_tmpi);
              PreList[xml_tmpi - 1].Name := '';
              PreList[xml_tmpi - 1].AType := '';
              PreList[xml_tmpi - 1].URL := RESOURCE_URLS[cbSite.ItemIndex] +
                trim(Attrs.Value('href'), '/');
              PreList[xml_tmpi - 1].chck := false;
              PreList[xml_tmpi - 1].Preview := '';
            end
            else
          else if (tstart = 3) and (ATag = 'a') then
          begin
            tmp := Attrs.Value('href');
            tstart := 4;
          end
          else if (tstart = -1) then
            if (ATag = 'a') and (Attrs.Value('class') = 'thumb') then
              tmpurl := Attrs.Value('href')
            else if (ATag = 'img') and
              (pos('preview', Attrs.Value('class')) > 0) then
            begin
              xml_tmpi := AddN(REPLACE(RESOURCE_URLS[cbSite.ItemIndex],
                'oreno.', 'yusa.') + 'image/' +
                emptyname(deleteids(Attrs.Value('src'))));
              if xml_tmpi <> -1 then
              begin
                n[xml_tmpi].title := PreList[curPreItem].Name;
                n[xml_tmpi].pageurl := tmpurl;
                n[xml_tmpi].Preview := Attrs.Value('src');
                n[xml_tmpi].tags :=
                  AddTags(CopyFromTo(Attrs.Value('alt'), 'Tags: ', ' User:'));
              end;
            end
            else
          else

        else if (tstart = 0) then
          if (ATag = 'div') then
            if (Attrs.Value('class') = 'inner') then
            begin
              xml_tmpi := AddN('');
              tstart := 3;
            end
            else if (ATag = 'div') and
              (Attrs.Value('class') = 'pagination') then
              tstart := 1
            else
          else if (ATag = 'a') and
            (pos('directlink', Attrs.Value('class')) > 0) then
            n[xml_tmpi].URL := deleteids(Attrs.Value('href'), true)
          else if (ATag = 'span') and
            (pos('directlink-res', Attrs.Value('class')) > 0) then
            tstart := 4
          else
        else if (tstart = 1) and (ATag = 'a') then
        begin
          tmp := Attrs.Value('href');
          tstart := 2;
        end
        else if (tstart = 3) then
          if (ATag = 'img') and (pos('preview', Attrs.Value('class')) > 0) then
          begin
            n[xml_tmpi].Preview := Attrs.Value('src');
            n[xml_tmpi].tags := AddTags(CopyFromTo(Attrs.Value('alt'), 'Tags: ',
              ' User:'));
          end
          else if (ATag = 'a') then
            if (pos('thumb', Attrs.Value('class')) > 0) then
              n[xml_tmpi].pageurl := Attrs.Value('href');
      end;
    RP_PIXIV:
      begin
        if (tstart = 0) then
          if (ATag = 'li') and (Attrs.Value('class') = 'image') and
            not chbByAuthor.Checked or (ATag = 'div') and
            (pos('display_works', Attrs.Value('class')) > 0) and
            chbByAuthor.Checked then
            tstart := 1
          else if (ATag = 'a') then
            if (Attrs.Value('class') = 'avatar_m') then
              tmp := Attrs.Value('title')
            else if (Attrs.Value('rel') = 'next') then
              nxt := Attrs.Value('href')
            else
          else if (ATag = 'div') and (Attrs.Value('class') = 'related-tag') or
            (ATag = 'dl') and (Attrs.Value('class') = 'related') then
            tstart := 4
          else
        else if (tstart = 1) then
          if (ATag = 'a') then
            tmpurl := Attrs.Value('href')
          else if (ATag = 'img') then
            if Attrs.Value('data-src') <> '' then
            begin
              xml_tmpi :=
                AddN(deleteids(REPLACE(Attrs.Value('data-src'),
                emptyname(Attrs.Value('data-src')),
                REPLACE(emptyname(Attrs.Value('data-src')), '_s', ''))));
              if xml_tmpi <> -1 then
              begin
                n[xml_tmpi].Preview := Attrs.Value('data-src');
                // n[xml_tmpi].Title := Attrs.Value('alt');
                n[xml_tmpi].pageurl := tmpurl;
              end;
            end
            else
            begin
              xml_tmpi :=
                AddN(deleteids(REPLACE(Attrs.Value('src'),
                emptyname(Attrs.Value('src')),
                REPLACE(emptyname(Attrs.Value('src')), '_s', ''))));
              if xml_tmpi <> -1 then
              begin
                n[xml_tmpi].Preview := Attrs.Value('src');
                // n[xml_tmpi].Title := Attrs.Value('alt');
                n[xml_tmpi].pageurl := tmpurl;
              end;
            end
          else if (ATag = 'h1') then
            tstart := 2
          else if (ATag = 'p') and (Attrs.Value('class') = 'user') then
            tstart := 3
          else
        else if (tstart = 4) and (ATag = 'a') then
          tstart := 5;
      end;
    RP_SAFEBOORU, RP_XBOORU:
      if (ATag = 'a') and (Attrs.Value('alt') = 'next') then
        nxt := Attrs.Value('href');
    RP_SANKAKU_CHAN, RP_SANKAKU_IDOL:
      if chbInPools.Checked then
        if (tstart = 0) then
          if (ATag = 'div') and (Attrs.Value('id') = 'pool-index') then
            tstart := 1
          else if (ATag = 'div') and (Attrs.Value('class') = 'pagination') then
            tstart := 3
          else
        else if (tstart = 1) then
          if (ATag = 'div') then
            tstart := -2
          else if (ATag = 'td') then
            tstart := 2
          else
        else if (tstart = 2) then
          if (ATag = 'a') and
            not((xml_tmpi > 0) and (PreList[xml_tmpi - 1].AType = '')) then
          begin
            xml_tmpi := Length(PreList) + 1;
            SetLength(PreList, xml_tmpi);
            PreList[xml_tmpi - 1].Name := '';
            PreList[xml_tmpi - 1].AType := '';
            PreList[xml_tmpi - 1].URL := RESOURCE_URLS[cbSite.ItemIndex] +
              trim(Attrs.Value('href'), '/');
            PreList[xml_tmpi - 1].chck := false;
            PreList[xml_tmpi - 1].Preview := '';
          end
          else
        else if (tstart = 3) and (ATag = 'a') then
        begin
          tmp := Attrs.Value('href');
          tstart := 4;
        end
        else if (tstart = -1) then
          if (ATag = 'span') and (pos('thumb', Attrs.Value('class')) > 0) then
            tstart := 5
          else if (ATag = 'div') and (Attrs.Value('class') = 'pagination') then
            tstart := 6
          else
        else if tstart = 5 then
          if (ATag = 'a') then
            tmpurl := Attrs.Value('href')
          else if (ATag = 'img') and (pos('preview', Attrs.Value('class')) > 0)
            and (emptyname(Attrs.Value('src')) <> 'download-preview.png') then
          begin
            xml_tmpi := AddN(CopyTo(RESOURCE_URLS[cbSite.ItemIndex], '.') + '.'
              + DeleteTo(REPLACE(Attrs.Value('src'), 'preview/', ''), '.'));
            if xml_tmpi <> -1 then
            begin
              n[xml_tmpi].title := PreList[curPreItem].Name;
              n[xml_tmpi].pageurl := tmpurl;
              n[xml_tmpi].Preview := Attrs.Value('src');
              n[xml_tmpi].tags :=
                AddTags(CopyTo(Attrs.Value('alt'), ' score:'));
            end
            else
          end
          else
        else if (tstart = 6) and (ATag = 'a') then
        begin
          tmp := Attrs.Value('href');
          tstart := 7;
        end
        else

      else
      begin
        if (ATag = 'div') and (Attrs.Value('id') = 'popular-preview') then
          tstart := -1
        else if (tstart > -1) then
          if (ATag = 'img') and (pos('preview', Attrs.Value('class')) > 0) and
            (emptyname(Attrs.Value('src')) <> 'download-preview.png') then
          begin
            xml_tmpi := AddN(CopyTo(RESOURCE_URLS[cbSite.ItemIndex], '.') + '.'
              + DeleteTo(REPLACE(Attrs.Value('src'), 'preview/', ''), '.'));
            if xml_tmpi <> -1 then
            begin
              n[xml_tmpi].Preview := Attrs.Value('src');
              n[xml_tmpi].tags :=
                AddTags(CopyTo(Attrs.Value('title'), ' score:'));
              n[xml_tmpi].pageurl := tmpurl;
            end;
          end
          else if (ATag = 'div') and (Attrs.Value('class') = 'pagination') then
            tstart := 1
          else if (ATag = 'span') and
            (pos('thumb', Attrs.Value('class')) > 0) then
            tstart := 3
          else if (ATag = 'a') then
            case (tstart) of
              1:
                begin
                  tmp := Attrs.Value('href');
                  tstart := 2;
                end;
              3:
                tmpurl := Attrs.Value('href');
            end;
      end;
    RP_EHENTAI_G, RP_EXHENTAI:
      if (tstart = 0) and (ATag = 'table') then
        if (Attrs.Value('class') = 'itg') then
          tstart := 1
        else if (Attrs.Value('class') = 'ptb') then
          tstart := 4
        else
      else if (tstart = 1) and (ATag = 'td') and
        (Attrs.Value('class') = 'itdc') then
        tstart := 2
      else if (tstart = 1) and (ATag = 'div') and
        (Attrs.Value('class') = 'it3') then
        tstart := 3
      else if (tstart = 3) and (ATag = 'a') then
        if (Attrs.Value('rel') <> '') then
          PreList[xml_tmpi - 1].HasTorrent := true
        else
          PreList[xml_tmpi - 1].URL := Attrs.Value('href')
      else if (tstart = 4) and (ATag = 'a') then
      begin
        tmpurl := Attrs.Value('href');
        tstart := 5;
      end
      else if (tstart = -1) then
        if (PreList[curPreItem].Name = '') and (ATag = 'h1') and
          (Attrs.Value('id') = 'gn') then
          tstart := 8
        else if (ATag = 'div') and (Attrs.Value('class') = 'gdtm') then
          tstart := 6
        else if (ATag = 'p') and (Attrs.Value('class') = 'ip') then
          tstart := 7
        else
      else if (tstart = 6) and (ATag = 'a') then
      begin
        xml_tmpi := AddN(Attrs.Value('href'));
        n[xml_tmpi].title := IntToStr(npp);
        n[xml_tmpi].Params := PreList[curPreItem].Name;
        n[xml_tmpi].pageurl := n[xml_tmpi].URL;
      end;
    RP_PAHEAL_RULE34, RP_PAHEAL_RULE63, RP_PAHEAL_COSPLAY, RP_TENTACLERAPE:
      if (tstart = 0) and (ATag = 'div') then
        if ((lowercase(Attrs.Value('id')) = 'navigationleft')) or
          (lowercase(Attrs.Value('id')) = 'navigation') then
          tstart := -1
        else if (lowercase(Attrs.Value('id')) = 'imagesmain') or
          (lowercase(Attrs.Value('id')) = 'images') then
          tstart := 1
        else
      else if (tstart < 0) then
        if (ATag = 'div') then
          dec(tstart)
        else if (ATag = 'a') then
          tmp := Attrs.Value('href')
        else
      else if (tstart > 0) then
        if (ATag = 'div') then
          inc(tstart)
        else if (ATag = 'img') then
        begin
          if pos('://', Attrs.Value('src')) > 0 then
            xml_tmpi := AddN(REPLACE(REPLACE(Attrs.Value('src'), 'thumbs',
              'images', false, true), '/thumb', ''))
          else
            xml_tmpi := AddN(RESOURCE_URLS[cbSite.ItemIndex] +
              trim(REPLACE(REPLACE(Attrs.Value('src'), 'thumbs', 'images',
              false, true), '/thumb', ''), '/'));
          if xml_tmpi <> -1 then
          begin
            if pos('://', Attrs.Value('src')) > 0 then
              n[xml_tmpi].Preview := Attrs.Value('src')
            else
              n[xml_tmpi].Preview := RESOURCE_URLS[cbSite.ItemIndex] +
                trim(Attrs.Value('src'), '/');
            n[xml_tmpi].Params := Attrs.Value('alt');
            n[xml_tmpi].tags := AddTags(CopyTo(Attrs.Value('alt'), ' //'));
            n[xml_tmpi].pageurl := tmpurl;
          end;
        end
        else if (ATag = 'a') then
          tmpurl := Attrs.Value('href');
    RP_DEVIANTART:
      if (tstart = 0) then
        if (ATag = 'div') and (Attrs.Value('id') = 'browse2-stream') then
          inc(tstart)
        else if (ATag = 'li') and (Attrs.Value('class') = 'next') then
          tstart := -1
        else
      else if (tstart > 0) then
        if ATag = 'div' then
          inc(tstart)
        else if (ATag = 'a') then
          if (pos('thumb', Attrs.Value('class')) > 0) then
            if ((Attrs.Value('super_fullimg') <> '') or
              (Attrs.Value('super_img') <> '') or
              (pos('thumb', Attrs.Value('ismature')) > 0)) then
            begin
              xml_tmpi := -1;
              if (Attrs.Value('super_fullimg') <> '') then
                xml_tmpi := AddN(Attrs.Value('super_fullimg'))
              else
                xml_tmpi := AddN(Attrs.Value('super_img'));
              { xml_tmpi := AddN
                (REPLACE(REPLACE(Attrs.Value('super_img'),
                '/PRE/i/', '/i/'), '/PRE/f/', '/f/')); }
              if xml_tmpi <> -1 then
              begin
                // n[xml_tmpi].preview := replace(attrs.Value('super_img'),'/PRE/i/','/150/i/');
{                n[xml_tmpi].URL := RESOURCE_URLS[cbSite.ItemIndex] + 'download/' +
                  DownCopyTo('-',Attrs.Value('href')) +
                  '/' + emptyname(n[xml_tmpi].URL);    }
                n[xml_tmpi].Preview := '';
                n[xml_tmpi].title :=
                  CopyTo(CopyTo(Attrs.Value('title'), ' by ~'), ' by *');
                n[xml_tmpi].Params := Attrs.Value('title');
                n[xml_tmpi].pageurl := Attrs.Value('href');
              end;
            end
            else
          else if (xml_tmpi > -1) and (Attrs.Value('class') = '') then
            n[xml_tmpi].category := Attrs.Value('href')
          else
        else if (ATag = 'img') and (xml_tmpi > -1) and (n[xml_tmpi].Preview = '') then
        begin
          n[xml_tmpi].Preview := Attrs.Value('src');
          if n[xml_tmpi].URL = '' then
            n[xml_tmpi].URL := REPLACE(REPLACE(Attrs.Value('src'), '/150/i/',
              '/i/'), '/150/f/', '/f/');
        end
        else
      else if tstart = -1 then
        if (ATag = 'a') and (Attrs.Value('id') = 'gmi-GPageButton') then
          nxt := Attrs.Value('href');
    RP_E621:
      if chbInPools.Checked then
        if (tstart = 0) then
          if (ATag = 'div') and (Attrs.Value('id') = 'pool-index') then
            tstart := 1
          else if (ATag = 'div') and (Attrs.Value('class') = 'pagination') then
            tstart := 3
          else
        else if (tstart = 1) then
          if (ATag = 'div') then
            tstart := -2
          else if (ATag = 'td') then
            tstart := 2
          else
        else if (tstart = 2) then
          if (ATag = 'a') and
            not((xml_tmpi > 0) and (PreList[xml_tmpi - 1].AType = '')) then
          begin
            xml_tmpi := Length(PreList) + 1;
            SetLength(PreList, xml_tmpi);
            PreList[xml_tmpi - 1].Name := '';
            PreList[xml_tmpi - 1].AType := '';
            PreList[xml_tmpi - 1].URL := RESOURCE_URLS[cbSite.ItemIndex] +
              trim(Attrs.Value('href'), '/');
            PreList[xml_tmpi - 1].chck := false;
            PreList[xml_tmpi - 1].Preview := '';
          end
          else
        else if (tstart = 3) and (ATag = 'a') then
        begin
          tmp := Attrs.Value('href');
          tstart := 4;
        end
        else if (tstart = -1) then
          if (ATag = 'span') and (pos('thumb', Attrs.Value('class')) > 0) then
            tstart := 5
          else if (ATag = 'div') and (Attrs.Value('class') = 'pagination') then
            tstart := 6
          else
        else if tstart = 5 then
          if (ATag = 'a') then
            tmpurl := Attrs.Value('href')
          else if (ATag = 'img') and (pos('preview', Attrs.Value('class')) > 0)
            and (emptyname(Attrs.Value('src')) <> 'download-preview.png') then
          begin
            xml_tmpi := AddN(RESOURCE_URLS[cbSite.ItemIndex] +
              trim(REPLACE(Attrs.Value('src'), 'preview/', ''), '/'));
            if xml_tmpi <> -1 then
            begin
              n[xml_tmpi].title := PreList[curPreItem].Name;
              n[xml_tmpi].pageurl := tmpurl;
              n[xml_tmpi].Preview := RESOURCE_URLS[cbSite.ItemIndex] +
                trim(Attrs.Value('src'), '/');
              n[xml_tmpi].tags :=
                AddTags(CopyTo(Attrs.Value('alt'), ' score:'));
            end
            else
          end
          else if ATag = 'script' then
            tstart := 8
          else
        else if (tstart = 6) and (ATag = 'a') then
        begin
          tmp := Attrs.Value('href');
          tstart := 7;
        end
        else
      else
      begin
        if (ATag = 'div') and (Attrs.Value('class') = 'pagination') then
          tstart := 1
        else if (ATag = 'span') and
          (pos('thumb', Attrs.Value('class')) > 0) then
          tstart := 3
        else if (tstart = 1) and (ATag = 'a') then
        begin
          tmp := Attrs.Value('href');
          tstart := 2;
        end
        else if (tstart = 3) then
          if (ATag = 'a') then
            tmpurl := Attrs.Value('href')
          else if (ATag = 'img') and (pos('preview', Attrs.Value('class')) > 0)
            and (emptyname(Attrs.Value('src')) <> 'download-preview.png') then
          begin
            xml_tmpi := AddN(RESOURCE_URLS[cbSite.ItemIndex] +
              trim(REPLACE(Attrs.Value('src'), 'preview/', ''), '/'));
            if xml_tmpi <> -1 then
            begin
              n[xml_tmpi].Preview := RESOURCE_URLS[cbSite.ItemIndex] +
                trim(Attrs.Value('src'), '/');
              n[xml_tmpi].tags :=
                AddTags(CopyTo(Attrs.Value('alt'), ' score:'));
              n[xml_tmpi].pageurl := RESOURCE_URLS[cbSite.ItemIndex] +
                trim(tmpurl, '/');
            end;
          end
          else if ATag = 'script' then
            tstart := 4;
      end;
    RP_413CHAN_PONIBOORU:
      if tstart = 0 then
        if (ATag = 'span') and (Attrs.Value('class') = 'thumb') then
          tstart := 1
        else if (ATag = 'div') and (Attrs.Value('id') = 'paginator') then
          tstart := 2
        else
      else if tstart = 1 then
        if ATag = 'a' then
          tmpurl := Attrs.Value('href')
        else
      else if tstart = 2 then
        if ATag = 'b' then
          tstart := 3
        else
      else if tstart = 3 then
        if ATag = 'a' then
          nxt := Attrs.Value('href');
    RP_ZEROCHAN:
      if tstart = 0 then
        if (ATag = 'ul') and (Attrs.Value('id') = 'thumbs2') then
          tstart := 1
        else if (ATag = 'a') and (Attrs.Value('rel') = 'next') then
          nxt := tmp + trim(Attrs.Value('href'), '/')
        else
      else if tstart = 1 then
        if ATag = 'a' then
          tmpurl := trim(Attrs.Value('href'));
    RP_RMART:
      if tstart = 0 then
        if (ATag = 'a') and (Attrs.Value('class') = 'page-link') then
        begin
          tmp := Attrs.Value('href');
          tstart := 1;
        end;
    RP_THEDOUJIN:
      if tstart = 0 then
        if (ATag = 'li') and (Attrs.Value('class') = 'next') then
          tstart := 1
        else if (ATag = 'div') and (Attrs.Value('class') = 'items') then
          tstart := 2
        else
      else if tstart = 1 then
        if (ATag = 'a') then
          nxt := Attrs.Value('href')
        else
      else if (tstart > 1) and (tstart < 6) then
        if ATag = 'div' then
          inc(tstart)
        else if tstart = 4 then
          if ATag = 'a' then
            tmpurl := RESOURCE_URLS[cbSite.ItemIndex] + trim(Attrs.Value('href'),'/')
          else if ATag = 'img' then
          begin
            xml_tmpi := Length(PreList) + 1;
            SetLength(PreList, xml_tmpi);
            PreList[xml_tmpi - 1].Name := '';
            PreList[xml_tmpi - 1].AType := '';
            PreList[xml_tmpi - 1].URL := tmpurl;
            PreList[xml_tmpi - 1].chck := false;
            PreList[xml_tmpi - 1].Preview := deleteids(Attrs.Value('src'));
          end else
        else if tstart = 5 then
          if ATag = 'a' then
            tstart := 6
          else
        else
      else if tstart = -1 then
        if (ATag = 'div') and (Attrs.Value('id') = 'yw0')then
          tstart := 8
        else
      else if tstart > 7 then
        if ATag = 'div' then
          inc(tstart)
        else if tstart = 9 then
          if ATag = 'a' then
            tmpurl := RESOURCE_URLS[cbSite.ItemIndex] + trim(Attrs.Value('href'),'/')
          else if ATag = 'img' then
          begin
            xml_tmpi := AddN(REPLACE(REPLACE(deleteids(Attrs.Value('src')),
              'thumbnail_', ''), 'thumbs', 'images'));
            if xml_tmpi <> -1 then
            begin
              n[xml_tmpi].Preview := deleteids(Attrs.Value('src'));
              n[xml_tmpi].pageurl := RESOURCE_URLS[cbSite.ItemIndex] + tmpurl;
              //n[xml_tmpi].tags := AddTags(CopyTo(Attrs.Value('title'), 'score:'));
              n[xml_tmpi].Params := PreList[curPreItem].Name;
              n[xml_tmpi].title := IntToStr(npp);
            end;
          end
          else if (ATag = 'li') and (Attrs.Value('class') = 'next') then
            tstart := 10
          else
        else if tstart = 10 then
          if ATag = 'a' then
            nxt := Attrs.Value('href')
          else
        else
      else ;












    RP_MINITOKYO:
      if (tstart = 0) and (ATag = 'ul') and (Attrs.Value('id') = 'tabs') then
        tstart := 1
      else if (tstart = 1) and (ATag = 'a') and (Attrs.Value('href') <> '') then
      begin
        xml_tmpi := Length(PreList) + 1;
        SetLength(PreList, xml_tmpi);
        PreList[xml_tmpi - 1].Name := '';
        PreList[xml_tmpi - 1].AType := '';
        PreList[xml_tmpi - 1].URL := ClearHTML(Attrs.Value('href')) +
          '&order=id&display=extensive';
        if PreList[xml_tmpi - 1].URL[1] = '?' then
          PreList[xml_tmpi - 1].URL := RESOURCE_URLS[cbSite.ItemIndex] +
            'search' + PreList[xml_tmpi - 1].URL;
        PreList[xml_tmpi - 1].chck := false;
        PreList[xml_tmpi - 1].Preview := '';
        tstart := 2;
      end
      else if (tstart = -1) then
        if (ATag = 'div') and (Attrs.Value('id') = 'content') then
          tstart := 3
        else
      else if (tstart = 3) then
        if ((ATag = 'p') or (ATag = 'div')) and
          (Attrs.Value('class') = 'pagination') then
          tstart := 4
        else if (ATag = 'div') then
          tstart := 99
        else if (ATag = 'li') or (ATag = 'dt') then
          tstart := 5
        else if (ATag = 'dd') then
          tstart := 6
        else
      else if (tstart = 4) and (ATag = 'a') and (Attrs.Value('href') <> '') then
      begin
        tmp := Attrs.Value('href');
        tstart := 7
      end
      else if (tstart = 5) then
        if ATag = 'a' then
          tmpurl := Attrs.Value('href')
        else
      else if (tstart = 6) then
        if ATag = 'p' then
          if Attrs.Value('class') = 'description' then
            tstart := 8
          else
            tstart := 9
        else
      else if (tstart = 10) and (ATag = 'a') then
        tstart := 11;
  end;

end;

procedure TMainForm.XmlEndTag(ATag: String);
begin
  case cbSite.ItemIndex of
    RP_GELBOORU, RP_BOORU_II, RP_XXX_RULE34, RP_TBIB:
      if (ATag = 'span') and (tstart = 1) then
        tstart := 0;
    RP_DONMAI_DANBOORU, RP_DONMAI_HIJIRIBE, RP_DONMAI_SONOHARA, RP_SANKAKU_CHAN,
      RP_BEHOIMI, RP_SANKAKU_IDOL, RP_E621, RP_WILDCRITTERS, RP_NEKOBOORU:
      begin
        if chbInPools.Checked then
          if (tstart in [1, 3]) and (ATag = 'div') then
            tstart := 0
          else if (tstart = 2) and (ATag = 'td') or (tstart = -2) and
            (ATag = 'div') then
            tstart := 1
          else if (tstart = 4) and (ATag = 'a') then
            tstart := 3
          else if (tstart = 5) and (ATag = 'span') or (tstart = 6) and
            (ATag = 'div') then
            tstart := -1
          else if (tstart = 7) and (ATag = 'a') then
            tstart := 6
          else if (tstart = 8) and (ATag = 'script') then
            tstart := 5
          else
        else if ATag = 'div' then
          tstart := 0
        else if (ATag = 'a') and (tstart = 2) then
          tstart := 1
        else if (tstart = 3) and (ATag = 'span') then
          tstart := 0
        else if (ATag = 'ul') then
          xml_li := false
        else if (tstart = 4) and (ATag = 'script') then
          tstart := 3
        else
      end;
    RP_KONACHAN, RP_IMOUTO:
      if chbInPools.Checked then
        if (tstart = 1) and (ATag = 'table') or (tstart = 3) and
          (ATag = 'div') then
          tstart := 0
        else if (tstart = 2) and (ATag = 'td') then
          tstart := 1
        else if (tstart = 4) and (ATag = 'a') then
          tstart := 3
        else
      else if ((tstart = 1) or (tstart = 3)) and (ATag = 'div') then
        tstart := 0
      else if (tstart = 2) and (ATag = 'a') then
        tstart := 1
      else if (tstart = 4) and (ATag = 'span') then
        tstart := 0;
    RP_PIXIV:
      if (tstart = 1) then
        if (ATag = 'div') and chbByAuthor.Checked or (ATag = 'li') and
          not chbByAuthor.Checked then
          tstart := 0
        else
      else if (tstart = 2) and (ATag = 'h1') or (tstart = 3) and
        (ATag = 'p') then
        tstart := 1
      else if (tstart = 4) and ((ATag = 'div') or (ATag = 'dl')) then
        tstart := 0
      else if (tstart = 5) and (ATag = 'a') then
        tstart := 4;
    RP_EHENTAI_G, RP_EXHENTAI:
      if (tstart in [1, 4]) and (ATag = 'table') then
        tstart := 0
      else if (tstart = 2) and (ATag = 'td') then
        tstart := 1
      else if (tstart = 3) and (ATag = 'div') then
        tstart := 1
      else if (tstart = 5) and (ATag = 'a') then
        tstart := 4
      else if (tstart = 6) and (ATag = 'div') then
        tstart := -1
      else if (tstart = 7) and (ATag = 'p') then
        tstart := -1
      else if (tstart = 8) and (ATag = 'h1') then
        tstart := -1;
    RP_PAHEAL_RULE34, RP_PAHEAL_RULE63, RP_PAHEAL_COSPLAY, RP_TENTACLERAPE:
      if (ATag = 'div') then
        if tstart > 0 then
          dec(tstart)
        else if (tstart < 0) then
          inc(tstart);
    RP_DEVIANTART:
      if (ATag = 'div') and (tstart > 0) then
        dec(tstart)
      else if (ATag = 'li') and (tstart = -1) then
        tstart := 0;
    RP_413CHAN_PONIBOORU:
      if (tstart = 1) and (ATag = 'span') or (tstart = 2) and
        (ATag = 'div') then
        tstart := 0
      else if (tstart = 3) and ((ATag = 'a') or (ATag = 'div')) then
        tstart := 0;
    RP_ZEROCHAN:
      if (tstart = 1) and (ATag = 'ul') then
        tstart := 0;
    RP_RMART:
      if (tstart = 1) and (ATag = 'a') then
        tstart := 0;
    RP_THEDOUJIN:
      if (tstart = 1) and (ATag = 'li') then
        tstart := 0
      else if (tstart = 2) and (ATag = 'div') then
        tstart := 0
      else if (tstart > 2) and (tstart < 6) and (ATag = 'div') then
        dec(tstart)
      else if (tstart = 6) and (ATag = 'a') then
        tstart := 5
      else if (tstart = 8) and (ATag = 'div') then
        tstart := -1
      else if (tstart > 8) and (tstart < 10) and (ATag = 'div')then
        dec(tstart)
      else if (tstart = 10) and (ATag = 'li') then
        tstart := 9;
    RP_MINITOKYO:
      if (tstart = 1) and (ATag = 'ul') then
        tstart := 0
      else if (tstart = 2) and (ATag = 'a') then
        tstart := 1
      else if (tstart = 3) and (ATag = 'div') then
        tstart := -1
      else if (tstart = 4) and ((ATag = 'p') or (ATag = 'div')) then
        tstart := 3
      else if (tstart = 5) and ((ATag = 'li') or (ATag = 'dt')) or (tstart = 6)
        and (ATag = 'dd') then
        tstart := 3
      else if (tstart = 7) and (ATag = 'a') then
        tstart := 4
      else if ((tstart = 8) or (tstart = 9)) and (ATag = 'p') then
        tstart := 6
      else if (tstart = 10) and (ATag = 'p') and (xml_tmpi <> -1) then
      begin
        n[xml_tmpi].tags := AddTags(tmp, ',');
        tmp := '';
        tstart := 6;
      end
      else if (tstart = 11) and (ATag = 'a') then
        tstart := 10
      else if (tstart = 99) and (ATag = 'div') then
        tstart := 3;
  end;
end;

procedure TMainForm.XmlEmptyTag(ATag: String; Attrs: TAttrList);
begin
  case cbSite.ItemIndex of
    RP_GELBOORU:
      if (ATag = 'img') and (tstart = 1) then
        if (Attrs.Value('class') = 'preview') then
        begin
          if pos('img1.', Attrs.Value('src')) > 0 then
            xml_tmpi :=
              AddN(addstr(deleteids(REPLACE(REPLACE(Attrs.Value('src'), 'img1.',
              'img2.'), 'thumbnail_', '')), 'images/'))
          else
            xml_tmpi :=
              AddN(deleteids(REPLACE(REPLACE(REPLACE(
              batchreplace(Attrs.Value('src'),
              ['img3.', 'img4.'], 'img2.'), 'thumbs', 'images'),
              'thumbnail_', ''),'thumbnails','images')));
          if xml_tmpi <> -1 then
          begin
            n[xml_tmpi].Preview := deleteids(Attrs.Value('src'));
            n[xml_tmpi].tags := AddTags(Attrs.Value('alt'));
            n[xml_tmpi].pageurl := tmpurl;
          end;
        end;
    RP_PIXIV:
      if (ATag = 'img') and (tstart = 1) then
        if Attrs.Value('data-src') <> '' then
        begin
          xml_tmpi := AddN(deleteids(REPLACE(Attrs.Value('data-src'),
            emptyname(Attrs.Value('data-src')),
            REPLACE(emptyname(Attrs.Value('data-src')), '_s', ''))));
          if xml_tmpi <> -1 then
          begin
            n[xml_tmpi].Preview := Attrs.Value('data-src');
            n[xml_tmpi].title := Attrs.Value('alt');
            n[xml_tmpi].Params := tmp;
            n[xml_tmpi].pageurl := tmpurl;
          end;
        end
        else
        begin
          xml_tmpi :=
            AddN(deleteids(REPLACE(Attrs.Value('src'),
            emptyname(Attrs.Value('src')), REPLACE(emptyname(Attrs.Value('src')
            ), '_s', ''))));
          if xml_tmpi <> -1 then
          begin
            n[xml_tmpi].Preview := Attrs.Value('src');
            n[xml_tmpi].title := Attrs.Value('alt');
            n[xml_tmpi].Params := tmp;
            n[xml_tmpi].pageurl := tmpurl;
          end;
        end;
    RP_SAFEBOORU:
      if (ATag = 'img') and (Attrs.Value('class') = 'preview') then
      begin
        xml_tmpi :=
          AddN('http://safe' +
          deleteids(DeleteTo(REPLACE(REPLACE(Attrs.Value('src'), '/safe/',
          '/images/'), 'thumbnail_', ''), '.')));
        if xml_tmpi <> -1 then
        begin
          n[xml_tmpi].Preview := deleteids(Attrs.Value('src'));
          n[xml_tmpi].tags := AddTags(Attrs.Value('alt'));
          n[xml_tmpi].pageurl := tmpurl;
        end;
      end;
    RP_XBOORU:
      if (ATag = 'img') and (Attrs.Value('class') = 'preview') then
      begin
        xml_tmpi :=
          AddN(deleteids(REPLACE(REPLACE(Attrs.Value('src'), '/thumbnails/',
          '/images/'), 'thumbnail_', '')));
        if xml_tmpi <> -1 then
        begin
          n[xml_tmpi].Preview := deleteids(Attrs.Value('src'));
          n[xml_tmpi].tags := AddTags(Attrs.Value('alt'));
          n[xml_tmpi].pageurl := RESOURCE_URLS[cbSite.ItemIndex] + tmpurl;
        end;
      end;
    RP_EHENTAI_G, RP_EXHENTAI:
      if (tstart = 2) and (ATag = 'img') then
      begin
        xml_tmpi := Length(PreList) + 1;
        SetLength(PreList, xml_tmpi);
        PreList[xml_tmpi - 1].AType := Attrs.Value('alt');
        PreList[xml_tmpi - 1].HasTorrent := false;
        PreList[xml_tmpi - 1].chck := false;
        PreList[xml_tmpi - 1].Preview := '';
      end;
    RP_413CHAN_PONIBOORU:
      if (tstart = 1) and (ATag = 'img') and
        (emptyname(Attrs.Value('src')) <> 'questionable.png') and
        (emptyname(Attrs.Value('src')) <> 'nsfw.png') then
      begin
        xml_tmpi := AddN(RESOURCE_URLS[cbSite.ItemIndex] +
          trim(REPLACE(REPLACE(Attrs.Value('src'), '_thumbs', '_images', false,
          true), '/thumb', ''), '/'));
        if xml_tmpi <> -1 then
        begin
          n[xml_tmpi].pageurl := RESOURCE_URLS[cbSite.ItemIndex] +
            trim(tmpurl, '/');
          n[xml_tmpi].Preview := RESOURCE_URLS[cbSite.ItemIndex] +
            trim(Attrs.Value('src'), '/');
          n[xml_tmpi].tags := AddTags(CopyTo(Attrs.Value('title'), ' //'));
        end;
      end;
    RP_BOORU_II,RP_TBIB:
      if (ATag = 'img') and (tstart = 1) then
      begin
        xml_tmpi :=
          AddN(deleteids(REPLACE(REPLACE(REPLACE(Attrs.Value('src'), 'thumbs',
          'img'), 'thumbnails', 'images'), 'thumbnail_', '')));
        if xml_tmpi <> -1 then
        begin
          n[xml_tmpi].Preview := deleteids(Attrs.Value('src'));
          n[xml_tmpi].tags := AddTags(CopyTo(Attrs.Value('title'), 'score:'));
          n[xml_tmpi].pageurl := tmpurl;
        end;
      end;
    RP_XXX_RULE34:
      if (ATag = 'img') and (tstart = 1) then
      begin
        xml_tmpi :=
          AddN('http://img.' +
          DeleteTo(deleteids(REPLACE(REPLACE(Attrs.Value('src'), '/r34/',
          '/rule34/images/'), 'thumbnail_', '')), '.'));
        if xml_tmpi <> -1 then
        begin
          n[xml_tmpi].Preview := deleteids(Attrs.Value('src'));
          n[xml_tmpi].tags := AddTags(CopyTo(Attrs.Value('title'), 'score:'));
          n[xml_tmpi].pageurl := tmpurl;
        end;
      end;
    RP_ZEROCHAN:
      if (tstart = 0) and (ATag = 'link') and
        (Attrs.Value('rel') = 'alternate') then
        tmp := deleteids(Attrs.Value('href'))
      else if (ATag = 'img') and (tstart = 1) then
      begin
        xml_tmpi := AddN('http://static.' + REPLACE(DeleteTo(Attrs.Value('src'),
          '.', false), '240/', 'full/'));
        if xml_tmpi <> -1 then
        begin
          n[xml_tmpi].Preview := Attrs.Value('src');
          n[xml_tmpi].pageurl := RESOURCE_URLS[cbSite.ItemIndex] +
            trim(tmpurl, '/');
          n[xml_tmpi].title := Attrs.Value('alt');
          n[xml_tmpi].Params := Attrs.Value('title');
        end;
      end;
    RP_RMART:
      if tstart = 0 then
        if (ATag = 'img') and (Attrs.Value('class') = 'thumb-image') then
        begin
          xml_tmpi := AddN(RESOURCE_URLS[cbSite.ItemIndex] +
            trim(CopyTo(Attrs.Value('src'), '/Thumb'), '/') + '/Src/Image');
          if xml_tmpi <> -1 then
          begin
            n[xml_tmpi].pageurl := RESOURCE_URLS[cbSite.ItemIndex] +
              trim(CopyTo(Attrs.Value('src'), '/Thumb'), '/');
            n[xml_tmpi].Preview := RESOURCE_URLS[cbSite.ItemIndex] +
              trim(REPLACE(Attrs.Value('src'), 'Thumb/3', 'Thumb/6'), '/');
            n[xml_tmpi].tags := AddTags(Attrs.Value('alt'), ',');
          end;
        end;
    RP_THEDOUJIN:
{      if tstart = 1 then
        if (ATag = 'img') and (Attrs.Value('class') = 'preview') then
        begin
          xml_tmpi := Length(PreList) + 1;
          SetLength(PreList, xml_tmpi);
          PreList[xml_tmpi - 1].Name := DeleteTo(tmpurl, ':');
          PreList[xml_tmpi - 1].AType := '';
          PreList[xml_tmpi - 1].URL := RESOURCE_URLS[cbSite.ItemIndex] + tmpurl;
          PreList[xml_tmpi - 1].chck := false;
          PreList[xml_tmpi - 1].Preview := deleteids(Attrs.Value('src'));
        end
        else
      else if tstart = 2 then
        if (ATag = 'img') and (Attrs.Value('class') = 'preview') then
        begin
          xml_tmpi := AddN(REPLACE(REPLACE(deleteids(Attrs.Value('src')),
            'thumbnail_', ''), 'thumbs', 'images'));
          if xml_tmpi <> -1 then
          begin
            n[xml_tmpi].Preview := deleteids(Attrs.Value('src'));
            n[xml_tmpi].pageurl := RESOURCE_URLS[cbSite.ItemIndex] + tmpurl;
            n[xml_tmpi].tags := AddTags(CopyTo(Attrs.Value('title'), 'score:'));
            n[xml_tmpi].Params := PreList[curPreItem].Name;
            n[xml_tmpi].title := IntToStr(npp);
          end;
        end else
      else} if tstart = 7 then
        if ATag = 'br' then
        begin
          if PreList[xml_tmpi - 1].Name = '' then
            PreList[xml_tmpi - 1].Name := emptyname(PreList[xml_tmpi - 1].URL);
          tstart := 5;
        end;
    RP_MINITOKYO:
      if (tstart = 5) and (ATag = 'img') then
      begin
        xml_tmpi := AddN(REPLACE(REPLACE(Attrs.Value('src'), 'static2.',
          'static.'), '/thumbs/', '/downloads/'));
        if xml_tmpi <> -1 then
        begin
          n[xml_tmpi].pageurl := tmpurl;
          n[xml_tmpi].Preview := Attrs.Value('src');
          n[xml_tmpi].title := Attrs.Value('alt');
          n[xml_tmpi].postdate := Attrs.Value('title');
          n[xml_tmpi].Params := PreList[curPreItem].Name;
        end;
      end;
    RP_TENTACLERAPE:
      if (tstart > 0) then
        if (ATag = 'img') then
          begin
            if pos('://', Attrs.Value('src')) > 0 then
              xml_tmpi := AddN(REPLACE(REPLACE(Attrs.Value('src'), 'thumbs',
                'images', false, true), '/thumb', ''))
            else
              xml_tmpi := AddN(RESOURCE_URLS[cbSite.ItemIndex] +
                trim(REPLACE(REPLACE(Attrs.Value('src'), 'thumbs', 'images',
                false, true), '/thumb', ''), '/'));
            if xml_tmpi <> -1 then
            begin
              if pos('://', Attrs.Value('src')) > 0 then
                n[xml_tmpi].Preview := Attrs.Value('src')
              else
                n[xml_tmpi].Preview := RESOURCE_URLS[cbSite.ItemIndex] +
                  trim(Attrs.Value('src'), '/');
              n[xml_tmpi].Params := Attrs.Value('alt');
              n[xml_tmpi].tags := AddTags(CopyTo(Attrs.Value('alt'), ' //'));
              n[xml_tmpi].pageurl := tmpurl;
            end;
          end
  end;
end;

procedure TMainForm.XmlContent(AContent: String);
begin
  case cbSite.ItemIndex of
    RP_DONMAI_DANBOORU, RP_DONMAI_HIJIRIBE, RP_DONMAI_SONOHARA, RP_SANKAKU_CHAN,
      RP_BEHOIMI, RP_SANKAKU_IDOL, RP_E621, RP_WILDCRITTERS, RP_NEKOBOORU:
      if chbInPools.Checked then
        if (tstart = 2) and (xml_tmpi > 0) then
          if PreList[xml_tmpi - 1].Name = '' then
            PreList[xml_tmpi - 1].Name := AContent
          else if PreList[xml_tmpi - 1].AType = '' then
            PreList[xml_tmpi - 1].AType := AContent
          else
            PreList[xml_tmpi - 1].AType := PreList[xml_tmpi - 1].AType + ', '
              + AContent
        else if (tstart in [4, 7]) and (ClearHTML(AContent) = '>>') then
          nxt := tmp
        else if (tstart = 8) and (xml_tmpi <> -1) then
        begin
          n[xml_tmpi].URL := RESOURCE_URLS[cbSite.ItemIndex] +
            trim(REPLACE(CopyFromTo(AContent, '.src=''', ''';'), 'preview/',
            ''), '/');
          n[xml_tmpi].Preview := RESOURCE_URLS[cbSite.ItemIndex] +
            trim(CopyFromTo(AContent, '.src=''', ''';'), '/');
        end
        else
      else if (tstart = 2) and (ClearHTML(AContent) = '>>') then
        nxt := tmp
      else if (tstart = 4) and (xml_tmpi <> -1) then
      begin
        n[xml_tmpi].URL := RESOURCE_URLS[cbSite.ItemIndex] +
          trim(REPLACE(CopyFromTo(AContent, '.src=''', ''';'), 'preview/',
          ''), '/');
        n[xml_tmpi].Preview := RESOURCE_URLS[cbSite.ItemIndex] +
          trim(CopyFromTo(AContent, '.src=''', ''';'), '/');
      end;
    RP_KONACHAN, RP_IMOUTO:
      if chbInPools.Checked then
        if (tstart = 2) and (xml_tmpi > 0) then
          if PreList[xml_tmpi - 1].Name = '' then
            PreList[xml_tmpi - 1].Name := AContent
          else if PreList[xml_tmpi - 1].AType = '' then
            PreList[xml_tmpi - 1].AType := AContent
          else
            PreList[xml_tmpi - 1].AType := PreList[xml_tmpi - 1].AType + ', '
              + AContent
        else if (tstart = 4) and (ClearHTML(AContent) = '>>') then
          nxt := tmp
        else
      else if (tstart = 2) and (ClearHTML(AContent) = '>>') then
        nxt := tmp
      else if (tstart = 4) then
        n[xml_tmpi].Params := AContent;
    RP_PIXIV:
      begin
        if (xml_tmpi <> -1) then
        begin
          if tstart = 2 then
            n[xml_tmpi].title := AContent
          else if tstart = 3 then
            n[xml_tmpi].Params := AContent;
        end;
        if tstart = 5 then
          with lbRelatedTags.Items do
            if (AContent <> '...') and (IndexOf(AContent) = -1) then
              lbRelatedTags.Items.Add(AContent);

      end;
    RP_EHENTAI_G, RP_EXHENTAI:
      if (tstart = 3) then
        PreList[xml_tmpi - 1].Name := AContent
      else if (tstart = 5) and (AContent = '&gt;') then
        nxt := tmpurl
      else if (tstart = 7) then
        nxt := AContent
      else if (tstart = 8) then
        PreList[curPreItem].Name := AContent;
    RP_PAHEAL_RULE34, RP_PAHEAL_RULE63, RP_PAHEAL_COSPLAY, RP_TENTACLERAPE:
      if (tstart < 0) and (lowercase(AContent) = 'next') then
        nxt := tmp;
    RP_RMART:
      if (tstart = 1) and ((AContent = 'Следующая') or (AContent = 'Next')) then
        nxt := tmp;
    RP_MINITOKYO:
      if (tstart = 2) and (xml_tmpi <> -1) then
        if AContent[1] = '(' then
          PreList[xml_tmpi - 1].AType := trim(trim(AContent, '('), ')')
        else
          PreList[xml_tmpi - 1].Name := trim(AContent)
      else if (tstart = 7) and (AContent = 'Next &raquo;') then
        nxt := ClearHTML(tmp)
      else if (tstart = 8) then
        if pos('Tags:', AContent) = 1 then
        begin
          tstart := 10;
          tmp := '';
        end
        else if pos('Submitted by', AContent) = 1 then
          tstart := 6
        else if (xml_tmpi > -1) then
          n[xml_tmpi].postdate := AContent
        else
      else if (tstart = 9) and (xml_tmpi > -1) then
        n[xml_tmpi].category := AContent
      else if (tstart = 11) then
        tmp := tmp + ',' + AContent;
    RP_THEDOUJIN:
      if (tstart = 5) and (AContent = 'Description:') then
        tstart := 7
      else if (tstart = 6) then
        if pos('View ',Acontent) = 1 then
          PreList[xml_tmpi - 1].Name := trim(DeleteTo(Acontent,'View'))
        else
      else if (tstart = 7) then
        if PreList[xml_tmpi - 1].Name = '' then
          PreList[xml_tmpi - 1].Name := trim(AContent)
        else
      else ;
  end;
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
  JvTrayIcon.HideBalloon;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  chbKeepInstance.Checked := false;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  try
    if not FSHUTDOWN and not AutoMode and (prgress = 0) and
      (MessageDlg('Program is working. Are you realy want to exit?',
      mtConfirmation, [mbYes, mbNo], 0) = mrNo) then
    begin
      CanClose := false;
      Exit;
    end;

    prgress := 1;

    if not FSHUTDOWN and not AutoMode and not saved and (Length(n) > 0) and
      chbSaveNote.Checked then
      case MessageDlg('Do you want to save list?', mtConfirmation,
        [mbYes, mbNo, mbCancel], 0) of
        mrYes:
          begin
            tbiSaveClick(nil);
            if not saved then
            begin
              CanClose := false;
              Exit;
            end;
          end;
        mrCancel:
          begin
            CanClose := false;
            Exit;
          end;
      end
    else if AutoMode and AutoSave then
      with sdList do
        if ExtractFileDrive(FileName) = '' then
          SaveToFile(IncludeTrailingPathDelimiter(edir.Text) + '\' +
            FileName, 1, nil)
        else
          SaveToFile(FileName, 1, nil);

    CanClose := true;
    saveparams;
    saveoptions;
  except
    on E: Exception do
      MessageDlg(E.Message, mtError, [mbOk], 0);
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);

var
  i: Integer;
  Icon: TIcon;
//  ICON: TIcon;

begin
  FCookies := TMyCookieList.Create;
  FSection := TCriticalSection.Create;
  FThreadList := nil;
  FSHUTDOWN := false;
  CloseAfterFinish := false;
  AutoMode := false;
  AutoSave := false;
  loading := true;
  hFileMapObj := 0;
  FPreviousTab := 0;

  // tbrasiMenu.

  TTBCustomDockableWindowAccess(pcMenu.View.Window)
    .CurrentDock.AllowDrag := false;
  TTBCustomDockableWindowAccess(pcMenu.View.Window).Floating := false;
  TSpTBXToolbarAccess(pcMenu.View.Window).OnMouseDown := pcMenuMouseDown;
  (pcMenu as TWinControl).TabOrder := 0;
  (tsPicsList as TWinControl).DoubleBuffered := true;
  (tsMetadata as TWinControl).DoubleBuffered := true;
  (tsDownloading as TWinControl).DoubleBuffered := true;
  (tsSettings as TWinControl).DoubleBuffered := true;
  (tsLog as TWinControl).DoubleBuffered := true;
  (tsErrors as TWinControl).DoubleBuffered := true;
  // pcMenu.ActiveTabIndex := 1;

  // tbrasiMenu.o

  // MainForm.DoubleBuffered := true;

  updateskin;

  cbLetter.ShortDisplayName := true;

  prgrsbr.MainBar := true;

  AuthData[-1].Login := '';
  AuthData[-1].Password := '';

  xml_li := false;
  FAutoScroll := chbautoscroll.Checked;
  (* iLain.Hint := 'Close the world' + #13#10 + '          .txEn eht nepO'{ + #13#10#13#10 + 'əɯ ɥʇɪʍ ◦◦◦'}; *)

  Grid.OnVerticalScroll := GridScroll;
  Grid.Cells[1, 0] := 'URL';
  SetGridState(false);

  for i := 0 to Length(RESOURCE_URLS) - 1 do
    cbSite.Items.Add(trim(DeleteTo(DeleteTo(RESOURCE_URLS[i], ':/'),
      'www.'), '/'));
  loadparams;

  tbiClose.Images := MDIButtonsImgList;
  tbiGridClose.Images := MDIButtonsImgList;
  tbiMaximize.Images := MDIButtonsImgList;
  tbiMinimize.Images := MDIButtonsImgList;
  tbiClose.ImageIndex := 0;
  tbiGridClose.ImageIndex := 0;
  if MainForm.WindowState = wsMaximized then
    tbiMaximize.ImageIndex := 3
  else
    tbiMaximize.ImageIndex := 1;
  tbiMinimize.ImageIndex := 2;
  tbiMenuHide.Caption := #9650;

  edir.Text := DefFolder;

  Caption := Application.title + ' ' + VersionInfo.FileVersion;
  lblCaption.Caption := VersionInfo.FileVersion;
  // MainContainer.Caption := Caption;
  cpt := Caption;

  log('Program started');

  loadoptions;

  if FDrive <> '' then
    cbLetter.Drive := FDrive[1];

  Randomize;

  curLain := Random(ZLAINS);
  DrawImageFromRes(iLain, 'ZLAIN' + IntToStr(curLain), '.png');

  Icon := TIcon.Create;
  GLISTANIM := TImageList.Create(Self);
  for i := 0 to 8 do
  begin
    Icon.Handle := LoadIcon(hInstance, PWideChar('ZGLIST' + IntToStr(i)));
    GLISTANIM.AddIcon(Icon);
  end;
  Icon.Free;

  IconMaker := TPNGIconMaker.Create('ZDBG', 'ZD');
  // JvTrayIcon.Icon := IconMaker.Icon;

  FThreadQueue := TThreadQueue.Create;
  // FThreadQueue.DelayPeriod := 1000;

  loading := false;

  block(1, 0);
  bgimage.Parent.DoubleBuffered := true;
  iIcon.Picture.Icon.Handle := LoadImage(hInstance, 'MAINICON', IMAGE_ICON, 16,
    16, LR_DEFAULTCOLOR);
{  PNG := TPNGIMAGE.Create;
  PNG.LoadFromResourceName(hInstance,'ZNEKOPAW');
  Icon := TIcon.Create;
  Icon.Handle := PngToIcon(PNG,clWhite);
  il.AddIcon(Icon);
  PNG.Free;
  Icon.Free;  }
  DrawImageFromRes(bgimage, 'ZNYA', '.png');
  ActiveControl := cbSite;
  // UpdateDataInterface;
  // cbSite.SetFocus;

end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FThreadQueue.Free;
  FCookies.Free;
  FSection.Free;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  if Grid.ColCount = 2 then
    Grid.ColWidths[1] := Grid.Width - 12 - 16 - Grid.ColWidths[0]
  else
    Grid.ColWidths[1] := Grid.Width - 12 - 16 - Grid.ColWidths[0] -
      Grid.ColWidths[2] - Grid.ColWidths[3] - Grid.ColWidths[4] -
      Grid.ColWidths[5];

  if pcMenu.Visible and pnlMain.Visible then
  begin
    if pcLogs.Height + splLogs.Height > pnlMain.Height - pnlGrid.Height then
      pcLogs.Height := pnlMain.Height - pnlGrid.Height - splLogs.Height;

    if pcMenu.Height + splMenu.Height > MainForm.ClientHeight - pnlMain.Height -
      StatusBar.Height then
      pcMenu.Height := MainForm.ClientHeight - pnlMain.Height - StatusBar.Height
        - splMenu.Height;
  end;
end;

procedure TMainForm.GenGrid;
var
  i: Integer;
  s: string;
begin
  if Length(n) = 0 then
    if Length(PreList) > 0 then
    begin
      Grid.RowCount := Max(2, Length(PreList) + 1);
      Grid.AddCheckBoxColumn(0, false, false);
      for i := 0 to Length(PreList) - 1 do
      begin
        Grid.SetCheckBoxState(0, i + 1, false);
        s := '';
        if PreList[i].AType <> '' then
          s := '[' + PreList[i].AType + '] ';
        if PreList[i].HasTorrent then
          s := s + '[has torrent] ';
        s := s + ClearHTML(PreList[i].Name);
        Grid.Rows[i + 1][1] := s;
        // Grid.ReadOnly[i+1,1] := true;
        Grid.Rows[i + 1][2] := '';
        Grid.Rows[i + 1][3] := '';
        Grid.Rows[i + 1][4] := '';
        Grid.Rows[i + 1][5] := '';
      end;
      bgimage.Visible := false;
      tbGrid.Visible := true;
      Grid.Visible := true;
      lRow.Visible := true;
      FormResize(nil);
    end
    else
      GridClear
  else
  begin
    Grid.RowCount := Max(2, Length(n) + 1);
    Grid.AddCheckBoxColumn(0, false, false);
    for i := 0 to Length(n) - 1 do
    begin
      Grid.SetCheckBoxState(0, i + 1, Boolean(n[i].chck));

      // Grid.Rows[i+1][0] := IntToStr(n[i].chck);
      Grid.Rows[i + 1][1] := n[i].URL;
      Grid.Rows[i + 1][2] := '';
      Grid.Rows[i + 1][3] := '';
      Grid.Rows[i + 1][4] := '';
      Grid.Rows[i + 1][5] := '';
    end;
    bgimage.Visible := false;
    tbGrid.Visible := true;
    Grid.Visible := true;
    lRow.Visible := true;
    FormResize(nil);
  end;
end;

procedure TMainForm.GenTags;
var
  i: Integer;
begin
  chblTagsCloud.Clear;
  ClearTags;
  for i := 0 to Length(tags) - 1 do
    if tags[i].Count >= eCFilter.Value then
      chblTagsCloud.Items.AddObject(ClearHTML(tags[i].Name) + ' (' +
        IntToStr(tags[i].Count) + ')', TObject(i));
  tsTags.Caption := 'Tags Cloud (' + IntToStr(chblTagsCloud.Count) + ')';
  tsRelated.Caption := 'Related (' + IntToStr(lbRelatedTags.Count) + ')';
end;

function TMainForm.GetNInfo(l: Integer): string;

  function chb(const b: Boolean; const s: string): string;
  begin
    if b then
      result := s
    else
      result := '';
  end;

  function ch(var chs: string; const s: string): string;
  begin
    if chs <> '' then
      result := s
    else
      result := '';
  end;

begin
  if Length(n) = 0 then
    Exit;
  result := ch(n[l].title, 'title: ' + ClearHTML(n[l].title));
  result := result + ch(n[l].Params, ch(result, #13#10) + 'info: ' +
    ClearHTML(n[l].Params));
  result := result + ch(n[l].postdate, ch(result, #13#10) + 'info2: ' +
    ClearHTML(n[l].postdate));
  result := result + chb(Length(n[l].tags) > 0, ch(result, #13#10) + 'tags: ' +
    ClearHTML(TagString(n[l].tags)));
  result := result + ch(n[l].category, ch(result, #13#10) + 'category: ' +
    ClearHTML(n[l].category));
  result := result + ch(n[l].pageurl, ch(result, #13#10) + 'page: ' +
    ClearHTML(n[l].pageurl));
end;

procedure TMainForm.GridCanEditCell(Sender: TObject; ARow, ACol: Integer;
  var CanEdit: Boolean);
begin
  CanEdit := (not(prgress = 0) and (ACol in [0, 1, 3])) or
    ((prgress = 0) and (ACol in [1, 3]));
end;

procedure TMainForm.GridCheck(v: Boolean);
var
  i: Integer;
begin
  if Length(PreList) > 0 then
    for i := 0 to Length(PreList) - 1 do
    begin
      PreList[i].chck := v;
      Grid.SetCheckBoxState(0, i + 1, v);
    end
  else
    for i := 0 to Length(n) - 1 do
    begin
      n[i].chck := v;
      Grid.SetCheckBoxState(0, i + 1, v);
    end;
end;

procedure TMainForm.GridCheckBoxChange(Sender: TObject; ACol, ARow: Integer;
  State: Boolean);
begin
  if Length(n) > 0 then
    n[ARow - 1].chck := State
  else if Length(PreList) > 0 then
    PreList[ARow - 1].chck := State;
end;

procedure TMainForm.GridCheckByKeyword(v: Boolean);
var
  i: Integer;
  s: string;
begin
  s := InputBox('URL keyword selection', 'Specify a keyword', '');
  if s <> '' then
    for i := 0 to Length(n) - 1 do
      if pos(UPPERCASE(s), UPPERCASE(n[i].URL)) > 0 then
      begin
        n[i].chck := v;
        Grid.SetCheckBoxState(0, i + 1, v);
      end;
end;

procedure TMainForm.GridCheckByTag(v: Boolean);

  function OrCheck(a1, a2: TArrayOfWord): Boolean;
  var
    i, j: Integer;
  begin
    result := false;
    for i := 0 to Length(a1) - 1 do
      for j := 0 to Length(a2) - 1 do
        if a1[i] = a2[j] then
        begin
          result := true;
          Break;
        end;
  end;

  function AndCheck(a1, a2: TArrayOfWord): Boolean;
  var
    i, j: Integer;
    b: Boolean;
  begin
    result := true;
    for i := 0 to Length(a1) - 1 do
    begin
      b := false;
      for j := 0 to Length(a2) - 1 do
        if a1[i] = a2[j] then
        begin
          b := true;
          Break;
        end;
      if not b then
      begin
        result := false;
        Break;
      end;
    end;
  end;

var
  i, l: Integer;
  tmp: TArrayOfWord;

begin
  l := RadioGroupDlg('Selection method', 'Select method:', ['And', 'Or']);
  if l > -1 then
  begin
    tmp := nil;
    for i := 0 to chblTagsCloud.Count - 1 do
      if chblTagsCloud.Checked[i] then
        Addsrtdd(tmp, Integer(chblTagsCloud.Items.Objects[i]));
    case l of
      0:
        for i := 0 to Length(n) - 1 do
          if AndCheck(tmp, n[i].tags) then
          begin
            n[i].chck := v;
            Grid.SetCheckBoxState(0, i + 1, v);
          end;
      1:
        for i := 0 to Length(n) - 1 do
          if OrCheck(tmp, n[i].tags) then
          begin
            n[i].chck := v;
            Grid.SetCheckBoxState(0, i + 1, v);
          end;
    end;
  end;
end;

procedure TMainForm.GridCheckInverse;
var
  i: Integer;
begin
  if Length(PreList) > 0 then
    for i := 0 to Length(PreList) - 1 do
    begin
      PreList[i].chck := not PreList[i].chck;
      Grid.SetCheckBoxState(0, i + 1, PreList[i].chck);
    end
  else
    for i := 0 to Length(n) - 1 do
    begin
      n[i].chck := not n[i].chck;
      Grid.SetCheckBoxState(0, i + 1, n[i].chck);
    end;
end;

procedure TMainForm.GridCheckSelected(v: Boolean);
var
  i: Integer;
begin
  if Length(PreList) > 0 then
    for i := Grid.Selection.Top to Grid.Selection.Bottom do
    begin
      PreList[i - 1].chck := v;
      Grid.SetCheckBoxState(0, i, v);
    end
  else
    for i := Grid.Selection.Top to Grid.Selection.Bottom do
    begin
      n[i - 1].chck := v;
      Grid.SetCheckBoxState(0, i, v);
    end;
end;

procedure TMainForm.GridClear;
begin
  Grid.RowCount := 2;
  Grid.Rows[1].Clear;
  Grid.Visible := false;
  tbGrid.Visible := false;
  lRow.Caption := '';
  lRow.Visible := false;
  bgimage.Visible := true;
  { bgimage.Picture.Graphic.Free;
    bgimage.Picture.Graphic := nil; }
end;

procedure TMainForm.GridDblClickCell(Sender: TObject; ARow, ACol: Integer);
begin
  if not(ACol in [0, 5]) then
    with TAdvStringGrid(Sender) do
    begin
      // options := options + [goEditing];
      EditorMode := true;
    end;
end;

procedure TMainForm.GridExit(Sender: TObject);
begin
  Grid.Options := Grid.Options + [goEditing];
end;

procedure TMainForm.GridGetEditText(Sender: TObject; ACol, ARow: Integer;
  var Value: string);
begin
  TMyGrid(Sender).InplaceEditor.ReadOnly := true;
end;

procedure TMainForm.GridKeyDown(Sender: TObject; var key: Word;
  Shift: TShiftState);
begin
  case key of
    67:
      if (ssCtrl in Shift) then
      begin
        with TStringGrid(Sender) do
          Clipboard.AsText := Cells[Col, Row];
      end;
    VK_SHIFT:
      if not Grid.EditMode then
        Grid.Options := Grid.Options - [goEditing];
  end;
end;

procedure TMainForm.GridKeyUp(Sender: TObject; var key: Word;
  Shift: TShiftState);
begin
  case key of
    VK_SHIFT:
      if not Grid.EditMode then
        Grid.Options := Grid.Options + [goEditing];
  end;
end;

procedure TMainForm.GridScroll(var Msg: TWMVScroll);
begin
  if (prgress = 0) and FAutoScroll then
    chbautoscroll.Checked := false;
end;

procedure TMainForm.GridSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  if not CanSelect then
    Exit;
  if (prgress = 0) and FAutoScroll and (ARow <> (Sender as TAdvStringGrid).Row)
    and not((Sender as TAdvStringGrid).IsAutoSelect) then
    chbautoscroll.Checked := false;
  if RowCount > 0 then
  begin
    lRow.Caption := 'Line: ' + IntToStr(ARow) + ' / ' +
      IntToStr((Sender as TAdvStringGrid).RowCount - 1);
    if (pcMenu.ActivePage = tsMetadata) and not(prgress = 0) then
      mPicInfo.Text := GetNInfo(ARow - 1);
    if (pcMenu.ActivePage = tsMetadata) and (chbPreview.Checked) then
    begin
      if Length(n) > 0 then
        fPreview.Execute(n[ARow - 1].Preview, RESOURCE_URLS[curdest] +
          n[ARow - 1].pageurl, n[ARow - 1].title)
      else if Length(PreList) > 0 then
        fPreview.Execute(PreList[ARow - 1].Preview, PreList[ARow - 1].URL);
    end;
  end;
end;

procedure TMainForm.GridSetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: string);
begin
  with TStringGrid(Sender) do
    // options := options - [goEditing];
end;

function TMainForm.AddN(aurl: string; achck: Boolean): Integer;
var
  i: Integer;

begin
  result := -1;
  case hitcheck of
    0:
      if hit then
        Exit
      else
        for i := 0 to Length(n) - 1 do
          if n[i].URL = aurl then
          begin
            hit := true;
            Exit;
          end;
    1:
      for i := 0 to Length(n) - 1 do
        if n[i].URL = aurl then
          Exit;
  end;
  if hitcheck = -1 then
  begin
    SetLength(n, Length(n) + 1);
    i := Length(n) - 1;
  end
  else
  begin
    InsertN(nm);
    i := nm;
  end;
  inc(nm);
  with n[i] do
  begin
    URL := aurl;
    chck := achck;
    size := 0;
    work := 0;
    { author := 0;
      category := ''; }
  end;
  inc(npp);
  result := i;
end;

procedure TMainForm.AppEventsException(Sender: TObject; E: Exception);
begin
  LogErr('Critical error: ' + E.Message);
  prgress := -1;
  block(-1, 0);
end;

procedure TMainForm.AppEventsRestore(Sender: TObject);
begin
  prgrsbr.UpdateStates;
end;

procedure TMainForm.btnDefDirClick(Sender: TObject);
begin
  if MessageDlg('Do you realy want to change default folder? Current folder:' +
    #13#10 + DefFolder, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    DefFolder := IncludeTrailingPathDelimiter(edir.Text);
end;

procedure TMainForm.btnLoadDefDirClick(Sender: TObject);
begin
  edir.Text := DefFolder;
end;

procedure TMainForm.block(nn: Integer; prtype: Integer);
var
  n: Boolean;
begin
  prgress := nn;
  n := nn <> 0;
  btnCancel.Enabled := not n;
  tsiPicList.Enabled := n;
  tsiMetadata.Enabled := n and ((Length(Unit1.n) > 0) or (Length(PreList) > 0));
  tsiDownloading.Enabled := n and (Length(Unit1.n) > 0);
  tsiSettings.Enabled := n;
  // tsiMenuHide.Enabled := n;

  btnListGet.Enabled := n;
  tbiSave.Enabled := n and (Length(Unit1.n) > 0);
  tbiLoad.Enabled := n;
  tbiGridClose.Enabled := n;

  btnFindTag.Enabled := n;
  btnSelAll.Enabled := n;
  btnDeselAll.Enabled := n;
  btnSelInverse.Enabled := n;

  btnGrab.Enabled := n and (curdest > -1);
  btnBrowse.Enabled := n or (prtype <> 1);
  btnBrBrowse.Enabled := n or (prtype <> 1);
  btnDefDir.Enabled := n;
  btnLoadDefDir.Enabled := n;

  tbsiCheck.Enabled := n and ((Length(Unit1.n) > 0) or (Length(PreList) > 0));
  tbsiUncheck.Enabled := n and ((Length(Unit1.n) > 0) or (Length(PreList) > 0));
  tbiPrevious.Enabled :=(Length(Unit1.n) > 0);
  tbiNext.Enabled := (Length(Unit1.n) > 0);
  tbiGoto.Enabled := (Length(Unit1.n) > 0);

  // btnUpdTags.Enabled := n and (length(tags) > 0) and (curdest > -1);
  chbTagsIn.Enabled := n and (Length(tags) > 0);
  edir.Enabled := n;
  btnTagEdit.Enabled := n;
  chbSavedTags.Enabled := n;
  eSavedTags.Enabled := n and chbSavedTags.Checked;
  cbSite.Enabled := n;
  chbByAuthor.Enabled := n;
  euserid.Enabled := n and chbByAuthor.Checked;
  cbByAuthor.Enabled := n and chbByAuthor.Checked;
  eTag.Enabled := n and (not cbByAuthor.Visible or (cbByAuthor.ItemIndex < 1));
  eCategory.Enabled := n;
  btnCatEdit.Enabled := n;
  cbAfterFinish.Enabled := n;
  eCFilter.Enabled := n;
  chbPreview.Enabled := n;
  // chbsavepath.Enabled := n;
  cbExistingFile.Enabled := n;
  chbdownloadalbums.Enabled := n { and (curdest = RP_PIXIV) };
  chbcreatenewdirs.Enabled := n { and ((chbdownloadalbums.Enabled
    and chbdownloadalbums.Checked) or (curdest in [RP_EHENTAI_G,RP_EXHENTAI,RP_DEVIANTART])) };
  eThreadCount.Enabled := n;
  chbOpenDrive.Enabled := (cbLetter.Items.Count > 0) and n;
  btnAuth1.Enabled := n;
  btnAuth2.Enabled := n;
  // chbsavepwd.Enabled := n;
  chbproxy.Enabled := n;
  { chbDistByAuth.Enabled := n and (curdest = RP_PIXIV); }
  chblTagsCloud.Enabled := n;
  chbTrayIcon.Enabled := n;
  chbKeepInstance.Enabled := n;
  chbSaveNote.Enabled := n;
  chbdebug.Enabled := n;
{  chbQueryI1.Enabled := n;
  chbQueryI2.Enabled := n;  }
  chbNameFormat.Enabled := n and (curdest = RP_PIXIV);
  // eNameFormat.Enabled := n;
  chbAutoDirName.Enabled := n;
  // eAutoDirName.Enabled := chbAutoDirName.Checked and n;
  chbSaveJPEGMeta.Enabled := n;
  // btnDistByAuth.Enabled := n and (curdest in [RP_PIXIV]) and (Grid.RowCount > 1);
  pnlPBar.Visible := not n and (prtype <> 0);
  if n then
  begin
    updatecaption;
    if prtype <> 0 then
      case prgress of
        - 1, 2:
          pcMenu.ActiveTabIndex := FPreviousTab;
        1:
          if prtype <> 1 then
            pcMenu.ActiveTabIndex := FPreviousTab;
      end;
    DrawImageFromRes(iStatIcon, 'ZOK', '.png');
    with JvTrayIcon do
      if Active then
      begin
        if Icons <> nil then
          Icons := nil;
        Icon.Handle := LoadIcon(hInstance, PWideChar('ZICON'));
      end;
    if (pcMenu.ActivePage = tsMetadata) and chbPreview.Checked then
      pcMenuActiveTabChange(nil, 4);
    UpdateDataInterface;
  end
  else
  begin
    if prtype <> 0 then
    begin
      FPreviousTab := Max(0, pcMenu.ActiveTabIndex);
      tbiMenuHideClick(nil);
    end;
    ShowWindow(fPreview.Handle, SW_HIDE);
    // mPicInfo.Clear;
    DrawImageFromRes(iStatIcon, 'ZLOADING', '.gif');
  end;
  Grid.RepaintCol(0);
  updateinterface;
end;

procedure TMainForm.Hide1Click(Sender: TObject);
begin
  JvTrayIcon.HideApplication;
end;

procedure TMainForm.HTTPWork(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  if not(prgress = 0) then
    (ASender as TIdCustomHTTP).Disconnect;
end;

{ procedure DeleteAuthor(a: Integer);
  begin
  if a > 0 then
  dec(Authors[a-1].Count);
  end; }

procedure TMainForm.DeleteN(index: Integer);
var
  i: Integer;
begin
  for i := index to Length(n) - 2 do
    n[i] := n[i + 1];
  SetLength(n, Length(n) - 1);
end;

procedure TMainForm.DWNLDProc(n: Integer);
begin
  prgrsbr.SetPosition(n);
  if JvTrayIcon.Active then
    JvTrayIcon.Icon := IconMaker.MakeIcon(trunc(n / prgrsbr.Max * 100));

  updatecaption('[' + FloatToStr(RoundTo(diff(ncmpl, nsel) * 100, -2)) + '%]');
  StatusBar.SimpleText := 'OK ' + IntToStr(nok) + ' MISS ' + IntToStr(nmiss) +
    ' ERR ' + IntToStr(nerr) + ' SKIP ' + IntToStr(nskip) + ' TTL ' +
    IntToStr(nok + nmiss + nerr + nskip) + ' OVERALL ' +
    FloatToStr(RoundTo(diff(ncmpl, nsel) * 100, -2)) + '%';
end;

procedure TMainForm.CategoryPaste(Sender: TObject; var Text: string;
  var Accept: Boolean);
begin
  case cbSite.ItemIndex of
    RP_DEVIANTART:
      Text := CopyFromTo(Text, 'deviantart.com/', '?', false);
  end;
end;

{ procedure DeleteTags(a: TArrayOfWord);
  var
  i,n: integer;

  begin
  for i := 0 to length(a)-1 do
  dec(Tags[a[i]].Count);
  end; }

procedure TDownloadThread.DwnldHTTPWork(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  if not(prgress = 0) then
    (ASender as TIdCustomHTTP).Disconnect;
  n[num].work := AWorkCount;
  { CSection.Enter;
    try
    Grd.Rows[num + 1][4] := GetBtString
    (d.work / Max(MilliSecondsBetween(d.wtime, Date + Time),
    1000) * 1000) + '/s';
    Grd.Rows[num + 1][2] := GetBtString(d.work);

    Grd.Rows[num + 1][5] := FloatToStr
    (RoundTo(diff(d.work, d.size) * 100, -2)) + '%';
    finally
    CSection.Leave;
    end; }
  SMSG(msWORK);
  // Grd.Ints[5,num+1] := Round(AWorkCount * (MAXINT / MAX(d.work,MAXINT)));
end;

procedure TMainForm.HTTPWorkBegin(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCountMax: Int64);
begin
  if not(prgress = 0) then
    (ASender as TIdCustomHTTP).Disconnect;
end;

procedure TMainForm.iIconMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  case Button of
    mbLeft:
      begin
        if MainForm.WindowState <> wsMaximized then
        begin
          // Drag the form when dragging the toolbar
          ReleaseCapture;
          SendMessage(MainForm.Handle, WM_SYSCOMMAND, $F012, 0);
        end;
      end;
    mbRight:
      SpShowSystemPopupMenu(MainForm, Mouse.CursorPos);
  end;
end;

procedure TMainForm.iLainDblClick(Sender: TObject);
begin
  curLain := (curLain + 1) mod ZLAINS;
  DrawImageFromRes(iLain, 'ZLAIN' + IntToStr(curLain), '.png');
end;

procedure TMainForm.InsertN(index: Integer);
var
  i: Integer;
begin
  SetLength(n, Length(n) + 1);
  for i := Length(n) - 1 downto index + 1 do
    n[i] := n[i - 1];
end;

procedure TMainForm.JvTrayIconBalloonClick(Sender: TObject);
begin
  with TJvTrayIcon(Sender) do
    if ApplicationVisible then
      if not Application.Active then
        SetForegroundWindow(Application.Handle)
      else
    else
      ShowApplication;
  // ShowApplication;
end;

procedure TMainForm.JvTrayIconClick(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  with TJvTrayIcon(Sender) do
    if ApplicationVisible and not Application.Active then
      SetForegroundWindow(Application.Handle);
end;

procedure TMainForm.LoadFromFile(fname: string);
var
  f: textfile;
  s: string;
  n1: string;
  // n2: Integer;
  i: Integer;
  FileVersion: Integer;

begin
  try
    assignfile(f, fname);
    reset(f);
    readln(f, s);

    if (Length(s) > 0) and (s[1] <> '*') then
      FileVersion := 0
    else
    begin
      FileVersion := StrToInt(CopyFromTo(s, ':', ''));
      readln(f, s);
    end;

    curdest := StrToInt(GetNextS(s));

    if (FileVersion = 0) then
    begin
      if curdest = 5 then
        chbByAuthor.Checked := true;
      if curdest > 4 then
        dec(curdest);
    end;

    curdest := RVLIST[curdest];

    cbSite.ItemIndex := curdest;
    curtag := StringDecode(GetNextS(s));
    eTag.Text := curtag;
    chbSavedTagsClick(chbSavedTags);
    case curdest of
      RP_DEVIANTART:
        begin
          curcategory := StringDecode(GetNextS(s));
          eCategory.Text := curcategory;
        end;
      RP_PIXIV:
        if FileVersion > 0 then
        begin
          curByAuthor := StrToBool(GetNextS(s));
          chbByAuthor.Checked := curByAuthor;
          curuserid := StrToInt(GetNextS(s));
          euserid.Value := curuserid;
        end;
      RP_EHENTAI_G, RP_EXHENTAI:
        if FileVersion > 1 then
          chbOrigFNames.Checked := StrToBool(GetNextS(s));
    end;

    if FileVersion = 0 then
    begin
      curuserid := StrToInt(GetNextS(s));
      euserid.Value := curuserid;
      n1 := GetNextS(s);
      if n1 <> '' then
        finished := StrToBool(n1)
      else
        finished := true;
    end;

    n1 := StringDecode(GetNextS(s));

    if n1 <> '' then
      edir.Text := n1;

    ImportTags(GetNextS(s, ';', '"'), tags);
    ImportTags(GetNextS(s, ';', '"'), lbRelatedTags.Items);

    if curdest in (RS_POOLS - [RP_SANKAKU_IDOL, RP_SANKAKU_CHAN]) then
      if s <> '' then
      begin
        curInPools := StrToBool(GetNextS(s));
        chbInPools.Checked := curInPools;
      end;

    SetLength(n, 0);
    while not eof(f) do
    begin
      readln(f, s);
      n1 := GetNextS(s);
      i := AddN(n1, StrToBool(GetNextS(s)));
      if FileVersion = 0 then
        n1 := GetNextS(s);
      n[i].title := StringDecode(GetNextS(s));
      n[i].Params := StringDecode(GetNextS(s));
      n[i].postdate := StringDecode(GetNextS(s));
      n[i].Preview := GetNextS(s);
      n[i].pageurl := StringDecode(GetNextS(s));
      if FileVersion > 0 then
        n[i].category := StringDecode(GetNextS(s));
      n[i].tags := StringToArrayOfWord(GetNextS(s));
      CountTags(n[i].tags);
    end;
    closefile(f);
    cbSiteChange(nil);
    GenGrid;
    GenTags;
    sdList.InitialDir := ExtractFileDir(fname);
    sdList.FileName := ExtractFileName(fname);
    log('Loaded list "' + ExtractFileName(fname) + '" of ' + IntToStr(Length(n))
      + ' picture' + numstr(Length(n), '', '', '', true));
    saved := true;

    // UpdateDataInterface;
  except
    on E: Exception do
    begin
      curdest := -1;
      curtag := '';
      curuserid := -1;
      curcategory := '';
      curByAuthor := false;
      n := nil;
      closefile(f);
      LogErr('Error on loading file: ' + E.Message);
    end;
  end;
end;

procedure TMainForm.eCFilterChange(Sender: TObject);
begin
  if (Sender as TJvSpinEdit).Text <> '' then
    GenTags;
end;

procedure TMainForm.fdTagFind(Sender: TObject);

  function s(s,e: integer): boolean;
  var
    i: integer;
  begin
    for i := s to e do
      if pos(fdTag.FindText,chblTagsCloud.Items[i]) > 0 then
      begin  
        chblTagsCloud.ItemIndex := i;
        Result := true;
        Exit;
      end;
    Result := false;
  end;
  
begin
  fdTag.FindText := lowercase(fdTag.FindText);
  with  chblTagsCloud do
  begin
    if not s(ItemIndex + 1,Count - 1) then
      if not s(0,ItemIndex - 1) then
        MessageDlg('Nothing found',mtInformation,[mbOk],0);
  end;
end;

procedure TDownloadThread.DwnldHTTPWorkBegin(ASender: TObject;
  AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
  if not(prgress = 0) then
    (ASender as TIdCustomHTTP).Disconnect;

  n[num].work := 0;
  n[num].size := AWorkCountMax;
  n[num].wtime := Date + Time;

  if dwnld and IntBefDwnld then
    Synchronize(ProcStack);

  SMSG(msWCOUNT);
end;

procedure TMainForm.TBXItem10Click(Sender: TObject);
begin
  GridCheckByKeyword(false);
end;

procedure TMainForm.TBXItem11Click(Sender: TObject);
begin
  GridCheckByTag(false);
end;

procedure TMainForm.TBXItem12Click(Sender: TObject);
begin
  GridCheckSelected(true);
end;

procedure TMainForm.TBXItem13Click(Sender: TObject);
begin
  GridCheckSelected(false);
end;

procedure TMainForm.TBXItem1Click(Sender: TObject);
begin
  GridCheck(true);
end;

procedure TMainForm.TBXItem2Click(Sender: TObject);
begin
  GridCheck(false);
end;

procedure TMainForm.TBXItem3Click(Sender: TObject);
begin
  GridCheckInverse;
end;

procedure TMainForm.TBXItem5Click(Sender: TObject);
begin
  GridCheckByTag(true);
end;

procedure TMainForm.TBXItem6Click(Sender: TObject);
var
  i, n: Integer;
begin
  if RowCount = 0 then
    Exit;
  n := Grid.Row;
  if Grid.Col = 0 then
    Grid.Col := 1;
  for i := n - 1 downto 1 do
    if Grid.IsChecked(0, i) then
    begin
      Grid.Row := i;
      Exit;
    end;
  for i := Grid.RowCount - 1 downto n do
    if Grid.IsChecked(0, i) then
    begin
      Grid.Row := i;
      Exit;
    end;
  MessageDlg('No one is checked', mtInformation, [mbOk], 0);
end;

procedure TMainForm.TBXItem7Click(Sender: TObject);
var
  i, n: Integer;
begin

  if RowCount = 0 then
    Exit;
  n := Grid.Row;
  if Grid.Col = 0 then
    Grid.Col := 1;
  for i := n + 1 to Grid.RowCount - 1 do
    if Grid.IsChecked(0, i) then
    begin
      Grid.Row := i;
      Exit;
    end;
  for i := 1 to n do
  begin
    if Grid.IsChecked(0, i) then
    begin
      Grid.Row := i;
      Exit;
    end;
  end;
  MessageDlg('No one is checked', mtInformation, [mbOk], 0);
end;

procedure TMainForm.TBXItem8Click(Sender: TObject);
var
  n: variant;
begin
  n := InputBox('Go to line', 'Input line index', '0');
  try
    if (n > 0) and (n < Grid.RowCount - 1) then
    begin
      if Grid.Col = 0 then
        Grid.Col := 1;
      Grid.Row := n;
      Grid.SetFocus;
    end;
  except
    MessageDlg('Incorrect number', mtError, [mbOk], 0);
  end;
end;

procedure TMainForm.TBXItem9Click(Sender: TObject);
begin
  GridCheckByKeyword(true);
end;

procedure TMainForm.UpdateDataInterface;
var
  i: Integer;
begin
  i := 1;

  with chbdownloadalbums do
  begin
    Visible := curdest = RP_PIXIV;
    if Visible then
      inc(i);
  end;

  with chbcreatenewdirs do
    if (curdest in RS_GALLISTS + [RP_PIXIV, RP_DEVIANTART]) or
      (curdest in RS_POOLS) and curInPools then
    begin
      case curdest of
        RP_DEVIANTART:
          Caption := 'cr. new dirs for categories';
      else
        Caption := 'create new dirs for albums';
      end;
      Top := 59 + 23 * (i mod 3);
      Left := 9 * Integer(i < 3) + 173 * (i div 3);
      Visible := true;
      inc(i);
    end
    else
      Visible := false;

  if Length(tags) > 0 then
  begin
    chbTagsIn.Top := 59 + 23 * (i mod 3);
    chbTagsIn.Left := 9 * Integer(i < 3) + 173 * (i div 3);
    chbTagsIn.Visible := true;
    cbTagsIn.Top := 57 + 23 * (i mod 3);
    cbTagsIn.Left := chbTagsIn.Left + chbTagsIn.Width + 5;
    cbTagsIn.Visible := true;
    inc(i);
  end
  else
  begin
    chbTagsIn.Visible := false;
    cbTagsIn.Visible := false;
  end;

  if curdest in [RP_EHENTAI_G, RP_EXHENTAI] then
  begin
    // chbOrigFNames.Caption := 'original filenames';
    chbOrigFNames.Top := 59 + 23 * (i mod 3);
    chbOrigFNames.Left := 9 * Integer(i < 3) + 173 * (i div 3);
    chbOrigFNames.Visible := true;
    inc(i);
  end
  else
    chbOrigFNames.Visible := false;

  if curdest in [RP_THEDOUJIN, RP_EXHENTAI, RP_EHENTAI_G] then
  begin
    // chbOrigFNames.Caption := 'incremental filenames';
    chbIncFNames.Top := 59 + 23 * (i mod 3);
    chbIncFNames.Left := 9 * Integer(i < 3) + 173 * (i div 3);
    chbIncFNames.Visible := true;
    inc(i);
  end
  else
    chbIncFNames.Visible := false;

  if curdest in [RP_EHENTAI_G, RP_EXHENTAI{, RP_DEVIANTART}] then
  begin
    chbFullSize.Top := 59 + 23 * (i mod 3);
    chbFullSize.Left := 9 * Integer(i < 3) + 173 * (i div 3);
{    if curdest = RP_DEVIANTART then
      chbFullSize.Caption := 'Full Size'
    else
      chbFullSize.Caption := 'Full Size (spends GP)';  }
    chbFullSize.Visible := true;
    inc(i);
  end
  else
    chbFullSize.Visible := false;

  if curdest in [RP_EHENTAI_G, RP_EXHENTAI] then
  begin
    chbQueryI2.Top := 59 + 23 * (i mod 3);
    chbQueryI2.Left := 9 * Integer(i < 3) + 173 * (i div 3);
    chbQueryI2.Visible := true;
    { eQueryI.Top := 56 + 23 * (i mod 3);
      eQueryI.Left := lQueryI.Left + lQueryI.Width + 5;
      eQueryI.Visible := True; }
    inc(i);
  end
  else
  begin
    chbQueryI2.Visible := false;
    { eQueryI.Visible := false; }
  end;

  if curdest in [RP_PIXIV] then
  begin
    chbNameFormat.Top := 59 + 23 * (i mod 3);
    chbNameFormat.Left := 9 * Integer(i < 3) + 173 * (i div 3);
    chbNameFormat.Visible := true;
    eNameFormat.Top := 57 + 23 * (i mod 3);
    eNameFormat.Left := chbNameFormat.Left + chbNameFormat.Width + 5;
    eNameFormat.Visible := true;
    // inc(i);
  end
  else
  begin
    chbNameFormat.Visible := false;
    eNameFormat.Visible := false;
  end;

end;

end.
