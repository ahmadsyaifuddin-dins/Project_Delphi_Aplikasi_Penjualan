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

unit frxrcClass;

interface

implementation

uses frxRes;

const resStr =
'1=OK' + #13#10 +
'2=Cancel' + #13#10 +
'3=All' + #13#10 +
'4=Current page' + #13#10 +
'5=Pages:' + #13#10 +
'6=Page breaks' + #13#10 +
'7=Page range' + #13#10 +
'8=Export settings' + #13#10 +
'9=Enter page numbers and/or page ranges, separated by commas. For example, 1,3,5-12' + #13#10 +
'======== TfrxPreviewForm ========' + #13#10 +
'100=Preview' + #13#10 +
'101=Print' + #13#10 +
'102=Print' + #13#10 +
'103=Open' + #13#10 +
'104=Open' + #13#10 +
'105=Save' + #13#10 +
'106=Save' + #13#10 +
'107=Export' + #13#10 +
'108=Export' + #13#10 +
'109=Find' + #13#10 +
'110=Find' + #13#10 +
'111=Whole Page' + #13#10 +
'112=Whole Page' + #13#10 +
'113=Page Width' + #13#10 +
'114=Page Width' + #13#10 +
'115=100%' + #13#10 +
'116=100%' + #13#10 +
'117=Two Pages' + #13#10 +
'118=Two Pages' + #13#10 +
'119=Zoom' + #13#10 +
'120=Page Settings' + #13#10 +
'121=Page Settings' + #13#10 +
'122=Outline' + #13#10 +
'123=Outline' + #13#10 +
'124=Zoom In' + #13#10 +
'125=Zoom In' + #13#10 +
'126=Zoom Out' + #13#10 +
'127=Zoom Out' + #13#10 +
'128=Outline' + #13#10 +
'129=Report outline' + #13#10 +
'130=Thumbnails' + #13#10 +
'131=Thumbnails' + #13#10 +
'132=Edit' + #13#10 +
'133=Edit Page' + #13#10 +
'134=First' + #13#10 +
'135=First Page' + #13#10 +
'136=Prior' + #13#10 +
'137=Prior Page' + #13#10 +
'138=Next' + #13#10 +
'139=Next Page' + #13#10 +
'140=Last' + #13#10 +
'141=Last Page' + #13#10 +
'142=Page Number' + #13#10 +
'' + #13#10 +
'150=Full Screen' + #13#10 +
'151=Export to PDF' + #13#10 +
'152=Send by E-mail' + #13#10 +
'zmPageWidth=Page width' + #13#10 +
'zmWholePage=Whole page' + #13#10 +
'======== TfrxPrintDialog ========' + #13#10 +
'200=Print' + #13#10 +
'201=Printer' + #13#10 +
'202=Pages' + #13#10 +
'203=Number of copies' + #13#10 +
'204=Collate' + #13#10 +
'205=Copies' + #13#10 +
'206=Print' + #13#10 +
'207=!Other' + #13#10 +
'208=Where:' + #13#10 +
'209=Properties...' + #13#10 +
'210=Print to file' + #13#10 +
'211=!Order' + #13#10 +
'212=Name:' + #13#10 +
'213=Print mode' + #13#10 +
'214=Print on sheet' + #13#10 +
'216=Duplex' + #13#10 +
'' + #13#10 +
'ppAll=All pages' + #13#10 +
'ppOdd=Odd pages' + #13#10 +
'ppEven=Even pages' + #13#10 +
'pgDefault=Default' + #13#10 +
'pmDefault=Default' + #13#10 +
'pmSplit=Split big pages' + #13#10 +
'pmJoin=Join small pages' + #13#10 +
'pmScale=Scale' + #13#10 +
'poDirect=!Direct (1-9)' + #13#10 +
'poReverse=!Reverse (9-1)' + #13#10 +
'======== TfrxSearchDialog ========' + #13#10 +
'300=Find Text' + #13#10 +
'301=Text to find:' + #13#10 +
'302=Search options' + #13#10 +
'303=Replace with' + #13#10 +
'304=Search from beginning' + #13#10 +
'305=Case sensitive' + #13#10 +
'' + #13#10 +
'======== TfrxPageSettingsForm ========' + #13#10 +
'400=Page Settings' + #13#10 +
'401=Width' + #13#10 +
'402=Height' + #13#10 +
'403=Size' + #13#10 +
'404=Orientation' + #13#10 +
'405=Left' + #13#10 +
'406=Top' + #13#10 +
'407=Right' + #13#10 +
'408=Bottom' + #13#10 +
'409=Margins' + #13#10 +
'410=Portrait' + #13#10 +
'411=Landscape' + #13#10 +
'412=Other' + #13#10 +
'413=Apply to the current page' + #13#10 +
'414=Apply to all pages' + #13#10 +
'' + #13#10 +
'======== TfrxDMPExportDialog ========' + #13#10 +
'500=Print' + #13#10 +
'501=Printer' + #13#10 +
'502=Pages' + #13#10 +
'503=Copies' + #13#10 +
'504=Number of copies' + #13#10 +
'505=Options' + #13#10 +
'506=Escape commands' + #13#10 +
'507=Print to file' + #13#10 +
'508=OEM codepage' + #13#10 +
'509=Pseudographic' + #13#10 +
'510=Printer file (*.prn)|*.prn' + #13#10 +
'' + #13#10 +
'======== TfrxProgress ========' + #13#10 +
'' + #13#10 +
'mbConfirm=Confirm' + #13#10 +
'mbError=Error' + #13#10 +
'mbInfo=Information' + #13#10 +
'xrCantFindClass=Cannot find class' + #13#10 +
'prVirtual=Virtual' + #13#10 +
'prDefault=Default' + #13#10 +
'prCustom=Custom' + #13#10 +
'enUnconnHeader=Unconnected header/footer' + #13#10 +
'enUnconnGroup=No data band for the group' + #13#10 +
'enUnconnGFooter=No group header for' + #13#10 +
'enBandPos=Incorrect band position:' + #13#10 +
'dbNotConn=DataSet %s is not connected to data' + #13#10 +
'dbFldNotFound=Field not found:' + #13#10 +
'clDSNotIncl=(dataset is not included in Report.DataSets)' + #13#10 +
'clUnknownVar=Unknown variable or datafield:' + #13#10 +
'clScrError=Script error at %s: %s' + #13#10 +
'clDSNotExist=Dataset "%s" does not exist' + #13#10 +
'clErrors=The following error(s) have occured:' + #13#10 +
'clExprError=Error in expression' + #13#10 +
'clFP3files=Prepared Report' + #13#10 +
'clSaving=Saving file...' + #13#10 +
'clCancel=Cancel' + #13#10 +
'clClose=Close' + #13#10 +
'clPrinting=Printing page' + #13#10 +
'clLoading=Loading file...' + #13#10 +
'clPageOf=Page %d of %d' + #13#10 +
'clFirstPass=First pass: page' + #13#10 +
'clNoPrinters=No printers installed on your system' + #13#10 +
'clDecompressError=Stream decompress error' + #13#10 +
'crFillMx=Filling the cross-tab...' + #13#10 +
'crBuildMx=Building the cross-tab...' + #13#10 +
'prRunningFirst=First pass: page %d' + #13#10 +
'prRunning=Preparing page %d' + #13#10 +
'prPrinting=Printing page %d' + #13#10 +
'prExporting=Exporting page %d' + #13#10 +
'uCm=cm' + #13#10 +
'uInch=in' + #13#10 +
'uPix=px' + #13#10 +
'uChar=chr' + #13#10 +
'dupDefault=Default' + #13#10 +
'dupVert=Vertical' + #13#10 +
'dupHorz=Horizontal' + #13#10 +
'dupSimpl=Simplex' + #13#10 +
'' + #13#10 +
'=========== FS strings ===============' + #13#10 +
'SLangNotFound=Language ''%s'' not found' + #13#10 +
'SInvalidLanguage=Invalid language definition' + #13#10 +
'SIdRedeclared=Identifier redeclared:' + #13#10 +
'SUnknownType=Unknown type:' + #13#10 +
'SIncompatibleTypes=Incompatible types' + #13#10 +
'SIdUndeclared=Undeclared identifier:' + #13#10 +
'SClassRequired=Class type required' + #13#10 +
'SIndexRequired=Index required' + #13#10 +
'SStringError=Strings do not have properties or methods' + #13#10 +
'SClassError=Class %s does not have a default property' + #13#10 +
'SArrayRequired=Array type required' + #13#10 +
'SVarRequired=Variable required' + #13#10 +
'SNotEnoughParams=Not enough actual parameters' + #13#10 +
'STooManyParams=Too many actual parameters' + #13#10 +
'SLeftCantAssigned=Left side cannot be assigned to' + #13#10 +
'SForError=For loop variable must be numeric variable' + #13#10 +
'SEventError=Event handler must be a procedure' + #13#10 +
'======== TfrxPreviewOutlineForm ========' + #13#10 +
'600=Expand all' + #13#10 +
'601=Collapse all' + #13#10 +
'';

initialization
  frxResources.AddStrings(resStr);

end.


//0f31356a91fea3356e5f76cdce90aa7b