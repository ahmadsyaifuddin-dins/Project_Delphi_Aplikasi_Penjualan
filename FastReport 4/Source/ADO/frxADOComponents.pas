
{******************************************}
{                                          }
{             FastReport v4.0              }
{         ADO enduser components           }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxADOComponents;

interface

{$I frx.inc}

uses
  Windows, Classes, SysUtils, frxClass, frxCustomDB, DB, ADODB, ADOInt
{$IFDEF Delphi6}
, Variants
{$ENDIF}
{$IFDEF QBUILDER}
, fqbClass
{$ENDIF}

;

const
  CLASS_TfrxADODatabase: TGUID = '{4B15360C-223C-4F3E-A306-8E5C19E2EA98}';
  CLASS_TfrxADOTable: TGUID = '{75AE7A73-E752-4DE6-A326-9C18C8D753F4}';
  CLASS_TfrxADOQuery: TGUID = '{6B1A7A66-07F6-4B4C-A454-BAA59FC951FA}';


type
  TfrxADOComponents = class(TfrxDBComponents)
  private
    FDefaultDatabase: TADOConnection;
    FOldComponents: TfrxADOComponents;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetDescription: String; override;
  published
    property DefaultDatabase: TADOConnection read FDefaultDatabase write FDefaultDatabase;
  end;


  TfrxADODatabase = class(TfrxCustomDatabase)

  private
    FDatabase: TADOConnection;
  protected
    procedure SetConnected(Value: Boolean); override;
    procedure SetDatabaseName(const Value: String); override;
    procedure SetLoginPrompt(Value: Boolean); override;
    function GetConnected: Boolean; override;
    function GetDatabaseName: String; override;
    function GetLoginPrompt: Boolean; override;

  public
    constructor Create(AOwner: TComponent); override;
    class function GetDescription: String; override;
    procedure SetLogin(const Login, Password: String); override;
    property Database: TADOConnection read FDatabase;
  published
    property DatabaseName;
    property LoginPrompt;
    property Connected;
  end;


  TfrxADOTable = class(TfrxCustomTable)

  private
    FDatabase: TfrxADODatabase;
    FTable: TADOTable;
    procedure SetDatabase(Value: TfrxADODatabase);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetMaster(const Value: TDataSource); override;
    procedure SetMasterFields(const Value: String); override;
    procedure SetIndexFieldNames(const Value: String); override;
    procedure SetIndexName(const Value: String); override;
    procedure SetTableName(const Value: String); override;
    function GetIndexFieldNames: String; override;
    function GetIndexName: String; override;
    function GetTableName: String; override;

  public
    constructor Create(AOwner: TComponent); override;
    constructor DesignCreate(AOwner: TComponent; Flags: Word); override;
    class function GetDescription: String; override;
    procedure BeforeStartReport; override;
    property Table: TADOTable read FTable;
  published
    property Database: TfrxADODatabase read FDatabase write SetDatabase;
  end;


  TfrxADOQuery = class(TfrxCustomQuery)

  private
    FDatabase: TfrxADODatabase;
    FQuery: TADOQuery;
    FStrings: TStrings;
    FLock: Boolean;
    procedure SetDatabase(Value: TfrxADODatabase);
    function GetCommandTimeout: Integer;
    procedure SetCommandTimeout(const Value: Integer);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure OnChangeSQL(Sender: TObject); override;
    procedure SetMaster(const Value: TDataSource); override;
    procedure SetSQL(Value: TStrings); override;
    function GetSQL: TStrings; override;

  public
    constructor Create(AOwner: TComponent); override;
    constructor DesignCreate(AOwner: TComponent; Flags: Word); override;
    destructor Destroy; override;
    class function GetDescription: String; override;
    procedure BeforeStartReport; override;
    procedure UpdateParams; override;
{$IFDEF QBUILDER}
    function QBEngine: TfqbEngine; override;
{$ENDIF}
    property Query: TADOQuery read FQuery;
  published
    property CommandTimeout: Integer read GetCommandTimeout write SetCommandTimeout;
    property Database: TfrxADODatabase read FDatabase write SetDatabase;
  end;

{$IFDEF QBUILDER}
  TfrxEngineADO = class(TfqbEngine)
  private
    FQuery: TADOQuery;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ReadTableList(ATableList: TStrings); override;
    procedure ReadFieldList(const ATableName: string; var AFieldList: TfqbFieldList); override;
    function ResultDataSet: TDataSet; override;
    procedure SetSQL(const Value: string); override;
  end;
{$ENDIF}

procedure frxParamsToTParameters(Query: TfrxCustomQuery; Params: TParameters);
procedure frxADOGetTableNames(conADO: TADOConnection; List: TStrings; SystemTables: Boolean);

var
  ADOComponents: TfrxADOComponents;


implementation

uses
  frxADORTTI,
{$IFNDEF NO_EDITORS}
  frxADOEditor,
{$ENDIF}
  frxDsgnIntf, frxRes;

type
  THackQuery = class(TADOQuery);


{ frxParamsToTParameters }

procedure frxParamsToTParameters(Query: TfrxCustomQuery; Params: TParameters);
var
  i: Integer;
  Item: TfrxParamItem;
begin
  for i := 0 to Params.Count - 1 do
    if Query.Params.IndexOf(Params[i].Name) <> -1 then
    begin
      Item := Query.Params[Query.Params.IndexOf(Params[i].Name)];
      Params[i].DataType := Item.DataType;
      Params[i].Attributes := [paNullable];
      if Trim(Item.Expression) <> '' then
        if not (Query.IsLoading or Query.IsDesigning) then
        begin
          Query.Report.CurObject := Query.Name;
          Item.Value := Query.Report.Calc(Item.Expression);
        end;
      Params[i].Value := Item.Value;
    end;
end;

procedure frxADOGetTableNames(conADO: TADOConnection; List: TStrings; SystemTables: Boolean);
var
  tbl: TADODataSet;
  s: string;
begin
  tbl := TADODataSet.Create(nil);
  List.Clear;
  try
    conADO.OpenSchema(siTables, EmptyParam, EmptyParam, tbl);
    tbl.First;
    while not tbl.Eof do
    begin
      s := Trim(tbl.FieldByName('TABLE_SCHEMA').AsString);
      if s <> '' then
        List.Add(s + '.' + tbl.FieldByName('TABLE_NAME').AsString)
      else
        List.Add(tbl.FieldByName('TABLE_NAME').AsString);
      tbl.Next;
    end;
  finally
    tbl.Free;
  end;
end;


{ TfrxDBComponents }

constructor TfrxADOComponents.Create(AOwner: TComponent);
begin
  inherited;
  FOldComponents := ADOComponents;
  ADOComponents := Self;
end;

destructor TfrxADOComponents.Destroy;
begin
  if ADOComponents = Self then
    ADOComponents := FOldComponents;
  inherited;
end;

function TfrxADOComponents.GetDescription: String;
begin
  Result := 'ADO';
end;


{ TfrxADODatabase }

constructor TfrxADODatabase.Create(AOwner: TComponent);
begin
  inherited;
  FDatabase := TADOConnection.Create(nil);
  Component := FDatabase;

  FImageIndex := 51;

end;

class function TfrxADODatabase.GetDescription: String;
begin
  Result := frxResources.Get('obADODB');
end;

function TfrxADODatabase.GetConnected: Boolean;
begin
  Result := FDatabase.Connected;
end;

function TfrxADODatabase.GetDatabaseName: String;
begin
  Result := FDatabase.ConnectionString;
end;

function TfrxADODatabase.GetLoginPrompt: Boolean;
begin
  Result := FDatabase.LoginPrompt;
end;

procedure TfrxADODatabase.SetConnected(Value: Boolean);
begin
  BeforeConnect(Value);
  FDatabase.Connected := Value;
end;

procedure TfrxADODatabase.SetDatabaseName(const Value: String);
begin
  FDatabase.ConnectionString := Value;
end;

procedure TfrxADODatabase.SetLoginPrompt(Value: Boolean);
begin
  FDatabase.LoginPrompt := Value;
end;

procedure TfrxADODatabase.SetLogin(const Login, Password: String);
var
  i, j: Integer;
  s: String;
begin
  s := DatabaseName;
  i := Pos('USER ID=', AnsiUppercase(s));
  if i <> 0 then
  begin
    for j := i to Length(s) do
      if s[j] = ';' then
        break;
    Delete(s, i, j - i);
    Insert('User ID=' + Login, s, i);
  end
  else
    s := s + ';User ID=' + Login;

  i := Pos('PASSWORD=', AnsiUppercase(s));
  if i <> 0 then
  begin
    for j := i to Length(s) do
      if s[j] = ';' then
        break;
    Delete(s, i, j - i);
    Insert('Password=' + Password, s, i);
  end
  else
    s := s + ';Password=' + Password;

  DatabaseName := s;
end;


{ TfrxADOTable }

constructor TfrxADOTable.Create(AOwner: TComponent);
begin
  FTable := TADOTable.Create(nil);
  DataSet := FTable;
  SetDatabase(nil);
  inherited;

  FImageIndex := 52;

end;

constructor TfrxADOTable.DesignCreate(AOwner: TComponent; Flags: Word);
var
  i: Integer;
  l: TList;
begin
  inherited;
  l := Report.AllObjects;
  for i := 0 to l.Count - 1 do
    if TObject(l[i]) is TfrxADODatabase then
    begin
      SetDatabase(TfrxADODatabase(l[i]));
      break;
    end;
end;

class function TfrxADOTable.GetDescription: String;
begin
  Result := frxResources.Get('obADOTb');
end;

procedure TfrxADOTable.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FDatabase) then
    SetDatabase(nil);
end;

procedure TfrxADOTable.SetDatabase(Value: TfrxADODatabase);
begin
  FDatabase := Value;
  if Value <> nil then
    FTable.Connection := Value.Database
  else if ADOComponents <> nil then
    FTable.Connection := ADOComponents.DefaultDatabase
  else
    FTable.Connection := nil;
  DBConnected := FTable.Connection <> nil;
end;

function TfrxADOTable.GetIndexFieldNames: String;
begin
  Result := FTable.IndexFieldNames;
end;

function TfrxADOTable.GetIndexName: String;
begin
  Result := FTable.IndexName;
end;

function TfrxADOTable.GetTableName: String;
begin
  Result := FTable.TableName;
end;

procedure TfrxADOTable.SetIndexFieldNames(const Value: String);
begin
  FTable.IndexFieldNames := Value;
end;

procedure TfrxADOTable.SetIndexName(const Value: String);
begin
  FTable.IndexName := Value;
end;

procedure TfrxADOTable.SetTableName(const Value: String);
begin
  FTable.TableName := Value;
end;

procedure TfrxADOTable.SetMaster(const Value: TDataSource);
begin
  FTable.MasterSource := Value;
end;

procedure TfrxADOTable.SetMasterFields(const Value: String);
begin
  FTable.MasterFields := Value;
end;

procedure TfrxADOTable.BeforeStartReport;
begin
  SetDatabase(FDatabase);
end;



{ TfrxADOQuery }

constructor TfrxADOQuery.Create(AOwner: TComponent);
begin
  FStrings := TStringList.Create;
  FQuery := TADOQuery.Create(nil);
  Dataset := FQuery;
  SetDatabase(nil);
  FLock := False;
  inherited;

  FImageIndex := 53;

end;

constructor TfrxADOQuery.DesignCreate(AOwner: TComponent; Flags: Word);
var
  i: Integer;
  l: TList;
begin
  inherited;
  l := Report.AllObjects;
  for i := 0 to l.Count - 1 do
    if TObject(l[i]) is TfrxADODatabase then
    begin
      SetDatabase(TfrxADODatabase(l[i]));
      break;
    end;
end;

destructor TfrxADOQuery.Destroy;
begin
  FStrings.Free;
  inherited;
end;

class function TfrxADOQuery.GetDescription: String;
begin
  Result := frxResources.Get('obADOQ');
end;

procedure TfrxADOQuery.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FDatabase) then
    SetDatabase(nil);
end;

function TfrxADOQuery.GetSQL: TStrings;
begin
  FLock := True;
  FStrings.Assign(FQuery.SQL);
  FLock := False;
  Result := FStrings;
end;

procedure TfrxADOQuery.SetSQL(Value: TStrings);
begin
  FQuery.SQL.Assign(Value);
  FStrings.Assign(FQuery.SQL);
end;

procedure TfrxADOQuery.SetDatabase(Value: TfrxADODatabase);
begin
  FDatabase := Value;
  if Value <> nil then
    FQuery.Connection := Value.Database
  else if ADOComponents <> nil then
    FQuery.Connection := ADOComponents.DefaultDatabase
  else
    FQuery.Connection := nil;
  DBConnected := FQuery.Connection <> nil;
end;

procedure TfrxADOQuery.SetMaster(const Value: TDataSource);
begin
  FQuery.DataSource := Value;
end;

function TfrxADOQuery.GetCommandTimeout: Integer;
begin
  Result := THackQuery(FQuery).CommandTimeout;
end;

procedure TfrxADOQuery.SetCommandTimeout(const Value: Integer);
begin
  THackQuery(FQuery).CommandTimeout := Value;
end;

procedure TfrxADOQuery.UpdateParams;
begin
  frxParamsToTParameters(Self, FQuery.Parameters);
end;

procedure TfrxADOQuery.OnChangeSQL(Sender: TObject);
var
  i, ind: Integer;
  Param: TfrxParamItem;
  QParam: TParameter;
begin
  if not FLock then
  begin
    { needed to update parameters }
    FQuery.SQL.Text := '';
    FQuery.SQL.Assign(FStrings);
    inherited;

    { fill datatype automatically, if possible }
    for i := 0 to FQuery.Parameters.Count - 1 do
    begin
      QParam := FQuery.Parameters[i];
      ind := Params.IndexOf(QParam.Name);
      if ind <> -1 then
      begin
        Param := Params[ind];
        if (Param.DataType = ftUnknown) and (QParam.DataType <> ftUnknown) then
          Param.DataType := QParam.DataType;
      end;
    end;
  end;
end;

procedure TfrxADOQuery.BeforeStartReport;
begin
  SetDatabase(FDatabase);
  { needed to update parameters }
  SQL.Text := SQL.Text;
end;

{$IFDEF QBUILDER}
function TfrxADOQuery.QBEngine: TfqbEngine;
begin
  Result := TfrxEngineADO.Create(nil);
  TfrxEngineADO(Result).FQuery.Connection := FQuery.Connection;
end;
{$ENDIF}



{$IFDEF QBUILDER}
constructor TfrxEngineADO.Create(AOwner: TComponent);
begin
  inherited;
  FQuery := TADOQuery.Create(Self);
end;

destructor TfrxEngineADO.Destroy;
begin
  FQuery.Free;
  inherited;
end;

procedure TfrxEngineADO.ReadFieldList(const ATableName: string;
  var AFieldList: TfqbFieldList);
var
  TempTable: TADOTable;
  Fields: TFieldDefs;
  i: Integer;
  tmpField: TfqbField;
begin
  AFieldList.Clear;
  TempTable := TADOTable.Create(Self);
  TempTable.Connection := FQuery.Connection;
  TempTable.TableName := ATableName;
  Fields := TempTable.FieldDefs;
  try
    try
      TempTable.Active := True;
      tmpField:= TfqbField(AFieldList.Add);
      tmpField.FieldName := '*';
      for i := 0 to Fields.Count - 1 do
      begin
        tmpField := TfqbField(AFieldList.Add);
        tmpField.FieldName := Fields.Items[i].Name;
        tmpField.FieldType := Ord(Fields.Items[i].DataType)
      end;
    except
    end;
  finally
    TempTable.Free;
  end;
end;

procedure TfrxEngineADO.ReadTableList(ATableList: TStrings);
begin
  ATableList.Clear;
  frxADOGetTableNames(FQuery.Connection, ATableList, ShowSystemTables);
//  FQuery.Connection.GetTableNames(ATableList, ShowSystemTables);
end;

function TfrxEngineADO.ResultDataSet: TDataSet;
begin
  Result := FQuery;
end;

procedure TfrxEngineADO.SetSQL(const Value: string);
begin
  FQuery.SQL.Text := Value;
end;
{$ENDIF}


initialization
  frxObjects.RegisterObject1(TfrxADODataBase, nil, '', '', 0, 51);
  frxObjects.RegisterObject1(TfrxADOTable, nil, '', '', 0, 52);
  frxObjects.RegisterObject1(TfrxADOQuery, nil, '', '', 0, 53);



finalization
  frxObjects.UnRegister(TfrxADODataBase);
  frxObjects.UnRegister(TfrxADOTable);
  frxObjects.UnRegister(TfrxADOQuery);

end.