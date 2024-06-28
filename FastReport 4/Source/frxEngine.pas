
{******************************************}
{                                          }
{             FastReport v4.0              }
{              Report engine               }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxEngine;

interface

{$I frx.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs,
  frxClass, frxAggregate, frxXML, frxDMPClass
{$IFDEF Delphi6}
, Variants
{$ENDIF};
  

type
  { TfrxHeaderList holds a set of bands that should appear on each new page.
    This includes page header, column header and header bands with
    "Reprint on new page" setting }

  TfrxHeaderListItem = class(TObject)
  public
    Band: TfrxBand;
    Left: Extended;
    IsInKeepList: Boolean;
  end;

  TfrxHeaderList = class(TObject)
  private
    FList: TList;
    function GetCount: Integer;
    function GetItems(Index: Integer): TfrxHeaderListItem;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure AddItem(ABand: TfrxBand; ALeft: Extended; AInKeepList: Boolean);
    procedure RemoveItem(ABand: TfrxBand);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TfrxHeaderListItem read GetItems; default;
  end;

  TfrxEngine = class(TfrxCustomEngine)
  private
    FAggregates: TfrxAggregateList;
    FCallFromAddPage: Boolean;
    FCallFromEndPage: Boolean;
    FCurBand: TfrxBand;
    FDontShowHeaders: Boolean;
    FHeaderList: TfrxHeaderList; { list of header bands }
    FFirstReportPage: Boolean;   { needed for correct setting of PreviewPages.FirstPage }
    FIsFirstBand: Boolean;       { needed for KeepTogether }
    FIsFirstPage: Boolean;       { first and last page flags }
    FIsLastPage: Boolean;        {                           }
    FKeepBand: TfrxBand;
    FKeepFooter: Boolean;
    FKeeping: Boolean;
    FKeepOutline: TfrxXMLItem;
    FKeepPosition: Integer;
    FKeepAnchor: Integer;
    FOutputTo: TfrxNullBand;     { used in the subreports }
    FPage: TfrxReportPage;       { currently proceeded page }
    FPageCurX: Extended;
    FStartNewPageBand: TfrxBand; { needed in addpage }
    FVHeaderList: TList;         { list of vheader bands }
    FVMasterBand: TfrxBand;      { master hband for vbands }
    FVPageList: TList;           { list of page breaks for vbands }
    procedure AddBandOutline(Band: TfrxBand);
    procedure AddColumn;
    procedure AddPage;
    procedure AddPageOutline;
    procedure AddToHeaderList(Band: TfrxBand);
    procedure AddToVHeaderList(Band: TfrxBand);
    procedure CheckBandColumns(Band: TfrxDataBand; ColumnKeepPos: Integer;
      SaveCurY: Extended);
    procedure CheckDrill(Master: TfrxDataBand; Band: TfrxGroupHeader);
    procedure CheckGroups(Master: TfrxDataBand; Band: TfrxGroupHeader;
      ColumnKeepPos: Integer; SaveCurY: Extended);
    procedure CheckSubReports(Band: TfrxBand);
    procedure DoShow(Band: TfrxBand);
    procedure DrawSplit(Band: TfrxBand);
    procedure EndColumn;
    procedure EndKeep(Band: TfrxBand);
    procedure Finalize;
    procedure InitGroups(Master: TfrxDataBand; Band: TfrxGroupHeader;
      Index: Integer; ResetLineN: Boolean = False);
    procedure InitPage;
    procedure NotifyObjects(Band: TfrxBand);
    procedure OutlineRoot;
    procedure OutlineUp(Band: TfrxBand);
    procedure PreparePage(ErrorList: TStrings; PrepareVBands: Boolean);
    procedure PrepareShiftTree(Band: TfrxBand);
    procedure RemoveFromHeaderList(Band: TfrxBand);
    procedure RemoveFromVHeaderList(Band: TfrxBand);
    procedure ResetSuppressValues(Band: TfrxBand);
    procedure RunPage(Page: TfrxReportPage);
    procedure RunReportPages;
    procedure ShowGroupFooters(Band: TfrxGroupHeader; Index: Integer; Master: TfrxDataBand);
    procedure ShowVBands(HBand: TfrxBand);
    procedure StartKeep(Band: TfrxBand; Position: Integer = 0);
    procedure Stretch(Band: TfrxBand);
    procedure UnStretch(Band: TfrxBand);
    function CanShow(Obj: TObject; PrintIfDetailEmpty: Boolean): Boolean;
    function FindBand(Band: TfrxBandClass): TfrxBand;
    function Initialize: Boolean;
    function RunDialogs: Boolean;
  protected
  public
    constructor Create(AReport: TfrxReport); override;
    destructor Destroy; override;
    procedure EndPage; override;
    procedure NewColumn; override;
    procedure NewPage; override;
    function Run: Boolean; override;
    procedure ShowBand(Band: TfrxBand); overload; override;
    procedure ShowBand(Band: TfrxBandClass); overload; override;
    function FooterHeight: Extended; override;
    function FreeSpace: Extended; override;
    function GetAggregateValue(const Name, Expression: String;
      Band: TfrxBand; Flags: Integer): Variant; override;
  end;


implementation

uses frxUtils, frxPreviewPages, frxRes;

type
  THackComponent = class(TfrxComponent);
  THackMemoView = class(TfrxCustomMemoView);


{ TfrxHeaderList }

constructor TfrxHeaderList.Create;
begin
  FList := TList.Create;
end;

destructor TfrxHeaderList.Destroy;
begin
  Clear;
  FList.Free;
  inherited;
end;

procedure TfrxHeaderList.Clear;
begin
  while FList.Count > 0 do
  begin
    TObject(FList[0]).Free;
    FList.Delete(0);
  end;
end;

function TfrxHeaderList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TfrxHeaderList.GetItems(Index: Integer): TfrxHeaderListItem;
begin
  Result := FList[Index];
end;

procedure TfrxHeaderList.AddItem(ABand: TfrxBand; ALeft: Extended; AInKeepList: Boolean);
var
  Item: TfrxHeaderListItem;
begin
  Item := TfrxHeaderListItem.Create;
  Item.Band := ABand;
  Item.Left := ALeft;
  Item.IsInKeepList := AInKeepList;
  FList.Add(Item);
end;

procedure TfrxHeaderList.RemoveItem(ABand: TfrxBand);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if Items[i].Band = ABand then
    begin
      Items[i].Free;
      FList.Delete(i);
      break;
    end;
end;


{ TfrxEngine }

constructor TfrxEngine.Create(AReport: TfrxReport);
begin
  inherited;
  FHeaderList := TfrxHeaderList.Create;
  FVHeaderList := TList.Create;
  FVPageList := TList.Create;
  FAggregates := TfrxAggregateList.Create(AReport);
end;

destructor TfrxEngine.Destroy;
begin
  FHeaderList.Free;
  FVHeaderList.Free;
  FVPageList.Free;
  FAggregates.Free;
  inherited;
end;

function TfrxEngine.Initialize: Boolean;
var
  i, j: Integer;
  b: TfrxDataBand;
begin
  PreviewPages.Initialize;
  StartDate := Date;
  StartTime := Time;
  Running := True;
  FKeeping := False;
  CurVColumn := 0;
  FOutputTo := nil;

  { clear all aggregate items }
  FAggregates.Clear;

  { add all report pages to the PreviewPages }
  for i := 0 to Report.PagesCount - 1 do
    if Report.Pages[i] is TfrxReportPage then
    begin
      { set the current page }
      FPage := TfrxReportPage(Report.Pages[i]);
      { create band tree for the current page }
      PreparePage(Report.Errors, False);
      PreparePage(Report.Errors, True);
    end;

  { check datasets used }
  for i := 0 to Report.PagesCount - 1 do
    if Report.Pages[i] is TfrxReportPage then
    begin
      FPage := TfrxReportPage(Report.Pages[i]);
      if (Report.DataSet <> nil) and (Report.DataSet = FPage.DataSet) then
      begin
        Report.Errors.Add('Cannot use the same dataset for Report.DataSet and Page.DataSet');
        break;
      end;
      for j := 0 to FPage.FSubBands.Count - 1 do
      begin
        b := FPage.FSubBands[j];
        if (b <> nil) and (b.DataSet <> nil) then
          if Report.DataSet = b.DataSet then
          begin
            Report.Errors.Add('Cannot use the same dataset for Report.DataSet and Band.DataSet');
            break;
          end
          else if FPage.DataSet = b.DataSet then
          begin
            Report.Errors.Add('Cannot use the same dataset for Page.DataSet and Band.DataSet');
            break;
          end
      end;
    end;

  Result := Report.Errors.Count = 0;
end;

procedure TfrxEngine.Finalize;
begin
  try
    Report.DataSets.Finalize;
  finally
    PreviewPages.Finish;
    Running := False;
  end;
end;

function TfrxEngine.Run: Boolean;
var
  i: Integer;
begin
  Result := False;
  try
    if Initialize then
      try
        Report.DataSets.Initialize;
        Report.DoNotifyEvent(Report, Report.OnStartReport);
        if RunDialogs then
        begin
          Result := True;

          { add all report pages to the PreviewPages }
          for i := 0 to Report.PagesCount - 1 do
            if Report.Pages[i] is TfrxReportPage then
            begin
              FPage := TfrxReportPage(Report.Pages[i]);
              PreviewPages.AddSourcePage(FPage);
              { find aggregates }
              FAggregates.AddItems(FPage);
            end;

          { start the report }
          FinalPass := not DoublePass;
          TotalPages := 0;
          PreviewPages.BeginPass;
          RunReportPages;
          if DoublePass then
          begin
            TotalPages := PreviewPages.Count;
            PreviewPages.ClearFirstPassPages;
            FAggregates.ClearValues;
            FinalPass := True;
            RunReportPages;
          end;
        end
      finally
        Report.DoNotifyEvent(Report, Report.OnStopReport);
      end;
  finally
    Finalize;
  end;
end;

{$HINTS OFF}
function TfrxEngine.RunDialogs: Boolean;
var
  i: Integer;
  p: TfrxDialogPage;
  v: Variant;
begin
  Result := True;
{$IFNDEF FR_VER_BASIC}
  if Trim(Report.OnRunDialogs) <> '' then
  begin
    v := VarArrayOf([True]);
    Report.DoParamEvent(Report.OnRunDialogs, v);
    Result := v[0];
  end
  else
    for i := 0 to Report.PagesCount - 1 do
      if (Report.Pages[i] is TfrxDialogPage) and Report.Pages[i].Visible then
      begin
        p := TfrxDialogPage(Report.Pages[i]);
        { refresh the border style - it was bsSizeable in the designer }
        p.DialogForm.BorderStyle := p.BorderStyle;
        { don't show empty form }
        if p.DialogForm.ControlCount <> 0 then
        begin
          if Assigned(OnRunDialog) then
            OnRunDialog(p) else
            p.ShowModal;
          if p.ModalResult = mrCancel then
          begin
            Result := False;
            break;
          end;
        end;
      end;
{$ENDIF}
end;
{$HINTS ON}

procedure TfrxEngine.RunReportPages;

  procedure DoPages;
  var
    i: Integer;
  begin
    for i := 0 to Report.PagesCount - 1 do
      if Report.Pages[i] is TfrxReportPage then
      begin
        FPage := TfrxReportPage(Report.Pages[i]);
         { ignore subreport pages and invisible pages }
        if not FPage.IsSubReport and FPage.Visible then
          RunPage(FPage);
        if Report.Terminated then break;
        FFirstReportPage := False;
      end;
  end;

begin
  FFirstReportPage := True;
  if Report.DataSet = nil then
    DoPages
  else
  begin
    Report.DataSet.First;
    while not Report.DataSet.Eof do
    begin
      if Report.Terminated then break;
      DoPages;
      Report.DataSet.Next;
    end;
  end;
end;

procedure TfrxEngine.PreparePage(ErrorList: TStrings; PrepareVBands: Boolean);
var
  i, j, k: Integer;
  t, c: TfrxComponent;
  b: TfrxBand;
  Bands: TList;
  SortBands: TStringList;

  procedure ClearNils;
  var
    i: Integer;
  begin
    i := 0;
    while i < Bands.Count do
      if Bands[i] = nil then
        Bands.Delete(i) else
        Inc(i);
  end;

  procedure MakeTree(Obj: TObject; From: Integer);
  var
    i: Integer;
    b: TfrxBand;
  begin
    if Obj is TfrxReportPage then
    begin
     { fill the first level - TfrxReportPage.FMasterBands }
      for i := 0 to Bands.Count - 1 do
      begin
        b := Bands[i];
        if b = nil then continue;
        if b is TfrxMasterData then
        begin
          if TfrxDataBand(b).DataSet <> nil then  { ignore empty datasets }
            if PrepareVBands then
              TfrxReportPage(Obj).FVSubBands.Add(b)
            else
              TfrxReportPage(Obj).FSubBands.Add(b);
          Bands[i] := nil;
          MakeTree(b, i + 1);
        end;
      end;
    end
    else
    begin
      { fill next levels - TfrxBand.FSubBands }
      for i := From to Bands.Count - 1 do
      begin
        b := Bands[i];
        if b = nil then continue;
        { looking for sub-level bands }
        if b.BandNumber = TfrxBand(Obj).BandNumber + 1 then
        begin
          if TfrxDataBand(b).DataSet <> nil then  { ignore empty datasets }
            TfrxBand(Obj).FSubBands.Add(b);
          Bands[i] := nil;
          if not (b is TfrxDataBand6) then
            MakeTree(b, i + 1);
        end
        else if b.BandNumber <= TfrxBand(Obj).BandNumber then
          break;   { found higher-level data band }
      end;
    end;
  end;

  procedure ConnectHeaders;
  var
    i: Integer;
    b1, b2: TfrxBand;
  begin
    for i := 0 to Bands.Count - 1 do
    begin
      b1 := Bands[i];
      { looking for data band }
      if b1 is TfrxDataBand then
      begin
        if i > 0 then
        begin
          b2 := Bands[i - 1];
          if b2 is TfrxHeader then  { if top band is header, connect it }
          begin
            b1.FHeader := b2;
            Bands[i - 1] := nil;
          end;
        end;

        if i < Bands.Count - 1 then { if bottom band is footer, connect it }
        begin
          b2 := Bands[i + 1];
          if b2 is TfrxFooter then
          begin
            b1.FFooter := b2;
            Bands[i + 1] := nil;
          end;
        end;
      end;
    end;

    ClearNils;
    { now all headers/footers must be connected. If not, add an error }
    for i := 0 to Bands.Count - 1 do
    begin
      b1 := Bands[i];
      if (b1 is TfrxHeader) or (b1 is TfrxFooter) then
      begin
        ErrorList.Add(frxResources.Get('enUnconnHeader') + ' ' + b1.Name);
        Bands[i] := nil;
      end;
    end;

    ClearNils;
  end;

  procedure ConnectGroups;
  var
    i, j: Integer;
    b1, b2: TfrxBand;
  begin
    { connect group headers }
    i := 0;
    while i < Bands.Count do
    begin
      b1 := Bands[i];
      if b1 is TfrxGroupHeader then
      begin
        b1.FSubBands.Add(b1);
        Inc(i);
        { add all subsequent headers to the first header's FSubBands }
        while (i < Bands.Count) and (TfrxBand(Bands[i]) is TfrxGroupHeader) do
        begin
          b1.FSubBands.Add(Bands[i]);
          Inc(i);
        end;

        { search for databand }
        while (i < Bands.Count) and not (TfrxBand(Bands[i]) is TfrxDataBand) do
          Inc(i);

        { now we expect to see the databand }
        if (i = Bands.Count) or not (TObject(Bands[i]) is TfrxDataBand) then
          ErrorList.Add(frxResources.Get('enUnconnGroup') + ' ' + b1.Name)
        else
          TfrxBand(Bands[i]).FGroup := b1;
      end
      else
        Inc(i);
    end;

    { connect group footers }
    for i := 0 to Bands.Count - 1 do
    begin
      b1 := Bands[i];
      if b1 is TfrxGroupFooter then
        for j := i - 1 downto 0 do
        begin
          b2 := Bands[j];
          if b2 is TfrxGroupHeader then  { connect to top-nearest header }
          begin
            b2.FFooter := b1;
            Bands[i] := nil;
            Bands[j] := nil;
            break;
          end;
        end;
    end;

    { remove header bands from the list }
    for i := 0 to Bands.Count - 1 do
    begin
      b1 := Bands[i];
      if b1 is TfrxGroupHeader then
        Bands[i] := nil;
    end;

    { looking for footers w/o corresponding header }
    for i := 0 to Bands.Count - 1 do
    begin
      b1 := Bands[i];
      if b1 is TfrxGroupFooter then
      begin
        ErrorList.Add(frxResources.Get('enUnconnGFooter') + ' ' + b1.Name);
        Bands[i] := nil;
      end;
    end;

    ClearNils;
  end;

begin
  SortBands := TStringList.Create;
  SortBands.Sorted := True;

  { align all objects with Align property <> baNone }
  FPage.AlignChildren;

  { clear all page SubBands }
  if PrepareVBands then
    FPage.FVSubBands.Clear
  else
    FPage.FSubBands.Clear;

  for i := 0 to FPage.Objects.Count - 1 do
  begin
    t := FPage.Objects[i];
    if t is TfrxBand then
    begin
      b := TfrxBand(t);
      if b.Vertical <> PrepareVBands then
        continue;
      PrepareShiftTree(b);
      b.FSubBands.Clear;
      b.FHeader := nil;
      b.FFooter := nil;
      b.FGroup := nil;
      b.FHasVBands := False;
      if b is TfrxDataBand then
        if (TfrxDataBand(b).DataSet = nil) and (TfrxDataBand(b).RowCount > 0) then
        begin
          TfrxDataBand(b).DataSet := TfrxDataBand(b).VirtualDataSet;
          TfrxDataBand(b).DataSet.Initialize;
        end;

      { connect objects to vertical bands }
      if (not PrepareVBands) and not (b is TfrxOverlay) then
        for j := 0 to FPage.Objects.Count - 1 do
        begin
          t := FPage.Objects[j];
          if (t is TfrxBand) and TfrxBand(t).Vertical then
          begin
            k := 0;
            while k < b.Objects.Count do
            begin
              c := b.Objects[k];
              if (c.Left >= t.Left - 1e-4) and
                (c.Left + c.Width <= t.Left + t.Width + 1e-4) then
              begin
                b.FHasVBands := True;
                c.Parent := t;
                THackComponent(c).FOriginalBand := b;
                c.Left := c.Left - t.Left;
              end
              else
                Inc(k);
            end;
          end;
        end;
    end;
  end;

  { sort bands by position }
  for i := 0 to FPage.Objects.Count - 1 do
  begin
    t := FPage.Objects[i];
    if t is TfrxBand then
    begin
      b := TfrxBand(t);
      if b.Vertical <> PrepareVBands then
        continue;
      if b.BandNumber in [4..13] then
        if b.Vertical then
          SortBands.AddObject(Format('%9.2f', [b.Left]), b)
        else
          SortBands.AddObject(Format('%9.2f', [b.Top]), b);
    end;
  end;

  { copy sorted items to TList - it's easier to work with it }
  Bands := TList.Create;
  for i := 0 to SortBands.Count - 1 do
  begin
    t := TfrxComponent(SortBands.Objects[i]);
    Bands.Add(t);
  end;

  SortBands.Free;

  ConnectGroups;
  ConnectHeaders;
  MakeTree(FPage, 0);

  ClearNils;
  for i := 0 to Bands.Count - 1 do
  begin
    t := Bands[i];
    ErrorList.Add(frxResources.Get('enBandPos') + ' ' + t.Name);
  end;

  Bands.Free;
end;

procedure TfrxEngine.PrepareShiftTree(Band: TfrxBand);
var
  i, j, k: Integer;
  c0, c1, c2, top: TfrxReportComponent;
  allObjects: TStringList;
  diff: Extended;
  Found: Boolean;
begin
  if Band.FShiftChildren.Count <> 0 then
    Exit;

  allObjects := TStringList.Create;
  allObjects.Duplicates := dupAccept;

  { temporary top object }
  top := TfrxMemoView.Create(nil);
  top.SetBounds(0, -2, Band.Width, 1);

  { sort objects }
  for i := 0 to Band.Objects.Count - 1 do
  begin
    c0 := Band.Objects[i];
    allObjects.AddObject(Format('%9.2f', [c0.Top]), c0);
    c0.FShiftChildren.Clear;
  end;
  allObjects.Sort;
  allObjects.InsertObject(0, Format('%10.2f', [top.Top]), top);

  for i := 0 to allObjects.Count - 1 do
  begin
    c0 := TfrxReportComponent(allObjects.Objects[i]);

    { find an object under c0 }
    for j := i + 1 to allObjects.Count - 1 do
    begin
      c1 := TfrxReportComponent(allObjects.Objects[j]);
      diff := c1.Top - (c0.Top + c0.Height);
      if (diff > -1e-4) and (c0.Left < c1.Left + c1.Width - 1e-4) and
        (c1.Left < c0.Left + c0.Width - 1e-4) then
      begin
        Found := False;

        { check if there is no other objects between c1 and c0 }
        for k := j - 1 downto i + 1 do
        begin
          c2 := TfrxReportComponent(allObjects.Objects[k]);
          if (c2.Top + c2.Height < c1.Top + 1e-4) and
            (c2.Top > c0.Top + c0.Height - 1e-4) and
            (c2.Left < c1.Left + c1.Width - 1e-4) and
            (c1.Left < c2.Left + c2.Width - 1e-4) then
          begin
            Found := True;
            break;
          end;
        end;

        if not Found then
          c0.FShiftChildren.Add(c1);
      end;
    end;
  end;

  { copy children from the top object to the band }
  for i := 0 to top.FShiftChildren.Count - 1 do
    Band.FShiftChildren.Add(top.FShiftChildren[i]);

  allObjects.Free;
  top.Free;
end;

function TfrxEngine.CanShow(Obj: TObject; PrintIfDetailEmpty: Boolean): Boolean;
var
  i: Integer;
  Bands: TList;
  b: TfrxDataBand;
  res: Boolean;
begin
  if Obj is TfrxReportPage then
    Bands := TfrxReportPage(Obj).FSubBands else
    Bands := TfrxBand(Obj).FSubBands;

  Result := True;
  { Check all subdetail bands to ensure they all have records }
  if not PrintIfDetailEmpty then
  begin
    Result := False;
    if (Bands.Count = 0) and not (Obj is TfrxPage) then
      Result := True;

    for i := 0 to Bands.Count - 1 do
    begin
      b := Bands[i];
      if b.DataSet <> nil then
      begin
        Report.DoNotifyEvent(b, b.OnMasterDetail);
        b.DataSet.First;

        while not b.DataSet.Eof do
        begin
          res := CanShow(b, b.PrintIfDetailEmpty);
          if res then
          begin
            Result := True;
            break;
          end
          else
            b.DataSet.Next;
        end;
      end;
    end;
  end;
end;

procedure TfrxEngine.ResetSuppressValues(Band: TfrxBand);
var
  i: Integer;
begin
  for i := 0 to Band.Objects.Count - 1 do
    if TObject(Band.Objects[i]) is TfrxCustomMemoView then
      THackMemoView(Band.Objects[i]).FLastValue := Null;
end;

procedure TfrxEngine.InitGroups(Master: TfrxDataBand; Band: TfrxGroupHeader;
  Index: Integer; ResetLineN: Boolean = False);
var
  i: Integer;
  b: TfrxGroupHeader;
begin
  for i := Index to Band.FSubBands.Count - 1 do
  begin
    b := Band.FSubBands[i];
    if ResetLineN then
    begin
      b.FLineN := 1;
      b.FLineThrough := 1;
      ResetSuppressValues(b);
    end
    else
    begin
      Inc(b.FLineN);
      if i < Band.FSubBands.Count - 1 then
        TfrxBand(Band.FSubBands[i + 1]).FLineN := 0;
      Inc(b.FLineThrough);
    end;
  end;

  CheckDrill(Master, Band);

  for i := Index to Band.FSubBands.Count - 1 do
  begin
    b := Band.FSubBands[i];
    CurLine := b.FLineN;
    CurLineThrough := b.FLineThrough;
    Report.CurObject := b.Name;
    b.FLastValue := Report.Calc(b.Condition);
    if b.KeepTogether then
      StartKeep(b);
    ShowBand(b);
    AddBandOutline(b);
    if b.Vertical then
      AddToVHeaderList(b)
    else
      AddToHeaderList(b);
  end;
end;

procedure TfrxEngine.ShowGroupFooters(Band: TfrxGroupHeader; Index: Integer;
  Master: TfrxDataBand);
var
  i: Integer;
  b: TfrxGroupHeader;
begin
  for i := Band.FSubBands.Count - 1 downto Index do
  begin
    b := Band.FSubBands[i];
    if b.FFooter <> nil then
      if not TfrxGroupFooter(b.FFooter).HideIfSingleDataRecord or (Master.FLineN > 2) then
        ShowBand(b.FFooter)
      else
        FAggregates.Reset(b.FFooter);

    OutlineUp(b);
    if b.Vertical then
      RemoveFromVHeaderList(b)
    else
      RemoveFromHeaderList(b);
    if b.KeepTogether then
      EndKeep(b);
  end;
end;

procedure TfrxEngine.CheckDrill(Master: TfrxDataBand; Band: TfrxGroupHeader);
var
  i, j: Integer;
  b, b1: TfrxGroupHeader;
  drillName: String;
  drillVisible: Boolean;
begin
  for i := 0 to Band.FSubBands.Count - 1 do
  begin
    b := Band.FSubBands[i];
    if b.DrillDown then
    begin
      drillName := b.Name + '.' + IntToStr(b.FLineThrough);
      drillVisible := Report.DrillState.IndexOf(drillName) <> -1;
      if b.ExpandDrillDown then
        drillVisible := not DrillVisible;
      for j := i + 1 to Band.FSubBands.Count - 1 do
      begin
        b1 := Band.FSubBands[j];
        b1.Visible := drillVisible;
        if b1.FFooter <> nil then
          b1.FFooter.Visible := drillVisible;
      end;
      Master.Visible := drillVisible;
      if not b.ShowFooterIfDrillDown and (b.FFooter <> nil) then
        b.FFooter.Visible := drillVisible;
      if not drillVisible then
        break;  
    end;
  end;
end;

procedure TfrxEngine.CheckGroups(Master: TfrxDataBand; Band: TfrxGroupHeader;
  ColumnKeepPos: Integer; SaveCurY: Extended);
var
  i: Integer;
  b: TfrxGroupHeader;
  NextNeeded: Boolean;
begin
  CheckDrill(Master, Band);
  
  for i := 0 to Band.FSubBands.Count - 1 do
  begin
    b := Band.FSubBands[i];

    Report.CurObject := b.Name;
    if Report.Calc(b.Condition) <> b.FLastValue then
    begin
      Master.CurColumn := Master.Columns;
      CheckBandColumns(Master, ColumnKeepPos, SaveCurY);

      { avoid exception in uni-directional datasets }
      NextNeeded := True;
      try
        Master.DataSet.Prior;
      except
        NextNeeded := False;
      end;
      ShowGroupFooters(Band, i, Master);
      if NextNeeded then
        Master.DataSet.Next;

      InitGroups(Master, Band, i);
      Master.FLineN := 1;
      ResetSuppressValues(Master);
      break;
    end;
  end;
end;

procedure TfrxEngine.CheckBandColumns(Band: TfrxDataBand; ColumnKeepPos: Integer;
  SaveCurY: Extended);
begin
  if Band.Columns > 1 then
  begin
    { collect max position in b.FMaxY }
    if CurY > Band.FMaxY then
      Band.FMaxY := CurY;
    { all columns have been printed }
    if Band.CurColumn >= Band.Columns then
    begin
      { need page break }
      if Band.FMaxY > PageHeight - FooterHeight then
      begin
        if FKeeping then  { standard keep procedure }
          NewColumn
        else
        begin
          PreviewPages.CutObjects(ColumnKeepPos);
          NewColumn;
          PreviewPages.PasteObjects(CurX, CurY);
          CurY := CurY + Band.FMaxY - SaveCurY;
        end;
      end
      else
        CurY := Band.FMaxY;  { start the new band from saved b.FMaxY }
    end
    else
      CurY := SaveCurY;   { start the new band from saved SaveCurY }
    if Band.Visible then
      Band.CurColumn := Band.CurColumn + 1;
  end;
end;

procedure TfrxEngine.NotifyObjects(Band: TfrxBand);
var
  i: Integer;
  c: TfrxComponent;
begin
  for i := 0 to NotifyList.Count - 1 do
  begin
    c := NotifyList[i];
    if c <> nil then
      c.OnNotify(Band);
  end;
end;

procedure TfrxEngine.RunPage(Page: TfrxReportPage);

  { "Null" band contains all free-placed objects that don't have a parent band }
  procedure ShowNullBand;
  var
    i: Integer;
    b: TfrxNullBand;
    SaveCurY: Extended;
  begin
    b := TfrxNullBand.Create(nil);
    b.Width := PageWidth;
    b.Height := PageHeight;
    SaveCurY := CurY;
    for i := 0 to FPage.Objects.Count - 1 do
      if not (TObject(FPage.Objects[i]) is TfrxBand) then
        b.Objects.Add(FPage.Objects[i]);
    try
      b.AlignChildren;
      ShowBand(b);
    finally
      CurY := SaveCurY;
      b.Objects.Clear;
      b.Free;
    end;
  end;

  { Band tree is the structure that we created in the PreparePage method }
  procedure ShowBandTree(Obj: TObject);
  var
    i: Integer;
    Bands: TList;
    b: TfrxDataBand;
    FirstTime: Boolean;
    FooterKeepPos, ColumnKeepPos: Integer;
    SaveCurY: Extended;
  begin
    Application.ProcessMessages;
    if Report.Terminated then Exit;

    FooterKeepPos := 0;
    ColumnKeepPos := 0;
    SaveCurY := CurY;
    if Obj is TfrxReportPage then
      Bands := TfrxReportPage(Obj).FSubBands else
      Bands := TfrxBand(Obj).FSubBands;

    for i := 0 to Bands.Count - 1 do
    begin
      b := Bands[i];
      if b.DataSet = nil then
        continue;
      b.DataSet.First;
      b.FLineN := 1;
      b.FLineThrough := 1;
      b.CurColumn := 1;
      FirstTime := True;
      ResetSuppressValues(b);

      while not b.DataSet.Eof do
      begin
        if CanShow(b, b.PrintIfDetailEmpty) then
        begin
          if FirstTime then
          begin
            if b.KeepTogether then
              StartKeep(b);
            if b.KeepHeader and (b.FHeader <> nil) then
              StartKeep(b);
            AddToHeaderList(b.FHeader);
            ShowBand(b.FHeader);
          end
          { keeping a master-detail differs from keeping a group }
          else if (b.FGroup = nil) and b.KeepTogether then
            StartKeep(b);

          if b.FGroup <> nil then
            if FirstTime then
              InitGroups(b, TfrxGroupHeader(b.FGroup), 0, True) else
              CheckGroups(b, TfrxGroupHeader(b.FGroup), ColumnKeepPos, SaveCurY);

          if b.KeepFooter then
            FooterKeepPos := PreviewPages.GetCurPosition;
          if (b.Columns > 1) and (b.CurColumn = 1) then
            ColumnKeepPos := PreviewPages.GetCurPosition;

          SaveCurY := CurY;
          CurLine := b.FLineN;
          CurLineThrough := b.FLineThrough;
          ShowBand(b);
          NotifyObjects(b);

          if FirstTime then
            if b.KeepHeader and (b.FHeader <> nil) then
              EndKeep(b);
          FirstTime := False;

          Inc(b.FLineN);
          Inc(b.FLineThrough);
          CheckBandColumns(b, ColumnKeepPos, SaveCurY);
          AddBandOutline(b);
          ShowBandTree(b);
          OutlineUp(b);
        end;

        FIsFirstBand := False;

        if b.FooterAfterEach then
          ShowBand(b.FFooter);

        { keeping a master-detail differs from keeping a group }
        if (b.FGroup = nil) and b.KeepTogether then
          EndKeep(b);
        b.DataSet.Next;
        if b.RowCount <> 0 then
          if b.FLineN > b.RowCount then break;

        if Report.Terminated then break;
      end;

      { update the CurY if band is multicolumn }
      b.CurColumn := b.Columns;
      CheckBandColumns(b, ColumnKeepPos, SaveCurY);

      if not FirstTime then { some bands have been printed }
      begin
        if b.FGroup <> nil then
          ShowGroupFooters(TfrxGroupHeader(b.FGroup), 0, b);

        if not b.FooterAfterEach then
        begin
          if b.KeepFooter then
            StartKeep(b, FooterKeepPos);
          FKeepFooter := True;
          ShowBand(b.FFooter);
          if b.KeepFooter then
            EndKeep(b);
          FKeepFooter := False;
        end;
        RemoveFromHeaderList(b.FHeader);
        if (b.FGroup <> nil) and b.KeepTogether then
          EndKeep(b);
      end;

      if Report.Terminated then break;
      FIsFirstBand := False;
    end;
  end;

  procedure ShowPage;
  var
    pgWidth, pgHeight: Extended;
  begin
    if CanShow(FPage, Report.EngineOptions.PrintIfEmpty) then
    begin
      InitPage;
      ShowNullBand;

      if Assigned(Report.OnManualBuild) then
        Report.OnManualBuild(FPage)
      else if Trim(FPage.OnManualBuild) <> '' then
        Report.DoNotifyEvent(FPage, FPage.OnManualBuild)
      else
        ShowBandTree(FPage);

      FIsLastPage := True;
      if FPage.EndlessHeight or FPage.EndlessWidth then
      begin
        PageHeight := CurY + FooterHeight;
        if FPage.EndlessWidth then
          pgWidth := PageWidth + FPage.LeftMargin * fr01cm + FPage.RightMargin * fr01cm
        else
          pgWidth := FPage.PaperWidth * fr01cm;
        if FPage.EndlessHeight then
          pgHeight := PageHeight + FPage.TopMargin * fr01cm + FPage.BottomMargin * fr01cm
        else
          pgHeight := FPage.PaperHeight * fr01cm;
        TfrxPreviewPages(PreviewPages).UpdatePageDimensions(FPage, pgWidth, pgHeight);
      end;
      EndPage;
      FIsLastPage := False;
    end;
  end;

begin
  { The Page parameter needed only for subreport pages. General is FPage }
  if Page.IsSubReport then
  begin
    ShowBandTree(Page);
    Exit;
  end;

  FIsFirstBand := True;
  Report.DoNotifyEvent(FPage, FPage.OnBeforePrint);

  if FPage.DataSet <> nil then
  begin
    FPage.DataSet.First;

    while not FPage.DataSet.Eof do
    begin
      if Report.Terminated then break;
      ShowPage;
      FPage.DataSet.Next;
    end;
  end
  else
    ShowPage;

  Report.DoNotifyEvent(FPage, FPage.OnAfterPrint);
end;

procedure TfrxEngine.ShowVBands(HBand: TfrxBand);

  procedure ShowBandTree(Bands: TList);
  var
    i: Integer;
    b: TfrxDataBand;
    FirstTime: Boolean;
  begin
    if Report.Terminated then Exit;

    for i := 0 to Bands.Count - 1 do
    begin
      b := Bands[i];
      if b.DataSet = nil then
        continue;
      b.DataSet.First;
      b.FLineN := 1;
      b.FLineThrough := 1;
      b.CurColumn := 1;
      FirstTime := True;
      ResetSuppressValues(b);

      while not b.DataSet.Eof do
      begin
        if FirstTime then
        begin
          ShowBand(b.FHeader);
          AddToVHeaderList(b.FHeader);
        end;

        if b.FGroup <> nil then
          if FirstTime then
            InitGroups(b, TfrxGroupHeader(b.FGroup), 0, True) else
            CheckGroups(b, TfrxGroupHeader(b.FGroup), 0, 0);

        FirstTime := False;

        CurLine := b.FLineN;
        CurLineThrough := b.FLineThrough;
        ShowBand(b);
        NotifyObjects(b);

        Inc(b.FLineN);
        Inc(b.FLineThrough);
        ShowBandTree(b.FSubBands);

        if b.FooterAfterEach then
          ShowBand(b.FFooter);

        b.DataSet.Next;
        if b.RowCount <> 0 then
          if b.FLineN > b.RowCount then break;
        if Report.Terminated then break;
      end;

      if b.FGroup <> nil then
        ShowGroupFooters(TfrxGroupHeader(b.FGroup), 0, b);

      if not FirstTime then { some bands have been printed }
      begin
        RemoveFromVHeaderList(b.FHeader);
        if not b.FooterAfterEach then
          ShowBand(b.FFooter);
      end;

      if Report.Terminated then break;
    end;
  end;

begin
  FVMasterBand := HBand;
  FVMasterBand.FOriginalObjectsCount := FVMasterBand.Objects.Count;
  FVMasterBand.AllowSplit := False;

  FVHeaderList.Clear;
  FVPageList.Clear;
  FVPageList.Add(Pointer(0));

  CurVColumn := 0;
  ShowBandTree(TfrxReportPage(HBand.Page).FVSubBands);
  FVPageList.Add(Pointer(FVMasterBand.Objects.Count));
end;

procedure TfrxEngine.InitPage;
begin
  { fill in the header/footer lists }
  FHeaderList.Clear;
  if FPage.TitleBeforeHeader then
  begin
    FHeaderList.AddItem(FindBand(TfrxReportTitle), 0, False);
    FHeaderList.AddItem(FindBand(TfrxPageHeader), 0, False);
  end
  else
  begin
    FHeaderList.AddItem(FindBand(TfrxPageHeader), 0, False);
    FHeaderList.AddItem(FindBand(TfrxReportTitle), 0, False);
  end;

  { calculating the page/footer sizes }
  PageHeight := FPage.PaperHeight * fr01cm - FPage.TopMargin * fr01cm -
    FPage.BottomMargin * fr01cm;
  PageWidth := FPage.PaperWidth * fr01cm - FPage.LeftMargin * fr01cm -
    FPage.RightMargin * fr01cm;

  { reset the current position }
  CurX := 0;
  CurY := 0;
  CurColumn := 1;
  FPageCurX := 0;
  FVMasterBand := nil;

  FIsFirstPage := True;
  FIsLastPage := False;

  if (PreviewPages.Count = 0) or not FPage.PrintOnPreviousPage then
    AddPage
  else
  begin
    PreviewPages.CurPage := PreviewPages.Count - 1;
    CurY := PreviewPages.GetLastY;
    RemoveFromHeaderList(FindBand(TfrxReportTitle));
    ShowBand(TfrxReportTitle);
  end;

  if FFirstReportPage then
    PreviewPages.FirstPage := PreviewPages.CurPage;
  HeaderHeight := CurY;
  ShowBand(TfrxColumnHeader);
  FHeaderList.AddItem(FindBand(TfrxColumnHeader), 0, False);
  RemoveFromHeaderList(FindBand(TfrxReportTitle));
  OutlineRoot;
  AddPageOutline;
end;

function TfrxEngine.FooterHeight: Extended;
var
  Band: TfrxBand;
begin
  Result := 0;

  Band := FindBand(TfrxColumnFooter);
  if Band <> nil then
    Result := Result + Band.Height;
  Band := FindBand(TfrxPageFooter);
  if Band <> nil then
    Result := Result + Band.Height;
end;

function TfrxEngine.FindBand(Band: TfrxBandClass): TfrxBand;
begin
  Result := FPage.FindBand(Band);
end;

procedure TfrxEngine.ShowBand(Band: TfrxBand);
var
  chBand: TfrxBand;
begin
  if Band <> nil then
  begin
    if Band.KeepChild then
      StartKeep(Band);
    DoShow(Band);
    chBand := Band.Child;
    if (chBand <> nil) and (Band.Visible or Band.PrintChildIfInvisible) then
      ShowBand(chBand);
    if Band.KeepChild then
      EndKeep(Band);
    if Band is TfrxDataBand then
      FAggregates.AddValue(Band);
  end;
end;

procedure TfrxEngine.ShowBand(Band: TfrxBandClass);
begin
  ShowBand(FindBand(Band));
end;

procedure TfrxEngine.AddToHeaderList(Band: TfrxBand);
begin
  { only header bands with "Reprint on new page" flag can be added }
  if ((Band is TfrxHeader) and TfrxHeader(Band).ReprintOnNewPage) or
     ((Band is TfrxGroupHeader) and TfrxGroupHeader(Band).ReprintOnNewPage) then
    FHeaderList.AddItem(Band, FPageCurX, FKeeping);
end;

procedure TfrxEngine.AddToVHeaderList(Band: TfrxBand);
begin
  { only header bands with "Reprint on new page" flag can be added }
  if ((Band is TfrxHeader) and TfrxHeader(Band).ReprintOnNewPage) or
     ((Band is TfrxGroupHeader) and TfrxGroupHeader(Band).ReprintOnNewPage) then
    FVHeaderList.Add(Band);
end;

procedure TfrxEngine.RemoveFromHeaderList(Band: TfrxBand);
begin
  if Band <> nil then
    FHeaderList.RemoveItem(Band);
end;

procedure TfrxEngine.RemoveFromVHeaderList(Band: TfrxBand);
begin
  if Band <> nil then
    FVHeaderList.Remove(Band);
end;

function TfrxEngine.FreeSpace: Extended;
begin
  if FPage.EndlessHeight then
    Result := 1e+6
  else
    Result := PageHeight - FooterHeight - CurY;
end;

procedure TfrxEngine.Stretch(Band: TfrxBand);
var
  i: Integer;
  h, maxh: Extended;
  c, maxc: TfrxView;
  HaveSub, NeedShift: Boolean;

  procedure DoSubReports;
  var
    i: Integer;
    SaveCurX, SaveCurY, SavePageCurX: Extended;
    Sub: TfrxSubReport;
    MainBand: Boolean;
    AllObjects: TList;
    c: TfrxComponent;
  begin
    { create a band which will accepts all subsequent output }
    MainBand := False;
    if FOutputTo = nil then
    begin
      Band.FOriginalObjectsCount := Band.Objects.Count;
      FOutputTo := TfrxNullBand.Create(nil);
      MainBand := True;
    end;

    { save the current position }
    SaveCurX := CurX;
    SaveCurY := CurY;
    SavePageCurX := FPageCurX;

    { looking for subreport objects }
    for i := 0 to Band.Objects.Count - 1 do
      if TObject(Band.Objects[i]) is TfrxSubReport then
      begin
        Sub := TfrxSubReport(Band.Objects[i]);
        if not Sub.Visible or not Sub.PrintOnParent or not MainBand then continue;

        { set up all properties... }
        FPageCurX := SavePageCurX + Sub.Left;
        CurX := SaveCurX + Sub.Left;
        CurY := Sub.Top;
        { ...and run the subreport }
        RunPage(Sub.Page);
      end;

    { restore saved position }
    CurX := SaveCurX;
    CurY := SaveCurY;
    FPageCurX := SavePageCurX;

    if MainBand then
    begin
      { copy all output to the band }
      AllObjects := FOutputTo.AllObjects;

      for i := 0 to AllObjects.Count - 1 do
      begin
        c := AllObjects[i];
        if (c is TfrxView) and not (c is TfrxSubReport) then
        begin
          c.Left := c.AbsLeft;
          c.Top := c.AbsTop;
          c.ParentFont := False;
          c.Parent := Band;
        end;
        if c is TfrxStretcheable then
          TfrxStretcheable(c).StretchMode := smDontStretch;
      end;

      { Clear the FOutputTo property. Extra objects will be freed
        in the Unstretch method. }
      FOutputTo.Free;
      FOutputTo := nil;
    end;
  end;

  procedure ShiftObjects(Parent: TfrxReportComponent; Amount: Extended);
  var
    i: Integer;
    v: TfrxView;
    diff: Extended;
  begin
    for i := 0 to Parent.FShiftChildren.Count - 1 do
    begin
      v := Parent.FShiftChildren[i];
      if v.ShiftMode = smAlways then
      begin
        v.Top := v.Top + Amount;
        ShiftObjects(v, Amount + v.FShiftAmount);
      end
      else if v.ShiftMode = smWhenOverlapped then
      begin
        if not (Parent is TfrxBand) and (v.Top < Parent.Top + Parent.Height) then
        begin
          diff := Parent.Top + Parent.Height - v.Top;
          v.Top := Parent.Top + Parent.Height;
          ShiftObjects(v, diff + v.FShiftAmount);
        end
        else
          ShiftObjects(v, v.FShiftAmount);
      end
      else if v.FShiftAmount <> 0 then
        ShiftObjects(v, Amount + v.FShiftAmount);

      v.FShiftAmount := 0;
    end;
  end;

begin
  FCurBand := Band;
  HaveSub := False;
  NeedShift := False;
  PrepareShiftTree(Band);

  { it is not necessary for vertical bands }
  if Band <> FVMasterBand then
  begin
    { firing band OnBeforePrint event }
    Report.CurObject := Band.Name;
    Band.BeforePrint;
    Report.DoBeforePrint(Band);
  end;

  { firing OnBeforePrint events, stretching objects }
  for i := 0 to Band.Objects.Count - 1 do
  begin
    c := Band.Objects[i];
    if (c is TfrxSubReport) and TfrxSubReport(c).PrintOnParent then
      HaveSub := True;

    { skip getdata for vertical bands' objects }
    if Band <> FVMasterBand then
    begin
      Report.CurObject := c.Name;
      c.BeforePrint;
      if Band.Visible then
      begin
        Report.DoBeforePrint(c);
        if c.Visible then
        begin
          c.GetData;
          Report.DoNotifyEvent(c, c.OnAfterData);
        end;
      end;
    end;
    if not Band.Visible or not c.Visible then continue;

    if (c is TfrxStretcheable) and (TfrxStretcheable(c).StretchMode <> smDontStretch) then
    begin
      h := TfrxStretcheable(c).CalcHeight;
      if h > c.Height then
      begin
        c.FShiftAmount := h - c.Height; { needed to shift underlying objects }
        c.Height := h;                  { stretch the object }
        NeedShift := True;
      end
      else
        c.FShiftAmount := 0;
    end;
  end;

  if not Band.Visible then Exit;

  { shift objects }
  if NeedShift then
    ShiftObjects(Band, 0);

  { check subreports that have PrintOnParent option }
  if HaveSub then
    DoSubReports;

  { calculate the max height of the band }
  maxh := 0;
  maxc := nil;
  for i := 0 to Band.Objects.Count - 1 do
  begin
    c := Band.Objects[i];
    if c.Top + c.Height > maxh then
    begin
      maxh := c.Top + c.Height;
      maxc := c;
    end;
  end;
  if (maxc <> nil) and (maxc is TfrxDMPMemoView) and
    (ftBottom in TfrxDMPMemoView(maxc).Frame.Typ) then
    maxh := maxh + fr1CharY;
  if Band.Stretched then
    Band.Height := maxh;

  { fire Band.OnAfterCalcHeight event }
  Report.CurObject := Band.Name;
  Report.DoNotifyEvent(Band, Band.OnAfterCalcHeight);

  { set the height of objects that should stretch to max height }
  for i := 0 to Band.Objects.Count - 1 do
  begin
    c := Band.Objects[i];
    if (c is TfrxStretcheable) and (TfrxStretcheable(c).StretchMode = smMaxHeight) then
    begin
      c.Height := maxh - c.Top;
      if (c is TfrxDMPMemoView) and (ftBottom in TfrxDMPMemoView(c).Frame.Typ) then
        c.Height := c.Height - fr1CharY;
    end;
  end;
end;

procedure TfrxEngine.UnStretch(Band: TfrxBand);
var
  i: Integer;
  c: TfrxView;
begin
  { fire OnAfterPrint event }
  if Band.Visible then
    for i := 0 to Band.Objects.Count - 1 do
    begin
      c := Band.Objects[i];
      Report.CurObject := c.Name;
      Report.DoAfterPrint(c);
    end;

  { restore state }
  for i := 0 to Band.Objects.Count - 1 do
  begin
    c := Band.Objects[i];
    c.AfterPrint;
  end;

  Report.CurObject := Band.Name;
  Report.DoAfterPrint(Band);
  Band.AfterPrint;

  { remove extra band objects if any }
  if Band.FOriginalObjectsCount <> -1 then
  begin
    while Band.Objects.Count > Band.FOriginalObjectsCount do
      TObject(Band.Objects[Band.Objects.Count - 1]).Free;
    Band.FOriginalObjectsCount := -1;
  end;
end;

procedure TfrxEngine.AddPage;
var
  i: Integer;
  SaveCurX: Extended;
  SaveCurLine, SaveCurLineThrough: Integer;
  Band: TfrxBand;
begin
  PreviewPages.AddPage(FPage);
  CurY := 0;

  Band := FindBand(TfrxOverlay);
  if (Band <> nil) and not TfrxOverlay(Band).PrintOnTop then
    ShowBand(Band);

  CurY := 0;
  SaveCurX := CurX;
  HeaderHeight := 0;

  for i := 0 to FHeaderList.Count - 1 do
  begin
   { use own CurX - we may be inside subreports now }
    CurX := FHeaderList[i].Left;
    Band := FHeaderList[i].Band;
    if Band = FStartNewPageBand then
      continue;

    if FIsFirstPage and (Band is TfrxPageHeader) and
      not TfrxPageHeader(Band).PrintOnFirstPage then
      continue;

    if Band <> nil then
      if not FKeeping or not FHeaderList[i].IsInKeepList then
      begin
        if (Band is TfrxHeader) and FDontShowHeaders then continue;
        Band.Overflow := True;
        SaveCurLine := CurLine;
        SaveCurLineThrough := CurLineThrough;
        CurLine := Band.FLineN;
        CurLineThrough := Band.FLineThrough;
        FCallFromAddPage := True;

        { fix the stack overflow error if call NewPage from ReportTitle }
        if Band is TfrxReportTitle then
          FHeaderList[i].Band := nil;
        if Band is TfrxPageHeader then
          HeaderHeight := Band.Height;

        ShowBand(Band);

        FCallFromAddPage := False;
        Band.Overflow := False;
        CurLine := SaveCurLine;
        CurLineThrough := SaveCurLineThrough;
      end;
  end;

  CurX := SaveCurX;
end;

procedure TfrxEngine.EndPage;
var
  Band: TfrxBand;

  procedure ShowBand(Band: TfrxBand);
  begin
    if Band = nil then Exit;

    Stretch(Band);
    try
      if Band.Visible then
      begin
        Band.Left := 0;
        Band.Top := CurY;

        if Band is TfrxPageFooter then
          if (FIsFirstPage and not TfrxPageFooter(Band).PrintOnFirstPage) or
             (FIsLastPage and not TfrxPageFooter(Band).PrintOnLastPage) then
          Exit;

        if not PreviewPages.BandExists(Band) then
          PreviewPages.AddObject(Band);
        CurY := CurY + Band.Height;
      end;
    finally
      UnStretch(Band);
    end;

    FAggregates.Reset(Band);
  end;

begin
  if FPage.Columns > 1 then
  begin
    EndColumn;
    if not FIsLastPage then
    begin
      CurX := FPageCurX;
      CurColumn := 1;
    end;
  end;

  ShowBand(FindBand(TfrxColumnFooter));

  if FIsLastPage and not FCallFromEndPage then
  begin
    { avoid stack overflow if reportsummary does not fit on the page }
    FCallFromEndPage := True;
    try
      Self.ShowBand(TfrxReportSummary);
    finally
      FCallFromEndPage := False;
    end;
  end;

  Band := FindBand(TfrxPageFooter);
  if Band <> nil then
    CurY := PageHeight - Band.Height;
  ShowBand(Band);

  Band := FindBand(TfrxOverlay);
  if (Band <> nil) and TfrxOverlay(Band).PrintOnTop then
  begin
    CurY := 0;
    ShowBand(Band);
  end;

  FIsFirstPage := False;
end;

procedure TfrxEngine.AddColumn;
var
  i: Integer;
  AddX: Extended;

  procedure DoShow(Band: TfrxBand);
  begin
    Band.Overflow := True;
    Stretch(Band);

    try
      if Band.Visible then
      begin
        Band.Left := CurX;
        Band.Top := CurY;
        PreviewPages.AddObject(Band);
        CurY := CurY + Band.Height;
      end;
    finally
      UnStretch(Band);
      Band.Overflow := False;
    end;
  end;

  procedure ShowBand(Band: TfrxBand);
  begin
    while Band <> nil do
    begin
      DoShow(Band);
      if Band.Visible or Band.PrintChildIfInvisible then
        Band := Band.Child else
        break;
    end;
  end;

begin
  CurColumn := CurColumn + 1;
  AddX := frxStrToFloat(FPage.ColumnPositions[CurColumn - 1]) * fr01cm;
  CurY := HeaderHeight;

  for i := 0 to FHeaderList.Count - 1 do
  begin
    CurX := FHeaderList[i].Left + AddX;
    if not (FHeaderList[i].Band is TfrxPageHeader) then
      ShowBand(FHeaderList[i].Band);
  end;

  CurX := FPageCurX + AddX;
end;

procedure TfrxEngine.EndColumn;
var
  Band: TfrxBand;
begin
  Band := FindBand(TfrxColumnFooter);
  if Band = nil then Exit;

  Stretch(Band);
  try
    if Band.Visible then
    begin
      Band.Left := CurX - FPageCurX;
      Band.Top := CurY;
      PreviewPages.AddObject(Band);
    end;
  finally
    UnStretch(Band);
  end;

  FAggregates.Reset(Band);
end;

procedure TfrxEngine.NewPage;
begin
  if FKeeping then
  begin
    if FKeepFooter then
      FAggregates.DeleteValue(FKeepBand);
    PreviewPages.CutObjects(FKeepPosition);
  end;
  EndPage;
  AddPage;
  if FKeeping then
  begin
    FAggregates.EndKeep;
    PreviewPages.PasteObjects(0, CurY);
    PreviewPages.Outline.ShiftItems(FKeepOutline, Round(CurY));
    PreviewPages.ShiftAnchors(FKeepAnchor, Round(CurY));
    CurY := PreviewPages.GetLastY;
    if FKeepFooter then
      FAggregates.AddValue(FKeepBand);
  end;
  FKeeping := False;
  AddPageOutline;
end;

procedure TfrxEngine.NewColumn;
begin
  if CurColumn >= FPage.Columns then
    NewPage
  else
  begin
    EndColumn;
    AddColumn;
  end;
end;

procedure TfrxEngine.DrawSplit(Band: TfrxBand);
var
  i: Integer;
  List, SaveObjects, ShiftedList: TList;
  View: TfrxView;
  StrView: TfrxStretcheable;
  CurHeight, Corr: Extended;

  procedure ShiftObjects(TopView: TfrxView; Delta: Extended);
  var
    i: Integer;
    View: TfrxView;
  begin
    for i := 0 to List.Count - 1 do
    begin
      View := List[i];
      if (View <> TopView) and (ShiftedList.IndexOf(View) = -1) and
         (View.Top >= TopView.Top + TopView.Height) and
         (View.Left < TopView.Left + TopView.Width) and
         (TopView.Left < View.Left + View.Width) then
      begin
        View.Top := View.Top + Delta;
        ShiftedList.Add(View);
      end;
    end;
  end;

  procedure DrawPart;
  var
    i: Integer;
    View: TfrxView;
  begin
    { draw current objects }
    Band.Left := CurX;
    Band.Top := CurY;
    PreviewPages.AddObject(Band);
    { add new column/page }
    if List.Count > 0 then
      NewColumn else
      CurY := CurY + Band.Height;

    { correct the top coordinate of remained objects }
    Band.Objects.Clear;
    for i := 0 to List.Count - 1 do
    begin
      View := List[i];
      View.Top := View.Top - CurHeight;
      { restore the height of stretched objects }
      if View is TfrxStretcheable then
      begin
        if View.Top < 0 then
          View.Top := 0;
        View.Height := TfrxStretcheable(View).FSaveHeight;
      end;
    end;
  end;

  procedure CalcBandHeight;
  var
    i: Integer;
    View: TfrxView;
  begin
    Band.Height := 0;
    { calculate the band's height }
    for i := 0 to Band.Objects.Count - 1 do
    begin
      View := Band.Objects[i];
      if View.Top + View.Height > Band.Height then
        Band.Height := View.Top + View.Height;
    end;

    { correct objects with StretchToMaxHeight or BandAlign = baBottom }
    if List.Count = 0 then
      for i := 0 to Band.Objects.Count - 1 do
      begin
        View := Band.Objects[i];
        if View.Align = baBottom then
          View.Top := Band.Height - View.Height
        else if (View is TfrxStretcheable) and
          (TfrxStretcheable(View).StretchMode = smMaxHeight) then
          View.Height := Band.Height - View.Top;
      end;
  end;

begin
  List := TList.Create;
  SaveObjects := TList.Create;
  ShiftedList := TList.Create;

  { initializing lists }
  for i := 0 to Band.Objects.Count - 1 do
  begin
    View := Band.Objects[i];
    if not (View is TfrxSubReport) then
      List.Add(View);
    SaveObjects.Add(View);
    if View is TfrxStretcheable then
    begin
      TfrxStretcheable(View).InitPart;
      TfrxStretcheable(View).FSaveHeight := View.Height;
    end;
  end;

  Band.Objects.Clear;

  CurHeight := FreeSpace;

  while List.Count > 0 do
  begin
    ShiftedList.Clear;
    i := 0;

    while i < List.Count do
    begin
      View := List[i];

      { whole object fits in the page }
      if View.Top + View.Height <= CurHeight then
      begin
        { add to band and remove from list }
        Band.Objects.Add(View);
        List.Remove(View);
        { prepare last part of text }
        if View is TfrxStretcheable then
          TfrxStretcheable(View).DrawPart;
        continue;
      end;

      if View is TfrxStretcheable then
      begin
        StrView := List[i];
        { view is inside draw area }
        if StrView.Top < CurHeight then
        begin
          { trying to place it }
          StrView.Height := CurHeight - StrView.Top;
          { DrawPart method returns the amount of unused space. If view
            can't fit in the height, this method returns the Height }
          Corr := StrView.DrawPart;
          { shift the underlying objects down }
          ShiftObjects(StrView, Corr);

          if Abs(Corr - StrView.Height) < 1e-4 then
          begin
            { view can't fit, return back the height and correct the top }
            StrView.Top := CurHeight;
            StrView.Height := StrView.FSaveHeight;
          end
          else
          begin
            { view can draw something }
            Band.Objects.Add(StrView);
            { decrease the remained height }
            StrView.FSaveHeight := StrView.FSaveHeight - StrView.Height + Corr;
          end;
        end;
      end
      else
      begin
        { non-stretcheable view can't be splitted, draw it in the next page }
        if View.Top < CurHeight then
        begin
          { shift the underlying objects down }
          ShiftObjects(View, CurHeight - View.Top);
          View.Top := CurHeight;
        end;
      end;

      Inc(i);
    end;

    { draw the visible part }
    CalcBandHeight;
    DrawPart;
    CurHeight := FreeSpace;
  end;

  { get objects back to the band }
  Band.Objects.Clear;
  for i := 0 to SaveObjects.Count - 1 do
    Band.Objects.Add(SaveObjects[i]);

  List.Free;
  SaveObjects.Free;
  ShiftedList.Free;
end;

procedure TfrxEngine.DoShow(Band: TfrxBand);
var
  IsMultiColumnBand, IsSplit: Boolean;
  TempBand: TfrxBand;
  SaveCurX: Extended;
  SavePageList: TList;
  SaveVMasterBand: TfrxBand;
  i: Integer;

  procedure RenderVBand;
  var
    i, j, SavePageN: Integer;
    SaveCurY: Extended;
    c: TfrxComponent;
    SaveObjects: TList;
  begin
    SaveObjects := TList.Create;
    SavePageN := PreviewPages.CurPage;
    SaveCurY := CurY;
    { the next NewPage call shouldn't form a new page }
    PreviewPages.AddPageAction := apWriteOver;

    { save hband objects }
    for i := 0 to FVMasterBand.Objects.Count - 1 do
      SaveObjects.Add(FVMasterBand.Objects[i]);

    for i := 0 to FVPageList.Count - 2 do
    begin
      FVMasterBand.Objects.Clear;
      for j := Integer(FVPageList[i]) to Integer(FVPageList[i + 1]) - 1 do
      begin
        c := SaveObjects[j];
        FVMasterBand.Objects.Add(c);
      end;
      PreviewPages.AddObject(FVMasterBand);

      if i <> FVPageList.Count - 2 then
      begin
        FDontShowHeaders := True;
        NewPage;
        FDontShowHeaders := False;
      end
      else
        EndPage;
    end;

    { restore hband objects }
    FVMasterBand.Objects.Clear;
    for i := 0 to SaveObjects.Count - 1 do
      FVMasterBand.Objects.Add(SaveObjects[i]);
    SaveObjects.Free;

    PreviewPages.CurPage := SavePageN;
    CurY := SaveCurY;
    CurX := SaveCurX;
    { the next NewPage call should form a new page }
    PreviewPages.AddPageAction := apAdd;
  end;

  procedure AddVBand;
  var
    i: Integer;
    c, c1: TfrxReportComponent;
  begin
    if Band is TfrxDataBand then
      CurVColumn := CurVColumn + 1;
    if (Band is TfrxFooter) or (Band is TfrxGroupFooter) then
      FCurBand := Band
    else
      FCurBand := FVMasterBand;

    { fire beforeprint }
    Report.CurObject := Band.Name;
    Band.BeforePrint;
    Report.DoBeforePrint(Band);

    if Band.Visible then
    begin
      if CurX + Band.Width > PageWidth then
        if FPage.EndlessWidth then
          PageWidth := PageWidth + Band.Width
        else
        begin
          CurX := 0;
          FVPageList.Add(Pointer(FVMasterBand.Objects.Count));
          { reprint headers }
          for i := 0 to FVHeaderList.Count - 1 do
            ShowBand(TfrxBand(FVHeaderList[i]));
        end;

      { find objects that intersect with vertical Band }
      for i := 0 to Band.Objects.Count - 1 do
      begin
        c := Band.Objects[i];
        if THackComponent(c).FOriginalBand = FVMasterBand then
        begin
          { fire beforeprint and getdata }
          Report.CurObject := c.Name;
          c.BeforePrint;
          Report.DoBeforePrint(c);
          c.GetData;
          Report.DoNotifyEvent(c, c.OnAfterData);

          { copy the object }
          c1 := TfrxReportComponent(c.NewInstance);
          c1.Create(FVMasterBand);
          c1.Assign(c);
          with THackComponent(c1) do
          begin
            FAliasName := THackComponent(c).FAliasName;
            FOriginalComponent := THackComponent(c).FOriginalComponent;
          end;
          c1.Left := c1.Left + CurX;

          { restore the object's state }
          c.AfterPrint;
        end;
      end;

      CurX := CurX + Band.Width;
    end;

    { fire afterprint }
    Report.CurObject := Band.Name;
    Report.DoAfterPrint(Band);
    Band.AfterPrint;

    if Band is TfrxDataBand then
      FAggregates.AddValue(FVMasterBand, CurVColumn);

    { reset aggregates }
    if (Band is TfrxFooter) or (Band is TfrxGroupFooter) then
      FAggregates.Reset(Band);
  end;

begin
  SavePageList := nil;
  SaveVMasterBand := nil;

  { make cross-bands }
  if Band.FHasVBands then
  begin
    SaveCurX := CurX;
    { fire onbeforeprint }
    Report.CurObject := Band.Name;
    Band.BeforePrint;
    Report.DoBeforePrint(Band);
    { show vertical bands }
    ShowVBands(Band);
    CurX := 0;
    { the next NewPage call should form a new page }
    PreviewPages.AddPageAction := apAdd;

    { save global variables - FVPageList and FVMasterBand }
    { they may be changed in the NewPage call, if cross has a h-header }
    { with ReprintOnNewPage option }
    SavePageList := TList.Create;
    for i := 0 to FVPageList.Count - 1 do
      SavePageList.Add(FVPageList[i]);
    SaveVMasterBand := FVMasterBand;
  end;

  { show one vertical band }
  if Band.Vertical then
  begin
    AddVBand;
    Exit;
  end;

  IsMultiColumnBand := (Band is TfrxDataBand) and (TfrxDataBand(Band).Columns > 1);
  IsSplit := False;

  { check for StartNewPage flag }
  if not FCallFromAddPage then
    if Band.Visible then { don't process invisible bands }
      if Band.StartNewPage then
        if FOutputTo = nil then
          if not (((Band is TfrxDataBand) or (Band is TfrxGroupHeader)) and (Band.FLineN = 1)) then
          begin
            FStartNewPageBand := Band;
            if (Band is TfrxGroupHeader) and (TfrxGroupHeader(Band).ResetPageNumbers) then
              PreviewPages.ResetLogicalPageNumber;
            NewPage;
            FStartNewPageBand := nil;
          end;

  Stretch(Band);
  try
    if Band.Visible then
    begin
      { if band has columns, print all columns in one page. Page feed will be
        performed after the last column }
      if not IsMultiColumnBand and not (Band is TfrxOverlay) and not (Band is TfrxNullBand) and
        (Band.Height > FreeSpace) then
        if FOutputTo = nil then
          if Band.AllowSplit then
          begin
            DrawSplit(Band);
            IsSplit := True;
          end
          else
            NewColumn;

      if not IsSplit then
      begin
        if not (Band is TfrxNullBand) then
        begin
          { multicolumn band manages its Left property itself }
          if IsMultiColumnBand then
            Band.Left := Band.Left + CurX else
            Band.Left := CurX;
          Band.Top := CurY;
        end;

        { output the band }
        if FOutputTo = nil then
        begin
          if Band.FHasVBands then
          begin
            { restore global variables - FVPageList and FVMasterBand }
            { they may be changed in the NewPage call, if cross has a h-header }
            { with ReprintOnNewPage option }
            FVPageList.Clear;
            for i := 0 to SavePageList.Count - 1 do
              FVPageList.Add(SavePageList[i]);
            SavePageList.Free;
            FVMasterBand := SaveVMasterBand;
            RenderVBand;
          end
          else if (not FCallFromAddPage) or (not PreviewPages.BandExists(Band)) then
            PreviewPages.AddObject(Band)
        end
        else
        begin
          TempBand := TfrxBand.Create(FOutputTo);
          TempBand.AssignAll(Band);
        end;

        { move the current position }
        CurY := CurY + Band.Height;
      end;
    end;
  finally
    UnStretch(Band);
  end;

  { reset aggregate values }
//  if (Band is TfrxFooter) or (Band is TfrxGroupFooter) or
//     (Band is TfrxPageFooter) or (Band is TfrxReportSummary) then
    FAggregates.Reset(Band);

  { print subreports contained in this band }
  if Band.Visible then
    CheckSubReports(Band);
end;

procedure TfrxEngine.CheckSubReports(Band: TfrxBand);
var
  i, SavePageN, SaveColumnN: Integer;
  SaveCurX, SaveCurY, SavePageCurX: Extended;
  HaveSub: Boolean;
  Sub: TfrxSubReport;
  MaxPageN, MaxColumnN: Integer;
  MaxCurY: Extended;
begin
  { save the current position }
  HaveSub := False;
  SavePageN := PreviewPages.CurPage;
  SaveColumnN := CurColumn;
  SaveCurX := CurX;
  SaveCurY := CurY;
  SavePageCurX := FPageCurX;

  { init max position }
  MaxPageN := SavePageN;      //0
  MaxColumnN := SaveColumnN;  //0
  MaxCurY := SaveCurY;        //0

  { looking for subreport objects }
  for i := 0 to Band.Objects.Count - 1 do
    if TObject(Band.Objects[i]) is TfrxSubReport then
    begin
      Sub := TfrxSubReport(Band.Objects[i]);
      if not Sub.Visible or Sub.PrintOnParent then continue;
      HaveSub := True;

      { set up all properties... }
      PreviewPages.CurPage := SavePageN;
      FPageCurX := SavePageCurX + Sub.Left;
      CurColumn := SaveColumnN;
      CurX := SaveCurX + Sub.Left;
      CurY := SaveCurY - Band.Height + Sub.Top; //SaveCurY - Sub.Height;
      { ...and run the subreport }
      RunPage(Sub.Page);

      { calc max position }
      if PreviewPages.CurPage > MaxPageN then
      begin
        MaxPageN := PreviewPages.CurPage;
        MaxColumnN := CurColumn;
        MaxCurY := CurY;
      end
      else if PreviewPages.CurPage = MaxPageN then
        if CurColumn > MaxColumnN then
        begin
          MaxColumnN := CurColumn;
          MaxCurY := CurY;
        end
        else if CurColumn = MaxColumnN then
          if CurY > MaxCurY then
            MaxCurY := CurY;
    end;

  { move the current position to the last generated page }
  if HaveSub then
  begin
    PreviewPages.CurPage := MaxPageN;
    CurColumn := MaxColumnN;
    CurX := SavePageCurX;
    if CurColumn > 1 then
      CurX := CurX + frxStrToFloat(FPage.ColumnPositions[CurColumn - 1]) * fr01cm;
    CurY := MaxCurY;
    FPageCurX := SavePageCurX;
  end;
end;

procedure TfrxEngine.StartKeep(Band: TfrxBand; Position: Integer = 0);
begin
  if FKeeping or FIsFirstBand then Exit;

  FKeeping := True;
  FKeepBand := Band;
  if Position = 0 then
    Position := PreviewPages.GetCurPosition;
  FKeepPosition := Position;
  FKeepOutline := PreviewPages.Outline.GetCurPosition;
  FKeepAnchor := PreviewPages.GetAnchorCurPosition;
  FAggregates.StartKeep;
end;

procedure TfrxEngine.EndKeep(Band: TfrxBand);
begin
  if FKeepBand = Band then
  begin
    FKeeping := False;
    FKeepBand := nil;
    FAggregates.EndKeep;
  end;
end;

function TfrxEngine.GetAggregateValue(const Name, Expression: String;
  Band: TfrxBand; Flags: Integer): Variant;
begin
  Result := FAggregates.GetValue(FCurBand, CurVColumn, Name, Expression, Band, Flags);
end;

procedure TfrxEngine.AddBandOutline(Band: TfrxBand);
begin
  if Band.OutlineText <> '' then
  begin
    Report.CurObject := Band.Name;
    PreviewPages.Outline.AddItem(VarToStr(Report.Calc(Band.OutlineText)),
      Round(CurY - Band.Height));
  end;
end;

procedure TfrxEngine.AddPageOutline;
begin
  if FPage.OutlineText <> '' then
  begin
    OutlineRoot;
    Report.CurObject := FPage.Name;
    PreviewPages.Outline.AddItem(VarToStr(Report.Calc(FPage.OutlineText)), 0);
  end;
end;

procedure TfrxEngine.OutlineRoot;
begin
  PreviewPages.Outline.LevelRoot;
end;

procedure TfrxEngine.OutlineUp(Band: TfrxBand);
begin
  if Band.OutlineText <> '' then
    PreviewPages.Outline.LevelUp;
end;


end.


//0f31356a91fea3356e5f76cdce90aa7b