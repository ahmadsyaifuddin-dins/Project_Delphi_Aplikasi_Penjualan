{*******************************************************}
{    The Delphi Unicode Controls Project                }
{                                                       }
{      http://home.ccci.org/wolbrink                    }
{                                                       }
{ Copyright (c) 2002, Troy Wolbrink (wolbrink@ccci.org) }
{                                                       }
{*******************************************************}

unit frxUnicodeUtils;

interface

{$I frx.inc}

uses Windows, Classes, SysUtils;

type
  TWString = record
    WString: WideString;
    Obj: TObject;
  end;

  TWideStrings = class(TPersistent)
  private
    FWideStringList: TList;
    function Get(Index: Integer): WideString;
    procedure Put(Index: Integer; const S: WideString);
    function GetObject(Index: Integer): TObject;
    procedure PutObject(Index: Integer; const Value: TObject);
    procedure ReadData(Reader: TReader);
    procedure ReadDataW(Reader: TReader);
    procedure WriteDataW(Writer: TWriter);
    function GetTextStr: WideString;
    procedure SetTextStr(const Value: WideString);
  protected
    procedure AssignTo(Dest: TPersistent); override;
    procedure DefineProperties(Filer: TFiler); override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function Count: Integer;
    procedure Clear;
    procedure Delete(Index: Integer);
    function Add(const S: WideString): Integer;
    procedure AddStrings(Strings: TWideStrings);
    function AddObject(const S: WideString; AObject: TObject): Integer;
    function IndexOf(const S: WideString): Integer;
    procedure Insert(Index: Integer; const S: WideString);
    procedure LoadFromFile(const FileName: WideString);
    procedure LoadFromStream(Stream: TStream);
    procedure LoadFromWStream(Stream: TStream);
    procedure SaveToFile(const FileName: WideString);
    procedure SaveToStream(Stream: TStream);
    property Objects[Index: Integer]: TObject read GetObject write PutObject;
    property Strings[Index: Integer]: WideString read Get write Put; default;
    property Text: WideString read GetTextStr write SetTextStr;
  end;


{$IFNDEF Delphi6}
function Utf8Encode(const WS: WideString): String;
function UTF8Decode(const S: String): WideString;
function VarToWideStr(const V: Variant): WideString;
{$ENDIF}
function AnsiToUnicode(const s: String; Charset: UINT): WideString;


implementation

const
  sLineBreak = #13#10;
  WideLineSeparator = WideChar($2028);
  NameValueSeparator = '=';


{$IFNDEF Delphi6}
function Utf8Encode(const WS: WideString): String;
var
  L: Integer;
  Temp: String;

  function ToUtf8(Dest: PChar; MaxDestBytes: Cardinal; 
           Source: PWideChar; SourceChars: Cardinal): Cardinal;
  var
    i, count: Cardinal;
    c: Cardinal;
  begin
    Result := 0;
    if Source = nil then Exit;
    count := 0;
    i := 0;
    if Dest <> nil then
    begin
      while (i < SourceChars) and (count < MaxDestBytes) do
      begin
        c := Cardinal(Source[i]);
        Inc(i);
        if c <= $7F then
        begin
          Dest[count] := Char(c);
          Inc(count);
        end
        else if c > $7FF then
        begin
          if count + 3 > MaxDestBytes then
            break;
          Dest[count] := Char($E0 or (c shr 12));
          Dest[count+1] := Char($80 or ((c shr 6) and $3F));
          Dest[count+2] := Char($80 or (c and $3F));
          Inc(count,3);
        end
        else //  $7F < Source[i] <= $7FF
        begin
          if count + 2 > MaxDestBytes then
            break;
          Dest[count] := Char($C0 or (c shr 6));
          Dest[count+1] := Char($80 or (c and $3F));
          Inc(count,2);
        end;
      end;
      if count >= MaxDestBytes then count := MaxDestBytes-1;
      Dest[count] := #0;
    end
    else
    begin
      while i < SourceChars do
      begin
        c := Integer(Source[i]);
        Inc(i);
        if c > $7F then
        begin
          if c > $7FF then
            Inc(count);
          Inc(count);
        end;
        Inc(count);
      end;
    end;
    Result := count+1; 
  end;

begin
  Result := '';
  if WS = '' then Exit;
  SetLength(Temp, Length(WS) * 3);
  L := ToUtf8(PChar(Temp), Length(Temp)+1, PWideChar(WS), Length(WS));
  if L > 0 then
    SetLength(Temp, L-1)
  else
    Temp := '';
  Result := Temp;
end;

function Utf8Decode(const S: String): WideString;
var
  L: Integer;
  Temp: WideString;

  function Utf8ToUnicode(Dest: PWideChar; MaxDestChars: Cardinal; Source: PChar; SourceBytes: Cardinal): Cardinal;
  var
    i, count: Cardinal;
    c: Byte;
    wc: Cardinal;
  begin
    if Source = nil then
    begin
      Result := 0;
      Exit;
    end;
    Result := Cardinal(-1);
    count := 0;
    i := 0;
    if Dest <> nil then
    begin
      while (i < SourceBytes) and (count < MaxDestChars) do
      begin
        wc := Cardinal(Source[i]);
        Inc(i);
        if (wc and $80) <> 0 then
        begin
          wc := wc and $3F;
          if i > SourceBytes then Exit;           // incomplete multibyte char
          if (wc and $20) <> 0 then
          begin
            c := Byte(Source[i]);
            Inc(i);
            if (c and $C0) <> $80 then  Exit;     // malformed trail byte or out of range char
            if i > SourceBytes then Exit;         // incomplete multibyte char
            wc := (wc shl 6) or (c and $3F);
          end;
          c := Byte(Source[i]);
          Inc(i);
          if (c and $C0) <> $80 then Exit;       // malformed trail byte

          Dest[count] := WideChar((wc shl 6) or (c and $3F));
        end
        else
          Dest[count] := WideChar(wc);
        Inc(count);
      end;
    if count >= MaxDestChars then count := MaxDestChars-1;
    Dest[count] := #0;
    end
    else
    begin
    while (i <= SourceBytes) do
    begin
      c := Byte(Source[i]);
      Inc(i);
      if (c and $80) <> 0 then
      begin
      if (c and $F0) = $F0 then Exit;  // too many bytes for UCS2
      if (c and $40) = 0 then Exit;    // malformed lead byte
      if i > SourceBytes then Exit;         // incomplete multibyte char

      if (Byte(Source[i]) and $C0) <> $80 then Exit;  // malformed trail byte
      Inc(i);
      if i > SourceBytes then Exit;         // incomplete multibyte char
      if ((c and $20) <> 0) and ((Byte(Source[i]) and $C0) <> $80) then Exit; // malformed trail byte
      Inc(i);
      end;
      Inc(count);
    end;
    end;
    Result := count+1;
  end;

begin
  Result := '';
  if S = '' then Exit;
  SetLength(Temp, Length(S));

  L := Utf8ToUnicode(PWideChar(Temp), Length(Temp)+1, PChar(S), Length(S));
  if L > 0 then
    SetLength(Temp, L-1)
  else
    Temp := '';
  Result := Temp;
end;

function VarToWideStrDef(const V: Variant; const ADefault: WideString): WideString;
begin
  if not VarIsNull(V) then
    Result := V
  else
    Result := ADefault;
end;

function VarToWideStr(const V: Variant): WideString;
begin
  Result := VarToWideStrDef(V, '');
end;
{$ENDIF}


{ TWideStrings }

constructor TWideStrings.Create;
begin
  FWideStringList := TList.Create;
end;

destructor TWideStrings.Destroy;
begin
  Clear;
  FWideStringList.Free;
  inherited;
end;

procedure TWideStrings.Clear;
var
  Index: Integer;
  PWStr: ^TWString;
begin
  for Index := 0 to FWideStringList.Count-1 do
  begin
    PWStr := FWideStringList.Items[Index];
    if PWStr <> nil then
      Dispose(PWStr);
  end;
  FWideStringList.Clear;
end;

function TWideStrings.Get(Index: Integer): WideString;
var
  PWStr: ^TWString;
begin
  Result := '';
  if ( (Index >= 0) and (Index < FWideStringList.Count) ) then
  begin
    PWStr := FWideStringList.Items[Index];
    if PWStr <> nil then
      Result := PWStr^.WString;
  end;
end;

procedure TWideStrings.Put(Index: Integer; const S: WideString);
begin
  Insert(Index, S);
end;

function TWideStrings.GetObject(Index: Integer): TObject;
var
  PWStr: ^TWString;
begin
  Result := nil;
  if ( (Index >= 0) and (Index < FWideStringList.Count) ) then
  begin
    PWStr := FWideStringList.Items[Index];
    if PWStr <> nil then
      Result := PWStr^.Obj;
  end;
end;

procedure TWideStrings.PutObject(Index: Integer; const Value: TObject);
var
  PWStr: ^TWString;
begin
  if ( (Index >= 0) and (Index < FWideStringList.Count) ) then
  begin
    PWStr := FWideStringList.Items[Index];
    if PWStr <> nil then
      PWStr^.Obj := Value;
  end;
end;

function TWideStrings.Add(const S: WideString): Integer;
var
  PWStr: ^TWString;
begin
  New(PWStr);
  PWStr^.WString := S;
  Result := FWideStringList.Add(PWStr);
end;

procedure TWideStrings.Delete(Index: Integer);
var
  PWStr: ^TWString;
begin
  PWStr := FWideStringList.Items[Index];
  if PWStr <> nil then
    Dispose(PWStr);
  FWideStringList.Delete(Index);
end;

function TWideStrings.IndexOf(const S: WideString): Integer;
var
  Index: Integer;
  PWStr: ^TWString;
begin
  Result := -1;
  for Index := 0 to FWideStringList.Count -1 do
  begin
    PWStr := FWideStringList.Items[Index];
    if PWStr <> nil then
    begin
      if S = PWStr^.WString then
      begin
        Result := Index;
        break;
      end;
    end;
  end;
end;

function TWideStrings.Count: Integer;
begin
  Result := FWideStringList.Count;
end;

procedure TWideStrings.Insert(Index: Integer; const S: WideString);
var
  PWStr: ^TWString;
begin
  if((Index < 0) or (Index > FWideStringList.Count)) then
    raise Exception.Create('Wide String Out of Bounds');
  if Index < FWideStringList.Count then
  begin
    PWStr := FWideStringList.Items[Index];
    if PWStr <> nil then
      PWStr.WString := S;
  end
  else
    Add(S);
end;

procedure TWideStrings.AddStrings(Strings: TWideStrings);
var
  I: Integer;
begin
  for I := 0 to Strings.Count - 1 do
    AddObject(Strings[I], Strings.Objects[I]);
end;

function TWideStrings.AddObject(const S: WideString; AObject: TObject): Integer;
begin
  Result := Add(S);
  PutObject(Result, AObject);
end;

procedure TWideStrings.Assign(Source: TPersistent);
var
  I: Integer;
begin
  if Source is TWideStrings then
  begin
    Clear;
    AddStrings(TWideStrings(Source));
  end
  else if Source is TStrings then
  begin
    Clear;
    for I := 0 to TStrings(Source).Count - 1 do
      AddObject(TStrings(Source)[I], TStrings(Source).Objects[I]);
  end
  else
    inherited Assign(Source);
end;

procedure TWideStrings.AssignTo(Dest: TPersistent);
var
  I: Integer;
begin
  if Dest is TWideStrings then
    Dest.Assign(Self)
  else if Dest is TStrings then
  begin
    TStrings(Dest).BeginUpdate;
    try
      TStrings(Dest).Clear;
      for I := 0 to Count - 1 do
        TStrings(Dest).AddObject(Strings[I], Objects[I]);
    finally
      TStrings(Dest).EndUpdate;
    end;
  end
  else
    inherited AssignTo(Dest);
end;

procedure TWideStrings.DefineProperties(Filer: TFiler);
begin
  // compatibility
  Filer.DefineProperty('Strings', ReadData, nil, Count > 0);
  Filer.DefineProperty('UTF8', ReadDataW, WriteDataW, Count > 0);
end;

function TWideStrings.GetTextStr: WideString;
var
  I, L, Size, Count: Integer;
  P: PWideChar;
  S, LB: WideString;
begin
  Count := FWideStringList.Count;
  Size := 0;
  LB := sLineBreak;
  for I := 0 to Count - 1 do Inc(Size, Length(Get(I)) + Length(LB));
  SetString(Result, nil, Size);
  P := Pointer(Result);
  for I := 0 to Count - 1 do
  begin
    S := Get(I);
    L := Length(S);
    if L <> 0 then
    begin
      System.Move(Pointer(S)^, P^, L * SizeOf(WideChar));
      Inc(P, L);
    end;
    L := Length(LB);
    if L <> 0 then
    begin
      System.Move(Pointer(LB)^, P^, L * SizeOf(WideChar));
      Inc(P, L);
    end;
  end;
end;

procedure TWideStrings.LoadFromFile(const FileName: WideString);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TWideStrings.LoadFromStream(Stream: TStream);
var
  Size: Integer;
  S: WideString;
  ansiS: String;
  sign: Word;
begin
  Size := Stream.Size - Stream.Position;
  sign := 0;
  if Size > 2 then
    Stream.Read(sign, 2);

  if sign = $FEFF then
  begin
    Dec(Size, 2);
    SetLength(S, Size div 2);
    Stream.Read(S[1], Size);
    SetTextStr(S);
  end
  else
  begin
    Stream.Seek(-2, soFromCurrent);
    SetLength(ansiS, Size);
    Stream.Read(ansiS[1], Size);
    SetTextStr(ansiS);
  end;
end;

procedure TWideStrings.LoadFromWStream(Stream: TStream);
var
  Size: Integer;
  S: WideString;
begin
  Size := Stream.Size - Stream.Position;
  SetLength(S, Size div 2);
  Stream.Read(S[1], Size);
  SetTextStr(S);
end;

procedure TWideStrings.ReadData(Reader: TReader);
begin
  Clear;
  Reader.ReadListBegin;
  while not Reader.EndOfList do
    if Reader.NextValue in [vaString, vaLString] then
      Add(Reader.ReadString) {TStrings compatiblity}
    else
      Add(Reader.ReadWideString);
  Reader.ReadListEnd;
end;

procedure TWideStrings.ReadDataW(Reader: TReader);
begin
  Clear;
  Reader.ReadListBegin;
  while not Reader.EndOfList do
    Add(Utf8Decode(Reader.ReadString));
  Reader.ReadListEnd;
end;

procedure TWideStrings.SaveToFile(const FileName: WideString);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TWideStrings.SaveToStream(Stream: TStream);
var
  SW: WideString;
begin
  SW := GetTextStr;
  Stream.WriteBuffer(PWideChar(SW)^, Length(SW) * SizeOf(WideChar));
end;

procedure TWideStrings.SetTextStr(const Value: WideString);
var
  P, Start: PWideChar;
  S: WideString;
begin
  Clear;
  P := Pointer(Value);
  if P <> nil then
    while P^ <> #0 do
    begin
      Start := P;
      while not (P^ in [WideChar(#0), WideChar(#10), WideChar(#13)]) and (P^ <> WideLineSeparator) do
        Inc(P);
      SetString(S, Start, P - Start);
      Add(S);
      if P^ = #13 then Inc(P);
      if P^ = #10 then Inc(P);
      if P^ = WideLineSeparator then Inc(P);
    end;
end;

procedure TWideStrings.WriteDataW(Writer: TWriter);
var
  I: Integer;
begin
  Writer.WriteListBegin;
  for I := 0 to Count - 1 do
    Writer.WriteString(Utf8Encode(Get(I)));
  Writer.WriteListEnd;
end;

function TranslateCharsetInfo(lpSrc: DWORD; var lpCs: TCharsetInfo;
  dwFlags: DWORD): BOOL; stdcall; external gdi32 name 'TranslateCharsetInfo';

function CharSetToCodePage(ciCharset: DWORD): Cardinal;
var
  C: TCharsetInfo;
begin
  if ciCharset = DEFAULT_CHARSET then
    Result := GetACP
  else
  begin
    Win32Check(TranslateCharsetInfo(ciCharset, C, TCI_SRCCHARSET));
    Result := C.ciACP;
  end;
end;

function AnsiToUnicode(const s: String; Charset: UINT): WideString;
var
  CodePage: Integer;
  InputLength, OutputLength: Integer;
begin
  CodePage := CharSetToCodePage(Charset);
  InputLength := Length(S);
  OutputLength := MultiByteToWideChar(CodePage, 0, PAnsiChar(S), InputLength, nil, 0);
  SetLength(Result, OutputLength);
  MultiByteToWideChar(CodePage, 0, PAnsiChar(S), InputLength, PWideChar(Result), OutputLength);
end;



end.


//0f31356a91fea3356e5f76cdce90aa7b