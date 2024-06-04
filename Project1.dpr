program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Utama1},
  Unit2 in 'Unit2.pas' {Login2},
  Unit3 in 'Unit3.pas' {Kategori3},
  Unit4 in 'Unit4.pas' {DataModule4: TDataModule},
  Unit5 in 'Unit5.pas' {Satuan5},
  Unit6 in 'Unit6.pas' {Supplier6},
  Unit7 in 'Unit7.pas' {Kustomer7},
  Unit8 in 'Unit8.pas' {Penjualan8},
  Unit9 in 'Unit9.pas' {Pembelian9},
  Unit10 in 'Unit10.pas' {Lap_penjualan10};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TUtama1, Utama1);
  Application.CreateForm(TLogin2, Login2);
  Application.CreateForm(TKategori3, Kategori3);
  Application.CreateForm(TDataModule4, DataModule4);
  Application.CreateForm(TSatuan5, Satuan5);
  Application.CreateForm(TSupplier6, Supplier6);
  Application.CreateForm(TKustomer7, Kustomer7);
  Application.CreateForm(TPenjualan8, Penjualan8);
  Application.CreateForm(TPembelian9, Pembelian9);
  Application.CreateForm(TLap_penjualan10, Lap_penjualan10);
  Application.Run;
end.
