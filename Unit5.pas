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
  Satuan5: TSatuan5;
  b: string;

implementation

uses
  Unit4;

{$R *.dfm}


procedure TSatuan5.btn1Click(Sender: TObject);
begin
DataModule4.tbl_satuan.SQL.Clear;
DataModule4.tbl_satuan.SQL.Add('INSERT INTO satuan (name, deskripsi) VALUES (' + QuotedStr(edt1.Text) + ', ' + QuotedStr(edt2.Text) + ')');
DataModule4.tbl_satuan.ExecSQL;

DataModule4.tbl_satuan.SQL.Clear;
DataModule4.tbl_satuan.SQL.Add('Select * From satuan');
DataModule4.tbl_satuan.Open;
ShowMessage('Data Berhasil Disimpan');
end;

procedure TSatuan5.btn2Click(Sender: TObject);
begin
DataModule4.tbl_satuan.SQL.Clear;
DataModule4.tbl_satuan.SQL.Add('UPDATE satuan SET name=' + QuotedStr(edt1.Text) + ', deskripsi=' + QuotedStr(edt2.Text) + ' WHERE id=' + QuotedStr(b));
DataModule4.tbl_satuan.SQL.Clear;
DataModule4.tbl_satuan.SQL.Add('Select * from satuan');
DataModule4.tbl_satuan.Open;
ShowMessage('Data Berhasil Diupdate!');
end;

procedure TSatuan5.btn3Click(Sender: TObject);
begin
DataModule4.tbl_satuan.SQL.Clear;
DataModule4.tbl_satuan.SQL.Add('DELETE FROM satuan WHERE id=' + QuotedStr(b));
DataModule4.tbl_satuan.ExecSQL;

DataModule4.tbl_satuan.SQL.Clear;
DataModule4.tbl_satuan.SQL.Add('Select * from satuan');
DataModule4.tbl_satuan.Open;
ShowMessage('Data Berhasil Dihapus!');
end;

procedure TSatuan5.dbgrd1CellClick(Column: TColumn);
begin
edt1.Text:= DataModule4.tbl_satuan.Fields[1].AsString;
edt2.Text:= DataModule4.tbl_satuan.Fields[2].AsString;
b:= DataModule4.tbl_satuan.Fields[0].AsString;
end;

end.
