unit alk_kat_start;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons, global;


type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnMachines: TButton;
    btnFeedersSplicing: TButton;
    btnKereses: TButton;
    cmbKeresesTipusa: TComboBox;
    edtKeresettAlkatresz: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    rdbD4: TRadioButton;
    rdbPipettak: TRadioButton;
    rdbF4: TRadioButton;
    rdbF5: TRadioButton;
    rdbF5HM: TRadioButton;
    rdbFeederS: TRadioButton;
    rdbFeederX: TRadioButton;
    rdbD1 : TRadioButton;
    rdbMTC2: TRadioButton;
    rdbSplicing: TRadioButton;
    rdbX4: TRadioButton;
    rdbHS60: TRadioButton;
    rdbS27: TRadioButton;
    rdbS23: TRadioButton;
    rdbHS50: TRadioButton;
    rdbWPW: TRadioButton;
    rdbSX4: TRadioButton;
    rdbX4i: TRadioButton;
    Shape1: TShape;
    procedure btnFeedersSplicingClick(Sender: TObject) ;
    procedure btnKeresesClick(Sender: TObject);
    procedure btnMachinesClick(Sender: TObject);
    procedure cmbKeresesTipusaChange(Sender: TObject);
    procedure edtKeresettAlkatreszKeyPress(Sender: TObject; var Key: char);
    procedure FormClose(Sender: TObject ; var CloseAction: TCloseAction) ;
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image1MouseEnter(Sender: TObject);
    procedure Image1MouseLeave(Sender: TObject);
    procedure rdbD1Change(Sender : TObject);
    procedure rdbD4Change(Sender: TObject);
    procedure rdbF4Change(Sender: TObject);
    procedure rdbF5Change(Sender: TObject);
    procedure rdbF5HMChange(Sender: TObject);
    procedure rdbFeederSChange(Sender: TObject);
    procedure rdbFeederXChange(Sender: TObject);
    procedure rdbHS50Change(Sender: TObject);
    procedure rdbHS60Change(Sender: TObject);
    procedure rdbMTC2Change(Sender: TObject);
    procedure rdbPipettakChange(Sender: TObject);
    procedure rdbS23Change(Sender: TObject);
    procedure rdbS27Change(Sender: TObject);
    procedure rdbSplicingChange(Sender: TObject) ;
    procedure rdbSX4Change(Sender: TObject);
    procedure rdbWPWChange(Sender: TObject);
    procedure rdbX4Change(Sender: TObject);
    procedure rdbX4iChange(Sender: TObject);
  private
    { private declarations }
		//1=F4;2=F5;3=F5HM;4=S_FEEDERS;5=X_FEEDERS;6=HS50;7=HS60;8=S23HM;9=S27HM;10=SPLICING;11=WPW_80F_3;12=X4
    iMachineType : Integer;
    sMachineType : String;

    //
    iFeederType : Integer;
    sFeederType : String;

  public
    { public declarations }
  end; 

var
  frmMain: TfrmMain;

implementation
              uses Machines, kereses_eredmenye, beallitasok;

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
var
  myDate : TDateTime;
  myYear, myMonth, myDay : Word;
	store,sMessage:	string;
  FAge,i: Integer;
  FileParam: TDateTime;
  err: boolean;
  //errdesc: integer;

begin
		MyDir := ExtractFilePath(ParamStr(0));
    bRaktarkeszletCopy := true;
    iMachineType:=1;
    sMachineType:='Siplace F4';
    iFeederType := 4;
    sFeederType := 'Siplace S';

  	//Masolat keszitese az eredeti raktarkeszletrol ??s ??tnevez??se :
    Randomize;
    i := Random(20000);
  	InputFileName := MyDir + 'raktar' + IntToStr(i) + '.xls';

    myDate := Now;
    DecodeDate(myDate, myYear, myMonth, myDay);

    store := 'u:\Maintenance\store new\'+IntToStr(myYear)+'\inventory of store '+IntToStr(myYear)+'.xls';
    //store := MyDir + 'raktarkeszlet\inventory of store '+IntToStr(myYear)+'.xls';

    //FAge:=FileAge(store);
    //FileParam:=FileDateToDateTime(FAge);

    err := CopyFile(PChar(store),PChar(InputFileName),false);
    if (err = false) then
    begin
      //errdesc:=GetLastOSError();
      sMessage:='Nem lehet m??solatot k??sz??teni a rakt??rk??szletr??l,'+#13;
      sMessage:=sMessage+'val??sz??n??leg valaki haszn??lja a f??jlt!'+#13+#13;
      sMessage:=sMessage+'Emiatt a rakt??rk??szletre vonatkoz?? adatok nem fognak megjelenni!';
      ShowMessage(sMessage);
      bRaktarkeszletCopy := false;
      exit;
    end;

    if (bRaktarkeszletCopy) then repeat until FileExists(InputFileName);

end;

procedure TfrmMain.Image1Click(Sender: TObject);
var
  sJelszo : string;
begin
  //be??ll??t??sok...
  sJelszo := PasswordBox('Jelsz?? bek??r??s...','Jelsz?? : ');
  if trim(sJelszo) <> 'kincso' then exit;
  frmBeallitasok.Show;
  frmMain.Hide;
end;

procedure TfrmMain.Image1MouseEnter(Sender: TObject);
begin
  Image1.Width := Image1.Width + 3;
  Image1.Height := Image1.Height + 3;
end;

procedure TfrmMain.Image1MouseLeave(Sender: TObject);
begin
  Image1.Width := Image1.Width - 3;
  Image1.Height := Image1.Height - 3;
end;

procedure TfrmMain.rdbD1Change(Sender : TObject);
begin
  iMachineType := 13;
  sMachineType := 'Siplace D1';
end;

procedure TfrmMain.rdbD4Change(Sender: TObject);
begin
  iMachineType := 16;
  sMachineType := 'Siplace D4';
end;

procedure TfrmMain.rdbF4Change(Sender: TObject);
begin
  iMachineType:=1;
  sMachineType:='Siplace F4';
end;

procedure TfrmMain.rdbF5Change(Sender: TObject);
begin
  iMachineType:=2;
  sMachineType:='Siplace F5';
end;

procedure TfrmMain.rdbF5HMChange(Sender: TObject);
begin
  iMachineType:=3;
  sMachineType:='Siplace F5HM';
end;

procedure TfrmMain.rdbFeederSChange(Sender: TObject);
begin
  iFeederType:=4;
  sFeederType:='Siplace S';
end;

procedure TfrmMain.rdbFeederXChange(Sender: TObject);
begin
  iFeederType:=5;
  sFeederType:='Siplace X';
end;

procedure TfrmMain.rdbHS50Change(Sender: TObject);
begin
  iMachineType:=6;
  sMachineType:='Siplace HS50';
end;

procedure TfrmMain.rdbHS60Change(Sender: TObject);
begin
  iMachineType:=7;
  sMachineType:='Siplace HS60';
end;

procedure TfrmMain.rdbMTC2Change(Sender: TObject);
begin
  iMachineType:=18;
  sMachineType:='MTC2...';
end;

procedure TfrmMain.rdbPipettakChange(Sender: TObject);
begin
  iMachineType:=17;
  sMachineType:='Pipett??k...';
end;

procedure TfrmMain.rdbS23Change(Sender: TObject);
begin
  iMachineType:=8;
  sMachineType:='Siplace S23';
end;

procedure TfrmMain.rdbS27Change(Sender: TObject);
begin
  iMachineType:=9;
  sMachineType:='Siplace S27';
end;

procedure TfrmMain.rdbSplicingChange(Sender: TObject) ;
begin
  iFeederType:=10;
  sFeederType:='Splicing';
end;

procedure TfrmMain.rdbWPWChange(Sender: TObject);
begin
  iMachineType:=11;
  sMachineType:='Siplace WPW';
end;

procedure TfrmMain.rdbX4Change(Sender: TObject);
begin
  iMachineType:=12;
  sMachineType:='Siplace X4';
end;

procedure TfrmMain.rdbSX4Change(Sender: TObject);
begin
  iMachineType:=14;
  sMachineType:='Siplace SX4';
end;

procedure TfrmMain.rdbX4iChange(Sender: TObject);
begin
  iMachineType:=15;
  sMachineType:='Siplace X4i';
end;

procedure TfrmMain.btnMachinesClick(Sender: TObject);
begin
  //Kiv??lasztott g??pt??pus adatainak megjelen??t??se :
  frmMain.Hide;
  frmGepalkatreszek.iMachineType := iMachineType;
  frmGepalkatreszek.sMachineType := sMachineType;
  frmGepalkatreszek.Caption := sMachineType+' be??ltet??g??p alkatr??szkatal??gus...';
  frmGepalkatreszek.Show;
end;

procedure TfrmMain.cmbKeresesTipusaChange(Sender: TObject);
begin
  edtKeresettAlkatresz.Text:='';
  edtKeresettAlkatresz.SetFocus;
end;

procedure TfrmMain.edtKeresettAlkatreszKeyPress(Sender: TObject; var Key: char);
begin
  //Alkatr??sz keres??se.....
  if (Key = chr(13)) then
  begin
    iKeresesTipus := cmbKeresesTipusa.ItemIndex;
  	sKeresettAlkatresz := edtKeresettAlkatresz.Text;
  	frmMain.Hide;
    frmKeresesEredmenye.iMachineType := iMachineType;
    frmKeresesEredmenye.sMachineType := sMachineType;
  	frmKeresesEredmenye.Show;
  end;
end;

procedure TfrmMain.FormClose(Sender: TObject ; var CloseAction: TCloseAction) ;
begin
    //??tmeneti rakt??k??szlet f??jl t??rl??se :
  	DeleteFile(InputFileName);
end;

procedure TfrmMain.btnFeedersSplicingClick(Sender: TObject) ;
begin
	//Kiv??lasztott t??pus?? feeder vagy splicing alkatr??szek :
  frmMain.Hide;
  frmGepalkatreszek.iMachineType := iFeederType;
  frmGepalkatreszek.sMachineType := sFeederType;
  frmGepalkatreszek.Caption := sFeederType + ' adagol?? alkatr??szkatal??gus...';
  frmGepalkatreszek.Show;
end;

procedure TfrmMain.btnKeresesClick(Sender: TObject);
begin
  //Alkatr??sz keres??se.....
  iKeresesTipus := cmbKeresesTipusa.ItemIndex;
  sKeresettAlkatresz := edtKeresettAlkatresz.Text;
  frmMain.Hide;
  frmKeresesEredmenye.iMachineType := iMachineType;
  frmKeresesEredmenye.sMachineType := sMachineType;
  frmKeresesEredmenye.Show;
end;

initialization
  {$I alk_kat_start.lrs}

end.

