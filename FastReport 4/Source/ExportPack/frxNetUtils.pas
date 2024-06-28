
{******************************************}
{                                          }
{             FastReport v4.0              }
{         Network utilities unit           }
{                                          }
{            Copyright (c) 2006            }
{         by Alexander Fediachov,          }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxNetUtils;

{$I frx.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Registry;

function DateTimeToRFCDateTime(const D: TDateTime): String;
function GMTDateTimeToRFCDateTime(const D: TDateTime): String;
function PadRight(const S: String; const PadChar: Char; const Len: Integer): String;
function PadLeft(const S: String; const PadChar: Char; const Len: Integer): String;
function Base64Encode(const S: String): String;
function Base64Decode(const S: String): String;
function GetFileMIMEType(const FileName: String): String;
function GetSocketErrorText(const ErrorCode: integer):string;
function ParseHeaderField(const Field: String; const Header: String): String;
procedure PMessages;

implementation

const
  Base64Charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  RFCDayNames : Array[1..7] of String = (
      'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat');
  RFCMonthNames : Array[1..12] of String = (
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');

function GMTDateTimeToRFCDateTime(const D: TDateTime): String;
var
  Ho, Mi, Se, Ms : Word;
  Ye, Mo, Da : Word;
begin
  DecodeTime(D, Ho, Mi, Se, Ms);
  DecodeDate(D, Ye, Mo, Da);
  Result := RFCDayNames[DayOfWeek(D)] + ', ';
  Result := Result + PadLeft(IntToStr(Da), '0', 2) + ' ' +
    RFCMonthNames[Mo] + ' ' + IntToStr(Ye) + ' ';
  Result := Result + PadLeft(IntToStr(Ho), '0', 2) + ':' + PadLeft(IntToStr(Mi), '0', 2);
  Result := Result + ':' + PadLeft(IntToStr(Se), '0', 2);
  Result := Result + ' GMT';
end;

function GMTBias : Integer;
var
  TZI : TTimeZoneInformation;
begin
  if GetTimeZoneInformation(TZI) = TIME_ZONE_ID_DAYLIGHT then
    Result := TZI.DaylightBias
  else
    Result := 0;
  Result := Result + TZI.Bias;
end;

function DateTimeToRFCDateTime(const D: TDateTime): String;
begin
  Result := GMTDateTimeToRFCDateTime(D + GMTBias / (24.0 * 60.0));
end;

function PadLeft(const S: String; const PadChar: Char; const Len: Integer): String;
var
  F, L, P, M : Integer;
  I, J: PChar;
begin
  if Len > 0 then
  begin
    M := Length(S);
    if Len <> M then
    begin
      L := Len;
      P := L - M;
      if P < 0 then
        P := 0;
      SetLength(Result, L);
      if P > 0 then
        FillChar(Pointer(Result)^, P, Ord(PadChar));
      if L > P then
      begin
        I := Pointer(Result);
        J := Pointer(S);
        Inc(I, P);
        for F := 1 to L - P do
        begin
          I^ := J^;
          Inc(I);
          Inc(J);
        end;
      end;
    end else
      Result := S;
  end else
    Result := '';
end;

function PadRight(const S: String; const PadChar: Char; const Len: Integer): String;
var
  F, L, P, M : Integer;
  I, J: PChar;
begin
  if Len > 0 then
  begin
    M := Length(S);
    if Len <> M then
    begin
      L := Len;
      P := L - M;
      if P < 0 then
        P := 0;
      SetLength(Result, L);
      if L > P then
      begin
        I := Pointer(Result);
        J := Pointer(S);
        for F := 1 to L - P do
        begin
          I^ := J^;
          Inc(I);
          Inc(J);
        end;
      end;
      if P > 0 then
        FillChar(Result[L - P + 1], P, Ord(PadChar));
    end else
      Result := S;
  end else
    Result := '';
end;

function Base64Encode(const S: String): String;
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
      Inc(N, U);
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
              R := (C and 3) shl 4;
            end;
        1 : begin
              P^ := Base64Charset[C shr 4 + R + 1];
              Inc(P);
              R := (C and $0F) shl 2;
            end;
        2 : begin
              P^ := Base64Charset[C shr 6 + R + 1];
              Inc(P);
              P^ := Base64Charset[C and $3F + 1];
              Inc(P);
            end;
      end;
    end;
    if M > 0 then
    begin
      P^ := Base64Charset[R + 1];
      Inc(P);
    end;
    for F := 1 to U do
    begin
      P^ := '=';
      Inc(P);
    end;
  end else
    Result := '';
end;

function Base64Decode(const S: String): String;
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
                OutB[2] := (B shl 4) and $FF;
              end;
          2 : begin
                OutB[2] := OutB[2] or (B shr 2);
                R^ := Char(OutB[2]);
                Inc(R);
                OutB[3] := (B shl 6) and $FF;
              end;
          3 : begin
                OutB[3] := OutB[3] or B;
                R^ := Char(OutB[3]);
                Inc(R);
              end;
        end;
      OutPos := (OutPos + 1) mod 4;
    end;
    if (OutPos > 0) and (P = 0) then
      if OutB[OutPos] <> 0 then
        Result := Result + Char(OutB[OutPos]);
  end else
    Result := '';
end;

function GetFileMIMEType(const FileName: String): String;
var
  Registry: TRegistry;
  ext: String;
begin
  Result := 'application/octet-stream';
  ext := ExtractFileExt(FileName);
  Registry  := TRegistry.Create;
  try
    Registry.RootKey := HKEY_CLASSES_ROOT;
    if Registry.KeyExists(ext) then
    begin
      Registry.OpenKey(ext, false);
      Result := Registry.ReadString('Content Type');
      Registry.CloseKey;
    end;
  finally
    Registry.Free;
  end;
end;

function GetSocketErrorText(const ErrorCode: integer):string;
begin
  case errorcode of
    10004: result:=   'Interrupted system call.';
    10009: result:=   'Bad file number.';
    10013: result:=   'Access denied.';
    10014: result:=   'Bad address.';
    10022: result:=   'Invalid argument.';
    10024: result:=   'Too many open files.';
    10035: result:=   'Operation would block. Check also the DataToSend property of the component (if any).';
    10036: result:=   'Operation now in progress.';
    10037: result:=   'Operation already in progress.';
    10038: result:=   'Socket operation on non-socket.';
    10039: result:=   'Destination address required.';
    10040: result:=   'Message too long.';
    10041: result:=   'Protocol wrong type for socket.';
    10042: result:=   'Bad protocol option.';
    10043: result:=   'Protocol not supported.';
    10044: result:=   'Socket type not supported.';
    10045: result:=   'Operation not supported on socket.';
    10046: result:=   'Protocol family not supported.';
    10047: result:=   'Address family not supported by protocol family.';
    10048: result:=   'Address already in use.';
    10049: result:=   'Can''t assign requested address.';
    10050: result:=   'Network is down.';
    10051: result:=   'Network is unreachable.';
    10052: result:=   'Net dropped connection or reset.';
    10053: result:=   'Software caused connection abort.';
    10054: result:=   'Connection reset by peer.';
    10055: result:=   'No buffer space available.';
    10056: result:=   'Socket is already connected.';
    10057: result:=   'Socket is not connected.';
    10058: result:=   'Can''t send after socket shutdown.';
    10059: result:=   'Too many references, can''t splice.';
    10060: result:=   'Connection timed out.';
    10061: result:=   'Connection refused.';
    10062: result:=   'Too many levels of symbolic links.';
    10063: result:=   'File name too long.';
    10064: result:=   'Host is down.';
    10065: result:=   'No route to host.';
    10066: result:=   'Directory not empty.';
    10067: result:=   'Too many processes.';
    10068: result:=   'Too many users.';
    10069: result:=   'Disc Quota Exceeded.';
    10070: result:=   'Stale NFS file handle.';
    10071: result:=   'Too many levels of remote in path.';
    10091: result:=   'Network subsystem is unavailable.';
    10092: result:=   'WINSOCK DLL Version out of range.';
    10093: result:=   'Winsock not loaded yet.';
    11001: result:=   'Host not found.';
    11002: result:=   'Non-authoritative ''Host not found'' (try again or check DNS setup).';
    11003: result:=   'Non-recoverable errors: FORMERR, REFUSED, NOTIMP.';
    11004: result:=   'Valid name, no data record (check DNSsetup).';
    500:   result:=   'Exception occured with astadataset';
    501:   result:=   'Unauthorized remote control attempted'
    else
      Result := 'Unknown error'
  end;
  Result := Result + '(' + IntToStr(errorcode) + ')';
end;

procedure PMessages;
var
  Msg: TMsg;
begin
  while PeekMessage(Msg, 0, 0, 0, PM_REMOVE) do begin
    if Msg.Message = WM_QUIT then exit;
    TranslateMessage(Msg);
    DispatchMessage(Msg);
  end;
  Sleep(1);
end;

function ParseHeaderField(const Field: String; const Header: String): String;
var
  i: integer;
  s: string;
begin
  i := Pos(Field, Header);
  Result := '';
  if i > 0 then
  begin
    s := Copy(Header, i + Length(Field), Length(Header) - i + Length(Field));
    i := Pos(#13#10, s);
    if i > 0 then
      Result := Copy(s, 1, i - 1);
  end;
end;

end.
