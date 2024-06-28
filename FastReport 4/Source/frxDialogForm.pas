
{******************************************}
{                                          }
{             FastReport v4.0              }
{               Dialog form                }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxDialogForm;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs
{$IFDEF Delphi6}
, Variants
{$ENDIF};

type
  TfrxDialogForm = class(TForm)
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  protected
    procedure ReadState(Reader: TReader); override;
  private
    FOnModify: TNotifyEvent;
    FThreadSafe: Boolean;
    procedure WMExitSizeMove(var Msg: TMessage); message WM_EXITSIZEMOVE;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
  public
    constructor Create(AOwner: TComponent); override;
    property OnModify: TNotifyEvent read FOnModify write FOnModify;
    property ThreadSafe: Boolean read FThreadSafe write FThreadSafe;
  end;

implementation

{$R *.DFM}

procedure TfrxDialogForm.WMExitSizeMove(var Msg: TMessage);
begin
  inherited;
  if Assigned(OnModify) then
    OnModify(Self);
end;

procedure TfrxDialogForm.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result := DLGC_WANTARROWS or DLGC_WANTTAB;
end;

procedure TfrxDialogForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
end;

procedure TfrxDialogForm.ReadState(Reader: TReader);
begin
  if not ThreadSafe then
    inherited ReadState(Reader);
end;

constructor TfrxDialogForm.Create(AOwner: TComponent);
begin
  if AOwner <> nil then
    FThreadSafe := AOwner.Tag = 318;
  AOwner := nil;
  inherited;
end;


end.


//0f31356a91fea3356e5f76cdce90aa7b