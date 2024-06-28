
{******************************************}
{                                          }
{             FastReport v4.0              }
{          Inherit error dialog            }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxInheritError;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ImgList, ExtCtrls
{$IFDEF Delphi6}
, Variants
{$ENDIF};

type
  TfrxInheritErrorForm = class(TForm)
    OkB: TButton;
    CancelB: TButton;
    MessageL: TLabel;
    DeleteRB: TRadioButton;
    RenameRB: TRadioButton;
    PaintBox1: TPaintBox;
    ImageList1: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


implementation

{$R *.dfm}

uses frxRes;

procedure TfrxInheritErrorForm.FormCreate(Sender: TObject);
begin
  Caption := frxGet(6000);
  OkB.Caption := frxGet(1);
  CancelB.Caption := frxGet(2);
  MessageL.Caption := frxGet(6001);
  DeleteRB.Caption := frxGet(6002);
  RenameRB.Caption := frxGet(6003);
end;

procedure TfrxInheritErrorForm.PaintBox1Paint(Sender: TObject);
begin
  with PaintBox1 do
  begin
    Canvas.Brush.Color := Color;
    Canvas.FillRect(Rect(0, 0, 32, 32));
    ImageList1.Draw(Canvas, 0, 0, 0);
  end;
end;

end.


//0f31356a91fea3356e5f76cdce90aa7b