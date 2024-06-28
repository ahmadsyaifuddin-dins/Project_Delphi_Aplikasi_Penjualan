
{******************************************}
{                                          }
{             FastReport v4.0              }
{      BDE components design editors       }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxBDEEditor;

interface

{$I frx.inc}

implementation

uses
  Windows, Classes, frxBDEComponents, frxCustomDB, frxDsgnIntf, DB, DBTables
{$IFDEF Delphi6}
, Variants
{$ENDIF};


type
  TfrxAliasNameProperty = class(TfrxStringProperty)
  public
    function GetAttributes: TfrxPropertyAttributes; override;
    procedure GetValues; override;
  end;

  TfrxDriverNameProperty = class(TfrxStringProperty)
  public
    function GetAttributes: TfrxPropertyAttributes; override;
    procedure GetValues; override;
  end;

  TfrxDataBaseNameProperty = class(TfrxStringProperty)
  public
    function GetAttributes: TfrxPropertyAttributes; override;
    procedure GetValues; override;
  end;

  TfrxSessionNameProperty = class(TfrxStringProperty)
  public
    function GetAttributes: TfrxPropertyAttributes; override;
    procedure GetValues; override;
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


{ TfrxAliasNameProperty }

function TfrxAliasNameProperty.GetAttributes: TfrxPropertyAttributes;
begin
  Result := [paMultiSelect, paValueList, paSortList];
end;

procedure TfrxAliasNameProperty.GetValues;
begin
  inherited;
  Session.GetAliasNames(Values);
end;


{ TfrxDriverNameProperty }

function TfrxDriverNameProperty.GetAttributes: TfrxPropertyAttributes;
begin
  Result := [paMultiSelect, paValueList, paSortList];
end;

procedure TfrxDriverNameProperty.GetValues;
begin
  inherited;
  Session.GetDriverNames(Values);
end;


{ TfrxDataBaseNameProperty }

function TfrxDataBaseNameProperty.GetAttributes: TfrxPropertyAttributes;
begin
  Result := [paMultiSelect, paValueList];
end;

procedure TfrxDataBaseNameProperty.GetValues;
var
  Session: TSession;
begin
  inherited;
  Session := Sessions.FindSession(TDBDataSet(TfrxCustomDataset(Component).DataSet).SessionName);
  if Session <> nil then
    Session.GetAliasNames(Values);
end;


{ TfrxSessionNameProperty }

function TfrxSessionNameProperty.GetAttributes: TfrxPropertyAttributes;
begin
  Result := [paMultiSelect, paValueList];
end;

procedure TfrxSessionNameProperty.GetValues;
begin
  Sessions.GetSessionNames(Values);
end;


{ TfrxTableNameProperty }

function TfrxTableNameProperty.GetAttributes: TfrxPropertyAttributes;
begin
  Result := [paMultiSelect, paValueList, paSortList];
end;

procedure TfrxTableNameProperty.GetValues;
var
  t: TTable;
  Session: TSession;
begin
  inherited;
  t := TfrxBDETable(Component).Table;
  Session := Sessions.FindSession(t.SessionName);
  if (Session <> nil) and (t.DatabaseName <> '') then
    try
      Session.GetTableNames(t.DatabaseName, '', True, False, Values);
    except
    end;
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
    with TfrxBDETable(Component).Table do
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
  frxPropertyEditors.Register(TypeInfo(String), TfrxBDEDatabase, 'AliasName',
    TfrxAliasNameProperty);
  frxPropertyEditors.Register(TypeInfo(String), TfrxBDEDatabase, 'DriverName',
    TfrxDriverNameProperty);
  frxPropertyEditors.Register(TypeInfo(String), TfrxBDETable, 'DatabaseName',
    TfrxDataBaseNameProperty);
  frxPropertyEditors.Register(TypeInfo(String), TfrxBDETable, 'SessionName',
    TfrxSessionNameProperty);
  frxPropertyEditors.Register(TypeInfo(String), TfrxBDETable, 'TableName',
    TfrxTableNameProperty);
  frxPropertyEditors.Register(TypeInfo(String), TfrxBDETable, 'IndexName',
    TfrxIndexNameProperty);
  frxPropertyEditors.Register(TypeInfo(String), TfrxBDEQuery, 'DatabaseName',
    TfrxDataBaseNameProperty);
  frxPropertyEditors.Register(TypeInfo(String), TfrxBDEQuery, 'SessionName',
    TfrxSessionNameProperty);

end.
