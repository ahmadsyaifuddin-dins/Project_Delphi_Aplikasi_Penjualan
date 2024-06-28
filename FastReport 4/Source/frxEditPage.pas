
{******************************************}
{                                          }
{             FastReport v4.0              }
{              Page options                }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxEditPage;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, frxCtrls, Buttons
{$IFDEF Delphi6}
, Variants
{$ENDIF};
  

type
  TfrxPageEditorForm = class(TForm)
    OKB: TButton;
    CancelB: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet3: TTabSheet;
    Label11: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    UnitL1: TLabel;
    UnitL2: TLabel;
    WidthE: TEdit;
    HeightE: TEdit;
    SizeCB: TComboBox;
    Label14: TGroupBox;
    Label12: TGroupBox;
    PortraitImg: TImage;
    LandscapeImg: TImage;
    PortraitRB: TRadioButton;
    LandscapeRB: TRadioButton;
    Label13: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    UnitL3: TLabel;
    UnitL4: TLabel;
    UnitL5: TLabel;
    UnitL6: TLabel;
    MarginLeftE: TEdit;
    MarginTopE: TEdit;
    MarginRightE: TEdit;
    MarginBottomE: TEdit;
    Label9: TLabel;
    Label10: TLabel;
    Tray1CB: TComboBox;
    Tray2CB: TComboBox;
    Label7: TGroupBox;
    Label8: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    UnitL7: TLabel;
    ColumnsNumberE: TEdit;
    ColumnWidthE: TEdit;
    ColumnPositionsM: TMemo;
    UpDown1: TUpDown;
    Label17: TGroupBox;
    Label18: TLabel;
    PrintOnPrevCB: TCheckBox;
    MirrorMarginsCB: TCheckBox;
    LargeHeightCB: TCheckBox;
    DuplexCB: TComboBox;
    EndlessWidthCB: TCheckBox;
    EndlessHeightCB: TCheckBox;
    procedure PortraitRBClick(Sender: TObject);
    procedure SizeCBClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure WidthEChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure UpDown1Click(Sender: TObject; Button: TUDBtnType);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FUpdating: Boolean;
  public
    { Public declarations }
  end;


implementation

{$R *.DFM}

uses Printers, frxPrinter, frxClass, frxUtils, frxDesgn, frxRes;


procedure TfrxPageEditorForm.FormShow(Sender: TObject);
var
  i: Integer;
  p: TfrxReportPage;
begin
  FUpdating := True;

  with frxPrinters.Printer, TfrxDesignerForm(Owner) do
  begin
    p := TfrxReportPage(Page);

    SizeCB.Items := Papers;
    i := PaperIndex(p.PaperSize);
    if i = -1 then
      i := PaperIndex(256);
    SizeCB.ItemIndex := i;

    WidthE.Text := frxFloatToStr(mmToUnits(p.PaperWidth));
    HeightE.Text := frxFloatToStr(mmToUnits(p.PaperHeight, False));
    PortraitRB.Checked := p.Orientation = poPortrait;
    LandscapeRB.Checked := p.Orientation = poLandscape;

    MarginLeftE.Text := frxFloatToStr(mmToUnits(p.LeftMargin));
    MarginRightE.Text := frxFloatToStr(mmToUnits(p.RightMargin));
    MarginTopE.Text := frxFloatToStr(mmToUnits(p.TopMargin, False));
    MarginBottomE.Text := frxFloatToStr(mmToUnits(p.BottomMargin, False));

    Tray1CB.Items := Bins;
    Tray2CB.Items := Tray1CB.Items;
    i := BinIndex(p.Bin);
    if i = -1 then
      i := BinIndex(DMBIN_AUTO);
    Tray1CB.ItemIndex := i;
    i := BinIndex(p.BinOtherPages);
    if i = -1 then
      i := BinIndex(DMBIN_AUTO);
    Tray2CB.ItemIndex := i;

    UpDown1.Position := p.Columns;
    ColumnWidthE.Text := frxFloatToStr(mmToUnits(p.ColumnWidth));
    for i := 0 to p.ColumnPositions.Count - 1 do
      ColumnPositionsM.Lines.Add(frxFloatToStr(mmToUnits(frxStrToFloat(p.ColumnPositions[i]))));
    PrintOnPrevCB.Checked := p.PrintOnPreviousPage;
    MirrorMarginsCB.Checked := p.MirrorMargins;
    EndlessHeightCB.Checked := p.EndlessHeight;
    EndlessWidthCB.Checked := p.EndlessWidth;
    LargeHeightCB.Checked := p.LargeDesignHeight;
    DuplexCB.ItemIndex := Integer(p.Duplex);
  end;

  PortraitRBClick(nil);
  FUpdating := False;
end;

procedure TfrxPageEditorForm.FormHide(Sender: TObject);
var
  p: TfrxReportPage;
  i: Integer;
  c: TfrxReportComponent;

  procedure ChangePage(p: TfrxReportPage);
  var
    i: Integer;
  begin
    with frxPrinters.Printer, TfrxDesignerForm(Owner) do
    begin
      if PortraitRB.Checked then
        p.Orientation := poPortrait else
        p.Orientation := poLandscape;

      p.SetSizeAndDimensions(PaperNameToNumber(SizeCB.Text),
        UnitsTomm(frxStrToFloat(WidthE.Text)),
        UnitsTomm(frxStrToFloat(HeightE.Text), False));

      p.LeftMargin := UnitsTomm(frxStrToFloat(MarginLeftE.Text));
      p.RightMargin := UnitsTomm(frxStrToFloat(MarginRightE.Text));
      p.TopMargin := UnitsTomm(frxStrToFloat(MarginTopE.Text), False);
      p.BottomMargin := UnitsTomm(frxStrToFloat(MarginBottomE.Text), False);

      p.Bin := BinNameToNumber(Tray1CB.Text);
      p.BinOtherPages := BinNameToNumber(Tray2CB.Text);

      p.Columns := UpDown1.Position;
      p.ColumnWidth := UnitsTomm(frxStrToFloat(ColumnWidthE.Text));
      p.ColumnPositions.Clear;
      for i := 0 to ColumnPositionsM.Lines.Count - 1 do
        p.ColumnPositions.Add(frxFloatToStr(UnitsTomm(frxStrToFloat(ColumnPositionsM.Lines[i]))));
      p.PrintOnPreviousPage := PrintOnPrevCB.Checked;
      p.MirrorMargins := MirrorMarginsCB.Checked;
      p.EndlessWidth := EndlessWidthCB.Checked;
      p.EndlessHeight := EndlessHeightCB.Checked;
      p.LargeDesignHeight := LargeHeightCB.Checked;
      p.Duplex := TfrxDuplexMode(DuplexCB.ItemIndex);
    end;
  end;

begin
  if ModalResult = mrOk then
  begin
    p := TfrxReportPage(TfrxDesignerForm(Owner).Page);
    ChangePage(p);

    { change all subreport pages }
    for i := 0 to p.AllObjects.Count - 1 do
    begin
      c := p.AllObjects[i];
      if c is TfrxSubReport then
        ChangePage(TfrxSubReport(c).Page);
    end;
  end;
end;

procedure TfrxPageEditorForm.PortraitRBClick(Sender: TObject);
begin
  PortraitImg.Visible := PortraitRB.Checked;
  LandscapeImg.Visible := LandscapeRB.Checked;
  SizeCBClick(nil);
end;

procedure TfrxPageEditorForm.SizeCBClick(Sender: TObject);
var
  pOr: TPrinterOrientation;
  pNumber: Integer;
  pWidth, pHeight: Extended;
begin
  if FUpdating then Exit;
  FUpdating := True;

  with frxPrinters.Printer, TfrxDesignerForm(Owner) do
  begin
    pNumber := PaperNameToNumber(SizeCB.Text);
    pWidth := UnitsTomm(frxStrToFloat(WidthE.Text));
    pHeight := UnitsTomm(frxStrToFloat(HeightE.Text), False);
    if PortraitRB.Checked then
      pOr := poPortrait else
      pOr := poLandscape;

    if pNumber = 256 then
      SetViewParams(pNumber, pHeight, pWidth, pOr) else
      SetViewParams(pNumber, pWidth, pHeight, pOr);

    WidthE.Text := frxFloatToStr(mmToUnits(PaperWidth));
    HeightE.Text := frxFloatToStr(mmToUnits(PaperHeight, False));
  end;

  FUpdating := False;
end;

procedure TfrxPageEditorForm.UpDown1Click(Sender: TObject; Button: TUDBtnType);
var
  n: Integer;
  w: Extended;
begin
  if FUpdating then Exit;

  n := UpDown1.Position;
  if n = 0 then
    n := 1;

  with TfrxDesignerForm(Owner) do
  begin
    w := (UnitsTomm(frxStrToFloat(WidthE.Text)) -
         UnitsTomm(frxStrToFloat(MarginLeftE.Text)) -
         UnitsTomm(frxStrToFloat(MarginRightE.Text))) / n;
    ColumnWidthE.Text := frxFloatToStr(mmToUnits(w));

    with ColumnPositionsM.Lines do
    begin
      Clear;
      while Count < n do
        Add(frxFloatToStr(mmToUnits(Count * w)));
    end;
  end;
end;

procedure TfrxPageEditorForm.WidthEChange(Sender: TObject);
begin
  if not FUpdating then
    SizeCB.ItemIndex := 0;
end;

procedure TfrxPageEditorForm.FormCreate(Sender: TObject);
var
  uStr: String;
begin
  Caption := frxGet(2700);
  OKB.Caption := frxGet(1);
  CancelB.Caption := frxGet(2);
  TabSheet1.Caption := frxGet(2701);
  Label1.Caption := frxGet(2702);
  Label2.Caption := frxGet(2703);
  Label11.Caption := frxGet(2704);
  Label12.Caption := frxGet(2705);
  Label3.Caption := frxGet(2706);
  Label4.Caption := frxGet(2707);
  Label5.Caption := frxGet(2708);
  Label6.Caption := frxGet(2709);
  Label13.Caption := frxGet(2710);
  Label14.Caption := frxGet(2711);
  Label9.Caption := frxGet(2712);
  Label10.Caption := frxGet(2713);
  PortraitRB.Caption := frxGet(2714);
  LandscapeRB.Caption := frxGet(2715);
  TabSheet3.Caption := frxGet(2716);
  Label7.Caption := frxGet(2717);
  Label8.Caption := frxGet(2718);
  Label15.Caption := frxGet(2719);
  Label16.Caption := frxGet(2720);
  Label17.Caption := frxGet(2721);
  Label18.Caption := frxGet(2722);
  PrintOnPrevCB.Caption := frxGet(2723);
  MirrorMarginsCB.Caption := frxGet(2724);
  LargeHeightCB.Caption := frxGet(2725);
  EndlessWidthCB.Caption := frxGet(2726);
  EndlessHeightCB.Caption := frxGet(2727);
  DuplexCB.Items.Clear;
  DuplexCB.Items.Add(frxResources.Get('dupDefault'));
  DuplexCB.Items.Add(frxResources.Get('dupVert'));
  DuplexCB.Items.Add(frxResources.Get('dupHorz'));
  DuplexCB.Items.Add(frxResources.Get('dupSimpl'));

  uStr := '';
  case TfrxDesignerForm(Owner).Units of
    duCM: uStr := frxResources.Get('uCm');
    duInches: uStr := frxResources.Get('uInch');
    duPixels: uStr := frxResources.Get('uPix');
    duChars: uStr := frxResources.Get('uChar');
  end;

  UnitL1.Caption := uStr;
  UnitL2.Caption := uStr;
  UnitL3.Caption := uStr;
  UnitL4.Caption := uStr;
  UnitL5.Caption := uStr;
  UnitL6.Caption := uStr;
  UnitL7.Caption := uStr;
end;

procedure TfrxPageEditorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

end.



//0f31356a91fea3356e5f76cdce90aa7b