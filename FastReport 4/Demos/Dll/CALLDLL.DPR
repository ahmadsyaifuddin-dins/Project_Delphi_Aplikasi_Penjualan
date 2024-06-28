program CallDLL;

uses
  Forms,
  TestDLL in 'TestDLL.pas' {frmCallDLL};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmCallDLL, frmCallDLL);
  Application.Run;
end.
