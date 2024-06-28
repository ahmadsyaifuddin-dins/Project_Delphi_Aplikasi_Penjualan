
{******************************************}
{                                          }
{             FastReport v4.0              }
{       Common designer workspace          }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxDesgnWorkspace;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, frxClass, frxUnicodeCtrls
{$IFDEF Delphi6}
, Variants
{$ENDIF};


const
  crPencil = 11;

type
  TfrxDesignMode = (dmSelect, dmInsert, dmDrag);
  TfrxDesignMode1 = (dmNone, dmMove, dmSize, dmSizeBand, dmScale,
    dmInplaceEdit, dmSelectionRect, dmInsertObject, dmInsertLine,
    dmMoveGuide, dmContainer);
  TfrxGridType = (gt1pt, gt1cm, gt1in, gtDialog, gtChar, gtNone);
  TfrxCursorType = (ct0, ct1, ct2, ct3, ct4, ct5, ct6, ct7, ct8, ct9, ct10);
  TfrxNotifyPositionEvent = procedure (ARect: TfrxRect) of object;

  TfrxInsertion = packed record
    ComponentClass: TfrxComponentClass;
    Left: Extended;
    Top: Extended;
    Width: Extended;
    Height: Extended;
    OriginalWidth: Extended;
    OriginalHeight: Extended;
    Flags: Word;
  end;

  TfrxDesignerWorkspace = class(TPanel)
  protected
    FBandHeader: Extended;
    FCanvas: TCanvas;
    FColor: TColor;
    FCT: TfrxCursorType;
    FDblClicked: Boolean;
    FDisableUpdate: Boolean;
    FFreeBandsPlacement: Boolean;
    FGapBetweenBands: Integer;
    FGridAlign: Boolean;
    FGridLCD: Boolean;
    FGridType: TfrxGridType;
    FGridX: Extended;
    FGridY: Extended;
    FInplaceMemo: TUnicodeMemo;
    FInplaceObject: TfrxCustomMemoView;
    FInsertion: TfrxInsertion;
    FLastMousePointX: Extended;
    FLastMousePointY: Extended;
    FMargins: TRect;
    FMarginsPanel: TPanel;
    FMode: TfrxDesignMode;
    FMode1: TfrxDesignMode1;
    FModifyFlag: Boolean;
    FMouseDown: Boolean;
    FObjects: TList;
    FOffsetX: Extended;
    FOffsetY: Extended;
    FPage: TfrxPage;
    FPageHeight: Integer;
    FPageWidth: Integer;
    FScale: Extended;
    FScaleRect: TfrxRect;
    FScaleRect1: TfrxRect;
    FSelectedObjects: TList;
    FSelectionRect: TfrxRect;
    FShowBandCaptions: Boolean;
    FShowEdges: Boolean;
    FShowGrid: Boolean;
    FSizedBand: TfrxBand;
    FOnModify: TNotifyEvent;
    FOnEdit: TNotifyEvent;
    FOnInsert: TNotifyEvent;
    FOnNotifyPosition: TfrxNotifyPositionEvent;
    FOnSelectionChanged: TNotifyEvent;
    FOnTopLeftChanged: TNotifyEvent;
    procedure DoModify;
    procedure AdjustBandHeight(Bnd: TfrxBand);
    procedure CheckGuides(var kx, ky: Extended; var Result: Boolean); virtual;
    procedure DoNudge(dx, dy: Extended);
    procedure DoSize(dx, dy: Extended);
    procedure DoStick(dx, dy: Integer);
    procedure DoTab;
    procedure DrawBackground;
    procedure DrawCross(Down: Boolean);
    procedure DrawInsertionRect;
    procedure DrawObjects; virtual;
    procedure DrawSelectionRect;
    procedure FindNearest(dx, dy: Integer);
    procedure MouseLeave;
    procedure NormalizeCoord(c: TfrxComponent);
    procedure NormalizeRect(var R: TfrxRect);
    procedure SelectionChanged;
    procedure SetScale(Value: Extended);
    procedure SetShowBandCaptions(const Value: Boolean);
    procedure UpdateBandHeader;

    procedure DblClick; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMMove(var Message: TWMMove); message WM_MOVE;
    procedure WMEraseBackground(var Message: TMessage); message WM_ERASEBKGND;

    procedure SetColor(const Value: TColor);
    procedure SetGridType(const Value: TfrxGridType);
    procedure SetOrigin(const Value: TPoint);
    procedure SetParent(AParent: TWinControl); override;
    procedure SetShowGrid(const Value: Boolean);
    function GetOrigin: TPoint;
    function GetRightBottomObject: TfrxComponent;
    function GetSelectionBounds: TfrxRect;
    function ListsEqual(List1, List2: TList): Boolean;
    function SelectedCount: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
    procedure AdjustBands;
    procedure DeleteObjects; virtual;
    procedure DisableUpdate;
    procedure EnableUpdate;
    procedure EditObject; virtual;
    procedure GroupObjects;
    procedure UngroupObjects;
    procedure SetInsertion(AClass: TfrxComponentClass;
      AWidth, AHeight: Extended; AFlag: Word); virtual;
    procedure SetPageDimensions(AWidth, AHeight: Integer; AMargins: TRect);
    procedure UpdateView;

    property BandHeader: Extended read FBandHeader write FBandHeader;
    property Color: TColor read FColor write SetColor;
    property FreeBandsPlacement: Boolean read FFreeBandsPlacement write FFreeBandsPlacement;
    property GapBetweenBands: Integer read FGapBetweenBands write FGapBetweenBands;
    property GridAlign: Boolean read FGridAlign write FGridAlign;
    property GridLCD: Boolean read FGridLCD write FGridLCD;
    property GridType: TfrxGridType read FGridType write SetGridType;
    property GridX: Extended read FGridX write FGridX;
    property GridY: Extended read FGridY write FGridY;
    property Insertion: TfrxInsertion read FInsertion;
    property IsMouseDown: Boolean read FMouseDown;
    property Mode: TfrxDesignMode1 read FMode1;
    property Objects: TList read FObjects write FObjects;
    property OffsetX: Extended read FOffsetX write FOffsetX;
    property OffsetY: Extended read FOffsetY write FOffsetY;
    property Origin: TPoint read GetOrigin write SetOrigin;
    property Page: TfrxPage read FPage write FPage;
    property Scale: Extended read FScale write SetScale;
    property SelectedObjects: TList read FSelectedObjects write FSelectedObjects;
    property ShowBandCaptions: Boolean read FShowBandCaptions write SetShowBandCaptions;
    property ShowEdges: Boolean read FShowEdges write FShowEdges;
    property ShowGrid: Boolean read FShowGrid write SetShowGrid;
    property OnModify: TNotifyEvent read FOnModify write FOnModify;
    property OnEdit: TNotifyEvent read FOnEdit write FOnEdit;
    property OnInsert: TNotifyEvent read FOnInsert write FOnInsert;
    property OnNotifyPosition: TfrxNotifyPositionEvent read FOnNotifyPosition write
      FOnNotifyPosition;
    property OnSelectionChanged: TNotifyEvent read FOnSelectionChanged write
      FOnSelectionChanged;
    property OnTopLeftChanged: TNotifyEvent read FOnTopLeftChanged write
      FOnTopLeftChanged;
  end;

  TInplaceMemo = class(TUnicodeMemo)
  private
    FDesigner: TfrxDesignerWorkspace;
    FObject: TfrxCustomMemoView;
    FOriginalSize: TSize;
    procedure LinesChange(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    procedure Edit(c: TfrxCustomMemoView);
    procedure EditDone;
    procedure KeyPress(var Key: Char); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
  end;


implementation

{$R *.res}

uses frxRes, frxDMPClass, frxUtils, frxCtrls;

const
  DefFontName = 'Tahoma';


type
  TMarginsPanel = class(TPanel)
  protected
    FWorkspace: TfrxDesignerWorkspace;
    procedure WMEraseBackground(var Message: TMessage); message WM_ERASEBKGND;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
  end;

  THackComponent = class(TfrxComponent);


{ TInplaceMemo }

constructor TInplaceMemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDesigner := TfrxDesignerWorkspace(AOwner);
  Parent := FDesigner;
  Visible := False;
  WordWrap := False;
  OnChange := LinesChange;
end;

procedure TInplaceMemo.Edit(c: TfrxCustomMemoView);
var
  s: WideString;
begin
  FObject := c;

  s := c.Text;
  if (s <> '') and (s[Length(s)] = #10) then
    Delete(s, Length(s) - 1, 2);
  Text := s;

  SetBounds(Round(c.AbsLeft * FDesigner.Scale), Round(c.AbsTop * FDesigner.Scale),
    Round(c.Width * FDesigner.Scale + 1), Round(c.Height * FDesigner.Scale + 1));
  FOriginalSize.cx := Width;
  FOriginalSize.cy := Height;

  Font.Assign(c.Font);
  Font.Height := Round(Font.Height * FDesigner.Scale);
  if c.Color = clNone then
    Color := clWhite else
    Color := c.Color;
  Ctl3D := False;
  BorderStyle := bsNone;

  Show;
  SetFocus;
  SelectAll;
end;

procedure TInplaceMemo.EditDone;
begin
  if Modified then
  begin
    FObject.Text := Text;
    if FOriginalSize.cx <> Width then
      FObject.Width := (Width + 5) / FDesigner.Scale;
    if FOriginalSize.cy <> Height then
      FObject.Height := (Height + 5) / FDesigner.Scale;
    FDesigner.FModifyFlag := True;
    FDesigner.DoModify;
  end;
  Hide;
  FDesigner.Repaint;
  FDesigner.Cursor := crDefault;
end;

procedure TInplaceMemo.KeyPress(var Key: Char);
begin
  if Key = #27 then
  begin
    Modified := False;
    EditDone;
  end;
end;

procedure TInplaceMemo.LinesChange(Sender: TObject);
var
  i, w0, w, h: Integer;
begin
  h := (-Font.Height + 3) * Lines.Count + 4;
  if h > Height - Font.Height then
    Height := h;

  FDesigner.Canvas.Font := Font;

  w := Width;
  for i := 0 to Lines.Count - 1 do
  begin
    w0 := FDesigner.Canvas.TextWidth(Lines[i]) + 6;
    if w0 > w then
      w := w0;
  end;

  if w > Width then
    Width := w;
end;

procedure TInplaceMemo.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  EditDone;
end;


{ TMarginsPanel }

constructor TMarginsPanel.Create(AOwner: TComponent);
begin
  inherited;
  Color := clWindow;
  BevelInner := bvNone;
  BevelOuter := bvNone;
end;

procedure TMarginsPanel.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  FWorkspace.MouseDown(Button, Shift, X - (FWorkspace.Left - Left),
    Y - (FWorkspace.Top - Top));
end;

procedure TMarginsPanel.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;

  if FWorkspace.FMode = dmSelect then
    FWorkspace.MouseMove(Shift, X - (FWorkspace.Left - Left),
      Y - (FWorkspace.Top - Top)) else
    FWorkspace.MouseLeave;
  Cursor := FWorkspace.Cursor;
end;

procedure TMarginsPanel.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  FWorkspace.MouseUp(Button, Shift, X - (FWorkspace.Left - Left),
    Y - (FWorkspace.Top - Top));
end;

procedure TMarginsPanel.Paint;
var
  r: TRect;
begin
  with Canvas do
  begin
    Brush.Color := Color;
    Pen.Color := $505050;
    Pen.Width := 1;
    Pen.Style := psSolid;

    Rectangle(0, 0, Width - 1, Height - 1);
    Polyline([Point(1, Height - 1), Point(Width - 1, Height - 1), Point(Width - 1, 0)]);

    Pixels[0, Height - 1] := clGray;
    Pixels[Width - 1, 0] := clGray;


    Pen.Color := clSilver;
    Pen.Style := psDot;
    with FWorkspace, FWorkspace.FMargins do
      r := Rect(Round(Left * FScale), Round(Top * FScale),
        Self.Width - Round(Right * FScale) + 1,
        Self.Height - Round(Bottom * FScale) + 1);

    Polyline([Point(r.Left - 1, r.Top - 1),
      Point(r.Left - 1, r.Bottom),
      Point(r.Right, r.Bottom),
      Point(r.Right, r.Top - 1),
      Point(r.Left - 1, r.Top - 1)]);
  end;
end;

procedure TMarginsPanel.WMEraseBackground(var Message: TMessage);
begin
//
end;


{ TfrxDesignerWorkspace }

constructor TfrxDesignerWorkspace.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FullRepaint := False;
  Screen.Cursors[crPencil] := LoadCursor(hInstance, 'frxPENCIL');

  FMarginsPanel := TMarginsPanel.Create(AOwner);
  TMarginsPanel(FMarginsPanel).FWorkspace := Self;
  FInplaceMemo := TInplaceMemo.Create(Self);

  FBandHeader := fr01cm * 5;
  FColor := clWhite;
  FGridAlign := True;
  FGridType := gt1cm;
  FGridX := fr01cm;
  FGridY := fr01cm;
  FMode := dmSelect;
  FMode1 := dmNone;
  FScale := 1;
  FShowGrid := True;
  FShowEdges := True;
end;

procedure TfrxDesignerWorkspace.SetParent(AParent: TWinControl);
begin
  if not (csDestroying in ComponentState) then
    FMarginsPanel.Parent := AParent;
  inherited;
end;

procedure TfrxDesignerWorkspace.DisableUpdate;
begin
  FDisableUpdate := True;
  FMode := dmSelect;
  FMode1 := dmNone;
end;

procedure TfrxDesignerWorkspace.EnableUpdate;
begin
  FDisableUpdate := False;
end;

procedure TfrxDesignerWorkspace.UpdateView;
var
  NotifyRect: TfrxRect;
begin
  Invalidate;
  if SelectedCount = 0 then
    NotifyRect := frxRect(0, 0, 0, 0) else
    NotifyRect := GetSelectionBounds;
  if Assigned(FOnNotifyPosition) then
    FOnNotifyPosition(NotifyRect);
end;

procedure TfrxDesignerWorkspace.WMMove(var Message: TWMMove);
begin
  inherited;
  if Assigned(FOnTopLeftChanged) then
    FOnTopLeftChanged(Self);
end;

procedure TfrxDesignerWorkspace.SetInsertion(AClass: TfrxComponentClass;
  AWidth, AHeight: Extended; AFlag: Word);
begin
  with FInsertion do
  begin
    ComponentClass := AClass;
    Width := AWidth;
    Height := AHeight;
    OriginalWidth := AWidth;
    OriginalHeight := AHeight;
    Flags := AFlag;
  end;

  FMode := dmInsert;
  if AClass = nil then
  begin
    FMode := dmSelect;
    FMode1 := dmNone;
  end
  else if AClass.InheritsFrom(TfrxCustomLineView) then
  begin
    Cursor := crPencil;
    FMode1 := dmInsertLine;
    if FGridType = gtChar then
    begin
      FInsertion.Left := - FGridX / 2;
      FInsertion.Top := - FGridY / 2;
    end
    else
    begin
      FInsertion.Left := - FGridX;
      FInsertion.Top := - FGridY;
    end;
  end
  else
  begin
    Cursor := crCross;
    FMode1 := dmInsertObject;
    FInsertion.Left := -1000 * FGridX;
    FInsertion.Top := -1000 * FGridY;
  end;
end;

procedure TfrxDesignerWorkspace.SetScale(Value: Extended);
begin
  FScale := Value;

  FMarginsPanel.Width := Round(FPageWidth * FScale);
  FMarginsPanel.Height := Round(FPageHeight * FScale);

  SetBounds(FMarginsPanel.Left + Round(FMargins.Left * FScale),
            FMarginsPanel.Top + Round(FMargins.Top * FScale),
            FMarginsPanel.Width - Round((FMargins.Left + FMargins.Right - 1) * FScale),
            FMarginsPanel.Height - Round((FMargins.Top + FMargins.Bottom - 1) * FScale));

  FMarginsPanel.Invalidate;
  Invalidate;
end;

procedure TfrxDesignerWorkspace.SetPageDimensions(AWidth, AHeight: Integer;
  AMargins: TRect);
begin
  FPageWidth := AWidth;
  FPageHeight := AHeight;
  FMargins := AMargins;
  SetScale(FScale);
  AdjustBands;
end;

procedure TfrxDesignerWorkspace.SetShowGrid(const Value: Boolean);
begin
  FShowGrid := Value;
  Invalidate;
end;

procedure TfrxDesignerWorkspace.UpdateBandHeader;
begin
  case FGridType of
    gt1pt, gtDialog:
      FBandHeader := 16;
    gt1cm:
      FBandHeader := fr01cm * 5;
    gt1in:
      FBandHeader := fr01in * 2;
    gtChar:
      FBandHeader := fr1CharY;
  end;

  if not FShowBandCaptions then
    FBandHeader := 0;
end;

procedure TfrxDesignerWorkspace.SetGridType(const Value: TfrxGridType);
begin
  FGridType := Value;
  UpdateBandHeader;
  if FSelectedObjects.Count <> 0 then
    MouseMove([], 0, 0);
  AdjustBands;
  Invalidate;
end;

procedure TfrxDesignerWorkspace.SetShowBandCaptions(const Value: Boolean);
begin
  FShowBandCaptions := Value;
  UpdateBandHeader;
  AdjustBands;
  Invalidate;
end;

function TfrxDesignerWorkspace.GetOrigin: TPoint;
begin
  Result.X := FMarginsPanel.Left;
  Result.Y := FMarginsPanel.Top;
end;

procedure TfrxDesignerWorkspace.SetOrigin(const Value: TPoint);
begin
  FMarginsPanel.Left := Value.X;
  FMarginsPanel.Top := Value.Y;
end;

procedure TfrxDesignerWorkspace.SetColor(const Value: TColor);
begin
  FColor := Value;
  FMarginsPanel.Color := Value;
end;

procedure TfrxDesignerWorkspace.DoModify;
begin
  if FModifyFlag then
    if Assigned(FOnModify) then
      FOnModify(Self);
  FModifyFlag := False;
end;

procedure TfrxDesignerWorkspace.SelectionChanged;
var
  i, j: Integer;
  c, c1: TfrxComponent;
begin
  for i := 0 to SelectedCount - 1 do
  begin
    c := FSelectedObjects[i];
    if (c is TfrxReportComponent) and (c.GroupIndex <> 0) then
      for j := 0 to FObjects.Count - 1 do
      begin
        c1 := FObjects[j];
        if (c1 is TfrxReportComponent) and (c1.GroupIndex = c.GroupIndex) then
        begin
          if FSelectedObjects.IndexOf(c1) = -1 then
            FSelectedObjects.Add(c1);
        end;
      end;
  end;

  if Assigned(FOnSelectionChanged) then
    FOnSelectionChanged(Self);
  Repaint;
end;

function TfrxDesignerWorkspace.GetSelectionBounds: TfrxRect;
var
  i: Integer;
  c: TfrxComponent;
begin
  if SelectedCount = 1 then
  begin
    with TfrxComponent(FSelectedObjects[0]) do
      Result := frxRect(Left, Top, Width, Height);
    Exit;
  end;

  Result := frxRect(1e10, 1e10, -1e10, -1e10);

  for i := 0 to SelectedCount - 1 do
  begin
    c := FSelectedObjects[i];

    if c.AbsLeft < Result.Left then
      Result.Left := c.AbsLeft;
    if c.AbsTop < Result.Top then
      Result.Top := c.AbsTop;
    if c.AbsLeft + c.Width > Result.Right then
      Result.Right := c.AbsLeft + c.Width;
    if c.AbsTop + c.Height > Result.Bottom then
      Result.Bottom := c.AbsTop + c.Height;
  end;

  with Result do
    Result := frxRect(Left, Top, Right - Left, Bottom - Top);
end;

function TfrxDesignerWorkspace.GetRightBottomObject: TfrxComponent;
var
  i: Integer;
  c: TfrxComponent;
  maxx, maxy: Extended;
begin
  maxx := 0;
  maxy := 0;
  Result := nil;

  for i := 0 to SelectedCount - 1 do
  begin
    c := FSelectedObjects[i];
    if (c.AbsLeft + c.Width > maxx) or
       ((c.AbsLeft + c.Width = maxx) and (c.AbsTop + c.Height > maxy)) then
    begin
      maxx := c.AbsLeft + c.Width;
      maxy := c.AbsTop + c.Height;
      Result := c;
    end;
  end;
end;

function TfrxDesignerWorkspace.SelectedCount: Integer;
begin
  Result := FSelectedObjects.Count;
  if (Result = 1) and
    ((FSelectedObjects[0] = FPage) or (TObject(FSelectedObjects[0]) is TfrxReport)) then
    Result := 0;
end;

procedure TfrxDesignerWorkspace.WMEraseBackground(var Message: TMessage);
begin
// do nothing, prevent flickering
end;

procedure TfrxDesignerWorkspace.Paint;
var
  bmp: TBitmap;
begin
  bmp := TBitmap.Create;
  try
    with Canvas.ClipRect do
    begin
      bmp.Width := Right - Left;
      bmp.Height := Bottom - Top;
      FCanvas := bmp.Canvas;
      SetViewPortOrgEx(FCanvas.Handle, -Left, -Top, nil);
    end;

    DrawBackground;
    if not FDisableUpdate then
    begin
      if (FPage <> nil) and (FPage is TfrxReportPage) then
        TfrxReportPage(FPage).Draw(FCanvas, FScale, FScale,
          -FMargins.Left * FScale,
          -FMargins.Top * FScale);
      DrawObjects;
    end;

    BitBlt(Canvas.Handle, 0, 0, Width, Height, FCanvas.Handle, 0, 0, SRCCOPY);
  finally
    bmp.Free;
  end;
  FCanvas := nil;
end;

procedure TfrxDesignerWorkspace.DrawObjects;
var
  i: Integer;
  c: TfrxComponent;

  function CreateRotatedFont(Font: TFont; Rotation: Integer): HFont;
  var
    F: TLogFont;
  begin
    GetObject(Font.Handle, SizeOf(TLogFont), @F);
    F.lfEscapement := Rotation * 10;
    F.lfOrientation := Rotation * 10;
    Result := CreateFontIndirect(F);
  end;

  procedure DrawPoint(x, y: Extended);
  var
    i, w: Integer;
  begin
    if FScale > 1.7 then
      w := 7
    else if FScale < 0.7 then
      w := 3 else
      w := 5;
    for i := 0 to w - 1 do
    begin
      FCanvas.MoveTo(Round(x * FScale) - w div 2, Round(y * FScale) - w div 2 + i);
      FCanvas.LineTo(Round(x * FScale) + w div 2  +1, Round(y * FScale) - w div 2 + i);
    end;
  end;

  procedure DrawLine(x, y, dx, dy: Extended);
  begin
    FCanvas.MoveTo(Round(x * FScale), Round(y * FScale));
    FCanvas.LineTo(Round((x + dx) * FScale), Round((y + dy) * FScale));
  end;

  procedure DrawSqares(c: TfrxComponent);
  var
    px, py: Extended;
  begin
    with c, FCanvas do
    begin
      Pen.Style := psSolid;
      Pen.Width := 1;
      Pen.Mode := pmXor;
      Pen.Color := clWhite;
      px := AbsLeft + Width / 2;
      py := AbsTop + Height / 2;

      DrawPoint(AbsLeft, AbsTop);
      if not (c is TfrxCustomLineView) then
      begin
        DrawPoint(AbsLeft + Width, AbsTop);
        DrawPoint(AbsLeft, AbsTop + Height);
      end;
      if (SelectedCount > 1) and (c = GetRightBottomObject) then
        Pen.Color := clTeal;
      DrawPoint(AbsLeft + Width, AbsTop + Height);

      Pen.Color := clWhite;
      if (SelectedCount = 1) and not (c is TfrxCustomLineView) then
      begin
        DrawPoint(px, AbsTop); DrawPoint(px, AbsTop + Height);
        DrawPoint(AbsLeft, py); DrawPoint(AbsLeft + Width, py);
      end;

      Pen.Mode := pmCopy;
    end;
  end;

  procedure DrawScriptSign(c: TfrxReportComponent);
  var
    NeedDraw: Boolean;
    Offs: Extended;
  begin
    NeedDraw := False;
    Offs := 0;
    if c is TfrxReportComponent then
      with c do
        if (OnBeforePrint <> '') or (OnAfterPrint <> '') or
          (OnAfterData <> '') or (OnPreviewClick <> '') then
          NeedDraw := True;
    if c is TfrxDialogControl then
      with TfrxDialogControl(c) do
        if (OnClick <> '') or (OnDblClick <> '') or
          (OnEnter <> '') or (OnExit <> '') or
          (OnKeyDown <> '') or (OnKeyPress <> '') or
          (OnKeyUp <> '') or (OnMouseDown <> '') or
          (OnMouseMove <> '') or (OnMouseUp <> '') then
          NeedDraw := True;
    if c is TfrxBand then
      with TfrxBand(c) do
      begin
        if (OnAfterCalcHeight <> '') then
          NeedDraw := True;
        if not Vertical then
          Offs := -FBandHeader + 2;
      end;

    if NeedDraw then
      with c, FCanvas do
      begin
        Pen.Style := psSolid;
        Pen.Color := clRed;
        Pen.Width := 1;
        DrawLine(AbsLeft + 2, AbsTop + Offs + 1, 0, 7);
        DrawLine(AbsLeft + 3, AbsTop + Offs + 2, 0, 5);
        DrawLine(AbsLeft + 4, AbsTop + Offs + 3, 0, 3);
        DrawLine(AbsLeft + 5, AbsTop + Offs + 4, 0, 1);
      end;
  end;

  procedure DrawObject(c: TfrxReportComponent);
  var
    s: String;
    i, w, x, y: Integer;
    d: TfrxDataBand;
    fh, oldfh: HFont;
  begin
    c.IsDesigning := True;
    c.Draw(FCanvas, FScale, FScale, FOffsetX, FOffsetY);

    if c is TfrxBand then
      with c as TfrxBand, FCanvas do
      begin
        if Vertical then
        begin
          Top := 0;
          Pen.Style := psSolid;
          Pen.Color := clGray;
          Pen.Width := 1;
          Brush.Style := bsClear;
          x := Round((Left - FBandHeader) * FScale);
          Rectangle(x, 0, Round((Left + Width) * FScale) + 1, Round((Height) * FScale));

          if FShowBandCaptions then
          begin
            Brush.Style := bsSolid;
            if c is TfrxDataBand then
              Brush.Color := $EEBB00 else
              Brush.Color := clBtnFace;
            FillRect(Rect(x + 1, 1, Round(Left * FScale), Round(Height * FScale)));
          end;

          Font.Name := DefFontName;
          Font.Size := Round(8 * FScale);
          Font.Color := clBlack;
          Font.Style := [];
          fh := CreateRotatedFont(Font, 90);
          oldfh := SelectObject(Handle, fh);
          y := TextWidth(Name) + 4;
          TextOut(x + 2, y, Name);
          SelectObject(Handle, oldfh);
          DeleteObject(fh);
          Font.Style := [fsBold];
          fh := CreateRotatedFont(Font, 90);
          oldfh := SelectObject(Handle, fh);
          TextOut(x + 2, y + TextWidth(BandName + ': ') + 2, BandName + ': ');
          SelectObject(Handle, oldfh);
          DeleteObject(fh);
        end
        else
        begin
          Left := 0;
          if (Page is TfrxReportPage) and (TfrxReportPage(Page).Columns > 1) then
            if BandNumber in [4..16] then
              Width := TfrxReportPage(Page).ColumnWidth * fr01cm;
          Pen.Style := psSolid;
          Pen.Color := clGray;
          Pen.Width := 1;
          Brush.Style := bsClear;
          y := Round((Top - FBandHeader) * FScale);
          Rectangle(0, y, Round(Width * FScale) + 1, Round((Top + Height) * FScale) + 1);

          if FShowBandCaptions then
          begin
            Brush.Style := bsSolid;
            if c is TfrxDataBand then
              Brush.Color := $30A7E0
            else
              Brush.Color := clBtnFace;
            FillRect(Rect(1, y + 1, Round(Width * FScale), Round(Top * FScale)));
          end;

          Font.Name := DefFontName;
          Font.Size := Round(8 * FScale);
          Font.Color := clBlack;
          Font.Style := [fsBold];
          TextOut(6, y + 2, BandName);
          Font.Style := [];
          TextOut(PenPos.X, y + 2, ': ' + Name);

          if c is TfrxDataBand then
          begin
            d := TfrxDataBand(c);

            if FShowBandCaptions then
            begin
              if (d.DataSet <> nil) and (c.Report <> nil) then
                s := c.Report.GetAlias(d.DataSet)
              else if d.RowCount <> 0 then
                s := IntToStr(d.RowCount)
              else
                s := '';
              w := TextWidth(s);
              if FScale > 0.7 then
                frxResources.MainButtonImages.Draw(FCanvas,
                  Round(Width * FScale - w - 24), Round(y + 2 * FScale), 53);
              if s <> '' then
                TextOut(Round(Width * FScale - w - 3), y + 3, s);
            end;

            if d.Columns > 1 then
            begin
              Pen.Style := psDot;
              Pen.Color := clBlack;
              Brush.Style := bsClear;
              for i := 1 to d.Columns do
                Rectangle(Round((i - 1) * (d.ColumnWidth + d.ColumnGap) * FScale),
                          Round(Top * FScale),
                          Round(((i - 1) * (d.ColumnWidth + d.ColumnGap) + d.ColumnWidth) * FScale),
                          Round((Top + Height) * FScale));
            end;
          end;
          if c is TfrxGroupHeader then
          begin
            s := TfrxGroupHeader(c).Condition;
            if s <> '' then
              if FShowBandCaptions then
                TextOut(Round(Width * FScale - TextWidth(s) - 3), y + 3, s);
          end;
        end
      end
    else if not (c is TfrxCustomLineView) and not (c is TfrxDialogComponent) and
      not (c is TfrxDialogControl) then
      with c, FCanvas do
        if FShowEdges and not (FPage is TfrxDataPage) and (c is TfrxView) and
          (TfrxView(c).Frame.Typ <> [ftLeft, ftRight, ftTop, ftBottom]) then
        begin
          Pen.Style := psSolid;
          Pen.Color := clBlack;
          Pen.Width := 1;
          DrawLine(AbsLeft, AbsTop + 3, 0, -3);
          DrawLine(AbsLeft, AbsTop, 4, 0);
          DrawLine(AbsLeft, AbsTop + Height - 3, 0, 3);
          DrawLine(AbsLeft, AbsTop + Height, 4, 0);
          DrawLine(AbsLeft + Width - 3, AbsTop, 3, 0);
          DrawLine(AbsLeft + Width, AbsTop, 0, 4);
          DrawLine(AbsLeft + Width - 3, AbsTop + Height, 3, 0);
          DrawLine(AbsLeft + Width, AbsTop + Height, 0, -4);
        end;

    DrawScriptSign(c);

    if c.IsAncestor then
      frxResources.MainButtonImages.Draw(FCanvas,
        Round((c.AbsLeft + 2) * FScale), Round((c.AbsTop + 1) * FScale), 99);
  end;

begin
  { update aligned objects }
  if Page is TfrxReportPage then
    Page.AlignChildren;

  { draw objects }
  for i := 0 to FObjects.Count - 1 do
  begin
    c := FObjects[i];
    if c is TfrxReportComponent then
      DrawObject(TfrxReportComponent(c));
  end;

  { draw selection }
  for i := 0 to SelectedCount - 1 do
    if not FMouseDown then
      DrawSqares(FSelectedObjects[i]);
end;

procedure TfrxDesignerWorkspace.DrawBackground;

  procedure Line(x, y, x1, y1: Integer);
  begin
    FCanvas.MoveTo(x, y);
    FCanvas.LineTo(x1, y1);
  end;

  procedure DrawPoints;
  var
    GridBmp: TBitmap;
    i: Extended;
    c: TColor;
    dx, dy: Extended;
  begin
    if FGridType = gtDialog then
      c := clBlack else
      c := clGray;
    dx := FGridX * FScale;
    dy := FGridY * FScale;
    if (dx > 2) and (dy > 2) then
    begin
      GridBmp := TBitmap.Create;
      GridBmp.Width:= Width;
      GridBmp.Height := 1;

      GridBmp.Canvas.Pen.Color := FColor;
      GridBmp.Canvas.MoveTo(0, 0);
      GridBmp.Canvas.LineTo(Width, 0);

      i := 0;
      while i < Width do
      begin
        GridBmp.Canvas.Pixels[Round(i), 0] := c;
        i := i + dx;
      end;

      i := 0;
      while i < Height do
      begin
        FCanvas.Draw(0, Round(i), GridBmp);
        i := i + dy;
      end;

      GridBmp.Free;
    end;
  end;

  procedure DrawMM;
  var
    i, dx, maxi: Extended;
    i1: Integer;
    Color5, Color10: TColor;
  begin
    if FGridLCD then
    begin
      Color5 := $F2F2F2;
      Color10 := $E2E2E2;
    end
    else
    begin
      Color5 := $F8F8F8;
      Color10 := $E8E8E8;
    end;

    with FCanvas do
    begin
      Pen.Width := 1;
      Pen.Mode := pmCopy;
      Pen.Style := psSolid;

      if FGridType = gt1cm then
        dx := fr01cm * FScale else
        dx := fr01in * FScale;

      if Width > Height then
        maxi := Width else
        maxi := Height;

      i := 0;
      i1 := 0;
      while i < maxi do
      begin
        if i1 mod 10 = 0 then
          Pen.Color := Color10
        else if i1 mod 5 = 0 then
          Pen.Color := Color5
        else if FGridType = gt1in then
          Pen.Color := Color5
        else
          Pen.Color := clWhite;
        if Pen.Color <> clWhite then
        begin
          Line(Round(i), 0, Round(i), Height);
          Line(0, Round(i), Width, Round(i));
        end;
        i := i + dx;
        Inc(i1);
      end;
    end;
  end;

begin
  FCanvas.Brush.Color := FColor;
  FCanvas.Brush.Style := bsSolid;
  FCanvas.FillRect(Rect(0, 0, Width, Height));

  if FShowGrid then
    case FGridType of
      gt1pt, gtDialog, gtChar:
        DrawPoints;
      gt1cm, gt1in:
        DrawMM;
    end;
end;

procedure TfrxDesignerWorkspace.DrawSelectionRect;
begin
  with Canvas do
  begin
    Pen.Mode := pmXor;
    Pen.Color := clSilver;
    Pen.Width := 1;
    Pen.Style := psDot;
    Brush.Style := bsClear;
    with FSelectionRect do
      Rectangle(Round(Left), Round(Top), Round(Right), Round(Bottom));
    Pen.Mode := pmCopy;
    Brush.Style := bsSolid;
  end;
end;

procedure TfrxDesignerWorkspace.DrawInsertionRect;
var
  R: TfrxRect;
begin
  with Canvas do
  begin
    Pen.Mode := pmCopy;
    Pen.Color := clBlack;
    Pen.Width := 1;
    Pen.Style := psDot;
    Brush.Style := bsClear;
    with FInsertion do
      R := frxRect(Left, Top, Left + Width, Top + Height);
    NormalizeRect(R);
    Rectangle(Round(R.Left * FScale), Round(R.Top * FScale),
      Round(R.Right * FScale) + 1, Round(R.Bottom * FScale) + 1);
    Brush.Style := bsSolid;
  end;
end;

procedure TfrxDesignerWorkspace.DrawCross(Down: Boolean);
var
  x, y: Extended;
begin
  with FInsertion do
    if Down then
    begin
      if Flags <> 0 then
      begin
        x := (Left + Width) * FScale;
        y := (Top + Height) * FScale;
      end
      else if Abs(Width) > Abs(Height) then
      begin
        x := (Left + Width) * FScale;
        y := Top * FScale;
      end
      else
      begin
        x := Left * FScale;
        y := (Top + Height) * FScale;
      end;
    end
    else
    begin
      x := Left * FScale;
      y := Top * FScale;
    end;

  with Canvas do
  begin
    Pen.Mode := pmXor;
    Pen.Color := clSilver;
    Pen.Width := 1;
    Pen.Style := psSolid;
    MoveTo(Round(x - 4), Round(y));
    LineTo(Round(x + 5), Round(y));
    MoveTo(Round(x), Round(y - 4));
    LineTo(Round(x), Round(y + 5));
    if Down then
    begin
      MoveTo(Round(FInsertion.Left * FScale), Round(FInsertion.Top * FScale));
      LineTo(Round(x), Round(y));
    end;

    Pen.Mode := pmCopy;
  end;
end;

procedure TfrxDesignerWorkspace.FindNearest(dx, dy: Integer);
var
  i: Integer;
  c, sel, found: TfrxComponent;
  min, dist, dist_dx, dist_dy: Extended;
  r1, r2, r3: TfrxRect;

  function RectsIntersect(r1, r2: TfrxRect): Boolean;
  begin
    Result := not ((r2.Left > r1.Right) or (r2.Right < r1.Left) or
      (r2.Top > r1.Bottom) or (r2.Bottom < r1.Top));
  end;

begin
  if SelectedCount <> 1 then Exit;

  found := nil;
  sel := FSelectedObjects[0];
  min := 1e10;
  for i := 0 to FObjects.Count - 1 do
  begin
    c := FObjects[i];
    if not (c is TfrxReportComponent) or (c is TfrxBand) or (c = sel) then continue;

    r1 := frxRect(c.AbsLeft, c.AbsTop, c.AbsLeft + c.Width, c.AbsTop + c.Height);
    dist := 0;
    dist_dx := 0;
    dist_dy := 0;
    with sel do
      if dx = 1 then
      begin
        r2 := frxRect(AbsLeft, AbsTop, 1e10, AbsTop + Height);
        r3 := frxRect(AbsLeft, 0, 1e10, 1e10);
        dist := r1.Left - r2.Left;
        dist_dx := r1.Left - (AbsLeft + Width);
        if r1.Top > r2.Top then
          dist_dy := r1.Top - r2.Bottom else
          dist_dy := r2.Top - r1.Bottom;
      end
      else if dx = -1 then
      begin
        r2 := frxRect(-1e10, AbsTop, AbsLeft + Width, AbsTop + Height);
        r3 := frxRect(0, 0, AbsLeft + Width, 1e10);
        dist := r2.Right - r1.Right;
        dist_dx := AbsLeft - r1.Right;
        if r1.Top > r2.Top then
          dist_dy := r1.Top - r2.Bottom else
          dist_dy := r2.Top - r1.Bottom;
      end
      else if dy = 1 then
      begin
        r2 := frxRect(AbsLeft, AbsTop, AbsLeft + Width, 1e10);
        r3 := frxRect(0, AbsTop, 1e10, 1e10);
        dist := r1.Top - r2.Top;
        dist_dy := r1.Top - (AbsTop + Height);
        if r1.Left > r2.Left then
          dist_dx := r1.Left - r2.Right else
          dist_dx := r2.Left - r1.Right;
      end
      else if dy = -1 then
      begin
        r2 := frxRect(AbsLeft, -1e10, AbsLeft + Width, AbsTop + Height);
        r3 := frxRect(0, 0, 1e10, AbsTop + Height);
        dist := r2.Bottom - r1.Bottom;
        dist_dy := AbsTop - r1.Bottom;
        if r1.Left > r2.Left then
          dist_dx := r1.Left - r2.Right else
          dist_dx := r2.Left - r1.Right;
      end;

    if not RectsIntersect(r1, r2) then
    begin
      if (not RectsIntersect(r1, r3)) or
         ((dx <> 0) and (dist_dx < dist_dy)) or
         ((dy <> 0) and (dist_dy < dist_dx)) or
         ((dist_dx = 0) and (dist_dy = 0)) then continue;
      dist := sqrt(dist_dx * dist_dx + dist_dy * dist_dy) * (Width + Height);
    end;

    if dist < min then
    begin
      found := c;
      min := dist;
    end;
  end;

  if found <> nil then
  begin
    FSelectedObjects.Clear;
    FSelectedObjects.Add(found);
    if Assigned(FOnNotifyPosition) then
      FOnNotifyPosition(GetSelectionBounds);
    SelectionChanged;
  end;
end;

procedure TfrxDesignerWorkspace.NormalizeCoord(c: TfrxComponent);
begin
  if c.Width < 0 then
  begin
    c.Width := -c.Width;
    c.Left := c.Left - c.Width;
  end;
  if c.Height < 0 then
  begin
    c.Height := -c.Height;
    c.Top := c.Top - c.Height;
  end;
end;

procedure TfrxDesignerWorkspace.NormalizeRect(var R: TfrxRect);
var
  i: Extended;
begin
  with R do
  begin
    if Left > Right then
    begin
      i := Left;
      Left := Right;
      Right := i
    end;
    if Top > Bottom then
    begin
      i := Top;
      Top := Bottom;
      Bottom := i
    end;
  end;
end;

procedure TfrxDesignerWorkspace.AdjustBands;
var
  i, j: Integer;
  sl: TStringList;
  b: TfrxBand;
  c, c0: TfrxComponent;
  add, add1: Extended;
  l: TList;
  ch: TfrxChild;

  procedure DoBand(Bnd: TfrxBand);
  var
    y: Extended;
  begin
    if Bnd.Vertical then Exit;

    if Bnd is TfrxPageHeader then
      y := 0
    else if Bnd is TfrxReportTitle then
      y := 0.01
    else if Bnd is TfrxColumnHeader then
      y := 0.02
    else if Bnd is TfrxColumnFooter then
      y := 99999
    else if Bnd is TfrxReportSummary then
      y := 100000
    else if Bnd is TfrxPageFooter then
      y := 100001
    else
      y := Abs(Bnd.Top);

    if TfrxReportPage(FPage).TitleBeforeHeader then
    begin
      if Bnd is TfrxReportTitle then
        y := 0
      else if Bnd is TfrxPageHeader then
        y := 0.01
    end;

    sl.AddObject(Format('%9.2f', [y]), Bnd);
  end;

  procedure TossObjects(Bnd: TfrxBand);
  var
    i: Integer;
    c: TfrxComponent;
    SaveRestrictions: TfrxRestrictions;
  begin
    if Bnd.Vertical then Exit;

    while Bnd.Objects.Count > 0 do
    begin
      c := Bnd.Objects[0];
      SaveRestrictions := c.Restrictions;
      c.Restrictions := [];
      c.Top := c.AbsTop;
      c.Restrictions := SaveRestrictions;
      c.Parent := Bnd.Parent;
    end;

    for i := 0 to FObjects.Count - 1 do
    begin
      c := FObjects[i];
      if (c is TfrxView) and (c.AbsTop >= Bnd.Top - 1e-4) and (c.AbsTop < Bnd.Top + Bnd.Height + 1e-4) then
      begin
        SaveRestrictions := c.Restrictions;
        c.Restrictions := [];
        c.Top := c.AbsTop - Bnd.Top;
        c.Restrictions := SaveRestrictions;
        c.Parent := Bnd;
      end;
    end;
  end;

  function Round8(e: Extended): Extended;
  begin
    Result := Round(e * 100000000) / 100000000;
  end;

  procedure AdjustParent(Ctrl: TfrxComponent; Index: Integer);
  var
    i: Integer;
    c: TfrxComponent;
    found: Boolean;
  begin
    found := False;
    for i := Index - 1 downto 0 do
    begin
      c := FObjects[i];
      if (c <> Ctrl) and (c is TfrxDialogControl) and
        (csAcceptsControls in TfrxDialogControl(c).Control.ControlStyle) then
        if (Ctrl.AbsLeft >= c.AbsLeft) and
           (Ctrl.AbsTop >= c.AbsTop) and (Ctrl.AbsLeft < c.AbsLeft + c.Width) and
           (Ctrl.AbsTop < c.AbsTop + c.Height) then
        begin
          Ctrl.Top := Ctrl.AbsTop - c.AbsTop;
          Ctrl.Left := Ctrl.AbsLeft - c.AbsLeft;
          Ctrl.Parent := c;
          found := True;
          break;
        end;
    end;

    if not found and (Ctrl.Parent <> Page) then
    begin
      Ctrl.Top := Ctrl.AbsTop;
      Ctrl.Left := Ctrl.AbsLeft;
      Ctrl.Parent := Page;
      BringToFront;
    end;
  end;

begin
  sl := TStringList.Create;
  sl.Sorted := True;
  sl.Duplicates := dupAccept;

  { sort bands }
  for i := 0 to FObjects.Count - 1 do
    if TObject(FObjects[i]) is TfrxBand then
      DoBand(FObjects[i]);

  { arrange child bands }
  sl.Sorted := False;
  i := 0;
  while i < sl.Count do
  begin
    sl[i] := '';
    b := TfrxBand(sl.Objects[i]);
    if b.Child <> nil then
    begin
      j := sl.IndexOfObject(b.Child);
      if j <> -1 then
      begin
        c := TfrxComponent(sl.Objects[j]);
        sl.Delete(j);
        if j < i then
          Dec(i);
        sl.InsertObject(i + 1, '', c);
      end;
    end;
    Inc(i);
  end;

  { set top/middle/bottom indexes }
  i := 0;
  while i < sl.Count do
  begin
    b := TfrxBand(sl.Objects[i]);
    if sl[i] = '' then
      if (b is TfrxPageHeader) or (b is TfrxReportTitle) or (b is TfrxColumnHeader) then
        sl[i] := 'top'
      else if (b is TfrxPageFooter) or (b is TfrxReportSummary) or (b is TfrxColumnFooter) then
        sl[i] := 'bottom'
      else
        sl[i] := 'middle';
    ch := b.Child;
    while ch <> nil do
    begin
      j := sl.IndexOfObject(ch);
      if j <> -1 then
        sl[j] := sl[i];
      ch := ch.Child;
    end;
    Inc(i);
  end;

  add1 := 0;
  case FGridType of
    gt1pt: add1 := 40;
    gt1cm: add1 := fr1cm;
    gt1in: add1 := fr1in * 0.4;
    gtChar: add1 := fr1CharY;
  end;

  { rearrange all bands }
  if not FFreeBandsPlacement then
    for i := 0 to sl.Count - 1 do
    begin
      c := TfrxComponent(sl.Objects[i]);
      if i = 0 then
        c.Top := Round8(FBandHeader)
      else
      begin
        c0 := TfrxComponent(sl.Objects[i - 1]);
        if ((sl[i - 1] = 'top') and (sl[i] <> 'top')) or
           ((sl[i] = 'bottom') and (sl[i - 1] <> 'bottom')) then
          add := add1 else
          add := 0;

        c.Top := Round8(Round((c0.Top + c0.Height + FBandHeader + FGapBetweenBands)
          / FGridY) * FGridY + add);
      end;
    end;

  sl.Free;

  { toss objects }
  for i := 0 to FObjects.Count - 1 do
  begin
    c := FObjects[i];
    if c is TfrxBand then
      TossObjects(TfrxBand(c))
    else if c is TfrxDialogControl then
      AdjustParent(c, i);
  end;

  { move all bands to the begin of objects list }
  l := TList.Create;
  for i := 0 to FObjects.Count - 1 do
    if TObject(FObjects[i]) is TfrxBand then
      l.Add(FObjects[i]);
  for i := 0 to FObjects.Count - 1 do
    if not (TObject(FObjects[i]) is TfrxBand) then
      l.Add(FObjects[i]);

  FObjects.Clear;
  for i := 0 to l.Count - 1 do
    FObjects.Add(l[i]);
  l.Free;
end;

procedure TfrxDesignerWorkspace.AdjustBandHeight(Bnd: TfrxBand);
var
  i: Integer;
  max, min: Extended;
  c: TfrxComponent;
begin
  max := 0;
  min := 0;
  for i := 0 to Bnd.Objects.Count - 1 do
  begin
    c := Bnd.Objects[i];
    if (c is TfrxView) and (TfrxView(c).Align in [baClient, baBottom]) then
      continue;
    if c.Top + c.Height > max then
      max := c.Top + c.Height;
    if c.Top < min then
      min := c.Top;
  end;

  max := max - min;
  if Bnd.Height < max then
    Bnd.Height := max;
  if min < 0 then
    for i := 0 to Bnd.Objects.Count - 1 do
      with TfrxComponent(Bnd.Objects[i]) do
        Top := Top - min;
end;

function TfrxDesignerWorkspace.ListsEqual(List1, List2: TList): Boolean;
var
  i: Integer;
begin
  Result := List1.Count = List2.Count;
  if Result then
    for i := 0 to List1.Count - 1 do
      if List1.List[i] <> List2.List[i] then
        Result := False;
end;

procedure TfrxDesignerWorkspace.DeleteObjects;
var
  c, c1: TfrxComponent;
  i: Integer;
begin
  if SelectedCount = 0 then exit;

  i := 0;
  while FSelectedObjects.Count > i do
  begin
    c := FSelectedObjects[i];

    if not (rfDontDelete in c.Restrictions) then
    begin
      if c.IsAncestor then
        raise Exception.Create('Could not delete ' + c.Name + ', it was introduced in the ancestor report');
      FSelectedObjects.Remove(c);
      FObjects.Remove(c);

      while c.Objects.Count > 0 do
      begin
        c1 := c.Objects[0];
        FSelectedObjects.Remove(c1);
        FObjects.Remove(c1);
        c1.Free;
      end;

      c.Free;
    end
    else
      Inc(i);
  end;

  if FSelectedObjects.Count = 0 then
    FSelectedObjects.Add(FPage);

  AdjustBands;
  FModifyFlag := True;
  DoModify;
  SelectionChanged;
end;

procedure TfrxDesignerWorkspace.EditObject;
begin
  if FSelectedObjects.Count = 1 then
    if Assigned(FOnEdit) then
      FOnEdit(Self);
end;

procedure TfrxDesignerWorkspace.DoNudge(dx, dy: Extended);
var
  i: Integer;
  c: TfrxComponent;
begin
  if SelectedCount = 0 then exit;
  dx := dx * FGridX;
  dy := dy * FGridY;

  for i := 0 to SelectedCount - 1 do
  begin
    c := FSelectedObjects[i];
    c.Left := c.Left + dx;
    c.Top := c.Top + dy;
  end;

  FModifyFlag := True;
  if Assigned(FOnNotifyPosition) then
    FOnNotifyPosition(GetSelectionBounds);
  Repaint;
end;

procedure TfrxDesignerWorkspace.DoSize(dx, dy: Extended);
var
  i: Integer;
  c: TfrxComponent;
begin
  if SelectedCount = 0 then exit;
  dx := dx * FGridX;
  dy := dy * FGridY;

  for i := 0 to SelectedCount - 1 do
  begin
    c := FSelectedObjects[i];
    c.Width := c.Width + dx;
    if c.Width < 0 then
      c.Width := c.Width - dx;
    c.Height := c.Height + dy;
    if c.Height < 0 then
      c.Height := c.Height - dy;
  end;

  FModifyFlag := True;
  if Assigned(FOnNotifyPosition) then
    FOnNotifyPosition(GetSelectionBounds);
  Repaint;
end;

procedure TfrxDesignerWorkspace.DoStick(dx, dy: Integer);
var
  i: Integer;
  c, sel, found: TfrxComponent;
  min, dist: Extended;
  r1, r2: TfrxRect;
  gapLeft, gapRight, gapTop, gapBottom: Extended;

  function RectsIntersect(r1, r2: TfrxRect): Boolean;
  begin
    Result := not ((r2.Left > r1.Right) or (r2.Right < r1.Left) or
      (r2.Top > r1.Bottom) or (r2.Bottom < r1.Top));
  end;

begin
  if SelectedCount <> 1 then exit;

  found := nil;
  sel := FSelectedObjects[0];
  min := 1e10;
  for i := 0 to FObjects.Count - 1 do
  begin
    c := FObjects[i];
    if not (c is TfrxReportComponent) or (c is TfrxBand) or (c = sel) then continue;

    r1 := frxRect(c.AbsLeft, c.AbsTop, c.AbsLeft + c.Width, c.AbsTop + c.Height);
    dist := 0;
    with sel do
      if dx = 1 then
      begin
        r2 := frxRect(AbsLeft, AbsTop, 1e10, AbsTop + Height);
        dist := r1.Left - r2.Left;
      end
      else if dx = -1 then
      begin
        r2 := frxRect(-1e10, AbsTop, AbsLeft + Width, AbsTop + Height);
        dist := r2.Right - r1.Right;
      end
      else if dy = 1 then
      begin
        r2 := frxRect(AbsLeft, AbsTop, AbsLeft + Width, 1e10);
        dist := r1.Top - r2.Top;
      end
      else if dy = -1 then
      begin
        r2 := frxRect(AbsLeft, -1e10, AbsLeft + Width, AbsTop + Height);
        dist := r2.Bottom - r1.Bottom;
      end;

    if RectsIntersect(r1, r2) then
      if dist < min then
      begin
        found := c;
        min := dist;
      end;
  end;

  if found <> nil then
  begin
    gapLeft := 0;
    gapRight := 0;
    gapTop := 0;
    gapBottom := 0;
    if (sel is TfrxDMPMemoView) and (found is TfrxDMPMemoView) then
    begin
      if (ftLeft in TfrxDMPMemoView(sel).Frame.Typ) or
         (ftRight in TfrxDMPMemoView(found).Frame.Typ) then
        gapLeft := fr1CharX;
      if (ftRight in TfrxDMPMemoView(sel).Frame.Typ) or
         (ftLeft in TfrxDMPMemoView(found).Frame.Typ) then
        gapRight := fr1CharX;
      if (ftTop in TfrxDMPMemoView(sel).Frame.Typ) or
         (ftBottom in TfrxDMPMemoView(found).Frame.Typ) then
        gapTop := fr1CharY;
      if (ftBottom in TfrxDMPMemoView(sel).Frame.Typ) or
         (ftTop in TfrxDMPMemoView(found).Frame.Typ) then
        gapBottom := fr1CharY;
    end;
    if dx = 1 then
      sel.Left := found.Left - sel.Width - gapRight
    else if dx = -1 then
      sel.Left := found.Left + found.Width + gapLeft
    else if dy = 1 then
      sel.Top := found.Top - sel.Height - gapBottom
    else if dy = -1 then
      sel.Top := found.Top + found.Height + gapTop;

    FModifyFlag := True;
    if Assigned(FOnNotifyPosition) then
      FOnNotifyPosition(GetSelectionBounds);
    Repaint;
  end;
end;

procedure TfrxDesignerWorkspace.DoTab;
var
  c: TfrxComponent;
  i: Integer;
begin
  if SelectedCount <> 1 then Exit;

  c := SelectedObjects[0];
  if (c is TfrxBand) and (c.Objects.Count > 0) then
    SelectedObjects[0] := c.Objects[0]
  else if c is TfrxView then
  begin
    i := c.Parent.Objects.IndexOf(c);
    if i = c.Parent.Objects.Count - 1 then
      i := 0
    else
      Inc(i);
    SelectedObjects[0] := c.Parent.Objects[i];
  end;

  if Assigned(FOnNotifyPosition) then
    FOnNotifyPosition(GetSelectionBounds);
  SelectionChanged;
end;

procedure TfrxDesignerWorkspace.KeyDown(var Key: Word; Shift: TShiftState);
var
  p: TPoint;
  dx, dy: Integer;
begin
  if FDisableUpdate then exit;

  if ssAlt in Shift then
  begin
    GetCursorPos(p);
    p := ScreenToClient(p);
    MouseMove(Shift, p.X, p.Y);
  end;

  dx := 0; dy := 0;

  case Key of
    vk_Delete:
      DeleteObjects;

    vk_Return:
      EditObject;

    vk_Left:
      dx := -1;

    vk_Right:
      dx := 1;

    vk_Up:
      dy := -1;

    vk_Down:
      dy := 1;

    vk_Tab:
      DoTab;
  end;

  if (dx <> 0) or (dy <> 0) then
    if ssCtrl in Shift then
      DoNudge(dx, dy)
    else if ssShift in Shift then
      DoSize(dx, dy)
    else if ssAlt in Shift then
      DoStick(dx, dy)
    else
      FindNearest(dx, dy);
end;

procedure TfrxDesignerWorkspace.KeyUp(var Key: Word; Shift: TShiftState);
begin
  if FDisableUpdate then exit;
  DoModify;
end;

procedure TfrxDesignerWorkspace.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  i, j: Integer;
  c, c1: TfrxComponent;
  EmptySpace: Boolean;
  l: TList;
  NeedRepaint: Boolean;
  p: TPoint;

  function Contain(c: TfrxComponent): Boolean;
  var
    w0, w1, w2, w3: Extended;
    Left, Top, Right, Bottom, e, k, mx, my: Extended;
  begin
    Result := False;
    w0 := 0;
    w1 := 0;
    w2 := 0;
    if c.Width = 0 then
    begin
      w0 := 4;
      w1 := 4
    end
    else if c.Height = 0 then
      w2 := 4;
    w3 := w2;
    if c is TfrxBand then
      if TfrxBand(c).Vertical then
        w0 := FBandHeader
      else
        w2 := FBandHeader;

    Left := c.AbsLeft;
    Right := c.AbsLeft + c.Width;
    Top := c.AbsTop;
    Bottom := c.AbsTop + c.Height;
    mx := X / FScale;
    my := Y / FScale;

    if Right < Left then
    begin
      e := Right;
      Right := Left;
      Left := e;
    end;
    if Bottom < Top then
    begin
      e := Bottom;
      Bottom := Top;
      Top := e;
    end;

    if (c is TfrxLineView) and TfrxLineView(c).Diagonal and
      (c.Width <> 0) and (c.Height <> 0) then
    begin
      k := c.Height / c.Width;
      if Abs((k * (mx - c.AbsLeft) - (my - c.AbsTop)) * cos(arctan(k))) < 5 then
        Result := True;
      if (mx < Left - 5) or (mx > Right + 5) or (my < Top - 5) or (my > Bottom + 5) then
        Result := False;
    end
    else if (mx >= Left - w0) and (mx <= Right + w1) and
      (my >= Top - w2) and (my <= Bottom + w3) then
      Result := True;
  end;

begin
  inherited;
  if FDisableUpdate then exit;
  if FDblClicked then
  begin
    FDblClicked := False;
    exit;
  end;

  if TInplaceMemo(FInplaceMemo).Visible then
    TInplaceMemo(FInplaceMemo).EditDone;

  l := TList.Create;
  for i := 0 to FSelectedObjects.Count - 1 do
    l.Add(FSelectedObjects[i]);

  if FPage is TfrxReportPage then
    ValidParentForm(Self).ActiveControl := Parent else
    ValidParentForm(Self).ActiveControl := nil;

  FMouseDown := True;
  FLastMousePointX := X / FScale;
  FLastMousePointY := Y / FScale;
  NeedRepaint := False;

// Ctrl was pressed
  if (FMode1 = dmNone) and (ssCtrl in Shift) then
  begin
    FSelectedObjects.Clear;
    FSelectedObjects.Add(FPage);
    FMode1 := dmSelectionRect;
    FSelectionRect := frxRect(X, Y, X, Y);
    NeedRepaint := True;
  end;

// clicked on object or on empty space
  if FMode1 = dmNone then
  begin
    EmptySpace := True;

    for i := FObjects.Count - 1 downto 0 do
    begin
      c := FObjects[i];
      if (c is TfrxReportComponent) and Contain(c) then
      begin
        EmptySpace := False;

        if csContainer in c.frComponentStyle then
        begin
          if c.ContainerMouseDown(Self, X, Y) then
            FMode1 := dmContainer
          else
            for j := c.ContainerObjects.Count - 1 downto 0 do
            begin
              c1 := c.ContainerObjects[j];
              if c1.Visible and Contain(c1) then
              begin
                c := c1;
                break;
              end;
            end;
        end;

        if ssShift in Shift then
          if FSelectedObjects.IndexOf(c) <> -1 then
            FSelectedObjects.Remove(c) else
            FSelectedObjects.Add(c)
        else if FSelectedObjects.IndexOf(c) = -1 then
        begin
          FSelectedObjects.Clear;
          FSelectedObjects.Add(c);
        end;

        break;
      end;
    end;

    if EmptySpace then
    begin
      FSelectedObjects.Clear;
      FSelectedObjects.Add(FPage);
      FMode1 := dmSelectionRect;
      FSelectionRect := frxRect(X, Y, X, Y);
    end
    else if FSelectedObjects.Count = 0 then
    begin
      FSelectedObjects.Add(FPage);
      FMode1 := dmNone;
    end
    else
    begin
      FSelectedObjects.Remove(FPage);
      if FMode1 <> dmContainer then
        FMode1 := dmMove;
    end;

    NeedRepaint := True;
  end;

// scaling
  if FMode1 = dmScale then
  begin
    FScaleRect := GetSelectionBounds;
    FScaleRect.Right := FScaleRect.Right + FScaleRect.Left;
    FScaleRect.Bottom := FScaleRect.Bottom + FScaleRect.Top;
    FScaleRect1 := FScaleRect;
    for i := 0 to SelectedCount - 1 do
    begin
      c := FSelectedObjects[i];
      THackComponent(c).FOriginalRect := frxRect(c.AbsLeft, c.AbsTop, c.Width, c.Height);
    end;
  end;

// inserting a line
  if FMode1 = dmInsertLine then
  begin
    FInsertion.Width := 0;
    FInsertion.Height := 0;
  end;

  if NeedRepaint then
    if not ListsEqual(l, FSelectedObjects) then
      SelectionChanged else
      Repaint;

  if (Button = mbRight) and (PopupMenu <> nil) then
  begin
    FMode1 := dmNone;
    FMouseDown := False;
    Repaint;
    p := ClientToScreen(Point(X, Y));
    PopupMenu.Popup(p.X, p.Y);
  end;

  l.Free;
end;

procedure TfrxDesignerWorkspace.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  c: TfrxComponent;
  kx, ky, nx, ny: Extended;
  i: Integer;
  NotifyRect, SaveBounds: TfrxRect;

  function Contain(px, py: Extended): Boolean;
  begin
    Result := (X / FScale >= px - 2) and (X / FScale <= px + 3) and
      (Y / FScale >= py - 2) and (Y / FScale <= py + 3);
  end;

  function Contain0(py: Extended): Boolean;
  begin
    Result := (Y / FScale >= py - 2) and (Y / FScale <= py + 2);
  end;

  function Contain1(px, py: Extended): Boolean;
  begin
    Result := (FLastMousePointX >= px - 2) and (FLastMousePointX <= px + 3) and
      (FLastMousePointY >= py - 2) and (FLastMousePointY <= py + 3);
  end;

  function Contain2(c: TfrxComponent): Boolean;
  var
    w1, w2: Integer;
  begin
    w1 := 0;
    w2 := 0;
    if c.Width = 0 then
      w1 := 4 else
      w2 := 4;
    if (X / FScale >= c.AbsLeft - w1) and (X / FScale <= c.AbsLeft + c.Width + w1) and
       (Y / FScale >= c.AbsTop - w2) and (Y / FScale <= c.AbsTop + c.Height + w2) then
      Result := True else
      Result := False;
  end;

  function Contain3(px: Extended): Boolean;
  begin
    Result := (X / FScale >= px - 2) and (X / FScale <= px + 2);
  end;

  function GridCheck: Boolean;
  begin
    Result := (kx >= FGridX) or (kx <= -FGridX) or
              (ky >= FGridY) or (ky <= -FGridY);
    if Result then
    begin
      kx := Trunc(kx / FGridX) * FGridX;
      ky := Trunc(ky / FGridY) * FGridY;
    end;
  end;

  function CheckMove: Boolean;
  var
    al: Boolean;
  begin
    al := FGridAlign;
    if ssAlt in Shift then
      al := not al;

    Result := False;

    if al and not GridCheck then
      Result := True;

    CheckGuides(kx, ky, Result);
  end;

  procedure CheckNegative(c: TfrxComponent);
  const
    ar1: array[ct1..ct8] of TfrxCursorType = (ct3, ct4, ct1, ct2, ct6, ct5, ct0, ct0);
    ar2: array[ct1..ct8] of TfrxCursorType = (ct4, ct3, ct2, ct1, ct0, ct0, ct8, ct7);
    ar3: array[ct1..ct8] of TfrxCursorType = (ct2, ct1, ct4, ct3, ct0, ct0, ct0, ct0);
  begin
    if (c is TfrxLineView) and (TfrxLineView(c).Diagonal = True) then exit;
    if (c.Width < 0) and (c.Height < 0) then
      FCT := ar3[FCT]
    else if c.Width < 0 then
      FCT := ar1[FCT]
    else if c.Height < 0 then
      FCT := ar2[FCT];
    NormalizeCoord(c);
  end;

  procedure CTtoCursor;
  const
    ar: array[ct0..ct10] of TCursor =
      (crDefault, crSizeNWSE, crSizeNWSE, crSizeNESW,
       crSizeNESW, crSizeWE, crSizeWE, crSizeNS, crSizeNS, crCross, crCross);
  begin
    Cursor := ar[FCT];
  end;

begin
  inherited;
  if FDisableUpdate then Exit;

  if SelectedCount = 0 then
    NotifyRect := frxRect(X / FScale, Y / FScale, 0, 0) else
    NotifyRect := GetSelectionBounds;

// cursor shapes
  if not FMouseDown and (FMode = dmSelect) then
    if SelectedCount = 1 then
    begin
      FMode1 := dmSize;
      c := FSelectedObjects[0];
      FCT := ct0;
      if Contain(c.AbsLeft, c.AbsTop) then
        FCT := ct1
      else if Contain(c.AbsLeft + c.Width, c.AbsTop + c.Height) then
        FCT := ct2
      else if Contain(c.AbsLeft + c.Width, c.AbsTop) then
        FCT := ct3
      else if Contain(c.AbsLeft, c.AbsTop + c.Height) then
        FCT := ct4
      else if Contain(c.AbsLeft + c.Width, c.AbsTop + c.Height / 2) then
        FCT := ct5
      else if Contain(c.AbsLeft, c.AbsTop + c.Height / 2) then
        FCT := ct6
      else if Contain(c.AbsLeft + c.Width / 2, c.AbsTop) then
        FCT := ct7
      else if Contain(c.AbsLeft + c.Width / 2, c.AbsTop + c.Height) then
        FCT := ct8;

      if c is TfrxCustomLineView then
        if not TfrxCustomLineView(c).Diagonal then
        begin
          if c.Width = 0 then
            if FCT in [ct1, ct3] then
              FCT := ct7
            else if FCT in [ct4, ct2] then
              FCT := ct8
            else
              FCT := ct0;
          if c.Height = 0 then
            if FCT in [ct1, ct4] then
              FCT := ct6
            else if FCT in [ct3, ct2] then
              FCT := ct5
            else
              FCT := ct0;
        end
        else
          if FCT = ct1 then
            FCT := ct9
          else if FCT = ct2 then
            FCT := ct10
          else
            FCT := ct0;


      if FCT = ct0 then
        FMode1 := dmNone;
      CTtoCursor;
    end
    else if SelectedCount > 1 then
    begin
      FMode1 := dmScale;
      c := GetRightBottomObject;
      if (c <> nil) and Contain(c.AbsLeft + c.Width, c.AbsTop + c.Height) then
        Cursor := crSizeNWSE
      else
      begin
        Cursor := crDefault;
        FMode1 := dmNone;
      end;
    end
    else
      Cursor := crDefault;

// resizing a band - setup
  if not FMouseDown and (FMode = dmSelect) and not (FMode1 in [dmSize, dmScale]) then
  begin
    Cursor := crDefault;
    FMode1 := dmNone;
    for i := 0 to FObjects.Count - 1 do
    begin
      c := FObjects[i];

      if c is TfrxBand then
        if TfrxBand(c).Vertical then
        begin
          if Contain3(c.Left + c.Width) then
          begin
            Cursor := crHSplit;
            FMode1 := dmSizeBand;
            FSizedBand := TfrxBand(c);
            break;
          end;
        end
        else
        begin
          if Contain0(c.Top + c.Height) then
          begin
            Cursor := crVSplit;
            FMode1 := dmSizeBand;
            FSizedBand := TfrxBand(c);
            break;
          end;
        end;
    end;
  end;

// resizing a band
  if FMouseDown and (FMode1 = dmSizeBand) then
  begin
    kx := X / FScale - FLastMousePointX;
    ky := Y / FScale - FLastMousePointY;
    if CheckMove then Exit;

    FModifyFlag := True;
    if FSizedBand.Vertical then
      FSizedBand.Width := FSizedBand.Width + kx
    else
      FSizedBand.Height := FSizedBand.Height + ky;
    AdjustBandHeight(FSizedBand);
    AdjustBands;

    FLastMousePointX := FLastMousePointX + kx;
    FLastMousePointY := FLastMousePointY + ky;
    Repaint;
    with FSizedBand do
      NotifyRect := frxRect(Left, Top, Width, Height);
  end;

// inplace editing - setup
  if not FMouseDown and (ssAlt in Shift) then
  begin
    Cursor := crDefault;
    FMode1 := dmNone;
    for i := 0 to FObjects.Count - 1 do
    begin
      c := FObjects[i];
      if (c is TfrxCustomMemoView) and Contain2(c) then
      begin
        FInplaceObject := TfrxCustomMemoView(c);
        Cursor := crIBeam;
        FMode1 := dmInplaceEdit;
        break;
      end;
    end;
  end;

// inserting
  if not FMouseDown and (FMode1 = dmInsertObject) then
  begin
    kx := X / FScale - FInsertion.Left;
    ky := Y / FScale - FInsertion.Top;
    if CheckMove then Exit;

    FInsertion.Left := FInsertion.Left + kx;
    FInsertion.Top := FInsertion.Top + ky;
    Repaint;
    DrawInsertionRect;
    with FInsertion do
      NotifyRect := frxRect(Left, Top, Width, Height);
  end;

// inserting + resizing
  if FMouseDown and (FMode1 = dmInsertObject) then
  begin
    kx := X / FScale - FInsertion.Left;
    ky := Y / FScale - FInsertion.Top;
    if CheckMove then Exit;

    FInsertion.Width := kx;
    FInsertion.Height := ky;
    Repaint;
    DrawInsertionRect;
    with FInsertion do
      NotifyRect := frxRect(Left, Top, Width, Height);
  end;

// moving
  if FMouseDown and (FMode1 = dmMove) then
  begin
    kx := X / FScale - FLastMousePointX;
    ky := Y / FScale - FLastMousePointY;
    if CheckMove then Exit;

    { vertical band }
    if not FModifyFlag and (SelectedCount = 1) and
      (TObject(FSelectedObjects[0]) is TfrxBand) and
      (TfrxBand(FSelectedObjects[0]).Vertical) then
    begin
      for i := 0 to FObjects.Count - 1 do
      begin
        c := FObjects[i];
        if (c is TfrxView) and
          (c.Left >= TfrxBand(FSelectedObjects[0]).Left - 1e-4) and
          (c.Left + c.Width <= TfrxBand(FSelectedObjects[0]).Left +
          TfrxBand(FSelectedObjects[0]).Width + 1e-4) then
          FSelectedObjects.Add(c);
      end;
    end;

    if (TObject(FSelectedObjects[0]) is TfrxBand) and
      (TfrxBand(FSelectedObjects[0]).Vertical) then
      ky := 0;

    FModifyFlag := True;
    for i := 0 to SelectedCount - 1 do
    begin
      c := FSelectedObjects[i];
      c.Left := c.Left + kx;
      if FSelectedObjects.IndexOf(c.Parent) = -1 then
      begin
        if c.IsAncestor and (c is TfrxView) then
          if (c.Top + ky < -1e-4) or (c.Top + ky > c.Parent.Height) then
            continue;
        c.Top := c.Top + ky;
      end;
    end;

    FLastMousePointX := FLastMousePointX + kx;
    FLastMousePointY := FLastMousePointY + ky;
    Repaint;
    NotifyRect := GetSelectionBounds;
  end;

// resizing one object
  if FMouseDown and (FMode1 = dmSize) then
  begin
    kx := X / FScale - FLastMousePointX;
    ky := Y / FScale - FLastMousePointY;
    if CheckMove then Exit;

    FModifyFlag := True;
    c := FSelectedObjects[0];
    SaveBounds := frxRect(c.Left, c.Top, c.Width, c.Height);
    case FCT of
      ct1, ct9:
        begin
          c.Left := c.Left + kx;
          c.Width := c.Width - kx;
          c.Top := c.Top + ky;
          c.Height := c.Height - ky;
        end;

      ct2, ct10:
        begin
          c.Width := c.Width + kx;
          c.Height := c.Height + ky;
        end;

      ct3:
        begin
          c.Top := c.Top + ky;
          c.Width := c.Width + kx;
          c.Height := c.Height - ky;
        end;

      ct4:
        begin
          c.Left := c.Left + kx;
          c.Width := c.Width - kx;
          c.Height := c.Height + ky;
        end;

      ct5:
        begin
          c.Width := c.Width + kx;
        end;

      ct6:
        begin
          c.Left := c.Left + kx;
          c.Width := c.Width - kx;
        end;

      ct7:
        begin
          c.Top := c.Top + ky;
          c.Height := c.Height - ky;
        end;

      ct8:
        begin
          c.Height := c.Height + ky;
        end;
    end;
    CheckNegative(c);
    CTtoCursor;

    if c.Left < 0 then
      c.Left := 0;

    if c.IsAncestor and (c is TfrxView) then
      if (c.Top < -1e-4) or (c.Top > c.Parent.Height) then
        c.SetBounds(SaveBounds.Left, SaveBounds.Top, SaveBounds.Right, SaveBounds.Bottom);

    if c is TfrxBand then
    begin
      if FCT in [ct1, ct3, ct7] then
        for i := 0 to c.Objects.Count - 1 do
          with TfrxComponent(c.Objects[i]) do
            Top := Top - ky;
      AdjustBandHeight(TfrxBand(c));
      AdjustBands;
    end;

    FLastMousePointX := FLastMousePointX + kx;
    FLastMousePointY := FLastMousePointY + ky;
    Repaint;
    NotifyRect := frxRect(c.Left, c.Top, c.Width, c.Height);
  end;

// scaling
  if FMouseDown and (FMode1 = dmScale) then
  begin
    kx := X / FScale - FLastMousePointX;
    ky := Y / FScale - FLastMousePointY;
    if CheckMove then Exit;

    FModifyFlag := True;
    with FScaleRect do
      if not ((Right + kx < Left) or (Bottom + ky < Top)) then
        FScaleRect := frxRect(Left, Top, Right + kx, Bottom + ky);
    nx := (FScaleRect.Right - FScaleRect.Left) / (FScaleRect1.Right - FScaleRect1.Left);
    ny := (FScaleRect.Bottom - FScaleRect.Top) / (FScaleRect1.Bottom - FScaleRect1.Top);
    for i := 0 to SelectedCount - 1 do
    begin
      c := FSelectedObjects[i];
      c.Left := FScaleRect1.Left + (THackComponent(c).FOriginalRect.Left - FScaleRect1.Left) * nx;
      c.Top := FScaleRect1.Top + (THackComponent(c).FOriginalRect.Top - FScaleRect1.Top) * ny;
      if c.Parent is TfrxBand then
        c.Top := c.Top - c.Parent.Top;
      c.Width := THackComponent(c).FOriginalRect.Right * nx;
      c.Height := THackComponent(c).FOriginalRect.Bottom * ny;
    end;

    FLastMousePointX := FLastMousePointX + kx;
    FLastMousePointY := FLastMousePointY + ky;
    Repaint;
    with FScaleRect do
      NotifyRect := frxRect(Right - Left, Bottom - Top, nx, ny);
  end;

// drawing selection rectangle
  if FMouseDown and (FMode1 = dmSelectionRect) then
  begin
    DrawSelectionRect;
    FSelectionRect := frxRect(FSelectionRect.Left, FSelectionRect.Top, X, Y);
    DrawSelectionRect;
  end;

// inserting a line
  if not FMouseDown and (FMode1 = dmInsertLine) then
  begin
    kx := X / FScale - FInsertion.Left;
    ky := Y / FScale - FInsertion.Top;
    if CheckMove then Exit;

    DrawCross(False);
    FInsertion.Left := FInsertion.Left + kx;
    FInsertion.Top := FInsertion.Top + ky;
    DrawCross(False);
    with FInsertion do
      NotifyRect := frxRect(Left, Top, 0, 0);
  end;

// inserting a line + resizing
  if FMouseDown and (FMode1 = dmInsertLine) then
  begin
    kx := X / FScale - (FInsertion.Left + FInsertion.Width);
    ky := Y / FScale - (FInsertion.Top + FInsertion.Height);
    if CheckMove then Exit;

    DrawCross(True);
    FInsertion.Width := FInsertion.Width + kx;
    FInsertion.Height := FInsertion.Height + ky;
    DrawCross(True);
    with FInsertion do
      NotifyRect := frxRect(Left, Top, Width, Height);
  end;

// check containers
  if not FMouseDown and (FMode = dmSelect) and not (FMode1 in [dmSize, dmScale]) then
    for i := 0 to FObjects.Count - 1 do
    begin
      c := FObjects[i];
      if (csContainer in c.frComponentStyle) and Contain2(c) then
        c.ContainerMouseMove(Self, X, Y);
    end;

// handle containers
  if FMouseDown and (FMode1 = dmContainer) then
  begin
    kx := X / FScale - FLastMousePointX;
    ky := Y / FScale - FLastMousePointY;
    if CheckMove then Exit;

    FModifyFlag := True;
    c := FSelectedObjects[0];
    c.ContainerMouseMove(Self, X, Y);
    FLastMousePointX := FLastMousePointX + kx;
    FLastMousePointY := FLastMousePointY + ky;
    Repaint;
  end;

  if FMouseDown and (Cursor <> crHand) then
    if Parent is TScrollingWinControl then
      with TScrollingWinControl(Parent) do
      begin
        x := x + Round(FMargins.Left * FScale);
        y := y + Round(FMargins.Top * FScale);
        if x > (ClientRect.Right + HorzScrollBar.Position) then
        begin
          i := x - (ClientRect.Right + HorzScrollBar.Position);
          HorzScrollBar.Position := HorzScrollBar.Position + i;
        end;
        if x < HorzScrollBar.Position then
        begin
          i := HorzScrollBar.Position - x;
          HorzScrollBar.Position := HorzScrollBar.Position - i;
        end;
        if y > (ClientRect.Bottom + VertScrollBar.Position) then
        begin
          i := y - (ClientRect.Bottom + VertScrollBar.Position);
          VertScrollBar.Position := VertScrollBar.Position + i;
        end;
        if y < VertScrollBar.Position then
        begin
          i := VertScrollBar.Position - y;
          VertScrollBar.Position := VertScrollBar.Position - i;
        end;
      end;

  if (SelectedCount = 0) or FMouseDown then
    if Assigned(FOnNotifyPosition) then
      FOnNotifyPosition(NotifyRect);
end;

procedure TfrxDesignerWorkspace.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  i, j: Integer;
  c, c1: TfrxComponent;
  R: TfrxRect;
  l: TList;
  NotifyRect: TfrxRect;

  function Round8(e: Extended): Extended;
  begin
    Result := Round(e * 100000000) / 100000000;
  end;

  function Contain(c: TfrxComponent): Boolean;
  var
    cLeft, cTop, cRight, cBottom, e: Extended;
    Sign: Boolean;

    function Dist(x, y: Extended): Boolean;
    var
      k: Extended;
    begin
      k := c.Height / c.Width;
      k := (k * (x / FScale - c.AbsLeft) - (y / FScale - c.AbsTop)) * cos(arctan(k));
      Result := k >= 0;
    end;

    function RectInRect: Boolean;
    begin
      with FSelectionRect do
        Result := not ((cLeft > Right / FScale) or
                       (cRight < Left / FScale) or
                       (cTop > Bottom / FScale) or
                       (cBottom < Top / FScale));
    end;

  begin
    Result := False;
    cLeft := c.AbsLeft;
    cRight := c.AbsLeft + c.Width;
    cTop := c.AbsTop;
    cBottom := c.AbsTop + c.Height;

    if cRight < cLeft then
    begin
      e := cRight;
      cRight := cLeft;
      cLeft := e;
    end;
    if cBottom < cTop then
    begin
      e := cBottom;
      cBottom := cTop;
      cTop := e;
    end;

    if (c is TfrxLineView) and TfrxLineView(c).Diagonal and
      (c.Width <> 0) and (c.Height <> 0) then
      with FSelectionRect do
      begin
        Sign := Dist(Left, Top);
        if Dist(Right, Top) <> Sign then
          Result := True;
        if Dist(Left, Bottom) <> Sign then
          Result := True;
        if Dist(Right, Bottom) <> Sign then
          Result := True;

        if Result then
          Result := RectInRect;
      end
      else
        Result := RectInRect;
  end;

begin
  inherited;
  if FDisableUpdate then Exit;
  if Button <> mbLeft then Exit;

  l := TList.Create;
  for i := 0 to FSelectedObjects.Count - 1 do
    l.Add(FSelectedObjects[i]);
  FMouseDown := False;

// insert an object
  if FMode = dmInsert then
  begin
    with FInsertion do
    begin
      R := frxRect(Left, Top, Left + Width, Top + Height);
      if ((ComponentClass.InheritsFrom(TfrxCustomLineView)) and (Flags = 0)) then
      begin
        if Width < 0 then
          R.Right := Left - Width;
        if Height < 0 then
          R.Bottom := Top - Height;

        if (Width < 0) and (Abs(Width) > Abs(Height)) then
        begin
          R.Left := Left + Width;
          R.Right := Left;
        end;
        if (Height < 0) and (Abs(Height) > Abs(Width)) then
        begin
          R.Top := Top + Height;
          R.Bottom := Top;
        end;
      end
      else if not ((ComponentClass.InheritsFrom(TfrxLineView)) and (Flags <> 0)) then
      begin
        if ((Width >= 0) and (Width < 4)) or ((Height > 0) and (Height < 4)) then
          R := frxRect(Left, Top, Left + OriginalWidth, Top + OriginalHeight);
        NormalizeRect(R);
      end;
      Left := Round8(R.Left);
      Top := Round8(R.Top);
      Width := Round8(R.Right - R.Left);
      Height := Round8(R.Bottom - R.Top);
    end;

    if Assigned(FOnInsert) then
      FOnInsert(Self);
  end;

// select objects that inside of selection rect
  if FMode1 = dmSelectionRect then
  begin
    NormalizeRect(FSelectionRect);
    FSelectedObjects.Clear;
    for i := 0 to FObjects.Count - 1 do
    begin
      c := FObjects[i];
      if (c is TfrxReportComponent) and not (c is TfrxBand) and Contain(c) then
        if not (csContainer in c.frComponentStyle) then
          FSelectedObjects.Add(c)
        else
        begin
          for j := 0 to c.ContainerObjects.Count - 1 do
          begin
            c1 := c.ContainerObjects[j];
            if c1.Visible and Contain(c1) then
              FSelectedObjects.Add(c1);
          end;
        end;
    end;

    if FSelectedObjects.Count = 0 then
      FSelectedObjects.Add(FPage);
  end;

// inplace editing
  if FMode1 = dmInplaceEdit then
  begin
    FSelectedObjects.Clear;
    FSelectedObjects.Add(FInplaceObject);
    SelectionChanged;
    TInplaceMemo(FInplaceMemo).Edit(FInplaceObject);
    FMode1 := dmNone;
  end;

// round coordinates
  if FMode1 in [dmMove, dmSize] then
    for i := 0 to SelectedCount - 1 do
    begin
      c := FSelectedObjects[i];
      c.Left := Round8(c.Left);
      c.Top := Round8(c.Top);
      c.Width := Round8(c.Width);
      c.Height := Round8(c.Height);
    end;
  if FMode1 = dmSizeBand then
    FSizedBand.Height := Round8(FSizedBand.Height);

  // container
  if FMode1 = dmContainer then
  begin
    c := SelectedObjects[0];
    c.ContainerMouseUp(Self, X, Y);
  end;

  AdjustBands;
  if not ListsEqual(l, FSelectedObjects) then
    SelectionChanged else
    Repaint;
  DoModify;
  l.Free;
  FCT := ct0;
  if not ((FMode = dmInsert) and (FInsertion.ComponentClass <> nil)) then
    FMode1 := dmNone;

  if SelectedCount = 0 then
    NotifyRect := frxRect(X / FScale, Y / FScale, 0, 0) else
    NotifyRect := GetSelectionBounds;
  if Assigned(FOnNotifyPosition) then
    FOnNotifyPosition(NotifyRect);
end;

procedure TfrxDesignerWorkspace.DblClick;
begin
  inherited;
  EditObject;
  FDblClicked := True;
end;

procedure TfrxDesignerWorkspace.MouseLeave;
begin
  if not FMouseDown and (FMode1 = dmInsertObject) then
  begin
//    DrawInsertionRect;
    FInsertion.Left := -FGridX * 1000;
    FInsertion.Top := -FGridY * 1000;
    Repaint;
  end;
  if not FMouseDown and (FMode1 = dmInsertLine) then
  begin
    DrawCross(False);
    if FGridType = gtChar then
    begin
      FInsertion.Left := - FGridX / 2;
      FInsertion.Top := - FGridY / 2;
    end
    else
    begin
      FInsertion.Left := - FGridX;
      FInsertion.Top := - FGridY;
    end;
  end;
  if FMode = dmDrag then
    SetInsertion(nil, 0, 0, 0);
end;

procedure TfrxDesignerWorkspace.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  MouseLeave;
end;

procedure TfrxDesignerWorkspace.CheckGuides(var kx, ky: Extended;
  var Result: Boolean);
begin
//
end;

procedure TfrxDesignerWorkspace.GroupObjects;
var
  i, j: Integer;
  c: TfrxComponent;
  sl: TStringList;
begin
  sl := TStringList.Create;
  sl.Sorted := True;
  sl.Duplicates := dupIgnore;

  { reset group index }
  for i := 0 to SelectedCount - 1 do
  begin
    c := FSelectedObjects[i];
    c.GroupIndex := 0;
  end;

  { collect available indexes }
  for i := 0 to FObjects.Count - 1 do
  begin
    c := FObjects[i];
    sl.Add(IntToStr(c.GroupIndex));
  end;

  { find an unique index }
  j := 0;
  repeat
    Inc(j);
  until sl.IndexOf(IntToStr(j)) = -1;

  { set group index }
  for i := 0 to SelectedCount - 1 do
  begin
    c := FSelectedObjects[i];
    c.GroupIndex := j;
  end;

  sl.Free;
end;

procedure TfrxDesignerWorkspace.UngroupObjects;
var
  i: Integer;
  c: TfrxComponent;
begin
  for i := 0 to SelectedCount - 1 do
  begin
    c := FSelectedObjects[i];
    c.GroupIndex := 0;
  end;
end;

end.


//0f31356a91fea3356e5f76cdce90aa7b