
{******************************************}
{                                          }
{             FastReport v4.0              }
{            Various routines              }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxUtils;

interface

{$I frx.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms,
  StdCtrls, Menus, ImgList, ActnList, ComCtrls, frxClass
{$IFDEF Delphi6}
, Variants
{$ENDIF};

function frxFindComponent(Owner: TComponent; const Name: String): TComponent;
procedure frxGetComponents(Owner: TComponent; ClassRef: TClass;
  List: TStrings; Skip: TComponent);
function frxGetFullName(Owner: TComponent; c: TComponent): String;
procedure frxSetCommaText(const Text: String; sl: TStrings; Comma: Char = ';');
function frxRemoveQuotes(const s: String): String;
function frxStreamToString(Stream: TStream): String;
procedure frxStringToStream(const s: String; Stream: TStream);
function frxStrToFloat(s: String): Extended;
function frxFloatToStr(d: Extended): String;
function frxRect(ALeft, ATop, ARight, ABottom: Extended): TfrxRect;
function frxPoint(X, Y: Extended): TfrxPoint;
function frxGetBrackedVariable(const Str, OpenBracket, CloseBracket: String;
  var i, j: Integer): String;
function frxGetBrackedVariableW(const Str, OpenBracket, CloseBracket: WideString;
  var i, j: Integer): WideString;
procedure frxCommonErrorHandler(Report: TfrxReport; const Text: String);
procedure frxErrorMsg(const Text: String);
procedure frxInfoMsg(const Text: String);
function frxConfirmMsg(const Text: String; Buttons: Integer): Integer;
function frxIsValidFloat(const Value: string): Boolean;
procedure frxAssignImages(Bitmap: TBitmap; dx, dy: Integer;
  ImgList1: TImageList; ImgList2: TImageList = nil);
procedure frxDrawTransparent(Canvas: TCanvas; x, y: Integer; bmp: TBitmap);
procedure frxDrawGraphic(Canvas: TCanvas; DestRect: TRect; aGraph: TGraphic;
  IsPrinting: Boolean);
procedure frxParsePageNumbers(const PageNumbers: String; List: TStrings;
  Total: Integer);
function HTMLRGBColor(Color: TColor): string;
procedure frxWriteCollection(Collection: TCollection; Writer: TWriter;
  Owner: TfrxComponent);
procedure frxReadCollection(Collection: TCollection; Reader: TReader;
  Owner: TfrxComponent);
function GetAppFileName: String;
function GetAppPath: String;
function GetTemporaryFolder: String;
function GetTempFile: String;
function frxCreateTempFile(const TempDir: String): String;
function frFloat2Str(const Value: Extended; const Prec: Integer = 2): String;
function frxReverseString(const AText: string): string;
function frxStreamCRC32(Stream: TStream): Cardinal;

implementation

uses frxXMLSerializer, frxRes, TypInfo;

const
  CRCTable: array [0..255] of Cardinal = (
 0000000000, 1996959894, 3993919788, 2567524794,
 0124634137, 1886057615, 3915621685, 2657392035,
 0249268274, 2044508324, 3772115230, 2547177864,
 0162941995, 2125561021, 3887607047, 2428444049,
 0498536548, 1789927666, 4089016648, 2227061214,
 0450548861, 1843258603, 4107580753, 2211677639,
 0325883990, 1684777152, 4251122042, 2321926636,
 0335633487, 1661365465, 4195302755, 2366115317,
 0997073096, 1281953886, 3579855332, 2724688242,
 1006888145, 1258607687, 3524101629, 2768942443,
 0901097722, 1119000684, 3686517206, 2898065728,
 0853044451, 1172266101, 3705015759, 2882616665,
 0651767980, 1373503546, 3369554304, 3218104598,
 0565507253, 1454621731, 3485111705, 3099436303,
 0671266974, 1594198024, 3322730930, 2970347812,
 0795835527, 1483230225, 3244367275, 3060149565,
 1994146192, 0031158534, 2563907772, 4023717930,
 1907459465, 0112637215, 2680153253, 3904427059,
 2013776290, 0251722036, 2517215374, 3775830040,
 2137656763, 0141376813, 2439277719, 3865271297,
 1802195444, 0476864866, 2238001368, 4066508878,
 1812370925, 0453092731, 2181625025, 4111451223,
 1706088902, 0314042704, 2344532202, 4240017532,
 1658658271, 0366619977, 2362670323, 4224994405,
 1303535960, 0984961486, 2747007092, 3569037538,
 1256170817, 1037604311, 2765210733, 3554079995,
 1131014506, 0879679996, 2909243462, 3663771856,
 1141124467, 0855842277, 2852801631, 3708648649,
 1342533948, 0654459306, 3188396048, 3373015174,
 1466479909, 0544179635, 3110523913, 3462522015,
 1591671054, 0702138776, 2966460450, 3352799412,
 1504918807, 0783551873, 3082640443, 3233442989,
 3988292384, 2596254646, 0062317068, 1957810842,
 3939845945, 2647816111, 0081470997, 1943803523,
 3814918930, 2489596804, 0225274430, 2053790376,
 3826175755, 2466906013, 0167816743, 2097651377,
 4027552580, 2265490386, 0503444072, 1762050814,
 4150417245, 2154129355, 0426522225, 1852507879,
 4275313526, 2312317920, 0282753626, 1742555852,
 4189708143, 2394877945, 0397917763, 1622183637,
 3604390888, 2714866558, 0953729732, 1340076626,
 3518719985, 2797360999, 1068828381, 1219638859,
 3624741850, 2936675148, 0906185462, 1090812512,
 3747672003, 2825379669, 0829329135, 1181335161,
 3412177804, 3160834842, 0628085408, 1382605366,
 3423369109, 3138078467, 0570562233, 1426400815,
 3317316542, 2998733608, 0733239954, 1555261956,
 3268935591, 3050360625, 0752459403, 1541320221,
 2607071920, 3965973030, 1969922972, 0040735498,
 2617837225, 3943577151, 1913087877, 0083908371,
 2512341634, 3803740692, 2075208622, 0213261112,
 2463272603, 3855990285, 2094854071, 0198958881,
 2262029012, 4057260610, 1759359992, 0534414190,
 2176718541, 4139329115, 1873836001, 0414664567,
 2282248934, 4279200368, 1711684554, 0285281116,
 2405801727, 4167216745, 1634467795, 0376229701,
 2685067896, 3608007406, 1308918612, 0956543938,
 2808555105, 3495958263, 1231636301, 1047427035,
 2932959818, 3654703836, 1088359270, 0936918000,
 2847714899, 3736837829, 1202900863, 0817233897,
 3183342108, 3401237130, 1404277552, 0615818150,
 3134207493, 3453421203, 1423857449, 0601450431,
 3009837614, 3294710456, 1567103746, 0711928724,
 3020668471, 3272380065, 1510334235, 0755167117);

function frxStreamCRC32(Stream: TStream): Cardinal;
var
  OldPos: Integer;
  b: Byte;
  c: Cardinal;
begin
  OldPos := Stream.Position;
  Stream.Position := 0;
  c := $ffffffff;
  while Stream.Position < Stream.Size do
  begin
    Stream.Read(b,1);
    c := CrcTable[(c xor Cardinal(b)) and $ff] xor (c shr 8);
  end;
  Stream.Position := OldPos;
  Result := c xor $ffffffff;
end;

function frxFindComponent(Owner: TComponent; const Name: String): TComponent;
var
  n: Integer;
  s1, s2: String;
begin
  Result := nil;
  n := Pos('.', Name);
  try
    if n = 0 then
    begin
      if Owner <> nil then
        Result := Owner.FindComponent(Name);
      if (Result = nil) and (Owner is TfrxReport) and (Owner.Owner <> nil) then
        Result := Owner.Owner.FindComponent(Name);
    end
    else
    begin
      s1 := Copy(Name, 1, n - 1);        // module name
      s2 := Copy(Name, n + 1, 255);      // component name
      Owner := FindGlobalComponent(s1);
      if Owner <> nil then
      begin
        n := Pos('.', s2);
        if n <> 0 then        // frame name - Delphi5
        begin
          s1 := Copy(s2, 1, n - 1);
          s2 := Copy(s2, n + 1, 255);
          Owner := Owner.FindComponent(s1);
          if Owner <> nil then
            Result := Owner.FindComponent(s2);
        end
        else
          Result := Owner.FindComponent(s2);
      end;
    end;
  except
    on Exception do
      raise EClassNotFound.Create('Missing ' + Name);
  end;
end;

{$HINTS OFF}
procedure frxGetComponents(Owner: TComponent; ClassRef: TClass;
  List: TStrings; Skip: TComponent);
var
  i, j: Integer;

  procedure EnumComponents(f: TComponent);
  var
    i: Integer;
    c: TComponent;
  begin
{$IFDEF Delphi5}
    if f is TForm then
      for i := 0 to TForm(f).ControlCount - 1 do
      begin
        c := TForm(f).Controls[i];
        if c is TFrame then
          EnumComponents(c);
      end;
{$ENDIF}
    for i := 0 to f.ComponentCount - 1 do
    begin
      c := f.Components[i];
      if (c <> Skip) and (c is ClassRef) then
        List.AddObject(frxGetFullName(Owner, c), c);
    end;
  end;

begin
  List.Clear;
  if Owner is TfrxReport then
    EnumComponents(Owner);
  for i := 0 to Screen.FormCount - 1 do
    EnumComponents(Screen.Forms[i]);
  for i := 0 to Screen.DataModuleCount - 1 do
    EnumComponents(Screen.DataModules[i]);
{$IFDEF Delphi6} // D6 bugfix
  with Screen do
    for i := 0 to CustomFormCount - 1 do
      with CustomForms[i] do
      if (ClassName = 'TDataModuleForm')  then
        for j := 0 to ComponentCount - 1 do
        begin
          if (Components[j] is TDataModule) then
            EnumComponents(Components[j]);
        end;
{$ENDIF}
end;
{$HINTS ON}

function frxGetFullName(Owner: TComponent; c: TComponent): String;
var
  o: TComponent;
begin
  Result := '';
  if c = nil then Exit;

  o := c.Owner;
  if (o = nil) or (o = Owner) or ((Owner is TfrxReport) and (o = Owner.Owner)) then
    Result := c.Name
  else if ((o is TForm) or (o is TDataModule)) then
    Result := o.Name + '.' + c.Name
{$IFDEF Delphi5}
  else if o is TFrame then
    Result := o.Owner.Name + '.' + c.Owner.Name + '.' + c.Name
{$ENDIF}
end;

procedure frxSetCommaText(const Text: String; sl: TStrings; Comma: Char = ';');
var
  i: Integer;

  function ExtractCommaName(s: string; var Pos: Integer): string;
  var
    i: Integer;
  begin
    i := Pos;
    while (i <= Length(s)) and (s[i] <> Comma) do Inc(i);
    Result := Copy(s, Pos, i - Pos);
    if (i <= Length(s)) and (s[i] = Comma) then Inc(i);
    Pos := i;
  end;

begin
  i := 1;
  sl.Clear;
  while i <= Length(Text) do
    sl.Add(ExtractCommaName(Text, i));
end;

function frxRemoveQuotes(const s: String): String;
begin
  if (Length(s) > 2) and (s[1] = '"') and (s[Length(s)] = '"') then
    Result := Copy(s, 2, Length(s) - 2) else
    Result := s;
end;

function frxStreamToString(Stream: TStream): String;
var
  Size: Integer;
  p: PChar;
begin
  Size := Stream.Size;
  SetLength(Result, Size * 2);
  GetMem(p, Size);

  Stream.Position := 0;
  Stream.Read(p^, Size);

  BinToHex(p, @Result[1], Size);

  FreeMem(p, Size);
end;

procedure frxStringToStream(const s: String; Stream: TStream);
var
  Size: Integer;
  p: PChar;
begin
  Size := Length(s) div 2;
  GetMem(p, Size);

  HexToBin(@s[1], p, Size * 2);

  Stream.Position := 0;
  Stream.Write(p^, Size);

  FreeMem(p, Size);
end;

function frxStrToFloat(s: String): Extended;
var
  i: Integer;
begin
  for i := 1 to Length(s) do
    if s[i] in [',', '.'] then
      s[i] := DecimalSeparator;
  while Pos(' ', s) <> 0 do
    Delete(s, Pos(' ', s), 1);
  Result := StrToFloat(s);
end;

function frxFloatToStr(d: Extended): String;
begin
  if Int(d) = d then
    Result := FloatToStr(d) else
    Result := Format('%2.2f', [d]);
end;

function frxRect(ALeft, ATop, ARight, ABottom: Extended): TfrxRect;
begin
  with Result do
  begin
    Left := ALeft;
    Top := ATop;
    Right := ARight;
    Bottom := ABottom;
  end;
end;

function frxPoint(X, Y: Extended): TfrxPoint;
begin
  Result.X := X;
  Result.Y := Y;
end;

function frxGetBrackedVariable(const Str, OpenBracket, CloseBracket: String;
  var i, j: Integer): String;
var
  c: Integer;
  fl1, fl2: Boolean;
begin
  Result := '';
  j := i;
  fl1 := True;
  fl2 := True;
  c := 0;
  if (Str = '') or (j > Length(Str)) then Exit;

  Dec(j);
  repeat
    Inc(j);
    if isDBCSLeadByte(Byte(Str[j])) then  { if DBCS then skip 2 bytes }
      Inc(j, 2);

    if fl1 and fl2 then
      if Copy(Str, j, Length(OpenBracket)) = OpenBracket then
      begin
        if c = 0 then i := j;
        Inc(c);
      end
      else if Copy(Str, j, Length(CloseBracket)) = CloseBracket then
        Dec(c);
    if fl1 then
      if Str[j] = '"' then fl2 := not fl2;
    if fl2 then
      if Str[j] = '''' then fl1 := not fl1;
  until (c = 0) or (j >= Length(Str));

  Result := Copy(Str, i + Length(OpenBracket), j - i - Length(OpenBracket));
  if i <> j then
    Inc(j, Length(CloseBracket) - 1);
end;

function frxGetBrackedVariableW(const Str, OpenBracket, CloseBracket: WideString;
  var i, j: Integer): WideString;
var
  c: Integer;
  fl1, fl2: Boolean;
begin
  Result := '';
  j := i;
  fl1 := True;
  fl2 := True;
  c := 0;
  if (Str = '') or (j > Length(Str)) then Exit;

  Dec(j);
  repeat
    Inc(j);
    if fl1 and fl2 then
      if Copy(Str, j, Length(OpenBracket)) = OpenBracket then
      begin
        if c = 0 then i := j;
        Inc(c);
      end
      else if Copy(Str, j, Length(CloseBracket)) = CloseBracket then
        Dec(c);
    if fl1 then
      if Str[j] = '"' then fl2 := not fl2;
    if fl2 then
      if Str[j] = '''' then fl1 := not fl1;
  until (c = 0) or (j >= Length(Str));

  Result := Copy(Str, i + Length(OpenBracket), j - i - Length(OpenBracket));
  if i <> j then
    Inc(j, Length(CloseBracket) - 1);
end;

procedure frxCommonErrorHandler(Report: TfrxReport; const Text: String);
var
  e: Exception;
begin
  case Report.EngineOptions.NewSilentMode of
    simMessageBoxes: frxErrorMsg(Text);
    simReThrow: begin e := Exception.Create(Text); raise e; end;
  end;
end;

procedure frxErrorMsg(const Text: String);
begin
  Application.MessageBox(PChar(Text), PChar(frxResources.Get('mbError')),
    mb_Ok + mb_IconError);
end;

function frxConfirmMsg(const Text: String; Buttons: Integer): Integer;
begin
  Result := Application.MessageBox(PChar(Text),
    PChar(frxResources.Get('mbConfirm')), mb_IconQuestion + Buttons);
end;

procedure frxInfoMsg(const Text: String);
begin
  Application.MessageBox(PChar(Text), PChar(frxResources.Get('mbInfo')),
    mb_Ok + mb_IconInformation);
end;

function frxIsValidFloat(const Value: string): Boolean;
begin
  Result := True;
  try
    frxStrToFloat(Value);
  except
    Result := False;
  end;
end;

procedure frxAssignImages(Bitmap: TBitmap; dx, dy: Integer;
  ImgList1: TImageList; ImgList2: TImageList = nil);
var
  b: TBitmap;
  x, y: Integer;
  Done: Boolean;
begin
  b := TBitmap.Create;
  b.Width := dx;
  b.Height := dy;

  x := 0; y := 0;

  repeat
    b.Canvas.CopyRect(Rect(0, 0, dx, dy), Bitmap.Canvas, Rect(x, y, x + dx, y + dy));
    Done := y > Bitmap.Height;

    if not Done then
    begin
      ImgList1.AddMasked(b, b.TransparentColor);
      if ImgList2 <> nil then
      begin
        Inc(x, dx);
        b.Canvas.CopyRect(Rect(0, 0, dx, dy), Bitmap.Canvas, Rect(x, y, x + dx, y + dy));
        ImgList2.AddMasked(b, b.TransparentColor);
      end;
    end;

    Inc(x, dx);
    if x >= Bitmap.Width then
    begin
      x := 0;
      Inc(y, dy);
    end;
  until Done;

  b.Free;
end;

procedure frxDrawTransparent(Canvas: TCanvas; x, y: Integer; bmp: TBitmap);
var
  img: TImageList;
begin
  if Assigned(bmp) then
  begin
    img := TImageList.Create(nil);
    try
      img.Width := bmp.Width;
      img.Height := bmp.Height;
      img.AddMasked(bmp, bmp.TransparentColor);
      img.Draw(Canvas, x, y, 0);
      img.Clear;
    finally
      img.Free;
    end;
  end;
end;

procedure DrawBitmap(aCanvas: TCanvas; Dest: TRect; Bitmap: TBitmap);
var
  Info: PBitmapInfo;
  HInfo: HGLOBAL;
  InfoSize: DWord;
  Image: Pointer;
  HImage: HGLOBAL;
  ImageSize: DWord;
begin
  with Bitmap do
  begin
    GetDIBSizes(Handle, InfoSize, ImageSize);
    HInfo := GlobalAlloc(GMEM_MOVEABLE or GMEM_SHARE, InfoSize);
    Info := PBitmapInfo(GlobalLock(HInfo));
    try
      HImage := GlobalAlloc(GMEM_MOVEABLE or GMEM_SHARE, ImageSize);
      Image := Pointer(GlobalLock(HImage));
      try
        GetDIB(Handle, Palette, Info^, Image^);
        SetStretchBltMode(ACanvas.Handle, STRETCH_HALFTONE);
        with Info^.bmiHeader do
          StretchDIBits(aCanvas.Handle, Dest.Left, Dest.Top,
            Dest.RIght - Dest.Left, Dest.Bottom - Dest.Top,
            0, 0, biWidth, biHeight, Image, Info^, DIB_RGB_COLORS, SRCCOPY);
      finally
        GlobalUnlock(HImage);
        GlobalFree(HImage);
      end;
    finally
      GlobalUnlock(HInfo);
      GlobalFree(HInfo);
    end;
  end;
end;

procedure frxDrawGraphic(Canvas: TCanvas; DestRect: TRect; aGraph: TGraphic;
  IsPrinting: Boolean);
var
  Bitmap: TBitmap;
begin
  if (aGraph is TMetaFile) or not IsPrinting then
    Canvas.StretchDraw(DestRect, aGraph)
  else
  begin
    Bitmap := TBitmap.Create;
    try
      Bitmap.Width := aGraph.Width;
      Bitmap.Height := aGraph.Height;
      Bitmap.PixelFormat := pf32Bit;
      Bitmap.Canvas.Draw(0, 0, aGraph);
      DrawBitmap(Canvas, DestRect, Bitmap);
    finally
      Bitmap.Free;
    end;
  end
end;

procedure frxParsePageNumbers(const PageNumbers: String; List: TStrings;
  Total: Integer);
var
  i, j, n1, n2: Integer;
  s: String;
  IsRange: Boolean;
begin
  List.Clear;
  s := PageNumbers;
  while Pos(' ', s) <> 0 do
    Delete(s, Pos(' ', s), 1);
  if s = '' then Exit;

  if s[Length(s)] = '-' then
    s := s + IntToStr(Total);
  s := s + ',';
  i := 1; j := 1; n1 := 1;
  IsRange := False;

  while i <= Length(s) do
  begin
    if s[i] = ',' then
    begin
      n2 := StrToInt(Copy(s, j, i - j));
      j := i + 1;
      if IsRange then
        while n1 <= n2 do
        begin
          List.Add(IntToStr(n1));
          Inc(n1);
        end
      else
        List.Add(IntToStr(n2));
      IsRange := False;
    end
    else if s[i] = '-' then
    begin
      IsRange := True;
      n1 := StrToInt(Copy(s, j, i - j));
      j := i + 1;
    end;
    Inc(i);
  end;
end;

function HTMLRGBColor(Color: TColor): string;
var
  TheRgbValue : TColorRef;
begin
  TheRgbValue := ColorToRGB(Color);
  Result := '#' + Format('%.2x%.2x%.2x', [GetRValue(TheRGBValue), GetGValue(TheRGBValue), GetBValue(TheRGBValue)]);
end;


procedure ConvertOneItem(Item: TCollectionItem; ToAnsi: Boolean);
var
  i: Integer;
  TypeInfo: PTypeInfo;
  PropCount: Integer;
  PropList: PPropList;

  function Convert(const Value: String): String;
  var
    i: Integer;
  begin
    Result := '';
    i := 1;
    while i <= Length(Value) do
    begin
      if ToAnsi then
      begin
        if Value[i] >= #128 then
          Result := Result + #1 + Chr(Ord(Value[i]) - 128) else
          Result := Result + Value[i];
      end
      else
      begin
        if (Value[i] = #1) and (i < Length(Value)) then
        begin
          Result := Result + Chr(Ord(Value[i + 1]) + 128);
          Inc(i);
        end
        else
          Result := Result + Value[i];
      end;

      Inc(i);
    end;
  end;

  procedure DoStrProp;
  var
    Value, NewValue: String;
  begin
    Value := GetStrProp(Item, PropList[i]);
    NewValue := Convert(Value);
    if Value <> NewValue then
      SetStrProp(Item, PropList[i], NewValue);
  end;

  procedure DoVariantProp;
  var
    Value: Variant;
  begin
    Value := GetVariantProp(Item, PropList[i]);
    if (TVarData(Value).VType = varString) or (TVarData(Value).VType = varOleStr) then
    begin
      Value := Convert(Value);
      SetVariantProp(Item, PropList[i], Value);
    end;
  end;

begin
  TypeInfo := Item.ClassInfo;
  PropCount := GetTypeData(TypeInfo).PropCount;
  GetMem(PropList, PropCount * SizeOf(PPropInfo));
  GetPropInfos(TypeInfo, PropList);

  try
    for i := 0 to PropCount - 1 do
    begin
      case PropList[i].PropType^.Kind of
        tkString, tkLString, tkWString:
          DoStrProp;

        tkVariant:
          DoVariantProp;
      end;
    end;

  finally
    FreeMem(PropList, PropCount * SizeOf(PPropInfo));
  end;
end;

procedure frxWriteCollection(Collection: TCollection; Writer: TWriter;
  Owner: TfrxComponent);
var
  i, l: Integer;
  xs: TfrxXMLSerializer;
  s: String;
  vt: TValueType;
begin
  if Owner.IsWriting then
  begin
    { called from SaveToStream }
    Writer.WriteListBegin;
    xs := TfrxXMLSerializer.Create(nil);
    try
      xs.Owner := Owner.Report;
      for i := 0 to Collection.Count - 1 do
      begin
        Writer.WriteListBegin;
        s := xs.ObjToXML(Collection.Items[i]);
        vt := vaLString;
        Writer.Write(vt, SizeOf(vt));
        l := Length(s);
        Writer.Write(l, SizeOf(l));
        Writer.Write(s[1], l);
        Writer.WriteListEnd;
      end;
    finally
      Writer.WriteListEnd;
      xs.Free;
    end;
  end
  else
  begin
    { called from Delphi streamer }
    Writer.WriteCollection(Collection);
  end;
end;

procedure frxReadCollection(Collection: TCollection; Reader: TReader;
  Owner: TfrxComponent);
var
  i: Integer;
  vt: TValueType;
  xs: TfrxXMLSerializer;
  s: String;
  Item: TCollectionItem;
  NeedFree: Boolean;
begin
  vt := Reader.ReadValue;
  if vt <> vaCollection then
  begin
    { called from LoadFromStream }
    NeedFree := False;
    xs := nil;
    if Owner.Report <> nil then
      xs := TfrxXMLSerializer(Owner.Report.XMLSerializer);

    if xs = nil then
    begin
      xs := TfrxXMLSerializer.Create(nil);
      xs.Owner := Owner.Report;
      NeedFree := True;
    end;

    try
      Collection.Clear;

      while not Reader.EndOfList do
      begin
        Reader.ReadListBegin;
        Item := Collection.Add;
        s := Reader.ReadString;
        if NeedFree then
          xs.ReadPersistentStr(Owner.Report, Item, s)
        else
          xs.XMLToObj(s, Item);
        Reader.ReadListEnd;
      end;
    finally
      Reader.ReadListEnd;
      if NeedFree then
        xs.Free;
    end;
  end
  else
  begin
    { called from Delphi streamer }
    Reader.ReadCollection(Collection);
    for i := 0 to Collection.Count - 1 do
      ConvertOneItem(Collection.Items[i], False);
  end;
end;

function GetTemporaryFolder: String;
var
  Path: String;
begin
  Setlength(Path, MAX_PATH);
  SetLength(Path, GetTempPath(MAX_PATH, @Path[1]));
  Result := StrPas(@Path[1]);
end;

function GetTempFile: String;
var
  Path: String;
  FileName: String;
begin
  SetLength(Path, MAX_PATH);
  SetLength(Path, GetTempPath(MAX_PATH, @Path[1]));
  SetLength(FileName, MAX_PATH);
  GetTempFileName(@Path[1], PChar('fr'), 0, @FileName[1]);
  Result := StrPas(@FileName[1]);
end;

function frxCreateTempFile(const TempDir: String): String;
var
  Path: String;
  FileName: String;
begin
  Path := TempDir;
  if (Path <> '') and (Path[Length(Path)] <> '\') then
    Path := Path + '\';
  SetLength(FileName, MAX_PATH);
  if Path = '' then
  begin
    SetLength(Path, MAX_PATH);
    SetLength(Path, GetTempPath(MAX_PATH, @Path[1]));
  end
  else begin
    Path := Path + #0;
    SetLength(Path, MAX_PATH);
  end;
  GetTempFileName(@Path[1], PChar('fr'), 0, @FileName[1]);
  Result := StrPas(@FileName[1]);
end;

function GetAppFileName: String;
var
  fName: String;
  nsize: cardinal;
begin
  nsize := MAX_PATH;
  SetLength(fName,nsize);
  SetLength(fName, GetModuleFileName(hinstance, pchar(fName), nsize));
  Result := fName;
end;

function GetAppPath: String;
begin
  Result := ExtractFilePath(GetAppFileName);
end;

function frFloat2Str(const Value: Extended; const Prec: Integer = 2): String;
var
  i: Integer;
  IntVal: Integer;
begin
  IntVal := Trunc(Value);
  if IntVal <> Value then
    Result := Format('%.' + IntToStr(Prec)+ 'f', [Value])
  else
    Result := IntToStr(IntVal);
  if DecimalSeparator <> '.' then
  begin
    i := Pos(DecimalSeparator, Result);
    if i > 0 then
      Result[i] := '.';
  end;
end;

function frxReverseString(const AText: string): string;
var
  I: Integer;
  P: PChar;
begin
  SetLength(Result, Length(AText));
  P := PChar(Result);
  for I := Length(AText) downto 1 do
  begin
    P^ := AText[I];
    Inc(P);
  end;
end;


end.


//0f31356a91fea3356e5f76cdce90aa7b