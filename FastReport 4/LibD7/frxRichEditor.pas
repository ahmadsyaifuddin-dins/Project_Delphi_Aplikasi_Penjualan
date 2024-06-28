
{******************************************}
{                                          }
{             FastReport v4.0              }
{         RichEdit design editor           }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxRichEditor;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, ExtCtrls, Buttons, frxClass, frxRich, frxCustomEditors,
  frxCtrls, frxRichEdit, ImgList, frxDock, ToolWin, ComCtrls
{$IFDEF Delphi6}
, Variants
{$ENDIF};
  

type
  TfrxRichEditor = class(TfrxViewEditor)
  public
    function Edit: Boolean; override;
    function HasEditor: Boolean; override;
    procedure GetMenuItems; override;
    function Execute(Tag: Integer; Checked: Boolean): Boolean; override;
  end;

  TfrxRichEditorForm = class(TForm)
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    SpeedBar: TToolBar;
    Ruler: TPanel;
    FontDialog1: TFontDialog;
    FirstInd: TLabel;
    LeftInd: TLabel;
    RulerLine: TBevel;
    RightInd: TLabel;
    BoldB: TToolButton;
    ItalicB: TToolButton;
    LeftAlignB: TToolButton;
    CenterAlignB: TToolButton;
    RightAlignB: TToolButton;
    UnderlineB: TToolButton;
    BulletsB: TToolButton;
    TTB: TToolButton;
    CancelB: TToolButton;
    OkB: TToolButton;
    ExprB: TToolButton;
    FontNameCB: TfrxFontComboBox;
    FontSizeCB: TfrxComboBox;
    OpenB: TToolButton;
    SaveB: TToolButton;
    UndoB: TToolButton;
    Sep1: TToolButton;
    Sep2: TToolButton;
    Sep3: TfrxTBPanel;
    Sep4: TToolButton;
    Sep5: TToolButton;
    BlockAlignB: TToolButton;

    procedure SelectionChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FileOpen(Sender: TObject);
    procedure FileSaveAs(Sender: TObject);
    procedure EditUndo(Sender: TObject);
    procedure SelectFont(Sender: TObject);
    procedure RulerResize(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure BoldBClick(Sender: TObject);
    procedure AlignButtonClick(Sender: TObject);
    procedure FontNameCBChange(Sender: TObject);
    procedure BulletsBClick(Sender: TObject);
    procedure RulerItemMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RulerItemMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FirstIndMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LeftIndMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RightIndMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CancelBClick(Sender: TObject);
    procedure OkBClick(Sender: TObject);
    procedure ExprBClick(Sender: TObject);
    procedure FontSizeCBChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FDragging: Boolean;
    FDragOfs: Integer;
    FRichView: TfrxRichView;
    FUpdating: Boolean;
    RichEdit1: TrxRichEdit;
    function CurrText: TrxTextAttributes;
    procedure SetupRuler;
    procedure SetEditRect;
  public
    { Public declarations }
    property RichView: TfrxRichView read FRichView write FRichView;
  end;


implementation

{$R *.DFM}

uses frxDsgnIntf, frxRes;


const
  RulerAdj = 4/3;
  GutterWid = 6;


{ TfrxRichEditor }

function TfrxRichEditor.HasEditor: Boolean;
begin
  Result := True;
end;

function TfrxRichEditor.Edit: Boolean;
begin
  with TfrxRichEditorForm.Create(Designer) do
  begin
    RichView := TfrxRichView(Component);
    Result := ShowModal = mrOk;
    Free;
  end;
end;

function TfrxRichEditor.Execute(Tag: Integer; Checked: Boolean): Boolean;
var
  i: Integer;
  c: TfrxComponent;
  v: TfrxRichView;
begin
  Result := inherited Execute(Tag, Checked);

  for i := 0 to Designer.SelectedObjects.Count - 1 do
  begin
    c := Designer.SelectedObjects[i];
    if (c is TfrxRichView) and not (rfDontModify in c.Restrictions) then
    begin
      v := TfrxRichView(c);
      case Tag of
        1: v.AllowExpressions := Checked;
        2: if Checked then
             v.StretchMode := smActualHeight else
             v.StretchMode := smDontStretch;
        3: if Checked then
             v.StretchMode := smMaxHeight else
             v.StretchMode := smDontStretch;
      end;

      Result := True;
    end;
  end;
end;

procedure TfrxRichEditor.GetMenuItems;
var
  v: TfrxRichView;
begin
  v := TfrxRichView(Component);

  AddItem(frxResources.Get('mvExpr'), 1, v.AllowExpressions);
  AddItem('-', -1);
  AddItem(frxResources.Get('mvStretch'), 2, v.StretchMode = smActualHeight);
  AddItem(frxResources.Get('mvStretchToMax'), 3, v.StretchMode = smMaxHeight);

  inherited;
end;


{ TfrxRichEditorForm }

procedure TfrxRichEditorForm.SelectionChange(Sender: TObject);
begin
  with RichEdit1.Paragraph do
  try
    FUpdating := True;
    FirstInd.Left := Trunc(FirstIndent * RulerAdj) - 4 + GutterWid;
    LeftInd.Left := Trunc((LeftIndent + FirstIndent) * RulerAdj) - 4 + GutterWid;
    RightInd.Left := Ruler.ClientWidth - 6 - Trunc((RightIndent + GutterWid) * RulerAdj);
    BoldB.Down := fsBold in RichEdit1.SelAttributes.Style;
    ItalicB.Down := fsItalic in RichEdit1.SelAttributes.Style;
    UnderlineB.Down := fsUnderline in RichEdit1.SelAttributes.Style;
    BulletsB.Down := Boolean(Numbering);
    FontSizeCB.Text := IntToStr(RichEdit1.SelAttributes.Size);
    FontNameCB.Text := RichEdit1.SelAttributes.Name;
    case Alignment of
      paLeftJustify: LeftAlignB.Down := True;
      paCenter: CenterAlignB.Down := True;
      paRightJustify: RightAlignB.Down := True;
      paJustify: BlockAlignB.Down := True;
    end;
  finally
    FUpdating := False;
  end;
end;

function TfrxRichEditorForm.CurrText: TrxTextAttributes;
begin
  if RichEdit1.SelLength > 0 then
    Result := RichEdit1.SelAttributes else
    Result := RichEdit1.DefAttributes;
end;

procedure TfrxRichEditorForm.SetupRuler;
var
  I: Integer;
  S: String;
begin
  SetLength(S, 201);
  I := 1;
  while I < 200 do
  begin
    S[I] := #9;
    S[I+1] := '|';
    Inc(I, 2);
  end;
  Ruler.Caption := S;
end;

procedure TfrxRichEditorForm.SetEditRect;
var
  R: TRect;
begin
  with RichEdit1 do
  begin
    R := Rect(GutterWid, 0, ClientWidth - GutterWid, ClientHeight);
    SendMessage(Handle, EM_SETRECT, 0, Longint(@R));
  end;
end;

{ Event Handlers }

procedure TfrxRichEditorForm.FormResize(Sender: TObject);
begin
  SetEditRect;
  SelectionChange(Sender);
end;

procedure TfrxRichEditorForm.FormPaint(Sender: TObject);
begin
  SetEditRect;
end;

procedure TfrxRichEditorForm.FileOpen(Sender: TObject);
begin
  OpenDialog.Filter := frxResources.Get('ftRichFile') + ' (*.rtf)|*.rtf';
  if OpenDialog.Execute then
  begin
    RichEdit1.Lines.LoadFromFile(OpenDialog.FileName);
    RichEdit1.SetFocus;
    SelectionChange(Self);
  end;
end;

procedure TfrxRichEditorForm.FileSaveAs(Sender: TObject);
begin
  SaveDialog.Filter := frxResources.Get('ftRichFile') + ' (*.rtf)|*.rtf|' +
                       frxResources.Get('ftTextFile') + ' (*.txt)|*.txt';
  if SaveDialog.Execute then
    RichEdit1.Lines.SaveToFile(ChangeFileExt(SaveDialog.FileName, '.rtf'));
end;

procedure TfrxRichEditorForm.EditUndo(Sender: TObject);
begin
  with RichEdit1 do
    if HandleAllocated then SendMessage(Handle, EM_UNDO, 0, 0);
end;

procedure TfrxRichEditorForm.SelectFont(Sender: TObject);
begin
  FontDialog1.Font.Assign(RichEdit1.SelAttributes);
  if FontDialog1.Execute then
    CurrText.Assign(FontDialog1.Font);
  RichEdit1.SetFocus;
end;

procedure TfrxRichEditorForm.RulerResize(Sender: TObject);
begin
  RulerLine.Width := Ruler.ClientWidth - RulerLine.Left * 2;
end;

procedure TfrxRichEditorForm.BoldBClick(Sender: TObject);
var
  s: TFontStyles;
begin
  if FUpdating then Exit;
  s := [];
  if BoldB.Down then s := s + [fsBold];
  if ItalicB.Down then s := s + [fsItalic];
  if UnderlineB.Down then s := s + [fsUnderline];
  CurrText.Style := s;
end;

procedure TfrxRichEditorForm.AlignButtonClick(Sender: TObject);
begin
  if FUpdating then Exit;
  case TControl(Sender).Tag of
    0: RichEdit1.Paragraph.Alignment := paLeftJustify;
    1: RichEdit1.Paragraph.Alignment := paCenter;
    2: RichEdit1.Paragraph.Alignment := paRightJustify;
    3: RichEdit1.Paragraph.Alignment := paJustify;
  end;
end;

procedure TfrxRichEditorForm.FontNameCBChange(Sender: TObject);
begin
  if FUpdating then Exit;
  CurrText.Name := FontNameCB.Text;
  RichEdit1.SetFocus;
end;

procedure TfrxRichEditorForm.BulletsBClick(Sender: TObject);
begin
  if FUpdating then Exit;
  RichEdit1.Paragraph.Numbering := TrxNumbering(BulletsB.Down);
end;

{ Ruler Indent Dragging }

procedure TfrxRichEditorForm.RulerItemMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FDragOfs := (TLabel(Sender).Width div 2);
  TLabel(Sender).Left := TLabel(Sender).Left + X - FDragOfs;
  FDragging := True;
end;

procedure TfrxRichEditorForm.RulerItemMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if FDragging then
    TLabel(Sender).Left :=  TLabel(Sender).Left + X - FDragOfs
end;

procedure TfrxRichEditorForm.FirstIndMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FDragging := False;
  RichEdit1.Paragraph.FirstIndent :=
    Trunc((FirstInd.Left + FDragOfs - GutterWid) / RulerAdj);
  LeftIndMouseUp(Sender, Button, Shift, X, Y);
end;

procedure TfrxRichEditorForm.LeftIndMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FDragging := False;
  RichEdit1.Paragraph.LeftIndent :=
    Trunc((LeftInd.Left + FDragOfs - GutterWid) / RulerAdj) - RichEdit1.Paragraph.FirstIndent;
  SelectionChange(Sender);
end;

procedure TfrxRichEditorForm.RightIndMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FDragging := False;
  RichEdit1.Paragraph.RightIndent :=
    Trunc((Ruler.ClientWidth - RightInd.Left + FDragOfs - 2) / RulerAdj) - 2 * GutterWid;
  SelectionChange(Sender);
end;

procedure TfrxRichEditorForm.CancelBClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrxRichEditorForm.OkBClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrxRichEditorForm.ExprBClick(Sender: TObject);
var
  s, s1, s2: String;

  function BracketCount: Integer;
  var
    i: Integer;
  begin
    Result := 0;
    for i := 1 to Length(s) do
      if s[i] = '<' then
        Inc(Result);
  end;

begin
  s := TfrxCustomDesigner(Owner).InsertExpression('');
  if s <> '' then
  begin
    s1 := RichView.ExpressionDelimiters;
    s2 := Copy(s1, Pos(',', s1) + 1, 255);
    s1 := Copy(s1, 1, Pos(',', s1) - 1);
    if (s[1] = '<') and (s[Length(s)] = '>') and (BracketCount = 1) then
      s := Copy(s, 2, Length(s) - 2);
    RichEdit1.SelText := s1 + s + s2;
  end;
end;

procedure TfrxRichEditorForm.FontSizeCBChange(Sender: TObject);
begin
  CurrText.Size := StrToInt(FontSizeCB.Text);
  RichEdit1.SetFocus;
end;

procedure TfrxRichEditorForm.FormCreate(Sender: TObject);
begin
  Caption := frxGet(4200);
  OpenB.Hint := frxGet(4201);
  SaveB.Hint := frxGet(4202);
  UndoB.Hint := frxGet(4203);
  TTB.Hint := frxGet(4204);
  ExprB.Hint := frxGet(4205);
  CancelB.Hint := frxGet(2);
  OkB.Hint := frxGet(1);
  BoldB.Hint := frxGet(4206);
  ItalicB.Hint := frxGet(4207);
  UnderlineB.Hint := frxGet(4208);
  LeftAlignB.Hint := frxGet(4209);
  CenterAlignB.Hint := frxGet(4210);
  RightAlignB.Hint := frxGet(4211);
  BlockAlignB.Hint := frxGet(4212);
  BulletsB.Hint := frxGet(4213);

  RichEdit1 := TrxRichEdit.Create(Self);
  RichEdit1.Parent := Self;
  RichEdit1.Align := alClient;
  RichEdit1.OnSelectionChange := SelectionChange;

  SpeedBar.Images := frxResources.MainButtonImages;
  Icon := TForm(Owner).Icon;
  OpenDialog.InitialDir := ExtractFilePath(ParamStr(0));
  SaveDialog.InitialDir := OpenDialog.InitialDir;
  SetupRuler;
  SelectionChange(Self);
end;

procedure TfrxRichEditorForm.FormShow(Sender: TObject);
begin
  frxAssignRich(RichView.RichEdit, RichEdit1);
  RichEdit1.SetFocus;
end;

procedure TfrxRichEditorForm.FormHide(Sender: TObject);
begin
  if ModalResult = mrOk then
    frxAssignRich(RichEdit1, RichView.RichEdit);
end;


procedure TfrxRichEditorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

initialization
  frxComponentEditors.Register(TfrxRichView, TfrxRichEditor);


end.


//0f31356a91fea3356e5f76cdce90aa7b