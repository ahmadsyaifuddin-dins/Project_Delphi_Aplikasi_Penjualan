
{******************************************}
{                                          }
{             FastReport v4.0              }
{            Watches toolwindow            }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxWatchForm;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ToolWin, fs_iinterpreter
{$IFDEF Delphi6}
, Variants
{$ENDIF};

type
  TfrxWatchForm = class(TForm)
    ToolBar1: TToolBar;
    AddB: TToolButton;
    DeleteB: TToolButton;
    EditB: TToolButton;
    WatchLB: TListBox;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure AddBClick(Sender: TObject);
    procedure DeleteBClick(Sender: TObject);
    procedure EditBClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FScript: TfsScript;
    FScriptRunning: Boolean;
    FWatches: TStrings;
    function CalcWatch(const s: String): String;
  public
    procedure UpdateWatches;
    property Script: TfsScript read FScript write FScript;
    property ScriptRunning: Boolean read FScriptRunning write FScriptRunning;
    property Watches: TStrings read FWatches;
  end;


implementation

{$R *.DFM}

uses frxRes, frxEvaluateForm;

type
  THackWinControl = class(TWinControl);


procedure TfrxWatchForm.FormCreate(Sender: TObject);
begin
  Caption := frxGet(5900);
  AddB.Hint := frxGet(5901);
  DeleteB.Hint := frxGet(5902);
  EditB.Hint := frxGet(5903);
  FWatches := TStringList.Create;
  THackWinControl(WatchLB).BevelKind := bkFlat;
end;

procedure TfrxWatchForm.FormDestroy(Sender: TObject);
begin
  FWatches.Free;
end;

procedure TfrxWatchForm.FormShow(Sender: TObject);
begin
  Toolbar1.Images := frxResources.MainButtonImages;
end;

procedure TfrxWatchForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

procedure TfrxWatchForm.AddBClick(Sender: TObject);
begin
  with TfrxEvaluateForm.Create(Owner) do
  begin
    IsWatch := True;
    if ShowModal = mrOk then
    begin
      Watches.Add(ExpressionE.Text);
      UpdateWatches;
    end;
    Free;
  end;
end;

procedure TfrxWatchForm.DeleteBClick(Sender: TObject);
begin
  if WatchLB.ItemIndex <> -1 then
  begin
    Watches.Delete(WatchLB.ItemIndex);
    UpdateWatches;
  end;
end;

procedure TfrxWatchForm.EditBClick(Sender: TObject);
begin
  if WatchLB.ItemIndex <> -1 then
    with TfrxEvaluateForm.Create(Owner) do
    begin
      IsWatch := True;
      ExpressionE.Text := Watches[WatchLB.ItemIndex];
      if ShowModal = mrOk then
      begin
        Watches[WatchLB.ItemIndex] := ExpressionE.Text;
        UpdateWatches;
      end;
      Free;
    end;
end;

function TfrxWatchForm.CalcWatch(const s: String): String;
var
  v: Variant;
begin
  if (FScript <> nil) and (FScriptRunning) then
  begin
    v := FScript.Evaluate(s);
    Result := VarToStr(v);
    if TVarData(v).VType = varBoolean then
      if Boolean(v) = True then
        Result := 'True' else
        Result := 'False'
    else if (TVarData(v).VType = varString) or (TVarData(v).VType = varOleStr) then
      Result := '''' + v + ''''
    else if v = Null then
      Result := 'Null';
  end
  else
    Result := 'not accessible';
end;

procedure TfrxWatchForm.UpdateWatches;
var
  i: Integer;
begin
  WatchLB.Items.BeginUpdate;
  WatchLB.Items.Clear;
  for i := 0 to Watches.Count - 1 do
    WatchLB.Items.Add(Watches[i] + ': ' + CalcWatch(Watches[i]));
  WatchLB.Items.EndUpdate;
end;

procedure TfrxWatchForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
end;

end.


//0f31356a91fea3356e5f76cdce90aa7b