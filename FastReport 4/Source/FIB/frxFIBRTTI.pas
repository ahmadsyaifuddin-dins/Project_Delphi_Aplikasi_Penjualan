
{******************************************}
{                                          }
{             FastReport v4.0              }
{         Fib enduser components           }
{                                          }
{         Copyright (c) 2004               }
{         by Alexander Tzyganenko,         }
{******************************************}
{                                          }
{       Improved by Butov Konstantin       }
{  Improved by  Serge Buzadzhy             }
{             buzz@devrace.com             }
{                                          }
{******************************************}

unit frxFIBRTTI;

interface

{$I frx.inc}

implementation

uses
  Windows, Classes, fs_iinterpreter, fs_idbrtti, frxFIBComponents, 
  pFIBDatabase, pFIBDataSet
{$IFDEF Delphi6}
, Variants
{$ENDIF};


type
  TFunctions = class(TfsRTTIModule)
  private
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
    AddClass(TpFIBDatabase, 'TComponent');
    AddClass(TpFIBDataset, 'TDataSet');
    with AddClass(TfrxFIBDatabase, 'TfrxCustomDatabase') do
      AddProperty('Database', 'TpFIBDatabase', GetProp, nil);
    with AddClass(TfrxFIBQuery, 'TfrxCustomQuery') do
      AddProperty('Query', 'TpFIBDataset', GetProp, nil);
  end;
end;

function TFunctions.GetProp(Instance: TObject; ClassType: TClass;
  const PropName: String): Variant;
begin
  Result := 0;

  if ClassType = TfrxFIBDatabase then
  begin
    if PropName = 'DATABASE' then
      Result := Integer(TfrxFIBDatabase(Instance).Database)
  end
  else if ClassType = TfrxFIBQuery then
  begin
    if PropName = 'QUERY' then
      Result := Integer(TfrxFIBQuery(Instance).Query)
  end
end;


initialization
  fsRTTIModules.Add(TFunctions);

finalization
  fsRTTIModules.Remove(TFunctions);

end.
