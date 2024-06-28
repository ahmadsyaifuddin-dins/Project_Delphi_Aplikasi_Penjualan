
{******************************************}
{                                          }
{             FastReport v4.0              }
{        Text advanced  export filter      }
{                                          }
{         Copyright (c) 1998-2006          }
{          by Alexander Fediachov,         }
{             Fast Reports Inc.            }
{                                          }
{******************************************}

unit frxExportTXT;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, frxClass, frxProgress, Buttons, ComCtrls
{$IFDEF Delphi6}
, Variants
{$ENDIF};

type
  TfrxTXTExport = class;

  TfrxTXTExportDialog = class(TForm)
    OK: TButton;
    Cancel: TButton;
    Panel1: TPanel;
    GroupCellProp: TGroupBox;
    GroupPageRange: TGroupBox;
    Pages: TLabel;
    Descr: TLabel;
    E_Range: TEdit;
    GroupScaleSettings: TGroupBox;
    ScX: TLabel;
    Label2: TLabel;
    ScY: TLabel;
    Label9: TLabel;
    E_ScaleX: TEdit;
    CB_PageBreaks: TCheckBox;
    GroupFramesSettings: TGroupBox;
    RB_NoneFrames: TRadioButton;
    RB_Simple: TRadioButton;
    RB_Graph: TRadioButton;
    CB_OEM: TCheckBox;
    CB_EmptyLines: TCheckBox;
    CB_LeadSpaces: TCheckBox;
    CB_PrintAfter: TCheckBox;
    Panel2: TPanel;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label3: TLabel;
    PgHeight: TLabel;
    PgWidth: TLabel;
    Preview: TMemo;
    EPage: TEdit;
    PageUpDown: TUpDown;
    LBPage: TLabel;
    ToolButton1: TSpeedButton;
    ToolButton2: TSpeedButton;
    BtnPreview: TSpeedButton;
    SaveDialog1: TSaveDialog;
    UpDown1: TUpDown;
    UpDown2: TUpDown;
    E_ScaleY: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure CB_OEMClick(Sender: TObject);
    procedure RefreshClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure E_ScaleXChange(Sender: TObject);
    procedure BtnPreviewClick(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure UpDown1Changing(Sender: TObject; var AllowChange: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    TxtExp: TfrxTXTExport;
    Flag, created, MakeInit, running: Boolean;
    printer: Integer;
  public
    PagesCount: Integer;
    Exporter: TfrxTXTExport;
    PreviewActive: Boolean;
  end;

  PfrxTXTStyle = ^TfrxTXTStyle;
  TfrxTXTStyle = packed record
    Font: TFont;
    VAlignment: TfrxVAlign;
    HAlignment: TfrxHAlign;
    FrameTyp: TfrxFrameTypes;
    FrameWidth: Single;
    FrameColor: TColor;
    FrameStyle: TfrxFrameStyle;
    FillColor: TColor;
    IsText: Boolean;
  end;

  TfrxTXTPrinterCommand = packed record
    Name: String;
    SwitchOn: String;
    SwitchOff: String;
    Trigger: Boolean;
  end;

  TfrxTXTPrinterType = packed record
    name: String;
    CommCount: Integer;
    Commands: array[0..31] of TfrxTXTPrinterCommand;
  end;

  TfrxTXTExport = class(TfrxCustomExportFilter)
  private
    CurrentPage: Integer;
    FirstPage: Boolean;
    CurY: Integer;
    RX: TList; // TObjCell
    RY: TList; // TObjCell
    ObjectPos: TList; // TObjPos
    PageObj: TList; // TfrxView
    StyleList: TList;
    CY, LastY: Extended;
    frExportSet: TfrxTXTExportDialog;
    pgBreakList: TStringList;
    expBorders, expBordersGraph, expPrintAfter, expUseSavedProps,
      expPrinterDialog, expPageBreaks, expOEM, expEmptyLines,
      expLeadSpaces: Boolean;
    expCustomFrameSet: String;
    expScaleX, expScaleY: Extended;
    MaxWidth: Extended;
    Scr: array of Char;
    ScrWidth: Integer;
    ScrHeight: Integer;
    PrinterInitString: String;
    Stream: TFileStream;
    procedure WriteExpLn(const str: String);
    procedure WriteExp(const str: String);
    procedure ObjCellAdd(Vector: TList; Value: Extended);
    procedure ObjPosAdd(Vector: TList; x, y, dx, dy, obj: Integer);
    function CompareStyles(Style1, Style2: PfrxTXTStyle): Boolean;
    function FindStyle(Style: PfrxTXTStyle): Integer;
    procedure MakeStyleList;
    procedure ClearLastPage;
    procedure OrderObjectByCells;
    procedure ExportPage;
    function ChangeReturns(const Str: String): String;
    function TruncReturns(const Str: String): String;
    procedure AfterExport(const FileName: String);
    procedure PrepareExportPage;
    procedure DrawMemo(x, y: Integer; dx, dy: Integer; text: String; st: Integer);
    procedure FlushScr;
    procedure CreateScr(dx, dy: Integer);
    procedure FreeScr;
    procedure ScrType(x, y: Integer; c: Char);
    function ScrGet(x, y: Integer): Char;
    procedure ScrString(x, y: Integer; const s: String);
    procedure FormFeed;
    function MakeInitString: String;
  public
    PrintersCount: Integer;
    PrinterTypes: array [0..15] of TfrxTXTPrinterType;
    SelectedPrinterType: Integer;
    PageWidth, PageHeight: Integer;
    IsPreview: Boolean;
    Copys: Integer;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ShowModal: TModalResult; override;
    function Start: Boolean; override;
    procedure Finish; override;
    procedure FinishPage(Page: TfrxReportPage; Index: Integer); override;
    procedure StartPage(Page: TfrxReportPage; Index: Integer); override;
    procedure ExportObject(Obj: TfrxComponent); override;
    class function GetDescription: String; override;
    function RegisterPrinterType(const Name: String):Integer;
    procedure RegisterPrinterCommand(PrinterIndex: Integer;
      const Name, switch_on, switch_off: String);
    procedure LoadPrinterInit(const FName: String);
    procedure SavePrinterInit(const FName: String);
    procedure SpoolFile(const FileName: String);
  published
    property ScaleWidth: Extended read expScaleX write expScaleX;
    property ScaleHeight: Extended read expScaleY write expScaleY;
    property Borders: Boolean read expBorders write expBorders;
    property Pseudogrpahic: Boolean read expBordersGraph write expBordersGraph;
    property PageBreaks: Boolean read expPageBreaks write expPageBreaks;
    property OEMCodepage: Boolean read expOEM write expOEM;
    property EmptyLines: Boolean read expEmptyLines write expEmptyLines;
    property LeadSpaces: Boolean read expLeadSpaces write expLeadSpaces;
    property PrintAfter: Boolean read expPrintAfter write expPrintAfter;
    property PrinterDialog: Boolean read expPrinterDialog write expPrinterDialog;
    property UseSavedProps: Boolean read expUseSavedProps write expUseSavedProps;
    property InitString: String read PrinterInitString write PrinterInitString;
    property CustomFrameSet: String read expCustomFrameSet write expCustomFrameSet;
  end;

implementation

uses frxUtils, frxprinter, Printers, Winspool, frxExportTxtPrn,
     frxFileUtils, frxres, frxrcExports;

{$R *.dfm}

type
  PObjCell = ^TObjCell;
  TObjCell = packed record
    Value: Extended;
    Count: Integer;
  end;

  PObjPos = ^TObjPos;
  TObjPos = packed record
    obj: Integer;
    x,y: Integer;
    dx, dy: Integer;
    style: Integer;
  end;

const
  Xdivider = 7;
  Ydivider = 8;
  FrameSet: array [1..2] of String = (
// frameset: vertical, horizontal, up-left corner, up-right corner
//           down-left corner, down-right corner, down tap, left tap,
//           up tap, right tap,  cross
  '|-+++++++++',
  #179#196#218#191#192#217#193#195#194#180#197 );
  EpsonCommCnt = 12;
  Epson: array [0..EpsonCommCnt - 1, 0..2] of String = (
   ('Reset', #27#64, ''),
   ('Normal', #27#120#00, ''),
   ('Pica', #27#120#01#27#107#00, ''),
   ('Elite', #27#120#01#27#107#01, ''),
   ('Condensed', #15, #18),
   ('Bold', #27#71, #27#72),
   ('Italic', #27#52, #27#53),
   ('Wide', #27#87#01, #27#87#00),
   ('12cpi', #27#77, #27#80),
   ('Linefeed 1/8"', #27#48, ''),
   ('Linefeed 7/72"', #27#49, ''),
   ('Linefeed 1/6"', #27#50, ''));
  HPCommCnt = 6;
  HPComm: array [0..HPCommCnt - 1, 0..2] of String = (
   ('Reset', #27#69, ''),
   ('Landscape orientation', #27#38#108#49#79, #27#38#108#48#79),
   ('Italic', #27#40#115#49#83, #27#40#115#48#83),
   ('Bold', #27#40#115#51#66, #27#40#115#48#66),
   ('Draft EconoMode', #27#40#115#49#81, #27#40#115#50#81),
   ('Condenced', #27#40#115#49#50#72#27#38#108#56#68, #27#40#115#49#48#72));
  IBMCommCnt = 8;
  IBMComm: array [0..IBMCommCnt - 1, 0..2] of String = (
   ('Reset', #27#64, ''),
   ('Normal', #27#120#00, ''),
   ('Pica', #27#48#73, ''),
   ('Elite', #27#56#73, ''),
   ('Condensed', #15, #18),
   ('Bold', #27#71, #27#72),
   ('Italic', #27#52, #27#53),
   ('12cpi', #27#77, #27#80));

function ComparePoints(Item1, Item2: Pointer): Integer;
begin
  if PObjCell(Item1).Value > PObjCell(Item2).Value then
    Result := 1
  else if PObjCell(Item1).Value < PObjCell(Item2).Value then
    Result := -1
  else
    Result := 0;
end;

function CompareObjects(Item1, Item2: Pointer): Integer;
var
  m1, m2:  TfrxView;
  Res: Extended;
begin
  m1 := TfrxView(Item1);
  m2 := TfrxView(Item2);
  Res := m1.Top - m2.Top;
  if Res = 0 then
    Res := m1.Left - m2.Left;
  if Res = 0 then
    if (m1 is TfrxCustomMemoView) and (m2 is TfrxCustomMemoView) then
      Res := Length(TfrxMemoView(m1).Memo.Text) - Length(TfrxMemoView(m2).Memo.Text);
  if Res > 0 then
    Result := 1
  else if Res < 0 then
    Result := -1
  else
    Result := 0;
end;

class function TfrxTXTExport.GetDescription: String;
begin
  Result := frxResources.Get('TextExport');
end;

constructor TfrxTXTExport.Create(AOwner: TComponent);
var
  i: Integer;
begin
  inherited Create(AOwner);
  RX := TList.Create;
  RY := TList.Create;
  PageObj := TList.Create;
  ObjectPos := TList.Create;
  StyleList := TList.Create;
  pgBreakList := TStringList.Create;
  ShowDialog := True;
  expBorders := False;
  expPageBreaks := True;
  expScaleX := 1.0;
  expScaleY := 1.0;
  expBordersGraph := False;
  expOEM := False;
  expEmptyLines := False;
  expLeadSpaces := False;
  PrinterInitString := '';
  PageWidth := 0;
  PageHeight := 0;
  IsPreview := False;
  expPrintAfter := False;
  expUseSavedProps := True;
  expPrinterDialog := True;
  PrintersCount := 0;
  SelectedPrinterType := 0;
  expCustomFrameSet := '';
  Copys := 1;
  /// printer registration
  RegisterPrinterType('NONE');
  RegisterPrinterType('EPSON ESC/P2 Matrix/Stylus)');
  for i := 0 to EpsonCommCnt - 1 do
    RegisterPrinterCommand(1, Epson[i, 0], Epson[i, 1], Epson[i, 2]);
  RegisterPrinterType('HP PCL (LaserJet/DeskJet)');
  for i := 0 to HPCommCnt - 1 do
    RegisterPrinterCommand(2, HPComm[i, 0], HPComm[i, 1], HPComm[i, 2]);
  RegisterPrinterType('CANON/IBM (Matrix)');
  for i := 0 to IBMCommCnt - 1 do
    RegisterPrinterCommand(3, IBMComm[i, 0], IBMComm[i, 1], IBMComm[i, 2]);
end;

destructor TfrxTXTExport.Destroy;
begin
  ClearLastPage;
  RX.Free;
  RY.Free;
  PageObj.Free;
  ObjectPos.Free;
  StyleList.Free;
  pgBreakList.Free;
  inherited;
end;

function TfrxTXTExport.TruncReturns(const Str: String): String;
begin
  Result := StringReplace(Str, #1, '', [rfReplaceAll]);
  if Copy(Result, Length(Result) - 1, 2) = #13#10 then
    Delete(Result, Length(Result) - 1, 2);
end;

function TfrxTXTExport.ChangeReturns(const Str: String): String;
begin
  Result := StringReplace(Str, #1, '', [rfReplaceAll]);
end;

procedure TfrxTXTExport.ClearLastPage;
var
  i: Integer;
begin
  PageObj.Clear;
  for i := 0 to StyleList.Count - 1 do
  begin
    PfrxTXTStyle(StyleList[i]).Font.Free;
    FreeMemory(PfrxTXTStyle(StyleList[i]));
  end;
  StyleList.Clear;
  for i := 0 to RX.Count - 1 do FreeMem(PObjCell(RX[i]));
  RX.Clear;
  for i := 0 to RY.Count - 1 do FreeMem(PObjCell(RY[i]));
  RY.Clear;
  for i := 0 to ObjectPos.Count - 1 do FreeMem(PObjPos(ObjectPos[i]));
  ObjectPos.Clear;
end;

procedure TfrxTXTExport.ObjCellAdd(Vector: TList; Value: Extended);
var
   ObjCell: PObjCell;
   i, cnt: Integer;
   exist: Boolean;
begin
   exist := False;
   if Vector.Count > 0 then
   begin
     if Vector.Count > 100 then
       cnt := Vector.Count - 100 else
       cnt := 0;
     for i := Vector.Count - 1 downto cnt do
       if Round(PObjCell(Vector[i]).Value) = Round(Value) then
       begin
         exist := True;
         break;
       end;
   end;
   if not exist then
   begin
     GetMem(ObjCell, SizeOf(TObjCell));
     ObjCell.Value := Value;
     ObjCell.Count := 0;
     Vector.Add(ObjCell);
   end;
end;

procedure TfrxTXTExport.ObjPosAdd(Vector: TList; x, y, dx, dy, obj: Integer);
var
  ObjPos: PObjPos;
begin
  GetMem(ObjPos, SizeOf(TObjPos));
  ObjPos.x := x;
  ObjPos.y := y;
  ObjPos.dx := dx;
  ObjPos.dy := dy;
  ObjPos.obj := Obj;
  Vector.Add(ObjPos);
end;

procedure TfrxTXTExport.OrderObjectByCells;
var
   obj, c, fx, fy, dx, dy, mi: integer;
   m, curx, cury: Extended;
begin
   for obj := 0 to PageObj.Count - 1 do
   begin
     fx := 0; fy := 0;
     dx := 1; dy := 1;
     for c := 0 to RX.Count - 1 do
       if Round(PObjCell(RX[c]).Value) = Round(TfrxView(PageObj[obj]).Left) then
       begin
          fx := c;
          m := TfrxView(PageObj[obj]).Left;
          mi := c + 1;
          curx := TfrxView(PageObj[obj]).Left + TfrxView(PageObj[obj]).Width;
          while Round(m) < Round(curx) do
          begin
            m := m + PObjCell(RX[mi]).Value - PObjCell(RX[mi - 1]).Value;
            inc(mi);
          end;
          dx := mi - c - 1;
          break;
       end;
     for c := 0 to RY.Count - 1 do
       if Round(PObjCell(RY[c]).Value) = Round(TfrxView(PageObj[obj]).Top) then
       begin
          fy := c;
          m := TfrxView(PageObj[obj]).Top;
          mi := c + 1;
          cury := TfrxView(PageObj[obj]).Top + TfrxView(PageObj[obj]).Height;
          while Round(m) < Round(cury) do
          begin
            m := m + PObjCell(RY[mi]).Value - PObjCell(RY[mi - 1]).Value;
            inc(mi);
          end;
          dy := mi - c - 1;
          break;
       end;
     ObjPosAdd(ObjectPos, fx, fy, dx, dy, obj);
   end;
end;

function TfrxTXTExport.CompareStyles(Style1, Style2: PfrxTXTStyle): Boolean;
begin
  if Style1.IsText and Style2.IsText then
  begin
    Result := (Style1.Font.Color = Style2.Font.Color) and
      (Style1.Font.Name = Style2.Font.Name) and
      (Style1.Font.Size = Style2.Font.Size) and
      (Style1.Font.Style = Style2.Font.Style) and
      (Style1.Font.Charset = Style2.Font.Charset) and
      (Style1.VAlignment = Style2.VAlignment) and
      (Style1.HAlignment = Style2.HAlignment) and
      (Style1.FrameTyp = Style2.FrameTyp) and
      (Style1.FrameWidth = Style2.FrameWidth) and
      (Style1.FrameColor = Style2.FrameColor) and
      (Style1.FrameStyle = Style2.FrameStyle) and
      (Style1.FillColor = Style2.FillColor);
  end
  else if (not Style1.IsText) and (not Style2.IsText) then
  begin
    Result := (Style1.VAlignment = Style2.VAlignment) and
      (Style1.HAlignment = Style2.HAlignment) and
      (Style1.FrameTyp = Style2.FrameTyp) and
      (Style1.FrameWidth = Style2.FrameWidth) and
      (Style1.FrameColor = Style2.FrameColor) and
      (Style1.FrameStyle = Style2.FrameStyle) and
      (Style1.FillColor = Style2.FillColor);
  end
  else
    Result := False;
end;

function TfrxTXTExport.FindStyle(Style: PfrxTXTStyle): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to StyleList.Count - 1 do
    if CompareStyles(Style, PfrxTXTStyle(StyleList[i])) then
      Result := i;
end;

procedure TfrxTXTExport.MakeStyleList;
var
  i, j, k: Integer;
  obj: TfrxView;
  style: PfrxTXTStyle;
begin
  j := 0;
  for i := 0 to ObjectPos.Count - 1 do
  begin
    obj := PageObj[PObjPos(ObjectPos[i]).obj];
    style := AllocMem(SizeOf(TfrxTXTStyle));
    if obj is TfrxCustomMemoView then
    begin
      style.Font := TFont.Create;
      style.Font.Assign(TfrxMemoView(obj).Font);
      style.VAlignment := TfrxMemoView(obj).VAlign;
      style.HAlignment := TfrxMemoView(obj).HAlign;
      style.IsText := True;
    end
    else
    begin
      style.Font := nil;
      style.IsText := False;
    end;
    style.FrameTyp := obj.Frame.Typ;
    style.FrameWidth := obj.Frame.Width;
    style.FrameColor := obj.Frame.Color;
    style.FrameStyle := obj.Frame.Style;
    style.FillColor := obj.Color;
    k := FindStyle(Style);
    if k = -1 then
    begin
      StyleList.Add(style);
      PObjPos(ObjectPos[i]).style := j;
      j := j + 1;
    end
    else
    begin
      PObjPos(ObjectPos[i]).style := k;
      Style.Font.Free;
      FreeMemory(Style);
    end;
  end;
end;

function StrToOem(const AnsiStr: String): String;
begin
  SetLength(Result, Length(AnsiStr));
  if Length(Result) > 0 then
    CharToOemBuff(PChar(AnsiStr), PChar(Result), Length(Result));
end;

function MakeStr(C: Char; N: Integer): String;
begin
  if N < 1 then
    Result := ''
  else
  begin
    SetLength(Result, N);
    FillChar(Result[1], Length(Result), C);
  end;
end;

function AddChar(C: Char; const S: String; N: Integer): String;
begin
  if Length(S) < N then
    Result := MakeStr(C, N - Length(S)) + S else
    Result := S;
end;

function AddCharR(C: Char; const S: String; N: Integer): String;
begin
  if Length(S) < N then
    Result := S + MakeStr(C, N - Length(S)) else
    Result := S;
end;

function LeftStr(const S: String; N: Integer): String;
begin
  Result := AddCharR(' ', S, N);
end;

function RightStr(const S: String; N: Integer): String;
begin
  Result := AddChar(' ', S, N);
end;

function CenterStr(const S: String; Len: Integer): String;
begin
  if Length(S) < Len then
  begin
    Result := MakeStr(' ', (Len div 2) - (Length(S) div 2)) + S;
    Result := Result + MakeStr(' ', Len - Length(Result));
  end
  else
    Result := S;
end;

const
  Delims = [' ', #9, '-'];

function WrapTxt(s: String; dx, dy: Integer): String;
var
  i, j, k: Integer;
  buf1, buf2: String;
begin
  i := 0;
  buf2 := s;
  Result := '';
  while (i < dy) and (Length(Buf2) > 0) do
  begin
    if Length(buf2) > dx then
    begin
      if buf2[dx + 1] = #10 then
        buf1 := copy(buf2, 1, dx + 1)
      else if buf2[dx + 1] = #13 then
        buf1 := copy(buf2, 1, dx + 2)
      else
        buf1 := copy(buf2, 1, dx)
    end
    else
    begin
      Result := Result + buf2;
      break;
    end;
    k := Pos(#13#10, buf1);
    if k > 0 then
      j := k + 1
    else if Length(Buf1) < dx  then
    begin
      j := Length(Buf1);
      k := 1;
    end
    else
      j := dx;
    if (not (buf2[dx + 1] in Delims)) or (k > 0) then
    begin
      if k = 0 then
        while (j > 0) and (not (buf1[j] in Delims)) do
          Dec(j);
      if j > 0 then
      begin
        buf1 := copy(buf1, 1, j);
        buf2 := copy(buf2, j + 1, Length(buf2) - j)
      end
      else
        buf2 := copy(buf2, dx + 1, Length(buf2) - dx);
    end
    else
      buf2 := copy(buf2, dx + 2, Length(buf2) - dx - 1);
    i := i + 1;
    Result := Result + buf1;
    if k = 0 then
      Result := Result + #13#10;
  end;
end;

procedure TfrxTXTExport.WriteExpLn(const str: String);
var
  ln: String;
begin
  if Length(str) > 0 then
  begin
    if Length(str) > PageWidth then
      PageWidth := Length(str);
    Inc(PageHeight);
    Stream.Write(str[1], Length(str));
    ln := #13#10;
    Stream.Write(ln[1], Length(ln));
  end
  else if expEmptyLines then
  begin
    ln := #13#10;
    Inc(PageHeight);
    Stream.Write(ln[1], Length(ln));
  end;
end;

procedure TfrxTXTExport.WriteExp(const str: String);
begin
  if Length(str) > 0 then
    Stream.Write(str[1], Length(str))
end;

procedure TfrxTXTExport.CreateScr(dx, dy: Integer);
var
  i, j: Integer;
begin
  ScrWidth := dx;
  ScrHeight := dy;
  Initialize(Scr);
  SetLength(Scr, ScrWidth * ScrHeight);
  for i := 0 to ScrHeight - 1 do
    for j := 0 to ScrWidth - 1 do
      Scr[i * ScrWidth + j] := ' ';
end;

procedure TfrxTXTExport.ScrString(x, y: Integer; const s: String);
var
  i: Integer;
begin
  for i := 0 to Length(s) - 1 do
    ScrType(x + i, y, s[i + 1]);
end;

function TfrxTXTExport.ScrGet(x, y: Integer): Char;
begin
 if (x < ScrWidth) and (y < ScrHeight) and
   (x >= 0) and (y >= 0) then
   Result := Scr[ScrWidth * y + x] else
   Result := ' ';
end;

procedure TfrxTXTExport.DrawMemo(x, y, dx, dy: Integer; text: String;
  st: Integer);
var
  i, sx, sy, lines: Integer;
  buf: String;
  style: PfrxTXTStyle;
  f: String;

  function AlignBuf: String;
  begin
    if (style.HAlignment = haLeft) then
      buf := LeftStr(buf, dx - 1)
    else if (style.HAlignment = haRight) then
      buf := RightStr(buf, dx - 1)
    else if (style.HAlignment = haCenter) then
      buf := CenterStr(buf, dx - 1)
    else
      buf := LeftStr(buf, dx - 1);
    if expOEM then
      buf := StrToOem(buf);
    Result := buf;
  end;

begin
  style := PfrxTXTStyle(StyleList[st]);
  if (Style.FrameTyp <> []) and expBorders then
  begin
    if Length(expCustomFrameSet) > 0 then
      f := CustomFrameSet
    else if expBordersGraph then
      f := FrameSet[2]
    else
      f := FrameSet[1];
    if (ScrGet(x + 1, y) in [f[1], f[3], f[4]]) then
    begin
      Inc(x);
      Dec(dx);
    end
    else if (ScrGet(x - 1, y) in [f[1], f[3], f[4]]) then
    begin
      Dec(x);
      Inc(dx);
    end;
    if (ftLeft in Style.FrameTyp) then
      for i := 0 to dy do
        if i = 0 then
          ScrType(x, y + i, f[3])
        else if i = dy then
          ScrType(x, y + i, f[5])
        else
          ScrType(x, y + i, f[1]);
    if (ftRight in Style.FrameTyp) then
      for i := 0 to dy do
        if i = 0 then
          ScrType(x + dx, y + i, f[4])
        else if i = dy then
          ScrType(x + dx, y + i, f[6])
        else
          ScrType(x + dx, y + i, f[1]);
    if (ftTop in Style.FrameTyp) then
      for i := 0 to dx do
        if i = 0 then
          ScrType(x + i, y, f[3])
        else if i = dx then
          ScrType(x + i, y, f[4])
        else
          ScrType(x + i, y, f[2]);
    if (ftBottom in Style.FrameTyp) then
      for i := 0 to dx do
        if i = 0 then
          ScrType(x + i, y + dy, f[5])
        else if i = dx then
          ScrType(x + i, y + dy, f[6])
        else
          ScrType(x + i, y + dy, f[2]);
  end;
  text := WrapTxt(text, dx - 1, dy - 1);
  text := StringReplace(text, #13#10, #13, [rfReplaceAll]);
  lines := 1;
  for i := 0 to Length(text) - 1 do
    if text[i + 1] = #13 then
      Inc(lines);
  sx := x;
  if (style.VAlignment = vaBottom) then
    sy := y + dy - lines - 1
  else if (style.VAlignment = vaCenter) then
    sy := y + (dy - lines - 1) div 2
  else
    sy := y;
  buf := '';
  for i := 0 to Length(text) - 1 do
    if text[i + 1] = #13 then
    begin
      Inc(sy);
      if sy > (y + dy) then
        break;
      ScrString(sx + 1, sy, AlignBuf);
      buf := '';
    end
    else
    begin
      buf := buf + text[i + 1];
    end;
  if buf <> '' then
    ScrString(sx + 1, sy + 1, AlignBuf);
end;

procedure TfrxTXTExport.FlushScr;
var
  i, j, cnt, maxcnt: Integer;
  buf: String;
  f: String;
  c: Char;

  function IsLine(c: Char): Boolean;
  begin
    Result := (c in [f[1], f[2]]);
  end;

  function IsConner(c: Char): Boolean;
  begin
    Result := (c in [f[3], f[4], f[5], f[6], f[7], f[8], f[9], f[10], f[11]]);
  end;

  function IsFrame(c: Char): Boolean;
  begin
    Result := IsLine(c) or IsConner(c);
  end;

  function FrameOpt(c: Char; x, y: Integer; f: String): Char;
  begin
    if (not IsLine(ScrGet(x - 1, y))) and
      (not IsLine(ScrGet(x + 1, y))) and
      (not IsLine(ScrGet(x, y - 1))) and
      (IsLine(ScrGet(x, y + 1))) then
      Result := f[1]
    else if (not IsLine(ScrGet(x - 1, y))) and
      (not IsLine(ScrGet(x + 1, y))) and
      (IsLine(ScrGet(x, y - 1))) and
      (not IsLine(ScrGet(x, y + 1))) then
      Result := f[1]
    else if (not IsLine(ScrGet(x - 1, y))) and
      (IsLine(ScrGet(x + 1, y))) and
      (not IsLine(ScrGet(x, y - 1))) and
      (not IsLine(ScrGet(x, y + 1))) then
      Result := f[2]
    else if (not IsLine(ScrGet(x + 1, y))) and
      (IsLine(ScrGet(x - 1, y))) and
      (not IsLine(ScrGet(x, y - 1))) and
      (not IsLine(ScrGet(x, y + 1))) then
      Result := f[2]
    else if (not IsFrame(ScrGet(x + 1, y))) and
      (not IsFrame(ScrGet(x - 1, y))) and
      (ScrGet(x, y + 1) = f[1]) and
      (ScrGet(x, y - 1) = f[1]) then
      Result := f[1]
    else if (ScrGet(x + 1, y) = f[2]) and
      (ScrGet(x - 1, y) = f[2]) and
      (not IsFrame(ScrGet(x, y + 1))) and
      (not IsFrame(ScrGet(x, y - 1))) then
      Result := f[2]
    else if (ScrGet(x + 1, y) = f[2]) and
      (ScrGet(x - 1, y) = f[2]) and
      (ScrGet(x, y + 1) = f[1]) and
      (ScrGet(x, y - 1) = f[1]) then
      Result := f[11]
    else if (ScrGet(x + 1, y) = f[2]) and
      (ScrGet(x - 1, y) = f[2]) and
      (ScrGet(x, y + 1) = f[1]) and
      (ScrGet(x, y - 1) <> f[1]) then
      Result := f[9]
    else if (ScrGet(x + 1, y) = f[2]) and
      (ScrGet(x - 1, y) = f[2]) and
      (ScrGet(x, y - 1) = f[1]) and
      (ScrGet(x, y + 1) <> f[1]) then
      Result := f[7]
    else if (ScrGet(x, y - 1) = f[1]) and
      (ScrGet(x, y + 1) = f[1]) and
      (ScrGet(x + 1, y) = f[2]) and
      (ScrGet(x - 1, y) <> f[2])then
      Result := f[8]
    else if (ScrGet(x, y - 1) = f[1]) and
      (ScrGet(x, y + 1) = f[1]) and
      (ScrGet(x - 1, y) = f[2]) and
      (ScrGet(x + 1, y) <> f[2])then
      Result := f[10]
    else if (ScrGet(x + 1, y) = f[2]) and
      (ScrGet(x - 1, y) <> f[2]) and
      (ScrGet(x, y + 1) = f[1]) and
      (ScrGet(x, y - 1) <> f[1]) then
      Result := f[3]
    else if (ScrGet(x + 1, y) = f[2]) and
      (ScrGet(x - 1, y) <> f[2]) and
      (ScrGet(x, y + 1) <> f[1]) and
      (ScrGet(x, y - 1) = f[1]) then
      Result := f[5]
    else if (ScrGet(x + 1, y) <> f[2]) and
      (ScrGet(x - 1, y) = f[2]) and
      (ScrGet(x, y + 1) <> f[1]) and
      (ScrGet(x, y - 1) = f[1]) then
      Result := f[6]
    else if (ScrGet(x + 1, y) <> f[2]) and
      (ScrGet(x - 1, y) = f[2]) and
      (ScrGet(x, y + 1) = f[1]) and
      (ScrGet(x, y - 1) <> f[1]) then
      Result := f[4]
    else
      Result := c;
  end;

begin
  if expBorders then
  begin
    if Length(expCustomFrameSet) > 0 then
      f := CustomFrameSet
    else if expBordersGraph then
      f := FrameSet[2]
    else
      f := FrameSet[1];
    for i := 0 to ScrHeight - 1 do
      for j := 0 to ScrWidth - 1 do
      begin
        c := Scr[i * ScrWidth + j];
        if IsConner(c) then
          Scr[i * ScrWidth + j] := FrameOpt(c, j, i, f);
      end;
  end;
  if not expLeadSpaces then
  begin
    maxcnt := 99999;
    for i := 0 to ScrHeight - 1 do
    begin
      cnt := 0;
      for j := 0 to ScrWidth - 1 do
        if (Scr[i * ScrWidth + j] = ' ') then
          Inc(cnt) else
          break;
      if cnt < maxcnt then
        maxcnt := cnt;
    end;
  end
  else
    maxcnt := 0;
  for i := 0 to ScrHeight - 1 do
  begin
    buf := '';
    for j := 0 to ScrWidth - 1 do
      buf := buf + Scr[i * ScrWidth + j];
    buf := TrimRight(buf);
    if (maxcnt > 0) then
      buf := Copy(buf, maxcnt + 1, Length(buf) - maxcnt);
    WriteExpLn(buf);
  end;
end;

procedure TfrxTXTExport.FreeScr;
begin
  Finalize(Scr);
  ScrHeight := 0;
  ScrWidth := 0;
end;

procedure TfrxTXTExport.ScrType(x,y: Integer; c: Char);
var
  i: Integer;
begin
  i := ScrWidth * y + x;
  if (not expOEM) and (c = #160) then
    c := ' ';
  Scr[i] := c;
end;

procedure TfrxTXTExport.ExportPage;
var
  i, x, y: Integer;
  s: String;
  obj: TfrxMemoView;
begin
  i := 0;
  CreateScr(Round(expScaleX * MaxWidth / Xdivider) + 10, Round(expScaleY * LastY / Ydivider) + 2);
  for y := 1 to RY.Count - 1 do
  begin
    for x := 1 to RX.Count - 1 do
      if i < ObjectPos.Count then
        if ((PObjPos(ObjectPos[i]).y + CurY + 1) = y) and
          ((PObjPos(ObjectPos[i]).x + 1) = x) then
        begin
          Obj := TfrxMemoView(PageObj[PObjPos(ObjectPos[i]).obj]);
          s := ChangeReturns(TruncReturns(Obj.Memo.Text));
          DrawMemo(Round(expScaleX * obj.Left / Xdivider),
            Round(expScaleY * obj.Top / Ydivider),
            Round(expScaleX * obj.Width / Xdivider),
            Round(expScaleY * obj.Height / Ydivider),
            s, PObjPos(ObjectPos[i]).style);
          Obj.Free;
          Inc(i);
        end;
  end;
  FlushScr;
  FreeScr;
end;


function TfrxTXTExport.ShowModal: TModalResult;
var
  preview: Boolean;
begin
  if ShowDialog then
  begin
    preview := False;
    frExportSet := TfrxTXTExportDialog.Create(nil);
    frExportSet.Exporter := Self;
    frExportSet.CB_PrintAfter.Visible := not SlaveExport;
    if SlaveExport then
      expPrintAfter := False;

    if FileName = '' then
      frExportSet.SaveDialog1.FileName := ChangeFileExt(ExtractFileName(Report.FileName), frExportSet.SaveDialog1.DefaultExt)
    else
      frExportSet.SaveDialog1.FileName := FileName;

    frExportSet.PreviewActive := false;
    frExportSet.RB_Graph.Checked := expBordersGraph;
    frExportSet.RB_NoneFrames.Checked := not expBorders;
    frExportSet.RB_Simple.Checked := expBorders and (not expBordersGraph);
    frExportSet.CB_PageBreaks.Checked := expPageBreaks;
    frExportSet.CB_OEM.Checked := expOEM;
    frExportSet.CB_EmptyLines.Checked := expEmptyLines;
    frExportSet.CB_LeadSpaces.Checked := expLeadSpaces;
    frExportSet.UpDown1.Position := StrToInt(IntToStr(Round(expScaleX * 100)));
    frExportSet.UpDown2.Position := StrToInt(IntToStr(Round(expScaleY * 100)));
    frExportSet.CB_PrintAfter.Checked := expPrintAfter;
    frExportSet.PreviewActive := preview;
    frExportSet.PagesCount := Report.PreviewPages.Count;
    Result := frExportSet.ShowModal;
    if Result = mrOk then
    begin
      PageNumbers := frExportSet.E_Range.Text;
      expBorders := not frExportSet.RB_NoneFrames.Checked;
      expBordersGraph := frExportSet.RB_Graph.Checked;
      expPageBreaks := frExportSet.CB_PageBreaks.Checked;
      expOEM := frExportSet.CB_OEM.Checked;
      expEmptyLines := frExportSet.CB_EmptyLines.Checked;
      expLeadSpaces := frExportSet.CB_LeadSpaces.Checked;
      expScaleX := StrToInt(frExportSet.E_ScaleX.Text) / 100;
      expScaleY := StrToInt(frExportSet.E_ScaleY.Text) / 100;
      expPrintAfter := frExportSet.CB_PrintAfter.Checked;
      if frExportSet.MakeInit then
      begin
        SelectedPrinterType := frExportSet.printer;
        MakeInitString;
      end;
      if DefaultPath <> '' then
        frExportSet.SaveDialog1.InitialDir := DefaultPath;
      if not SlaveExport then
      begin
        if frExportSet.SaveDialog1.Execute then
        begin
          FileName := frExportSet.SaveDialog1.Filename;
        end
        else
          Result := mrCancel;
      end
      else
        FileName := ChangeFileExt(GetTempFile, frExportSet.SaveDialog1.DefaultExt);
    end;
    frExportSet.Free;
  end
  else
    Result := mrOk;
end;

function TfrxTXTExport.Start: Boolean;
begin
  CurrentPage := 0;
  FirstPage := True;
  ClearLastPage;
  if not IsPreview then
    WriteExp(PrinterInitString);
  pgBreakList.Clear;
  if FileName <> '' then
  begin
    if (ExtractFilePath(FileName) = '') and (DefaultPath <> '') then
      FileName := DefaultPath + '\' + FileName;
    Stream := TFileStream.Create(FileName, fmCreate);
    Result := True
  end
  else
    Result := False;
end;

procedure TfrxTXTExport.StartPage(Page: TfrxReportPage; Index: Integer);
begin
  Inc(CurrentPage);
  MaxWidth := 0;
  LastY := 0;
  CY := 0;
  CurY := 0;
  PageWidth := 0;
  PageHeight := 0;
end;

procedure TfrxTXTExport.ExportObject(Obj: TfrxComponent);
var
  MemoView: TfrxMemoView;
  maxy: Extended;
begin
  if Obj is TfrxCustomMemoView then
  begin
    if ((TfrxMemoView(Obj).Memo.Count > 0) or (TfrxMemoView(Obj).Frame.Typ <> [])) then
    begin
      MemoView := TfrxMemoView.Create(nil);
      MemoView.Assign(Obj);
      MemoView.Left := Obj.AbsLeft;
      MemoView.Top := Obj.AbsTop + CY;
      MemoView.Width := Obj.Width;
      MemoView.Height := Obj.Height;
      MemoView.Font.Assign(Obj.Font); // added by Samuel Herzog
      PageObj.Add(MemoView);
      ObjCellAdd(RX, Obj.AbsLeft);
      ObjCellAdd(RX, Obj.AbsLeft + Obj.Width);
      ObjCellAdd(RY, Obj.AbsTop + CY);
      ObjCellAdd(RY, Obj.AbsTop + Obj.Height + CY);
    end;
  end;
  if Obj.AbsLeft + Obj.Width > MaxWidth then
    MaxWidth := Obj.AbsLeft + Obj.Width;
  maxy := Obj.AbsTop + Obj.Height + CY;
  if maxy > LastY then
    LastY := maxy;
end;

procedure TfrxTXTExport.FinishPage(Page: TfrxReportPage; Index: Integer);
begin
  PrepareExportPage;
  ExportPage;
  if expPageBreaks then
    FormFeed;
  ClearLastPage;
end;

procedure TfrxTXTExport.Finish;
begin
  if (not expPageBreaks) and (not IsPreview) then
    FormFeed;
  Stream.Free;
  AfterExport(FileName);
end;

procedure TfrxTXTExport.SpoolFile(const FileName: String);
const
  BUF_SIZE = 1024;
var
  f: TFileStream;
  buf: String;
  l: longint;
begin
  frxPrinters.Printer.Title := FileName;
  frxPrinters.Printer.BeginRAWDoc;
  f := TFileStream.Create(FileName, fmOpenRead);
  SetLength(buf, BUF_SIZE);
  l := BUF_SIZE;
  while l = BUF_SIZE do
  begin
    l := f.Read(buf[1], BUF_SIZE);
    SetLength(buf, l);
    frxPrinters.Printer.WriteRAWDoc(buf);
  end;
  f.Free;
  frxPrinters.Printer.EndRAWDoc;
  DeleteFile(FileName);
end;

function GetTempFName: String;
var
  Path: String[64];
  FileName: String[255];
begin
  Path[0] := Chr(GetTempPath(64, @Path[1]));
  GetTempFileName(@Path[1], PChar('fr'), 0, @FileName[1]);
  Result := StrPas(@FileName[1]);
end;

procedure TfrxTXTExport.AfterExport(const FileName: String);
var
  i: Integer;
  fname: String;
  f, ffrom: TFileStream;
begin
  if expPrintAfter then
  begin
    if Printer.Printers.Count = 0 then Exit;
    if expPrinterDialog  then
      with TfrxPrnInit.Create(Self) do
      begin
        i := ShowModal;
        if i = mrOk then
          Copys := UpDown1.Position;
        Free;
      end
    else
      i := mrOk;
    if i = mrOk then
    begin
      MakeInitString;
      fname := GetTempFName;
      f := TFileStream.Create(fname, fmCreate);
      ffrom := TFileStream.Create(FileName, fmOpenRead);
      f.Write(PrinterInitString[1], Length(PrinterInitString));
      f.CopyFrom(ffrom, 0);
      f.Free;
      ffrom.Free;
      f := TFileStream.Create(FileName, fmCreate);
      ffrom := TFileStream.Create(fname, fmOpenRead);
      f.CopyFrom(ffrom, 0);
      f.Free;
      ffrom.Free;
      DeleteFile(fname);
      for i := 1 to Copys do
        SpoolFile(FileName);
    end;
  end;
end;

procedure TfrxTXTExport.PrepareExportPage;
begin
  RX.Sort(@ComparePoints);
  RY.Sort(@ComparePoints);
  PageObj.Sort(@CompareObjects);
  OrderObjectByCells;
  MakeStyleList;
end;

function TfrxTXTExport.MakeInitString: String;
var
  i: Integer;
begin
  if PrintersCount > 0 then
  begin
    PrinterInitString := '';
    for i := 0 to PrinterTypes[SelectedPrinterType].CommCount - 1 do
      if PrinterTypes[SelectedPrinterType].Commands[i].Trigger then
        PrinterInitString := PrinterInitString +
           PrinterTypes[SelectedPrinterType].Commands[i].SwitchOn
      else
        PrinterInitString := PrinterInitString +
            PrinterTypes[SelectedPrinterType].Commands[i].SwitchOff;
  end;
end;

procedure TfrxTXTExport.RegisterPrinterCommand(PrinterIndex: Integer;
  const Name, switch_on, switch_off: String);
var
  i: Integer;
begin
  i := PrinterTypes[PrinterIndex].CommCount;
  PrinterTypes[PrinterIndex].Commands[i].Name := Name;
  PrinterTypes[PrinterIndex].Commands[i].SwitchOn := Switch_On;
  PrinterTypes[PrinterIndex].Commands[i].SwitchOff := Switch_Off;
  PrinterTypes[PrinterIndex].Commands[i].Trigger := False;
  Inc(PrinterTypes[PrinterIndex].CommCount);
end;

function TfrxTXTExport.RegisterPrinterType(const Name: String): Integer;
begin
  PrinterTypes[PrintersCount].Name := Name;
  PrinterTypes[PrintersCount].CommCount := 0;
  Inc(PrintersCount);
  Result := PrintersCount - 1;
end;

procedure TfrxTXTExport.LoadPrinterInit(const FName: String);
var
  f: TextFile;
  i: Integer;
  buf: String;
  b: Boolean;
begin
{$I-}
  AssignFile(f, FName);
  Reset(f);
  ReadLn(f, buf);
  SelectedPrinterType := StrToInt(buf);
  i := 0;
  while (not eof(f)) and (i < PrinterTypes[SelectedPrinterType].CommCount) do
  begin
    ReadLn(f, buf);
      if Pos('True', buf) > 0 then
        b := True
      else
        b := False;
      PrinterTypes[SelectedPrinterType].Commands[i].Trigger := b;
    Inc(i);
  end;
  MakeInitString;
{$I+}
end;

procedure TfrxTXTExport.SavePrinterInit(const FName: String);
var
  f: TextFile;
  i: Integer;
  s: String;
begin
{$I-}
  AssignFile(f, FName);
  Rewrite(f);
  WriteLn(f, IntToStr(SelectedPrinterType));
  for i := 0 to PrinterTypes[SelectedPrinterType].CommCount - 1 do
  begin
    if PrinterTypes[SelectedPrinterType].Commands[i].Trigger then
      s := 'True' else
      s := 'False';
    WriteLn(f, s);
  end;
  CloseFile(f);
{$I+}
end;

procedure TfrxTXTExport.FormFeed;
begin
  WriteExp(#12);
end;

//////////////////////////////////////////////

procedure TfrxTXTExportDialog.FormCreate(Sender: TObject);
begin
  Caption := frxGet(8300);
  OK.Caption := frxGet(1);
  Cancel.Caption := frxGet(2);
  BtnPreview.Hint := frxGet(8301);
  GroupCellProp.Caption := frxGet(8302);
  CB_PageBreaks.Caption := frxGet(8303);
  CB_OEM.Caption := frxGet(8304);
  CB_EmptyLines.Caption := frxGet(8305);
  CB_LeadSpaces.Caption := frxGet(8306);
  GroupPageRange.Caption := frxGet(7);
  Pages.Caption := frxGet(8307);
  Descr.Caption := frxGet(8308);
  GroupScaleSettings.Caption := frxGet(8309);
  ScX.Caption := frxGet(8310);
  ScY.Caption := frxGet(8311);
  GroupFramesSettings.Caption := frxGet(8312);
  RB_NoneFrames.Caption := frxGet(8313);
  RB_Simple.Caption := frxGet(8314);
  RB_Graph.Caption := frxGet(8315);
  RB_Graph.Hint := frxGet(8316);
  CB_PrintAfter.Caption := frxGet(8317);
  GroupBox1.Caption := frxGet(8319);
  Label1.Caption := frxGet(8320);
  Label3.Caption := frxGet(8321);
  LBPage.Caption := frxGet(8322);
  ToolButton1.Hint := frxGet(8323);
  ToolButton2.Hint := frxGet(8324);
  SaveDialog1.Filter := frxGet(8325);
  SaveDialog1.DefaultExt := frxGet(8326);

  created := False;
  TxtExp := TfrxTXTExport.CreateNoRegister;
  BtnPreviewClick(Sender);
  Created := True;
  MakeInit := False;
  printer := 0;
  PageUpDown.Max := PagesCount;
  running := False;
end;

procedure TfrxTXTExportDialog.CB_OEMClick(Sender: TObject);
begin
  RB_Graph.Enabled := CB_OEM.Checked;
  if not RB_Simple.Checked then
    RB_Simple.Checked := RB_Graph.Checked;
  E_ScaleXChange(Sender);
end;

procedure TfrxTXTExportDialog.RefreshClick(Sender: TObject);
var
  fname: String;
  Progr: Boolean;
begin
 if Flag then
 begin
   running := true;
   fname := GetTempFName;
   TxtExp.IsPreview := True;
   TxtExp.ShowDialog := False;
   TxtExp.Borders := not RB_NoneFrames.Checked;
   TxtExp.Pseudogrpahic := RB_Graph.Checked;
   TxtExp.PageBreaks := CB_PageBreaks.Checked;
   TxtExp.OEMCodepage := CB_OEM.Checked;
   TxtExp.EmptyLines := CB_EmptyLines.Checked;
   TxtExp.LeadSpaces := CB_LeadSpaces.Checked;
   TxtExp.ScaleWidth := StrToInt(E_ScaleX.Text) / 100;
   TxtExp.ScaleHeight := StrToInt(E_ScaleY.Text) / 100;
   progr := Exporter.ShowProgress;
   Exporter.ShowProgress := False;
   TxtExp.FileName := fname;
   TxtExp.PageNumbers := EPage.Text;
   Exporter.Report.Export(TxtExp);
   Exporter.ShowProgress := progr;
   if CB_OEM.Checked then
     Preview.Font.Name := 'Terminal' else
     Preview.Font.Name := 'Courier New';
   Preview.Lines.LoadFromFile(fname);
   DeleteFile(fname);
   PgWidth.Caption := IntToStr(TxtExp.PageWidth);
   PgHeight.Caption := IntToStr(TxtExp.PageHeight);
   running := false;
 end;
end;

procedure TfrxTXTExportDialog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  TxtExp.Free;
end;

procedure TfrxTXTExportDialog.FormActivate(Sender: TObject);
begin
{  CB_OEMClick(Sender);
  if PreviewActive then
    BtnPreview.Down := True;
  BtnPreviewClick(Sender);}
end;

procedure TfrxTXTExportDialog.E_ScaleXChange(Sender: TObject);
begin
  if PreviewActive then
    RefreshClick(Sender);
end;

procedure TfrxTXTExportDialog.BtnPreviewClick(Sender: TObject);
begin
  if BtnPreview.Down then
  begin
    PreviewActive := True;
    Left := Left - 177;
    Width := 631;
    Panel2.Visible := True;
    Flag := True;
    E_ScaleXChange(Sender);
  end
  else
  begin
    if created and PreviewActive then
      Left := Left + 177;
    Flag := False;
    PreviewActive := False;
    Width := 277;
    Panel2.Visible := False;
  end;
end;

procedure TfrxTXTExportDialog.ToolButton1Click(Sender: TObject);
begin
  if Preview.Font.Size < 30 then
   Preview.Font.Size := Preview.Font.Size + 1;
end;

procedure TfrxTXTExportDialog.ToolButton2Click(Sender: TObject);
begin
  if Preview.Font.Size > 2 then
   Preview.Font.Size := Preview.Font.Size - 1;
end;

procedure TfrxTXTExportDialog.UpDown1Changing(Sender: TObject;
  var AllowChange: Boolean);
begin
  if PreviewActive then
    if not running then
      RefreshClick(Sender)
    else
      AllowChange := False;
end;

procedure TfrxTXTExportDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

end.
