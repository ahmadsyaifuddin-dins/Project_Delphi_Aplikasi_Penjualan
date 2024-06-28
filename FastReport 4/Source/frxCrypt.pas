
{******************************************}
{                                          }
{             FastReport v4.0              }
{          Report encrypt/decrypt          }
{                                          }
{            Copyright (c) 2006            }
{         by Alexander Tzyganenko,         }
{             Fast Reports Inc.            }
{                                          }
{******************************************}

unit frxCrypt;

interface

{$I frx.inc}

uses Windows, Classes, SysUtils, Forms, Controls, frxClass;

type
  TfrxCrypt = class(TfrxCustomCrypter)
  private
    function AskKey(const Key: String): String;
  public
    procedure Crypt(Dest: TStream; const Key: String); override;
    function Decrypt(Source: TStream; const Key: String): Boolean; override;
  end;


procedure frxCryptStream(Source, Dest: TStream; const Key: String);
procedure frxDecryptStream(Source, Dest: TStream; const Key: String);


implementation

uses frxUtils, rc_Crypt, frxPassw;


function MakeKey(const Key: String): String;
begin
  Result := '';
  if (Key <> '') then
  begin
    SetLength(Result, Length(Key) * 2);
    BinToHex(@Key[1], @Result[1], Length(Key));
  end;
  Result := ExpandKey(Result, _KEYLength);
end;

procedure frxCryptStream(Source, Dest: TStream; const Key: String);
var
  s: String;
  header: array [0..2] of byte;
begin
  Source.Position := 0;
  SetLength(s, Source.Size);
  Source.Read(s[1], Source.Size);

  s := EncryptString(s, MakeKey(Key));

  header[0] := Ord('r');
  header[1] := Ord('i');
  header[2] := Ord('j');
  Dest.Write(header, 3);
  Dest.Write(s[1], Length(s));
end;

procedure frxDecryptStream(Source, Dest: TStream; const Key: String);
var
  s: String;
begin
  SetLength(s, Source.Size);
  Source.Read(s[1], Source.Size);

  if (s <> '') and (s[1] = 'r') and (s[2] = 'i') and (s[3] = 'j') then
  begin
    Delete(s, 1, 3);
    s := DecryptString(s, MakeKey(Key));
  end;

  Dest.Write(s[1], Length(s));
end;


{ TfrxCrypt }

function TfrxCrypt.AskKey(const Key: String): String;
begin
  Result := Key;
  if Result = '' then
    with TfrxPasswordForm.Create(Application) do
    begin
      if ShowModal = mrOk then
        Result := PasswordE.Text;
      Free;
    end;
end;

procedure TfrxCrypt.Crypt(Dest: TStream; const Key: String);
begin
  frxCryptStream(Stream, Dest, Key);
end;

function TfrxCrypt.Decrypt(Source: TStream; const Key: String): Boolean;
var
  Signature: array[0..2] of Byte;
begin
  Source.Read(Signature, 3);
  Source.Seek(-3, soFromCurrent);
  Result := (Signature[0] = Ord('r')) and (Signature[1] = Ord('i')) and (Signature[2] = Ord('j'));
  if Result then
    frxDecryptStream(Source, Stream, AskKey(Key));
  Stream.Position := 0;
end;


end.


//0f31356a91fea3356e5f76cdce90aa7b