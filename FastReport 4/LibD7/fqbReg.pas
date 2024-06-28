{*******************************************}
{                                           }
{          FastQueryBuilder 1.03            }
{                                           }
{            Copyright (c) 2005             }
{             Fast Reports Inc.             }
{                                           }
{*******************************************}

{$I fqb.inc}

unit fqbReg;

interface

procedure Register;

implementation

uses
  Windows, Messages, Classes
{$IFNDEF Delphi6}
  ,DsgnIntf
{$ELSE}
  ,DesignIntf, DesignEditors
{$ENDIF}
  ,fqbClass, fqbSynMemo;

{$R 'FQB.DCR'}

procedure Register;
begin
  RegisterComponents('FastQueryBuilder', [TfqbDialog,
                     TfqbTableArea, TfqbTableListBox, TfqbSyntaxMemo, TfqbGrid]);
end;

end.
