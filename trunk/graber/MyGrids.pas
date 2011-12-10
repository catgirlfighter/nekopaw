{ ******************************************************* }
{ }
{ Delphi Visual Component Library }
{ }
{ Copyright(c) 1995-2010 Embarcadero Technologies, Inc. }
{ }
{ ******************************************************* }

unit MyGrids;
{$R-,T-,H+,X+}

interface

uses
{$IF NOT DEFINED(MSWINDOWS)}
  WinUtils,
{$IFEND}
  Messages, Windows, SysUtils, Classes, Variants,
  Types, Graphics, Menus, Controls, Forms, StdCtrls, Mask;

const
  MaxShortInt = High(ShortInt);
{$IF NOT DEFINED(CLR)}
  MaxCustomExtents = MaxListSize;
{$IFEND}

type
  EInvalidGridOperation = class(Exception);

    { Internal grid types }
    TGetExtentsFunc = function(Index: Longint): Integer of object;

    TGridAxisDrawInfo = record EffectiveLineWidth: Integer;
    FixedBoundary: Integer;
    GridBoundary: Integer;
    GridExtent: Integer;
    LastFullVisibleCell: Longint;
    FullVisBoundary: Integer;
    FixedCellCount: Integer;
    FirstGridCell: Integer;
    GridCellCount: Integer;
    GetExtent: TGetExtentsFunc;
  end;

  TGridDrawInfo = record
    Horz, Vert: TGridAxisDrawInfo;
  end;

  TGridState = (gsNormal, gsSelecting, gsRowSizing, gsColSizing, gsRowMoving,
    gsColMoving);
  TGridMovement = gsRowMoving .. gsColMoving;

  { TInplaceEdit }
  { The inplace editor is not intended to be used outside the grid }

  TCustomGrid = class;

  TInplaceEdit = class(TCustomMaskEdit)
  private
    FGrid: TCustomGrid;
    FClickTime: Longint;
    procedure InternalMove(const Loc: TRect; Redraw: Boolean);
    procedure SetGrid(Value: TCustomGrid);
    procedure CMShowingChanged(var Message: TMessage);
      message CM_SHOWINGCHANGED;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMPaste(var Message: TMessage); message WM_PASTE;
    procedure WMCut(var Message: TMessage); message WM_CUT;
    procedure WMClear(var Message: TMessage); message WM_CLEAR;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DblClick; override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;
    function EditCanModify: Boolean; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure BoundsChanged; virtual;
    procedure UpdateContents; virtual;
    procedure WndProc(var Message: TMessage); override;
    property Grid: TCustomGrid read FGrid;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Deselect;
    procedure Hide;
    procedure Invalidate; reintroduce;
    procedure Move(const Loc: TRect);
    function PosEqual(const Rect: TRect): Boolean;
    procedure SetFocus; reintroduce;
    procedure UpdateLoc(const Loc: TRect);
    function Visible: Boolean;
  end;

  { TCustomGrid }

  { TCustomGrid is an abstract base class that can be used to implement
    general purpose grid style controls.  The control will call DrawCell for
    each of the cells allowing the derived class to fill in the contents of
    the cell.  The base class handles scrolling, selection, cursor keys, and
    scrollbars.
    DrawCell
    Called by Paint. If DefaultDrawing is true the font and brush are
    intialized to the control font and cell color.  The cell is prepainted
    in the cell color and a focus rect is drawn in the focused cell after
    DrawCell returns.  The state passed will reflect whether the cell is
    a fixed cell, the focused cell or in the selection.
    SizeChanged
    Called when the size of the grid has changed.
    BorderStyle
    Allows a single line border to be drawn around the control.
    Col
    The current column of the focused cell (runtime only).
    ColCount
    The number of columns in the grid.
    ColWidths
    The width of each column (up to a maximum MaxCustomExtents, runtime
    only).
    DefaultColWidth
    The default column width.  Changing this value will throw away any
    customization done either visually or through ColWidths.
    DefaultDrawing
    Indicates whether the Paint should do the drawing talked about above in
    DrawCell.
    DefaultRowHeight
    The default row height.  Changing this value will throw away any
    customization done either visually or through RowHeights.
    FixedCols
    The number of non-scrolling columns.  This value must be at least one
    below ColCount.
    FixedRows
    The number of non-scrolling rows.  This value must be at least one
    below RowCount.
    GridLineWidth
    The width of the lines drawn between the cells.
    LeftCol
    The index of the left most displayed column (runtime only).
    Options
    The following options are available:
    goFixedHorzLine:     Draw horizontal grid lines in the fixed cell area.
    goFixedVertLine:     Draw veritical grid lines in the fixed cell area.
    goHorzLine:          Draw horizontal lines between cells.
    goVertLine:          Draw vertical lines between cells.
    goRangeSelect:       Allow a range of cells to be selected.
    goDrawFocusSelected: Draw the focused cell in the selected color.
    goRowSizing:         Allows rows to be individually resized.
    goColSizing:         Allows columns to be individually resized.
    goRowMoving:         Allows rows to be moved with the mouse
    goColMoving:         Allows columns to be moved with the mouse.
    goEditing:           Places an edit control over the focused cell.
    goAlwaysShowEditor:  Always shows the editor in place instead of
    waiting for a keypress or F2 to display it.
    goTabs:              Enables the tabbing between columns.
    goRowSelect:         Selection and movement is done a row at a time.
    Row
    The row of the focused cell (runtime only).
    RowCount
    The number of rows in the grid.
    RowHeights
    The hieght of each row (up to a maximum MaxCustomExtents, runtime
    only).
    ScrollBars
    Determines whether the control has scrollbars.
    Selection
    A TGridRect of the current selection.
    TopLeftChanged
    Called when the TopRow or LeftCol change.
    TopRow
    The index of the top most row displayed (runtime only)
    VisibleColCount
    The number of columns fully displayed.  There could be one more column
    partially displayed.
    VisibleRowCount
    The number of rows fully displayed.  There could be one more row
    partially displayed.

    Protected members, for implementors of TCustomGrid descendents
    DesignOptionBoost
    Options mixed in only at design time to aid design-time editing.
    Default = [goColSizing, goRowSizing], which makes grid cols and rows
    resizeable at design time, regardless of the Options settings.
    VirtualView
    Controls the use of maximum screen clipping optimizations when the
    grid window changes size.  Default = False, which means only the
    area exposed by the size change will be redrawn, for less flicker.
    VirtualView = True means the entire data area of the grid is redrawn
    when the size changes.  This is required when the data displayed in
    the grid is not bound to the number of rows or columns in the grid,
    such as the dbgrid (a few grid rows displaying a view onto a million
    row table).
    }

  TGridOption = (goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine,
    goRangeSelect, goDrawFocusSelected, goRowSizing, goColSizing, goRowMoving,
    goColMoving, goEditing, goTabs, goRowSelect, goAlwaysShowEditor,
    goThumbTracking, goFixedColClick, goFixedRowClick, goFixedHotTrack);
  TGridOptions = set of TGridOption;
  TGridDrawState = set of (gdSelected, gdFocused, gdFixed, gdRowSelected,
    gdHotTrack, gdPressed);
  TGridScrollDirection = set of (sdLeft, sdRight, sdUp, sdDown);

  TGridCoord = record
    X: Longint;
    Y: Longint;
  end;

  THotTrackCellInfo = record
    Coord: TGridCoord;
    Pressed: Boolean;
    Button: TMouseButton;
  end;
{$IF DEFINED(CLR)}

  TGridRect = TRect;
{$ELSE}

  TGridRect = record
    case Integer of
      0:
        (Left, Top, Right, Bottom: Longint);
      1:
        (TopLeft, BottomRight: TGridCoord);
  end;
{$IFEND}

  TEditStyle = (esSimple, esEllipsis, esPickList);

  TSelectCellEvent = procedure(Sender: TObject; ACol, ARow: Longint;
    var CanSelect: Boolean) of object;
  TDrawCellEvent = procedure(Sender: TObject; ACol, ARow: Longint; Rect: TRect;
    State: TGridDrawState) of object;
  TFixedCellClickEvent = procedure(Sender: TObject;
    ACol, ARow: Longint) of object;

  TGridDrawingStyle = (gdsClassic, gdsThemed, gdsGradient);

  TCustomGrid = class(TCustomControl)
  private
    FReadOnly: Boolean;
    FAnchor: TGridCoord;
    FBorderStyle: TBorderStyle;
    FCanEditModify: Boolean;
    FColCount: Longint;
    FCurrent: TGridCoord;
    FDefaultColWidth: Integer;
    FDefaultRowHeight: Integer;
    FDrawingStyle: TGridDrawingStyle;
    FFixedCols: Integer;
    FFixedRows: Integer;
    FFixedColor: TColor;
    FGradientEndColor: TColor;
    FGradientStartColor: TColor;
    FGridLineWidth: Integer;
    FOddColor: TColor;
    FOptions: TGridOptions;
    FPanPoint: TPoint;
    FRowCount: Longint;
    FScrollBars: TScrollStyle;
    FTopLeft: TGridCoord;
    FSizingIndex: Longint;
    FSizingPos, FSizingOfs: Integer;
    FMoveIndex, FMovePos: Longint;
    FHitTest: TPoint;
    FInplaceEdit: TInplaceEdit;
    FInplaceCol, FInplaceRow: Longint;
    FColOffset: Integer;
    FDefaultDrawing: Boolean;
    FEditorMode: Boolean;
    FRowHighlight: Boolean;
{$IF DEFINED(CLR)}
    FColWidths: TIntegerDynArray;
    FRowHeights: TIntegerDynArray;
    FTabStops: TIntegerDynArray;
{$ELSE}
    FColWidths: Pointer;
    FRowHeights: Pointer;
    FTabStops: Pointer;
{$IFEND}
    FOnFixedCellClick: TFixedCellClickEvent;
    function CalcCoordFromPoint(X, Y: Integer; const DrawInfo: TGridDrawInfo)
      : TGridCoord;
    procedure CalcDrawInfoXY(var DrawInfo: TGridDrawInfo;
      UseWidth, UseHeight: Integer);
    function CalcMaxTopLeft(const Coord: TGridCoord;
      const DrawInfo: TGridDrawInfo): TGridCoord;
    procedure CancelMode;
    procedure ChangeSize(NewColCount, NewRowCount: Longint);
    procedure ClampInView(const Coord: TGridCoord);
    procedure DrawSizingLine(const DrawInfo: TGridDrawInfo);
    procedure DrawMove;
    procedure GridRectToScreenRect(GridRect: TGridRect; var ScreenRect: TRect;
      IncludeLine: Boolean);
    procedure Initialize;
    procedure InvalidateRect(ARect: TGridRect);
    procedure ModifyScrollBar(ScrollBar, ScrollCode, Pos: Cardinal;
      UseRightToLeft: Boolean);
    procedure MoveAdjust(var CellPos: Longint; FromIndex, ToIndex: Longint);
    procedure MoveAnchor(const NewAnchor: TGridCoord);
    procedure MoveAndScroll(Mouse, CellHit: Integer;
      var DrawInfo: TGridDrawInfo; var Axis: TGridAxisDrawInfo;
      ScrollBar: Integer; const MousePt: TPoint);
    procedure MoveCurrent(ACol, ARow: Longint; MoveAnchor, Show: Boolean);
    procedure MoveTopLeft(ALeft, ATop: Longint);
    procedure ResizeCol(Index: Longint; OldSize, NewSize: Integer);
    procedure ResizeRow(Index: Longint; OldSize, NewSize: Integer);
    procedure SelectionMoved(const OldSel: TGridRect);
    procedure ScrollDataInfo(DX, DY: Integer; var DrawInfo: TGridDrawInfo);
    procedure TopLeftMoved(const OldTopLeft: TGridCoord);
    procedure UpdateScrollPos;
    procedure UpdateScrollRange;
    function GetColWidths(Index: Longint): Integer;
    function GetRowHeights(Index: Longint): Integer;
    function GetSelection: TGridRect;
    function GetTabStops(Index: Longint): Boolean;
    function GetVisibleColCount: Integer;
    function GetVisibleRowCount: Integer;
    function GetReadOnly: Boolean;
    procedure SetReadOnly(Value: Boolean);
    function IsActiveControl: Boolean;
    function IsGradientEndColorStored: Boolean;
    procedure ReadColWidths(Reader: TReader);
    procedure ReadRowHeights(Reader: TReader);
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetCol(Value: Longint);
    procedure SetColCount(Value: Longint);
    procedure SetColWidths(Index: Longint; Value: Integer);
    procedure SetDefaultColWidth(Value: Integer);
    procedure SetDefaultRowHeight(Value: Integer);
    procedure SetDrawingStyle(const Value: TGridDrawingStyle);
    procedure SetEditorMode(Value: Boolean);
    procedure SetFixedColor(Value: TColor);
    procedure SetFixedCols(Value: Integer);
    procedure SetFixedRows(Value: Integer);
    procedure SetGradientEndColor(Value: TColor);
    procedure SetGradientStartColor(Value: TColor);
    procedure SetGridLineWidth(Value: Integer);
    procedure SetLeftCol(Value: Longint);
    procedure SetOddColor(Value: TColor);
    procedure SetOptions(Value: TGridOptions);
    procedure SetRow(Value: Longint);
    procedure SetRowCount(Value: Longint);
    procedure SetRowHeights(Index: Longint; Value: Integer);
    procedure SetScrollBars(Value: TScrollStyle);
    procedure SetSelection(Value: TGridRect);
    procedure SetTabStops(Index: Longint; Value: Boolean);
    procedure SetTopRow(Value: Longint);
    procedure UpdateEdit;
    procedure UpdateText;
    procedure WriteColWidths(Writer: TWriter);
    procedure WriteRowHeights(Writer: TWriter);
    procedure CMCancelMode(var Msg: TCMCancelMode); message CM_CANCELMODE;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
    procedure CMDesignHitTest(var Msg: TCMDesignHitTest);
      message CM_DESIGNHITTEST;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMWantSpecialKey(var Msg: TCMWantSpecialKey);
      message CM_WANTSPECIALKEY;
    procedure CMShowingChanged(var Message: TMessage);
      message CM_SHOWINGCHANGED;
    procedure WMChar(var Msg: TWMChar); message WM_CHAR;
    procedure WMCancelMode(var Msg: TWMCancelMode); message WM_CANCELMODE;
    procedure WMCommand(var Message: TWMCommand); message WM_COMMAND;
    procedure WMGetDlgCode(var Msg: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMHScroll(var Msg: TWMHScroll); message WM_HSCROLL;
    procedure WMKillFocus(var Msg: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LBUTTONDOWN;
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMSetCursor(var Msg: TWMSetCursor); message WM_SETCURSOR;
    procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
    procedure WMTimer(var Msg: TWMTimer); message WM_TIMER;
    procedure WMVScroll(var Msg: TWMVScroll); message WM_VSCROLL;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    FGridState: TGridState;
    FSaveCellExtents: Boolean;
    DesignOptionsBoost: TGridOptions;
    VirtualView: Boolean;
    FInternalColor: TColor;
    FInternalDrawingStyle: TGridDrawingStyle;
    FHotTrackCell: THotTrackCellInfo;
    procedure CalcDrawInfo(var DrawInfo: TGridDrawInfo);
    procedure CalcFixedInfo(var DrawInfo: TGridDrawInfo);
    procedure CalcSizingState(X, Y: Integer; var State: TGridState;
      var Index: Longint; var SizingPos, SizingOfs: Integer;
      var FixedInfo: TGridDrawInfo); virtual;
    procedure ChangeGridOrientation(RightToLeftOrientation: Boolean);
    function CreateEditor: TInplaceEdit; virtual;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure DoGesture(const EventInfo: TGestureEventInfo;
      var Handled: Boolean); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      override;
    procedure AdjustSize(Index, Amount: Longint; Rows: Boolean); reintroduce;
      dynamic;
    function BoxRect(ALeft, ATop, ARight, ABottom: Longint): TRect;
    procedure DoExit; override;
    function CellRect(ACol, ARow: Longint): TRect;
    function CanEditAcceptKey(Key: Char): Boolean; dynamic;
    function CanGridAcceptKey(Key: Word; Shift: TShiftState): Boolean; dynamic;
    function CanEditModify: Boolean; dynamic;
    function CanEditShow: Boolean; virtual;
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean;
      override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean;
      override;
    procedure FixedCellClick(ACol, ARow: Longint); dynamic;
    procedure FocusCell(ACol, ARow: Longint; MoveAnchor: Boolean);
    function GetEditText(ACol, ARow: Longint): string; dynamic;
    procedure SetEditText(ACol, ARow: Longint; const Value: string); dynamic;
    function GetEditLimit: Integer; dynamic;
    function GetEditMask(ACol, ARow: Longint): string; dynamic;
    function GetEditStyle(ACol, ARow: Longint): TEditStyle; dynamic;
    function GetGridWidth: Integer;
    function GetGridHeight: Integer;
    procedure HideEdit;
    procedure HideEditor;
    procedure ShowEditor;
    procedure ShowEditorChar(Ch: Char);
    procedure InvalidateEditor;
    procedure InvalidateGrid; inline;
    procedure MoveColumn(FromIndex, ToIndex: Longint);
    procedure ColumnMoved(FromIndex, ToIndex: Longint); dynamic;
    procedure MoveRow(FromIndex, ToIndex: Longint);
    procedure RowMoved(FromIndex, ToIndex: Longint); dynamic;
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect;
      AState: TGridDrawState); virtual; abstract;
    procedure DrawCellBackground(const ARect: TRect; AColor: TColor;
      AState: TGridDrawState; ACol, ARow: Integer); virtual;
    procedure DrawCellHighlight(const ARect: TRect; AState: TGridDrawState;
      ACol, ARow: Integer); virtual;
    procedure DefineProperties(Filer: TFiler); override;
    procedure MoveColRow(ACol, ARow: Longint; MoveAnchor, Show: Boolean);
    function SelectCell(ACol, ARow: Longint): Boolean; virtual;
    procedure SizeChanged(OldColCount, OldRowCount: Longint); dynamic;
    function Sizing(X, Y: Integer): Boolean;
    procedure ScrollData(DX, DY: Integer);
    procedure InvalidateCell(ACol, ARow: Longint);
    procedure InvalidateCol(ACol: Longint);
    procedure InvalidateRow(ARow: Longint);
    function IsTouchPropertyStored(AProperty: TTouchProperty): Boolean;
      override;
    procedure TopLeftChanged; dynamic;
    procedure TimedScroll(Direction: TGridScrollDirection); dynamic;
    procedure Paint; override;
    procedure ColWidthsChanged; dynamic;
    procedure RowHeightsChanged; dynamic;
    procedure DeleteColumn(ACol: Longint); virtual;
    procedure DeleteRow(ARow: Longint); virtual;
    procedure UpdateDesigner;
    function BeginColumnDrag(var Origin, Destination: Integer;
      const MousePt: TPoint): Boolean; dynamic;
    function BeginRowDrag(var Origin, Destination: Integer;
      const MousePt: TPoint): Boolean; dynamic;
    function CheckColumnDrag(var Origin, Destination: Integer;
      const MousePt: TPoint): Boolean; dynamic;
    function CheckRowDrag(var Origin, Destination: Integer;
      const MousePt: TPoint): Boolean; dynamic;
    function EndColumnDrag(var Origin, Destination: Integer;
      const MousePt: TPoint): Boolean; dynamic;
    function EndRowDrag(var Origin, Destination: Integer;
      const MousePt: TPoint): Boolean; dynamic;
    property BorderStyle
      : TBorderStyle read FBorderStyle write SetBorderStyle
      default bsSingle;
    property Col: Longint read FCurrent.X write SetCol;
    property Color default clWindow;
    property ColCount: Longint read FColCount write SetColCount default 5;
    property ColWidths[Index: Longint]
      : Integer read GetColWidths write SetColWidths;
    property DefaultColWidth: Integer read FDefaultColWidth write
      SetDefaultColWidth default 64;
    property DefaultDrawing
      : Boolean read FDefaultDrawing write FDefaultDrawing
      default True;
    property DefaultRowHeight: Integer read FDefaultRowHeight write
      SetDefaultRowHeight default 24;
    property DrawingStyle: TGridDrawingStyle read FDrawingStyle write
      SetDrawingStyle default gdsThemed;
    property EditorMode: Boolean read FEditorMode write SetEditorMode;
    property FixedColor
      : TColor read FFixedColor write SetFixedColor default clBtnFace;
    property FixedCols: Integer read FFixedCols write SetFixedCols default 1;
    property FixedRows: Integer read FFixedRows write SetFixedRows default 1;
    property GradientEndColor: TColor read FGradientEndColor write
      SetGradientEndColor stored IsGradientEndColorStored;
    property GradientStartColor: TColor read FGradientStartColor write
      SetGradientStartColor default clWhite;
    property GridHeight: Integer read GetGridHeight;
    property GridLineWidth
      : Integer read FGridLineWidth write
      SetGridLineWidth default 1;
    property GridWidth: Integer read GetGridWidth;
    property HitTest: TPoint read FHitTest;
    property InplaceEditor: TInplaceEdit read FInplaceEdit;
    property LeftCol: Longint read FTopLeft.X write SetLeftCol;
    property OddColor: TColor read FOddColor write SetOddColor;
    property Options: TGridOptions read FOptions write SetOptions default
      [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine,
      goRangeSelect];
    property ParentColor default False;
    property Row: Longint read FCurrent.Y write SetRow;
    property RowCount: Longint read FRowCount write SetRowCount default 5;
    property RowHeights[Index: Longint]
      : Integer read GetRowHeights write SetRowHeights;
    property RowHighlight: Boolean read FRowHighlight write FRowHighlight;
    property ScrollBars
      : TScrollStyle read FScrollBars write SetScrollBars default
      ssBoth;
    property Selection: TGridRect read GetSelection write SetSelection;
    property TabStops[Index: Longint]
      : Boolean read GetTabStops write SetTabStops;
    property TopRow: Longint read FTopLeft.Y write SetTopRow;
    property VisibleColCount: Integer read GetVisibleColCount;
    property VisibleRowCount: Integer read GetVisibleRowCount;
    property OnFixedCellClick
      : TFixedCellClickEvent read FOnFixedCellClick write
      FOnFixedCellClick;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function MouseCoord(X, Y: Integer): TGridCoord;
  published
    property TabStop default True;
  end;

  { TCustomDrawGrid }

  { A grid relies on the OnDrawCell event to display the cells.
    CellRect
    This method returns control relative screen coordinates of the cell or
    an empty rectangle if the cell is not visible.
    EditorMode
    Setting to true shows the editor, as if the F2 key was pressed, when
    goEditing is turned on and goAlwaysShowEditor is turned off.
    MouseToCell
    Takes control relative screen X, Y location and fills in the column and
    row that contain that point.
    OnColumnMoved
    Called when the user request to move a column with the mouse when
    the goColMoving option is on.
    OnDrawCell
    This event is passed the same information as the DrawCell method
    discussed above.
    OnGetEditMask
    Called to retrieve edit mask in the inplace editor when goEditing is
    turned on.
    OnGetEditText
    Called to retrieve text to edit when goEditing is turned on.
    OnRowMoved
    Called when the user request to move a row with the mouse when
    the goRowMoving option is on.
    OnSetEditText
    Called when goEditing is turned on to reflect changes to the text
    made by the editor.
    OnTopLeftChanged
    Invoked when TopRow or LeftCol change. }

  TGetEditEvent = procedure(Sender: TObject; ACol, ARow: Longint;
    var Value: string) of object;
  TSetEditEvent = procedure(Sender: TObject; ACol, ARow: Longint;
    const Value: string) of object;
  TMovedEvent = procedure(Sender: TObject;
    FromIndex, ToIndex: Longint) of object;

  TCustomDrawGrid = class(TCustomGrid)
  private
    FOnColumnMoved: TMovedEvent;
    FOnDrawCell: TDrawCellEvent;
    FOnGetEditMask: TGetEditEvent;
    FOnGetEditText: TGetEditEvent;
    FOnRowMoved: TMovedEvent;
    FOnSelectCell: TSelectCellEvent;
    FOnSetEditText: TSetEditEvent;
    FOnTopLeftChanged: TNotifyEvent;
  protected
    procedure ColumnMoved(FromIndex, ToIndex: Longint); override;
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect;
      AState: TGridDrawState); override;
    function GetEditMask(ACol, ARow: Longint): string; override;
    function GetEditText(ACol, ARow: Longint): string; override;
    procedure RowMoved(FromIndex, ToIndex: Longint); override;
    function SelectCell(ACol, ARow: Longint): Boolean; override;
    procedure SetEditText(ACol, ARow: Longint; const Value: string); override;
    procedure TopLeftChanged; override;
    property OnColumnMoved
      : TMovedEvent read FOnColumnMoved write FOnColumnMoved;
    property OnDrawCell: TDrawCellEvent read FOnDrawCell write FOnDrawCell;
    property OnGetEditMask
      : TGetEditEvent read FOnGetEditMask write FOnGetEditMask;
    property OnGetEditText
      : TGetEditEvent read FOnGetEditText write FOnGetEditText;
    property OnRowMoved: TMovedEvent read FOnRowMoved write FOnRowMoved;
    property OnSelectCell
      : TSelectCellEvent read FOnSelectCell write FOnSelectCell;
    property OnSetEditText
      : TSetEditEvent read FOnSetEditText write FOnSetEditText;
    property OnTopLeftChanged
      : TNotifyEvent read FOnTopLeftChanged write FOnTopLeftChanged;
  public
    function CellRect(ACol, ARow: Longint): TRect;
    procedure MouseToCell(X, Y: Integer; var ACol, ARow: Longint);
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly;
    property Canvas;
    property Col;
    property ColWidths;
    property DrawingStyle;
    property EditorMode;
    property GridHeight;
    property GridWidth;
    property LeftCol;
    property Selection;
    property Row;
    property RowHeights;
    property TabStops;
    property TopRow;
  end;

  { TDrawGrid }

  TDrawGrid = class(TCustomDrawGrid)
  published
    property Align;
    property Anchors;
    property BevelEdges;
    property BevelInner;
    property BevelKind;
    property BevelOuter;
    property BevelWidth;
    property BiDiMode;
    property BorderStyle;
    property Color;
    property ColCount;
    property Constraints;
    property Ctl3D;
    property DefaultColWidth;
    property DefaultRowHeight;
    property DefaultDrawing;
    property DoubleBuffered;
    property DragCursor;
    property DragKind;
    property DragMode;
    property DrawingStyle;
    property Enabled;
    property FixedColor;
    property FixedCols;
    property RowCount;
    property FixedRows;
    property Font;
    property GradientEndColor;
    property GradientStartColor;
    property GridLineWidth;
    property Options;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentDoubleBuffered;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ScrollBars;
    property ShowHint;
    property TabOrder;
    property Touch;
    property Visible;
    property VisibleColCount;
    property VisibleRowCount;
    property OnClick;
    property OnColumnMoved;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawCell;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnFixedCellClick;
    property OnGesture;
    property OnGetEditMask;
    property OnGetEditText;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnRowMoved;
    property OnSelectCell;
    property OnSetEditText;
    property OnStartDock;
    property OnStartDrag;
    property OnTopLeftChanged;
  end;

  { TStringGrid }

  { TStringGrid adds to TDrawGrid the ability to save a string and associated
    object (much like TListBox).  It also adds to the DefaultDrawing the drawing
    of the string associated with the current cell.
    Cells
    A ColCount by RowCount array of strings which are associated with each
    cell.  By default, the string is drawn into the cell before OnDrawCell
    is called.  This can be turned off (along with all the other default
    drawing) by setting DefaultDrawing to false.
    Cols
    A TStrings object that contains the strings and objects in the column
    indicated by Index.  The TStrings will always have a count of RowCount.
    If a another TStrings is assigned to it, the strings and objects beyond
    RowCount are ignored.
    Objects
    A ColCount by Rowcount array of TObject's associated with each cell.
    Object put into this array will *not* be destroyed automatically when
    the grid is destroyed.
    Rows
    A TStrings object that contains the strings and objects in the row
    indicated by Index.  The TStrings will always have a count of ColCount.
    If a another TStrings is assigned to it, the strings and objects beyond
    ColCount are ignored. }

  TStringGrid = class;

  TStringGridStrings = class(TStrings)
  private
    FGrid: TStringGrid;
    FIndex: Integer;
    procedure CalcXY(Index: Integer; var X, Y: Integer);
{$IF DEFINED(CLR)}
    function BlankStr(TheIndex: Integer; TheItem: TObject): Integer;
{$IFEND}
  protected
    function Get(Index: Integer): string; override;
    function GetCount: Integer; override;
    function GetObject(Index: Integer): TObject; override;
    procedure Put(Index: Integer; const S: string); override;
    procedure PutObject(Index: Integer; AObject: TObject); override;
    procedure SetUpdateState(Updating: Boolean); override;
  public
    constructor Create(AGrid: TStringGrid; AIndex: Longint);
    function Add(const S: string): Integer; override;
    procedure Assign(Source: TPersistent); override;
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Insert(Index: Integer; const S: string); override;
  end;

  TStringGrid = class(TDrawGrid)
  private
    FAutoRepaint: Boolean;
    FCheckboxes: Boolean;
    FUpdating: Boolean;
    FNeedsUpdating: Boolean;
    FEditUpdate: Integer;
    FData: TCustomData;
    FRows: TCustomData;
    FCols: TCustomData;
{$IF DEFINED(CLR)}
    FTempFrom: Integer;
    FTempTo: Integer;
{$IFEND}
    procedure DisableEditUpdate;
    procedure EnableEditUpdate;
    procedure Initialize;
    procedure Update(ACol, ARow: Integer); reintroduce;
    procedure SetUpdateState(Updating: Boolean);
    function GetCells(ACol, ARow: Integer): string;
    function GetCols(Index: Integer): TStrings;
    function GetObjects(ACol, ARow: Integer): TObject;
    function GetRows(Index: Integer): TStrings;
    procedure SetCells(ACol, ARow: Integer; const Value: string);
    procedure SetCols(Index: Integer; Value: TStrings);
    procedure SetObjects(ACol, ARow: Integer; Value: TObject);
    procedure SetRows(Index: Integer; Value: TStrings);
    function EnsureColRow(Index: Integer; IsCol: Boolean): TStringGridStrings;
    function EnsureDataRow(ARow: Integer): TCustomData;
  protected
    procedure ColumnMoved(FromIndex, ToIndex: Longint); override;
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect;
      AState: TGridDrawState); override;
    function GetEditText(ACol, ARow: Longint): string; override;
    procedure SetEditText(ACol, ARow: Longint; const Value: string); override;
    procedure RowMoved(FromIndex, ToIndex: Longint); override;
{$IF DEFINED(CLR)}
    function MoveColData(Index: Integer; ARow: TObject): Integer;
{$IFEND}
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property AutoRepaint: Boolean read FAutoRepaint write FAutoRepaint;
    property Cells[ACol, ARow: Integer]: string read GetCells write SetCells;
    property CheckBoxes: Boolean read FCheckboxes write FCheckboxes;
    property Cols[Index: Integer]: TStrings read GetCols write SetCols;
    property Objects[ACol, ARow: Integer]
      : TObject read GetObjects write SetObjects;
    property Rows[Index: Integer]: TStrings read GetRows write SetRows;
  end;

  { TInplaceEditList }

  { TInplaceEditList adds to TInplaceEdit the ability to drop down a pick list
    of possible values or to display an ellipsis button which will invoke
    user code in an event to bring up a modal dialog.  The EditStyle property
    determines which type of button to draw (if any)
    ActiveList
    TWinControl reference which typically points to the internal
    PickList.  May be set to a different list by descendent inplace
    editors which provide additional functionality.
    ButtonWidth
    The width of the button used to drop down the pick list.
    DropDownRows
    The maximum number of rows to display at a time in the pick list.
    EditStyle
    Indicates what type of list to display (none, custom, or picklist).
    ListVisible
    Indicates if the list is currently dropped down.
    PickList
    Reference to the internal PickList (a TCustomListBox).
    Pressed
    Indicates if the button is currently pressed. }

  TOnGetPickListItems = procedure(ACol, ARow: Integer;
    Items: TStrings) of Object;

  TInplaceEditList = class(TInplaceEdit)
  private
    FButtonWidth: Integer;
    FPickList: TCustomListbox;
    FActiveList: TWinControl;
    FEditStyle: TEditStyle;
    FDropDownRows: Integer;
    FListVisible: Boolean;
    FTracking: Boolean;
    FPressed: Boolean;
    FPickListLoaded: Boolean;
    FOnGetPickListitems: TOnGetPickListItems;
    FOnEditButtonClick: TNotifyEvent;
    FMouseInControl: Boolean;
    function GetPickList: TCustomListbox;
    procedure CMCancelMode(var Message: TCMCancelMode); message CM_CANCELMODE;
    procedure WMCancelMode(var Message: TWMCancelMode); message WM_CANCELMODE;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk);
      message wm_LButtonDblClk;
    procedure WMPaint(var Message: TWMPaint); message wm_Paint;
    procedure WMSetCursor(var Message: TWMSetCursor); message WM_SETCURSOR;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  protected
    procedure BoundsChanged; override;
    function ButtonRect: TRect;
    procedure CloseUp(Accept: Boolean); dynamic;
    procedure DblClick; override;
    procedure DoDropDownKeys(var Key: Word; Shift: TShiftState); virtual;
    procedure DoEditButtonClick; virtual;
    procedure DoGetPickListItems; dynamic;
    procedure DropDown; dynamic;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure ListMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      override;
    function OverButton(const P: TPoint): Boolean;
    procedure PaintWindow(DC: HDC); override;
    procedure StopTracking;
    procedure TrackButton(X, Y: Integer);
    procedure UpdateContents; override;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(Owner: TComponent); override;
    procedure RestoreContents;
    property ActiveList: TWinControl read FActiveList write FActiveList;
    property ButtonWidth: Integer read FButtonWidth write FButtonWidth;
    property DropDownRows: Integer read FDropDownRows write FDropDownRows;
    property EditStyle: TEditStyle read FEditStyle;
    property ListVisible: Boolean read FListVisible write FListVisible;
    property PickList: TCustomListbox read GetPickList;
    property PickListLoaded: Boolean read FPickListLoaded write FPickListLoaded;
    property Pressed: Boolean read FPressed;
    property OnEditButtonClick
      : TNotifyEvent read FOnEditButtonClick write FOnEditButtonClick;
    property OnGetPickListitems
      : TOnGetPickListItems read FOnGetPickListitems write
      FOnGetPickListitems;
  end;

implementation

uses
{$IF DEFINED(CLR)}
  System.Runtime.InteropServices, System.Security.Permissions,
{$IFEND}
  Math, Themes, RTLConsts, Consts, UxTheme, GraphUtil;
{$IF NOT DEFINED(CLR)}

type
  PIntArray = ^TIntArray;
  TIntArray = array [0 .. MaxCustomExtents] of Integer;
{$IFEND}

procedure InvalidOp(const id: string);
begin
  raise EInvalidGridOperation.Create(id);
end;

function GridRect(Coord1, Coord2: TGridCoord): TGridRect;
begin
  with Result do
  begin
    Left := Coord2.X;
    if Coord1.X < Coord2.X then
      Left := Coord1.X;
    Right := Coord1.X;
    if Coord1.X < Coord2.X then
      Right := Coord2.X;
    Top := Coord2.Y;
    if Coord1.Y < Coord2.Y then
      Top := Coord1.Y;
    Bottom := Coord1.Y;
    if Coord1.Y < Coord2.Y then
      Bottom := Coord2.Y;
  end;
end;

function PointInGridRect(Col, Row: Longint; const Rect: TGridRect): Boolean;
begin
  Result := (Col >= Rect.Left) and (Col <= Rect.Right) and (Row >= Rect.Top)
    and (Row <= Rect.Bottom);
end;

type
  TXorRects = array [0 .. 3] of TRect;

procedure XorRects(const R1, R2: TRect; var XorRects: TXorRects);
var
  Intersect, Union: TRect;

  function PtInRect(X, Y: Integer; const Rect: TRect): Boolean;
  begin
    with Rect do
      Result := (X >= Left) and (X <= Right) and (Y >= Top) and (Y <= Bottom);
  end;
{$IF DEFINED(CLR)}
  function Includes(const P1: TPoint; P2: TPoint): Boolean;
  begin
    with P1 do
      Result := PtInRect(X, Y, R1) or PtInRect(X, Y, R2);
  end;
{$ELSE}
  function Includes(const P1: TPoint; var P2: TPoint): Boolean;
  begin
    with P1 do
    begin
      Result := PtInRect(X, Y, R1) or PtInRect(X, Y, R2);
      if Result then
        P2 := P1;
    end;
  end;
{$IFEND}
{$IF DEFINED(CLR)}
  function Build(var R: TRect; const P1, P2, P3: TPoint): Boolean;
  begin
    Build := True;
    with R do
      if Includes(P1, R.TopLeft) then
      begin
        Left := P1.X;
        Top := P1.Y;
        if Includes(P3, R.BottomRight) then
        begin
          Right := P3.X;
          Bottom := P3.Y;
        end
        else
        begin
          Right := P2.X;
          Bottom := P2.Y;
        end
      end
      else if Includes(P2, R.TopLeft) then
      begin
        Left := P2.X;
        Top := P2.Y;
        Bottom := P3.Y;
        Right := P3.X;
      end
      else
        Build := False;
  end;
{$ELSE}
  function Build(var R: TRect; const P1, P2, P3: TPoint): Boolean;
  begin
    Build := True;
    with R do
      if Includes(P1, TopLeft) then
      begin
        if not Includes(P3, BottomRight) then
          BottomRight := P2;
      end
      else if Includes(P2, TopLeft) then
        BottomRight := P3
      else
        Build := False;
  end;
{$IFEND}

begin
{$IF NOT DEFINED(CLR)}
  FillChar(XorRects, SizeOf(XorRects), 0);
{$IFEND}
  if not IntersectRect(Intersect, R1, R2) then
  begin
    { Don't intersect so its simple }
    XorRects[0] := R1;
    XorRects[1] := R2;
  end
  else
  begin
    UnionRect(Union, R1, R2);
    if Build(XorRects[0], Point(Union.Left, Union.Top),
      Point(Union.Left, Intersect.Top), Point(Union.Left, Intersect.Bottom))
      then
      XorRects[0].Right := Intersect.Left;
    if Build(XorRects[1], Point(Intersect.Left, Union.Top),
      Point(Intersect.Right, Union.Top), Point(Union.Right, Union.Top)) then
      XorRects[1].Bottom := Intersect.Top;
    if Build(XorRects[2], Point(Union.Right, Intersect.Top),
      Point(Union.Right, Intersect.Bottom), Point(Union.Right, Union.Bottom))
      then
      XorRects[2].Left := Intersect.Right;
    if Build(XorRects[3], Point(Union.Left, Union.Bottom),
      Point(Intersect.Left, Union.Bottom),
      Point(Intersect.Right, Union.Bottom)) then
      XorRects[3].Top := Intersect.Bottom;
  end;
end;
{$IF DEFINED(CLR)}

procedure ModifyExtents(var Extents: TIntegerDynArray; Index, Amount: Longint;
{$ELSE}
procedure ModifyExtents(var Extents: Pointer; Index, Amount: Longint;
{$IFEND}
  Default: Integer);
var
  LongSize, OldSize: Longint;
  NewSize: Integer;
  I: Integer;
begin
  if Amount <> 0 then
  begin
{$IF DEFINED(CLR)}
    if Length(Extents) = 0 then
      OldSize := 0
    else
      OldSize := Extents[0];
{$ELSE}
    if not Assigned(Extents) then
      OldSize := 0
    else
      OldSize := PIntArray(Extents)^[0];
{$IFEND}
    if (Index < 0) or (OldSize < Index) then
      InvalidOp(SIndexOutOfRange);
    LongSize := OldSize + Amount;
    if LongSize < 0 then
      InvalidOp(STooManyDeleted)
    else if LongSize >= MaxListSize - 1 then
      InvalidOp(SGridTooLarge);
    NewSize := Cardinal(LongSize);
    if NewSize > 0 then
      Inc(NewSize);
{$IF DEFINED(CLR)}
    SetLength(Extents, NewSize);
    if Length(Extents) <> 0 then
{$ELSE}
      ReallocMem(Extents, NewSize * SizeOf(Integer));
    if Assigned(Extents) then
{$IFEND}
    begin
      I := Index + 1;
      while I < NewSize do
{$IF DEFINED(CLR)}
      begin
        Extents[I] := Default;
        Inc(I);
      end;
      Extents[0] := NewSize - 1;
{$ELSE}
      begin
        PIntArray(Extents)^[I] := Default;
        Inc(I);
      end;
      PIntArray(Extents)^[0] := NewSize - 1;
{$IFEND}
    end;
  end;
end;
{$IF DEFINED(CLR)}

procedure UpdateExtents(var Extents: TIntegerDynArray; NewSize: Longint;
  Default: Integer);
{$ELSE}
  procedure UpdateExtents(var Extents: Pointer; NewSize: Longint;
    Default: Integer);
{$IFEND}
  var
    OldSize: Integer;
  begin
    OldSize := 0;
{$IF DEFINED(CLR)}
    if Length(Extents) <> 0 then
      OldSize := Extents[0];
{$ELSE}
    if Assigned(Extents) then
      OldSize := PIntArray(Extents)^[0];
{$IFEND}
    ModifyExtents(Extents, OldSize, NewSize - OldSize, Default);
  end;
{$IF DEFINED(CLR)}
  procedure MoveExtent(var Extents: TIntegerDynArray;
    FromIndex, ToIndex: Longint);
  var
    Extent, I: Integer;
  begin
    if Length(Extents) <> 0 then
    begin
      Extent := Extents[FromIndex];
      if FromIndex < ToIndex then
        for I := FromIndex + 1 to ToIndex do
          Extents[I - 1] := Extents[I]
        else if FromIndex > ToIndex then
          for I := FromIndex - 1 downto ToIndex do
            Extents[I + 1] := Extents[I];
      Extents[ToIndex] := Extent;
    end;
  end;
{$ELSE}
  procedure MoveExtent(var Extents: Pointer; FromIndex, ToIndex: Longint);
  var
    Extent: Integer;
  begin
    if Assigned(Extents) then
    begin
      Extent := PIntArray(Extents)^[FromIndex];
      if FromIndex < ToIndex then
        Move(PIntArray(Extents)^[FromIndex + 1],
          PIntArray(Extents)^[FromIndex],
          (ToIndex - FromIndex) * SizeOf(Integer))
      else if FromIndex > ToIndex then
        Move(PIntArray(Extents)^[ToIndex], PIntArray(Extents)^[ToIndex + 1],
          (FromIndex - ToIndex) * SizeOf(Integer));
      PIntArray(Extents)^[ToIndex] := Extent;
    end;
  end;
{$IFEND}
{$IF DEFINED(CLR)}
  function CompareExtents(E1, E2: TIntegerDynArray): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    if Length(E1) <> 0 then
    begin
      if Length(E2) <> 0 then
      begin
        for I := 0 to E1[0] do
          if E1[I] <> E2[I] then
            Exit;
        Result := True;
      end
    end
    else
      Result := Length(E2) = 0;
  end;
{$ELSE}
  function CompareExtents(E1, E2: Pointer): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    if E1 <> nil then
    begin
      if E2 <> nil then
      begin
        for I := 0 to PIntArray(E1)^[0] do
          if PIntArray(E1)^[I] <> PIntArray(E2)^[I] then
            Exit;
        Result := True;
      end
    end
    else
      Result := E2 = nil;
  end;
{$IFEND}
{ Private. LongMulDiv multiplys the first two arguments and then
  divides by the third.  This is used so that real number
  (floating point) arithmetic is not necessary.  This routine saves
  the possible 64-bit value in a temp before doing the divide.  Does
  not do error checking like divide by zero.  Also assumes that the
  result is in the 32-bit range (Actually 31-bit, since this algorithm
  is for unsigned). }
{$IFDEF LINUX}
function LongMulDiv(Mult1, Mult2, Div1: Longint): Longint; stdcall;
external 'libwine.borland.so' name 'MulDiv';
{$ENDIF}
{$IFDEF MSWINDOWS}
function LongMulDiv(Mult1, Mult2, Div1: Longint): Longint; stdcall;
external 'kernel32.dll' name 'MulDiv';
{$ENDIF}
  procedure KillMessage(Wnd: HWnd; Msg: Integer);
  // Delete the requested message from the queue, but throw back
  // any WM_QUIT msgs that PeekMessage may also return
  var
    M: TMsg;
  begin
    M.Message := 0;
    if PeekMessage(M, Wnd, Msg, Msg, pm_Remove) and (M.Message = WM_QUIT) then
      PostQuitMessage(M.wparam);
  end;

  constructor TInplaceEdit.Create(AOwner: TComponent);
  begin
    inherited Create(AOwner);
    ParentCtl3D := False;
    Ctl3D := False;
    TabStop := False;
    BorderStyle := bsNone;
    DoubleBuffered := False;
  end;

  procedure TInplaceEdit.CreateParams(var Params: TCreateParams);
  begin
    inherited CreateParams(Params);
    Params.Style := Params.Style or ES_MULTILINE;
  end;

  procedure TInplaceEdit.SetGrid(Value: TCustomGrid);
  begin
    FGrid := Value;
  end;

  procedure TInplaceEdit.CMShowingChanged(var Message: TMessage);
  begin
    { Ignore showing using the Visible property }
  end;

  procedure TInplaceEdit.WMGetDlgCode(var Message: TWMGetDlgCode);
  begin
    inherited;
    if goTabs in Grid.Options then
      Message.Result := Message.Result or DLGC_WANTTAB;
  end;

[UIPermission(SecurityAction.LinkDemand,
  Clipboard = UIPermissionClipboard.AllClipboard)]
  procedure TInplaceEdit.WMPaste(var Message: TMessage);
  begin
    if not EditCanModify then
      Exit;
    inherited
  end;

  procedure TInplaceEdit.WMClear(var Message: TMessage);
  begin
    if not EditCanModify then
      Exit;
    inherited;
  end;

  procedure TInplaceEdit.WMCut(var Message: TMessage);
  begin
    if not EditCanModify then
      Exit;
    inherited;
  end;

  procedure TInplaceEdit.DblClick;
  begin
    Grid.DblClick;
  end;

  function TInplaceEdit.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
    MousePos: TPoint): Boolean;
  begin
    Result := Grid.DoMouseWheel(Shift, WheelDelta, MousePos);
  end;

  function TInplaceEdit.EditCanModify: Boolean;
  begin
    Result := Grid.CanEditModify;
  end;

  procedure TInplaceEdit.KeyDown(var Key: Word; Shift: TShiftState);

    procedure SendToParent;
    begin
      Grid.KeyDown(Key, Shift);
      Key := 0;
    end;

    procedure ParentEvent;
    var
      GridKeyDown: TKeyEvent;
    begin
      GridKeyDown := Grid.OnKeyDown;
      if Assigned(GridKeyDown) then
        GridKeyDown(Grid, Key, Shift);
    end;

    function ForwardMovement: Boolean;
    begin
      Result := goAlwaysShowEditor in Grid.Options;
    end;

    function Ctrl: Boolean;
    begin
      Result := ssCtrl in Shift;
    end;

    function Selection: TSelection;
    begin
{$IF DEFINED(CLR)}
      SendGetSel(Result.StartPos, Result.EndPos);
{$ELSE}
      SendMessage(Handle, EM_GETSEL, Longint(@Result.StartPos),
        Longint(@Result.EndPos));
{$IFEND}
    end;

    function CaretPos: Integer;
    var
      P: TPoint;
    begin
      Windows.GetCaretPos(P);
      Result := SendMessage(Handle, EM_CHARFROMPOS, 0, MakeLong(P.X, P.Y));
    end;

    function RightSide: Boolean;
    begin
      with Selection do
        Result := (CaretPos = GetTextLen) and
          ((StartPos = 0) or (EndPos = StartPos)) and (EndPos = GetTextLen);
    end;

    function LeftSide: Boolean;
    begin
      with Selection do
        Result := (CaretPos = 0) and (StartPos = 0) and
          ((EndPos = 0) or (EndPos = GetTextLen));
    end;

  begin
    case Key of
      VK_UP, VK_DOWN, VK_PRIOR, VK_NEXT, VK_ESCAPE:
        SendToParent;
      VK_INSERT:
        if Shift = [] then
          SendToParent
        else if (Shift = [ssShift]) and not Grid.CanEditModify then
          Key := 0;
      VK_LEFT:
        if ForwardMovement and (Ctrl or LeftSide) then
          SendToParent;
      VK_RIGHT:
        if ForwardMovement and (Ctrl or RightSide) then
          SendToParent;
      VK_HOME:
        if ForwardMovement and (Ctrl or LeftSide) then
          SendToParent;
      VK_END:
        if ForwardMovement and (Ctrl or RightSide) then
          SendToParent;
      VK_F2:
        begin
          ParentEvent;
          if Key = VK_F2 then
          begin
            Deselect;
            Exit;
          end;
        end;
      VK_TAB:
        if not(ssAlt in Shift) then
          SendToParent;
      VK_DELETE:
        if Ctrl then
          SendToParent
        else if not Grid.CanEditModify then
          Key := 0;
    end;
    if Key <> 0 then
    begin
      ParentEvent;
      inherited KeyDown(Key, Shift);
    end;
  end;

  procedure TInplaceEdit.KeyPress(var Key: Char);
  var
    Selection: TSelection;
  begin
    Grid.KeyPress(Key);
    if (Key >= #32) and not Grid.CanEditAcceptKey(Key) then
    begin
      Key := #0;
      MessageBeep(0);
    end;
    case Key of
      #9, #27:
        Key := #0;
      #13:
        begin
{$IF DEFINED(CLR)}
          SendGetSel(Selection.StartPos, Selection.EndPos);
{$ELSE}
          SendMessage(Handle, EM_GETSEL, Longint(@Selection.StartPos),
            Longint(@Selection.EndPos));
{$IFEND}
          if (Selection.StartPos = 0) and (Selection.EndPos = GetTextLen) then
            Deselect
          else
            SelectAll;
          Key := #0;
        end;
      ^H, ^V, ^X, #32 .. High(Char):
        if not Grid.CanEditModify then
          Key := #0;
    end;
    if Key <> #0 then
      inherited KeyPress(Key);
  end;

  procedure TInplaceEdit.KeyUp(var Key: Word; Shift: TShiftState);
  begin
    Grid.KeyUp(Key, Shift);
  end;

  procedure TInplaceEdit.WndProc(var Message: TMessage);
  begin
    case Message.Msg of
      WM_SETFOCUS:
        begin
          if (GetParentForm(Self) = nil) or GetParentForm(Self)
            .SetFocusedControl(Grid) then
            Dispatch(Message);
          Exit;
        end;
      WM_LBUTTONDOWN:
        begin
          if UINT(GetMessageTime - FClickTime) < GetDoubleClickTime then
            Message.Msg := wm_LButtonDblClk;
          FClickTime := 0;
        end;
    end;
    inherited WndProc(Message);
  end;

  procedure TInplaceEdit.Deselect;
  begin
    SendMessage(Handle, EM_SETSEL, $7FFFFFFF, Longint($FFFFFFFF));
  end;

  procedure TInplaceEdit.Invalidate;
  var
    Cur: TRect;
  begin
    ValidateRect(Handle, nil);
    InvalidateRect(Handle, nil, True);
    Windows.GetClientRect(Handle, Cur);
    MapWindowPoints(Handle, Grid.Handle, Cur, 2);
    ValidateRect(Grid.Handle, Cur);
    InvalidateRect(Grid.Handle, Cur, False);
  end;

  procedure TInplaceEdit.Hide;
  begin
    if HandleAllocated and IsWindowVisible(Handle) then
    begin
      Invalidate;
      SetWindowPos(Handle, 0, 0, 0, 0, 0,
        SWP_HIDEWINDOW or SWP_NOZORDER or SWP_NOREDRAW);
      if Focused then
        Windows.SetFocus(Grid.Handle);
    end;
  end;

  function TInplaceEdit.PosEqual(const Rect: TRect): Boolean;
  var
    Cur: TRect;
  begin
    GetWindowRect(Handle, Cur);
    MapWindowPoints(HWND_DESKTOP, Grid.Handle, Cur, 2);
    Result := EqualRect(Rect, Cur);
  end;

  procedure TInplaceEdit.InternalMove(const Loc: TRect; Redraw: Boolean);
  begin
    if IsRectEmpty(Loc) then
      Hide
    else
    begin
      CreateHandle;
      Redraw := Redraw or not IsWindowVisible(Handle);
      Invalidate;
      with Loc do
        SetWindowPos(Handle, HWND_TOP, Left, Top, Right - Left, Bottom - Top,
          SWP_SHOWWINDOW or SWP_NOREDRAW);
      BoundsChanged;
      if Redraw then
        Invalidate;
      if Grid.Focused then
        Windows.SetFocus(Handle);
    end;
  end;

  procedure TInplaceEdit.BoundsChanged;
  var
    R: TRect;
  begin
    R := Rect(2, 2, Width - 2, Height);
    SendStructMessage(Handle, EM_SETRECTNP, 0, R);
    SendMessage(Handle, EM_SCROLLCARET, 0, 0);
  end;

  procedure TInplaceEdit.UpdateLoc(const Loc: TRect);
  begin
    InternalMove(Loc, False);
  end;

  function TInplaceEdit.Visible: Boolean;
  begin
    Result := IsWindowVisible(Handle);
  end;

  procedure TInplaceEdit.Move(const Loc: TRect);
  begin
    InternalMove(Loc, True);
  end;

[UIPermission(SecurityAction.LinkDemand, Window = UIPermissionWindow.AllWindows)
  ]
  procedure TInplaceEdit.SetFocus;
  begin
    if IsWindowVisible(Handle) then
      Windows.SetFocus(Handle);
  end;

  procedure TInplaceEdit.UpdateContents;
  begin
    Text := '';
    EditMask := Grid.GetEditMask(Grid.Col, Grid.Row);
    Text := Grid.GetEditText(Grid.Col, Grid.Row);
    MaxLength := Grid.GetEditLimit;
  end;

{ TCustomGrid }

const
  GradientEndColorBase = $F0F0F0;

  constructor TCustomGrid.Create(AOwner: TComponent);
  const
    GridStyle = [csCaptureMouse, csOpaque, csDoubleClicks, csNeedsBorderPaint,
      csPannable, csGestures];
  begin
    inherited Create(AOwner);
    if NewStyleControls then
      ControlStyle := GridStyle
    else
      ControlStyle := GridStyle + [csFramed];
    FOddColor := Color;
    FCanEditModify := True;
    FColCount := 5;
    FRowCount := 5;
    FFixedCols := 1;
    FFixedRows := 1;
    FGridLineWidth := 1;
    FOptions := [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine,
      goRangeSelect];
    DesignOptionsBoost := [goColSizing, goRowSizing];
    FFixedColor := clBtnFace;
    FScrollBars := ssBoth;
    FBorderStyle := bsSingle;
    FDefaultColWidth := 64;
    FDefaultRowHeight := 24;
    FDefaultDrawing := True;
    FDrawingStyle := gdsThemed;
    FGradientEndColor := GetShadowColor(GradientEndColorBase, -25);
    FGradientStartColor := clWhite;
    FSaveCellExtents := True;
    FEditorMode := False;
    Color := clWindow;
    ParentColor := False;
    TabStop := True;
    SetBounds(Left, Top, FColCount * FDefaultColWidth,
      FRowCount * FDefaultRowHeight);
    FHotTrackCell.Coord.X := -1;
    FHotTrackCell.Coord.Y := -1;
    FHotTrackCell.Pressed := False;
    Touch.InteractiveGestures := [igPan, igPressAndTap];
    Touch.InteractiveGestureOptions := [igoPanInertia,
      igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanGutter,
      igoParentPassthrough];
    Initialize;
  end;

  destructor TCustomGrid.Destroy;
  begin
    FInplaceEdit.Free;
    FInplaceEdit := nil;
    inherited Destroy;
{$IF NOT DEFINED(CLR)}
    FreeMem(FColWidths);
    FreeMem(FRowHeights);
    FreeMem(FTabStops);
{$IFEND}
  end;

  procedure TCustomGrid.AdjustSize(Index, Amount: Longint; Rows: Boolean);
  var
    NewCur: TGridCoord;
    OldRows, OldCols: Longint;
    MovementX, MovementY: Longint;
    MoveRect: TGridRect;
    ScrollArea: TRect;
    AbsAmount: Longint;
{$IF DEFINED(CLR)}
    function DoSizeAdjust(var Count: Longint; var Extents: TIntegerDynArray;
      DefaultExtent: Integer; var Current: Longint): Longint;
{$ELSE}
      function DoSizeAdjust(var Count: Longint; var Extents: Pointer;
        DefaultExtent: Integer; var Current: Longint): Longint;
{$IFEND}
      var
        I: Integer;
        NewCount: Longint;
      begin
        NewCount := Count + Amount;
        if NewCount < Index then
          InvalidOp(STooManyDeleted);
        if (Amount < 0) and Assigned(Extents) then
        begin
          Result := 0;
          for I := Index to Index - Amount - 1 do
{$IF DEFINED(CLR)}
            Inc(Result, Extents[I]);
{$ELSE}
          Inc(Result, PIntArray(Extents)^[I]);
{$IFEND}
        end
        else
          Result := Amount * DefaultExtent;
        if Extents <> nil then
          ModifyExtents(Extents, Index, Amount, DefaultExtent);
        Count := NewCount;
        if Current >= Index then
          if (Amount < 0) and (Current < Index - Amount) then
            Current := Index
          else
            Inc(Current, Amount);
      end;

    begin
      if Amount = 0 then
        Exit;
      NewCur := FCurrent;
      OldCols := ColCount;
      OldRows := RowCount;
      MoveRect.Left := FixedCols;
      MoveRect.Right := ColCount - 1;
      MoveRect.Top := FixedRows;
      MoveRect.Bottom := RowCount - 1;
      MovementX := 0;
      MovementY := 0;
      AbsAmount := Amount;
      if AbsAmount < 0 then
        AbsAmount := -AbsAmount;
      if Rows then
      begin
        MovementY := DoSizeAdjust(FRowCount, FRowHeights, DefaultRowHeight,
          NewCur.Y);
        MoveRect.Top := Index;
        if Index + AbsAmount <= TopRow then
          MoveRect.Bottom := TopRow - 1;
      end
      else
      begin
        MovementX := DoSizeAdjust(FColCount, FColWidths, DefaultColWidth,
          NewCur.X);
        MoveRect.Left := Index;
        if Index + AbsAmount <= LeftCol then
          MoveRect.Right := LeftCol - 1;
      end;
      GridRectToScreenRect(MoveRect, ScrollArea, True);
      if not IsRectEmpty(ScrollArea) then
      begin
        ScrollWindow(Handle, MovementX, MovementY,
{$IFNDEF CLR}@{$ENDIF} ScrollArea, {$IFNDEF CLR}@{$ENDIF} ScrollArea);
        UpdateWindow(Handle);
      end;
      SizeChanged(OldCols, OldRows);
      if (NewCur.X <> FCurrent.X) or (NewCur.Y <> FCurrent.Y) then
        MoveCurrent(NewCur.X, NewCur.Y, True, True);
    end;

    function TCustomGrid.BoxRect(ALeft, ATop, ARight, ABottom: Longint): TRect;
    var
      GridRect: TGridRect;
    begin
      GridRect.Left := ALeft;
      GridRect.Right := ARight;
      GridRect.Top := ATop;
      GridRect.Bottom := ABottom;
      GridRectToScreenRect(GridRect, Result, False);
    end;

    procedure TCustomGrid.DoExit;
    begin
      inherited DoExit;
      if not(goAlwaysShowEditor in Options) then
        HideEditor;
    end;

    function TCustomGrid.CellRect(ACol, ARow: Longint): TRect;
    begin
      Result := BoxRect(ACol, ARow, ACol, ARow);
    end;

    function TCustomGrid.CanEditAcceptKey(Key: Char): Boolean;
    begin
      Result := True;
    end;

    function TCustomGrid.CanGridAcceptKey(Key: Word;
      Shift: TShiftState): Boolean;
    begin
      Result := True;
    end;

    function TCustomGrid.CanEditModify: Boolean;
    begin
      Result := FCanEditModify;
    end;

    function TCustomGrid.CanEditShow: Boolean;
    begin
      Result := ([goRowSelect, goEditing] * Options = [goEditing])
        and FEditorMode and not(csDesigning in ComponentState)
        and HandleAllocated and ((goAlwaysShowEditor in Options)
          or IsActiveControl);
    end;

    function TCustomGrid.IsActiveControl: Boolean;
    var
      H: HWnd;
      ParentForm: TCustomForm;
    begin
      Result := False;
      ParentForm := GetParentForm(Self);
      if Assigned(ParentForm) then
        Result := (ParentForm.ActiveControl = Self) and
          ((ParentForm = Screen.ActiveForm) or
            (ParentForm is TCustomActiveForm) or
            (ParentForm is TCustomDockForm))
      else
      begin
        H := GetFocus;
        while IsWindow(H) and not Result do
        begin
          if H = WindowHandle then
            Result := True
          else
            H := GetParent(H);
        end;
      end;
    end;

    function TCustomGrid.IsGradientEndColorStored: Boolean;
    begin
      Result := FGradientEndColor <> GetShadowColor(GradientEndColorBase, -25);
    end;

    function TCustomGrid.GetEditMask(ACol, ARow: Longint): string;
    begin
      Result := '';
    end;

    function TCustomGrid.GetEditText(ACol, ARow: Longint): string;
    begin
      Result := '';
    end;

    procedure TCustomGrid.SetEditText(ACol, ARow: Longint; const Value: string);
    begin
    end;

    function TCustomGrid.GetEditLimit: Integer;
    begin
      Result := 0;
    end;

    function TCustomGrid.GetEditStyle(ACol, ARow: Longint): TEditStyle;
    begin
      Result := esSimple;
    end;

    procedure TCustomGrid.HideEditor;
    begin
      FEditorMode := False;
      HideEdit;
    end;

    procedure TCustomGrid.ShowEditor;
    begin
      FEditorMode := True;
      UpdateEdit;
    end;

    procedure TCustomGrid.ShowEditorChar(Ch: Char);
    begin
      ShowEditor;
      if FInplaceEdit <> nil then
        PostMessage(FInplaceEdit.Handle, WM_CHAR, Ord(Ch), 0);
    end;

    procedure TCustomGrid.InvalidateEditor;
    begin
      FInplaceCol := -1;
      FInplaceRow := -1;
      UpdateEdit;
    end;

    procedure TCustomGrid.ReadColWidths(Reader: TReader);
    var
      I: Integer;
    begin
      with Reader do
      begin
        ReadListBegin;
        for I := 0 to ColCount - 1 do
          ColWidths[I] := ReadInteger;
        ReadListEnd;
      end;
    end;

    procedure TCustomGrid.ReadRowHeights(Reader: TReader);
    var
      I: Integer;
    begin
      with Reader do
      begin
        ReadListBegin;
        for I := 0 to RowCount - 1 do
          RowHeights[I] := ReadInteger;
        ReadListEnd;
      end;
    end;

    procedure TCustomGrid.WriteColWidths(Writer: TWriter);
    var
      I: Integer;
    begin
      with Writer do
      begin
        WriteListBegin;
        for I := 0 to ColCount - 1 do
          WriteInteger(ColWidths[I]);
        WriteListEnd;
      end;
    end;

    procedure TCustomGrid.WriteRowHeights(Writer: TWriter);
    var
      I: Integer;
    begin
      with Writer do
      begin
        WriteListBegin;
        for I := 0 to RowCount - 1 do
          WriteInteger(RowHeights[I]);
        WriteListEnd;
      end;
    end;

    procedure TCustomGrid.DefineProperties(Filer: TFiler);

      function DoColWidths: Boolean;
      begin
        if Filer.Ancestor <> nil then
          Result := not CompareExtents(TCustomGrid(Filer.Ancestor).FColWidths,
            FColWidths)
        else
{$IF DEFINED(CLR)}
          Result := Length(FColWidths) <> 0;
{$ELSE}
        Result := FColWidths <> nil;
{$IFEND}
      end;

      function DoRowHeights: Boolean;
      begin
        if Filer.Ancestor <> nil then
          Result := not CompareExtents(TCustomGrid(Filer.Ancestor).FRowHeights,
            FRowHeights)
        else
{$IF DEFINED(CLR)}
          Result := Length(FRowHeights) <> 0;
{$ELSE}
        Result := FRowHeights <> nil;
{$IFEND}
      end;

    begin
      inherited DefineProperties(Filer);
      if FSaveCellExtents then
        with Filer do
        begin
          DefineProperty('ColWidths', ReadColWidths, WriteColWidths,
            DoColWidths);
          DefineProperty('RowHeights', ReadRowHeights, WriteRowHeights,
            DoRowHeights);
        end;
    end;

    procedure TCustomGrid.MoveColumn(FromIndex, ToIndex: Longint);
    var
      Rect: TGridRect;
    begin
      if FromIndex = ToIndex then
        Exit;
{$IF DEFINED(CLR)}
      if Length(FColWidths) > 0 then
{$ELSE}
        if Assigned(FColWidths) then
{$IFEND}
        begin
          MoveExtent(FColWidths, FromIndex + 1, ToIndex + 1);
          MoveExtent(FTabStops, FromIndex + 1, ToIndex + 1);
        end;
      MoveAdjust(FCurrent.X, FromIndex, ToIndex);
      MoveAdjust(FAnchor.X, FromIndex, ToIndex);
      MoveAdjust(FInplaceCol, FromIndex, ToIndex);
      Rect.Top := 0;
      Rect.Bottom := VisibleRowCount;
      if FromIndex < ToIndex then
      begin
        Rect.Left := FromIndex;
        Rect.Right := ToIndex;
      end
      else
      begin
        Rect.Left := ToIndex;
        Rect.Right := FromIndex;
      end;
      InvalidateRect(Rect);
      ColumnMoved(FromIndex, ToIndex);
{$IF DEFINED(CLR)}
      if Length(FColWidths) <> 0 then
{$ELSE}
        if Assigned(FColWidths) then
{$IFEND}
          ColWidthsChanged;
      UpdateEdit;
    end;

    procedure TCustomGrid.ColumnMoved(FromIndex, ToIndex: Longint);
    begin
    end;

    procedure TCustomGrid.MoveRow(FromIndex, ToIndex: Longint);
    begin
{$IF DEFINED(CLR)}
      if Length(FRowHeights) <> 0 then
{$ELSE}
        if Assigned(FRowHeights) then
{$IFEND}
          MoveExtent(FRowHeights, FromIndex + 1, ToIndex + 1);
      MoveAdjust(FCurrent.Y, FromIndex, ToIndex);
      MoveAdjust(FAnchor.Y, FromIndex, ToIndex);
      MoveAdjust(FInplaceRow, FromIndex, ToIndex);
      RowMoved(FromIndex, ToIndex);
{$IF DEFINED(CLR)}
      if Length(FRowHeights) <> 0 then
{$ELSE}
        if Assigned(FRowHeights) then
{$IFEND}
          RowHeightsChanged;
      UpdateEdit;
    end;

    procedure TCustomGrid.RowMoved(FromIndex, ToIndex: Longint);
    begin
    end;

    function TCustomGrid.MouseCoord(X, Y: Integer): TGridCoord;
    var
      DrawInfo: TGridDrawInfo;
    begin
      CalcDrawInfo(DrawInfo);
      Result := CalcCoordFromPoint(X, Y, DrawInfo);
      if Result.X < 0 then
        Result.Y := -1
      else if Result.Y < 0 then
        Result.X := -1;
    end;

    procedure TCustomGrid.MoveColRow(ACol, ARow: Longint;
      MoveAnchor, Show: Boolean);
    begin
      MoveCurrent(ACol, ARow, MoveAnchor, Show);
    end;

    function TCustomGrid.SelectCell(ACol, ARow: Longint): Boolean;
    begin
      Result := True;
    end;

    procedure TCustomGrid.SizeChanged(OldColCount, OldRowCount: Longint);
    begin
    end;

    function TCustomGrid.Sizing(X, Y: Integer): Boolean;
    var
      DrawInfo: TGridDrawInfo;
      State: TGridState;
      Index: Longint;
      Pos, Ofs: Integer;
    begin
      State := FGridState;
      if State = gsNormal then
      begin
        CalcDrawInfo(DrawInfo);
        CalcSizingState(X, Y, State, Index, Pos, Ofs, DrawInfo);
      end;
      Result := State <> gsNormal;
    end;

    procedure TCustomGrid.TopLeftChanged;
    begin
      if FEditorMode and (FInplaceEdit <> nil) then
        FInplaceEdit.UpdateLoc(CellRect(Col, Row));
    end;
{$IF NOT DEFINED(CLR)}
    procedure FillDWord(var Dest; Count, Value: Integer); register;
asm
  XCHG  EDX, ECX
  PUSH  EDI
  MOV   EDI, EAX
  MOV   EAX, EDX
  REP   STOSD
  POP   EDI
end;
{$IFEND}
    { StackAlloc allocates a 'small' block of memory from the stack by
      decrementing SP.  This provides the allocation speed of a local variable,
      but the runtime size flexibility of heap allocated memory. }
{$IF NOT DEFINED(CLR)}
      function StackAlloc(Size: Integer): Pointer; register;
asm
  POP   ECX          { return address }
  MOV   EDX, ESP
  ADD   EAX, 3
  AND   EAX, not 3   // round up to keep ESP dword aligned
  CMP   EAX, 4092
  JLE   @@2
@@1:
  SUB   ESP, 4092
  PUSH  EAX          { make sure we touch guard page, to grow stack }
  SUB   EAX, 4096
  JNS   @@1
  ADD   EAX, 4096
@@2:
  SUB   ESP, EAX
  MOV   EAX, ESP     { function result = low memory address of block }
  PUSH  EDX          { save original SP, for cleanup }
  MOV   EDX, ESP
  SUB   EDX, 4
  PUSH  EDX          { save current SP, for sanity check  (sp = [sp]) }
  PUSH  ECX          { return to caller }
end;
{$IFEND}
      { StackFree pops the memory allocated by StackAlloc off the stack.
        - Calling StackFree is optional - SP will be restored when the calling routine
        exits, but it's a good idea to free the stack allocated memory ASAP anyway.
        - StackFree must be called in the same stack context as StackAlloc - not in
        a subroutine or finally block.
        - Multiple StackFree calls must occur in reverse order of their corresponding
        StackAlloc calls.
        - Built-in sanity checks guarantee that an improper call to StackFree will not
        corrupt the stack. Worst case is that the stack block is not released until
        the calling routine exits. }
{$IF NOT DEFINED(CLR)}
        procedure StackFree(P: Pointer); register;
asm
  POP   ECX                     { return address }
  MOV   EDX, DWORD PTR [ESP]
  SUB   EAX, 8
  CMP   EDX, ESP                { sanity check #1 (SP = [SP]) }
  JNE   @@1
  CMP   EDX, EAX                { sanity check #2 (P = this stack block) }
  JNE   @@1
  MOV   ESP, DWORD PTR [ESP+4]  { restore previous SP }
@@1:
  PUSH  ECX                     { return to caller }
end;
{$IFEND}
          procedure TCustomGrid.Paint;
          var
            LColorRef: TColorRef;
            LineColor: TColor;
            LFixedColor: TColor;
            LFixedBorderColor: TColor;
            DrawInfo: TGridDrawInfo;
            Sel: TGridRect;
            UpdateRect: TRect;
            AFocRect, FocRect: TRect;
{$IF DEFINED(CLR)}
            PointsList: array of TPoint;
            StrokeList: array of DWORD;
            I: Integer;
{$ELSE}
            PointsList: PIntArray;
            StrokeList: PIntArray;
{$IFEND}
            MaxStroke: Integer;
            FrameFlags1, FrameFlags2: DWORD;

            procedure DrawLines(DoHorz, DoVert: Boolean; Col, Row: Longint;
              const CellBounds: array of Integer; OnColor, OffColor: TColor);

            { Cellbounds is 4 integers: StartX, StartY, StopX, StopY
              Horizontal lines:  MajorIndex = 0
              Vertical lines:    MajorIndex = 1 }

            const
              FlatPenStyle =
                PS_Geometric or PS_Solid or PS_EndCap_Flat or PS_Join_Miter;

              procedure DrawAxisLines(const AxisInfo: TGridAxisDrawInfo;
                Cell, MajorIndex: Integer; UseOnColor: Boolean);
              var
                Line: Integer;
                LogBrush: TLOGBRUSH;
                Index: Integer;
{$IF DEFINED(CLR)}
                Points: array of TPoint;
{$ELSE}
                Points: PIntArray;
{$IFEND}
                StopMajor, StartMinor, StopMinor, StopIndex: Integer;
                LineIncr: Integer;
              begin
                with Canvas, AxisInfo do
                begin
                  if EffectiveLineWidth <> 0 then
                  begin
                    Pen.Width := GridLineWidth;
                    if UseOnColor then
                      Pen.Color := OnColor
                    else
                      Pen.Color := OffColor;
                    if Pen.Width > 1 then
                    begin
                      LogBrush.lbStyle := BS_Solid;
                      LogBrush.lbColor := Pen.Color;
                      LogBrush.lbHatch := 0;
                      Pen.Handle := ExtCreatePen(FlatPenStyle, Pen.Width,
                        LogBrush, 0, nil);
                    end;
                    Points := PointsList;
                    Line := CellBounds[MajorIndex] + (EffectiveLineWidth shr 1)
                      + AxisInfo.GetExtent(Cell);
                    // !!! ??? Line needs to be incremented for RightToLeftAlignment ???
                    if UseRightToLeftAlignment and (MajorIndex = 0) then
                      Inc(Line);
                    StartMinor := CellBounds[MajorIndex xor 1];
                    StopMinor := CellBounds[2 + (MajorIndex xor 1)];
                    StopMajor := CellBounds[2 + MajorIndex]
                      + EffectiveLineWidth;
{$IF DEFINED(CLR)}
                    StopIndex := MaxStroke * 2;
{$ELSE}
                    StopIndex := MaxStroke * 4;
{$IFEND}
                    Index := 0;
                    repeat
{$IF DEFINED(CLR)}
                      if MajorIndex <> 0 then
                      begin
                        Points[Index].Y := Line;
                        Points[Index].X := StartMinor;
                      end
                      else
                      begin
                        Points[Index].X := Line;
                        Points[Index].Y := StartMinor;
                      end;
                      Inc(Index);
                      if MajorIndex <> 0 then
                      begin
                        Points[Index].Y := Line;
                        Points[Index].X := StopMinor;
                      end
                      else
                      begin
                        Points[Index].X := Line;
                        Points[Index].Y := StopMinor;
                      end;
                      Inc(Index);
{$ELSE}
                      Points^[Index + MajorIndex] := Line; { MoveTo }
                      Points^[Index + (MajorIndex xor 1)] := StartMinor;
                      Inc(Index, 2);
                      Points^[Index + MajorIndex] := Line; { LineTo }
                      Points^[Index + (MajorIndex xor 1)] := StopMinor;
                      Inc(Index, 2);
{$IFEND}
                      // Skip hidden columns/rows.  We don't have stroke slots for them
                      // A column/row with an extent of -EffectiveLineWidth is hidden
                      repeat
                        Inc(Cell);
                        LineIncr := AxisInfo.GetExtent(Cell)
                          + EffectiveLineWidth;
                      until (LineIncr > 0) or (Cell > LastFullVisibleCell);
                      Inc(Line, LineIncr);
                    until (Line > StopMajor) or (Cell > LastFullVisibleCell) or
                      (Index > StopIndex);
{$IF DEFINED(CLR)}
                    { 2 points per line -> Index div 2 }
                    PolyPolyLine(Canvas.Handle, Points, StrokeList,
                      Index shr 1);
{$ELSE}
                    { 2 integers per point, 2 points per line -> Index div 4 }
                    PolyPolyLine(Canvas.Handle, Points^, StrokeList^,
                      Index shr 2);
{$IFEND}
                  end;
                end;
              end;

            begin
              if (CellBounds[0] = CellBounds[2]) or
                (CellBounds[1] = CellBounds[3]) then
                Exit;
              if not DoHorz then
              begin
                DrawAxisLines(DrawInfo.Vert, Row, 1, DoHorz);
                DrawAxisLines(DrawInfo.Horz, Col, 0, DoVert);
              end
              else
              begin
                DrawAxisLines(DrawInfo.Horz, Col, 0, DoVert);
                DrawAxisLines(DrawInfo.Vert, Row, 1, DoHorz);
              end;
            end;

            procedure DrawCells(ACol, ARow: Longint;
              StartX, StartY, StopX, StopY: Integer; AColor: TColor;
              IncludeDrawState: TGridDrawState);
            var
              CurCol, CurRow: Longint;
              AWhere, Where, TempRect: TRect;
              DrawState: TGridDrawState;
              Focused: Boolean;
            begin
              CurRow := ARow;
              Where.Top := StartY;
              while (Where.Top < StopY) and (CurRow < RowCount) do
              begin
                CurCol := ACol;
                Where.Left := StartX;
                Where.Bottom := Where.Top + RowHeights[CurRow];
                while (Where.Left < StopX) and (CurCol < ColCount) do
                begin
                  Where.Right := Where.Left + ColWidths[CurCol];
                  if (Where.Right > Where.Left) and RectVisible(Canvas.Handle,
                    Where) then
                  begin
                    DrawState := IncludeDrawState;
                    if (CurCol = FHotTrackCell.Coord.X) and
                      (CurRow = FHotTrackCell.Coord.Y) then
                    begin
                      if (goFixedHotTrack in Options) then
                        Include(DrawState, gdHotTrack);
                      if FHotTrackCell.Pressed then
                        Include(DrawState, gdPressed);
                    end;
                    Focused := IsActiveControl;
                    if Focused and (CurRow = Row) and (CurCol = Col) then
                    begin
                      SetCaretPos(Where.Left, Where.Top);
                      Include(DrawState, gdFocused);
                    end;
                    if PointInGridRect(CurCol, CurRow, Sel) then
                      Include(DrawState, gdSelected);
                    if not(gdFocused in DrawState) or not(goEditing in Options)
                      or not FEditorMode or (csDesigning in ComponentState) then
                    begin
                      if DefaultDrawing or (csDesigning in ComponentState) then
                      begin
                        Canvas.Font := Self.Font;
                        if ((gdSelected in DrawState) or (curRow = Row) and RowHighlight) and
                          ({not(gdFocused in DrawState) or}
                            ([goDrawFocusSelected,
                            goRowSelect] * Options <> []) or RowHighlight) then
                          DrawCellHighlight(Where, DrawState, CurCol, CurRow)
                        else
                          if CurRow mod 2 = 0 then
                            DrawCellBackground(Where, OddColor, DrawState, CurCol,
                              CurRow)
                          else
                            DrawCellBackground(Where, AColor, DrawState, CurCol,
                              CurRow);
                      end;
                      AWhere := Where;
                      if (gdPressed in DrawState) then
                      begin
                        Inc(AWhere.Top);
                        Inc(AWhere.Left);
                      end;
                      DrawCell(CurCol, CurRow, AWhere, DrawState);
                      if DefaultDrawing and (gdFixed in DrawState)
                        and Ctl3D and ((FrameFlags1 or FrameFlags2) <> 0)
                        and (FInternalDrawingStyle = gdsClassic) and not
                        (gdPressed in DrawState) then
                      begin
                        TempRect := Where;
                        if (FrameFlags1 and BF_RIGHT) = 0 then
                          Inc(TempRect.Right, DrawInfo.Horz.EffectiveLineWidth)
                        else if (FrameFlags1 and BF_BOTTOM) = 0 then
                          Inc(TempRect.Bottom,
                            DrawInfo.Vert.EffectiveLineWidth);
                        DrawEdge(Canvas.Handle, TempRect, BDR_RAISEDINNER,
                          FrameFlags1);
                        DrawEdge(Canvas.Handle, TempRect, BDR_RAISEDINNER,
                          FrameFlags2);
                      end;

                      if DefaultDrawing and not(csDesigning in ComponentState)
                        and (gdFocused in DrawState) and ([goEditing,
                        goAlwaysShowEditor] * Options <> [goEditing,
                        goAlwaysShowEditor]) and not(goRowSelect in Options)
                        then
                      begin
                        TempRect := Where;
                        if (FInternalDrawingStyle = gdsThemed) and
                          (Win32MajorVersion >= 6) then
                          InflateRect(TempRect, -1, -1);
                        Canvas.Brush.Style := bsSolid;
                        if not UseRightToLeftAlignment then
                          DrawFocusRect(Canvas.Handle, TempRect)
                        else
                        begin
                          AWhere := TempRect;
                          AWhere.Left := TempRect.Right;
                          AWhere.Right := TempRect.Left;
                          DrawFocusRect(Canvas.Handle, AWhere);
                        end;
                      end;
                    end;
                  end;
                  Where.Left := Where.Right + DrawInfo.Horz.EffectiveLineWidth;
                  Inc(CurCol);
                end;
                Where.Top := Where.Bottom + DrawInfo.Vert.EffectiveLineWidth;
                Inc(CurRow);
              end;
            end;

          begin
            if UseRightToLeftAlignment then
              ChangeGridOrientation(True);

            if (FInternalDrawingStyle = gdsThemed) then
            begin
              if Win32MajorVersion >= 6 then
              begin
                LineColor := $F0F0F0;
                GetThemeColor(ThemeServices.Theme[teHeader], HP_HEADERITEM,
                  HIS_NORMAL, TMT_EDGEFILLCOLOR, LColorRef);
                LFixedBorderColor := LColorRef;
              end
              else
              begin
                LineColor := $D8E9EC;
                LFixedBorderColor := $B8C7CB;
              end;
              GetThemeColor(ThemeServices.Theme[teListView], LVP_LISTITEM,
                LIS_NORMAL, TMT_FILLCOLOR, LColorRef);
              FInternalColor := LColorRef;
              LFixedColor := FInternalColor;
            end
            else
            begin
              FInternalColor := Color;
              if FInternalDrawingStyle = gdsGradient then
              begin
                LineColor := $F0F0F0;
                LFixedColor := Color;
                LFixedBorderColor := GetShadowColor($F0F0F0, -45);
              end
              else
              begin
                LineColor := clSilver;
                LFixedColor := FixedColor;
                LFixedBorderColor := clBlack;
              end;
            end;
            UpdateRect := Canvas.ClipRect;
            CalcDrawInfo(DrawInfo);
            with DrawInfo do
            begin
              if (Horz.EffectiveLineWidth > 0) or (Vert.EffectiveLineWidth > 0)
                then
              begin
                { Draw the grid line in the four areas (fixed, fixed), (variable, fixed),
                  (fixed, variable) and (variable, variable) }
                MaxStroke := Max
                  (Horz.LastFullVisibleCell - LeftCol + FixedCols,
                  Vert.LastFullVisibleCell - TopRow + FixedRows) + 3;
{$IF DEFINED(CLR)}
                SetLength(PointsList, MaxStroke * 2); // two points per stroke
                SetLength(StrokeList, MaxStroke);
                for I := 0 to MaxStroke - 1 do
                  StrokeList[I] := 2;
{$ELSE}
                PointsList := StackAlloc(MaxStroke * SizeOf(TPoint) * 2);
                StrokeList := StackAlloc(MaxStroke * SizeOf(Integer));
                FillDWord(StrokeList^, MaxStroke, 2);
{$IFEND}
                if ColorToRGB(FInternalColor) = clSilver then
                  LineColor := clGray;
                DrawLines(goFixedHorzLine in Options,
                  goFixedVertLine in Options, 0, 0,
                  [0, 0, Horz.FixedBoundary, Vert.FixedBoundary],
                  LFixedBorderColor, LFixedColor);
                DrawLines(goFixedHorzLine in Options,
                  goFixedVertLine in Options, LeftCol, 0,
                  [Horz.FixedBoundary, 0, Horz.GridBoundary,
                  Vert.FixedBoundary], LFixedBorderColor,
                  LFixedColor);
                DrawLines(goFixedHorzLine in Options,
                  goFixedVertLine in Options, 0, TopRow,
                  [0, Vert.FixedBoundary, Horz.FixedBoundary,
                  Vert.GridBoundary], LFixedBorderColor,
                  LFixedColor);
                DrawLines(goHorzLine in Options, goVertLine in Options,
                  LeftCol, TopRow, [Horz.FixedBoundary, Vert.FixedBoundary,
                  Horz.GridBoundary, Vert.GridBoundary], LineColor,
                  FInternalColor);
{$IF DEFINED(CLR)}
                SetLength(StrokeList, 0);
                SetLength(PointsList, 0);
{$ELSE}
                StackFree(StrokeList);
                StackFree(PointsList);
{$IFEND}
              end;

              { Draw the cells in the four areas }
              Sel := Selection;
              FrameFlags1 := 0;
              FrameFlags2 := 0;
              if goFixedVertLine in Options then
              begin
                FrameFlags1 := BF_RIGHT;
                FrameFlags2 := BF_LEFT;
              end;
              if goFixedHorzLine in Options then
              begin
                FrameFlags1 := FrameFlags1 or BF_BOTTOM;
                FrameFlags2 := FrameFlags2 or BF_TOP;
              end;
              DrawCells(0, 0, 0, 0, Horz.FixedBoundary, Vert.FixedBoundary,
                LFixedColor, [gdFixed]);
              DrawCells(LeftCol, 0, Horz.FixedBoundary - FColOffset, 0,
                Horz.GridBoundary, // !! clip
                Vert.FixedBoundary, LFixedColor, [gdFixed]);
              DrawCells(0, TopRow, 0, Vert.FixedBoundary, Horz.FixedBoundary,
                Vert.GridBoundary, LFixedColor, [gdFixed]);
              DrawCells(LeftCol, TopRow, Horz.FixedBoundary - FColOffset,
                // !! clip
                Vert.FixedBoundary, Horz.GridBoundary, Vert.GridBoundary,
                FInternalColor, []);

              if not(csDesigning in ComponentState) and
                (goRowSelect in Options) and DefaultDrawing and Focused then
              begin
                GridRectToScreenRect(GetSelection, FocRect, False);
                Canvas.Brush.Style := bsSolid;
                if (FInternalDrawingStyle = gdsThemed) and
                  (Win32MajorVersion >= 6) then
                  InflateRect(FocRect, -1, -1);
                AFocRect := FocRect;
                if not UseRightToLeftAlignment then
                  Canvas.DrawFocusRect(AFocRect)
                else
                begin
                  AFocRect := FocRect;
                  AFocRect.Left := FocRect.Right;
                  AFocRect.Right := FocRect.Left;
                  DrawFocusRect(Canvas.Handle, AFocRect);
                end;
              end;

              { Fill in area not occupied by cells }
              if Horz.GridBoundary < Horz.GridExtent then
              begin
                Canvas.Brush.Color := FInternalColor;
                Canvas.FillRect(Rect(Horz.GridBoundary, 0, Horz.GridExtent,
                    Vert.GridBoundary));
              end;
              if Vert.GridBoundary < Vert.GridExtent then
              begin
                Canvas.Brush.Color := FInternalColor;
                Canvas.FillRect(Rect(0, Vert.GridBoundary, Horz.GridExtent,
                    Vert.GridExtent));
              end;
            end;

            if UseRightToLeftAlignment then
              ChangeGridOrientation(False);
          end;

          function TCustomGrid.CalcCoordFromPoint(X, Y: Integer;
            const DrawInfo: TGridDrawInfo): TGridCoord;

            function DoCalc(const AxisInfo: TGridAxisDrawInfo;
              N: Integer): Integer;
            var
              I, Start, Stop: Longint;
              Line: Integer;
            begin
              with AxisInfo do
              begin
                if N < FixedBoundary then
                begin
                  Start := 0;
                  Stop := FixedCellCount - 1;
                  Line := 0;
                end
                else
                begin
                  Start := FirstGridCell;
                  Stop := GridCellCount - 1;
                  Line := FixedBoundary;
                end;
                Result := -1;
                for I := Start to Stop do
                begin
                  Inc(Line, AxisInfo.GetExtent(I) + EffectiveLineWidth);
                  if N < Line then
                  begin
                    Result := I;
                    Exit;
                  end;
                end;
              end;
            end;

            function DoCalcRightToLeft(const AxisInfo: TGridAxisDrawInfo;
              N: Integer): Integer;
            var
              I, Start, Stop: Longint;
              Line: Integer;
            begin
              N := ClientWidth - N;
              with AxisInfo do
              begin
                if N < FixedBoundary then
                begin
                  Start := 0;
                  Stop := FixedCellCount - 1;
                  Line := ClientWidth;
                end
                else
                begin
                  Start := FirstGridCell;
                  Stop := GridCellCount - 1;
                  Line := FixedBoundary;
                end;
                Result := -1;
                for I := Start to Stop do
                begin
                  Inc(Line, AxisInfo.GetExtent(I) + EffectiveLineWidth);
                  if N < Line then
                  begin
                    Result := I;
                    Exit;
                  end;
                end;
              end;
            end;

          begin
            if not UseRightToLeftAlignment then
              Result.X := DoCalc(DrawInfo.Horz, X)
            else
              Result.X := DoCalcRightToLeft(DrawInfo.Horz, X);
            Result.Y := DoCalc(DrawInfo.Vert, Y);
          end;

          procedure TCustomGrid.CalcDrawInfo(var DrawInfo: TGridDrawInfo);
          begin
            CalcDrawInfoXY(DrawInfo, ClientWidth, ClientHeight);
          end;

          procedure TCustomGrid.CalcDrawInfoXY(var DrawInfo: TGridDrawInfo;
            UseWidth, UseHeight: Integer);

            procedure CalcAxis(var AxisInfo: TGridAxisDrawInfo;
              UseExtent: Integer);
            var
              I: Integer;
            begin
              with AxisInfo do
              begin
                GridExtent := UseExtent;
                GridBoundary := FixedBoundary;
                FullVisBoundary := FixedBoundary;
                LastFullVisibleCell := FirstGridCell;
                for I := FirstGridCell to GridCellCount - 1 do
                begin
                  Inc(GridBoundary, AxisInfo.GetExtent(I) + EffectiveLineWidth);
                  if GridBoundary > GridExtent + EffectiveLineWidth then
                  begin
                    GridBoundary := GridExtent;
                    Break;
                  end;
                  LastFullVisibleCell := I;
                  FullVisBoundary := GridBoundary;
                end;
              end;
            end;

          begin
            CalcFixedInfo(DrawInfo);
            CalcAxis(DrawInfo.Horz, UseWidth);
            CalcAxis(DrawInfo.Vert, UseHeight);
          end;

          procedure TCustomGrid.CalcFixedInfo(var DrawInfo: TGridDrawInfo);

            procedure CalcFixedAxis(var Axis: TGridAxisDrawInfo;
              LineOptions: TGridOptions;
              FixedCount, FirstCell, CellCount: Integer;
              GetExtentFunc: TGetExtentsFunc);
            var
              I: Integer;
            begin
              with Axis do
              begin
                if LineOptions * Options = [] then
                  EffectiveLineWidth := 0
                else
                  EffectiveLineWidth := GridLineWidth;

                FixedBoundary := 0;
                for I := 0 to FixedCount - 1 do
                  Inc(FixedBoundary, GetExtentFunc(I) + EffectiveLineWidth);

                FixedCellCount := FixedCount;
                FirstGridCell := FirstCell;
                GridCellCount := CellCount;
                GetExtent := GetExtentFunc;
              end;
            end;

          begin
            CalcFixedAxis(DrawInfo.Horz, [goFixedVertLine, goVertLine],
              FixedCols, LeftCol, ColCount, GetColWidths);
            CalcFixedAxis(DrawInfo.Vert, [goFixedHorzLine, goHorzLine],
              FixedRows, TopRow, RowCount, GetRowHeights);
          end;

        { Calculates the TopLeft that will put the given Coord in view }
          function TCustomGrid.CalcMaxTopLeft(const Coord: TGridCoord;
            const DrawInfo: TGridDrawInfo): TGridCoord;

            function CalcMaxCell(const Axis: TGridAxisDrawInfo;
              Start: Integer): Integer;
            var
              Line: Integer;
              I, Extent: Longint;
            begin
              Result := Start;
              with Axis do
              begin
                Line := GridExtent + EffectiveLineWidth;
                for I := Start downto FixedCellCount do
                begin
                  Extent := GetExtent(I);
                  if Extent > 0 then
                  begin
                    Dec(Line, Extent);
                    Dec(Line, EffectiveLineWidth);
                    if Line < FixedBoundary then
                    begin
                      if (Result = Start) and (GetExtent(Start) <= 0) then
                        Result := I;
                      Break;
                    end;
                    Result := I;
                  end;
                end;
              end;
            end;

          begin
            Result.X := CalcMaxCell(DrawInfo.Horz, Coord.X);
            Result.Y := CalcMaxCell(DrawInfo.Vert, Coord.Y);
          end;

          procedure TCustomGrid.CalcSizingState(X, Y: Integer;
            var State: TGridState; var Index: Longint;
            var SizingPos, SizingOfs: Integer;
            var FixedInfo: TGridDrawInfo);

            procedure CalcAxisState(const AxisInfo: TGridAxisDrawInfo;
              Pos: Integer; NewState: TGridState);
            var
              I, Line, Back, Range: Integer;
            begin
              if (NewState = gsColSizing) and UseRightToLeftAlignment then
                Pos := ClientWidth - Pos;
              with AxisInfo do
              begin
                Line := FixedBoundary;
                Range := EffectiveLineWidth;
                Back := 0;
                if Range < 7 then
                begin
                  Range := 7;
                  Back := (Range - EffectiveLineWidth) shr 1;
                end;
                for I := FirstGridCell to GridCellCount - 1 do
                begin
                  Inc(Line, AxisInfo.GetExtent(I));
                  if Line > GridBoundary then
                    Break;
                  if (Pos >= Line - Back) and (Pos <= Line - Back + Range) then
                  begin
                    State := NewState;
                    SizingPos := Line;
                    SizingOfs := Line - Pos;
                    Index := I;
                    Exit;
                  end;
                  Inc(Line, EffectiveLineWidth);
                end;
                if (GridBoundary = GridExtent) and (Pos >= GridExtent - Back)
                  and (Pos <= GridExtent) then
                begin
                  State := NewState;
                  SizingPos := GridExtent;
                  SizingOfs := GridExtent - Pos;
                  Index := LastFullVisibleCell + 1;
                end;
              end;
            end;

            function XOutsideHorzFixedBoundary: Boolean;
            begin
              with FixedInfo do
                if not UseRightToLeftAlignment then
                  Result := X > Horz.FixedBoundary
                else
                  Result := X < ClientWidth - Horz.FixedBoundary;
            end;

            function XOutsideOrEqualHorzFixedBoundary: Boolean;
            begin
              with FixedInfo do
                if not UseRightToLeftAlignment then
                  Result := X >= Horz.FixedBoundary
                else
                  Result := X <= ClientWidth - Horz.FixedBoundary;
            end;

          var
            EffectiveOptions: TGridOptions;
          begin
            State := gsNormal;
            Index := -1;
            EffectiveOptions := Options;
            if csDesigning in ComponentState then
              EffectiveOptions := EffectiveOptions + DesignOptionsBoost;
            if [goColSizing, goRowSizing] * EffectiveOptions <> [] then
              with FixedInfo do
              begin
                Vert.GridExtent := ClientHeight;
                Horz.GridExtent := ClientWidth;
                if (XOutsideHorzFixedBoundary) and
                  (goColSizing in EffectiveOptions) then
                begin
                  if Y >= Vert.FixedBoundary then
                    Exit;
                  CalcAxisState(Horz, X, gsColSizing);
                end
                else if (Y > Vert.FixedBoundary) and
                  (goRowSizing in EffectiveOptions) then
                begin
                  if XOutsideOrEqualHorzFixedBoundary then
                    Exit;
                  CalcAxisState(Vert, Y, gsRowSizing);
                end;
              end;
          end;

          procedure TCustomGrid.ChangeGridOrientation
            (RightToLeftOrientation: Boolean);
          var
            Org: TPoint;
            Ext: TPoint;
          begin
            if RightToLeftOrientation then
            begin
              Org := Point(ClientWidth, 0);
              Ext := Point(-1, 1);
              SetMapMode(Canvas.Handle, mm_Anisotropic);
              SetWindowOrgEx(Canvas.Handle, Org.X, Org.Y, nil);
              SetViewportExtEx(Canvas.Handle, ClientWidth, ClientHeight, nil);
              SetWindowExtEx(Canvas.Handle, Ext.X * ClientWidth,
                Ext.Y * ClientHeight, nil);
            end
            else
            begin
              Org := Point(0, 0);
              Ext := Point(1, 1);
              SetMapMode(Canvas.Handle, mm_Anisotropic);
              SetWindowOrgEx(Canvas.Handle, Org.X, Org.Y, nil);
              SetViewportExtEx(Canvas.Handle, ClientWidth, ClientHeight, nil);
              SetWindowExtEx(Canvas.Handle, Ext.X * ClientWidth,
                Ext.Y * ClientHeight, nil);
            end;
          end;

          procedure TCustomGrid.ChangeSize(NewColCount, NewRowCount: Longint);
          var
            OldColCount, OldRowCount: Longint;
            OldDrawInfo: TGridDrawInfo;

            procedure MinRedraw(const OldInfo, NewInfo: TGridAxisDrawInfo;
              Axis: Integer);
            var
              R: TRect;
              First: Integer;
            begin
              First := Min(OldInfo.LastFullVisibleCell,
                NewInfo.LastFullVisibleCell);
              // Get the rectangle around the leftmost or topmost cell in the target range.
              R := CellRect(First and not Axis, First and Axis);
              R.Bottom := Height;
              R.Right := Width;
              Windows.InvalidateRect(Handle, R, False);
            end;

            procedure DoChange;
            var
              Coord: TGridCoord;
              NewDrawInfo: TGridDrawInfo;
            begin
{$IF DEFINED(CLR)}
              if Length(FColWidths) <> 0 then
                UpdateExtents(FColWidths, ColCount, DefaultColWidth);
              if Length(FTabStops) <> 0 then
                UpdateExtents(FTabStops, ColCount, Integer(True));
              if Length(FRowHeights) <> 0 then
                UpdateExtents(FRowHeights, RowCount, DefaultRowHeight);
{$ELSE}
              if FColWidths <> nil then
                UpdateExtents(FColWidths, ColCount, DefaultColWidth);
              if FTabStops <> nil then
                UpdateExtents(FTabStops, ColCount, Integer(True));
              if FRowHeights <> nil then
                UpdateExtents(FRowHeights, RowCount, DefaultRowHeight);
{$IFEND}
              Coord := FCurrent;
              if Row >= RowCount then
                Coord.Y := RowCount - 1;
              if Col >= ColCount then
                Coord.X := ColCount - 1;
              if (FCurrent.X <> Coord.X) or (FCurrent.Y <> Coord.Y) then
                MoveCurrent(Coord.X, Coord.Y, True, True);
              if (FAnchor.X <> Coord.X) or (FAnchor.Y <> Coord.Y) then
                MoveAnchor(Coord);
              if VirtualView or (LeftCol <> OldDrawInfo.Horz.FirstGridCell) or
                (TopRow <> OldDrawInfo.Vert.FirstGridCell) then
                InvalidateGrid
              else if HandleAllocated then
              begin
                CalcDrawInfo(NewDrawInfo);
                MinRedraw(OldDrawInfo.Horz, NewDrawInfo.Horz, 0);
                MinRedraw(OldDrawInfo.Vert, NewDrawInfo.Vert, -1);
              end;
              UpdateScrollRange;
              SizeChanged(OldColCount, OldRowCount);
            end;

          begin
            if HandleAllocated then
              CalcDrawInfo(OldDrawInfo);
            OldColCount := FColCount;
            OldRowCount := FRowCount;
            FColCount := NewColCount;
            FRowCount := NewRowCount;
            if FixedCols > NewColCount then
              FFixedCols := NewColCount - 1;
            if FixedRows > NewRowCount then
              FFixedRows := NewRowCount - 1;
            try
              DoChange;
            except
              { Could not change size so try to clean up by setting the size back }
              FColCount := OldColCount;
              FRowCount := OldRowCount;
              DoChange;
              InvalidateGrid;
              raise ;
            end;
          end;

        { Will move TopLeft so that Coord is in view }
          procedure TCustomGrid.ClampInView(const Coord: TGridCoord);
          var
            DrawInfo: TGridDrawInfo;
            MaxTopLeft: TGridCoord;
            OldTopLeft: TGridCoord;
          begin
            if not HandleAllocated then
              Exit;
            CalcDrawInfo(DrawInfo);
            with DrawInfo, Coord do
            begin
              if (X > Horz.LastFullVisibleCell) or
                (Y > Vert.LastFullVisibleCell) or
                (X < LeftCol) or (Y < TopRow) then
              begin
                OldTopLeft := FTopLeft;
                MaxTopLeft := CalcMaxTopLeft(Coord, DrawInfo);
                Update;
                if X < LeftCol then
                  FTopLeft.X := X
                else if X > Horz.LastFullVisibleCell then
                  FTopLeft.X := MaxTopLeft.X;
                if Y < TopRow then
                  FTopLeft.Y := Y
                else if Y > Vert.LastFullVisibleCell then
                  FTopLeft.Y := MaxTopLeft.Y;
                TopLeftMoved(OldTopLeft);
              end;
            end;
          end;

          procedure TCustomGrid.DrawSizingLine(const DrawInfo: TGridDrawInfo);
          var
            OldPen: TPen;
          begin
            OldPen := TPen.Create;
            try
              with Canvas, DrawInfo do
              begin
                OldPen.Assign(Pen);
                Pen.Style := psDot;
                Pen.Mode := pmXor;
                Pen.Width := 1;
                try
                  if FGridState = gsRowSizing then
                  begin
                    if UseRightToLeftAlignment then
                    begin
                      MoveTo(Horz.GridExtent, FSizingPos);
                      LineTo(Horz.GridExtent - Horz.GridBoundary, FSizingPos);
                    end
                    else
                    begin
                      MoveTo(0, FSizingPos);
                      LineTo(Horz.GridBoundary, FSizingPos);
                    end;
                  end
                  else
                  begin
                    MoveTo(FSizingPos, 0);
                    LineTo(FSizingPos, Vert.GridBoundary);
                  end;
                finally
                  Pen := OldPen;
                end;
              end;
            finally
              OldPen.Free;
            end;
          end;

          procedure TCustomGrid.DrawCellHighlight(const ARect: TRect;
            AState: TGridDrawState; ACol, ARow: Integer);
          var
            LRect: TRect;
            LTheme: HTHEME;
            LColor: TColorRef;
          begin
            if (goRowSelect in Options) or RowHighlight then
              Include(AState, gdRowSelected);
            if (FInternalDrawingStyle = gdsThemed) and (Win32MajorVersion >= 6)
              then
            begin
              Canvas.Brush.Style := bsSolid;
              Canvas.FillRect(ARect);
              LTheme := ThemeServices.Theme[teMenu];
              LRect := ARect;
              if (gdRowSelected in AState) then
              begin
                if (ACol >= FixedCols + 1) and (ACol < ColCount - 1) then
                  InflateRect(LRect, 4, 0)
                else if ACol = FixedCols then
                  Inc(LRect.Right, 4)
                else if ACol = (ColCount - 1) then
                  Dec(LRect.Left, 4);
              end;
              DrawThemeBackground(LTheme, Canvas.Handle, MENU_POPUPITEM,
                MPI_HOT, LRect, {$IFNDEF CLR}@{$ENDIF} ARect);
              GetThemeColor(LTheme, MENU_POPUPITEM, MPI_HOT, TMT_TEXTCOLOR,
                LColor);
              Canvas.Font.Color := LColor;
              Canvas.Brush.Style := bsClear;
            end
            else
            begin
              if FInternalDrawingStyle = gdsGradient then
              begin
                LRect := ARect;
                Canvas.Brush.Color := clHighlight;
                Canvas.FrameRect(LRect);
                if (gdRowSelected in AState) then
                begin
                  InflateRect(LRect, 0, -1);
                  if (ACol >= FixedCols + 1) and (ACol < ColCount - 1) then
                    InflateRect(LRect, 2, 0)
                  else if ACol = FixedCols then
                    Inc(LRect.Left)
                  else if ACol = (ColCount - 1) then
                    Dec(LRect.Right);
                end
                else
                  InflateRect(LRect, -1, -1);
                GradientFillCanvas(Canvas, GetShadowColor(clHighlight, 45),
                  GetShadowColor(clHighlight, 10), LRect, gdVertical);
                Canvas.Font.Color := clHighlightText;
                Canvas.Brush.Style := bsClear;
              end
              else
              begin
                Canvas.Brush.Color := clHighlight;
                Canvas.Font.Color := clHighlightText;
                Canvas.FillRect(ARect);
              end;
            end;
          end;

          procedure TCustomGrid.DrawCellBackground(const ARect: TRect;
            AColor: TColor; AState: TGridDrawState; ACol, ARow: Integer);
          const
            States: array [Boolean, Boolean] of Cardinal =
              ((HIS_NORMAL, HIS_PRESSED), (HIS_HOT, HIS_PRESSED));
          var
            LRect, ClipRect: TRect;
          begin
            LRect := ARect;

            if (FInternalDrawingStyle = gdsThemed) and (gdFixed in AState) then
            begin
              ClipRect := LRect;
              if Win32MajorVersion >= 6 then
                InflateRect(LRect, 1, 1);
              Inc(LRect.Bottom);
              DrawThemeBackground(ThemeServices.Theme[teHeader], Canvas.Handle,
                HP_HEADERITEM, States[(gdHotTrack in AState),
                (gdPressed in AState)], LRect, {$IFNDEF CLR}@
                {$ENDIF} ClipRect);
              Canvas.Brush.Style := bsClear;
            end
            else
            begin
              if (FInternalDrawingStyle = gdsGradient) and (gdFixed in AState)
                then
              begin
                if not(goFixedVertLine in Options) then
                  Inc(LRect.Right);
                if not(goFixedHorzLine in Options) then
                  Inc(LRect.Bottom);

                if (gdHotTrack in AState) or (gdPressed in AState) then
                begin
                  if (gdPressed in AState) then
                    GradientFillCanvas(Canvas, FGradientEndColor,
                      FGradientStartColor, LRect, gdVertical)
                  else
                    GradientFillCanvas(Canvas,
                      GetHighlightColor(FGradientStartColor),
                      GetHighlightColor(FGradientEndColor),
                      LRect, gdVertical);
                end
                else
                  GradientFillCanvas(Canvas, FGradientStartColor,
                    FGradientEndColor, LRect, gdVertical);
                Canvas.Brush.Style := bsClear;
              end
              else
              begin
                Canvas.Brush.Color := AColor;
                Canvas.FillRect(LRect);
                if (gdPressed in AState) then
                begin
                  Dec(LRect.Right);
                  Dec(LRect.Bottom);
                  DrawEdge(Canvas.Handle, LRect, BDR_SUNKENINNER, BF_TOPLEFT);
                  DrawEdge(Canvas.Handle, LRect, BDR_SUNKENINNER,
                    BF_BOTTOMRIGHT);
                end;
              end;
            end;
          end;

          procedure TCustomGrid.DrawMove;
          var
            OldPen: TPen;
            Pos: Integer;
            R: TRect;
          begin
            OldPen := TPen.Create;
            try
              with Canvas do
              begin
                OldPen.Assign(Pen);
                try
                  Pen.Style := psDot;
                  Pen.Mode := pmXor;
                  Pen.Width := 5;
                  if FGridState = gsRowMoving then
                  begin
                    R := CellRect(0, FMovePos);
                    if FMovePos > FMoveIndex then
                      Pos := R.Bottom
                    else
                      Pos := R.Top;
                    MoveTo(0, Pos);
                    LineTo(ClientWidth, Pos);
                  end
                  else
                  begin
                    R := CellRect(FMovePos, 0);
                    if FMovePos > FMoveIndex then
                      if not UseRightToLeftAlignment then
                        Pos := R.Right
                      else
                        Pos := R.Left
                      else if not UseRightToLeftAlignment then
                        Pos := R.Left
                      else
                        Pos := R.Right;
                    MoveTo(Pos, 0);
                    LineTo(Pos, ClientHeight);
                  end;
                finally
                  Canvas.Pen := OldPen;
                end;
              end;
            finally
              OldPen.Free;
            end;
          end;

          procedure TCustomGrid.FixedCellClick(ACol, ARow: Integer);
          begin
            if Assigned(FOnFixedCellClick) then
              FOnFixedCellClick(Self, ACol, ARow);
          end;

          procedure TCustomGrid.FocusCell(ACol, ARow: Longint;
            MoveAnchor: Boolean);
          begin
            MoveCurrent(ACol, ARow, MoveAnchor, True);
            UpdateEdit;
            Click;
          end;

          procedure TCustomGrid.GridRectToScreenRect(GridRect: TGridRect;
            var ScreenRect: TRect; IncludeLine: Boolean);

            function LinePos(const AxisInfo: TGridAxisDrawInfo;
              Line: Integer): Integer;
            var
              Start, I: Longint;
            begin
              with AxisInfo do
              begin
                Result := 0;
                if Line < FixedCellCount then
                  Start := 0
                else
                begin
                  if Line >= FirstGridCell then
                    Result := FixedBoundary;
                  Start := FirstGridCell;
                end;
                for I := Start to Line - 1 do
                begin
                  Inc(Result, AxisInfo.GetExtent(I) + EffectiveLineWidth);
                  if Result > GridExtent then
                  begin
                    Result := 0;
                    Exit;
                  end;
                end;
              end;
            end;

            function CalcAxis(const AxisInfo: TGridAxisDrawInfo;
              GridRectMin, GridRectMax: Integer; var ScreenRectMin,
              ScreenRectMax: Integer): Boolean;
            begin
              Result := False;
              with AxisInfo do
              begin
                if (GridRectMin >= FixedCellCount) and
                  (GridRectMin < FirstGridCell) then
                  if GridRectMax < FirstGridCell then
                  begin
                    ScreenRect := Rect(0, 0, 0, 0); { erase partial results }
                    Exit;
                  end
                  else
                    GridRectMin := FirstGridCell;
                if GridRectMax > LastFullVisibleCell then
                begin
                  GridRectMax := LastFullVisibleCell;
                  if GridRectMax < GridCellCount - 1 then
                    Inc(GridRectMax);
                  if LinePos(AxisInfo, GridRectMax) = 0 then
                    Dec(GridRectMax);
                end;

                ScreenRectMin := LinePos(AxisInfo, GridRectMin);
                ScreenRectMax := LinePos(AxisInfo, GridRectMax);
                if ScreenRectMax = 0 then
                  ScreenRectMax := ScreenRectMin + AxisInfo.GetExtent
                    (GridRectMin)
                else
                  Inc(ScreenRectMax, AxisInfo.GetExtent(GridRectMax));
                if ScreenRectMax > GridExtent then
                  ScreenRectMax := GridExtent;
                if IncludeLine then
                  Inc(ScreenRectMax, EffectiveLineWidth);
              end;
              Result := True;
            end;

          var
            DrawInfo: TGridDrawInfo;
            Hold: Integer;
          begin
            ScreenRect := Rect(0, 0, 0, 0);
            if (GridRect.Left > GridRect.Right) or
              (GridRect.Top > GridRect.Bottom) then
              Exit;
            CalcDrawInfo(DrawInfo);
            with DrawInfo do
            begin
              if GridRect.Left > Horz.LastFullVisibleCell + 1 then
                Exit;
              if GridRect.Top > Vert.LastFullVisibleCell + 1 then
                Exit;

              if CalcAxis(Horz, GridRect.Left, GridRect.Right, ScreenRect.Left,
                ScreenRect.Right) then
              begin
                CalcAxis(Vert, GridRect.Top, GridRect.Bottom, ScreenRect.Top,
                  ScreenRect.Bottom);
              end;
            end;
            if UseRightToLeftAlignment and
              (Canvas.CanvasOrientation = coLeftToRight) then
            begin
              Hold := ScreenRect.Left;
              ScreenRect.Left := ClientWidth - ScreenRect.Right;
              ScreenRect.Right := ClientWidth - Hold;
            end;
          end;

          procedure TCustomGrid.Initialize;
          begin
            FTopLeft.X := FixedCols;
            FTopLeft.Y := FixedRows;
            FCurrent := FTopLeft;
            FAnchor := FCurrent;
            if goRowSelect in Options then
              FAnchor.X := ColCount - 1;
          end;

          procedure TCustomGrid.InvalidateCell(ACol, ARow: Longint);
          var
            Rect: TGridRect;
          begin
            Rect.Top := ARow;
            Rect.Left := ACol;
            Rect.Bottom := ARow;
            Rect.Right := ACol;
            InvalidateRect(Rect);
          end;

          procedure TCustomGrid.InvalidateCol(ACol: Longint);
          var
            Rect: TGridRect;
          begin
            if not HandleAllocated then
              Exit;
            Rect.Top := 0;
            Rect.Left := ACol;
            Rect.Bottom := VisibleRowCount + 1;
            Rect.Right := ACol;
            InvalidateRect(Rect);
          end;

          procedure TCustomGrid.InvalidateRow(ARow: Longint);
          var
            Rect: TGridRect;
          begin
            if not HandleAllocated then
              Exit;
            Rect.Top := ARow;
            Rect.Left := 0;
            Rect.Bottom := ARow;
            Rect.Right := VisibleColCount + 1;
            InvalidateRect(Rect);
          end;

          procedure TCustomGrid.InvalidateGrid;
          begin
            Invalidate;
          end;

          procedure TCustomGrid.InvalidateRect(ARect: TGridRect);
          var
            InvalidRect: TRect;
          begin
            if not HandleAllocated then
              Exit;
            GridRectToScreenRect(ARect, InvalidRect, True);
            Windows.InvalidateRect(Handle, InvalidRect, False);
          end;

          function TCustomGrid.IsTouchPropertyStored(AProperty: TTouchProperty)
            : Boolean;
          begin
            Result := inherited IsTouchPropertyStored(AProperty);
            case AProperty of
              tpInteractiveGestures:
                Result := Touch.InteractiveGestures <> [igPan, igPressAndTap];
              tpInteractiveGestureOptions:
                Result := Touch.InteractiveGestureOptions <> [igoPanInertia,
                  igoPanSingleFingerHorizontal, igoPanSingleFingerVertical,
                  igoPanGutter, igoParentPassthrough];
            end;
          end;

          procedure TCustomGrid.ModifyScrollBar(ScrollBar, ScrollCode,
            Pos: Cardinal; UseRightToLeft: Boolean);
          var
            NewTopLeft, MaxTopLeft: TGridCoord;
            DrawInfo: TGridDrawInfo;
            RTLFactor: Integer;

            function Min: Longint;
            begin
              if ScrollBar = SB_HORZ then
                Result := FixedCols
              else
                Result := FixedRows;
            end;

            function Max: Longint;
            begin
              if ScrollBar = SB_HORZ then
                Result := MaxTopLeft.X
              else
                Result := MaxTopLeft.Y;
            end;

            function PageUp: Longint;
            var
              MaxTopLeft: TGridCoord;
            begin
              MaxTopLeft := CalcMaxTopLeft(FTopLeft, DrawInfo);
              if ScrollBar = SB_HORZ then
                Result := FTopLeft.X - MaxTopLeft.X
              else
                Result := FTopLeft.Y - MaxTopLeft.Y;
              if Result < 1 then
                Result := 1;
            end;

            function PageDown: Longint;
            var
              DrawInfo: TGridDrawInfo;
            begin
              CalcDrawInfo(DrawInfo);
              with DrawInfo do
                if ScrollBar = SB_HORZ then
                  Result := Horz.LastFullVisibleCell - FTopLeft.X
                else
                  Result := Vert.LastFullVisibleCell - FTopLeft.Y;
              if Result < 1 then
                Result := 1;
            end;

            function CalcScrollBar(Value, ARTLFactor: Longint): Longint;
            begin
              Result := Value;
              case ScrollCode of
                SB_LINEUP:
                  Dec(Result, ARTLFactor);
                SB_LINEDOWN:
                  Inc(Result, ARTLFactor);
                SB_PAGEUP:
                  Dec(Result, PageUp * ARTLFactor);
                SB_PAGEDOWN:
                  Inc(Result, PageDown * ARTLFactor);
                SB_THUMBPOSITION, SB_THUMBTRACK:
                  if (goThumbTracking in Options) or
                    (ScrollCode = SB_THUMBPOSITION) then
                  begin
{$IF DEFINED(CLR)}
                    if (not UseRightToLeftAlignment) or (ARTLFactor = 1) then
                      Result := Min + MulDiv(Pos, Max - Min, MaxShortInt)
                    else
                      Result := Max - MulDiv(Pos, Max - Min, MaxShortInt);
{$ELSE}
                    if (not UseRightToLeftAlignment) or (ARTLFactor = 1) then
                      Result := Min + LongMulDiv(Pos, Max - Min, MaxShortInt)
                    else
                      Result := Max - LongMulDiv(Pos, Max - Min, MaxShortInt);
{$IFEND}
                  end;
                SB_BOTTOM:
                  Result := Max;
                SB_TOP:
                  Result := Min;
              end;
            end;

            procedure ModifyPixelScrollBar(Code, Pos: Cardinal);
            var
              NewOffset: Integer;
              OldOffset: Integer;
              R: TGridRect;
              GridSpace, ColWidth: Integer;
            begin
              NewOffset := FColOffset;
              ColWidth := ColWidths[DrawInfo.Horz.FirstGridCell];
              GridSpace := ClientWidth - DrawInfo.Horz.FixedBoundary;
              case Code of
                SB_LINEUP:
                  Dec(NewOffset, Canvas.TextWidth('0') * RTLFactor);
                SB_LINEDOWN:
                  Inc(NewOffset, Canvas.TextWidth('0') * RTLFactor);
                SB_PAGEUP:
                  Dec(NewOffset, GridSpace * RTLFactor);
                SB_PAGEDOWN:
                  Inc(NewOffset, GridSpace * RTLFactor);
                SB_THUMBPOSITION, SB_THUMBTRACK:
                  if (goThumbTracking in Options) or (Code = SB_THUMBPOSITION)
                    then
                  begin
                    if not UseRightToLeftAlignment then
                      NewOffset := Pos
                    else
                      NewOffset := Max - Integer(Pos);
                  end;
                SB_BOTTOM:
                  NewOffset := 0;
                SB_TOP:
                  NewOffset := ColWidth - GridSpace;
              end;
              if NewOffset < 0 then
                NewOffset := 0
              else if NewOffset >= ColWidth - GridSpace then
                NewOffset := ColWidth - GridSpace;
              if NewOffset <> FColOffset then
              begin
                OldOffset := FColOffset;
                FColOffset := NewOffset;
                ScrollData(OldOffset - NewOffset, 0);
{$IF DEFINED(CLR)}
                R := Rect(0, 0, 0, 0);
{$ELSE}
                FillChar(R, SizeOf(R), 0);
{$IFEND}
                R.Bottom := FixedRows;
                InvalidateRect(R);
                Update;
                UpdateScrollPos;
              end;
            end;

          var
            Temp: Longint;
          begin
            if (not UseRightToLeftAlignment) or (not UseRightToLeft) then
              RTLFactor := 1
            else
              RTLFactor := -1;
            if Visible and CanFocus and TabStop and not
              (csDesigning in ComponentState) then
              SetFocus;
            CalcDrawInfo(DrawInfo);
            if (ScrollBar = SB_HORZ) and (ColCount = 1) then
            begin
              ModifyPixelScrollBar(ScrollCode, Pos);
              Exit;
            end;
            MaxTopLeft.X := ColCount - 1;
            MaxTopLeft.Y := RowCount - 1;
            MaxTopLeft := CalcMaxTopLeft(MaxTopLeft, DrawInfo);
            NewTopLeft := FTopLeft;
            if ScrollBar = SB_HORZ then
              repeat
                Temp := NewTopLeft.X;
                NewTopLeft.X := CalcScrollBar(NewTopLeft.X, RTLFactor);
              until (NewTopLeft.X <= FixedCols) or
                (NewTopLeft.X >= MaxTopLeft.X) or
                (ColWidths[NewTopLeft.X] > 0) or (Temp = NewTopLeft.X)
                else repeat Temp := NewTopLeft.Y;
              NewTopLeft.Y := CalcScrollBar(NewTopLeft.Y, 1);
            until (NewTopLeft.Y <= FixedRows) or (NewTopLeft.Y >= MaxTopLeft.Y)
              or (RowHeights[NewTopLeft.Y] > 0) or (Temp = NewTopLeft.Y);
            NewTopLeft.X := Math.Max(FixedCols, Math.Min(MaxTopLeft.X,
                NewTopLeft.X));
            NewTopLeft.Y := Math.Max(FixedRows, Math.Min(MaxTopLeft.Y,
                NewTopLeft.Y));
            if (NewTopLeft.X <> FTopLeft.X) or (NewTopLeft.Y <> FTopLeft.Y) then
              MoveTopLeft(NewTopLeft.X, NewTopLeft.Y);
          end;

          procedure TCustomGrid.MoveAdjust(var CellPos: Longint;
            FromIndex, ToIndex: Longint);
          var
            Min, Max: Longint;
          begin
            if CellPos = FromIndex then
              CellPos := ToIndex
            else
            begin
              Min := FromIndex;
              Max := ToIndex;
              if FromIndex > ToIndex then
              begin
                Min := ToIndex;
                Max := FromIndex;
              end;
              if (CellPos >= Min) and (CellPos <= Max) then
                if FromIndex > ToIndex then
                  Inc(CellPos)
                else
                  Dec(CellPos);
            end;
          end;

          procedure TCustomGrid.MoveAnchor(const NewAnchor: TGridCoord);
          var
            OldSel: TGridRect;
          begin
            if [goRangeSelect, goEditing] * Options = [goRangeSelect] then
            begin
              OldSel := Selection;
{              if RowHighlight then
                OldSel.Left := 0;    }
              FAnchor := NewAnchor;
              if (goRowSelect in Options){ or RowHighLight} then
                FAnchor.X := ColCount - 1;
              ClampInView(NewAnchor);
              SelectionMoved(OldSel);
            end
            else
              MoveCurrent(NewAnchor.X, NewAnchor.Y, True, True);
          end;

          procedure TCustomGrid.MoveCurrent(ACol, ARow: Longint;
            MoveAnchor, Show: Boolean);
          var
            OldSel: TGridRect;
            OldCurrent: TGridCoord;
            FFCurrent: TGridCoord;
          begin
            if (ACol < 0) or (ARow < 0) or (ACol >= ColCount) or
              (ARow >= RowCount) then
              InvalidOp(SIndexOutOfRange);
            if SelectCell(ACol, ARow) then
            begin
              OldSel := Selection;
{              if RowHighlight then
                OldSel.Left := 0;  }
              OldCurrent := FCurrent;
              FCurrent.X := ACol;
              FCurrent.Y := ARow;
              if not(goAlwaysShowEditor in Options) then
                HideEditor;
              if MoveAnchor or not(goRangeSelect in Options) then
              begin
                FAnchor := FCurrent;
                if (goRowSelect in Options){ or RowHighlight} then
                  FAnchor.X := ColCount - 1;
              end;
              if (goRowSelect in Options){ or RowHighlight} then
                FCurrent.X := FixedCols;
              FFCurrent := FCurrent;
              if RowHighlight then
                FFCurrent.X := FixedCols;
              if Show then
                ClampInView(FFCurrent);
              SelectionMoved(OldSel);
              with OldCurrent do
                  InvalidateCell(X, Y);
              with FFCurrent do
                  InvalidateCell(ACol, ARow);
            end;
          end;

          procedure TCustomGrid.MoveTopLeft(ALeft, ATop: Longint);
          var
            OldTopLeft: TGridCoord;
          begin
            if (ALeft = FTopLeft.X) and (ATop = FTopLeft.Y) then
              Exit;
            Update;
            OldTopLeft := FTopLeft;
            FTopLeft.X := ALeft;
            FTopLeft.Y := ATop;
            TopLeftMoved(OldTopLeft);
          end;

          procedure TCustomGrid.ResizeCol(Index: Longint;
            OldSize, NewSize: Integer);
          begin
            InvalidateGrid;
          end;

          procedure TCustomGrid.ResizeRow(Index: Longint;
            OldSize, NewSize: Integer);
          begin
            InvalidateGrid;
          end;

          procedure TCustomGrid.SelectionMoved(const OldSel: TGridRect);
          var
            OldRect, NewRect: TRect;
            AXorRects: TXorRects;
            I: Integer;
          begin
            if not HandleAllocated then
              Exit;
            GridRectToScreenRect(OldSel, OldRect, True);
            GridRectToScreenRect(Selection, NewRect, True);
            XorRects(OldRect, NewRect, AXorRects);
            for I := Low(AXorRects) to High(AXorRects) do
              Windows.InvalidateRect(Handle, AXorRects[I], False);
          end;

          procedure TCustomGrid.ScrollDataInfo(DX, DY: Integer;
            var DrawInfo: TGridDrawInfo);
          var
            ScrollArea: TRect;
            ScrollFlags: Integer;
          begin
            with DrawInfo do
            begin
              ScrollFlags := SW_INVALIDATE;
              if not DefaultDrawing then
                ScrollFlags := ScrollFlags or SW_ERASE;
              { Scroll the area }
              if DY = 0 then
              begin
                { Scroll both the column titles and data area at the same time }
                if not UseRightToLeftAlignment then
                  ScrollArea := Rect(Horz.FixedBoundary, 0, Horz.GridExtent,
                    Vert.GridExtent)
                else
                begin
                  ScrollArea := Rect(ClientWidth - Horz.GridExtent, 0,
                    ClientWidth - Horz.FixedBoundary, Vert.GridExtent);
                  DX := -DX;
                end;
                ScrollWindowEx(Handle, DX, 0, ScrollArea, ScrollArea, 0, nil,
                  ScrollFlags);
              end
              else if DX = 0 then
              begin
                { Scroll both the row titles and data area at the same time }
                ScrollArea := Rect(0, Vert.FixedBoundary, Horz.GridExtent,
                  Vert.GridExtent);
                ScrollWindowEx(Handle, 0, DY, ScrollArea, ScrollArea, 0, nil,
                  ScrollFlags);
              end
              else
              begin
                { Scroll titles and data area separately }
                { Column titles }
                ScrollArea := Rect(Horz.FixedBoundary, 0, Horz.GridExtent,
                  Vert.FixedBoundary);
                ScrollWindowEx(Handle, DX, 0, ScrollArea, ScrollArea, 0, nil,
                  ScrollFlags);
                { Row titles }
                ScrollArea := Rect(0, Vert.FixedBoundary, Horz.FixedBoundary,
                  Vert.GridExtent);
                ScrollWindowEx(Handle, 0, DY, ScrollArea, ScrollArea, 0, nil,
                  ScrollFlags);
                { Data area }
                ScrollArea := Rect(Horz.FixedBoundary, Vert.FixedBoundary,
                  Horz.GridExtent, Vert.GridExtent);
                ScrollWindowEx(Handle, DX, DY, ScrollArea, ScrollArea, 0, nil,
                  ScrollFlags);
              end;
            end;
            if (goRowSelect in Options) or RowHighlight then
              InvalidateRect(Selection);
          end;

          procedure TCustomGrid.ScrollData(DX, DY: Integer);
          var
            DrawInfo: TGridDrawInfo;
          begin
            CalcDrawInfo(DrawInfo);
            ScrollDataInfo(DX, DY, DrawInfo);
          end;

          procedure TCustomGrid.TopLeftMoved(const OldTopLeft: TGridCoord);

            function CalcScroll(const AxisInfo: TGridAxisDrawInfo;
              OldPos, CurrentPos: Integer; var Amount: Longint): Boolean;
            var
              Start, Stop: Longint;
              I: Longint;
            begin
              Result := False;
              with AxisInfo do
              begin
                if OldPos < CurrentPos then
                begin
                  Start := OldPos;
                  Stop := CurrentPos;
                end
                else
                begin
                  Start := CurrentPos;
                  Stop := OldPos;
                end;
                Amount := 0;
                for I := Start to Stop - 1 do
                begin
                  Inc(Amount, AxisInfo.GetExtent(I) + EffectiveLineWidth);
                  if Amount > (GridBoundary - FixedBoundary) then
                  begin
                    { Scroll amount too big, redraw the whole thing }
                    InvalidateGrid;
                    Exit;
                  end;
                end;
                if OldPos < CurrentPos then
                  Amount := -Amount;
              end;
              Result := True;
            end;

          var
            DrawInfo: TGridDrawInfo;
            Delta: TGridCoord;
          begin
            UpdateScrollPos;
            CalcDrawInfo(DrawInfo);
            if CalcScroll(DrawInfo.Horz, OldTopLeft.X, FTopLeft.X, Delta.X)
              and CalcScroll(DrawInfo.Vert, OldTopLeft.Y, FTopLeft.Y,
              Delta.Y) then
              ScrollDataInfo(Delta.X, Delta.Y, DrawInfo);
            TopLeftChanged;
          end;

          procedure TCustomGrid.UpdateScrollPos;
          var
            DrawInfo: TGridDrawInfo;
            MaxTopLeft: TGridCoord;
            GridSpace, ColWidth: Integer;

            procedure SetScroll(Code: Word; Value: Integer);
            begin
              if UseRightToLeftAlignment and (Code = SB_HORZ) then
                if ColCount <> 1 then
                  Value := MaxShortInt - Value
                else
                  Value := (ColWidth - GridSpace) - Value;
              if GetScrollPos(Handle, Code) <> Value then
                SetScrollPos(Handle, Code, Value, True);
            end;

          begin
            if (not HandleAllocated) or (ScrollBars = ssNone) then
              Exit;
            CalcDrawInfo(DrawInfo);
            MaxTopLeft.X := ColCount - 1;
            MaxTopLeft.Y := RowCount - 1;
            MaxTopLeft := CalcMaxTopLeft(MaxTopLeft, DrawInfo);
            if ScrollBars in [ssHorizontal, ssBoth] then
              if ColCount = 1 then
              begin
                ColWidth := ColWidths[DrawInfo.Horz.FirstGridCell];
                GridSpace := ClientWidth - DrawInfo.Horz.FixedBoundary;
                if (FColOffset > 0) and (GridSpace > (ColWidth - FColOffset))
                  then
                  ModifyScrollBar(SB_HORZ, SB_THUMBPOSITION,
                    ColWidth - GridSpace, True)
                else
                  SetScroll(SB_HORZ, FColOffset)
              end
              else
{$IF DEFINED(CLR)}
                SetScroll(SB_HORZ, MulDiv(FTopLeft.X - FixedCols, MaxShortInt,
                    MaxTopLeft.X - FixedCols));
            if ScrollBars in [ssVertical, ssBoth] then
              SetScroll(SB_VERT, MulDiv(FTopLeft.Y - FixedRows, MaxShortInt,
                  MaxTopLeft.Y - FixedRows));
{$ELSE}
            SetScroll(SB_HORZ, LongMulDiv(FTopLeft.X - FixedCols, MaxShortInt,
                MaxTopLeft.X - FixedCols));
            if ScrollBars in [ssVertical, ssBoth] then
              SetScroll(SB_VERT, LongMulDiv(FTopLeft.Y - FixedRows,
                  MaxShortInt, MaxTopLeft.Y - FixedRows));
{$IFEND}
          end;

          procedure TCustomGrid.UpdateScrollRange;
          var
            MaxTopLeft, OldTopLeft: TGridCoord;
            DrawInfo: TGridDrawInfo;
            OldScrollBars: TScrollStyle;
            Updated: Boolean;

            procedure DoUpdate;
            begin
              if not Updated then
              begin
                Update;
                Updated := True;
              end;
            end;

            function ScrollBarVisible(Code: Word): Boolean;
            var
              Min, Max: Integer;
            begin
              Result := False;
              if (ScrollBars = ssBoth) or
                ((Code = SB_HORZ) and (ScrollBars = ssHorizontal)) or
                ((Code = SB_VERT) and (ScrollBars = ssVertical)) then
              begin
                GetScrollRange(Handle, Code, Min, Max);
                Result := Min <> Max;
              end;
            end;

            procedure CalcSizeInfo;
            begin
              CalcDrawInfoXY(DrawInfo, DrawInfo.Horz.GridExtent,
                DrawInfo.Vert.GridExtent);
              MaxTopLeft.X := ColCount - 1;
              MaxTopLeft.Y := RowCount - 1;
              MaxTopLeft := CalcMaxTopLeft(MaxTopLeft, DrawInfo);
            end;

            procedure SetAxisRange(var Max, Old, Current: Longint; Code: Word;
              Fixeds: Integer);
            begin
              CalcSizeInfo;
              if Fixeds < Max then
                SetScrollRange(Handle, Code, 0, MaxShortInt, True)
              else
                SetScrollRange(Handle, Code, 0, 0, True);
              if Old > Max then
              begin
                DoUpdate;
                Current := Max;
              end;
            end;

            procedure SetHorzRange;
            var
              Range: Integer;
            begin
              if OldScrollBars in [ssHorizontal, ssBoth] then
                if ColCount = 1 then
                begin
                  Range := ColWidths[0] - ClientWidth;
                  if Range < 0 then
                    Range := 0;
                  SetScrollRange(Handle, SB_HORZ, 0, Range, True);
                end
                else
                  SetAxisRange(MaxTopLeft.X, OldTopLeft.X, FTopLeft.X, SB_HORZ,
                    FixedCols);
            end;

            procedure SetVertRange;
            begin
              if OldScrollBars in [ssVertical, ssBoth] then
                SetAxisRange(MaxTopLeft.Y, OldTopLeft.Y, FTopLeft.Y, SB_VERT,
                  FixedRows);
            end;

          begin
            if (ScrollBars = ssNone) or not HandleAllocated or not Showing then
              Exit;
            with DrawInfo do
            begin
              Horz.GridExtent := ClientWidth;
              Vert.GridExtent := ClientHeight;
              { Ignore scroll bars for initial calculation }
              if ScrollBarVisible(SB_HORZ) then
                Inc(Vert.GridExtent, GetSystemMetrics(SM_CYHSCROLL));
              if ScrollBarVisible(SB_VERT) then
                Inc(Horz.GridExtent, GetSystemMetrics(SM_CXVSCROLL));
            end;
            OldTopLeft := FTopLeft;
            { Temporarily mark us as not having scroll bars to avoid recursion }
            OldScrollBars := FScrollBars;
            FScrollBars := ssNone;
            Updated := False;
            try
              { Update scrollbars }
              SetHorzRange;
              DrawInfo.Vert.GridExtent := ClientHeight;
              SetVertRange;
              if DrawInfo.Horz.GridExtent <> ClientWidth then
              begin
                DrawInfo.Horz.GridExtent := ClientWidth;
                SetHorzRange;
              end;
            finally
              FScrollBars := OldScrollBars;
            end;
            UpdateScrollPos;
            if (FTopLeft.X <> OldTopLeft.X) or (FTopLeft.Y <> OldTopLeft.Y) then
              TopLeftMoved(OldTopLeft);
          end;

          function TCustomGrid.CreateEditor: TInplaceEdit;
          begin
            Result := TInplaceEdit.Create(Self);
            Result.ReadOnly := FReadOnly;
          end;

          procedure TCustomGrid.CreateParams(var Params: TCreateParams);
          begin
            inherited CreateParams(Params);
            with Params do
            begin
              Style := Style or WS_TABSTOP;
              if FScrollBars in [ssVertical, ssBoth] then
                Style := Style or WS_VSCROLL;
              if FScrollBars in [ssHorizontal, ssBoth] then
                Style := Style or WS_HSCROLL;
              WindowClass.Style := CS_DBLCLKS;
              if FBorderStyle = bsSingle then
                if NewStyleControls and Ctl3D then
                begin
                  Style := Style and not WS_BORDER;
                  ExStyle := ExStyle or WS_EX_CLIENTEDGE;
                end
                else
                  Style := Style or WS_BORDER;
            end;
          end;

          procedure TCustomGrid.CreateWnd;
          begin
            inherited;
            FInternalDrawingStyle := FDrawingStyle;
            if (FDrawingStyle = gdsThemed) and not ThemeControl(Self) then
              FInternalDrawingStyle := gdsClassic;
          end;

          procedure TCustomGrid.DoGesture(const EventInfo: TGestureEventInfo;
            var Handled: Boolean);
          const
            VertScrollFlags: array [Boolean] of Integer = (SB_LINEDOWN,
              SB_LINEUP);
            HorizScrollFlags: array [Boolean] of Integer = (SB_LINERIGHT,
              SB_LINELEFT);
          var
            I, LColWidth, LCols, LRowHeight, LRows, DeltaX, DeltaY: Integer;
          begin
            if EventInfo.GestureID = igiPan then
            begin
              Handled := True;
              if gfBegin in EventInfo.Flags then
                FPanPoint := EventInfo.Location
              else if not(gfEnd in EventInfo.Flags) then
              begin
                // Vertical panning
                DeltaY := EventInfo.Location.Y - FPanPoint.Y;
                if Abs(DeltaY) > 1 then
                begin
                  LRowHeight := RowHeights[TopRow];
                  LRows := Abs(DeltaY) div LRowHeight;
                  if (Abs(DeltaY) mod LRowHeight = 0) or (LRows > 0) then
                  begin
                    for I := 0 to LRows - 1 do
                      ModifyScrollBar(SB_VERT, VertScrollFlags[DeltaY > 0], 0,
                        True);
                    FPanPoint := EventInfo.Location;
                    Inc(FPanPoint.Y, DeltaY mod LRowHeight);
                  end;
                end
                else
                begin
                  // Horizontal panning
                  DeltaX := EventInfo.Location.X - FPanPoint.X;
                  if Abs(DeltaX) > 1 then
                  begin
                    LColWidth := ColWidths[LeftCol];
                    LCols := Abs(DeltaX) div LColWidth;
                    if (Abs(DeltaX) mod LColWidth = 0) or (LCols > 0) then
                    begin
                      for I := 0 to LCols - 1 do
                        ModifyScrollBar(SB_HORZ, HorizScrollFlags[DeltaX > 0],
                          0, True);
                      FPanPoint := EventInfo.Location;
                      Inc(FPanPoint.X, DeltaX mod LColWidth);
                    end;
                  end;
                end;

              end;
            end;
          end;

          procedure TCustomGrid.KeyDown(var Key: Word; Shift: TShiftState);
          var
            NewTopLeft, NewCurrent, MaxTopLeft: TGridCoord;
            DrawInfo: TGridDrawInfo;
            PageWidth, PageHeight: Integer;
            RTLFactor: Integer;
            NeedsInvalidating: Boolean;

            procedure CalcPageExtents;
            begin
              CalcDrawInfo(DrawInfo);
              PageWidth := DrawInfo.Horz.LastFullVisibleCell - LeftCol;
              if PageWidth < 1 then
                PageWidth := 1;
              PageHeight := DrawInfo.Vert.LastFullVisibleCell - TopRow;
              if PageHeight < 1 then
                PageHeight := 1;
            end;

            procedure Restrict(var Coord: TGridCoord;
              MinX, MinY, MaxX, MaxY: Longint);
            begin
              with Coord do
              begin
                if X > MaxX then
                  X := MaxX
                else if X < MinX then
                  X := MinX;
                if Y > MaxY then
                  Y := MaxY
                else if Y < MinY then
                  Y := MinY;
              end;
            end;

          begin
            inherited KeyDown(Key, Shift);
            NeedsInvalidating := False;
            if not CanGridAcceptKey(Key, Shift) then
              Key := 0;
            if not UseRightToLeftAlignment then
              RTLFactor := 1
            else
              RTLFactor := -1;
            NewCurrent := FCurrent;
            NewTopLeft := FTopLeft;
            CalcPageExtents;
            if ssCtrl in Shift then
              case Key of
                VK_UP:
                  Dec(NewTopLeft.Y);
                VK_DOWN:
                  Inc(NewTopLeft.Y);
                VK_LEFT:
                  if not(goRowSelect in Options) then
                  begin
                    Dec(NewCurrent.X, PageWidth * RTLFactor);
                    Dec(NewTopLeft.X, PageWidth * RTLFactor);
                  end;
                VK_RIGHT:
                  if not(goRowSelect in Options) then
                  begin
                    Inc(NewCurrent.X, PageWidth * RTLFactor);
                    Inc(NewTopLeft.X, PageWidth * RTLFactor);
                  end;
                VK_PRIOR:
                  NewCurrent.Y := TopRow;
                VK_NEXT:
                  NewCurrent.Y := DrawInfo.Vert.LastFullVisibleCell;
                VK_HOME:
                  begin
                    NewCurrent.X := FixedCols;
                    NewCurrent.Y := FixedRows;
                    NeedsInvalidating := UseRightToLeftAlignment;
                  end;
                VK_END:
                  begin
                    NewCurrent.X := ColCount - 1;
                    NewCurrent.Y := RowCount - 1;
                    NeedsInvalidating := UseRightToLeftAlignment;
                  end;
              end
            else
              case Key of
                VK_UP:
                  Dec(NewCurrent.Y);
                VK_DOWN:
                  Inc(NewCurrent.Y);
                VK_LEFT:
                  if goRowSelect in Options then
                    Dec(NewCurrent.Y, RTLFactor)
                  else
                    Dec(NewCurrent.X, RTLFactor);
                VK_RIGHT:
                  if goRowSelect in Options then
                    Inc(NewCurrent.Y, RTLFactor)
                  else
                    Inc(NewCurrent.X, RTLFactor);
                VK_NEXT:
                  begin
                    Inc(NewCurrent.Y, PageHeight);
                    Inc(NewTopLeft.Y, PageHeight);
                  end;
                VK_PRIOR:
                  begin
                    Dec(NewCurrent.Y, PageHeight);
                    Dec(NewTopLeft.Y, PageHeight);
                  end;
                VK_HOME:
                  if goRowSelect in Options then
                    NewCurrent.Y := FixedRows
                  else
                    NewCurrent.X := FixedCols;
                VK_END:
                  if goRowSelect in Options then
                    NewCurrent.Y := RowCount - 1
                  else
                    NewCurrent.X := ColCount - 1;
                VK_TAB:
                  if not(ssAlt in Shift) then
                    repeat
                      if ssShift in Shift then
                      begin
                        Dec(NewCurrent.X);
                        if NewCurrent.X < FixedCols then
                        begin
                          NewCurrent.X := ColCount - 1;
                          Dec(NewCurrent.Y);
                          if NewCurrent.Y < FixedRows then
                            NewCurrent.Y := RowCount - 1;
                        end;
                        Shift := [];
                      end
                      else
                      begin
                        Inc(NewCurrent.X);
                        if NewCurrent.X >= ColCount then
                        begin
                          NewCurrent.X := FixedCols;
                          Inc(NewCurrent.Y);
                          if NewCurrent.Y >= RowCount then
                            NewCurrent.Y := FixedRows;
                        end;
                      end;
                    until TabStops[NewCurrent.X] or (NewCurrent.X = FCurrent.X);
                  VK_F2 :
                    EditorMode := True;
              end;
            MaxTopLeft.X := ColCount - 1;
            MaxTopLeft.Y := RowCount - 1;
            MaxTopLeft := CalcMaxTopLeft(MaxTopLeft, DrawInfo);
            Restrict(NewTopLeft, FixedCols, FixedRows, MaxTopLeft.X,
              MaxTopLeft.Y);
            if (NewTopLeft.X <> LeftCol) or (NewTopLeft.Y <> TopRow) then
              MoveTopLeft(NewTopLeft.X, NewTopLeft.Y);
            Restrict(NewCurrent, FixedCols, FixedRows, ColCount - 1,
              RowCount - 1);
            if (NewCurrent.X <> Col) or (NewCurrent.Y <> Row) then
              FocusCell(NewCurrent.X, NewCurrent.Y, not(ssShift in Shift));
            if NeedsInvalidating then
              Invalidate;
          end;

          procedure TCustomGrid.KeyPress(var Key: Char);
          begin
            inherited KeyPress(Key);
            if not(goAlwaysShowEditor in Options) and (Key = #13) then
            begin
              if FEditorMode then
                HideEditor
              else
                ShowEditor;
              Key := #0;
            end;
          end;

          procedure TCustomGrid.MouseDown(Button: TMouseButton;
            Shift: TShiftState; X, Y: Integer);
          var
            CellHit: TGridCoord;
            DrawInfo: TGridDrawInfo;
            MoveDrawn: Boolean;
          begin
            MoveDrawn := False;
            HideEdit;
            if not(csDesigning in ComponentState) and
              (CanFocus or (GetParentForm(Self) = nil)) then
            begin
              SetFocus;
              if not IsActiveControl then
              begin
                MouseCapture := False;
                Exit;
              end;
            end;
            if (Button = mbLeft) and (ssDouble in Shift) then
              DblClick
            else if Button = mbLeft then
            begin
              CalcDrawInfo(DrawInfo);
              { Check grid sizing }
              CalcSizingState(X, Y, FGridState, FSizingIndex, FSizingPos,
                FSizingOfs, DrawInfo);
              if FGridState <> gsNormal then
              begin
                if (FGridState = gsColSizing) and UseRightToLeftAlignment then
                  FSizingPos := ClientWidth - FSizingPos;
                DrawSizingLine(DrawInfo);
                Exit;
              end;
              CellHit := CalcCoordFromPoint(X, Y, DrawInfo);
              if (CellHit.X >= FixedCols) and (CellHit.Y >= FixedRows) then
              begin
                if goEditing in Options then
                begin
                  if (CellHit.X = FCurrent.X) and (CellHit.Y = FCurrent.Y) then
                    ShowEditor
                  else
                  begin
                    MoveCurrent(CellHit.X, CellHit.Y, True, True);
                    UpdateEdit;
                  end;
                  Click;
                end
                else
                begin
                  FGridState := gsSelecting;
                  SetTimer(Handle, 1, 60, nil);
                  if ssShift in Shift then
                    MoveAnchor(CellHit)
                  else
                    MoveCurrent(CellHit.X, CellHit.Y, True, True);
                end;
              end
              else
              begin
                if (FHotTrackCell.Coord.X <> -1) or
                  (FHotTrackCell.Coord.Y <> -1) then
                begin
                  FHotTrackCell.Pressed := True;
                  FHotTrackCell.Button := Button;
                  InvalidateCell(FHotTrackCell.Coord.X, FHotTrackCell.Coord.Y);
                end;

                if (goRowMoving in Options) and (CellHit.X >= 0) and
                  (CellHit.X < FixedCols) and (CellHit.Y >= FixedRows) then
                begin
                  FMoveIndex := CellHit.Y;
                  FMovePos := FMoveIndex;
                  if BeginRowDrag(FMoveIndex, FMovePos, Point(X, Y)) then
                  begin
                    FGridState := gsRowMoving;
                    Update;
                    DrawMove;
                    MoveDrawn := True;
                    SetTimer(Handle, 1, 60, nil);
                  end;
                end
                else if (goColMoving in Options) and (CellHit.Y >= 0) and
                  (CellHit.Y < FixedRows) and (CellHit.X >= FixedCols) then
                begin
                  FMoveIndex := CellHit.X;
                  FMovePos := FMoveIndex;
                  if BeginColumnDrag(FMoveIndex, FMovePos, Point(X, Y)) then
                  begin
                    FGridState := gsColMoving;
                    Update;
                    DrawMove;
                    MoveDrawn := True;
                    SetTimer(Handle, 1, 60, nil);
                  end;
                end;
              end;
            end;
            try
              inherited MouseDown(Button, Shift, X, Y);
            except
              if MoveDrawn then
                DrawMove;
            end;
          end;

          procedure TCustomGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
          var
            DrawInfo: TGridDrawInfo;
            CellHit: TGridCoord;
          begin
            CalcDrawInfo(DrawInfo);
            case FGridState of
              gsSelecting, gsColMoving, gsRowMoving:
                begin
                  CellHit := CalcCoordFromPoint(X, Y, DrawInfo);
                  if (CellHit.X >= FixedCols) and (CellHit.Y >= FixedRows) and
                    (CellHit.X <= DrawInfo.Horz.LastFullVisibleCell + 1) and
                    (CellHit.Y <= DrawInfo.Vert.LastFullVisibleCell + 1) then
                    case FGridState of
                      gsSelecting:
                        if ((CellHit.X <> FAnchor.X) or (CellHit.Y <> FAnchor.Y)
                          ) then
                          MoveAnchor(CellHit);
                      gsColMoving:
                        MoveAndScroll(X, CellHit.X, DrawInfo, DrawInfo.Horz,
                          SB_HORZ, Point(X, Y));
                      gsRowMoving:
                        MoveAndScroll(Y, CellHit.Y, DrawInfo, DrawInfo.Vert,
                          SB_VERT, Point(X, Y));
                    end;
                end;
              gsRowSizing, gsColSizing:
                begin
                  DrawSizingLine(DrawInfo); { XOR it out }
                  if FGridState = gsRowSizing then
                    FSizingPos := Y + FSizingOfs
                  else
                    FSizingPos := X + FSizingOfs;
                  DrawSizingLine(DrawInfo); { XOR it back in }
                end;
            else
              begin
                if (csDesigning in ComponentState) then
                  Exit;
                // Highlight "fixed" cell
                CellHit := CalcCoordFromPoint(X, Y, DrawInfo);
                if ((goFixedRowClick in FOptions) and (CellHit.Y <= FixedRows))
                  or ((goFixedColClick in FOptions) and (CellHit.X <= FixedCols)
                  ) then
                begin
                  if (FHotTrackCell.Coord.X <> -1) or
                    (FHotTrackCell.Coord.Y <> -1) then
                    InvalidateCell(FHotTrackCell.Coord.X,
                      FHotTrackCell.Coord.Y);
                  if (CellHit.X <> FHotTrackCell.Coord.X) or
                    (CellHit.Y <> FHotTrackCell.Coord.Y) then
                  begin
                    FHotTrackCell.Coord := CellHit;
                    FHotTrackCell.Pressed := False;
                    InvalidateCell(FHotTrackCell.Coord.X,
                      FHotTrackCell.Coord.Y);
                  end;
                end
                else if (FHotTrackCell.Coord.X <> -1) or
                  (FHotTrackCell.Coord.Y <> -1) then
                begin
                  InvalidateCell(FHotTrackCell.Coord.X, FHotTrackCell.Coord.Y);
                  FHotTrackCell.Coord.X := -1;
                  FHotTrackCell.Coord.Y := -1;
                  FHotTrackCell.Pressed := False;
                end;
              end;
            end;
            inherited MouseMove(Shift, X, Y);
          end;

          procedure TCustomGrid.MouseUp(Button: TMouseButton;
            Shift: TShiftState; X, Y: Integer);
          var
            DrawInfo: TGridDrawInfo;
            NewSize: Integer;
            Cell: TGridCoord;

            function ResizeLine(const AxisInfo: TGridAxisDrawInfo): Integer;
            var
              I: Integer;
            begin
              with AxisInfo do
              begin
                Result := FixedBoundary;
                for I := FirstGridCell to FSizingIndex - 1 do
                  Inc(Result, AxisInfo.GetExtent(I) + EffectiveLineWidth);
                Result := FSizingPos - Result;
              end;
            end;

          begin
            try
              case FGridState of
                gsSelecting:
                  begin
                    MouseMove(Shift, X, Y);
                    KillTimer(Handle, 1);
                    UpdateEdit;
                    Click;
                  end;
                gsRowSizing, gsColSizing:
                  begin
                    CalcDrawInfo(DrawInfo);
                    DrawSizingLine(DrawInfo);
                    if (FGridState = gsColSizing)
                      and UseRightToLeftAlignment then
                      FSizingPos := ClientWidth - FSizingPos;
                    if FGridState = gsColSizing then
                    begin
                      NewSize := ResizeLine(DrawInfo.Horz);
                      if NewSize > 1 then
                      begin
                        ColWidths[FSizingIndex] := NewSize;
                        UpdateDesigner;
                      end;
                    end
                    else
                    begin
                      NewSize := ResizeLine(DrawInfo.Vert);
                      if NewSize > 1 then
                      begin
                        RowHeights[FSizingIndex] := NewSize;
                        UpdateDesigner;
                      end;
                    end;
                  end;
                gsColMoving:
                  begin
                    DrawMove;
                    KillTimer(Handle, 1);
                    if EndColumnDrag(FMoveIndex, FMovePos, Point(X, Y)) and
                      (FMoveIndex <> FMovePos) then
                    begin
                      MoveColumn(FMoveIndex, FMovePos);
                      UpdateDesigner;
                    end;
                    UpdateEdit;
                  end;
                gsRowMoving:
                  begin
                    DrawMove;
                    KillTimer(Handle, 1);
                    if EndRowDrag(FMoveIndex, FMovePos, Point(X, Y)) and
                      (FMoveIndex <> FMovePos) then
                    begin
                      MoveRow(FMoveIndex, FMovePos);
                      UpdateDesigner;
                    end;
                    UpdateEdit;
                  end;
              else
                UpdateEdit;
                Cell := MouseCoord(X, Y);
                if (Button = mbLeft) and (FHotTrackCell.Coord.X <> -1) and
                  (FHotTrackCell.Coord.Y <> -1) and
                  (((goFixedColClick in FOptions) and (Cell.X < FFixedCols)
                      and (Cell.X >= 0)) or ((goFixedRowClick in FOptions) and
                      (Cell.Y < FFixedRows) and (Cell.Y >= 0))) then
                  FixedCellClick(Cell.X, Cell.Y);
              end;
              inherited MouseUp(Button, Shift, X, Y);
            finally
              FGridState := gsNormal;
              FHotTrackCell.Pressed := False;
              InvalidateCell(FHotTrackCell.Coord.X, FHotTrackCell.Coord.Y);
            end;
          end;

          procedure TCustomGrid.MoveAndScroll(Mouse, CellHit: Integer;
            var DrawInfo: TGridDrawInfo; var Axis: TGridAxisDrawInfo;
            ScrollBar: Integer; const MousePt: TPoint);
          begin
            if UseRightToLeftAlignment and (ScrollBar = SB_HORZ) then
              Mouse := ClientWidth - Mouse;
            if (CellHit <> FMovePos) and not
              ((FMovePos = Axis.FixedCellCount) and
                (Mouse < Axis.FixedBoundary)) and not
              ((FMovePos = Axis.GridCellCount - 1) and
                (Mouse > Axis.GridBoundary)) then
            begin
              DrawMove; // hide the drag line
              if (Mouse < Axis.FixedBoundary) then
              begin
                if (FMovePos > Axis.FixedCellCount) then
                begin
                  ModifyScrollBar(ScrollBar, SB_LINEUP, 0, False);
                  Update;
                  CalcDrawInfo(DrawInfo); // this changes contents of Axis var
                end;
                CellHit := Axis.FirstGridCell;
              end
              else if (Mouse >= Axis.FullVisBoundary) then
              begin
                if (FMovePos = Axis.LastFullVisibleCell) and
                  (FMovePos < Axis.GridCellCount - 1) then
                begin
                  ModifyScrollBar(ScrollBar, SB_LINEDOWN, 0, False);
                  Update;
                  CalcDrawInfo(DrawInfo); // this changes contents of Axis var
                end;
                CellHit := Axis.LastFullVisibleCell;
              end
              else if CellHit < 0 then
                CellHit := FMovePos;
              if ((FGridState = gsColMoving) and CheckColumnDrag(FMoveIndex,
                  CellHit, MousePt)) or ((FGridState = gsRowMoving)
                  and CheckRowDrag(FMoveIndex, CellHit, MousePt)) then
                FMovePos := CellHit;
              DrawMove;
            end;
          end;

          function TCustomGrid.GetColWidths(Index: Longint): Integer;
          begin
{$IF DEFINED(CLR)}
            if (Length(FColWidths) = 0) or (Index >= ColCount) then
              Result := DefaultColWidth
            else
              Result := FColWidths[Index + 1];
{$ELSE}
            if (FColWidths = nil) or (Index >= ColCount) then
              Result := DefaultColWidth
            else
              Result := PIntArray(FColWidths)^[Index + 1];
{$IFEND}
          end;

          function TCustomGrid.GetRowHeights(Index: Longint): Integer;
          begin
{$IF DEFINED(CLR)}
            if (Length(FRowHeights) = 0) or (Index >= RowCount) then
              Result := DefaultRowHeight
            else
              Result := FRowHeights[Index + 1];
{$ELSE}
            if (FRowHeights = nil) or (Index >= RowCount) then
              Result := DefaultRowHeight
            else
              Result := PIntArray(FRowHeights)^[Index + 1];
{$IFEND}
          end;

          function TCustomGrid.GetGridWidth: Integer;
          var
            DrawInfo: TGridDrawInfo;
          begin
            CalcDrawInfo(DrawInfo);
            Result := DrawInfo.Horz.GridBoundary;
          end;

          function TCustomGrid.GetGridHeight: Integer;
          var
            DrawInfo: TGridDrawInfo;
          begin
            CalcDrawInfo(DrawInfo);
            Result := DrawInfo.Vert.GridBoundary;
          end;

          function TCustomGrid.GetSelection: TGridRect;
          begin
            Result := GridRect(FCurrent, FAnchor);
          end;

          function TCustomGrid.GetTabStops(Index: Longint): Boolean;
          begin
{$IF DEFINED(CLR)}
            if Length(FTabStops) = 0 then
              Result := True
            else
              Result := FTabStops[Index + 1] <> 0;
{$ELSE}
            if FTabStops = nil then
              Result := True
            else
              Result := Boolean(PIntArray(FTabStops)^[Index + 1]);
{$IFEND}
          end;

          function TCustomGrid.GetVisibleColCount: Integer;
          var
            DrawInfo: TGridDrawInfo;
          begin
            CalcDrawInfo(DrawInfo);
            Result := DrawInfo.Horz.LastFullVisibleCell - LeftCol + 1;
          end;

          function TCustomGrid.GetVisibleRowCount: Integer;
          var
            DrawInfo: TGridDrawInfo;
          begin
            CalcDrawInfo(DrawInfo);
            Result := DrawInfo.Vert.LastFullVisibleCell - TopRow + 1;
          end;

          function TCustomGrid.GetReadOnly: Boolean;
          begin
            Result := FReadOnly{InplaceEditor.ReadOnly};
          end;

          procedure TCustomGrid.SetReadOnly(Value: Boolean);
          begin
            FReadOnly {InplaceEditor.ReadOnly} := Value;
          end;

          procedure TCustomGrid.SetBorderStyle(Value: TBorderStyle);
          begin
            if FBorderStyle <> Value then
            begin
              FBorderStyle := Value;
              RecreateWnd;
            end;
          end;

          procedure TCustomGrid.SetCol(Value: Longint);
          begin
            if Col <> Value then
              FocusCell(Value, Row, True);
          end;

          procedure TCustomGrid.SetColCount(Value: Longint);
          begin
            if FColCount <> Value then
            begin
              if Value < 1 then
                Value := 1;
              if Value <= FixedCols then
                FixedCols := Value - 1;
              ChangeSize(Value, RowCount);
              if goRowSelect in Options then
              begin
                FAnchor.X := ColCount - 1;
                Invalidate;
              end;
            end;
          end;

          procedure TCustomGrid.SetColWidths(Index: Longint; Value: Integer);
          begin
{$IF DEFINED(CLR)}
            if Length(FColWidths) = 0 then
              UpdateExtents(FColWidths, ColCount, DefaultColWidth);
            if Index >= ColCount then
              InvalidOp(SIndexOutOfRange);
            if Value <> FColWidths[Index + 1] then
            begin
              ResizeCol(Index, FColWidths[Index + 1], Value);
              FColWidths[Index + 1] := Value;
              ColWidthsChanged;
            end;
{$ELSE}
            if FColWidths = nil then
              UpdateExtents(FColWidths, ColCount, DefaultColWidth);
            if Index >= ColCount then
              InvalidOp(SIndexOutOfRange);
            if Value <> PIntArray(FColWidths)^[Index + 1] then
            begin
              ResizeCol(Index, PIntArray(FColWidths)^[Index + 1], Value);
              PIntArray(FColWidths)^[Index + 1] := Value;
              ColWidthsChanged;
            end;
{$IFEND}
          end;

          procedure TCustomGrid.SetDefaultColWidth(Value: Integer);
          begin
{$IF DEFINED(CLR)}
            if Length(FColWidths) <> 0 then
{$ELSE}
              if FColWidths <> nil then
{$IFEND}
                UpdateExtents(FColWidths, 0, 0);
            FDefaultColWidth := Value;
            ColWidthsChanged;
            InvalidateGrid;
          end;

          procedure TCustomGrid.SetDefaultRowHeight(Value: Integer);
          begin
{$IF DEFINED(CLR)}
            if Length(FRowHeights) <> 0 then
{$ELSE}
              if FRowHeights <> nil then
{$IFEND}
                UpdateExtents(FRowHeights, 0, 0);
            FDefaultRowHeight := Value;
            RowHeightsChanged;
            InvalidateGrid;
          end;

          procedure TCustomGrid.SetDrawingStyle(const Value: TGridDrawingStyle);
          begin
            if Value <> FDrawingStyle then
            begin
              FDrawingStyle := Value;
              FInternalDrawingStyle := FDrawingStyle;
              if (FDrawingStyle = gdsThemed) and not ThemeControl(Self) then
                FInternalDrawingStyle := gdsClassic;
              Repaint;
            end;
          end;

          procedure TCustomGrid.SetFixedColor(Value: TColor);
          begin
            if FFixedColor <> Value then
            begin
              FFixedColor := Value;
              InvalidateGrid;
            end;
          end;

          procedure TCustomGrid.SetFixedCols(Value: Integer);
          begin
            if FFixedCols <> Value then
            begin
              if Value < 0 then
                InvalidOp(SIndexOutOfRange);
              if Value >= ColCount then
                InvalidOp(SFixedColTooBig);
              FFixedCols := Value;
              Initialize;
              InvalidateGrid;
            end;
          end;

          procedure TCustomGrid.SetFixedRows(Value: Integer);
          begin
            if FFixedRows <> Value then
            begin
              if Value < 0 then
                InvalidOp(SIndexOutOfRange);
              if Value >= RowCount then
                InvalidOp(SFixedRowTooBig);
              FFixedRows := Value;
              Initialize;
              InvalidateGrid;
            end;
          end;

          procedure TCustomGrid.SetEditorMode(Value: Boolean);
          begin
            if not Value then
              HideEditor
            else
            begin
              ShowEditor;
              if FInplaceEdit <> nil then
                FInplaceEdit.Deselect;
            end;
          end;

          procedure TCustomGrid.SetGradientEndColor(Value: TColor);
          begin
            if Value <> FGradientEndColor then
            begin
              FGradientEndColor := Value;
              if HandleAllocated then
                Repaint;
            end;
          end;

          procedure TCustomGrid.SetGradientStartColor(Value: TColor);
          begin
            if Value <> FGradientStartColor then
            begin
              FGradientStartColor := Value;
              if HandleAllocated then
                Repaint;
            end;
          end;

          procedure TCustomGrid.SetGridLineWidth(Value: Integer);
          begin
            if FGridLineWidth <> Value then
            begin
              FGridLineWidth := Value;
              InvalidateGrid;
            end;
          end;

          procedure TCustomGrid.SetLeftCol(Value: Longint);
          begin
            if FTopLeft.X <> Value then
              MoveTopLeft(Value, TopRow);
          end;

          procedure TCustomGrid.SetOddColor(Value: TColor);
          begin
            if FOddColor <> Value then
            begin
              FOddColor := Value;
              InvalidateGrid;
            end;
          end;

          procedure TCustomGrid.SetOptions(Value: TGridOptions);
          begin
            if FOptions <> Value then
            begin
              if goRowSelect in Value then
                Exclude(Value, goAlwaysShowEditor);
              FOptions := Value;
              if not FEditorMode then
                if goAlwaysShowEditor in Value then
                  ShowEditor
                else
                  HideEditor;
              if goRowSelect in Value then
                MoveCurrent(Col, Row, True, False);
              InvalidateGrid;
            end;
          end;

          procedure TCustomGrid.SetRow(Value: Longint);
          begin
            if Row <> Value then
              FocusCell(Col, Value, True);
          end;

          procedure TCustomGrid.SetRowCount(Value: Longint);
          begin
            if FRowCount <> Value then
            begin
              if Value < 1 then
                Value := 1;
              if Value <= FixedRows then
                FixedRows := Value - 1;
              ChangeSize(ColCount, Value);
            end;
          end;

          procedure TCustomGrid.SetRowHeights(Index: Longint; Value: Integer);
          begin
{$IF DEFINED(CLR)}
            if Length(FRowHeights) = 0 then
              UpdateExtents(FRowHeights, RowCount, DefaultRowHeight);
            if Index >= RowCount then
              InvalidOp(SIndexOutOfRange);
            if Value <> FRowHeights[Index + 1] then
            begin
              ResizeRow(Index, FRowHeights[Index + 1], Value);
              FRowHeights[Index + 1] := Value;
              RowHeightsChanged;
            end;
{$ELSE}
            if FRowHeights = nil then
              UpdateExtents(FRowHeights, RowCount, DefaultRowHeight);
            if Index >= RowCount then
              InvalidOp(SIndexOutOfRange);
            if Value <> PIntArray(FRowHeights)^[Index + 1] then
            begin
              ResizeRow(Index, PIntArray(FRowHeights)^[Index + 1], Value);
              PIntArray(FRowHeights)^[Index + 1] := Value;
              RowHeightsChanged;
            end;
{$IFEND}
          end;

          procedure TCustomGrid.SetScrollBars(Value: TScrollStyle);
          begin
            if FScrollBars <> Value then
            begin
              FScrollBars := Value;
              RecreateWnd;
            end;
          end;

          procedure TCustomGrid.SetSelection(Value: TGridRect);
          var
            OldSel: TGridRect;
          begin
            OldSel := Selection;
            FAnchor.X := Value.Left;
            FAnchor.Y := Value.Top;
            FCurrent.X := Value.Right;
            FCurrent.Y := Value.Bottom;
            SelectionMoved(OldSel);
          end;

          procedure TCustomGrid.SetTabStops(Index: Longint; Value: Boolean);
          begin
{$IF DEFINED(CLR)}
            if Length(FTabStops) = 0 then
              UpdateExtents(FTabStops, ColCount, Integer(True));
            if Index >= ColCount then
              InvalidOp(SIndexOutOfRange);
            FTabStops[Index + 1] := Integer(Value);
{$ELSE}
            if FTabStops = nil then
              UpdateExtents(FTabStops, ColCount, Integer(True));
            if Index >= ColCount then
              InvalidOp(SIndexOutOfRange);
            PIntArray(FTabStops)^[Index + 1] := Integer(Value);
{$IFEND}
          end;

          procedure TCustomGrid.SetTopRow(Value: Longint);
          begin
            if FTopLeft.Y <> Value then
              MoveTopLeft(LeftCol, Value);
          end;

          procedure TCustomGrid.HideEdit;
          begin
            if FInplaceEdit <> nil then
              try
                UpdateText;
              finally
                FInplaceCol := -1;
                FInplaceRow := -1;
                FInplaceEdit.Hide;
              end;
          end;

          procedure TCustomGrid.UpdateEdit;

            procedure UpdateEditor;
            begin
              FInplaceCol := Col;
              FInplaceRow := Row;
              FInplaceEdit.UpdateContents;
              if FInplaceEdit.MaxLength = -1 then
                FCanEditModify := False
              else
                FCanEditModify := True;
              FInplaceEdit.SelectAll;
            end;

          begin
            if CanEditShow then
            begin
              if FInplaceEdit = nil then
              begin
                FInplaceEdit := CreateEditor;
                FInplaceEdit.SetGrid(Self);
                FInplaceEdit.Parent := Self;
                UpdateEditor;
              end
              else
              begin
                if (Col <> FInplaceCol) or (Row <> FInplaceRow) then
                begin
                  HideEdit;
                  UpdateEditor;
                end;
              end;
              if CanEditShow then
                FInplaceEdit.Move(CellRect(Col, Row));
            end;
          end;

          procedure TCustomGrid.UpdateText;
          begin
            if (FInplaceCol <> -1) and (FInplaceRow <> -1) then
              SetEditText(FInplaceCol, FInplaceRow, FInplaceEdit.Text);
          end;

          procedure TCustomGrid.WMChar(var Msg: TWMChar);
          begin
            if (goEditing in Options) and (CharInSet(Char(Msg.CharCode),
                [^H]) or (Char(Msg.CharCode) >= #32)) then
              ShowEditorChar(Char(Msg.CharCode))
            else
              inherited;
          end;

          procedure TCustomGrid.WMCommand(var Message: TWMCommand);
          begin
            with Message do
            begin
              if (FInplaceEdit <> nil) and (Ctl = FInplaceEdit.Handle) then
                case NotifyCode of
                  EN_CHANGE:
                    UpdateText;
                end;
            end;
          end;

          procedure TCustomGrid.WMGetDlgCode(var Msg: TWMGetDlgCode);
          begin
            Msg.Result := DLGC_WANTARROWS;
            if goRowSelect in Options then
              Exit;
            if goTabs in Options then
              Msg.Result := Msg.Result or DLGC_WANTTAB;
            if goEditing in Options then
              Msg.Result := Msg.Result or DLGC_WANTCHARS;
          end;

          procedure TCustomGrid.WMKillFocus(var Msg: TWMKillFocus);
          begin
            inherited;
            DestroyCaret;
            InvalidateRect(Selection);
            if (FInplaceEdit <> nil) and
              (Msg.FocusedWnd <> FInplaceEdit.Handle) then
              HideEdit;
          end;

          procedure TCustomGrid.WMLButtonDown(var Message: TWMLButtonDown);
          begin
            inherited;
            if FInplaceEdit <> nil then
              FInplaceEdit.FClickTime := GetMessageTime;
          end;

          procedure TCustomGrid.WMNCHitTest(var Msg: TWMNCHitTest);
          begin
            DefaultHandler(Msg);
            FHitTest := ScreenToClient(SmallPointToPoint(Msg.Pos));
          end;

          procedure TCustomGrid.WMSetCursor(var Msg: TWMSetCursor);
          var
            DrawInfo: TGridDrawInfo;
            State: TGridState;
            Index: Longint;
            Pos, Ofs: Integer;
            Cur: HCURSOR;
          begin
            Cur := 0;
            with Msg do
            begin
              if HitTest = HTCLIENT then
              begin
                if FGridState = gsNormal then
                begin
                  CalcDrawInfo(DrawInfo);
                  CalcSizingState(FHitTest.X, FHitTest.Y, State, Index, Pos,
                    Ofs, DrawInfo);
                end
                else
                  State := FGridState;
                if State = gsRowSizing then
                  Cur := Screen.Cursors[crVSplit]
                else if State = gsColSizing then
                  Cur := Screen.Cursors[crHSplit]
              end;
            end;
            if Cur <> 0 then
              SetCursor(Cur)
            else
              inherited;
          end;

          procedure TCustomGrid.WMSetFocus(var Msg: TWMSetFocus);
          begin
            inherited;
            CreateCaret(Handle, 0, 0, 0);
            if (FInplaceEdit = nil) or (Msg.FocusedWnd <> FInplaceEdit.Handle)
              then
            begin
              InvalidateRect(Selection);
              UpdateEdit;
            end;
          end;

          procedure TCustomGrid.WMSize(var Msg: TWMSize);
          begin
            inherited;
            UpdateScrollRange;
            if UseRightToLeftAlignment then
              Invalidate;
          end;

          procedure TCustomGrid.WMVScroll(var Msg: TWMVScroll);
          begin
            ModifyScrollBar(SB_VERT, Msg.ScrollCode, Msg.Pos, True);
          end;

          procedure TCustomGrid.WMHScroll(var Msg: TWMHScroll);
          begin
            ModifyScrollBar(SB_HORZ, Msg.ScrollCode, Msg.Pos, True);
          end;

          procedure TCustomGrid.WMEraseBkgnd(var Message: TWMEraseBkgnd);
          var
            R: TRect;
            Size: TSize;
          begin
            { Fill the area between the two scroll bars. }
            Size.cx := GetSystemMetrics(SM_CXVSCROLL);
            Size.cy := GetSystemMetrics(SM_CYHSCROLL);
            if UseRightToLeftAlignment then
              R := Bounds(0, Height - Size.cy, Size.cx, Size.cy)
            else
              R := Bounds(Width - Size.cx, Height - Size.cy, Size.cx, Size.cy);
            FillRect(Message.DC, R, Brush.Handle);
            Message.Result := 1;
          end;

          procedure TCustomGrid.CancelMode;
          var
            DrawInfo: TGridDrawInfo;
          begin
            try
              case FGridState of
                gsSelecting:
                  KillTimer(Handle, 1);
                gsRowSizing, gsColSizing:
                  begin
                    CalcDrawInfo(DrawInfo);
                    DrawSizingLine(DrawInfo);
                  end;
                gsColMoving, gsRowMoving:
                  begin
                    DrawMove;
                    KillTimer(Handle, 1);
                  end;
              end;
            finally
              FGridState := gsNormal;
            end;
          end;

          procedure TCustomGrid.WMCancelMode(var Msg: TWMCancelMode);
          begin
            inherited;
            CancelMode;
          end;

          procedure TCustomGrid.CMCancelMode(var Msg: TCMCancelMode);
{$IF DEFINED(CLR)}
          var
            OrigMsg: TMessage;
{$IFEND}
          begin
            if Assigned(FInplaceEdit) then
            begin
{$IF DEFINED(CLR)}
              OrigMsg := Msg.OriginalMessage;
              FInplaceEdit.WndProc(OrigMsg);
{$ELSE}
              FInplaceEdit.WndProc(TMessage(Msg));
{$IFEND}
            end;
            inherited;
            CancelMode;
          end;

          procedure TCustomGrid.CMFontChanged(var Message: TMessage);
          begin
            if FInplaceEdit <> nil then
              FInplaceEdit.Font := Font;
            inherited;
          end;

          procedure TCustomGrid.CMMouseLeave(var Message: TMessage);
          begin
            inherited;
            if (FHotTrackCell.Coord.X <> -1) or (FHotTrackCell.Coord.Y <> -1)
              then
            begin
              InvalidateCell(FHotTrackCell.Coord.X, FHotTrackCell.Coord.Y);
              FHotTrackCell.Coord.X := -1;
              FHotTrackCell.Coord.Y := -1;
            end;
          end;

          procedure TCustomGrid.CMCtl3DChanged(var Message: TMessage);
          begin
            inherited;
            RecreateWnd;
          end;

          procedure TCustomGrid.CMDesignHitTest(var Msg: TCMDesignHitTest);
          begin
            Msg.Result := Longint(BOOL(Sizing(Msg.Pos.X, Msg.Pos.Y)));
          end;

          procedure TCustomGrid.CMWantSpecialKey(var Msg: TCMWantSpecialKey);
          begin
            inherited;
            if (goEditing in Options) and (Char(Msg.CharCode) = #13) then
              Msg.Result := 1;
          end;

          procedure TCustomGrid.TimedScroll(Direction: TGridScrollDirection);
          var
            MaxAnchor, NewAnchor: TGridCoord;
          begin
            NewAnchor := FAnchor;
            MaxAnchor.X := ColCount - 1;
            MaxAnchor.Y := RowCount - 1;
            if (sdLeft in Direction) and (FAnchor.X > FixedCols) then
              Dec(NewAnchor.X);
            if (sdRight in Direction) and (FAnchor.X < MaxAnchor.X) then
              Inc(NewAnchor.X);
            if (sdUp in Direction) and (FAnchor.Y > FixedRows) then
              Dec(NewAnchor.Y);
            if (sdDown in Direction) and (FAnchor.Y < MaxAnchor.Y) then
              Inc(NewAnchor.Y);
            if (FAnchor.X <> NewAnchor.X) or (FAnchor.Y <> NewAnchor.Y) then
              MoveAnchor(NewAnchor);
          end;

          procedure TCustomGrid.WMTimer(var Msg: TWMTimer);
          var
            Point: TPoint;
            DrawInfo: TGridDrawInfo;
            ScrollDirection: TGridScrollDirection;
            CellHit: TGridCoord;
            LeftSide: Integer;
            RightSide: Integer;
          begin
            if not(FGridState in [gsSelecting, gsRowMoving, gsColMoving]) then
              Exit;
            GetCursorPos(Point);
            Point := ScreenToClient(Point);
            CalcDrawInfo(DrawInfo);
            ScrollDirection := [];
            with DrawInfo do
            begin
              CellHit := CalcCoordFromPoint(Point.X, Point.Y, DrawInfo);
              case FGridState of
                gsColMoving:
                  MoveAndScroll(Point.X, CellHit.X, DrawInfo, Horz, SB_HORZ,
                    Point);
                gsRowMoving:
                  MoveAndScroll(Point.Y, CellHit.Y, DrawInfo, Vert, SB_VERT,
                    Point);
                gsSelecting:
                  begin
                    if not UseRightToLeftAlignment then
                    begin
                      if Point.X < Horz.FixedBoundary then
                        Include(ScrollDirection, sdLeft)
                      else if Point.X > Horz.FullVisBoundary then
                        Include(ScrollDirection, sdRight);
                    end
                    else
                    begin
                      LeftSide := ClientWidth - Horz.FullVisBoundary;
                      RightSide := ClientWidth - Horz.FixedBoundary;
                      if Point.X < LeftSide then
                        Include(ScrollDirection, sdRight)
                      else if Point.X > RightSide then
                        Include(ScrollDirection, sdLeft);
                    end;
                    if Point.Y < Vert.FixedBoundary then
                      Include(ScrollDirection, sdUp)
                    else if Point.Y > Vert.FullVisBoundary then
                      Include(ScrollDirection, sdDown);
                    if ScrollDirection <> [] then
                      TimedScroll(ScrollDirection);
                  end;
              end;
            end;
          end;

          procedure TCustomGrid.ColWidthsChanged;
          begin
            UpdateScrollRange;
            UpdateEdit;
          end;

          procedure TCustomGrid.RowHeightsChanged;
          begin
            UpdateScrollRange;
            UpdateEdit;
          end;

          procedure TCustomGrid.DeleteColumn(ACol: Longint);
          begin
            MoveColumn(ACol, ColCount - 1);
            ColCount := ColCount - 1;
          end;

          procedure TCustomGrid.DeleteRow(ARow: Longint);
          begin
            MoveRow(ARow, RowCount - 1);
            RowCount := RowCount - 1;
          end;

          procedure TCustomGrid.UpdateDesigner;
          var
            ParentForm: TCustomForm;
          begin
            if (csDesigning in ComponentState) and HandleAllocated and not
              (csUpdating in ComponentState) then
            begin
              ParentForm := GetParentForm(Self);
              if Assigned(ParentForm) and Assigned(ParentForm.Designer) then
                ParentForm.Designer.Modified;
            end;
          end;

          function TCustomGrid.DoMouseWheelDown(Shift: TShiftState;
            MousePos: TPoint): Boolean;
          begin
            Result := inherited DoMouseWheelDown(Shift, MousePos);
            if not Result then
            begin
              if Row < RowCount - 1 then
                Row := Row + 1;
              Result := True;
            end;
          end;

          function TCustomGrid.DoMouseWheelUp(Shift: TShiftState;
            MousePos: TPoint): Boolean;
          begin
            Result := inherited DoMouseWheelUp(Shift, MousePos);
            if not Result then
            begin
              if Row > FixedRows then
                Row := Row - 1;
              Result := True;
            end;
          end;

          function TCustomGrid.CheckColumnDrag(var Origin,
            Destination: Integer; const MousePt: TPoint): Boolean;
          begin
            Result := True;
          end;

          function TCustomGrid.CheckRowDrag(var Origin, Destination: Integer;
            const MousePt: TPoint): Boolean;
          begin
            Result := True;
          end;

          function TCustomGrid.BeginColumnDrag(var Origin,
            Destination: Integer; const MousePt: TPoint): Boolean;
          begin
            Result := True;
          end;

          function TCustomGrid.BeginRowDrag(var Origin, Destination: Integer;
            const MousePt: TPoint): Boolean;
          begin
            Result := True;
          end;

          function TCustomGrid.EndColumnDrag(var Origin, Destination: Integer;
            const MousePt: TPoint): Boolean;
          begin
            Result := True;
          end;

          function TCustomGrid.EndRowDrag(var Origin, Destination: Integer;
            const MousePt: TPoint): Boolean;
          begin
            Result := True;
          end;

          procedure TCustomGrid.CMShowingChanged(var Message: TMessage);
          begin
            inherited;
            if Showing then
              UpdateScrollRange;
          end;

        { TCustomDrawGrid }

          function TCustomDrawGrid.CellRect(ACol, ARow: Longint): TRect;
          begin
            Result := inherited CellRect(ACol, ARow);
          end;

          procedure TCustomDrawGrid.MouseToCell(X, Y: Integer;
            var ACol, ARow: Longint);
          var
            Coord: TGridCoord;
          begin
            Coord := MouseCoord(X, Y);
            ACol := Coord.X;
            ARow := Coord.Y;
          end;

          procedure TCustomDrawGrid.ColumnMoved(FromIndex, ToIndex: Longint);
          begin
            if Assigned(FOnColumnMoved) then
              FOnColumnMoved(Self, FromIndex, ToIndex);
          end;

          function TCustomDrawGrid.GetEditMask(ACol, ARow: Longint): string;
          begin
            Result := '';
            if Assigned(FOnGetEditMask) then
              FOnGetEditMask(Self, ACol, ARow, Result);
          end;

          function TCustomDrawGrid.GetEditText(ACol, ARow: Longint): string;
          begin
            Result := '';
            if Assigned(FOnGetEditText) then
              FOnGetEditText(Self, ACol, ARow, Result);
          end;

          procedure TCustomDrawGrid.RowMoved(FromIndex, ToIndex: Longint);
          begin
            if Assigned(FOnRowMoved) then
              FOnRowMoved(Self, FromIndex, ToIndex);
          end;

          function TCustomDrawGrid.SelectCell(ACol, ARow: Longint): Boolean;
          begin
            Result := True;
            if Assigned(FOnSelectCell) then
              FOnSelectCell(Self, ACol, ARow, Result);
          end;

          procedure TCustomDrawGrid.SetEditText(ACol, ARow: Longint;
            const Value: string);
          begin
            if Assigned(FOnSetEditText) then
              FOnSetEditText(Self, ACol, ARow, Value);
          end;

          procedure TCustomDrawGrid.DrawCell(ACol, ARow: Longint; ARect: TRect;
            AState: TGridDrawState);
          var
            Hold: Integer;
          begin
            if Assigned(FOnDrawCell) then
            begin
              if UseRightToLeftAlignment then
              begin
                ARect.Left := ClientWidth - ARect.Left;
                ARect.Right := ClientWidth - ARect.Right;
                Hold := ARect.Left;
                ARect.Left := ARect.Right;
                ARect.Right := Hold;
                ChangeGridOrientation(False);
              end;
              FOnDrawCell(Self, ACol, ARow, ARect, AState);
              if UseRightToLeftAlignment then
                ChangeGridOrientation(True);
            end;
          end;

          procedure TCustomDrawGrid.TopLeftChanged;
          begin
            inherited TopLeftChanged;
            if Assigned(FOnTopLeftChanged) then
              FOnTopLeftChanged(Self);
          end;

        { StrItem management for TStringSparseList }

        type
{$IF DEFINED(CLR)}
          TStrItem = class
            FObject: TObject;
            FString: string;
          end;

          TStrItemType = TStrItem;
{$ELSE}
          PStrItem = ^TStrItem;

          TStrItem = record
            FObject: TObject;
            FString: string;
          end;

          TStrItemType = PStrItem;
{$IFEND}
          function NewStrItem(const AString: string;
            AObject: TObject): TStrItemType;
          begin
{$IF DEFINED(CLR)}
            Result := TStrItem.Create;
{$ELSE}
            New(Result);
{$IFEND}
            Result.FObject := AObject;
            Result.FString := AString;
          end;
{$IF DEFINED(CLR)}
          procedure DisposeStrItem(var P: TStrItem);
          begin
            P.Free;
            P := nil;
          end;
{$ELSE}
          procedure DisposeStrItem(P: PStrItem);
          begin
            Dispose(P);
          end;
{$IFEND}
        { Sparse array classes for TStringGrid }

        type
          { Exception classes }

          EStringSparseListError = class(Exception);

            { TSparsePointerArray class }
{$IF DEFINED(CLR)}
            { Used by TSparseList.  Based on Sparse1Array, but has Object elements
              and Integer index, and less indirection }

            { Apply function for the applicator:
              TheIndex        Index of item in array
              TheItem         Value of item (i.e object) in section
              Returns: 0 if success, else error code. }
            TSPAApply = function(TheIndex: Integer; TheItem: TObject): Integer;

            TSectData = array of TObject;
            TSecDir = array of TSectData;
            TSecDirType = TSecDir;
{$ELSE}
            { Used by TSparseList.  Based on Sparse1Array, but has Pointer elements
              and Integer index, just like TPointerList/TList, and less indirection }

            { Apply function for the applicator:
              TheIndex        Index of item in array
              TheItem         Value of item (i.e pointer element) in section
              Returns: 0 if success, else error code. }
            TSPAApply = function(TheIndex: Integer; TheItem: Pointer): Integer;

            TSecDir = array [0 .. 4095] of Pointer;
            { Enough for up to 12 bits of sec }
            PSecDir = ^TSecDir;
            TSecDirType = PSecDir;
{$IFEND}
            TSPAQuantum = (SPASmall, SPALarge); { Section size }

            TSparsePointerArray = class(TObject)private secDir: TSecDirType;
            slotsInDir: Word;
            indexMask, secShift: Word;
            FHighBound: Integer;
            FSectionSize: Word;
            cachedIndex: Integer;
            cachedValue: TCustomData;
{$IF DEFINED(CLR)}
            FTemp: Integer; { temporary value storage }
{$IFEND}
            { Return item[i], nil if slot outside defined section. }
            function GetAt(Index: Integer): TCustomData;
            { Store item at item[i], creating slot if necessary. }
            procedure PutAt(Index: Integer; Item: TCustomData);
{$IF NOT DEFINED(CLR)}
            { Return address of item[i], creating slot if necessary. }
            function MakeAt(Index: Integer): PPointer;
{$ELSE}
            { callback that is passed to ForAll }
            function Detector(TheIndex: Integer; TheItem: TObject): Integer;
{$IFEND}
          public
            constructor Create(Quantum: TSPAQuantum);
            destructor Destroy; override;

            { Traverse SPA, calling apply function for each defined non-nil
              item.  The traversal terminates if the apply function returns
              a value other than 0. }
{$IF DEFINED(CLR)}
            // .NET: Must be a class member to have access to other class members
            function ForAll(ApplyFunction: TSPAApply): Integer;
{$ELSE}
            // WIN32: Must be static method so that we can take its address in TSparseList.ForAll
            function ForAll(ApplyFunction: Pointer { TSPAApply } ): Integer;
{$IFEND}
            { Ratchet down HighBound after a deletion }
            procedure ResetHighBound;

            property HighBound: Integer read FHighBound;
            property SectionSize: Word read FSectionSize;
            property Items[Index: Integer]: TCustomData read GetAt write PutAt;
            default;
          end;

          { TSparseList class }

          TSparseList = class(TObject)
          private
            FList: TSparsePointerArray;
            FCount: Integer; { 1 + HighBound, adjusted for Insert/Delete }
            FQuantum: TSPAQuantum;
            procedure NewList(Quantum: TSPAQuantum);
          protected
            function Get(Index: Integer): TCustomData;
            procedure Put(Index: Integer; Item: TCustomData);
          public
            constructor Create(Quantum: TSPAQuantum);
            destructor Destroy; override;
            procedure Clear;
            procedure Delete(Index: Integer);
            procedure Exchange(Index1, Index2: Integer);
            procedure Insert(Index: Integer; Item: TCustomData);
            procedure Move(CurIndex, NewIndex: Integer);
{$IF DEFINED(CLR)}
            function ForAll(ApplyFunction: TSPAApply): Integer;
{$ELSE}
            function ForAll(ApplyFunction: Pointer { TSPAApply } ): Integer;
{$IFEND}
            property Count: Integer read FCount;
            property Items[Index: Integer]: TCustomData read Get write Put;
            default;
          end;

          { TStringSparseList class }

          TStringSparseList = class(TStrings)
          private
            FList: TSparseList; { of StrItems }
            FOnChange: TNotifyEvent;
{$IF DEFINED(CLR)}
            FTempInt: Integer; { used during callbacks }
            FTempObject: TObject; { used during callbacks }
{$IFEND}
          protected
            // TStrings overrides
            function Get(Index: Integer): String; override;
            function GetCount: Integer; override;
            function GetObject(Index: Integer): TObject; override;
            procedure Put(Index: Integer; const S: String); override;
            procedure PutObject(Index: Integer; AObject: TObject); override;
            procedure Changed;
{$IF DEFINED(CLR)}
            // callbacks to pass to ForAll
            function CountItem(TheIndex: Integer; TheItem: TObject): Integer;
            function StoreItem(TheIndex: Integer; TheItem: TObject): Integer;
{$IFEND}
          public
            constructor Create(Quantum: TSPAQuantum);
            destructor Destroy; override;
            procedure ReadData(Reader: TReader);
            procedure WriteData(Writer: TWriter);
            procedure DefineProperties(Filer: TFiler); override;
            procedure Delete(Index: Integer); override;
            procedure Exchange(Index1, Index2: Integer); override;
            procedure Insert(Index: Integer; const S: String); override;
            procedure Clear; override;
            property List: TSparseList read FList;
            property OnChange: TNotifyEvent read FOnChange write FOnChange;
          end;

          { TSparsePointerArray }

        const
          SPAIndexMask: array [TSPAQuantum] of Byte = (15, 255);
          SPASecShift: array [TSPAQuantum] of Byte = (4, 8);

          { Expand Section Directory to cover at least `newSlots' slots. Returns: Possibly
            updated pointer to the Section Directory. }
          function ExpandDir(secDir: TSecDirType; var slotsInDir: Word;
            newSlots: Word): TSecDirType;
          begin
            Result := secDir;
{$IF DEFINED(CLR)}
            SetLength(Result, newSlots);
{$ELSE}
            ReallocMem(Result, newSlots * SizeOf(Pointer));
            FillChar(Result^[slotsInDir],
              (newSlots - slotsInDir) * SizeOf(Pointer), 0);
{$IFEND}
            slotsInDir := newSlots;
          end;

        { Allocate a section and set all its items to nil. Returns: Pointer to start of
          section. }
{$IF NOT DEFINED(CLR)}
          function MakeSec(SecIndex: Integer; SectionSize: Word): Pointer;
          var
            SecP: Pointer;
            Size: Word;
          begin
            Size := SectionSize * SizeOf(Pointer);
            GetMem(SecP, Size);
            FillChar(SecP^, Size, 0);
            MakeSec := SecP
          end;
{$IFEND}
          constructor TSparsePointerArray.Create(Quantum: TSPAQuantum);
          begin
{$IF DEFINED(CLR)}
            inherited Create;
            SetLength(secDir, 0);
{$ELSE}
            secDir := nil;
{$IFEND}
            slotsInDir := 0;
            FHighBound := -1;
            FSectionSize := Word(SPAIndexMask[Quantum]) + 1;
            indexMask := Word(SPAIndexMask[Quantum]);
            secShift := Word(SPASecShift[Quantum]);
            cachedIndex := -1
          end;

          destructor TSparsePointerArray.Destroy;
{$IF DEFINED(CLR)}
          var
            I: Integer;
          begin
            { Scan section directory and free each section that exists. }
            I := 0;
            while I < slotsInDir do
            begin
              if Length(secDir[I]) <> 0 then
                SetLength(secDir[I], 0);
              Inc(I)
            end;
            SetLength(secDir, 0);
            slotsInDir := 0;
{$ELSE}

            var
              I: Integer;
              Size: Word;
            begin
              { Scan section directory and free each section that exists. }
              I := 0;
              Size := FSectionSize * SizeOf(Pointer);
              while I < slotsInDir do
              begin
                if secDir^[I] <> nil then
                  FreeMem(secDir^[I], Size);
                Inc(I)
              end;

              { Free section directory. }
              if secDir <> nil then
                FreeMem(secDir, slotsInDir * SizeOf(Pointer));
{$IFEND}
            end;

            function TSparsePointerArray.GetAt(Index: Integer): TCustomData;
{$IF DEFINED(CLR)}
            var
              SecData: TSectData;
              SecIndex: Cardinal;
            begin
              if Index = cachedIndex then
                Result := cachedValue
              else
              begin
                { Index into Section Directory using high order part of
                  index.  Get pointer to Section. If not empty, index into
                  Section using low order part of index. }
                Result := nil;
                SecIndex := Index shr secShift;
                if SecIndex < slotsInDir then
                begin
                  SecData := secDir[SecIndex];
                  if Length(SecData) > 0 then
                    Result := SecData[(Index and indexMask)];
                end;
                cachedIndex := Index;
                cachedValue := Result
              end
{$ELSE}

              var
                byteP: PByte;
                SecIndex: Cardinal;
              begin
                { Index into Section Directory using high order part of
                  index.  Get pointer to Section. If not null, index into
                  Section using low order part of index. }
                if Index = cachedIndex then
                  Result := cachedValue
                else
                begin
                  SecIndex := Index shr secShift;
                  if SecIndex >= slotsInDir then
                    byteP := nil
                  else
                  begin
                    byteP := secDir^[SecIndex];
                    if byteP <> nil then
                    begin
                      Inc(byteP, (Index and indexMask) * SizeOf(Pointer));
                    end
                  end;
                  if byteP = nil then
                    Result := nil
                  else
                    Result := PPointer(byteP)^;
                  cachedIndex := Index;
                  cachedValue := Result
                end
{$IFEND}
              end;
{$IF NOT DEFINED(CLR)}

              function TSparsePointerArray.MakeAt(Index: Integer): PPointer;
              var
                dirP: PSecDir;
                P: Pointer;
                byteP: PByte;
                SecIndex: Word;
              begin
                { Expand Section Directory if necessary. }
                SecIndex := Index shr secShift; { Unsigned shift }
                if SecIndex >= slotsInDir then
                  dirP := ExpandDir(secDir, slotsInDir, SecIndex + 1)
                else
                  dirP := secDir;

                { Index into Section Directory using high order part of
                  index.  Get pointer to Section. If null, create new
                  Section.  Index into Section using low order part of index. }
                secDir := dirP;
                P := dirP^[SecIndex];
                if P = nil then
                begin
                  P := MakeSec(SecIndex, FSectionSize);
                  dirP^[SecIndex] := P
                end;
                byteP := P;
                Inc(byteP, (Index and indexMask) * SizeOf(Pointer));
                if Index > FHighBound then
                  FHighBound := Index;
                Result := PPointer(byteP);
                cachedIndex := -1
              end;
{$IFEND}

              procedure TSparsePointerArray.PutAt(Index: Integer;
                Item: TCustomData);
{$IF DEFINED(CLR)}
              var
                SecIndex: Word;
              begin
                if (Item <> nil) or (GetAt(Index) <> nil) then
                begin
                  { Expand Section Directory if necessary. }
                  SecIndex := Index shr secShift; { Unsigned shift }
                  if SecIndex >= slotsInDir then
                    secDir := ExpandDir(secDir, slotsInDir, SecIndex + 1);
                  { get the section and make sure it has enough slots }
                  if Length(secDir[SecIndex]) = 0 then
                    SetLength(secDir[SecIndex], FSectionSize);
                  secDir[SecIndex][(Index and indexMask)] := Item;
                  if Item = nil then
                    ResetHighBound
                  else if Index > FHighBound then
                    FHighBound := Index;
                  cachedIndex := Index;
                  cachedValue := Item
                end
{$ELSE}
                begin
                  if (Item <> nil) or (GetAt(Index) <> nil) then
                  begin
                    MakeAt(Index)^ := Item;
                    if Item = nil then
                      ResetHighBound
                  end
{$IFEND}
                end;
{$IF DEFINED(CLR)}

                function TSparsePointerArray.ForAll(ApplyFunction: TSPAApply)
                  : Integer;
                var
                  Section: TSectData;
                  Item: TObject;
                  I: Cardinal;
                  j, index: Integer;
                begin
                  Result := 0;
                  I := 0;
                  while (I < slotsInDir) and (Result = 0) do
                  begin
                    Section := secDir[I];
                    if Length(Section) <> 0 then
                    begin
                      j := 0;
                      index := I shl secShift;
                      while (j < FSectionSize) and (Result = 0) do
                      begin
                        Item := Section[j];
                        if Item <> nil then
                          Result := ApplyFunction(index, Item);
                        Inc(j);
                        Inc(index)
                      end
                    end;
                    Inc(I)
                  end;
                end;
{$ELSE}

                function TSparsePointerArray.ForAll(ApplyFunction: Pointer
                  { TSPAApply } ): Integer;
                var
                  itemP: PByte; { Pointer to item in section }
                  Item: Pointer;
                  I, callerBP: Cardinal;
                  j, index: Integer;
                begin
                  { Scan section directory and scan each section that exists,
                    calling the apply function for each non-nil item.
                    The apply function must be a far local function in the scope of
                    the procedure P calling ForAll.  The trick of setting up the stack
                    frame (taken from TurboVision's TCollection.ForEach) allows the
                    apply function access to P's arguments and local variables and,
                    if P is a method, the instance variables and methods of P's class }
                  Result := 0;
                  I := 0;
  asm
    mov   eax,[ebp]                     { Set up stack frame for local }
    mov   callerBP,eax
  end;
                  while (I < slotsInDir) and (Result = 0) do
                  begin
                    itemP := secDir^[I];
                    if itemP <> nil then
                    begin
                      j := 0;
                      index := I shl secShift;
                      while (j < FSectionSize) and (Result = 0) do
                      begin
                        Item := PPointer(itemP)^;
                        if Item <> nil then
                          { ret := ApplyFunction(index, item.Ptr); }
          asm
            mov   eax,index
            mov   edx,item
            push  callerBP
            call  ApplyFunction
            pop   ecx
            mov   @Result,eax
          end
                          ;
                        Inc(itemP, SizeOf(Pointer));
                        Inc(j);
                        Inc(index)
                      end
                    end;
                    Inc(I)
                  end;
                end;
{$IFEND}
{$IF DEFINED(CLR)}

                function TSparsePointerArray.Detector(TheIndex: Integer;
                  TheItem: TObject): Integer;
                begin
                  if TheIndex > FHighBound then
                    Result := 1
                  else
                  begin
                    Result := 0;
                    if TheItem <> nil then
                      FTemp := TheIndex
                  end
                end;
{$IFEND}

                procedure TSparsePointerArray.ResetHighBound;
{$IF NOT DEFINED(CLR)}
                var
                  NewHighBound: Integer;

                  function Detector(TheIndex: Integer;
                    TheItem: Pointer): Integer; far;
                  begin
                    if TheIndex > FHighBound then
                      Result := 1
                    else
                    begin
                      Result := 0;
                      if TheItem <> nil then
                        NewHighBound := TheIndex
                    end
                  end;

                begin
                  NewHighBound := -1;
                  ForAll(@Detector);
                  FHighBound := NewHighBound
                end;
{$ELSE}
                begin
                  FTemp := -1;
                  ForAll(@Detector);
                  FHighBound := FTemp
                end;
{$IFEND}
                { TSparseList }

                constructor TSparseList.Create(Quantum: TSPAQuantum);
                begin
                  inherited Create;
                  NewList(Quantum)
                end;

                destructor TSparseList.Destroy;
                begin
{$IF DEFINED(CLR)}
                  FreeAndNil(FList);
{$ELSE}
                  if FList <> nil then
                    FList.Destroy
{$IFEND}
                end;

                procedure TSparseList.Clear;
                begin
                  FList.Destroy;
                  NewList(FQuantum);
                  FCount := 0
                end;

                procedure TSparseList.Delete(Index: Integer);
                var
                  I: Integer;
                begin
                  if (Index < 0) or (Index >= FCount) then
                    Exit;
                  for I := Index to FCount - 1 do
                    FList[I] := FList[I + 1];
                  FList[FCount] := nil;
                  Dec(FCount);
                end;

                procedure TSparseList.Exchange(Index1, Index2: Integer);
                var
                  Temp: TCustomData;
                begin
                  Temp := Get(Index1);
                  Put(Index1, Get(Index2));
                  Put(Index2, Temp);
                end;
{$IF DEFINED(CLR)}

                function TSparseList.ForAll(ApplyFunction: TSPAApply): Integer;
                begin
                  Result := FList.ForAll(ApplyFunction);
                end;
{$ELSE}
                { Jump to TSparsePointerArray.ForAll so that it looks like it was called
                  from our caller, so that the BP trick works. }

                function TSparseList.ForAll(ApplyFunction: Pointer
                  { TSPAApply } ): Integer;
                assembler;
asm
        MOV     EAX,[EAX].TSparseList.FList
        JMP     TSparsePointerArray.ForAll
end;
{$IFEND}
                  function TSparseList.Get(Index: Integer): TCustomData;
                  begin
                    if Index < 0 then
                      TList.Error(SListIndexError, Index);
                    Result := FList[Index]
                  end;

                  procedure TSparseList.Insert(Index: Integer;
                    Item: TCustomData);
                  var
                    I: Integer;
                  begin
                    if Index < 0 then
                      TList.Error(SListIndexError, Index);
                    I := FCount;
                    while I > Index do
                    begin
                      FList[I] := FList[I - 1];
                      Dec(I)
                    end;
                    FList[Index] := Item;
                    if Index > FCount then
                      FCount := Index;
                    Inc(FCount)
                  end;

                  procedure TSparseList.Move(CurIndex, NewIndex: Integer);
                  var
                    Item: TCustomData;
                  begin
                    if CurIndex <> NewIndex then
                    begin
                      Item := Get(CurIndex);
                      Delete(CurIndex);
                      Insert(NewIndex, Item);
                    end;
                  end;

                  procedure TSparseList.NewList(Quantum: TSPAQuantum);
                  begin
                    FQuantum := Quantum;
                    FList := TSparsePointerArray.Create(Quantum)
                  end;

                  procedure TSparseList.Put(Index: Integer; Item: TCustomData);
                  begin
                    if Index < 0 then
                      TList.Error(SListIndexError, Index);
                    FList[Index] := Item;
                    FCount := FList.HighBound + 1
                  end;

                { TStringSparseList }

                  constructor TStringSparseList.Create(Quantum: TSPAQuantum);
                  begin
                    inherited Create;
                    FList := TSparseList.Create(Quantum)
                  end;

                  destructor TStringSparseList.Destroy;
                  begin
                    if FList <> nil then
                    begin
                      Clear;
                      FList.Destroy
                    end
                  end;

                  procedure TStringSparseList.ReadData(Reader: TReader);
                  var
                    I: Integer;
                  begin
                    with Reader do
                    begin
                      I := Integer(ReadInteger);
                      while I > 0 do
                      begin
                        InsertObject(Integer(ReadInteger), ReadString, nil);
                        Dec(I)
                      end
                    end
                  end;
{$IF DEFINED(CLR)}
                  function TStringSparseList.CountItem(TheIndex: Integer;
                    TheItem: TObject): Integer;
                  begin
                    Inc(FTempInt);
                    Result := 0
                  end;
{$IFEND}
{$IF DEFINED(CLR)}
                  function TStringSparseList.StoreItem(TheIndex: Integer;
                    TheItem: TObject): Integer;
                  begin
                    with FTempObject as TWriter do
                    begin
                      WriteInteger(TheIndex); { Item index }
                      WriteString(TStrItem(TheItem).FString);
                    end;
                    Result := 0
                  end;
{$IFEND}
                  procedure TStringSparseList.WriteData(Writer: TWriter);
{$IF NOT DEFINED(CLR)}
                  var
                    itemCount: Integer;

                    function CountItem(TheIndex: Integer;
                      TheItem: Pointer): Integer; far;
                    begin
                      Inc(itemCount);
                      Result := 0
                    end;

                    function StoreItem(TheIndex: Integer;
                      TheItem: Pointer): Integer; far;
                    begin
                      with Writer do
                      begin
                        WriteInteger(TheIndex); { Item index }
                        WriteString(PStrItem(TheItem)^.FString);
                      end;
                      Result := 0
                    end;
{$IFEND}

                  begin
{$IF DEFINED(CLR)}
                    FTempInt := 0;
                    FTempObject := Writer;
                    FList.ForAll(@CountItem);
                    Writer.WriteInteger(FTempInt);
                    FList.ForAll(@StoreItem);
{$ELSE}
                    with Writer do
                    begin
                      itemCount := 0;
                      FList.ForAll(@CountItem);
                      WriteInteger(itemCount);
                      FList.ForAll(@StoreItem);
                    end
{$IFEND}
                  end;

                  procedure TStringSparseList.DefineProperties(Filer: TFiler);
                  begin
                    Filer.DefineProperty('List', ReadData, WriteData, True);
                  end;

                  function TStringSparseList.Get(Index: Integer): String;
                  var
                    P: TStrItemType;
                  begin
                    P := TStrItemType(FList[Index]);
                    if P = nil then
                      Result := ''
                    else
                      Result := P.FString
                  end;

                  function TStringSparseList.GetCount: Integer;
                  begin
                    Result := FList.Count
                  end;

                  function TStringSparseList.GetObject(Index: Integer): TObject;
                  var
                    P: TStrItemType;
                  begin
                    P := TStrItemType(FList[Index]);
                    if P = nil then
                      Result := nil
                    else
                      Result := P.FObject
                  end;

                  procedure TStringSparseList.Put(Index: Integer;
                    const S: String);
                  var
                    P: TStrItemType;
                    obj: TObject;
                  begin
                    P := TStrItemType(FList[Index]);
                    if P = nil then
                      obj := nil
                    else
                      obj := P.FObject;
                    if (S = '') and (obj = nil) then { Nothing left to store }
                      FList[Index] := nil
                    else
                      FList[Index] := NewStrItem(S, obj);
                    if P <> nil then
                      DisposeStrItem(P);
                    Changed
                  end;

                  procedure TStringSparseList.PutObject(Index: Integer;
                    AObject: TObject);
                  var
                    P: TStrItemType;
                  begin
                    P := TStrItemType(FList[Index]);
                    if P <> nil then
                      P.FObject := AObject
                    else if AObject <> nil then
                      FList[Index] := NewStrItem('', AObject);
                    Changed
                  end;

                  procedure TStringSparseList.Changed;
                  begin
                    if Assigned(FOnChange) then
                      FOnChange(Self)
                  end;

                  procedure TStringSparseList.Delete(Index: Integer);
                  var
                    P: TStrItemType;
                  begin
                    P := TStrItemType(FList[Index]);
                    if P <> nil then
                      DisposeStrItem(P);
                    FList.Delete(Index);
                    Changed
                  end;

                  procedure TStringSparseList.Exchange(Index1, Index2: Integer);
                  begin
                    FList.Exchange(Index1, Index2);
                  end;

                  procedure TStringSparseList.Insert(Index: Integer;
                    const S: String);
                  begin
                    FList.Insert(Index, NewStrItem(S, nil));
                    Changed
                  end;
{$IF DEFINED(CLR)}
                  function ClearItem(TheIndex: Integer;
                    TheItem: TObject): Integer;
                  begin
                    TheItem.Free;
                    Result := 0
                  end;
{$IFEND}
                  procedure TStringSparseList.Clear;
{$IF NOT DEFINED(CLR)}
                    function ClearItem(TheIndex: Integer;
                      TheItem: Pointer): Integer; far;
                    begin
                      DisposeStrItem(PStrItem(TheItem));
                      { Item guaranteed non-nil }
                      Result := 0
                    end;
{$IFEND}

                  begin
                    FList.ForAll(@ClearItem);
                    FList.Clear;
                    Changed
                  end;

                { TStringGridStrings }

                { AIndex < 0 is a column (for column -AIndex - 1)
                  AIndex > 0 is a row (for row AIndex - 1)
                  AIndex = 0 denotes an empty row or column }

                  constructor TStringGridStrings.Create(AGrid: TStringGrid;
                    AIndex: Longint);
                  begin
                    inherited Create;
                    FGrid := AGrid;
                    FIndex := AIndex;
                  end;

                  procedure TStringGridStrings.Assign(Source: TPersistent);
                  var
                    I, Max: Integer;
                  begin
                    if Source is TStrings then
                    begin
                      BeginUpdate;
                      Max := TStrings(Source).Count - 1;
                      if Max >= Count then
                        Max := Count - 1;
                      try
                        for I := 0 to Max do
                        begin
                          Put(I, TStrings(Source).Strings[I]);
                          PutObject(I, TStrings(Source).Objects[I]);
                        end;
                      finally
                        EndUpdate;
                      end;
                      Exit;
                    end;
                    inherited Assign(Source);
                  end;

                  procedure TStringGridStrings.CalcXY(Index: Integer;
                    var X, Y: Integer);
                  begin
                    if FIndex = 0 then
                    begin
                      X := -1;
                      Y := -1;
                    end
                    else if FIndex > 0 then
                    begin
                      X := Index;
                      Y := FIndex - 1;
                    end
                    else
                    begin
                      X := -FIndex - 1;
                      Y := Index;
                    end;
                  end;

                { Changes the meaning of Add to mean copy to the first empty string }
                  function TStringGridStrings.Add(const S: string): Integer;
                  var
                    I: Integer;
                  begin
                    for I := 0 to Count - 1 do
                      if Strings[I] = '' then
                      begin
                        if S = '' then
                          Strings[I] := ' '
                        else
                          Strings[I] := S;
                        Result := I;
                        Exit;
                      end;
                    Result := -1;
                  end;
{$IF DEFINED(CLR)}
                  function TStringGridStrings.BlankStr(TheIndex: Integer;
                    TheItem: TObject): Integer;
                  begin
                    Objects[TheIndex] := nil;
                    Strings[TheIndex] := '';
                    Result := 0;
                  end;
{$IFEND}
                  procedure TStringGridStrings.Clear;
                  var
                    SSList: TStringSparseList;
                    I: Integer;
{$IF NOT DEFINED(CLR)}
                    function BlankStr(TheIndex: Integer;
                      TheItem: Pointer): Integer; far;
                    begin
                      Objects[TheIndex] := nil;
                      Strings[TheIndex] := '';
                      Result := 0;
                    end;
{$IFEND}

                  begin
                    if FIndex > 0 then
                    begin
                      SSList := TStringSparseList
                        (TSparseList(FGrid.FData)[FIndex - 1]);
                      if SSList <> nil then
                        SSList.List.ForAll(@BlankStr);
                    end
                    else if FIndex < 0 then
                      for I := Count - 1 downto 0 do
                      begin
                        Objects[I] := nil;
                        Strings[I] := '';
                      end;
                  end;

                  procedure TStringGridStrings.Delete(Index: Integer);
                  begin
                    InvalidOp(sInvalidStringGridOp);
                  end;

                  function TStringGridStrings.Get(Index: Integer): string;
                  var
                    X, Y: Integer;
                  begin
                    CalcXY(Index, X, Y);
                    if X < 0 then
                      Result := ''
                    else
                      Result := FGrid.Cells[X, Y];
                  end;

                  function TStringGridStrings.GetCount: Integer;
                  begin
                    { Count of a row is the column count, and vice versa }
                    if FIndex = 0 then
                      Result := 0
                    else if FIndex > 0 then
                      Result := Integer(FGrid.ColCount)
                    else
                      Result := Integer(FGrid.RowCount);
                  end;

                  function TStringGridStrings.GetObject(Index: Integer)
                    : TObject;
                  var
                    X, Y: Integer;
                  begin
                    CalcXY(Index, X, Y);
                    if X < 0 then
                      Result := nil
                    else
                      Result := FGrid.Objects[X, Y];
                  end;

                  procedure TStringGridStrings.Insert(Index: Integer;
                    const S: string);
                  begin
                    InvalidOp(sInvalidStringGridOp);
                  end;

                  procedure TStringGridStrings.Put(Index: Integer;
                    const S: string);
                  var
                    X, Y: Integer;
                  begin
                    CalcXY(Index, X, Y);
                    FGrid.Cells[X, Y] := S;
                  end;

                  procedure TStringGridStrings.PutObject(Index: Integer;
                    AObject: TObject);
                  var
                    X, Y: Integer;
                  begin
                    CalcXY(Index, X, Y);
                    FGrid.Objects[X, Y] := AObject;
                  end;

                  procedure TStringGridStrings.SetUpdateState
                    (Updating: Boolean);
                  begin
                    FGrid.SetUpdateState(Updating);
                  end;

                { TStringGrid }

                  constructor TStringGrid.Create(AOwner: TComponent);
                  begin
                    inherited Create(AOwner);
                    Initialize;
                  end;
{$IF DEFINED(CLR)}
                  function FreeItem(TheIndex: Integer;
                    TheItem: TObject): Integer;
                  begin
                    TheItem.Free;
                    Result := 0;
                  end;
{$IFEND}
                  destructor TStringGrid.Destroy;
{$IF NOT DEFINED(CLR)}
                    function FreeItem(TheIndex: Integer;
                      TheItem: Pointer): Integer; far;
                    begin
                      TObject(TheItem).Free;
                      Result := 0;
                    end;
{$IFEND}

                  begin
                    if FRows <> nil then
                    begin
                      TSparseList(FRows).ForAll(@FreeItem);
                      TSparseList(FRows).Free;
                    end;
                    if FCols <> nil then
                    begin
                      TSparseList(FCols).ForAll(@FreeItem);
                      TSparseList(FCols).Free;
                    end;
                    if FData <> nil then
                    begin
                      TSparseList(FData).ForAll(@FreeItem);
                      TSparseList(FData).Free;
                    end;
                    inherited Destroy;
                  end;
{$IF DEFINED(CLR)}
                  function TStringGrid.MoveColData(Index: Integer;
                    ARow: TObject): Integer;
                  begin
                    TStringSparseList(ARow).Move(FTempFrom, FTempTo);
                    Result := 0;
                  end;
{$IFEND}
                  procedure TStringGrid.ColumnMoved(FromIndex,
                    ToIndex: Longint);
{$IF NOT DEFINED(CLR)}
                    function MoveColData(Index: Integer;
                      ARow: TStringSparseList): Integer; far;
                    begin
                      ARow.Move(FromIndex, ToIndex);
                      Result := 0;
                    end;
{$IFEND}

                  begin
{$IF DEFINED(CLR)}
                    FTempFrom := FromIndex;
                    FTempTo := ToIndex;
{$IFEND}
                    TSparseList(FData).ForAll(@MoveColData);
                    Invalidate;
                    inherited ColumnMoved(FromIndex, ToIndex);
                  end;

                  procedure TStringGrid.RowMoved(FromIndex, ToIndex: Longint);
                  begin
                    TSparseList(FData).Move(FromIndex, ToIndex);
                    Invalidate;
                    inherited RowMoved(FromIndex, ToIndex);
                  end;

                  function TStringGrid.GetEditText(ACol, ARow: Longint): string;
                  begin
                    Result := Cells[ACol, ARow];
                    if Assigned(FOnGetEditText) then
                      FOnGetEditText(Self, ACol, ARow, Result);
                  end;

                  procedure TStringGrid.SetEditText(ACol, ARow: Longint;
                    const Value: string);
                  begin
                    DisableEditUpdate;
                    try
                      if Value <> Cells[ACol, ARow] then
                        Cells[ACol, ARow] := Value;
                    finally
                      EnableEditUpdate;
                    end;
                    inherited SetEditText(ACol, ARow, Value);
                  end;

                  procedure TStringGrid.DrawCell(ACol, ARow: Longint;
                    ARect: TRect; AState: TGridDrawState);

                      procedure DrawCheck( Canvas: TCanvas; Value: Boolean );
                      var DrawState: Integer;
                          LRect : TRect;
                          LTheme: HTHEME;
                      begin
                        LRect := Classes.Rect( 0, 0, 16, 16 );
                        with ARect do
                          OffsetRect( LRect, (Left + Right - LRect.Right) div 2,
                            (Top + Bottom - LRect.Bottom) div 2 );


                        if (Win32MajorVersion >= 6) then
                        begin
                          if Value then
                            DrawState := CBS_CHECKEDNORMAL
                          else
                            DrawState := CBS_UNCHECKEDNORMAL;
                          LTheme := ThemeServices.Theme[teButton];
                          DrawThemeBackground( LTheme, Canvas.Handle, BP_CHECKBOX, DrawState,
                            LRect, {$IFNDEF CLR}@{$ENDIF}LRect);
                        end else
                        begin
                          if Value then
                            DrawState := DFCS_BUTTONCHECK or DFCS_CHECKED
                          else
                            DrawState := DFCS_BUTTONCHECK ;
                          DrawFrameControl(Canvas.Handle, LRect, DFC_BUTTON, DrawState);
                        end;
                     end;

                  begin
                    if DefaultDrawing then
                      if FCheckboxes and (ACol = 0) and (ARow > 0)
                      and (Cells[ACol,Arow] <> '') then
                        DrawCheck(Canvas, StrToBool(Cells[ACol,Arow]))
                      else
                        Canvas.TextRect(ARect, ARect.Left + 2, ARect.Top + 2,
                          Cells[ACol, ARow]);
                    inherited DrawCell(ACol, ARow, ARect, AState);
                  end;

                  procedure TStringGrid.DisableEditUpdate;
                  begin
                    Inc(FEditUpdate);
                  end;

                  procedure TStringGrid.EnableEditUpdate;
                  begin
                    Dec(FEditUpdate);
                  end;

                  procedure TStringGrid.Initialize;
                  var
                    Quantum: TSPAQuantum;
                  begin
                    FAutoRepaint := True;
                    FCheckboxes := false;
                    if FCols = nil then
                    begin
                      if ColCount > 512 then
                        Quantum := SPALarge
                      else
                        Quantum := SPASmall;
                      FCols := TSparseList.Create(Quantum);
                    end;
                    if RowCount > 256 then
                      Quantum := SPALarge
                    else
                      Quantum := SPASmall;
                    if FRows = nil then
                      FRows := TSparseList.Create(Quantum);
                    if FData = nil then
                      FData := TSparseList.Create(Quantum);
                  end;

                  procedure TStringGrid.SetUpdateState(Updating: Boolean);
                  begin
                    FUpdating := Updating;
                    if not Updating and FNeedsUpdating then
                    begin
                      InvalidateGrid;
                      FNeedsUpdating := False;
                    end;
                  end;

                  procedure TStringGrid.Update(ACol, ARow: Integer);
                  begin
                    if FAutoRepaint then
                      if not FUpdating then
                        InvalidateCell(ACol, ARow)
                      else
                        FNeedsUpdating := True;
                      if (ACol = Col) and (ARow = Row) and (FEditUpdate = 0) then
                        InvalidateEditor;
                  end;

                  function TStringGrid.EnsureColRow(Index: Integer;
                    IsCol: Boolean): TStringGridStrings;
{$IF DEFINED(CLR)}
                  var
                    RCIndex: Integer;
                    List: TSparseList;
                  begin
                    if IsCol then
                      List := TSparseList(FCols)
                    else
                      List := TSparseList(FRows);
                    Result := TStringGridStrings(List[Index]);
                    if Result = nil then
                    begin
                      if IsCol then
                        RCIndex := -Index - 1
                      else
                        RCIndex := Index + 1;
                      Result := TStringGridStrings.Create(Self, RCIndex);
                      List[Index] := Result;
                    end;
{$ELSE}

                    var
                      RCIndex: Integer;
                      PList: ^TSparseList;
                    begin
                      if IsCol then
                        PList := @FCols
                      else
                        PList := @FRows;
                      Result := TStringGridStrings(PList^[Index]);
                      if Result = nil then
                      begin
                        if IsCol then
                          RCIndex := -Index - 1
                        else
                          RCIndex := Index + 1;
                        Result := TStringGridStrings.Create(Self, RCIndex);
                        PList^[Index] := Result;
                      end;
{$IFEND}
                    end;

                    function TStringGrid.EnsureDataRow(ARow: Integer)
                      : TCustomData;
                    var
                      Quantum: TSPAQuantum;
                    begin
{$IF DEFINED(CLR)}
                      Result := TSparseList(FData)[ARow];
{$ELSE}
                      Result := TStringSparseList(TSparseList(FData)[ARow]);
{$IFEND}
                      if Result = nil then
                      begin
                        if ColCount > 512 then
                          Quantum := SPALarge
                        else
                          Quantum := SPASmall;
                        Result := TStringSparseList.Create(Quantum);
                        TSparseList(FData)[ARow] := Result;
                      end;
                    end;

                    function TStringGrid.GetCells(ACol, ARow: Integer): string;
                    var
                      ssl: TStringSparseList;
                    begin
                      ssl := TStringSparseList(TSparseList(FData)[ARow]);
                      if ssl = nil then
                        Result := ''
                      else
                        Result := ssl[ACol];
                    end;

                    function TStringGrid.GetCols(Index: Integer): TStrings;
                    begin
                      Result := EnsureColRow(Index, True);
                    end;

                    function TStringGrid.GetObjects(ACol, ARow: Integer)
                      : TObject;
                    var
                      ssl: TStringSparseList;
                    begin
                      ssl := TStringSparseList(TSparseList(FData)[ARow]);
                      if ssl = nil then
                        Result := nil
                      else
                        Result := ssl.Objects[ACol];
                    end;

                    function TStringGrid.GetRows(Index: Integer): TStrings;
                    begin
                      Result := EnsureColRow(Index, False);
                    end;

                    procedure TStringGrid.SetCells(ACol, ARow: Integer;
                      const Value: string);
                    begin
{$IF DEFINED(CLR)}
                      TStringSparseList(EnsureDataRow(ARow))[ACol] := Value;
{$ELSE}
                      TStringGridStrings(EnsureDataRow(ARow))[ACol] := Value;
{$IFEND}
                      EnsureColRow(ACol, True);
                      EnsureColRow(ARow, False);
                      Update(ACol, ARow);
                    end;

                    procedure TStringGrid.SetCols(Index: Integer;
                      Value: TStrings);
                    begin
                      EnsureColRow(Index, True).Assign(Value);
                    end;

                    procedure TStringGrid.SetObjects(ACol, ARow: Integer;
                      Value: TObject);
                    begin
{$IF DEFINED(CLR)}
                      TStringSparseList(EnsureDataRow(ARow)).Objects[ACol] :=
                        Value;
{$ELSE}
                      TStringGridStrings(EnsureDataRow(ARow)).Objects[ACol] :=
                        Value;
{$IFEND}
                      EnsureColRow(ACol, True);
                      EnsureColRow(ARow, False);
                      Update(ACol, ARow);
                    end;

                    procedure TStringGrid.SetRows(Index: Integer;
                      Value: TStrings);
                    begin
                      EnsureColRow(Index, False).Assign(Value);
                    end;

                    type

                      { TPopupListbox }

                      TPopupListbox = class(TCustomListbox)
                      private
                        FSearchText: String;
                        FSearchTickCount: Longint;
                      protected
                        procedure CreateParams(var Params: TCreateParams);
                          override;
                        procedure CreateWnd; override;
                        procedure KeyPress(var Key: Char); override;
                        procedure MouseUp(Button: TMouseButton;
                          Shift: TShiftState; X, Y: Integer); override;
                      end;

                    procedure TPopupListbox.CreateParams
                      (var Params: TCreateParams);
                    begin
                      inherited CreateParams(Params);
                      with Params do
                      begin
                        Style := Style or WS_BORDER;
                        ExStyle := WS_EX_TOOLWINDOW or WS_EX_TOPMOST;
                        AddBiDiModeExStyle(ExStyle);
                        WindowClass.Style := CS_SAVEBITS;
                      end;
                    end;

                    [UIPermission(SecurityAction.LinkDemand,
                      Window = UIPermissionWindow.AllWindows)]

                    procedure TPopupListbox.CreateWnd;
                    begin
                      inherited CreateWnd;
                      Windows.SetParent(Handle, 0);
                      CallWindowProc(DefWndProc, Handle, WM_SETFOCUS, 0, 0);
                    end;

                    procedure TPopupListbox.KeyPress(var Key: Char);
                    var
                      TickCount: Integer;
                    begin
                      case Key of
                        #8, #27:
                          FSearchText := '';
                        #32 .. High(Char):
                          begin
                            TickCount := GetTickCount;
                            if TickCount - FSearchTickCount > 2000 then
                              FSearchText := '';
                            FSearchTickCount := TickCount;
                            if Length(FSearchText) < 32 then
                              FSearchText := FSearchText + Key;
                            SendTextMessage(Handle, LB_SelectString, Word(-1),
                              FSearchText);
                            Key := #0;
                          end;
                      end;
                      inherited KeyPress(Key);
                    end;

                    procedure TPopupListbox.MouseUp(Button: TMouseButton;
                      Shift: TShiftState; X, Y: Integer);
                    begin
                      inherited MouseUp(Button, Shift, X, Y);
                      TInplaceEditList(Owner).CloseUp
                        ((X >= 0) and (Y >= 0) and (X < Width) and
                          (Y < Height));
                    end;

                    { TInplaceEditList }

                    constructor TInplaceEditList.Create(Owner: TComponent);
                    begin
                      inherited Create(Owner);
                      FButtonWidth := GetSystemMetrics(SM_CXVSCROLL);
                      FEditStyle := esSimple;
                    end;

                    procedure TInplaceEditList.BoundsChanged;
                    var
                      R: TRect;
                    begin
                      SetRect(R, 2, 2, Width - 2, Height);
                      if EditStyle <> esSimple then
                        if not Grid.UseRightToLeftAlignment then
                          Dec(R.Right, ButtonWidth)
                        else
                          Inc(R.Left, ButtonWidth - 2);
                      SendStructMessage(Handle, EM_SETRECTNP, 0, R);
                      SendMessage(Handle, EM_SCROLLCARET, 0, 0);
                      if SysLocale.FarEast then
                        SetImeCompositionWindow(Font, R.Left, R.Top);
                    end;

                    procedure TInplaceEditList.CloseUp(Accept: Boolean);
                    var
                      ListValue: Variant;
                    begin
                      if ListVisible and (ActiveList = FPickList) then
                      begin
                        if GetCapture <> 0 then
                          SendMessage(GetCapture, WM_CANCELMODE, 0, 0);
                        if PickList.ItemIndex <> -1 then
{$IF DEFINED(CLR)}
                          ListValue := PickList.Items[PickList.ItemIndex]
                        else
                          ListValue := Unassigned;
{$ELSE}
                        ListValue := PickList.Items[PickList.ItemIndex];
{$IFEND}
                        SetWindowPos(ActiveList.Handle, 0, 0, 0, 0, 0,
                          SWP_NOZORDER or SWP_NOMOVE or SWP_NOSIZE or
                            SWP_NOACTIVATE or SWP_HIDEWINDOW);
                        FListVisible := False;
                        Invalidate;
                        if Accept then
                          if (not VarIsEmpty(ListValue) or VarIsNull(ListValue)
                            ) and (VarToStr(ListValue) <> Text) then
                          begin
                            { Here we store the new value directly in the edit control so that
                              we bypass the CMTextChanged method on TCustomMaskedEdit.  This
                              preserves the old value so that we can restore it later by calling
                              the Reset method. }
{$IF DEFINED(CLR)}
                            Perform(WM_SETTEXT, 0, VarToStr(ListValue));
{$ELSE}
                            Perform(WM_SETTEXT, 0, Longint(string(ListValue)));
{$IFEND}
                            Modified := True;
                            with Grid do
                              SetEditText(Col, Row, VarToStr(ListValue));
                          end;
                      end;
                    end;

                    procedure TInplaceEditList.DoDropDownKeys(var Key: Word;
                      Shift: TShiftState);
                    begin
                      case Key of
                        VK_UP, VK_DOWN:
                          if ssAlt in Shift then
                          begin
                            if ListVisible then
                              CloseUp(True)
                            else
                              DropDown;
                            Key := 0;
                          end;
                        VK_RETURN, VK_ESCAPE:
                          if ListVisible and not(ssAlt in Shift) then
                          begin
                            CloseUp(Key = VK_RETURN);
                            Key := 0;
                          end;
                      end;
                    end;

                    procedure TInplaceEditList.DoEditButtonClick;
                    begin
                      if Assigned(FOnEditButtonClick) then
                        FOnEditButtonClick(Grid);
                    end;

                    procedure TInplaceEditList.DoGetPickListItems;
                    begin
                      if not PickListLoaded then
                      begin
                        if Assigned(OnGetPickListitems) then
                          OnGetPickListitems(Grid.Col, Grid.Row,
                            PickList.Items);
                        PickListLoaded := (PickList.Items.Count > 0);
                      end;
                    end;

                    function TInplaceEditList.GetPickList: TCustomListbox;
                    var
                      PopupListbox: TPopupListbox;
                    begin
                      if not Assigned(FPickList) then
                      begin
                        PopupListbox := TPopupListbox.Create(Self);
                        PopupListbox.Visible := False;
                        PopupListbox.Parent := Self;
                        PopupListbox.OnMouseUp := ListMouseUp;
                        PopupListbox.IntegralHeight := True;
                        PopupListbox.ItemHeight := 11;
                        FPickList := PopupListbox;
                      end;
                      Result := FPickList;
                    end;

                    procedure TInplaceEditList.DropDown;
                    var
                      P: TPoint;
                      I, j, Y: Integer;
                    begin
                      if not ListVisible then
                      begin
                        ActiveList.Width := Width;
                        if ActiveList = FPickList then
                        begin
                          DoGetPickListItems;
                          TPopupListbox(PickList).Color := Color;
                          TPopupListbox(PickList).Font := Font;
                          if (DropDownRows > 0) and
                            (PickList.Items.Count >= DropDownRows) then
                            PickList.Height := DropDownRows * TPopupListbox
                              (PickList).ItemHeight + 4
                          else
                            PickList.Height := PickList.Items.Count *
                              TPopupListbox(PickList).ItemHeight + 4;
                          if Text = '' then
                            PickList.ItemIndex := -1
                          else
                            PickList.ItemIndex := PickList.Items.IndexOf(Text);
                          j := PickList.ClientWidth;
                          for I := 0 to PickList.Items.Count - 1 do
                          begin
                            Y := PickList.Canvas.TextWidth(PickList.Items[I]);
                            if Y > j then
                              j := Y;
                          end;
                          PickList.ClientWidth := j;
                        end;
                        P := Parent.ClientToScreen(Point(Left, Top));
                        Y := P.Y + Height;
                        if Y + ActiveList.Height > Screen.Height then
                          Y := P.Y - ActiveList.Height;
                        SetWindowPos(ActiveList.Handle, HWND_TOP, P.X, Y, 0, 0,
                          SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW);
                        FListVisible := True;
                        Invalidate;
                        Windows.SetFocus(Handle);
                      end;
                    end;

                    procedure TInplaceEditList.KeyDown(var Key: Word;
                      Shift: TShiftState);
                    begin
                      if (EditStyle = esEllipsis) and (Key = VK_RETURN) and
                        (Shift = [ssCtrl]) then
                      begin
                        DoEditButtonClick;
                        KillMessage(Handle, WM_CHAR);
                      end
                      else
                        inherited KeyDown(Key, Shift);
                    end;

                    procedure TInplaceEditList.ListMouseUp(Sender: TObject;
                      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
                    begin
                      if Button = mbLeft then
                        CloseUp(PtInRect(ActiveList.ClientRect, Point(X, Y)));
                    end;

                    procedure TInplaceEditList.MouseDown(Button: TMouseButton;
                      Shift: TShiftState; X, Y: Integer);
                    begin
                      if (Button = mbLeft) and (EditStyle <> esSimple)
                        and OverButton(Point(X, Y)) then
                      begin
                        if ListVisible then
                          CloseUp(False)
                        else
                        begin
                          MouseCapture := True;
                          FTracking := True;
                          TrackButton(X, Y);
                          if Assigned(ActiveList) then
                            DropDown;
                        end;
                      end;
                      inherited MouseDown(Button, Shift, X, Y);
                    end;

                    procedure TInplaceEditList.MouseMove(Shift: TShiftState;
                      X, Y: Integer);
                    var
                      ListPos: TPoint;
                    begin
                      if FTracking then
                      begin
                        TrackButton(X, Y);
                        if ListVisible then
                        begin
                          ListPos := ActiveList.ScreenToClient
                            (ClientToScreen(Point(X, Y)));
                          if PtInRect(ActiveList.ClientRect, ListPos) then
                          begin
                            StopTracking;
                            SendMessage(ActiveList.Handle, WM_LBUTTONDOWN, 0,
                              PointToLParam(ListPos));
                            Exit;
                          end;
                        end;
                      end;
                      inherited MouseMove(Shift, X, Y);
                    end;

                    procedure TInplaceEditList.MouseUp(Button: TMouseButton;
                      Shift: TShiftState; X, Y: Integer);
                    var
                      WasPressed: Boolean;
                    begin
                      WasPressed := Pressed;
                      StopTracking;
                      if (Button = mbLeft) and (EditStyle = esEllipsis)
                        and WasPressed then
                        DoEditButtonClick;
                      inherited MouseUp(Button, Shift, X, Y);
                    end;

                    procedure TInplaceEditList.PaintWindow(DC: HDC);
                    var
                      R: TRect;
                      Flags: Integer;
                      W, X, Y: Integer;
                      Details: TThemedElementDetails;
                    begin
                      if EditStyle <> esSimple then
                      begin
                        R := ButtonRect;
                        Flags := 0;
                        case EditStyle of
                          esPickList:
                            begin
                              if ThemeServices.ThemesEnabled then
                              begin
                                if ActiveList = nil then
                                  Details := ThemeServices.GetElementDetails
                                    (tcDropDownButtonDisabled)
                                else if Pressed then
                                  Details := ThemeServices.GetElementDetails
                                    (tcDropDownButtonPressed)
                                else if FMouseInControl then
                                  Details := ThemeServices.GetElementDetails
                                    (tcDropDownButtonHot)
                                else
                                  Details := ThemeServices.GetElementDetails
                                    (tcDropDownButtonNormal);
                                ThemeServices.DrawElement(DC, Details, R);
                              end
                              else
                              begin
                                if ActiveList = nil then
                                  Flags := DFCS_INACTIVE
                                else if Pressed then
                                  Flags := DFCS_FLAT or DFCS_PUSHED;
                                DrawFrameControl(DC, R, DFC_SCROLL,
                                  Flags or DFCS_SCROLLCOMBOBOX);
                              end;
                            end;
                          esEllipsis:
                            begin
                              if ThemeServices.ThemesEnabled then
                              begin
                                if Pressed then
                                  Details := ThemeServices.GetElementDetails
                                    (tbPushButtonPressed)
                                else if FMouseInControl then
                                  Details := ThemeServices.GetElementDetails
                                    (tbPushButtonHot)
                                else
                                  Details := ThemeServices.GetElementDetails
                                    (tbPushButtonNormal);
                                ThemeServices.DrawElement(DC, Details, R);
                              end
                              else
                              begin
                                if Pressed then
                                  Flags := BF_FLAT;
                                DrawEdge(DC, R, EDGE_RAISED,
                                  BF_RECT or BF_MIDDLE or Flags);
                              end;

                              X := R.Left + ((R.Right - R.Left) shr 1) - 1 + Ord
                                (Pressed);
                              Y := R.Top + ((R.Bottom - R.Top) shr 1) - 1 + Ord
                                (Pressed);
                              W := ButtonWidth shr 3;
                              if W = 0 then
                                W := 1;
                              PatBlt(DC, X, Y, W, W, BLACKNESS);
                              PatBlt(DC, X - (W * 2), Y, W, W, BLACKNESS);
                              PatBlt(DC, X + (W * 2), Y, W, W, BLACKNESS);
                            end;
                        end;
                        ExcludeClipRect(DC, R.Left, R.Top, R.Right, R.Bottom);
                      end;
                      inherited PaintWindow(DC);
                    end;

                    procedure TInplaceEditList.StopTracking;
                    begin
                      if FTracking then
                      begin
                        TrackButton(-1, -1);
                        FTracking := False;
                        MouseCapture := False;
                      end;
                    end;

                    procedure TInplaceEditList.TrackButton(X, Y: Integer);
                    var
                      NewState: Boolean;
                      R: TRect;
                    begin
                      R := ButtonRect;
                      NewState := PtInRect(R, Point(X, Y));
                      if Pressed <> NewState then
                      begin
                        FPressed := NewState;
                        InvalidateRect(Handle, R, False);
                      end;
                    end;

                    procedure TInplaceEditList.UpdateContents;
                    begin
                      ActiveList := nil;
                      PickListLoaded := False;
                      FEditStyle := Grid.GetEditStyle(Grid.Col, Grid.Row);
                      if EditStyle = esPickList then
                        ActiveList := PickList;
                      inherited UpdateContents;
                    end;

                    procedure TInplaceEditList.RestoreContents;
                    begin
                      Reset;
                      Grid.UpdateText;
                    end;

                    procedure TInplaceEditList.CMCancelMode
                      (var Message: TCMCancelMode);
                    begin
                      if (Message.Sender <> Self) and
                        (Message.Sender <> ActiveList) then
                        CloseUp(False);
                    end;

                    procedure TInplaceEditList.WMCancelMode
                      (var Message: TWMCancelMode);
                    begin
                      StopTracking;
                      inherited;
                    end;

                    procedure TInplaceEditList.WMKillFocus
                      (var Message: TWMKillFocus);
                    begin
                      if not SysLocale.FarEast then
                      begin
                        inherited;
                      end
                      else
                      begin
                        ImeName := Screen.DefaultIme;
                        ImeMode := imDontCare;
                        inherited;
                        if HWnd(Message.FocusedWnd) <> Grid.Handle then
                          ActivateKeyboardLayout(Screen.DefaultKbLayout,
                            KLF_ACTIVATE);
                      end;
                      CloseUp(False);
                    end;

                    function TInplaceEditList.ButtonRect: TRect;
                    begin
                      if not Grid.UseRightToLeftAlignment then
                        Result := Rect(Width - ButtonWidth, 0, Width, Height)
                      else
                        Result := Rect(0, 0, ButtonWidth, Height);
                    end;

                    function TInplaceEditList.OverButton(const P: TPoint)
                      : Boolean;
                    begin
                      Result := PtInRect(ButtonRect, P);
                    end;

                    procedure TInplaceEditList.WMLButtonDblClk
                      (var Message: TWMLButtonDblClk);
                    begin
                      with Message do
                        if (EditStyle <> esSimple) and OverButton
                          (Point(XPos, YPos)) then
                          Exit;
                      inherited;
                    end;

                    procedure TInplaceEditList.WMPaint(var Message: TWMPaint);
                    begin
                      PaintHandler(Message);
                    end;

                    procedure TInplaceEditList.WMSetCursor
                      (var Message: TWMSetCursor);
                    var
                      P: TPoint;
                    begin
                      GetCursorPos(P);
                      P := ScreenToClient(P);
                      if (EditStyle <> esSimple) and OverButton(P) then
                        Windows.SetCursor(LoadCursor(0, idc_Arrow))
                      else
                        inherited;
                    end;

                    procedure TInplaceEditList.WndProc(var Message: TMessage);
                    var
                      TheChar: Word;
                    begin
                      case Message.Msg of
                        wm_KeyDown, wm_SysKeyDown, WM_CHAR:
                          if EditStyle = esPickList then
                            with TWMKey(Message) do
                            begin
                              TheChar := CharCode;
                              DoDropDownKeys(TheChar,
                                KeyDataToShiftState(KeyData));
                              CharCode := TheChar;
                              if (CharCode <> 0) and ListVisible then
                              begin
                                with Message do
                                  SendMessage(ActiveList.Handle, Msg, wparam,
                                    LParam);
                                Exit;
                              end;
                            end
                      end;
                      inherited;
                    end;

                    procedure TInplaceEditList.DblClick;
                    var
                      Index: Integer;
                      ListValue: string;
                    begin
                      if (EditStyle = esSimple) or Assigned(Grid.OnDblClick)
                        then
                        inherited
                      else if (EditStyle = esPickList) and
                        (ActiveList = PickList) then
                      begin
                        DoGetPickListItems;
                        if PickList.Items.Count > 0 then
                        begin
                          Index := PickList.ItemIndex + 1;
                          if Index >= PickList.Items.Count then
                            Index := 0;
                          PickList.ItemIndex := Index;
                          ListValue := PickList.Items[PickList.ItemIndex];
{$IF DEFINED(CLR)}
                          Perform(WM_SETTEXT, 0, ListValue);
{$ELSE}
                          Perform(WM_SETTEXT, 0, Longint(ListValue));
{$IFEND}
                          Modified := True;
                          with Grid do
                            SetEditText(Col, Row, ListValue);
                          SelectAll;
                        end;
                      end
                      else if EditStyle = esEllipsis then
                        DoEditButtonClick;
                    end;

                    procedure TInplaceEditList.CMMouseEnter
                      (var Message: TMessage);
                    begin
                      inherited;

                      if ThemeServices.ThemesEnabled and not FMouseInControl
                        then
                      begin
                        FMouseInControl := True;
                        Invalidate;
                      end;
                    end;

                    procedure TInplaceEditList.CMMouseLeave
                      (var Message: TMessage);
                    begin
                      inherited;
                      if ThemeServices.ThemesEnabled and FMouseInControl then
                      begin
                        FMouseInControl := False;
                        Invalidate;
                      end;
                    end;

end.
