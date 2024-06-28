
{******************************************}
{                                          }
{             FastReport v4.0              }
{            PDF export filter             }
{                                          }
{         Copyright (c) 1998-2006          }
{          by Alexander Fediachov,         }
{             Fast Reports Inc.            }
{                                          }
{******************************************}

unit frxExportPDF;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComObj, Printers, frxClass, JPEG, ShellAPI,
  ComCtrls, frxPDFFile
{$IFDEF Delphi6}, Variants {$ENDIF};

type
  TfrxPDFExportDialog = class(TForm)
    OkB: TButton;
    CancelB: TButton;
    GroupPageRange: TGroupBox;
    DescrL: TLabel;
    AllRB: TRadioButton;
    CurPageRB: TRadioButton;
    PageNumbersRB: TRadioButton;
    PageNumbersE: TEdit;
    GroupQuality: TGroupBox;
    CompressedCB: TCheckBox;
    OpenCB: TCheckBox;
    SaveDialog1: TSaveDialog;
    EmbeddedCB: TCheckBox;
    PrintOptCB: TCheckBox;
    OutlineCB: TCheckBox;
    BackgrCB: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure PageNumbersEChange(Sender: TObject);
    procedure PageNumbersEKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  end;

  TfrxPDFExport = class(TfrxCustomExportFilter)
  private
    FCompressed: Boolean;
    FEmbedded: Boolean;
    FOpenAfterExport: Boolean;
    FPDF: TfrxPDFFile;
    FPDFpage: TfrxPDFPage;
    FPrintOpt: Boolean;
    FOutline: Boolean;
    FSubject: WideString;
    FAuthor: WideString;
    FBackground: Boolean;
    FCreator: WideString;
    FTags: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    class function GetDescription: String; override;
    function ShowModal: TModalResult; override;
    function Start: Boolean; override;
    procedure ExportObject(Obj: TfrxComponent); override;
    procedure Finish; override;
    procedure StartPage(Page: TfrxReportPage; Index: Integer); override;
  published
    property Compressed: Boolean read FCompressed write FCompressed default True;
    property EmbeddedFonts: Boolean read FEmbedded write FEmbedded default False;
    property OpenAfterExport: Boolean read FOpenAfterExport
      write FOpenAfterExport default False;
    property PrintOptimized: Boolean read FPrintOpt write FPrintOpt;
    property Outline: Boolean read FOutline write FOutline;
    property Author: WideString read FAuthor write FAuthor;
    property Subject: WideString read FSubject write FSubject;
    property Background: Boolean read FBackground write FBackground;
    property Creator: WideString read FCreator write FCreator;
    property HTMLTags: Boolean read FTags write FTags;
  end;

implementation

uses frxUtils, frxFileUtils, frxRes, frxrcExports;

{$R *.dfm}

{ TfrxPDFExport }

constructor TfrxPDFExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCompressed := True;
  FPrintOpt := False;
  FAuthor := 'FastReport';
  FSubject := 'FastReport PDF export';
  FBackground := False;
  FCreator := 'FastReport (http://www.fast-report.com)';
  FTags := True;
  FilterDesc := frxGet(8707);
  DefaultExt := frxGet(8708);
end;

class function TfrxPDFExport.GetDescription: String;
begin
  Result := frxResources.Get('PDFexport');
end;

function TfrxPDFExport.ShowModal: TModalResult;
begin
  if not Assigned(Stream) then
  begin
    if Assigned(Report) then
      FOutline := Report.PreviewOptions.OutlineVisible
    else
      FOutline := True;
    with TfrxPDFExportDialog.Create(nil) do
    begin
      OpenCB.Visible := not SlaveExport;
      if SlaveExport then
        FOpenAfterExport := False;

      if (FileName = '') and (not SlaveExport) then
        SaveDialog1.FileName := ChangeFileExt(ExtractFileName(Report.FileName), SaveDialog1.DefaultExt)
      else
        SaveDialog1.FileName := FileName;

      OpenCB.Checked := FOpenAfterExport;
      CompressedCB.Checked := FCompressed;
      EmbeddedCB.Checked := FEmbedded;
      PrintOptCB.Checked := FPrintOpt;
      OutlineCB.Checked := FOutline;
      OutlineCB.Enabled := FOutline;
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

        FOpenAfterExport := OpenCB.Checked;
        FCompressed := CompressedCB.Checked;
        FEmbedded := EmbeddedCB.Checked;
        FPrintOpt := PrintOptCB.Checked;
        FOutline := OutlineCB.Checked;
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

function TfrxPDFExport.Start: Boolean;
var
  f: Boolean;
begin
  if (FileName <> '') or Assigned(Stream) then
  begin
    if (ExtractFilePath(FileName) = '') and (DefaultPath <> '') then
      FileName := DefaultPath + '\' + FileName;
    f := Report.PreviewPages.Count > 200;
    FPDF := TfrxPDFFile.Create(UseFileCache and f, Report.EngineOptions.TempDir);
    FPDF.Compressed := FCompressed;
    FPDF.EmbeddedFonts := FEmbedded;
    FPDF.PrintOptimized := FPrintOpt;
    FPDF.Outline := FOutline;
    FPDF.Background := FBackground;
    FPDF.Author := FAuthor;
    FPDF.Subject := FSubject;
    FPDF.Creator := FCreator;
    FPDF.HTMLTags := FTags;
    if FOutline then
      FPDF.PreviewOutline := Report.PreviewPages.Outline;
    Result := True
  end else
    Result := False;
end;

procedure TfrxPDFExport.StartPage(Page: TfrxReportPage; Index: Integer);
begin
  FPDFPage := FPDF.AddPage(Page);
end;

procedure TfrxPDFExport.ExportObject(Obj: TfrxComponent);
begin
  if (Obj is TfrxView) and (ExportNotPrintable or TfrxView(Obj).Printable) then
    FPDFPage.AddObject(TfrxView(Obj));
end;

procedure TfrxPDFExport.Finish;
var
  Exp: TStream;

begin

  try
    try
      if Assigned(Stream) then
        Exp := Stream
      else
        Exp := TFileStream.Create(FileName, fmCreate);
      try
        FPDF.Title := Report.ReportOptions.Name;
        FPDF.SaveToStream(Exp);
      finally
        if not Assigned(Stream) then
          Exp.Free;
        if FOpenAfterExport and (not Assigned(Stream)) then
          ShellExecute(GetDesktopWindow, 'open', PChar(FileName), nil, nil, SW_SHOW);
      end;
    except
      on e: Exception do
        case Report.EngineOptions.NewSilentMode of
          simSilent:        Report.Errors.Add(e.Message);
          simMessageBoxes:  frxErrorMsg(e.Message);
          simReThrow:       raise;
        end;
    end;
  finally
    FPDF.Free;
  end;
end;

{ TfrxPDFExportDialog }

procedure TfrxPDFExportDialog.FormCreate(Sender: TObject);
begin
  Caption := frxGet(8700);
  OkB.Caption := frxGet(1);
  CancelB.Caption := frxGet(2);
  GroupPageRange.Caption := frxGet(7);
  AllRB.Caption := frxGet(3);
  CurPageRB.Caption := frxGet(4);
  PageNumbersRB.Caption := frxGet(5);
  DescrL.Caption := frxGet(9);
  GroupQuality.Caption := frxGet(8);
  CompressedCB.Caption := frxGet(8701);
  EmbeddedCB.Caption := frxGet(8702);
  PrintOptCB.Caption := frxGet(8703);
  OutlineCB.Caption := frxGet(8704);
  BackgrCB.Caption := frxGet(8705);
  OpenCB.Caption := frxGet(8706);
  SaveDialog1.Filter := frxGet(8707);
  SaveDialog1.DefaultExt := frxGet(8708);
end;

procedure TfrxPDFExportDialog.PageNumbersEChange(Sender: TObject);
begin
  PageNumbersRB.Checked := True;
end;

procedure TfrxPDFExportDialog.PageNumbersEKeyPress(Sender: TObject;
  var Key: Char);
begin
  case key of
    '0'..'9':;
    #8, '-', ',':;
  else
    key := #0;
  end;
end;

procedure TfrxPDFExportDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

end.
