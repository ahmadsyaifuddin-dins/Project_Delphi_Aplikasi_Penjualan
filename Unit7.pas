unit Unit7;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, DBGrids;

type
  TKustomer7 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    edt1: TEdit;
    edt2: TEdit;
    edt3: TEdit;
    edt4: TEdit;
    edt5: TEdit;
    dbgrd1: TDBGrid;
    btn1: TButton;
    btn2: TButton;
    btn3: TButton;
    procedure dbgrd1CellClick(Column: TColumn);
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Kustomer7: TKustomer7;
  b: string;
  sql: string;

implementation

uses
  Unit4;

{$R *.dfm}

procedure TKustomer7.dbgrd1CellClick(Column: TColumn);
begin
edt1.Text:= DataModule4.tbl_kustomer.Fields[1].AsString;
edt2.Text:= DataModule4.tbl_kustomer.Fields[2].AsString;
edt3.Text:= DataModule4.tbl_kustomer.Fields[3].AsString;
edt4.Text:= DataModule4.tbl_kustomer.Fields[4].AsString;
edt5.Text:= DataModule4.tbl_kustomer.Fields[5].AsString;
b:= DataModule4.tbl_kustomer.Fields[0].AsString;
end;

procedure TKustomer7.btn1Click(Sender: TObject);
begin
sql := 'INSERT INTO kustomer (NIK, name, alamat, telp, email) VALUES ('
    + QuotedStr(edt1.Text) + ', '
    + QuotedStr(edt2.Text) + ', '
    + QuotedStr(edt3.Text) + ', '
    + QuotedStr(edt4.Text) + ', '
    + QuotedStr(edt5.Text) + ')';
    
  DataModule4.tbl_kustomer.SQL.Clear;
  DataModule4.tbl_kustomer.SQL.Add(sql);
  DataModule4.tbl_kustomer.ExecSQL;

  DataModule4.tbl_kustomer.SQL.Clear;
  DataModule4.tbl_kustomer.SQL.Add('SELECT * FROM kustomer');
  DataModule4.tbl_kustomer.Open;
  ShowMessage('Data Berhasil Disimpan');
end;

procedure TKustomer7.btn2Click(Sender: TObject);
begin
sql := 'UPDATE kustomer SET ' +
         'NIK = ' + QuotedStr(edt1.Text) + ', ' +
         'name = ' + QuotedStr(edt2.Text) + ', ' +
         'alamat = ' + QuotedStr(edt3.Text) + ', ' +
         'telp = ' + QuotedStr(edt4.Text) + ', ' +
         'email = ' + QuotedStr(edt5.Text) +
         ' WHERE id = ' + QuotedStr(b);

  DataModule4.tbl_kustomer.SQL.Clear;
  DataModule4.tbl_kustomer.SQL.Add(sql);
  DataModule4.tbl_kustomer.ExecSQL;

  DataModule4.tbl_kustomer.SQL.Clear;
  DataModule4.tbl_kustomer.SQL.Add('SELECT * FROM kustomer');
  DataModule4.tbl_kustomer.Open;
  ShowMessage('Data Berhasil Diupdate!');
end;

procedure TKustomer7.btn3Click(Sender: TObject);
begin
sql := 'DELETE FROM kustomer WHERE id = ' + QuotedStr(b);

  DataModule4.tbl_kustomer.SQL.Clear;
  DataModule4.tbl_kustomer.SQL.Add(sql);
  DataModule4.tbl_kustomer.ExecSQL;

  DataModule4.tbl_kustomer.SQL.Clear;
  DataModule4.tbl_kustomer.SQL.Add('SELECT * FROM kustomer');
  DataModule4.tbl_kustomer.Open;
  ShowMessage('Data Berhasil Dihapus!');
end;

end.
