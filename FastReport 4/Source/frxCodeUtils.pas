
{******************************************}
{                                          }
{             FastReport v4.0              }
{            Code window utils             }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxCodeUtils;

interface

{$I frx.inc}

uses
  Windows, Classes, SysUtils, TypInfo
{$IFDEF Delphi6}
, Variants
{$ENDIF};


procedure frxGetEventHandlersList(Code: TStrings; const Language: String;
  EventType: PTypeInfo; List: TStrings);
function frxLocateEventHandler(Code: TStrings; const Language,
  EventName: String): Integer;
function frxLocateMainProc(Code: TStrings; const Language: String): Integer;
function frxAddEvent(Code: TStrings; const Language: String;
  EventType: PTypeInfo; const EventName: String): Integer;
procedure frxEmptyCode(Code: TStrings; const Language: String);
procedure frxAddCodeRes;

implementation

uses frxRes;

procedure frxAddCodeRes;
begin
  with frxResources do
  begin
    Add('PascalScript',
      'proc="procedure" begin="begin" end="end;" lastend="end."');
    Add('C++Script',
      'proc="void" begin="{" end="}" lastend="}"');
    Add('BasicScript',
      'proc="sub" begin="" end="end sub" lastend=""');
    Add('JScript',
      'proc="function" begin="{" end="}" lastend=""');

    Add('TfrxNotifyEvent',
      'PascalScript=(Sender: TfrxComponent);' + #13#10 +
      'C++Script=(TfrxComponent Sender)' + #13#10 +
      'BasicScript=(Sender)' + #13#10 +
      'JScript=(Sender)');
    Add('TfrxCloseQueryEvent',
      'PascalScript=(Sender: TfrxComponent; var CanClose: Boolean);' + #13#10 +
      'C++Script=(TfrxComponent Sender, bool &CanClose)' + #13#10 +
      'BasicScript=(Sender, byref CanClose)' + #13#10 +
      'JScript=(Sender, &CanClose)');
    Add('TfrxKeyEvent',
      'PascalScript=(Sender: TfrxComponent; var Key: Word; Shift: Integer);' + #13#10 +
      'C++Script=(TfrxComponent Sender, word &Key, int Shift)' + #13#10 +
      'BasicScript=(Sender, byref Key, Shift)' + #13#10 +
      'JScript=(Sender, &Key, Shift)');
    Add('TfrxKeyPressEvent',
      'PascalScript=(Sender: TfrxComponent; var Key: Char);' + #13#10 +
      'C++Script=(TfrxComponent Sender, char &Key)' + #13#10 +
      'BasicScript=(Sender, byref Key)' + #13#10 +
      'JScript=(Sender, &Key)');
    Add('TfrxMouseEvent',
      'PascalScript=(Sender: TfrxComponent; Button: TMouseButton; Shift: Integer; X, Y: Integer);' + #13#10 +
      'C++Script=(TfrxComponent Sender, TMouseButton Button, int Shift, int X, int Y)' + #13#10 +
      'BasicScript=(Sender, Button, Shift, X, Y)' + #13#10 +
      'JScript=(Sender, Button, Shift, X, Y)');
    Add('TfrxMouseMoveEvent',
      'PascalScript=(Sender: TfrxComponent; Shift: Integer; X, Y: Integer);' + #13#10 +
      'C++Script=(TfrxComponent Sender, int Shift, int X, int Y)' + #13#10 +
      'BasicScript=(Sender, Shift, X, Y)' + #13#10 +
      'JScript=(Sender, Shift, X, Y)');
    Add('TfrxPreviewClickEvent',
      'PascalScript=(Sender: TfrxView; Button: TMouseButton; Shift: Integer; var Modified: Boolean);' + #13#10 +
      'C++Script=(TfrxView Sender, TMouseButton Button, int Shift, bool &Modified)' + #13#10 +
      'BasicScript=(Sender, Button, Shift, byref Modified)' + #13#10 +
      'JScript=(Sender, Button, Shift, &Modified)');
    Add('TfrxRunDialogsEvent',
      'PascalScript=(var Result: Boolean);' + #13#10 +
      'C++Script=(bool &Result)' + #13#10 +
      'BasicScript=(byref Result)' + #13#10 +
      'JScript=(&Result)');
  end;
end;

function GetLangParam(const Language, Param: String): String;
var
  s: String;
  i: Integer;
begin
  Result := '';
  s := frxResources.Get(Language);
  if s = Language then Exit;

  i := Pos(AnsiUppercase(Param) + '="', AnsiUppercase(s));
  if (i <> 0) and ((i = 1) or (s[i - 1] = ' ')) then
  begin
    Result := Copy(s, i + Length(Param + '="'), MaxInt);
    Result := Copy(Result, 1, Pos('"', Result) - 1);
  end;
end;

function GetEventParams(EventType: PTypeInfo; const Language: String): String;
var
  s: String;
  sl: TStringList;
begin
  Result := '';
  s := frxResources.Get(EventType.Name);
  if s = EventType.Name then Exit;

  sl := TStringList.Create;
  sl.Text := s;
  Result := sl.Values[Language];
  sl.Free;
end;

procedure frxGetEventHandlersList(Code: TStrings; const Language: String;
  EventType: PTypeInfo; List: TStrings);
var
  i: Integer;
  s, EventName, EventWord, EventParams: String;
begin
  List.Clear;
  EventParams := GetEventParams(EventType, Language);
  EventWord := AnsiUppercase(GetLangParam(Language, 'proc'));

  for i := 0 to Code.Count - 1 do
  begin
    s := Code[i];
    if Pos(EventWord, AnsiUppercase(s)) = 1 then
    begin
      { delete the "procedure" word }
      Delete(s, 1, Length(EventWord));
      { extract the event name and params }
      EventName := Trim(Copy(s, 1, Pos('(', s) - 1));
      s := Trim(Copy(s, Pos('(', s), 255));
      { compare the params }
      if AnsiCompareText(s, EventParams) = 0 then
        List.Add(EventName);
    end;
  end;
end;

function frxLocateEventHandler(Code: TStrings; const Language,
  EventName: String): Integer;
var
  i: Integer;
  s: String;
begin
  Result := -1;
  s := UpperCase(GetLangParam(Language, 'proc') + ' ' + EventName + '(');

  for i := 0 to Code.Count - 1 do
    if Pos(s, UpperCase(Code[i])) = 1 then
    begin
      Result := i;
      break;
    end;
end;

function frxLocateMainProc(Code: TStrings; const Language: String): Integer;
var
  i, endCount: Integer;
  s, BeginStr, EndStr: String;
begin
  Result := -1;

  BeginStr := GetLangParam(Language, 'begin');
  EndStr := GetLangParam(Language, 'lastend');
  if EndStr = '' then
  begin
    Result := Code.Count - 1;
    Exit;
  end;

  i := Code.Count - 1;
  while i >= 0 do
  begin
    s := AnsiUpperCase(Code[i]);
    Dec(i);
    if Pos(AnsiUpperCase(EndStr), s) <> 0 then
      break;
  end;

  if i < 0 then Exit;

  EndStr := GetLangParam(Language, 'end');
  endCount := 1;
  while (i >= 0) and (endCount <> 0) do
  begin
    s := AnsiUpperCase(Code[i]);
    if Pos(AnsiUpperCase(EndStr), s) <> 0 then
      Inc(endCount);
    if Pos(AnsiUpperCase(BeginStr), s) <> 0 then
      Dec(endCount);
    Dec(i);
  end;

  Result := i + 1;
end;

function frxAddEvent(Code: TStrings; const Language: String;
  EventType: PTypeInfo; const EventName: String): Integer;
var
  MainProcIndex: Integer;
begin
  MainProcIndex := frxLocateMainProc(Code, Language);
  if MainProcIndex = -1 then
    raise Exception.Create(frxResources.Get('dsCantFindProc'));

  Code.Insert(MainProcIndex, GetLangParam(Language, 'proc') + ' ' + EventName +
    GetEventParams(EventType, Language));
  Code.Insert(MainProcIndex + 1, GetLangParam(Language, 'begin'));
  Code.Insert(MainProcIndex + 2, '');
  Code.Insert(MainProcIndex + 3, GetLangParam(Language, 'end'));
  Code.Insert(MainProcIndex + 4, '');
  Result := MainProcIndex + 3;
end;

procedure frxEmptyCode(Code: TStrings; const Language: String);
begin
  Code.Clear;
  if GetLangParam(Language, 'lastend') <> '' then
  begin
    Code.Add(GetLangParam(Language, 'begin'));
    Code.Add('');
    Code.Add(GetLangParam(Language, 'lastend'));
  end;
end;



end.


//0f31356a91fea3356e5f76cdce90aa7b