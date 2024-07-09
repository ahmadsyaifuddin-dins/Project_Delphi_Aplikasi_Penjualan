unit Unit12;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, DBGrids;

type
  TLap_barang12 = class(TForm)
    edt1: TEdit;
    edt2: TEdit;
    edt3: TEdit;
    edt4: TEdit;
    edt5: TEdit;
    edt6: TEdit;
    edt7: TEdit;
    edt8: TEdit;
    edt9: TEdit;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    btn1: TButton;
    btn2: TButton;
    btn3: TButton;
    btn4: TButton;
    btn6: TButton;
    btn5: TButton;
    edt11: TEdit;
    dbgrd1: TDBGrid;
    btn7: TButton;
    Label2: TLabel;
    procedure btn6Click(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btn4Click(Sender: TObject);
    procedure bersih;
    procedure posisiawal;
    procedure FormShow(Sender: TObject);
    procedure edt11Change(Sender: TObject);
    procedure dbgrd1CellClick(Column: TColumn);
    procedure btn7Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Lap_barang12: TLap_barang12;
  b : string;
  sql : string;

implementation

uses
  Unit4;

{$R *.dfm}

procedure TLap_barang12.btn6Click(Sender: TObject);
begin
edt1.Enabled:= True;
edt2.Enabled:= True;
edt3.Enabled:= True;
edt4.Enabled:= True;
edt5.Enabled:= True;
edt6.Enabled:= True;
edt7.Enabled:= True;
edt8.Enabled:= True;
edt9.Enabled:= True;
btn1.Enabled:= True;
btn2.Enabled:= False;
btn3.Enabled:= False;
btn5.Enabled:= True;
btn6.Enabled:= False;
end;

procedure TLap_barang12.btn1Click(Sender: TObject);
begin
// Validasi input
  if edt1.Text = '' then
  begin
    ShowMessage('BARCODE tidak boleh kosong!');
    Exit;
  end;
  if edt2.Text = '' then
  begin
    ShowMessage('Nama barang tidak boleh kosong!');
    Exit;
  end;
  if edt3.Text = '' then
  begin
    ShowMessage('Harga jual tidak boleh kosong!');
    Exit;
  end;
  if edt4.Text = '' then
  begin
    ShowMessage('Harga beli tidak boleh kosong!');
    Exit;
  end;
  if edt5.Text = '' then
  begin
    ShowMessage('Stok tidak boleh kosong!');
    Exit;
  end;
  if edt6.Text = '' then
  begin
    ShowMessage('Kategori ID tidak boleh kosong!');
    Exit;
  end;
  if edt7.Text = '' then
  begin
    ShowMessage('Satuan ID tidak boleh kosong!');
    Exit;
  end;
  if edt8.Text = '' then
  begin
    ShowMessage('User ID tidak boleh kosong!');
    Exit;
  end;
  if edt9.Text = '' then
  begin
    ShowMessage('Supplier ID tidak boleh kosong!');
    Exit;
  end;

  // Pengecekan duplikasi berdasarkan BARCODE
  if DataModule4.tbl_barang.Locate('BARCODE', edt1.Text, []) then
  begin
    ShowMessage('BARCODE ' + edt1.Text + ' sudah ada di dalam sistem');
    Exit;
  end;

  // Simpan data
  with DataModule4.tbl_barang do
  begin
    SQL.Clear;
    SQL.Add('INSERT INTO barang (BARCODE, name, harga_jual, harga_beli, stok, kategori_id, satuan_id, user_id, supplier_id) VALUES ('
      + QuotedStr(edt1.Text) + ', '
      + QuotedStr(edt2.Text) + ', '
      + QuotedStr(edt3.Text) + ', '
      + QuotedStr(edt4.Text) + ', '
      + QuotedStr(edt5.Text) + ', '
      + QuotedStr(edt6.Text) + ', '
      + QuotedStr(edt7.Text) + ', '
      + QuotedStr(edt8.Text) + ', '
      + QuotedStr(edt9.Text) + ')');
    ExecSQL;

    // Refresh dataset
    SQL.Clear;
    SQL.Add('SELECT * FROM barang');
    Open;
  end;

  ShowMessage('Data Berhasil Disimpan!');
  posisiawal;
end;

procedure TLap_barang12.btn2Click(Sender: TObject);
begin
if edt1.Text = '' then
  begin
    ShowMessage('BARCODE tidak boleh kosong!');
    Exit;
  end;

  if edt2.Text = '' then
  begin
    ShowMessage('Nama barang tidak boleh kosong!');
    Exit;
  end;

  // Kode update
  with DataModule4.tbl_barang do
  begin
    SQL.Clear;
    SQL.Add('UPDATE barang SET ' +
            'BARCODE = ' + QuotedStr(edt1.Text) + ', ' +
            'name = ' + QuotedStr(edt2.Text) + ', ' +
            'harga_jual = ' + QuotedStr(edt3.Text) + ', ' +
            'harga_beli = ' + QuotedStr(edt4.Text) + ', ' +
            'stok = ' + QuotedStr(edt5.Text) + ', ' +
            'kategori_id = ' + QuotedStr(edt6.Text) + ', ' +
            'satuan_id = ' + QuotedStr(edt7.Text) + ', ' +
            'user_id = ' + QuotedStr(edt8.Text) + ', ' +
            'supplier_id = ' + QuotedStr(edt9.Text) +
            ' WHERE id = ' + QuotedStr(b));
    ExecSQL;

    // Refresh dataset
    SQL.Clear;
    SQL.Add('SELECT * FROM barang');
    Open;
  end;

  ShowMessage('Data Berhasil Diupdate!');
  posisiawal;
end;

procedure TLap_barang12.btn3Click(Sender: TObject);
begin
 if MessageDlg('Apakah Anda yakin menghapus data ini?', mtWarning, [mbYes, mbNo], 0) = mrYes then
  begin
    with DataModule4.tbl_barang do
    begin
      SQL.Clear;
      SQL.Add('DELETE FROM barang WHERE id = ' + QuotedStr(b));
      ExecSQL;

      // Refresh dataset
      SQL.Clear;
      SQL.Add('SELECT * FROM barang');
      Open;
    end;
    ShowMessage('Data Berhasil Dihapus!');
  end
  else
  begin
    ShowMessage('Data Batal Dihapus!');
  end;
  posisiawal;
end;

procedure TLap_barang12.btn4Click(Sender: TObject);
begin
edt1.Clear;
edt2.Clear;
edt3.Clear;
edt4.Clear;
edt5.Clear;
edt6.Clear;
edt7.Clear;
edt8.Clear;
edt9.Clear;
btn1.Enabled:= True;
btn5.Enabled:= True;
btn2.Enabled:= False;
btn3.Enabled:= False;
end;

procedure TLap_barang12.bersih;
begin
edt1.Clear;
edt2.Clear;
edt3.Clear;
edt4.Clear;
edt5.Clear;
edt6.Clear;
edt7.Clear;
edt8.Clear;
edt9.Clear;
end;

procedure TLap_barang12.posisiawal;
begin
edt1.Enabled:= False;
edt2.Enabled:= False;
edt3.Enabled:= False;
edt4.Enabled:= False;
edt5.Enabled:= False;
edt6.Enabled:= False;
edt7.Enabled:= False;
edt8.Enabled:= False;
edt9.Enabled:= False;
bersih;
btn6.Enabled:= True;
btn1.Enabled:= false;
btn2.Enabled:= false;
btn3.Enabled:= false;
btn5.Enabled:= False;
end;

procedure TLap_barang12.FormShow(Sender: TObject);
begin
posisiawal;
end;

procedure TLap_barang12.edt11Change(Sender: TObject);
begin
with DataModule4.tbl_barang do
begin
SQL.Clear;
SQL.Add('select * from barang where name like "%'+edt11.Text+'%"');
Open;
end;
end;

procedure TLap_barang12.dbgrd1CellClick(Column: TColumn);
begin
edt1.Text:= DataModule4.tbl_barang.Fields[1].AsString;
edt2.Text:= DataModule4.tbl_barang.Fields[2].AsString;
edt3.Text:= DataModule4.tbl_barang.Fields[3].AsString;
edt4.Text:= DataModule4.tbl_barang.Fields[4].AsString;
edt5.Text:= DataModule4.tbl_barang.Fields[5].AsString;
edt6.Text:= DataModule4.tbl_barang.Fields[6].AsString;
edt7.Text:= DataModule4.tbl_barang.Fields[7].AsString;
edt8.Text:= DataModule4.tbl_barang.Fields[8].AsString;
edt9.Text:= DataModule4.tbl_barang.Fields[9].AsString;
b:= DataModule4.tbl_barang.Fields[0].AsString;

edt1.Enabled:= True;
edt2.Enabled:= True;
edt3.Enabled:= True;
edt4.Enabled:= True;
edt5.Enabled:= True;
edt6.Enabled:= True;
edt7.Enabled:= True;
edt8.Enabled:= True;
edt9.Enabled:= True;

btn2.Enabled:= True;
btn3.Enabled:=True;
btn5.Enabled:= True;
btn6.Enabled:= False;
btn1.Enabled:= False;
end;

procedure TLap_barang12.btn7Click(Sender: TObject);
begin
DataModule4.ReportBarang.ShowReport();
end;

end.
