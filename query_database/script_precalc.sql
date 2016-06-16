	--1--aggregate asset in RW level
	--source table asset

	drop table asset_rw_unit;
	create table asset_rw_unit as 
	select id_rw, sector, subsector, asset, rw, kelurahan, kecamatan, kota, kelas, count(id_asset) as total_asset, sum(area_m2) as total_area_m2
	from asset 
	GROUP BY sector, subsector, asset, kota, kecamatan, kelurahan, rw, id_rw, kelas
	order by sector, subsector, asset, kota, kecamatan, kelurahan, rw, kelas;

	--buat table gabungan asset_rw_kelas (asset_rw_agg, asset_rw_unit, dan asset_rw_jalan)--
	drop table asset_rw_kelas;
	create table asset_rw_kelas(
	id_rw bigint,
	sector varchar(100),
	subsector varchar(50),
	asset varchar(50),
	rw varchar(50),
	kelurahan varchar(50),
	kecamatan varchar(100),
	kota varchar(100),
	total_asset1 bigint,
	total_asset2 bigint,
	total_asset3 bigint,
	total_asset bigint,
	total_area1 double precision,
	total_area2 double precision,
	total_area3 double precision,
	total_area double precision
	); 
	--insert 1
	--kelas A1
	insert into asset_rw_kelas
	select id_rw, sector, subsector, asset, rw, kelurahan, 
	kecamatan, kota, total_asset, '0', '0', '0', total_area_m2, '0', '0', '0' from asset_rw_unit
	where kelas in ('A1') ;
	--kelas A2
	insert into asset_rw_kelas
	select id_rw, sector, subsector, asset, rw, kelurahan, 
	kecamatan, kota, '0', total_asset, '0', '0', '0', total_area_m2, '0', '0' from asset_rw_unit
	where kelas in ('A2') ;
	--kelas A3
	insert into asset_rw_kelas
	select id_rw, sector, subsector,asset, rw, kelurahan, 
	kecamatan, kota, '0', '0', total_asset, '0', '0', '0', total_area_m2, '0' from  asset_rw_unit
	where kelas in ('A3');
	--kelas is null
	insert into asset_rw_kelas
	select id_rw, sector, subsector,asset, rw, kelurahan, 
	kecamatan, kota, '0', '0', '0', total_asset, '0', '0', '0', total_area_m2 from  asset_rw_unit
	where kelas is null;

	--gabungkan asset_rw_agg, asset_rw_unit, dan asset_rw_jalan
	drop table asset_rw;
	create table asset_rw(
	id_rw bigint,
	sector varchar(100),
	subsector varchar(50),
	asset varchar(50),
	rw varchar(50),
	kelurahan varchar(50),
	kecamatan varchar(100),
	kota varchar(100),
	total_asset1 double precision,
	total_asset2 double precision,
	total_asset3 double precision,
	total_asset double precision,
	unit_type varchar(3) default 'U'
	); 
	--insert 1
	--luas
	insert into asset_rw
	select id_rw, sector, subsector, asset, rw, kelurahan, 
	kecamatan, kota, total_area1, total_area2, total_area3, total_area, 'A' from asset_rw_kelas
	where asset in ('HUTAN KOTA', 'RTH', 'KUBURAN_MAKAM', 'RAWA', 'DANAU', 'SITU', 'WADUK', 'TAMAN', 'TANAH KOSONG', 'KOLAM_EMPANG', 'SAWAH','KEBUN') ;
	--unit
	insert into asset_rw
	select id_rw, sector, subsector, asset, rw, kelurahan, 
	kecamatan, kota, total_asset1, total_asset2, total_asset3, total_asset, 'U' from asset_rw_kelas
	where asset not in ('HUTAN KOTA', 'RTH', 'KUBURAN_MAKAM', 'RAWA', 'DANAU', 'SITU', 'WADUK', 'TAMAN', 'TANAH KOSONG', 'KOLAM_EMPANG', 'SAWAH','KEBUN') ;
	--insert3
	insert into asset_rw
	select id_rw, sector, subsector, asset, 
	rw, kelurahan, kecamatan, kota, (total_asset/3), (total_asset/3), (total_asset/3), total_asset,
	'U' from asset_rw_agg;


--ROAD--
--2--aggregate road in RW level
--source table road
drop table asset_rw_jalan;
create table asset_rw_jalan as
select id_rw, 'INFRASTRUKTUR' as sector, 'TRANSPORTASI' as subsector, 'JALAN' as asset, rw, kelurahan, kecamatan, kota, sum(length) as total_length_m, kelas
from road 
GROUP BY kota, kecamatan, kelurahan, rw, id_rw, kelas
order by kota, kecamatan, kelurahan, rw, kelas;

--buat tabel asset_jalan_kelas-
drop table asset_jalan_kelas;
create table asset_jalan_kelas(
id_rw bigint,
sector varchar(100),
subsector varchar(50),
asset varchar(50),
rw varchar(50),
kelurahan varchar(50),
kecamatan varchar(100),
kota varchar(100),
total_length1 double precision,
total_length2 double precision,
total_length3 double precision,
total_length double precision
); 
--insert 1
--kelas A1
insert into asset_jalan_kelas
select id_rw, sector, subsector, asset, rw, kelurahan, 
kecamatan, kota, total_length_m, 0, 0, 0 from asset_rw_jalan
where kelas in ('A1') ;
--kelas A2
insert into asset_jalan_kelas
select id_rw, sector, subsector, asset, rw, kelurahan, 
kecamatan, kota, 0, total_length_m, 0, 0 from asset_rw_jalan
where kelas in ('A2') ;
--kelas A3
insert into asset_jalan_kelas
select id_rw, sector, subsector, asset, rw, kelurahan, 
kecamatan, kota, 0, 0, total_length_m, 0 from asset_rw_jalan
where kelas in ('A3');
--kelas is null
insert into asset_jalan_kelas
select id_rw, sector, subsector, asset, rw, kelurahan, 
kecamatan, kota, 0, 0, 0, total_length_m from asset_rw_jalan
where kelas is null;

--gabungkan asset_rw_jalan ke asset_rw
--delete data jalan lama dari asset_rw
delete from asset_rw
where asset = 'JALAN';
--insert data jalan
insert into asset_rw
select id_rw, sector, subsector,asset, rw, kelurahan, 
kecamatan, kota, total_length1, total_length2, total_length3, total_length, 'L' from asset_jalan_kelas;

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-- pre calculation dal RW
-- asset_rwjoin dal_matrix
DROP TABLE asset_rw_calc;
CREATE TABLE asset_rw_calc(
	id_rw bigint,
	sector varchar(100),
	subsector varchar(100),
	asset varchar(100),
	rw varchar(50),
	kelurahan varchar(50),
	kecamatan varchar(50),
	kota varchar(50),
	unit_type varchar(3),
	total_asset1 double precision,
	total_asset2 double precision,
	total_asset3 double precision,
	total_asset double precision,
	tda1 double precision,
	tda2 double precision,
	tda3 double precision,
	tda4 double precision,
	tdb1 double precision,
	tdb2 double precision,
	tdb3 double precision,
	tdb4 double precision,
	tdc1 double precision,
	tdc2 double precision,
	tdc3 double precision,
	tdc4 double precision,
	tdd1 double precision,
	tdd2 double precision,
	tdd3 double precision,
	tdd4 double precision,
	tla1 double precision,
	tla2 double precision,
	tla3 double precision,
	tla4 double precision,
	tlb1 double precision,
	tlb2 double precision,
	tlb3 double precision,
	tlb4 double precision,
	tlc1 double precision,
	tlc2 double precision,
	tlc3 double precision,
	tlc4 double precision,
	tld1 double precision,
	tld2 double precision,
	tld3 double precision,
	tld4 double precision
	);

insert into asset_rw_calc
select id_rw, sector, asset_rw.subsector, asset_rw.asset, rw,
kelurahan, kecamatan, kota, asset_rw.unit_type, total_asset1, total_asset2, total_asset3, total_asset,
da1*total_asset3 as tda1,
(da2*total_asset3)+(da1*total_asset2) as tda2,
(da3*total_asset3)+(da2*total_asset2)+(da1*total_asset1) as tda3,
(da4*total_asset3)+(da4*total_asset2)+(da4*total_asset1)+(da4*total_asset) as tda4,
db1*total_asset3 as tdb1,
(db2*total_asset3)+(db1*total_asset2) as tdb2,
(db3*total_asset3)+(db2*total_asset2)+(db1*total_asset1) as tdb3,
(db4*total_asset3)+(db4*total_asset2)+(db4*total_asset1)+(db4*total_asset) as tdb4,
dc1*total_asset3 as tdc1,
(dc2*total_asset3)+(dc1*total_asset2) as tdc2,
(dc3*total_asset3)+(dc2*total_asset2)+(dc1*total_asset1) as tdc3,
(dc4*total_asset3)+(dc4*total_asset2)+(dc4*total_asset1)+(dc4*total_asset) as tdc4,
dd1*total_asset3 as tdd1,
(dd2*total_asset3)+(dd1*total_asset2) as tdd2,
(dd3*total_asset3)+(dd2*total_asset2)+(dd1*total_asset1) as tdd3,
(dd4*total_asset3)+(dd4*total_asset2)+(dd4*total_asset1)+(dd4*total_asset) as tda4,
la1*total_asset3 as tla1,
(la2*total_asset3)+(la1*total_asset2) as tla2,
(la3*total_asset3)+(la2*total_asset2)+(la1*total_asset1) as tla3,
(la4*total_asset3)+(la4*total_asset2)+(la4*total_asset1)+(la4*total_asset) as tla4,
lb1*total_asset3 as tlb1,
(lb2*total_asset3)+(lb1*total_asset2) as tlb2,
(lb3*total_asset3)+(lb2*total_asset2)+(lb1*total_asset1) as tlb3,
(lb4*total_asset3)+(lb4*total_asset2)+(lb4*total_asset1)+(lb4*total_asset) as tla4,
lc1*total_asset3 as tlc1,
(lc2*total_asset3)+(lc1*total_asset2) as tlc2,
(lc3*total_asset3)+(lc2*total_asset2)+(lc1*total_asset1) as tlc3,
(lc4*total_asset3)+(lc4*total_asset2)+(lc4*total_asset1)+(lc4*total_asset) as tlc4,
ld1*total_asset3 as tld1,
(ld2*total_asset3)+(ld1*total_asset2) as tld2,
(ld3*total_asset3)+(ld2*total_asset2)+(ld1*total_asset1) as tld3,
(ld4*total_asset3)+(ld4*total_asset2)+(ld4*total_asset1)+(ld4*total_asset) as tld4
from asset_rw
left join dal_matrix on (asset_rw.asset = dal_matrix.asset);



-- calculate dal RW
-- asset_rw join dal_matrix
DROP table asset_rw_dal;
CREATE TABLE asset_rw_dal(
	id_rw bigint,
	sector varchar(100),
	subsector varchar(100),
	asset varchar(100),
	rw varchar(50),
	kelurahan varchar(50),
	kecamatan varchar(50),
	kota varchar(50),
	unit_type varchar(3),
	total_asset double precision,
	tda1 double precision,
	tda2 double precision,
	tda3 double precision,
	tda4 double precision,
	tdb1 double precision,
	tdb2 double precision,
	tdb3 double precision,
	tdb4 double precision,
	tdc1 double precision,
	tdc2 double precision,
	tdc3 double precision,
	tdc4 double precision,
	tdd1 double precision,
	tdd2 double precision,
	tdd3 double precision,
	tdd4 double precision,
	tla1 double precision,
	tla2 double precision,
	tla3 double precision,
	tla4 double precision,
	tlb1 double precision,
	tlb2 double precision,
	tlb3 double precision,
	tlb4 double precision,
	tlc1 double precision,
	tlc2 double precision,
	tlc3 double precision,
	tlc4 double precision,
	tld1 double precision,
	tld2 double precision,
	tld3 double precision,
	tld4 double precision
);

insert into asset_rw_dal
select id_rw, sector, subsector, asset, rw,
kelurahan, kecamatan, kota, unit_type, (total_asset1 + total_asset2 + total_asset3 + total_asset) as total_asset, tda1,
tda2, tda3, tda4, tdb1, tdb2, tdb3, tdb4, tdc1, tdc2, tdc3, tdc4,
tdd1, tdd2, tdd3, tdd4, tla1, tla2, tla3, tla4, tlb1, tlb2, tlb3,
tlb4, tlc1, tlc2, tlc3, tlc4, tld1, tld2, tld3, tld4
from asset_rw_calc;



--KENDARAAN
--kendaraan rw
drop table kendaraan_rw;
create table kendaraan_rw as
select id_rw, kota, kecamatan, kelurahan, rw, kelas,
sum(motor*length) sum_motor,sum(mobil*length) sum_mobil,sum(angkot*length) sum_angkot, sum(bus_sedang*length) sum_bus_sedang,
sum(bus_besar*length) sum_bus_besar, sum(truck*length) sum_truck, sum(lainnya*length) sum_lainnya,
sum(length) sum_length, sum(lajur) sum_lajur, sum(length/5*lajur) length_lajur from road
group by id_rw, kota, kecamatan, kelurahan, rw, kelas;

--kendaraan_rw_kelas
drop table kendaraan_rw_kelas;
CREATE TABLE kendaraan_rw_kelas
(
  id_rw bigint,
  sector character varying(200),
  subsector character varying(200),
  asset character varying(200),
  rw character varying(50),
  kelurahan character varying(50),
  kecamatan character varying(50),
  kota character varying(50),
  sum_motor1 numeric,
  sum_motor2 numeric,
  sum_motor3 numeric,
  sum_motor numeric,
  sum_mobil1 numeric,
  sum_mobil2 numeric,
  sum_mobil3 numeric,
  sum_mobil numeric,
  sum_angkot1 numeric,
  sum_angkot2 numeric,
  sum_angkot3 numeric,
  sum_angkot numeric,
  sum_bus_sedang1 numeric,
  sum_bus_sedang2 numeric,
  sum_bus_sedang3 numeric,
  sum_bus_sedang numeric,
  sum_bus_besar1 numeric,
  sum_bus_besar2 numeric,
  sum_bus_besar3 numeric,
  sum_bus_besar numeric,
  sum_truck1 numeric,
  sum_truck2 numeric,
  sum_truck3 numeric,
  sum_truck numeric,
  sum_length1 numeric,
  sum_length2 numeric,
  sum_length3 numeric,
  summ_length numeric,
  sum_lainnya1 numeric,
  sum_lainnya2 numeric,
  sum_lainnya3 numeric,
  sum_lainnya numeric,
  sum_lajur1 numeric,
  sum_lajur2 numeric,
  sum_lajur3 numeric,
  sum_lajur numeric,
  length_lajur1 numeric,
  length_lajur2 numeric,
  length_lajur3 numeric,
  length_lajur numeric
  );

--insert into kendaraan_rw_kelas
--insert 1
--kelas A1
  insert into kendaraan_rw_kelas
  select id_rw, 'INFRASTRUKTUR' sector, 'TRANSPORTASI' subsector, 'KENDARAAN' asset, rw, kelurahan, 
  kecamatan, kota, sum_motor, 0, 0, 0, sum_mobil, 0, 0, 0,
  sum_angkot, 0, 0, 0, sum_bus_sedang, 0, 0, 0,
  sum_bus_besar, 0, 0, 0, sum_truck, 0, 0, 0,
  sum_length, 0, 0, 0, sum_lainnya, 0, 0, 0,
  sum_lajur, 0, 0, 0, length_lajur, 0, 0, 0
  from kendaraan_rw
  where kelas in ('A1');
--kelas A2
  insert into kendaraan_rw_kelas
  select id_rw, 'INFRASTRUKTUR' sector, 'TRANSPORTASI' subsector, 'KENDARAAN' asset, rw, kelurahan, 
  kecamatan, kota, 0, sum_motor, 0, 0, 0, sum_mobil , 0, 0,
  0, sum_angkot, 0, 0, 0, sum_bus_sedang, 0, 0,
  0, sum_bus_besar, 0, 0, 0, sum_truck, 0, 0,
  0, sum_length, 0, 0, 0, sum_lainnya, 0, 0,
  0, sum_lajur, 0, 0, 0, length_lajur, 0, 0
  from kendaraan_rw
  where kelas in ('A2') ;
--kelas A3
  insert into kendaraan_rw_kelas
  select id_rw, 'INFRASTRUKTUR' sector, 'TRANSPORTASI' subsector, 'KENDARAAN' asset, rw, kelurahan, 
  kecamatan, kota, 0, 0, sum_motor, 0, 0, 0 , sum_mobil, 0,
  0, 0, sum_angkot, 0, 0, 0, sum_bus_sedang, 0,
  0, 0, sum_bus_besar, 0, 0, 0, sum_truck, 0,
  0, 0, sum_length, 0, 0, 0, sum_lainnya, 0,
  0, 0, sum_lajur, 0,0, 0, length_lajur, 0
  from kendaraan_rw
  where kelas in ('A3') ;
--kelas A4 atau null
  insert into kendaraan_rw_kelas
  select id_rw, 'INFRASTRUKTUR' sector, 'TRANSPORTASI' subsector, 'KENDARAAN' asset, rw, kelurahan, 
  kecamatan, kota, 0, 0, 0, sum_motor, 0, 0 , 0, sum_mobil,
  0, 0, 0,sum_angkot, 0, 0, 0, sum_bus_sedang,
  0, 0, 0, sum_bus_besar, 0, 0, 0, sum_truck,
  0, 0, 0, sum_length, 0, 0, 0, sum_lainnya,
  0, 0, 0, sum_lajur, 0, 0, 0, length_lajur
  from kendaraan_rw
  where kelas is null ;


drop table kendaraan_rw_loss;
CREATE TABLE kendaraan_rw_loss
(
  id_rw bigint,
  sector character varying(200),
  subsector character varying(200),
  asset character varying(200),
  rw character varying(50),
  kelurahan character varying(50),
  kecamatan character varying(50),
  kota character varying(50),
  tla1 double precision,
  tla2 double precision,
  tla3 double precision,
  tla4 double precision,
  tlb1 double precision,
  tlb2 double precision,
  tlb3 double precision,
  tlb4 double precision,
  tlc1 double precision,
  tlc2 double precision,
  tlc3 double precision,
  tlc4 double precision,
  tld1 double precision,
  tld2 double precision,
  tld3 double precision,
  tld4 double precision
);
insert into kendaraan_rw_loss  
select id_rw, sector, subsector, asset, rw, kelurahan, kecamatan, kota, 
((sum_bus_besar3*0.5*(select a1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select a1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang3*0.5*(select a1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select a1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot3*0.5*(select a1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select a1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur3*(select a1 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM')
tla1,

(((sum_bus_besar3*0.5*(select a2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select a2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang3*0.5*(select a2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select a2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot3*0.5*(select a2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select a2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur3*(select a2 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM')) +
(((sum_bus_besar2*0.5*(select a1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select a1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang2*0.5*(select a1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select a1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot2*0.5*(select a1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select a1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur2*(select a1 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))
tla2,

(((sum_bus_besar3*0.5*(select a3 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select a3 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang3*0.5*(select a3 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select a3 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot3*0.5*(select a3 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select a3 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur3*(select a3 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))+
(((sum_bus_besar2*0.5*(select a2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select a2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang2*0.5*(select a2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select a2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot2*0.5*(select a2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select a2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur2*(select a2 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM')) +
(((sum_bus_besar1*0.5*(select a1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select a1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang1*0.5*(select a1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select a1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot1*0.5*(select a1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select a1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur1*(select a1 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))
tla3,

(((sum_bus_besar*0.5*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang*0.5*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot*0.5*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))+
(((sum_bus_besar1*0.5*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang1*0.5*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot1*0.5*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur1*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))+
(((sum_bus_besar2*0.5*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang2*0.5*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot2*0.5*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur2*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))+
(((sum_bus_besar3*0.5*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang3*0.5*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot3*0.5*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur3*(select a4 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))
tla4,

((sum_bus_besar3*0.5*(select b1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select b1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang3*0.5*(select b1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select b1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot3*0.5*(select b1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select b1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur3*(select b1 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM')
tlb1,

(((sum_bus_besar3*0.5*(select b2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select b2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang3*0.5*(select b2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select b2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot3*0.5*(select b2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select b2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur3*(select b2 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM')) +
(((sum_bus_besar2*0.5*(select b1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select b1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang2*0.5*(select b1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select b1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot2*0.5*(select b1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select b1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur2*(select b1 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))
tlb2,

(((sum_bus_besar3*0.5*(select b3 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select b3 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang3*0.5*(select b3 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select b3 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot3*0.5*(select b3 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select b3 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur3*(select b3 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))+
(((sum_bus_besar2*0.5*(select b2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select b2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang2*0.5*(select b2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select b2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot2*0.5*(select b2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select b2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur2*(select b2 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM')) +
(((sum_bus_besar1*0.5*(select b1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select b1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang1*0.5*(select b1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select b1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot1*0.5*(select b1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select b1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur1*(select b1 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))
tlb3,

(((sum_bus_besar*0.5*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang*0.5*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot*0.5*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))+
(((sum_bus_besar1*0.5*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang1*0.5*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot1*0.5*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur1*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))+
(((sum_bus_besar2*0.5*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang2*0.5*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot2*0.5*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur2*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))+
(((sum_bus_besar3*0.5*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang3*0.5*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot3*0.5*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur3*(select b4 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))
tlb4,

((sum_bus_besar3*0.5*(select c1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select c1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang3*0.5*(select c1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select c1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot3*0.5*(select c1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select c1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur3*(select c1 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM')
tlc1,

(((sum_bus_besar3*0.5*(select c2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select c2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang3*0.5*(select c2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select c2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot3*0.5*(select c2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select c2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur3*(select c2 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM')) +
(((sum_bus_besar2*0.5*(select c1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select c1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang2*0.5*(select c1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select c1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot2*0.5*(select c1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select c1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur2*(select c1 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))
tlc2,

(((sum_bus_besar3*0.5*(select c3 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select c3 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang3*0.5*(select c3 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select c3 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot3*0.5*(select c3 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select c3 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur3*(select c3 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))+
(((sum_bus_besar2*0.5*(select c2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select c2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang2*0.5*(select c2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select c2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot2*0.5*(select c2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select c2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur2*(select c2 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM')) +
(((sum_bus_besar1*0.5*(select c1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select c1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang1*0.5*(select c1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select c1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot1*0.5*(select c1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select c1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur1*(select c1 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))
tlc3,

(((sum_bus_besar*0.5*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang*0.5*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot*0.5*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))+
(((sum_bus_besar1*0.5*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang1*0.5*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot1*0.5*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur1*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))+
(((sum_bus_besar2*0.5*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang2*0.5*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot2*0.5*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur2*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))+
(((sum_bus_besar3*0.5*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang3*0.5*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot3*0.5*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur3*(select c4 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))
tlc4,

((sum_bus_besar3*0.5*(select d1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select d1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang3*0.5*(select d1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select d1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot3*0.5*(select d1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select d1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur3*(select d1 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM')
tld1,

(((sum_bus_besar3*0.5*(select d2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select d2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang3*0.5*(select d2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select d2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot3*0.5*(select d2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select d2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur3*(select d2 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM')) +
(((sum_bus_besar2*0.5*(select d1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select d1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang2*0.5*(select d1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select d1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot2*0.5*(select d1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select d1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur2*(select d1 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))
tld2,

(((sum_bus_besar3*0.5*(select d3 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select d3 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang3*0.5*(select d3 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select d3 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot3*0.5*(select d3 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select d3 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur3*(select d3 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))+
(((sum_bus_besar2*0.5*(select d2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select d2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang2*0.5*(select d2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select d2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot2*0.5*(select d2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select d2 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur2*(select d2 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM')) +
(((sum_bus_besar1*0.5*(select d1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select d1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang1*0.5*(select d1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select d1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot1*0.5*(select d1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select d1 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur1*(select d1 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))
tld3,

(((sum_bus_besar*0.5*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang*0.5*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot*0.5*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))+
(((sum_bus_besar1*0.5*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang1*0.5*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot1*0.5*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur1*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))+
(((sum_bus_besar2*0.5*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang2*0.5*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot2*0.5*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur2*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))+
(((sum_bus_besar3*0.5*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
40*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*9000) +
(sum_bus_sedang3*0.5*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*0.7*
20*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*4000) +
(sum_angkot3*0.5*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Volume Angkutan Umum')*
8*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Penurunan Kapasitas Angkutan Umum')*3500)) + 
length_lajur3*(select d4 from asumsi_kendaraan where asumsi_kendaraan = 'Kerugian BBM'))
tld4
from kendaraan_rw_kelas;

-----------------------END------------------