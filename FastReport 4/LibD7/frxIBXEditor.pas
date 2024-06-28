
{******************************************}
{                                          }
{             FastReport v4.0              }
{      IBX components design editors       }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxIBXEditor;

interface

{$I frx.inc}

implementation

uses
  Windows, Classes, SysUtils, Forms, Dialogs, frxIBXComponents, frxCustomDB,
  frxDsgnIntf, frxRes, IBDatabase, IBTable
{$IFDEF Delphi6}
, Variants
{$ENDIF};


type
  TfrxDatabaseNameProperty = class(TfrxStringProperty)
  public
    function GetAttributes: TfrxPropertyAttributes; override;
    function Edit: Boolean; override;
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


{ TfrxDatabaseNameProperty }

function TfrxDatabaseNameProperty.GetAttributes: TfrxPropertyAttributes;
begin
  Result := [paDialog];
end;

function TfrxDatabaseNameProperty.Edit: Boolean;
var
  SaveConnected: Boolean;
begin
  with TOpenDialog.Create(nil) do
  begin
    InitialDir := GetCurrentDir;
    Filter := frxResources.Get('ftDB') + ' (*.gdb)|*.gdb|' +
      frxResources.Get('ftAllFiles') + ' (*.*)|*.*';
    Result := Execute;
    if Result then
      with TfrxIBXDatabase(Component).Database do
      begin
        SaveConnected := Connected;
        Connected := False;
        DatabaseName := FileName;
        Connected := SaveConnected;
      end;
    Free;
  end;
end;


{ TfrxDatabaseProperty }

function TfrxDatabaseProperty.GetValue: String;
var
  db: TfrxIBXDatabase;
begin
  db := TfrxIBXDatabase(GetOrdValue);
  if db = nil then
  begin
    if (IBXComponents <> nil) and (IBXComponents.DefaultDatabase <> nil) then
      Result := IBXComponents.DefaultDatabase.Name
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
  with TfrxIBXTable(Component).Table do
    if Database <> nil then
      DataBase.GetTableNames(Values, False);
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
    with TfrxIBXTable(Component).Table do
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
  frxPropertyEditors.Register(TypeInfo(String), TfrxIBXDataBase, 'DatabaseName',
    TfrxDataBaseNameProperty);
  frxPropertyEditors.Register(TypeInfo(TfrxIBXDatabase), TfrxIBXTable, 'Database',
    TfrxDatabaseProperty);
  frxPropertyEditors.Register(TypeInfo(TfrxIBXDatabase), TfrxIBXQuery, 'Database',
    TfrxDatabaseProperty);
  frxPropertyEditors.Register(TypeInfo(String), TfrxIBXTable, 'TableName',
    TfrxTableNameProperty);
  frxPropertyEditors.Register(TypeInfo(String), TfrxIBXTable, 'IndexName',
    TfrxIndexNameProperty);

end.
