
{******************************************}
{                                          }
{             FastReport v4.0              }
{               Chart RTTI                 }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxChartRTTI;

interface

{$I frx.inc}

implementation

uses
  Windows, Classes, SysUtils, Forms, fs_iinterpreter, frxChart, fs_ichartrtti
{$IFDEF Delphi6}
, Variants
{$ENDIF};
  

type
  TFunctions = class(TfsRTTIModule)
  private
    function CallMethod(Instance: TObject; ClassType: TClass;
      const MethodName: String; Caller: TfsMethodHelper): Variant;
    function GetProp(Instance: TObject; ClassType: TClass;
      const PropName: String): Variant;
  public
    constructor Create(AScript: TfsScript); override;
  end;


{ TFunctions }

constructor TFunctions.Create(AScript: TfsScript);
begin
  inherited Create(AScript);
  with AScript do
  begin
    AddEnum('TfrxSeriesDataType', 'dtDBData, dtBandData, dtFixedData');
    AddClass(TfrxSeriesItem, 'TPersistent');
    with AddClass(TfrxSeriesData, 'TPersistent') do
    begin
      AddMethod('function Add: TfrxSeriesItem', CallMethod);
      AddDefaultProperty('Items', 'Integer', 'TfrxSeriesItem', CallMethod, True);
    end;
    with AddClass(TfrxChartView, 'TfrxView') do
    begin
      AddProperty('Chart', 'TChart', GetProp, nil);
      AddIndexProperty('Series', 'Integer', 'TChartSeries', CallMethod, True);
      AddProperty('SeriesData', 'TfrxSeriesData', GetProp, nil);
    end;
  end;
end;

function TFunctions.CallMethod(Instance: TObject; ClassType: TClass;
  const MethodName: String; Caller: TfsMethodHelper): Variant;
begin
  Result := 0;

  if ClassType = TfrxSeriesData then
  begin
    if MethodName = 'ADD' then
      Result := Integer(TfrxSeriesData(Instance).Add)
    else if MethodName = 'ITEMS.GET' then
      Result := Integer(TfrxSeriesData(Instance).Items[Caller.Params[0]])
  end
  else if ClassType = TfrxChartView then
  begin
    if MethodName = 'SERIES.GET' then
      Result := Integer(TfrxChartView(Instance).Chart.Series[Caller.Params[0]])
  end
end;

function TFunctions.GetProp(Instance: TObject; ClassType: TClass;
  const PropName: String): Variant;
begin
  Result := 0;

  if ClassType = TfrxChartView then
  begin
    if PropName = 'CHART' then
      Result := Integer(TfrxChartView(Instance).Chart)
    else if PropName = 'SERIESDATA' then
      Result := Integer(TfrxChartView(Instance).SeriesData)
  end
end;


initialization
  fsRTTIModules.Add(TFunctions);

finalization
  fsRTTIModules.Remove(TFunctions);

end.


//0f31356a91fea3356e5f76cdce90aa7b