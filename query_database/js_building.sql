 delete from building_exposure where building_exposure = 'NO DATA';
 UPDATE building_exposure
 set sector = 'SOSIAL DAN PERUMAHAN'
 where sector = 'PRODUKTIF' AND subsector = 'PERUMAHAN';

delete from building_exposure
where id_rw is null;

update building_exposure
set id_kel = substring (id_rw, 1 ,10)
where id_kel is null;

UPDATE building_exposure
SET kelurahan = boundary.kelurahan FROM boundary
WHERE building_exposure.id_kel= boundary.id_kel;

UPDATE building_exposure
SET kecamatan = boundary.kecamatan FROM boundary
WHERE building_exposure.id_kel= boundary.id_kel;

UPDATE building_exposure
SET kota = boundary.kota FROM boundary
WHERE building_exposure.id_kel= boundary.id_kel;


create table asset as (select nama, id_building_exposure, sector, subsector, building_exposure, jalan, area_m2, rw, 
       id_kel, id_rw, kelurahan, kecamatan, kota, kelas from building_exposure)


ALTER TABLE asset ALTER COLUMN nama TYPE varchar (100);
ALTER TABLE asset ALTER COLUMN id_asset TYPE varchar (50);
ALTER TABLE asset ALTER COLUMN sector TYPE varchar (100);
ALTER TABLE asset ALTER COLUMN subsector TYPE varchar (50);
ALTER TABLE asset ALTER COLUMN asset TYPE varchar (50);
ALTER TABLE asset ALTER COLUMN jalan TYPE varchar (200);
ALTER TABLE asset ALTER COLUMN kelurahan TYPE character varying (50);
ALTER TABLE asset ALTER COLUMN area_m2 TYPE double precision;
ALTER TABLE asset ALTER COLUMN id_rw TYPE bigint USING (id_rw::bigint);
ALTER TABLE asset ALTER COLUMN kecamatan TYPE character varying (100);
ALTER TABLE asset ALTER COLUMN kota TYPE character varying (100);
ALTER TABLE asset ALTER COLUMN rw TYPE character varying (50)