
{******************************************}
{                                          }
{             FastReport v4.0              }
{      Publish all classes defined in      }
{                frxClass                  }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxClassRTTI;

interface

{$I frx.inc}


implementation

uses
  SysUtils, Classes, Controls, fs_iinterpreter, frxClass, frxCtrls,
  frxPreviewPages, frxEngine, frxDMPClass, frxVariables, fs_iformsrtti,
  frxUnicodeUtils
{$IFDEF Delphi6}
, Variants
{$ENDIF};


type
  TFunctions = class(TfsRTTIModule)
  private
    function CallMethod(Instance: TObject; ClassType: TClass;
      const MethodName: String; Caller: TfsMethodHelper): Variant;
    function GetProp(Instance: TObject; ClassType: TClass;
      const PropName: String): Variant;
    procedure SetProp(Instance: TObject; ClassType: TClass;
      const PropName: String; Value: Variant);
  public
    constructor Create(AScript: TfsScript); override;
  end;


{ TFunctions }

constructor TFunctions.Create(AScript: TfsScript);
begin
  inherited Create(AScript);
  with AScript do
  begin
    AddConst('fr01cm', 'Extended', fr01cm);
    AddConst('fr1cm', 'Extended', fr1cm);
    AddConst('fr01in', 'Extended', fr01in);
    AddConst('fr1in', 'Extended', fr1in);
    AddConst('fr1CharX', 'Extended', fr1CharX);
    AddConst('fr1CharY', 'Extended', fr1CharY);
    AddConst('clTransparent', 'Integer', clTransparent);
    AddConst('crHand', 'Integer', crHand);
    AddConst('crZoom', 'Integer', crZoom);
    AddConst('crFormat', 'Integer', crFormat);
    AddEnum('TfrxStretchMode', 'smDontStretch, smActualHeight, smMaxHeight');
    AddEnum('TfrxShiftMode', 'smDontShift, smAlways, smWhenOverlapped');
    AddEnum('TfrxDuplexMode', 'dmNone, dmVertical, dmHorizontal, dmSimplex');
    AddEnum('TfrxAlign', 'baNone, baLeft, baRight, baCenter, baWidth, baBottom');
    AddEnum('TfrxFrameStyle', 'fsSolid, fsDash, fsDot, fsDashDot, fsDashDotDot, fsDouble');
    AddEnumSet('TfrxFrameTypes', 'ftLeft, ftRight, ftTop, ftBottom');
    AddEnum('TfrxHAlign', 'haLeft, haRight, haCenter, haBlock');
    AddEnum('TfrxVAlign', 'vaTop, vaBottom, vaCenter');
    AddEnumSet('TfrxRestrictions', 'rfDontModify, rfDontSize, rfDontMove, rfDontDelete');
    AddEnum('TfrxShapeKind', 'skRectangle, skRoundRectangle, skEllipse, skTriangle, skDiagonal1, skDiagonal2');
    AddEnumSet('TfrxPreviewButtons', 'pbPrint, pbLoad, pbSave, pbExport, ' +
      'pbZoom, pbFind, pbTree, pbPageSetup, pbRefresh, pbTools, pbEdit, pbNavigator, pbExportQuick');
    AddEnum('TfrxZoomMode', 'zmDefault, zmWholePage, zmPageWidth, zmManyPages');
    AddEnum('TfrxPrintPages', 'ppAll, ppOdd, ppEven');
    AddEnumSet('TfrxDMPFontStyles', 'fsxBold, fsxItalic, fsxUnderline, fsxSuperScript, ' +
      'fsxSubScript, fsxCondensed, fsxWide, fsx12cpi, fsx15cpi');
    AddEnum('TfrxRangeBegin', 'rbFirst, rbCurrent');
    AddEnum('TfrxRangeEnd', 'reLast, reCurrent, reCount');
    AddEnum('TfrxFieldType', 'fftNumeric, fftString, fftBoolean');
    AddEnum('TfrxFormatKind', 'fkText, fkNumeric, fkDateTime, fkBoolean');

    with AddClass(TWideStrings, 'TPersistent') do
    begin
      AddMethod('function Add(const S: string): Integer', CallMethod);
      AddMethod('function AddObject(const S: string; AObject: TObject): Integer', CallMethod);
      AddMethod('procedure Clear', CallMethod);
      AddMethod('procedure Delete(Index: Integer)', CallMethod);
      AddMethod('function IndexOf(const S: string): Integer', CallMethod);
      AddMethod('procedure Insert(Index: Integer; const S: string)', CallMethod);
      AddMethod('procedure LoadFromFile(const FileName: string)', CallMethod);
      AddMethod('procedure LoadFromStream(Stream: TStream)', CallMethod);
      AddMethod('procedure SaveToFile(const FileName: string)', CallMethod);
      AddMethod('procedure SaveToStream(Stream: TStream)', CallMethod);

      AddProperty('Count', 'Integer', GetProp, nil);
      AddIndexProperty('Objects', 'Integer', 'TObject', CallMethod);
      AddDefaultProperty('Strings', 'Integer', 'string', CallMethod);
      AddProperty('Text', 'string', GetProp, SetProp);
    end;

    with AddClass(TfrxDataSet, 'TComponent') do
    begin
      AddMethod('procedure Open', CallMethod);
      AddMethod('procedure Close', CallMethod);
      AddMethod('procedure First', CallMethod);
      AddMethod('procedure Next', CallMethod);
      AddMethod('procedure Prior', CallMethod);
      AddMethod('function Eof: Boolean', CallMethod);
      AddMethod('function FieldsCount: Integer', CallMethod);
      AddMethod('function HasField(const fName: String): Boolean', CallMethod);
      AddMethod('function IsBlobField(const fName: String): Boolean', CallMethod);
      AddMethod('function RecordCount: Integer', CallMethod);
      AddMethod('procedure GetFieldList(List: TStrings)', CallMethod);
      AddProperty('RecNo', 'Integer', GetProp, nil);
      AddIndexProperty('DisplayText', 'String', 'String', CallMethod, True);
      AddIndexProperty('DisplayWidth', 'String', 'Integer', CallMethod, True);
      AddIndexProperty('FieldType', 'String', 'TfrxFieldType', CallMethod, True);
      AddIndexProperty('Value', 'String', 'Variant', CallMethod, True);
    end;
    AddClass(TfrxUserDataSet, 'TfrxDataSet');
    AddClass(TfrxCustomDBDataSet, 'TfrxDataSet');

    with AddClass(TfrxComponent, 'TComponent') do
    begin
      AddMethod('procedure Clear', CallMethod);
      AddMethod('function FindObject(s: String): TfrxComponent', CallMethod);
      AddMethod('procedure LoadFromStream(Stream: TStream)', CallMethod);
      AddMethod('procedure SaveToStream(Stream: TStream; SaveChildren: Boolean = True)', CallMethod);
      AddMethod('procedure SetBounds(ALeft, ATop, AWidth, AHeight: Extended)', CallMethod);
      AddProperty('Objects', 'TList', GetProp, nil);
      AddProperty('AllObjects', 'TList', GetProp, nil);
      AddProperty('Parent', 'TfrxComponent', GetProp, SetProp);
      AddProperty('Page', 'TfrxPage', GetProp, nil);
      AddProperty('AbsLeft', 'Extended', GetProp, nil);
      AddProperty('AbsTop', 'Extended', GetProp, nil);
    end;
    AddClass(TfrxReportComponent, 'TfrxComponent');
    AddClass(TfrxDialogComponent, 'TfrxReportComponent');
    with AddClass(TfrxDialogControl, 'TfrxReportComponent') do
      AddMethod('procedure SetFocus', CallMethod);
    AddClass(TfrxFrameLine, 'TPersistent');
    AddClass(TfrxFrame, 'TPersistent');
    with AddClass(TfrxView, 'TfrxReportComponent') do
      AddProperty('TagStr', 'String', GetProp, SetProp);
    AddClass(TfrxShapeView, 'TfrxView');
    with AddClass(TfrxStretcheable, 'TfrxView') do
      AddMethod('function CalcHeight: Extended', CallMethod);
    AddClass(TfrxHighlight, 'TPersistent');
    AddClass(TfrxFormat, 'TPersistent');
    with AddClass(TfrxCustomMemoView, 'TfrxStretcheable') do
    begin
      AddMethod('function CalcWidth: Extended', CallMethod);
      AddProperty('Text', 'String', GetProp, SetProp);
      AddProperty('Lines', 'TWideStrings', GetProp, SetProp);
      AddProperty('Value', 'Variant', GetProp, nil);
    end;
    AddClass(TfrxMemoView, 'TfrxCustomMemoView');
    AddClass(TfrxSysMemoView, 'TfrxCustomMemoView');
    AddClass(TfrxDMPMemoView, 'TfrxCustomMemoView');
    AddClass(TfrxCustomLineView, 'TfrxStretcheable');
    AddClass(TfrxLineView, 'TfrxCustomLineView');
    AddClass(TfrxDMPLineView, 'TfrxCustomLineView');
    AddClass(TfrxDMPCommand, 'TfrxView');
    with AddClass(TfrxPictureView, 'TfrxView') do
      AddMethod('procedure LoadFromFile(filename: String)', CallMethod);
    AddClass(TfrxSubreport, 'TfrxView');
    with AddClass(TfrxBand, 'TfrxReportComponent') do
      AddProperty('Overflow', 'Boolean', GetProp, nil);
    AddClass(TfrxDataBand, 'TfrxBand');
    AddClass(TfrxHeader, 'TfrxBand');
    AddClass(TfrxFooter, 'TfrxBand');
    AddClass(TfrxMasterData, 'TfrxDataBand');
    AddClass(TfrxDetailData, 'TfrxDataBand');
    AddClass(TfrxSubDetailData, 'TfrxDataBand');
    AddClass(TfrxDataBand4, 'TfrxDataBand');
    AddClass(TfrxDataBand5, 'TfrxDataBand');
    AddClass(TfrxDataBand6, 'TfrxDataBand');
    AddClass(TfrxPageHeader, 'TfrxBand');
    AddClass(TfrxPageFooter, 'TfrxBand');
    AddClass(TfrxColumnHeader, 'TfrxBand');
    AddClass(TfrxColumnFooter, 'TfrxBand');
    AddClass(TfrxGroupHeader, 'TfrxBand');
    AddClass(TfrxGroupFooter, 'TfrxBand');
    AddClass(TfrxReportTitle, 'TfrxBand');
    AddClass(TfrxReportSummary, 'TfrxBand');
    AddClass(TfrxChild, 'TfrxBand');
    AddClass(TfrxOverlay, 'TfrxBand');
    AddClass(TfrxPage, 'TfrxComponent');
    AddClass(TfrxReportPage, 'TfrxPage');
    with AddClass(TfrxDialogPage, 'TfrxPage') do
    begin
      AddMethod('function ShowModal: Integer', CallMethod);
      AddProperty('ModalResult', 'Integer', GetProp, SetProp);
    end;
    AddClass(TfrxDMPPage, 'TfrxReportPage');
    AddClass(TfrxDataPage, 'TfrxPage');
    AddClass(TfrxEngineOptions, 'TPersistent');
    AddClass(TfrxPrintOptions, 'TPersistent');
    AddClass(TfrxPreviewOptions, 'TPersistent');
    AddClass(TfrxReportOptions, 'TPersistent');
    AddClass(TfrxVariable, 'TCollectionItem');
    with AddClass(TfrxVariables, 'TCollection') do
    begin
      AddDefaultProperty('Variables', 'String', 'Variant', CallMethod);
    end;
    AddObject('frxGlobalVariables', frxGlobalVariables);
    with AddClass(TfrxReport, 'TfrxComponent') do
    begin
      AddMethod('function Calc(const Expr: String): Variant', CallMethod);
      AddMethod('function GetDataset(const Alias: String): TfrxDataset', CallMethod);
      AddMethod('function LoadFromFile(const FileName: String): Boolean', CallMethod);
      AddMethod('procedure SaveToFile(const FileName: String)', CallMethod);
      AddMethod('procedure ShowReport', CallMethod);
      AddProperty('Terminated', 'Boolean', GetProp, SetProp);
      AddProperty('Variables', 'TfrxVariables', GetProp, nil);
    end;
    with AddClass(TfrxCustomEngine, 'TPersistent') do
    begin
      AddMethod('procedure AddAnchor(const Text: String)', CallMethod);
      AddMethod('procedure NewPage', CallMethod);
      AddMethod('procedure NewColumn', CallMethod);
      AddMethod('procedure ShowBand(Band: TfrxBand)', CallMethod);
      AddMethod('procedure StopReport', CallMethod);
      AddMethod('function FreeSpace: Extended', CallMethod);
      AddMethod('function GetAnchorPage(const Text: String): Integer', CallMethod);
    end;
    AddClass(TfrxEngine, 'TfrxCustomEngine');
    with AddClass(TfrxCustomOutline, 'TPersistent') do
    begin
      AddMethod('procedure AddItem(const Text: String)', CallMethod);
      AddMethod('procedure LevelRoot', CallMethod);
      AddMethod('procedure LevelUp', CallMethod);
    end;
    AddClass(TfrxOutline, 'TfrxCustomOutline');

    AddMethod('function DayOf(Date: TDateTime): Integer', CallMethod, 'ctDate');
    AddMethod('function MonthOf(Date: TDateTime): Integer', CallMethod, 'ctDate');
    AddMethod('function YearOf(Date: TDateTime): Integer', CallMethod, 'ctDate');

    { note: these functions don't have implementation here. They are implemented
      in the frxClass.pas unit }
    AddMethod('function IIF(Expr: Boolean; TrueValue, FalseValue: Variant): Variant',
      CallMethod, 'ctOther');
    AddMethod('function SUM(Expr: Variant; Band: Variant = 0; Flags: Integer = 0): Variant',
      CallMethod, 'ctAggregate');
    AddMethod('function AVG(Expr: Variant; Band: Variant = 0; Flags: Integer = 0): Variant',
      CallMethod, 'ctAggregate');
    AddMethod('function MIN(Expr: Variant; Band: Variant = 0; Flags: Integer = 0): Variant',
      CallMethod, 'ctAggregate');
    AddMethod('function MAX(Expr: Variant; Band: Variant = 0; Flags: Integer = 0): Variant',
      CallMethod, 'ctAggregate');
    AddMethod('function COUNT(Band: Variant = 0; Flags: Integer = 0): Variant',
      CallMethod, 'ctAggregate');
  end;
end;

function TFunctions.CallMethod(Instance: TObject; ClassType: TClass;
  const MethodName: String; Caller: TfsMethodHelper): Variant;
var
  _TfrxDataSet: TfrxDataSet;
  _TStrings: TWideStrings;
begin
  Result := 0;
  if ClassType = TWideStrings then
  begin
    _TStrings := TWideStrings(Instance);
    if MethodName = 'ADD' then
      Result := _TStrings.Add(Caller.Params[0])
    else if MethodName = 'ADDOBJECT' then
      Result := _TStrings.AddObject(Caller.Params[0], TObject(Integer(Caller.Params[1])))
    else if MethodName = 'CLEAR' then
      _TStrings.Clear
    else if MethodName = 'DELETE' then
      _TStrings.Delete(Caller.Params[0])
    else if MethodName = 'INDEXOF' then
      Result := _TStrings.IndexOf(Caller.Params[0])
    else if MethodName = 'INSERT' then
      _TStrings.Insert(Caller.Params[0], Caller.Params[1])
    else if MethodName = 'LOADFROMFILE' then
      _TStrings.LoadFromFile(Caller.Params[0])
    else if MethodName = 'LOADFROMSTREAM' then
      _TStrings.LoadFromStream(TStream(Integer(Caller.Params[0])))
    else if MethodName = 'SAVETOFILE' then
      _TStrings.SaveToFile(Caller.Params[0])
    else if MethodName = 'SAVETOSTREAM' then
      _TStrings.SaveToStream(TStream(Integer(Caller.Params[0])))
    else if MethodName = 'OBJECTS.GET' then
      Result := Integer(_TStrings.Objects[Caller.Params[0]])
    else if MethodName = 'OBJECTS.SET' then
      _TStrings.Objects[Caller.Params[0]] := TObject(Integer(Caller.Params[1]))
    else if MethodName = 'STRINGS.GET' then
      Result := _TStrings.Strings[Caller.Params[0]]
    else if MethodName = 'STRINGS.SET' then
      _TStrings.Strings[Caller.Params[0]] := Caller.Params[1]
  end
  else if ClassType = TfrxDataSet then
  begin
    _TfrxDataSet := TfrxDataSet(Instance);
    if MethodName = 'OPEN' then
      _TfrxDataSet.Open
    else if MethodName = 'CLOSE' then
      _TfrxDataSet.Close
    else if MethodName = 'FIRST' then
      _TfrxDataSet.First
    else if MethodName = 'NEXT' then
      _TfrxDataSet.Next
    else if MethodName = 'PRIOR' then
      _TfrxDataSet.Prior
    else if MethodName = 'EOF' then
      Result := _TfrxDataSet.Eof
    else if MethodName = 'FIELDSCOUNT' then
      Result := _TfrxDataSet.FieldsCount
    else if MethodName = 'RECORDCOUNT' then
      Result := _TfrxDataSet.RecordCount
    else if MethodName = 'HASFIELD' then
      Result := _TfrxDataSet.HasField(Caller.Params[0])
    else if MethodName = 'ISBLOBFIELD' then
      Result := _TfrxDataSet.IsBlobField(Caller.Params[0])
    else if MethodName = 'GETFIELDLIST' then
      _TfrxDataSet.GetFieldList(TStrings(Integer(Caller.Params[0])))
    else if MethodName = 'DISPLAYTEXT.GET' then
      Result := _TfrxDataSet.DisplayText[Caller.Params[0]]
    else if MethodName = 'DISPLAYWIDTH.GET' then
      Result := _TfrxDataSet.DisplayWidth[Caller.Params[0]]
    else if MethodName = 'FIELDTYPE.GET' then
      Result := _TfrxDataSet.FieldType[Caller.Params[0]]
    else if MethodName = 'VALUE.GET' then
      Result := _TfrxDataSet.Value[Caller.Params[0]]
  end
  else if ClassType = TfrxComponent then
  begin
    if MethodName = 'CLEAR' then
      TfrxComponent(Instance).Clear
    else if MethodName = 'FINDOBJECT' then
      Result := Integer(TfrxComponent(Instance).FindObject(Caller.Params[0]))
    else if MethodName = 'LOADFROMSTREAM' then
      TfrxComponent(Instance).LoadFromStream(TStream(Integer(Caller.Params[0])))
    else if MethodName = 'SAVETOSTREAM' then
      TfrxComponent(Instance).SaveToStream(TStream(Integer(Caller.Params[0])), Caller.Params[1])
    else if MethodName = 'SETBOUNDS' then
      TfrxComponent(Instance).SetBounds(Caller.Params[0], Caller.Params[1], Caller.Params[2], Caller.Params[3])
  end
  else if ClassType = TfrxDialogControl then
  begin
    if MethodName = 'SETFOCUS' then
      if TfrxDialogControl(Instance).Control is TWinControl then
        TWinControl(TfrxDialogControl(Instance).Control).SetFocus;
  end
  else if ClassType = TfrxStretcheable then
  begin
    if MethodName = 'CALCHEIGHT' then
      Result := TfrxStretcheable(Instance).CalcHeight
  end
  else if ClassType = TfrxCustomMemoView then
  begin
    if MethodName = 'CALCWIDTH' then
      Result := TfrxCustomMemoView(Instance).CalcWidth
  end
  else if ClassType = TfrxPictureView then
  begin
    if MethodName = 'LOADFROMFILE' then
      TfrxPictureView(Instance).Picture.LoadFromFile(Caller.Params[0])
  end
  else if ClassType = TfrxDialogPage then
  begin
    if MethodName = 'SHOWMODAL' then
      Result := TfrxDialogPage(Instance).ShowModal
  end
  else if ClassType = TfrxVariables then
  begin
    if MethodName = 'VARIABLES.GET' then
      Result := TfrxVariables(Instance).Variables[Caller.Params[0]]
    else if MethodName = 'VARIABLES.SET' then
      TfrxVariables(Instance).Variables[Caller.Params[0]] := Caller.Params[1]
  end
  else if ClassType = TfrxReport then
  begin
    if MethodName = 'CALC' then
      Result := TfrxReport(Instance).Calc(Caller.Params[0])
    else if MethodName = 'GETDATASET' then
      Result := Integer(TfrxReport(Instance).GetDataset(Caller.Params[0]))
    else if MethodName = 'LOADFROMFILE' then
      Result := TfrxReport(Instance).LoadFromFile(Caller.Params[0])
    else if MethodName = 'SAVETOFILE' then
      TfrxReport(Instance).SaveToFile(Caller.Params[0])
    else if MethodName = 'SHOWREPORT' then
      TfrxReport(Instance).ShowReport
  end
  else if ClassType = TfrxCustomEngine then
  begin
    if MethodName = 'ADDANCHOR' then
      TfrxPreviewPages(TfrxCustomEngine(Instance).PreviewPages).AddAnchor(Caller.Params[0])
    else if MethodName = 'GETANCHORPAGE' then
      Result := TfrxPreviewPages(TfrxCustomEngine(Instance).PreviewPages).GetAnchorPage(Caller.Params[0])
    else if MethodName = 'NEWPAGE' then
      TfrxCustomEngine(Instance).NewPage
    else if MethodName = 'NEWCOLUMN' then
      TfrxCustomEngine(Instance).NewColumn
    else if MethodName = 'FREESPACE' then
      Result := TfrxCustomEngine(Instance).FreeSpace
    else if MethodName = 'SHOWBAND' then
      TfrxCustomEngine(Instance).ShowBand(TfrxBand(Integer(Caller.Params[0])))
    else if MethodName = 'STOPREPORT' then
      TfrxCustomEngine(Instance).StopReport
  end
  else if ClassType = TfrxCustomOutline then
  begin
    if MethodName = 'ADDITEM' then
      TfrxCustomOutline(Instance).AddItem(Caller.Params[0],
        Round(TfrxCustomOutline(Instance).Engine.CurY))
    else if MethodName = 'LEVELROOT' then
      TfrxCustomOutline(Instance).LevelRoot
    else if MethodName = 'LEVELUP' then
      TfrxCustomOutline(Instance).LevelUp
  end
  else if MethodName = 'DAYOF' then
    Result := StrToInt(FormatDateTime('d', Caller.Params[0]))
  else if MethodName = 'MONTHOF' then
    Result := StrToInt(FormatDateTime('m', Caller.Params[0]))
  else if MethodName = 'YEAROF' then
    Result := StrToInt(FormatDateTime('yyyy', Caller.Params[0]))
end;

function TFunctions.GetProp(Instance: TObject; ClassType: TClass;
  const PropName: String): Variant;
begin
  Result := 0;

  if ClassType = TWideStrings then
  begin
    if PropName = 'COUNT' then
      Result := TWideStrings(Instance).Count
    else if PropName = 'TEXT' then
      Result := TWideStrings(Instance).Text
  end
  else if ClassType = TfrxDataSet then
  begin
    if PropName = 'RECNO' then
      Result := TfrxDataSet(Instance).RecNo
  end
  else if ClassType = TfrxComponent then
  begin
    if PropName = 'OBJECTS' then
      Result := Integer(TfrxComponent(Instance).Objects)
    else if PropName = 'ALLOBJECTS' then
      Result := Integer(TfrxComponent(Instance).AllObjects)
    else if PropName = 'PARENT' then
      Result := Integer(TfrxComponent(Instance).Parent)
    else if PropName = 'PAGE' then
      Result := Integer(TfrxComponent(Instance).Page)
    else if PropName = 'ABSLEFT' then
      Result := TfrxComponent(Instance).AbsLeft
    else if PropName = 'ABSTOP' then
      Result := TfrxComponent(Instance).AbsTop
  end
  else if ClassType = TfrxView then
  begin
    if PropName = 'TAGSTR' then
      Result := TfrxView(Instance).TagStr
  end
  else if ClassType = TfrxCustomMemoView then
  begin
    if PropName = 'TEXT' then
      Result := TfrxMemoView(Instance).Text
    else if PropName = 'LINES' then
      Result := Integer(TfrxMemoView(Instance).Memo)
    else if PropName = 'VALUE' then
      Result := TfrxMemoView(Instance).Value
  end
  else if ClassType = TfrxBand then
  begin
    if PropName = 'OVERFLOW' then
      Result := TfrxBand(Instance).Overflow
  end
  else if ClassType = TfrxDialogPage then
  begin
    if PropName = 'MODALRESULT' then
      Result := TfrxDialogPage(Instance).ModalResult
  end
  else if ClassType = TfrxReport then 
  begin
    if PropName = 'TERMINATED' then
      Result := TfrxReport(Instance).Terminated
    else if PropName = 'VARIABLES' then
      Result := Integer(TfrxReport(Instance).Variables)
  end
end;

procedure TFunctions.SetProp(Instance: TObject; ClassType: TClass;
  const PropName: String; Value: Variant);
begin
  if ClassType = TWideStrings then
  begin
    if PropName = 'TEXT' then
      TWideStrings(Instance).Text := Value
  end
  else if ClassType = TfrxComponent then
  begin
    if PropName = 'PARENT' then
      TfrxComponent(Instance).Parent := TfrxComponent(Integer(Value))
  end
  else if ClassType = TfrxView then
  begin
    if PropName = 'TAGSTR' then
      TfrxView(Instance).TagStr := Value
  end
  else if ClassType = TfrxCustomMemoView then
  begin
    if PropName = 'TEXT' then
      TfrxMemoView(Instance).Text := Value
    else if PropName = 'LINES' then
      TfrxMemoView(Instance).Memo.Assign(TStrings(Integer(Value)));
  end
  else if ClassType = TfrxDialogPage then
  begin
    if PropName = 'MODALRESULT' then
      TfrxDialogPage(Instance).ModalResult := Value
  end
  else if ClassType = TfrxReport then
  begin
    if PropName = 'TERMINATED' then
      TfrxReport(Instance).Terminated := Value
  end
end;


initialization
  fsRTTIModules.Add(TFunctions);

end.


//0f31356a91fea3356e5f76cdce90aa7b