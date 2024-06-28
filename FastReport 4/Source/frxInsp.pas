
{******************************************}
{                                          }
{             FastReport v4.0              }
{             Object Inspector             }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxInsp;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, frxDsgnIntf, frxPopupForm,
  frxClass, Menus, ComCtrls
{$IFDEF UseTabset}
, Tabs
{$ENDIF}
{$IFDEF Delphi6}
, Variants
{$ENDIF};
  

type
  TfrxObjectInspector = class(TForm)
    ObjectsCB: TComboBox;
    PopupMenu1: TPopupMenu;
    N11: TMenuItem;
    N21: TMenuItem;
    N31: TMenuItem;
    BackPanel: TPanel;
    Box: TScrollBox;
    PB: TPaintBox;
    Edit1: TEdit;
    EditPanel: TPanel;
    EditBtn: TSpeedButton;
    ComboPanel: TPanel;
    ComboBtn: TSpeedButton;
    HintPanel: TScrollBox;
    Splitter1: TSplitter;
    PropL: TLabel;
    DescrL: TLabel;
    N41: TMenuItem;
    N51: TMenuItem;
    N61: TMenuItem;
    procedure PBPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure PBMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PBMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PBMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure EditBtnClick(Sender: TObject);
    procedure ComboBtnClick(Sender: TObject);
    procedure Edit1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ObjectsCBClick(Sender: TObject);
    procedure ObjectsCBDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure PBDblClick(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormEndDock(Sender, Target: TObject; X, Y: Integer);
    procedure ComboBtnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure TabChange(Sender: TObject);
    procedure N11Click(Sender: TObject);
    procedure N21Click(Sender: TObject);
    procedure N31Click(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
  private
    { Private declarations }
    FDesigner: TfrxCustomDesigner;
    FDisableDblClick: Boolean;
    FDisableUpdate: Boolean;
    FDown: Boolean;
    FEventList: TfrxPropertyList;
    FHintWindow: THintWindow;
    FItemIndex: Integer;
    FLastPosition: String;
    FList: TfrxPropertyList;
    FPopupForm: TfrxPopupForm;
    FPopupLB: TListBox;
    FPopupLBVisible: Boolean;
    FPropertyList: TfrxPropertyList;
    FPanel: TPanel;
    FRowHeight: Integer;
    FSelectedObjects: TList;
    FSplitterPos: Integer;
{$IFDEF UseTabset}
    FTabs: TTabSet;
{$ELSE}
    FTabs: TTabControl;
{$ENDIF}
    FTempBMP: TBitmap;
    FTempList: TList;
    FTickCount: UInt;
    FUpdatingObjectsCB: Boolean;
    FUpdatingPB: Boolean;
    FOnSelectionChanged: TNotifyEvent;
    FOnModify: TNotifyEvent;

    function Count: Integer;
    function GetItem(Index: Integer): TfrxPropertyItem;
    function GetName(Index: Integer): String;
    function GetOffset(Index: Integer): Integer;
    function GetType(Index: Integer): TfrxPropertyAttributes;
    function GetValue(Index: Integer): String;
    procedure AdjustControls;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MouseLeave;
    procedure DrawOneLine(i: Integer; Selected: Boolean);
    procedure DoModify;
    procedure SetObjects(Value: TList);
    procedure SetItemIndex(Value: Integer);
    procedure SetSelectedObjects(Value: TList);
    procedure SetValue(Index: Integer; Value: String);
    procedure LBClick(Sender: TObject);
    function GetSplitter1Pos: Integer;
    procedure SetSplitter1Pos(const Value: Integer);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DisableUpdate;
    procedure EnableUpdate;
    procedure Inspect(AObjects: array of TPersistent);
    procedure SetColor(Color: TColor);
    procedure UpdateProperties;
    property Objects: TList write SetObjects;
    property ItemIndex: Integer read FItemIndex write SetItemIndex;
    property SelectedObjects: TList read FSelectedObjects write SetSelectedObjects;
    property SplitterPos: Integer read FSplitterPos write FSplitterPos;
    property Splitter1Pos: Integer read GetSplitter1Pos write SetSplitter1Pos;
    property OnModify: TNotifyEvent read FOnModify write FOnModify;
    property OnSelectionChanged: TNotifyEvent read FOnSelectionChanged write FOnSelectionChanged;
  end;


implementation

{$R *.DFM}

uses frxUtils, frxRes, frxrcInsp;


type
  TInspPanel = class(TPanel)
  protected
    procedure WMEraseBackground(var Message: TMessage); message WM_ERASEBKGND;
    procedure Paint; override;
  end;

  THackWinControl = class(TWinControl);


{ TInspPanel }

procedure TInspPanel.WMEraseBackground(var Message: TMessage);
begin
// empty method
end;

procedure TInspPanel.Paint;
begin
// empty method
end;


{ TfrxObjectInspector }

constructor TfrxObjectInspector.Create(AOwner: TComponent);
begin
  if not (AOwner is TfrxCustomDesigner) then
    raise Exception.Create('The Owner of the object inspector should be TfrxCustomDesigner');
  inherited Create(AOwner);
  FItemIndex := -1;
  FTempBMP := TBitmap.Create;
  FTempList := TList.Create;
  FDesigner := TfrxCustomDesigner(AOwner);
  FHintWindow := THintWindow.Create(Self);
  FHintWindow.Color := clInfoBk;

  FPanel := TInspPanel.Create(Self);
  with FPanel do
  begin
    Parent := Box;
    BevelInner := bvNone;
    BevelOuter := bvNone;
  end;
  PB.Parent := FPanel;
  ComboPanel.Parent := FPanel;
  EditPanel.Parent := FPanel;
  Edit1.Parent := FPanel;
  THackWinControl(Box).BevelKind := bkFlat;
  THackWinControl(HintPanel).BevelKind := bkFlat;

  FRowHeight := Canvas.TextHeight('Wg') + 3;
  with Box.VertScrollBar do
  begin
    Increment := FRowHeight;
    Tracking := True;
  end;

{$IFDEF UseTabset}
  FTabs := TTabSet.Create(Self);
  FTabs.OnClick := TabChange;
  FTabs.ShrinkToFit := True;
  FTabs.Style := tsSoftTabs;
  FTabs.TabPosition := tpTop;
{$ELSE}
  FTabs := TTabControl.Create(Self);
  FTabs.OnChange := TabChange;
{$ENDIF}
  FTabs.Parent := Self;
  FTabs.SendToBack;
  FTabs.Tabs.Add(frxResources.Get('oiProp'));
  FTabs.Tabs.Add(frxResources.Get('oiEvent'));
  FTabs.TabIndex := 0;

  if Screen.PixelsPerInch > 96 then
    ObjectsCB.ItemHeight := 19;
  FSplitterPos := PB.Width div 2;
  AutoScroll := False;

  FormResize(nil);

  Caption := frxGet(2000);
end;

destructor TfrxObjectInspector.Destroy;
begin
  FTempBMP.Free;
  FTempList.Free;
  if FPropertyList <> nil then
    FPropertyList.Free;
  if FEventList <> nil then
    FEventList.Free;
  inherited;
end;

procedure TfrxObjectInspector.UpdateProperties;
begin
  SetSelectedObjects(FSelectedObjects);
end;

procedure TfrxObjectInspector.Inspect(AObjects: array of TPersistent);
var
  i: Integer;
begin
  FTempList.Clear;
  for i := Low(AObjects) to High(AObjects) do
    FTempList.Add(AObjects[i]);
  Objects := FTempList;
  SelectedObjects := FTempList;
end;

function TfrxObjectInspector.GetSplitter1Pos: Integer;
begin
  Result := HintPanel.Height;
end;

procedure TfrxObjectInspector.SetSplitter1Pos(const Value: Integer);
begin
  HintPanel.Height := Value;
end;

procedure TfrxObjectInspector.DisableUpdate;
begin
  FDisableUpdate := True;
end;

procedure TfrxObjectInspector.EnableUpdate;
begin
  FDisableUpdate := False;
end;

procedure TfrxObjectInspector.SetColor(Color: TColor);
begin
  ObjectsCB.Color := Color;
  Box.Color := Color;
  PB.Repaint;
end;

procedure TfrxObjectInspector.SetObjects(Value: TList);
var
  i: Integer;
  s: String;
begin
  ObjectsCB.Items.Clear;
  for i := 0 to Value.Count - 1 do
  begin
    if TObject(Value[i]) is TComponent then
      s := TComponent(Value[i]).Name + ': ' + TComponent(Value[i]).ClassName else
      s := '';
    ObjectsCB.Items.AddObject(s, Value[i]);
  end;
end;

procedure TfrxObjectInspector.SetSelectedObjects(Value: TList);
var
  i: Integer;
  s: String;

  procedure CreateLists;
  var
    i: Integer;
    p: TfrxPropertyItem;
    s: String;
  begin
    if FPropertyList <> nil then
      FPropertyList.Free;
    if FEventList <> nil then
      FEventList.Free;
    FEventList := nil;

    FPropertyList := frxCreatePropertyList(Value, FDesigner);
    if FPropertyList <> nil then
    begin
      FEventList := TfrxPropertyList.Create(FDesigner);

      i := 0;
      while i < FPropertyList.Count do
      begin
        p := FPropertyList[i];
        s := p.Editor.PropInfo.PropType^.Name;
        if (Pos('Tfrx', s) = 1) and (Pos('Event', s) = Length(s) - 4) then
          p.Collection := FEventList else
          Inc(i);
      end;
    end;

    if FTabs.TabIndex = 0 then
      FList := FPropertyList else
      FList := FEventList;
  end;

begin
  FSelectedObjects := Value;
  CreateLists;

  FUpdatingObjectsCB := True;
  if FSelectedObjects.Count = 1 then
  begin
    ObjectsCB.ItemIndex := ObjectsCB.Items.IndexOfObject(FSelectedObjects[0]);
    if ObjectsCB.ItemIndex = -1 then
    begin
      s := TComponent(FSelectedObjects[0]).Name  + ': ' +
        TComponent(FSelectedObjects[0]).ClassName;
      ObjectsCB.Items.AddObject(s, FSelectedObjects[0]);
      ObjectsCB.ItemIndex := ObjectsCB.Items.IndexOfObject(FSelectedObjects[0]);
    end;
  end
  else
    ObjectsCB.ItemIndex := -1;
  FUpdatingObjectsCB := False;

  FItemIndex := -1;
  FormResize(nil);
  if Count > 0 then
  begin
    for i := 0 to Count - 1 do
      if GetName(i) = FLastPosition then
      begin
        ItemIndex := i;
        Exit;
      end;
    s := FLastPosition;
    ItemIndex := 0;
    FLastPosition := s;
  end;
end;

function TfrxObjectInspector.Count: Integer;

  function EnumProperties(p: TfrxPropertyList): Integer;
  var
    i: Integer;
  begin
    Result := 0;
    for i := 0 to p.Count - 1 do
    begin
      Inc(Result);
      if (p[i].SubProperty <> nil) and p[i].Expanded then
        Inc(Result, EnumProperties(p[i].SubProperty));
    end;
  end;

begin
  if FList <> nil then
    Result := EnumProperties(FList) else
    Result := 0;
end;

function TfrxObjectInspector.GetItem(Index: Integer): TfrxPropertyItem;

  function EnumProperties(p: TfrxPropertyList; var Index: Integer): TfrxPropertyItem;
  var
    i: Integer;
  begin
    Result := nil;
    for i := 0 to p.Count - 1 do
    begin
      Dec(Index);
      if Index < 0 then
      begin
        Result := p[i];
        break;
      end;
      if (p[i].SubProperty <> nil) and p[i].Expanded then
        Result := EnumProperties(p[i].SubProperty, Index);
      if Index < 0 then
        break;
    end;
  end;

begin
  if (Index >= 0) and (Index < Count) then
    Result := EnumProperties(FList, Index) else
    Result := nil;
end;

function TfrxObjectInspector.GetOffset(Index: Integer): Integer;
var
  p: TfrxPropertyList;
begin
  Result := 0;
  p := TfrxPropertyList(GetItem(Index).Collection);
  while p.Parent <> nil do
  begin
    Inc(Result);
    p := p.Parent;
  end;
end;

function TfrxObjectInspector.GetName(Index: Integer): String;
begin
  Result := GetItem(Index).Editor.GetName;
end;

function TfrxObjectInspector.GetType(Index: Integer): TfrxPropertyAttributes;
begin
  Result := GetItem(Index).Editor.GetAttributes;
end;

function TfrxObjectInspector.GetValue(Index: Integer): String;
begin
  Result := GetItem(Index).Editor.Value;
end;

procedure TfrxObjectInspector.DoModify;
var
  i: Integer;
begin
  if FSelectedObjects.Count = 1 then
  begin
    i := ObjectsCB.Items.IndexOfObject(FSelectedObjects[0]);
    if TObject(FSelectedObjects[0]) is TComponent then
      ObjectsCB.Items.Strings[i] := TComponent(FSelectedObjects[0]).Name + ': ' +
        TComponent(FSelectedObjects[0]).ClassName;
    ObjectsCB.ItemIndex := ObjectsCB.Items.IndexOfObject(FSelectedObjects[0]);
  end;

  if Assigned(FOnModify) then
    FOnModify(Self);
end;

procedure TfrxObjectInspector.SetItemIndex(Value: Integer);
var
  p: TfrxPropertyItem;
  s: String;
begin
  PropL.Caption := '';
  DescrL.Caption := '';
  if Value > Count - 1 then
    Value := Count - 1;
  if Value < 0 then
    Value := -1;

  Edit1.Visible := Count > 0;
  if Count = 0 then Exit;

  if FItemIndex <> -1 then
    if Edit1.Modified then
      SetValue(FItemIndex, Edit1.Text);
  FItemIndex := Value;

  if FItemIndex <> -1 then
  begin
    FLastPosition := GetName(FItemIndex);
    p := GetItem(FItemIndex);
    s := GetName(FItemIndex);
    PropL.Caption := s;
    if TfrxPropertyList(p.Collection).Component <> nil then
    begin
      s := 'prop' + s + '.' + TfrxPropertyList(p.Collection).Component.ClassName;
      if frxResources.Get(s) = s then
        s := frxResources.Get('prop' + GetName(FItemIndex)) else
        s := frxResources.Get(s);
      DescrL.Caption := s;
    end;
  end;

  AdjustControls;
end;

procedure TfrxObjectInspector.SetValue(Index: Integer; Value: String);
begin
  try
    GetItem(Index).Editor.Value := Value;
    DoModify;
    PBPaint(nil);
  except
    on E: Exception do
    begin
      frxErrorMsg(E.Message);
      Edit1.Text := GetItem(Index).Editor.Value;
    end;
  end;
end;

procedure TfrxObjectInspector.AdjustControls;
var
  PropType: TfrxPropertyAttributes;
  y, ww: Integer;
begin
  if (csDocking in ControlState) or FDisableUpdate then Exit;
  if FItemIndex = -1 then
  begin
    EditPanel.Visible := False;
    ComboPanel.Visible := False;
    Edit1.Visible := False;
    FUpdatingPB := False;
    PBPaint(nil);
    Exit;
  end;

  FUpdatingPB := True;
  PropType := GetType(FItemIndex);

  EditPanel.Visible := paDialog in PropType;
  ComboPanel.Visible := paValueList in PropType;
  Edit1.ReadOnly := paReadOnly in PropType;

  ww := PB.Width - FSplitterPos - 2;
  y := FItemIndex * FRowHeight + 1;
  if EditPanel.Visible then
  begin
    EditPanel.SetBounds(PB.Width - 15, y - 1, 15, FRowHeight - 1);
    EditBtn.SetBounds(0, 0, EditPanel.Width, EditPanel.Height);
    Dec(ww, 15);
  end;
  if ComboPanel.Visible then
  begin
    ComboPanel.SetBounds(PB.Width - 15, y - 1, 15, FRowHeight - 1);
    ComboBtn.SetBounds(0, 0, ComboPanel.Width, ComboPanel.Height);
    Dec(ww, 15);
  end;

  Edit1.Text := GetValue(FItemIndex);
  Edit1.Modified := False;
  Edit1.SetBounds(FSplitterPos + 2, y, ww, FRowHeight - 2);
  Edit1.SelectAll;

  if y + FRowHeight > Box.VertScrollBar.Position + Box.ClientHeight then
    Box.VertScrollBar.Position := y - Box.ClientHeight + FRowHeight;
  if y < Box.VertScrollBar.Position then
    Box.VertScrollBar.Position := y - 1;

  FUpdatingPB := False;
  PBPaint(nil);
end;

procedure TfrxObjectInspector.DrawOneLine(i: Integer; Selected: Boolean);
var
  R: TRect;
  s: String;
  p: TfrxPropertyItem;
  offs, add: Integer;

  procedure Line(x, y, dx, dy: Integer);
  begin
    FTempBMP.Canvas.MoveTo(x, y);
    FTempBMP.Canvas.LineTo(x + dx, y + dy);
  end;

  procedure DrawProperty;
  var
    x, y: Integer;
  begin
    x := offs + GetOffset(i) * (12 + add);
    y := 1 + i * FRowHeight;

    with FTempBMP.Canvas do
    begin
      Pen.Color := clGray;
      Brush.Color := clWhite;

      if offs < 12 then
      begin
        Rectangle(x + 1, y + 2 + add, x + 10, y + 11 + add);
        Line(x + 3, y + 6 + add, 5, 0);
        if s[1] = '+' then
          Line(x + 5, y + 4 + add, 0, 5);

        s := Copy(s, 2, 255);
        Inc(x, 12 + add);
      end;

      Brush.Style := bsClear;
      if ((s = 'Name') or (s = 'Width') or (s = 'Height') or (s = 'Left') or (s = 'Top'))
        and (GetOffset(i) = 0) then
        Font.Style := [fsBold];
      TextRect(R, x, y, s);
    end;
  end;

begin
  if Count > 0 then
  with FTempBMP.Canvas do
  begin
    Pen.Color := clBtnShadow;
    Font.Assign(Self.Font);
    R := Rect(0, i * FRowHeight, FSplitterPos, i * FRowHeight + FRowHeight - 1);

    if Screen.PixelsPerInch > 96 then
      add := 2
    else
      add := 0;
    p := GetItem(i);
    s := GetName(i);
    if p.SubProperty <> nil then
    begin
      offs := 1 + add;
      if p.Expanded then
        s := '-' + s else
        s := '+' + s;
    end
    else
      offs := 13 + add;

    p.Editor.ItemHeight := FRowHeight;

    if Selected then
    begin
      Pen.Color := clBtnFace;
      Line(0, FRowHeight + -1 + i * FRowHeight, PB.Width, 0);
      Brush.Color := clBtnFace;
      FillRect(R);
      DrawProperty;
    end
    else
    begin
      Pen.Color := clBtnFace;
      Line(0, FRowHeight + -1 + i * FRowHeight, PB.Width, 0);
      Pen.Color := clBtnFace;
      Line(FSplitterPos - 1, 0 + i * FRowHeight, 0, FRowHeight);
      DrawProperty;
      Font.Color := clNavy;
      if paOwnerDraw in p.Editor.GetAttributes then
        p.Editor.OnDrawItem(FTempBMP.Canvas,
          Rect(FSplitterPos + 2, 1 + i * FRowHeight, Width, 1 + (i + 1) * FRowHeight))
      else
        TextOut(FSplitterPos + 2, 1 + i * FRowHeight, GetValue(i));
    end;
  end;
end;


{ Form events }

procedure TfrxObjectInspector.FormShow(Sender: TObject);
begin
  AdjustControls;
end;

procedure TfrxObjectInspector.FormResize(Sender: TObject);
var
  h: Integer;
begin
  if Screen.PixelsPerInch > 96 then
    h := 26
  else
    h := 22;
  FTabs.SetBounds(0, ObjectsCB.Top + ObjectsCB.Height + 4, ClientWidth, h);
{$IFDEF UseTabset}
  BackPanel.Top := FTabs.Top + FTabs.Height - 1;
{$ELSE}
  BackPanel.Top := FTabs.Top + FTabs.Height - 2;
{$ENDIF}
  BackPanel.Width := ClientWidth;
  BackPanel.Height := ClientHeight - BackPanel.Top + 1;
  ObjectsCB.Width := ClientWidth;

  FPanel.Height := Count * FRowHeight;
  FPanel.Width := Box.ClientWidth;
  AdjustControls;
end;

procedure TfrxObjectInspector.FormEndDock(Sender, Target: TObject; X, Y: Integer);
begin
  FormResize(nil);
end;

procedure TfrxObjectInspector.TabChange(Sender: TObject);
begin
  if FDesigner.IsPreviewDesigner then
  begin
    FTabs.TabIndex := 0;
    Exit;
  end;
  if FTabs.TabIndex = 0 then
    FList := FPropertyList else
{$IFNDEF FR_VER_BASIC}
    FList := FEventList;
{$ELSE}
    FTabs.TabIndex := 0;
{$ENDIF}
  FItemIndex := -1;
  FormResize(nil);
end;

procedure TfrxObjectInspector.N11Click(Sender: TObject);
begin
  if Edit1.Visible then
    Edit1.CutToClipboard;
end;

procedure TfrxObjectInspector.N21Click(Sender: TObject);
begin
  if Edit1.Visible then
    Edit1.PasteFromClipboard;
end;

procedure TfrxObjectInspector.N31Click(Sender: TObject);
begin
  if Edit1.Visible then
    Edit1.CopyToClipboard;
end;

procedure TfrxObjectInspector.FormDeactivate(Sender: TObject);
begin
  if FDisableUpdate then Exit;
  SetItemIndex(FItemIndex);
end;


{ PB events }

procedure TfrxObjectInspector.PBPaint(Sender: TObject);
var
  i: Integer;
  r: TRect;
begin
  if FUpdatingPB then Exit;

  r := PB.BoundsRect;
  FTempBMP.Width := PB.Width;
  FTempBMP.Height := PB.Height;
  with FTempBMP.Canvas do
  begin
    Brush.Color := Box.Color;
    FillRect(r);
  end;

  if not FDisableUpdate then
  begin
    for i := 0 to Count - 1 do
      if i <> ItemIndex then
        DrawOneLine(i, False);
    if FItemIndex <> -1 then
      DrawOneLine(ItemIndex, True);
  end;

  PB.Canvas.Draw(0, 0, FTempBMP);
end;

procedure TfrxObjectInspector.PBMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  p: TfrxPropertyItem;
  n, x1: Integer;
begin
  FDisableDblClick := False;
  if Count = 0 then Exit;
  if PB.Cursor = crHSplit then
    FDown := True
  else
  begin
    n := Y div FRowHeight;

    if (X > FSplitterPos) and (X < FSplitterPos + 15) and
       (n >= 0) and (n < Count) then
    begin
      p := GetItem(n);
      if p.Editor.ClassName = 'TfrxBooleanProperty' then
      begin
        p.Editor.Edit;
        DoModify;
        PBPaint(nil);
        Exit;
      end;
    end;

    ItemIndex := n;
    Edit1.SetFocus;
    FTickCount := GetTickCount;

    p := GetItem(ItemIndex);
    x1 := GetOffset(ItemIndex) * 12;
    if (X > x1) and (X < x1 + 13) and (p.SubProperty <> nil) then
    begin
      p.Expanded := not p.Expanded;
      FormResize(nil);
      FDisableDblClick := True;
    end;
  end;
end;

procedure TfrxObjectInspector.PBMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FDown := False;
end;

procedure TfrxObjectInspector.PBMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  n, OffsetX, MaxWidth: Integer;
  s: String;
  HideHint: Boolean;

  procedure ShowHint(const s: String; x, y: Integer);
  var
    HintRect: TRect;
    p: TPoint;
  begin
    p := PB.ClientToScreen(Point(x - 2, y - 2));
    HintRect := FHintWindow.CalcHintRect(1000, s, nil);
    OffsetRect(HintRect, p.X, p.Y);
    FHintWindow.ActivateHint(HintRect, s);
    HideHint := False;
  end;

begin
  HideHint := True;

  if not FDown then
  begin
    if (X > FSplitterPos - 4) and (X < FSplitterPos + 2) then
      PB.Cursor := crHSplit
    else
    begin
      PB.Cursor := crDefault;

      { hint window }
      n := Y div FRowHeight;
      if (X > 12) and (n >= 0) and (n < Count) then
      begin
        if X <= FSplitterPos - 4 then
        begin
          OffsetX := (GetOffset(n) + 1) * 12;
          s := GetName(n);
          MaxWidth := FSplitterPos - OffsetX;
        end
        else
        begin
          OffsetX := FSplitterPos + 1;
          s := GetValue(n);
          MaxWidth := PB.ClientWidth - FSplitterPos;
          if n = ItemIndex then
            MaxWidth := 1000;
        end;

        if PB.Canvas.TextWidth(s) > MaxWidth then
          ShowHint(s, OffsetX, n * FRowHeight);
      end;
    end;
  end
  else
  begin
    if (x > 30) and (x < PB.ClientWidth - 30) then
      FSplitterPos := X;
    AdjustControls;
  end;

  if HideHint then
    FHintWindow.ReleaseHandle;
end;

procedure TfrxObjectInspector.PBDblClick(Sender: TObject);
var
  p: TfrxPropertyItem;
begin
  if (Count = 0) or FDisableDblClick then Exit;

  p := GetItem(ItemIndex);
  if p.SubProperty <> nil then
  begin
    p.Expanded := not p.Expanded;
    FormResize(nil);
  end;
end;


{ Edit1 events }

procedure TfrxObjectInspector.Edit1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if GetTickCount - FTickCount < GetDoubleClickTime then
    EditBtnClick(nil);
end;

procedure TfrxObjectInspector.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i: Integer;
begin
  if Count = 0 then Exit;
  if Key = vk_Escape then
  begin
    Edit1.Perform(EM_UNDO, 0, 0);
    Edit1.Modified := False;
  end;
  if Key = vk_Up then
  begin
    if ItemIndex > 0 then
      ItemIndex := ItemIndex - 1;
    Key := 0;
  end
  else if Key = vk_Down then
  begin
    if ItemIndex < Count - 1 then
      ItemIndex := ItemIndex + 1;
    Key := 0;
  end
  else if Key = vk_Prior then
  begin
    i := Box.Height div FRowHeight;
    i := ItemIndex - i;
    if i < 0 then
      i := 0;
    ItemIndex := i;
    Key := 0;
  end
  else if Key = vk_Next then
  begin
    i := Box.Height div FRowHeight;
    i := ItemIndex + i;
    ItemIndex := i;
    Key := 0;
  end;
end;

procedure TfrxObjectInspector.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    if paDialog in GetType(ItemIndex) then
      EditBtnClick(nil)
    else
    begin
      if Edit1.Modified then
        SetValue(ItemIndex, Edit1.Text);
      Edit1.Modified := False;
    end;
    Edit1.SelectAll;
    Key := #0;
  end;
end;


{ EditBtn and ComboBtn events }

procedure TfrxObjectInspector.EditBtnClick(Sender: TObject);
begin
  if GetItem(ItemIndex).Editor.Edit then
  begin
    ItemIndex := FItemIndex;
    DoModify;
  end;
end;

procedure TfrxObjectInspector.ComboBtnMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FPopupLBVisible := GetTickCount - frxPopupFormCloseTime < 100;
end;

procedure TfrxObjectInspector.ComboBtnClick(Sender: TObject);
var
  i, wItems, nItems: Integer;
  p: TPoint;
begin
  if FPopupLBVisible then
    Edit1.SetFocus
  else
  begin
    FPopupForm := TfrxPopupForm.Create(Self);
    FPopupLB := TListBox.Create(FPopupForm);
    with FPopupLB do
    begin
      Parent := FPopupForm;
      Ctl3D := False;
      Align := alClient;
      if paOwnerDraw in GetItem(FItemIndex).Editor.GetAttributes then
        Style := lbOwnerDrawFixed;
      ItemHeight := FRowHeight;
      OnClick := LBClick;
      OnDrawItem := GetItem(FItemIndex).Editor.OnDrawLBItem;
      GetItem(FItemIndex).Editor.GetValues;
      Items.Assign(GetItem(FItemIndex).Editor.Values);

      if Items.Count > 0 then
      begin
        ItemIndex := Items.IndexOf(GetValue(FItemIndex));
        wItems := 0;
        for i := 0 to Items.Count - 1 do
        begin
          if Canvas.TextWidth(Items[i]) > wItems then
            wItems := Canvas.TextWidth(Items[i]);
        end;

        Inc(wItems, 8);
        if paOwnerDraw in GetItem(FItemIndex).Editor.GetAttributes then
          Inc(wItems, GetItem(FItemIndex).Editor.GetExtraLBSize);
        nItems := Items.Count;
        if nItems > 8 then
        begin
          nItems := 8;
          Inc(wItems, GetSystemMetrics(SM_CXVSCROLL));
        end;

        p := Edit1.ClientToScreen(Point(0, Edit1.Height));

        if wItems < PB.Width - FSplitterPos then
          FPopupForm.SetBounds(p.X - 3, p.Y,
                             PB.Width - FSplitterPos + 1, nItems * ItemHeight + 2)
        else
          FPopupForm.SetBounds(p.X + (PB.Width - FSplitterPos - wItems) - 2, p.Y,
                             wItems, nItems * ItemHeight + 2);
        if FPopupForm.Left < 0 then
          FPopupForm.Left := 0;
        if FPopupForm.Top + FPopupForm.Height > Screen.Height then
          FPopupForm.Top := Screen.Height - FPopupForm.Height;
        FDisableUpdate := True;
        FPopupForm.Show;
        FDisableUpdate := False;
      end;
    end;
  end;
end;

procedure TfrxObjectInspector.LBClick(Sender: TObject);
begin
  Edit1.Text := FPopupLB.Items[FPopupLB.ItemIndex];
  FPopupForm.Hide;
  Edit1.SetFocus;
  Edit1.SelectAll;
  SetValue(ItemIndex, Edit1.Text);
end;


{ ObjectsCB events }

procedure TfrxObjectInspector.ObjectsCBClick(Sender: TObject);
begin
  if FUpdatingObjectsCB then Exit;

  FSelectedObjects.Clear;
  if ObjectsCB.ItemIndex <> -1 then
    FSelectedObjects.Add(ObjectsCB.Items.Objects[ObjectsCB.ItemIndex]);
  SetSelectedObjects(FSelectedObjects);
  Edit1.SetFocus;
  if Assigned(FOnSelectionChanged) then
    FOnSelectionChanged(Self);
end;

procedure TfrxObjectInspector.ObjectsCBDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  if FDisableUpdate then exit;
  with ObjectsCB.Canvas do
  begin
    FillRect(Rect);
    if Index <> -1 then
      TextOut(Rect.Left + 2, Rect.Top + 1, ObjectsCB.Items[Index]);
  end;
end;


{ Mouse wheel }

procedure TfrxObjectInspector.FormMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  with Box.VertScrollBar do
    Position := Position + FRowHeight;
end;

procedure TfrxObjectInspector.FormMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  with Box.VertScrollBar do
    Position := Position - FRowHeight;
end;

procedure TfrxObjectInspector.CMMouseLeave(var Msg: TMessage);
begin
  FHintWindow.ReleaseHandle;
  inherited;
end;


end.


//0f31356a91fea3356e5f76cdce90aa7b