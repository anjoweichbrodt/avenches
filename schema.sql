CREATE SCHEMA IF NOT EXISTS listes;
CREATE SCHEMA IF NOT EXISTS site;

CREATE EXTENSION IF NOT EXISTS postgis;

DROP TABLE IF EXISTS site.monument CASCADE;
DROP TABLE IF EXISTS site.mur_secteur CASCADE;
DROP TABLE IF EXISTS site.secteur CASCADE;
DROP TABLE IF EXISTS site.mur CASCADE;
DROP TABLE IF EXISTS site.surface CASCADE;
DROP TABLE IF EXISTS site.materiel_zone CASCADE;
DROP TABLE IF EXISTS listes.pierres CASCADE;
DROP TABLE IF EXISTS listes.mortiers CASCADE;
DROP TYPE IF EXISTS site.expo;

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
  mur_nom             VARCHAR(4),
  visible             boolean
);

CREATE TABLE site.mur_secteur (
  fk_mur              INTEGER REFERENCES site.mur (mur_id),
  fk_secteur          INTEGER REFERENCES site.secteur (secteur_id),
  PRIMARY KEY(fk_mur, fk_secteur)
);

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
  geom_3d             geometry(Polygon, 2056, 3),
  fk_mur              INTEGER REFERENCES site.mur (mur_id),
  fk_secteur          INTEGER REFERENCES site.secteur (secteur_id)
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
  mortier_id           SERIAL PRIMARY KEY,
  nom                 VARCHAR
);

INSERT INTO listes.mortiers
  (nom)
VALUES
  ('romain'),
  ('TRA 2012'),
  ('cimenteux');

CREATE TABLE listes.observation ( 
  observation_id           SERIAL PRIMARY KEY,
  nom                 VARCHAR
);

INSERT INTO listes.observation
  (nom)
VALUES
  ('état'),
  ('intervention');
  
 CREATE TABLE listes.designation ( 
  designation_id           SERIAL PRIMARY KEY,
  nom                 VARCHAR
);

INSERT INTO listes.designation.etat
  (nom)
VALUES
  ('écaillage'),
  ('fissure'),
  ('joint manquant'),
  ('lacune');
  
INSERT INTO listes.designation.intervention
  (nom)
VALUES
  ('comblement'),
  ('démolition'),
  ('drainage'),
  ('reconstitution'),
  ('rejointoyage');
  

-- Materiel

CREATE TABLE site.materiel_zone ( 
  materiel_zone_id     SERIAL PRIMARY KEY,
  date_saisie          DATE,
  surface              INTEGER REFERENCES site.surface(surface_id),
  pierre               INTEGER REFERENCES listes.pierres(pierre_id),
  mortier              INTEGER REFERENCES listes.mortiers(mortier_id),
  geom                 geometry(Polygon, 1)
);
