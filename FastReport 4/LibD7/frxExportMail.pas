
{******************************************}
{                                          }
{             FastReport v4.0              }
{              E-mail export               }
{                                          }
{         Copyright (c) 1998-2006          }
{          by Alexander Fediachov,         }
{             Fast Reports Inc.            }
{                                          }
{******************************************}

unit frxExportMail;

interface

{$I frx.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, extctrls, frxClass, IniFiles, ComCtrls, frxSMTP
{$IFDEF Delphi6}, Variants {$ENDIF};

type
  TfrxMailExportDialog = class(TForm)
    OkB: TButton;
    CancelB: TButton;
    PageControl1: TPageControl;
    ExportSheet: TTabSheet;
    MessageGroup: TGroupBox;
    AddressLB: TLabel;
    SubjectLB: TLabel;
    MessageLB: TLabel;
    MessageM: TMemo;
    AttachGroup: TGroupBox;
    ExportsCombo: TComboBox;
    FormatLB: TLabel;
    SettingCB: TCheckBox;
    AccountSheet: TTabSheet;
    MailGroup: TGroupBox;
    RememberCB: TCheckBox;
    AccountGroup: TGroupBox;
    FromNameE: TEdit;
    FromNameLB: TLabel;
    FromAddrE: TEdit;
    FromAddrLB: TLabel;
    OrgLB: TLabel;
    OrgE: TEdit;
    SignatureLB: TLabel;
    SignatureM: TMemo;
    HostLB: TLabel;
    HostE: TEdit;
    PortE: TEdit;
    PortLB: TLabel;
    LoginLB: TLabel;
    LoginE: TEdit;
    PasswordE: TEdit;
    PasswordLB: TLabel;
    SignBuildBtn: TButton;
    AddressE: TComboBox;
    SubjectE: TComboBox;
    ReqLB: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure SignBuildBtnClick(Sender: TObject);
    procedure OkBClick(Sender: TObject);
    procedure PortEKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  end;

  TfrxMailExport = class(TfrxCustomExportFilter)
  private
    FExportFilter: TfrxCustomExportFilter;
    FAddress: String;
    FSubject: String;
    FMessage: TStrings;
    FShowExportDialog: Boolean;
    FOldSlaveStatus: Boolean;
    FFromName: String;
    FFromMail: String;
    FFromCompany: String;
    FSignature: TStrings;
    FSmtpHost: String;
    FSmtpPort: Integer;
    FLogin: String;
    FPassword: String;
    FUseIniFile: Boolean;
    FLogFile: String;
    procedure SetMessage(const Value: TStrings);
    procedure SetSignature(const Value: TStrings);
  protected
    property DefaultPath;
    property Stream;
    property CurPage;
    property PageNumbers;
    property FileName;
    property UseFileCache;
    property ExportNotPrintable;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class function GetDescription: String; override;
    function ShowModal: TModalResult; override;
    function Start: Boolean; override;
    function Mail(const Server: String; const Port: Integer;const
      UserField, PasswordField, FromField, ToField, SubjectField,
      TextField, FileName, AttachName: String): String;
    procedure ExportObject(Obj: TfrxComponent); override;
    property ExportFilter: TfrxCustomExportFilter read FExportFilter write FExportFilter;
  published
    property Address: String read FAddress write FAddress;
    property Subject: String read FSubject write FSubject;
    property Lines: TStrings read FMessage write SetMessage;
    property ShowExportDialog: Boolean read FShowExportDialog write FShowExportDialog;
    property FromMail: String read FFromMail write FFromMail;
    property FromName: String read FFromName write FFromName;
    property FromCompany: String read FFromCompany write FFromCompany;
    property Signature: TStrings read FSignature write SetSignature;
    property SmtpHost: String read FSmtpHost write FSmtpHost;
    property SmtpPort: Integer read FSmtpPort write FSmtpPort;
    property Login: String read FLogin write Flogin;
    property Password: String read FPassword write FPassword;
    property UseIniFile: Boolean read FUseIniFile write FUseIniFile;
    property LogFile: String read FLogFile write FLogFile;
  end;


implementation

uses frxDsgnIntf, frxFileUtils, frxNetUtils, frxUtils,
     frxUnicodeUtils, frxRes, frxrcExports, Registry;

{$R *.dfm}

const
  EMAIL_EXPORT_SECTION = 'EmailExport';

{ TfrxMailExport }

constructor TfrxMailExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAddress := '';
  FSubject := '';
  FMessage := TStringList.Create;
  FShowExportDialog := True;
  FFromName := '';
  FFromMail := '';
  FFromCompany := '';
  FSignature := TStringList.Create;
  FSmtpHost := '';
  FSmtpPort := 25;
  FLogin := '';
  FPassword := '';
  FUseIniFile := True;
end;

destructor TfrxMailExport.Destroy;
begin
  FMessage.Free;
  FSignature.Free;
  inherited;
end;

class function TfrxMailExport.GetDescription: String;
begin
  Result := frxResources.Get('EmailExport');
end;

function TfrxMailExport.ShowModal: TModalResult;
var
  i: Integer;
  ini: TCustomIniFile;
  Section: String;
begin
  with TfrxMailExportDialog.Create(nil) do
  begin
    try
      AttachGroup.Visible := not SlaveExport;
      SendMessage(GetWindow(ExportsCombo.Handle,GW_CHILD), EM_SETREADONLY, 1, 0);
      for i := 0 to frxExportFilters.Count - 1 do
      begin
        if (TfrxCustomExportFilter(frxExportFilters[i].Filter).ClassName <> 'TfrxDotMatrixExport')
          and (TfrxCustomExportFilter(frxExportFilters[i].Filter).ClassName <> 'TfrxMailExport') then
        ExportsCombo.Items.AddObject(TfrxCustomExportFilter(frxExportFilters[i].Filter).GetDescription, TfrxCustomExportFilter(frxExportFilters[i].Filter));
      end;
      ExportsCombo.Items.AddObject(frxResources.Get('FastReportFile'), nil);
      SettingCB.Checked := ShowExportDialog;
      if Assigned(Report) then
        ini := Report.GetIniFile
      else
        ini := TRegistryIniFile.Create('\Software\Fast Reports');
      try
        if not FUseIniFile then
          RememberCB.Visible := False;

        Section := EMAIL_EXPORT_SECTION + '.Properties';

        if ini.SectionExists(Section) and FUseIniFile then
        begin
          FromNameE.Text := ini.ReadString(Section, 'FromName', '');
          FromAddrE.Text := ini.ReadString(Section, 'FromAddress', '');
          OrgE.Text := ini.ReadString(Section, 'Organization', '');
          SignatureM.Lines.Text := ini.ReadString(Section, 'Signature', '');
          HostE.Text := ini.ReadString(Section, 'SmtpHost', '');
          PortE.Text := ini.ReadString(Section, 'SmtpPort', '25');
          LoginE.Text := Base64Decode(ini.ReadString(Section, 'Login', ''));
          PasswordE.Text := Base64Decode(ini.ReadString(Section, 'Password', ''));
          ExportsCombo.ItemIndex := ini.ReadInteger(Section, 'LastUsedExport', 0);
          ini.ReadSection(EMAIL_EXPORT_SECTION + '.RecentAddresses' , AddressE.Items);
          ini.ReadSection(EMAIL_EXPORT_SECTION + '.RecentSubjects' , SubjectE.Items);
        end
        else begin
          FromNameE.Text := FFromName;
          FromAddrE.Text := FFromMail;
          OrgE.Text := FFromCompany;
          SignatureM.Lines.Text := FSignature.Text;
          HostE.Text := FSmtpHost;
          PortE.Text := IntToStr(FSmtpPort);
          LoginE.Text := FLogin;
          PasswordE.Text := FPassword;
          if not Assigned(FExportFilter) then
            ExportsCombo.ItemIndex := 0
          else
            ExportsCombo.ItemIndex := ExportsCombo.Items.IndexOfObject(FExportFilter);
        end;

        AddressE.Text := FAddress;
        SubjectE.Text := FSubject;
        MessageM.Text := FMessage.Text;

        Result := ShowModal;

        if Result = mrOk then
        begin
          FAddress := AddressE.Text;
          FFromName := FromNameE.Text;
          FFromMail := FromAddrE.Text;
          FFromCompany := OrgE.Text;
          FSignature.Text := SignatureM.Lines.Text;
          FSmtpHost := HostE.Text;
          FSmtpPort := StrToInt(PortE.Text);
          FLogin := LoginE.Text;
          FPassword := PasswordE.Text;
          FSubject := SubjectE.Text;
          FMessage.Text := MessageM.Lines.Text;

          if RememberCB.Checked and FUseIniFile then
          begin
            ini.WriteString(Section, 'FromName', FromNameE.Text);
            ini.WriteString(Section, 'FromAddress', FromAddrE.Text);
            ini.WriteString(Section, 'Organization', OrgE.Text);
            ini.WriteString(Section, 'Signature', SignatureM.Lines.Text);
            ini.WriteString(Section, 'SmtpHost', HostE.Text);
            ini.WriteString(Section, 'SmtpPort', PortE.Text);
            ini.WriteString(Section, 'Login', Base64Encode(LoginE.Text));
            ini.WriteString(Section, 'Password', Base64Encode(PasswordE.Text));
          end;
          if FUseIniFile then
          begin
            ini.WriteInteger(Section, 'LastUsedExport', ExportsCombo.ItemIndex);
            ini.WriteString(EMAIL_EXPORT_SECTION + '.RecentAddresses' , AddressE.Text, '');
            ini.WriteString(EMAIL_EXPORT_SECTION + '.RecentSubjects' , SubjectE.Text, '');
          end;
          ShowExportDialog := SettingCB.Checked;
          FExportFilter := TfrxCustomExportFilter(ExportsCombo.Items.Objects[ExportsCombo.ItemIndex]);
        end;
      finally
        ini.Free;
      end;
    finally
      Free;
    end;
  end;
end;

function TfrxMailExport.Start: Boolean;
var
  s, f: String;
  fname: String;
begin
  s := '';
  if Assigned(FExportFilter) and (FExportFilter.FileName <> '') then
    f := ExtractFileName(FExportFilter.FileName)
  else if Report.ReportOptions.Name = '' then
    f := StringReplace(ExtractFileName(Report.FileName), ExtractFileExt(Report.FileName), '', [])
  else
    f := Report.ReportOptions.Name;
  if Assigned(FExportFilter) and (FExportFilter.FileName = '') then
    f := f + FExportFilter.DefaultExt; // ExtractFileExt(FExportFilter.FileName);
  if Assigned(FExportFilter) then
  begin
    FOldSlaveStatus := FExportFilter.SlaveExport;
    FExportFilter.SlaveExport := True;
    try
      FExportFilter.ShowDialog := ShowDialog and ShowExportDialog;
      FExportFilter.ShowProgress := ShowProgress;
      if Report.Export(FExportFilter) then
      begin
        s := Mail(FSmtpHost, FSmtpPort, FLogin, FPassword, FFromMail, FAddress,
          FSubject, FMessage.Text + FSignature.Text, FExportFilter.FileName, f);
      end;
    finally
      DeleteFile(FExportFilter.FileName);
      FExportFilter.FileName := '';
      FExportFilter.SlaveExport := FOldSlaveStatus;
    end;
  end
  else begin
    f := f + '.fp3';
    fname := GetTempFile;
    Report.PreviewPages.SaveToFile(fname);
    try
      s := Mail(FSmtpHost, FSmtpPort, FLogin, FPassword, FFromMail, FAddress,
         FSubject, FMessage.Text + FSignature.Text, fname, f);
    finally
      DeleteFile(fname);
    end;
  end;
  if s <> '' then
    case Report.EngineOptions.NewSilentMode of
      simSilent:        Report.Errors.Add(s);
      simMessageBoxes:  frxErrorMsg(s);
      simReThrow:       Exception.Create(s);
    end;
  Result := False;
end;

procedure TfrxMailExport.ExportObject(Obj: TfrxComponent);
begin
  // Fake
end;

function TfrxMailExport.Mail(const Server: String; const Port: Integer;const
  UserField, PasswordField, FromField, ToField, SubjectField,
  TextField, FileName, AttachName: String): String;
var
  frxMail: TfrxSMTPClient;
begin
  frxMail := TfrxSMTPClient.Create(nil);
  try
    frxMail.Host := Server;
    frxMail.Port := Port;
    frxMail.User := UserField;
    frxMail.Password := PasswordField;
    frxMail.MailFrom := FromField;
    frxMail.MailTo := ToField;
    frxMail.MailSubject := SubjectField;
    frxMail.MailText := StringReplace(TextField, '\n', #13#10, [rfReplaceAll]);
    frxMail.MailFile := FileName;
    frxMail.AttachName := AttachName;
    frxMail.ShowProgress := ShowProgress;
    frxMail.LogFile := LogFile;
    frxMail.Open;
  finally
    Result := frxMail.Errors.Text;
    frxMail.Free;
  end;
end;

procedure TfrxMailExport.SetMessage(const Value: TStrings);
begin
  FMessage.Assign(Value);
end;

procedure TfrxMailExport.SetSignature(const Value: TStrings);
begin
  FSignature.Assign(Value);
end;

{ TfrxMailExportDialog }

procedure TfrxMailExportDialog.FormCreate(Sender: TObject);
begin
  Caption := frxGet(8900);
  OkB.Caption := frxGet(1);
  CancelB.Caption := frxGet(2);
  ExportSheet.Caption := frxGet(8901);
  AccountSheet.Caption := frxGet(8902);
  AccountGroup.Caption := frxGet(8903);
  AddressLB.Caption := frxGet(8904);
  AttachGroup.Caption := frxGet(8905);
  FormatLB.Caption := frxGet(8906);
  FromAddrLB.Caption := frxGet(8907);
  FromNameLB.Caption := frxGet(8908);
  HostLB.Caption := frxGet(8909);
  LoginLB.Caption := frxGet(8910);
  MailGroup.Caption := frxGet(8911);
  MessageGroup.Caption := frxGet(8912);
  MessageLB.Caption := frxGet(8913);
  OrgLB.Caption := frxGet(8914);
  PasswordLB.Caption := frxGet(8915);
  PortLB.Caption := frxGet(8916);
  RememberCB.Caption := frxGet(8917);
  ReqLB.Caption := frxGet(8918);
  SettingCB.Caption := frxGet(8919);
  SignatureLB.Caption := frxGet(8920);
  SignBuildBtn.Caption := frxGet(8921);
  SubjectLB.Caption := frxGet(8922);
end;


procedure TfrxMailExportDialog.SignBuildBtnClick(Sender: TObject);
begin
  SignatureM.Clear;
  SignatureM.Lines.Add('--');
  SignatureM.Lines.Add(frxGet(8923) + ',');
  if Length(FromNameE.Text) > 0 then
    SignatureM.Lines.Add('  ' + FromNameE.Text);
  if Length(FromAddrE.Text) > 0 then
    SignatureM.Lines.Add('  mailto: ' + FromAddrE.Text);
  if Length(OrgE.Text) > 0 then
    SignatureM.Lines.Add('  ' + OrgE.Text);
end;

procedure TfrxMailExportDialog.OkBClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TLabel then
      (Components[i] as TLabel).Font.Style := [];
  if AddressE.Text = '' then
  begin
    ExportSheet.Show;
    AddressLB.Font.Style := [fsBold];
    ModalResult := mrNone;
  end;
  if SubjectE.Text = '' then
  begin
    ExportSheet.Show;
    SubjectLB.Font.Style := [fsBold];
    ModalResult := mrNone;
  end;
  if FromAddrE.Text = '' then
  begin
    AccountSheet.Show;
    FromAddrLB.Font.Style := [fsBold];
    ModalResult := mrNone;
  end;
  if HostE.Text = '' then
  begin
    AccountSheet.Show;
    HostLB.Font.Style := [fsBold];
    ModalResult := mrNone;
  end;
  if PortE.Text = '' then
  begin
    AccountSheet.Show;
    PortLB.Font.Style := [fsBold];
    ModalResult := mrNone;
  end;
  ReqLB.Visible := ModalResult = mrNone
end;

procedure TfrxMailExportDialog.PortEKeyPress(Sender: TObject;
  var Key: Char);
begin
  case key of
    '0'..'9':;
    #8:;
  else
    key := #0;
  end;
end;

procedure TfrxMailExportDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F1 then
    frxResources.Help(Self);
end;

end.
