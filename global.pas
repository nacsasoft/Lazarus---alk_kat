unit global;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
	  dbPath = 'database/alkkat.db';
    //sReportsPath = 'reports/';

    Codes64 = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+/';
    secstring = 'SPH9Q8WAeONhdm5z';

var
  	MyDir,InputFileName,InputFileName2 : string;
    iKeresesTipus                      : integer; //0 = Megnevezés; 1 = Rendelési szám
    sKeresettAlkatresz                 : string;
    bRaktarkeszletCopy								 : boolean;	//Ha sikerült másolatot készíteni a raktárkészletről akkor = TRUE

//Globális függvények :
function IsStrANumber(const S: string): Boolean;

function MakeRNDString(Chars: string; Count: Integer): string;
function EncodePWDEx(Data: string; MinV: Integer = 0; MaxV: Integer = 5): string;
function DecodePWDEx(Data: string): string;


implementation


//a string szám ?
function IsStrANumber(const S: string): Boolean;
var
  P: PChar;
begin
  P      := PChar(S);
  Result := False;
  while P^ <> #0 do
  begin
    if not (P^ in ['0'..'9']) then Exit;
    Inc(P);
  end;
  Result := True;
end;

function MakeRNDString(Chars: string; Count: Integer): string;
var
  i, x: integer;
begin
  Result := '';
  for i := 0 to Count - 1 do
  begin
    x := Length(chars) - Random(Length(chars));
    Result := Result + chars[x];
    chars := Copy(chars, 1,x - 1) + Copy(chars, x + 1,Length(chars));
  end;
end;

function EncodePWDEx(Data: string; MinV: Integer = 0;
  MaxV: Integer = 5): string;
var
  i, x: integer;
  s1, s2, ss: string;
begin
  if minV > MaxV then
  begin
    i := minv;
    minv := maxv;
    maxv := i;
  end;
  if MinV < 0 then MinV := 0;
  if MaxV > 100 then MaxV := 100;
  Result := '';
  if Length(secstring) < 16 then Exit;
  for i := 1 to Length(secstring) do
  begin
    s1 := Copy(secstring, i + 1,Length(secstring));
    if Pos(secstring[i], s1) > 0 then Exit;
    if Pos(secstring[i], Codes64) <= 0 then Exit;
  end;
  s1 := Codes64;
  s2 := '';
  for i := 1 to Length(secstring) do
  begin
    x := Pos(secstring[i], s1);
    if x > 0 then s1 := Copy(s1, 1,x - 1) + Copy(s1, x + 1,Length(s1));
  end;
  ss := secstring;
  for i := 1 to Length(Data) do
  begin
    s2 := s2 + ss[Ord(Data[i]) mod 16 + 1];
    ss := Copy(ss, Length(ss), 1) + Copy(ss, 1,Length(ss) - 1);
    s2 := s2 + ss[Ord(Data[i]) div 16 + 1];
    ss := Copy(ss, Length(ss), 1) + Copy(ss, 1,Length(ss) - 1);
  end;
  Result := MakeRNDString(s1, Random(MaxV - MinV) + minV + 1);
  for i := 1 to Length(s2) do Result := Result + s2[i] + MakeRNDString(s1,
      Random(MaxV - MinV) + minV);
end;

function DecodePWDEx(Data: string): string;
var
  i, x, x2: integer;
  s1, s2, ss: string;
begin
  Result := #1;
  if Length(secstring) < 16 then Exit;
  for i := 1 to Length(secstring) do
  begin
    s1 := Copy(secstring, i + 1,Length(secstring));
    if Pos(secstring[i], s1) > 0 then Exit;
    if Pos(secstring[i], Codes64) <= 0 then Exit;
  end;
  s1 := Codes64;
  s2 := '';
  ss := secstring;
  for i := 1 to Length(Data) do if Pos(Data[i], ss) > 0 then s2 := s2 + Data[i];
  Data := s2;
  s2   := '';
  if Length(Data) mod 2 <> 0 then Exit;
  for i := 0 to Length(Data) div 2 - 1 do
  begin
    x := Pos(Data[i * 2 + 1], ss) - 1;
    if x < 0 then Exit;
    ss := Copy(ss, Length(ss), 1) + Copy(ss, 1,Length(ss) - 1);
    x2 := Pos(Data[i * 2 + 2], ss) - 1;
    if x2 < 0 then Exit;
    x  := x + x2 * 16;
    s2 := s2 + chr(x);
    ss := Copy(ss, Length(ss), 1) + Copy(ss, 1,Length(ss) - 1);
  end;
  Result := s2;
end;



end.

