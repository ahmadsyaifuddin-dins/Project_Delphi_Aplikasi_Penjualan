
{******************************************}
{                                          }
{             FastReport v4.0              }
{         HTML table export filter         }
{                                          }
{         Copyright (c) 1998-2006          }
{          by Alexander Fediachov,         }
{             Fast Reports Inc.            }
{                                          }
{******************************************}

unit frxExportHTML;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, frxClass, JPEG, ShellAPI, frxExportMatrix, frxProgress
{$IFDEF Delphi6}, Variants {$ENDIF}, frxExportImage;

type
  TfrxHTMLExportDialog = class(TForm)
    SaveDialog1: TSaveDialog;
    GroupQuality: TGroupBox;
    StylesCB: TCheckBox;
    PicsSameCB: TCheckBox;
    FixWidthCB: TCheckBox;
    NavigatorCB: TCheckBox;
    MultipageCB: TCheckBox;
    GroupPageRange: TGroupBox;
    DescrL: TLabel;
    AllRB: TRadioButton;
    CurPageRB: TRadioButton;
    PageNumbersRB: TRadioButton;
    PageNumbersE: TEdit;
    OpenAfterCB: TCheckBox;
    OkB: TButton;
    CancelB: TButton;
    BackgrCB: TCheckBox;
    PicturesL: TLabel;
    PFormatCB: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure PageNumbersEChange(Sender: TObject);
    procedure PageNumbersEKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  end;

  TfrxHTMLExport = class(TfrxCustomExportFilter)
  private
    Exp: TStream;
    FAbsLinks: Boolean;
    FCurrentPage: Integer;
    FExportPictures: Boolean;
    FExportStyles: Boolean;
    FFixedWidth: Boolean;
    FMatrix: TfrxIEMatrix;
    FMozillaBrowser: Boolean;
    FMultipage: Boolean;
    FNavigator: Boolean;
    FOpenAfterExport: Boolean;
    FPicsInSameFolder: Boolean;
    FPicturesCount: Integer;
    FProgress: TfrxProgress;
    FUseJpeg: Boolean;
    FServer: Boolean;
    FPrintLink: String;
    FRefreshLink: String;
    FBackground: Boolean;
    FBackImage: TBitmap;
    FBackImageExist: Boolean;
    FReportPath: String;
    FUseGif: Boolean;
    FCentered: Boolean;
    FEmptyLines: Boolean;
    procedure WriteExpLn(const str: String);
    procedure ExportPage;
    function ChangeReturns(const Str: String): String;
    function TruncReturns(const Str: WideString): WideString;
    function GetPicsFolder: String;
    function GetPicsFolderRel: String;
    function GetFrameFolder: String;
    function ReverseSlash(const S: String): String;
    function HTMLCodeStr(const Str: String): String;
    procedure SetUseGif(const Value: Boolean);
    procedure SetUseJpeg(const Value: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ShowModal: TModalResult; override;
    function Start: Boolean; override;
    procedure Finish; override;
    procedure FinishPage(Page: TfrxReportPage; Index: Integer); override;
    procedure StartPage(Page: TfrxReportPage; Index: Integer); override;
    procedure ExportObject(Obj: TfrxComponent); override;
    class function GetDescription: String; override;
    property Server: Boolean read FServer write FServer;
    property PrintLink: String read FPrintLink write FPrintLink;
    property RefreshLink: String read FRefreshLink write FRefreshLink;
    property ReportPath: String read FReportPath write FReportPath;
  published
    property OpenAfterExport: Boolean read FOpenAfterExport write FOpenAfterExport default False;
    property FixedWidth: Boolean read FFixedWidth write FFixedWidth default False;
    property ExportPictures: Boolean read FExportPictures write FExportPictures default True;
    property PicsInSameFolder: Boolean read FPicsInSameFolder write FPicsInSameFolder default False;
    property ExportStyles: Boolean read FExportStyles write FExportStyles default True;
    property Navigator: Boolean read FNavigator write FNavigator default False;
    property Multipage: Boolean read FMultipage write FMultipage default False;
    property MozillaFrames: Boolean read FMozillaBrowser write FMozillaBrowser default False;
    property UseJpeg: Boolean read FUseJpeg write SetUseJpeg default True;
    property UseGif: Boolean read FUseGif write SetUseGif default False;
    property AbsLinks: Boolean read FAbsLinks write FAbsLinks default False;
    property Background: Boolean read FBackground write FBackground;
    property Centered: Boolean read FCentered write FCentered;
    property EmptyLines: Boolean read FEmptyLines write FEmptyLines;
  end;


implementation

uses frxUtils, frxFileUtils, frxUnicodeUtils, frxRes, frxrcExports, Math;

{$R *.dfm}

const
  Xdivider = 1;
  Ydivider = 1.03;
  Navigator_src =
    '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'#13#10 +
    '<html><head>' +
    '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">' +
    '<meta name=Generator content="FastReport 4.0 http://www.fast-report.com">' +
    '<title></title><style type="text/css"><!--'#13#10 +
    'body { font-family: Tahoma; font-size: 8px; font-weight: bold; font-style: normal; text-align: center; vertical-align: middle; }'#13#10 +
    'input {text-align: center}'#13#10 +
    '.nav { font : 9pt Tahoma; color : #283e66; font-weight : bold; text-decoration : none;}'#13#10 +
    '--></style><script language="javascript" type="text/javascript"><!--'#13#10 +
    '  var frPgCnt = %s; var frRepName = "%s"; var frMultipage = %s; var frPrefix="%s";'#13#10 +
    '  function DoPage(PgN) {'#13#10 +
    '    if ((PgN > 0) && (PgN <= frPgCnt) && (PgN != parent.frCurPage)) {'#13#10 +
    '      if (frMultipage > 0)  parent.mainFrame.location = frPrefix + PgN + ".html";'#13#10 +
    '      else parent.mainFrame.location = frPrefix + "main.html#PageN" + PgN;'#13#10 +
    '      UpdateNav(PgN); } else document.PgForm.PgEdit.value = parent.frCurPage; }'#13#10 +
    '  function UpdateNav(PgN) {'#13#10 +
    '    parent.frCurPage = PgN; document.PgForm.PgEdit.value = PgN;'#13#10 +
    '    if (PgN == 1) { document.PgForm.bFirst.disabled = 1; document.PgForm.bPrev.disabled = 1; }'#13#10 +
    '    else { document.PgForm.bFirst.disabled = 0; document.PgForm.bPrev.disabled = 0; }'#13#10 +
    '    if (PgN == frPgCnt) { document.PgForm.bNext.disabled = 1; document.PgForm.bLast.disabled = 1; }'#13#10 +
    '    else { document.PgForm.bNext.disabled = 0; document.PgForm.bLast.disabled = 0; } }'#13#10 +
    '  function RefreshRep() { %s }'#13#10 +
    '  function PrintRep() { %s }'#13#10 +
    '--></script></head>'#13#10 +
    '<body bgcolor="#DDDDDD" text="#000000" leftmargin="0" topmargin="4" onload="UpdateNav(parent.frCurPage)">'#13#10 +
    '<form name="PgForm" onsubmit="DoPage(document.forms[0].PgEdit.value); return false;" action="">'#13#10 +
    '<table cellspacing="0" align="left" cellpadding="0" border="0" width="100%%">'#13#10 +
    '<tr valign="middle">'#13#10 +
    '<td width="60" align="center"><button name="bFirst" class="nav" type="button" onclick="DoPage(1); return false;">%s</button></td>'#13#10 +
    '<td width="60" align="center"><button name="bPrev" class="nav" type="button" onclick="DoPage(Math.max(parent.frCurPage - 1, 1)); return false;">%s</button></td>'#13#10 +
    '<td width="100" align="center"><input type="text" class="nav" name="PgEdit" value="parent.frCurPage" size="4"></td>'#13#10 +
    '<td width="60" align="center"><button name="bNext" class="nav" type="button" onclick="DoPage(parent.frCurPage + 1); return false;">%s</button></td>'#13#10 +
    '<td width="60" align="center"><button name="bLast" class="nav" type="button" onclick="DoPage(frPgCnt); return false;">%s</button></td>'#13#10 +
    '<td width="20">&nbsp;</td>'#13#10'%s' +
    '<td align="right">%s: <script language="javascript" type="text/javascript"> document.write(frPgCnt);</script></td>'#13#10 +
    '<td width="10">&nbsp;</td>'#13#10 +
    '</tr></table></form></body></html>';
  Server_sect =
    '<td width="60" align="center"><button name="bRefresh" class="nav" type="button" onclick="RefreshRep(); return false;">%s</button></td>'#13#10 +
    '<td width="60" align="center"><button name="bPrint" class="nav" type="button" onclick="PrintRep(); return false;">%s</button></td>'#13#10;
  DefPrint = 'parent.mainFrame.focus(); parent.mainFrame.print();';
  LinkPrint = 'parent.location = "%s";';
  DefRefresh = 'parent.location = "result?report=" + frRepName + "&multipage=" + frMultipage;';
  LinkRefresh = 'parent.location = "%s";';

{ TfrxHTMLExport }

constructor TfrxHTMLExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FExportPictures := True;
  FExportStyles := True;
  FFixedWidth := True;
  FUseJpeg := True;
  FUseGif := False;
  FServer := False;
  FPrintLink := '';
  FBackground := False;
  FCentered := False;
  FBackImage := TBitmap.Create;
  FilterDesc := frxGet(8210);
  DefaultExt := frxGet(8211);
  FEmptyLines := True;
end;

class function TfrxHTMLExport.GetDescription: String;
begin
  Result := frxResources.Get('HTMLexport');
end;

function TfrxHTMLExport.TruncReturns(const Str: WideString): WideString;
begin
  if Copy(Str, Length(Str) - 1, 2) = #13#10 then
    Result := Copy(Str, 1, Length(Str) - 2)
  else
    Result := Str;
end;

function TfrxHTMLExport.ChangeReturns(const Str: String): String;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(Str) do
  begin
    if Str[i] = '&' then
      Result := Result + '&amp;'
    else if (i < Length(Str)) and (Str[i] = #13) and (Str[i + 1] = #10) then
      Result := Result + '<br>'
    else if Str[i] = '"' then
      Result := Result + '&quot;'
    else if (Str[i] <> #10) then
      Result := Result + Str[i]
  end;
end;

procedure TfrxHTMLExport.WriteExpLn(const str: String);
begin
  if Length(str) > 0 then
  begin
    Exp.Write(str[1], Length(str));
    Exp.Write(#13#10, 2);
  end;
end;

procedure TfrxHTMLExport.ExportPage;
var
  i, x, y, dx, dy, fx, fy, pbk: Integer;
  dcol, drow: Integer;
  text, s, s1, sb, si, su: String;
  Vert, Horiz: String;
  obj: TfrxIEMObject;
  EStyle: TfrxIEMStyle;
  St, buff: String;
  hlink, newpage: Boolean;
  jpg : TJPEGImage;
  tableheader, columnWidths: String;

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
      AlignV := 'Middle'
    else
      AlignV := '';
  end;

begin
  WriteExpLn('<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">');
  WriteExpLn('<html><head>');
  WriteExpLn('<meta http-equiv="Content-Type" content="text/html; charset=utf-8">');
  WriteExpLn('<meta name=Generator content="FastReport 4.0 http://www.fast-report.com">');
  if Length(Report.ReportOptions.Name) > 0 then
    s := Report.ReportOptions.Name
  else
    s := ChangeFileExt(ExtractFileName(Report.FileName), '');
  WriteExpLn('<title>' + UTF8Encode(s) + '</title>');

  if FExportStyles then
  begin
    WriteExpLn('<style type="text/css"><!-- ');
    WriteExpLn('.page_break {page-break-before: always;}');
    for x := 0 to FMatrix.StylesCount - 1 do
    begin
      EStyle := FMatrix.GetStyleById(x);
      s := 's' + IntToStr(x);
      WriteExpLn('.' + s + ' {');
      if Assigned(EStyle.Font) then
      begin
        su := '';
        sb := '';
        si := '';
        if fsBold in EStyle.Font.Style then
          sb := ' font-weight: bold;'
        else
          sb := '';
        if fsItalic in EStyle.Font.Style then
          si := ' font-style: italic;'
        else
          si := ' font-style: normal;';

        if fsUnderline in EStyle.Font.Style then
          su := ' text-decoration: underline';
        if fsStrikeout in EStyle.Font.Style then
        begin
          if su = '' then
            su := ' text-decoration: line-through'
          else
            su := su + ' | line-through';
        end;
        if su <> '' then
          su := su + ';';
        WriteExpLn(' font-family: ' + EStyle.Font.Name + ';'#13#10 +
          ' font-size: ' + IntToStr(Round(EStyle.Font.Size * 96 / 72)) + 'px;'#13#10 +
          ' color: ' + HTMLRGBColor(EStyle.Font.Color) + ';' + sb + si + su);
      end;
      if EStyle.Color = clNone then
        WriteExpLn(' background-color: transparent;')
      else
        WriteExpLn(' background-color: ' + HTMLRGBColor(EStyle.Color) + ';');
      AlignFR2AlignExcel(EStyle.HAlign, EStyle.VAlign, Horiz, Vert);
      if EStyle.FrameTyp <> [] then
      begin
        su := IntToStr(Round(EStyle.FrameWidth));
        s := HTMLRGBColor(EStyle.FrameColor);
        si := ' border-color:' + s + ';';
        WriteExpLn(si + ' border-style: solid;');
        if (ftLeft in EStyle.FrameTyp) then
          WriteExpLn(' border-left-width: ' + su + ';')
        else
          WriteExpLn(' border-left-width: 0px;');
        if (ftRight in EStyle.FrameTyp) then
          WriteExpLn(' border-right-width: ' + su + ';')
        else
          WriteExpLn(' border-right-width: 0px;');
        if (ftTop in EStyle.FrameTyp) then
          WriteExpLn(' border-top-width: ' + su + ';')
        else
          WriteExpLn(' border-top-width: 0px;');
        if (ftBottom in EStyle.FrameTyp) then
          WriteExpLn(' border-bottom-width: ' + su + ';')
        else
          WriteExpLn(' border-bottom-width: 0px;');
      end;
      WriteExpLn(' text-align: ' + Horiz + '; vertical-align: ' + Vert +';');
      WriteExpLn('}');
    end;
    WriteExpLn('--></style>');
  end;
  WriteExpLn('</head>');
  WriteExpLn('<body');
  if FBackImageExist and FExportPictures then
  begin
    if FUseJpeg then
    begin
      s := GetPicsFolder + 'backgrnd.jpg';
      s1 := ExtractFilePath(s);
      if (s1 = ChangeFileExt(ExtractFileName(FileName), '.files\')) or (s1 = '') then
         s := ExtractFilePath(filename) + s;
      jpg := TJPEGImage.Create;
      jpg.Assign(FBackImage);
      jpg.SaveToFile(s);
      jpg.Free;
      s := ReverseSlash(GetPicsFolderRel + 'backgrnd.jpg');
    end else
    if FUseGif then
    begin
      s := GetPicsFolder + 'backgrnd.gif';
      s1 := ExtractFilePath(s);
      if (s1 = ChangeFileExt(ExtractFileName(FileName), '.files\')) or (s1 = '') then
         s := ExtractFilePath(filename) + s;
      GIFSaveToFile(s, FBackImage);
      s := ReverseSlash(GetPicsFolderRel + 'backgrnd.gif');
    end else
    begin
      s := GetPicsFolder + 'backgrnd.bmp';
      if (ExtractFilePath(s) = ChangeFileExt(ExtractFileName(FileName), '.files\')) or
         (ExtractFilePath(s) = '') then
         s := ExtractFilePath(filename) + s;
      FBackImage.SaveToFile(s);
      s := ReverseSlash(GetPicsFolderRel + 'backgrnd.bmp');
    end;
    WriteExpLn(' background="' + s + '"');
  end;
  WriteExpLn(' bgcolor="#FFFFFF" text="#000000">');

  WriteExpLn('<a name="PageN1"></a>');
  if FFixedWidth then
    st := ' width="' + IntToStr(Round((FMatrix.MaxWidth - FMatrix.Left) / Xdivider)) + '"'
  else
    st := '';
  if FCentered then
    st := st + ' align="center"';
  tableheader := '<table' + st +' border="0" cellspacing="0" cellpadding="0"';
  WriteExpLn(tableheader + '>');

  columnWidths := '<tr style="height: 1px">';
  for x := 0 to FMatrix.Width - 2 do
  begin
    dcol := Round((FMatrix.GetXPosById(x + 1) - FMatrix.GetXPosById(x)) / Xdivider);
    columnWidths := columnWidths + '<td width="' + IntToStr(dcol) + '"/>';
  end;
  if FMatrix.Width < 2 then
    columnWidths := columnWidths + '<td/>';
  columnWidths := columnWidths + '</tr>';
  WriteExpLn(columnWidths);

  pbk := 0;
  st := '';
  newpage := False;

  for y := 0 to FMatrix.Height - 2 do
  begin
    if ShowProgress and (not FMultipage) then
      if FProgress.Terminated then
        break;
    drow := Round((FMatrix.GetYPosById(y + 1) - FMatrix.GetYPosById(y)) / Ydivider);
    s := '';
    if FMatrix.PagesCount > pbk then
      if Round(FMatrix.GetPageBreak(pbk)) <= Round(FMatrix.GetYPosById(y + 1)) then
      begin
        Inc(pbk);
        if ShowProgress and (not FMultipage) then
          FProgress.Tick;
        newpage := True;
      end;
    if drow = 0 then
      drow := 1;
    WriteExpLn('<tr style="height:' + IntToStr(drow) + 'px">');
    buff := '';
    for x := 0 to FMatrix.Width - 2 do
    begin
      if ShowProgress and (not FMultipage) then
        if FProgress.Terminated then
          break;
      i := FMatrix.GetCell(x, y);
      if (i <> -1) then
      begin
        Obj := FMatrix.GetObjectById(i);
        if Obj.Counter = 0 then
        begin
          FMatrix.GetObjectPos(i, fx, fy, dx, dy);
          Obj.Counter := 1;
          if dx > 1 then
            s := ' colspan="' + IntToStr(dx) + '"'
          else
            s := '';
          if dy > 1 then
            sb := ' rowspan="' + IntToStr(dy) + '"'
          else
            sb := '';
          if FExportStyles then
            st := ' class="' + 's' + IntToStr(Obj.StyleIndex) + '"'
          else
            st := '';
          if Length(Trim(Obj.Memo.Text)) = 0 then
            st := st + ' style="font-size:1px"';

          buff := buff + '<td' + s + sb + st + '>';
          if Length(Obj.URL) > 0 then
          begin
            if Obj.URL[1] = '@' then
              if  FMultipage then
              begin
                Obj.URL := StringReplace(Obj.URL, '@', '', []);
                Obj.URL := ReverseSlash(GetPicsFolderRel + Trim(Obj.URL) + '.html')
              end
              else
                Obj.URL := StringReplace(Obj.URL, '@', '#PageN', []);
            buff := buff + '<a href="' + Obj.URL + '">';
            hlink := True;
          end
          else
            hlink := False;
          if Obj.IsText then
          begin
            text := Trim(ChangeReturns(UTF8Encode(TruncReturns(Obj.Memo.Text))));
            if Length(text) > 0 then
              buff := buff + text
            else
              buff := buff + '&nbsp;';
          end else
          begin
            if FUseJpeg then
            begin
              s := GetPicsFolder + 'img' + IntToStr(FPicturesCount) + '.jpg';
              s1 := ExtractFilePath(s);
              if (s1 = ChangeFileExt(ExtractFileName(FileName), '.files\')) or (s1 = '') then
                s := ExtractFilePath(filename) + s;
              jpg := TJPEGImage.Create;
              jpg.Assign(Obj.Image);
              jpg.SaveToFile(s);
              jpg.Free;
              s := ReverseSlash(GetPicsFolderRel + 'img' + IntToStr(FPicturesCount) + '.jpg');
            end else
            if FUseGif then
            begin
              s := GetPicsFolder + 'img' + IntToStr(FPicturesCount) + '.gif';
              s1 := ExtractFilePath(s);
              if (s1 = ChangeFileExt(ExtractFileName(FileName), '.files\')) or (s1 = '') then
                s := ExtractFilePath(filename) + s;
              GIFSaveToFile(s, Obj.Image);
              s := ReverseSlash(GetPicsFolderRel + 'img' + IntToStr(FPicturesCount) + '.gif');
            end else
            begin
              s := GetPicsFolder + 'img' + IntToStr(FPicturesCount) + '.bmp';
              s1 := ExtractFilePath(s);
              if (s1 = ChangeFileExt(ExtractFileName(FileName), '.files\')) or
                 (s1 = '') then
                s := ExtractFilePath(filename) + s;
              Obj.Image.SaveToFile(s);
              s := ReverseSlash(GetPicsFolderRel + 'img' + IntToStr(FPicturesCount) + '.bmp');
            end;
            buff := buff + '<img src="' + s + '" width="' + IntToStr(Obj.Image.Width) +
                           '" height="' + IntToStr(Obj.Image.Height) + '" alt="">';
            Inc(FPicturesCount);
          end;
          if hlink then
            buff := buff + '</a>';
          buff := buff + '</td>';
        end;
      end
      else
        buff := buff + '<td/>';
    end;
    WriteExpLn(buff);
    WriteExpLn('</tr>');
    if newpage then
    begin
      WriteExpLn('</table>');
      newpage := False;
      if y < FMatrix.Height - 2 then
      begin
        WriteExpLn('<a name="PageN' + IntToStr(pbk + 1) + '"></a>');
        WriteExpLn(tableheader + ' class="page_break">');
        WriteExpLn(columnWidths);
      end;
    end;
  end;
  if FMultipage or (FMatrix.Height < 2) then
    WriteExpLn('</table>');
  WriteExpLn('</body></html>');
end;

function TfrxHTMLExport.ShowModal: TModalResult;
begin
  if not Assigned(Stream) then
  begin
    with TfrxHTMLExportDialog.Create(nil) do
    begin
      SendMessage(GetWindow(PFormatCB.Handle,GW_CHILD), EM_SETREADONLY, 1, 0);
      OpenAfterCB.Visible := not SlaveExport;
      PFormatCB.Enabled := not SlaveExport;
      MultipageCB.Enabled := not SlaveExport;
      BackgrCB.Enabled := not SlaveExport;
      NavigatorCB.Enabled := not SlaveExport;
      PicsSameCB.Enabled := not SlaveExport;
      if SlaveExport then
      begin
        FOpenAfterExport := False;
        FExportPictures := False;
        FPicsInSameFolder := True;
        FNavigator := False;
        FMultipage := False;
        FBackground := False;
      end;

      if (FileName = '') and (not SlaveExport) then
        SaveDialog1.FileName := ChangeFileExt(ExtractFileName(Report.FileName), SaveDialog1.DefaultExt)
      else
        SaveDialog1.FileName := FileName;

      StylesCB.Checked := FExportStyles;
      PicsSameCB.Checked := FPicsInSameFolder;
      if not FExportPictures then
        PFormatCB.ItemIndex := 0
      else
      begin
        if FUseJpeg then
          PFormatCB.ItemIndex := 1
        else if FUseGif then
          PFormatCB.ItemIndex := 3
        else
          PFormatCB.ItemIndex := 2
      end;
      OpenAfterCB.Checked := FOpenAfterExport;
      FixWidthCB.Checked := FFixedWidth;
      NavigatorCB.Checked := FNavigator;
      MultipageCB.Checked := FMultipage;
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

        FExportStyles := StylesCB.Checked;
        FPicsInSameFolder := PicsSameCB.Checked;
        FExportPictures := not (PFormatCB.ItemIndex = 0);
        FUseJpeg := PFormatCB.ItemIndex = 1;
        FUseGif := PFormatCB.ItemIndex = 3;
        FOpenAfterExport := OpenAfterCB.Checked;
        FFixedWidth := FixWidthCB.Checked;
        FMultipage := MultipageCB.Checked;
        FNavigator := NavigatorCB.Checked;
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
    end
  end else
    Result := mrOk;
end;

function TfrxHTMLExport.Start: Boolean;
begin
  if SlaveExport then
  begin
    FOpenAfterExport := False;
    FExportPictures := False;
    FPicsInSameFolder := True;
    FNavigator := False;
    FMultipage := False;
    FBackground := False;
  end;
  if (FileName <> '') or Assigned(Stream) then
  begin
    if (ExtractFilePath(FileName) = '') and (DefaultPath <> '') then
      FileName := DefaultPath + '\' + FileName;
    FCurrentPage := 0;
    FPicturesCount := 0;
    FMatrix := TfrxIEMatrix.Create(UseFileCache, Report.EngineOptions.TempDir);
    FMatrix.Report := Report;
    if not FMultipage then
      FMatrix.ShowProgress := ShowProgress
    else
      FMatrix.ShowProgress := False;
    FMatrix.Inaccuracy := 0.5;
    FMatrix.RotatedAsImage := True;
    FMatrix.FramesOptimization := True;
    FMatrix.Background := FBackground;
    FMatrix.BackgroundImage := False;
    FMatrix.Printable := ExportNotPrintable;
    FMatrix.RichText := True;
    FMatrix.PlainRich := True;
    FMatrix.EmptyLines := EmptyLines;
    if Assigned(Stream) then
    begin
      FMultipage := False;
      FExportPictures := False;
      FNavigator := False;
    end;
    Result := True
  end
  else
    Result := False;
end;

procedure TfrxHTMLExport.StartPage(Page: TfrxReportPage; Index: Integer);
begin
  Inc(FCurrentPage);
  FBackImageExist := False;
  FBackImage.Width := 0;
  FBackImage.Height := 0;
end;

procedure TfrxHTMLExport.ExportObject(Obj: TfrxComponent);
begin
  if Obj is TfrxView then
  begin
    if (Obj is TfrxCustomMemoView) or
      (FExportPictures and (not (Obj is TfrxCustomMemoView))) then
      FMatrix.AddObject(TfrxView(Obj));
    if (TfrxView(Obj).Name = '_pagebackground') and FExportPictures and FBackground then
    begin
      FBackImageExist := True;
      FBackImage.Width := Round(TfrxView(Obj).Width);
      FBackImage.Height := Round(TfrxView(Obj).Height);
      TfrxView(Obj).Draw(FBackImage.Canvas ,1, 1, -TfrxView(Obj).AbsLeft, -TfrxView(Obj).AbsTop);
    end;
  end;
end;

procedure TfrxHTMLExport.FinishPage(Page: TfrxReportPage; Index: Integer);
begin
  if FMultipage then
  begin
    FMatrix.Prepare;
    try
      Exp := TFileStream.Create(GetPicsFolder + IntToStr(FCurrentPage) + '.html', fmCreate);
      try
        ExportPage;
      finally
        FMatrix.Clear;
        Exp.Free;
      end;
    except
      on e: Exception do
        case Report.EngineOptions.NewSilentMode of
          simSilent:        Report.Errors.Add(e.Message);
          simMessageBoxes:  frxErrorMsg(e.Message);
          simReThrow:       raise;
        end;
    end;
  end
  else FMatrix.AddPage(Page.Orientation, Page.Width, Page.Height, Page.LeftMargin,
                    Page.TopMargin, Page.RightMargin, Page.BottomMargin);
end;

procedure TfrxHTMLExport.Finish;
var
  s, st, serv, print: String;
  Refresh: String;

begin
  if not FMultipage then
  begin
    if ShowProgress then
    begin
      FProgress := TfrxProgress.Create(Self);
      FProgress.Execute(FCurrentPage - 1, frxResources.Get('ProgressWait'), true, true);
    end;
    FMatrix.Prepare;
    try
      if ShowProgress then
        if FProgress.Terminated then
          Exit;
      if not Assigned(Stream) then
      begin
        if FNavigator then
          Exp := TFileStream.Create(GetPicsFolder + 'main.html', fmCreate)
        else
          Exp := TFileStream.Create(FileName, fmCreate);
      end
      else
        Exp := Stream;
      try
        ExportPage;
      finally
        FMatrix.Clear;
        if not Assigned(Stream) then
          Exp.Free;
      end;
    except
      on e: Exception do
        case Report.EngineOptions.NewSilentMode of
          simSilent:        Report.Errors.Add(e.Message);
          simMessageBoxes:  frxErrorMsg(e.Message);
          simReThrow:       raise;
        end;
    end;
    if ShowProgress then
      FProgress.Free;
  end;
  if FNavigator then
  begin
    try
      Exp := TFileStream.Create(GetPicsFolder + 'nav.html', fmCreate);
      try
        if FMultipage then
          s := '1'
        else
          s := '0';
        st := '';
        if FPicsInSameFolder then
          st := ChangeFileExt(ExtractFileName(FileName), '.');
        if FServer then
          serv := Format(Server_sect, [UTF8Encode(frxResources.Get('HTMLNavRefresh')), UTF8Encode(frxResources.Get('HTMLNavPrint'))])
        else
          serv := '';
        if Length(FPrintLink) > 0 then
          print := Format(LinkPrint, [FPrintLink])
        else
          print := DefPrint;

        if Length(FRefreshLink) > 0 then
          refresh := Format(LinkRefresh, [FRefreshLink])
        else
          refresh := DefRefresh;

        WriteExpLn(Format(Navigator_src, [
          IntToStr(FCurrentPage),
          HTMLCodeStr(StringReplace(Report.FileName, FReportPath, '', [])),
          s, st, Refresh, print,
          UTF8Encode(frxResources.Get('HTMLNavFirst')),
          UTF8Encode(frxResources.Get('HTMLNavPrev')),
          UTF8Encode(frxResources.Get('HTMLNavNext')),
          UTF8Encode(frxResources.Get('HTMLNavLast')),
          serv, UTF8Encode(frxResources.Get('HTMLNavTotal'))]));

      finally
        Exp.Free;
      end;
    except
      on e: Exception do
        case Report.EngineOptions.NewSilentMode of
          simSilent:        Report.Errors.Add(e.Message);
          simMessageBoxes:  frxErrorMsg(e.Message);
          simReThrow:       raise;
        end;
    end;

    try
      Exp := TFileStream.Create(FileName, fmCreate);
      try
        WriteExpLn('<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">');
        WriteExpLn('<html><head>');
        if Length(Report.ReportOptions.Name) > 0 then
          s := Report.ReportOptions.Name
        else
          s := ChangeFileExt(ExtractFileName(Report.FileName), '');
        WriteExpLn('<title>' + UTF8Encode(s) + '</title>');
        WriteExpLn('<meta http-equiv="Content-Type" content="text/html; charset=utf-8">');
        WriteExpLn('<script language="javascript" type="text/javascript"> var frCurPage = 1;</script></head>');
        WriteExpLn('<frameset rows="32,*" cols="*">');
        WriteExpLn('<frame name="topFrame" src="' + ReverseSlash(GetFrameFolder) + 'nav.html" noresize scrolling="no">');
        if FMultipage then
          WriteExpLn('<frame name="mainFrame" src="' + ReverseSlash(GetFrameFolder) + '1.html">')
        else
          WriteExpLn('<frame name="mainFrame" src="' + ReverseSlash(GetFrameFolder) + 'main.html">');
        WriteExpLn('</frameset>');
        WriteExpLn('</html>');
      finally
        Exp.Free;
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

  FMatrix.Free;

  if FOpenAfterExport and (not Assigned(Stream)) then
    if FMultipage and (not FNavigator) then
      ShellExecute(GetDesktopWindow, 'open', PChar(GetPicsFolder + '1.html'), nil, nil, SW_SHOW)
    else
      ShellExecute(GetDesktopWindow, 'open', PChar(FileName), nil, nil, SW_SHOW);
end;

function TfrxHTMLExport.GetPicsFolderRel: String;
begin
  if FPicsInSameFolder then
    Result := ChangeFileExt(ExtractFileName(FileName), '.')
  else if FMultipage then
    Result := ''
  else if FAbsLinks then
    Result := ExtractFilePath(FileName) + ChangeFileExt(ExtractFileName(FileName),'.files') + '\'
  else if FNavigator then
    Result := ''
  else
    Result := ChangeFileExt(ExtractFileName(FileName),'.files') + '\'
end;

function TfrxHTMLExport.GetFrameFolder: String;
begin
  if not FPicsInSameFolder then
    Result := ChangeFileExt(ExtractFileName(FileName),'.files') + '\'
  else
    Result := ChangeFileExt(ExtractFileName(FileName), '.');
end;

function TfrxHTMLExport.GetPicsFolder: String;
var
  SecAtrtrs: TSecurityAttributes;
begin
  if FPicsInSameFolder then
  begin
    if FAbsLinks then
      Result := ExtractFilePath(FileName) + ChangeFileExt(ExtractFileName(FileName), '.')
    else
      Result := ChangeFileExt(ExtractFileName(FileName), '.')
  end
  else
  begin
    if FAbsLinks then
      Result := ExtractFilePath(FileName) + ChangeFileExt(ExtractFileName(FileName), '.files')
    else
      Result := ChangeFileExt(ExtractFileName(FileName), '.files');
    SecAtrtrs.nLength := SizeOf(TSecurityAttributes);
    SecAtrtrs.lpSecurityDescriptor := nil;
    SecAtrtrs.bInheritHandle := True;
    CreateDirectory(PChar(Result), @SecAtrtrs);
    Result := Result + '\';
  end;
end;

function TfrxHTMLExport.ReverseSlash(const S: String): String;
begin
  Result := StringReplace(S, '\', '/', [rfReplaceAll]);
end;

destructor TfrxHTMLExport.Destroy;
begin
  FBackImage.Free;
  inherited;
end;

function TfrxHTMLExport.HTMLCodeStr(const Str: String): String;
var
  i: Integer;
  c: Char;
  s: String;

  function StrToHex(const s: String): String;
  var
    Len, i: Integer;
    C, H, L: Byte;

    function HexChar(N : Byte) : Char;
    begin
      if (N < 10) then Result := Chr(Ord('0') + N)
      else Result := Chr(Ord('A') + (N - 10));
    end;

  begin
    Len := Length(s);
    SetLength(Result, Len shl 1);
    for i := 1 to Len do begin
      C := Ord(s[i]);
      H := (C shr 4) and $f;
      L := C and $f;
      Result[i shl 1 - 1] := HexChar(H);
      Result[i shl 1]:= HexChar(L);
    end;
  end;

begin
  Result := '';
  for i := 1 to Length(Str) do
  begin
    c := Str[i];
    case c of
     '0'..'9', 'A'..'Z', 'a'..'z': Result := Result + c;
      else begin
        s := c;
        Result := Result + '%' + StrToHex(s);
      end
   end;
  end;
end;

procedure TfrxHTMLExport.SetUseGif(const Value: Boolean);
begin
  FUseGif := Value;
  if FUseJpeg and FUseGif then
    FUseJpeg := False;
end;

procedure TfrxHTMLExport.SetUseJpeg(const Value: Boolean);
begin
  FUseJpeg := Value;
  if FUseJpeg and FUseGif then
    FUseGif := False;
end;

{ TfrxHTMLExportDialog }

procedure TfrxHTMLExportDialog.FormCreate(Sender: TObject);
begin
  Caption := frxGet(8200);
  OkB.Caption := frxGet(1);
  CancelB.Caption := frxGet(2);
  GroupPageRange.Caption := frxGet(7);
  AllRB.Caption := frxGet(3);
  CurPageRB.Caption := frxGet(4);
  PageNumbersRB.Caption := frxGet(5);
  DescrL.Caption := frxGet(9);
  GroupQuality.Caption := frxGet(8);
  OpenAfterCB.Caption := frxGet(8201);
  StylesCB.Caption := frxGet(8202);
  PicturesL.Caption := frxGet(8203);
  PicsSameCB.Caption := frxGet(8204);
  FixWidthCB.Caption := frxGet(8205);
  NavigatorCB.Caption := frxGet(8206);
  MultipageCB.Caption := frxGet(8207);
  BackgrCB.Caption := frxGet(8209);
  SaveDialog1.Filter := frxGet(8210);
  SaveDialog1.DefaultExt := frxGet(8211);
  PFormatCB.Items[0] := frxGet(8313);
end;


procedure TfrxHTMLExportDialog.PageNumbersEChange(Sender: TObject);
begin
  PageNumbersRB.Checked := True;
end;

procedure TfrxHTMLExportDialog.PageNumbersEKeyPress(Sender: TObject;
  var Key: Char);
begin
  case key of
    '0'..'9':;
    #8, '-', ',':;
  else
    key := #0;
  end;
end;

procedure TfrxHTMLExportDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

end.
