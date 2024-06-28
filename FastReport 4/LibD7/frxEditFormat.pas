
{******************************************}
{                                          }
{             FastReport v4.0              }
{           DisplayFormat editor           }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxEditFormat;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, frxClass
{$IFDEF Delphi6}
, Variants
{$ENDIF};


type
  TfrxFormatEditorForm = class(TForm)
    OkB: TButton;
    CancelB: TButton;
    CategoryL: TGroupBox;
    CategoryLB: TListBox;
    FormatL: TGroupBox;
    FormatLB: TListBox;
    GroupBox1: TGroupBox;
    FormatStrL: TLabel;
    SeparatorL: TLabel;
    FormatE: TEdit;
    SeparatorE: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure CategoryLBClick(Sender: TObject);
    procedure FormatLBDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure FormatLBClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FFormat: TfrxFormat;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure HostControls(Host: TWinControl);
    procedure UnhostControls;
    property Format: TfrxFormat read FFormat write FFormat;
  end;


implementation

{$R *.DFM}

uses frxRes;

const
  CategoryNames: array[0..3] of String =
    ('fkText', 'fkNumber', 'fkDateTime', 'fkBoolean');


constructor TfrxFormatEditorForm.Create(AOwner: TComponent);
begin
  inherited;
  FFormat := TfrxFormat.Create;
end;

destructor TfrxFormatEditorForm.Destroy;
begin
  FFormat.Free;
  inherited;
end;

procedure TfrxFormatEditorForm.FormShow(Sender: TObject);

  procedure FillCategory;
  var
    i: Integer;
  begin
    for i := 0 to 3 do
      CategoryLB.Items.Add(frxResources.Get(CategoryNames[i]));
  end;

  procedure FindFormat;
  var
    i: Integer;
    s: String;
  begin
    for i := 0 to FormatLB.Items.Count - 1 do
    begin
      s := FormatLB.Items[i];
      if Copy(s, Pos(';', s) + 1, 255) = FFormat.FormatStr then
        FormatLB.ItemIndex := i;
    end;
  end;

begin
  FillCategory;
  CategoryLB.ItemIndex := Integer(FFormat.Kind);
  CategoryLBClick(Self);
  FindFormat;
  FormatE.Text := FFormat.FormatStr;
  SeparatorE.Text := FFormat.DecimalSeparator;
end;

procedure TfrxFormatEditorForm.FormHide(Sender: TObject);
var
  s: String;
begin
  FFormat.Kind := TfrxFormatKind(CategoryLB.ItemIndex);
  FFormat.FormatStr := FormatE.Text;
  s := SeparatorE.Text;
  if s = '' then
    s := DecimalSeparator;
  FFormat.DecimalSeparator := s[1];
end;

procedure TfrxFormatEditorForm.CategoryLBClick(Sender: TObject);
var
  i, n: Integer;
  s: String;
begin
  FormatLB.Items.Clear;
  n := CategoryLB.ItemIndex;
  SeparatorE.Enabled := n = 1;
  SeparatorL.Enabled := n = 1;

  if (n = 0) or (n = 4) or (n = -1) then
    Exit;

  for i := 1 to 10 do
  begin
    s := frxResources.Get(CategoryNames[n] + IntToStr(i));
    if Pos('fk', s) = 0 then
      FormatLB.Items.Add(s);
  end;
end;

procedure TfrxFormatEditorForm.FormatLBClick(Sender: TObject);
var
  s: String;
begin
  s := FormatLB.Items[FormatLB.ItemIndex];
  FormatE.Text := Copy(s, Pos(';', s) + 1, 255);
end;

procedure TfrxFormatEditorForm.FormatLBDrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  s: String;
begin
  with FormatLB do
  begin
    Canvas.FillRect(ARect);
    s := Items[Index];
    if Pos(';', s) <> 0 then
      s := Copy(s, 1, Pos(';', s) - 1);
    Canvas.TextOut(ARect.Left + 2, ARect.Top + 1, s);
  end;
end;

procedure TfrxFormatEditorForm.FormCreate(Sender: TObject);
begin
  Caption := frxGet(4500);
  CategoryL.Caption := frxGet(4501);
  FormatL.Caption := frxGet(4502);
  FormatStrL.Caption := frxGet(4503);
  SeparatorL.Caption := frxGet(4504);
  OkB.Caption := frxGet(1);
  CancelB.Caption := frxGet(2);
end;

procedure TfrxFormatEditorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

procedure TfrxFormatEditorForm.HostControls(Host: TWinControl);
begin
  CategoryL.Parent := Host;
  FormatL.Parent := Host;
  GroupBox1.Parent := Host;
  FormShow(Self);
end;

procedure TfrxFormatEditorForm.UnhostControls;
begin
  FormHide(Self);
end;

end.


//0f31356a91fea3356e5f76cdce90aa7b