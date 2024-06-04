object Pembelian9: TPembelian9
  Left = 192
  Top = 125
  Width = 689
  Height = 553
  Caption = 'PEMBELIAN'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 140
    Height = 16
    Caption = 'HALAMAN PEMBELIAN'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 168
    Top = 32
    Width = 40
    Height = 16
    Caption = 'Invoice'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 168
    Top = 64
    Width = 29
    Height = 16
    Caption = 'Total'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 168
    Top = 96
    Width = 32
    Height = 16
    Caption = 'Bayar'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label5: TLabel
    Left = 168
    Top = 128
    Width = 51
    Height = 16
    Caption = 'Deskripsi'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label6: TLabel
    Left = 168
    Top = 160
    Width = 46
    Height = 16
    Caption = 'Tanggal'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label7: TLabel
    Left = 168
    Top = 192
    Width = 59
    Height = 17
    Caption = 'supplier id'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label8: TLabel
    Left = 168
    Top = 224
    Width = 39
    Height = 16
    Caption = 'user id'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object dbgrd1: TDBGrid
    Left = 16
    Top = 328
    Width = 649
    Height = 169
    DataSource = DataModule4.ds_pembelian
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    OnCellClick = dbgrd1CellClick
  end
  object edt1: TEdit
    Left = 272
    Top = 32
    Width = 217
    Height = 21
    TabOrder = 1
  end
  object edt2: TEdit
    Left = 272
    Top = 64
    Width = 217
    Height = 21
    TabOrder = 2
  end
  object edt3: TEdit
    Left = 272
    Top = 96
    Width = 217
    Height = 21
    TabOrder = 3
  end
  object edt4: TEdit
    Left = 272
    Top = 128
    Width = 217
    Height = 21
    TabOrder = 4
  end
  object btn1: TButton
    Left = 176
    Top = 280
    Width = 75
    Height = 25
    Caption = 'INSERT'
    TabOrder = 5
  end
  object btn2: TButton
    Left = 272
    Top = 280
    Width = 75
    Height = 25
    Caption = 'UPDATE'
    TabOrder = 6
  end
  object btn3: TButton
    Left = 368
    Top = 280
    Width = 75
    Height = 25
    Caption = 'DELETE'
    TabOrder = 7
  end
  object edt6: TEdit
    Left = 272
    Top = 192
    Width = 217
    Height = 21
    Enabled = False
    TabOrder = 8
  end
  object edt7: TEdit
    Left = 272
    Top = 224
    Width = 217
    Height = 21
    Enabled = False
    TabOrder = 9
  end
  object dtp1: TDateTimePicker
    Left = 272
    Top = 160
    Width = 217
    Height = 21
    Date = 45444.597614456020000000
    Time = 45444.597614456020000000
    TabOrder = 10
  end
end
