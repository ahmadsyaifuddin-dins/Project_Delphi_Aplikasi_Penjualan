
{******************************************}
{                                          }
{             FastReport v4.0              }
{               XML document               }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxXML;

interface

{$I frx.inc}

uses
  Windows, SysUtils, Classes
{$IFDEF Delphi6}
, Variants
{$ENDIF};


type
  TfrxInvalidXMLException = class(Exception);

  TfrxXMLItem = class(TObject)
  private
    FData: Pointer;              { optional item data }
    FHiOffset: Byte;             { hi-part of the offset }
    FItems: TList;               { subitems }
    FLoaded: Boolean;            { item is loaded, no need to call LoadItem }
    FLoOffset: Integer;          { lo-part of the offset }
    FModified: Boolean;          { item is modified (used by preview designer) }
    FName: String;               { item name }
    FParent: TfrxXMLItem;        { item parent }
    FText: String;               { item attributes }
    FUnloadable: Boolean;
    FValue: String;              { item value <item>Value</item> }
    function GetCount: Integer;
    function GetItems(Index: Integer): TfrxXMLItem;
    function GetOffset: Int64;
    procedure SetOffset(const Value: Int64);
    function GetProp(Index: String): String;
    procedure SetProp(Index: String; const Value: String);
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddItem(Item: TfrxXMLItem);
    procedure Clear;
    procedure InsertItem(Index: Integer; Item: TfrxXMLItem);

    function Add: TfrxXMLItem;
    function Find(const Name: String): Integer;
    function FindItem(const Name: String): TfrxXMLItem;
    function IndexOf(Item: TfrxXMLItem): Integer;
    function PropExists(const Index: String): Boolean;
    function Root: TfrxXMLItem;
    procedure DeleteProp(const Index: String);

    property Count: Integer read GetCount;
    property Data: Pointer read FData write FData;
    property Items[Index: Integer]: TfrxXMLItem read GetItems; default;
    property Loaded: Boolean read FLoaded;
    property Modified: Boolean read FModified write FModified;
    property Name: String read FName write FName;
{ offset is the position of the item in the tempstream. This parameter is needed
  for dynamically loading large files. Items that can be loaded on-demand must
  have Unloadable = True (in run-time) or have 'ld="0"' parameter (in the file) }
    property Offset: Int64 read GetOffset write SetOffset;
    property Parent: TfrxXMLItem read FParent;
    property Prop[Index: String]: String read GetProp write SetProp;
    property Text: String read FText write FText;
    property Unloadable: Boolean read FUnloadable write FUnloadable;
    property Value: String read FValue write FValue;
  end;

  TfrxXMLDocument = class(TObject)
  private
    FAutoIndent: Boolean;        { use indents when writing document to a file }
    FRoot: TfrxXMLItem;          { root item }
    FTempDir: String;            { folder for temporary files }
    FTempFile: String;           { tempfile name }
    FTempStream: TStream;        { temp stream associated with tempfile }
    FTempFileCreated: Boolean;   { tempfile has been created - need to delete it }
    procedure CreateTempFile;
    procedure DeleteTempFile;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure LoadItem(Item: TfrxXMLItem);
    procedure UnloadItem(Item: TfrxXMLItem);
    procedure SaveToStream(Stream: TStream);
    procedure LoadFromStream(Stream: TStream; AllowPartialLoading: Boolean = False);
    procedure SaveToFile(const FileName: String);
    procedure LoadFromFile(const FileName: String);

    property AutoIndent: Boolean read FAutoIndent write FAutoIndent;
    property Root: TfrxXMLItem read FRoot;
    property TempDir: String read FTempDir write FTempDir;
  end;

{ TfrxXMLReader and TfrxXMLWriter are doing actual read/write to the XML file.
  Read/write process is buffered. }

  TfrxXMLReader = class(TObject)
  private
    FBuffer: PChar;
    FBufPos: Integer;
    FBufEnd: Integer;
    FPosition: Int64;
    FSize: Int64;
    FStream: TStream;
    procedure SetPosition(const Value: Int64);
    procedure ReadBuffer;
    procedure ReadItem(var Name, Text: String);
  public
    constructor Create(Stream: TStream);
    destructor Destroy; override;
    procedure RaiseException;
    procedure ReadHeader;
    procedure ReadRootItem(Item: TfrxXMLItem; ReadChildren: Boolean = True);
    property Position: Int64 read FPosition write SetPosition;
    property Size: Int64 read FSize;
  end;

  TfrxXMLWriter = class(TObject)
  private
    FAutoIndent: Boolean;
    FBuffer: String;
    FStream: TStream;
    FTempStream: TStream;
    procedure FlushBuffer;
    procedure WriteLn(const s: String);
    procedure WriteItem(Item: TfrxXMLItem; Level: Integer = 0);
  public
    constructor Create(Stream: TStream);
    procedure WriteHeader;
    procedure WriteRootItem(RootItem: TfrxXMLItem);
    property TempStream: TStream read FTempStream write FTempStream;
  end;


{ StrToXML changes '<', '>', '"', cr, lf symbols to its ascii codes }
function frxStrToXML(const s: String): String;

{ ValueToXML convert a value to the valid XML string }
function frxValueToXML(const Value: Variant): String;

{ XMLToStr is opposite to StrToXML function }
function frxXMLToStr(const s: String): String;


implementation


function frxStrToXML(const s: String): String;
const
  SpecChars = ['<', '>', '"', #10, #13, '&'];
var
  i, lenRes, resI, ch: Integer;
  pRes: PChar;

  procedure ReplaceChars(var s: String; i: Integer);
  begin
    Insert('#' + IntToStr(Ord(s[i])) + ';', s, i + 1);
    s[i] := '&';
  end;

begin
  lenRes := Length(s);

  if lenRes < 32 then
  begin
    Result := s;
    for i := lenRes downto 1 do
      if s[i] in SpecChars then
        if s[i] <> '&' then
          ReplaceChars(Result, i)
        else
        begin
          if Copy(s, i + 1, 5) = 'quot;' then
          begin
            Delete(Result, i, 6);
            Insert('&#34;', Result, i);
          end;
        end;
    Exit;
  end;

  { speed optimized code }
  SetLength(Result, lenRes);
  pRes := PChar(Result) - 1;
  resI := 1;
  i := 1;

  while i <= Length(s) do
  begin
    if resI + 5 > lenRes then
    begin
      Inc(lenRes, 256);
      SetLength(Result, lenRes);
      pRes := PChar(Result) - 1;
    end;

    if s[i] in SpecChars then
    begin
      if (s[i] = '&') and (i <= Length(s) - 5) and (s[i + 1] = 'q') and
        (s[i + 2] = 'u') and (s[i + 3] = 'o') and (s[i + 4] = 't') and (s[i + 5] = ';') then
      begin
        pRes[resI] := '&';
        pRes[resI + 1] := '#';
        pRes[resI + 2] := '3';
        pRes[resI + 3] := '4';
        pRes[resI + 4] := ';';
        Inc(resI, 4);
        Inc(i, 5);
      end
      else
      begin
        pRes[resI] := '&';
        pRes[resI + 1] := '#';

        ch := Ord(s[i]);
        if ch < 10 then
        begin
          pRes[resI + 2] := Chr(ch + $30);
          Inc(resI, 3);
        end
        else if ch < 100 then
        begin
          pRes[resI + 2] := Chr(ch div 10 + $30);
          pRes[resI + 3] := Chr(ch mod 10 + $30);
          Inc(resI, 4);
        end
        else
        begin
          pRes[resI + 2] := Chr(ch div 100 + $30);
          pRes[resI + 3] := Chr(ch mod 100 div 10 + $30);
          pRes[resI + 4] := Chr(ch mod 10 + $30);
          Inc(resI, 5);
        end;
        pRes[resI] := ';';
      end;
    end
    else
      pRes[resI] := s[i];
    Inc(resI);
    Inc(i);
  end;

  SetLength(Result, resI - 1);
end;

function frxXMLToStr(const s: String): String;
var
  i, j, h, n: Integer;
begin
  Result := s;

  i := 1;
  n := Length(s);
  while i < n do
  begin
    if Result[i] = '&' then
      if (i + 3 <= n) and (Result[i + 1] = '#') then
      begin
        j := i + 3;
        while Result[j] <> ';' do
          Inc(j);
        h := StrToInt(Copy(Result, i + 2, j - i - 2));
        Delete(Result, i, j - i);
        Result[i] := Chr(h);
        Dec(n, j - i);
      end
      else if Copy(Result, i + 1, 5) = 'quot;' then
      begin
        Delete(Result, i, 5);
        Result[i] := '"';
        Dec(n, 5);
      end;
    Inc(i);
  end;
end;

function frxValueToXML(const Value: Variant): String;
begin
  case TVarData(Value).VType of
    varSmallint, varInteger, varByte:
      Result := IntToStr(Value);

    varSingle, varDouble, varCurrency:
      Result := FloatToStr(Value);

    varDate:
      Result := DateToStr(Value);

    varOleStr, varString, varVariant:
      Result := frxStrToXML(Value);

    varBoolean:
      if Value = True then Result := '1' else Result := '0';

    else
      Result := '';
  end;
end;


{ TfrxXMLItem }

constructor TfrxXMLItem.Create;
begin
  FLoaded := True;
end;

destructor TfrxXMLItem.Destroy;
begin
  Clear;
  if FParent <> nil then
    FParent.FItems.Remove(Self);
  inherited;
end;

procedure TfrxXMLItem.Clear;
begin
  if FItems <> nil then
  begin
    while FItems.Count > 0 do
      TfrxXMLItem(FItems[0]).Free;
    FItems.Free;
    FItems := nil;
  end;
  if FUnloadable then
    FLoaded := False;
end;

function TfrxXMLItem.GetItems(Index: Integer): TfrxXMLItem;
begin
  Result := TfrxXMLItem(FItems[Index]);
end;

function TfrxXMLItem.GetCount: Integer;
begin
  if FItems = nil then
    Result := 0 else
    Result := FItems.Count;
end;

function TfrxXMLItem.Add: TfrxXMLItem;
begin
  Result := TfrxXMLItem.Create;
  AddItem(Result);
end;

procedure TfrxXMLItem.AddItem(Item: TfrxXMLItem);
begin
  if FItems = nil then
    FItems := TList.Create;

  FItems.Add(Item);
  if Item.FParent <> nil then
    Item.FParent.FItems.Remove(Item);
  Item.FParent := Self;
end;

procedure TfrxXMLItem.InsertItem(Index: Integer; Item: TfrxXMLItem);
begin
  AddItem(Item);
  FItems.Delete(FItems.Count - 1);
  FItems.Insert(Index, Item);
end;

function TfrxXMLItem.Find(const Name: String): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Count - 1 do
    if AnsiCompareText(Items[i].Name, Name) = 0 then
    begin
      Result := i;
      break;
    end;
end;

function TfrxXMLItem.FindItem(const Name: String): TfrxXMLItem;
var
  i: Integer;
begin
  i := Find(Name);
  if i = -1 then
  begin
    Result := Add;
    Result.Name := Name;
  end
  else
    Result := Items[i];
end;

function TfrxXMLItem.GetOffset: Int64;
begin
  Result := Int64(FHiOffset) * $100000000 + Int64(FLoOffset);
end;

procedure TfrxXMLItem.SetOffset(const Value: Int64);
begin
  FHiOffset := Value div $100000000;
  FLoOffset := Value mod $100000000;
end;

function TfrxXMLItem.Root: TfrxXMLItem;
begin
  Result := Self;
  while Result.Parent <> nil do
    Result := Result.Parent;
end;

function TfrxXMLItem.GetProp(Index: String): String;
var
  i: Integer;
begin
  i := Pos(' ' + AnsiUppercase(Index) + '="', AnsiUppercase(' ' + FText));
  if i <> 0 then
  begin
    Result := Copy(FText, i + Length(Index + '="'), MaxInt);
    Result := frxXMLToStr(Copy(Result, 1, Pos('"', Result) - 1));
  end
  else
    Result := '';
end;

procedure TfrxXMLItem.SetProp(Index: String; const Value: String);
var
  i, j: Integer;
  s: String;
begin
  i := Pos(' ' + AnsiUppercase(Index) + '="', AnsiUppercase(' ' + FText));
  if i <> 0 then
  begin
    j := i + Length(Index + '="');
    while (j <= Length(FText)) and (FText[j] <> '"') do
      Inc(j);
    Delete(FText, i, j - i + 1);
  end
  else
    i := Length(FText) + 1;

  s := Index + '="' + frxStrToXML(Value) + '"';
  if (i > 1) and (FText[i - 1] <> ' ') then
    s := ' ' + s;
  Insert(s, FText, i);
end;

function TfrxXMLItem.PropExists(const Index: String): Boolean;
begin
  Result := Pos(' ' + AnsiUppercase(Index) + '="', ' ' + AnsiUppercase(FText)) > 0;
end;

procedure TfrxXMLItem.DeleteProp(const Index: String);
var
  i: Integer;
begin
  i := Pos(' ' + AnsiUppercase(Index) + '="', ' ' + AnsiUppercase(FText));
  if i > 0 then
  begin
    SetProp(Index, '');
    Delete(FText, i, Length(Index) + 4);
  end;
end;

function TfrxXMLItem.IndexOf(Item: TfrxXMLItem): Integer;
begin
  Result := FItems.IndexOf(Item);
end;


{ TfrxXMLDocument }

constructor TfrxXMLDocument.Create;
begin
  FRoot := TfrxXMLItem.Create;
end;

destructor TfrxXMLDocument.Destroy;
begin
  DeleteTempFile;
  FRoot.Free;
  inherited;
end;

procedure TfrxXMLDocument.Clear;
begin
  FRoot.Clear;
  DeleteTempFile;
end;

procedure TfrxXMLDocument.CreateTempFile;
var
  Path: String[64];
  FileName: String[255];
begin
  if FTempFileCreated then Exit;

  Path := FTempDir;
  if Path = '' then
    Path[0] := Chr(GetTempPath(64, @Path[1])) else
    Path := Path + #0;
  if (Path <> '') and (Path[Length(Path)] <> '\') then
    Path := Path + '\';

  GetTempFileName(@Path[1], PChar('fr'), 0, @FileName[1]);
  FTempFile := StrPas(@FileName[1]);
  FTempStream := TFileStream.Create(FTempFile, fmOpenReadWrite);
  FTempFileCreated := True;
end;

procedure TfrxXMLDocument.DeleteTempFile;
begin
  if FTempFileCreated then
  begin
    FTempStream.Free;
    FTempStream := nil;
    DeleteFile(FTempFile);
    FTempFileCreated := False;
  end;
  if FTempStream <> nil then
    FTempStream.Free;
  FTempStream := nil;
end;

procedure TfrxXMLDocument.LoadItem(Item: TfrxXMLItem);
var
  rd: TfrxXMLReader;
  Text: String;
begin
  if (FTempStream = nil) or Item.FLoaded or not Item.FUnloadable then Exit;

  rd := TfrxXMLReader.Create(FTempStream);
  try
    rd.Position := Item.Offset;
    Text := Item.Text;
    rd.ReadRootItem(Item);
    Item.Text := Text;
    Item.FLoaded := True;
  finally
    rd.Free;
  end;
end;

procedure TfrxXMLDocument.UnloadItem(Item: TfrxXMLItem);
var
  wr: TfrxXMLWriter;
begin
  if not Item.FLoaded or not Item.FUnloadable then Exit;

  CreateTempFile;
  FTempStream.Position := FTempStream.Size;
  wr := TfrxXMLWriter.Create(FTempStream);
  try
    Item.Offset := FTempStream.Size;
    wr.WriteRootItem(Item);
    Item.Clear;
  finally
    wr.Free;
  end;
end;

procedure TfrxXMLDocument.LoadFromStream(Stream: TStream;
  AllowPartialLoading: Boolean = False);
var
  rd: TfrxXMLReader;
begin
  DeleteTempFile;

  rd := TfrxXMLReader.Create(Stream);
  try
    FRoot.Clear;
    FRoot.Offset := 0;
    rd.ReadHeader;
    rd.ReadRootItem(FRoot, not AllowPartialLoading);
  finally
    rd.Free;
  end;

  if AllowPartialLoading then
    FTempStream := Stream else
    FTempStream := nil;
end;

procedure TfrxXMLDocument.SaveToStream(Stream: TStream);
var
  wr: TfrxXMLWriter;
begin
  wr := TfrxXMLWriter.Create(Stream);
  wr.TempStream := FTempStream;
  wr.FAutoIndent := FAutoIndent;

  try
    wr.WriteHeader;
    wr.WriteRootItem(FRoot);
  finally
    wr.Free;
  end;
end;

procedure TfrxXMLDocument.LoadFromFile(const FileName: String);
var
  s: TFileStream;
begin
  s := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  LoadFromStream(s, True);
end;

procedure TfrxXMLDocument.SaveToFile(const FileName: String);
var
  s: TFileStream;
begin
  s := TFileStream.Create(FileName + '.tmp', fmCreate);
  try
    SaveToStream(s);
  finally
    s.Free;
  end;

  DeleteTempFile;
  DeleteFile(FileName);
  RenameFile(FileName + '.tmp', FileName);
  LoadFromFile(FileName);
end;


{ TfrxXMLReader }

constructor TfrxXMLReader.Create(Stream: TStream);
begin
  FStream := Stream;
  FSize := Stream.Size;
  FPosition := Stream.Position;
  GetMem(FBuffer, 4096);
end;

destructor TfrxXMLReader.Destroy;
begin
  FreeMem(FBuffer, 4096);
  FStream.Position := FPosition;
  inherited;
end;

procedure TfrxXMLReader.ReadBuffer;
begin
  FBufEnd := FStream.Read(FBuffer^, 4096);
  FBufPos := 0;
end;

procedure TfrxXMLReader.SetPosition(const Value: Int64);
begin
  FPosition := Value;
  FStream.Position := Value;
  FBufPos := 0;
  FBufEnd := 0;
end;

procedure TfrxXMLReader.RaiseException;
begin
  raise TfrxInvalidXMLException.Create('Invalid file format');
end;

procedure TfrxXMLReader.ReadHeader;
var
  s1, s2: String;
begin
  ReadItem(s1, s2);
  if Pos('?xml', s1) <> 1 then
    RaiseException;
end;

procedure TfrxXMLReader.ReadItem(var Name, Text: String);
var
  c: Integer;
  curpos, len: Integer;
  state: (FindLeft, FindRight, FindComment, Done);
  i, comment: Integer;
  ps: PChar;
begin
  Text := '';
  comment := 0;
  state := FindLeft;
  curpos := 0;
  len := 4096;
  SetLength(Name, len);
  ps := @Name[1];

  while FPosition < FSize do
  begin
    if FBufPos = FBufEnd then
      ReadBuffer;
    c := Ord(FBuffer[FBufPos]);
    Inc(FBufPos);
    Inc(FPosition);

    if state = FindLeft then
    begin
      if c = Ord('<') then
        state := FindRight
    end
    else if state = FindRight then
    begin
      if c = Ord('>') then
      begin
        state := Done;
        break;
      end
      else if c = Ord('<') then
        RaiseException
      else
      begin
        ps[curpos] := Chr(c);
        Inc(curpos);
        if (curpos = 3) and (Pos('!--', Name) = 1) then
        begin
          state := FindComment;
          comment := 0;
          curpos := 0;
        end;
        if curpos >= len - 1 then
        begin
          Inc(len, 4096);
          SetLength(Name, len);
          ps := @Name[1];
        end;
      end;
    end
    else if State = FindComment then
    begin
      if comment = 2 then
      begin
        if c = Ord('>') then
          state := FindLeft
        else
          comment := 0;
      end
      else begin
        if c = Ord('-') then
          Inc(comment)
        else
          comment := 0;
      end;
    end;
  end;

  len := curpos;
  SetLength(Name, len);

  if state = FindRight then
    RaiseException;
  if (Name <> '') and (Name[len] = ' ') then
    SetLength(Name, len - 1);

  i := Pos(' ', Name);
  if i <> 0 then
  begin
    Text := Copy(Name, i + 1, len - i);
    Delete(Name, i, len - i + 1);
  end;
end;

procedure TfrxXMLReader.ReadRootItem(Item: TfrxXMLItem; ReadChildren: Boolean = True);
var
  LastName: String;

  function DoRead(RootItem: TfrxXMLItem): Boolean;
  var
    n: Integer;
    ChildItem: TfrxXMLItem;
    Done: Boolean;
    CurPos: Int64;
  begin
    Result := False;
    CurPos := Position;
    ReadItem(RootItem.FName, RootItem.FText);
    LastName := RootItem.FName;

    if (RootItem.Name = '') or (RootItem.Name[1] = '/') then
    begin
      Result := True;
      Exit;
    end;

    n := Length(RootItem.Name);
    if RootItem.Name[n] = '/' then
    begin
      SetLength(RootItem.FName, n - 1);
      Exit;
    end;

    n := Length(RootItem.Text);
    if (n > 0) and (RootItem.Text[n] = '/') then
    begin
      SetLength(RootItem.FText, n - 1);
      Exit;
    end;

    repeat
      ChildItem := TfrxXMLItem.Create;
      Done := DoRead(ChildItem);
      if not Done then
        RootItem.AddItem(ChildItem) else
        ChildItem.Free;
    until Done;

    if (LastName <> '') and (AnsiCompareText(LastName, '/' + RootItem.Name) <> 0) then
      RaiseException;

    n := Pos(' ld="0"', LowerCase(RootItem.Text));
    if n <> 0 then
      Delete(RootItem.FText, n, 7);
    if not ReadChildren and (n <> 0) then
    begin
      RootItem.Clear;
      RootItem.Offset := CurPos;
      RootItem.FUnloadable := True;
      RootItem.FLoaded := False;
    end;
  end;

begin
  DoRead(Item);
end;


{ TfrxXMLWriter }

constructor TfrxXMLWriter.Create(Stream: TStream);
begin
  FStream := Stream;
end;

procedure TfrxXMLWriter.FlushBuffer;
begin
  if FBuffer <> '' then
    FStream.Write(FBuffer[1], Length(FBuffer));
  FBuffer := '';
end;

procedure TfrxXMLWriter.WriteLn(const s: String);
begin
  if not FAutoIndent then
    Insert(s, FBuffer, MaxInt) else
    Insert(s + #13#10, FBuffer, MaxInt);
  if Length(FBuffer) > 4096 then
    FlushBuffer;
end;

procedure TfrxXMLWriter.WriteHeader;
begin
  WriteLn('<?xml version="1.0" encoding="utf-8"?>');
end;

function Dup(n: Integer): String;
begin
  SetLength(Result, n);
  FillChar(Result[1], n, ' ');
end;

procedure TfrxXMLWriter.WriteItem(Item: TfrxXMLItem; Level: Integer = 0);
var
  s: String;
begin
  if (Item.FText <> '') or Item.FUnloadable then
  begin
    s := Item.FText;
    if (s = '') or (s[1] <> ' ') then
      s := ' ' + s;
    if Item.FUnloadable then
      s := s + 'ld="0"';
  end
  else
    s := '';

  if Item.Count = 0 then
  begin
    if Item.Value = '' then                       
      s := s + '/>' 
    else
      s := s + '>' + Item.Value + '</' + Item.Name + '>' 
  end 
  else
    s := s + '>';
  if not FAutoIndent then
    s := '<' + Item.Name + s else
    s := Dup(Level) + '<' + Item.Name + s;
  WriteLn(s);
end;

procedure TfrxXMLWriter.WriteRootItem(RootItem: TfrxXMLItem);

  procedure DoWrite(RootItem: TfrxXMLItem; Level: Integer = 0);
  var
    i: Integer;
    rd: TfrxXMLReader;
    NeedClear: Boolean;
  begin
    NeedClear := False;
    if not FAutoIndent then
      Level := 0;

    if (FTempStream <> nil) and RootItem.FUnloadable and not RootItem.FLoaded then
    begin
      rd := TfrxXMLReader.Create(FTempStream);
      try
        rd.Position := RootItem.Offset;
        rd.ReadRootItem(RootItem);
        NeedClear := True;
      finally
        rd.Free;
      end;
    end;

    WriteItem(RootItem, Level);
    for i := 0 to RootItem.Count - 1 do
      DoWrite(RootItem[i], Level + 2);
    if RootItem.Count > 0 then
      if not FAutoIndent then
        WriteLn('</' + RootItem.Name + '>') else
        WriteLn(Dup(Level) + '</' + RootItem.Name + '>');

    if NeedClear then
      RootItem.Clear;
  end;

begin
  DoWrite(RootItem);
  FlushBuffer;
end;

end.



//0f31356a91fea3356e5f76cdce90aa7b