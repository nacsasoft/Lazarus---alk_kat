program alk_kat;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, alk_kat_start, LResources, sqlite3laz, laz_fpspreadsheet, Machines,
  kereses_eredmenye ;

{$IFDEF WINDOWS}{$R alk_kat.rc}{$ENDIF}

begin
  Application.Title := 'Siplace-OPC';
  {$I alk_kat.lrs}
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmGepalkatreszek, frmGepalkatreszek);
  Application.CreateForm(TfrmKeresesEredmenye, frmKeresesEredmenye);
  Application.Run;
end.

