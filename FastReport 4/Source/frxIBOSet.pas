
{******************************************}
{                                          }
{             FastReport v4.0              }
{             IBO DB dataset               }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxIBOSet;

interface

{$I frx.inc}

uses
  SysUtils, Windows, Messages, Classes, frxClass, IB_Components, IB_Header
{$IFDEF Delphi6}
, Variants
{$ENDIF};

type
  TfrxIBODataset = class(TfrxCustomDBDataset)
  private
    FBookmark: String;
    FDataSet: TIB_DataSet;
    FDataSource: TIB_DataSource;
    FEof: Boolean;
    procedure SetDataSet(Value: TIB_DataSet);
    procedure SetDataSource(Value: TIB_DataSource);
    function DataSetActive: Boolean;
    function IsDataSetStored: Boolean;
  protected
    FDS: TIB_DataSet;
    function GetDisplayText(Index: String): WideString; override;
    function GetDisplayWidth(Index: String): Integer; override;
    function GetFieldType(Index: String): TfrxFieldType; override;
    function GetValue(Index: String): Variant; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    procedure Initialize; override;
    procedure Finalize; override;
    procedure First; override;
    procedure Next; override;
    procedure Prior; override;
    procedure Open; override;
    procedure Close; override;
    function Eof: Boolean; override;

    function GetDataSet: TIB_DataSet;
    function IsBlobField(const fName: String): Boolean; override;
    procedure AssignBlobTo(const fName: String; Obj: TObject); override;
    procedure GetFieldList(List: TStrings); override;
  published
    property DataSet: TIB_DataSet read FDataSet write SetDataSet stored IsDataSetStored;
    property DataSource: TIB_DataSource read FDataSource write SetDataSource stored IsDataSetStored;
  end;


implementation

uses frxUtils, frxRes, frxUnicodeUtils;

type
  EDSError = class(Exception);


{ TfrxIBODataset }

procedure TfrxIBODataset.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if Operation = opRemove then
    if AComponent = FDataSource then
      DataSource := nil
    else if AComponent = FDataSet then
      DataSet := nil
end;

procedure TfrxIBODataset.SetDataSet(Value: TIB_DataSet);
begin
  FDataSet := Value;
  if Value <> nil then
    FDataSource := nil;
  FDS := GetDataSet;
end;

procedure TfrxIBODataset.SetDataSource(Value: TIB_DataSource);
begin
  FDataSource := Value;
  if Value <> nil then
    FDataSet := nil;
  FDS := GetDataSet;
end;

function TfrxIBODataset.DataSetActive: Boolean;
begin
  Result := (FDS <> nil) and FDS.Active;
end;

function TfrxIBODataset.GetDataset: TIB_DataSet;
begin
  if FDataSet <> nil then
    Result := FDataSet
  else if (FDataSource <> nil) and (FDataSource.DataSet <> nil) then
    Result := FDataSource.DataSet
  else
    Result := nil;
end;

function TfrxIBODataset.IsDataSetStored: Boolean;
begin
  Result := Report = nil;
end;

procedure TfrxIBODataset.Initialize;
begin
  if FDS = nil then
    raise Exception.Create(Format(frxResources.Get('dbNotConn'), [Name]));

  FEof := False;
  FInitialized := False;
end;

procedure TfrxIBODataset.Finalize;
begin
  if FDS = nil then Exit;
  if FBookMark <> '' then
    FDS.Bookmark := FBookmark;
  FBookMark := '';

  if CloseDataSource then
    Close;
  FInitialized := False;
end;

procedure TfrxIBODataset.Open;
var
  i: Integer;
begin
  if FInitialized then
    Exit;

  FInitialized := True;
  FDS.Open;
  if (RangeBegin = rbCurrent) or (RangeEnd = reCurrent) then
    FBookmark := FDS.Bookmark else
    FBookmark := '';

  GetFieldList(Fields);
  for i := 0 to Fields.Count - 1 do
    Fields.Objects[i] := FDS.FindField(ConvertAlias(Fields[i]));

  inherited;
end;

procedure TfrxIBODataset.Close;
begin
  inherited;

  if FBookMark <> '' then
    FDS.Bookmark := FBookmark;
  FBookMark := '';

  FInitialized := False;
  FDS.Close;
end;

procedure TfrxIBODataset.First;
begin
  if not FInitialized then
    Open;

  if RangeBegin = rbFirst then
    FDS.First else
    FDS.Bookmark := FBookmark;
  FEof := False;
  inherited First;
end;

procedure TfrxIBODataset.Next;
begin
  if not FInitialized then
    Open;

  FEof := False;
  if RangeEnd = reCurrent then
  begin
    if FDS.Bookmark = FBookmark then
      FEof := True;
    Exit;
  end;
  if not Eof then FDS.Next;
  inherited Next;
end;

procedure TfrxIBODataset.Prior;
begin
  if not FInitialized then
    Open;

  FDS.Prior;
  inherited Prior;
end;

function TfrxIBODataset.Eof: Boolean;
begin
  if not FInitialized then
    Open;

  Result := inherited Eof or FDS.Eof or FEof;
  if FDS.Eof then
  begin
    if not FDS.Bof then 
    try
      FDS.Prior;
    except
    end;
    FEof := True;
  end;
end;

function TfrxIBODataset.GetDisplayText(Index: String): WideString;
var
  i: Integer;
begin
  if not FInitialized then
    Open;

  if DataSetActive then
    if Fields.Count = 0 then
      Result := FDS.FieldByName(Index).DisplayText
    else
    begin
      i := Fields.IndexOf(Index);
      if i <> -1 then
        Result := TIB_Column(Fields.Objects[i]).DisplayText
      else
      begin
        Result := frxResources.Get('dbFldNotFound') + ' ' + UserName + '."' +
          Index + '"';
        ReportRef.Errors.Add(ReportRef.CurObject + ': ' + Result);
      end;
    end
  else
    Result := UserName + '."' + Index + '"';
end;

function TfrxIBODataset.GetValue(Index: String): Variant;
var
  i: Integer;
  f: TIB_Column;
begin
  if not FInitialized then
    Open;

  i := Fields.IndexOf(Index);
  if i <> -1 then
  begin
    f := TIB_Column(Fields.Objects[i]);
    if f.IsCurrencyDataType then
      Result := f.AsCurrency
    else
      Result := f.Value
  end
  else
  begin
    Result := Null;
    ReportRef.Errors.Add(ReportRef.CurObject + ': ' +
      frxResources.Get('dbFldNotFound') + ' ' + UserName + '."' + Index + '"');
  end;
end;

function TfrxIBODataset.GetDisplayWidth(Index: String): Integer;
var
  f: TIB_Column;
//  fDef: TFieldDef;
begin
  Result := 10;
  Index := ConvertAlias(Index);
  f := FDS.FindField(Index);
  if f <> nil then
    Result := f.DisplayWidth div 7
{  else
  begin
    try
      if not FDS.FieldDefs.Updated then
        FDS.FieldDefs.Update;
    except
    end;
    fDef := FDS.FieldDefs.Find(Index);
    if fDef <> nil then
      case fDef.DataType of
        ftString:   Result := fDef.Size;
        ftLargeInt: Result := 15;
        ftDateTime: Result := 20;
      end;
  end;}
end;

function TfrxIBODataset.GetFieldType(Index: String): TfrxFieldType;
var
  f: TIB_Column;
begin
  Result := fftNumeric;
  f := FDS.FindField(ConvertAlias(Index));
  if f <> nil then
    if (f.SqlType = SQL_TEXT) or (f.SqlType = SQL_TEXT_) or
       (f.SqlType = SQL_VARYING) or (f.SqlType = SQL_VARYING_) then
      Result := fftString
    else if f.IsBoolean then
      Result := fftBoolean;
end;

procedure TfrxIBODataset.AssignBlobTo(const fName: String; Obj: TObject);
var
  Field: TIB_Column;
  BlobStream: TStream;
  sl: TStringList;
begin
  if not FInitialized then
    Open;
  Field := TIB_Column(Fields.Objects[Fields.IndexOf(fName)]);

  if Obj is TWideStrings then
  begin
    BlobStream := TMemoryStream.Create;
    sl := TStringList.Create;
    try
      Field.AssignTo(BlobStream);
      BlobStream.Position := 0;
      sl.LoadFromStream(BlobStream);
      TWideStrings(Obj).Assign(sl);
    finally
      BlobStream.Free;
      sl.Free;
    end;
  end
  else if Obj is TStream then
  begin
    Field.AssignTo(Obj);
    TStream(Obj).Position := 0;
  end;
end;

procedure TfrxIBODataset.GetFieldList(List: TStrings);
var
  i: Integer;
  tempList: TStringList;
begin
  List.Clear;
  tempList := TStringList.Create;

  if FieldAliases.Count = 0 then
  begin
    if FDS <> nil then
      try
        FDS.Prepare;
        FDS.GetFieldNamesList(tempList);
        for i := 0 to tempList.Count - 1 do
          List.Add(Copy(tempList[i], Pos('.', tempList[i]) + 1, 255));
      except
      end;
  end
  else
  begin
    for i := 0 to FieldAliases.Count - 1 do
      List.Add(FieldAliases.Values[FieldAliases.Names[i]]);
  end;

  tempList.Free;
end;

function TfrxIBODataset.IsBlobField(const fName: String): Boolean;
var
  Field: TIB_Column;
  i: Integer;
begin
  if not FInitialized then
    Open;

  Result := False;
  i := Fields.IndexOf(fName);
  if i <> -1 then
  begin
    Field := TIB_Column(Fields.Objects[i]);
    Result := (Field <> nil) and (Field.SQLType >= 520) and (Field.SQLType <= 541);
  end;
end;


end.


//0f31356a91fea3356e5f76cdce90aa7b