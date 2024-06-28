
{******************************************}
{                                          }
{             FastReport v4.0              }
{             New item dialog              }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxNewItem;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ImgList;

type
  TfrxNewItemForm = class(TForm)
    Pages: TPageControl;
    ItemsTab: TTabSheet;
    OkB: TButton;
    CancelB: TButton;
    TemplateTab: TTabSheet;
    InheritCB: TCheckBox;
    TemplateLV: TListView;
    ItemsLV: TListView;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ItemsLVDblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FTemplates: TStringList;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;


implementation

{$R *.DFM}

uses frxClass, frxDesgn, frxDsgnIntf, frxUtils, frxRes;


constructor TfrxNewItemForm.Create(AOwner: TComponent);
begin
  inherited;
  FTemplates := TStringList.Create;
  FTemplates.Sorted := True;
end;

destructor TfrxNewItemForm.Destroy;
begin
  FTemplates.Free;
  inherited;
end;

procedure TfrxNewItemForm.FormCreate(Sender: TObject);
begin
  Caption := frxGet(5300);
  ItemsTab.Caption := frxGet(5301);
  TemplateTab.Caption := frxGet(5302);
  InheritCB.Caption := frxGet(5303);
  OkB.Caption := frxGet(1);
  CancelB.Caption := frxGet(2);
  ItemsLV.LargeImages := frxResources.WizardImages;
  TemplateLV.LargeImages := frxResources.WizardImages;
end;

procedure TfrxNewItemForm.FormShow(Sender: TObject);
var
  i: Integer;
  Item: TfrxWizardItem;
  lvItem: TListItem;
begin
  for i := 0 to frxWizards.Count - 1 do
  begin
    Item := frxWizards[i];
    if (Item.ButtonBmp <> nil) and (Item.ButtonImageIndex = -1) then
    begin
      frxResources.SetWizardImages(Item.ButtonBmp);
      Item.ButtonImageIndex := frxResources.WizardImages.Count - 1;
    end;

    lvItem := ItemsLV.Items.Add;
    lvItem.Caption := Item.ClassRef.GetDescription;
    lvItem.Data := Item;
    lvItem.ImageIndex := Item.ButtonImageIndex;
  end;

  if frxDesignerComp <> nil then
  begin
    frxDesignerComp.GetTemplateList(FTemplates);
    for i := 0 to FTemplates.Count - 1 do
    begin
      lvItem := TemplateLV.Items.Add;
      lvItem.Caption := ExtractFileName(FTemplates[i]);
      lvItem.Data := Pointer(i);
      lvItem.ImageIndex := 5;
    end;
  end;
end;

procedure TfrxNewItemForm.ItemsLVDblClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrxNewItemForm.FormDestroy(Sender: TObject);
var
  w: TfrxCustomWizard;
  Designer: TfrxDesignerForm;
  Report: TfrxReport;
  templ: String;
begin
  if ModalResult = mrOk then
  begin
    if (Pages.ActivePage = ItemsTab) and (ItemsLV.Selected <> nil) then
    begin
      w := TfrxCustomWizard(TfrxWizardItem(ItemsLV.Selected.Data).ClassRef.NewInstance);
      w.Create(Owner);
      if w.Execute then
        w.Designer.Modified := True;
      w.Free;
    end
    else if (Pages.ActivePage = TemplateTab) and (TemplateLV.Selected <> nil) then
    begin
      Designer := TfrxDesignerForm(Owner);
      Report := Designer.Report;
      templ := FTemplates[Integer(TemplateLV.Selected.Data)];
      Designer.Lock;
      try
        Report.Clear;
        if InheritCB.Checked then
          Report.ParentReport := ExtractRelativePath(
            ExtractFilePath(Application.ExeName), templ)
        else
        begin
          if Assigned(Report.OnLoadTemplate) then
            Report.OnLoadTemplate(Report, templ)
          else
            Report.LoadFromFile(templ);
        end;
      finally
        Report.FileName := '';
        Designer.ReloadReport;
      end;
    end;
  end;
end;

procedure TfrxNewItemForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

end.


//0f31356a91fea3356e5f76cdce90aa7b