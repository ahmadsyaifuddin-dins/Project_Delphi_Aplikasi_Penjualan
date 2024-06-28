
{******************************************}
{                                          }
{             FastReport v4.0              }
{            Highlight editor              }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxEditHighlight;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, frxClass, ExtCtrls, Buttons, frxCtrls
{$IFDEF Delphi6}
, Variants
{$ENDIF};
  

type
  TfrxHighlightEditorForm = class(TForm)
    OKB: TButton;
    CancelB: TButton;
    ConditionL: TGroupBox;
    ConditionE: TfrxComboEdit;
    FontL: TGroupBox;
    FontColorB: TSpeedButton;
    BoldCB: TCheckBox;
    ItalicCB: TCheckBox;
    UnderlineCB: TCheckBox;
    ColorDialog1: TColorDialog;
    BackgroundL: TGroupBox;
    BackColorB: TSpeedButton;
    TransparentRB: TRadioButton;
    OtherRB: TRadioButton;
    procedure FontColorBClick(Sender: TObject);
    procedure BackColorBClick(Sender: TObject);
    procedure TransparentRBClick(Sender: TObject);
    procedure ConditionEButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FBackColor: TColor;
    FFontColor: TColor;
    FHighlight: TfrxHighlight;
    FMemoView: TfrxCustomMemoView;
    procedure SetGlyph(Button: TSpeedButton; Color: TColor);
  public
    property MemoView: TfrxCustomMemoView read FMemoView write FMemoView;
    procedure HostControls(Host: TWinControl);
    procedure UnhostControls(AModalResult: TModalResult);
  end;


implementation

{$R *.DFM}

uses frxRes;


procedure TfrxHighlightEditorForm.FormShow(Sender: TObject);
begin
  FHighlight := FMemoView.Highlight;
  FBackColor := FHighlight.Color;
  FFontColor := FHighlight.Font.Color;

  ConditionE.Text := FHighlight.Condition;
  BoldCB.Checked := fsBold in FHighlight.Font.Style;
  ItalicCB.Checked := fsItalic in FHighlight.Font.Style;
  UnderlineCB.Checked := fsUnderline in FHighlight.Font.Style;
  SetGlyph(FontColorB, FFontColor);

  if FBackColor = clTransparent then
    TransparentRB.Checked := True else
    OtherRB.Checked := True;
  SetGlyph(BackColorB, FBackColor);

  TransparentRBClick(nil);
end;

procedure TfrxHighlightEditorForm.FormHide(Sender: TObject);
var
  fs: TFontStyles;
begin
  if ModalResult = mrOk then
  begin
    FHighlight.Condition := ConditionE.Text;

    fs := [];
    if BoldCB.Checked then
      fs := fs + [fsBold];
    if ItalicCB.Checked then
      fs := fs + [fsItalic];
    if UnderlineCB.Checked then
      fs := fs + [fsUnderline];

    FHighlight.Font := MemoView.Font;
    FHighlight.Font.Style := fs;
    FHighlight.Font.Color := FFontColor;
    FHighlight.Color := FBackColor;
  end;
end;

procedure TfrxHighlightEditorForm.SetGlyph(Button: TSpeedButton; Color: TColor);
var
  bmp: TBitmap;
begin
  bmp := TBitmap.Create;
  bmp.Width := 14;
  bmp.Height := 15;
  with bmp.Canvas do
  begin
    Brush.Color := clBtnFace;
    FillRect(Rect(0, 0, 14, 15));
    Pen.Color := clGray;
    Brush.Color := Color;
    Rectangle(0, 0, 14, 14);
  end;

  Button.Glyph := bmp;
  bmp.Free;
end;

procedure TfrxHighlightEditorForm.FontColorBClick(Sender: TObject);
begin
  ColorDialog1.Color := FFontColor;
  if ColorDialog1.Execute then
  begin
    FFontColor := ColorDialog1.Color;
    SetGlyph(FontColorB, FFontColor);
  end;
end;

procedure TfrxHighlightEditorForm.BackColorBClick(Sender: TObject);
begin
  ColorDialog1.Color := FBackColor;
  if ColorDialog1.Execute then
  begin
    FBackColor := ColorDialog1.Color;
    SetGlyph(BackColorB, FBackColor);
  end;
end;

procedure TfrxHighlightEditorForm.TransparentRBClick(Sender: TObject);
begin
  BackColorB.Enabled := OtherRB.Checked;
  if TransparentRB.Checked then
    FBackColor := clTransparent;
end;

procedure TfrxHighlightEditorForm.ConditionEButtonClick(Sender: TObject);
var
  s: String;
begin
  s := TfrxCustomDesigner(Owner).InsertExpression(ConditionE.Text);
  if s <> '' then
    ConditionE.Text := s;
end;

procedure TfrxHighlightEditorForm.FormCreate(Sender: TObject);
begin
  Caption := frxGet(4600);
  FontColorB.Caption := frxGet(4601);
  BackColorB.Caption := frxGet(4602);
  ConditionL.Caption := frxGet(4603);
  FontL.Caption := frxGet(4604);
  BackgroundL.Caption := frxGet(4605);
  OKB.Caption := frxGet(1);
  CancelB.Caption := frxGet(2);
  BoldCB.Caption := frxGet(4606);
  ItalicCB.Caption := frxGet(4607);
  UnderlineCB.Caption := frxGet(4608);
  TransparentRB.Caption := frxGet(4609);
  OtherRB.Caption := frxGet(4610);
end;

procedure TfrxHighlightEditorForm.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

procedure TfrxHighlightEditorForm.HostControls(Host: TWinControl);
begin
  ConditionL.Parent := Host;
  FontL.Parent := Host;
  BackgroundL.Parent := Host;
  FormShow(Self);
end;

procedure TfrxHighlightEditorForm.UnhostControls(AModalResult: TModalResult);
begin
  ModalResult := AModalResult;
  FormHide(Self);
end;

end.



//0f31356a91fea3356e5f76cdce90aa7b