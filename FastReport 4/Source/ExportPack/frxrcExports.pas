{******************************************}
{                                          }
{             FastReport v4.0              }
{          Language resource file          }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxrcExports;

interface

implementation

uses frxRes;

const resStr =
'======== TfrxXLSExportDialog ========' + #13#10 +
'8000=Export to Excel' + #13#10 +
'8001=Styles' + #13#10 +
'8002=Pictures' + #13#10 +
'8003=Merge cells' + #13#10 +
'8004=Fast export' + #13#10 +
'8005=WYSIWYG' + #13#10 +
'8006=As text' + #13#10 +
'8007=Background' + #13#10 +
'8008=Open Excel after export' + #13#10 +
'8009=Excel file (*.xls)|*.xls' + #13#10 +
'8010=.xls' + #13#10 +
'' + #13#10 +
'======== TfrxXMLExportDialog ========' + #13#10 +
'8100=Export to Excel' + #13#10 +
'8101=Styles' + #13#10 +
'8102=WYSIWYG' + #13#10 +
'8103=Background' + #13#10 +
'8104=Open Excel after export' + #13#10 +
'8105=XML Excel file (*.xls)|*.xls' + #13#10 +
'8106=.xls' + #13#10 +
'' + #13#10 +
'======== TfrxHTMLExportDialog ========' + #13#10 +
'8200=Export to HTML table' + #13#10 +
'8201=Open after export' + #13#10 +
'8202=Styles' + #13#10 +
'8203=Pictures' + #13#10 +
'8204=All in one folder' + #13#10 +
'8205=Fixed width' + #13#10 +
'8206=Page navigator' + #13#10 +
'8207=Multipage' + #13#10 +
'8208=Mozilla browser' + #13#10 +
'8209=Background' + #13#10 +
'8210=HTML file (*.html)|*.html' + #13#10 +
'8211=.html' + #13#10 +
'' + #13#10 +
'======== TfrxTXTExportDialog ========' + #13#10 +
'8300=Export to text (dot-matrix printer)' + #13#10 +
'8301=Preview on/off' + #13#10 +
'8302= Export properties' + #13#10 +
'8303=Page breaks' + #13#10 +
'8304=OEM codepage' + #13#10 +
'8305=Empty lines' + #13#10 +
'8306=Lead spaces' + #13#10 +
'8307=Page numbers' + #13#10 +
'8308=Enter numbers and/or page ranges, separated by commas. For example: 1,3,5-12' + #13#10 +
'8309= Scaling' + #13#10 +
'8310=X Scale' + #13#10 +
'8311=Y Scale' + #13#10 +
'8312= Frames' + #13#10 +
'8313=None' + #13#10 +
'8314=Simple' + #13#10 +
'8315=Graphic' + #13#10 +
'8316=Only with OEM codepage' + #13#10 +
'8317=Print after export' + #13#10 +
'8318=Save settings' + #13#10 +
'8319= Preview' + #13#10 +
'8320=Width:' + #13#10 +
'8321=Height:' + #13#10 +
'8322=Page' + #13#10 +
'8323=Zoom in' + #13#10 +
'8324=Zoom out' + #13#10 +
'8325=Text file (dot-matrix printer)(*.prn)|*.prn' + #13#10 +
'8326=.prn' + #13#10 +
'' + #13#10 +
'======== TfrxPrnInit ========' + #13#10 +
'8400=Print' + #13#10 +
'8401=Printer' + #13#10 +
'8402=Name' + #13#10 +
'8403=Setup...' + #13#10 +
'8404=Copies' + #13#10 +
'8405=Number of copies' + #13#10 +
'8406= Printer init setup' + #13#10 +
'8407=Printer type' + #13#10 +
'8408=.fpi' + #13#10 +
'8409=Printer init template (*.fpi)|*.fpi' + #13#10 +
'8410=.fpi' + #13#10 +
'8411=Printer init template (*.fpi)|*.fpi' + #13#10 +
'' + #13#10 +
'======== TfrxRTFExportDialog ========' + #13#10 +
'8500=Export to RTF' + #13#10 +
'8501=Pictures' + #13#10 +
'8502=WYSIWYG' + #13#10 +
'8503=Open after export' + #13#10 +
'8504=RTF file (*.rtf)|*.rtf' + #13#10 +
'8505=.rtf' + #13#10 +
'' + #13#10 +
'======== TfrxIMGExportDialog ========' + #13#10 +
'8600=Export Settings' + #13#10 +
'8601= Image settings' + #13#10 +
'8602=JPEG quality' + #13#10 +
'8603=Resolution (dpi)' + #13#10 +
'8604=Separate files' + #13#10 +
'8605=Crop pages' + #13#10 +
'8606=Monochrome' + #13#10 +
'' + #13#10 +
'======== TfrxPDFExportDialog ========' + #13#10 +
'8700=Export to PDF' + #13#10 +
'8701=Compressed' + #13#10 +
'8702=Embedded fonts' + #13#10 +
'8703=Print optimized' + #13#10 +
'8704=Outline' + #13#10 +
'8705=Background' + #13#10 +
'8706=Open after export' + #13#10 +
'8707=Adobe PDF file (*.pdf)|*.pdf' + #13#10 +
'8708=.pdf' + #13#10 +
'' + #13#10 +
'RTFexport=RTF file' + #13#10 +
'BMPexport=BMP image' + #13#10 +
'JPEGexport=JPEG image' + #13#10 +
'TIFFexport=TIFF image' + #13#10 +
'TextExport=Text (matrix printer)' + #13#10 +
'XlsOLEexport=Excel table (OLE)' + #13#10 +
'HTMLexport=HTML file' + #13#10 +
'XlsXMLexport=Excel table (XML)' + #13#10 +
'PDFexport=PDF file' + #13#10 +
'ProgressWait=Please wait' + #13#10 +
'ProgressRows=Setting up rows' + #13#10 +
'ProgressColumns=Setting up columns' + #13#10 +
'ProgressStyles=Setting up styles' + #13#10 +
'ProgressObjects=Exporting objects' + #13#10 +
'TIFFexportFilter=Tiff image (*.tif)|*.tif' + #13#10 +
'BMPexportFilter=BMP image (*.bmp)|*.bmp' + #13#10 +
'JPEGexportFilter=Jpeg image (*.jpg)|*.jpg' + #13#10 +
'HTMLNavFirst=First' + #13#10 +
'HTMLNavPrev=Prev' + #13#10 +
'HTMLNavNext=Next' + #13#10 +
'HTMLNavLast=Last' + #13#10 +
'HTMLNavRefresh=Refresh' + #13#10 +
'HTMLNavPrint=Print' + #13#10 +
'HTMLNavTotal=Total pages' + #13#10 +
'======== TfrxSimpleTextExportDialog ========' + #13#10 +
'8800=Export to Text' + #13#10 +
'8801=Text file (*.txt)|*.txt' + #13#10 +
'8802=.txt' + #13#10 +
'SimpleTextExport=Text file' + #13#10 +
'======== TfrxCSVExportDialog ========' + #13#10 +
'8850=Export to CSV' + #13#10 +
'8851=CSV file (*.csv)|*.csv' + #13#10 +
'8852=.csv' + #13#10 +
'8853=Separator' + #13#10 +
'CSVExport=CSV file' + #13#10 +
'======== TfrxMailExportDialog ========' + #13#10 +
'8900=Send by E-mail' + #13#10 +
'8901=E-mail' + #13#10 +
'8902=Account' + #13#10 +
'8903=Connection' + #13#10 +
'8904=Address' + #13#10 +
'8905=Attachment' + #13#10 +
'8906=Format' + #13#10 +
'8907=From Address' + #13#10 +
'8908=From Name' + #13#10 +
'8909=Host' + #13#10 +
'8910=Login' + #13#10 +
'8911=Mail' + #13#10 +
'8912=Message' + #13#10 +
'8913=Text' + #13#10 +
'8914=Organization' + #13#10 +
'8915=Password' + #13#10 +
'8916=Port' + #13#10 +
'8917=Remember properties' + #13#10 +
'8918=Required fields are Empty' + #13#10 +
'8919=Advanced export settings' + #13#10 +
'8920=Signature' + #13#10 +
'8921=Build' + #13#10 +
'8922=Subject' + #13#10 +
'8923=Best regards' + #13#10 +
'8924=Send mail to' + #13#10 +
'EmailExport=E-mail' + #13#10 +
'FastReportFile=FastReport file' + #13#10 +
'======== TfrxGIFExport ========' + #13#10 +
'GifexportFilter=Gif file (*.gif)|*.gif' + #13#10 +
'GIFexport=Gif image' + #13#10 +
'======== 3.21 ========' + #13#10 +
'8950=Continuous' + #13#10 +
'======== 3.22 ========' + #13#10 +
'8951=Page Header/Footer' + #13#10 +
'8952=Text' + #13#10 +
'8953=Header/Footer' + #13#10 +
'8954=None' + #13#10 +
'ODSExportFilter=Open Document Spreadsheet file (*.ods)|*.ods' + #13#10 +
'ODSExport=Open Document Spreadsheet' + #13#10 +
'ODTExportFilter=Open Document Text file (*.odt)|*.odt' + #13#10 +
'ODTExport=Open Document Text' + #13#10 +
'8960=.ods' + #13#10 +
'8961=.odt' + #13#10 +
'';

initialization
  frxResources.AddStrings(resStr);

end.
