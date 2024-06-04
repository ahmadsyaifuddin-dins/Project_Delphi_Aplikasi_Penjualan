unit Unit6;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, DBGrids;

type
  TSupplier6 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    edt1: TEdit;
    edt2: TEdit;
    edt3: TEdit;
    edt4: TEdit;
    edt5: TEdit;
    edt6: TEdit;
    edt7: TEdit;
    edt8: TEdit;
    edt9: TEdit;
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
  Supplier6: TSupplier6;
  b: string;
  sql : string;

implementation

uses
  Unit4;

{$R *.dfm}

procedure TSupplier6.dbgrd1CellClick(Column: TColumn);
begin
edt1.Text:= DataModule4.tbl_supplier.Fields[1].AsString;
edt2.Text:= DataModule4.tbl_supplier.Fields[2].AsString;
edt3.Text:= DataModule4.tbl_supplier.Fields[3].AsString;
edt4.Text:= DataModule4.tbl_supplier.Fields[4].AsString;
edt5.Text:= DataModule4.tbl_supplier.Fields[5].AsString;
edt6.Text:= DataModule4.tbl_supplier.Fields[6].AsString;
edt7.Text:= DataModule4.tbl_supplier.Fields[7].AsString;
edt8.Text:= DataModule4.tbl_supplier.Fields[8].AsString;
edt9.Text:= DataModule4.tbl_supplier.Fields[9].AsString;
b:= DataModule4.tbl_supplier.Fields[0].AsString;
end;

procedure TSupplier6.btn1Click(Sender: TObject);
begin
sql := 'INSERT INTO supplier (NIK, name, telp, alamat, email, perusahaan, nama_bank, akun_bank, no_akun_bank) VALUES ('
    + QuotedStr(edt1.Text) + ', '
    + QuotedStr(edt2.Text) + ', '
    + QuotedStr(edt3.Text) + ', '
    + QuotedStr(edt4.Text) + ', '
    + QuotedStr(edt5.Text) + ', '
    + QuotedStr(edt6.Text) + ', '
    + QuotedStr(edt7.Text) + ', '
    + QuotedStr(edt8.Text) + ', '
    + QuotedStr(edt9.Text) + ')';
    
  DataModule4.tbl_supplier.SQL.Clear;
  DataModule4.tbl_supplier.SQL.Add(sql);
  DataModule4.tbl_supplier.ExecSQL;

  DataModule4.tbl_supplier.SQL.Clear;
  DataModule4.tbl_supplier.SQL.Add('SELECT * FROM supplier');
  DataModule4.tbl_supplier.Open;
  ShowMessage('Data Berhasil Disimpan');
end;

procedure TSupplier6.btn2Click(Sender: TObject);
begin
sql := 'UPDATE supplier SET ' +
         'NIK = ' + QuotedStr(edt1.Text) + ', ' +
         'name = ' + QuotedStr(edt2.Text) + ', ' +
         'telp = ' + QuotedStr(edt3.Text) + ', ' +
         'alamat = ' + QuotedStr(edt4.Text) + ', ' +
         'email = ' + QuotedStr(edt5.Text) + ', ' +
         'perusahaan = ' + QuotedStr(edt6.Text) + ', ' +
         'nama_bank = ' + QuotedStr(edt7.Text) + ', ' +
         'akun_bank = ' + QuotedStr(edt8.Text) + ', ' +
         'no_akun_bank = ' + QuotedStr(edt9.Text) +
         ' WHERE id = ' + QuotedStr(b);

  DataModule4.tbl_supplier.SQL.Clear;
  DataModule4.tbl_supplier.SQL.Add(sql);
  DataModule4.tbl_supplier.ExecSQL;

  DataModule4.tbl_supplier.SQL.Clear;
  DataModule4.tbl_supplier.SQL.Add('SELECT * FROM supplier');
  DataModule4.tbl_supplier.Open;
  ShowMessage('Data Berhasil Diupdate!');
end;

procedure TSupplier6.btn3Click(Sender: TObject);
begin
sql := 'DELETE FROM supplier WHERE id = ' + QuotedStr(b);

  DataModule4.tbl_supplier.SQL.Clear;
  DataModule4.tbl_supplier.SQL.Add(sql);
  DataModule4.tbl_supplier.ExecSQL;

  DataModule4.tbl_supplier.SQL.Clear;
  DataModule4.tbl_supplier.SQL.Add('SELECT * FROM supplier');
  DataModule4.tbl_supplier.Open;
  ShowMessage('Data Berhasil Dihapus!');
end;

end.
