
{******************************************}
{                                          }
{             FastReport v4.0              }
{          ADO components RTTI             }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxADORTTI;

interface

{$I frx.inc}

implementation

uses
  Windows, Classes, fs_iinterpreter, frxADOComponents, fs_iadortti
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
  public
    constructor Create(AScript: TfsScript); override;
  end;


{ TFunctions }

constructor TFunctions.Create(AScript: TfsScript);
begin
  inherited Create(AScript);
  with AScript do
  begin
    with AddClass(TfrxADODatabase, 'TfrxCustomDatabase') do
      AddProperty('Database', 'TADOConnection', GetProp, nil);
    with AddClass(TfrxADOTable, 'TfrxCustomTable') do
      AddProperty('Table', 'TADOTable', GetProp, nil);
    with AddClass(TfrxADOQuery, 'TfrxCustomQuery') do
    begin
      AddMethod('procedure ExecSQL', CallMethod);
      AddProperty('Query', 'TADOQuery', GetProp, nil);
    end;
  end;
end;

function TFunctions.CallMethod(Instance: TObject; ClassType: TClass;
  const MethodName: String; Caller: TfsMethodHelper): Variant;
begin
  Result := 0;

  if ClassType = TfrxADOQuery then
  begin
    if MethodName = 'EXECSQL' then
      TfrxADOQuery(Instance).Query.ExecSQL
  end
end;

function TFunctions.GetProp(Instance: TObject; ClassType: TClass;
  const PropName: String): Variant;
begin
  Result := 0;

  if ClassType = TfrxADODatabase then
  begin
    if PropName = 'DATABASE' then
      Result := Integer(TfrxADODatabase(Instance).Database)
  end
  else if ClassType = TfrxADOTable then
  begin
    if PropName = 'TABLE' then
      Result := Integer(TfrxADOTable(Instance).Table)
  end
  else if ClassType = TfrxADOQuery then
  begin
    if PropName = 'QUERY' then
      Result := Integer(TfrxADOQuery(Instance).Query)
  end
end;


initialization
  fsRTTIModules.Add(TFunctions);

finalization
  fsRTTIModules.Remove(TFunctions);

end.
