CREATE SCHEMA IF NOT EXISTS listes;
CREATE SCHEMA IF NOT EXISTS site;
CREATE SCHEMA IF NOT EXISTS import;

CREATE EXTENSION IF NOT EXISTS postgis;

DROP TABLE IF EXISTS site.monument CASCADE;
DROP TABLE IF EXISTS site.mur_secteur CASCADE;
DROP TABLE IF EXISTS site.secteur CASCADE;
DROP TABLE IF EXISTS site.mur CASCADE;
DROP TABLE IF EXISTS site.mur_part CASCADE;
DROP TABLE IF EXISTS site.surface CASCADE;
DROP TABLE IF EXISTS site.materiel_zone CASCADE;
DROP TABLE IF EXISTS site.observation CASCADE;
DROP TABLE IF EXISTS site.zone CASCADE;
DROP TABLE IF EXISTS listes.pierres CASCADE;
DROP TABLE IF EXISTS listes.mortiers CASCADE;
DROP TABLE IF EXISTS listes.mortiers CASCADE;
DROP TABLE IF EXISTS listes.observations CASCADE;

DROP TYPE IF EXISTS site.expo CASCADE;
DROP TYPE IF EXISTS site.zone_type CASCADE;

CREATE TABLE site.monument (
  monument_id    INTEGER PRIMARY KEY,
  monument_nom   VARCHAR,
  geom           geometry(MultiPolygon, 2056)
);

CREATE TABLE site.secteur (
  secteur_id          SERIAL PRIMARY KEY,
  secteur_nom         VARCHAR(3),
  fk_monument         INTEGER REFERENCES site.monument (monument_id),
  geom                geometry(Polygon, 2056)
);

CREATE TABLE site.mur (
  mur_id              SERIAL PRIMARY KEY,
  mur_nom             VARCHAR(4) UNIQUE,
  fk_monument         INTEGER REFERENCES site.monument (monument_id)
);

-- Example nom: M11-cu3 ou M5-ca4
CREATE TABLE site.mur_part (
  mur_part_id         SERIAL PRIMARY KEY,
  fk_mur              INTEGER REFERENCES site.mur (mur_id),
  fk_secteur          INTEGER REFERENCES site.secteur (secteur_id),
  visible             boolean
);

CREATE VIEW site.mur_part_avec_nom AS
SELECT
  mur_part_id,
  CONCAT(mur.mur_nom, '_', secteur.secteur_nom) AS mur_part_nom,
  fk_mur,
  fk_secteur,
  visible
FROM site.mur_part
LEFT JOIN site.mur ON mur.mur_id = mur_part.fk_mur
LEFT JOIN site.secteur ON secteur.secteur_id = mur_part.fk_secteur
;

CREATE TYPE site.expo AS ENUM (
  'S',
  'SE',
  'E',
  'NE',
  'N',
  'NO',
  'O',
  'SO',
  'VH',
  'VB'
);

CREATE TABLE site.surface (
  surface_id          SERIAL PRIMARY KEY,
  exposition          site.expo,
  mur_nom             VARCHAR(3),
  geom_frontal        geometry(Polygon, 1),      -- TODO: FIND USEFUL CRS
  geom_3d             geometry(PolygonZ, 2056, 3),
  fk_mur_part         INTEGER REFERENCES site.mur_part (mur_part_id)
);

-- Listes

CREATE TABLE listes.pierres (
  pierre_id           SERIAL PRIMARY KEY,
  nom                 VARCHAR
);

INSERT INTO listes.pierres
  (nom)
VALUES
  ('calcaire hautrivien'),
  ('grès coquillier'),
  ('tuff');

CREATE TABLE listes.mortiers (
  mortier_id          SERIAL PRIMARY KEY,
  nom                 VARCHAR
);

INSERT INTO listes.mortiers
  (nom)
VALUES
  ('romain'),
  ('TRA 2012'),
  ('cimenteux');

CREATE TABLE listes.observations (
   observations_id    SERIAL PRIMARY KEY,
   type               VARCHAR,
   specification      VARCHAR
);

INSERT INTO listes.observations
   (type, specification)
VALUES
   ('état','écaillage'),
   ('état','fissure'),
   ('état','joint manquant'),
   ('état','lacune'),
   ('intervention','comblement'),
   ('intervention','démolition'),
   ('intervention','drainage'),
   ('intervention','reconstitution'),
   ('intervention','rejointoyage');


-- Zones

CREATE TYPE site.zone_type AS ENUM (
  'matériel',
  'observation',
  'entité'
);

CREATE TABLE site.zone (
  zone_id              SERIAL PRIMARY KEY,
  date_saisie          DATE,
  type                 site.zone_type,
  surface              INTEGER REFERENCES site.surface(surface_id),
  fk_pierre            INTEGER REFERENCES listes.pierres(pierre_id),
  fk_mortier           INTEGER REFERENCES listes.mortiers(mortier_id),
  fk_observation       INTEGER REFERENCES listes.observations(observations_id),
  geom                 geometry(Polygon, 1)
);
