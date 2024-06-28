
{******************************************}
{                                          }
{             FastReport v4.0              }
{          BDE components RTTI             }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxBDERTTI;

interface

{$I frx.inc}

implementation

uses
  Windows, Classes, SysUtils, Forms, fs_iinterpreter, frxBDEComponents,
  fs_ibdertti
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
    with AddClass(TfrxBDEDatabase, 'TfrxCustomDatabase') do
      AddProperty('Database', 'TDatabase', GetProp, nil);
    with AddClass(TfrxBDETable, 'TfrxCustomTable') do
      AddProperty('Table', 'TTable', GetProp, nil);
    with AddClass(TfrxBDEQuery, 'TfrxCustomQuery') do
    begin
      AddMethod('procedure ExecSQL', CallMethod);
      AddProperty('Query', 'TQuery', GetProp, nil);
    end;
  end;
end;

function TFunctions.CallMethod(Instance: TObject; ClassType: TClass;
  const MethodName: String; Caller: TfsMethodHelper): Variant;
begin
  Result := 0;

  if ClassType = TfrxBDEQuery then
  begin
    if MethodName = 'EXECSQL' then
      TfrxBDEQuery(Instance).Query.ExecSQL
  end
end;

function TFunctions.GetProp(Instance: TObject; ClassType: TClass;
  const PropName: String): Variant;
begin
  Result := 0;

  if ClassType = TfrxBDEDatabase then
  begin
    if PropName = 'DATABASE' then
      Result := Integer(TfrxBDEDatabase(Instance).Database)
  end
  else if ClassType = TfrxBDETable then
  begin
    if PropName = 'TABLE' then
      Result := Integer(TfrxBDETable(Instance).Table)
  end
  else if ClassType = TfrxBDEQuery then
  begin
    if PropName = 'QUERY' then
      Result := Integer(TfrxBDEQuery(Instance).Query)
  end
end;


initialization
  fsRTTIModules.Add(TFunctions);

finalization
  fsRTTIModules.Remove(TFunctions);

end.
