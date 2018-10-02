DROP VIEW tra.surface_create;

CREATE OR REPLACE VIEW tra.surface_create AS 
 SELECT surfaces.name,
    st_makeline(st_pointn(st_exteriorring(surfaces.geom_3d), 1), st_pointn(st_exteriorring(surfaces.geom_3d), 2)) AS baseline,
    st_zmin(surfaces.geom_3d::box3d)::numeric(10,2) AS minimum_level,
    st_zmax(surfaces.geom_3d::box3d)::numeric(10,2) AS maximum_level,
    surfaces.exposition,
    wall_parts.wall::varchar,
    wall_parts.sector::varchar,
    NULL::smallint AS surface_part,
    NULL::varchar AS atlas_name
   FROM tra.surfaces
   LEFT JOIN tra.wall_parts ON wall_parts.name = surfaces.wall_part;

--------------------------------------------
-- INSERT
--------------------------------------------

CREATE OR REPLACE FUNCTION tra.surface_create_insert()
  RETURNS trigger AS
$BODY$
DECLARE
  import_surface RECORD;
  minx numeric(10,2);
  maxx numeric(10,2);
BEGIN
  SELECT
  COALESCE(ST_YMIN(wkb_geometry), NEW.minimum_level) AS minimum_level,
  COALESCE(ST_YMAX(wkb_geometry), NEW.maximum_level) AS maximum_level,
  wkb_geometry	
  INTO import_surface
  FROM import.surfaces
  WHERE nomatlas = NEW.atlas_name;

 
  INSERT INTO tra.surfaces (
           name,
           geom_3d -- create geometry
           , geom_frontal
           , exposition
           , wall_part
           , surface_part
           )
     VALUES (
           CONCAT(
             CONCAT(NEW.sector,'_' ,COALESCE(NEW.wall, split_part(NEW.atlas_name,'-' ,1)))
             , '-', COALESCE(regexp_replace(split_part(split_part(NEW.atlas_name,'-' ,2), '_', 1), 'O', 'W')::tra.exposition, NEW.exposition)
             , '-' || NULLIF(split_part(split_part(NEW.atlas_name, '-', 3), '_', 1), NEW.surface_part)),
           ST_SetSRID(ST_MakePolygon(
             ST_MakeLine(ARRAY[
               ST_MakePoint(ST_X(ST_PointN(NEW.baseline, 1)), ST_Y(ST_PointN(NEW.baseline, 1)), COALESCE(import_surface.minimum_level, NEW.minimum_level)),
               ST_MakePoint(ST_X(ST_PointN(NEW.baseline, 2)), ST_Y(ST_PointN(NEW.baseline, 2)), COALESCE(import_surface.minimum_level, NEW.minimum_level)),
               ST_MakePoint(ST_X(ST_PointN(NEW.baseline, 2)), ST_Y(ST_PointN(NEW.baseline, 2)), COALESCE(import_surface.maximum_level, NEW.maximum_level)),
               ST_MakePoint(ST_X(ST_PointN(NEW.baseline, 1)), ST_Y(ST_PointN(NEW.baseline, 1)), COALESCE(import_surface.maximum_level, NEW.maximum_level)),
               ST_MakePoint(ST_X(ST_PointN(NEW.baseline, 1)), ST_Y(ST_PointN(NEW.baseline, 1)), COALESCE(import_surface.minimum_level, NEW.minimum_level))
             ])
           ), 2056)
           , ST_SetSRID(import_surface.wkb_geometry, 1)
           , COALESCE(regexp_replace(split_part(split_part(NEW.atlas_name,'-' ,2), '_', 1), 'O', 'W')::tra.exposition, NEW.exposition)
           , CONCAT(NEW.sector,'_' ,COALESCE(NEW.wall, split_part(NEW.atlas_name,'-' ,1)))
           , COALESCE(NULLIF(split_part(split_part(NEW.atlas_name, '-', 3), '_', 1), '')::smallint, NEW.surface_part)
           )
           RETURNING name INTO NEW.name;
     RETURN NEW;
END; $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION tra.surface_create_insert()
  OWNER TO qgis;

CREATE TRIGGER surface_create_on_insert
  INSTEAD OF INSERT
  ON tra.surface_create
  FOR EACH ROW
  EXECUTE PROCEDURE tra.surface_create_insert();

--------------------------------------------
-- UPDATE
--------------------------------------------

CREATE OR REPLACE FUNCTION tra.surface_create_update()
  RETURNS trigger AS
$BODY$
DECLARE
  import_surface RECORD;
  minx numeric(10,2);
  maxx numeric(10,2);
BEGIN
  SELECT
  COALESCE(ST_YMIN(wkb_geometry), NEW.minimum_level) AS minimum_level,
  COALESCE(ST_YMAX(wkb_geometry), NEW.maximum_level) AS maximum_level,
  wkb_geometry
  INTO import_surface
  FROM import.surfaces
  WHERE nomatlas = NEW.atlas_name;

 
  UPDATE tra.surfaces 
     SET geom_3d =ST_SetSRID(ST_MakePolygon(
             ST_MakeLine(ARRAY[
               ST_MakePoint(ST_X(ST_PointN(NEW.baseline, 1)), ST_Y(ST_PointN(NEW.baseline, 1)), COALESCE(import_surface.minimum_level, NEW.minimum_level)),
               ST_MakePoint(ST_X(ST_PointN(NEW.baseline, 2)), ST_Y(ST_PointN(NEW.baseline, 2)), COALESCE(import_surface.minimum_level, NEW.minimum_level)),
               ST_MakePoint(ST_X(ST_PointN(NEW.baseline, 2)), ST_Y(ST_PointN(NEW.baseline, 2)), COALESCE(import_surface.maximum_level, NEW.maximum_level)),
               ST_MakePoint(ST_X(ST_PointN(NEW.baseline, 1)), ST_Y(ST_PointN(NEW.baseline, 1)), COALESCE(import_surface.maximum_level, NEW.maximum_level)),
               ST_MakePoint(ST_X(ST_PointN(NEW.baseline, 1)), ST_Y(ST_PointN(NEW.baseline, 1)), COALESCE(import_surface.minimum_level, NEW.minimum_level))
             ])
           ), 2056),
         geom_frontal = ST_SetSRID(import_surface.wkb_geometry, 1),
         exposition = COALESCE(regexp_replace(split_part(split_part(NEW.atlas_name,'-' ,2), '_', 1), 'O', 'W')::tra.exposition, NEW.exposition),
         wall_part = CONCAT(NEW.sector,'_' ,COALESCE(NEW.wall, split_part(NEW.atlas_name,'-' ,1))),
         surface_part = COALESCE(NULLIF(split_part(split_part(NEW.atlas_name, '-', 3), '_', 1), '')::smallint, NEW.surface_part)
     WHERE name = OLD.name;
END; $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION tra.surface_create_update()
  OWNER TO qgis;


CREATE TRIGGER surface_create_on_update
  INSTEAD OF UPDATE
  ON tra.surface_create
  FOR EACH ROW
  EXECUTE PROCEDURE tra.surface_create_update();
