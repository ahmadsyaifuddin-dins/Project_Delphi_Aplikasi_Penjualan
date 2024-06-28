
{******************************************}
{                                          }
{             FastReport v4.0              }
{      Custom TDataSet-based classes       }
{        for enduser DB components         }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxCustomDB;

interface

{$I frx.inc}

uses
  Windows, Classes, SysUtils, DB, frxClass, frxDBSet, DBCtrls
{$IFDEF Delphi6}
, Variants
{$ENDIF}
{$IFDEF QBUILDER}
, fqbClass
{$ENDIF}
;


type
  TfrxCustomDataset = class(TfrxDBDataSet)
  private
    FDBConnected: Boolean;
    FDataSource: TDataSource;
    FMaster: TfrxDBDataSet;
    FMasterFields: String;
    procedure SetActive(Value: Boolean);
    procedure SetFilter(const Value: String);
    procedure SetFiltered(Value: Boolean);
    function GetActive: Boolean;
    function GetFields: TFields;
    function GetFilter: String;
    function GetFiltered: Boolean;
    procedure InternalSetMaster(const Value: TfrxDBDataSet);
    procedure InternalSetMasterFields(const Value: String);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetParent(AParent: TfrxComponent); override;
    procedure SetUserName(const Value: String); override;
    procedure SetMaster(const Value: TDataSource); virtual;
    procedure SetMasterFields(const Value: String); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure OnPaste; override;
    property DBConnected: Boolean read FDBConnected write FDBConnected;
    property Fields: TFields read GetFields;
    property MasterFields: String read FMasterFields write InternalSetMasterFields;
    property Active: Boolean read GetActive write SetActive default False;
  published
    property Filter: String read GetFilter write SetFilter;
    property Filtered: Boolean read GetFiltered write SetFiltered default False;
    property Master: TfrxDBDataSet read FMaster write InternalSetMaster;
  end;

  TfrxCustomTable = class(TfrxCustomDataset)
  protected
    function GetIndexFieldNames: String; virtual;
    function GetIndexName: String; virtual;
    function GetTableName: String; virtual;
    procedure SetIndexFieldNames(const Value: String); virtual;
    procedure SetIndexName(const Value: String); virtual;
    procedure SetTableName(const Value: String); virtual;
  published
    property MasterFields;
    property TableName: String read GetTableName write SetTableName;
    property IndexName: String read GetIndexName write SetIndexName;
    property IndexFieldNames: String read GetIndexFieldNames write SetIndexFieldNames;
  end;


  TfrxParamItem = class(TCollectionItem)
  private

    FDataType: TFieldType;
    FExpression: String;
    FName: String;
    FValue: Variant;

  public
    procedure Assign(Source: TPersistent); override;
    property Value: Variant read FValue write FValue;
  published
    property Name: String read FName write FName;
    property DataType: TFieldType read FDataType write FDataType;
    property Expression: String read FExpression write FExpression;
  end;

  TfrxParams = class(TCollection)
  private
    function GetParam(Index: Integer): TfrxParamItem;
  public
    constructor Create;
    function Add: TfrxParamItem;
    function Find(const Name: String): TfrxParamItem;
    function IndexOf(const Name: String): Integer;
    procedure UpdateParams(const SQL: String);
    property Items[Index: Integer]: TfrxParamItem read GetParam; default;
  end;

  TfrxCustomQuery = class(TfrxCustomDataset)
  private
    FParams: TfrxParams;
    FSaveOnBeforeOpen: TDataSetNotifyEvent;
    FSaveOnChange: TNotifyEvent;
    FSQLSchema: String;
    procedure ReadData(Reader: TReader);
    procedure SetParams(Value: TfrxParams);
    procedure WriteData(Writer: TWriter);
  protected
    procedure DefineProperties(Filer: TFiler); override;
    procedure OnBeforeOpen(DataSet: TDataSet); virtual;
    procedure OnChangeSQL(Sender: TObject); virtual;
    procedure SetSQL(Value: TStrings); virtual;
    function GetSQL: TStrings; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure UpdateParams; virtual;
    function ParamByName(const Value: String): TfrxParamItem;
{$IFDEF QBUILDER}
    function QBEngine: TfqbEngine; virtual;
{$ENDIF}
  published
    property Params: TfrxParams read FParams write SetParams;
    property SQL: TStrings read GetSQL write SetSQL;
    property SQLSchema: String read FSQLSchema write FSQLSchema;
  end;

  TfrxDBLookupComboBox = class(TfrxDialogControl)
  private
    FDataSet: TfrxDBDataSet;
    FDataSetName: String;
    FDataSource: TDataSource;
    FDBLookupComboBox: TDBLookupComboBox;
    function GetDataSetName: String;
    function GetKeyField: String;
    function GetKeyValue: Variant;
    function GetListField: String;
    function GetText: String;
    procedure SetDataSet(const Value: TfrxDBDataSet);
    procedure SetDataSetName(const Value: String);
    procedure SetKeyField(Value: String);
    procedure SetKeyValue(const Value: Variant);
    procedure SetListField(Value: String);
    procedure UpdateDataSet;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class function GetDescription: String; override;
    procedure BeforeStartReport; override;
    property DBLookupComboBox: TDBLookupComboBox read FDBLookupComboBox;
    property KeyValue: Variant read GetKeyValue write SetKeyValue;
    property Text: String read GetText;
  published
    property ListField: String read GetListField write SetListField;
    property DataSet: TfrxDBDataSet read FDataSet write SetDataSet;
    property DataSetName: String read GetDataSetName write SetDataSetName;
    property KeyField: String read GetKeyField write SetKeyField;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;


procedure frxParamsToTParams(Query: TfrxCustomQuery; Params: TParams);


implementation

uses
{$IFNDEF NO_EDITORS}
  frxCustomDBEditor,
{$ENDIF}
  frxCustomDBRTTI, frxDsgnIntf, frxUtils, frxRes;


{ TfrxParamItem }

procedure TfrxParamItem.Assign(Source: TPersistent);
begin
  if Source is TfrxParamItem then
  begin
    FName := TfrxParamItem(Source).Name;
    FDataType := TfrxParamItem(Source).DataType;
    FExpression := TfrxParamItem(Source).Expression;
    FValue := TfrxParamItem(Source).Value;
  end;
end;



{ TfrxParams }

constructor TfrxParams.Create;
begin
  inherited Create(TfrxParamItem);
end;

function TfrxParams.Add: TfrxParamItem;
begin
  Result := TfrxParamItem(inherited Add);
end;

function TfrxParams.GetParam(Index: Integer): TfrxParamItem;
begin
  Result := TfrxParamItem(inherited Items[Index]);
end;

function TfrxParams.Find(const Name: String): TfrxParamItem;
var
  i: Integer;
begin
  i := IndexOf(Name);
  if i <> -1 then
    Result := Items[i] else
    Result := nil;
end;

function TfrxParams.IndexOf(const Name: String): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Count - 1 do
    if CompareText(Items[i].Name, Name) = 0 then
    begin
      Result := i;
      break;
    end;
end;

procedure TfrxParams.UpdateParams(const SQL: String);
var
  i, j: Integer;
  QParams: TParams;
  NewParams: TfrxParams;
begin
  { parse query params }
  QParams := TParams.Create;
  QParams.ParseSQL(SQL, True);

  { create new TfrxParams object and copy all params to it }
  NewParams := TfrxParams.Create;
  for i := 0 to QParams.Count - 1 do
    with NewParams.Add do
    begin
      Name := QParams[i].Name;
      j := IndexOf(Name);
      if j <> -1 then
      begin
        DataType := Items[j].DataType;
        Value := Items[j].Value;
        Expression := Items[j].Expression;
      end;
    end;

  Assign(NewParams);
  QParams.Free;
  NewParams.Free;
end;


{ TfrxCustomDataset }

constructor TfrxCustomDataset.Create(AOwner: TComponent);
begin
  Component := Dataset;
  inherited;
  CloseDataSource := True;
  FDataSource := TDataSource.Create(nil);
  SetMaster(FDataSource);
end;

destructor TfrxCustomDataset.Destroy;
begin
  FDataSource.Free;
  inherited;
end;

procedure TfrxCustomDataset.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if Operation = opRemove then
    if AComponent = FMaster then
      Master := nil
end;

procedure TfrxCustomDataset.SetParent(AParent: TfrxComponent);
begin
  inherited;
  if (AParent <> nil) and (Report <> nil) then
  begin
    if IsDesigning and (Report.DataSets.Find(Self) = nil) then
    begin
      Report.DataSets.Add(Self);
      if Report.Designer <> nil then
        Report.Designer.UpdateDataTree;
    end;
  end;
end;

procedure TfrxCustomDataset.SetUserName(const Value: String);
begin
  inherited;
  if (Report <> nil) and (Report.Designer <> nil) then
    Report.Designer.UpdateDataTree;
end;

procedure TfrxCustomDataset.OnPaste;
var
  i: Integer;
  sl: TStringList;
begin
  if Report.DataSets.Find(Self) = nil then
    Report.DataSets.Add(Self);

  sl := TStringList.Create;
  if Report <> nil then
    Report.GetDatasetList(sl);
  for i := 0 to sl.Count - 1 do
    if (sl.Objects[i] <> Self) and (CompareText(sl[i], UserName) = 0) then
    begin
      if Name <> '' then
        UserName := Name;
      break;
    end;
  sl.Free;

  Report.Designer.UpdateDataTree;
end;

procedure TfrxCustomDataset.SetActive(Value: Boolean);
begin
  Dataset.Active := Value;
end;

procedure TfrxCustomDataset.SetFilter(const Value: String);
begin
  Dataset.Filter := Value;
end;

function TfrxCustomDataset.GetActive: Boolean;
begin
  Result := Dataset.Active;
end;

function TfrxCustomDataset.GetFields: TFields;
begin
  Result := Dataset.Fields;
end;

function TfrxCustomDataset.GetFilter: String;
begin
  Result := Dataset.Filter;
end;

function TfrxCustomDataset.GetFiltered: Boolean;
begin
  Result := Dataset.Filtered;
end;

procedure TfrxCustomDataset.SetFiltered(Value: Boolean);
begin
  Dataset.Filtered := Value;
end;

procedure TfrxCustomDataset.InternalSetMaster(const Value: TfrxDBDataSet);
begin
  FMaster := Value;
  if FMaster <> nil then
    FDataSource.DataSet := FMaster.GetDataSet
  else
    FDataSource.DataSet := nil;
end;

procedure TfrxCustomDataset.InternalSetMasterFields(const Value: String);
var
  sl: TStringList;
  s: String;
  i: Integer;

  function ConvertAlias(const s: String): String;
  begin
    if FMaster <> nil then
      Result := FMaster.ConvertAlias(s)
    else
      Result := s;
  end;

begin
  FMasterFields := Value;

  sl := TStringList.Create;
  frxSetCommaText(Value, sl);
  s := '';
  for i := 0 to sl.Count - 1 do
    s := s + ConvertAlias(sl.Values[sl.Names[i]]) + ';';
  s := Copy(s, 1, Length(s) - 1);

  SetMasterFields(s);

  s := '';
  for i := 0 to sl.Count - 1 do
    s := s + ConvertAlias(sl.Names[i]) + ';';
  s := Copy(s, 1, Length(s) - 1);

  if Self is TfrxCustomTable then
    TfrxCustomTable(Self).SetIndexFieldNames(s);

  sl.Free;
end;

procedure TfrxCustomDataset.SetMaster(const Value: TDataSource);
begin
// do nothing
end;

procedure TfrxCustomDataset.SetMasterFields(const Value: String);
begin
// do nothing
end;


{ TfrxCustomTable }

function TfrxCustomTable.GetIndexFieldNames: String;
begin
  Result := '';
end;

function TfrxCustomTable.GetIndexName: String;
begin
  Result := '';
end;

function TfrxCustomTable.GetTableName: String;
begin
  Result := '';
end;

procedure TfrxCustomTable.SetIndexFieldNames(const Value: String);
begin
// do nothing
end;

procedure TfrxCustomTable.SetIndexName(const Value: String);
begin
// do nothing
end;

procedure TfrxCustomTable.SetTableName(const Value: String);
begin
// do nothing
end;


{ TfrxCustomQuery }

constructor TfrxCustomQuery.Create(AOwner: TComponent);
begin
  inherited;
  FParams := TfrxParams.Create;
  FSaveOnBeforeOpen := DataSet.BeforeOpen;
  DataSet.BeforeOpen := OnBeforeOpen;
  FSaveOnChange := TStringList(SQL).OnChange;
  TStringList(SQL).OnChange := OnChangeSQL;
end;

destructor TfrxCustomQuery.Destroy;
begin
  FParams.Free;
  inherited;
end;

procedure TfrxCustomQuery.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineProperty('Parameters', ReadData, WriteData, True);
end;

procedure TfrxCustomQuery.ReadData(Reader: TReader);
begin
  frxReadCollection(FParams, Reader, Self);
  UpdateParams;
end;

procedure TfrxCustomQuery.WriteData(Writer: TWriter);
begin
  frxWriteCollection(FParams, Writer, Self);
end;

procedure TfrxCustomQuery.OnBeforeOpen(DataSet: TDataSet);
begin
  UpdateParams;
  if Assigned(FSaveOnBeforeOpen) then
    FSaveOnBeforeOpen(DataSet);
end;

procedure TfrxCustomQuery.OnChangeSQL(Sender: TObject);
begin
  if Assigned(FSaveOnChange) then
    FSaveOnChange(Sender);
  FParams.UpdateParams(SQL.Text);
end;

procedure TfrxCustomQuery.SetParams(Value: TfrxParams);
begin
  FParams.Assign(Value);
end;

function TfrxCustomQuery.ParamByName(const Value: String): TfrxParamItem;
begin
  Result := FParams.Find(Value);
  if Result = nil then
    raise Exception.Create('Parameter "' + Value + '" not found'); 
end;

procedure TfrxCustomQuery.SetSQL(Value: TStrings);
begin
//
end;

function TfrxCustomQuery.GetSQL: TStrings;
begin
  Result := nil;
end;

procedure TfrxCustomQuery.UpdateParams;
begin
//
end;

{$IFDEF QBUILDER}
function TfrxCustomQuery.QBEngine: TfqbEngine;
begin
  Result := nil;
end;
{$ENDIF}


{ frxParamsToTParams }

procedure frxParamsToTParams(Query: TfrxCustomQuery; Params: TParams);
var
  i: Integer;
  Item: TfrxParamItem;
begin
  for i := 0 to Params.Count - 1 do
    if Query.Params.IndexOf(Params[i].Name) <> -1 then
    begin
      Item := Query.Params[Query.Params.IndexOf(Params[i].Name)];
      Params[i].Clear;
      { Bound should be True in design mode }
      if not (Query.IsLoading or Query.IsDesigning) then
        Params[i].Bound := False
      else
        Params[i].Bound := True;
      Params[i].DataType := Item.DataType;
      if Trim(Item.Expression) <> '' then
        if not (Query.IsLoading or Query.IsDesigning) then
          if Query.Report <> nil then
          begin
            Query.Report.CurObject := Query.Name;
            Item.Value := Query.Report.Calc(Item.Expression);
          end;
      if not VarIsEmpty(Item.Value) then
      begin
        Params[i].Bound := True;
        if Params[i].DataType in [ftDate, ftTime, ftDateTime] then
          Params[i].Value := Item.Value
        else
          Params[i].Text := VarToStr(Item.Value);
      end;
    end;
end;


{ TfrxDBLookupComboBox }

constructor TfrxDBLookupComboBox.Create(AOwner: TComponent);
begin
  inherited;
  FDBLookupComboBox := TDBLookupComboBox.Create(nil);
  InitControl(FDBLookupComboBox);
  Width := 145;
  Height := 21;
  FDataSource := TDataSource.Create(nil);
  FDBLookupComboBox.ListSource := FDataSource;
end;

destructor TfrxDBLookupComboBox.Destroy;
begin
  FDataSource.Free;
  inherited;
end;

class function TfrxDBLookupComboBox.GetDescription: String;
begin
  Result := frxResources.Get('obDBLookup');
end;

function TfrxDBLookupComboBox.GetDataSetName: String;
begin
  if FDataSet = nil then
    Result := FDataSetName else
    Result := FDataSet.UserName;
end;

function TfrxDBLookupComboBox.GetKeyField: String;
begin
  Result := FDBLookupComboBox.KeyField;
  if FDataSet <> nil then
    Result := FDataSet.GetAlias(Result);
end;

function TfrxDBLookupComboBox.GetKeyValue: Variant;
begin
  Result := FDBLookupComboBox.KeyValue;
end;

function TfrxDBLookupComboBox.GetListField: String;
begin
  Result := FDBLookupComboBox.ListField;
  if FDataSet <> nil then
    Result := FDataSet.GetAlias(Result);
end;

function TfrxDBLookupComboBox.GetText: String;
begin
  Result := FDBLookupComboBox.Text;
end;

procedure TfrxDBLookupComboBox.SetDataSet(const Value: TfrxDBDataSet);
begin
  FDataSet := Value;
  if FDataSet = nil then
    FDataSetName := '' else
    FDataSetName := FDataSet.UserName;
  UpdateDataSet;
end;

procedure TfrxDBLookupComboBox.SetDataSetName(const Value: String);
begin
  FDataSetName := Value;
  FDataSet := TfrxDBDataSet(frxFindDataSet(FDataSet, FDataSetName, Report));
  UpdateDataSet;
end;

procedure TfrxDBLookupComboBox.SetKeyField(Value: String);
begin
  if FDataSet <> nil then
    Value := FDataSet.ConvertAlias(Value);
  FDBLookupComboBox.KeyField := Value;
end;

procedure TfrxDBLookupComboBox.SetKeyValue(const Value: Variant);
begin
  FDBLookupComboBox.KeyValue := Value;
end;

procedure TfrxDBLookupComboBox.SetListField(Value: String);
begin
  if FDataSet <> nil then
    Value := FDataSet.ConvertAlias(Value);
  FDBLookupComboBox.ListField := Value;
end;

procedure TfrxDBLookupComboBox.UpdateDataSet;
begin
  if FDataSet <> nil then
    FDataSource.DataSet := FDataSet.GetDataSet else
    FDataSource.DataSet := nil;
end;

procedure TfrxDBLookupComboBox.BeforeStartReport;
begin
  SetListField(FDBLookupComboBox.ListField);
  SetKeyField(FDBLookupComboBox.KeyField);
end;


initialization
  frxObjects.RegisterObject1(TfrxDBLookupComboBox, nil, '', '', 0, 41);


end.


//0f31356a91fea3356e5f76cdce90aa7b