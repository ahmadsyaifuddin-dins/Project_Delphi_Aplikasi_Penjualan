
{******************************************}
{                                          }
{             FastReport v4.0              }
{              Group editor                }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxEditGroup;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, frxClass, frxCtrls
{$IFDEF Delphi6}
, Variants
{$ENDIF};
  

type
  TfrxGroupEditorForm = class(TForm)
    OKB: TButton;
    CancelB: TButton;
    BreakOnL: TGroupBox;
    DataFieldCB: TComboBox;
    DataSetCB: TComboBox;
    ExpressionE: TfrxComboEdit;
    DataFieldRB: TRadioButton;
    ExpressionRB: TRadioButton;
    OptionsL: TGroupBox;
    KeepGroupTogetherCB: TCheckBox;
    StartNewPageCB: TCheckBox;
    OutlineCB: TCheckBox;
    DrillCB: TCheckBox;
    ResetCB: TCheckBox;
    procedure ExpressionEButtonClick(Sender: TObject);
    procedure DataFieldRBClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure DataSetCBChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FGroupHeader: TfrxGroupHeader;
    FReport: TfrxReport;
    procedure FillDataFieldCB;
    procedure FillDataSetCB;
  public
    property GroupHeader: TfrxGroupHeader read FGroupHeader write FGroupHeader;
  end;


implementation

{$R *.DFM}

uses frxUtils, frxRes;


procedure TfrxGroupEditorForm.FormShow(Sender: TObject);
var
  ds: TfrxDataSet;
  fld: String;
begin
  FReport := FGroupHeader.Report;
  FillDataSetCB;

  FReport.GetDataSetAndField(FGroupHeader.Condition, ds, fld);
  if FGroupHeader.Condition = '' then
  begin
    DataSetCB.ItemIndex := 0;
    FillDataFieldCB;
    DataFieldCB.SetFocus;
  end
  else if (ds <> nil) and (fld <> '') then
  begin
    DataSetCB.Text := FReport.GetAlias(ds);
    FillDataFieldCB;
    DataFieldCB.Text := fld;
    DataFieldCB.SetFocus;
  end
  else
  begin
    ExpressionE.Text := FGroupHeader.Condition;
    ExpressionRB.Checked := True;
    ExpressionE.SetFocus;
  end;

  KeepGroupTogetherCB.Checked := FGroupHeader.KeepTogether;
  StartNewPageCB.Checked := FGroupHeader.StartNewPage;
  OutlineCB.Checked := Trim(FGroupHeader.OutlineText) <> '';
  DrillCB.Checked := FGroupHeader.DrillDown;
  ResetCB.Checked := FGroupHeader.ResetPageNumbers;
end;

procedure TfrxGroupEditorForm.FormHide(Sender: TObject);
begin
  if ModalResult = mrOk then
  begin
    if DataFieldRB.Checked then
      FGroupHeader.Condition := DataSetCB.Text + '."' + DataFieldCB.Text + '"' else
      FGroupHeader.Condition := ExpressionE.Text;

    FGroupHeader.KeepTogether := KeepGroupTogetherCB.Checked;
    FGroupHeader.StartNewPage := StartNewPageCB.Checked;
    if OutlineCB.Checked then
      FGroupHeader.OutlineText := FGroupHeader.Condition else
      FGroupHeader.OutlineText := '';
    FGroupHeader.DrillDown := DrillCB.Checked;
    FGroupHeader.ResetPageNumbers := ResetCB.Checked;
  end;
end;

procedure TfrxGroupEditorForm.FillDataSetCB;
begin
  FReport.GetDataSetList(DataSetCB.Items);
end;

procedure TfrxGroupEditorForm.FillDataFieldCB;
var
  ds: TfrxDataSet;
begin
  ds := FReport.GetDataSet(DataSetCB.Text);
  if ds <> nil then
    ds.GetFieldList(DataFieldCB.Items) else
    DataFieldCB.Items.Clear;
end;

procedure TfrxGroupEditorForm.ExpressionEButtonClick(Sender: TObject);
var
  s: String;
begin
  s := TfrxCustomDesigner(Owner).InsertExpression(ExpressionE.Text);
  if s <> '' then
    ExpressionE.Text := s;
end;

procedure TfrxGroupEditorForm.DataFieldRBClick(Sender: TObject);
begin
  DataSetCB.Enabled := DataFieldRB.Checked;
  DataFieldCB.Enabled := DataFieldRB.Checked;
  ExpressionE.Enabled := ExpressionRB.Checked;
end;

procedure TfrxGroupEditorForm.DataSetCBChange(Sender: TObject);
begin
  FillDataFieldCB;
end;

procedure TfrxGroupEditorForm.FormCreate(Sender: TObject);
begin
  Caption := frxGet(3200);
  BreakOnL.Caption := frxGet(3201);
  OptionsL.Caption := frxGet(3202);
  OKB.Caption := frxGet(1);
  CancelB.Caption := frxGet(2);
  DataFieldRB.Caption := frxGet(3203);
  ExpressionRB.Caption := frxGet(3204);
  KeepGroupTogetherCB.Caption := frxGet(3205);
  StartNewPageCB.Caption := frxGet(3206);
  OutlineCB.Caption := frxGet(3207);
  DrillCB.Caption := frxResources.Get('bvDrillDown');
  ResetCB.Caption := frxResources.Get('bvResetPageNo');
end;

procedure TfrxGroupEditorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

end.



//0f31356a91fea3356e5f76cdce90aa7b