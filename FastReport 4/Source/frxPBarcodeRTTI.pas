
{******************************************}
{                                          }
{             FastReport v4.0              }
{            PSOFT Barcode RTTI            }
{           http://www.psoft.sk            }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxPBarcodeRTTI;

interface

{$I frx.inc}

implementation

uses
  Windows, Classes, SysUtils, Forms, fs_iinterpreter, frxPBarcode, frxClassRTTI
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
    AddEnum('TTypBarCode',
      'bcEan8, bcEan13, bcCodabar, bcCode39Standard, bcCode39Full, bcCode93Standard, ' +
      'bcCode93Full, bcCode128, bcABCCodabar, bc25Datalogic, bc25Interleaved, ' +
      'bc25Matrix, bc25Industrial, bc25IATA, bc25Invert, bc25Coop, bcITF, bcISBN, ' +
      'bcISSN, bcISMN, bcUPCA, bcUPCE0, bcUPCE1, bcUPCShipping, bcJAN8, bcJAN13, ' +
      'bcMSIPlessey, bcPostNet, bcOPC, bcEan128, bcCode11, bcPZN, bcPDF417');
    AddClass(TfrxPBarcodeView, 'TfrxView');
  end;
end;


initialization
  fsRTTIModules.Add(TFunctions);

end.


//0f31356a91fea3356e5f76cdce90aa7b