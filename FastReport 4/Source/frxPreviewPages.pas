
{******************************************}
{                                          }
{             FastReport v4.0              }
{              Preview Pages               }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxPreviewPages;

interface

{$I frx.inc}

uses
  Windows, SysUtils, Messages, Classes, Graphics, Controls, Forms, Dialogs,
  frxClass, frxXML, frxPictureCache
{$IFDEF Delphi6}
, Variants
{$ENDIF};


type
  TfrxOutline = class(TfrxCustomOutline)
  private
  protected
    function GetCount: Integer; override;
  public
    function Root: TfrxXMLItem;
    procedure AddItem(const Text: String; Top: Integer); override;
    procedure LevelDown(Index: Integer); override;
    procedure LevelRoot; override;
    procedure LevelUp; override;
    procedure GetItem(Index: Integer; var Text: String;
      var Page, Top: Integer); override;
    procedure ShiftItems(From: TfrxXMLItem; NewTop: Integer); override;
    function GetCurPosition: TfrxXMLItem; override;
  end;

  TfrxDictionary = class(TObject)
  private
    FNames: TStringList;
    FSourceNames: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const Name, SourceName: String; Obj: TObject);
    procedure Clear;
    function AddUnique(const Base, SourceName: String; Obj: TObject): String;
    function CreateUniqueName(const Base: String): String;
    function GetSourceName(const Name: String): String;
    function GetObject(const Name: String): TObject;
    property Names: TStringList read FNames;
    property SourceNames: TStringList read FSourceNames;
  end;

  TfrxPreviewPages = class(TfrxCustomPreviewPages)
  private
    FAllowPartialLoading: Boolean;
    FCopyNo: Integer;
    FDictionary: TfrxDictionary;   { list of all objects }
    FFirstObjectIndex: Integer; { used in the ClearFirstPassPages }
    FFirstPageIndex: Integer;   { used in the ClearFirstPassPages }
    FLogicalPageN: Integer;
    FPageCache: TStringList;  { last 20 TfrxPreviewPage }
    FPagesItem: TfrxXMLItem;  { shortcut to XMLDoc.Root.FindName('previewpages') }
    FPictureCache: TfrxPictureCache;
    FPrintScale: Extended;
    FSourcePages: TList;      { list of source pages }
    FTempStream: TStream;
    FXMLDoc: TfrxXMLDocument; { parsed FP3 document }
    FXMLSize: Integer;
    procedure AfterLoad;
    procedure BeforeSave;
    procedure ClearPageCache;
    procedure ClearSourcePages;
    function CurXMLPage: TfrxXMLItem;
    function GetObject(const Name: String): TfrxComponent;
    procedure DoLoadFromStream;
    procedure DoSaveToStream;
  protected
    function GetCount: Integer; override;
    function GetPage(Index: Integer): TfrxReportPage; override;
    function GetPageSize(Index: Integer): TPoint; override;
  public
    constructor Create(AReport: TfrxReport); override;
    destructor Destroy; override;
    procedure Clear; override;
    procedure Initialize; override;

    { engine commands }
    procedure AddAnchor(const Text: String);
    procedure AddObject(Obj: TfrxComponent); override;
    procedure AddPage(Page: TfrxReportPage); override;
    procedure AddPicture(Picture: TfrxPictureView); override;
    procedure AddSourcePage(Page: TfrxReportPage); override;
    procedure AddToSourcePage(Obj: TfrxComponent); override;
    procedure BeginPass; override;
    procedure ClearFirstPassPages; override;
    procedure CutObjects(APosition: Integer); override;
    procedure Finish; override;
    procedure IncLogicalPageNumber; override;
    procedure ResetLogicalPageNumber; override;
    procedure PasteObjects(X, Y: Extended); override;
    procedure ShiftAnchors(From, NewTop: Integer); override;
    procedure UpdatePageDimensions(Page: TfrxReportPage; Width, Height: Extended);
    function BandExists(Band: TfrxBand): Boolean; override;
    function FindAnchor(const Text: String): TfrxXMLItem;
    function GetAnchorPage(const Text: String): Integer;
    function GetAnchorCurPosition: Integer; override;
    function GetCurPosition: Integer; override;
    function GetLastY: Extended; override;
    function GetLogicalPageNo: Integer; override;
    function GetLogicalTotalPages: Integer; override;

    { preview commands }
    procedure DrawPage(Index: Integer; Canvas: TCanvas; ScaleX, ScaleY,
      OffsetX, OffsetY: Extended); override;
    procedure AddEmptyPage(Index: Integer); override;
    procedure DeletePage(Index: Integer); override;
    procedure ModifyPage(Index: Integer; Page: TfrxReportPage); override;
    procedure AddFrom(Report: TfrxReport); override;
    procedure LoadFromStream(Stream: TStream;
      AllowPartialLoading: Boolean = False); override;
    procedure SaveToStream(Stream: TStream); override;
    function LoadFromFile(const FileName: String;
      ExceptionIfNotFound: Boolean = False): Boolean; override;
    procedure SaveToFile(const FileName: String); override;
    function Print: Boolean; override;
    function Export(Filter: TfrxCustomExportFilter): Boolean; override;
    procedure ObjectOver(Index: Integer; X, Y: Integer; Button: TMouseButton;
      Shift: TShiftState; Scale, OffsetX, OffsetY: Extended;
      Click: Boolean; var Cursor: TCursor); override;
    property SourcePages: TList read FSourcePages;
  end;


implementation

uses
  frxPreview, Printers, frxPrinter, frxPrintDialog, frxXMLSerializer, frxUtils,
  ShellApi, frxDMPClass, frxRes;

type
  THackComponent = class(TfrxComponent);
  THackMemoView = class(TfrxCustomMemoView);
  THackThread = class(TThread);



{ TfrxOutline }

procedure TfrxOutline.AddItem(const Text: String; Top: Integer);
begin
  CurItem := CurItem.Add;
  CurItem.Name := 'item';
  CurItem.Text := 'text="' + frxStrToXML(Text) +
    '" page="' + IntToStr(PreviewPages.CurPage) +
    '" top="' + IntToStr(Top) + '"';
end;

procedure TfrxOutline.GetItem(Index: Integer; var Text: String; var Page,
  Top: Integer);
var
  Item: TfrxXMLItem;
  s: String;
begin
  Item := CurItem[Index];
  Text := Item.Prop['text'];

  s := Item.Prop['page'];
  if s <> '' then
    Page := StrToInt(s);

  s := Item.Prop['top'];
  if s <> '' then
    Top := StrToInt(s);
end;

procedure TfrxOutline.LevelDown(Index: Integer);
begin
  CurItem := CurItem[Index];
end;

procedure TfrxOutline.LevelRoot;
begin
  CurItem := Root;
end;

procedure TfrxOutline.LevelUp;
begin
  if CurItem <> Root then
    CurItem := CurItem.Parent;
end;

function TfrxOutline.Root: TfrxXMLItem;
begin
  Result := TfrxPreviewPages(PreviewPages).FXMLDoc.Root.FindItem('outline');
end;

function TfrxOutline.GetCount: Integer;
begin
  if CurItem = nil then
    Result := 0
  else
    Result := CurItem.Count;
end;

procedure TfrxOutline.ShiftItems(From: TfrxXMLItem; NewTop: Integer);
var
  i, TopY, CorrY: Integer;

  procedure EnumItems(Item: TfrxXMLItem);
  var
    i: Integer;
  begin
    Item.Prop['page'] := IntToStr(StrToInt(Item.Prop['page']) + 1);
    Item.Prop['top'] := IntToStr(StrToInt(Item.Prop['top']) + CorrY);
    for i := 0 to Item.Count - 1 do
      EnumItems(Item[i]);
  end;

begin
  if From = nil then Exit;
  i := From.Parent.IndexOf(From);
  if i + 1 >= From.Parent.Count then Exit;
  From := From.Parent[i + 1];

  TopY := StrToInt(From.Prop['top']);
  CorrY := NewTop - TopY;
  EnumItems(From);
end;

function TfrxOutline.GetCurPosition: TfrxXMLItem;
begin
  if Count = 0 then
    Result := nil else
    Result := CurItem[Count - 1];
end;


{ TfrxDictionary }

constructor TfrxDictionary.Create;
begin
  FNames := TStringList.Create;
  FNames.Sorted := True;
  FSourceNames := TStringList.Create;
end;

destructor TfrxDictionary.Destroy;
begin
  FNames.Free;
  FSourceNames.Free;
  inherited;
end;

procedure TfrxDictionary.Clear;
begin
  FNames.Clear;
  FSourceNames.Clear;
end;

procedure TfrxDictionary.Add(const Name, SourceName: String; Obj: TObject);
var
  i: Integer;
begin
  i := FSourceNames.AddObject(SourceName, Obj);
  FNames.AddObject(Name, TObject(i));
end;

function TfrxDictionary.AddUnique(const Base, SourceName: String; Obj: TObject): String;
begin
  Result := CreateUniqueName(Base);
  Add(Result, SourceName, Obj);
end;

function TfrxDictionary.CreateUniqueName(const Base: String): String;
var
  i: Integer;
begin
  i := 10000;
  while (i > 1) and (FNames.IndexOf(Base + IntToStr(i)) = -1) do
    i := i div 2;
  while FNames.IndexOf(Base + IntToStr(i)) <> -1 do
    Inc(i);
  Result := Base + IntToStr(i);
end;

function TfrxDictionary.GetObject(const Name: String): TObject;
var
  i: Integer;
begin
  Result := nil;
  i := FNames.IndexOf(Name);
  if i <> -1 then
    Result := FSourceNames.Objects[Integer(FNames.Objects[i])];
end;

function TfrxDictionary.GetSourceName(const Name: String): String;
var
  i: Integer;
begin
  Result := '';
  i := FNames.IndexOf(Name);
  if i <> -1 then
    Result := FSourceNames[Integer(FNames.Objects[i])];
end;


{ TfrxPreviewPages }

constructor TfrxPreviewPages.Create(AReport: TfrxReport);
begin
  inherited;
  FDictionary := TfrxDictionary.Create;
  FSourcePages := TList.Create;
  FXMLDoc := TfrxXMLDocument.Create;
  FXMLDoc.Root.Name := 'preparedreport';
//  FXMLDoc.AutoIndent := True;
  FPageCache := TStringList.Create;
  FPictureCache := TfrxPictureCache.Create;
end;

destructor TfrxPreviewPages.Destroy;
begin
  ClearPageCache;
  FPageCache.Free;
  FDictionary.Free;
  ClearSourcePages;
  FPictureCache.Free;
  FSourcePages.Free;
  FXMLDoc.Free;
  inherited;
end;

procedure TfrxPreviewPages.Clear;
begin
  ClearPageCache;
  ClearSourcePages;
  FXMLDoc.Clear;
  FDictionary.Clear;
  FPictureCache.Clear;
  CurPage := -1;
  FXMLSize := 0;
end;

procedure TfrxPreviewPages.Initialize;
begin
  FXMLDoc.TempDir := Report.EngineOptions.TempDir;
  Report.InternalOnProgressStart(ptRunning);
end;

procedure TfrxPreviewPages.ClearPageCache;
begin
  while FPageCache.Count > 0 do
  begin
    TfrxReportPage(FPageCache.Objects[0]).Free;
    FPageCache.Delete(0);
  end;
end;

procedure TfrxPreviewPages.ClearSourcePages;
begin
  while FSourcePages.Count > 0 do
  begin
    TfrxReportPage(FSourcePages[0]).Free;
    FSourcePages.Delete(0);
  end;
end;

procedure TfrxPreviewPages.BeginPass;
begin
  FFirstPageIndex := Count - 1;
  if FFirstPageIndex <> -1 then
    FFirstObjectIndex := FXMLDoc.Root.FindItem('previewpages')[FFirstPageIndex].Count;
  ResetLogicalPageNumber;
end;

procedure TfrxPreviewPages.ClearFirstPassPages;
var
  PagesRoot: TfrxXMLItem;
  p: TfrxXMLItem;
  i: Integer;
begin
  if FFirstPageIndex = -1 then
  begin
    for i := 0 to FXMLDoc.Root.Count - 1 do
      if (CompareText(FXMLDoc.Root[i].Name, 'anchors') <> 0) and
        (CompareText(FXMLDoc.Root[i].Name, 'logicalpagenumbers') <> 0) then
        FXMLDoc.Root[i].Clear;
  end
  else
  begin
    PagesRoot := FXMLDoc.Root.FindItem('previewpages');
    p := PagesRoot[FFirstPageIndex];
    { clear some objects on first page }
    while p.Count > FFirstObjectIndex do
      p[FFirstObjectIndex].Free;
    { clear remained pages }
    while Count > FFirstPageIndex + 1 do
      PagesRoot[FFirstPageIndex + 1].Free;
  end;

  ResetLogicalPageNumber;
  CurPage := FFirstPageIndex;
  FXMLSize := 0;
end;

function TfrxPreviewPages.CurXMLPage: TfrxXMLItem;
begin
  Result := FXMLDoc.Root.FindItem('previewpages');
  Result := Result[CurPage];
end;

function TfrxPreviewPages.GetCount: Integer;
begin
  Result := FXMLDoc.Root.FindItem('previewpages').Count;
end;

function TfrxPreviewPages.GetCurPosition: Integer;
begin
  Result := CurXMLPage.Count;
end;

procedure TfrxPreviewPages.AddAnchor(const Text: String);
var
  AnchorRoot, Item: TfrxXMLItem;
begin
  AnchorRoot := FXMLDoc.Root.FindItem('anchors');
  Item := AnchorRoot.Add;
  Item.Name := 'item';
  Item.Text := 'text="' + frxStrToXML(Text) +
    '" page="' + IntToStr(CurPage) +
    '" top="' + IntToStr(Round(Engine.CurY)) + '"';
end;

function TfrxPreviewPages.FindAnchor(const Text: String): TfrxXMLItem;
var
  AnchorRoot, Item: TfrxXMLItem;
  i: Integer;
begin
  Result := nil;
  AnchorRoot := FXMLDoc.Root.FindItem('anchors');
  for i := AnchorRoot.Count - 1 downto 0 do
  begin
    Item := AnchorRoot[i];
    if AnsiCompareText(Item.Prop['text'], Text) = 0 then
    begin
      Result := Item;
      Exit;
    end;
  end;
end;

function TfrxPreviewPages.GetAnchorPage(const Text: String): Integer;
var
  Item: TfrxXMLItem;
begin
  Item := FindAnchor(Text);
  if Item <> nil then
    Result := StrToInt(Item.Prop['page']) + 1 else
    Result := 1;
end;

function TfrxPreviewPages.GetAnchorCurPosition: Integer;
begin
  Result := FXMLDoc.Root.FindItem('anchors').Count - 1;
end;

procedure TfrxPreviewPages.ShiftAnchors(From, NewTop: Integer);
var
  i, CorrY: Integer;
  AnchorRoot, Item: TfrxXMLItem;
begin
  AnchorRoot := FXMLDoc.Root.FindItem('anchors');
  if (From + 1 < 0) or (From + 1 >= AnchorRoot.Count) then Exit;

  Item := AnchorRoot[From + 1];
  CorrY := NewTop - StrToInt(Item.Prop['top']);

  for i := From + 1 to AnchorRoot.Count - 1 do
  begin
    Item := AnchorRoot[i];
    Item.Prop['page'] := IntToStr(StrToInt(Item.Prop['page']) + 1);
    Item.Prop['top'] := IntToStr(StrToInt(Item.Prop['top']) + CorrY);
  end;
end;

procedure TfrxPreviewPages.IncLogicalPageNumber;
var
  xi: TfrxXMLItem;
begin
  if Engine.FinalPass and Engine.DoublePass then Exit;

  Inc(FLogicalPageN);
  xi := FXMLDoc.Root.FindItem('logicalpagenumbers').Add;
  xi.Name := 'page';
  xi.Prop['n'] := IntToStr(FLogicalPageN);
end;

procedure TfrxPreviewPages.ResetLogicalPageNumber;
var
  i: Integer;
  xi, pageItem: TfrxXMLItem;
begin
  if Engine.FinalPass and Engine.DoublePass then Exit;

  pageItem := FXMLDoc.Root.FindItem('logicalpagenumbers');
  for i := CurPage downto FFirstPageIndex + 1 do
  begin
    if (i < 0) or (i >= pageItem.Count) then continue;
    xi := pageItem[i];
    xi.Prop['t'] := IntToStr(FLogicalPageN);
    if xi.Prop['n'] = '1' then
      break;
  end;
  FLogicalPageN := 0;
end;

function TfrxPreviewPages.GetLogicalPageNo: Integer;
var
  xi: TfrxXMLItem;
begin
  xi := FXMLDoc.Root.FindItem('logicalpagenumbers');
  if (CurPage < 0) or (CurPage >= xi.Count) then
    Result := CurPage - FirstPage + 1
  else
  begin
    xi := xi[CurPage];
    Result := StrToInt(xi.Prop['n']);
  end;
end;

function TfrxPreviewPages.GetLogicalTotalPages: Integer;
var
  xi: TfrxXMLItem;
begin
  xi := FXMLDoc.Root.FindItem('logicalpagenumbers');
  if (CurPage < 0) or (CurPage >= xi.Count) then
    Result := Engine.TotalPages - FirstPage
  else
  begin
    xi := xi[CurPage];
    if xi.Prop['t'] <> '' then
      Result := StrToInt(xi.Prop['t'])
    else
      Result := 0;
  end;
end;

procedure TfrxPreviewPages.AddObject(Obj: TfrxComponent);

  procedure DoAdd(c: TfrxComponent; Item: TfrxXMLItem);
  var
    i: Integer;
  begin
    if (not c.Visible) or not (csPreviewVisible in c.frComponentStyle) then Exit;

    with THackComponent(c) do
    begin
      Item := Item.Add;
      { the component that was created after report has been started }
      if FOriginalComponent = nil then
      begin
        Item.Name := ClassName;
        Item.Text := AllDiff(nil);
      end
      else
      begin
        { the component that exists in the report template }
        Item.Name := FAliasName;
        if Engine.FinalPass then
        begin
          if csDefaultDiff in frComponentStyle then
            Item.Text := AllDiff(FOriginalComponent) else
            Item.Text := Diff(FOriginalComponent);
        end
        else
          { we don't need to output all info on the first pass, only coordinates }
          Item.Text := InternalDiff(FOriginalComponent);
      end;
      Inc(FXMLSize, Length(Item.Name) + Length(Item.Text) + Item.InstanceSize + 16);
    end;

    for i := 0 to c.Objects.Count - 1 do
      DoAdd(c.Objects[i], Item);
  end;

begin
  DoAdd(Obj, CurXMLPage);
end;

procedure TfrxPreviewPages.AddPage(Page: TfrxReportPage);
var
  xi: TfrxXMLItem;

  procedure UnloadPages;
  var
    i: Integer;
  begin
    if Report.EngineOptions.UseFileCache then
      if FXMLSize > Report.EngineOptions.MaxMemSize * 1024 * 1024 then
      begin
        for i := xi.Count - 2 downto 0 do
          if xi[i].Loaded then
            FXMLDoc.UnloadItem(xi[i]) else
            break;
        FXMLSize := 0;
      end;
  end;

  function GetSourceNo(Page: TfrxReportPage): Integer;
  var
    i: Integer;
  begin
    Result := -1;
    for i := 0 to FSourcePages.Count - 1 do
      if THackComponent(FSourcePages[i]).FOriginalComponent = Page then
      begin
        Result := i;
        break;
      end;
  end;

begin
  FPagesItem := FXMLDoc.Root.FindItem('previewpages');
  xi := FPagesItem;
  UnloadPages;

  CurPage := CurPage + 1;
  if (CurPage >= Count) or (AddPageAction = apAdd) then
  begin
    xi := xi.Add;
    xi.Name := 'page' + IntToStr(GetSourceNo(Page));
    if Count > 2 then
      xi.Unloadable := True;
    Report.InternalOnProgress(ptRunning, CurPage + 1);
    AddPageAction := apWriteOver;
    CurPage := Count - 1;
    IncLogicalPageNumber;
  end;
end;

procedure TfrxPreviewPages.AddSourcePage(Page: TfrxReportPage);
var
  p: TfrxReportPage;
  xs: TfrxXMLSerializer;
  xi: TfrxXMLItem;
  i: Integer;
  originals, copies: TList;
  c1, c2: TfrxComponent;
  s, s1: String;

  function EnumObjects(Parent, Parent1: TfrxComponent): TfrxComponent;
  var
    i: Integer;
    c: TfrxComponent;
  begin
    Result := nil;
    if not (csPreviewVisible in Parent.frComponentStyle) then Exit;

    c := TfrxComponent(Parent.NewInstance);
    c.Create(Parent1);
    if Parent is TfrxPictureView then
      TfrxPictureView(Parent).IsPictureStored := False;
    c.Assign(Parent);
    if Parent is TfrxPictureView then
      TfrxPictureView(Parent).IsPictureStored := True;
    c.Name := Parent.Name;
    originals.Add(Parent);
    copies.Add(c);

    for i := 0 to Parent.Objects.Count - 1 do
      EnumObjects(Parent.Objects[i], c);
    Result := c;
  end;

begin
  xs := TfrxXMLSerializer.Create(nil);
  xi := TfrxXMLItem.Create;
  originals := TList.Create;
  copies := TList.Create;

  try
    p := TfrxReportPage(EnumObjects(Page, nil));
    THackComponent(p).FOriginalComponent := Page;
    FSourcePages.Add(p);

    for i := 1 to copies.Count - 1 do
    begin
      c1 := copies[i];
      c2 := originals[i];

      THackComponent(c2).FOriginalComponent := c1;
      THackComponent(c1).FOriginalComponent := c2;

      if c1 is TfrxBand then
        s := 'b' else
        s := LowerCase(c1.BaseName[1]);
      s := FDictionary.AddUnique(s, 'Page' + IntToStr(FSourcePages.Count - 1) +
        '.' + c1.Name, c1);
      // speed optimization
      if c1 is TfrxCustomMemoView then
      begin
        TfrxCustomMemoView(c1).DataSet := nil;
        TfrxCustomMemoView(c1).DataField := '';
      end;
      if csDefaultDiff in c1.frComponentStyle then
        s1 := c1.ClassName
      else
        s1 := xs.WriteComponentStr(c1);
      THackComponent(c1).FBaseName := s1;
      // speed optimization
      if c1 is TfrxCustomMemoView then
      begin
        xi.Text := s1;
        xi.DeleteProp('Text');
        s1 := xi.Text;
        Delete(s1, Pos(' ParentFont="False"', s1), 19);
        Delete(s1, Pos(' Font.Charset="1"', s1), 17);
        Delete(s1, Pos(' Font.Color="0"', s1), 15);
        Delete(s1, Pos(' Font.Name="Arial"', s1), 18);
        Delete(s1, Pos(' Font.Height="-13"', s1), 18);
        Delete(s1, Pos(' Font.Style="0"', s1), 15);
        THackComponent(c1).FBaseName := s1;
      end;

      THackComponent(c1).FAliasName := s;
      THackComponent(c2).FAliasName := s;
    end;

  finally
    originals.Free;
    copies.Free;
    xs.Free;
    xi.Free;
  end;
end;

procedure TfrxPreviewPages.AddPicture(Picture: TfrxPictureView);
begin
  FPictureCache.AddPicture(Picture);
end;

procedure TfrxPreviewPages.AddToSourcePage(Obj: TfrxComponent);
var
  NewObj: TfrxComponent;
  Page: TfrxReportPage;
  s: String;
  xs: TfrxXMLSerializer;
begin
  xs := TfrxXMLSerializer.Create(nil);
  Page := FSourcePages[FSourcePages.Count - 1];
  NewObj := TfrxComponent(Obj.NewInstance);
  NewObj.Create(Page);
  NewObj.Assign(Obj);
  NewObj.CreateUniqueName;

  s := FDictionary.AddUnique(LowerCase(NewObj.BaseName[1]),
    'Page' + IntToStr(FSourcePages.Count - 1) + '.' + NewObj.Name, NewObj);
  if csDefaultDiff in NewObj.frComponentStyle then
    THackComponent(NewObj).FBaseName := NewObj.ClassName else
    THackComponent(NewObj).FBaseName := xs.WriteComponentStr(NewObj);

  THackComponent(Obj).FOriginalComponent := NewObj;
  THackComponent(Obj).FAliasName := s;
  THackComponent(NewObj).FAliasName := s;
  xs.Free;
end;

procedure TfrxPreviewPages.UpdatePageDimensions(Page: TfrxReportPage; Width, Height: Extended);
var
  SourcePage: TfrxReportPage;
  xi: TfrxXMLItem;
  i: Integer;
begin
  SourcePage := nil;
  for i := 0 to FSourcePages.Count - 1 do
  begin
    SourcePage := FSourcePages[i];
    if THackComponent(SourcePage).FOriginalComponent = Page then
      break;
  end;

  SourcePage.PaperSize := 256;
  SourcePage.PaperWidth := Width / fr01cm;
  SourcePage.PaperHeight := Height / fr01cm;
  xi := TfrxXMLItem.Create;
  xi.Text := THackComponent(SourcePage).FBaseName;
  xi.Prop['PaperSize'] := '256';
  xi.Prop['PaperWidth'] := frxFloatToStr(SourcePage.PaperWidth);
  xi.Prop['PaperHeight'] := frxFloatToStr(SourcePage.PaperHeight);
  THackComponent(SourcePage).FBaseName := xi.Text;
  xi.Free;
end;

procedure TfrxPreviewPages.Finish;
var
  i: Integer;
begin
  ClearPageCache;
  { avoid bug with multiple PrepareReport(False) }
  for i := 0 to FSourcePages.Count - 1 do
    THackComponent(FSourcePages[i]).FOriginalComponent := nil;
  Report.InternalOnProgressStop(ptRunning);
end;

function TfrxPreviewPages.BandExists(Band: TfrxBand): Boolean;
var
  i: Integer;
  c: TfrxComponent;
begin
  Result := False;
  for i := 0 to CurXMLPage.Count - 1 do
  begin
    c := GetObject(CurXMLPage[i].Name);
    if c <> nil then
      if (THackComponent(c).FOriginalComponent = Band) or
         ((Band is TfrxPageFooter) and (c is TfrxPageFooter)) or
         ((Band is TfrxColumnFooter) and (c is TfrxColumnFooter)) then
      begin
        Result := True;
        break;
      end;
  end;
end;

function TfrxPreviewPages.GetLastY: Extended;
var
  i: Integer;
  c: TfrxComponent;
  s: String;
  y: Extended;
begin
  Result := 0;
  for i := 0 to CurXMLPage.Count - 1 do
  begin
    c := GetObject(CurXMLPage[i].Name);
    if c is TfrxBand then
      if not (c is TfrxPageFooter) and not (c is TfrxOverlay) then
      begin
        s := CurXMLPage[i].Prop['t'];
        if s <> '' then
          y := frxStrToFloat(s) else
          y := c.Top;
        s := CurXMLPage[i].Prop['h'];
        if s <> '' then
          y := y + frxStrToFloat(s) else
          y := y + c.Height;
        if y > Result then
          Result := y;
      end;
  end;
end;

procedure TfrxPreviewPages.CutObjects(APosition: Integer);
var
  xi: TfrxXMLItem;
begin
  xi := FXMLDoc.Root.FindItem('cutted');
  while APosition < CurXMLPage.Count do
    xi.AddItem(CurXMLPage[APosition]);
end;

procedure TfrxPreviewPages.PasteObjects(X, Y: Extended);
var
  xi: TfrxXMLItem;
  LeftX, TopY, CorrX, CorrY: Extended;

  procedure CorrectX(xi: TfrxXMLItem);
  var
    X: Extended;
  begin
    if xi.Prop['l'] <> '' then
      X := frxStrToFloat(xi.Prop['l']) else
      X := 0;
    X := X + CorrX;
    xi.Prop['l'] := FloatToStr(X);
  end;

  procedure CorrectY(xi: TfrxXMLItem);
  var
    Y: Extended;
  begin
    if xi.Prop['t'] <> '' then
      Y := frxStrToFloat(xi.Prop['t']) else
      Y := 0;
    Y := Y + CorrY;
    xi.Prop['t'] := FloatToStr(Y);
  end;

begin
  xi := FXMLDoc.Root.FindItem('cutted');

  if xi.Count > 0 then
  begin
    if xi[0].Prop['l'] <> '' then
      LeftX := frxStrToFloat(xi[0].Prop['l']) else
      LeftX := 0;
    CorrX := X - LeftX;

    if xi[0].Prop['t'] <> '' then
      TopY := frxStrToFloat(xi[0].Prop['t']) else
      TopY := 0;
    CorrY := Y - TopY;

    while xi.Count > 0 do
    begin
      CorrectX(xi[0]);
      CorrectY(xi[0]);
      CurXMLPage.AddItem(xi[0]);
    end;
  end;

  xi.Free;
end;

procedure TfrxPreviewPages.DoLoadFromStream;
var
  Compressor: TfrxCustomCompressor;
begin
  Compressor := nil;
  if frxCompressorClass <> nil then
  begin
    FAllowPartialLoading := False;
    Compressor := TfrxCustomCompressor(frxCompressorClass.NewInstance);
    Compressor.Create(nil);
    Compressor.Report := Report;
    Compressor.IsFR3File := False;
    try
      Compressor.CreateStream;
      if Compressor.Decompress(FTempStream) then
        FTempStream := Compressor.Stream;
    except
      Compressor.Free;
      Report.Errors.Add(frxResources.Get('clDecompressError'));
      frxCommonErrorHandler(Report, frxResources.Get('clErrors') + #13#10 + Report.Errors.Text);
      Exit;
    end;
  end;
  FXMLDoc.LoadFromStream(FTempStream, FAllowPartialLoading);
  AfterLoad;
  if Compressor <> nil then
    Compressor.Free;
end;

procedure TfrxPreviewPages.DoSaveToStream;
var
  Compressor: TfrxCustomCompressor;
  StreamTo: TStream;
begin
  StreamTo := FTempStream;
  Compressor := nil;
  if Report.ReportOptions.Compressed and (frxCompressorClass <> nil) then
  begin
    Compressor := TfrxCustomCompressor(frxCompressorClass.NewInstance);
    Compressor.Create(nil);
    Compressor.Report := Report;
    Compressor.IsFR3File := False;
    Compressor.CreateStream;
    StreamTo := Compressor.Stream;
  end;
  try
    BeforeSave;
    FXMLDoc.SaveToStream(StreamTo);
  finally
    if Compressor <> nil then
    begin
      try
        Compressor.Compress(FTempStream);
      finally
        Compressor.Free;
      end;
    end;
  end;
end;

procedure TfrxPreviewPages.LoadFromStream(Stream: TStream;
  AllowPartialLoading: Boolean = False);
begin
  Clear;
  FTempStream := Stream;
  FAllowPartialLoading := AllowPartialLoading;

//  if Report.EngineOptions.ReportThread <> nil then
//    THackThread(Report.EngineOptions.ReportThread).Synchronize(DoLoadFromStream)
//  else

    DoLoadFromStream;
end;

procedure TfrxPreviewPages.SaveToStream(Stream: TStream);
begin
  FTempStream := Stream;

//  if Report.EngineOptions.ReportThread <> nil then
//    THackThread(Report.EngineOptions.ReportThread).Synchronize(DoSaveToStream)
//  else

    DoSaveToStream;
end;

function TfrxPreviewPages.LoadFromFile(const FileName: String;
  ExceptionIfNotFound: Boolean): Boolean;
var
  Stream: TFileStream;
begin
  Result := FileExists(FileName);
  if Result or ExceptionIfNotFound then
  begin
    Stream := TFileStream.Create(FileName, fmOpenRead + fmShareDenyWrite);
    try
      LoadFromStream(Stream);
    finally
      Stream.Free;
    end;
{   Clear;
    FXMLDoc.LoadFromFile(FileName);
    AfterLoad;}
  end;
end;

procedure TfrxPreviewPages.SaveToFile(const FileName: String);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
{  BeforeSave;
  FXMLDoc.SaveToFile(FileName);
  ClearPageCache;
  AfterLoad;}
end;

procedure TfrxPreviewPages.AfterLoad;
var
  i: Integer;
  xs: TfrxXMLSerializer;
  xi: TfrxXMLItem;
  p: TfrxReportPage;

{ store source objects' properties in the FBaseName to get it later in the GetPage }
  procedure DoProps(p: TfrxReportPage);
  var
    i: Integer;
    l: TList;
    c: THackComponent;
  begin
    l := p.AllObjects;
    for i := 0 to l.Count - 1 do
    begin
      c := l[i];
      c.FBaseName := xs.WriteComponentStr(c);
    end;
  end;

{ fill FDictionary.Objects }
  procedure FillDictionary;
  var
    i: Integer;
    Name, PageName, ObjName: String;
    PageN: Integer;
  begin
    xi := FXMLDoc.Root.FindItem('dictionary');
    FDictionary.Clear;
    for i := 0 to xi.Count - 1 do
    begin
      Name := Copy(xi[i].Text, 7, Length(xi[i].Text) - 7);
      PageName := Copy(Name, 1, Pos('.', Name) - 1);
      ObjName := Copy(Name, Pos('.', Name) + 1, 255);

      PageN := StrToInt(Copy(PageName, 5, 255));
      FDictionary.Add(xi[i].Name, Name,
        TfrxReportPage(FSourcePages[PageN]).FindObject(ObjName));
    end;
  end;

begin
  FPagesItem := FXMLDoc.Root.FindItem('previewpages');
  xs := TfrxXMLSerializer.Create(nil);

{ load the report settings }
  xi := FXMLDoc.Root.FindItem('report');
  if xi.Count > 0 then
    xs.ReadRootComponent(Report, xi[0]);

{ build sourcepages }
  try
    xi := FXMLDoc.Root.FindItem('sourcepages');
    ClearSourcePages;

    for i := 0 to xi.Count - 1 do
    begin
      if CompareText(xi[i].Name, 'TfrxDMPPage') = 0 then
        p := TfrxDMPPage.Create(nil) else
        p := TfrxReportPage.Create(nil);
      xs.Owner := p;
      xs.ReadRootComponent(p, xi[i]);
      DoProps(p);
      FSourcePages.Add(p);
    end;
    xi.Clear;

  finally
    xs.Free;
  end;

{ build the dictionary }
  FillDictionary;

{ load the picturecache }
  FPictureCache.LoadFromXML(FXMLDoc.Root.FindItem('picturecache'));
end;

procedure TfrxPreviewPages.BeforeSave;
var
  i: Integer;
  xs: TfrxXMLSerializer;
  xi: TfrxXMLItem;
begin
  FPagesItem := FXMLDoc.Root.FindItem('previewpages');
  xs := TfrxXMLSerializer.Create(nil);

{ upload the report settings }
  xi := FXMLDoc.Root.FindItem('report');
  xi.Clear;
  xi := xi.Add;
  xi.Name := Report.ClassName;
  xi.Text := 'DotMatrixReport="' + frxValueToXML(Report.DotMatrixReport) +
    '" PreviewOptions.OutlineVisible="' + frxValueToXML(Report.PreviewOptions.OutlineVisible) +
    '" PreviewOptions.OutlineWidth="' + frxValueToXML(Report.PreviewOptions.OutlineWidth) + '"';

{ upload the sourcepages }
  try
    xi := FXMLDoc.Root.FindItem('sourcepages');
    xi.Clear;
    for i := 0 to FSourcePages.Count - 1 do
      xs.WriteRootComponent(FSourcePages[i], True, xi.Add);

  finally
    xs.Free;
  end;

{ upload the dictionary }
  xi := FXMLDoc.Root.FindItem('dictionary');
  xi.Clear;
  for i := 0 to FDictionary.Names.Count - 1 do
    with xi.Add do
    begin
      Name := FDictionary.Names[i];
      Text := 'name="' + FDictionary.GetSourceName(Name) + '"';
    end;

{ upload the picturecache }
  xi := FXMLDoc.Root.FindItem('picturecache');
  FPictureCache.SaveToXML(xi);
end;

function TfrxPreviewPages.GetObject(const Name: String): TfrxComponent;
begin
  Result := TfrxComponent(FDictionary.GetObject(Name));
end;

function TfrxPreviewPages.GetPage(Index: Integer): TfrxReportPage;
var
  xi: TfrxXMLItem;
  xs: TfrxXMLSerializer;
  i: Integer;
  Source: TfrxReportPage;

  procedure DoObjects(Item: TfrxXMLItem; Owner: TfrxComponent);
  var
    i: Integer;
    c, c0: TfrxComponent;
  begin
    for i := 0 to Item.Count - 1 do
    begin
      c0 := GetObject(Item[i].Name);
      { object not found in the dictionary }
      if c0 = nil then
        c := xs.ReadComponentStr(Owner, Item[i].Name + ' ' + Item[i].Text, True)
      else
      begin
        c := xs.ReadComponentStr(Owner,
          THackComponent(c0).FBaseName + ' ' + Item[i].Text, True);
        c.Name := c0.Name;
        if (c is TfrxPictureView) and (TfrxPictureView(c).Picture.Graphic = nil) then
          FPictureCache.GetPicture(TfrxPictureView(c));
      end;
      c.Parent := Owner;

      DoObjects(Item[i], c);
    end;
  end;

begin
  Result := nil;
  if Count = 0 then Exit;

  { check pagecache first }
  if not Engine.Running then
  begin
    i := FPageCache.IndexOf(IntToStr(Index));
    if i <> -1 then
    begin
      Result := TfrxReportPage(FPageCache.Objects[i]);
      FPageCache.Exchange(i, 0);
      Exit;
    end;
  end;

  xs := TfrxXMLSerializer.Create(nil);
  try
    { load the page item }
    xi := FPagesItem[Index];
    FXMLDoc.LoadItem(xi);

    if CompareText(xi.Name, 'TfrxReportPage') = 0 then
    begin
      { page item do not refer to the originalpages }
      Result := TfrxReportPage.Create(nil);
      xs.ReadRootComponent(Result, xi);
    end
    else if CompareText(xi.Name, 'TfrxDMPPage') = 0 then
    begin
      { page item do not refer to the originalpages }
      Result := TfrxDMPPage.Create(nil);
      xs.ReadRootComponent(Result, xi);
    end
    else
    begin
      Source := FSourcePages[StrToInt(Copy(xi.Name, 5, 5))];
      { create reportpage and assign properties from original page }
      if Source is TfrxDMPPage then
        Result := TfrxDMPPage.Create(nil) else
        Result := TfrxReportPage.Create(nil);
      Result.Assign(Source);

      { create objects }
      DoObjects(xi, Result);
    end;
  finally
    xs.Free;
  end;

  { update aligned objects }
  Result.AlignChildren;

  { add this page to the pagecache }
  FPageCache.InsertObject(0, IntToStr(Index), Result);
  i := FPageCache.Count;

  { remove the least used item from the pagecache }
  if i > 50 then
  begin
    xi := FPagesItem[StrToInt(FPageCache[i - 1])];
    if Report.EngineOptions.UseFileCache and xi.Unloadable then
    begin
      FXMLDoc.UnloadItem(xi);
      xi.Clear;
    end;

    TfrxReportPage(FPageCache.Objects[i - 1]).Free;
    FPageCache.Delete(i - 1);
  end;
end;

function TfrxPreviewPages.GetPageSize(Index: Integer): TPoint;
var
  xi: TfrxXMLItem;
  p: TfrxReportPage;
begin
  if (Count = 0) or (Index < 0) or (Index >= Count) then
  begin
    Result := Point(0, 0);
    Exit;
  end;

  xi := FPagesItem[Index];
  if (CompareText(xi.Name, 'TfrxReportPage') = 0) or
    (CompareText(xi.Name, 'TfrxDMPPage') = 0) then
    p := GetPage(Index) else
    p := FSourcePages[StrToInt(Copy(xi.Name, 5, 256))];
  Result.X := Round(p.Width);
  Result.Y := Round(p.Height);
end;

procedure TfrxPreviewPages.AddEmptyPage(Index: Integer);
var
  xi: TfrxXMLItem;
begin
  if Count = 0 then Exit;

  xi := TfrxXMLItem.Create;
  xi.Name := FPagesItem[Index].Name;
  FPagesItem.InsertItem(Index, xi);
  ClearPageCache;
end;

procedure TfrxPreviewPages.DeletePage(Index: Integer);
begin
  if Count < 2 then Exit;

  FPagesItem[Index].Free;
  ClearPageCache;
end;

procedure TfrxPreviewPages.ModifyPage(Index: Integer; Page: TfrxReportPage);
var
  xs: TfrxXMLSerializer;
begin
  xs := TfrxXMLSerializer.Create(nil);
  try
    FPagesItem[Index].Clear;
    xs.WriteRootComponent(Page, True, FPagesItem[Index]);
    FPagesItem[Index].Unloadable := False;
    ClearPageCache;
  finally
    xs.Free;
  end;
end;

procedure TfrxPreviewPages.AddFrom(Report: TfrxReport);
var
  i: Integer;
  Page: TfrxReportPage;
  xi: TfrxXMLItem;
  xs: TfrxXMLSerializer;
begin
  xs := TfrxXMLSerializer.Create(nil);

  for i := 0 to Report.PreviewPages.Count - 1 do
  begin
    Page := Report.PreviewPages.Page[i];
    xi := TfrxXMLItem.Create;
    xi.Name := FPagesItem[Count - 1].Name;
    xs.WriteRootComponent(Page, True, xi);
    xi.Unloadable := False;
    FPagesItem.AddItem(xi);
  end;

  xs.Free;
  ClearPageCache;
end;

procedure TfrxPreviewPages.DrawPage(Index: Integer; Canvas: TCanvas;
  ScaleX, ScaleY, OffsetX, OffsetY: Extended);
var
  i: Integer;
  Page: TfrxReportPage;
  l: TList;
  c: TfrxComponent;
  IsPrinting: Boolean;
  SaveLeftMargin, SaveRightMargin: Extended;
  rgn: HRGN;

  function ViewVisible(c: TfrxComponent): Boolean;
  var
    r: TRect;
  begin
    with c do
      r := Rect(Round(AbsLeft * ScaleX) - 20, Round(AbsTop * ScaleY) - 20,
                Round((AbsLeft + Width) * ScaleX + 20),
                Round((AbsTop + Height) * ScaleY + 20));
    OffsetRect(r, Round(OffsetX), Round(OffsetY));
    Result := RectVisible(Canvas.Handle, r) or (Canvas is TMetafileCanvas);
  end;

begin
  Page := GetPage(Index);
  if Page = nil then Exit;

  SaveLeftMargin := Page.LeftMargin;
  SaveRightMargin := Page.RightMargin;
  if Page.MirrorMargins and (Index mod 2 = 1) then
  begin
    Page.LeftMargin := SaveRightMargin;
    Page.RightMargin := SaveLeftMargin;
  end;

  IsPrinting := Canvas is TfrxPrinterCanvas;
  rgn := 0;
  if not IsPrinting then
  begin
    rgn := CreateRectRgn(0, 0, 10000, 10000);
    GetClipRgn(Canvas.Handle, rgn);
    IntersectClipRect(Canvas.Handle,
      Round(OffsetX),
      Round(OffsetY),
      Round(OffsetX + Page.PaperWidth * fr01cm * ScaleX) - 1,
      Round(OffsetY + Page.PaperHeight * fr01cm * ScaleY) - 1);
  end;

  Page.Draw(Canvas, ScaleX, ScaleY, OffsetX, OffsetY);
  OffsetX := OffsetX + Page.LeftMargin * fr01cm * ScaleX;
  OffsetY := OffsetY + Page.TopMargin * fr01cm * ScaleY;

  l := Page.AllObjects;

  for i := 0 to l.Count - 1 do
  begin
    c := l[i];
    if (c is TfrxView) and ViewVisible(c) then
      if not IsPrinting or TfrxView(c).Printable then
      begin
        c.IsPrinting := IsPrinting;
        { needed for TOTALPAGES macro }
        if c is TfrxCustomMemoView then
        begin
          THackMemoView(c).FTotalPages := Count;
          THackMemoView(c).FCopyNo := FCopyNo;
          THackMemoView(c).FPrintScale := FPrintScale;
        end;
        { draw the object }
        TfrxView(c).Draw(Canvas, ScaleX, ScaleY, OffsetX, OffsetY);
        c.IsPrinting := False;
      end;
  end;

  Page.LeftMargin := SaveLeftMargin;
  Page.RightMargin := SaveRightMargin;
  if not IsPrinting then
  begin
    SelectClipRgn(Canvas.Handle, rgn);
    DeleteObject(rgn);
  end;
end;

function TfrxPreviewPages.Print: Boolean;
var
  MaxCount: Integer;
  PagesPrinted, ACopyNo: Integer;
  pgList: TStringList;
  LastDuplexMode: TfrxDuplexMode;
  LastPaperSize, LastPaperWidth, LastPaperHeight, LastBin: Integer;
  LastOrientation: TPrinterOrientation;
  SplitAddX, SplitAddY: Extended;
  DuplexMode: TfrxDuplexMode;
  SavePrintOptions: TfrxPrintOptions;
  SheetWidth, SheetHeight: Extended;


  function GetNextPage(var Index: Integer): TfrxReportPage;
  begin
    Result := nil;
    while Index < Count - 1 do
    begin
      Inc(Index);
      if (pgList.Count <> 0) and (pgList.IndexOf(IntToStr(Index + 1)) = -1) then
        continue
      else
      begin
        Result := GetPage(Index);
        break;
      end;
    end;
  end;

  procedure SplitPage(a, b, c, d: Extended; var x, y: Integer; var NeedRotate: Boolean);
  var
    tempX, tempY: Integer;
    tempC: Extended;

    procedure TrySplit;
    begin
      if Abs(Trunc(a / c) * c - a) < 11 then
        x := Round(a / c)
      else
        x := Trunc(a / c) + 1;

      if Abs(Trunc(b / d) * d - b) < 11 then
        y := Round(b / d)
      else
        y := Trunc(b / d) + 1;
    end;

  begin
    NeedRotate := False;

    TrySplit;

    tempX := x;
    tempY := y;

    tempC := c;
    c := d;
    d := tempC;

    TrySplit;

    if x * y >= tempX * tempY then
    begin
      x := tempX;
      y := tempY;
    end
    else
      NeedRotate := True;
  end;

  procedure DoPrint;
  var
    i: Integer;
    Printer: TfrxCustomPrinter;
    PagePrinted: Boolean;
    Page: TfrxReportPage;

    function PrintSplittedPage(Index: Integer): Boolean;
    var
      Bin, ACopies, x, y, countX, countY: Integer;
      pieceX, pieceY, offsX, offsY, marginX, marginY, printedX, printedY: Extended;
      orient: TPrinterOrientation;
      NeedChangeOrientation: Boolean;
      dup: TfrxDuplexMode;
    begin
      Result := True;
      if Index >= Count then Exit;

      if (pgList.Count <> 0) and (pgList.IndexOf(IntToStr(Index + 1)) = -1) then Exit;
      if ((Report.PrintOptions.PrintPages = ppOdd) and ((Index + 1) mod 2 = 0)) or
         ((Report.PrintOptions.PrintPages = ppEven) and ((Index + 1) mod 2 = 1)) then Exit;
      if Report.Terminated then
      begin
        Printer.Abort;
        Result := False;
        Exit;
      end;

      Page := GetPage(Index);

      if Report.PrintOptions.Collate then
      begin
        ACopies := 1;
        FCopyNo := ACopyNo;
      end
      else
      begin
        ACopies := Report.PrintOptions.Copies;
        FCopyNo := 1;
      end;

      if Assigned(Report.OnPrintPage) then
        Report.OnPrintPage(Page, FCopyNo);

      if Index = 0 then
        Bin := Page.Bin else
        Bin := Page.BinOtherPages;

      SplitPage(Page.PaperWidth, Page.PaperHeight, SheetWidth, SheetHeight,
        countX, countY, NeedChangeOrientation);

      orient := poPortrait;
      if NeedChangeOrientation then
        orient := poLandscape;

      dup := Page.Duplex;
      if DuplexMode <> dmNone then
        dup := DuplexMode;

      if not PagePrinted or (orient <> LastOrientation) then
        Printer.SetPrintParams(Report.PrintOptions.PrintOnSheet,
          SheetWidth, SheetHeight, orient, Bin, Integer(dup) + 1, ACopies);
      if not PagePrinted then
        Printer.BeginDoc;

      if orient = poPortrait then
      begin
        pieceX := SheetWidth * (Printer.DPI.X / 25.4);
        pieceY := SheetHeight * (Printer.DPI.Y / 25.4);
      end
      else
      begin
        pieceX := SheetHeight * (Printer.DPI.X / 25.4);
        pieceY := SheetWidth * (Printer.DPI.Y / 25.4);
      end;

      marginY := 0;
      printedY := 0;
      offsY := -Printer.TopMargin * Printer.DPI.Y / 25.4;

      for y := 1 to countY do
      begin
        marginX := 0;
        printedX := 0;
        offsX := -Printer.LeftMargin * Printer.DPI.X / 25.4;

        for x := 1 to countX do
        begin
          Printer.BeginPage;
          DrawPage(Index, Printer.Canvas, Printer.DPI.X / 96, Printer.DPI.Y / 96,
            offsX, offsY);


          Printer.EndPage;

          printedX := printedX + (pieceX - marginX - Printer.RightMargin * Printer.DPI.X / 25.4) -
            SplitAddX * Printer.DPI.X / 25.4;
          offsX := -printedX;
          marginX := Printer.LeftMargin * Printer.DPI.X / 25.4;
        end;

        printedY := printedY + (pieceY - marginY - Printer.BottomMargin * Printer.DPI.Y / 25.4) -
          SplitAddY * Printer.DPI.Y / 25.4;
        offsY := -printedY;
        marginY := Printer.TopMargin * Printer.DPI.Y / 25.4;
      end;

      Report.InternalOnProgress(ptPrinting, Index + 1);
      Application.ProcessMessages;

      PagePrinted := True;
      Inc(PagesPrinted);

      LastOrientation := Page.Orientation;
      ClearPageCache;
    end;


    function PrintPage(Index: Integer): Boolean;
    var
      Bin, ACopies: Integer;
      dup: TfrxDuplexMode;
      ZoomX, ZoomY: Extended;
    begin
      Result := True;
      if Index >= Count then Exit;

      if (pgList.Count <> 0) and (pgList.IndexOf(IntToStr(Index + 1)) = -1) then Exit;
      if ((Report.PrintOptions.PrintPages = ppOdd) and ((Index + 1) mod 2 = 0)) or
         ((Report.PrintOptions.PrintPages = ppEven) and ((Index + 1) mod 2 = 1)) then Exit;
      if Report.Terminated then
      begin
        Printer.Abort;
        Result := False;
        Exit;
      end;

      Page := GetPage(Index);

      if Report.PrintOptions.Collate then
      begin
        ACopies := 1;
        FCopyNo := ACopyNo;
      end
      else
      begin
        ACopies := Report.PrintOptions.Copies;
        FCopyNo := 1;
      end;

      if Assigned(Report.OnPrintPage) then
        Report.OnPrintPage(Page, FCopyNo);

      if Index = 0 then
        Bin := Page.Bin else
        Bin := Page.BinOtherPages;

      dup := Page.Duplex;
      if DuplexMode <> dmNone then
        dup := DuplexMode;

      if Report.PrintOptions.PrintMode = pmDefault then
      begin
        if (not PagePrinted) or
          (LastPaperSize <> Page.PaperSize) or
          (LastPaperWidth <> Round(Page.PaperWidth)) or
          (LastPaperHeight <> Round(Page.PaperHeight)) or
          (LastBin <> Bin) or
          (LastOrientation <> Page.Orientation) or
          (LastDuplexMode <> dup) then
          Printer.SetPrintParams(Page.PaperSize, Page.PaperWidth, Page.PaperHeight,
            Page.Orientation, Bin, Integer(dup) + 1, ACopies);
      end
      else
        if (not PagePrinted) or
          (LastBin <> Bin) or
          (LastOrientation <> Page.Orientation) or
          (LastDuplexMode <> dup) then
          Printer.SetPrintParams(Report.PrintOptions.PrintOnSheet,
            SheetWidth, SheetHeight, Page.Orientation, Bin, Integer(dup) + 1, ACopies);
      if not PagePrinted then
        Printer.BeginDoc;

      Printer.BeginPage;

      if Report.PrintOptions.PrintMode = pmDefault then
      begin
        ZoomX := 1;
        ZoomY := 1;
      end
      else
      begin
        ZoomX := SheetWidth / Page.PaperWidth;
        ZoomY := SheetHeight / Page.PaperHeight;
        FPrintScale := ZoomY;
      end;

      DrawPage(Index, Printer.Canvas, Printer.DPI.X / 96 * ZoomX, Printer.DPI.Y / 96 * ZoomY,
        -Printer.LeftMargin * Printer.DPI.X / 25.4,
        -Printer.TopMargin * Printer.DPI.Y / 25.4);

      Report.InternalOnProgress(ptPrinting, Index + 1);


      Printer.EndPage;
      Application.ProcessMessages;

      PagePrinted := True;
      Inc(PagesPrinted);

      LastPaperSize := Page.PaperSize;
      LastPaperWidth := Round(Page.PaperWidth);
      LastPaperHeight := Round(Page.PaperHeight);
      LastBin := Bin;
      LastOrientation := Page.Orientation;
      LastDuplexMode := dup;
      ClearPageCache;
    end;

    procedure PrintPages;
    var
      i: Integer;
    begin
      PagesPrinted := 0;

      if Report.PrintOptions.Reverse then
      begin
        for i := MaxCount - 1 downto 0 do
          if not PrintPage(i) then
            break;
      end
      else
        for i := 0 to MaxCount - 1 do
          if not PrintPage(i) then
            break;
    end;

    procedure PrintSplittedPages;
    var
      i: Integer;
    begin
      PagesPrinted := 0;

      if Report.PrintOptions.Reverse then
      begin
        for i := MaxCount - 1 downto 0 do
          if not PrintSplittedPage(i) then
            break;
      end
      else
        for i := 0 to MaxCount - 1 do
          if not PrintSplittedPage(i) then
            break;
    end;

    procedure PrintJoinedPages;
    var
      Index, cp, x, y, countX, countY: Integer;
      pieceX, pieceY, offsX, offsY: Extended;
      orient: TPrinterOrientation;
      NeedChangeOrientation: Boolean;
      dup: TfrxDuplexMode;
    begin
      PagesPrinted := 0;
      if Count = 0 then Exit;

      { get the first page and calculate the join options }
      Index := -1;
      Page := GetNextPage(Index);

      SplitPage(SheetWidth, SheetHeight, Page.PaperWidth, Page.PaperHeight,
        countX, countY, NeedChangeOrientation);
      orient := poPortrait;
      if NeedChangeOrientation then
      begin
        orient := poLandscape;
        x := countX;
        countX := countY;
        countY := x;
      end;

      { setup the printer }
      dup := Page.Duplex;
      if DuplexMode <> dmNone then
        dup := DuplexMode;
      Printer.SetPrintParams(Report.PrintOptions.PrintOnSheet,
        SheetWidth, SheetHeight, orient, Page.Bin, Integer(dup) + 1, 1);
      PagePrinted := True;
      Printer.BeginDoc;

      { start the cycle }
      pieceX := Page.PaperWidth * (Printer.DPI.X / 25.4);
      pieceY := Page.PaperHeight * (Printer.DPI.Y / 25.4);

      Index := -1;
      while Index < MaxCount - 1 do
      begin
        cp := 1;
        offsY := -Printer.TopMargin * Printer.DPI.Y / 25.4;
        Printer.BeginPage;

        for y := 1 to countY do
        begin
          offsX := -Printer.LeftMargin * Printer.DPI.X / 25.4;

          for x := 1 to countX do
          begin
            { get the next page }
            FCopyNo := cp;
            if cp = 1 then
              Page := GetNextPage(Index);
            Inc(cp);
            if cp > Report.PrintOptions.Copies then
              cp := 1;

            if Page = nil then break;

            DrawPage(Index, Printer.Canvas, Printer.DPI.X / 96, Printer.DPI.Y / 96,
              offsX, offsY);

            offsX := offsX + pieceX;
          end;

          if Page = nil then break;
          offsY := offsY + pieceY;
        end;


        Printer.EndPage;

        Report.InternalOnProgress(ptPrinting, Index);
        Application.ProcessMessages;
        if Report.Terminated then
        begin
          Printer.Abort;
          Exit;
        end;

        Inc(PagesPrinted);
        ClearPageCache;
      end;
    end;

  begin
    Printer := frxPrinters.Printer;
    Report.Terminated := False;
    Report.InternalOnProgressStart(ptPrinting);

    if Report.ReportOptions.Name <> '' then
      Printer.Title := Report.ReportOptions.Name else
      Printer.Title := Report.FileName;
    if Report.PrintOptions.Copies <= 0 then
      Report.PrintOptions.Copies := 1;

    MaxCount := Count;


    PagePrinted := False;
    LastDuplexMode := dmNone;

    if Report.PrintOptions.Collate then
      for i := 0 to Report.PrintOptions.Copies - 1 do
      begin
        ACopyNo := i + 1;
        case Report.PrintOptions.PrintMode of
          pmDefault, pmScale:
            PrintPages;
          pmSplit:
            PrintSplittedPages;
          pmJoin:
            PrintJoinedPages;
        end;
        if (LastDuplexMode in [dmVertical, dmHorizontal]) and (PagesPrinted mod 2 <> 0) then
        begin
          Printer.BeginPage;
          Printer.EndPage;
        end;

        if Report.Terminated then break;
      end
    else
    begin
      case Report.PrintOptions.PrintMode of
        pmDefault, pmScale:
          PrintPages;
        pmSplit:
          PrintSplittedPages;
        pmJoin:
          PrintJoinedPages;
      end;
    end;

    if PagePrinted then
      Printer.EndDoc;
    Report.InternalOnProgressStop(ptPrinting);
  end;

begin
  Result := True;
  FPrintScale := 1;

  if Report.DotMatrixReport and (frxDotMatrixExport <> nil) then
  begin
    Report.SelectPrinter;
    frxDotMatrixExport.ShowDialog := Report.PrintOptions.ShowDialog;
    Result := Export(frxDotMatrixExport);
    Exit;
  end;

  SavePrintOptions := TfrxPrintOptions.Create;
  SavePrintOptions.Assign(Report.PrintOptions);
  DuplexMode := dmNone;
  Report.SelectPrinter;

  if Report.PrintOptions.ShowDialog then
    with TfrxPrintDialog.Create(Application) do
    begin
      AReport := Report;
      ADuplexMode := DuplexMode;
      ShowModal;
      if ModalResult = mrOk then
      begin
        DuplexMode := ADuplexMode;
        Free;
      end
      else
      begin
        Free;
        FCopyNo := 0;
        Result := False;
        SavePrintOptions.Free;
        Exit;
      end;
    end;

  if Report.PrintOptions.PrintMode <> pmDefault then
  begin
    frxPrinters.Printer.SetViewParams(Report.PrintOptions.PrintOnSheet, 0, 0, poPortrait);
    SheetWidth := frxPrinters.Printer.PaperWidth;
    SheetHeight := frxPrinters.Printer.PaperHeight;
    SplitAddX := 3;
    SplitAddY := 3;
  end;

  if Assigned(Report.OnPrintReport) then
    Report.OnPrintReport(Report);

  if Report.Preview <> nil then
    Report.Preview.Lock;
  pgList := TStringList.Create;
  try
    frxParsePageNumbers(Report.PrintOptions.PageNumbers, pgList, Count);
    ClearPageCache;
    DoPrint;
  finally
    if Assigned(Report.OnAfterPrintReport) then
      Report.OnAfterPrintReport(Report);
    FCopyNo := 0;
    Report.PrintOptions.Assign(SavePrintOptions);
    SavePrintOptions.Free;
    pgList.Free;
  end;
end;

function TfrxPreviewPages.Export(Filter: TfrxCustomExportFilter): Boolean;
var
  pgList: TStringList;
  tempBMP: TBitmap;

  procedure ExportPage(Index: Integer);
  var
    i, j: Integer;
    Page: TfrxReportPage;
    c: TfrxComponent;
    p: TfrxPictureView;


    procedure ExportObject(c: TfrxComponent);
    begin
      if c is TfrxCustomMemoView then
      begin
        { set up font if Highlight is active }
        if TfrxCustomMemoView(c).Highlight.Active then
          TfrxCustomMemoView(c).Font.Assign(TfrxCustomMemoView(c).Highlight.Font);
        { needed for TOTALPAGES, COPYNAME macros }
        THackMemoView(c).FTotalPages := Count;
        THackMemoView(c).FCopyNo := 1;
        THackMemoView(c).ExtractMacros;
        { needed if memo has AutoWidth and Align properties }
        if THackMemoView(c).AutoWidth then
          THackMemoView(c).Draw(tempBMP.Canvas, 1, 1, 0, 0);
      end;
      Filter.ExportObject(c);
    end;

  begin
    if Index >= Count then Exit;
    if (pgList.Count <> 0) and (pgList.IndexOf(IntToStr(Index + 1)) = -1) then Exit;
    Page := GetPage(Index);
    if Page = nil then Exit;

    if Filter.ShowProgress then
      Report.InternalOnProgress(ptExporting, Index + 1);

    Filter.StartPage(Page, Index);
    try
      { set the offset of the page objects }
      if Page.MirrorMargins and (Index mod 2 = 1) then
        Page.Left := Page.RightMargin * fr01cm else
        Page.Left := Page.LeftMargin * fr01cm;
      Page.Top := Page.TopMargin * fr01cm;

      { export the page background picture and frame }
      p := TfrxPictureView.Create(nil);
      p.Name := '_pagebackground';
      p.Color := Page.Color;
      p.Frame.Assign(Page.Frame);
      p.Picture.Assign(Page.BackPicture);
      p.Stretched := True;
      p.KeepAspectRatio := False;
      try
        p.SetBounds(Page.Left, Page.Top,
          Page.Width - (Page.LeftMargin + Page.RightMargin) * fr01cm,
          Page.Height - (Page.TopMargin + Page.BottomMargin) * fr01cm);
        Filter.ExportObject(p);
      finally
        p.Free;
      end;


      for i := 0 to Page.Objects.Count - 1 do
      begin
        c := Page.Objects[i];
        if c is TfrxBand then
        begin
          if c is TfrxPageHeader then
          begin
            { suppress a header }
            if Filter.SuppressPageHeadersFooters and (Index <> 0) then continue;
          end;
          if c is TfrxPageFooter then
          begin
            { suppress a footer }
            if Filter.SuppressPageHeadersFooters and (Index <> Count - 1) then continue;
          end;
        end;

        ExportObject(c);
        if c.Objects.Count <> 0 then
          for j := 0 to c.Objects.Count - 1 do
            ExportObject(c.Objects[j]);
      end;

    finally
      Filter.FinishPage(Page, Index);
    end;

    if Report.Preview = nil then
      ClearPageCache
    else
    begin
      Page.Left := 0;
      Page.Top := 0;
    end;
  end;

  procedure DoExport;
  var
    i: Integer;
  begin
    if Filter.Start then
      try
        if Report.Preview <> nil then
        begin
          Report.Preview.Refresh;
          Report.Preview.Lock;
        end;

        if Filter.ShowProgress then
          Report.InternalOnProgressStart(ptExporting);


        for i := 0 to Count - 1 do

        begin
          ExportPage(i);
          if Report.Terminated then break;
          Application.ProcessMessages;
        end;

      finally
        if Report.Preview <> nil then
        begin
          TfrxPreview(Report.Preview).HideMessage;
          Report.Preview.Refresh;
        end;

        if Filter.ShowProgress then
          Report.InternalOnProgressStop(ptExporting);

        Filter.Finish;
      end;
  end;

begin
  Result := False;
  FCopyNo := 0;
  if Filter = nil then Exit;

  Filter.Report := Report;
  if (Filter.ShowDialog and (Filter.ShowModal <> mrOk)) then
    Exit;
  if Filter.CurPage then
    if Report.Preview <> nil then
      Filter.PageNumbers := IntToStr(CurPreviewPage) else
      Filter.PageNumbers := '1';

  Result := True;
  Report.Terminated := False;

  pgList := TStringList.Create;
  tempBMP := TBitmap.Create;
  try
    frxParsePageNumbers(Filter.PageNumbers, pgList, Count);

    if Filter = frxDotMatrixExport then
      if Assigned(Report.OnPrintReport) then
        Report.OnPrintReport(Report);

    try
      DoExport;
    except
      on e: Exception do
      begin
        Result := False;
        Report.Errors.Text := e.Message;
        frxCommonErrorHandler(Report, frxResources.Get('clErrors') + #13#10 + Report.Errors.Text);
      end;
    end;

    if Filter = frxDotMatrixExport then
      if Assigned(Report.OnAfterPrintReport) then
        Report.OnAfterPrintReport(Report);
  finally
    pgList.Free;
    tempBMP.Free;
  end;
end;

procedure TfrxPreviewPages.ObjectOver(Index: Integer; X, Y: Integer;
  Button: TMouseButton; Shift: TShiftState; Scale, OffsetX, OffsetY: Extended;
  Click: Boolean; var Cursor: TCursor);
var
  Page: TfrxReportPage;
  c: TfrxComponent;
  l: TList;
  i: Integer;
  Flag: Boolean;
  v: TfrxView;
  drill: TfrxGroupHeader;
  drillName: String;

  function MouseInView(c: TfrxComponent): Boolean;
  var
    r: TRect;
  begin
    with c do
      r := Rect(Round(AbsLeft * Scale), Round(AbsTop * Scale),
                Round((AbsLeft + Width) * Scale),
                Round((AbsTop + Height) * Scale));
    OffsetRect(r, Round(OffsetX), Round(OffsetY));
    Result := PtInRect(r, Point(X, Y));
  end;

  procedure SetToAnchor(const Text: String);
  var
    Item: TfrxXMLItem;
    PageN, Top: Integer;
  begin
    Item := FindAnchor(Text);
    if Item <> nil then
    begin
      PageN := StrToInt(Item.Prop['page']);
      Top := StrToInt(Item.Prop['top']);
      TfrxPreview(Report.Preview).SetPosition(PageN + 1, Top);
    end;
  end;

begin
  if (Index < 0) or (Index >= Count) or Engine.Running then Exit;
  Page := GetPage(Index);
  if Page = nil then Exit;

  if Page.MirrorMargins and (Index mod 2 = 1) then
    OffsetX := OffsetX + Page.RightMargin * fr01cm * Scale else
    OffsetX := OffsetX + Page.LeftMargin * fr01cm * Scale;
  OffsetY := OffsetY + Page.TopMargin * fr01cm * Scale;

  Report.SetProgressMessage('');
  Page := GetPage(Index); // get page again to ensure it was not cleared during export
  if Page = nil then Exit;

  drill := nil;
  l := Page.AllObjects;

  for i := l.Count - 1 downto 0 do
  begin
    c := l[i];
    if (c is TfrxGroupHeader) and MouseInView(c) then
      if TfrxGroupHeader(c).DrillDown then
      begin
        drill := TfrxGroupHeader(c);
        break;
      end;

    if (c is TfrxView) and MouseInView(c) then
    begin
      v := TfrxView(c);
      if (v.Parent is TfrxGroupHeader) and TfrxGroupHeader(v.Parent).DrillDown then
      begin
        drill := TfrxGroupHeader(v.Parent);
        break;
      end;
      if v.Cursor <> crDefault then
        Cursor := v.Cursor;
      if v.URL <> '' then
      begin
        Report.SetProgressMessage(v.URL);
        if v.Cursor = crDefault then
          Cursor := crHandPoint;
      end;

      if Click then
      begin
        if v.URL <> '' then
          if Pos('@', v.URL) = 1 then
            TfrxPreview(Report.Preview).PageNo := StrToInt(Copy(v.URL, 2, 255))
          else if Pos('#', v.URL) = 1 then
            SetToAnchor(Copy(v.URL, 2, 255))
          else
            ShellExecute(GetDesktopWindow, nil, PChar(v.URL), nil, nil, sw_ShowNormal);

        Flag := False;
        Report.DoPreviewClick(v, Button, Shift, Flag);
        if Flag then
        begin
          ModifyPage(Index, Page);
          Report.Preview.Invalidate;
        end;
      end
      else if Assigned(Report.OnMouseOverObject) then
        Report.OnMouseOverObject(v);
      break;
    end;
  end;

  if drill <> nil then
  begin
    Cursor := crHandPoint;
    if Click and (Button = mbLeft) then
    begin
      drillName := drill.Name + '.' + IntToStr(drill.Tag);
      if Report.DrillState.IndexOf(drillName) = -1 then
        Report.DrillState.Add(drillName)
      else
        Report.DrillState.Delete(Report.DrillState.IndexOf(drillName));
      Report.Preview.RefreshReport;
    end;
  end;
end;

end.


//0f31356a91fea3356e5f76cdce90aa7b