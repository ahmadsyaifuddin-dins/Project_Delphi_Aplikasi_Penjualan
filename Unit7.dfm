object Kustomer7: TKustomer7
  Left = 172
  Top = 136
  Width = 857
  Height = 579
  Caption = 'KUSTOMER'
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
    Top = 96
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
    Top = 128
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
    Top = 160
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
    Top = 192
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
    Top = 224
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
  object lbl1: TLabel
    Left = 184
    Top = 256
    Width = 47
    Height = 16
    Caption = 'Member'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lbl2: TLabel
    Left = 416
    Top = 256
    Width = 53
    Height = 16
    Caption = 'DISKON :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lbl3: TLabel
    Left = 480
    Top = 256
    Width = 87
    Height = 16
    Caption = 'Terisi Otomatis'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object edt1: TEdit
    Left = 288
    Top = 96
    Width = 297
    Height = 24
    TabOrder = 0
  end
  object edt2: TEdit
    Left = 288
    Top = 128
    Width = 297
    Height = 24
    TabOrder = 1
  end
  object edt3: TEdit
    Left = 288
    Top = 160
    Width = 297
    Height = 24
    TabOrder = 2
  end
  object edt4: TEdit
    Left = 288
    Top = 192
    Width = 297
    Height = 24
    TabOrder = 3
  end
  object edt5: TEdit
    Left = 288
    Top = 224
    Width = 297
    Height = 24
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
    TitleFont.Height = -13
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
  object btn6: TButton
    Left = 88
    Top = 304
    Width = 75
    Height = 25
    Caption = 'NEW'
    TabOrder = 9
    OnClick = btn6Click
  end
  object btn4: TButton
    Left = 472
    Top = 304
    Width = 75
    Height = 25
    Caption = 'RESET'
    TabOrder = 10
    OnClick = btn4Click
  end
  object btn5: TButton
    Left = 716
    Top = 304
    Width = 75
    Height = 25
    Caption = 'SEARCH'
    TabOrder = 11
  end
  object btn7: TButton
    Left = 648
    Top = 352
    Width = 75
    Height = 25
    Caption = 'REPORT'
    TabOrder = 12
    OnClick = btn7Click
  end
  object edt10: TEdit
    Left = 568
    Top = 304
    Width = 121
    Height = 24
    TabOrder = 13
    OnChange = edt10Change
  end
  object cbb1: TComboBox
    Left = 288
    Top = 256
    Width = 113
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemHeight = 16
    ParentFont = False
    TabOrder = 14
    Text = '-- Pilih --'
    OnChange = cbb1Change
    Items.Strings = (
      'Yes'
      'No')
  end
end
