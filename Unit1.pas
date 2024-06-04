unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, jpeg, ExtCtrls, Mask;

type
  TUtama1 = class(TForm)
    mm1: TMainMenu;
    DD1: TMenuItem;
    DATAMASTER1: TMenuItem;
    RANSAKSI1: TMenuItem;
    LAPORAN1: TMenuItem;
    LOGIN1: TMenuItem;
    LOGOUT1: TMenuItem;
    KATEGORI1: TMenuItem;
    SATUAN1: TMenuItem;
    SUPPLIER1: TMenuItem;
    KUSTOMER1: TMenuItem;
    PENJUALAN1: TMenuItem;
    PEMBELIAN1: TMenuItem;
    LAPORANPENJUALAN1: TMenuItem;
    LAPORANSTOKBARANG1: TMenuItem;
    LAPORANBARANG1: TMenuItem;
    img1: TImage;
    Label1: TLabel;
    edt_tanggal: TEdit;
    procedure LOGIN1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure KATEGORI1Click(Sender: TObject);
    procedure LOGOUT1Click(Sender: TObject);
    procedure SATUAN1Click(Sender: TObject);
    procedure SUPPLIER1Click(Sender: TObject);
    procedure KUSTOMER1Click(Sender: TObject);
    procedure PENJUALAN1Click(Sender: TObject);
    procedure PEMBELIAN1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Utama1: TUtama1;

implementation

uses Unit2, Unit3, Unit5, Unit6, Unit7, Unit8, Unit9;

{$R *.dfm}







procedure TUtama1.FormShow(Sender: TObject);
begin
  mm1.Items[1].Visible:= False;
  mm1.Items[2].Visible:= False;
  mm1.Items[3].Visible:= False;
end;

procedure TUtama1.LOGIN1Click(Sender: TObject);
begin
Login2.Show;
end;

procedure TUtama1.KATEGORI1Click(Sender: TObject);
begin
Kategori3.Show;
end;

procedure TUtama1.LOGOUT1Click(Sender: TObject);
begin
mm1.Items[1].Visible:= False;
mm1.Items[2].Visible:= False;
mm1.Items[3].Visible:= False;
end;

procedure TUtama1.SATUAN1Click(Sender: TObject);
begin
Satuan5.Show;
end;

procedure TUtama1.SUPPLIER1Click(Sender: TObject);
begin
Supplier6.Show;
end;

procedure TUtama1.KUSTOMER1Click(Sender: TObject);
begin
Kustomer7.Show;
end;

procedure TUtama1.PENJUALAN1Click(Sender: TObject);
begin
Penjualan8.Show;
end;

procedure TUtama1.PEMBELIAN1Click(Sender: TObject);
begin
Pembelian9.Show;
end;

procedure TUtama1.FormCreate(Sender: TObject);
begin
  LongDateFormat := 'mm/dd/yyyy';
  edt_tanggal.Text := 'Hari ini ' + FormatDateTime('dddd, dd mmmm yyyy', Date);
end;


end.
