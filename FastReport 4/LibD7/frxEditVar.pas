
{******************************************}
{                                          }
{             FastReport v4.0              }
{             Variables editor             }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxEditVar;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, frxClass, ExtCtrls, ImgList, Buttons, frxDock,
  ToolWin, frxVariables, frxDataTree
{$IFDEF Delphi6}
, Variants
{$ENDIF};
  

type
  TfrxVarEditorForm = class(TForm)
    VarTree: TTreeView;
    ToolBar: TToolBar;
    NewCategoryB: TToolButton;
    NewVarB: TToolButton;
    EditB: TToolButton;
    DeleteB: TToolButton;
    EditListB: TToolButton;
    OkB: TToolButton;
    CancelB: TToolButton;
    Sep1: TToolButton;
    ExprMemo: TMemo;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    ExprPanel: TPanel;
    LoadB: TToolButton;
    SaveB: TToolButton;
    Sep2: TToolButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Panel: TPanel;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DeleteBClick(Sender: TObject);
    procedure NewCategoryBClick(Sender: TObject);
    procedure NewVarBClick(Sender: TObject);
    procedure OkBClick(Sender: TObject);
    procedure EditBClick(Sender: TObject);
    procedure VarTreeEdited(Sender: TObject; Node: TTreeNode;
      var S: String);
    procedure VarTreeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ExprMemoDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ExprMemoDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure VarTreeChange(Sender: TObject; Node: TTreeNode);
    procedure VarTreeChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure CancelBClick(Sender: TObject);
    procedure EditListBClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure LoadBClick(Sender: TObject);
    procedure SaveBClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Splitter2Moved(Sender: TObject);
  private
    FReport: TfrxReport;
    FUpdating: Boolean;
    FVariables: TfrxVariables;
    FDataTree: TfrxDataTreeForm;
    function Root: TTreeNode;
    procedure CreateUniqueName(var s: String);
    procedure FillVariables;
    procedure UpdateItem0;
    procedure OnDataTreeDblClick(Sender: TObject);
  public
  end;


implementation

{$R *.DFM}

uses frxEditStrings, frxUtils, frxRes, IniFiles;

var
  lastPosition: TPoint;

type
  THackWinControl = class(TWinControl);


procedure SetImageIndex(Node: TTreeNode; Index: Integer);
begin
  Node.ImageIndex := Index;
  Node.StateIndex := Index;
  Node.SelectedIndex := Index;
end;


{ TfrxVarEditorForm }

procedure TfrxVarEditorForm.FormCreate(Sender: TObject);
begin
  Icon := TForm(Owner).Icon;
  FReport := TfrxCustomDesigner(Owner).Report;
  VarTree.Images := frxResources.MainButtonImages;
  Toolbar.Images := VarTree.Images;
  THackWinControl(VarTree).BevelKind := bkFlat;
  THackWinControl(ExprMemo).BevelKind := bkFlat;


  FVariables := TfrxVariables.Create;
  FVariables.Assign(FReport.Variables);

  FDataTree := TfrxDataTreeForm.Create(Owner);
  FDataTree.Report := FReport;
  FDataTree.OnDblClick := OnDataTreeDblClick;
  FDataTree.SetControlsParent(Panel);
  FDataTree.HintPanel.Height := 64;
  FDataTree.UpdateItems;

  Caption := frxGet(2900);
  NewCategoryB.Hint := frxGet(2901);
  NewVarB.Hint := frxGet(2902);
  EditB.Hint := frxGet(2903);
  DeleteB.Hint := frxGet(2904);
  EditListB.Hint := frxGet(2905);
  LoadB.Hint := frxGet(2906);
  SaveB.Hint := frxGet(2907);
  CancelB.Hint := frxGet(2);
  OkB.Hint := frxGet(1);
  ExprPanel.Caption := ' ' + frxGet(2908);
  OpenDialog1.Filter := frxGet(2909);
  SaveDialog1.Filter := frxGet(2910);
end;

procedure TfrxVarEditorForm.FormDestroy(Sender: TObject);
begin
  FDataTree.Free;
  FVariables.Free;
end;

procedure TfrxVarEditorForm.FormShow(Sender: TObject);
var
  Ini: TCustomIniFile;
begin
  Ini := FReport.GetIniFile;
  Ini.WriteBool('Form4.TfrxVarEditorForm', 'Visible', True);
  frxRestoreFormPosition(Ini, Self);
  ExprMemo.Height := Ini.ReadInteger('Form4.TfrxVarEditorForm', 'Split1Pos', 76);
  Panel.Width := Ini.ReadInteger('Form4.TfrxVarEditorForm', 'Split2Pos', 400);
  FDataTree.UpdateSize;
  Ini.Free;

  FillVariables;
  VarTree.SetFocus;
  FDataTree.SetLastPosition(lastPosition);
end;

procedure TfrxVarEditorForm.FormHide(Sender: TObject);
var
  Ini: TCustomIniFile;
begin
  Ini := FReport.GetIniFile;
  frxSaveFormPosition(Ini, Self);
  Ini.WriteInteger('Form4.TfrxVarEditorForm', 'Split1Pos', ExprMemo.Height);
  Ini.WriteInteger('Form4.TfrxVarEditorForm', 'Split2Pos', Panel.Width);
  Ini.Free;
  lastPosition := FDataTree.GetLastPosition;
end;

procedure TfrxVarEditorForm.OkBClick(Sender: TObject);
begin
  ModalResult := mrOk;
  VarTree.Selected := VarTree.Items[0];
  FReport.Variables.Assign(FVariables);
end;

procedure TfrxVarEditorForm.CancelBClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

function TfrxVarEditorForm.Root: TTreeNode;
begin
  Result := VarTree.Items[0];
end;

procedure TfrxVarEditorForm.UpdateItem0;
begin
  if Root.Count = 0 then
    Root.Text := frxResources.Get('vaNoVar') else
    Root.Text := frxResources.Get('vaVar');
end;

procedure TfrxVarEditorForm.CreateUniqueName(var s: String);
var
  i: Integer;
begin
  i := 0;
  repeat
    Inc(i);
  until FVariables.IndexOf(s + IntToStr(i)) = -1;
  s := s + IntToStr(i);
end;

procedure TfrxVarEditorForm.FillVariables;
var
  i: Integer;
  CategoriesList, VariablesList: TStrings;
  Node: TTreeNode;

  procedure AddVariables(Node: TTreeNode);
  var
    i: Integer;
    Node1: TTreeNode;
  begin
    for i := 0 to VariablesList.Count - 1 do
    begin
      Node1 := VarTree.Items.AddChild(Node, VariablesList[i]);
      SetImageIndex(Node1, 80);
    end;
  end;

begin
  FUpdating := True;
  CategoriesList := TStringList.Create;
  VariablesList := TStringList.Create;
  FVariables.GetCategoriesList(CategoriesList);

  VarTree.Items.BeginUpdate;
  VarTree.Items.Clear;
  VarTree.Items.AddChild(nil, '');
  SetImageIndex(Root, 66);

  for i := 0 to CategoriesList.Count - 1 do
  begin
    FVariables.GetVariablesList(CategoriesList[i], VariablesList);
    Node := VarTree.Items.AddChild(Root, CategoriesList[i]);
    SetImageIndex(Node, 66);
    AddVariables(Node);
  end;

  if CategoriesList.Count = 0 then
  begin
    FVariables.GetVariablesList('', VariablesList);
    AddVariables(Root);
  end;

  UpdateItem0;
  VarTree.FullExpand;
  VarTree.TopItem := Root;
  VarTree.Items.EndUpdate;
  CategoriesList.Free;
  VariablesList.Free;
  FUpdating := False;
end;

procedure TfrxVarEditorForm.DeleteBClick(Sender: TObject);
var
  Node: TTreeNode;
begin
  Node := VarTree.Selected;
  if (Node = nil) or (Node = Root) then Exit;

  if Node.Parent <> Root then
    FVariables.DeleteVariable(Node.Text) else
    FVariables.DeleteCategory(Node.Text);
  Node.Free;
  UpdateItem0;
end;

procedure TfrxVarEditorForm.NewCategoryBClick(Sender: TObject);
var
  Node: TTreeNode;
  s: String;
begin
  s := ' New Category';
  CreateUniqueName(s);
  Node := VarTree.Items.AddChild(Root, Trim(s));
  SetImageIndex(Node, 66);
  FVariables.Add.Name := s;
  VarTree.FullExpand;
  UpdateItem0;
end;

procedure TfrxVarEditorForm.NewVarBClick(Sender: TObject);
var
  Node: TTreeNode;
  s: String;
begin
  if Root.Count = 0 then Exit;
  Node := VarTree.Selected;
  if (Node = nil) or (Node = Root) then
    Node := VarTree.Items[0][Root.Count - 1]
  else if Node.Parent <> Root then
    Node := Node.Parent;

  s := 'New Variable';
  CreateUniqueName(s);
  FVariables.AddVariable(Node.Text, s, '');

  Node := VarTree.Items.AddChild(Node, s);
  SetImageIndex(Node, 80);

  VarTree.FullExpand;
  UpdateItem0;
end;

procedure TfrxVarEditorForm.EditBClick(Sender: TObject);
var
  Node: TTreeNode;
begin
  Node := VarTree.Selected;
  if (Node = nil) or (Node = Root) then Exit;

  Node.EditText;
end;

procedure TfrxVarEditorForm.VarTreeEdited(Sender: TObject; Node: TTreeNode;
  var S: String);
var
  s1, s2: String;
begin
  if (Node.Text = s) or (Root.Count = 0) then Exit;

  s1 := s;
  s2 := Node.Text;

  if Node.Parent = Root then
  begin
    s1 := ' ' + s1;
    s2 := ' ' + s2;
  end;

  if FVariables.IndexOf(s1) <> -1 then
  begin
    s := Node.Text;
    frxErrorMsg(frxResources.Get('vaDupName'));
  end
  else
    FVariables.Items[FVariables.IndexOf(s2)].Name := s1;
end;

procedure TfrxVarEditorForm.VarTreeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    vk_Insert:
      if not VarTree.IsEditing then
        if Root.Count = 0 then
          NewCategoryBClick(nil) else
          NewVarBClick(nil);
    vk_Delete:
      if not VarTree.IsEditing then
        DeleteBClick(nil);
    vk_Return, vk_F2:
      if not VarTree.IsEditing then
        EditBClick(nil);
  end;
end;

procedure TfrxVarEditorForm.ExprMemoDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := (Source is TTreeView) and (TControl(Source).Owner = FDataTree) and
    (FDataTree.GetFieldName <> '');
end;

procedure TfrxVarEditorForm.ExprMemoDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
  ExprMemo.SelText := FDataTree.GetFieldName;
end;

procedure TfrxVarEditorForm.OnDataTreeDblClick(Sender: TObject);
begin
  ExprMemo.SelText := FDataTree.GetFieldName;
end;

procedure TfrxVarEditorForm.VarTreeChange(Sender: TObject; Node: TTreeNode);
begin
  if FUpdating then Exit;

  if (Node = nil) or (Node = Root) or (Node.Parent = Root) then
    ExprMemo.Text := '' else
    ExprMemo.Text := VarToStr(FVariables[Node.Text]);
  ExprMemo.Modified := False;
end;

procedure TfrxVarEditorForm.VarTreeChanging(Sender: TObject;
  Node: TTreeNode; var AllowChange: Boolean);
begin
  if FUpdating then Exit;
  Node := VarTree.Selected;

  if ExprMemo.Modified then
    if not ((Node = nil) or (Node = Root) or (Node.Parent = Root)) then
       FVariables[Node.Text] := ExprMemo.Text;
end;

procedure TfrxVarEditorForm.EditListBClick(Sender: TObject);

  procedure VarToStrings(Lines: TStrings);
  var
    i: Integer;
    s: String;
  begin
    for i := 0 to FVariables.Count - 1 do
    begin
      s := FVariables.Items[i].Name;
      if s <> '' then
        if s[1] = ' ' then
          s := Copy(s, 2, 255) else
          s := ' ' + s;
      Lines.Add(s);
    end;
  end;

  procedure StringsToVar(Lines: TStrings);
  var
    i: Integer;
    v: TfrxVariables;
    s: String;
  begin
    v := TfrxVariables.Create;
    for i := 0 to Lines.Count - 1 do
    begin
      s := Lines[i];
      if Trim(s) <> '' then
      begin
        if s[1] = ' ' then
          s := Copy(s, 2, 255) else
          s := ' ' + s;
        if FVariables.IndexOf(s) <> -1 then
          v[s] := FVariables[s] else
          v[s] := '';
      end;
    end;

    FVariables.Assign(v);
    FillVariables;
    v.Free;
  end;

begin
  with TfrxStringsEditorForm.Create(Owner) do
  begin
    VarToStrings(Memo.Lines);
    if ShowModal = mrOk then
      StringsToVar(Memo.Lines);
    VarTree.Items[0].Selected := True;
    Free;
  end;
end;

procedure TfrxVarEditorForm.LoadBClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    FVariables.LoadFromFile(OpenDialog1.FileName);
    FillVariables;
  end;
end;

procedure TfrxVarEditorForm.SaveBClick(Sender: TObject);
begin
  VarTree.Selected := VarTree.Items[0];
  if SaveDialog1.Execute then
    FVariables.SaveToFile(SaveDialog1.FileName);
end;

procedure TfrxVarEditorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Shift = [ssCtrl]) and (Key = vk_Return) then
    OkBClick(nil);
  if Key = VK_ESCAPE then
    CancelBClick(nil);
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

procedure TfrxVarEditorForm.Splitter2Moved(Sender: TObject);
begin
  FDataTree.UpdateSize;
end;

end.


//0f31356a91fea3356e5f76cdce90aa7b