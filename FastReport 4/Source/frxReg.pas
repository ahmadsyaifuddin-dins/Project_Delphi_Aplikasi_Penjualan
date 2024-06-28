
{******************************************}
{                                          }
{             FastReport v4.0              }
{            Registration unit             }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxReg;

{$I frx.inc}
//{$I frxReg.inc}

interface


procedure Register;

implementation

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
{$IFNDEF Delphi6}
  DsgnIntf,
{$ELSE}
  DesignIntf, DesignEditors,
{$ENDIF}
  Dialogs, frxClass, 
  frxDock, frxCtrls, frxDesgnCtrls,
  frxDesgn, frxPreview, frxRich, frxOLE, frxBarCode,
  frxChBox, frxDMPExport,
{$IFNDEF FR_VER_BASIC}
  frxDCtrl, 
{$ENDIF}
  frxCross, frxRichEdit, frxGradient, 
  frxGZip, frxEditAliases, frxCrypt;

{-----------------------------------------------------------------------}
type
  TfrxReportEditor = class(TComponentEditor)
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): String; override;
    function GetVerbCount: Integer; override;
  end;

  TfrxDataSetEditor = class(TComponentEditor)
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): String; override;
    function GetVerbCount: Integer; override;
  end;


{ TfrxReportEditor }

procedure TfrxReportEditor.ExecuteVerb(Index: Integer);
var
  Report: TfrxReport;
begin
  Report := TfrxReport(Component);
  if Report.Designer <> nil then
    Report.Designer.BringToFront
  else
  begin
    Report.DesignReport(Designer, Self);
    if Report.StoreInDFM then
      Designer.Modified;
  end;
end;

function TfrxReportEditor.GetVerb(Index: Integer): String;
begin
  Result := 'Edit Report...';
end;

function TfrxReportEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;


{ TfrxDataSetEditor }

procedure TfrxDataSetEditor.ExecuteVerb(Index: Integer);
begin
  with TfrxAliasesEditorForm.Create(Application) do
  begin
    DataSet := TfrxCustomDBDataSet(Component);
    if ShowModal = mrOk then
      Self.Designer.Modified;
    Free;
  end;
end;

function TfrxDataSetEditor.GetVerb(Index: Integer): String;
begin
  Result := 'Edit Fields Aliases...';
end;

function TfrxDataSetEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;


{-----------------------------------------------------------------------}
procedure Register;
begin
  RegisterComponents('FastReport 4.0',
    [TfrxReport, TfrxUserDataset, 
{$IFNDEF FR_VER_BASIC}
     TfrxDesigner, 
{$ENDIF}
     TfrxPreview,
     TfrxBarcodeObject, TfrxOLEObject, TfrxRichObject,
     TfrxCrossObject, TfrxCheckBoxObject, TfrxGradientObject, 
     TfrxDotMatrixExport
{$IFNDEF FR_VER_BASIC}
   , TfrxDialogControls
{$ENDIF}     
   , TfrxGZipCompressor, TfrxCrypt
     ]);

  RegisterComponents('FR4 tools',
    [TfrxDockSite, TfrxTBPanel, TfrxComboEdit,
     TfrxComboBox, TfrxFontComboBox, TfrxRuler, TfrxScrollBox]);

  RegisterComponentEditor(TfrxReport, TfrxReportEditor);
  RegisterComponentEditor(TfrxCustomDBDataSet, TfrxDataSetEditor);
end;

end.


//0f31356a91fea3356e5f76cdce90aa7b