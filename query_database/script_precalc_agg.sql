
---asset aggergate
drop table count_kelurahan_rw;
create table count_kelurahan_rw as
select kota, kecamatan, kelurahan, count(rw) from boundary group by kota, kecamatan, kelurahan order by kota, kecamatan, kelurahan;

drop table count_kecamatan_rw;
create table count_kecamatan_rw as
select kota, kecamatan, count(rw) from boundary group by kota, kecamatan order by kota, kecamatan;

drop table count_kota_rw;
create table count_kota_rw as
select kota, count(rw) from boundary group by kota order by kota;

--create aggregate rw, jalankan query setiap ada perubahan aggregate asset baru
drop table asset_rw_agg;
CREATE TABLE asset_rw_agg
(
  id_rw bigint,
  sector character varying(100),
  subsector character varying(50),
  asset character varying(50),
  rw character varying(50),
  kelurahan character varying(50),
  kecamatan character varying(100),
  kota character varying(100),
  total_asset double precision
);
--breakdown dari level kelurahan
--jumlah asset >= jumlah RW akan dinput menggunakan query ini, yang < akan dibuakan query terpisah
--jumlah asset >= jumlah RW (insert into asaet_rw_agg)
insert into asset_rw_agg
select id_rw, sector, subsector, asset, d.rw, d.kelurahan, d.kecamatan, d.kota, c.per_rw from 
(select sector, subsector, asset, a.kelurahan, b.count as jumlah_rw, total_asset, round(total_asset/b.count,0) as per_rw 
from asset_aggregate a left join count_kelurahan_rw b on (a.kelurahan = b.kelurahan)  
where aggregate_level = 'KELURAHAN' and total_asset>= b.count order by jumlah_rw desc) c, boundary d 
where c.kelurahan = d.kelurahan and rw is not null and id_rw is not null;

--breakdown dari level kecamatan
--jumlah asset >= jumlah RW akan dinput menggunakan query ini, yang < akan dibuakan query terpisah
--jumlah asset >= jumlah RW (insert into asset_rw_agg)
insert into asset_rw_agg
select id_rw, sector, subsector, asset, d.rw, d.kelurahan, d.kecamatan, d.kota, c.per_rw from 
(select sector, subsector, asset, a.kecamatan, b.count as jumlah_rw, total_asset, round(total_asset/b.count,0) as per_rw 
from asset_aggregate a left join count_kecamatan_rw b on (a.kecamatan = b.kecamatan)  
where aggregate_level = 'KECAMATAN' and total_asset>= b.count order by jumlah_rw desc) c, boundary d 
where c.kecamatan = d.kecamatan and rw is not null and id_rw is not null;

-- yang belum, asset yang jumlahnya kurang dari jumlah rw di kecamatan(34 row) dan kelurahan(420 row)
--yang  diletakkan satu2 di setiap RW, mulai dari rw1
--satu asset 
insert into asset_rw_agg
select id_rw, sector, subsector, asset, d.rw, d.kelurahan, d.kecamatan, d.kota, c.total_asset from
(select sector, subsector, asset, a.kelurahan, b.count as jumlah_rw, total_asset, round(total_asset/b.count,0) as per_rw 
from asset_aggregate a left join count_kelurahan_rw b on (a.kelurahan = b.kelurahan)  
where aggregate_level = 'KELURAHAN' and total_asset < b.count and total_asset = 1 order by total_asset asc)c, boundary d 
where c.kelurahan = d.kelurahan and rw ='001' and id_rw is not null;

--dua asset
insert into asset_rw_agg
select id_rw, sector, subsector, asset, d.rw, d.kelurahan, d.kecamatan, d.kota, 1 as t_ast from
(select sector, subsector, asset, a.kelurahan, b.count as jumlah_rw, total_asset, round(total_asset/b.count,0) as per_rw 
from asset_aggregate a left join count_kelurahan_rw b on (a.kelurahan = b.kelurahan)  
where aggregate_level = 'KELURAHAN' and total_asset < b.count and total_asset = 2 order by total_asset asc)c, boundary d 
where c.kelurahan = d.kelurahan and rw in ('001', '002') and id_rw is not null;

--tiga asset
insert into asset_rw_agg
select id_rw, sector, subsector, asset, d.rw, d.kelurahan, d.kecamatan, d.kota, 1 as t_ast from
(select sector, subsector, asset, a.kelurahan, b.count as jumlah_rw, total_asset, round(total_asset/b.count,0) as per_rw 
from asset_aggregate a left join count_kelurahan_rw b on (a.kelurahan = b.kelurahan)  
where aggregate_level = 'KELURAHAN' and total_asset < b.count and total_asset = 3 order by total_asset asc)c, boundary d 
where c.kelurahan = d.kelurahan and rw in ('001', '002','003') and id_rw is not null;

--empat asset
insert into asset_rw_agg
select id_rw, sector, subsector, asset, d.rw, d.kelurahan, d.kecamatan, d.kota, 1 as t_ast from
(select sector, subsector, asset, a.kelurahan, b.count as jumlah_rw, total_asset, round(total_asset/b.count,0) as per_rw 
from asset_aggregate a left join count_kelurahan_rw b on (a.kelurahan = b.kelurahan)  
where aggregate_level = 'KELURAHAN' and total_asset < b.count and total_asset = 4 order by total_asset asc)c, boundary d 
where c.kelurahan = d.kelurahan and rw in ('001', '002','003','004') and id_rw is not null;

--lima asset
insert into asset_rw_agg
select id_rw, sector, subsector, asset, d.rw, d.kelurahan, d.kecamatan, d.kota, 1 as t_ast from
(select sector, subsector, asset, a.kelurahan, b.count as jumlah_rw, total_asset, round(total_asset/b.count,0) as per_rw 
from asset_aggregate a left join count_kelurahan_rw b on (a.kelurahan = b.kelurahan)  
where aggregate_level = 'KELURAHAN' and total_asset < b.count and total_asset = 5 order by total_asset asc)c, boundary d 
where c.kelurahan = d.kelurahan and rw in ('001', '002','003','004','005') and id_rw is not null;

--enam asset
insert into asset_rw_agg
select id_rw, sector, subsector, asset, d.rw, d.kelurahan, d.kecamatan, d.kota, 1 as t_ast from
(select sector, subsector, asset, a.kelurahan, b.count as jumlah_rw, total_asset, round(total_asset/b.count,0) as per_rw 
from asset_aggregate a left join count_kelurahan_rw b on (a.kelurahan = b.kelurahan)  
where aggregate_level = 'KELURAHAN' and total_asset < b.count and total_asset = 6 order by total_asset asc)c, boundary d 
where c.kelurahan = d.kelurahan and rw in ('001', '002','003','004','005','006') and id_rw is not null;

--tujuh asset
insert into asset_rw_agg
select id_rw, sector, subsector, asset, d.rw, d.kelurahan, d.kecamatan, d.kota, 1 as t_ast from
(select sector, subsector, asset, a.kelurahan, b.count as jumlah_rw, total_asset, round(total_asset/b.count,0) as per_rw 
from asset_aggregate a left join count_kelurahan_rw b on (a.kelurahan = b.kelurahan)  
where aggregate_level = 'KELURAHAN' and total_asset < b.count and total_asset = 7 order by total_asset asc)c, boundary d 
where c.kelurahan = d.kelurahan and rw in ('001', '002','003','004','005','006','007') and id_rw is not null;

--delapan asset
insert into asset_rw_agg
select id_rw, sector, subsector, asset, d.rw, d.kelurahan, d.kecamatan, d.kota, 1 as t_ast from
(select sector, subsector, asset, a.kelurahan, b.count as jumlah_rw, total_asset, round(total_asset/b.count,0) as per_rw 
from asset_aggregate a left join count_kelurahan_rw b on (a.kelurahan = b.kelurahan)  
where aggregate_level = 'KELURAHAN' and total_asset < b.count and total_asset = 8 order by total_asset asc)c, boundary d 
where c.kelurahan = d.kelurahan and rw in ('001', '002','003','004','005','006','007','008') and id_rw is not null;

--sembilan asset
insert into asset_rw_agg
select id_rw, sector, subsector, asset, d.rw, d.kelurahan, d.kecamatan, d.kota, 1 as t_ast from
(select sector, subsector, asset, a.kelurahan, b.count as jumlah_rw, total_asset, round(total_asset/b.count,0) as per_rw 
from asset_aggregate a left join count_kelurahan_rw b on (a.kelurahan = b.kelurahan)  
where aggregate_level = 'KELURAHAN' and total_asset < b.count and total_asset = 9 order by total_asset asc)c, boundary d 
where c.kelurahan = d.kelurahan and rw in ('001', '002','003','004','005','006','007','008','009') and id_rw is not null;

--sepuluh asset
insert into asset_rw_agg
select id_rw, sector, subsector, asset, d.rw, d.kelurahan, d.kecamatan, d.kota, 1 as t_ast from
(select sector, subsector, asset, a.kelurahan, b.count as jumlah_rw, total_asset, round(total_asset/b.count,0) as per_rw 
from asset_aggregate a left join count_kelurahan_rw b on (a.kelurahan = b.kelurahan)  
where aggregate_level = 'KELURAHAN' and total_asset < b.count and total_asset = 10 order by total_asset asc)c, boundary d 
where c.kelurahan = d.kelurahan and rw in ('001', '002','003','004','005','006','007','008','009','010') and id_rw is not null;

----12 asset
insert into asset_rw_agg
select id_rw, sector, subsector, asset, d.rw, d.kelurahan, d.kecamatan, d.kota, 1 as t_ast from
(select sector, subsector, asset, a.kelurahan, b.count as jumlah_rw, total_asset, round(total_asset/b.count,0) as per_rw 
from asset_aggregate a left join count_kelurahan_rw b on (a.kelurahan = b.kelurahan)  
where aggregate_level = 'KELURAHAN' and total_asset < b.count and total_asset = 12 order by total_asset asc)c, boundary d 
where c.kelurahan = d.kelurahan and rw in ('001', '002','003','004','005','006','007','008','009','010','011','012') 
and id_rw is not null;

----14 asset
insert into asset_rw_agg
select id_rw, sector, subsector, asset, d.rw, d.kelurahan, d.kecamatan, d.kota, 1 as t_ast from
(select sector, subsector, asset, a.kelurahan, b.count as jumlah_rw, total_asset, round(total_asset/b.count,0) as per_rw 
from asset_aggregate a left join count_kelurahan_rw b on (a.kelurahan = b.kelurahan)  
where aggregate_level = 'KELURAHAN' and total_asset < b.count and total_asset = 14 order by total_asset asc)c, boundary d 
where c.kelurahan = d.kelurahan and rw in ('001', '002','003','004','005','006','007','008','009','010','011','012','013','014') 
and id_rw is not null;

--!!!PROSES MANUAL !!!
--breakdown kecamatan asset kurang dari jumlah kecamatan
-- yang jumlah asset < jumlah RW (jalankan query manual, ambil record sesuai jumlah assetnya)
copy 
(select c.id_rw, sector, subsector, asset,  c.rw, c.kelurahan, c.kecamatan, c.kota,  round(total_asset/b.count,0) as per_rw , b.count as jumlah_rw, total_asset
from asset_aggregate a left join count_kecamatan_rw b on (a.kecamatan = b.kecamatan) left join boundary c on (a.kecamatan = c.kecamatan) 
where aggregate_level = 'KECAMATAN' and total_asset < b.count order by jumlah_rw desc) to 'e:/jakSAFE/kecamatan_asset.csv' 
with (format 'csv',delimiter ',', header true);
--!!!PROSES MANUAL !!!
--edit manual menggunakan excel, kemudian upload ke table asset_rw_agg
copy asset_rw_agg from 'e:/jakSAFE/kecamatan_asset_ready.csv'  with (format 'csv', delimiter ',', header true);
