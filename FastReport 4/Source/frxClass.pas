
{******************************************}
{                                          }
{             FastReport v4.0              }
{             Report classes               }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxClass;

interface

{$I frx.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs,
  IniFiles, ExtCtrls, Printers, frxVariables, frxXML, frxProgress,
  fs_iinterpreter, frxUnicodeUtils
{$IFDEF Delphi6}
, Variants
{$ENDIF}
,  SyncObjs
;

const
  fr01cm: Extended = 3.77953;
  fr1cm: Extended = 37.7953;
  fr01in: Extended = 9.6;
  fr1in: Integer = 96;
  fr1CharX: Extended = 9.6;
  fr1CharY: Integer = 17;
  clTransparent: TColor = clNone;
  crHand: Integer = 150;
  crZoom: Integer = 151;
  crFormat: Integer = 152;
  DEF_REG_CONNECTIONS: String = '\Software\Fast Reports\Connections';
  WM_CREATEHANDLE = WM_USER + 1;
  WM_DESTROYHANDLE = WM_USER + 2;
  
type
  TfrxReport = class;
  TfrxPage = class;
  TfrxReportPage = class;
  TfrxDialogPage = class;
  TfrxCustomEngine = class;
  TfrxCustomDesigner = class;
  TfrxCustomPreview = class;
  TfrxCustomPreviewPages = class;
  TfrxComponent = class;
  TfrxReportComponent = class;
  TfrxView = class;
  TfrxStyleItem = class;
  TfrxCustomExportFilter = class;
  TfrxCustomCompressor = class;
  TfrxCustomDatabase = class;
  TfrxFrame = class;

  TfrxNotifyEvent = type String;
  TfrxCloseQueryEvent = type String;
  TfrxKeyEvent = type String;
  TfrxKeyPressEvent = type String;
  TfrxMouseEvent = type String;
  TfrxMouseMoveEvent = type String;
  TfrxPreviewClickEvent = type String;
  TfrxRunDialogsEvent = type String;

  SYSINT = Integer;

  TfrxComponentStyle = set of (csContainer, csPreviewVisible, csDefaultDiff);
  TfrxStretchMode = (smDontStretch, smActualHeight, smMaxHeight);
  TfrxShiftMode = (smDontShift, smAlways, smWhenOverlapped);
  TfrxDuplexMode = (dmNone, dmVertical, dmHorizontal, dmSimplex);

  TfrxAlign = (baNone, baLeft, baRight, baCenter, baWidth, baBottom, baClient);

  TfrxFrameStyle = (fsSolid, fsDash, fsDot, fsDashDot, fsDashDotDot, fsDouble);

  TfrxFrameType = (ftLeft, ftRight, ftTop, ftBottom);
  TfrxFrameTypes = set of TfrxFrameType;

  TfrxFormatKind = (fkText, fkNumeric, fkDateTime, fkBoolean);

  TfrxHAlign = (haLeft, haRight, haCenter, haBlock);
  TfrxVAlign = (vaTop, vaBottom, vaCenter);

  TfrxSilentMode = (simMessageBoxes, simSilent, simReThrow);
  TfrxRestriction = (rfDontModify, rfDontSize, rfDontMove, rfDontDelete, rfDontEdit);
  TfrxRestrictions = set of TfrxRestriction;

  TfrxShapeKind = (skRectangle, skRoundRectangle, skEllipse, skTriangle,
    skDiamond, skDiagonal1, skDiagonal2);

  TfrxPreviewButton = (pbPrint, pbLoad, pbSave, pbExport, pbZoom, pbFind,
    pbOutline, pbPageSetup, pbTools, pbEdit, pbNavigator, pbExportQuick,
    pbNoClose);
  TfrxPreviewButtons = set of TfrxPreviewButton;
  TfrxZoomMode = (zmDefault, zmWholePage, zmPageWidth, zmManyPages);
  TfrxPrintPages = (ppAll, ppOdd, ppEven);
  TfrxAddPageAction = (apWriteOver, apAdd);
  TfrxRangeBegin = (rbFirst, rbCurrent);
  TfrxRangeEnd = (reLast, reCurrent, reCount);
  TfrxFieldType = (fftNumeric, fftString, fftBoolean);
  TfrxProgressType = (ptRunning, ptExporting, ptPrinting);
  TfrxPrintMode = (pmDefault, pmSplit, pmJoin, pmScale);

  TfrxRect = packed record
    Left, Top, Right, Bottom: Extended;
  end;

  TfrxPoint = packed record
    X, Y: Extended;
  end;

  TfrxProgressEvent = procedure(Sender: TfrxReport;
    ProgressType: TfrxProgressType; Progress: Integer) of object;
  TfrxBeforePrintEvent = procedure(Sender: TfrxReportComponent) of object;
  TfrxGetValueEvent = procedure(const VarName: String; var Value: Variant) of object;
  TfrxUserFunctionEvent = function(const MethodName: String;
    var Params: Variant): Variant of object;
  TfrxManualBuildEvent = procedure(Page: TfrxPage) of object;
  TfrxClickObjectEvent = procedure(Sender: TfrxView;
    Button: TMouseButton; Shift: TShiftState; var Modified: Boolean) of object;
  TfrxMouseOverObjectEvent = procedure(Sender: TfrxView) of object;
  TfrxCheckEOFEvent = procedure(Sender: TObject; var Eof: Boolean) of object;
  TfrxRunDialogEvent = procedure(Page: TfrxDialogPage) of object;
  TfrxEditConnectionEvent = function(const ConnString: String): String of object;
  TfrxSetConnectionEvent = procedure(const ConnString: String) of object;
  TfrxBeforeConnectEvent = procedure(Sender: TfrxCustomDatabase; var Connected: Boolean) of object;
  TfrxPrintPageEvent = procedure(Page: TfrxReportPage; CopyNo: Integer) of object;
  TfrxLoadTemplateEvent = procedure(Report: TfrxReport; const TemplateName: String) of object;

{ Root classes }


  TfrxComponent = class(TComponent)
  private
    FFont: TFont;

    FObjects: TList;
    FAllObjects: TList;
    FParent: TfrxComponent;
    FLeft: Extended;
    FTop: Extended;
    FWidth: Extended;
    FHeight: Extended;
    FParentFont: Boolean;
    FGroupIndex: Integer;
    FIsDesigning: Boolean;
    FIsLoading: Boolean;
    FIsPrinting: Boolean;
    FIsWriting: Boolean;
    FRestrictions: TfrxRestrictions;
    FVisible: Boolean;
    FDescription: String;
    FAncestor: Boolean;
    FComponentStyle: TfrxComponentStyle;
    function GetAbsTop: Extended;
    function GetPage: TfrxPage;
    function GetReport: TfrxReport;
    function IsFontStored: Boolean;
    function GetAllObjects: TList;
    function GetAbsLeft: Extended;
    function GetIsLoading: Boolean;
    function GetIsAncestor: Boolean;
  protected
    FAliasName: String;
    FBaseName: String;
    FOriginalComponent: TfrxComponent;
    FOriginalRect: TfrxRect;
    FOriginalBand: TfrxComponent;
    procedure SetParent(AParent: TfrxComponent); virtual;
    procedure SetLeft(Value: Extended); virtual;
    procedure SetTop(Value: Extended); virtual;
    procedure SetWidth(Value: Extended); virtual;
    procedure SetHeight(Value: Extended); virtual;
    procedure SetName(const AName: TComponentName); override;
    procedure SetFont(Value: TFont); virtual;
    procedure SetParentFont(const Value: Boolean); virtual;
    procedure SetVisible(Value: Boolean); virtual;
    procedure FontChanged(Sender: TObject); virtual;
    function DiffFont(f1, f2: TFont; const Add: String): String;
    function InternalDiff(AComponent: TfrxComponent): String;
    function GetContainerObjects: TList; virtual;

    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    function GetChildOwner: TComponent; override;
  public
    constructor Create(AOwner: TComponent); override;
    constructor DesignCreate(AOwner: TComponent; Flags: Word); virtual;
    destructor Destroy; override;
    class function GetDescription: String; virtual;
    procedure AlignChildren; virtual;
    procedure Assign(Source: TPersistent); override;
    procedure AssignAll(Source: TfrxComponent);
    procedure BeforeStartReport; virtual;
    procedure Clear; virtual;
    procedure CreateUniqueName;
    procedure LoadFromStream(Stream: TStream); virtual;
    procedure SaveToStream(Stream: TStream; SaveChildren: Boolean = True;
      SaveDefaultValues: Boolean = False); virtual;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Extended);
    procedure OnNotify(Sender: TObject); virtual;
    procedure OnPaste; virtual;
    function AllDiff(AComponent: TfrxComponent): String;
    function Diff(AComponent: TfrxComponent): String; virtual;
    function FindObject(const AName: String): TfrxComponent;
    function ContainerAdd(Obj: TfrxComponent): Boolean; virtual;
    function ContainerMouseDown(Sender: TObject; X, Y: Integer): Boolean; virtual;
    procedure ContainerMouseMove(Sender: TObject; X, Y: Integer); virtual;
    procedure ContainerMouseUp(Sender: TObject; X, Y: Integer); virtual;

    property Objects: TList read FObjects;
    property AllObjects: TList read GetAllObjects;
    property ContainerObjects: TList read GetContainerObjects;
    property Parent: TfrxComponent read FParent write SetParent;
    property Page: TfrxPage read GetPage;
    property Report: TfrxReport read GetReport;
    property IsAncestor: Boolean read GetIsAncestor;
    property IsDesigning: Boolean read FIsDesigning write FIsDesigning;
    property IsLoading: Boolean read GetIsLoading write FIsLoading;
    property IsPrinting: Boolean read FIsPrinting write FIsPrinting;
    property IsWriting: Boolean read FIsWriting write FIsWriting;
    property BaseName: String read FBaseName;
    property GroupIndex: Integer read FGroupIndex write FGroupIndex default 0;
    property frComponentStyle: TfrxComponentStyle read FComponentStyle write FComponentStyle;

    property Left: Extended read FLeft write SetLeft;
    property Top: Extended read FTop write SetTop;
    property Width: Extended read FWidth write SetWidth;
    property Height: Extended read FHeight write SetHeight;
    property AbsLeft: Extended read GetAbsLeft;
    property AbsTop: Extended read GetAbsTop;

    property Description: String read FDescription write FDescription;
    property ParentFont: Boolean read FParentFont write SetParentFont default True;
    property Restrictions: TfrxRestrictions read FRestrictions write FRestrictions default [];
    property Visible: Boolean read FVisible write SetVisible default True;

    property Font: TFont read FFont write SetFont stored IsFontStored;

  end;

  TfrxReportComponent = class(TfrxComponent)
  private
    FOnAfterData: TfrxNotifyEvent;
    FOnAfterPrint: TfrxNotifyEvent;
    FOnBeforePrint: TfrxNotifyEvent;
    FOnPreviewClick: TfrxPreviewClickEvent;
  public
    FShiftAmount: Extended;
    FShiftChildren: TList;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended);
      virtual; abstract;
    procedure BeforePrint; virtual;
    procedure GetData; virtual;
    procedure AfterPrint; virtual;
    function GetComponentText: String; virtual;
    function GetRealBounds: TfrxRect; virtual;
    property OnAfterData: TfrxNotifyEvent read FOnAfterData write FOnAfterData;
    property OnAfterPrint: TfrxNotifyEvent read FOnAfterPrint write FOnAfterPrint;
    property OnBeforePrint: TfrxNotifyEvent read FOnBeforePrint write FOnBeforePrint;
    property OnPreviewClick: TfrxPreviewClickEvent read FOnPreviewClick write FOnPreviewClick;
  published
    property Description;
  end;

  TfrxDialogComponent = class(TfrxReportComponent)
  private
    FBitmap: TBitmap;
    FComponent: TComponent;
    procedure ReadLeft(Reader: TReader);
    procedure ReadTop(Reader: TReader);
    procedure WriteLeft(Writer: TWriter);
    procedure WriteTop(Writer: TWriter);
  protected
    FImageIndex: Integer;
    procedure DefineProperties(Filer: TFiler); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended); override;
    property Bitmap: TBitmap read FBitmap;
    property Component: TComponent read FComponent write FComponent;
  end;

  TfrxDialogControl = class(TfrxReportComponent)
  private
    FControl: TControl;
    FOnClick: TfrxNotifyEvent;
    FOnDblClick: TfrxNotifyEvent;
    FOnEnter: TfrxNotifyEvent;
    FOnExit: TfrxNotifyEvent;
    FOnKeyDown: TfrxKeyEvent;
    FOnKeyPress: TfrxKeyPressEvent;
    FOnKeyUp: TfrxKeyEvent;
    FOnMouseDown: TfrxMouseEvent;
    FOnMouseMove: TfrxMouseMoveEvent;
    FOnMouseUp: TfrxMouseEvent;
    function GetColor: TColor;
    function GetEnabled: Boolean;
    procedure DoOnClick(Sender: TObject);
    procedure DoOnDblClick(Sender: TObject);
    procedure DoOnEnter(Sender: TObject);
    procedure DoOnExit(Sender: TObject);
    procedure DoOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DoOnKeyPress(Sender: TObject; var Key: Char);
    procedure DoOnKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DoOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DoOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DoOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SetColor(const Value: TColor);
    procedure SetEnabled(const Value: Boolean);
    function GetCaption: String;
    procedure SetCaption(const Value: String);
    function GetHint: String;
    procedure SetHint(const Value: String);
    function GetTabStop: Boolean;
    procedure SetTabStop(const Value: Boolean);
  protected
    procedure SetLeft(Value: Extended); override;
    procedure SetTop(Value: Extended); override;
    procedure SetWidth(Value: Extended); override;
    procedure SetHeight(Value: Extended); override;
    procedure SetParentFont(const Value: Boolean); override;
    procedure SetVisible(Value: Boolean); override;
    procedure SetParent(AParent: TfrxComponent); override;
    procedure FontChanged(Sender: TObject); override;
    procedure InitControl(AControl: TControl);
    procedure SetName(const AName: TComponentName); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended); override;

    property Caption: String read GetCaption write SetCaption;
    property Color: TColor read GetColor write SetColor;
    property Control: TControl read FControl write FControl;
    property TabStop: Boolean read GetTabStop write SetTabStop default True;
    property OnClick: TfrxNotifyEvent read FOnClick write FOnClick;
    property OnDblClick: TfrxNotifyEvent read FOnDblClick write FOnDblClick;
    property OnEnter: TfrxNotifyEvent read FOnEnter write FOnEnter;
    property OnExit: TfrxNotifyEvent read FOnExit write FOnExit;
    property OnKeyDown: TfrxKeyEvent read FOnKeyDown write FOnKeyDown;
    property OnKeyPress: TfrxKeyPressEvent read FOnKeyPress write FOnKeyPress;
    property OnKeyUp: TfrxKeyEvent read FOnKeyUp write FOnKeyUp;
    property OnMouseDown: TfrxMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseMove: TfrxMouseMoveEvent read FOnMouseMove write FOnMouseMove;
    property OnMouseUp: TfrxMouseEvent read FOnMouseUp write FOnMouseUp;
  published
    property Left;
    property Top;
    property Width;
    property Height;
    property Font;
    property GroupIndex;
    property ParentFont;
    property Enabled: Boolean read GetEnabled write SetEnabled default True;
    property Hint: String read GetHint write SetHint;
    property Visible;
  end;


  TfrxDataSet = class(TfrxDialogComponent)

  private
    FCloseDataSource: Boolean;
    FEnabled: Boolean;
    FOpenDataSource: Boolean;
    FRangeBegin: TfrxRangeBegin;
    FRangeEnd: TfrxRangeEnd;
    FRangeEndCount: Integer;
    FReportRef: TfrxReport;
    FUserName: String;
    FOnCheckEOF: TfrxCheckEOFEvent;
    FOnFirst: TNotifyEvent;
    FOnNext: TNotifyEvent;
    FOnPrior: TNotifyEvent;
    FOnOpen: TNotifyEvent;
    FOnClose: TNotifyEvent;
  protected
    FInitialized: Boolean;
    FRecNo: Integer;
    function GetDisplayText(Index: String): WideString; virtual;
    function GetDisplayWidth(Index: String): Integer; virtual;
    function GetFieldType(Index: String): TfrxFieldType; virtual;
    function GetValue(Index: String): Variant; virtual;
    procedure SetName(const NewName: TComponentName); override;
    procedure SetUserName(const Value: String); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    { Navigation methods }
    procedure Initialize; virtual;
    procedure Finalize; virtual;
    procedure Open; virtual;
    procedure Close; virtual;
    procedure First; virtual;
    procedure Next; virtual;
    procedure Prior; virtual;
    function Eof: Boolean; virtual;

    { Data access }
    function FieldsCount: Integer; virtual;
    function HasField(const fName: String): Boolean;
    function IsBlobField(const fName: String): Boolean; virtual;
    function RecordCount: Integer; virtual;
    procedure AssignBlobTo(const fName: String; Obj: TObject); virtual;
    procedure GetFieldList(List: TStrings); virtual;
    property DisplayText[Index: String]: WideString read GetDisplayText;
    property DisplayWidth[Index: String]: Integer read GetDisplayWidth;
    property FieldType[Index: String]: TfrxFieldType read GetFieldType;
    property Value[Index: String]: Variant read GetValue;

    property CloseDataSource: Boolean read FCloseDataSource write FCloseDataSource;
    { OpenDataSource is kept for backward compatibility only }
    property OpenDataSource: Boolean read FOpenDataSource write FOpenDataSource default True;
    property RecNo: Integer read FRecNo;
    property ReportRef: TfrxReport read FReportRef write FReportRef;
    property OnClose: TNotifyEvent read FOnClose write FOnClose;
    property OnOpen: TNotifyEvent read FOnOpen write FOnOpen;
  published
    property Enabled: Boolean read FEnabled write FEnabled default True;
    property RangeBegin: TfrxRangeBegin read FRangeBegin write FRangeBegin default rbFirst;
    property RangeEnd: TfrxRangeEnd read FRangeEnd write FRangeEnd default reLast;
    property RangeEndCount: Integer read FRangeEndCount write FRangeEndCount default 0;
    property UserName: String read FUserName write SetUserName;
    property OnCheckEOF: TfrxCheckEOFEvent read FOnCheckEOF write FOnCheckEOF;
    property OnFirst: TNotifyEvent read FOnFirst write FOnFirst;
    property OnNext: TNotifyEvent read FOnNext write FOnNext;
    property OnPrior: TNotifyEvent read FOnPrior write FOnPrior;

  end;


  TfrxUserDataSet = class(TfrxDataset)
  private

    FFields: TStrings;
    FOnGetValue: TfrxGetValueEvent;
    procedure SetFields(const Value: TStrings);
  protected
    function GetDisplayText(Index: String): WideString; override;
    function GetValue(Index: String): Variant; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function FieldsCount: Integer; override;
    procedure GetFieldList(List: TStrings); override;
  published
    property Fields: TStrings read FFields write SetFields;
    property OnGetValue: TfrxGetValueEvent read FOnGetValue write FOnGetValue;

  end;

  TfrxCustomDBDataSet = class(TfrxDataSet)
  private
    FAliases: TStrings;
    FFields: TStringList;
    procedure SetFieldAliases(const Value: TStrings);
  protected
    property Fields: TStringList read FFields;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ConvertAlias(const fName: String): String;
    function GetAlias(const fName: String): String;
    function FieldsCount: Integer; override;
  published
    property CloseDataSource;
    property FieldAliases: TStrings read FAliases write SetFieldAliases;
    property OpenDataSource;
    property OnClose;
    property OnOpen;
  end;


  TfrxDBComponents = class(TComponent)
  public
    function GetDescription: String; virtual;
  end;

  TfrxCustomDatabase = class(TfrxDialogComponent)
  protected
    procedure BeforeConnect(var Value: Boolean);
    procedure SetConnected(Value: Boolean); virtual;
    procedure SetDatabaseName(const Value: String); virtual;
    procedure SetLoginPrompt(Value: Boolean); virtual;
    procedure SetParams(Value: TStrings); virtual;
    function GetConnected: Boolean; virtual;
    function GetDatabaseName: String; virtual;
    function GetLoginPrompt: Boolean; virtual;
    function GetParams: TStrings; virtual;
  public
    procedure SetLogin(const Login, Password: String); virtual;
    property Connected: Boolean read GetConnected write SetConnected default False;
    property DatabaseName: String read GetDatabaseName write SetDatabaseName;
    property LoginPrompt: Boolean read GetLoginPrompt write SetLoginPrompt default True;
    property Params: TStrings read GetParams write SetParams;
  end;


  TfrxComponentClass = class of TfrxComponent;

{ Report Objects }

  TfrxFrameLine = class(TPersistent)
  private
    FFrame: TfrxFrame;
    FColor: TColor;
    FStyle: TfrxFrameStyle;
    FWidth: Extended;
    function IsColorStored: Boolean;
    function IsStyleStored: Boolean;
    function IsWidthStored: Boolean;
  public
    constructor Create(AFrame: TfrxFrame);
    procedure Assign(Source: TPersistent); override;
    function Diff(ALine: TfrxFrameLine; const LineName: String): String;
  published
    property Color: TColor read FColor write FColor stored IsColorStored;
    property Style: TfrxFrameStyle read FStyle write FStyle stored IsStyleStored;
    property Width: Extended read FWidth write FWidth stored IsWidthStored;
  end;


  TfrxFrame = class(TPersistent)
  private

  private
    FLeftLine: TfrxFrameLine;
    FTopLine: TfrxFrameLine;
    FRightLine: TfrxFrameLine;
    FBottomLine: TfrxFrameLine;
    FColor: TColor;
    FDropShadow: Boolean;
    FShadowWidth: Extended;
    FShadowColor: TColor;
    FStyle: TfrxFrameStyle;
    FTyp: TfrxFrameTypes;
    FWidth: Extended;
    function IsShadowWidthStored: Boolean;
    function IsTypStored: Boolean;
    function IsWidthStored: Boolean;
    procedure SetBottomLine(const Value: TfrxFrameLine);
    procedure SetLeftLine(const Value: TfrxFrameLine);
    procedure SetRightLine(const Value: TfrxFrameLine);
    procedure SetTopLine(const Value: TfrxFrameLine);
    procedure SetColor(const Value: TColor);
    procedure SetStyle(const Value: TfrxFrameStyle);
    procedure SetWidth(const Value: Extended);

  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function Diff(AFrame: TfrxFrame): String;
  published
    property Color: TColor read FColor write SetColor default clBlack;
    property DropShadow: Boolean read FDropShadow write FDropShadow default False;
    property ShadowColor: TColor read FShadowColor write FShadowColor default clBlack;
    property ShadowWidth: Extended read FShadowWidth write FShadowWidth stored IsShadowWidthStored;
    property Style: TfrxFrameStyle read FStyle write SetStyle default fsSolid;
    property Typ: TfrxFrameTypes read FTyp write FTyp stored IsTypStored;
    property Width: Extended read FWidth write SetWidth stored IsWidthStored;
    property LeftLine: TfrxFrameLine read FLeftLine write SetLeftLine;
    property TopLine: TfrxFrameLine read FTopLine write SetTopLine;
    property RightLine: TfrxFrameLine read FRightLine write SetRightLine;
    property BottomLine: TfrxFrameLine read FBottomLine write SetBottomLine;
  end;


 TfrxView = class(TfrxReportComponent)

  private
    FAlign: TfrxAlign;
    FBrushStyle: TBrushStyle;
    FColor: TColor;
    FCursor: TCursor;
    FDataField: String;
    FDataSet: TfrxDataSet;
    FDataSetName: String;
    FFrame: TfrxFrame;
    FPrintable: Boolean;
    FShiftMode: TfrxShiftMode;
    FTagStr: String;
    FTempTag: String;
    FTempURL: String;
    FURL: String;
    FPlainText: Boolean;
    procedure SetFrame(const Value: TfrxFrame);
    procedure SetDataSet(const Value: TfrxDataSet);
    procedure SetDataSetName(const Value: String);
    function GetDataSetName: String;
  protected
    FX: Integer;
    FY: Integer;
    FX1: Integer;
    FY1: Integer;
    FDX: Integer;
    FDY: Integer;
    FFrameWidth: Integer;
    FScaleX: Extended;
    FScaleY: Extended;
    FOffsetX: Extended;
    FOffsetY: Extended;
    FCanvas: TCanvas;
    procedure BeginDraw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended); virtual;
    procedure DrawBackground; virtual;
    procedure DrawFrame; virtual;
    procedure DrawLine(x, y, x1, y1, w: Integer);
    procedure ExpandVariables(var Expr: String);
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Diff(AComponent: TfrxComponent): String; override;
    function IsDataField: Boolean;
    procedure Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended); override;
    procedure BeforePrint; override;
    procedure GetData; override;
    procedure AfterPrint; override;
    property BrushStyle: TBrushStyle read FBrushStyle write FBrushStyle default bsSolid;
    property Color: TColor read FColor write FColor default clNone;
    property DataField: String read FDataField write FDataField;
    property DataSet: TfrxDataSet read FDataSet write SetDataSet;
    property DataSetName: String read GetDataSetName write SetDataSetName;
    property Frame: TfrxFrame read FFrame write SetFrame;
    property PlainText: Boolean read FPlainText write FPlainText;
    property Cursor: TCursor read FCursor write FCursor default crDefault;
    property TagStr: String read FTagStr write FTagStr;
    property URL: String read FURL write FURL;
  published
    property Align: TfrxAlign read FAlign write FAlign default baNone;
    property Printable: Boolean read FPrintable write FPrintable default True;
    property ShiftMode: TfrxShiftMode read FShiftMode write FShiftMode default smAlways;
    property Left;
    property Top;
    property Width;
    property Height;
    property GroupIndex;
    property Restrictions;
    property Visible;
    property OnAfterData;
    property OnAfterPrint;
    property OnBeforePrint;
    property OnPreviewClick;
  end;


  TfrxStretcheable = class(TfrxView)

  private
    FStretchMode: TfrxStretchMode;

  public
    FSaveHeight: Extended;
    constructor Create(AOwner: TComponent); override;
    function CalcHeight: Extended; virtual;
    function DrawPart: Extended; virtual;
    procedure InitPart; virtual;
  published
    property StretchMode: TfrxStretchMode read FStretchMode write FStretchMode
      default smDontStretch;
  end;


  TfrxHighlight = class(TPersistent)
  private

    FActive: Boolean;
    FColor: TColor;
    FCondition: String;

    FFont: TFont;

    procedure SetFont(const Value: TFont);

  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Active: Boolean read FActive write FActive default False;

    property Font: TFont read FFont write SetFont;

    property Color: TColor read FColor write FColor default clNone;
    property Condition: String read FCondition write FCondition;
  end;


  TfrxFormat = class(TPersistent)
  private

    FDecimalSeparator: String;
    FFormatStr: String;
    FKind: TfrxFormatKind;

  public
    procedure Assign(Source: TPersistent); override;
  published
    property DecimalSeparator: String read FDecimalSeparator write FDecimalSeparator;
    property FormatStr: String read FFormatStr write FFormatStr;
    property Kind: TfrxFormatKind read FKind write FKind default fkText;
  end;


  TfrxCustomMemoView = class(TfrxStretcheable)

  private
    FAllowExpressions: Boolean;
    FAllowHTMLTags: Boolean;
    FAutoWidth: Boolean;
    FCharSpacing: Extended;
    FClipped: Boolean;
    FDisplayFormat: TfrxFormat;
    FExpressionDelimiters: String;
    FFlowTo: TfrxCustomMemoView;
    FGapX: Extended;
    FGapY: Extended;
    FHAlign: TfrxHAlign;
    FHideZeros: Boolean;
    FHighlight: TfrxHighlight;
    FLineSpacing: Extended;
    FMemo: TWideStrings;
    FParagraphGap: Extended;
    FPartMemo: WideString;
    FRotation: Integer;
    FRTLReading: Boolean;
    FStyle: String;
    FSuppressRepeated: Boolean;
    FTempMemo: WideString;
    FUnderlines: Boolean;
    FVAlign: TfrxVAlign;
    FValue: Variant;
    FWordBreak: Boolean;
    FWordWrap: Boolean;
    FWysiwyg: Boolean;
    procedure SetMemo(const Value: TWideStrings);
    procedure SetRotation(Value: Integer);
    procedure SetText(const Value: WideString);
    function AdjustCalcHeight: Extended;
    function AdjustCalcWidth: Extended;
    function GetText: WideString;
    function IsExprDelimitersStored: Boolean;
    function IsLineSpacingStored: Boolean;
    function IsGapXStored: Boolean;
    function IsGapYStored: Boolean;
    function IsHighlightStored: Boolean;
    function IsParagraphGapStored: Boolean;
    procedure SetHighlight(const Value: TfrxHighlight);
    procedure SetDisplayFormat(const Value: TfrxFormat);
    procedure SetStyle(const Value: String);
    function IsCharSpacingStored: Boolean;
  protected
    FLastValue: Variant;
    FTotalPages: Integer;
    FCopyNo: Integer;
    FTextRect: TRect;
    FPrintScale: Extended;
    function CalcAndFormat(const Expr: WideString): WideString;
    procedure BeginDraw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended); override;
    procedure SetDrawParams(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended);
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class function GetDescription: String; override;
    function Diff(AComponent: TfrxComponent): String; override;
    function CalcHeight: Extended; override;
    function CalcWidth: Extended; virtual;
    function DrawPart: Extended; override;
    function GetComponentText: String; override;
    function FormatData(const Value: Variant; AFormat: TfrxFormat = nil): WideString;
    function WrapText(WrapWords: Boolean): WideString;
    procedure Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended); override;
    procedure BeforePrint; override;
    procedure GetData; override;
    procedure AfterPrint; override;
    procedure InitPart; override;
    procedure ApplyStyle(Style: TfrxStyleItem);
    procedure ExtractMacros;
    property Text: WideString read GetText write SetText;
    property Value: Variant read FValue write FValue;
    // analogue of Memo property
    property Lines: TWideStrings read FMemo write SetMemo;

    property AllowExpressions: Boolean read FAllowExpressions write FAllowExpressions default True;
    property AllowHTMLTags: Boolean read FAllowHTMLTags write FAllowHTMLTags default False;
    property AutoWidth: Boolean read FAutoWidth write FAutoWidth default False;
    property CharSpacing: Extended read FCharSpacing write FCharSpacing stored IsCharSpacingStored;
    property Clipped: Boolean read FClipped write FClipped default True;
    property DisplayFormat: TfrxFormat read FDisplayFormat write SetDisplayFormat;
    property ExpressionDelimiters: String read FExpressionDelimiters
      write FExpressionDelimiters stored IsExprDelimitersStored;
    property FlowTo: TfrxCustomMemoView read FFlowTo write FFlowTo;
    property GapX: Extended read FGapX write FGapX stored IsGapXStored;
    property GapY: Extended read FGapY write FGapY stored IsGapYStored;
    property HAlign: TfrxHAlign read FHAlign write FHAlign default haLeft;
    property HideZeros: Boolean read FHideZeros write FHideZeros default False;
    property Highlight: TfrxHighlight read FHighlight write SetHighlight
      stored IsHighlightStored;
    property LineSpacing: Extended read FLineSpacing write FLineSpacing stored IsLineSpacingStored;
    property Memo: TWideStrings read FMemo write SetMemo;
    property ParagraphGap: Extended read FParagraphGap write FParagraphGap stored IsParagraphGapStored;
    property Rotation: Integer read FRotation write SetRotation default 0;
    property RTLReading: Boolean read FRTLReading write FRTLReading default False;
    property Style: String read FStyle write SetStyle;
    property SuppressRepeated: Boolean read FSuppressRepeated write FSuppressRepeated default False;
    property Underlines: Boolean read FUnderlines write FUnderlines default False;
    property WordBreak: Boolean read FWordBreak write FWordBreak default False;
    property WordWrap: Boolean read FWordWrap write FWordWrap default True;
    property Wysiwyg: Boolean read FWysiwyg write FWysiwyg default True;
    property VAlign: TfrxVAlign read FVAlign write FVAlign default vaTop;

  published
    property Cursor;
    property TagStr;
    property URL;
  end;


  TfrxMemoView = class(TfrxCustomMemoView)

  published
    property AutoWidth;
    property AllowExpressions;
    property AllowHTMLTags;
    property BrushStyle;
    property CharSpacing;
    property Clipped;
    property Color;
    property DataField;
    property DataSet;
    property DataSetName;
    property DisplayFormat;
    property ExpressionDelimiters;
    property FlowTo;
    property Font;
    property Frame;
    property GapX;
    property GapY;
    property HAlign;
    property HideZeros;
    property Highlight;
    property LineSpacing;
    property Memo;
    property ParagraphGap;
    property ParentFont;
    property Rotation;
    property RTLReading;
    property Style;
    property SuppressRepeated;
    property Underlines;
    property WordBreak;
    property WordWrap;
    property Wysiwyg;
    property VAlign;
  end;

  TfrxSysMemoView = class(TfrxCustomMemoView)
  public
    class function GetDescription: String; override;
  published
    property AutoWidth;
    property BrushStyle;
    property CharSpacing;
    property Color;
    property DisplayFormat;
    property Font;
    property Frame;
    property GapX;
    property GapY;
    property HAlign;
    property HideZeros;
    property Highlight;
    property Memo;
    property ParentFont;
    property Rotation;
    property RTLReading;
    property Style;
    property SuppressRepeated;
    property VAlign;
    property WordWrap;
  end;

  TfrxCustomLineView = class(TfrxStretcheable)
  private
    FDiagonal: Boolean;
    FArrowEnd: Boolean;
    FArrowLength: Integer;
    FArrowSolid: Boolean;
    FArrowStart: Boolean;
    FArrowWidth: Integer;
    procedure DrawArrow(x1, y1, x2, y2: Integer);
    procedure DrawDiagonalLine;
  public
    constructor Create(AOwner: TComponent); override;
    constructor DesignCreate(AOwner: TComponent; Flags: Word); override;
    procedure Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended); override;
    property ArrowEnd: Boolean read FArrowEnd write FArrowEnd default False;
    property ArrowLength: Integer read FArrowLength write FArrowLength default 20;
    property ArrowSolid: Boolean read FArrowSolid write FArrowSolid default False;
    property ArrowStart: Boolean read FArrowStart write FArrowStart default False;
    property ArrowWidth: Integer read FArrowWidth write FArrowWidth default 5;
    property Diagonal: Boolean read FDiagonal write FDiagonal default False;
  published
    property TagStr;
  end;

  TfrxLineView = class(TfrxCustomLineView)
  public
    class function GetDescription: String; override;
  published
    property ArrowEnd;
    property ArrowLength;
    property ArrowSolid;
    property ArrowStart;
    property ArrowWidth;
    property Frame;
    property Diagonal;
  end;


  TfrxPictureView = class(TfrxView)

  private
    FAutoSize: Boolean;
    FCenter: Boolean;
    FFileLink: String;
    FImageIndex: Integer;
    FIsImageIndexStored: Boolean;
    FIsPictureStored: Boolean;
    FKeepAspectRatio: Boolean;
    FPicture: TPicture;
    FPictureChanged: Boolean;
    FStretched: Boolean;
    procedure SetPicture(const Value: TPicture);
    procedure PictureChanged(Sender: TObject);
    procedure SetAutoSize(const Value: Boolean);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class function GetDescription: String; override;
    function Diff(AComponent: TfrxComponent): String; override;
    function LoadPictureFromStream(s: TStream): HResult;
    procedure Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended); override;
    procedure GetData; override;
    property IsImageIndexStored: Boolean read FIsImageIndexStored write FIsImageIndexStored;
    property IsPictureStored: Boolean read FIsPictureStored write FIsPictureStored;
  published
    property Cursor;
    property AutoSize: Boolean read FAutoSize write SetAutoSize default False;
    property Center: Boolean read FCenter write FCenter default False;
    property DataField;
    property DataSet;
    property DataSetName;
    property Frame;
    property FileLink: String read FFileLink write FFileLink;
    property ImageIndex: Integer read FImageIndex write FImageIndex stored FIsImageIndexStored;
    property KeepAspectRatio: Boolean read FKeepAspectRatio write FKeepAspectRatio default True;
    property Picture: TPicture read FPicture write SetPicture stored FIsPictureStored;
    property Stretched: Boolean read FStretched write FStretched default True;
    property TagStr;
    property URL;
  end;


  TfrxShapeView = class(TfrxView)

  private
    FCurve: Integer;
    FShape: TfrxShapeKind;

  public
    constructor Create(AOwner: TComponent); override;
    constructor DesignCreate(AOwner: TComponent; Flags: Word); override;
    function Diff(AComponent: TfrxComponent): String; override;
    procedure Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended); override;
    class function GetDescription: String; override;
  published
    property BrushStyle;
    property Color;
    property Cursor;
    property Curve: Integer read FCurve write FCurve default 0;
    property Frame;
    property Shape: TfrxShapeKind read FShape write FShape default skRectangle;
    property TagStr;
    property URL;
  end;


  TfrxSubreport = class(TfrxView)

  private
    FPage: TfrxReportPage;
    FPrintOnParent: Boolean;
    procedure SetPage(const Value: TfrxReportPage);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended); override;
    class function GetDescription: String; override;
  published
    property Page: TfrxReportPage read FPage write SetPage;
    property PrintOnParent: Boolean read FPrintOnParent write FPrintOnParent
      default False;
  end;


{ Bands }
  TfrxChild = class;


  TfrxBand = class(TfrxReportComponent)

  private
    FAllowSplit: Boolean;
    FChild: TfrxChild;
    FKeepChild: Boolean;
    FOnAfterCalcHeight: TfrxNotifyEvent;
    FOutlineText: String;
    FOverflow: Boolean;
    FStartNewPage: Boolean;
    FStretched: Boolean;
    FPrintChildIfInvisible: Boolean;
    FVertical: Boolean;
    function GetBandName: String;
    procedure SetChild(Value: TfrxChild);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetLeft(Value: Extended); override;
    procedure SetTop(Value: Extended); override;
    procedure SetHeight(Value: Extended); override;

  public
    FSubBands: TList;                    { list of subbands }
    FHeader, FFooter, FGroup: TfrxBand;  { h./f./g. bands   }
    FLineN: Integer;                     { used for Line#   }
    FLineThrough: Integer;               { used for LineThrough#   }
    FOriginalObjectsCount: Integer;      { used for TfrxSubReport.PrintOnParent }
    FHasVBands: Boolean;                 { whether the band should show vbands }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function BandNumber: Integer;
    procedure Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended); override;
    class function GetDescription: String; override;
    property AllowSplit: Boolean read FAllowSplit write FAllowSplit default False;
    property BandName: String read GetBandName;
    property Child: TfrxChild read FChild write SetChild;
    property KeepChild: Boolean read FKeepChild write FKeepChild default False;
    property OutlineText: String read FOutlineText write FOutlineText;
    property Overflow: Boolean read FOverflow write FOverflow;
    property PrintChildIfInvisible: Boolean read FPrintChildIfInvisible
      write FPrintChildIfInvisible default False;
    property StartNewPage: Boolean read FStartNewPage write FStartNewPage default False;
    property Stretched: Boolean read FStretched write FStretched default False;
  published
    property Font;
    property Height;
    property Left;
    property ParentFont;
    property Restrictions;
    property Top;
    property Vertical: Boolean read FVertical write FVertical default False;
    property Visible;
    property Width;
    property OnAfterCalcHeight: TfrxNotifyEvent read FOnAfterCalcHeight
      write FOnAfterCalcHeight;
    property OnAfterPrint;
    property OnBeforePrint;
  end;

  TfrxBandClass = class of TfrxBand;


  TfrxDataBand = class(TfrxBand)

  private
    FColumnGap: Extended;
    FColumnWidth: Extended;
    FColumns: Integer;
    FCurColumn: Integer;
    FDataSet: TfrxDataSet;
    FDataSetName: String;
    FFooterAfterEach: Boolean;
    FKeepFooter: Boolean;
    FKeepHeader: Boolean;
    FKeepTogether: Boolean;
    FPrintIfDetailEmpty: Boolean;
    FRowCount: Integer;
    FOnMasterDetail: TfrxNotifyEvent;
    FVirtualDataSet: TfrxUserDataSet;
    procedure SetCurColumn(Value: Integer);
    procedure SetRowCount(const Value: Integer);
    procedure SetDataSet(const Value: TfrxDataSet);
    procedure SetDataSetName(const Value: String);
    function GetDataSetName: String;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  public
    FMaxY: Extended;                             { used for columns }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class function GetDescription: String; override;
    property CurColumn: Integer read FCurColumn write SetCurColumn;
    property VirtualDataSet: TfrxUserDataSet read FVirtualDataSet;
  published
    property AllowSplit;
    property Child;
    property Columns: Integer read FColumns write FColumns default 0;
    property ColumnWidth: Extended read FColumnWidth write FColumnWidth;
    property ColumnGap: Extended read FColumnGap write FColumnGap;
    property DataSet: TfrxDataSet read FDataSet write SetDataSet;
    property DataSetName: String read GetDataSetName write SetDataSetName;
    property FooterAfterEach: Boolean read FFooterAfterEach write FFooterAfterEach default False;
    property KeepChild;
    property KeepFooter: Boolean read FKeepFooter write FKeepFooter default False;
    property KeepHeader: Boolean read FKeepHeader write FKeepHeader default False;
    property KeepTogether: Boolean read FKeepTogether write FKeepTogether default False;
    property OutlineText;
    property PrintChildIfInvisible;
    property PrintIfDetailEmpty: Boolean read FPrintIfDetailEmpty
      write FPrintIfDetailEmpty default False;
    property RowCount: Integer read FRowCount write SetRowCount;
    property StartNewPage;
    property Stretched;
    property OnMasterDetail: TfrxNotifyEvent read FOnMasterDetail write FOnMasterDetail;
  end;


  TfrxHeader = class(TfrxBand)

  private
    FReprintOnNewPage: Boolean;

  published
    property AllowSplit;
    property Child;
    property KeepChild;
    property PrintChildIfInvisible;
    property ReprintOnNewPage: Boolean read FReprintOnNewPage write FReprintOnNewPage default False;
    property StartNewPage;
    property Stretched;
  end;


  TfrxFooter = class(TfrxBand)

  private
  public
  published
    property AllowSplit;
    property Child;
    property KeepChild;
    property PrintChildIfInvisible;
    property Stretched;
  end;


  TfrxMasterData = class(TfrxDataBand)

  private
  public
  published
  end;


  TfrxDetailData = class(TfrxDataBand)

  private
  public
  published
  end;


  TfrxSubdetailData = class(TfrxDataBand)

  private
  public
  published
  end;


  TfrxDataBand4 = class(TfrxDataBand)

  private
  public
  published
  end;


  TfrxDataBand5 = class(TfrxDataBand)

  private
  public
  published
  end;


  TfrxDataBand6 = class(TfrxDataBand)

  private
  public
  published
  end;


  TfrxPageHeader = class(TfrxBand)

  private
    FPrintOnFirstPage: Boolean;

  public
    constructor Create(AOwner: TComponent); override;
  published
    property Child;
    property PrintChildIfInvisible;
    property PrintOnFirstPage: Boolean read FPrintOnFirstPage write FPrintOnFirstPage default True;
    property Stretched;
  end;


  TfrxPageFooter = class(TfrxBand)

  private
    FPrintOnFirstPage: Boolean;
    FPrintOnLastPage: Boolean;

  public
    constructor Create(AOwner: TComponent); override;
  published
    property PrintOnFirstPage: Boolean read FPrintOnFirstPage write FPrintOnFirstPage default True;
    property PrintOnLastPage: Boolean read FPrintOnLastPage write FPrintOnLastPage default True;
  end;


  TfrxColumnHeader = class(TfrxBand)

  private
  public
  published
    property Stretched;
  end;


  TfrxColumnFooter = class(TfrxBand)

  private
  public
  published
  end;


  TfrxGroupHeader = class(TfrxBand)

  private
    FCondition: String;
    FDrillDown: Boolean;
    FExpandDrillDown: Boolean;
    FShowFooterIfDrillDown: Boolean;
    FKeepTogether: Boolean;
    FReprintOnNewPage: Boolean;
    FResetPageNumbers: Boolean;

  public
    FLastValue: Variant;
    function Diff(AComponent: TfrxComponent): String; override;
  published
    property AllowSplit;
    property Child;
    property Condition: String read FCondition write FCondition;
    property DrillDown: Boolean read FDrillDown write FDrillDown default False;
    property ExpandDrillDown: Boolean read FExpandDrillDown write FExpandDrillDown default False;
    property KeepChild;
    property KeepTogether: Boolean read FKeepTogether write FKeepTogether default False;
    property ReprintOnNewPage: Boolean read FReprintOnNewPage write FReprintOnNewPage default False;
    property OutlineText;
    property PrintChildIfInvisible;
    property ResetPageNumbers: Boolean read FResetPageNumbers write FResetPageNumbers default False;
    property ShowFooterIfDrillDown: Boolean read FShowFooterIfDrillDown
      write FShowFooterIfDrillDown default False;
    property StartNewPage;
    property Stretched;
  end;


  TfrxGroupFooter = class(TfrxBand)

  private
    FHideIfSingleDataRecord: Boolean;

  public
  published
    property AllowSplit;
    property Child;
    property HideIfSingleDataRecord: Boolean read FHideIfSingleDataRecord
      write FHideIfSingleDataRecord default False;
    property KeepChild;
    property PrintChildIfInvisible;
    property Stretched;
  end;


  TfrxReportTitle = class(TfrxBand)

  private
  public
  published
    property AllowSplit;
    property Child;
    property KeepChild;
    property PrintChildIfInvisible;
    property StartNewPage;
    property Stretched;
  end;


  TfrxReportSummary = class(TfrxBand)

  private
  public
  published
    property AllowSplit;
    property Child;
    property KeepChild;
    property PrintChildIfInvisible;
    property StartNewPage;
    property Stretched;
  end;


  TfrxChild = class(TfrxBand)

  private
  public
  published
    property AllowSplit;
    property Child;
    property KeepChild;
    property PrintChildIfInvisible;
    property StartNewPage;
    property Stretched;
  end;


  TfrxOverlay = class(TfrxBand)

  private
    FPrintOnTop: Boolean;
  public
  published
    property PrintOnTop: Boolean read FPrintOnTop write FPrintOnTop default False;
  end;

  TfrxNullBand = class(TfrxBand);


{ Pages }


  TfrxPage = class(TfrxComponent)

  private
  protected

  public
  published
    property Font;
    property Visible;
  end;


  TfrxReportPage = class(TfrxPage)

  private
    FBackPicture: TfrxPictureView;
    FBin: Integer;
    FBinOtherPages: Integer;
    FBottomMargin: Extended;
    FColumns: Integer;
    FColumnWidth: Extended;
    FColumnPositions: TStrings;
    FDataSet: TfrxDataSet;
    FDuplex: TfrxDuplexMode;
    FEndlessHeight: Boolean;
    FEndlessWidth: Boolean;
    FHGuides: TStrings;
    FLargeDesignHeight: Boolean;
    FLeftMargin: Extended;
    FMirrorMargins: Boolean;
    FOrientation: TPrinterOrientation;
    FOutlineText: String;
    FPrintIfEmpty: Boolean;
    FPrintOnPreviousPage: Boolean;
    FRightMargin: Extended;
    FSubReport: TfrxSubReport;
    FTitleBeforeHeader: Boolean;
    FTopMargin: Extended;
    FVGuides: TStrings;
    FOnAfterPrint: TfrxNotifyEvent;
    FOnBeforePrint: TfrxNotifyEvent;
    FOnManualBuild: TfrxNotifyEvent;
    FDataSetName: String;
    procedure SetColumns(const Value: Integer);
    procedure SetOrientation(Value: TPrinterOrientation);
    procedure SetHGuides(const Value: TStrings);
    procedure SetVGuides(const Value: TStrings);
    procedure SetColumnPositions(const Value: TStrings);
    procedure SetFrame(const Value: TfrxFrame);
    function GetFrame: TfrxFrame;
    function GetColor: TColor;
    procedure SetColor(const Value: TColor);
    function GetBackPicture: TPicture;
    procedure SetBackPicture(const Value: TPicture);
    procedure SetDataSet(const Value: TfrxDataSet);
    procedure SetDataSetName(const Value: String);
    function GetDataSetName: String;
  protected
    FPaperHeight: Extended;
    FPaperSize: Integer;
    FPaperWidth: Extended;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetPaperHeight(const Value: Extended); virtual;
    procedure SetPaperWidth(const Value: Extended); virtual;
    procedure SetPaperSize(const Value: Integer); virtual;
    procedure UpdateDimensions;
  public
    FSubBands: TList;   { list of master bands }
    FVSubBands: TList;  { list of vertical master bands }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class function GetDescription: String; override;
    function FindBand(Band: TfrxBandClass): TfrxBand;
    function IsSubReport: Boolean;
    procedure AlignChildren; override;
    procedure ClearGuides;
    procedure Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended);
    procedure SetDefaults; virtual;
    procedure SetSizeAndDimensions(ASize: Integer; AWidth, AHeight: Extended);
    property SubReport: TfrxSubReport read FSubReport;
  published
    { paper }
    property Orientation: TPrinterOrientation read FOrientation
      write SetOrientation default poPortrait;
    property PaperWidth: Extended read FPaperWidth write SetPaperWidth;
    property PaperHeight: Extended read FPaperHeight write SetPaperHeight;
    property PaperSize: Integer read FPaperSize write SetPaperSize;
    { margins }
    property LeftMargin: Extended read FLeftMargin write FLeftMargin;
    property RightMargin: Extended read FRightMargin write FRightMargin;
    property TopMargin: Extended read FTopMargin write FTopMargin;
    property BottomMargin: Extended read FBottomMargin write FBottomMargin;
    property MirrorMargins: Boolean read FMirrorMargins write FMirrorMargins
      default False;
    { columns }
    property Columns: Integer read FColumns write SetColumns default 0;
    property ColumnWidth: Extended read FColumnWidth write FColumnWidth;
    property ColumnPositions: TStrings read FColumnPositions write SetColumnPositions;
    { bins }
    property Bin: Integer read FBin write FBin default DMBIN_AUTO;
    property BinOtherPages: Integer read FBinOtherPages write FBinOtherPages
      default DMBIN_AUTO;
    { other }
    property BackPicture: TPicture read GetBackPicture write SetBackPicture;
    property Color: TColor read GetColor write SetColor default clNone;
    property DataSet: TfrxDataSet read FDataSet write SetDataSet;
    property DataSetName: String read GetDataSetName write SetDataSetName;
    property Duplex: TfrxDuplexMode read FDuplex write FDuplex default dmNone;
    property Frame: TfrxFrame read GetFrame write SetFrame;
    property EndlessHeight: Boolean read FEndlessHeight write FEndlessHeight default False;
    property EndlessWidth: Boolean read FEndlessWidth write FEndlessWidth default False;
    property LargeDesignHeight: Boolean read FLargeDesignHeight
      write FLargeDesignHeight default False;
    property OutlineText: String read FOutlineText write FOutlineText;
    property PrintIfEmpty: Boolean read FPrintIfEmpty write FPrintIfEmpty default True;
    property PrintOnPreviousPage: Boolean read FPrintOnPreviousPage
      write FPrintOnPreviousPage default False;
    property TitleBeforeHeader: Boolean read FTitleBeforeHeader
      write FTitleBeforeHeader default True;
    property HGuides: TStrings read FHGuides write SetHGuides;
    property VGuides: TStrings read FVGuides write SetVGuides;
    property OnAfterPrint: TfrxNotifyEvent read FOnAfterPrint write FOnAfterPrint;
    property OnBeforePrint: TfrxNotifyEvent read FOnBeforePrint write FOnBeforePrint;
    property OnManualBuild: TfrxNotifyEvent read FOnManualBuild write FOnManualBuild;

  end;

  TfrxDialogPage = class(TfrxPage)
  private
    FBorderStyle: TFormBorderStyle;
    FCaption: String;
    FColor: TColor;
    FForm: TForm;
    FOnActivate: TfrxNotifyEvent;
    FOnClick: TfrxNotifyEvent;
    FOnDeactivate: TfrxNotifyEvent;
    FOnHide: TfrxNotifyEvent;
    FOnKeyDown: TfrxKeyEvent;
    FOnKeyPress: TfrxKeyPressEvent;
    FOnKeyUp: TfrxKeyEvent;
    FOnResize: TfrxNotifyEvent;
    FOnShow: TfrxNotifyEvent;
    FOnCloseQuery: TfrxCloseQueryEvent;
    FPosition: TPosition;
    FWindowState: TWindowState;
    procedure DoInitialize;
    procedure DoOnActivate(Sender: TObject);
    procedure DoOnClick(Sender: TObject);
    procedure DoOnCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure DoOnDeactivate(Sender: TObject);
    procedure DoOnHide(Sender: TObject);
    procedure DoOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DoOnKeyPress(Sender: TObject; var Key: Char);
    procedure DoOnKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DoOnShow(Sender: TObject);
    procedure DoOnResize(Sender: TObject);
    procedure DoModify(Sender: TObject);
    procedure SetBorderStyle(const Value: TFormBorderStyle);
    procedure SetCaption(const Value: String);
    procedure SetColor(const Value: TColor);
    function GetModalResult: TModalResult;
    procedure SetModalResult(const Value: TModalResult);
  protected
    procedure SetLeft(Value: Extended); override;
    procedure SetTop(Value: Extended); override;
    procedure SetWidth(Value: Extended); override;
    procedure SetHeight(Value: Extended); override;
    procedure FontChanged(Sender: TObject); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class function GetDescription: String; override;
    procedure Initialize;
    function ShowModal: TModalResult;
    property DialogForm: TForm read FForm;
    property ModalResult: TModalResult read GetModalResult write SetModalResult;
  published
    property BorderStyle: TFormBorderStyle read FBorderStyle write SetBorderStyle default bsSizeable;
    property Caption: String read FCaption write SetCaption;
    property Color: TColor read FColor write SetColor default clBtnFace;
    property Height;
    property Left;
    property Position: TPosition read FPosition write FPosition default poScreenCenter;
    property Top;
    property Width;
    property WindowState: TWindowState read FWindowState write FWindowState default wsNormal;
    property OnActivate: TfrxNotifyEvent read FOnActivate write FOnActivate;
    property OnClick: TfrxNotifyEvent read FOnClick write FOnClick;
    property OnCloseQuery: TfrxCloseQueryEvent read FOnCloseQuery write FOnCloseQuery;
    property OnDeactivate: TfrxNotifyEvent read FOnDeactivate write FOnDeactivate;
    property OnHide: TfrxNotifyEvent read FOnHide write FOnHide;
    property OnKeyDown: TfrxKeyEvent read FOnKeyDown write FOnKeyDown;
    property OnKeyPress: TfrxKeyPressEvent read FOnKeyPress write FOnKeyPress;
    property OnKeyUp: TfrxKeyEvent read FOnKeyUp write FOnKeyUp;
    property OnShow: TfrxNotifyEvent read FOnShow write FOnShow;
    property OnResize: TfrxNotifyEvent read FOnResize write FOnResize;
  end;

  TfrxDataPage = class(TfrxPage)
  private
  protected
  public
    constructor Create(AOwner: TComponent); override;
    class function GetDescription: String; override;
  published
    property Height;
    property Left;
    property Top;
    property Width;
  end;


{ Report }


  TfrxEngineOptions = class(TPersistent)

  private
    FConvertNulls: Boolean;
    FDestroyForms: Boolean;
    FDoublePass: Boolean;
    FMaxMemSize: Integer;
    FPrintIfEmpty: Boolean;

    FReportThread: TThread;

    FEnableThreadSafe: Boolean;
    FSilentMode: TfrxSilentMode;
    FTempDir: String;
    FUseFileCache: Boolean;

    procedure SetSilentMode(Mode: Boolean);
    function GetSilentMode: Boolean;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    procedure Clear;

    property ReportThread: TThread read FReportThread write FReportThread;

    property DestroyForms: Boolean read FDestroyForms write FDestroyForms;
    property EnableThreadSafe: Boolean read FEnableThreadSafe write FEnableThreadSafe;
  published
    property ConvertNulls: Boolean read FConvertNulls write FConvertNulls default True;
    property DoublePass: Boolean read FDoublePass write FDoublePass default False;
    property MaxMemSize: Integer read FMaxMemSize write FMaxMemSize default 10;
    property PrintIfEmpty: Boolean read FPrintIfEmpty write FPrintIfEmpty default True;
    property SilentMode: Boolean read GetSilentMode write SetSilentMode default False;
    property NewSilentMode: TfrxSilentMode read FSilentMode write FSilentMode default simMessageBoxes;
    property TempDir: String read FTempDir write FTempDir;
    property UseFileCache: Boolean read FUseFileCache write FUseFileCache default False;

  end;


  TfrxPrintOptions = class(TPersistent)

  private
    FCopies: Integer;
    FCollate: Boolean;
    FPageNumbers: String;
    FPagesOnSheet: Integer;
    FPrinter: String;
    FPrintMode: TfrxPrintMode;
    FPrintOnSheet: Integer;
    FPrintPages: TfrxPrintPages;
    FReverse: Boolean;
    FShowDialog: Boolean;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    procedure Clear;
  published
    property Copies: Integer read FCopies write FCopies default 1;
    property Collate: Boolean read FCollate write FCollate default True;
    property PageNumbers: String read FPageNumbers write FPageNumbers;
    property Printer: String read FPrinter write FPrinter;
    property PrintMode: TfrxPrintMode read FPrintMode write FPrintMode default pmDefault;
    property PrintOnSheet: Integer read FPrintOnSheet write FPrintOnSheet;
    property PrintPages: TfrxPrintPages read FPrintPages write FPrintPages default ppAll;
    property Reverse: Boolean read FReverse write FReverse default False;
    property ShowDialog: Boolean read FShowDialog write FShowDialog default True;

  end;


  TfrxPreviewOptions = class(TPersistent)

  private
    FAllowEdit: Boolean;
    FButtons: TfrxPreviewButtons;
    FDoubleBuffered: Boolean;
    FMaximized: Boolean;
    FMDIChild: Boolean;
    FModal: Boolean;
    FOutlineExpand: Boolean;
    FOutlineVisible: Boolean;
    FOutlineWidth: Integer;
    FShowCaptions: Boolean;
    FZoom: Extended;
    FZoomMode: TfrxZoomMode;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    procedure Clear;
  published
    property AllowEdit: Boolean read FAllowEdit write FAllowEdit default True;
    property Buttons: TfrxPreviewButtons read FButtons write FButtons;
    property DoubleBuffered: Boolean read FDoubleBuffered write FDoubleBuffered default True;
    property Maximized: Boolean read FMaximized write FMaximized default True;
    property MDIChild: Boolean read FMDIChild write FMDIChild default False;
    property Modal: Boolean read FModal write FModal default True;
    property OutlineExpand: Boolean read FOutlineExpand write FOutlineExpand default True;
    property OutlineVisible: Boolean read FOutlineVisible write FOutlineVisible default False;
    property OutlineWidth: Integer read FOutlineWidth write FOutlineWidth default 120;
    property ShowCaptions: Boolean read FShowCaptions write FShowCaptions default False;
    property Zoom: Extended read FZoom write FZoom;
    property ZoomMode: TfrxZoomMode read FZoomMode write FZoomMode default zmDefault;

  end;


  TfrxReportOptions = class(TPersistent)

  private
    FAuthor: String;
    FCompressed: Boolean;
    FConnectionName: String;
    FCreateDate: TDateTime;
    FDescription: TStrings;
    FInitString: String;
    FName: String;
    FLastChange: TDateTime;
    FPassword: String;
    FPicture: TPicture;
    FReport: TfrxReport;
    FVersionBuild: String;
    FVersionMajor: String;
    FVersionMinor: String;
    FVersionRelease: String;
    FPrevPassword: String;
    FInfo: Boolean;
    procedure SetDescription(const Value: TStrings);
    procedure SetPicture(const Value: TPicture);
    procedure SetConnectionName(const Value: String);
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Clear;
    function CheckPassword: Boolean;
    property PrevPassword: String write FPrevPassword;
    property Info: Boolean read FInfo write FInfo;
  published
    property Author: String read FAuthor write FAuthor;
    property Compressed: Boolean read FCompressed write FCompressed default False;
    property ConnectionName: String read FConnectionName write SetConnectionName;
    property CreateDate: TDateTime read FCreateDate write FCreateDate;
    property Description: TStrings read FDescription write SetDescription;
    property InitString: String read FInitString write FInitString;
    property Name: String read FName write FName;
    property LastChange: TDateTime read FLastChange write FLastChange;
    property Password: String read FPassword write FPassword;
    property Picture: TPicture read FPicture write SetPicture;
    property VersionBuild: String read FVersionBuild write FVersionBuild;
    property VersionMajor: String read FVersionMajor write FVersionMajor;
    property VersionMinor: String read FVersionMinor write FVersionMinor;
    property VersionRelease: String read FVersionRelease write FVersionRelease;

  end;


  TfrxExpressionCache = class(TObject)
  private
    FExpressions: TStringList;
    FMainScript: TfsScript;
    FScript: TfsScript;
    FScriptLanguage: String;
  public
    constructor Create(AScript: TfsScript);
    destructor Destroy; override;
    procedure Clear;
    function Calc(const Expression: String; var ErrorMsg: String;
      AScript: TfsScript): Variant;
  end;

  TfrxDataSetItem = class(TCollectionItem)
  private
    FDataSet: TfrxDataSet;
    FDataSetName: String;
    procedure SetDataSet(const Value: TfrxDataSet);
    procedure SetDataSetName(const Value: String);
    function GetDataSetName: String;
  published
    property DataSet: TfrxDataSet read FDataSet write SetDataSet;
    property DataSetName: String read GetDataSetName write SetDataSetName;
  end;

  TfrxReportDataSets = class(TCollection)
  private
    FReport: TfrxReport;
    function GetItem(Index: Integer): TfrxDataSetItem;
  public
    constructor Create(AReport: TfrxReport);
    procedure Initialize;
    procedure Finalize;
    procedure Add(ds: TfrxDataSet);
    function Find(ds: TfrxDataSet): TfrxDataSetItem; overload;
    function Find(const Name: String): TfrxDataSetItem; overload;
    procedure Delete(const Name: String); overload;
    property Items[Index: Integer]: TfrxDataSetItem read GetItem; default;
  end;

  TfrxStyleItem = class(TCollectionItem)
  private
    FName: String;
    FColor: TColor;
    FFont: TFont;
    FFrame: TfrxFrame;
    procedure SetFont(const Value: TFont);
    procedure SetFrame(const Value: TfrxFrame);
    procedure SetName(const Value: String);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure CreateUniqueName;
  published
    property Name: String read FName write SetName;
    property Color: TColor read FColor write FColor;
    property Font: TFont read FFont write SetFont;
    property Frame: TfrxFrame read FFrame write SetFrame;
  end;

  TfrxStyles = class(TCollection)
  private
    FName: String;
    FReport: TfrxReport;
    function GetItem(Index: Integer): TfrxStyleItem;
  public
    constructor Create(AReport: TfrxReport);
    function Add: TfrxStyleItem;
    function Find(const Name: String): TfrxStyleItem;
    procedure Apply;
    procedure GetList(List: TStrings);
    procedure LoadFromFile(const FileName: String);
    procedure LoadFromStream(Stream: TStream);
    procedure LoadFromXMLItem(Item: TfrxXMLItem);
    procedure SaveToFile(const FileName: String);
    procedure SaveToStream(Stream: TStream);
    procedure SaveToXMLItem(Item: TfrxXMLItem);
    property Items[Index: Integer]: TfrxStyleItem read GetItem; default;
    property Name: String read FName write FName;
  end;

  TfrxStyleSheet = class(TObject)
  private
    FItems: TList;
    function GetItems(Index: Integer): TfrxStyles;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Delete(Index: Integer);
    procedure GetList(List: TStrings);
    procedure LoadFromFile(const FileName: String);
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToFile(const FileName: String);
    procedure SaveToStream(Stream: TStream);
    function Add: TfrxStyles;
    function Count: Integer;
    function Find(const Name: String): TfrxStyles;
    function IndexOf(const Name: String): Integer;
    property Items[Index: Integer]: TfrxStyles read GetItems; default;
  end;


  TfrxReport = class(TfrxComponent)

  private
    FCurObject: String;
    FDataSet: TfrxDataSet;
    FDataSetName: String;
    FDataSets: TfrxReportDatasets;
    FDesigner: TfrxCustomDesigner;
    FDotMatrixReport: Boolean;
    FDrawText: Pointer;
    FDrillState: TStrings;
    FEnabledDataSets: TfrxReportDataSets;
    FEngine: TfrxCustomEngine;
    FEngineOptions: TfrxEngineOptions;
    FErrors: TStrings;
    FExpressionCache: TfrxExpressionCache;
    FFileName: String;
    FIniFile: String;
    FLoadStream: TStream;
    FLocalValue: TfsCustomVariable;
    FModified: Boolean;
    FOldStyleProgress: Boolean;
    FParentForm: TForm;
    FParentReport: String;
    FParentReportObject: TfrxReport;
    FPreviewPages: TfrxCustomPreviewPages;
    FPreview: TfrxCustomPreview;
    FPreviewForm: TForm;
    FPreviewOptions: TfrxPreviewOptions;
    FPrintOptions: TfrxPrintOptions;
    FProgress: TfrxProgress;
    FReloading: Boolean;
    FReportOptions: TfrxReportOptions;
    FScript: TfsScript;
    FScriptLanguage: String;
    FScriptText: TStrings;
    FShowProgress: Boolean;
    FStoreInDFM: Boolean;
    FStyles: TfrxStyles;
    FSysVariables: TStrings;
    FTerminated: Boolean;
    FTimer: TTimer;
    FVariables: TfrxVariables;
    FVersion: String;
    FXMLSerializer: TObject;

    FOnAfterPrint: TfrxBeforePrintEvent;
    FOnAfterPrintReport: TNotifyEvent;
    FOnBeforeConnect: TfrxBeforeConnectEvent;
    FOnBeforePrint: TfrxBeforePrintEvent;
    FOnBeginDoc: TNotifyEvent;
    FOnClickObject: TfrxClickObjectEvent;
    FOnEditConnection: TfrxEditConnectionEvent;
    FOnEndDoc: TNotifyEvent;
    FOnGetValue: TfrxGetValueEvent;
    FOnLoadTemplate: TfrxLoadTemplateEvent;
    FOnManualBuild: TfrxManualBuildEvent;
    FOnMouseOverObject: TfrxMouseOverObjectEvent;
    FOnPreview: TNotifyEvent;
    FOnPrintPage: TfrxPrintPageEvent;
    FOnPrintReport: TNotifyEvent;
    FOnProgressStart: TfrxProgressEvent;
    FOnProgress: TfrxProgressEvent;
    FOnProgressStop: TfrxProgressEvent;
    FOnRunDialogs: TfrxRunDialogsEvent;
    FOnSetConnection: TfrxSetConnectionEvent;
    FOnStartReport: TfrxNotifyEvent;
    FOnStopReport: TfrxNotifyEvent;
    FOnUserFunction: TfrxUserFunctionEvent;
    FOnClosePreview: TNotifyEvent;

    function CallMethod(Instance: TObject; ClassType: TClass;
      const MethodName: String; var Params: Variant): Variant;
    function DoGetValue(const Expr: String; var Value: Variant): Boolean;
    function GetScriptValue(Instance: TObject; ClassType: TClass;
      const MethodName: String; var Params: Variant): Variant;
    function SetScriptValue(Instance: TObject; ClassType: TClass;
      const MethodName: String; var Params: Variant): Variant;
    function DoUserFunction(Instance: TObject; ClassType: TClass;
      const MethodName: String; var Params: Variant): Variant;
    function GetDataSetName: String;
    function GetLocalValue: Variant;
    function GetPages(Index: Integer): TfrxPage;
    function GetPagesCount: Integer;
    procedure AncestorNotFound(Reader: TReader; const ComponentName: string;
      ComponentClass: TPersistentClass; var Component: TComponent);
    procedure DoClear;
    procedure DoGetAncestor(const Name: String; var Ancestor: TPersistent);
    procedure DoLoadFromStream;
    procedure OnTimer(Sender: TObject);
    procedure ReadDatasets(Reader: TReader);
    procedure ReadStyle(Reader: TReader);
    procedure ReadVariables(Reader: TReader);
    procedure SetDataSet(const Value: TfrxDataSet);
    procedure SetDataSetName(const Value: String);
    procedure SetEngineOptions(const Value: TfrxEngineOptions);
    procedure SetLocalValue(const Value: Variant);
    procedure SetParentReport(const Value: String);
    procedure SetPreviewOptions(const Value: TfrxPreviewOptions);
    procedure SetPrintOptions(const Value: TfrxPrintOptions);
    procedure SetReportOptions(const Value: TfrxReportOptions);
    procedure SetScriptText(const Value: TStrings);
    procedure SetStyles(const Value: TfrxStyles);
    procedure SetTerminated(const Value: Boolean);
    procedure WriteDatasets(Writer: TWriter);
    procedure WriteStyle(Writer: TWriter);
    procedure WriteVariables(Writer: TWriter);
    procedure SetPreview(const Value: TfrxCustomPreview);
    procedure SetVersion(const Value: String);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure DefineProperties(Filer: TFiler); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear; override;
    class function GetDescription: String; override;

    { internal methods }
    function Calc(const Expr: String; AScript: TfsScript = nil): Variant;
    function DesignPreviewPage: Boolean;
    function GetAlias(DataSet: TfrxDataSet): String;
    function GetDataset(const Alias: String): TfrxDataset;
    function GetIniFile: TCustomIniFile;
    function PrepareScript: Boolean;
    function InheritFromTemplate(const templName: String): Boolean;
    procedure DesignReport(IDesigner: IUnknown; Editor: TObject); overload;
    procedure DoNotifyEvent(Obj: TObject; const EventName: String;
      RunAlways: Boolean = False);
    procedure DoParamEvent(const EventName: String; var Params: Variant;
      RunAlways: Boolean = False);
    procedure DoAfterPrint(c: TfrxReportComponent);
    procedure DoBeforePrint(c: TfrxReportComponent);
    procedure DoPreviewClick(v: TfrxView; Button: TMouseButton;
      Shift: TShiftState; var Modified: Boolean);
    procedure GetDatasetAndField(const ComplexName: String;
      var Dataset: TfrxDataset; var Field: String);
    procedure GetDataSetList(List: TStrings; OnlyDB: Boolean = False);
    procedure InternalOnProgressStart(ProgressType: TfrxProgressType); virtual;
    procedure InternalOnProgress(ProgressType: TfrxProgressType; Progress: Integer); virtual;
    procedure InternalOnProgressStop(ProgressType: TfrxProgressType); virtual;
    procedure SelectPrinter;
    procedure SetProgressMessage(const Value: String);

    { public methods }
    function LoadFromFile(const FileName: String;
      ExceptionIfNotFound: Boolean = False): Boolean;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToFile(const FileName: String);
    procedure SaveToStream(Stream: TStream; SaveChildren: Boolean = True;
      SaveDefaultValues: Boolean = False); override;

    procedure DesignReport(Modal: Boolean = True; MDIChild: Boolean = False); overload; stdcall;
    function PrepareReport(ClearLastReport: Boolean = True): Boolean;
    procedure ShowPreparedReport; stdcall;
    procedure ShowReport(ClearLastReport: Boolean = True); stdcall;
    procedure AddFunction(const FuncName: String; const Category: String = '';
      const Description: String = '');

    function Print: Boolean; stdcall;
    function Export(Filter: TfrxCustomExportFilter): Boolean;

    { internals }
    property CurObject: String read FCurObject write FCurObject;
    property DrillState: TStrings read FDrillState;
    property LocalValue: Variant read GetLocalValue write SetLocalValue;
    property PreviewForm: TForm read FPreviewForm;
    property XMLSerializer: TObject read FXMLSerializer;
    property Reloading: Boolean read FReloading write FReloading;

    { public }
    property DataSets: TfrxReportDataSets read FDataSets;
    property Designer: TfrxCustomDesigner read FDesigner write FDesigner;
    property EnabledDataSets: TfrxReportDataSets read FEnabledDataSets;
    property Engine: TfrxCustomEngine read FEngine;
    property Errors: TStrings read FErrors;
    property FileName: String read FFileName write FFileName;
    property Modified: Boolean read FModified write FModified;
    property PreviewPages: TfrxCustomPreviewPages read FPreviewPages;
    property Pages[Index: Integer]: TfrxPage read GetPages;
    property PagesCount: Integer read GetPagesCount;
    property Script: TfsScript read FScript;
    property Styles: TfrxStyles read FStyles write SetStyles;
    property Terminated: Boolean read FTerminated write SetTerminated;
    property Variables: TfrxVariables read FVariables;

    property OnEditConnection: TfrxEditConnectionEvent read FOnEditConnection write FOnEditConnection;
    property OnSetConnection: TfrxSetConnectionEvent read FOnSetConnection write FOnSetConnection;
  published
    property Version: String read FVersion write SetVersion;
    property ParentReport: String read FParentReport write SetParentReport;
    property DataSet: TfrxDataSet read FDataSet write SetDataSet;
    property DataSetName: String read GetDataSetName write SetDataSetName;
    property DotMatrixReport: Boolean read FDotMatrixReport write FDotMatrixReport;
    property EngineOptions: TfrxEngineOptions read FEngineOptions write SetEngineOptions;
    property IniFile: String read FIniFile write FIniFile;
    property OldStyleProgress: Boolean read FOldStyleProgress write FOldStyleProgress default False;
    property Preview: TfrxCustomPreview read FPreview write SetPreview;
    property PreviewOptions: TfrxPreviewOptions read FPreviewOptions write SetPreviewOptions;
    property PrintOptions: TfrxPrintOptions read FPrintOptions write SetPrintOptions;
    property ReportOptions: TfrxReportOptions read FReportOptions write SetReportOptions;
    property ScriptLanguage: String read FScriptLanguage write FScriptLanguage;
    property ScriptText: TStrings read FScriptText write SetScriptText;
    property ShowProgress: Boolean read FShowProgress write FShowProgress default True;
    property StoreInDFM: Boolean read FStoreInDFM write FStoreInDFM default True;

    property OnAfterPrint: TfrxBeforePrintEvent read FOnAfterPrint write FOnAfterPrint;
    property OnBeforeConnect: TfrxBeforeConnectEvent read FOnBeforeConnect write FOnBeforeConnect;
    property OnBeforePrint: TfrxBeforePrintEvent read FOnBeforePrint write FOnBeforePrint;
    property OnBeginDoc: TNotifyEvent read FOnBeginDoc write FOnBeginDoc;
    property OnClickObject: TfrxClickObjectEvent read FOnClickObject write FOnClickObject;
    property OnEndDoc: TNotifyEvent read FOnEndDoc write FOnEndDoc;
    property OnGetValue: TfrxGetValueEvent read FOnGetValue write FOnGetValue;
    property OnManualBuild: TfrxManualBuildEvent read FOnManualBuild write FOnManualBuild;
    property OnMouseOverObject: TfrxMouseOverObjectEvent read FOnMouseOverObject
      write FOnMouseOverObject;
    property OnPreview: TNotifyEvent read FOnPreview write FOnPreview;
    property OnPrintPage: TfrxPrintPageEvent read FOnPrintPage write FOnPrintPage;
    property OnPrintReport: TNotifyEvent read FOnPrintReport write FOnPrintReport;
    property OnAfterPrintReport: TNotifyEvent read FOnAfterPrintReport write FOnAfterPrintReport;
    property OnProgressStart: TfrxProgressEvent read FOnProgressStart write FOnProgressStart;
    property OnProgress: TfrxProgressEvent read FOnProgress write FOnProgress;
    property OnProgressStop: TfrxProgressEvent read FOnProgressStop write FOnProgressStop;
    property OnRunDialogs: TfrxRunDialogsEvent read FOnRunDialogs write FOnRunDialogs;
    property OnStartReport: TfrxNotifyEvent read FOnStartReport write FOnStartReport;
    property OnStopReport: TfrxNotifyEvent read FOnStopReport write FOnStopReport;
    property OnUserFunction: TfrxUserFunctionEvent read FOnUserFunction write FOnUserFunction;
    property OnLoadTemplate: TfrxLoadTemplateEvent read FOnLoadTemplate write FOnLoadTemplate;
    property OnClosePreview: TNotifyEvent read FOnClosePreview write FOnClosePreview;
  end;

  TfrxCustomDesigner = class(TForm)
  private
    FReport: TfrxReport;
    FIsPreviewDesigner: Boolean;
    FMemoFontName: String;
    FMemoFontSize: Integer;
    FUseObjectFont: Boolean;
  protected
    FModified: Boolean;
    FObjects: TList;
    FPage: TfrxPage;
    FSelectedObjects: TList;
    procedure SetModified(const Value: Boolean); virtual;
    procedure SetPage(const Value: TfrxPage); virtual;
    function GetCode: TStrings; virtual; abstract;
  public
    constructor CreateDesigner(AOwner: TComponent; AReport: TfrxReport;
      APreviewDesigner: Boolean = False);
    destructor Destroy; override;
    function InsertExpression(const Expr: String): String; virtual; abstract;
    procedure Lock; virtual; abstract;
    procedure ReloadPages(Index: Integer); virtual; abstract;
    procedure ReloadReport; virtual; abstract;
    procedure UpdateDataTree; virtual; abstract;
    procedure UpdatePage; virtual; abstract;
    property IsPreviewDesigner: Boolean read FIsPreviewDesigner;
    property Modified: Boolean read FModified write SetModified;
    property Objects: TList read FObjects;
    property Report: TfrxReport read FReport;
    property SelectedObjects: TList read FSelectedObjects;
    property Page: TfrxPage read FPage write SetPage;
    property Code: TStrings read GetCode;
    property UseObjectFont: Boolean read FUseObjectFont write FUseObjectFont;
    property MemoFontName: String read FMemoFontName write FMemoFontName;
    property MemoFontSize: Integer read FMemoFontSize write FMemoFontSize;
  end;

  TfrxDesignerClass = class of TfrxCustomDesigner;


  TfrxCustomExportFilter = class(TComponent)

  private
    FCurPage: Boolean;
    FExportNotPrintable: Boolean;
    FName: String;
    FNoRegister: Boolean;
    FPageNumbers: String;
    FReport: TfrxReport;
    FShowDialog: Boolean;
    FStream: TStream;
    FUseFileCache: Boolean;
    FDefaultPath: String;
    FSlaveExport: Boolean;
    FShowProgress: Boolean;
    FDefaultExt: String;
    FFilterDesc: String;
    FSuppressPageHeadersFooters: Boolean;
    FTitle: String;
  protected
  public
    constructor Create(AOwner: TComponent); override;
    constructor CreateNoRegister;
    destructor Destroy; override;
    class function GetDescription: String; virtual;
    function ShowModal: TModalResult; virtual;
    function Start: Boolean; virtual;
    procedure ExportObject(Obj: TfrxComponent); virtual; abstract;
    procedure Finish; virtual;
    procedure FinishPage(Page: TfrxReportPage; Index: Integer); virtual;
    procedure StartPage(Page: TfrxReportPage; Index: Integer); virtual;

    property CurPage: Boolean read FCurPage write FCurPage;
    property PageNumbers: String read FPageNumbers write FPageNumbers;
    property Report: TfrxReport read FReport write FReport;
    property Stream: TStream read FStream write FStream;
    property SlaveExport: Boolean read FSlaveExport write FSlaveExport;
    property DefaultExt: String read FDefaultExt write FDefaultExt;
    property FilterDesc: String read FFilterDesc write FFilterDesc;
    property SuppressPageHeadersFooters: Boolean read FSuppressPageHeadersFooters
      write FSuppressPageHeadersFooters;
    property ExportTitle: String read FTitle write FTitle;
  published
    property ShowDialog: Boolean read FShowDialog write FShowDialog default True;
    property FileName: String read FName write FName;
    property ExportNotPrintable: Boolean read FExportNotPrintable write FExportNotPrintable default False;
    property UseFileCache: Boolean read FUseFileCache write FUseFileCache;
    property DefaultPath: String read FDefaultPath write FDefaultPath;
    property ShowProgress: Boolean read FShowProgress write FShowProgress;
  end;

  TfrxCustomWizard = class(TComponent)
  private
    FDesigner: TfrxCustomDesigner;
    FReport: TfrxReport;
  public
    constructor Create(AOwner: TComponent); override;
    class function GetDescription: String; virtual;
    function Execute: Boolean; virtual; abstract;
    property Designer: TfrxCustomDesigner read FDesigner;
    property Report: TfrxReport read FReport;
  end;

  TfrxWizardClass = class of TfrxCustomWizard;


  TfrxCustomEngine = class(TPersistent)

  private
    FCurColumn: Integer;
    FCurVColumn: Integer;
    FCurLine: Integer;
    FCurLineThrough: Integer;
    FCurX: Extended;
    FCurY: Extended;
    FFinalPass: Boolean;
    FHeaderHeight: Extended;
    FNotifyList: TList;
    FPageHeight: Extended;
    FPageWidth: Extended;
    FPreviewPages: TfrxCustomPreviewPages;
    FReport: TfrxReport;
    FRunning: Boolean;
    FStartDate: TDateTime;
    FStartTime: TDateTime;
    FTotalPages: Integer;
    FOnRunDialog: TfrxRunDialogEvent;
    function GetDoublePass: Boolean;
  protected

  public
    constructor Create(AReport: TfrxReport); virtual;
    destructor Destroy; override;
    procedure EndPage; virtual; abstract;
    procedure NewColumn; virtual; abstract;
    procedure NewPage; virtual; abstract;
    procedure ShowBand(Band: TfrxBand); overload; virtual; abstract;
    procedure ShowBand(Band: TfrxBandClass); overload; virtual; abstract;
    procedure ShowBandByName(const BandName: String);
    procedure StopReport;
    function FooterHeight: Extended; virtual; abstract;
    function FreeSpace: Extended; virtual; abstract;
    function GetAggregateValue(const Name, Expression: String;
      Band: TfrxBand;  Flags: Integer): Variant; virtual; abstract;
    function Run: Boolean; virtual; abstract;

    property CurLine: Integer read FCurLine write FCurLine;
    property CurLineThrough: Integer read FCurLineThrough write FCurLineThrough;
    property HeaderHeight: Extended read FHeaderHeight write FHeaderHeight;
    property NotifyList: TList read FNotifyList;
    property PreviewPages: TfrxCustomPreviewPages read FPreviewPages;
    property Report: TfrxReport read FReport;
    property Running: Boolean read FRunning write FRunning;
    property OnRunDialog: TfrxRunDialogEvent read FOnRunDialog write FOnRunDialog;
  published
    property CurColumn: Integer read FCurColumn write FCurColumn;
    property CurVColumn: Integer read FCurVColumn write FCurVColumn;
    property CurX: Extended read FCurX write FCurX;
    property CurY: Extended read FCurY write FCurY;
    property DoublePass: Boolean read GetDoublePass;
    property FinalPass: Boolean read FFinalPass write FFinalPass;
    property PageHeight: Extended read FPageHeight write FPageHeight;
    property PageWidth: Extended read FPageWidth write FPageWidth;
    property StartDate: TDateTime read FStartDate write FStartDate;
    property StartTime: TDateTime read FStartTime write FStartTime;
    property TotalPages: Integer read FTotalPages write FTotalPages;
  end;

  TfrxCustomOutline = class(TPersistent)
  private
    FCurItem: TfrxXMLItem;
    FPreviewPages: TfrxCustomPreviewPages;
  protected
    function GetCount: Integer; virtual; abstract;
  public
    constructor Create(APreviewPages: TfrxCustomPreviewPages); virtual;
    procedure AddItem(const Text: String; Top: Integer); virtual; abstract;
    procedure LevelDown(Index: Integer); virtual; abstract;
    procedure LevelRoot; virtual; abstract;
    procedure LevelUp; virtual; abstract;
    procedure GetItem(Index: Integer; var Text: String;
      var Page, Top: Integer); virtual; abstract;
    procedure ShiftItems(From: TfrxXMLItem; NewTop: Integer); virtual; abstract;
    function Engine: TfrxCustomEngine;
    function GetCurPosition: TfrxXMLItem; virtual; abstract;
    property Count: Integer read GetCount;
    property CurItem: TfrxXMLItem read FCurItem write FCurItem;
    property PreviewPages: TfrxCustomPreviewPages read FPreviewPages;
  end;


  TfrxCustomPreviewPages = class(TObject)

  private
    FAddPageAction: TfrxAddPageAction; { used in the cross-tab renderer }
    FCurPage: Integer;
    FCurPreviewPage: Integer;
    FEngine: TfrxCustomEngine;
    FFirstPage: Integer;               {  used in the composite reports }
    FOutline: TfrxCustomOutline;
    FReport: TfrxReport;
  protected
    function GetCount: Integer; virtual; abstract;
    function GetPage(Index: Integer): TfrxReportPage; virtual; abstract;
    function GetPageSize(Index: Integer): TPoint; virtual; abstract;

  public
    constructor Create(AReport: TfrxReport); virtual;
    destructor Destroy; override;
    procedure Clear; virtual; abstract;

    procedure Initialize; virtual; abstract;


    procedure AddObject(Obj: TfrxComponent); virtual; abstract;
    procedure AddPage(Page: TfrxReportPage); virtual; abstract;
    procedure AddSourcePage(Page: TfrxReportPage); virtual; abstract;
    procedure AddToSourcePage(Obj: TfrxComponent); virtual; abstract;
    procedure BeginPass; virtual; abstract;
    procedure ClearFirstPassPages; virtual; abstract;
    procedure CutObjects(APosition: Integer); virtual; abstract;
    procedure Finish; virtual; abstract;
    procedure IncLogicalPageNumber; virtual; abstract;
    procedure ResetLogicalPageNumber; virtual; abstract;
    procedure PasteObjects(X, Y: Extended); virtual; abstract;
    procedure ShiftAnchors(From, NewTop: Integer); virtual; abstract;
    procedure AddPicture(Picture: TfrxPictureView); virtual; abstract;
    function BandExists(Band: TfrxBand): Boolean; virtual; abstract;
    function GetCurPosition: Integer; virtual; abstract;
    function GetAnchorCurPosition: Integer; virtual; abstract;
    function GetLastY: Extended; virtual; abstract;
    function GetLogicalPageNo: Integer; virtual; abstract;
    function GetLogicalTotalPages: Integer; virtual; abstract;

    procedure AddEmptyPage(Index: Integer); virtual; abstract;
    procedure DeletePage(Index: Integer); virtual; abstract;
    procedure ModifyPage(Index: Integer; Page: TfrxReportPage); virtual; abstract;
    procedure DrawPage(Index: Integer; Canvas: TCanvas; ScaleX, ScaleY,
      OffsetX, OffsetY: Extended); virtual; abstract;
    procedure ObjectOver(Index: Integer; X, Y: Integer; Button: TMouseButton;
      Shift: TShiftState; Scale, OffsetX, OffsetY: Extended;
      Click: Boolean; var Cursor: TCursor); virtual; abstract;
    procedure AddFrom(Report: TfrxReport); virtual; abstract;

    procedure LoadFromStream(Stream: TStream;
      AllowPartialLoading: Boolean = False); virtual; abstract;
    procedure SaveToStream(Stream: TStream); virtual; abstract;
    function LoadFromFile(const FileName: String;
      ExceptionIfNotFound: Boolean = False): Boolean; virtual; abstract;
    procedure SaveToFile(const FileName: String); virtual; abstract;
    function Print: Boolean; virtual; abstract;
    function Export(Filter: TfrxCustomExportFilter): Boolean; virtual; abstract;

    property AddPageAction: TfrxAddPageAction read FAddPageAction write FAddPageAction;
    property Count: Integer read GetCount;
    property CurPage: Integer read FCurPage write FCurPage;
    property CurPreviewPage: Integer read FCurPreviewPage write FCurPreviewPage;
    property Engine: TfrxCustomEngine read FEngine;
    property FirstPage: Integer read FFirstPage write FFirstPage;
    property Outline: TfrxCustomOutline read FOutline;
    property Page[Index: Integer]: TfrxReportPage read GetPage;
    property PageSize[Index: Integer]: TPoint read GetPageSize;
    property Report: TfrxReport read FReport;
  end;

  TfrxCustomPreview = class(TCustomControl)
  private
    FPreviewPages: TfrxCustomPreviewPages;
    FReport: TfrxReport;
  public
    procedure Init; virtual; abstract;
    procedure Lock; virtual; abstract;
    procedure Unlock; virtual; abstract;
    procedure RefreshReport; virtual; abstract;
    procedure InternalOnProgressStart(Sender: TfrxReport;
      ProgressType: TfrxProgressType; Progress: Integer); virtual; abstract;
    procedure InternalOnProgress(Sender: TfrxReport;
      ProgressType: TfrxProgressType; Progress: Integer); virtual; abstract;
    procedure InternalOnProgressStop(Sender: TfrxReport;
      ProgressType: TfrxProgressType; Progress: Integer); virtual; abstract;

    property PreviewPages: TfrxCustomPreviewPages read FPreviewPages write FPreviewPages;
    property Report: TfrxReport read FReport write FReport;
  end;

  TfrxCompressorClass = class of TfrxCustomCompressor;


  TfrxCustomCompressor = class(TComponent)

  private
    FIsFR3File: Boolean;
    FOldCompressor: TfrxCompressorClass;
    FReport: TfrxReport;
    FStream: TStream;
    FTempFile: String;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Decompress(Source: TStream): Boolean; virtual; abstract;
    procedure Compress(Dest: TStream); virtual; abstract;
    procedure CreateStream;
    property IsFR3File: Boolean read FIsFR3File write FIsFR3File;
    property Report: TfrxReport read FReport write FReport;
    property Stream: TStream read FStream write FStream;
  end;

  TfrxCrypterClass = class of TfrxCustomCrypter;

  TfrxCustomCrypter = class(TComponent)
  private
    FStream: TStream;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Decrypt(Source: TStream; const Key: String): Boolean; virtual; abstract;
    procedure Crypt(Dest: TStream; const Key: String); virtual; abstract;
    procedure CreateStream;
    property Stream: TStream read FStream write FStream;
  end;

  TfrxLoadEvent = function(Sender: TfrxReport; Stream: TStream): Boolean of object;
  TfrxGetScriptValueEvent = function(var Params: Variant): Variant of object;

  TfrxFR2Events = class(TObject)
  private
    FOnGetValue: TfrxGetValueEvent;
    FOnPrepareScript: TNotifyEvent;
    FOnLoad: TfrxLoadEvent;
    FOnGetScriptValue: TfrxGetScriptValueEvent;
  public
    property OnGetValue: TfrxGetValueEvent read FOnGetValue write FOnGetValue;
    property OnPrepareScript: TNotifyEvent read FOnPrepareScript write FOnPrepareScript;
    property OnLoad: TfrxLoadEvent read FOnLoad write FOnLoad;
    property OnGetScriptValue: TfrxGetScriptValueEvent read FOnGetScriptValue write FOnGetScriptValue;
  end;

  TfrxGlobalDataSetList = class(TList)
    FCriticalSection: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Lock;
    procedure Unlock;
  end;


function frxParentForm: TForm;
function frxFindDataSet(DataSet: TfrxDataSet; const Name: String;
  Owner: TComponent): TfrxDataSet;
procedure frxGetDataSetList(List: TStrings);

var
  frxDesignerClass: TfrxDesignerClass;
  frxDotMatrixExport: TfrxCustomExportFilter;
  frxCompressorClass: TfrxCompressorClass;
  frxCrypterClass: TfrxCrypterClass;
  frxCharset: Integer = DEFAULT_CHARSET;
  frxFR2Events: TfrxFR2Events;
  frxCS: TCriticalSection;
  frxGlobalVariables: TfrxVariables;

const
  FR_VERSION = {$I frxVersion.inc};
  BND_COUNT = 18;
  frxBands: array[0..BND_COUNT - 1] of TfrxComponentClass =
    (TfrxReportTitle, TfrxReportSummary, TfrxPageHeader, TfrxPageFooter,
     TfrxHeader, TfrxFooter, TfrxMasterData, TfrxDetailData, TfrxSubdetailData,
     TfrxDataBand4, TfrxDataBand5, TfrxDataBand6, TfrxGroupHeader, TfrxGroupFooter,
     TfrxChild, TfrxColumnHeader, TfrxColumnFooter, TfrxOverlay);


implementation

{$R *.RES}


uses
  Registry, frxEngine, frxPreviewPages, frxPreview, frxPrinter, frxUtils,
  frxPassw, frxGraphicUtils, frxDialogForm, frxXMLSerializer, frxAggregate,
  frxRes, frxDsgnIntf, frxrcClass, frxClassRTTI, frxInheritError,
  fs_ipascal, fs_icpp, fs_ibasic, fs_ijs, fs_iclassesrtti,
  fs_igraphicsrtti, fs_iformsrtti, fs_idialogsrtti, fs_iinirtti, frxDMPClass
{$IFDEF JPEG}
, jpeg
{$ENDIF}
{$IFDEF PNG}
, pngimage
{$ENDIF}
;

var
  FParentForm: TForm;
  DatasetList: TfrxGlobalDataSetList;


const
  DefFontName = 'Arial';
  DefFontSize = 10;

type
  TByteSet = set of 0..7;
  PByteSet = ^TByteSet;

  THackControl = class(TControl);
  THackWinControl = class(TWinControl);
  THackPersistent = class(TPersistent);
  THackThread = class(TThread);

  TParentForm = class(TForm)
  protected
    procedure WndProc(var Message: TMessage); override;
  end;

procedure TParentForm.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_CREATEHANDLE:
      TWinControl(Message.WParam).HandleNeeded;
    WM_DESTROYHANDLE:
      THackWinControl(Message.WParam).DestroyHandle;
  else
    inherited;
  end;
end;

function Round8(e: Extended): Extended;
begin
  Result := Round(e * 100000000) / 100000000;
end;

function frxParentForm: TForm;
begin
  if FParentForm = nil then
  begin
    FParentForm := TParentForm.CreateNew(nil);
    FParentForm.HandleNeeded;
  end;
  Result := FParentForm;
end;

function frxFindDataSet(DataSet: TfrxDataSet; const Name: String;
  Owner: TComponent): TfrxDataSet;
var
  i: Integer;
  ds: TfrxDataSet;
begin
  Result := DataSet;
  if Name = '' then
  begin
    Result := nil;
    Exit;
  end;
  if Owner = nil then Exit;
  DatasetList.Lock;
  for i := 0 to DatasetList.Count - 1 do
  begin
    ds := DatasetList[i];
    if AnsiCompareText(ds.UserName, Name) = 0 then
      if not ((Owner is TfrxReport) and (ds.Owner is TfrxReport) and
        (ds.Owner <> Owner)) then
      begin
        Result := DatasetList[i];
        break;
      end;
  end;
  DatasetList.Unlock;
end;

procedure frxGetDataSetList(List: TStrings);
var
  i: Integer;
  ds: TfrxDataSet;
begin
  DatasetList.Lock;
  List.Clear;
  for i := 0 to DatasetList.Count - 1 do
  begin
    ds := DatasetList[i];
    if (ds <> nil) and (ds.UserName <> '') and ds.Enabled then
      List.AddObject(ds.UserName, ds);
  end;
  DatasetList.Unlock;
end;

procedure EmptyParentForm;
begin
  while FParentForm.ControlCount > 0 do
    FParentForm.Controls[0].Parent := nil;
end;


function FloatDiff(const Val1, Val2: Extended): Boolean;
begin
  Result := Abs(Val1 - Val2) > 1e-4;
end;

function ShiftToByte(Value: TShiftState): Byte;
begin
  Result := Byte(PByteSet(@Value)^);
end;


{ TfrxDataset }

constructor TfrxDataSet.Create(AOwner: TComponent);
begin
  inherited;
  FEnabled := True;
  FOpenDataSource := True;
  FRangeBegin := rbFirst;
  FRangeEnd := reLast;
  DatasetList.Lock;
  DatasetList.Add(Self);
  DatasetList.Unlock;
end;

destructor TfrxDataSet.Destroy;
begin
  DatasetList.Lock;
  DatasetList.Remove(Self);
  inherited;
  DatasetList.Unlock;
end;

procedure TfrxDataSet.SetName(const NewName: TComponentName);
begin
  if NewName <> '' then
    if (FUserName = '') or (FUserName = Name) then
      UserName := NewName;
  inherited;
end;

procedure TfrxDataSet.SetUserName(const Value: String);
begin
  if Trim(Value) = '' then
    raise Exception.Create(frxResources.Get('prInvProp'));
  FUserName := Value;
end;

procedure TfrxDataSet.Initialize;
begin
end;

procedure TfrxDataSet.Finalize;
begin
end;

procedure TfrxDataSet.Close;
begin
  if Assigned(FOnClose) then FOnClose(Self);
end;

procedure TfrxDataSet.Open;
begin
  if Assigned(FOnOpen) then FOnOpen(Self);
end;

procedure TfrxDataSet.First;
begin
  FRecNo := 0;
  if Assigned(FOnFirst) then
    FOnFirst(Self);
end;

procedure TfrxDataSet.Next;
begin
  Inc(FRecNo);
  if not ((FRangeEnd = reCount) and (FRecNo >= FRangeEndCount)) then
    if Assigned(FOnNext) then
      FOnNext(Self);
end;

procedure TfrxDataSet.Prior;
begin
  Dec(FRecNo);
  if Assigned(FOnPrior) then
    FOnPrior(Self);
end;

function TfrxDataSet.Eof: Boolean;
begin
  Result := False;
  if (FRangeEnd = reCount) and (FRecNo >= FRangeEndCount) then
    Result := True;
  if Assigned(FOnCheckEOF) then
    FOnCheckEOF(Self, Result);
end;

function TfrxDataSet.GetDisplayText(Index: String): WideString;
begin
  Result := '';
end;

function TfrxDataSet.GetDisplayWidth(Index: String): Integer;
begin
  Result := 10;
end;

procedure TfrxDataSet.GetFieldList(List: TStrings);
begin
  List.Clear;
end;

function TfrxDataSet.GetValue(Index: String): Variant;
begin
  Result := Null;
end;

function TfrxDataSet.HasField(const fName: String): Boolean;
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  GetFieldList(sl);
  Result := sl.IndexOf(fName) <> -1;
  sl.Free;
end;

procedure TfrxDataSet.AssignBlobTo(const fName: String; Obj: TObject);
begin
// empty method
end;

function TfrxDataSet.IsBlobField(const fName: String): Boolean;
begin
  Result := False;
end;

function TfrxDataSet.FieldsCount: Integer;
begin
  Result := 0;
end;

function TfrxDataSet.GetFieldType(Index: String): TfrxFieldType;
begin
  Result := fftNumeric;
end;

function TfrxDataSet.RecordCount: Integer;
begin
  if (RangeBegin = rbFirst) and (RangeEnd = reCount) then
    Result := RangeEndCount
  else
    Result := 0;
end;



{ TfrxUserDataSet }

constructor TfrxUserDataSet.Create(AOwner: TComponent);
begin
  inherited;
  FFields := TStringList.Create;

end;

destructor TfrxUserDataSet.Destroy;
begin
  FFields.Free;
  inherited;
end;

procedure TfrxUserDataSet.SetFields(const Value: TStrings);
begin
  FFields.Assign(Value);
end;

procedure TfrxUserDataSet.GetFieldList(List: TStrings);
begin
  List.Assign(FFields);
end;

function TfrxUserDataSet.FieldsCount: Integer;
begin
  Result := FFields.Count;
end;

function TfrxUserDataSet.GetDisplayText(Index: String): WideString;
var
  v: Variant;
begin
  Result := '';
  if Assigned(FOnGetValue) then
  begin
    v := Null;
    FOnGetValue(Index, v);
    Result := VarToWideStr(v);
  end;
end;

function TfrxUserDataSet.GetValue(Index: String): Variant;
begin
  Result := Null;
  if Assigned(FOnGetValue) then
    FOnGetValue(Index, Result);
end;



{ TfrxCustomDBDataSet }

constructor TfrxCustomDBDataset.Create(AOwner: TComponent);
begin
  FFields := TStringList.Create;
  FFields.Sorted := True;
  FFields.Duplicates := dupIgnore;
  FAliases := TStringList.Create;
  inherited;
end;

destructor TfrxCustomDBDataset.Destroy;
begin
  FFields.Free;
  FAliases.Free;
  inherited;
end;

procedure TfrxCustomDBDataset.SetFieldAliases(const Value: TStrings);
begin
  FAliases.Assign(Value);
end;

function TfrxCustomDBDataset.ConvertAlias(const fName: String): String;
var
  i: Integer;
  s: String;
begin
  Result := fName;
  for i := 0 to FAliases.Count - 1 do
  begin
    s := FAliases[i];
    if AnsiCompareText(Copy(s, Pos('=', s) + 1, MaxInt), fName) = 0 then
    begin
      Result := FAliases.Names[i];
      break;
    end;
  end;
end;

function TfrxCustomDBDataset.GetAlias(const fName: String): String;
var
  i: Integer;
begin
  Result := fName;
  for i := 0 to FAliases.Count - 1 do
    if AnsiCompareText(FAliases.Names[i], fName) = 0 then
    begin
      Result := FAliases[i];
      Result := Copy(Result, Pos('=', Result) + 1, MaxInt);
      break;
    end;
end;

function TfrxCustomDBDataset.FieldsCount: Integer;
var
  sl: TStrings;
begin
  sl := TStringList.Create;
  try
    GetFieldList(sl);
  finally
    Result := sl.Count;
    sl.Free;
  end;
end;


{ TfrxDBComponents }

function TfrxDBComponents.GetDescription: String;
begin
  Result := '';
end;


{ TfrxCustomDatabase }

procedure TfrxCustomDatabase.BeforeConnect(var Value: Boolean);
begin
  if (Report <> nil) and Assigned(Report.OnBeforeConnect) then
    Report.OnBeforeConnect(Self, Value);
end;

function TfrxCustomDatabase.GetConnected: Boolean;
begin
  Result := False;
end;

function TfrxCustomDatabase.GetDatabaseName: String;
begin
  Result := '';
end;

function TfrxCustomDatabase.GetLoginPrompt: Boolean;
begin
  Result := False;
end;

function TfrxCustomDatabase.GetParams: TStrings;
begin
  Result := nil;
end;

procedure TfrxCustomDatabase.SetConnected(Value: Boolean);
begin
// empty
end;

procedure TfrxCustomDatabase.SetDatabaseName(const Value: String);
begin
// empty
end;

procedure TfrxCustomDatabase.SetLogin(const Login, Password: String);
begin
// empty
end;

procedure TfrxCustomDatabase.SetLoginPrompt(Value: Boolean);
begin
// empty
end;

procedure TfrxCustomDatabase.SetParams(Value: TStrings);
begin
// empty
end;


{ TfrxComponent }

constructor TfrxComponent.Create(AOwner: TComponent);
begin
  if AOwner is TfrxComponent then
    inherited Create(TfrxComponent(AOwner).Report)
  else
    inherited Create(AOwner);

  FComponentStyle := [csPreviewVisible];
  FBaseName := ClassName;
  Delete(FBaseName, Pos('Tfrx', FBaseName), 4);
  Delete(FBaseName, Pos('View', FBaseName), 4);
  FObjects := TList.Create;
  FAllObjects := TList.Create;


  FFont := TFont.Create;

  with FFont do
  begin
    PixelsPerInch := 96;
    Name := DefFontName;
    Size := DefFontSize;
    Color := clBlack;
    Charset := frxCharset;
    OnChange := FontChanged;
  end;

  FVisible := True;
  ParentFont := True;
  if AOwner is TfrxComponent then
    SetParent(TfrxComponent(AOwner));
end;

constructor TfrxComponent.DesignCreate(AOwner: TComponent; Flags: Word);
begin
  FIsDesigning := True;
  Create(AOwner);
end;

destructor TfrxComponent.Destroy;
begin
  SetParent(nil);
  Clear;
  FFont.Free;
  FObjects.Free;
  FAllObjects.Free;
  inherited;
end;

procedure TfrxComponent.Assign(Source: TPersistent);
var
  s: TMemoryStream;
begin
  if Source is TfrxComponent then
  begin
    s := TMemoryStream.Create;
    try
      TfrxComponent(Source).SaveToStream(s, False, True);
      s.Position := 0;
      LoadFromStream(s);
    finally
      s.Free;
    end;
  end;
end;

procedure TfrxComponent.AssignAll(Source: TfrxComponent);
var
  s: TMemoryStream;
begin
  s := TMemoryStream.Create;
  try
    Source.SaveToStream(s, True, True);
    s.Position := 0;
    LoadFromStream(s);
  finally
    s.Free;
  end;
end;

procedure TfrxComponent.LoadFromStream(Stream: TStream);
var
  Reader: TfrxXMLSerializer;
begin
  Clear;
  Reader := TfrxXMLSerializer.Create(Stream);
  if Report <> nil then
    Report.FXMLSerializer := Reader;

  try
    Reader.Owner := Report;
    if (Report <> nil) and Report.EngineOptions.EnableThreadSafe then
    begin
      frxCS.Enter;
      try
        Reader.ReadRootComponent(Self, nil);
      finally
        frxCS.Leave;
      end;
    end
    else
      Reader.ReadRootComponent(Self, nil);

    if Report <> nil then
      Report.Errors.AddStrings(Reader.Errors);

  finally
    Reader.Free;
    if Report <> nil then
      Report.FXMLSerializer := nil;
  end;
end;

procedure TfrxComponent.SaveToStream(Stream: TStream; SaveChildren: Boolean = True;
  SaveDefaultValues: Boolean = False);
var
  Writer: TfrxXMLSerializer;
begin
  Writer := TfrxXMLSerializer.Create(Stream);

  try
    Writer.Owner := Report;
    Writer.SerializeDefaultValues := SaveDefaultValues;
    if Self is TfrxReport then
      Writer.OnGetAncestor := Report.DoGetAncestor;
    Writer.WriteRootComponent(Self, SaveChildren);
  finally
    Writer.Free;
  end;
end;

procedure TfrxComponent.Clear;
var
  i: Integer;
  c: TfrxComponent;
begin
  i := 0;
  while i < FObjects.Count do
  begin
    c := FObjects[i];
    if (csAncestor in c.ComponentState) then
    begin
      c.Clear;
      Inc(i);
    end
    else
      c.Free;
  end;
end;

procedure TfrxComponent.SetParent(AParent: TfrxComponent);
begin
  if FParent <> AParent then
  begin
    if FParent <> nil then
      FParent.FObjects.Remove(Self);
    if AParent <> nil then
      AParent.FObjects.Add(Self);
  end;

  FParent := AParent;
  if FParent <> nil then
    SetParentFont(FParentFont);
end;

procedure TfrxComponent.SetBounds(ALeft, ATop, AWidth, AHeight: Extended);
begin
  Left := ALeft;
  Top := ATop;
  Width := AWidth;
  Height := AHeight;
end;

function TfrxComponent.GetPage: TfrxPage;
var
  p: TfrxComponent;
begin
  if Self is TfrxPage then
  begin
    Result := TfrxPage(Self);
    Exit;
  end;

  Result := nil;
  p := Parent;
  while p <> nil do
  begin
    if p is TfrxPage then
    begin
      Result := TfrxPage(p);
      Exit;
    end;
    p := p.Parent;
  end;
end;

function TfrxComponent.GetReport: TfrxReport;
var
  p: TfrxComponent;
begin
  if Self is TfrxReport then
  begin
    Result := TfrxReport(Self);
    Exit;
  end;

  Result := nil;
  p := Parent;
  while p <> nil do
  begin
    if p is TfrxReport then
    begin
      Result := TfrxReport(p);
      Exit;
    end;
    p := p.Parent;
  end;
end;

function TfrxComponent.GetIsLoading: Boolean;
begin
  Result := FIsLoading or (csLoading in ComponentState);
end;

function TfrxComponent.GetAbsTop: Extended;
begin
  if (Parent <> nil) and not (Parent is TfrxDialogPage) then
    Result := Parent.AbsTop + Top else
    Result := Top;
end;

function TfrxComponent.GetAbsLeft: Extended;
begin
  if (Parent <> nil) and not (Parent is TfrxDialogPage) then
    Result := Parent.AbsLeft + Left else
    Result := Left;
end;

procedure TfrxComponent.SetLeft(Value: Extended);
begin
  if not IsDesigning or not (rfDontMove in FRestrictions) then
    FLeft := Value;
end;

procedure TfrxComponent.SetTop(Value: Extended);
begin
  if not IsDesigning or not (rfDontMove in FRestrictions) then
    FTop := Value;
end;

procedure TfrxComponent.SetWidth(Value: Extended);
begin
  if not IsDesigning or not (rfDontSize in FRestrictions) then
    FWidth := Value;
end;

procedure TfrxComponent.SetHeight(Value: Extended);
begin
  if not IsDesigning or not (rfDontSize in FRestrictions) then
    FHeight := Value;
end;

function TfrxComponent.IsFontStored: Boolean;
begin
  Result := not FParentFont;
end;

procedure TfrxComponent.SetFont(Value: TFont);
begin
  FFont.Assign(Value);
  FParentFont := False;
end;

procedure TfrxComponent.SetParentFont(const Value: Boolean);
begin
  if Value then
    if Parent <> nil then
      Font := Parent.Font;
  FParentFont := Value;
end;

procedure TfrxComponent.SetVisible(Value: Boolean);
begin
  FVisible := Value;
end;

procedure TfrxComponent.FontChanged(Sender: TObject);
var
  i: Integer;
  c: TfrxComponent;
begin
  FParentFont := False;
  for i := 0 to FObjects.Count - 1 do
  begin
    c := FObjects[i];
    if c.ParentFont then
      c.ParentFont := True;
  end;
end;

function TfrxComponent.GetAllObjects: TList;

  procedure EnumObjects(c: TfrxComponent);
  var
    i: Integer;
  begin
    if c <> Self then
      FAllObjects.Add(c);
    for i := 0 to c.FObjects.Count - 1 do
      EnumObjects(c.FObjects[i]);
  end;

begin
  FAllObjects.Clear;
  EnumObjects(Self);
  Result := FAllObjects;
end;

procedure TfrxComponent.SetName(const AName: TComponentName);
var
  c: TfrxComponent;
begin
  if CompareText(AName, Name) = 0 then Exit;

  if (AName <> '') and (Report <> nil) then
  begin
    c := Report.FindObject(AName);
    if (c <> nil) and (c <> Self) then
      raise Exception.Create(frxResources.Get('prDupl'));
    if IsAncestor then
      raise Exception.Create('Could not rename ' + Name + ', it was introduced in the ancestor report');
  end;
  inherited;
end;

procedure TfrxComponent.CreateUniqueName;
var
  i: Integer;
  l: TList;
  sl: TStringList;
begin
  sl := TStringList.Create;
  sl.Sorted := True;
  sl.Duplicates := dupIgnore;

  if Report <> nil then
    l := Report.AllObjects else
    l := Parent.AllObjects;
  for i := 0 to l.Count - 1 do
    sl.Add(TfrxComponent(l[i]).Name);

  i := 1;
  while sl.IndexOf(FBaseName + IntToStr(i)) <> -1 do
    Inc(i);

  Name := FBaseName + IntToStr(i);
  sl.Free;
end;

function TfrxComponent.Diff(AComponent: TfrxComponent): String;
begin
  Result := InternalDiff(AComponent);
end;

function TfrxComponent.DiffFont(f1, f2: TFont; const Add: String): String;
var
  fs: Integer;
begin
  Result := '';

  if f1.Name <> f2.Name then
    Result := Result + Add + 'Font.Name="' + frxStrToXML(f1.Name) + '"';
  if f1.Size <> f2.Size then
    Result := Result + Add + 'Font.Size="' + IntToStr(f1.Size) + '"';
  if f1.Color <> f2.Color then
    Result := Result + Add + 'Font.Color="' + IntToStr(f1.Color) + '"';
  if f1.Style <> f2.Style then
  begin
    fs := 0;
    if fsBold in f1.Style then fs := 1;
    if fsItalic in f1.Style then fs := fs or 2;
    if fsUnderline in f1.Style then fs := fs or 4;
    if fsStrikeout in f1.Style then fs := fs or 8;
    Result := Result + Add + 'Font.Style="' + IntToStr(fs) + '"';
  end;
  if f1.Charset <> f2.Charset then
    Result := Result + Add + 'Font.Charset="' + IntToStr(f1.Charset) + '"';
end;

function TfrxComponent.InternalDiff(AComponent: TfrxComponent): String;
begin
  Result := '';

  if not ((Self is TfrxView) and (TfrxView(Self).FAlign <> baNone)) then
    if FloatDiff(FLeft, AComponent.FLeft) then
      Result := Result + ' l="' + FloatToStr(FLeft) + '"';
  if (Self is TfrxBand) or FloatDiff(FTop, AComponent.FTop) then
    Result := Result + ' t="' + FloatToStr(FTop) + '"';
  if not ((Self is TfrxCustomMemoView) and TfrxCustomMemoView(Self).FAutoWidth) then
    if FloatDiff(FWidth, AComponent.FWidth) then
      Result := Result + ' w="' + FloatToStr(FWidth) + '"';
  if FloatDiff(FHeight, AComponent.FHeight) then
    Result := Result + ' h="' + FloatToStr(FHeight) + '"';
  if FVisible <> AComponent.FVisible then
    Result := Result + ' Visible="' + frxValueToXML(FVisible) + '"';
  if not FParentFont then
    Result := Result + DiffFont(FFont, AComponent.FFont, ' ');
  if FParentFont <> AComponent.FParentFont then
    Result := Result + ' ParentFont="' + frxValueToXML(FParentFont) + '"';
  if Tag <> AComponent.Tag then
    Result := Result + ' Tag="' + IntToStr(Tag) + '"';
end;

function TfrxComponent.AllDiff(AComponent: TfrxComponent): String;
var
  s: TStringStream;
  Writer: TfrxXMLSerializer;
  i: Integer;
begin
  s := TStringStream.Create('');
  Writer := TfrxXMLSerializer.Create(s);
  Writer.Owner := Report;
  Writer.WriteComponent(Self);
  Writer.Free;

  Result := s.DataString;
  i := Pos(' ', Result);
  if i <> 0 then
  begin
    Delete(Result, 1, i);
    Delete(Result, Length(Result) - 1, 2);
  end
  else
    Result := '';
  if AComponent <> nil then
    Result := Result + ' ' + InternalDiff(AComponent);

  s.Free;
end;

procedure TfrxComponent.AlignChildren;
var
  i: Integer;
  c: TfrxComponent;
  sl: TStringList;

  procedure DoAlign(v: TfrxView; n, dir: Integer);
  var
    i: Integer;
    c, c0: TfrxComponent;
  begin
    c0 := nil;
    i := n;
    while (i >= 0) and (i < sl.Count) do
    begin
      c := TfrxComponent(sl.Objects[i]);
      if c <> v then
        if (c.AbsTop < v.AbsTop + v.Height - 1e-4) and
          (v.AbsTop < c.AbsTop + c.Height - 1e-4) then
        begin
          { special case for baWidth }
          if (v.Align = baWidth) and
            (((dir = 1) and (c.Left > v.Left)) or
            ((dir = -1) and (c.Left + c.Width < v.Left + v.Width))) then
          begin
            Dec(i, dir);
            continue;
          end;
          c0 := c;
          break;
        end;
      Dec(i, dir);
    end;

    if (dir = 1) and (v.Align in [baLeft, baWidth]) then
      if c0 = nil then
        v.Left := 0 else
        v.Left := c0.Left + c0.Width;

    if v.Align = baRight then
      if c0 = nil then
        v.Left := Width - v.Width else
        v.Left := c0.Left - v.Width;

    if (dir = -1) and (v.Align = baWidth) then
      if c0 = nil then
        v.Width := Width - v.Left else
        v.Width := c0.Left - v.Left;
  end;

begin
  sl := TStringList.Create;
  sl.Sorted := True;
  sl.Duplicates := dupAccept;

  for i := 0 to FObjects.Count - 1 do
  begin
    c := FObjects[i];
    if c is TfrxView then
      if c.Left >= 0 then
        sl.AddObject('1' + Format('%9.2f', [c.Left]), c)
      else
        sl.AddObject('0' + Format('%9.2f', [-c.Left]), c);
  end;

  { process baLeft }

  for i := 0 to sl.Count - 1 do
  begin
    c := TfrxComponent(sl.Objects[i]);
    if c is TfrxView then
      if TfrxView(c).Align in [baLeft, baWidth] then
        DoAlign(TfrxView(c), i, 1);
  end;

  { process baRight }

  for i := sl.Count - 1 downto 0 do
  begin
    c := TfrxComponent(sl.Objects[i]);
    if c is TfrxView then
      if TfrxView(c).Align in [baRight, baWidth] then
        DoAlign(TfrxView(c), i, -1);
  end;

  { process others }

  for i := 0 to FObjects.Count - 1 do
  begin
    c := FObjects[i];
    if c is TfrxView then
      case TfrxView(c).Align of
        baCenter:
          c.Left := (Width - c.Width) / 2;

        baBottom:
          c.Top := Height - c.Height;

        baClient:
          begin
            c.Left := 0;
            c.Top := 0;
            c.Width := Width;
            c.Height := Height;
          end;
      end;
  end;

  sl.Free;
end;

function TfrxComponent.FindObject(const AName: String): TfrxComponent;
var
  i: Integer;
  l: TList;
begin
  Result := nil;
  l := AllObjects;
  for i := 0 to l.Count - 1 do
    if CompareText(AName, TfrxComponent(l[i]).Name) = 0 then
    begin
      Result := l[i];
      break;
    end;
end;

class function TfrxComponent.GetDescription: String;
begin
  Result := ClassName;
end;

function TfrxComponent.GetChildOwner: TComponent;
begin
  Result := Self;
end;

procedure TfrxComponent.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  i: Integer;
begin
  if (Self is TfrxReport) and not TfrxReport(Self).StoreInDFM then
    Exit;
  for i := 0 to FObjects.Count - 1 do
    Proc(FObjects[i]);
end;

procedure TfrxComponent.BeforeStartReport;
begin
// do nothing
end;

procedure TfrxComponent.OnNotify(Sender: TObject);
begin
// do nothing
end;

procedure TfrxComponent.OnPaste;
begin
//
end;

function TfrxComponent.GetIsAncestor: Boolean;
begin
  Result := (csAncestor in ComponentState) or FAncestor;
end;

function TfrxComponent.GetContainerObjects: TList;
begin
  Result := FObjects;
end;

function TfrxComponent.ContainerAdd(Obj: TfrxComponent): Boolean;
begin
  Result := False;
end;

function TfrxComponent.ContainerMouseDown(Sender: TObject; X, Y: Integer): Boolean;
begin
  Result := False;
end;

procedure TfrxComponent.ContainerMouseMove(Sender: TObject; X, Y: Integer);
begin
end;

procedure TfrxComponent.ContainerMouseUp(Sender: TObject; X, Y: Integer);
begin
end;




{ TfrxReportComponent }

constructor TfrxReportComponent.Create(AOwner: TComponent);
begin
  inherited;
  FShiftChildren := TList.Create;
end;

destructor TfrxReportComponent.Destroy;
begin
  FShiftChildren.Free;
  inherited;
end;

procedure TfrxReportComponent.GetData;
begin
// do nothing
end;

procedure TfrxReportComponent.BeforePrint;
begin
  FOriginalRect := frxRect(Left, Top, Width, Height);
end;

procedure TfrxReportComponent.AfterPrint;
begin
  with FOriginalRect do
    SetBounds(Left, Top, Right, Bottom);
end;

function TfrxReportComponent.GetComponentText: String;
begin
  Result := '';
end;

function TfrxReportComponent.GetRealBounds: TfrxRect;
begin
  Result := frxRect(AbsLeft, AbsTop, AbsLeft + Width, AbsTop + Height);
end;


{ TfrxDialogComponent }

constructor TfrxDialogComponent.Create(AOwner: TComponent);
begin
  inherited;
  frComponentStyle := frComponentStyle - [csPreviewVisible];
  if not (Self is TfrxUserDataSet) then
  begin
    FBitmap := TBitmap.Create;
    FBitmap.Width := 22;
    FBitmap.Height := 22;
    with FBitmap.Canvas do
    begin
      Brush.Color := clBtnFace;
      FillRect(Rect(0, 0, 22, 22));
    end;
  end;

  FImageIndex := -1;
  Width := 28;
  Height := 28;
end;

destructor TfrxDialogComponent.Destroy;
begin
  if FComponent <> nil then
    FComponent.Free;
  FComponent := nil;
  if FBitmap <> nil then
    FBitmap.Free;
  inherited;
end;

procedure TfrxDialogComponent.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineProperty('pLeft', ReadLeft, WriteLeft, Report <> nil);
  Filer.DefineProperty('pTop', ReadTop, WriteTop, Report <> nil);
end;

procedure TfrxDialogComponent.ReadLeft(Reader: TReader);
begin
  Left := Reader.ReadInteger;
end;

procedure TfrxDialogComponent.ReadTop(Reader: TReader);
begin
  Top := Reader.ReadInteger;
end;

procedure TfrxDialogComponent.WriteLeft(Writer: TWriter);
begin
  Writer.WriteInteger(Round(Left));
end;

procedure TfrxDialogComponent.WriteTop(Writer: TWriter);
begin
  Writer.WriteInteger(Round(Top));
end;

procedure TfrxDialogComponent.Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX,
  OffsetY: Extended);
var
  r: TRect;
  w: Integer;
begin
  Width := 28;
  Height := 28;
  r := Rect(Round(Left), Round(Top), Round(Left + 28), Round(Top + 28));
  Canvas.Brush.Color := clBtnFace;
  Canvas.FillRect(r);
  DrawEdge(Canvas.Handle, r, EDGE_RAISED, BF_RECT);
  if FBitmap <> nil then
  begin
    if FImageIndex <> -1 then
      frxResources.ObjectImages.Draw(FBitmap.Canvas, 3, 3, FImageIndex);
    Canvas.Draw(r.Left + 3, r.Top + 3, FBitmap);
  end;

  Canvas.Font.Name := 'Tahoma';
  Canvas.Font.Size := 8;
  Canvas.Font.Color := clBlack;
  Canvas.Font.Style := [];
  w := Canvas.TextWidth(Name);
  Canvas.Brush.Color := clWindow;
  Canvas.TextOut(r.Left - (w - 28) div 2, r.Bottom + 4, Name);
end;


{ TfrxDialogControl }

constructor TfrxDialogControl.Create(AOwner: TComponent);
begin
  inherited;
  FBaseName := ClassName;
  Delete(FBaseName, Pos('Tfrx', FBaseName), 4);
  Delete(FBaseName, Pos('Control', FBaseName), 7);
end;

destructor TfrxDialogControl.Destroy;
begin
  inherited;
  if FControl <> nil then
    FControl.Free;
  FControl := nil;
end;

procedure TfrxDialogControl.InitControl(AControl: TControl);
begin
  FControl := AControl;
  with THackControl(FControl) do
  begin
    OnClick := DoOnClick;
    OnDblClick := DoOnDblClick;
    OnMouseDown := DoOnMouseDown;
    OnMouseMove := DoOnMouseMove;
    OnMouseUp := DoOnMouseUp;
  end;
  if FControl is TWinControl then
    with THackWinControl(FControl) do
    begin
      OnEnter := DoOnEnter;
      OnExit := DoOnExit;
      OnKeyDown := DoOnKeyDown;
      OnKeyPress := DoOnKeyPress;
      OnKeyUp := DoOnKeyUp;
    end;
  SetParent(Parent);
end;

procedure TfrxDialogControl.Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX,
  OffsetY: Extended);
var
  Bmp: TBitmap;
  MemDC: HDC;
  OldBitmap: HBITMAP;
begin
  Bmp := TBitmap.Create;
  Bmp.Width := Round(Width);
  Bmp.Height := Round(Height);
  Bmp.Canvas.Brush.Color := clBtnFace;
  Bmp.Canvas.FillRect(Rect(0, 0, Round(Width) + 1, Round(Height) + 1));

  Canvas.Lock;
  try
    MemDC := CreateCompatibleDC(0);
    OldBitmap := SelectObject(MemDC, Bmp.Handle);
    if FControl is TWinControl then
      TWinControl(FControl).PaintTo(MemDC, 0, 0)
    else
    begin
      FControl.Perform(WM_ERASEBKGND, MemDC, 0);
      FControl.Perform(WM_PAINT, MemDC, 0);
    end;
    SelectObject(MemDC, OldBitmap);
    DeleteDC(MemDC);
  finally
    Canvas.Unlock;
  end;

  Canvas.Draw(Round(AbsLeft), Round(AbsTop), Bmp);
  Bmp.Free;
end;

function TfrxDialogControl.GetCaption: String;
begin
  Result := THackControl(FControl).Caption;
end;

function TfrxDialogControl.GetColor: TColor;
begin
  Result := THackControl(FControl).Color;
end;

function TfrxDialogControl.GetEnabled: Boolean;
begin
  Result := FControl.Enabled;
end;

procedure TfrxDialogControl.SetLeft(Value: Extended);
begin
  inherited;
  FControl.Left := Round(Left);
end;

procedure TfrxDialogControl.SetTop(Value: Extended);
begin
  inherited;
  FControl.Top := Round(Top);
end;

procedure TfrxDialogControl.SetWidth(Value: Extended);
begin
  inherited;
  FControl.Width := Round(Width);
end;

procedure TfrxDialogControl.SetHeight(Value: Extended);
begin
  inherited;
  FControl.Height := Round(Height);
end;

procedure TfrxDialogControl.SetVisible(Value: Boolean);
begin
  inherited;
  FControl.Visible := Visible;
end;

procedure TfrxDialogControl.SetCaption(const Value: String);
begin
  THackControl(FControl).Caption := Value;
end;

procedure TfrxDialogControl.SetColor(const Value: TColor);
begin
  THackControl(FControl).Color := Value;
end;

procedure TfrxDialogControl.SetEnabled(const Value: Boolean);
begin
  FControl.Enabled := Value;
end;

function TfrxDialogControl.GetHint: String;
begin
  Result := FControl.Hint;
end;

procedure TfrxDialogControl.SetHint(const Value: String);
begin
  FControl.Hint := Value;
end;

function TfrxDialogControl.GetTabStop: Boolean;
begin
  Result := True;
  if FControl is TWinControl then
    Result := THackWinControl(FControl).TabStop;
end;

procedure TfrxDialogControl.SetTabStop(const Value: Boolean);
begin
  if FControl is TWinControl then
    THackWinControl(FControl).TabStop := Value;
end;

procedure TfrxDialogControl.FontChanged(Sender: TObject);
begin
  inherited;
  if FControl <> nil then
    THackControl(FControl).Font.Assign(Font);
end;

procedure TfrxDialogControl.SetParentFont(const Value: Boolean);
begin
  inherited;
  if FControl <> nil then
    THackControl(FControl).ParentFont := Value;
end;

procedure TfrxDialogControl.SetParent(AParent: TfrxComponent);
begin
  inherited;
  if FControl <> nil then
    if AParent is TfrxDialogControl then
      FControl.Parent := TWinControl(TfrxDialogControl(AParent).Control)
    else if AParent is TfrxDialogPage then
      FControl.Parent := TfrxDialogPage(AParent).DialogForm
    else
      FControl.Parent := frxParentForm;
end;

procedure TfrxDialogControl.SetName(const AName: TComponentName);
var
  ChangeText: Boolean;
begin
  ChangeText := (csSetCaption in FControl.ControlStyle) and (Name = Caption) and
    not IsLoading;
  inherited SetName(AName);
  if ChangeText then
    Caption := AName;
end;

procedure TfrxDialogControl.DoOnClick(Sender: TObject);
begin
  if Report <> nil then
    Report.DoNotifyEvent(Self, FOnClick);
end;

procedure TfrxDialogControl.DoOnDblClick(Sender: TObject);
begin
  if Report <> nil then
    Report.DoNotifyEvent(Self, FOnDblClick);
end;

procedure TfrxDialogControl.DoOnEnter(Sender: TObject);
begin
  if Report <> nil then
    Report.DoNotifyEvent(Self, FOnEnter);
end;

procedure TfrxDialogControl.DoOnExit(Sender: TObject);
begin
  if Report <> nil then
    Report.DoNotifyEvent(Self, FOnExit);
end;

procedure TfrxDialogControl.DoOnKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  v: Variant;
begin
  v := VarArrayOf([Integer(Self), Key, ShiftToByte(Shift)]);
  if (Report <> nil) and (FOnKeyDown <> '') then
  begin
    Report.DoParamEvent(FOnKeyDown, v);
    Key := v[1];
  end;
end;

procedure TfrxDialogControl.DoOnKeyPress(Sender: TObject; var Key: Char);
var
  v: Variant;
begin
  v := VarArrayOf([Integer(Self), Key]);
  if (Report <> nil) and (FOnKeyPress <> '') then
  begin
    Report.DoParamEvent(FOnKeyPress, v);
    if VarToStr(v[1]) <> '' then
      Key := VarToStr(v[1])[1]
    else
      Key := Chr(0);
  end;
end;

procedure TfrxDialogControl.DoOnKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  v: Variant;
begin
  v := VarArrayOf([Integer(Self), Key, ShiftToByte(Shift)]);
  if (Report <> nil) and (FOnKeyUp <> '') then
  begin
    Report.DoParamEvent(FOnKeyUp, v);
    Key := v[1];
  end;
end;

procedure TfrxDialogControl.DoOnMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  v: Variant;
begin
  v := VarArrayOf([Integer(Self), Button, ShiftToByte(Shift), X, Y]);
  if Report <> nil then
    Report.DoParamEvent(FOnMouseDown, v);
end;

procedure TfrxDialogControl.DoOnMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  v: Variant;
begin
  v := VarArrayOf([Integer(Self), ShiftToByte(Shift), X, Y]);
  if Report <> nil then
    Report.DoParamEvent(FOnMouseMove, v);
end;

procedure TfrxDialogControl.DoOnMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  v: Variant;
begin
  v := VarArrayOf([Integer(Self), Button, ShiftToByte(Shift), X, Y]);
  if Report <> nil then
    Report.DoParamEvent(FOnMouseUp, v);
end;


{ TfrxFrameLine }

constructor TfrxFrameLine.Create(AFrame: TfrxFrame);
begin
  FColor := clBlack;
  FStyle := fsSolid;
  FWidth := 1;
  FFrame := AFrame;
end;

procedure TfrxFrameLine.Assign(Source: TPersistent);
begin
  if Source is TfrxFrameLine then
  begin
    FColor := TfrxFrameLine(Source).Color;
    FStyle := TfrxFrameLine(Source).Style;
    FWidth := TfrxFrameLine(Source).Width;
  end;
end;

function TfrxFrameLine.IsColorStored: Boolean;
begin
  Result := FColor <> FFrame.Color;
end;

function TfrxFrameLine.IsStyleStored: Boolean;
begin
  Result := FStyle <> FFrame.Style;
end;

function TfrxFrameLine.IsWidthStored: Boolean;
begin
  Result := FWidth <> FFrame.Width;
end;

function TfrxFrameLine.Diff(ALine: TfrxFrameLine; const LineName: String): String;
begin
  Result := '';

  if FColor <> ALine.Color then
    Result := Result + ' ' + LineName + '.Color="' + IntToStr(FColor) + '"';
  if FStyle <> ALine.Style then
    Result := Result + ' ' + LineName + '.Style="' + frxValueToXML(FStyle) + '"';
  if FloatDiff(FWidth, ALine.Width) then
    Result := Result + ' ' + LineName + '.Width="' + FloatToStr(FWidth) + '"';
end;


{ TfrxFrame }

constructor TfrxFrame.Create;
begin
  FColor := clBlack;
  FShadowColor := clBlack;
  FShadowWidth := 4;
  FStyle := fsSolid;
  FTyp := [];
  FWidth := 1;

  FLeftLine := TfrxFrameLine.Create(Self);
  FTopLine := TfrxFrameLine.Create(Self);
  FRightLine := TfrxFrameLine.Create(Self);
  FBottomLine := TfrxFrameLine.Create(Self);
end;

destructor TfrxFrame.Destroy;
begin
  FLeftLine.Free;
  FTopLine.Free;
  FRightLine.Free;
  FBottomLine.Free;
  inherited;
end;

procedure TfrxFrame.Assign(Source: TPersistent);
begin
  if Source is TfrxFrame then
  begin
    FColor := TfrxFrame(Source).Color;
    FDropShadow := TfrxFrame(Source).DropShadow;
    FShadowColor := TfrxFrame(Source).ShadowColor;
    FShadowWidth := TfrxFrame(Source).ShadowWidth;
    FStyle := TfrxFrame(Source).Style;
    FTyp := TfrxFrame(Source).Typ;
    FWidth := TfrxFrame(Source).Width;

    FLeftLine.Assign(TfrxFrame(Source).LeftLine);
    FTopLine.Assign(TfrxFrame(Source).TopLine);
    FRightLine.Assign(TfrxFrame(Source).RightLine);
    FBottomLine.Assign(TfrxFrame(Source).BottomLine);
  end;
end;

function TfrxFrame.IsShadowWidthStored: Boolean;
begin
  Result := FShadowWidth <> 4;
end;

function TfrxFrame.IsTypStored: Boolean;
begin
  Result := FTyp <> [];
end;

function TfrxFrame.IsWidthStored: Boolean;
begin
  Result := FWidth <> 1;
end;

procedure TfrxFrame.SetBottomLine(const Value: TfrxFrameLine);
begin
  FBottomLine.Assign(Value);
end;

procedure TfrxFrame.SetLeftLine(const Value: TfrxFrameLine);
begin
  FLeftLine.Assign(Value);
end;

procedure TfrxFrame.SetRightLine(const Value: TfrxFrameLine);
begin
  FRightLine.Assign(Value);
end;

procedure TfrxFrame.SetTopLine(const Value: TfrxFrameLine);
begin
  FTopLine.Assign(Value);
end;

procedure TfrxFrame.SetColor(const Value: TColor);
begin
  FColor := Value;
  FLeftLine.Color := Value;
  FTopLine.Color := Value;
  FRightLine.Color := Value;
  FBottomLine.Color := Value;
end;

procedure TfrxFrame.SetStyle(const Value: TfrxFrameStyle);
begin
  FStyle := Value;
  FLeftLine.Style := Value;
  FTopLine.Style := Value;
  FRightLine.Style := Value;
  FBottomLine.Style := Value;
end;

procedure TfrxFrame.SetWidth(const Value: Extended);
begin
  FWidth := Value;
  FLeftLine.Width := Value;
  FTopLine.Width := Value;
  FRightLine.Width := Value;
  FBottomLine.Width := Value;
end;

function TfrxFrame.Diff(AFrame: TfrxFrame): String;
var
  i: Integer;
begin
  Result := '';

  if FColor <> AFrame.Color then
    Result := Result + ' Frame.Color="' + IntToStr(FColor) + '"';
  if FDropShadow <> AFrame.DropShadow then
    Result := Result + ' Frame.DropShadow="' + frxValueToXML(FDropShadow) + '"';
  if FShadowColor <> AFrame.ShadowColor then
    Result := Result + ' Frame.ShadowColor="' + IntToStr(FShadowColor) + '"';
  if FloatDiff(FShadowWidth, AFrame.ShadowWidth) then
    Result := Result + ' Frame.ShadowWidth="' + FloatToStr(FShadowWidth) + '"';
  if FStyle <> AFrame.Style then
    Result := Result + ' Frame.Style="' + frxValueToXML(FStyle) + '"';
  if FTyp <> AFrame.Typ then
  begin
    i := 0;
    if ftLeft in FTyp then i := i or 1;
    if ftRight in FTyp then i := i or 2;
    if ftTop in FTyp then i := i or 4;
    if ftBottom in FTyp then i := i or 8;
    Result := Result + ' Frame.Typ="' + IntToStr(i) + '"';
  end;
  if FloatDiff(FWidth, AFrame.Width) then
    Result := Result + ' Frame.Width="' + FloatToStr(FWidth) + '"';

  Result := Result + FLeftLine.Diff(AFrame.LeftLine, 'LeftLine');
  Result := Result + FTopLine.Diff(AFrame.TopLine, 'TopLine');
  Result := Result + FRightLine.Diff(AFrame.RightLine, 'RightLine');
  Result := Result + FBottomLine.Diff(AFrame.BottomLine, 'BottomLine');
end;




{ TfrxView }

constructor TfrxView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  frComponentStyle := frComponentStyle + [csDefaultDiff];
  FAlign := baNone;
  FBrushStyle := bsSolid;
  FColor := clTransparent;
  FFrame := TfrxFrame.Create;
  FShiftMode := smAlways;
  FPrintable := True;
  FPlainText := False;
end;

destructor TfrxView.Destroy;
begin
  FFrame.Free;
  inherited;
end;

procedure TfrxView.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FDataSet) then
    FDataSet := nil;
end;

procedure TfrxView.SetDataSet(const Value: TfrxDataSet);
begin
  FDataSet := Value;
  if FDataSet = nil then
    FDataSetName := '' else
    FDataSetName := FDataSet.UserName;
end;

procedure TfrxView.SetDataSetName(const Value: String);
begin
  FDataSetName := Value;
  FDataSet := frxFindDataSet(FDataSet, FDataSetName, Report);
end;

function TfrxView.GetDataSetName: String;
begin
  if FDataSet = nil then
    Result := FDataSetName else
    Result := FDataSet.UserName;
end;

procedure TfrxView.SetFrame(const Value: TfrxFrame);
begin
  FFrame.Assign(Value);
end;

procedure TfrxView.BeginDraw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended);
begin
  FCanvas := Canvas;
  FScaleX := ScaleX;
  FScaleY := ScaleY;
  FOffsetX := OffsetX;
  FOffsetY := OffsetY;
  FX := Round(AbsLeft * ScaleX + OffsetX);
  FY := Round(AbsTop * ScaleY + OffsetY);
  FX1 := Round((AbsLeft + Width) * ScaleX + OffsetX);
  FY1 := Round((AbsTop + Height) * ScaleY + OffsetY);

  if Frame.DropShadow then
  begin
    FX1 := FX1 - Round(Frame.ShadowWidth * ScaleX);
    FY1 := FY1 - Round(Frame.ShadowWidth * ScaleY);
  end;

  FDX := FX1 - FX;
  FDY := FY1 - FY;
  FFrameWidth := Round(Frame.Width * ScaleX);
end;

procedure TfrxView.DrawBackground;
var
  br, oldbr: HBRUSH;
begin
  with FCanvas do
  begin
    if FColor <> clNone then
    begin
      Brush.Color := FColor;
      Brush.Style := bsSolid;
      FillRect(Rect(FX, FY, FX1, FY1));
    end;
    if FBrushStyle <> bsSolid then
    begin
      { Brush.Style := xxx does not work for some printers }
      br := CreateHatchBrush(Integer(FBrushStyle) - 2, ColorToRGB(Frame.Color));
      oldbr := SelectObject(Handle, br);
      Rectangle(FX, FY, FX1 + 1, FY1 + 1);
      SelectObject(Handle, oldbr);
      DeleteObject(br);
    end;
  end;
end;

procedure TfrxView.DrawLine(x, y, x1, y1, w: Integer);
var
  i, d: Integer;
begin
  with FCanvas do
  begin
    if w = 0 then
      w := 1;
    if w mod 2 = 0 then
      d := 1 else
      d := 0;

    for i := (-w div 2) to (w div 2 - d) do
    begin
      if Abs(x1 - x) > Abs(y1 - y) then
      begin
        MoveTo(x, y + i);
        LineTo(x1, y1 + i);
      end
      else
      begin
        MoveTo(x + i, y);
        LineTo(x1 + i, y1);
      end;
    end;
  end;
end;

procedure TfrxView.DrawFrame;
var
  d: Integer;

  procedure Line(x, y, x1, y1: Integer; Line: TfrxFrameLine;
    Typ: TfrxFrameType; gap1, gap2: Boolean);
  var
    g1, g2, g3, g4, fw: Integer;

    procedure Line1(x, y, x1, y1: Integer);
    begin
      FCanvas.MoveTo(x, y);
      FCanvas.LineTo(x1, y1);
    end;

  begin
    fw := Round(Line.Width * FScaleX);
    if Line.Style = fsSolid then
      Line1(x, y, x1, y1)
    else if Line.Style = fsDouble then
    begin
      if gap1 then
        g1 := fw else
        g1 := 0;
      if gap2 then
        g2 := fw else
        g2 := 0;
      g3 := -g1;
      g4 := -g2;

      if Typ in [ftLeft, ftTop] then
      begin
        g1 := -g1;
        g2 := -g2;
        g3 := -g3;
        g4 := -g4;
      end;

      if x = x1 then
        Line1(x - fw, y + g1, x1 - fw, y1 - g2) else
        Line1(x + g1, y - fw, x1 - g2, y1 - fw);
      if Color <> clNone then
      begin
        FCanvas.Pen.Color := Color;
        Line1(x, y, x1, y1);
      end;
      FCanvas.Pen.Color := Line.Color;
      if x = x1 then
        Line1(x + fw, y + g3, x1 + fw, y1 - g4) else
        Line1(x + g3, y + fw, x1 - g4, y1 + fw);
    end
    else
      DrawLine(x, y, x1, y1, fw);
  end;

  procedure SetPen(Line: TfrxFrameLine);
  begin
    with FCanvas do
    begin
      Pen.Color := Line.Color;
      if Line.Style in [fsSolid, fsDouble] then
      begin
        Pen.Style := psSolid;
        Pen.Width := Round(Line.Width * FScaleX);
      end
      else
      begin
        Pen.Style := TPenStyle(Line.Style);
        Pen.Width := 1;
      end;
    end;
  end;

begin
  if Frame.DropShadow then
    with FCanvas do
    begin
      Pen.Style := psSolid;
      Pen.Color := Frame.ShadowColor;
      d := Round(Frame.ShadowWidth * FScaleX);
      DrawLine(FX1 + d div 2, FY + d, FX1 + d div 2, FY1, d);
      d := Round(Frame.ShadowWidth * FScaleY);
      DrawLine(FX + d, FY1 + d div 2, FX1 + d, FY1 + d div 2, d);
    end;

  if (Frame.Typ <> []) and (Frame.Color <> clNone) and (Frame.Width <> 0) then
    with FCanvas do
    begin
      Brush.Style := bsSolid;
      if Frame.Style <> fsSolid then
        if Color = clNone then
          Brush.Style := bsClear else
          Brush.Color := Color;

      if ftLeft in Frame.Typ then
      begin
        SetPen(FFrame.LeftLine);
        if Pen.Width = 2 then
          d := 1 else
          d := 0;
        Line(FX, FY - d, FX, FY1, FFrame.LeftLine, ftLeft, ftTop in Frame.Typ, ftBottom in Frame.Typ);
      end;
      if ftRight in Frame.Typ then
      begin
        SetPen(FFrame.RightLine);
        Line(FX1, FY, FX1, FY1, FFrame.RightLine, ftRight, ftTop in Frame.Typ, ftBottom in Frame.Typ);
      end;
      if ftTop in Frame.Typ then
      begin
        SetPen(FFrame.TopLine);
        Line(FX, FY, FX1, FY, FFrame.TopLine, ftTop, ftLeft in Frame.Typ, ftRight in Frame.Typ);
      end;
      if ftBottom in Frame.Typ then
      begin
        SetPen(FFrame.BottomLine);
        if Pen.Width = 1 then
          d := 1 else
          d := 0;
        Line(FX, FY1, FX1 + d, FY1, FFrame.BottomLine, ftBottom, ftLeft in Frame.Typ, ftRight in Frame.Typ);
      end;
    end;
end;

procedure TfrxView.Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended);
begin
  BeginDraw(Canvas, ScaleX, ScaleY, OffsetX, OffsetY);
  DrawBackground;
  DrawFrame;
end;

function TfrxView.Diff(AComponent: TfrxComponent): String;
var
  v: TfrxView;
begin
  Result := inherited Diff(AComponent);
  v := TfrxView(AComponent);

  if FBrushStyle <> v.FBrushStyle then
    Result := Result + ' BrushStyle="' + frxValueToXML(FBrushStyle) + '"';
  if FAlign <> v.FAlign then
    Result := Result + ' Align="' + frxValueToXML(FAlign) + '"';
  if FColor <> v.FColor then
    Result := Result + ' Color="' + IntToStr(FColor) + '"';
  Result := Result + FFrame.Diff(v.FFrame);
  if Cursor <> v.Cursor then
    Result := Result + ' Cursor="' + frxValueToXML(Cursor) + '"';
  if FPrintable <> v.FPrintable then
    Result := Result + ' Printable="' + frxValueToXML(FPrintable) + '"';
  if TagStr <> v.TagStr then
    Result := Result + ' TagStr="' + frxStrToXML(TagStr) + '"';
  if URL <> v.URL then
    Result := Result + ' URL="' + frxStrToXML(URL) + '"';
end;

function TfrxView.IsDataField: Boolean;
begin
  Result := (DataSet <> nil) and (Length(DataField) <> 0);
end;

procedure TfrxView.BeforePrint;
begin
  inherited;
  FTempTag := FTagStr;
  FTempURL := FURL;
end;

procedure TfrxView.ExpandVariables(var Expr: String);
var
  i, j: Integer;
  s: String;
begin
  i := 1;
  repeat
    while i < Length(Expr) do
      if isDBCSLeadByte(Byte(Expr[i])) then  { if DBCS then skip 2 bytes }
        Inc(i, 2)
      else if (Expr[i] <> '[') then
        Inc(i)
      else
        break;

    s := frxGetBrackedVariable(Expr, '[', ']', i, j);
    if i <> j then
    begin
      Delete(Expr, i, j - i + 1);
      s := VarToStr(Report.Calc(s));
      Insert(s, Expr, i);
      Inc(i, Length(s));
      j := 0;
    end;
  until i = j;
end;

procedure TfrxView.GetData;
begin
  if (FTagStr <> '') and (Pos('[', FTagStr) <> 0) then
    ExpandVariables(FTagStr);
  if (FURL <> '') and (Pos('[', FURL) <> 0) then
    ExpandVariables(FURL);
end;

procedure TfrxView.AfterPrint;
begin
  inherited;
  FTagStr := FTempTag;
  FURL := FTempURL;
end;




{ TfrxShapeView }

constructor TfrxShapeView.Create(AOwner: TComponent);
begin
  inherited;
  frComponentStyle := frComponentStyle - [csDefaultDiff];
end;

constructor TfrxShapeView.DesignCreate(AOwner: TComponent; Flags: Word);
begin
  inherited;
  FShape := TfrxShapeKind(Flags);
end;

procedure TfrxShapeView.Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX,
  OffsetY: Extended);
var
  SaveLeft, SaveTop, SaveWidth, SaveHeight: Extended;

  procedure DrawShape;
  var
    min: Integer;
  begin
    if FDY < FDX then
      min := FDY else
      min := FDX;

    with Canvas do
    case FShape of
      skRectangle:
        Rectangle(FX, FY, FX1 + 1, FY1 + 1);

      skRoundRectangle:
        begin
          if FCurve = 0 then
            min := min div 4
          else
            min := Round(FCurve * FScaleX * 10);
          RoundRect(FX, FY, FX1 + 1, FY1 + 1, min, min);
        end;

      skEllipse:
        Ellipse(FX, FY, FX1 + 1, FY1 + 1);

      skTriangle:
        Polygon([Point(FX1, FY1), Point(FX, FY1), Point(FX + FDX div 2, FY), Point(FX1, FY1)]);

      skDiamond:
        Polygon([Point(FX + FDX div 2, FY), Point(FX1, FY + FDY div 2),
          Point(FX + FDX div 2, FY1), Point(FX, FY + FDY div 2)]);

      skDiagonal1:
        DrawLine(FX, FY1, FX1, FY, FFrameWidth);

      skDiagonal2:
        DrawLine(FX, FY, FX1, FY1, FFrameWidth);
    end;
  end;

  procedure DoDraw;
  begin
    with Canvas do
    begin
      Pen.Color := Frame.Color;
      Pen.Width := FFrameWidth;
      Brush.Style := bsSolid;
      SetBkMode(Handle, Opaque);

      if FBrushStyle = bsSolid then
      begin
        Pen.Style := TPenStyle(Frame.Style);
        if FColor <> clNone then
          Brush.Color := FColor else
          Brush.Style := bsClear;
        DrawShape;
      end
      else
      begin
        Pen.Style := TPenStyle(Frame.Style);
        if FColor <> clNone then
        begin
          Brush.Color := FColor;
          DrawShape;
        end;
        Brush.Style := FBrushStyle;
        Brush.Color := Frame.Color;
        DrawShape;
      end;
    end;
  end;

begin
  if Frame.Style = fsDouble then
  begin
    Frame.Style := fsSolid;
    SaveLeft := Left;
    SaveTop := Top;
    SaveWidth := Width;
    SaveHeight := Height;

    BeginDraw(Canvas, ScaleX, ScaleY, OffsetX, OffsetY);
    DoDraw;

    case FShape of
      skRectangle, skRoundRectangle, skEllipse:
        begin
          Left := Left + 2 * Frame.Width;
          Top := Top + 2 * Frame.Width;
          Width := Width - 4 * Frame.Width;
          Height := Height - 4 * Frame.Width;
        end;

      skTriangle:
        begin
          Left := Left + 4 * Frame.Width;
          Top := Top + 4 * Frame.Width;
          Width := Width - 8 * Frame.Width;
          Height := Height - 6 * Frame.Width;
        end;

      skDiamond:
        begin
          Left := Left + 3 * Frame.Width;
          Top := Top + 3 * Frame.Width;
          Width := Width - 6 * Frame.Width;
          Height := Height - 6 * Frame.Width;
        end;

      skDiagonal1, skDiagonal2:
        begin
          Left := Left + 2 * Frame.Width;
        end;
    end;

    BeginDraw(Canvas, ScaleX, ScaleY, OffsetX, OffsetY);
    DoDraw;

    Frame.Style := fsDouble;
    Left := SaveLeft;
    Top := SaveTop;
    Width := SaveWidth;
    Height := SaveHeight;
  end
  else
  begin
    BeginDraw(Canvas, ScaleX, ScaleY, OffsetX, OffsetY);
    DoDraw;
  end;
end;

function TfrxShapeView.Diff(AComponent: TfrxComponent): String;
begin
  Result := inherited Diff(AComponent);

  if FShape <> TfrxShapeView(AComponent).FShape then
    Result := Result + ' Shape="' + frxValueToXML(FShape) + '"';
end;

class function TfrxShapeView.GetDescription: String;
begin
  Result := frxResources.Get('obShape');
end;



{ TfrxHighlight }

constructor TfrxHighlight.Create;
begin
  FColor := clTransparent;

  FFont := TFont.Create;

  with FFont do
  begin
    Name := DefFontName;
    Size := DefFontSize;
    Color := clRed;
    Charset := frxCharset;
  end;
end;

destructor TfrxHighlight.Destroy;
begin
  FFont.Free;
  inherited;
end;

procedure TfrxHighlight.Assign(Source: TPersistent);
begin
  if Source is TfrxHighlight then
  begin
    FFont.Assign(TfrxHighlight(Source).Font);
    FColor := TfrxHighlight(Source).Color;
    FCondition := TfrxHighlight(Source).Condition;
  end;
end;

procedure TfrxHighlight.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;



{ TfrxFormat }

procedure TfrxFormat.Assign(Source: TPersistent);
begin
  if Source is TfrxFormat then
  begin
    FDecimalSeparator := TfrxFormat(Source).DecimalSeparator;
    FFormatStr := TfrxFormat(Source).FormatStr;
    FKind := TfrxFormat(Source).Kind;
  end;
end;



{ TfrxStretcheable }

constructor TfrxStretcheable.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FStretchMode := smDontStretch;
end;

function TfrxStretcheable.CalcHeight: Extended;
begin
  Result := Height;
end;

function TfrxStretcheable.DrawPart: Extended;
begin
  Result := 0;
end;

procedure TfrxStretcheable.InitPart;
begin
//
end;



{ TfrxCustomMemoView }

constructor TfrxCustomMemoView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  frComponentStyle := frComponentStyle - [csDefaultDiff];
  FHighlight := TfrxHighlight.Create;
  FDisplayFormat := TfrxFormat.Create;
  FMemo := TWideStrings.Create;
  FAllowExpressions := True;
  FClipped := True;
  FExpressionDelimiters := '[,]';
  FGapX := 2;
  FGapY := 1;
  FHAlign := haLeft;
  FVAlign := vaTop;
  FLineSpacing := 2;
  ParentFont := True;
  FWordWrap := True;
  FWysiwyg := True;
  FLastValue := Null;
end;

destructor TfrxCustomMemoView.Destroy;
begin
  FHighlight.Free;
  FDisplayFormat.Free;
  FMemo.Free;
  inherited;
end;

class function TfrxCustomMemoView.GetDescription: String;
begin
  Result := frxResources.Get('obText');
end;

procedure TfrxCustomMemoView.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FFlowTo) then
    FFlowTo := nil;
end;

function TfrxCustomMemoView.IsExprDelimitersStored: Boolean;
begin
  Result := FExpressionDelimiters <> '[,]';
end;

function TfrxCustomMemoView.IsLineSpacingStored: Boolean;
begin
  Result := FLineSpacing <> 2;
end;

function TfrxCustomMemoView.IsGapXStored: Boolean;
begin
  Result := FGapX <> 2;
end;

function TfrxCustomMemoView.IsGapYStored: Boolean;
begin
  Result := FGapY <> 1;
end;

function TfrxCustomMemoView.IsParagraphGapStored: Boolean;
begin
  Result := FParagraphGap <> 0;
end;

function TfrxCustomMemoView.IsCharSpacingStored: Boolean;
begin
  Result := FCharSpacing <> 0;
end;

function TfrxCustomMemoView.IsHighlightStored: Boolean;
begin
  Result := Trim(FHighlight.Condition) <> '';
end;

procedure TfrxCustomMemoView.SetRotation(Value: Integer);
begin
  FRotation := Value mod 360;
end;

procedure TfrxCustomMemoView.SetText(const Value: WideString);
begin
  FMemo.Text := Value;
end;

function TfrxCustomMemoView.GetText: WideString;
begin
  Result := FMemo.Text;
end;

procedure TfrxCustomMemoView.SetMemo(const Value: TWideStrings);
begin
  FMemo.Assign(Value);
end;

procedure TfrxCustomMemoView.SetHighlight(const Value: TfrxHighlight);
begin
  FHighlight.Assign(Value);
end;

procedure TfrxCustomMemoView.SetDisplayFormat(const Value: TfrxFormat);
begin
  FDisplayFormat.Assign(Value);
end;

procedure TfrxCustomMemoView.SetStyle(const Value: String);
begin
  FStyle := Value;
  if Report <> nil then
    ApplyStyle(Report.Styles.Find(FStyle));
end;

function TfrxCustomMemoView.AdjustCalcHeight: Extended;
begin
  Result := GapY * 2;
  if ftTop in Frame.Typ then
    Result := Result + (Frame.Width - 1) / 2;
  if ftBottom in Frame.Typ then
    Result := Result + Frame.Width / 2;
  if Frame.DropShadow then
    Result := Result + Frame.ShadowWidth;
end;

function TfrxCustomMemoView.AdjustCalcWidth: Extended;
begin
  Result := GapX * 2;
  if ftLeft in Frame.Typ then
    Result := Result + (Frame.Width - 1) / 2;
  if ftRight in Frame.Typ then
    Result := Result + Frame.Width / 2;
  if Frame.DropShadow then
    Result := Result + Frame.ShadowWidth;
end;

procedure TfrxCustomMemoView.BeginDraw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended);
var
  bx, by, bx1, by1, wx1, wx2, wy1, wy2, gx1, gy1: Integer;
begin
  inherited BeginDraw(Canvas, ScaleX, ScaleY, OffsetX, OffsetY);

  wx1 := Round((Frame.Width * ScaleX - 1) / 2);
  wx2 := Round(Frame.Width * ScaleX / 2);
  wy1 := Round((Frame.Width * ScaleY - 1) / 2);
  wy2 := Round(Frame.Width * ScaleY / 2);

  bx := FX;
  by := FY;
  bx1 := FX1;
  by1 := FY1;
  if ftLeft in Frame.Typ then
    Inc(bx, wx1);
  if ftRight in Frame.Typ then
    Dec(bx1, wx2);
  if ftTop in Frame.Typ then
    Inc(by, wy1);
  if ftBottom in Frame.Typ then
    Dec(by1, wy2);
  gx1 := Round(GapX * ScaleX);
  gy1 := Round(GapY * ScaleY);

  FTextRect := Rect(bx + gx1, by + gy1, bx1 - gx1 + 1, by1 - gy1 + 1);
end;

procedure TfrxCustomMemoView.SetDrawParams(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended);
var
  ScaledRect: TRect;
  SaveWidth: Extended;
  FDrawText: TfrxDrawText;
begin
  if Report <> nil then
    FDrawText := Report.FDrawText else
    FDrawText := frxDrawText;

  if FHighlight.Active then
  begin
    FDrawText.SetFont(FHighlight.Font);
    FColor := FHighlight.Color;
  end
  else
    FDrawText.SetFont(FFont);
  FDrawText.SetOptions(FWordWrap, FAllowHTMLTags, FRTLReading, FWordBreak,
    FClipped, FWysiwyg, FRotation);
  FDrawText.SetGaps(FParagraphGap, FCharSpacing, FLineSpacing);

  if not IsDesigning then
    if FAutoWidth then
    begin
      FDrawText.SetDimensions(1, 1, 1, Rect(0, 0, 10000, 10000), Rect(0, 0, 10000, 10000));
      FDrawText.SetText(FMemo);
      SaveWidth := Width;
      Width := FDrawText.CalcWidth + AdjustCalcWidth;
      if FHAlign = haRight then
        Left := Left + SaveWidth - Width
      else if FHAlign = haCenter then
        Left := Left + (SaveWidth - Width) / 2;
      if Parent <> nil then
        Parent.AlignChildren;
    end;

  BeginDraw(Canvas, ScaleX, ScaleY, OffsetX, OffsetY);
  ScaledRect := FTextRect;
  BeginDraw(Canvas, 1, 1, 0, 0);

  if not IsPrinting then
    FPrintScale := 1;
  FDrawText.SetDimensions(ScaleX, ScaleY, FPrintScale, FTextRect, ScaledRect);
  FDrawText.SetText(FMemo);
end;

procedure TfrxCustomMemoView.Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX,
  OffsetY: Extended);
var
  SaveColor: TColor;
  FDrawText: TfrxDrawText;

  procedure DrawUnderlines;
  var
    dy, h: Extended;
  begin
    with Canvas do
    begin
      Pen.Color := Frame.Color;
      Pen.Width := FFrameWidth;
      Pen.Style := psSolid;
      Pen.Mode := pmCopy;
    end;

    h := FDrawText.LineHeight * ScaleY;
    dy := FY + h + (GapY - LineSpacing + 1) * ScaleY;
    while dy < FY1 do
    begin
      Canvas.MoveTo(FX, Round(dy));
      Canvas.LineTo(FX1, Round(dy));
      dy := dy + h;
    end;
  end;

begin
  if Report <> nil then
    FDrawText := Report.FDrawText else
    FDrawText := frxDrawText;

  if not IsDesigning then
    ExtractMacros
  else if IsDataField then
    FMemo.Text := '[' + DataSet.UserName + '."' + DataField + '"]';

  SaveColor := FColor;

  FDrawText.Lock;
  try
    SetDrawParams(Canvas, ScaleX, ScaleY, OffsetX, OffsetY);
    inherited Draw(Canvas, ScaleX, ScaleY, OffsetX, OffsetY);

    if FUnderlines and (FRotation = 0) then
      DrawUnderlines;
    FDrawText.DrawText(FCanvas, HAlign, VAlign);

  finally
    FDrawText.Unlock;
  end;

  FColor := SaveColor;
end;

function TfrxCustomMemoView.CalcHeight: Extended;
var
  FDrawText: TfrxDrawText;
begin
  if Report <> nil then
    FDrawText := Report.FDrawText else
    FDrawText := frxDrawText;

  FDrawText.Lock;
  try
    if FHighlight.Active then
      FDrawText.SetFont(FHighlight.Font) else
      FDrawText.SetFont(FFont);
    FDrawText.SetOptions(FWordWrap, FAllowHTMLTags, FRTLReading, FWordBreak,
      FClipped, FWysiwyg, FRotation);
    FDrawText.SetGaps(FParagraphGap, FCharSpacing, FLineSpacing);

    if FAutoWidth then
      FDrawText.SetDimensions(1, 1, 1, Rect(0, 0, 10000, 10000), Rect(0, 0, 10000, 10000))
    else
    begin
      BeginDraw(nil, 1, 1, 0, 0);
      FDrawText.SetDimensions(1, 1, 1, FTextRect, FTextRect);
    end;

    FDrawText.SetText(FMemo);
    Result := Round(FDrawText.CalcHeight + AdjustCalcHeight);

  finally
    FDrawText.Unlock;
  end;
end;

function TfrxCustomMemoView.CalcWidth: Extended;
var
  FDrawText: TfrxDrawText;
begin
  if Report <> nil then
    FDrawText := Report.FDrawText else
    FDrawText := frxDrawText;

  FDrawText.Lock;
  try
    if FHighlight.Active then
      FDrawText.SetFont(FHighlight.Font) else
      FDrawText.SetFont(FFont);
    FDrawText.SetOptions(FWordWrap, FAllowHTMLTags, FRTLReading, FWordBreak,
      FClipped, FWysiwyg, FRotation);
    FDrawText.SetGaps(FParagraphGap, FCharSpacing, FLineSpacing);

    FDrawText.SetDimensions(1, 1, 1, Rect(0, 0, 10000, 10000), Rect(0, 0, 10000, 10000));
    FDrawText.SetText(FMemo);
    Result := Round(FDrawText.CalcWidth + AdjustCalcWidth);

  finally
    FDrawText.Unlock;
  end;
end;

procedure TfrxCustomMemoView.InitPart;
begin
  FPartMemo := FMemo.Text;
end;

function TfrxCustomMemoView.DrawPart: Extended;
var
  SaveColor: TColor;
  FDrawText: TfrxDrawText;
begin
  if Report <> nil then
    FDrawText := Report.FDrawText else
    FDrawText := frxDrawText;

  SaveColor := FColor;

  FDrawText.Lock;
  try
    FMemo.Text := FPartMemo;
    SetDrawParams(nil, 1, 1, 0, 0);
    FPartMemo := FDrawText.GetOutBoundsText;
    FMemo.Text := FDrawText.GetInBoundsText;

    Result := FDrawText.UnusedSpace;
    if Result = 0 then
      Result := Height;

  finally
    FDrawText.Unlock;
  end;

  FColor := SaveColor;
end;

function TfrxCustomMemoView.Diff(AComponent: TfrxComponent): String;
var
  m: TfrxCustomMemoView;
  s: WideString;
  c: Integer;
begin
  Result := inherited Diff(AComponent);
  m := TfrxCustomMemoView(AComponent);

  if FAutoWidth <> m.FAutoWidth then
    Result := Result + ' AutoWidth="' + frxValueToXML(FAutoWidth) + '"';
  if FloatDiff(FCharSpacing, m.FCharSpacing) then
    Result := Result + ' CharSpacing="' + FloatToStr(FCharSpacing) + '"';
  if FloatDiff(FGapX, m.FGapX) then
    Result := Result + ' GapX="' + FloatToStr(FGapX) + '"';
  if FloatDiff(FGapY, m.FGapY) then
    Result := Result + ' GapY="' + FloatToStr(FGapY) + '"';
  if FHAlign <> m.FHAlign then
    Result := Result + ' HAlign="' + frxValueToXML(FHAlign) + '"';
  if FHighlight.Active <> m.FHighlight.Active then
    Result := Result + ' Highlight.Active="' + frxValueToXML(FHighlight.Active) + '"';
  if FloatDiff(FLineSpacing, m.FLineSpacing) then
    Result := Result + ' LineSpacing="' + FloatToStr(FLineSpacing) + '"';

  c := FMemo.Count;
  if c = 0 then
    Result := Result + ' u=""'
  else
  begin
    if c = 1 then
      Result := Result + ' u="' + frxStrToXML(Utf8Encode(FMemo[0])) + '"'
    else
    begin
      s := Text;
      SetLength(s, Length(s) - 2);
      Result := Result + ' u="' + frxStrToXML(Utf8Encode(s)) + '"';
    end;
  end;

  if FloatDiff(FParagraphGap, m.FParagraphGap) then
    Result := Result + ' ParagraphGap="' + FloatToStr(FParagraphGap) + '"';
  if FRotation <> m.FRotation then
    Result := Result + ' Rotation="' + IntToStr(FRotation) + '"';
  if FRTLReading <> m.FRTLReading then
    Result := Result + ' RTLReading="' + frxValueToXML(FRTLReading) + '"';
  if FUnderlines <> m.FUnderlines then
    Result := Result + ' Underlines="' + frxValueToXML(FUnderlines) + '"';
  if FVAlign <> m.FVAlign then
    Result := Result + ' VAlign="' + frxValueToXML(FVAlign) + '"';
  if FWordWrap <> m.FWordWrap then
    Result := Result + ' WordWrap="' + frxValueToXML(FWordWrap) + '"';
end;

procedure TfrxCustomMemoView.BeforePrint;
begin
  inherited;
  if not IsDataField then
    FTempMemo := FMemo.Text;
end;

procedure TfrxCustomMemoView.AfterPrint;
begin
  if not IsDataField then
    FMemo.Text := FTempMemo;
  inherited;
end;

procedure TfrxCustomMemoView.GetData;
var
  i, j: Integer;
  s, s1, s2, dc1, dc2: WideString;
begin
  inherited;
  if IsDataField then
  begin
    if DataSet.IsBlobField(DataField) then
      DataSet.AssignBlobTo(DataField, FMemo)
    else
    begin
      FValue := DataSet.Value[DataField];
      if FDisplayFormat.Kind = fkText then
        FMemo.Text := DataSet.DisplayText[DataField] else
        FMemo.Text := FormatData(FValue);
      if FHideZeros and (TVarData(FValue).VType <> varString) and
        (TVarData(FValue).VType <> varOleStr) and (FValue = 0) then
        FMemo.Text := '';
    end
  end
  else if AllowExpressions then
  begin
    s := FMemo.Text;
    i := 1;
    dc1 := FExpressionDelimiters;
    dc2 := Copy(dc1, Pos(',', dc1) + 1, 255);
    dc1 := Copy(dc1, 1, Pos(',', dc1) - 1);

    if Pos(dc1, s) <> 0 then
    begin
      repeat
        while (i < Length(s)) and (Copy(s, i, Length(dc1)) <> dc1) do Inc(i);

        s1 := frxGetBrackedVariableW(s, dc1, dc2, i, j);
        if i <> j then
        begin
          Delete(s, i, j - i + 1);
          s2 := CalcAndFormat(s1);
          Insert(s2, s, i);
          Inc(i, Length(s2));
          j := 0;
        end;
      until i = j;

      FMemo.Text := s;
    end;
  end;

  Report.LocalValue := FValue;
  FHighlight.Active := False;
  if FHighlight.Condition <> '' then
    FHighlight.Active := Report.Calc(FHighlight.Condition);

  if FSuppressRepeated then
  begin
    if FLastValue = FMemo.Text then
      FMemo.Text := '' else
      FLastValue := FMemo.Text;
  end;

  if FFlowTo <> nil then
  begin
    InitPart;
    DrawPart;
    FFlowTo.Text := FPartMemo;
    FFlowTo.AllowExpressions := False;
  end;
end;

function TfrxCustomMemoView.CalcAndFormat(const Expr: WideString): WideString;
var
  i: Integer;
  ExprStr, FormatStr: WideString;
  Format: TfrxFormat;
begin
  Result := '';
  Format := nil;
  i := Pos(' #', Expr);
  if i <> 0 then
  begin
    ExprStr := Copy(Expr, 1, i - 1);
    FormatStr := Copy(Expr, i + 2, Length(Expr) - i - 1);
    if Pos(')', FormatStr) = 0 then
    begin
      Format := TfrxFormat.Create;

      if FormatStr[1] in [WideChar('N'), WideChar('n')] then
      begin
        Format.Kind := fkNumeric;
        for i := 1 to Length(FormatStr) do
          if FormatStr[i] in [WideChar(','), WideChar('-')] then
          begin
            Format.DecimalSeparator := FormatStr[i];
            FormatStr[i] := '.';
          end;
      end
      else if FormatStr[1] in [WideChar('D'), WideChar('T'), WideChar('d'), WideChar('t')] then
        Format.Kind := fkDateTime
      else if FormatStr[1] in [WideChar('B'), WideChar('b')] then
        Format.Kind := fkBoolean;

      Format.FormatStr := Copy(FormatStr, 2, 255);
    end
    else
      ExprStr := Expr;
  end
  else
    ExprStr := Expr;

  try
    if CompareText(ExprStr, 'TOTALPAGES#') = 0 then
      FValue := '[TotalPages#]'
    else if CompareText(ExprStr, 'COPYNAME#') = 0 then
      FValue := '[CopyName#]'
    else
      FValue := Report.Calc(ExprStr);
    if FHideZeros and (TVarData(FValue).VType <> varString) and
      (TVarData(FValue).VType <> varOleStr) and (FValue = 0) then
      Result := '' else
      Result := FormatData(FValue, Format);
  finally
    if Format <> nil then
      Format.Free;
  end;
end;

function TfrxCustomMemoView.FormatData(const Value: Variant;
  AFormat: TfrxFormat = nil): WideString;
var
  i: Integer;
begin
  if AFormat = nil then
    AFormat := FDisplayFormat;
  if VarIsNull(Value) then
    Result := ''
  else if AFormat.Kind = fkText then
    Result := VarToWideStr(Value)
  else
  try
    case AFormat.Kind of
      fkNumeric:
        begin
          if (AFormat.FormatStr <> '') and (AFormat.FormatStr[1] = '#') then
            Result := FormatFloat(AFormat.FormatStr, Extended(Value))
          else if Pos('d', AFormat.FormatStr) <> 0 then
            Result := Format(AFormat.FormatStr, [Integer(Value)])
          else
            Result := Format(AFormat.FormatStr, [Extended(Value)]);
          if (Length(AFormat.DecimalSeparator) = 1) and
            (DecimalSeparator <> AFormat.DecimalSeparator[1]) then
            for i := 1 to Length(Result) do
              if Result[i] = WideChar(DecimalSeparator) then
                Result[i] := WideChar(AFormat.DecimalSeparator[1]);
        end;

      fkDateTime:
        Result := FormatDateTime(AFormat.FormatStr, Value);

      fkBoolean:
        if Value = True then
           Result := Copy(AFormat.FormatStr, Pos(',', AFormat.FormatStr) + 1, 255) else
           Result := Copy(AFormat.FormatStr, 1, Pos(',', AFormat.FormatStr) - 1);
      else
        Result := VarToWideStr(Value)
    end;
  except
    Result := VarToWideStr(Value);
  end;
end;

function TfrxCustomMemoView.GetComponentText: String;
var
  i: Integer;
begin
  Result := FMemo.Text;
  if FAllowExpressions then   { extract TOTALPAGES macro if any }
  begin
    i := Pos('[TOTALPAGES]', UpperCase(Result));
    if i <> 0 then
    begin
      Delete(Result, i, 12);
      Insert(IntToStr(FTotalPages), Result, i);
    end;
  end;
end;

procedure TfrxCustomMemoView.ApplyStyle(Style: TfrxStyleItem);
begin
  if Style <> nil then
  begin
    Color := Style.Color;
    Font := Style.Font;
    Frame := Style.Frame;
  end;
end;

function TfrxCustomMemoView.WrapText(WrapWords: Boolean): WideString;
var
  TempBMP: TBitmap;
  FDrawText: TfrxDrawText;
begin
  Result := '';
  TempBMP := TBitmap.Create;
  if Report <> nil then
    FDrawText := Report.FDrawText else
    FDrawText := frxDrawText;

  FDrawText.Lock;
  try
    SetDrawParams(TempBMP.Canvas, 1, 1, 0, 0);
    if WrapWords then
      Result := FDrawText.WrappedText
    else
      Result := FDrawText.DeleteTags(Text);
  finally
    FDrawText.Unlock;
    TempBMP.Free;
  end;
end;

procedure TfrxCustomMemoView.ExtractMacros;
var
  s, s1: String;
  i, j: Integer;
begin
  if FAllowExpressions then
  begin
    s := FMemo.Text;
    i := Pos('[TOTALPAGES#]', UpperCase(s));
    if i <> 0 then
    begin
      Delete(s, i, 13);
      Insert(IntToStr(FTotalPages), s, i);
      FMemo.Text := s;
    end;
    i := Pos('[COPYNAME#]', UpperCase(s));
    if i <> 0 then
    begin
      j := frxGlobalVariables.IndexOf('CopyName' + IntToStr(FCopyNo));
      if j <> -1 then
        s1 := VarToStr(frxGlobalVariables.Items[j].Value)
      else
        s1 := '';
      Delete(s, i, 11);
      Insert(s1, s, i);
      FMemo.Text := s;
    end;
  end;
end;





{ TfrxSysMemoView }

class function TfrxSysMemoView.GetDescription: String;
begin
  Result := frxResources.Get('obSysText');
end;


{ TfrxCustomLineView }

constructor TfrxCustomLineView.Create(AOwner: TComponent);
begin
  inherited;
  frComponentStyle := frComponentStyle - [csDefaultDiff];
  FArrowWidth := 5;
  FArrowLength := 20;
end;

constructor TfrxCustomLineView.DesignCreate(AOwner: TComponent; Flags: Word);
begin
  inherited;
  FDiagonal := Flags <> 0;
  FArrowEnd := Flags in [2, 4];
  FArrowStart := Flags in [3, 4];
end;

procedure TfrxCustomLineView.Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX,
  OffsetY: Extended);
begin
  if not FDiagonal then
  begin
    if Width > Height then
    begin
      Height := 0;
      Frame.Typ := [ftTop];
    end
    else
    begin
      Width := 0;
      Frame.Typ := [ftLeft];
    end;
  end;

  BeginDraw(Canvas, ScaleX, ScaleY, OffsetX, OffsetY);
  DrawDiagonalLine;
end;

procedure TfrxCustomLineView.DrawArrow(x1, y1, x2, y2: Integer);
var
  k1, a, b, c, D: Double;
  xp, yp, x3, y3, x4, y4: Integer;
begin
  if abs(x2 - x1) > 8 then
  begin
    k1 := (y2 - y1) / (x2 - x1);
    a := Sqr(k1) + 1;
    b := 2 * k1 * (x2 * y1 - x1 * y2) / (x2 - x1) - 2 * y2 * k1 - 2 * x2;
    c := Sqr(x2) + Sqr(y2) - Sqr(FArrowLength * FScaleX) + sqr((x2 * y1 - x1 * y2) / (x2 - x1)) -
      2 * y2 * (x2 * y1 - x1 * y2) / (x2 - x1);
    D := Sqr(b) - 4 * a * c;
    xp := Round((-b + Sqrt(D)) / (2 * a));
    if (xp > x1) and (xp > x2) or (xp < x1) and (xp < x2) then
      xp := Round((-b - Sqrt(D)) / (2 * a));
    yp := Round(xp * k1 + (x2 * y1 - x1 * y2) / (x2 - x1));
    if y2 <> y1 then
    begin
      x3 := Round(xp + FArrowWidth * FScaleX * sin(ArcTan(k1)));
      y3 := Round(yp - FArrowWidth * FScaleX * cos(ArcTan(k1)));
      x4 := Round(xp - FArrowWidth * FScaleX * sin(ArcTan(k1)));
      y4 := Round(yp + FArrowWidth * FScaleX * cos(ArcTan(k1)));
    end
    else
    begin
      x3 := xp;
      y3 := yp - Round(FArrowWidth * FScaleX);
      x4 := xp;
      y4 := yp + Round(FArrowWidth * FScaleX);
    end;
  end
  else
  begin
    xp := x2;
    yp := y2 - Round(FArrowLength * FScaleX);
    if (yp > y1) and (yp > y2) or (yp < y1) and (yp < y2) then
      yp := y2 + Round(FArrowLength * FScaleX);
    x3 := xp - Round(FArrowWidth * FScaleX);
    y3 := yp;
    x4 := xp + Round(FArrowWidth * FScaleX);
    y4 := yp;
  end;

  if FArrowSolid then
  begin
    FCanvas.Brush.Color := Frame.Color;
    FCanvas.Polygon([Point(x2, y2), Point(x3, y3), Point(x4, y4), Point(x2, y2)])
  end
  else
  begin
    FCanvas.Pen.Width := Round(FFrame.Width * FScaleX);
    FCanvas.Polyline([Point(x3, y3), Point(x2, y2), Point(x4, y4)]);
  end;
end;

procedure TfrxCustomLineView.DrawDiagonalLine;
begin
  if (Frame.Color = clNone) or (Frame.Width = 0) then exit;
  with FCanvas do
  begin
    Brush.Style := bsSolid;
    if Color = clNone then
      Brush.Style := bsClear else
      Brush.Color := Color;
    Pen.Color := Frame.Color;
    Pen.Width := 1;
    if Frame.Style <> fsDouble then
      Pen.Style := TPenStyle(Frame.Style) else
      Pen.Style := psSolid;

    DrawLine(FX, FY, FX1, FY1, FFrameWidth);

    if FArrowStart then
      DrawArrow(FX1, FY1, FX, FY);
    if FArrowEnd then
      DrawArrow(FX, FY, FX1, FY1);
  end;
end;


{ TfrxLineView }

class function TfrxLineView.GetDescription: String;
begin
  Result := frxResources.Get('obLine');
end;


{ TfrxPictureView }

constructor TfrxPictureView.Create(AOwner: TComponent);
begin
  inherited;
  frComponentStyle := frComponentStyle - [csDefaultDiff];
  FPicture := TPicture.Create;
  FPicture.OnChange := PictureChanged;
  FKeepAspectRatio := True;
  FStretched := True;
  FColor := clWhite;
  FIsPictureStored := True;
end;

destructor TfrxPictureView.Destroy;
begin
  FPicture.Free;
  inherited;
end;

class function TfrxPictureView.GetDescription: String;
begin
  Result := frxResources.Get('obPicture');
end;

procedure TfrxPictureView.SetPicture(const Value: TPicture);
begin
  FPicture.Assign(Value);
end;

procedure TfrxPictureView.SetAutoSize(const Value: Boolean);
begin
  FAutoSize := Value;
  if FAutoSize and not (FPicture.Graphic = nil) then
  begin
    FWidth := FPicture.Width;
    FHeight := FPicture.Height;
  end;
end;

procedure TfrxPictureView.PictureChanged(Sender: TObject);
begin
  AutoSize := FAutoSize;
  FPictureChanged := True;
end;

procedure TfrxPictureView.Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended);
var
  r: TRect;
  kx, ky: Extended;
  rgn: HRGN;

  procedure PrintGraphic(Canvas: TCanvas; DestRect: TRect; aGraph: TGraphic);
  begin
    frxDrawGraphic(Canvas, DestRect, aGraph, IsPrinting);
  end;

begin
  BeginDraw(Canvas, ScaleX, ScaleY, OffsetX, OffsetY);

  with Canvas do
  begin
    DrawBackground;
    r := Rect(FX, FY, FX1, FY1);

    if (FPicture.Graphic = nil) or FPicture.Graphic.Empty then
    begin
      if IsDesigning then
        frxResources.ObjectImages.Draw(Canvas, FX + 1, FY + 2, 3);
    end
    else
    begin
      if FStretched then
      begin
        if FKeepAspectRatio then
        begin
          kx := FDX / FPicture.Width;
          ky := FDY / FPicture.Height;
          if kx < ky then
            r.Bottom := r.Top + Round(FPicture.Height * kx) else
            r.Right := r.Left + Round(FPicture.Width * ky);

          if FCenter then
            OffsetRect(r, (FDX - (r.Right - r.Left)) div 2,
                          (FDY - (r.Bottom - r.Top)) div 2);
        end;

        PrintGraphic(Canvas, r, FPicture.Graphic);
      end
      else
      begin
        rgn := CreateRectRgn(0, 0, 10000, 10000);
        GetClipRgn(Canvas.Handle, rgn);
        IntersectClipRect(Canvas.Handle,
          Round(FX),
          Round(FY),
          Round(FX1),
          Round(FY1));

        if FCenter then
          OffsetRect(r, (FDX - Round(ScaleX * FPicture.Width)) div 2,
                        (FDY - Round(ScaleY * FPicture.Height)) div 2);
        r.Right := r.Left + Round(FPicture.Width * ScaleX);
        r.Bottom := r.Top + Round(FPicture.Height * ScaleY);
        PrintGraphic(Canvas, r, Picture.Graphic);

        SelectClipRgn(Canvas.Handle, rgn);
        DeleteObject(rgn);
      end;
    end;

    DrawFrame;
  end;
end;

function TfrxPictureView.Diff(AComponent: TfrxComponent): String;
begin
  if FPictureChanged then
  begin
    Report.PreviewPages.AddPicture(Self);
    FPictureChanged := False;
  end;

  Result := ' ' + inherited Diff(AComponent) + ' ImageIndex="' +
    IntToStr(FImageIndex) + '"';
end;



const
  WMFKey = Integer($9AC6CDD7);
  WMFWord = $CDD7;
  rc3_StockIcon = 0;
  rc3_Icon = 1;
  rc3_Cursor = 2;

type
  TGraphicHeader = record
    Count: Word;
    HType: Word;
    Size: Longint;
  end;

  TMetafileHeader = packed record
    Key: Longint;
    Handle: SmallInt;
    Box: TSmallRect;
    Inch: Word;
    Reserved: Longint;
    CheckSum: Word;
  end;

  TCursorOrIcon = packed record
    Reserved: Word;
    wType: Word;
    Count: Word;
  end;

const
  OriginalPngHeader: array[0..7] of Char = (#137, #80, #78, #71, #13, #10, #26, #10);

function TfrxPictureView.LoadPictureFromStream(s: TStream): Hresult;
var
  pos: Integer;
  Header: TGraphicHeader;
  BMPHeader: TBitmapFileHeader;
{$IFDEF JPEG}
  JPEGHeader: array[0..1] of Byte;
{$ENDIF}
{$IFDEF PNG}
  PNGHeader: array[0..7] of Char;
{$ENDIF}
  EMFHeader: TEnhMetaHeader;
  WMFHeader: TMetafileHeader;
  ICOHeader: TCursorOrIcon;
  NewGraphic: TGraphic;
  bOK : Boolean;
begin
  NewGraphic := nil;

  if s.Size > 0 then
  begin
    // skip Delphi blob-image header
    if s.Size >= SizeOf(TGraphicHeader) then
    begin
      s.Read(Header, SizeOf(Header));
      if (Header.Count <> 1) or (Header.HType <> $0100) or
        (Header.Size <> s.Size - SizeOf(Header)) then
          s.Position := 0;
    end;
    pos := s.Position;

    bOK := False;

    if (s.Size-pos) >= SizeOf(BMPHeader) then
    begin
      // try bmp header
      s.ReadBuffer(BMPHeader, SizeOf(BMPHeader));
      s.Position := pos;
      if BMPHeader.bfType = $4D42 then
      begin
        NewGraphic := TBitmap.Create;
        bOK := True;
      end;
    end;

    {$IFDEF JPEG}
    if not bOK then
    begin
      if (s.Size-pos) >= SizeOf(JPEGHeader) then
      begin
        // try jpeg header
        s.ReadBuffer(JPEGHeader, SizeOf(JPEGHeader));
        s.Position := pos;
        if (JPEGHeader[0] = $FF) and (JPEGHeader[1] = $D8) then
        begin
          NewGraphic := TJPEGImage.Create;
          bOK := True;
        end;
      end;
    end;
    {$ENDIF}

    {$IFDEF PNG}
    if not bOK then
    begin
      if (s.Size-pos) >= SizeOf(PNGHeader) then
      begin
        // try png header
        s.ReadBuffer(PNGHeader, SizeOf(PNGHeader));
        s.Position := pos;
        if PNGHeader = OriginalPngHeader then
        begin
          NewGraphic := TPngObject.Create;
          bOK := True;
        end;
      end;
    end;
    {$ENDIF}

    if not bOK then
    begin
      if (s.Size-pos) >= SizeOf(WMFHeader) then
      begin
        // try wmf header
        s.ReadBuffer(WMFHeader, SizeOf(WMFHeader));
        s.Position := pos;
        if WMFHeader.Key = WMFKEY then
        begin
          NewGraphic := TMetafile.Create;
          bOK := True;
        end;
      end;
    end;

    if not bOK then
    begin
      if (s.Size-pos) >= SizeOf(EMFHeader) then
      begin
        // try emf header
        s.ReadBuffer(EMFHeader, SizeOf(EMFHeader));
        s.Position := pos;
        if EMFHeader.dSignature = ENHMETA_SIGNATURE then
        begin
          NewGraphic := TMetafile.Create;
          bOK := True;
        end;
      end;
    end;

    if not bOK then
    begin
      if (s.Size-pos) >= SizeOf(ICOHeader) then
      begin
        // try icon header
        s.ReadBuffer(ICOHeader, SizeOf(ICOHeader));
        s.Position := pos;
        if ICOHeader.wType in [RC3_STOCKICON, RC3_ICON] then
          NewGraphic := TIcon.Create;
      end;
    end;
  end;

  if NewGraphic <> nil then
  begin
    FPicture.Graphic := NewGraphic;
    NewGraphic.Free;
    FPicture.Graphic.LoadFromStream(s);
    Result := S_OK;
  end
  else
  begin
    FPicture.Assign(nil);
    Result := E_INVALIDARG;
  end;
// workaround pngimage bug
{$IFDEF PNG}
  if FPicture.Graphic is TPngObject then
    PictureChanged(nil);
{$ENDIF}
end;

procedure TfrxPictureView.GetData;
var
  m: TMemoryStream;
  s: String;
begin
  inherited;
  if FFileLink <> '' then
  begin
    s := FFileLink;
    if Pos('[', s) <> 0 then
      ExpandVariables(s);
    if FileExists(s) then
      FPicture.LoadFromFile(s)
    else
      FPicture.Assign(nil);
  end
  else if IsDataField and DataSet.IsBlobField(DataField) then
  begin
    m := TMemoryStream.Create;
    try
      DataSet.AssignBlobTo(DataField, m);
      LoadPictureFromStream(m);
    finally
      m.Free;
    end;
  end;
end;


{ TfrxBand }

constructor TfrxBand.Create(AOwner: TComponent);
begin
  inherited;
  FSubBands := TList.Create;
  FOriginalObjectsCount := -1;
end;

destructor TfrxBand.Destroy;
begin
  FSubBands.Free;
  inherited;
end;

procedure TfrxBand.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FChild) then
    FChild := nil;
end;

procedure TfrxBand.Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended);
begin
end;

function TfrxBand.GetBandName: String;
begin
  Result := ClassName;
  Delete(Result, Pos('Tfrx', Result), 4);
  Delete(Result, Pos('Band', Result), 4);
end;

function TfrxBand.BandNumber: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to BND_COUNT - 1 do
    if Self is frxBands[i] then
      Result := i;
end;

class function TfrxBand.GetDescription: String;
begin
  Result := frxResources.Get('obBand');
end;

procedure TfrxBand.SetLeft(Value: Extended);
begin
  if Parent is TfrxDMPPage then
    Value := Round(Value / fr1CharX) * fr1CharX;
  inherited;
end;

procedure TfrxBand.SetTop(Value: Extended);
begin
  if Parent is TfrxDMPPage then
    Value := Round(Value / fr1CharY) * fr1CharY;
  inherited;
end;

procedure TfrxBand.SetHeight(Value: Extended);
begin
  if Parent is TfrxDMPPage then
    Value := Round(Value / fr1CharY) * fr1CharY;
  inherited;
end;

procedure TfrxBand.SetChild(Value: TfrxChild);
var
  b: TfrxBand;
begin
  b := Value;
  while b <> nil do
  begin
    b := b.Child;
    if b = Self then
      raise Exception.Create('Circular child reference is not allowed');
  end;
  FChild := Value;
end;


{ TfrxDataBand }

constructor TfrxDataBand.Create(AOwner: TComponent);
begin
  inherited;
  FVirtualDataSet := TfrxUserDataSet.Create(nil);
  FVirtualDataSet.RangeEnd := reCount;
end;

destructor TfrxDataBand.Destroy;
begin
  FVirtualDataSet.Free;
  inherited;
end;

class function TfrxDataBand.GetDescription: String;
begin
  Result := frxResources.Get('obDataBand');
end;

procedure TfrxDataBand.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FDataSet) then
    FDataSet := nil;
end;

procedure TfrxDataBand.SetCurColumn(Value: Integer);
begin
  if Value > FColumns then
    Value := 1;
  FCurColumn := Value;
  if FCurColumn = 1 then
    FMaxY := 0;
  FLeft := (FCurColumn - 1) * (FColumnWidth + FColumnGap);
end;

procedure TfrxDataBand.SetDataSet(const Value: TfrxDataSet);
begin
  FDataSet := Value;
  if FDataSet = nil then
    FDataSetName := '' else
    FDataSetName := FDataSet.UserName;
end;

procedure TfrxDataBand.SetDataSetName(const Value: String);
begin
  FDataSetName := Value;
  FDataSet := frxFindDataSet(FDataSet, FDataSetName, Report);
end;

function TfrxDataBand.GetDataSetName: String;
begin
  if FDataSet = nil then
    Result := FDataSetName else
    Result := FDataSet.UserName;
end;

procedure TfrxDataBand.SetRowCount(const Value: Integer);
begin
  FRowCount := Value;
  FVirtualDataSet.RangeEndCount := Value;
end;



{ TfrxPageHeader }

constructor TfrxPageHeader.Create(AOwner: TComponent);
begin
  inherited;
  FPrintOnFirstPage := True;
end;


{ TfrxPageFooter }

constructor TfrxPageFooter.Create(AOwner: TComponent);
begin
  inherited;
  FPrintOnFirstPage := True;
  FPrintOnLastPage := True;
end;


{ TfrxGroupHeader }

function TfrxGroupHeader.Diff(AComponent: TfrxComponent): String;
begin
  Result := inherited Diff(AComponent);
  if FDrillDown then
    Result := Result + ' Tag="' + IntToStr(FLineThrough) + '"';
end;


{ TfrxSubreport }

constructor TfrxSubreport.Create(AOwner: TComponent);
begin
  inherited;
  frComponentStyle := frComponentStyle - [csPreviewVisible];
  FFrame.Typ := [ftLeft, ftRight, ftTop, ftBottom];
  FFont.Name := 'Tahoma';
  FFont.Size := 8;
  FColor := clSilver;
end;

destructor TfrxSubreport.Destroy;
begin
  if FPage <> nil then
    FPage.FSubReport := nil;
  inherited;
end;

procedure TfrxSubreport.SetPage(const Value: TfrxReportPage);
begin
  FPage := Value;
  if FPage <> nil then
    FPage.FSubReport := Self;
end;

procedure TfrxSubreport.Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX,
  OffsetY: Extended);
begin
  inherited;

  with Canvas do
  begin
    Font.Assign(FFont);
    TextOut(FX + 2, FY + 2, Name);
  end;
end;

class function TfrxSubreport.GetDescription: String;
begin
  Result := frxResources.Get('obSubRep');
end;




{ TfrxDialogPage }

constructor TfrxDialogPage.Create(AOwner: TComponent);
var
  FSaveTag: Integer;
begin
  inherited;
  FSaveTag := Tag;
  if (Report <> nil) and Report.EngineOptions.EnableThreadSafe then
    Tag := 318
  else
    Tag := 0;
  FForm := TfrxDialogForm.Create(Self);
  Tag := FSaveTag;
  FForm.KeyPreview := True;
  Font.Name := 'Tahoma';
  Font.Size := 8;
  BorderStyle := bsSizeable;
  Position := poScreenCenter;
  WindowState := wsNormal;
  Color := clBtnFace;
end;

destructor TfrxDialogPage.Destroy;
begin
  frxCS.Enter;
  try
    inherited;
    FForm.Free;
  finally
    frxCS.Leave;
  end;
end;

class function TfrxDialogPage.GetDescription: String;
begin
  Result := frxResources.Get('obDlgPage');
end;

procedure TfrxDialogPage.SetLeft(Value: Extended);
begin
  inherited;
  FForm.Left := Round(Value);
end;

procedure TfrxDialogPage.SetTop(Value: Extended);
begin
  inherited;
  FForm.Top := Round(Value);
end;

procedure TfrxDialogPage.SetWidth(Value: Extended);
begin
  inherited;
  FForm.Width := Round(Value);
end;

procedure TfrxDialogPage.SetHeight(Value: Extended);
begin
  inherited;
  FForm.Height := Round(Value);
end;

procedure TfrxDialogPage.SetBorderStyle(const Value: TFormBorderStyle);
begin
  FBorderStyle := Value;
end;

procedure TfrxDialogPage.SetCaption(const Value: String);
begin
  FCaption := Value;
  FForm.Caption := Value;
end;

procedure TfrxDialogPage.SetColor(const Value: TColor);
begin
  FColor := Value;
  FForm.Color := Value;
end;

function TfrxDialogPage.GetModalResult: TModalResult;
begin
  Result := FForm.ModalResult;
end;

procedure TfrxDialogPage.SetModalResult(const Value: TModalResult);
begin
  FForm.ModalResult := Value;
end;

procedure TfrxDialogPage.FontChanged(Sender: TObject);
begin
  inherited;
  FForm.Font := Font;
end;

procedure TfrxDialogPage.DoInitialize;
begin
  if FForm.Visible then
    FForm.Hide;
  FForm.Position := FPosition;
  FForm.WindowState := FWindowState;
  FForm.OnActivate := DoOnActivate;
  FForm.OnClick := DoOnClick;
  FForm.OnCloseQuery := DoOnCloseQuery;
  FForm.OnDeactivate := DoOnDeactivate;
  FForm.OnHide := DoOnHide;
  FForm.OnKeyDown := DoOnKeyDown;
  FForm.OnKeyPress := DoOnKeyPress;
  FForm.OnKeyUp := DoOnKeyUp;
  FForm.OnShow := DoOnShow;
  FForm.OnResize := DoOnResize;
end;

procedure TfrxDialogPage.Initialize;
begin

//  if (Report <> nil) and (Report.EngineOptions.ReportThread <> nil) then
//    THackThread(Report.EngineOptions.ReportThread).Synchronize(DoInitialize) else

    DoInitialize;
end;

function TfrxDialogPage.ShowModal: TModalResult;
begin
  Initialize;
  FForm.BorderStyle := FBorderStyle;
  FForm.FormStyle := fsNormal;
  try
    TfrxDialogForm(FForm).OnModify := DoModify;
    Result := FForm.ShowModal;
  finally
    FForm.FormStyle := fsStayOnTop;
  end;
end;

procedure TfrxDialogPage.DoModify(Sender: TObject);
begin
  FLeft := FForm.Left;
  FTop := FForm.Top;
  FWidth := FForm.Width;
  FHeight := FForm.Height;
end;

procedure TfrxDialogPage.DoOnActivate(Sender: TObject);
begin
  DoModify(nil);
  Report.DoNotifyEvent(Sender, FOnActivate);
end;

procedure TfrxDialogPage.DoOnClick(Sender: TObject);
begin
  Report.DoNotifyEvent(Sender, FOnClick);
end;

procedure TfrxDialogPage.DoOnCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  v: Variant;
begin
  v := VarArrayOf([Integer(Sender), CanClose]);
  Report.DoParamEvent(FOnCloseQuery, v);
  CanClose := v[1];
end;

procedure TfrxDialogPage.DoOnDeactivate(Sender: TObject);
begin
  Report.DoNotifyEvent(Sender, FOnDeactivate);
end;

procedure TfrxDialogPage.DoOnHide(Sender: TObject);
begin
  Report.DoNotifyEvent(Sender, FOnHide);
end;

procedure TfrxDialogPage.DoOnKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  v: Variant;
begin
  v := VarArrayOf([Integer(Sender), Key, ShiftToByte(Shift)]);
  if Report <> nil then
    Report.DoParamEvent(FOnKeyDown, v);
  Key := v[1];
end;

procedure TfrxDialogPage.DoOnKeyPress(Sender: TObject; var Key: Char);
var
  v: Variant;
begin
  v := VarArrayOf([Integer(Sender), Key]);
  if Report <> nil then
    Report.DoParamEvent(FOnKeyPress, v);
  if VarToStr(v[1]) <> '' then
    Key := VarToStr(v[1])[1]
  else
    Key := Chr(0);
end;

procedure TfrxDialogPage.DoOnKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  v: Variant;
begin
  v := VarArrayOf([Integer(Sender), Key, ShiftToByte(Shift)]);
  if Report <> nil then
    Report.DoParamEvent(FOnKeyUp, v);
  Key := v[1];
end;

procedure TfrxDialogPage.DoOnShow(Sender: TObject);
begin
  FForm.Perform(CM_FOCUSCHANGED, 0, Longint(FForm.ActiveControl));
  Report.DoNotifyEvent(Sender, FOnShow);
end;

procedure TfrxDialogPage.DoOnResize(Sender: TObject);
begin
  Report.DoNotifyEvent(Sender, FOnResize);
end;


{ TfrxReportPage }

constructor TfrxReportPage.Create(AOwner: TComponent);
begin
  inherited;
  FBackPicture := TfrxPictureView.Create(nil);
  FBackPicture.Color := clTransparent;
  FBackPicture.KeepAspectRatio := False;
  FColumnPositions := TStringList.Create;
  FOrientation := poPortrait;
  PaperSize := DMPAPER_A4;
  FBin := DMBIN_AUTO;
  FBinOtherPages := DMBIN_AUTO;
  FBaseName := 'Page';
  FSubBands := TList.Create;
  FVSubBands := TList.Create;
  FHGuides := TStringList.Create;
  FVGuides := TStringList.Create;
  FPrintIfEmpty := True;
  FTitleBeforeHeader := True;
end;

destructor TfrxReportPage.Destroy;
begin
  FColumnPositions.Free;
  FBackPicture.Free;
  FSubBands.Free;
  FVSubBands.Free;
  FHGuides.Free;
  FVGuides.Free;
  inherited;
end;

class function TfrxReportPage.GetDescription: String;
begin
  Result := frxResources.Get('obRepPage');
end;

procedure TfrxReportPage.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FDataSet) then
    FDataSet := nil;
end;

procedure TfrxReportPage.SetDataSet(const Value: TfrxDataSet);
begin
  FDataSet := Value;
  if FDataSet = nil then
    FDataSetName := '' else
    FDataSetName := FDataSet.UserName;
end;

procedure TfrxReportPage.SetDataSetName(const Value: String);
begin
  FDataSetName := Value;
  FDataSet := frxFindDataSet(FDataSet, FDataSetName, Report);
end;

function TfrxReportPage.GetDataSetName: String;
begin
  if FDataSet = nil then
    Result := FDataSetName else
    Result := FDataSet.UserName;
end;

procedure TfrxReportPage.SetPaperHeight(const Value: Extended);
begin
  FPaperHeight := Round8(Value);
  FPaperSize := 256;
  UpdateDimensions;
end;

procedure TfrxReportPage.SetPaperWidth(const Value: Extended);
begin
  FPaperWidth := Round8(Value);
  FPaperSize := 256;
  UpdateDimensions;
end;

procedure TfrxReportPage.SetPaperSize(const Value: Integer);
var
  e: Extended;
begin
  FPaperSize := Value;
  if FPaperSize < DMPAPER_USER then
  begin
    if frxGetPaperDimensions(FPaperSize, FPaperWidth, FPaperHeight) then
      if FOrientation = poLandscape then
      begin
        e := FPaperWidth;
        FPaperWidth := FPaperHeight;
        FPaperHeight := e;
      end;
    UpdateDimensions;
  end;
end;

procedure TfrxReportPage.SetSizeAndDimensions(ASize: Integer; AWidth,
  AHeight: Extended);
begin
  FPaperSize := ASize;
  FPaperWidth := Round8(AWidth);
  FPaperHeight := Round8(AHeight);
  UpdateDimensions;
end;

procedure TfrxReportPage.SetColumns(const Value: Integer);
begin
  FColumns := Value;
  FColumnPositions.Clear;
  if FColumns <= 0 then exit;

  FColumnWidth := (FPaperWidth - FLeftMargin - FRightMargin) / FColumns;
  while FColumnPositions.Count < FColumns do
    FColumnPositions.Add(FloatToStr(FColumnPositions.Count * FColumnWidth));
end;

procedure TfrxReportPage.SetOrientation(Value: TPrinterOrientation);
var
  e, m1, m2, m3, m4: Extended;
begin
  if FOrientation <> Value then
  begin
    e := FPaperWidth;
    FPaperWidth := FPaperHeight;
    FPaperHeight := e;

    m1 := FLeftMargin;
    m2 := FRightMargin;
    m3 := FTopMargin;
    m4 := FBottomMargin;

    if Value = poLandscape then
    begin
      FLeftMargin := m3;
      FRightMargin := m4;
      FTopMargin := m2;
      FBottomMargin := m1;
    end
    else
    begin
      FLeftMargin := m4;
      FRightMargin := m3;
      FTopMargin := m1;
      FBottomMargin := m2;
    end;
    UpdateDimensions;
  end;

  FOrientation := Value;
end;

procedure TfrxReportPage.UpdateDimensions;
begin
  Width := Round(FPaperWidth * fr01cm);
  Height := Round(FPaperHeight * fr01cm);
end;

procedure TfrxReportPage.ClearGuides;
begin
  FHGuides.Clear;
  FVGuides.Clear;
end;

procedure TfrxReportPage.SetHGuides(const Value: TStrings);
begin
  FHGuides.Assign(Value);
end;

procedure TfrxReportPage.SetVGuides(const Value: TStrings);
begin
  FVGuides.Assign(Value);
end;

function TfrxReportPage.FindBand(Band: TfrxBandClass): TfrxBand;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to FObjects.Count - 1 do
    if TObject(FObjects[i]) is Band then
    begin
      Result := FObjects[i];
      break;
    end;
end;

function TfrxReportPage.IsSubReport: Boolean;
begin
  Result := SubReport <> nil;
end;

procedure TfrxReportPage.SetColumnPositions(const Value: TStrings);
begin
  FColumnPositions.Assign(Value);
end;

function TfrxReportPage.GetFrame: TfrxFrame;
begin
  Result := FBackPicture.Frame;
end;

procedure TfrxReportPage.SetFrame(const Value: TfrxFrame);
begin
  FBackPicture.Frame := Value;
end;

function TfrxReportPage.GetColor: TColor;
begin
  Result := FBackPicture.Color;
end;

procedure TfrxReportPage.SetColor(const Value: TColor);
begin
  FBackPicture.Color := Value;
end;

function TfrxReportPage.GetBackPicture: TPicture;
begin
  Result := FBackPicture.Picture;
end;

procedure TfrxReportPage.SetBackPicture(const Value: TPicture);
begin
  FBackPicture.Picture := Value;
end;

procedure TfrxReportPage.Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX,
  OffsetY: Extended);
begin
  FBackPicture.Width := (FPaperWidth - FLeftMargin - FRightMargin) * fr01cm;
  FBackPicture.Height := (FPaperHeight - FTopMargin - FBottomMargin) * fr01cm;
  FBackPicture.Draw(Canvas, ScaleX, ScaleY,
    OffsetX + FLeftMargin * fr01cm * ScaleX,
    OffsetY + FTopMargin * fr01cm * ScaleY);
end;

procedure TfrxReportPage.SetDefaults;
begin
  FLeftMargin := 10;
  FRightMargin := 10;
  FTopMargin := 10;
  FBottomMargin := 10;
  FPaperSize := frxPrinters.Printer.DefPaper;
  FPaperWidth := frxPrinters.Printer.DefPaperWidth;
  FPaperHeight := frxPrinters.Printer.DefPaperHeight;
  FOrientation := frxPrinters.Printer.DefOrientation;
  UpdateDimensions;
end;

procedure TfrxReportPage.AlignChildren;
var
  i: Integer;
  c: TfrxComponent;
begin
  Width := (FPaperWidth - FLeftMargin - FRightMargin) * fr01cm;
  Height := (FPaperHeight - FTopMargin - FBottomMargin) * fr01cm;
  inherited;
  for i := 0 to Objects.Count - 1 do
  begin
    c := Objects[i];
    if c is TfrxBand then
    begin
      if TfrxBand(c).Vertical then
        c.Height := (FPaperHeight - FTopMargin - FBottomMargin) * fr01cm - c.Top
      else
        c.Width := Width - c.Left;
// previous bugfix is wrong!!!
//      if c.Width > Width then
//        c.Width := Width;
//      if c.Height > Height then
//        c.Height := Height;
      c.AlignChildren;
    end;
  end;
  UpdateDimensions;
end;



{ TfrxDataPage }

constructor TfrxDataPage.Create(AOwner: TComponent);
begin
  inherited;
  Width := 1000;
  Height := 1000;
end;

class function TfrxDataPage.GetDescription: String;
begin
  Result := frxResources.Get('obDataPage');
end;


{ TfrxEngineOptions }

constructor TfrxEngineOptions.Create;
begin
  Clear;
  FMaxMemSize := 10;
  FPrintIfEmpty := True;
  FSilentMode := simMessageBoxes;
  FEnableThreadSafe := False;
  FTempDir := '';

  FUseFileCache := False;

  FDestroyForms := True;
end;

procedure TfrxEngineOptions.Assign(Source: TPersistent);
begin
  if Source is TfrxEngineOptions then
  begin
    FConvertNulls := TfrxEngineOptions(Source).ConvertNulls;
    FDoublePass := TfrxEngineOptions(Source).DoublePass;
    FMaxMemSize := TfrxEngineOptions(Source).MaxMemSize;
    FPrintIfEmpty := TfrxEngineOptions(Source).PrintIfEmpty;
    NewSilentMode := TfrxEngineOptions(Source).NewSilentMode;
    FTempDir := TfrxEngineOptions(Source).TempDir;
    FUseFileCache := TfrxEngineOptions(Source).UseFileCache;
  end;
end;

procedure TfrxEngineOptions.Clear;
begin
  FConvertNulls := True;
  FDoublePass := False;
end;

procedure TfrxEngineOptions.SetSilentMode(Mode: Boolean);
begin
  if Mode = True then
    FSilentMode := simSilent
  else
    FSilentMode := simMessageBoxes;
end;

function TfrxEngineOptions.GetSilentMode: Boolean;
begin
  if FSilentMode = simSilent then
    Result := True
  else
    Result := False;
end;



{ TfrxPreviewOptions }

constructor TfrxPreviewOptions.Create;
begin
  Clear;
  FAllowEdit := True;
  FButtons := [pbPrint, pbLoad, pbSave, pbExport, pbZoom, pbFind,
    pbOutline, pbPageSetup, pbTools, pbEdit, pbNavigator, pbExportQuick];
  FDoubleBuffered := True;
  FMaximized := True;
  FMDIChild := False;
  FModal := True;
  FShowCaptions := False;
  FZoom := 1;
  FZoomMode := zmDefault;
end;

procedure TfrxPreviewOptions.Assign(Source: TPersistent);
begin
  if Source is TfrxPreviewOptions then
  begin
    FAllowEdit := TfrxPreviewOptions(Source).AllowEdit;
    FButtons := TfrxPreviewOptions(Source).Buttons;
    FDoubleBuffered := TfrxPreviewOptions(Source).DoubleBuffered;
    FMaximized := TfrxPreviewOptions(Source).Maximized;
    FMDIChild := TfrxPreviewOptions(Source).MDIChild;
    FModal := TfrxPreviewOptions(Source).Modal;
    FOutlineExpand := TfrxPreviewOptions(Source).OutlineExpand;
    FOutlineVisible := TfrxPreviewOptions(Source).OutlineVisible;
    FOutlineWidth := TfrxPreviewOptions(Source).OutlineWidth;
    FShowCaptions := TfrxPreviewOptions(Source).ShowCaptions;
    FZoom := TfrxPreviewOptions(Source).Zoom;
    FZoomMode := TfrxPreviewOptions(Source).ZoomMode;
  end;
end;

procedure TfrxPreviewOptions.Clear;
begin
  FOutlineExpand := True;
  FOutlineVisible := False;
  FOutlineWidth := 120;
end;



{ TfrxPrintOptions }

constructor TfrxPrintOptions.Create;
begin
  Clear;
end;

procedure TfrxPrintOptions.Assign(Source: TPersistent);
begin
  if Source is TfrxPrintOptions then
  begin
    FCopies := TfrxPrintOptions(Source).Copies;
    FCollate := TfrxPrintOptions(Source).Collate;
    FPageNumbers := TfrxPrintOptions(Source).PageNumbers;
    FPrinter := TfrxPrintOptions(Source).Printer;
    FPrintMode := TfrxPrintOptions(Source).PrintMode;
    FPrintOnSheet := TfrxPrintOptions(Source).PrintOnSheet;
    FPrintPages := TfrxPrintOptions(Source).PrintPages;
    FReverse := TfrxPrintOptions(Source).Reverse;
    FShowDialog := TfrxPrintOptions(Source).ShowDialog;
  end;
end;

procedure TfrxPrintOptions.Clear;
begin
  FCopies := 1;
  FCollate := True;
  FPageNumbers := '';
  FPagesOnSheet := 0;
  FPrinter := frxResources.Get('prDefault');
  FPrintMode := pmDefault;
  FPrintOnSheet := 0;
  FPrintPages := ppAll;
  FReverse := False;
  FShowDialog := True;
end;



{ TfrxReportOptions }

constructor TfrxReportOptions.Create;
begin
  FDescription := TStringList.Create;
  FPicture := TPicture.Create;
  FCreateDate := Now;
  FLastChange := Now;
  FPrevPassword := '';
  FInfo := False;
end;

destructor TfrxReportOptions.Destroy;
begin
  FDescription.Free;
  FPicture.Free;
  inherited;
end;

procedure TfrxReportOptions.Assign(Source: TPersistent);
begin
  if Source is TfrxReportOptions then
  begin
    FAuthor := TfrxReportOptions(Source).Author;
    FCompressed := TfrxReportOptions(Source).Compressed;
    FConnectionName := TfrxReportOptions(Source).ConnectionName;
    FCreateDate := TfrxReportOptions(Source).CreateDate;
    Description := TfrxReportOptions(Source).Description;
    FInitString := TfrxReportOptions(Source).InitString;
    FLastChange := TfrxReportOptions(Source).LastChange;
    FName := TfrxReportOptions(Source).Name;
    FPassword := TfrxReportOptions(Source).Password;
    Picture := TfrxReportOptions(Source).Picture;
    FVersionBuild := TfrxReportOptions(Source).VersionBuild;
    FVersionMajor := TfrxReportOptions(Source).VersionMajor;
    FVersionMinor := TfrxReportOptions(Source).VersionMinor;
    FVersionRelease := TfrxReportOptions(Source).VersionRelease;
  end;
end;

procedure TfrxReportOptions.Clear;
begin
  if not FInfo then
  begin
    FAuthor := '';
    FCompressed := False;
    FCreateDate := Now;
    FDescription.Clear;
    FLastChange := Now;
    FPicture.Assign(nil);
    FVersionBuild := '';
    FVersionMajor := '';
    FVersionMinor := '';
    FVersionRelease := '';
  end;
  FConnectionName := '';
  FInitString := '';
  FName := '';
  FPassword := '';
  FPrevPassword := '';
end;

procedure TfrxReportOptions.SetDescription(const Value: TStrings);
begin
  FDescription.Assign(Value);
end;

procedure TfrxReportOptions.SetPicture(const Value: TPicture);
begin
  FPicture.Assign(Value);
end;

function TfrxReportOptions.CheckPassword: Boolean;
begin
  Result := True;
  if (FPassword <> '') and (FPassword <> FPrevPassword) then
    with TfrxPasswordForm.Create(Application) do
    begin
      if (ShowModal <> mrOk) or (FPassword <> PasswordE.Text) then
        Result := False
      else
        FPrevPassword := FPassword;
      Free;
    end;
end;

procedure TfrxReportOptions.SetConnectionName(const Value: String);
var
  ini: TRegistry;
begin
  FConnectionName := Value;
  if Value <> '' then
    if Assigned(FReport.OnSetConnection) then
    begin
      ini := TRegistry.Create;
      try
        ini.RootKey := HKEY_LOCAL_MACHINE;
        if ini.OpenKey(DEF_REG_CONNECTIONS, false) then
          FReport.OnSetConnection(ini.ReadString(Value));
      finally
        ini.Free;
      end;
    end;
end;



{ TfrxDataSetItem }

procedure TfrxDataSetItem.SetDataSet(const Value: TfrxDataSet);
begin
  FDataSet := Value;
  if FDataSet = nil then
    FDataSetName := '' else
    FDataSetName := FDataSet.UserName;
end;

procedure TfrxDataSetItem.SetDataSetName(const Value: String);
begin
  FDataSetName := Value;
  FDataSet := frxFindDataSet(FDataSet, FDataSetName,
    TfrxReportDataSets(Collection).FReport);
end;

function TfrxDataSetItem.GetDataSetName: String;
begin
  if FDataSet = nil then
    Result := FDataSetName else
    Result := FDataSet.UserName;
end;


{ TfrxReportDatasets }

constructor TfrxReportDatasets.Create(AReport: TfrxReport);
begin
  inherited Create(TfrxDatasetItem);
  FReport := AReport;
end;

procedure TfrxReportDataSets.Initialize;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if Items[i].DataSet <> nil then
    begin
      Items[i].DataSet.ReportRef := FReport;
      Items[i].DataSet.Initialize;
    end;
end;

procedure TfrxReportDataSets.Finalize;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if Items[i].DataSet <> nil then
      Items[i].DataSet.Finalize;
end;

procedure TfrxReportDatasets.Add(ds: TfrxDataSet);
begin
  TfrxDatasetItem(inherited Add).DataSet := ds;
end;

function TfrxReportDatasets.GetItem(Index: Integer): TfrxDatasetItem;
begin
  Result := TfrxDatasetItem(inherited Items[Index]);
end;

function TfrxReportDatasets.Find(ds: TfrxDataSet): TfrxDatasetItem;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
    if Items[i].DataSet = ds then
    begin
      Result := Items[i];
      Exit;
    end;
end;

function TfrxReportDatasets.Find(const Name: String): TfrxDatasetItem;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
    if Items[i].DataSet <> nil then
      if CompareText(Items[i].DataSet.UserName, Name) = 0 then
      begin
        Result := Items[i];
        Exit;
      end;
end;

procedure TfrxReportDatasets.Delete(const Name: String);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if Items[i].DataSet <> nil then
      if CompareText(Items[i].DataSet.UserName, Name) = 0 then
      begin
        Items[i].Free;
        Exit;
      end;
end;

{ TfrxStyleItem }

constructor TfrxStyleItem.Create(Collection: TCollection);
begin
  inherited;
  FColor := clNone;
  FFont := TFont.Create;
  with FFont do
  begin
    Name := DefFontName;
    Size := DefFontSize;
    Charset := frxCharset;
  end;
  FFrame := TfrxFrame.Create;
end;

destructor TfrxStyleItem.Destroy;
begin
  FFont.Free;
  FFrame.Free;
  inherited;
end;

procedure TfrxStyleItem.Assign(Source: TPersistent);
begin
  if Source is TfrxStyleItem then
  begin
    FName := TfrxStyleItem(Source).Name;
    FColor := TfrxStyleItem(Source).Color;
    FFont.Assign(TfrxStyleItem(Source).Font);
    FFrame.Assign(TfrxStyleItem(Source).Frame);
  end;
end;

procedure TfrxStyleItem.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TfrxStyleItem.SetFrame(const Value: TfrxFrame);
begin
  FFrame.Assign(Value);
end;

procedure TfrxStyleItem.SetName(const Value: String);
var
  Item: TfrxStyleItem;
begin
  Item := TfrxStyles(Collection).Find(Value);
  if (Item = nil) or (Item = Self) then
    FName := Value else
    raise Exception.Create('Duplicate name');
end;

procedure TfrxStyleItem.CreateUniqueName;
var
  i: Integer;
begin
  i := 1;
  while TfrxStyles(Collection).Find('Style' + IntToStr(i)) <> nil do
    Inc(i);
  Name := 'Style' + IntToStr(i);
end;


{ TfrxStyles }

constructor TfrxStyles.Create(AReport: TfrxReport);
begin
  inherited Create(TfrxStyleItem);
  FReport := AReport;
end;

function TfrxStyles.Add: TfrxStyleItem;
begin
  Result := TfrxStyleItem(inherited Add);
end;

function TfrxStyles.Find(const Name: String): TfrxStyleItem;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
    if AnsiCompareText(Items[i].Name, Name) = 0 then
    begin
      Result := Items[i];
      break;
    end;
end;

function TfrxStyles.GetItem(Index: Integer): TfrxStyleItem;
begin
  Result := TfrxStyleItem(inherited Items[Index]);
end;

procedure TfrxStyles.GetList(List: TStrings);
var
  i: Integer;
begin
  List.Clear;
  for i := 0 to Count - 1 do
    List.Add(Items[i].Name);
end;

procedure TfrxStyles.LoadFromXMLItem(Item: TfrxXMLItem);
var
  xs: TfrxXMLSerializer;
  i: Integer;
begin
  Clear;
  xs := TfrxXMLSerializer.Create(nil);
  try
    Name := Item.Prop['Name'];
    for i := 0 to Item.Count - 1 do
      if CompareText(Item[i].Name, 'item') = 0 then
        xs.XMLToObj(Item[i].Text, Add);
  finally
    xs.Free;
  end;

  Apply;
end;

procedure TfrxStyles.SaveToXMLItem(Item: TfrxXMLItem);
var
  xi: TfrxXMLItem;
  xs: TfrxXMLSerializer;
  i: Integer;
begin
  xs := TfrxXMLSerializer.Create(nil);
  try
    Item.Name := 'style';
    Item.Prop['Name'] := Name;
    for i := 0 to Count - 1 do
    begin
      xi := Item.Add;
      xi.Name := 'item';
      xi.Text := xs.ObjToXML(Items[i]);
    end;
  finally
    xs.Free;
  end;
end;

procedure TfrxStyles.LoadFromFile(const FileName: String);
var
  f: TFileStream;
begin
  f := TFileStream.Create(FileName, fmOpenRead);
  try
    LoadFromStream(f);
  finally
    f.Free;
  end;
end;

procedure TfrxStyles.LoadFromStream(Stream: TStream);
var
  x: TfrxXMLDocument;
begin
  Clear;
  x := TfrxXMLDocument.Create;
  try
    x.LoadFromStream(Stream);
    if CompareText(x.Root.Name, 'style') = 0 then
      LoadFromXMLItem(x.Root);
  finally
    x.Free;
  end;
end;

procedure TfrxStyles.SaveToFile(const FileName: String);
var
  f: TFileStream;
begin
  f := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(f);
  finally
    f.Free;
  end;
end;

procedure TfrxStyles.SaveToStream(Stream: TStream);
var
  x: TfrxXMLDocument;
begin
  x := TfrxXMLDocument.Create;
  x.AutoIndent := True;
  try
    x.Root.Name := 'style';
    SaveToXMLItem(x.Root);
    x.SaveToStream(Stream);
  finally
    x.Free;
  end;
end;

procedure TfrxStyles.Apply;
var
  i: Integer;
  l: TList;
begin
  if FReport <> nil then
  begin
    l := FReport.AllObjects;
    for i := 0 to l.Count - 1 do
      if TObject(l[i]) is TfrxCustomMemoView then
        if Find(TfrxCustomMemoView(l[i]).Style) = nil then
          TfrxCustomMemoView(l[i]).Style := ''
        else
          TfrxCustomMemoView(l[i]).Style := TfrxCustomMemoView(l[i]).Style;
  end;
end;


{ TfrxStyleSheet }

constructor TfrxStyleSheet.Create;
begin
  FItems := TList.Create;
end;

destructor TfrxStyleSheet.Destroy;
begin
  Clear;
  FItems.Free;
  inherited;
end;

procedure TfrxStyleSheet.Clear;
begin
  while Count > 0 do
    Delete(0);
end;

procedure TfrxStyleSheet.Delete(Index: Integer);
begin
  Items[Index].Free;
  FItems.Delete(Index);
end;

function TfrxStyleSheet.Add: TfrxStyles;
begin
  Result := TfrxStyles.Create(nil);
  FItems.Add(Result);
end;

function TfrxStyleSheet.Count: Integer;
begin
  Result := FItems.Count;
end;

function TfrxStyleSheet.GetItems(Index: Integer): TfrxStyles;
begin
  Result := FItems[Index];
end;

function TfrxStyleSheet.Find(const Name: String): TfrxStyles;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
    if AnsiCompareText(Items[i].Name, Name) = 0 then
    begin
      Result := Items[i];
      break;
    end;
end;

function TfrxStyleSheet.IndexOf(const Name: String): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Count - 1 do
    if AnsiCompareText(Items[i].Name, Name) = 0 then
    begin
      Result := i;
      break;
    end;
end;

procedure TfrxStyleSheet.GetList(List: TStrings);
var
  i: Integer;
begin
  List.Clear;
  for i := 0 to Count - 1 do
    List.Add(Items[i].Name);
end;

procedure TfrxStyleSheet.LoadFromFile(const FileName: String);
var
  f: TFileStream;
begin
  f := TFileStream.Create(FileName, fmOpenRead);
  try
    LoadFromStream(f);
  finally
    f.Free;
  end;
end;

procedure TfrxStyleSheet.LoadFromStream(Stream: TStream);
var
  x: TfrxXMLDocument;
  i: Integer;
begin
  Clear;
  x := TfrxXMLDocument.Create;
  try
    x.LoadFromStream(Stream);
    if CompareText(x.Root.Name, 'stylesheet') = 0 then
      for i := 0 to x.Root.Count - 1 do
        if CompareText(x.Root[i].Name, 'style') = 0 then
          Add.LoadFromXMLItem(x.Root[i]);
  finally
    x.Free;
  end;
end;

procedure TfrxStyleSheet.SaveToFile(const FileName: String);
var
  f: TFileStream;
begin
  f := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(f);
  finally
    f.Free;
  end;
end;

procedure TfrxStyleSheet.SaveToStream(Stream: TStream);
var
  x: TfrxXMLDocument;
  i: Integer;
begin
  x := TfrxXMLDocument.Create;
  x.AutoIndent := True;
  try
    x.Root.Name := 'stylesheet';
    for i := 0 to Count - 1 do
      Items[i].SaveToXMLItem(x.Root.Add);

    x.SaveToStream(Stream);
  finally
    x.Free;
  end;
end;


{ TfrxReport }

constructor TfrxReport.Create(AOwner: TComponent);
begin
  inherited;
  FVersion := FR_VERSION;
  FDatasets := TfrxReportDatasets.Create(Self);
  FVariables := TfrxVariables.Create;
  FScript := TfsScript.Create(nil);
  FScript.ExtendedCharset := True;
  FScript.AddRTTI;

  FTimer := TTimer.Create(nil);
  FTimer.Interval := 50;
  FTimer.Enabled := False;
  FTimer.OnTimer := OnTimer;

  FEngineOptions := TfrxEngineOptions.Create;
  FPreviewOptions := TfrxPreviewOptions.Create;
  FPrintOptions := TfrxPrintOptions.Create;
  FReportOptions := TfrxReportOptions.Create(Self);
  FReportOptions.FReport := Self;

  FIniFile := '\Software\Fast Reports';
  FScriptText := TStringList.Create;
  FExpressionCache := TfrxExpressionCache.Create(FScript);
  FErrors := TStringList.Create;
  TStringList(FErrors).Sorted := True;
  TStringList(FErrors).Duplicates := dupIgnore;
  FStyles := TfrxStyles.Create(Self);
  FSysVariables := TStringList.Create;
  FEnabledDataSets := TfrxReportDataSets.Create(Self);
  FShowProgress := True;
  FStoreInDFM := True;

  FEngine := TfrxEngine.Create(Self);
  FPreviewPages := TfrxPreviewPages.Create(Self);
  FEngine.FPreviewPages := FPreviewPages;
  FPreviewPages.FEngine := FEngine;
  FDrawText := TfrxDrawText.Create;
  FDrillState := TStringList.Create;
  Clear;

end;

destructor TfrxReport.Destroy;
begin
  inherited;
  Preview := nil;

  FDatasets.Free;
  FEngineOptions.Free;
  FPreviewOptions.Free;
  FPrintOptions.Free;
  FReportOptions.Free;

  FExpressionCache.Free;
  FScript.Free;
  FScriptText.Free;
  FVariables.Free;
  FEngine.Free;
  FPreviewPages.Free;
  FErrors.Free;
  FStyles.Free;
  FSysVariables.Free;
  FEnabledDataSets.Free;
  FTimer.Free;
  TObject(FDrawText).Free;
  FDrillState.Free;

  if FParentForm <> nil then
    FParentForm.Free;
end;

class function TfrxReport.GetDescription: String;
begin
  Result := frxResources.Get('obReport');
end;

procedure TfrxReport.DoClear;
begin
  inherited Clear;
  FDataSets.Clear;
  FVariables.Clear;
  FEngineOptions.Clear;
  FPreviewOptions.Clear;
  FPrintOptions.Clear;
  FReportOptions.Clear;
  FStyles.Clear;
  FDataSet := nil;
  FDataSetName := '';
  FDotMatrixReport := False;
  ParentReport := '';

  FScriptLanguage := 'PascalScript';
  with FScriptText do
  begin
    Clear;
    Add('begin');
    Add('');
    Add('end.');
  end;

  with FSysVariables do
  begin
    Clear;
    Add('Date');
    Add('Time');
    Add('Page');
    Add('Page#');
    Add('TotalPages');
    Add('TotalPages#');
    Add('Line');
    Add('Line#');
    Add('CopyName#');
  end;

  FOnRunDialogs := '';
  FOnStartReport := '';
  FOnStopReport := '';
end;

procedure TfrxReport.Clear;
begin

//  if FEngineOptions.ReportThread <> nil then
//    THackThread(FEngineOptions.ReportThread).Synchronize(DoClear) else

    DoClear;
end;

procedure TfrxReport.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if Operation = opRemove then
    if AComponent is TfrxDataSet then
    begin
      if FDataSets.Find(TfrxDataSet(AComponent)) <> nil then
        FDataSets.Find(TfrxDataSet(AComponent)).Free;
      if FDataset = AComponent then
        FDataset := nil;
      if Designer <> nil then
        Designer.UpdateDataTree;
    end
    else if AComponent is TfrxCustomPreview then
      if FPreview = AComponent then
        FPreview := nil;
end;

procedure TfrxReport.AncestorNotFound(Reader: TReader; const ComponentName: string;
  ComponentClass: TPersistentClass; var Component: TComponent);
begin
  Component := FindObject(ComponentName);
end;

procedure TfrxReport.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineProperty('Datasets', ReadDatasets, WriteDatasets, True);
  Filer.DefineProperty('Variables', ReadVariables, WriteVariables, True);
  Filer.DefineProperty('Style', ReadStyle, WriteStyle, True);
  if Filer is TReader then
    TReader(Filer).OnAncestorNotFound := AncestorNotFound;
end;

procedure TfrxReport.ReadDatasets(Reader: TReader);
begin
  frxReadCollection(FDatasets, Reader, Self);
end;

procedure TfrxReport.ReadStyle(Reader: TReader);
begin
  frxReadCollection(FStyles, Reader, Self);
end;

procedure TfrxReport.ReadVariables(Reader: TReader);
begin
  frxReadCollection(FVariables, Reader, Self);
end;

procedure TfrxReport.WriteDatasets(Writer: TWriter);
begin
  frxWriteCollection(FDatasets, Writer, Self);
end;

procedure TfrxReport.WriteStyle(Writer: TWriter);
begin
  frxWriteCollection(FStyles, Writer, Self);
end;

procedure TfrxReport.WriteVariables(Writer: TWriter);
begin
  frxWriteCollection(FVariables, Writer, Self);
end;

function TfrxReport.GetPages(Index: Integer): TfrxPage;
begin
  Result := TfrxPage(Objects[Index]);
end;

function TfrxReport.GetPagesCount: Integer;
begin
  Result := Objects.Count;
end;

procedure TfrxReport.SetScriptText(const Value: TStrings);
begin
  FScriptText.Assign(Value);
end;

procedure TfrxReport.SetEngineOptions(const Value: TfrxEngineOptions);
begin
  FEngineOptions.Assign(Value);
end;

procedure TfrxReport.SetParentReport(const Value: String);
var
  i: Integer;
  list: TList;
  c: TfrxComponent;
  fName, SaveFileName: String;
begin
  FParentReport := Value;
  if FParentReportObject <> nil then
  begin
    FParentReportObject.Free;
    FParentReportObject := nil;
  end;
  if Value = '' then
  begin
    list := AllObjects;
    for i := 0 to list.Count - 1 do
    begin
      c := list[i];
      c.FAncestor := False;
    end;

    FAncestor := False;
    Exit;
  end;

  SaveFileName := FFileName;
  if Assigned(FOnLoadTemplate) then
    FOnLoadTemplate(Self, Value)
  else
  begin
    fName := Value;
    { check relative path }
    if (Length(fName) > 1) and (fName[2] <> ':') then
      fName := ExtractFilePath(Application.ExeName) + Value;
    LoadFromFile(fName);
  end;

  FFileName := SaveFileName;
  FParentReportObject := TfrxReport.Create(nil);
  FParentReportObject.AssignAll(Self);

  { set ancestor flag for parent objects }
  list := AllObjects;
  for i := 0 to list.Count - 1 do
  begin
    c := list[i];
    c.FAncestor := True;
  end;

  FAncestor := True;
  FParentReport := Value;
end;

function TfrxReport.InheritFromTemplate(const templName: String): Boolean;
var
  tempReport: TfrxReport;
  i: Integer;
  l: TList;
  c: TfrxComponent;
  found, DeleteDuplicates: Boolean;

  procedure EnumObjects(ToParent, FromParent: TfrxComponent);
  var
    xs: TfrxXMLSerializer;
    s: String;
    i: Integer;
    cFrom, cTo: TfrxComponent;
  begin
    xs := TfrxXMLSerializer.Create(nil);
    { don't serialize ParentReport property! }
    xs.SerializeDefaultValues := not (ToParent is TfrxReport);
    s := xs.ObjToXML(FromParent);
    xs.XMLToObj(s, ToParent);
    xs.Free;

    for i := 0 to FromParent.Objects.Count - 1 do
    begin
      cFrom := FromParent.Objects[i];
      cTo := ToParent.Report.FindObject(cFrom.Name);

      if (cTo <> nil) and not (cTo is TfrxPage) then
      begin
        { skip duplicate object }
        if DeleteDuplicates then continue;
        { set empty name for duplicate object, rename later }
        cFrom.Name := '';
        cTo := nil;
      end;

      if cTo = nil then
      begin
        cTo := TfrxComponent(cFrom.NewInstance);
        cTo.Create(ToParent);
        cTo.Name := cFrom.Name;
      end;

      EnumObjects(cTo, cFrom);
    end;
  end;

begin
  Result := True;
  tempReport := TfrxReport.Create(nil);
  tempReport.AssignAll(Self);

  { load the template }
  ParentReport := ExtractRelativePath(ExtractFilePath(Application.ExeName), templName);

  { find duplicate objects }
  found := False;
  l := tempReport.AllObjects;
  for i := 0 to l.Count - 1 do
  begin
    c := l[i];
    if not (c is TfrxPage) and (FindObject(c.Name) <> nil) then
    begin
      found := True;
      break;
    end;
  end;

  deleteDuplicates := False;
  if found then
  begin
    with TfrxInheritErrorForm.Create(nil) do
    begin
      Result := ShowModal = mrOk;
      if Result then
        deleteDuplicates := DeleteRB.Checked;
      Free;
    end;
  end;

  if Result then
  begin
    EnumObjects(Self, tempReport);
    { create unique names for duplicates }
    l := AllObjects;
    for i := 0 to l.Count - 1 do
    begin
      c := l[i];
      if not (c is TfrxPage) and (c.Name = '') then
        c.CreateUniqueName;
    end;

  end
  else
    AssignAll(tempReport);

  tempReport.Free;
end;

procedure TfrxReport.SetPreviewOptions(const Value: TfrxPreviewOptions);
begin
  FPreviewOptions.Assign(Value);
end;

procedure TfrxReport.SetPrintOptions(const Value: TfrxPrintOptions);
begin
  FPrintOptions.Assign(Value);
end;

procedure TfrxReport.SetReportOptions(const Value: TfrxReportOptions);
begin
  FReportOptions.Assign(Value);
end;

procedure TfrxReport.SetStyles(const Value: TfrxStyles);
begin
  if Value <> nil then
  begin
    FStyles.Assign(Value);
    FStyles.Apply;
  end
  else
    FStyles.Clear;
end;

procedure TfrxReport.SetDataSet(const Value: TfrxDataSet);
begin
  FDataSet := Value;
  if FDataSet = nil then
    FDataSetName := '' else
    FDataSetName := FDataSet.UserName;
end;

procedure TfrxReport.SetDataSetName(const Value: String);
begin
  FDataSetName := Value;
  FDataSet := frxFindDataSet(FDataSet, FDataSetName, Report);
end;

function TfrxReport.GetDataSetName: String;
begin
  if FDataSet = nil then
    Result := FDataSetName else
    Result := FDataSet.UserName;
end;

function TfrxReport.Calc(const Expr: String; AScript: TfsScript = nil): Variant;
var
  ErrorMsg: String;
begin
  if AScript = nil then
    AScript := FScript;
  if not DoGetValue(Expr, Result) then
  begin
    Result := FExpressionCache.Calc(Expr, ErrorMsg, AScript);
    if ErrorMsg <> '' then
    begin
      if FCurObject <> '' then
        ErrorMsg := FCurObject + ': ' + ErrorMsg;
      FErrors.Add(ErrorMsg);
      raise Exception.Create(ErrorMsg);
    end;
  end;
end;

function TfrxReport.GetAlias(DataSet: TfrxDataSet): String;
var
  ds: TfrxDataSetItem;
begin
  if DataSet = nil then
  begin
    Result := '';
    Exit;
  end;

  ds := DataSets.Find(DataSet);
  if ds <> nil then
    Result := ds.DataSet.UserName else
    Result := frxResources.Get('clDSNotIncl');
end;

function TfrxReport.GetDataset(const Alias: String): TfrxDataset;
var
  ds: TfrxDataSetItem;
begin
  ds := DataSets.Find(Alias);
  if ds <> nil then
    Result := ds.DataSet else
    Result := nil;
end;

procedure TfrxReport.GetDatasetAndField(const ComplexName: String;
  var DataSet: TfrxDataSet; var Field: String);
var
  i: Integer;
  s: String;
begin
  DataSet := nil;
  Field := '';

  { ComplexName has format: dataset name."field name"
    Spaces are allowed in both parts of the complex name }
  i := Pos('."', ComplexName);
  if i <> 0 then
  begin
    s := Copy(ComplexName, 1, i - 1); { dataset name }
    DataSet := GetDataSet(s);
    Field := Copy(ComplexName, i + 2, Length(ComplexName) - i - 2);
  end;
end;

procedure TfrxReport.GetDataSetList(List: TStrings; OnlyDB: Boolean = False);
var
  i: Integer;
begin
  List.Clear;
  for i := 0 to DataSets.Count - 1 do
    if Datasets[i].DataSet <> nil then
      if not OnlyDB or not (DataSets[i].DataSet is TfrxUserDataSet) then
        List.AddObject(DataSets[i].DataSet.UserName, DataSets[i].DataSet);
end;

procedure TfrxReport.DoLoadFromStream;
var
  SaveLeftTop: Longint;
  Loaded: Boolean;
begin
  SaveLeftTop := DesignInfo;
  Loaded := False;

  if Assigned(frxFR2Events.OnLoad) then
    Loaded := frxFR2Events.OnLoad(Self, FLoadStream);

  if not Loaded then
    inherited LoadFromStream(FLoadStream);

  DesignInfo := SaveLeftTop;
end;

procedure TfrxReport.LoadFromStream(Stream: TStream);
var
  Compressor: TfrxCustomCompressor;
  Crypter: TfrxCustomCrypter;
  SaveEngineOptions: TfrxEngineOptions;
  SavePreviewOptions: TfrxPreviewOptions;
  SaveConvertNulls: Boolean;
  SaveDoublePass: Boolean;
  SaveOutlineVisible, SaveOutlineExpand: Boolean;
  SaveOutlineWidth: Integer;
  SaveIni: String;
  SavePreview: TfrxCustomPreview;
  SaveOldStyleProgress, SaveShowProgress, SaveStoreInDFM: Boolean;
  Crypted: Boolean;

  function DecodePwd(const s: String): String;
  var
    i: Integer;
  begin
    Result := '';
    for i := 1 to Length(s) do
      Result := Result + Chr(Ord(s[i]) + 10);
  end;

  procedure ConvertOldDatasets;
  var
    i, x: Integer;
    l: TList;
    hasDataPage, hasDataObjects: Boolean;
    p: TfrxDataPage;
    c: TfrxComponent;
  begin
    { check if report has datapage and datacomponents }
    hasDataPage := False;
    hasDataObjects := False;
    l := AllObjects;
    for i := 0 to l.Count - 1 do
    begin
      c := l[i];
      if c is TfrxDataPage then
        hasDataPage := True;
      if c is TfrxDialogComponent then
        hasDataObjects := True;
    end;

    if not hasDataPage then
    begin
      { create the datapage }
      p := TfrxDataPage.Create(Self);
      if FindObject('Data') = nil then
        p.Name := 'Data'
      else
        p.CreateUniqueName;

      { make it the first page }
      Objects.Delete(Objects.Count - 1);
      Objects.Insert(0, p);

      { move existing datacomponents to this page }
      if hasDataObjects then
      begin
        x := 60;
        for i := 0 to l.Count - 1 do
        begin
          c := l[i];
          if c is TfrxDialogComponent then
          begin
            c.Parent := p;
            c.Left := x;
            c.Top := 20;
            Inc(x, 64);
          end;
        end;
      end;
    end;
  end;

begin
  FErrors.Clear;

  Compressor := nil;
  if frxCompressorClass <> nil then
  begin
    Compressor := TfrxCustomCompressor(frxCompressorClass.NewInstance);
    Compressor.Create(nil);
    Compressor.Report := Self;
    Compressor.IsFR3File := True;
    try
      Compressor.CreateStream;
      if Compressor.Decompress(Stream) then
        Stream := Compressor.Stream;
    except
      Compressor.Free;
      FErrors.Add(frxResources.Get('clDecompressError'));
      frxCommonErrorHandler(Self, frxResources.Get('clErrors') + #13#10 + FErrors.Text);
      Exit;
    end;
  end;

  Crypter := nil;
  Crypted := False;
  if frxCrypterClass <> nil then
  begin
    Crypter := TfrxCustomCrypter(frxCrypterClass.NewInstance);
    Crypter.Create(nil);
    try
      Crypter.CreateStream;
      Crypted := Crypter.Decrypt(Stream, ReportOptions.Password);
      if Crypted then
        Stream := Crypter.Stream;
    except
      Crypter.Free;
      FErrors.Add(frxResources.Get('clDecryptError'));
      frxCommonErrorHandler(Self, frxResources.Get('clErrors') + #13#10 + FErrors.Text);
      Exit;
    end;
  end;

  SaveEngineOptions := TfrxEngineOptions.Create;
  SaveEngineOptions.Assign(FEngineOptions);
  SavePreviewOptions := TfrxPreviewOptions.Create;
  SavePreviewOptions.Assign(FPreviewOptions);
  SaveIni := FIniFile;
  SavePreview := FPreview;
  SaveOldStyleProgress := FOldStyleProgress;
  SaveShowProgress := FShowProgress;
  SaveStoreInDFM := FStoreInDFM;

  try
    FLoadStream := Stream;

//    if FEngineOptions.ReportThread <> nil then
//      THackThread(FEngineOptions.ReportThread).Synchronize(DoLoadFromStream) else

    try
      DoLoadFromStream;
    except
      on E: Exception do
      begin
        if (E is TfrxInvalidXMLException) and Crypted then
          FErrors.Add('Invalid password');
      end;
    end;
  finally
    if Compressor <> nil then
      Compressor.Free;
    if Crypter <> nil then
      Crypter.Free;

    ConvertOldDatasets;

    SaveConvertNulls := FEngineOptions.ConvertNulls;
    SaveDoublePass := FEngineOptions.DoublePass;
    FEngineOptions.Assign(SaveEngineOptions);
    FEngineOptions.ConvertNulls := SaveConvertNulls;
    FEngineOptions.DoublePass := SaveDoublePass;
    SaveEngineOptions.Free;

    SaveOutlineVisible := FPreviewOptions.OutlineVisible;
    SaveOutlineWidth := FPreviewOptions.OutlineWidth;
    SaveOutlineExpand := FPreviewOptions.OutlineExpand;
    FPreviewOptions.Assign(SavePreviewOptions);
    FPreviewOptions.OutlineVisible := SaveOutlineVisible;
    FPreviewOptions.OutlineWidth := SaveOutlineWidth;
    FPreviewOptions.OutlineExpand := SaveOutlineExpand;
    SavePreviewOptions.Free;

    FIniFile := SaveIni;
    FPreview := SavePreview;
    FOldStyleProgress := SaveOldStyleProgress;
    FShowProgress := SaveShowProgress;
    FStoreInDFM := SaveStoreInDFM;
    if not Crypted then
      ReportOptions.Password := DecodePwd(ReportOptions.Password);

    if ReportOptions.Info or ((not FReloading) and

       (not FEngineOptions.EnableThreadSafe) and

       (not Crypted and not FReportOptions.CheckPassword)) then

      Clear
    else if (FErrors.Count > 0) then
      frxCommonErrorHandler(Self, frxResources.Get('clErrors') + #13#10 + FErrors.Text);
  end;
end;

procedure TfrxReport.SaveToStream(Stream: TStream; SaveChildren: Boolean = True;
  SaveDefaultValues: Boolean = False);
var
  Compressor: TfrxCustomCompressor;
  Crypter: TfrxCustomCrypter;
  StreamTo: TStream;
  SavePwd: String;
  SavePreview: TfrxCustomPreview;

  function EncodePwd(const s: String): String;
  var
    i: Integer;
  begin
    Result := '';
    for i := 1 to Length(s) do
      Result := Result + Chr(Ord(s[i]) - 10);
  end;

begin
  StreamTo := Stream;

  Compressor := nil;
  if FReportOptions.Compressed and (frxCompressorClass <> nil) then
  begin
    Compressor := TfrxCustomCompressor(frxCompressorClass.NewInstance);
    Compressor.Create(nil);
    Compressor.Report := Self;
    Compressor.IsFR3File := True;
    Compressor.CreateStream;
    StreamTo := Compressor.Stream;
  end;

  Crypter := nil;
  if (FReportOptions.Password <> '') and (frxCrypterClass <> nil) then
  begin
    Crypter := TfrxCustomCrypter(frxCrypterClass.NewInstance);
    Crypter.Create(nil);
    Crypter.CreateStream;
    StreamTo := Crypter.Stream;
  end;

  SavePwd := ReportOptions.Password;
  ReportOptions.PrevPassword := SavePwd;
  if Crypter = nil then
    ReportOptions.Password := EncodePwd(SavePwd);
  SavePreview := FPreview;
  FPreview := nil;

  try
    inherited SaveToStream(StreamTo, SaveChildren, SaveDefaultValues);
  finally
    FPreview := SavePreview;
    ReportOptions.Password := SavePwd;
    { crypt }
    if Crypter <> nil then
    begin
      try
        if Compressor <> nil then
          Crypter.Crypt(Compressor.Stream, ReportOptions.Password)
        else
          Crypter.Crypt(Stream, ReportOptions.Password);
      finally
        Crypter.Free;
      end;
    end;
    { compress }
    if Compressor <> nil then
    begin
      try
        Compressor.Compress(Stream);
      finally
        Compressor.Free;
      end;
    end;
  end;
end;

function TfrxReport.LoadFromFile(const FileName: String;
  ExceptionIfNotFound: Boolean = False): Boolean;
var
  f: TFileStream;
begin
  Clear;
  FFileName := '';
  Result := FileExists(FileName);
  if Result or ExceptionIfNotFound then
  begin
    f := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    try
      LoadFromStream(f);
      FFileName := FileName;
    finally
      f.Free;
    end;
  end;
end;

procedure TfrxReport.SaveToFile(const FileName: String);
var
  f: TFileStream;
begin
  f := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(f);
  finally
    f.Free;
  end;
end;

function TfrxReport.GetIniFile: TCustomIniFile;
begin
  if Pos('\Software\', FIniFile) = 1 then
    Result := TRegistryIniFile.Create(FIniFile) else
    Result := TIniFile.Create(FIniFile);
end;

procedure TfrxReport.SelectPrinter;
begin
  if frxPrinters.IndexOf(FPrintOptions.Printer) <> -1 then
    frxPrinters.PrinterIndex := frxPrinters.IndexOf(FPrintOptions.Printer);
end;

procedure TfrxReport.DoNotifyEvent(Obj: TObject; const EventName: String;
  RunAlways: Boolean = False);
begin
{$IFNDEF FR_VER_BASIC}
  if FEngine.Running or RunAlways then
    if EventName <> '' then
      FScript.CallFunction(EventName, VarArrayOf([Integer(Obj)]));
{$ENDIF}
end;

procedure TfrxReport.DoParamEvent(const EventName: String; var Params: Variant;
  RunAlways: Boolean = False);
begin
{$IFNDEF FR_VER_BASIC}
  if FEngine.Running or RunAlways then
    if EventName <> '' then
      FScript.CallFunction1(EventName, Params);
{$ENDIF}
end;

procedure TfrxReport.DoBeforePrint(c: TfrxReportComponent);
begin
  if Assigned(FOnBeforePrint) then
    FOnBeforePrint(c);
  DoNotifyEvent(c, c.OnBeforePrint);
end;

procedure TfrxReport.DoAfterPrint(c: TfrxReportComponent);
begin
  if Assigned(FOnAfterPrint) then
    FOnAfterPrint(c);
  DoNotifyEvent(c, c.OnAfterPrint);
end;

procedure TfrxReport.DoPreviewClick(v: TfrxView; Button: TMouseButton;
  Shift: TShiftState; var Modified: Boolean);
var
  arr: Variant;
begin
  arr := VarArrayOf([Integer(v), Button, ShiftToByte(Shift), Modified]);
  DoParamEvent(v.OnPreviewClick, arr, True);
  Modified := arr[3];
  if Assigned(FOnClickObject) then
    FOnClickObject(v, Button, Shift, Modified);
end;

procedure TfrxReport.DoGetAncestor(const Name: String; var Ancestor: TPersistent);
begin
  if FParentReportObject <> nil then
  begin
    if Name = Self.Name then
      Ancestor := FParentReportObject
    else
      Ancestor := FParentReportObject.FindObject(Name);
  end;
end;

function TfrxReport.DoGetValue(const Expr: String; var Value: Variant): Boolean;
var
  i: Integer;
  ds: TfrxDataSet;
  fld: String;
  val: Variant;
  v: TfsCustomVariable;
begin
  Result := False;
  Value := Null;

  if Assigned(frxFR2Events.OnGetValue) then
  begin
    TVarData(val).VType := varEmpty;
    frxFR2Events.OnGetValue(Expr, val);
    if TVarData(val).VType <> varEmpty then
    begin
      Value := val;
      Result := True;
      Exit;
    end;
  end;

  { maybe it's a dataset/field? }
  GetDataSetAndField(Expr, ds, fld);
  if (ds <> nil) and (fld <> '') then
  begin
    Value := ds.Value[fld];
    if FEngineOptions.ConvertNulls and (Value = Null) then
      case ds.FieldType[fld] of
        fftNumeric:
          Value := 0;
        fftString:
          Value := '';
        fftBoolean:
          Value := False;
      end;
    Result := True;
    Exit;
  end;

  { searching in the sys variables }
  i := FSysVariables.IndexOf(Expr);
  if i <> -1 then
  begin
    case i of
      0: Value := FEngine.StartDate;  { Date }
      1: Value := FEngine.StartTime;  { Time }
      2: Value := FPreviewPages.GetLogicalPageNo; { Page }
      3: Value := FPreviewPages.CurPage + 1;  { Page# }
      4: Value := FPreviewPages.GetLogicalTotalPages;  { TotalPages }
      5: Value := FEngine.TotalPages;  { TotalPages# }
      6: Value := FEngine.CurLine;  { Line }
      7: Value := FEngine.CurLineThrough; { Line# }
      8: Value := frxGlobalVariables['CopyName0'];
    end;
    Result := True;
    Exit;
  end;

  { value supplied by OnGetValue event }
  TVarData(val).VType := varEmpty;
  if Assigned(FOnGetValue) then
    FOnGetValue(Expr, val);
  if TVarData(val).VType <> varEmpty then
  begin
    Value := val;
    Result := True;
    Exit;
  end;

  { searching in the variables }
  i := FVariables.IndexOf(Expr);
  if i <> -1 then
  begin
    val := FVariables.Items[i].Value;
    if (TVarData(val).VType = varString) or (TVarData(val).VType = varOleStr) then
    begin
      if Pos(#13#10, val) <> 0 then
        Value := val
      else
        Value := Calc(val);
    end
    else
      Value := val;
    Result := True;
    Exit;
  end;

  { searching in the global variables }
  i := frxGlobalVariables.IndexOf(Expr);
  if i <> -1 then
  begin
    Value := frxGlobalVariables.Items[i].Value;
    Result := True;
    Exit;
  end;

  if not Assigned(frxFR2Events.OnGetScriptValue) then
  begin
    { searching in the script }
    v := FScript.FindLocal(Expr);
    if v <> nil then
    begin
      Value := v.Value;
      Result := True;
      Exit;
    end;
  end;
end;

function TfrxReport.GetScriptValue(Instance: TObject; ClassType: TClass;
  const MethodName: String; var Params: Variant): Variant;
var
  i: Integer;
  s: String;
begin
  if not DoGetValue(Params[0], Result) then
  begin
    { checking aggregate functions }
    s := VarToStr(Params[0]);
    i := Pos('(', s);
    if i <> 0 then
    begin
      s := UpperCase(Trim(Copy(s, 1, i - 1)));
      if (s = 'SUM') or (s = 'MIN') or (s = 'MAX') or
         (s = 'AVG') or (s = 'COUNT') then
      begin
        Result := Calc(Params[0]);
        Exit;
      end;
    end;

    if Assigned(frxFR2Events.OnGetScriptValue) then
      Result := frxFR2Events.OnGetScriptValue(Params)
    else
      FErrors.Add(frxResources.Get('clUnknownVar') + ' ' + VarToStr(Params[0]));
  end;
end;

function TfrxReport.SetScriptValue(Instance: TObject; ClassType: TClass;
  const MethodName: String; var Params: Variant): Variant;
begin
  FVariables[Params[0]] := Params[1];
end;

function TfrxReport.CallMethod(Instance: TObject; ClassType: TClass;
  const MethodName: String; var Params: Variant): Variant;
var
  p1, p2, p3: Variant;
begin
  if MethodName = 'IIF' then
  begin
    p1 := Params[0];
    p2 := Params[1];
    p3 := Params[2];
    if Calc(p1, FScript.ProgRunning) = True then
      Result := Calc(p2, FScript.ProgRunning) else
      Result := Calc(p3, FScript.ProgRunning);
  end
  else if (MethodName = 'SUM') or (MethodName = 'AVG') or
    (MethodName = 'MIN') or (MethodName = 'MAX') then
  begin
    p2 := Params[1];
    if Trim(VarToStr(p2)) = '' then
      p2 := 0
    else
      p2 := Calc(p2, FScript.ProgRunning);
    p3 := Params[2];
    if Trim(VarToStr(p3)) = '' then
      p3 := 0
    else
      p3 := Calc(p3, FScript.ProgRunning);
    Result := FEngine.GetAggregateValue(MethodName, Params[0],
      TfrxBand(Integer(p2)), p3);
  end
  else if MethodName = 'COUNT' then
  begin
    p1 := Params[0];
    if Trim(VarToStr(p1)) = '' then
      p1 := 0
    else
      p1 := Calc(p1, FScript.ProgRunning);
    p2 := Params[1];
    if Trim(VarToStr(p2)) = '' then
      p2 := 0
    else
      p2 := Calc(p2, FScript.ProgRunning);
    Result := FEngine.GetAggregateValue(MethodName, '',
      TfrxBand(Integer(p1)), p2);
  end
end;

function TfrxReport.DoUserFunction(Instance: TObject; ClassType: TClass;
  const MethodName: String; var Params: Variant): Variant;
begin
  if Assigned(FOnUserFunction) then
    Result := FOnUserFunction(MethodName, Params);
end;

function TfrxReport.PrepareScript: Boolean;
var
  i: Integer;
  l: TList;
  c: TfrxComponent;
begin
  FExpressionCache.Clear;
  FExpressionCache.FScriptLanguage := FScriptLanguage;
  FEngine.NotifyList.Clear;

  FScript.ClearItems(Self);
  FScript.AddedBy := Self;
  FScript.MainProg := True;

  try
    l := AllObjects;
    for i := 0 to l.Count - 1 do
    begin
      c := l[i];
      c.IsDesigning := False;
      c.BeforeStartReport;
      if c is TfrxPictureView then
        TfrxPictureView(c).FPictureChanged := True;
      FScript.AddObject(c.Name, c);
    end;

    FScript.AddObject('Report', Self);
    FScript.AddObject('Engine', FEngine);
    FScript.AddObject('Outline', FPreviewPages.Outline);
    FScript.AddVariable('Value', 'Variant', Null);
    FScript.AddMethod('function Get(Name: String): Variant', GetScriptValue);
    FScript.AddMethod('procedure Set(Name: String; Value: Variant)', SetScriptValue);
    FScript.AddMethod('macrofunction IIF(Expr: Boolean; TrueValue, FalseValue: Variant): Variant',
      CallMethod);
    FScript.AddMethod('macrofunction SUM(Expr: Variant; Band: Variant = 0; Flags: Integer = 0): Variant',
      CallMethod);
    FScript.AddMethod('macrofunction AVG(Expr: Variant; Band: Variant = 0; Flags: Integer = 0): Variant',
      CallMethod);
    FScript.AddMethod('macrofunction MIN(Expr: Variant; Band: Variant = 0; Flags: Integer = 0): Variant',
      CallMethod);
    FScript.AddMethod('macrofunction MAX(Expr: Variant; Band: Variant = 0; Flags: Integer = 0): Variant',
      CallMethod);
    FScript.AddMethod('macrofunction COUNT(Band: Variant = 0; Flags: Integer = 0): Variant',
      CallMethod);

    if Assigned(frxFR2Events.OnPrepareScript) then
      frxFR2Events.OnPrepareScript(Self);
    FLocalValue := FScript.Find('Value');
    FScript.Lines := FScriptText;
    FScript.SyntaxType := FScriptLanguage;

  {$IFNDEF FR_VER_BASIC}
    Result := FScript.Compile;
    if not Result then
      FErrors.Add(Format(frxResources.Get('clScrError'),
        [FScript.ErrorPos, FScript.ErrorMsg]));
  {$ELSE}
    Result := True;
  {$ENDIF}
  finally
    FScript.AddedBy := nil;
  end;
end;

 // FR_COM

function TfrxReport.PrepareReport(ClearLastReport: Boolean = True): Boolean;
var
  TempStream: TStream;
  ErrorsText: String;
  ErrorMessage: String;
  SavePwd: String;

  function CheckDatasets: Boolean;
  var
    i: Integer;
  begin
    for i := 0 to FDataSets.Count - 1 do
      if FDatasets[i].DataSet = nil then
        FErrors.Add(Format(frxResources.Get('clDSNotExist'), ['']));
    Result := FErrors.Count = 0;
  end;

begin
  if ClearLastReport then
    PreviewPages.Clear;
  FErrors.Clear;
  FTerminated := False;
  Result := False;

  if CheckDatasets then
  begin
    TempStream := nil;
    SavePwd := ReportOptions.Password;

    { save the report state }
    if FEngineOptions.DestroyForms then
    begin
      TempStream := TMemoryStream.Create;
      ReportOptions.Password := '';
      SaveToStream(TempStream);
    end;

    try
      if Assigned(FOnBeginDoc) then
        FOnBeginDoc(Self);
      if PrepareScript then
      begin
{$IFNDEF FR_VER_BASIC}
        if FScript.Statement.Count > 0 then
          FScript.Execute;
{$ENDIF}
        if FEngine.Run then
        begin
          if Assigned(FOnEndDoc) then
            FOnEndDoc(Self);
          Result := True
        end
        else if FPreviewForm <> nil then
          FPreviewForm.Close;
      end;
    except
      on e: Exception do
        FErrors.Add(e.Message);
    end;

    if FEngineOptions.DestroyForms then
    begin
      ErrorsText := FErrors.Text;
      TempStream.Position := 0;
      FReloading := True;
      try
//        if FEngineOptions.ReportThread = nil then
          LoadFromStream(TempStream);
      finally
        FReloading := False;
        ReportOptions.Password := SavePwd;
      end;
      TempStream.Free;
      FErrors.Text := ErrorsText;
    end;
  end;

  if FErrors.Text <> '' then
  begin
    Result := False;
    ErrorMessage := frxResources.Get('clErrors') + #13#10 + FErrors.Text;
    frxCommonErrorHandler(Self, ErrorMessage);
  end;
end;

  // FR_COM


procedure TfrxReport.ShowPreparedReport;

begin
  FPreviewForm := nil;
  if FPreview <> nil then
  begin
    FPreview.FReport := Self;
    FPreview.FPreviewPages := FPreviewPages;
    FPreview.Init;
  end
  else
  begin
    FPreviewForm := TfrxPreviewForm.Create(Application);
    with TfrxPreviewForm(FPreviewForm) do
    begin
      Preview.FReport := Self;
      Preview.FPreviewPages := FPreviewPages;
      FPreview := Preview;
      Init;
      if Assigned(FOnPreview) then
        FOnPreview(Self);
      if PreviewOptions.Maximized then
        Position := poDesigned;
      if FPreviewOptions.Modal then
      begin
        ShowModal;
        Free;
      end
      else
      begin
        FreeOnClose := True;
        Show;
      end;
    end;
  end;

end;


procedure TfrxReport.ShowReport(ClearLastReport: Boolean = True);

begin
  if ClearLastReport then
    PreviewPages.Clear;

  if FOldStyleProgress then
  begin

    if PrepareReport(False) then
      ShowPreparedReport;

  end
  else
  begin
    FTimer.Enabled := True;

    ShowPreparedReport;

  end;
end;

procedure TfrxReport.OnTimer(Sender: TObject);
begin
  FTimer.Enabled := False;
  PrepareReport(False);
end;

{$HINTS OFF}

{$UNDEF FR_RUN_DESIGNER}

{$IFDEF FR_LITE}
  {$DEFINE FR_RUN_DESIGNER}
{$ENDIF}

{$IFNDEF FR_VER_BASIC}
  {$DEFINE FR_RUN_DESIGNER}
{$ENDIF}


procedure TfrxReport.DesignReport(Modal: Boolean = True; MDIChild: Boolean = False);

var
  l: TList;
  i: Integer;
  c: TfrxComponent;
begin

{$IFDEF FR_RUN_DESIGNER}
  if FDesigner <> nil then Exit;
  if frxDesignerClass <> nil then
  begin
    FScript.ClearItems(Self);
    l := AllObjects;
    for i := 0 to l.Count - 1 do
    begin
      c := l[i];
      if c is TfrxCustomDBDataset then
        c.BeforeStartReport;
    end;

    FModified := False;
    FDesigner := TfrxCustomDesigner(frxDesignerClass.NewInstance);
    FDesigner.CreateDesigner(nil, Self);
    if MDIChild then
      FDesigner.FormStyle := fsMDIChild;
    PostMessage(FDesigner.Handle, WM_USER + 1, 0, 0);
    if Modal then
      FDesigner.ShowModal
    else
      FDesigner.Show;
  end
  
  ;
  
{$ENDIF}
end;
{$HINTS ON}

procedure TfrxReport.DesignReport(IDesigner: IUnknown; Editor: TObject);
var
  l: TList;
  i: Integer;
  c: TfrxComponent;
begin
  if FDesigner <> nil then
  begin
    FDesigner.Activate;
    Exit;
  end;
  if (IDesigner = nil) or (Editor.ClassName <> 'TfrxReportEditor') then Exit;

  l := AllObjects;
  for i := 0 to l.Count - 1 do
  begin
    c := l[i];
    if c is TfrxCustomDBDataset then
      c.BeforeStartReport;
  end;

  FDesigner := TfrxCustomDesigner(frxDesignerClass.NewInstance);
  FDesigner.CreateDesigner(nil, Self);
  FDesigner.ShowModal;
end;

{$HINTS OFF}
function TfrxReport.DesignPreviewPage: Boolean;
begin
  Result := False;
{$IFNDEF FR_VER_BASIC}
  if FDesigner <> nil then Exit;
  if frxDesignerClass <> nil then
  begin
    FDesigner := TfrxCustomDesigner(frxDesignerClass.NewInstance);
    FDesigner.CreateDesigner(nil, Self, True);
    FDesigner.ShowModal;
    Result := FModified;
  end;
{$ENDIF}
end;
{$HINTS ON}

function TfrxReport.Export(Filter: TfrxCustomExportFilter): Boolean;
begin
  Result := FPreviewPages.Export(Filter);
end;

function TfrxReport.Print: Boolean;
begin
  Result := FPreviewPages.Print;
end;


procedure TfrxReport.AddFunction(const FuncName: String;
  const Category: String = ''; const Description: String = '');

begin
  FScript.AddedBy := nil;
  FScript.AddMethod(FuncName, DoUserFunction, Category, Description);

end;

function TfrxReport.GetLocalValue: Variant;
begin
  Result := FLocalValue.Value;
end;

procedure TfrxReport.SetLocalValue(const Value: Variant);
begin
  FLocalValue.Value := Value;
end;

procedure TfrxReport.SetTerminated(const Value: Boolean);
begin
  FTerminated := Value;
  if Value then
    FScript.Terminate;
end;

procedure TfrxReport.SetPreview(const Value: TfrxCustomPreview);
begin
  if (FPreview <> nil) and (Value = nil) then
  begin
    FPreview.FReport := nil;
    FPreview.FPreviewPages := nil;
    FPreviewForm := nil;
  end;

  FPreview := Value;

  if FPreview <> nil then
  begin
    FPreview.FReport := Self;
    FPreview.FPreviewPages := FPreviewPages;
    FPreview.Init;
  end;
end;

procedure TfrxReport.InternalOnProgressStart(ProgressType: TfrxProgressType);
begin

  if (FEngineOptions.EnableThreadSafe) then Exit; //(FEngineOptions.ReportThread <> nil) or


  if Assigned(FOnProgressStart) then
    FOnProgressStart(Self, ProgressType, 0);

  if OldStyleProgress or (ProgressType <> ptRunning) then
  begin
    if FShowProgress then
    begin
      if FProgress <> nil then
        FProgress.Free;
      FProgress := TfrxProgress.Create(nil);
      FProgress.Execute(0, '', True, False);
    end;
  end;

  if (FPreview <> nil) and (ProgressType = ptRunning) then
    FPreview.InternalOnProgressStart(Self, ProgressType, 0);
  Application.ProcessMessages;
end;

procedure TfrxReport.InternalOnProgress(ProgressType: TfrxProgressType;
  Progress: Integer);
begin

  if FEngineOptions.EnableThreadSafe then Exit;
//  if FEngineOptions.ReportThread <> nil then Exit;


  if Assigned(FOnProgress) then
    FOnProgress(Self, ProgressType, Progress);

  if OldStyleProgress or (ProgressType <> ptRunning) then
  begin
    if FShowProgress then
    begin
      case ProgressType of
        ptRunning:
          if not Engine.FinalPass then
            FProgress.Message := Format(frxResources.Get('prRunningFirst'), [Progress])
          else
            FProgress.Message := Format(frxResources.Get('prRunning'), [Progress]);
        ptPrinting:
          FProgress.Message := Format(frxResources.Get('prPrinting'), [Progress]);
        ptExporting:
          FProgress.Message := Format(frxResources.Get('prExporting'), [Progress]);
      end;
      if FProgress.Terminated then
        Terminated := True;
    end;
  end;

  if (FPreview <> nil) and (ProgressType = ptRunning) then
    FPreview.InternalOnProgress(Self, ProgressType, Progress - 1);
  Application.ProcessMessages;
end;

procedure TfrxReport.InternalOnProgressStop(ProgressType: TfrxProgressType);
begin

  if FEngineOptions.EnableThreadSafe then Exit;
//  if FEngineOptions.ReportThread <> nil then Exit;


  if Assigned(FOnProgressStop) then
    FOnProgressStop(Self, ProgressType, 0);

  if OldStyleProgress or (ProgressType <> ptRunning) then
  begin
    if FShowProgress then
    begin
      FProgress.Free;
      FProgress := nil;
    end;
  end;

  if (FPreview <> nil) and (ProgressType = ptRunning) then
    FPreview.InternalOnProgressStop(Self, ProgressType, 0);
  Application.ProcessMessages;
end;

procedure TfrxReport.SetProgressMessage(const Value: String);
begin

  if FEngineOptions.EnableThreadSafe then Exit;
//  if FEngineOptions.ReportThread <> nil then Exit;


  if OldStyleProgress and Engine.Running then
  begin
    if FShowProgress then
      FProgress.Message := Value
  end;

  if FPreviewForm <> nil then
    TfrxPreviewForm(FPreviewForm).SetMessageText(Value);
  Application.ProcessMessages;
end;

procedure TfrxReport.SetVersion(const Value: String);
begin
  FVersion := FR_VERSION;
end;



{ TfrxCustomDesigner }

constructor TfrxCustomDesigner.CreateDesigner(AOwner: TComponent;
  AReport: TfrxReport; APreviewDesigner: Boolean);
begin
  inherited Create(AOwner);
  FReport := AReport;
  FIsPreviewDesigner := APreviewDesigner;
  FObjects := TList.Create;
  FSelectedObjects := TList.Create;
end;

destructor TfrxCustomDesigner.Destroy;
begin
  FObjects.Free;
  FSelectedObjects.Free;
  inherited;
end;

procedure TfrxCustomDesigner.SetModified(const Value: Boolean);
begin
  FModified := Value;
  if Value then
    FReport.Modified := True;
end;

procedure TfrxCustomDesigner.SetPage(const Value: TfrxPage);
begin
  FPage := Value;
end;


{ TfrxCustomEngine }

constructor TfrxCustomEngine.Create(AReport: TfrxReport);
begin
  FReport := AReport;
  FNotifyList := TList.Create;
end;

destructor TfrxCustomEngine.Destroy;
begin
  FNotifyList.Free;
  inherited;
end;

function TfrxCustomEngine.GetDoublePass: Boolean;
begin
  Result := FReport.EngineOptions.DoublePass;
end;

procedure TfrxCustomEngine.ShowBandByName(const BandName: String);
begin
  ShowBand(TfrxBand(Report.FindObject(BandName)));
end;

procedure TfrxCustomEngine.StopReport;
begin
  Report.Terminated := True;
end;



{ TfrxCustomOutline }

constructor TfrxCustomOutline.Create(APreviewPages: TfrxCustomPreviewPages);
begin
  FPreviewPages := APreviewPages;
end;

function TfrxCustomOutline.Engine: TfrxCustomEngine;
begin
  Result := FPreviewPages.Engine;
end;

{ TfrxCustomPreviewPages }

constructor TfrxCustomPreviewPages.Create(AReport: TfrxReport);
begin
  FReport := AReport;
  FOutline := TfrxOutline.Create(Self);
end;

destructor TfrxCustomPreviewPages.Destroy;
begin
  FOutline.Free;
  inherited;
end;



{ TfrxExpressionCache }

constructor TfrxExpressionCache.Create(AScript: TfsScript);
begin
  FExpressions := TStringList.Create;
  FExpressions.Sorted := True;
  FScript := TfsScript.Create(nil);
  FScript.ExtendedCharset := True;
  FMainScript := AScript;
end;

destructor TfrxExpressionCache.Destroy;
begin
  FExpressions.Free;
  FScript.Free;
  inherited;
end;

procedure TfrxExpressionCache.Clear;
begin
  FExpressions.Clear;
  FScript.Clear;
end;

function TfrxExpressionCache.Calc(const Expression: String;
  var ErrorMsg: String; AScript: TfsScript): Variant;
var
  i: Integer;
  v: TfsProcVariable;
begin
  ErrorMsg := '';
  FScript.Parent := AScript;
  i := FExpressions.IndexOf(Expression);
  if i = -1 then
  begin
    i := FExpressions.Count;
    FScript.SyntaxType := FScriptLanguage;
    if CompareText(FScriptLanguage, 'PascalScript') = 0 then
      FScript.Lines.Text := 'function fr3f' + IntToStr(i) + ': Variant; begin ' +
        'Result := ' + Expression + ' end; begin end.'
    else if CompareText(FScriptLanguage, 'C++Script') = 0 then
      FScript.Lines.Text := 'Variant fr3f' + IntToStr(i) + '() { ' +
        'return ' + Expression + '; } {}'
    else if CompareText(FScriptLanguage, 'BasicScript') = 0 then
      FScript.Lines.Text := 'function fr3f' + IntToStr(i) + #13#10 +
        'return ' + Expression + #13#10 + 'end function'
    else if CompareText(FScriptLanguage, 'JScript') = 0 then
      FScript.Lines.Text := 'function fr3f' + IntToStr(i) + '() { ' +
        'return ' + Expression + '; }';

    if FScript.Compile then
      v := TfsProcVariable(FScript.Find('fr3f' + IntToStr(i)))
    else
    begin
      ErrorMsg := frxResources.Get('clExprError') + ' ''' + Expression + ''': ' +
        FScript.ErrorMsg;
      Result := Null;
      Exit;
    end;

    FExpressions.AddObject(Expression, v);
  end
  else
    v := TfsProcVariable(FExpressions.Objects[i]);

  FMainScript.MainProg := False;
  try
    try
      Result := v.Value;
    except
      on e: Exception do
        ErrorMsg := e.Message;
    end;
  finally
    FMainScript.MainProg := True;
  end;
end;


{ TfrxCustomExportFilter }

constructor TfrxCustomExportFilter.Create(AOwner: TComponent);
begin
  inherited;
  if not FNoRegister then
    frxExportFilters.Register(Self);
  FShowDialog := True;
  FUseFileCache := True;
  FDefaultPath := '';
  FShowProgress := True;
  FSlaveExport := False;
end;

constructor TfrxCustomExportFilter.CreateNoRegister;
begin
  FNoRegister := True;
  Create(nil);
end;

destructor TfrxCustomExportFilter.Destroy;
begin
  if not FNoRegister then
    frxExportFilters.Unregister(Self);
  inherited;
end;

class function TfrxCustomExportFilter.GetDescription: String;
begin
  Result := '';
end;

procedure TfrxCustomExportFilter.Finish;
begin
//
end;

procedure TfrxCustomExportFilter.FinishPage(Page: TfrxReportPage;
  Index: Integer);
begin
//
end;

function TfrxCustomExportFilter.ShowModal: TModalResult;
begin
  Result := mrOk;
end;

function TfrxCustomExportFilter.Start: Boolean;
begin
  Result := True;
end;

procedure TfrxCustomExportFilter.StartPage(Page: TfrxReportPage;
  Index: Integer);
begin
//
end;


{ TfrxCustomWizard }

constructor TfrxCustomWizard.Create(AOwner: TComponent);
begin
  inherited;
  FDesigner := TfrxCustomDesigner(AOwner);
  FReport := FDesigner.Report;
end;

class function TfrxCustomWizard.GetDescription: String;
begin
  Result := '';
end;


{ TfrxCustomCompressor }

constructor TfrxCustomCompressor.Create(AOwner: TComponent);
begin
  inherited;
  FOldCompressor := frxCompressorClass;
  frxCompressorClass := TfrxCompressorClass(ClassType);
end;

destructor TfrxCustomCompressor.Destroy;
begin
  frxCompressorClass := FOldCompressor;
  if FStream <> nil then
    FStream.Free;
  if FTempFile <> '' then
    SysUtils.DeleteFile(FTempFile);
  inherited;
end;

procedure TfrxCustomCompressor.CreateStream;
begin
  if FIsFR3File or not FReport.EngineOptions.UseFileCache then
    FStream := TMemoryStream.Create
  else
  begin
    FTempFile := frxCreateTempFile(FReport.EngineOptions.TempDir);
    FStream := TFileStream.Create(FTempFile, fmCreate);
  end;
end;




{ TfrxCustomCrypter }

constructor TfrxCustomCrypter.Create(AOwner: TComponent);
begin
  inherited;
  frxCrypterClass := TfrxCrypterClass(ClassType);
end;

destructor TfrxCustomCrypter.Destroy;
begin
  if FStream <> nil then
    FStream.Free;
  inherited;
end;

procedure TfrxCustomCrypter.CreateStream;
begin
  FStream := TMemoryStream.Create;
end;


{ TfrxGlobalDataSetList }

constructor TfrxGlobalDataSetList.Create;
begin
  FCriticalSection := TCriticalSection.Create;
  inherited;
end;

destructor TfrxGlobalDataSetList.Destroy;
begin
  FCriticalSection.Free;
  FCriticalSection := nil;
  inherited;
end;

procedure TfrxGlobalDataSetList.Lock;
begin
  if FCriticalSection <> nil then
    FCriticalSection.Enter;
end;

procedure TfrxGlobalDataSetList.Unlock;
begin
  if FCriticalSection <> nil then
    FCriticalSection.Leave;
end;


initialization
  frxCS := TCriticalSection.Create;
  DatasetList := TfrxGlobalDataSetList.Create;
  frxGlobalVariables := TfrxVariables.Create;
  { create parent form for OLE and RICH controls in the main thread }
  frxParentForm;

  Screen.Cursors[crHand] := LoadCursor(hInstance, 'frxHAND');
  Screen.Cursors[crZoom] := LoadCursor(hInstance, 'frxZOOM');
  Screen.Cursors[crFormat] := LoadCursor(hInstance, 'frxFORMAT');

  RegisterClasses([
    TfrxChild, TfrxColumnFooter, TfrxColumnHeader, TfrxCustomMemoView, TfrxMasterData,
    TfrxDetailData, TfrxSubDetailData, TfrxDataBand4, TfrxDataBand5, TfrxDataBand6,
    TfrxDialogPage, TfrxFooter, TfrxFrame, TfrxGroupFooter, TfrxGroupHeader,
    TfrxHeader, TfrxHighlight, TfrxLineView, TfrxMemoView, TfrxOverlay, TfrxPageFooter,
    TfrxPageHeader, TfrxPictureView, TfrxReport, TfrxReportPage, TfrxReportSummary,
    TfrxReportTitle, TfrxShapeView, TfrxSubreport, TfrxSysMemoView, TfrxStyleItem,
    TfrxNullBand, TfrxCustomLineView, TfrxDataPage]);

  frxResources.UpdateFSResources;
  frxFR2Events := TfrxFR2Events.Create;



finalization
  frxCS.Free;
  frxGlobalVariables.Free;

  DatasetList.Free;

  if FParentForm <> nil then
  begin
    EmptyParentForm;
    FParentForm.Free;
  end;
  FParentForm := nil;
  frxFR2Events.Free;



end.




//0f31356a91fea3356e5f76cdce90aa7b