
{******************************************}
{                                          }
{             FastReport v4.0              }
{         TeeChart Add-In Object           }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxChart;

interface

{$I frx.inc}
{$I tee.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Menus, Controls,

  frxClass,
  TeeProcs, TeEngine, Chart, Series, TeCanvas
{$IFDEF Delphi6}
, Variants
{$ENDIF};


type
  TfrxChartObject = class(TComponent);  // fake component

  TfrxSeriesDataType = (dtDBData, dtBandData, dtFixedData);
  TfrxSeriesSortOrder = (soNone, soAscending, soDescending);
  TfrxSeriesXType = (xtText, xtNumber, xtDate);
  TSeriesClass = class of TChartSeries;
  TfrxChartSeries = (csLine, csArea, csPoint, csBar, csHorizBar,
    csPie, csGantt, csFastLine, csArrow, csBubble, csChartShape, csHorizArea,
    csHorizLine, csPolar, csRadar, csPolarBar, csGauge, csSmith, csPyramid,
    csDonut, csBezier, csCandle, csVolume, csPointFigure, csHistogram,
    csHorizHistogram, csErrorBar, csError, csHighLow, csFunnel, csBox,
    csHorizBox, csSurface, csContour, csWaterFall, csColorGrid, csVector3D,
    csTower, csTriSurface, csPoint3D, csBubble3D, csMyPoint, csBarJoin, csBar3D);



  TfrxSeriesItem = class(TCollectionItem)
  private

    FDataBand: TfrxDataBand;
    FDataSet: TfrxDataSet;
    FDataSetName: String;
    FDataType: TfrxSeriesDataType;
    FSortOrder: TfrxSeriesSortOrder;
    FTopN: Integer;
    FTopNCaption: String;
    FSource1: String;
    FSource2: String;
    FSource3: String;
    FSource4: String;
    FSource5: String;
    FSource6: String;
    FXType: TfrxSeriesXType;
    FValues1: String;
    FValues2: String;
    FValues3: String;
    FValues4: String;
    FValues5: String;
    FValues6: String;
    procedure FillSeries(Series: TChartSeries);
    procedure SetDataSet(const Value: TfrxDataSet);
    procedure SetDataSetName(const Value: String);
    function GetDataSetName: String;

  published
    property DataType: TfrxSeriesDataType read FDataType write FDataType;
    property DataBand: TfrxDataBand read FDataBand write FDataBand;
    property DataSet: TfrxDataSet read FDataSet write SetDataSet;
    property DataSetName: String read GetDataSetName write SetDataSetName;
    property SortOrder: TfrxSeriesSortOrder read FSortOrder write FSortOrder;
    property TopN: Integer read FTopN write FTopN;
    property TopNCaption: String read FTopNCaption write FTopNCaption;
    property XType: TfrxSeriesXType read FXType write FXType;

    { source expressions }
    property Source1: String read FSource1 write FSource1;
    property Source2: String read FSource2 write FSource2;
    property Source3: String read FSource3 write FSource3;
    property Source4: String read FSource4 write FSource4;
    property Source5: String read FSource5 write FSource5;
    property Source6: String read FSource6 write FSource6;

    { ready values. For internal use only. }
    property Values1: String read FValues1 write FValues1;
    property Values2: String read FValues2 write FValues2;
    property Values3: String read FValues3 write FValues3;
    property Values4: String read FValues4 write FValues4;
    property Values5: String read FValues5 write FValues5;
    property Values6: String read FValues6 write FValues6;

    { backward compatibility }
    property XSource: String read FSource1 write FSource1;
    property YSource: String read FSource2 write FSource2;
    property XValues: String read FValues1 write FValues1;
    property YValues: String read FValues2 write FValues2;
    {}

  end;

  TfrxSeriesData = class(TCollection)
  private
    FReport: TfrxReport;
    function GetSeries(Index: Integer): TfrxSeriesItem;
  public
    constructor Create(Report: TfrxReport);
    function Add: TfrxSeriesItem;
    property Items[Index: Integer]: TfrxSeriesItem read GetSeries; default;
  end;


  TfrxChartView = class(TfrxView)

  private
    FChart: TChart;
    FSeriesData: TfrxSeriesData;
    procedure CreateChart;
    procedure FillChart;
    procedure ReadData(Stream: TStream);
    procedure ReadData1(Reader: TReader);
    procedure ReadData2(Reader: TReader);
    procedure WriteData(Stream: TStream);
    procedure WriteData1(Writer: TWriter);
    procedure WriteData2(Writer: TWriter);
  protected
    procedure DefineProperties(Filer: TFiler); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class function GetDescription: String; override;
    procedure Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended); override;
    procedure AfterPrint; override;
    procedure GetData; override;
    procedure BeforeStartReport; override;
    procedure OnNotify(Sender: TObject); override;
    procedure ClearSeries;
    procedure AddSeries(Series: TfrxChartSeries);

    property Chart: TChart read FChart;
    property SeriesData: TfrxSeriesData read FSeriesData;
  published
    property BrushStyle;
    property Color;
    property Cursor;
    property Frame;
    property TagStr;
    property URL;
  end;


implementation

uses
  frxChartHelpers, frxChartRTTI,
{$IFNDEF NO_EDITORS}
  frxChartEditor,
{$ENDIF}
  frxDsgnIntf, frxUtils, frxRes;


{ TfrxSeriesItem }

procedure TfrxSeriesItem.SetDataSet(const Value: TfrxDataSet);
begin
  FDataSet := Value;
  if FDataSet = nil then
    FDataSetName := '' else
    FDataSetName := FDataSet.UserName;
end;

procedure TfrxSeriesItem.SetDataSetName(const Value: String);
begin
  FDataSetName := Value;
  FDataSet := frxFindDataSet(FDataSet, FDataSetName,
    TfrxSeriesData(Collection).FReport);
end;

function TfrxSeriesItem.GetDataSetName: String;
begin
  if FDataSet = nil then
    Result := FDataSetName else
    Result := FDataSet.UserName;
end;

procedure TfrxSeriesItem.FillSeries(Series: TChartSeries);
var
  i: Integer;
  sl1, sl2, sl3, sl4, sl5, sl6: TStringList;
  v1, v2, v3, v4, v5, v6: String;
  Helper: TfrxSeriesHelper;

  procedure Sort;
  var
    i: Integer;
    sl: TStringList;
    s: String;
  begin
    if sl1.Count <> sl2.Count then exit;

    sl := TStringList.Create;
    sl.Sorted := True;
    sl.Duplicates := dupAccept;

    for i := 0 to sl2.Count - 1 do
    begin
      s := sl2[i];
      if not frxIsValidFloat(s) then
        s := '0';
      sl.Add(Format('%18.2f', [frxStrToFloat(s)]) + '=' + sl1[i]);
    end;

    sl1.Clear;
    sl2.Clear;
    if FSortOrder = soAscending then
      for i := 0 to sl.Count - 1 do
      begin
        sl1.Add(Trim(Copy(sl[i], Pos('=', sl[i]) + 1, 255)));
        sl2.Add(Trim(Copy(sl[i], 1, Pos('=', sl[i]) - 1)));
      end
    else
      for i := sl.Count - 1 downto 0 do
      begin
        sl1.Add(Trim(Copy(sl[i], Pos('=', sl[i]) + 1, 255)));
        sl2.Add(Trim(Copy(sl[i], 1, Pos('=', sl[i]) - 1)));
      end;

    sl.Free;
  end;

  procedure MakeTopN;
  var
    i: Integer;
    d: Double;
    sl: TStringList;
    s: String;
  begin
    if sl1.Count <> sl2.Count then exit;

    sl := TStringList.Create;
    sl.Sorted := True;
    sl.Duplicates := dupAccept;

    for i := 0 to sl2.Count - 1 do
    begin
      s := sl2[i];
      if not frxIsValidFloat(s) then
        s := '0';
      sl.Add(Format('%18.2f', [frxStrToFloat(s)]) + '=' + sl1[i]);
    end;

    sl1.Clear;
    sl2.Clear;
    for i := sl.Count - 1 downto sl.Count - FTopN do
    begin
      sl1.Add(Trim(Copy(sl[i], Pos('=', sl[i]) + 1, 255)));
      sl2.Add(Trim(Copy(sl[i], 1, Pos('=', sl[i]) - 1)));
    end;

    d := 0;
    for i := sl.Count - FTopN - 1 downto 0 do
      d := d + frxStrToFloat(Trim(Copy(sl[i], 1, Pos('=', sl[i]) - 1)));

    sl1.Add(FTopNCaption);
    sl2.Add(FloatToStr(d));

    sl.Free;
  end;

begin
  sl1 := TStringList.Create;
  sl2 := TStringList.Create;
  sl3 := TStringList.Create;
  sl4 := TStringList.Create;
  sl5 := TStringList.Create;
  sl6 := TStringList.Create;
  Series.Clear;

  v1 := FValues1;
  if (v1 <> '') and (v1[1] = ';') then
    Delete(v1, 1, 1);
  v2 := FValues2;
  if (v2 <> '') and (v2[1] = ';') then
    Delete(v2, 1, 1);
  v3 := FValues3;
  if (v3 <> '') and (v3[1] = ';') then
    Delete(v3, 1, 1);
  v4 := FValues4;
  if (v4 <> '') and (v4[1] = ';') then
    Delete(v4, 1, 1);
  v5 := FValues5;
  if (v5 <> '') and (v5[1] = ';') then
    Delete(v5, 1, 1);
  v6 := FValues6;
  if (v6 <> '') and (v6[1] = ';') then
    Delete(v6, 1, 1);

  frxSetCommaText(v1, sl1);
  frxSetCommaText(v2, sl2);
  frxSetCommaText(v3, sl3);
  frxSetCommaText(v4, sl4);
  frxSetCommaText(v5, sl5);
  frxSetCommaText(v6, sl6);

  Helper := frxFindSeriesHelper(Series);

  try
    if sl2.Count > 0 then
    begin
      if (FTopN > 0) and (FTopN < sl2.Count) then
        MakeTopN
      else if FSortOrder <> soNone then
        Sort;

      for i := 0 to sl2.Count - 1 do
      begin
        if i < sl1.Count then v1 := sl1[i] else v1 := '';
        if i < sl2.Count then v2 := sl2[i] else v2 := '';
        if i < sl3.Count then v3 := sl3[i] else v3 := '';
        if i < sl4.Count then v4 := sl4[i] else v4 := '';
        if i < sl5.Count then v5 := sl5[i] else v5 := '';
        if i < sl6.Count then v6 := sl6[i] else v6 := '';
        Helper.AddValues(Series, v1, v2, v3, v4, v5, v6, FXType);
      end;
    end;

  finally
    Helper.Free;
    sl1.Free;
    sl2.Free;
    sl3.Free;
    sl4.Free;
    sl5.Free;
    sl6.Free;
  end;
end;



{ TfrxSeriesData }

constructor TfrxSeriesData.Create(Report: TfrxReport);
begin
  inherited Create(TfrxSeriesItem);
  FReport := Report;
end;

function TfrxSeriesData.Add: TfrxSeriesItem;
begin
  Result := TfrxSeriesItem(inherited Add);
end;

function TfrxSeriesData.GetSeries(Index: Integer): TfrxSeriesItem;
begin
  Result := TfrxSeriesItem(inherited Items[Index]);
end;


{ TfrxChartView }

constructor TfrxChartView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CreateChart;
  FSeriesData := TfrxSeriesData.Create(Report);

end;

destructor TfrxChartView.Destroy;
begin

  FChart.Free;
  inherited Destroy;
  FSeriesData.Free;
end;

class function TfrxChartView.GetDescription: String;
begin
  Result := frxResources.Get('obChart');
end;

procedure TfrxChartView.Notification(AComponent: TComponent; Operation: TOperation);
var
  i: Integer;
begin
  inherited;
  if Operation = opRemove then
  begin
    for i := 0 to FSeriesData.Count - 1 do
      if AComponent is TfrxDataSet then
      begin
        if FSeriesData[i].DataSet = AComponent then
          FSeriesData[i].DataSet := nil;
      end
      else if AComponent is TfrxBand then
      begin
        if FSeriesData[i].DataBand = AComponent then
          FSeriesData[i].DataBand := nil;
      end;
  end;
end;

procedure TfrxChartView.CreateChart;
begin
  FChart := TChart.Create(Self);
  with FChart do
  begin
    Color := clWhite;
    BevelInner := bvNone;
    BevelOuter := bvNone;
    Name := 'Chart';
    Frame.Visible := False;
    View3DOptions.Rotation := 0;
    Title.Text.Text := '';
  end;
end;

procedure TfrxChartView.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineBinaryProperty('Chart', ReadData, WriteData, True);
  Filer.DefineProperty('ChartElevation', ReadData1, WriteData1, True);
  Filer.DefineProperty('SeriesData', ReadData2, WriteData2, True);
end;

procedure TfrxChartView.ReadData(Stream: TStream);
begin
  FChart.Free;
  CreateChart;
  Stream.ReadComponent(FChart);
end;

procedure TfrxChartView.WriteData(Stream: TStream);
begin
  Stream.WriteComponent(FChart);
end;

procedure TfrxChartView.ReadData1(Reader: TReader);
begin
  FChart.View3DOptions.Elevation := Reader.ReadInteger;
end;

procedure TfrxChartView.WriteData1(Writer: TWriter);
begin
  Writer.WriteInteger(FChart.View3DOptions.Elevation);
end;

procedure TfrxChartView.ReadData2(Reader: TReader);
begin
  frxReadCollection(FSeriesData, Reader, Self);
end;

procedure TfrxChartView.WriteData2(Writer: TWriter);
begin
  frxWriteCollection(FSeriesData, Writer, Self);
end;

procedure TfrxChartView.FillChart;
var
  i: Integer;
begin
  for i := 0 to FSeriesData.Count - 1 do
    FSeriesData[i].FillSeries(FChart.Series[i]);
end;

procedure TfrxChartView.Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX,
  OffsetY: Extended);
var
  EMF: TMetafile;
begin
  BeginDraw(Canvas, ScaleX, ScaleY, OffsetX, OffsetY);
  DrawBackground;

  FillChart;

  if Color = clTransparent then
    FChart.Color := clWhite else
    FChart.Color := Color;
  FChart.BufferedDisplay := True;
  EMF := FChart.TeeCreateMetafile(False, Rect(0, 0, Round(Width), Round(Height)));
  Canvas.StretchDraw(Rect(FX, FY, FX1, FY1), EMF);
  EMF.Free;

  DrawFrame;
end;

procedure TfrxChartView.AfterPrint;
var
  i: Integer;
begin
  for i := 0 to FSeriesData.Count - 1 do
    with FSeriesData[i] do
    begin
      Values1 := '';
      Values2 := '';
      Values3 := '';
      Values4 := '';
      Values5 := '';
      Values6 := '';
    end;
end;

procedure TfrxChartView.GetData;
var
  i: Integer;
begin
  inherited;
  for i := 0 to FSeriesData.Count - 1 do
    with FSeriesData[i] do
      if (DataType = dtDBData) and (DataSet <> nil) then
      begin
        Values1 := '';
        Values2 := '';
        Values3 := '';
        Values4 := '';
        Values5 := '';
        Values6 := '';

        DataSet.First;
        while not DataSet.Eof do
        begin
          if Source1 <> '' then
            Values1 := Values1 + ';' + VarToStr(Report.Calc(Source1));
          if Source2 <> '' then
            Values2 := Values2 + ';' + VarToStr(Report.Calc(Source2));
          if Source3 <> '' then
            Values3 := Values3 + ';' + VarToStr(Report.Calc(Source3));
          if Source4 <> '' then
            Values4 := Values4 + ';' + VarToStr(Report.Calc(Source4));
          if Source5 <> '' then
            Values5 := Values5 + ';' + VarToStr(Report.Calc(Source5));
          if Source6 <> '' then
            Values6 := Values6 + ';' + VarToStr(Report.Calc(Source6));
          DataSet.Next;
        end;
      end
      else if DataType = dtFixedData then
      begin
        Values1 := Source1;
        Values2 := Source2;
        Values3 := Source3;
        Values4 := Source4;
        Values5 := Source5;
        Values6 := Source5;
      end
end;

procedure TfrxChartView.BeforeStartReport;
var
  i: Integer;
begin
  for i := 0 to FSeriesData.Count - 1 do
    with FSeriesData[i] do
    begin
      Values1 := '';
      Values2 := '';
      Values3 := '';
      Values4 := '';
      Values5 := '';
      Values6 := '';
    end;
  Report.Engine.NotifyList.Add(Self);
end;

procedure TfrxChartView.OnNotify(Sender: TObject);
var
  i: Integer;
begin
  inherited;
  for i := 0 to FSeriesData.Count - 1 do
    with FSeriesData[i] do
      if (DataType = dtBandData) and (DataBand = Sender) then
      begin
        Report.CurObject := Self.Name;
        if Source1 <> '' then
          Values1 := Values1 + ';' + VarToStr(Report.Calc(Source1));
        if Source2 <> '' then
          Values2 := Values2 + ';' + VarToStr(Report.Calc(Source2));
        if Source3 <> '' then
          Values3 := Values3 + ';' + VarToStr(Report.Calc(Source3));
        if Source4 <> '' then
          Values4 := Values4 + ';' + VarToStr(Report.Calc(Source4));
        if Source5 <> '' then
          Values5 := Values5 + ';' + VarToStr(Report.Calc(Source5));
        if Source6 <> '' then
          Values6 := Values6 + ';' + VarToStr(Report.Calc(Source6));
      end;
end;

procedure TfrxChartView.AddSeries(Series: TfrxChartSeries);
var
  sc: TSeriesClass;
  s: TChartSeries;
  b: Boolean;

begin
  sc := frxChartSeries[Integer(Series)];
  s := TChartSeries(sc.NewInstance);
  s.Create(Chart);
  Chart.AddSeries(s);

  SeriesData.Add;


  with Chart do
  begin
    b := not (s is TPieSeries);
    View3DOptions.Orthogonal := b;
    AxisVisible := b;
    View3DWalls := b;
  end;
end;

procedure TfrxChartView.ClearSeries;
begin
  FChart.Free;
  CreateChart;
  SeriesData.Clear;
end;






initialization
{$IFNDEF TeeChartStd}
{$IFNDEF TeeChart4}
  RegisterTeeStandardSeries;
{$ENDIF}
{$ENDIF}
  frxObjects.RegisterObject1(TfrxChartView, nil, '', '', 0, 25);

finalization
  frxObjects.UnRegister(TfrxChartView);

end.


//0f31356a91fea3356e5f76cdce90aa7b