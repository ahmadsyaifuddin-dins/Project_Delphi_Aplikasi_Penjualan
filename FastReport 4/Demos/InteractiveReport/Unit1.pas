unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  frxClass, StdCtrls, frxDBSet, Db, DBTables;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Customers: TTable;
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
    DetailQuery: TQuery;
    DetailQueryCustNo: TFloatField;
    DetailQueryCompany: TStringField;
    DetailQueryAddr1: TStringField;
    DetailQueryAddr2: TStringField;
    DetailQueryCity: TStringField;
    DetailQueryState: TStringField;
    DetailQueryZip: TStringField;
    DetailQueryCountry: TStringField;
    DetailQueryPhone: TStringField;
    DetailQueryFAX: TStringField;
    DetailQueryTaxRate: TFloatField;
    DetailQueryContact: TStringField;
    DetailQueryLastInvoiceDate: TDateTimeField;
    DetailQueryOrderNo: TFloatField;
    DetailQueryCustNo_1: TFloatField;
    DetailQuerySaleDate: TDateTimeField;
    DetailQueryShipDate: TDateTimeField;
    DetailQueryEmpNo: TIntegerField;
    DetailQueryShipToContact: TStringField;
    DetailQueryShipToAddr1: TStringField;
    DetailQueryShipToAddr2: TStringField;
    DetailQueryShipToCity: TStringField;
    DetailQueryShipToState: TStringField;
    DetailQueryShipToZip: TStringField;
    DetailQueryShipToCountry: TStringField;
    DetailQueryShipToPhone: TStringField;
    DetailQueryShipVIA: TStringField;
    DetailQueryPO: TStringField;
    DetailQueryTerms: TStringField;
    DetailQueryPaymentMethod: TStringField;
    DetailQueryItemsTotal: TCurrencyField;
    DetailQueryTaxRate_1: TFloatField;
    DetailQueryFreight: TCurrencyField;
    DetailQueryAmountPaid: TCurrencyField;
    DetailQueryOrderNo_1: TFloatField;
    DetailQueryItemNo: TFloatField;
    DetailQueryPartNo: TFloatField;
    DetailQueryQty: TIntegerField;
    DetailQueryDiscount: TFloatField;
    DetailQueryPartNo_1: TFloatField;
    DetailQueryVendorNo: TFloatField;
    DetailQueryDescription: TStringField;
    DetailQueryOnHand: TFloatField;
    DetailQueryOnOrder: TFloatField;
    DetailQueryCost: TCurrencyField;
    DetailQueryListPrice: TCurrencyField;
    CustomersDS: TfrxDBDataset;
    DetailQueryDS: TfrxDBDataset;
    MainReport: TfrxReport;
    DetailReport: TfrxReport;
    procedure Button1Click(Sender: TObject);
    procedure MainReportClickObject(View: TfrxView;
      Button: TMouseButton; Shift: TShiftState; var Modified: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
begin
  MainReport.ShowReport;
end;

procedure TForm1.MainReportClickObject(View: TfrxView;
  Button: TMouseButton; Shift: TShiftState; var Modified: Boolean);
begin
  if View.Name = 'Memo8' then
  begin
    DetailQuery.Close;
    DetailQuery.ParamByName('custno').Text := View.TagStr;
    DetailReport.ShowReport;
  end;
end;

end.
