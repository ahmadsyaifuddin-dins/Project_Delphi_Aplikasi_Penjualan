
{******************************************}
{                                          }
{              FastReport 4.0              }
{        SMTP connection client unit       }
{                                          }
{            Copyright (c) 2006            }
{         by Alexander Fediachov,          }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxSMTP;

interface

{$I frx.inc}

uses
  Windows, SysUtils, Classes, ScktComp, frxNetUtils, frxProgress
{$IFDEF Delphi6}, Variants {$ENDIF};


type
  TfrxSMTPClientThread = class;

  TfrxSMTPClient = class(TComponent)
  private
    FActive: Boolean;
    FBreaked: Boolean;
    FErrors: TStrings;
    FHost: String;
    FPort: Integer;
    FThread: TfrxSMTPClientThread;
    FTimeOut: Integer;
    FPassword: String;
    FMailTo: String;
    FUser: String;
    FMailFile: String;
    FMailFrom: String;
    FMailSubject: String;
    FMailText: String;
    FAnswer: String;
    FAccepted: Boolean;
    FAuth: String;
    FCode: Integer;
    FSending: Boolean;
    FAttachName: String;
    FProgress: TfrxProgress;
    FShowProgress: Boolean;
    FLogFile: String;
    FLog: TStringList;
    FAnswerList: TStringList;
    F200Flag: Boolean;
    F210Flag: Boolean;
    F215Flag: Boolean;
    FUserName: String;
    procedure DoConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure DoDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure DoError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure DoRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure SetActive(const Value: Boolean);
    procedure AddLogIn(const s: String);
    procedure AddLogOut(const s: String);
    function DomainByEmail(const addr: String): String;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Connect;
    procedure Disconnect;
    procedure Open;
    procedure Close;
    property Breaked: Boolean read FBreaked;
    property Errors: TStrings read FErrors write Ferrors;
    property LogFile: String read FLogFile write FLogFile;
  published
    property Active: Boolean read FActive write SetActive;
    property Host: String read FHost write FHost;
    property Port: Integer read FPort write FPort;
    property TimeOut: Integer read FTimeOut write FTimeOut;
    property UserName: String read FUserName write FUserName;
    property User: String read FUser write FUser;
    property Password: String read FPassword write FPassword;
    property MailFrom: String read FMailFrom write FMailFrom;
    property MailTo: String read FMailTo write FMailTo;
    property MailSubject: String read FMailSubject write FMailSubject;
    property MailText: String read FMailText write FMailText;
    property MailFile: String read FMailFile write FMailFile;
    property AttachName: String read FAttachName write FAttachName;
    property ShowProgress: Boolean read FShowProgress write FShowProgress;
  end;

  TfrxSMTPClientThread = class (TThread)
  protected
    FClient: TfrxSMTPClient;
    procedure DoOpen;
    procedure Execute; override;
  public
    FSocket: TClientSocket;
    constructor Create(Client: TfrxSMTPClient);
    destructor Destroy; override;
  end;

implementation

uses frxRes, frxrcExports;

const
  MIME_STRING_SIZE = 57;
  boundary = '----------FastReport';

type
  THackThread = class(TThread);


{ TfrxSMTPClient }

constructor TfrxSMTPClient.Create(AOwner: TComponent);
begin
  inherited;
  FErrors := TStringList.Create;
  FHost := '127.0.0.1';
  FPort := 25;
  FActive := False;
  FTimeOut := 60;
  FBreaked := False;
  FThread := TfrxSMTPClientThread.Create(Self);
  FThread.FSocket.OnConnect := DoConnect;
  FThread.FSocket.OnRead := DoRead;
  FThread.FSocket.OnDisconnect := DoDisconnect;
  FThread.FSocket.OnError := DoError;
  FAttachName := '';
  FShowProgress := False;
  FLogFile := '';
  FLog := TStringList.Create;
  FAnswerList := TStringList.Create;
end;

destructor TfrxSMTPClient.Destroy;
begin
  Close;
  while FActive do
    PMessages;
  FThread.Free;
  FErrors.Free;
  FLog.Free;
  FAnswerList.Free;
  inherited;
end;

procedure TfrxSMTPClient.Connect;
var
  ticks: Cardinal;
begin
  FLog.Clear;
  if (FLogFile <> '') and FileExists(LogFile) then
    FLog.LoadFromFile(LogFile);
  FLog.Add(DateTimeToStr(Now));
  FErrors.Clear;
  FActive := True;
  FThread.FSocket.Host := FHost;
  FThread.FSocket.Address := FHost;
  FThread.FSocket.Port := FPort;
  FThread.FSocket.ClientType := ctNonBlocking;
  F200Flag := False;
  F210Flag := False;
  F215Flag := False;
  if FShowProgress then
  begin
    FProgress := TfrxProgress.Create(Self);
    FProgress.Execute(100, frxGet(8924) + ' ' + FMailTo, False, True);
  end;
  FThread.Execute;
  try
    ticks := GetTickCount;
    while FActive and (not FBreaked) do
    begin
      PMessages;
      if FShowProgress then
        FProgress.Tick;
      if ((GetTickCount - ticks) > Cardinal(FTimeOut * 1000)) then
      begin
        Errors.Add('Timeout expired (' + IntToStr(FTimeOut) + ')');
        break;
      end;
      if FSending then
        ticks := GetTickCount;
      Sleep(100);
    end;
  finally
    if FShowProgress then
      FProgress.Free;
    Disconnect;
  end;
  FLog.Add('---' + DateTimeToStr(Now));
  FLog.AddStrings(FErrors);
  if FLogFile <> '' then
    FLog.SaveToFile(FLogFile);
end;

procedure TfrxSMTPClient.Disconnect;
begin
  FThread.FSocket.Close;
  FThread.Terminate;
  FActive := False;
end;

procedure TfrxSMTPClient.DoConnect(Sender: TObject;
  Socket: TCustomWinSocket);
var
  s: String;
begin
  s := 'HELO ' + DomainByEmail(FMailFrom) + #13#10;
  Socket.SendText(s);
  AddLogOut(s);
  FCode := 0;
  FAuth := FUser;
  FAccepted := False;
  FSending := False;
end;

procedure TfrxSMTPClient.DoDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  if Pos('221', FAnswer) = 0 then
    Errors.Add(FAnswer);
  FActive := False;
  FSending := False;
end;

procedure TfrxSMTPClient.DoError(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  if FAnswer <> '' then
    Errors.Add(FAnswer);
  Errors.Add(GetSocketErrorText(ErrorCode));
  FActive := False;
  ErrorCode := 0;
  FSending := False;
end;

procedure TfrxSMTPClient.DoRead(Sender: TObject; Socket: TCustomWinSocket);
var
  buf: PChar;
  i, k: Integer;
  Stream: TMemoryStream;
  fbuf: PChar;
  FStream: TFileStream;
  s: String;
  s1: String;

  procedure OutStream(const S: String);
  begin
    Stream.Write(S[1], Length(S));
    Stream.Write(#13#10, 2);
  end;

begin
  i := Socket.ReceiveLength;
  GetMem(buf, i);
  try
    try
      i := Socket.ReceiveBuf(buf^, i);
      SetLength(FAnswer, i);
      CopyMemory(PChar(FAnswer), buf, i);
      FAnswerList.Text := FAnswer;

      for k := 0 to FAnswerList.Count - 1 do
      begin
        FAnswer := FAnswerList[k];
        FCode := StrToInt(Copy(FAnswer, 1, 3));
        AddLogIn(FAnswer);
        if (FCode = 235) then
        begin
          FCode := 220;
          FAccepted := True;
        end;
        if (FUser <> '') and (not FAccepted) and (FCode = 220) then
        begin
          s := 'AUTH LOGIN'#13#10;
          Socket.SendText(s);
          AddLogOut(s);
        end
        else if FCode = 334 then
        begin
          Socket.SendText(Base64Encode(FAuth) + #13#10);
          FAuth := FPassword;
          AddLogOut('****');
        end
        else if (FCode = 220) then
        begin
          s := 'MAIL FROM: ' + '<' + FMailFrom + '>' + #13#10;
          Socket.SendText(s);
          AddLogOut(s);
          F210Flag := True;
        end
        else if (FCode = 250) and F210Flag then
        begin
          s := 'RCPT TO: ' + '<' + FMailTo + '>' + #13#10;
          Socket.SendText(s);
          AddLogOut(s);
          F210Flag := False;
          F215Flag := True;
        end
        else if (FCode = 250) and F215Flag then
        begin
          s := 'DATA'#13#10;
          Socket.SendText(s);
          AddLogOut(s);
          F215Flag := False;
        end
        else if (FCode = 250) and F200Flag then
        begin
          s := 'QUIT'#13#10;
          Socket.SendText(s);
          AddLogOut(s);
          F200Flag := False;
        end
        else if (FCode = 354) then
        begin
          FSending := True;
          Stream := TMemoryStream.Create;
          try
            OutStream('Date: ' + DateTimeToRFCDateTime(Now));
            OutStream('Subject: ' + FMailSubject);
            OutStream('To: ' + FMailTo);
            OutStream('From: ' + FMailFrom);
            OutStream('X-Mailer: FastReport');
            if (FMailFile <> '') and FileExists(FMailFile) then
            begin
              OutStream('MIME-Version: 1.0');
              OutStream('Content-Type: multipart/mixed; boundary="' + boundary +'"');
              OutStream(#13#10'--' + boundary);
              OutStream('Content-Type: text/plain');
              OutStream('Content-Transfer-Encoding: 7bit');
              OutStream(#13#10 + FMailText);
              OutStream('--' + boundary);
              s := GetFileMIMEType(FMailFile);
              if FAttachName = '' then
                s1 := ExtractFileName(FMailFile)
              else
                s1 := FAttachName;
              OutStream('Content-Type: ' + s + '; name="' + s1 + '"');
              OutStream('Content-Transfer-Encoding: base64');
              OutStream('Content-Disposition: attachment; filename="' + s1 + '"'#13#10);
              FStream := TFileStream.Create(FMailFile, fmOpenRead + fmShareDenyWrite);
              GetMem(fbuf, MIME_STRING_SIZE);
              try
                i := MIME_STRING_SIZE;
                while i = MIME_STRING_SIZE do
                begin
                  i := FStream.Read(fbuf^, i);
                  SetLength(s, i);
                  CopyMemory(PChar(s), fbuf, i);
                  s := Base64Encode(s);
                  OutStream(s);
                end;
              finally
                FreeMem(fbuf);
                FStream.Free;
              end;
              OutStream(#13#10 + '--' + boundary + '--');
            end
            else
              OutStream(#13#10 + FMailText);
            OutStream('.');
            AddLogOut('message(skipped)');
            Socket.SendBuf(Stream.Memory^, Stream.Size);
            F200Flag := True;
          finally
            FSending := False;
            Stream.Free;
          end;
        end;
      end;
    except
      on e: Exception do
        Errors.Add('Data receive error: ' + e.Message)
    end;
  finally
    FreeMem(buf);
  end;
end;

procedure TfrxSMTPClient.SetActive(const Value: Boolean);
begin
  if Value then Connect
  else Disconnect;
end;

procedure TfrxSMTPClient.Close;
begin
  FBreaked := True;
  Active := False;
end;

procedure TfrxSMTPClient.Open;
begin
  Active := True;
end;

function TfrxSMTPClient.DomainByEmail(const addr: String): String;
var
  i: Integer;
begin
  i := Pos('@', addr);
  if i > 0 then
    Result := Copy(addr, i + 1, Length(addr) - i)
  else
    Result := addr;
end;

procedure TfrxSMTPClient.AddLogIn(const s: String);
begin
  FLog.Add('<' + s);
end;

procedure TfrxSMTPClient.AddLogOut(const s: String);
begin
  FLog.Add('>' + s);
end;

{ TfrxSMTPClientThread }

constructor TfrxSMTPClientThread.Create(Client: TfrxSMTPClient);
begin
  inherited Create(True);
  FClient := Client;
  FreeOnTerminate := False;
  FSocket := TClientSocket.Create(nil);
end;

destructor TfrxSMTPClientThread.Destroy;
begin
  FSocket.Free;
  inherited;
end;

procedure TfrxSMTPClientThread.DoOpen;
begin
  FSocket.Open;
end;

procedure TfrxSMTPClientThread.Execute;
begin
  Synchronize(DoOpen);
end;

end.
