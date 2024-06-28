
{******************************************}
{                                          }
{             FastReport v4.0              }
{           Chart design editor            }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxChartEditor;

interface

{$I frx.inc}
{$I tee.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, ExtCtrls, Buttons, frxClass, frxChart, frxCustomEditors,
  frxCtrls, frxInsp, frxDock, TeeProcs, TeEngine, Chart, Series, ComCtrls,
  ImgList, TeeGally
{$IFDEF Delphi6}
, Variants
{$ENDIF};


type
  TfrxChartEditor = class(TfrxViewEditor)
  public
    function Edit: Boolean; override;
    function HasEditor: Boolean; override;
    procedure GetMenuItems; override;
    function Execute(Tag: Integer; Checked: Boolean): Boolean; override;
  end;

  TfrxChartEditorForm = class(TForm)
    OkB: TButton;
    Panel1: TPanel;
    ChartTree: TTreeView;
    Panel2: TPanel;
    ChartImages: TImageList;
    TreePanel: TPanel;
    AddB: TSpeedButton;
    DeleteB: TSpeedButton;
    CancelB: TButton;
    SourcePanel: TPanel;
    DataSourceGB: TGroupBox;
    DBSourceRB: TRadioButton;
    BandSourceRB: TRadioButton;
    FixedDataRB: TRadioButton;
    DatasetsCB: TComboBox;
    DatabandsCB: TComboBox;
    ValuesGB: TGroupBox;
    Values1CB: TComboBox;
    Values1L: TLabel;
    Values2L: TLabel;
    Values2CB: TComboBox;
    Values3L: TLabel;
    Values3CB: TComboBox;
    Values4L: TLabel;
    Values4CB: TComboBox;
    OptionsGB: TGroupBox;
    ShowTopLbl: TLabel;
    CaptionLbl: TLabel;
    SortLbl: TLabel;
    XLbl: TLabel;
    TopNE: TEdit;
    TopNCaptionE: TEdit;
    SortCB: TComboBox;
    UpDown1: TUpDown;
    XTypeCB: TComboBox;
    InspSite: TPanel;
    Values5L: TLabel;
    Values5CB: TComboBox;
    HintL: TLabel;
    Values6L: TLabel;
    Values6CB: TComboBox;
    EditB: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure ChartTreeClick(Sender: TObject);
    procedure AddBClick(Sender: TObject);
    procedure DeleteBClick(Sender: TObject);
    procedure DoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure UpDown1Click(Sender: TObject; Button: TUDBtnType);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DatasetsCBClick(Sender: TObject);
    procedure DatabandsCBClick(Sender: TObject);
    procedure DBSourceRBClick(Sender: TObject);
    procedure OkBClick(Sender: TObject);
    procedure EditBClick(Sender: TObject);
  private
    { Private declarations }
    FChart: TfrxChartView;
    FCurSeries: TfrxSeriesItem;
    FInspector: TfrxObjectInspector;
    FModified: Boolean;
    FReport: TfrxReport;
    FUpdating: Boolean;
    FValuesGBHeight: Integer;
    procedure FillDropDownLists(ds: TfrxDataset);
    procedure SetCurSeries(const Value: TfrxSeriesItem);
    procedure SetModified(const Value: Boolean);
    procedure ShowSeriesData;
    procedure UpdateSeriesData;
    property Modified: Boolean read FModified write SetModified;
    property CurSeries: TfrxSeriesItem read FCurSeries write SetCurSeries;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Chart: TfrxChartView read FChart write FChart;
  end;


implementation

uses frxDsgnIntf, frxUtils, frxRes, frxChartHelpers
{$IFDEF TeeChartPro}, TeeEdit{$IFNDEF TeeChart4}, TeeEditCha{$ENDIF} {$ENDIF};

{$R *.DFM}

type
  THackWinControl = class(TWinControl);


{ TfrxChartEditor }

function TfrxChartEditor.HasEditor: Boolean;
begin
  Result := True;
end;

function TfrxChartEditor.Edit: Boolean;
begin
  with TfrxChartEditorForm.Create(Designer) do
  begin
    Chart.Assign(TfrxChartView(Component));
    Result := ShowModal = mrOk;
    if Result then
      TfrxChartView(Component).Assign(Chart);
    Free;
  end;
end;

function TfrxChartEditor.Execute(Tag: Integer; Checked: Boolean): Boolean;
var
  i: Integer;
  c: TfrxComponent;
  v: TfrxChartView;
begin
  Result := inherited Execute(Tag, Checked);
  for i := 0 to Designer.SelectedObjects.Count - 1 do
  begin
    c := Designer.SelectedObjects[i];
    if (c is TfrxChartView) and not (rfDontModify in c.Restrictions) then
    begin
      v := TfrxChartView(c);
      if Tag = 1 then
        v.Chart.View3D := Checked
      else if Tag = 2 then
        v.Chart.AxisVisible := Checked;
      Result := True;
    end;
  end;
end;

procedure TfrxChartEditor.GetMenuItems;
var
  v: TfrxChartView;
begin
  v := TfrxChartView(Component);
  AddItem(frxResources.Get('ch3D'), 1, v.Chart.View3D);
  AddItem(frxResources.Get('chAxis'), 2, v.Chart.AxisVisible);
  inherited;
end;


{ TfrxChartEditorForm }

constructor TfrxChartEditorForm.Create(AOwner: TComponent);
var
  bmp: TBitmap;
begin
  inherited;
  FReport := TfrxCustomDesigner(AOwner).Report;
  FChart := TfrxChartView.Create(FReport);
  FInspector := TfrxObjectInspector.Create(Owner);
  with FInspector do
  begin
    SplitterPos := InspSite.Width div 2;
    Box.Parent := InspSite;
    Box.Align := alClient;
  end;
  OnMouseWheelDown := FInspector.FormMouseWheelDown;
  OnMouseWheelUp := FInspector.FormMouseWheelUp;
  THackWinControl(ChartTree).BevelKind := bkFlat;

  { add chart image }
  bmp := TBitmap.Create;
  bmp.Width := 24;
  bmp.Height := 24;
  frxResources.ObjectImages.Draw(bmp.Canvas, 0, 0, 25);
  frxAssignImages(bmp, 24, 24, ChartImages);
  bmp.Free;
  FValuesGBHeight := ValuesGB.Height;
{$IFDEF TeeChartPro}
  EditB.Visible := True;
{$ENDIF}
end;

destructor TfrxChartEditorForm.Destroy;
begin
  FChart.Free;
  inherited;
end;

procedure TfrxChartEditorForm.FormShow(Sender: TObject);

  procedure FillChartTree;
  var
    i: Integer;
    n: TTreeNode;
  begin
    for i := 0 to FChart.Chart.SeriesCount - 1 do
    begin
      n := ChartTree.Items.AddChild(ChartTree.Items[0], GetGallerySeriesName(FChart.Chart.Series[i]));

      n.ImageIndex := 0;
      n.SelectedIndex := 0;
      n.StateIndex := 0;
    end;

    ChartTree.FullExpand;
    ChartTree.Selected := ChartTree.Items[0];
  end;

  procedure FillBandsList;
  var
    i: Integer;
    c: TfrxComponent;
  begin
    for i := 0 to FReport.Designer.Objects.Count - 1 do
    begin
      c := FReport.Designer.Objects[i];
      if c is TfrxDataBand then
        DatabandsCB.Items.Add(c.Name);
    end;
  end;

begin
  FReport.GetDatasetList(DatasetsCB.Items);
  FillBandsList;
  FillChartTree;
  CurSeries := nil;
end;

procedure TfrxChartEditorForm.ShowSeriesData;
var
  Helper: TfrxSeriesHelper;
  sl: TStrings;
  NewHeight: Integer;
begin
  FUpdating := True;

  if FCurSeries <> nil then
    with FCurSeries do
    begin
      if DataType = dtDBData then
        DBSourceRB.Checked := True
      else if DataType = dtBandData then
        BandSourceRB.Checked := True
      else if DataType = dtFixedData then
        FixedDataRB.Checked := True;

      Values1CB.Text := FCurSeries.Source1;
      Values2CB.Text := FCurSeries.Source2;
      Values3CB.Text := FCurSeries.Source3;
      Values4CB.Text := FCurSeries.Source4;
      Values5CB.Text := FCurSeries.Source5;
      Values6CB.Text := FCurSeries.Source6;

      Helper := frxFindSeriesHelper(FChart.Chart.Series[FCurSeries.Index]);
      sl := TStringList.Create;
      frxSetCommaText(Helper.GetParamNames, sl);

      NewHeight := FValuesGBHeight;
      Values2CB.Visible := sl.Count >= 2;
      Values2L.Visible := sl.Count >= 2;
      if not Values2CB.Visible then
        Dec(NewHeight, Values2CB.Height + 4);
      Values3CB.Visible := sl.Count >= 3;
      Values3L.Visible := sl.Count >= 3;
      if not Values3CB.Visible then
        Dec(NewHeight, Values3CB.Height + 4);
      Values4CB.Visible := sl.Count >= 4;
      Values4L.Visible := sl.Count >= 4;
      if not Values4CB.Visible then
        Dec(NewHeight, Values4CB.Height + 4);
      Values5CB.Visible := sl.Count >= 5;
      Values5L.Visible := sl.Count >= 5;
      if not Values5CB.Visible then
        Dec(NewHeight, Values5CB.Height + 4);
      Values6CB.Visible := sl.Count >= 6;
      Values6L.Visible := sl.Count >= 6;
      if not Values6CB.Visible then
        Dec(NewHeight, Values6CB.Height + 4);

      ValuesGB.Height := NewHeight;
      OptionsGB.Top := ValuesGB.Top + ValuesGB.Height + 8;

      if sl.Count > 0 then
        Values1L.Caption := sl[0];
      if sl.Count > 1 then
        Values2L.Caption := sl[1];
      if sl.Count > 2 then
        Values3L.Caption := sl[2];
      if sl.Count > 3 then
        Values4L.Caption := sl[3];
      if sl.Count > 4 then
        Values5L.Caption := sl[4];
      if sl.Count > 5 then
        Values6L.Caption := sl[5];

      sl.Free;
      Helper.Free;


      if DataSet = nil then
        DatasetsCB.ItemIndex := -1
      else
      begin
        DatasetsCB.ItemIndex := DatasetsCB.Items.IndexOf(FReport.GetAlias(DataSet));
        DatasetsCBClick(nil);
      end;

      if DataBand = nil then
        DatabandsCB.ItemIndex := -1
      else
      begin
        DatabandsCB.ItemIndex := DatabandsCB.Items.IndexOf(DataBand.Name);
        DatabandsCBClick(nil);
      end;

      TopNE.Text := IntToStr(TopN);
      TopNCaptionE.Text := TopNCaption;
      SortCB.ItemIndex := Integer(SortOrder);
      XTypeCB.ItemIndex := Integer(XType);
    end;

  FUpdating := False;
end;

procedure TfrxChartEditorForm.UpdateSeriesData;
begin
  if FCurSeries <> nil then
    with FCurSeries do
    begin
      if DBSourceRB.Checked then
        DataType := dtDBData
      else if BandSourceRB.Checked then
        DataType := dtBandData
      else if FixedDataRB.Checked then
        DataType := dtFixedData;

      if DatabandsCB.ItemIndex <> -1 then
        DataBand := TfrxDataBand(FReport.FindObject(DatabandsCB.Items[DatabandsCB.ItemIndex]))
      else
        DataBand := nil;
      if DatasetsCB.ItemIndex <> -1 then
        DataSet := FReport.GetDataSet(DatasetsCB.Items[DatasetsCB.ItemIndex])
      else
        DataSet := nil;

      Source1 := Values1CB.Text;
      Source2 := Values2CB.Text;
      Source3 := Values3CB.Text;
      Source4 := Values4CB.Text;
      Source5 := Values5CB.Text;
      Source6 := Values6CB.Text;

      SortOrder := TfrxSeriesSortOrder(SortCB.ItemIndex);
      TopN := StrToInt(TopNE.Text);
      TopNCaption := TopNCaptionE.Text;
      XType := TfrxSeriesXType(XTypeCB.ItemIndex);
    end;

  Modified := False;
end;

procedure TfrxChartEditorForm.SetCurSeries(const Value: TfrxSeriesItem);
var
  InspectObj: TPersistent;
begin
  if Modified then
    UpdateSeriesData;
  FCurSeries := Value;

  if FCurSeries = nil then
    InspectObj := FChart.Chart
  else
    InspectObj := FChart.Chart.Series[FCurSeries.Index];
  FInspector.Inspect([InspectObj]);
  SourcePanel.Visible := FCurSeries <> nil;
  HintL.Visible := not SourcePanel.Visible;
  DeleteB.Enabled := FCurSeries <> nil;
  ShowSeriesData;
end;

procedure TfrxChartEditorForm.SetModified(const Value: Boolean);
begin
  if not FUpdating then
    FModified := Value;
end;

procedure TfrxChartEditorForm.FillDropDownLists(ds: TfrxDataset);
var
  l: TStringList;
  i: Integer;
begin
  if ds = nil then
  begin
    Values1CB.Items.Clear;
    Values2CB.Items.Clear;
    Values3CB.Items.Clear;
    Values4CB.Items.Clear;
    Values5CB.Items.Clear;
    Values6CB.Items.Clear;
  end
  else
  begin
    l := TStringList.Create;
    try
      ds.GetFieldList(l);
      for i := 0 to l.Count - 1 do
        l[i] := FReport.GetAlias(ds) + '."' + l[i] + '"';

      Values1CB.Items := l;
      Values2CB.Items := l;
      Values3CB.Items := l;
      Values4CB.Items := l;
      Values5CB.Items := l;
      Values6CB.Items := l;
    finally
      l.Free;
    end;
  end;
end;

procedure TfrxChartEditorForm.ChartTreeClick(Sender: TObject);
var
  i: Integer;
begin
  i := ChartTree.Selected.AbsoluteIndex - 1;
  if i >= 0 then
    CurSeries := FChart.SeriesData[i] else
    CurSeries := nil;
end;

{$HINTS OFF}
procedure TfrxChartEditorForm.AddBClick(Sender: TObject);
var
  s: TChartSeries;
  n: TTreeNode;
  b: Boolean;
  ind: Integer;
begin
  ind := 0;
  s := CreateNewSeriesGallery(nil, nil, FChart.Chart, False, False{$IFNDEF TeeChart4}{$IFDEF TeeChartPro}, ind{$ENDIF}{$ENDIF});
  if s = nil then
    Exit;
  FChart.SeriesData.Add;

  with FChart.Chart do
  begin
    b := not (s is TPieSeries);
    View3DOptions.Orthogonal := b;
    AxisVisible := b;
    View3DWalls := b;
  end;

  n := ChartTree.Items.AddChild(ChartTree.Items[0], GetGallerySeriesName(s));

  n.ImageIndex := 0;
  n.SelectedIndex := 0;
  n.StateIndex := 0;

  ChartTree.Selected := n;
  ChartTreeClick(nil);
end;
{$HINTS ON}

procedure TfrxChartEditorForm.DeleteBClick(Sender: TObject);
var
  s: TChartSeries;
begin
  s := FChart.Chart.Series[FCurSeries.Index];
  s.Free;
  FCurSeries.Free;
  ChartTree.Selected.Free;

  ChartTree.SetFocus;
  ChartTree.Selected := ChartTree.Items[0];
  ChartTreeClick(nil);
end;

procedure TfrxChartEditorForm.EditBClick(Sender: TObject);
begin
{$IFDEF TeeChartPro}
  with TChartEditor.Create(nil) do
  begin
    Chart := FChart.Chart;
{$IFDEF TeeChart7}
    if FCurSeries <> nil then
      Series := FChart.Chart.Series[FCurSeries.Index];
{$ENDIF}
{$IFNDEF TeeChart4}
    HideTabs := [cetGeneral, cetTitles, cetPaging, cetSeriesData, cetMain,
      cetExport, {$IFDEF TeeChart7}cetExportNative,{$ENDIF} cetTools, cetPrintPreview];
    Options := Options - [ceDataSource, ceHelp, ceClone, ceTitle, ceAdd];
{$ENDIF}
    Execute;
    Free;
  end;
{$ENDIF}
end;

procedure TfrxChartEditorForm.DoClick(Sender: TObject);
begin
  if not FUpdating then
    Modified := True;
end;

procedure TfrxChartEditorForm.UpDown1Click(Sender: TObject; Button: TUDBtnType);
begin
  DoClick(Sender);
end;

procedure TfrxChartEditorForm.DatasetsCBClick(Sender: TObject);
var
  ds: TfrxDataSet;
begin
  ds := FReport.GetDataSet(DatasetsCB.Items[DatasetsCB.ItemIndex]);
  FillDropDownLists(ds);
  DoClick(nil);
end;

procedure TfrxChartEditorForm.DatabandsCBClick(Sender: TObject);
var
  db: TfrxDataBand;
  ds: TfrxDataSet;
begin
  db := TfrxDataBand(FReport.FindObject(DatabandsCB.Items[DatabandsCB.ItemIndex]));
  if db <> nil then
    ds := db.DataSet
  else
    ds := nil;
  FillDropDownLists(ds);
  DoClick(nil);
end;

procedure TfrxChartEditorForm.DBSourceRBClick(Sender: TObject);
begin
  DatasetsCB.ItemIndex := -1;
  DatabandsCB.ItemIndex := -1;
  FillDropDownLists(nil);
  DoClick(nil);
end;

procedure TfrxChartEditorForm.OkBClick(Sender: TObject);
begin
  CurSeries := nil;
end;

procedure TfrxChartEditorForm.FormCreate(Sender: TObject);
begin
  Caption := frxGet(4100);
  OkB.Caption := frxGet(1);
  CancelB.Caption := frxGet(2);
  AddB.Hint := frxGet(4101);
  DeleteB.Hint := frxGet(4102);
  EditB.Hint := frxGet(4103);

  DatasourceGB.Caption := frxGet(4107);
  DBSourceRB.Caption := frxGet(4106);
  BandSourceRB.Caption := frxGet(4104);
  FixedDataRB.Caption := frxGet(4105);

  ValuesGB.Caption := frxGet(4108);
  HintL.Caption := frxGet(4109);

  OptionsGB.Caption := frxGet(4114);
  ShowTopLbl.Caption := frxGet(4115);
  CaptionLbl.Caption := frxGet(4116);
  SortLbl.Caption := frxGet(4117);
  XLbl.Caption := frxGet(4126);

  XTypeCB.Items.Clear;
  XTypeCB.Items.Add(frxResources.Get('chxtText'));
  XTypeCB.Items.Add(frxResources.Get('chxtNumber'));
  XTypeCB.Items.Add(frxResources.Get('chxtDate'));
  SortCB.Items.Clear;
  SortCB.Items.Add(frxResources.Get('chsoNone'));
  SortCB.Items.Add(frxResources.Get('chsoAscending'));
  SortCB.Items.Add(frxResources.Get('chsoDescending'));
end;

procedure TfrxChartEditorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;


initialization
  frxComponentEditors.Register(TfrxChartView, TfrxChartEditor);
  frxHideProperties(TChart, 'Align;AllowPanning;AllowZoom;Anchors;AnimatedZoom;' +
    'AnimatedZoomSteps;AutoSize;BackImage;BackImageInside;BackImageMode;' +
    'BevelInner;BevelOuter;BevelWidth;BorderStyle;BorderWidth;ClipPoints;Color;' +
    'Constraints;Cursor;DragCursor;DragKind;DragMode;DockSite;Enabled;Foot;Frame;Height;' +
    'HelpContext;HelpType;HelpKeyword;Hint;Left;Locked;MarginBottom;MarginLeft;MarginRight;MarginTop;' +
    'MaxPointsPerPage;Name;Page;ParentColor;ParentShowHint;PopupMenu;PrintProportional;' +
    'ScaleLastPage;ScrollMouseButton;SeriesList;ShowHint;TabOrder;TabStop;Tag;Top;UseDockManager;' +
    'Visible;Width');
  frxHideProperties(TChartSeries, 'ColorSource;Cursor;DataSource;Name;' +
    'ParentChart;Tag;XLabelsSource');
  frxHideProperties(TfrxChartView, 'SeriesData;BrushStyle');


end.


//0f31356a91fea3356e5f76cdce90aa7b