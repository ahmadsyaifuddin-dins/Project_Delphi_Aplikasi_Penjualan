
{******************************************}
{                                          }
{             FastReport v4.0              }
{       PSOFT Barcode Add-in object        }
{           http://www.psoft.sk            }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxPBarcode;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, EanKod, EanSpecs, frxClass, ExtCtrls
{$IFDEF Delphi6}
, Variants
{$ENDIF};
  

type
  TfrxPBarCodeObject = class(TComponent);  // fake component

  TfrxPBarCodeView = class(TfrxView)
  private
    FBarCode: TEan;
    FExpression: String;
    FText: String;
    FLinesColor: TColor;
    FBarType: TTypBarCode;
    FRotation: Integer;
    FFontAutoSize: Boolean;
    FCalcCheckSum: Boolean;
    FShowText: Boolean;
    function GetPDF417: TpsPDF417;
    function GetSecurity: Boolean;
    function GetHorzLines: TBarcodeHorzLines;
    function GetStartStopLine: Boolean;
    function GetTrasparent: Boolean;
    procedure SetPDF417(const Value: TpsPDF417);
    procedure SetSecurity(const Value: Boolean);
    procedure SetHorzLines(const Value: TBarcodeHorzLines);
    procedure SetStartStopLines(const Value: Boolean);
    procedure SetTrasparent(const Value: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended); override;
    procedure GetData; override;
    class function GetDescription: String; override;
    property BarCode: TEan read FBarCode;
  published
    property HorzLines: TBarcodeHorzLines read GetHorzLines write SetHorzLines;
    property Security: Boolean read GetSecurity write SetSecurity;
    property PDF417: TpsPDF417 read GetPDF417 write SetPDF417;
    property StartStopLines: Boolean read GetStartStopLine write SetStartStopLines;
    property Trasparent: Boolean read GetTrasparent write SetTrasparent;
    property LinesColor: TColor read FLinesColor write FLinesColor default clBlack;
    property BarType: TTypBarCode read FBarType write FBarType;
    property Rotation: Integer read FRotation write FRotation;
    property Font;
    property FontAutoSize: Boolean read FFontAutoSize write FFontAutoSize default True;
    property CalcCheckSum: Boolean read FCalcCheckSum write FCalcCheckSum default False;
    property ShowText: Boolean read FShowText write FShowText default True;
    property Color;
    property DataField;
    property DataSet;
    property DataSetName;
    property Expression: String read FExpression write FExpression;
    property Frame;
    property Text: String read FText write FText;
  end;


implementation

uses
{$IFNDEF NO_EDITORS}
  frxPBarcodeEditor,
{$ENDIF}
  frxPBarcodeRTTI, frxDsgnIntf, frxRes;



{ TfrxPBarCodeView }

constructor TfrxPBarCodeView.Create(AOwner: TComponent);
begin
  inherited;
  FBarCode := TEan.Create(nil);
  FLinesColor := clBlack;
  FFontAutoSize := True;
  FShowText := True;
end;

destructor TfrxPBarCodeView.Destroy;
begin
  FBarCode.Free;
  inherited Destroy;
end;

class function TfrxPBarCodeView.GetDescription: String;
begin
  Result := 'PSOFT Barcode object';
end;

procedure TfrxPBarCodeView.Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX,
  OffsetY: Extended);
begin
  FBarCode.LinesColor := FLinesColor;
  FBarCode.BackgroundColor := Color;
  FBarCode.Transparent := Color = clNone;

  FBarCode.Angle := FRotation;
  FBarCode.Font.Assign(Font);
  FBarCode.FontAutoSize := FFontAutoSize;

  FBarCode.AutoCheckDigit := FCalcCheckSum;
  FBarCode.TypBarCode := FBarType;
  if FText <> '' then
    FBarCode.BarCode := FText;
  FBarcode.ShowLabels := FShowText;

  BeginDraw(Canvas, ScaleX, ScaleY, OffsetX, OffsetY);
  PaintBarCode(Canvas, Rect(FX, FY, FX1, FY1), FBarCode);
  DrawFrame;
end;

procedure TfrxPBarCodeView.GetData;
begin
  inherited;
  if IsDataField then
    FText := DataSet.Value[DataField]
  else if FExpression <> '' then
    FText := Report.Calc(FExpression);
end;


function TfrxPBarCodeView.GetPDF417: TpsPDF417;
begin
  Result := FBarCode.PDF417;
end;

procedure TfrxPBarCodeView.SetPDF417(const Value: TpsPDF417);
begin
  FBarCode.PDF417 := Value;
end;

function TfrxPBarCodeView.GetSecurity: Boolean;
begin
  Result := FBarCode.Security;
end;

procedure TfrxPBarCodeView.SetSecurity(const Value: Boolean);
begin
  FBarCode.Security := Value;
end;

function TfrxPBarCodeView.GetHorzLines: TBarcodeHorzLines;
begin
  Result := FBarCode.HorzLines;
end;

procedure TfrxPBarCodeView.SetHorzLines(const Value: TBarcodeHorzLines);
begin
  FBarCode.HorzLines := Value;
end;

function TfrxPBarCodeView.GetStartStopLine: Boolean;
begin
  Result := FBarCode.StartStopLines;
end;

procedure TfrxPBarCodeView.SetStartStopLines(const Value: Boolean);
begin
  FBarCode.StartStopLines := Value;
end;

function TfrxPBarCodeView.GetTrasparent: Boolean;
begin
  Result := FBarCode.Transparent;
end;

procedure TfrxPBarCodeView.SetTrasparent(const Value: Boolean);
begin
  FBarCode.Transparent := Value;
end;

initialization
  frxObjects.RegisterObject1(TfrxPBarCodeView, nil, '', 'Other', 0, 23);



end.


//a925ad72a1da9d8873ffb721772811b5

//0f31356a91fea3356e5f76cdce90aa7b