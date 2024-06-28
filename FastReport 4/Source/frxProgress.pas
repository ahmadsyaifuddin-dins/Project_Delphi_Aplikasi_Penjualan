
{******************************************}
{                                          }
{             FastReport v4.0              }
{                Progress                  }
{                                          }
{            Copyright (c) 2004            }
{          by Alexander Fediachov,         }
{             Fast Reports, Inc.           }
{                                          }
{******************************************}

unit frxProgress;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls;

type
  TfrxProgress = class(TForm)
    Panel1: TPanel;
    LMessage: TLabel;
    Bar: TProgressBar;
    CancelB: TButton;
    procedure WMNCHitTest(var Message :TWMNCHitTest); message WM_NCHITTEST;
    procedure FormCreate(Sender: TObject);
    procedure CancelBClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FActiveForm: TForm;
    FTerminated: Boolean;
    FPosition: Integer;
    FMessage: String;
    FProgress: Boolean;
    procedure SetPosition(Value: Integer);
    procedure SetMessage(const Value: String);
    procedure SetTerminated(Value: Boolean);
    procedure SetProgress(Value: Boolean);
  public
    procedure Reset;
    procedure Execute(MaxValue: Integer; const Msg: String;
      Canceled: Boolean; Progress: Boolean);
    procedure Tick;
    property Terminated: Boolean read FTerminated write SetTerminated;
    property Position: Integer read FPosition write SetPosition;
    property ShowProgress: Boolean read FProgress write SetProgress;
    property Message: String read FMessage write SetMessage;
  end;


implementation

{$R *.DFM}

uses frxRes;

{ TfrxProgress }

procedure TfrxProgress.WMNCHitTest(var Message: TWMNCHitTest);
begin
  inherited;
  if Message.Result = htClient then
    Message.Result := htCaption;
end;

procedure TfrxProgress.FormCreate(Sender: TObject);
begin
  CancelB.Caption := frxGet(2);
  FActiveForm := Screen.ActiveForm;
  if FActiveForm <> nil then
    FActiveForm.Enabled := False;
  Bar.Min := 0;
  Bar.Max := 100;
  Position := 0;
end;

procedure TfrxProgress.FormDestroy(Sender: TObject);
begin
  if FActiveForm <> nil then
    FActiveForm.Enabled := True;
end;

procedure TfrxProgress.FormHide(Sender: TObject);
begin
  if FActiveForm <> nil then
    FActiveForm.Enabled := True;
end;

procedure TfrxProgress.Reset;
begin
  Position := 0;
end;

procedure TfrxProgress.SetPosition(Value: Integer);
begin
  FPosition := Value;
  Bar.Position := Value;
  BringToFront;
  Application.ProcessMessages;
end;

procedure TfrxProgress.Execute(MaxValue: Integer; const Msg: String;
  Canceled: Boolean; Progress: Boolean);
begin
  Terminated := False;
  CancelB.Visible := Canceled;
  ShowProgress := Progress;
  Bar.Min := 0;
  Reset;
  Bar.Max := MaxValue;
  Message := Msg;
  Show;
  Application.ProcessMessages;
end;

procedure TfrxProgress.Tick;
begin
  if (Position < Bar.Max) and (Position >= Bar.Min) then
    Position := Position + 1;
end;

procedure TfrxProgress.SetMessage(const Value: String);
begin
  FMessage := Value;
  LMessage.Caption := Value;
  LMessage.Refresh;
end;

procedure TfrxProgress.CancelBClick(Sender: TObject);
begin
  Terminated := True;
end;

procedure TfrxProgress.SetTerminated(Value: boolean);
begin
  FTerminated := Value;
  if Value then Close;
end;

procedure TfrxProgress.SetProgress(Value: boolean);
begin
  Bar.Visible := Value;
  FProgress := Value;
  if Value then
    LMessage.Top := 15
  else
    LMessage.Top := 35;
end;

end.


//0f31356a91fea3356e5f76cdce90aa7b