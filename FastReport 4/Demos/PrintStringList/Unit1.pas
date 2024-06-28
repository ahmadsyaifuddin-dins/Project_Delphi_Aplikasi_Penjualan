unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  frxClass, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    StringDS: TfrxUserDataSet;
    frxReport1: TfrxReport;
    procedure Button1Click(Sender: TObject);
    procedure frxReport1GetValue(const VarName: String; var Value: Variant);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    sl: TStringList;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
  sl := TStringList.Create;
  sl.Add('1');
  sl.Add('2');
  sl.Add('3');
  sl.Add('4');
  sl.Add('5');
  sl.Add('6');
  sl.Add('7');
  sl.Add('8');
  sl.Add('9');
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  StringDS.RangeEnd := reCount;
  StringDS.RangeEndCount := sl.Count;
  frxReport1.ShowReport;
end;

procedure TForm1.frxReport1GetValue(const VarName: String; var Value: Variant);
begin
  if CompareText(VarName, 'element') = 0 then
    Value := sl[StringDS.RecNo];
end;

end.
