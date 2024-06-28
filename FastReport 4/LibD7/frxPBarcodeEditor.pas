
{******************************************}
{                                          }
{             FastReport v4.0              }
{       PSOFT Barcode design editor        }
{           http://www.psoft.sk            }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxPBarcodeEditor;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, ExtCtrls, Buttons, frxClass, frxPBarcode, frxCustomEditors,
  EanKod, EanSpecs, frxCtrls, ComCtrls
{$IFDEF Delphi6}
, Variants
{$ENDIF};
  

type
  TfrxPBarcodeEditor = class(TfrxViewEditor)
  public
    function Edit: Boolean; override;
    function HasEditor: Boolean; override;
    procedure GetMenuItems; override;
    function Execute(Tag: Integer; Checked: Boolean): Boolean; override;
  end;

  TfrxPBarcodeEditorForm = class(TForm)
    CancelB: TButton;
    OkB: TButton;
    CodeE: TfrxComboEdit;
    CodeLbl: TLabel;
    TypeCB: TComboBox;
    TypeLbl: TLabel;
    ExampleBvl: TBevel;
    ExamplePB: TPaintBox;
    OptionsLbl: TGroupBox;
    CalcCheckSumCB: TCheckBox;
    ViewTextCB: TCheckBox;
    RotationLbl: TGroupBox;
    Rotation0RB: TRadioButton;
    Rotation90RB: TRadioButton;
    Rotation180RB: TRadioButton;
    Rotation270RB: TRadioButton;
    procedure ExprBtnClick(Sender: TObject);
    procedure ExamplePBPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FBarcode: TfrxPBarcodeView;
  public
    { Public declarations }
    property Barcode: TfrxPBarcodeView read FBarcode write FBarcode;
  end;


implementation

uses frxDsgnIntf, frxRes, frxUtils;

{$R *.DFM}


{ TfrxPBarcodeEditor }

function TfrxPBarcodeEditor.HasEditor: Boolean;
begin
  Result := True;
end;

function TfrxPBarcodeEditor.Edit: Boolean;
begin
  with TfrxPBarcodeEditorForm.Create(Designer) do
  begin
    Barcode := TfrxPBarcodeView(Component);
    Result := ShowModal = mrOk;
    Free;
  end;
end;

function TfrxPBarcodeEditor.Execute(Tag: Integer; Checked: Boolean): Boolean;
var
  i: Integer;
  c: TfrxComponent;
  v: TfrxPBarcodeView;
begin
  Result := inherited Execute(Tag, Checked);
  for i := 0 to Designer.SelectedObjects.Count - 1 do
  begin
    c := Designer.SelectedObjects[i];
    if (c is TfrxPBarcodeView) and not (rfDontModify in c.Restrictions) then
    begin
      v := TfrxPBarcodeView(c);
      if Tag = 1 then
        v.CalcCheckSum := Checked
      else if Tag = 2 then
        v.ShowText := Checked;
      Result := True;
    end;
  end;
end;

procedure TfrxPBarcodeEditor.GetMenuItems;
var
  v: TfrxPBarcodeView;
begin
  v := TfrxPBarcodeView(Component);
  AddItem(frxResources.Get('bcCalcChecksum'), 1, v.CalcCheckSum);
  AddItem(frxResources.Get('bcShowText'), 2, v.ShowText);
  inherited;
end;


{ TfrxPBarcodeEditorForm }

procedure TfrxPBarcodeEditorForm.FormShow(Sender: TObject);
begin
  FBarcode.BarCode.AddTypesToList(TypeCB.Items, btText);

  CodeE.Text := FBarcode.Text;
  TypeCB.ItemIndex := Integer(FBarcode.BarType);
  CalcCheckSumCB.Checked := FBarcode.CalcCheckSum;
  ViewTextCB.Checked := FBarcode.ShowText;

  case FBarcode.Rotation of
    90:  Rotation90RB.Checked := True;
    180: Rotation180RB.Checked := True;
    270: Rotation270RB.Checked := True;
    else Rotation0RB.Checked := True;
  end;

  ExamplePBPaint(nil);
end;

procedure TfrxPBarcodeEditorForm.FormHide(Sender: TObject);
begin
  if ModalResult = mrOk then
  begin
    FBarcode.Text := CodeE.Text;
    FBarcode.BarType := TTypBarcode(TypeCB.ItemIndex);
    FBarcode.CalcCheckSum := CalcCheckSumCB.Checked;
    FBarcode.ShowText := ViewTextCB.Checked;

    if Rotation90RB.Checked then
      FBarcode.Rotation := 90
    else if Rotation180RB.Checked then
      FBarcode.Rotation := 180
    else if Rotation270RB.Checked then
      FBarcode.Rotation := 270
    else
      FBarcode.Rotation := 0;
  end;
end;

procedure TfrxPBarcodeEditorForm.ExprBtnClick(Sender: TObject);
var
  s: String;
begin
  s := TfrxCustomDesigner(Owner).InsertExpression(CodeE.Text);
  if s <> '' then
    CodeE.Text := s;
end;

procedure TfrxPBarcodeEditorForm.ExamplePBPaint(Sender: TObject);
var
  Barcode: TfrxPBarcodeView;
begin
  Barcode := TfrxPBarcodeView.Create(nil);
  Barcode.BarType := TTypBarcode(TypeCB.ItemIndex);
  if Rotation0RB.Checked then
    Barcode.Rotation := 0
  else if Rotation90RB.Checked then
    Barcode.Rotation := 90
  else if Rotation180RB.Checked then
    Barcode.Rotation := 180
  else
    Barcode.Rotation := 270;
  Barcode.CalcCheckSum  := CalcCheckSumCB.Checked;
  Barcode.ShowText := ViewTextCB.Checked;
  Barcode.SetBounds(20, 20, ExamplePB.Width - 40, 200);

  with ExamplePB.Canvas do
  begin
    Brush.Color := clWhite;
    FillRect(Rect(0, 0, ExamplePB.Width, ExamplePB.Height));
  end;

  Barcode.Draw(ExamplePB.Canvas, 1, 1, 0, 0);
  Barcode.Free;
end;

procedure TfrxPBarcodeEditorForm.FormCreate(Sender: TObject);
begin
  Caption := frxGet(3500);
  CodeLbl.Caption := frxGet(3501);
  TypeLbl.Caption := frxGet(3502);
  OptionsLbl.Caption := frxGet(3504);
  RotationLbl.Caption := frxGet(3505);
  CancelB.Caption := frxGet(2);
  OkB.Caption := frxGet(1);
  CalcCheckSumCB.Caption := frxGet(3506);
  ViewTextCB.Caption := frxGet(3507);
  Rotation0RB.Caption := frxGet(3508);
  Rotation90RB.Caption := frxGet(3509);
  Rotation180RB.Caption := frxGet(3510);
  Rotation270RB.Caption := frxGet(3511);
end;


procedure TfrxPBarcodeEditorForm.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

initialization
  frxComponentEditors.Register(TfrxPBarcodeView, TfrxPBarcodeEditor);


end.


//0f31356a91fea3356e5f76cdce90aa7b