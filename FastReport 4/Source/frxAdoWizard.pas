
{******************************************}
{                                          }
{             FastReport v4.0              }
{     Standard Report wizard for ADO       }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxAdoWizard;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ComCtrls, ExtCtrls, frxClass, frxDesgn;

type
  TfrxStdWizard = class(TfrxCustomWizard)
  public
    class function GetDescription: String; override;
    function Execute: Boolean; override;
  end;

  TfrxDotMatrixWizard = class(TfrxCustomWizard)
  public
    class function GetDescription: String; override;
    function Execute: Boolean; override;
  end;

  TfrxStdEmptyWizard = class(TfrxCustomWizard)
  public
    class function GetDescription: String; override;
    function Execute: Boolean; override;
  end;

  TfrxDMPEmptyWizard = class(TfrxCustomWizard)
  public
    class function GetDescription: String; override;
    function Execute: Boolean; override;
  end;

  TfrxStdWizardForm = class(TForm)
    Pages: TPageControl;
    FieldsTab: TTabSheet;
    GroupsTab: TTabSheet;
    LayoutTab: TTabSheet;
    FieldsLB: TListBox;
    AddFieldB: TSpeedButton;
    AddAllFieldsB: TSpeedButton;
    RemoveFieldB: TSpeedButton;
    RemoveAllFieldsB: TSpeedButton;
    SelectedFieldsLB: TListBox;
    SelectedFieldsL: TLabel;
    FieldUpB: TSpeedButton;
    FieldDownB: TSpeedButton;
    AvailableFieldsLB: TListBox;
    AddGroupB: TSpeedButton;
    RemoveGroupB: TSpeedButton;
    GroupsLB: TListBox;
    GroupsL: TLabel;
    GroupUpB: TSpeedButton;
    GroupDownB: TSpeedButton;
    AvailableFieldsL: TLabel;
    BackB: TButton;
    NextB: TButton;
    FinishB: TButton;
    FitWidthCB: TCheckBox;
    Step2L: TLabel;
    Step3L: TLabel;
    Step4L: TLabel;
    StyleTab: TTabSheet;
    Step5L: TLabel;
    ScrollBox1: TScrollBox;
    StylePB: TPaintBox;
    StyleLB: TListBox;
    OrientationL: TGroupBox;
    LayoutL: TGroupBox;
    PortraitImg: TImage;
    LandscapeImg: TImage;
    PortraitRB: TRadioButton;
    LandscapeRB: TRadioButton;
    TabularRB: TRadioButton;
    ColumnarRB: TRadioButton;
    ScrollBox2: TScrollBox;
    LayoutPB: TPaintBox;
    AvailableFieldsL1: TLabel;
    DataTab: TTabSheet;
    Step1L: TLabel;
    ConnectionCB: TComboBox;
    TableL: TLabel;
    TablesLB: TListBox;
    orL: TLabel;
    CreateQueryB: TButton;
    ConnectionL: TLabel;
    ConfigureConnB: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure AddFieldBClick(Sender: TObject);
    procedure AddAllFieldsBClick(Sender: TObject);
    procedure RemoveFieldBClick(Sender: TObject);
    procedure RemoveAllFieldsBClick(Sender: TObject);
    procedure AddGroupBClick(Sender: TObject);
    procedure RemoveGroupBClick(Sender: TObject);
    procedure FieldUpBClick(Sender: TObject);
    procedure FieldDownBClick(Sender: TObject);
    procedure GroupUpBClick(Sender: TObject);
    procedure GroupDownBClick(Sender: TObject);
    procedure NextBClick(Sender: TObject);
    procedure BackBClick(Sender: TObject);
    procedure GroupsTabShow(Sender: TObject);
    procedure StylePBPaint(Sender: TObject);
    procedure PortraitRBClick(Sender: TObject);
    procedure PagesChange(Sender: TObject);
    procedure StyleLBClick(Sender: TObject);
    procedure FinishBClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure LayoutPBPaint(Sender: TObject);
    procedure TabularRBClick(Sender: TObject);
    procedure ConnectionCBClick(Sender: TObject);
    procedure ConfigureConnBClick(Sender: TObject);
    procedure TablesLBClick(Sender: TObject);
    procedure CreateQueryBClick(Sender: TObject);
  private
    FDataset: TfrxDataset;
    FDesigner: TfrxDesignerForm;
    FDotMatrix: Boolean;
    FLayoutReport: TfrxReport;
    FReport: TfrxReport;
    FStyleReport: TfrxReport;
    FStyleSheet: TfrxStyleSheet;
    procedure DrawSample(PaintBox: TPaintBox; Report: TfrxReport);
    procedure FillConnections;
    procedure FillFields;
    procedure FillTables;
    procedure UpdateAvailableFields;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;


implementation

{$R *.DFM}
{$R *.RES}

uses
  frxEditReportData, frxDsgnIntf, frxRes, frxUtils, frxDMPClass,
  IniFiles, Registry, Printers, frxADOComponents, frxConnEditor;

const
  StyleReport =
'<?xml version="1.0" encoding="utf-8"?>' +
'<TfrxReport>' +
'<TfrxReportPage>' +
'<TfrxMemoView Width="439,65337" Height="26" HAlign="haCenter" Text="Customers" Style="Title" VAlign="vaCenter"/>' +
'<TfrxMemoView Top="36" Width="253" Height="20" Style="Header line"/>' +
'<TfrxMemoView Top="36" Width="126,96846" Height="20" Text="Company" Style="Header"/>' +
'<TfrxMemoView Left="137,74799" Top="36" Width="126,2047" Height="20" Text="Address" Style="Header"/>' +
'<TfrxMemoView Top="60,47248" Width="264,5671" Height="26,45671" Text="Action Club" Style="Group header" VAlign="vaCenter"/>' +
'<TfrxMemoView Top="92" Width="126,96846" Height="20" Text="Action Club" Style="Data"/>' +
'<TfrxMemoView Left="137,74799" Top="92" Width="126,2047" Height="20" Text="PO Box 5451-F" Style="Data"/>' +
'<TfrxMemoView Top="112" Width="126,96846" Height="20" Text="Action Diver Supply" Style="Data"/>' +
'<TfrxMemoView Left="137,74799" Top="112" Width="126,2047" Height="20" Text="Blue Spar Box #3" Style="Data"/>' +
'<TfrxMemoView Top="132" Width="126,96846" Height="20" Text="Adventure Undersea" Style="Data"/>' +
'<TfrxMemoView Left="137,74799" Top="132" Width="126,2047" Height="20" Text="PO Box 744" Style="Data"/>' +
'<TfrxMemoView Top="157,98423" Width="264,47248" Height="18" Text="Count: 3" Style="Group footer"/>' +
'</TfrxReportPage>' +
'</TfrxReport>';

  LayoutTabularReport =
'<?xml version="1.0" encoding="utf-8"?>' +
'<TfrxReport>' +
'<TfrxReportPage>' +
'<TfrxMemoView Left="0" Top="0" Width="338,1107" Height="22,67718" HAlign="haCenter" Style="Title" VAlign="vaCenter" Text="Report"/>' +
'<TfrxMemoView Left="0" Top="26,45671" Width="151,1812" Height="22,67718" Style="Header" Text="Company"/>' +
'<TfrxMemoView Left="151,1812" Top="26,45671" Width="139,84261" Height="22,67718" Style="Header" Text="Address"/>' +
'<TfrxMemoView Left="0" Top="49,13389" Width="151,1812" Height="18,89765" Style="Data" Text="Action Club"/>' +
'<TfrxMemoView Left="151,1812" Top="49,13389" Width="139,84261" Height="18,89765" Style="Data" Text="PO Box 5451-F"/>' +
'<TfrxMemoView Left="0" Top="68,03154" Width="151,1812" Height="18,89765" Style="Data" Text="Action Diver Supply"/>' +
'<TfrxMemoView Left="151,1812" Top="68,03154" Width="139,84261" Height="18,89765" Style="Data" Text="Blue Spar Box #3"/>' +
'<TfrxMemoView Left="0" Top="86,92919" Width="151,1812" Height="18,89765" Style="Data" Text="Adventure Undersea"/>' +
'<TfrxMemoView Left="151,1812" Top="86,92919" Width="139,84261" Height="18,89765" Style="Data" Text="PO Box 744"/>' +
'<TfrxMemoView Left="0" Top="105,82684" Width="151,1812" Height="18,89765" Style="Data" Text="American SCUBA Supply"/>' +
'<TfrxMemoView Left="151,1812" Top="105,82684" Width="139,84261" Height="18,89765" Style="Data" Text="1739 Atlantic Avenue"/>' +
'<TfrxMemoView Left="0" Top="124,72449" Width="151,1812" Height="18,89765" Style="Data" Text="Aquatic Drama"/>' +
'<TfrxMemoView Left="151,1812" Top="124,72449" Width="139,84261" Height="18,89765" Style="Data" Text="921 Everglades Way"/>' +
'<TfrxMemoView Left="0" Top="143,62214" Width="151,1812" Height="18,89765" Style="Data" Text="Blue Glass Happiness"/>' +
'<TfrxMemoView Left="151,1812" Top="143,62214" Width="139,84261" Height="18,89765" Style="Data" Text="6345 W. Shore Lane"/>' +
'</TfrxReportPage>' +
'</TfrxReport>';

  LayoutColumnarReport =
'<?xml version="1.0" encoding="utf-8"?>' +
'<TfrxReport>' +
'<TfrxReportPage>' +
'<TfrxMemoView Left="0" Top="0" Width="338,1107" Height="22,67718" HAlign="haCenter" Style="Title" VAlign="vaCenter" Text="Report"/>' +
'<TfrxMemoView Left="0" Top="26,45671" Width="64" Height="18,89765" Style="Header" Text="Company"/>' +
'<TfrxMemoView Left="82,89765" Top="26,45671" Width="225" Height="18,89765" Style="Data" Text="Action Club"/>' +
'<TfrxMemoView Left="0" Top="45,35436" Width="64" Height="18,89765" Style="Header" Text="Address"/>' +
'<TfrxMemoView Left="82,89765" Top="45,35436" Width="225" Height="18,89765" Style="Data" Text="PO Box 5451-F"/>' +
'<TfrxMemoView Left="0" Top="64,25201" Width="64" Height="18,89765" Style="Header" Text="Phone"/>' +
'<TfrxMemoView Left="82,89765" Top="64,25201" Width="114" Height="18,89765" Style="Data" Text="813-870-0239"/>' +
'<TfrxMemoView Left="0" Top="83,14966" Width="64" Height="18,89765" Style="Header" Text="FAX"/>' +
'<TfrxMemoView Left="82,89765" Top="83,14966" Width="114" Height="18,89765" Style="Data" Text="813-870-0282"/>' +
'<TfrxMemoView Left="0" Top="120,94496" Width="64" Height="18,89765" Style="Header" Text="Company"/>' +
'<TfrxMemoView Left="82,89765" Top="120,94496" Width="225" Height="18,89765" Style="Data" Text="Action Diver Supply"/>' +
'<TfrxMemoView Left="0" Top="139,84261" Width="64" Height="18,89765" Style="Header" Text="Address"/>' +
'<TfrxMemoView Left="82,89765" Top="139,84261" Width="225" Height="18,89765" Style="Data" Text="Blue Spar Box #3"/>' +
'<TfrxMemoView Left="0" Top="158,74026" Width="64" Height="18,89765" Style="Header" Text="Phone"/>' +
'<TfrxMemoView Left="82,89765" Top="158,74026" Width="114" Height="18,89765" Style="Data" Text="22-44-500211"/>' +
'</TfrxReportPage>' +
'</TfrxReport>';


  Style =
'<?xml version="1.0" encoding="utf-8"?>' +
'<stylesheet>' +
'<style Name="FastReport">' +
'<item Name="Title" Color="8388608" Font.Color="16777215" Font.Height="-16" Font.Style="1"/>' +
'<item Name="Header" Color="536870911" Font.Color="128" Font.Style="1"/>' +
'<item Name="Group header" Color="15790320" Font.Style="1"/>' +
'<item Name="Data" Color="536870911"/>' +
'<item Name="Group footer" Color="536870911" Font.Style="1"/>' +
'<item Name="Header line" Color="536870911" Frame.Typ="8" Frame.Width="2"/>' +
'</style>' +
'<style Name="Standard">' +
'<item Name="Title" Color="536870911" Font.Height="-16" Font.Style="1"/>' +
'<item Name="Header" Color="536870911" Font.Style="1"/>' +
'<item Name="Group header" Color="536870911" Frame.Typ="8"/>' +
'<item Name="Data" Color="536870911"/>' +
'<item Name="Group footer" Color="536870911" Frame.Typ="4"/>' +
'<item Name="Header line" Color="536870911" Frame.Typ="8" Frame.Width="2"/>' +
'</style>' +
'<style Name="Soft gray">' +
'<item Name="Title" Color="14211288" Font.Height="-16" Font.Style="1"/>' +
'<item Name="Header" Color="15790320" Font.Style="1"/>' +
'<item Name="Group header" Color="15790320" Font.Style="1"/>' +
'<item Name="Data" Color="536870911" Font.Style="0"/>' +
'<item Name="Group footer" Color="536870911" Frame.Typ="4"/>' +
'<item Name="Header line" Color="536870911" Frame.Width="2"/>' +
'</style>' +
'<style Name="Corporate">' +
'<item Name="Title" Color="0" Font.Color="16777215" Font.Height="-16" Font.Style="1"/>' +
'<item Name="Header" Color="0" Font.Color="16777215" Font.Style="1"/>' +
'<item Name="Group header" Color="52479" Font.Style="1"/>' +
'<item Name="Data" Color="536870911"/>' +
'<item Name="Group footer" Color="536870911" Font.Style="1"/>' +
'<item Name="Header line" Color="536870911" Frame.Width="2"/>' +
'</style>' +
'</stylesheet>';



{ TfrxStdWizard }

class function TfrxStdWizard.GetDescription: String;
begin
  Result := frxResources.Get('wzStd');
end;

function TfrxStdWizard.Execute: Boolean;
begin
  with TfrxStdWizardForm.Create(Owner) do
  begin
    FDesigner := TfrxDesignerForm(Self.Designer);
    FReport := Report;
    Result := ShowModal = mrOk;
    Free;
  end;
end;


{ TfrxDotMatrixWizard }

class function TfrxDotMatrixWizard.GetDescription: String;
begin
  Result := frxResources.Get('wzDMP');
end;

function TfrxDotMatrixWizard.Execute: Boolean;
begin
  with TfrxStdWizardForm.Create(Owner) do
  begin
    FDesigner := TfrxDesignerForm(Self.Designer);
    FDotMatrix := True;
    FReport := Report;
    Result := ShowModal = mrOk;
    Free;
  end;
end;


{ TfrxStdEmptyWizard }

class function TfrxStdEmptyWizard.GetDescription: String;
begin
  Result := frxResources.Get('wzStdEmpty');
end;

function TfrxStdEmptyWizard.Execute: Boolean;
var
  Page: TfrxReportPage;
begin
  Result := True;
  try
    Designer.Lock;
    Report.Clear;
    Report.FileName := '';
    Report.DotMatrixReport := False;

    Page := TfrxReportPage.Create(Report);
    Page.Name := 'Page1';
    Page.SetDefaults;
  finally
    Designer.ReloadReport;
  end;
end;


{ TfrxDMPEmptyWizard }

class function TfrxDMPEmptyWizard.GetDescription: String;
begin
  Result := frxResources.Get('wzDMPEmpty');
end;

function TfrxDMPEmptyWizard.Execute: Boolean;
var
  Page: TfrxReportPage;
begin
  Result := True;
  try
    Designer.Lock;
    Report.Clear;
    Report.FileName := '';
    Report.DotMatrixReport := True;

    Page := TfrxDMPPage.Create(Report);
    Page.Name := 'Page1';
    Page.SetDefaults;
  finally
    Designer.ReloadReport;
  end;
end;


{ TfrxStdWizardForm }

constructor TfrxStdWizardForm.Create(AOwner: TComponent);
var
  s: TStringStream;
begin
  inherited;
  FStyleReport := TfrxReport.Create(nil);
  s := TStringStream.Create(StyleReport);
  FStyleReport.LoadFromStream(s);
  s.Free;
  FLayoutReport := TfrxReport.Create(nil);

  FStyleSheet := TfrxStyleSheet.Create;
  if FileExists(ExtractFilePath(Application.ExeName) + 'wizstyle.xml') then
    FStyleSheet.LoadFromFile(ExtractFilePath(Application.ExeName) + 'wizstyle.xml')
  else
  begin
    s := TStringStream.Create(Style);
    FStyleSheet.LoadFromStream(s);
    s.Free;
  end;
end;

destructor TfrxStdWizardForm.Destroy;
begin
  FStyleReport.Free;
  FLayoutReport.Free;
  FStyleSheet.Free;
  inherited;
end;

procedure TfrxStdWizardForm.FormCreate(Sender: TObject);
var
  bmp: TBitmap;
begin
  Caption := frxGet(5600);
  DataTab.Caption := frxGet(5601);
  FieldsTab.Caption := frxGet(5602);
  GroupsTab.Caption := frxGet(5603);
  LayoutTab.Caption := frxGet(5604);
  StyleTab.Caption := frxGet(5605);
  Step1L.Caption := frxGet(5606);
  Step2L.Caption := frxGet(5607);
  Step3L.Caption := frxGet(5608);
  Step4L.Caption := frxGet(5609);
  Step5L.Caption := frxGet(5610);
  AddFieldB.Caption := frxGet(5611);
  AddAllFieldsB.Caption := frxGet(5612);
  RemoveFieldB.Caption := frxGet(5613);
  RemoveAllFieldsB.Caption := frxGet(5614);
  AddGroupB.Caption := frxGet(5615);
  RemoveGroupB.Caption := frxGet(5616);
  SelectedFieldsL.Caption := frxGet(5617);
  AvailableFieldsL.Caption := frxGet(5618);
  AvailableFieldsL1.Caption := frxGet(5618);
  GroupsL.Caption := frxGet(5619);
  OrientationL.Caption := frxGet(5620);
  LayoutL.Caption := frxGet(5621);
  PortraitRB.Caption := frxGet(5622);
  LandscapeRB.Caption := frxGet(5623);
  TabularRB.Caption := frxGet(5624);
  ColumnarRB.Caption := frxGet(5625);
  FitWidthCB.Caption := frxGet(5626);
  BackB.Caption := frxGet(5627);
  NextB.Caption := frxGet(5628);
  FinishB.Caption := frxGet(5629);

  ConnectionL.Caption := frxGet(5632);
  TableL.Caption := frxGet(5633);
  orL.Caption := frxGet(5634);
  CreateQueryB.Caption := frxGet(5635);
  ConfigureConnB.Hint := frxGet(5636);

  bmp := TBitmap.Create;
  bmp.Width := 16;
  bmp.Height := 16;
  bmp.Canvas.Brush.Color := clOlive;
  bmp.Canvas.FillRect(Rect(0, 0, 16, 16));
  frxResources.MainButtonImages.Draw(bmp.Canvas, 0, 0, 69);
  ConfigureConnB.Glyph := bmp;
  bmp.Free;
end;

procedure TfrxStdWizardForm.FormShow(Sender: TObject);
var
  Page: TfrxReportPage;
begin
  FDesigner.Lock;
  FReport.Clear;
  if FDotMatrix then
    Page := TfrxDMPPage.Create(FReport) else
    Page := TfrxReportPage.Create(FReport);
  Page.Name := 'Page1';
  Page.SetDefaults;
  FDesigner.ReloadReport;

  FillConnections;
  ConnectionCB.ItemIndex := 0;
  ConnectionCBClick(nil);

  FStyleSheet.GetList(StyleLB.Items);
  StyleLB.ItemIndex := 0;
  StyleLBClick(nil);

  TabularRBClick(nil);
  if FDotMatrix then
    StyleTab.Free;
end;

procedure TfrxStdWizardForm.FillConnections;
var
  ini: TRegistry;
begin
  ConnectionCB.Items.Clear;
  ini := TRegistry.Create;
  try
    ini.RootKey := HKEY_LOCAL_MACHINE;
    if ini.OpenKey(DEF_REG_CONNECTIONS, False) then
      ini.GetValueNames(ConnectionCB.Items);
  finally
    ini.Free;
  end;
end;

procedure TfrxStdWizardForm.FillFields;
begin
  FieldsLB.Clear;
  SelectedFieldsLB.Clear;
  UpdateAvailableFields;

  if FDataset <> nil then
    FDataset.GetFieldList(FieldsLB.Items);

  if FieldsLB.Items.Count <> 0 then
  begin
    FieldsLB.ItemIndex := 0;
    FieldsLB.Selected[0] := True;
  end;
end;

procedure TfrxStdWizardForm.FillTables;
begin
  frxADOGetTableNames(ADOComponents.DefaultDatabase, TablesLB.Items, False);
end;

procedure TfrxStdWizardForm.UpdateAvailableFields;
begin
  AvailableFieldsLB.Items := SelectedFieldsLB.Items;
  GroupsLB.Clear;
end;

procedure TfrxStdWizardForm.DrawSample(PaintBox: TPaintBox; Report: TfrxReport);
var
  i: Integer;
  c: TfrxComponent;
begin
  with PaintBox do
  begin
    Canvas.Pen.Color := clBlack;
    Canvas.Brush.Color := clWindow;
    Canvas.Rectangle(0, 0, Width, Height);

    for i := 0 to Report.AllObjects.Count - 1 do
    begin
      c := Report.AllObjects[i];
      if c is TfrxCustomMemoView then
        with TfrxCustomMemoView(c) do
          Draw(Canvas, 1, 1, 10, 10);
    end;
  end;
end;

procedure TfrxStdWizardForm.ConnectionCBClick(Sender: TObject);
begin
  FReport.ReportOptions.ConnectionName := ConnectionCB.Items[ConnectionCB.ItemIndex];
  FillTables;
end;

procedure TfrxStdWizardForm.ConfigureConnBClick(Sender: TObject);
begin
  with TfrxConnEditorForm.Create(nil) do
  begin
    Report := FReport;
    ShowModal;
    Free;
  end;

  FillConnections;
  ConnectionCB.ItemIndex := 0;
  ConnectionCBClick(nil);
end;

procedure TfrxStdWizardForm.TablesLBClick(Sender: TObject);
begin
  if FDataset <> nil then
    FDataset.Free;

  FDataset := TfrxADOTable.DesignCreate(FReport.Pages[0], 0);
  FDataset.CreateUniqueName;
  TfrxADOTable(FDataset).TableName := TablesLB.Items[TablesLB.ItemIndex];
  TfrxADOTable(FDataset).UserName := TfrxADOTable(FDataset).TableName;

  FillFields;
end;

procedure TfrxStdWizardForm.CreateQueryBClick(Sender: TObject);
var
  ed: TfrxComponentEditor;
begin
  if FDataset <> nil then
    FDataset.Free;

  FDataset := TfrxADOQuery.DesignCreate(FReport.Pages[0], 0);
  FDataset.CreateUniqueName;

  ed := frxComponentEditors.GetComponentEditor(FDataset, FDesigner, nil);
  try
    ed.Edit;
  finally
    ed.Free;
  end;

  FillFields;
end;

procedure TfrxStdWizardForm.AddFieldBClick(Sender: TObject);
var
  i, j: Integer;
begin
  if FieldsLB.ItemIndex = -1 then Exit;

  i := 0;
  j := -1;
  while i < FieldsLB.Items.Count do
    if FieldsLB.Selected[i] then
    begin
      if j = -1 then
        j := i;
      SelectedFieldsLB.Items.Add(FieldsLB.Items[i]);
      FieldsLB.Items.Delete(i);
    end
    else
      Inc(i);

  if j = FieldsLB.Items.Count then
    Dec(j);
  if j <> -1 then
  begin
    FieldsLB.ItemIndex := j;
    FieldsLB.Selected[j] := True;
  end;

  UpdateAvailableFields;
end;

procedure TfrxStdWizardForm.AddAllFieldsBClick(Sender: TObject);
begin
  if FieldsLB.Items.Count = 0 then Exit;
  FillFields;
  SelectedFieldsLB.Items := FieldsLB.Items;
  FieldsLB.Items.Clear;
  UpdateAvailableFields;
end;

procedure TfrxStdWizardForm.RemoveFieldBClick(Sender: TObject);
var
  i, j: Integer;
begin
  if SelectedFieldsLB.ItemIndex = -1 then Exit;

  i := 0;
  j := -1;
  while i < SelectedFieldsLB.Items.Count do
    if SelectedFieldsLB.Selected[i] then
    begin
      if j = -1 then
        j := i;
      FieldsLB.Items.Add(SelectedFieldsLB.Items[i]);
      SelectedFieldsLB.Items.Delete(i);
    end
    else
      Inc(i);

  if j = SelectedFieldsLB.Items.Count then
    Dec(j);
  if j <> -1 then
  begin
    SelectedFieldsLB.ItemIndex := j;
    SelectedFieldsLB.Selected[j] := True;
  end;

  UpdateAvailableFields;
end;

procedure TfrxStdWizardForm.RemoveAllFieldsBClick(Sender: TObject);
begin
  FillFields;
end;

procedure TfrxStdWizardForm.AddGroupBClick(Sender: TObject);
var
  i: Integer;
begin
  i := AvailableFieldsLB.ItemIndex;
  if i = -1 then Exit;
  GroupsLB.Items.Add(AvailableFieldsLB.Items[i]);
  AvailableFieldsLB.Items.Delete(i);
  AvailableFieldsLB.ItemIndex := i;
end;

procedure TfrxStdWizardForm.RemoveGroupBClick(Sender: TObject);
var
  i: Integer;
begin
  i := GroupsLB.ItemIndex;
  if i = -1 then Exit;
  AvailableFieldsLB.Items.Add(GroupsLB.Items[i]);
  GroupsLB.Items.Delete(i);
  GroupsLB.ItemIndex := i;
end;

procedure TfrxStdWizardForm.FieldUpBClick(Sender: TObject);
var
  i: Integer;
begin
  i := SelectedFieldsLB.ItemIndex;
  if i < 1 then Exit;
  SelectedFieldsLB.Items.Exchange(i, i - 1);
  UpdateAvailableFields;
end;

procedure TfrxStdWizardForm.FieldDownBClick(Sender: TObject);
var
  i: Integer;
begin
  i := SelectedFieldsLB.ItemIndex;
  if (i = -1) or (SelectedFieldsLB.Items.Count = 0) or
    (i = SelectedFieldsLB.Items.Count - 1) then Exit;
  SelectedFieldsLB.Items.Exchange(i, i + 1);
  SelectedFieldsLB.ItemIndex := i + 1;
  UpdateAvailableFields;
end;

procedure TfrxStdWizardForm.GroupUpBClick(Sender: TObject);
var
  i: Integer;
begin
  i := GroupsLB.ItemIndex;
  if i < 1 then Exit;
  GroupsLB.Items.Exchange(i, i - 1);
end;

procedure TfrxStdWizardForm.GroupDownBClick(Sender: TObject);
var
  i: Integer;
begin
  i := GroupsLB.ItemIndex;
  if (i = -1) or (i = GroupsLB.Items.Count - 1) then Exit;
  GroupsLB.Items.Exchange(i, i + 1);
  GroupsLB.ItemIndex := i + 1;
end;

procedure TfrxStdWizardForm.NextBClick(Sender: TObject);
begin
  Pages.SelectNextPage(True);
  PagesChange(nil);
end;

procedure TfrxStdWizardForm.BackBClick(Sender: TObject);
begin
  Pages.SelectNextPage(False);
  PagesChange(nil);
end;

procedure TfrxStdWizardForm.PagesChange(Sender: TObject);
begin
  if not FDotMatrix then
    NextB.Enabled := Pages.ActivePage <> StyleTab else
    NextB.Enabled := Pages.ActivePage <> LayoutTab;
  BackB.Enabled := Pages.ActivePage <> DataTab;
end;

procedure TfrxStdWizardForm.GroupsTabShow(Sender: TObject);
begin
  AvailableFieldsLB.ItemIndex := 0;
end;

procedure TfrxStdWizardForm.StylePBPaint(Sender: TObject);
begin
  DrawSample(StylePB, FStyleReport);
end;

procedure TfrxStdWizardForm.LayoutPBPaint(Sender: TObject);
begin
  DrawSample(LayoutPB, FLayoutReport);
end;

procedure TfrxStdWizardForm.PortraitRBClick(Sender: TObject);
begin
  PortraitImg.Visible := PortraitRB.Checked;
  LandscapeImg.Visible := LandscapeRB.Checked;
end;

procedure TfrxStdWizardForm.StyleLBClick(Sender: TObject);
begin
  FStyleReport.Styles := FStyleSheet.Find(StyleLB.Items[StyleLB.ItemIndex]);
  StylePBPaint(nil);
end;

procedure TfrxStdWizardForm.TabularRBClick(Sender: TObject);
var
  s: TStringStream;
begin
  if TabularRB.Checked then
    s := TStringStream.Create(LayoutTabularReport)
  else
    s := TStringStream.Create(LayoutColumnarReport);
  FLayoutReport.LoadFromStream(s);
  s.Free;
  FLayoutReport.Styles := FStyleSheet[0];
  LayoutPBPaint(nil);
end;

procedure TfrxStdWizardForm.FinishBClick(Sender: TObject);
var
  Page: TfrxReportPage;
  Band: TfrxBand;
  Memo: TfrxCustomMemoView;
  CurY, PageWidth, MaxHeaderWidth: Extended;
  Widths, HeaderWidths, DataWidths: array of Extended;

  function Duplicate(n: Integer): String;
  begin
    Result := '';
    SetLength(Result, n);
    FillChar(Result[1], n, '0');
  end;

  function CreateMemo(Parent: TfrxComponent): TfrxCustomMemoView;
  begin
    if FDotMatrix then
      Result := TfrxDMPMemoView.Create(Parent) else
      Result := TfrxMemoView.Create(Parent);
    if Parent <> nil then
      Result.CreateUniqueName;
  end;

  procedure CreatePage;
  begin
    Page := TfrxReportPage(FReport.Pages[0]);
    if PortraitRB.Checked then
      Page.Orientation := poPortrait else
      Page.Orientation := poLandscape;
    PageWidth := (Page.PaperWidth - Page.LeftMargin - Page.RightMargin) * 96 / 25.4;
  end;

  procedure CreateWidthsArray;
  var
    i, FieldsCount: Integer;
    HeaderMemo, DataMemo: TfrxCustomMemoView;
    MaxWidth, HeadersWidth, GapWidth: Extended;
    Style: TfrxStyles;
  begin
    FieldsCount := AvailableFieldsLB.Items.Count;
    SetLength(Widths, FieldsCount);
    SetLength(HeaderWidths, FieldsCount);
    SetLength(DataWidths, FieldsCount);

    HeaderMemo := CreateMemo(nil);
    DataMemo := CreateMemo(nil);
    if not FDotMatrix then
    begin
      Style := FStyleSheet.Find(StyleLB.Items[StyleLB.ItemIndex]);
      HeaderMemo.ApplyStyle(Style.Find('Header'));
      DataMemo.ApplyStyle(Style.Find('Data'));
    end;

    MaxWidth := 0;
    HeadersWidth := 0;
    MaxHeaderWidth := 0;
    GapWidth := 0;
    for i := 0 to FieldsCount - 1 do
    begin
      HeaderMemo.Text := AvailableFieldsLB.Items[i];
      DataMemo.Text := Duplicate(FDataSet.DisplayWidth[AvailableFieldsLB.Items[i]]);
      HeaderWidths[i] := HeaderMemo.CalcWidth;
      DataWidths[i] := DataMemo.CalcWidth;
      if HeaderWidths[i] > DataWidths[i] then
        Widths[i] := HeaderWidths[i]
      else
      begin
        Widths[i] := DataWidths[i];
        GapWidth := GapWidth + DataWidths[i] - HeaderWidths[i];
      end;
      MaxWidth := MaxWidth + Widths[i];
      HeadersWidth := HeadersWidth + HeaderWidths[i];
      if HeaderWidths[i] > MaxHeaderWidth then
        MaxHeaderWidth := HeaderWidths[i];
    end;

    if FitWidthCB.Checked and (MaxWidth > PageWidth) then
    begin
      if HeadersWidth > PageWidth then
      begin
        for i := 0 to FieldsCount - 1 do
          Widths[i] := HeaderWidths[i] / (HeadersWidth / PageWidth);
      end
      else
      begin
        for i := 0 to FieldsCount - 1 do
          if HeaderWidths[i] < DataWidths[i] then
            Widths[i] := Widths[i] - (DataWidths[i] - HeaderWidths[i]) /
              GapWidth * (MaxWidth - PageWidth);
      end;
    end;

    HeaderMemo.Free;
    DataMemo.Free;
  end;

  procedure CreateTitle;
  begin
    Band := TfrxReportTitle.Create(Page);
    Band.CreateUniqueName;
    Band.SetBounds(0, 0, 0, fr01cm * 7);
    CurY := 30;

    Memo := CreateMemo(Band);
    Memo.SetBounds(0, 0, 0, fr01cm * 6);
    Memo.Align := baWidth;
    Memo.HAlign := haCenter;
    Memo.VAlign := vaCenter;
    Memo.Text := 'Report';
    Memo.Style := 'Title';
  end;

  procedure CreateHeader;
  var
    i: Integer;
    X, Y: Extended;
    HeaderMemo: TfrxCustomMemoView;
  begin
    if ColumnarRB.Checked then Exit;

    Band := TfrxPageHeader.Create(Page);
    Band.CreateUniqueName;
    Band.SetBounds(0, CurY, 0, fr01cm * 7);

    HeaderMemo := CreateMemo(Band);
    HeaderMemo.SetBounds(0, 0, PageWidth, 0);
    HeaderMemo.Style := 'Header line';

    X := 0;
    Y := 0;
    for i := 0 to AvailableFieldsLB.Items.Count - 1 do
    begin
      if X + Widths[i] > PageWidth + 1 then
      begin
        X := 0;
        Y := Y + fr01cm * 6;
      end;

      Memo := CreateMemo(Band);
      Memo.SetBounds(X, Y, Widths[i], fr01cm * 6);
      Memo.Text := AvailableFieldsLB.Items[i];
      Memo.Style := 'Header';

      X := X + Widths[i];
    end;

    Band.Height := Y + fr01cm * 6;
    HeaderMemo.Height := Band.Height;
    if FDotMatrix then
      HeaderMemo.Free;
    CurY := CurY + Band.Height;
  end;

  procedure CreateGroupHeaders;
  var
    i: Integer;
  begin
    for i := 0 to GroupsLB.Items.Count - 1 do
    begin
      Band := TfrxGroupHeader.Create(Page);
      Band.CreateUniqueName;
      Band.SetBounds(0, CurY, 0, fr01cm * 7);
      TfrxGroupHeader(Band).Condition := FDataSet.UserName + '."' + GroupsLB.Items[i] + '"';
      CurY := CurY + 30;

      Memo := CreateMemo(Band);
      Memo.SetBounds(0, 0, 0, fr01cm * 6);
      Memo.Align := baWidth;
      Memo.VAlign := vaCenter;
      Memo.DataSet := FDataSet;
      Memo.DataField := GroupsLB.Items[i];
      Memo.Style := 'Group header';
    end;
  end;

  procedure CreateData;
  var
    i: Integer;
    X, Y: Extended;
  begin
    Band := TfrxMasterData.Create(Page);
    Band.CreateUniqueName;
    Band.SetBounds(0, CurY, 0, 0);
    TfrxMasterData(Band).DataSet := FDataSet;
    CurY := CurY + 30;

    X := 0;
    Y := 0;
    for i := 0 to AvailableFieldsLB.Items.Count - 1 do
    begin
      if ColumnarRB.Checked then
      begin
        Memo := CreateMemo(Band);
        Memo.SetBounds(0, Y, MaxHeaderWidth, fr01cm * 5);
        Memo.Text := AvailableFieldsLB.Items[i];
        Memo.Style := 'Header';

        Memo := CreateMemo(Band);
        Memo.SetBounds(MaxHeaderWidth + fr01cm * 5, Y, DataWidths[i], fr01cm * 5);
        Memo.DataSet := FDataSet;
        Memo.DataField := AvailableFieldsLB.Items[i];
        Memo.Style := 'Data';

        Y := Y + fr01cm * 5;
      end
      else
      begin
        if X + Widths[i] > PageWidth + 1 then
        begin
          X := 0;
          Y := Y + fr01cm * 5;
        end;

        Memo := CreateMemo(Band);
        Memo.SetBounds(X, Y, Widths[i], fr01cm * 5);
        Memo.DataSet := FDataSet;
        Memo.DataField := AvailableFieldsLB.Items[i];
        Memo.Style := 'Data';

        X := X + Widths[i];
      end;
    end;

    Band.Height := Y + fr01cm * 5;
    CurY := CurY + Band.Height;
  end;

  procedure CreateGroupFooters;
  var
    i: Integer;
  begin
    CurY := 1000;
    for i := GroupsLB.Items.Count - 1 downto 0 do
    begin
      Band := TfrxGroupFooter.Create(Page);
      Band.CreateUniqueName;
      Band.SetBounds(0, CurY, 0, 0);
      CurY := CurY - 30;
    end;
  end;

  procedure CreateFooter;
  begin
    Band := TfrxPageFooter.Create(Page);
    Band.CreateUniqueName;
    Band.SetBounds(0, 1000, 0, fr01cm * 7);

    Memo := CreateMemo(Band);
    Memo.Align := baWidth;
    Memo.Frame.Typ := [ftTop];
    Memo.Frame.Width := 2;

    Memo := CreateMemo(Band);
    Memo.SetBounds(0, 1, 0, fr01cm * 6);
    Memo.AutoWidth := True;
    Memo.Text := '[Date] [Time]';

    Memo := CreateMemo(Band);
    Memo.SetBounds(100, 1, fr1cm * 2, fr01cm * 6);
    Memo.Align := baRight;
    Memo.HAlign := haRight;
    Memo.Text := 'Page [Page#]';
  end;

begin
  try
    FDesigner.Lock;
    FReport.FileName := '';
    FReport.DotMatrixReport := FDotMatrix;

    FReport.DataSets.Clear;
    if FDataset <> nil then
      FReport.DataSets.Add(FDataSet);

    CreatePage;
    CreateWidthsArray;
    CreateTitle;
    CreateHeader;
    CreateGroupHeaders;
    CreateData;
    CreateGroupFooters;
    CreateFooter;

    if not FDotMatrix then
      FReport.Styles := FStyleSheet.Find(StyleLB.Items[StyleLB.ItemIndex]);

  finally
    FDesigner.ReloadReport;
    Widths := nil;
    HeaderWidths := nil;
    DataWidths := nil;
  end;
end;

procedure TfrxStdWizardForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;


initialization
  frxWizards.Register1(TfrxStdWizard, 1);
  frxWizards.Register1(TfrxStdEmptyWizard, 0);
{$IFNDEF FR_LITE}
  frxWizards.Register1(TfrxDotMatrixWizard, 1);
  frxWizards.Register1(TfrxDMPEmptyWizard, 0);
{$ENDIF}

finalization
  frxWizards.Unregister(TfrxStdWizard);
  frxWizards.Unregister(TfrxStdEmptyWizard);
{$IFNDEF FR_LITE}
  frxWizards.Unregister(TfrxDotMatrixWizard);
  frxWizards.Unregister(TfrxDMPEmptyWizard);
{$ENDIF}

end.


//0f31356a91fea3356e5f76cdce90aa7b