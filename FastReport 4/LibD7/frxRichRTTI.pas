
{******************************************}
{                                          }
{             FastReport v4.0              }
{                Rich RTTI                 }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxRichRTTI;

interface

{$I frx.inc}

implementation

uses
  Windows, Classes, SysUtils, Forms, fs_iinterpreter, fs_iformsrtti, frxRich,
  frxRichEdit, frxClassRTTI
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
    AddClass(TrxRichEdit, 'TWinControl');
    with AddClass(TfrxRichView, 'TfrxView') do
      AddProperty('RichEdit', 'TrxRichEdit', GetProp, nil);
  end;
end;

function TFunctions.GetProp(Instance: TObject; ClassType: TClass;
  const PropName: String): Variant;
begin
  Result := 0;

  if ClassType = TfrxRichView then
  begin
    if PropName = 'RICHEDIT' then
      Result := Integer(TfrxRichView(Instance).RichEdit)
  end
end;


initialization
  fsRTTIModules.Add(TFunctions);

end.


//0f31356a91fea3356e5f76cdce90aa7b