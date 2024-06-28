
{******************************************}
{                                          }
{             FastScript v1.9              }
{    IniFiles.pas classes and functions    }
{                                          }
{  (c) 2003-2005 by Alexander Tzyganenko,  }
{             Fast Reports Inc             }
{                                          }
{  Copyright (c) 2004 by Stalker SoftWare  }
{                                          }
{******************************************}

unit fs_iinirtti;

interface

{$i fs.inc}

uses
  SysUtils, Classes, fs_iinterpreter, IniFiles;

type
  TfsIniRTTI = class(TComponent); // fake component


implementation

type
  TFunctions = class(TfsRTTIModule)
  private
    function CallMethod(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
    function GetProp(Instance: TObject; ClassType: TClass; const PropName: String): Variant;
  public
    constructor Create(AScript: TfsScript); override;
  end;


{ TFunctions }

constructor TFunctions.Create(AScript: TfsScript);
begin
  inherited Create(AScript);

  with AScript do
  begin
    with AddClass(TIniFile, 'TObject') do  
    begin
      AddConstructor('constructor Create(const FileName: String)', CallMethod);
      AddMethod('procedure WriteString(const Section, Ident, Value: String)', CallMethod);
      AddMethod('function ReadString(const Section, Ident, Default: String): String;', CallMethod);
      AddMethod('function ReadInteger(const Section, Ident: String; Default: LongInt): LongInt', CallMethod);
      AddMethod('procedure WriteInteger(const Section, Ident: String; Value: LongInt)', CallMethod);
      AddMethod('function ReadBool(const Section, Ident: String; Default: Boolean): Boolean', CallMethod);
      AddMethod('procedure WriteBool(const Section, Ident: String; Value: Boolean)', CallMethod);
      AddMethod('function ReadDate(const Section, Name: String; Default: TDateTime): TDateTime', CallMethod);
      AddMethod('procedure WriteDate(const Section, Name: String; Value: TDateTime)', CallMethod);
      AddMethod('function ReadDateTime(const Section, Name: String; Default: TDateTime): TDateTime', CallMethod);
      AddMethod('procedure WriteDateTime(const Section, Name: String; Value: TDateTime)', CallMethod);
      AddMethod('function ReadFloat(const Section, Name: String; Default: Double): Double', CallMethod);
      AddMethod('procedure WriteFloat(const Section, Name: String; Value: Double)', CallMethod);
      AddMethod('function ReadTime(const Section, Name: String; Default: TDateTime): TDateTime', CallMethod);
      AddMethod('procedure WriteTime(const Section, Name: String; Value: TDateTime);', CallMethod);
{$IFDEF DELPHI6}
      AddMethod('function ReadBinaryStream(const Section, Name: String; Value: TStream): Integer', CallMethod);
      AddMethod('procedure WriteBinaryStream(const Section, Name: String; Value: TStream)', CallMethod);
{$ENDIF}
{$IFDEF DELPHI7}
      AddMethod('procedure ReadSectionValuesEx(const Section: String; Strings: TStrings)', CallMethod);
{$ENDIF}
      AddMethod('function SectionExists(const Section: String): Boolean', CallMethod);
      AddMethod('procedure DeleteKey(const Section, Ident: String)', CallMethod);
      AddMethod('function ValueExists(const Section, Ident: String): Boolean', CallMethod);
      AddMethod('procedure ReadSection(const Section: String; Strings: TStrings)', CallMethod);
      AddMethod('procedure ReadSections(Strings: TStrings)', CallMethod);
      AddMethod('procedure ReadSectionValues(const Section: String; Strings: TStrings)', CallMethod);
      AddMethod('procedure EraseSection(const Section: String)', CallMethod);
      AddProperty('FileName', 'String', GetProp);
    end;
  end;
end;

{$HINTS OFF}
function TFunctions.CallMethod(Instance: TObject; ClassType: TClass; const MethodName: String; Caller: TfsMethodHelper): Variant;
var
  oTIniFile: TIniFile;
  oList: TStrings;
  nCou: Integer;
begin
  Result := 0;

  if ClassType = TIniFile then 
  begin
    oTIniFile := TIniFile(Instance);
    if MethodName = 'CREATE' then
      Result := Integer(oTIniFile.Create(Caller.Params[0]))
    else if MethodName = 'WRITESTRING' then
      oTIniFile.WriteString(Caller.Params[0], Caller.Params[1], Caller.Params[2])
    else if MethodName = 'READSTRING' then
      Result := oTIniFile.ReadString(Caller.Params[0], Caller.Params[1], Caller.Params[2])
    else if MethodName = 'WRITEINTEGER' then
      oTIniFile.WriteInteger(Caller.Params[0], Caller.Params[1], Caller.Params[2])
    else if MethodName = 'READINTEGER' then
      Result := oTIniFile.ReadInteger(Caller.Params[0], Caller.Params[1], Caller.Params[2])
    else if MethodName = 'WRITEBOOL' then
      oTIniFile.WriteBool(Caller.Params[0], Caller.Params[1], Caller.Params[2])
    else if MethodName = 'READBOOL' then
      Result := oTIniFile.ReadBool(Caller.Params[0], Caller.Params[1], Caller.Params[2])
    else if MethodName = 'WRITEDATE' then
      oTIniFile.WriteDate(Caller.Params[0], Caller.Params[1], Caller.Params[2])
    else if MethodName = 'READDATE' then
      Result := oTIniFile.ReadDate(Caller.Params[0], Caller.Params[1], Caller.Params[2])
    else if MethodName = 'WRITEDATETIME' then
      oTIniFile.WriteDateTime(Caller.Params[0], Caller.Params[1], Caller.Params[2])
    else if MethodName = 'READDATETIME' then
      Result := oTIniFile.ReadDateTime(Caller.Params[0], Caller.Params[1], Caller.Params[2])
    else if MethodName = 'WRITEFLOAT' then
      oTIniFile.WriteFloat(Caller.Params[0], Caller.Params[1], Caller.Params[2])
    else if MethodName = 'READFLOAT' then
      Result := oTIniFile.ReadFloat(Caller.Params[0], Caller.Params[1], Caller.Params[2])
    else if MethodName = 'WRITETIME' then
      oTIniFile.WriteTime(Caller.Params[0], Caller.Params[1], Caller.Params[2])
    else if MethodName = 'READTIME' then
      Result := oTIniFile.ReadTime(Caller.Params[0], Caller.Params[1], Caller.Params[2])
{$IFDEF DELPHI6}
    else if MethodName = 'WRITEBINARYSTREAM' then
      oTIniFile.WriteBinaryStream(Caller.Params[0], Caller.Params[1], TStream(Integer(Caller.Params[2])))
    else if MethodName = 'READBINARYSTREAM' then
      Result := oTIniFile.ReadBinaryStream(Caller.Params[0], Caller.Params[1], TStream(Integer(Caller.Params[2])))
{$ENDIF}
    else if MethodName = 'SECTIONEXISTS' then
      Result := oTIniFile.SectionExists(Caller.Params[0])
    else if MethodName = 'DELETEKEY' then
      oTIniFile.DeleteKey(Caller.Params[0], Caller.Params[1])
    else if MethodName = 'VALUEEXISTS' then
      Result := oTIniFile.ValueExists(Caller.Params[0], Caller.Params[1])
    else if MethodName = 'READSECTION' then
      oTIniFile.ReadSection(Caller.Params[0], TStrings(Integer(Caller.Params[1])))
    else if MethodName = 'READSECTIONS' then
      oTIniFile.ReadSections(TStrings(Integer(Caller.Params[0])))
    else if MethodName = 'READSECTIONVALUES' then
      oTIniFile.ReadSectionValues(Caller.Params[0], TStrings(Integer(Caller.Params[1])))
    else if MethodName = 'ERASESECTION' then
      oTIniFile.EraseSection(Caller.Params[0])
{$IFDEF DELPHI7}
    else if MethodName = 'READSECTIONVALUESEX' then
    begin
      oList := TStringList.Create;
      try
        oTIniFile.ReadSectionValues(Caller.Params[0], oList);
        TStrings(Integer(Caller.Params[1])).Clear;
        for nCou := 0 to oList.Count-1 do
          TStrings(Integer(Caller.Params[1])).Add(oList.ValueFromIndex[nCou]);
      finally
        oList.Free;
      end;
    end;
{$ENDIF}
  end;
end;
{$HINTS ON}

function TFunctions.GetProp(Instance: TObject; ClassType: TClass; const PropName: String): Variant;
begin
  Result := 0;

  if ClassType = TIniFile then 
  begin
    if PropName = 'FILENAME' then
      Result := TIniFile(Instance).FileName
  end;
end;


initialization
  fsRTTIModules.Add(TFunctions);

finalization
  fsRTTIModules.Remove(TFunctions);

end.
