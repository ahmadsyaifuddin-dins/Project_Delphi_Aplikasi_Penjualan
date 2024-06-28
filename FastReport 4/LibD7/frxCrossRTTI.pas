
{******************************************}
{                                          }
{             FastReport v4.0              }
{              Cross-tab RTTI              }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxCrossRTTI;

interface

{$I frx.inc}

implementation

uses
  Windows, Classes, SysUtils, Forms, fs_iinterpreter, frxCross, frxClassRTTI
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
    with AddClass(TfrxCustomCrossView, 'TfrxView') do
    begin
      AddMethod('procedure AddValue(Rows, Columns, Cells: array)', CallMethod);
      AddMethod('procedure BeginMatrix', CallMethod);
      AddMethod('function ColCount: Integer', CallMethod);
      AddMethod('function RowCount: Integer', CallMethod);
      AddMethod('function IsGrandTotalColumn(Index: Integer): Boolean', CallMethod);
      AddMethod('function IsGrandTotalRow(Index: Integer): Boolean', CallMethod);
      AddMethod('function IsTotalColumn(Index: Integer): Boolean', CallMethod);
      AddMethod('function IsTotalRow(Index: Integer): Boolean', CallMethod);
      AddProperty('ClearBeforePrint', 'Boolean', GetProp, SetProp);
    end;

    AddClass(TfrxCrossView, 'TfrxCustomCrossView');
    AddClass(TfrxDBCrossView, 'TfrxCustomCrossView');
  end;
end;

function TFunctions.CallMethod(Instance: TObject; ClassType: TClass;
  const MethodName: String; Caller: TfsMethodHelper): Variant;
var
  ar: array[0..2] of array of Variant;

  procedure ConvertVariantToArray(v: Variant; Index: Integer);
  var
    i: Integer;
  begin
    SetLength(ar[Index], VarArrayHighBound(v, 1) + 1);
    for i := 0 to VarArrayHighBound(v, 1) do
      ar[Index][i] := v[i];
  end;

begin
  Result := 0;

  if MethodName = 'ADDVALUE' then
  begin
    ConvertVariantToArray(Caller.Params[0], 0);
    ConvertVariantToArray(Caller.Params[1], 1);
    ConvertVariantToArray(Caller.Params[2], 2);
    TfrxCustomCrossView(Instance).AddValue(ar[0], ar[1], ar[2]);
    ar[0] := nil;
    ar[1] := nil;
    ar[2] := nil;
  end
  else if MethodName = 'BEGINMATRIX' then
    TfrxCustomCrossView(Instance).BeginMatrix
  else if MethodName = 'COLCOUNT' then
    Result := TfrxCustomCrossView(Instance).ColCount
  else if MethodName = 'ROWCOUNT' then
    Result := TfrxCustomCrossView(Instance).RowCount
  else if MethodName = 'ISGRANDTOTALCOLUMN' then
    Result := TfrxCustomCrossView(Instance).IsGrandTotalColumn(Caller.Params[0])
  else if MethodName = 'ISGRANDTOTALROW' then
    Result := TfrxCustomCrossView(Instance).IsGrandTotalRow(Caller.Params[0])
  else if MethodName = 'ISTOTALCOLUMN' then
    Result := TfrxCustomCrossView(Instance).IsTotalColumn(Caller.Params[0])
  else if MethodName = 'ISTOTALROW' then
    Result := TfrxCustomCrossView(Instance).IsTotalRow(Caller.Params[0])
end;

function TFunctions.GetProp(Instance: TObject; ClassType: TClass;
  const PropName: String): Variant;
begin
  Result := 0;

  if PropName = 'CLEARBEFOREPRINT' then
    Result := TfrxCustomCrossView(Instance).ClearBeforePrint
end;

procedure TFunctions.SetProp(Instance: TObject; ClassType: TClass;
  const PropName: String; Value: Variant);
begin
  if PropName = 'CLEARBEFOREPRINT' then
    TfrxCustomCrossView(Instance).ClearBeforePrint := Value;
end;


initialization
  fsRTTIModules.Add(TFunctions);

end.


//0f31356a91fea3356e5f76cdce90aa7b