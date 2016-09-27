# Requires a service pg_avenches to be configured on the machine
#
# On linux create a file $HOME/.pg_service.conf with
# the following content:
# 
# [pg_avenches]
# host=46.101.216.29
# port=5432
# dbname=pilot
# user={username}
# password={password}



import psycopg2
import csv

conn = psycopg2.connect("service=pg_avenches")
cur = conn.cursor()

with open('mur_secteur.csv', 'rb') as csvfile:
    mur_secteurs = csv.reader(csvfile, delimiter=',', quotechar='|')

    # Skip header line
    mur_secteurs = list(mur_secteurs)[1:]
    for mur_secteur in mur_secteurs:
        print(mur_secteur)
        cur.execute("""
            INSERT INTO site.mur_secteur (fk_mur, fk_secteur)
            SELECT mur_id, secteur_id
            FROM site.mur
            LEFT JOIN site.secteur ON secteur_nom = %(secteur_nom)s
            WHERE mur_nom = %(mur_nom)s;
        """, {'mur_nom': mur_secteur[0], 'secteur_nom': mur_secteur[1]})

conn.commit()
