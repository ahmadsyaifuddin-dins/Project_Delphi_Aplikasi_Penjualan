
{******************************************}
{                                          }
{             FastReport v4.0              }
{                CSV export                }
{                                          }
{         Copyright (c) 1998-2006          }
{          by Alexander Fediachov,         }
{             Fast Reports Inc.            }
{                                          }
{******************************************}

unit frxExportCSV;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, extctrls, frxClass, frxExportMatrix, ShellAPI
{$IFDEF Delphi6}, Variants {$ENDIF};

type
  TfrxCSVExportDialog = class(TForm)
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
    OpenCB: TCheckBox;
    OEMCB: TCheckBox;
    SeparatorLB: TLabel;
    SeparatorE: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure PageNumbersEChange(Sender: TObject);
    procedure PageNumbersEKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  end;

  TfrxCSVExport = class(TfrxCustomExportFilter)
  private
    FMatrix: TfrxIEMatrix;
    FOpenAfterExport: Boolean;
    Exp: TStream;
    FPage: TfrxReportPage;
    FOEM: Boolean;
    FSeparator: String;
    procedure ExportPage(Stream: TStream);
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
    property Separator: String read FSeparator write FSeparator;
    property OEMCodepage: Boolean read FOEM write FOEM;
    property OpenAfterExport: Boolean read FOpenAfterExport write FOpenAfterExport default False;
  end;


implementation

uses frxUtils, frxFileUtils, frxUnicodeUtils, frxRes, frxrcExports;

{$R *.dfm}

{ TfrxCSVExport }

constructor TfrxCSVExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOEM := False;
  FSeparator := ';';
  FilterDesc := frxGet(8851);
  DefaultExt := frxGet(8852);
end;

class function TfrxCSVExport.GetDescription: String;
begin
  Result := frxResources.Get('CSVExport');
end;

procedure TfrxCSVExport.ExportPage(Stream: TStream);
var
  x, y, i: Integer;
  Obj: TfrxIEMObject;
  s: String;

  function StrToOem(const AnsiStr: String): String;
  begin
    SetLength(Result, Length(AnsiStr));
    if Length(Result) > 0 then
      CharToOemBuff(PChar(AnsiStr), PChar(Result), Length(Result));
  end;

  function PrepareString(const Str: String): String;
  begin
    if FOEM then
      Result := StrToOem(Str)
    else
      Result := Str;
    Result := '"' + StringReplace(Result, #13#10, '', [rfReplaceAll]) + '"';
  end;

begin
  FMatrix.Prepare;

  for y := 0 to FMatrix.Height - 2 do
  begin
    for x := 0 to FMatrix.Width - 1 do
    begin
      i := FMatrix.GetCell(x, y);
      if (i <> -1) then
      begin
        Obj := FMatrix.GetObjectById(i);
        if Obj.Counter = 0 then
        begin
          s := PrepareString(Obj.Memo.Text) + FSeparator;
          Stream.Write(s[1], Length(s));
          Obj.Counter := 1;
        end
        else begin
          s := FSeparator;
          Stream.Write(s[1], Length(s));
        end;
      end;
    end;
    Stream.Write(#13#10, 2);
  end;

end;

function TfrxCSVExport.ShowModal: TModalResult;
begin
  if not Assigned(Stream) then
  begin
    with TfrxCSVExportDialog.Create(nil) do
    begin
      OpenCB.Visible := not SlaveExport;
      if SlaveExport then
        FOpenAfterExport := False;

      if (FileName = '') and (not SlaveExport) then
        SaveDialog1.FileName := ChangeFileExt(ExtractFileName(Report.FileName), SaveDialog1.DefaultExt)
      else
        SaveDialog1.FileName := FileName;

      OpenCB.Checked := FOpenAfterExport;
      OEMCB.Checked := FOEM;
      SeparatorE.Text := FSeparator;

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
        FOEM := OEMCB.Checked;
        FSeparator := SeparatorE.Text;

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

function TfrxCSVExport.Start: Boolean;
begin
  if (FileName <> '') or Assigned(Stream) then
  begin
    if (ExtractFilePath(FileName) = '') and (DefaultPath <> '') then
      FileName := DefaultPath + '\' + FileName;
    FMatrix := TfrxIEMatrix.Create(UseFileCache, Report.EngineOptions.TempDir);
    FMatrix.Background := False;
    FMatrix.BackgroundImage := False;
    FMatrix.Printable := ExportNotPrintable;
    FMatrix.RichText := True;
    FMatrix.PlainRich := True;
    FMatrix.AreaFill := False;
    FMatrix.CropAreaFill := True;
    FMatrix.Inaccuracy := 5;
    FMatrix.DeleteHTMLTags := True;
    FMatrix.Images := False;
    FMatrix.WrapText := True;
    FMatrix.ShowProgress := False;
    FMatrix.FramesOptimization := True;
    try
      if Assigned(Stream) then
        Exp := Stream
      else
        Exp := TFileStream.Create(FileName, fmCreate);
       Result := True;
    except
      Result := False;
    end;
  end
  else
    Result := False;
end;

procedure TfrxCSVExport.StartPage(Page: TfrxReportPage; Index: Integer);
begin
  FMatrix.Clear;
end;

procedure TfrxCSVExport.ExportObject(Obj: TfrxComponent);
begin
  if Obj is TfrxView then
    FMatrix.AddObject(TfrxView(Obj));
end;

procedure TfrxCSVExport.FinishPage(Page: TfrxReportPage; Index: Integer);
begin
  FPage := Page;
  ExportPage(Exp);
end;

procedure TfrxCSVExport.Finish;
begin
  FMatrix.Free;
  if not Assigned(Stream) then
    Exp.Free;
  if FOpenAfterExport and (not Assigned(Stream)) then
    ShellExecute(GetDesktopWindow, 'open', PChar(FileName), nil, nil, SW_SHOW);
end;

{ TfrxCSVExportDialog }

procedure TfrxCSVExportDialog.FormCreate(Sender: TObject);
begin
  Caption := frxGet(8850);
  OkB.Caption := frxGet(1);
  CancelB.Caption := frxGet(2);
  GroupPageRange.Caption := frxGet(7);
  AllRB.Caption := frxGet(3);
  CurPageRB.Caption := frxGet(4);
  PageNumbersRB.Caption := frxGet(5);
  DescrL.Caption := frxGet(9);
  GroupQuality.Caption := frxGet(8302);
  OEMCB.Caption := frxGet(8304);
  OpenCB.Caption := frxGet(8706);
  SaveDialog1.Filter := frxGet(8851);
  SaveDialog1.DefaultExt := frxGet(8852);
  SeparatorLB.Caption := frxGet(8853)
end;

procedure TfrxCSVExportDialog.PageNumbersEChange(Sender: TObject);
begin
  PageNumbersRB.Checked := True;
end;

procedure TfrxCSVExportDialog.PageNumbersEKeyPress(Sender: TObject;
  var Key: Char);
begin
  case key of
    '0'..'9':;
    #8, '-', ',':;
  else
    key := #0;
  end;
end;

procedure TfrxCSVExportDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

end.
