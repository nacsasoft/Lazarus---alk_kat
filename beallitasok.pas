unit beallitasok;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, DBGrids, global, database, Sqlite3DS, db;

type

  { TfrmBeallitasok }

  TfrmBeallitasok = class(TForm)
    btnUjAlkatreszFelvitele: TButton;
    cmbGep: TComboBox;
    cmbKategoria: TComboBox;
    edtRendelesiSzam: TEdit;
    edtMegnevezes: TEdit;
    edtKepAzonosito: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure btnUjAlkatreszFelviteleClick(Sender: TObject);
    procedure cmbGepChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
    myDataset:    TSqlite3Dataset;
    sSQL :        string;

  public
    { public declarations }
  end;

var
  frmBeallitasok: TfrmBeallitasok;

implementation
  uses alk_kat_start;

  { TfrmBeallitasok }

  procedure TfrmBeallitasok.FormClose(Sender: TObject; var CloseAction: TCloseAction);
  begin
    frmBeallitasok.Hide;
    frmMain.Show;
  end;

procedure TfrmBeallitasok.cmbGepChange(Sender: TObject);
var
  iMachineID : integer;
begin
  //géptípus csere esetén frissíteni kell a géphez tartozó kategóriákat is!!
  cmbKategoria.Clear;
  iMachineID := integer(cmbGep.Items.Objects[cmbGep.ItemIndex]);
  sSQL := 'SELECT * FROM category WHERE machine_id = ' + IntToStr(iMachineID) + ' ORDER BY c_name;';
  myDataset := dbConnect('category',sSQL,'id');
  Repeat
    cmbKategoria.Items.AddObject(myDataset.FieldByName('c_name').AsString,
      TObject(myDataset.FieldByName('id').AsInteger));
    myDataset.Next;
  Until myDataset.Eof;
  myDataset.First;
  cmbKategoria.Text := myDataset.FieldByName('c_name').AsString;
  dbClose(myDataset);
end;

procedure TfrmBeallitasok.btnUjAlkatreszFelviteleClick(Sender: TObject);
var
  c_id : integer;

begin
  //Új alkatrész felvitele....
  if ((trim(edtMegnevezes.Text) = '') or (trim(edtRendelesiSzam.Text) = '') or (trim(edtKepAzonosito.Text) = '')) then
    begin
      ShowMessage('Minden mező kitöltése kötelező !');
      exit;
    end;

  c_id := integer(cmbKategoria.Items.Objects[cmbKategoria.ItemIndex]);

  myDataset := dbConnect('parts','SELECT * FROM parts ORDER BY id;','id');
	myDataset.Append;
	myDataset.FieldByName('c_id').AsInteger := c_id;
  myDataset.FieldByName('p_id').AsString := edtKepAzonosito.Text;
  myDataset.FieldByName('p_ordernum').AsString := edtRendelesiSzam.Text;
  myDataset.FieldByName('p_desc').AsString := edtMegnevezes.Text;
  myDataset.Post;
  myDataset.ApplyUpdates;
  dbClose(myDataset);

  edtKepAzonosito.Text := '';
  edtMegnevezes.Text := '';
  edtRendelesiSzam.Text := '';

end;

procedure TfrmBeallitasok.FormShow(Sender: TObject);
begin
  //Gépek listázása:
  cmbGep.Clear;
  sSQL := 'SELECT * FROM machines ORDER BY name;';
  myDataset := dbConnect('machines',sSQL,'id');
  Repeat
    cmbGep.Items.AddObject(myDataset.FieldByName('name').AsString,
      TObject(myDataset.FieldByName('id').AsInteger));
    myDataset.Next;
  Until myDataset.Eof;
  myDataset.First;
  cmbGep.Text := myDataset.FieldByName('name').AsString;
  dbClose(myDataset);

  //Kategória lista törlése, majd a géptípus beálításakor lesz frissíve!!
  cmbKategoria.Clear;
  cmbGepChange(Sender); //kategória beállítása az első géphez...

  edtKepAzonosito.Text := '';
  edtRendelesiSzam.Text := '';
  edtMegnevezes.Text := '';



end;

initialization
  {$I beallitasok.lrs}

end.

