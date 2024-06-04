object Kustomer7: TKustomer7
  Left = 173
  Top = 119
  Width = 663
  Height = 579
  Caption = 'KUSTOMER'
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
    Width = 136
    Height = 16
    Caption = 'HALAMAN KUSTOMER'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 184
    Top = 104
    Width = 19
    Height = 16
    Caption = 'NIK'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 184
    Top = 136
    Width = 33
    Height = 16
    Caption = 'Name'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 184
    Top = 168
    Width = 40
    Height = 16
    Caption = 'Alamat'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label5: TLabel
    Left = 184
    Top = 200
    Width = 25
    Height = 16
    Caption = 'Telp'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label6: TLabel
    Left = 184
    Top = 232
    Width = 31
    Height = 16
    Caption = 'Email'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object edt1: TEdit
    Left = 288
    Top = 104
    Width = 217
    Height = 21
    TabOrder = 0
  end
  object edt2: TEdit
    Left = 288
    Top = 136
    Width = 217
    Height = 21
    TabOrder = 1
  end
  object edt3: TEdit
    Left = 288
    Top = 168
    Width = 217
    Height = 21
    TabOrder = 2
  end
  object edt4: TEdit
    Left = 288
    Top = 200
    Width = 217
    Height = 21
    TabOrder = 3
  end
  object edt5: TEdit
    Left = 288
    Top = 232
    Width = 217
    Height = 21
    TabOrder = 4
  end
  object dbgrd1: TDBGrid
    Left = 8
    Top = 352
    Width = 625
    Height = 169
    DataSource = DataModule4.ds_kustomer
    TabOrder = 5
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    OnCellClick = dbgrd1CellClick
  end
  object btn1: TButton
    Left = 184
    Top = 304
    Width = 75
    Height = 25
    Caption = 'INSERT'
    TabOrder = 6
    OnClick = btn1Click
  end
  object btn2: TButton
    Left = 280
    Top = 304
    Width = 75
    Height = 25
    Caption = 'UPDATE'
    TabOrder = 7
    OnClick = btn2Click
  end
  object btn3: TButton
    Left = 376
    Top = 304
    Width = 75
    Height = 25
    Caption = 'DELETE'
    TabOrder = 8
    OnClick = btn3Click
  end
end
