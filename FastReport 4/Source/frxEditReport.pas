
{******************************************}
{                                          }
{             FastReport v4.0              }
{             Report options               }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxEditReport;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, frxCtrls, ComCtrls
{$IFDEF Delphi6}
, Variants
{$ENDIF};
  

type
  TfrxReportEditorForm = class(TForm)
    OkB: TButton;
    CancelB: TButton;
    PageControl: TPageControl;
    GeneralTS: TTabSheet;
    DescriptionTS: TTabSheet;
    ReportSettingsL: TGroupBox;
    PrintersLB: TListBox;
    CopiesL: TLabel;
    CopiesE: TEdit;
    CollateCB: TCheckBox;
    GeneralL: TGroupBox;
    PasswordL: TLabel;
    DoublePassCB: TCheckBox;
    PrintIfEmptyCB: TCheckBox;
    PasswordE: TEdit;
    DescriptionL: TGroupBox;
    Bevel3: TBevel;
    NameL: TLabel;
    PictureImg: TImage;
    Description1L: TLabel;
    PictureL: TLabel;
    AuthorL: TLabel;
    NameE: TEdit;
    DescriptionE: TMemo;
    PictureB: TButton;
    AuthorE: TEdit;
    VersionL: TGroupBox;
    MajorL: TLabel;
    MinorL: TLabel;
    ReleaseL: TLabel;
    BuildL: TLabel;
    CreatedL: TLabel;
    Created1L: TLabel;
    ModifiedL: TLabel;
    Modified1L: TLabel;
    MajorE: TEdit;
    MinorE: TEdit;
    ReleaseE: TEdit;
    BuildE: TEdit;
    InheritTS: TTabSheet;
    InheritGB: TGroupBox;
    InheritStateL: TLabel;
    DetachRB: TRadioButton;
    SelectL: TLabel;
    InheritRB: TRadioButton;
    DontChangeRB: TRadioButton;
    InheritLV: TListView;
    procedure FormCreate(Sender: TObject);
    procedure PictureBClick(Sender: TObject);
    procedure PrintersLBDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FTemplates: TStringList;
  public
    { Public declarations }
  end;


implementation

{$R *.DFM}

uses
  frxDesgn, frxEditPicture, frxPrinter, frxUtils, frxRes, frxClass;


procedure TfrxReportEditorForm.FormCreate(Sender: TObject);
begin
  Caption := frxGet(4700);
  OkB.Caption := frxGet(1);
  CancelB.Caption := frxGet(2);
  GeneralTS.Caption := frxGet(4701);
  ReportSettingsL.Caption := frxGet(4702);
  CopiesL.Caption := frxGet(4703);
  GeneralL.Caption := frxGet(4704);
  PasswordL.Caption := frxGet(4705);
  CollateCB.Caption := frxGet(4706);
  DoublePassCB.Caption := frxGet(4707);
  PrintIfEmptyCB.Caption := frxGet(4708);
  DescriptionTS.Caption := frxGet(4709);
  NameL.Caption := frxGet(4710);
  Description1L.Caption := frxGet(4711);
  PictureL.Caption := frxGet(4712);
  AuthorL.Caption := frxGet(4713);
  MajorL.Caption := frxGet(4714);
  MinorL.Caption := frxGet(4715);
  ReleaseL.Caption := frxGet(4716);
  BuildL.Caption := frxGet(4717);
  CreatedL.Caption := frxGet(4718);
  ModifiedL.Caption := frxGet(4719);
  DescriptionL.Caption := frxGet(4720);
  VersionL.Caption := frxGet(4721);
  PictureB.Caption := frxGet(4722);
  InheritTS.Caption := frxGet(4728);
  InheritGB.Caption := frxGet(4723);
  SelectL.Caption := frxGet(4724);
  DontChangeRB.Caption := frxGet(4725);
  DetachRB.Caption := frxGet(4726);
  InheritRB.Caption := frxGet(4727);

  if Screen.PixelsPerInch > 96 then
    PrintersLB.ItemHeight := 19;
  InheritLV.LargeImages := frxResources.WizardImages;

  FTemplates := TStringList.Create;
  FTemplates.Sorted := True;
end;

procedure TfrxReportEditorForm.FormDestroy(Sender: TObject);
begin
  FTemplates.Free;
end;

procedure TfrxReportEditorForm.FormShow(Sender: TObject);
var
  i: Integer;
  lvItem: TListItem;
begin
  with TfrxDesignerForm(Owner).Report do
  begin
    PrintersLB.Items := frxPrinters.Printers;
    PrintersLB.Items.Insert(0, frxResources.Get('prDefault'));
    PrintersLB.ItemIndex := PrintersLB.Items.IndexOf(PrintOptions.Printer);
    CollateCB.Checked := PrintOptions.Collate;
    CopiesE.Text := IntToStr(PrintOptions.Copies);
    DoublePassCB.Checked := EngineOptions.DoublePass;
    PrintIfEmptyCB.Checked := EngineOptions.PrintIfEmpty;
    PasswordE.Text := ReportOptions.Password;

    if Trim(ParentReport) = '' then
    begin
      InheritStateL.Caption := frxResources.Get('riNotInherited');
      DetachRB.Enabled := False;
    end
    else
      InheritStateL.Caption := Format(frxResources.Get('riInherited'), [ParentReport]);

    if frxDesignerComp <> nil then
    begin
      frxDesignerComp.GetTemplateList(FTemplates);
      for i := 0 to FTemplates.Count - 1 do
      begin
        lvItem := InheritLV.Items.Add;
        lvItem.Caption := ExtractFileName(FTemplates[i]);
        lvItem.Data := Pointer(i);
        lvItem.ImageIndex := 5;
      end;
    end;

    NameE.Text := ReportOptions.Name;
    AuthorE.Text := ReportOptions.Author;
    DescriptionE.Lines.Text := ReportOptions.Description.Text;
    PictureImg.Picture.Assign(ReportOptions.Picture);
    PictureImg.Stretch := (PictureImg.Picture.Width > PictureImg.Width) or
      (PictureImg.Picture.Height > PictureImg.Height);

    MajorE.Text := ReportOptions.VersionMajor;
    MinorE.Text := ReportOptions.VersionMinor;
    ReleaseE.Text := ReportOptions.VersionRelease;
    BuildE.Text := ReportOptions.VersionBuild;
    Created1L.Caption := DateTimeToStr(ReportOptions.CreateDate);
    Modified1L.Caption := DateTimeToStr(ReportOptions.LastChange);
  end;
end;

procedure TfrxReportEditorForm.FormHide(Sender: TObject);
var
  templ: String;
begin
  if ModalResult = mrOk then
    with TfrxDesignerForm(Owner).Report do
    begin
      if PrintersLB.ItemIndex <> -1 then
      begin
        PrintOptions.Printer := PrintersLB.Items[PrintersLB.ItemIndex];
        SelectPrinter;
      end;
      PrintOptions.Collate := CollateCB.Checked;
      PrintOptions.Copies := StrToInt(CopiesE.Text);
      EngineOptions.DoublePass := DoublePassCB.Checked;
      EngineOptions.PrintIfEmpty := PrintIfEmptyCB.Checked;
      ReportOptions.Password := PasswordE.Text;

      if not DontChangeRB.Checked then
      begin
        Designer.Lock;
        try
          if DetachRB.Checked then
            ParentReport := ''
          else if InheritRB.Checked and (InheritLV.Selected <> nil) then
          begin
            ParentReport := '';
            templ := FTemplates[Integer(InheritLV.Selected.Data)];
            InheritFromTemplate(templ);
          end;
        finally
          Designer.ReloadReport;
        end;
      end;

      ReportOptions.Name := NameE.Text;
      ReportOptions.Author := AuthorE.Text;
      ReportOptions.Description.Text := DescriptionE.Lines.Text;
      ReportOptions.Picture.Assign(PictureImg.Picture);
      ReportOptions.VersionMajor := MajorE.Text;
      ReportOptions.VersionMinor := MinorE.Text;
      ReportOptions.VersionRelease := ReleaseE.Text;
      ReportOptions.VersionBuild := BuildE.Text;
    end;
end;

procedure TfrxReportEditorForm.PictureBClick(Sender: TObject);
begin
  with TfrxPictureEditorForm.Create(Owner) do
  begin
    Image.Picture.Assign(PictureImg.Picture);
    if ShowModal = mrOk then
    begin
      PictureImg.Picture.Assign(Image.Picture);
      PictureImg.Stretch := (PictureImg.Picture.Width > PictureImg.Width) or
        (PictureImg.Picture.Height > PictureImg.Height);
    end;
    Free;
  end;
end;

procedure TfrxReportEditorForm.PrintersLBDrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  s: String;
begin
  with PrintersLB.Canvas do
  begin
    FillRect(ARect);
    frxResources.PreviewButtonImages.Draw(PrintersLB.Canvas, ARect.Left + 2, ARect.Top, 2);
    s := PrintersLB.Items[Index];
    if (Index <> 0) and (frxPrinters[Index - 1].Port <> '') then
      s := s + ' ' + frxResources.Get('rePrnOnPort') + ' ' + frxPrinters[Index - 1].Port;
    TextOut(ARect.Left + 24, ARect.Top + 1, s);
  end;
end;

procedure TfrxReportEditorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

end.


//0f31356a91fea3356e5f76cdce90aa7b