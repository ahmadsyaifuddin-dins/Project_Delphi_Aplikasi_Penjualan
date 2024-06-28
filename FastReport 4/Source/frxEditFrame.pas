
{******************************************}
{                                          }
{             FastReport v4.0              }
{              Frame editor                }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxEditFrame;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ImgList, ExtCtrls, StdCtrls, frxCtrls, frxDock, ComCtrls, ToolWin, frxClass;

type
  TfrxFrameEditorForm = class(TForm)
    FrameL: TLabel;
    LineL: TLabel;
    ShadowL: TLabel;
    OkB: TButton;
    CancelB: TButton;
    ToolBar1: TToolBar;
    FrameTopB: TToolButton;
    FrameBottomB: TToolButton;
    FrameLeftB: TToolButton;
    FrameRightB: TToolButton;
    Sep1: TToolButton;
    FrameAllB: TToolButton;
    FrameNoB: TToolButton;
    ToolBar2: TToolBar;
    FrameColorB: TToolButton;
    FrameStyleB: TToolButton;
    Sep2: TfrxTBPanel;
    FrameWidthCB: TfrxComboBox;
    ToolBar3: TToolBar;
    ShadowB: TToolButton;
    ShadowColorB: TToolButton;
    Sep3: TfrxTBPanel;
    ShadowWidthCB: TfrxComboBox;
    Bevel1: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure BClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FFrame: TfrxFrame;
    FImageList: TImageList;
    procedure UpdateControls;
  public
    property Frame: TfrxFrame read FFrame;
  end;


implementation

{$R *.DFM}

uses frxDesgnCtrls, frxUtils, frxRes;


procedure TfrxFrameEditorForm.FormCreate(Sender: TObject);
begin
  FFrame := TfrxFrame.Create;
  Caption := frxGet(5200);
  FrameL.Caption := frxGet(5201);
  LineL.Caption := frxGet(5202);
  ShadowL.Caption := frxGet(5203);
  FrameTopB.Hint := frxGet(5204);
  FrameBottomB.Hint := frxGet(5205);
  FrameLeftB.Hint := frxGet(5206);
  FrameRightB.Hint := frxGet(5207);
  FrameAllB.Hint := frxGet(5208);
  FrameNoB.Hint := frxGet(5209);
  FrameColorB.Hint := frxGet(5210);
  FrameStyleB.Hint := frxGet(5211);
  FrameWidthCB.Hint := frxGet(5212);
  ShadowB.Hint := frxGet(5213);
  ShadowColorB.Hint := frxGet(5214);
  ShadowWidthCB.Hint := frxGet(5215);
  OkB.Caption := frxGet(1);
  CancelB.Caption := frxGet(2);

  FImageList := frxResources.MainButtonImages;
  ToolBar1.Images := FImageList;
  ToolBar2.Images := FImageList;
  ToolBar3.Images := FImageList;
end;

procedure TfrxFrameEditorForm.FormDestroy(Sender: TObject);
begin
  FFrame.Free;
end;

procedure TfrxFrameEditorForm.FormShow(Sender: TObject);
begin
  UpdateControls;
end;

procedure TfrxFrameEditorForm.UpdateControls;
begin
  FrameTopB.Down := ftTop in FFrame.Typ;
  FrameBottomB.Down := ftBottom in FFrame.Typ;
  FrameLeftB.Down := ftLeft in FFrame.Typ;
  FrameRightB.Down := ftRight in FFrame.Typ;
  ShadowB.Down := FFrame.DropShadow;
  FrameWidthCB.Text := FloatToStr(FFrame.Width);
  ShadowWidthCB.Text := FloatToStr(FFrame.ShadowWidth);
end;

procedure TfrxFrameEditorForm.BClick(Sender: TObject);

  procedure SetFrameType(fType: TfrxFrameType; Include: Boolean);
  begin
     with FFrame do
      if Include then
        Typ := Typ + [fType] else
        Typ := Typ - [fType];
  end;

begin
  case TControl(Sender).Tag of
    1: SetFrameType(ftTop, FrameTopB.Down);
    2: SetFrameType(ftBottom, FrameBottomB.Down);
    3: SetFrameType(ftLeft, FrameLeftB.Down);
    4: SetFrameType(ftRight, FrameRightB.Down);
    5: FFrame.Typ := [ftLeft, ftRight, ftTop, ftBottom];
    6: FFrame.Typ := [];
    7:
      with TfrxColorSelector.Create(TComponent(Sender)) do
      begin
        OnColorChanged := BClick;
        Tag := 70;
      end;
    70: FFrame.Color := TfrxColorSelector(Sender).Color;
    8:
      with TfrxLineSelector.Create(TComponent(Sender)) do
      begin
        OnStyleChanged := BClick;
        Tag := 80;
      end;
    80: FFrame.Style := TfrxFrameStyle(TfrxLineSelector(Sender).Style);
    9: FFrame.Width := frxStrToFloat(FrameWidthCB.Text);
    10: FFrame.DropShadow := ShadowB.Down;
    11:
      with TfrxColorSelector.Create(TComponent(Sender)) do
      begin
        OnColorChanged := BClick;
        Tag := 110;
      end;
    110: FFrame.ShadowColor := TfrxColorSelector(Sender).Color;
    12: FFrame.ShadowWidth := frxStrToFloat(ShadowWidthCB.Text);
  end;

  UpdateControls;
end;

procedure TfrxFrameEditorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

end.


//0f31356a91fea3356e5f76cdce90aa7b