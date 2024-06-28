
{******************************************}
{                                          }
{             FastReport v4.0              }
{               OLE object                 }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxOLE;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OleCtnrs, StdCtrls, ExtCtrls, frxClass, ActiveX
{$IFDEF Delphi6}
, Variants
{$ENDIF}
;


type
  TfrxSizeMode = (fsmClip, fsmScale);

  TfrxOLEObject = class(TComponent)  // fake component
  end;


  TfrxOLEView = class(TfrxView)

  private
    FOleContainer: TOleContainer;
    FSizeMode: TfrxSizeMode;
    FStretched: Boolean;
    procedure ReadData(Stream: TStream);
    procedure SetStretched(const Value: Boolean);
    procedure WriteData(Stream: TStream);
  protected
    procedure DefineProperties(Filer: TFiler); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended); override;
    procedure GetData; override;
    class function GetDescription: String; override;
    property OleContainer: TOleContainer read FOleContainer;
  published
    property BrushStyle;
    property Color;
    property Cursor;
    property DataField;
    property DataSet;
    property DataSetName;
    property Frame;
    property SizeMode: TfrxSizeMode read FSizeMode write FSizeMode default fsmClip;
    property Stretched: Boolean read FStretched write SetStretched default False;
    property TagStr;
    property URL;
  end;

procedure frxAssignOle(ContFrom, ContTo: TOleContainer);


implementation

uses 
  frxOLERTTI, 
{$IFNDEF NO_EDITORS}
  frxOLEEditor, 
{$ENDIF}
  frxDsgnIntf, frxRes;


procedure frxAssignOle(ContFrom, ContTo: TOleContainer);
var
  st: TMemoryStream;
begin
  if (ContFrom = nil) or (ContFrom.OleObjectInterface = nil) then
  begin
    ContTo.DestroyObject;
    Exit;
  end;
  st := TMemoryStream.Create;
  ContFrom.SaveToStream(st);
  st.Position := 0;
  ContTo.LoadFromStream(st);
  st.Free;
end;

function HimetricToPixels(const P: TPoint): TPoint;
begin
  Result.X := MulDiv(P.X, Screen.PixelsPerInch, 2540);
  Result.Y := MulDiv(P.Y, Screen.PixelsPerInch, 2540);
end;


{ TfrxOLEView }

constructor TfrxOLEView.Create(AOwner: TComponent);
begin
  inherited;
  Font.Name := 'Tahoma';
  Font.Size := 8;

  FOleContainer := TOleContainer.Create(nil);
  with FOleContainer do
  begin
    Parent := frxParentForm;
    SendMessage(frxParentForm.Handle, WM_CREATEHANDLE, Integer(FOleContainer), 0);
    AllowInPlace := False;
    AutoVerbMenu := False;
    BorderStyle := bsNone;
    SizeMode := smClip;
  end;
end;

destructor TfrxOLEView.Destroy;
begin
  SendMessage(frxParentForm.Handle, WM_DESTROYHANDLE, Integer(FOleContainer), 0);
  FOleContainer.Free;
  inherited;
end;

class function TfrxOLEView.GetDescription: String;
begin
  Result := frxResources.Get('obOLE');
end;

procedure TfrxOLEView.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineBinaryProperty('OLE', ReadData, WriteData,
    OleContainer.OleObjectInterface <> nil);
end;

procedure TfrxOLEView.ReadData(Stream: TStream);
begin
  FOleContainer.LoadFromStream(Stream);
end;

procedure TfrxOLEView.WriteData(Stream: TStream);
begin
  FOleContainer.SaveToStream(Stream);
end;

procedure TfrxOLEView.SetStretched(const Value: Boolean);
var
  VS: TPoint;
begin
  FStretched := Value;
  if not Stretched then
    with FOleContainer do
      if OleObjectInterface <> nil then
      begin
        Run;
        VS.X := MulDiv(Width, 2540, Screen.PixelsPerInch);
        VS.Y := MulDiv(Height, 2540, Screen.PixelsPerInch);
        OleObjectInterface.SetExtent(DVASPECT_CONTENT, VS);
      end;
end;

procedure TfrxOLEView.Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended);
var
  DRect, R: TRect;
  W, H: Integer;
  ViewObject2: IViewObject2;
  S, ViewSize: TPoint;
begin
  BeginDraw(Canvas, ScaleX, ScaleY, OffsetX, OffsetY);
  DRect := Rect(FX, FY, FX1, FY1);
  OleContainer.Width := FDX;
  OleContainer.Height := FDY;
  DrawBackground;

  if (FDX > 0) and (FDY > 0) then
    with OleContainer do
      if OleObjectInterface <> nil then
        if Self.SizeMode = fsmClip then
          OleDraw(OleObjectInterface, DVASPECT_CONTENT, Canvas.Handle, DRect)
        else
        begin
          if Succeeded(OleObjectInterface.QueryInterface(IViewObject2,
             ViewObject2)) then
          begin
            ViewObject2.GetExtent(DVASPECT_CONTENT, -1, nil, ViewSize);
            W := DRect.Right - DRect.Left;
            H := DRect.Bottom - DRect.Top;
            S := HimetricToPixels(ViewSize);
            if W * S.Y > H * S.X then
            begin
              S.X := S.X * H div S.Y;
              S.Y := H;
            end
            else
            begin
              S.Y := S.Y * W div S.X;
              S.X := W;
            end;

            R.Left := DRect.Left + (W - S.X) div 2;
            R.Top := DRect.Top + (H - S.Y) div 2;
            R.Right := R.Left + S.X;
            R.Bottom := R.Top + S.Y;
            OleDraw(OleObjectInterface, DVASPECT_CONTENT, Canvas.Handle, R);
          end
        end
      else
        frxResources.ObjectImages.Draw(Canvas, FX + 1, FY + 2, 22);

  DrawFrame;
end;

procedure TfrxOLEView.GetData;
var
  s: TMemoryStream;
begin
  inherited;
  if IsDataField then
  begin
    s := TMemoryStream.Create;
    try
      DataSet.AssignBlobTo(DataField, s);
      FOleContainer.LoadFromStream(s);
    finally
      s.Free;
    end;
  end;
end;




initialization
  frxObjects.RegisterObject1(TfrxOLEView, nil, '', '', 0, 22);

end.



//0f31356a91fea3356e5f76cdce90aa7b