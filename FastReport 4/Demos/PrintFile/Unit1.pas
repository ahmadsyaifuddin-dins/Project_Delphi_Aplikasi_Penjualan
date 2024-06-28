unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  frxClass, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    frxReport1: TfrxReport;
    procedure Button1Click(Sender: TObject);
    procedure frxReport1GetValue(VarName: String; var Value: Variant);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

var
  ar: array[0..9] of Integer = (0,1,2,3,4,5,6,7,8,9);

procedure TForm1.Button1Click(Sender: TObject);
begin
  frxReport1.ShowReport;
end;

procedure TForm1.frxReport1GetValue(VarName: String; var Value: Variant);
var
  sl: TStringList;
begin
  if CompareText(VarName, 'file') = 0 then
  begin
    sl := TStringList.Create;
    sl.LoadFromFile('unit1.pas');
    Value := sl.Text;
    sl.Free;
  end;
end;

end.
