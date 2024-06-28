
{******************************************}
{                                          }
{             FastReport v4.0              }
{             Data Band editor             }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxEditDataBand;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, frxClass, ComCtrls
{$IFDEF Delphi6}
, Variants
{$ENDIF};


type
  TfrxDataBandEditorForm = class(TForm)
    OkB: TButton;
    CancelB: TButton;
    GroupBox1: TGroupBox;
    DatasetsLB: TListBox;
    RecordsL: TLabel;
    RecordsE: TEdit;
    RecordsUD: TUpDown;
    procedure DatasetsLBDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure DatasetsLBDblClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DatasetsLBClick(Sender: TObject);
  private
    { Private declarations }
    FDataBand: TfrxDataBand;
    FDesigner: TfrxCustomDesigner;
  public
    { Public declarations }
    property DataBand: TfrxDataBand read FDataBand write FDataBand;
  end;


implementation

{$R *.DFM}

uses frxUtils, frxRes;


procedure TfrxDataBandEditorForm.FormShow(Sender: TObject);
var
  i: Integer;
  dsList: TStringList;
begin
  FDesigner := TfrxCustomDesigner(Owner);

  dsList := TStringList.Create;
  FDesigner.Report.GetDatasetList(dsList);
  dsList.Sort;
  DatasetsLB.Items := dsList;
  DatasetsLB.Items.InsertObject(0, frxResources.Get('dbNotAssigned'), nil);
  dsList.Free;

  i := DatasetsLB.Items.IndexOfObject(FDataBand.DataSet);
  if i = -1 then
    i := 0;
  DatasetsLB.ItemIndex := i;

  RecordsUD.Position := FDataBand.RowCount;
end;

procedure TfrxDataBandEditorForm.FormHide(Sender: TObject);
begin
  if ModalResult = mrOk then
    if DatasetsLB.ItemIndex = 0 then
    begin
      FDataBand.DataSet := nil;
      FDataBand.RowCount := RecordsUD.Position;
    end
    else
    begin
      FDataBand.DataSet := TfrxDataSet(DatasetsLB.Items.Objects[DatasetsLB.ItemIndex]);
      FDataBand.RowCount := RecordsUD.Position;
    end;
end;

procedure TfrxDataBandEditorForm.DatasetsLBDrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  r: TRect;
begin
  r := ARect;
  r.Right := r.Left + 18;
  r.Bottom := r.Top + 16;
  OffsetRect(r, 2, 0);
  with TListBox(Control) do
  begin
    Canvas.FillRect(ARect);
    if Index > 0 then
      frxResources.MainButtonImages.Draw(Canvas, ARect.Left + 2, ARect.Top + 1, 53);
    Canvas.TextOut(ARect.Left + 22, ARect.Top + 2, Items[Index]);
  end;
end;

procedure TfrxDataBandEditorForm.DatasetsLBDblClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrxDataBandEditorForm.FormCreate(Sender: TObject);
begin
  Caption := frxGet(3100);
  RecordsL.Caption := frxGet(3101);
  OkB.Caption := frxGet(1);
  CancelB.Caption := frxGet(2);
end;

procedure TfrxDataBandEditorForm.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

procedure TfrxDataBandEditorForm.DatasetsLBClick(Sender: TObject);
begin
  if DatasetsLB.ItemIndex <> 0 then
    RecordsUD.Position := 0;
end;

end.



//0f31356a91fea3356e5f76cdce90aa7b