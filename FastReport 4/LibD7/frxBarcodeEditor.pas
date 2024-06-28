
{******************************************}
{                                          }
{             FastReport v4.0              }
{          Barcode design editor           }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxBarcodeEditor;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, ExtCtrls, Buttons, frxClass, frxBarcode, frxCustomEditors,
  frxBarcod, frxCtrls, ComCtrls
{$IFDEF Delphi6}
, Variants
{$ENDIF};
  

type
  TfrxBarcodeEditor = class(TfrxViewEditor)
  public
    function Edit: Boolean; override;
    function HasEditor: Boolean; override;
    procedure GetMenuItems; override;
    function Execute(Tag: Integer; Checked: Boolean): Boolean; override;
  end;

  TfrxBarcodeEditorForm = class(TForm)
    CancelB: TButton;
    OkB: TButton;
    CodeE: TfrxComboEdit;
    CodeLbl: TLabel;
    TypeCB: TComboBox;
    TypeLbl: TLabel;
    ExampleBvl: TBevel;
    ExamplePB: TPaintBox;
    OptionsLbl: TGroupBox;
    ZoomLbl: TLabel;
    CalcCheckSumCB: TCheckBox;
    ViewTextCB: TCheckBox;
    ZoomE: TEdit;
    UpDown1: TUpDown;
    RotationLbl: TGroupBox;
    Rotation0RB: TRadioButton;
    Rotation90RB: TRadioButton;
    Rotation180RB: TRadioButton;
    Rotation270RB: TRadioButton;
    procedure ExprBtnClick(Sender: TObject);
    procedure UpBClick(Sender: TObject);
    procedure DownBClick(Sender: TObject);
    procedure ExamplePBPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FBarcode: TfrxBarcodeView;
  public
    { Public declarations }
    property Barcode: TfrxBarcodeView read FBarcode write FBarcode;
  end;


implementation

uses frxDsgnIntf, frxRes, frxUtils;

{$R *.DFM}

const
  cbDefaultText = '12345678';


{ TfrxBarcodeEditor }

function TfrxBarcodeEditor.HasEditor: Boolean;
begin
  Result := True;
end;

function TfrxBarcodeEditor.Edit: Boolean;
begin
  with TfrxBarcodeEditorForm.Create(Designer) do
  begin
    Barcode := TfrxBarcodeView(Component);
    Result := ShowModal = mrOk;
    Free;
  end;
end;

function TfrxBarcodeEditor.Execute(Tag: Integer; Checked: Boolean): Boolean;
var
  i: Integer;
  c: TfrxComponent;
  v: TfrxBarcodeView;
begin
  Result := inherited Execute(Tag, Checked);
  for i := 0 to Designer.SelectedObjects.Count - 1 do
  begin
    c := Designer.SelectedObjects[i];
    if (c is TfrxBarcodeView) and not (rfDontModify in c.Restrictions) then
    begin
      v := TfrxBarcodeView(c);
      if Tag = 1 then
        v.CalcCheckSum := Checked
      else if Tag = 2 then
        v.ShowText := Checked;
      Result := True;
    end;
  end;
end;

procedure TfrxBarcodeEditor.GetMenuItems;
var
  v: TfrxBarcodeView;
begin
  v := TfrxBarcodeView(Component);
  AddItem(frxResources.Get('bcCalcChecksum'), 1, v.CalcCheckSum);
  AddItem(frxResources.Get('bcShowText'), 2, v.ShowText);
  inherited;
end;


{ TfrxBarcodeEditorForm }

procedure TfrxBarcodeEditorForm.FormShow(Sender: TObject);
var
  i: TfrxBarcodeType;
begin
  TypeCB.Items.Clear;
  for i := bcCode_2_5_interleaved to bcCodeEAN128C do
    TypeCB.Items.Add(bcData[i].Name);

  CodeE.Text := FBarcode.Expression;
  TypeCB.ItemIndex := Integer(FBarcode.BarType);
  CalcCheckSumCB.Checked := FBarcode.CalcCheckSum;
  ViewTextCB.Checked := FBarcode.ShowText;
  ZoomE.Text := FloatToStr(FBarcode.Zoom);

  case FBarcode.Rotation of
    90:  Rotation90RB.Checked := True;
    180: Rotation180RB.Checked := True;
    270: Rotation270RB.Checked := True;
    else Rotation0RB.Checked := True;
  end;

  ExamplePBPaint(nil);
end;

procedure TfrxBarcodeEditorForm.FormHide(Sender: TObject);
begin
  if ModalResult = mrOk then
  begin
    FBarcode.Expression := CodeE.Text;
    FBarcode.BarType := TfrxBarcodeType(TypeCB.ItemIndex);
    FBarcode.CalcCheckSum := CalcCheckSumCB.Checked;
    FBarcode.ShowText := ViewTextCB.Checked;
    FBarcode.Zoom := frxStrToFloat(ZoomE.Text);

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

procedure TfrxBarcodeEditorForm.ExprBtnClick(Sender: TObject);
var
  s: String;
begin
  s := TfrxCustomDesigner(Owner).InsertExpression(CodeE.Text);
  if s <> '' then
    CodeE.Text := s;
end;

procedure TfrxBarcodeEditorForm.UpBClick(Sender: TObject);
var
  i: Double;
begin
  i := frxStrToFloat(ZoomE.Text);
  i := i + 0.1;
  ZoomE.Text := FloatToStr(i);
end;

procedure TfrxBarcodeEditorForm.DownBClick(Sender: TObject);
var
  i: Double;
begin
  i := frxStrToFloat(ZoomE.Text);
  i := i - 0.1;
  if i <= 0 then i := 1;
  ZoomE.Text := FloatToStr(i);
end;

procedure TfrxBarcodeEditorForm.ExamplePBPaint(Sender: TObject);
var
  Barcode: TfrxBarcode;
begin
  Barcode := TfrxBarcode.Create(Self);
  Barcode.Typ := TfrxBarcodeType(TypeCB.ItemIndex);
  Barcode.Text := '12345678';
  if Rotation0RB.Checked then
    Barcode.Angle := 0
  else if Rotation90RB.Checked then
    Barcode.Angle := 90
  else if Rotation180RB.Checked then
    Barcode.Angle := 180
  else
    Barcode.Angle := 270;
  Barcode.CheckSum  := CalcCheckSumCB.Checked;

  with ExamplePB.Canvas do
  begin
    Brush.Color := clWhite;
    FillRect(Rect(0, 0, ExamplePB.Width, ExamplePB.Height));
    Barcode.DrawBarcode(ExamplePB.Canvas, Rect(40, 20, ExamplePB.Width - 40, 200),
      ViewTextCB.Checked);
  end;

  Barcode.Free;
end;

procedure TfrxBarcodeEditorForm.FormCreate(Sender: TObject);
begin
  Caption := frxGet(3500);
  CodeLbl.Caption := frxGet(3501);
  TypeLbl.Caption := frxGet(3502);
  ZoomLbl.Caption := frxGet(3503);
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


procedure TfrxBarcodeEditorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

initialization
  frxComponentEditors.Register(TfrxBarcodeView, TfrxBarcodeEditor);


end.


//0f31356a91fea3356e5f76cdce90aa7b