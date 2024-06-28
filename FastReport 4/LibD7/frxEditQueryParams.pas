
{******************************************}
{                                          }
{             FastReport v4.0              }
{           Query params editor            }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxEditQueryParams;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, Buttons, DB, frxCustomDB, frxCtrls, ExtCtrls
{$IFDEF Delphi6}
, Variants
{$ENDIF};


type
  TfrxParamsEditorForm = class(TForm)
    ParamsLV: TListView;
    TypeCB: TComboBox;
    ValueE: TEdit;
    OkB: TButton;
    CancelB: TButton;
    ButtonPanel: TPanel;
    ExpressionB: TSpeedButton;
    procedure ParamsLVSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure FormShow(Sender: TObject);
    procedure ParamsLVMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OkBClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ValueEButtonClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FParams: TfrxParams;
  public
    property Params: TfrxParams read FParams write FParams;
  end;


implementation

{$R *.DFM}

uses frxClass, frxRes;


{ TfrxParamEditorForm }

procedure TfrxParamsEditorForm.FormShow(Sender: TObject);
var
  i: Integer;
  t: TFieldType;
  Item: TListItem;
begin
  for i := 0 to Params.Count - 1 do
  begin
    Item := ParamsLV.Items.Add;
    Item.Caption := Params[i].Name;
    Item.SubItems.Add(FieldTypeNames[Params[i].DataType]);
    Item.SubItems.Add(Params[i].Expression);
  end;

  for t := Low(TFieldType) to High(TFieldType) do
    TypeCB.Items.Add(FieldTypeNames[t]);

  ParamsLV.Selected := ParamsLV.Items[0];
  ValueE.Height := TypeCB.Height;
  ButtonPanel.Height := TypeCB.Height - 2;
  ExpressionB.Height := TypeCB.Height - 2;
end;

procedure TfrxParamsEditorForm.FormHide(Sender: TObject);
var
  i: Integer;
  t: TFieldType;
  Item: TListItem;
begin
  if ModalResult <> mrOk then Exit;

  for i := 0 to ParamsLV.Items.Count - 1 do
  begin
    Item := ParamsLV.Items[i];
    for t := Low(TFieldType) to High(TFieldType) do
      if Item.SubItems[0] = FieldTypeNames[t] then
      begin
        Params[i].DataType := t;
        break;
      end;
    Params[i].Expression := Item.SubItems[1];
  end;
end;

procedure TfrxParamsEditorForm.ParamsLVSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if Selected then
  begin
    TypeCB.Top := ParamsLV.Top + Item.Top;
    ValueE.Top := TypeCB.Top;
    ButtonPanel.Top := TypeCB.Top;
    TypeCB.ItemIndex := TypeCB.Items.IndexOf(Item.SubItems[0]);
    ValueE.Text := Item.SubItems[1];
  end
  else
  begin
    Item.SubItems[0] := TypeCB.Text;
    Item.SubItems[1] := ValueE.Text;
  end;
end;

procedure TfrxParamsEditorForm.ParamsLVMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ParamsLV.Selected := ParamsLV.GetItemAt(5, Y);
  ParamsLV.ItemFocused := ParamsLV.Selected;
end;

procedure TfrxParamsEditorForm.OkBClick(Sender: TObject);
begin
  ParamsLV.Selected := ParamsLV.Items[0];
end;

procedure TfrxParamsEditorForm.ValueEButtonClick(Sender: TObject);
var
  s: String;
begin
  s := TfrxCustomDesigner(Owner).InsertExpression(ValueE.Text);
  if s <> '' then
    ValueE.Text := s;
end;

procedure TfrxParamsEditorForm.FormCreate(Sender: TObject);
begin

  Caption := frxGet(3700);
  OkB.Caption := frxGet(1);
  CancelB.Caption := frxGet(2);
  ParamsLV.Columns[0].Caption := frxResources.Get('qpName');
  ParamsLV.Columns[1].Caption := frxResources.Get('qpDataType');
  ParamsLV.Columns[2].Caption := frxResources.Get('qpValue');
end;

procedure TfrxParamsEditorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

end.


//0f31356a91fea3356e5f76cdce90aa7b