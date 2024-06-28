{******************************************}
{                                          }
{             FastReport v3.0              }
{      Language resources management       }
{                                          }
{         Copyright (c) 1998-2005          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit fqbRes;

interface

{$I fqb.inc}

uses
  Windows, SysUtils, Classes, Controls, Graphics, Forms, ImgList, TypInfo
{$IFDEF Delphi6}
, Variants
{$ENDIF};


type
  TfqbResources = class(TObject)
  private
    FNames: TStringList;
    FValues: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    function Get(const StrName: String): String;
    procedure Add(const Ref, Str: String);
    procedure AddStrings(const Str: String);
    procedure Clear;
    procedure LoadFromFile(const FileName: String);
    procedure LoadFromStream(Stream: TStream);
  end;

function fqbResources: TfqbResources;
function fqbGet(ID: Integer): String;


implementation

var
  FResources: TfqbResources = nil;

{ TfrxResources }

constructor TfqbResources.Create;
begin
  inherited;
  FNames := TStringList.Create;
  FValues := TStringList.Create;
  FNames.Sorted := True;
end;

destructor TfqbResources.Destroy;
begin
  FNames.Free;
  FValues.Free;
  inherited;
end;

procedure TfqbResources.Add(const Ref, Str: String);
var
  i: Integer;
begin
  i := FNames.IndexOf(Ref);
  if i = -1 then
  begin
    FNames.AddObject(Ref, Pointer(FValues.Count));
    FValues.Add(Str);
  end
  else
    FValues[Integer(FNames.Objects[i])] := Str;
end;

procedure TfqbResources.AddStrings(const Str: String);
var
  i: Integer;
  sl: TStringList;
  nm, vl: String;
begin
  sl := TStringList.Create;
  sl.Text := Str;
  for i := 0 to sl.Count - 1 do
  begin
//    nm := sl[i];
    nm := sl.Names[i];//  Copy(nm, Pos('=', nm) + 1, MaxInt);
    vl := sl.Values[nm];// Copy(nm, 1, Pos('=', nm) - 1);
    if (nm <> '') and (vl <> '') then
      Add(nm, vl);
  end;
  sl.Free;
end;

procedure TfqbResources.Clear;
begin
  FNames.Clear;
  FValues.Clear;
end;

function TfqbResources.Get(const StrName: String): String;
var
  i: Integer;
begin
  i := FNames.IndexOf(StrName);
  if i <> -1 then
    Result := FValues[Integer(FNames.Objects[i])] else
    Result := StrName;
end;

procedure TfqbResources.LoadFromFile(const FileName: String);
var
  f: TFileStream;
begin
  f := TFileStream.Create(FileName, fmOpenRead);
  try
    LoadFromStream(f);
  finally
    f.Free;
  end;
end;

procedure TfqbResources.LoadFromStream(Stream: TStream);
var
  sl: TStringList;
  i: Integer;
  nm, vl: String;
begin
  sl := TStringList.Create;
  try
    sl.LoadFromStream(Stream);
    Clear;
    for i := 0 to sl.Count - 1 do
    begin
      nm := sl[i];
      vl := Copy(nm, Pos('=', nm) + 1, MaxInt);
      nm := Copy(nm, 1, Pos('=', nm) - 1);
      if (nm <> '') and (vl <> '') then
        Add(nm, vl);
    end;
  finally
    sl.Free;
  end
end;


function fqbResources: TfqbResources;
begin
  if FResources = nil then
    FResources := TfqbResources.Create;
  Result := FResources;
end;

function fqbGet(ID: Integer): String;
begin
  Result := fqbResources.Get(IntToStr(ID));
end;


initialization

finalization
  if FResources <> nil then
    FResources.Free;
  FResources := nil;

end.
