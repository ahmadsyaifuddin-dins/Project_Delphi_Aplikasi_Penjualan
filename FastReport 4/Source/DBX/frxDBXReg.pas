
{******************************************}
{                                          }
{             FastReport v4.0              }
{       DBX components registration        }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxDBXReg;

interface

{$I frx.inc}

procedure Register;

implementation

uses
  Windows, Messages, SysUtils, Classes
{$IFNDEF Delphi6}
, DsgnIntf
{$ELSE}
, DesignIntf, DesignEditors
{$ENDIF}
, frxDBXComponents;

procedure Register;
begin
  RegisterComponents('FastReport 4.0', [TfrxDBXComponents]);
end;

end.
