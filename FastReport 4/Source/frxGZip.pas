
{******************************************}
{                                          }
{             FastReport v4.0              }
{         GZIP compress/decompress         }
{                                          }
{            Copyright (c) 2004            }
{          by Alexander Fediachov,         }
{             Fast Reports, Inc.           }
{                                          }
{******************************************}

unit frxGZip;

interface

{$I frx.inc}

uses Windows, Classes, SysUtils, frxZLib, frxClass;

type
  TfrxCompressionLevel = (gzNone, gzFastest, gzDefault, gzMax);

  TfrxGZipCompressor = class(TfrxCustomCompressor)
  public
    procedure Compress(Dest: TStream); override;
    function Decompress(Source: TStream): Boolean; override;
  end;


procedure frxCompressStream(Source, Dest: TStream;
  Compression: TfrxCompressionLevel = gzDefault; FileName: String = '');
function frxDecompressStream(Source, Dest: TStream): String;
procedure frxDeflateStream(Source, Dest: TStream;
  Compression: TfrxCompressionLevel = gzDefault);
procedure frxInflateStream(Source, Dest: TStream);


implementation

uses frxUtils;

procedure frxCompressStream(Source, Dest: TStream;
  Compression: TfrxCompressionLevel = gzDefault; FileName: String = '');
var
  header: array [0..3] of Byte;
  Compressor: TZCompressionStream;
  Size: Cardinal;
  CRC: Cardinal;
begin
  CRC := frxStreamCRC32(Source);
  Size := Source.Size;
  if FileName = '' then
    FileName := '1';
  FileName := FileName + #0;

  // put gzip header
  header[0] := $1f; // ID1 (IDentification 1)
  header[1] := $8b; // ID2 (IDentification 2)
  header[2] := $8;  // CM (Compression Method) CM = 8 denotes the "deflate"
  header[3] := $8;  // FLG (FLaGs) bit 3   FNAME
  Dest.Write(header, 4);

  // reserve 4 bytes in MTIME field
  Dest.Write(header, 4);

  header[0] := 0; // XFL (eXtra FLags) XFL = 2 - compressor used maximum compression
  header[1] := 0; // OS (Operating System) 0 - FAT filesystem (MS-DOS, OS/2, NT/Win32)
  Dest.Write(header, 2);

  // original file name, zero-terminated
  Dest.Write(FileName[1], Length(FileName));

  // seek back to skip 2 bytes zlib header
  Dest.Seek(-2, soFromCurrent);

  // put compressed data
  Compressor := TZCompressionStream.Create(Dest, TZCompressionLevel(Compression));
  try
    Compressor.CopyFrom(Source, 0);
  finally
    Compressor.Free;
  end;

  // get adler32 checksum
  Dest.Seek(-4, soFromEnd);
  Dest.Read(header, 4);
  // write it to the header (to MTIME field)
  Dest.Position := 4;
  Dest.Write(header, 4);

  // restore original file name (it was corrupted by zlib header)
  Dest.Seek(2, soFromCurrent);
  Dest.Write(FileName[1], Length(FileName));

  // put crc32 and length
  Dest.Seek(-4, soFromEnd);
  Dest.Write(CRC, 4);
  Dest.Write(Size, 4);
end;

function frxDecompressStream(Source, Dest: TStream): String;
var
  s: String;
  header: array [0..3] of byte;
  adler32: Integer;
  FTempStream: TMemoryStream;
  UnknownPtr: Pointer;
  NewSize: Integer;
begin
  s := '';

  // read gzip header
  Source.Read(header, 4);
  if (header[0] = $1f) and (header[1] = $8b) and (header[2] = $8) then
  begin
    Source.Read(adler32, 4);
    Source.Read(header, 2);
    if (header[3] and $8) <> 0 then
    begin
      Source.Read(header, 1);
      while header[0] <> 0 do
      begin
        s := s + Char(header[0]);
        Source.Read(header, 1);
      end;
    end;
  end;

  FTempStream := TMemoryStream.Create;
  try
    // put zlib header
    s := #$78#$DA;
    FTempStream.Write(s[1], 2);
    // put compressed data, skip gzip's crc32 and filelength
    FTempStream.CopyFrom(Source, Source.Size - Source.Position - 8);
    // put adler32
    FTempStream.Write(adler32, 4);

    // uncompress data and save it to the Dest
    ZDeCompress(FTempStream.Memory, FTempStream.Size, UnknownPtr, NewSize);
    Dest.Write(UnknownPtr^, NewSize);
    FreeMem(UnknownPtr, NewSize);
  finally
    FTempStream.Free;
  end;
  Result := s;
end;

procedure frxDeflateStream(Source, Dest: TStream;
  Compression: TfrxCompressionLevel = gzDefault);
var
  Compressor: TZCompressionStream;
begin
  Compressor := TZCompressionStream.Create(Dest, TZCompressionLevel(Compression));
  try
    Compressor.CopyFrom(Source, 0);
  finally
    Compressor.Free;
  end;
end;

procedure frxInflateStream(Source, Dest: TStream);
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
    FreeMem(UnknownPtr, NewSize);
  finally
    FTempStream.Free;
  end;
end;


{ TfrxGZipCompressor }

procedure TfrxGZipCompressor.Compress(Dest: TStream);
var
  Compression: TfrxCompressionLevel;
  FileName: String;
begin
  if IsFR3File then
  begin
    Compression := gzMax;
    FileName := '1.fr3';
  end
  else
  begin
    Compression := gzDefault;
    FileName := '1.fp3';
  end;
  frxCompressStream(Stream, Dest, Compression, FileName);
end;

function TfrxGZipCompressor.Decompress(Source: TStream): Boolean;
var
  Signature: array[0..1] of Byte;
begin
  Source.Read(Signature, 2);
  Source.Seek(-2, soFromCurrent);
  Result := (Signature[0] = $1F) and (Signature[1] = $8B);
  if Result then
    frxDecompressStream(Source, Stream);
  Stream.Position := 0;
end;


end.


//0f31356a91fea3356e5f76cdce90aa7b