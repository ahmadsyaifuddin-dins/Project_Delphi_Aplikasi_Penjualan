
{******************************************}
{                                          }
{             FastReport v4.0              }
{              SysMemo editor              }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxEditSysMemo;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, frxClass, frxCtrls
{$IFDEF Delphi6}
, Variants
{$ENDIF};
  

type
  TfrxSysMemoEditorForm = class(TForm)
    OKB: TButton;
    CancelB: TButton;
    AggregateRB: TRadioButton;
    SysVariableRB: TRadioButton;
    TextRB: TRadioButton;
    AggregatePanel: TGroupBox;
    DataBandL: TLabel;
    DataSetL: TLabel;
    DataFieldL: TLabel;
    FunctionL: TLabel;
    ExpressionL: TLabel;
    DataFieldCB: TComboBox;
    DataSetCB: TComboBox;
    DataBandCB: TComboBox;
    CountInvisibleCB: TCheckBox;
    FunctionCB: TComboBox;
    ExpressionE: TfrxComboEdit;
    RunningTotalCB: TCheckBox;
    GroupBox1: TGroupBox;
    SysVariableCB: TComboBox;
    GroupBox2: TGroupBox;
    TextE: TEdit;
    SampleL: TLabel;
    procedure ExpressionEButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure DataSetCBChange(Sender: TObject);
    procedure DataBandCBChange(Sender: TObject);
    procedure DataFieldCBChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FunctionCBChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FAggregateOnly: Boolean;
    FReport: TfrxReport;
    FText: String;
    procedure FillDataBandCB;
    procedure FillDataFieldCB;
    procedure FillDataSetCB;
    function CreateAggregate: String;
    procedure UpdateSample;
  public
    property AggregateOnly: Boolean read FAggregateOnly write FAggregateOnly;
    property Text: String read FText write FText;
  end;


implementation

{$R *.DFM}

uses frxUtils, frxRes;


procedure TfrxSysMemoEditorForm.FormShow(Sender: TObject);
var
  s: String;

  procedure HideControls(ar: array of TControl);
  var
    i: Integer;
  begin
    for i := 0 to High(ar) do
      ar[i].Hide;
  end;

begin
  FReport := TfrxCustomDesigner(Owner).Report;
  FillDataBandCB;
  FillDataSetCB;

  s := FText;
  if s <> '' then
    SetLength(s, Length(s) - 2);  { cut #13#10 }

  if FAggregateOnly then
  begin
    Caption := frxResources.Get('agAggregate');
    AggregateRB.Checked := True;
    HideControls([SysVariableRB, AggregateRB, TextRB, SysVariableCB, TextE,
      GroupBox1, GroupBox2]);
    AggregatePanel.Top := 4;
    OkB.Top := AggregatePanel.Height + 18;
    CancelB.Top := OkB.Top;
    ClientHeight := CancelB.Top + 33;
  end
  else if (SysVariableCB.Items.IndexOf(s) <> -1) or (s = '') then
  begin
    SysVariableRB.Checked := True;
    SysVariableCB.Text := s;
  end
  else
  begin
    TextRB.Checked := True;
    TextE.Text := s;
    TextE.SetFocus;
  end;
  UpdateSample;
end;

procedure TfrxSysMemoEditorForm.FormHide(Sender: TObject);
begin
  if ModalResult = mrOk then
  begin
    if SysVariableRB.Checked then
      FText := SysVariableCB.Text
    else if AggregateRB.Checked then
      FText := '[' + CreateAggregate + ']'
    else
      FText := TextE.Text
  end;
end;

function TfrxSysMemoEditorForm.CreateAggregate: String;
var
  s: String;
  i: Integer;
begin
  s := FunctionCB.Text;
  i := 0;
  if CountInvisibleCB.Checked then
    i := i or 1;
  if RunningTotalCB.Checked then
    i := i or 2;

  if s <> 'COUNT' then
  begin
    s := s + '(';
    if ExpressionE.Text <> '' then
      s := s + ExpressionE.Text else
      s := s + '<' + DataSetCB.Text + '."' + DataFieldCB.Text + '">';

    if DataBandCB.Text <> '' then
    begin
      s := s + ',' + DataBandCB.Text;
      if i <> 0 then
        s := s + ',' + IntToStr(i);
    end;
    s := s + ')';
  end
  else
  begin
    s := s + '(';
    s := s + DataBandCB.Text;
    if i <> 0 then
      s := s + ',' + IntToStr(i);
    s := s + ')';
  end;

  Result := s;
end;

procedure TfrxSysMemoEditorForm.FillDataBandCB;
var
  i: Integer;
  c: TfrxComponent;
begin
  DataBandCB.Items.Clear;
  for i := 0 to FReport.Designer.Objects.Count - 1 do
  begin
    c := FReport.Designer.Objects[i];
    if c is TfrxDataBand then
      DataBandCB.Items.Add(c.Name);
  end;
end;

procedure TfrxSysMemoEditorForm.FillDataSetCB;
begin
  FReport.GetDataSetList(DataSetCB.Items);
end;

procedure TfrxSysMemoEditorForm.FillDataFieldCB;
var
  ds: TfrxDataSet;
begin
  ds := FReport.GetDataSet(DataSetCB.Text);
  if ds <> nil then
    ds.GetFieldList(DataFieldCB.Items) else
    DataFieldCB.Items.Clear;
end;

procedure TfrxSysMemoEditorForm.DataBandCBChange(Sender: TObject);
var
  b: TfrxDataBand;
begin
  b := FReport.Designer.Page.FindObject(DataBandCB.Text) as TfrxDataBand;
  if (b <> nil) and (b.DataSet <> nil) and not (b.DataSet is TfrxUserDataSet) then
  begin
    DataSetCB.Text := FReport.GetAlias(b.DataSet);
    DataSetCBChange(nil);
  end;
end;

procedure TfrxSysMemoEditorForm.DataSetCBChange(Sender: TObject);
begin
  FillDataFieldCB;
  ExpressionE.Text := '';
  UpdateSample;
end;

procedure TfrxSysMemoEditorForm.DataFieldCBChange(Sender: TObject);
begin
  ExpressionE.Text := '';
  UpdateSample;
end;

procedure TfrxSysMemoEditorForm.ExpressionEButtonClick(Sender: TObject);
var
  s: String;
begin
  s := TfrxCustomDesigner(Owner).InsertExpression(ExpressionE.Text);
  if s <> '' then
    ExpressionE.Text := s;
  UpdateSample;
end;

procedure TfrxSysMemoEditorForm.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  Caption := frxGet(3300);
  DataBandL.Caption := frxGet(3301);
  DataSetL.Caption := frxGet(3302);
  DataFieldL.Caption := frxGet(3303);
  FunctionL.Caption := frxGet(3304);
  ExpressionL.Caption := frxGet(3305);
  OKB.Caption := frxGet(1);
  CancelB.Caption := frxGet(2);
  AggregateRB.Caption := frxGet(3306);
  SysVariableRB.Caption := frxGet(3307);
  CountInvisibleCB.Caption := frxGet(3308);
  TextRB.Caption := frxGet(3309);
  RunningTotalCB.Caption := frxGet(3310);
  for i := 1 to 6 do
    SysVariableCB.Items.Add(frxResources.Get('vt' + IntToStr(i)));
end;

procedure TfrxSysMemoEditorForm.UpdateSample;
begin
  if AggregateRB.Checked then
    SampleL.Caption := CreateAggregate
  else
    SampleL.Caption := '';
end;

procedure TfrxSysMemoEditorForm.FunctionCBChange(Sender: TObject);
begin
  UpdateSample;
end;

procedure TfrxSysMemoEditorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

end.



//0f31356a91fea3356e5f76cdce90aa7b