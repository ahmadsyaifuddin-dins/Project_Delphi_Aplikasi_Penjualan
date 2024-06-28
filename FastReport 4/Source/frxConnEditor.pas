
{******************************************}
{                                          }
{             FastReport v4.0              }
{          Connection list editor          }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxConnEditor;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, Buttons, ExtCtrls, frxClass;

type
  TfrxConnEditorForm = class(TForm)
    NewB: TButton;
    DeleteB: TButton;
    ConnLV: TListView;
    OKB: TButton;
    Panel: TPanel;
    ExpressionB: TSpeedButton;
    CancelB: TButton;
    NameE: TEdit;
    ConnE: TEdit;
    procedure ConnLVSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure NewBClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DeleteBClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure ExpressionBClick(Sender: TObject);
    procedure OKBClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    Report: TfrxReport;
  end;


implementation

{$R *.DFM}

uses frxDesgn, frxRes, IniFiles, Registry;


procedure TfrxConnEditorForm.FormShow(Sender: TObject);
var
  i: Integer;
  ini: TRegistry;
  sl: TStringList;
  li: TListItem;
begin
  Caption := frxGet(5800);
  NewB.Caption := frxGet(5801);
  DeleteB.Caption := frxGet(5802);
  OKB.Caption := frxGet(1);
  CancelB.Caption := frxGet(2);
  ConnLV.Columns[0].Caption := frxResources.Get('cpName');
  ConnLV.Columns[1].Caption := frxResources.Get('cpConnStr');

  NameE.Height := 19;
  ConnE.Height := 19;
  Panel.Visible := False;

  ini := TRegistry.Create;
  try
    ini.RootKey := HKEY_LOCAL_MACHINE;
    sl := TStringList.Create;
    try
      if ini.OpenKey(DEF_REG_CONNECTIONS, false) then
      begin
        ini.GetValueNames(sl);
        for i := 0 to sl.Count - 1 do
        begin
          li := ConnLV.Items.Add;
          li.Caption := sl[i];
          li.SubItems.Add(Ini.ReadString(sl[i]));
        end;
      end;
    finally
      sl.Free;
    end;
  finally
    ini.Free;
  end;
end;

procedure TfrxConnEditorForm.FormHide(Sender: TObject);
var
  i: Integer;
  ini: TRegistry;
  li: TListItem;
begin
  if ModalResult <> mrOk then Exit;
  ini := TRegistry.Create;
  try
    ini.RootKey := HKEY_LOCAL_MACHINE;
    ini.DeleteKey(DEF_REG_CONNECTIONS);
    if ini.OpenKey(DEF_REG_CONNECTIONS, true) then
      for i := 0 to ConnLV.Items.Count - 1 do
      begin
        li := ConnLV.Items[i];
        ini.WriteString(li.Caption, li.SubItems[0]);
      end;
  finally
    ini.Free;
  end;
end;

procedure TfrxConnEditorForm.NewBClick(Sender: TObject);
var
  li: TListItem;
begin
  li := ConnLV.Items.Add;
  li.Caption := 'New name';
  li.SubItems.Add('');
  ConnLV.Selected := li;
  NameE.SetFocus;
end;

procedure TfrxConnEditorForm.DeleteBClick(Sender: TObject);
begin
  ConnLV.Selected.Free;
end;

procedure TfrxConnEditorForm.ConnLVSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  if Selected then
  begin
    Panel.Visible := True;
    Panel.Top := ConnLV.Top + Item.Top;
    NameE.Text := Item.Caption;
    ConnE.Text := Item.SubItems[0];
  end
  else
  begin
    Panel.Visible := False;
    Item.Caption := NameE.Text;
    Item.SubItems[0] := ConnE.Text;
  end;
end;

procedure TfrxConnEditorForm.ExpressionBClick(Sender: TObject);
begin
  if Assigned(Report) and Assigned(Report.OnEditConnection) then
    ConnE.Text := Report.OnEditConnection(ConnE.Text);
end;

procedure TfrxConnEditorForm.OKBClick(Sender: TObject);
begin
  ConnLV.Selected := nil;
end;

procedure TfrxConnEditorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

end.


//0f31356a91fea3356e5f76cdce90aa7b