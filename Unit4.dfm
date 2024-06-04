object DataModule4: TDataModule4
  OldCreateOrder = False
  Left = 166
  Top = 119
  Height = 174
  Width = 751
  object con1: TZConnection
    ControlsCodePage = cGET_ACP
    AutoEncodeStrings = False
    Connected = True
    HostName = 'localhost'
    Port = 3306
    Database = 'penjualan'
    User = 'root'
    Protocol = 'mysql'
    LibraryLocation = 
      'D:\AHMAD SYAIFUDDIN\Visual 2 (Delphi 7)\Project Delphi Aplikasi ' +
      'Penjualan\libmysql.dll'
    Left = 16
    Top = 8
  end
  object tbl_kategori: TZQuery
    Connection = con1
    Active = True
    SQL.Strings = (
      'select * from kategori')
    Params = <>
    Left = 80
    Top = 8
  end
  object ds_kategori: TDataSource
    DataSet = tbl_kategori
    Left = 80
    Top = 72
  end
  object tbl_satuan: TZQuery
    Connection = con1
    Active = True
    SQL.Strings = (
      'SELECT * FROM satuan')
    Params = <>
    Left = 144
    Top = 8
  end
  object ds_satuan: TDataSource
    DataSet = tbl_satuan
    Left = 144
    Top = 72
  end
  object ds_supplier: TDataSource
    DataSet = tbl_supplier
    Left = 208
    Top = 72
  end
  object tbl_supplier: TZQuery
    Connection = con1
    Active = True
    SQL.Strings = (
      'SELECT * FROM supplier')
    Params = <>
    Left = 208
    Top = 8
  end
  object tbl_kustomer: TZQuery
    Connection = con1
    Active = True
    SQL.Strings = (
      'SELECT * FROM kustomer')
    Params = <>
    Left = 272
    Top = 8
  end
  object tbl_penjualan: TZQuery
    Connection = con1
    Active = True
    SQL.Strings = (
      'SELECT * FROM penjualan')
    Params = <>
    Left = 344
    Top = 8
  end
  object ds_kustomer: TDataSource
    DataSet = tbl_kustomer
    Left = 272
    Top = 72
  end
  object ds_penjualan: TDataSource
    DataSet = tbl_penjualan
    Left = 344
    Top = 72
  end
  object ds_pembelian: TDataSource
    DataSet = tbl_pembelian
    Left = 416
    Top = 72
  end
  object tbl_pembelian: TZQuery
    Connection = con1
    Active = True
    SQL.Strings = (
      'SELECT * FROM pembelian')
    Params = <>
    Left = 416
    Top = 8
  end
  object tbl1: TZQuery
    Params = <>
    Left = 480
    Top = 8
  end
end
