
{******************************************}
{                                          }
{             FastReport v4.0              }
{         Report datasets selector         }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxEditReportData;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, frxClass, CheckLst
{$IFDEF Delphi6}
, Variants
{$ENDIF};


type
  TfrxReportDataForm = class(TForm)
    OKB: TButton;
    CancelB: TButton;
    DatasetsLB: TCheckListBox;
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DatasetsLBClickCheck(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FStandalone: Boolean;
    procedure BuildConnectionList;
    procedure BuildDatasetList;
  public
    Report: TfrxReport;
  end;


implementation

{$R *.DFM}

uses frxDesgn, frxUtils, frxRes, IniFiles, Registry;


procedure TfrxReportDataForm.FormCreate(Sender: TObject);
begin
  FStandalone := (frxDesignerComp <> nil) and frxDesignerComp.Standalone;
  if FStandalone then
    Caption := frxGet(5800)
  else
    Caption := frxGet(2800);
  OKB.Caption := frxGet(1);
  CancelB.Caption := frxGet(2);
end;

procedure TfrxReportDataForm.FormShow(Sender: TObject);
begin
  if FStandalone then
    BuildConnectionList
  else
    BuildDatasetList;
end;

procedure TfrxReportDataForm.FormHide(Sender: TObject);
var
  i: Integer;
begin
  if ModalResult <> mrOk then Exit;

  if FStandalone then
    Report.ReportOptions.ConnectionName := ''
  else
    Report.Datasets.Clear;

  for i := 0 to DatasetsLB.Items.Count - 1 do
    if DatasetsLB.Checked[i] then
      if FStandalone then
        Report.ReportOptions.ConnectionName := DatasetsLB.Items[i]
      else
        Report.DataSets.Add(TfrxDataSet(DatasetsLB.Items.Objects[i]));
end;

procedure TfrxReportDataForm.BuildConnectionList;
var
  i: Integer;
  ini: TRegistry;
  sl: TStringList;
begin
  ini := TRegistry.Create;
  try
    ini.RootKey := HKEY_LOCAL_MACHINE;
    sl := TStringList.Create;
    try
      if ini.OpenKey(DEF_REG_CONNECTIONS, false)  then
      begin
        ini.GetValueNames(sl);
        for i := 0 to sl.Count - 1 do
        begin
          DataSetsLB.Items.Add(sl[i]);
          DataSetsLB.Checked[i] := CompareText(sl[i], Report.ReportOptions.ConnectionName) = 0;
        end;
      end;
    finally
      sl.Free;
    end;
  finally
    ini.Free;
  end;
end;

procedure TfrxReportDataForm.BuildDatasetList;
var
  i: Integer;
  ds: TfrxDataSet;
  dsList: TStringList;
begin
  dsList := TStringList.Create;

  if Report.EnabledDataSets.Count > 0 then
  begin
    for i := 0 to Report.EnabledDataSets.Count - 1 do
    begin
      ds := Report.EnabledDataSets[i].DataSet;
      if ds <> nil then
        dsList.AddObject(ds.UserName, ds);
    end;
  end
  else
    frxGetDataSetList(dsList);

  dsList.Sort;

  for i := 0 to dsList.Count - 1 do
  begin
    ds := TfrxDataSet(dsList.Objects[i]);
    if (csDesigning in Report.ComponentState) and
      ((ds.Owner is TForm) or (ds.Owner is TDataModule)) then
      DataSetsLB.Items.AddObject(ds.UserName + '  (' + ds.Owner.Name + '.' + ds.Name + ')', ds)
    else
      DataSetsLB.Items.AddObject(ds.UserName, ds);
    if Report.Datasets.Find(ds) <> nil then
      DataSetsLB.Checked[DataSetsLB.Items.Count - 1] := True;
  end;

  dsList.Free;
end;

procedure TfrxReportDataForm.DatasetsLBClickCheck(Sender: TObject);
var
  i: Integer;
begin
  if FStandalone then
    for i := 0 to DatasetsLB.Items.Count - 1 do
      if i <> DatasetsLB.ItemIndex then
        DatasetsLB.Checked[i] := False;
end;

procedure TfrxReportDataForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

end.


//0f31356a91fea3356e5f76cdce90aa7b