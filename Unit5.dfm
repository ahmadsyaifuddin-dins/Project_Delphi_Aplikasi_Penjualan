object Satuan5: TSatuan5
  Left = 311
  Top = 160
  Width = 704
  Height = 480
  Caption = 'SATUAN'
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
    Left = 16
    Top = 8
    Width = 120
    Height = 16
    Caption = 'HALAMAN SATUAN'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 208
    Top = 80
    Width = 33
    Height = 16
    Caption = 'NAME'
  end
  object Label3: TLabel
    Left = 208
    Top = 112
    Width = 61
    Height = 16
    Caption = 'DESKRIPSI'
  end
  object dbgrd1: TDBGrid
    Left = 64
    Top = 208
    Width = 417
    Height = 129
    DataSource = DataModule4.ds_satuan
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -13
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    OnCellClick = dbgrd1CellClick
  end
  object edt1: TEdit
    Left = 280
    Top = 80
    Width = 121
    Height = 24
    TabOrder = 1
  end
  object btn1: TButton
    Left = 200
    Top = 168
    Width = 75
    Height = 25
    Caption = 'INSERT'
    TabOrder = 2
    OnClick = btn1Click
  end
  object btn2: TButton
    Left = 296
    Top = 168
    Width = 75
    Height = 25
    Caption = 'UPDATE'
    TabOrder = 3
    OnClick = btn2Click
  end
  object btn3: TButton
    Left = 392
    Top = 168
    Width = 75
    Height = 25
    Caption = 'DELETE'
    TabOrder = 4
    OnClick = btn3Click
  end
  object edt2: TEdit
    Left = 280
    Top = 112
    Width = 177
    Height = 24
    TabOrder = 5
  end
  object btn4: TButton
    Left = 488
    Top = 168
    Width = 75
    Height = 25
    Caption = 'RESET'
    TabOrder = 6
    OnClick = btn4Click
  end
  object btn5: TButton
    Left = 400
    Top = 352
    Width = 75
    Height = 25
    Caption = 'SEARCH'
    TabOrder = 7
    OnClick = btn5Click
  end
  object edt3: TEdit
    Left = 208
    Top = 352
    Width = 169
    Height = 24
    TabOrder = 8
    OnChange = edt3Change
  end
  object btn6: TButton
    Left = 104
    Top = 168
    Width = 75
    Height = 25
    Caption = 'NEW'
    TabOrder = 9
    OnClick = btn6Click
  end
  object btn7: TButton
    Left = 488
    Top = 216
    Width = 75
    Height = 25
    Caption = 'Report'
    TabOrder = 10
    OnClick = btn7Click
  end
end
