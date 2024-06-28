
{******************************************}
{                                          }
{             FastReport v4.0              }
{           Files utilities unit           }
{                                          }
{            Copyright (c) 2006            }
{         by Alexander Fediachov,          }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxFileUtils;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, ShlObj, FileCtrl;

function GetFileSize(const FileName: String): Longint;
function StreamSearch(Strm: TStream; const StartPos: Longint; const Value: String): Longint;
function BrowseDialog(const Path:String; const Title: string = ''): string;
procedure DeleteFolder(const DirName: String);
{$IFNDEF Delphi6}
function DirectoryExists(const Name: string): Boolean;
{$ENDIF}

implementation

{$IFNDEF Delphi6}
function DirectoryExists(const Name: string): Boolean;
var
  Code: Integer;
begin
  Code := GetFileAttributes(PChar(Name));
  Result := (Code <> -1) and (FILE_ATTRIBUTE_DIRECTORY and Code <> 0);
end;
{$ENDIF}

function GetFileSize(const FileName: String): Longint;
var
  SRec: TSearchRec;
begin
  FindFirst(FileName, faAnyFile, SRec);
  Result := SRec.Size;
  FindClose(SRec);
end;

function StreamSearch(Strm: TStream; const StartPos: Longint; const Value: String): Longint;
var
  i, oldpos: Longint;
  s1: String;
  Stream: TMemoryStream;
begin
  Result := -1;
  try
    Stream := TMemoryStream.Create;
    oldpos := Strm.Position;
    try
      Strm.Position := 0;
      Stream.CopyFrom(Strm, 0);
      SetLength(s1, 1);
      i := 1;
      Stream.Position := StartPos;
      while (Stream.Position < Stream.Size) do
      begin
        Stream.Read(s1[1], 1);
        while (s1[1] = Value[i]) and (Stream.Position <= Stream.Size) and (Length(Value) > (i - 1)) do
        begin
          Stream.Read(s1[1], 1);
          Inc(i);
        end;
        if Length(Value) = (i - 1) then
        begin
          Result := Stream.Position - i;
          break;
        end else
          i := 1;
      end;
    finally
      Stream.Free;
    end;
    Strm.Position := oldpos;
  except
  end;
end;

function BrowseCallbackProc(hwnd: HWND; uMsg: UINT; lParam: LPARAM; lpData: LPARAM):integer; stdcall;
begin
  if  uMsg = BFFM_INITIALIZED then
    if lpData <> 0 then
      SendMessage(hwnd, BFFM_SETSELECTION, 1, lpData);
  Result := 0;
end;

function BrowseDialog(const Path: String; const Title: String = ''): string;
var
  lpItemID : PItemIDList;
  bi : TBrowseInfo;
  DisplayName : array[0..MAX_PATH] of char;
  TempPath : array[0..MAX_PATH] of char;
begin
  Result := Path;
  FillChar(bi, sizeof(TBrowseInfo), #0);
  bi.hwndOwner := GetActiveWindow;
  bi.pszDisplayName := @DisplayName;
  bi.lpszTitle := PChar(Title);
  bi.ulFlags := BIF_RETURNONLYFSDIRS + $0040;
  bi.lpfn := BrowseCallbackProc;
  bi.lParam := LPARAM(PChar(Path));
  lpItemID := SHBrowseForFolder(bi);
  if lpItemId <> nil then
  begin
    SHGetPathFromIDList(lpItemID, TempPath);
    Result := TempPath;
    GlobalFreePtr(lpItemID);
  end;
  if Result[Length(Result)] <> '\' then
    Result := Result + '\';
end;

{$WARNINGS OFF}
procedure DeleteFolder(const DirName: String);
var
  SearchRec: TSearchRec;
  i: Integer;
begin
  if DirectoryExists(DirName) then
  begin
    i := FindFirst(DirName + '\*.*', faAnyFile, SearchRec);
    while i = 0 do
    begin
      if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
      begin
        if (SearchRec.Attr and faDirectory) > 0 then
          DeleteFolder(DirName + '\' + SearchRec.Name)
        else if (SearchRec.Attr and faVolumeID) = 0 then
        try
          DeleteFile(PChar(DirName + '\' + SearchRec.Name));
        except
        end;
      end;
      i := FindNext(SearchRec);
    end;
    FindClose(SearchRec);
    try
      RemoveDirectory(PChar(DirName));
    except
    end;
  end;
end;
{$WARNINGS ON}

end.
