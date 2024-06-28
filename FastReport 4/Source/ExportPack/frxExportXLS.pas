
{******************************************}
{                                          }
{             FastReport v4.0              }
{         Excel OLE export filter          }
{                                          }
{         Copyright (c) 1998-2006          }
{          by Alexander Fediachov,         }
{             Fast Reports Inc.            }
{                                          }
{******************************************}
{               Improved by:               }
{              Serge Buzadzhy              }
{             buzz@devrace.com             }
{              Bysoev Alexander            }
{             Kanal-B@Yandex.ru            }
{******************************************}

unit frxExportXLS;

interface

{$I frx.inc}
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Printers, ComObj, frxClass, frxProgress,
  frxExportMatrix, Clipbrd, ActiveX
{$IFDEF Delphi6}, Variants {$ENDIF};

type
  TfrxXLSExportDialog = class(TForm)
    OkB: TButton;
    CancelB: TButton;
    SaveDialog1: TSaveDialog;
    GroupPageRange: TGroupBox;
    DescrL: TLabel;
    AllRB: TRadioButton;
    CurPageRB: TRadioButton;
    PageNumbersRB: TRadioButton;
    PageNumbersE: TEdit;
    GroupQuality: TGroupBox;
    MergeCB: TCheckBox;
    WCB: TCheckBox;
    ContinuousCB: TCheckBox;
    PicturesCB: TCheckBox;
    OpenExcelCB: TCheckBox;
    AsTextCB: TCheckBox;
    BackgrCB: TCheckBox;
    FastExpCB: TCheckBox;
    PageBreaksCB: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure PageNumbersEChange(Sender: TObject);
    procedure PageNumbersEKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  end;

  TfrxExcel = class;

  TfrxXLSExport = class(TfrxCustomExportFilter)
  private
    FExcel: TfrxExcel;
    FExportPictures: Boolean;
    FExportStyles: Boolean;
    FFirstPage: Boolean;
    FMatrix: TfrxIEMatrix;
    FMergeCells: Boolean;
    FOpenExcelAfterExport: Boolean;
    FPageBottom: Extended;
    FPageLeft: Extended;
    FPageRight: Extended;
    FPageTop: Extended;
    FPageOrientation: TPrinterOrientation;
    FProgress: TfrxProgress;
    FWysiwyg: Boolean;
    FAsText: Boolean;
    FBackground: Boolean;
    FFastExport: Boolean;
    FpageBreaks: Boolean;
    FEmptyLines: Boolean;
    procedure ExportPage_Fast;
    procedure ExportPage;
    function CleanReturns(const Str: String): String;
    function FrameTypesToByte(Value: TfrxFrameTypes): Byte;
    function GetNewIndex(Strings: TStrings; ObjValue: Integer): Integer;
  public
    constructor Create(AOwner: TComponent); override;
    class function GetDescription: String; override;
    function ShowModal: TModalResult; override;
    function Start: Boolean; override;
    procedure Finish; override;
    procedure FinishPage(Page: TfrxReportPage; Index: Integer); override;
    procedure StartPage(Page: TfrxReportPage; Index: Integer); override;
    procedure ExportObject(Obj: TfrxComponent); override;
  published
    property ExportStyles: Boolean read FExportStyles write FExportStyles default True;
    property ExportPictures: Boolean read FExportPictures write FExportPictures default True;
    property MergeCells: Boolean read FMergeCells write FMergeCells default True;
    property OpenExcelAfterExport: Boolean read FOpenExcelAfterExport
      write FOpenExcelAfterExport default False;
    property Wysiwyg: Boolean read FWysiwyg write FWysiwyg default True;
    property AsText: Boolean read FAsText write FAsText;
    property Background: Boolean read FBackground write FBackground;
    property FastExport: Boolean read FFastExport write FFastExport;
    property PageBreaks: Boolean read FpageBreaks write FPageBreaks;
    property EmptyLines: Boolean read FEmptyLines write FEmptyLines;
    property SuppressPageHeadersFooters;
  end;

  TfrxExcel = class(TObject)
  private
    FIsOpened: Boolean;
    FIsVisible: Boolean;
    Excel: Variant;
    WorkBook: Variant;
    WorkSheet: Variant;
    Range: Variant;
    function ByteToFrameTypes(Value: Byte): TfrxFrameTypes;
  protected
    function IntToCoord(X, Y: Integer): String;
    function Pos2Str(Pos: Integer): String;
    procedure SetVisible(DoShow: Boolean);
    procedure ApplyStyles(aRanges:TStrings; Kind:byte;aProgress: TfrxProgress);
    procedure ApplyFrame(const RangeCoord:string; aFrame:byte);
    procedure SetRowsSize(aRanges: TStrings; Sizes: array of Currency;MainSizeIndex:integer;RowsCount:integer;aProgress: TfrxProgress);
    procedure ApplyStyle(const RangeCoord: string; aStyle: integer);
    procedure ApplyFormats(aRanges: TStringlist; aProgress: TfrxProgress);
    procedure ApplyFormat(const RangeCoord, aFormat: String);
  public
    constructor Create;
    destructor Destroy; override;
    procedure MergeCells;
    procedure SetCellFrame(Frame: TfrxFrameTypes);
    procedure SetRowSize(y: Integer; Size: Extended);
    procedure OpenExcel;
    procedure SetColSize(x: Integer; Size: Extended);
    procedure SetPageMargin(Left, Right, Top, Bottom: Extended;
      Orientation: TPrinterOrientation);
    procedure SetRange(x, y, dx, dy: Integer);
    property Visible: Boolean read FIsVisible write SetVisible;
  end;


implementation

uses frxUtils, frxFileUtils, frxRes, frxrcExports;

{$R *.dfm}

const
  Xdivider = 8;
  Ydivider = 1.315;
  XLMaxHeight = 409;
  XLMaxChars = 900;
  xlLeft = -4131;
  xlRight = -4152;
  xlTop = -4160;
  xlCenter = -4108 ;
  xlBottom = -4107;
  xlJustify = -4130 ;
  xlThin = 2;
  xlHairline = 1;
  xlNone = -4142;
  xlAutomatic = -4105;
  xlInsideHorizontal = 12 ;
  xlInsideVertical = 11 ;
  xlEdgeBottom = 9 ;
  xlEdgeLeft = 7 ;
  xlEdgeRight = 10 ;
  xlEdgeTop = 8 ;
  xlSolid = 1 ;
  xlLineStyleNone = -4142;
  xlTextWindows = 20 ;
  xlNormal = -4143 ;
  xlNoChange = 1 ;
  xlPageBreakManual = -4135 ;
  xlSizeYRound = 0.25;

{ TfrxXLSExport }

type
  TArrData = array [1..1] of variant;
  PArrData = ^TArrData;
  PFrameTypes = ^TfrxFrameTypes;

constructor TfrxXLSExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMergeCells := True;
  FExportPictures := True;
  FExportStyles := True;
  FWysiwyg := True;
  FAsText := False;
  FBackground := True;
  FFastExport := True;
  FPageBreaks := True;
  FilterDesc := frxGet(8009);
  DefaultExt := frxGet(8010);
  FEmptyLines := True;
end;

class function TfrxXLSExport.GetDescription: String;
begin
  Result := frxResources.Get('XlsOLEexport');
end;

function TfrxXLSExport.FrameTypesToByte(Value: TfrxFrameTypes): Byte;
begin
  Result := PByte(@Value)^
end;

function TfrxXLSExport.GetNewIndex(Strings: TStrings; ObjValue: Integer): Integer;
var
  L, H, I, C: Integer;
begin
  Result:=0;
  if Strings.Count > 0 then
  begin
    L := 0;
    H := Strings.Count - 1;
    while L <= H do
    begin
      I := (L + H) shr 1;
      C:= Integer(Strings.Objects[I]) - ObjValue;
      if C < 0 then
        L := I + 1
      else begin
        H := I - 1;
        if C = 0 then
        begin
          L := I;
          break;
        end;
      end;
    end;
    Result := L;
  end;
end;

function TfrxXLSExport.CleanReturns(const Str: string): string;
var
  i: Integer;
  s: String;
begin
  s := Str;
  i := Pos(#13, s);
  while i > 0 do
  begin
    if i > 0 then
      Delete(s, i, 1);
    i := Pos(#13, s);
  end;
  while Copy(s, Length(s), 1) = #10 do
    Delete(s, Length(s), 1);
  Result := s;
end;

{$WARNINGS OFF}
procedure TfrxXLSExport.ExportPage;
var
  i, fx, fy, x, y, dx, dy: Integer;
  dcol, drow: Extended;
  s: String;
  Vert, Horiz: Integer;
  ExlArray: Variant;
  obj: TfrxIEMObject;
  EStyle: TfrxIEMStyle;
  XStyle: Variant;
  Pic: TPicture;
  PicFormat: Word;
  PicData: Cardinal;
  PicPalette: HPALETTE;
  PicCount: Integer;
  PBreakCounter: Integer;

  procedure AlignFR2AlignExcel(HAlign: TfrxHAlign; VAlign: TfrxVAlign; var AlignH, AlignV: integer);
  begin
    if HAlign = haLeft then
      AlignH := xlLeft
    else if HAlign = haRight then
      AlignH := xlRight
    else if HAlign = haCenter then
      AlignH := xlCenter
    else if HAlign = haBlock then
      AlignH := xlJustify
    else
      AlignH := xlLeft;

    if VAlign = vaTop then
      AlignV := xlTop
    else if VAlign = vaBottom then
      AlignV := xlBottom
    else if VAlign = vaCenter then
      AlignV := xlCenter
    else
      AlignV := xlTop;
  end;

begin
  PicCount := 0;
  FExcel.SetPageMargin(FPageLeft, FPageRight, FPageTop, FPageBottom, FPageOrientation);

  if ShowProgress then
  begin
    FProgress := TfrxProgress.Create(self);
    FProgress.Execute(FMatrix.Height - 1, frxResources.Get('ProgressRows'), True, True);
  end;

  PBreakCounter := 0;
  for y := 1 to FMatrix.Height - 1 do
  begin
    if ShowProgress then
    begin
      if FProgress.Terminated then break;
      FProgress.Tick;
    end;
    drow := (FMatrix.GetYPosById(y) - FMatrix.GetYPosById(y - 1)) / Ydivider;
    FExcel.SetRowSize(y, drow);
    if (FMatrix.GetCellYPos(y) >= FMatrix.GetPageBreak(PBreakCounter)) and FpageBreaks then
    begin
      FExcel.WorkSheet.Rows[y + 2].PageBreak := xlPageBreakManual;
      Inc(PBreakCounter);
    end;
  end;

  if ShowProgress then
  begin
    if not FProgress.Terminated then
      FProgress.Execute(FMatrix.Width - 1, frxResources.Get('ProgressColumns'), True, True);
  end else;

  for x := 1 to FMatrix.Width - 1 do
  begin
    if ShowProgress then
    begin
      if FProgress.Terminated then break;
      FProgress.Tick;
    end;
    dcol := (FMatrix.GetXPosById(x) - FMatrix.GetXPosById(x - 1)) / Xdivider;
    FExcel.SetColSize(x, dcol);
  end;

  if ShowProgress then
    if not FProgress.Terminated then
      FProgress.Execute(FMatrix.StylesCount - 1, frxResources.Get('ProgressStyles'), True, True);

  for x := 0 to FMatrix.StylesCount - 1 do
  begin
    if ShowProgress then
    begin
      if FProgress.Terminated then break;
      FProgress.Tick;
    end;
    EStyle := FMatrix.GetStyleById(x);
    s := 'S' + IntToStr(x);
    XStyle := FExcel.Excel.ActiveWorkbook.Styles.Add(s);
    XStyle.Font.Bold := fsBold in EStyle.Font.Style;
    XStyle.Font.Italic := fsItalic in EStyle.Font.Style;
    XStyle.Font.Underline := fsUnderline in EStyle.Font.Style;;
    XStyle.Font.Name := EStyle.Font.Name;
    XStyle.Font.Size := EStyle.Font.Size;
    XStyle.Font.Color:= EStyle.Font.Color;
    XStyle.Interior.Color := EStyle.Color;
    AlignFR2AlignExcel(EStyle.HAlign, EStyle.VAlign, Horiz, Vert);
    XStyle.VerticalAlignment := Vert;
    XStyle.HorizontalAlignment := Horiz;
    Application.ProcessMessages;
  end;

  ExlArray := VarArrayCreate([0, FMatrix.Height - 1, 0, FMatrix.Width - 1], varOleStr);

  if ShowProgress then
    if not FProgress.Terminated then
      FProgress.Execute(FMatrix.Height, frxResources.Get('ProgressObjects'), True, True);

  for y := 1 to FMatrix.Height do
  begin
    if ShowProgress then
    begin
      if FProgress.Terminated then break;
      FProgress.Tick;
    end;
    for x := 1 to FMatrix.Width do
    begin
      i := FMatrix.GetCell(x - 1, y - 1);
      if i <> -1 then
      begin
        Obj := FMatrix.GetObjectById(i);
        if Obj.Counter = 0 then
        begin
          Obj.Counter := 1;
          FMatrix.GetObjectPos(i, fx, fy, dx, dy);
          FExcel.SetRange(x, y, dx, dy);
          if Obj.IsText then
          begin
            if FExportStyles then
              FExcel.Range.Style := 'S' + IntToStr(Obj.StyleIndex);
            if FMergeCells then
              if (dx > 1) or (dy > 1) then
                if (dx > 1) or (dy > 1) then
                begin
                  FExcel.SetRange(x, y, dx, dy);
                  FExcel.MergeCells;
                end;
            if FExportStyles then
              FExcel.SetCellFrame(obj.Style.FrameTyp);
            s := CleanReturns(Obj.Memo.Text);
            if Length(s) > XLMaxChars then
              s := Copy(s, 1, XLMaxChars);
            ExlArray[y - 1, x - 1] := s;
          end
          else
          begin
            Inc(PicCount);
            Pic := TPicture.Create;
            Pic.Bitmap.Assign(Obj.Image);
            Pic.SaveToClipboardFormat(PicFormat, PicData, PicPalette);
            Clipboard.SetAsHandle(PicFormat,THandle(PicData));
            FExcel.Range.PasteSpecial(EmptyParam, EmptyParam, EmptyParam, EmptyParam);
            FExcel.WorkSheet.Pictures[PicCount].Width := Pic.Width / 1.38;
            FExcel.WorkSheet.Pictures[PicCount].Height := Pic.Height/ 1.38;
            Pic.Free;
          end;
        end;
      end;
    end;
  end;

  FExcel.SetRange(1, 1, FMatrix.Width - 1, FMatrix.Height - 1);
  FExcel.Range.Value := ExlArray;
  FExcel.WorkSheet.Cells.WrapText := True;
  if ShowProgress then
    FProgress.Free;
end;
{$WARNINGS ON}

procedure TfrxXLSExport.ExportPage_Fast;
var
  i, fx, fy, x, y, dx, dy: Integer;
  dcol, drow: Extended;
  s: OLEVariant;
  Vert, Horiz: Integer;
  ExlArray: Variant;

  obj: TfrxIEMObject;
  EStyle: TfrxIEMStyle;
  XStyle: Variant;
  Pic: TPicture;
  PicFormat: Word;
  PicData: Cardinal;
  PicPalette: HPALETTE;
  PicCount: Integer;
  PBreakCounter: Integer;
  RowSizes: array of Currency;
  RowSizesCount: array of Integer;
  imc: Integer;
  ArrData: PArrData;
  j: Integer;
  FixRow: String;
  CurRowSize: Integer;
  CurRangeCoord: String;
  vRowsToSizes: TStrings;
  vCellStyles: TStrings;
  vCellFrames: TStrings;
  vCellMerges: TStrings;
  vCellFormats: TStringList;

  function ConvertFormat(const fstr: string): string;
  var
    i, err, p : integer;
    s: string;
  begin
    result := '';
    if length(fstr)>0 then
    begin
      p := pos('.', fstr);
      if p > 0 then
      begin
        s := Copy(fstr, p + 1, length(fstr) - p - 1);
        val(s, p ,err);
      end;
      case fstr[length(fstr)] of
        'n': begin
              result := '# ##0,';
              for i := 1 to p do result := result + '0';
             end;
        'f': begin
               result := '0,';
               for i := 1 to p do result := result + '0';
             end;
        'd': begin
               result := '#,';
               for i := 1 to p do result := result + '#';
             end;
      end;
    end;
  end;

  procedure AlignFR2AlignExcel(HAlign: TfrxHAlign; VAlign: TfrxVAlign; var AlignH, AlignV: integer);
  begin
    if HAlign = haLeft then
      AlignH := xlLeft
    else if HAlign = haRight then
      AlignH := xlRight
    else if HAlign = haCenter then
      AlignH := xlCenter
    else if HAlign = haBlock then
      AlignH := xlJustify
    else
      AlignH := xlLeft;

    if VAlign = vaTop then
      AlignV := xlTop
    else if VAlign = vaBottom then
      AlignV := xlBottom
    else if VAlign = vaCenter then
      AlignV := xlCenter
    else
      AlignV := xlTop;
  end;

  function RoundSizeY(const Value: Extended; xlSizeYRound: Currency): Currency;
  begin
    Result := Round(Value / xlSizeYRound) * xlSizeYRound
  end;

  function GetSizeIndex(const aSize: Currency): integer;
  var
    i: integer;
    c: integer;
  begin
    c := Length(RowSizes);
    for i := 0 to c - 1 do
    begin
      if RowSizes[i] = aSize then
      begin
        Result := i;
        RowSizesCount[i] := RowSizesCount[i] + 1;
        Exit
      end;
    end;
    SetLength(RowSizes, c + 1);
    SetLength(RowSizesCount,c + 1);
    RowSizes[c] := aSize;
    RowSizesCount[c] := 1;
    Result := c
  end;

begin
  PicCount := 0;
  FExcel.SetPageMargin(FPageLeft, FPageRight, FPageTop, FPageBottom, FPageOrientation);

  if ShowProgress then
  begin
    FProgress := TfrxProgress.Create(self);
    FProgress.Execute(FMatrix.Height - 1, frxResources.Get('ProgressRows') + ' - 1', True, True);
  end;

  PBreakCounter := 0;

  FixRow := 'A1';
  CurRowSize := 0;
  vRowsToSizes := TStringList.Create;
  try
    vRowsToSizes.Capacity := FMatrix.Height;
    imc := 0;
    for y := 1 to FMatrix.Height - 1 do
    begin
      if ShowProgress then
      begin
       if FProgress.Terminated then
         break;
       FProgress.Tick;
      end;

      if (FMatrix.GetCellYPos(y) >= FMatrix.GetPageBreak(PBreakCounter)) and FpageBreaks then
      begin
        FExcel.WorkSheet.Rows[y + 2].PageBreak := xlPageBreakManual;
        Inc(PBreakCounter);
      end;

      drow := (FMatrix.GetYPosById(y) - FMatrix.GetYPosById(y - 1)) / Ydivider;
      j := GetSizeIndex(RoundSizeY(drow, xlSizeYRound));
      if RowSizesCount[j] > RowSizesCount[imc] then
        imc := j;
      if y > 1 then
      begin
        if j <> CurRowSize then
        begin
          if FixRow <> 'A' + IntToStr(y - 1) then
            CurRangeCoord := FixRow + ':A' + IntToStr(y - 1)
          else
            CurRangeCoord := FixRow;
          i := GetNewIndex(vRowsToSizes, CurRowSize);
          vRowsToSizes.InsertObject(i, CurRangeCoord, TObject(CurRowSize));
          FixRow := 'A' + IntToStr(y);
          CurRowSize := j;
        end;
      end;
      if y = FMatrix.Height - 1 then
      begin
        CurRangeCoord := FixRow + ':A' + IntToStr(y);
        i := GetNewIndex(vRowsToSizes, j);
        vRowsToSizes.InsertObject(i, CurRangeCoord, TObject(j));
      end;
    end;
    FExcel.SetRowsSize(vRowsToSizes, RowSizes, imc, FMatrix.Height, FProgress)
  finally
    vRowsToSizes.Free;
  end;

  if ShowProgress then
    if not FProgress.Terminated then
      FProgress.Execute(FMatrix.Width - 1, frxResources.Get('ProgressColumns'), True, True);

  for x := 1 to FMatrix.Width - 1 do
  begin
    if ShowProgress then
    begin
      if FProgress.Terminated then
        break;
      FProgress.Tick;
    end;
    dcol := (FMatrix.GetXPosById(x) - FMatrix.GetXPosById(x - 1)) / Xdivider;
    FExcel.SetColSize(x, dcol);
  end;

  if ShowProgress then
    if not FProgress.Terminated then
      FProgress.Execute(FMatrix.StylesCount - 1, frxResources.Get('ProgressStyles'), True, True);

  for x := 0 to FMatrix.StylesCount - 1 do
  begin
    if ShowProgress then
    begin
      if FProgress.Terminated then break;
      FProgress.Tick;
    end;
    EStyle := FMatrix.GetStyleById(x);
    s := 'S' + IntToStr(x);
    XStyle := FExcel.Excel.ActiveWorkbook.Styles.Add(s);
    XStyle.Font.Bold := fsBold in EStyle.Font.Style;
    XStyle.Font.Italic := fsItalic in EStyle.Font.Style;
    XStyle.Font.Underline := fsUnderline in EStyle.Font.Style;;
    XStyle.Font.Name := EStyle.Font.Name;
    XStyle.Font.Size := EStyle.Font.Size;
    XStyle.Font.Color:= EStyle.Font.Color;
    XStyle.Interior.Color := EStyle.Color;
    if (EStyle.Rotation > 0) and (EStyle.Rotation <= 90) then
      XStyle.Orientation := EStyle.Rotation
    else
      if (EStyle.Rotation < 360) and (EStyle.Rotation >= 270) then
        XStyle.Orientation := EStyle.Rotation - 360;

    AlignFR2AlignExcel(EStyle.HAlign, EStyle.VAlign, Horiz, Vert);
    XStyle.VerticalAlignment := Vert;
    XStyle.HorizontalAlignment := Horiz;
    Application.ProcessMessages;
  end;
  ExlArray := VarArrayCreate([1, FMatrix.Height , 1, FMatrix.Width ], varVariant);
  if ShowProgress then
    if not FProgress.Terminated then
      FProgress.Execute(FMatrix.Height, frxResources.Get('ProgressObjects'), True, True);
  ArrData := VarArrayLock(ExlArray) ;
  vCellStyles := TStringList.Create;
  vCellFrames := TStringList.Create;
  vCellMerges := TStringList.Create;
  vCellFormats := TStringList.Create;
  try
    for y := 1 to FMatrix.Height do
    begin
      if ShowProgress then
      begin
        if FProgress.Terminated then
          Break;
        FProgress.Tick;
      end;
      for x := 1 to FMatrix.Width do
      begin
        i := FMatrix.GetCell(x - 1, y - 1);
        if i <> -1 then
        begin
          Obj := FMatrix.GetObjectById(i);
          if Obj.Counter = 0 then
          begin
            Obj.Counter := 1;
            FMatrix.GetObjectPos(i, fx, fy, dx, dy);
            with FExcel do
            if  (dx > 1) or (dy > 1) then
              CurRangeCoord := IntToCoord(x, y)+ ':' +
                IntToCoord(x + dx - 1, y + dy - 1)
            else
              CurRangeCoord := IntToCoord(x, y);
            if FExportStyles then
            begin
              j := GetNewIndex(vCellStyles, Obj.StyleIndex);
              vCellStyles.InsertObject(j, CurRangeCoord, TObject(Obj.StyleIndex));
            end;

            if FMergeCells then
              if (dx > 1) or (dy > 1) then
                vCellMerges.Add(CurRangeCoord);
            if FExportStyles then
            begin
              i := FrameTypesToByte(obj.Style.FrameTyp);
              if i <> 0 then
              begin
                j := GetNewIndex(vCellFrames, i);
                vCellFrames.InsertObject(j, CurRangeCoord, TObject(i));
              end;
            end;

            s := CleanReturns(Obj.Memo.Text);
            if Length(s) > XLMaxChars then
              s := Copy(s, 1, XLMaxChars);

            if not FAsText then
              if (Obj.Style.DisplayFormat.Kind = fkNumeric) then
              begin
                if length(s) > 0 then
                  begin
                  s := StringReplace(s, ThousandSeparator, '', [rfReplaceAll]);
                  if Obj.Style.DisplayFormat.DecimalSeparator <> '' then
                    s := StringReplace(s, Obj.Style.DisplayFormat.DecimalSeparator, '.', [rfReplaceAll])
                  else
                    s := StringReplace(s, DecimalSeparator, '.', [rfReplaceAll]);
                  if (Obj.Style.DisplayFormat.FormatStr <> '') then
                    vCellFormats.Add(ConVertFormat(Obj.Style.DisplayFormat.FormatStr) +
                      '=' + FExcel.IntToCoord(x, y))
                end
              end
              else
                if (Obj.Style.DisplayFormat.Kind = fkText) then
                  s := '''' + s;

            if FAsText then
              s := '''' + s;
            ArrData^[y + FMatrix.Height * (x - 1)] := s;
            if not Obj.IsText then
            begin
              FExcel.SetRange(x, y, dx, dy);
              Inc(PicCount);
              Pic := TPicture.Create;
              Pic.Bitmap.Assign(Obj.Image);
              Pic.SaveToClipboardFormat(PicFormat, PicData, PicPalette);
              Clipboard.SetAsHandle(PicFormat,THandle(PicData));
              FExcel.Range.PasteSpecial(EmptyParam, EmptyParam, EmptyParam, EmptyParam);
              FExcel.WorkSheet.Pictures[PicCount].Left := FExcel.WorkSheet.Pictures[PicCount].Left + 1;
              FExcel.WorkSheet.Pictures[PicCount].Top := FExcel.WorkSheet.Pictures[PicCount].Top + 1;
              FExcel.WorkSheet.Pictures[PicCount].Width := Pic.Width / 1.38;
              FExcel.WorkSheet.Pictures[PicCount].Height := Pic.Height/ 1.38;
              Pic.Free;
            end;
          end;
        end;
      end;
    end;

    if FExportStyles then
    begin
      FExcel.ApplyStyles(vCellStyles, 0, FProgress);
      FExcel.ApplyStyles(vCellFrames, 1, FProgress);
      FExcel.ApplyFormats(vCellFormats, FProgress);
    end;
    if FMergeCells then
      FExcel.ApplyStyles(vCellMerges, 2, FProgress);
  finally
    VarArrayUnlock(ExlArray);
    vCellStyles.Free;
    vCellFrames.Free;
    vCellMerges.Free;
    vCellFormats.Free;
  end;
  FExcel.SetRange(1, 1, FMatrix.Width , FMatrix.Height);
  FExcel.Range.Value := ExlArray;
  FExcel.WorkSheet.Cells.WrapText := True;
  if ShowProgress then
    FProgress.Free;
end;

function TfrxXLSExport.ShowModal: TModalResult;
begin
  with TfrxXLSExportDialog.Create(nil) do
  begin
    OpenExcelCB.Visible := not SlaveExport;
    if SlaveExport then
      FOpenExcelAfterExport := False;

    if (FileName = '') and (not SlaveExport) then
      SaveDialog1.FileName := ChangeFileExt(ExtractFileName(Report.FileName), SaveDialog1.DefaultExt)
    else
      SaveDialog1.FileName := FileName;

    ContinuousCB.Checked := (not EmptyLines) or SuppressPageHeadersFooters;
    PicturesCB.Checked := FExportPictures;
    MergeCB.Checked := FMergeCells;
    WCB.Checked := FWysiwyg;
    OpenExcelCB.Checked := FOpenExcelAfterExport;
    AsTextCB.Checked := FAsText;
    BackgrCB.Checked := FBackground;
    FastExpCB.Checked := FFastExport;
    PageBreaksCB.Checked := FpageBreaks;

    if PageNumbers <> '' then
    begin
      PageNumbersE.Text := PageNumbers;
      PageNumbersRB.Checked := True;
    end;

    Result := ShowModal;
    if Result = mrOk then
    begin
      PageNumbers := '';
      CurPage := False;
      if CurPageRB.Checked then
        CurPage := True
      else if PageNumbersRB.Checked then
        PageNumbers := PageNumbersE.Text;

      FMergeCells := MergeCB.Checked;
      FPageBreaks :=  PageBreaksCB.Checked;
      FExportPictures := PicturesCB.Checked;
      EmptyLines := not ContinuousCB.Checked;
      SuppressPageHeadersFooters := ContinuousCB.Checked;
      FWysiwyg := WCB.Checked;
      FOpenExcelAfterExport := OpenExcelCB.Checked;
      FAsText := AsTextCB.Checked;
      FBackground := BackgrCB.Checked;
      FFastExport := FastExpCB.Checked;

      if not SlaveExport then
      begin
        if DefaultPath <> '' then
          SaveDialog1.InitialDir := DefaultPath;
        if SaveDialog1.Execute then
          FileName := SaveDialog1.FileName
        else
          Result := mrCancel;
      end
      else
        FileName := ChangeFileExt(GetTempFile, SaveDialog1.DefaultExt);
    end;
    Free;
  end;
end;

function TfrxXLSExport.Start: Boolean;
begin
  if FileName <> '' then
  begin
    if (ExtractFilePath(FileName) = '') and (DefaultPath <> '') then
      if DefaultPath[Length(DefaultPath)] = '\' then
        FileName := DefaultPath + FileName
      else
        FileName := DefaultPath + '\' + FileName;
    FFirstPage := True;
    FMatrix := TfrxIEMatrix.Create(UseFileCache, Report.EngineOptions.TempDir);
    FMatrix.ShowProgress := ShowProgress;
    FMatrix.MaxCellHeight := XLMaxHeight * Ydivider;
    FMatrix.BackgroundImage := False;
    FMatrix.Background := FBackground and FEmptyLines;
    FMatrix.RichText := True;
    FMatrix.PlainRich := True;
    if FWysiwyg then
      FMatrix.Inaccuracy := 0.5
    else
      FMatrix.Inaccuracy := 10;
    FMatrix.RotatedAsImage := False;
    FMatrix.DeleteHTMLTags := True;
    FMatrix.Printable := ExportNotPrintable;
    FMatrix.EmptyLines := FEmptyLines;
    FExcel := TfrxExcel.Create;
    FExcel.OpenExcel;
    Result := True;
  end
  else
    Result := False;
end;

procedure TfrxXLSExport.StartPage(Page: TfrxReportPage; Index: Integer);
begin
  if FFirstPage then
  begin
    FFirstPage := False;
    FPageLeft := Page.LeftMargin * 2.6;
    FPageTop := Page.TopMargin * 2.6;
    FPageBottom := Page.BottomMargin * 2.6;
    FPageRight := Page.RightMargin * 2.6;
    FPageOrientation := Page.Orientation;
  end;
end;

procedure TfrxXLSExport.ExportObject(Obj: TfrxComponent);
begin
  if Obj is TfrxView then
    if (Obj is TfrxCustomMemoView) or
      (FExportPictures and (not (Obj is TfrxCustomMemoView))) then
        FMatrix.AddObject(TfrxView(Obj));
end;

procedure TfrxXLSExport.FinishPage(Page: TfrxReportPage; Index: Integer);
begin
  FMatrix.AddPage(Page.Orientation, Page.Width, Page.Height, Page.LeftMargin,
                  Page.TopMargin, Page.RightMargin, Page.BottomMargin);
end;

procedure TfrxXLSExport.Finish;

begin
  FMatrix.Prepare;
  try
    if FFastExport then
      ExportPage_Fast
    else
      ExportPage;

    FExcel.SetRange(1, 1, 1, 1);
    FExcel.Range.Select;
    if FOpenExcelAfterExport then
      FExcel.Visible := True;
  finally
    try
      try
        if ExtractFilePath(FileName) = '' then
          FileName := GetCurrentDir + '\' + FileName;
        FExcel.WorkBook.SaveAs(FileName, xlNormal, EmptyParam,
          EmptyParam, EmptyParam, EmptyParam, xlNoChange, EmptyParam, EmptyParam, EmptyParam);
      finally
        FExcel.Excel.Application.DisplayAlerts := True;
        FExcel.Excel.Application.ScreenUpdating := True;
      end;
      if not FOpenExcelAfterExport then
      begin
        FExcel.Excel.Quit;
        FExcel.Excel := Null;
        FExcel.Excel := Unassigned;
      end;
    except
    end;
  end;
  FMatrix.Free;
  FExcel.Free;
end;


{ TfrxExcel }

constructor TfrxExcel.Create;
begin
  inherited Create;
  FIsOpened := False;
  FIsVisible := False;
  OleInitialize(nil);
end;

function TfrxExcel.Pos2Str(Pos: Integer): String;
var
  i, j: Integer;
begin
  if Pos > 26 then
  begin
    i := Pos mod 26;
    j := Pos div 26;
    if i = 0 then
      Result := Chr(64 + j - 1)
    else
      Result := Chr(64 + j);
    if i = 0 then
      Result := Result + chr(90)
    else
      Result := Result + Chr(64 + i);
  end
  else
    Result := Chr(64 + Pos);
end;

procedure TfrxExcel.SetVisible(DoShow: Boolean);
begin
  if not FIsOpened then Exit;
  if DoShow then
    Excel.Visible := True
  else
    Excel.Visible := False;
end;

function TfrxExcel.IntToCoord(X, Y: Integer): String;
begin
  Result := Pos2Str(X) + IntToStr(Y);
end;

procedure TfrxExcel.SetColSize(x: Integer; Size: Extended);
var
  r: Variant;
begin
  if (Size > 0) and (Size < 256) and (x < 256) then
  begin
    try
      r := WorkSheet.Columns;
      r.Columns[x].ColumnWidth := Size;
    except
    end;
  end;
end;

procedure TfrxExcel.SetRowSize(y: Integer; Size: Extended);
var
  r: Variant;
begin
  if Size > 0 then
  begin
    r := WorkSheet.Rows;
    if size > 409 then
      size := 409;
    r.Rows[y].RowHeight := Size;
  end;
end;

procedure TfrxExcel.MergeCells;
begin
  Range.MergeCells := True;
end;

procedure TfrxExcel.OpenExcel;
begin
  try
    Excel := CreateOLEObject('Excel.Application');
    Excel.Application.ScreenUpdating := False;
    Excel.Application.DisplayAlerts := False;
    WorkBook := Excel.WorkBooks.Add;
    WorkSheet := WorkBook.WorkSheets[1];
    FIsOpened := True;
  except
    FIsOpened := False;
  end;
end;

procedure TfrxExcel.SetPageMargin(Left, Right, Top, Bottom: Extended;
  Orientation: TPrinterOrientation);
var
  Orient: Integer;
begin
  if Orientation = poLandscape then
    Orient := 2
  else
    Orient := 1;
  try
    Excel.ActiveSheet.PageSetup.LeftMargin := Left;
    Excel.ActiveSheet.PageSetup.RightMargin := Right;
    Excel.ActiveSheet.PageSetup.TopMargin := Top;
    Excel.ActiveSheet.PageSetup.BottomMargin := Bottom;
    Worksheet.PageSetup.Orientation := Orient;
  except
  end;
end;

procedure TfrxExcel.SetRange(x, y, dx, dy: Integer);
begin
  try
    if x > 255 then
      x := 255;
    if (x + dx) > 255 then
      dx := 255 - x;
    if (dx > 0) and (dy > 0) then
      Range := WorkSheet.Range[IntToCoord(x, y), IntToCoord(x + dx - 1, y + dy - 1)];
  except
  end;
end;

procedure TfrxExcel.SetRowsSize(aRanges: TStrings;
  Sizes: array of Currency; MainSizeIndex: integer;
  RowsCount:integer; aProgress: TfrxProgress);
var
  i: integer;
  s: string;
  curSizes: integer;
  v: Variant;
begin
  if aRanges.Count > 0 then
  begin

    if Assigned(aProgress) then
      if not aProgress.Terminated then
      begin
        s := frxResources.Get('ProgressRows') + ' - 2';
        aProgress.Execute(aRanges.Count, s, True, True);
      end;

    WorkSheet.Range['A1:A' + IntToStr(RowsCount)].RowHeight := Sizes[MainSizeIndex];
    s := aRanges[0];
    curSizes := Integer(aRanges.Objects[0]);

    for i := 1 to Pred(aRanges.Count) do
    begin

      if Assigned(aProgress) then
      begin
        if aProgress.Terminated then
          Break;
        aProgress.Tick;
      end;

      if Integer(aRanges.Objects[i]) = MainSizeIndex then
        Continue;
      if Integer(aRanges.Objects[i]) <> curSizes then
      begin
        if curSizes <> MainSizeIndex then
        begin
          try
            v := WorkSheet.Range[s];
            v.RowHeight := Sizes[curSizes];
          except
          end;
        end;
        curSizes := Integer(aRanges.Objects[i]);
        s := aRanges[i];
      end
      else if Length(s) + Length(aRanges[i]) + 1 > 255 then
      begin
        try
          v := WorkSheet.Range[s];
          v.RowHeight := Sizes[curSizes];
        except
        end;
        s := aRanges[i];
      end
      else s := s + ';' + aRanges[i]
    end;

    if Length(s) > 0 then
    begin
      try
        v := WorkSheet.Range[s].Rows;
        v.RowHeight := Sizes[curSizes];
      except
      end;
    end;

  end;
end;

procedure TfrxExcel.ApplyStyles(aRanges: TStrings; Kind: byte; aProgress: TfrxProgress);
// Kind=0 - Styles
// Kind=1 - Frames
// Kind=2 - Merge
var
  i: integer;
  s: string;
  curStyle: integer;
begin
  if aRanges.Count > 0 then
  begin
    if Assigned(aProgress) then
      if not aProgress.Terminated then
        aProgress.Execute(aRanges.Count, frxResources.Get('ProgressStyles') + ' - ' + IntToStr(Kind + 1), True, True);

    s := aRanges[0];
    curStyle := Integer(aRanges.Objects[0]);
    for i := 1 to Pred(aRanges.Count) do
    begin
     if Assigned(aProgress) then
     begin
       if aProgress.Terminated then
         Break;
       aProgress.Tick;
     end;
     if Integer(aRanges.Objects[i]) <> CurStyle then
     begin
       case Kind of
         0: ApplyStyle(s, CurStyle);
         1: ApplyFrame(s, CurStyle);
      end;
      CurStyle := Integer(aRanges.Objects[i]);
      s := aRanges[i];
     end
     else if Length(s) + Length(aRanges[i]) + 1 > 255 then
     begin
       case Kind of
         0: ApplyStyle(s, CurStyle);
         1: ApplyFrame(s, CurStyle);
         2: try
              WorkSheet.Range[s].MergeCells := True;
            except
            end;
      end;
      s := aRanges[i];
     end
     else s := s + ListSeparator + aRanges[i]
    end;
    case Kind of
      0: ApplyStyle(s, CurStyle);
      1: ApplyFrame(s, CurStyle);
      2: try
           WorkSheet.Range[s].MergeCells := True;
         except
         end;
    end;
  end;
end;

procedure TfrxExcel.ApplyStyle(const RangeCoord: String; aStyle: Integer);
begin
  try
    if Length(RangeCoord) > 0 then
      WorkSheet.Range[RangeCoord].Style := 'S' + IntToStr(aStyle)
  except
  end;
end;

function TfrxExcel.ByteToFrameTypes(Value: Byte): TfrxFrameTypes;
begin
  Result := PFrameTypes(@Value)^
end;

procedure TfrxExcel.ApplyFrame(const RangeCoord: String; aFrame: Byte);
var
  vFrame: TfrxFrameTypes;
  vBorders: Variant;
begin
  try
    if aFrame <> 0 then
      if Length(RangeCoord) > 0 then
      begin
        vFrame := ByteToFrameTypes(aFrame);
        vBorders := WorkSheet.Range[RangeCoord].Cells.Borders;
        if ftLeft in vFrame then
          vBorders.Item[xlEdgeLeft].Linestyle := xlSolid;
        if ftRight in vFrame then
          vBorders.Item[xlEdgeRight].Linestyle := xlSolid;
        if ftTop in vFrame then
          vBorders.Item[xlEdgeTop].Linestyle := xlSolid;
        if ftBottom in vFrame then
          vBorders.Item[xlEdgeBottom].Linestyle := xlSolid;
      end;
  except
  end;
end;

procedure TfrxExcel.SetCellFrame(Frame: TfrxFrameTypes);
begin
  if ftLeft in Frame then
    Range.Cells.Borders.Item[xlEdgeLeft].Linestyle := xlSolid;
  if ftRight in Frame then
    Range.Cells.Borders.Item[xlEdgeRight].Linestyle := xlSolid;
  if ftTop in Frame then
    Range.Borders.Item[xlEdgeTop].Linestyle := xlSolid;
  if ftBottom in Frame then
    Range.Borders.Item[xlEdgeBottom].Linestyle := xlSolid;
end;

procedure TfrxExcel.ApplyFormats(aRanges: TStringlist; aProgress: TfrxProgress);
var
  i: integer;
  s: string;
  curFormat: string;

  function ValueFrom(List: TStringList; Index: Integer): String;
  begin
    if Index >= 0 then
      Result := Copy(List[Index], Length(List.Names[Index]) + 2, MaxInt) else
      Result := '';
  end;

begin
  if aRanges.Count > 0 then
  begin
    if Assigned(aProgress) then
      aProgress.Execute(aRanges.Count, 'Data formats', True, True);
    s := ValueFrom(aRanges, 0);
    curFormat := aRanges.Names[0];
    for i := 1 to Pred(aRanges.Count) do
    begin
      if Assigned(aProgress) then
      begin
        if aProgress.Terminated then
          Break;
        aProgress.Tick;
      end;
      if aRanges.Names[i] <> CurFormat then
      begin
        ApplyFormat(s, CurFormat);
        CurFormat := aRanges.Names[i];
        s := ValueFrom(aRanges, i);
      end
      else
      if Length(s) + Length(ValueFrom(aRanges, i)) + 1 > 255 then
      begin
        ApplyFormat(s, CurFormat);
        s := ValueFrom(aRanges, i);
      end
      else
        s := s + ListSeparator + ValueFrom(aRanges, i)
    end;
      ApplyFormat(s, CurFormat);
  end;
end;

procedure TfrxExcel.ApplyFormat(const RangeCoord, aFormat: String);
begin
  if Length(RangeCoord) > 0 then
  try
    WorkSheet.Range[RangeCoord].NumberFormat := aFormat;
  except
  end;
end;

destructor TfrxExcel.Destroy;
begin
  OleUnInitialize;
  inherited;
end;

{ TfrxXLSExportDialog }

procedure TfrxXLSExportDialog.FormCreate(Sender: TObject);
begin
  Caption := frxGet(8000);
  OkB.Caption := frxGet(1);
  CancelB.Caption := frxGet(2);
  GroupPageRange.Caption := frxGet(7);
  AllRB.Caption := frxGet(3);
  CurPageRB.Caption := frxGet(4);
  PageNumbersRB.Caption := frxGet(5);
  DescrL.Caption := frxGet(9);
  GroupQuality.Caption := frxGet(8);
  ContinuousCB.Caption := frxGet(8950);
  PicturesCB.Caption := frxGet(8002);
  MergeCB.Caption := frxGet(8003);
  PageBreaksCB.Caption := frxGet(6);
  FastExpCB.Caption := frxGet(8004);
  WCB.Caption := frxGet(8005);
  AsTextCB.Caption := frxGet(8006);
  BackgrCB.Caption := frxGet(8007);
  OpenExcelCB.Caption := frxGet(8008);
  SaveDialog1.Filter := frxGet(8009);
  SaveDialog1.DefaultExt := frxGet(8010);
end;

procedure TfrxXLSExportDialog.PageNumbersEChange(Sender: TObject);
begin
  PageNumbersRB.Checked := True;
end;

procedure TfrxXLSExportDialog.PageNumbersEKeyPress(Sender: TObject;
  var Key: Char);
begin
  case key of
    '0'..'9':;
    #8, '-', ',':;
  else
    key := #0;
  end;
end;

procedure TfrxXLSExportDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

end.

