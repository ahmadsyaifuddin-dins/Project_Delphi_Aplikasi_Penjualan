
{******************************************}
{                                          }
{             FastReport v4.0              }
{                Designer                  }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxDesgn;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ImgList, Menus, Buttons, StdCtrls, ToolWin, ExtCtrls, ActnList,
  CommCtrl, frxClass, frxDock, frxCtrls, frxDesgnCtrls, frxDesgnWorkspace,
  frxInsp, frxDialogForm, frxDataTree, frxReportTree, frxSynMemo,
  fs_iinterpreter, Printers, frxWatchForm, frxPictureCache
{$IFDEF Delphi6}
, Variants
{$ENDIF}
{$IFDEF Delphi9}
, GraphUtil, Tabs
{$ENDIF}

;



type
  TfrxDesignerUnits = (duCM, duInches, duPixels, duChars);
  TfrxLoadReportEvent = function(Report: TfrxReport): Boolean of object;
  TfrxSaveReportEvent = function(Report: TfrxReport; SaveAs: Boolean): Boolean of object;
  TfrxGetTemplateListEvent = procedure(List: TStrings) of object;
  TfrxDesignerRestriction =
    (drDontInsertObject, drDontDeletePage, drDontCreatePage, drDontChangePageOptions,
     drDontCreateReport, drDontLoadReport, drDontSaveReport,
     drDontPreviewReport, drDontEditVariables, drDontChangeReportOptions,
     drDontEditReportData, drDontShowRecentFiles);
  TfrxDesignerRestrictions = set of TfrxDesignerRestriction;
  TSampleFormat = class;


  TfrxDesigner = class(TComponent)
  private

    FCloseQuery: Boolean;
    FDefaultScriptLanguage: String;
    FDefaultFont: TFont;
    FDefaultLeftMargin: Extended;
    FDefaultBottomMargin: Extended;
    FDefaultRightMargin: Extended;
    FDefaultTopMargin: Extended;
    FDefaultPaperSize: Integer;
    FDefaultOrientation: TPrinterOrientation;
{$IFDEF Delphi10}
    FGradient: Boolean;
    FGradientEnd: TColor;
    FGradientStart: TColor;
{$ENDIF}
    FOpenDir: String;
    FSaveDir: String;
    FTemplateDir: String;
    FStandalone: Boolean;
    FRestrictions: TfrxDesignerRestrictions;
    FRTLLanguage: Boolean;
    FOnLoadReport: TfrxLoadReportEvent;
    FOnSaveReport: TfrxSaveReportEvent;
    FOnShow: TNotifyEvent;
    FOnInsertObject: TNotifyEvent;
    FOnGetTemplateList: TfrxGetTemplateListEvent;
    FOnShowStartupScreen: TNotifyEvent;
    procedure SetDefaultFont(const Value: TFont);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure GetTemplateList(List: TStrings);
  published
    property CloseQuery: Boolean read FCloseQuery write FCloseQuery default True;
    property DefaultScriptLanguage: String read FDefaultScriptLanguage write FDefaultScriptLanguage;
    property DefaultFont: TFont read FDefaultFont write SetDefaultFont;
    property DefaultLeftMargin: Extended read FDefaultLeftMargin write FDefaultLeftMargin;
    property DefaultRightMargin: Extended read FDefaultRightMargin write FDefaultRightMargin;
    property DefaultTopMargin: Extended read FDefaultTopMargin write FDefaultTopMargin;
    property DefaultBottomMargin: Extended read FDefaultBottomMargin write FDefaultBottomMargin;
    property DefaultPaperSize: Integer read FDefaultPaperSize write FDefaultPaperSize;
    property DefaultOrientation: TPrinterOrientation read FDefaultOrientation write FDefaultOrientation;
{$IFDEF Delphi10}
    property Gradient: Boolean read FGradient write FGradient default False;
    property GradientEnd: TColor read FGradientEnd write FGradientEnd;
    property GradientStart: TColor read FGradientStart write FGradientStart;
{$ENDIF}
    property OpenDir: String read FOpenDir write FOpenDir;
    property SaveDir: String read FSaveDir write FSaveDir;
    property TemplateDir: String read FTemplateDir write FTemplateDir;
    property Standalone: Boolean read FStandalone write FStandalone default False;
    property Restrictions: TfrxDesignerRestrictions read FRestrictions write FRestrictions;
    property RTLLanguage: Boolean read FRTLLanguage write FRTLLanguage;
    property OnLoadReport: TfrxLoadReportEvent read FOnLoadReport write FOnLoadReport;
    property OnSaveReport: TfrxSaveReportEvent read FOnSaveReport write FOnSaveReport;
    property OnShow: TNotifyEvent read FOnShow write FOnShow;
    property OnInsertObject: TNotifyEvent read FOnInsertObject write FOnInsertObject;
    property OnShowStartupScreen: TNotifyEvent read FOnShowStartupScreen write FOnShowStartupScreen;
    property OnGetTemplateList: TfrxGetTemplateListEvent read FOnGetTemplateList write FOnGetTemplateList;


  end;

  TfrxDesignerForm = class(TfrxCustomDesigner)
    Bevel1: TBevel;
    StatusBar: TStatusBar;
    DockBottom: TControlBar;
    DockTop: TControlBar;
    TextTB: TToolBar;
    PanelTB1: TfrxTBPanel;
    FontSizeCB: TfrxComboBox;
    FontNameCB: TfrxFontComboBox;
    BoldB: TToolButton;
    ItalicB: TToolButton;
    UnderlineB: TToolButton;
    SepTB8: TToolButton;
    FontColorB: TToolButton;
    HighlightB: TToolButton;
    SepTB9: TToolButton;
    TextAlignLeftB: TToolButton;
    TextAlignCenterB: TToolButton;
    TextAlignRightB: TToolButton;
    TextAlignBlockB: TToolButton;
    SepTB10: TToolButton;
    TextAlignTopB: TToolButton;
    TextAlignMiddleB: TToolButton;
    TextAlignBottomB: TToolButton;
    FrameTB: TToolBar;
    FrameTopB: TToolButton;
    FrameBottomB: TToolButton;
    FrameLeftB: TToolButton;
    FrameRightB: TToolButton;
    SepTB11: TToolButton;
    FrameAllB: TToolButton;
    FrameNoB: TToolButton;
    SepTB12: TToolButton;
    FillColorB: TToolButton;
    FrameColorB: TToolButton;
    FrameStyleB: TToolButton;
    PanelTB2: TfrxTBPanel;
    FrameWidthCB: TfrxComboBox;
    StandardTB: TToolBar;
    NewB: TToolButton;
    OpenB: TToolButton;
    SaveB: TToolButton;
    PreviewB: TToolButton;
    SepTB1: TToolButton;
    CutB: TToolButton;
    CopyB: TToolButton;
    PasteB: TToolButton;
    SepTB2: TToolButton;
    UndoB: TToolButton;
    RedoB: TToolButton;
    SepTB3: TToolButton;
    SepTB4: TToolButton;
    NewPageB: TToolButton;
    NewDialogB: TToolButton;
    DeletePageB: TToolButton;
    PageSettingsB: TToolButton;
    ShowGridB: TToolButton;
    AlignToGridB: TToolButton;
    ExtraToolsTB: TToolBar;
    PagePopup: TPopupMenu;
    CutMI1: TMenuItem;
    CopyMI1: TMenuItem;
    PasteMI1: TMenuItem;
    DeleteMI1: TMenuItem;
    SelectAllMI1: TMenuItem;
    SepMI8: TMenuItem;
    EditMI1: TMenuItem;
    MainMenu: TMainMenu;
    FileMenu: TMenuItem;
    EditMenu: TMenuItem;
    ViewMenu: TMenuItem;
    ToolbarsMI: TMenuItem;
    StandardMI: TMenuItem;
    TextMI: TMenuItem;
    FrameMI: TMenuItem;
    AlignmentMI: TMenuItem;
    ToolsMI: TMenuItem;
    InspectorMI: TMenuItem;
    DataTreeMI: TMenuItem;
    OptionsMI: TMenuItem;
    HelpMenu: TMenuItem;
    HelpContentsMI: TMenuItem;
    SepMI7: TMenuItem;
    AboutMI: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    TabPopup: TPopupMenu;
    NewPageMI1: TMenuItem;
    NewDialogMI1: TMenuItem;
    DeletePageMI1: TMenuItem;
    PageSettingsMI1: TMenuItem;
    ActionList: TActionList;
    ExitCmd: TAction;
    CutCmd: TAction;
    CopyCmd: TAction;
    PasteCmd: TAction;
    UndoCmd: TAction;
    RedoCmd: TAction;
    DeleteCmd: TAction;
    SelectAllCmd: TAction;
    EditCmd: TAction;
    BringToFrontCmd: TAction;
    SendToBackCmd: TAction;
    DeletePageCmd: TAction;
    NewItemCmd: TAction;
    NewPageCmd: TAction;
    NewDialogCmd: TAction;
    NewReportCmd: TAction;
    OpenCmd: TAction;
    SaveCmd: TAction;
    SaveAsCmd: TAction;
    VariablesCmd: TAction;
    PageSettingsCmd: TAction;
    PreviewCmd: TAction;
    NewMI: TMenuItem;
    NewReportMI: TMenuItem;
    NewPageMI: TMenuItem;
    NewDialogMI: TMenuItem;
    SepMI1: TMenuItem;
    OpenMI: TMenuItem;
    SaveMI: TMenuItem;
    SaveAsMI: TMenuItem;
    VariablesMI: TMenuItem;
    SepMI3: TMenuItem;
    PreviewMI: TMenuItem;
    SepMI4: TMenuItem;
    ExitMI: TMenuItem;
    UndoMI: TMenuItem;
    RedoMI: TMenuItem;
    SepMI5: TMenuItem;
    CutMI: TMenuItem;
    CopyMI: TMenuItem;
    PasteMI: TMenuItem;
    DeleteMI: TMenuItem;
    DeletePageMI: TMenuItem;
    SelectAllMI: TMenuItem;
    SepMI6: TMenuItem;
    BringtoFrontMI: TMenuItem;
    SendtoBackMI: TMenuItem;
    EditMI: TMenuItem;
    PanelTB3: TfrxTBPanel;
    ScaleCB: TfrxComboBox;
    ObjectsTB1: TToolBar;
    BandsPopup: TPopupMenu;
    ReportTitleMI: TMenuItem;
    ReportSummaryMI: TMenuItem;
    PageHeaderMI: TMenuItem;
    PageFooterMI: TMenuItem;
    HeaderMI: TMenuItem;
    FooterMI: TMenuItem;
    MasterDataMI: TMenuItem;
    DetailDataMI: TMenuItem;
    SubdetailDataMI: TMenuItem;
    GroupHeaderMI: TMenuItem;
    GroupFooterMI: TMenuItem;
    ColumnHeaderMI: TMenuItem;
    ColumnFooterMI: TMenuItem;
    ChildMI: TMenuItem;
    LeftDockSite1: TfrxDockSite;
    VariablesB: TToolButton;
    SepTB13: TToolButton;
    PageSettingsMI: TMenuItem;
    Timer: TTimer;
    ReportSettingsMI: TMenuItem;
    Data4levelMI: TMenuItem;
    Data5levelMI: TMenuItem;
    Data6levelMI: TMenuItem;
    SepMI10: TMenuItem;
    SepMI9: TMenuItem;
    ShowGuidesMI: TMenuItem;
    ShowRulersMI: TMenuItem;
    DeleteGuidesMI: TMenuItem;
    SepMI11: TMenuItem;
    N1: TMenuItem;
    BringtoFrontMI1: TMenuItem;
    SendtoBackMI1: TMenuItem;
    SepMI12: TMenuItem;
    RotateB: TToolButton;
    RotationPopup: TPopupMenu;
    R0MI: TMenuItem;
    R45MI: TMenuItem;
    R90MI: TMenuItem;
    R180MI: TMenuItem;
    R270MI: TMenuItem;
    SetToGridB: TToolButton;
    ShadowB: TToolButton;
    ReportMenu: TMenuItem;
    ReportDataMI: TMenuItem;
    OpenScriptDialog: TOpenDialog;
    SaveScriptDialog: TSaveDialog;
    ReportTreeMI: TMenuItem;
    ObjectsPopup: TPopupMenu;
    AlignTB: TToolBar;
    AlignLeftsB: TToolButton;
    AlignHorzCentersB: TToolButton;
    AlignRightsB: TToolButton;
    AlignTopsB: TToolButton;
    AlignVertCentersB: TToolButton;
    AlignBottomsB: TToolButton;
    SpaceHorzB: TToolButton;
    SpaceVertB: TToolButton;
    CenterHorzB: TToolButton;
    CenterVertB: TToolButton;
    SameWidthB: TToolButton;
    SameHeightB: TToolButton;
    SepTB15: TToolButton;
    SepTB16: TToolButton;
    SepTB18: TToolButton;
    SepTB17: TToolButton;
    OverlayMI: TMenuItem;
    StyleCB: TfrxComboBox;
    ReportStylesMI: TMenuItem;
    TabOrderMI: TMenuItem;
    N2: TMenuItem;
    FindMI: TMenuItem;
    FindNextMI: TMenuItem;
    ReplaceMI: TMenuItem;
    DMPPopup: TPopupMenu;
    BoldMI: TMenuItem;
    ItalicMI: TMenuItem;
    UnderlineMI: TMenuItem;
    SuperScriptMI: TMenuItem;
    SubScriptMI: TMenuItem;
    CondensedMI: TMenuItem;
    WideMI: TMenuItem;
    N12cpiMI: TMenuItem;
    N15cpiMI: TMenuItem;
    FontB: TToolButton;
    VerticalbandsMI: TMenuItem;
    HeaderMI1: TMenuItem;
    FooterMI1: TMenuItem;
    MasterDataMI1: TMenuItem;
    DetailDataMI1: TMenuItem;
    SubdetailDataMI1: TMenuItem;
    GroupHeaderMI1: TMenuItem;
    GroupFooterMI1: TMenuItem;
    ChildMI1: TMenuItem;
    N3: TMenuItem;
    GroupB: TToolButton;
    UngroupB: TToolButton;
    SepTB20: TToolButton;
    GroupCmd: TAction;
    UngroupCmd: TAction;
    GroupMI: TMenuItem;
    UngroupMI: TMenuItem;
    ConnectionsMI: TMenuItem;
    BackPanel: TPanel;
    ScrollBoxPanel: TPanel;
    ScrollBox: TfrxScrollBox;
    LeftRuler: TfrxRuler;
    TopRuler: TfrxRuler;
    CodePanel: TPanel;
    CodeTB: TToolBar;
    frTBPanel1: TfrxTBPanel;
    LangL: TLabel;
    LangCB: TfrxComboBox;
    OpenScriptB: TToolButton;
    SaveScriptB: TToolButton;
    SepTB19: TToolButton;
    RunScriptB: TToolButton;
    RunToCursorB: TToolButton;
    StepScriptB: TToolButton;
    StopScriptB: TToolButton;
    EvaluateB: TToolButton;
    BreakPointB: TToolButton;
    CodeDockSite: TfrxDockSite;
    LeftDockSite2: TfrxDockSite;
    RightDockSite: TfrxDockSite;
    TabPanel: TPanel;
    Panel1: TPanel;
    AddChildMI: TMenuItem;
    procedure ExitCmdExecute(Sender: TObject);
    procedure ObjectsButtonClick(Sender: TObject);
    procedure StatusBarDrawPanel(StatusBar: TStatusBar;
      Panel: TStatusPanel; const ARect: TRect);
    procedure ScrollBoxMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure ScrollBoxMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure ScrollBoxResize(Sender: TObject);
    procedure ScaleCBClick(Sender: TObject);
    procedure ShowGridBClick(Sender: TObject);
    procedure AlignToGridBClick(Sender: TObject);
    procedure StatusBarDblClick(Sender: TObject);
    procedure StatusBarMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure InsertBandClick(Sender: TObject);
    procedure BandsPopupPopup(Sender: TObject);
    procedure ToolbarsMIOpen(Sender: TObject);
    procedure ToolbarsMIClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure NewReportCmdExecute(Sender: TObject);
    procedure ToolButtonClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FontColorBClick(Sender: TObject);
    procedure FrameStyleBClick(Sender: TObject);
    procedure TabChange(Sender: TObject);
    procedure OptionsMIClick(Sender: TObject);
    procedure UndoCmdExecute(Sender: TObject);
    procedure RedoCmdExecute(Sender: TObject);
    procedure CutCmdExecute(Sender: TObject);
    procedure CopyCmdExecute(Sender: TObject);
    procedure PasteCmdExecute(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure DeletePageCmdExecute(Sender: TObject);
    procedure NewDialogCmdExecute(Sender: TObject);
    procedure NewPageCmdExecute(Sender: TObject);
    procedure SaveCmdExecute(Sender: TObject);
    procedure SaveAsCmdExecute(Sender: TObject);
    procedure OpenCmdExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure DeleteCmdExecute(Sender: TObject);
    procedure SelectAllCmdExecute(Sender: TObject);
    procedure EditCmdExecute(Sender: TObject);
    procedure TabChanging(Sender: TObject; var AllowChange: Boolean);
    procedure AboutMIClick(Sender: TObject);
    procedure ReportSettingsMIClick(Sender: TObject);
    procedure PageSettingsCmdExecute(Sender: TObject);
    procedure TopRulerDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ShowRulersMIClick(Sender: TObject);
    procedure ShowGuidesMIClick(Sender: TObject);
    procedure DeleteGuidesMIClick(Sender: TObject);
    procedure AlignLeftsBClick(Sender: TObject);
    procedure AlignRightsBClick(Sender: TObject);
    procedure AlignTopsBClick(Sender: TObject);
    procedure AlignBottomsBClick(Sender: TObject);
    procedure AlignHorzCentersBClick(Sender: TObject);
    procedure AlignVertCentersBClick(Sender: TObject);
    procedure CenterHorzBClick(Sender: TObject);
    procedure CenterVertBClick(Sender: TObject);
    procedure SpaceHorzBClick(Sender: TObject);
    procedure SpaceVertBClick(Sender: TObject);
    procedure SelectToolBClick(Sender: TObject);
    procedure PagePopupPopup(Sender: TObject);
    procedure BringToFrontCmdExecute(Sender: TObject);
    procedure SendToBackCmdExecute(Sender: TObject);
    procedure LangCBClick(Sender: TObject);
    procedure OpenScriptBClick(Sender: TObject);
    procedure SaveScriptBClick(Sender: TObject);
    procedure ReportDataMIClick(Sender: TObject);
    procedure CodeWindowDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure CodeWindowDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure VariablesCmdExecute(Sender: TObject);
    procedure ObjectBandBClick(Sender: TObject);
    procedure PreviewCmdExecute(Sender: TObject);
    procedure HighlightBClick(Sender: TObject);
    procedure TabMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TabMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure TabMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TabDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TabDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure SameWidthBClick(Sender: TObject);
    procedure SameHeightBClick(Sender: TObject);
    procedure ReportStylesMIClick(Sender: TObject);
    procedure NewItemCmdExecute(Sender: TObject);
    procedure TabOrderMIClick(Sender: TObject);
    procedure RunScriptBClick(Sender: TObject);
    procedure StopScriptBClick(Sender: TObject);
    procedure EvaluateBClick(Sender: TObject);
    procedure FindMIClick(Sender: TObject);
    procedure FindNextMIClick(Sender: TObject);
    procedure GroupCmdExecute(Sender: TObject);
    procedure UngroupCmdExecute(Sender: TObject);
    procedure ConnectionsMIClick(Sender: TObject);
    procedure LangSelectClick(Sender: TObject);
    procedure HelpContentsMIClick(Sender: TObject);
    procedure BreakPointBClick(Sender: TObject);
    procedure RunToCursorBClick(Sender: TObject);
    procedure CodeDockSiteDockOver(Sender: TObject;
      Source: TDragDockObject; X, Y: Integer; State: TDragState;
      var Accept: Boolean);
    procedure TabSetChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure AddChildMIClick(Sender: TObject);
  private
    { Private declarations }
    ObjectSelectB: TToolButton;
    HandToolB: TToolButton;
    ZoomToolB: TToolButton;
    TextToolB: TToolButton;
    FormatToolB: TToolButton;
    ObjectBandB: TToolButton;

    FClipboard: TfrxClipboard;
    FCodeWindow: TfrxSyntaxMemo;
    FColor: TColor;
    FCoord1: String;
    FCoord2: String;
    FCoord3: String;
    FDialogForm: TfrxDialogForm;
    FEditAfterInsert: Boolean;
    FDataTree: TfrxDataTreeForm;
    FDropFields: Boolean;
    FGridAlign: Boolean;
    FGridSize1: Extended;
    FGridSize2: Extended;
    FGridSize3: Extended;
    FGridSize4: Extended;
    FInspector: TfrxObjectInspector;
    FLineStyle: TfrxFrameStyle;
    FLocalizedOI: Boolean;
    FModifiedBy: TObject;
    FMouseDown: Boolean;
    FOldDesignerComp: TfrxDesigner;
    FOldUnits: TfrxDesignerUnits;
    FPagePositions: TStrings;
    FPictureCache: TfrxPictureCache;
    FRecentFiles: TStringList;
    FRecentMenuIndex: Integer;
    FReportTree: TfrxReportTreeForm;
    FSampleFormat: TSampleFormat;
    FScale: Extended;
    FScriptFirstTime: Boolean;
    FScriptRunning: Boolean;
    FScriptStep: Boolean;
    FScriptStopped: Boolean;
    FSearchCase: Boolean;
    FSearchIndex: Integer;
    FSearchReplace: Boolean;
    FSearchReplaceText: String;
    FSearchText: String;
    FShowGrid: Boolean;
    FShowGuides: Boolean;
    FShowRulers: Boolean;
    FShowStartup: Boolean;
{$IFDEF UseTabset}
    FTabs: TTabSet;
{$ELSE}
    FTabs: TTabControl;
{$ENDIF}
    FToolsColor: TColor;
    FUndoBuffer: TfrxUndoBuffer;
    FUnits: TfrxDesignerUnits;
    FUnitsDblClicked: Boolean;
    FUpdatingControls: Boolean;
    FWatchList: TfrxWatchForm;
    FWorkspace: TfrxDesignerWorkspace;
    FWorkspaceColor: TColor;

    procedure AttachDialogFormEvents(Attach: Boolean);
    procedure CreateColorSelector(Sender: TToolButton);
    procedure CreateExtraToolbar;
    procedure CreateToolWindows;
    procedure CreateObjectsToolbar;
    procedure CreateWorkspace;
    procedure DialogFormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DialogFormKeyPress(Sender: TObject; var Key: Char);
    procedure DialogFormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DialogFormModify(Sender: TObject);
    procedure Done;
    procedure FindText;
    procedure Init;
    procedure OnCodeChanged(Sender: TObject);
    procedure OnCodeCompletion(const Name: String; List: TStrings);
    procedure OnColorChanged(Sender: TObject);
    procedure OnComponentMenuClick(Sender: TObject);
    procedure OnChangePosition(Sender: TObject);
    procedure OnDataTreeDblClick(Sender: TObject);
    procedure OnDisableDock(Sender: TObject; var DragObject: TDragDockObject);
    procedure OnEditObject(Sender: TObject);
    procedure OnEnableDock(Sender, Target: TObject; X, Y: Integer);
    procedure OnExtraToolClick(Sender: TObject);
    procedure OnInsertObject(Sender: TObject);
    procedure OnModify(Sender: TObject);
    procedure OnNotifyPosition(ARect: TfrxRect);
    procedure OnRunLine(Sender: TfsScript; const UnitName, SourcePos: String);
    procedure OnSelectionChanged(Sender: TObject);
    procedure OnStyleChanged(Sender: TObject);
    procedure OpenRecentFile(Sender: TObject);
    procedure ReadButtonImages;
    procedure ReloadObjects;
    procedure RestorePagePosition;
    procedure SavePagePosition;
    procedure SaveState;
    procedure SetScale(Value: Extended);
    procedure SetGridAlign(const Value: Boolean);
    procedure SetShowGrid(const Value: Boolean);
    procedure SetShowRulers(const Value: Boolean);
    procedure SetToolsColor(const Value: TColor);
    procedure SetUnits(const Value: TfrxDesignerUnits);
    procedure SetWorkspaceColor(const Value: TColor);
    procedure SwitchToolbar;
    procedure UpdateCaption;
    procedure UpdateControls;
    procedure UpdatePageDimensions;
    procedure UpdateRecentFiles(NewFile: String);
    procedure UpdateStyles;
    procedure UpdateSyntaxType;
    function AskSave: Word;
    function GetPageIndex: Integer;
    function GetReportName: String;
    procedure SetShowGuides(const Value: Boolean);
    procedure Localize;
    procedure CreateLangMenu;
    procedure CMStartup(var Message: TMessage); message WM_USER + 1;
    procedure WMSysCommand(var Message: TWMSysCommand); message WM_SYSCOMMAND;
    procedure WMEnable(var Message: TMessage); message WM_ENABLE;
  protected
    procedure SetModified(const Value: Boolean); override;
    procedure SetPage(const Value: TfrxPage); override;
    function GetCode: TStrings; override;
  public
    { Public declarations }
    function CheckOp(Op: TfrxDesignerRestriction): Boolean;
    function InsertExpression(const Expr: String): String; override;
    procedure LoadFile(FileName: String; UseOnLoadEvent: Boolean);
    procedure Lock; override;
    procedure ReloadPages(Index: Integer); override;
    procedure ReloadReport; override;
    procedure RestoreState(RestoreDefault: Boolean = False;
      RestoreMainForm: Boolean = False);
    procedure SaveFile(SaveAs: Boolean; UseOnSaveEvent: Boolean);
    procedure SetReportDefaults;
    procedure SwitchToCodeWindow;
    procedure UpdateDataTree; override;
    procedure UpdatePage; override;
    function GetDefaultObjectSize: TfrxPoint;
    function mmToUnits(mm: Extended; X: Boolean = True): Extended;
    function UnitsTomm(mm: Extended; X: Boolean = True): Extended;

    property CodeWindow: TfrxSyntaxMemo read FCodeWindow;
    property DataTree: TfrxDataTreeForm read FDataTree;
    property DropFields: Boolean read FDropFields write FDropFields;
    property EditAfterInsert: Boolean read FEditAfterInsert write FEditAfterInsert;
    property GridAlign: Boolean read FGridAlign write SetGridAlign;
    property GridSize1: Extended read FGridSize1 write FGridSize1;
    property GridSize2: Extended read FGridSize2 write FGridSize2;
    property GridSize3: Extended read FGridSize3 write FGridSize3;
    property GridSize4: Extended read FGridSize4 write FGridSize4;
    property PictureCache: TfrxPictureCache read FPictureCache;
    property RecentFiles: TStringList read FRecentFiles;
    property SampleFormat: TSampleFormat read FSampleFormat;
    property Scale: Extended read FScale write SetScale;
    property ShowGrid: Boolean read FShowGrid write SetShowGrid;
    property ShowGuides: Boolean read FShowGuides write SetShowGuides;
    property ShowRulers: Boolean read FShowRulers write SetShowRulers;
    property ShowStartup: Boolean read FShowStartup write FShowStartup;
    property ToolsColor: TColor read FToolsColor write SetToolsColor;
    property Units: TfrxDesignerUnits read FUnits write SetUnits;
    property Workspace: TfrxDesignerWorkspace read FWorkspace;
    property WorkspaceColor: TColor read FWorkspaceColor write SetWorkspaceColor;
  end;

  TSampleFormat = class(TObject)
  private
    FMemo: TfrxCustomMemoView;
    procedure Clear;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ApplySample(Memo: TfrxCustomMemoView);
    procedure SetAsSample(Memo: TfrxCustomMemoView);
    property Memo: TfrxCustomMemoView read FMemo;
  end;

var
  frxDesignerComp: TfrxDesigner;

implementation

{$R *.DFM}
{$R *.RES}

uses
  TypInfo, IniFiles, Registry,
  frxDsgnIntf, frxUtils, frxPopupForm, frxDesgnWorkspace1,
  frxDesgnEditors, frxEditOptions, frxEditReport, frxEditPage, frxAbout,
  fs_itools, frxXML, frxEditReportData, frxEditVar, frxEditExpr,
  frxEditHighlight, frxEditStyle, frxNewItem,
  frxStdWizard,
  frxEditTabOrder, frxCodeUtils, frxRes, frxrcDesgn, frxDMPClass,
  frxEvaluateForm, frxSearchDialog, frxConnEditor, fs_xml;

type
  THackControl = class(TWinControl);



{ TSampleFormat }

constructor TSampleFormat.Create;
begin
  Clear;
end;

destructor TSampleFormat.Destroy;
begin
  FMemo.Free;
  inherited;
end;

procedure TSampleFormat.Clear;
begin
  if FMemo <> nil then
    FMemo.Free;
  FMemo := TfrxMemoView.Create(nil);
  if frxDesignerComp <> nil then
  begin
    FMemo.Font := frxDesignerComp.DefaultFont;
    FMemo.RTLReading := frxDesignerComp.RTLLanguage;
  end;
end;

procedure TSampleFormat.ApplySample(Memo: TfrxCustomMemoView);
begin
  Memo.Color := FMemo.Color;
  if not (Memo is TfrxDMPMemoView) then
    Memo.Font := FMemo.Font;
  Memo.Frame.Assign(FMemo.Frame);
  Memo.HAlign := FMemo.HAlign;
  Memo.VAlign := FMemo.VAlign;
  Memo.RTLReading := FMemo.RTLReading;
end;

procedure TSampleFormat.SetAsSample(Memo: TfrxCustomMemoView);
begin
  FMemo.Color := Memo.Color;
  if not (Memo is TfrxDMPMemoView) then
    FMemo.Font := Memo.Font;
  FMemo.Frame.Assign(Memo.Frame);
  FMemo.HAlign := Memo.HAlign;
  FMemo.VAlign := Memo.VAlign;
  FMemo.RTLReading := Memo.RTLReading;
end;


{ TfrxDesigner }

constructor TfrxDesigner.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FCloseQuery := True;
  FDefaultFont := TFont.Create;
  with FDefaultFont do
  begin
    Name := 'Arial';
    Size := 10;
  end;
  FDefaultScriptLanguage := 'PascalScript';
  FDefaultLeftMargin := 10;
  FDefaultBottomMargin := 10;
  FDefaultRightMargin := 10;
  FDefaultTopMargin := 10;
  FDefaultPaperSize := DMPAPER_A4;
  FDefaultOrientation := poPortrait;
  frxDesignerComp := Self;
{$IFDEF Delphi10}
  FGradientStart := clWindow;
  FGradientEnd := $00B6D6DA;
{$ENDIF}


end;

destructor TfrxDesigner.Destroy;
begin
  FDefaultFont.Free;
  frxDesignerComp := nil;
  inherited Destroy;
end;

procedure TfrxDesigner.SetDefaultFont(const Value: TFont);
begin
  FDefaultFont.Assign(Value);
end;

procedure TfrxDesigner.GetTemplateList(List: TStrings);
var
  sr: TSearchRec;
  dir: String;

  function NormalDir(const DirName: string): string;
  begin
    Result := DirName;
    if (Result <> '') and
      not (Result[Length(Result)] in [':', '\']) then
    begin
      if (Length(Result) = 1) and (UpCase(Result[1]) in ['A'..'Z']) then
        Result := Result + ':\'
      else Result := Result + '\';
    end;
  end;

begin
  List.Clear;
  if Assigned(FOnGetTemplateList) then
    FOnGetTemplateList(List)
  else
  begin
    dir := FTemplateDir;
    if (Trim(dir) = '') or (Trim(dir) = '.') then
      dir := ExtractFilePath(Application.ExeName);
    dir := NormalDir(dir);
    if FindFirst(dir + '*.fr3', faAnyFile, sr) = 0 then
    begin
      repeat
        List.Add(dir + sr.Name);
      until FindNext(sr) <> 0;
      FindClose(sr);
    end;
  end;
end;



{ TfrxDesignerForm }

{ Form events }
{------------------------------------------------------------------------------}

procedure TfrxDesignerForm.FormShow(Sender: TObject);
begin

  ReadButtonImages;
  CreateObjectsToolbar;
  CreateWorkspace;
  CreateToolWindows;
  Init;
  CreateExtraToolbar;

  Localize;
  CreateLangMenu;

  with ScaleCB.Items do
  begin
    Clear;
    Add('25%');
    Add('50%');
    Add('75%');
    Add('100%');
    Add('150%');
    Add('200%');
    Add(frxResources.Get('zmPageWidth'));
    Add(frxResources.Get('zmWholePage'));
  end;

  if Screen.PixelsPerInch > 96 then
  begin
    StyleCB.Font.Height := -11;
    FontNameCB.Font.Height := -11;
    FontSizeCB.Font.Height := -11;
    ScaleCB.Font.Height := -11;
    FrameWidthCB.Font.Height := -11;
    LangL.Font.Height := -11;
    LangCB.Font.Height := -11;
  end;

  RestoreState;
  ToolsMI.Visible := ExtraToolsTB.ButtonCount > 0;
  ExtraToolsTB.Visible := ExtraToolsTB.ButtonCount > 0;
  ReloadReport;
  RestoreState(False, True);

  ConnectionsMI.Visible := False;
  if frxDesignerComp <> nil then
  begin
    ConnectionsMI.Visible := frxDesignerComp.Standalone;
    if Assigned(frxDesignerComp.FOnShow) then
      frxDesignerComp.FOnShow(Self);
  end;
end;

procedure TfrxDesignerForm.FormHide(Sender: TObject);
begin
  SaveState;
  Done;
end;

procedure TfrxDesignerForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Report.Modified := Modified;
  Report.Designer := nil;
  Action := caFree;
end;

procedure TfrxDesignerForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  w: Word;
begin
  if FScriptRunning then
  begin
    CanClose := False;
    Exit;
  end;

  CanClose := True;
  Report.ScriptText := CodeWindow.Lines;

  if (frxDesignerComp <> nil) and not frxDesignerComp.CloseQuery then
    Exit;

  if Modified and not (csDesigning in Report.ComponentState) and CheckOp(drDontSaveReport) then
  begin
    w := AskSave;

    if IsPreviewDesigner then
    begin
      if w = mrNo then
        Modified := False
    end
    else if w = mrYes then
      SaveFile(False, True);

    if not IsPreviewDesigner then
    begin
      if w = mrNo then 
        Modified := False
      else
        Modified := True;
    end;

    if w = mrCancel then
      CanClose := False;
  end;
end;

procedure TfrxDesignerForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ((FDialogForm <> nil) or (FPage is TfrxDataPage)) and
    (ActiveControl <> FInspector.Edit1) then
    THackControl(FWorkspace).KeyDown(Key, Shift);

  if Key = vk_Return then
    if ActiveControl = FontSizeCB then
      ToolButtonClick(FontSizeCB)
    else if ActiveControl = ScaleCB then
      ScaleCBClick(Self);

  if (Page <> nil) and (ActiveControl <> FInspector.Edit1) then
    if Key = vk_Insert then
      if Shift = [ssShift] then
        PasteCmdExecute(nil)
      else if Shift = [ssCtrl] then
        CopyCmdExecute(nil);

  if (Page <> nil) and (ActiveControl <> FInspector.Edit1) then
    if Key = vk_Delete then
      if Shift = [ssShift] then
        CutCmdExecute(nil);

  if (Key = Ord('E')) and (Shift = [ssCtrl]) then
    Page := nil;

  if ((Key = vk_F4) or (Key = vk_F5)) and (Shift = []) and (Page = nil) then
  begin
    if Key = vk_F4 then
      RunToCursorBClick(nil)
    else
      BreakPointBClick(nil);
  end
  else if (Key = vk_F2) and (Shift = [ssCtrl]) then
    StopScriptBClick(StopScriptB)
  else if (Key = vk_F7) and (Shift = [ssCtrl]) and (Page = nil) then
    EvaluateBClick(EvaluateB)
  else if Key = vk_F9 then
    RunScriptBClick(RunScriptB)
  else if ((Key = vk_F7) or (Key = vk_F8)) and (Page = nil) then
    RunScriptBClick(StepScriptB);
end;

procedure TfrxDesignerForm.CMStartup(var Message: TMessage);
begin
  if FShowStartup then
    if (frxDesignerComp <> nil) and Assigned(frxDesignerComp.FOnShowStartupScreen) then
      frxDesignerComp.FOnShowStartupScreen(Self);
end;

procedure TfrxDesignerForm.WMSysCommand(var Message: TWMSysCommand);
begin
  if (Message.CmdType and $FFF0 = SC_MINIMIZE) and (FormStyle <> fsMDIChild) then
    Application.Minimize
  else
    inherited;
end;

procedure TfrxDesignerForm.WMEnable(var Message: TMessage);
var
  fStyle: UINT;
  en: Boolean;

  procedure SetFormStyle(Control: TWinControl);
  begin
    if Control is TToolBar then
      if Control.Floating then
        Control := Control.Parent
      else
        Exit;
    SetWindowPos(Control.Handle, fStyle, 0, 0, 0, 0, SWP_NOMOVE or
      SWP_NOSIZE or SWP_NOACTIVATE);
  end;

begin
  inherited;
  { workaround for ShowModal bug. If form with fsStayOnTop style is visible
    before ShowModal call, it will be topmost }
  en := Message.WParam <> 0;

  if en then
    fStyle := HWND_TOPMOST
  else
    fStyle := HWND_NOTOPMOST;

  SetFormStyle(FReportTree);
  SetFormStyle(FDataTree);
  SetFormStyle(FInspector);

  SetFormStyle(StandardTB);
  SetFormStyle(TextTB);
  SetFormStyle(FrameTB);
  SetFormStyle(AlignTB);
  SetFormStyle(ExtraToolsTB);
end;


{ Get/Set methods }
{------------------------------------------------------------------------------}

function TfrxDesignerForm.GetDefaultObjectSize: TfrxPoint;
begin
  case FUnits of
    duCM:     Result := frxPoint(fr1cm * 2.5, fr1cm * 0.5);
    duInches: Result := frxPoint(fr1in, fr1in * 0.2);
    duPixels: Result := frxPoint(80, 16);
    duChars:  Result := frxPoint(fr1CharX * 10, fr1CharY);
  end;
end;

function TfrxDesignerForm.GetCode: TStrings;
begin
  Result := CodeWindow.Lines;
end;

procedure TfrxDesignerForm.SetGridAlign(const Value: Boolean);
begin
  FGridAlign := Value;
  AlignToGridB.Down := FGridAlign;
  FWorkspace.GridAlign := FGridAlign;
end;

procedure TfrxDesignerForm.SetModified(const Value: Boolean);
var
  i: Integer;
begin
  inherited;
  Report.ScriptText := CodeWindow.Lines;
  FUndoBuffer.AddUndo(Report);
  FUndoBuffer.ClearRedo;
  SaveCmd.Enabled := Modified;

  if FModifiedBy <> Self then
    UpdateControls;

  if FModifiedBy = FInspector then
    if (FSelectedObjects[0] = FPage) or
       (TObject(FSelectedObjects[0]) is TfrxSubreport) then
    begin
      i := Report.Objects.IndexOf(FPage);
      if i >= 0 then
        ReloadPages(i);
    end;

  if FModifiedBy <> FWorkspace then
  begin
    FWorkspace.UpdateView;
    FWorkspace.AdjustBands;
  end;

  if FModifiedBy <> FInspector then
    FInspector.UpdateProperties;

  FReportTree.UpdateItems;
  FModifiedBy := nil;
end;

procedure TfrxDesignerForm.SetPage(const Value: TfrxPage);
begin
  inherited;

  FTabs.TabIndex := Report.Objects.IndexOf(FPage) + 1;
  AttachDialogFormEvents(False);
  ScrollBoxPanel.Visible := FPage <> nil;
  CodePanel.Visible := FPage = nil;

  SwitchToolbar;
  UpdateControls;

  if FPage = nil then
  begin
    CodeWindow.SetFocus;
    Exit;
  end
  else if FPage is TfrxReportPage then
  begin
    with FWorkspace do
    begin
      Parent := ScrollBox;
      Align := alNone;
      Color := FWorkspaceColor;
      Scale := Self.Scale;
    end;

    if FPage is TfrxDMPPage then
      Units := duChars else
      Units := FOldUnits;
    UpdatePageDimensions;
    if Visible then
      ScrollBox.SetFocus;
  end
  else if FPage is TfrxDialogPage then
  begin
    Units := duPixels;
    FDialogForm := TfrxDialogForm(TfrxDialogPage(FPage).DialogForm);

    with FWorkspace do
    begin
      Parent := FDialogForm;
      Align := alClient;
      GridType := gtDialog;
      GridX := FGridSize4;
      GridY := FGridSize4;
      Color := TfrxDialogPage(FPage).Color;
      Scale := 1;
      SetPageDimensions(0, 0, Rect(0, 0, 0, 0));
    end;

    if FDialogForm <> nil then
    with FDialogForm do
    begin
      Position := poDesigned;
      BorderStyle := bsSizeable;
      AttachDialogFormEvents(True);
      Show;
    end;
  end
  else if FPage is TfrxDataPage then
  begin
    Units := duPixels;
    with FWorkspace do
    begin
      Parent := ScrollBox;
      Align := alNone;
      Color := FWorkspaceColor;
      Scale := 1;
      GridType := gtNone;
      GridX := FGridSize4;
      GridY := FGridSize4;
    end;

    UpdatePageDimensions;
    if Visible then
      ScrollBox.SetFocus;
  end
  else
  begin
    Report.Errors.Add('Page object is not page');
  end;

  ReloadObjects;
  RestorePagePosition;
end;

procedure TfrxDesignerForm.SetScale(Value: Extended);
begin
  ScrollBox.AutoScroll := False;
  if Value = 0 then
    Value := 1;
  if Value > 20 then
    Value := 20;
  FScale := Value;
  TopRuler.Scale := Value;
  LeftRuler.Scale := Value;
  FWorkspace.Scale := Value;
  ScaleCB.Text := IntToStr(Round(FScale * 100)) + '%';
  UpdatePageDimensions;
  ScrollBox.AutoScroll := True;
end;

procedure TfrxDesignerForm.SetShowGrid(const Value: Boolean);
begin
  FShowGrid := Value;
  ShowGridB.Down := FShowGrid;
  FWorkspace.ShowGrid := FShowGrid;
end;

procedure TfrxDesignerForm.SetShowRulers(const Value: Boolean);
begin
  FShowRulers := Value;
  TopRuler.Visible := FShowRulers;
  LeftRuler.Visible := FShowRulers;
  ShowRulersMI.Checked := FShowRulers;
end;

procedure TfrxDesignerForm.SetShowGuides(const Value: Boolean);
begin
  FShowGuides := Value;
  TDesignerWorkspace(FWorkspace).ShowGuides := FShowGuides;
  ShowGuidesMI.Checked := FShowGuides;
end;

procedure TfrxDesignerForm.SetUnits(const Value: TfrxDesignerUnits);
var
  s: String;
  gType: TfrxGridType;
  gSizeX, gSizeY: Extended;
begin
  FUnits := Value;
  s := '';
  if FUnits = duCM then
  begin
    s := frxResources.Get('dsCm');
    gType := gt1cm;
    gSizeX := FGridSize1 * fr1cm;
    gSizeY := gSizeX;
  end
  else if FUnits = duInches then
  begin
    s := frxResources.Get('dsInch');
    gType := gt1in;
    gSizeX := FGridSize2 * fr1in;
    gSizeY := gSizeX;
  end
  else if FUnits = duPixels then
  begin
    s := frxResources.Get('dsPix');
    gType := gt1pt;
    gSizeX := FGridSize3;
    gSizeY := gSizeX;
  end
  else {if FUnits = duChars then}
  begin
    s := frxResources.Get('dsChars');
    gType := gtChar;
    gSizeX := fr1CharX;
    gSizeY := fr1CharY;
  end;

  StatusBar.Panels[0].Text := s;
  TopRuler.Units := TfrxRulerUnits(FUnits);
  LeftRuler.Units := TfrxRulerUnits(FUnits);

  with FWorkspace do
  begin
    GridType := gType;
    GridX := gSizeX;
    GridY := gSizeY;
    AdjustBands;
  end;

  if FSelectedObjects.Count <> 0 then
    OnSelectionChanged(Self);
end;

procedure TfrxDesignerForm.SetToolsColor(const Value: TColor);
begin
  FToolsColor := Value;
  FInspector.SetColor(Value);
  FDataTree.SetColor(Value);
  FReportTree.SetColor(Value);
end;

procedure TfrxDesignerForm.SetWorkspaceColor(const Value: TColor);
begin
  FWorkspaceColor := Value;
  if not (FPage is TfrxDialogPage) then
    FWorkspace.Color := Value;
end;


{ Service methods }
{------------------------------------------------------------------------------}

procedure TfrxDesignerForm.Init;
var
  i: Integer;
begin
  FPictureCache := TfrxPictureCache.Create;
  FScale := 1;
  ScrollBoxPanel.Align := alClient;
  CodePanel.Align := alClient;

  fsGetLanguageList(LangCB.Items);
  frxAddCodeRes;

  FUndoBuffer := TfrxUndoBuffer.Create;
  FUndoBuffer.PictureCache := FPictureCache;

  FClipboard := TfrxClipboard.Create(Self);
  FClipboard.PictureCache := FPictureCache;
  Timer.Enabled := True;

  FRecentFiles := TStringList.Create;
  FRecentMenuIndex := FileMenu.IndexOf(SepMI4);
{$IFDEF Delphi5}
  MainMenu.AutoHotKeys := maManual;
{$ENDIF}

  FSampleFormat := TSampleFormat.Create;
  FPagePositions := TStringList.Create;
  for i := 1 to 256 do
    FPagePositions.Add('');

  if IsPreviewDesigner then
  begin
    FOldDesignerComp := frxDesignerComp;
    TfrxDesigner.Create(nil);
    frxDesignerComp.Restrictions := [drDontDeletePage, drDontCreatePage,
      drDontCreateReport, drDontLoadReport, drDontPreviewReport,
      drDontEditVariables, drDontChangeReportOptions];
    ObjectBandB.Enabled := False;
  end;

  Report.SelectPrinter;
  FontNameCB.PopulateList;

{$IFDEF FR_VER_BASIC}
  NewDialogCmd.Enabled := False;
{$ENDIF}

  NewReportCmd.Enabled := CheckOp(drDontCreateReport) and not (csAncestor in Report.ComponentState);
  NewItemCmd.Enabled := CheckOp(drDontCreateReport);
  NewPageCmd.Enabled := CheckOp(drDontCreatePage);
  NewDialogCmd.Enabled := NewDialogCmd.Enabled and CheckOp(drDontCreatePage);
  SaveAsCmd.Enabled := CheckOp(drDontSaveReport);
  OpenCmd.Enabled := CheckOp(drDontLoadReport) and not (csAncestor in Report.ComponentState);
  ReportSettingsMI.Enabled := CheckOp(drDontChangeReportOptions);
  ReportStylesMI.Enabled := CheckOp(drDontChangeReportOptions);
  ReportDataMI.Enabled := CheckOp(drDontEditReportData);
  VariablesCmd.Enabled := CheckOp(drDontEditVariables);
  PreviewCmd.Enabled := CheckOp(drDontPreviewReport);
end;

procedure TfrxDesignerForm.Done;
begin
  AttachDialogFormEvents(False);
  if IsPreviewDesigner then
  begin
    frxDesignerComp.Free;
    frxDesignerComp := FOldDesignerComp;
  end;

  FPictureCache.Free;
  FUndoBuffer.Free;
  FClipboard.Free;
  FRecentFiles.Free;
  FSampleFormat.Free;
  FPagePositions.Free;
end;

procedure TfrxDesignerForm.ReadButtonImages;
var
  MainImages, DisabledImages, ObjectImages: TImageList;
begin
  MainImages := frxResources.MainButtonImages;
  DisabledImages := frxResources.DisabledButtonImages;
  ObjectImages := frxResources.ObjectImages;

  CodeTB.Images := MainImages;
  CodeTB.DisabledImages := DisabledImages;

  StandardTB.Images := MainImages;
  StandardTB.DisabledImages := DisabledImages;

  TextTB.Images := MainImages;
  TextTB.DisabledImages := DisabledImages;

  FrameTB.Images := MainImages;
  FrameTB.DisabledImages := DisabledImages;

  AlignTB.Images := MainImages;
  AlignTB.DisabledImages := DisabledImages;

  ExtraToolsTB.Images := MainImages;
  ExtraToolsTB.DisabledImages := DisabledImages;

  ObjectsTB1.Images := ObjectImages;
  ObjectsPopup.Images := ObjectImages;
  MainMenu.Images := MainImages;
  PagePopup.Images := MainImages;
  TabPopup.Images := MainImages;
  ActionList.Images := MainImages;
  BandsPopup.Images := MainImages;

{$IFDEF Delphi10}
  if (frxDesignerComp <> nil) and (frxDesignerComp.Gradient) then
  begin
    StandardTB.DrawingStyle := ComCtrls.dsGradient;
    StandardTB.GradientStartColor := frxDesignerComp.GradientStart;
    StandardTB.GradientEndColor := frxDesignerComp.GradientEnd;
    TextTB.DrawingStyle := ComCtrls.dsGradient;
    TextTB.GradientStartColor := frxDesignerComp.GradientStart;
    TextTB.GradientEndColor := frxDesignerComp.GradientEnd;
    FrameTB.DrawingStyle := ComCtrls.dsGradient;
    FrameTB.GradientStartColor := frxDesignerComp.GradientStart;
    FrameTB.GradientEndColor := frxDesignerComp.GradientEnd;
    AlignTB.DrawingStyle := ComCtrls.dsGradient;
    AlignTB.GradientStartColor := frxDesignerComp.GradientStart;
    AlignTB.GradientEndColor := frxDesignerComp.GradientEnd;
    ExtraToolsTB.DrawingStyle := ComCtrls.dsGradient;
    ExtraToolsTB.GradientStartColor := frxDesignerComp.GradientStart;
    ExtraToolsTB.GradientEndColor := frxDesignerComp.GradientEnd;
    ObjectsTB1.DrawingStyle := ComCtrls.dsGradient;
    ObjectsTB1.GradientStartColor := frxDesignerComp.GradientStart;
    ObjectsTB1.GradientEndColor := frxDesignerComp.GradientEnd;
    DockTop.DrawingStyle := dsGradient;
    DockTop.GradientStartColor := frxDesignerComp.GradientStart;
    DockTop.GradientEndColor := frxDesignerComp.GradientEnd;
    DockBottom.DrawingStyle := dsGradient;
    DockBottom.GradientStartColor := frxDesignerComp.GradientStart;
    DockBottom.GradientEndColor := frxDesignerComp.GradientEnd;
  end;
{$ENDIF}
end;

procedure TfrxDesignerForm.CreateToolWindows;
begin
  FInspector := TfrxObjectInspector.Create(Self);
  with FInspector do
  begin
    OnModify := Self.OnModify;
    OnSelectionChanged := Self.OnSelectionChanged;
    OnStartDock := OnDisableDock;
    OnEndDock := OnEnableDock;
    SelectedObjects := FSelectedObjects;
  end;

  FDataTree := TfrxDataTreeForm.Create(Self);
  with FDataTree do
  begin
    Report := Self.Report;
    CBPanel.Visible := True;
    OnDblClick := OnDataTreeDblClick;
    OnStartDock := OnDisableDock;
    OnEndDock := OnEnableDock;
  end;
  UpdateDataTree;

  FReportTree := TfrxReportTreeForm.Create(Self);
  FReportTree.OnSelectionChanged := OnSelectionChanged;
  FReportTree.OnStartDock := OnDisableDock;
  FReportTree.OnEndDock := OnEnableDock;

  FWatchList := TfrxWatchForm.Create(Self);
  FWatchList.Script := Report.Script;
end;

procedure TfrxDesignerForm.CreateWorkspace;
begin
  FWorkspace := TDesignerWorkspace.Create(Self);
  with FWorkspace do
  begin
    Parent := ScrollBox;
    OnNotifyPosition := Self.OnNotifyPosition;
    OnInsert := OnInsertObject;
    OnEdit := OnEditObject;
    OnModify := Self.OnModify;
    OnSelectionChanged := Self.OnSelectionChanged;
    OnTopLeftChanged := ScrollBoxResize;
    PopupMenu := PagePopup;
    Objects := FObjects;
    SelectedObjects := FSelectedObjects;
  end;

  FCodeWindow := TfrxSyntaxMemo.Create(Self);
  with FCodeWindow do
  begin
    Parent := CodePanel;
    Align := alClient;
    BevelKind := bkFlat;
    Lines := Report.ScriptText;
    Color := clWindow;
    OnChangeText := OnCodeChanged;
    OnChangePos := OnChangePosition;
    OnDragOver := CodeWindowDragOver;
    OnDragDrop := CodeWindowDragDrop;
    OnCodeCompletion := Self.OnCodeCompletion;
  end;

{$IFDEF UseTabset}
  FTabs := TTabSet.Create(Self);
  FTabs.ShrinkToFit := True;
  FTabs.Style := tsSoftTabs;
  FTabs.TabPosition := tpTop;
  FTabs.OnClick := TabChange;
  FTabs.OnChange := TabSetChange;
{$ELSE}
  FTabs := TTabControl.Create(Self);
  FTabs.OnChange := TabChange;
  FTabs.OnChanging := TabChanging;
{$ENDIF}
  FTabs.OnDragDrop := TabDragDrop;
  FTabs.OnDragOver := TabDragOver;
  FTabs.OnMouseDown := TabMouseDown;
  FTabs.OnMouseMove := TabMouseMove;
  FTabs.OnMouseUp := TabMouseUp;
  FTabs.Parent := TabPanel;
  FTabs.Align := alTop;
{$IFDEF UseTabset}
  FTabs.Height := 22;
  Panel1.SetBounds(0, FTabs.Height, 2000, 2);
{$ELSE}
  if Screen.PixelsPerInch > 96 then
    FTabs.Height := 25
  else
    FTabs.Height := 21;
  Panel1.BringToFront;
  Panel1.SetBounds(0, FTabs.Height, 2000, 2);
  FTabs.Height := FTabs.Height + 2;
{$ENDIF}
end;

procedure TfrxDesignerForm.CreateObjectsToolbar;
var
  i: Integer;
  Item: TfrxObjectItem;

  function HasButtons(Item: TfrxObjectItem): Boolean;
  var
    i: Integer;
    Item1: TfrxObjectItem;
  begin
    Result := False;
    for i := 0 to frxObjects.Count - 1 do
    begin
      Item1 := frxObjects[i];
      if (Item1.ClassRef <> nil) and (Item1.CategoryName = Item.CategoryName) then
        Result := True;
    end;
  end;

  procedure CreateButton(Index: Integer; Item: TfrxObjectItem);
  var
    b: TToolButton;
    s: String;
  begin
    b := TToolButton.Create(ObjectsTB1);
    b.Parent := ObjectsTB1;
    b.Style := tbsCheck;
    b.ImageIndex := Item.ButtonImageIndex;
    b.Grouped := True;
    s := Item.ButtonHint;
    if s = '' then
    begin
      if Item.ClassRef <> nil then
        s := Item.ClassRef.GetDescription;
    end
    else
      s := frxResources.Get(s);
    b.Hint := s;
    b.Tag := Index;
    if Item.ClassRef = nil then  { category }
      if not HasButtons(Item) then
      begin
        b.Free;
        Exit;
      end;
    b.OnClick := ObjectsButtonClick;
    b.Wrap := True;
    {$IFDEF FR_LITE}
    if Item.CategoryName = 'Other' then
    begin
      b.Enabled := False;
      b.Hint := b.Hint + #13#10 + 'This feature is not available in FreeReport';
    end;
    {$ENDIF}
  end;

begin
  { add category buttons }
  for i := frxObjects.Count - 1 downto 0 do
  begin
    Item := frxObjects[i];
    if (Item.ButtonBmp <> nil) and (Item.ButtonImageIndex = -1) then
    begin
      frxResources.SetObjectImages(Item.ButtonBmp);
      Item.ButtonImageIndex := frxResources.ObjectImages.Count - 1;
    end;
    if Item.ClassRef = nil then
      CreateButton(i, Item);
  end;

  { add object buttons }
  for i := frxObjects.Count - 1 downto 0 do
  begin
    Item := frxObjects[i];
    if (Item.ButtonBmp <> nil) and (Item.ButtonImageIndex = -1) then
    begin
      frxResources.SetObjectImages(Item.ButtonBmp);
      Item.ButtonImageIndex := frxResources.ObjectImages.Count - 1;
    end;

    if (Item.ClassRef <> nil) and (Item.CategoryName = '') then
      CreateButton(i, Item);
  end;

  ObjectBandB := TToolButton.Create(Self);
  with ObjectBandB do
  begin
    Parent := ObjectsTB1;
    Tag := 1000;
    Grouped := True;
    ImageIndex := 1;
    Style := tbsCheck;
    OnClick := ObjectBandBClick;
    Wrap := True;
  end;

  FormatToolB := TToolButton.Create(Self);
  with FormatToolB do
  begin
    Parent := ObjectsTB1;
    Tag := 1000;
    Grouped := True;
    ImageIndex := 30;
    Style := tbsCheck;
    OnClick := SelectToolBClick;
    Wrap := True;
  end;

  TextToolB := TToolButton.Create(Self);
  with TextToolB do
  begin
    Parent := ObjectsTB1;
    Tag := 1000;
    Grouped := True;
    ImageIndex := 29;
    Style := tbsCheck;
    OnClick := SelectToolBClick;
    Wrap := True;
  end;

  ZoomToolB := TToolButton.Create(Self);
  with ZoomToolB do
  begin
    Parent := ObjectsTB1;
    Tag := 1000;
    Grouped := True;
    ImageIndex := 28;
    Style := tbsCheck;
    OnClick := SelectToolBClick;
    Wrap := True;
  end;

  HandToolB := TToolButton.Create(Self);
  with HandToolB do
  begin
    Parent := ObjectsTB1;
    Tag := 1000;
    Grouped := True;
    ImageIndex := 27;
    Style := tbsCheck;
    OnClick := SelectToolBClick;
    Wrap := True;
  end;

  ObjectSelectB := TToolButton.Create(Self);
  with ObjectSelectB do
  begin
    Parent := ObjectsTB1;
    Down := True;
    Grouped := True;
    ImageIndex := 0;
    Style := tbsCheck;
    OnClick := SelectToolBClick;
    Wrap := True;
  end;
end;

procedure TfrxDesignerForm.CreateExtraToolbar;
var
  i: Integer;
  Item: TfrxWizardItem;
  b: TToolButton;
begin
  for i := 0 to frxWizards.Count - 1 do
  begin
    Item := frxWizards[i];
    if Item.IsToolbarWizard then
    begin
      b := TToolButton.Create(Self);
      with b do
      begin
        Tag := i;
        if (Item.ButtonBmp <> nil) and (Item.ButtonImageIndex = -1) then
        begin
          frxResources.SetButtonImages(Item.ButtonBmp);
          Item.ButtonImageIndex := frxResources.MainButtonImages.Count - 1;
        end;
        ImageIndex := Item.ButtonImageIndex;
        Hint := Item.ClassRef.GetDescription;
        SetBounds(1000, 0, 22, 22);
        Parent := ExtraToolsTB;
      end;
      b.OnClick := OnExtraToolClick;
    end;
  end;

  ExtraToolsTB.Height := 27;
  ExtraToolsTB.Width := 27;
end;

procedure TfrxDesignerForm.AttachDialogFormEvents(Attach: Boolean);
begin
  if Attach then
  begin
    FDialogForm.Parent := Self;
    FDialogForm.OnModify := DialogFormModify;
    FDialogForm.OnKeyDown := DialogFormKeyDown;
    FDialogForm.OnKeyUp := DialogFormKeyUp;
    FDialogForm.OnKeyPress := DialogFormKeyPress;
  end
  else
    if FDialogForm <> nil then
    begin
      FWorkspace.Parent := nil;
      FDialogForm.Parent := nil;
      FDialogForm.Hide;
      FDialogForm.OnModify := nil;
      FDialogForm.OnKeyDown := nil;
      FDialogForm.OnKeyUp := nil;
      FDialogForm.OnKeyPress := nil;
      FDialogForm := nil;
    end;
end;

procedure TfrxDesignerForm.ReloadReport;
var
  i: Integer;
  l: TList;
  c: TfrxComponent;
  p: TfrxPage;
  isDMP: Boolean;
begin
  if Report.PagesCount = 0 then
  begin
    isDMP := Report.DotMatrixReport;
//    Report.Clear;
    p := TfrxDataPage.Create(Report);
    p.Name := 'Data';
    if isDMP then
      p := TfrxDMPPage.Create(Report)
    else
      p := TfrxReportPage.Create(Report);
    p.Name := 'Page1';
  end;

  LangCB.ItemIndex := LangCB.Items.IndexOf(Report.ScriptLanguage);
  CodeWindow.Lines := Report.ScriptText;
  UpdateSyntaxType;
  ReloadPages(-2);
  UpdateRecentFiles(Report.FileName);
  UpdateCaption;
  UpdateStyles;

  FPictureCache.Clear;
  l := Report.AllObjects;
  for i := 0 to l.Count - 1 do
  begin
    c := l[i];
    if c is TfrxPictureView then
      FPictureCache.AddPicture(TfrxPictureView(c));
  end;

  FUndoBuffer.ClearUndo;
  Modified := False;
end;

procedure TfrxDesignerForm.ReloadPages(Index: Integer);
var
  i: Integer;
  c: TfrxPage;
  s: String;
begin
  FDialogForm := nil;
  FTabs.Tabs.BeginUpdate;
  FTabs.Tabs.Clear;
  FTabs.Tabs.Add(frxResources.Get('dsCode'));

  for i := 0 to Report.PagesCount - 1 do
  begin
    c := Report.Pages[i];
    c.IsDesigning := True;
    if (c is TfrxReportPage) and (TfrxReportPage(c).Subreport <> nil) then
      s := TfrxReportPage(c).Subreport.Name
    else if c is TfrxDataPage then
      s := frxResources.Get('dsData')
    else if c.Name = '' then
      s := frxResources.Get('dsPage') + IntToStr(i + 1) else
      s := c.Name;
    FTabs.Tabs.Add(s);
  end;

  FTabs.Tabs.EndUpdate;

  if Index = -1 then
    Page := nil
  else if Index = -2 then
  begin
    for i := 0 to Report.PagesCount - 1 do
    begin
      c := Report.Pages[i];
      if not (c is TfrxDataPage) then
      begin
        Page := c;
        break;
      end;
    end;
  end
  else if Index < Report.PagesCount then
    Page := Report.Pages[Index] else
    Page := Report.Pages[0];
end;

procedure TfrxDesignerForm.ReloadObjects;
var
  i: Integer;
begin
  FObjects.Clear;
  FSelectedObjects.Clear;

  for i := 0 to FPage.AllObjects.Count - 1 do
    FObjects.Add(FPage.AllObjects[i]);

  FObjects.Add(Report);
  FObjects.Add(FPage);
  FSelectedObjects.Add(FPage);
  FWorkspace.Page := FPage;
  FWorkspace.EnableUpdate;
  FWorkspace.AdjustBands;

  FInspector.EnableUpdate;

  UpdateDataTree;
  FReportTree.UpdateItems;
  OnSelectionChanged(Self);
end;

procedure TfrxDesignerForm.SetReportDefaults;
begin
  if frxDesignerComp <> nil then
  begin
    Report.ScriptLanguage := frxDesignerComp.DefaultScriptLanguage;
    frxEmptyCode(CodeWindow.Lines, Report.ScriptLanguage);
    UpdateSyntaxType;
    LangCB.ItemIndex := LangCB.Items.IndexOf(Report.ScriptLanguage);

    with TfrxReportPage(Report.Pages[1]) do
    begin
      LeftMargin := frxDesignerComp.DefaultLeftMargin;
      BottomMargin := frxDesignerComp.DefaultBottomMargin;
      RightMargin := frxDesignerComp.DefaultRightMargin;
      TopMargin := frxDesignerComp.DefaultTopMargin;
      PaperSize := frxDesignerComp.DefaultPaperSize;
      Orientation := frxDesignerComp.DefaultOrientation;
    end;
  end
  else
  begin
    Report.ScriptLanguage := 'PascalScript';
    frxEmptyCode(CodeWindow.Lines, Report.ScriptLanguage);
    UpdateSyntaxType;
    LangCB.ItemIndex := LangCB.Items.IndexOf(Report.ScriptLanguage);

    TfrxReportPage(Report.Pages[1]).SetDefaults;
  end;
end;

procedure TfrxDesignerForm.UpdatePageDimensions;
var
  h: Extended;
begin
  if FPage is TfrxReportPage then
  begin
    with FPage as TfrxReportPage do
    begin
      ScrollBox.HorzScrollBar.Position := 0;
      ScrollBox.VertScrollBar.Position := 0;

      FWorkspace.Origin := Point(10, 10);
      h := PaperHeight;
      if LargeDesignHeight then
        h := h * 5;
      FWorkspace.SetPageDimensions(
        Round(PaperWidth * 96 / 25.4),
        Round(h * 96 / 25.4),
        Rect(Round(LeftMargin * 96 / 25.4), Round(TopMargin * 96 / 25.4),
             Round(RightMargin * 96 / 25.4), Round(BottomMargin * 96 / 25.4)));
    end;
  end
  else if FPage is TfrxDataPage then
  begin
    ScrollBox.HorzScrollBar.Position := 0;
    ScrollBox.VertScrollBar.Position := 0;

    FWorkspace.Origin := Point(0, 0);
    FWorkspace.SetPageDimensions(
      Round(FPage.Width),
      Round(FPage.Height),
      Rect(0, 0, 0, 0));
  end;
end;

procedure TfrxDesignerForm.UpdateControls;
var
  c: TfrxComponent;
  p1, p2, p3: PPropInfo;
  Count: Integer;
  FontEnabled, AlignEnabled, IsReportPage: Boolean;
  Frame1Enabled, Frame2Enabled, Frame3Enabled, ObjSelected, DMPEnabled: Boolean;
  s: String;
  Frame: TfrxFrame;
  DMPFontStyle: TfrxDMPFontStyles;

  procedure SetEnabled(cAr: array of TControl; Enabled: Boolean);
  var
    i: Integer;
  begin
    for i := 0 to High(cAr) do
    begin
      cAr[i].Enabled := Enabled;
      if (cAr[i] is TToolButton) and not Enabled then
        TToolButton(cAr[i]).Down := False;
    end;
  end;

  procedure ButtonUp(cAr: array of TToolButton);
  var
    i: Integer;
  begin
    for i := 0 to High(cAr) do
      cAr[i].Down := False;
  end;

begin
  FUpdatingControls := True;

  Count := FSelectedObjects.Count;
  if Count > 0 then
  begin
    c := FSelectedObjects[0];
    p1 := GetPropInfo(PTypeInfo(c.ClassInfo), 'Font');
    p2 := GetPropInfo(PTypeInfo(c.ClassInfo), 'Frame');
    p3 := GetPropInfo(PTypeInfo(c.ClassInfo), 'Color');
  end
  else
  begin
    c := nil;
    p1 := nil;
    p2 := nil;
    p3 := nil;
  end;

  if Count = 1 then
  begin
    FontNameCB.Text := c.Font.Name;
    FontSizeCB.Text := IntToStr(c.Font.Size);

    BoldB.Down := fsBold in c.Font.Style;
    ItalicB.Down := fsItalic in c.Font.Style;
    UnderlineB.Down := fsUnderline in c.Font.Style;

    if c is TfrxCustomMemoView then
      with TfrxCustomMemoView(c) do
      begin
        TextAlignLeftB.Down := HAlign = haLeft;
        TextAlignCenterB.Down := HAlign = haCenter;
        TextAlignRightB.Down := HAlign = haRight;
        TextAlignBlockB.Down := HAlign = haBlock;

        TextAlignTopB.Down := VAlign = vaTop;
        TextAlignMiddleB.Down := VAlign = vaCenter;
        TextAlignBottomB.Down := VAlign = vaBottom;
        if not (c is TfrxDMPMemoView) then
          if Style = '' then
            StyleCB.ItemIndex := 0 else
            StyleCB.Text := Style;
      end;

    Frame := nil;
    if c is TfrxView then
      Frame := TfrxView(c).Frame
    else if c is TfrxReportPage then
      Frame := TfrxReportPage(c).Frame;

    if Frame <> nil then
      with Frame do
      begin
        FrameTopB.Down := ftTop in Typ;
        FrameBottomB.Down := ftBottom in Typ;
        FrameLeftB.Down := ftLeft in Typ;
        FrameRightB.Down := ftRight in Typ;
        ShadowB.Down := DropShadow;

        FrameWidthCB.Text := FloatToStr(Width);
      end;
  end
  else
  begin
    FontNameCB.Text := '';
    FontSizeCB.Text := '';
    FrameWidthCB.Text := '';

    ButtonUp([BoldB, ItalicB, UnderlineB, TextAlignLeftB, TextAlignCenterB,
      TextAlignRightB, TextAlignBlockB, TextAlignTopB, TextAlignMiddleB,
      TextAlignBottomB, FrameTopB, FrameBottomB, FrameLeftB,
      FrameRightB, ShadowB]);
  end;

  FontEnabled := (p1 <> nil) and not (c is TfrxDMPPage) and (FPage <> nil);
  AlignEnabled := (c is TfrxCustomMemoView) and (FPage <> nil);
  Frame1Enabled := (p2 <> nil) and not (c is TfrxLineView) and
    not (c is TfrxShapeView) and not (c is TfrxDMPPage) and (FPage <> nil);
  Frame2Enabled := (p2 <> nil) and not (c is TfrxDMPPage) and (FPage <> nil);
  Frame3Enabled := (p3 <> nil) and not (c is TfrxDMPPage) and (FPage <> nil);
  IsReportPage := FPage is TfrxReportPage;
  ObjSelected := (Count <> 0) and (FPage <> nil) and (FSelectedObjects[0] <> FPage);
  DMPEnabled := (c is TfrxDMPMemoView) or (c is TfrxDMPLineView) or
    (c is TfrxDMPCommand) or (c is TfrxDMPPage);

  SetEnabled([FontNameCB, FontSizeCB, BoldB, ItalicB, UnderlineB, FontColorB],
    (FontEnabled or (Count > 1)) and not (FPage is TfrxDMPPage));
  SetEnabled([FontB], (FontEnabled or DMPEnabled or (Count > 1)));
  SetEnabled([TextAlignLeftB, TextAlignCenterB, TextAlignRightB,
    TextAlignBlockB, TextAlignTopB, TextAlignMiddleB, TextAlignBottomB],
    AlignEnabled or (Count > 1));
  SetEnabled([StyleCB, HighlightB, RotateB],
    (AlignEnabled or (Count > 1)) and not (FPage is TfrxDMPPage));
  SetEnabled([FrameTopB, FrameBottomB, FrameLeftB, FrameRightB, FrameAllB,
    FrameNoB, ShadowB], Frame1Enabled or (Count > 1));
  SetEnabled([FrameColorB, FrameStyleB, FrameWidthCB],
    (Frame2Enabled or (Count > 1)) and not (FPage is TfrxDMPPage));
  SetEnabled([FillColorB], Frame3Enabled and not (FPage is TfrxDMPPage));
  if Report.DotMatrixReport then
  begin
    FontB.DropDownMenu := DMPPopup;
    FontB.OnClick := nil;
  end
  else
  begin
    FontB.DropDownMenu := nil;
    FontB.OnClick := ToolButtonClick;
  end;

  DMPFontStyle := [];
  if c is TfrxDMPMemoView then
    DMPFontStyle := TfrxDMPMemoView(c).FontStyle;
  if c is TfrxDMPLineView then
    DMPFontStyle := TfrxDMPLineView(c).FontStyle;
  if c is TfrxDMPPage then
    DMPFontStyle := TfrxDMPPage(c).FontStyle;

  BoldMI.Checked := fsxBold in DMPFontStyle;
  ItalicMI.Checked := fsxItalic in DMPFontStyle;
  UnderlineMI.Checked := fsxUnderline in DMPFontStyle;
  SuperScriptMI.Checked := fsxSuperScript in DMPFontStyle;
  SubScriptMI.Checked := fsxSubScript in DMPFontStyle;
  CondensedMI.Checked := fsxCondensed in DMPFontStyle;
  WideMI.Checked := fsxWide in DMPFontStyle;
  N12cpiMI.Checked := fsx12cpi in DMPFontStyle;
  N15cpiMI.Checked := fsx15cpi in DMPFontStyle;

  UndoCmd.Enabled := (FUndoBuffer.UndoCount > 1) or (FPage = nil);
  RedoCmd.Enabled := (FUndoBuffer.RedoCount > 0) and (FPage <> nil);
  CutCmd.Enabled := ((Count <> 0) and (FSelectedObjects[0] <> FPage)) or (FPage = nil);
  CopyCmd.Enabled := CutCmd.Enabled;
  TimerTimer(nil);

  PageSettingsCmd.Enabled := IsReportPage and CheckOp(drDontChangePageOptions);
  DeletePageCmd.Enabled := (Report.PagesCount > 2) and (FPage <> nil) and
    not (FPage is TfrxDataPage) and CheckOp(drDontDeletePage) and 
    not Page.IsAncestor;
  SaveCmd.Enabled := Modified and CheckOp(drDontSaveReport);
  DeleteCmd.Enabled := ObjSelected;
  SelectAllCmd.Enabled := (FObjects.Count > 2) or (FPage = nil);
  EditCmd.Enabled := (Count = 1) and (FPage <> nil);
  SetToGridB.Enabled := ObjSelected;
  BringToFrontCmd.Enabled := ObjSelected;
  SendToBackCmd.Enabled := ObjSelected;
  GroupCmd.Enabled := ObjSelected and (FSelectedObjects[0] <> Report);
  UngroupCmd.Enabled := GroupCmd.Enabled;
  ScaleCB.Enabled := IsReportPage;

  SetEnabled([HandToolB, ZoomToolB, TextToolB], IsReportPage);
  TabOrderMI.Visible := FPage is TfrxDialogPage;

  if Count <> 1 then
    s := ''
  else
  begin
    s := c.Name;
    if c is TfrxView then
      if TfrxView(c).IsDataField then
        s := s + ': ' + Report.GetAlias(TfrxView(c).DataSet) + '."' + TfrxView(c).DataField + '"'
      else if c is TfrxCustomMemoView then
        s := s + ': ' + Copy(TfrxCustomMemoView(c).Text, 1, 128);
    if c is TfrxDataBand then
      if TfrxDataBand(c).DataSet <> nil then
        s := s + ': ' + Report.GetAlias(TfrxDataBand(c).DataSet);
    if c is TfrxGroupHeader then
      s := s + ': ' + TfrxGroupHeader(c).Condition
  end;

  StatusBar.Panels[2].Text := s;

  FUpdatingControls := False;
end;

procedure TfrxDesignerForm.UpdateDataTree;
begin
  FDataTree.UpdateItems;
end;

procedure TfrxDesignerForm.UpdateStyles;
begin
  Report.Styles.GetList(StyleCB.Items);
  StyleCB.Items.Insert(0, frxResources.Get('dsNoStyle'));
end;

procedure TfrxDesignerForm.UpdateSyntaxType;
begin
  CodeWindow.Syntax := Report.ScriptLanguage;
  if CompareText(Report.ScriptLanguage, 'PascalScript') = 0 then
  begin
    OpenScriptDialog.FilterIndex := 1;
    OpenScriptDialog.DefaultExt := 'pas';
    SaveScriptDialog.FilterIndex := 1;
    SaveScriptDialog.DefaultExt := 'pas';
  end
  else if CompareText(Report.ScriptLanguage, 'C++Script') = 0 then
  begin
    OpenScriptDialog.FilterIndex := 2;
    OpenScriptDialog.DefaultExt := 'cpp';
    SaveScriptDialog.FilterIndex := 2;
    SaveScriptDialog.DefaultExt := 'cpp';
  end
  else if CompareText(Report.ScriptLanguage, 'JScript') = 0 then
  begin
    OpenScriptDialog.FilterIndex := 3;
    OpenScriptDialog.DefaultExt := 'js';
    SaveScriptDialog.FilterIndex := 3;
    SaveScriptDialog.DefaultExt := 'js';
  end
  else if CompareText(Report.ScriptLanguage, 'BasicScript') = 0 then
  begin
    OpenScriptDialog.FilterIndex := 4;
    OpenScriptDialog.DefaultExt := 'vb';
    SaveScriptDialog.FilterIndex := 4;
    SaveScriptDialog.DefaultExt := 'vb';
  end
  else
  begin
    OpenScriptDialog.FilterIndex := 5;
    OpenScriptDialog.DefaultExt := '';
    SaveScriptDialog.FilterIndex := 5;
    SaveScriptDialog.DefaultExt := '';
  end
end;

procedure TfrxDesignerForm.Lock;
begin
  FObjects.Clear;
  FSelectedObjects.Clear;
  AttachDialogFormEvents(False);
  FWorkspace.DisableUpdate;
  FInspector.DisableUpdate;
end;

procedure TfrxDesignerForm.CreateColorSelector(Sender: TToolButton);
var
  AColor: TColor;
  i: Integer;
begin
  AColor := clBlack;
  for i := 0 to SelectedObjects.Count - 1 do
    if TObject(SelectedObjects[i]) is TfrxView then
    begin
      if Sender = FontColorB then
        AColor := TfrxView(SelectedObjects[i]).Font.Color
      else if Sender = FrameColorB then
        AColor := TfrxView(SelectedObjects[i]).Frame.Color
      else
        AColor := TfrxView(SelectedObjects[i]).Color;
      break;
    end;

  with TfrxColorSelector.Create(Sender) do
  begin
    Color := AColor;
    OnColorChanged := Self.OnColorChanged;
  end;
end;

procedure TfrxDesignerForm.SwitchToCodeWindow;
begin
  Page := nil;
end;

function TfrxDesignerForm.AskSave: Word;
begin
  if IsPreviewDesigner then
    Result := frxConfirmMsg(frxResources.Get('dsSavePreviewChanges'), mb_YesNoCancel)
  else
    Result := frxConfirmMsg(frxResources.Get('dsSaveChangesTo') + ' ' +
      GetReportName + '?', mb_YesNoCancel);
end;

function TfrxDesignerForm.CheckOp(Op: TfrxDesignerRestriction): Boolean;
begin
  Result := True;
  if (frxDesignerComp <> nil) and (Op in frxDesignerComp.Restrictions) then
    Result := False;
end;

function TfrxDesignerForm.GetPageIndex: Integer;
begin
  Result := Report.Objects.IndexOf(FPage);
end;

function TfrxDesignerForm.GetReportName: String;
begin
  if Report.FileName = '' then
    Result := 'Untitled.fr3' else
    Result := ExtractFileName(Report.FileName);
end;

procedure TfrxDesignerForm.LoadFile(FileName: String; UseOnLoadEvent: Boolean);
var
  SaveSilentMode: Boolean;

  function SaveCurrentFile: Boolean;
  var
    w: Word;
  begin
    Result := True;
    if Modified then
    begin
      w := AskSave;
      if w = mrYes then
        SaveFile(False, UseOnLoadEvent)
      else if w = mrCancel then
        Result := False;
    end;
  end;

  procedure EmptyReport;
  var
    p: TfrxPage;
  begin
    Report.Clear;
    p := TfrxDataPage.Create(Report);
    p.Name := 'Data';
    p := TfrxReportPage.Create(Report);
    p.Name := 'Page1';
  end;

  procedure Error;
  begin
    frxErrorMsg(frxResources.Get('dsCantLoad'));
  end;

begin
  SaveSilentMode := Report.EngineOptions.SilentMode;
  Report.EngineOptions.SilentMode := False;

  if FileName <> '' then  // call from recent filelist
  begin
    if SaveCurrentFile then
    begin
      Lock;
      try
        if not Report.LoadFromFile(FileName) then
          Error;
      except
        EmptyReport;
      end;
    end;
    Report.EngineOptions.SilentMode := SaveSilentMode;
    ReloadReport;
    Exit;
  end;

  if UseOnLoadEvent then
    if (frxDesignerComp <> nil) and Assigned(frxDesignerComp.FOnLoadReport) then
    begin
      Lock;
      if frxDesignerComp.FOnLoadReport(Report) then
        ReloadReport else
        ReloadPages(-2);
      Report.EngineOptions.SilentMode := SaveSilentMode;
      Exit;
    end;

  if frxDesignerComp <> nil then
    OpenDialog.InitialDir := frxDesignerComp.OpenDir;
  if OpenDialog.Execute then
  begin
    if SaveCurrentFile then
    begin
      Lock;
      try
        Report.LoadFromFile(OpenDialog.FileName);
      except
        Error;
        EmptyReport;
      end;
    end;
    Report.EngineOptions.SilentMode := SaveSilentMode;
    ReloadReport;
  end;
end;

procedure TfrxDesignerForm.SaveFile(SaveAs: Boolean; UseOnSaveEvent: Boolean);
var
  Saved: Boolean;
begin
  Report.ScriptText := CodeWindow.Lines;
  Report.ReportOptions.LastChange := Now;

  if UseOnSaveEvent then
    if (frxDesignerComp <> nil) and Assigned(frxDesignerComp.FOnSaveReport) then
    begin
      if frxDesignerComp.FOnSaveReport(Report, SaveAs) then
      begin
        UpdateRecentFiles(Report.FileName);
        UpdateCaption;
        Modified := False;
      end;
      Exit;
    end;

  Saved := True;
  if SaveAs or (Report.FileName = '') then
  begin
    SaveDialog.DefaultExt := 'fr3';
    SaveDialog.Filter := frxResources.Get('dsRepFilter');
    if frxCompressorClass <> nil then
      SaveDialog.Filter := SaveDialog.Filter + '|' + frxResources.Get('dsComprRepFilter');
    if Report.ReportOptions.Compressed then
      SaveDialog.FilterIndex := 2 else
      SaveDialog.FilterIndex := 1;
    if frxDesignerComp <> nil then
      SaveDialog.InitialDir := frxDesignerComp.SaveDir;
    Saved := SaveDialog.Execute;
    if Saved then
    begin
      Report.ReportOptions.Compressed := SaveDialog.FilterIndex = 2;
      Report.FileName := SaveDialog.FileName;
      Report.SaveToFile(Report.FileName);
    end
  end
  else
    Report.SaveToFile(Report.FileName);

  UpdateRecentFiles(Report.FileName);
  UpdateCaption;
  if Saved then
    Modified := False;
end;

procedure TfrxDesignerForm.UpdateCaption;
begin
{$IFDEF FR_LITE}
  Caption := 'FreeReport - ' + GetReportName;
{$ELSE}
  Caption := 'FastReport - ' + GetReportName;
{$ENDIF}
end;

procedure TfrxDesignerForm.UpdateRecentFiles(NewFile: String);
var
  i: Integer;
  m: TMenuItem;
begin
  if NewFile <> '' then
  begin
    if FRecentFiles.IndexOf(NewFile) <> -1 then
      FRecentFiles.Delete(FRecentFiles.IndexOf(NewFile));
    FRecentFiles.Add(NewFile);
    while FRecentFiles.Count > 8 do
      FRecentFiles.Delete(0);
  end;

  SepMI11.Visible := FRecentFiles.Count <> 0;

  for i := FileMenu.Count - 1 downto 0 do
  begin
    m := FileMenu.Items[i];
    if m.Tag = 100 then
      m.Free;
  end;

  if CheckOp(drDontShowRecentFiles) then
    for i := FRecentFiles.Count - 1 downto 0 do
    begin
      m := TMenuItem.Create(FileMenu);
      m.Caption := FRecentFiles[i];
      m.OnClick := OpenRecentFile;
      m.Tag := 100;
      FileMenu.Insert(FileMenu.IndexOf(SepMI4), m);
    end;
end;

procedure TfrxDesignerForm.SwitchToolbar;
var
  i: Integer;
  Item: TfrxObjectItem;
  b: TToolButton;
  IsToolandBand, IsReportComponent, IsDialogControl,
  IsDataComponent, IsDMPComponent: Boolean;

  function IsDialogCategory(Category: Integer): Boolean;
  var
    i: Integer;
    Item: TfrxObjectItem;
  begin
    Result := False;
    for i := 0 to frxObjects.Count - 1 do
    begin
      Item := frxObjects[i];
      if (Item.ClassRef <> nil) and
         (Item.CategoryName = frxObjects[Category].CategoryName) then
      begin
        Result := Item.ClassRef.InheritsFrom(TfrxDialogControl);
        break;
      end;
    end;
  end;

  function IsDataCategory(Category: Integer): Boolean;
  var
    i: Integer;
    Item: TfrxObjectItem;
  begin
    Result := False;
    if Category = 1000 then Exit;
    for i := 0 to frxObjects.Count - 1 do
    begin
      Item := frxObjects[i];
      if (Item.ClassRef <> nil) and
         (Item.CategoryName = frxObjects[Category].CategoryName) then
      begin
        Result := Item.ClassRef.InheritsFrom(TfrxDialogComponent);
        break;
      end;
    end;
  end;

begin
  ObjectSelectB.Down := True;
  SelectToolBClick(nil);

  for i := ObjectsTB1.ControlCount - 1 downto 0 do
  begin
    b := TToolButton(ObjectsTB1.Controls[i]);

    if b <> ObjectSelectB then
    begin
      Item := nil;

      IsToolandBand := False;
      IsReportComponent := False;
      IsDialogControl := False;
      IsDataComponent := False;
      IsDMPComponent := False;

      if b.Tag = 1000 then  { tools and band }
        IsToolandBand := True
      else                  { object or category }
      begin
        Item := frxObjects[b.Tag];
        if Item.ClassRef <> nil then  { object }
        begin
          IsDialogControl := Item.ClassRef.InheritsFrom(TfrxDialogControl);
          IsDataComponent := Item.ClassRef.InheritsFrom(TfrxDialogComponent);
        end
        else
        begin
          IsDialogControl := IsDialogCategory(b.Tag);
          IsDataComponent := IsDataCategory(b.Tag);
        end;
        IsDMPComponent := Item.IsDMPObject;
        if not (IsDialogControl or IsDataComponent) then
          IsReportComponent := Item.IsReportObject;
      end;

      if FPage is TfrxDialogPage then
        b.Visible := IsDialogControl
      else if FPage is TfrxDMPPage then
        b.Visible := IsDMPComponent or IsToolandBand
      else if FPage is TfrxReportPage then
        b.Visible := IsReportComponent or IsToolandBand
      else if FPage is TfrxDataPage then
      begin
        b.Visible := IsDataComponent or
          ((Item <> nil) and
            (((Item.ClassRef <> nil) and (Item.ClassRef.ClassName = 'TfrxMemoView'))
             or
            (Item.CategoryName = 'Draw')));
      end;
    end;
  end;
end;

function TfrxDesignerForm.mmToUnits(mm: Extended; X: Boolean = True): Extended;
begin
  Result := 0;
  case FUnits of
    duCM:
      Result := mm / 10;
    duInches:
      Result := mm / 25.4;
    duPixels:
      Result := mm * 96 / 25.4;
    duChars:
      if X then
        Result := Round(mm * fr01cm / fr1CharX) else
        Result := Round(mm * fr01cm / fr1CharY);
  end;
end;

function TfrxDesignerForm.UnitsTomm(mm: Extended; X: Boolean = True): Extended;
begin
  Result := 0;
  case FUnits of
    duCM:
      Result := mm * 10;
    duInches:
      Result := mm * 25.4;
    duPixels:
      Result := mm / 96 * 25.4;
    duChars:
      if X then
        Result := Round(mm) * fr1CharX / fr01cm  else
        Result := Round(mm) * fr1CharY / fr01cm;
  end;
end;

function TfrxDesignerForm.InsertExpression(const Expr: String): String;
begin
  with TfrxExprEditorForm.Create(Self) do
  begin
    ExprMemo.Text := Expr;
    if ShowModal = mrOk then
      Result := ExprMemo.Text else
      Result := '';
    Free;
  end
end;

procedure TfrxDesignerForm.UpdatePage;
begin
  FWorkspace.Repaint;
end;

procedure TfrxDesignerForm.FindText;
var
  i: Integer;
  c: TfrxComponent;
  s: String;
  Found, FoundOne: Boolean;
  Flags: TReplaceFlags;
  ReplaceAll: Boolean;

  function AskReplace: Boolean;
  var
    i: Integer;
  begin
    if not ReplaceAll then
      i := MessageDlg(Format(frxResources.Get('dsReplace'), [FSearchText]),
        mtConfirmation, [mbYes, mbNo, mbCancel, mbAll], 0)
    else
      i := mrAll;
    Result := i in [mrYes, mrAll];
    ReplaceAll := i = mrAll;

{    Result := Application.MessageBox(
      PChar(Format(frxResources.Get('dsReplace'), [FSearchText])),
      PChar(frxResources.Get('mbConfirm')), mb_IconQuestion + mb_YesNo) = mrYes;}
  end;

begin
  ReplaceAll := False;
  FoundOne := False;

  repeat
    Found := False;
    if FPage <> nil then
    begin
      c := nil;
      for i := FSearchIndex to Objects.Count - 1 do
      begin
        c := Objects[i];
        if c is TfrxCustomMemoView then
        begin
          s := TfrxCustomMemoView(c).Text;
          if FSearchCase then
          begin
            if Pos(FSearchText, s) <> 0 then
              Found := True;
          end
          else if Pos(AnsiUpperCase(FSearchText), AnsiUpperCase(s)) <> 0 then
            Found := True;
        end;
        if Found then break;
      end;

      if Found then
      begin
        FSearchIndex := i + 1;
        SelectedObjects.Clear;
        SelectedObjects.Add(c);
        OnSelectionChanged(Self);
        if FSearchReplace then
          if AskReplace then
          begin
            Flags := [rfReplaceAll];
            if not FSearchCase then
              Flags := Flags + [rfIgnoreCase];
            TfrxCustomMemoView(c).Text := StringReplace(s, FSearchText,
              FSearchReplaceText, Flags);
            Modified := True;
          end;
      end;
    end
    else
    begin
      Found := CodeWindow.Find(FSearchText, FSearchCase, FSearchIndex);
      if FSearchReplace then
        if Found and AskReplace then
        begin
          CodeWindow.SelText := FSearchReplaceText;
          Modified := True;
        end;
    end;

    if Found then
      FoundOne := True;
  until not ReplaceAll or not Found;

  if not FoundOne then
    frxInfoMsg(Format(frxResources.Get('dsTextNotFound'), [FSearchText]));
end;

procedure TfrxDesignerForm.RestorePagePosition;
var
  pt: TPoint;
begin
  if (FTabs.TabIndex > 0) and (FTabs.TabIndex < 255) then
  begin
    pt := fsPosToPoint(FPagePositions[FTabs.TabIndex]);
    ScrollBox.VertScrollBar.Position := pt.X;
    ScrollBox.HorzScrollBar.Position := pt.Y;
  end;
end;

procedure TfrxDesignerForm.SavePagePosition;
begin
  if (FTabs.TabIndex > 0) and (FTabs.TabIndex < 255) then
    FPagePositions[FTabs.TabIndex] := IntToStr(ScrollBox.HorzScrollBar.Position) +
      ':' + IntToStr(ScrollBox.VertScrollBar.Position);
end;


{ Workspace/Inspector event handlers }
{------------------------------------------------------------------------------}

procedure TfrxDesignerForm.OnModify(Sender: TObject);
begin
  FModifiedBy := Sender;
  Modified := True;
end;

procedure TfrxDesignerForm.OnSelectionChanged(Sender: TObject);
var
  c: TfrxComponent;
begin
  if Sender = FReportTree then
  begin
    c := SelectedObjects[0];
    if (c <> Report) and (Page <> nil) then
      if c.Page <> Page then
      begin
        Page := c.Page;
        SelectedObjects[0] := c;
        FReportTree.UpdateSelection;
      end;
  end
  else
    FReportTree.UpdateSelection;

  if Sender <> FWorkspace then
    FWorkspace.UpdateView;

  if Sender <> FInspector then
  begin
    FInspector.Objects := FObjects;
    FInspector.UpdateProperties;
  end;

  FDataTree.UpdateSelection;
  UpdateControls;
end;

procedure TfrxDesignerForm.OnEditObject(Sender: TObject);
var
  ed: TfrxComponentEditor;
begin
  if FSelectedObjects[0] <> nil then
    if rfDontEdit in TfrxComponent(FSelectedObjects[0]).Restrictions then
      Exit;

  ed := frxComponentEditors.GetComponentEditor(FSelectedObjects[0], Self, nil);
  if (ed <> nil) and ed.HasEditor then
    if ed.Edit then
    begin
      Modified := True;
      if FSelectedObjects[0] = FPage then
        UpdatePageDimensions;
    end;
  ed.Free;
end;

procedure TfrxDesignerForm.OnInsertObject(Sender: TObject);
var
  c: TfrxComponent;
  SaveLeft, SaveTop, SaveWidth, SaveHeight: Extended;

  function CheckContainers(Obj: TfrxComponent): Boolean;
  var
    i: Integer;
    c: TfrxComponent;
  begin
    Result := False;
    for i := 0 to FObjects.Count - 1 do
    begin
      c := FObjects[i];
      if (c <> Obj) and (csContainer in c.frComponentStyle) then
        if (Obj.Left >= c.AbsLeft) and (Obj.Top >= c.AbsTop) and
          (Obj.Left + Obj.Width <= c.AbsLeft + c.Width) and
          (Obj.Top + Obj.Height <= c.AbsTop + c.Height) then
      begin
        Result := c.ContainerAdd(Obj);
        break;
      end;
    end;
  end;

begin
  if not CheckOp(drDontInsertObject) or (FWorkspace.Insertion.Top < 0) then
  begin
    FWorkspace.SetInsertion(nil, 0, 0, 0);
    ObjectSelectB.Down := True;
    Exit;
  end;

  with FWorkspace.Insertion do
  begin
    if (ComponentClass = nil) or ((Width = 0) and (Height = 0)) then Exit;

    SaveLeft := Left;
    SaveTop := Top;
    SaveWidth := Width;
    SaveHeight := Height;
    c := TfrxComponent(ComponentClass.NewInstance);
    c.DesignCreate(FPage, Flags);
    c.SetBounds(SaveLeft, SaveTop, SaveWidth, SaveHeight);
    c.CreateUniqueName;
    if c is TfrxCustomLineView then
      FWorkspace.SetInsertion(ComponentClass, 0, 0, Flags)
    else
    begin
      FWorkspace.SetInsertion(nil, 0, 0, 0);
      if not TextToolB.Down then
        ObjectSelectB.Down := True;
    end;

    if c is TfrxCustomMemoView then
    begin
      FSampleFormat.ApplySample(TfrxCustomMemoView(c));
      if FPage is TfrxDataPage then
        TfrxCustomMemoView(c).Wysiwyg := False;
    end;

    if not CheckContainers(c) then
      FObjects.Add(c);
    FSelectedObjects.Clear;
    FSelectedObjects.Add(c);

    if (frxDesignerComp <> nil) and Assigned(frxDesignerComp.FOnInsertObject) then
      frxDesignerComp.FOnInsertObject(c);

    if c is TfrxSubreport then
    begin
      NewPageCmdExecute(Self);
      TfrxSubreport(c).Page := TfrxReportPage(Report.Pages[Report.PagesCount - 1]);
      ReloadPages(Report.PagesCount - 1);
    end
    else
    begin
      Modified := True;
      if EditAfterInsert and not
        ((c is TfrxDialogControl) or (c is TfrxDialogComponent)) then
        OnEditObject(Self);
    end;

    FWorkspace.BringToFront;
  end;
end;

procedure TfrxDesignerForm.OnNotifyPosition(ARect: TfrxRect);
var
  dx, dy: Extended;
begin
  with ARect do
  begin
    if FUnits = duCM then
    begin
      dx := 1 / 96 * 2.54;
      dy := dx;
    end
    else if FUnits = duChars then
    begin
      dx := 1 / fr1CharX;
      dy := 1 / fr1CharY;
    end
    else if FUnits = duPixels then
    begin
      dx := 1;
      dy := dx;
    end
    else
    begin
      dx := 1 / 96;
      dy := dx;
    end;

    Left := Left * dx;
    Top := Top * dy;
    if FWorkspace.Mode <> dmScale then
    begin
      Right := Right * dx;
      Bottom := Bottom * dy;
    end;

    if FUnits = duChars then
    begin
      Left := Trunc(Left);
      Top := Trunc(Top);
      Right := Trunc(Right);
      Bottom := Trunc(Bottom);
    end;


    FCoord1 := '';
    FCoord2 := '';
    FCoord3 := '';
    if (not FWorkspace.IsMouseDown) and (FWorkspace.Mode <> dmInsertObject) then
      if (FSelectedObjects.Count > 0) and (FSelectedObjects[0] = FPage) then
        FCoord1 := Format('%f; %f', [Left, Top])
      else
      begin
        FCoord1 := Format('%f; %f', [Left, Top]);
        FCoord2 := Format('%f; %f', [Right, Bottom]);
      end
    else
    case FWorkspace.Mode of
      dmMove, dmSize, dmSizeBand, dmInsertObject, dmInsertLine:
        begin
          FCoord1 := Format('%f; %f', [Left, Top]);
          FCoord2 := Format('%f; %f', [Right, Bottom]);
        end;

      dmScale:
        begin
          FCoord1 := Format('%f; %f', [Left, Top]);
          FCoord3 := Format('%s%f; %s%f', ['%', Right * 100, '%', Bottom * 100]);
        end;
    end;
  end;

  LeftRuler.Position := ARect.Top;
  TopRuler.Position := ARect.Left;

  if FPage = nil then
    OnChangePosition(Self);  

  StatusBar.Repaint;
end;


{ Toolbar buttons' events }
{------------------------------------------------------------------------------}

procedure TfrxDesignerForm.SelectToolBClick(Sender: TObject);
var
  t: TfrxDesignTool;
begin
  t := dtSelect;
  if HandToolB.Down then
    t := dtHand
  else if ZoomToolB.Down then
    t := dtZoom
  else if TextToolB.Down then
    t := dtText
  else if FormatToolB.Down then
    t := dtFormat;

  TDesignerWorkspace(FWorkspace).Tool := t;
  FWorkspace.SetInsertion(nil, 0, 0, 0);
end;

procedure TfrxDesignerForm.ObjectBandBClick(Sender: TObject);
var
  pt: TPoint;
begin
  pt := TControl(Sender).ClientToScreen(Point(TControl(Sender).Width, 0));
  BandsPopup.Popup(pt.X, pt.Y);
end;

procedure TfrxDesignerForm.ObjectsButtonClick(Sender: TObject);
var
  i: Integer;
  Obj, Item: TfrxObjectItem;
  c: TfrxComponent;
  dx, dy: Extended;
  m: TMenuItem;
  pt: TPoint;
  s: String;
begin
  SelectToolBClick(Sender);
  if Page = nil then Exit;
  Obj := frxObjects[TComponent(Sender).Tag];

  if Obj.ClassRef = nil then  { it's a category }
  begin
    while ObjectsPopup.Items.Count > 0 do
      ObjectsPopup.Items[0].Free;

    for i := 0 to frxObjects.Count - 1 do
    begin
      Item := frxObjects[i];
      if (Item.ClassRef <> nil) and (Item.CategoryName = Obj.CategoryName) then
      begin
        if FPage is TfrxDMPPage then
          if not ((Item.ClassRef.ClassName = 'TfrxCrossView') or
            (Item.ClassRef.ClassName = 'TfrxDBCrossView') or
            (Item.ClassRef.InheritsFrom(TfrxDialogComponent))) then continue;

        m := TMenuItem.Create(ObjectsPopup);
        m.ImageIndex := Item.ButtonImageIndex;
        s := Item.ButtonHint;
        if s = '' then
          s := Item.ClassRef.GetDescription else
          s := frxResources.Get(s);
        m.Caption := s;
        m.OnClick := ObjectsButtonClick;
        m.Tag := i;
        ObjectsPopup.Items.Add(m);
      end;
    end;

    pt := TControl(Sender).ClientToScreen(Point(TControl(Sender).Width, 0));
    ObjectsPopup.Popup(pt.X, pt.Y);
  end
  else  { it's a simple object }
  begin
    c := TfrxComponent(Obj.ClassRef.NewInstance);
    c.Create(FPage);
    dx := c.Width;
    dy := c.Height;
    c.Free;

    if (dx = 0) and (dy = 0) then
    begin
      dx := GetDefaultObjectSize.X;
      dy := GetDefaultObjectSize.Y;
    end;

    FWorkspace.SetInsertion(Obj.ClassRef, dx, dy, Obj.Flags);
  end;
end;

procedure TfrxDesignerForm.OnExtraToolClick(Sender: TObject);
var
  w: TfrxCustomWizard;
  Item: TfrxWizardItem;
begin
  Item := frxWizards[TToolButton(Sender).Tag];
  w := TfrxCustomWizard(Item.ClassRef.NewInstance);
  w.Create(Self);
  if w.Execute then
    Modified := True;
  w.Free;
end;

procedure TfrxDesignerForm.InsertBandClick(Sender: TObject);
var
  i: Integer;
  Band: TfrxBand;
  Size: Extended;

  function FindFreeSpace: Extended;
  var
    i: Integer;
    b: TfrxComponent;
  begin
    Result := 0;
    for i := 0 to FPage.Objects.Count - 1 do
    begin
      b := FPage.Objects[i];
      if (b is TfrxBand) and not TfrxBand(b).Vertical then
        if b.Top + b.Height > Result then
          Result := b.Top + b.Height;
    end;

    Result := Round((Result + Workspace.BandHeader + 4) / Workspace.GridY) * Workspace.GridY;
    Result := Round(Result * 100000000) / 100000000;
  end;

begin
  if Page = nil then Exit;

  i := (Sender as TMenuItem).Tag;

  Band := TfrxBand(frxBands[i mod 100].NewInstance);
  Band.Create(FPage);
  Band.CreateUniqueName;
  if i >= 100 then
    Band.Vertical := True;

  if not Band.Vertical then
    if Workspace.FreeBandsPlacement then
      Band.Top := FindFreeSpace else
      Band.Top := 10000;

  Size := 0;
  case FUnits of
    duCM:     Size := fr01cm * 6;
    duInches: Size := fr01in * 3;
    duPixels: Size := 20;
    duChars:  Size := fr1CharY;
  end;

  if not Band.Vertical then
    Band.Height := Size
  else
  begin
    Band.Left := Size;
    Band.Width := Size;
  end;

  FObjects.Add(Band);
  FSelectedObjects.Clear;
  FSelectedObjects.Add(Band);
  Modified := True;
  OnSelectionChanged(Self);

  ObjectSelectB.Down := True;
  SelectToolBClick(Sender);

  if EditAfterInsert then
    OnEditObject(Self);
end;

procedure TfrxDesignerForm.ToolbarsMIClick(Sender: TObject);

  procedure SetShow(c: array of TWinControl; i: Integer; b: Boolean);
  begin
    c[i].ManualDock(nil);
    c[i].Visible := b;
  end;

begin
  with Sender as TMenuItem do
  begin
    Checked := not Checked;
    SetShow([StandardTB, TextTB, FrameTB, AlignTB, ExtraToolsTB, FInspector,
      FDataTree, FReportTree], Tag, Checked);
  end;
end;

procedure TfrxDesignerForm.ShowRulersMIClick(Sender: TObject);
begin
  ShowRulersMI.Checked := not ShowRulersMI.Checked;
  ShowRulers := ShowRulersMI.Checked;
end;

procedure TfrxDesignerForm.ShowGuidesMIClick(Sender: TObject);
begin
  ShowGuidesMI.Checked := not ShowGuidesMI.Checked;
  ShowGuides := ShowGuidesMI.Checked;
end;

procedure TfrxDesignerForm.DeleteGuidesMIClick(Sender: TObject);
begin
  if FPage is TfrxReportPage then
  begin
    TfrxReportPage(FPage).ClearGuides;
    FWorkspace.Invalidate;
    Modified := True;
  end;
end;

procedure TfrxDesignerForm.ToolButtonClick(Sender: TObject);
var
  i: Integer;
  c: TfrxComponent;
  wasModified: Boolean;
  gx, gy: Extended;
  TheFont: TFont;

  procedure EditFont;
  begin
    with TFontDialog.Create(Application) do
    begin
      Font := TfrxComponent(FSelectedObjects[0]).Font;
      Options := Options + [fdForceFontExist];
      if Execute then
      begin
        TheFont := TFont.Create;
        TheFont.Assign(Font);
      end;
      Free;
    end;
  end;

  procedure SetFontStyle(c: TfrxComponent; fStyle: TFontStyle; Include: Boolean);
  begin
    with c.Font do
      if Include then
        Style := Style + [fStyle] else
        Style := Style - [fStyle];
  end;

  procedure SetFrameType(c: TfrxComponent; fType: TfrxFrameType; Include: Boolean);
  var
    f: TfrxFrame;
  begin
    if c is TfrxView then
      f := TfrxView(c).Frame
    else if c is TfrxReportPage then
      f := TfrxReportPage(c).Frame else
      Exit;

     with f do
      if Include then
        Typ := Typ + [fType] else
        Typ := Typ - [fType];
  end;

  procedure SetDMPFontStyle(c: TfrxComponent; fStyle: TfrxDMPFontStyle;
    Include: Boolean);
  var
    Style: TfrxDMPFontStyles;
  begin
    Style := [];
    if c is TfrxDMPMemoView then
      Style := TfrxDMPMemoView(c).FontStyle;
    if c is TfrxDMPLineView then
      Style := TfrxDMPLineView(c).FontStyle;
    if c is TfrxDMPPage then
      Style := TfrxDMPPage(c).FontStyle;
    if not Include then
      Style := Style + [fStyle] else
      Style := Style - [fStyle];
    if c is TfrxDMPMemoView then
      TfrxDMPMemoView(c).FontStyle := Style;
    if c is TfrxDMPLineView then
      TfrxDMPLineView(c).FontStyle := Style;
    if c is TfrxDMPPage then
      TfrxDMPPage(c).FontStyle := Style;
  end;

begin
  if FUpdatingControls then Exit;

  TheFont := nil;
  wasModified := False;
  if TComponent(Sender).Tag = 43 then
    EditFont;

  for i := 0 to FSelectedObjects.Count - 1 do
  begin
    c := FSelectedObjects[i];
    if rfDontModify in c.Restrictions then continue;

    case TComponent(Sender).Tag of

      0:  c.Font.Name := FontNameCB.Text;

      1:  c.Font.Size := StrToInt(FontSizeCB.Text);

      2:  SetFontStyle(c, fsBold, BoldB.Down);

      3:  SetFontStyle(c, fsItalic, ItalicB.Down);

      4:  SetFontStyle(c, fsUnderline, UnderlineB.Down);

      5:  c.Font.Color := FColor;

      6:;

      7..10:
          if c is TfrxCustomMemoView then
            with TfrxCustomMemoView(c) do
              if TextAlignLeftB.Down then
                HAlign := haLeft
              else if TextAlignCenterB.Down then
                HAlign := haCenter
              else if TextAlignRightB.Down then
                HAlign := haRight
              else
                HAlign := haBlock;

      11..13:
          if c is TfrxCustomMemoView then
            with TfrxCustomMemoView(c) do
              if TextAlignTopB.Down then
                VAlign := vaTop
              else if TextAlignMiddleB.Down then
                VAlign := vaCenter
              else
                VAlign := vaBottom;

      20: SetFrameType(c, ftTop, FrameTopB.Down);

      21: SetFrameType(c, ftBottom, FrameBottomB.Down);

      22: SetFrameType(c, ftLeft, FrameLeftB.Down);

      23: SetFrameType(c, ftRight, FrameRightB.Down);

      24: begin
            SetFrameType(c, ftTop, True);
            SetFrameType(c, ftBottom, True);
            SetFrameType(c, ftLeft, True);
            SetFrameType(c, ftRight, True);
          end;

      25: begin
            SetFrameType(c, ftTop, False);
            SetFrameType(c, ftBottom, False);
            SetFrameType(c, ftLeft, False);
            SetFrameType(c, ftRight, False);
          end;

      26: if c is TfrxView then
            TfrxView(c).Color := FColor
          else if c is TfrxReportPage then
            TfrxReportPage(c).Color := FColor
          else if c is TfrxDialogPage then
          begin
            TfrxDialogPage(c).Color := FColor;
            FWorkspace.Color := FColor;
          end
          else if c is TfrxDialogControl then
            TfrxDialogControl(c).Color := FColor;

      27: if c is TfrxView then
            TfrxView(c).Frame.Color := FColor
          else if c is TfrxReportPage then
            TfrxReportPage(c).Frame.Color := FColor;

      28: if c is TfrxView then
            TfrxView(c).Frame.Style := FLineStyle
          else if c is TfrxReportPage then
            TfrxReportPage(c).Frame.Style := FLineStyle;

      29: if c is TfrxView then
            TfrxView(c).Frame.Width := frxStrToFloat(FrameWidthCB.Text)
          else if c is TfrxReportPage then
            TfrxReportPage(c).Frame.Width := frxStrToFloat(FrameWidthCB.Text);

      30: if c is TfrxCustomMemoView then
            TfrxCustomMemoView(c).Rotation := TMenuItem(Sender).HelpContext;

      31:
        begin
          gx := FWorkspace.GridX;
          gy := FWorkspace.GridY;
          c.Left := Round(c.Left / gx) * gx;
          c.Top := Round(c.Top / gy) * gy;
          c.Width := Round(c.Width / gx) * gx;
          c.Height := Round(c.Height / gy) * gy;
          if c.Width = 0 then
            c.Width := gx;
          if c.Height = 0 then
            c.Height := gy;
        end;

      32: if c is TfrxView then
            TfrxView(c).Frame.DropShadow := ShadowB.Down
          else if c is TfrxReportPage then
            TfrxReportPage(c).Frame.DropShadow := ShadowB.Down;

      33: if c is TfrxCustomMemoView then
            if StyleCB.ItemIndex = 0 then
              TfrxCustomMemoView(c).Style := '' else
              TfrxCustomMemoView(c).Style := StyleCB.Text;

      34: SetDMPFontStyle(c, fsxBold, BoldMI.Checked);

      35: SetDMPFontStyle(c, fsxItalic, ItalicMI.Checked);

      36: SetDMPFontStyle(c, fsxUnderline, UnderlineMI.Checked);

      37: SetDMPFontStyle(c, fsxSuperScript, SuperScriptMI.Checked);

      38: SetDMPFontStyle(c, fsxSubScript, SubScriptMI.Checked);

      39: SetDMPFontStyle(c, fsxCondensed, CondensedMI.Checked);

      40: SetDMPFontStyle(c, fsxWide, WideMI.Checked);

      41: SetDMPFontStyle(c, fsx12cpi, N12cpiMI.Checked);

      42: SetDMPFontStyle(c, fsx15cpi, N15cpiMI.Checked);

      43: if TheFont <> nil then
            c.Font := TheFont;
    end;

    if TComponent(Sender).Tag in [0..5, 20..29, 32] then
      if c is TfrxCustomMemoView then
      begin
        TfrxCustomMemoView(c).Style := '';
        StyleCB.ItemIndex := 0;
      end;

    if c is TfrxCustomMemoView then
      FSampleFormat.SetAsSample(TfrxCustomMemoView(c));
    wasModified := True;
  end;

  if TheFont <> nil then
    TheFont.Free;

  ScrollBox.SetFocus;
  if wasModified then
  begin
    FModifiedBy := Self;
    Modified := True;

    if TComponent(Sender).Tag in [24, 25, 34..43] then
      UpdateControls;
  end;
end;

procedure TfrxDesignerForm.FontColorBClick(Sender: TObject);
begin
  CreateColorSelector(Sender as TToolButton);
end;

procedure TfrxDesignerForm.FrameStyleBClick(Sender: TObject);
begin
  with TfrxLineSelector.Create(TComponent(Sender)) do
    OnStyleChanged := Self.OnStyleChanged;
end;

procedure TfrxDesignerForm.ScaleCBClick(Sender: TObject);
var
  s: String;
  dx, dy: Integer;
begin
  if ScaleCB.ItemIndex = 6 then
    s := IntToStr(Round((ScrollBox.Width - 40) / (TfrxReportPage(FPage).PaperWidth * 96 / 25.4) * 100))
  else if ScaleCB.ItemIndex = 7 then
  begin
    dx := Round(TfrxReportPage(FPage).PaperWidth * 96 / 25.4);
    dy := Round(TfrxReportPage(FPage).PaperHeight * 96 / 25.4);
    if (ScrollBox.Width - 20) / dx < (ScrollBox.Height - 20) / dy then
      s := IntToStr(Round((ScrollBox.Width - 20) / dx * 100)) else
      s := IntToStr(Round((ScrollBox.Height - 20) / dy * 100));
  end
  else
    s := ScaleCB.Text;

  if Pos('%', s) <> 0 then
    s[Pos('%', s)] := ' ';
  while Pos(' ', s) <> 0 do
    Delete(s, Pos(' ', s), 1);

  if s <> '' then
  begin
    Scale := frxStrToFloat(s) / 100;
    ScaleCB.Text := s + '%';
    ScrollBox.SetFocus;
  end;
end;

procedure TfrxDesignerForm.ShowGridBClick(Sender: TObject);
begin
  ShowGrid := ShowGridB.Down;
end;

procedure TfrxDesignerForm.AlignToGridBClick(Sender: TObject);
begin
  GridAlign := AlignToGridB.Down;
end;

procedure TfrxDesignerForm.LangCBClick(Sender: TObject);
begin
  if frxConfirmMsg(frxResources.Get('dsClearScript'), mb_YesNo) <> mrYes then
  begin
    LangCB.ItemIndex := LangCB.Items.IndexOf(Report.ScriptLanguage);
    Exit;
  end;

  Report.ScriptLanguage := LangCB.Text;
  frxEmptyCode(CodeWindow.Lines, Report.ScriptLanguage);

  UpdateSyntaxType;
  Modified := True;
  CodeWindow.SetFocus;
end;

procedure TfrxDesignerForm.OpenScriptBClick(Sender: TObject);
begin
  with OpenScriptDialog do
    if Execute then
    begin
      CodeWindow.Lines.LoadFromFile(FileName);
      Modified := True;
    end;
end;

procedure TfrxDesignerForm.SaveScriptBClick(Sender: TObject);
begin
  with SaveScriptDialog do
    if Execute then
      CodeWindow.Lines.SaveToFile(FileName);
end;

procedure TfrxDesignerForm.HighlightBClick(Sender: TObject);
var
  i: Integer;
begin
  with TfrxHighlightEditorForm.Create(Self) do
  begin
    MemoView := SelectedObjects[0];
    if ShowModal = mrOk then
    begin
      for i := 1 to SelectedObjects.Count - 1 do
        if TObject(SelectedObjects[i]) is TfrxMemoView then
          TfrxMemoView(SelectedObjects[i]).Highlight.Assign(MemoView.Highlight);

      Modified := True;
    end;
    Free;
  end;
end;


{ Controls' event handlers }
{------------------------------------------------------------------------------}

procedure TfrxDesignerForm.OnCodeChanged(Sender: TObject);
begin
  if FPage = nil then
  begin
    FModified := True;
    SaveCmd.Enabled := True;
  end;
end;

procedure TfrxDesignerForm.OnChangePosition(Sender: TObject);
begin
  if FPage = nil then
  begin
    FCoord1 := Format('%d; %d', [CodeWindow.GetPos.Y, CodeWindow.GetPos.X]);
    FCoord2 := '';
    FCoord3 := '';
  end;
  StatusBar.Repaint;
end;

procedure TfrxDesignerForm.OnColorChanged(Sender: TObject);
begin
  with TfrxColorSelector(Sender) do
  begin
    FColor := Color;
    ToolButtonClick(TfrxColorSelector(Sender));
  end;
end;

procedure TfrxDesignerForm.OnStyleChanged(Sender: TObject);
begin
  with TfrxLineSelector(Sender) do
  begin
    FLineStyle := TfrxFrameStyle(Style);
    ToolButtonClick(TfrxLineSelector(Sender));
  end;
end;

procedure TfrxDesignerForm.ScrollBoxMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  with ScrollBox.VertScrollBar do
    Position := Position - 16;
end;

procedure TfrxDesignerForm.ScrollBoxMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  with ScrollBox.VertScrollBar do
    Position := Position + 16;
end;

procedure TfrxDesignerForm.ScrollBoxResize(Sender: TObject);
var
  ofs, st: Integer;
begin
  if FWorkspace = nil then Exit;
  if FWorkspace.Left < 0 then
  begin
    ofs := ScrollBox.Left + 2;
    st := -FWorkspace.Left;
  end
  else
  begin
    ofs := ScrollBox.Left + 2 + FWorkspace.Left;
    st := 0;
  end;

  TopRuler.Offset := ofs;
  TopRuler.Start := st;

  if FWorkspace.Top < 0 then
  begin
    ofs := 2;
    st := -FWorkspace.Top;
  end
  else
  begin
    ofs := FWorkspace.Top + 2;
    st := 0;
  end;

  LeftRuler.Offset := ofs;
  LeftRuler.Start := st;
end;

procedure TfrxDesignerForm.StatusBarMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FUnitsDblClicked := X < StatusBar.Panels[0].Width;
end;

procedure TfrxDesignerForm.StatusBarDblClick(Sender: TObject);
var
  i: Integer;
begin
  if FUnitsDblClicked and not
    ((FWorkspace.GridType = gtDialog) or (FWorkspace.GridType = gtChar)) then
  begin
    i := Integer(FUnits);
    Inc(i);
    if i > 2 then
      i := 0;
    Units := TfrxDesignerUnits(i);
    FOldUnits := FUnits;
  end;
end;

procedure TfrxDesignerForm.StatusBarDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const ARect: TRect);
begin
  with StatusBar.Canvas do
  begin
    FillRect(ARect);

    if FCoord1 <> '' then
    begin
      frxResources.MainButtonImages.Draw(StatusBar.Canvas, ARect.Left + 2, ARect.Top - 1, 62);
      TextOut(ARect.Left + 20, ARect.Top + 1, FCoord1);
    end;

    if FCoord2 <> '' then
    begin
      frxResources.MainButtonImages.Draw(StatusBar.Canvas, ARect.Left + 110, ARect.Top - 1, 63);
      TextOut(ARect.Left + 130, ARect.Top + 1, FCoord2);
    end;

    if FCoord3 <> '' then
      TextOut(ARect.Left + 110, ARect.Top + 1, FCoord3);
  end;
end;

procedure TfrxDesignerForm.TimerTimer(Sender: TObject);
begin
  PasteCmd.Enabled := FClipboard.PasteAvailable or (FPage = nil);
end;

procedure TfrxDesignerForm.BandsPopupPopup(Sender: TObject);

  function FindBand(Band: TfrxComponentClass): TfrxBand;
  var
    i: Integer;
  begin
    Result := nil;
    if FPage = nil then Exit;
    for i := 0 to FPage.Objects.Count - 1 do
      if TObject(FPage.Objects[i]) is Band then
        Result := FPage.Objects[i];
  end;

begin
  ReportTitleMI.Enabled := FindBand(TfrxReportTitle) = nil;
  ReportSummaryMI.Enabled := FindBand(TfrxReportSummary) = nil;
  PageHeaderMI.Enabled := FindBand(TfrxPageHeader) = nil;
  PageFooterMI.Enabled := FindBand(TfrxPageFooter) = nil;
  ColumnHeaderMI.Enabled := FindBand(TfrxColumnHeader) = nil;
  ColumnFooterMI.Enabled := FindBand(TfrxColumnFooter) = nil;
end;

procedure TfrxDesignerForm.ToolbarsMIOpen(Sender: TObject);
begin
  StandardMI.Checked := StandardTB.Visible;
  TextMI.Checked := TextTB.Visible;
  FrameMI.Checked := FrameTB.Visible;
  AlignmentMI.Checked := AlignTB.Visible;
  ToolsMI.Checked := ExtraToolsTB.Visible;
  InspectorMI.Checked := FInspector.Visible;
  DataTreeMI.Checked := FDataTree.Visible;
  ReportTreeMI.Checked := FReportTree.Visible;
end;

procedure TfrxDesignerForm.TopRulerDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Source is TfrxDesignerWorkspace;
end;

procedure TfrxDesignerForm.PagePopupPopup(Sender: TObject);
var
  i: Integer;
  ed: TfrxComponentEditor;
  p: TPopupMenu;
  m: TMenuItem;
begin
  while PagePopup.Items[3] <> SepMI8 do
    PagePopup.Items[3].Free;

  AddChildMI.Visible := TObject(FSelectedObjects[0]) is TfrxBand;
  p := TPopupMenu.Create(nil);
  ed := frxComponentEditors.GetComponentEditor(FSelectedObjects[0], Self, p);
  if ed <> nil then
  begin
    EditMI1.Enabled := ed.HasEditor;
    EditMI1.Default := EditMI1.Enabled;

    ed.GetMenuItems;

    SepMI12.Visible := p.Items.Count > 0;

    for i := p.Items.Count - 1 downto 0 do
    begin
      m := TMenuItem.Create(PagePopup);
      with p.Items[i] do
      begin
        m.Caption := Caption;
        m.Tag := Tag;
        m.Checked := Checked;
        m.Bitmap := Bitmap;
      end;
      m.OnClick := OnComponentMenuClick;
      PagePopup.Items.Insert(3, m);
    end;

    ed.Free;
  end
  else
  begin
    EditMI1.Enabled := False;
    SepMI12.Visible := False;
  end;

  p.Free;
end;

procedure TfrxDesignerForm.CodeWindowDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := (Source is TTreeView) and (TTreeView(Source).Owner = FDataTree) and
     (FDataTree.GetFieldName <> '');
end;

procedure TfrxDesignerForm.CodeWindowDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
  CodeWindow.SelText := FDataTree.GetFieldName;
  CodeWindow.SetFocus;
end;

procedure TfrxDesignerForm.OnDataTreeDblClick(Sender: TObject);
begin
  if Page = nil then
  begin
    CodeWindow.SelText := FDataTree.GetFieldName;
    CodeWindow.SetFocus;
  end
  else if (FDataTree.GetActivePage = 0) and
    (Report.DataSets.Count = 0) then
    ReportDataMIClick(Self);
end;

procedure TfrxDesignerForm.TabChanging(Sender: TObject; var AllowChange: Boolean);
begin
  if IsPreviewDesigner or FScriptRunning then
    AllowChange := False;

  if (FTabs.TabIndex = 0) and CodeWindow.Modified then
  begin
    Modified := True;
    CodeWindow.Modified := False;
  end;

  SavePagePosition;
end;

procedure TfrxDesignerForm.TabSetChange(Sender: TObject; NewTab: Integer;
  var AllowChange: Boolean);
begin
  TabChanging(nil, AllowChange);
end;

procedure TfrxDesignerForm.TabChange(Sender: TObject);
begin
  if FTabs.TabIndex = 0 then
{$IFDEF FR_VER_BASIC}
    FTabs.TabIndex := 1 else
{$ELSE}
    Page := nil else
{$ENDIF}
    Page := Report.Pages[FTabs.TabIndex - 1];
end;

procedure TfrxDesignerForm.TabMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  p: TPoint;
begin
  GetCursorPos(p);
  if Button = mbRight then
    TabPopup.Popup(p.X, p.Y) else
    FMouseDown := True;
end;

procedure TfrxDesignerForm.TabMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  pt: TPoint;
begin
  FMouseDown := False;
  if Button = mbRight then
  begin
    pt := TControl(Sender).ClientToScreen(Point(X, Y));
    TabPopup.Popup(pt.X, pt.Y);
  end;
end;

procedure TfrxDesignerForm.TabMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if FMouseDown then
    FTabs.BeginDrag(False);
end;

procedure TfrxDesignerForm.TabDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Source is Sender.ClassType;
end;

{$IFDEF UseTabset}
procedure TfrxDesignerForm.TabDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  HitPage, CurPage: Integer;
begin
  HitPage := FTabs.ItemAtPos(Point(X, Y));
  CurPage := Report.Objects.IndexOf(Page) + 1;
  if (CurPage < 2) or (HitPage < 2) then Exit;

  FTabs.Tabs.Move(CurPage, HitPage);
  Report.Objects.Move(CurPage - 1, HitPage - 1);
  Modified := True;
end;
{$ELSE}
procedure TfrxDesignerForm.TabDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  HitPage, CurPage: Integer;
  HitTestInfo: TTCHitTestInfo;
begin
  HitTestInfo.pt := Point(X, Y);
  HitPage := SendMessage(FTabs.Handle, TCM_HITTEST, 0, Longint(@HitTestInfo));
  CurPage := Report.Objects.IndexOf(Page) + 1;
  if (CurPage < 2) or (HitPage < 2) then Exit;

  FTabs.Tabs.Move(CurPage, HitPage);
  Report.Objects.Move(CurPage - 1, HitPage - 1);
  Modified := True;
end;
{$ENDIF}

{ Dialog form events }
{------------------------------------------------------------------------------}

procedure TfrxDesignerForm.DialogFormModify(Sender: TObject);
begin
  Page.Left := FDialogForm.Left;
  Page.Top := FDialogForm.Top;
  Page.Width := FDialogForm.Width;
  Page.Height := FDialogForm.Height;
  Modified := True;
end;

procedure TfrxDesignerForm.DialogFormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Shift = [ssCtrl] then
    if Key = Ord('C') then
      CopyCmd.Execute
    else if Key = Ord('V') then
      PasteCmd.Execute
    else if Key = Ord('X') then
      CutCmd.Execute
    else if Key = Ord('Z') then
      UndoCmd.Execute
    else if Key = Ord('Y') then
      RedoCmd.Execute
    else if Key = Ord('A') then
      SelectAllCmd.Execute
    else if Key = Ord('S') then
      SaveCmd.Execute;

  THackControl(FWorkspace).KeyDown(Key, Shift);
end;

procedure TfrxDesignerForm.DialogFormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  THackControl(FWorkspace).KeyUp(Key, Shift);
end;

procedure TfrxDesignerForm.DialogFormKeyPress(Sender: TObject; var Key: Char);
begin
  THackControl(FWorkspace).KeyPress(Key);
end;


{ Menu commands }
{------------------------------------------------------------------------------}

procedure TfrxDesignerForm.ExitCmdExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrxDesignerForm.OptionsMIClick(Sender: TObject);
var
  u: TfrxDesignerUnits;
begin
  u := FUnits;

  with TfrxOptionsEditor.Create(Self) do
  begin
    ShowModal;
    Free;
  end;

  if u <> FUnits then
    FOldUnits := FUnits;

  if FWorkspace.GridType = gtDialog then
  begin
    FWorkspace.GridX := FGridSize4;
    FWorkspace.GridY := FGridSize4;
  end;

  FWorkspace.UpdateView;
  CodeWindow.Invalidate;
end;

procedure TfrxDesignerForm.ConnectionsMIClick(Sender: TObject);
begin
  with TfrxConnEditorForm.Create(nil) do
  begin
    Report := Self.Report;
    ShowModal;
    Free;
  end;
end;

procedure TfrxDesignerForm.UndoCmdExecute(Sender: TObject);
var
  i: Integer;
begin
  if IsPreviewDesigner then Exit;

  if FPage = nil then
  begin
    CodeWindow.Undo;
    Exit;
  end;

  i := GetPageIndex;
  Lock;

  Report.ScriptText := CodeWindow.Lines;
  FUndoBuffer.AddRedo(Report);
  FUndoBuffer.GetUndo(Report);
  CodeWindow.Lines := Report.ScriptText;

  ReloadPages(i);
end;

procedure TfrxDesignerForm.RedoCmdExecute(Sender: TObject);
var
  i: Integer;
begin
  if IsPreviewDesigner then Exit;

  i := GetPageIndex;
  Lock;

  Report.Reloading := True;
  FUndoBuffer.GetRedo(Report);
  Report.Reloading := False;
  FUndoBuffer.AddUndo(Report);
  CodeWindow.Lines := Report.ScriptText;

  ReloadPages(i);
end;

procedure TfrxDesignerForm.CutCmdExecute(Sender: TObject);
begin
  if FPage = nil then
  begin
    CodeWindow.CutToClipboard;
    Exit;
  end;

  FClipboard.Copy;
  FWorkspace.DeleteObjects;
  FInspector.Objects := FObjects;

  Modified := True;
end;

procedure TfrxDesignerForm.CopyCmdExecute(Sender: TObject);
begin
  if FPage = nil then
  begin
    CodeWindow.CopyToClipboard;
    Exit;
  end;

  FClipboard.Copy;
  TimerTimer(nil);
end;

procedure TfrxDesignerForm.PasteCmdExecute(Sender: TObject);
begin
  if FPage = nil then
  begin
    CodeWindow.PasteFromClipboard;
    Exit;
  end;

  FClipboard.Paste;
  FWorkspace.BringToFront;
  FInspector.Objects := FObjects;
  FInspector.UpdateProperties;

  if TfrxComponent(FSelectedObjects[0]) is TfrxDialogComponent then
    Modified := True
  else if FSelectedObjects[0] <> FPage then
    TDesignerWorkspace(FWorkspace).SimulateMove;
end;

procedure TfrxDesignerForm.GroupCmdExecute(Sender: TObject);
begin
  FWorkspace.GroupObjects;
end;

procedure TfrxDesignerForm.UngroupCmdExecute(Sender: TObject);
begin
  FWorkspace.UngroupObjects;
end;

procedure TfrxDesignerForm.DeletePageCmdExecute(Sender: TObject);
begin
  if not CheckOp(drDontDeletePage) then Exit;

  Lock;
  if (FPage is TfrxReportPage) and (TfrxReportPage(FPage).Subreport <> nil) then
    TfrxReportPage(FPage).Subreport.Free;

  FPage.Free;
  ReloadPages(-2);
  Modified := True;
end;

procedure TfrxDesignerForm.NewPageCmdExecute(Sender: TObject);
begin
  if not CheckOp(drDontCreatePage) then Exit;

  Lock;
  if Report.DotMatrixReport then
    FPage := TfrxDMPPage.Create(Report)
  else
    FPage := TfrxReportPage.Create(Report);
  FPage.CreateUniqueName;
  TfrxReportPage(FPage).SetDefaults;
  ReloadPages(Report.PagesCount - 1);
  Modified := True;
end;

procedure TfrxDesignerForm.NewDialogCmdExecute(Sender: TObject);
begin
  if not CheckOp(drDontCreatePage) then Exit;

  Lock;
  FPage := TfrxDialogPage.Create(Report);
  FPage.CreateUniqueName;
  FPage.SetBounds(265, 150, 300, 200);
  ReloadPages(Report.PagesCount - 1);
  Modified := True;
end;

procedure TfrxDesignerForm.NewReportCmdExecute(Sender: TObject);
var
  dp: TfrxDataPage;
  p: TfrxReportPage;
  b: TfrxBand;
  m: TfrxMemoView;
  h, t: Extended;
  w: Word;
begin
  if not CheckOp(drDontCreateReport) then Exit;

  if Modified then
  begin
    w := AskSave;
    if w = mrYes then
      SaveCmdExecute(Self)
    else if w = mrCancel then
      Exit;
  end;

  t := FWorkspace.BandHeader;
  h := 0;
  case FUnits of
    duCM:     h := fr01cm * 6;
    duInches: h := fr01in * 3;
    duPixels: h := 20;
    duChars:  h := fr1CharY;
  end;

  ObjectSelectB.Down := True;
  SelectToolBClick(Self);

  Lock;
  Report.Clear;
  Report.FileName := '';

  dp := TfrxDataPage.Create(Report);
  dp.Name := 'Data';

  p := TfrxReportPage.Create(Report);
  p.Name := 'Page1';
  SetReportDefaults;

  b := TfrxReportTitle.Create(p);
  b.Name := 'ReportTitle1';
  b.Top := t;
  b.Height := h;

  b := TfrxMasterData.Create(p);
  b.Name := 'MasterData1';
  b.Height := h;
  b.Top := t * 2 + h * 2;

  b := TfrxPageFooter.Create(p);
  b.Name := 'PageFooter1';
  b.Height := h;
  b.Top := t * 3 + h * 4;

  m := TfrxMemoView.Create(b);
  m.Name := 'Memo1';
  m.SetBounds((p.PaperWidth - p.LeftMargin - p.RightMargin - 20) * fr01cm, 0,
    2 * fr1cm, 5 * fr01cm);
  m.HAlign := haRight;
  m.Memo.Text := '[Page#]';

  ReloadPages(-2);
  UpdateCaption;
  Modified := False;
end;

procedure TfrxDesignerForm.SaveCmdExecute(Sender: TObject);
begin
  FInspector.ItemIndex := FInspector.ItemIndex;
  if CheckOp(drDontSaveReport) then
    SaveFile(False, Sender = SaveCmd);
end;

procedure TfrxDesignerForm.SaveAsCmdExecute(Sender: TObject);
begin
  FInspector.ItemIndex := FInspector.ItemIndex;
  if CheckOp(drDontSaveReport) then
    SaveFile(True, Sender = SaveAsCmd);
end;

procedure TfrxDesignerForm.OpenCmdExecute(Sender: TObject);
begin
  if CheckOp(drDontLoadReport) then
    LoadFile('', Sender = OpenCmd);
end;

procedure TfrxDesignerForm.OpenRecentFile(Sender: TObject);
begin
  if CheckOp(drDontLoadReport) then
    LoadFile(TMenuItem(Sender).Caption, True);
end;

procedure TfrxDesignerForm.DeleteCmdExecute(Sender: TObject);
begin
  FWorkspace.DeleteObjects;
end;

procedure TfrxDesignerForm.SelectAllCmdExecute(Sender: TObject);
var
  i: Integer;
  Parent: TfrxComponent;
begin
  if Page = nil then
  begin
    CodeWindow.SelectAll;
    Exit;
  end;

  Parent := FPage;
  if FSelectedObjects.Count = 1 then
    if TfrxComponent(FSelectedObjects[0]) is TfrxBand then
      Parent := FSelectedObjects[0]
    else if TfrxComponent(FSelectedObjects[0]).Parent is TfrxBand then
      Parent := TfrxComponent(FSelectedObjects[0]).Parent;

  if Parent.Objects.Count <> 0 then
    FSelectedObjects.Clear;
  for i := 0 to Parent.Objects.Count - 1 do
    FSelectedObjects.Add(Parent.Objects[i]);
  OnSelectionChanged(Self);
end;

procedure TfrxDesignerForm.EditCmdExecute(Sender: TObject);
begin
  FWorkspace.EditObject;
end;

procedure TfrxDesignerForm.BringToFrontCmdExecute(Sender: TObject);
var
  i: Integer;
  c: TfrxComponent;
begin
  for i := 0 to FSelectedObjects.Count - 1 do
  begin
    c := FSelectedObjects[i];
    if (c is TfrxReportComponent) and not (rfDontMove in c.Restrictions) then
    begin
      c.Parent.Objects.Remove(c);
      c.Parent.Objects.Add(c);
    end;
  end;

  ReloadObjects;
  Modified := True;
end;

procedure TfrxDesignerForm.SendToBackCmdExecute(Sender: TObject);
var
  i: Integer;
  c: TfrxComponent;
begin
  for i := 0 to FSelectedObjects.Count - 1 do
  begin
    c := FSelectedObjects[i];
    if (c is TfrxReportComponent) and not (rfDontMove in c.Restrictions) then
    begin
      c.Parent.Objects.Remove(c);
      c.Parent.Objects.Insert(0, c);
    end;
  end;

  ReloadObjects;
  Modified := True;
end;

procedure TfrxDesignerForm.TabOrderMIClick(Sender: TObject);
begin
  with TfrxTabOrderEditorForm.Create(Self) do
  begin
    if ShowModal = mrOk then
      Modified := True;
    ReloadObjects;
    Free;
  end;
end;

procedure TfrxDesignerForm.AboutMIClick(Sender: TObject);
begin
  with TfrxAboutForm.Create(Self) do
  begin
    ShowModal;
    Free;
  end;
end;

procedure TfrxDesignerForm.ReportSettingsMIClick(Sender: TObject);
begin
  if CheckOp(drDontChangeReportOptions) then
    with TfrxReportEditorForm.Create(Self) do
    begin
      if ShowModal = mrOk then
      begin
        { reload printer fonts }
        FontNameCB.PopulateList;
        Modified := True;
      end;
      Free;
    end;
end;

procedure TfrxDesignerForm.PageSettingsCmdExecute(Sender: TObject);
begin
  if CheckOp(drDontChangePageOptions) then
    if (FPage is TfrxReportPage) and (TfrxReportPage(FPage).Subreport = nil) then
      with TfrxPageEditorForm.Create(Self) do
      begin
        if ShowModal = mrOk then
        begin
          Modified := True;
          UpdatePageDimensions;
        end;
        Free;
      end;
end;

procedure TfrxDesignerForm.OnComponentMenuClick(Sender: TObject);
var
  ed: TfrxComponentEditor;
begin
  ed := frxComponentEditors.GetComponentEditor(FSelectedObjects[0], Self, nil);
  if ed <> nil then
  begin
    if ed.Execute(TMenuItem(Sender).Tag, not TMenuItem(Sender).Checked) then
      Modified := True;
    ed.Free;
  end;
end;

procedure TfrxDesignerForm.ReportDataMIClick(Sender: TObject);
begin
  if CheckOp(drDontEditReportData) then
    with TfrxReportDataForm.Create(Self) do
    begin
      Report := Self.Report;
      if ShowModal = mrOk then
      begin
        Modified := True;
        UpdateDataTree;
      end;
      Free;
    end;
end;

procedure TfrxDesignerForm.VariablesCmdExecute(Sender: TObject);
begin
  if CheckOp(drDontEditVariables) then
    with TfrxVarEditorForm.Create(Self) do
    begin
      if ShowModal = mrOk then
      begin
        Modified := True;
        UpdateDataTree;
      end;
      Free;
    end;
end;

procedure TfrxDesignerForm.PreviewCmdExecute(Sender: TObject);
var
  Preview: TfrxCustomPreview;
  pt: TPoint;
  SavePageNo: Integer;
  SaveModalPreview: Boolean;
  SaveDestroyForms: Boolean;
  SaveMDIChild: Boolean;
begin
  FInspector.ItemIndex := FInspector.ItemIndex;
  if not CheckOp(drDontPreviewReport) then Exit;

  SavePagePosition;
  Report.ScriptText := CodeWindow.Lines;
  if not Report.PrepareScript then
  begin
    pt := fsPosToPoint(Report.Script.ErrorPos);
    SwitchToCodeWindow;
    FCodeWindow.SetPos(pt.X, pt.Y);
    FCodeWindow.ShowMessage(Report.Script.ErrorMsg);
    Exit;
  end;

  AttachDialogFormEvents(False);
  SavePageNo := GetPageIndex;
  SaveModalPreview := Report.PreviewOptions.Modal;
  SaveDestroyForms := Report.EngineOptions.DestroyForms;
  SaveMDIChild := Report.PreviewOptions.MDIChild;

  FUndoBuffer.AddUndo(Report);

  Preview := Report.Preview;
  try
    Report.Preview := nil;
    Report.PreviewOptions.Modal := True;
    Report.EngineOptions.DestroyForms := False;
    Report.PreviewOptions.MDIChild := False;
    FWatchList.ScriptRunning := True;
    Report.ShowReport;
  except
  end;

  FWatchList.ScriptRunning := False;
  Lock;
  FUndoBuffer.GetUndo(Report);

  Report.Script.ClearItems(Report);
  Report.Preview := Preview;
  Report.PreviewOptions.Modal := SaveModalPreview;
  Report.EngineOptions.DestroyForms := SaveDestroyForms;
  Report.PreviewOptions.MDIChild := SaveMDIChild;

  if SavePageNo <> -1 then
    ReloadPages(SavePageNo)
  else
  begin
    ReloadPages(-2);
    Page := nil;
  end;

  FWatchList.UpdateWatches;
end;

procedure TfrxDesignerForm.ReportStylesMIClick(Sender: TObject);
begin
  if CheckOp(drDontChangeReportOptions) then
    with TfrxStyleEditorForm.Create(Self) do
    begin
      if ShowModal = mrOk then
      begin
        Modified := True;
        UpdateStyles;
        Report.Styles.Apply;
      end;
      Free;
    end;
end;

procedure TfrxDesignerForm.NewItemCmdExecute(Sender: TObject);
begin
  if CheckOp(drDontCreateReport) then
    with TfrxNewItemForm.Create(Self) do
    begin
      ShowModal;
      Free;
    end;
end;

procedure TfrxDesignerForm.FindMIClick(Sender: TObject);
begin
  with TfrxSearchDialog.Create(Application) do
  begin
    FSearchReplace := Sender = ReplaceMI;
    if FSearchReplace then
      ReplacePanel.Show;
    if Page <> nil then
      TopCB.Enabled := False;
    if ShowModal = mrOk then
    begin
      FSearchText := TextE.Text;
      FSearchReplaceText := ReplaceE.Text;
      FSearchCase := CaseCB.Checked;
      FSearchIndex := 0;
      if (Page = nil) and not TopCB.Checked then
        FSearchIndex := CodeWindow.GetPlainPos;
      FindNextMI.Enabled := True;
      FindText;
    end;
    Free;
  end;
end;

procedure TfrxDesignerForm.FindNextMIClick(Sender: TObject);
begin
  FindText;
end;

procedure TfrxDesignerForm.HelpContentsMIClick(Sender: TObject);
var
  tempC: TfrxDialogComponent;
begin
  if Page = nil then
    frxResources.Help(FCodeWindow)
  else if Page is TfrxDialogPage then
    frxResources.Help(Page)
  else if TObject(SelectedObjects[0]) is TfrxDialogComponent then
  begin
    tempC := TfrxDialogComponent.Create(nil);
    frxResources.Help(tempC);
    tempC.Free;
  end
  else
    frxResources.Help(Self);
end;

procedure TfrxDesignerForm.AddChildMIClick(Sender: TObject);
var
  b, bc: TfrxBand;
begin
  b := FSelectedObjects[0];
  bc := b.Child;
  InsertBandClick(ChildMI);
  b.Child := FSelectedObjects[0];
  b.Child.Child := TfrxChild(bc);
  Modified := True;
end;


{ Debugging }
{------------------------------------------------------------------------------}

procedure TfrxDesignerForm.RunScriptBClick(Sender: TObject);
begin
  if FScriptRunning then
  begin
    FScriptStep := Sender = StepScriptB;
    if (Sender = RunScriptB) and (CodeWindow.BreakPoints.Count = 0) then
      Report.Script.OnRunLine := nil;
    FScriptStopped := False;
    Exit;
  end;

  if (Sender = RunScriptB) and (CodeWindow.BreakPoints.Count = 0) then
    Report.Script.OnRunLine := nil
  else
    Report.Script.OnRunLine := OnRunLine;

  try
    FScriptRunning := True;
    FScriptFirstTime := True;
    PreviewCmdExecute(Self);
  finally
    FScriptRunning := False;
    Report.Script.OnRunLine := nil;
    CodeWindow.DeleteF4BreakPoints;
    CodeWindow.ActiveLine := -1;
  end;
end;

procedure TfrxDesignerForm.StopScriptBClick(Sender: TObject);
begin
  Report.Script.OnRunLine := nil;
  Report.Script.Terminate;
  Report.Terminated := True;
  FScriptStopped := False;
end;

procedure TfrxDesignerForm.EvaluateBClick(Sender: TObject);
begin
  with TfrxEvaluateForm.Create(Self) do
  begin
    Script := Report.Script;
    if CodeWindow.SelText <> '' then
      ExpressionE.Text := CodeWindow.SelText;
    ShowModal;
    Free;
  end;
end;

procedure TfrxDesignerForm.BreakPointBClick(Sender: TObject);
begin
  CodeWindow.ToggleBreakPoint(CodeWindow.GetPos.Y, '');
end;

procedure TfrxDesignerForm.RunToCursorBClick(Sender: TObject);
begin
  CodeWindow.AddBreakPoint(CodeWindow.GetPos.Y, 'F4');
  RunScriptBClick(nil);
end;

procedure TfrxDesignerForm.OnRunLine(Sender: TfsScript; const UnitName,
  SourcePos: String);
var
  p: TPoint;
  SaveActiveForm: TForm;
  Condition: String;

  procedure CreateLineMarks;
  var
    i: Integer;
  begin
    for i := 0 to Report.Script.Lines.Count - 1 do
      CodeWindow.RunLine[i + 1] := Report.Script.IsExecutableLine(i + 1);
  end;

begin
  p := fsPosToPoint(SourcePos);
  if not FScriptStep and (CodeWindow.BreakPoints.Count > 0) then
    if not CodeWindow.IsBreakPoint(p.Y) then
      Exit;

  Condition := CodeWindow.GetBreakPointCondition(p.Y);
  { F4 - run to line, remove the breakpoint }
  if Condition = 'F4' then
    CodeWindow.DeleteBreakPoint(p.Y);

  if FScriptFirstTime then
    CreateLineMarks;
  FScriptFirstTime := False;

  SaveActiveForm := Screen.ActiveForm;
  EnableWindow(Handle, True);
  SetFocus;

  CodeWindow.ActiveLine := p.Y;
  CodeWindow.SetPos(p.X, p.Y);
  FWatchList.UpdateWatches;

  FScriptStopped := True;
  while FScriptStopped do
    Application.ProcessMessages;

  if SaveActiveForm <> nil then
    SaveActiveForm.SetFocus;
end;


{ Alignment palette }
{------------------------------------------------------------------------------}

procedure TfrxDesignerForm.AlignLeftsBClick(Sender: TObject);
var
  i: Integer;
  c0, c: TfrxComponent;
begin
  if FSelectedObjects.Count < 2 then Exit;

  c0 := FSelectedObjects[0];
  for i := 1 to FSelectedObjects.Count - 1 do
  begin
    c := FSelectedObjects[i];
    if not (rfDontMove in c.Restrictions) then
      c.Left := c0.Left;
  end;

  Modified := True;
end;

procedure TfrxDesignerForm.AlignRightsBClick(Sender: TObject);
var
  i: Integer;
  c0, c: TfrxComponent;
begin
  if FSelectedObjects.Count < 2 then Exit;

  c0 := FSelectedObjects[0];
  for i := 1 to FSelectedObjects.Count - 1 do
  begin
    c := FSelectedObjects[i];
    if not (rfDontMove in c.Restrictions) then
      c.Left := c0.Left + c0.Width - c.Width;
  end;

  Modified := True;
end;

procedure TfrxDesignerForm.AlignTopsBClick(Sender: TObject);
var
  i: Integer;
  c0, c: TfrxComponent;
begin
  if FSelectedObjects.Count < 2 then Exit;

  c0 := FSelectedObjects[0];
  for i := 1 to FSelectedObjects.Count - 1 do
  begin
    c := FSelectedObjects[i];
    if not (rfDontMove in c.Restrictions) then
      if Abs(c.Top - c.AbsTop) < 1e-4 then
        c.Top := c0.AbsTop
      else
        c.Top := c0.AbsTop - c.AbsTop + c.Top;
  end;

  Modified := True;
end;

procedure TfrxDesignerForm.AlignBottomsBClick(Sender: TObject);
var
  i: Integer;
  c0, c: TfrxComponent;
begin
  if FSelectedObjects.Count < 2 then Exit;

  c0 := FSelectedObjects[0];
  for i := 1 to FSelectedObjects.Count - 1 do
  begin
    c := FSelectedObjects[i];
    if not (rfDontMove in c.Restrictions) then
      if Abs(c.Top - c.AbsTop) < 1e-4 then
        c.Top := c0.AbsTop + c0.Height - c.Height
      else
        c.Top := c0.AbsTop - c.AbsTop + c.Top + c0.Height - c.Height;
  end;

  Modified := True;
end;

procedure TfrxDesignerForm.AlignHorzCentersBClick(Sender: TObject);
var
  i: Integer;
  c0, c: TfrxComponent;
begin
  if FSelectedObjects.Count < 2 then Exit;

  c0 := FSelectedObjects[0];
  for i := 1 to FSelectedObjects.Count - 1 do
  begin
    c := FSelectedObjects[i];
    if not (rfDontMove in c.Restrictions) then
      c.Left := c0.Left + c0.Width / 2 - c.Width / 2;
  end;

  Modified := True;
end;

procedure TfrxDesignerForm.AlignVertCentersBClick(Sender: TObject);
var
  i: Integer;
  c0, c: TfrxComponent;
begin
  if FSelectedObjects.Count < 2 then Exit;

  c0 := FSelectedObjects[0];
  for i := 1 to FSelectedObjects.Count - 1 do
  begin
    c := FSelectedObjects[i];
    if not (rfDontMove in c.Restrictions) then
      c.Top := c0.Top + c0.Height / 2 - c.Height / 2;
  end;

  Modified := True;
end;

procedure TfrxDesignerForm.CenterHorzBClick(Sender: TObject);
var
  i: Integer;
  c: TfrxComponent;
begin
  if FSelectedObjects.Count < 1 then Exit;

  for i := 0 to FSelectedObjects.Count - 1 do
  begin
    c := FSelectedObjects[i];
    if not (rfDontMove in c.Restrictions) and (c is TfrxView) then
      if c.Parent is TfrxBand then
        c.Left := (c.Parent.Width - c.Width) / 2 else
        c.Left := (FWorkspace.Width / Scale - c.Width) / 2;
  end;

  Modified := True;
end;

procedure TfrxDesignerForm.CenterVertBClick(Sender: TObject);
var
  i: Integer;
  c: TfrxComponent;
begin
  if FSelectedObjects.Count < 1 then Exit;

  for i := 0 to FSelectedObjects.Count - 1 do
  begin
    c := FSelectedObjects[i];
    if not (rfDontMove in c.Restrictions) and (c is TfrxView) then
      if c.Parent is TfrxBand then
        c.Top := (c.Parent.Height - c.Height) / 2 else
        c.Top := (FWorkspace.Height / Scale - c.Height) / 2;
  end;

  Modified := True;
end;

procedure TfrxDesignerForm.SpaceHorzBClick(Sender: TObject);
var
  i: Integer;
  c: TfrxComponent;
  sl: TStringList;
  dx: Extended;
begin
  if FSelectedObjects.Count < 3 then Exit;

  sl := TStringList.Create;
  sl.Sorted := True;
  sl.Duplicates := dupAccept;

  for i := 0 to FSelectedObjects.Count - 1 do
  begin
    c := FSelectedObjects[i];
    sl.AddObject(Format('%4.4d', [Round(c.Left)]), c);
  end;

  dx := (TfrxComponent(sl.Objects[sl.Count - 1]).Left -
    TfrxComponent(sl.Objects[0]).Left) / (sl.Count - 1);

  for i := 1 to sl.Count - 2 do
  begin
    c := TfrxComponent(sl.Objects[i]);
    if not (rfDontMove in c.Restrictions) then
      c.Left := TfrxComponent(sl.Objects[i - 1]).Left + dx;
  end;

  sl.Free;
  Modified := True;
end;

procedure TfrxDesignerForm.SpaceVertBClick(Sender: TObject);
var
  i: Integer;
  c: TfrxComponent;
  sl: TStringList;
  dy: Extended;
begin
  if FSelectedObjects.Count < 3 then Exit;

  sl := TStringList.Create;
  sl.Sorted := True;
  sl.Duplicates := dupAccept;

  for i := 0 to FSelectedObjects.Count - 1 do
  begin
    c := FSelectedObjects[i];
    sl.AddObject(Format('%4.4d', [Round(c.Top)]), c);
  end;

  dy := (TfrxComponent(sl.Objects[sl.Count - 1]).Top -
    TfrxComponent(sl.Objects[0]).Top) / (sl.Count - 1);

  for i := 1 to sl.Count - 2 do
  begin
    c := TfrxComponent(sl.Objects[i]);
    if not (rfDontMove in c.Restrictions) then
      c.Top := TfrxComponent(sl.Objects[i - 1]).Top + dy;
  end;

  sl.Free;
  Modified := True;
end;

procedure TfrxDesignerForm.SameWidthBClick(Sender: TObject);
var
  i: Integer;
  c0, c: TfrxComponent;
begin
  if FSelectedObjects.Count < 2 then Exit;

  c0 := FSelectedObjects[0];
  for i := 1 to FSelectedObjects.Count - 1 do
  begin
    c := FSelectedObjects[i];
    if not (rfDontSize in c.Restrictions) then
      c.Width := c0.Width;
  end;

  Modified := True;
end;

procedure TfrxDesignerForm.SameHeightBClick(Sender: TObject);
var
  i: Integer;
  c0, c: TfrxComponent;
begin
  if FSelectedObjects.Count < 2 then Exit;

  c0 := FSelectedObjects[0];
  for i := 1 to FSelectedObjects.Count - 1 do
  begin
    c := FSelectedObjects[i];
    if not (rfDontSize in c.Restrictions) then
      c.Height := c0.Height;
  end;

  Modified := True;
end;


{ Save/restore state }
{------------------------------------------------------------------------------}

procedure TfrxDesignerForm.SaveState;
var
  Ini: TCustomIniFile;
  Nm: String;

  procedure SaveToolbars(t: array of TToolBar);
  var
    i: Integer;
  begin
    for i := Low(t) to High(t) do
      frxSaveToolbarPosition(Ini, t[i]);
  end;

  procedure SaveDocks(t: array of TfrxDockSite);
  var
    i: Integer;
  begin
    for i := Low(t) to High(t) do
      frxSaveDock(Ini, t[i]);
  end;

begin
  if IsPreviewDesigner then Exit;
  if WorkspaceColor = 0 then Exit;

  Ini := Report.GetIniFile;
  Nm := 'Form4.TfrxDesignerForm';
  Ini.WriteInteger('Form4.TfrxObjectInspector', 'SplitPos', FInspector.SplitterPos);
  Ini.WriteInteger('Form4.TfrxObjectInspector', 'Split1Pos', FInspector.Splitter1Pos);
  Ini.WriteFloat(Nm, 'Scale', FScale);
  Ini.WriteBool(Nm, 'ShowGrid', FShowGrid);
  Ini.WriteBool(Nm, 'GridAlign', FGridAlign);
  Ini.WriteBool(Nm, 'ShowRulers', FShowRulers);
  Ini.WriteBool(Nm, 'ShowGuides', FShowGuides);
  Ini.WriteFloat(Nm, 'Grid1', FGridSize1);
  Ini.WriteFloat(Nm, 'Grid2', FGridSize2);
  Ini.WriteFloat(Nm, 'Grid3', FGridSize3);
  Ini.WriteFloat(Nm, 'Grid4', FGridSize4);
  FUnits := FOldUnits;
  Ini.WriteInteger(Nm, 'Units', Integer(FUnits));
  Ini.WriteString(Nm, 'ScriptFontName', CodeWindow.Font.Name);
  Ini.WriteInteger(Nm, 'ScriptFontSize', CodeWindow.Font.Size);
  Ini.WriteString(Nm, 'MemoFontName', MemoFontName);
  Ini.WriteInteger(Nm, 'MemoFontSize', MemoFontSize);
  Ini.WriteBool(Nm, 'UseObjectFont', UseObjectFont);
  Ini.WriteInteger(Nm, 'WorkspaceColor', FWorkspaceColor);
  Ini.WriteInteger(Nm, 'ToolsColor', FToolsColor);
  Ini.WriteBool(Nm, 'GridLCD', FWorkspace.GridLCD);
  Ini.WriteBool(Nm, 'EditAfterInsert', FEditAfterInsert);
  Ini.WriteBool(Nm, 'LocalizedOI', FLocalizedOI);
  Ini.WriteString(Nm, 'RecentFiles', FRecentFiles.CommaText);
  Ini.WriteBool(Nm, 'FreeBands', FWorkspace.FreeBandsPlacement);
  Ini.WriteInteger(Nm, 'BandsGap', FWorkspace.GapBetweenBands);
  Ini.WriteBool(Nm, 'ShowBandCaptions', FWorkspace.ShowBandCaptions);
  Ini.WriteBool(Nm, 'DropFields', FDropFields);
  Ini.WriteBool(Nm, 'ShowStartup', FShowStartup);
  Ini.WriteString(Nm, 'WatchList', FWatchList.Watches.Text);

  frxSaveFormPosition(Ini, Self);
  frxSaveFormPosition(Ini, FInspector);
  frxSaveFormPosition(Ini, FDataTree);
  frxSaveFormPosition(Ini, FReportTree);
  frxSaveFormPosition(Ini, FWatchList);
  SaveToolbars([StandardTB, TextTB, FrameTB, AlignTB, ExtraToolsTB]);
  SaveDocks([LeftDockSite1, LeftDockSite2, RightDockSite, CodeDockSite]);

  Ini.Free;
end;

procedure TfrxDesignerForm.RestoreState(RestoreDefault: Boolean = False;
  RestoreMainForm: Boolean = False);
const
  DefIni =
'[Form4.TfrxObjectInspector];' +
'Width=159;' +
'SplitPos=75;' +
'Split1Pos=65;' +
'Dock=LeftDockSite2;' +
'[Form4.TfrxDesignerForm];' +
'EditAfterInsert=1;' +
'Maximized=1;' +
'[Form4.TfrxDataTreeForm];' +
'Width=143;' +
'Dock=RightDockSite;' +
'[Form4.TfrxReportTreeForm];' +
'Width=159;' +
'Dock=LeftDockSite2;' +
'[Form4.TfrxWatchForm];' +
'Height=100;' +
'Dock=CodeDockSite;' +
'[ToolBar4.StandardTB];' +
'Float=0;' +
'Visible=1;' +
'Left=0;' +
'Top=0;' +
'Width=576;' +
'Height=27;' +
'Dock=DockTop;' +
'[ToolBar4.TextTB];' +
'Float=0;' +
'Visible=1;' +
'Left=0;' +
'Top=27;' +
'Width=651;' +
'Height=27;' +
'Dock=DockTop;' +
'[ToolBar4.FrameTB];' +
'Float=0;' +
'Visible=1;' +
'Left=651;' +
'Top=27;' +
'Width=305;' +
'Height=27;' +
'Dock=DockTop;' +
'[ToolBar4.AlignTB];' +
'Visible=0;' +
'[ToolBar4.ExtraToolsTB];' +
'Visible=0;' +
'[Dock4.LeftDockSite2];' +
'Data=00000400000000004F0300000000000001A200000000000000010000000073000000110000006672785265706F727454726565466F726D01000000004F030000120000006672784F626A656374496E73706563746F72FFFFFFFF;' +
'Width=160;' +
'[Dock4.RightDockSite];' +
'Data=000004000000000000000000000000000000000000000000000100000000000000000F0000006672784461746154726565466F726DFFFFFFFF;' +
'Width=160';

var
  Ini: TCustomIniFile;
  Nm: String;

  procedure RestoreToolbars(t: array of TToolBar);
  var
    i: Integer;
  begin
    for i := Low(t) to High(t) do
      frxRestoreToolbarPosition(Ini, t[i]);
  end;

  procedure RestoreDocks(t: array of TfrxDockSite);
  var
    i: Integer;
  begin
    for i := Low(t) to High(t) do
      frxRestoreDock(Ini, t[i]);
  end;

  function Def(Value, DefValue: Extended): Extended;
  begin
    if Value = 0 then
      Result := DefValue else
      Result := Value;
  end;

  procedure DoRestore;
  begin
    if not RestoreMainForm then
    begin
      FInspector.SplitterPos := Ini.ReadInteger('Form4.TfrxObjectInspector',
        'SplitPos', FInspector.Width div 2);
      if FInspector.SplitterPos > FInspector.Width - 10 then
        FInspector.SplitterPos := FInspector.Width div 2;
      FInspector.Splitter1Pos := Ini.ReadInteger('Form4.TfrxObjectInspector',
        'Split1Pos', 65);
      if FInspector.Splitter1Pos < 10 then
        FInspector.Splitter1Pos := 65;
      Scale := Ini.ReadFloat(Nm, 'Scale', 1);
      ShowGrid := Ini.ReadBool(Nm, 'ShowGrid', True);
      GridAlign := Ini.ReadBool(Nm, 'GridAlign', True);
      ShowRulers := Ini.ReadBool(Nm, 'ShowRulers', True);
      ShowGuides := Ini.ReadBool(Nm, 'ShowGuides', True);
      FGridSize1 := Def(Ini.ReadFloat(Nm, 'Grid1', 0), 0.1);
      FGridSize2 := Def(Ini.ReadFloat(Nm, 'Grid2', 0), 0.1);
      FGridSize3 := Def(Ini.ReadFloat(Nm, 'Grid3', 0), 4);
      FGridSize4 := Def(Ini.ReadFloat(Nm, 'Grid4', 0), 4);
      Units := TfrxDesignerUnits(Ini.ReadInteger(Nm, 'Units', 0));
      FOldUnits := FUnits;
      CodeWindow.Font.Name := Ini.ReadString(Nm, 'ScriptFontName', 'Courier New');
      CodeWindow.Font.Size := Ini.ReadInteger(Nm, 'ScriptFontSize', 10);
      MemoFontName := Ini.ReadString(Nm, 'MemoFontName', 'Arial');
      MemoFontSize := Ini.ReadInteger(Nm, 'MemoFontSize', 10);
      UseObjectFont := Ini.ReadBool(Nm, 'UseObjectFont', True);
      WorkspaceColor := Ini.ReadInteger(Nm, 'WorkspaceColor', clWindow);
      ToolsColor := Ini.ReadInteger(Nm, 'ToolsColor', clWindow);
      FWorkspace.GridLCD := Ini.ReadBool(Nm, 'GridLCD', False);
      FEditAfterInsert := Ini.ReadBool(Nm, 'EditAfterInsert', False);
      FRecentFiles.CommaText := Ini.ReadString(Nm, 'RecentFiles', '');
      FWorkspace.FreeBandsPlacement := Ini.ReadBool(Nm, 'FreeBands', False);
      FWorkspace.GapBetweenBands := Ini.ReadInteger(Nm, 'BandsGap', 4);
      FWorkspace.ShowBandCaptions := Ini.ReadBool(Nm, 'ShowBandCaptions', True);
      FDropFields := Ini.ReadBool(Nm, 'DropFields', True);
      FShowStartup := Ini.ReadBool(Nm, 'ShowStartup', True);
      FWatchList.Watches.Text := Ini.ReadString(Nm, 'WatchList', '');
      FWatchList.UpdateWatches;

      frxRestoreFormPosition(Ini, FInspector);
      if not IsPreviewDesigner then
      begin
        frxRestoreFormPosition(Ini, FDataTree);
        frxRestoreFormPosition(Ini, FReportTree);
        frxRestoreFormPosition(Ini, FWatchList);
      end;
      RestoreToolbars([StandardTB, TextTB, FrameTB, AlignTB, ExtraToolsTB]);
      if not IsPreviewDesigner then
        RestoreDocks([LeftDockSite1, LeftDockSite2, RightDockSite, CodeDockSite]);

      FWatchList.Visible := True;
      FWatchList.DragMode := dmManual;
      FWatchList.ManualDock(CodeDockSite);

      with FCodeWindow do
      begin
  {$I frxDesgn.inc}
      end;
    end
    else
      frxRestoreFormPosition(Ini, Self);
  end;

  procedure ReadDefIni;
  var
    MemIni: TMemIniFile;
    sl: TStringList;
  begin
    Ini.Free;
    MemIni := TMemIniFile.Create('');

    sl := TStringList.Create;
    frxSetCommaText(DefIni, sl);
    MemIni.SetStrings(sl);
    sl.Free;
    Ini := MemIni;
  end;

begin
  Ini := Report.GetIniFile;
  Nm := 'Form4.TfrxDesignerForm';
  if RestoreDefault or (Ini.ReadFloat(Nm, 'Scale', 0) = 0) or
    (Ini.ReadInteger(Nm, 'WorkspaceColor', clWindow) = 0) then
    ReadDefIni;

  try
    try
      DoRestore;
    except
      ReadDefIni;
      DoRestore;
    end
  finally
    Ini.Free;
  end;
end;

procedure TfrxDesignerForm.Localize;
begin
  OpenScriptB.Hint := frxGet(2300);
  SaveScriptB.Hint := frxGet(2301);
  RunScriptB.Hint := frxGet(2302);
  StepScriptB.Hint := frxGet(2303);
  StopScriptB.Hint := frxGet(2304);
  EvaluateB.Hint := frxGet(2305);
  LangL.Caption := frxGet(2306);
  AlignTB.Caption := frxGet(2307);
  AlignLeftsB.Hint := frxGet(2308);
  AlignHorzCentersB.Hint := frxGet(2309);
  AlignRightsB.Hint := frxGet(2310);
  AlignTopsB.Hint := frxGet(2311);
  AlignVertCentersB.Hint := frxGet(2312);
  AlignBottomsB.Hint := frxGet(2313);
  SpaceHorzB.Hint := frxGet(2314);
  SpaceVertB.Hint := frxGet(2315);
  CenterHorzB.Hint := frxGet(2316);
  CenterVertB.Hint := frxGet(2317);
  SameWidthB.Hint := frxGet(2318);
  SameHeightB.Hint := frxGet(2319);
  TextTB.Caption := frxGet(2320);
  StyleCB.Hint := frxGet(2321);
  FontNameCB.Hint := frxGet(2322);
  FontSizeCB.Hint := frxGet(2323);
  BoldB.Hint := frxGet(2324);
  ItalicB.Hint := frxGet(2325);
  UnderlineB.Hint := frxGet(2326);
  FontColorB.Hint := frxGet(2327);
  HighlightB.Hint := frxGet(2328);
  RotateB.Hint := frxGet(2329);
  TextAlignLeftB.Hint := frxGet(2330);
  TextAlignCenterB.Hint := frxGet(2331);
  TextAlignRightB.Hint := frxGet(2332);
  TextAlignBlockB.Hint := frxGet(2333);
  TextAlignTopB.Hint := frxGet(2334);
  TextAlignMiddleB.Hint := frxGet(2335);
  TextAlignBottomB.Hint := frxGet(2336);
  FrameTB.Caption := frxGet(2337);
  FrameTopB.Hint := frxGet(2338);
  FrameBottomB.Hint := frxGet(2339);
  FrameLeftB.Hint := frxGet(2340);
  FrameRightB.Hint := frxGet(2341);
  FrameAllB.Hint := frxGet(2342);
  FrameNoB.Hint := frxGet(2343);
  ShadowB.Hint := frxGet(2344);
  FillColorB.Hint := frxGet(2345);
  FrameColorB.Hint := frxGet(2346);
  FrameStyleB.Hint := frxGet(2347);
  FrameWidthCB.Hint := frxGet(2348);
  StandardTB.Caption := frxGet(2349);
  NewB.Hint := frxGet(2350);
  OpenB.Hint := frxGet(2351);
  SaveB.Hint := frxGet(2352);
  PreviewB.Hint := frxGet(2353);
  NewPageB.Hint := frxGet(2354);
  NewDialogB.Hint := frxGet(2355);
  DeletePageB.Hint := frxGet(2356);
  PageSettingsB.Hint := frxGet(2357);
  VariablesB.Hint := frxGet(2358);
  CutB.Hint := frxGet(2359);
  CopyB.Hint := frxGet(2360);
  PasteB.Hint := frxGet(2361);
  UndoB.Hint := frxGet(2363);
  RedoB.Hint := frxGet(2364);
  GroupB.Hint := frxGet(2365);
  UngroupB.Hint := frxGet(2366);
  ShowGridB.Hint := frxGet(2367);
  AlignToGridB.Hint := frxGet(2368);
  SetToGridB.Hint := frxGet(2369);
  ScaleCB.Hint := frxGet(2370);

  ExtraToolsTB.Caption := frxGet(2371);
  ObjectSelectB.Hint := frxGet(2372);
  HandToolB.Hint := frxGet(2373);
  ZoomToolB.Hint := frxGet(2374);
  TextToolB.Hint := frxGet(2375);
  FormatToolB.Hint := frxGet(2376);
  ObjectBandB.Hint := frxGet(2377);
  FileMenu.Caption := frxGet(2378);
  EditMenu.Caption := frxGet(2379);
  FindMI.Caption := frxGet(2380);
  FindNextMI.Caption := frxGet(2381);
  ReplaceMI.Caption := frxGet(2382);
  ReportMenu.Caption := frxGet(2383);
  ReportDataMI.Caption := frxGet(2384);
  ReportSettingsMI.Caption := frxGet(2385);
  ReportStylesMI.Caption := frxGet(2386);
  ViewMenu.Caption := frxGet(2387);
  ToolbarsMI.Caption := frxGet(2388);
  StandardMI.Caption := frxGet(2389);
  TextMI.Caption := frxGet(2390);
  FrameMI.Caption := frxGet(2391);
  AlignmentMI.Caption := frxGet(2392);
  ToolsMI.Caption := frxGet(2393);
  InspectorMI.Caption := frxGet(2394);
  DataTreeMI.Caption := frxGet(2395);
  ReportTreeMI.Caption := frxGet(2396);
  ShowRulersMI.Caption := frxGet(2397);
  ShowGuidesMI.Caption := frxGet(2398);
  DeleteGuidesMI.Caption := frxGet(2399);
  OptionsMI.Caption := frxGet(2400);
  HelpMenu.Caption := frxGet(2401);
  HelpContentsMI.Caption := frxGet(2402);
{$IFDEF FR_LITE}
  AboutMI.Caption := StringReplace(frxGet(2403), 'FastReport', 'FreeReport', []);
{$ELSE}
  AboutMI.Caption := frxGet(2403);
{$ENDIF}
  TabOrderMI.Caption := frxGet(2404);
  UndoCmd.Caption := frxGet(2405);
  RedoCmd.Caption := frxGet(2406);
  CutCmd.Caption := frxGet(2407);
  CopyCmd.Caption := frxGet(2408);
  PasteCmd.Caption := frxGet(2409);
  GroupCmd.Caption := frxGet(2410);
  UngroupCmd.Caption := frxGet(2411);
  DeleteCmd.Caption := frxGet(2412);
  DeletePageCmd.Caption := frxGet(2413);
  SelectAllCmd.Caption := frxGet(2414);
  EditCmd.Caption := frxGet(2415);
  BringToFrontCmd.Caption := frxGet(2416);
  SendToBackCmd.Caption := frxGet(2417);
  NewItemCmd.Caption := frxGet(2418);
  NewReportCmd.Caption := frxGet(2419);
  NewPageCmd.Caption := frxGet(2420);
  NewDialogCmd.Caption := frxGet(2421);
  OpenCmd.Caption := frxGet(2422);
  SaveCmd.Caption := frxGet(2423);
  SaveAsCmd.Caption := frxGet(2424);
  VariablesCmd.Caption := frxGet(2425);
  PageSettingsCmd.Caption := frxGet(2426);
  PreviewCmd.Caption := frxGet(2427);
  ExitCmd.Caption := frxGet(2428);
  ReportTitleMI.Caption := frxGet(2429);
  ReportSummaryMI.Caption := frxGet(2430);
  PageHeaderMI.Caption := frxGet(2431);
  PageFooterMI.Caption := frxGet(2432);
  HeaderMI.Caption := frxGet(2433);
  FooterMI.Caption := frxGet(2434);
  MasterDataMI.Caption := frxGet(2435);
  DetailDataMI.Caption := frxGet(2436);
  SubdetailDataMI.Caption := frxGet(2437);
  Data4levelMI.Caption := frxGet(2438);
  Data5levelMI.Caption := frxGet(2439);
  Data6levelMI.Caption := frxGet(2440);
  GroupHeaderMI.Caption := frxGet(2441);
  GroupFooterMI.Caption := frxGet(2442);
  ChildMI.Caption := frxGet(2443);
  ColumnHeaderMI.Caption := frxGet(2444);
  ColumnFooterMI.Caption := frxGet(2445);
  OverlayMI.Caption := frxGet(2446);
  VerticalbandsMI.Caption := frxGet(2447);
  HeaderMI1.Caption := frxGet(2448);
  FooterMI1.Caption := frxGet(2449);
  MasterDataMI1.Caption := frxGet(2450);
  DetailDataMI1.Caption := frxGet(2451);
  SubdetailDataMI1.Caption := frxGet(2452);
  GroupHeaderMI1.Caption := frxGet(2453);
  GroupFooterMI1.Caption := frxGet(2454);
  ChildMI1.Caption := frxGet(2455);
  R0MI.Caption := frxGet(2456);
  R45MI.Caption := frxGet(2457);
  R90MI.Caption := frxGet(2458);
  R180MI.Caption := frxGet(2459);
  R270MI.Caption := frxGet(2460);
  FontB.Hint := frxGet(2461);
  BoldMI.Caption := frxGet(2462);
  ItalicMI.Caption := frxGet(2463);
  UnderlineMI.Caption := frxGet(2464);
  SuperScriptMI.Caption := frxGet(2465);
  SubScriptMI.Caption := frxGet(2466);
  CondensedMI.Caption := frxGet(2467);
  WideMI.Caption := frxGet(2468);
  N12cpiMI.Caption := frxGet(2469);
  N15cpiMI.Caption := frxGet(2470);
  OpenDialog.Filter := frxGet(2471);
  OpenScriptDialog.Filter := frxGet(2472);
  SaveScriptDialog.Filter := frxGet(2473);
  ConnectionsMI.Caption := frxGet(2474);
  BreakPointB.Hint := frxGet(2476);
  RunToCursorB.Hint := frxGet(2477);
  AddChildMI.Caption := frxGet(2478);

  if Assigned(frxFR2Events.OnLoad) then
    OpenDialog.Filter := 'Report (*.fr3, *.frf)|*.fr3;*.frf';
end;

procedure TfrxDesignerForm.CreateLangMenu;
var
  m, t: TMenuItem;
  i: Integer;
  reg: TRegistry;
  current: String;
begin
  current := '';
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey('\Software\Fast Reports\Resources', false) then
      current := reg.ReadString('Language');
  finally
    reg.Free;
  end;
  if frxResources.Languages.Count > 0 then
  begin
    m := TMenuItem.Create(ViewMenu);
    m.Caption := '-';
    ViewMenu.Add(m);
    m := TMenuItem.Create(ViewMenu);
    m.Caption := frxGet(2475);
    ViewMenu.Add(m);
    for i := 0 to frxResources.Languages.Count - 1 do
    begin
      t := TMenuItem.Create(m);
      t.Caption := frxResources.Languages[i];
      t.RadioItem := True;
      t.OnClick := LangSelectClick;
      if UpperCase(t.Caption) = UpperCase(current) then
        t.Checked := True;
      m.Add(t);
    end;
  end;
end;

procedure TfrxDesignerForm.LangSelectClick(Sender: TObject);
var
  m: TMenuItem;
  reg: TRegistry;
begin
  m := Sender as TMenuItem;
  m.Checked := True;
  frxResources.LoadFromFile(GetAppPath + m.Caption + '.frc');
  Localize;
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey('\Software\Fast Reports\Resources', false) then
      reg.WriteString('Language', m.Caption);
  finally
    reg.Free;
  end;
end;

procedure TfrxDesignerForm.OnCodeCompletion(const Name: String; List: TStrings);
var
  obj: TPersistent;
  xd: TfsXMLDocument;
  i, j: Integer;
  sl, members: TStringList;
  s: String;
  clName: String;
  clVar: TfsClassVariable;
  clMethod: TfsCustomHelper;
  cl: TClass;
  l: TList;
begin
  members := TStringList.Create;
  frxSetCommaText(Name, members, '.');
  if members.Count = 0 then
  begin
    List.Clear;
    l := Report.AllObjects;
    for i := 0 to l.Count - 1 do
      List.AddObject(TfrxComponent(l[i]).Name + ' : ' + TfrxComponent(l[i]).ClassName, nil);

    members.Free;
    Exit;
  end;

  for i := 0 to members.Count - 1 do
    members[i] := Trim(members[i]);

  if CompareText('Report', members[0]) = 0 then
    obj := Report
  else if CompareText('Engine', members[0]) = 0 then
    obj := Report.Engine
  else if CompareText('Outline', members[0]) = 0 then
    obj := Report.PreviewPages.Outline
  else
    obj := Report.FindObject(members[0]);

  clName := '';
  if obj <> nil then
    clName := obj.ClassName;

  i := 1;
  while (clName <> '') and (i < members.Count) do
  begin
    clVar := Report.Script.FindClass(clName);
    clName := '';
    if clVar <> nil then
    begin
      clMethod := clVar.Find(members[i]);
      if clMethod <> nil then
        clName := clMethod.TypeName;
      Inc(i);
    end;
  end;

  if clName <> '' then
  begin
    clVar := Report.Script.FindClass(clName);
    if clVar <> nil then
    begin
      cl := Report.Script.FindClass(clName).ClassRef;

      xd := TfsXMLDocument.Create;
      GenerateMembers(Report.Script, cl, xd.Root);
      sl := TStringList.Create;
      sl.Sorted := True;
      sl.Duplicates := dupIgnore;
      for i := 0 to xd.Root.Count - 1 do
      begin
        s := xd.Root[i].Prop['text'];
        j := 0;
        if Pos('property', s) = 1 then
        begin
          Delete(s, 1, 9);
          j := 1;
        end;
        if Pos('index property', s) = 1 then
        begin
          Delete(s, 1, 15);
          j := 1;
        end;
        if Pos('procedure', s) = 1 then
        begin
          Delete(s, 1, 10);
          j := 2;
        end;
        if Pos('function', s) = 1 then
        begin
          Delete(s, 1, 9);
          j := 3;
        end;

        sl.AddObject(s, TObject(j));
      end;
      List.Assign(sl);
      sl.Free;
      xd.Free;
    end;
  end;
end;

procedure TfrxDesignerForm.CodeDockSiteDockOver(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
begin
  Accept := not (Source.Control is TToolBar);
end;

procedure TfrxDesignerForm.OnDisableDock(Sender: TObject;
  var DragObject: TDragDockObject);
begin
  DockTop.DockSite := False;
  DockBottom.DockSite := False;
end;

procedure TfrxDesignerForm.OnEnableDock(Sender, Target: TObject; X, Y: Integer);
begin
  DockTop.DockSite := True;
  DockBottom.DockSite := True;
end;


initialization
  frxDesignerClass := TfrxDesignerForm;


end.



//0f31356a91fea3356e5f76cdce90aa7b