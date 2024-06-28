
{******************************************}
{                                          }
{             FastReport v4.0              }
{            Designer options              }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxEditOptions;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, frxCtrls
{$IFDEF Delphi6}
, Variants
{$ENDIF};
  

type
  TfrxOptionsEditor = class(TForm)
    OkB: TButton;
    CancelB: TButton;
    ColorDialog: TColorDialog;
    RestoreDefaultsB: TButton;
    Label1: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    CMRB: TRadioButton;
    InchesRB: TRadioButton;
    PixelsRB: TRadioButton;
    CME: TEdit;
    InchesE: TEdit;
    PixelsE: TEdit;
    DialogFormE: TEdit;
    ShowGridCB: TCheckBox;
    AlignGridCB: TCheckBox;
    Label6: TGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    CodeWindowFontCB: TComboBox;
    CodeWindowSizeCB: TComboBox;
    MemoEditorFontCB: TComboBox;
    MemoEditorSizeCB: TComboBox;
    ObjectFontCB: TCheckBox;
    Label11: TGroupBox;
    WorkspacePB: TPaintBox;
    ToolPB: TPaintBox;
    WorkspaceB: TButton;
    ToolB: TButton;
    LCDCB: TCheckBox;
    Label5: TGroupBox;
    Label12: TLabel;
    Label17: TLabel;
    EditAfterInsCB: TCheckBox;
    FreeBandsCB: TCheckBox;
    GapE: TEdit;
    BandsCaptionsCB: TCheckBox;
    DropFieldsCB: TCheckBox;
    StartupCB: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure WorkspacePBPaint(Sender: TObject);
    procedure ToolPBPaint(Sender: TObject);
    procedure WorkspaceBClick(Sender: TObject);
    procedure ToolBClick(Sender: TObject);
    procedure RestoreDefaultsBClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FWColor: TColor;
    FTColor: TColor;
  public
    { Public declarations }
  end;


implementation

{$R *.DFM}

uses frxDesgn, frxDesgnWorkspace, frxUtils, frxRes;


{ TfrxPreferencesEditor }

procedure TfrxOptionsEditor.FormShow(Sender: TObject);

  procedure SetEnabled(cAr: Array of TControl; Enabled: Boolean);
  var
    i: Integer;
  begin
    for i := 0 to High(cAr) do
      cAr[i].Enabled := Enabled;
  end;

begin
  ColorDialog.CustomColors.Add('ColorA=' + IntToHex(ColorToRGB(clBtnFace), 6));

  with TfrxDesignerForm(Owner) do
  begin
    CodeWindowFontCB.Items.Assign(Screen.Fonts);
    MemoEditorFontCB.Items.Assign(Screen.Fonts);

    SetEnabled([CMRB, InchesRB, PixelsRB, CME, InchesE, PixelsE],
      (Workspace.GridType <> gtDialog) and (Workspace.GridType <> gtChar));

    CMRB.Checked := Units = duCM;
    InchesRB.Checked := Units = duInches;
    PixelsRB.Checked := Units = duPixels;

    CME.Text := FloatToStr(GridSize1);
    InchesE.Text := FloatToStr(GridSize2);
    PixelsE.Text := FloatToStr(GridSize3);
    DialogFormE.Text := FloatToStr(GridSize4);

    ShowGridCB.Checked := ShowGrid;
    AlignGridCB.Checked := GridAlign;
    EditAfterInsCB.Checked := EditAfterInsert;
    BandsCaptionsCB.Checked := Workspace.ShowBandCaptions;
    DropFieldsCB.Checked := DropFields;
    StartupCB.Checked := ShowStartup;
    StartupCB.Visible := ConnectionsMI.Visible;
    FreeBandsCB.Checked := Workspace.FreeBandsPlacement;
    GapE.Text := IntToStr(Workspace.GapBetweenBands);

    CodeWindowFontCB.Text := CodeWindow.Font.Name;
    CodeWindowSizeCB.Text := IntToStr(CodeWindow.Font.Size);
    MemoEditorFontCB.Text := MemoFontName;
    MemoEditorSizeCB.Text := IntToStr(MemoFontSize);
    ObjectFontCB.Checked := UseObjectFont;

    FWColor := WorkspaceColor;
    FTColor := ToolsColor;
    LCDCB.Checked := Workspace.GridLCD;
  end;
end;

procedure TfrxOptionsEditor.FormHide(Sender: TObject);
begin
  if ModalResult = mrOk then
    with TfrxDesignerForm(Owner) do
    begin
      GridSize4 := frxStrToFloat(DialogFormE.Text);

      if CMRB.Enabled then
      begin
        GridSize1 := frxStrToFloat(CME.Text);
        GridSize2 := frxStrToFloat(InchesE.Text);
        GridSize3 := frxStrToFloat(PixelsE.Text);

        if CMRB.Checked then
          Units := duCM
        else if InchesRB.Checked then
          Units := duInches else
          Units := duPixels;
      end;

      ShowGrid := ShowGridCB.Checked;
      GridAlign := AlignGridCB.Checked;
      EditAfterInsert := EditAfterInsCB.Checked;
      Workspace.ShowBandCaptions := BandsCaptionsCB.Checked;
      DropFields := DropFieldsCB.Checked;
      ShowStartup := StartupCB.Checked;
      Workspace.FreeBandsPlacement := FreeBandsCB.Checked;
      Workspace.GapBetweenBands := StrToInt(GapE.Text);

      CodeWindow.Font.Name := CodeWindowFontCB.Text;
      CodeWindow.Font.Size := StrToInt(CodeWindowSizeCB.Text);
      MemoFontName := MemoEditorFontCB.Text;
      MemoFontSize := StrToInt(MemoEditorSizeCB.Text);
      UseObjectFont := ObjectFontCB.Checked;

      WorkspaceColor := FWColor;
      ToolsColor := FTColor;
      Workspace.GridLCD := LCDCB.Checked;
    end;
end;

procedure TfrxOptionsEditor.WorkspacePBPaint(Sender: TObject);
begin
  with WorkspacePB.Canvas do
  begin
    Pen.Color := clGray;
    Brush.Color := FWColor;
    Rectangle(0, 0, 161, 21);
  end;
end;

procedure TfrxOptionsEditor.ToolPBPaint(Sender: TObject);
begin
  with ToolPB.Canvas do
  begin
    Pen.Color := clGray;
    Brush.Color := FTColor;
    Rectangle(0, 0, 161, 21);
  end;
end;

procedure TfrxOptionsEditor.WorkspaceBClick(Sender: TObject);
begin
  ColorDialog.Color := FWColor;
  if ColorDialog.Execute then
    FWColor := ColorDialog.Color;
  WorkspacePB.Repaint;
end;

procedure TfrxOptionsEditor.ToolBClick(Sender: TObject);
begin
  ColorDialog.Color := FTColor;
  if ColorDialog.Execute then
    FTColor := ColorDialog.Color;
  ToolPB.Repaint;
end;

procedure TfrxOptionsEditor.RestoreDefaultsBClick(Sender: TObject);
begin
  TfrxDesignerForm(Owner).RestoreState(True);
  ModalResult := mrOk;
end;

procedure TfrxOptionsEditor.FormCreate(Sender: TObject);
begin
  Caption := frxGet(3000);
  Label1.Caption := frxGet(3001);
  Label2.Caption := frxGet(3002);
  Label3.Caption := frxGet(3003);
  Label4.Caption := frxGet(3004);
  Label5.Caption := frxGet(3005);
  Label6.Caption := frxGet(3006);
  Label7.Caption := frxGet(3007);
  Label8.Caption := frxGet(3008);
  Label9.Caption := frxGet(3009);
  Label10.Caption := frxGet(3010);
  Label11.Caption := frxGet(3011);
  Label12.Caption := frxGet(3012);
  Label13.Caption := frxGet(3013);
  Label14.Caption := frxGet(3014);
  Label15.Caption := frxGet(3015);
  Label16.Caption := frxGet(3016);
  Label17.Caption := frxGet(3017);
  OkB.Caption := frxGet(1);
  CancelB.Caption := frxGet(2);
  CMRB.Caption := frxGet(3018);
  InchesRB.Caption := frxGet(3019);
  PixelsRB.Caption := frxGet(3020);
  ShowGridCB.Caption := frxGet(3021);
  AlignGridCB.Caption := frxGet(3022);
  EditAfterInsCB.Caption := frxGet(3023);
  ObjectFontCB.Caption := frxGet(3024);
  WorkspaceB.Caption := frxGet(3025);
  ToolB.Caption := frxGet(3026);
  LCDCB.Caption := frxGet(3027);
  FreeBandsCB.Caption := frxGet(3028);
  DropFieldsCB.Caption := frxGet(3029);
  StartupCB.Caption := frxGet(3030);
  RestoreDefaultsB.Caption := frxGet(3031);
  BandsCaptionsCB.Caption := frxGet(3032);
end;

procedure TfrxOptionsEditor.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

end.


//0f31356a91fea3356e5f76cdce90aa7b