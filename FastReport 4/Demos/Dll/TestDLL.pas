unit TestDLL;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, DB, ExtCtrls, DBTables;

type
  TShowForm = function(A: TApplication): Bool; StdCall;

  EDLLLoadError = class(Exception);

  TfrmCallDLL = class(TForm)
    Database1: TDatabase;
    btnCallDLL: TButton;
    btnClose: TButton;
    procedure btnCallDLLClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  end;

var
  frmCallDLL: TfrmCallDLL;

implementation


{$R *.DFM}

procedure TfrmCallDLL.btnCallDLLClick(Sender: TObject);
var
  LibHandle: THandle;
  ShowForm: TShowForm;
begin
  LibHandle := LoadLibrary('RptDLL.DLL');
  try
    if LibHandle = HINSTANCE_ERROR then
      raise EDLLLoadError.Create('Unable to Load DLL');
    @ShowForm := GetProcAddress(LibHandle, 'ShowForm');
    if not (@ShowForm = nil) then
      ShowForm(Application);
  finally
    FreeLibrary(LibHandle);
  end;
end;

procedure TfrmCallDLL.btnCloseClick(Sender: TObject);
begin
  Close;
end;


end.
