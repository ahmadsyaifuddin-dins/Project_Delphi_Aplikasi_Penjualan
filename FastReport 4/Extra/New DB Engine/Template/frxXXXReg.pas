
{******************************************}
{                                          }
{             FastReport v3.0              }
{       XXX components registration        }
{                                          }

// Copyright
{                                          }
{******************************************}

unit frxXXXReg;

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
, frxXXXComponents;

procedure Register;
begin
  RegisterComponents('FastReport 3.0', [TfrxXXXComponents]);
end;

end.
