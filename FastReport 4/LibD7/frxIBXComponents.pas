
{******************************************}
{                                          }
{             FastReport v4.0              }
{         IBX enduser components           }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxIBXComponents;

interface

{$I frx.inc}

uses
  Windows, Classes, frxClass, frxCustomDB, DB, IBDatabase, IBTable, IBQuery
{$IFDEF Delphi6}
, Variants
{$ENDIF}
{$IFDEF QBUILDER}
, fqbClass
{$ENDIF};


type
  TfrxIBXComponents = class(TfrxDBComponents)
  private
    FDefaultDatabase: TIBDatabase;
    FOldComponents: TfrxIBXComponents;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetDescription: String; override;
  published
    property DefaultDatabase: TIBDatabase read FDefaultDatabase write FDefaultDatabase;
  end;

  TfrxIBXDatabase = class(TfrxCustomDatabase)
  private
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;
    function GetSQLDialect: Integer;
    procedure SetSQLDialect(const Value: Integer);
  protected
    procedure SetConnected(Value: Boolean); override;
    procedure SetDatabaseName(const Value: String); override;
    procedure SetLoginPrompt(Value: Boolean); override;
    procedure SetParams(Value: TStrings); override;
    function GetConnected: Boolean; override;
    function GetDatabaseName: String; override;
    function GetLoginPrompt: Boolean; override;
    function GetParams: TStrings; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class function GetDescription: String; override;
    procedure SetLogin(const Login, Password: String); override;
    property Database: TIBDatabase read FDatabase;
  published
    property DatabaseName;
    property LoginPrompt;
    property Params;
    property SQLDialect: Integer read GetSQLDialect write SetSQLDialect;
    property Connected;
  end;

  TfrxIBXTable = class(TfrxCustomTable)
  private
    FDatabase: TfrxIBXDatabase;
    FTable: TIBTable;
    procedure SetDatabase(const Value: TfrxIBXDatabase);
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
    property Table: TIBTable read FTable;
  published
    property Database: TfrxIBXDatabase read FDatabase write SetDatabase;
  end;

  TfrxIBXQuery = class(TfrxCustomQuery)
  private
    FDatabase: TfrxIBXDatabase;
    FQuery: TIBQuery;
    procedure SetDatabase(const Value: TfrxIBXDatabase);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetMaster(const Value: TDataSource); override;
    procedure SetSQL(Value: TStrings); override;
    function GetSQL: TStrings; override;
  public
    constructor Create(AOwner: TComponent); override;
    constructor DesignCreate(AOwner: TComponent; Flags: Word); override;
    class function GetDescription: String; override;
    procedure BeforeStartReport; override;
    procedure UpdateParams; override;
{$IFDEF QBUILDER}
    function QBEngine: TfqbEngine; override;
{$ENDIF}
    property Query: TIBQuery read FQuery;
  published
    property Database: TfrxIBXDatabase read FDatabase write SetDatabase;
  end;

{$IFDEF QBUILDER}
  TfrxEngineIBX = class(TfqbEngine)
  private
    FQuery: TIBQuery;
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
  IBXComponents: TfrxIBXComponents;


implementation

uses
  frxIBXRTTI,
{$IFNDEF NO_EDITORS}
  frxIBXEditor,
{$ENDIF}
  frxDsgnIntf, frxRes;


{ TfrxDBComponents }

constructor TfrxIBXComponents.Create(AOwner: TComponent);
begin
  inherited;
  FOldComponents := IBXComponents;
  IBXComponents := Self;
end;

destructor TfrxIBXComponents.Destroy;
begin
  if IBXComponents = Self then
    IBXComponents := FOldComponents;
  inherited;
end;

function TfrxIBXComponents.GetDescription: String;
begin
  Result := 'IBX';
end;


{ TfrxIBXDatabase }

constructor TfrxIBXDatabase.Create(AOwner: TComponent);
begin
  inherited;
  FDatabase := TIBDatabase.Create(nil);
  FTransaction := TIBTransaction.Create(nil);
  FDatabase.DefaultTransaction := FTransaction;
  Component := FDatabase;
  FImageIndex := 60;
end;

destructor TfrxIBXDatabase.Destroy;
begin
  FTransaction.Free;
  inherited;
end;

class function TfrxIBXDatabase.GetDescription: String;
begin
  Result := frxResources.Get('obIBXDB');
end;

function TfrxIBXDatabase.GetConnected: Boolean;
begin
  Result := FDatabase.Connected;
end;

function TfrxIBXDatabase.GetDatabaseName: String;
begin
  Result := FDatabase.DatabaseName;
end;

function TfrxIBXDatabase.GetLoginPrompt: Boolean;
begin
  Result := FDatabase.LoginPrompt;
end;

function TfrxIBXDatabase.GetParams: TStrings;
begin
  Result := FDatabase.Params;
end;

function TfrxIBXDatabase.GetSQLDialect: Integer;
begin
  Result := FDatabase.SQLDialect;
end;

procedure TfrxIBXDatabase.SetConnected(Value: Boolean);
begin
  BeforeConnect(Value);
  FDatabase.Connected := Value;
  FTransaction.Active := Value;
end;

procedure TfrxIBXDatabase.SetDatabaseName(const Value: String);
begin
  FDatabase.DatabaseName := Value;
end;

procedure TfrxIBXDatabase.SetLoginPrompt(Value: Boolean);
begin
  FDatabase.LoginPrompt := Value;
end;

procedure TfrxIBXDatabase.SetParams(Value: TStrings);
begin
  FDatabase.Params := Value;
end;

procedure TfrxIBXDatabase.SetSQLDialect(const Value: Integer);
begin
  FDatabase.SQLDialect := Value;
end;

procedure TfrxIBXDatabase.SetLogin(const Login, Password: String);
begin
  Params.Text := 'user_name=' + Login + #13#10 + 'password=' + Password;
end;


{ TfrxIBXTable }

constructor TfrxIBXTable.Create(AOwner: TComponent);
begin
  FTable := TIBTable.Create(nil);
  DataSet := FTable;
  SetDatabase(nil);
  inherited;
  FImageIndex := 61;
end;

constructor TfrxIBXTable.DesignCreate(AOwner: TComponent; Flags: Word);
var
  i: Integer;
  l: TList;
begin
  inherited;
  l := Report.AllObjects;
  for i := 0 to l.Count - 1 do
    if TObject(l[i]) is TfrxIBXDatabase then
    begin
      SetDatabase(TfrxIBXDatabase(l[i]));
      break;
    end;
end;

class function TfrxIBXTable.GetDescription: String;
begin
  Result := frxResources.Get('obIBXTb');
end;

procedure TfrxIBXTable.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FDatabase) then
    SetDatabase(nil);
end;

procedure TfrxIBXTable.SetDatabase(const Value: TfrxIBXDatabase);
begin
  FDatabase := Value;
  if Value <> nil then
    FTable.Database := Value.Database
  else if IBXComponents <> nil then
    FTable.Database := IBXComponents.DefaultDatabase
  else
    FTable.Database := nil;
  DBConnected := FTable.Database <> nil;
end;

function TfrxIBXTable.GetIndexFieldNames: String;
begin
  Result := FTable.IndexFieldNames;
end;

function TfrxIBXTable.GetIndexName: String;
begin
  Result := FTable.IndexName;
end;

function TfrxIBXTable.GetTableName: String;
begin
  Result := FTable.TableName;
end;

procedure TfrxIBXTable.SetIndexFieldNames(const Value: String);
begin
  FTable.IndexFieldNames := Value;
end;

procedure TfrxIBXTable.SetIndexName(const Value: String);
begin
  FTable.IndexName := Value;
end;

procedure TfrxIBXTable.SetTableName(const Value: String);
begin
  FTable.TableName := Value;
end;

procedure TfrxIBXTable.SetMaster(const Value: TDataSource);
begin
  FTable.MasterSource := Value;
end;

procedure TfrxIBXTable.SetMasterFields(const Value: String);
begin
  FTable.MasterFields := Value;
end;

procedure TfrxIBXTable.BeforeStartReport;
begin
  SetDatabase(FDatabase);
end;


{ TfrxIBXQuery }

constructor TfrxIBXQuery.Create(AOwner: TComponent);
begin
  FQuery := TIBQuery.Create(nil);
  Dataset := FQuery;
  SetDatabase(nil);
  inherited;
  FImageIndex := 62;
end;

constructor TfrxIBXQuery.DesignCreate(AOwner: TComponent; Flags: Word);
var
  i: Integer;
  l: TList;
begin
  inherited;
  l := Report.AllObjects;
  for i := 0 to l.Count - 1 do
    if TObject(l[i]) is TfrxIBXDatabase then
    begin
      SetDatabase(TfrxIBXDatabase(l[i]));
      break;
    end;
end;

class function TfrxIBXQuery.GetDescription: String;
begin
  Result := frxResources.Get('obIBXQ');
end;

procedure TfrxIBXQuery.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FDatabase) then
    SetDatabase(nil);
end;

procedure TfrxIBXQuery.SetDatabase(const Value: TfrxIBXDatabase);
begin
  FDatabase := Value;
  if Value <> nil then
    FQuery.Database := Value.Database
  else if IBXComponents <> nil then
    FQuery.Database := IBXComponents.DefaultDatabase
  else
    FQuery.Database := nil;
  DBConnected := FQuery.Database <> nil;
end;

procedure TfrxIBXQuery.SetMaster(const Value: TDataSource);
begin
  FQuery.DataSource := Value;
end;

procedure TfrxIBXQuery.SetSQL(Value: TStrings);
begin
  FQuery.SQL := Value;
end;

function TfrxIBXQuery.GetSQL: TStrings;
begin
  Result := FQuery.SQL;
end;

procedure TfrxIBXQuery.UpdateParams;
begin
  frxParamsToTParams(Self, FQuery.Params);
end;

procedure TfrxIBXQuery.BeforeStartReport;
begin
  SetDatabase(FDatabase);
end;

{$IFDEF QBUILDER}
function TfrxIBXQuery.QBEngine: TfqbEngine;
begin
  Result := TfrxEngineIBX.Create(nil);
  TfrxEngineIBX(Result).FQuery.Database := FQuery.Database;
end;
{$ENDIF}


{$IFDEF QBUILDER}
constructor TfrxEngineIBX.Create(AOwner: TComponent);
begin
  inherited;
  FQuery := TIBQuery.Create(Self);
end;

destructor TfrxEngineIBX.Destroy;
begin
  FQuery.Free;
  inherited;
end;

procedure TfrxEngineIBX.ReadFieldList(const ATableName: string;
  var AFieldList: TfqbFieldList);
var
  TempTable: TIBTable;
  Fields: TFieldDefs;
  i: Integer;
  tmpField: TfqbField;
begin
  AFieldList.Clear;
  TempTable := TIBTable.Create(Self);
  TempTable.Database := FQuery.Database;
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

procedure TfrxEngineIBX.ReadTableList(ATableList: TStrings);
begin
  ATableList.Clear;
  FQuery.Database.GetTableNames(ATableList, ShowSystemTables);
end;

function TfrxEngineIBX.ResultDataSet: TDataSet;
begin
  Result := FQuery;
end;

procedure TfrxEngineIBX.SetSQL(const Value: string);
begin
  FQuery.SQL.Text := Value;
end;
{$ENDIF}


initialization
  frxObjects.RegisterObject1(TfrxIBXDataBase, nil, '', '', 0, 60);
  frxObjects.RegisterObject1(TfrxIBXTable, nil, '', '', 0, 61);
  frxObjects.RegisterObject1(TfrxIBXQuery, nil, '', '', 0, 62);

finalization
  frxObjects.UnRegister(TfrxIBXDataBase);
  frxObjects.UnRegister(TfrxIBXTable);
  frxObjects.UnRegister(TfrxIBXQuery);


end.