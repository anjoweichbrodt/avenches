## Importieren der Rasterdaten

    # Erzeugen eines Import SQL für eine Datei (mit * können mehrere angegeben werden)
    # -a: in bestehende Tabelle einfügen
    # -t: Tilegrösse
    # -F: Dateinamen in Spalte "filename" schreiben
    # -s: SRID
    # -I: Create a GIST index
    # -Y: User copy statement (schneller)
    #
    # -C: Apply raster constraints (Testen!!!)
    #
    # http://postgis.net/docs/using_raster_dataman.html

    raster2pgsql -F -a -s 1 -t 50x50 -f image -I -Y Mur_11_5/2013/02_0012_11_5__L2013__PN001.tif site.surface > /tmp/raster.sql

    # Erzeugtes SQL ausführen
    psql -h 46.101.216.29 -U qgis -d pilot -f /tmp/raster.sql
