unit Machines;

{$mode objfpc}{$H+}

interface

uses
	Classes , SysUtils , sqlite3ds , db , FileUtil , LResources , Forms ,
  Controls , Graphics , Dialogs , StdCtrls , ExtCtrls , Buttons ,
  DbCtrls , database , global , DBGrids , fpspreadsheet , laz_fpspreadsheet ,fpsTypes, types , Clipbrd;

type

  { TfrmGepalkatreszek }

  TfrmGepalkatreszek = class(TForm)
    btnFirst: TBitBtn ;
    btnPrev: TBitBtn ;
    btnNext: TBitBtn ;
    btnLast: TBitBtn ;
    dtsParts: TDatasource ;
    dtsCategories: TDatasource ;
    dbgPartsList: TDBGrid;
    edtCost: TEdit ;
    edtLokacio: TEdit ;
    edtMKB: TEdit;
    edtNew: TEdit ;
    edtUsed: TEdit ;
    edtConsig: TEdit ;
    edtMIN: TEdit ;
    edtMAX: TEdit ;
    gpbMachine: TGroupBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox ;
    GroupBox3: TGroupBox ;
    imgPart: TImage;
    lstCategory: TListBox ;
    scrPartsList : TScrollBar;
    ScrollBox1: TScrollBox;
    sqlParts: TSqlite3Dataset ;
    sqlCategories: TSqlite3Dataset ;
    StaticText1: TStaticText ;
    StaticText10: TStaticText ;
    StaticText11: TStaticText ;
    StaticText12: TStaticText ;
    StaticText13: TStaticText;
    StaticText14: TStaticText;
    StaticText2: TStaticText ;
    StaticText3: TStaticText ;
    StaticText4: TStaticText ;
    StaticText5: TStaticText ;
    StaticText6: TStaticText ;
    StaticText7: TStaticText ;
    StaticText8: TStaticText ;
    StaticText9: TStaticText ;
    stcCurrency: TStaticText ;
    procedure btnFirstClick(Sender: TObject) ;
    procedure btnLastClick(Sender: TObject) ;
    procedure btnNextClick(Sender: TObject) ;
    procedure btnPrevClick(Sender: TObject) ;
    procedure dbgPartsListCellClick(Column: TColumn) ;
    procedure dbgPartsListContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject) ;
    procedure imgPartMouseDown(Sender: TObject ; Button: TMouseButton ;
        Shift: TShiftState ; X , Y: Integer) ;
    procedure imgPartMouseMove(Sender: TObject ; Shift: TShiftState ; X ,
        Y: Integer) ;
    procedure imgPartMouseUp(Sender: TObject ; Button: TMouseButton ;
        Shift: TShiftState ; X , Y: Integer) ;
    procedure imgPartMouseWheelDown(Sender: TObject ; Shift: TShiftState ;
        MousePos: TPoint ; var Handled: Boolean) ;
    procedure imgPartMouseWheelUp(Sender: TObject ; Shift: TShiftState ;
        MousePos: TPoint ; var Handled: Boolean) ;
    procedure lstCategoryClick(Sender: TObject) ;
    procedure scrPartsListScroll(Sender : TObject; ScrollCode : TScrollCode;
      var ScrollPos : Integer);
    procedure sqlPartsAfterScroll(DataSet : TDataSet);

  private
    { private declarations }
    myDataset						: TSqlite3Dataset;
    sImgPath						:	string;		//kateg??ri??hoz tartoz?? k??pek ??tvonala
    sMachine						:	string;		//G??pt??pus
    iAlkatMax						: integer;	//Alkateg??ri??k sz??ma
    iAlkatIndex					: integer;	//Aktu??lisan megjelen??tett alkateg??ria
    LMButton						: Boolean;	//=True akkor a bal eg??rgomb lenyomva...
    tmp									: Boolean;	//K??pmozgat??shoz....
    Mouse								: TPoint;		//K??pmozgat??shoz....

		//Raktarkeszlet...
    MyWorkbook		: TsWorkbook;
  	MyWorksheet		: TsWorksheet;
    iRowNum				: integer;		//excel sorok sz??ma...

    //kijel??lt adat ment??se(jobb klikkre ez az adat ker??l a v??g??lapra):
    sPartData     : String;

    //procedure SetOriginalZoom(); //k??pm??ret vissza??ll??t??sa az eredetire !

  public
    { public declarations }
    //1=F4;2=F5;3=F5HM;4=S_FEEDERS;5=X_FEEDERS;6=HS50;7=HS60;8=S23HM;9=S27HM;10=SPLICING;11=WPW_80F_3;12=X4
    iMachineType : Integer;
    sMachineType : string;

    iZoomFactor,iZoomLevel : Integer;

  end;

  //Kateg??ria adatok :
  type datas = record
        c_id		: integer;		//Kateg??ria azonos??t??...
        //c_name 	: string;			//Kateg??ria neve pl.: 12_segm_10000_head
        c_images: integer;		//Kateg??ri??hoz tartoz?? k??pek sz??ma... 1-
  end;

  //Rakt??rk??szlet :
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
  end;


var
  frmGepalkatreszek		: TfrmGepalkatreszek;
  category_datas 			: array of datas;
  store_infos 				: array of store_datas;

implementation
	uses alk_kat_start;

{ TfrmGepalkatreszek }

procedure TfrmGepalkatreszek.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
	// Finalization
 	//MyWorkbook.Free;

  //adatb??ziskapcsolatok lez??r??sa :
  sqlParts.Close;
	sqlCategories.Close;

  SetLength(category_datas,0);

  //??tmeneti rakt??k??szlet f??jl t??rl??se :
  //DeleteFile(InputFileName);

  frmGepalkatreszek.Hide;
  frmMain.Show;
end;

procedure TfrmGepalkatreszek.btnFirstClick(Sender: TObject) ;
begin
	//Az els?? kateg??ria...
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
  GroupBox2.Caption := 'Kateg??ria r??szletek : ' + IntToStr(iAlkatIndex) + ' / ' + IntToStr(iAlkatMax);

  edtConsig.Text := '-';
  edtMKB.Text := '-';
  edtUsed.Text := '-';
  edtNew.Text := '-';
  edtLokacio.Text := '-';
  edtCost.Text := '-';
  edtMIN.Text := '-';
  edtMAX.Text := '-';

end;

procedure TfrmGepalkatreszek.btnLastClick(Sender: TObject) ;
begin
	//Az utols?? kateg??ria...
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
  GroupBox2.Caption := 'Kateg??ria r??szletek : ' + IntToStr(iAlkatIndex) + ' / ' + IntToStr(iAlkatMax);

  edtConsig.Text := '-';
  edtMKB.Text := '-';
  edtUsed.Text := '-';
  edtNew.Text := '-';
  edtLokacio.Text := '-';
  edtCost.Text := '-';
  edtMIN.Text := '-';
  edtMAX.Text := '-';

end;

procedure TfrmGepalkatreszek.btnNextClick(Sender: TObject) ;
begin
	//K??vetkez?? kateg??ria...
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
  GroupBox2.Caption := 'Kateg??ria r??szletek : ' + IntToStr(iAlkatIndex) + ' / ' + IntToStr(iAlkatMax);

  edtConsig.Text := '-';
  edtMKB.Text := '-';
  edtUsed.Text := '-';
  edtNew.Text := '-';
  edtLokacio.Text := '-';
  edtCost.Text := '-';
  edtMIN.Text := '-';
  edtMAX.Text := '-';

end;

procedure TfrmGepalkatreszek.btnPrevClick(Sender: TObject) ;
begin
	//El??z?? kateg??ria...
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
  GroupBox2.Caption := 'Kateg??ria r??szletek : ' + IntToStr(iAlkatIndex) + ' / ' + IntToStr(iAlkatMax);

  edtConsig.Text := '-';
  edtMKB.Text := '-';
  edtUsed.Text := '-';
  edtNew.Text := '-';
  edtLokacio.Text := '-';
  edtCost.Text := '-';
  edtMIN.Text := '-';
  edtMAX.Text := '-';

end;

procedure TfrmGepalkatreszek.dbgPartsListCellClick(Column: TColumn) ;
var
  keres,talal,sl,sn,su,sc,sMKB,scost,sMIN,sMAX : string;
  i,iSorszam 															: integer;
  ered                          	        : boolean;

begin
  keres := '';
  talal := '';
  ered := false;
  //Kiv??lasztott sorb??l csak a rendel??si sz??m kell :
  keres := dbgPartsList.DataSource.DataSet[dbgPartsList.Columns[1].FieldName];
  keres := LeftStr(keres,8);

  if (iMachineType = 17) then
  begin
    //pipett??kn??l meg lehet jelen??teni a k??peket is.
    iSorszam := dbgPartsList.DataSource.DataSet[dbgPartsList.Columns[0].FieldName];
    imgPart.Picture.LoadFromFile('alk_kat/pipettak/images/304/' + IntToStr(iSorszam) + '.jpg');
    imgPart.Top := 0;
    imgPart.Left := 0;
    ScrollBox1.Update;
  end;

  //ShowMessage(dbgPartsList.SelectedField.Value);
  sPartData := dbgPartsList.SelectedField.Value;

  if (bRaktarkeszletCopy = true) then
  begin
  for i := 1 to iRowNum do
  begin
       talal := store_infos[i].sPartNum; //  Utf8ToAnsi(MyWorksheet.ReadAsUTF8Text(i,2));
       //ShowMessage(talal);

       if Pos(LowerCase(keres),LowerCase(talal)) > 0 then
       begin
        sl := store_infos[i].sLocation;	// Utf8ToAnsi(MyWorksheet.ReadAsUTF8Text(i,0));
        if Length(sl) <> 0 then
        	edtLokacio.Text := sl
        else
		    edtLokacio.Text := '0';

        sn := store_infos[i].sNew;	// Utf8ToAnsi(MyWorksheet.ReadAsUTF8Text(i,6));
        if Length(sn) <> 0 then
        	edtNew.Text := sn
        else
        	edtNew.Text := '0';

        su := store_infos[i].sUsed;	// Utf8ToAnsi(MyWorksheet.ReadAsUTF8Text(i,4));
        if Length(su) <> 0 then
        	edtUsed.Text := su
        else
            edtUsed.Text := '0';

        sc := store_infos[i].sConsig;	// Utf8ToAnsi(MyWorksheet.ReadAsUTF8Text(i,5));
        if Length(sc) <> 0 then
        	edtConsig.Text := sc
        else
        	edtConsig.Text := '0';

        sMKB := store_infos[i].sMKB;	// Utf8ToAnsi(MyWorksheet.ReadAsUTF8Text(i,5));
        if Length(sMKB) <> 0 then
        	edtMKB.Text := sMKB
        else
        	edtMKB.Text := '0';

				scost := store_infos[i].sCost;	// Utf8ToAnsi(MyWorksheet.ReadAsUTF8Text(i,8));
        if Length(scost) <> 0 then
        begin
        	edtCost.Text := scost;
         	stcCurrency.Caption := store_infos[i].sCurrency;	// UpperCase(Utf8ToAnsi(MyWorksheet.ReadAsUTF8Text(i,9)));
        end
        else
        	edtCost.Text := '0';

        sMIN := store_infos[i].sMin;	// Utf8ToAnsi(MyWorksheet.ReadAsUTF8Text(i,13));
				if Length(sMIN) <> 0 then
        	edtMIN.Text := sMIN
        else
        	edtMIN.Text := '0';

        sMAX := store_infos[i].sMax;	// Utf8ToAnsi(MyWorksheet.ReadAsUTF8Text(i,14));
				if Length(sMAX) <> 0 then
        	edtMAX.Text := sMAX
        else
        	edtMAX.Text := '0';

        ered := true;
        //exit;
       end;
  end ;
  end;

  if ered = false then
  begin
		edtConsig.Text := '-';
    edtMKB.Text := '-';
    edtUsed.Text := '-';
    edtNew.Text := '-';
    edtLokacio.Text := '-';
    edtCost.Text := '-';
    edtMIN.Text := '-';
    edtMAX.Text := '-';
    exit;
  end ;

	//ShowMessage(dbgPartsList.SelectedField.Value);
end;

procedure TfrmGepalkatreszek.dbgPartsListContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);

begin
  Clipboard.AsText := sPartData;
  ShowMessage('A k??vetkez?? adat ker??lt v??g??lapra :' + #10 + #10 + sPartData);
end;

procedure TfrmGepalkatreszek.FormShow(Sender: TObject) ;
var
  i					: integer;

begin
  if (bRaktarkeszletCopy = true) then
  begin
  // Create the spreadsheet
  MyWorkbook := TsWorkbook.Create;
  MyWorkbook.ReadFromFile(InputFileName, sfExcel8);
  //MyWorkbook.WriteToFile(ExtractFilePath(ParamStr(0))+'test.ods', sfOpenDocument, true);
  MyWorksheet := MyWorkbook.GetFirstWorksheet;

  //Rakt??rk??szlet beolvas??sa - excel-b??l, t??mbbe :
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
  end ;
  MyWorkbook.Free;
  end;

  //ShowMessage(inttostr(MyWorksheet.GetLastRowNumber));

  edtConsig.Text := '-';
  edtMKB.Text := '-';
  edtUsed.Text := '-';
  edtNew.Text := '-';
  edtLokacio.Text := '-';
  edtCost.Text := '-';
  edtMIN.Text := '-';
  edtMAX.Text := '-';

	gpbMachine.Caption := sMachineType + ' - alkatr??sz kateg??ri??k...';
  //Az els?? kateg??ria felt??lt??se, be??ll??t??sa :
  lstCategory.Items.Clear;
  sqlCategories.FileName:=dbPath;
  sqlCategories.SQL := 'select * from category where machine_id = ' + IntToStr(iMachineType)
  											+ ' order by c_name;';
  sqlCategories.Open;
  SetLength(category_datas,sqlCategories.RecordCount+1);
  i := 0;
  Repeat
    lstCategory.Items.Add(dtsCategories.DataSet.FieldByName('c_name').AsString);
		category_datas[i].c_id := dtsCategories.DataSet.FieldByName('id').AsInteger;
    //category_datas[i].c_name := dtsCategories.DataSet.FieldByName('c_name').AsString;
    category_datas[i].c_images := dtsCategories.DataSet.FieldByName('c_images').AsInteger;
		dtsCategories.DataSet.Next;
    i := i + 1;
  Until dtsCategories.DataSet.Eof;
	lstCategory.Refresh;
  lstCategory.Selected[0] := true;
  //dbgrid be??ll??t??sa :
  sqlParts.FileName:=dbPath;
	sqlParts.SQL := 'select * from parts where c_id = ' + IntToStr(category_datas[0].c_id)
  							+ ' order by parts.id;';
  sqlParts.Open;
  scrPartsList.Min := 1;
  scrPartsList.Max := sqlParts.RecordCount;
  //kateg??ri??hoz tartoz?? k??pek bet??lt??se :
  myDataset := dbConnect('machines','SELECT * FROM machines WHERE id = ' + IntToStr(iMachineType) + ';','id');
	sMachine := myDataset.FieldByName('name').AsString;
  sImgPath := 'alk_kat/' + sMachine + '/images/' + IntToStr(category_datas[0].c_id) + '/';
	//ShowMessage(sImgPath);
  //K??plapoz?? be??ll??t??sa :
  GroupBox2.Caption := 'Kateg??ria r??szletek : 1 / ' + IntToStr(category_datas[0].c_images);
	iAlkatIndex := 1;
  iAlkatMax := category_datas[0].c_images;
  imgPart.Picture.LoadFromFile(sImgPath + '1.jpg');
  imgPart.Top := 0;
  imgPart.Left := 0;
  ScrollBox1.Update;

  iZoomFactor := 40;
  iZoomLevel := 0;
  LMButton := false;

  //Alkateg??ria l??ptet??sgombok be??ll??t??sa :
  btnLast.Enabled := true;
  btnNext.Enabled := true;
	btnFirst.Enabled := false;
  btnPrev.Enabled := false;

  if (iMachineType = 17) then
  begin
       //pipetta keres??skor nem 'Megnevez??s' hanem 'Pipetta t??pusa' a fejl??c
       dbgPartsList.Columns.Items[2].Title.Caption := 'Pipetta t??pusa';
  end
  else
      dbgPartsList.Columns.Items[2].Title.Caption := 'Megnevez??s';

  frmGepalkatreszek.Top := 0;
  frmGepalkatreszek.Left := 0;

end;

procedure TfrmGepalkatreszek.imgPartMouseDown(Sender: TObject ;
    Button: TMouseButton ; Shift: TShiftState ; X , Y: Integer) ;
begin
    LMButton := true;
    tmp := true;
    imgPart.Cursor := crSizeAll;
end;

procedure TfrmGepalkatreszek.imgPartMouseMove(Sender: TObject ;
    Shift: TShiftState ; X , Y: Integer) ;
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

procedure TfrmGepalkatreszek.imgPartMouseUp(Sender: TObject ;
    Button: TMouseButton ; Shift: TShiftState ; X , Y: Integer) ;
begin
    LMButton := false;
		imgPart.Cursor := crDefault;
end;

procedure TfrmGepalkatreszek.imgPartMouseWheelDown(Sender: TObject ;
    Shift: TShiftState ; MousePos: TPoint ; var Handled: Boolean) ;
begin
	imgPart.Width := imgPart.Width - iZoomFactor;
	imgPart.Height := imgPart.Height - iZoomFactor;
  iZoomLevel := iZoomLevel - 1;
  ScrollBox1.Update;
end;

procedure TfrmGepalkatreszek.imgPartMouseWheelUp(Sender: TObject ;
    Shift: TShiftState ; MousePos: TPoint ; var Handled: Boolean) ;
begin
	imgPart.Width := imgPart.Width + iZoomFactor;
	imgPart.Height := imgPart.Height + iZoomFactor;
  iZoomLevel := iZoomLevel + 1;
  ScrollBox1.Update;
end;

procedure TfrmGepalkatreszek.lstCategoryClick(Sender: TObject) ;
begin
  //Kiv??lasztott kateg??ri??hoz tartoz?? k??p megjelen??t??se :
  sImgPath := 'alk_kat/' + sMachine + '/images/' + IntToStr(category_datas[lstCategory.ItemIndex].c_id) + '/';
  imgPart.Picture.LoadFromFile(sImgPath + '1.jpg');
  //if iZoomLevel <> 0 then SetOriginalZoom();
  imgPart.Left:=0;
  imgPart.Top:=0;
  imgPart.Update;
  ScrollBox1.Update;

  //Kateg??ri??hoz tartoz?? alkatr??szek :
  dbUpdate(sqlParts,'select * from parts where c_id = '
				+ IntToStr(category_datas[lstCategory.ItemIndex].c_id) + ' order by id;');
  dbgPartsList.Update;
  scrPartsList.Min := 1;
  scrPartsList.Max := sqlParts.RecordCount;

  //Lapoz?? be??ll??t??sa :
  iAlkatIndex := 1;
  iAlkatMax := category_datas[lstCategory.ItemIndex].c_images;
  GroupBox2.Caption := 'Kateg??ria r??szletek : 1 / ' + IntToStr(iAlkatMax);

  btnLast.Enabled := true;
  btnNext.Enabled := true;
	btnFirst.Enabled := false;
  btnPrev.Enabled := false;

  edtConsig.Text := '-';
  edtMKB.Text := '-';
  edtUsed.Text := '-';
  edtNew.Text := '-';
  edtLokacio.Text := '-';
  edtCost.Text := '-';
  edtMIN.Text := '-';
  edtMAX.Text := '-';

end;

procedure TfrmGepalkatreszek.scrPartsListScroll(Sender : TObject;
  ScrollCode : TScrollCode; var ScrollPos : Integer);
begin
  sqlParts.RecNo := ScrollPos;
end;

procedure TfrmGepalkatreszek.sqlPartsAfterScroll(DataSet : TDataSet);
begin
  scrPartsList.Position:= DataSet.RecNo;
end;



initialization
  {$I machines.lrs}

end.

