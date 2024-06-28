
{******************************************}
{                                          }
{             FastReport v4.0              }
{   BMP, JPEG, TIFF, GIF export filters    }
{                                          }
{         Copyright (c) 1998-2006          }
{          by Alexander Fediachov,         }
{             Fast Reports Inc.            }
{                                          }
{******************************************}

unit frxExportImage;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, frxClass, Jpeg
{$IFDEF Delphi6}
, Variants
{$ENDIF};

procedure GIFSaveToStream(const Stream: TStream; const Bitmap: TBitmap);
procedure GIFSaveToFile(const FileName: String; const Bitmap: TBitmap);

type
  TfrxCustomImageExport = class(TfrxCustomExportFilter)
  private
    FBitmap: TBitmap;
    FCrop: Boolean;
    FCurrentPage: Integer;
    FJPEGQuality: Integer;
    FMaxX: Integer;
    FMaxY: Integer;
    FMinX: Integer;
    FMinY: Integer;
    FMonochrome: Boolean;
    FResolution: Integer;
    FCurrentRes: Integer;
    FSeparate: Boolean;
    FYOffset: Integer;
    FFileSuffix: String;
    FFirstPage: Boolean;
    FExportNotPrintable: Boolean;
    function SizeOverflow(const Val: Extended): Boolean;
  protected
    FDiv: Extended;
    procedure Save; virtual;
    procedure FinishExport;
  public
    constructor Create(AOwner: TComponent); override;
    function ShowModal: TModalResult; override;
    function Start: Boolean; override;
    procedure Finish; override;
    procedure FinishPage(Page: TfrxReportPage; Index: Integer); override;
    procedure StartPage(Page: TfrxReportPage; Index: Integer); override;
    procedure ExportObject(Obj: TfrxComponent); override;

    property JPEGQuality: Integer read FJPEGQuality write FJPEGQuality default 90;
    property CropImages: Boolean read FCrop write FCrop default False;
    property Monochrome: Boolean read FMonochrome write FMonochrome default False;
    property Resolution: Integer read FResolution write FResolution;
    property SeparateFiles: Boolean read FSeparate write FSeparate;
    property ExportNotPrintable: Boolean read FExportNotPrintable write FExportNotPrintable;
  end;

  TfrxBMPExport = class(TfrxCustomImageExport)
  protected
    procedure Save; override;
  public
    constructor Create(AOwner: TComponent); override;
    class function GetDescription: String; override;
  published
    property CropImages;
    property Monochrome;
  end;

  TfrxTIFFExport = class(TfrxCustomImageExport)
  private
    procedure SaveTiffToStream(const Stream: TStream; const Bitmap: TBitmap);
  protected
    procedure Save; override;
  public
    constructor Create(AOwner: TComponent); override;
    class function GetDescription: String; override;
  published
    property CropImages;
    property Monochrome;
  end;

  TfrxJPEGExport = class(TfrxCustomImageExport)
  protected
    procedure Save; override;
  public
    constructor Create(AOwner: TComponent); override;
    class function GetDescription: String; override;
  published
    property JPEGQuality;
    property CropImages;
    property Monochrome;
  end;

  TfrxGIFExport = class(TfrxCustomImageExport)
  protected
    procedure Save; override;
  public
    constructor Create(AOwner: TComponent); override;
    class function GetDescription: String; override;
  published
    property CropImages;
    property Monochrome;
  end;

  TfrxIMGExportDialog = class(TForm)
    OK: TButton;
    Cancel: TButton;
    GroupPageRange: TGroupBox;
    GroupBox1: TGroupBox;
    CropPage: TCheckBox;
    Label2: TLabel;
    Quality: TEdit;
    Mono: TCheckBox;
    SaveDialog1: TSaveDialog;
    DescrL: TLabel;
    AllRB: TRadioButton;
    CurPageRB: TRadioButton;
    PageNumbersRB: TRadioButton;
    PageNumbersE: TEdit;
    Label1: TLabel;
    Resolution: TEdit;
    SeparateCB: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure PageNumbersEChange(Sender: TObject);
    procedure PageNumbersEKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FFilter: TfrxCustomImageExport;
    procedure SetFilter(const Value: TfrxCustomImageExport);
  public
    property Filter: TfrxCustomImageExport read FFilter write SetFilter;
  end;

implementation

uses frxUtils, frxFileUtils, frxRes, frxrcExports;

{$R *.dfm}

type
  PDirEntry = ^TDirEntry;
  TDirEntry = record
    _Tag: Word;
    _Type: Word;
    _Count: LongInt;
    _Value: LongInt;
  end;

const
  TifHeader: array[0..7] of Byte = (
    $49, $49, $2A, $00, $08, $00, $00, $00);
  MAX_TBITMAP_HEIGHT = 30000;
  MAXBITSCODES = 12;
  HSIZE = 5003;
  NullString: array[0..3] of Byte = ($00, $00, $00, $00);
  Software: array[0..9] of Char = ('F', 'a', 's', 't', 'R', 'e', 'p', 'o', 'r', 't');
  code_mask: array [0..16] of cardinal = ($0000, $0001, $0003, $0007, $000F,
 	  $001F, $003F, $007F, $00FF, $01FF, $03FF, $07FF, $0FFF,
	  $1FFF, $3FFF, $7FFF, $FFFF);
  BitsPerSample: array[0..2] of Word = ($0008, $0008, $0008);
  D_BW_C: array[0..13] of TDirEntry = (
    (_Tag: $00FE; _Type: $0004; _Count: $00000001; _Value: $00000000),
    (_Tag: $0100; _Type: $0003; _Count: $00000001; _Value: $00000000),
    (_Tag: $0101; _Type: $0003; _Count: $00000001; _Value: $00000000),
    (_Tag: $0102; _Type: $0003; _Count: $00000001; _Value: $00000001),
    (_Tag: $0103; _Type: $0003; _Count: $00000001; _Value: $00000001),
    (_Tag: $0106; _Type: $0003; _Count: $00000001; _Value: $00000001),
    (_Tag: $0111; _Type: $0004; _Count: $00000001; _Value: $00000000),
    (_Tag: $0115; _Type: $0003; _Count: $00000001; _Value: $00000001),
    (_Tag: $0116; _Type: $0004; _Count: $00000001; _Value: $00000000),
    (_Tag: $0117; _Type: $0004; _Count: $00000001; _Value: $00000000),
    (_Tag: $011A; _Type: $0005; _Count: $00000001; _Value: $00000000),
    (_Tag: $011B; _Type: $0005; _Count: $00000001; _Value: $00000000),
    (_Tag: $0128; _Type: $0003; _Count: $00000001; _Value: $00000002),
    (_Tag: $0131; _Type: $0002; _Count: $0000000A; _Value: $00000000));
  D_COL_C: array[0..14] of TDirEntry = (
    (_Tag: $00FE; _Type: $0004; _Count: $00000001; _Value: $00000000),
    (_Tag: $0100; _Type: $0003; _Count: $00000001; _Value: $00000000),
    (_Tag: $0101; _Type: $0003; _Count: $00000001; _Value: $00000000),
    (_Tag: $0102; _Type: $0003; _Count: $00000001; _Value: $00000008),
    (_Tag: $0103; _Type: $0003; _Count: $00000001; _Value: $00000001),
    (_Tag: $0106; _Type: $0003; _Count: $00000001; _Value: $00000003),
    (_Tag: $0111; _Type: $0004; _Count: $00000001; _Value: $00000000),
    (_Tag: $0115; _Type: $0003; _Count: $00000001; _Value: $00000001),
    (_Tag: $0116; _Type: $0004; _Count: $00000001; _Value: $00000000),
    (_Tag: $0117; _Type: $0004; _Count: $00000001; _Value: $00000000),
    (_Tag: $011A; _Type: $0005; _Count: $00000001; _Value: $00000000),
    (_Tag: $011B; _Type: $0005; _Count: $00000001; _Value: $00000000),
    (_Tag: $0128; _Type: $0003; _Count: $00000001; _Value: $00000002),
    (_Tag: $0131; _Type: $0002; _Count: $0000000A; _Value: $00000000),
    (_Tag: $0140; _Type: $0003; _Count: $00000300; _Value: $00000008));
  D_RGB_C: array[0..14] of TDirEntry = (
    (_Tag: $00FE; _Type: $0004; _Count: $00000001; _Value: $00000000),
    (_Tag: $0100; _Type: $0003; _Count: $00000001; _Value: $00000000),
    (_Tag: $0101; _Type: $0003; _Count: $00000001; _Value: $00000000),
    (_Tag: $0102; _Type: $0003; _Count: $00000003; _Value: $00000008),
    (_Tag: $0103; _Type: $0003; _Count: $00000001; _Value: $00000001),
    (_Tag: $0106; _Type: $0003; _Count: $00000001; _Value: $00000002),
    (_Tag: $0111; _Type: $0004; _Count: $00000001; _Value: $00000000),
    (_Tag: $0115; _Type: $0003; _Count: $00000001; _Value: $00000003),
    (_Tag: $0116; _Type: $0004; _Count: $00000001; _Value: $00000000),
    (_Tag: $0117; _Type: $0004; _Count: $00000001; _Value: $00000000),
    (_Tag: $011A; _Type: $0005; _Count: $00000001; _Value: $00000000),
    (_Tag: $011B; _Type: $0005; _Count: $00000001; _Value: $00000000),
    (_Tag: $011C; _Type: $0003; _Count: $00000001; _Value: $00000001),
    (_Tag: $0128; _Type: $0003; _Count: $00000001; _Value: $00000002),
    (_Tag: $0131; _Type: $0002; _Count: $0000000A; _Value: $00000000));

{ TfrxCustomImageExport }

constructor TfrxCustomImageExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCrop := True;
  FJPEGQuality := 90;
  FResolution := 96;
  FSeparate := True;
  FExportNotPrintable := False;
  CropImages := False;
end;

function TfrxCustomImageExport.ShowModal: TModalResult;
begin
  with TfrxIMGExportDialog.Create(nil) do
  begin
    Filter := Self;
    Quality.Text := IntToStr(FJPEGQuality);
    CropPage.Checked := FCrop;
    Mono.Checked := FMonochrome;
    Quality.Enabled := Self is TfrxJPEGExport;
    Mono.Enabled := not (Self is TfrxGIFExport);
    Resolution.Text := IntToStr(FResolution);
    if SlaveExport then
    begin
      SeparateCB.Checked := False;
      SeparateCB.Visible := False;
    end
    else
      SeparateCB.Checked := FSeparate;

    if (FileName = '') and (not SlaveExport) then
      SaveDialog1.FileName := ChangeFileExt(ExtractFileName(Report.FileName), SaveDialog1.DefaultExt)
    else
      SaveDialog1.FileName := FileName;

    if PageNumbers <> '' then
    begin
      PageNumbersE.Text := PageNumbers;
      PageNumbersRB.Checked := True;
    end;

    Result := ShowModal;

    if Result = mrOk then
    begin
      FJPEGQuality := StrToInt(Quality.Text);
      FCrop := CropPage.Checked;
      FMonochrome := Mono.Checked;
      FResolution := StrToInt(Resolution.Text);
      FSeparate := SeparateCB.Checked;
      PageNumbers := '';
      CurPage := False;
      if CurPageRB.Checked then
        CurPage := True
      else if PageNumbersRB.Checked then
        PageNumbers := PageNumbersE.Text;

      if not SlaveExport then
      begin
        if DefaultPath <> '' then
          SaveDialog1.InitialDir := DefaultPath;
        if SaveDialog1.Execute then
          FileName := SaveDialog1.FileName else
          Result := mrCancel
      end else
        FileName := ChangeFileExt(GetTempFile, SaveDialog1.DefaultExt);
    end;
    Free;
  end;
end;

function TfrxCustomImageExport.Start: Boolean;
begin
  if SlaveExport then
    FSeparate := False;
  CurPage := False;
  FCurrentPage := 0;
  FYOffset := 0;
  if not FSeparate then
  begin
    FBitmap := TBitmap.Create;
    FCurrentRes := FBitmap.Canvas.Font.PixelsPerInch;
    FDiv := FResolution / FCurrentRes;
    FBitmap.Canvas.Brush.Color := clWhite;
    FBitmap.Monochrome := Monochrome;
    FMaxX := 0;
    FMaxY := 0;
    FFirstPage := True;
  end;
  Result := (FileName <> '') or (Stream <> nil);
  if (ExtractFilePath(FileName) = '') and (DefaultPath <> '') then
    FileName := DefaultPath + '\' + FileName;
end;

procedure TfrxCustomImageExport.StartPage(Page: TfrxReportPage; Index: Integer);
var
  i: Extended;
begin
  Inc(FCurrentPage);
  if FSeparate then
  begin
    FBitmap := TBitmap.Create;
    FCurrentRes := FBitmap.Canvas.Font.PixelsPerInch;
    FDiv := FResolution / FCurrentRes;
    FBitmap.Canvas.Brush.Color := clWhite;
    FBitmap.Monochrome := Monochrome;
    FBitmap.Width := Round(Page.Width * FDiv);
    FBitmap.Height := Round(Page.Height * FDiv);
    FMaxX := 0;
    FMaxY := 0;
    FMinX := FBitmap.Width;
    FMinY := FBitmap.Height;
  end else
  begin
    if FFirstpage then
    begin
      if FBitmap.Width < Round(Page.Width * FDiv) then
        FBitmap.Width := Round(Page.Width * FDiv);
      i := Page.Height * Report.PreviewPages.Count * FDiv;
      if SizeOverflow(i) then
        i := MAX_TBITMAP_HEIGHT;
      FBitmap.Height := Round(i);
      FFirstPage := False;
    end;
    FMinX := FBitmap.Width;
    FMinY := FBitmap.Height;
  end;
end;

procedure TfrxCustomImageExport.ExportObject(Obj: TfrxComponent);
begin
  if (Obj is TfrxView) and (FExportNotPrintable or TfrxView(Obj).Printable) then
  begin
    if Round(Obj.AbsLeft * FDiv) < FMinX then
      FMinX := Round(Obj.AbsLeft * FDiv);
    if (FYOffset + Round(Obj.AbsTop * FDiv)) < FMinY then
      FMinY := FYOffset + Round(Obj.AbsTop * FDiv);
    if ((Obj.AbsLeft + Obj.Width) * FDiv) > FMaxX then
      FMaxX := Round((Obj.AbsLeft + Obj.Width) * FDiv) + 1;
    if (FYOffset + ((Obj.AbsTop + Obj.Height) * FDiv)) > FMaxY then
      FMaxY := FYOffset + Round((Obj.AbsTop + Obj.Height) * FDiv) + 1;
    TfrxView(Obj).Draw(FBitmap.Canvas, FDiv, FDiv, 0, FYOffset);
  end;
end;

procedure TfrxCustomImageExport.FinishPage(Page: TfrxReportPage; Index: Integer);
begin
  if FSeparate then
    FinishExport
  else
    FYOffset := FYOffset + Round(Page.Height * FDiv);
end;

procedure TfrxCustomImageExport.Finish;
begin
  if not FSeparate then
    FinishExport;
end;

procedure TfrxCustomImageExport.Save;
begin
  if FSeparate then
    FFileSuffix := '.' + IntToStr(FCurrentPage)
  else
    FFileSuffix := '';
end;

procedure TfrxCustomImageExport.FinishExport;
var
  RFrom, RTo: TRect;
begin
  try
    if FCrop then
    begin
      RFrom := Rect(FMinX, FMinY, FMaxX, FMaxY);
      RTo := Rect(0, FYOffset, FMaxX - FMinX, FYOffset + FMaxY - FMinY);
      FBitmap.Canvas.CopyRect(RTo, FBitmap.Canvas, RFrom);
      FBitmap.Width := FMaxX - FMinX;
      FBitmap.Height := FYOffset + FMaxY - FMinY;
    end;
    Save;
  finally
    FBitmap.Free;
  end;
end;

function TfrxCustomImageExport.SizeOverflow(const Val: Extended): Boolean;
begin
  Result :=  Val > MAX_TBITMAP_HEIGHT;
end;

{ TfrxIMGExportDialog }

procedure TfrxIMGExportDialog.FormCreate(Sender: TObject);
begin
  Caption := frxGet(8600);
  OK.Caption := frxGet(1);
  Cancel.Caption := frxGet(2);
  GroupPageRange.Caption := frxGet(7);
  AllRB.Caption := frxGet(3);
  CurPageRB.Caption := frxGet(4);
  PageNumbersRB.Caption := frxGet(5);
  DescrL.Caption := frxGet(9);
  GroupBox1.Caption := frxGet(8601);
  Label2.Caption := frxGet(8602);
  Label1.Caption := frxGet(8603);
  SeparateCB.Caption := frxGet(8604);
  CropPage.Caption := frxGet(8605);
  Mono.Caption := frxGet(8606);
end;

procedure TfrxIMGExportDialog.SetFilter(const Value: TfrxCustomImageExport);
begin
  FFilter := Value;
  SaveDialog1.Filter := FFilter.FilterDesc;
  SaveDialog1.DefaultExt := FFilter.DefaultExt;
end;


{ TfrxBMPExport }

constructor TfrxBMPExport.Create(AOwner: TComponent);
begin
  inherited;
  FilterDesc := frxResources.Get('BMPexportFilter');
  DefaultExt := '.bmp';
end;

class function TfrxBMPExport.GetDescription: String;
begin
  Result := frxResources.Get('BMPexport');
end;

procedure TfrxBMPExport.Save;
begin
  inherited;
  if Stream <> nil then
    FBitmap.SaveToStream(Stream)
  else
    FBitmap.SaveToFile(ChangeFileExt(FileName, FFileSuffix + '.bmp'));
end;


{ TfrxTIFFExport }

constructor TfrxTIFFExport.Create(AOwner: TComponent);
begin
  inherited;
  FilterDesc := frxResources.Get('TIFFexportFilter');
  DefaultExt := '.tif';
end;

class function TfrxTIFFExport.GetDescription: String;
begin
  Result := frxResources.Get('TIFFexport');
end;

procedure TfrxTIFFExport.Save;
var
  TFStream: TFileStream;
begin
  inherited;
  try
    if Stream <> nil then
      SaveTiffToStream(Stream, FBitmap)
    else
    begin
      TFStream := TFileStream.Create(ChangeFileExt(FileName, FFileSuffix + '.tif'), fmCreate);
      try
        SaveTiffToStream(TFStream, FBitmap);
      finally
        TFStream.Free;
      end;
    end;
  except
    on e: Exception do
      case Report.EngineOptions.NewSilentMode of
        simSilent:        Report.Errors.Add(e.Message);
        simMessageBoxes:  frxErrorMsg(e.Message);
        simReThrow:       raise;
      end;
  end;
end;

procedure TfrxTIFFExport.SaveTIFFToStream(const Stream: TStream; const Bitmap: TBitmap);
var
  i, k: Integer;
  dib_f: Boolean;
  Header, Bits, BitsPtr, TmpBitsPtr, NewBits: PChar;
  HeaderSize, BitsSize: DWORD;
  Width, Height, DataWidth, BitCount: Integer;
  MapRed, MapGreen, MapBlue: array[0..255, 0..1] of Byte;
  ColTabSize, BmpWidth: Integer;
  Red, Blue, Green: Char;
  O_XRes, O_YRes, O_Soft, O_Strip, O_Dir, O_BPS: LongInt;
  RGB: Word;
  Res: Word;
  NoOfDirs: array[0..1] of Byte;
  D_BW: array[0..13] of TDirEntry;
  D_COL: array[0..14] of TDirEntry;
  D_RGB: array[0..14] of TDirEntry;
  Res_Value: array[0..7] of Byte;
begin
  if Bitmap.Handle = 0 then Exit;
  NoOfDirs[1] := 0;
  Res := FResolution * 10;
  Res_Value[0] := Res and $00ff;
  Res_Value[1] := (Res and $ff00) shr 8;
  Res_Value[2] := 0;
  Res_Value[3] := 0;
  Res_Value[4] := $0A;
  Res_Value[5] := 0;
  Res_Value[6] := 0;
  Res_Value[7] := 0;
  GetDIBSizes(Bitmap.Handle, HeaderSize, BitsSize);
  Header := GlobalAllocPtr(GMEM_MOVEABLE or GMEM_SHARE, HeaderSize + BitsSize);
  try
    Bits := Header + HeaderSize;
    dib_f := GetDIB(Bitmap.Handle, Bitmap.Palette, Header^, Bits^);
    if dib_f then
    begin
      Width := PBITMAPINFO(Header)^.bmiHeader.biWidth;
      Height := PBITMAPINFO(Header)^.bmiHeader.biHeight;
      BitCount := PBITMAPINFO(Header)^.bmiHeader.biBitCount;
      NoOfDirs[0] := $0F;
      ColTabSize := (1 shl BitCount);
      BmpWidth := Trunc(BitsSize / Height);
      Stream.Write(TifHeader, sizeof(TifHeader));
      if BitCount = 1 then
      begin
        CopyMemory(@D_BW, @D_BW_C, SizeOf(D_BW));
        NoOfDirs[0] := $0E;
        O_XRes := Stream.Position;
        Stream.Write(Res_Value, sizeof(Res_Value));
        O_YRes := Stream.Position;
        Stream.Write(Res_Value, sizeof(Res_Value));
        O_Soft := Stream.Position;
        Stream.Write(Software, sizeof(Software));
        DataWidth := ((Width + 7) div 8);
        O_Strip := Stream.Position;
        if Height < 0 then
          for i := 0 to Height - 1 do
          begin
            BitsPtr := Bits + i * BmpWidth;
            Stream.Write(BitsPtr^, DataWidth);
          end
        else
          for i := 1 to Height do
          begin
            BitsPtr := Bits + (Height - i) * BmpWidth;
            Stream.Write(BitsPtr^, DataWidth);
          end;
        Stream.Write(NullString, sizeof(NullString));
        D_BW[1]._Value := LongInt(Width);
        D_BW[2]._Value := LongInt(abs(Height));
        D_BW[8]._Value := LongInt(abs(Height));
        D_BW[9]._Value := LongInt(DataWidth * abs(Height));
        D_BW[6]._Value := O_Strip;
        D_BW[10]._Value := O_XRes;
        D_BW[11]._Value := O_YRes;
        D_BW[13]._Value := O_Soft;
        O_Dir := Stream.Position;
        Stream.Write(NoOfDirs, sizeof(NoOfDirs));
        Stream.Write(D_BW, sizeof(D_BW));
        Stream.Write(NullString, sizeof(NullString));
        Stream.Seek(4, soFromBeginning);
        Stream.Write(O_Dir, sizeof(O_Dir));
      end;
      if BitCount in [4, 8] then
      begin
        CopyMemory(@D_COL, @D_COL_C, SizeOf(D_COL));
        DataWidth := Width;
        if BitCount = 4 then
        begin
          Width := (Width div BitCount) * BitCount;
          if BitCount = 4 then
            DataWidth := Width div 2;
        end;
        D_COL[1]._Value := LongInt(Width);
        D_COL[2]._Value := LongInt(abs(Height));
        D_COL[3]._Value := LongInt(BitCount);
        D_COL[8]._Value := LongInt(Height);
        D_COL[9]._Value := LongInt(DataWidth * abs(Height));
        for i := 0 to ColTabSize - 1 do
        begin
          MapRed[i][1] := PBITMAPINFO(Header)^.bmiColors[i].rgbRed;
          MapRed[i][0] := 0;
          MapGreen[i][1] := PBITMAPINFO(Header)^.bmiColors[i].rgbGreen;
          MapGreen[i][0] := 0;
          MapBlue[i][1] := PBITMAPINFO(Header)^.bmiColors[i].rgbBlue;
          MapBlue[i][0] := 0;
        end;
        D_COL[14]._Count := LongInt(ColTabSize * 3);
        Stream.Write(MapRed, ColTabSize * 2);
        Stream.Write(MapGreen, ColTabSize * 2);
        Stream.Write(MapBlue, ColTabSize * 2);
        O_XRes := Stream.Position;
        Stream.Write(Res_Value, sizeof(Res_Value));
        O_YRes := Stream.Position;
        Stream.Write(Res_Value, sizeof(Res_Value));
        O_Soft := Stream.Position;
        Stream.Write(Software, sizeof(Software));
        O_Strip := Stream.Position;
        if Height < 0 then
          for i := 0 to Height - 1 do
          begin
            BitsPtr := Bits + i * BmpWidth;
            Stream.Write(BitsPtr^, DataWidth);
          end
        else
          for i := 1 to Height do
          begin
            BitsPtr := Bits + (Height - i) * BmpWidth;
            Stream.Write(BitsPtr^, DataWidth);
          end;
        D_COL[6]._Value := O_Strip;
        D_COL[10]._Value := O_XRes;
        D_COL[11]._Value := O_YRes;
        D_COL[13]._Value := O_Soft;
        O_Dir := Stream.Position;
        Stream.Write(NoOfDirs, sizeof(NoOfDirs));
        Stream.Write(D_COL, sizeof(D_COL));
        Stream.Write(NullString, sizeof(NullString));
        Stream.Seek(4, soFromBeginning);
        Stream.Write(O_Dir, sizeof(O_Dir));
      end;
      if BitCount = 16 then
      begin
        CopyMemory(@D_RGB, @D_RGB_C, SizeOf(D_RGB));
        D_RGB[1]._Value := LongInt(Width);
        D_RGB[2]._Value := LongInt(Height);
        D_RGB[8]._Value := LongInt(Height);
        D_RGB[9]._Value := LongInt(3 * Width * Height);
        O_XRes := Stream.Position;
        Stream.Write(Res_Value, sizeof(Res_Value));
        O_YRes := Stream.Position;
        Stream.Write(Res_Value, sizeof(Res_Value));
        O_BPS := Stream.Position;
        Stream.Write(BitsPerSample, sizeof(BitsPerSample));
        O_Soft := Stream.Position;
        Stream.Write(Software, sizeof(Software));
        O_Strip := Stream.Position;
        GetMem(NewBits, Width * Height * 3);
        for i := 0 to Height - 1 do
        begin
          BitsPtr := Bits + i * BmpWidth;
          TmpBitsPtr := NewBits + i * Width * 3;
          for k := 0 to Width - 1 do
          begin
            RGB := PWord(BitsPtr)^;
            Blue := Char((RGB and $1F) shl 3 or $7);
            Green := Char((RGB shr 5 and $1F) shl 3 or $7);
            Red := Char((RGB shr 10 and $1F) shl 3 or $7);
            PByte(TmpBitsPtr)^ := Byte(Red);
            PByte(TmpBitsPtr + 1)^ := Byte(Green);
            PByte(TmpBitsPtr + 2)^ := Byte(Blue);
            BitsPtr := BitsPtr + 2;
            TmpBitsPtr := TmpBitsPtr + 3;
          end;
        end;
        for i := 1 to Height do
        begin
          TmpBitsPtr := NewBits + (Height - i) * Width * 3;
          Stream.Write(TmpBitsPtr^, Width * 3);
        end;
        FreeMem(NewBits);
        D_RGB[3]._Value := O_BPS;
        D_RGB[6]._Value := O_Strip;
        D_RGB[10]._Value := O_XRes;
        D_RGB[11]._Value := O_YRes;
        D_RGB[14]._Value := O_Soft;
        O_Dir := Stream.Position;
        Stream.Write(NoOfDirs, sizeof(NoOfDirs));
        Stream.Write(D_RGB, sizeof(D_RGB));
        Stream.Write(NullString, sizeof(NullString));
        Stream.Seek(4, soFromBeginning);
        Stream.Write(O_Dir, sizeof(O_Dir));
      end;
      if BitCount in [24, 32] then
      begin
        CopyMemory(@D_RGB, @D_RGB_C, SizeOf(D_RGB));
        D_RGB[1]._Value := LongInt(Width);
        D_RGB[2]._Value := LongInt(Height);
        D_RGB[8]._Value := LongInt(Height);
        D_RGB[9]._Value := LongInt(3 * Width * Height);
        O_XRes := Stream.Position;
        Stream.Write(Res_Value, sizeof(Res_Value));
        O_YRes := Stream.Position;
        Stream.Write(Res_Value, sizeof(Res_Value));
        O_BPS := Stream.Position;
        Stream.Write(BitsPerSample, sizeof(BitsPerSample));
        O_Soft := Stream.Position;
        Stream.Write(Software, sizeof(Software));
        O_Strip := Stream.Position;
        for i := 0 to Height - 1 do
        begin
          BitsPtr := Bits + i * BmpWidth;
          for k := 0 to Width - 1 do
          begin
            Blue := (BitsPtr)^;
            Red := (BitsPtr + 2)^;
            (BitsPtr)^ := Red;
            (BitsPtr + 2)^ := Blue;
            BitsPtr := BitsPtr + BitCount div 8;
          end;
        end;
        if BitCount = 32 then
          for i := 0 to Height - 1 do
          begin
            BitsPtr := Bits + i * BmpWidth;
            TmpBitsPtr := BitsPtr;
            for k := 0 to Width - 1 do
            begin
              (TmpBitsPtr)^ := (BitsPtr)^;
              (TmpBitsPtr + 1)^ := (BitsPtr + 1)^;
              (TmpBitsPtr + 2)^ := (BitsPtr + 2)^;
              TmpBitsPtr := TmpBitsPtr + 3;
              BitsPtr := BitsPtr + 4;
            end;
          end;
        BmpWidth := Trunc(BitsSize / Height);
        if Height < 0 then
          for i := 0 to Height - 1 do
          begin
            BitsPtr := Bits + i * BmpWidth;
            Stream.Write(BitsPtr^, Width * 3);
          end
        else
          for i := 1 to Height do
          begin
            BitsPtr := Bits + (Height - i) * BmpWidth;
            Stream.Write(BitsPtr^, Width * 3);
          end;
        D_RGB[3]._Value := O_BPS;
        D_RGB[6]._Value := O_Strip;
        D_RGB[10]._Value := O_XRes;
        D_RGB[11]._Value := O_YRes;
        D_RGB[14]._Value := O_Soft;
        O_Dir := Stream.Position;
        Stream.Write(NoOfDirs, sizeof(NoOfDirs));
        Stream.Write(D_RGB, sizeof(D_RGB));
        Stream.Write(NullString, sizeof(NullString));
        Stream.Seek(4, soFromBeginning);
        Stream.Write(O_Dir, sizeof(O_Dir));
      end;
    end;
  finally
    GlobalFreePtr(Header);
  end;
end;


{ TfrxJPEGExport }

constructor TfrxJPEGExport.Create(AOwner: TComponent);
begin
  inherited;
  FilterDesc := frxResources.Get('JPEGexportFilter');
  DefaultExt := '.jpg';
end;

class function TfrxJPEGExport.GetDescription: String;
begin
  Result := frxResources.Get('JPEGexport');
end;

procedure TfrxJPEGExport.Save;
var
  Image: TJPEGImage;
  TFStream: TFileStream;
begin
  inherited;
  try
    if Stream <> nil then
    begin
      Image := TJPEGImage.Create;
      try
        Image.CompressionQuality := FJPEGQuality;
        Image.Assign(FBitmap);
        Image.SaveToStream(Stream);
      finally
        Image.Free;
      end;
    end
    else
    begin
      TFStream := TFileStream.Create(ChangeFileExt(FileName, FFileSuffix + '.jpg'), fmCreate);
      try
        Image := TJPEGImage.Create;
        try
          Image.CompressionQuality := FJPEGQuality;
          Image.Assign(FBitmap);
          Image.SaveToStream(TFStream);
        finally
          Image.Free;
        end;
      finally
        TFStream.Free;
      end;
    end;
  except
    on e: Exception do
      case Report.EngineOptions.NewSilentMode of
        simSilent:        Report.Errors.Add(e.Message);
        simMessageBoxes:  frxErrorMsg(e.Message);
        simReThrow:       raise;
      end;
  end;
end;

{ TfrxGIFExport }

procedure GIFSaveToFile(const FileName: String; const Bitmap: TBitmap);
var
  f: TFileStream;
begin
  f := TFileStream.Create(FileName, fmCreate);
  try
    GIFSaveToStream(f, Bitmap);
  finally
    f.Free;
  end;
end;

procedure GIFSaveToStream(const Stream: TStream; const Bitmap: TBitmap);
var
  w, h: word;
  flags, b: byte;
  i: Integer;
  Palette: array [0..255] of PALETTEENTRY;
  s: String;
  CountDown: Integer;
  curx, cury: Integer;
  htab: array [0..HSIZE] of longint;
  codetab: array [0..HSIZE] of integer;
  accum: array [0..255] of byte;
	a_count: integer;
  InitCodeSize: Integer;
  g_init_bits: Integer;
	maxcode, free_ent: integer;
	cur_accum: cardinal;
  cur_bits, clear_flg, clearcode, EOFCode, n_bits: Integer;

  function GifNextPixel: Integer;
  var
    P : PByteArray;
  begin
    if CountDown = 0 then
      Result := -1
    else begin
      Dec(CountDown);
      P := Bitmap.ScanLine[cury];
      Result := P[curx];
      Inc(curx);
      if curx = Bitmap.Width then
      begin
        curx := 0;
        Inc(cury);
      end;
    end;
  end;

  procedure Putword(const w: Integer);
  begin
    Stream.Write(w, 2);
  end;

  procedure cl_hash(const hsize: longint);
  var
    i: longint;
  begin
    for i := 0 to hsize - 1 do
      htab[i] := -1;
  end;

  procedure flush_char;
  var
    b: byte;
  begin
    if a_count > 0 then
    begin
      b := byte(a_count);
      Stream.Write(b, 1);
      Stream.Write(accum, a_count);
      a_count := 0;
    end;
  end;

  procedure char_out(c: byte);
  begin
    accum[a_count] := c;
    Inc(a_count);
    if a_count >= 254 then
      flush_char;
  end;

  procedure output(const code: Integer);
  begin
	  cur_accum := cur_accum and code_mask[cur_bits];
	  if cur_bits > 0  then
		  cur_accum := cur_accum or (cardinal(code) shl cur_bits)
	  else
		  cur_accum := code;
	  cur_bits := cur_bits + n_bits;
	  while cur_bits >= 8 do
    begin
		  char_out(cur_accum and $ff);
		  cur_accum := cur_accum shr 8;
		  cur_bits := cur_bits - 8;
	  end;
    if (free_ent > maxcode) or (clear_flg <> 0) then
    begin
      if clear_flg <> 0 then
      begin
        n_bits := g_init_bits;
        maxcode := (1 shl n_bits) - 1;
        clear_flg := 0;
      end
      else begin
        Inc(n_bits);
        if n_bits = MAXBITSCODES then
          maxcode := 1 shl MAXBITSCODES
        else
          maxcode := (1 shl n_bits) - 1;
      end;
    end;
	  if code = EOFCode then
    begin
  		while cur_bits > 0 do
      begin
	  		char_out(cur_accum and $ff);
		  	cur_accum := cur_accum shr 8;
			  cur_bits := cur_bits - 8;
		  end;
		  flush_char;
	  end;
  end;

  procedure compressLZW(const init_bits: Integer);
  var
    fcode, c, ent, hshift, disp, i: longint;
    maxmaxcode: integer;
    label probe;
    label nomatch;
  begin
    g_init_bits := init_bits;
    cur_accum := 0;
    cur_bits := 0;
    clear_flg := 0;
    n_bits := g_init_bits;
    maxcode := (1 shl g_init_bits) - 1;
    maxmaxcode := 1 shl MAXBITSCODES;
    ClearCode := 1 shl (init_bits - 1);
    EOFCode := ClearCode + 1;
    free_ent := ClearCode + 2;
    a_count := 0;
    ent := GifNextPixel;
    hshift := 0;
    fcode := HSIZE;
    while fcode < 65536 do
    begin
      fcode := fcode * 2;
      hshift := hshift + 1;
    end;
    hshift := 8 - hshift;
    cl_hash(HSIZE);
    output(ClearCode);
    c := GifNextPixel;
    while c <> -1 do
    begin
      fcode := longint((longint(c) shl MAXBITSCODES) + ent);
      i := ((c shl hshift) xor ent);
      if HTab[i] = fcode then
      begin
        ent := CodeTab[i];
        c := GifNextPixel;
        continue;
      end
      else if HTab[i] < 0 then
        goto nomatch;
      disp := HSIZE - i;
      if i = 0 then
        disp := 1;
  probe:
      i := i - disp;
      if i < 0  then	i := i + HSIZE;
      if HTab[i] = fcode then
      begin
        ent := CodeTab[i];
        c := GifNextPixel;
        continue;
      end;
      if HTab[i] > 0 then
        goto probe;
  nomatch:
      output(ent);
      ent := c;
      if free_ent < maxmaxcode then
      begin
        CodeTab[i] := free_ent;
        free_ent := free_ent + 1;
        HTab[i] := fcode;
      end
      else begin
        cl_hash(HSIZE);
        free_ent := ClearCode + 2;
        clear_flg := 1;
        output(ClearCode);
      end;
      c := GifNextPixel;
    end;
    output(ent);
    output(EOFCode);
  end;

begin
  Bitmap.PixelFormat := pf8bit;
  Stream.Write('GIF89a', 6);
  w := Bitmap.Width;
  h := Bitmap.Height;
  Stream.Write(w, 2);
  Stream.Write(h, 2);
  flags := $e7;
  Stream.Write(flags, 1);
  flags := 0;
  Stream.Write(flags, 1);
  Stream.Write(flags, 1);
  GetPaletteEntries(Bitmap.Palette, 0, 256, Palette);
  for i := 0 to 255 do
  begin
    Stream.Write(Palette[i].peRed, 1);
    Stream.Write(Palette[i].peGreen, 1);
    Stream.Write(Palette[i].peBlue, 1);
  end;
  Stream.Write(String('!'), 1);
  flags := $F9;
  Stream.Write(flags, 1);
  flags := 4;
  Stream.Write(flags, 1);
  flags := 0;
  Stream.Write(flags, 1);
  Stream.Write(flags, 1);
  Stream.Write(flags, 1);
  Stream.Write(flags, 1);
  Stream.Write(flags, 1);
  Stream.Write(String('!'), 1);
  flags := 254;
  Stream.Write(flags, 1);
  s := 'FastReport';
  flags := Length(s);
  Stream.Write(flags, 1);
  Stream.Write(s[1], flags);
  flags := 0;
  Stream.Write(flags, 1);
  curx := 0;
  cury := 0;
  CountDown := Bitmap.Width * Bitmap.Height;
  Stream.Write(String(','), 1);
  Putword(0);
  Putword(0);
  Putword(Bitmap.Width);
  Putword(Bitmap.Height);
  flags := 0;
  Stream.Write(flags, 1);
  InitCodeSize := 8;
  b := byte(InitCodeSize);
  Stream.Write(b, 1);
  compressLZW(InitCodeSize + 1);
  flags := 0;
  Stream.Write(flags, 1);
  Stream.Write(String(';'), 1);
end;

constructor TfrxGIFExport.Create(AOwner: TComponent);
begin
  inherited;
  FilterDesc := frxResources.Get('GifexportFilter');
  DefaultExt := '.gif';
end;

class function TfrxGIFExport.GetDescription: String;
begin
  Result := frxResources.Get('GIFexport');
end;

procedure TfrxGIFExport.Save;
var
  TFStream: TFileStream;
begin
  inherited;
  try
    if Stream <> nil then
      GIFSaveToStream(Stream, FBitmap)
    else
    begin
      TFStream := TFileStream.Create(ChangeFileExt(FileName, FFileSuffix + '.gif'), fmCreate);
      try
        GIFSaveToStream(TFStream, FBitmap);
      finally
        TFStream.Free;
      end;
    end;
  except
    on e: Exception do
      case Report.EngineOptions.NewSilentMode of
        simSilent:        Report.Errors.Add(e.Message);
        simMessageBoxes:  frxErrorMsg(e.Message);
        simReThrow:       raise;
      end;
  end;
end;

procedure TfrxIMGExportDialog.PageNumbersEChange(Sender: TObject);
begin
  PageNumbersRB.Checked := True;
end;

procedure TfrxIMGExportDialog.PageNumbersEKeyPress(Sender: TObject;
  var Key: Char);
begin
  case key of
    '0'..'9':;
    #8, '-', ',':;
  else
    key := #0;
  end;
end;

procedure TfrxIMGExportDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

end.

