unit Unit9;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Grids, DBGrids;

type
  TPembelian9 = class(TForm)
    dbgrd1: TDBGrid;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    edt1: TEdit;
    edt2: TEdit;
    edt3: TEdit;
    edt4: TEdit;
    btn1: TButton;
    btn2: TButton;
    btn3: TButton;
    edt6: TEdit;
    edt7: TEdit;
    dtp1: TDateTimePicker;
    btn6: TButton;
    btn4: TButton;
    btn5: TButton;
    edt10: TEdit;
    btn7: TButton;
    procedure dbgrd1CellClick(Column: TColumn);
    procedure btn6Click(Sender: TObject);
    procedure btn4Click(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure bersih;
    procedure posisiawal;
    procedure edt10Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btn7Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Pembelian9: TPembelian9;
  b: string;
  sql: string;

implementation

uses
  Unit4;

{$R *.dfm}

procedure TPembelian9.dbgrd1CellClick(Column: TColumn);
begin
edt1.Text:= DataModule4.tbl_pembelian.Fields[1].AsString;
edt2.Text:= DataModule4.tbl_pembelian.Fields[2].AsString;
edt3.Text:= DataModule4.tbl_pembelian.Fields[3].AsString;
edt4.Text:= DataModule4.tbl_pembelian.Fields[4].AsString;
dtp1.Date:= DataModule4.tbl_pembelian.Fields[5].AsDateTime;
edt6.Text:= DataModule4.tbl_pembelian.Fields[6].AsString;
edt7.Text:= DataModule4.tbl_pembelian.Fields[7].AsString;
b:= DataModule4.tbl_pembelian.Fields[0].AsString;

edt1.Enabled:= True;
edt2.Enabled:= True;
edt3.Enabled:= True;
edt4.Enabled:= True;
edt6.Enabled:= True;
edt7.Enabled:= True;

btn2.Enabled:= True;
btn3.Enabled:=True;
btn5.Enabled:= True;
btn6.Enabled:= False;
btn1.Enabled:= False;
end;

procedure TPembelian9.btn6Click(Sender: TObject);
begin
edt1.Enabled:= True;
edt2.Enabled:= True;
edt3.Enabled:= True;
edt4.Enabled:= True;
edt6.Enabled:= True;
edt7.Enabled:= True;
btn1.Enabled:= True;
btn2.Enabled:= False;
btn3.Enabled:= False;
btn5.Enabled:= True;
btn6.Enabled:= False;
end;

procedure TPembelian9.btn4Click(Sender: TObject);
begin
edt1.Clear;
edt2.Clear;
edt3.Clear;
edt4.Clear;
edt6.Clear;
edt7.Clear;
btn1.Enabled:= True;
btn5.Enabled:= True;
btn2.Enabled:= False;
btn3.Enabled:= False;
end;

procedure TPembelian9.btn1Click(Sender: TObject);
begin
// Validasi input
  if edt1.Text = '' then
  begin
    ShowMessage('Invoice tidak boleh kosong!');
    Exit;
  end;
  if edt2.Text = '' then
  begin
    ShowMessage('Total tidak boleh kosong!');
    Exit;
  end;
  if edt3.Text = '' then
  begin
    ShowMessage('Bayar tidak boleh kosong!');
    Exit;
  end;
  if edt4.Text = '' then
  begin
    ShowMessage('Deskripsi tidak boleh kosong!');
    Exit;
  end;
  if edt6.Text = '' then
  begin
    ShowMessage('Supplier ID tidak boleh kosong!');
    Exit;
  end;
  if edt7.Text = '' then
  begin
    ShowMessage('User ID tidak boleh kosong!');
    Exit;
  end;

  // Simpan data
  with DataModule4.tbl_pembelian do
  begin
    SQL.Clear;
    SQL.Add('INSERT INTO pembelian (invoice, total, bayar, deskripsi, tanggal, supplier_id, user_id) VALUES ('
      + QuotedStr(edt1.Text) + ', '
      + QuotedStr(edt2.Text) + ', '
      + QuotedStr(edt3.Text) + ', '
      + QuotedStr(edt4.Text) + ', '
      + QuotedStr(FormatDateTime('yyyy-mm-dd', dtp1.Date)) + ', '
      + QuotedStr(edt6.Text) + ', '
      + QuotedStr(edt7.Text) + ')');
    ExecSQL;

    // Refresh dataset
    SQL.Clear;
    SQL.Add('SELECT * FROM pembelian');
    Open;
  end;

  ShowMessage('Data Berhasil Disimpan');
  posisiawal;
end;

procedure TPembelian9.btn2Click(Sender: TObject);
begin
// Validasi input
  if edt1.Text = '' then
  begin
    ShowMessage('Invoice tidak boleh kosong!');
    Exit;
  end;
  if edt2.Text = '' then
  begin
    ShowMessage('Total tidak boleh kosong!');
    Exit;
  end;
  if edt3.Text = '' then
  begin
    ShowMessage('Bayar tidak boleh kosong!');
    Exit;
  end;
  if edt4.Text = '' then
  begin
    ShowMessage('Deskripsi tidak boleh kosong!');
    Exit;
  end;
  if edt6.Text = '' then
  begin
    ShowMessage('Kustomer ID tidak boleh kosong!');
    Exit;
  end;
  if edt7.Text = '' then
  begin
    ShowMessage('User ID tidak boleh kosong!');
    Exit;
  end;

  // Kode update
  with DataModule4.tbl_pembelian do
  begin
    SQL.Clear;
    SQL.Add('UPDATE pembelian SET ' +
            'invoice = ' + QuotedStr(edt1.Text) + ', ' +
            'total = ' + QuotedStr(edt2.Text) + ', ' +
            'bayar = ' + QuotedStr(edt3.Text) + ', ' +
            'deskripsi = ' + QuotedStr(edt4.Text) + ', ' +
            'tanggal = ' + QuotedStr(FormatDateTime('yyyy-mm-dd', dtp1.Date)) + ', ' +
            'supplier_id = ' + QuotedStr(edt6.Text) + ', ' +
            'user_id = ' + QuotedStr(edt7.Text) +
            ' WHERE id = ' + QuotedStr(b)); // Assuming RecordID contains the record ID to update

    ExecSQL;

    // Refresh dataset
    SQL.Clear;
    SQL.Add('SELECT * FROM pembelian');
    Open;
  end;

  ShowMessage('Data Berhasil Diupdate!');
  posisiawal;
end;

procedure TPembelian9.btn3Click(Sender: TObject);
begin
if MessageDlg('Apakah Anda yakin menghapus data ini?', mtWarning, [mbYes, mbNo], 0) = mrYes then
  begin
    with DataModule4.tbl_pembelian do
    begin
      SQL.Clear;
      SQL.Add('DELETE FROM pembelian WHERE id = ' + QuotedStr(b)); // Assuming RecordID contains the record ID to delete
      ExecSQL;

      // Refresh dataset
      SQL.Clear;
      SQL.Add('SELECT * FROM pembelian');
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

procedure TPembelian9.bersih;
begin
edt1.Clear;
edt2.Clear;
edt3.Clear;
edt4.Clear;
edt6.Clear;
edt7.Clear;
end;

procedure TPembelian9.posisiawal;
begin
edt1.Enabled:= False;
edt2.Enabled:= False;
edt3.Enabled:= False;
edt4.Enabled:= False;
edt6.Enabled:= False;
edt7.Enabled:= False;
bersih;
btn6.Enabled:= True;
btn1.Enabled:= false;
btn2.Enabled:= false;
btn3.Enabled:= false;
btn5.Enabled:= False;

end;

procedure TPembelian9.edt10Change(Sender: TObject);
begin
with DataModule4.tbl_pembelian do
begin
SQL.Clear;
SQL.Add('select * from pembelian where invoice like "%'+edt10.Text+'%"');
Open;
end;
end;

procedure TPembelian9.FormShow(Sender: TObject);
begin
posisiawal;
end;

procedure TPembelian9.btn7Click(Sender: TObject);
begin
DataModule4.ReportBeli.ShowReport();
end;

end.
