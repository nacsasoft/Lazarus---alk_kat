unit kereses_eredmenye;

{$mode objfpc}

interface

uses
  Classes, SysUtils, db, Sqlite3DS, sqldb, sqlite3conn, FileUtil, LResources,
  Forms, Controls, Graphics, Dialogs, ComCtrls, Grids, DBGrids, StdCtrls,
  ExtCtrls, Buttons, database, global, fpspreadsheet, fpsTypes, laz_fpspreadsheet , types;

type

  { TfrmKeresesEredmenye }

  TfrmKeresesEredmenye = class(TForm)
    btnFirst: TBitBtn;
    btnLast: TBitBtn;
    btnNext: TBitBtn;
    btnPrev: TBitBtn;
    dbgKeresesEredmenye: TDBGrid;
    dtsKeresesEredmenye: TDatasource;
    dtsParts: TDatasource;
    edtConsig: TEdit;
    edtCost: TEdit;
    edtLokacio: TEdit;
    edtMAX: TEdit;
    edtMIN: TEdit;
    edtNew: TEdit;
    edtUsed: TEdit;
    edtMKB: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    imgPart: TImage;
    ScrollBox1: TScrollBox;
    sqlKeresesEredmenye: TSqlite3Dataset;
    sqlParts: TSqlite3Dataset;
    StaticText1: TStaticText;
    StaticText10: TStaticText;
    StaticText11: TStaticText;
    StaticText12: TStaticText;
    StaticText13: TStaticText;
    StaticText14: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    StaticText5: TStaticText;
    StaticText6: TStaticText;
    StaticText7: TStaticText;
    StaticText8: TStaticText;
    StaticText9: TStaticText;
    stcCurrency: TStaticText;
    procedure btnFirstClick(Sender: TObject);
    procedure btnLastClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnPrevClick(Sender: TObject);
    procedure dbgKeresesEredmenyeCellClick(Column: TColumn);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure imgPartMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgPartMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure imgPartMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgPartMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure imgPartMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
  private
    { private declarations }
    myDataset						: TSqlite3Dataset;
    sImgPath						:	string;		//kategóriához tartozó képek útvonala
    sMachine						:	string;		//Géptípus
    iAlkatMax						: integer;	//Alkategóriák száma
    iAlkatIndex					: integer;	//Aktuálisan megjelenített alkategória
    LMButton						: Boolean;	//=True akkor a bal egérgomb lenyomva...
    tmp									: Boolean;	//Képmozgatáshoz....
    Mouse								: TPoint;		//Képmozgatáshoz....
    category_id					:	integer;

    //Raktarkeszlet...
    MyWorkbook: TsWorkbook;
  	MyWorksheet: TsWorksheet;
    iRowNum				: integer;		//excel sorok száma...


  public
    { public declarations }
    //1=F4;2=F5;3=F5HM;4=S_FEEDERS;5=X_FEEDERS;6=HS50;7=HS60;8=S23HM;9=S27HM;10=SPLICING;11=WPW_80F_3;12=X4
    iMachineType : Integer;
    sMachineType : string;

    iZoomFactor,iZoomLevel : Integer;

  end;

  //Kategória adatok :
  type datas = record
        p_id				: integer;		//Alkatrészazonosító
        p_ordernum	: string;			//Rendelési szám
        p_desc			: string;			//Alkatrész megnevezése
        c_id				: integer;		//Kategóri azonosító
        c_name 			: string;			//Kategória neve pl.: 12_segm_10000_head
        machine_name: string;			//Gép neve
        c_images		: integer;		//Kategóriához tartozó képek száma... 1-
  end;

  //Raktárkészlet :
  type store_datas = record
  			sLocation		: string;
        sPartName		: string;
        sPartNum		: string;
        sUsed				: string;
        sConsig			: string;
        sMKB        : string;
        sNew				: string;
        sCost				: string;
        sCurrency		: string;
        sMin				: string;
        sMax				: string;
        sRemark     : string;
  end;

var
  frmKeresesEredmenye: TfrmKeresesEredmenye;
  category_datas : array of datas;
  store_infos 				: array of store_datas;

implementation

uses
  	alk_kat_start;

{ TfrmKeresesEredmenye }

procedure TfrmKeresesEredmenye.FormShow(Sender: TObject);
var
  i,j				: integer;
  sSQL			: widestring;
  sp_id     : string;

begin
  if (bRaktarkeszletCopy = true) then
  begin
  // Create the spreadsheet
  MyWorkbook := TsWorkbook.Create;
  MyWorkbook.ReadFromFile(InputFileName, sfExcel8);
  MyWorksheet := MyWorkbook.GetFirstWorksheet;
  //Raktárkészlet beolvasása - excel-ből, tömbbe :
  iRowNum:=MyWorksheet.GetLastRowNumber;

  SetLength(store_infos,iRowNum+1);

  for i := 1 to iRowNum do
  begin
       store_infos[i].sLocation:=Utf8ToAnsi(MyWorksheet.ReadAsUTF8Text(i,0));
       store_infos[i].sPartName:=Utf8ToAnsi(MyWorksheet.ReadAsUTF8Text(i,1));
       store_infos[i].sPartNum:=Utf8ToAnsi(MyWorksheet.ReadAsUTF8Text(i,2));
       store_infos[i].sUsed:=Utf8ToAnsi(MyWorksheet.ReadAsUTF8Text(i,4));
       store_infos[i].sConsig:=Utf8ToAnsi(MyWorksheet.ReadAsUTF8Text(i,5));
       store_infos[i].sMKB:=Utf8ToAnsi(MyWorksheet.ReadAsUTF8Text(i,6));
       store_infos[i].sNew:=Utf8ToAnsi(MyWorksheet.ReadAsUTF8Text(i,7));
       store_infos[i].sCost:=Utf8ToAnsi(MyWorksheet.ReadAsUTF8Text(i,9));
       store_infos[i].sCurrency:=UpperCase(Utf8ToAnsi(MyWorksheet.ReadAsUTF8Text(i,10)));
       store_infos[i].sMin:=Utf8ToAnsi(MyWorksheet.ReadAsUTF8Text(i,13));
       store_infos[i].sMax:=Utf8ToAnsi(MyWorksheet.ReadAsUTF8Text(i,14));
       store_infos[i].sRemark:=Utf8ToAnsi(MyWorksheet.ReadAsUTF8Text(i,15));
  end ;
  MyWorkbook.Free;
  end;

  edtConsig.Text := '-';
  edtUsed.Text := '-';
  edtNew.Text := '-';
  edtLokacio.Text := '-';
  edtCost.Text := '-';
  edtMIN.Text := '-';
  edtMAX.Text := '-';
  edtMKB.Text := '-';

  //Keresés eredményének megjelenítése a dbgrid-be:
  sqlKeresesEredmenye.FileName:=dbPath;
  sSQL := 'select parts.p_id ,parts.p_ordernum ';
  sSQL := sSQL + ',parts.p_desc ,category.id as cat_id,category.c_images as cat_images';
  sSQL := sSQL + ',category.c_name as cat_name ,machines.name as mach_name from parts,category,machines ';
  if iKeresesTipus = 0 then
    begin
  	sSQL := sSQL + 'where p_desc LIKE("%' + sKeresettAlkatresz + '%")';
    end
  else
  	begin
    sSQL := sSQL + 'where p_ordernum LIKE("%' + sKeresettAlkatresz + '%")';
    end;
  sSQL := sSQL + ' and cat_id=parts.c_id and machines.id=category.machine_id order by mach_name, parts.p_id;';
  sqlKeresesEredmenye.SQL := sSQL;

  sqlKeresesEredmenye.Open;
  if (sqlKeresesEredmenye.RecordCount = 0) then
    begin
    	ShowMessage('Nincs találat!');
      //adatbáziskapcsolatok lezárása :
  		sqlParts.Close;
			sqlKeresesEredmenye.Close;
  		SetLength(store_infos,0);
  		frmKeresesEredmenye.Hide;
  		frmMain.Show;
      exit;
    end;
  SetLength(category_datas,sqlKeresesEredmenye.RecordCount+1);

  i := 0;
  Repeat
    //lstCategory.Items.Add(dtsKeresesEredmenye.DataSet.FieldByName('c_name').AsString);
    sp_id := dtsKeresesEredmenye.DataSet.FieldByName('p_id').AsString;
    Val(sp_id,j);
    //ShowMessage(inttostr(j));
    category_datas[i].p_id := j;
		category_datas[i].c_id := dtsKeresesEredmenye.DataSet.FieldByName('cat_id').AsInteger;
    category_datas[i].c_name := dtsKeresesEredmenye.DataSet.FieldByName('cat_name').AsString;
    category_datas[i].machine_name := dtsKeresesEredmenye.DataSet.FieldByName('mach_name').AsString;
    category_datas[i].c_images := dtsKeresesEredmenye.DataSet.FieldByName('cat_images').AsInteger;
		dtsKeresesEredmenye.DataSet.Next;
    i := i + 1;
  Until dtsKeresesEredmenye.DataSet.Eof;

  dtsKeresesEredmenye.DataSet.First;
  dbgKeresesEredmenye.Refresh;

  //kategóriához tartozó képek betöltése :
  sMachine := category_datas[0].machine_name;
  sImgPath := 'alk_kat/' + sMachine + '/images/' + IntToStr(category_datas[0].c_id) + '/';
	//ShowMessage(sImgPath);
  //Képlapozó beállítása :
  GroupBox2.Caption := 'Kategória részletek : 1 / ' + IntToStr(category_datas[0].c_images);
	iAlkatIndex := 1;
  iAlkatMax := category_datas[0].c_images;
  if (category_datas[0].c_id = 304) then
     imgPart.Picture.LoadFromFile(sImgPath + IntToStr(category_datas[0].p_id) + '.jpg')
  else
     imgPart.Picture.LoadFromFile(sImgPath + '1.jpg');

  imgPart.Top := 0;
  imgPart.Left := 0;
  ScrollBox1.Update;

  iZoomFactor := 40;
  iZoomLevel := 0;
  LMButton := false;

  //Alkategória léptetésgombok beállítása :
  btnLast.Enabled := true;
  btnNext.Enabled := true;
	btnFirst.Enabled := false;
  btnPrev.Enabled := false;

  category_id:=0;

  frmKeresesEredmenye.Top := 0;
  frmKeresesEredmenye.Left := 0;

end;

procedure TfrmKeresesEredmenye.imgPartMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  	LMButton := true;
    tmp := true;
    imgPart.Cursor := crSizeAll;
end;

procedure TfrmKeresesEredmenye.imgPartMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if (LMButton) then
  begin
    if (tmp) then
    begin
      Mouse.X:=X;
      Mouse.Y:=Y;
    end;
    tmp:=False;

    imgPart.Left:=imgPart.Left+X-Mouse.X;
    imgPart.Top:=imgPart.Top+Y-Mouse.Y;
  end;
end;

procedure TfrmKeresesEredmenye.imgPartMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  	LMButton := false;
		imgPart.Cursor := crDefault;
end;

procedure TfrmKeresesEredmenye.imgPartMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  imgPart.Width := imgPart.Width - iZoomFactor;
	imgPart.Height := imgPart.Height - iZoomFactor;
  iZoomLevel := iZoomLevel - 1;
  ScrollBox1.Update;
end;

procedure TfrmKeresesEredmenye.imgPartMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  imgPart.Width := imgPart.Width + iZoomFactor;
	imgPart.Height := imgPart.Height + iZoomFactor;
  iZoomLevel := iZoomLevel + 1;
  ScrollBox1.Update;
end;

procedure TfrmKeresesEredmenye.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  //MyWorkbook.Free;

  //adatbáziskapcsolatok lezárása :
  sqlParts.Close;
	sqlKeresesEredmenye.Close;

  SetLength(category_datas,0);

  frmKeresesEredmenye.Hide;
  frmMain.Show;
end;

procedure TfrmKeresesEredmenye.btnFirstClick(Sender: TObject);
begin
  //Az első kategória...
  if iAlkatIndex = 1 then exit;
  iAlkatIndex := 1;
  btnFirst.Enabled := false;
  btnPrev.Enabled := false;
  btnLast.Enabled := true;
  btnNext.Enabled := true;
	imgPart.Picture.LoadFromFile(sImgPath + IntToStr(iAlkatIndex) + '.jpg');
  imgPart.Left:=0;
  imgPart.Top:=0;
  imgPart.Update;
  GroupBox2.Caption := 'Kategória részletek : ' + IntToStr(iAlkatIndex) + ' / ' + IntToStr(iAlkatMax);
end;

procedure TfrmKeresesEredmenye.btnLastClick(Sender: TObject);
begin
  //Az utolsó kategória...
  if iAlkatIndex = iAlkatMax then exit;
  iAlkatIndex := iAlkatMax;
  btnLast.Enabled := false;
  btnNext.Enabled := false;
	btnFirst.Enabled := true;
  btnPrev.Enabled := true;
	imgPart.Picture.LoadFromFile(sImgPath + IntToStr(iAlkatIndex) + '.jpg');
  imgPart.Left:=0;
  imgPart.Top:=0;
  imgPart.Update;
  GroupBox2.Caption := 'Kategória részletek : ' + IntToStr(iAlkatIndex) + ' / ' + IntToStr(iAlkatMax);
end;

procedure TfrmKeresesEredmenye.btnNextClick(Sender: TObject);
begin
  //Következő kategória...
  if iAlkatIndex = iAlkatMax then exit;
  iAlkatIndex := iAlkatIndex + 1;
  btnFirst.Enabled := true;
  btnPrev.Enabled := true;
  if iAlkatIndex = iAlkatMax then
  begin
		btnFirst.Enabled := true;
  	btnPrev.Enabled := true;
  	btnLast.Enabled := false;
  	btnNext.Enabled := false;
  end ;
	imgPart.Picture.LoadFromFile(sImgPath + IntToStr(iAlkatIndex) + '.jpg');
	imgPart.Left:=0;
  imgPart.Top:=0;
  imgPart.Update;
  GroupBox2.Caption := 'Kategória részletek : ' + IntToStr(iAlkatIndex) + ' / ' + IntToStr(iAlkatMax);
end;

procedure TfrmKeresesEredmenye.btnPrevClick(Sender: TObject);
begin
  //Előző kategória...
  if iAlkatIndex = 1 then exit;
  iAlkatIndex := iAlkatIndex - 1;
  btnLast.Enabled := true;
  btnNext.Enabled := true;
  if iAlkatIndex = 1 then
  begin
		btnFirst.Enabled := false;
  	btnPrev.Enabled := false;
  	btnLast.Enabled := true;
  	btnNext.Enabled := true;
  end ;
	imgPart.Picture.LoadFromFile(sImgPath + IntToStr(iAlkatIndex) + '.jpg');
  imgPart.Left:=0;
  imgPart.Top:=0;
  imgPart.Update;
  GroupBox2.Caption := 'Kategória részletek : ' + IntToStr(iAlkatIndex) + ' / ' + IntToStr(iAlkatMax);
end;

procedure TfrmKeresesEredmenye.dbgKeresesEredmenyeCellClick(Column: TColumn);
var
  keres,talal,talal2,sl,sn,su,sc,sMKB,scost,sMIN,sMAX,sRemark, sGep : string;
  i,iSorszam															: integer;
  ered                                  	: boolean;
begin
  keres := '';
  talal := '';
  ered := false;
  //Kiválasztott sorból csak a rendelési szám kell :
  keres := dbgKeresesEredmenye.DataSource.DataSet[dbgKeresesEredmenye.Columns[1].FieldName];
  keres := LeftStr(keres,8);

  if (bRaktarkeszletCopy = true) then
  begin
  for i := 1 to iRowNum do
  begin
       talal := store_infos[i].sPartNum;
       talal2 := store_infos[i].sRemark;

       if (Pos(LowerCase(keres),LowerCase(talal)) > 0) OR (Pos(LowerCase(keres),LowerCase(talal2)) > 0) then
       begin
            sl := store_infos[i].sLocation;
            if Length(sl) <> 0 then
        	    edtLokacio.Text := sl
            else
		        edtLokacio.Text := '0';

            sn := store_infos[i].sNew;
            if Length(sn) <> 0 then
        	    edtNew.Text := sn
            else
        	    edtNew.Text := '0';

            su := store_infos[i].sUsed;
            if Length(su) <> 0 then
        	    edtUsed.Text := su
            else
                edtUsed.Text := '0';

            sc := store_infos[i].sConsig;
            if Length(sc) <> 0 then
        	    edtConsig.Text := sc
            else
        	    edtConsig.Text := '0';

            sMKB := store_infos[i].sMKB;
            if Length(sMKB) <> 0 then
        	    edtMKB.Text := sMKB
            else
        	    edtMKB.Text := '0';

				    scost := store_infos[i].sCost;
            if Length(scost) <> 0 then
            begin
        	    edtCost.Text := scost;
         	    stcCurrency.Caption := store_infos[i].sCurrency;
            end
            else
        	    edtCost.Text := '0';

            sMIN := store_infos[i].sMin;
				    if Length(sMIN) <> 0 then
        	    edtMIN.Text := sMIN
            else
        	    edtMIN.Text := '0';

            sMAX := store_infos[i].sMax;
				    if Length(sMAX) <> 0 then
        	    edtMAX.Text := sMAX
            else
        	    edtMAX.Text := '0';

            ered := true;

       end;
  end ;
  end;

  if ered = false then
  begin
		edtConsig.Text := '-';
    edtUsed.Text := '-';
    edtNew.Text := '-';
    edtLokacio.Text := '-';
    edtCost.Text := '-';
    edtMIN.Text := '-';
    edtMAX.Text := '-';
    edtMKB.Text := '-';
  end ;

  i := dbgKeresesEredmenye.DataSource.DataSet.RecNo - 1;

  //kategóriához tartozó képek betöltése ha szükséges :
  if (category_id <> category_datas[i].c_id) then
  begin
  	//ShowMessage('i: ' + IntToStr(i));
    sMachine := category_datas[i].machine_name;
  	sImgPath := 'alk_kat/' + sMachine + '/images/' + IntToStr(category_datas[i].c_id) + '/';
  	//Képlapozó beállítása :
	  GroupBox2.Caption := 'Kategória részletek : 1 / ' + IntToStr(category_datas[i].c_images);
		iAlkatIndex := 1;
	  iAlkatMax := category_datas[i].c_images;
	  category_id := category_datas[i].c_id;
	  imgPart.Picture.LoadFromFile(sImgPath + '1.jpg');

    imgPart.Top := 0;
  	imgPart.Left := 0;
    imgPart.Update;
  	ScrollBox1.Update;
  	iZoomFactor := 40;
  	iZoomLevel := 0;
  	LMButton := false;

  	//Alkategória léptetésgombok beállítása :
  	btnLast.Enabled := true;
  	btnNext.Enabled := true;
		btnFirst.Enabled := false;
  	btnPrev.Enabled := false;
  end;

  //Ha pipettát választ ki akkor egyből a kiválasztott típust kell beállítani:
  sGep := dbgKeresesEredmenye.DataSource.DataSet[dbgKeresesEredmenye.Columns[4].FieldName];
  if (trim(sGep) = 'PIPETTAK') then
  begin
    //pipettáknál meg lehet jeleníteni a képeket is.
    iSorszam := dbgKeresesEredmenye.DataSource.DataSet[dbgKeresesEredmenye.Columns[0].FieldName];
    //ShowMessage('alk_kat/pipettak/images/304/' + IntToStr(iSorszam) + '.jpg');
    imgPart.Picture.LoadFromFile('alk_kat/pipettak/images/304/' + IntToStr(iSorszam) + '.jpg');
    imgPart.Top := 0;
    imgPart.Left := 0;
    ScrollBox1.Update;
  end;

end;

initialization
  {$I kereses_eredmenye.lrs}

end.

