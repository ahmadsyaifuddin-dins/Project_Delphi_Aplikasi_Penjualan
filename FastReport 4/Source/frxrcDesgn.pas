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

unit frxrcDesgn;

interface

implementation

uses frxRes;

const resStr =
'======== TfrxObjectInspector ========' + #13#10 +
'2000=Object Inspector' + #13#10 +
'' + #13#10 +
'oiProp=Properties' + #13#10 +
'oiEvent=Events' + #13#10 +
'======== TfrxDataTreeForm ========' + #13#10 +
'2100=Data Tree' + #13#10 +
'2101=Data' + #13#10 +
'2102=Variables' + #13#10 +
'2103=Functions' + #13#10 +
'2104=Create field' + #13#10 +
'2105=Create caption' + #13#10 +
'2106=Classes' + #13#10 +
'' + #13#10 +
'dtNoData=No data available' + #13#10 +
'dtNoData1=Go "Report|Data..." menu to add an existing datasets to your report, or switch to "Data" tab and create new datasets.' + #13#10 +
'dtData=Data' + #13#10 +
'dtSysVar=System variables' + #13#10 +
'dtVar=Variables' + #13#10 +
'dtFunc=Functions' + #13#10 +
'======== TfrxReportTreeForm ========' + #13#10 +
'2200=Report Tree' + #13#10 +
'' + #13#10 +
'======== TfrxDesignerForm ========' + #13#10 +
'2300=Open Script File' + #13#10 +
'2301=Save Script to File' + #13#10 +
'2302=Run Script' + #13#10 +
'2303=Trace Into' + #13#10 +
'2304=Terminate Script' + #13#10 +
'2305=Evaluate' + #13#10 +
'2306=Language:' + #13#10 +
'2307=Align' + #13#10 +
'2308=Align Left' + #13#10 +
'2309=Align Middle' + #13#10 +
'2310=Align Right' + #13#10 +
'2311=Align Top' + #13#10 +
'2312=Align Center' + #13#10 +
'2313=Align Bottom' + #13#10 +
'2314=Space Horizontally' + #13#10 +
'2315=Space Vertically' + #13#10 +
'2316=Center Horizontally in Band' + #13#10 +
'2317=Center Vertically in Band' + #13#10 +
'2318=Same Width' + #13#10 +
'2319=Same Height' + #13#10 +
'2320=Text' + #13#10 +
'2321=Style' + #13#10 +
'2322=Font Name' + #13#10 +
'2323=Font Size' + #13#10 +
'2324=Bold' + #13#10 +
'2325=Italic' + #13#10 +
'2326=Underline' + #13#10 +
'2327=Font Color' + #13#10 +
'2328=Highlight' + #13#10 +
'2329=Text Rotation' + #13#10 +
'2330=Align Left' + #13#10 +
'2331=Align Center' + #13#10 +
'2332=Align Right' + #13#10 +
'2333=Justify' + #13#10 +
'2334=Align Top' + #13#10 +
'2335=Align Middle' + #13#10 +
'2336=Align Bottom' + #13#10 +
'2337=Frame' + #13#10 +
'2338=Top Line' + #13#10 +
'2339=Bottom Line' + #13#10 +
'2340=Left Line' + #13#10 +
'2341=Right Line' + #13#10 +
'2342=All Frame Lines' + #13#10 +
'2343=No Frame' + #13#10 +
'2344=Shadow' + #13#10 +
'2345=Background Color' + #13#10 +
'2346=Frame Color' + #13#10 +
'2347=Frame Style' + #13#10 +
'2348=Frame Width' + #13#10 +
'2349=Standard' + #13#10 +
'2350=New Report' + #13#10 +
'2351=Open Report' + #13#10 +
'2352=Save Report' + #13#10 +
'2353=Preview' + #13#10 +
'2354=New Report Page' + #13#10 +
'2355=New Dialog Page' + #13#10 +
'2356=Delete Page' + #13#10 +
'2357=Page Settings' + #13#10 +
'2358=Variables' + #13#10 +
'2359=Cut' + #13#10 +
'2360=Copy' + #13#10 +
'2361=Paste' + #13#10 +
'2362=Copy Formatting' + #13#10 +
'2363=Undo' + #13#10 +
'2364=Redo' + #13#10 +
'2365=Group' + #13#10 +
'2366=Ungroup' + #13#10 +
'2367=Show Grid' + #13#10 +
'2368=Align to Grid' + #13#10 +
'2369=Fit to Grid' + #13#10 +
'2370=Zoom' + #13#10 +
'2371=Extra Tools' + #13#10 +
'2372=Select Tool' + #13#10 +
'2373=Hand Tool' + #13#10 +
'2374=Zoom Tool' + #13#10 +
'2375=Edit Text Tool' + #13#10 +
'2376=Copy Format Tool' + #13#10 +
'2377=Insert Band' + #13#10 +
'2378=&File' + #13#10 +
'2379=&Edit' + #13#10 +
'2380=Find...' + #13#10 +
'2381=Find Next' + #13#10 +
'2382=Replace...' + #13#10 +
'2383=&Report' + #13#10 +
'2384=Data...' + #13#10 +
'2385=Options...' + #13#10 +
'2386=Styles...' + #13#10 +
'2387=&View' + #13#10 +
'2388=Toolbars' + #13#10 +
'2389=Standard' + #13#10 +
'2390=Text' + #13#10 +
'2391=Frame' + #13#10 +
'2392=Alignment Palette' + #13#10 +
'2393=Extra Tools' + #13#10 +
'2394=Object Inspector' + #13#10 +
'2395=Data Tree' + #13#10 +
'2396=Report Tree' + #13#10 +
'2397=Rulers' + #13#10 +
'2398=Guides' + #13#10 +
'2399=Delete Guides' + #13#10 +
'2400=Options...' + #13#10 +
'2401=&Help' + #13#10 +
'2402=Help Contents...' + #13#10 +
'2403=About FastReport...' + #13#10 +
'2404=Tab Order...' + #13#10 +
'2405=Undo' + #13#10 +
'2406=Redo' + #13#10 +
'2407=Cut' + #13#10 +
'2408=Copy' + #13#10 +
'2409=Paste' + #13#10 +
'2410=Group' + #13#10 +
'2411=Ungroup' + #13#10 +
'2412=Delete' + #13#10 +
'2413=Delete Page' + #13#10 +
'2414=Select All' + #13#10 +
'2415=Edit...' + #13#10 +
'2416=Bring to Front' + #13#10 +
'2417=Send to Back' + #13#10 +
'2418=New...' + #13#10 +
'2419=New Report' + #13#10 +
'2420=New Page' + #13#10 +
'2421=New Dialog' + #13#10 +
'2422=Open...' + #13#10 +
'2423=Save' + #13#10 +
'2424=Save As...' + #13#10 +
'2425=Variables...' + #13#10 +
'2426=Page Settings...' + #13#10 +
'2427=Preview' + #13#10 +
'2428=Exit' + #13#10 +
'2429=Report Title' + #13#10 +
'2430=Report Summary' + #13#10 +
'2431=Page Header' + #13#10 +
'2432=Page Footer' + #13#10 +
'2433=Header' + #13#10 +
'2434=Footer' + #13#10 +
'2435=Master Data' + #13#10 +
'2436=Detail Data' + #13#10 +
'2437=Subdetail Data' + #13#10 +
'2438=Data 4th level' + #13#10 +
'2439=Data 5th level' + #13#10 +
'2440=Data 6th level' + #13#10 +
'2441=Group Header' + #13#10 +
'2442=Group Footer' + #13#10 +
'2443=Child' + #13#10 +
'2444=Column Header' + #13#10 +
'2445=Column Footer' + #13#10 +
'2446=Overlay' + #13#10 +
'2447=Vertical bands' + #13#10 +
'2448=Header' + #13#10 +
'2449=Footer' + #13#10 +
'2450=Master Data' + #13#10 +
'2451=Detail Data' + #13#10 +
'2452=Subdetail Data' + #13#10 +
'2453=Group Header' + #13#10 +
'2454=Group Footer' + #13#10 +
'2455=Child' + #13#10 +
'2456=0°' + #13#10 +
'2457=45°' + #13#10 +
'2458=90°' + #13#10 +
'2459=180°' + #13#10 +
'2460=270°' + #13#10 +
'2461=Font Settings' + #13#10 +
'2462=Bold' + #13#10 +
'2463=Italic' + #13#10 +
'2464=Underline' + #13#10 +
'2465=SuperScript' + #13#10 +
'2466=SubScript' + #13#10 +
'2467=Condensed' + #13#10 +
'2468=Wide' + #13#10 +
'2469=12 cpi' + #13#10 +
'2470=15 cpi' + #13#10 +
'2471=Report (*.fr3)|*.fr3' + #13#10 +
'2472=Pascal files (*.pas)|*.pas|C++ files (*.cpp)|*.cpp|JavaScript files (*.js)|*.js|Basic files (*.vb)|*.vb|All files|*.*' + #13#10 +
'2473=Pascal files (*.pas)|*.pas|C++ files (*.cpp)|*.cpp|JavaScript files (*.js)|*.js|Basic files (*.vb)|*.vb|All files|*.*' + #13#10 +
'2474=Connections...' + #13#10 +
'' + #13#10 +
'2475=Language' + #13#10 +
'2476=Toggle breakpoint' + #13#10 +
'2477=Run to cursor' + #13#10 +
'2478=!Add child band' + #13#10 +
'dsCm=Centimeters' + #13#10 +
'dsInch=Inches' + #13#10 +
'dsPix=Pixels' + #13#10 +
'dsChars=Characters' + #13#10 +
'dsCode=Code' + #13#10 +
'dsData=Data' + #13#10 +
'dsPage=Page' + #13#10 +
'dsRepFilter=Report (*.fr3)|*.fr3' + #13#10 +
'dsComprRepFilter=Compressed report (*.fr3)|*.fr3' + #13#10 +
'dsSavePreviewChanges=Save changes to preview page?' + #13#10 +
'dsSaveChangesTo=Save changes to' + #13#10 +
'dsCantLoad=Couldn''t load file' + #13#10 +
'dsStyleFile=Style' + #13#10 +
'dsCantFindProc=Could not locate the main proc' + #13#10 +
'dsClearScript=This will clear all code. Do you want to continue?' + #13#10 +
'dsNoStyle=No style' + #13#10 +
'dsStyleSample=Style sample' + #13#10 +
'dsTextNotFound=Text ''%s'' not found' + #13#10 +
'dsReplace=Replace this occurence of ''%s''?' + #13#10 +
'======== TfrxAboutForm ========' + #13#10 +
'2600=About FastReport' + #13#10 +
'2601=Visit our webpage for more info:' + #13#10 +
'2602=Sales:' + #13#10 +
'2603=Support:' + #13#10 +
'' + #13#10 +
'======== TfrxPageEditorForm ========' + #13#10 +
'2700=Page Options' + #13#10 +
'2701=Paper' + #13#10 +
'2702=Width' + #13#10 +
'2703=Height' + #13#10 +
'2704=Size' + #13#10 +
'2705=Orientation' + #13#10 +
'2706=Left' + #13#10 +
'2707=Top' + #13#10 +
'2708=Right' + #13#10 +
'2709=Bottom' + #13#10 +
'2710=Margins' + #13#10 +
'2711=Paper Source' + #13#10 +
'2712=First page' + #13#10 +
'2713=Other pages' + #13#10 +
'2714=Portrait' + #13#10 +
'2715=Landscape' + #13#10 +
'2716=Other options' + #13#10 +
'2717=Columns' + #13#10 +
'2718=Number' + #13#10 +
'2719=Width' + #13#10 +
'2720=Positions' + #13#10 +
'2721=Other' + #13#10 +
'2722=Duplex' + #13#10 +
'2723=Print to previous page' + #13#10 +
'2724=Mirror margins' + #13#10 +
'2725=Large height in design mode' + #13#10 +
'2726=Endless page width' + #13#10 +
'2727=Endless page height' + #13#10 +
'' + #13#10 +
'======== TfrxReportDataForm ========' + #13#10 +
'2800=Select Report Datasets' + #13#10 +
'' + #13#10 +
'======== TfrxVarEditorForm ========' + #13#10 +
'2900=Edit Variables' + #13#10 +
'2901=Category' + #13#10 +
'2902=Variable' + #13#10 +
'2903=Edit' + #13#10 +
'2904=Delete' + #13#10 +
'2905=List' + #13#10 +
'2906=Load' + #13#10 +
'2907=Save' + #13#10 +
'2908=Expression:' + #13#10 +
'2909=Dictionary (*.fd3)|*.fd3' + #13#10 +
'2910=Dictionary (*.fd3)|*.fd3' + #13#10 +
'' + #13#10 +
'vaNoVar=(no variables defined)' + #13#10 +
'vaVar=Variables' + #13#10 +
'vaDupName=Duplicate name' + #13#10 +
'======== TfrxOptionsEditor ========' + #13#10 +
'3000=Designer Options' + #13#10 +
'3001=Grid' + #13#10 +
'3002=Type' + #13#10 +
'3003=Size' + #13#10 +
'3004=Dialog form:' + #13#10 +
'3005=Other' + #13#10 +
'3006=Fonts' + #13#10 +
'3007=Code window' + #13#10 +
'3008=Memo editor' + #13#10 +
'3009=Size' + #13#10 +
'3010=Size' + #13#10 +
'3011=Colors' + #13#10 +
'3012=Gap between bands:' + #13#10 +
'3013=cm' + #13#10 +
'3014=in' + #13#10 +
'3015=pt' + #13#10 +
'3016=pt' + #13#10 +
'3017=pt' + #13#10 +
'3018=Centimeters:' + #13#10 +
'3019=Inches:' + #13#10 +
'3020=Pixels:' + #13#10 +
'3021=Show grid' + #13#10 +
'3022=Align to Grid' + #13#10 +
'3023=Show editor after insert' + #13#10 +
'3024=Use object''s font settings' + #13#10 +
'3025=Workspace' + #13#10 +
'3026=Tool windows' + #13#10 +
'3027=LCD grid color' + #13#10 +
'3028=Free bands placement' + #13#10 +
'3029=Show drop-down fields list' + #13#10 +
'3030=Show startup screen' + #13#10 +
'3031=Restore defaults' + #13#10 +
'3032=Show band captions' + #13#10 +
'' + #13#10 +
'======== TfrxDataBandEditorForm ========' + #13#10 +
'3100=Select DataSet' + #13#10 +
'3101=Number of records:' + #13#10 +
'' + #13#10 +
'dbNotAssigned=[not assigned]' + #13#10 +
'======== TfrxGroupEditorForm ========' + #13#10 +
'3200=Group' + #13#10 +
'3201=Break on' + #13#10 +
'3202=Options' + #13#10 +
'3203=Data field' + #13#10 +
'3204=Expression' + #13#10 +
'3205=Keep group together' + #13#10 +
'3206=Start new page' + #13#10 +
'3207=Show in outline' + #13#10 +
'' + #13#10 +
'======== TfrxSysMemoEditorForm ========' + #13#10 +
'3300=System Memo' + #13#10 +
'3301=Data band' + #13#10 +
'3302=DataSet' + #13#10 +
'3303=DataField' + #13#10 +
'3304=Function' + #13#10 +
'3305=Expression' + #13#10 +
'3306=Aggregate value' + #13#10 +
'3307=System variable' + #13#10 +
'3308=Count invisible bands' + #13#10 +
'3309=Text' + #13#10 +
'3310=Running total' + #13#10 +
'' + #13#10 +
'agAggregate=Insert Aggregate' + #13#10 +
'vt1=[DATE]' + #13#10 +
'vt2=[TIME]' + #13#10 +
'vt3=[PAGE#]' + #13#10 +
'vt4=[TOTALPAGES#]' + #13#10 +
'vt5=[PAGE#] of [TOTALPAGES#]' + #13#10 +
'vt6=[LINE#]' + #13#10 +
'======== TfrxOleEditorForm ========' + #13#10 +
'3400=OLE object' + #13#10 +
'3401=Insert...' + #13#10 +
'3402=Edit...' + #13#10 +
'3403=Close' + #13#10 +
'' + #13#10 +
'olStretched=Stretched' + #13#10 +
'======== TfrxBarcodeEditorForm ========' + #13#10 +
'3500=Barcode Editor' + #13#10 +
'3501=Code' + #13#10 +
'3502=Type of Bar' + #13#10 +
'3503=Zoom:' + #13#10 +
'3504=Options' + #13#10 +
'3505=Rotation' + #13#10 +
'3506=Calc Checksum' + #13#10 +
'3507=Text' + #13#10 +
'3508=0°' + #13#10 +
'3509=90°' + #13#10 +
'3510=180°' + #13#10 +
'3511=270°' + #13#10 +
'' + #13#10 +
'bcCalcChecksum=Calc Checksum' + #13#10 +
'bcShowText=Show Text' + #13#10 +
'======== TfrxAliasesEditorForm ========' + #13#10 +
'3600=Edit Aliases' + #13#10 +
'3601=Press Enter to edit item' + #13#10 +
'3602=Dataset alias' + #13#10 +
'3603=Field aliases' + #13#10 +
'3604=Reset' + #13#10 +
'3605=Update' + #13#10 +
'' + #13#10 +
'alUserName=User name' + #13#10 +
'alOriginal=Original name' + #13#10 +
'======== TfrxParamsEditorForm ========' + #13#10 +
'3700=Parameters Editor' + #13#10 +
'' + #13#10 +
'qpName=Name' + #13#10 +
'qpDataType=Data Type' + #13#10 +
'qpValue=Value' + #13#10 +
'======== TfrxMDEditorForm ========' + #13#10 +
'3800=Master-Detail Link' + #13#10 +
'3801=Detail fields' + #13#10 +
'3802=Master fields' + #13#10 +
'3803=Linked fields' + #13#10 +
'3804=Add' + #13#10 +
'3805=Clear' + #13#10 +
'' + #13#10 +
'======== TfrxMemoEditorForm ========' + #13#10 +
'3900=Memo' + #13#10 +
'3901=Insert Expression' + #13#10 +
'3902=Insert Aggregate' + #13#10 +
'3903=Insert Formatting' + #13#10 +
'3904=Word Wrap' + #13#10 +
'3905=Text' + #13#10 +
'3906=Format' + #13#10 +
'3907=Highlight' + #13#10 +
'' + #13#10 +
'======== TfrxPictureEditorForm ========' + #13#10 +
'4000=Picture' + #13#10 +
'4001=Load' + #13#10 +
'4002=Copy' + #13#10 +
'4003=Paste' + #13#10 +
'4004=Clear' + #13#10 +
'' + #13#10 +
'piEmpty=Empty' + #13#10 +
'======== TfrxChartEditorForm ========' + #13#10 +
'4100=Chart Editor' + #13#10 +
'4101=Add Series' + #13#10 +
'4102=Delete Series' + #13#10 +
'4103=Edit Chart' + #13#10 +
'4104=Band source' + #13#10 +
'4105=Fixed data' + #13#10 +
'4106=DataSet' + #13#10 +
'4107=Data Source' + #13#10 +
'4108=Values' + #13#10 +
'4109=Select the chart series or add a new one.' + #13#10 +
'4114=Other options' + #13#10 +
'4115=TopN values' + #13#10 +
'4116=TopN caption' + #13#10 +
'4117=Sort order' + #13#10 +
'4126=X Axis' + #13#10 +
'' + #13#10 +
'ch3D=3D View' + #13#10 +
'chAxis=Show Axis' + #13#10 +
'chsoNone=None' + #13#10 +
'chsoAscending=Ascending' + #13#10 +
'chsoDescending=Descending' + #13#10 +
'chxtText=Text' + #13#10 +
'chxtNumber=Numeric' + #13#10 +
'chxtDate=Date' + #13#10 +
'======== TfrxRichEditorForm ========' + #13#10 +
'4200=Rich Editor' + #13#10 +
'4201=Open File' + #13#10 +
'4202=Save File' + #13#10 +
'4203=Undo' + #13#10 +
'4204=Font' + #13#10 +
'4205=Insert Expression' + #13#10 +
'4206=Bold' + #13#10 +
'4207=Italic' + #13#10 +
'4208=Underline' + #13#10 +
'4209=Left Align' + #13#10 +
'4210=Center Align' + #13#10 +
'4211=Right Align' + #13#10 +
'4212=Justify' + #13#10 +
'4213=Bullets' + #13#10 +
'' + #13#10 +
'======== TfrxCrossEditorForm ========' + #13#10 +
'4300=Cross-tab Editor' + #13#10 +
'4301=Source data' + #13#10 +
'4302=Dimensions' + #13#10 +
'4303=Rows' + #13#10 +
'4304=Columns' + #13#10 +
'4305=Cells' + #13#10 +
'4306=Cross-tab structure' + #13#10 +
'4307=Row header' + #13#10 +
'4308=Column header' + #13#10 +
'4309=Row grand total' + #13#10 +
'4310=Column grand total' + #13#10 +
'4311=Swap rows/columns' + #13#10 +
'4312=!Select style' + #13#10 +
'4313=!Save current style...' + #13#10 +
'4314=!Show title' + #13#10 +
'4315=!Show corner' + #13#10 +
'4316=!Reprint headers on new page' + #13#10 +
'4317=!Auto size' + #13#10 +
'4318=!Border around cells' + #13#10 +
'4319=!Print down then across' + #13#10 +
'4320=!Side-by-side cells' + #13#10 +
'4321=!Join equal cells' + #13#10 +
'4322=None' + #13#10 +
'4323=Sum' + #13#10 +
'4324=Min' + #13#10 +
'4325=Max' + #13#10 +
'4326=Average' + #13#10 +
'4327=Count' + #13#10 +
'4328=Ascending (A-Z)' + #13#10 +
'4329=Descending (Z-A)' + #13#10 +
'4330=No Sort' + #13#10 +
'' + #13#10 +
'crStName=!Enter the style name:' + #13#10 +
'crResize=!To resize a cross-tab, set its "AutoSize" property to False.' + #13#10 +
'crSubtotal=Subtotal' + #13#10 +
'crNone=None' + #13#10 +
'crSum=Sum' + #13#10 +
'crMin=Min' + #13#10 +
'crMax=Max' + #13#10 +
'crAvg=Avg' + #13#10 +
'crCount=Count' + #13#10 +
'crAsc=A-Z' + #13#10 +
'crDesc=Z-A' + #13#10 +
'======== TfrxExprEditorForm ========' + #13#10 +
'4400=Expression Editor' + #13#10 +
'4401=Expression:' + #13#10 +
'' + #13#10 +
'======== TfrxFormatEditorForm ========' + #13#10 +
'4500=Display Format' + #13#10 +
'4501=Category' + #13#10 +
'4502=Format' + #13#10 +
'4503=Format string:' + #13#10 +
'4504=Decimal separator:' + #13#10 +
'' + #13#10 +
'fkText=Text (no formatting)' + #13#10 +
'fkNumber=Number' + #13#10 +
'fkDateTime=Date/Time' + #13#10 +
'fkBoolean=Boolean' + #13#10 +
'fkNumber1=1234.5;%g' + #13#10 +
'fkNumber2=1234.50;%2.2f' + #13#10 +
'fkNumber3=1,234.50;%2.2n' + #13#10 +
'fkNumber4=$1,234.50;%2.2m' + #13#10 +
'fkDateTime1=11.28.2002;mm.dd.yyyy' + #13#10 +
'fkDateTime2=28 nov 2002;dd mmm yyyy' + #13#10 +
'fkDateTime3=November 28, 2002;mmmm dd, yyyy' + #13#10 +
'fkDateTime4=02:14;hh:mm' + #13#10 +
'fkDateTime5=02:14am;hh:mm am/pm' + #13#10 +
'fkDateTime6=02:14:00;hh:mm:ss' + #13#10 +
'fkDateTime7=02:14am, November 28, 2002;hh:mm am/pm, mmmm dd, yyyy' + #13#10 +
'fkBoolean1=0,1;0,1' + #13#10 +
'fkBoolean2=No,Yes;No,Yes' + #13#10 +
'fkBoolean3=_,x;_,x' + #13#10 +
'fkBoolean4=False,True;False,True' + #13#10 +
'======== TfrxHighlightEditorForm ========' + #13#10 +
'4600=Highlight' + #13#10 +
'4601=Color...' + #13#10 +
'4602=Color...' + #13#10 +
'4603=Condition' + #13#10 +
'4604=Font' + #13#10 +
'4605=Background' + #13#10 +
'4606=Bold' + #13#10 +
'4607=Italic' + #13#10 +
'4608=Underline' + #13#10 +
'4609=Transparent' + #13#10 +
'4610=Other' + #13#10 +
'' + #13#10 +
'======== TfrxReportEditorForm ========' + #13#10 +
'4700=Report Settings' + #13#10 +
'4701=General' + #13#10 +
'4702=Printer settings' + #13#10 +
'4703=Copies' + #13#10 +
'4704=General' + #13#10 +
'4705=Password' + #13#10 +
'4706=Collate copies' + #13#10 +
'4707=Double pass' + #13#10 +
'4708=Print if empty' + #13#10 +
'4709=Description' + #13#10 +
'4710=Name' + #13#10 +
'4711=Description' + #13#10 +
'4712=Picture' + #13#10 +
'4713=Author' + #13#10 +
'4714=Major' + #13#10 +
'4715=Minor' + #13#10 +
'4716=Release' + #13#10 +
'4717=Build' + #13#10 +
'4718=Created' + #13#10 +
'4719=Modified' + #13#10 +
'4720=Description' + #13#10 +
'4721=Version' + #13#10 +
'4722=Browse...' + #13#10 +
'4723=Inheritance settings' + #13#10 +
'4724=Select the option:' + #13#10 +
'4725=Don''t change' + #13#10 +
'4726=Detach the base report' + #13#10 +
'4727=Inherit from base report:' + #13#10 +
'4728=Inheritance' + #13#10 +
'' + #13#10 +
'rePrnOnPort=on' + #13#10 +
'riNotInherited=This report is not inherited.' + #13#10 +
'riInherited=This report is inherited from base report: %s' + #13#10 +
'======== TfrxStringsEditorForm ========' + #13#10 +
'4800=Lines' + #13#10 +
'' + #13#10 +
'======== TfrxSQLEditorForm ========' + #13#10 +
'4900=SQL' + #13#10 +
'4901=Query Builder' + #13#10 +
'' + #13#10 +
'======== TfrxPasswordForm ========' + #13#10 +
'5000=Password' + #13#10 +
'5001=Enter the password:' + #13#10 +
'' + #13#10 +
'======== TfrxStyleEditorForm ========' + #13#10 +
'5100=Style Editor' + #13#10 +
'5101=Color...' + #13#10 +
'5102=Font...' + #13#10 +
'5103=Frame...' + #13#10 +
'5104=Add' + #13#10 +
'5105=Delete' + #13#10 +
'5106=Edit' + #13#10 +
'5107=Load' + #13#10 +
'5108=Save' + #13#10 +
'' + #13#10 +
'======== TfrxFrameEditorForm ========' + #13#10 +
'5200=Frame Editor' + #13#10 +
'5201=Frame' + #13#10 +
'5202=Frame line' + #13#10 +
'5203=Shadow' + #13#10 +
'5204=Top Line' + #13#10 +
'5205=Bottom Line' + #13#10 +
'5206=Left Line' + #13#10 +
'5207=Right Line' + #13#10 +
'5208=All Frame Lines' + #13#10 +
'5209=No Frame' + #13#10 +
'5210=Frame Color' + #13#10 +
'5211=Frame Style' + #13#10 +
'5212=Frame Width' + #13#10 +
'5213=Shadow' + #13#10 +
'5214=Shadow Color' + #13#10 +
'5215=Shadow Width' + #13#10 +
'' + #13#10 +
'======== TfrxNewItemForm ========' + #13#10 +
'5300=New Item' + #13#10 +
'5301=Items' + #13#10 +
'5302=Templates' + #13#10 +
'5303=Inherit the report' + #13#10 +
'' + #13#10 +
'======== TfrxTabOrderEditorForm ========' + #13#10 +
'5400=Tab Order' + #13#10 +
'5401=Controls listed in tab order:' + #13#10 +
'5402=Move Up' + #13#10 +
'5403=Move Down' + #13#10 +
'' + #13#10 +
'======== TfrxEvaluateForm ========' + #13#10 +
'5500=Evaluate' + #13#10 +
'5501=Expression' + #13#10 +
'5502=Result' + #13#10 +
'' + #13#10 +
'======== TfrxStdWizardForm ========' + #13#10 +
'5600=Report Wizard' + #13#10 +
'5601=Data' + #13#10 +
'5602=Fields' + #13#10 +
'5603=Groups' + #13#10 +
'5604=Layout' + #13#10 +
'5605=Style' + #13#10 +
'5606=Step 1. Select the dataset.' + #13#10 +
'5607=Step 2. Select the fields to display.' + #13#10 +
'5608=Step 3. Create groups (optional).' + #13#10 +
'5609=Step 4. Define the page orientation and data layout.' + #13#10 +
'5610=Step 5. Choose the report style.' + #13#10 +
'5611=Add >' + #13#10 +
'5612=Add all >>' + #13#10 +
'5613=< Remove' + #13#10 +
'5614=<< Remove all' + #13#10 +
'5615=Add >' + #13#10 +
'5616=< Remove' + #13#10 +
'5617=Selected fields:' + #13#10 +
'5618=Available fields:' + #13#10 +
'5619=Groups:' + #13#10 +
'5620=Orientation' + #13#10 +
'5621=Layout' + #13#10 +
'5622=Portrait' + #13#10 +
'5623=Landscape' + #13#10 +
'5624=Tabular' + #13#10 +
'5625=Columnar' + #13#10 +
'5626=Fit fields to page width' + #13#10 +
'5627=<< Back' + #13#10 +
'5628=Next >>' + #13#10 +
'5629=Finish' + #13#10 +
'5630=New table...' + #13#10 +
'5631=New query...' + #13#10 +
'5632=Select database connection:' + #13#10 +
'5633=Select a table:' + #13#10 +
'5634=or' + #13#10 +
'5635=Create a query...' + #13#10 +
'5636=Configure connections' + #13#10 +
'' + #13#10 +
'wzStd=Standard Report Wizard' + #13#10 +
'wzDMP=Dot-Matrix Report Wizard' + #13#10 +
'wzStdEmpty=Standard Report' + #13#10 +
'wzDMPEmpty=Dot-Matrix Report' + #13#10 +
'======== TfrxConnectionWizardForm ========' + #13#10 +
'5700=Connection Wizard' + #13#10 +
'5701=Connection' + #13#10 +
'5702=Choose the connection type:' + #13#10 +
'5703=Choose the database:' + #13#10 +
'5704=Login' + #13#10 +
'5705=Password' + #13#10 +
'5706=Prompt login' + #13#10 +
'5707=Use login/password:' + #13#10 +
'5708=Table' + #13#10 +
'5709=Choose the table name:' + #13#10 +
'5710=Filter records:' + #13#10 +
'5711=Query' + #13#10 +
'5712=SQL statement:' + #13#10 +
'5713=Query Builder' + #13#10 +
'5714=Edit Query Parameters' + #13#10 +
'' + #13#10 +
'ftAllFiles=All Files' + #13#10 +
'ftPictures=Pictures' + #13#10 +
'ftDB=Databases' + #13#10 +
'ftRichFile=RichText file' + #13#10 +
'ftTextFile=Text file' + #13#10 +
'prNotAssigned=(Not assigned)' + #13#10 +
'prInvProp=Invalid property value' + #13#10 +
'prDupl=Duplicate name' + #13#10 +
'prPict=(Picture)' + #13#10 +
'mvExpr=Allow Expressions' + #13#10 +
'mvStretch=Stretch' + #13#10 +
'mvStretchToMax=Stretch to Max Height' + #13#10 +
'mvShift=Shift' + #13#10 +
'mvShiftOver=Shift When Overlapped' + #13#10 +
'mvVisible=Visible' + #13#10 +
'mvPrintable=Printable' + #13#10 +
'mvFont=Font...' + #13#10 +
'mvFormat=Display Format...' + #13#10 +
'mvClear=Clear Contents' + #13#10 +
'mvAutoWidth=Auto Width' + #13#10 +
'mvWWrap=Word Wrap' + #13#10 +
'mvSuppress=Suppress Repeated Values' + #13#10 +
'mvHideZ=Hide Zeros' + #13#10 +
'mvHTML=Allow HTML Tags' + #13#10 +
'lvDiagonal=Diagonal' + #13#10 +
'pvAutoSize=Auto Size' + #13#10 +
'pvCenter=Center' + #13#10 +
'pvAspect=Keep Aspect Ratio' + #13#10 +
'bvSplit=Allow Split' + #13#10 +
'bvKeepChild=Keep Child Together' + #13#10 +
'bvPrintChild=Print Child If Invisible' + #13#10 +
'bvStartPage=Start New Page' + #13#10 +
'bvPrintIfEmpty=Print If Detail Empty' + #13#10 +
'bvKeepDetail=Keep Detail Together' + #13#10 +
'bvKeepFooter=Keep Footer Together' + #13#10 +
'bvReprint=Reprint On New Page' + #13#10 +
'bvOnFirst=Print On First Page' + #13#10 +
'bvOnLast=Print On Last Page' + #13#10 +
'bvKeepGroup=Keep Together' + #13#10 +
'bvFooterAfterEach=Footer After Each Row' + #13#10 +
'bvDrillDown=Drill-Down' + #13#10 +
'bvResetPageNo=Reset Page Numbers' + #13#10 +
'srParent=Print On Parent' + #13#10 +
'bvKeepHeader=Keep Header Together' + #13#10 +
'obCatDraw=Draw' + #13#10 +
'obCatOther=Other objects' + #13#10 +
'obCatOtherControls=Other controls' + #13#10 +
'obDiagLine=Diagonal line' + #13#10 +
'obRect=Rectangle' + #13#10 +
'obRoundRect=Rounded rectangle' + #13#10 +
'obEllipse=Ellipse' + #13#10 +
'obTrian=Triangle' + #13#10 +
'obDiamond=Diamond' + #13#10 +
'obLabel=Label control' + #13#10 +
'obEdit=Edit control' + #13#10 +
'obMemoC=Memo control' + #13#10 +
'obButton=Button control' + #13#10 +
'obChBoxC=CheckBox control' + #13#10 +
'obRButton=RadioButton control' + #13#10 +
'obLBox=ListBox control' + #13#10 +
'obCBox=ComboBox control' + #13#10 +
'obDateEdit=DateEdit control' + #13#10 +
'obImageC=Image control' + #13#10 +
'obPanel=Panel control' + #13#10 +
'obGrBox=GroupBox control' + #13#10 +
'obBBtn=BitBtn control' + #13#10 +
'obSBtn=SpeedButton control' + #13#10 +
'obMEdit=MaskEdit control' + #13#10 +
'obChLB=CheckListBox control' + #13#10 +
'obDBLookup=DBLookupComboBox control' + #13#10 +
'obBevel=Bevel object' + #13#10 +
'obShape=Shape object' + #13#10 +
'obText=Text object' + #13#10 +
'obSysText=System text' + #13#10 +
'obLine=Line object' + #13#10 +
'obPicture=Picture object' + #13#10 +
'obBand=Band object' + #13#10 +
'obDataBand=Data band' + #13#10 +
'obSubRep=Subreport object' + #13#10 +
'obDlgPage=Dialog form' + #13#10 +
'obRepPage=Report page' + #13#10 +
'obReport=Report object' + #13#10 +
'obRich=RichText object' + #13#10 +
'obOLE=OLE object' + #13#10 +
'obChBox=CheckBox object' + #13#10 +
'obChart=Chart object' + #13#10 +
'obBarC=Barcode object' + #13#10 +
'obCross=Cross-tab object' + #13#10 +
'obDBCross=DB Cross-tab object' + #13#10 +
'obGrad=Gradient object' + #13#10 +
'obDMPText=Dot-matrix Text object' + #13#10 +
'obDMPLine=Dot-matrix Line object' + #13#10 +
'obDMPCmd=Dot-matrix Command object' + #13#10 +
'obBDEDB=BDE Database' + #13#10 +
'obBDETb=BDE Table' + #13#10 +
'obBDEQ=BDE Query' + #13#10 +
'obBDEComps=BDE components' + #13#10 +
'obIBXDB=IBX Database' + #13#10 +
'obIBXTb=IBX Table' + #13#10 +
'obIBXQ=IBX Query' + #13#10 +
'obIBXComps=IBX Components' + #13#10 +
'obADODB=ADO Database' + #13#10 +
'obADOTb=ADO Table' + #13#10 +
'obADOQ=ADO Query' + #13#10 +
'obADOComps=ADO Components' + #13#10 +
'obDBXDB=DBX Database' + #13#10 +
'obDBXTb=DBX Table' + #13#10 +
'obDBXQ=DBX Query' + #13#10 +
'obDBXComps=DBX Components' + #13#10 +
'obFIBDB=FIB Database' + #13#10 +
'obFIBTb=FIB Table' + #13#10 +
'obFIBQ=FIB Query' + #13#10 +
'obFIBComps=FIB Components' + #13#10 +
'ctString=String' + #13#10 +
'ctDate=Date and Time' + #13#10 +
'ctConv=Conversions' + #13#10 +
'ctFormat=Formatting' + #13#10 +
'ctMath=Mathematical' + #13#10 +
'ctOther=Other' + #13#10 +
'IntToStr=Converts an integer value to a string' + #13#10 +
'FloatToStr=Converts a float value to a string' + #13#10 +
'DateToStr=Converts a date to a string' + #13#10 +
'TimeToStr=Converts a time to a string' + #13#10 +
'DateTimeToStr=Converts a date-and-time value to a string' + #13#10 +
'VarToStr=Converts a variant value to a string' + #13#10 +
'StrToInt=Converts a string to an integer value' + #13#10 +
'StrToInt64=Converts a string to an Int64 value' + #13#10 +
'StrToFloat=Converts a string to a floating-point value' + #13#10 +
'StrToDate=Converts a string to a date format' + #13#10 +
'StrToTime=Converts a string to a time format' + #13#10 +
'StrToDateTime=Converts a string to a date-and-time format' + #13#10 +
'Format=Returns formatted string assembled from a series of array arguments' + #13#10 +
'FormatFloat=Formats a floating-point value' + #13#10 +
'FormatDateTime=Formats a date-and-time value' + #13#10 +
'FormatMaskText=Returns a string formatted using an edit mask' + #13#10 +
'EncodeDate=Returns a TDateTime type for a specified Year, Month, and Day' + #13#10 +
'DecodeDate=Breaks TDateTime into Year, Month, and Day values' + #13#10 +
'EncodeTime=Returns a TDateTime type for a specified Hour, Min, Sec, and MSec' + #13#10 +
'DecodeTime=Breaks TDateTime into hours, minutes, seconds, and milliseconds' + #13#10 +
'Date=Returns current date' + #13#10 +
'Time=Returns current time' + #13#10 +
'Now=Return current date and time' + #13#10 +
'DayOfWeek=Returns the day of the week for a specified date' + #13#10 +
'IsLeapYear=Indicates whether a specified year is a leap year' + #13#10 +
'DaysInMonth=Returns a number of days in a specified month' + #13#10 +
'Length=Returns a length of a string' + #13#10 +
'Copy=Returns a substring of a string' + #13#10 +
'Pos=Returns a position of a substring in a string' + #13#10 +
'Delete=Removes a substring from a string' + #13#10 +
'Insert=Inserts a substring into a string' + #13#10 +
'Uppercase=Converts all character in a string to upper case' + #13#10 +
'Lowercase=Converts all character in a string to lower case' + #13#10 +
'Trim=Trims all trailing and leading spaces in a string' + #13#10 +
'NameCase=Converts first character of a word to upper case' + #13#10 +
'CompareText=Compares two strings' + #13#10 +
'Chr=Converts an integer value to a char' + #13#10 +
'Ord=Converts a character value to an integer' + #13#10 +
'SetLength=Sets the length of a string' + #13#10 +
'Round=Rounds a floating-point value to the nearest whole number' + #13#10 +
'Trunc=Truncates a floating-point value to an integer' + #13#10 +
'Int=Returns the integer part of a real number' + #13#10 +
'Frac=Returns the fractional part of a real number' + #13#10 +
'Sqrt=Returns the square root of a specified number' + #13#10 +
'Abs=Returns an absolute value' + #13#10 +
'Sin=Returns the sine of an angle (in radians)' + #13#10 +
'Cos=Returns the cosine of an angle (in radians)' + #13#10 +
'ArcTan=Returns the arctangent' + #13#10 +
'Tan=Returns the tangent' + #13#10 +
'Exp=Returns the exponential' + #13#10 +
'Ln=Returns the natural log of a real expression' + #13#10 +
'Pi=Returns the 3.1415926... number' + #13#10 +
'Inc=Increments a value' + #13#10 +
'Dec=Decrements a value' + #13#10 +
'RaiseException=Raises an exception' + #13#10 +
'ShowMessage=Shows a message box' + #13#10 +
'Randomize=Starts the random numbers generator' + #13#10 +
'Random=Returns a random number' + #13#10 +
'ValidInt=Returns True if specified string contains a valid integer' + #13#10 +
'ValidFloat=Returns True if specified string contains a valid float' + #13#10 +
'ValidDate=Returns True if specified string contains a valid date' + #13#10 +
'IIF=Returns TrueValue if specified Expr is True, otherwise returns FalseValue' + #13#10 +
'Get=For internal use only' + #13#10 +
'Set=For internal use only' + #13#10 +
'InputBox=Displays an input dialog box that enables the user to enter a string' + #13#10 +
'InputQuery=Displays an input dialog box that enables the user to enter a string' + #13#10 +
'MessageDlg=Shows a message box' + #13#10 +
'CreateOleObject=Creates an OLE object' + #13#10 +
'VarArrayCreate=Creates a variant array' + #13#10 +
'VarType=Return a type of the variant value' + #13#10 +
'DayOf=Returns day number (1..31) of given Date' + #13#10 +
'MonthOf=Returns month number (1..12) of given Date' + #13#10 +
'YearOf=Returns year of given Date' + #13#10 +
'ctAggregate=Aggregate' + #13#10 +
'Sum=Calculates the sum of the Expr for the Band datarow' + #13#10 +
'Avg=Calculates the average of the Expr for the Band datarow' + #13#10 +
'Min=Calculates the minimum of the Expr for the Band datarow' + #13#10 +
'Max=Calculates the maximum of the Expr for the Band datarow' + #13#10 +
'Count=Calculates the number of datarows' + #13#10 +
'wzDBConn=New Connection Wizard' + #13#10 +
'wzDBTable=New Table Wizard' + #13#10 +
'wzDBQuery=New Query Wizard' + #13#10 +
'======== TfrxConnEditorForm ========' + #13#10 +
'5800=Connections' + #13#10 +
'5801=New' + #13#10 +
'5802=Delete' + #13#10 +
'' + #13#10 +
'cpName=Name' + #13#10 +
'cpConnStr=Connection string' + #13#10 +
'startCreateNew=Create new report' + #13#10 +
'startCreateBlank=Create blank report' + #13#10 +
'startOpenReport=Open report' + #13#10 +
'startOpenLast=Open last report' + #13#10 +
'startEditAliases=Edit connection aliases' + #13#10 +
'startHelp=Help' + #13#10 +
'' + #13#10 +
'======== TfrxWatchForm ========' + #13#10 +
'5900=Watches' + #13#10 +
'5901=Add Watch' + #13#10 +
'5902=Delete Watch' + #13#10 +
'5903=Edit Watch' + #13#10 +
'' + #13#10 +
'======== TfrxInheritErrorForm ========' + #13#10 +
'6000=Inherit error' + #13#10 +
'6001=Base and inherited reports have duplicate objects. What should we do?' + #13#10 +
'6002=Delete duplicates' + #13#10 +
'6003=Rename duplicates' + #13#10 +
'';

initialization
  frxResources.AddStrings(resStr);

end.


//0f31356a91fea3356e5f76cdce90aa7b