
{******************************************}
{                                          }
{             FastReport v4.0              }
{           DB Connection wizard           }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxConnWizard;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Buttons, StdCtrls, ComCtrls, ToolWin,
  frxClass, frxSynMemo, frxCustomDB
{$IFDEF Delphi6}
, Variants
{$ENDIF}
{$IFDEF QBUILDER}
, fqbClass
{$ENDIF};

type
  TfrxDBConnWizard = class(TfrxCustomWizard)
  private
    FDatabase: TfrxCustomDatabase;
  public
    class function GetDescription: String; override;
    function Execute: Boolean; override;
    property Database: TfrxCustomDatabase read FDatabase write FDatabase;
  end;

  TfrxDBTableWizard = class(TfrxCustomWizard)
  public
    class function GetDescription: String; override;
    function Execute: Boolean; override;
  end;

  TfrxDBQueryWizard = class(TfrxCustomWizard)
  public
    class function GetDescription: String; override;
    function Execute: Boolean; override;
  end;

  TfrxConnectionWizardForm = class(TForm)
    OKB: TButton;
    CancelB: TButton;
    PageControl1: TPageControl;
    ConnTS: TTabSheet;
    TableTS: TTabSheet;
    ConnL1: TLabel;
    DBL: TLabel;
    LoginL: TLabel;
    PasswordL: TLabel;
    ChooseB: TSpeedButton;
    ConnCB: TComboBox;
    DatabaseE: TEdit;
    LoginE: TEdit;
    PasswordE: TEdit;
    PromptRB: TRadioButton;
    LoginRB: TRadioButton;
    ConnL2: TLabel;
    ConnCB1: TComboBox;
    TableL: TLabel;
    TableCB: TComboBox;
    FilterCB: TCheckBox;
    FilterE: TEdit;
    QueryTS: TTabSheet;
    ConnL3: TLabel;
    ConnCB2: TComboBox;
    QueryL: TLabel;
    ToolBar1: TToolBar;
    BuildSQLB: TToolButton;
    ParamsB: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure ChooseBClick(Sender: TObject);
    procedure ConnCBClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ConnCB1Click(Sender: TObject);
    procedure ConnCB2Click(Sender: TObject);
    procedure BuildSQLBClick(Sender: TObject);
    procedure ParamsBClick(Sender: TObject);
    procedure OKBClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FComponent: TfrxComponent;
    FDatabase: TfrxCustomDatabase;
    FDesigner: TfrxCustomDesigner;
    FItem: Integer;
    FItemIndex: Integer;
    FMemo: TfrxSyntaxMemo;
    FOldItem: Integer;
    FPage: TfrxPage;
    FQuery: TfrxCustomQuery;
    FReport: TfrxReport;
    FTable: TfrxCustomTable;
  public
    { Public declarations }
  end;


implementation

{$R *.DFM}
{$R *.RES}

uses frxUtils, frxDsgnIntf, frxRes, frxEditQueryParams;

const
  dbiConnection = 0;
  dbiTable = 1;
  dbiQuery = 2;


{ TfrxDBConnWizard }

class function TfrxDBConnWizard.GetDescription: String;
begin
  Result := frxResources.Get('wzDBConn');
end;

function TfrxDBConnWizard.Execute: Boolean;
begin
  with TfrxConnectionWizardForm.Create(Owner) do
  begin
    FDesigner := Self.Designer;
    FReport := Report;
    FItem := dbiConnection;
    FDatabase := Self.FDatabase;
    Result := ShowModal = mrOk;
    Free;
  end;
end;


{ TfrxDBTableWizard }

class function TfrxDBTableWizard.GetDescription: String;
begin
  Result := frxResources.Get('wzDBTable');
end;

function TfrxDBTableWizard.Execute: Boolean;
begin
  with TfrxConnectionWizardForm.Create(Owner) do
  begin
    FDesigner := Self.Designer;
    FReport := Report;
    FItem := dbiTable;
    Result := ShowModal = mrOk;
    Free;
  end;
end;


{ TfrxDBQueryWizard }

class function TfrxDBQueryWizard.GetDescription: String;
begin
  Result := frxResources.Get('wzDBQuery');
end;

function TfrxDBQueryWizard.Execute: Boolean;
begin
  with TfrxConnectionWizardForm.Create(Owner) do
  begin
    FDesigner := Self.Designer;
    FReport := Report;
    FItem := dbiQuery;
    Result := ShowModal = mrOk;
    Free;
  end;
end;


{ TfrxConnectionWizardForm }

procedure TfrxConnectionWizardForm.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  Caption := frxGet(5700);
  OKB.Caption := frxGet(1);
  CancelB.Caption := frxGet(2);
  ConnTS.Caption := frxGet(5701);
  ConnL1.Caption := frxGet(5702);
  ConnL2.Caption := ConnL1.Caption;
  ConnL3.Caption := ConnL1.Caption;
  DBL.Caption := frxGet(5703);
  LoginL.Caption := frxGet(5704);
  PasswordL.Caption := frxGet(5705);
  PromptRB.Caption := frxGet(5706);
  LoginRB.Caption := frxGet(5707);
  TableTS.Caption := frxGet(5708);
  TableL.Caption := frxGet(5709);
  FilterCB.Caption := frxGet(5710);
  QueryTS.Caption := frxGet(5711);
  QueryL.Caption := frxGet(5712);
  BuildSQLB.Hint := frxGet(5713);
  ParamsB.Hint := frxGet(5714);

  Toolbar1.Images := frxResources.MainButtonImages;
  FOldItem := dbiConnection;
  FMemo := TfrxSyntaxMemo.Create(Self);
  with FMemo do
  begin
    Parent := QueryTS;
    SetBounds(16, 80, 265, 153);
    Syntax := 'SQL';
    ShowGutter := False;
    Color := clWindow;
    BevelKind := bkFlat;
{$I frxEditSQL.inc}
  end;

{$IFNDEF QBUILDER}
  BuildSQLB.Visible := False;
{$ENDIF}

  ConnCB1.Items.Add(frxResources.Get('prNotAssigned'));
  ConnCB2.Items.Add(frxResources.Get('prNotAssigned'));
  for i := 0 to frxObjects.Count - 1 do
    if frxObjects[i].ClassRef <> nil then
      if frxObjects[i].ClassRef.InheritsFrom(TfrxCustomDatabase) then
        ConnCB.Items.AddObject(frxObjects[i].ClassRef.GetDescription, Pointer(i))
      else if frxObjects[i].ClassRef.InheritsFrom(TfrxCustomTable) then
        ConnCB1.Items.AddObject(frxObjects[i].ClassRef.GetDescription, Pointer(i))
      else if frxObjects[i].ClassRef.InheritsFrom(TfrxCustomQuery) then
        ConnCB2.Items.AddObject(frxObjects[i].ClassRef.GetDescription, Pointer(i));
end;

procedure TfrxConnectionWizardForm.FormShow(Sender: TObject);
var
  i: Integer;
begin
  FPage := FReport.Pages[0];

  if FItem = dbiConnection then
  begin
    PageControl1.ActivePage := ConnTS;
    ConnTS.TabVisible := True;
    TableTS.TabVisible := False;
    QueryTS.TabVisible := False;
    if FDatabase <> nil then
    begin
      for i := 0 to ConnCB.Items.Count - 1 do
        if frxObjects[Integer(ConnCB.Items.Objects[i])].ClassRef = FDatabase.ClassType then
        begin
          ConnCB.ItemIndex := i;
          break;
        end;
      ConnCB.Enabled := False;
      DatabaseE.Text := FDatabase.DatabaseName;
    end
    else
    begin
      if ConnCB.Items.Count > 1 then
        ConnCB.ItemIndex := 1
      else
        ConnCB.ItemIndex := 0;
      ConnCBClick(nil);
    end;
  end
  else if FItem = dbiTable then
  begin
    PageControl1.ActivePage := TableTS;
    ConnTS.TabVisible := False;
    TableTS.TabVisible := True;
    QueryTS.TabVisible := False;
    if FItemIndex <> 0 then
      ConnCB1.ItemIndex := FItemIndex
    else if ConnCB1.Items.Count > 1 then
      ConnCB1.ItemIndex := 1
    else
      ConnCB1.ItemIndex := 0;
    ConnCB1Click(nil);
  end
  else if FItem = dbiQuery then
  begin
    PageControl1.ActivePage := QueryTS;
    ConnTS.TabVisible := False;
    TableTS.TabVisible := False;
    QueryTS.TabVisible := True;
    if FItemIndex <> 0 then
      ConnCB2.ItemIndex := FItemIndex
    else if ConnCB2.Items.Count > 1 then
      ConnCB2.ItemIndex := 1
    else
      ConnCB2.ItemIndex := 0;
    ConnCB2Click(nil);
  end;
end;

procedure TfrxConnectionWizardForm.FormHide(Sender: TObject);
begin
  if FItem = dbiConnection then
  begin
    FComponent := FDatabase;
    if ConnCB.Enabled = False then
      FComponent := nil;
  end
  else if FItem = dbiTable then
    FComponent := FTable
  else if FItem = dbiQuery then
    FComponent := FQuery;

  if FComponent <> nil then
    if ModalResult = mrCancel then
      FComponent.Free
    else
    begin
      FComponent.CreateUniqueName;
      FDesigner.ReloadReport;
    end;
end;

procedure TfrxConnectionWizardForm.OKBClick(Sender: TObject);
begin
  if FItem = dbiConnection then
  begin
    if FDatabase = nil then Exit;
    FDatabase.DatabaseName := DatabaseE.Text;
    if PromptRB.Checked then
      FDatabase.LoginPrompt := True
    else
    begin
      FDatabase.LoginPrompt := False;
      FDatabase.SetLogin(LoginE.Text, PasswordE.Text);
    end;
    FComponent := FDatabase;
  end
  else if FItem = dbiTable then
  begin
    if FTable = nil then Exit;
    FTable.TableName := TableCB.Text;
    FTable.Filter := FilterE.Text;
    FTable.Filtered := FilterCB.Checked;
    FComponent := FTable;
  end
  else if FItem = dbiQuery then
  begin
    if FQuery = nil then Exit;
    FQuery.SQL.Assign(FMemo.Lines);
    FComponent := FQuery;
  end;

  if FOldItem <> dbiConnection then
  begin
    FComponent.CreateUniqueName;
    FItem := FOldItem;
    FOldItem := dbiConnection;
    ModalResult := mrNone;
    FormShow(nil);
  end;
end;

procedure TfrxConnectionWizardForm.ConnCBClick(Sender: TObject);
var
  ClassRef: TClass;
begin
  if FDatabase <> nil then
  begin
    FDatabase.Free;
    FDatabase := nil;
  end;
  ClassRef := frxObjects[Integer(ConnCB.Items.Objects[ConnCB.ItemIndex])].ClassRef;
  FDatabase := TfrxCustomDatabase(ClassRef.NewInstance);
  FDatabase.Create(FPage);
  FDatabase.SetBounds((FPage.Objects.Count - 1) * 100 + 30, 20, 32, 32);
end;

procedure TfrxConnectionWizardForm.ConnCB1Click(Sender: TObject);
var
  i: Integer;
  ClassRef: TClass;
  propList: TfrxPropertyList;
begin
  if FTable <> nil then
  begin
    FTable.Free;
    FTable := nil;
  end;
  if ConnCB1.ItemIndex = 0 then Exit;

  ClassRef := frxObjects[Integer(ConnCB1.Items.Objects[ConnCB1.ItemIndex])].ClassRef;
  FTable := TfrxCustomTable(ClassRef.NewInstance);
  FTable.DesignCreate(FPage, 0);
  FTable.SetBounds((FPage.Objects.Count - 1) * 100 + 30, 20, 32, 32);

  propList := TfrxPropertyList.Create(nil);
  propList.Component := FTable;
  for i := 0 to propList.Count - 1 do
    if propList[i].Editor.GetName = 'TableName' then
    begin
      propList[i].Editor.GetValues;
      TableCB.Items := propList[i].Editor.Values;
    end;
  propList.Free;

  if not FTable.DBConnected then
  begin
    FTable.Free;
    FTable := nil;
    FOldItem := FItem;
    FItem := dbiConnection;
    FItemIndex := ConnCB1.ItemIndex;
    FormShow(nil);
  end;
end;

procedure TfrxConnectionWizardForm.ConnCB2Click(Sender: TObject);
var
  ClassRef: TClass;
begin
  if FQuery <> nil then
  begin
    FQuery.Free;
    FQuery := nil;
  end;
  if ConnCB2.ItemIndex = 0 then Exit;

  ClassRef := frxObjects[Integer(ConnCB2.Items.Objects[ConnCB2.ItemIndex])].ClassRef;
  FQuery := TfrxCustomQuery(ClassRef.NewInstance);
  FQuery.DesignCreate(FPage, 0);
  FQuery.SetBounds((FPage.Objects.Count - 1) * 100 + 30, 20, 32, 32);

  if not FQuery.DBConnected then
  begin
    FQuery.Free;
    FQuery := nil;
    FOldItem := FItem;
    FItem := dbiConnection;
    FItemIndex := ConnCB2.ItemIndex;
    FormShow(nil);
  end;
end;

procedure TfrxConnectionWizardForm.ChooseBClick(Sender: TObject);
var
  i: Integer;
  propList: TfrxPropertyList;
begin
  propList := TfrxPropertyList.Create(nil);
  propList.Component := FDatabase;
  for i := 0 to propList.Count - 1 do
    if (CompareText(propList[i].Editor.GetName, 'DatabaseName') = 0) or
      (CompareText(propList[i].Editor.GetName, 'ConnectionName') = 0) then
    begin
      propList[i].Editor.Edit;
      DatabaseE.Text := FDatabase.DatabaseName;
      break;
    end;
  propList.Free;

  DatabaseE.SetFocus;
end;

procedure TfrxConnectionWizardForm.BuildSQLBClick(Sender: TObject);
{$IFDEF QBUILDER}
var
  fqbDialog: TfqbDialog;
{$ENDIF}
begin
{$IFDEF QBUILDER}
  if FQuery = nil then Exit;
  fqbDialog := TfqbDialog.Create(nil);
  try
    fqbDialog.Engine := FQuery.QBEngine;
    fqbDialog.SchemaInsideSQL := False;
    fqbDialog.SQL := FMemo.Lines.Text;
    fqbDialog.SQLSchema := FQuery.SQLSchema;

    if fqbDialog.Execute then
    begin
      FMemo.Lines.Text := fqbDialog.SQL;
      FQuery.SQLSchema := fqbDialog.SQLSchema;
    end;
  finally
    fqbDialog.Free;
  end;
{$ENDIF}
end;

procedure TfrxConnectionWizardForm.ParamsBClick(Sender: TObject);
begin
  if FQuery <> nil then
  begin
    FQuery.SQL.Assign(FMemo.Lines);
    if FQuery.Params.Count <> 0 then
      with TfrxParamsEditorForm.Create(FDesigner) do
      begin
        Params := FQuery.Params;
        if ShowModal = mrOk then
          FQuery.UpdateParams;
        Free;
      end;
  end;
end;

procedure TfrxConnectionWizardForm.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;


initialization
  frxWizards.Register1(TfrxDBConnWizard, 2);
  frxWizards.Register1(TfrxDBTableWizard, 3);
  frxWizards.Register1(TfrxDBQueryWizard, 4);

finalization
  frxWizards.Unregister(TfrxDBConnWizard);
  frxWizards.Unregister(TfrxDBTableWizard);
  frxWizards.Unregister(TfrxDBQueryWizard);

end.


//0f31356a91fea3356e5f76cdce90aa7b