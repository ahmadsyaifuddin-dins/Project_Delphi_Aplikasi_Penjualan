
{******************************************}
{                                          }
{             FastReport v4.0              }
{            XML Excel export              }
{                                          }
{         Copyright (c) 1998-2006          }
{          by Alexander Fediachov,         }
{             Fast Reports Inc.            }
{                                          }
{******************************************}
{        Improved by Bysoev Alexander      }
{             Kanal-B@Yandex.ru            }
{******************************************}

unit frxExportXML;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, extctrls, Printers, ComObj, frxClass, frxExportMatrix, frxProgress
{$IFDEF Delphi6}, Variants {$ENDIF};

type
  TfrxXMLExportDialog = class(TForm)
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
    WCB: TCheckBox;
    ContinuousCB: TCheckBox;
    PageBreaksCB: TCheckBox;
    OpenExcelCB: TCheckBox;
    BackgrCB: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure PageNumbersEChange(Sender: TObject);
    procedure PageNumbersEKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  end;

  TfrxXMLExport = class(TfrxCustomExportFilter)
  private
    FExportPageBreaks: Boolean;
    FExportStyles: Boolean;
    FFirstPage: Boolean;
    FMatrix: TfrxIEMatrix;
    FOpenExcelAfterExport: Boolean;
    FPageBottom: Extended;
    FPageLeft: Extended;
    FPageRight: Extended;
    FPageTop: Extended;
    FPageOrientation: TPrinterOrientation;
    FProgress: TfrxProgress;
    FShowProgress: Boolean;
    FWysiwyg: Boolean;
    FBackground: Boolean;
    FCreator: String;
    FEmptyLines: Boolean;
    procedure ExportPage(Stream: TStream);
    function ChangeReturns(const Str: String): String;
    function TruncReturns(const Str: WideString): WideString;
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
    property ExportPageBreaks: Boolean read FExportPageBreaks write FExportPageBreaks default True;
    property OpenExcelAfterExport: Boolean read FOpenExcelAfterExport
      write FOpenExcelAfterExport default False;
    property ShowProgress: Boolean read FShowProgress write FShowProgress;
    property Wysiwyg: Boolean read FWysiwyg write FWysiwyg default True;
    property Background: Boolean read FBackground write FBackground default False;
    property Creator: String read FCreator write FCreator;
    property EmptyLines: Boolean read FEmptyLines write FEmptyLines;
    property SuppressPageHeadersFooters;
  end;


implementation

uses frxUtils, frxFileUtils, frxUnicodeUtils, frxRes, frxrcExports;

{$R *.dfm}

const
  Xdivider = 1.376;
  Ydivider = 1.376;
  MargDiv = 26.6;
  XLMaxHeight = 409;


{ TfrxXMLExport }

constructor TfrxXMLExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FExportPageBreaks := True;
  FExportStyles := True;
  FShowProgress := True;
  FWysiwyg := True;
  FBackground := True;
  FCreator := 'FastReport';
  FilterDesc := frxGet(8105);
  DefaultExt := frxGet(8106);
  FEmptyLines := True;
end;

class function TfrxXMLExport.GetDescription: String;
begin
  Result := frxResources.Get('XlsXMLexport');
end;

function TfrxXMLExport.TruncReturns(const Str: WideString): WideString;
begin
  Result := Str;
  if Copy(Result, Length(Result) - 1, 2) = #13#10 then
    Delete(Result, Length(Result) - 1, 2);
end;

function TfrxXMLExport.ChangeReturns(const Str: String): String;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(Str) do
  begin
    if Str[i] = '&' then
      Result := Result + '&amp;'
    else if (i < Length(Str)) and (Str[i] = #13) and (Str[i + 1] = #10) then
      Result := Result + '&#10'
    else if Str[i] = '"' then
      Result := Result + '&quot;'
    else if Str[i] = '<' then
      Result := Result + '&lt;'
    else if Str[i] = '>' then
      Result := Result + '&gt;'
    else if (Str[i] <> #10) then
      Result := Result + Str[i]
  end;
end;

procedure TfrxXMLExport.ExportPage(Stream: TStream);
var
  i, x, y, dx, dy, fx, fy, Page: Integer;
  s, sb, si, su: String;
  dcol, drow: Extended;
  Vert, Horiz: String;
  obj: TfrxIEMObject;
  EStyle: TfrxIEMStyle;
  St: String;
  PageBreak: TStringList;

  function IsDigits(const Str: String): Boolean;
  var
    i: Integer;
  begin
    Result := True;
    for i := 1 to Length(Str) do
      if not((AnsiChar(Str[i]) in ['0'..'9', ',' ,'.' ,'-', ' ', 'ð']) or (Ord(Str[i]) = 160)) then
      begin
        Result := False;
        break;
      end;
  end;

  procedure WriteExpLn(const str: String);
  begin
    if Length(str) > 0 then
      Stream.Write(str[1], Length(str));
    Stream.Write(#13#10, 2);
  end;

  procedure AlignFR2AlignExcel(HAlign: TfrxHAlign; VAlign: TfrxVAlign;
    var AlignH, AlignV: String);
  begin
    if HAlign = haLeft then
      AlignH := 'Left'
    else if HAlign = haRight then
      AlignH := 'Right'
    else if HAlign = haCenter then
      AlignH := 'Center'
    else if HAlign = haBlock then
      AlignH := 'Justify'
    else
      AlignH := '';
    if VAlign = vaTop then
      AlignV := 'Top'
    else if VAlign = vaBottom then
      AlignV := 'Bottom'
    else if VAlign = vaCenter then
      AlignV := 'Center'
    else
      AlignV := '';
  end;

  function ConvertFormat(const fstr: string): string;
  var
    err, p : integer;
    s: string;
  begin
    result := '';
    s := '';
    if length(fstr)>0 then
    begin
      p := pos('.', fstr);
      if p > 0 then
      begin
        s := Copy(fstr, p+1, length(fstr)-p-1);
        val(s, p ,err);
        SetLength(s, p);
        if p>0 then
        begin
          FillChar(s[1], p, '0');
          s:='.' + s;
        end;
      end;
      case fstr[length(fstr)] of
        'n': result := '#,##0' + s;
        'f': result := '0' + s;
        'g': result := '0.##';
        'm': result := '#,##0.00';
//        'm': result := '#,##0.00&quotð.;&quot;';
      else
        result := '#,##0.00';
      end;
    end;
  end;

begin
  PageBreak := TStringList.Create;

  try
    if FShowProgress then
    begin
      FProgress := TfrxProgress.Create(nil);
      FProgress.Execute(FMatrix.PagesCount, 'Exporting pages', True, True);
    end;

    WriteExpLn('<?xml version="1.0"?>');
    WriteExpLn('<?mso-application progid="Excel.Sheet"?>');
    WriteExpLn('<?fr-application created="' + UTF8Encode(FCreator) + '"?>');
    WriteExpLn('<?fr-application homesite="http://www.fast-report.com"?>');
    WriteExpLn('<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"');
    WriteExpLn(' xmlns:o="urn:schemas-microsoft-com:office:office"');
    WriteExpLn(' xmlns:x="urn:schemas-microsoft-com:office:excel"');
    WriteExpLn(' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"');
    WriteExpLn(' xmlns:html="http://www.w3.org/TR/REC-html40">');
    WriteExpLn('<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">');
    WriteExpLn('<Title>' + UTF8Encode(Report.ReportOptions.Name) + '</Title>');
    WriteExpLn('<Author>' + UTF8Encode(Report.ReportOptions.Author) + '</Author>');
    WriteExpLn('<Created>' + DateToStr(Date) + 'T' + TimeToStr(Time) + 'Z</Created>');
    WriteExpLn('<Version>' + UTF8Encode(Report.ReportOptions.VersionMajor) + '.' +
      UTF8Encode(Report.ReportOptions.VersionMinor) + '.' +
      UTF8Encode(Report.ReportOptions.VersionRelease) + '.' +
      UTF8Encode(Report.ReportOptions.VersionBuild) + '</Version>');
    WriteExpLn('</DocumentProperties>');
    WriteExpLn('<ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">');
    WriteExpLn('<ProtectStructure>False</ProtectStructure>');
    WriteExpLn('<ProtectWindows>False</ProtectWindows>');
    WriteExpLn('</ExcelWorkbook>');
    if FExportStyles then
    begin
      WriteExpLn('<Styles>');
      for x := 0 to FMatrix.StylesCount - 1 do
      begin
        EStyle := FMatrix.GetStyleById(x);
        s := 's' + IntToStr(x);
        WriteExpLn('<Style ss:ID="'+s+'">');
        if fsBold in EStyle.Font.Style then
          sb := ' ss:Bold="1"'
        else
          sb := '';
        if fsItalic in EStyle.Font.Style then
          si := ' ss:Italic="1"'
        else
          si := '';
        if fsUnderline in EStyle.Font.Style then
          su := ' ss:Underline="Single"'
        else
          su := '';
        WriteExpLn('<Font '+
          'ss:FontName="' + EStyle.Font.Name + '" '+
          'ss:Size="' + IntToStr(EStyle.Font.Size) + '" ' +
          'ss:Color="' + HTMLRGBColor(EStyle.Font.Color) + '"' + sb + si + su + '/>');
        WriteExpLn('<Interior ss:Color="' + HTMLRGBColor(EStyle.Color) +
          '" ss:Pattern="Solid"/>');
        AlignFR2AlignExcel(EStyle.HAlign, EStyle.VAlign, Horiz, Vert);
        if (EStyle.Rotation > 0) and (EStyle.Rotation <= 90) then
          s := 'ss:Rotate="' + IntToStr(EStyle.Rotation) + '"'
        else  if (EStyle.Rotation < 360) and (EStyle.Rotation >= 270) then
          s := 'ss:Rotate="' + IntToStr(EStyle.Rotation - 360) + '"'
        else
          s := '';
        si := '" ss:WrapText="1" ';
        WriteExpLn('<Alignment ss:Horizontal="' + Horiz + '" ss:Vertical="' + Vert + si + s +'/>');
        WriteExpLn('<Borders>');
        if EStyle.FrameWidth > 1 then
          i := 3
        else
          i := 1;
        s := 'ss:Weight="' + IntToStr(i) + '" ';
        si := 'ss:Color="' + HTMLRGBColor(EStyle.FrameColor) + '" ';
        if (ftLeft in EStyle.FrameTyp) then
          WriteExpLn('<Border ss:Position="Left" ss:LineStyle="Continuous" ' + s + si + '/>');
        if (ftRight in EStyle.FrameTyp) then
          WriteExpLn('<Border ss:Position="Right" ss:LineStyle="Continuous" ' + s + si + '/>');
        if (ftTop in EStyle.FrameTyp) then
          WriteExpLn('<Border ss:Position="Top" ss:LineStyle="Continuous" ' + s + si + '/>');
        if (ftBottom in EStyle.FrameTyp) then
          WriteExpLn('<Border ss:Position="Bottom" ss:LineStyle="Continuous" ' + s + si + '/>');
        WriteExpLn('</Borders>');
        if (EStyle.DisplayFormat.Kind = fkNumeric) and
          (EStyle.DisplayFormat.FormatStr <> '') and
          (EStyle.DisplayFormat.FormatStr <> '%2.2n') and
          (EStyle.DisplayFormat.FormatStr <> '') then
          WriteExpLn('<NumberFormat ss:Format="' + UTF8Encode(ConVertFormat(EStyle.DisplayFormat.FormatStr)) + '"/>');
        WriteExpLn('</Style>');
      end;
      WriteExpLn('</Styles>');
    end;

    s := 'Page 1';
    WriteExpLn('<Worksheet ss:Name="' + UTF8Encode(s) + '">');
    WriteExpLn('<Table ss:ExpandedColumnCount="' + IntToStr(FMatrix.Width) + '"' +
      ' ss:ExpandedRowCount="' + IntToStr(FMatrix.Height) + '" x:FullColumns="1" x:FullRows="1">');
    for x := 1 to FMatrix.Width - 1 do
    begin
      dcol := (FMatrix.GetXPosById(x) - FMatrix.GetXPosById(x - 1)) / Xdivider;
      WriteExpLn('<Column ss:AutoFitWidth="0" ss:Width="' +
        frFloat2Str(dcol, 2) + '"/>');
    end;
    st := '';
    Page := 0;

    for y := 0 to FMatrix.Height - 2 do
    begin
      drow := (FMatrix.GetYPosById(y + 1) - FMatrix.GetYPosById(y)) / Ydivider;
      WriteExpLn('<Row ss:Height="' + frFloat2Str(drow, 2) + '">');
      if FMatrix.PagesCount > Page then
        if FMatrix.GetYPosById(y) >= FMatrix.GetPageBreak(Page) then
        begin
          Inc(Page);
          PageBreak.Add(IntToStr(y + 1));
          if FShowProgress then
          begin
            FProgress.Tick;
            if FProgress.Terminated then
              break;
          end;
        end;
      for x := 0 to FMatrix.Width - 1 do
      begin
        if FShowProgress then
          if FProgress.Terminated then
             break;
        si := ' ss:Index="' + IntToStr(x + 1) + '" ';
        i := FMatrix.GetCell(x, y);
        if (i <> -1) then
        begin
          Obj := FMatrix.GetObjectById(i);
          if Obj.Counter = 0 then
          begin
            FMatrix.GetObjectPos(i, fx, fy, dx, dy);
            Obj.Counter := 1;
            if Obj.IsText then
            begin
              if dx > 1 then
              begin
                s := 'ss:MergeAcross="' + IntToStr(dx - 1) + '" ';
                Inc(dx);
              end
              else
                s := '';
              if dy > 1 then
                sb := 'ss:MergeDown="' + IntToStr(dy - 1) + '" '
              else
                sb := '';
              if FExportStyles then
                st := 'ss:StyleID="' + 's' + IntToStr(Obj.StyleIndex) + '" '
              else
                st := '';
              WriteExpLn('<Cell' + si + s + sb + st + '>');

              s := TruncReturns(Obj.Memo.Text);
              if (Obj.Style.DisplayFormat.Kind = fkNumeric) and IsDigits(s) then
              begin
                s := StringReplace(s, ThousandSeparator, '', [rfReplaceAll]);
                s := StringReplace(s, CurrencyString, '', [rfReplaceAll]);
                if Obj.Style.DisplayFormat.DecimalSeparator <> '' then
                  s := StringReplace(s, Obj.Style.DisplayFormat.DecimalSeparator, '.', [rfReplaceAll])
                else
                  s := StringReplace(s, DecimalSeparator, '.', [rfReplaceAll]);
                s := Trim(s);
                si := ' ss:Type="Number"';
                WriteExpLn('<Data' + si + '>' + UTF8Encode(s) + '</Data>');
              end
              else
              begin
                si := ' ss:Type="String"';
                s := ChangeReturns(s);
                WriteExpLn('<Data' + si + '>' + UTF8Encode(s) + '</Data>');
              end;
              WriteExpLn('</Cell>');
            end;
          end
        end
        else
          WriteExpLn('<Cell' + si + '/>');
      end;
      WriteExpLn('</Row>');
    end;

    WriteExpLn('</Table>');
    WriteExpLn('<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">');
    WriteExpLn('<PageSetup>');
    if FPageOrientation = poLandscape then
      WriteExpLn('<Layout x:Orientation="Landscape"/>');
    WriteExpLn('<PageMargins x:Bottom="' + frFloat2Str(FPageBottom / MargDiv, 2) +
      '" x:Left="' + frFloat2Str(FPageLeft / MargDiv, 2) +
      '" x:Right="' + frFloat2Str(FPageRight / MargDiv, 2) +
      '" x:Top="' + frFloat2Str(FPageTop / MargDiv, 2) + '"/>');
    WriteExpLn('</PageSetup>');
    WriteExpLn('</WorksheetOptions>');

    if FExportPageBreaks then
    begin
      WriteExpLn('<PageBreaks xmlns="urn:schemas-microsoft-com:office:excel">');
      WriteExpLn('<RowBreaks>');
      for i := 0 to FMatrix.PagesCount - 2 do
      begin
        WriteExpLn('<RowBreak>');
        WriteExpLn('<Row>' + PageBreak[i] + '</Row>');
        WriteExpLn('</RowBreak>');
      end;
      WriteExpLn('</RowBreaks>');
      WriteExpLn('</PageBreaks>');
    end;
    WriteExpLn('</Worksheet>');
    WriteExpLn('</Workbook>');
  finally
    PageBreak.Free;
  end;
  if FShowProgress then
    FProgress.Free;
end;

function TfrxXMLExport.ShowModal: TModalResult;
begin
  if not Assigned(Stream) then
  begin
    with TfrxXMLExportDialog.Create(nil) do
    begin
      OpenExcelCB.Visible := not SlaveExport;
      if SlaveExport then
        FOpenExcelAfterExport := False;

      if (FileName = '') and (not SlaveExport) then
        SaveDialog1.FileName := ChangeFileExt(ExtractFileName(Report.FileName), SaveDialog1.DefaultExt)
      else
        SaveDialog1.FileName := FileName;

      ContinuousCB.Checked := (not EmptyLines) or SuppressPageHeadersFooters;
      PageBreaksCB.Checked := FExportPageBreaks and (not ContinuousCB.Checked);
      WCB.Checked := FWysiwyg;
      OpenExcelCB.Checked := FOpenExcelAfterExport;
      BackgrCB.Checked := FBackground;

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

        FExportPageBreaks := PageBreaksCB.Checked and (not ContinuousCB.Checked);
        EmptyLines := not ContinuousCB.Checked;
        SuppressPageHeadersFooters := ContinuousCB.Checked;
        FWysiwyg := WCB.Checked;
        FOpenExcelAfterExport := OpenExcelCB.Checked;
        FBackground := BackgrCB.Checked;

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
  end else
    Result := mrOk;
end;

function TfrxXMLExport.Start: Boolean;
begin
  if (FileName <> '') or Assigned(Stream) then
  begin
    if (ExtractFilePath(FileName) = '') and (DefaultPath <> '') then
      FileName := DefaultPath + '\' + FileName;
    FFirstPage := True;
    FMatrix := TfrxIEMatrix.Create(UseFileCache, Report.EngineOptions.TempDir);
    FMatrix.ShowProgress := ShowProgress;
    FMatrix.MaxCellHeight := XLMaxHeight * Ydivider;
    FMatrix.Background := FBackground and FEmptyLines;
    FMatrix.BackgroundImage := False;
    FMatrix.Printable := ExportNotPrintable;
    FMatrix.RichText := True;
    FMatrix.PlainRich := True;
    FMatrix.EmptyLines := FEmptyLines;
    FExportPageBreaks := FExportPageBreaks and FEmptyLines;
    if FWysiwyg then
      FMatrix.Inaccuracy := 0.5
    else
      FMatrix.Inaccuracy := 10;
    FMatrix.DeleteHTMLTags := True;
    Result := True
  end
  else
    Result := False;
end;

procedure TfrxXMLExport.StartPage(Page: TfrxReportPage; Index: Integer);
begin
  if FFirstPage then
  begin
    FFirstPage := False;
    FPageLeft := Page.LeftMargin;
    FPageTop := Page.TopMargin;
    FPageBottom := Page.BottomMargin;
    FPageRight := Page.RightMargin;
    FPageOrientation := Page.Orientation;
  end;
end;

procedure TfrxXMLExport.ExportObject(Obj: TfrxComponent);
begin
  if Obj is TfrxView then
    FMatrix.AddObject(TfrxView(Obj));
end;

procedure TfrxXMLExport.FinishPage(Page: TfrxReportPage; Index: Integer);
begin
  FMatrix.AddPage(Page.Orientation, Page.Width, Page.Height, Page.LeftMargin,
                  Page.TopMargin, Page.RightMargin, Page.BottomMargin);
end;

procedure TfrxXMLExport.Finish;
var
  Exp: TStream;
  Excel: Variant;

begin
  FMatrix.Prepare;

  try
    if Assigned(Stream) then
      Exp := Stream
    else
      Exp := TFileStream.Create(FileName, fmCreate);
    try
      ExportPage(Exp);
    finally
      if not Assigned(Stream) then
        Exp.Free;
    end;
    try
      if FOpenExcelAfterExport and (not Assigned(Stream)) then
      begin
        Excel := CreateOLEObject('Excel.Application');
        Excel.Visible := True;
        Excel.WorkBooks.Open(FileName);
      end;
    finally
      Excel := Unassigned;
    end;
  except
    on e: Exception do
      case Report.EngineOptions.NewSilentMode of
        simSilent:        Report.Errors.Add(e.Message);
        simMessageBoxes:  frxErrorMsg(e.Message);
        simReThrow:       raise;
      end;
  end;
  FMatrix.Free;
end;

{ TfrxXMLExportDialog }

procedure TfrxXMLExportDialog.FormCreate(Sender: TObject);
begin
  Caption := frxGet(8100);
  OkB.Caption := frxGet(1);
  CancelB.Caption := frxGet(2);
  GroupPageRange.Caption := frxGet(7);
  AllRB.Caption := frxGet(3);
  CurPageRB.Caption := frxGet(4);
  PageNumbersRB.Caption := frxGet(5);
  DescrL.Caption := frxGet(9);
  GroupQuality.Caption := frxGet(8);
  ContinuousCB.Caption := frxGet(8950);
  PageBreaksCB.Caption := frxGet(6);
  WCB.Caption := frxGet(8102);
  BackgrCB.Caption := frxGet(8103);
  OpenExcelCB.Caption := frxGet(8104);
  SaveDialog1.Filter := frxGet(8105);
  SaveDialog1.DefaultExt := frxGet(8106);
end;


procedure TfrxXMLExportDialog.PageNumbersEChange(Sender: TObject);
begin
  PageNumbersRB.Checked := True;
end;

procedure TfrxXMLExportDialog.PageNumbersEKeyPress(Sender: TObject;
  var Key: Char);
begin
  case key of
    '0'..'9':;
    #8, '-', ',':;
  else
    key := #0;
  end;
end;

procedure TfrxXMLExportDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

end.
