
{******************************************}
{                                          }
{             FastReport v4.0              }
{             TStrings editor              }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxEditStrings;

interface

{$I frx.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls, ToolWin
{$IFDEF Delphi6}
, Variants
{$ENDIF};
  

type
  TfrxStringsEditorForm = class(TForm)
    ToolBar: TToolBar;
    OkB: TToolButton;
    CancelB: TToolButton;
    Memo: TMemo;
    procedure OkBClick(Sender: TObject);
    procedure CancelBClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MemoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


implementation

{$R *.DFM}

uses frxClass, frxRes;


procedure TfrxStringsEditorForm.OkBClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrxStringsEditorForm.CancelBClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrxStringsEditorForm.FormCreate(Sender: TObject);
begin
  Toolbar.Images := frxResources.MainButtonImages;
  Caption := frxGet(4800);
  CancelB.Hint := frxGet(2);
  OkB.Hint := frxGet(1);
end;

procedure TfrxStringsEditorForm.MemoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = vk_Return) and (ssCtrl in Shift) then
    ModalResult := mrOk
  else if Key = vk_Escape then
    ModalResult := mrCancel;
end;

procedure TfrxStringsEditorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

end.



//0f31356a91fea3356e5f76cdce90aa7b