
{******************************************}
{                                          }
{             FastReport v4.0              }
{        Open Document Format export       }
{                                          }
{         Copyright (c) 1998-2006          }
{          by Alexander Fediachov,         }
{             Fast Reports Inc.            }
{                                          }
{******************************************}

unit frxExportODF;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, extctrls, Printers, frxClass, frxExportMatrix, frxProgress,
  frxXML, ShellAPI,  frxZip {$IFDEF Delphi6}, Variants {$ENDIF};

type
  TfrxODFExportDialog = class(TForm)
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
    OpenCB: TCheckBox;
    BackgrCB: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure PageNumbersEChange(Sender: TObject);
    procedure PageNumbersEKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  end;

  TfrxODFExport = class(TfrxCustomExportFilter)
  private
    FExportPageBreaks: Boolean;
    FExportStyles: Boolean;
    FFirstPage: Boolean;
    FMatrix: TfrxIEMatrix;
    FOpenAfterExport: Boolean;
    FPageBottom: Extended;
    FPageLeft: Extended;
    FPageRight: Extended;
    FPageTop: Extended;
    FPageWidth: Extended;
    FPageHeight: Extended;
    FPageOrientation: TPrinterOrientation;
    FShowProgress: Boolean;
    FWysiwyg: Boolean;
    FBackground: Boolean;
    FCreator: String;
    FEmptyLines: Boolean;
    FTempFolder: String;
    FZipFile: TfrxZipArchive;
    FThumbImage: TImage;
    FProgress: TfrxProgress;
    FExportType: String;
    procedure DoOnProgress(Sender: TObject);
    function OdfPrepareString(const Str: String): String;
    function OdfGetFrameName(const FrameStyle:  TfrxFrameStyle): String;
    procedure OdfMakeHeader(const Item: TfrxXMLItem);
    procedure OdfCreateMeta(const FileName: String; const Creator: String);
    procedure OdfCreateManifest(const FileName: String; const PicCount: Integer; const MValue: String);
    procedure OdfCreateMime(const FileName: String; const MValue: String);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class function GetDescription: String; override;
    function ShowModal: TModalResult; override;
    function Start: Boolean; override;
    procedure Finish; override;
    procedure FinishPage(Page: TfrxReportPage; Index: Integer); override;
    procedure StartPage(Page: TfrxReportPage; Index: Integer); override;
    procedure ExportObject(Obj: TfrxComponent); override;
    property ExportType: String read FExportType write FExportType;
    property ExportTitle;
  protected
    procedure ExportPage(Stream: TStream);
  published
    property ExportStyles: Boolean read FExportStyles write FExportStyles default True;
    property ExportPageBreaks: Boolean read FExportPageBreaks write FExportPageBreaks default True;
    property OpenAfterExport: Boolean read FOpenAfterExport
      write FOpenAfterExport default False;
    property ShowProgress: Boolean read FShowProgress write FShowProgress;
    property Wysiwyg: Boolean read FWysiwyg write FWysiwyg default True;
    property Background: Boolean read FBackground write FBackground default False;
    property Creator: String read FCreator write FCreator;
    property EmptyLines: Boolean read FEmptyLines write FEmptyLines;
    property SuppressPageHeadersFooters;
  end;

  TfrxODSExport = class(TfrxODFExport)
  public
    constructor Create(AOwner: TComponent); override;
    class function GetDescription: String; override;
    property ExportTitle;
  published
    property ExportStyles;
    property ExportPageBreaks;
    property OpenAfterExport;
    property ShowProgress;
    property Wysiwyg;
    property Background;
    property Creator;
    property EmptyLines;
    property SuppressPageHeadersFooters;
  end;

  TfrxODTExport = class(TfrxODFExport)
  public
    constructor Create(AOwner: TComponent); override;
    class function GetDescription: String; override;
  published
    property ExportStyles;
    property ExportPageBreaks;
    property OpenAfterExport;
    property ShowProgress;
    property Wysiwyg;
    property Background;
    property Creator;
    property EmptyLines;
    property SuppressPageHeadersFooters;
  end;

implementation

uses frxUtils, frxFileUtils, frxUnicodeUtils, frxRes, frxrcExports;

{$R *.dfm}

const
  odfDivider = 37.82;
  odfPageDiv = 37.8;
  odfMargDiv = 10;
  odfHeaderSize = 20;
  odfRep = 'urn:oasis:names:tc:opendocument:xmlns:';

var
  odfXMLHeader: array[0..odfHeaderSize - 1] of array [0..1] of String = (
  ('xmlns:office', odfRep + 'office:1.0'),
  ('xmlns:style', odfRep + 'style:1.0'),
  ('xmlns:text', odfRep + 'text:1.0'),
  ('xmlns:table', odfRep + 'table:1.0'),
  ('xmlns:draw', odfRep + 'drawing:1.0'),
  ('xmlns:fo', odfRep + 'xsl-fo-compatible:1.0'),
  ('xmlns:xlink', 'http://www.w3.org/1999/xlink'),
  ('xmlns:dc', 'http://purl.org/dc/elements/1.1/'),
  ('xmlns:meta', odfRep + 'meta:1.0'),
  ('xmlns:number', odfRep + 'datastyle:1.0'),
  ('xmlns:svg', odfRep + 'svg-compatible:1.0'),
  ('xmlns:chart', odfRep + 'chart:1.0'),
  ('xmlns:dr3d', odfRep + 'dr3d:1.0'),
  ('xmlns:math', 'http://www.w3.org/1998/Math/MathML'),
  ('xmlns:form', odfRep + 'form:1.0'),
  ('xmlns:script', odfRep + 'script:1.0'),
  ('xmlns:dom', 'http://www.w3.org/2001/xml-events'),
  ('xmlns:xforms', 'http://www.w3.org/2002/xforms'),
  ('xmlns:xsd', 'http://www.w3.org/2001/XMLSchema'),
  ('xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance'));

{ TfrxODFExport }

constructor TfrxODFExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FExportPageBreaks := True;
  FExportStyles := True;
  FShowProgress := True;
  FWysiwyg := True;
  FBackground := True;
  FCreator := 'FastReport';
  FEmptyLines := True;
  FThumbImage := TImage.Create(nil);
end;

class function TfrxODFExport.GetDescription: String;
begin
  Result := '';
end;

procedure TfrxODFExport.OdfCreateMeta(const FileName: String; const Creator: String);
var
  XML: TfrxXMLDocument;
begin
  XML := TfrxXMLDocument.Create;
  try
    XML.AutoIndent := True;
    XML.Root.Name := 'office:document-meta';
    XML.Root.Prop['xmlns:office'] := 'urn:oasis:names:tc:opendocument:xmlns:office:1.0';
    XML.Root.Prop['xmlns:xlink'] := 'http://www.w3.org/1999/xlink';
    XML.Root.Prop['xmlns:dc'] := 'http://purl.org/dc/elements/1.1/';
    XML.Root.Prop['xmlns:meta'] := 'urn:oasis:names:tc:opendocument:xmlns:meta:1.0';
    with XML.Root.Add do
    begin
      Name := 'office:meta';
      with Add do
      begin
        Name := 'meta:generator';
        Value := 'fast-report.com/Fast Report/build:' + FR_VERSION;
      end;
      with Add do
      begin
        Name := 'meta:initial-creator';
        Value := Creator;
      end;
      with Add do
      begin
        Name := 'meta:creation-date';
        Value := FormatDateTime('YYYY-MM-DD', Now) + 'T' + FormatDateTime('HH:MM:SS', Now);
      end;
    end;
    XML.SaveToFile(FileName);
  finally
    XML.Free;
  end;
end;

procedure TfrxODFExport.OdfCreateMime(const FileName: String; const MValue: String);
var
  f: TFileStream;
  s: String;
begin
  f := TFileStream.Create(FileName, fmCreate);
  try
    s := 'application/vnd.oasis.opendocument.' + MValue;
    f.Write(s[1], Length(s));
  finally
    f.Free;
  end;
end;

procedure TfrxODFExport.OdfCreateManifest(const FileName: String; const PicCount: Integer; const MValue: String);
var
  XML: TfrxXMLDocument;
  i: Integer;
begin
  XML := TfrxXMLDocument.Create;
  try
    XML.AutoIndent := True;
    XML.Root.Name := 'manifest:manifest';
    XML.Root.Prop['xmlns:manifest'] := 'urn:oasis:names:tc:opendocument:xmlns:manifest:1.0';
    with XML.Root.Add do
    begin
      Name := 'manifest:file-entry';
      Prop['manifest:media-type'] := 'application/vnd.oasis.opendocument.' + MValue;
      Prop['manifest:full-path'] := '/';
    end;
    with XML.Root.Add do
    begin
      Name := 'manifest:file-entry';
      Prop['manifest:media-type'] := 'text/xml';
      Prop['manifest:full-path'] := 'content.xml';
    end;
    with XML.Root.Add do
    begin
      Name := 'manifest:file-entry';
      Prop['manifest:media-type'] := 'text/xml';
      Prop['manifest:full-path'] := 'styles.xml';
    end;
    with XML.Root.Add do
    begin
      Name := 'manifest:file-entry';
      Prop['manifest:media-type'] := 'text/xml';
      Prop['manifest:full-path'] := 'meta.xml';
    end;
    for i := 1 to PicCount do
      with XML.Root.Add do
      begin
        Name := 'manifest:file-entry';
        Prop['manifest:media-type'] := 'image/bmp';
        Prop['manifest:full-path'] := 'Pictures/Pic' + IntToStr(i) + '.bmp';
      end;
    XML.SaveToFile(FileName);
  finally
    XML.Free;
  end;
end;

function TfrxODFExport.OdfPrepareString(const Str: String): String;
var
  i: Integer;
  s: String;
begin
  Result := '';
  s := Str;
  if Copy(s, Length(s) - 1, 4) = #13#10 then
    Delete(s, Length(s) - 1, 4);
  for i := 1 to Length(s) do
  begin
    if s[i] = '&' then
      Result := Result + '&amp;'
    else
    if s[i] = '"' then
      Result := Result + '&quot;'
    else if s[i] = '<' then
      Result := Result + '&lt;'
    else if s[i] = '>' then
      Result := Result + '&gt;'
    else if (s[i] <> #10) then
      Result := Result + s[i]
  end;
end;

function TfrxODFExport.OdfGetFrameName(const FrameStyle:  TfrxFrameStyle): String;
begin
  if FrameStyle = fsDouble then
    Result := 'double'
  else
    Result := 'solid';
end;

procedure TfrxODFExport.OdfMakeHeader(const Item: TfrxXMLItem);
var
  i: Integer;
begin
  for i := 0 to odfHeaderSize - 1 do
    Item.Prop[odfXMLHeader[i][0]] := odfXMLHeader[i][1];
end;

procedure TfrxODFExport.ExportPage(Stream: TStream);
var
  XML: TfrxXMLDocument;
  f: TFileStream;
  s, s1: String;
  FList: TStringList;
  i, j, x, y, Page, PicCount: Integer;
  dx, dy, fx, fy: Integer;
  Style: TfrxIEMStyle;
  d: Extended;
  Obj: TfrxIEMObject;
begin
  if ShowProgress then
    FProgress.Execute(FMatrix.Height - 1, frxResources.Get('ProgressWait'), True, True);
  FTempFolder := GetTempFile;
  DeleteFile(FTempFolder);
  FTempFolder := FTempFolder + '\';
  MkDir(FTempFolder);
  MkDir(FTempFolder + 'Pictures');
  MkDir(FTempFolder + 'Thumbnails');
  PicCount := 0;
  FThumbImage.Picture.SaveToFile(FTempFolder + 'Thumbnails\thumbnail.bmp');
  XML := TfrxXMLDocument.Create;
  try
    XML.AutoIndent := True;
    XML.Root.Name := 'office:document-styles';
    OdfMakeHeader(XML.Root);
    with XML.Root.Add do
    begin
      Name := 'office:automatic-styles';
      with Add do
      begin
        Name := 'style:page-layout';
        Prop['style:name'] := 'pm1';
        with Add do
        begin
          Name := 'style:page-layout-properties';
          Prop['fo:page-width'] := frFloat2Str( FPageWidth / odfPageDiv, 1) + 'cm';
          Prop['fo:page-height'] := frFloat2Str( FPageHeight / odfPageDiv, 1) + 'cm';
          Prop['fo:margin-top'] := frFloat2Str(FPageTop / odfMargDiv, 3) + 'cm';
          Prop['fo:margin-bottom'] := frFloat2Str(FPageBottom / odfMargDiv, 3) + 'cm';
          Prop['fo:margin-left'] := frFloat2Str(FPageLeft / odfMargDiv, 3) + 'cm';
          Prop['fo:margin-right'] := frFloat2Str(FPageRight / odfMargDiv, 3) + 'cm';
        end;
      end;
    end;
    with XML.Root.Add do
    begin
      Name := 'office:master-styles';
      with Add do
      begin
        Name := 'style:master-page';
        Prop['style:name'] := 'PageDef';
        Prop['style:page-layout-name'] := 'pm1';
        with Add do
        begin
          Name := 'style:header';
          Prop['style:display'] := 'false';
        end;
        with Add do
        begin
          Name := 'style:footer';
          Prop['style:display'] := 'false';
        end;
      end;
    end;
    XML.SaveToFile(FTempFolder + 'styles.xml');
  finally
    XML.Free;
  end;

  XML := TfrxXMLDocument.Create;
  try
    XML.AutoIndent := True;
    XML.Root.Name := 'office:document-content';
    OdfMakeHeader(XML.Root);
    with XML.Root.Add do
      Name := 'office:scripts';
    // font styles
    FList := TStringList.Create;
    try
      FList.Sorted := True;
      for i := 0 to FMatrix.StylesCount - 1 do
      begin
        Style := FMatrix.GetStyleById(i);
        if (Style.Font <> nil) and (FList.IndexOf(Style.Font.Name) = -1) then
          FList.Add(Style.Font.Name);
      end;
      with XML.Root.Add do
      begin
        Name := 'office:font-face-decls';
        for i := 0 to FList.Count - 1 do
        begin
          with Add do
          begin
            Name := 'style:font-face';
            Prop['style:name'] := FList[i];
            Prop['svg:font-family'] := '&apos;' + FList[i] + '&apos;';
            Prop['style:font-pitch'] := 'variable';
          end;
        end;
      end;
    finally
      FList.Free;
    end;
    with XML.Root.Add do
    begin
      Name := 'office:automatic-styles';
      // columns styles
      FList := TStringList.Create;
      try
        FList.Sorted := True;
        for i := 1 to FMatrix.Width - 1 do
        begin
          d := (FMatrix.GetXPosById(i) - FMatrix.GetXPosById(i - 1)) / odfDivider;
          s := frFloat2Str(d, 3);
          if FList.IndexOf(s) = -1 then
            FList.Add(s);
        end;
        for i := 0 to FList.Count - 1 do
        begin
          with Add do
          begin
            Name := 'style:style';
            Prop['style:name'] := 'co' + FList[i];
            Prop['style:family'] := 'table-column';
            with Add do
            begin
              Name := 'style:table-column-properties';
              Prop['fo:break-before'] := 'auto';
              Prop['style:column-width'] := FList[i] + 'cm';
            end;
          end;
        end;
      finally
        FList.Free;
      end;
      // rows styles
      FList := TStringList.Create;
      try
        FList.Sorted := True;
        for i := 0 to FMatrix.Height - 2 do
        begin
          d := (FMatrix.GetYPosById(i + 1) - FMatrix.GetYPosById(i)) / odfDivider;
          s := frFloat2Str(d, 3);
          if FList.IndexOf(s) = -1 then
            FList.Add(s);
        end;
        for i := 0 to FList.Count - 1 do
        begin
          with Add do
          begin
            Name := 'style:style';
            Prop['style:name'] := 'ro' + FList[i];
            Prop['style:family'] := 'table-row';
            with Add do
            begin
              Name := 'style:table-row-properties';
              Prop['fo:break-before'] := 'auto';
              Prop['style:row-height'] := FList[i] + 'cm';
            end;
          end;
        end;
        with Add do
        begin
          Name := 'style:style';
          Prop['style:name'] := 'ro_breaked';
          Prop['style:family'] := 'table-row';
          with Add do
          begin
            Name := 'style:table-row-properties';
            Prop['fo:break-before'] := 'page';
            Prop['style:row-height'] := '0.001cm';
          end;
        end;
      finally
        FList.Free;
      end;
      // table style
      with Add do
      begin
        Name := 'style:style';
        Prop['style:name'] := 'ta1';
        Prop['style:family'] := 'table';
        Prop['style:master-page-name'] := 'PageDef';
        with Add do
        begin
          Name := 'style:table-properties';
          Prop['table:display'] := 'true';
          Prop['style:writing-mode'] := 'lr-tb';  /// RTL - LTR?
        end;
      end;
      // cells styles
      with Add do
      begin
        Name := 'style:style';
        Prop['style:name'] := 'ceb';
        Prop['style:family'] := 'table-cell';
        Prop['style:display'] := 'false';
      end;
      for i := 0 to FMatrix.StylesCount - 1 do
      begin
        Style := FMatrix.GetStyleById(i);
        with Add do
        begin
          Name := 'style:style';
          Prop['style:name'] := 'ce' + IntToStr(i);
          Prop['style:family'] := 'table-cell';
          Prop['style:parent-style-name'] := 'Default';
          if FExportType <> 'text' then
          begin
            with Add do
            begin
              Name := 'style:text-properties';
              Prop['style:font-name'] := Style.Font.Name;
              Prop['fo:font-size'] := IntToStr(Style.Font.Size) + 'pt';
              if fsUnderline in Style.Font.Style then
              begin
                Prop['style:text-underline-style'] := 'solid';
                Prop['style:text-underline-width'] := 'auto';
                Prop['style:text-underline-color'] := 'font-color';
              end;
              if fsItalic in Style.Font.Style then
                Prop['fo:font-style'] := 'italic';
              if fsBold in Style.Font.Style then
                Prop['fo:font-weight'] := 'bold';
              Prop['fo:color'] := HTMLRGBColor(Style.Font.Color);
            end;
            with Add do
            begin
              Name := 'style:paragraph-properties';
              if Style.HAlign = haLeft then
                Prop['fo:text-align'] := 'start';
              if Style.HAlign = haCenter then
                Prop['fo:text-align'] := 'center';
              if Style.HAlign = haRight then
                Prop['fo:text-align'] := 'end';
              if Style.GapX <> 0 then
              begin
                Prop['fo:margin-left'] := frFloat2Str(Style.GapX / odfDivider, 3) + 'cm';
                Prop['fo:margin-right'] := Prop['fo:margin-left'];
              end;
            end;
          end;
          with Add do
          begin
            Name := 'style:table-cell-properties';
            Prop['fo:background-color'] := HTMLRGBColor(Style.Color);
            Prop['style:repeat-content'] := 'false';
            if Style.Rotation > 0 then
            begin
              Prop['style:rotation-angle'] := IntToStr(Style.Rotation);
              Prop['style:rotation-align'] := 'none';
            end;
            if Style.VAlign = vaCenter then
              Prop['style:vertical-align'] := 'middle';
            if Style.VAlign = vaTop then
              Prop['style:vertical-align'] := 'top';
            if Style.VAlign = vaBottom then
              Prop['style:vertical-align'] := 'bottom';
            if (ftLeft in Style.FrameTyp) then
              Prop['fo:border-left'] := frFloat2Str(Style.FrameWidth / odfDivider, 3) + 'cm ' + OdfGetFrameName(Style.FrameStyle) + ' ' + HTMLRGBColor(Style.FrameColor);
            if (ftRight in Style.FrameTyp) then
              Prop['fo:border-right'] := frFloat2Str(Style.FrameWidth / odfDivider, 3) + 'cm ' + OdfGetFrameName(Style.FrameStyle) + ' ' + HTMLRGBColor(Style.FrameColor);
            if (ftTop in Style.FrameTyp) then
              Prop['fo:border-top'] := frFloat2Str(Style.FrameWidth / odfDivider, 3) + 'cm ' + OdfGetFrameName(Style.FrameStyle) + ' ' + HTMLRGBColor(Style.FrameColor);
            if (ftBottom in Style.FrameTyp) then
              Prop['fo:border-bottom'] := frFloat2Str(Style.FrameWidth / odfDivider, 3) + 'cm ' + OdfGetFrameName(Style.FrameStyle) + ' ' + HTMLRGBColor(Style.FrameColor);
          end;
        end;
      end;
      if FExportType = 'text' then
      begin
        // text styles
        with Add do
        begin
          Name := 'style:style';
          Prop['style:name'] := 'pb';
          Prop['style:family'] := 'paragraph';
          Prop['style:display'] := 'false';
        end;
        for i := 0 to FMatrix.StylesCount - 1 do
        begin
          Style := FMatrix.GetStyleById(i);
          with Add do
          begin
            Name := 'style:style';
            Prop['style:name'] := 'p' + IntToStr(i);
            Prop['style:family'] := 'paragraph';
            Prop['style:parent-style-name'] := 'Default';
            with Add do
            begin
              Name := 'style:text-properties';
              Prop['style:font-name'] := Style.Font.Name;
              Prop['fo:font-size'] := IntToStr(Style.Font.Size) + 'pt';
              if fsUnderline in Style.Font.Style then
              begin
                Prop['style:text-underline-style'] := 'solid';
                Prop['style:text-underline-width'] := 'auto';
                Prop['style:text-underline-color'] := 'font-color';
              end;
              if fsItalic in Style.Font.Style then
                Prop['fo:font-style'] := 'italic';
              if fsBold in Style.Font.Style then
                Prop['fo:font-weight'] := 'bold';
              Prop['fo:color'] := HTMLRGBColor(Style.Font.Color);
            end;
            with Add do
            begin
              Name := 'style:paragraph-properties';
              if Style.HAlign = haLeft then
                Prop['fo:text-align'] := 'start';
              if Style.HAlign = haCenter then
                Prop['fo:text-align'] := 'center';
              if Style.HAlign = haRight then
                Prop['fo:text-align'] := 'end';
              if Style.GapX <> 0 then
              begin
                Prop['fo:margin-left'] := frFloat2Str(Style.GapX / odfDivider, 3) + 'cm';
                Prop['fo:margin-right'] := Prop['fo:margin-left'];
              end;
            end;
          end;
        end;
      end;
      // pic style
      with Add do
      begin
        Name := 'style:style';
        Prop['style:name'] := 'gr1';
        Prop['style:family'] := 'graphic';
        with Add do
        begin
          Name := 'style:graphic-properties';
          Prop['draw:stroke'] := 'none';
          Prop['draw:fill'] := 'none';
          Prop['draw:textarea-horizontal-align'] := 'center';
          Prop['draw:textarea-vertical-align'] := 'middle';
          Prop['draw:color-mode'] := 'standard';
          Prop['draw:luminance'] := '0%';
          Prop['draw:contrast'] := '0%';
          Prop['draw:gamma'] := '100%';
          Prop['draw:red'] := '0%';
          Prop['draw:green'] := '0%';
          Prop['draw:blue'] := '0%';
          Prop['fo:clip'] := 'rect(0cm 0cm 0cm 0cm)';
          Prop['draw:image-opacity'] := '100%';
          Prop['style:mirror'] := 'none';
        end;
      end;
    end;
    // BODY
    with XML.Root.Add do
    begin
      Name := 'office:body';
      with Add do
      begin
        Name := 'office:spreadsheet';
        with Add do
        begin
          Name := 'table:table';
          Prop['table:name'] := 'Table';
          Prop['table:style-name'] := 'ta1';
          Prop['table:print'] := 'false';
          for x := 1 to FMatrix.Width - 1 do
            with Add do
            begin
              Name := 'table:table-column';
              d := (FMatrix.GetXPosById(x) - FMatrix.GetXPosById(x - 1)) / odfDivider;
              s := frFloat2Str(d, 3);
              Prop['table:style-name'] := 'co' + s;
            end;
          Page := 0;
          for y := 0 to FMatrix.Height - 2 do
          begin
            if ShowProgress then
            begin
              FProgress.Tick;
              if FProgress.Terminated then
                break;
            end;
            if FMatrix.PagesCount > Page then
              if FMatrix.GetYPosById(y) >= FMatrix.GetPageBreak(Page) then
              begin
                Inc(Page);
                if FExportPageBreaks then
                  with Add do
                  begin
                    Name := 'table:table-row';
                    Prop['table:style-name'] := 'ro_breaked';
                  end;
                continue;
              end;
            with Add do
            begin
              Name := 'table:table-row';
              d := (FMatrix.GetYPosById(y + 1) - FMatrix.GetYPosById(y)) / odfDivider;
              s := frFloat2Str(d, 3);
              Prop['table:style-name'] := 'ro' + s;
              for x := 0 to FMatrix.Width - 1 do
              begin
                i := FMatrix.GetCell(x, y);
                with Add do
                begin
                  if i <> -1 then
                  begin
                    Obj := FMatrix.GetObjectById(i);
                    if Obj.Counter = 0 then
                    begin
                      Name := 'table:table-cell';
                      Obj.Counter := 1;
                      FMatrix.GetObjectPos(i, fx, fy, dx, dy);
                      Prop['table:style-name'] := 'ce' + IntToStr(Obj.StyleIndex);
                      if dx > 1 then
                        Prop['table:number-columns-spanned'] := IntToStr(dx);
                      if dy > 1 then
                        Prop['table:number-rows-spanned'] := IntToStr(dy);
                      // text
                      if Obj.IsText then
                      begin
                        s := UTF8Encode(OdfPrepareString(Obj.Memo.Text));
                        Prop['office:value'] := s;
                        with Add do
                        begin
                          Name := 'text:p';
                          if FExportType = 'text' then
                            Prop['text:style-name'] := 'p' + IntToStr(Obj.StyleIndex);
                          Value := s;
                        end;
                      end
                      else
                      // picture
                      begin
                        Inc(PicCount);
                        with Add do
                        begin
                          s := 'pic' + IntToStr(PicCount) + '.bmp';
                          Obj.Image.SaveToFile(FTempFolder + 'Pictures\' + s);
                          Name := 'draw:frame';
                          Prop['draw:z-index'] := '0';
                          Prop['draw:name'] := 'Picture' + IntToStr(PicCount);
                          Prop['draw:style-name'] := 'gr1';
                          Prop['draw:text-style-name'] := 'P1';
                          Prop['svg:width'] := frFloat2Str(Obj.Width / odfDivider, 3) + 'cm';
                          Prop['svg:height'] := frFloat2Str(Obj.Height / odfDivider, 3) + 'cm';
                          Prop['svg:x'] := '0cm';
                          Prop['svg:y'] := '0cm';
                          with Add do
                          begin
                            Name := 'draw:image';
                            Prop['xlink:href'] := 'Pictures/' + s;
                            Prop['xlink:type'] := 'simple';
                            Prop['xlink:show'] := 'embed';
                            Prop['xlink:actuate'] := 'onLoad';
                          end;
                        end;
                      end;
                    end
                    else
                    begin
                      Name := 'table:covered-table-cell';
                      Prop['table:style-name'] := 'ceb';
                      if FExportType = 'text' then
                      begin
                        with Add do
                        begin
                          Name := 'text:p';
                          if FExportType = 'text' then
                            Prop['text:style-name'] := 'pb';
                        end;
                      end;
                    end;
                  end
                  else
                  begin
                    Name := 'table:table-cell';
                    if FExportType = 'text' then
                    begin
                      with Add do
                      begin
                        Name := 'text:p';
                        if FExportType = 'text' then
                          Prop['text:style-name'] := 'pb';
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
    XML.SaveToFile(FTempFolder + 'content.xml');
  finally
    XML.Free;
  end;
  MkDir(FTempFolder + 'META-INF');
  s := FExportType;
  OdfCreateManifest(FTempFolder + 'META-INF\manifest.xml', PicCount, s);
  OdfCreateMime(FTempFolder + 'mimetype', s);
  OdfCreateMeta(FTempFolder + 'meta.xml', Creator);
  FZipFile := TfrxZipArchive.Create;
  try
    FZipFile.RootFolder := FTempFolder;
    FZipFile.AddDir(FTempFolder);
    if ShowProgress then
    begin
      FProgress.Execute(FZipFile.FileCount, frxResources.Get('ProgressWait'), True, True);
      FZipFile.OnProgress := DoOnProgress;
    end;
    FZipFile.SaveToStream(Stream);
  finally
    FZipFile.Free;
  end;
  DeleteFolder(FTempFolder);
end;

function TfrxODFExport.ShowModal: TModalResult;
begin
  if not Assigned(Stream) then
  begin
    with TfrxODFExportDialog.Create(nil) do
    begin
      SaveDialog1.DefaultExt := DefaultExt;
      SaveDialog1.Filter := FilterDesc;
      Caption := ExportTitle; 
      OpenCB.Visible := not SlaveExport;
      if SlaveExport then
        FOpenAfterExport := False;

      if (FileName = '') and (not SlaveExport) then
        SaveDialog1.FileName := ChangeFileExt(ExtractFileName(Report.FileName), SaveDialog1.DefaultExt)
      else
        SaveDialog1.FileName := FileName;

      ContinuousCB.Checked := (not EmptyLines) or SuppressPageHeadersFooters;
      PageBreaksCB.Checked := FExportPageBreaks and (not ContinuousCB.Checked);
      WCB.Checked := FWysiwyg;
      OpenCB.Checked := FOpenAfterExport;
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
        FOpenAfterExport := OpenCB.Checked;
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

function TfrxODFExport.Start: Boolean;
begin
  FThumbImage.Width := 0;
  FThumbImage.Height := 0;
  if (FileName <> '') or Assigned(Stream) then
  begin
    if (ExtractFilePath(FileName) = '') and (DefaultPath <> '') then
      FileName := DefaultPath + '\' + FileName;
    FFirstPage := True;
    FMatrix := TfrxIEMatrix.Create(UseFileCache, Report.EngineOptions.TempDir);
    FMatrix.RotatedAsImage := False;
    FMatrix.ShowProgress := ShowProgress;
    FMatrix.Background := FBackground and FEmptyLines;
    FMatrix.BackgroundImage := False;
    FMatrix.Printable := ExportNotPrintable;
    FMatrix.RichText := True;
    FMatrix.PlainRich := True;
    FMatrix.EmptyLines := FEmptyLines;
    FMatrix.WrapText := True;
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

procedure TfrxODFExport.StartPage(Page: TfrxReportPage; Index: Integer);
begin
  if FFirstPage then
  begin
    FPageLeft := Page.LeftMargin;
    FPageTop := Page.TopMargin;
    FPageBottom := Page.BottomMargin;
    FPageRight := Page.RightMargin;
    FPageOrientation := Page.Orientation;
    FPageWidth := Page.Width;
    FPageHeight := Page.Height;
    FThumbImage.Width := Round(Page.Width / 5);
    FThumbImage.Height := Round(Page.Height / 5);
  end;
end;

procedure TfrxODFExport.ExportObject(Obj: TfrxComponent);
begin
  if Obj is TfrxView then
  begin
    FMatrix.AddObject(TfrxView(Obj));
    if FFirstPage then
      TfrxView(Obj).Draw(FThumbImage.Canvas, 0.2, 0.2, Obj.Left / 5, Obj.Top / 5);
  end;
end;

procedure TfrxODFExport.FinishPage(Page: TfrxReportPage; Index: Integer);
begin
  FFirstPage := False;
  FMatrix.AddPage(Page.Orientation, Page.Width, Page.Height, Page.LeftMargin,
                  Page.TopMargin, Page.RightMargin, Page.BottomMargin);
end;

procedure TfrxODFExport.Finish;
var
  Exp: TStream;
begin
  FMatrix.Prepare;
  if ShowProgress then
    FProgress := TfrxProgress.Create(nil);
  try
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
      if FOpenAfterExport and (not Assigned(Stream)) then
        ShellExecute(GetDesktopWindow, 'open', PChar(FileName), nil, nil, SW_SHOW);
    except
      on e: Exception do
        case Report.EngineOptions.NewSilentMode of
          simSilent:        Report.Errors.Add(e.Message);
          simMessageBoxes:  frxErrorMsg(e.Message);
          simReThrow:       raise;
        end;
    end;
  finally
    FMatrix.Free;
    if ShowProgress then
      FProgress.Free;
  end;
end;

destructor TfrxODFExport.Destroy;
begin
  FThumbImage.Free;
  inherited;
end;

procedure TfrxODFExport.DoOnProgress(Sender: TObject);
begin
  if ShowProgress then
    FProgress.Tick;
end;

{ TfrxODSExport }

constructor TfrxODSExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ExportType := 'spreadsheet';
  FilterDesc := frxResources.Get('ODSExportFilter');
  DefaultExt := frxGet(8960);
  ExportTitle := frxResources.Get('ODSExport');
end;

class function TfrxODSExport.GetDescription: String;
begin
  Result := frxResources.Get('ODSExport');
end;

{ TfrxODTExport }

constructor TfrxODTExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ExportType := 'text';
  FilterDesc := frxResources.Get('ODTExportFilter');
  DefaultExt := frxGet(8961);
  ExportTitle := frxResources.Get('ODTExport');
end;

class function TfrxODTExport.GetDescription: String;
begin
  Result := frxResources.Get('ODTExport');
end;

{ TfrxODFExportDialog }

procedure TfrxODFExportDialog.FormCreate(Sender: TObject);
begin
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
  OpenCB.Caption := frxGet(8706);
end;


procedure TfrxODFExportDialog.PageNumbersEChange(Sender: TObject);
begin
  PageNumbersRB.Checked := True;
end;

procedure TfrxODFExportDialog.PageNumbersEKeyPress(Sender: TObject;
  var Key: Char);
begin
  case key of
    '0'..'9':;
    #8, '-', ',':;
  else
    key := #0;
  end;
end;

procedure TfrxODFExportDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

end.
