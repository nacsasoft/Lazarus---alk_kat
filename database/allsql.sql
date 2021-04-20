select * from parts where p_desc LIKE('%TOOTHED WHEEL%');
select * from parts where id = 3146;
select * from parts where c_id = 7 order by p_id;
select * from parts where p_ordernum LIKE('%352957%');
update parts set p_desc = 'GEAR WHEEL 2' where id = 5239;

update parts set p_ordernum='193687', p_desc='Festo Cable Valve (ASM:03048851-01)' 
where p_ordernum LIKE('%3048851%');

update category set c_name='6_szegmenses_8000_fej' where id=20;
select * from category where c_name LIKE('%conn%');

update parts set p_ordernum='00352957S04' where id=3422;

--Alkatreszkereses rendelesi szam alapjan :
select parts.p_id ,parts.p_ordernum ,parts.p_desc ,category.id ,category.c_name,category.c_images ,machines.name 
from parts,category,machines 
where p_ordernum LIKE("%341780%") and category.id=parts.c_id and machines.id=category.machine_id order by machines.name;

--Alkatreszkereses megnevezes alapjan :
select parts.p_id as 'Képazonosító',parts.p_ordernum as 'Rendelési szám',parts.p_desc as 'Alkatrész megnevezés',category.c_name as 'Kategória',machines.name as 'Gép név' 
from parts,category,machines 
where p_desc LIKE('%turn%') and category.id=parts.c_id and machines.id=category.machine_id order by machines.name,parts.p_id ASC;