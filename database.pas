unit database;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqlite3conn, sqlite3ds, db, global;


function dbConnect(sTablaName: string; sSQL: string; sPrimaryKey: string):TSqlite3Dataset;
procedure dbClose(dbSQL3Dataset: TSqlite3Dataset);
procedure dbUpdate(dbSQL3Dataset: TSqlite3Dataset; sSQL: string);



var

   //dbSQL3Dataset:        TSqlite3Dataset;
   dbDatasource:         TDataSource;

implementation

function dbConnect(sTablaName: string; sSQL: string; sPrimaryKey: string) :TSqlite3Dataset;
var
   dbSQL3Dataset: TSqlite3Dataset;
begin
     dbSQL3Dataset := TSqlite3Dataset.Create(nil);
     with dbSQL3Dataset do
     begin
          FileName:=dbPath;
          AutoIncrementKey:=true;
          PrimaryKey:=sPrimaryKey;
          SaveOnClose:=true;
          SaveOnRefetch:=true;
          TableName:=sTablaName;
          SQL:=sSQL;
          //Active:=true;
          Open;
          First;
     end; //end of with
     dbConnect := dbSQL3Dataset;
end; //end of dbConnect function

procedure dbClose(dbSQL3Dataset: TSqlite3Dataset);
begin
     dbSQL3Dataset.Close;
     dbSQL3Dataset.Free;
end;

//procedure dbEdit(dbSQL3Dataset: TSqlite3Dataset; sFieldName: string);

procedure dbUpdate(dbSQL3Dataset: TSqlite3Dataset; sSQL: string);
begin
     dbSQL3Dataset.Close;
     dbSQL3Dataset.SQL:=sSQL;
     dbSQL3Dataset.Open;
     dbSQL3Dataset.First;
end;

end.

