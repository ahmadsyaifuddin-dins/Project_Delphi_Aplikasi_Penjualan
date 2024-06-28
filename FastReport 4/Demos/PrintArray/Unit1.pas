unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  frxClass, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    ArrayDS: TfrxUserDataSet;
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
  ArrayDS.RangeEnd := reCount;
  ArrayDS.RangeEndCount := 10;
  frxReport1.ShowReport;
end;

procedure TForm1.frxReport1GetValue(VarName: String; var Value: Variant);
begin
  if CompareText(VarName, 'element') = 0 then
    Value := ar[ArrayDS.RecNo];
end;

end.
