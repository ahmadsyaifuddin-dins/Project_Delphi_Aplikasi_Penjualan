
{******************************************}
{                                          }
{             FastReport v4.0              }
{         DBX enduser components           }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxDBXComponents;

interface

{$I frx.inc}

uses
  Windows, Classes, frxClass, frxCustomDB, DB, DBXpress, SqlExpr,
  Provider, DBClient
{$IFDEF Delphi6}
, Variants
{$ENDIF}
{$IFDEF QBUILDER}
, fqbClass
{$ENDIF};


type
  TfrxDBXDataset = class(TCustomClientDataset)
  private
    FDataSet: TDataSet;
    FProvider: TDataSetProvider;
    procedure SetDataset(const Value: TDataset);
  protected
    procedure OpenCursor(InfoQuery: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Dataset: TDataset read FDataset write SetDataset;
  end;

  TfrxDBXComponents = class(TfrxDBComponents)
  private
    FDefaultDatabase: TSQLConnection;
    FOldComponents: TfrxDBXComponents;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetDescription: String; override;
  published
    property DefaultDatabase: TSQLConnection read FDefaultDatabase write FDefaultDatabase;
  end;

  TfrxDBXDatabase = class(TfrxCustomDatabase)
  private
    FDatabase: TSQLConnection;
    FStrings: TStrings;
    FLock: Boolean;
    function GetDriverName: String;
    function GetGetDriverFunc: String;
    function GetLibraryName: String;
    function GetVendorLib: String;
    procedure SetDriverName(const Value: String);
    procedure SetGetDriverFunc(const Value: String);
    procedure SetLibraryName(const Value: String);
    procedure SetVendorLib(const Value: String);
    procedure OnChange(Sender: TObject);
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
    property Database: TSQLConnection read FDatabase;
  published
    property ConnectionName: String read GetDatabaseName write SetDatabaseName;
    property DriverName: String read GetDriverName write SetDriverName;
    property GetDriverFunc: String read GetGetDriverFunc write SetGetDriverFunc;
    property LibraryName: String read GetLibraryName write SetLibraryName;
    property LoginPrompt;
    property Params;
    property VendorLib: String read GetVendorLib write SetVendorLib;
    property Connected;
  end;

  TfrxDBXTable = class(TfrxCustomTable)
  private
    FDatabase: TfrxDBXDatabase;
    FTable: TSQLTable;
    procedure SetDatabase(const Value: TfrxDBXDatabase);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
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
    constructor DesignCreate(AOwner: TComponent; Flags: Word); override;
    destructor Destroy; override;
    class function GetDescription: String; override;
    procedure BeforeStartReport; override;
    property Table: TSQLTable read FTable;
  published
    property Database: TfrxDBXDatabase read FDatabase write SetDatabase;
  end;

  TfrxDBXQuery = class(TfrxCustomQuery)
  private
    FDatabase: TfrxDBXDatabase;
    FQuery: TSQLQuery;
    FStrings: TStrings;
    FLock: Boolean;
    procedure SetDatabase(const Value: TfrxDBXDatabase);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetMaster(const Value: TDataSource); override;
    procedure SetSQL(Value: TStrings); override;
    function GetSQL: TStrings; override;
    procedure OnChangeSQL(Sender: TObject); override;
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
    property Query: TSQLQuery read FQuery;
  published
    property Database: TfrxDBXDatabase read FDatabase write SetDatabase;
  end;

{$IFDEF QBUILDER}
  TfrxEngineDBX = class(TfqbEngine)
  private
    FQuery: TSQLQuery;
    FDBXDataset: TfrxDBXDataset;
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
  DBXComponents: TfrxDBXComponents;


implementation

uses
  frxDBXRTTI,
{$IFNDEF NO_EDITORS}
  frxDBXEditor,
{$ENDIF}
  frxDsgnIntf, frxRes;

type
  THackSQLConnection = class(TSQLConnection);


{ TfrxDBXDataset }

constructor TfrxDBXDataset.Create(AOwner: TComponent);
begin
  inherited;
  FProvider := TDatasetProvider.Create(nil);
end;

destructor TfrxDBXDataset.Destroy;
begin
  FProvider.Free;
  inherited;
end;

procedure TfrxDBXDataset.OpenCursor(InfoQuery: Boolean);
begin
  SetProvider(FProvider);
  inherited;
end;

procedure TfrxDBXDataset.SetDataset(const Value: TDataset);
begin
  FDataset := Value;
  FProvider.Dataset := FDataset;
end;


{ TfrxDBXComponents }

constructor TfrxDBXComponents.Create(AOwner: TComponent);
begin
  inherited;
  FOldComponents := DBXComponents;
  DBXComponents := Self;
end;

destructor TfrxDBXComponents.Destroy;
begin
  if DBXComponents = Self then
    DBXComponents := FOldComponents;
  inherited;
end;

function TfrxDBXComponents.GetDescription: String;
begin
  Result := 'DBX';
end;


{ TfrxDBXDatabase }

constructor TfrxDBXDatabase.Create(AOwner: TComponent);
begin
  inherited;
  FStrings := TStringList.Create;
  TStringList(FStrings).OnChange := OnChange;
  FDatabase := TSQLConnection.Create(nil);
// set ComponentState := csDesigning to obtain Params automatically
  THackSQLConnection(FDataBase).SetDesigning(True, False);
  Component := FDatabase;
  FImageIndex := 57;
end;

destructor TfrxDBXDatabase.Destroy;
begin
  FStrings.Free;
  inherited;
end;

class function TfrxDBXDatabase.GetDescription: String;
begin
  Result := frxResources.Get('obDBXDB');
end;

function TfrxDBXDatabase.GetConnected: Boolean;
begin
  Result := FDatabase.Connected;
end;

function TfrxDBXDatabase.GetDatabaseName: String;
begin
  Result := FDatabase.ConnectionName;
end;

function TfrxDBXDatabase.GetDriverName: String;
begin
  Result := FDatabase.DriverName;
end;

function TfrxDBXDatabase.GetGetDriverFunc: String;
begin
  Result := FDatabase.GetDriverFunc;
end;

function TfrxDBXDatabase.GetLibraryName: String;
begin
  Result := FDatabase.LibraryName;
end;

function TfrxDBXDatabase.GetLoginPrompt: Boolean;
begin
  Result := FDatabase.LoginPrompt;
end;

function TfrxDBXDatabase.GetParams: TStrings;
begin
  FLock := True;
  FStrings.Assign(FDatabase.Params);
  FLock := False;
  Result := FStrings;
end;

function TfrxDBXDatabase.GetVendorLib: String;
begin
  Result := FDatabase.VendorLib;
end;

procedure TfrxDBXDatabase.SetConnected(Value: Boolean);
begin
  BeforeConnect(Value);
  FDatabase.Connected := Value;
end;

procedure TfrxDBXDatabase.SetDatabaseName(const Value: String);
begin
  FDatabase.ConnectionName := Value;
end;

procedure TfrxDBXDatabase.SetDriverName(const Value: String);
begin
  FDatabase.DriverName := Value;
end;

procedure TfrxDBXDatabase.SetGetDriverFunc(const Value: String);
begin
  FDatabase.GetDriverFunc := Value;
end;

procedure TfrxDBXDatabase.SetLibraryName(const Value: String);
begin
  FDatabase.LibraryName := Value;
end;

procedure TfrxDBXDatabase.SetLoginPrompt(Value: Boolean);
begin
  FDatabase.LoginPrompt := Value;
end;

procedure TfrxDBXDatabase.SetParams(Value: TStrings);
begin
  FStrings.Assign(Value);
end;

procedure TfrxDBXDatabase.SetVendorLib(const Value: String);
begin
  FDatabase.VendorLib := Value;
end;

procedure TfrxDBXDatabase.OnChange(Sender: TObject);
begin
  if not FLock then
    FDatabase.Params.Assign(FStrings);
end;


{ TfrxDBXTable }

constructor TfrxDBXTable.Create(AOwner: TComponent);
begin
  FTable := TSQLTable.Create(nil);
  DataSet := FTable;
  SetDatabase(nil);
  inherited;
  FImageIndex := 58;
end;

destructor TfrxDBXTable.Destroy;
begin
  inherited;
end;

constructor TfrxDBXTable.DesignCreate(AOwner: TComponent; Flags: Word);
var
  i: Integer;
  l: TList;
begin
  inherited;
  l := Report.AllObjects;
  for i := 0 to l.Count - 1 do
    if TObject(l[i]) is TfrxDBXDatabase then
    begin
      SetDatabase(TfrxDBXDatabase(l[i]));
      break;
    end;
end;

class function TfrxDBXTable.GetDescription: String;
begin
  Result := frxResources.Get('obDBXTb');
end;

procedure TfrxDBXTable.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FDatabase) then
    SetDatabase(nil);
end;

procedure TfrxDBXTable.SetDatabase(const Value: TfrxDBXDatabase);
begin
  FDatabase := Value;
  if Value <> nil then
    FTable.SQLConnection := Value.Database
  else if DBXComponents <> nil then
    FTable.SQLConnection := DBXComponents.DefaultDatabase
  else
    FTable.SQLConnection := nil;
  DBConnected := FTable.SQLConnection <> nil;
end;

function TfrxDBXTable.GetIndexName: String;
begin
  Result := FTable.IndexName;
end;

function TfrxDBXTable.GetIndexFieldNames: String;
begin
  Result := FTable.IndexFieldNames;
end;

function TfrxDBXTable.GetTableName: String;
begin
  Result := FTable.TableName;
end;

procedure TfrxDBXTable.SetIndexName(const Value: String);
begin
  FTable.IndexName := Value;
end;

procedure TfrxDBXTable.SetIndexFieldNames(const Value: String);
begin
  FTable.IndexFieldNames := Value;
end;

procedure TfrxDBXTable.SetTableName(const Value: String);
begin
  FTable.TableName := Value;
end;

procedure TfrxDBXTable.SetMaster(const Value: TDataSource);
begin
  FTable.MasterSource := Value;
end;

procedure TfrxDBXTable.SetMasterFields(const Value: String);
begin
  FTable.MasterFields := Value;
end;

procedure TfrxDBXTable.BeforeStartReport;
begin
  SetDatabase(FDatabase);
end;


{ TfrxDBXQuery }

constructor TfrxDBXQuery.Create(AOwner: TComponent);
begin
  FStrings := TStringList.Create;
  FQuery := TSQLQuery.Create(nil);
  DataSet := FQuery;
  SetDatabase(nil);
  inherited;
  FImageIndex := 59;
end;

destructor TfrxDBXQuery.Destroy;
begin
  FStrings.Free;
  inherited;
end;

constructor TfrxDBXQuery.DesignCreate(AOwner: TComponent; Flags: Word);
var
  i: Integer;
  l: TList;
begin
  inherited;
  l := Report.AllObjects;
  for i := 0 to l.Count - 1 do
    if TObject(l[i]) is TfrxDBXDatabase then
    begin
      SetDatabase(TfrxDBXDatabase(l[i]));
      break;
    end;
end;

class function TfrxDBXQuery.GetDescription: String;
begin
  Result := frxResources.Get('obDBXQ');
end;

procedure TfrxDBXQuery.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FDatabase) then
    SetDatabase(nil);
end;

procedure TfrxDBXQuery.SetDatabase(const Value: TfrxDBXDatabase);
begin
  FDatabase := Value;
  if Value <> nil then
    FQuery.SQLConnection := Value.Database
  else if DBXComponents <> nil then
    FQuery.SQLConnection := DBXComponents.DefaultDatabase
  else
    FQuery.SQLConnection := nil;
  DBConnected := FQuery.SQLConnection <> nil;
end;

function TfrxDBXQuery.GetSQL: TStrings;
begin
  FLock := True;
  FStrings.Assign(FQuery.SQL);
  FLock := False;
  Result := FStrings;
end;

procedure TfrxDBXQuery.SetSQL(Value: TStrings);
begin
  FQuery.SQL.Assign(Value);
  FStrings.Assign(Value);
end;

procedure TfrxDBXQuery.SetMaster(const Value: TDataSource);
begin
  FQuery.DataSource := Value;
end;

procedure TfrxDBXQuery.UpdateParams;
begin
  frxParamsToTParams(Self, FQuery.Params);
end;

procedure TfrxDBXQuery.BeforeStartReport;
begin
  SetDatabase(FDatabase);
end;

procedure TfrxDBXQuery.OnChangeSQL(Sender: TObject);
begin
  if not FLock then
  begin
    FQuery.SQL.Assign(FStrings);
    inherited;
  end;
end;

{$IFDEF QBUILDER}
function TfrxDBXQuery.QBEngine: TfqbEngine;
begin
  Result := TfrxEngineDBX.Create(nil);
  TfrxEngineDBX(Result).FQuery.SQLConnection := FQuery.SQLConnection;
end;
{$ENDIF}


{$IFDEF QBUILDER}
constructor TfrxEngineDBX.Create(AOwner: TComponent);
begin
  inherited;
  FQuery := TSQLQuery.Create(nil);
  FDBXDataset := TfrxDBXDataset.Create(nil);
  FDBXDataset.Dataset := FQuery;
end;

destructor TfrxEngineDBX.Destroy;
begin
  FQuery.Free;
  FDBXDataset.Free;
  inherited;
end;

procedure TfrxEngineDBX.ReadFieldList(const ATableName: string;
  var AFieldList: TfqbFieldList);
var
  TempTable: TSQLTable;
  Fields: TFieldDefs;
  i: Integer;
  tmpField: TfqbField;
begin
  AFieldList.Clear;
  TempTable := TSQLTable.Create(Self);
  TempTable.SQLConnection := FQuery.SQLConnection;
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

procedure TfrxEngineDBX.ReadTableList(ATableList: TStrings);
begin
  ATableList.Clear;
  FQuery.SQLConnection.GetTableNames(ATableList, ShowSystemTables);
end;

function TfrxEngineDBX.ResultDataSet: TDataSet;
begin
  Result := FDBXDataset;
end;

procedure TfrxEngineDBX.SetSQL(const Value: string);
begin
  FQuery.SQL.Text := Value;
end;
{$ENDIF}



initialization
  frxObjects.RegisterObject1(TfrxDBXDataBase, nil, '', '', 0, 57);
  frxObjects.RegisterObject1(TfrxDBXTable, nil, '', '', 0, 58);
  frxObjects.RegisterObject1(TfrxDBXQuery, nil, '', '', 0, 59);

finalization
  frxObjects.UnRegister(TfrxDBXDataBase);
  frxObjects.UnRegister(TfrxDBXTable);
  frxObjects.UnRegister(TfrxDBXQuery);


end.