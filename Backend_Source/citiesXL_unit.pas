Unit citiesXL_unit;

Interface

Uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs,StdCtrls,
  FileCtrl, ComCtrls, ExtCtrls, IniFiles,
 Gauges,citiesXL_PAK_unit;


Type TButton = class(StdCtrls.TButton)
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  end;


Type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    OpenDialog1: TOpenDialog;
    Edit1: TEdit;
    Edit2: TEdit;
    Button_XtractAll: TButton;
    ComboBox_use_Zlib: TComboBox;
    Button_MakeArchive: TButton;
    Gauge1: TGauge;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);

    procedure Button_XtractAllClick(Sender: TObject);
    procedure Button_MakeArchiveClick(Sender: TObject);

  private
    { Private declarations }
    procedure onWMLBUTTONDOWN(var Msg: TMessage); message WM_LBUTTONDOWN;
  protected
    Procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public declarations }
  end;

Const sz_BACTER_CLASS : PChar = 'BACTER_APP_CLASS';

Var
  Form1: TForm1;

implementation

{$R *.dfm}


Procedure TButton.CreateParams(var Params: TCreateParams);
Begin
  Inherited CreateParams(Params);
  Params.Style := Params.Style Or BS_FLAT;
End;


procedure TForm1.onWMLBUTTONDOWN(var Msg: TMessage);
begin
  SendMessage(Handle,WM_NCLBUTTONDOWN,HTCAPTION,Msg.lParam);
end;

Procedure TForm1.CreateParams(var Params: TCreateParams);
Begin
  Inherited CreateParams(Params);
  Move(sz_BACTER_CLASS[0],Params.WinClassName[0],StrLen(sz_BACTER_CLASS)+1);
End;


Function Get_ZLib_mode_Object_from_list : Integer;
// a "Form1.FlatComboBox_use_Zlib" aktualis elemehez tartozo Object erteket adja vissza
Var I : Integer;
Begin {Func. Get_ZLib_mode_Object_from_list}
  I := Form1.ComboBox_use_Zlib.ItemIndex;
  If I < 0 Then
    Begin
      Result := -1;
    End Else
    Begin
      Result := Integer( Form1.ComboBox_use_Zlib.Items.Objects[I] );
    End;
  //vk_DebugPrintS('Zlib_mode lekérdezés : '+SzamTagol(Result));
End;  {Func. Get_ZLib_mode_Object_from_list}


procedure TForm1.FormCreate(Sender: TObject);
Var S,S0 : String;
    I : Integer;
Var Mode : String;

begin {proc. TForm1.FormCreate}
  Caption := 'CitiesXL eXtractor / Maker [v'+PAK_Unit_Version+' FINAL ]';
  Application.Title := Caption;
// [akLeft,akTop,akRight,akBottom]

  ComboBox_use_Zlib.Items.Clear;
  ComboBox_use_Zlib.Items.AddObject('never',Pointer(_citiesXL_comp_NONE));
  ComboBox_use_Zlib.Items.AddObject('clever',Pointer(_citiesXL_comp_CLEVER));
  ComboBox_use_Zlib.Items.AddObject('always',Pointer(_citiesXL_comp_FORCE_ZLIB));
  ComboBox_use_Zlib.ItemIndex := 2; //

  Mode := ParamStr(1);
  Edit1.Text := ParamStr(2);
  Edit2.Text := ParamStr(3);
  If Mode = 'x' then
    Begin
       
    End;
  If Mode = 'c' then
    Begin

    End;
end;  {proc. TForm1.FormCreate}


Procedure CallBack2(L:LongInt;pFileName:PChar);
Var Db,Index : LongInt;
    Szazalek : Integer;
Begin
  //If Szamoljal Then
  //  Begin
  //    If L <> 0 Then Inc(Szamlalo);
  //  End;
  Index := L And $FFFF;
  Db := L Shr 16;
  If Db = 0 Then Szazalek := 0
            Else Szazalek := (Index*100) Div Db;
  If (L <> 0) Or (pFileName = NIL) Then Form1.Gauge1.Progress := Szazalek;
  Form1.caption := pFileName;
  Application.ProcessMessages;
End;


procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin  {proc. TForm1.FormClose}
  CallBack2(0,'Exiting...');
end;   {proc. TForm1.FormClose}

procedure TForm1.FormResize(Sender: TObject);
Const MinW = 450;
      MinH = 135;
      MaxH = 150;
begin {proc. TForm1.FormResize}
  If Width < MinW Then Width := MinW;
  If Height < MinH Then Height := MinH;
  If MaxH < Height Then Height := MaxH;
end;  {proc. TForm1.FormResize}


procedure TForm1.Button_MakeArchiveClick(Sender: TObject);
Var SrcDir,TrgtARCHIVEfileName : String;
    FilesNum : Integer;
    Success : Boolean;
    CompressionMode : Integer;

Begin {proc. TForm1.Button_MakeArchiveClick}
  TrgtARCHIVEfileName := Edit1.Text;
  If TrgtARCHIVEfileName = '' Then
    Begin
      Exit;
    End;
  SrcDir := Edit2.Text;
  If SrcDir = '' Then
    Begin
      Exit;
    End;
  If FileExists(TrgtARCHIVEfileName) Then
    Begin
      //  CONFIRMATION!
      If MessageDlg('Warning!'#13'The given file already exists!'+
                     #13'Do you really want to overwrite it?',
                     mtConfirmation, [mbYes, mbNo], 0) <> mrYes Then Exit;
    End;

  CompressionMode := Get_ZLib_mode_Object_from_list;
  Success := CitiesXL_PAK_maker_bacter(SrcDir,
                                       TrgtARCHIVEfileName,
                                       CompressionMode,
                                       CallBack2,FilesNum);

  If Not Success Then
    Begin
      Caption := 'Error :-(';
    End Else
    Begin
      Caption := 'O.K. Packed: ' + IntToStr(FilesNum)+' files!';
    End;
End;  {proc. TForm1.Button_MakeArchiveClick}


Procedure Extraction(FileName,TargetName : String);
Var Nr : Integer;
    pak_FileName,TargetDir : String;
    Success : Boolean;
    S : String;
Begin {Proc. Extraction}
  pak_FileName := FileName;
  TargetDir := TargetName;
  Nr := CitiesXL_PAK_eXtract_bacter(pak_fileName,TargetDir,CallBack2,Success);
  If Success Then
    Begin
      S := 'O.K. Successfully extracted '+ IntToStr(Nr)+' files!';
    End Else
    Begin
      S := 'Error :-(';
    End;
  Form1.Caption := S;
End;  {Proc. Extraction}

procedure TForm1.Button_XtractAllClick(Sender: TObject);
begin
  Extraction(Edit1.Text, Edit2.Text);
end;


end.
