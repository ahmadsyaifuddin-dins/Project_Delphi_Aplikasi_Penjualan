
{******************************************}
{                                          }
{             FastReport v4.0              }
{             Evaluate dialog              }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxEvaluateForm;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, fs_iinterpreter
{$IFDEF Delphi6}
, Variants
{$ENDIF};

type
  TfrxEvaluateForm = class(TForm)
    Label1: TLabel;
    ExpressionE: TEdit;
    Label2: TLabel;
    ResultM: TMemo;
    OkB: TButton;
    CancelB: TButton;
    procedure ExpressionEKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FScript: TfsScript;
    FIsWatch: Boolean;
  public
    property IsWatch: Boolean read FIsWatch write FIsWatch;
    property Script: TfsScript read FScript write FScript;
  end;


implementation

{$R *.DFM}

uses frxRes;


procedure TfrxEvaluateForm.ExpressionEKeyPress(Sender: TObject; var Key: Char);
var
  v: Variant;
  s: String;
begin
  if IsWatch then Exit;
  if Key = #13 then
  begin
    v := FScript.Evaluate(ExpressionE.Text);
    s := VarToStr(v);
    if TVarData(v).VType = varBoolean then
      if Boolean(v) = True then
        s := 'True' else
        s := 'False'
    else if (TVarData(v).VType = varString) or (TVarData(v).VType = varOleStr) then
      s := '''' + v + ''''
    else if v = Null then
      s := 'Null';
    ResultM.Text := s;
    ExpressionE.SelectAll;
  end
  else if Key = #27 then
    Close;
end;

procedure TfrxEvaluateForm.FormShow(Sender: TObject);
begin
  ExpressionE.SelectAll;
  ResultM.Text := '';
  if IsWatch then
  begin
    OkB.Visible := True;
    CancelB.Visible := True;
    ResultM.Visible := False;
    Label2.Visible := False;
    ClientHeight := OkB.Top + OkB.Height + 4;
  end;
end;

procedure TfrxEvaluateForm.FormCreate(Sender: TObject);
begin
  Caption := frxGet(5500);
  Label1.Caption := frxGet(5501);
  Label2.Caption := frxGet(5502);
  OkB.Caption := frxGet(1);
  CancelB.Caption := frxGet(2);
end;

procedure TfrxEvaluateForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    ModalResult := mrCancel;
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

end.


//0f31356a91fea3356e5f76cdce90aa7b