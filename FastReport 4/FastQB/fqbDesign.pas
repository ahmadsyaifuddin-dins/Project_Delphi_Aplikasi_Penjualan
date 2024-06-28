{*******************************************}
{                                           }
{          FastQueryBuilder 1.03            }
{                                           }
{            Copyright (c) 2005             }
{             Fast Reports Inc.             }
{                                           }
{*******************************************}

{$I fqb.inc}

unit fqbDesign;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ToolWin, ComCtrls, StdCtrls, ExtCtrls, Grids, DBGrids,
  ImgList, Buttons, Menus, DB
{$IFDEF Delphi6}
  ,Variants
{$ENDIF}
  ,fqbSynmemo, fqbClass;

type

  TfqbDesigner = class(TForm)
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    fqbGrid1: TfqbGrid;
    fqbSyntaxMemo1: TfqbSyntaxMemo;
    fqbTableArea1: TfqbTableArea;
    fqbTableListBox1: TfqbTableListBox;
    ImageList2: TImageList;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    Panel1: TPanel;
    SaveDialog1: TSaveDialog;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    ToolBar1: TToolBar;
    ToolButton10: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure TabSheet2Show(Sender: TObject);
    procedure TabSheet3Hide(Sender: TObject);
    procedure TabSheet3Show(Sender: TObject);
    procedure ToolButton10Click(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure ToolButton4Click(Sender: TObject);
    procedure ToolButton6Click(Sender: TObject);
    procedure ToolButton7Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  protected
    procedure LoadPos;
    procedure SavePos;
  end;


var
  fqbDesigner: TfqbDesigner;

implementation

{$R *.dfm}

uses fqbUtils, fqbRes, Registry;

type
  THackWinControl = class(TWinControl);


{-----------------------  TfqbDesigner -----------------------}
procedure TfqbDesigner.FormCreate(Sender: TObject);
begin
  LoadPos;

  ToolButton7.Hint := fqbGet(1);
  ToolButton10.Hint := fqbGet(2);
  ToolButton6.Hint := fqbGet(1803);
  ToolButton3.Hint := fqbGet(1805);
  ToolButton4.Hint := fqbGet(1804);
  TabSheet1.Caption := fqbGet(1806);
  TabSheet2.Caption := fqbGet(1807);
  TabSheet3.Caption := fqbGet(1808);
  fqbGrid1.Column[0].Caption := fqbGet(1820);
  fqbGrid1.Column[1].Caption := fqbGet(1821);
  fqbGrid1.Column[2].Caption := fqbGet(1822);
  fqbGrid1.Column[3].Caption := fqbGet(1823);
  fqbGrid1.Column[4].Caption := fqbGet(1824);
  fqbGrid1.Column[5].Caption := fqbGet(1825);

  THackWinControl(fqbTableArea1).BevelKind := bkFlat;
  THackWinControl(fqbTableListBox1).BevelKind := bkFlat;
  THackWinControl(fqbGrid1).BevelKind := bkFlat;
  THackWinControl(fqbGrid1).BevelKind := bkFlat;
  THackWinControl(fqbSyntaxMemo1).BevelKind := bkFlat;
  THackWinControl(DBGrid1).BevelKind := bkFlat;

  PageControl1.ActivePage := PageControl1.Pages[0];
  DataSource1.DataSet := fqbCore.Engine.ResultDataSet;
  fqbTableListBox1.Items.BeginUpdate;
  fqbTableListBox1.Items.Clear;
  fqbCore.Engine.ReadTableList(fqbTableListBox1.Items);
  fqbTableListBox1.Items.EndUpdate;
end;

procedure TfqbDesigner.TabSheet2Show(Sender: TObject);
begin
  fqbSyntaxMemo1.Lines.BeginUpdate;
  fqbSyntaxMemo1.Lines.Clear;
  fqbSyntaxMemo1.Lines.Text := fqbCore.GenerateSQL;
  fqbSyntaxMemo1.Lines.EndUpdate
end;

procedure TfqbDesigner.TabSheet3Hide(Sender: TObject);
begin
  fqbCore.Engine.ResultDataSet.Close;
end;

procedure TfqbDesigner.TabSheet3Show(Sender: TObject);
begin
  fqbCore.Engine.ResultDataSet.Close;
  fqbCore.Engine.SetSQL(fqbCore.GenerateSQL);
  fqbCore.Engine.ResultDataSet.Open;
end;

procedure TfqbDesigner.ToolButton10Click(Sender: TObject);
begin
  ModalResult := mrCancel
end;

procedure TfqbDesigner.ToolButton3Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
    begin
      fqbCore.Clear;
      fqbCore.LoadFromFile(OpenDialog1.FileName);
    end;
end;

procedure TfqbDesigner.ToolButton4Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
    fqbCore.SaveToFile(SaveDialog1.FileName);
end;

procedure TfqbDesigner.ToolButton6Click(Sender: TObject);
begin
  fqbCore.Clear;
end;

procedure TfqbDesigner.ToolButton7Click(Sender: TObject);
begin
  ModalResult := mrOk
end;

procedure TfqbDesigner.FormDestroy(Sender: TObject);
begin
  SavePos;
end;

procedure TfqbDesigner.LoadPos;
var
  Reg: TRegIniFile;
  s: string;
begin
  s := ChangeFileExt(ExtractFileName(Application.ExeName), '');
  Reg := TRegIniFile.Create('\Software\Fast Reports\FQBuilder\' + s);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    Reg.OpenKey('\Software\Fast Reports\FQBuilder\' + s, True);
    Top := Reg.ReadInteger(Name, 'Top', Top);
    Left := Reg.ReadInteger(Name, 'Left', Left);
    Height := Reg.ReadInteger(Name, 'Height', Height);
    Width := Reg.ReadInteger(Name, 'Width', Width);
  finally
    Reg.Free;
  end
end;

procedure TfqbDesigner.SavePos;
var
  Reg: TRegIniFile;
  s: string;
begin
  s := ChangeFileExt(ExtractFileName(Application.ExeName), '');
  Reg := TRegIniFile.Create('\Software\Fast Reports\FQBuilder\' + s);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    Reg.OpenKey('\Software\Fast Reports\FQBuilder\' + s, True);
    Reg.WriteInteger(Name, 'Top', Top);
    Reg.WriteInteger(Name, 'Left', Left);
    Reg.WriteInteger(Name, 'Height', Height);
    Reg.WriteInteger(Name, 'Width', Width);
  finally
    Reg.Free;
  end
end;

end.

