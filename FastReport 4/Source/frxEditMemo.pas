
{******************************************}
{                                          }
{             FastReport v4.0              }
{               Memo editor                }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxEditMemo;

interface

{$I frx.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls, ToolWin, frxClass,
  frxEditFormat, frxEditHighlight
{$IFDEF Delphi6}
, Variants
{$ENDIF};
  

type
  TfrxMemoEditorForm = class(TForm)
    PageControl1: TPageControl;
    TextTS: TTabSheet;
    Panel1: TPanel;
    OkB: TButton;
    CancelB: TButton;
    FormatTS: TTabSheet;
    HighlightTS: TTabSheet;
    ToolBar: TToolBar;
    ExprB: TToolButton;
    AggregateB: TToolButton;
    LocalFormatB: TToolButton;
    WordWrapB: TToolButton;
    procedure FormShow(Sender: TObject);
    procedure WordWrapBClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure MemoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ExprBClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure AggregateBClick(Sender: TObject);
    procedure LocalFormatBClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FFormat: TfrxFormatEditorForm;
    FHighlight: TfrxHighlightEditorForm;
    FMemoView: TfrxCustomMemoView;
    FIsUnicode: Boolean;
    FText: WideString;
  public
    Memo: TMemo;
    property MemoView: TfrxCustomMemoView read FMemoView write FMemoView;
    property Text: WideString read FText write FText;
  end;


implementation

{$R *.DFM}

uses frxEditSysMemo, IniFiles, frxDock, frxRes, frxUnicodeCtrls;


{ TfrxMemoEditorForm }

procedure TfrxMemoEditorForm.FormShow(Sender: TObject);
var
  Ini: TCustomIniFile;
begin
  FIsUnicode := FMemoView.Font.Charset = DEFAULT_CHARSET;

  if FIsUnicode then
    Memo := TUnicodeMemo.Create(Self)
  else
    Memo := TMemo.Create(Self);

  with Memo do
  begin
    Parent := TextTS;
    Align := alClient;
    ScrollBars := ssBoth;
    TabOrder := 1;
    OnKeyDown := MemoKeyDown;
  end;

  FFormat := TfrxFormatEditorForm.Create(Owner);
  FFormat.Format.Assign(MemoView.DisplayFormat);
  FFormat.HostControls(FormatTS);

  FHighlight := TfrxHighlightEditorForm.Create(Owner);
  FHighlight.MemoView := MemoView;
  FHighlight.HostControls(HighlightTS);

  Icon := TForm(Owner).Icon;
  Toolbar.Images := frxResources.MainButtonImages;
  Ini := TfrxCustomDesigner(Owner).Report.GetIniFile;
  Ini.WriteBool('Form4.TfrxMemoEditorForm', 'Visible', True);
  WordWrapB.Down := Ini.ReadBool('Form4.TfrxMemoEditorForm', 'WordWrap', False);
  WordWrapBClick(nil);
  frxRestoreFormPosition(Ini, Self);
  Ini.Free;

  with TfrxCustomDesigner(Owner) do
  begin
    if UseObjectFont then
    begin
      Memo.Font := FMemoView.Font;
      Memo.Font.Color := clBlack;
      Memo.Font.Height := FMemoView.Font.Height;
    end
    else
    begin
      Memo.Font.Name := MemoFontName;
      Memo.Font.Size := MemoFontSize;
    end;
  end;

  if FIsUnicode then
    TUnicodeMemo(Memo).Text := FMemoView.Text
  else
    Memo.Text := FMemoView.Text;

  Memo.SetFocus;
  Memo.Perform(EM_SETSEL, 0, 0);
  Memo.Perform(EM_SCROLLCARET, 0, 0);
end;

procedure TfrxMemoEditorForm.FormHide(Sender: TObject);
var
  Ini: TCustomIniFile;
begin
  Ini := TfrxCustomDesigner(Owner).Report.GetIniFile;
  frxSaveFormPosition(Ini, Self);
  Ini.WriteBool('Form4.TfrxMemoEditorForm', 'WordWrap', Memo.WordWrap);
  Ini.Free;

  if FIsUnicode then
    FText := TUnicodeMemo(Memo).Text
  else
    FText := Memo.Text;

  FFormat.UnhostControls;
  if ModalResult = mrOk then
    FMemoView.DisplayFormat.Assign(FFormat.Format);
  FFormat.Free;
  FHighlight.UnhostControls(ModalResult);
  FHighlight.Free;
end;

procedure TfrxMemoEditorForm.ExprBClick(Sender: TObject);
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
    s1 := MemoView.ExpressionDelimiters;
    s2 := Copy(s1, Pos(',', s1) + 1, 255);
    s1 := Copy(s1, 1, Pos(',', s1) - 1);
    if (s[1] = '<') and (s[Length(s)] = '>') and (BracketCount = 1) then
      s := Copy(s, 2, Length(s) - 2);
    Memo.SelText := s1 + s + s2;
  end;
end;

procedure TfrxMemoEditorForm.WordWrapBClick(Sender: TObject);
var
  s: WideString;
begin
  s := '';
  if FIsUnicode then
    s := TUnicodeMemo(Memo).Text;

  Memo.WordWrap := WordWrapB.Down;
  if Memo.WordWrap then
    Memo.ScrollBars := ssVertical
  else
    Memo.ScrollBars := ssBoth;

  if FIsUnicode then
    TUnicodeMemo(Memo).Text := s;
end;

procedure TfrxMemoEditorForm.MemoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = vk_Return) and (ssCtrl in Shift) then
    ModalResult := mrOk
  else if Key = vk_Escape then
    ModalResult := mrCancel
  else if (Key = Ord('A')) and (Shift = [ssCtrl]) then
    Memo.SelectAll;
end;

procedure TfrxMemoEditorForm.FormCreate(Sender: TObject);
begin
  Caption := frxGet(3900);
  ExprB.Hint := frxGet(3901);
  AggregateB.Hint := frxGet(3902);
  LocalFormatB.Hint := frxGet(3903);
  WordWrapB.Hint := frxGet(3904);
  TextTS.Caption := frxGet(3905);
  FormatTS.Caption := frxGet(3906);
  HighlightTS.Caption := frxGet(3907);
  OkB.Caption := frxGet(1);
  CancelB.Caption := frxGet(2);
end;

procedure TfrxMemoEditorForm.AggregateBClick(Sender: TObject);
begin
  with TfrxSysMemoEditorForm.Create(Owner) do
  begin
    AggregateOnly := True;
    if ShowModal = mrOk then
      Memo.SelText := Text;
    Free;
  end;
end;

procedure TfrxMemoEditorForm.LocalFormatBClick(Sender: TObject);
var
  s: String;
  i: Integer;
begin
  with TfrxFormatEditorForm.Create(Owner) do
  begin
    if ShowModal = mrOk then
    begin
      case Format.Kind of
        fkText:
          s := '';

        fkNumeric:
          begin
            s := Format.FormatStr;
            for i := 1 to Length(s) do
              if s[i] in ['.', ',', '-'] then
                if Format.DecimalSeparator <> '' then
                  s[i] := Format.DecimalSeparator[1] else
                  s[i] := DecimalSeparator;
            s := ' #n' + s;
          end;

        fkDateTime:
          s := ' #d' + Format.FormatStr;

        fkBoolean:
          s := ' #b' + Format.FormatStr;
      end;

      if s <> '' then
      begin
        i := Memo.SelStart;
        if (i > 0) and (Memo.Text[i] = ']') then
          Memo.SelStart := Memo.SelStart - 1;
        Memo.SelText := s;

      end;
    end;
    Free;
  end;
end;

procedure TfrxMemoEditorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

end.



//0f31356a91fea3356e5f76cdce90aa7b