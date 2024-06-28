
{******************************************}
{                                          }
{             FastReport v4.0              }
{            Expression Editor             }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxEditExpr;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, frxClass, ExtCtrls, ImgList, Buttons, frxDataTree
{$IFDEF Delphi6}
, Variants
{$ENDIF};
  

type
  TfrxExprEditorForm = class(TForm)
    ExprMemo: TMemo;
    Panel1: TPanel;
    OkB: TButton;
    CancelB: TButton;
    Splitter1: TSplitter;
    Panel2: TPanel;
    ExprL: TLabel;
    Panel: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure ExprMemoDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ExprMemoDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);
  private
    FDataTree: TfrxDataTreeForm;
    FReport: TfrxReport;
    procedure OnDataTreeDblClick(Sender: TObject);
  public
  end;


implementation

{$R *.DFM}

uses frxDock, IniFiles, frxRes;

var
  lastPosition: TPoint;

type
  THackWinControl = class(TWinControl);


{ TfrxExprEditorForm }

procedure TfrxExprEditorForm.FormCreate(Sender: TObject);
begin
  Caption := frxGet(4400);
  ExprL.Caption := frxGet(4401);
  OkB.Caption := frxGet(1);
  CancelB.Caption := frxGet(2);
  THackWinControl(ExprMemo).BevelKind := bkFlat;

  FReport := TfrxCustomDesigner(Owner).Report;
  FDataTree := TfrxDataTreeForm.Create(Self);
  FDataTree.Report := FReport;
  FDataTree.OnDblClick := OnDataTreeDblClick;
  FDataTree.SetControlsParent(Panel);
  FDataTree.HintPanel.Height := 60;
  FDataTree.UpdateItems;
end;

procedure TfrxExprEditorForm.FormShow(Sender: TObject);
var
  Ini: TCustomIniFile;
begin
  Ini := FReport.GetIniFile;
  Ini.WriteBool('Form4.TfrxExprEditorForm', 'Visible', True);
  frxRestoreFormPosition(Ini, Self);
  Ini.Free;
  FDataTree.SetLastPosition(lastPosition);
end;

procedure TfrxExprEditorForm.FormHide(Sender: TObject);
var
  Ini: TCustomIniFile;
begin
  Ini := FReport.GetIniFile;
  frxSaveFormPosition(Ini, Self);
  Ini.Free;
  lastPosition := FDataTree.GetLastPosition;
end;

procedure TfrxExprEditorForm.OnDataTreeDblClick(Sender: TObject);
begin
  ExprMemo.SelText := FDataTree.GetFieldName;
  ExprMemo.SetFocus;
end;

procedure TfrxExprEditorForm.ExprMemoDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := (Source is TTreeView) and (TControl(Source).Owner = FDataTree) and
    (FDataTree.GetFieldName <> '');
end;

procedure TfrxExprEditorForm.ExprMemoDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
  ExprMemo.SelText := FDataTree.GetFieldName;
  ExprMemo.SetFocus;
end;

procedure TfrxExprEditorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

procedure TfrxExprEditorForm.FormResize(Sender: TObject);
begin
  FDataTree.UpdateSize;
end;

end.


//0f31356a91fea3356e5f76cdce90aa7b