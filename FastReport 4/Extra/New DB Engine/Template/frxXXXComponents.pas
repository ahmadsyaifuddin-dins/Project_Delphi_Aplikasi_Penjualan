
{******************************************}
{                                          }
{             FastReport v3.0              }
{         XXX enduser components           }
{                                          }

// Copyright
{                                          }
{******************************************}

unit frxXXXComponents;

interface

{$I frx.inc}

uses
  Windows, Classes, frxClass, frxCustomDB, DB, UXXX
{$IFDEF Delphi6}
, Variants
{$ENDIF}
{$IFDEF QBUILDER}
, fqbClass
{$ENDIF};


type
  TfrxXXXComponents = class(TfrxDBComponents)
  private
    FDefaultDatabase: TXXXDatabase;
    FOldComponents: TfrxXXXComponents;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetDescription: String; override;
  published
    property DefaultDatabase: TXXXDatabase read FDefaultDatabase write FDefaultDatabase;
  end;

  TfrxXXXDatabase = class(TfrxCustomDatabase)
  private
    FDatabase: TXXXDatabase;
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
    property Database: TXXXDatabase read FDatabase;
  published
    property DatabaseName;
    property LoginPrompt;
    property Params;
    property Connected;
  end;

  TfrxXXXTable = class(TfrxCustomTable)
  private
    FDatabase: TfrxXXXDatabase;
    FTable: TXXXTable;
    procedure SetDatabase(const Value: TfrxXXXDatabase);
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
    property Table: TXXXTable read FTable;
  published
    property Database: TfrxXXXDatabase read FDatabase write SetDatabase;
  end;

  TfrxXXXQuery = class(TfrxCustomQuery)
  private
    FDatabase: TfrxXXXDatabase;
    FQuery: TXXXQuery;
    procedure SetDatabase(const Value: TfrxXXXDatabase);
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
    property Query: TXXXQuery read FQuery;
  published
    property Database: TfrxXXXDatabase read FDatabase write SetDatabase;
  end;

{$IFDEF QBUILDER}
  TfrxEngineXXX = class(TfqbEngine)
  private
    FQuery: TXXXQuery;
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
  XXXComponents: TfrxXXXComponents;


implementation

{$R *.res}

uses 
  frxXXXRTTI, 
{$IFNDEF NO_EDITORS}
  frxXXXEditor, 
{$ENDIF}
  frxDsgnIntf, frxRes;


{ TfrxXXXComponents }

constructor TfrxXXXComponents.Create(AOwner: TComponent);
begin
  inherited;
  FOldComponents := XXXComponents;
  XXXComponents := Self;
end;

destructor TfrxXXXComponents.Destroy;
begin
  if XXXComponents = Self then
    XXXComponents := FOldComponents;
  inherited;
end;

function TfrxXXXComponents.GetDescription: String;
begin
  Result := 'XXX';
end;


{ TfrxXXXDatabase }

constructor TfrxXXXDatabase.Create(AOwner: TComponent);
begin
  inherited;
  FDatabase := TXXXDatabase.Create(nil);
  Component := FDatabase;
end;

destructor TfrxXXXDatabase.Destroy;
begin
  inherited;
end;

class function TfrxXXXDatabase.GetDescription: String;
begin
  Result := 'XXX Database';
end;

function TfrxXXXDatabase.GetConnected: Boolean;
begin
  Result := FDatabase.Connected;
end;

function TfrxXXXDatabase.GetDatabaseName: String;
begin
  Result := FDatabase.DatabaseName;
end;

function TfrxXXXDatabase.GetLoginPrompt: Boolean;
begin
  Result := FDatabase.LoginPrompt;
end;

function TfrxXXXDatabase.GetParams: TStrings;
begin
  Result := FDatabase.Params;
end;

procedure TfrxXXXDatabase.SetConnected(Value: Boolean);
begin
  BeforeConnect(Value);
  FDatabase.Connected := Value;
end;

procedure TfrxXXXDatabase.SetDatabaseName(const Value: String);
begin
  FDatabase.DatabaseName := Value;
end;

procedure TfrxXXXDatabase.SetLoginPrompt(Value: Boolean);
begin
  FDatabase.LoginPrompt := Value;
end;

procedure TfrxXXXDatabase.SetParams(Value: TStrings);
begin
  FDatabase.Params := Value;
end;

procedure TfrxXXXDatabase.SetLogin(const Login, Password: String);
begin
// this method is used by "New connection" wizard
// for example (IBX):
// Params.Text := 'user_name=' + Login + #13#10 + 'password=' + Password;
end;


{ TfrxXXXTable }

constructor TfrxXXXTable.Create(AOwner: TComponent);
begin
  FTable := TXXXTable.Create(nil);
  DataSet := FTable;
  SetDatabase(nil);
  inherited;
end;

constructor TfrxXXXTable.DesignCreate(AOwner: TComponent; Flags: Word);
var
  i: Integer;
  l: TList;
begin
  inherited;
  l := Report.AllObjects;
  for i := 0 to l.Count - 1 do
    if TObject(l[i]) is TfrxXXXDatabase then
    begin
      SetDatabase(TfrxXXXDatabase(l[i]));
      break;
    end;
end;

class function TfrxXXXTable.GetDescription: String;
begin
  Result := 'XXX Table';
end;

procedure TfrxXXXTable.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FDatabase) then
    SetDatabase(nil);
end;

procedure TfrxXXXTable.SetDatabase(const Value: TfrxXXXDatabase);
begin
  FDatabase := Value;
  if Value <> nil then
    FTable.Database := Value.Database
  else if XXXComponents <> nil then
    FTable.Database := XXXComponents.DefaultDatabase
  else
    FTable.Database := nil;
end;

function TfrxXXXTable.GetIndexFieldNames: String;
begin
  Result := FTable.IndexFieldNames;
end;

function TfrxXXXTable.GetIndexName: String;
begin
  Result := FTable.IndexName;
end;

function TfrxXXXTable.GetTableName: String;
begin
  Result := FTable.TableName;
end;

procedure TfrxXXXTable.SetIndexFieldNames(const Value: String);
begin
  FTable.IndexFieldNames := Value;
end;

procedure TfrxXXXTable.SetIndexName(const Value: String);
begin
  FTable.IndexName := Value;
end;

procedure TfrxXXXTable.SetTableName(const Value: String);
begin
  FTable.TableName := Value;
end;

procedure TfrxXXXTable.SetMaster(const Value: TDataSource);
begin
  FTable.MasterSource := Value;
end;

procedure TfrxXXXTable.SetMasterFields(const Value: String);
begin
  FTable.MasterFields := Value;
end;

procedure TfrxXXXTable.BeforeStartReport;
begin
  SetDatabase(FDatabase);
end;


{ TfrxXXXQuery }

constructor TfrxXXXQuery.Create(AOwner: TComponent);
begin
  FQuery := TXXXQuery.Create(nil);
  Dataset := FQuery;
  SetDatabase(nil);
  inherited;
end;

constructor TfrxXXXQuery.DesignCreate(AOwner: TComponent; Flags: Word);
var
  i: Integer;
  l: TList;
begin
  inherited;
  l := Report.AllObjects;
  for i := 0 to l.Count - 1 do
    if TObject(l[i]) is TfrxXXXDatabase then
    begin
      SetDatabase(TfrxXXXDatabase(l[i]));
      break;
    end;
end;

class function TfrxXXXQuery.GetDescription: String;
begin
  Result := 'XXX Query';
end;

procedure TfrxXXXQuery.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FDatabase) then
    SetDatabase(nil);
end;

procedure TfrxXXXQuery.SetDatabase(const Value: TfrxXXXDatabase);
begin
  FDatabase := Value;
  if Value <> nil then
    FQuery.Database := Value.Database
  else if XXXComponents <> nil then
    FQuery.Database := XXXComponents.DefaultDatabase
  else
    FQuery.Database := nil;
end;

function TfrxXXXQuery.GetSQL: TStrings;
begin
  Result := FQuery.SQL;
end;

procedure TfrxXXXQuery.SetSQL(Value: TStrings);
begin
  FQuery.SQL := Value;
end;

procedure TfrxXXXQuery.SetMaster(const Value: TDataSource);
begin
  FQuery.DataSource := Value;
end;

procedure TfrxXXXQuery.UpdateParams;
begin
  frxParamsToTParams(Self, FQuery.Params);
end;

procedure TfrxXXXQuery.BeforeStartReport;
begin
  SetDatabase(FDatabase);
end;

{$IFDEF QBUILDER}
function TfrxXXXQuery.QBEngine: TfqbEngine;
begin
  Result := TfrxEngineXXX.Create(nil);
  TfrxEngineXXX(Result).FQuery.Database := FQuery.Database;
end;
{$ENDIF}


{$IFDEF QBUILDER}
constructor TfrxEngineXXX.Create(AOwner: TComponent);
begin
  inherited;
  FQuery := TXXXQuery.Create(Self);
end;

destructor TfrxEngineXXX.Destroy;
begin
  FQuery.Free;
  inherited;
end;

procedure TfrxEngineXXX.ReadFieldList(const ATableName: string;
  var AFieldList: TfqbFieldList);
var
  TempTable: TXXXTable;
  Fields: TFieldDefs;
  i: Integer;
  tmpField: TfqbField;
begin
  AFieldList.Clear;
  TempTable := TXXXTable.Create(Self);
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

procedure TfrxEngineXXX.ReadTableList(ATableList: TStrings);
begin
  ATableList.Clear;
  FQuery.Database.GetTableNames(ATableList, ShowSystemTables);
end;

function TfrxEngineXXX.ResultDataSet: TDataSet;
begin
  Result := FQuery;
end;

procedure TfrxEngineXXX.SetSQL(const Value: string);
begin
  FQuery.SQL.Text := Value;
end;
{$ENDIF}


var
  CatBmp: TBitmap;

initialization
  CatBmp := TBitmap.Create;
  CatBmp.LoadFromResourceName(hInstance, 'frxXXX');
  frxObjects.RegisterCategory('XXX', CatBmp, 'XXX Components');
  frxObjects.RegisterObject1(TfrxXXXDataBase, nil, '', 'XXX', 0, 37);
  frxObjects.RegisterObject1(TfrxXXXTable, nil, '', 'XXX', 0, 38);
  frxObjects.RegisterObject1(TfrxXXXQuery, nil, '', 'XXX', 0, 39);

finalization
  CatBmp.Free;
  frxObjects.UnRegister(TfrxXXXDataBase);
  frxObjects.UnRegister(TfrxXXXTable);
  frxObjects.UnRegister(TfrxXXXQuery);


end.