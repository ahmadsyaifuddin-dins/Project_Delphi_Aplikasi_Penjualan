
{******************************************}
{                                          }
{             FastReport v4.0              }
{   Enduser DB components design editors   }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxCustomDBEditor;

interface

{$I frx.inc}

implementation

uses
  Windows, Classes, SysUtils, Forms, Controls, frxClass, frxCustomDB,
  frxDsgnIntf, frxEditMD, frxEditAliases, frxEditQueryParams, frxEditSQL,
  frxDBSet, frxRes, frxConnWizard
{$IFDEF Delphi6}
, Variants
{$ENDIF}
{$IFDEF QBUILDER}
, fqbClass
{$ENDIF};

type
  TfrxCustomDatabaseEditor = class(TfrxComponentEditor)
  public
    function Edit: Boolean; override;
    function HasEditor: Boolean; override;
  end;

  TfrxCustomDataSetEditor = class(TfrxComponentEditor)
  public
    function Edit: Boolean; override;
    function HasEditor: Boolean; override;
  end;

  TfrxCustomQueryEditor = class(TfrxComponentEditor)
  public
    function Edit: Boolean; override;
    function HasEditor: Boolean; override;
  end;

  TfrxFieldAliasesProperty = class(TfrxClassProperty)
  public
    function GetAttributes: TfrxPropertyAttributes; override;
    function Edit: Boolean; override;
  end;

  TfrxDataSetProperty = class(TfrxComponentProperty)
  public
    function GetValue: String; override;
    function GetAttributes: TfrxPropertyAttributes; override;
    procedure GetValues; override;
    procedure SetValue(const Value: String); override;
  end;

  TfrxDataFieldProperty = class(TfrxPropertyEditor)
  public
    function GetValue: String; override;
    function GetAttributes: TfrxPropertyAttributes; override;
    procedure GetValues; override;
    procedure SetValue(const Value: String); override;
  end;

  TfrxMasterFieldsProperty = class(TfrxStringProperty)
  public
    function GetAttributes: TfrxPropertyAttributes; override;
    function Edit: Boolean; override;
  end;

  TfrxSQLProperty = class(TfrxClassProperty)
  public
    function GetAttributes: TfrxPropertyAttributes; override;
    function Edit: Boolean; override;
  end;

  TfrxParamsProperty = class(TfrxClassProperty)
  public
    function GetAttributes: TfrxPropertyAttributes; override;
    function Edit: Boolean; override;
  end;


{ TfrxCustomDatabaseEditor }

function TfrxCustomDatabaseEditor.HasEditor: Boolean;
begin
  Result := True;
end;

function TfrxCustomDatabaseEditor.Edit: Boolean;
var
  i: Integer;
  wiz: TfrxCustomWizard;
begin
  Result := False;
  for i := 0 to frxWizards.Count - 1 do
    if frxWizards[i].ClassRef = TfrxDBConnWizard then
    begin
      wiz := TfrxCustomWizard(frxWizards[i].ClassRef.NewInstance);
      wiz.Create(Designer);
      try
        TfrxDBConnWizard(wiz).Database := TfrxCustomDatabase(Component);
        Result := wiz.Execute;
      finally
        wiz.Free;
      end;
      break;
    end;
end;


{ TfrxCustomDataSetEditor }

function TfrxCustomDataSetEditor.Edit: Boolean;
begin
  with TfrxAliasesEditorForm.Create(Application) do
  begin
    DataSet := TfrxCustomDataSet(Component);
    Result := ShowModal = mrOk;
    if Result then
      Self.Designer.UpdateDataTree;
    Free;
  end;
end;

function TfrxCustomDataSetEditor.HasEditor: Boolean;
begin
  Result := True;
end;


{ TfrxCustomQueryEditor }

function TfrxCustomQueryEditor.Edit: Boolean;
begin
  with TfrxSQLEditorForm.Create(Designer) do
  begin
    Query := TfrxCustomQuery(Component);
    Result := ShowModal = mrOk;
    if Result then
      Self.Designer.UpdateDataTree;
    Free;
  end;
end;

function TfrxCustomQueryEditor.HasEditor: Boolean;
begin
  Result := True;
end;


{ TfrxFieldAliasesProperty }

function TfrxFieldAliasesProperty.Edit: Boolean;
begin
  with TfrxAliasesEditorForm.Create(Application) do
  begin
    DataSet := TfrxCustomDataSet(Component);
    Result := ShowModal = mrOk;
    if Result then
      Self.Designer.UpdateDataTree;
    Free;
  end;
end;

function TfrxFieldAliasesProperty.GetAttributes: TfrxPropertyAttributes;
begin
  Result := [paDialog, paReadOnly];
end;


{ TfrxDataSetProperty }

function TfrxDataSetProperty.GetAttributes: TfrxPropertyAttributes;
begin
  Result := [paMultiSelect, paValueList];
end;

function TfrxDataSetProperty.GetValue: String;
var
  ds: TfrxDataSet;
begin
  ds := TfrxDataSet(GetOrdValue);
  if ds <> nil then
    Result := frComponent.Report.GetAlias(ds) else
    Result := frxResources.Get('prNotAssigned');
end;

procedure TfrxDataSetProperty.GetValues;
var
  i: Integer;
begin
  frComponent.Report.GetDataSetList(Values, True);
  if Component is TfrxDataSet then
  begin
    i := Values.IndexOf(TfrxDataSet(Component).UserName);
    if i <> -1 then
      Values.Delete(i);
  end;
end;

procedure TfrxDataSetProperty.SetValue(const Value: String);
var
  ds: TfrxDataSet;
begin
  if Value = '' then
    SetOrdValue(0)
  else
  begin
    ds := frComponent.Report.GetDataSet(Value);
    if ds <> nil then
      SetOrdValue(Integer(ds)) else
      raise Exception.Create(frxResources.Get('prInvProp'));
  end;
end;


{ TfrxDataFieldProperty }

function TfrxDataFieldProperty.GetAttributes: TfrxPropertyAttributes;
begin
  Result := [paMultiSelect, paValueList];
end;

function TfrxDataFieldProperty.GetValue: String;
begin
  Result := GetStrValue;
end;

procedure TfrxDataFieldProperty.SetValue(const Value: String);
begin
  SetStrValue(Value);
end;

procedure TfrxDataFieldProperty.GetValues;
var
  ds: TfrxDataSet;
begin
  inherited;
  ds := TfrxDBLookupComboBox(Component).DataSet;
  if ds <> nil then
    ds.GetFieldList(Values);
end;


{ TfrxMasterFieldsProperty }

function TfrxMasterFieldsProperty.Edit: Boolean;
var
  ds: TfrxCustomDataSet;
begin
  Result := False;
  ds := TfrxCustomDataSet(Component);
  if ds.Master <> nil then
    with TfrxMDEditorForm.Create(Application) do
    begin
      DataSet := ds;
      Result := ShowModal = mrOk;
      Free;
    end;
end;

function TfrxMasterFieldsProperty.GetAttributes: TfrxPropertyAttributes;
begin
  Result := [paDialog, paReadOnly];
end;


{ TfrxSQLProperty }

function TfrxSQLProperty.Edit: Boolean;
begin
  with TfrxSQLEditorForm.Create(Designer) do
  begin
    Query := TfrxCustomQuery(Component);
    Result := ShowModal = mrOk;
    if Result then
      Self.Designer.UpdateDataTree;
    Free;
  end;
end;

function TfrxSQLProperty.GetAttributes: TfrxPropertyAttributes;
begin
  Result := [paDialog, paReadOnly];
end;


{ TfrxParamsProperty }

function TfrxParamsProperty.Edit: Boolean;
var
  q: TfrxCustomQuery;
begin
  Result := False;
  q := TfrxCustomQuery(Component);
  if q.Params.Count <> 0 then
    with TfrxParamsEditorForm.Create(Designer) do
    begin
      Params := q.Params;
      Result := ShowModal = mrOk;
      if Result then
      begin
        q.UpdateParams;
        Self.Designer.UpdateDataTree;
      end;
      Free;
    end;
end;

function TfrxParamsProperty.GetAttributes: TfrxPropertyAttributes;
begin
  Result := [paDialog, paReadOnly];
end;


initialization
  frxComponentEditors.Register(TfrxCustomDatabase, TfrxCustomDatabaseEditor);
  frxComponentEditors.Register(TfrxCustomDataSet, TfrxCustomDataSetEditor);
  frxComponentEditors.Register(TfrxCustomQuery, TfrxCustomQueryEditor);
  frxPropertyEditors.Register(TypeInfo(TStrings), TfrxCustomDataSet, 'FieldAliases',
    TfrxFieldAliasesProperty);
  frxPropertyEditors.Register(TypeInfo(TfrxCustomDBDataSet), TfrxCustomDataSet,
    'Master', TfrxDataSetProperty);
  frxPropertyEditors.Register(TypeInfo(String), TfrxCustomDataSet, 'MasterFields',
    TfrxMasterFieldsProperty);
  frxPropertyEditors.Register(TypeInfo(TStrings), TfrxCustomQuery, 'SQL',
    TfrxSQLProperty);
  frxPropertyEditors.Register(TypeInfo(TfrxParams), TfrxCustomQuery, 'Params',
    TfrxParamsProperty);
  frxPropertyEditors.Register(TypeInfo(TfrxDBDataSet), TfrxDBLookupComboBox,
    'DataSet', TfrxDataSetProperty);
  frxPropertyEditors.Register(TypeInfo(String), TfrxDBLookupComboBox,
    'KeyField', TfrxDataFieldProperty);
  frxPropertyEditors.Register(TypeInfo(String), TfrxDBLookupComboBox,
    'ListField', TfrxDataFieldProperty);
  frxHideProperties(TfrxCustomDataset, 'DataSet;DataSource;Enabled;OpenDataSource;Tag');
  frxHideProperties(TfrxCustomQuery, 'SQLSchema');
  frxHideProperties(TfrxDBLookupComboBox, 'DataSetName');

end.


//0f31356a91fea3356e5f76cdce90aa7b