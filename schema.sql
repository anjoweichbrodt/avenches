CREATE SCHEMA IF NOT EXISTS listes;
CREATE SCHEMA IF NOT EXISTS site;
CREATE SCHEMA IF NOT EXISTS import;

CREATE EXTENSION IF NOT EXISTS postgis;

DROP TABLE IF EXISTS site.monument CASCADE;
DROP TABLE IF EXISTS site.secteur CASCADE;
DROP TABLE IF EXISTS site.mur CASCADE;
DROP TABLE IF EXISTS site.surface CASCADE;
DROP TABLE IF EXISTS site.deteriotation_zone CASCADE;
DROP TABLE IF EXISTS site.intervention_zone CASCADE;
DROP TABLE IF EXISTS site.materiel_zone CASCADE;
DROP TABLE IF EXISTS site.entite_zone CASCADE;
DROP TABLE IF EXISTS site.dating_zone CASCADE;
DROP TABLE IF EXISTS listes.deteriotation CASCADE;
DROP TABLE IF EXISTS listes.intervention CASCADE;
DROP TABLE IF EXISTS listes.pierre CASCADE;
DROP TABLE IF EXISTS listes.mortier CASCADE;
DROP TABLE IF EXISTS listes.entite CASCADE;
DROP TABLE IF EXISTS listes.dating_zone CASCADE;
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
LEFT JOIN site.mur ON mur.mur_id = mur_part.fk_mur_id
LEFT JOIN site.secteur ON secteur.secteur_id = mur_part.fk_secteur_id
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
  geom_3d             geometry(PolygonZ, 2056, 3),
  fk_mur_part         INTEGER REFERENCES site.mur_part (mur_part_id)
);


-- Listes


-- deteriotation

CREATE TABLE listes.deteriotation (
   deteriotation_id  SERIAL PRIMARY KEY,
   type              VARCHAR,
   specification     VARCHAR,
);

INSERT INTO listes.deteriotation
   (type, specification)
VALUES
   ('écaillage',NULL),
   ('fissure',NULL),
   ('joint manquant',NULL),
   ('lacune',NULL);


-- intervention

CREATE TABLE listes.intervention (
   intervention_id   SERIAL PRIMARY KEY,
   type              VARCHAR,
   specification     VARCHAR,
);

INSERT INTO listes.intervention
   (type, specification)
VALUES
   ('comblement',NULL),
   ('démolition',NULL),
   ('drainage',NULL),
   ('reconstitution',NULL),
   ('rejointoyage',NULL);


-- pierre

CREATE TABLE listes.pierre (
   pierre_id         SERIAL PRIMARY KEY,
   type              VARCHAR,
   specification     VARCHAR,
);

INSERT INTO listes.pierre
   (type, specification)
VALUES
   ('calcaire','calcaire hautrivien'),
   ('molasse','grès coquillier'),
   ('calcaire','tuff');


-- mortier

CREATE TABLE listes.mortier (
   mortier_id        SERIAL PRIMARY KEY,
   type              VARCHAR,
   specification     VARCHAR,
);

INSERT INTO listes.mortier
   (type, specification)
VALUES
   ('chaux','romain'),
   ('cimenteux','TRA 2012'),
   ('chaux','TRA 2015');


-- entite

CREATE TABLE listes.entite (
   entite_id         SERIAL PRIMARY KEY,
   type              VARCHAR,
   );

INSERT INTO listes.entite
   (type)
VALUES
   ('maçonnerie'),
   ('chappe');


-- dating

CREATE TABLE listes.dating (
   dating_id         SERIAL PRIMARY KEY,
   type              VARCHAR,
   );

INSERT INTO listes.dating
   (type)
VALUES
   ('romain'),
   ('1910-1920'),
   ('2012'),
   ('2012'),
   ('2013'),
   ('2014'),
   ('2015');

-- Zones


CREATE TABLE site.deteriotation_zone (
  zone_id              SERIAL PRIMARY KEY,
  date_observation     DATE,
  surface              INTEGER REFERENCES site.surface(surface_id),
  fk_observation       INTEGER REFERENCES listes.deteriotation(deteriotation_id),
  geom                 geometry(Polygon, 1)
);


CREATE TABLE site.intervention_zone (
  zone_id              SERIAL PRIMARY KEY,
  date_observation     DATE,
  surface              INTEGER REFERENCES site.surface(surface_id),
  fk_observation       INTEGER REFERENCES listes.intervention(intervention_id),
  geom                 geometry(Polygon, 1)
);


CREATE TABLE site.materiel_zone (
  zone_id              SERIAL PRIMARY KEY,
  date_observation     DATE,
  surface              INTEGER REFERENCES site.surface(surface_id),
  fk_pierre            INTEGER REFERENCES listes.pierre(pierre_id),
  fk_mortier           INTEGER REFERENCES listes.mortier(mortier_id),
  geom                 geometry(Polygon, 1)
);


CREATE TABLE site.entite_zone (
  zone_id              SERIAL PRIMARY KEY,
  date_observation     DATE,
  surface              INTEGER REFERENCES site.surface(surface_id),
  fk_observation       INTEGER REFERENCES listes.entite(entite_id),
  geom                 geometry(Polygon, 1)
);


CREATE TABLE site.dating_zone (
  zone_id              SERIAL PRIMARY KEY,
  date_observation     DATE,
  surface              INTEGER REFERENCES site.surface(surface_id),
  fk_observation       INTEGER REFERENCES listes.dating(dating_id),
  geom                 geometry(Polygon, 1)
);
