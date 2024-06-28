unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  frxDBSet, Db, frxClass, ADODB;

type
  TReportData = class(TDataModule)
    Customers: TADOTable;
    CustomersCustNo: TFloatField;
    CustomersCompany: TStringField;
    CustomersAddr1: TStringField;
    CustomersAddr2: TStringField;
    CustomersCity: TStringField;
    CustomersState: TStringField;
    CustomersZip: TStringField;
    CustomersCountry: TStringField;
    CustomersPhone: TStringField;
    CustomersFAX: TStringField;
    CustomersTaxRate: TFloatField;
    CustomersContact: TStringField;
    CustomersLastInvoiceDate: TDateTimeField;
    Orders: TADOTable;
    OrdersOrderNo: TFloatField;
    OrdersCustNo: TFloatField;
    OrdersCustCompany: TStringField;
    OrdersSaleDate: TDateTimeField;
    OrdersShipDate: TDateTimeField;
    OrdersEmpNo: TIntegerField;
    OrdersShipToContact: TStringField;
    OrdersShipToAddr1: TStringField;
    OrdersShipToAddr2: TStringField;
    OrdersShipToCity: TStringField;
    OrdersShipToState: TStringField;
    OrdersShipToZip: TStringField;
    OrdersShipToCountry: TStringField;
    OrdersShipToPhone: TStringField;
    OrdersShipVIA: TStringField;
    OrdersPO: TStringField;
    OrdersTerms: TStringField;
    OrdersPaymentMethod: TStringField;
    OrdersItemsTotal: TCurrencyField;
    OrdersTaxRate: TFloatField;
    OrdersFreight: TCurrencyField;
    OrdersAmountPaid: TCurrencyField;
    LineItems: TADOTable;
    LineItemsOrderNo: TFloatField;
    LineItemsItemNo: TFloatField;
    LineItemsPartNo: TFloatField;
    LineItemsPartName: TStringField;
    LineItemsQty: TIntegerField;
    LineItemsPrice: TCurrencyField;
    LineItemsDiscount: TFloatField;
    LineItemsTotal: TCurrencyField;
    LineItemsExtendedPrice: TCurrencyField;
    Parts: TADOTable;
    PartsPartNo: TFloatField;
    PartsVendorNo: TFloatField;
    PartsDescription: TStringField;
    PartsOnHand: TFloatField;
    PartsOnOrder: TFloatField;
    PartsCost: TCurrencyField;
    PartsListPrice: TCurrencyField;
    CustomerSource: TDataSource;
    OrderSource: TDataSource;
    LineItemSource: TDataSource;
    PartSource: TDataSource;
    RepQuery: TADOQuery;
    RepQuerySource: TDataSource;
    CustomersDS: TfrxDBDataset;
    OrdersDS: TfrxDBDataset;
    ItemsDS: TfrxDBDataset;
    PartDS: TfrxDBDataset;
    QueryDS: TfrxDBDataset;
    Bio: TADOTable;
    BioSource: TDataSource;
    BioDS: TfrxDBDataset;
    Country: TADOTable;
    CountrySource: TDataSource;
    CountryDS: TfrxDBDataset;
    Cross: TADOTable;
    CrossSource: TDataSource;
    CrossDS: TfrxDBDataset;
    ADOConnection1: TADOConnection;
    RepQueryaCustNo: TFloatField;
    RepQueryCompany: TWideStringField;
    RepQueryAddr1: TWideStringField;
    RepQueryAddr2: TWideStringField;
    RepQueryCity: TWideStringField;
    RepQueryState: TWideStringField;
    RepQueryZip: TWideStringField;
    RepQueryCountry: TWideStringField;
    RepQueryPhone: TWideStringField;
    RepQueryFAX: TWideStringField;
    RepQueryaTaxRate: TFloatField;
    RepQueryContact: TWideStringField;
    RepQueryLastInvoiceDate: TDateTimeField;
    RepQuerybOrderNo: TFloatField;
    RepQuerybCustNo: TFloatField;
    RepQuerySaleDate: TDateTimeField;
    RepQueryShipDate: TDateTimeField;
    RepQueryEmpNo: TIntegerField;
    RepQueryShipToContact: TWideStringField;
    RepQueryShipToAddr1: TWideStringField;
    RepQueryShipToAddr2: TWideStringField;
    RepQueryShipToCity: TWideStringField;
    RepQueryShipToState: TWideStringField;
    RepQueryShipToZip: TWideStringField;
    RepQueryShipToCountry: TWideStringField;
    RepQueryShipToPhone: TWideStringField;
    RepQueryShipVIA: TWideStringField;
    RepQueryPO: TWideStringField;
    RepQueryTerms: TWideStringField;
    RepQueryPaymentMethod: TWideStringField;
    RepQueryItemsTotal: TFloatField;
    RepQuerybTaxRate: TFloatField;
    RepQueryFreight: TFloatField;
    RepQueryAmountPaid: TFloatField;
    RepQuerycOrderNo: TFloatField;
    RepQueryItemNo: TFloatField;
    RepQuerycPartNo: TFloatField;
    RepQueryQty: TIntegerField;
    RepQueryDiscount: TFloatField;
    RepQuerydPartNo: TFloatField;
    RepQueryVendorNo: TFloatField;
    RepQueryDescription: TWideStringField;
    RepQueryOnHand: TFloatField;
    RepQueryOnOrder: TFloatField;
    RepQueryCost: TFloatField;
    RepQueryListPrice: TFloatField;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ReportData: TReportData;

implementation

{$R *.DFM}

procedure TReportData.DataModuleCreate(Sender: TObject);
begin
//  Cross.DatabaseName := ExtractFilePath(Application.ExeName);
end;

end.
