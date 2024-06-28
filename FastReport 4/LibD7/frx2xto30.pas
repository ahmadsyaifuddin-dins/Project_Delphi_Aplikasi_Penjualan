
{******************************************}
{                                          }
{             FastReport v4.0              }
{             FR2.x importer               }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frx2xto30;

interface

{$I frx.inc}

implementation

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Printers, TypInfo, Jpeg, DB,
  frxClass, frxVariables, frxPrinter, frxDCtrl, frxBarcode, frxBarcod,
  TeeProcs, TeEngine, Chart, Series, frxChart, frxChBox, frxOLE, frxRich,
  frxCross, frxCrossMatrix, frxDBSet, frxUnicodeUtils, frxUtils, fs_ipascal,
  frxCustomDB, frxBDEComponents, frxADOComponents, frxIBXComponents
{$IFDEF Delphi6}
, Variants
{$ENDIF};

type
  TfrxFR2EventsNew = class(TObject)
  private
    FReport: TfrxReport;
    procedure DoGetValue(const Expr: String; var Value: Variant);
    procedure DoPrepareScript(Sender: TObject);
    function GetScriptValue(Instance: TObject; ClassType: TClass;
      const MethodName: String; var Params: Variant): Variant;
    function DoLoad(Sender: TfrxReport; Stream: TStream): Boolean;
    function DoGetScriptValue(var Params: Variant): Variant;
  end;

  TfrPageType = (ptReport, ptDialog);
  TfrBandType = (btReportTitle, btReportSummary,
                 btPageHeader, btPageFooter,
                 btMasterHeader, btMasterData, btMasterFooter,
                 btDetailHeader, btDetailData, btDetailFooter,
                 btSubDetailHeader, btSubDetailData, btSubDetailFooter,
                 btOverlay, btColumnHeader, btColumnFooter,
                 btGroupHeader, btGroupFooter,
                 btCrossHeader, btCrossData, btCrossFooter,
                 btChild, btNone);

  TfrxFixupItem = class(TObject)
  public
    Obj: TPersistent;
    PropInfo: PPropInfo;
    Value: String;
  end;

  TfrHighlightAttr = packed record
    FontStyle: Word;
    FontColor, FillColor: TColor;
  end;

  TfrBarCodeRec = packed record
    cCheckSum : Boolean;
    cShowText : Boolean;
    cCadr     : Boolean;
    cBarType  : TfrxBarcodeType;
    cModul    : Integer;
    cRatio    : Double;
    cAngle    : Double;
  end;

  TChartOptions = packed record
    ChartType: Byte;
    Dim3D, IsSingle, ShowLegend, ShowAxis, ShowMarks, Colored: Boolean;
    MarksStyle: Byte;
    Top10Num: Integer;
    Reserved: array[0..35] of Byte;
  end;

  TfrRoundRect = packed record
    SdColor: TColor;    // Color of Shadow
    wShadow: Integer;   // Width of shadow
    Cadre  : Boolean;   // Frame On/Off - not used /TZ/
    sCurve : Boolean;   // RoundRect On/Off
    wCurve : Integer;   // Curve size
  end;

  THackControl = class(TControl)
  end;

  TSeriesClass = class of TChartSeries;

const
  gtMemo = 0;
  gtPicture = 1;
  gtBand = 2;
  gtSubReport = 3;
  gtLine = 4;
  gtCross = 5;
  gtAddIn = 10;

  frftNone = 0;
  frftRight = 1;
  frftBottom = 2;
  frftLeft = 4;
  frftTop = 8;

  frtaLeft = 0;
  frtaRight = 1;
  frtaCenter = 2;
  frtaVertical = 4;
  frtaMiddle = 8;
  frtaDown = 16;

  flStretched = 1;
  flWordWrap = 2;
  flWordBreak = 4;
  flAutoSize = 8;
  flTextOnly = $10;
  flSuppressRepeated = $20;
  flHideZeros = $40;
  flUnderlines = $80;
  flRTLReading = $100;
  flBandNewPageAfter = 2;
  flBandPrintifSubsetEmpty = 4;
  flBandBreaked = 8;
  flBandOnFirstPage = $10;
  flBandOnLastPage = $20;
  flBandRepeatHeader = $40;
  flBandPrintChildIfInvisible = $80;
  flPictCenter = 2;
  flPictRatio = 4;
  flWantHook = $8000;
  flDontUndo = $4000;
  flOnePerPage = $2000;

  pkNone = 0;
  pkBitmap = 1;
  pkMetafile = 2;
  pkIcon = 3;
  pkJPEG = 4;

var
  frVersion: Byte;
  Report: TfrxReport;
  Stream: TStream;
  Page: TfrxPage;
  Fixups: TList;
  offsx, offsy: Integer;
  frxFR2EventsNew: TfrxFR2EventsNew;

const
  frSpecCount = 9;
  frSpecFuncs: array[0..frSpecCount - 1] of String =
    ('PAGE#', '', 'DATE', 'TIME', 'LINE#', 'LINETHROUGH#', 'COLUMN#',
     'CURRENT#', 'TOTALPAGES');
  Bands: array[TfrBandType] of TfrxBandClass =
    (TfrxReportTitle, TfrxReportSummary,
     TfrxPageHeader, TfrxPageFooter,
     TfrxHeader, TfrxMasterData, TfrxFooter,
     TfrxHeader, TfrxDetailData, TfrxFooter,
     TfrxHeader, TfrxSubDetailData, TfrxFooter,
     TfrxOverlay, TfrxColumnHeader, TfrxColumnFooter,
     TfrxGroupHeader, TfrxGroupFooter,
     TfrxHeader, TfrxMasterData, TfrxFooter,
     TfrxChild, nil);
  cbDefaultText = '12345678';
  ChartTypes: array[0..5] of TSeriesClass =
    (TLineSeries, TAreaSeries, TPointSeries,
     TBarSeries, THorizBarSeries, TPieSeries);
  frRepInfoCount = 9;
  frRepInfo: array[0..frRepInfoCount-1] of String =
     ('REPORTCOMMENT', 'REPORTNAME', 'REPORTAUTOR',
     'VMAJOR', 'VMINOR', 'VRELEASE', 'VBUILD', 'REPORTDATE', 'REPORTLASTCHANGE');
  ParamTypes: array[0..10] of TFieldType =
    (ftBCD, ftBoolean, ftCurrency, ftDate, ftDateTime, ftInteger,
     ftFloat, ftSmallint, ftString, ftTime, ftWord);


procedure frGetDataSetAndField(ComplexName: String; var DataSet: TDataSet;
  var Field: String); forward;
function frGetFieldValue(F: TField): Variant; forward;
procedure LoadFromFR2Stream(AReport: TfrxReport; AStream: TStream); forward;
function ConvertDatasetAndField(s: String): String; forward;

{ ------------------ hack FR events --------------------------------------- }
{ TfrxFR2EventsNew }

procedure TfrxFR2EventsNew.DoGetValue(const Expr: String; var Value: Variant);
var
  Dataset: TDataset;
  s, Field: String;
  tf: TField;
  ds: TfrxDataSet;
  fld: String;
begin
  Dataset := nil;
  Field := '';

  if CompareText(Expr, 'COLUMN#') = 0 then
    Value := Report.Engine.CurLine
  else
  begin
    s := Expr;
    if Pos('DialogForm.', s) = 1 then
    begin
      Delete(s, 1, Length('DialogForm.'));
      Report.GetDataSetAndField(s, ds, fld);
      if (ds <> nil) and (fld <> '') then
      begin
        Value := ds.Value[fld];
        if Report.EngineOptions.ConvertNulls and (Value = Null) then
          case ds.FieldType[fld] of
            fftNumeric:
              Value := 0;
            fftString:
              Value := '';
            fftBoolean:
              Value := False;
          end;
        Exit;
      end;
    end;

    frGetDataSetAndField(s, Dataset, Field);
    if (Dataset <> nil) and (Field <> '') then
    begin
      tf := Dataset.FieldByName(Field);
      Value := frGetFieldValue(tf);
    end;
  end;
end;

procedure TfrxFR2EventsNew.DoPrepareScript(Sender: TObject);
var
  i: Integer;
begin
  FReport := TfrxReport(Sender);
  Report := FReport;
  for i := 0 to FReport.Variables.Count - 1 do
    if IsValidIdent(FReport.Variables.Items[i].Name) then
      FReport.Script.AddMethod('function ' + FReport.Variables.Items[i].Name + ': Variant', GetScriptValue);
end;

function TfrxFR2EventsNew.GetScriptValue(Instance: TObject;
  ClassType: TClass; const MethodName: String;
  var Params: Variant): Variant;
var
  i: Integer;
  val: Variant;
begin
  i := FReport.Variables.IndexOf(MethodName);
  if i <> -1 then
  begin
    val := FReport.Variables.Items[i].Value;
    if (TVarData(val).VType = varString) or (TVarData(val).VType = varOleStr) then
    begin
      if Pos(#13#10, val) <> 0 then
        Result := val
      else
        Result := FReport.Calc(val);
    end
    else
      Result := val;
  end;
end;

function TfrxFR2EventsNew.DoLoad(Sender: TfrxReport; Stream: TStream): Boolean;
begin
  Result := False;
  Stream.Read(frVersion, 1);
  Stream.Seek(-1, soFromCurrent);
  if frVersion < 30 then
  begin
    LoadFromFR2Stream(Sender, Stream);
    Result := True;
  end;
end;

function TfrxFR2EventsNew.DoGetScriptValue(var Params: Variant): Variant;
begin
  Result := FReport.Calc('`' + Params[0] + '`', FReport.Script.ProgRunning);
end;


{ ------------------ fixups ----------------------------------------------- }
procedure ClearFixups;
begin
  while Fixups.Count > 0 do
  begin
    TfrxFixupItem(Fixups[0]).Free;
    Fixups.Delete(0);
  end;
end;

procedure FixupReferences;
var
  i: Integer;
  Item: TfrxFixupItem;
  Ref: TObject;
begin
  for i := 0 to Fixups.Count - 1 do
  begin
    Item := Fixups[i];
    Ref := Report.FindObject(Item.Value);
    if Ref <> nil then
      SetOrdProp(Item.Obj, Item.PropInfo, Integer(Ref));
  end;

  ClearFixups;
end;

procedure AddFixup(Obj: TPersistent; Name, Value: String);
var
  Item: TfrxFixupItem;
begin
  Item := TfrxFixupItem.Create;
  Item.Obj := Obj;
  Item.PropInfo := GetPropInfo(Obj.ClassInfo, Name);
  Item.Value := Value;
  Fixups.Add(Item);
end;

{ ------------------ stream readers -------------------------------------- }
function frSetFontStyle(Style: Integer): TFontStyles;
begin
  Result := [];
  if (Style and $1) <> 0 then Result := Result + [fsItalic];
  if (Style and $2) <> 0 then Result := Result + [fsBold];
  if (Style and $4) <> 0 then Result := Result + [fsUnderLine];
  if (Style and $8) <> 0 then Result := Result + [fsStrikeOut];
end;

procedure frReadMemo(Stream: TStream; l: TStrings);
var
  s: String;
  b: Byte;
  n: Word;
begin
  l.Clear;
  Stream.Read(n, 2);
  if n > 0 then
    repeat
      Stream.Read(n, 2);
      SetLength(s, n);
      if n > 0 then
        Stream.Read(s[1], n);
      l.Add(s);
      Stream.Read(b, 1);
    until b = 0
  else
    Stream.Read(b, 1);
end;

function frReadString(Stream: TStream): String;
var
  s: String;
  n: Word;
  b: Byte;
begin
  Stream.Read(n, 2);
  SetLength(s, n);
  if n > 0 then
    Stream.Read(s[1], n);
  Stream.Read(b, 1);
  Result := s;
end;

procedure frReadMemo22(Stream: TStream; l: TStrings);
var
  s: String;
  i: Integer;
  b: Byte;
begin
  SetLength(s, 4096);
  l.Clear;
  i := 1;
  repeat
    Stream.Read(b,1);
    if (b = 13) or (b = 0) then
    begin
      SetLength(s, i - 1);
      if not ((b = 0) and (i = 1)) then l.Add(s);
      SetLength(s, 4096);
      i := 1;
    end
    else if b <> 0 then
    begin
      s[i] := Chr(b);
      Inc(i);
      if i > 4096 then
        SetLength(s, Length(s) + 4096);
    end;
  until b = 0;
end;

function frReadString22(Stream: TStream): String;
var
  s: String;
  i: Integer;
  b: Byte;
begin
  SetLength(s, 4096);
  i := 1;
  repeat
    Stream.Read(b, 1);
    if b = 0 then
      SetLength(s, i - 1)
    else
    begin
      s[i] := Chr(b);
      Inc(i);
      if i > 4096 then
        SetLength(s, Length(s) + 4096);
    end;
  until b = 0;
  Result := s;
end;

function frReadBoolean(Stream: TStream): Boolean;
begin
  Stream.Read(Result, 1);
end;

function frReadByte(Stream: TStream): Byte;
begin
  Stream.Read(Result, 1);
end;

function frReadWord(Stream: TStream): Word;
begin
  Stream.Read(Result, 2);
end;

function frReadInteger(Stream: TStream): Integer;
begin
  Stream.Read(Result, 4);
end;

procedure frReadFont(Stream: TStream; Font: TFont);
var
  w: Word;
begin
  Font.Name := frReadString(Stream);
  Font.Size := frReadInteger(Stream);
  Font.Style := frSetFontStyle(frReadWord(Stream));
  Font.Color := frReadInteger(Stream);
  w := frReadWord(Stream);
  Font.Charset := w;
end;

function ReadString(Stream: TStream): String;
begin
  if frVersion >= 23 then
    Result := frReadString(Stream) else
    Result := frReadString22(Stream);
end;

procedure ReadMemo(Stream: TStream; Memo: TStrings);
begin
  if frVersion >= 23 then
    frReadMemo(Stream, Memo) else
    frReadMemo22(Stream, Memo);
end;

{ --------------------------- utils -------------------------------- }
function frFindComponent(Owner: TComponent; Name: String): TComponent;
var
  n: Integer;
  s1, s2: String;
begin
  Result := nil;
  n := Pos('.', Name);
  try
    if n = 0 then
      Result := Owner.FindComponent(Name)
    else
    begin
      s1 := Copy(Name, 1, n - 1);        // module name
      s2 := Copy(Name, n + 1, 255);      // component name
      Owner := FindGlobalComponent(s1);
      if Owner <> nil then
      begin
        n := Pos('.', s2);
        if n <> 0 then        // frame name - Delphi5
        begin
          s1 := Copy(s2, 1, n - 1);
          s2 := Copy(s2, n + 1, 255);
          Owner := Owner.FindComponent(s1);
          if Owner <> nil then
            Result := Owner.FindComponent(s2);
        end
        else
          Result := Owner.FindComponent(s2);
      end;
    end;
  except
    on Exception do
      raise EClassNotFound.Create('Missing ' + Name);
  end;
end;

function frRemoveQuotes(const s: String): String;
begin
  if (Length(s) > 2) and (s[1] = '"') and (s[Length(s)] = '"') then
    Result := Copy(s, 2, Length(s) - 2) else
    Result := s;
end;

function frRemoveQuotes1(const s: String): String;
begin
  if (Length(s) > 2) and (s[1] = '''') and (s[Length(s)] = '''') then
    Result := Copy(s, 2, Length(s) - 2) else
    Result := s;
end;

procedure frGetFieldNames(DataSet: TDataSet; List: TStrings);
begin
  try
    DataSet.GetFieldNames(List);
  except;
  end;
end;

procedure frGetDataSetAndField(ComplexName: String; var DataSet: TDataSet;
  var Field: String);
var
  i, j, n: Integer;
  f: TComponent;
  sl: TStringList;
  s: String;
  c: Char;
  cn: TControl;

  function FindField(ds: TDataSet; FName: String): String;
  var
    sl: TStringList;
  begin
    Result := '';
    if ds <> nil then
    begin
      sl := TStringList.Create;
      frGetFieldNames(ds, sl);
      if sl.IndexOf(FName) <> -1 then
        Result := FName;
      sl.Free;
    end;
  end;

begin
  Field := '';
  f := Report.Owner;
  sl := TStringList.Create;

  n := 0; j := 1;
  for i := 1 to Length(ComplexName) do
  begin
    c := ComplexName[i];
    if c = '"' then
    begin
      sl.Add(Copy(ComplexName, i, 255));
      j := i;
      break;
    end
    else if c = '.' then
    begin
      sl.Add(Copy(ComplexName, j, i - j));
      j := i + 1;
      Inc(n);
    end;
  end;
  if j <> i then
    sl.Add(Copy(ComplexName, j, 255));

  case n of
    0: // field name only
      begin
        if DataSet <> nil then
        begin
          s := frRemoveQuotes(ComplexName);
          Field := FindField(DataSet, s);
        end;
      end;
    1: // DatasetName.FieldName
      begin
        if sl.Count > 1 then
        begin
          DataSet := TDataSet(frFindComponent(f, sl[0]));
          s := frRemoveQuotes(sl[1]);
          Field := FindField(DataSet, s);
        end;
      end;
    2: // FormName.DatasetName.FieldName
      begin
        f := FindGlobalComponent(sl[0]);
        if f <> nil then
        begin
          DataSet := TDataSet(f.FindComponent(sl[1]));
          s := frRemoveQuotes(sl[2]);
          Field := FindField(DataSet, s);
        end;
      end;
    3: // FormName.FrameName.DatasetName.FieldName - Delphi5
      begin
        f := FindGlobalComponent(sl[0]);
        if f <> nil then
        begin
          cn := TControl(f.FindComponent(sl[1]));
          DataSet := TDataSet(cn.FindComponent(sl[2]));
          s := frRemoveQuotes(sl[3]);
          Field := FindField(DataSet, s);
        end;
      end;
  end;

  sl.Free;
end;

function frGetFieldValue(F: TField): Variant;
begin
  if not F.DataSet.Active then
    F.DataSet.Open;
  if Assigned(F.OnGetText) then
    Result := F.DisplayText
  else if F.DataType in [ftLargeint] then
    Result := F.DisplayText
  else
    Result := F.AsVariant;

  if Result = Null then
    if F.DataType = ftString then
      Result := ''
    else if F.DataType = ftWideString then
      Result := ''
    else if F.DataType = ftBoolean then
      Result := False
    else
      Result := 0;
end;

function FindTfrxDataset(ds: TDataset): TfrxDataset;
var
  i: Integer;
  sl: TStringList;
  ds1: TfrxDataset;
begin
  Result := nil;
  sl := TStringList.Create;
  frxGetDatasetList(sl);
  for i := 0 to sl.Count - 1 do
  begin
    ds1 := TfrxDataset(sl.Objects[i]);
    if (ds1 is TfrxDBDataset) and (TfrxDBDataset(ds1).GetDataSet = ds) then
    begin
      Result := ds1;
      break;
    end;
  end;
  sl.Free;
end;

function GetBrackedVariable(const s: String; var i, j: Integer): String;
var
  c: Integer;
  fl1, fl2: Boolean;
begin
  j := i; fl1 := True; fl2 := True; c := 0;
  Result := '';
  if (s = '') or (j > Length(s)) then Exit;
  Dec(j);
  repeat
    Inc(j);
    if fl1 and fl2 then
      if s[j] = '[' then
      begin
        if c = 0 then i := j;
        Inc(c);
      end
      else if s[j] = ']' then Dec(c);
    if fl1 then
      if s[j] = '"' then fl2 := not fl2;
    if fl2 then
      if s[j] = '''' then fl1 := not fl1;
  until (c = 0) or (j >= Length(s));
  Result := Copy(s, i + 1, j - i - 1);
end;

function Substitute(const ParName: String): String;
begin
  Result := ParName;
  if CompareText(ParName, frRepInfo[0]) = 0 then
    Result := 'Report.ReportOptions.Description'
  else if CompareText(ParName, frRepInfo[1]) = 0 then
    Result := 'Report.ReportOptions.Name'
  else if CompareText(ParName, frRepInfo[2]) = 0 then
    Result := 'Report.ReportOptions.Author'
  else if CompareText(ParName, frRepInfo[3]) = 0 then
    Result := 'Report.ReportOptions.VersionMajor'
  else if CompareText(ParName, frRepInfo[4]) = 0 then
    Result := 'Report.ReportOptions.VersionMinor'
  else if CompareText(ParName, frRepInfo[5]) = 0 then
    Result := 'Report.ReportOptions.VersionRelease'
  else if CompareText(ParName, frRepInfo[6]) = 0 then
    Result := 'Report.ReportOptions.VersionBuild'
  else if CompareText(ParName, frRepInfo[7]) = 0 then
    Result := 'Report.ReportOptions.CreateDate'
  else if CompareText(ParName, frRepInfo[8]) = 0 then
    Result := 'Report.ReportOptions.LastChange'

  else if CompareText(ParName, 'CURY') = 0 then
    Result := 'Engine.CurY'
  else if CompareText(ParName, 'FREESPACE') = 0 then
    Result := 'Engine.FreeSpace'
  else if CompareText(ParName, 'FINALPASS') = 0 then
    Result := 'Engine.FinalPass'
  else if CompareText(ParName, 'PAGEHEIGHT') = 0 then
    Result := 'Engine.PageHeight'
  else if CompareText(ParName, 'PAGEWIDTH') = 0 then
    Result := 'Engine.PageWidth'
end;

procedure DoExpression(const Expr: String; var Value: String);
begin
  Value := Substitute(Expr);
  if ConvertDatasetAndField(Expr) <> Expr then
    Value := ConvertDatasetAndField(Expr);
end;

procedure ExpandVariables(var s: String);
var
  i, j: Integer;
  s1, s2: String;
begin
  i := 1;
  repeat
    while (i < Length(s)) and (s[i] <> '[') do Inc(i);
    s1 := GetBrackedVariable(s, i, j);
    if i <> j then
    begin
      Delete(s, i, j - i + 1);
      s2 := s1;
      DoExpression(s1, s2);
      s2 := '[' + s2 + ']';
      Insert(s2, s, i);
      Inc(i, Length(s2));
      j := 0;
    end;
  until i = j;
end;

procedure ExpandVariables1(var s: String);
var
  i, j: Integer;
  s1, s2: String;
begin
  i := 1;
  repeat
    while (i < Length(s)) and (s[i] <> '[') do Inc(i);
    s1 := GetBrackedVariable(s, i, j);
    if i <> j then
    begin
      Delete(s, i, j - i + 1);
      s2 := s1;
      DoExpression(s1, s2);
      Insert(s2, s, i);
      Inc(i, Length(s2));
      j := 0;
    end;
  until i = j;
end;

procedure ConvertMemoExpressions(m: TfrxCustomMemoView; s: String);
begin
  ExpandVariables(s);
  m.Memo.Text := AnsiToUnicode(s, m.Font.Charset);
end;

{ --------------------------- report items -------------------------------- }
var
  Name: String;
  HVersion, LVersion: Byte;
  x, y, dx, dy: Integer;
  Flags: Word;
  FrameTyp: Word;
  FrameWidth: Single;
  FrameColor: TColor;
  FrameStyle: Word;
  FillColor: TColor;
  Format: Integer;
  FormatStr: String;
  Visible: WordBool;
  gapx, gapy: Integer;
  Restrictions: Word;
  Tag: String;
  Memo, Script: TStringList;
  BandAlign: Byte;
  NeedCreateName: Boolean;

procedure AddScript(c: TfrxComponent; const ScriptName: String);
var
  i: Integer;
  vName: String;
begin
  vName := c.Name;
  if Script.Count <> 0 then
  begin
    Report.ScriptText.Add('procedure ' + vName + scriptName);
    Report.ScriptText.Add('begin');
    Report.ScriptText.Add('  with ' + vName + ', Engine do');
    Report.ScriptText.Add('  begin');
    if Script[0] <> 'begin' then
      Report.ScriptText.Add(Script[0]);

    for i := 1 to Script.Count - 2 do
      Report.ScriptText.Add(Script[i]);

    if Script[0] <> 'begin' then
    begin
      if Script.Count <> 1 then
        Report.ScriptText.Add(Script[Script.Count - 1]);
      Report.ScriptText.Add('  end');
      Report.ScriptText.Add('end;');
    end
    else
    begin
      Report.ScriptText.Add('  end');
      Report.ScriptText.Add(Script[Script.Count - 1] + ';');
    end;
    Report.ScriptText.Add('');

    if c is TfrxDialogPage then
      TfrxDialogPage(c).OnShow := vName + 'OnShow'
    else if c is TfrxDialogControl then
      TfrxDialogControl(c).OnClick := vName + 'OnClick'
    else if c is TfrxReportComponent then
      TfrxReportComponent(c).OnBeforePrint := vName + 'OnBeforePrint';
  end;
end;

procedure SetfrxComponent(c: TfrxComponent);

  procedure SetValidIdent(var Ident: string);
  const
    Alpha = ['A'..'Z', 'a'..'z', '_'];
    AlphaNumeric = Alpha + ['0'..'9'];
  var
    I: Integer;
  begin
    if (Length(Ident) > 0) and not (Ident[1] in Alpha) then
      Ident[1] := '_';
    for I := 2 to Length(Ident) do
      if not (Ident[I] in AlphaNumeric) then
        Ident[I] := '_';
  end;

begin
  SetValidIdent(Name);
  c.Name := Name;
  if NeedCreateName then
    c.CreateUniqueName;

  c.Left := x + offsx;
  c.Top := y + offsy;
  c.Width := dx;
  c.Height := dy;
  c.Visible := Visible;
end;

procedure SetfrxView(c: TfrxView);
begin
  if (FrameTyp and frftRight) <> 0 then
    c.Frame.Typ := c.Frame.Typ + [ftRight];
  if (FrameTyp and frftBottom) <> 0 then
    c.Frame.Typ := c.Frame.Typ + [ftBottom];
  if (FrameTyp and frftLeft) <> 0 then
    c.Frame.Typ := c.Frame.Typ + [ftLeft];
  if (FrameTyp and frftTop) <> 0 then
    c.Frame.Typ := c.Frame.Typ + [ftTop];
  c.Frame.Width := FrameWidth;
  c.Frame.Color := FrameColor;
  c.Frame.Style := TfrxFrameStyle(FrameStyle);
  c.Color := FillColor;
  if BandAlign = 6 then
    BandAlign := 0;
  if BandAlign = 7 then
    BandAlign := 6;
  c.Align := TfrxAlign(BandAlign);
  c.TagStr := Tag;
  AddScript(c, 'OnBeforePrint(Sender: TfrxComponent);');
end;

procedure TfrViewLoadFromStream;
var
  w: Integer;
begin
  with Stream do
  begin
    NeedCreateName := False;
    if frVersion >= 23 then
      Name := ReadString(Stream) else
      NeedCreateName := True;
    if frVersion > 23 then
    begin
      Read(HVersion, 1);
      Read(LVersion, 1);
    end;
    Read(x, 4); Read(y, 4); Read(dx, 4); Read(dy, 4);
    Read(Flags, 2); Read(FrameTyp, 2); Read(FrameWidth, 4);
    Read(FrameColor, 4); Read(FrameStyle, 2);
    Read(FillColor, 4);
    Read(Format, 4);
    FormatStr := ReadString(Stream);
    ReadMemo(Stream, Memo);
    if frVersion >= 23 then
    begin
      ReadMemo(Stream, Script);
      Read(Visible, 2);
    end;
    if frVersion >= 24 then
    begin
      Read(Restrictions, 2);
      Tag := ReadString(Stream);
      Read(gapx, 4);
      Read(gapy, 4);
    end;
    w := PInteger(@FrameWidth)^;
    if w <= 10 then
      w := w * 1000;
    if HVersion > 1 then
      Read(BandAlign, 1);
    FrameWidth := w / 1000;
  end;
end;

procedure TfrMemoViewLoadFromStream;
var
  w: Word;
  i: Integer;
  Alignment: Integer;
  Highlight: TfrHighlightAttr;
  HighlightStr: String;
  LineSpacing, CharacterSpacing: Integer;
  m: TfrxMemoView;

  procedure DecodeDisplayFormat;
  var
    LCategory: Byte;
    LType: Byte;
    LNoOfDecimals: Byte;
    LSeparator: Char;
  begin
    LCategory := (Format and $0F000000) shr 24;
    LType := (Format and $00FF0000) shr 16;
    LNoOfDecimals := (Format and $0000FF00) shr 8;
    LSeparator := Chr(Format and $000000FF);

    case LCategory of
      0: { text }
        m.DisplayFormat.Kind := fkText;

      1: { number }
      begin
        m.DisplayFormat.Kind := fkNumeric;
        m.DisplayFormat.DecimalSeparator := LSeparator;
        case LType of
          0: m.DisplayFormat.FormatStr := '%2.' + IntToStr(LNoOfDecimals) + 'g';
          1: m.DisplayFormat.FormatStr := '%g';
          2: m.DisplayFormat.FormatStr := '%2.' + IntToStr(LNoOfDecimals) + 'f';
          3: m.DisplayFormat.FormatStr := '%2.' + IntToStr(LNoOfDecimals) + 'n';
          else
           m.DisplayFormat.FormatStr := '%g' { can't convert custom format string };
        end;
      end;

      2: { date }
      begin
        m.DisplayFormat.Kind := fkDateTime;
        case LType of
          0: m.DisplayFormat.FormatStr := 'dd.mm.yy';
          1: m.DisplayFormat.FormatStr := 'dd.mm.yyyy';
          2: m.DisplayFormat.FormatStr := 'd mmm yyyy';
          3: m.DisplayFormat.FormatStr := LongDateFormat;
          4: m.DisplayFormat.FormatStr := FormatStr;
        end;
      end;

      3: { time }
      begin
        m.DisplayFormat.Kind := fkDateTime;
        case LType of
          0: m.DisplayFormat.FormatStr := 'hh:nn:ss';
          1: m.DisplayFormat.FormatStr := 'h:nn:ss';
          2: m.DisplayFormat.FormatStr := 'hh:nn';
          3: m.DisplayFormat.FormatStr := 'h:nn';
          4: m.DisplayFormat.FormatStr := FormatStr;
        end;
      end;

      4: { boolean }
      begin
        m.DisplayFormat.Kind := fkBoolean;
        case LType of
          0: m.DisplayFormat.FormatStr := '0,1';
          1: m.DisplayFormat.FormatStr := 'Нет,Да';
          2: m.DisplayFormat.FormatStr := '_,X';
          3: m.DisplayFormat.FormatStr := 'False,True';
          4: m.DisplayFormat.FormatStr := FormatStr;
        end;
      end;
    end;
  end;

begin
  TfrViewLoadFromStream;
  m := TfrxMemoView.Create(Page);
  SetfrxComponent(m);
  SetfrxView(m);

  with Stream do
  begin
    { font info }
    m.Font.Name := ReadString(Stream);
    Read(i, 4);
    m.Font.Size := i;
    Read(w, 2);
    m.Font.Style := frSetFontStyle(w);
    Read(i, 4);
    m.Font.Color := i;

    { text align, rotation }
    Read(Alignment, 4);
    if (Alignment and frtaRight) <> 0 then
      m.HAlign := haRight;
    if (Alignment and frtaCenter) <> 0 then
      m.HAlign := haCenter;
    if (Alignment and 3) = 3 then
      m.HAlign := haBlock;
    if (Alignment and frtaVertical) <> 0 then
      m.Rotation := 90;
    if (Alignment and frtaMiddle) <> 0 then
      m.VAlign := vaCenter;
    if (Alignment and frtaDown) <> 0 then
      m.VAlign := vaBottom;

    { charset }
    Read(w, 2);
    if frVersion < 23 then
      w := DEFAULT_CHARSET;
    m.Font.Charset := w;

    Read(Highlight, 10);
    HighlightStr := ReadString(Stream);

    m.Highlight.Condition := HighlightStr;
    m.Highlight.Color := Highlight.FillColor;
    m.Highlight.Font.Color := Highlight.FontColor;
    m.Highlight.Font.Style := frSetFontStyle(Highlight.FontStyle);

    if frVersion >= 24 then
    begin
      Read(LineSpacing, 4);
      m.LineSpacing := LineSpacing;
      Read(CharacterSpacing, 4);
      m.CharSpacing := CharacterSpacing;
    end;
  end;

  if frVersion = 21 then
    Flags := Flags or flWordWrap;

  if (Flags and flStretched) <> 0 then
    m.StretchMode := smMaxHeight;
  m.WordWrap := (Flags and flWordWrap) <> 0;
  m.WordBreak := (Flags and flWordBreak) <> 0;
  m.AutoWidth := (Flags and flAutoSize) <> 0;
  m.AllowExpressions := (Flags and flTextOnly) = 0;
  m.SuppressRepeated := (Flags and flSuppressRepeated) <> 0;
  m.HideZeros := (Flags and flHideZeros) <> 0;
  m.Underlines := (Flags and flUnderlines) <> 0;
  m.RTLReading := (Flags and flRTLReading) <> 0;

  DecodeDisplayFormat;

  ConvertMemoExpressions(m, Memo.Text);
end;

procedure TfrPictureViewLoadFromStream;
var
  b, BlobType: Byte;
  n: Integer;
  Graphic: TGraphic;
  TempStream: TMemoryStream;
  p: TfrxPictureView;
begin
  TfrViewLoadFromStream;
  p := TfrxPictureView.Create(Page);
  SetfrxComponent(p);
  SetfrxView(p);

  Stream.Read(b, 1);
  if HVersion * 10 + LVersion > 10 then
    Stream.Read(BlobType, 1);
  Stream.Read(n, 4);
  Graphic := nil;
  case b of
    pkBitmap:   Graphic := TBitmap.Create;
    pkMetafile: Graphic := TMetafile.Create;
    pkIcon:     Graphic := TIcon.Create;
    pkJPEG:     Graphic := TJPEGImage.Create;
  end;
  p.Picture.Graphic := Graphic;
  if Graphic <> nil then
  begin
    Graphic.Free;
    TempStream := TMemoryStream.Create;
    TempStream.CopyFrom(Stream, n - Stream.Position);
    TempStream.Position := 0;
    p.Picture.Graphic.LoadFromStream(TempStream);
    TempStream.Free;
  end;
  Stream.Seek(n, soFromBeginning);

  p.Stretched := (Flags and flStretched) <> 0;
  p.Center := (Flags and flPictCenter) <> 0;
  p.KeepAspectRatio := (Flags and flPictRatio) <> 0;
  if Memo.Count > 0 then
    p.DataField := Memo[0];
end;

procedure TfrBandViewLoadFromStream;
var
  ChildBand, Master: String;
  Columns: Integer;
  ColumnWidth: Integer;
  ColumnGap: Integer;
  NewColumnAfter: Integer;
  BandType: TfrBandType;
  Band: TfrxBand;
begin
  TfrViewLoadFromStream;

  BandType := TfrBandType(FrameTyp);
  Band := TfrxBand(Bands[BandType].NewInstance);
  Band.Create(Page);
  if BandType in [btCrossHeader..btCrossFooter] then
    Band.Vertical := True;
  SetfrxComponent(Band);
  AddScript(Band, 'OnBeforePrint(Sender: TfrxComponent);');

  if frVersion > 23 then
  begin
    ChildBand := frReadString(Stream);
    if ChildBand <> '' then
      AddFixup(Band, 'Child', ChildBand);
    Stream.Read(Columns, 4);
    Stream.Read(ColumnWidth, 4);
    Stream.Read(ColumnGap, 4);
    { not implemented }
    Stream.Read(NewColumnAfter, 4);
    { not implemented }
    if HVersion * 10 + LVersion > 20 then
      Master := frReadString(Stream);
    if Band is TfrxDataBand then
    begin
      TfrxDataBand(Band).Columns := Columns;
      TfrxDataBand(Band).ColumnWidth := ColumnWidth;
      TfrxDataBand(Band).ColumnGap := ColumnGap;
      if (FormatStr <> '') and (FormatStr[1] in ['1'..'9']) then
        TfrxDataBand(Band).RowCount := StrToInt(FormatStr)
      else
        TfrxDataBand(Band).DatasetName := FormatStr;
    end;
  end;

  Band.Stretched := (Flags and flStretched) <> 0;
  Band.StartNewPage := (Flags and flBandNewPageAfter) <> 0;
  Band.PrintChildIfInvisible := (Flags and flBandPrintChildIfInvisible) <> 0;
  Band.AllowSplit := (Flags and flBandBreaked) <> 0;
  if Band is TfrxDataBand then
    TfrxDataBand(Band).PrintifDetailEmpty := (Flags and flBandPrintifSubsetEmpty) <> 0;
  if Band is TfrxPageHeader then
    TfrxPageHeader(Band).PrintOnFirstPage := (Flags and flBandOnFirstPage) <> 0;
  if Band is TfrxPageFooter then
  begin
    TfrxPageFooter(Band).PrintOnFirstPage := (Flags and flBandOnFirstPage) <> 0;
    TfrxPageFooter(Band).PrintOnLastPage := (Flags and flBandOnLastPage) <> 0;
  end;
  if Band is TfrxHeader then
    TfrxHeader(Band).ReprintOnNewPage := (Flags and flBandRepeatHeader) <> 0;
  if Band is TfrxGroupHeader then
  begin
    TfrxGroupHeader(Band).ReprintOnNewPage := (Flags and flBandRepeatHeader) <> 0;
    DoExpression(FormatStr, FormatStr);
    TfrxGroupHeader(Band).Condition := FormatStr;
  end;
end;

procedure TfrSubreportLoadFromStream;
var
  s: TfrxSubreport;
  SubPage: Integer;
begin
  TfrViewLoadFromStream;
  s := TfrxSubreport.Create(Page);
  SetfrxComponent(s);
  Stream.Read(SubPage, 4);
  s.Page := TfrxReportPage(Report.Pages[SubPage]);
  with s.Page do
  begin
    if Name = '' then
      CreateUniqueName;    
    LeftMargin := 0;
    RightMargin := 0;
    TopMargin := 0;
    BottomMargin := 0;
  end;
end;

procedure TfrLineViewLoadFromStream;
var
  Line: TfrxLineView;
begin
  TfrViewLoadFromStream;
  Line := TfrxLineView.Create(Page);
  SetfrxComponent(Line);
  SetfrxView(Line);
  if (Flags and flStretched) <> 0 then
    Line.StretchMode := smMaxHeight;
end;

procedure ReadStdCtrl(c: TfrxDialogControl);
begin
  TfrViewLoadFromStream;
  SetfrxComponent(c);
  THackControl(c.Control).Color := frReadInteger(Stream);
  c.Control.Enabled := frReadBoolean(Stream);
  frReadFont(Stream, c.Font);
  AddScript(c, 'OnClick(Sender: TfrxComponent);');
end;

procedure ReadTfrLabelControl;
var
  l: TfrxLabelControl;
begin
  l := TfrxLabelControl.Create(Page);
  ReadStdCtrl(l);
  l.Alignment := TAlignment(frReadByte(Stream));
  l.AutoSize := frReadBoolean(Stream);
  l.Caption := frReadString(Stream);
  l.WordWrap := frReadBoolean(Stream);
end;

procedure ReadTfrEditControl;
var
  e: TfrxEditControl;
begin
  e := TfrxEditControl.Create(Page);
  ReadStdCtrl(e);
  e.Text := frReadString(Stream);
  e.ReadOnly := frReadBoolean(Stream);
end;

procedure ReadTfrMemoControl;
var
  m: TfrxMemoControl;
begin
  m := TfrxMemoControl.Create(Page);
  ReadStdCtrl(m);
  m.Text := frReadString(Stream);
  m.ReadOnly := frReadBoolean(Stream);
end;

procedure ReadTfrButtonControl;
var
  b: TfrxButtonControl;
begin
  b := TfrxButtonControl.Create(Page);
  ReadStdCtrl(b);
  b.Caption := frReadString(Stream);
  b.ModalResult := frReadWord(Stream);
  b.Cancel := b.ModalResult = mrCancel;
  b.Default := b.ModalResult = mrOk;
end;

procedure ReadTfrCheckBoxControl;
var
  b: TfrxCheckBoxControl;
begin
  b := TfrxCheckBoxControl.Create(Page);
  ReadStdCtrl(b);
  b.Alignment := TAlignment(frReadByte(Stream));
  b.Checked := frReadBoolean(Stream);
  b.Caption := frReadString(Stream);
end;

procedure ReadTfrRadioButtonControl;
var
  b: TfrxRadioButtonControl;
begin
  b := TfrxRadioButtonControl.Create(Page);
  ReadStdCtrl(b);
  b.Alignment := TAlignment(frReadByte(Stream));
  b.Checked := frReadBoolean(Stream);
  b.Caption := frReadString(Stream);
end;

procedure ReadTfrListBoxControl;
var
  b: TfrxListBoxControl;
begin
  b := TfrxListBoxControl.Create(Page);
  ReadStdCtrl(b);
  frReadMemo(Stream, b.Items);
end;

procedure ReadTfrComboBoxControl;
var
  c: TfrxComboBoxControl;
  b: Byte;
begin
  c := TfrxComboBoxControl.Create(Page);
  ReadStdCtrl(c);
  frReadMemo(Stream, c.Items);
  if HVersion * 10 + LVersion > 10 then
  begin
    b := frReadByte(Stream);
    if (HVersion * 10 + LVersion <= 20) and (b > 0) then
      Inc(b);
    c.Style := TComboBoxStyle(b);
  end;
end;

procedure ReadTfrDateEditControl;
var
  b: TfrxDateEditControl;
begin
  b := TfrxDateEditControl.Create(Page);
  ReadStdCtrl(b);
  b.DateFormat := TDTDateFormat(frReadByte(Stream));
end;

procedure ReadTfrBarcodeView;
var
  v: TfrxBarcodeView;
  Param: TfrBarcodeRec;
begin
  v := TfrxBarcodeView.Create(Page);
  TfrViewLoadFromStream;
  SetfrxComponent(v);
  SetfrxView(v);

  Stream.Read(Param, SizeOf(Param));
  if Param.cModul = 1 then
  begin
    Param.cRatio := Param.cRatio / 2;
    Param.cModul := 2;
  end;

  if (Memo.Count > 0) and (Memo[0][1] <> '[') then
    v.Text := Memo[0] else
    v.Expression := Memo[0];

  v.Rotation := Round(Param.cAngle);
  v.CalcChecksum := Param.cCheckSum;
  v.BarType := Param.cBarType;
  v.Zoom := Param.cRatio;
  v.ShowText := Param.cShowText;
end;

procedure ReadTfrChartView;
var
  v: TfrxChartView;
  b: Byte;
  ChartOptions: TChartOptions;
  LegendObj, ValueObj, Top10Label: String;
  Ser: TChartSeries;
  dser: TfrxSeriesItem;
begin
  v := TfrxChartView.Create(Page);
  TfrViewLoadFromStream;
  SetfrxComponent(v);
  SetfrxView(v);

  Stream.Read(b, 1);
  if b <> 1 then
  with Stream do
  begin
    Read(ChartOptions, SizeOf(ChartOptions));
    LegendObj := frReadString(Stream);
    ValueObj := frReadString(Stream);
    Top10Label := frReadString(Stream);
  end;

  v.Chart.Frame.Visible := False;
  v.Chart.LeftWall.Brush.Style := bsClear;
  v.Chart.BottomWall.Brush.Style := bsClear;

  v.Chart.View3D := ChartOptions.Dim3D;
  v.Chart.Legend.Visible := ChartOptions.ShowLegend;
  v.Chart.AxisVisible := ChartOptions.ShowAxis;
  v.Chart.View3DWalls := ChartOptions.ChartType <> 5;
  v.Chart.BackWall.Brush.Style := bsClear;
  v.Chart.View3DOptions.Elevation := 315;
  v.Chart.View3DOptions.Rotation := 360;
  v.Chart.View3DOptions.Orthogonal := ChartOptions.ChartType <> 5;

  Ser := ChartTypes[ChartOptions.ChartType].Create(v.Chart);
  v.Chart.AddSeries(Ser);
  if ChartOptions.Colored then
    Ser.ColorEachPoint := True;
  Ser.Marks.Visible := ChartOptions.ShowMarks;
  Ser.Marks.Style := TSeriesMarksStyle(ChartOptions.MarksStyle);

  dser := v.SeriesData.Add;
  dser.DataType := dtBandData;
  dser.XSource := LegendObj;
  dser.YSource := ValueObj;
  dser.TopN := ChartOptions.Top10Num;
  dser.TopNCaption := Top10Label;
end;

procedure ReadTfrCheckBoxView;
var
  v: TfrxCheckBoxView;
  CheckStyle: Byte;
  CheckColor: TColor;
begin
  v := TfrxCheckBoxView.Create(Page);
  TfrViewLoadFromStream;
  SetfrxComponent(v);
  SetfrxView(v);

  if frVersion > 23 then
  begin
    Stream.Read(CheckStyle, 1);
    v.CheckStyle := TfrxCheckStyle(CheckStyle);
    Stream.Read(CheckColor, 4);
    v.CheckColor := CheckColor;
  end;
  if Memo.Count > 0 then
    v.Expression := Memo[0];
end;

procedure ReadTfrOLEView;
var
  v: TfrxOLEView;
  b: Byte;
begin
  v := TfrxOLEView.Create(Page);
  TfrViewLoadFromStream;
  SetfrxComponent(v);
  SetfrxView(v);

  Stream.Read(b, 1);
  if b <> 0 then
    v.OleContainer.LoadFromStream(Stream);
  if Memo.Count > 0 then
    v.DataField := Memo[0];
end;

procedure ReadTfrRichView;
var
  v: TfrxRichView;
  b: Byte;
  n: Integer;
begin
  v := TfrxRichView.Create(Page);
  TfrViewLoadFromStream;
  SetfrxComponent(v);
  SetfrxView(v);

  if (Flags and flStretched) <> 0 then
    v.StretchMode := smMaxHeight;
  Stream.Read(b, 1);
  Stream.Read(n, 4);
  if b <> 0 then
    v.RichEdit.Lines.LoadFromStream(Stream);
  Stream.Seek(n, soFromBeginning);
  if Memo.Count > 0 then
    v.DataField := Memo[0];
end;

procedure ReadTfrShapeView;
var
  v: TfrxShapeView;
  ShapeType: Byte;
begin
  v := TfrxShapeView.Create(Page);
  TfrViewLoadFromStream;
  SetfrxComponent(v);
  SetfrxView(v);

  Stream.Read(ShapeType, 1);
  v.Shape := TfrxShapeKind(ShapeType);
end;

procedure ReadTfrRoundRectView;
var
  v: TfrxShapeView;
  Cadre: TfrRoundRect;
begin
  v := TfrxShapeView.Create(Page);
  v.Shape := skRoundRectangle;
  TfrViewLoadFromStream;
  SetfrxComponent(v);
  SetfrxView(v);

  Stream.Read(Cadre, SizeOf(Cadre));
end;

procedure ReadTfrCrossView;
var
  v: TfrxDBCrossView;
  sl: TStringList;
  s: String;
  i: Integer;

  function PureName1(const s: String): String;
  begin
    if Pos('+', s) <> 0 then
      Result := Copy(s, 1, Pos('+', s) - 1) else
      Result := s;
  end;

  function HasTotal(s: String): Boolean;
  begin
    Result := Pos('+', s) <> 0;
  end;

  function FuncName(s: String): String;
  begin
    if HasTotal(s) then
    begin
      Result := LowerCase(Copy(s, Pos('+', s) + 1, 255));
      if Result = '' then
        Result := 'sum';
    end
    else
      Result := '';
  end;

begin
  v := TfrxDBCrossView.Create(Page);
  TfrViewLoadFromStream;
  SetfrxComponent(v);
  SetfrxView(v);

  v.Border := frReadBoolean(Stream);
  v.RepeatHeaders := frReadBoolean(Stream);
  v.GapY := 1;
  v.Visible := True;
  { show header, not used }
  frReadBoolean(Stream);
  if LVersion > 0 then
  begin
    v.ShowColumnTotal := frReadBoolean(Stream);
    v.ShowRowTotal := v.ShowColumnTotal;
    v.MaxWidth      := frReadInteger(Stream);
    {FHeaderWidth    := }frReadInteger(Stream);
  end;
  if LVersion > 1 then
  begin
    {FDictionary.Text := }frReadString(Stream);
    {FMaxNameLen  := }frReadInteger(Stream);
  end;
  if LVersion > 2 then
    {FDataCaption := }frReadString(Stream);

  sl := TStringList.Create;

  if Memo.Count >= 4 then
  begin
    v.DataSetName := Memo[0];

    frxSetCommaText(Memo[1], sl);
    v.RowLevels := sl.Count;
    v.RowFields.Clear;
    for i := 0 to sl.Count - 1 do
    begin
      s := PureName1(sl[i]); {row field name }
      v.RowFields.Add(s);
      v.RowTotalMemos[i + 1].Visible := s <> sl[i];
    end;

    frxSetCommaText(Memo[2], sl);
    v.ColumnLevels := sl.Count;
    v.ColumnFields.Clear;
    for i := 0 to sl.Count - 1 do
    begin
      s := PureName1(sl[i]); {column field name }
      v.ColumnFields.Add(s);
      v.ColumnTotalMemos[i + 1].Visible := s <> sl[i];
    end;

    frxSetCommaText(Memo[3], sl);
    v.CellLevels := sl.Count;
    v.CellFields.Clear;
    for i := 0 to sl.Count - 1 do
    begin
      s := PureName1(sl[i]); {column field name }
      v.CellFields.Add(s);
      s := FuncName(sl[i]);
      if s = 'sum' then
        v.CellFunctions[i] := cfSum
      else if s = 'avg' then
        v.CellFunctions[i] := cfAvg
      else if s = 'min' then
        v.CellFunctions[i] := cfMin
      else if s = 'max' then
        v.CellFunctions[i] := cfMax
      else if s = 'count' then
        v.CellFunctions[i] := cfCount
    end;
  end;

  sl.Free;
end;


{------------------------- datacontrols --------------------------------------}
procedure ReadTfrBDEDatabase;
var
  v: TfrxBDEDatabase;
  s: String;
begin
  v := TfrxBDEDatabase.Create(Page);
  TfrViewLoadFromStream;
  SetfrxComponent(v);

  v.DatabaseName := frReadString(Stream);
  s := frReadString(Stream);
  if s <> '' then
    v.AliasName := s;
  s := frReadString(Stream);
  if s <> '' then
    v.DriverName := s;
  v.LoginPrompt := frReadBoolean(Stream);
  frReadMemo(Stream, v.Params);
  v.Connected := frReadBoolean(Stream);
end;

{ field list is not stored in FR3, just skip }
procedure TfrXXXDataSetReadFields;
var
  i: Integer;
  n: Word;
  fLookup: Boolean;
  b: Byte;
begin
  Stream.Read(n, 2);             // FieldCount
  for i := 0 to n - 1 do
  begin

// Old version of BDEComponents stores fieldlist wrongfully
    if HVersion * 10 + LVersion <= 10 then
    begin
      b := frReadByte(Stream);   // islookup
      frReadString(Stream);      // fieldname
      if b = 1 then
      begin
        frReadByte(Stream);      // datatype
        frReadWord(Stream);      // size
        frReadString(Stream);    // KeyFields
        frReadString(Stream);    // LookupDataset
        frReadString(Stream);    // LookupKeyFields
        frReadString(Stream);    // LookupResultField
      end;
      continue;
    end;

    frReadByte(Stream);                  // DataType
    frReadString(Stream);                              // FieldName
    fLookup := frReadBoolean(Stream);                           // Lookup
    frReadWord(Stream);                                // Size

    if fLookup then
    begin
      frReadString(Stream);                      // KeyFields
      frReadString(Stream);                              // LookupDataset
      frReadString(Stream);                // LookupKeyFields
      frReadString(Stream);              // LookupResultField
    end;
  end;
end;

procedure ReadTfrBDETable;
var
  v: TfrxBDETable;
begin
  v := TfrxBDETable.Create(Page);
  TfrViewLoadFromStream;
  SetfrxComponent(v);
  v.SetBounds(-1000, -1000, 0, 0);

  v.DatabaseName := frReadString(Stream);
  v.Filter := frReadString(Stream);
  v.Filtered := Trim(v.Filter) <> '';
  v.IndexName := frReadString(Stream);
  v.MasterFields := frReadString(Stream);
  AddFixup(v, 'Master', frReadString(Stream));
  v.TableName := frReadString(Stream);
  frReadBoolean(Stream); // active
  TfrXXXDataSetReadFields;
  Report.Datasets.Add(v);
end;

procedure TfrXXXQueryReadParams(Query: TfrxCustomQuery);
var
  i: Integer;
  w, n: Word;
begin
  Stream.Read(n, 2);
  for i := 0 to n - 1 do
  with Query.Params[i] do
  begin
    Stream.Read(w, 2);
    DataType := ParamTypes[w];
    Stream.Read(w, 2);
    Expression := frReadString(Stream);
  end;
end;

procedure ReadTfrBDEQuery;
var
  v: TfrxBDEQuery;
begin
  v := TfrxBDEQuery.Create(Page);
  TfrViewLoadFromStream;
  SetfrxComponent(v);
  v.SetBounds(-1000, -1000, 0, 0);

  v.DatabaseName := frReadString(Stream);
  v.Filter := frReadString(Stream);
  v.Filtered := Trim(v.Filter) <> '';
  AddFixup(v, 'Master', frReadString(Stream));
  frReadMemo(Stream, v.SQL);

  frReadBoolean(Stream);
  TfrXXXDataSetReadFields;
  TfrXXXQueryReadParams(v);
  v.IsLoading := True;
  v.UpdateParams;
  v.IsLoading := False;
end;

procedure ReadTfrADODatabase;
var
  v: TfrxADODatabase;
begin
  v := TfrxADODatabase.Create(Page);
  TfrViewLoadFromStream;
  SetfrxComponent(v);

  v.DatabaseName := frReadString(Stream);
  v.LoginPrompt := frReadBoolean(Stream);
  v.Connected := frReadBoolean(Stream);
end;

procedure ReadTfrADOTable;
var
  v: TfrxADOTable;
begin
  v := TfrxADOTable.Create(Page);
  TfrViewLoadFromStream;
  SetfrxComponent(v);
  v.SetBounds(-1000, -1000, 0, 0);

  AddFixup(v, 'Database', frReadString(Stream));
  v.Filter := frReadString(Stream);
  v.Filtered := Trim(v.Filter) <> '';
  v.IndexName := frReadString(Stream);
  v.MasterFields := frReadString(Stream);
  AddFixup(v, 'Master', frReadString(Stream));
  v.TableName := frReadString(Stream);
  frReadBoolean(Stream); // active
  if LVersion >= 2 then
    frReadBoolean(Stream);  // enableBCD
  TfrXXXDataSetReadFields;
  Report.Datasets.Add(v);
end;

procedure ReadTfrADOQuery;
var
  v: TfrxADOQuery;
begin
  v := TfrxADOQuery.Create(Page);
  TfrViewLoadFromStream;
  SetfrxComponent(v);
  v.SetBounds(-1000, -1000, 0, 0);

  AddFixup(v, 'Database', frReadString(Stream));
  v.Filter := frReadString(Stream);
  v.Filtered := Trim(v.Filter) <> '';
  AddFixup(v, 'Master', frReadString(Stream));
  frReadMemo(Stream, v.SQL);

  frReadBoolean(Stream);  // active
  if LVersion >= 2 then
    frReadBoolean(Stream);  // enableBCD

  TfrXXXDataSetReadFields;
  TfrXXXQueryReadParams(v);
  v.IsLoading := True;
  v.UpdateParams;
  v.IsLoading := False;
end;

procedure ReadTfrIBXDatabase;
var
  v: TfrxIBXDatabase;
begin
  v := TfrxIBXDatabase.Create(Page);
  TfrViewLoadFromStream;
  SetfrxComponent(v);

  v.DatabaseName := frReadString(Stream);
  v.LoginPrompt := frReadBoolean(Stream);
  if HVersion * 10 + LVersion > 20 then
    v.SQLDialect := frReadInteger(Stream);
  frReadMemo(Stream, v.Params);
  v.Connected := frReadBoolean(Stream);
end;

procedure ReadTfrIBXTable;
var
  v: TfrxIBXTable;
begin
  v := TfrxIBXTable.Create(Page);
  TfrViewLoadFromStream;
  SetfrxComponent(v);
  v.SetBounds(-1000, -1000, 0, 0);

  AddFixup(v, 'Database', frReadString(Stream));
  v.TableName := frReadString(Stream);
  v.Filter := frReadString(Stream);
  v.Filtered := Trim(v.Filter) <> '';
  v.IndexName := frReadString(Stream);
  v.IndexFieldNames := frReadString(Stream);
  v.MasterFields := frReadString(Stream);
  AddFixup(v, 'Master', frReadString(Stream));
  frReadBoolean(Stream); // active
  TfrXXXDataSetReadFields;
  Report.Datasets.Add(v);
end;

procedure ReadTfrIBXQuery;
var
  v: TfrxIBXQuery;
begin
  v := TfrxIBXQuery.Create(Page);
  TfrViewLoadFromStream;
  SetfrxComponent(v);
  v.SetBounds(-1000, -1000, 0, 0);

  AddFixup(v, 'Database', frReadString(Stream));
  v.Filter := frReadString(Stream);
  v.Filtered := Trim(v.Filter) <> '';
  AddFixup(v, 'Master', frReadString(Stream));
  frReadMemo(Stream, v.SQL);
  frReadBoolean(Stream);  // active

  TfrXXXDataSetReadFields;
  TfrXXXQueryReadParams(v);
  v.IsLoading := True;
  v.UpdateParams;
  v.IsLoading := False;
end;



{----------------------------------------------------------------------------}
procedure TfrDictionaryLoadFromStream;
var
  w: Word;
  NewVersion: Boolean;
  Variables, FieldAliases, BandDatasources: TfrxVariables;
  SMemo: TStringList;

  procedure LoadFRVariables(Value: TfrxVariables);
  var
    i, n: Integer;
    s: String;
  begin
    Stream.Read(n, 4);
    for i := 0 to n - 1 do
    begin
      s := frReadString(Stream);
      Value[s] := frReadString(Stream);
    end;
  end;

  procedure LoadOldVariables;
  var
    i, n, d: Integer;
    b: Byte;
    s, s1, s2: String;

    function ReadStr: String;
    var
      n: Byte;
    begin
      Stream.Read(n, 1);
      SetLength(Result, n);
      Stream.Read(Result[1], n);
    end;

  begin
    with Stream do
    begin
      ReadBuffer(n, SizeOf(n));
      for i := 0 to n - 1 do
      begin
        Read(b, 1); // typ
        Read(d, 4); // otherkind
        s1 := ReadStr; // dataset
        s2 := ReadStr; // field
        s := ReadStr;  // var name
        if b = 2 then      // it's system variable or expression
          if d = 1 then
            s1 := s2 else
            s1 := frSpecFuncs[d]
        else if b = 1 then // it's data field
          s1 := s1 + '."' + s2 + '"'
        else
          s1 := '';
        FieldAliases[' ' + s] := s1;
      end;
    end;

    ReadMemo(Stream, SMemo);
    for i := 0 to SMemo.Count - 1 do
    begin
      s := SMemo[i];
      if (s <> '') and (s[1] <> ' ') then
        Variables[s] := '' else
        Variables[s] := FieldAliases[s];
    end;
    FieldAliases.Clear;
  end;

  procedure ConvertToNewFormat;
  var
    i: Integer;
    s: String;
  begin
    for i := 0 to Variables.Count - 1 do
    begin
      s := Variables.Items[i].Name;
      if s <> '' then
        if s[1] = ' ' then
          s := Copy(s, 2, 255) else
          s := ' ' + s;
      Variables.Items[i].Name := s;
    end;
  end;

begin
  Variables := TfrxVariables.Create;
  FieldAliases := TfrxVariables.Create;
  BandDatasources := TfrxVariables.Create;
  SMemo := TStringList.Create;

  w := frReadWord(Stream);
  NewVersion := (w = $FFFF) or (w = $FFFE);
  if NewVersion then
  begin
    LoadFRVariables(Variables);
    LoadFRVariables(FieldAliases);
    LoadFRVariables(BandDatasources);
  end
  else
  begin
    Stream.Seek(-2, soFromCurrent);
    LoadOldVariables;
  end;
  if (Variables.Count > 0) and (Variables.Items[0].Name <> '') and (Variables.Items[0].Name[1] <> ' ') then
    ConvertToNewFormat;
{  if w = $FFFF then
    ConvertAliases;}

  Report.Variables.Assign(Variables);
  Variables.Free;
  FieldAliases.Free;
  BandDatasources.Free;
  SMemo.Free;
end;

procedure TfrPageLoadFromStream;
var
  i: Integer;
  b: Byte;
  s: String[6];

  pgSize, pgWidth, pgHeight: Integer;
  pgMargins: TRect;
  pgOr: TPrinterOrientation;
  pgBin: Integer;
  PrintToPrevPage, UseMargins: WordBool;
  ColCount, ColGap: Integer;
  PageType: TfrPageType;
  // dialog properties
  BorderStyle: Byte;
  Color: TColor;
  Left, Top, Width, Height: Integer;

  ReportPage: TfrxReportPage;
  DialogPage: TfrxDialogPage;
  ColWidth: Extended;
begin
  ReportPage := TfrxReportPage.Create(nil);
  DialogPage := TfrxDialogPage.Create(nil);
  PageType := ptReport;

  with Stream do
  begin
    { paper size }
    Read(i, 4);
    if i = -1 then
      Read(pgSize, 4) else
      pgSize := i;
    ReportPage.PaperSize := pgSize;

    { width }
    Read(pgWidth, 4);

    { height }
    Read(pgHeight, 4);

    { margins }
    Read(pgMargins, Sizeof(pgMargins));
    pgMargins.Left := pgMargins.Left * 5 div 18;
    pgMargins.Top := pgMargins.Top * 5 div 18;
    pgMargins.Right := pgMargins.Right * 5 div 18;
    pgMargins.Bottom := pgMargins.Bottom * 5 div 18;
    if (pgMargins.Left = 0) and (pgMargins.Top = 0) and
      (pgMargins.Right = 0) and (pgMargins.Bottom = 0) then
    begin
      pgMargins.Left := Round(frxPrinters.Printer.LeftMargin);
      pgMargins.Top := Round(frxPrinters.Printer.TopMargin);
      pgMargins.Right := Round(frxPrinters.Printer.RightMargin);
      pgMargins.Bottom := Round(frxPrinters.Printer.BottomMargin);
    end;
    ReportPage.LeftMargin := pgMargins.Left;
    ReportPage.TopMargin := pgMargins.Top;
    ReportPage.RightMargin := pgMargins.Right;
    ReportPage.BottomMargin := pgMargins.Bottom;

    { orientation }
    Read(b, 1);
    pgOr := TPrinterOrientation(b);
    ReportPage.Orientation := pgOr;

    ReportPage.PaperWidth := pgWidth / 10;
    ReportPage.PaperHeight := pgHeight / 10;

    if frVersion < 23 then
      Read(s[1], 6);

    { bin }
    pgBin := -1;
    if frVersion > 23 then
      Read(pgBin, 4);
    ReportPage.Bin := pgBin;
    ReportPage.BinOtherPages := pgBin;

    { print to prevpage }
    Read(PrintToPrevPage, 2);
    ReportPage.PrintOnPreviousPage := PrintToPrevPage;

    { not used }
    Read(UseMargins, 2);

    { columns }
    Read(ColCount, 4);
    ReportPage.Columns := ColCount;

    { not used }
    Read(ColGap, 4);

    if ColGap <> 0 then
    begin
      ColGap := Round(ColGap / 18 * 5);
      ReportPage.ColumnPositions.Clear;
      if ColCount > 0 then
      begin
        ColWidth := (ReportPage.PaperWidth - ReportPage.LeftMargin - ReportPage.RightMargin + ColGap) / ColCount;
        ReportPage.ColumnWidth := ColWidth - ColGap;
        while ReportPage.ColumnPositions.Count < ColCount do
          ReportPage.ColumnPositions.Add(FloatToStr(ReportPage.ColumnPositions.Count * ColWidth));
      end;
    end;

    if frVersion > 23 then
    begin
      { page type }
      Read(PageType, 1);

      { name }
      ReportPage.Name := frReadString(Stream);
      DialogPage.Name := ReportPage.Name;

      { border style }
      Read(BorderStyle, 1);
      if BorderStyle = 0 then
        BorderStyle := Byte(bsDialog)
      else if BorderStyle = 1 then
        BorderStyle := Byte(bsSizeable);
      DialogPage.BorderStyle := TFormBorderStyle(BorderStyle);

      { caption }
      DialogPage.Caption := frReadString(Stream);

      { color }
      Read(Color, 4);
      DialogPage.Color := Color;

      { left-top-width-height }
      Read(Left, 4);
      Read(Top, 4);
      Read(Width, 4);
      Read(Height, 4);
      DialogPage.Left := Left;
      DialogPage.Top := Top;
      DialogPage.Width := Width;
      DialogPage.Height := Height;

      { position }
      Read(b, 1);
      if b <> 0 then
        b := Byte(poScreenCenter);
      DialogPage.Position := TPosition(b);

      if i = -1 then
      begin
        Script := TStringList.Create;
        frReadMemo(Stream, Script);
      end;
    end
    else
      ReportPage.CreateUniqueName;
  end;

  if PageType = ptReport then
  begin
    ReportPage.Parent := Report;
    DialogPage.Free;
    AddScript(ReportPage, 'OnBeforePrint(Sender: TfrxComponent);');
  end
  else
  begin
    DialogPage.Parent := Report;
    ReportPage.Free;
    AddScript(DialogPage, 'OnShow(Sender: TfrxComponent);');
  end;
end;

procedure ReadReportOptions;
var
  l: Word;
  buf: String;

  ReportComment, ReportName, ReportAuthor : String;
  ReportCreateDate, ReportLastChange : TDateTime;
  ReportVersionMajor : String;
  ReportVersionMinor : String;
  ReportVersionRelease : String;
  ReportVersionBuild : String;
  ReportPasswordProtected : Boolean;
  ReportPassword : String;
  ReportGeneratorVersion : Byte;

  function HexChar1(Ch : Char) : Byte;
  begin
    Ch := UpCase(Ch);
    if (Ch <= '9') then
      Result := Ord(Ch) - Ord('0')
    else
      Result := Ord(Ch) - Ord('A') + 10;
  end;

  function HexToStr(const s : String) : String;
  var
    Len, i           :  Integer;
    Ch               : Byte;
    NibbleH, NibbleL : Byte;
  begin
    Len := Length(s);
    SetLength(Result, Len shr 1);
    for i := 1 to Len shr 1 do begin
      NibbleH := HexChar1(s[i shl 1 - 1]);
      NibbleL := HexChar1(s[i shl 1]);
      Ch      := NibbleH shl 4 or NibbleL;
      Result[i] := Chr(Ch);
    end;
  end;

begin
  Stream.Read(l, 2);
  if l>0 then
  begin
    SetLength(ReportComment, l);
    Stream.Read(ReportComment[1], l);
    Report.ReportOptions.Description.Text := ReportComment;
  end;
  Stream.Read(l, 2);
  if l>0 then
  begin
    SetLength(ReportName, l);
    Stream.Read(ReportName[1], l);
    Report.ReportOptions.Name := ReportName;
  end;
  Stream.Read(l, 2);
  if l>0 then
  begin
    SetLength(ReportAuthor, l);
    Stream.Read(ReportAuthor[1], l);
    Report.ReportOptions.Author := ReportAuthor;
  end;
  Stream.Read(l, 2);
  if l>0 then
  begin
    SetLength(ReportVersionMajor, l);
    Stream.Read(ReportVersionMajor[1], l);
    Report.ReportOptions.VersionMajor := ReportVersionMajor;
  end;
  Stream.Read(l, 2);
  if l>0 then
  begin
    SetLength(ReportVersionMinor, l);
    Stream.Read(ReportVersionMinor[1], l);
    Report.ReportOptions.VersionMinor := ReportVersionMinor;
  end;
  Stream.Read(l, 2);
  if l>0 then
  begin
    SetLength(ReportVersionRelease, l);
    Stream.Read(ReportVersionRelease[1], l);
    Report.ReportOptions.VersionRelease := ReportVersionRelease;
  end;
  Stream.Read(l, 2);
  if l>0 then
  begin
    SetLength(ReportVersionBuild, l);
    Stream.Read(ReportVersionBuild[1], l);
    Report.ReportOptions.VersionBuild := ReportVersionBuild;
  end;
  Stream.Read(l, 2);
  if l>0 then
  begin
    SetLength(Buf, l);
    Stream.Read(Buf[1], l);
    ReportPassword := HexToStr(buf);
    Report.ReportOptions.Password := ReportPassword;
  end;
  Stream.Read(ReportGeneratorVersion, 1);
  Stream.Read(ReportPasswordProtected, SizeOf(Boolean));
  Stream.Read(ReportCreateDate, SizeOf(TDateTime));
  Report.ReportOptions.CreateDate := ReportCreateDate;
  Stream.Read(ReportLastChange, SizeOf(TDateTime));
  Report.ReportOptions.LastChange := ReportLastChange;
end;

procedure TfrPagesLoadFromStream;
var
  b, b1: Byte;
  w: Word;
  n: Integer;
  s: String;
  buf: String[8];
  PrintToDefault: Boolean;
begin
  Stream.Read(w{Parent.PrintToDefault}, 2);
  PrintToDefault := w <> 0;
  Stream.Read(w{Parent.DoublePass}, 2);
  Report.EngineOptions.DoublePass := w <> 0;
  s := ReadString(Stream);
  if (s = #1) or PrintToDefault then
    s := 'Default';
  Report.PrintOptions.Printer := s;

  while Stream.Position < Stream.Size do
  begin
    Stream.Read(b, 1);
    if b = $FF then  // page info
      TfrPageLoadFromStream
    else if b = $FE then // data dictionary
      TfrDictionaryLoadFromStream
    else if b = $FD then // data manager, not supported
    begin
      break;
    end
    else if b = $FC then // extra report data
    begin
      ReadReportOptions;
      break;
    end
    else
    begin
      if b > Integer(gtAddIn) then
      begin
        raise Exception.Create('Error in frf file');
        break;
      end;
      s := ''; n := 0;
      try
        if b = gtAddIn then
        begin
          s := ReadString(Stream);
          if (AnsiUpperCase(s) = 'TFRBDELOOKUPCONTROL') or
             (AnsiUpperCase(s) = 'TFRIBXLOOKUPCONTROL') then
            s := 'TfrDBLookupControl';
          if AnsiUpperCase(s) = 'TFRFRAMEDMEMOVIEW' then
            b := gtMemo;
        end;

        { object's page }
        Stream.Read(b1, 1);
        Page := Report.Pages[b1];
        if Page is TfrxReportPage then
        begin
          offsx := Round(-TfrxReportPage(Page).LeftMargin * fr01cm);
          offsy := Round(-TfrxReportPage(Page).TopMargin * fr01cm);
        end
        else
        begin
          offsx := 0;
          offsy := 0;
        end;

        if frVersion > 23 then
          Stream.Read(n, 4);

        case b of
          gtMemo:      TfrMemoViewLoadFromStream;
          gtPicture:   TfrPictureViewLoadFromStream;
          gtBand:      TfrBandViewLoadFromStream;
          gtSubReport: TfrSubreportLoadFromStream;
          gtLine:      TfrLineViewLoadFromStream;
          gtAddIn:
            begin
              if CompareText(s, 'TfrLabelControl') = 0 then
                ReadTfrLabelControl
              else if CompareText(s, 'TfrEditControl') = 0 then
                ReadTfrEditControl
              else if CompareText(s, 'TfrMemoControl') = 0 then
                ReadTfrMemoControl
              else if CompareText(s, 'TfrButtonControl') = 0 then
                ReadTfrButtonControl
              else if CompareText(s, 'TfrCheckBoxControl') = 0 then
                ReadTfrCheckBoxControl
              else if CompareText(s, 'TfrRadioButtonControl') = 0 then
                ReadTfrRadioButtonControl
              else if CompareText(s, 'TfrListBoxControl') = 0 then
                ReadTfrListBoxControl
              else if CompareText(s, 'TfrComboBoxControl') = 0 then
                ReadTfrComboBoxControl
              else if CompareText(s, 'TfrDateEditControl') = 0 then
                ReadTfrDateEditControl
{              else if CompareText(s, 'TfrDBLookupControl') = 0 then
                ReadTfrDBLookupControl
}
              else if CompareText(s, 'TfrBarCodeView') = 0 then
                ReadTfrBarCodeView
              else if CompareText(s, 'TfrChartView') = 0 then
                ReadTfrChartView
              else if CompareText(s, 'TfrCheckBoxView') = 0 then
                ReadTfrCheckBoxView
              else if CompareText(s, 'TfrCrossView') = 0 then
                ReadTfrCrossView
              else if CompareText(s, 'TfrOLEView') = 0 then
                ReadTfrOLEView
              else if CompareText(s, 'TfrRichView') = 0 then
                ReadTfrRichView
              else if CompareText(s, 'TfrRxRichView') = 0 then
                ReadTfrRichView
              else if CompareText(s, 'TfrRoundRectView') = 0 then
                ReadTfrRoundRectView
              else if CompareText(s, 'TfrShapeView') = 0 then
                ReadTfrShapeView

              else if CompareText(s, 'TfrBDEDatabase') = 0 then
                ReadTfrBDEDatabase
              else if CompareText(s, 'TfrBDETable') = 0 then
                ReadTfrBDETable
              else if CompareText(s, 'TfrBDEQuery') = 0 then
                ReadTfrBDEQuery

              else if CompareText(s, 'TfrADODatabase') = 0 then
                ReadTfrADODatabase
              else if CompareText(s, 'TfrADOTable') = 0 then
                ReadTfrADOTable
              else if CompareText(s, 'TfrADOQuery') = 0 then
                ReadTfrADOQuery

              else if CompareText(s, 'TfrIBXDatabase') = 0 then
                ReadTfrIBXDatabase
              else if CompareText(s, 'TfrIBXTable') = 0 then
                ReadTfrIBXTable
              else if CompareText(s, 'TfrIBXQuery') = 0 then
                ReadTfrIBXQuery
            end;
        end;

        if AnsiUpperCase(s) = 'TFRFRAMEDMEMOVIEW' then
          Stream.Read(buf[1], 8);
        if n <> 0 then
          Stream.Position := n;
      except
        if frVersion > 23 then
        begin
          if n = 0 then
            Stream.Read(n, 4);
          Stream.Seek(n, soFromBeginning);
        end;
      end;
    end;
  end;
end;

procedure TfrReportLoadFromStream;
begin
  Stream.Read(frVersion, 1);
  TfrPagesLoadFromStream;
end;

procedure AdjustBands;
var
  i, j: Integer;
  FObjects: TList;

  procedure TossObjects(Bnd: TfrxBand);
  var
    i: Integer;
    c: TfrxComponent;
    SaveRestrictions: TfrxRestrictions;
  begin
    if Bnd.Vertical then Exit;

    while Bnd.Objects.Count > 0 do
    begin
      c := Bnd.Objects[0];
      SaveRestrictions := c.Restrictions;
      c.Restrictions := [];
      c.Top := c.AbsTop;
      c.Restrictions := SaveRestrictions;
      c.Parent := Bnd.Parent;
    end;

    for i := 0 to FObjects.Count - 1 do
    begin
      c := FObjects[i];
      if (c is TfrxView) and (c.AbsTop >= Bnd.Top - 1e-4) and (c.AbsTop < Bnd.Top + Bnd.Height + 1e-4) then
      begin
        SaveRestrictions := c.Restrictions;
        c.Restrictions := [];
        c.Top := c.AbsTop - Bnd.Top;
        c.Restrictions := SaveRestrictions;
        c.Parent := Bnd;
        if c is TfrxStretcheable then
          if (TfrxStretcheable(c).StretchMode = smMaxHeight) and not Bnd.Stretched then
            TfrxStretcheable(c).StretchMode := smDontStretch;
      end;
    end;
  end;

begin
  FObjects := TList.Create;
  for i := 0 to Report.PagesCount - 1 do
  begin
    Page := Report.Pages[i];
    FObjects.Clear;
    for j := 0 to Page.AllObjects.Count - 1 do
      FObjects.Add(Page.AllObjects[j]);
    for j := 0 to FObjects.Count - 1 do
      if TObject(FObjects[j]) is TfrxBand then
        TossObjects(FObjects[j]);
  end;
  FObjects.Free;
end;

procedure ConnectDatasets;
var
  l: TList;
  i: Integer;
  c: TfrxComponent;
  d: TfrxDataband;
  ds: TfrxDataset;
  cr: TfrxDBCrossView;
  c1: TComponent;
  s: String;
begin
  l := Report.AllObjects;
  for i := 0 to l.Count - 1 do
  begin
    c := l[i];
    if c is TfrxDataband then
    begin
      d := l[i];

      s := d.DatasetName;
      if Pos('DialogForm._', s) = 1 then
      begin
        Delete(s, 1, Length('DialogForm._'));
        d.DatasetName := s;
        ds := d.DataSet;
      end
      else
        ds := frFindComponent(Report.Owner, d.DatasetName) as TfrxDataset;

      if ds <> nil then
      begin
        d.Dataset := ds;
        if Report.Datasets.Find(ds) = nil then
          Report.Datasets.Add(ds);
      end;
    end;
    if c is TfrxDBCrossView then
    begin
      cr := l[i];
      c1 := frFindComponent(Report.Owner, cr.DatasetName);
      if c1 is TDataSet then
      begin
        ds := FindTfrxDataset(TDataSet(c1));
        if ds <> nil then
        begin
          cr.Dataset := ds;
          if Report.Datasets.Find(ds) = nil then
            Report.Datasets.Add(ds);
        end;
      end;
    end;
  end;
end;

function ConvertDatasetAndField(s: String): String;
var
  ds: TDataset;
  ds1: TfrxDataset;
  fld: String;
begin
  ds := nil;
  fld := '';

  if Pos(AnsiUppercase('DialogForm.'), AnsiUppercase(s)) = 1 then
    s := Copy(s, Length('DialogForm.') + 1, 255);

  Result := s;
  frGetDatasetAndField(s, ds, fld);
  if (ds <> nil) and (fld <> '') then
  begin
    ds1 := FindTfrxDataset(ds);
    if ds1 <> nil then
      Result := ds1.UserName + '."' + fld + '"';
  end;
end;

procedure ConvertVariables;
var
  i: Integer;
  v: TfrxVariable;
begin
  for i := 0 to Report.Variables.Count - 1 do
  begin
    v := Report.Variables.Items[i];
    v.Value := ConvertDatasetAndField(v.Value);
  end;
end;

procedure CheckCrosses;
var
  l, l1: TList;
  i, j: Integer;
  c: TfrxComponent;
  cr: TfrxDBCrossView;
  v: TfrxMemoView;

  procedure AssignMemo(m, m1: TfrxCustomMemoView);
  var
    s: String;
  begin
    m.Visible := True;
    m.StretchMode := smDontStretch;
    s := m.Highlight.Condition;
    ExpandVariables1(s);
    m.Highlight.Condition := s;
    m1.Assign(m);
    if l1.IndexOf(m) = -1 then
      l1.Add(m);
  end;

begin
  l := Report.AllObjects;
  l1 := TList.Create;

  for i := 0 to l.Count - 1 do
  begin
    c := l[i];
    if c is TfrxDBCrossView then
    begin
      cr := l[i];
      v := TfrxMemoView(Report.FindObject('ColumnHeaderMemo' + cr.Name));
      if v <> nil then
      begin
        for j := 0 to CROSS_DIM_SIZE - 1 do
          AssignMemo(v, cr.ColumnMemos[j]);
      end;
      v := TfrxMemoView(Report.FindObject('RowHeaderMemo' + cr.Name));
      if v <> nil then
      begin
        for j := 0 to CROSS_DIM_SIZE - 1 do
          AssignMemo(v, cr.RowMemos[j]);
      end;
      v := TfrxMemoView(Report.FindObject('ColumnTotalMemo' + cr.Name));
      if v <> nil then
      begin
        for j := 0 to CROSS_DIM_SIZE - 1 do
          AssignMemo(v, cr.ColumnTotalMemos[j]);
      end;
      v := TfrxMemoView(Report.FindObject('RowTotalMemo' + cr.Name));
      if v <> nil then
      begin
        for j := 0 to CROSS_DIM_SIZE - 1 do
          AssignMemo(v, cr.RowTotalMemos[j]);
      end;
      v := TfrxMemoView(Report.FindObject('GrandColumnTotalMemo' + cr.Name));
      if v <> nil then
      begin
        AssignMemo(v, cr.ColumnTotalMemos[0]);
      end;
      v := TfrxMemoView(Report.FindObject('GrandRowTotalMemo' + cr.Name));
      if v <> nil then
      begin
        AssignMemo(v, cr.RowTotalMemos[0]);
      end;
      v := TfrxMemoView(Report.FindObject('CellMemo' + cr.Name));
      if v <> nil then
      begin
        if not cr.Border then
          v.Frame.Typ := [ftLeft, ftRight];
        for j := 0 to CROSS_DIM_SIZE - 1 do
        begin
          AssignMemo(v, cr.CellMemos[j]);
          if j <> 0 then
            cr.CellMemos[j].Frame.Typ := cr.CellMemos[j].Frame.Typ - [ftTop];
          if j <> cr.CellLevels - 1 then
            cr.CellMemos[j].Frame.Typ := cr.CellMemos[j].Frame.Typ - [ftBottom];
        end;
        cr.Border := True;
      end;
    end;
  end;

  for i := 0 to l1.Count - 1 do
    TObject(l1[i]).Free;
  l1.Free;
end;

procedure CheckCharts;
var
  l: TList;
  i: Integer;
  c, c1: TfrxComponent;
  ch: TfrxChartView;
  dser: TfrxSeriesItem;
begin
  l := Report.AllObjects;
  for i := 0 to l.Count - 1 do
  begin
    c := l[i];
    if c is TfrxChartView then
    begin
      ch := l[i];
      dser := ch.SeriesData[0];
      c1 := Report.FindObject(dser.XSource) as TfrxComponent;
      if (c1 is TfrxMemoView) and (c1.Parent is TfrxDataBand) then
      begin
        dser.Databand := TfrxDataBand(c1.Parent);
        dser.XSource := TfrxMemoView(c1).Text;
        c1 := Report.FindObject(dser.YSource) as TfrxComponent;
        if c1 is TfrxMemoView then
          dser.YSource := TfrxMemoView(c1).Text;
      end;
    end;
  end;
end;

procedure CheckViews;
var
  l: TList;
  i: Integer;
  c: TfrxComponent;
  v: TfrxView;
  s: String;
  ds: TfrxDataSet;
  fld: String;
begin
  l := Report.AllObjects;
  for i := 0 to l.Count - 1 do
  begin
    c := l[i];
    if c is TfrxView then
    begin
      v := l[i];
      if v.DataField <> '' then
        if v.DataField[1] = '[' then
        begin
          s := Copy(v.DataField, 2, Length(v.DataField) - 2);
          if Report.Variables.IndexOf(s) <> -1 then
            s := Report.Variables[s]
          else
            s := ConvertDatasetAndField(s);
          ds := nil;
          fld := '';
          Report.GetDatasetAndField(s, ds, fld);
          if (ds <> nil) and (fld <> '') then
          begin
            v.Dataset := ds;
            v.DataField := fld;
          end;
        end;
    end;
  end;
end;

procedure LoadFromFR2Stream(AReport: TfrxReport; AStream: TStream);
begin
  Report := AReport;
  Stream := AStream;
  ClearFixups;
  Report.Clear;
  Report.ScriptText.Clear;
  TfrReportLoadFromStream;
  Report.ScriptText.Add('begin');
  Report.ScriptText.Add('');
  Report.ScriptText.Add('end.');
  AdjustBands;
  FixupReferences;
  ConnectDatasets;
  ConvertVariables;
  CheckCrosses;
  CheckCharts;
  CheckViews;
end;


initialization
  Memo := TStringList.Create;
  Script := TStringList.Create;
  Fixups := TList.Create;
  fsModifyPascalForFR2;
  frxFR2EventsNew := TfrxFR2EventsNew.Create;
  frxFR2Events.OnGetValue := frxFR2EventsNew.DoGetValue;
  frxFR2Events.OnPrepareScript := frxFR2EventsNew.DoPrepareScript;
  frxFR2Events.OnLoad := frxFR2EventsNew.DoLoad;
  frxFR2Events.OnGetScriptValue := frxFR2EventsNew.DoGetScriptValue;

finalization
  Memo.Free;
  Script.Free;
  Fixups.Free;
  frxFR2EventsNew.Free;


end.

//0f31356a91fea3356e5f76cdce90aa7b