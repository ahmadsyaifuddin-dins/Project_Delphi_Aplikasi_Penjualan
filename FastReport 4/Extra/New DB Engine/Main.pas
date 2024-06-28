unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    AbbrE: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    TableE: TEdit;
    QueryE: TEdit;
    DatabaseE: TEdit;
    Button1: TButton;
    Button2: TButton;
    Bevel1: TBevel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    UnitsE: TEdit;
    CopyrightM: TMemo;
    Label9: TLabel;
    Label10: TLabel;
    CommentsM: TMemo;
    Label11: TLabel;
    PackageE: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure AbbrEExit(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}
{$I-}

type
  PCharArray = ^TCharArray;
  TCharArray = Array[0..32767] of Char;

procedure TForm1.Button1Click(Sender: TObject);
var
  BaseDir, NewDir: String;
  SearchRec: TSearchRec;
  r: Word;
  mem: PCharArray;
  memSize: Integer;

  procedure Replace(sFrom, sTo: String);
  var
    i, j: Integer;
    Flag: Boolean;
  begin
    while Pos('?', sFrom) <> 0 do
      sFrom[Pos('?', sFrom)] := #0;
    i := 0;
    while i < memSize do
    begin
      Flag := True;
      for j := 1 to Length(sFrom) do
        if AnsiCompareText(mem^[i + j - 1], sFrom[j]) <> 0 then
        begin
          Flag := False;
          break;
        end;
      if Flag then
      begin
        Move((PChar(mem) + i + Length(sFrom))^,
             (PChar(mem) + i + Length(sTo))^, memSize - (i + Length(sFrom)));
        for j := 1 to Length(sTo) do
          mem^[i + j - 1] := sTo[j];
        Inc(memSize, Length(sTo) - Length(sFrom));
      end;
      Inc(i);
    end;
  end;

  procedure ProcessFile(s: String);
  var
    n: Integer;
    stm: TMemoryStream;
    stm1: TFileStream;

    function MakeTwoChar(s: String): String;
    var
      i: Integer;
    begin
      Result := '';
      for i := 1 to Length(s) do
        Result := Result + s[i] + #0;
    end;

    function GetCopyText: String;
    var
      i: Integer;
    begin
      Result := '';
      for i := 0 to CopyrightM.Lines.Count - 1 do
        Result := Result + '// ' + CopyrightM.Lines[i] + #13#10;
    end;

  begin
    stm := TMemoryStream.Create;
    stm.LoadFromFile(BaseDir + '\' + s);
    FillChar(mem^, 32768, 0);
    Move(stm.Memory^, mem^, stm.Size);
    memSize := stm.Size;

    // components
    Replace('TXXXTable', TableE.Text);
    Replace('TXXXQuery', QueryE.Text);
    Replace('TXXXDatabase', DatabaseE.Text);
    // units
    Replace('UXXX', UnitsE.Text);
    // package
    Replace('PXXX', PackageE.Text);
    // dcr
    Replace('F?R?X?X?X?X?', MakeTwoChar('FRX' + AbbrE.Text));
    // other
    Replace('frxXXX', 'frx' + AbbrE.Text);
    Replace('XXX', AbbrE.Text);
    Replace('// Copyright', GetCopyText);
    Replace('IdCopyright', CopyrightM.Lines.Text);
    Replace('IdComments', CommentsM.Lines.Text);

    n := Pos('FRXXXX', AnsiUpperCase(s));
    if n <> 0 then
    begin
      Delete(s, n, 6);
      Insert('frx' + AbbrE.Text, s, n);
    end;
    stm1 := TFileStream.Create(NewDir + '\' + s, fmCreate);
    stm1.Write(mem^, memSize);
    stm1.Free;

    stm.Free;
  end;

begin
  if (Trim(AbbrE.Text) = '') or (Trim(TableE.Text) = '') or
     (Trim(QueryE.Text) = '') or (Trim(DatabaseE.Text) = '') or
     (Trim(UnitsE.Text) = '') or (Trim(PackageE.Text) = '') then
  begin
    MessageBox(0, PChar('You should fill all fields!'), PChar('Error'),
      mb_OK + mb_IconError);
    AbbrE.SetFocus;
    Exit;
  end;

  SetCurrentDir(ExtractFilePath(ParamStr(0)));
  BaseDir := GetCurrentDir + '\Template';
  ChDir('..');
  NewDir := GetCurrentDir + '\' + AbbrE.Text;
  New(mem);

// make dir
  MkDir(NewDir);

// processing files
  R := FindFirst(BaseDir + '\*.*', faAnyFile, SearchRec);
  while R = 0 do
  begin
    if (SearchRec.Attr and faDirectory) = 0 then
      ProcessFile(SearchRec.Name);
    R := FindNext(SearchRec);
  end;
  FindClose(SearchRec);

  Dispose(mem);

  MessageBox(0, PChar('Files are converted and placed in the ' +
    NewDir + ' folder.'), '', mb_OK + mb_IconInformation);
  Close;
end;

procedure TForm1.AbbrEExit(Sender: TObject);
begin
  if AbbrE.Text = '' then Exit;
  TableE.Text := 'T' + AbbrE.Text + 'Table';
  QueryE.Text := 'T' + AbbrE.Text + 'Query';
  DatabaseE.Text := 'T' + AbbrE.Text + 'Database';
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Close;
end;

end.
