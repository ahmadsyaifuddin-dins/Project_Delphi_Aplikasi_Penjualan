
{******************************************}
{                                          }
{             FastReport v4.0              }
{      DBX components design editors       }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxDBXEditor;

interface

{$I frx.inc}

implementation

uses
  Windows, Classes, SysUtils, Forms, Dialogs, frxDBXComponents, frxCustomDB,
  frxDsgnIntf, frxRes, DBXpress, SqlExpr
{$IFDEF Delphi6}
, Variants
{$ENDIF};


type
  TfrxConnectionNameProperty = class(TfrxStringProperty)
  public
    function GetAttributes: TfrxPropertyAttributes; override;
    procedure GetValues; override;
  end;

  TfrxDriverNameProperty = class(TfrxStringProperty)
  public
    function GetAttributes: TfrxPropertyAttributes; override;
    procedure GetValues; override;
  end;

  TfrxDatabaseProperty = class(TfrxComponentProperty)
  public
    function GetValue: String; override;
  end;

  TfrxTableNameProperty = class(TfrxStringProperty)
  public
    function GetAttributes: TfrxPropertyAttributes; override;
    procedure GetValues; override;
    procedure SetValue(const Value: String); override;
  end;

  TfrxIndexNameProperty = class(TfrxStringProperty)
  public
    function GetAttributes: TfrxPropertyAttributes; override;
    procedure GetValues; override;
  end;


{ TfrxConnectionNameProperty }

function TfrxConnectionNameProperty.GetAttributes: TfrxPropertyAttributes;
begin
  Result := [paMultiSelect, paValueList];
end;

procedure TfrxConnectionNameProperty.GetValues;
begin
  inherited;
  GetConnectionNames(Values);
end;


{ TfrxDriverNameProperty }

function TfrxDriverNameProperty.GetAttributes: TfrxPropertyAttributes;
begin
  Result := [paMultiSelect, paValueList];
end;

procedure TfrxDriverNameProperty.GetValues;
begin
  inherited;
  GetDriverNames(Values);
end;


{ TfrxDatabaseProperty }

function TfrxDatabaseProperty.GetValue: String;
var
  db: TfrxDBXDatabase;
begin
  db := TfrxDBXDatabase(GetOrdValue);
  if db = nil then
  begin
    if (DBXComponents <> nil) and (DBXComponents.DefaultDatabase <> nil) then
      Result := DBXComponents.DefaultDatabase.Name
    else
      Result := frxResources.Get('prNotAssigned');
  end
  else
    Result := inherited GetValue;
end;


{ TfrxTableNameProperty }

function TfrxTableNameProperty.GetAttributes: TfrxPropertyAttributes;
begin
  Result := [paMultiSelect, paValueList, paSortList];
end;

procedure TfrxTableNameProperty.GetValues;
begin
  inherited;
  with TfrxDBXTable(Component).Table do
    if SQLConnection <> nil then
      SQLConnection.GetTableNames(Values, False);
end;

procedure TfrxTableNameProperty.SetValue(const Value: String);
begin
  inherited;
  Designer.UpdateDataTree;
end;


{ TfrxIndexProperty }

function TfrxIndexNameProperty.GetAttributes: TfrxPropertyAttributes;
begin
  Result := [paMultiSelect, paValueList];
end;

procedure TfrxIndexNameProperty.GetValues;
var
  i: Integer;
begin
  inherited;
  try
    with TfrxDBXTable(Component).Table do
      if (TableName <> '') and (IndexDefs <> nil) then
      begin
        IndexDefs.Update;
        for i := 0 to IndexDefs.Count - 1 do
          if IndexDefs[i].Name <> '' then
            Values.Add(IndexDefs[i].Name);
      end;
  except
  end;
end;


initialization
  frxPropertyEditors.Register(TypeInfo(String), TfrxDBXDataBase, 'ConnectionName',
    TfrxConnectionNameProperty);
  frxPropertyEditors.Register(TypeInfo(String), TfrxDBXDataBase, 'DriverName',
    TfrxDriverNameProperty);
  frxPropertyEditors.Register(TypeInfo(TfrxDBXDatabase), TfrxDBXTable, 'Database',
    TfrxDatabaseProperty);
  frxPropertyEditors.Register(TypeInfo(TfrxDBXDatabase), TfrxDBXQuery, 'Database',
    TfrxDatabaseProperty);
  frxPropertyEditors.Register(TypeInfo(String), TfrxDBXTable, 'TableName',
    TfrxTableNameProperty);
  frxPropertyEditors.Register(TypeInfo(String), TfrxDBXTable, 'IndexName',
    TfrxIndexNameProperty);

end.
