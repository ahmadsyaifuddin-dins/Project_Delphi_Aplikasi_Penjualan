
{******************************************}
{                                          }
{             FastReport v4.0              }
{                 Printer                  }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxPrinter;

interface

{$I frx.inc}

uses 
  Windows, SysUtils, Classes, Graphics, Forms, Printers
{$IFDEF Delphi6}
, Variants
{$ENDIF};


type
  TfrxPrinterCanvas = class;

  TfrxCustomPrinter = class(TObject)
  private
    FBin: Integer;
    FBins: TStrings;
    FCanvas: TfrxPrinterCanvas;
    FDefOrientation: TPrinterOrientation;
    FDefPaper: Integer;
    FDefPaperHeight: Extended;
    FDefPaperWidth: Extended;
    FDPI: TPoint;
    FFileName: String;
    FHandle: THandle;
    FInitialized: Boolean;
    FName: String;
    FPaper: Integer;
    FPapers: TStrings;
    FPaperHeight: Extended;
    FPaperWidth: Extended;
    FLeftMargin: Extended;
    FTopMargin: Extended;
    FRightMargin: Extended;
    FBottomMargin: Extended;
    FOrientation: TPrinterOrientation;
    FPort: String;
    FPrinting: Boolean;
    FTitle: String;
  public
    constructor Create(const AName, APort: String); virtual;
    destructor Destroy; override;
    procedure Init; virtual; abstract;
    procedure Abort; virtual; abstract;
    procedure BeginDoc; virtual; abstract;
    procedure BeginPage; virtual; abstract;
    procedure BeginRAWDoc; virtual; abstract;
    procedure EndDoc; virtual; abstract;
    procedure EndPage; virtual; abstract;
    procedure EndRAWDoc; virtual; abstract;
    procedure WriteRAWDoc(const buf: String); virtual; abstract;

    function BinIndex(ABin: Integer): Integer;
    function PaperIndex(APaper: Integer): Integer;
    function BinNameToNumber(const ABin: String): Integer;
    function PaperNameToNumber(const APaper: String): Integer;
    procedure SetViewParams(APaperSize: Integer;
      APaperWidth, APaperHeight: Extended;
      AOrientation: TPrinterOrientation); virtual; abstract;
    procedure SetPrintParams(APaperSize: Integer;
      APaperWidth, APaperHeight: Extended; AOrientation: TPrinterOrientation;
      ABin, ADuplex, ACopies: Integer); virtual; abstract;
    procedure PropertiesDlg; virtual; abstract;

    property Bin: Integer read FBin;
    property Bins: TStrings read FBins;
    property Canvas: TfrxPrinterCanvas read FCanvas;
    property DefOrientation: TPrinterOrientation read FDefOrientation;
    property DefPaper: Integer read FDefPaper;
    property DefPaperHeight: Extended read FDefPaperHeight;
    property DefPaperWidth: Extended read FDefPaperWidth;
    property DPI: TPoint read FDPI;
    property FileName: String read FFileName write FFileName;
    property Handle: THandle read FHandle;
    property Name: String read FName;
    property Paper: Integer read FPaper;
    property Papers: TStrings read FPapers;
    property PaperHeight: Extended read FPaperHeight;
    property PaperWidth: Extended read FPaperWidth;
    property LeftMargin: Extended read FLeftMargin;
    property TopMargin: Extended read FTopMargin;
    property RightMargin: Extended read FRightMargin;
    property BottomMargin: Extended read FBottomMargin;
    property Orientation: TPrinterOrientation read FOrientation;
    property Port: String read FPort;
    property Title: String read FTitle write FTitle;
  end;

  TfrxVirtualPrinter = class(TfrxCustomPrinter)
  public
    procedure Init; override;
    procedure Abort; override;
    procedure BeginDoc; override;
    procedure BeginPage; override;
    procedure BeginRAWDoc; override;
    procedure EndDoc; override;
    procedure EndPage; override;
    procedure EndRAWDoc; override;
    procedure WriteRAWDoc(const buf: String); override;
    procedure SetViewParams(APaperSize: Integer;
      APaperWidth, APaperHeight: Extended;
      AOrientation: TPrinterOrientation); override;
    procedure SetPrintParams(APaperSize: Integer;
      APaperWidth, APaperHeight: Extended; AOrientation: TPrinterOrientation;
      ABin, ADuplex, ACopies: Integer); override;
    procedure PropertiesDlg; override;
  end;

  TfrxPrinter = class(TfrxCustomPrinter)
  private
    FDeviceMode: THandle;
    FDC: HDC;
    FDriver: String;
    FMode: PDeviceMode;
    procedure CreateDevMode;
    procedure FreeDevMode;
    procedure GetDC;
    procedure RecreateDC;
  public
    destructor Destroy; override;
    procedure Init; override;
    procedure Abort; override;
    procedure BeginDoc; override;
    procedure BeginPage; override;
    procedure BeginRAWDoc; override;
    procedure EndDoc; override;
    procedure EndPage; override;
    procedure EndRAWDoc; override;
    procedure WriteRAWDoc(const buf: String); override;
    procedure SetViewParams(APaperSize: Integer;
      APaperWidth, APaperHeight: Extended;
      AOrientation: TPrinterOrientation); override;
    procedure SetPrintParams(APaperSize: Integer;
      APaperWidth, APaperHeight: Extended; AOrientation: TPrinterOrientation;
      ABin, ADuplex, ACopies: Integer); override;
    procedure PropertiesDlg; override;
    procedure UpdateDeviceCaps;
    property DeviceMode: PDeviceMode read FMode;
  end;


  TfrxPrinters = class(TObject)
  private
    FHasPhysicalPrinters: Boolean;
    FPrinters: TStrings;
    FPrinterIndex: Integer;
    FPrinterList: TList;
    function GetDefaultPrinter: String;
    function GetItem(Index: Integer): TfrxCustomPrinter;
    function GetCurrentPrinter: TfrxCustomPrinter;
    procedure SetPrinterIndex(Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    function IndexOf(AName: String): Integer;
    procedure Clear;
    procedure FillPrinters;
    property Items[Index: Integer]: TfrxCustomPrinter read GetItem; default;
    property HasPhysicalPrinters: Boolean read FHasPhysicalPrinters;
    property Printer: TfrxCustomPrinter read GetCurrentPrinter;
    property PrinterIndex: Integer read FPrinterIndex write SetPrinterIndex;
    property Printers: TStrings read FPrinters;
  end;

  TfrxPrinterCanvas = class(TCanvas)
  private
    FPrinter: TfrxCustomPrinter;
    procedure UpdateFont;
  public
    procedure Changing; override;
  end;


function frxPrinters: TfrxPrinters;
function frxGetPaperDimensions(PaperSize: Integer; var Width, Height: Extended): Boolean;


implementation

uses frxUtils, WinSpool, Dialogs, frxRes;


type
  TPaperInfo = packed record
    Typ: Integer;
    Name: String;
    X, Y: Integer;
  end;


const
  PAPERCOUNT = 66;
  PaperInfo: array[0..PAPERCOUNT - 1] of TPaperInfo = (
    (Typ:1;  Name: ''; X:2159; Y:2794),
    (Typ:2;  Name: ''; X:2159; Y:2794),
    (Typ:3;  Name: ''; X:2794; Y:4318),
    (Typ:4;  Name: ''; X:4318; Y:2794),
    (Typ:5;  Name: ''; X:2159; Y:3556),
    (Typ:6;  Name: ''; X:1397; Y:2159),
    (Typ:7;  Name: ''; X:1842; Y:2667),
    (Typ:8;  Name: ''; X:2970; Y:4200),
    (Typ:9;  Name: ''; X:2100; Y:2970),
    (Typ:10; Name: ''; X:2100; Y:2970),
    (Typ:11; Name: ''; X:1480; Y:2100),
    (Typ:12; Name: ''; X:2500; Y:3540),
    (Typ:13; Name: ''; X:1820; Y:2570),
    (Typ:14; Name: ''; X:2159; Y:3302),
    (Typ:15; Name: ''; X:2150; Y:2750),
    (Typ:16; Name: ''; X:2540; Y:3556),
    (Typ:17; Name: ''; X:2794; Y:4318),
    (Typ:18; Name: ''; X:2159; Y:2794),
    (Typ:19; Name: ''; X:984;  Y:2254),
    (Typ:20; Name: ''; X:1048; Y:2413),
    (Typ:21; Name: ''; X:1143; Y:2635),
    (Typ:22; Name: ''; X:1207; Y:2794),
    (Typ:23; Name: ''; X:1270; Y:2921),
    (Typ:24; Name: ''; X:4318; Y:5588),
    (Typ:25; Name: ''; X:5588; Y:8636),
    (Typ:26; Name: ''; X:8636; Y:11176),
    (Typ:27; Name: ''; X:1100; Y:2200),
    (Typ:28; Name: ''; X:1620; Y:2290),
    (Typ:29; Name: ''; X:3240; Y:4580),
    (Typ:30; Name: ''; X:2290; Y:3240),
    (Typ:31; Name: ''; X:1140; Y:1620),
    (Typ:32; Name: ''; X:1140; Y:2290),
    (Typ:33; Name: ''; X:2500; Y:3530),
    (Typ:34; Name: ''; X:1760; Y:2500),
    (Typ:35; Name: ''; X:1760; Y:1250),
    (Typ:36; Name: ''; X:1100; Y:2300),
    (Typ:37; Name: ''; X:984;  Y:1905),
    (Typ:38; Name: ''; X:920;  Y:1651),
    (Typ:39; Name: ''; X:3778; Y:2794),
    (Typ:40; Name: ''; X:2159; Y:3048),
    (Typ:41; Name: ''; X:2159; Y:3302),
    (Typ:42; Name: ''; X:2500; Y:3530),
    (Typ:43; Name: ''; X:1000; Y:1480),
    (Typ:44; Name: ''; X:2286; Y:2794),
    (Typ:45; Name: ''; X:2540; Y:2794),
    (Typ:46; Name: ''; X:3810; Y:2794),
    (Typ:47; Name: ''; X:2200; Y:2200),
    (Typ:50; Name: ''; X:2355; Y:3048),
    (Typ:51; Name: ''; X:2355; Y:3810),
    (Typ:52; Name: ''; X:2969; Y:4572),
    (Typ:53; Name: ''; X:2354; Y:3223),
    (Typ:54; Name: ''; X:2101; Y:2794),
    (Typ:55; Name: ''; X:2100; Y:2970),
    (Typ:56; Name: ''; X:2355; Y:3048),
    (Typ:57; Name: ''; X:2270; Y:3560),
    (Typ:58; Name: ''; X:3050; Y:4870),
    (Typ:59; Name: ''; X:2159; Y:3223),
    (Typ:60; Name: ''; X:2100; Y:3300),
    (Typ:61; Name: ''; X:1480; Y:2100),
    (Typ:62; Name: ''; X:1820; Y:2570),
    (Typ:63; Name: ''; X:3220; Y:4450),
    (Typ:64; Name: ''; X:1740; Y:2350),
    (Typ:65; Name: ''; X:2010; Y:2760),
    (Typ:66; Name: ''; X:4200; Y:5940),
    (Typ:67; Name: ''; X:2970; Y:4200),
    (Typ:68; Name: ''; X:3220; Y:4450));


var
  FPrinters: TfrxPrinters = nil;


function frxGetPaperDimensions(PaperSize: Integer; var Width, Height: Extended): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to PAPERCOUNT - 1 do
    if PaperInfo[i].Typ = PaperSize then
    begin
      Width := PaperInfo[i].X / 10;
      Height := PaperInfo[i].Y / 10;
      Result := True;
      break;
    end;
end;


{ TfrxPrinterCanvas }

procedure TfrxPrinterCanvas.Changing;
begin
  inherited;
  UpdateFont;
end;

procedure TfrxPrinterCanvas.UpdateFont;
var
  FontSize: Integer;
begin
  if FPrinter.DPI.Y <> Font.PixelsPerInch then
  begin
    FontSize := Font.Size;
    Font.PixelsPerInch := FPrinter.DPI.Y;
    Font.Size := FontSize;
  end;
end;


{ TfrxCustomPrinter }

constructor TfrxCustomPrinter.Create(const AName, APort: String);
begin
  FName := AName;
  FPort := APort;

  FBins := TStringList.Create;
  FBins.AddObject(frxResources.Get('prDefault'), Pointer(DMBIN_AUTO));

  FPapers := TStringList.Create;
  FPapers.AddObject(frxResources.Get('prCustom'), Pointer(256));

  FCanvas := TfrxPrinterCanvas.Create;
  FCanvas.FPrinter := Self;
end;

destructor TfrxCustomPrinter.Destroy;
begin
  FBins.Free;
  FPapers.Free;
  FCanvas.Free;
  inherited;
end;

function TfrxCustomPrinter.BinIndex(ABin: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to FBins.Count - 1 do
    if Integer(FBins.Objects[i]) = ABin then
    begin
      Result := i;
      break;
    end;
end;

function TfrxCustomPrinter.PaperIndex(APaper: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to FPapers.Count - 1 do
    if Integer(FPapers.Objects[i]) = APaper then
    begin
      Result := i;
      break;
    end;
end;

function TfrxCustomPrinter.BinNameToNumber(const ABin: String): Integer;
var
  i: Integer;
begin
  i := FBins.IndexOf(ABin);
  if i = -1 then
    i := 0;
  Result := Integer(FBins.Objects[i]);
end;

function TfrxCustomPrinter.PaperNameToNumber(const APaper: String): Integer;
var
  i: Integer;
begin
  i := FPapers.IndexOf(APaper);
  if i = -1 then
    i := 0;
  Result := Integer(FPapers.Objects[i]);
end;


{ TfrxVirtualPrinter }

procedure TfrxVirtualPrinter.Init;
var
  i: Integer;
begin
  if FInitialized then Exit;

  FDPI := Point(600, 600);
  FDefPaper := DMPAPER_A4;
  FDefOrientation := poPortrait;
  FDefPaperWidth := 210;
  FDefPaperHeight := 297;

  for i := 0 to PAPERCOUNT - 1 do
    FPapers.AddObject(PaperInfo[i].Name, Pointer(PaperInfo[i].Typ));

  FBin := -1;
  FInitialized := True;
end;

procedure TfrxVirtualPrinter.Abort;
begin
end;

procedure TfrxVirtualPrinter.BeginDoc;
begin
end;

procedure TfrxVirtualPrinter.BeginPage;
begin
end;

procedure TfrxVirtualPrinter.EndDoc;
begin
end;

procedure TfrxVirtualPrinter.EndPage;
begin
end;

procedure TfrxVirtualPrinter.BeginRAWDoc;
begin
end;

procedure TfrxVirtualPrinter.EndRAWDoc;
begin
end;

procedure TfrxVirtualPrinter.WriteRAWDoc(const buf: String);
begin
end;

procedure TfrxVirtualPrinter.SetViewParams(APaperSize: Integer;
  APaperWidth, APaperHeight: Extended; AOrientation: TPrinterOrientation);
var
  i: Integer;
  Found: Boolean;
begin
  Found := False;
  if APaperSize <> 256 then
    for i := 0 to PAPERCOUNT - 1 do
      if PaperInfo[i].Typ = APaperSize then
      begin
        if AOrientation = poPortrait then
        begin
          APaperWidth := PaperInfo[i].X / 10;
          APaperHeight := PaperInfo[i].Y / 10;
        end
        else
        begin
          APaperWidth := PaperInfo[i].Y / 10;
          APaperHeight := PaperInfo[i].X / 10;
        end;
        Found := True;
        break;
      end;

  if not Found then
    APaperSize := 256;

  FOrientation := AOrientation;
  FPaper := APaperSize;
  FPaperWidth := APaperWidth;
  FPaperHeight := APaperHeight;
  FLeftMargin := 5;
  FTopMargin := 5;
  FRightMargin := 5;
  FBottomMargin := 5;
end;

procedure TfrxVirtualPrinter.SetPrintParams(APaperSize: Integer;
  APaperWidth, APaperHeight: Extended; AOrientation: TPrinterOrientation;
  ABin, ADuplex, ACopies: Integer);
begin
  SetViewParams(APaperSize, APaperWidth, APaperHeight, AOrientation);
  FBin := ABin;
end;

procedure TfrxVirtualPrinter.PropertiesDlg;
begin
end;


{ TfrxPrinter }

destructor TfrxPrinter.Destroy;
begin
  FreeDevMode;
  inherited;
end;

procedure TfrxPrinter.Init;

  procedure FillPapers;
  var
    i, PaperSizesCount: Integer;
    PaperSizes: array[0..255] of Word;
    PaperNames: PChar;
  begin
    FillChar(PaperSizes, SizeOf(PaperSizes), 0);
    PaperSizesCount := DeviceCapabilities(PChar(FName), PChar(FPort), DC_PAPERS, @PaperSizes, FMode);
    GetMem(PaperNames, PaperSizesCount * 64);
    DeviceCapabilities(PChar(FName), PChar(FPort), DC_PAPERNAMES, PaperNames, FMode);

    for i := 0 to PaperSizesCount - 1 do
      if PaperSizes[i] <> 256 then
        FPapers.AddObject(StrPas(PaperNames + i * 64), Pointer(PaperSizes[i]));

    FreeMem(PaperNames, PaperSizesCount * 64);
  end;

  procedure FillBins;
  var
    i, BinsCount: Integer;
    BinNumbers: array[0..255] of Word;
    BinNames: PChar;
  begin
    FillChar(BinNumbers, SizeOf(BinNumbers), 0);
    BinsCount := DeviceCapabilities(PChar(FName), PChar(FPort), DC_BINS, @BinNumbers[0], FMode);
    GetMem(BinNames, BinsCount * 64);
    DeviceCapabilities(PChar(FName), PChar(FPort), DC_BINNAMES, BinNames, FMode);

    for i := 0 to BinsCount - 1 do
      if BinNumbers[i] <> DMBIN_AUTO then
        FBins.AddObject(StrPas(BinNames + i * 24), Pointer(BinNumbers[i]));

    FreeMem(BinNames, BinsCount * 64);
  end;

begin
  if FInitialized then Exit;

  CreateDevMode;
  if FDeviceMode = 0 then Exit;
  RecreateDC;

  UpdateDeviceCaps;
  FDefPaper := FMode.dmPaperSize;
  FPaper := FDefPaper;
  FDefPaperWidth := FPaperWidth;
  FDefPaperHeight := FPaperHeight;
  if FMode.dmOrientation = DMORIENT_PORTRAIT then
    FDefOrientation := poPortrait else
    FDefOrientation := poLandscape;
  FOrientation := FDefOrientation;

  FillPapers;
  FillBins;
  FBin := -1;

  FInitialized := True;
end;

procedure TfrxPrinter.Abort;
begin
  AbortDoc(FDC);
  EndDoc;
end;

procedure TfrxPrinter.BeginDoc;
var
  DocInfo: TDocInfo;
begin
  FPrinting := True;

  FillChar(DocInfo, SizeOf(DocInfo), 0);
  DocInfo.cbSize := SizeOf(DocInfo);
  DocInfo.lpszDocName := PChar(FTitle);
  if FFileName <> '' then
    DocInfo.lpszOutput := PChar(FFileName);

  RecreateDC;
  StartDoc(FDC, DocInfo);
end;

procedure TfrxPrinter.BeginPage;
begin
  StartPage(FDC);
end;

procedure TfrxPrinter.EndDoc;
begin
  try
    Windows.EndDoc(FDC);
  except
  end;

  FPrinting := False;
  RecreateDC;
  FBin := -1;
end;

procedure TfrxPrinter.EndPage;
begin
  Windows.EndPage(FDC);
end;

procedure TfrxPrinter.BeginRAWDoc;
var
  DocInfo1: TDocInfo1;
begin
  RecreateDC;
  DocInfo1.pDocName := PChar(FTitle);
  DocInfo1.pOutputFile := nil;
  DocInfo1.pDataType := 'RAW';
  StartDocPrinter(FHandle, 1, @DocInfo1);
  StartPagePrinter(FHandle);
end;

procedure TfrxPrinter.EndRAWDoc;
begin
  EndPagePrinter(FHandle);
  EndDocPrinter(FHandle);
end;

procedure TfrxPrinter.WriteRAWDoc(const buf: String);
var
  N: DWORD;
begin
  WritePrinter(FHandle, PChar(buf), Length(buf), N);
end;

procedure TfrxPrinter.CreateDevMode;
var
  bufSize: Integer;
  dm: TDeviceMode;
begin
  if OpenPrinter(PChar(FName), FHandle, nil) then
  begin
    bufSize := DocumentProperties(0, FHandle, PChar(FName), dm, dm, 0);
    if bufSize > 0 then
    begin
      FDeviceMode := GlobalAlloc(GHND, bufSize);
      if FDeviceMode <> 0 then
      begin
        FMode := GlobalLock(FDeviceMode);
        if DocumentProperties(0, FHandle, PChar(FName), FMode^, FMode^,
          DM_OUT_BUFFER) < 0 then
        begin
          GlobalUnlock(FDeviceMode);
          GlobalFree(FDeviceMode);
          FDeviceMode := 0;
          FMode := nil;
        end
      end;
    end;
  end;
end;

procedure TfrxPrinter.FreeDevMode;
begin
  FCanvas.Handle := 0;
  if FDC <> 0 then
    DeleteDC(FDC);
  if FHandle <> 0 then
    ClosePrinter(FHandle);
  if FDeviceMode <> 0 then
  begin
    GlobalUnlock(FDeviceMode);
    GlobalFree(FDeviceMode);
  end;
end;

procedure TfrxPrinter.RecreateDC;
begin
  if FDC <> 0 then
    try
      DeleteDC(FDC);
    except
    end;
  FDC := 0;
  GetDC;
end;

procedure TfrxPrinter.GetDC;
begin
  if FDC = 0 then
  begin
    if FPrinting then
      FDC := CreateDC(PChar(FDriver), PChar(FName), nil, FMode) else
      FDC := CreateIC(PChar(FDriver), PChar(FName), nil, FMode);
    FCanvas.Handle := FDC;
    FCanvas.Refresh;
    FCanvas.UpdateFont;
  end;
end;

procedure TfrxPrinter.SetViewParams(APaperSize: Integer;
  APaperWidth, APaperHeight: Extended; AOrientation: TPrinterOrientation);
begin
  if APaperSize <> 256 then
  begin
    FMode.dmFields := DM_PAPERSIZE or DM_ORIENTATION;
    FMode.dmPaperSize := APaperSize;
    if AOrientation = poPortrait then
      FMode.dmOrientation := DMORIENT_PORTRAIT else
      FMode.dmOrientation := DMORIENT_LANDSCAPE;
    RecreateDC;
    UpdateDeviceCaps;
  end
  else
  begin
    // copy the margins from A4 paper
    SetViewParams(DMPAPER_A4, 0, 0, AOrientation);
    FPaperHeight := APaperHeight;
    FPaperWidth := APaperWidth;
  end;

  FPaper := APaperSize;
  FOrientation := AOrientation;
end;

procedure TfrxPrinter.SetPrintParams(APaperSize: Integer;
  APaperWidth, APaperHeight: Extended; AOrientation: TPrinterOrientation;
  ABin, ADuplex, ACopies: Integer);
begin
  FMode.dmFields := FMode.dmFields or DM_PAPERSIZE or DM_ORIENTATION or DM_COPIES or
    DM_DEFAULTSOURCE;
  if ADuplex <> 1 then
    FMode.dmFields := FMode.dmFields or DM_DUPLEX;

  if APaperSize = 256 then
  begin
    FMode.dmFields := FMode.dmFields or DM_PAPERLENGTH or DM_PAPERWIDTH;
    FMode.dmPaperLength := Round(APaperHeight * 10);
    FMode.dmPaperWidth := Round(APaperWidth * 10);
  end
  else
  begin
    FMode.dmPaperLength := 0;
    FMode.dmPaperWidth := 0;
  end;

  FMode.dmPaperSize := APaperSize;

  if AOrientation = poPortrait then
    FMode.dmOrientation := DMORIENT_PORTRAIT else
    FMode.dmOrientation := DMORIENT_LANDSCAPE;

  FMode.dmCopies := ACopies;
  if FBin <> -1 then
    ABin := FBin;
  if ABin <> DMBIN_AUTO then
    FMode.dmDefaultSource := ABin;
  if ADuplex = 4 then
    FMode.dmDuplex := DMDUP_SIMPLEX
  else if ADuplex <> 1 then
    FMode.dmDuplex := ADuplex;

  FDC := ResetDC(FDC, FMode^);
  FDC := ResetDC(FDC, FMode^);  // needed for some printers
  FCanvas.Refresh;
  UpdateDeviceCaps;
  FPaper := APaperSize;
  FOrientation := AOrientation;
end;

procedure TfrxPrinter.UpdateDeviceCaps;
begin
  FDPI := Point(GetDeviceCaps(FDC, LOGPIXELSX), GetDeviceCaps(FDC, LOGPIXELSY));
  if (FDPI.X = 0) or (FDPI.Y = 0) then
    raise Exception.Create('Printer selected is not valid');
  FPaperHeight := Round(GetDeviceCaps(FDC, PHYSICALHEIGHT) / FDPI.Y * 25.4);
  FPaperWidth := Round(GetDeviceCaps(FDC, PHYSICALWIDTH) / FDPI.X * 25.4);
  FLeftMargin := Round(GetDeviceCaps(FDC, PHYSICALOFFSETX) / FDPI.X * 25.4);
  FTopMargin := Round(GetDeviceCaps(FDC, PHYSICALOFFSETY) / FDPI.Y * 25.4);
  FRightMargin := FPaperWidth - Round(GetDeviceCaps(FDC, HORZRES) / FDPI.X * 25.4) - FLeftMargin;
  FBottomMargin := FPaperHeight - Round(GetDeviceCaps(FDC, VERTRES) / FDPI.Y * 25.4) - FTopMargin;
end;

procedure TfrxPrinter.PropertiesDlg;
var
  h: THandle;
begin
  if Screen.ActiveForm <> nil then
    h := Screen.ActiveForm.Handle else
    h := 0;
  if DocumentProperties(h, FHandle, PChar(FName), FMode^,
    FMode^, DM_IN_BUFFER or DM_OUT_BUFFER or DM_IN_PROMPT) > 0 then
  begin
    FBin := FMode.dmDefaultSource;
    RecreateDC;
  end;
end;


{ TfrxPrinters }

constructor TfrxPrinters.Create;
begin
  FPrinterList := TList.Create;
  FPrinters := TStringList.Create;

  FillPrinters;
  if FPrinterList.Count = 0 then
  begin
    FPrinterList.Add(TfrxVirtualPrinter.Create(frxResources.Get('prVirtual'), ''));
    FHasPhysicalPrinters := False;
    PrinterIndex := 0;
  end
  else
  begin
    FHasPhysicalPrinters := True;
    PrinterIndex := IndexOf(GetDefaultPrinter);
  end;
end;

destructor TfrxPrinters.Destroy;
begin
  Clear;
  FPrinterList.Free;
  FPrinters.Free;
  inherited;
end;

procedure TfrxPrinters.Clear;
begin
  while FPrinterList.Count > 0 do
  begin
    TObject(FPrinterList[0]).Free;
    FPrinterList.Delete(0);
  end;
  FPrinters.Clear;
end;

function TfrxPrinters.GetItem(Index: Integer): TfrxCustomPrinter;
begin
  Result := FPrinterList[Index];
end;

function TfrxPrinters.IndexOf(AName: String): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to FPrinterList.Count - 1 do
    if AnsiCompareText(Items[i].Name, AName) = 0 then
    begin
      Result := i;
      break;
    end;
end;

procedure TfrxPrinters.SetPrinterIndex(Value: Integer);
begin
  FPrinterIndex := Value;
  if Value <> -1 then
    Items[FPrinterIndex].Init
  else
    FPrinterIndex := IndexOf(GetDefaultPrinter);
end;

function TfrxPrinters.GetCurrentPrinter: TfrxCustomPrinter;
begin
  Result := Items[PrinterIndex];
end;

function TfrxPrinters.GetDefaultPrinter: String;
var
  prnName: array[0..79] of Char;
begin
  GetProfileString('windows', 'device', '', prnName,  79);
  Result := Copy(prnName, 1, Pos(',', prnName) - 1);
end;

procedure TfrxPrinters.FillPrinters;
var
  i, j: Integer;
  Buf, prnInfo: PChar;
  Flags, bufSize, prnCount: DWORD;
  Level: Byte;
  sl: TStringList;

  procedure AddPrinter(ADevice, APort: String);
  begin
    FPrinterList.Add(TfrxPrinter.Create(ADevice, APort));
    FPrinters.Add(ADevice);
  end;

begin
  Clear;
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    Flags := PRINTER_ENUM_CONNECTIONS or PRINTER_ENUM_LOCAL;
    Level := 5;
//    Level := 4;
  end
  else
  begin
    Flags := PRINTER_ENUM_LOCAL;
    Level := 5;
  end;

  bufSize := 0;
  EnumPrinters(Flags, nil, Level, nil, 0, bufSize, prnCount);
  if bufSize = 0 then Exit;

  GetMem(Buf, bufSize);
  try
    if not EnumPrinters(Flags, nil, Level, PByte(Buf), bufSize, bufSize, prnCount) then
      Exit;
    prnInfo := Buf;

    for i := 0 to prnCount - 1 do
      if Level = 4 then
        with PPrinterInfo4(prnInfo)^ do
        begin
          AddPrinter(pPrinterName, '');
          Inc(prnInfo, SizeOf(TPrinterInfo4));
        end
      else
        with PPrinterInfo5(prnInfo)^ do
        begin
          sl := TStringList.Create;
          frxSetCommaText(pPortName, sl, ',');

          for j := 0 to sl.Count - 1 do
            AddPrinter(pPrinterName, sl[j]);

          sl.Free;
          Inc(prnInfo, SizeOf(TPrinterInfo5));
        end;

  finally
    FreeMem(Buf, bufSize);
  end;
end;



function frxPrinters: TfrxPrinters;
begin
  if FPrinters = nil then
    FPrinters := TfrxPrinters.Create;
  Result := FPrinters;
end;


initialization
  FPrinters := nil;

finalization
  if FPrinters <> nil then
    FPrinters.Free;
  FPrinters := nil;

end.


//0f31356a91fea3356e5f76cdce90aa7b