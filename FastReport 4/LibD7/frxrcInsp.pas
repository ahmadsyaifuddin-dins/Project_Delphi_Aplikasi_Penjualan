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

unit frxrcInsp;

interface

implementation

uses frxRes;

const resStr =
'propActive=Specifies if a dataset is open' + #13#10 +
'propActive.TfrxHighlight=Specifies if a highlight is active' + #13#10 +
'propAliasName=The name of the DB alias' + #13#10 +
'propAlign=Determines the alignment of the object relative to band or page' + #13#10 +
'propAlignment=The alignment of the object''s text' + #13#10 +
'propAllowAllUp=Specifies if all speed buttons in the group can be unselected at the same time' + #13#10 +
'propAllowEdit=Determines if the user may edit the prepared report pages' + #13#10 +
'propAllowExpressions=Determines if the text object may contain expressions inside the text' + #13#10 +
'propAllowGrayed=Allows grayed state of the control checkboxes' + #13#10 +
'propAllowHTMLTags=Determines if the text object may contain HTML tags inside the text' + #13#10 +
'propAllowSplit=Determines if the band may split its contents across pages' + #13#10 +
'propAuthor=The author of the report' + #13#10 +
'propAutoSize.TfrxPictureView=Determines if the picture should handle its size automatically' + #13#10 +
'propAutoWidth=Determines if the text object should handle its width automatically' + #13#10 +
'propBackPicture=The background page picture' + #13#10 +
'propBarType=The type of the barcode' + #13#10 +
'propBevelInner=The type of the inner bevel' + #13#10 +
'propBevelOuter=The type of the outer bevel' + #13#10 +
'propBevelWidth=The width of the bevel' + #13#10 +
'propBorder=Determines if outer border is shown' + #13#10 +
'propBorderStyle=The style of the window' + #13#10 +
'propBottomMargin=The size of the bottom page margin' + #13#10 +
'propBrushStyle=The style of the brush used for object''s background' + #13#10 +
'propCalcCheckSum=Determines if the barcode should calculate the checksum digit' + #13#10 +
'propCancel=Determines if the button should be activated when Esc key pressed' + #13#10 +
'propCaption=The caption of the control' + #13#10 +
'propCellFields=Names of DB fields represents the cross cells' + #13#10 +
'propCellLevels=Number of cell levels' + #13#10 +
'propCenter=Determines if the image should be centered inside the control' + #13#10 +
'propCharset=The font charset' + #13#10 +
'propCharSpacing=Amount of pixels between two characters' + #13#10 +
'propCheckColor=The color of the check mark' + #13#10 +
'propChecked=Indicates if the control is checked' + #13#10 +
'propCheckStyle=The style of the check mark' + #13#10 +
'propChild=Child band connected to this band' + #13#10 +
'propClipped=Determines if the text should be clipped inside the objects bounds' + #13#10 +
'propCollate=Default setting of collation' + #13#10 +
'propColor.TFont=The color of the text' + #13#10 +
'propColor=The color of the object' + #13#10 +
'propColor.TfrxFrame=The color of the frame' + #13#10 +
'propColor.TfrxHighlight=Determines the color of the object if highlight is active' + #13#10 +
'propColumnFields=Names of DB fields represents the cross columns' + #13#10 +
'propColumnGap=The gap between band columns' + #13#10 +
'propColumnLevels=Number of column levels' + #13#10 +
'propColumns=Number of columns in the band' + #13#10 +
'propColumnWidth=The width of the band column' + #13#10 +
'propCondition=The grouping condition. The group will break if value of this expression changed' + #13#10 +
'propCondition.TfrxHighlight=Expression string. If this expression is True, the highlight will be active' + #13#10 +
'propConnected=Indicates if the database connection is active' + #13#10 +
'propConvertNulls=Determines if null DB values will converted to 0, False or empty string' + #13#10 +
'propCopies=The default number of copies' + #13#10 +
'propCursor=The cursor of the object' + #13#10 +
'propDatabaseName=The name of the database' + #13#10 +
'propDataField=Specifies the field from which the object gets data' + #13#10 +
'propDataSet=Links the object to the dataset that contains the field it represents' + #13#10 +
'propDate=The date value of the control' + #13#10 +
'propDateFormat=Specifies format in which the date is presented' + #13#10 +
'propDecimalSeparator=The decimal separator' + #13#10 +
'propDefault=Determines if the button is the default button' + #13#10 +
'propDefHeight=Default height of the row' + #13#10 +
'propDescription.TfrxReportOptions=The report description' + #13#10 +
'propDescription=Object''s description' + #13#10 +
'propDiagonal=Indicates that the line is diagonal' + #13#10 +
'propDisplayFormat=The format of the displayed value' + #13#10 +
'propDoublePass=Determines if the report engine should perform the second pass' + #13#10 +
'propDown=Determines if the speed button is pressed or not' + #13#10 +
'propDownThenAcross=Determines how a large cross table will be split across pages' + #13#10 +
'propDriverName=The name of the BDE driver' + #13#10 +
'propDropShadow=Determines if the objects has a shadow' + #13#10 +
'propDuplex=Specifies the duplex mode for the page' + #13#10 +
'propEditMask=Specifies the mask that represents what text is valid for the masked edit control' + #13#10 +
'propEnabled=Determines if the control is enabled' + #13#10 +
'propEngineOptions=The engine options of the report' + #13#10 +
'propExpression=Value of this expression will be shown in the object' + #13#10 +
'propExpressionDelimiters=The characters that will be used for enclosing the expressions contained in the text' + #13#10 +
'propFieldAliases=The dataset field''s aliases' + #13#10 +
'propFilter=The filtering condition for the dataset' + #13#10 +
'propFiltered=Determines if the dataset should filter the records using the condition in the Filter property' + #13#10 +
'propFlowTo=The text object that will show the text that not fit in the object' + #13#10 +
'propFont=The font attributes of the object' + #13#10 +
'propFooterAfterEach=Determines if the footer band should be shown after each data row' + #13#10 +
'propFormatStr=The formatting string' + #13#10 +
'propFrame=The frame attributes of the object' + #13#10 +
'propGapX=The left indent of the text' + #13#10 +
'propGapY=The top indent of the text' + #13#10 +
'propGlyph=The image of the control' + #13#10 +
'propGroupIndex=Allows speed buttons to work together as a group' + #13#10 +
'propHAlign=The horizontal alignment of the text' + #13#10 +
'propHeight=The height of the object' + #13#10 +
'propHideZeros=Determines if the text object will hide the zero values' + #13#10 +
'propHighlight=The conditional highlight attributes' + #13#10 +
'propIndexName=The name of the index' + #13#10 +
'propInitString=Printer init string for dot-matrix reports' + #13#10 +
'propItems=List items of the object' + #13#10 +
'propKeepAspectRatio=Keep the original aspect ratio of the image' + #13#10 +
'propKeepChild=Determines if the band will be printed together with its child' + #13#10 +
'propKeepFooter=Determines if the band will be printed together with its footer' + #13#10 +
'propKeepHeader=Determines if the band will be printed together with its header' + #13#10 +
'propKeepTogether=Determines if the band will be printed together with all its subbands' + #13#10 +
'propKind.TfrxFormat=The kind of formatting' + #13#10 +
'propKind=The kind of the button' + #13#10 +
'propLargeDesignHeight=Determines if the page will have large height in the design mode' + #13#10 +
'propLayout=The layout of the button glyph' + #13#10 +
'propLeft=The left coordinate of the object' + #13#10 +
'propLeftMargin=The size of the left page margin' + #13#10 +
'propLines=The text of the object' + #13#10 +
'propLineSpacing=The amount of pixels between two lines of text' + #13#10 +
'propLoginPrompt=Determines if to show the login dialog' + #13#10 +
'propMargin=Determines the number of pixels between the edge of the image and the edge of the button' + #13#10 +
'propMaster=The master dataset' + #13#10 +
'propMasterFields=The fields linked by master-detail relationship' + #13#10 +
'propMaxLength=Max length of the text' + #13#10 +
'propMaxWidth=Max width of the column' + #13#10 +
'propMemo=The text of the object' + #13#10 +
'propMinWidth=Min width of the column' + #13#10 +
'propMirrorMargins=Mirror the page margins on the even pages' + #13#10 +
'propModalResult=Determines if and how the button closes its modal form' + #13#10 +
'propName.TFont=The name of the font' + #13#10 +
'propName.TfrxReportOptions=The name of the report' + #13#10 +
'propName=The name of the object' + #13#10 +
'propNumGlyphs=Indicates the number of images that are in the graphic specified in the Glyph property' + #13#10 +
'propOpenDataSource=Determines if to open datasource automatically or not' + #13#10 +
'propOrientation=The orientation of the page' + #13#10 +
'propOutlineText=The text that will be shown in the preview outline control' + #13#10 +
'propOutlineVisible=The visibility of the preview outline control' + #13#10 +
'propOutlineWidth=The width of the preview outline control' + #13#10 +
'propPageNumbers.TfrxPrintOptions=The numbers of the pages to be printed' + #13#10 +
'propPaperHeight=The height of the page' + #13#10 +
'propPaperWidth=The width of the page' + #13#10 +
'propParagraphGap=The indent of the first line of paragraph' + #13#10 +
'propParams.TfrxBDEDatabase=The parameters of the connection' + #13#10 +
'propParams=The parameters of the query' + #13#10 +
'propParentFont=Determines if the object will use parent''s font' + #13#10 +
'propPassword=The report password' + #13#10 +
'propPasswordChar=Indicates the character, if any, to display in place of the actual characters typed in the control' + #13#10 +
'propPicture=The picture' + #13#10 +
'propPicture.TfrxReportOptions=The description picture of the report' + #13#10 +
'propPosition=The initial position of the window' + #13#10 +
'propPreviewOptions=The preview options of the report' + #13#10 +
'propPrintable=Printability of the object. Objects with the Printable=False will be previewed, but not printed' + #13#10 +
'propPrintChildIfInvisible=Determines if the child band will be printed if its parent band is invisible' + #13#10 +
'propPrinter=The name of the printer that will be selected when open or run this report' + #13#10 +
'propPrintIfDetailEmpty=Determines if the databand will be printed if its subband is empty' + #13#10 +
'propPrintIfEmpty=Determines if the page will be printed if all its datasets are empty' + #13#10 +
'propPrintOnFirstPage=Determines if the band will be printed on the first page' + #13#10 +
'propPrintOnLastPage=Determines if the band will be printed on the last page' + #13#10 +
'propPrintOnParent=Determines if the subreport can print itself on parent band' + #13#10 +
'propPrintOnPreviousPage=Determines if the page can be generated on the free space of previously generated page' + #13#10 +
'propPrintOptions=Print options of the report' + #13#10 +
'propPrintPages=Determines if to print all, odd or even pages' + #13#10 +
'propRangeBegin=Determines the start point of dataset navigation' + #13#10 +
'propRangeEnd=Determines the end point of dataset navigation' + #13#10 +
'propRangeEndCount=Determines the number of records in the dataset if RangeEnd is reCount' + #13#10 +
'propReadOnly=Determines if the text object is read-only' + #13#10 +
'propRepeatHeaders=Determines if the column and row headers will be reprinted on new page' + #13#10 +
'propReportOptions=The options of the report' + #13#10 +
'propReprintOnNewPage=Determines if the band will be reprinted on new page' + #13#10 +
'propRestrictions=Set of restriction flags' + #13#10 +
'propRightMargin=The size of the right page margin' + #13#10 +
'propRotation.TfrxBarCodeView=The orientation of the barcode' + #13#10 +
'propRotation=The text rotation' + #13#10 +
'propRowCount=Number of virtual records in the databand' + #13#10 +
'propRowFields=Names of DB fields represents the cross rows' + #13#10 +
'propRowLevels=Number of row levels' + #13#10 +
'propRTLReading=Determines if the text object will show its text in right-to-left direction' + #13#10 +
'propSessionName=The name of the BDE session' + #13#10 +
'propShadowColor=The color of the shadow' + #13#10 +
'propShadowWidth=The width of the shadow' + #13#10 +
'propShape=The type of the shape' + #13#10 +
'propShiftMode=Shift behavior of the object' + #13#10 +
'propShowColumnHeader=Determines if the cross will show column headers' + #13#10 +
'propShowColumnTotal=Determines if the cross will show column grand total' + #13#10 +
'propShowRowHeader=Determines if the cross will show row headers' + #13#10 +
'propShowRowTotal=Determines if the cross will show row grand total' + #13#10 +
'propShowDialog=Determines if the print dialog will be shown in the preview window' + #13#10 +
'propShowText=Determines if the barcode object will show a readable text' + #13#10 +
'propSize=The size of the font' + #13#10 +
'propSorted=Determines if the items are sorted or not' + #13#10 +
'propSpacing=Determines the number of pixels between the image and the text' + #13#10 +
'propSQL=The SQL statement' + #13#10 +
'propStartNewPage=Starts a new page before printing a band' + #13#10 +
'propStretch=Stretches the picture to fit the object bounds' + #13#10 +
'propStretched=Determines if the object can be stretched' + #13#10 +
'propStretchMode=Stretch behavior of the object' + #13#10 +
'propStyle.TFont=The style of the font' + #13#10 +
'propStyle=The style of the control' + #13#10 +
'propStyle.TfrxFrame=The style of the object''s frame' + #13#10 +
'propSuppressRepeated=Suppresses repeated values' + #13#10 +
'propTableName=The name of the data table' + #13#10 +
'propTag=Tag number of the object' + #13#10 +
'propTagStr=Tag string of the object' + #13#10 +
'propText=The text of the object' + #13#10 +
'propTitleBeforeHeader=Determines if report title shown before page header' + #13#10 +
'propTop=The top coordinate of the object' + #13#10 +
'propTopMargin=The size of the top page margin' + #13#10 +
'propTyp=The type of the frame' + #13#10 +
'propUnderlines=Determines if the text object will show under lines after each text line' + #13#10 +
'propURL=The URL of the object' + #13#10 +
'propUserName=User name of the data object. This name will be shown in the data tree' + #13#10 +
'propVAlign=The vertical alignment of the text' + #13#10 +
'propVersionBuild=Version info, build' + #13#10 +
'propVersionMajor=Version info, major version' + #13#10 +
'propVersionMinor=Version info, minor version' + #13#10 +
'propVersionRelease=Version info, release' + #13#10 +
'propVisible=Visibility of the object' + #13#10 +
'propWidth=Width of the object' + #13#10 +
'propWidth.TfrxFrame=The width of the frame' + #13#10 +
'propWindowState=Initial state of the window' + #13#10 +
'propWordBreak=Break russian words' + #13#10 +
'propWordWrap=Determines if the text object inserts soft carriage returns so text wraps at the right margin' + #13#10 +
'propZoom.TfrxBarCodeView=Zooms the barcode' + #13#10 +
'propConnectionName=Name of the connection to the database used in the report' + #13#10 +
'propCurve=Curvature of the roundrectangle edges' + #13#10 +
'propDrillDown=Determines if the group can be drilled down' + #13#10 +
'propFontStyle=Dot-matrix font style' + #13#10 +
'propHideIfSingleDataRecord=Hide the footer if a group has only one data record' + #13#10 +
'propOutlineExpand=Determines if the report outline expands or not' + #13#10 +
'propPlainCells=Determines whether to print several cells side-by-side or stacked' + #13#10 +
'propPrintMode=Print mode: normal, split big pages to small one, or print several small pages on a big one' + #13#10 +
'propPrintOnSheet=Paper size to print report on. Used if PrintMode is not pmDefault' + #13#10 +
'propResetPageNumbers=Reset page number/total pages numbers when print a group. Should be used with StartNewPage option set to true' + #13#10 +
'propReverse=Determines if pages print in reverse order' + #13#10 +
'propShowFooterIfDrillDown=Determines if group footer is shown if group is drilldown' + #13#10 +
'propSizeMode=Display mode of the OLE object' + #13#10 +
'propVersion=Version of the FastReport' + #13#10 +
'propWideBarRatio=Relative with of wide bars of the barcode' + #13#10 +
'propWysiwyg=Determines if the object should use the printer canvas to format the text. A printer should be installed and ready.' + #13#10 +
'propArrowEnd=Determines if an arrow is shown at end of a line' + #13#10 +
'propArrowLength=Length of the arrow' + #13#10 +
'propArrowSolid=Determines if arrow has solid-fill' + #13#10 +
'propArrowStart=Determines if an arrow is shown at the start of a line' + #13#10 +
'propArrowWidth=Width of the arrow' + #13#10 +
'propCloseDataSource=Determines whether to close the dataset when report is finished' + #13#10 +
'propDatabase=Database connection' + #13#10 +
'propIndexFieldNames=Names of index fields' + #13#10 +
'propCommandTimeOut=Amount of time needed to execute a query' + #13#10 +
'propExpandDrillDown=Determines if all drill-down elements are expanded at first start of a report' + #13#10 +
'propWysiwyg.TfrxMemoView=Determines if text is displayed in WYSIWYG mode' + #13#10 +
'propLeftLine=Left line of a frame' + #13#10 +
'propTopLine=Top line of a frame' + #13#10 +
'propRightLine=Right line of a frame' + #13#10 +
'propBottomLine=Bottom line of a frame' + #13#10 +
'propColor.TfrxFrameLine=The color of the frame line' + #13#10 +
'propStyle.TfrxFrameLine=The style of the frame line' + #13#10 +
'propWidth.TfrxFrameLine=The width of the frame line' + #13#10 +
'propFileLink=Expression or name of the file containing a picture' + #13#10 +
'propEndlessWidth=Endless page mode. If true, page will grow depending on number of data records on it' + #13#10 +
'propEndlessHeight=Endless page mode. If true, page will grow depending on number of data records on it' + #13#10 +
'propAddHeight=Adds specified amount of space to the cell height' + #13#10 +
'propAddWidth=Adds specified amount of space to the cell width' + #13#10 +
'propAllowDuplicates=Determines if the cell can accept duplicate string values' + #13#10 +
'propJoinEqualCells=Determines if the crosstab should join cells with equal values' + #13#10 +
'propNextCross=Pointer to the next crosstab that will be displayed side-by-side' + #13#10 +
'propNextCrossGap=Gap between side-by-side crosstabs' + #13#10 +
'propShowCorner=Determines if the crosstab should display a left-top corner elements' + #13#10 +
'propSuppressNullRecords=!Determines if the crosstab should suppress records with all NULL values' + #13#10 +
'propShowTitle=!Determines if the crosstab should display a title' + #13#10 +
'propAutoSize=!Determines if the crosstab should handle its size automatically' + #13#10 +
'';

initialization
  frxResources.AddStrings(resStr);

end.


//0f31356a91fea3356e5f76cdce90aa7b