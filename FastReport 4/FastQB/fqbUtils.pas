{*******************************************}
{                                           }
{          FastQueryBuilder 1.03            }
{                                           }
{            Copyright (c) 2005             }
{             Fast Reports Inc.             }
{                                           }
{*******************************************}

{$I fqb.inc}

unit fqbUtils;

interface

uses Windows, Messages, Classes, SysUtils, fqbZLib;

function fqbStringCRC32(const Str: string): Cardinal;
function fqbGetUniqueFileName(const Prefix: String): string;
function fqbTrim(const Input: string; EArray: TSysCharSet):string;
function fqbParse(Char, S: string; Count: Integer; Last: Boolean = False): string;
function fqbBase64Decode(const S: String): String;
function fqbBase64Encode(const S: String): String;
function fqbCompress(const S: String): String;
function fqbDeCompress(const S: String): String;
procedure fqbDeflateStream(Source, Dest: TStream; Compression: TZCompressionLevel = zcDefault);
procedure fqbInflateStream(Source, Dest: TStream);


implementation

const
  Base64Charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

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


function fqbStringCRC32(const Str: string): Cardinal;
  var
    i: Integer;
    b: Byte;
    c: Cardinal;
begin
  c := $ffffffff;
  for i := 1 to Length(Str) do
  begin
    b := Byte(Str[i]);
    c := CrcTable[(c xor Cardinal(b)) and $ff] xor (c shr 8)
  end;
  Result := c xor $ffffffff
end;

function fqbGetUniqueFileName(const Prefix: String): string;
  var
    TempPath: array[0..MAX_PATH] of Char;
    FileName: String[255];
begin
   GetTempPath(SizeOf(TempPath) - 1, TempPath);
   GetTempFileName(TempPath, PChar(Prefix), 0, @FileName[1]);
   Result := StrPas(@FileName[1])
end;

function fqbTrim(const Input: string; EArray: TSysCharSet):string;
  var
    tmp: string;
begin
  Result := '';
  tmp := Input;
  while Length(tmp) <> 0 do
    if tmp[1] in EArray then
      Delete(tmp, 1, 1)
    else
      begin
        Result := Result + tmp[1];
        Delete(tmp, 1, 1)
      end;
  repeat
    if Pos('  ', Result) > 0 then
      Delete(Result, Pos('  ', Result) + 1, 1)
  until Pos('  ', Result) = 0;
end;

function fqbParse(Char, S: string; Count: Integer; Last: Boolean = False): string;
  var
    i: Integer;
    t: string;
begin
  if S[Length(S)] <> Char then
     S := S + Char;
  for i := 1 to Count do
    begin
      if Last then
        t := Copy(S, 0, Length(S) - 1)
      else
        t := Copy(S, 0, Pos(Char, S) - 1);
      S := Copy(S, Pos(Char, S) + 1, Length(S))
    end;
 Result := t
end;


function fqbBase64Decode(const S: String): String;
  var
    F, L, M, P: Integer;
    B, OutPos: Byte;
    OutB: Array[1..3] of Byte;
    Lookup: Array[Char] of Byte;
    R: PChar;
begin
  L := Length(S);
  P := 0;
  while (L - P > 0) and (S[L - P] = '=') do Inc(P);
  M := L - P;
  if M <> 0 then
  begin
    SetLength(Result, (M * 3) div 4);
    FillChar(Lookup, Sizeof(Lookup), #0);
    for F := 0 to 63 do
      Lookup[Base64Charset[F + 1]] := F;
    R := Pointer(Result);
    OutPos := 0;
    for F := 1 to L - P do
    begin
      B := Lookup[S[F]];
      case OutPos of
          0 : OutB[1] := B shl 2;
          1 : begin
                OutB[1] := OutB[1] or (B shr 4);
                R^ := Char(OutB[1]);
                Inc(R);
                OutB[2] := (B shl 4) and $FF
              end;
          2 : begin
                OutB[2] := OutB[2] or (B shr 2);
                R^ := Char(OutB[2]);
                Inc(R);
                OutB[3] := (B shl 6) and $FF
              end;
          3 : begin
                OutB[3] := OutB[3] or B;
                R^ := Char(OutB[3]);
                Inc(R)
              end
        end;
      OutPos := (OutPos + 1) mod 4
    end;
    if (OutPos > 0) and (P = 0) then
      if OutB[OutPos] <> 0 then
        Result := Result + Char(OutB[OutPos])
  end else
    Result := ''
end;

function fqbBase64Encode(const S: String): String;
  var
    R, C : Byte;
    F, L, M, N, U : Integer;
    P : PChar;
begin
  L := Length(S);
  if L > 0 then
  begin
    M := L mod 3;
    N := (L div 3) * 4 + M;
    if M > 0 then Inc(N);
    U := N mod 4;
    if U > 0 then
    begin
      U := 4 - U;
      Inc(N, U)
    end;
    SetLength(Result, N);
    P := Pointer(Result);
    R := 0;
    for F := 0 to L - 1 do
    begin
      C := Byte(S [F + 1]);
      case F mod 3 of
        0 : begin
              P^ := Base64Charset[C shr 2 + 1];
              Inc(P);
              R := (C and 3) shl 4
            end;
        1 : begin
              P^ := Base64Charset[C shr 4 + R + 1];
              Inc(P);
              R := (C and $0F) shl 2
            end;
        2 : begin
              P^ := Base64Charset[C shr 6 + R + 1];
              Inc(P);
              P^ := Base64Charset[C and $3F + 1];
              Inc(P)
            end
      end
    end;
    if M > 0 then
    begin
      P^ := Base64Charset[R + 1];
      Inc(P)
    end;
    for F := 1 to U do
    begin
      P^ := '=';
      Inc(P)
    end;
  end else
    Result := ''
end;

function fqbCompress(const S: String): String;
  var
    st, stres: TStringStream;
begin
  st := TStringStream.Create(s);
  stres := TStringStream.Create('');

  fqbDeflateStream(st, stres, zcMax);
  Result := fqbBase64Encode(stres.DataString);

  stres.Free;
  st.Free
end;

function fqbDeCompress(const S: String): String;
  var
    st, stres: TStringStream;
begin

  st := TStringStream.Create(fqbBase64Decode(s));
  stres := TStringStream.Create('');

  fqbInflateStream(st, stres);
  Result := stres.DataString;

  stres.Free;
  st.Free
end;

procedure fqbDeflateStream(Source, Dest: TStream; Compression: TZCompressionLevel = zcDefault);
var
  Compressor: TZCompressionStream;
begin
  Compressor := TZCompressionStream.Create(Dest, TZCompressionLevel(Compression));
  try
    Compressor.CopyFrom(Source, 0)
  finally
    Compressor.Free
  end
end;

procedure fqbInflateStream(Source, Dest: TStream);
var
  FTempStream: TMemoryStream;
  UnknownPtr: Pointer;
  NewSize: Integer;
begin
  FTempStream := TMemoryStream.Create;
  try
    FTempStream.CopyFrom(Source, 0);
    // uncompress data and save it to the Dest
    ZDeCompress(FTempStream.Memory, FTempStream.Size, UnknownPtr, NewSize);
    Dest.Write(UnknownPtr^, NewSize);
    FreeMem(UnknownPtr, NewSize)
  finally
    FTempStream.Free
  end
end;

end.
