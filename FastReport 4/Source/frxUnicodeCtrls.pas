{*******************************************************}
{    The Delphi Unicode Controls Project                }
{                                                       }
{      http://home.ccci.org/wolbrink                    }
{                                                       }
{ Copyright (c) 2002, Troy Wolbrink (wolbrink@ccci.org) }
{                                                       }
{*******************************************************}

unit frxUnicodeCtrls;

interface

{$I frx.inc}

uses Windows, Messages, Classes, Controls, Forms, StdCtrls;

type
  TUnicodeEdit = class(TEdit)
  private
    procedure SetSelText(const Value: WideString);
    function GetText: WideString;
    procedure SetText(const Value: WideString);
  protected
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    function GetSelText: WideString; reintroduce;
  public
    property SelText: WideString read GetSelText write SetSelText;
    property Text: WideString read GetText write SetText;
  end;

  TUnicodeMemo = class(TMemo)
  private
    procedure SetSelText(const Value: WideString);
    function GetText: WideString;
    procedure SetText(const Value: WideString);
  protected
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    function GetSelText: WideString; reintroduce;
  public
    property SelText: WideString read GetSelText write SetSelText;
    property Text: WideString read GetText write SetText;
  end;


implementation

uses SysUtils, Graphics, Imm;

const
  UNICODE_CLASS_EXT = '.UnicodeClass';
  ANSI_UNICODE_HOLDER = $FF;

var
  UnicodeCreationControl: TWinControl = nil;
  Win32PlatformIsUnicode: Boolean;
  Win32PlatformIsXP: Boolean;

{$IFDEF Delphi6}
function MakeObjectInstance(Method: TWndMethod): Pointer;
begin
  Result := Classes.MakeObjectInstance(Method);
end;

procedure FreeObjectInstance(ObjectInstance: Pointer);
begin
  Classes.FreeObjectInstance(ObjectInstance);
end;
{$ENDIF}

function IsUnicodeCreationControl(Handle: HWND): Boolean;
begin
  Result := (UnicodeCreationControl <> nil)
        and (UnicodeCreationControl.HandleAllocated)
        and (UnicodeCreationControl.Handle = Handle);
end;

function WMNotifyFormatResult(FromHandle: HWND): Integer;
begin
  if Win32PlatformIsUnicode
  and (IsWindowUnicode(FromHandle) or IsUnicodeCreationControl(FromHandle)) then
    Result := NFR_UNICODE
  else
    Result := NFR_ANSI;
end;

function IsTextMessage(Msg: UINT): Boolean;
begin
  // WM_CHAR is omitted because of the special handling it receives
  Result := (Msg = WM_SETTEXT)
         or (Msg = WM_GETTEXT)
         or (Msg = WM_GETTEXTLENGTH);
end;

procedure MakeWMCharMsgSafeForAnsi(var Message: TMessage);
begin
  with TWMChar(Message) do begin
    Assert(Msg = WM_CHAR);
    Assert(Unused = 0);
    if (CharCode > Word(High(AnsiChar))) then begin
      Unused := CharCode;
      CharCode := ANSI_UNICODE_HOLDER;
    end;
  end;
end;

procedure RestoreWMCharMsg(var Message: TMessage);
begin
  with TWMChar(Message) do begin
    Assert(Message.Msg = WM_CHAR);
    if (Unused > 0)
    and (CharCode = ANSI_UNICODE_HOLDER) then
      CharCode := Unused;
    Unused := 0;
  end;
end;

//-----------------------------------------------------------------------------------
type
  TAccessControl = class(TControl);
  TAccessWinControl = class(TWinControl);

  TWinControlTrap = class(TComponent)
  private
    WinControl_ObjectInstance: Pointer;
    ObjectInstance: Pointer;
    DefObjectInstance: Pointer;
    function IsInSubclassChain(Control: TWinControl): Boolean;
    procedure SubClassWindowProc;
  private
    FControl: TAccessWinControl;
    Handle: THandle;
    PrevWin32Proc: Pointer;
    PrevDefWin32Proc: Pointer;
    PrevWindowProc: TWndMethod;
  private
    LastWin32Msg: UINT;
    Win32ProcLevel: Integer;
    IDEWindow: Boolean;
    DestroyTrap: Boolean;
    TestForNull: Boolean;
    FoundNull: Boolean;
    {$IFDEF TNT_VERIFY_WINDOWPROC}
    LastVerifiedWindowProc: TWndMethod;
    {$ENDIF}
    procedure Win32Proc(var Message: TMessage);
    procedure DefWin32Proc(var Message: TMessage);
    procedure WindowProc(var Message: TMessage);
  private
    procedure SubClassControl(Params_Caption: PAnsiChar);
    procedure UnSubClassUnicodeControl;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

constructor TWinControlTrap.Create(AOwner: TComponent);
begin
  FControl := TAccessWinControl(AOwner as TWinControl);
  inherited Create(nil);
  FControl.FreeNotification(Self);

  WinControl_ObjectInstance := MakeObjectInstance(FControl.MainWndProc);
  ObjectInstance := MakeObjectInstance(Win32Proc);
  DefObjectInstance := MakeObjectInstance(DefWin32Proc);
end;

destructor TWinControlTrap.Destroy;
begin
  FreeObjectInstance(ObjectInstance);
  FreeObjectInstance(DefObjectInstance);
  FreeObjectInstance(WinControl_ObjectInstance);
  inherited;
end;

procedure TWinControlTrap.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (AComponent = FControl) and (Operation = opRemove) then begin
    FControl := nil;
    if Win32ProcLevel = 0 then
      Free
    else
      DestroyTrap := True;
  end;
end;

procedure TWinControlTrap.SubClassWindowProc;
begin
  if not IsInSubclassChain(FControl) then begin
    PrevWindowProc := FControl.WindowProc;
    FControl.WindowProc := Self.WindowProc;
  end;
end;

procedure TWinControlTrap.SubClassControl(Params_Caption: PAnsiChar);
begin
  // initialize trap object
  Handle := FControl.Handle;
  PrevWin32Proc := Pointer(GetWindowLongW(FControl.Handle, GWL_WNDPROC));
  PrevDefWin32Proc := FControl.DefWndProc;

  // subclass Window Procedures
  SetWindowLongW(FControl.Handle, GWL_WNDPROC, Integer(ObjectInstance));
  FControl.DefWndProc := DefObjectInstance;
  SubClassWindowProc;
end;

function SameWndMethod(A, B: TWndMethod): Boolean;
begin
  Result := @A = @B;
end;

var
  PendingRecreateWndTrapList: TList = nil;

procedure TWinControlTrap.UnSubClassUnicodeControl;
begin
  // restore window procs (restore WindowProc only if we are still the direct subclass)
  if SameWndMethod(FControl.WindowProc, Self.WindowProc) then
    FControl.WindowProc := PrevWindowProc;
  TAccessWinControl(FControl).DefWndProc := PrevDefWin32Proc;
  SetWindowLongW(FControl.Handle, GWL_WNDPROC, Integer(PrevWin32Proc));

  if IDEWindow then
    DestroyTrap := True
  else if not (csDestroying in FControl.ComponentState) then
    // control not being destroyed, probably recreating window
    PendingRecreateWndTrapList.Add(Self);
end;

var
  Finalized: Boolean; { If any tnt controls are still around after finalization it must be due to a memory leak.
                        Windows will still try to send a WM_DESTROY, but we will just ignore it if we're finalized. }

procedure TWinControlTrap.Win32Proc(var Message: TMessage);
begin
  if (not Finalized) then begin
    Inc(Win32ProcLevel);
    try
      with Message do begin
        LastWin32Msg := Msg;
        Result := CallWindowProcW(PrevWin32Proc, Handle, Msg, wParam, lParam);
      end;
    finally
      Dec(Win32ProcLevel);
    end;
    if (Win32ProcLevel = 0) and (DestroyTrap) then
      Free;
  end else if (Message.Msg = WM_DESTROY) then
    FControl.WindowHandle := 0
end;

procedure TWinControlTrap.DefWin32Proc(var Message: TMessage);
begin
  with Message do begin
    if Msg = WM_NOTIFYFORMAT then
      Result := WMNotifyFormatResult(Message.wParam)
    else begin
      if (Msg = WM_CHAR) then begin
        RestoreWMCharMsg(Message)
      end;
      if (Msg = WM_IME_CHAR) and (not Win32PlatformIsXP) then
      begin
        { In Windows XP, DefWindowProc handles WM_IME_CHAR fine for VCL windows. }
        { Before XP, DefWindowProc will sometimes produce incorrect, non-Unicode WM_CHAR. }
        { Also, using PostMessageW on Windows 2000 didn't always produce the correct results. }
        Message.Result := SendMessageW(Handle, WM_CHAR, wParam, lParam)
      end else begin
        if (Msg = WM_DESTROY) then begin
          UnSubClassUnicodeControl; {The reason for doing this in DefWin32Proc is because in D9, TWinControl.WMDestroy() does a perform(WM_TEXT) operation. }
        end;
        { Normal DefWindowProc }
        Result := CallWindowProcW(PrevDefWin32Proc, Handle, Msg, wParam, lParam);
      end;
    end;
  end;
end;

function TWinControlTrap.IsInSubclassChain(Control: TWinControl): Boolean;
var
  Message: TMessage;
begin
  if SameWndMethod(Control.WindowProc, TAccessWinControl(Control).WndProc) then
    Result := False { no subclassing }
  else if SameWndMethod(Control.WindowProc, Self.WindowProc) then
    Result := True { directly subclassed }
  else begin
    TestForNull := True;
    FoundNull := False;
    ZeroMemory(@Message, SizeOf(Message));
    Message.Msg := WM_NULL;
    Control.WindowProc(Message);
    Result := FoundNull; { indirectly subclassed }
  end;
end;

procedure TWinControlTrap.WindowProc(var Message: TMessage);
var
  CameFromWindows: Boolean;
begin
  if TestForNull and (Message.Msg = WM_NULL) then
    FoundNull := True;

  if (not FControl.HandleAllocated) then
    FControl.WndProc(Message)
  else begin
    CameFromWindows := LastWin32Msg <> WM_NULL;
    LastWin32Msg := WM_NULL;
    with Message do begin
      if (not CameFromWindows)
      and (IsTextMessage(Msg)) then
        Result := SendMessageA(Handle, Msg, wParam, lParam)
      else begin
        if (Msg = WM_CHAR) then begin
          MakeWMCharMsgSafeForAnsi(Message);
        end;
        PrevWindowProc(Message)
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------

function FindOrCreateWinControlTrap(Control: TWinControl): TWinControlTrap;
var
  i: integer;
begin
  // find or create trap object
  Result := nil;
  for i := PendingRecreateWndTrapList.Count - 1 downto 0 do begin
    if TWinControlTrap(PendingRecreateWndTrapList[i]).FControl = Control then begin
      Result := TWinControlTrap(PendingRecreateWndTrapList[i]);
      PendingRecreateWndTrapList.Delete(i);
      break; { found it }
    end;
  end;
  if Result = nil then
    Result := TWinControlTrap.Create(Control);
end;

procedure SubClassUnicodeControl(Control: TWinControl; Params_Caption: PAnsiChar; IDEWindow: Boolean = False);
var
  WinControlTrap: TWinControlTrap;
begin
  if not IsWindowUnicode(Control.Handle) then
    raise Exception.Create('Internal Error: SubClassUnicodeControl.Control is not Unicode.');

  WinControlTrap := FindOrCreateWinControlTrap(Control);
  WinControlTrap.SubClassControl(Params_Caption);
  WinControlTrap.IDEWindow := IDEWindow;
end;


//----------------------------------------------- CREATE/DESTROY UNICODE HANDLE

var
  WindowAtom: TAtom;
  ControlAtom: TAtom;
  WindowAtomString: AnsiString;
  ControlAtomString: AnsiString;

type
  TWndProc = function(HWindow: HWnd; Message, WParam, LParam: Longint): Longint; stdcall;

function InitWndProcW(HWindow: HWnd; Message, WParam, LParam: Longint): Longint; stdcall;

    function GetObjectInstance(Control: TWinControl): Pointer;
    var
      WinControlTrap: TWinControlTrap;
    begin
      WinControlTrap := FindOrCreateWinControlTrap(Control);
      PendingRecreateWndTrapList.Add(WinControlTrap);
      Result := WinControlTrap.WinControl_ObjectInstance;
    end;

var
  ObjectInstance: Pointer;
begin
  TAccessWinControl(CreationControl).WindowHandle := HWindow;
  ObjectInstance := GetObjectInstance(CreationControl);
  {Controls.InitWndProc converts control to ANSI here by calling SetWindowLongA()!}
  SetWindowLongW(HWindow, GWL_WNDPROC, Integer(ObjectInstance));
  if  (GetWindowLongW(HWindow, GWL_STYLE) and WS_CHILD <> 0)
  and (GetWindowLongW(HWindow, GWL_ID) = 0) then
    SetWindowLongW(HWindow, GWL_ID, Integer(HWindow));
  SetProp(HWindow, MakeIntAtom(ControlAtom), THandle(CreationControl));
  SetProp(HWindow, MakeIntAtom(WindowAtom), THandle(CreationControl));
  CreationControl := nil;
  Result := TWndProc(ObjectInstance)(HWindow, Message, WParam, lParam);
end;

procedure RegisterUnicodeClass(Params: TCreateParams; out WideWinClassName: WideString; IDEWindow: Boolean = False);
var
  TempClass: TWndClassW;
  WideClass: TWndClassW;
  ClassRegistered: Boolean;
  InitialProc: TFNWndProc;
begin
  if IDEWindow then
    InitialProc := @InitWndProc
  else
    InitialProc := @InitWndProcW;

  with Params do begin
    WideWinClassName := WinClassName + UNICODE_CLASS_EXT;
    ClassRegistered := GetClassInfoW(hInstance, PWideChar(WideWinClassName), TempClass);
    if (not ClassRegistered) or (TempClass.lpfnWndProc <> InitialProc)
    then begin
      if ClassRegistered then Win32Check(Windows.UnregisterClassW(PWideChar(WideWinClassName), hInstance));
      // Prepare a TWndClassW record
      WideClass := TWndClassW(WindowClass);
      WideClass.hInstance := hInstance;
      WideClass.lpfnWndProc := InitialProc;
      WideClass.lpszMenuName := PWideChar(WideString(WindowClass.lpszMenuName));
      WideClass.lpszClassName := PWideChar(WideWinClassName);

      // Register the UNICODE class
      RegisterClassW(WideClass);
    end;
  end;
end;

procedure CreateUnicodeHandle(Control: TWinControl; const Params: TCreateParams;
                                        const SubClass: WideString; IDEWindow: Boolean = False);
var
  TempSubClass: TWndClassW;
  WideWinClassName: WideString;
  Handle: THandle;
begin
  if (not Win32PlatformIsUnicode) then begin
    with Params do
      TAccessWinControl(Control).WindowHandle := CreateWindowEx(ExStyle, WinClassName,
        Caption, Style, X, Y, Width, Height, WndParent, 0, WindowClass.hInstance, Param);
  end else begin
    // SubClass the unicode version of this control by getting the correct DefWndProc
    if (SubClass <> '')
    and GetClassInfoW(Params.WindowClass.hInstance, PWideChar(SubClass), TempSubClass) then
      TAccessWinControl(Control).DefWndProc := TempSubClass.lpfnWndProc
    else
      TAccessWinControl(Control).DefWndProc := @DefWindowProcW;

    // make sure Unicode window class is registered
    RegisterUnicodeClass(Params, WideWinClassName, IDEWindow);

    // Create UNICODE window handle
    UnicodeCreationControl := Control;
    try
      with Params do
        Handle := CreateWindowExW(ExStyle, PWideChar(WideWinClassName), nil,
          Style, X, Y, Width, Height, WndParent, 0, hInstance, Param);
      TAccessWinControl(Control).WindowHandle := Handle;
      if IDEWindow then
        SetWindowLongW(Handle, GWL_WNDPROC, GetWindowLong(Handle, GWL_WNDPROC));
    finally
      UnicodeCreationControl := nil;
    end;

    SubClassUnicodeControl(Control, Params.Caption, IDEWindow);
  end;
end;


//----------------------------------------------- GET/SET WINDOW TEXT

function WideGetWindowText(Control: TWinControl): WideString;
begin
  if (not Control.HandleAllocated)
  or (not IsWindowUnicode(Control.Handle)) then begin
    // NO HANDLE -OR- NOT UNICODE
    result := TAccessWinControl(Control).Text;
  end else begin
    // UNICODE & HANDLE
    SetLength(Result, GetWindowTextLengthW(Control.Handle) + 1);
    GetWindowTextW(Control.Handle, PWideChar(Result), Length(Result));
    SetLength(Result, Length(Result) - 1);
  end;
end;

procedure WideSetWindowText(Control: TWinControl; const Text: WideString);
begin
  if (not Control.HandleAllocated)
  or (not IsWindowUnicode(Control.Handle)) then begin
    // NO HANDLE -OR- NOT UNICODE
    TAccessWinControl(Control).Text := Text;
  end else if WideGetWindowText(Control) <> Text then begin
    // UNICODE & HANDLE
    SetWindowTextW(Control.Handle, PWideChar(Text));
    Control.Perform(CM_TEXTCHANGED, 0, 0);
  end;
end;



{ TUnicodeEdit }

procedure TUnicodeEdit.CreateWindowHandle(const Params: TCreateParams);
begin
  CreateUnicodeHandle(Self, Params, 'EDIT');
end;

function TUnicodeEdit.GetSelText: WideString;
begin
  Result := Copy(GetText, SelStart + 1, SelLength);
end;

function TUnicodeEdit.GetText: WideString;
begin
  Result := WideGetWindowText(Self);
end;

procedure TUnicodeEdit.SetSelText(const Value: WideString);
begin
  SendMessageW(Handle, EM_REPLACESEL, 0, Longint(PWideChar(Value)));
end;

procedure TUnicodeEdit.SetText(const Value: WideString);
begin
  WideSetWindowText(Self, Value);
end;


{ TUnicodeMemo }

procedure TUnicodeMemo.CreateWindowHandle(const Params: TCreateParams);
begin
  CreateUnicodeHandle(Self, Params, 'EDIT');
end;

function TUnicodeMemo.GetSelText: WideString;
begin
  Result := Copy(GetText, SelStart + 1, SelLength);
end;

function TUnicodeMemo.GetText: WideString;
begin
  Result := WideGetWindowText(Self);
end;

procedure TUnicodeMemo.SetSelText(const Value: WideString);
begin
  SendMessageW(Handle, EM_REPLACESEL, 0, Longint(PWideChar(Value)));
end;

procedure TUnicodeMemo.SetText(const Value: WideString);
begin
  WideSetWindowText(Self, Value);
end;


procedure InitControls;
var
  Controls_HInstance: Cardinal;
begin
  Controls_HInstance := FindClassHInstance(TWinControl);
  WindowAtomString := Format('Delphi%.8X',[GetCurrentProcessID]);
  ControlAtomString := Format('ControlOfs%.8X%.8X', [Controls_HInstance, GetCurrentThreadID]);
  WindowAtom := (GlobalAddAtom(PAnsiChar(WindowAtomString)));
  ControlAtom := (GlobalAddAtom(PAnsiChar(ControlAtomString)));
end;

initialization
  Win32PlatformIsUnicode := (Win32Platform = VER_PLATFORM_WIN32_NT);
  Win32PlatformIsXP := ((Win32MajorVersion = 5) and (Win32MinorVersion >= 1))
                    or  (Win32MajorVersion > 5);
  PendingRecreateWndTrapList := TList.Create;
  InitControls;

finalization
  GlobalDeleteAtom(ControlAtom);
  GlobalDeleteAtom(WindowAtom);
  PendingRecreateWndTrapList.Free;
  PendingRecreateWndTrapList := nil;
  Finalized := True;

end.


//0f31356a91fea3356e5f76cdce90aa7b