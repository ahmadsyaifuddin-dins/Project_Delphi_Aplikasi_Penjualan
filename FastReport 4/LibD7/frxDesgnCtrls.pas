
{******************************************}
{                                          }
{             FastReport v4.0              }
{            Designer controls             }
{                                          }
{         Copyright (c) 1998-2005          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxDesgnCtrls;

interface

{$I frx.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, ToolWin, ImgList, frxClass,
  frxPictureCache
{$IFDEF Delphi6}
, Variants
{$ENDIF};


type
  TfrxRulerUnits = (ruCM, ruInches, ruPixels, ruChars);

  TfrxRuler = class(TPanel)
  private
    FOffset: Integer;
    FScale: Extended;
    FStart: Integer;
    FUnits: TfrxRulerUnits;
    FPosition: Extended;
    FSize: Integer;
    procedure SetOffset(const Value: Integer);
    procedure SetScale(const Value: Extended);
    procedure SetStart(const Value: Integer);
    procedure SetUnits(const Value: TfrxRulerUnits);
    procedure SetPosition(const Value: Extended);
    procedure WMEraseBackground(var Message: TMessage); message WM_ERASEBKGND;
    procedure SetSize(const Value: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
  published
    property Offset: Integer read FOffset write SetOffset;
    property Scale: Extended read FScale write SetScale;
    property Start: Integer read FStart write SetStart;
    property Units: TfrxRulerUnits read FUnits write SetUnits default ruPixels;
    property Position: Extended read FPosition write SetPosition;
    property Size: Integer read FSize write SetSize;
  end;

  TfrxScrollBox = class(TScrollBox)
  protected
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
  end;

  TfrxCustomSelector = class(TPanel)
  private
    procedure WMEraseBackground(var Message: TMessage); message WM_ERASEBKGND;
  protected
    procedure DrawEdge(X, Y: Integer; IsDown: Boolean); virtual; abstract;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
  public
    procedure Paint; override;
    constructor Create(AOwner: TComponent); override;
  end;

  TfrxColorSelector = class(TfrxCustomSelector)
  private
    FColor: TColor;
    FOnColorChanged: TNotifyEvent;
  protected
    procedure DrawEdge(X, Y: Integer; IsDown: Boolean); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
    property Color: TColor read FColor write FColor;
    property OnColorChanged: TNotifyEvent read FOnColorChanged write FOnColorChanged;
  end;

  TfrxLineSelector = class(TfrxCustomSelector)
  private
    FStyle: Byte;
    FOnStyleChanged: TNotifyEvent;
  protected
    procedure DrawEdge(X, Y: Integer; IsDown: Boolean); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
    property Style: Byte read FStyle;
    property OnStyleChanged: TNotifyEvent read FOnStyleChanged write FOnStyleChanged;
  end;

  TfrxUndoBuffer = class(TObject)
  private
    FPictureCache: TfrxPictureCache;
    FRedo: TList;
    FUndo: TList;
    function GetRedoCount: Integer;
    function GetUndoCount: Integer;
    procedure SetPictureFlag(Report: TfrxReport; Flag: Boolean);
    procedure SetPictures(Report: TfrxReport);
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddUndo(Report: TfrxReport);
    procedure AddRedo(Report: TfrxReport);
    procedure GetUndo(Report: TfrxReport);
    procedure GetRedo(Report: TfrxReport);
    procedure ClearUndo;
    procedure ClearRedo;
    property UndoCount: Integer read GetUndoCount;
    property RedoCount: Integer read GetRedoCount;
    property PictureCache: TfrxPictureCache read FPictureCache write FPictureCache;
  end;

  TfrxClipboard = class(TObject)
  private
    FDesigner: TfrxCustomDesigner;
    FPictureCache: TfrxPictureCache;
    function GetPasteAvailable: Boolean;
  public
    constructor Create(ADesigner: TfrxCustomDesigner);
    procedure Copy;
    procedure Paste;
    property PasteAvailable: Boolean read GetPasteAvailable;
    property PictureCache: TfrxPictureCache read FPictureCache write FPictureCache;
  end;


implementation

uses
  frxDMPClass, frxPopupForm, frxDsgnIntf, frxCtrls, frxXMLSerializer, Clipbrd,
  frxUtils, frxXML;

const
  Colors: array[0..47] of TColor =
    (clNone, clWhite, clBlack, clMaroon, clGreen, clOlive, clNavy, clPurple,
     clGray, clSilver, clTeal, clRed, clLime, clYellow, clBlue, clFuchsia,
     $CCCCCC, $E4E4E4, clAqua, $00CCFF, $00CC98, $98FFFF, $FFCC00, $FF98CC,
     $D8D8D8, $F0F0F0, $FFFFDC, $CAE4FF, $CCFFCC, $CCFFFF, $FFF4CC, $CC98FF,
     clBtnFace, $46DAFF, $9BEBFF, $00A47B, $FDBD97, $FED3BA, $6ACFFF, $FFF4CC,
     clBtnFace, clBtnFace, clBtnFace, clBtnFace, clBtnFace, clBtnFace, clBtnFace, clBtnFace);

type
  THackControl = class(TWinControl);


{ TfrxRuler }

constructor TfrxRuler.Create(AOwner: TComponent);
begin
  inherited;
  FScale := 1;
  DoubleBuffered := True;
end;

procedure TfrxRuler.WMEraseBackground(var Message: TMessage);
begin
//
end;

procedure TfrxRuler.Paint;
var
  fh, oldfh: HFont;
  sz: Integer;

  function CreateRotatedFont(Font: TFont): HFont;
  var
    F: TLogFont;
  begin
    GetObject(Font.Handle, SizeOf(TLogFont), @F);
    F.lfEscapement := 90 * 10;
    F.lfOrientation := 90 * 10;
    Result := CreateFontIndirect(F);
  end;

  procedure Line(x, y, dx, dy: Integer);
  begin
    Canvas.MoveTo(x, y);
    Canvas.LineTo(x + dx, y + dy);
  end;

  procedure DrawLines;
  var
    i, dx, maxi: Extended;
    i1, h, w, w5, w10, maxw, ofs: Integer;
    s: String;
  begin
    with Canvas do
    begin
      Pen.Color := clBlack;
      Brush.Style := bsClear;
      w5 := 5;
      w10 := 10;
      if FUnits = ruCM then
        dx := fr01cm * FScale
      else if FUnits = ruInches then
        dx := fr01in * FScale
      else if FUnits = ruChars then
      begin
        if Align = alLeft then
          dx := fr1CharY * FScale / 10 else
          dx := fr1CharX * FScale / 10
      end
      else
      begin
        dx := FScale;
        w5 := 50;
        w10 := 100;
      end;

      if FSize = 0 then
      begin
        if Align = alLeft then
          maxi := Height + FStart else
          maxi := Width + FStart;
      end
      else
        maxi := FSize;

      if FUnits = ruPixels then
        s := IntToStr(FStart + Round(maxi / dx)) else
        s := IntToStr((FStart + Round(maxi / dx)) div 10);

      maxw := TextWidth(s);
      ofs := FOffset - FStart;
      if FUnits = ruChars then
      begin
        if Align = alLeft then
          Inc(ofs, Round(fr1CharY * FScale / 2)) else
          Inc(ofs, Round(fr1CharX * FScale / 2))
      end;

      i := 0;
      i1 := 0;
      while i < maxi do
      begin
        h := 0;
        if i1 = 0 then
          h := 0
        else if i1 mod w10 = 0 then
          h := 6
        else if i1 mod w5 = 0 then
          h := 4
        else if FUnits <> ruPixels then
          h := 2;

        if (h = 2) and (dx * w10 < 41) then
          h := 0;
        if (h = 4) and (dx * w10 < 21) then
          h := 0;

        w := 0;
        if h = 6 then
        begin
          if maxw > dx * w10 * 1.5 then
            w := w10 * 4
          else if maxw > dx * w10 * 0.7 then
            w := w10 * 2
          else
            w := w10;
        end;

        if FUnits = ruPixels then
          s := IntToStr(i1) else
          s := IntToStr(i1 div 10);

        if (w <> 0) and (i1 mod w = 0) and (ofs + i >= FOffset) then
          if Align = alLeft then
            TextOut(Width - TextHeight(s) - 6, ofs + Round(i) + TextWidth(s) div 2 + 1, s) else
            TextOut(ofs + Round(i) - TextWidth(s) div 2 + 1, 4, s)
        else if (h <> 0) and (ofs + i >= FOffset) then
          if Align = alLeft then
            Line(3 + (13 - h) div 2, ofs + Round(i), h, 0) else
            Line(ofs + Round(i), 3 + (13 - h) div 2, 0, h);

        i := i + dx;
        Inc(i1);
      end;

      i := FPosition * dx;
      if FUnits <> ruPixels then
        i := i * 10;
      if ofs + i >= FOffset then
        if Align = alLeft then
          Line(3, ofs + Round(i), 13, 0) else
          Line(ofs + Round(i), 3, 0, 13);
    end;
  end;

begin
  fh := 0; oldfh := 0;
  with Canvas do
  begin
    Brush.Color := clBtnFace;
    Brush.Style := bsSolid;
    FillRect(Rect(0, 0, Width, Height));
    Brush.Color := clWindow;

    Font.Name := 'Arial';
    Font.Size := 7;
    if Align = alLeft then
    begin
      if FSize = 0 then
        sz := Height
      else
        sz := FSize + FOffset;
      FillRect(Rect(3, FOffset, Width - 5, sz));
      fh := CreateRotatedFont(Font);
      oldfh := SelectObject(Handle, fh);
    end
    else
    begin
      if FSize = 0 then
        sz := Width
      else
        sz := FSize + FOffset;
      FillRect(Rect(FOffset, 3, sz, Height - 5));
    end;
  end;

  DrawLines;

  if Align = alLeft then
  begin
    SelectObject(Canvas.Handle, oldfh);
    DeleteObject(fh);
  end;
end;

procedure TfrxRuler.SetOffset(const Value: Integer);
begin
  FOffset := Value;
  Invalidate;
end;

procedure TfrxRuler.SetPosition(const Value: Extended);
begin
  FPosition := Value;
  Invalidate;
end;

procedure TfrxRuler.SetScale(const Value: Extended);
begin
  FScale := Value;
  Invalidate;
end;

procedure TfrxRuler.SetStart(const Value: Integer);
begin
  FStart := Value;
  Invalidate;
end;

procedure TfrxRuler.SetUnits(const Value: TfrxRulerUnits);
begin
  FUnits := Value;
  Invalidate;
end;

procedure TfrxRuler.SetSize(const Value: Integer);
begin
  FSize := Value;
  Invalidate;
end;


{ TfrxScrollBox }

procedure TfrxScrollBox.KeyDown(var Key: Word; Shift: TShiftState);
var
  i: Integer;
begin
  inherited;
  for i := 0 to ControlCount - 1 do
    if Controls[i] is TWinControl then
      THackControl(Controls[i]).KeyDown(Key, Shift);
end;

procedure TfrxScrollBox.KeyPress(var Key: Char);
var
  i: Integer;
begin
  inherited;
  for i := 0 to ControlCount - 1 do
    if Controls[i] is TWinControl then
      THackControl(Controls[i]).KeyPress(Key);
end;

procedure TfrxScrollBox.KeyUp(var Key: Word; Shift: TShiftState);
var
  i: Integer;
begin
  inherited;
  for i := 0 to ControlCount - 1 do
    if Controls[i] is TWinControl then
      THackControl(Controls[i]).KeyUp(Key, Shift);
end;

procedure TfrxScrollBox.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result := DLGC_WANTARROWS or DLGC_WANTTAB;
end;


{ TfrxCustomSelector }

constructor TfrxCustomSelector.Create(AOwner: TComponent);
var
  f: TfrxPopupForm;
  p: TPoint;
begin
  f := TfrxPopupForm.Create(nil);
  f.AutoSize := True;

  inherited Create(f);
  Parent := f;
  DoubleBuffered := True;
  Tag := AOwner.Tag;

  with TControl(AOwner) do
    p := ClientToScreen(Point(0, Height + 2));
  f.SetBounds(p.X, p.Y, 20, 20);
  f.Show;
end;

procedure TfrxCustomSelector.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  DrawEdge(X, Y, True);
end;

procedure TfrxCustomSelector.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  DrawEdge(X, Y, False);
end;

procedure TfrxCustomSelector.Paint;
begin
  with Canvas do
  begin
    Pen.Color := clBtnShadow;
    Brush.Color := clWindow;
    Rectangle(0, 0, ClientWidth, ClientHeight);
  end;
end;

procedure TfrxCustomSelector.WMEraseBackground(var Message: TMessage);
begin
//
end;


{ TfrxColorSelector }

constructor TfrxColorSelector.Create(AOwner: TComponent);
begin
  inherited;
  Width := 155;
  Height := 143;
end;

procedure TfrxColorSelector.DrawEdge(X, Y: Integer; IsDown: Boolean);
var
  r: TRect;
begin
  X := (X - 5) div 18;
  if X >= 8 then
    X := 7;
  Y := (Y - 5) div 18;

  Repaint;
  if Y < 6 then
    r := Rect(X * 18 + 5, Y * 18 + 5, X * 18 + 23, Y * 18 + 23) else
    r := Rect(5, 113, Width - 6, Height - 6);

  with Canvas do
  begin
    Brush.Style := bsClear;
    Pen.Color := $C56A31;
    Rectangle(r.Left, r.Top, r.Right, r.Bottom);
    InflateRect(r, -1, -1);
    Pen.Color := $E8E6E2;
    Rectangle(r.Left, r.Top, r.Right, r.Bottom);
    InflateRect(r, -1, -1);
    Rectangle(r.Left, r.Top, r.Right, r.Bottom);
  end;
end;

procedure TfrxColorSelector.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  cd: TColorDialog;

  procedure AddCustomColor;
  var
    i: Integer;
    Found: Boolean;
    Empty: Integer;
  begin
    Found := False;
    Empty := 0;
    for i := 0 to 47 do
    begin
      if Colors[i] = FColor then
        Found := True;
      if (i > 37) and (Colors[i] = clBtnFace) and (Empty = 0) then
        Empty := i;
    end;

    if Found then exit;

    if Empty = 0 then
    begin
      for i := 40 to 46 do
        Colors[i] := Colors[i + 1];
      Empty := 47;
    end;
    Colors[Empty] := FColor
  end;

begin
  X := (X - 5) div 18;
  if X >= 8 then
    X := 7;
  Y := (Y - 5) div 18;

  if Y < 6 then
    FColor := Colors[X + Y * 8]
  else
  begin
    TForm(Parent).AutoSize := False;
    Parent.Height := 0;
    cd := TColorDialog.Create(Self);
    cd.Options := [cdFullOpen];
    cd.Color := FColor;
    if cd.Execute then
      FColor := cd.Color else
      Exit;

    AddCustomColor;
  end;

  Repaint;
  if Assigned(FOnColorChanged) then
    FOnColorChanged(Self);
  Parent.Hide;
end;

procedure TfrxColorSelector.Paint;
var
  i, j: Integer;
  s: String;
begin
  inherited;

  with Canvas do
  begin
    for j := 0 to 5 do
      for i := 0 to 7 do
      begin
        if (i = 0) and (j = 0) then
          Brush.Color := clWhite else
          Brush.Color := Colors[i + j * 8];
        Pen.Color := clGray;
        Rectangle(i * 18 + 8, j * 18 + 8, i * 18 + 20, j * 18 + 20);
        if (i = 0) and (j = 0) then
        begin
          MoveTo(i * 18 + 10, j * 18 + 10);
          LineTo(i * 18 + 18, j * 18 + 18);
          MoveTo(i * 18 + 17, j * 18 + 10);
          LineTo(i * 18 + 9, j * 18 + 18);
        end;
      end;

    Pen.Color := clGray;
    Brush.Color := clBtnFace;
    Rectangle(8, 116, Width - 9, Height - 9);
    s := 'Other...';
    Font := Self.Font;
    TextOut((Width - TextWidth(s)) div 2, 118, s);
  end;
end;


{ TfrxLineSelector }

constructor TfrxLineSelector.Create(AOwner: TComponent);
begin
  inherited;
  Width := 98;
  Height := 106;
end;

procedure TfrxLineSelector.DrawEdge(X, Y: Integer; IsDown: Boolean);
var
  r: TRect;
begin
  Y := (Y - 5) div 16;
  if Y > 5 then
    Y := 5;

  Repaint;

  r := Rect(5, Y * 16 + 5, Width - 5, Y * 16 + 21);
  if IsDown then
    Frame3D(Canvas, r, clBtnShadow, clBtnShadow, 2) else
    Frame3D(Canvas, r, clBtnShadow, clBtnShadow, 1);
end;

procedure TfrxLineSelector.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  Y := (Y - 5) div 16;
  if Y > 5 then
    Y := 5;

  FStyle := Y;

  Repaint;
  if Assigned(FOnStyleChanged) then
    FOnStyleChanged(Self);
  Parent.Hide;
end;

procedure TfrxLineSelector.Paint;
var
  i: Integer;

  procedure DrawLine(Y, Style: Integer);
  begin
    if Style = 5 then
    begin
      Style := 0;
      DrawLine(Y - 2, Style);
      Inc(Y, 2);
    end;

    with Canvas do
    begin
      Pen.Color := clBlack;
      Pen.Style := TPenStyle(Style);
      MoveTo(7, Y);
      LineTo(Width - 8, Y);
      MoveTo(7, Y + 1);
      LineTo(Width - 8, Y + 1);
    end;
  end;

begin
  inherited;

  for i := 0 to 5 do
    DrawLine(12 + i * 16, i);
end;


{ TfrxUndoBuffer }

constructor TfrxUndoBuffer.Create;
begin
  FRedo := TList.Create;
  FUndo := TList.Create;
end;

destructor TfrxUndoBuffer.Destroy;
begin
  ClearUndo;
  ClearRedo;
  FUndo.Free;
  FRedo.Free;
  inherited;
end;

procedure TfrxUndoBuffer.AddUndo(Report: TfrxReport);
var
  m: TMemoryStream;
begin
  m := TMemoryStream.Create;
  FUndo.Add(m);
  SetPictureFlag(Report, False);
  try
    Report.SaveToStream(m);
  finally
    SetPictureFlag(Report, True);
  end;
end;

procedure TfrxUndoBuffer.AddRedo(Report: TfrxReport);
var
  m: TMemoryStream;
begin
  m := TMemoryStream.Create;
  FRedo.Add(m);
  SetPictureFlag(Report, False);
  try
    Report.SaveToStream(m);
  finally
    SetPictureFlag(Report, True);
  end;
end;

procedure TfrxUndoBuffer.GetUndo(Report: TfrxReport);
var
  m: TMemoryStream;
begin
  m := FUndo[FUndo.Count - 2];
  m.Position := 0;
  Report.Reloading := True;
  try
    Report.LoadFromStream(m);
  finally
    Report.Reloading := False;
  end;
  SetPictures(Report);

  m := FUndo[FUndo.Count - 1];
  m.Free;
  FUndo.Delete(FUndo.Count - 1);
end;

procedure TfrxUndoBuffer.GetRedo(Report: TfrxReport);
var
  m: TMemoryStream;
begin
  m := FRedo[FRedo.Count - 1];
  m.Position := 0;
  Report.Reloading := True;
  try
    Report.LoadFromStream(m);
  finally
    Report.Reloading := False;
  end;
  SetPictures(Report);

  m.Free;
  FRedo.Delete(FRedo.Count - 1);
end;

procedure TfrxUndoBuffer.ClearUndo;
begin
  while FUndo.Count > 0 do
  begin
    TMemoryStream(FUndo[0]).Free;
    FUndo.Delete(0);
  end;
end;

procedure TfrxUndoBuffer.ClearRedo;
begin
  while FRedo.Count > 0 do
  begin
    TMemoryStream(FRedo[0]).Free;
    FRedo.Delete(0);
  end;
end;

function TfrxUndoBuffer.GetRedoCount: Integer;
begin
  Result := FRedo.Count;
end;

function TfrxUndoBuffer.GetUndoCount: Integer;
begin
  Result := FUndo.Count;
end;

procedure TfrxUndoBuffer.SetPictureFlag(Report: TfrxReport; Flag: Boolean);
var
  i: Integer;
  l: TList;
  c: TfrxComponent;
begin
  l := Report.AllObjects;
  for i := 0 to l.Count - 1 do
  begin
    c := l[i];
    if c is TfrxPictureView then
    begin
      TfrxPictureView(c).IsPictureStored := Flag;
      TfrxPictureView(c).IsImageIndexStored := not Flag;
    end;
  end;
end;

procedure TfrxUndoBuffer.SetPictures(Report: TfrxReport);
var
  i: Integer;
  l: TList;
  c: TfrxComponent;
begin
  l := Report.AllObjects;
  for i := 0 to l.Count - 1 do
  begin
    c := l[i];
    if c is TfrxPictureView then
      FPictureCache.GetPicture(TfrxPictureView(c));
  end;
end;


{ TfrxClipboard }

constructor TfrxClipboard.Create(ADesigner: TfrxCustomDesigner);
begin
  FDesigner := ADesigner;
end;

procedure TfrxClipboard.Copy;
var
  c, c1: TfrxComponent;
  i, j: Integer;
  text: String;
  minX, minY: Extended;
  List: TList;
  Flag: Boolean;

  procedure Write(c: TfrxComponent);
  var
    c1: TfrxComponent;
    Writer: TfrxXMLSerializer;
  begin
    c1 := TfrxComponent(c.NewInstance);
    c1.Create(FDesigner.Page);

    if c is TfrxPictureView then
    begin
      TfrxPictureView(c).IsPictureStored := False;
      TfrxPictureView(c).IsImageIndexStored := True;
    end;

    try
      c1.Assign(c);
    finally
      if c is TfrxPictureView then
      begin
        TfrxPictureView(c).IsPictureStored := True;
        TfrxPictureView(c).IsImageIndexStored := False;
        TfrxPictureView(c1).IsImageIndexStored := True;
      end;
    end;

    c1.Left := c1.Left - minX;
    c1.Top := c.AbsTop - minY;

    Writer := TfrxXMLSerializer.Create(nil);
    Writer.Owner := c1.Report;
    text := text + '<' + c1.ClassName + ' Name="' + c.Name + '"' + Writer.ObjToXML(c1) + '/>';
    Writer.Free;

    c1.Free;
  end;

begin
  text := '#FR3 clipboard#' + #10#13;

  minX := 100000;
  minY := 100000;
  for i := 0 to FDesigner.SelectedObjects.Count - 1 do
  begin
    c := FDesigner.SelectedObjects[i];
    if c.AbsLeft < minX then
      minX := c.AbsLeft;
    if c.AbsTop < minY then
      minY := c.AbsTop;
  end;

  List := FDesigner.Page.AllObjects;
  for i := 0 to List.Count - 1 do
  begin
    c := List[i];
    if FDesigner.SelectedObjects.IndexOf(c) <> -1 then
    begin
      Write(c);
      if c is TfrxBand then
      begin
        Flag := False;
        for j := 0 to c.Objects.Count - 1 do
        begin
          c1 := c.Objects[j];
          if FDesigner.SelectedObjects.IndexOf(c1) <> -1 then
            Flag := True;
        end;

        if not Flag then
          for j := 0 to c.Objects.Count - 1 do
            Write(c.Objects[j]);
      end;
    end;
  end;

  Clipboard.AsText := text;
end;

function TfrxClipboard.GetPasteAvailable: Boolean;
begin
  try
    Result := Clipboard.HasFormat(CF_TEXT) and
      (Pos('#FR3 clipboard#', Clipboard.AsText) = 1);
  except
    Result := False;
  end;
end;

procedure TfrxClipboard.Paste;
var
  c: TfrxComponent;
  sl: TStrings;
  s: TStream;
  List: TList;
  NewCompName: string;
  NewComp: TfrxComponent;

  function ReadComponent_(AReader: TfrxXMLSerializer; Root: TfrxComponent): TfrxComponent;
  var
    rd: TfrxXMLReader;
    RootItem: TfrxXMLItem;
  begin
    rd := TfrxXMLReader.Create(AReader.Stream);
    RootItem := TfrxXMLItem.Create;

    try
      rd.ReadRootItem(RootItem, False);
      Result := AReader.ReadComponentStr(Root, RootItem.Name + ' ' + RootItem.Text);

      NewCompName := RootItem.Prop['Name'];
    finally
      rd.Free;
      RootItem.Free;
    end;
  end;

  function ReadComponent: TfrxComponent;
  var
    Reader: TfrxXMLSerializer;
  begin
    Reader := TfrxXMLSerializer.Create(s);
    Result := ReadComponent_(Reader, FDesigner.Report);
    Reader.Free;
  end;

  function FindBand(Band: TfrxComponent): Boolean;
  var
    i: Integer;
  begin
    Result := False;
    for i := 0 to FDesigner.Page.Objects.Count - 1 do
      if (FDesigner.Page.Objects[i] <> Band) and
        (TObject(FDesigner.Page.Objects[i]) is Band.ClassType) then
        Result := True;
  end;

  function CanInsert(c: TfrxComponent): Boolean;
  begin
    Result := True;
    if (c is TfrxDialogControl) and (FDesigner.Page is TfrxReportPage) then
      Result := False;
    if not (c is TfrxDialogComponent) and not (c is TfrxDialogControl) and
      (FDesigner.Page is TfrxDialogPage) then
      Result := False;
    if ((c is TfrxDMPMemoView) or (c is TfrxDMPLineView)) and
      not (FDesigner.Page is TfrxDMPPage) then
      Result := False;
    if not ((c is TfrxBand) or (c is TfrxDMPMemoView) or (c is TfrxDMPLineView)) and
      (FDesigner.Page is TfrxDMPPage) then
      Result := False;
    if not ((c is TfrxCustomLineView) or (c is TfrxCustomMemoView) or
      (c is TfrxShapeView) or (c is TfrxDialogComponent)) and
      (FDesigner.Page is TfrxDataPage) then
      Result := False;
  end;

  procedure FindParent(c: TfrxComponent);
  var
    i: Integer;
    Found: Boolean;
    c1: TfrxComponent;
  begin
    Found := False;
    if not (c is TfrxBand) then
      for i := List.Count - 1 downto 0 do
      begin
        c1 := List[i];
        if c1 is TfrxBand then
          if (c.Top >= c1.Top) and (c.Top < c1.Top + c1.Height) then
          begin
            c.Parent := c1;
            c.Top := c.Top - c1.Top;
            Found := True;
            break;
          end;
      end;
    if not Found then
      c.Parent := FDesigner.Page;
  end;

begin
  FDesigner.SelectedObjects.Clear;

  sl := TStringList.Create;
  sl.Text := Clipboard.AsText;
  sl.Delete(0);

  s := TMemoryStream.Create;
  sl.SaveToStream(s);
  sl.Free;
  s.Position := 0;

  List := TList.Create;

  while s.Position < s.Size do
  begin
    c := ReadComponent;
    if c = nil then break;

    if (((c is TfrxReportTitle) or (c is TfrxReportSummary) or
       (c is TfrxPageHeader) or (c is TfrxPageFooter) or
       (c is TfrxColumnHeader) or (c is TfrxColumnFooter)) and FindBand(c)) or
       not CanInsert(c) then
      c.Free
    else
    begin
      if c is TfrxPictureView then
        FPictureCache.GetPicture(TfrxPictureView(c));
      List.Add(c);
      FindParent(c);
      NewComp := FDesigner.Report.FindComponent(NewCompName) as TfrxComponent;
      if ((NewComp <> nil) and (NewComp <> c)) or (NewCompName = '') then
        c.CreateUniqueName
      else
        c.Name := NewCompName;
      c.GroupIndex := 0;
      FDesigner.Objects.Add(c);
      if c.Parent = FDesigner.Page then
        FDesigner.SelectedObjects.Add(c);
      c.OnPaste;
    end;
  end;

  if FDesigner.SelectedObjects.Count = 0 then
    FDesigner.SelectedObjects.Add(FDesigner.Page);

  List.Free;
  s.Free;
end;


end.




//0f31356a91fea3356e5f76cdce90aa7b