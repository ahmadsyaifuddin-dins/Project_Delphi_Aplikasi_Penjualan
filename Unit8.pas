unit Unit8;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, Grids, DBGrids, ComCtrls;

type
  TPenjualan8 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    edt1: TEdit;
    edt2: TEdit;
    edt3: TEdit;
    edt4: TEdit;
    dbgrd1: TDBGrid;
    btn1: TButton;
    btn2: TButton;
    btn3: TButton;
    edt6: TEdit;
    edt7: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    dtp1: TDateTimePicker;
    procedure dbgrd1CellClick(Column: TColumn);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Penjualan8: TPenjualan8;
  b: string;

implementation

uses
  Unit4;

{$R *.dfm}

procedure TPenjualan8.dbgrd1CellClick(Column: TColumn);
begin
edt1.Text:= DataModule4.tbl_penjualan.Fields[1].AsString;
edt2.Text:= DataModule4.tbl_penjualan.Fields[2].AsString;
edt3.Text:= DataModule4.tbl_penjualan.Fields[3].AsString;
edt4.Text:= DataModule4.tbl_penjualan.Fields[4].AsString;
dtp1.Date:= DataModule4.tbl_penjualan.Fields[5].AsDateTime;
edt6.Text:= DataModule4.tbl_penjualan.Fields[6].AsString;
edt7.Text:= DataModule4.tbl_penjualan.Fields[7].AsString;
b:= DataModule4.tbl_penjualan.Fields[0].AsString;
end;

end.
