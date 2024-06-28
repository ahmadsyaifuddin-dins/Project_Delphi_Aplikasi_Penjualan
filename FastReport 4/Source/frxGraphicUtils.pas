
{******************************************}
{                                          }
{             FastReport v4.0              }
{            Graphic routines              }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxGraphicUtils;

interface

{$I frx.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs,
  frxClass, frxUnicodeUtils
{$IFDEF Delphi6}
, Variants
{$ENDIF};


type
  TIntArray = array[0..MaxInt div 4 - 1] of Integer;
  PIntArray = ^TIntArray;

  TfrxHTMLTag = class(TObject)
  public
    Position: Integer;
    Size: Integer;
    AddY: Integer;
    Style: TFontStyles;
    Color: Integer;
    Default: Boolean;
    Small: Boolean;
    procedure Assign(Tag: TfrxHTMLTag);
  end;

  TfrxHTMLTags = class(TObject)
  private
    FItems: TList;
    procedure Add(Tag: TfrxHTMLTag);
    function GetItems(Index: Integer): TfrxHTMLTag;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Count: Integer;
    property Items[Index: Integer]: TfrxHTMLTag read GetItems; default;
  end;

  TfrxHTMLTagsList = class(TObject)
  private
    FAllowTags: Boolean;
    FAddY: Integer;
    FColor: LongInt;
    FDefColor: LongInt;
    FDefSize: Integer;
    FDefStyle: TFontStyles;
    FItems: TList;
    FPosition: Integer;
    FSize: Integer;
    FStyle: TFontStyles;
    FTempArray: PIntArray;
    procedure NewLine;
    procedure Wrap(TagsCount: Integer; AddBreak: Boolean);
    function Add: TfrxHTMLTag;
    function FillCharSpacingArray(var ar: PIntArray; const s: WideString;
      Canvas: TCanvas; LineIndex, Add: Integer; Convert: Boolean): Integer;
    function GetItems(Index: Integer): TfrxHTMLTags;
    function GetPrevTag: TfrxHTMLTag;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure SetDefaults(DefColor: TColor; DefSize: Integer;
      DefStyle: TFontStyles);
    procedure ExpandHTMLTags(var s: WideString);
    function Count: Integer;
    property AllowTags: Boolean read FAllowTags write FAllowTags;
    property Items[Index: Integer]: TfrxHTMLTags read GetItems; default;
    property Position: Integer read FPosition write FPosition;
  end;

  TfrxDrawText = class(TObject)
  private
// internals
    FBMP: TBitmap;
    FLocked: Boolean;
    FCanvas: TCanvas;
    FDefPPI: Integer;
    FScrPPI: Integer;
    FTempArray: PIntArray;

// data passed by SetXXX calls
    FFontSize: Integer;
    FHTMLTags: TfrxHTMLTagsList;
    FCharSpacing: Extended;
    FLineSpacing: Extended;
    FOptions: Integer;
    FOriginalRect: TRect;
    FParagraphGap: Extended;
    FPlainText: WideString;
    FPrintScale: Extended;
    FRotation: Integer;
    FRTLReading: Boolean;
    FScaledRect: TRect;
    FScaleX: Extended;
    FScaleY: Extended;
    FText: TWideStrings;
    FWordBreak: Boolean;
    FWordWrap: Boolean;
    FWysiwyg: Boolean;

    function GetWrappedText: WideString;
    function IsPrinter(C: TCanvas): Boolean;
    procedure DrawTextLine(C: TCanvas; const s: WideString;
      X, Y, DX, LineIndex: Integer; Align: TfrxHAlign; var fh, oldfh: HFont);
    procedure WrapTextLine(s: WideString; Width, FirstLineWidth,
      CharSpacing: Integer);
  public
    constructor Create;
    destructor Destroy; override;

// Call these methods in the same order
    procedure SetFont(Font: TFont);
    procedure SetOptions(WordWrap, HTMLTags, RTLReading, WordBreak,
      Clipped, Wysiwyg: Boolean; Rotation: Integer);
    procedure SetGaps(ParagraphGap, CharSpacing, LineSpacing: Extended);
    procedure SetDimensions(ScaleX, ScaleY, PrintScale: Extended;
      OriginalRect, ScaledRect: TRect);
    procedure SetText(Text: TWideStrings);
    function DeleteTags(const Txt: WideString): WideString;

// call these methods only after methods listed above
    procedure DrawText(C: TCanvas; HAlign: TfrxHAlign; VAlign: TfrxVAlign);
    function CalcHeight: Extended;
    function CalcWidth: Extended;
    function LineHeight: Extended;
    function TextHeight: Extended;
// returns the text that don't fit in the bounds
    function GetInBoundsText: WideString;
    function GetOutBoundsText: WideString;
    function UnusedSpace: Extended;

// call these methods before and after doing something
    procedure Lock;
    procedure Unlock;

    property Canvas: TCanvas read FCanvas;
    property DefPPI: Integer read FDefPPI;
    property ScrPPI: Integer read FScrPPI;
    property WrappedText: WideString read GetWrappedText;
  end;


var
  frxDrawText: TfrxDrawText;

implementation

uses frxPrinter;

const
  glasn: String = 'АЕЁИОУЫЭЮЯ';
  soglasn: String = 'БВГДЖЗЙКЛМНПРСТФХЦЧШЩЬЪ';
  znaks: String = 'ЬЪ';
  znaks1: String = 'Й';

{ Правила переноса по слогам, принятые в русском языке, которые можно
  реализовать в виде алгоритма без словаря.

  1. При переносе слов нельзя ни оставлять в конце строки, ни переносить на
  другую строку часть слова, не составляющую слога; например, нельзя
  переносить просмо-тр, ст-рах.

  2. Нельзя отделять согласную от следующей за ней гласной.
  Неправильно  Правильно
  люб-овь      лю-бовь

  3. Нельзя отрывать буквы ь и ъ от предшествующей согласной.
  Неправильно  Правильно
  бол-ьшой     боль-шой

  4. Нельзя отрывать букву й от предшествующей гласной.
  Неправильно  Правильно
  во-йна       вой-на

  5. Нельзя оставлять в конце строки или переносить на другую строку одну букву.
  Неправильно       Правильно
  а-кация, акаци-я  ака-ция

  6. Нельзя оставлять в конце строки или переносить в начало следующей две
  одинаковые согласные, стоящие между гласными.
  Неправильно  Правильно
  ко-нный      кон-ный }

{ Алгоритм возвращает номера символов строки, после которых можно ставить перенос }
function BreakRussianWord(const s: WideString): String;
var
  i, j: Integer;
  CanBreak: Boolean;

  function Check1and5(const s: WideString): Boolean;
  var
    i: Integer;
  begin
    Result := False;
    if Length(s) >= 2 then
      for i := 1 to Length(s) do
        if Pos(s[i], glasn) <> 0 then
        begin
          Result := True;
          break;
        end;
  end;

begin
  Result := '';
  if Length(s) < 4 then Exit;

  for i := 1 to Length(s) do
  begin
    CanBreak := False;
    if Pos(s[i], soglasn) <> 0 then
    begin
      CanBreak := True;
      { 2 }
      if (i < Length(s)) and (Pos(s[i + 1], glasn) <> 0) then
        CanBreak := False;
      { 3 }
      if (i < Length(s)) and (Pos(s[i + 1], znaks) <> 0) then
        CanBreak := False;
    end;
    if Pos(s[i], glasn) <> 0 then
    begin
      CanBreak := True;
      { 4 }
      if (i < Length(s)) and (Pos(s[i + 1], znaks1) <> 0) then
        CanBreak := False;
      { 6 }
      if (i < Length(s) - 2) and (Pos(s[i + 1], soglasn) <> 0) and
        (s[i + 1] = s[i + 2]) and (Pos(s[i + 3], glasn) <> 0) then
        CanBreak := False;
    end;
    if CanBreak then
      Result := Result + Chr(i);
  end;

  { 1, 5 }
  for i := 1 to Length(Result) do
  begin
    j := Ord(Result[i]);
    if not (Check1and5(Copy(s, 1, j)) and Check1and5(Copy(s, j + 1, 255))) then
      Result[i] := #255;
  end;
  while Pos(#255, Result) <> 0 do
    Delete(Result, Pos(#255, Result), 1);
end;

procedure IncArray(Ar: PIntArray; x1, x2, n, one: Integer);
var
  xm: Integer;
begin
  if n <= 0 then Exit;
  xm := (x2 - x1 + 1) div 2;
  if xm = 0 then
    xm := 1;
  if n = 1 then
    Inc(Ar[x1 + xm - 1], one)
  else
  begin
    IncArray(Ar, x1, x1 + xm - 1, n div 2, one);
    IncArray(Ar, x1 + xm, x2, n - n div 2, one);
  end;
end;

function CreateRotatedFont(Font: TFont; Rotation: Integer): HFont;
var
  F: TLogFont;
begin
  GetObject(Font.Handle, SizeOf(TLogFont), @F);
  F.lfEscapement := Rotation * 10;
  F.lfOrientation := Rotation * 10;
  Result := CreateFontIndirect(F);
end;


{ TfrxHTMLTag }

procedure TfrxHTMLTag.Assign(Tag: TfrxHTMLTag);
begin
  Position := Tag.Position;
  Size := Tag.Size;
  AddY := Tag.AddY;
  Style := Tag.Style;
  Color := Tag.Color;
  Default := Tag.Default;
  Small := Tag.Small;
end;


{ TfrxHTMLTags }

constructor TfrxHTMLTags.Create;
begin
  FItems := TList.Create;
end;

destructor TfrxHTMLTags.Destroy;
begin
  Clear;
  FItems.Free;
  inherited;
end;

procedure TfrxHTMLTags.Clear;
var
  i: Integer;
begin
  for i := 0 to FItems.Count - 1 do
    TfrxHTMLTag(FItems[i]).Free;
  FItems.Clear;
end;

function TfrxHTMLTags.GetItems(Index: Integer): TfrxHTMLTag;
begin
  Result := TfrxHTMLTag(FItems[Index]);
end;

function TfrxHTMLTags.Count: Integer;
begin
  Result := FItems.Count;
end;

procedure TfrxHTMLTags.Add(Tag: TfrxHTMLTag);
begin
  FItems.Add(Tag);
end;


{ TfrxHTMLTagsList }

constructor TfrxHTMLTagsList.Create;
begin
  FItems := TList.Create;
  FAllowTags := True;
  GetMem(FTempArray, SizeOf(Integer) * 32768);
end;

destructor TfrxHTMLTagsList.Destroy;
begin
  Clear;
  FItems.Free;
  FreeMem(FTempArray, SizeOf(Integer) * 32768);
  inherited;
end;

procedure TfrxHTMLTagsList.Clear;
var
  i: Integer;
begin
  for i := 0 to FItems.Count - 1 do
    TfrxHTMLTags(FItems[i]).Free;
  FItems.Clear;
end;

procedure TfrxHTMLTagsList.NewLine;
begin
  if Count <> 0 then
    FItems.Add(TfrxHTMLTags.Create);
end;

procedure TfrxHTMLTagsList.Wrap(TagsCount: Integer; AddBreak: Boolean);
var
  i: Integer;
  Line, OldLine: TfrxHTMLTags;
  NewTag: TfrxHTMLTag;
begin
  OldLine := Items[Count - 1];
  if OldLine.Count <= TagsCount then
    Exit;

  NewLine;
  Line := Items[Count - 1];
  for i := TagsCount to OldLine.Count - 1 do
    Line.Add(OldLine[i]);
  OldLine.FItems.Count := TagsCount;
  if AddBreak then
  begin
    NewTag := TfrxHTMLTag.Create;
    OldLine.FItems.Add(NewTag);
    NewTag.Assign(TfrxHTMLTag(OldLine.FItems[TagsCount - 1]))
  end
  else if Line[0].Default then
    Line[0].Assign(OldLine[TagsCount - 1]);
end;

function TfrxHTMLTagsList.Count: Integer;
begin
  Result := FItems.Count;
end;

function TfrxHTMLTagsList.GetItems(Index: Integer): TfrxHTMLTags;
begin
  Result := TfrxHTMLTags(FItems[Index]);
end;

function TfrxHTMLTagsList.Add: TfrxHTMLTag;
var
  i: Integer;
begin
  Result := TfrxHTMLTag.Create;
  i := Count - 1;
  if i = -1 then
  begin
    FItems.Add(TfrxHTMLTags.Create);
    i := 0;
  end;
  Items[i].Add(Result);
end;

function TfrxHTMLTagsList.GetPrevTag: TfrxHTMLTag;
var
  Tags: TfrxHTMLTags;
begin
  Result := nil;
  Tags := Items[Count - 1];
  if Tags.Count > 1 then
    Result := Tags[Tags.Count - 2]
  else if Count > 1 then
  begin
    Tags := Items[Count - 2];
    Result := Tags[Tags.Count - 1];
  end;
end;

procedure TfrxHTMLTagsList.SetDefaults(DefColor: TColor; DefSize: Integer;
  DefStyle: TFontStyles);
begin
  FDefColor := DefColor;
  FDefSize := DefSize;
  FDefStyle := DefStyle;
  FAddY := 0;
  FColor := FDefColor;
  FSize := FDefSize;
  FStyle := FDefStyle;
  FPosition := 1;
  Clear;
end;

procedure TfrxHTMLTagsList.ExpandHTMLTags(var s: WideString);
var
  i, j, j1: Integer;
  b: Boolean;
  cl: WideString;

  procedure AddTag;
  var
    Tag, PrevTag: TfrxHTMLTag;
  begin
    Tag := Add;
    Tag.Position := FPosition; // this will help us to get position in the original text
    Tag.Size := FSize;
    Tag.Style := FStyle;
    Tag.Color := FColor;
    Tag.AddY := FAddY;
// when "Default" changes, we need to set Font.Style, Size and Color
    if FAllowTags then
    begin
      PrevTag := GetPrevTag;
      if PrevTag <> nil then
        Tag.Default := (FStyle = PrevTag.Style) and
                       (FColor = PrevTag.Color) and
                       (FSize = PrevTag.Size)
      else
        Tag.Default := (FStyle = FDefStyle) and (FColor = FDefColor) and (FSize = FDefSize);
    end
    else
      Tag.Default := True;
    Tag.Small := FSize <> FDefSize;
  end;

begin
  i := 1;
  if Length(s) = 0 then Exit;

  while i <= Length(s) do
  begin
    b := True;

    if FAllowTags then
      if s[i] = '<' then
      begin

        // <b>, <u>, <i> tags
        if (i + 2 <= Length(s)) and (s[i + 2] = '>') then
        begin
          case s[i + 1] of
            'b','B': FStyle := FStyle + [fsBold];
            'i','I': FStyle := FStyle + [fsItalic];
            'u','U': FStyle := FStyle + [fsUnderline];
            else
              b := False;
          end;
          if b then
          begin
            System.Delete(s, i, 3);
            Inc(FPosition, 3);
            continue;
          end;
        end

        // <sub>, <sup> tags
        else if (i + 4 <= Length(s)) and (s[i + 4] = '>') then
        begin
          if Pos('SUB>', AnsiUpperCase(s)) = i + 1 then
          begin
            FSize := Round(FDefSize / 1.5);
            FAddY := 1;
            b := True;
          end
          else if Pos('SUP>', AnsiUpperCase(s)) = i + 1 then
          begin
            FSize := Round(FDefSize / 1.5);
            FAddY := 0;
            b := True;
          end;
          if b then
          begin
            System.Delete(s, i, 5);
            Inc(FPosition, 5);
            continue;
          end;
        end

        // <strike> tag
        else if (i + 1 <= Length(s)) and ((s[i + 1] = 's') or (s[i + 1] = 'S')) then
        begin
          if Pos('STRIKE>', AnsiUpperCase(s)) = i + 1 then
          begin
            FStyle := FStyle + [fsStrikeOut];
            System.Delete(s, i, 8);
            Inc(FPosition, 8);
            continue;
          end;
        end

        // </b>, </u>, </i>, </strike>, </font>, </sub>, </sup> tags
        else if (i + 1 <= Length(s)) and (s[i + 1] = '/') then
        begin
          if (i + 3 <= Length(s)) and (s[i + 3] = '>') then
          begin
            case s[i + 2] of
              'b','B': FStyle := FStyle - [fsBold];
              'i','I': FStyle := FStyle - [fsItalic];
              'u','U': FStyle := FStyle - [fsUnderline];
              else
                b := False;
            end;
            if b then
            begin
              System.Delete(s, i, 4);
              Inc(FPosition, 4);
              continue;
            end;
          end
          else if (Pos('STRIKE>', AnsiUpperCase(s)) = i + 2) then
          begin
            FStyle := FStyle - [fsStrikeOut];
            System.Delete(s, i, 9);
            Inc(FPosition, 9);
            continue;
          end
          else if Pos('FONT>', AnsiUpperCase(s)) = i + 2 then
          begin
            FColor := FDefColor;
            System.Delete(s, i, 7);
            Inc(FPosition, 7);
            continue;
          end
          else if (Pos('SUB>', AnsiUpperCase(s)) = i + 2) or
            (Pos('SUP>', AnsiUpperCase(s)) = i + 2) then
          begin
            FSize := FDefSize;
            FAddY := 0;
            System.Delete(s, i, 6);
            Inc(FPosition, 6);
            continue;
          end
        end

  // <font color = ...> tag
        else if Pos('FONT COLOR', AnsiUpperCase(s)) = i + 1 then
        begin
          j := i + 11;
          while (j <= Length(s)) and (s[j] <> '=') do
            Inc(j);
          Inc(j);
          while (j <= Length(s)) and (s[j] = ' ') do
            Inc(j);
          j1 := j;
          while (j <= Length(s)) and (s[j] <> '>') do
            Inc(j);

          cl := Copy(s, j1, j - j1);
          if cl <> '' then
          begin
            if (Length(cl) > 3) and (cl[1] = '"') and (cl[2] = '#') and
              (cl[Length(cl)] = '"') then
            begin
              cl := '$' + Copy(cl, 3, Length(cl) - 3);
              FColor := StrToInt(cl);
              FColor := (FColor and $00FF0000) div 65536 +
                        (FColor and $000000FF) * 65536 +
                        (FColor and $0000FF00);
              System.Delete(s, i, j - i + 1);
              Inc(FPosition, j - i + 1);
              continue;
            end
            else if IdentToColor('cl' + cl, FColor) then
            begin
              System.Delete(s, i, j - i + 1);
              Inc(FPosition, j - i + 1);
              continue;
            end;
          end;
        end
      end;

    AddTag;
    Inc(i);
    Inc(FPosition);
  end;

  if Length(s) = 0 then
  begin
    AddTag;
    s := ' ';
  end;
end;

function TfrxHTMLTagsList.FillCharSpacingArray(var ar: PIntArray; const s: WideString;
  Canvas: TCanvas; LineIndex, Add: Integer; Convert: Boolean): Integer;
var
  i, n: Integer;
  Tags: TfrxHTMLTags;
  Tag: TfrxHTMLTag;

  procedure BreakArray;
  var
    i, j, offs: Integer;
    Size: TSize;
    ansis: String;
  begin
    if (Win32Platform <> VER_PLATFORM_WIN32_NT) or (Canvas.Font.Charset <> DEFAULT_CHARSET) then
    begin
      ansis := s;
      GetTextExtentExPoint(Canvas.Handle, PChar(ansis), n, 0, nil,
        @FTempArray[0], Size);
    end
    else
      GetTextExtentExPointW(Canvas.Handle, PWideChar(s), n, 0, nil,
        @FTempArray[0], Size);
    i := 0;
    repeat
      if FTempArray[i] = 32767 then
      begin
        offs := FTempArray[i - 1];
        if (Win32Platform <> VER_PLATFORM_WIN32_NT) or (Canvas.Font.Charset <> DEFAULT_CHARSET) then
        begin
          ansis := s;
          GetTextExtentExPoint(Canvas.Handle, PChar(ansis) + i, n - i, 0, nil,
            @FTempArray[i], Size);
        end
        else
          GetTextExtentExPointW(Canvas.Handle, PWideChar(s) + i, n - i, 0, nil,
            @FTempArray[i], Size);
        for j := i to n - 1 do
          if FTempArray[j] = 32767 then
          begin
            i := j - 1;
            break;
          end
          else
            FTempArray[j] := FTempArray[j] + offs;
      end;
      Inc(i);
    until i >= n;
  end;

begin
  Result := 0;
  n := Length(s);

  Tags := Items[LineIndex];
  Tag := Tags.Items[0];
  if not Tag.Default then
    Canvas.Font.Style := Tag.Style;

  BreakArray;

  for i := 0 to n - 1 do
  begin
    Tag := Tags.Items[i];
    if (i <> 0) and not Tag.Default then
    begin
      Canvas.Font.Style := Tag.Style;
      BreakArray;
    end;

    if i > 0 then
      Ar[i] := FTempArray[i] - FTempArray[i - 1] + Add else
      Ar[i] := FTempArray[i] + Add;
    if Tag.Small then
      Ar[i] := Round(Ar[i] / 1.5);
    Inc(Result, Ar[i]);
    if Convert and (i > 0) then
      Inc(Ar[i], Ar[i - 1]);
  end;
end;


{ TfrxDrawText }

constructor TfrxDrawText.Create;
begin
  FBMP := TBitmap.Create;
  FCanvas := FBMP.Canvas;
  FDefPPI := 600;
  FScrPpi := 96;
  FHTMLTags := TfrxHTMLTagsList.Create;
  FText := TWideStrings.Create;
  FWysiwyg := True;
  GetMem(FTempArray, SizeOf(Integer) * 32768);
end;

destructor TfrxDrawText.Destroy;
begin
  FBMP.Free;
  FHTMLTags.Free;
  FText.Free;
  FreeMem(FTempArray, SizeOf(Integer) * 32768);
  inherited;
end;

procedure TfrxDrawText.SetFont(Font: TFont);
var
  h: Integer;
begin
  FFontSize := Font.Size;
  h := -Round(FFontSize * FDefPPI / 72);  // height is as in the 600 dpi printer
  FCanvas.Lock;
  try
    with FCanvas.Font do
    begin
      if Name <> Font.Name then
        Name := Font.Name;
      if Height <> h then
        Height := h;
      if Style <> Font.Style then
        Style := Font.Style;
      if Charset <> Font.Charset then
        Charset := Font.Charset;
      if Color <> Font.Color then
        Color := Font.Color;
    end;
  finally
    FCanvas.Unlock;
  end;
end;

procedure TfrxDrawText.SetOptions(WordWrap, HTMLTags, RTLReading,
  WordBreak, Clipped, Wysiwyg: Boolean; Rotation: Integer);
begin
  FWordWrap := WordWrap;
  FHTMLTags.AllowTags := HTMLTags;
  FRTLReading := RTLReading;
  FOptions := 0;
  if RTLReading then
    FOptions := ETO_RTLREADING;
  if Clipped then
    FOptions := FOptions or ETO_CLIPPED;
  FWordBreak := WordBreak;
  FRotation := Rotation mod 360;
  FWysiwyg := Wysiwyg;
end;

procedure TfrxDrawText.SetDimensions(ScaleX, ScaleY, PrintScale: Extended;
  OriginalRect, ScaledRect: TRect);
begin
  FScaleX := ScaleX;
  FScaleY := ScaleY;
  FPrintScale := PrintScale;
  FOriginalRect := OriginalRect;
  FScaledRect := ScaledRect;
end;

procedure TfrxDrawText.SetGaps(ParagraphGap, CharSpacing, LineSpacing: Extended);
begin
  FParagraphGap := ParagraphGap;
  FCharSpacing := CharSpacing;
  FLineSpacing := LineSpacing;
end;

procedure TfrxDrawText.SetText(Text: TWideStrings);
var
  i, j, n, Width: Integer;
  s: WideString;
  Style: TFontStyles;
  FPPI: Extended;
begin
  FCanvas.Lock;
  try
    FPlainText := '';
    FText.Clear;
  finally
    FCanvas.Unlock;
  end;

  n := Text.Count;
  if n = 0 then Exit;

  FCanvas.Lock;
  try
  // set up html engine
    FHTMLTags.SetDefaults(FCanvas.Font.Color, FFontSize, FCanvas.Font.Style);
    Style := FCanvas.Font.Style;

  // width of the wrap area
    Width := FOriginalRect.Right - FOriginalRect.Left;
    if ((FRotation >= 90) and (FRotation < 180)) or
       ((FRotation >= 270) and (FRotation < 360)) then
      Width := FOriginalRect.Bottom - FOriginalRect.Top;

    for i := 0 to n - 1 do
    begin
      j := FText.Count;
      s := Text[i];
      if s = '' then
        s := ' ';
      FPlainText := FPlainText + s + #13#10;
      FPPI := FDefPPI / FScrPPI;
      WrapTextLine(s,
        Round(Width * FPPI),
        Round((Width - FParagraphGap) * FPPI),
        Round(FCharSpacing * FPPI));
      if FText.Count <> j then
      begin
        FText.Objects[j] := Pointer(1);                 // mark the begin of paragraph:
        if FText.Count - 1 = j then                     // it will be needed in DrawText
          FText.Objects[j] := Pointer(3) else           // both begin and end at one line
          FText.Objects[FText.Count - 1] := Pointer(2); // mark the end of paragraph
      end;
    end;

    FCanvas.Font.Style := Style;
  finally
    FCanvas.Unlock;
  end;
end;

function TfrxDrawText.DeleteTags(const Txt: WideString): WideString;
begin
  Result := Txt;
  FHTMLTags.ExpandHTMLTags(Result);
end;

procedure TfrxDrawText.WrapTextLine(s: WideString;
  Width, FirstLineWidth, CharSpacing: Integer);
var
  n, i, Offset, LineBegin, LastSpace, BreakPos: Integer;
  sz: TSize;
  TheWord: WideString;
  WasBreak: Boolean;

  function BreakWord(const s: WideString; LineBegin, CurPos, LineEnd: Integer): WideString;
  var
    i, BreakPos: Integer;
    TheWord, Breaks: WideString;
  begin
    // get the whole word
    i := CurPos;
    while (i <= LineEnd) and (Pos(s[i], ' .,-;') = 0) do
      Inc(i);
    TheWord := Copy(s, LineBegin, i - LineBegin);
    // get available break positions
    Breaks := BreakRussianWord(AnsiUpperCase(TheWord));
    // find the closest position
    BreakPos := CurPos - LineBegin;
    for i := Length(Breaks) downto 1 do
      if Ord(Breaks[i]) < BreakPos then
      begin
        BreakPos := Ord(Breaks[i]);
        break;
      end;
    if BreakPos <> CurPos - LineBegin then
      Result := Copy(TheWord, 1, BreakPos) else
      Result := '';
  end;

begin
// remove all HTML tags and build the tag list
  FHTMLTags.NewLine;
  FHTMLTags.ExpandHTMLTags(s);
  FHTMLTags.FPosition := FHTMLTags.FPosition + 2;

  n := Length(s);
  if (n < 2) or not FWordWrap then  // no need to wrap a string with 0 or 1 symbol
  begin
    FText.Add(s);
    Exit;
  end;

// get the intercharacter spacing table and calculate the width
  FCanvas.Lock;
  try
    sz.cx := FHTMLTags.FillCharSpacingArray(FTempArray, s, FCanvas,
      FHTMLTags.Count - 1, CharSpacing, True);
  finally
    FCanvas.Unlock;
  end;

// text fits, no need to wrap it
  if sz.cx < FirstLineWidth then
  begin
    FText.Add(s);
    Exit;
  end;

  Offset := 0;
  i := 1;
  LineBegin := 1; // index of the first symbol in the current line
  LastSpace := 1; // index of the last space symbol in the current line

  while i <= n do
  begin
    if s[i] = ' ' then
      LastSpace := i;

    if FTempArray[i - 1] - Offset > FirstLineWidth then  // need wrap
    begin
      if LastSpace = LineBegin then  // there is only one word without spaces...
      begin
        if i <> LineBegin then       // ... and it has more than 1 symbol
        begin
          if FWordBreak then
          begin
            TheWord := BreakWord(s, LineBegin, i, n);
            WasBreak := TheWord <> '';
            if not WasBreak then
              TheWord := Copy(s, LineBegin, i - LineBegin);
            if WasBreak then
              FText.Add(TheWord + '-') else
              FText.Add(TheWord);
            BreakPos := Length(TheWord);
            FHTMLTags.Wrap(BreakPos, WasBreak);
            LastSpace := LineBegin + BreakPos - 1;
          end
          else
          begin
            FText.Add(Copy(s, LineBegin, i - LineBegin));
            FHTMLTags.Wrap(i - LineBegin, False);
            LastSpace := i - 1;
          end;
        end
        else
        begin
          FText.Add(s[LineBegin]); // can't wrap 1 symbol, just add it to the new line
          FHTMLTags.Wrap(1, False);
        end;
      end
      else // we have a space symbol inside
      begin
        if FWordBreak then
        begin
          TheWord := BreakWord(s, LastSpace + 1, i, n);
          WasBreak := TheWord <> '';
          if WasBreak then
            FText.Add(Copy(s, LineBegin, LastSpace - LineBegin + 1) + TheWord + '-') else
            FText.Add(Copy(s, LineBegin, LastSpace - LineBegin));
          BreakPos := LastSpace - LineBegin + Length(TheWord) + 1;
          FHTMLTags.Wrap(BreakPos, WasBreak);
          if WasBreak then
            LastSpace := LineBegin + BreakPos - 1;
        end
        else
        begin
          FText.Add(Copy(s, LineBegin, LastSpace - LineBegin));
          FHTMLTags.Wrap(LastSpace - LineBegin + 1, False);
        end;
      end;

      Offset := FTempArray[LastSpace - 1]; // starting a new line
      i := LastSpace;
      Inc(LastSpace);
      LineBegin := LastSpace;
      FirstLineWidth := Width; // this line is not first, so use Width
    end;

    Inc(i);
  end;

  if n - LineBegin + 1 > 0 then   // put the rest of line to FText
    FText.Add(Copy(s, LineBegin, n - LineBegin + 1));
end;

procedure TfrxDrawText.DrawTextLine(C: TCanvas; const s: WideString;
  X, Y, DX, LineIndex: Integer; Align: TfrxHAlign; var fh, oldfh: HFont);
var
  spaceAr: PIntArray;
  n, i, j, cw, neededSize, extraSize, spaceCount: Integer;
  add1, add2, add3, addCount: Integer;
  ratio: Extended;
  Sz, prnSz, PPI: Integer;
  Tag: TfrxHTMLTag;
  CosA, SinA: Extended;
  Style: TFontStyles;
  FPPI: Extended;

  function CountSpaces: Integer;
  var
    i: Integer;
  begin
    Result := 0;
    for i := 0 to n - 1 do
    begin
      spaceAr[i] := 0;
      if (s[i + 1] = ' ') or (s[i + 1] = #$A0) then
      begin
        Inc(Result);
        spaceAr[i] := 1;
      end;
    end;
  end;

  function CalcWidth(Index, Count: Integer): Integer;
  var
    i: Integer;
  begin
    Result := 0;
    for i := Index to Index + Count - 1 do
      Result := Result + FTempArray[i];
  end;

begin
  n := Length(s);
  if n = 0 then Exit;

  spaceAr := nil;
  FCanvas.Lock;

  try
    Style := C.Font.Style;
    FHTMLTags.FDefStyle := Style;
    FCanvas.Font.Style := Style;
    FPPI := FDefPPI / FScrPPI;

    PrnSz := FHTMLTags.FillCharSpacingArray(FTempArray, s, FCanvas, LineIndex,
      Round(FCharSpacing * FPPI), False) - Round(FCharSpacing * FPPI);
    Sz := FHTMLTags.FillCharSpacingArray(FTempArray, s, C, LineIndex,
      Round(FCharSpacing * FScaleX), False) - Round(FCharSpacing * FScaleX);                      //!Den

    C.Font.Style := Style;
    if FHTMLTags.AllowTags and (FRotation <> 0) then
    begin
      SelectObject(C.Handle, oldfh);
      DeleteObject(fh);
      fh := CreateRotatedFont(C.Font, FRotation);
      oldfh := SelectObject(C.Handle, fh);
    end;

    PPI := GetDeviceCaps(C.Handle, LOGPIXELSX);
    ratio := FDefPPI / PPI;
    if IsPrinter(C) then
      neededSize := Round(prnSz * FPrintScale / ratio) else
      neededSize := Round(prnSz / (FDefPPI / 96) * FScaleX);
    if not FWysiwyg then
      neededSize := Sz;
    extraSize := neededSize - Sz;

    CosA := Cos(pi / 180 * FRotation);
    SinA := Sin(pi / 180 * FRotation);
    if Align = haRight then
    begin
      X := x + Round((dx - neededSize + 1) * CosA);
      Y := y - Round((dx - neededSize + 1) * SinA);

      Dec(X, 1);
      if (fsBold in Style) or (fsItalic in Style) then
        if FRotation = 0 then
          Dec(X, 1);
    end
    else if Align = haCenter then
    begin
      X := x + Round((dx - neededSize) / 2 * CosA);
      Y := y - Round((dx - neededSize) / 2 * SinA);
    end;


    if Align = haBlock then
    begin
      GetMem(spaceAr, SizeOf(Integer) * n);
      spaceCount := CountSpaces;
      if spaceCount = 0 then
        Align := haLeft else
        extraSize := Abs(dx) - Sz;
    end
    else
      spaceCount := 0;

    if extraSize < 0 then
    begin
      extraSize := -extraSize;
      add3 := -1;
    end
    else
      add3 := 1;

    if Align <> haBlock then
    begin
      if extraSize < n then
        IncArray(FTempArray, 0, n - 1, extraSize, add3)
      else
      begin
        add1 := extraSize div n * add3;
        for i := 0 to n - 1 do
          Inc(FTempArray[i], add1);
        IncArray(FTempArray, 0, n - 1, extraSize - add1 * n * add3, add3)
      end;
    end
    else
    begin
      add1 := extraSize div spaceCount;
      add2 := extraSize mod spaceCount;
      addCount := 0;
      for i := 0 to n - 1 do
        if spaceAr[i] = 1 then
        begin
          Inc(FTempArray[i], add1 * add3);
          if addCount <= add2 then
          begin
            Inc(FTempArray[i], add3);
            Inc(addCount);
          end;
        end;
    end;


    i := 0;
    Tag := FHTMLTags[LineIndex].Items[0];
    add1 := Round(Tag.AddY * Tag.Size * FScaleY);

    repeat
      j := i;
      while i < n do
      begin
        Tag := FHTMLTags[LineIndex].Items[i];
        if not Tag.Default then
        begin
          Tag.Default := True;
          break;
        end;
        Inc(i);
      end;

      if (C.Font.Charset = DEFAULT_CHARSET) and (Win32Platform = VER_PLATFORM_WIN32_NT) then
        if FWysiwyg then
          ExtTextOutW(C.Handle, X + Round(add1 * SinA), Y + Round(add1 * CosA),
            FOptions, @FScaledRect, PWideChar(s) + j, i - j, @FTempArray[j])
        else
          ExtTextOutW(C.Handle, X + Round(add1 * SinA), Y + Round(add1 * CosA),
            FOptions, @FScaledRect, PWideChar(s) + j, i - j, nil)
      else
        if FWysiwyg then
          ExtTextOut(C.Handle, X + Round(add1 * SinA), Y + Round(add1 * CosA),
            FOptions, @FScaledRect, PChar(String(s)) + j, i - j, @FTempArray[j])
        else
          ExtTextOut(C.Handle, X + Round(add1 * SinA), Y + Round(add1 * CosA),
            FOptions, @FScaledRect, PChar(String(s)) + j, i - j, nil);

      if i < n then
      begin
        if IsPrinter(C) then
          C.Font.Height := -Round(Tag.Size * PPI * FPrintScale / 72) else
          C.Font.Height := -Round(Tag.Size * FScaleY * 96 / 72);
        C.Font.Style := Tag.Style;
        C.Font.Color := Tag.Color;
        add1 := Round(Tag.AddY * Tag.Size * FScaleY);

        cw := CalcWidth(j, i - j);
        if FRotation = 0 then
          X := X + cw
        else
        begin
          X := X + Round(cw * CosA);
          Y := Y - Round(cw * SinA);

          SelectObject(C.Handle, oldfh);
          DeleteObject(fh);
          fh := CreateRotatedFont(C.Font, FRotation);
          oldfh := SelectObject(C.Handle, fh);
        end;
      end;
    until i >= n;

    if spaceAr <> nil then
      FreeMem(spaceAr, SizeOf(Integer) * n);

  finally
    FCanvas.Unlock;
  end;
end;

procedure TfrxDrawText.DrawText(C: TCanvas; HAlign: TfrxHAlign; VAlign: TfrxVAlign);
var
  Ar: PIntArray;
  i, n, neededSize, extraSize, add1, add3: Integer;
  ratio: Extended;
  al: TfrxHAlign;
  x, y, par: Integer;
  Sz, prnSz: Integer;
  Tag: TfrxHTMLTag;
  fh, oldfh: HFont;
  h, PPI, dx, gx: Integer;
  CosA, SinA: Extended;

  procedure CalcRotatedCoords;
  var
    AbsCosA, AbsSinA: Extended;
    dy: Integer;
  begin
    CosA := Cos(pi / 180 * FRotation);
    SinA := Sin(pi / 180 * FRotation);
    AbsCosA := Abs(CosA);
    AbsSinA := Abs(SinA);

    dy := 0;
    with FScaledRect do
      case FRotation of
        0:
          begin
            x := Left;
            y := Top;
            dx := Right - Left;
            dy := Bottom - Top;
          end;

        1..89:
          begin
            x := Left;
            dx := Round((Right - Left - neededsize * AbsSinA) / AbsCosA);
            y := Top + Round(dx * AbsSinA);
            dy := Bottom - y - Round(neededsize * AbsCosA) + neededsize;
            CosA := 1; SinA := 0;
          end;

        90:
          begin
            x := Left;
            y := Bottom;
            dx := Bottom - Top;
            dy := Right - Left;
          end;

        91..179:
          begin
            y := Bottom;
            dx := Round((Right - Left - neededsize * AbsSinA) / AbsCosA);
            x := Left + Round(dx * AbsCosA);
            dy := Bottom - Top - Round(neededsize * AbsCosA + dx * AbsSinA) + neededsize;
            CosA := -1; SinA := 0;
          end;

        180:
          begin
            x := Right;
            y := Bottom;
            dx := Right - Left;
            dy := Bottom - Top;
          end;

        181..269:
          begin
            x := Right;
            dx := Round((Right - Left - neededsize * AbsSinA) / AbsCosA);
            y := Bottom - Round(dx * AbsSinA);
            dy := y - Top - Round(neededsize * AbsCosA) + neededsize;
            CosA := -1; SinA := 0;
          end;

        270:
          begin
            x := Right;
            y := Top;
            dx := Bottom - Top;
            dy := Right - Left;
          end;

        271..359:
          begin
            y := Top;
            dx := Round((Right - Left - neededsize * AbsSinA) / AbsCosA);
            x := Left + Round(neededsize * AbsSinA);
            dy := Bottom - Top - Round(dx * AbsSinA + neededsize * AbsCosA) + neededsize;
            CosA := 1; SinA := 0;
          end;
      end;

    if VAlign = vaBottom then
    begin
      y := y + Round(CosA * (dy - neededSize));
      x := x + Round(SinA * (dy - neededSize));
    end
    else if VAlign = vaCenter then
    begin
      y := y + Round(CosA * (dy - neededSize) / 2);
      x := x + Round(SinA * (dy - neededSize) / 2);
    end;

    CosA := cos(pi / 180 * FRotation);
    SinA := sin(pi / 180 * FRotation);
  end;

begin
  n := FText.Count;
  if (n = 0) or (FHTMLTags.Count = 0) then exit;  // no text to draw

  FCanvas.Lock;
  try
    PPI := GetDeviceCaps(C.Handle, LOGPIXELSY);
    if IsPrinter(C) then
      h := -Round(FFontSize * PPI * FPrintScale / 72) else
      h := -Round(FFontSize * FScaleY * 96 / 72);
    C.Font := FCanvas.Font;
    C.Font.Height := h;

    if FHTMLTags[0].Count > 0 then
    begin
      Tag := FHTMLTags[0].Items[0];
      if not Tag.Default then
      begin
        C.Font.Style := Tag.Style;
        C.Font.Color := Tag.Color;
        if IsPrinter(C) then
          C.Font.Height := -Round(Tag.Size * PPI * FPrintScale / 72) else
          C.Font.Height := -Round(Tag.Size * FScaleY * 96 / 72);
      end;
      Tag.Default := True;
    end;

    fh := 0; oldfh := 0;
    if FRotation <> 0 then
    begin
      fh := CreateRotatedFont(C.Font, FRotation);
      oldfh := SelectObject(C.Handle, fh);
    end;

    Sz := -C.Font.Height;
    PrnSz := -FCanvas.Font.Height;
    if IsPrinter(C) then
    begin
      ratio := FDefPPI / PPI / FPrintScale;
      neededSize := Round((prnSz * n + FLineSpacing * FScaleY * ratio * n) / ratio)
    end
    else
    begin
      ratio := FDefPPI / 96;
      neededSize := Round((prnSz * n + FLineSpacing * ratio * n) / ratio * FScaleY);
    end;
    extraSize := neededSize - (Sz * n + Round(FLineSpacing * FScaleY) * n);

    if not FWysiwyg then
      extraSize := 0;

    CalcRotatedCoords;

    GetMem(Ar, SizeOf(Integer) * n);
    for i := 0 to n - 2 do
      Ar[i] := Round(FLineSpacing * FScaleY) + Sz;

    if extraSize < 0 then
    begin
      extraSize := -extraSize;
      add3 := -1;
    end
    else
      add3 := 1;

    if n > 1 then
      if extraSize < n then
        IncArray(Ar, 0, n - 2, extraSize, add3)
      else if n > 1 then
      begin
        add1 := extraSize div (n - 1) * add3;
        for i := 0 to n - 2 do
          Inc(Ar[i], add1);
        IncArray(Ar, 0, n - 2, extraSize - add1 * (n - 1) * add3, add3)
      end;

    SetBkMode(C.Handle, Transparent);

    for i := 0 to n - 1 do
    begin
      gx := 0;
      al := HAlign;
      par := Integer(FText.Objects[i]);
      if (par and 1) <> 0 then
        if HAlign in [haLeft, haBlock] then
          gx := Round(FParagraphGap * FScaleX);
      if (par and 2) <> 0 then
        if HAlign = haBlock then
          if FRTLReading then
            al := haRight else
            al := haLeft;

      DrawTextLine(C, FText[i], x + gx, y, dx - gx, i, al, fh, oldfh);
      Inc(y, Round(Ar[i] * CosA));
      Inc(x, Round(Ar[i] * SinA));
    end;

    FreeMem(Ar, SizeOf(Integer) * n);

    if FRotation <> 0 then
    begin
      SelectObject(C.Handle, oldfh);
      DeleteObject(fh);
    end;

  finally
    FCanvas.Unlock;
  end;
end;

function TfrxDrawText.UnusedSpace: Extended;
var
  PrnSz: Integer;
  n: Integer;
  ratio: Extended;
begin
  FCanvas.Lock;
  try
    PrnSz := -FCanvas.Font.Height;
    ratio := FDefPPI / FScrPPI;

  // number of lines that will fit in the bounds
    n := Trunc((FOriginalRect.Bottom - FOriginalRect.Top + 1) /
      (PrnSz / ratio + FLineSpacing));
    if n = 0 then
      Result := 0
    else
    begin
      Result := (FOriginalRect.Bottom - FOriginalRect.Top + 1) -
        (PrnSz / ratio + FLineSpacing) * n;
      if Result = 0 then
        Result := 1e-4;
    end;
  finally
    FCanvas.Unlock;
  end;
end;

function TfrxDrawText.CalcHeight: Extended;
var
  PrnSz: Integer;
  n: Integer;
  ratio: Extended;
begin
  n := FText.Count;
  if n = 0 then
  begin
    Result := 0;
    Exit;
  end;
  FCanvas.Lock;
  try
    PrnSz := -FCanvas.Font.Height;
  finally
    FCanvas.Unlock;
  end;
  ratio := FDefPPI / FScrPPI;
  Result := (PrnSz / ratio + FLineSpacing) * n;
end;

function TfrxDrawText.CalcWidth: Extended;
var
  Sz: TSize;
  s: WideString;
  i, maxWidth, par: Integer;
  ratio: Extended;
begin
  if FText.Count = 0 then
  begin
    Result := 0;
    Exit;
  end;

  ratio := FDefPPI / FScrPPI;
  maxWidth := 0;
  FCanvas.Lock;
  try
    for i := 0 to FText.Count - 1 do
    begin
      s := FText[i];
      GetTextExtentPointW(FCanvas.Handle, PWideChar(s), Length(s), Sz);
      Inc(Sz.cx, Round(Length(s) * FCharSpacing * ratio));

      par := Integer(FText.Objects[i]);
      if (par and 1) <> 0 then
        Inc(Sz.cx, Round(FParagraphGap * ratio));

      if maxWidth < Sz.cx then
        maxWidth := Sz.cx;
    end;
  finally
    FCanvas.Unlock;
  end;

  Result := maxWidth / ratio;
end;

function TfrxDrawText.LineHeight: Extended;
var
  PrnSz: Integer;
  ratio: Extended;
begin
  FCanvas.Lock;
  try
    PrnSz := -FCanvas.Font.Height;
  finally
    FCanvas.Unlock;
  end;
  ratio := FDefPPI / FScrPPI;
  Result := PrnSz / ratio + FLineSpacing;
end;

function TfrxDrawText.GetOutBoundsText: WideString;
var
  PrnSz: Integer;
  n, vl: Integer;
  ratio: Extended;
  Tag: TfrxHTMLTags;
  cl: LongInt;
begin
  Result := '';
  n := FText.Count;
  if n = 0 then Exit;

  FCanvas.Lock;
  try
    PrnSz := -FCanvas.Font.Height;
    ratio := FDefPPI / FScrPPI;

  // number of lines that will fit in the bounds
    vl := Trunc((FOriginalRect.Bottom - FOriginalRect.Top + 1) / (PrnSz / ratio + FLineSpacing));
    if vl > n then
      vl := n;

    if vl < FHTMLTags.Count then
    begin
  // deleting all outbounds text
      while FText.Count > vl do
        FText.Delete(FText.Count - 1);

      Tag := FHTMLTags[vl];
      Result := Copy(FPlainText, Tag[0].Position, Length(FPlainText) - Tag[0].Position + 1);
      if (Length(Result) > 0) and (Result[1] = ' ') then
        Delete(Result, 1, 1);
      Delete(FPlainText, Tag[0].Position, Length(FPlainText) - Tag[0].Position + 1);

      if FHTMLTags.AllowTags then
      begin
        if fsBold in Tag[0].Style then
          Result := '<b>' + Result;
        if fsItalic in Tag[0].Style then
          Result := '<i>' + Result;
        if fsUnderline in Tag[0].Style then
          Result := '<u>' + Result;
        cl := ColorToRGB(Tag[0].Color);
        cl := (cl and $00FF0000) div 65536 + (cl and $000000FF) * 65536 + (cl and $0000FF00);
        Result := '<font color="#' + IntToHex(cl, 6) + '">' + Result;
      end;
    end;
  finally
    FCanvas.Unlock;
  end;
end;

function TfrxDrawText.GetInBoundsText: WideString;
begin
  Result := FPlainText;
end;

function TfrxDrawText.IsPrinter(C: TCanvas): Boolean;
begin
  Result := C is TfrxPrinterCanvas;
end;

procedure TfrxDrawText.Lock;
begin
  while FLocked do
    Application.ProcessMessages;
  FLocked := True;
end;

procedure TfrxDrawText.Unlock;
begin
  FLocked := False;
end;

function TfrxDrawText.GetWrappedText: WideString;
begin
  Result := FText.Text;
end;

function TfrxDrawText.TextHeight: Extended;
var
  PrnSz: Integer;
  ratio: Extended;
begin
  FCanvas.Lock;
  try
    PrnSz := -FCanvas.Font.Height;
  finally
    FCanvas.Unlock;
  end;
  ratio := FDefPPI / FScrPPI;
  Result := PrnSz / ratio;
end;

initialization
  frxDrawText := TfrxDrawText.Create;


finalization
  frxDrawText.Free;


end.



//0f31356a91fea3356e5f76cdce90aa7b