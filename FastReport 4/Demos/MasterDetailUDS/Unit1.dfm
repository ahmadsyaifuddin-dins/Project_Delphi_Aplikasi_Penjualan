object Form1: TForm1
  Left = 272
  Top = 220
  Width = 244
  Height = 166
  Caption = 'Master-Detail demo'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object BitBtn1: TBitBtn
    Left = 80
    Top = 56
    Width = 75
    Height = 25
    Caption = 'Run!'
    TabOrder = 0
    OnClick = BitBtn1Click
  end
  object frxReport1: TfrxReport
    Version = '4.0a'
    DotMatrixReport = False
    IniFile = '\Software\Fast Reports'
    PreviewOptions.Buttons = [pbPrint, pbLoad, pbSave, pbExport, pbZoom, pbFind, pbOutline, pbPageSetup, pbTools, pbEdit, pbNavigator, pbExportQuick]
    PreviewOptions.Zoom = 1
    PrintOptions.Printer = 'Default'
    PrintOptions.PrintOnSheet = 0
    ReportOptions.CreateDate = 38806.5953306944
    ReportOptions.LastChange = 38806.5953306944
    ScriptLanguage = 'PascalScript'
    ScriptText.Strings = (
      'begin'
      ''
      'end.')
    Left = 4
    Top = 12
    Datasets = <
      item
        DataSet = DetailDS
        DataSetName = 'DetailDS'
      end
      item
        DataSet = MasterDS
        DataSetName = 'MasterDS'
      end>
    Variables = <>
    Style = <>
    object Page1: TfrxReportPage
      PaperWidth = 210
      PaperHeight = 297
      PaperSize = 9
      LeftMargin = 10
      RightMargin = 10
      TopMargin = 10
      BottomMargin = 10
      object MasterData1: TfrxMasterData
        Height = 20
        Top = 18.89765
        Width = 718.1107
        DataSet = MasterDS
        DataSetName = 'MasterDS'
        RowCount = 0
        object Memo1: TfrxMemoView
          Width = 260
          Height = 20
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          Memo.UTF8 = (
            '[MasterDS."name"]')
          ParentFont = False
        end
      end
      object DetailData1: TfrxDetailData
        Height = 20
        Top = 60.47248
        Width = 718.1107
        DataSet = DetailDS
        DataSetName = 'DetailDS'
        RowCount = 0
        object Memo2: TfrxMemoView
          Left = 24
          Width = 236
          Height = 20
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          Frame.Typ = [ftLeft, ftRight, ftTop, ftBottom]
          Memo.UTF8 = (
            '[DetailDS."name"]')
          ParentFont = False
        end
      end
    end
  end
  object MasterDS: TfrxUserDataSet
    UserName = 'MasterDS'
    OnCheckEOF = MasterDSCheckEOF
    OnFirst = MasterDSFirst
    OnNext = MasterDSNext
    OnPrior = MasterDSPrior
    Fields.Strings = (
      'name')
    OnGetValue = MasterDSGetValue
    Left = 40
    Top = 12
  end
  object DetailDS: TfrxUserDataSet
    UserName = 'DetailDS'
    OnCheckEOF = DetailDSCheckEOF
    OnFirst = DetailDSFirst
    OnNext = DetailDSNext
    OnPrior = DetailDSPrior
    Fields.Strings = (
      'mas_id'
      'name')
    OnGetValue = DetailDSGetValue
    Left = 76
    Top = 12
  end
end
