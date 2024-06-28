
{******************************************}
{                                          }
{             FastReport v4.0              }
{             PDF file library             }
{                                          }
{         Copyright (c) 1998-2006          }
{          by Alexander Fediachov,         }
{             Fast Reports Inc.            }
{******************************************}
{          Add CJK Font support by         }
{          crispin2k@hotmail.com           }
{          http://www.jane.com.tw          }
{******************************************}

unit frxPDFFile;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Forms,
  ComObj, ComCtrls, frxClass, frxUtils, JPEG, frxUnicodeUtils
{$IFDEF Delphi6}, Variants {$ENDIF};

type
  TfrxPDFPage = class;
  TfrxPDFFont = class;

  TfrxPDFElement = class(TObject)
  private
    FXrefPosition: Cardinal;
    FIndex: Integer;
    FLines: String;
    FCR: Boolean;
    procedure Write(const S: String);
    procedure WriteLn(const S: String);
    procedure Flush(const Stream: TStream);
  public
    constructor Create;
    procedure SaveToStream(const Stream: TStream); virtual;
  published
    property XrefPosition: Cardinal read FXrefPosition;
    property Index: Integer read FIndex write FIndex;
  end;

  TfrxPDFToolkit = class(TObject)
  public
    Divider: Extended;
    LineHeight: Extended;
    LastColor: TColor;
    LastColorResult: String;
    constructor Create;
    function GetHTextPos(const Left: Extended; const Width: Extended; const CharSpacing: Extended;
      const Text: String; const Align: TfrxHAlign): Extended;
    function GetVTextPos(const Top: Extended; const Height: Extended; const Text: String;
      const Align: TfrxVAlign; const Line: Integer = 0; const Count: Integer = 1): Extended;
    function GetLineWidth(const Text: String; const CharSpacing: Extended): Extended;
    procedure SetMemo(const Memo: TfrxCustomMemoView);
  end;

  TfrxPDFFile = class(TfrxPDFElement)
  private
    FPages: TList;
    FFonts: TList;
    FXRef: TStringList;
    FObjNo: Integer; 
    FCounter: Integer;
    FTitle: String;
    FStartXRef: Cardinal;
    FStartFonts: Integer;
    FStartPages: Integer;
    FPagesRoot: Integer;
    FCompressed: Boolean;
    FPrintOpt: Boolean;
    FOutline: Boolean;
    FPreviewOutline: TfrxCustomOutline;
    FSubject: String;
    FAuthor: String;
    FBackground: Boolean;
    FCreator: String;
    FHTMLTags: Boolean;
  public
    FStreamObjects: TStream;
    FTempStreamFile: String;
    FEmbedded: Boolean;
    FFontDCnt: Integer;
    PTool: TfrxPDFToolkit;
    constructor Create(const UseFileCache: Boolean; const TempDir: String);
    destructor Destroy; override;
    procedure Clear;
    procedure XRefAdd(Stream: TStream; ObjNo: Integer);  
    procedure SaveToStream(const Stream: TStream); override;
    function AddPage(const Page: TfrxReportPage): TfrxPDFPage;
    function AddFont(const Font: TFont): Integer;
  published
    property Pages: TList read FPages;
    property Fonts: TList read FFonts;
    property Counter: Integer read FCounter write FCounter;
    property Title: String read FTitle write FTitle;
    property Compressed: Boolean read FCompressed write FCompressed;
    property EmbeddedFonts: Boolean read FEmbedded write FEmbedded default True;
    property PrintOptimized: Boolean read FPrintOpt write FPrintOpt;
    property Outline: Boolean read FOutline write FOutline;
    property PreviewOutline: TfrxCustomOutline read FPreviewOutline write FPreviewOutline;
    property Author: String read FAuthor write FAuthor;
    property Subject: String read FSubject write FSubject;
    property Background: Boolean read FBackground write FBackground;
    property Creator: String read FCreator write FCreator;
    property HTMLTags: Boolean read FHTMLTags write FHTMLTags;
  end;

  TfrxPDFPage = class(TfrxPDFElement)
  private
    FStreamOffset: Longint;
    FParent: TfrxPDFFile;
    FWidth: Extended;
    FHeight: Extended;
    FMarginLeft: Extended;
    FMarginTop: Extended;
    FStream: TStream;
    FStreamSize: Longint;
  public
    constructor Create;
    procedure SaveToStream(const Stream: TStream); override;
    procedure AddObject(const Obj: TfrxView);
    property StreamOffset: Longint read FStreamOffset write FStreamOffset;
    property StreamSize: Longint read FStreamSize write FStreamSize;
  published
    property OutStream: TStream read FStream write FStream;
    property Parent: TfrxPDFFile read FParent write FParent;
    property Width: Extended read FWidth write FWidth;
    property Height: Extended read FHeight write FHeight;
    property MarginLeft: Extended read FMarginLeft write FMarginLeft;
    property MarginTop: Extended read FMarginTop write FMarginTop;
  end;

  TfrxPDFFont = class(TfrxPDFElement)
  private
    FFont: TFont;
    FParent: TfrxPDFFile;
    FFontDCnt: Integer;   
  public
    constructor Create;
    destructor Destroy; override;
    procedure SaveToStream(const Stream: TStream); override;
  published
    property Parent: TfrxPDFFile read FParent write FParent;
    property Font: TFont read FFont;
  end;

  TfrxPDFOutlineNode = class(TObject)
  public
    Title: String;
    Dest: Integer;
    Top: Integer;
    Number: Integer;
    CountTree: Integer;
    Count: Integer;
    First: TfrxPDFOutlineNode;
    Last: TfrxPDFOutlineNode;
    Parent: TfrxPDFOutlineNode;
    Prev: TfrxPDFOutlineNode;
    Next: TfrxPDFOutlineNode;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses frxGraphicUtils, frxGzip;

const
  PDF_VER = '1.3';
  PDF_DIVIDER = 0.75;
  PDF_MARG_DIVIDER = 0.05;
  PDF_PRINTOPT = 3;	// 4 change to 3

type
  PABC = ^ABCarray;
  ABCarray = array [0..255] of ABC;

function CheckOEM(const Value: String): boolean;
var
  i: integer;
begin
  result := false;
  for i := 1 to Length(Value) do
    if (ByteType(Value, i) <> mbSingleByte) or
       (Ord(Value[i]) > 122) or
       (Ord(Value[i]) < 32) then
    begin
      result := true;
      Break;
    end;
end;

function StrToUTF16(const Value: String): String;
var
  PW: Pointer;
  Len: integer;
  i: integer;
  pwc: ^Word;
begin
  result := 'FEFF';
  Len := MultiByteToWideChar(0, CP_ACP, PChar(Value), Length(Value), nil, 0);
  GetMem(PW, Len * 2);
  try
    Len := MultiByteToWideChar(0, CP_ACP, PChar(Value), Length(Value), PW, Len * 2);
    pwc := PW;
    for i := 0 to Len - 1 do
    begin
      result := result  + IntToHex(pwc^, 4);
      Inc(pwc);
    end;
  finally
    FreeMem(PW);
  end;
end;

function PrepareString(const Text: String): String;
begin
  if CheckOEM(Text) then
    Result := '<' + StrToUTF16(Text) + '>'
  else
    Result := '(' + Text + ')';
end;

{ TfrxPDFFile }

constructor TfrxPDFFile.Create(const UseFileCache: Boolean; const TempDir: String);
begin
  inherited Create;
  PTool := TfrxPDFToolkit.Create;
  FPages := TList.Create;
  FFonts := TList.Create;
  FXRef := TStringList.Create;
  FCounter := 4;
  FStartPages := 0;
  FStartXRef := 0;
  FStartFonts := 0;
  FCompressed := True;
  FPrintOpt := False;
  FOutline := False;
  FPreviewOutline := nil;
  FHTMLTags := False;
  FFontDCnt := 0;     
  FObjNo := 0;        
  if UseFileCache then
  begin
    FTempStreamFile := frxCreateTempFile(TempDir);
    FStreamObjects := TFileStream.Create(FTempStreamFile, fmCreate);
  end else
    FStreamObjects := TMemoryStream.Create;
end;

destructor TfrxPDFFile.Destroy;
begin
  Clear;
  FXRef.Free;
  FPages.Free;
  FFonts.Free;
  PTool.Free;
  FStreamObjects.Free;
  try
    DeleteFile(FTempStreamFile);
  except
  end;
  inherited;
end;

procedure TfrxPDFFile.Clear;
var
  i: Integer;
begin
  for i := 0 to FPages.Count - 1 do
    TfrxPDFPage(FPages[i]).Free;
  FPages.Clear;
  for i := 0 to FFonts.Count - 1 do
    TfrxPDFFont(FFonts[i]).Free;
  FFonts.Clear;
  FXRef.Clear;
end;

procedure TfrxPDFFile.SaveToStream(const Stream: TStream);
var
  i, j: Integer;
  s, s1: String;
  Page, Top: Integer;
  Text: String;
  Parent: Integer;
  OutlineCount: Integer;
  NodeNumber: Integer;
  OutlineTree: TfrxPDFOutlineNode;

  function DoCalcOutlineCount: Integer;
  var
    i: Integer;
  begin
    Result := FPreviewOutline.Count;
    for i := 0 to FPreviewOutline.Count - 1 do
    begin
      FPreviewOutline.LevelDown(i);
      Result := Result + DoCalcOutlineCount;
      FPreviewOutline.LevelUp;
    end;
  end;

  procedure DoPrepareOutline(Node: TfrxPDFOutlineNode);
  var
    i: Integer;
    cnt: Integer;
    p: TfrxPDFOutlineNode;
    prev: TfrxPDFOutlineNode;
  begin
    cnt := FPreviewOutline.Count;
    Node.Count := cnt;
    Node.CountTree := cnt;
    Inc(NodeNumber);
    prev := nil;
    p := nil;
    for i := 0 to cnt - 1 do
    begin
      p := TfrxPDFOutlineNode.Create;
      FPreviewOutline.GetItem(i, Text, Page, Top);
      p.Title := Text;
      p.Dest := Page;
      p.Top := Top;
      p.Prev := prev;
      if prev <> nil then
        prev.Next := p
      else
        Node.First := p;
      prev := p;
      p.Parent := Node;
      FPreviewOutline.LevelDown(i);
      DoPrepareOutline(p);
      FPreviewOutline.LevelUp;
      Node.CountTree := Node.CountTree + p.CountTree;
    end;
    Node.Last := p;
  end;

  procedure DoWriteOutline(Node: TfrxPDFOutlineNode; Parent: Integer);
  var
    p: TfrxPDFOutlineNode;
  begin
    p := Node;
    if p.Dest = -1 then
    begin
      p.Number := Parent;
    end
    else begin
      p.Number := FCounter;
      Inc(FObjNo);  
      XRefAdd(Stream, FObjNo);
      WriteLn(IntToStr(FCounter) + ' 0 obj');
      Inc(FCounter);
      WriteLn('<<');
      WriteLn('/Title ' + PrepareString(p.Title));
      WriteLn('/Parent ' + IntToStr(Parent) + ' 0 R');
      if p.Prev <> nil then
        WriteLn('/Prev ' + IntToStr(p.Prev.Number) + ' 0 R');
      if p.First <> nil then
      begin
        WriteLn('/First ' + IntToStr(p.Number + 1) + ' 0 R');
        WriteLn('/Last ' + IntToStr(p.Number + p.CountTree - p.Last.CountTree ) + ' 0 R');
        WriteLn('/Count ' + IntToStr(p.Count));
      end;
      if p.Next <> nil then
        WriteLn('/Next ' + IntToStr(p.Number + p.CountTree + 1) + ' 0 R');
      WriteLn('/Dest [' + IntToStr(FpagesRoot + FFonts.Count * FFontDCnt + p.Dest * 2 + 1) + ' 0 R /XYZ 0 ' + IntToStr(Round(TfrxPDFPage(FPages[Page]).Height - p.Top * PDF_DIVIDER)) + ' 0]');
      WriteLn('>>');
      WriteLn('endobj');
      Flush(Stream);
    end;
    if p.First <> nil then
      DoWriteOutline(p.First, p.Number);
    if p.Next <> nil then
      DoWriteOutline(p.Next, Parent);
  end;

begin
  inherited SaveToStream(Stream);
  OutlineCount := 0;
  OutlineTree := nil;
  if FOutline then
    if not Assigned(FPreviewOutline) then
      FOutline := False
    else
      FPreviewOutline.LevelRoot;
  FCounter := 1;
  s := FormatDateTime('yyyy', Now) + FormatDateTime('mm', Now) +
    FormatDateTime('dd', Now) + FormatDateTime('hh', Now) +
    FormatDateTime('nn', Now) + FormatDateTime('ss', Now);
  WriteLn('%PDF-' + PDF_VER);
  WriteLn('%'#226#227#207#211);
  Flush(Stream);
  Inc(FObjNo); 
  XRefAdd(Stream, FObjNo);
  WriteLn(IntToStr(FCounter) + ' 0 obj');
  Inc(FCounter);
  WriteLn('<<');
  WriteLn('/Type /Catalog');
  i := 0;

  if FOutline then
  begin
    OutlineTree := TfrxPDFOutlineNode.Create;
    NodeNumber := 0;
    DoPrepareOutline(OutlineTree);
    if OutlineTree.CountTree > 0 then
    begin
      OutlineCount := OutlineTree.CountTree - OutlineTree.Last.CountTree;
      i := OutlineTree.CountTree + 1;
    end else
      FOutline := False;
  end;

  FPagesRoot := FObjNo + 2 + i;
  WriteLn('/Pages ' + IntToStr(FPagesRoot) + ' 0 R');
  if FOutline then s1 := '/UseOutlines'
  else s1 := '/UseNone';
  WriteLn('/PageMode ' + s1);
  if FOutline then
    WriteLn('/Outlines ' + IntToStr(FCounter + 1) + ' 0 R');
  if Length(Title) > 0 then
    WriteLn('/ViewerPreferences << /DisplayDocTitle true >>');
  WriteLn('>>');
  WriteLn('endobj');
  Flush(Stream);
  Inc(FObjNo);  
  XRefAdd(Stream, FObjNo);
  WriteLn(IntToStr(FCounter) + ' 0 obj');
  Inc(FCounter);
  WriteLn('<<');
  WriteLn('/Producer ' + PrepareString(FCreator));
  WriteLn('/Author ' + PrepareString(FAuthor));
  WriteLn('/Subject ' + PrepareString(FSubject));
  WriteLn('/Creator ' + PrepareString(Application.Name));
  WriteLn('/Title ' + PrepareString(FTitle));
  WriteLn('/CreationDate (D:' + s + ')');
  WriteLn('/ModDate (D:' + s + ')');
  WriteLn('>>');
  WriteLn('endobj');
  Flush(Stream);
  if FOutline then
  begin
    Inc(FObjNo);
    XRefAdd(Stream, FObjNo);
    WriteLn(IntToStr(FCounter) + ' 0 obj');
    Parent := FCounter;
    Inc(FCounter);
    FPreviewOutline.LevelRoot;
    WriteLn('<<');
    WriteLn('/Count ' + IntToStr(FPreviewOutline.Count));
    WriteLn('/First ' + IntToStr(FCounter) + ' 0 R');
    WriteLn('/Last ' + IntToStr(FCounter + OutlineCount - 1) + ' 0 R');
    WriteLn('>>');
    WriteLn('endobj');
    Flush(Stream);
    DoWriteOutline(OutlineTree, Parent);
    OutlineTree.Free;
    FCounter := FCounter + FPreviewOutline.Count;
  end;
  FStartFonts := FObjNo;
  Inc(FObjNo);
  for i := 0 to FFonts.Count - 1 do
    TfrxPDFFont(FFonts[i]).SaveToStream(Stream);

  FStartPages := FObjNo + 1;

  for i := 0 to FPages.Count - 1 do
  begin
    TfrxPDFPage(FPages[FPages.Count - 1]).StreamSize := FStreamObjects.Size - TfrxPDFPage(FPages[FPages.Count - 1]).StreamOffset;
    TfrxPDFPage(FPages[i]).SaveToStream(Stream);
  end;

  Flush(Stream);
  XRefAdd(Stream, FPagesRoot);
  WriteLn(IntToStr(FPagesRoot) + ' 0 obj');
  WriteLn('<<');
  WriteLn('/Type /Pages');
  Write('/Kids [');
  for i := 0 to FPages.Count - 1 do
    Write(IntToStr(FStartPages + i * 2) + ' 0 R ');
  WriteLn(']');
  WriteLn('/Count ' + IntToStr(FPages.Count));
  WriteLn('>>');
  WriteLn('endobj');
  Flush(Stream);
  FStartXRef := Stream.Position;
  WriteLn('xref');
  WriteLn('0 ' + IntToStr(FXRef.Count + 1));
  WriteLn('0000000000 65535 f');

  for i := 1 to FXRef.Count do
  begin
    j := FXRef.IndexOfObject(TObject(i));
    WriteLn(FXRef.Strings[j] + ' 00000 n');
  end;

  WriteLn('trailer');
  WriteLn('<<');
  WriteLn('/Size ' + IntToStr(FXref.Count + 1));
  WriteLn('/Root 1 0 R');
  WriteLn('/Info 2 0 R');
  WriteLn('>>');
  WriteLn('startxref');
  WriteLn(IntToStr(FStartXRef));
  WriteLn('%%EOF');
  Flush(Stream);
end;

procedure TfrxPDFFile.XRefAdd(Stream: TStream; ObjNo: Integer);
begin
  FXRef.AddObject(StringOfChar('0',  10 - Length(IntToStr(Stream.Position))) + IntToStr(Stream.Position), TObject(ObjNo));
end;

function TfrxPDFFile.AddFont(const Font: TFont): Integer;
var
  Font2: TfrxPDFFont;
  i, j: Integer;
begin
  j := -1;
  for i := 0 to FFonts.Count - 1 do
  begin
    Font2 := TfrxPDFFont(FFonts[i]);
    if (Font2.Font.Name = Font.Name) and
       (Font2.Font.Style = Font.Style) and
       (Font2.Font.Charset = Font.Charset) then
    begin
      j := i;
      break;
    end;
  end;
  if j = -1 then
  begin
    Font2 := TfrxPDFFont.Create;
    Font2.Parent := Self;
    Font2.Font.Assign(Font);
    FFonts.Add(Font2);
    j := FFonts.Count - 1;
    Font2.Index := j + 1     
  end;
  Result := j;
end;

function TfrxPDFFile.AddPage(const Page: TfrxReportPage): TfrxPDFPage;
var
  PDFPage: TfrxPDFPage;
begin
  PDFPage := TfrxPDFPage.Create;
  PDFPage.Width := Page.Width * PDF_DIVIDER;
  PDFPage.Height := Page.Height * PDF_DIVIDER;
  PDFPage.MarginLeft := Page.LeftMargin * PDF_MARG_DIVIDER;
  PDFPAge.MarginTop := Page.TopMargin * PDF_MARG_DIVIDER;
  PDFPage.Parent := Self;
  PDFPage.OutStream := FStreamObjects;
  PDFPage.StreamOffset := FStreamObjects.Position;
  if FPages.Count > 0 then
    TfrxPDFPage(FPages[FPages.Count - 1]).StreamSize := FStreamObjects.Position -
      TfrxPDFPage(FPages[FPages.Count - 1]).StreamOffset;
  FPages.Add(PDFPage);
  PDFPage.Index := FPages.Count;
  Result := PDFPage;
  if FEmbedded then
    FFontDCnt := 3
  else FFontDCnt := 2;
end;

{ TfrxPDFPage }

constructor TfrxPDFPage.Create;
begin
  inherited;
  FMarginLeft := 0;
  FMarginTop := 0;
end;

procedure TfrxPDFPage.SaveToStream(const Stream: TStream);
var
  i: Integer;
  s: String;
  TmpPageStream: TMemoryStream;
  TmpPageStream2: TMemoryStream;
begin
  inherited SaveToStream(Stream);
  Flush(Stream);
  Inc(Parent.FObjNo);  
  Parent.XRefAdd(Stream, Parent.FObjNo);
  WriteLn(IntToStr(Parent.FFontDCnt + Parent.FStartFonts + (Index-1) * 2) + ' 0 obj');  
  WriteLn('<<');
  WriteLn('/Type /Page');
  WriteLn('/Parent ' + IntToStr(Parent.FPagesRoot) + ' 0 R');
  WriteLn('/MediaBox [0 0 ' + frFloat2Str(FWidth) + ' ' + frFloat2Str(FHeight) + ' ]');
  WriteLn('/Resources <<');
  WriteLn('/Font <<');
  for i := 0 to Parent.FFonts.Count - 1 do
    WriteLn('/F' + IntToStr(TfrxPDFFont(Parent.FFonts[i]).Index - 1) + ' ' +
      IntToStr(TfrxPDFFont(Parent.FFonts[i]).FFontDCnt + Parent.FStartFonts) + ' 0 R');   
  WriteLn('>>');
  WriteLn('/XObject <<');
  WriteLn('>>');
  WriteLn('/ProcSet [/PDF /Text /ImageC ]');
  WriteLn('>>');
  WriteLn('/Contents ' + IntToStr(Parent.FFontDCnt + Parent.FStartFonts + (Index-1) * 2 + 1) + ' 0 R');
  WriteLn('>>');
  WriteLn('endobj');
  Flush(Stream);
  Inc(Parent.FObjNo); 
  Parent.XRefAdd(Stream, Parent.FObjNo);
  WriteLn(IntToStr(Parent.FFontDCnt + Parent.FStartFonts + (Index-1) * 2 + 1) + ' 0 obj');  
  Write('<< ');
  TmpPageStream := TMemoryStream.Create;
  TmpPageStream2 := TMemoryStream.Create;
  try
    OutStream.Position := FStreamOffset;
    TmpPageStream2.CopyFrom(OutStream, FStreamSize);
    if Parent.FCompressed then
    begin
      frxDeflateStream(TmpPageStream2, TmpPageStream, gzFastest);
      s := '/Filter /FlateDecode /Length ' + IntToStr(TmpPageStream.Size) +
        ' /Length1 ' + IntToStr(TmpPageStream2.Size);
    end
    else
      s := '/Length ' + IntToStr(TmpPageStream2.Size);
    WriteLn(s + ' >>');
    WriteLn('stream');
    Flush(Stream);
    if Parent.FCompressed then
    begin
      Stream.CopyFrom(TmpPageStream, 0);
      WriteLn('');
    end else
      Stream.CopyFrom(TmpPageStream2, 0);
  finally
    TmpPageStream2.Free;
    TmpPageStream.Free;
  end;
  WriteLn('endstream');
  WriteLn('endobj');
  Flush(Stream);
end;

procedure TfrxPDFPage.AddObject(const Obj: TfrxView);
var
  FontIndex: Integer;
  x, y, dx, dy, fdx, fdy, PGap, FCharSpacing: Extended;
  i, iz: Integer;
  Jpg: TJPEGImage;
  s: String;
  Lines: TStrings;
  TempBitmap: TBitmap;
  OldFrameWidth: Extended;
  TempColor: TColor;
  Left, Right, Top, Bottom, Width, Height, BWidth, BHeight: String;
  FUnderlineSize: Double;
  FRealBounds: TfrxRect;

  function GetLeft(const Left: Extended): Extended; register;
  begin
    Result := FMarginLeft + Left * PDF_DIVIDER
  end;

  function GetTop(const Top: Extended): Extended; register;
  begin
    Result := FHeight - (FMarginTop + Top * PDF_DIVIDER)
  end;

  function GetPDFColor(const Color: TColor): String;
  var
    TheRgbValue : TColorRef;
  begin
    if Color = clBlack then
      Result := '0 0 0'
    else if Color = clWhite then
      Result := '1 1 1'
    else if Color = Parent.PTool.LastColor then
      Result := Parent.PTool.LastColorResult
    else begin
      TheRgbValue := ColorToRGB(Color);
      Result := frFloat2Str(GetRValue(TheRGBValue) / 255) + ' ' +
        frFloat2Str(GetGValue(TheRGBValue) / 255) + ' ' +
        frFloat2Str(GetBValue(TheRGBValue) / 255);
      Parent.PTool.LastColor := Color;
      Parent.PTool.LastColorResult := Result;
    end;
  end;

  procedure MakeUpFrames;
  begin
    if (Obj.Frame.Typ <> []) and (Obj.Frame.Color <> clNone) then
    begin
      WriteLn(GetPDFColor(Obj.Frame.Color) + ' RG');
      WriteLn(frFloat2Str(Obj.Frame.Width * PDF_DIVIDER) + ' w');
      if Obj.Frame.Typ = [ftTop, ftRight, ftBottom, ftLeft] then
      begin
        WriteLn(Left + ' ' + Top + ' m');
        WriteLn(Right + ' ' + Top + ' l');
        WriteLn(Right + ' ' + Bottom + ' l');
        WriteLn(Left + ' ' + Bottom + ' l');
        WriteLn(Left + ' ' + Top + ' l');
        WriteLn('s')
      end else
      begin
        if ftTop in Obj.Frame.Typ then
        begin
          WriteLn(Left + ' ' + Top + ' m');
          WriteLn(Right + ' ' + Top + ' l');
          WriteLn('S')
        end;
        if ftRight in Obj.Frame.Typ then
        begin
          WriteLn(Right + ' ' + Top + ' m');
          WriteLn(Right + ' ' + Bottom + ' l');
          WriteLn('S')
        end;
        if ftBottom in Obj.Frame.Typ then
        begin
          WriteLn(Left + ' ' + Bottom + ' m');
          WriteLn(Right + ' ' + Bottom + ' l');
          WriteLn('S')
        end;
        if ftLeft in Obj.Frame.Typ then
        begin
          WriteLn(Left + ' ' + Top + ' m');
          WriteLn(Left + ' ' + Bottom + ' l');
          WriteLn('S')
        end;
      end;
    end;
  end;

  function HTMLTags(const View: TfrxCustomMemoView): Boolean;
  var
    f: Boolean;
  begin
    f := View.AllowHTMLTags;
    if f then
    begin
      Result := FParent.HTMLTags and
        (Pos('<' ,View.Memo.Text) > 0) and
        (Pos('>' ,View.Memo.Text) > 0);
    end else
      Result := False;
  end;
function InStr(Source, SubStr: string; StartPos: integer): integer;
var
  Index, Len1, Len2, Len: integer;
begin
  Result := 0;
  Len1 := Length(Source);
  Len2 := Length(SubStr);
  Len := Len1 - Len2 + 1;
  for Index := StartPos to Len do
    if Copy(Source, Index, Len2) = SubStr then
    begin
       Result := Index;
       break;
    end;
end;

function StringReplace(Source, OldStr, NewStr: string): string;
var
  nPos, nLen : integer;
begin
  nPos := Pos( OldStr, Source );
  nLen := Length( OldStr );
  while(nPos > 0) do
  begin
    Delete( Source, nPos, nLen );
    Insert( NewStr, Source, nPos );
    nPos := InStr(Source, OldStr, nPos+Length(NewStr)+1);
  end;
  Result := Source;
end;
  function TruncReturns(const Str: string): string;
  var
    l: Integer;
  begin
    Result := Str;
    l := Length(Result);
    if (Result[l - 1] = #13) and (Result[l] = #10) then
      Delete(Result, l - 2, 2);
    Result := StringReplace(Result, #1, '');
  end;

  function CheckOutPDFChars(const Str: string): string;
  begin
    Result := StringReplace(Str, '\', '\\');
    Result := StringReplace(Result, '(', '\(');
    Result := StringReplace(Result, ')', '\)');
  end;

  function Str2RTL(const Str: String): String;
  var
    b, i, l: Integer;
    s: String;
    t, f: Boolean;
  begin
    Result := frxReverseString(Str);
    l := Length(Result);
    i := 1;
    b := 1;
    f := False;
    while i <= l do
    begin
      if Result[i] = '(' then
        Result[i] := ')'
      else if Result[i] = ')' then
        Result[i] := '('
      else if Result[i] = '[' then
        Result[i] := ']'
      else if Result[i] = ']' then
        Result[i] := '[';
      t := not ((Ord(Result[i]) > 32) and (Ord(Result[i]) < 122));
      if (t and f) then
      begin
        s := Copy(Result, b, i - b);
        Delete(Result, b, i - b);
        s := frxReverseString(s);
        Insert(s, Result, b);
        f := False;
      end;
      if not (t or f) then
      begin
        b := i;
        f := True;
      end;
      i := i + 1;
    end;
  end;

begin
  Left := frFloat2Str(GetLeft(Obj.AbsLeft));
  Top := frFloat2Str(GetTop(Obj.AbsTop));
  Right := frFloat2Str(GetLeft(Obj.AbsLeft + Obj.Width));
  Bottom := frFloat2Str(GetTop(Obj.AbsTop + Obj.Height));
  Width := frFloat2Str(Obj.Width * PDF_DIVIDER);
  Height := frFloat2Str(Obj.Height * PDF_DIVIDER);

  OldFrameWidth := 0;
  // Text
  if (Obj is TfrxCustomMemoView) and (TfrxCustomMemoView(Obj).Rotation = 0) and
     (TfrxCustomMemoView(Obj).BrushStyle in [bsSolid, bsClear]) and
     (not HTMLTags(TfrxCustomMemoView(Obj))) then
  begin
    // save clip to stack
    WriteLn('q');
    // set clipping path for the memo
    Write(frFloat2Str(GetLeft(Obj.AbsLeft - Obj.Frame.Width)) + ' ' + frFloat2Str(GetTop(Obj.AbsTop + Obj.Height + Obj.Frame.Width)) + ' ');
    WriteLn(frFloat2Str((Obj.Width + Obj.Frame.Width * 2)* PDF_DIVIDER) + ' ' +
      frFloat2Str((Obj.Height + Obj.Frame.Width * 2) * PDF_DIVIDER) + ' re');
    WriteLn('W');
    WriteLn('n');
    // Shadow
    if Obj.Frame.DropShadow then
    begin
      Obj.Width := Obj.Width - Obj.Frame.ShadowWidth;
      Obj.Height := Obj.Height - Obj.Frame.ShadowWidth;
      Width := frFloat2Str(Obj.Width * PDF_DIVIDER);
      Height := frFloat2Str(Obj.Height * PDF_DIVIDER);
      Right := frFloat2Str(GetLeft(Obj.AbsLeft + Obj.Width));
      Bottom := frFloat2Str(GetTop(Obj.AbsTop + Obj.Height));
      s := GetPDFColor(Obj.Frame.ShadowColor);
      WriteLn(s + ' rg');
      WriteLn(s + ' RG');
      Write(frFloat2Str(GetLeft(Obj.AbsLeft + Obj.Width)) + ' ' +
        frFloat2Str(GetTop(Obj.AbsTop + Obj.Height + Obj.Frame.ShadowWidth)) + ' ');
      WriteLn(frFloat2Str(Obj.Frame.ShadowWidth * PDF_DIVIDER) + ' ' +
        frFloat2Str(Obj.Height * PDF_DIVIDER) + ' re');
      WriteLn('B');
      Write(frFloat2Str(GetLeft(Obj.AbsLeft + Obj.Frame.ShadowWidth)) + ' ' +
        frFloat2Str(GetTop(Obj.AbsTop + Obj.Height + Obj.Frame.ShadowWidth)) + ' ');
      WriteLn(frFloat2Str(Obj.Width * PDF_DIVIDER) + ' ' +
        frFloat2Str(Obj.Frame.ShadowWidth * PDF_DIVIDER) + ' re');
      WriteLn('B');
    end;
    if TfrxCustomMemoView(Obj).Highlight.Active and
       Assigned(TfrxCustomMemoView(Obj).Highlight.Font) then
    begin
      Obj.Font.Assign(TfrxCustomMemoView(Obj).Highlight.Font);
      Obj.Color := TfrxCustomMemoView(Obj).Highlight.Color;
    end;
    if Obj.Color <> clNone then
    begin
      WriteLn(GetPDFColor(Obj.Color) + ' rg');
      Write(Left + ' ' + Bottom + ' ');
      WriteLn(Width + ' ' + Height + ' re');
      WriteLn('f');
    end;
    // Frames
    MakeUpFrames;
    Lines := TStringList.Create;
    Lines.Text := TfrxCustomMemoView(Obj).WrapText(True);
    if Lines.Count > 0 then
    begin
      FontIndex := Parent.AddFont(Obj.Font);
      WriteLn('/F' + IntToStr(TfrxPDFFont(Parent.FFonts[FontIndex]).Index - 1) +
        ' ' + IntToStr(Obj.Font.Size) + ' Tf');
      if Obj.Font.Color <> clNone then
        TempColor := Obj.Font.Color
      else
        TempColor := clBlack;
      WriteLn(GetPDFColor(TempColor) + ' rg');
      FCharSpacing := TfrxCustomMemoView(Obj).CharSpacing * PDF_DIVIDER;
      if TfrxCustomMemoView(Obj).CharSpacing <> 0 then
        WriteLn(frFloat2Str(FCharSpacing) + ' Tc');
      Parent.PTool.SetMemo(TfrxCustomMemoView(Obj));
      // output lines of memo
      FUnderlineSize := Obj.Font.Size * 0.12;
      for i := 0 to Lines.Count - 1 do
      begin
        if i = 0 then
          PGap := TfrxCustomMemoView(Obj).ParagraphGap
        else
          PGap := 0;
        if TfrxCustomMemoView(Obj).RTLReading then
          s := CheckOutPDFChars(Str2RTL(TruncReturns(Lines[i])))
        else
          s := CheckOutPDFChars(TruncReturns(Lines[i]));
        if Length(Trim(s)) > 0 then
        begin
          // Text output
          WriteLn('BT');
          if TfrxCustomMemoView(Obj).HAlign <> haRight then
            FCharSpacing := 0;
          x := FCharSpacing + GetLeft(Parent.PTool.GetHTextPos(Obj.AbsLeft +
             TfrxCustomMemoView(Obj).GapX + PGap,
             Obj.Width - TfrxCustomMemoView(Obj).GapX * 2 -
             PGap, TfrxCustomMemoView(Obj).CharSpacing, Lines[i], TfrxCustomMemoView(Obj).HAlign));
          y := GetTop(Parent.PTool.GetVTextPos(Obj.AbsTop +
               TfrxCustomMemoView(Obj).GapY - 1,
               Obj.Height - TfrxCustomMemoView(Obj).GapY * 2,
               Lines[i], TfrxCustomMemoView(Obj).VAlign, i, Lines.Count));
          WriteLn(frFloat2Str(x) + ' ' + frFloat2Str(y) + ' Td');
          WriteLn('(' + s + ') Tj');
          WriteLn('ET');
          // set Underline
          if fsUnderline in (TfrxCustomMemoView(Obj).Font.Style) then
          begin
            WriteLn(GetPDFColor(Obj.Font.Color) + ' RG');
            WriteLn(frFloat2Str(Obj.Font.Size * 0.08) + ' w');
            WriteLn(frFloat2Str(x) + ' ' + frFloat2Str(y - FUnderlineSize) + ' m');
            WriteLn(frFloat2Str(x + Parent.PTool.GetLineWidth(Lines[i], TfrxCustomMemoView(Obj).CharSpacing) * PDF_DIVIDER) +
              ' ' + frFloat2Str(y - FUnderlineSize) + ' l');
            WriteLn('S')
          end;
        end;
      end;
    end;
    // restore clip
    WriteLn('Q');
    Lines.Free;
  end
  // Lines
  else if Obj is TfrxCustomLineView then
  begin
    WriteLn(GetPDFColor(Obj.Frame.Color) + ' RG');
    WriteLn(frFloat2Str(Obj.Frame.Width * PDF_DIVIDER) + ' w');
    WriteLn(Left + ' ' + Top + ' m');
    WriteLn(Right + ' ' + Bottom + ' l');
    WriteLn('S')
  end
  // Rects
  else if (Obj is TfrxShapeView) and (TfrxShapeView(Obj).Shape = skRectangle) then
  begin
    WriteLn(GetPDFColor(Obj.Frame.Color) + ' RG');
    WriteLn(frFloat2Str(Obj.Frame.Width * PDF_DIVIDER) + ' w');
    WriteLn(GetPDFColor(Obj.Color) + ' rg');
    Write(Left + ' ' + Bottom + ' ');
    WriteLn(Width + ' ' + Height + ' re');
    WriteLn('B');
  end
  // Shape line 1
  else if (Obj is TfrxShapeView) and (TfrxShapeView(Obj).Shape = skDiagonal1) then
  begin
    WriteLn(GetPDFColor(Obj.Frame.Color) + ' RG');
    WriteLn(frFloat2Str(Obj.Frame.Width * PDF_DIVIDER) + ' w');
    WriteLn(Left + ' ' + Bottom + ' m');
    WriteLn(Right + ' ' + Top + ' l');
    WriteLn('S')
  end
  // Shape line 2
  else if (Obj is TfrxShapeView) and (TfrxShapeView(Obj).Shape = skDiagonal2) then
  begin
    WriteLn(GetPDFColor(Obj.Frame.Color) + ' RG');
    WriteLn(frFloat2Str(Obj.Frame.Width * PDF_DIVIDER) + ' w');
    WriteLn(Left + ' ' + Top + ' m');
    WriteLn(Right + ' ' + Bottom + ' l');
    WriteLn('S')
  end
  else
  // Bitmaps
  if not ((Obj.Name = '_pagebackground') and (not Parent.Background)) and
     (Obj.Height > 0) and (Obj.Width > 0) then
  begin
    if Obj.Frame.Width > 0 then
    begin
      OldFrameWidth := Obj.Frame.Width;
      Obj.Frame.Width := 0;
    end;

    FRealBounds := Obj.GetRealBounds;
    dx := FRealBounds.Right - FRealBounds.Left;
    dy := FRealBounds.Bottom - FRealBounds.Top;

    if (dx = Obj.Width) or (Obj.AbsLeft = FRealBounds.Left) then
      fdx := 0
    else if (Obj.AbsLeft + Obj.Width) = FRealBounds.Right then
      fdx := (dx - Obj.Width)
    else
      fdx := (dx - Obj.Width) / 2;

    if (dy = Obj.Height) or (Obj.AbsTop = FRealBounds.Top) then
      fdy := 0
    else if (Obj.AbsTop + Obj.Height) = FRealBounds.Bottom then
      fdy := (dy - Obj.Height)
    else
      fdy := (dy - Obj.Height) / 2;

    TempBitmap := TBitmap.Create;
    TempBitmap.PixelFormat := pf24bit;

    if (Parent.PrintOptimized or (Obj is TfrxCustomMemoView)) and (Obj.BrushStyle in [bsSolid, bsClear]) then
      i := PDF_PRINTOPT
    else i := 1;

    iz := 0;

    if (Obj.ClassName = 'TfrxBarCodeView') and not Parent.PrintOptimized then
    begin
      i := 2;
      iz := i;
    end;

    TempBitmap.Width := Round(dx * i) + i;
    TempBitmap.Height := Round(dy * i) + i;

    Obj.Draw(TempBitmap.Canvas, i, i, -Round((Obj.AbsLeft - fdx) * i) + iz, -Round((Obj.AbsTop - fdy)* i));
    WriteLn('q');

    if dx <> 0 then
      BWidth := frFloat2Str(dx * PDF_DIVIDER)
    else
      BWidth := '1';
    if dy <> 0 then
      BHeight := frFloat2Str(dy * PDF_DIVIDER)
    else
      BHeight := '1';

    WriteLn(BWidth + ' 0 0 ' + BHeight + ' ' +
      frFloat2Str(GetLeft(Obj.AbsLeft - fdx)) + ' ' +
      frFloat2Str(GetTop(Obj.AbsTop - fdy + dy)) + ' cm');
    WriteLn('BI');
    WriteLn('/W ' + IntToStr(TempBitmap.Width));
    WriteLn('/H ' + IntToStr(TempBitmap.Height));
    WriteLn('/CS /RGB');
    WriteLn('/BPC 8');
    WriteLn('/I true');
    WriteLn('/F [/DCT]');
    WriteLn('ID');
    Flush(OutStream);

    Jpg := TJPEGImage.Create;

    if (Obj.ClassName = 'TfrxBarCodeView') or
       (Obj is TfrxCustomLineView) or
       (Obj is TfrxShapeView) then
    begin
      Jpg.PixelFormat := jf8Bit;
      Jpg.CompressionQuality := 85;
    end
    else begin
      Jpg.PixelFormat := jf24Bit;
      Jpg.CompressionQuality := 80;
    end;

    Jpg.Assign(TempBitmap);
    Jpg.SaveToStream(OutStream);
    Jpg.Free;

    WriteLn('');
    WriteLn('EI');
    WriteLn('Q');
    TempBitmap.Free;
    if OldFrameWidth > 0 then
      Obj.Frame.Width := OldFrameWidth;
    MakeUpFrames;
  end;
  Flush(OutStream);
end;

{ TfrxPDFFont }

constructor TfrxPDFFont.Create;
begin
  inherited;
  FFont := TFont.Create;
end;

destructor TfrxPDFFont.Destroy;
begin
  FFont.Free;
  inherited;
end;

procedure TfrxPDFFont.SaveToStream(const Stream: TStream);
var
  s: String;
  b: TBitmap;
  pm: ^OUTLINETEXTMETRIC;
  FontName: String;
  i: Cardinal;
  pfont: PChar;
  FirstChar, LastChar : Integer;
  MemStream: TMemoryStream;
  MemStream1: TMemoryStream;
  pwidths: PABC;
  Charset: TFontCharSet;

  // support DBCS font name encoding
  function EncodeFontName(AFontName: String): string;
  var
    s: string;
    Index, Len: Integer;
  begin
    s := '';
    Len := Length(AFontName);
    Index := 0;
    while Index < Len do
    begin
      Index := Index + 1;
      if Byte(AFontName[Index]) > $7F then
        s := s + '#' + IntToHex(Byte(AFontName[Index]), 2)
      else
        s := s + AFontname[Index];
    end;
    Result := s;
  end;

  function PrepareFontName(const Font: TFont): String;
  begin
    Result := StringReplace(Font.Name, ' ', '#20', [rfReplaceAll]);
    s := '';
    if fsBold in Font.Style then
      s := s + 'Bold';
    if fsItalic in Font.Style then
      s := s + 'Italic';
    if s <> '' then
      Result := Result + ',' + s;
    Result := EncodeFontName(Result);
  end;

begin
  inherited SaveToStream(Stream);
  b := TBitmap.Create;
  try
    b.Canvas.Lock;
    b.Canvas.Font.Assign(Font);
    b.Canvas.Font.PixelsPerInch := 96;
    b.Canvas.Font.Size := 750;
    i := GetOutlineTextMetrics(b.Canvas.Handle, 0, nil);
    if i = 0 then
    begin
      b.Canvas.Font.Name := 'Arial';
      i := GetOutlineTextMetrics(b.Canvas.Handle, 0, nil);
    end;
    if i <> 0 then
    begin
      pm := GlobalAllocPtr(GMEM_MOVEABLE or GMEM_SHARE, i);
      try
        if pm <> nil then
          i := GetOutlineTextMetrics(b.Canvas.Handle, i, pm)
        else
          i := 0;
        if i <> 0 then
        begin
          FirstChar := Ord(pm.otmTextMetrics.tmFirstChar);
          LastChar := Ord(pm.otmTextMetrics.tmLastChar);

          FontName := PrepareFontName(b.Canvas.Font);

          Charset := pm.otmTextMetrics.tmCharSet;
          FFontDCnt := Parent.FFontDCnt;  
          Flush(Stream);
          Inc(Parent.FObjNo); 
          Parent.XRefAdd(Stream, Parent.FObjNo);
          WriteLn(IntToStr(Parent.FFontDCnt + Parent.FStartFonts) + ' 0 obj');  
          Parent.FFontDCnt := Parent.FFontDCnt + 1; 
          WriteLn('<<');
          WriteLn('/Type /Font');
          WriteLn('/Name /F' + IntToStr(Index - 1));
          WriteLn('/BaseFont /' + FontName);

          if not (Charset in [CHINESEBIG5_CHARSET, GB2312_CHARSET,SHIFTJIS_CHARSET,HANGEUL_CHARSET]) then
            WriteLn('/Subtype /TrueType')
          else
            WriteLn('/Subtype /Type0');

          case Charset of
            SYMBOL_CHARSET:
              WriteLn('/Encoding /MacRomanEncoding');

            ANSI_CHARSET:
              WriteLn('/Encoding /WinAnsiEncoding');

            RUSSIAN_CHARSET: {1251}
            begin
              WriteLn('/Encoding <</Type/Encoding /BaseEncoding /WinAnsiEncoding');
              Write('/Differences [129 /afii10052');
              Write('/quotesinglbase/afii10100/quotedblbase/ellipsis/dagger/daggerdbl/Euro/perthousand/afii10058/guilsinglleft/afii10059/afii10061/afii10060/afii10145/afii10099/quoteleft');
              Write('/quoteright/quotedblleft/quotedblright/bullet/endash/emdash/space/trademark/afii10106/guilsinglright/afii10107/afii10109/afii10108/afii10193/space/afii10062');
              Write('/afii10110/afii10057/currency/afii10050/brokenbar/section/afii10023/copyright/afii10053/guillemotleft/logicalnot/hyphen/registered/afii10056/degree/plusminus');
              Write('/afii10055/afii10103/afii10098/mu/paragraph/periodcentered/afii10071/afii61352/afii10101/guillemotright/afii10105/afii10054/afii10102/afii10104/afii10017/afii10018');
              Write('/afii10019/afii10020/afii10021/afii10022/afii10024/afii10025/afii10026/afii10027/afii10028/afii10029/afii10030/afii10031/afii10032/afii10033/afii10034/afii10035');
              Write('/afii10036/afii10037/afii10038/afii10039/afii10040/afii10041/afii10042/afii10043/afii10044/afii10045/afii10046/afii10047/afii10048/afii10049/afii10065/afii10066');
              Write('/afii10067/afii10068/afii10069/afii10070/afii10072/afii10073/afii10074/afii10075/afii10076/afii10077/afii10078/afii10079/afii10080/afii10081/afii10082/afii10083');
              WriteLn('/afii10084/afii10085/afii10086/afii10087/afii10088/afii10089/afii10090/afii10091/afii10092/afii10093/afii10094/afii10095/afii10096/afii10097/space]');
              WriteLn('>>');
            end;

            EASTEUROPE_CHARSET: {1250}
            begin
              WriteLn('/Encoding <</Type/Encoding /BaseEncoding /WinAnsiEncoding');
              Write('/Differences [128 /Euro 140 /Sacute /Tcaron /Zcaron /Zacute');
              Write(' 156 /sacute /tcaron /zcaron /zacute 161 /caron /breve /Lslash');
              Write(' 165 /Aogonek 170 /Scedilla 175 /Zdotaccent 178 /ogonek /lslash');
              Write(' 185 /aogonek /scedilla 188 /Lcaron /hungarumlaut /lcaron /zdotaccent /Racute');
              Write(' 195 /Abreve 197 /Lacute /Cacute 200 /Ccaron 202 /Eogonek 204 /Ecaron 207 /Dcaron /Dslash');
              Write(' 209 /Nacute /Ncaron /Oacute 213 /Ohungarumlaut 216 /Rcaron /Uring 219 /Uhungarumlaut');
              Write(' 222 /Tcedilla 224 /racute 227 /abreve 229 /lacute /cacute /ccedilla /ccaron');
              Write(' 234 /eogonek 236 /ecaron 239 /dcaron /dmacron /nacute /ncaron 245 /ohungarumlaut');
              Write(' 248 /rcaron /uring 251 /uhungarumlaut 254 /tcedilla /dotaccent]');
              WriteLn('>>');
            end;

            GREEK_CHARSET: {1253}
            begin
              WriteLn('/Encoding <</Type/Encoding /BaseEncoding /WinAnsiEncoding');
              Write('/Differences [ 128 /Euro 160 /quoteleft/quoteright 175 /afii00208');
              Write(' 180 /tonos/dieresistonos/Alphatonos');
              Write(' 184 /Epsilontonos/Etatonos/Iotatonos');
              Write(' 188 /Omicrontonos 190 /Upsilontonos');
              Write('/Omegatonos/iotadieresistonos/Alpha/Beta/Gamma/Delta/Epsilon/Zeta');
              Write('/Eta/Theta/Iota/Kappa/Lambda/Mu/Nu/Xi/Omicron/Pi/Rho');
              Write(' 211 /Sigma/Tau/Upsilon/Phi');
              Write('/Chi/Psi/Omega/Iotadieresis/Upsilondieresis/alphatonos/epsilontonos');
              Write('/etatonos/iotatonos/upsilondieresistonos/alpha/beta/gamma/delta/epsilon');
              Write('/zeta/eta/theta/iota/kappa/lambda/mu/nu/xi/omicron/pi/rho/sigma1/sigma');
              Write('/tau/upsilon/phi/chi/psi/omega/iotadieresis/upsilondieresis/omicrontonos');
              Write('/upsilontonos/omegatonos ]');
              WriteLn('>>');
            end;

            TURKISH_CHARSET: {1254}
            begin
              WriteLn('/Encoding <</Type/Encoding /BaseEncoding /WinAnsiEncoding');
              Write('/Differences [ 128 /Euro');
              Write(' 130 /quotesinglbase/florin/quotedblbase/ellipsis/dagger');
              Write(' /daggerdbl/circumflex/perthousand/Scaron/guilsinglleft/OE');
              Write(' 145 /quoteleft/quoteright/quotedblleft/quotedblright');
              Write(' /bullet/endash/emdash/tilde/trademark/scaron/guilsinglright/oe');
              Write(' 159 /Ydieresis 208 /Gbreve 221 /Idotaccent/Scedilla');
              Write(' 240 /gbreve 253 /dotlessi/scedilla]');
              WriteLn('>>');
            end;

            HEBREW_CHARSET: {1255}
            begin
              WriteLn('/Encoding <</Type/Encoding /BaseEncoding /WinAnsiEncoding');
              Write('/Differences [ 128 /Euro 130 /quotesinglbase/florin/quotedblbase/ellipsis');
              Write(' /dagger/daggerdbl/circumflex/perthousand 139 /guilsinglleft');
              Write(' 145 /quoteleft/quoteright/quotedblleft/quotedblright');
              Write(' /bullet/endash/emdash/tilde/trademark 155 /perthousand');
              Write(' 164 /afii57636 170 /multiply 186 /divide');
              Write(' 192 /afii57799/afii57801/afii57800/afii57802/afii57793');
              Write(' /afii57794/afii57795/afii57798/afii57797/afii57806');
              Write(' 203 /afii57796/afii57807/afii57839/afii57645/afii57841/afii57842');
              Write(' /afii57804/afii57803/afii57658/afii57716/afii57717/afii57718');
              Write(' 224 /afii57664/afii57665/afii57666/afii57667/afii57668/afii57669');
              Write(' /afii57670/afii57671/afii57672/afii57673/afii57674/afii57675');
              Write(' /afii57676/afii57677/afii57678/afii57679/afii57680/afii57681');
              Write(' /afii57682/afii57683/afii57684/afii57685/afii57686/afii57687');
              Write(' /afii57688/afii57689/afii57690 253 /afii299/afii300]');
              WriteLn('>>');
            end;

            ARABIC_CHARSET:
            begin
              WriteLn('/Encoding <</Type/Encoding /BaseEncoding /WinAnsiEncoding');
              Write('/Differences [ 128 /Euro/afii57506/quotesinglbase/florin/quotedblbase');
              Write('/ellipsis/dagger/daggerdbl/circumflex/perthousand/afii57511');
              Write('/guilsinglleft/OE/afii57507/afii57508');
              Write(' 144 /afii57509/quoteleft/quoteright/quotedblleft');
              Write('/quotedblright/bullet/endash/emdash');
              Write(' 153 /trademark/afii57513/guilsinglright/oe/afii61664');
              Write('/afii301/afii57514 161 /afii57388');
              Write(' 186 /afii57403 191 /afii57407');
              Write(' 193 /afii57409/afii57410/afii57411/afii57412/afii57413');
              Write('/afii57414/afii57415/afii57416/afii57417/afii57418/afii57419');
              Write('/afii57420/afii57421/afii57422/afii57423/afii57424/afii57425');
              Write('/afii57426/afii57427/afii57428/afii57429/afii57430');
              Write(' 216 /afii57431/afii57432/afii57433/afii57434/afii57440');
              Write('/afii57441/afii57442/afii57443/afii57444');
              Write(' 227 /afii57445/afii57446/afii57470/afii57448/afii57449');
              Write('/afii57450 240 /afii57451/afii57452/afii57453/afii57454');
              Write('/afii57455/afii57456 248 /afii57457 250 /afii57458');
              Write(' 253 /afii299/afii300/afii57519]');
              WriteLn('>>');
            end;

            BALTIC_CHARSET:
            begin
              WriteLn('/Encoding <</Type/Encoding /BaseEncoding /WinAnsiEncoding');
              Write('/Differences [ 128 /Euro /space /quotesinglbase /space /quotedblbase');
              Write(' /ellipsis /dagger /daggerdbl /space /perthousand');
              Write(' /space /guilsinglleft /space /dieresis /caron');
              Write(' /cedilla /space /quoteleft /quoteright /quotedblleft');
              Write(' /quotedblright /bullet /endash /emdash /space /trademark');
              Write(' /space /guilsinglright /space /macron /ogonek /space');
              Write(' 170 /Rcommaaccent 175 /AE 184 /oslash 186 /rcommaaccent');
              Write(' 191 /ae /Aogonek /Iogonek /Amacron /Cacute 198 /Eogonek');
              Write(' /Emacron /Ccaron 202 /Zacute /Edotaccent /Gcommaaccent');
              Write(' /Kcommaaccent /Imacron /Lcommaaccent /Scaron /Nacute');
              Write(' /Ncommaaccent /trademark /Omacron 216 /Uogonek /Lslash');
              Write(' /Sacute /Umacron 221 /Zdotaccent /Zcaron 224 /aogonek');
              Write(' /iogonek /amacron /cacute 230 /eogonek /emacron /ccaron');
              Write(' 234 /zacute /edotaccent /gcommaaccent /kcommaaccent');
              Write(' /imacron /lcommaaccent /scaron /nacute /ncommaaccent');
              Write(' 244 /omacron 248 /uogonek /lslash /OE /umacron 253');
              Write(' /zdotaccent /zcaron /dotaccent ]');
              WriteLn('>>');
            end;

            VIETNAMESE_CHARSET:
            begin
              WriteLn('/Encoding <</Type/Encoding /BaseEncoding /WinAnsiEncoding');
              Write('/Differences [128 /Euro 142 /Zcaron 158 /zcaron]');
              WriteLn('>>');
            end;

            CHINESEBIG5_CHARSET: {136}
            begin
              WriteLn('/DescendantFonts [' + IntToStr(Parent.FFontDCnt + Parent.FStartFonts) + ' 0 R]');  
              WriteLn('/Encoding /ETenms-B5-H');
              WriteLn('>>');
              WriteLn('endobj');
              Flush(Stream);
              Inc(Parent.FObjNo); 
              Parent.XRefAdd(Stream, Parent.FObjNo);
              
              WriteLn(IntToStr(Parent.FFontDCnt + Parent.FStartFonts) + ' 0 obj');  
              Parent.FFontDCnt := Parent.FFontDCnt + 1; 
              WriteLn('<<');
              WriteLn('/Type /Font');
              WriteLn('/Subtype');
              WriteLn('/CIDFontType2');
              WriteLn('/BaseFont /'+ EncodeFontName(FontName));
              WriteLn('/WinCharSet 136');
              WriteLn('/FontDescriptor ' + IntToStr(Parent.FFontDCnt + Parent.FStartFonts) + ' 0 R');  
              WriteLn('/CIDSystemInfo');
              WriteLn('<<');
              WriteLn('/Registry(Adobe)');
              WriteLn('/Ordering(CNS1)');
              WriteLn('/Supplement 0');
              WriteLn('>>');
              WriteLn('/DW 1000');
              WriteLn('/W [1 95 500]');
              WriteLn('>>');
              WriteLn('endobj');
              Flush(Stream);
              Inc(Parent.FObjNo); 
              Parent.XRefAdd(Stream, Parent.FObjNo);
              
              WriteLn(IntToStr(Parent.FFontDCnt + Parent.FStartFonts) + ' 0 obj');  
              Parent.FFontDCnt := Parent.FFontDCnt + 1; 
              WriteLn('<<');
              WriteLn('/Type /FontDescriptor');
              if Parent.FEmbedded then
                 WriteLn('/FontFile2 ' + IntToStr(Parent.FFontDCnt + Parent.FStartFonts) + ' 0 R');  
              WriteLn('/FontName /' + EncodeFontName(FontName));
              WriteLn('/Flags 7');
              WriteLn('/FontBBox [' + IntToStr(pm^.otmrcFontBox.Left) + ' '+ IntToStr(pm^.otmrcFontBox.Bottom) + ' '+ IntToStr(pm^.otmrcFontBox.Right) + ' '+ IntToStr(pm^.otmrcFontBox.Top) + ' ]');
              WriteLn('/Style << /Panose <010502020300000000000000> >>');
              WriteLn('/Ascent ' + IntToStr(pm^.otmAscent));
              WriteLn('/Descent ' + IntToStr(pm^.otmDescent));
              WriteLn('/CapHeight ' + IntToStr(pm^.otmTextMetrics.tmHeight));
              WriteLn('/StemV ' + IntToStr(50 + Round(sqr(pm^.otmTextMetrics.tmWeight / 65))));
              WriteLn('/ItalicAngle ' + IntToStr(pm^.otmItalicAngle));
              WriteLn('>>');
              WriteLn('endobj');
            end;
            GB2312_CHARSET: {134}
            begin
              WriteLn('/DescendantFonts [' + IntToStr(Parent.FFontDCnt + Parent.FStartFonts) + ' 0 R]');  
              WriteLn('/Encoding /GB-EUC-H');
              WriteLn('>>');
              WriteLn('endobj');
              Flush(Stream);
              Inc(Parent.FObjNo); 
              Parent.XRefAdd(Stream, Parent.FObjNo);
              
              WriteLn(IntToStr(Parent.FFontDCnt + Parent.FStartFonts) + ' 0 obj');  
              Parent.FFontDCnt := Parent.FFontDCnt + 1; 
              WriteLn('<<');
              WriteLn('/Type /Font');
              WriteLn('/Subtype');
              WriteLn('/CIDFontType2');
              WriteLn('/BaseFont /'+ EncodeFontName(FontName));
              WriteLn('/WinCharSet 134');
              WriteLn('/FontDescriptor ' + IntToStr(Parent.FFontDCnt + Parent.FStartFonts) + ' 0 R');  
              WriteLn('/CIDSystemInfo');
              WriteLn('<<');
              WriteLn('/Registry(Adobe)');
              WriteLn('/Ordering(GB1)');
              WriteLn('/Supplement 2');
              WriteLn('>>');
              WriteLn('/DW 1000');
              WriteLn('/W [ 1 95 500 814 939 500 7712 [ 500 ] 7716 [ 500 ] ]');
              WriteLn('>>');
              WriteLn('endobj');
              Flush(Stream);
              Inc(Parent.FObjNo); 
              Parent.XRefAdd(Stream, Parent.FObjNo);

              WriteLn(IntToStr(Parent.FFontDCnt + Parent.FStartFonts) + ' 0 obj');  
              Parent.FFontDCnt := Parent.FFontDCnt + 1; 
              WriteLn('<<');
              WriteLn('/Type /FontDescriptor');
              if Parent.FEmbedded then
                 WriteLn('/FontFile2 ' + IntToStr(Parent.FFontDCnt + Parent.FStartFonts) + ' 0 R');  
              WriteLn('/FontName /' + EncodeFontName(FontName));
              WriteLn('/Flags 6');
              WriteLn('/FontBBox [' + IntToStr(pm^.otmrcFontBox.Left) + ' '+ IntToStr(pm^.otmrcFontBox.Bottom) + ' '+ IntToStr(pm^.otmrcFontBox.Right) + ' '+ IntToStr(pm^.otmrcFontBox.Top) + ' ]');
              WriteLn('/Style << /Panose <010502020400000000000000> >>');
              WriteLn('/Ascent ' + IntToStr(pm^.otmAscent));
              WriteLn('/Descent ' + IntToStr(pm^.otmDescent));
              WriteLn('/CapHeight ' + IntToStr(pm^.otmTextMetrics.tmHeight));
              WriteLn('/StemV ' + IntToStr(50 + Round(sqr(pm^.otmTextMetrics.tmWeight / 65))));
              WriteLn('/ItalicAngle ' + IntToStr(pm^.otmItalicAngle));
              WriteLn('>>');
              WriteLn('endobj');
            end;
            SHIFTJIS_CHARSET: {80}
            begin
              WriteLn('/DescendantFonts [' + IntToStr(Parent.FFontDCnt + Parent.FStartFonts) + ' 0 R]');  
              WriteLn('/Encoding /90msp-RKSJ-H');
              WriteLn('>>');
              WriteLn('endobj');
              Flush(Stream);
              Inc(Parent.FObjNo); 
              Parent.XRefAdd(Stream, Parent.FObjNo);
              
              WriteLn(IntToStr(Parent.FFontDCnt + Parent.FStartFonts) + ' 0 obj');  
              Parent.FFontDCnt := Parent.FFontDCnt + 1; 
              WriteLn('<<');
              WriteLn('/Type /Font');
              WriteLn('/Subtype');
              WriteLn('/CIDFontType2');
              WriteLn('/BaseFont /'+ EncodeFontName(FontName));
              WriteLn('/WinCharSet 80');
              Write('/FontDescriptor ' + IntToStr(Parent.FFontDCnt + Parent.FStartFonts) + ' 0 R');  
              WriteLn('/CIDSystemInfo');
              WriteLn('<<');
              WriteLn('/Registry(Adobe)');
              WriteLn('/Ordering(Japan1)');
              WriteLn('/Supplement 2');
              WriteLn('>>');
              WriteLn('/DW 1000');
              WriteLn('/W [ 1 95 500 231 632 500 ]');
              WriteLn('>>');
              WriteLn('endobj');
              Flush(Stream);
              Inc(Parent.FObjNo); 
              Parent.XRefAdd(Stream, Parent.FObjNo);

              WriteLn(IntToStr(Parent.FFontDCnt + Parent.FStartFonts) + ' 0 obj'); 
              Parent.FFontDCnt := Parent.FFontDCnt + 1; 
              WriteLn('<<');
              WriteLn('/Type /FontDescriptor');
              if Parent.FEmbedded then
                WriteLn('/FontFile2 ' + IntToStr(Parent.FFontDCnt + Parent.FStartFonts) + ' 0 R');  
              WriteLn('/FontName /' + EncodeFontName(FontName));
              WriteLn('/Flags 6');
              WriteLn('/FontBBox [' + IntToStr(pm^.otmrcFontBox.Left) + ' '+ IntToStr(pm^.otmrcFontBox.Bottom) + ' '+ IntToStr(pm^.otmrcFontBox.Right) + ' '+ IntToStr(pm^.otmrcFontBox.Top) + ' ]');
              WriteLn('/Style << /Panose <010502020400000000000000> >>');
              WriteLn('/Ascent ' + IntToStr(pm^.otmAscent));
              WriteLn('/Descent ' + IntToStr(pm^.otmDescent));
              WriteLn('/CapHeight ' + IntToStr(pm^.otmTextMetrics.tmHeight));
              WriteLn('/StemV ' + IntToStr(50 + Round(sqr(pm^.otmTextMetrics.tmWeight / 65))));
              WriteLn('/ItalicAngle ' + IntToStr(pm^.otmItalicAngle));
              WriteLn('>>');
              WriteLn('endobj');
            end;
            HANGEUL_CHARSET: {129}
            begin
              WriteLn('/DescendantFonts [' + IntToStr(Index + 1 + Parent.FStartFonts) + ' 0 R]');  
              WriteLn('/Encoding /KSCms-UHC-H');
              WriteLn('>>');
              WriteLn('endobj');
              Flush(Stream);
              Inc(Parent.FObjNo);
              Parent.XRefAdd(Stream, Parent.FObjNo);
              
              WriteLn(IntToStr(Parent.FFontDCnt + Parent.FStartFonts) + ' 0 obj');  
              Parent.FFontDCnt := Parent.FFontDCnt + 1; 
              WriteLn('<<');
              WriteLn('/Type /Font');
              WriteLn('/Subtype');
              WriteLn('/CIDFontType2');
              WriteLn('/BaseFont /'+ EncodeFontName(FontName));
              WriteLn('/WinCharSet 129');
              Write('/FontDescriptor '+ IntToStr(Parent.FFontDCnt + Parent.FStartFonts) + ' 0 R'); 
              WriteLn('/CIDSystemInfo');
              WriteLn('<<');
              WriteLn('/Registry(Adobe)');
              WriteLn('/Ordering(Korea1)');
              WriteLn('/Supplement 1');
              WriteLn('>>');
              WriteLn('/DW 1000');
              WriteLn('/W [ 1 95 500 8094 8190 500 ]');
              WriteLn('>>');
              WriteLn('endobj');
              Flush(Stream);
              Inc(Parent.FObjNo); 
              Parent.XRefAdd(Stream, Parent.FObjNo);
              
              WriteLn(IntToStr(Parent.FFontDCnt + Parent.FStartFonts) + ' 0 obj');  
              Parent.FFontDCnt := Parent.FFontDCnt + 1; 
              WriteLn('<<');
              WriteLn('/Type /FontDescriptor ');
              if Parent.FEmbedded then
                 WriteLn('/FontFile2 ' + IntToStr(Parent.FFontDCnt + Parent.FStartFonts) + ' 0 R');  
              WriteLn('/FontName /' + EncodeFontName(FontName));
              WriteLn('/Flags 6');
              WriteLn('/FontBBox [' + IntToStr(pm^.otmrcFontBox.Left) + ' '+ IntToStr(pm^.otmrcFontBox.Bottom) + ' '+ IntToStr(pm^.otmrcFontBox.Right) + ' '+ IntToStr(pm^.otmrcFontBox.Top) + ' ]');
              WriteLn('/Style << /Panose <010502020400000000000000> >>');
              WriteLn('/Ascent ' + IntToStr(pm^.otmAscent));
              WriteLn('/Descent ' + IntToStr(pm^.otmDescent));
              WriteLn('/CapHeight ' + IntToStr(pm^.otmTextMetrics.tmHeight));
              WriteLn('/StemV ' + IntToStr(50 + Round(sqr(pm^.otmTextMetrics.tmWeight / 65))));
              WriteLn('/ItalicAngle ' + IntToStr(pm^.otmItalicAngle));
              WriteLn('>>');
              WriteLn('endobj');
            end;
          end;

          if not (Charset in [CHINESEBIG5_CHARSET, GB2312_CHARSET,SHIFTJIS_CHARSET,HANGEUL_CHARSET]) then
          begin
            WriteLn('/FontDescriptor ' + IntToStr(Parent.FFontDCnt + Parent.FStartFonts) + ' 0 R');  
            WriteLn('/FirstChar ' + IntToStr(FirstChar));
            WriteLn('/LastChar ' + IntToStr(LastChar));
            pwidths := GlobalAllocPtr(GMEM_MOVEABLE or GMEM_SHARE, SizeOf(ABCArray));
            try
              Write('/Widths [');
              GetCharABCWidths(b.Canvas.Handle, FirstChar, LastChar, pwidths^);
              for i := 0 to (LastChar - FirstChar) do
                Write(IntToStr(pwidths^[i].abcA + Integer(pwidths^[i].abcB) + pwidths^[i].abcC) + ' ');
              WriteLn(']');
            finally
              GlobalFreePtr(pwidths);
            end;
            WriteLn('>>');
            WriteLn('endobj');
            Flush(Stream);
            Inc(Parent.FObjNo);
            Parent.XRefAdd(Stream, Parent.FObjNo);
            WriteLn(IntToStr(Parent.FFontDCnt + Parent.FStartFonts) + ' 0 obj');
            Parent.FFontDCnt := Parent.FFontDCnt + 1;
            WriteLn('<<');
            WriteLn('/Type /FontDescriptor');
            WriteLn('/FontName /' + FontName);
            WriteLn('/Flags 32');
            WriteLn('/FontBBox [' + IntToStr(pm^.otmrcFontBox.Left) + ' '+ IntToStr(pm^.otmrcFontBox.Bottom) + ' '+ IntToStr(pm^.otmrcFontBox.Right) + ' '+ IntToStr(pm^.otmrcFontBox.Top) + ' ]');
            WriteLn('/ItalicAngle ' + IntToStr(pm^.otmItalicAngle));
            WriteLn('/Ascent ' + IntToStr(pm^.otmAscent));
            WriteLn('/Descent ' + IntToStr(pm^.otmDescent));
            WriteLn('/Leading ' + IntToStr(pm^.otmTextMetrics.tmInternalLeading));
            WriteLn('/CapHeight ' + IntToStr(pm^.otmTextMetrics.tmHeight));
//            WriteLn('/XHeight ' + IntToStr(pm^.otmsXHeight));
            WriteLn('/StemV ' + IntToStr(50 + Round(sqr(pm^.otmTextMetrics.tmWeight / 65))));
            WriteLn('/AvgWidth ' + IntToStr(pm^.otmTextMetrics.tmAveCharWidth));
            WriteLn('/MaxWidth ' + IntToStr(pm^.otmTextMetrics.tmMaxCharWidth));
            WriteLn('/MissingWidth ' + IntToStr(pm^.otmTextMetrics.tmAveCharWidth));
            if Parent.FEmbedded then
              WriteLn('/FontFile2 ' + IntToStr(Parent.FFontDCnt + Parent.FStartFonts) + ' 0 R');
            WriteLn('>>');
            WriteLn('endobj');
          end;

          if Parent.FEmbedded then
          begin
            Flush(Stream);
            Inc(Parent.FObjNo);
            Parent.XRefAdd(Stream, Parent.FObjNo);
            WriteLn(IntToStr(Parent.FFontDCnt + Parent.FStartFonts) + ' 0 obj');
            Parent.FFontDCnt := Parent.FFontDCnt + 1;
            i := GetFontData(b.Canvas.Handle, 0, 0, nil, 1);
            pfont := GlobalAllocPtr(GMEM_MOVEABLE or GMEM_SHARE, i);
            try
              i := GetFontData(b.Canvas.Handle, 0, 0, pfont, i);
              MemStream := TMemoryStream.Create;
              try
                MemStream.Write(pfont^, i);
                MemStream1 := TMemoryStream.Create;
                try
                  frxDeflateStream(MemStream, MemStream1, gzMax);
                  WriteLn('<< /Length ' + IntToStr(MemStream1.Size) + ' /Filter /FlateDecode /Length1 ' + IntToStr(MemStream.Size) + ' >>');
                  WriteLn('stream');
                  Flush(Stream);
                  Stream.CopyFrom(MemStream1, 0);
                finally
                  MemStream1.Free;
                end;
              finally
                MemStream.Free;
              end;
            finally
              GlobalFreePtr(pfont);
            end;
            WriteLn('');
            WriteLn('endstream');
            WriteLn('endobj');
          end;
        end;
        Flush(Stream);
      finally
        GlobalFreePtr(pm);
      end;
    end
    else
      Exception.Create('Error on get font info');
  finally
    b.Canvas.Unlock;
    b.Free;
  end;
end;

{ TfrxPDFElement }

constructor TfrxPDFElement.Create;
begin
  FIndex := 0;
  FXrefPosition := 0;
  FCR := False;
  FLines := '';
end;

procedure TfrxPDFElement.Write(const S: String);
begin
  FLines := FLines + S;
end;

procedure TfrxPDFElement.WriteLn(const S: String);
begin
  FLines := FLines + S + #13#10;
end;

procedure TfrxPDFElement.Flush(const Stream: TStream);
begin
  Stream.Write(FLines[1], Length(FLines));
  FLines := '';
end;


procedure TfrxPDFElement.SaveToStream(const Stream: TStream);
begin
  FXrefPosition := Stream.Position;
end;

{ TfrxPDFToolkit }

constructor TfrxPDFToolkit.Create;
begin
  Divider := frxDrawText.DefPPI / frxDrawText.ScrPPI;
  LastColor := clBlack;
  LastColorResult := '0 0 0';
end;

function TfrxPDFToolkit.GetHTextPos(const Left: Extended; const Width: Extended;
  const CharSpacing: Extended; const Text: String; const Align: TfrxHAlign): Extended;
var
  FWidth: Extended;
begin
  if (Align = haLeft) or (Align = haBlock) then
    Result := Left
  else begin
    FWidth := frxDrawText.Canvas.TextWidth(Text) / Divider + Length(Text) * CharSpacing;
    if Align = haCenter then
      Result := Left + (Width - FWidth) / 2
    else
      Result := Left + Width - FWidth;
  end;
end;

function TfrxPDFToolkit.GetLineWidth(const Text: String; const CharSpacing: Extended): Extended;
var
  FWidth: Extended;
begin
  frxDrawText.Lock;
  try
    FWidth := frxDrawText.Canvas.TextWidth(Text) / Divider + Length(Text) * CharSpacing;
  finally
    frxDrawText.UnLock;
  end;
  Result := FWidth;
end;

function TfrxPDFToolkit.GetVTextPos(const Top: Extended; const Height: Extended;
  const Text: String; const Align: TfrxVAlign; const Line: Integer = 0;
  const Count: Integer = 1): Extended;
var
  i: Integer;
begin
  if Line <= Count then
    i := Line
  else
    i := 0;
  if Align = vaBottom then
    Result := Top + Height - LineHeight * (Count - i - 1)
  else if Align = vaCenter then
    Result := Top + (Height - (LineHeight * Count)) / 2 + LineHeight * (i + 1)
  else
    Result := Top + (LineHeight * i) + frxDrawText.TextHeight;
end;

procedure TfrxPDFToolkit.SetMemo(const Memo: TfrxCustomMemoView);
begin
  frxDrawText.SetFont(Memo.Font);
  frxDrawText.SetGaps(0, 0, Memo.LineSpacing);
  LineHeight := frxDrawText.LineHeight;
end;

{ TfrxPDFOutlineNode }

constructor TfrxPDFOutlineNode.Create;
begin
  Title := '';
  Dest := -1;
  Number := 0;
  Count := 0;
  CountTree :=0;
  Parent := nil;
  First := nil;
  Prev := nil;
  Next := nil;
  Last := nil;
end;

destructor TfrxPDFOutlineNode.Destroy;
begin
  if Next <> nil then
    Next.Free;
  if First <> nil then
    First.Free;
  inherited;
end;

end.

