
{******************************************}
{                                          }
{             FastReport v4.0              }
{              CheckBox RTTI               }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxChBoxRTTI;

interface

{$I frx.inc}

implementation

uses
  Windows, Classes, SysUtils, Forms, fs_iinterpreter, frxChBox, frxClassRTTI
{$IFDEF Delphi6}
, Variants
{$ENDIF};
  

type
  TFunctions = class(TfsRTTIModule)
  public
    constructor Create(AScript: TfsScript); override;
  end;


{ TFunctions }

constructor TFunctions.Create(AScript: TfsScript);
begin
  inherited Create(AScript);
  with AScript do
  begin
    AddEnum('TfrxCheckStyle', 'csCross, csCheck, csLineCross, csPlus');
    AddEnum('TfrxUncheckStyle', 'usEmpty, usCross, usLineCross, usMinus');
    AddClass(TfrxCheckBoxView, 'TfrxView');
  end;
end;


initialization
  fsRTTIModules.Add(TFunctions);

end.



//0f31356a91fea3356e5f76cdce90aa7b