object Lap_barang12: TLap_barang12
  Left = 192
  Top = 152
  Width = 1000
  Height = 374
  Caption = 'Laporan Barang'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 8
    Top = 0
    Width = 53
    Height = 16
    Caption = 'BARANG'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 80
    Top = 8
    Width = 53
    Height = 14
    Caption = 'BARCODE'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 80
    Top = 40
    Width = 71
    Height = 14
    Caption = 'Nama Barang'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label5: TLabel
    Left = 80
    Top = 72
    Width = 55
    Height = 14
    Caption = 'Harga Jual'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label6: TLabel
    Left = 80
    Top = 104
    Width = 53
    Height = 14
    Caption = 'Harga Beli'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label7: TLabel
    Left = 80
    Top = 136
    Width = 25
    Height = 14
    Caption = 'Stok'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label8: TLabel
    Left = 80
    Top = 168
    Width = 61
    Height = 14
    Caption = 'Kategori ID'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label9: TLabel
    Left = 80
    Top = 200
    Width = 54
    Height = 14
    Caption = 'Satuan ID'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label10: TLabel
    Left = 80
    Top = 232
    Width = 40
    Height = 14
    Caption = 'User ID'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 80
    Top = 264
    Width = 59
    Height = 14
    Caption = 'Supplier ID'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object edt1: TEdit
    Left = 160
    Top = 8
    Width = 217
    Height = 24
    TabOrder = 0
  end
  object edt2: TEdit
    Left = 160
    Top = 40
    Width = 217
    Height = 24
    TabOrder = 1
  end
  object edt3: TEdit
    Left = 160
    Top = 72
    Width = 217
    Height = 24
    TabOrder = 2
  end
  object edt4: TEdit
    Left = 160
    Top = 104
    Width = 217
    Height = 24
    TabOrder = 3
  end
  object edt5: TEdit
    Left = 160
    Top = 136
    Width = 217
    Height = 24
    TabOrder = 4
  end
  object edt6: TEdit
    Left = 160
    Top = 168
    Width = 217
    Height = 24
    TabOrder = 5
  end
  object edt7: TEdit
    Left = 160
    Top = 200
    Width = 217
    Height = 24
    TabOrder = 6
  end
  object edt8: TEdit
    Left = 160
    Top = 232
    Width = 217
    Height = 24
    TabOrder = 7
  end
  object edt9: TEdit
    Left = 160
    Top = 264
    Width = 217
    Height = 24
    TabOrder = 8
  end
  object btn1: TButton
    Left = 480
    Top = 176
    Width = 75
    Height = 25
    Caption = 'INSERT'
    TabOrder = 9
    OnClick = btn1Click
  end
  object btn2: TButton
    Left = 480
    Top = 216
    Width = 75
    Height = 25
    Caption = 'UPDATE'
    TabOrder = 10
    OnClick = btn2Click
  end
  object btn3: TButton
    Left = 432
    Top = 256
    Width = 83
    Height = 25
    Caption = 'DELETE'
    TabOrder = 11
    OnClick = btn3Click
  end
  object btn4: TButton
    Left = 392
    Top = 216
    Width = 75
    Height = 25
    Caption = 'RESET'
    TabOrder = 12
    OnClick = btn4Click
  end
  object btn6: TButton
    Left = 392
    Top = 176
    Width = 75
    Height = 25
    Caption = 'NEW'
    TabOrder = 13
    OnClick = btn6Click
  end
  object btn5: TButton
    Left = 704
    Top = 176
    Width = 75
    Height = 25
    Caption = 'SEARCH'
    TabOrder = 14
  end
  object edt11: TEdit
    Left = 568
    Top = 176
    Width = 121
    Height = 24
    TabOrder = 15
    OnChange = edt11Change
  end
  object dbgrd1: TDBGrid
    Left = 392
    Top = 8
    Width = 577
    Height = 153
    DataSource = DataModule4.ds_barang
    TabOrder = 16
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -13
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    OnCellClick = dbgrd1CellClick
  end
  object btn7: TButton
    Left = 800
    Top = 176
    Width = 75
    Height = 25
    Caption = 'REPORT'
    TabOrder = 17
    OnClick = btn7Click
  end
end
