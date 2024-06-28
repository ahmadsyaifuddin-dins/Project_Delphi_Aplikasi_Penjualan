
{******************************************}
{                                          }
{             FastReport v4.0              }
{              Picture editor              }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxEditPicture;

interface

{$I frx.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls, ToolWin, frxCtrls,
  frxDock
{$IFDEF Delphi6}
, Variants
{$ENDIF};
  

type
  TfrxPictureEditorForm = class(TForm)
    ToolBar: TToolBar;
    LoadB: TToolButton;
    ClearB: TToolButton;
    OkB: TToolButton;
    Box: TScrollBox;
    ToolButton1: TToolButton;
    CancelB: TToolButton;
    Image: TImage;
    StatusBar: TStatusBar;
    CopyB: TToolButton;
    PasteB: TToolButton;
    procedure ClearBClick(Sender: TObject);
    procedure LoadBClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OkBClick(Sender: TObject);
    procedure CancelBClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CopyBClick(Sender: TObject);
    procedure PasteBClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    procedure UpdateImage;
  public
    { Public declarations }
  end;


implementation

{$R *.DFM}

uses frxClass, frxUtils, frxRes, ClipBrd {$IFDEF OPENPICTUREDLG}, ExtDlgs {$ENDIF};

type
  THackWinControl = class(TWinControl);

{ TfrxPictureEditorForm }

procedure TfrxPictureEditorForm.UpdateImage;
begin
  if (Image.Picture.Graphic = nil) or Image.Picture.Graphic.Empty then
    StatusBar.Panels[0].Text := frxResources.Get('piEmpty')
  else
  begin
    StatusBar.Panels[0].Text := Format('%d x %d',
      [Image.Picture.Width, Image.Picture.Height]);
    Image.Stretch := (Image.Picture.Width > Image.Width) or
      (Image.Picture.Height > Image.Height);
  end;
end;

procedure TfrxPictureEditorForm.FormShow(Sender: TObject);
begin
  Toolbar.Images := frxResources.MainButtonImages;
  THackWinControl(Box).BevelKind := bkFlat;
  UpdateImage;
end;

procedure TfrxPictureEditorForm.ClearBClick(Sender: TObject);
begin
  Image.Picture.Assign(nil);
  UpdateImage;
end;

procedure TfrxPictureEditorForm.LoadBClick(Sender: TObject);
var
{$IFDEF OPENPICTUREDLG}
  OpenDlg: TOpenPictureDialog;
{$ELSE}
  OpenDlg: TOpenDialog;
{$ENDIF}
begin
{$IFDEF OPENPICTUREDLG}
  OpenDlg := TOpenPictureDialog.Create(nil);
{$ELSE}
  OpenDlg := TOpenDialog.Create(nil);
{$ENDIF}
  OpenDlg.Options := [];
  OpenDlg.Filter := frxResources.Get('ftPictures') + ' (*.bmp ' +
{$IFDEF JPEG}
    '*.jpg ' +
{$ENDIF}
{$IFDEF PNG}
    '*.png ' +
{$ENDIF}
    '*.ico *.wmf *.emf)|*.bmp;' +
{$IFDEF JPEG}
    '*.jpg;' +
{$ENDIF}
{$IFDEF PNG}
    '*.png;' +
{$ENDIF}
    '*.ico;*.wmf;*.emf|' + frxResources.Get('ftAllFiles') + '|*.*';
  if OpenDlg.Execute then
    Image.Picture.LoadFromFile(OpenDlg.FileName);
  OpenDlg.Free;
  UpdateImage;
end;

procedure TfrxPictureEditorForm.OkBClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrxPictureEditorForm.CancelBClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrxPictureEditorForm.FormCreate(Sender: TObject);
begin
  Caption := frxGet(4000);
  LoadB.Hint := frxGet(4001);
  CopyB.Hint := frxGet(4002);
  PasteB.Hint := frxGet(4003);
  ClearB.Hint := frxGet(4004);
  CancelB.Hint := frxGet(2);
  OkB.Hint := frxGet(1);
end;

procedure TfrxPictureEditorForm.CopyBClick(Sender: TObject);
begin
  if Image.Picture <> nil then
    Clipboard.Assign(Image.Picture);
end;

procedure TfrxPictureEditorForm.PasteBClick(Sender: TObject);
begin
  Image.Picture.Assign(Clipboard);
  UpdateImage;
end;

procedure TfrxPictureEditorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

end.



//0f31356a91fea3356e5f76cdce90aa7b