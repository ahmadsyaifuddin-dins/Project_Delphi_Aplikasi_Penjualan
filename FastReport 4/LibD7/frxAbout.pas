
{******************************************}
{                                          }
{             FastReport v4.0              }
{              About window                }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxAbout;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type
  TfrxAboutForm = class(TForm)
    Button1: TButton;
    Label2: TLabel;
    Label3: TLabel;
    Image1: TImage;
    Bevel2: TBevel;
    Label5: TLabel;
    Shape1: TShape;
    Label1: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure LabelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


implementation

uses frxClass, frxUtils, frxRes, ShellApi;

{$R *.DFM}

procedure TfrxAboutForm.FormCreate(Sender: TObject);
begin
  Caption := frxGet(2600);
  Label4.Caption := frxGet(2601);
  Label6.Caption := frxGet(2602);
  Label8.Caption := frxGet(2603);
  Label2.Caption := 'Version ' + FR_VERSION;
  Label10.Caption := #174;
  {$IFDEF FR_LITE}
  Label1.Caption := 'FreeReport'; 
  {$ENDIF}
end;

procedure TfrxAboutForm.LabelClick(Sender: TObject);
begin
  case TLabel(Sender).Tag of
    1: ShellExecute(GetDesktopWindow, 'open',
      PChar(TLabel(Sender).Caption), nil, nil, sw_ShowNormal);
    2: ShellExecute(GetDesktopWindow, 'open',
      PChar('mailto:' + TLabel(Sender).Caption), nil, nil, sw_ShowNormal);
  end;
end;

procedure TfrxAboutForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    ModalResult := mrCancel;
end;

end.



//0f31356a91fea3356e5f76cdce90aa7b