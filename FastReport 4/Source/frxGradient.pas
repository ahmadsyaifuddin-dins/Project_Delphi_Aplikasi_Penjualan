
{******************************************}
{                                          }
{             FastReport v4.0              }
{             Gradient object              }
{                                          }
{  (former RoundRect plus Add-in object)   }
{     (C) Guilbaud Olivier for FR 2.4      }
{        mailto: golivier@free.fr          }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxGradient;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, frxClass
{$IFDEF Delphi6}
, Variants
{$ENDIF};

type
  TfrxGradientObject = class(TComponent);  // fake component

  TfrxGradientStyle = (gsHorizontal, gsVertical, gsElliptic, gsRectangle,
    gsVertCenter, gsHorizCenter);

  TfrxGradientView = class(TfrxView)
  private
    FBeginColor: TColor;
    FEndColor: TColor;
    FStyle: TfrxGradientStyle;
    procedure DrawGradient(X, Y, X1, Y1: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    procedure Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended); override;
    class function GetDescription: String; override;
  published
    property BeginColor: TColor read FBeginColor write FBeginColor default clWhite;
    property EndColor: TColor read FEndColor write FEndColor default clGray;
    property Style: TfrxGradientStyle read FStyle write FStyle;
    property Frame;
  end;


implementation

uses frxGradientRTTI, frxDsgnIntf, frxRes;


constructor TfrxGradientView.Create(AOwner: TComponent);
begin
  inherited;
  FBeginColor := clWhite;
  FEndColor := clGray;
end;

class function TfrxGradientView.GetDescription: String;
begin
  Result := frxResources.Get('obGrad');
end;

procedure TfrxGradientView.DrawGradient(X, Y, X1, Y1: Integer);
var
  FromR, FromG, FromB: Integer;
  DiffR, DiffG, DiffB: Integer;
  ox, oy, dx, dy: Integer;

  procedure DoHorizontal(fr, fg, fb, dr, dg, db: Integer);
  var
    ColorRect: TRect;
    I: Integer;
    R, G, B: Byte;
  begin
    ColorRect.Top := oy;
    ColorRect.Bottom := oy + dy;
    for I := 0 to 255 do
    begin
      ColorRect.Left := MulDiv (I, dx, 256) + ox;
      ColorRect.Right := MulDiv (I + 1, dx, 256) + ox;
      R := fr + MulDiv(I, dr, 255);
      G := fg + MulDiv(I, dg, 255);
      B := fb + MulDiv(I, db, 255);
      FCanvas.Brush.Color := RGB(R, G, B);
      FCanvas.FillRect(ColorRect);
    end;
  end;

  procedure DoVertical(fr, fg, fb, dr, dg, db: Integer);
  var
    ColorRect: TRect;
    I: Integer;
    R, G, B: Byte;
  begin
    ColorRect.Left := ox;
    ColorRect.Right := ox + dx;
    for I := 0 to 255 do
    begin
      ColorRect.Top := MulDiv (I, dy, 256) + oy;
      ColorRect.Bottom := MulDiv (I + 1, dy, 256) + oy;
      R := fr + MulDiv(I, dr, 255);
      G := fg + MulDiv(I, dg, 255);
      B := fb + MulDiv(I, db, 255);
      FCanvas.Brush.Color := RGB(R, G, B);
      FCanvas.FillRect(ColorRect);
    end;
  end;

  procedure DoElliptic(fr, fg, fb, dr, dg, db: Integer);
  var
    I: Integer;
    R, G, B: Byte;
    Pw, Ph: Double;
    x1, y1, x2, y2: Double;
    bmp: TBitmap;
  begin
    bmp := TBitmap.Create;
    bmp.Width := dx;
    bmp.Height := dy;
    bmp.Canvas.Pen.Style := psClear;

    x1 := 0 - (dx / 4);
    x2 := dx + (dx / 4);
    y1 := 0 - (dy / 4);
    y2 := dy + (dy / 4);
    Pw := ((dx / 4) + (dx / 2)) / 155;
    Ph := ((dy / 4) + (dy / 2)) / 155;
    for I := 0 to 155 do
    begin
      x1 := x1 + Pw;
      x2 := X2 - Pw;
      y1 := y1 + Ph;
      y2 := y2 - Ph;
      R := fr + MulDiv(I, dr, 155);
      G := fg + MulDiv(I, dg, 155);
      B := fb + MulDiv(I, db, 155);
      bmp.Canvas.Brush.Color := R or (G shl 8) or (b shl 16);
      bmp.Canvas.Ellipse(Trunc(x1), Trunc(y1), Trunc(x2), Trunc(y2));
    end;

    FCanvas.Draw(ox, oy, bmp);
    bmp.Free;
  end;

  procedure DoRectangle(fr, fg, fb, dr, dg, db: Integer);
  var
    I: Integer;
    R, G, B: Byte;
    Pw, Ph: Real;
    x1, y1, x2, y2: Double;
  begin
    FCanvas.Pen.Style := psClear;
    FCanvas.Pen.Mode := pmCopy;
    x1 := 0 + ox;
    x2 := ox + dx;
    y1 := 0 + oy;
    y2 := oy + dy;
    Pw := (dx / 2) / 255;
    Ph := (dy / 2) / 255;
    for I := 0 to 255 do
    begin
      x1 := x1 + Pw;
      x2 := X2 - Pw;
      y1 := y1 + Ph;
      y2 := y2 - Ph;
      R := fr + MulDiv(I, dr, 255);
      G := fg + MulDiv(I, dg, 255);
      B := fb + MulDiv(I, db, 255);
      FCanvas.Brush.Color := RGB(R, G, B);
      FCanvas.FillRect(Rect(Trunc(x1), Trunc(y1), Trunc(x2), Trunc(y2)));
    end;
    FCanvas.Pen.Style := psSolid;
  end;

  procedure DoVertCenter(fr, fg, fb, dr, dg, db: Integer);
  var
    ColorRect: TRect;
    I: Integer;
    R, G, B: Byte;
    Haf: Integer;
  begin
    Haf := dy Div 2;
    ColorRect.Left := 0 + ox;
    ColorRect.Right := ox + dx;
    for I := 0 to Haf do
    begin
      ColorRect.Top := MulDiv(I, Haf, Haf) + oy;
      ColorRect.Bottom := MulDiv(I + 1, Haf, Haf) + oy;
      R := fr + MulDiv(I, dr, Haf);
      G := fg + MulDiv(I, dg, Haf);
      B := fb + MulDiv(I, db, Haf);
      FCanvas.Brush.Color := RGB(R, G, B);
      FCanvas.FillRect(ColorRect);
      ColorRect.Top := dy - (MulDiv (I, Haf, Haf)) + oy;
      ColorRect.Bottom := dy - (MulDiv (I + 1, Haf, Haf)) + oy;
      FCanvas.FillRect(ColorRect);
    end;
  end;

  procedure DoHorizCenter(fr, fg, fb, dr, dg, db: Integer);
  var
    ColorRect: TRect;
    I: Integer;
    R, G, B: Byte;
    Haf: Integer;
  begin
    Haf := dx Div 2;
    ColorRect.Top := 0 + oy;
    ColorRect.Bottom := oy + dy;
    for I := 0 to Haf do
    begin
      ColorRect.Left := MulDiv(I, Haf, Haf) + ox;
      ColorRect.Right := MulDiv(I + 1, Haf, Haf) + ox;
      R := fr + MulDiv(I, dr, Haf);
      G := fg + MulDiv(I, dg, Haf);
      B := fb + MulDiv(I, db, Haf);
      FCanvas.Brush.Color := RGB(R, G, B);
      FCanvas.FillRect(ColorRect);
      ColorRect.Left := dx - (MulDiv (I, Haf, Haf)) + ox;
      ColorRect.Right := dx - (MulDiv (I + 1, Haf, Haf)) + ox;
      FCanvas.FillRect(ColorRect);
    end;
  end;

begin
  ox := X;
  oy := Y;
  dx := X1 - X;
  dy := Y1 - Y;
  FromR := FBeginColor and $000000ff;
  FromG := (FBeginColor shr 8) and $000000ff;
  FromB := (FBeginColor shr 16) and $000000ff;
  DiffR := (FEndColor and $000000ff) - FromR;
  DiffG := ((FEndColor shr 8) and $000000ff) - FromG;
  DiffB := ((FEndColor shr 16) and $000000ff) - FromB;

  case FStyle of
    gsHorizontal:
      DoHorizontal(FromR, FromG, FromB, DiffR, DiffG, DiffB);
    gsVertical:
      DoVertical(FromR, FromG, FromB, DiffR, DiffG, DiffB);
    gsElliptic:
      DoElliptic(FromR, FromG, FromB, DiffR, DiffG, DiffB);
    gsRectangle:
      DoRectangle(FromR, FromG, FromB, DiffR, DiffG, DiffB);
    gsVertCenter:
      DoVertCenter(FromR, FromG, FromB, DiffR, DiffG, DiffB);
    gsHorizCenter:
      DoHorizCenter(FromR, FromG, FromB, DiffR, DiffG, DiffB);
  end;
end;

procedure TfrxGradientView.Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX,
  OffsetY: Extended);
begin
  BeginDraw(Canvas, ScaleX, ScaleY, OffsetX, OffsetY);
  DrawGradient(FX, FY, FX1, FY1);
  DrawFrame;
end;


initialization
  frxObjects.RegisterObject1(TfrxGradientView, nil, '', '', 0, 50);


end.


//0f31356a91fea3356e5f76cdce90aa7b