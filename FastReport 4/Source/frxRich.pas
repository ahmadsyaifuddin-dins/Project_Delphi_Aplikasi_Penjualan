
{******************************************}
{                                          }
{             FastReport v4.0              }
{         RichEdit Add-In Object           }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxRich;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Forms, Menus, frxClass,
  RichEdit, frxRichEdit, frxPrinter
{$IFDEF Delphi6}
, Variants
{$ENDIF}
;


type
  TfrxRichObject = class(TComponent)  // fake component
  end;


  TfrxRichView = class(TfrxStretcheable)

  private
    FAllowExpressions: Boolean;
    FExpressionDelimiters: String;
    FFlowTo: TfrxRichView;
    FGapX: Extended;
    FGapY: Extended;
    FRichEdit: TrxRichEdit;
    FTempStream: TMemoryStream;
    FTempStream1: TMemoryStream;
    FWysiwyg: Boolean;
    function CreateMetafile: TMetafile;
    function IsExprDelimitersStored: Boolean;
    function UsePrinterCanvas: Boolean;
    procedure ReadData(Stream: TStream);
    procedure WriteData(Stream: TStream);

  protected
    procedure DefineProperties(Filer: TFiler); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended); override;
    procedure AfterPrint; override;
    procedure BeforePrint; override;
    procedure GetData; override;
    procedure InitPart; override;
    function CalcHeight: Extended; override;
    function DrawPart: Extended; override;
    class function GetDescription: String; override;
    function GetComponentText: String; override;
    property RichEdit: TrxRichEdit read FRichEdit;
  published
    property AllowExpressions: Boolean read FAllowExpressions
      write FAllowExpressions default True;
    property BrushStyle;
    property Color;
    property Cursor;
    property DataField;
    property DataSet;
    property DataSetName;
    property ExpressionDelimiters: String read FExpressionDelimiters
      write FExpressionDelimiters stored IsExprDelimitersStored;
    property FlowTo: TfrxRichView read FFlowTo write FFlowTo;
    property Frame;
    property GapX: Extended read FGapX write FGapX;
    property GapY: Extended read FGapY write FGapY;
    property TagStr;
    property URL;
    property Wysiwyg: Boolean read FWysiwyg write FWysiwyg default True;
  end;


procedure frxAssignRich(RichFrom, RichTo: TrxRichEdit);


implementation

uses 
  frxRichRTTI,
{$IFNDEF NO_EDITORS}
  frxRichEditor,
{$ENDIF}
  frxUtils, frxDsgnIntf, frxRes;


procedure frxAssignRich(RichFrom, RichTo: TrxRichEdit);
var
  st: TMemoryStream;
begin
  st := TMemoryStream.Create;
  try
    RichFrom.Lines.SaveToStream(st);
    st.Position := 0;
    RichTo.Lines.LoadFromStream(st);
  finally
    st.Free;
  end;
end;


{ TfrxRichView }

constructor TfrxRichView.Create(AOwner: TComponent);
begin
  inherited;
  FRichEdit := TrxRichEdit.Create(nil);
  FRichEdit.Parent := frxParentForm;
  SendMessage(frxParentForm.Handle, WM_CREATEHANDLE, Integer(FRichEdit), 0);
  FRichEdit.AutoURLDetect := False;
  { make rich transparent }
  SetWindowLong(FRichEdit.Handle, GWL_EXSTYLE,
    GetWindowLong(FRichEdit.Handle, GWL_EXSTYLE) or WS_EX_TRANSPARENT);

  FTempStream := TMemoryStream.Create;
  FTempStream1 := TMemoryStream.Create;

  FAllowExpressions := True;
  FExpressionDelimiters := '[,]';
  FGapX := 2;
  FGapY := 1;
  FWysiwyg := True;
end;

destructor TfrxRichView.Destroy;
begin
  SendMessage(frxParentForm.Handle, WM_DESTROYHANDLE, Integer(FRichEdit), 0);
  FRichEdit.Free;
  FTempStream.Free;
  FTempStream1.Free;
  inherited;
end;

class function TfrxRichView.GetDescription: String;
begin
  Result := frxResources.Get('obRich');
end;

function TfrxRichView.IsExprDelimitersStored: Boolean;
begin
  Result := FExpressionDelimiters <> '[,]';
end;

procedure TfrxRichView.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineBinaryProperty('RichEdit', ReadData, WriteData, True);
end;

procedure TfrxRichView.ReadData(Stream: TStream);
begin
  FRichEdit.Lines.LoadFromStream(Stream);
end;

procedure TfrxRichView.WriteData(Stream: TStream);
begin
  FRichEdit.Lines.SaveToStream(Stream);
end;

procedure TfrxRichView.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FFlowTo) then
    FFlowTo := nil;
end;

function TfrxRichView.UsePrinterCanvas: Boolean;
begin
  Result := frxPrinters.HasPhysicalPrinters and FWysiwyg;
end;

function TfrxRichView.CreateMetafile: TMetafile;
var
  Range: TFormatRange;
  EMFCanvas: TMetafileCanvas;
  PrinterHandle: THandle;
begin
  if UsePrinterCanvas then
    PrinterHandle := frxPrinters.Printer.Canvas.Handle
  else
    PrinterHandle := GetDC(0);
  FillChar(Range, SizeOf(TFormatRange), 0);

  with Range do
  begin
    rc := Rect(Round(GapX * 1440 / 96), Round(GapY * 1440 / 96),
      Round((Width - GapX) * 1440 / 96),
      Round((Height - GapY) * 1440 / 96));
    rcPage := rc;

    Result := TMetafile.Create;
    Result.Width := Round(Width * GetDeviceCaps(PrinterHandle, LOGPIXELSX) / 96);
    Result.Height := Round(Height * GetDeviceCaps(PrinterHandle, LOGPIXELSY) / 96);

    EMFCanvas := TMetafileCanvas.Create(Result, PrinterHandle);
    hdc := EMFCanvas.Handle;
    hdcTarget := hdc;

    chrg.cpMin := 0;
    chrg.cpMax := -1;
    FRichEdit.Perform(EM_FORMATRANGE, 1, Integer(@Range));
  end;

  if not UsePrinterCanvas then
    ReleaseDC(0, PrinterHandle);

  FRichEdit.Perform(EM_FORMATRANGE, 0, 0);
  EMFCanvas.Free;
end;

procedure TfrxRichView.Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX,
  OffsetY: Extended);
var
  EMF: TMetafile;
begin
  BeginDraw(Canvas, ScaleX, ScaleY, OffsetX, OffsetY);
  DrawBackground;

  EMF := CreateMetafile;
  try
    Canvas.StretchDraw(Rect(FX, FY, FX1, FY1), EMF);
  finally
    EMF.Free;
  end;

  DrawFrame;
end;

procedure TfrxRichView.BeforePrint;
begin
  inherited;
  FTempStream.Position := 0;
  FRichEdit.Lines.SaveToStream(FTempStream);
end;

procedure TfrxRichView.AfterPrint;
begin
  FTempStream.Position := 0;
  FRichEdit.Lines.LoadFromStream(FTempStream);
  inherited;
end;

procedure TfrxRichView.GetData;
var
  ss: TStringStream;
  i, j, TextLen: Integer;
  s1, s2, dc1, dc2: String;

  function GetSpecial(const s: String; Pos: Integer): Integer;
  var
    i: Integer;
  begin
    Result := 0;
    for i := 1 to Pos do
      if s[i] in [#10, #13] then
        Inc(Result);
  end;

  function PosEx(const SubStr, S: string; Offset: Cardinal = 1): Integer;
  var
    I,X: Integer;
    Len, LenSubStr: Integer;
  begin
    if Offset = 1 then
      Result := Pos(SubStr, S)
    else
    begin
      I := Offset;
      LenSubStr := Length(SubStr);
      Len := Length(S) - LenSubStr + 1;
      while I <= Len do
      begin
        if S[I] = SubStr[1] then
        begin
          X := 1;
          while (X < LenSubStr) and (S[I + X] = SubStr[X + 1]) do
            Inc(X);
          if (X = LenSubStr) then
          begin
            Result := I;
            exit;
          end;
        end;
        Inc(I);
      end;
      Result := 0;
    end;
  end;

begin
  inherited;
  if IsDataField then
  begin
    ss := TStringStream.Create(VarToStr(DataSet.Value[DataField]));
    try
      FRichEdit.Lines.LoadFromStream(ss);
    finally
      ss.Free;
    end;
  end;

  if FAllowExpressions then
  begin
    dc1 := FExpressionDelimiters;
    dc2 := Copy(dc1, Pos(',', dc1) + 1, 255);
    dc1 := Copy(dc1, 1, Pos(',', dc1) - 1);

    with FRichEdit do
    try
      Lines.BeginUpdate;

      i := Pos(dc1, Text);
      while i > 0 do
      begin
        SelStart := i - 1 - GetSpecial(Text, i) div 2;
        s1 := frxGetBrackedVariable(Text, dc1, dc2, i, j);
        s2 := VarToStr(Report.Calc(s1));

        SelLength := j - i + 1;
        TextLen := Length(Text) - SelLength;
        SelText := s2;

        i := PosEx(dc1, Text, i + Length(Text) - TextLen);
      end;
    finally
      Lines.EndUpdate;
    end;
  end;

  if FFlowTo <> nil then
  begin
    InitPart;
    DrawPart;
    FTempStream1.Position := 0;
    FlowTo.RichEdit.Lines.LoadFromStream(FTempStream1);
    FFlowTo.AllowExpressions := False;
  end;
end;

function TfrxRichView.CalcHeight: Extended;
var
  Range: TFormatRange;
begin
  FillChar(Range, SizeOf(TFormatRange), 0);
  with Range do
  begin
    rc := Rect(0, 0, Round((Width - GapX * 2) * 1440 / 96), Round(1000000 * 1440.0 / 96));
    rcPage := rc;
    if UsePrinterCanvas then
      hdc := frxPrinters.Printer.Canvas.Handle
    else
      hdc := GetDC(0);
    hdcTarget := hdc;

    chrg.cpMin := 0;
    chrg.cpMax := -1;
    FRichEdit.Perform(EM_FORMATRANGE, 0, Integer(@Range));

    if not UsePrinterCanvas then
      ReleaseDC(0, hdc);
    if RichEdit.GetTextLen = 0 then
      Result := 0
    else
      Result := Round(rc.Bottom / (1440.0 / 96)) + 2 * GapY + 2;
  end;

  FRichEdit.Perform(EM_FORMATRANGE, 0, 0);
end;

function TfrxRichView.DrawPart: Extended;
var
  Range: TFormatRange;
  LastChar: Integer;
begin
  { get remained part of text }
  FTempStream1.Position := 0;
  FRichEdit.Lines.LoadFromStream(FTempStream1);

  { calculate the last visible char }
  FillChar(Range, SizeOf(TFormatRange), 0);
  with Range do
  begin
    rc := Rect(0, 0, Round((Width - GapX * 2) * 1440 / 96),
      Round((Height - GapY * 2) * 1440 / 96));
    rcPage := rc;
    if UsePrinterCanvas then
      hdc := frxPrinters.Printer.Canvas.Handle
    else
      hdc := GetDC(0);
    hdcTarget := hdc;

    chrg.cpMin := 0;
    chrg.cpMax := -1;
    LastChar := FRichEdit.Perform(EM_FORMATRANGE, 0, Integer(@Range));
    Result := Round((rcPage.Bottom - rc.Bottom) / (1440.0 / 96)) + 2 * GapY + 0.1;

    if not UsePrinterCanvas then
      ReleaseDC(0, hdc);
  end;
  FRichEdit.Perform(EM_FORMATRANGE, 0, 0);

  { text can't fit }
  if Result < 0 then
  begin
    Result := Height;
    Exit;
  end;

  { copy the outbounds text to the temp stream }
  try
    FRichEdit.SelStart := LastChar;
    FRichEdit.SelLength := FRichEdit.GetTextLen - LastChar + 1;
    if FRichEdit.SelLength = 1 then
      Result := 0;
    FTempStream1.Clear;
    FRichEdit.StreamMode := [smSelection];
    FRichEdit.Lines.SaveToStream(FTempStream1);
    FRichEdit.SelText := '';
  finally
    FRichEdit.StreamMode := [];
  end;
end;

procedure TfrxRichView.InitPart;
begin
  FTempStream1.Clear;
  FRichEdit.Lines.SaveToStream(FTempStream1);
end;

function TfrxRichView.GetComponentText: String;
var
  FTStream: TMemoryStream;
begin
  if PlainText then
  begin
    FTStream := TMemoryStream.Create;
    try
      FTempStream.Clear;
      FRichEdit.Lines.SaveToStream(FTStream);
      FRichEdit.PlainText := True;
      FRichEdit.Lines.SaveToStream(FTempStream);
      SetLength(Result, FTempStream.Size);
      FTempStream.Position := 0;
      FTempStream.Read(Result[1], FTempStream.Size);
      FRichEdit.PlainText := False;
      FTStream.Position := 0;
      FRichEdit.Lines.LoadFromStream(FTStream);
    finally
      FTStream.Free;
    end;
  end
  else
  begin
    FTempStream.Clear;
    FRichEdit.Lines.SaveToStream(FTempStream);
    SetLength(Result, FTempStream.Size);
    FTempStream.Position := 0;
    FTempStream.Read(Result[1], FTempStream.Size);
  end;
end;




initialization
  frxObjects.RegisterObject1(TfrxRichView, nil, '', '', 0, 26);


end.


//0f31356a91fea3356e5f76cdce90aa7b