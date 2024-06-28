unit FormDLL;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, DBTables, DB, frxDBSet, frxClass;

type
  TfrmDLL = class(TForm)
    btnBioLifePrintPreview: TButton;
    Table1: TTable;
    frxDBDataset1: TfrxDBDataset;
    frxReport1: TfrxReport;
    procedure btnBioLifePrintPreviewClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


function ShowForm(A: TApplication): Bool; StdCall;


implementation

{$R *.DFM}

{------------------------------------------------------------------------}

function ShowForm(A: TApplication): Bool;
var
  Form1: TfrmDLL;
begin
  Application.Handle := A.Handle;
  Form1 := TfrmDLL.Create(A);
  try
    Result := (Form1.ShowModal = mrOK);
  finally
    Form1.Free;
  end;
end;

procedure TfrmDLL.btnBioLifePrintPreviewClick(Sender: TObject);
begin
  frxReport1.ShowReport;
end;

procedure TfrmDLL.FormActivate(Sender: TObject);
begin
  Session.Active := True;
end;

procedure TfrmDLL.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Session.Active := False;
end;

end.
