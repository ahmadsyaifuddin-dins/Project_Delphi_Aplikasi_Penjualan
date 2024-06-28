
{******************************************}
{                                          }
{             FastReport v4.0              }
{              Barcode RTTI                }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxBarcodeRTTI;

interface

{$I frx.inc}

implementation

uses
  Windows, Classes, SysUtils, Forms, fs_iinterpreter, frxBarcode, frxClassRTTI
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
    AddEnum('TfrxBarcodeType', 'bcCode_2_5_interleaved, bcCode_2_5_industrial,' +
      'bcCode_2_5_matrix, bcCode39, bcCode39Extended, bcCode128A, bcCode128B,' +
      'bcCode128C, bcCode93, bcCode93Extended, bcCodeMSI, bcCodePostNet,' +
      'bcCodeCodabar, bcCodeEAN8, bcCodeEAN13, bcCodeUPC_A, bcCodeUPC_E0,' +
      'bcCodeUPC_E1, bcCodeUPC_Supp2, bcCodeUPC_Supp5, bcCodeEAN128A,' +
      'bcCodeEAN128B, bcCodeEAN128C');
    AddClass(TfrxBarcodeView, 'TfrxView');
  end;
end;


initialization
  fsRTTIModules.Add(TFunctions);

end.



//0f31356a91fea3356e5f76cdce90aa7b