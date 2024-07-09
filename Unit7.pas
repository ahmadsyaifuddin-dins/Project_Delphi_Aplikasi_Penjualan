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
    btn6: TButton;
    btn4: TButton;
    btn5: TButton;
    btn7: TButton;
    edt10: TEdit;
    cbb1: TComboBox;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    procedure dbgrd1CellClick(Column: TColumn);
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btn6Click(Sender: TObject);
    procedure bersih;
    procedure posisiawal;
    procedure FormShow(Sender: TObject);
    procedure btn4Click(Sender: TObject);
    procedure edt10Change(Sender: TObject);
    procedure btn7Click(Sender: TObject);
    procedure cbb1Change(Sender: TObject);
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
cbb1.Text:= DataModule4.tbl_kustomer.Fields[6].AsString;
b:= DataModule4.tbl_kustomer.Fields[0].AsString;

// Mengatur persentase diskon berdasarkan nilai ComboBox
  if cbb1.Text = 'Yes' then
  begin
    lbl3.Caption := '10%';
  end
  else if cbb1.Text = 'No' then
  begin
    lbl3.Caption := '5%';
  end
  else
  begin
    lbl3.Caption := 'Terisi Otomatis';
  end;

edt1.Enabled:= True;
edt2.Enabled:= True;
edt3.Enabled:= True;
edt4.Enabled:= True;
edt5.Enabled:= True;

btn2.Enabled:= True;
btn3.Enabled:=True;
btn5.Enabled:= True;
btn6.Enabled:= False;
btn1.Enabled:= False;
end;

procedure TKustomer7.btn1Click(Sender: TObject);
begin
// Validasi input
  if edt1.Text = '' then
  begin
    ShowMessage('NIK tidak boleh kosong!');
    Exit;
  end;
  if edt2.Text = '' then
  begin
    ShowMessage('Nama tidak boleh kosong!');
    Exit;
  end;
  if edt3.Text = '' then
  begin
    ShowMessage('Alamat tidak boleh kosong!');
    Exit;
  end;
  if edt4.Text = '' then
  begin
    ShowMessage('Telepon tidak boleh kosong!');
    Exit;
  end;
  if edt5.Text = '' then
  begin
    ShowMessage('Email tidak boleh kosong!');
    Exit;
  end;
  if cbb1.Text = '' then
  begin
    ShowMessage('Member status tidak boleh kosong!');
    Exit;
  end;

  // Pengecekan duplikasi berdasarkan NIK
  if DataModule4.tbl_kustomer.Locate('NIK', edt1.Text, []) then
  begin
    ShowMessage('NIK ' + edt1.Text + ' sudah ada di dalam sistem');
    Exit;
  end;

  // Simpan data
  with DataModule4.tbl_kustomer do
  begin
    SQL.Clear;
    SQL.Add('INSERT INTO kustomer (NIK, name, alamat, telp, email, member) VALUES ('
      + QuotedStr(edt1.Text) + ', '
      + QuotedStr(edt2.Text) + ', '
      + QuotedStr(edt3.Text) + ', '
      + QuotedStr(edt4.Text) + ', '
      + QuotedStr(edt5.Text) + ', '
      + QuotedStr(cbb1.Text) + ')');
    ExecSQL;

    // Refresh dataset
    SQL.Clear;
    SQL.Add('SELECT * FROM kustomer');
    Open;
  end;

  ShowMessage('Data Berhasil Disimpan');
  posisiawal;
end;

procedure TKustomer7.btn2Click(Sender: TObject);
begin
// Validasi input
  if edt1.Text = '' then
  begin
    ShowMessage('NIK tidak boleh kosong!');
    Exit;
  end;
  if edt2.Text = '' then
  begin
    ShowMessage('Nama tidak boleh kosong!');
    Exit;
  end;
  if edt3.Text = '' then
  begin
    ShowMessage('Alamat tidak boleh kosong!');
    Exit;
  end;
  if edt4.Text = '' then
  begin
    ShowMessage('Telepon tidak boleh kosong!');
    Exit;
  end;
  if edt5.Text = '' then
  begin
    ShowMessage('Email tidak boleh kosong!');
    Exit;
  end;
  if cbb1.Text = '' then
  begin
    ShowMessage('Member status tidak boleh kosong!');
    Exit;
  end;

  // Kode update
  with DataModule4.tbl_kustomer do
  begin
    SQL.Clear;
    SQL.Add('UPDATE kustomer SET ' +
            'NIK = ' + QuotedStr(edt1.Text) + ', ' +
            'name = ' + QuotedStr(edt2.Text) + ', ' +
            'alamat = ' + QuotedStr(edt3.Text) + ', ' +
            'telp = ' + QuotedStr(edt4.Text) + ', ' +
            'email = ' + QuotedStr(edt5.Text) + ', ' +
            'member = ' + QuotedStr(cbb1.Text) + ' ' +
            ' WHERE id = ' + QuotedStr(b));
    ExecSQL;

    // Refresh dataset
    SQL.Clear;
    SQL.Add('SELECT * FROM kustomer');
    Open;
  end;

  ShowMessage('Data Berhasil Diupdate!');
  posisiawal;
end;

procedure TKustomer7.btn3Click(Sender: TObject);
begin
if MessageDlg('Apakah Anda yakin menghapus data ini?', mtWarning, [mbYes, mbNo], 0) = mrYes then
  begin
    with DataModule4.tbl_kustomer do
    begin
      SQL.Clear;
      SQL.Add('DELETE FROM kustomer WHERE id = ' + QuotedStr(b));
      ExecSQL;

      // Refresh dataset
      SQL.Clear;
      SQL.Add('SELECT * FROM kustomer');
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

procedure TKustomer7.btn6Click(Sender: TObject);
begin
edt1.Enabled:= True;
edt2.Enabled:= True;
edt3.Enabled:= True;
edt4.Enabled:= True;
edt5.Enabled:= True;
btn1.Enabled:= True;
btn2.Enabled:= False;
btn3.Enabled:= False;
btn5.Enabled:= True;
btn6.Enabled:= False;
end;

procedure TKustomer7.bersih;
begin
edt1.Clear;
edt2.Clear;
edt3.Clear;
edt4.Clear;
edt5.Clear;
cbb1.ItemIndex := -1; // Mengembalikan ComboBox ke nilai default (tidak ada pilihan yang dipilih)
lbl3.Caption := 'Terisi Otomatis'; // Mengembalikan label ke caption default
end;

procedure TKustomer7.posisiawal;
begin
bersih;
edt1.Enabled:= False;
edt2.Enabled:= False;
edt3.Enabled:= False;
edt4.Enabled:= False;
edt5.Enabled:= False;
btn6.Enabled:= True;
btn1.Enabled:= false;
btn2.Enabled:= false;
btn3.Enabled:= false;
btn5.Enabled:= False;
end;

procedure TKustomer7.FormShow(Sender: TObject);
begin
posisiawal;
end;

procedure TKustomer7.btn4Click(Sender: TObject);
begin
edt1.Clear;
edt2.Clear;
edt3.Clear;
edt4.Clear;
edt5.Clear;
cbb1.ItemIndex := -1; // Mengembalikan ComboBox ke nilai default (tidak ada pilihan yang dipilih)
lbl3.Caption := 'Terisi Otomatis'; // Mengembalikan label ke caption default

btn1.Enabled:= True;
btn5.Enabled:= True;
btn2.Enabled:= False;
btn3.Enabled:= False;
end;

procedure TKustomer7.edt10Change(Sender: TObject);
begin
with DataModule4.tbl_kustomer do
begin
SQL.Clear;
SQL.Add('select * from kustomer where name like "%'+edt10.Text+'%"');
Open;
end;
end;

procedure TKustomer7.btn7Click(Sender: TObject);
begin
DataModule4.ReportKus.ShowReport();
end;

procedure TKustomer7.cbb1Change(Sender: TObject);
begin
 if cbb1.Text = 'Yes' then
  begin
    lbl3.Caption := '10%';
  end
  else if cbb1.Text = 'No' then
  begin
    lbl3.Caption := '5%';
  end
  else
  begin
    lbl3.Caption := 'Terisi Otomatis';
  end;
end;

end.
