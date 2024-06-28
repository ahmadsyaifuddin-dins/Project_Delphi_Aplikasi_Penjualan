
{******************************************}
{                                          }
{             FastReport v4.0              }
{           Aggregate Functions            }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxAggregate;

interface

{$I frx.inc}

uses
  Windows, SysUtils, Classes, Dialogs, frxClass
{$IFDEF Delphi6}
, Variants
{$ENDIF};


type
  TfrxAggregateFunction = (agSum, agAvg, agMin, agMax, agCount);

  TfrxAggregateItem = class(TObject)
  private
    FAggregateFunction: TfrxAggregateFunction;
    FBand: TfrxDataBand;
    FCountInvisibleBands: Boolean;
    FDontReset: Boolean;
    FExpression: String;
    FIsPageFooter: Boolean;
    FItemsArray: Variant;      { used for vbands }
    FItemsCount: Integer;
    FItemsCountArray: Variant; { used for vbands }
    FItemsValue: Variant;
    FKeeping: Boolean;
    FLastCount: Integer;
    FLastValue: Variant;
    FMemoName: String;
    FOriginalName: String;
    FParentBand: TfrxBand;
    FReport: TfrxReport;
    FTempItemsCount: Integer;
    FTempItemsValue: Variant;
    FVColumn: Integer;         { used for vbands }
  public
    procedure Calc;
    procedure DeleteValue;
    procedure Reset;
    procedure StartKeep;
    procedure EndKeep;
    function Value: Variant;
  end;

  TfrxAggregateList = class(TObject)
  private
    FList: TList;
    FReport: TfrxReport;
    function GetItem(Index: Integer): TfrxAggregateItem;
    procedure FindAggregates(Memo: TfrxCustomMemoView; DataBand: TfrxDataBand);
    procedure ParseName(const ComplexName: String; var Func: TfrxAggregateFunction;
      var Expr: String; var Band: TfrxDataBand; var CountInvisible, DontReset: Boolean);
    property Items[Index: Integer]: TfrxAggregateItem read GetItem; default;
  public
    constructor Create(AReport: TfrxReport);
    destructor Destroy; override;
    procedure Clear;
    procedure ClearValues;

    procedure AddItems(Page: TfrxReportPage);
    procedure AddValue(Band: TfrxBand; VColumn: Integer = 0);
    procedure DeleteValue(Band: TfrxBand);
    procedure EndKeep;
    procedure Reset(ParentBand: TfrxBand);
    procedure StartKeep;
    function GetValue(ParentBand: TfrxBand; const ComplexName: String;
      VColumn: Integer = 0): Variant; overload;
    function GetValue(ParentBand: TfrxBand; VColumn: Integer;
      const Name, Expression: String; Band: TfrxBand; Flags: Integer): Variant; overload;
  end;


implementation

uses frxVariables, frxUtils;

type
  THackComponent = class(TfrxComponent);

procedure Get3Params(const s: String; var i: Integer;
  var s1, s2, s3: String);
var
  c, d, oi, ci: Integer;
begin
  s1 := ''; s2 := ''; s3 := '';
  c := 1; d := 1; oi := i + 1; ci := 1;
  repeat
    Inc(i);
    if s[i] = '''' then
      if d = 1 then Inc(d) else d := 1;
    if d = 1 then
    begin
      if s[i] = '(' then
        Inc(c) else
      if s[i] = ')' then Dec(c);
      if (s[i] = ',') and (c = 1) then
      begin
        if ci = 1 then
          s1 := Copy(s, oi, i - oi) else
          s2 := Copy(s, oi, i - oi);
        oi := i + 1; Inc(ci);
      end;
    end;
  until (c = 0) or (i >= Length(s));
  case ci of
    1: s1 := Copy(s, oi, i - oi);
    2: s2 := Copy(s, oi, i - oi);
    3: s3 := Copy(s, oi, i - oi);
  end;
  Inc(i);
end;


{ TfrxAggregateItem }

procedure TfrxAggregateItem.Calc;
var
  Value: Variant;
  i: Integer;
begin
  if not FBand.Visible and not FCountInvisibleBands then Exit;

  FReport.CurObject := FMemoName;
  if FAggregateFunction <> agCount then
    Value := FReport.Calc(FExpression) else
    Value := Null;

  if VarType(Value) = varBoolean then
    if Value = True then
      Value := 1;

  { process vbands }
  if FVColumn > 0 then
  begin
    if VarIsNull(FItemsArray) then
    begin
      FItemsArray := VarArrayCreate([0, 1000], varVariant);
      FItemsCountArray := VarArrayCreate([0, 1000], varVariant);
      for i := 0 to 1000 do
      begin
        FItemsArray[i] := Null;
        FItemsCountArray[i] := 0;
      end;
    end;

    if (FAggregateFunction <> agAvg) or (Value <> Null) then
      FItemsCountArray[FVColumn] := FItemsCountArray[FVColumn] + 1;
    if FItemsArray[FVColumn] = Null then
      FItemsArray[FVColumn] := Value
    else if Value <> Null then
      case FAggregateFunction of
        agSum, agAvg:
          FItemsArray[FVColumn] := FItemsArray[FVColumn] + Value;
        agMin:
          if Value < FItemsArray[FVColumn] then
            FItemsArray[FVColumn] := Value;
        agMax:
          if Value > FItemsArray[FVColumn] then
            FItemsArray[FVColumn] := Value;
      end;
  end
  else if FKeeping then
  begin
    if (FAggregateFunction <> agAvg) or (Value <> Null) then
      Inc(FTempItemsCount);
    if FTempItemsValue = Null then
      FTempItemsValue := Value
    else if Value <> Null then
      case FAggregateFunction of
        agSum, agAvg:
          FTempItemsValue := FTempItemsValue + Value;
        agMin:
          if Value < FTempItemsValue then
            FTempItemsValue := Value;
        agMax:
          if Value > FTempItemsValue then
            FTempItemsValue := Value;
      end;
  end
  else
  begin
    FLastCount := FItemsCount;
    FLastValue := FItemsValue;
    if (FAggregateFunction <> agAvg) or (Value <> Null) then
      Inc(FItemsCount);
    if FItemsValue = Null then
      FItemsValue := Value
    else if Value <> Null then
      case FAggregateFunction of
        agSum, agAvg:
          FItemsValue := FItemsValue + Value;
        agMin:
          if Value < FItemsValue then
            FItemsValue := Value;
        agMax:
          if Value > FItemsValue then
            FItemsValue := Value;
      end;
  end;
end;

procedure TfrxAggregateItem.DeleteValue;
begin
  FItemsCount := FLastCount;
  FItemsValue := FLastValue;
end;

procedure TfrxAggregateItem.Reset;
begin
  if FDontReset and (FItemsCount <> 0) then Exit;

  FItemsCount := 0;
  FItemsValue := Null;
  FItemsArray := Null;
  FItemsCountArray := Null;
end;

procedure TfrxAggregateItem.StartKeep;
begin
  if not FIsPageFooter or FKeeping then Exit;
  FKeeping := True;

  FTempItemsCount := 0;
  FTempItemsValue := Null;
end;

procedure TfrxAggregateItem.EndKeep;
begin
  if not FIsPageFooter or not FKeeping then Exit;
  FKeeping := False;

  FItemsCount := FItemsCount + FTempItemsCount;
  case FAggregateFunction of
    agMin:
      if FTempItemsValue < FItemsValue then
        FItemsValue := FTempItemsValue;
    agMax:
      if FTempItemsValue > FItemsValue then
        FItemsValue := FTempItemsValue;
    else
      FItemsValue := FItemsValue + FTempItemsValue;
  end;
end;

function TfrxAggregateItem.Value: Variant;
begin
  Result := Null;
  if not VarIsNull(FItemsArray) then
  begin
    case FAggregateFunction of
      agSum, agMin, agMax:
        Result := FItemsArray[FVColumn];
      agAvg:
        Result := FItemsArray[FVColumn] / FItemsCountArray[FVColumn];
      agCount:
        Result := FItemsCountArray[FVColumn];
    end
  end
  else
    case FAggregateFunction of
      agSum, agMin, agMax:
        Result := FItemsValue;
      agAvg:
        Result := FItemsValue / FItemsCount;
      agCount:
        Result := FItemsCount;
    end;

  if VarIsNull(Result) then
    Result := 0;
end;


{ TfrxAggregateList }

constructor TfrxAggregateList.Create(AReport: TfrxReport);
begin
  FList := TList.Create;
  FReport := AReport;
end;

destructor TfrxAggregateList.Destroy;
begin
  Clear;
  FList.Free;
  inherited;
end;

procedure TfrxAggregateList.Clear;
begin
  while FList.Count > 0 do
  begin
    TObject(FList[0]).Free;
    FList.Delete(0);
  end;
end;

function TfrxAggregateList.GetItem(Index: Integer): TfrxAggregateItem;
begin
  Result := FList[Index];
end;

procedure TfrxAggregateList.ParseName(const ComplexName: String;
  var Func: TfrxAggregateFunction; var Expr: String; var Band: TfrxDataBand;
  var CountInvisible, DontReset: Boolean);
var
  i: Integer;
  Name, Param1, Param2, Param3: String;
begin
  i := Pos('(', ComplexName);
  Name := UpperCase(Trim(Copy(ComplexName, 1, i - 1)));
  Get3Params(ComplexName, i, Param1, Param2, Param3);
  Param1 := Trim(Param1);
  Param2 := Trim(Param2);
  Param3 := Trim(Param3);

  if Name = 'SUM' then
    Func := agSum
  else if Name = 'MIN' then
    Func := agMin
  else if Name = 'MAX' then
    Func := agMax
  else if Name = 'AVG' then
    Func := agAvg
  else //if Name = 'COUNT' then
    Func := agCount;

  if Name <> 'COUNT' then
  begin
    Expr := Param1;
    if Param2 <> '' then
      Band := TfrxDataBand(FReport.FindObject(Param2)) else
      Band := nil;
    if Param3 <> '' then
      i := StrToInt(Param3) else
      i := 0;
  end
  else
  begin
    Expr := '';
    Band := TfrxDataBand(FReport.FindObject(Param1));
    if Param2 <> '' then
      i := StrToInt(Param2) else
      i := 0;
  end;

  CountInvisible := (i and 1) <> 0;
  DontReset := (i and 2) <> 0;
end;

procedure TfrxAggregateList.FindAggregates(Memo: TfrxCustomMemoView;
  DataBand: TfrxDataBand);
const
  Spaces = [#1..#32, '!', '#', '$', '%', '^', '&', '|', '+', '-', '*', '/',
            '=', '.', ',', '[', ']', '0'..'9'];
  IdentSpaces = Spaces - ['0'..'9'] + ['('];
var
  i, j: Integer;
  s, s1, dc1, dc2: String;
  Report: TfrxReport;

  procedure FindIn(const s: String); forward;

  procedure SkipString(const s: String; var i: Integer);
  var
    ch: Char;
  begin
    ch := s[i];
    Inc(i);
    while (i <= Length(s)) and (s[i] <> ch) do
      Inc(i);
    Inc(i);
  end;

  function Check(s: String): Boolean;
  var
    i: Integer;
    ds: TfrxDataSet;
    s1: String;
    VarVal: Variant;
  begin
    Result := False;
    if s = '' then Exit;

    { searching in the variables }
    i := Report.Variables.IndexOf(s);
    if i <> -1 then
    begin
      VarVal := Report.Variables.Items[i].Value;
      if VarIsNull(VarVal) then
        s := ''
      else
        s := VarVal;
      FindIn(s);
      Result := True;
      Exit;
    end;

    { maybe it's a dataset/field? }
    Report.GetDataSetAndField(s, ds, s1);
    if (ds <> nil) and (s1 <> '') then
      Result := True;
  end;

  procedure AddAggregate(const ComplexName: String);
  var
    Item: TfrxAggregateItem;
  begin
    Item := TfrxAggregateItem.Create;
    FList.Add(Item);

    ParseName(ComplexName, Item.FAggregateFunction, Item.FExpression,
      Item.FBand, Item.FCountInvisibleBands, Item.FDontReset);
    if Item.FBand = nil then
      Item.FBand := DataBand;

    Item.FReport := FReport;
    Item.FParentBand := TfrxBand(Memo.Parent);
    if Item.FParentBand.Vertical and (THackComponent(Memo).FOriginalBand <> nil) and
      (TfrxBand(THackComponent(Memo).FOriginalBand).BandNumber in [1, 3, 5, 13]) then
      Item.FParentBand := TfrxBand(THackComponent(Memo).FOriginalBand);
    Item.FIsPageFooter := Item.FParentBand is TfrxPageFooter;
    Item.FOriginalName := Trim(ComplexName);
    Item.FMemoName := Memo.Name;
    Item.Reset;
  end;

  procedure FindIn(const s: String);
  var
    i, j: Integer;
    s1, s2, s3, s4: String;
  begin
    if Check(s) then
      Exit;

    { this is an expression }
    i := 1;
    while i <= Length(s) do
    begin
      { skip non-significant chars }
      while (i <= Length(s)) and (s[i] in Spaces) do
        Inc(i);

      case s[i] of
        '<':
          begin
            FindIn(frxGetBrackedVariable(s, '<', '>', i, j));
            i := j;
          end;

        '''', '"':
          SkipString(s, i);

        '(':
          begin
            FindIn(frxGetBrackedVariable(s, '(', ')', i, j));
            if i = j then
              Inc(i) else
              i := j;
          end;
        else
        begin
          j := i;
          while (i <= Length(s)) and not (s[i] in IdentSpaces) do
            Inc(i);
          s1 := UpperCase(Copy(s, j, i - j));

          if (s1 = 'SUM') or (s1 = 'MIN') or (s1 = 'MAX') or
             (s1 = 'AVG') or (s1 = 'COUNT') then
          begin
            if (i < Length(s)) and (s[i] = '(') then
            begin
              Get3Params(s, i, s2, s3, s4);
              AddAggregate(Copy(s, j, i - j));
            end;
          end
          else
            Check(s1);
        end;
      end;
    end;
  end;

begin
  Report := Memo.Report;
  if Memo.AllowExpressions then
  begin
    s := Memo.Text;
    i := 1;
    dc1 := Memo.ExpressionDelimiters;
    dc2 := Copy(dc1, Pos(',', dc1) + 1, 255);
    dc1 := Copy(dc1, 1, Pos(',', dc1) - 1);

    repeat
      while (i < Length(s)) and (Copy(s, i, Length(dc1)) <> dc1) do Inc(i);
      s1 := frxGetBrackedVariable(s, dc1, dc2, i, j);
      if i <> j then
      begin
        FindIn(s1);
        i := j;
        j := 0;
      end;
    until i = j;
  end;
end;

procedure TfrxAggregateList.AddItems(Page: TfrxReportPage);

  procedure EnumObjects(ParentBand: TfrxBand; DataBand: TfrxDataBand);
  var
    i: Integer;
    c: TfrxComponent;
  begin
    if ParentBand = nil then Exit;

    for i := 0 to ParentBand.Objects.Count - 1 do
    begin
      c := ParentBand.Objects[i];
      if c is TfrxCustomMemoView then
        FindAggregates(TfrxCustomMemoView(c), DataBand);
    end;

    if ParentBand.Child <> nil then
      EnumObjects(ParentBand.Child, DataBand);
  end;

  procedure EnumGroups(GroupHeader: TfrxGroupHeader; DataBand: TfrxDataBand);
  var
    i: Integer;
    g: TfrxGroupHeader;
  begin
    if GroupHeader = nil then Exit;

    for i := 0 to GroupHeader.FSubBands.Count - 1 do
    begin
      g := GroupHeader.FSubBands[i];
      EnumObjects(g.FFooter, DataBand);
    end;
  end;

  procedure EnumDataBands(List: TList);
  var
    i: Integer;
    d: TfrxDataBand;
  begin
    for i := 0 to List.Count - 1 do
    begin
      d := List[i];
      EnumObjects(d.FFooter, d);
      EnumGroups(TfrxGroupHeader(d.FGroup), d);
      EnumDataBands(d.FSubBands);
      if d.Vertical then
        EnumObjects(d, d);
    end;
  end;

begin
  EnumDataBands(Page.FSubBands);
  EnumDataBands(Page.FVSubBands);
  if Page.FSubBands.Count > 0 then
  begin
    EnumObjects(Page.FindBand(TfrxPageFooter), Page.FSubBands[0]);
    EnumObjects(Page.FindBand(TfrxColumnFooter), Page.FSubBands[0]);
    EnumObjects(Page.FindBand(TfrxReportSummary), Page.FSubBands[0]);
  end;
end;

procedure TfrxAggregateList.AddValue(Band: TfrxBand; VColumn: Integer = 0);
var
  i: Integer;
begin
  for i := 0 to FList.Count - 1 do
    if Items[i].FBand = Band then
    begin
      Items[i].FVColumn := VColumn;
      Items[i].Calc;
    end;
end;

procedure TfrxAggregateList.DeleteValue(Band: TfrxBand);
var
  i: Integer;
begin
  for i := 0 to FList.Count - 1 do
    if Items[i].FBand = Band then
      Items[i].DeleteValue;
end;

function TfrxAggregateList.GetValue(ParentBand: TfrxBand;
  const ComplexName: String; VColumn: Integer = 0): Variant;
var
  i: Integer;
begin
  Result := Null;

  for i := 0 to FList.Count - 1 do
    if (Items[i].FParentBand = ParentBand) and
       (AnsiCompareText(Items[i].FOriginalName, Trim(ComplexName)) = 0) then
    begin
      Items[i].FVColumn := VColumn;
      Result := Items[i].Value;
      break;
    end;
end;

function TfrxAggregateList.GetValue(ParentBand: TfrxBand; VColumn: Integer;
  const Name, Expression: String; Band: TfrxBand; Flags: Integer): Variant;
var
  i: Integer;
  fn: TfrxAggregateFunction;
begin
  Result := Null;
  if Name = 'SUM' then
    fn := agSum
  else if Name = 'AVG' then
    fn := agAvg
  else if Name = 'MIN' then
    fn := agMin
  else if Name = 'MAX' then
    fn := agMax
  else
    fn := agCount;

  for i := 0 to FList.Count - 1 do
    if (Items[i].FParentBand = ParentBand) and
      (Items[i].FAggregateFunction = fn) and
      (AnsiCompareText(Items[i].FExpression, Trim(Expression)) = 0) and
      ((Band = nil) or (Items[i].FBand = Band)) and
      (Items[i].FCountInvisibleBands = ((Flags and 1) <> 0)) and
      (Items[i].FDontReset = ((Flags and 2) <> 0)) then
    begin
      Items[i].FVColumn := VColumn;
      Result := Items[i].Value;
      break;
    end;
end;

procedure TfrxAggregateList.Reset(ParentBand: TfrxBand);
var
  i: Integer;
begin
  for i := 0 to FList.Count - 1 do
    if Items[i].FParentBand = ParentBand then
      Items[i].Reset;
end;

procedure TfrxAggregateList.StartKeep;
var
  i: Integer;
begin
  for i := 0 to FList.Count - 1 do
    Items[i].StartKeep;
end;

procedure TfrxAggregateList.EndKeep;
var
  i: Integer;
begin
  for i := 0 to FList.Count - 1 do
    Items[i].EndKeep;
end;

procedure TfrxAggregateList.ClearValues;
var
  i: Integer;
  SaveReset: Boolean;
begin
  for i := 0 to FList.Count - 1 do
  begin
    SaveReset := Items[i].FDontReset;
    Items[i].FDontReset := False;
    Items[i].Reset;
    Items[i].FDontReset := SaveReset;
  end;
end;

end.


//0f31356a91fea3356e5f76cdce90aa7b