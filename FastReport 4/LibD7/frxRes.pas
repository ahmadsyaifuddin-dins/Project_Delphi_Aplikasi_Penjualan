
{******************************************}
{                                          }
{             FastReport v4.0              }
{      Language resources management       }
{                                          }
{         Copyright (c) 1998-2006          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxRes;

interface

{$I frx.inc}

uses
  Windows, SysUtils, Classes, Controls, Graphics, Forms, ImgList, TypInfo
{$IFDEF Delphi6}
, Variants
{$ENDIF}
;


type

  TfrxResources = class(TObject)

  private
    FDisabledButtonImages: TImageList;
    FMainButtonImages: TImageList;
    FNames: TStringList;
    FObjectImages: TImageList;
    FPreviewButtonImages: TImageList;
    FValues: TStringList;
    FWizardImages: TImageList;
    FLanguages: TStringList;
    FHelpFile: String;
    procedure BuildLanguagesList;
    function GetMainButtonImages: TImageList;
    function GetObjectImages: TImageList;
    function GetPreviewButtonImages: TImageList;
    function GetWizardImages: TImageList;
  public

    constructor Create;

    destructor Destroy; override;
    function Get(const StrName: String): String;
    procedure Add(const Ref, Str: String);
    procedure AddStrings(const Str: String);
    procedure Clear;
    procedure LoadFromFile(const FileName: String);
    procedure LoadFromStream(Stream: TStream);
    procedure SetButtonImages(Images: TBitmap; Clear: Boolean = False);
    procedure SetObjectImages(Images: TBitmap; Clear: Boolean = False);
    procedure SetPreviewButtonImages(Images: TBitmap; Clear: Boolean = False);
    procedure SetWizardImages(Images: TBitmap; Clear: Boolean = False);
    procedure UpdateFSResources;
    procedure Help(Sender: TObject); overload;
    property DisabledButtonImages: TImageList read FDisabledButtonImages;
    property MainButtonImages: TImageList read GetMainButtonImages;
    property PreviewButtonImages: TImageList read GetPreviewButtonImages;
    property ObjectImages: TImageList read GetObjectImages;
    property WizardImages: TImageList read GetWizardImages;
    property Languages: TStringList read FLanguages;
    property HelpFile: String read FHelpFile write FHelpFile;

  end;

function frxResources: TfrxResources;
function frxGet(ID: Integer): String;


implementation

uses frxUtils, frxChm, fs_iconst, frxGZip;

var
  FResources: TfrxResources = nil;


{ TfrxResources }

constructor TfrxResources.Create;
begin
  inherited;
  FDisabledButtonImages := TImageList.Create(nil);
  FDisabledButtonImages.Width := 16;
  FDisabledButtonImages.Height := 16;
  FMainButtonImages := TImageList.Create(nil);
  FMainButtonImages.Width := 16;
  FMainButtonImages.Height := 16;
  FObjectImages := TImageList.Create(nil);
  FObjectImages.Width := 16;
  FObjectImages.Height := 16;
  FPreviewButtonImages := TImageList.Create(nil);
  FPreviewButtonImages.Width := 16;
  FPreviewButtonImages.Height := 16;
  FWizardImages := TImageList.Create(nil);
  FWizardImages.Width := 32;
  FWizardImages.Height := 32;
  FNames := TStringList.Create;
  FValues := TStringList.Create;
  FNames.Sorted := True;
  FLanguages := TStringList.Create;
  HelpFile := 'FRUser.chm';
  BuildLanguagesList;
end;

destructor TfrxResources.Destroy;
begin
  FLanguages.Free;
  FDisabledButtonImages.Free;
  FMainButtonImages.Free;
  FObjectImages.Free;
  FPreviewButtonImages.Free;
  FWizardImages.Free;
  FNames.Free;
  FValues.Free;
  inherited;
end;

procedure TfrxResources.Add(const Ref, Str: String);
var
  i: Integer;
begin
  i := FNames.IndexOf(Ref);
  if i = -1 then
  begin
    FNames.AddObject(Ref, Pointer(FValues.Count));
    FValues.Add(Str);
  end
  else
    FValues[Integer(FNames.Objects[i])] := Str;
end;

procedure TfrxResources.AddStrings(const Str: String);
var
  i: Integer;
  sl: TStringList;
  nm, vl: String;
begin
  sl := TStringList.Create;
  sl.Text := Str;
  for i := 0 to sl.Count - 1 do
  begin
    nm := sl[i];
    vl := Copy(nm, Pos('=', nm) + 1, MaxInt);
    nm := Copy(nm, 1, Pos('=', nm) - 1);
    if (nm <> '') and (vl <> '') then
      Add(nm, vl);
  end;
  sl.Free;
end;

procedure TfrxResources.Clear;
begin
  FNames.Clear;
  FValues.Clear;
end;

function TfrxResources.Get(const StrName: String): String;
var
  i: Integer;
begin
  i := FNames.IndexOf(StrName);
  if i <> -1 then
    Result := FValues[Integer(FNames.Objects[i])] else
    Result := StrName;
  if (Result <> '') and (Result[1] = '!') then
    Delete(Result, 1, 1);
end;

function TfrxResources.GetMainButtonImages: TImageList;
var
  Images: TBitmap;
  stm: TMemoryStream;
  res: TResourceStream;
begin
  if FMainButtonImages.Count = 0 then
  begin
    Images := TBitmap.Create;
    stm := TMemoryStream.Create;
    res := TResourceStream.Create(hInstance, 'DesgnButtons', RT_RCDATA);
    try
      frxDecompressStream(res, stm);
      stm.Position := 0;
      Images.LoadFromStream(stm);
      SetButtonImages(Images);
    finally
      stm.Free;
      res.Free;
      Images.Free;
    end;
  end;

  Result := FMainButtonImages;
end;

function TfrxResources.GetPreviewButtonImages: TImageList;
var
  Images: TBitmap;
  stm: TMemoryStream;
  res: TResourceStream;
begin
  if FPreviewButtonImages.Count = 0 then
  begin
    Images := TBitmap.Create;
    stm := TMemoryStream.Create;
    res := TResourceStream.Create(hInstance, 'PreviewButtons', RT_RCDATA);
    try
      frxDecompressStream(res, stm);
      stm.Position := 0;
      Images.LoadFromStream(stm);
      SetPreviewButtonImages(Images);
    finally
      stm.Free;
      res.Free;
      Images.Free;
    end;
  end;

  Result := FPreviewButtonImages;
end;

function TfrxResources.GetObjectImages: TImageList;
var
  Images: TBitmap;
  stm: TMemoryStream;
  res: TResourceStream;
begin
  if FObjectImages.Count = 0 then
  begin
    Images := TBitmap.Create;
    stm := TMemoryStream.Create;
    res := TResourceStream.Create(hInstance, 'ObjectButtons', RT_RCDATA);
    try
      frxDecompressStream(res, stm);
      stm.Position := 0;
      Images.LoadFromStream(stm);
      SetObjectImages(Images);
    finally
      stm.Free;
      res.Free;
      Images.Free;
    end;
  end;

  Result := FObjectImages;
end;

function TfrxResources.GetWizardImages: TImageList;
var
  Images: TBitmap;
  stm: TMemoryStream;
  res: TResourceStream;
begin
  if FWizardImages.Count = 0 then
  begin
    Images := TBitmap.Create;
    stm := TMemoryStream.Create;
    res := TResourceStream.Create(hInstance, 'WizardButtons', RT_RCDATA);
    try
      frxDecompressStream(res, stm);
      stm.Position := 0;
      Images.LoadFromStream(stm);
      SetWizardImages(Images);
    finally
      stm.Free;
      res.Free;
      Images.Free;
    end;
  end;

  Result := FWizardImages;
end;

procedure TfrxResources.SetButtonImages(Images: TBitmap; Clear: Boolean = False);
begin
  if Clear then
  begin
    FMainButtonImages.Clear;
    FDisabledButtonImages.Clear;
  end;
  frxAssignImages(Images, 16, 16, FMainButtonImages, FDisabledButtonImages);
end;

procedure TfrxResources.SetObjectImages(Images: TBitmap; Clear: Boolean = False);
begin
  if Clear then
    FObjectImages.Clear;
  frxAssignImages(Images, 16, 16, FObjectImages);
end;

procedure TfrxResources.SetPreviewButtonImages(Images: TBitmap; Clear: Boolean = False);
begin
  if Clear then
    FPreviewButtonImages.Clear;
  frxAssignImages(Images, 16, 16, FPreviewButtonImages);
end;

procedure TfrxResources.SetWizardImages(Images: TBitmap; Clear: Boolean = False);
begin
  if Clear then
    FWizardImages.Clear;
  frxAssignImages(Images, 32, 32, FWizardImages);
end;

procedure TfrxResources.LoadFromFile(const FileName: String);
var
  f: TFileStream;
begin
  if FileExists(FileName) then
  begin
    f := TFileStream.Create(FileName, fmOpenRead);
    try
      LoadFromStream(f);
    finally
      f.Free;
    end;
  end;
end;

procedure TfrxResources.LoadFromStream(Stream: TStream);
var
  sl: TStringList;
  i: Integer;
  nm, vl: String;
begin
  sl := TStringList.Create;
  try
    sl.LoadFromStream(Stream);
    Clear;
    for i := 0 to sl.Count - 1 do
    begin
      nm := sl[i];
      vl := Copy(nm, Pos('=', nm) + 1, MaxInt);
      nm := Copy(nm, 1, Pos('=', nm) - 1);
      if (nm <> '') and (vl <> '') then
        Add(nm, vl);
    end;
  finally
    sl.Free;
  end;
  UpdateFSResources;
end;

procedure TfrxResources.UpdateFSResources;
begin
  SLangNotFound := Get('SLangNotFound');
  SInvalidLanguage := Get('SInvalidLanguage');
  SIdRedeclared := Get('SIdRedeclared');
  SUnknownType := Get('SUnknownType');
  SIncompatibleTypes := Get('SIncompatibleTypes');
  SIdUndeclared := Get('SIdUndeclared');
  SClassRequired := Get('SClassRequired');
  SIndexRequired := Get('SIndexRequired');
  SStringError := Get('SStringError');
  SClassError := Get('SClassError');
  SArrayRequired := Get('SArrayRequired');
  SVarRequired := Get('SVarRequired');
  SNotEnoughParams := Get('SNotEnoughParams');
  STooManyParams := Get('STooManyParams');
  SLeftCantAssigned := Get('SLeftCantAssigned');
  SForError := Get('SForError');
  SEventError := Get('SEventError');
end;

type
  THelpTopic = record
    Sender: String;
    Topic: String;
  end;

const
  helpTopicsCount = 17;
  helpTopics: array[0..helpTopicsCount - 1] of THelpTopic =
   ((Sender: 'TfrxDesignerForm'; Topic: 'Designer.htm'),
    (Sender: 'TfrxOptionsEditor'; Topic: 'Designer_options.htm'),
    (Sender: 'TfrxReportEditorForm'; Topic: 'Report_options.htm'),
    (Sender: 'TfrxPageEditorForm'; Topic: 'Page_options.htm'),
    (Sender: 'TfrxCrossEditorForm'; Topic: 'Cross_tab_reports.htm'),
    (Sender: 'TfrxChartEditorForm'; Topic: 'Diagrams.htm'),
    (Sender: 'TfrxSyntaxMemo'; Topic: 'Script.htm'),
    (Sender: 'TfrxDialogPage'; Topic: 'Dialogue_forms.htm'),
    (Sender: 'TfrxDialogComponent'; Topic: 'Data_access_components.htm'),
    (Sender: 'TfrxVarEditorForm'; Topic: 'Variables.htm'),
    (Sender: 'TfrxHighlightEditorForm'; Topic: 'Conditional_highlighting.htm'),
    (Sender: 'TfrxSysMemoEditorForm'; Topic: 'Inserting_aggregate_function.htm'),
    (Sender: 'TfrxFormatEditorForm'; Topic: 'Values_formatting.htm'),
    (Sender: 'TfrxGroupEditorForm'; Topic: 'Report_with_groups.htm'),
    (Sender: 'TfrxPictureEditorForm'; Topic: 'Picture_object.htm'),
    (Sender: 'TfrxMemoEditorForm'; Topic: 'Text_object.htm'),
    (Sender: 'TfrxSQLEditorForm'; Topic: 'TfrxADOQuery.htm')
   );




procedure TfrxResources.Help(Sender: TObject);
var
  i: Integer;
  topic: String;
begin
  topic := '';
  if Sender <> nil then
    for i := 0 to helpTopicsCount - 1 do
      if CompareText(helpTopics[i].Sender, Sender.ClassName) = 0 then
        topic := '::/' + helpTopics[i].Topic;
  frxDisplayHHTopic(Application.Handle, FHelpFile + topic);
end;

procedure TfrxResources.BuildLanguagesList;
var
  i: Integer;
  SRec: TSearchRec;
  Dir: String;
  s: String;
begin
  Dir := GetAppPath;
  FLanguages.Clear;
  i := FindFirst(Dir + '*.frc', faAnyFile, SRec);
  try
    while i = 0 do
    begin
      s := LowerCase(SRec.Name);
      s := UpperCase(Copy(s, 1, 1)) + Copy(s, 2, Length(s) - 1);
      s := StringReplace(s, '.frc', '', []);
      FLanguages.Add(s);
      i := FindNext(SRec);
    end;
    FLanguages.Sort;
  finally
    FindClose(Srec);
  end;
end;


function frxResources: TfrxResources;
begin
  if FResources = nil then

    FResources := TfrxResources.Create;

  Result := FResources;
end;

function frxGet(ID: Integer): String;
begin
  Result := frxResources.Get(IntToStr(ID));
end;




initialization

finalization
  if FResources <> nil then
    FResources.Free;
  FResources := nil;

end.


//0f31356a91fea3356e5f76cdce90aa7b