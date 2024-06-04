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
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure dbgrd1CellClick(Column: TColumn);
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
  DataModule4.tbl_kategori.SQL.Clear;
  DataModule4.tbl_kategori.SQL.Add('insert into kategori values(null,"'+edt1.Text+'")');
  DataModule4.tbl_kategori.ExecSQL;

  DataModule4.tbl_kategori.SQL.Clear;
  DataModule4.tbl_kategori.SQL.Add('Select * From kategori');
  DataModule4.tbl_kategori.Open;
  ShowMessage('Data Berhasil Disimpan');
end;

procedure TKategori3.btn2Click(Sender: TObject);
begin
DataModule4.tbl_kategori.SQL.Clear;
DataModule4.tbl_kategori.SQL.Add('Update kategori set name="'+edt1.text+'" where id= "'+a+'"');
DataModule4.tbl_kategori.ExecSQL;

DataModule4.tbl_kategori.SQL.Clear;
DataModule4.tbl_kategori.SQL.Add('Select * from kategori');
DataModule4.tbl_kategori.Open;
ShowMessage('Data Berhasil Diupdate!');
end;

procedure TKategori3.btn3Click(Sender: TObject);
begin
DataModule4.tbl_kategori.SQL.Clear;
DataModule4.tbl_kategori.SQL.Add('Delete from kategori where id= "'+a+'"');
DataModule4.tbl_kategori.ExecSQL;

DataModule4.tbl_kategori.SQL.Clear;
DataModule4.tbl_kategori.SQL.Add('Select * from kategori');
DataModule4.tbl_kategori.Open;
ShowMessage('Data Berhasil Dihapus!');
end;

procedure TKategori3.dbgrd1CellClick(Column: TColumn);
begin
edt1.Text:= DataModule4.tbl_kategori.Fields[1].AsString;
a:= DataModule4.tbl_kategori.Fields[0].AsString;
end;

end.
