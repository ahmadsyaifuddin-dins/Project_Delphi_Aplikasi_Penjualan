
{******************************************}
{                                          }
{             FastReport v4.0              }
{         Exports Registration unit        }
{                                          }
{         Copyright (c) 1998-2006          }
{          by Alexander Fediachov,         }
{             Fast Reports Inc.            }
{                                          }
{******************************************}

unit frxeReg;

{$I frx.inc}

interface


procedure Register;

implementation

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
{$IFNDEF Delphi6}
  DsgnIntf,
{$ELSE}
  DesignIntf, DesignEditors,
{$ENDIF}
  frxExportXML, frxExportHTML, frxExportXLS, frxExportTXT, frxExportImage, 
  frxExportRTF, frxExportPDF, frxExportText, frxExportCSV, frxExportMail,
  frxExportODF;

{-----------------------------------------------------------------------}

procedure Register;
begin
  RegisterComponents('FastReport 4 exports',
    [TfrxPDFExport, TfrxHTMLExport, TfrxXLSExport,
    TfrxXMLExport, TfrxRTFExport, TfrxBMPExport, TfrxJPEGExport,
    TfrxTIFFExport, TfrxGIFExport, TfrxSimpleTextExport, 
    TfrxCSVExport, TfrxMailExport, TfrxTXTExport, TfrxODSExport, TfrxODTExport]);
end;

end.
