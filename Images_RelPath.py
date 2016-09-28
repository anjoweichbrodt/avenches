import os
import re

Images_RelPath_File = open('Images_RelPath.txt','w')

Images_RelPath_File.write('Image_Nom,Photo_CheminAccès,Mur_Nom-2016,Photo_Date-Prise' '\n')

for dirpath, subdirs, files in os.walk(os.getcwd()) :
    
    for line in files :
        if line.endswith(('.jpg', '.jpeg','.tif', '.tiff')) :
     
            ImagePath = os.path.join(dirpath, line)

            PosOrthImg = ImagePath.find('\OrthoImages')
            Images_RelPath = ImagePath[PosOrthImg : ]

            Year = line[:4]
             
            Surface_Nom = re.search('^(?:[0-9]{4})_(?:[A-Z]{3,4})_(?:[a-z]{2,3}[0-9]{1,2})_(M[0-9]{1,3}-[A-Z]{1,2}-?[0-9]?-?[0-9]?)_(?:[a-zA-Z]{3,5}-[a-zA-Z]{4,12})_(?:[a-zA-Z]{2,3}).(?:jpg?|tif)$', line)
            
            if Surface_Nom :
                Surface_Nom = Surface_Nom.group(1)
                Images_RelPath_File.write(line + ',' + Images_RelPath + ',' + str(Surface_Nom) + ',' + Year + '\n')
            else :
                print 'Le type du fichier', line, 'ou sa nomenclature ne correspond pas au standard accepté' 

Images_RelPath_File.close()

