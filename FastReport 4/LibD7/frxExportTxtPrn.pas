
{******************************************}
{                                          }
{             FastReport v4.0              }
{        Text advanced  export filter      }
{             Printing form                }
{                                          }
{         Copyright (c) 1998-2006          }
{          by Alexander Fediachov,         }
{             Fast Reports Inc.            }
{                                          }
{******************************************}

unit frxExportTxtPrn;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, CheckLst, frxExportTXT, Buttons
{$IFDEF Delphi6}, Variants {$ENDIF}, ComCtrls, Mask, frxRes, frxrcExports;

type
  TfrxPrnInit = class(TForm)
    OK: TButton;
    Cancel: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    GroupBox1: TGroupBox;
    Label4: TLabel;
    Image1: TImage;
    CB1: TComboBox;
    PropButton: TButton;
    GroupBox3: TGroupBox;
    Label2: TLabel;
    Panel2: TPanel;
    GroupBox2: TGroupBox;
    CheckListBox1: TCheckListBox;
    Label1: TLabel;
    ComboBox1: TComboBox;
    Button1: TSpeedButton;
    Button2: TSpeedButton;
    E1: TMaskEdit;
    UpDown1: TUpDown;
    procedure FormCreate(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure CheckListBox1ClickCheck(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure PropButtonClick(Sender: TObject);
    procedure CB1Click(Sender: TObject);
    procedure CB1DrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    exp: TfrxTXTExport;
    OldIndex: Integer;
    procedure Localize;
  public
    { Public declarations }
  end;

var
  frxPrnInit: TfrxPrnInit;

implementation

{$R *.dfm}

uses frxutils, Printers, frxprinter, frxclass;

procedure TfrxPrnInit.FormCreate(Sender: TObject);
var
  i: integer;
begin
  CB1.Items.Assign(Printer.Printers);
  CB1.ItemIndex := Printer.PrinterIndex;
  OldIndex := Printer.PrinterIndex;
  Localize;
  SendMessage(GetWindow(ComboBox1.Handle,GW_CHILD), EM_SETREADONLY, 1, 0);
  exp := TfrxTXTExport(Owner);
  ComboBox1.Items.Clear;
  CheckListBox1.Items.Clear;
  for i := 0 to exp.PrintersCount - 1 do
    ComboBox1.Items.Add(exp.PrinterTypes[i].name);
  ComboBox1.ItemIndex := exp.SelectedPrinterType;
  ComboBox1Change(Sender);
end;

procedure TfrxPrnInit.ComboBox1Change(Sender: TObject);
var
  j: integer;
begin
  CheckListBox1.Items.Clear;
  for j := 0 to exp.PrinterTypes[ComboBox1.ItemIndex].CommCount - 1 do
  begin
    CheckListBox1.Items.Add(exp.PrinterTypes[ComboBox1.ItemIndex].Commands[j].Name);
    CheckListBox1.Checked[j] := exp.PrinterTypes[ComboBox1.ItemIndex].Commands[j].Trigger;
  end;
  exp.SelectedPrinterType := ComboBox1.ItemIndex;
end;

procedure TfrxPrnInit.CheckListBox1ClickCheck(Sender: TObject);
begin
  exp.PrinterTypes[ComboBox1.ItemIndex].Commands[CheckListBox1.ItemIndex].Trigger :=
     CheckListBox1.Checked[CheckListBox1.ItemIndex];
end;

procedure TfrxPrnInit.Localize;
begin
  Caption := frxGet(8400);
  OK.Caption := frxGet(1);
  Cancel.Caption := frxGet(2);
  GroupBox1.Caption := frxGet(8401);
  Label4.Caption := frxGet(8402);
  PropButton.Caption := frxGet(8403);
  GroupBox3.Caption := frxGet(8404);
  Label2.Caption := frxGet(8405);
  GroupBox2.Caption := frxGet(8406);
  Label1.Caption := frxGet(8407);
  OpenDialog1.DefaultExt := frxGet(8408);
  OpenDialog1.Filter := frxGet(8409);
  SaveDialog1.DefaultExt := frxGet(8410);
  SaveDialog1.Filter := frxGet(8411);
end;

procedure TfrxPrnInit.Button1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    exp.LoadPrinterInit(OpenDialog1.FileName);
    ComboBox1.ItemIndex := exp.SelectedPrinterType;
    ComboBox1Change(Sender);
  end;
end;

procedure TfrxPrnInit.Button2Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
    exp.SavePrinterInit(SaveDialog1.FileName);
end;

procedure TfrxPrnInit.FormDeactivate(Sender: TObject);
begin
  if ModalResult <> mrOk then
    frxPrinters.PrinterIndex := OldIndex;
end;

procedure TfrxPrnInit.PropButtonClick(Sender: TObject);
begin
  frxPrinters.Printer.PropertiesDlg;
end;

procedure TfrxPrnInit.CB1Click(Sender: TObject);
begin
  frxPrinters.PrinterIndex := CB1.ItemIndex;
end;

procedure TfrxPrnInit.CB1DrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
var
  r: TRect;
begin
  r := ARect;
  r.Right := r.Left + 18;
  r.Bottom := r.Top + 16;
  OffsetRect(r, 2, 0);
  with CB1.Canvas do
  begin
    FillRect(ARect);
    BrushCopy(r, Image1.Picture.Bitmap, Rect(0, 0, 18, 16), clOlive);
    TextOut(ARect.Left + 24, ARect.Top + 1, CB1.Items[Index]);
  end;
end;

procedure TfrxPrnInit.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

end.
