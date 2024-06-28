
{******************************************}
{                                          }
{             FastReport v4.0              }
{         Dot-matrix export filter         }
{                                          }
{         Copyright (c) 1998-2005          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxDMPExport;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, frxClass, Buttons, ComCtrls, frxDMPClass, frxXML
{$IFDEF Delphi6}
, Variants
{$ENDIF};

type
  TfrxTranslateEvent = procedure(Sender: TObject; var s: String) of object;

  TfrxDotMatrixExport = class(TfrxCustomExportFilter)
  private
    FBufWidth: Integer;
    FBufHeight: Integer;
    FCharBuf: array of Char;
    FCopies: Integer;
    FCustomFrameSet: String;
    FEscModel: Integer;
    FFrameBuf: array of Byte;
    FGraphicFrames: Boolean;
    FMaxHeight: Integer;
    FOEMConvert: Boolean;
    FPageBreaks: Boolean;
    FPageStyle: Integer;
    FPrinterInitString: String;
    FSaveToFile: Boolean;
    FStream: TStream;
    FStyleBuf: array of Integer;
    FUseIniSettings: Boolean;
    FOnTranslate: TfrxTranslateEvent;

    function GetTempFName: String;
    function IntToStyle(i: Integer): TfrxDMPFontStyles;
    function StyleChange(OldStyle, NewStyle: Integer): String;
    function StyleOff(Style: Integer): String;
    function StyleOn(Style: Integer): String;
    function StyleToInt(Style: TfrxDMPFontStyles): Integer;

    procedure CreateBuf(Width, Height: Integer);
    procedure DrawFrame(x, y, dx, dy: Integer; Style: Integer);
    procedure DrawMemo(x, y, dx, dy: Integer; Memo: TfrxDMPMemoView);
    procedure FlushBuf;
    procedure FormFeed;
    procedure FreeBuf;
    procedure Landscape;
    procedure Portrait;
    procedure Reset;
    procedure SetFrame(x, y: Integer; typ: Byte);
    procedure SetString(x, y: Integer; s: String);
    procedure SetStyle(x, y, Style: Integer);
    procedure SpoolFile(const FileName: String);
    procedure WriteStrLn(const str: String);
    procedure WriteStr(const str: String);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ShowModal: TModalResult; override;
    function Start: Boolean; override;
    procedure ExportObject(Obj: TfrxComponent); override;
    procedure Finish; override;
    procedure FinishPage(Page: TfrxReportPage; Index: Integer); override;
    procedure StartPage(Page: TfrxReportPage; Index: Integer); override;
  published
    property CustomFrameSet: String read FCustomFrameSet write FCustomFrameSet;
    property EscModel: Integer read FEscModel write FEscModel;
    property GraphicFrames: Boolean read FGraphicFrames write FGraphicFrames;
    property InitString: String read FPrinterInitString write FPrinterInitString;
    property OEMConvert: Boolean read FOEMConvert write FOEMConvert default True;
    property PageBreaks: Boolean read FPageBreaks write FPageBreaks default True;
    property SaveToFile: Boolean read FSaveToFile write FSaveToFile;
    property UseIniSettings: Boolean read FUseIniSettings write FUseIniSettings;
    property OnTranslate: TfrxTranslateEvent read FOnTranslate write FOnTranslate;
  end;

  TfrxDMPExportDialog = class(TForm)
    OK: TButton;
    Cancel: TButton;
    SaveDialog1: TSaveDialog;
    Image1: TImage;
    PrinterL: TGroupBox;
    PrinterCB: TComboBox;
    EscL: TGroupBox;
    EscCB: TComboBox;
    CopiesL: TGroupBox;
    CopiesNL: TLabel;
    CopiesE: TEdit;
    CopiesUD: TUpDown;
    PagesL: TGroupBox;
    DescrL: TLabel;
    AllRB: TRadioButton;
    CurPageRB: TRadioButton;
    PageNumbersRB: TRadioButton;
    RangeE: TEdit;
    OptionsL: TGroupBox;
    SaveToFileCB: TCheckBox;
    PageBreaksCB: TCheckBox;
    OemCB: TCheckBox;
    PseudoCB: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure PrinterCBDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure PrinterCBClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure RangeEEnter(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    OldIndex: Integer;
  end;

const
  cmdName = 1;
  cmdReset = 2;
  cmdFormFeed = 3;
  cmdLandscape = 4;
  cmdPortrait = 5;
  cmdBoldOn = 6;
  cmdBoldOff = 7;
  cmdItalicOn = 8;
  cmdItalicOff = 9;
  cmdUnderlineOn = 10;
  cmdUnderlineOff = 11;
  cmdSuperscriptOn = 12;
  cmdSuperscriptOff = 13;
  cmdSubscriptOn = 14;
  cmdSubscriptOff = 15;
  cmdCondensedOn = 16;
  cmdCondensedOff = 17;
  cmdWideOn = 18;
  cmdWideOff = 19;
  cmd12cpiOn = 20;
  cmd12cpiOff = 21;
  cmd15cpiOn = 22;
  cmd15cpiOff = 23;

  CommandCount = 23;
  CommandNames: array[1..CommandCount] of String = (
    'Name', 'Reset', 'FormFeed', 'Landscape', 'Portrait',
    'BoldOn', 'BoldOff', 'ItalicOn', 'ItalicOff', 'UnderlineOn', 'UnderlineOff',
    'SuperscriptOn', 'SuperscriptOff', 'SubscriptOn', 'SubscriptOff',
    'CondensedOn', 'CondensedOff', 'WideOn', 'WideOff',
    'cpi12On', 'cpi12Off', 'cpi15On', 'cpi15Off');

type
  TfrxDMPrinter = class(TCollectionItem)
  public
    Commands: array[1..CommandCount] of String;
    procedure Assign(Source: TPersistent); override;
  end;

  TfrxDMPrinters = class(TCollection)
  private
    function GetItem(Index: Integer): TfrxDMPrinter;
  public
    constructor Create;
    function Add: TfrxDMPrinter;
    procedure ReadDefaultPrinters;
    procedure ReadExtPrinters;
    procedure ReadPrinters(x: TfrxXMLDocument);
    property Items[Index: Integer]: TfrxDMPrinter read GetItem; default;
  end;

var
  frxDMPrinters: TfrxDMPrinters;


implementation

uses frxUtils, frxPrinter, Printers, frxRes, IniFiles, Winspool;

{$R *.dfm}

const
  FrameSet: array[1..2] of String = (
    '  + |++ +-+++++',
    #32#32#192#32#179#218#195#32#217#196#193#191#180#194#197);
  DefaultPrinters: String =
'<?xml version="1.0" encoding="utf-8"?>' +
'<printers>' +
'  <printer id="0" Name="None" FormFeed="0C"/>' +
'  <printer id="1" Name="Epson Generic" Inherit="0" Reset="1B40" ' +
'BoldOn="1B45" BoldOff="1B46" ItalicOn="1B34" ItalicOff="1B35" ' +
'UnderlineOn="1B2D01" UnderlineOff="1B2D00" SuperscriptOn="#27#83#01" SuperscriptOff="#27#84" ' +
'SubscriptOn="#27#83#00" SubscriptOff="#27#84" CondensedOn="0F" CondensedOff="12" ' +
'WideOn="1B5701" WideOff="1B5700" cpi12On="1B4D" cpi12Off="1B50" cpi15On="1B67" cpi15Off="1B50"/>' +
'  <printer id="2" Name="HP Generic" Inherit="0" Reset="1B45" ' +
'Portrait="1B266C304F" Landscape="1B266C314F" BoldOn="1B28733342" ' +
'BoldOff="1B28733042" ItalicOn="1B28733153" ItalicOff="1B28733053" ' +
'UnderlineOn="1B26643144" UnderlineOff="1B266440" ' +
'SuperscriptOn="#27#38#97#45#46#53#82" SuperscriptOff="#27#38#97#43#46#53#82" ' +
'SubscriptOn="#27#38#97#43#46#53#82" SubscriptOff="#27#38#97#45#46#53#82" ' +
'CondensedOn="1B2873313648" CondensedOff="1B2873313048" ' +
'WideOn="1B28733548" WideOff="1B2873313048" cpi12On="1B266B313048" ' +
'cpi12Off="1B266B313248" cpi15On="" cpi15Off=""/>' +
'  <printer id="3" Name="IBM Generic" Inherit="1" Reset="" cpi12On="1B3A" ' +
'cpi12Off="12" cpi15On="1B67" cpi15Off="12"/>' +
'</printers>';

type
  TWordSet = set of 0..15;
  PWordSet = ^TWordSet;
  PfrxDMPFontStyles = ^TfrxDMPFontStyles;


{ TfrxDMPrinter }

procedure TfrxDMPrinter.Assign(Source: TPersistent);
begin
  if Source is TfrxDMPrinter then
    Commands := TfrxDMPrinter(Source).Commands;
end;


{ TfrxDMPrinters }

constructor TfrxDMPrinters.Create;
begin
  inherited Create(TfrxDMPrinter);
end;

function TfrxDMPrinters.Add: TfrxDMPrinter;
begin
  Result := TfrxDMPrinter(inherited Add);
end;

function TfrxDMPrinters.GetItem(Index: Integer): TfrxDMPrinter;
begin
  Result := TfrxDMPrinter(inherited Items[Index]);
end;

procedure TfrxDMPrinters.ReadDefaultPrinters;
var
  x: TfrxXMLDocument;
  s: TStringStream;
begin
  x := TfrxXMLDocument.Create;
  s := TStringStream.Create(DefaultPrinters);
  try
    x.LoadFromStream(s);
    ReadPrinters(x);
  finally
    s.Free;
    x.Free;
  end;
end;

procedure TfrxDMPrinters.ReadExtPrinters;
var
  x: TfrxXMLDocument;
begin
  if not FileExists(ExtractFilePath(Application.ExeName) + 'printers.xml') then
    Exit;
  x := TfrxXMLDocument.Create;
  try
    x.LoadFromFile(ExtractFilePath(Application.ExeName) + 'printers.xml');
    ReadPrinters(x);
  except
    ShowMessage('Error in file printers.xml');
  end;

  x.Free;
end;

procedure TfrxDMPrinters.ReadPrinters(x: TfrxXMLDocument);
var
  i, j: Integer;
  xi: TfrxXMLItem;
  Item: TfrxDMPrinter;

  function ConvertProp(s: String): String;
  var
    i: Integer;
    s1: String;
  begin
    Result := '';
    s1 := '';
    if Pos('#', s) = 1 then
    begin
      s := s + '#';
      for i := 2 to Length(s) do
        if s[i] = '#' then
        begin
          Result := Result + Chr(StrToInt(s1));
          s1 := '';
        end
        else
          s1 := s1 + s[i];
    end
    else
    begin
      for i := 1 to Length(s) do
      begin
        s1 := s1 + s[i];
        if i mod 2 = 0 then
        begin
          Result := Result + Chr(StrToInt('$' + s1));
          s1 := '';
        end;
      end;
    end;
  end;

begin
  Clear;
  for i := 0 to x.Root.Count - 1 do
  begin
    Item := Add;
    xi := x.Root[i];
    if xi.Prop['Inherit'] <> '' then
      Item.Assign(Items[StrToInt(xi.Prop['Inherit'])]);
    for j := 1 to CommandCount do
      if xi.PropExists(CommandNames[j]) then
        if j = 1 then
          Item.Commands[j] := xi.Prop[CommandNames[j]] else
          Item.Commands[j] := ConvertProp(xi.Prop[CommandNames[j]]);
  end;
end;


{ TfrxDotMatrixExport }

constructor TfrxDotMatrixExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  frxDotMatrixExport := Self;
  FCopies := 1;
  FOEMConvert := True;
  FPageBreaks := True;
  FUseIniSettings := True;
end;

destructor TfrxDotMatrixExport.Destroy;
begin
  FreeBuf;
  frxDotMatrixExport := nil;
  inherited;
end;

function TfrxDotMatrixExport.GetTempFName: String;
var
  Path: String;
  FileName: String;
begin
  Path := Report.EngineOptions.TempDir;
  if Path = '' then
  begin
    SetLength(Path, MAX_PATH);
    SetLength(Path, GetTempPath(MAX_PATH, @Path[1]));
  end
  else
    Path := Path + #0;
  SetLength(FileName, MAX_PATH);
  GetTempFileName(@Path[1], PChar('fr'), 0, @FileName[1]);
  Result := StrPas(@FileName[1]);
end;

function TfrxDotMatrixExport.IntToStyle(i: Integer): TfrxDMPFontStyles;
begin
  Result := TfrxDMPFontStyles(PfrxDMPFontStyles(@i)^);
end;

function TfrxDotMatrixExport.StyleToInt(Style: TfrxDMPFontStyles): Integer;
begin
  Result := Word(PWordSet(@Style)^);
end;

procedure TfrxDotMatrixExport.SpoolFile(const FileName: String);
const
  BUF_SIZE = 1024;
var
  f: TFileStream;
  buf: String;
  l: longint;
begin
  if Report.ReportOptions.Name <> '' then
    frxPrinters.Printer.Title := Report.ReportOptions.Name else
    frxPrinters.Printer.Title := Report.FileName;
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
end;

procedure TfrxDotMatrixExport.FormFeed;
begin
  WriteStr(frxDMPrinters[FEscModel].Commands[cmdFormFeed]);
end;

procedure TfrxDotMatrixExport.Landscape;
begin
  WriteStr(frxDMPrinters[FEscModel].Commands[cmdLandscape]);
end;

procedure TfrxDotMatrixExport.Portrait;
begin
  WriteStr(frxDMPrinters[FEscModel].Commands[cmdPortrait]);
end;

procedure TfrxDotMatrixExport.Reset;
begin
  WriteStr(frxDMPrinters[FEscModel].Commands[cmdReset]);
end;

function TfrxDotMatrixExport.StyleOff(Style: Integer): String;
var
  st: TfrxDMPFontStyles;
begin
  st := IntToStyle(Style);
  Result := '';
  if fsxBold in st then
    Result := Result + frxDMPrinters[FEscModel].Commands[cmdBoldOff];
  if fsxItalic in st then
    Result := Result + frxDMPrinters[FEscModel].Commands[cmdItalicOff];
  if fsxUnderline in st then
    Result := Result + frxDMPrinters[FEscModel].Commands[cmdUnderlineOff];
  if fsxSuperScript in st then
    Result := Result + frxDMPrinters[FEscModel].Commands[cmdSuperscriptOff];
  if fsxSubScript in st then
    Result := Result + frxDMPrinters[FEscModel].Commands[cmdSubscriptOff];
  if fsxCondensed in st then
    Result := Result + frxDMPrinters[FEscModel].Commands[cmdCondensedOff];
  if fsxWide in st then
    Result := Result + frxDMPrinters[FEscModel].Commands[cmdWideOff];
  if fsx12cpi in st then
    Result := Result + frxDMPrinters[FEscModel].Commands[cmd12cpiOff];
  if fsx15cpi in st then
    Result := Result + frxDMPrinters[FEscModel].Commands[cmd15cpiOff];
end;

function TfrxDotMatrixExport.StyleOn(Style: Integer): String;
var
  st: TfrxDMPFontStyles;
begin
  st := IntToStyle(Style);
  Result := '';
  if fsxBold in st then
    Result := Result + frxDMPrinters[FEscModel].Commands[cmdBoldOn];
  if fsxItalic in st then
    Result := Result + frxDMPrinters[FEscModel].Commands[cmdItalicOn];
  if fsxUnderline in st then
    Result := Result + frxDMPrinters[FEscModel].Commands[cmdUnderlineOn];
  if fsxSuperScript in st then
    Result := Result + frxDMPrinters[FEscModel].Commands[cmdSuperscriptOn];
  if fsxSubScript in st then
    Result := Result + frxDMPrinters[FEscModel].Commands[cmdSubscriptOn];
  if fsxCondensed in st then
    Result := Result + frxDMPrinters[FEscModel].Commands[cmdCondensedOn];
  if fsxWide in st then
    Result := Result + frxDMPrinters[FEscModel].Commands[cmdWideOn];
  if fsx12cpi in st then
    Result := Result + frxDMPrinters[FEscModel].Commands[cmd12cpiOn];
  if fsx15cpi in st then
    Result := Result + frxDMPrinters[FEscModel].Commands[cmd15cpiOn];
end;

function TfrxDotMatrixExport.StyleChange(OldStyle, NewStyle: Integer): String;
begin
  Result := StyleOff(OldStyle) + StyleOn(NewStyle);
end;

procedure TfrxDotMatrixExport.SetFrame(x, y: Integer; typ: Byte);
begin
  if (x < 0) or (y < 0) or (x >= FBufWidth) or (y >= FBufHeight) then Exit;
  FFrameBuf[FBufWidth * y + x] := FFrameBuf[FBufWidth * y + x] or typ;
end;

procedure TfrxDotMatrixExport.SetString(x, y: Integer; s: String);
var
  i, j: Integer;
  c: Char;
begin
  if (x < 0) or (y < 0) or (y >= FBufHeight) then Exit;
  if Assigned(FOnTranslate) then
    FOnTranslate(Self, s);
  for i := 1 to Length(s) do
  begin
    if x + i - 1 >= FBufWidth then break;
    c := s[i];
    j := FBufWidth * y + x + i - 1;
    FCharBuf[j] := c;
  end;
end;

procedure TfrxDotMatrixExport.SetStyle(x, y, Style: Integer);
begin
  if (x < 0) or (y < 0) or (x >= FBufWidth) or (y >= FBufHeight) then Exit;
  FStyleBuf[FBufWidth * y + x] := Style;
end;

procedure TfrxDotMatrixExport.WriteStr(const str: String);
begin
  if Length(str) > 0 then
    FStream.Write(str[1], Length(str))
end;

procedure TfrxDotMatrixExport.WriteStrLn(const str: String);
begin
  WriteStr(str);
  WriteStr(#13#10);
end;

procedure TfrxDotMatrixExport.DrawFrame(x, y, dx, dy: Integer; Style: Integer);
var
  i, j: Integer;
begin
  if dx = 1 then
  begin
    SetFrame(x, y, 4);
    for i := y + 1 to y + dy - 2 do
      SetFrame(x, i, 5);
    SetFrame(x, y + dy - 1, 1);
  end
  else
  begin
    SetFrame(x, y, 2);
    for i := x + 1 to x + dx - 2 do
      SetFrame(i, y, 10);
    SetFrame(x + dx - 1, y, 8);
  end;

  for i := x to x + dx - 1 do
    for j := y to y + dy - 1 do
      SetStyle(i, j, Style);

  if y + dy > FMaxHeight then
    FMaxHeight := y + dy;
end;

procedure TfrxDotMatrixExport.DrawMemo(x, y, dx, dy: Integer; Memo: TfrxDMPMemoView);
var
  i, sx, sy: Integer;
  Lines: TStringList;
  Text: String;
  Style: Integer;

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

  function AlignBuf(const buf: String): String;
  begin
    if (Memo.HAlign = haLeft) then
      Result := LeftStr(buf, dx)
    else if (Memo.HAlign = haRight) then
      Result := RightStr(buf, dx)
    else if (Memo.HAlign = haCenter) then
      Result := CenterStr(buf, dx)
    else
      Result := LeftStr(buf, dx);
  end;

begin
  Lines := TStringList.Create;

  Text := Memo.WrapText(True);
  if FOEMConvert then
    Text := StrToOem(Text);
  Lines.Text := Text;

  if dy > Lines.Count then
  begin
    if (Memo.VAlign = vaBottom) then
      sy := y + dy - Lines.Count
    else if (Memo.VAlign = vaCenter) then
      sy := y + (dy - Lines.Count) div 2
    else
      sy := y
  end
  else
     sy := y;

  for i := 0 to Lines.Count - 1 do
  begin
    if i > dy - 1 then
      break;
    SetString(x, sy + i, AlignBuf(Lines[i]));
  end;
  Lines.Free;

  Style := StyleToInt(Memo.FontStyle);
  for sx := x to x + dx - 1 do
    for sy := y to y + dy - 1 do
      SetStyle(sx, sy, Style);

  if y + dy > FMaxHeight then
    FMaxHeight := y + dy;
end;

procedure TfrxDotMatrixExport.CreateBuf(Width, Height: Integer);
var
  i, j: Integer;
begin
  FBufWidth := Width;
  FBufHeight := Height;
  SetLength(FCharBuf, FBufWidth * FBufHeight);
  SetLength(FStyleBuf, FBufWidth * FBufHeight);
  SetLength(FFrameBuf, FBufWidth * FBufHeight);
  for i := 0 to FBufHeight - 1 do
    for j := 0 to FBufWidth - 1 do
    begin
      FCharBuf[i * FBufWidth + j] := ' ';
      FStyleBuf[i * FBufWidth + j] := FPageStyle;
      FFrameBuf[i * FBufWidth + j] := 0;
    end;
end;

procedure TfrxDotMatrixExport.FreeBuf;
begin
  FFrameBuf := nil;
  FStyleBuf := nil;
  FCharBuf := nil;
  FBufHeight := 0;
  FBufWidth := 0;
end;

procedure TfrxDotMatrixExport.FlushBuf;
var
  i, j, Style, CurrentStyle: Integer;
  buf: String;
  Frames: String;

  function Trim_Right(const s: String): String;
  var
    i: Integer;
  begin
    Result := s;
    for i := Length(Result) downto 1 do
      if Result[i] <> ' ' then
        break;
    SetLength(Result, i);
  end;

begin
  if Length(CustomFrameSet) = 15 then
    Frames := CustomFrameSet
  else if FGraphicFrames then
    Frames := FrameSet[2]
  else
    Frames := FrameSet[1];

  CurrentStyle := FPageStyle;
  for i := 0 to FMaxHeight - 1 do
  begin
    buf := StyleOn(CurrentStyle);
    for j := 0 to FBufWidth - 1 do
    begin
      Style := FStyleBuf[i * FBufWidth + j];
      if Style <> CurrentStyle then
      begin
        buf := buf + StyleChange(CurrentStyle, Style);
        CurrentStyle := Style;
      end;
      if FFrameBuf[i * FBufWidth + j] <> 0 then
        buf := buf + Frames[FFrameBuf[i * FBufWidth + j]] else
        buf := buf + FCharBuf[i * FBufWidth + j];
    end;
    buf := Trim_Right(buf) + StyleOff(CurrentStyle);
    WriteStrLn(buf);
  end;
end;


function TfrxDotMatrixExport.ShowModal: TModalResult;
var
  Ini: TCustomIniFile;
begin
  Ini := Report.GetIniFile;
  with TfrxDMPExportDialog.Create(nil) do
  begin
    if FUseIniSettings then
    begin
      FPageBreaks := Ini.ReadBool('DMP', 'PageBreaks', True);
      FOEMConvert := Ini.ReadBool('DMP', 'OEM', True);
      FGraphicFrames := Ini.ReadBool('DMP', 'GraphFrame', False);
      FEscModel := Ini.ReadInteger('DMP', 'PrinterType', 0);
    end;
    if FEscModel >= frxDMPrinters.Count then
      FEscModel := 0;

    PageBreaksCB.Checked := FPageBreaks;
    OemCB.Checked := FOEMConvert;
    PseudoCB.Checked := FGraphicFrames;
    SaveToFileCB.Checked := FSaveToFile;
    EscCB.ItemIndex := FEscModel;
    CopiesUD.Position := Report.PrintOptions.Copies;

    Result := ShowModal;
    if Result = mrOk then
    begin
      FSaveToFile := SaveToFileCB.Checked;
      if FSaveToFile then
        if SaveDialog1.Execute then
          FileName := SaveDialog1.Filename else
          Result := mrCancel;

      CurPage := False;
      if PageNumbersRB.Checked then
        PageNumbers := RangeE.Text
      else if CurPageRB.Checked then
        CurPage := True
      else
        PageNumbers := '';
      FCopies := StrToInt(CopiesE.Text);
      FPageBreaks := PageBreaksCB.Checked;
      FOEMConvert := OemCB.Checked;
      FGraphicFrames := PseudoCB.Checked;
      FEscModel := EscCB.ItemIndex;

      Ini.WriteBool('DMP', 'OEM', FOEMConvert);
      Ini.WriteBool('DMP', 'GraphFrame', FGraphicFrames);
      Ini.WriteBool('DMP', 'PageBreaks', FPageBreaks);
      Ini.WriteInteger('DMP', 'PrinterType', FEscModel);
    end;
    Free;
  end;
  Ini.Free;
end;

function TfrxDotMatrixExport.Start: Boolean;
begin
  if not ShowDialog then
    FCopies := Report.PrintOptions.Copies;

  if Assigned(Stream) then
    FStream := Stream
  else
  begin
    if not FSaveToFile then
      FileName := GetTempFName;

    if FileName <> '' then
      FStream := TFileStream.Create(FileName, fmCreate)
    else
      FStream := nil;
  end;

  if Assigned(FStream) then
  begin
    Reset;
    WriteStr(FPrinterInitString);
    WriteStr(Report.ReportOptions.InitString);
    Result := True
  end
  else
    Result := False;
end;

procedure TfrxDotMatrixExport.StartPage(Page: TfrxReportPage; Index: Integer);
begin
  FMaxHeight := 0;
  FPageStyle := StyleToInt(TfrxDMPPage(Page).FontStyle);
  CreateBuf(Round(Page.Width / fr1CharX) + 1, Round(Page.Height / fr1CharY) + 1);
  if Page.Orientation = poLandscape then
    Landscape else
    Portrait;
end;

procedure TfrxDotMatrixExport.ExportObject(Obj: TfrxComponent);
var
  Style: Integer;
  Memo: TfrxDMPMemoView;
begin
  if (Obj is TfrxView) and not TfrxView(Obj).Printable then Exit;
  if Obj is TfrxDMPMemoView then
  begin
    Memo := TfrxDMPMemoView(Obj);
    Style := StyleToInt(Memo.FontStyle);
    DrawMemo(Round(Memo.AbsLeft / fr1CharX), Round(Memo.AbsTop / fr1CharY),
      Round(Memo.Width / fr1CharX), Round(Memo.Height / fr1CharY), Memo);
    if (ftLeft in Memo.Frame.Typ) then
      DrawFrame(Round(Memo.AbsLeft / fr1CharX) - 1,
        Round(Memo.AbsTop / fr1CharY) - 1, 1, Round(Memo.Height / fr1CharY) + 2, Style);
    if (ftRight in Memo.Frame.Typ) then
      DrawFrame(Round((Memo.AbsLeft + Memo.Width) / fr1CharX),
        Round(Memo.AbsTop / fr1CharY) - 1, 1, Round(Memo.Height / fr1CharY) + 2, Style);
    if (ftTop in Memo.Frame.Typ) then
      DrawFrame(Round(Memo.AbsLeft / fr1CharX) - 1,
        Round(Memo.AbsTop / fr1CharY) - 1, Round(Memo.Width / fr1CharX) + 2, 1, Style);
    if (ftBottom in Memo.Frame.Typ) then
      DrawFrame(Round(Memo.AbsLeft / fr1CharX) - 1,
        Round((Memo.AbsTop + Memo.Height) / fr1CharY),
        Round(Memo.Width / fr1CharX) + 2, 1, Style);
  end
  else if Obj is TfrxDMPLineView then
  begin
    Style := StyleToInt(TfrxDMPLineView(Obj).FontStyle);
    if Obj.Width = 0 then
      DrawFrame(Trunc(Obj.AbsLeft / fr1CharX), Trunc(Obj.AbsTop / fr1CharY),
        1, Round(Obj.Height / fr1CharY) + 1, Style)
    else if Obj.Height = 0 then
    begin
      if TfrxDMPLineView(Obj).Align = baWidth then
        DrawFrame(Trunc(Obj.AbsLeft / fr1CharX) - 1, Trunc(Obj.AbsTop / fr1CharY),
          Round(Obj.Width / fr1CharX) + 3, 1, Style)
      else if TfrxDMPLineView(Obj).Align = baLeft then
        DrawFrame(Trunc(Obj.AbsLeft / fr1CharX) - 1, Trunc(Obj.AbsTop / fr1CharY),
          Round(Obj.Width / fr1CharX) + 1, 1, Style)
      else if TfrxDMPLineView(Obj).Align = baRight then
        DrawFrame(Trunc(Obj.AbsLeft / fr1CharX), Trunc(Obj.AbsTop / fr1CharY),
          Round(Obj.Width / fr1CharX) + 2, 1, Style)
      else
        DrawFrame(Trunc(Obj.AbsLeft / fr1CharX), Trunc(Obj.AbsTop / fr1CharY),
          Round(Obj.Width / fr1CharX) + 1, 1, Style);
    end;
  end
  else if Obj is TfrxDMPCommand then
  begin
    SetString(Round(Obj.AbsLeft / fr1CharX), Round(Obj.AbsTop / fr1CharY),
      TfrxDMPCommand(Obj).ToChr);
  end;
end;

procedure TfrxDotMatrixExport.FinishPage(Page: TfrxReportPage; Index: Integer);
begin
  FlushBuf;
  FreeBuf;
  if FPageBreaks then
    FormFeed;
end;

procedure TfrxDotMatrixExport.Finish;
var
  i: Integer;
  fname: String;
  f, ffrom: TFileStream;
begin
  if FStream <> Stream then
  begin
    FStream.Free;
    if not frxPrinters.HasPhysicalPrinters then Exit;

    if not FSaveToFile then
    begin
      fname := GetTempFName;
      f := TFileStream.Create(fname, fmCreate);
      ffrom := TFileStream.Create(FileName, fmOpenRead);
      f.Write(FPrinterInitString[1], Length(FPrinterInitString));
      f.CopyFrom(ffrom, 0);
      f.Free;
      ffrom.Free;
      f := TFileStream.Create(FileName, fmCreate);
      ffrom := TFileStream.Create(fname, fmOpenRead);
      f.CopyFrom(ffrom, 0);
      f.Free;
      ffrom.Free;
      DeleteFile(fname);
      for i := 1 to FCopies do
        SpoolFile(FileName);
      DeleteFile(FileName);
    end;
  end;
end;


{ TfrxTXTExportDialog }

procedure TfrxDMPExportDialog.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  Caption := frxGet(500);
  PrinterL.Caption := frxGet(501);
  PagesL.Caption := frxGet(502);
  CopiesL.Caption := frxGet(503);
  CopiesNL.Caption := frxGet(504);
  DescrL.Caption := frxGet(9);
  OptionsL.Caption := frxGet(505);
  EscL.Caption := frxGet(506);
  OK.Caption := frxGet(1);
  Cancel.Caption := frxGet(2);
  SaveToFileCB.Caption := frxGet(507);
  AllRB.Caption := frxGet(3);
  CurPageRB.Caption := frxGet(4);
  PageNumbersRB.Caption := frxGet(5);
  PageBreaksCB.Caption := frxGet(6);
  OemCB.Caption := frxGet(508);
  PseudoCB.Caption := frxGet(509);
  SaveDialog1.Filter := frxGet(510);

  PrinterCB.Items := frxPrinters.Printers;
  PrinterCB.ItemIndex := frxPrinters.PrinterIndex;
  OldIndex := frxPrinters.PrinterIndex;
  for i := 0 to frxDMPrinters.Count - 1 do
    EscCB.Items.Add(frxDMPrinters[i].Commands[cmdName]);

  SetWindowLong(CopiesE.Handle, GWL_STYLE, GetWindowLong(CopiesE.Handle, GWL_STYLE) or ES_NUMBER);
end;

procedure TfrxDMPExportDialog.FormHide(Sender: TObject);
begin
  if ModalResult <> mrOk then
    frxPrinters.PrinterIndex := OldIndex;
end;

procedure TfrxDMPExportDialog.PrinterCBClick(Sender: TObject);
begin
  frxPrinters.PrinterIndex := PrinterCB.ItemIndex;
end;

procedure TfrxDMPExportDialog.PrinterCBDrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  r: TRect;
begin
  r := ARect;
  r.Right := r.Left + 18;
  r.Bottom := r.Top + 16;
  OffsetRect(r, 2, 0);
  with PrinterCB.Canvas do
  begin
    FillRect(ARect);
    BrushCopy(r, Image1.Picture.Bitmap, Rect(0, 0, 18, 16), clOlive);
    TextOut(ARect.Left + 24, ARect.Top + 1, PrinterCB.Items[Index]);
  end;
end;

procedure TfrxDMPExportDialog.RangeEEnter(Sender: TObject);
begin
  PageNumbersRB.Checked := True;
end;


procedure TfrxDMPExportDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

initialization
  frxDMPrinters := TfrxDMPrinters.Create;
  frxDMPrinters.ReadDefaultPrinters;
  frxDMPrinters.ReadExtPrinters;

finalization
  frxDMPrinters.Free;

end.


//0f31356a91fea3356e5f76cdce90aa7b