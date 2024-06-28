
{******************************************}
{                                          }
{             FastScript v1.9              }
{        IBX classes and functions         }
{                                          }
{  (c) 2003-2005 by Alexander Tzyganenko,  }
{             Fast Reports Inc             }
{                                          }
{******************************************}

unit fs_iibxrtti;

interface

{$i fs.inc}

uses
  SysUtils, Classes, fs_iinterpreter, fs_itools, fs_idbrtti, db, ibdatabase,
  IBCustomDataSet, IBQuery, IBTable, IBStoredProc;

type
  TfsIBXRTTI = class(TComponent); // fake component


implementation

type
  TFunctions = class(TfsRTTIModule)
  private
    function CallMethod(Instance: TObject; ClassType: TClass;
      const MethodName: String; Caller: TfsMethodHelper): Variant;
  public
    constructor Create(AScript: TfsScript); override;
  end;


{ TFunctions }

constructor TFunctions.Create(AScript: TfsScript);
begin
  inherited Create(AScript);
  with AScript do
  begin
    AddClass(TIBDataBase, 'TComponent');
    AddClass(TIBTransaction, 'TComponent');
    AddClass(TIBCustomDataSet, 'TDataSet');
    AddClass(TIBTable, 'TIBCustomDataSet');
    with AddClass(TIBQuery, 'TIBCustomDataSet') do
      AddMethod('procedure ExecSQL', CallMethod);
    with AddClass(TIBStoredProc, 'TIBCustomDataSet') do
      AddMethod('procedure ExecProc', CallMethod);
  end;
end;

function TFunctions.CallMethod(Instance: TObject; ClassType: TClass;
  const MethodName: String; Caller: TfsMethodHelper): Variant;
begin
  Result := 0;

  if ClassType = TIBQuery then
  begin
    if MethodName = 'EXECSQL' then
      TIBQuery(Instance).ExecSQL
  end
  else if ClassType = TIBStoredProc then
  begin
    if MethodName = 'EXECPROC' then
      TIBStoredProc(Instance).ExecProc
  end
end;


initialization
  fsRTTIModules.Add(TFunctions);

finalization
  fsRTTIModules.Remove(TFunctions);

end.
