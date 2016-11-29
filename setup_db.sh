#!/bin/bash

psql "service=pg_avenches" -v ON_ERROR_STOP=1 -f schema.sql
psql "service=pg_avenches" -v ON_ERROR_STOP=1 -f monument.sql
psql "service=pg_avenches" -v ON_ERROR_STOP=1 -f secteur.sql
psql "service=pg_avenches" -v ON_ERROR_STOP=1 -f mur.sql
psql "service=pg_avenches" -v ON_ERROR_STOP=1 -f surface_create.sql
python import_mur_secteur.py
ogr2ogr -f "PostgreSQL" PG:"service=pg_avenches dbname=pilot" -lco "SCHEMA=import" surfaces/surfaces.shp -nln surfaces
