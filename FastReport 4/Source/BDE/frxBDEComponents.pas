
{******************************************}
{                                          }
{             FastReport v4.0              }
{         BDE enduser components           }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxBDEComponents;

interface

{$I frx.inc}

uses
  Windows, Classes, SysUtils, frxClass, frxCustomDB, DB, DBTables
{$IFDEF Delphi6}
, Variants
{$ENDIF}
{$IFDEF QBUILDER}
, fqbClass
{$ENDIF};


type
  TfrxBDEComponents = class(TfrxDBComponents)
  private
    FDefaultDatabase: String;
    FDefaultSession: String;
    FOldComponents: TfrxBDEComponents;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetDescription: String; override;
  published
    property DefaultDatabase: String read FDefaultDatabase write FDefaultDatabase;
    property DefaultSession: String read FDefaultSession write FDefaultSession;
  end;

  TfrxBDEDatabase = class(TfrxCustomDatabase)
  private
    FDatabase: TDatabase;
    procedure SetAliasName(const Value: String);
    procedure SetDriverName(const Value: String);
    function GetAliasName: String;
    function GetDriverName: String;
  protected
    function GetConnected: Boolean; override;
    function GetDatabaseName: String; override;
    function GetLoginPrompt: Boolean; override;
    function GetParams: TStrings; override;
    procedure SetConnected(Value: Boolean); override;
    procedure SetDatabaseName(const Value: String); override;
    procedure SetLoginPrompt(Value: Boolean); override;
    procedure SetParams(Value: TStrings); override;
  public
    constructor Create(AOwner: TComponent); override;
    class function GetDescription: String; override;
    property Database: TDatabase read FDatabase;
  published
    property AliasName: String read GetAliasName write SetAliasName;
    property DatabaseName;
    property DriverName: String read GetDriverName write SetDriverName;
    property LoginPrompt;
    property Params;
    property Connected;
  end;

  TfrxBDETable = class(TfrxCustomTable)
  private
    FTable: TTable;
    procedure SetDatabaseName(const Value: String);
    function GetDatabaseName: String;
    procedure SetSessionName(const Value: String);
    function GetSessionName: String;
  protected
    procedure SetMaster(const Value: TDataSource); override;
    procedure SetMasterFields(const Value: String); override;
    procedure SetIndexName(const Value: String); override;
    procedure SetIndexFieldNames(const Value: String); override;
    procedure SetTableName(const Value: String); override;
    function GetIndexName: String; override;
    function GetIndexFieldNames: String; override;
    function GetTableName: String; override;
  public
    constructor Create(AOwner: TComponent); override;
    class function GetDescription: String; override;
    property Table: TTable read FTable;
  published
    property DatabaseName: String read GetDatabaseName write SetDatabaseName;
    property SessionName: String read GetSessionName write SetSessionName;
  end;

  TfrxBDEQuery = class(TfrxCustomQuery)
  private
    FQuery: TQuery;
    procedure SetDatabaseName(const Value: String);
    function GetDatabaseName: String;
    procedure SetSessionName(const Value: String);
    function GetSessionName: String;
  protected
    procedure SetMaster(const Value: TDataSource); override;
    procedure SetSQL(Value: TStrings); override;
    function GetSQL: TStrings; override;
  public
    constructor Create(AOwner: TComponent); override;
    class function GetDescription: String; override;
    procedure UpdateParams; override;
{$IFDEF QBUILDER}
    function QBEngine: TfqbEngine; override;
{$ENDIF}
    property Query: TQuery read FQuery;
  published
    property DatabaseName: String read GetDatabaseName write SetDatabaseName;
    property SessionName: String read GetSessionName write SetSessionName;
  end;

{$IFDEF QBUILDER}
  TfrxEngineBDE = class(TfqbEngine)
  private
    FQuery: TQuery;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ReadTableList(ATableList: TStrings); override;
    procedure ReadFieldList(const ATableName: string; var AFieldList: TfqbFieldList); override;
    function ResultDataSet: TDataSet; override;
    procedure SetSQL(const Value: string); override;
  end;
{$ENDIF}

var
  BDEComponents: TfrxBDEComponents;


implementation

uses
  frxBDERTTI,
{$IFNDEF NO_EDITORS}
  frxBDEEditor,
{$ENDIF}
  frxDsgnIntf, frxRes;


{ TfrxDBComponents }

constructor TfrxBDEComponents.Create(AOwner: TComponent);
begin
  inherited;
  FDefaultSession := 'Default';
  FOldComponents := BDEComponents;
  BDEComponents := Self;
end;

destructor TfrxBDEComponents.Destroy;
begin
  if BDEComponents = Self then
    BDEComponents := FOldComponents;
  inherited;
end;

function TfrxBDEComponents.GetDescription: String;
begin
  Result := 'BDE';
end;


{ TfrxBDEDatabase }

constructor TfrxBDEDatabase.Create(AOwner: TComponent);
begin
  inherited;
  FDatabase := TDatabase.Create(nil);
  Component := FDatabase;
  FImageIndex := 54;
end;

class function TfrxBDEDatabase.GetDescription: String;
begin
  Result := frxResources.Get('obBDEDB');
end;

function TfrxBDEDatabase.GetAliasName: String;
begin
  Result := FDatabase.AliasName;
end;

function TfrxBDEDatabase.GetConnected: Boolean;
begin
  Result := FDatabase.Connected;
end;

function TfrxBDEDatabase.GetDatabaseName: String;
begin
  Result := FDatabase.DatabaseName;
end;

function TfrxBDEDatabase.GetDriverName: String;
begin
  Result := FDatabase.DriverName;
end;

function TfrxBDEDatabase.GetLoginPrompt: Boolean;
begin
  Result := FDatabase.LoginPrompt;
end;

function TfrxBDEDatabase.GetParams: TStrings;
begin
  Result := FDatabase.Params;
end;

procedure TfrxBDEDatabase.SetAliasName(const Value: String);
begin
  FDatabase.AliasName := Value;
end;

procedure TfrxBDEDatabase.SetConnected(Value: Boolean);
begin
  BeforeConnect(Value);
  FDatabase.Connected := Value;
end;

procedure TfrxBDEDatabase.SetDatabaseName(const Value: String);
begin
  FDatabase.DatabaseName := Value;
end;

procedure TfrxBDEDatabase.SetDriverName(const Value: String);
begin
  FDatabase.DriverName := Value;
end;

procedure TfrxBDEDatabase.SetLoginPrompt(Value: Boolean);
begin
  FDatabase.LoginPrompt := Value;
end;

procedure TfrxBDEDatabase.SetParams(Value: TStrings);
begin
  FDatabase.Params := Value;
end;


{ TfrxBDETable }

constructor TfrxBDETable.Create(AOwner: TComponent);
begin
  FTable := TTable.Create(nil);
  DataSet := FTable;
  if BDEComponents <> nil then
  begin
    DatabaseName := BDEComponents.DefaultDatabase;
    SessionName := BDEComponents.DefaultSession;
  end;
  inherited;
  FImageIndex := 55;
end;

class function TfrxBDETable.GetDescription: String;
begin
  Result := frxResources.Get('obBDETb');
end;

function TfrxBDETable.GetDatabaseName: String;
begin
  Result := FTable.DatabaseName;
end;

function TfrxBDETable.GetSessionName: String;
begin
  Result := FTable.SessionName;
end;

procedure TfrxBDETable.SetDatabaseName(const Value: String);
begin
  FTable.DatabaseName := Value;
  DBConnected := True;
end;

procedure TfrxBDETable.SetSessionName(const Value: String);
begin
  FTable.SessionName := Value;
end;

function TfrxBDETable.GetIndexName: String;
begin
  Result := FTable.IndexName;
end;

function TfrxBDETable.GetIndexFieldNames: String;
begin
  Result := FTable.IndexFieldNames;
end;

function TfrxBDETable.GetTableName: String;
begin
  Result := FTable.TableName;
end;

procedure TfrxBDETable.SetIndexName(const Value: String);
begin
  FTable.IndexName := Value;
end;

procedure TfrxBDETable.SetIndexFieldNames(const Value: String);
begin
  FTable.IndexFieldNames := Value;
end;

procedure TfrxBDETable.SetTableName(const Value: String);
begin
  FTable.TableName := Value;
end;

procedure TfrxBDETable.SetMaster(const Value: TDataSource);
begin
  FTable.MasterSource := Value;
end;

procedure TfrxBDETable.SetMasterFields(const Value: String);
begin
  FTable.MasterFields := Value;
end;


{ TfrxBDEQuery }

constructor TfrxBDEQuery.Create(AOwner: TComponent);
begin
  FQuery := TQuery.Create(nil);
  Dataset := FQuery;
  if BDEComponents <> nil then
  begin
    DatabaseName := BDEComponents.DefaultDatabase;
    SessionName := BDEComponents.DefaultSession;
  end;
  inherited;
  FImageIndex := 56;
end;

class function TfrxBDEQuery.GetDescription: String;
begin
  Result := frxResources.Get('obBDEQ');
end;

function TfrxBDEQuery.GetDatabaseName: String;
begin
  Result := FQuery.DatabaseName;
end;

function TfrxBDEQuery.GetSessionName: String;
begin
  Result := FQuery.SessionName;
end;

function TfrxBDEQuery.GetSQL: TStrings;
begin
  Result := FQuery.SQL;
end;

procedure TfrxBDEQuery.SetDatabaseName(const Value: String);
begin
  FQuery.DatabaseName := Value;
  DBConnected := True;
end;

procedure TfrxBDEQuery.SetMaster(const Value: TDataSource);
begin
  FQuery.DataSource := Value;
end;

procedure TfrxBDEQuery.SetSessionName(const Value: String);
begin
  FQuery.SessionName := Value;
end;

procedure TfrxBDEQuery.SetSQL(Value: TStrings);
begin
  FQuery.SQL := Value;
end;

procedure TfrxBDEQuery.UpdateParams;
begin
  frxParamsToTParams(Self, FQuery.Params);
end;

{$IFDEF QBUILDER}
function TfrxBDEQuery.QBEngine: TfqbEngine;
begin
  Result := TfrxEngineBDE.Create(nil);
  TfrxEngineBDE(Result).FQuery.DatabaseName := FQuery.DatabaseName;
end;
{$ENDIF}


{$IFDEF QBUILDER}
constructor TfrxEngineBDE.Create(AOwner: TComponent);
begin
  inherited;
  FQuery := TQuery.Create(Self);
end;

destructor TfrxEngineBDE.Destroy;
begin
  FQuery.Free;
  inherited
end;

procedure TfrxEngineBDE.ReadFieldList(const ATableName: string;
  var AFieldList: TfqbFieldList);
var
  TempTable: TTable;
  Fields: TFieldDefs;
  i: Integer;
  tmpField: TfqbField;
begin
  AFieldList.Clear;
  TempTable := TTable.Create(Self);
  TempTable.DatabaseName := FQuery.DatabaseName;
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

procedure TfrxEngineBDE.ReadTableList(ATableList: TStrings);
begin
  ATableList.BeginUpdate;
  ATableList.Clear;
  try
    Session.GetTableNames(FQuery.DatabaseName, '', True, ShowSystemTables, ATableList);
  finally
    ATableList.EndUpdate;
  end;
end;

function TfrxEngineBDE.ResultDataSet: TDataSet;
begin
  Result := FQuery;
end;

procedure TfrxEngineBDE.SetSQL(const Value: string);
begin
  FQuery.SQL.Text := Value;
end;
{$ENDIF}

initialization
  frxObjects.RegisterObject1(TfrxBDEDataBase, nil, '', '', 0, 54);
  frxObjects.RegisterObject1(TfrxBDETable, nil, '', '', 0, 55);
  frxObjects.RegisterObject1(TfrxBDEQuery, nil, '', '', 0, 56);

finalization
  frxObjects.UnRegister(TfrxBDEDataBase);
  frxObjects.UnRegister(TfrxBDETable);
  frxObjects.UnRegister(TfrxBDEQuery);


end.