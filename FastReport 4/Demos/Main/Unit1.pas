unit Unit1;

{$I frx.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Db, frxDesgn, frxClass, frxDCtrl,
  frxChart, frxRich, frxBarcode, ImgList, ComCtrls, ExtCtrls, frxOLE,
  frxCross, frxDMPExport, frxExportImage, frxExportRTF,
  frxExportXML, frxExportXLS, frxExportHTML, frxGZip, frxExportPDF,
  frxChBox, frxExportText, frxExportCSV, frxExportMail,
  frxADOComponents, frxCrypt, frxExportODF;
                   
type
  TForm1 = class(TForm)
    frxDesigner1: TfrxDesigner;
    frxBarCodeObject1: TfrxBarCodeObject;
    frxRichObject1: TfrxRichObject;
    frxDialogControls1: TfrxDialogControls;
    ImageList1: TImageList;
    Image1: TImage;
    Label1: TLabel;
    Label3: TLabel;
    frxOLEObject1: TfrxOLEObject;
    frxCrossObject1: TfrxCrossObject;
    frxDotMatrixExport1: TfrxDotMatrixExport;
    frxBMPExport1: TfrxBMPExport;
    frxJPEGExport1: TfrxJPEGExport;
    frxTIFFExport1: TfrxTIFFExport;
    frxHTMLExport1: TfrxHTMLExport;
    frxXLSExport1: TfrxXLSExport;
    frxXMLExport1: TfrxXMLExport;
    frxRTFExport1: TfrxRTFExport;
    frxReport1: TfrxReport;
    frxGZipCompressor1: TfrxGZipCompressor;
    frxPDFExport1: TfrxPDFExport;
    Label4: TLabel;
    frxCheckBoxObject1: TfrxCheckBoxObject;
    frxMailExport1: TfrxMailExport;
    frxCSVExport1: TfrxCSVExport;
    frxGIFExport1: TfrxGIFExport;
    frxSimpleTextExport1: TfrxSimpleTextExport;
    frxADOComponents1: TfrxADOComponents;
    frxCrypt1: TfrxCrypt;
    GroupBox1: TGroupBox;
    Tree: TTreeView;
    GroupBox2: TGroupBox;
    DescriptionM: TMemo;
    DesignB: TButton;
    PreviewB: TButton;
    Label5: TLabel;
    Label7: TLabel;
    Label2: TLabel;
    FileNameL: TLabel;
    Shape1: TShape;
    frxODSExport1: TfrxODSExport;
    frxODTExport1: TfrxODTExport;
    procedure DesignBClick(Sender: TObject);
    procedure TreeCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure PreviewBClick(Sender: TObject);
    procedure TreeChange(Sender: TObject; Node: TTreeNode);
    procedure FormShow(Sender: TObject);
    procedure Label3Click(Sender: TObject);
  private
    { Private declarations }
    WPath: String;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses Unit2, ShellApi
{$IFDEF Delphi7}
,  XPMan
{$ENDIF};



{$R *.DFM}

procedure TForm1.FormShow(Sender: TObject);
begin
  WPath := ExtractFilePath(Application.ExeName);
  Tree.Items[0].Item[0].Selected := True;
  Label2.Caption := FR_VERSION;
  Label4.Caption := #174;
end;

procedure TForm1.DesignBClick(Sender: TObject);
begin
  frxReport1.DesignReport;
end;

procedure TForm1.PreviewBClick(Sender: TObject);
begin
  frxReport1.ShowReport;
end;

procedure TForm1.TreeCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if Node.Count <> 0 then
    Tree.Canvas.Font.Style := [fsBold];
end;

procedure TForm1.TreeChange(Sender: TObject; Node: TTreeNode);
begin
  if Node.StateIndex = -1 then
  begin
    Tree.FullCollapse;
    Node[0].Selected := True;
  end
  else
  begin
    DesignB.Enabled := True;
    PreviewB.Enabled := True;
    frxReport1.LoadFromFile(WPath + IntToStr(Node.StateIndex) + '.fr3');
    FileNameL.Caption := ' Report file: ' + IntToStr(Node.StateIndex) + '.fr3';
    DescriptionM.Lines := frxReport1.ReportOptions.Description;
  end;
end;

procedure TForm1.Label3Click(Sender: TObject);
begin
  ShellExecute(GetDesktopWindow, 'open',
    PChar(TLabel(Sender).Caption), nil, nil, sw_ShowNormal);
end;

end.


