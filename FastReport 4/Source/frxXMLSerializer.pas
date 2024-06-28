
{******************************************}
{                                          }
{             FastReport v4.0              }
{             XML serializer               }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxXMLSerializer;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  TypInfo, frxXML, frxClass
{$IFDEF Delphi6}
, Variants
{$ENDIF};


type
  TfrxGetAncestorEvent = procedure(const ComponentName: String;
    var Ancestor: TPersistent) of object;

{ TfrxXMLSerializer is the XML analogue of the Delphi component streaming -
  TReader and TWriter }

  TfrxXMLSerializer = class(TObject)
  private
    FErrors: TStringList;
    FFixups: TList;
    FOwner: TfrxComponent;
    FReader: TReader;
    FReaderStream: TMemoryStream;
    FSerializeDefaultValues: Boolean;
    FStream: TStream;
    FOnGetAncestor: TfrxGetAncestorEvent;
    procedure AddFixup(Obj: TPersistent; p: PPropInfo; Value: String);
    procedure ClearFixups;
    procedure FixupReferences;
  public
    constructor Create(Stream: TStream);
    destructor Destroy; override;
    function ObjToXML(Obj: TPersistent; const Add: String = ''; Ancestor: TPersistent = nil): String;
    function ReadComponent(Root: TfrxComponent): TfrxComponent;
    function ReadComponentStr(Root: TfrxComponent; s: String; DontFixup: Boolean = False): TfrxComponent;
    function WriteComponentStr(c: TfrxComponent): String;
    procedure ReadRootComponent(Root: TfrxComponent; XMLItem: TfrxXMLItem = nil);
    procedure ReadPersistentStr(Root: TComponent; Obj: TPersistent; const s: String);
    procedure WriteComponent(c: TfrxComponent);
    procedure WriteRootComponent(Root: TfrxComponent; SaveChildren: Boolean = True;
      XMLItem: TfrxXMLItem = nil);
    procedure XMLToObj(const s: String; Obj: TPersistent);
    property Errors: TStringList read FErrors;
    property Owner: TfrxComponent read FOwner write FOwner;
    property Stream: TStream read FStream;
    property SerializeDefaultValues: Boolean read FSerializeDefaultValues
      write FSerializeDefaultValues;
    property OnGetAncestor: TfrxGetAncestorEvent read FOnGetAncestor write FOnGetAncestor;
  end;


implementation

uses frxUtils, frxRes, frxUnicodeUtils;


type
  TfrxFixupItem = class(TObject)
  public
    Obj: TPersistent;
    PropInfo: PPropInfo;
    Value: String;
  end;

  THackComponent = class(TComponent);
  THackPersistent = class(TPersistent);
  THackReader = class(TReader);


{ TfrxXMLSerializer }

constructor TfrxXMLSerializer.Create(Stream: TStream);
begin
  FErrors := TStringList.Create;
  FErrors.Sorted := True;
  FErrors.Duplicates := dupIgnore;
  FFixups := TList.Create;
  FStream := Stream;
  FReaderStream := TMemoryStream.Create;
  FReader := TReader.Create(FReaderStream, 4096);
end;

destructor TfrxXMLSerializer.Destroy;
begin
  FErrors.Free;
  FReader.Free;
  FReaderStream.Free;
  ClearFixups;
  FFixups.Free;
  inherited;
end;

procedure TfrxXMLSerializer.ClearFixups;
begin
  while FFixups.Count > 0 do
  begin
    TfrxFixupItem(FFixups[0]).Free;
    FFixups.Delete(0);
  end;
end;

procedure TfrxXMLSerializer.AddFixup(Obj: TPersistent; p: PPropInfo;
  Value: String);
var
  Item: TfrxFixupItem;
begin
  Item := TfrxFixupItem.Create;
  Item.Obj := Obj;
  Item.PropInfo := p;
  Item.Value := Value;
  FFixups.Add(Item);
end;

procedure TfrxXMLSerializer.FixupReferences;
var
  i: Integer;
  Item: TfrxFixupItem;
  Ref: TObject;
begin
  for i := 0 to FFixups.Count - 1 do
  begin
    Item := FFixups[i];
    Ref := nil;
    if FOwner <> nil then
      Ref := FOwner.FindObject(Item.Value);
    if Ref = nil then
      Ref := frxFindComponent(FOwner, Item.Value);
    if Ref <> nil then
      SetOrdProp(Item.Obj, Item.PropInfo, Integer(Ref));
  end;

  FReader.FixupReferences;
  FReader.EndReferences;
  ClearFixups;
end;

procedure TfrxXMLSerializer.XMLToObj(const s: String; Obj: TPersistent);
var
  i, j, start, len, code: Integer;
  i1, start1, len1: Integer;
  Name, Value: String;
  Obj1: TPersistent;
  p: PPropInfo;
  ps, ps1: PChar;

  procedure DoNonPublishedProps;
  begin
    FReaderStream.Clear;
    frxStringToStream(Value, FReaderStream);
    FReaderStream.Position := 0;
    FReader.Position := 0;

    try
      while FReader.Position < FReaderStream.Size do
        THackReader(FReader).ReadProperty(Obj1);
    except
    end;
  end;

begin
  { speed optimized code. affects the speed of loading prepared page in the preview }
  len := Length(s);
  i := 1;
  ps := PChar(s) - 1;
  while i < len do
  begin
    j := i;
    len1 := len;
    ps1 := ps;
    while (j < len1) and (ps1[j] = ' ') do
      Inc(j);
    start := j;
    while (j < len1) and (ps1[j] <> '=') do
      Inc(j);
    i := j;
    if i < len then
    begin
      j := i - 1;
      while (j > 0) and (ps1[j] = ' ') do
        Dec(j);
      Name := Copy(s, start, j - start + 1);
      if Name = '' then break;
      j := i;
      len1 := len;
      while (j < len1) and (ps1[j] <> '"') do
        Inc(j);
      start := j + 1;
      Inc(j);
      while (j < len1) and (ps1[j] <> '"') do
        Inc(j);
      i := j;
      Value := Copy(s, start, i - start);
      Inc(i);

      Obj1 := Obj;

      { check multiple properties }
      len1 := Length(Name);
      start1 := 1;
      i1 := 1;
      while (i1 < len1) and (Name[i1] <> '.') do
        Inc(i1);
      if i1 < len1 then
      begin
        while i1 < len1 do
        begin
          p := GetPropInfo(Obj1.ClassInfo, Copy(Name, start1, i1 - start1));
          if p = nil then
            break;
          Obj1 := TPersistent(GetOrdProp(Obj1, p));
          start1 := i1 + 1;
          Inc(i1);
          while (i1 < len1) and (Name[i1] <> '.') do
            Inc(i1);
        end;
        Name := Copy(Name, start1, MaxInt);
      end;

      try
        if Length(Name) = 1 then
        begin
          { special properties }
          case Name[1] of
            'x':
              begin
                TfrxCustomMemoView(Obj1).Text := frxXMLToStr(Value);
                continue;
              end;
            'u':
              begin
                TfrxCustomMemoView(Obj1).Text := Utf8Decode(frxXMLToStr(Value));
                continue;
              end;
            'l':
              begin
                TfrxComponent(Obj1).Left := frxStrToFloat(Value);
                continue;
              end;
            't':
              begin
                TfrxComponent(Obj1).Top := frxStrToFloat(Value);
                continue;
              end;
            'w':
              begin
                TfrxComponent(Obj1).Width := frxStrToFloat(Value);
                continue;
              end;
            'h':
              begin
                TfrxComponent(Obj1).Height := frxStrToFloat(Value);
                continue;
              end;
          end;
        end
        else
        begin
          if Name = 'Text' then
          begin
            if Obj1 is TStrings then
            begin
              TStrings(Obj1).Text := frxXMLToStr(Value);
              continue;
            end
            else if Obj1 is TWideStrings then
            begin
              TWideStrings(Obj1).Text := frxXMLToStr(Value);
              continue;
            end
            else if Obj1 is TfrxCustomMemoView then
            begin
              TfrxCustomMemoView(Obj1).Text := Utf8Decode(frxXMLToStr(Value));
              continue;
            end
          end
          else if Name = 'PropData' then
          begin
            DoNonPublishedProps;
            continue;
          end
          else if (Obj1 is TfrxReport) and (Name = 'Name') then
            continue;
        end;

        p := GetPropInfo(Obj1.ClassInfo, Name);
        if p <> nil then
          case p.PropType^.Kind of
            tkInteger, tkSet, tkChar, tkWChar:
              SetOrdProp(Obj1, p, StrToInt(Value));

            tkEnumeration:
              begin
                Val(Value, j, code);
                if code = 0 then
                  SetOrdProp(Obj1, p, j) else
                  SetOrdProp(Obj1, p, GetEnumValue(p.PropType^, Value));
              end;

            tkFloat:
              SetFloatProp(Obj1, p, frxStrToFloat(Value));

            tkString, tkLString, tkWString:
              SetStrProp(Obj1, p, frxXMLToStr(Value));

            tkClass:
              AddFixup(Obj1, p, Value);

            tkVariant:
              SetVariantProp(Obj1, p, frxXMLToStr(Value));
          end;
      except
        on E: Exception do
          FErrors.Add(E.Message);
      end;
    end;
  end;
end;

function TfrxXMLSerializer.ObjToXML(Obj: TPersistent; const Add: String = '';
  Ancestor: TPersistent = nil): String;
var
  TypeInfo: PTypeInfo;
  PropCount: Integer;
  PropList: PPropList;
  i: Integer;
  s: String;
  ws: WideString;
  Flag: Boolean;

  procedure DoOrdProp;
  var
    Value: Integer;

    function IsDefault: Boolean;
    begin
      if Ancestor <> nil then
        Result := Value = GetOrdProp(Ancestor, PropList[i])
      else
        Result := Value = PropList[i].Default;
    end;

  begin
    Value := GetOrdProp(Obj, PropList[i]);
    if not IsDefault or FSerializeDefaultValues then
      if PropList[i].PropType^.Kind = tkEnumeration then
        s := GetEnumName(PropList[i].PropType^, Value)
      else
        s := IntToStr(Value);
  end;

  procedure DoFloatProp;
  var
    Value: Extended;

    function IsDefault: Boolean;
    begin
      if Ancestor <> nil then
        Result := Abs(Value - GetFloatProp(Ancestor, PropList[i])) < 1e-6
      else
        Result := False;
    end;

  begin
    Value := GetFloatProp(Obj, PropList[i]);
// commented out due to bug with tfrxmemoview.linespacing=0
    if not IsDefault or FSerializeDefaultValues then
      s := FloatToStr(Value);
  end;

  procedure DoStrProp;
  var
    Value: String;

    function IsDefault: Boolean;
    begin
      if Ancestor <> nil then
        Result := Value = GetStrProp(Ancestor, PropList[i])
      else
        Result := Value = '';
    end;

  begin
    Value := GetStrProp(Obj, PropList[i]);
    if not IsDefault or FSerializeDefaultValues then
      s := frxStrToXML(Value);
  end;

  procedure DoVariantProp;
  var
    Value: Variant;

    function IsDefault: Boolean;
    begin
      if Ancestor <> nil then
        Result := Value = GetVariantProp(Ancestor, PropList[i])
      else
        Result := False;
    end;

  begin
    Value := GetVariantProp(Obj, PropList[i]);
    if not IsDefault or FSerializeDefaultValues then
      s := frxStrToXML(VarToStr(Value));
  end;

  procedure DoClassProp;
  var
    FClass: TClass;
    FComp, FAncComp: TComponent;
    FObj, FAncObj: TPersistent;
  begin
    FClass := GetTypeData(PropList[i].PropType^).ClassType;
    if FClass.InheritsFrom(TComponent) then
    begin
      FComp := TComponent(GetOrdProp(Obj, PropList[i]));
      if Ancestor <> nil then
        FAncComp := TComponent(GetOrdProp(Ancestor, PropList[i]))
      else
        FAncComp := nil;

      if Ancestor <> nil then
      begin
        if (FComp = nil) and (FAncComp = nil) then Exit;
        if (FComp <> nil) and (FAncComp <> nil) then
          if CompareText(FComp.Name, FAncComp.Name) = 0 then Exit;
        if (FComp = nil) and (FAncComp <> nil) then
        begin
          s := 'nil';
          Exit;
        end;
      end;

      if FComp <> nil then
        s := frxGetFullName(FOwner, FComp);
    end
    else if FClass.InheritsFrom(TPersistent) then
    begin
      FObj := TPersistent(GetOrdProp(Obj, PropList[i]));
      if Ancestor <> nil then
        FAncObj := TPersistent(GetOrdProp(Ancestor, PropList[i]))
      else
        FAncObj := nil;

      if FObj is TStrings then
      begin
        if Ancestor <> nil then
          if TStrings(FObj).Text = TStrings(FAncObj).Text then
            Exit;

        s := TStrings(FObj).Text;
        if (Length(s) >= 2) and
           (s[Length(s) - 1] = #13) and (s[Length(s)] = #10) then
          Delete(s, Length(s) - 1, 2);
        s := ' ' + Add + PropList[i].Name + '.Text="' +
          frxStrToXML(s) + '"';

      end
      else if FObj is TWideStrings then
      begin
        // skip, handle separately
      end
      else
        s := ObjToXML(FObj, Add + PropList[i].Name + '.', FAncObj);
      Flag := True;
    end;
  end;

  procedure DoNonPublishedProps;
  var
    wr: TWriter;
    ms, AncMs: TMemoryStream;
  begin
    ms := TMemoryStream.Create;
    try
      wr := TWriter.Create(ms, 4096);
      wr.Root := FOwner;

      try
        THackPersistent(Obj).DefineProperties(wr);
      finally
        wr.Free;
      end;

      if ms.Size > 0 then
      begin
        if Ancestor <> nil then
        begin
          AncMs := TMemoryStream.Create;
          try
            wr := TWriter.Create(AncMs, 4096);
            wr.Root := FOwner;

            try
              THackPersistent(Ancestor).DefineProperties(wr);
            finally
              wr.Free;
            end;
            if frxStreamCRC32(ms) = frxStreamCRC32(AncMs) then
              Exit;
          finally
            AncMs.Free;
          end;
        end;

        s := frxStreamToString(ms);
        Result := Result + ' ' + Add + 'PropData="' + s + '"';
      end;
    finally
      ms.Free;
    end;
  end;

begin
  Result := '';

  TypeInfo := Obj.ClassInfo;
  PropCount := GetTypeData(TypeInfo).PropCount;
  GetMem(PropList, PropCount * SizeOf(PPropInfo));
  GetPropInfos(TypeInfo, PropList);

  try
    if Obj is TfrxComponent then
    begin
      TfrxComponent(Obj).IsWriting := True;
      if (Ancestor = nil) and Assigned(FOnGetAncestor) then
        FOnGetAncestor(TfrxComponent(Obj).Name, Ancestor);
    end;

    for i := 0 to PropCount - 1 do
    begin
      s := '';
      Flag := False;

      if IsStoredProp(Obj, PropList[i]) then
        case PropList[i].PropType^.Kind of
          tkInteger, tkSet, tkChar, tkWChar, tkEnumeration:
            DoOrdProp;

          tkFloat:
            DoFloatProp;

          tkString, tkLString, tkWString:
            DoStrProp;

          tkClass:
            DoClassProp;

          tkVariant:
            DoVariantProp;
        end;

      if s <> '' then
        if Flag then
          Result := Result + s
        else
          Result := Result + ' ' + Add + PropList[i].Name + '="' + s + '"';
    end;

    if Obj is TfrxCustomMemoView then
      if (Ancestor = nil) or
        (TfrxCustomMemoView(Obj).Text <> TfrxCustomMemoView(Ancestor).Text) then
      begin
        ws := TfrxCustomMemoView(Obj).Text;
        if (Length(ws) >= 2) and
          (ws[Length(ws) - 1] = #13) and (ws[Length(ws)] = #10) then
            Delete(ws, Length(ws) - 1, 2);
        Result := Result + ' Text="' + frxStrToXML(Utf8Encode(ws)) + '"';
      end;

    DoNonPublishedProps;

  finally
    if Obj is TfrxComponent then
      TfrxComponent(Obj).IsWriting := False;
    FreeMem(PropList, PropCount * SizeOf(PPropInfo));
  end;
end;

procedure TfrxXMLSerializer.ReadRootComponent(Root: TfrxComponent;
  XMLItem: TfrxXMLItem = nil);
var
  XMLDoc: TfrxXMLDocument;
  CompList: TList;

  procedure DoRead(Item: TfrxXMLItem; Owner: TfrxComponent);
  var
    i: Integer;
    c: TfrxComponent;
    IsAncestor: Boolean;
  begin
    IsAncestor := CompareText(Item.Name, 'inherited') = 0;
    if not IsAncestor then
      try
        FindClass(Item.Name);
      except
        FErrors.Add(frxResources.Get('xrCantFindClass') + ' ' + Item.Name);
        Exit;
      end;

    if Owner <> nil then
    begin
      c := FOwner.FindComponent(Item.Prop['Name']) as TfrxComponent;
      if not IsAncestor and (c = nil) then
      begin
        c := TfrxComponent(FindClass(Item.Name).NewInstance);
        c.Create(Owner);
      end;
    end
    else
      c := Root;

    if c <> nil then
    begin
      c.IsLoading := True;
      XMLToObj(Item.Text, c);
      CompList.Add(c);

      for i := 0 to Item.Count - 1 do
        DoRead(Item[i], c);
    end;
  end;

  procedure DoLoaded;
  var
    i: Integer;
    c: TfrxComponent;
  begin
    for i := 0 to CompList.Count - 1 do
    begin
      c := CompList[i];
      c.IsLoading := False;
      if not (c is TfrxReport) then
        THackComponent(c).Loaded;
    end;
  end;

begin
  if Owner = nil then
    Owner := Root;
  XMLDoc := nil;
  CompList := TList.Create;

  if XMLItem = nil then
  begin
    XMLDoc := TfrxXMLDocument.Create;
    XMLItem := XMLDoc.Root;
    XMLDoc.LoadFromStream(FStream);
  end;

  FReader.Root := FOwner;
  FReader.BeginReferences;
  try
    DoRead(XMLItem, nil);
    FixupReferences;
    DoLoaded;
  finally
    if XMLDoc <> nil then
      XMLDoc.Free;
    CompList.Free;
  end;
end;

procedure TfrxXMLSerializer.WriteRootComponent(Root: TfrxComponent;
  SaveChildren: Boolean = True; XMLItem: TfrxXMLItem = nil);
var
  XMLDoc: TfrxXMLDocument;

  procedure DoWrite(Item: TfrxXMLItem; ARoot: TfrxComponent);
  var
    i: Integer;
  begin
    if ARoot.IsAncestor then
      Item.Name := 'inherited'
    else
      Item.Name := ARoot.ClassName;
    if ARoot = Root then
      Item.Text := ObjToXML(ARoot)
    else
      Item.Text := 'Name="' + ARoot.Name + '"' + ObjToXML(ARoot);

    if SaveChildren then
      for i := 0 to ARoot.Objects.Count - 1 do
        DoWrite(Item.Add, ARoot.Objects[i]);
  end;

begin
  if Owner = nil then
    Owner := Root;
  XMLDoc := nil;

  if XMLItem = nil then
  begin
    XMLDoc := TfrxXMLDocument.Create;
    XMLItem := XMLDoc.Root;
    XMLDoc.AutoIndent := True;
  end;

  try
    DoWrite(XMLItem, Root);
    if XMLDoc <> nil then
      XMLDoc.SaveToStream(FStream);
  finally
    if XMLDoc <> nil then
      XMLDoc.Free;
  end;
end;

function TfrxXMLSerializer.ReadComponent(Root: TfrxComponent): TfrxComponent;
var
  rd: TfrxXMLReader;
  RootItem: TfrxXMLItem;
begin
  rd := TfrxXMLReader.Create(FStream);
  RootItem := TfrxXMLItem.Create;

  try
    rd.ReadRootItem(RootItem, False);
    Result := ReadComponentStr(Root, RootItem.Name + ' ' + RootItem.Text);
  finally
    rd.Free;
    RootItem.Free;
  end;
end;

procedure TfrxXMLSerializer.WriteComponent(c: TfrxComponent);
var
  s: String;
begin
  s := '<' + WriteComponentStr(c) + '/>';
  FStream.Write(s[1], Length(s));
end;

function TfrxXMLSerializer.ReadComponentStr(Root: TfrxComponent;
  s: String; DontFixup: Boolean = False): TfrxComponent;
var
  n: Integer;
  s1: String;
begin
  Owner := Root;
  if Trim(s) = '' then
    Result := nil
  else
  begin
    n := Pos(' ', s);
    s1 := Copy(s, n + 1, MaxInt);
    Delete(s, n, MaxInt);

    Result := TfrxComponent(FindClass(s).NewInstance);
    Result.Create(Root);

    FReader.Root := Root;
    FReader.BeginReferences;
    try
      Result.IsLoading := True;
      XMLToObj(s1, Result);
    finally
      if DontFixup then
        ClearFixups
      else
        FixupReferences;
      Result.IsLoading := False;
      if not (Result is TfrxReport) then
        THackComponent(Result).Loaded;
    end;
  end;
end;

function TfrxXMLSerializer.WriteComponentStr(c: TfrxComponent): String;
begin
  Result := c.ClassName + ObjToXML(c);
end;

procedure TfrxXMLSerializer.ReadPersistentStr(Root: TComponent;
  Obj: TPersistent; const s: String);
begin
  FReader.Root := Root;
  FReader.BeginReferences;
  XMLToObj(s, Obj);
  FixupReferences;
end;

end.



//0f31356a91fea3356e5f76cdce90aa7b