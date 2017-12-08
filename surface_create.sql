DROP VIEW IF EXISTS site.surface_create;
CREATE VIEW site.surface_create AS
SELECT
surface_id,
ST_MakeLine(ST_PointN(ST_ExteriorRing(geom_3d), 1), ST_PointN(ST_ExteriorRing(geom_3d), 2))::Geometry AS baseline,
ST_ZMin(geom_3d) AS minimum_level,
ST_ZMax(geom_3d)  AS maximum_level,
exposition::site.expo,
fk_mur,
fk_secteur,
NULL::text AS nomatlas
FROM site.surface
LEFT JOIN site.mur_part ON mur_part.mur_part_id = fk_mur_part;

CREATE OR REPLACE FUNCTION site.surface_create_insert()
  RETURNS trigger AS
$BODY$
DECLARE
  import_surface RECORD;
  minx INT;
  maxx INT;
BEGIN
  SELECT
  COALESCE(ST_YMIN(wkb_geometry), NEW.minimum_level) AS minimum_level,
  COALESCE(ST_YMAX(wkb_geometry), NEW.maximum_level) AS maximum_level,
  wkb_geometry
  INTO import_surface
  FROM import.surfaces
  WHERE nomatlas = NEW.nomatlas;

 
  INSERT INTO site.surface (
           geom_3d -- create geometry
           , geom_frontal
           , exposition
           , fk_mur_part
           )
     VALUES (
           ST_SetSRID(ST_MakePolygon(
             ST_MakeLine(ARRAY[
               ST_MakePoint(ST_X(ST_PointN(NEW.baseline, 1)), ST_Y(ST_PointN(NEW.baseline, 1)), import_surface.minimum_level),
               ST_MakePoint(ST_X(ST_PointN(NEW.baseline, 2)), ST_Y(ST_PointN(NEW.baseline, 2)), import_surface.minimum_level),
               ST_MakePoint(ST_X(ST_PointN(NEW.baseline, 2)), ST_Y(ST_PointN(NEW.baseline, 2)), import_surface.maximum_level),
               ST_MakePoint(ST_X(ST_PointN(NEW.baseline, 1)), ST_Y(ST_PointN(NEW.baseline, 1)), import_surface.maximum_level),
               ST_MakePoint(ST_X(ST_PointN(NEW.baseline, 1)), ST_Y(ST_PointN(NEW.baseline, 1)), import_surface.minimum_level)
             ])
           ), 2056)
           , ST_SetSRID(import_surface.wkb_geometry, 1)
           , NEW.exposition
           , (SELECT mur_part_id FROM site.mur_part WHERE fk_mur = NEW.fk_mur AND fk_secteur = NEW.fk_secteur)
           )
           RETURNING surface_id INTO NEW.surface_id;
     RETURN NEW;
END; $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- DROP TRIGGER vw_access_aid_ON_INSERT ON qgep.access_aid;

CREATE TRIGGER surface_create_ON_INSERT INSTEAD OF INSERT ON site.surface_create
  FOR EACH ROW EXECUTE PROCEDURE site.surface_create_insert();
