-- MAKING ID--

ALTER TABLE road_exposure ADD COLUMN bar bigserial;
ALTER TABLE road_exposure ALTER COLUMN bar TYPE varchar (15);

UPDATE road_exposure
SET bar = lpad(bar, 5, '0');

ALTER TABLE road_exposure ADD COLUMN id_type varchar (10);

UPDATE road_exposure SET id_type = '10' where osm_type = 'construction';
UPDATE road_exposure SET id_type = '11' where osm_type = 'crossing';
UPDATE road_exposure SET id_type = '12' where osm_type = 'cycleway';
UPDATE road_exposure SET id_type = '13' where osm_type = 'footway';
UPDATE road_exposure SET id_type = '14' where osm_type = 'motorway';
UPDATE road_exposure SET id_type = '15' where osm_type = 'motorway_link';
UPDATE road_exposure SET id_type = '16' where osm_type = 'path';
UPDATE road_exposure SET id_type = '17' where osm_type = 'pedestrian';
UPDATE road_exposure SET id_type = '01' where osm_type = 'primary';
UPDATE road_exposure SET id_type = '02' where osm_type = 'primary_link';
UPDATE road_exposure SET id_type = '09' where osm_type = 'residential';
UPDATE road_exposure SET id_type = '18' where osm_type = 'road';
UPDATE road_exposure SET id_type = '03' where osm_type = 'secondary';
UPDATE road_exposure SET id_type = '04' where osm_type = 'secondary_link';
UPDATE road_exposure SET id_type = '19' where osm_type = 'service';
UPDATE road_exposure SET id_type = '20' where osm_type = 'steps';
UPDATE road_exposure SET id_type = '05' where osm_type = 'tertiary';
UPDATE road_exposure SET id_type = '06' where osm_type = 'tertiary_link';
UPDATE road_exposure SET id_type = '21' where osm_type = 'track';
UPDATE road_exposure SET id_type = '07' where osm_type = 'trunk';
UPDATE road_exposure SET id_type = '08' where osm_type = 'trunk_link';
UPDATE road_exposure SET id_type = '22' where osm_type = 'unclassified';
UPDATE road_exposure SET id_type = '23' where osm_type = 'yes';

ALTER TABLE road_exposure ADD COLUMN id_street varchar (30);

UPDATE road_exposure SET id_street = id_rw||id_type||bar;


--ADDING COLUMN LAJUR--

ALTER TABLE road_exposure ADD COLUMN lajur integer;

UPDATE road_exposure SET lajur =6 WHERE osm_type = 'primary';
UPDATE road_exposure SET lajur =4 WHERE osm_type = 'primary_link';
UPDATE road_exposure SET lajur =4 WHERE osm_type = 'secondary';
UPDATE road_exposure SET lajur =4 WHERE osm_type = 'secondary_link';
UPDATE road_exposure SET lajur =2 WHERE osm_type = 'tertiary';
UPDATE road_exposure SET lajur =2 WHERE osm_type = 'tertiary_link';
UPDATE road_exposure SET lajur =2 WHERE osm_type = 'service';
UPDATE road_exposure SET lajur =1 WHERE osm_type = 'residential';
UPDATE road_exposure SET lajur =2 WHERE osm_type = 'trunk';
UPDATE road_exposure SET lajur =2 WHERE osm_type = 'trunk_link';


--FORMATING TABLE--

ALTER TABLE road_exposure ALTER COLUMN id_rw TYPE bigint USING (id_rw::bigint);
ALTER TABLE road_exposure ALTER COLUMN osm_type TYPE character varying(50);
ALTER TABLE road_exposure ALTER COLUMN name TYPE character varying(50);
ALTER TABLE road_exposure ALTER COLUMN kota TYPE character varying(50);
ALTER TABLE road_exposure ALTER COLUMN kecamatan TYPE character varying(50);
ALTER TABLE road_exposure ALTER COLUMN kelurahan TYPE character varying(50);
ALTER TABLE road_exposure ALTER COLUMN rw TYPE character varying(50);
ALTER TABLE road_exposure ALTER COLUMN id_rw TYPE bigint;
ALTER TABLE road_exposure ALTER COLUMN length TYPE double precision;
ALTER TABLE road_exposure ALTER COLUMN id_street TYPE character varying(30);
ALTER TABLE road_exposure ALTER COLUMN motor TYPE double precision;
ALTER TABLE road_exposure ALTER COLUMN mobil TYPE double precision;
ALTER TABLE road_exposure ALTER COLUMN angkot TYPE double precision;
ALTER TABLE road_exposure ALTER COLUMN bus_sedang TYPE double precision;
ALTER TABLE road_exposure ALTER COLUMN bus_besar TYPE double precision;
ALTER TABLE road_exposure ALTER COLUMN truck TYPE double precision;
ALTER TABLE road_exposure ALTER COLUMN lainnya TYPE double precision;
ALTER TABLE road_exposure ALTER COLUMN length TYPE double precision;
ALTER TABLE road_exposure ALTER COLUMN id_kel TYPE varchar (50);


--CREATE NEW DATABASE (AS FORMAT)--

CREATE TABLE road AS (SELECT motor, mobil, angkot, bus_sedang, bus_besar, truck, lainnya, 
       osm_type, name, rw, id_kel, id_rw, kelurahan, kecamatan, kota, 
       length, id_street, lajur, kelas FROM public.road_exposure)