
{******************************************}
{                                          }
{             FastReport v4.0              }
{          Data Tree tool window           }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxDataTree;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, frxClass, fs_xml, ComCtrls
{$IFDEF UseTabset}
, Tabs
{$ENDIF}
{$IFDEF Delphi6}
, Variants
{$ENDIF};


type
  TfrxDataTreeForm = class(TForm)
    DataPn: TPanel;
    DataTree: TTreeView;
    CBPanel: TPanel;
    InsFieldCB: TCheckBox;
    InsCaptionCB: TCheckBox;
    VariablesPn: TPanel;
    VariablesTree: TTreeView;
    FunctionsPn: TPanel;
    Splitter1: TSplitter;
    HintPanel: TScrollBox;
    FunctionDescL: TLabel;
    FunctionNameL: TLabel;
    FunctionsTree: TTreeView;
    ClassesPn: TPanel;
    ClassesTree: TTreeView;
    NoDataPn: TScrollBox;
    NoDataL: TLabel;
    procedure FormResize(Sender: TObject);
    procedure DataTreeCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure FunctionsTreeChange(Sender: TObject; Node: TTreeNode);
    procedure DataTreeDblClick(Sender: TObject);
    procedure ClassesTreeExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure ClassesTreeCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
  private
    { Private declarations }
    FXML: TfsXMLDocument;
    FImages: TImageList;
    FReport: TfrxReport;
    FUpdating: Boolean;
    FFirstTime: Boolean;
{$IFDEF UseTabset}
    FTabs: TTabSet;
{$ELSE}
    FTabs: TTabControl;
{$ENDIF}
    procedure FillClassesTree;
    procedure FillDataTree;
    procedure FillFunctionsTree;
    procedure FillVariablesTree;
    procedure TabsChange(Sender: TObject);
    function GetCollapsedNodes: String;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetColor(Color: TColor);
    procedure SetControlsParent(AParent: TWinControl);
    procedure SetLastPosition(p: TPoint);
    procedure ShowTab(Index: Integer);
    procedure UpdateItems;
    procedure UpdateSelection;
    procedure UpdateSize;
    function GetActivePage: Integer;
    function GetFieldName: String;
    function GetLastPosition: TPoint;
    function IsDataField: Boolean;
    property Report: TfrxReport read FReport write FReport;
  end;


implementation

{$R *.DFM}

uses fs_iinterpreter, fs_itools, frxRes;

var
  CollapsedNodes: String;

type
  THackWinControl = class(TWinControl);


procedure SetImageIndex(Node: TTreeNode; Index: Integer);
begin
  Node.ImageIndex := Index;
  Node.StateIndex := Index;
  Node.SelectedIndex := Index;
end;


{ TfrxDataTreeForm }

constructor TfrxDataTreeForm.Create(AOwner: TComponent);
begin
  inherited;
  FImages := frxResources.MainButtonImages;
  DataTree.Images := FImages;
  VariablesTree.Images := FImages;
  FunctionsTree.Images := FImages;
  ClassesTree.Images := FImages;
  THackWinControl(DataTree).BevelKind := bkFlat;
  THackWinControl(VariablesTree).BevelKind := bkFlat;
  THackWinControl(FunctionsTree).BevelKind := bkFlat;
  THackWinControl(ClassesTree).BevelKind := bkFlat;

  FXML := TfsXMLDocument.Create;
  FFirstTime := True;
{$IFDEF UseTabset}
  FTabs := TTabSet.Create(Self);
  FTabs.ShrinkToFit := True;
  FTabs.Style := tsSoftTabs;
  FTabs.TabPosition := tpTop;
{$ELSE}
  FTabs := TTabControl.Create(Self);
{$ENDIF}
  FTabs.Parent := Self;
  FTabs.SendToBack;

  Caption := frxGet(2100);
  FTabs.Tabs.AddObject(frxGet(2101), DataPn);
  FTabs.Tabs.AddObject(frxGet(2102), VariablesPn);
  FTabs.Tabs.AddObject(frxGet(2103), FunctionsPn);
  FTabs.Tabs.AddObject(frxGet(2106), ClassesPn);
  FTabs.TabIndex := 0;
  InsFieldCB.Caption := frxGet(2104);
  InsCaptionCB.Caption := frxGet(2105);
{$IFDEF UseTabset}
  FTabs.OnClick := TabsChange;
{$ELSE}
  FTabs.OnChange := TabsChange;
{$ENDIF}
end;

destructor TfrxDataTreeForm.Destroy;
begin
  if Owner is TfrxCustomDesigner then
    CollapsedNodes := GetCollapsedNodes;
  FUpdating := True;
  FXML.Free;
  inherited;
end;

procedure TfrxDataTreeForm.FillDataTree;
var
  ds: TfrxDataSet;
  DatasetsList, FieldsList: TStrings;
  i, j: Integer;
  Root, Node1, Node2: TTreeNode;
  s, Collapsed: String;
begin
  DatasetsList := TStringList.Create;
  FieldsList := TStringList.Create;
  FReport.GetDataSetList(DatasetsList);

  try
    if FFirstTime then
      Collapsed := CollapsedNodes
    else
      Collapsed := GetCollapsedNodes;

    DataTree.Items.BeginUpdate;
    DataTree.Items.Clear;
    if DatasetsList.Count = 0 then
    begin
      NoDataL.Caption := frxResources.Get('dtNoData') + '.' + #13#10#13#10 +
        frxResources.Get('dtNoData1');
      NoDataPn.Visible := True;
    end
    else
    begin
      NoDataPn.Visible := False;
      s := frxResources.Get('dtData');
      Root := DataTree.Items.AddChild(nil, s);
      SetImageIndex(Root, 53);

      for i := 0 to DatasetsList.Count - 1 do
      begin
        ds := TfrxDataSet(DatasetsList.Objects[i]);
        if ds = nil then continue;
        try
          ds.GetFieldList(FieldsList);
        except
        end;

        Node1 := DataTree.Items.AddChild(Root, FReport.GetAlias(ds));
        Node1.Data := ds;
        SetImageIndex(Node1, 72);

        for j := 0 to FieldsList.Count - 1 do
        begin
          Node2 := DataTree.Items.AddChild(Node1, FieldsList[j]);
          Node2.Data := ds;
          SetImageIndex(Node2, 54);
        end;
      end;

      DataTree.Items[0].Expanded := True;
      for i := 0 to DataTree.Items[0].Count - 1 do
      begin
        s := DataTree.Items[0][i].Text;
        if Pos(s + ',', Collapsed) = 0 then
          DataTree.Items[0][i].Expanded := True;
      end;
    end;
  finally
    DataTree.Items.EndUpdate;
    DatasetsList.Free;
    FieldsList.Free;
  end;
end;

procedure TfrxDataTreeForm.FillVariablesTree;
var
  CategoriesList, VariablesList: TStrings;
  i: Integer;
  Root, Node: TTreeNode;

  procedure AddVariables(Node: TTreeNode);
  var
    i: Integer;
    Node1: TTreeNode;
  begin
    for i := 0 to VariablesList.Count - 1 do
    begin
      Node1 := VariablesTree.Items.AddChild(Node, VariablesList[i]);
      SetImageIndex(Node1, 80);
    end;
  end;

  procedure AddSystemVariables;
  var
    SysNode: TTreeNode;

    procedure AddNode(const s: String);
    var
      Node: TTreeNode;
    begin
      Node := VariablesTree.Items.AddChild(SysNode, s);
      SetImageIndex(Node, 80);
    end;

  begin
    SysNode := VariablesTree.Items.AddChild(Root, frxResources.Get('dtSysVar'));
    SetImageIndex(SysNode, 66);

    AddNode('Date');
    AddNode('Time');
    AddNode('Page');
    AddNode('Page#');
    AddNode('TotalPages');
    AddNode('TotalPages#');
    AddNode('Line');
    AddNode('Line#');
    AddNode('CopyName#');
  end;

begin
  CategoriesList := TStringList.Create;
  VariablesList := TStringList.Create;
  FReport.Variables.GetCategoriesList(CategoriesList);

  VariablesTree.Items.BeginUpdate;
  VariablesTree.Items.Clear;
  Root := VariablesTree.Items.AddChild(nil, frxResources.Get('dtVar'));
  SetImageIndex(Root, 66);

  for i := 0 to CategoriesList.Count - 1 do
  begin
    FReport.Variables.GetVariablesList(CategoriesList[i], VariablesList);
    Node := VariablesTree.Items.AddChild(Root, CategoriesList[i]);
    SetImageIndex(Node, 66);
    AddVariables(Node);
  end;

  if CategoriesList.Count = 0 then
  begin
    FReport.Variables.GetVariablesList('', VariablesList);
    AddVariables(Root);
  end;

  AddSystemVariables;

  VariablesTree.FullExpand;
  VariablesTree.TopItem := Root;
  VariablesTree.Items.EndUpdate;
  CategoriesList.Free;
  VariablesList.Free;
end;

procedure TfrxDataTreeForm.FillFunctionsTree;

  procedure AddFunctions(xi: TfsXMLItem; Root: TTreeNode);
  var
    i: Integer;
    Node: TTreeNode;
    s: String;
  begin
    s := xi.Prop['text'];
    if xi.Count = 0 then
      s := Copy(s, Pos(' ', s) + 1, 255) else  { function }
      s := frxResources.Get(s);                { category }

    if CompareText(s, 'hidden') = 0 then Exit;
    Node := FunctionsTree.Items.AddChild(Root, s);
    if xi.Count = 0 then
      Node.Data := xi;
    if Root = nil then
      Node.Text := frxResources.Get('dtFunc');
    if xi.Count = 0 then
      SetImageIndex(Node, 52) else
      SetImageIndex(Node, 66);

    for i := 0 to xi.Count - 1 do
      AddFunctions(xi[i], Node);
  end;

begin
  FUpdating := True;

  FunctionsTree.Items.BeginUpdate;
  FunctionsTree.Items.Clear;
  AddFunctions(FXML.Root.FindItem('Functions'), nil);

  FunctionsTree.FullExpand;
  FunctionsTree.TopItem := FunctionsTree.Items[0];
  FunctionsTree.Items.EndUpdate;
  FUpdating := False;
end;

procedure TfrxDataTreeForm.FillClassesTree;

  procedure AddClasses(xi: TfsXMLItem; Root: TTreeNode);
  var
    i: Integer;
    Node: TTreeNode;
    s: String;
  begin
    s := xi.Prop['text'];

    Node := ClassesTree.Items.AddChild(Root, s);
    Node.Data := xi;
    if Root = nil then
    begin
      Node.Text := frxResources.Get('2106');
      SetImageIndex(Node, 66);
    end
    else
      SetImageIndex(Node, 78);

    if Root = nil then
    begin
      for i := 0 to xi.Count - 1 do
        AddClasses(xi[i], Node);
    end
    else
      ClassesTree.Items.AddChild(Node, 'more...');  // do not localize
  end;

begin
  FUpdating := True;

  ClassesTree.Items.BeginUpdate;
  ClassesTree.Items.Clear;
  AddClasses(FXML.Root.FindItem('Classes'), nil);

  ClassesTree.TopItem := ClassesTree.Items[0];
  ClassesTree.TopItem.Expand(False);
  ClassesTree.Items.EndUpdate;
  FUpdating := False;
end;

function TfrxDataTreeForm.GetCollapsedNodes: String;
var
  i: Integer;
  s: String;
begin
  Result := '';
  if DataTree.Items.Count > 0 then
    for i := 0 to DataTree.Items[0].Count - 1 do
    begin
      s := DataTree.Items[0][i].Text;
      if not DataTree.Items[0][i].Expanded then
        Result := Result + s + ',';
    end;
end;

function TfrxDataTreeForm.GetFieldName: String;
var
  i, n: Integer;
  s: String;
  Node: TTreeNode;
begin
  Result := '';
  if FTabs.TabIndex = 0 then   // data
  begin
    Node := DataTree.Selected;
    if (Node <> nil) and (Node.Count = 0) and (Node.Data <> nil) then
      Result := '<' + FReport.GetAlias(TfrxDataSet(Node.Data)) +
        '."' + Node.Text + '"' + '>';
  end
  else if FTabs.TabIndex = 1 then  // variables
  begin
    Node := VariablesTree.Selected;
    if (Node <> nil) and (Node.Count = 0) then
      if Node.Data <> nil then
        Result := Node.Text else
        Result := '<' + Node.Text + '>';
  end
  else if FTabs.TabIndex = 2 then  // functions
  begin
    if (FunctionsTree.Selected <> nil) and (FunctionsTree.Selected.Count = 0) then
    begin
      s := FunctionsTree.Selected.Text;
      if Pos('(', s) <> 0 then
        n := 1 else
        n := 0;
      for i := 1 to Length(s) do
        if s[i] in [',', ';'] then
          Inc(n);

      if n = 0 then
        s := Copy(s, 1, Pos(':', s) - 1)
      else
      begin
        s := Copy(s, 1, Pos('(', s));
        for i := 1 to n - 1 do
          s := s + ',';
        s := s + ')';
      end;
      Result := s;
    end;
  end;
end;

function TfrxDataTreeForm.IsDataField: Boolean;
begin
  Result := FTabs.TabIndex = 0;
end;

procedure TfrxDataTreeForm.UpdateItems;
begin
  FillDataTree;
  FillVariablesTree;
  FFirstTime := False;
end;

procedure TfrxDataTreeForm.SetColor(Color: TColor);
begin
  DataTree.Color := Color;
  VariablesTree.Color := Color;
  FunctionsTree.Color := Color;
  ClassesTree.Color := Color;
end;

procedure TfrxDataTreeForm.FormResize(Sender: TObject);
begin
  UpdateSize;
end;

procedure TfrxDataTreeForm.DataTreeCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if Node.Count <> 0 then
    Sender.Canvas.Font.Style := [fsBold];
end;

procedure TfrxDataTreeForm.ClassesTreeCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if Node.Level = 0 then
    Sender.Canvas.Font.Style := [fsBold];
end;

procedure TfrxDataTreeForm.FunctionsTreeChange(Sender: TObject;
  Node: TTreeNode);
var
  xi: TfsXMLItem;
begin
  if FUpdating then Exit;
  Node := FunctionsTree.Selected;
  if (Node = nil) or (Node.Data = nil) then
  begin
    FunctionNameL.Caption := '';
    FunctionDescL.Caption := '';
    Exit;
  end
  else
  begin
    xi := Node.Data;
    FunctionNameL.Caption := xi.Prop['text'];
    FunctionDescL.Caption := frxResources.Get(xi.Prop['description']);
    FunctionNameL.AutoSize := True;
  end;
end;

procedure TfrxDataTreeForm.DataTreeDblClick(Sender: TObject);
begin
  if Assigned(OnDblClick) then
    OnDblClick(Sender);
end;

procedure TfrxDataTreeForm.ClassesTreeExpanding(Sender: TObject;
  Node: TTreeNode; var AllowExpansion: Boolean);
var
  i: Integer;
  xi: TfsXMLItem;
  s: String;
  n: TTreeNode;
begin
  if (Node.Level = 1) and (Node.Data <> nil) then
  begin
    FUpdating := True;
    ClassesTree.Items.BeginUpdate;

    Node.DeleteChildren;
    xi := TfsXMLItem(Node.Data);
    Node.Data := nil;

    for i := 0 to xi.Count - 1 do
    begin
      s := xi[i].Prop['text'];
      n := ClassesTree.Items.AddChild(Node, s);
      if Pos('property', s) = 1 then
        SetImageIndex(n, 73)
      else if Pos('event', s) = 1 then
        SetImageIndex(n, 79)
      else
        SetImageIndex(n, 74);
    end;

    ClassesTree.Items.EndUpdate;
  end;
end;

function TfrxDataTreeForm.GetLastPosition: TPoint;
var
  Item: TTreeNode;
begin
  Result.X := FTabs.TabIndex;
  Result.Y := 0;
  Item := nil;
  case Result.X of
    0: Item := DataTree.TopItem;
    1: Item := VariablesTree.TopItem;
    2: Item := FunctionsTree.TopItem;
    3: Item := ClassesTree.TopItem;
  end;
  if Item <> nil then
    Result.Y := Item.AbsoluteIndex;
end;

procedure TfrxDataTreeForm.SetLastPosition(p: TPoint);
begin
  ShowTab(p.X);
  case p.X of
    0: if DataTree.Items.Count > 0 then DataTree.TopItem := DataTree.Items[p.Y];
    1: if VariablesTree.Items.Count > 0 then VariablesTree.TopItem := VariablesTree.Items[p.Y];
    2: if FunctionsTree.Items.Count > 0 then FunctionsTree.TopItem := FunctionsTree.Items[p.Y];
    3: if ClassesTree.Items.Count > 0 then ClassesTree.TopItem := ClassesTree.Items[p.Y];
  end;
end;

procedure TfrxDataTreeForm.TabsChange(Sender: TObject);
begin
  ShowTab(FTabs.TabIndex);
end;

procedure TfrxDataTreeForm.ShowTab(Index: Integer);
var
  i: Integer;
begin
  if (Index < 0) or (Index > FTabs.Tabs.Count - 1) then Exit;
  FTabs.TabIndex := Index;
  for i := 0 to FTabs.Tabs.Count - 1 do
    TControl(FTabs.Tabs.Objects[i]).Visible := i = Index;

  if FXML.Root.Count = 0 then
  begin
    FReport.Script.AddRTTI;
    GenerateXMLContents(FReport.Script, FXML.Root);
  end;

  if (Index = 2) and (FunctionsTree.Items.Count = 0) then
    FillFunctionsTree;
  if (Index = 3) and (ClassesTree.Items.Count = 0) then
    FillClassesTree;
end;

procedure TfrxDataTreeForm.SetControlsParent(AParent: TWinControl);
begin
  FTabs.Parent := AParent;
  DataPn.Parent := AParent;
  VariablesPn.Parent := AParent;
  FunctionsPn.Parent := AParent;
  ClassesPn.Parent := AParent;
end;

procedure TfrxDataTreeForm.UpdateSize;
var
  Y: Integer;
begin
  AutoScroll := False;
  with FTabs.Parent do
  begin
    if Screen.PixelsPerInch > 96 then
      Y := 26
    else
      Y := 22;
    FTabs.SetBounds(0, 0, ClientWidth, Y);
{$IFDEF UseTabset}
    Y := FTabs.Height - 1;
{$ELSE}
    Y := FTabs.Height - 2;
{$ENDIF}
    DataPn.SetBounds(0, Y, ClientWidth, ClientHeight - Y);
    VariablesPn.SetBounds(0, Y, ClientWidth, ClientHeight - Y);
    FunctionsPn.SetBounds(0, Y, ClientWidth, ClientHeight - Y);
    ClassesPn.SetBounds(0, Y, ClientWidth, ClientHeight - Y);
    NoDataPn.SetBounds(10, 20, DataPn.Width - 20, 140);
  end;
end;

function TfrxDataTreeForm.GetActivePage: Integer;
begin
  Result := FTabs.TabIndex;
end;

procedure TfrxDataTreeForm.UpdateSelection;
var
  i: Integer;
begin
  if GetActivePage = 0 then
  begin
    DataTree.Selected := nil;
    if (Report.Designer.SelectedObjects.Count = 1) and
      (TObject(Report.Designer.SelectedObjects[0]) is TfrxDataset) then
    begin
      for i := 0 to DataTree.Items.Count - 1 do
        if DataTree.Items[i].Data = Report.Designer.SelectedObjects[0] then
        begin
          DataTree.Selected := DataTree.Items[i];
          break;
        end;
    end;
  end;
end;

end.


//0f31356a91fea3356e5f76cdce90aa7b