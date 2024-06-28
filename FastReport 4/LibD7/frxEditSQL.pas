
{******************************************}
{                                          }
{             FastReport v4.0              }
{               SQL editor                 }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxEditSQL;

interface

{$I frx.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls, ToolWin, frxSynMemo,
  frxCustomDB
{$IFDEF Delphi6}
, Variants
{$ENDIF}
{$IFDEF QBUILDER}
, fqbClass
{$ENDIF};


type
  TfrxSQLEditorForm = class(TForm)
    ToolBar: TToolBar;
    OkB: TToolButton;
    CancelB: TToolButton;
    QBB: TToolButton;
    ParamsB: TToolButton;
    ToolButton2: TToolButton;
    procedure OkBClick(Sender: TObject);
    procedure CancelBClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MemoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure QBBClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ParamsBClick(Sender: TObject);
  private
    { Private declarations }
    FMemo: TfrxSyntaxMemo;
    FQuery: TfrxCustomQuery;
{$IFDEF QBUILDER}
    FQBEngine: TfqbEngine;
{$ENDIF}
    FSaveSQL: TStrings;
    FSaveSchema: String;
    FSaveParams: TfrxParams;
  public
    { Public declarations }
    property Query: TfrxCustomQuery read FQuery write FQuery;
  end;


implementation

{$R *.DFM}

uses frxClass, frxRes, frxDock, IniFiles, frxEditQueryParams;


procedure TfrxSQLEditorForm.FormCreate(Sender: TObject);
begin

  FSaveSQL := TStringList.Create;
  FSaveParams := TfrxParams.Create;

  FMemo := TfrxSyntaxMemo.Create(Self);
  with FMemo do
  begin
    Parent := Self;
    Align := alClient;
    Syntax := 'SQL';
    ShowGutter := True;
    GutterWidth := 20;
    BevelKind := bkFlat;
    Color := clWindow;
    OnKeyDown := MemoKeyDown;
{$I frxEditSQL.inc}
  end;
  Toolbar.Images := frxResources.MainButtonImages;
{$IFDEF QBUILDER}
  QBB.Visible := True;
{$ENDIF}
  Caption := frxGet(4900);
  QBB.Hint := frxGet(4901);
  ParamsB.Hint := frxGet(5714);
  CancelB.Hint := frxGet(2);
  OkB.Hint := frxGet(1);
end;

procedure TfrxSQLEditorForm.FormDestroy(Sender: TObject);
begin
  FSaveSQL.Free;
  FSaveParams.Free;
end;

procedure TfrxSQLEditorForm.FormShow(Sender: TObject);
var
  Ini: TCustomIniFile;
begin
  FSaveSQL.Assign(Query.SQL);
  FSaveParams.Assign(Query.Params);
  FSaveSchema := Query.SQLSchema;
{$IFDEF QBUILDER}
  FQBEngine := Query.QBEngine;
{$ENDIF}
  FMemo.Lines.Assign(Query.SQL);

  Ini := TfrxCustomDesigner(Owner).Report.GetIniFile;
  Ini.WriteBool('Form4.TfrxSQLEditorForm', 'Visible', True);
  frxRestoreFormPosition(Ini, Self);
  Ini.Free;
end;

procedure TfrxSQLEditorForm.FormHide(Sender: TObject);
var
  Ini: TCustomIniFile;
begin
  if ModalResult = mrOk then
  begin
    Query.SQL.Assign(FMemo.Lines);
  end
  else
  begin
    Query.SQL.Assign(FSaveSQL);
    Query.Params.Assign(FSaveParams);
    Query.SQLSchema := FSaveSchema;
  end;

  Ini := TfrxCustomDesigner(Owner).Report.GetIniFile;
  frxSaveFormPosition(Ini, Self);
  Ini.Free;
{$IFDEF QBUILDER}
  if FQBEngine <> nil then
    FQBEngine.Free;
{$ENDIF}
end;

procedure TfrxSQLEditorForm.OkBClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrxSQLEditorForm.CancelBClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrxSQLEditorForm.MemoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = vk_Return) and (ssCtrl in Shift) then
    ModalResult := mrOk
  else if Key = vk_Escape then
    ModalResult := mrCancel
  else if Key = VK_F1 then
    frxResources.Help(Self);
end;

procedure TfrxSQLEditorForm.QBBClick(Sender: TObject);
{$IFDEF QBUILDER}
var
  fqbDialog: TfqbDialog;
{$ENDIF}
begin
{$IFDEF QBUILDER}
  fqbDialog := TfqbDialog.Create(nil);
  try
    fqbDialog.Engine := FQBEngine;
    fqbDialog.SchemaInsideSQL := False;
    fqbDialog.SQL := FMemo.Lines.Text;
    fqbDialog.SQLSchema := Query.SQLSchema;

    if fqbDialog.Execute then
    begin
      FMemo.Lines.Text := fqbDialog.SQL;
      Query.SQLSchema := fqbDialog.SQLSchema;
    end;
  finally
    fqbDialog.Free;
  end;
{$ENDIF}
end;

procedure TfrxSQLEditorForm.ParamsBClick(Sender: TObject);
begin
  Query.SQL.Assign(FMemo.Lines);
  if Query.Params.Count <> 0 then
    with TfrxParamsEditorForm.Create(Owner) do
    begin
      Params := Query.Params;
      if ShowModal = mrOk then
        Query.UpdateParams;
      Free;
    end;
end;

end.



//0f31356a91fea3356e5f76cdce90aa7b