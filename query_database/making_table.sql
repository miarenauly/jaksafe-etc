-- Table: asset_aggregate

-- DROP TABLE asset_aggregate;

CREATE TABLE asset_aggregate
(
  aggregate_level character varying(100),
  kota character varying(100),
  kecamatan character varying(100),
  kelurahan character varying(100),
  rw character varying(100),
  rt character varying(100),
  sector character varying(100),
  subsector character varying(100),
  asset character varying(100),
  total_asset numeric
)
WITH (
  OIDS=FALSE
);
ALTER TABLE asset_aggregate
  OWNER TO postgres;




-- Table: dal_matrix

-- DROP TABLE dal_matrix;

CREATE TABLE dal_matrix
(
  subsector character varying(100),
  asset character varying(100),
  la1 numeric,
  la2 numeric,
  la3 numeric,
  la4 numeric,
  lb1 numeric,
  lb2 numeric,
  lb3 numeric,
  lb4 numeric,
  lc1 numeric,
  lc2 numeric,
  lc3 numeric,
  lc4 numeric,
  ld1 numeric,
  ld2 numeric,
  ld3 numeric,
  ld4 numeric,
  da1 numeric,
  da2 numeric,
  da3 numeric,
  da4 numeric,
  db1 numeric,
  db2 numeric,
  db3 numeric,
  db4 numeric,
  dc1 numeric,
  dc2 numeric,
  dc3 numeric,
  dc4 numeric,
  dd1 numeric,
  dd2 numeric,
  dd3 numeric,
  dd4 numeric,
  unit_type character varying(3)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE dal_matrix
  OWNER TO postgres;



-- Table: asumsi_kendaraan

-- DROP TABLE asumsi_kendaraan;

CREATE TABLE asumsi_kendaraan
(
  id serial NOT NULL,
  asumsi_kendaraan character varying(100),
  a1 numeric,
  a2 numeric,
  a3 numeric,
  a4 numeric,
  b1 numeric,
  b2 numeric,
  b3 numeric,
  b4 numeric,
  c1 numeric,
  c2 numeric,
  c3 numeric,
  c4 numeric,
  d1 numeric,
  d2 numeric,
  d3 numeric,
  d4 numeric,
  CONSTRAINT asumsi_kendaraan_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE asumsi_kendaraan
  OWNER TO postgres;
