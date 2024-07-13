unit Unit5;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, DBGrids;

type
  TSatuan5 = class(TForm)
    Label1: TLabel;
    dbgrd1: TDBGrid;
    edt1: TEdit;
    Label2: TLabel;
    btn1: TButton;
    btn2: TButton;
    btn3: TButton;
    edt2: TEdit;
    Label3: TLabel;
    btn4: TButton;
    btn5: TButton;
    edt3: TEdit;
    btn6: TButton;
    btn7: TButton;
    procedure dbgrd1CellClick(Column: TColumn);
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btn6Click(Sender: TObject);
    procedure bersih;
    procedure posisiawal;
    procedure btn4Click(Sender: TObject);
    procedure btn5Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edt3Change(Sender: TObject);
    procedure btn7Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Satuan5: TSatuan5;
  a: string;

implementation

uses
  Unit4;

{$R *.dfm}


procedure TSatuan5.btn1Click(Sender: TObject);
begin
if edt1.Text = '' then
begin
ShowMessage('Nama Satuan Tidak Boleh Kosong!');
end;
if edt2.Text = '' then
begin
ShowMessage('Deskripsi Tidak Boleh Kosong!');
end else
if DataModule4.tbl_satuan.Locate('name',edt1.Text,[]) then
begin
ShowMessage('Nama Satuan '+edt1.Text+' Sudah Ada Didalam Sistem');
end else
Begin
// simpan
    with DataModule4.tbl_satuan do
    begin
      SQL.Clear;
      SQL.Add('INSERT INTO satuan (name, deskripsi) VALUES (:name, :deskripsi)');
      Params.ParamByName('name').AsString := edt1.Text;
      Params.ParamByName('deskripsi').AsString := edt2.Text;
      ExecSQL;
      SQL.Clear;
      SQL.Add('SELECT * FROM satuan');
      Open;
    end;
    ShowMessage('Data Berhasil Disimpan!');
  end;
posisiawal;
end;

procedure TSatuan5.btn2Click(Sender: TObject);
begin
if edt1.Text = '' then
  begin
    ShowMessage('Nama Satuan Tidak Boleh Kosong!');
    Exit;
  end;

  if edt2.Text = '' then
  begin
    ShowMessage('Deskripsi Tidak Boleh Kosong!');
    Exit;
  end;

  // Simpan nilai id ke variabel a
  a := DataModule4.tbl_satuan.FieldByName('id').AsString;

  // Kode update
  with DataModule4.tbl_satuan do
  begin
    SQL.Clear;
    SQL.Add('UPDATE satuan SET name = :name, deskripsi = :deskripsi WHERE id = :id');
    Params.ParamByName('name').AsString := edt1.Text;
    Params.ParamByName('deskripsi').AsString := edt2.Text;
    Params.ParamByName('id').AsString := a;
    ExecSQL;

    SQL.Clear;
    SQL.Add('SELECT * FROM satuan');
    Open;
  end;

  ShowMessage('Data Berhasil Diupdate!');

posisiawal;
end;

procedure TSatuan5.btn3Click(Sender: TObject);
begin
//kode delete
if MessageDlg('Apakah Anda Yakin Menghapus Data ini',mtWarning,[mbYes,mbNo],0)=mryes then
begin
with DataModule4.tbl_satuan do
begin
SQL.Clear;
SQL.Add('delete from satuan where id= "'+a+'"');
ExecSQL ;

SQL.Clear;
SQL.Add('select * from satuan');
Open;
end;
ShowMessage('Data Berhasil DiDelete!');
end else
begin

ShowMessage('Data Batal Dihapus!');

end;
posisiawal;
end;

procedure TSatuan5.dbgrd1CellClick(Column: TColumn);
begin
edt1.Text:= DataModule4.tbl_satuan.Fields[1].AsString;
edt2.Text:= DataModule4.tbl_satuan.Fields[2].AsString;
a:= DataModule4.tbl_satuan.Fields[0].AsString;

edt1.Enabled:= True;
edt2.Enabled:= True;
btn2.Enabled:= True;
btn3.Enabled:=True;
btn5.Enabled:= True;
btn6.Enabled:= False;
btn1.Enabled:= False;
end;

procedure TSatuan5.btn6Click(Sender: TObject);
begin
edt1.Enabled:= True;
edt2.Enabled:= True;
btn1.Enabled:= True;
btn2.Enabled:= False;
btn3.Enabled:= False;
btn5.Enabled:= True;
btn6.Enabled:= False;
end;

procedure TSatuan5.btn4Click(Sender: TObject);
begin
edt1.clear;
edt2.clear;
btn1.Enabled:= True;
btn5.Enabled:= True;
btn2.Enabled:= False;
btn3.Enabled:= False;
end;

procedure TSatuan5.btn5Click(Sender: TObject);
begin
with DataModule4.tbl_satuan do
begin
SQL.Clear;
SQL.Add('select * from satuan where name = "'+edt1.Text+'"');
Open;
end;
end;

procedure TSatuan5.bersih;
begin
edt1.Clear;
edt2.Clear;
end;

procedure TSatuan5.posisiawal;
begin
bersih;
edt1.Enabled:= False;
edt2.Enabled:= False;
btn6.Enabled:= True;
btn1.Enabled:= false;
btn2.Enabled:= false;
end;

procedure TSatuan5.FormShow(Sender: TObject);
begin
posisiawal;
end;

procedure TSatuan5.edt3Change(Sender: TObject);
begin
with DataModule4.tbl_satuan do
begin
SQL.Clear;
SQL.Add('select * from satuan where name like "%'+edt3.Text+'%"');
Open;
end;
end;

procedure TSatuan5.btn7Click(Sender: TObject);
begin
DataModule4.ReportSat.ShowReport();
end;

end.








































































































































































































































































































































































































































































































































































































































































































































































































































































































































































