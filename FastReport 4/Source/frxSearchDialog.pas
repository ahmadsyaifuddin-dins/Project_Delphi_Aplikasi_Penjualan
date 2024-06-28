
{******************************************}
{                                          }
{             FastReport v4.0              }
{              Search dialog               }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxSearchDialog;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TfrxSearchDialog = class(TForm)
    ReplacePanel: TPanel;
    ReplaceL: TLabel;
    ReplaceE: TEdit;
    Panel2: TPanel;
    TextL: TLabel;
    TextE: TEdit;
    Panel3: TPanel;
    OkB: TButton;
    CancelB: TButton;
    SearchL: TGroupBox;
    CaseCB: TCheckBox;
    TopCB: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
  public
  end;


implementation

uses frxRes;

{$R *.DFM}

var
  LastText: String;

procedure TfrxSearchDialog.FormCreate(Sender: TObject);
begin
  Caption := frxGet(300);
  TextL.Caption := frxGet(301);
  SearchL.Caption := frxGet(302);
  ReplaceL.Caption := frxGet(303);
  TopCB.Caption := frxGet(304);
  CaseCB.Caption := frxGet(305);
  OkB.Caption := frxGet(1);
  CancelB.Caption := frxGet(2);
end;

procedure TfrxSearchDialog.FormShow(Sender: TObject);
begin
  TextE.Text := LastText;
  TextE.SetFocus;
  TextE.SelectAll;
end;

procedure TfrxSearchDialog.FormHide(Sender: TObject);
begin
  if ModalResult = mrOk then
    LastText := TextE.Text;
end;

procedure TfrxSearchDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

end.



//0f31356a91fea3356e5f76cdce90aa7b