
{******************************************}
{                                          }
{             FastReport v4.0              }
{              Picture Cache               }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxPictureCache;

interface

{$I frx.inc}

uses
  Windows, SysUtils, Messages, Classes, Graphics, Controls, Forms, Dialogs,
  frxClass, frxXML
{$IFDEF Delphi6}
, Variants
{$ENDIF};


type
  TfrxPictureCache = class(TObject)
  private
    FIndex: TStringList;
    function Add: TStream;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure AddPicture(Picture: TfrxPictureView);
    procedure GetPicture(Picture: TfrxPictureView);
    procedure SaveToXML(Item: TfrxXMLItem);
    procedure LoadFromXML(Item: TfrxXMLItem);
  end;


implementation

uses
  frxUtils;


{ TfrxPictureCache }

constructor TfrxPictureCache.Create;
begin
  FIndex := TStringList.Create;
end;

destructor TfrxPictureCache.Destroy;
begin
  Clear;
  FIndex.Free;
  inherited;
end;

procedure TfrxPictureCache.Clear;
begin
  while FIndex.Count > 0 do
  begin
    TStream(FIndex.Objects[0]).Free;
    FIndex.Delete(0);
  end;
end;

function TfrxPictureCache.Add: TStream;
begin
  Result := TMemoryStream.Create;
  FIndex.AddObject('', Result);
end;

procedure TfrxPictureCache.AddPicture(Picture: TfrxPictureView);
begin
  if Picture.Picture.Graphic = nil then
    Picture.ImageIndex := 0
  else
  begin
    Picture.ImageIndex := FIndex.Count + 1;
    Picture.Picture.Graphic.SaveToStream(Add);
  end;
end;

procedure TfrxPictureCache.GetPicture(Picture: TfrxPictureView);
var
  s: TStream;
begin
  if (Picture.ImageIndex <= 0) or (Picture.ImageIndex > FIndex.Count) then
    Picture.Picture.Assign(nil)
  else
  begin
    s := TStream(FIndex.Objects[Picture.ImageIndex - 1]);
    s.Position := 0;
    Picture.LoadPictureFromStream(s);
  end;
end;

procedure TfrxPictureCache.LoadFromXML(Item: TfrxXMLItem);
var
  i: Integer;
  xi: TfrxXMLItem;
begin
  Clear;
  for i := 0 to Item.Count - 1 do
  begin
    xi := Item[i];
    frxStringToStream(xi.Prop['stream'], Add);
  end;
end;

procedure TfrxPictureCache.SaveToXML(Item: TfrxXMLItem);
var
  i: Integer;
  s: TStream;
  xi: TfrxXMLItem;
begin
  Item.Clear;
  for i := 0 to FIndex.Count - 1 do
  begin
    xi := Item.Add;
    s := TStream(FIndex.Objects[i]);
    s.Position := 0;
    xi.Name := 'item';
    xi.Text := 'stream="' + frxStreamToString(s) + '"';
  end;
end;

end.


//0f31356a91fea3356e5f76cdce90aa7b