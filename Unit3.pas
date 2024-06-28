unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, DBGrids;

type
  TKategori3 = class(TForm)
    edt1: TEdit;
    Label1: TLabel;
    btn1: TButton;
    btn2: TButton;
    btn3: TButton;
    dbgrd1: TDBGrid;
    Label2: TLabel;
    btn4: TButton;
    btn6: TButton;
    edt2: TEdit;
    Label3: TLabel;
    btn5: TButton;
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure dbgrd1CellClick(Column: TColumn);
    procedure edt2Change(Sender: TObject);
    procedure btn5Click(Sender: TObject);
    procedure posisiawal;
    procedure bersih;
    procedure FormShow(Sender: TObject);
    procedure btn6Click(Sender: TObject);
    procedure btn4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Kategori3: TKategori3;
  a: string;


implementation

uses
  Unit4;

{$R *.dfm}

procedure TKategori3.btn1Click(Sender: TObject);
begin
  if edt1.Text = '' then
begin
ShowMessage('Nama Kategori Tidak Boleh Kosong!');
end else
if DataModule4.tbl_kategori.Locate('name',edt1.Text,[]) then
begin
ShowMessage('Nama Kategori '+edt1.Text+' Sudah Ada Didalam Sistem');
end else
Begin // simpan
with DataModule4.tbl_kategori do
begin
SQL.Clear;
SQL.Add('insert into kategori values(null,"'+edt1.Text+'")');
ExecSQL ;
SQL.Clear;
SQL.Add('select * from kategori');
Open;
end;
ShowMessage('Data Berhasil Disimpan!');
posisiawal;
end;
end;

procedure TKategori3.btn2Click(Sender: TObject);
begin
if edt1.Text = '' then
begin
ShowMessage('Nama Kategori Tidak Boleh Kosong!');
end else
if edt1.Text = DataModule4.tbl_kategori.Fields[1].AsString then
begin
ShowMessage('Nama Kategori '+edt1.Text+' Tidak Ada Perubahan');
end else
begin //kode update
with DataModule4.tbl_kategori do
begin
SQL.Clear;
SQL.Add('update kategori set name="'+edt1.text+'" where id= "'+a+'"');
ExecSQL ;

SQL.Clear;
SQL.Add('select * from kategori');
Open;
end;
ShowMessage('Data Berhasil Diupdate!');
posisiawal;
end;
end;

procedure TKategori3.btn3Click(Sender: TObject);
begin
//kode delete
if MessageDlg('Apakah Anda Yakin Menghapus Data ini',mtWarning,[mbYes,mbNo],0)=mryes then
begin
with DataModule4.tbl_kategori do
begin
SQL.Clear;
SQL.Add('delete from kategori where id= "'+a+'"');
ExecSQL ;

SQL.Clear;
SQL.Add('select * from kategori');
Open;
end;
ShowMessage('Data Berhasil DiDelete!');
end else
begin

ShowMessage('Data Batal Dihapus!');

end;
posisiawal;
end;

procedure TKategori3.dbgrd1CellClick(Column: TColumn);
begin
edt1.Text:= DataModule4.tbl_kategori.Fields[1].AsString;
a:= DataModule4.tbl_kategori.Fields[0].AsString;

edt1.Enabled:= True;
btn2.Enabled:= True;
btn3.Enabled:=True;
btn5.Enabled:= True;
btn6.Enabled:= False;
btn1.Enabled:= False;
end;

procedure TKategori3.edt2Change(Sender: TObject);
begin
with DataModule4.tbl_kategori do
begin
SQL.Clear;
SQL.Add('select * from kategori where name like "%'+edt2.Text+'%"');
Open;
end;
end;

procedure TKategori3.btn5Click(Sender: TObject);
begin
with DataModule4.tbl_kategori do
begin
SQL.Clear;
SQL.Add('select * from kategori where name = "'+edt1.Text+'"');
Open;
end;
end;

procedure TKategori3.posisiawal;
begin
bersih;
btn6.Enabled:= True;
btn1.Enabled:= false;
btn2.Enabled:= false;
btn3.Enabled:= false;
btn5.Enabled:= false;
edt1.Enabled:= False;
end;

procedure TKategori3.bersih;
begin
edt1.Clear;
end;

procedure TKategori3.FormShow(Sender: TObject);
begin
posisiawal;
end;

procedure TKategori3.btn6Click(Sender: TObject);
begin
edt1.Enabled:= True;
btn1.Enabled:= True;
btn2.Enabled:= False;
btn3.Enabled:= False;
btn5.Enabled:= True;
btn6.Enabled:= False;
end;

procedure TKategori3.btn4Click(Sender: TObject);
begin
edt1.Clear;
btn1.Enabled:= True;
btn5.Enabled:= True;
btn2.Enabled:= False;
btn3.Enabled:= False;

end;

end.
