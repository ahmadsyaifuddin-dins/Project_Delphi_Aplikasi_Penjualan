{*******************************************}
{                                           }
{          FastQueryBuilder 1.03            }
{                                           }
{            Copyright (c) 2005             }
{             Fast Reports Inc.             }
{                                           }
{*******************************************}

{$I fqb.inc}

unit fqbClass;

interface

uses
  Windows, Messages, Classes, Controls, Menus, Forms, Graphics, StdCtrls, Grids,
  DB, SysUtils, ExtCtrls, CheckLst, Buttons, Comctrls
{$IFDEF Delphi6}
  ,Variants
{$ENDIF};

type
  TfqbTable = class;
  TfqbTableArea = class;
  EfqbError = class(Exception)
  end;
  
  TfqbField = class(TCollectionItem)
  private
    FFieldName: string;
    FFielType: Integer;
    FLinked: Boolean;
    function GetFieldName: string;
  public
    property FieldName: string read GetFieldName write FFieldName;
    property FieldType: Integer read FFielType write FFielType;
    property Linked: Boolean read FLinked write FLinked;
  end;
  
  TfqbFieldList = class(TOwnedCollection)
  private
    function GetItem(Index: Integer): TfqbField;
    procedure SetItem(Index: Integer; const Value: TfqbField);
  public
    function Add: TfqbField;
    property Items[Index: Integer]: TfqbField read GetItem write SetItem; default;
  end;
  
  TfqbLink = class(TCollectionItem)
  protected
    FArea: TfqbTableArea;
    FDestField: TfqbField;
    FDestTable: TfqbTable;
    FJOp: Integer;
    FJType: Integer;
    FMenu: TPopupMenu;
    FSelected: Boolean;
    FSourceField: TfqbField;
    FSourceTable: TfqbTable;
    procedure DoDelete(Sender: TObject);
    procedure DoOptions(Sender: TObject);
    procedure Draw;
    function GetDestCoords: TPoint;
    function GetSourceCoords: TPoint;
    procedure SetSelected(const Value: Boolean);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    property DestCoords: TPoint read GetDestCoords;
    property DestField: TfqbField read FDestField;
    property DestTable: TfqbTable read FDestTable;
    property JoinOperator: Integer read FJOp write FJOp;
    property JoinType: Integer read FJType write FJType;
    property Selected: Boolean read FSelected write SetSelected;
    property SourceCoords: TPoint read GetSourceCoords;
    property SourceField: TfqbField read FSourceField;
    property SourceTable: TfqbTable read FSourceTable;
  end;
  
  TfqbLinkList = class(TOwnedCollection)
  private
    function GetItem(Index: Integer): TfqbLink;
    procedure SetItem(Index: Integer; const Value: TfqbLink);
  public
    function Add: TfqbLink;
    property Items[Index: Integer]: TfqbLink read GetItem write SetItem; default;
  end;
  
  TfqbCheckListBox = class(TCheckListBox)
  protected
    procedure ClickCheck; override;
    procedure DragOver(Sender: TObject; X, Y: Integer; State: TDragState; var
                   Accept: Boolean); override;
  public
    procedure DragDrop(Sender: TObject; X, Y: Integer); override;
  end;
  
  TfqbTable = class(TPanel)
  private
    FAliasName: string;
    FButtonClose: TSpeedButton;
    FButtonMinimize: TSpeedButton;
    FCheckListBox: TfqbCheckListBox;
    FFieldList: TfqbFieldList;
    FImage: TImage;
    FLabel: TLabel;
    FOldHeight: Integer;
    FTableName: string;
    function GetSellectedField: TfqbField;
    procedure SetTableName(const Value: string);
    procedure SetXPStyle(const AComp: TControl);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    function GetLinkPoint(AIndex: integer; ASide: char): TPoint;
    procedure Resize; override;
    procedure WMMove(var Message: TWMMove); message WM_MOVE;
    procedure WMNCHitTest(var M: TWMNCHitTest); message wm_NCHitTest;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure CMRelease(var Message: TMessage); message CM_RELEASE;
    procedure _DoExit(Sender: TObject);
    procedure _DoMinimize(Sender: TObject);
    procedure _DoRestore(Sender: TObject);
    property ChBox: TfqbCheckListBox read FCheckListBox;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure UpdateFieldList;
    procedure UpdateLinkList;
    property AliasName: string read FAliasName;
    property FieldList: TfqbFieldList read FFieldList write FFieldList;
    property SellectedField: TfqbField read GetSellectedField;
    property TableName: string read FTableName write SetTableName;
  end;
  
  TfqbTableArea = class(TScrollBox)
  private
    FCanvas: TCanvas;
    FInstX: Integer;
    FInstY: Integer;
    FLinkList: TfqbLinkList;
  protected
    procedure Click; override;
    function GenerateAlias(const ATableNAme: string): string; virtual;
    function GetLineAtCursor: Integer;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function CompareFields(TableID1: integer; FIndex1: integer; TableID2: integer;
                   FIndex2: integer): Boolean;
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var
                   Accept: Boolean); override;
    function FindTable(const AName, AAlias: string): TfqbTable;
    procedure InsertTable(const X, Y : integer; const Name: string); overload;
    procedure InsertTable(const Name : string); overload;
    property LinkList: TfqbLinkList read FLinkList;
  end;

  TfqbTableListBox = class(TListBox)
  protected
    procedure DblClick; override;
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState);
                   override;
    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;
  
  PGridColumn = ^TGridColumn;
  TGridColumn = record
    Table: string;
    Alias: string;
    Field: string;
    Visibl: Boolean;
    Where: string;
    Sort: Integer;
    Func: Integer;
    Group: Integer;
  end;
  
  TfqbEdit = class(TEdit)
  private
    FButton: TSpeedButton;
    FOnButtonClick: TNotifyEvent;
    FPanel: TPanel;
    FShowButton: Boolean;
    procedure SetShowButton(const Value: Boolean);
  protected
    procedure ButtonClick(Sender: TObject);
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure SetEditRect;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
  public
    constructor Create(AOwner: TComponent); override;
    property OnButtonClick: TNotifyEvent read FOnButtonClick write FOnButtonClick;
    property ShowButton: Boolean read FShowButton write SetShowButton;
  end;
  
  TfqbColumnResizeEvent = procedure (Sender: TCustomListview; ColumnIndex: Integer;
                 ColumnWidth: Integer) of object;
  TfqbGrid = class(TListView)
  private
    FEndColumnResizeEvent: TfqbColumnResizeEvent;
    FFunctionList: TComboBox;
    FGroupList: TComboBox;
    FPopupMenu: TPopupMenu;
    FSortList: TComboBox;
    FVisibleList: TComboBox;
    FWhereEditor: TfqbEdit;
    procedure fqbOnChange(Sender: TObject);
    procedure fqbOnMenu(Sender: TObject);
    procedure fqbOnPopup(Sender: TObject);
    procedure fqbOnSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure fqbSetBounds(var Contr: TControl);
  protected
    procedure CreateWnd; override;
    procedure DoColumnResize(ColumnIndex, ColumnWidth: Integer); virtual;
    function FindColumnIndex(pHeader: pNMHdr): Integer;
    function FindColumnWidth(pHeader: pNMHdr): Integer;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
                   override;
    procedure RecalcColWidth;
    procedure Resize; override;
    procedure WMNotify(var Msg: TWMNotify); message WM_NOTIFY;
    procedure WMVscroll(var Msg: TWMNotify); message WM_VSCROLL;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function AddColumn: Integer;
    procedure Exchange(const AItm1, AItm2: integer);
    procedure fqbUpdate;
    procedure UpdateColumn;
    property OnEndColumnResize: TfqbColumnResizeEvent read FEndColumnResizeEvent
                   write FEndColumnResizeEvent;
  end;
  
  TfqbEngine = class(TComponent)
  private
    FShowSystemTables: Boolean;
  public
    procedure ReadFieldList(const ATableName: string; var AFieldList: TfqbFieldList);
                   virtual; abstract;
    procedure ReadTableList(ATableList: TStrings); virtual; abstract;
    function ResultDataSet: TDataSet; virtual; abstract;
    procedure SetSQL(const Value: string); virtual; abstract;
  published
    property ShowSystemTables: Boolean read FShowSystemTables write
                   FShowSystemTables default False;
  end;
  
  TfqbDialog = class(TComponent)
  private
    FEngine: TfqbEngine;
    function GetSchemaInsideSQL: Boolean;
    function GetSQL: string;
    function GetSQLSchema: string;
    procedure SetEngine(const Value: TfqbEngine);
    procedure SetSchemaInsideSQL(const Value: Boolean);
    procedure SetSQL(Value: string);
    procedure SetSQLSchema(const Value: string);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    function Execute: Boolean; virtual;
    property SQL: string read GetSQL write SetSQL;
    property SQLSchema: string read GetSQLSchema write SetSQLSchema;
  published
    property Engine: TfqbEngine read FEngine write SetEngine;
    property SchemaInsideSQL: Boolean read GetSchemaInsideSQL write
                   SetSchemaInsideSQL default True;
  end;
  
  TfqbCore = class(TObject)
  private
    FEngine: TfqbEngine;
    FGrid: TfqbGrid;
    FSchemaInsideSQL: Boolean;
    FSQL: string;
    FSQLSchema: string;
    FTableArea: TfqbTableArea;
    FUseCoding: Boolean;
    FText: string;
    FUsingQuotes: Boolean;
    function ExtractSchema(const Value: string): string;
    function ExtractSQL(const Str: string): string;
    function GetEngine: TfqbEngine;
    function GetGrid: TfqbGrid;
    function GetSQL: string;
    function GetSQLSchema: string;
    function GetTableArea: TfqbTableArea;
    procedure SetSchemaInsideSQL(const Value: Boolean);
    procedure SetSQL(Value: string);
    procedure SetSQLSchema(const Value: string);
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Clear;
    function GenerateSQL: string;
    procedure LoadFromFile(const FileName: string);
    procedure LoadFromStr(const Str: TStringList);
    procedure RecognizeModel(const crc32: Cardinal; const FileName: string);
    procedure SaveToFile(const FileName: string);
    procedure SaveToStr(var Str: TStringList);
    property Engine: TfqbEngine read GetEngine write FEngine;
    property Grid: TfqbGrid read GetGrid write FGrid;
    property SQL: string read GetSQL write SetSQL;
    property SQLSchema: string read GetSQLSchema write SetSQLSchema;
    property TableArea: TfqbTableArea read GetTableArea write FTableArea;
    property SchemaInsideSQL: Boolean read FSchemaInsideSQL write SetSchemaInsideSQL
                   default True;
    property UsingQuotes: Boolean read FUsingQuotes write FUsingQuotes;

  end;
  

function fqbCore: TfqbCore;

const
  StrFieldType : array [0..29] of string = (''{0}, 'String'{1}, 'Smallint'{2},
                       'Integer'{3}, 'Word'{4}, 'Boolean'{5}, 'Float'{6},
                       'Currency'{7}, 'BCD'{8}, 'Date'{9}, 'Time'{10},
                       'DateTime'{11}, 'Bytes'{12}, 'VarBytes'{13}, 'AutoInc'{14},
                       'Blob'{15}, 'Memo'{16}, 'Graphic'{17}, 'FmtMemo'{18},
                       'ParadoxOle'{19}, 'DBaseOle'{20}, 'TypedBinary'{21},
                       'Cursor'{22}, 'FixedChar'{23}, 'WideString'{24}, 'Largeint'{25},
                       'ADT'{26}, 'Array'{27}, 'Reference'{28}, 'DataSet'{29});

  _fqbBeginModel = '/*_FQBMODEL';
  _fqbEndModel = '_FQBEND*/';

implementation

{$R images.res}

uses Math, IniFiles, Dialogs, Commctrl, fqbDesign, fqbLinkForm, fqbUtils,
     fqbRes, fqbrcDesign
     {$IFDEF Delphi7}
     ,Themes
     {$ENDIF}
     ;

const
  clSelectedLink = clGreen;
  clNotSelectedLink = clBlack;

  LinkType: array[0..5] of string = ('=', '>', '<', '>=', '<=', '<>');
  JoinType: array[0..3] of string = ('INNER JOIN', 'LEFT OUTER JOIN',
                                     'RIGHT OUTER JOIN', 'FULL OUTER JOIN');

  rowColumn =     0;
  rowVisibility = 1;
  rowWhere =      2;
  rowSort =       3;
  rowFunction =   4;
  rowGroup =      5;

  CompatibleIntTypes = [2, 3, 4, 12, 14];
  CompatibleDateTimeTypes = [9, 10, 11];
  CompatibleFloatTypes = [6, 7];

type
  TcrTControl = class(TControl)
  end;
  
var
  FfqbCore: TfqbCore = nil;
  FExternalCreation: Boolean = True;

function fqbCore: TfqbCore;
begin
  if FfqbCore = nil then
  begin
    FExternalCreation := False;
    try
      FfqbCore := TfqbCore.Create;
    finally
      FExternalCreation := True;
    end;
  end;
  Result := FfqbCore;
end;

function FindFQBcomp(const AClassName: string; const Source: TComponent): TComponent;
  var
    i: integer;
begin
  Result := nil;
  if UpperCase(Source.ClassName) = UpperCase(AClassName) then
      Result := Source
  else
    for i := 0 to Source.ComponentCount - 1 do
      if Result = nil then
        Result := FindFQBcomp(AClassName, Source.Components[i])
      else
        Exit
end;

{-----------------------  TfqbField -----------------------}
function TfqbField.GetFieldName: string;
begin
  if ((Pos(' ', FFieldName) > 0) or (Pos('/', FFieldName) > 0)
    or ((UpperCase(FFieldName) <> FFieldName)) and fqbCore.UsingQuotes) then
    Result := '"' + FFieldName + '"'
  else
    Result := FFieldName
end;

{-----------------------  TfqbFieldList -----------------------}
function TfqbFieldList.Add: TfqbField;
begin
  Result := TfqbField(inherited Add)
end;

function TfqbFieldList.GetItem(Index: Integer): TfqbField;
begin
  Result := TfqbField(inherited Items[Index])
end;

procedure TfqbFieldList.SetItem(Index: Integer; const Value: TfqbField);
begin
  Items[Index].Assign(Value)
end;

{-----------------------  TfqbLinkList -----------------------}
function TfqbLinkList.Add: TfqbLink;
begin
  Result := TfqbLink(inherited Add)
end;

function TfqbLinkList.GetItem(Index: Integer): TfqbLink;
begin
  Result := TfqbLink(inherited Items[Index])
end;

procedure TfqbLinkList.SetItem(Index: Integer; const Value: TfqbLink);
begin
  Items[Index].Assign(Value)
end;

{-----------------------  TfqbLink -----------------------}
constructor TfqbLink.Create(Collection: TCollection);
var
  tmp: TMenuItem;
begin
  inherited Create(Collection);
  FJOp := 0;
  FJType:= 0;
  FMenu:= TPopupMenu.Create(nil);
  tmp:= TMenuItem.Create(FMenu);
  tmp.Caption:= 'Link options';
  tmp.OnClick:= DoOptions;
  FMenu.Items.Add(tmp);
  tmp:= TMenuItem.Create(FMenu);
  tmp.Caption:= 'Delete';
  tmp.OnClick:= DoDelete;
  FMenu.Items.Add(tmp)
end;

destructor TfqbLink.Destroy;
begin
  SourceField.Linked := false;
  DestField.Linked := false;
  FMenu.Free;
  inherited Destroy;
end;

procedure TfqbLink.DoDelete(Sender: TObject);
begin
  Free
end;

procedure TfqbLink.DoOptions(Sender: TObject);
var
  fqbLinkForm: TfqbLinkForm;
begin
  fqbLinkForm := TfqbLinkForm.Create(nil);
  try
    fqbLinkForm.txtTable1.Caption := SourceTable.TableName;
    fqbLinkForm.txtCol1.Caption := SourceField.FieldName;
    fqbLinkForm.txtTable2.Caption := DestTable.TableName;
    fqbLinkForm.txtCol2.Caption := DestField.FieldName;;
    fqbLinkForm.RadioOpt.ItemIndex := JoinOperator;
    fqbLinkForm.RadioType.ItemIndex := JoinType;
    if fqbLinkForm.ShowModal = mrOk then
    begin
      JoinOperator := fqbLinkForm.RadioOpt.ItemIndex;
      JoinType := fqbLinkForm.RadioType.ItemIndex
    end;
  finally
    fqbLinkForm.Free
  end
end;

procedure TfqbLink.Draw;
var
  pnt1, pnt2: TPoint;
  cnt1, cnt2: Integer;
  dSrc, dDest: Integer;
  
  const Delta = 15;
  
begin
  pnt1:= SourceCoords;
  pnt2:= DestCoords;
  cnt1:= SourceTable.BoundsRect.Left + (SourceTable.Width div 2);
        cnt2:= DestTable.BoundsRect.Left + (DestTable.Width div 2);
  if cnt1 < cnt2 then
  begin
    dSrc:= Delta;
    dDest:= -Delta
  end
  else
  begin
    dSrc:= -Delta;
    dDest:= Delta
  end;
  FArea.FCanvas.MoveTo(pnt1.x, pnt1.y);
  FArea.FCanvas.Pen.Color:= clNotSelectedLink;
  FArea.FCanvas.Pen.Width:= 3;
  FArea.FCanvas.LineTo(pnt1.x + dSrc, pnt1.y);
  FArea.FCanvas.Pen.Width:= 1;
  if Selected then
    FArea.FCanvas.Pen.Color:= clSelectedLink
  else
    FArea.FCanvas.Pen.Color:= clNotSelectedLink;
  FArea.FCanvas.LineTo(pnt2.x + dDest, pnt2.y);
  FArea.FCanvas.Pen.Width:= 3;
  FArea.FCanvas.Pen.Color:= clNotSelectedLink;
  FArea.FCanvas.LineTo(pnt2.x, pnt2.y)
end;

function TfqbLink.GetDestCoords: TPoint;
var
  cnt1, cnt2: Integer;
begin
  cnt1:= SourceTable.BoundsRect.Left + (SourceTable.Width div 2);
  cnt2:= DestTable.BoundsRect.Left + (DestTable.Width div 2);
  
  if cnt1 < cnt2 then
    Result:= DestTable.GetLinkPoint(DestField.Index,'L')
  else
    Result:= DestTable.GetLinkPoint(DestField.Index,'R')
end;

function TfqbLink.GetSourceCoords: TPoint;
var
  cnt1, cnt2: Integer;
begin
  cnt1:= SourceTable.BoundsRect.Left + (SourceTable.Width div 2);
  cnt2:= DestTable.BoundsRect.Left + (DestTable.Width div 2);
  
  if cnt1 < cnt2 then
    Result:= SourceTable.GetLinkPoint(SourceField.Index,'R')
  else
    Result:= SourceTable.GetLinkPoint(SourceField.Index,'L')
end;

procedure TfqbLink.SetSelected(const Value: Boolean);
var
  i: Integer;
begin
  for i:= 0 to Collection.Count - 1 do
    TfqbLinkList(Collection).Items[i].FSelected := false;
  FSelected := Value
end;

{-----------------------  TfqbTableArea -----------------------}
constructor TfqbTableArea.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCanvas := TControlCanvas.Create;
  TControlCanvas(FCanvas).Control := Self;
  Color := clBtnFace;
  FCanvas.Brush.Color := clBtnFace;

  FLinkList := TfqbLinkList.Create(Self, TfqbLink);

  FInstX := 15;
  FInstY := 15;
end;

destructor TfqbTableArea.Destroy;
begin
  FCanvas.Free;
  FLinkList.Free;
  inherited Destroy;
end;

procedure TfqbTableArea.Click;
var
  n: Integer;
begin
  n := GetLineAtCursor;
  if ((n >= 0) and (n < LinkList.Count)) then
  begin
    LinkList[n].Selected := true;
    Invalidate;
    LinkList[n].FMenu.Popup(Mouse.CursorPos.X,Mouse.CursorPos.Y)
  end;
  inherited Click;
end;

function TfqbTableArea.CompareFields(TableID1: integer; FIndex1: integer; TableID2:
               integer; FIndex2: integer): Boolean;
var
  tp1, tp2: Integer;
begin
  if ((TableID1 > ComponentCount) or (TableID2 > ComponentCount)) then
    Result := false
  else
  begin
    tp1 := TfqbTable(Components[TableID1]).FieldList[Findex1].FieldType;
    tp2 := TfqbTable(Components[TableID2]).FieldList[Findex2].FieldType;

    if ((tp1 in CompatibleIntTypes)
        and (tp2 in CompatibleIntTypes)) then
      Result := True
    else
    if ((tp1 in CompatibleDateTimeTypes)
        and (tp2 in CompatibleDateTimeTypes)) then
      Result := True
    else
    if ((tp1 in CompatibleFloatTypes)
        and (tp2 in CompatibleFloatTypes)) then
      Result := True
    else
      Result := TfqbTable(Components[TableID1]).FieldList[Findex1].FieldType =
                TfqbTable(Components[TableID2]).FieldList[Findex2].FieldType
  end
end;

procedure TfqbTableArea.DragDrop(Source: TObject; X, Y: Integer);
begin
  InsertTable(X, Y, (Source as TfqbTableListBox).Items[(Source as TfqbTableListBox).ItemIndex])
end;

procedure TfqbTableArea.DragOver(Source: TObject; X, Y: Integer; State: TDragState;
               var Accept: Boolean);
begin
  Accept := Source is TfqbTableListBox
end;

function TfqbTableArea.FindTable(const AName, AAlias: string): TfqbTable;
var
  i: Integer;
begin
  Result:= nil;
  for i:= 0 to ComponentCount - 1 do
    if ((TfqbTable(Components[i]).TableName = AName) and
        (TfqbTable(Components[i]).AliasName = AAlias)) then
      Result:= TfqbTable(Components[i])
end;

function TfqbTableArea.GenerateAlias(const ATableNAme: string): string;
var
  n: Integer;
  
  function FindDublicat(AAlias: string): boolean;
    var i: integer;
  begin
    Result:= False;
    for i:= 0 to ComponentCount - 1 do
    begin
      if AAlias = TfqbTable(Components[i]).AliasName then
      begin
        Result:= True;
        Break
      end
    end
  end;
  
begin
  Result:= ATableName[1];
  n:=1;
  while FindDublicat(Result) do
  begin
    Result:= ATableName[1] + IntToStr(n);
    Inc(n)
  end
end;

function TfqbTableArea.GetLineAtCursor: Integer;
  
    procedure SwapInt(var X, Y: Integer);
      var
        T: Integer;
    begin
      T := X;
      X := Y;
      Y := T
    end;
  
    function InRange(const AValue, AMin, AMax: Integer): Boolean;
    begin
      Result := (AValue >= AMin) and (AValue <= AMax)
    end;

    const
      sf = 6; //Scale factor
  var
    i,TX1, TX2, TY1,TY2,X1,Y1,
    X2,Y2,Lx, Ly, C: integer;
    MousePos: TPoint;
    Delta: Real;
  
begin
  Result:= - 1;
  for i:= 0 to LinkList.Count - 1 do
  begin
    MousePos:= Mouse.CursorPos;
    MousePos:= ScreenToClient(MousePos);
    X1:= TfqbLink(LinkList[i]).GetSourceCoords.X;
    X2:= TfqbLink(LinkList[i]).GetDestCoords.X;
    Y1:= TfqbLink(LinkList[i]).GetSourceCoords.Y;
    Y2:= TfqbLink(LinkList[i]).GetDestCoords.Y;
    TX1:= X1;
    TX2:= X2;
    TY1:= Y1;
    TY2:= Y2;
    if TX1> TX2 then SwapInt(TX1, TX2);
    if TY1> TY2 then SwapInt(TY1, TY2);
    Lx:= X2-X1;
    Ly:= Y2-Y1;
    C:= -Ly*X1 + Lx*Y1;
    Delta:= Sqrt(Power((X1-X2), 2) + Power((Y1-Y2), 2)) * sf;
    if (Abs(-Ly*MousePos.X + Lx*MousePos.Y - C)<= Delta) and
       InRange(MousePos.X, TX1 - sf, TX2 + sf) and
       InRange(MousePos.Y, TY1 - sf, TY2 + sf) then
    begin
      Result:= i;
      break
    end
  end
end;

procedure TfqbTableArea.InsertTable(const X, Y : integer; const Name: string);
var
  tmp: TfqbTable;
begin
  tmp := TfqbTable.Create(Self);
  tmp.Left := X;
  tmp.Top := Y;
  tmp.Parent := Self;
  tmp.TableName := Name;
  fqbCore.Engine.ReadFieldList(Name, tmp.FFieldList);
  tmp.UpdateFieldList
end;

procedure TfqbTableArea.InsertTable(const Name : string);
begin
  InsertTable(FInstX, FInstY, Name);
  
  if FInstY > Height then
    FInstY:= 15
  else
    FInstY:= FInstY + 15;
  
  if FInstX > Width then
    FInstX := 15
  else
    FInstX:= FInstX + 15
end;

procedure TfqbTableArea.WMPaint(var Message: TWMPaint);
var
  i: Integer;
  
  {$IFDEF TRIAL}
  str: string;
  l, dx: integer;
  {$ENDIF}
  
begin
  inherited;
  {$IFDEF TRIAL}
  FCanvas.Font.Size := 50;
  FCanvas.Font.Color:= clRed;
  FCanvas.Font.Name := 'Tahoma';
  str := 'deretsigern';
  l := FCanvas.TextWidth(str + 'U');
  dx := (Width div 2) - (l div 2);
  FCanvas.TextOut(dx, 100, 'U');
  for i := 11 downto 1 do
    FCanvas.TextOut(FCanvas.PenPos.x, FCanvas.PenPos.y, str[i]);
  {$ENDIF}
  for i := 0 to LinkList.Count - 1 do
    LinkList[i].Draw
end;

{-----------------------  TfqbTable -----------------------}
constructor TfqbTable.Create(AOwner: TComponent);
begin
  inherited;

  Width := 130;
  Height := 150;
  BevelOuter := bvNone;
  BorderWidth := 1;
  
  FLabel := TLabel.Create(Self);
  with FLabel do
  begin
    Parent := Self;
    Align := alTop;
    Color := clActiveCaption;
    Font.Charset := DEFAULT_CHARSET;
    Font.Color := clCaptionText;
    AutoSize := False;
    Height := Height + 6;
    Font.Size := Font.Size + 1;
    Layout := tlCenter;
    SetXPStyle(FLabel);
  end;
  
  FImage := TImage.Create(Self);
  with FImage do
  begin
    Parent := Self;
    Top := 3;
    Left := 3;
    Width := 16;
    Height := 16;
    AutoSize := True;
    FImage.Picture.Bitmap.LoadFromResourceName(HInstance,'TABLEIMAGE1');
    Transparent := True;
    SetXPStyle(FImage);
  end;
  
  FButtonClose := TSpeedButton.Create(Self);
  with FButtonClose do
  begin
    Parent := Self;
    Top := 3;
    Width := 17;
    Height := 15;
    OnClick := _DoExit;
    Glyph.LoadFromResourceName(HInstance,'BTN_CLOSE');
  end;

  FButtonMinimize := TSpeedButton.Create(Self);
  with FButtonMinimize do
  begin
    Parent := Self;
    Top := 3;
    Width := 17;
    Height := 15;
    OnClick := _DoMinimize;
    Glyph.LoadFromResourceName(HInstance,'BTN_MINI');
  end;
  
  FCheckListBox := TfqbCheckListBox.Create(Self);
  with FCheckListBox do
  begin
    Parent := Self;
    Align := alClient;
    ItemHeight := 13;
    Style := lbOwnerDrawVariable;
    DragMode := dmAutomatic
  end;

  Constraints.MinHeight := FLabel.Height + 8;
  Constraints.MinWidth := 120;
  
  Caption := '';
  FFieldList := TfqbFieldList.Create(Self, TfqbField);
  DragMode := dmAutomatic;
  DoubleBuffered := true;
  ShowHint := False;
  Height := 200;
  Width := 150;

  SetXPStyle(Self);
end;

destructor TfqbTable.Destroy;
var
  i: Integer;
begin
  if GetParentForm(Self) <> nil then
  begin
    for i:= fqbCore.Grid.Items.Count - 1 downto 0 do
    begin
      if TGridColumn(fqbCore.Grid.Items[i].Data^).Table = TableName then
      begin
        FreeMem(fqbCore.Grid.Items[i].Data,SizeOf(TGridColumn));
        fqbCore.Grid.Items[i].Delete;
      end
    end;
    fqbCore.Grid.UpdateColumn
  end;
  UpdateLinkList;
  
  FLabel.Free;
  FCheckListBox.Free;
  FFieldList.Free;
  FImage.Free;
  FButtonClose.Free;
  FButtonMinimize.Free;
  
  if Parent <> nil then
  begin
    Parent.Invalidate;
    Parent:= nil
  end;
  inherited
end;

procedure TfqbTable.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style:= Style or WS_SIZEBOX;
    WindowClass.Style:= WindowClass.Style xor CS_VREDRAW
  end
end;

function TfqbTable.GetLinkPoint(AIndex: integer; ASide: char): TPoint;
var
  tmpRec: TRect;
begin
  tmpRec := ChBox.ItemRect(AIndex);
  tmpRec.Top := tmpRec.Top + FLabel.Height + (ChBox.Height - ChBox.ClientHeight);
  tmpRec.Bottom := tmpRec.Bottom + FLabel.Height + (ChBox.Height - ChBox.ClientHeight);
  
  if tmpRec.Bottom > ClientHeight then
    Result.y := ClientHeight
  else
  if tmpRec.Top < 0 then
    Result.y := 0
  else
    Result.y := tmpRec.Top + (tmpRec.Bottom - tmpRec.Top) div 2;
  
  Result := Parent.ScreenToClient(ClientToScreen(Result));
  
  // if ASide = 'L' then Left side else if ASide = 'R' then Right side
  if ASide = 'L' then
    Result.x := BoundsRect.Left
  else
    Result.x := BoundsRect.Right
end;

function TfqbTable.GetSellectedField: TfqbField;
begin
  Result := FFieldList[ChBox.ItemIndex]
end;

procedure TfqbTable.Resize;
begin
  inherited Resize;
  FButtonClose.Left := Width - 25;
  FButtonMinimize.Left := Width - 42
end;

procedure TfqbTable.SetTableName(const Value: string);
  
  function GetSpace(const Width: integer):string;
  begin
    Result := '';
    repeat
      Result := Result + ' '
    until FLabel.Canvas.TextWidth(Result) > Width
  end;
  
begin
  FTableName := Value;
  FAliasName:= TfqbTableArea(Parent).GenerateAlias(Value);
  FLabel.Caption := GetSpace(FImage.Width + 2) + Value + ' - ' + FAliasName
end;

procedure TfqbTable.SetXPStyle(const AComp: TControl);
begin
  {$IFDEF Delphi7}
  if ThemeServices.ThemesEnabled then
    AComp.ControlStyle := AComp.ControlStyle - [csParentBackground] + [csOpaque];
  {$ENDIF};
end;

procedure TfqbTable.UpdateFieldList;
var
  i: Integer;
begin
  ChBox.Items.BeginUpdate;
  ChBox.Items.Clear;
  if FFieldList.Count > 0 then
    ChBox.Items.Add(TfqbField(FFieldList[0]).FieldName);
  for i:= 1 to FFieldList.Count - 1 do
    ChBox.Items.Add(TfqbField(FFieldList[i]).FieldName + ' (' +
        StrFieldType[TfqbField(FFieldList[i]).FieldType] + ')');
  ChBox.Items.EndUpdate
end;

procedure TfqbTable.UpdateLinkList;
var
  i: Integer;
begin
  if Parent = nil then Exit;
  for i:= (Parent as TfqbTableArea).LinkList.Count - 1 downto 0 do
  if (((Parent as TfqbTableArea).LinkList[i].SourceTable = self) or ((Parent as TfqbTableArea).LinkList[i].DestTable = self)) then
        (Parent as TfqbTableArea).LinkList[i].Free
end;

procedure TfqbTable.WMMove(var Message: TWMMove);
begin
  inherited;
  Parent.Invalidate
end;

procedure TfqbTable.WMNCHitTest(var M: TWMNCHitTest);
var
  x: Integer;
begin
  inherited;
  x := ClientToScreen(Point(FButtonMinimize.Left,0)).X;
  if ((M.Result = htClient) and (M.XPos - x < 0)) then
     M.Result := htCaption
end;

procedure TfqbTable.WMPaint(var Message: TWMPaint);
begin
  inherited;
  Parent.Invalidate
end;

procedure TfqbTable._DoExit(Sender: TObject);
begin
  PostMessage(Handle, CM_RELEASE, 0, 0);
end;

procedure TfqbTable._DoMinimize(Sender: TObject);
begin
  FOldHeight := Height;
  Height := 0;
  FButtonMinimize.OnClick := _DoRestore
end;

procedure TfqbTable._DoRestore(Sender: TObject);
begin
  Height := FOldHeight;
  FButtonMinimize.OnClick := _DoMinimize
end;

{-----------------------  TfqbTableListBox -----------------------}
constructor TfqbTableListBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  DragMode := dmAutomatic;
end;

procedure TfqbTableListBox.CreateWnd;
begin
  Style := lbOwnerDrawFixed;
  ItemHeight := 18;
  inherited;
end;

procedure TfqbTableListBox.DblClick;
begin
  inherited DblClick;
  fqbCore.TableArea.InsertTable(Items[ItemIndex])
end;

procedure TfqbTableListBox.DrawItem(Index: Integer; Rect: TRect; State:
               TOwnerDrawState);
var
  Bitmap: TBitmap;
  BMPRect: TRect;
begin
  inherited DrawItem(Index, Rect, State);
  Canvas.FillRect(Rect);
  Bitmap := TBitmap.Create;
  Bitmap.LoadFromResourceName(HInstance,'TABLEIMAGE1');
  if Bitmap <> nil then
  begin
    BMPRect := Bounds(Rect.Left + 3, Rect.Top + 1, 16, 16);
    Canvas.BrushCopy(BMPRect,Bitmap, Bounds(0, 0, Bitmap.Width, Bitmap.Height),
    Bitmap.Canvas.Pixels[0, Bitmap.Height-1]);
  end;
  Canvas.TextOut(Rect.Left+24, Rect.Top+2, Items[Index]);
  Bitmap.Free
end;

{-----------------------  TfqbDialog -----------------------}
constructor TfqbDialog.Create(AOwner: TComponent);
begin
  inherited;
  fqbCore.SchemaInsideSQL := True;
end;

function TfqbDialog.Execute: Boolean;
var
  tmp: TStringList;
begin
  {$IFDEF TRIAL}
  ShowMessage(' Fast Query Builder'#10#13'Unregistered version');
  {$ENDIF}
  fqbDesigner := TfqbDesigner.Create(Self);
  fqbCore.Engine := Engine;
  fqbCore.Grid := fqbDesigner.fqbGrid1;
  fqbCore.TableArea := fqbDesigner.fqbTableArea1;

  tmp:= TStringList.Create;
  tmp.Text := fqbCore.FText;
  try
    try
      fqbCore.LoadFromStr(tmp);
    except
    end;

    if fqbDesigner.ShowModal = mrOk then
    begin
      tmp.Clear;
      fqbCore.SaveToStr(tmp);
      fqbCore.FText := tmp.Text;
      Result := true
    end
    else
      Result := false;
  finally
    tmp.Free;
    fqbDesigner.Free
  end
end;

function TfqbDialog.GetSchemaInsideSQL: Boolean;
begin
  Result := fqbCore.SchemaInsideSQL;
end;

function TfqbDialog.GetSQL: string;
begin
  Result := fqbCore.SQL;
end;

function TfqbDialog.GetSQLSchema: string;
begin
  Result := fqbCore.SQLSchema;
end;

procedure TfqbDialog.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (AComponent = FEngine) and (Operation = opRemove) then
  begin
    FEngine := nil;
    fqbCore.Engine := nil;
  end;
end;

procedure TfqbDialog.SetEngine(const Value: TfqbEngine);
begin
  if FEngine <> Value then
  begin
    FEngine := Value;
    fqbCore.Engine := Value;
    FreeNotification(FEngine);
  end
end;

procedure TfqbDialog.SetSchemaInsideSQL(const Value: Boolean);
begin
  fqbCore.SchemaInsideSQL := Value;
end;

procedure TfqbDialog.SetSQL(Value: string);
begin
  fqbCore.SQL := Value;
end;

procedure TfqbDialog.SetSQLSchema(const Value: string);
begin
  fqbCore.SQLSchema := Value;
end;

{-----------------------  TfqbCore -----------------------}
constructor TfqbCore.Create;
begin
  if FfqbCore <> nil then
    raise EfqbError.Create('TfqbCore class already initialized.');
  if FExternalCreation then
    raise EfqbError.Create('Call fqbCore function to reference this class.');
  inherited;
  FUseCoding := True;
  FUsingQuotes := False;
end;

destructor TfqbCore.Destroy;
begin
  FfqbCore := nil;
  inherited;
end;

procedure TfqbCore.Clear;
var
  i: Integer;
begin
  for i:= Grid.Items.Count - 1 downto 0 do
      Dispose(PGridColumn(Grid.Items[i].Data));
  Grid.Items.Clear;
  
  for i := TableArea.ComponentCount - 1 downto 0 do
    TableArea.Components[i].Free
end;

function TfqbCore.ExtractSchema(const Value: string): string;
var
  e, b: Integer;
begin
  b := Pos(_fqbBeginModel, Value) + Length(_fqbBeginModel);
  e := Pos(_fqbEndModel, Value);
  if not (e = 0) then
  begin
    Result := Copy(Value, b, e-b);
    Result := fqbTrim(Result, [#10, #13]);
  end
  else
    Result := Value;
end;

function TfqbCore.ExtractSQL(const Str: string): string;
var
  e, b: Integer;
begin
  b := Pos(_fqbBeginModel, Str);
  e := Pos(_fqbEndModel, Str);
  Result := Str;
  Delete(Result, b, e);
end;

function TfqbCore.GenerateSQL: string;
  
  const
    strTab  = '    ';
    strSel = 'SELECT ';
    strFrom = 'FROM';
    strWhere = 'WHERE';
    strOrder = 'ORDER BY ';
    strGroup = 'GROUP BY ';
  var
    i: integer;
    tmpStr, orderStr, prd, groupStr: string;
    slFrom, slWhere: TStringList;
    Tbl1, Tbl2, Tbl3: TfqbTable;
    CopyLL: TList;
    flg: boolean;
    SQL: TStringList;
  
  function FormingFrom(const Ind: integer):string;
    var
      tmp: TfqbLink;
  begin
      tmp := TableArea.LinkList[Ind];
      Result :=  {strTab + }JoinType[tmp.JoinType] + ' '
                + Tbl2.TableName + ' ' + Tbl2.AliasName + ' ON ('
                + Tbl1.AliasName + '.' + tmp.SourceField.FieldName
                + LinkType[tmp.JoinOperator]
                + Tbl2.AliasName + '.' + tmp.DestField.FieldName + ')'
  end;
  
  function FormingFromAnd(const Ind: integer):string;
    var
      tmp: TfqbLink;
  begin
    tmp := TfqbLink(TableArea.LinkList[Ind]);
    Result := ' AND ('
             + Tbl1.AliasName + '.' + tmp.SourceField.FieldName
             + LinkType[tmp.JoinOperator]
             + Tbl3.AliasName + '.' + tmp.DestField.FieldName + ') '
  end;
  
begin
  SQL := TStringList.Create;
  //SELECT
  tmpStr := strSel;
  
  if Grid.Items.Count = 0 then Exit;
  
  for i := 0 to Grid.Items.Count - 1 do
  
  if TGridColumn(Grid.Items[i].Data^).Visibl then
  begin
  
    if Grid.Items[i].SubItems[rowFunction - 1] <> '' then
      prd := Grid.Items[i].SubItems[rowFunction - 1] + '('
    else
      prd := '';
  
    tmpStr := tmpStr + prd + TGridColumn(Grid.Items[i].Data^).Alias + '.'
              + TGridColumn(Grid.Items[i].Data^).Field;
  
    if prd <> '' then prd := ')';
  
    tmpStr := tmpStr + prd + ', '
  end;
  tmpStr := Copy(tmpStr,1,Length(tmpStr) - 2);
  SQL.Add(tmpStr);
  
  //FROM
  tmpStr := '';
  slFrom := TStringList.Create;
  CopyLL := TList.Create;
  for i := 0 to TableArea.LinkList.Count - 1 do
    CopyLL.Add(Pointer(i));
  while CopyLL.Count <> 0 do
  begin
    Tbl1 := TableArea.LinkList[0].SourceTable;
    Tbl2 := TableArea.LinkList[0].DestTable;
    slFrom.Add(strTab + Tbl1.TableName + ' ' + Tbl1.AliasName);
    slFrom.Add(strTab + FormingFrom(0));
    for i := 1 to CopyLL.Count - 1 do
    begin
      Tbl3 := TableArea.LinkList[i].DestTable;
  
      if (Tbl3.AliasName = Tbl2.AliasName) then
      begin
        slFrom[slFrom.Count - 1] := slFrom[slFrom.Count - 1] + FormingFromAnd(Integer(CopyLL[i]));
        CopyLL[i] := Pointer(-1);
      end
      else
      begin
        Tbl1 := TableArea.LinkList[Integer(CopyLL[i])].SourceTable;
        Tbl2 := Tbl3;
        slFrom.Add(strTab + FormingFrom(Integer(CopyLL[i])));
        CopyLL[i] := Pointer(-1)
       end
  
    end;
    CopyLL.Delete(0);
    for i := CopyLL.Count - 1 downto 0 do
      if Integer(CopyLL[i]) = -1 then CopyLL.Delete(i)
  end;
  
  flg := false;
  for i := 0 to Grid.Items.Count - 1 do
  begin
    tmpStr := TGridColumn(Grid.Items[i].Data^).Table + ' '
                     + TGridColumn(Grid.Items[i].Data^).Alias;
  
    if Pos(tmpStr, slFrom.Text) = 0 then
    begin
      if slFrom.Count <> 0 then
        slFrom[slFrom.Count - 1] := slFrom[slFrom.Count - 1] + ', ';
  
      slFrom.Add(strTab + tmpStr);
      flg := true
    end
  end;
  
  if flg then
    slFrom.Text := Copy(slFrom.Text,1,Length(slFrom.Text) - 2);
  
  CopyLL.Free;
  
  //WHERE
  slWhere := TStringList.Create;
  for i := 0 to Grid.Items.Count - 1 do
    if TGridColumn(Grid.Items[i].Data^).Where <> '' then
       slWhere.Add(strTab + TGridColumn(Grid.Items[i].Data^).Alias + '.'
                   + TGridColumn(Grid.Items[i].Data^).Field + ' ' 
                   + TGridColumn(Grid.Items[i].Data^).Where + ' AND');
  
  if slWhere.Count <> 0 then
  begin
    slWhere.Text:= Copy(slWhere.Text,1,Length(slWhere.Text) - 6);
    slWhere.Insert(0,strWhere)
  end;
  
  //ORDER
  orderStr:= '';
  prd:= '';
  flg:= false;
  for i:= 0 to Grid.Items.Count - 1 do
  begin
    if TGridColumn(Grid.Items[i].Data^).Sort <> 0 then
    begin
      if TGridColumn(Grid.Items[i].Data^).Sort = 2 then
              prd := 'DESC'
      else
              prd := '';
      orderStr:= orderStr + TGridColumn(Grid.Items[i].Data^).Alias + '.' +
                               TGridColumn(Grid.Items[i].Data^).Field + ' ' + prd + ', ';
      flg:= true;
    end;
  end;
  if flg then
    orderStr := Trim(Copy(orderStr,1,Length(orderStr) - 2));
  
  //GROUP
  groupStr:= '';
  flg:= false;
  for i:= 0 to Grid.Items.Count - 1 do
  begin
    if TGridColumn(Grid.Items[i].Data^).Group <> 0 then
    begin
      groupStr:= groupStr + TGridColumn(Grid.Items[i].Data^).Alias + '.' +
                            TGridColumn(Grid.Items[i].Data^).Field + ', ';
      flg:= true;
    end;
  end;
  if flg then groupStr:= Copy(groupStr,1,Length(groupStr) - 2);
  
  SQL.Add(strFrom);
  SQL.AddStrings(slFrom);
  SQL.AddStrings(slWhere);
  
  if orderStr <> '' then SQL.Add(strOrder + orderStr);
  
  if groupStr <> '' then SQL.Add(strGroup + groupStr);
  
  slFrom.Free;
  slWhere.Free;

  FText := SQL.Text;
  Result := SQL.Text;
  SQL.Free
end;

function TfqbCore.GetEngine: TfqbEngine;
begin
  Result := FEngine;
  if not Assigned(FEngine) then
    raise EfqbError.Create('fqbCore.Engine not assigned');
  
end;

function TfqbCore.GetGrid: TfqbGrid;
begin
  Result := FGrid;
  if not Assigned(FGrid) then
    raise EfqbError.Create('fqbCore.Grid not assigned');
end;

function TfqbCore.GetSQL: string;
begin
  if SchemaInsideSQL then
    Result := Ftext
  else
  Result := fqbCore.ExtractSQL(Ftext);
end;

function TfqbCore.GetSQLSchema: string;
begin
  if SchemaInsideSQL then
    Result := ''
  else
    Result := fqbCore.ExtractSchema(Ftext);
end;

function TfqbCore.GetTableArea: TfqbTableArea;
begin
  Result := FTableArea;
  if not Assigned(FTableArea) then
    raise EfqbError.Create('fqbCore.TableArea not assigned');
end;

procedure TfqbCore.LoadFromFile(const FileName: string);
var
  StrLst, StrSrc: TStringList;
  tmp, tmp2: string;
begin
  StrLst := TStringList.Create;
  StrSrc := TStringList.Create;
  StrSrc.LoadFromFile(FileName);
  
  try
    tmp2 := ExtractSQL(StrSrc.Text);
    tmp := ExtractSchema(StrSrc.Text);
  
    if fqbCore.FUseCoding then
    begin
      tmp := fqbTrim(tmp, [#10,#13]);
      if tmp = '' then Exit;
      tmp:= fqbDeCompress(tmp)
    end;
  
    StrLst.Clear;
    StrLst.Text := tmp;
  
    tmp := fqbGetUniqueFileName('fqb');
    StrLst.SaveToFile(tmp);
    tmp2 := fqbTrim(tmp2, [#10,#13]);
    fqbCore.RecognizeModel(fqbStringCRC32(tmp2), tmp);
  finally
    DeleteFile(tmp);
  
    StrLst.Free;
    StrSrc.Free;
  end;
end;

procedure TfqbCore.LoadFromStr(const Str: TStringList);
var
  tmp: string;
begin
  tmp := fqbGetUniqueFileName('fqb');
  Str.SaveToFile(tmp);
  try
    fqbCore.LoadFromFile(tmp);
  finally
    DeleteFile(tmp)
  end
end;

procedure TfqbCore.RecognizeModel(const crc32: Cardinal; const FileName: string);
var
  fqbFile: TIniFile;
  tbl: TStringList;
  i: Integer;
  Rec: TRect;
  parstr, tmpstr: string;
  vis: TfqbTable;
  lnk: TfqbLink;
  c: Cardinal;
  
  function IndexOf(const FieldName: string): integer;
    var
      i: integer;
  begin
    Result:= -1;
    for i:= 0 to vis.FieldList.Count - 1 do
      if TfqbField(vis.FieldList[i]).FieldName = FieldName then
        Result:= i;
   end;
  
begin
  fqbFile:= TIniFile.Create(FileName);
  tbl:= TStringList.Create;
  tmpstr := fqbFile.ReadString('DataBase','SQL','');
  c := StrToInt64(tmpstr);
  if c <> crc32 then
  begin
    ShowMessage('The file was changed. The Model can not be loaded.');
    fqbFile.Free;
    tbl.Free;
    Exit
  end;
  try
    fqbCore.Engine.ReadTableList(TfqbTableListBox(FindFQBcomp('TfqbTableListBox',GetParentForm(TableArea))).Items);
    fqbFile.ReadSectionValues('Tables',tbl);
    try
      for i:= 0 to tbl.Count - 1 do
      begin
        parstr:= tbl.Values[tbl.Names[i]];
        tmpstr:= fqbParse(',',parstr,1);
        Rec.Top:= StrToInt(fqbParse(',',parstr,2));
        Rec.Left:= StrToInt(fqbParse(',',parstr,3));
        Rec.Right:= StrToInt(fqbParse(',',parstr,4));
        Rec.Bottom:= StrToInt(fqbParse(',',parstr,5));
        TableArea.InsertTable(Rec.Left, Rec.Top, tmpstr);
        TfqbTable(TableArea.Components[i]).Height:= Rec.Right;
        TfqbTable(TableArea.Components[i]).Width:= Rec.Bottom
      end
    except
      fqbCore.Clear;
      Exit
    end;
    tbl.Clear;
    fqbFile.ReadSectionValues('Grid',tbl);
    try
      for i:= 0 to tbl.Count - 1 do
      begin
        parstr:=tbl.Values[tbl.Names[i]];
        vis:= TableArea.FindTable(fqbParse(',',parstr,2),fqbParse(',',parstr,3));
        if vis = nil then Exit;
  
        vis.ChBox.Checked[IndexOf(fqbParse(',',parstr,1))]:= true;
        vis.ChBox.ItemIndex:= IndexOf(fqbParse(',',parstr,1));
        vis.ChBox.ClickCheck;
  
  //        n:= Grid.Items.Count - 1;
  
        TGridColumn(Grid.Items[i].Data^).Table:= fqbParse(',',parstr,2);
        TGridColumn(Grid.Items[i].Data^).Alias:= fqbParse(',',parstr,3);
        TGridColumn(Grid.Items[i].Data^).Field:= fqbParse(',',parstr,1);
        TGridColumn(Grid.Items[i].Data^).Visibl:= Boolean(StrToInt(fqbParse(',',parstr,4)));
        TGridColumn(Grid.Items[i].Data^).Sort:= StrToInt(fqbParse(',',parstr,5));
        TGridColumn(Grid.Items[i].Data^).Func:= StrToInt(fqbParse(',',parstr,6));
        TGridColumn(Grid.Items[i].Data^).Group:= StrToInt(fqbParse(',',parstr,7));
        TGridColumn(Grid.Items[i].Data^).Where:= fqbParse(',',parstr,8, True);

      //  format:
      //      field_name = table_name, alias, visible, sorting, function, group, where
        end;
      except
        fqbCore.Clear;
        Exit
      end;
      tbl.Clear;
      fqbFile.ReadSectionValues('Links',tbl);
      try
        for i:= 0 to tbl.Count - 1 do
        begin
          parstr:=tbl.Values[tbl.Names[i]];
  
          lnk:= TfqbLink(TableArea.LinkList.Add);
          lnk.FArea:= TableArea;
          lnk.FSourceTable := TfqbTable(TableArea.Components[StrToInt(fqbParse(',',parstr,2))]);
          lnk.FSourceField := lnk.SourceTable.FieldList[StrToInt(fqbParse(',',parstr,1))];
          lnk.SourceField.Linked := True;

          lnk.FDestTable := TfqbTable(TableArea.Components[StrToInt(fqbParse(',',parstr,4))]);
          lnk.FDestField := lnk.DestTable.FieldList[StrToInt(fqbParse(',',parstr,3))];
          lnk.FDestField.Linked := True;

          lnk.FJType := StrToInt(fqbParse(',',parstr, 5));
          lnk.FJOp := StrToInt(fqbParse(',',parstr, 6));
      //  format:
      //      index = sind,slst,dind,dlst,JType,JOper
        end;
      except
        fqbCore.Clear;
        Exit
      end;
      Grid.UpdateColumn;
    finally
      fqbFile.Free;
      tbl.Free
    end
end;

procedure TfqbCore.SaveToFile(const FileName: string);
var
  tmp: TStringList;
begin
  tmp := TStringList.Create;
  fqbCore.SaveToStr(tmp);
  tmp.SaveToFile(FileName);
  tmp.Free;
end;

procedure TfqbCore.SaveToStr(var Str: TStringList);
var
  i: Integer;
  tmp, tmp2: string;
begin
  Str.Clear;
  tmp2 := fqbCore.GenerateSQL;
  tmp := fqbTrim(tmp2, [#10,#13]);
  
  if tmp = '' then Exit;
  
  Str.Add('[DataBase]');
  Str.Add('SQL=' + IntToStr(fqbStringCRC32(tmp)));

  Str.Add('[Tables]');
  for i:= 0 to TableArea.ComponentCount - 1 do
  begin
    tmp := TfqbTable(TableArea.Components[i]).AliasName + '=';
    tmp := tmp + TfqbTAble(TableArea.Components[i]).TableName;
    tmp := tmp + ',' + IntToStr(TfqbTable(TableArea.Components[i]).Top);
    tmp := tmp + ',' + IntToStr(TfqbTable(TableArea.Components[i]).Left);
    tmp := tmp + ',' + IntToStr(TfqbTable(TableArea.Components[i]).Height);
    tmp := tmp + ',' + IntToStr(TfqbTable(TableArea.Components[i]).Width);
    Str.Add(tmp);
  //  format:
  //      alias= tablename,top,left,height,width
  end;
  
  Str.Add('[Grid]');
  for i:= 0 to Grid.Items.Count - 1 do
  begin
    tmp := IntToStr(i) + '=';
    tmp:= tmp + TGridColumn(Grid.Items[i].Data^).Field;
    tmp:= tmp + ',' + TGridColumn(Grid.Items[i].Data^).Table;
    tmp:= tmp + ',' + TGridColumn(Grid.Items[i].Data^).Alias;
    tmp:= tmp + ',' + IntToStr(Integer(TGridColumn(Grid.Items[i].Data^).Visibl));
    tmp:= tmp + ',' + IntToStr(TGridColumn(Grid.Items[i].Data^).Sort);
    tmp:= tmp + ',' + IntToStr(TGridColumn(Grid.Items[i].Data^).Func);
    tmp:= tmp + ',' + IntToStr(TGridColumn(Grid.Items[i].Data^).Group);
    tmp:= tmp + ',' + TGridColumn(Grid.Items[i].Data^).Where;
    Str.Add(tmp);
  //  format:
  //      field_name = table_name, alias, visible, sorting, function, group, where
  end;
  
  Str.Add('[Links]');
  for i:= 0 to TableArea.LinkList.Count - 1 do
  begin
    tmp:= IntToStr(i) + '=';
    tmp:= tmp + IntToStr(TableArea.LinkList[i].SourceField.Index);
    tmp:= tmp + ',' + IntToStr(TableArea.LinkList[i].SourceTable.ComponentIndex);
    tmp:= tmp + ',' + IntToStr(TableArea.LinkList[i].DestField.Index);
    tmp:= tmp + ',' + IntToStr(TableArea.LinkList[i].DestTable.ComponentIndex);
    tmp:= tmp + ',' + IntToStr(TfqbLink(TableArea.LinkList[i]).JoinType);
    tmp:= tmp + ',' + IntToStr(TfqbLink(TableArea.LinkList[i]).JoinOperator);
    Str.Add(tmp);
  //  format:
  //      index = sind,slst,dind,dlst,JType,JOper
  end;
  
  if fqbCore.FUseCoding then
    tmp := fqbCompress(str.Text)
  else
    tmp := str.Text;
  
  Str.Clear;
  Str.Add(tmp2);
  Str.Add(_fqbBeginModel);
  Str.Add(tmp);
  Str.Add(_fqbEndModel);
end;

procedure TfqbCore.SetSchemaInsideSQL(const Value: Boolean);
begin
  FSchemaInsideSQL := Value;
  if SchemaInsideSQL then
  begin
    FSQL := fqbCore.ExtractSQL(Ftext);
    FSQLSchema := fqbCore.ExtractSchema(Ftext);
  end
end;

procedure TfqbCore.SetSQL(Value: string);
begin
  FSQL := fqbCore.ExtractSQL(Value);
  FSQLSchema := fqbCore.ExtractSchema(Value);
  Ftext := FSQL + _fqbBeginModel + #$D#$A + FSQLSchema + #$D#$A + _fqbEndModel
end;

procedure TfqbCore.SetSQLSchema(const Value: string);
begin
  FSQLSchema := fqbCore.ExtractSchema(Value);
  Ftext := FSQL + _fqbBeginModel + #$D#$A + FSQLSchema + #$D#$A + _fqbEndModel
end;

{-----------------------  TfqbCheckListBox -----------------------}
procedure TfqbCheckListBox.ClickCheck;
var
  tmp: TfqbGrid;
  tbl: TfqbTable;
  i: Integer;
begin
  tmp := fqbCore.Grid;
  tbl := (Parent as TfqbTable);
  
  if not Assigned(tmp) then
    raise EfqbError.Create('Class TfqbGrid not fount on form.');
  
  if State[ItemIndex] = cbChecked then
  begin
    i:= tmp.AddColumn;
    TGridColumn(tmp.Items[i].Data^).Table:= tbl.TableName;
    TGridColumn(tmp.Items[i].Data^).Field:= tbl.FieldList[ItemIndex].FieldName;
    TGridColumn(tmp.Items[i].Data^).Alias:= tbl.AliasName;
    TGridColumn(tmp.Items[i].Data^).Where:= '';
    TGridColumn(tmp.Items[i].Data^).Sort:= 0;
    TGridColumn(tmp.Items[i].Data^).Func:= 0;
    TGridColumn(tmp.Items[i].Data^).Group:= 0;
    TGridColumn(tmp.Items[i].Data^).Visibl:= True
  end
  else
  if State[ItemIndex] = cbUnchecked then
  begin
    for i:= tmp.Items.Count - 1 downto 0 do
    begin
      if ((TGridColumn(tmp.Items[i].Data^).Table = tbl.TableName)
          and (TGridColumn(tmp.Items[i].Data^).Field = tbl.FieldList[ItemIndex].FieldName)) then
      begin
        FreeMem(tmp.Items[i].Data, SizeOf(TGridColumn));
        tmp.Items.Delete(i)
      end
    end
  end;
  tmp.UpdateColumn;
  Repaint;
  inherited ClickCheck;
end;

procedure TfqbCheckListBox.DragDrop(Sender: TObject; X, Y: Integer);
var
  lnk: TfqbLink;
begin
  lnk := (Parent.Parent as TfqbTableArea).LinkList.Add;
  lnk.FArea := Parent.Parent as TfqbTableArea;
  lnk.FSourceField := ((Sender as TControl).Parent as TfqbTable).SellectedField;
  lnk.FSourceField.Linked := true;
  lnk.FSourceTable := (Sender as TControl).Parent as TfqbTable;
  
  lnk.FDestField := (Self.Parent as TfqbTable).SellectedField;
  lnk.FDestField.Linked := true;
  lnk.FDestTable := Self.Parent as TfqbTable;
  
  TfqbTableArea(Parent.Parent).Invalidate;
  TfqbTable((Sender as TControl).Parent).Invalidate;
  Invalidate
end;

procedure TfqbCheckListBox.DragOver(Sender: TObject; X, Y: Integer; State:
               TDragState; var Accept: Boolean);
var
  int: Integer;
begin
  Accept := False;
  if ((not (Sender is TfqbCheckListBox)) or
      (Self = Sender)) then Exit;
  
  int := (Self as TfqbCheckListBox).ItemAtPos(Point(X,Y),True);
  
  if (int > (Self as TfqbCheckListBox).Items.Count - 1) or (int < 0) then
    Exit;
  
  (Self as TfqbCheckListBox).ItemIndex:= int;
  if not (Parent.Parent as TfqbTableArea).CompareFields(Parent.ComponentIndex, int, (Sender as TfqbCheckListBox).Parent.ComponentIndex, (Sender as TfqbCheckListBox).ItemIndex)
    then Exit;
  
  Accept := True
end;

{-----------------------  TfqbGrid -----------------------}
constructor TfqbGrid.Create(AOwner: TComponent);
var
  i: Integer;
  mi: TMenuItem;
begin
  inherited Create(AOwner);
  for i:= 0 to 5 do
    with Columns.Add do
    begin
      case i of
        rowColumn    : Caption := fqbGet(1820);
        rowVisibility: Caption := fqbGet(1821);
        rowWhere     : Caption := fqbGet(1822);
        rowSort      : Caption := fqbGet(1823);
        rowFunction  : Caption := fqbGet(1824);
        rowGroup     : Caption := fqbGet(1825);
      end;
      Width := 80;
    end;

  ViewStyle := vsReport;
  ColumnClick := False;
  HideSelection := False;
  Width := 300;
  DragMode := dmAutomatic;
  
  OnSelectItem := fqbOnSelectItem;
  
  FPopupMenu := TPopupMenu.Create(Self);
  mi := TMenuItem.Create(FPopupMenu);
  mi.Caption := fqbGet(1826);
  mi.OnClick := fqbOnMenu;
  mi.Tag := -1;
  FPopupMenu.Items.Add(mi);
  mi := TMenuItem.Create(FPopupMenu);
  mi.Caption := fqbGet(1827);
  mi.OnClick := fqbOnMenu;
  mi.Tag := 1;
  FPopupMenu.Items.Add(mi);
  
  FPopupMenu.OnPopup := fqbOnPopup;
  PopupMenu := FPopupMenu;
end;

destructor TfqbGrid.Destroy;
var
  i: Integer;
begin
  for i:= 0 to Items.Count - 1 do
    Dispose(PGridColumn(Items[i]));
  inherited
end;

function TfqbGrid.AddColumn: Integer;
var
  tmp: TListItem;
  p: PGridColumn;
begin
  tmp := Items.Add;
  tmp.SubItems.Add('');
  tmp.SubItems.Add('');
  tmp.SubItems.Add('');
  tmp.SubItems.Add('');
  tmp.SubItems.Add('');
  
  New(p);
  tmp.Data := p;
  
  Result:= tmp.Index
end;

procedure TfqbGrid.CreateWnd;
var
  wnd: HWND;
begin
  inherited CreateWnd;
  
  FVisibleList := TComboBox.Create(Self);
  FVisibleList.Visible := false;
  FVisibleList.Parent := Self;
  FVisibleList.Style := csOwnerDrawFixed;
  FVisibleList.ItemHeight := 12;
  FVisibleList.Items.Add(fqbGet(1828));
  FVisibleList.Items.Add(fqbGet(1829));
  FVisibleList.OnChange := fqbOnChange;
  FVisibleList.Tag := rowVisibility;
  
  FWhereEditor:= TfqbEdit.Create(Self);
  FWhereEditor.Visible := false;
  FWhereEditor.Parent := Self;
  FWhereEditor.OnChange := fqbOnChange;
  FWhereEditor.Tag := rowWhere;
  
  FSortList := TComboBox.Create(Self);
  FSortList.Visible := false;
  FSortList.Parent := Self;
  FSortList.Style := csOwnerDrawFixed;
  FSortList.ItemHeight := 12;
  FSortList.Items.Add(fqbGet(1830));
  FSortList.Items.Add(fqbGet(1831));
  FSortList.Items.Add(fqbGet(1832));
  FSortList.OnChange := fqbOnChange;
  FSortList.Tag := rowSort;
  
  FFunctionList := TComboBox.Create(Self);
  FFunctionList.Visible := false;
  FFunctionList.Parent := Self;
  FFunctionList.Style := csOwnerDrawFixed;
  FFunctionList.ItemHeight := 12;
  FFunctionList.Items.Add(fqbGet(1830));
  FFunctionList.Items.Add('AVG');
  FFunctionList.Items.Add('COUNT');
  FFunctionList.Items.Add('MAX');
  FFunctionList.Items.Add('MIN');
  FFunctionList.Items.Add('SUM');
  FFunctionList.OnChange := fqbOnChange;
  FFunctionList.Tag := rowFunction;
  
  FGroupList := TComboBox.Create(Self);
  FGroupList.Visible := False;
  FGroupList.Parent := Self;
  FGroupList.Style := csOwnerDrawFixed;
  FGroupList.ItemHeight := 12;
  FGroupList.Items.Add(fqbGet(1830));
  FGroupList.Items.Add(fqbGet(1833));
  FGroupList.OnChange := fqbOnChange;
  FGroupList.Tag := rowGroup;

  RecalcColWidth;
  
  wnd := GetWindow(Handle, GW_CHILD);
  SetWindowLong(wnd, GWL_STYLE, GetWindowLong(wnd, GWL_STYLE) and not HDS_FULLDRAG)
end;

procedure TfqbGrid.DoColumnResize(ColumnIndex, ColumnWidth: Integer);
begin
  //  RecalcColWidth;
  fqbUpdate;
  if Assigned(FEndColumnResizeEvent) then
    FEndColumnResizeEvent(Self, ColumnIndex, ColumnWidth)
end;

procedure TfqbGrid.Exchange(const AItm1, AItm2: integer);
var
  tmpStr: string;
  tmpDat: Pointer;
begin
  tmpStr := Items[AItm1].Caption;
  tmpDat := Items[AItm1].Data;
  
  Items[AItm1].Caption := Items[AItm2].Caption;
  Items[AItm1].Data := Items[AItm2].Data;
  
  Items[AItm2].Caption := tmpStr;
  Items[AItm2].Data := tmpDat;
  
  fqbUpdate;
end;

function TfqbGrid.FindColumnIndex(pHeader: pNMHdr): Integer;
var
  hwndHeader: HWND;
  ItemInfo: THdItem;
  ItemIndex: Integer;
  buf: array [0..128] of Char;
begin
  Result := -1;
  hwndHeader := pHeader^.hwndFrom;
  ItemIndex := pHDNotify(pHeader)^.Item;
  FillChar(iteminfo, SizeOf(iteminfo), 0);
  iteminfo.Mask := HDI_TEXT;
  iteminfo.pszText := buf;
  iteminfo.cchTextMax := SizeOf(buf) - 1;
  Header_GetItem(hwndHeader, ItemIndex, iteminfo);
  if CompareStr(Columns[ItemIndex].Caption, iteminfo.pszText) = 0 then
    Result := ItemIndex
  else
  begin
    for ItemIndex := 0 to Columns.Count - 1 do
      if CompareStr(Columns[ItemIndex].Caption, iteminfo.pszText) = 0 then
      begin
        Result := ItemIndex;
        Break;
      end
  end
end;

function TfqbGrid.FindColumnWidth(pHeader: pNMHdr): Integer;
begin
  Result := -1;
  if Assigned(PHDNotify(pHeader)^.pItem) and
    ((PHDNotify(pHeader)^.pItem^.mask and HDI_WIDTH) <> 0) then
    Result := PHDNotify(pHeader)^.pItem^.cxy;
end;

procedure TfqbGrid.fqbOnChange(Sender: TObject);
var
  tmp: TcrTControl;
begin
  if Selected = nil then Exit;
  tmp := TcrTControl(Sender);
  if tmp.ClassName = 'TComboBox' then
    if TComboBox(tmp).ItemIndex = 0 then
      Selected.SubItems[tmp.tag - 1] := ''
    else
      Selected.SubItems[tmp.tag - 1] := tmp.Text;
  
  if tmp.ClassName = 'TfqbEdit' then
    Selected.SubItems[tmp.tag - 1] := tmp.Text;
  
  if tmp.tag = rowVisibility then
    TGridColumn(Selected.Data^).Visibl := (TComboBox(tmp).ItemIndex = 0);
  if tmp.tag = rowWhere then
    TGridColumn(Selected.Data^).Where := tmp.Caption;
  if tmp.tag = rowSort then
      TGridColumn(Selected.Data^).Sort := TComboBox(tmp).ItemIndex;
  if tmp.tag = rowFunction then
      TGridColumn(Selected.Data^).Func := TComboBox(tmp).ItemIndex;
  if tmp.tag = rowGroup then
      TGridColumn(Selected.Data^).Group := TComboBox(tmp).ItemIndex;
end;

procedure TfqbGrid.fqbOnMenu(Sender: TObject);
begin
  Exchange(Selected.Index, Selected.Index + (Sender as TComponent).Tag);
  Items[Selected.Index + (Sender as TComponent).Tag].Selected := True;
  UpdateColumn
end;

procedure TfqbGrid.fqbOnPopup(Sender: TObject);
begin
  if Assigned(Selected) then
  begin
    FPopupMenu.Items[0].Enabled := Selected.Index <> 0;
    FPopupMenu.Items[1].Enabled := Selected.Index <> Items.Count - 1;
  end
  else
  begin
    FPopupMenu.Items[0].Enabled := False;
    FPopupMenu.Items[1].Enabled := False;
  end
end;

procedure TfqbGrid.fqbOnSelectItem(Sender: TObject; Item: TListItem; Selected:
               Boolean);
var
  tmp: TfqbTableArea;
  tbl: TfqbTable;
  i: Integer;
begin
  fqbUpdate;
  tmp := fqbCore.TableArea;
  if not Assigned(tmp) then Exit;
  tbl := tmp.FindTable(TGridColumn(Item.Data^).Table, TGridColumn(Item.Data^).Alias);
  if not Assigned(tbl) then Exit;
  tbl.BringToFront;
  for i:= 0 to tbl.FieldList.Count - 1 do
    if tbl.FieldList[i].FieldName = TGridColumn(Item.Data^).Field then
      tbl.ChBox.ItemIndex := i;
end;

procedure TfqbGrid.fqbSetBounds(var Contr: TControl);
var
  i: Integer;
begin
  Contr.Visible := false;
  if Selected = nil then Exit;
  if Assigned(TopItem) then
    if TopItem.Index > Selected.Index then Exit;
  Contr.Width := Columns[Contr.Tag].Width + 1;
  Contr.Top := Selected.Top - 2;
  Contr.Left := 0;
  for i:= 0 to Contr.Tag - 1  do
    Contr.Left := Contr.Left + Columns[i].Width;
  Contr.Height := 19;
  if Contr.ClassName = 'TComboBox' then
    begin
      TComboBox(Contr).ItemIndex := TComboBox(Contr).Items.IndexOf(Selected.SubItems[Contr.Tag - 1]);
    end
  else
  if Contr.ClassName = 'TfqbEdit' then
    begin
      TcrTControl(Contr).Text := Selected.SubItems[Contr.Tag - 1];
    end;
  Contr.Visible := true;
end;

procedure TfqbGrid.fqbUpdate;
begin
  if not (Assigned(FVisibleList) and Assigned(FWhereEditor)
      and Assigned(FSortList) and Assigned(FFunctionList)
      and Assigned(FGroupList)) then Exit;
  fqbSetBounds(TControl(FVisibleList));
  fqbSetBounds(TControl(FWhereEditor));
  fqbSetBounds(TControl(FSortList));
  fqbSetBounds(TControl(FFunctionList));
  fqbSetBounds(TControl(FGroupList));
  FWhereEditor.Height := 18;
end;

procedure TfqbGrid.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Selected := GetItemAt(5, Y);
  ItemFocused := Selected
end;

procedure TfqbGrid.RecalcColWidth;
var
  i, n: Integer;
  w, dw: Integer;
  p: Real;
begin
  if not Assigned(FVisibleList) then
    Exit;
  w:= 0;
  n := Columns.Count - 1;
  for i := 0 to n do
    w := w + Columns[i].Width;
  dw := 0;
  for i := 0 to n do
  begin
    p :=  Columns[i].Width / w;
    Columns[i].Width := Round(p * (Width - 4));
    dw := dw + Columns[i].Width;
  end;
  Columns[n].Width := Columns[n].Width + (Width - dw - 4);
end;

procedure TfqbGrid.Resize;
begin
  inherited;
  RecalcColWidth;
  fqbUpdate
end;

procedure TfqbGrid.UpdateColumn;
var
  i: Integer;
begin
  for i:= 0 to Items.Count - 1 do
  begin
    Items[i].Caption := TGridColumn(Items[i].Data^).Field;
  
    if TGridColumn(Items[i].Data^).Visibl then
       Items[i].SubItems[rowVisibility - 1] := ''
    else
       Items[i].SubItems[rowVisibility - 1] := FVisibleList.Items[1];
  
    Items[i].SubItems[rowWhere - 1]:= TGridColumn(Items[i].Data^).Where;
  
    if TGridColumn(Items[i].Data^).Sort = 0 then
      Items[i].SubItems[rowSort - 1]:= ''
    else
      Items[i].SubItems[rowSort - 1]:= FSortList.Items[TGridColumn(Items[i].Data^).Sort];
  
    if TGridColumn(Items[i].Data^).Func = 0 then
      Items[i].SubItems[rowFunction - 1]:= ''
    else
      Items[i].SubItems[rowFunction - 1]:= FFunctionList.Items[TGridColumn(Items[i].Data^).Func];
  
    if TGridColumn(Items[i].Data^).Group = 0 then
      Items[i].SubItems[rowGroup - 1]:= ''
    else
      Items[i].SubItems[rowGroup - 1]:= FGroupList.Items[TGridColumn(Items[i].Data^).Group];
  end
end;

procedure TfqbGrid.WMNotify(var Msg: TWMNotify);
begin
  inherited;
  case Msg.NMHdr^.code of
    HDN_ENDTRACK:
      DoColumnResize(FindColumnIndex(Msg.NMHdr), FindColumnWidth(Msg.NMHdr));
  end
end;

procedure TfqbGrid.WMVscroll(var Msg: TWMNotify);
begin
  inherited;
  fqbUpdate
end;

{-----------------------  TfqbEdit -----------------------}
constructor TfqbEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPanel := TPanel.Create(Self);
  FPanel.Parent := Self;
  FPanel.Align := alRight;
  FPanel.Width := Height - 3;
  FPanel.BevelOuter := bvNone;
  
  FButton := TSpeedButton.Create(Self);
  FButton.Parent := FPanel;
  FButton.Align := alClient;
  FButton.OnClick := ButtonClick;
end;

procedure TfqbEdit.ButtonClick(Sender: TObject);
begin
  SetFocus;
  if Assigned(FOnButtonClick) then
    FOnButtonClick(Self);
end;

procedure TfqbEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or WS_CLIPCHILDREN;
end;

procedure TfqbEdit.CreateWnd;
begin
  inherited;
  ShowButton := false;
end;

procedure TfqbEdit.SetEditRect;
var
  Rec: TRect;
begin
  SendMessage(Handle, EM_GETRECT, 0, LongInt(@Rec));
  if ShowButton then
  begin
    Rec.Bottom := ClientHeight + 1;
    Rec.Right := ClientWidth - FPanel.Width - 1
  end
  else
  begin
    Rec.Bottom := ClientHeight + 1;
    Rec.Right := ClientWidth;
  end;
  Rec.Top := 0;
  Rec.Left := 0;
  SendMessage(Handle, EM_SETRECTNP, 0, LongInt(@Rec));
end;

procedure TfqbEdit.SetShowButton(const Value: Boolean);
begin
  FShowButton := Value;
  FPanel.Visible := Value;
  SetEditRect
end;

procedure TfqbEdit.WMSize(var Message: TWMSize);
begin
  inherited;
  SetEditRect
end;

procedure TfqbTable.CMRelease(var Message: TMessage);
begin
  Free
end;

initialization
  RegisterClasses([TComboBox, TfqbEdit]);

finalization
  if FfqbCore <> nil then
    FfqbCore.Free;

end.
