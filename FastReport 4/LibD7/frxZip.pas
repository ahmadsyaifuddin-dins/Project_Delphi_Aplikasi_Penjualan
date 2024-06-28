
{******************************************}
{                                          }
{             FastReport v4.0              }
{         ZIP archiver support unit        }
{                                          }
{         Copyright (c) 1998-2006          }
{          by Alexander Fediachov,         }
{             Fast Reports Inc.            }
{                                          }
{******************************************}

unit frxZip;

{$I frx.inc}

interface

uses Classes, Windows, frxZLib, frxGZip, frxUtils, frxFileUtils;

type
  DWORD = Longword;
  TfrxZipLocalFileHeader = class;
  TfrxZipCentralDirectory = class;
  TfrxZipFileHeader = class;

  TfrxZipArchive = class(TObject)
  private
    FRootFolder: String;
    FErrors: TStringList;
    FFileList: TStringList;
    FComment: String;
    FProgress: TNotifyEvent;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure AddFile(const FileName: String);
    procedure AddDir(const DirName: String);
    procedure SaveToStream(const Stream: TStream);
    procedure SaveToFile(const Filename: String);
    property RootFolder: String read FRootFolder write FRootFolder;
    property Errors: TStringList read FErrors;
    property Comment: String read FComment write FComment;
    property FileCount: Integer read GetCount;
    property OnProgress: TNotifyEvent read FProgress write FProgress;
  end;

  TfrxZipLocalFileHeader = class(TObject)
  private
    FLocalFileHeaderSignature: DWORD;
    FVersion: WORD;
    FGeneralPurpose: WORD;
    FCompressionMethod: WORD;
    FCrc32: DWORD;
    FLastModFileDate: WORD;
    FLastModFileTime: WORD;
    FCompressedSize: DWORD;
    FUnCompressedSize: DWORD;
    FExtraField: String;
    FFileName: String;
    FFileNameLength: WORD;
    FExtraFieldLength: WORD;
    procedure SetExtraField(const Value: String);
    procedure SetFileName(const Value: String);
  public
    constructor Create;
    procedure SaveToStream(const Stream: TStream);
    property LocalFileHeaderSignature: DWORD read FLocalFileHeaderSignature;
    property Version: WORD read FVersion write FVersion;
    property GeneralPurpose: WORD read FGeneralPurpose write FGeneralPurpose;
    property CompressionMethod: WORD read FCompressionMethod write FCompressionMethod;
    property LastModFileTime: WORD read FLastModFileTime write FLastModFileTime;
    property LastModFileDate: WORD read FLastModFileDate write FLastModFileDate;
    property Crc32: DWORD read FCrc32 write FCrc32;
    property CompressedSize: DWORD read FCompressedSize write FCompressedSize;
    property UnCompressedSize: DWORD read FUnCompressedSize write FUnCompressedSize;
    property FileNameLength: WORD read FFileNameLength write FFileNameLength;
    property ExtraFieldLength: WORD read FExtraFieldLength write FExtraFieldLength;
    property FileName: String read FFileName write SetFileName;
    property ExtraField: String read FExtraField write SetExtraField;
  end;

  TfrxZipCentralDirectory = class(TObject)
  private
    FEndOfChentralDirSignature: DWORD;
    FNumberOfTheDisk: WORD;
    FTotalOfEntriesCentralDirOnDisk: WORD;
    FNumberOfTheDiskStartCentralDir: WORD;
    FTotalOfEntriesCentralDir: WORD;
    FSizeOfCentralDir: DWORD;
    FOffsetStartingDiskDir: DWORD;
    FComment: String;
    FCommentLength: WORD;
    procedure SetComment(const Value: String);
  public
    constructor Create;
    procedure SaveToStream(const Stream: TStream);
    property EndOfChentralDirSignature: DWORD read FEndOfChentralDirSignature;
    property NumberOfTheDisk: WORD read FNumberOfTheDisk write FNumberOfTheDisk;
    property NumberOfTheDiskStartCentralDir: WORD
      read FNumberOfTheDiskStartCentralDir write FNumberOfTheDiskStartCentralDir;
    property TotalOfEntriesCentralDirOnDisk: WORD
      read FTotalOfEntriesCentralDirOnDisk write FTotalOfEntriesCentralDirOnDisk;
    property TotalOfEntriesCentralDir: WORD
      read FTotalOfEntriesCentralDir write FTotalOfEntriesCentralDir;
    property SizeOfCentralDir: DWORD read FSizeOfCentralDir write FSizeOfCentralDir;
    property OffsetStartingDiskDir: DWORD read FOffsetStartingDiskDir write FOffsetStartingDiskDir;
    property CommentLength: WORD read FCommentLength write FCommentLength;
    property Comment: String read FComment write SetComment;
  end;

  TfrxZipFileHeader = class(TObject)
  private
    FCentralFileHeaderSignature: DWORD;
    FRelativeOffsetLocalHeader: DWORD;
    FUnCompressedSize: DWORD;
    FCompressedSize: DWORD;
    FCrc32: DWORD;
    FExternalFileAttribute: DWORD;
    FExtraField: String;
    FFileComment: String;
    FFileName: String;
    FCompressionMethod: WORD;
    FDiskNumberStart: WORD;
    FLastModFileDate: WORD;
    FLastModFileTime: WORD;
    FVersionMadeBy: WORD;
    FGeneralPurpose: WORD;
    FFileNameLength: WORD;
    FInternalFileAttribute: WORD;
    FExtraFieldLength: WORD;
    FVersionNeeded: WORD;
    FFileCommentLength: WORD;
    procedure SetExtraField(const Value: String);
    procedure SetFileComment(const Value: String);
    procedure SetFileName(const Value: String);
  public
    constructor Create;
    procedure SaveToStream(const Stream: TStream);
    property CentralFileHeaderSignature: DWORD read FCentralFileHeaderSignature;
    property VersionMadeBy: WORD read FVersionMadeBy;
    property VersionNeeded: WORD read FVersionNeeded;
    property GeneralPurpose: WORD read FGeneralPurpose write FGeneralPurpose;
    property CompressionMethod: WORD read FCompressionMethod write FCompressionMethod;
    property LastModFileTime: WORD read FLastModFileTime write FLastModFileTime;
    property LastModFileDate: WORD read FLastModFileDate write FLastModFileDate;
    property Crc32: DWORD read FCrc32 write FCrc32;
    property CompressedSize: DWORD read FCompressedSize write FCompressedSize;
    property UnCompressedSize: DWORD read FUnCompressedSize write FUnCompressedSize;
    property FileNameLength: WORD read FFileNameLength write FFileNameLength;
    property ExtraFieldLength: WORD read FExtraFieldLength write FExtraFieldLength;
    property FileCommentLength: WORD read FFileCommentLength write FFileCommentLength;
    property DiskNumberStart: WORD read FDiskNumberStart write FDiskNumberStart;
    property InternalFileAttribute: WORD read FInternalFileAttribute write FInternalFileAttribute;
    property ExternalFileAttribute: DWORD read FExternalFileAttribute write FExternalFileAttribute;
    property RelativeOffsetLocalHeader: DWORD read FRelativeOffsetLocalHeader write FRelativeOffsetLocalHeader;
    property FileName: String read FFileName write SetFileName;
    property ExtraField: String read FExtraField write SetExtraField;
    property FileComment: String read FFileComment write SetFileComment;
  end;

  TfrxZipLocalFile = class(TObject)
  private
    FLoacalFileHeader: TfrxZipLocalFileHeader;
    FFileData: TMemoryStream;
    FOffset: DWORD;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SaveToStream(const Stream: TStream);
    property LocalFileHeader: TfrxZipLocalFileHeader read FLoacalFileHeader;
    property FileData: TMemoryStream read FFileData write FFileData;
    property Offset: DWORD read FOffset write FOffset;
  end;

implementation

uses SysUtils;

const
  ZIP_VERSIONMADEBY = 20;
  ZIP_NONE = 0;
  ZIP_DEFLATED = 8;
  ZIP_MINSIZE = 128;

{ TfrxZipLocalFile }

constructor TfrxZipLocalFile.Create;
begin
  FLoacalFileHeader := TfrxZipLocalFileHeader.Create;
  FOffset := 0;
end;

destructor TfrxZipLocalFile.Destroy;
begin
  FLoacalFileHeader.Free;
  inherited;
end;

procedure TfrxZipLocalFile.SaveToStream(const Stream: TStream);
begin
  FLoacalFileHeader.SaveToStream(Stream);
  FFileData.Position := 0;
  FFileData.SaveToStream(Stream);
end;

{ TfrxZipLocalFileHeader }

constructor TfrxZipLocalFileHeader.Create;
begin
  inherited;
  FLocalFileHeaderSignature := $04034b50;
  FVersion := ZIP_VERSIONMADEBY;
  FGeneralPurpose := 0;
  FCompressionMethod := ZIP_NONE;
  FCrc32 := 0;
  FLastModFileDate := 0;
  FLastModFileTime := 0;
  FCompressedSize := 0;
  FUnCompressedSize := 0;
  FExtraField := '';
  FFileName := '';
  FFileNameLength := 0;
  FExtraFieldLength := 0;
end;

procedure TfrxZipLocalFileHeader.SaveToStream(const Stream: TStream);
begin
  Stream.Write(FLocalFileHeaderSignature, 4);
  Stream.Write(FVersion, 2);
  Stream.Write(FGeneralPurpose, 2);
  Stream.Write(FCompressionMethod, 2);
  Stream.Write(FLastModFileTime, 2);
  Stream.Write(FLastModFileDate, 2);
  Stream.Write(FCrc32, 4);
  Stream.Write(FCompressedSize, 4);
  Stream.Write(FUnCompressedSize, 4);
  Stream.Write(FFileNameLength, 2);
  Stream.Write(FExtraFieldLength, 2);
  if FFileNameLength > 0 then
    Stream.Write(FFileName[1], FFileNameLength);
  if FExtraFieldLength > 0 then
    Stream.Write(FExtraField[1], FExtraFieldLength);
end;

procedure TfrxZipLocalFileHeader.SetExtraField(const Value: String);
begin
  FExtraField := Value;
  FExtraFieldLength := Length(Value);
end;

procedure TfrxZipLocalFileHeader.SetFileName(const Value: String);
begin
  FFileName :=  StringReplace(Value, '\', '/', [rfReplaceAll]);
  FFileNameLength := Length(Value);
end;

{ TfrxZipCentralDirectory }

constructor TfrxZipCentralDirectory.Create;
begin
  inherited;
  FEndOfChentralDirSignature := $06054b50;
  FNumberOfTheDisk := 0;
  FNumberOfTheDiskStartCentralDir := 0;
  FTotalOfEntriesCentralDirOnDisk := 0;
  FTotalOfEntriesCentralDir := 0;
  FSizeOfCentralDir := 0;
  FOffsetStartingDiskDir := 0;
  FCommentLength := 0;
  FComment := '';
end;

procedure TfrxZipCentralDirectory.SaveToStream(const Stream: TStream);
begin
  Stream.Write(FEndOfChentralDirSignature, 4);
  Stream.Write(FNumberOfTheDisk, 2);
  Stream.Write(FNumberOfTheDiskStartCentralDir, 2);
  Stream.Write(FTotalOfEntriesCentralDirOnDisk, 2);
  Stream.Write(FTotalOfEntriesCentralDir, 2);
  Stream.Write(FSizeOfCentralDir, 4);
  Stream.Write(FOffsetStartingDiskDir, 4);
  Stream.Write(FCommentLength, 2);
  if FCommentLength > 0 then
    Stream.Write(FComment[1], FCommentLength);
end;

procedure TfrxZipCentralDirectory.SetComment(const Value: String);
begin
  FComment := Value;
  FCommentLength := Length(Value);
end;

{ TfrxZipFileHeader }

constructor TfrxZipFileHeader.Create;
begin
  FCentralFileHeaderSignature := $02014b50;
  FRelativeOffsetLocalHeader := 0;
  FUnCompressedSize := 0;
  FCompressedSize := 0;
  FCrc32 := 0;
  FExternalFileAttribute := 0;
  FExtraField := '';
  FFileComment := '';
  FFileName := '';
  FCompressionMethod := 0;
  FDiskNumberStart := 0;
  FLastModFileDate := 0;
  FLastModFileTime := 0;
  FVersionMadeBy := ZIP_VERSIONMADEBY;
  FGeneralPurpose := 0;
  FFileNameLength := 0;
  FInternalFileAttribute := 0;
  FExtraFieldLength := 0;
  FVersionNeeded := ZIP_VERSIONMADEBY;
  FFileCommentLength := 0;
end;

procedure TfrxZipFileHeader.SaveToStream(const Stream: TStream);
begin
  Stream.Write(FCentralFileHeaderSignature, 4);
  Stream.Write(FVersionMadeBy, 2);
  Stream.Write(FVersionNeeded, 2);
  Stream.Write(FGeneralPurpose, 2);
  Stream.Write(FCompressionMethod, 2);
  Stream.Write(FLastModFileTime, 2);
  Stream.Write(FLastModFileDate, 2);
  Stream.Write(FCrc32, 4);
  Stream.Write(FCompressedSize, 4);
  Stream.Write(FUnCompressedSize, 4);
  Stream.Write(FFileNameLength, 2);
  Stream.Write(FExtraFieldLength, 2);
  Stream.Write(FFileCommentLength, 2);
  Stream.Write(FDiskNumberStart, 2);
  Stream.Write(FInternalFileAttribute, 2);
  Stream.Write(FExternalFileAttribute, 4);
  Stream.Write(FRelativeOffsetLocalHeader, 4);
  Stream.Write(FFilename[1], FFileNameLength);
  Stream.Write(FExtraField[1], FExtraFieldLength);
  Stream.Write(FFileComment[1], FFileCommentLength);
end;

procedure TfrxZipFileHeader.SetExtraField(const Value: String);
begin
  FExtraField := Value;
  FExtraFieldLength := Length(Value);
end;

procedure TfrxZipFileHeader.SetFileComment(const Value: String);
begin
  FFileComment := Value;
  FFileNameLength := Length(Value);
end;

procedure TfrxZipFileHeader.SetFileName(const Value: String);
begin
  FFileName := StringReplace(Value, '\', '/', [rfReplaceAll]);
  FFileNameLength := Length(Value);
end;

{ TfrxZipArchive }

procedure TfrxZipArchive.AddDir(const DirName: String);
var
  SRec: TSearchRec;
  i: Integer;
  s: String;
begin
  if DirectoryExists(DirName) then
  begin
    s := DirName;
    if s[Length(s)] <> '\' then
      s := s + '\';
    i := FindFirst(s + '*.*', faDirectory + faArchive, SRec);
    try
      while i = 0 do
      begin
        if (SRec.Name <> '.') and (SRec.Name <> '..') then
        begin
          if (SRec.Attr and faDirectory) = faDirectory then
            AddDir(s + SRec.Name)
          else
            AddFile(s + SRec.Name);
        end;
        i := FindNext(SRec);
      end;
    finally
      FindClose(SRec);
    end;
  end;
end;

procedure TfrxZipArchive.AddFile(const FileName: String);
begin
  if FileExists(FileName) then
  begin
    FFileList.Add(FileName);
    if FRootFolder = '' then
      FRootFolder := ExtractFilePath(FileName);
  end
  else
    FErrors.Add('File ' + FileName + ' not found!');
end;

procedure TfrxZipArchive.Clear;
begin
  FErrors.Clear;
  FFileList.Clear;
  FRootFolder := '';
  FComment := '';
end;

constructor TfrxZipArchive.Create;
begin
  FProgress := nil;
  FErrors := TStringList.Create;
  FFileList := TStringList.Create;
  Clear;
end;

destructor TfrxZipArchive.Destroy;
begin
  FErrors.Free;
  FFileList.Free;
  inherited;
end;

function TfrxZipArchive.GetCount: Integer;
begin
  Result := FFileList.Count;
end;

procedure TfrxZipArchive.SaveToFile(const FileName: String);
var
  f: TFileStream;
begin
  f := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(f);
  finally
    f.Free;
  end;
end;

procedure TfrxZipArchive.SaveToStream(const Stream: TStream);
var
  i: Integer;
  ZipFile: TfrxZipLocalFile;
  ZipFileHeader: TfrxZipFileHeader;
  ZipDir: TfrxZipCentralDirectory;
  FileStream: TFileStream;
  TempStream: TMemoryStream;
  FileName: String;
  CentralStartPos, CentralEndPos: DWORD;
  LFT, LFT2: TFileTime;
  FDate, FTime: WORD;
begin
  for i := 0 to FFileList.Count - 1 do
  begin
    ZipFile := TfrxZipLocalFile.Create;
    ZipFile.FileData := TMemoryStream.Create;
    try
      FileName := StringReplace(FFileList[i], FRootFolder, '', []);
      ZipFile.LocalFileHeader.FileName := FileName;
      FileStream := TFileStream.Create(FFileList[i], fmOpenRead + fmShareDenyWrite);
      try
        if FileStream.Size > ZIP_MINSIZE then
        begin
          FileStream.Position := 0;
          TempStream := TMemoryStream.Create;
          try
            frxDeflateStream(FileStream, TempStream);
            TempStream.Position := 2;
            ZipFile.FileData.CopyFrom(TempStream, TempStream.Size - 6);
          finally
            TempStream.Free;
          end;
          ZipFile.LocalFileHeader.CompressionMethod := ZIP_DEFLATED;
        end
        else
        begin
          ZipFile.FileData.CopyFrom(FileStream, 0);
          ZipFile.LocalFileHeader.CompressionMethod := ZIP_NONE;
        end;
        ZipFile.LocalFileHeader.CompressedSize := ZipFile.FileData.Size;
        ZipFile.LocalFileHeader.UnCompressedSize := FileStream.Size;
        TempStream := TMemoryStream.Create;
        try
          TempStream.CopyFrom(FileStream, 0);
          ZipFile.LocalFileHeader.Crc32 := frxStreamCRC32(TempStream);
        finally
          TempStream.Free;
        end;
        ZipFile.Offset := Stream.Position;
        GetFileTime(FileStream.Handle, @LFT, nil, nil);
        FileTimeToLocalFileTime(LFT, LFT2);
        FileTimeToDosDateTime(LFT2, FDate, FTime);
        ZipFile.LocalFileHeader.LastModFileDate := FDate;
        ZipFile.LocalFileHeader.LastModFileTime := FTime;
      finally
        FileStream.Free;
      end;
      ZipFile.SaveToStream(Stream);
      if Assigned(FProgress) then
        FProgress(Self);
    finally
      ZipFile.FileData.Free;
      ZipFile.FileData := nil;
    end;
    FFileList.Objects[i] := ZipFile;
  end;
  CentralStartPos := Stream.Position;
  for i := 0 to FFileList.Count - 1 do
  begin
    ZipFile := TfrxZipLocalFile(FFileList.Objects[i]);
    ZipFileHeader := TfrxZipFileHeader.Create;
    try
      ZipFileHeader.CompressionMethod := ZipFile.LocalFileHeader.CompressionMethod;
      ZipFileHeader.LastModFileTime := ZipFile.LocalFileHeader.LastModFileTime;
      ZipFileHeader.LastModFileDate := ZipFile.LocalFileHeader.LastModFileDate;
      ZipFileHeader.GeneralPurpose := ZipFile.LocalFileHeader.GeneralPurpose;
      ZipFileHeader.Crc32 := ZipFile.LocalFileHeader.Crc32;
      ZipFileHeader.CompressedSize := ZipFile.LocalFileHeader.CompressedSize;
      ZipFileHeader.UnCompressedSize := ZipFile.LocalFileHeader.UnCompressedSize;
      ZipFileHeader.RelativeOffsetLocalHeader := ZipFile.Offset;
      ZipFileHeader.FileName := ZipFile.LocalFileHeader.FileName;
      ZipFileHeader.SaveToStream(Stream);
    finally
      ZipFileHeader.Free;
    end;
    ZipFile.Free;
  end;
  CentralEndPos := Stream.Position;
  ZipDir := TfrxZipCentralDirectory.Create;
  try
    ZipDir.TotalOfEntriesCentralDirOnDisk := FFileList.Count;
    ZipDir.TotalOfEntriesCentralDir := FFileList.Count;
    ZipDir.SizeOfCentralDir := CentralEndPos - CentralStartPos;
    ZipDir.OffsetStartingDiskDir := CentralStartPos;
    ZipDir.SaveToStream(Stream);
  finally
    ZipDir.Free;
  end;
end;

end.