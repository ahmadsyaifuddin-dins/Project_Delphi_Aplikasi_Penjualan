
{******************************************}
{                                          }
{             FastReport v4.0              }
{            RTF export filter             }
{                                          }
{         Copyright (c) 1998-2006          }
{          by Alexander Fediachov,         }
{             Fast Reports Inc.            }
{                                          }
{******************************************}

unit frxExportRTF;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, extctrls, ComObj, Printers, frxClass, JPEG, ShellAPI, frxExportMatrix
{$IFDEF Delphi6}, Variants {$ENDIF}, frxProgress, ComCtrls;

type
  TfrxHeaderFooterMode = (hfText, hfPrint, hfNone);

  TfrxRTFExportDialog = class(TForm)
    OkB: TButton;
    CancelB: TButton;
    GroupPageRange: TGroupBox;
    DescrL: TLabel;
    AllRB: TRadioButton;
    CurPageRB: TRadioButton;
    PageNumbersRB: TRadioButton;
    PageNumbersE: TEdit;
    GroupQuality: TGroupBox;
    WCB: TCheckBox;
    PageBreaksCB: TCheckBox;
    PicturesCB: TCheckBox;
    OpenCB: TCheckBox;
    SaveDialog1: TSaveDialog;
    ContinuousCB: TCheckBox;
    HeadFootL: TLabel;
    PColontitulCB: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure PageNumbersEChange(Sender: TObject);
    procedure PageNumbersEKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  end;

  TfrxRTFExport = class(TfrxCustomExportFilter)
  private
    FColorTable: TStringList;
    FCurrentPage: Integer;
    FDataList: TList;
    FExportPageBreaks: Boolean;
    FExportPictures: Boolean;
    FFirstPage: Boolean;
    FFontTable: TStringList;
    FCharsetTable: TStringList;
    FMatrix: TfrxIEMatrix;
    FOpenAfterExport: Boolean;
    FProgress: TfrxProgress;
    FWysiwyg: Boolean;
  	FCreator: String;
    FHeaderFooterMode: TfrxHeaderFooterMode;
    function TruncReturns(const Str: WideString): WideString;
    function GetRTFBorders(const Style: TfrxIEMStyle): string;
    function GetRTFColor(const c: Integer): string;
    function GetRTFFontStyle(const f: TFontStyles): String;
    function GetRTFFontColor(const f: String): String;
    function GetRTFFontName(const f: String; const charset: Integer): String;
    function GetRTFHAlignment(const HAlign: TfrxHAlign) : String;
    function GetRTFVAlignment(const VAlign: TfrxVAlign) : String;
    function StrToRTFUnicode(const Value: WideString): String;
    procedure ExportPage(const Stream: TStream);
    procedure PrepareExport;
  public
    constructor Create(AOwner: TComponent); override;
    class function GetDescription: String; override;
    function ShowModal: TModalResult; override;
    function Start: boolean; override;
    procedure Finish; override;
    procedure FinishPage(Page: TfrxReportPage; Index: Integer); override;
    procedure StartPage(Page: TfrxReportPage; Index: Integer); override;
    procedure ExportObject(Obj: TfrxComponent); override;
  published
    property ExportPageBreaks: Boolean read FExportPageBreaks write FExportPageBreaks default True;
    property ExportPictures: Boolean read FExportPictures write FExportPictures default True;
    property OpenAfterExport: Boolean read FOpenAfterExport
      write FOpenAfterExport default False;
    property Wysiwyg: Boolean read FWysiwyg write FWysiwyg;
    property Creator: String read FCreator write FCreator;
    property SuppressPageHeadersFooters;
    property HeaderFooterMode: TfrxHeaderFooterMode read FHeaderFooterMode write FHeaderFooterMode;
  end;


implementation

uses frxUtils, frxFileUtils, frxRes, frxrcExports;

{$R *.dfm}

const
  Xdivider = 15.05;
  Ydivider = 13;
  PageDivider = 15.02;
  MargDivider = 56.48;
  FONT_DIVIDER = 15;
  IMAGE_DIVIDER = 25.3;


{ TfrxRTFExport }

constructor TfrxRTFExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ShowDialog := True;
  FExportPageBreaks := True;
  FExportPictures := True;
  FWysiwyg := True;
  FHeaderFooterMode := hfText;
  FCreator := 'FastReport http://www.fast-report.com';
  FilterDesc := frxGet(8504);
  DefaultExt := frxGet(8505);
end;

class function TfrxRTFExport.GetDescription: String;
begin
  Result := frxResources.Get('RTFexport');
end;

function TfrxRTFExport.TruncReturns(const Str: WideString): WideString;
begin
  Result := Str;
  if Copy(Result, Length(Result) - 1, 2) = #13#10 then
    Delete(Result, Length(Result) - 1, 2);
end;

function TfrxRTFExport.StrToRTFUnicode(const Value: WideString): String;
var
  i: integer;
  pwc: ^Word;
begin
  result := '';
  for i := 1 to Length(Value) do
  begin
    if Value[i] = '\' then
      result := result + '\\'
    else if Value[i] = '{' then
      result := result + '\{'
    else if Value[i] = '}' then
      result := result + '\}'
    else if (Value[i] = #13) and (i < (Length(Value) - 1)) and (Value[i + 1] = #10) then
      result := result + '\line'#13
    else
    begin
      pwc := @Value[i];
      if pwc^ > 127 then
        result := result + '\u' + IntToStr(pwc^) + '\''3f'
      else
        result := result + Chr(pwc^);
    end;
  end;
end;

function TfrxRTFExport.GetRTFBorders(const Style: TfrxIEMStyle): string;
var
  brdrw: String;
  brdrc: String;
  brdrs: String;
begin
  Result := '';
  brdrw := '\brdrs\brdrw' + IntToStr(Round(Style.FrameWidth * 20));
  brdrc := '\brdrcf' + GetRTFFontColor(GetRTFColor(Style.FrameColor));
  if Style.FrameStyle = fsDouble then
    brdrs := '\brdrdashdd'
  else if Style.FrameStyle <> fsSolid then
    brdrs := '\brdrdashsm'
  else brdrs := '';
  if ftTop in Style.FrameTyp then
    Result := Result + '\clbrdrt' + brdrw + brdrc + brdrs;
  if ftLeft in Style.FrameTyp then
    Result := Result + '\clbrdrl' + brdrw + brdrc + brdrs;
  if ftBottom in Style.FrameTyp then
    Result := Result + '\clbrdrb' + brdrw + brdrc + brdrs;
  if ftRight in Style.FrameTyp then
    Result := Result + '\clbrdrr' + brdrw + brdrc + brdrs;
end;

function TfrxRTFExport.GetRTFColor(const c: Integer): string;
begin
  Result := '\red' + IntToStr(GetRValue(c)) +
            '\green' + IntToStr(GetGValue(c)) +
            '\blue' + IntToStr(GetBValue(c)) + ';'
end;

function TfrxRTFExport.GetRTFFontStyle(const f: TFontStyles): String;
begin
  Result := '';
  if fsItalic in f then Result := '\i';
  if fsBold in f then Result := Result + '\b';
  if fsUnderline in f then Result := Result + '\ul';
end;

function TfrxRTFExport.GetRTFFontColor(const f: String): String;
var
  i: Integer;
begin
  i := FColorTable.IndexOf(f);
  if i <> -1 then
    Result := IntToStr(i + 1)
  else
  begin
    FColorTable.Add(f);
    Result := IntToStr(FColorTable.Count);
  end;
end;

function TfrxRTFExport.GetRTFFontName(const f: String; const Charset: Integer): String;
var
  i: Integer;
begin
  i := FFontTable.IndexOf(f);
  if i <> -1 then
    Result := IntToStr(i)
  else
  begin
    FFontTable.Add(f);
    FCharsetTable.Add(IntToStr(charset));
    Result := IntToStr(FFontTable.Count - 1);
  end;
end;

function TfrxRTFExport.GetRTFHAlignment(const HAlign: TfrxHAlign) : String;
begin
  if (HAlign = haLeft) then Result := '\ql'
  else if (HAlign = haRight) then Result := '\qr'
  else if (HAlign = haCenter) then Result := '\qc'
//  else if (HAlign = haBlock) then Result := '\qj'
  else Result := '\ql';
end;

function TfrxRTFExport.GetRTFVAlignment(const VAlign: TfrxVAlign) : String;
begin
  if (VAlign = vaTop) then Result := '\clvertalt'
  else if (VAlign = vaCenter) then Result := '\clvertalc'
  else if (VAlign = vaBottom) then Result := '\clvertalb'
  else Result := '\clvertalt';
end;

procedure TfrxRTFExport.PrepareExport;
var
  i, j, x, y, n, n1, fx: Integer;
  s, s0, s1, s2: String;
  Obj: TfrxIEMObject;
  RepPos: TStringList;

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
  for y := 0 to FMatrix.Height - 1 do
    for x := 0 to FMatrix.Width - 1 do
    begin
      i := FMatrix.GetCell(x, y);
      if (i <> -1) then
      begin
        Obj := FMatrix.GetObjectById(i);
        if Obj.Counter <> -1 then
        begin
          Obj.Counter := -1;
          GetRTFFontColor(GetRTFColor(Obj.Style.Color));
          GetRTFFontColor(GetRTFColor(Obj.Style.FrameColor));
          if Obj.IsRichText then
          begin
            RepPos := TStringList.Create;
            s := Obj.Memo.Text;
            fx := Pos('{\fonttbl', s);
            Delete(s, 1, fx + 8);
            i := 1;
            RepPos.Clear;
            while (i < Length(s)) and (s[i] <> '}') do
            begin
              while (i < Length(s)) and (s[i] <> '{') and (s[i] <> '}') do
                Inc(i);
              j := i;
              while (j < Length(s)) and (s[j] <> '}') do
                Inc(j);
              Inc(j);
              s1 := Copy(s, i , j - i - 2);
              i := j;
              j := Pos(' ', s1);
              s2 := Copy(s1, j + 1, Length(s1) - j + 1);
              s0 := '\f' + GetRTFFontName(s2, 1);
              j := Pos('\f', s1);
              n := j + 1;
              while (n < Length(s1)) and (s1[n] <> '\') and (s1[n] <> ' ') do
                Inc(n);
              s2 := Copy(s1, j, n - j);
              j := Pos('}}', s);
              s1 := Copy(s, j + 2, Length(s) - j - 1);
              j := j + 2;
              n := 1;
              while n > 0 do
              begin
                n := Pos(s2, s1);
                if n > 0 then
                begin
                  if RepPos.IndexOf(IntToStr(n + j - 1)) = -1 then
                  begin
                    RepPos.Add(IntToStr(n + j - 1));
                    Delete(s, n + j - 1, Length(s2));
                    Insert(s0, s, n + j - 1);
                  end;
                  j := j + n + Length(s2) - 1;
                  s1 := Copy(s, j, Length(s) - j + 1);
                end;
              end;
            end;
            fx := Pos('}}', s);
            if fx > 0 then
              Delete(s, 1, fx + 1);
            fx := Pos('{\colortbl', s);
            if fx > 0 then
            begin
              Delete(s, 1, fx + 11);
              i := 1;
              n1 := 1;
              RepPos.Clear;
              while (i < Length(s)) and (s[i] <> '}') do
              begin
                while (i < Length(s)) and (s[i] <> '\') do
                  Inc(i);
                j := i;
                while (j < Length(s)) and (s[j] <> ';') do
                  Inc(j);
                Inc(j);
                s1 := Copy(s, i , j - i);
                i := j;
                s0 := '\cf' + GetRTFFontColor(s1);
                s2 := '\cf' + IntToStr(n1);
                j := Pos(';}', s);
                s1 := Copy(s, j + 2, Length(s) - j - 1);
                j := j + 2;
                n := 1;
                while n > 0 do
                begin
                  n := Pos(s2, s1);
                  if n > 0 then
                  begin
                    if RepPos.IndexOf(IntToStr(n + j - 1)) = -1 then
                    begin
                      RepPos.Add(IntToStr(n + j - 1));
                      Delete(s, n + j - 1, Length(s2));
                      Insert(s0, s, n + j - 1);
                    end;
                    j := j + n + Length(s2) - 1;
                    s1 := Copy(s, j, Length(s) - j + 1);
                  end;
                end;
                Inc(n1);
              end;
              fx := Pos(';}', s);
              if fx > 0 then
                Delete(s, 1, fx + 1);
            end;
            fx := Pos('{\stylesheet', s);
            if fx > 0 then
            begin
              Delete(s, 1, fx + 12);
              fx := Pos('}}', s);
              if fx > 0 then
                Delete(s, 1, fx + 1);
            end;
            s := StringReplace(s, '\pard', '', [rfReplaceAll]);
            Delete(s, Length(s) - 3, 3);

            fx := 1;
            while fx > 0 do
            begin
              fx := Pos('\lang', s);
              if fx > 0 then
              begin
                Delete(s, fx , 5);
                n := PosEx('\', s, fx);
                Delete(s, fx, n - fx);
              end;
            end;

            fx := 1;
            while fx > 0 do
            begin
              fx := Pos('\sa', s);
              if fx > 0 then
              begin
                Delete(s, fx , 3);
                n := PosEx('\', s, fx);
                Delete(s, fx, n - fx);
              end;
            end;

            fx := 1;
            while fx > 0 do
            begin
              fx := Pos('\sb', s);
              if fx > 0 then
              begin
                Delete(s, fx , 3);
                n := PosEx('\', s, fx);
                Delete(s, fx, n - fx);
              end;
            end;

            Obj.Memo.Text := s;
            RepPos.Free;
          end else if Obj.IsText then
          begin
            GetRTFFontColor(GetRTFColor(Obj.Style.Font.Color));
            GetRTFFontName(Obj.Style.Font.Name, Obj.Style.Charset);
          end;
        end;
      end;
    end;
end;

procedure TfrxRTFExport.ExportPage(const Stream: TStream);
var
  i, j, x, y, fx, fy, dx, dy, n, n1, pbk: Integer;
  dcol, drow, xoffs: Integer;
  buff, s, s0, s1, s2: String;
  CellsLine: String;
  Obj: TfrxIEMObject;
  Graphic: TGraphic;
  Str, CellsStream: TStream;
  bArr: array[0..1023] of Byte;
  FMode: Integer; // 3 - header, 2 - footer, 1 - body, 0 - stop

  procedure WriteExpLn(const str: string);
  begin
    if Length(str) > 0 then
    begin
      Stream.Write(str[1], Length(str));
      Stream.Write(#13#10, 2);
    end;
  end;

  procedure SetPageProp(Page: Integer);
  begin
    WriteExpLn('\pgwsxn' + IntToStr(Round(FMatrix.GetPageWidth(Page) * PageDivider)) +
               '\pghsxn' + IntToStr(Round(FMatrix.GetPageHeight(Page) * PageDivider)) +
               '\marglsxn' + IntToStr(Round(FMatrix.GetPageLMargin(Page) * MargDivider)) +
               '\margrsxn' + IntToStr(Round(FMatrix.GetPageRMargin(Page) * MargDivider)) +
               '\margtsxn' + IntToStr(Round(FMatrix.GetPageTMargin(Page) * MargDivider)) +
               '\margbsxn' + IntToStr(Round(FMatrix.GetPageBMargin(Page) * MargDivider)));
    if FMatrix.GetPageOrientation(Page) = poLandscape then
      WriteExpLn('\lndscpsxn');
  end;

begin
  PrepareExport;
  WriteExpLn('{\rtf1\ansi');
  s := '{\fonttbl';
  for i := 0 to FFontTable.Count - 1 do
  begin
    s1 := '{\f' + IntToStr(i) + '\fcharset' + FCharsetTable[i] +  ' ' + FFontTable[i] + '}';
    if Length(s + s1) < 255 then
      s := s + s1
    else
    begin
      WriteExpLn(s);
      s := s1;
    end;
  end;
  s := s + '}';
  WriteExpLn(s);
  s := '{\colortbl;';
  for i := 0 to FColorTable.Count - 1 do
  begin
    s1 := FColorTable[i];
    if Length(s + s1) < 255 then
      s := s + s1
    else
    begin
      WriteExpLn(s);
      s := s1;
    end;
  end;
  s := s + '}';
  WriteExpLn(s);
  WriteExpLn('{\info{\title ' + StrToRTFUnicode(Report.ReportOptions.Name) +
             '}{\author ' + StrToRTFUnicode(FCreator) +
             '}{\creatim\yr' + FormatDateTime('yyyy', Now) +
             '\mo' + FormatDateTime('mm', Now) + '\dy' + FormatDateTime('dd', Now) +
             '\hr' + FormatDateTime('hh', Now) + '\min' + FormatDateTime('nn', Now) + '}}');
  if ShowProgress then
    FProgress.Execute(FMatrix.Height - 1, frxResources.Get('ProgressWait'), True, True);
  pbk := 0;
  SetPageProp(pbk);

  if FHeaderFooterMode = hfPrint then
    FMode := 3
  else
    FMode := 1;
///
  while FMode > 0 do
  begin
    if FMode = 3 then
      WriteExpLn('{\header ')
    else if FMode = 2 then
      WriteExpLn('{\footer ');

    for y := 0 to FMatrix.Height - 2 do
    begin
      if ShowProgress then
      begin
        FProgress.Tick;
        if FProgress.Terminated then
          break;
      end;
      if FExportPageBreaks and (FMode = 1) then
        if FMatrix.PagesCount > pbk then
          if FMatrix.GetPageBreak(pbk) <= FMatrix.GetYPosById(y) then
          begin
  //          WriteExpLn('\pagebb\sect');
            WriteExpLn('\pard\sect');
            Inc(pbk);
            if pbk < FMatrix.PagesCount then
              SetPageProp(pbk);
            continue;
          end;
      drow := Round((FMatrix.GetYPosById(y + 1) - FMatrix.GetYPosById(y)) * Ydivider);
      buff := '\trrh' + IntToStr(drow)+ '\trgaph15';
      CellsStream := TMemoryStream.Create;
      try
        xoffs := Round(FMatrix.GetXPosById(1));
        for x := 1 to FMatrix.Width - 2 do
        begin
          i := FMatrix.GetCell(x, y);
          if (i <> -1) then
          begin
            Obj := FMatrix.GetObjectById(i);

            if (FMode = 3) and (not Obj.Header) then
              Continue;
            if (FMode = 2) and (not Obj.Footer) then
              Continue;
            if (FMode = 1) and (Obj.Header or Obj.Footer) and
               ((FHeaderFooterMode = hfPrint) or
                (FHeaderFooterMode = hfNone)) then
              Continue;

            FMatrix.GetObjectPos(i, fx, fy, dx, dy);
            if Obj.Counter = -1 then
            begin
              if dy > 1 then
                buff := buff + '\clvmgf';
              if (obj.Style.Color mod 16777216) <> clWhite then
                buff := buff + '\clcbpat' + GetRTFFontColor(GetRTFColor(Obj.Style.Color));
              buff := buff + GetRTFVAlignment(Obj.Style.VAlign) + GetRTFBorders(Obj.Style) + '\cltxlrtb';
              dcol := Round((Obj.Left + Obj.Width - xoffs) * Xdivider);
              buff := buff + '\cellx' + IntToStr(dcol);
              if Obj.IsText then
              begin
                s := '\f' + GetRTFFontName(Obj.Style.Font.Name, Obj.Style.Charset);
                if Length(Obj.Memo.Text) > 0 then
                  s := s + '\fs' + IntToStr(Obj.Style.Font.Size * 2)
                else
                begin
                  j := drow div FONT_DIVIDER;
                  if j > 20 then j := 20;
                  s := s + '\fs' + IntToStr(j);
                end;
                s := s + GetRTFFontStyle(Obj.Style.Font.Style);
                s := s + '\cf' + GetRTFFontColor(GetRTFColor(Obj.Style.Font.Color));
                if (Obj.IsRichText) then
                  s1 := Obj.Memo.Text
                else
                  s1 := StrToRTFUnicode(TruncReturns(Obj.Memo.Text));
                if Trim(s1) <> '' then
                begin
                  j := Round(Obj.Style.CharSpacing * FONT_DIVIDER);
                  s2 := '\sb' + IntToStr(Round(Obj.Style.GapY * Ydivider)) +
                      '\li' + IntToStr(Round((Obj.Style.GapX / 2) * Xdivider)) +
                      '\fi' + IntToStr(Round((Obj.Style.ParagraphGap) * Xdivider)) +
                      '\expnd' + IntToStr(j div 5) + '\expndtw' + IntToStr(j) +
                      '\sl' + IntToStr(Round((Obj.Style.Font.Size + Obj.Style.LineSpacing - 2) * Ydivider)) +
                      '\slmult0';
                  if Obj.Style.WordBreak then
                    s2 := s2 + '\hyphauto1\hyphcaps1';
                end else
                  s2 := '';
                CellsLine := GetRTFHAlignment(Obj.Style.HAlign) +
                  '{' + s + s2 + ' ' + s1 + '\cell}';
                s := '\par'#13#10'\cell';
                while Pos(s, CellsLine) > 0 do
                  CellsLine := StringReplace(CellsLine, s, '\cell', []);
                CellsStream.Write(CellsLine[1], Length(CellsLine));
              end
              else if FExportPictures then
              begin
                Graphic := Obj.Image;
                if not ((Graphic = nil) or Graphic.Empty) then
                begin
                  Str := TMemoryStream.Create;
                  try
                    dx := Round(Obj.Width);
                    dy := Round(Obj.Height);
                    fx := Graphic.Width;
                    fy := Graphic.Height;
                    Graphic.SaveToStream(Str);
                    Str.Position := 0;
                    CellsLine := '{\sb0\li0\sl0\slmult0 {\pict\wmetafile8\picw' + FloatToStr(Round(dx * IMAGE_DIVIDER)) +
                         '\pich' + FloatToStr(Round(dy * IMAGE_DIVIDER)) + '\picbmp\picbpp4' + #13#10;
                    CellsStream.Write(CellsLine[1], Length(CellsLine));
                    Str.Read(n, 2);
                    Str.Read(n, 4);
                    n := n div 2 + 7;
                    s0 := IntToHex(n + $24, 8);
                    s := '010009000003' + Copy(s0, 7, 2) + Copy(s0, 5, 2) +
                         Copy(s0, 3, 2) + Copy(s0, 1, 2) + '0000';
                    s0 := IntToHex(n, 8);
                    s1 := Copy(s0, 7, 2) + Copy(s0, 5, 2) + Copy(s0, 3, 2) + Copy(s0, 1, 2);
                    s := s + s1 + '0000050000000b0200000000050000000c02';
                    s0 := IntToHex(fy, 4);
                    s := s + Copy(s0, 3, 2) + Copy(s0, 1, 2);
                    s0 := IntToHex(fx, 4);
                    s := s + Copy(s0, 3, 2) + Copy(s0, 1, 2) +
                      '05000000090200000000050000000102ffffff000400000007010300' + s1 +
                      '430f2000cc000000';
                    s0 := IntToHex(fy, 4);
                    s := s + Copy(s0, 3, 2) + Copy(s0, 1, 2);
                    s0 := IntToHex(fx, 4);
                    s := s + Copy(s0, 3, 2) + Copy(s0, 1, 2) + '00000000';
                    s0 := IntToHex(fy, 4);
                    s := s + Copy(s0, 3, 2) + Copy(s0, 1, 2);
                    s0 := IntToHex(fx, 4);
                    s := s + Copy(s0, 3, 2) + Copy(s0, 1, 2) + '00000000';
                    CellsLine := s + #13#10;
                    CellsStream.Write(CellsLine[1], Length(CellsLine));
                    Str.Read(bArr[0], 8);
                    n1 := 0; s := '';
                    repeat
                      n := Str.Read(bArr[0], 1024);
                      for j := 0 to n - 1 do
                      begin
                        s := s + IntToHex(bArr[j], 2);
                        Inc(n1);
                        if n1 > 63 then
                        begin
                          n1 := 0;
                          CellsLine := s + #13#10;
                          CellsStream.Write(CellsLine[1], Length(CellsLine));
                          s := '';
                        end;
                      end;
                    until n < 1024;
                  finally
                    Str.Free;
                  end;
                  if n1 <> 0 then
                  begin
                    CellsLine := s + #13#10;
                    CellsStream.Write(CellsLine[1], Length(CellsLine));
                  end;
                  s := '030000000000}';
                  CellsLine := s + '\cell}' + #13#10;
                  CellsStream.Write(CellsLine[1], Length(CellsLine));
                end;
              end;
              Obj.Counter := y + 1;
            end
            else
            begin
              if (dy > 1) and (Obj.Counter <> (y + 1))then
              begin
                buff := buff + '\clvmrg';
                buff := buff + GetRTFBorders(Obj.Style) + '\cltxlrtb';
                dcol := Round((Obj.Left + Obj.Width - xoffs) * Xdivider);
                buff := buff + '\cellx' + IntToStr(dcol);
                j := drow div FONT_DIVIDER;
                if j > 20 then
                  j := 20;
                CellsLine := '{\fs' + IntToStr(j) + '\cell}';
                CellsStream.Write(CellsLine[1], Length(CellsLine));
                Obj.Counter := y + 1;
              end;
            end
          end
        end;
        if CellsStream.Size > 0 then
        begin
          s := '\trowd' + buff + '\pard\intbl';
          WriteExpLn(s);
          Stream.CopyFrom(CellsStream, 0);
          WriteExpLn('\pard\intbl{\trowd' + buff + '\row}');
        end;
      finally
        CellsStream.Free;
      end;
    end;
    if FMode in [2, 3] then
      WriteExpLn('}');
    Dec(FMode);
  end;
//
  WriteExpLn('}');
end;

function TfrxRTFExport.ShowModal: TModalResult;
begin
  if not Assigned(Stream) then
  begin
    with TfrxRTFExportDialog.Create(nil) do
    begin
      SendMessage(GetWindow(PColontitulCB.Handle,GW_CHILD), EM_SETREADONLY, 1, 0);
      OpenCB.Visible := not SlaveExport;
      if SlaveExport then
        FOpenAfterExport := False;

      if (FileName = '') and (not SlaveExport) then
        SaveDialog1.FileName := ChangeFileExt(ExtractFileName(Report.FileName), SaveDialog1.DefaultExt)
      else
        SaveDialog1.FileName := FileName;

      ContinuousCB.Checked := SuppressPageHeadersFooters;
      PicturesCB.Checked := FExportPictures;
      PageBreaksCB.Checked := FExportPageBreaks;
      WCB.Checked := FWysiwyg;
      OpenCB.Checked := FOpenAfterExport;

      if PageNumbers <> '' then
      begin
        PageNumbersE.Text := PageNumbers;
        PageNumbersRB.Checked := True;
      end;

      if FHeaderFooterMode = hfText then
        PColontitulCB.ItemIndex := 0
      else if FHeaderFooterMode = hfPrint then
        PColontitulCB.ItemIndex := 1
      else
        PColontitulCB.ItemIndex := 2;

      Result := ShowModal;

      if Result = mrOk then
      begin
        if PColontitulCB.ItemIndex = 0 then
          FHeaderFooterMode := hfText
        else if PColontitulCB.ItemIndex = 1 then
          FHeaderFooterMode := hfPrint
        else
          FHeaderFooterMode := hfNone;

        PageNumbers := '';
        CurPage := False;
        if CurPageRB.Checked then
          CurPage := True
        else if PageNumbersRB.Checked then
          PageNumbers := PageNumbersE.Text;

        SuppressPageHeadersFooters := ContinuousCB.Checked;

        if FHeaderFooterMode = hfPrint then
          SuppressPageHeadersFooters := True;

        FExportPictures := PicturesCB.Checked;
        FExportPageBreaks := PageBreaksCB.Checked;
        FWysiwyg := WCB.Checked;
        FOpenAfterExport := OpenCB.Checked;

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

function TfrxRTFExport.Start: Boolean;
begin
  if (FileName <> '') or Assigned(Stream) then
  begin
    if (ExtractFilePath(FileName) = '') and (DefaultPath <> '') then
      FileName := DefaultPath + '\' + FileName;
    FFirstPage := True;
    FCurrentPage := 0;
    FMatrix := TfrxIEMatrix.Create(UseFileCache, Report.EngineOptions.TempDir);
    FMatrix.ShowProgress := ShowProgress;
    if FWysiwyg then
      FMatrix.Inaccuracy := 0.5
    else
      FMatrix.Inaccuracy := 10;
    FMatrix.RotatedAsImage := True;
    FMatrix.RichText := True;
    FMatrix.PlainRich := False;
    FMatrix.AreaFill := True;
    FMatrix.CropAreaFill := True;
    FMatrix.DeleteHTMLTags := True;
    FMatrix.BackgroundImage := False;
    FMatrix.Background := False;
    FMatrix.Printable := ExportNotPrintable;
    FFontTable := TStringList.Create;
    FCharsetTable := TStringList.Create;
    FColorTable := TStringList.Create;
    FDataList := TList.Create;
    Result := True
  end
  else
    Result := False;
end;

procedure TfrxRTFExport.StartPage(Page: TfrxReportPage; Index: Integer);
begin
  Inc(FCurrentPage);
  if FFirstPage then
    FFirstPage := False;
end;

procedure TfrxRTFExport.ExportObject(Obj: TfrxComponent);
begin
  if (Obj is TfrxPageHeader) then
    FMatrix.SetPageHeader(TfrxBand(Obj))
  else if (Obj is TfrxPageFooter) then
    FMatrix.SetPageFooter(TfrxBand(Obj))
  else if Obj is TfrxView then
  begin
    if (Obj is TfrxCustomMemoView) or
      (FExportPictures and (not (Obj is TfrxCustomMemoView))) then
        FMatrix.AddObject(TfrxView(Obj))
  end;
end;

procedure TfrxRTFExport.FinishPage(Page: TfrxReportPage; Index: Integer);
begin
  FMatrix.AddPage(Page.Orientation, Page.Width, Page.Height, Page.LeftMargin,
                  Page.TopMargin, Page.RightMargin, Page.BottomMargin);
end;

procedure TfrxRTFExport.Finish;
var
  Exp: TStream;

begin
  FMatrix.Prepare;
  if ShowProgress then
    FProgress := TfrxProgress.Create(nil);
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
  FMatrix.Clear;
  FMatrix.Free;
  FFontTable.Free;
  FCharsetTable.Free;
  FColorTable.Free;
  FDataList.Free;
  if ShowProgress then
    FProgress.Free;
end;

{ TfrxRTFExportDialog }

procedure TfrxRTFExportDialog.FormCreate(Sender: TObject);
begin
  Caption := frxGet(8500);
  OkB.Caption := frxGet(1);
  CancelB.Caption := frxGet(2);
  GroupPageRange.Caption := frxGet(7);
  AllRB.Caption := frxGet(3);
  CurPageRB.Caption := frxGet(4);
  PageNumbersRB.Caption := frxGet(5);
  DescrL.Caption := frxGet(9);
  GroupQuality.Caption := frxGet(8);
  ContinuousCB.Caption := frxGet(8950);
  PicturesCB.Caption := frxGet(8501);
  PageBreaksCB.Caption := frxGet(6);
  WCB.Caption := frxGet(8502);
  OpenCB.Caption := frxGet(8503);
  SaveDialog1.Filter := frxGet(8504);
  SaveDialog1.DefaultExt := frxGet(8505);
  HeadFootL.Caption := frxGet(8951);
  PColontitulCB.Items[0] := frxGet(8952);
  PColontitulCB.Items[1] := frxGet(8953);
  PColontitulCB.Items[2] := frxGet(8954);
end;

procedure TfrxRTFExportDialog.PageNumbersEChange(Sender: TObject);
begin
  PageNumbersRB.Checked := True;
end;

procedure TfrxRTFExportDialog.PageNumbersEKeyPress(Sender: TObject;
  var Key: Char);
begin
  case key of
    '0'..'9':;
    #8, '-', ',':;
  else
    key := #0;
  end;
end;

procedure TfrxRTFExportDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

end.
