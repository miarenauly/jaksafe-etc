from PyQt4.QtCore import *
import processing

#Set the parameter (OUTPUT PATH)
#Path for output of Polygonize Raster Process
HAZARD = "E:/01 JakSAFE/09 PEMODELAN RW BANJIR QGIS/TES/hazard.shp"
BOUNDARY_SHP = "E:/01 JakSAFE/09 PEMODELAN RW BANJIR QGIS/boundary.shp"
RIVER_DKI = "E:/01 JakSAFE/09 PEMODELAN RW BANJIR QGIS/riverdki_polygon.shp"
HAZARD_RIVER = "E:/01 JakSAFE/09 PEMODELAN RW BANJIR QGIS/TES/hazard_river.shp"
HAZARD_FINAL = "E:/01 JakSAFE/09 PEMODELAN RW BANJIR QGIS/TES/hazard_final.shp"

#Union River shapefile with hazard
processing.runalg("saga:union", HAZARD, RIVER_DKI, True, HAZARD_RIVER)


#Rename attribute for River polygon
open_sungai = iface.addVectorLayer(HAZARD_RIVER, "sungai", "ogr")
srequest = QgsFeatureRequest().setFilterExpression(u'"KELAS" = 0')
sids = [f.id() for f in open_sungai.getFeatures(srequest)]
open_sungai.startEditing()
for sfid in sids:
    attrs = { 0 : 3 } #change polygon sungai jadi kelas 3
    open_sungai.dataProvider().changeAttributeValues({ sfid : attrs })
open_sungai.commitChanges()


#Union River, Hazard, and Boundar data
processing.runalg("saga:union",HAZARD_RIVER, BOUNDARY_SHP,True,HAZARD_FINAL)