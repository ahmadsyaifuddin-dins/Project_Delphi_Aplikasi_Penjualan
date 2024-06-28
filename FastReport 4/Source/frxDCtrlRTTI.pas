
{******************************************}
{                                          }
{             FastReport v4.0              }
{           Dialog controls RTTI           }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxDCtrlRTTI;

interface

{$I frx.inc}

implementation

uses
  Windows, Classes, SysUtils, Forms, fs_iinterpreter, fs_iformsrtti,
  frxDCtrl, frxClassRTTI
{$IFDEF Delphi6}
, Variants
{$ENDIF};


type
  TFunctions = class(TfsRTTIModule)
  private
    function CallMethod(Instance: TObject; ClassType: TClass;
      const MethodName: String; Caller: TfsMethodHelper): Variant;
    function GetProp(Instance: TObject; ClassType: TClass;
      const PropName: String): Variant;
    procedure SetProp(Instance: TObject; ClassType: TClass;
      const PropName: String; Value: Variant);
  public
    constructor Create(AScript: TfsScript); override;
  end;


{ TFunctions }

constructor TFunctions.Create(AScript: TfsScript);
begin
  inherited Create(AScript);
  with AScript do
  begin
    AddClass(TfrxLabelControl, 'TfrxDialogControl');
    AddClass(TfrxEditControl, 'TfrxDialogControl');
    AddClass(TfrxMemoControl, 'TfrxDialogControl');
    AddClass(TfrxButtonControl, 'TfrxDialogControl');
    AddClass(TfrxCheckBoxControl, 'TfrxDialogControl');
    AddClass(TfrxRadioButtonControl, 'TfrxDialogControl');
    with AddClass(TfrxListBoxControl, 'TfrxDialogControl') do
      AddProperty('ItemIndex', 'Integer', GetProp, SetProp);
    AddClass(TfrxComboBoxControl, 'TfrxDialogControl');
    AddClass(TfrxDateEditControl, 'TfrxDialogControl');
    AddClass(TfrxImageControl, 'TfrxDialogControl');
    AddClass(TfrxBevelControl, 'TfrxDialogControl');
    AddClass(TfrxPanelControl, 'TfrxDialogControl');
    AddClass(TfrxGroupBoxControl, 'TfrxDialogControl');
    AddClass(TfrxBitBtnControl, 'TfrxDialogControl');
    AddClass(TfrxSpeedButtonControl, 'TfrxDialogControl');
    AddClass(TfrxMaskEditControl, 'TfrxDialogControl');
    with AddClass(TfrxCheckListBoxControl, 'TfrxDialogControl') do
    begin
      AddIndexProperty('Checked', 'Integer', 'Boolean', CallMethod);
      AddIndexProperty('State', 'Integer', 'TCheckBoxState', CallMethod);
      AddProperty('ItemIndex', 'Integer', GetProp, SetProp);
    end;
  end;
end;

function TFunctions.CallMethod(Instance: TObject; ClassType: TClass;
  const MethodName: String; Caller: TfsMethodHelper): Variant;
begin
  Result := 0;

  if ClassType = TfrxCheckListBoxControl then
  begin
    if MethodName = 'CHECKED.GET' then
      Result := TfrxCheckListBoxControl(Instance).Checked[Caller.Params[0]]
    else if MethodName = 'CHECKED.SET' then
      TfrxCheckListBoxControl(Instance).Checked[Caller.Params[0]] := Caller.Params[1]
    else if MethodName = 'STATE.GET' then
      Result := TfrxCheckListBoxControl(Instance).State[Caller.Params[0]]
    else if MethodName = 'STATE.SET' then
      TfrxCheckListBoxControl(Instance).State[Caller.Params[0]] := Caller.Params[1]
  end
end;

function TFunctions.GetProp(Instance: TObject; ClassType: TClass;
  const PropName: String): Variant;
begin
  Result := 0;

  if ClassType = TfrxListBoxControl then
  begin
    if PropName = 'ITEMINDEX' then
      Result := TfrxListBoxControl(Instance).ItemIndex
  end
  else if ClassType = TfrxCheckListBoxControl then
  begin
    if PropName = 'ITEMINDEX' then
      Result := TfrxCheckListBoxControl(Instance).ItemIndex
  end
end;

procedure TFunctions.SetProp(Instance: TObject; ClassType: TClass;
  const PropName: String; Value: Variant);
begin
  if ClassType = TfrxListBoxControl then
  begin
    if PropName = 'ITEMINDEX' then
      TfrxListBoxControl(Instance).ItemIndex := Value;
  end
  else if ClassType = TfrxCheckListBoxControl then
  begin
    if PropName = 'ITEMINDEX' then
      TfrxCheckListBoxControl(Instance).ItemIndex := Value;
  end
end;


initialization
  fsRTTIModules.Add(TFunctions);

end.


//0f31356a91fea3356e5f76cdce90aa7b