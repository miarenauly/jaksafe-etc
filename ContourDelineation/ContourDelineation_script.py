# Before running this script, open vector layer that going to be iterated (boundary.shp)

# Importing QGIS Module for FEATURE ITERATION
from PyQt4.QtCore import *
# Importing GDAL Module for MASKING RASTER
import os, fnmatch
from subprocess import call
from osgeo import gdal
call(["ls", "-l"])
# Importing QGIS Module for RASTER RECLASSIFICATION
from PyQt4.QtGui import *
from qgis.core import *
# Importing QGIS Module for POLYGONIZE RASTER
import processing

#Set the parameter (OUTPUT PATH)
#Input shapefile (RW Boundary)
BOUNDARY_SHP = "E:/01 JakSAFE/09 PEMODELAN RW BANJIR QGIS/TES/boundary.shp"
#Output of feature iteration (spliting feature from one shapefile) and going to be used as masking zone on Raster Masking Process
MASKING_FOLDER = "E:/01 JakSAFE/09 PEMODELAN RW BANJIR QGIS/POLY RW/"
#Input shapefile (River Polygon)
RIVER_DKI = "E:/01 JakSAFE/09 PEMODELAN RW BANJIR QGIS/riverdki_polygon.shp"
#Raster DEM data input path
INPUT_RASTER = "E:/01 JakSAFE/09 PEMODELAN RW BANJIR QGIS/RASTER/jkt_erase.tif"
#Path for output of Masking Raster Process
OUTPUT_MASKING= "E:/01 JakSAFE/09 PEMODELAN RW BANJIR QGIS/MASK/"
#Path for output of Raster Reclassification Process
OUTPUT_RECLASS = "E:/01 JakSAFE/09 PEMODELAN RW BANJIR QGIS/RECLASS/"
#Path for output of Polygonize Raster Process
OUTPUT_POLYGON = "E:/01 JakSAFE/09 PEMODELAN RW BANJIR QGIS/POLYGON/"
#Output shapefile hazard (final)
HAZARD = "E:/01 JakSAFE/09 PEMODELAN RW BANJIR QGIS/hazard.shp"


########################################### FEATURE ITERATION ###################################################


layer = iface.addVectorLayer(BOUNDARY_SHP, "boundary", "ogr")
iter = layer.getFeatures()

# Looping the feature, and save it into new shapefile
for feature in iter:
    geom = feature.geometry()
    # Making shapefile (defining shapefile field name and field type one by one, the field name and type is made according to boundary.shp
    namafield = MASKING_FOLDER + '%s.shp' % feature ['id_rw']
    fields = QgsFields()
    fields.append(QgsField("id", QVariant.Int))
    fields.append(QgsField("objectid", QVariant.Int))
    fields.append(QgsField("area", QVariant.Double))
    fields.append(QgsField("rw", QVariant.String))
    fields.append(QgsField("id_kel", QVariant.String))
    fields.append(QgsField("id_rw", QVariant.String))
    fields.append(QgsField("kelurahan", QVariant.String))
    fields.append(QgsField("kecamatan", QVariant.String))
    fields.append(QgsField("kota", QVariant.String))
    writer = QgsVectorFileWriter(namafield, "CP1250", fields, QGis.WKBPolygon, layer.crs(), "ESRI Shapefile")
    #add feature from iteration to shapefile
    writer.addFeature(feature)

del writer

########################################### MASKING RASTER ###################################################

#Finding shapefile for masking the raster
os.chdir (MASKING_FOLDER)
def findShp (path, filter):
    for root, dirs, files in os.walk(path, filter):
        for file in fnmatch.filter(files, filter):
            yield os.path.join (root, file)

#Looping raster masking by calling the command line (GDAL script)
for shp in findShp (MASKING_FOLDER, "*.shp"):
    (infilepath, infilename)= os.path.split (shp)
    inLayer = MASKING_FOLDER + "/" + infilename
    outRaster = OUTPUT_MASKING + infilename[:13] + ".tif"
    cmd= 'gdalwarp -dstnodata 0 -q -cutline "%s" -crop_to_cutline -of GTiff "%s" "%s"' % (inLayer, INPUT_RASTER, outRaster)
    call (cmd)

########################################### RASTER RECLASSIFICATION ###################################################

#Looping raster masking by calling the masked raster path
os.chdir (OUTPUT_MASKING)
def findLayer (path, filter):
    for root, dirs, files in os.walk(path, filter):
        for file in fnmatch.filter(files, filter):
            yield os.path.join (root, file)

# Looping raster
for layer in findLayer (OUTPUT_MASKING, "*.tif"):
    (infilepath, infilename)= os.path.split (layer)
    
    #Get minimimum and maximum raster value
    gdalData = gdal.Open(layer)
    bands = gdalData.RasterCount
    band = gdalData.GetRasterBand(1)
    min = band.GetMinimum()
    max = band.GetMaximum()
    if min is None or max is None:
        (min,max) = band.ComputeRasterMinMax(1)
    
    #Get standard deviation raster value
    fileInfo = QFileInfo(layer)
    rLabel = fileInfo.baseName()
    rLayer = QgsRasterLayer(layer,rLabel)
    QgsMapLayerRegistry.instance().addMapLayer(rLayer)
    entries = []
    renderer = rLayer.renderer()
    provider = rLayer.dataProvider()
    extent = rLayer.extent()
    stats = provider.bandStatistics(1, QgsRasterBandStats.All,extent, 0)
    StdDev = stats.stdDev
    
    #Raster Classification
    driver = gdal.GetDriverByName("GTiff")
    lista = band.ReadAsArray()

    #Reclassification Rule for steep slope
    if (max - min) <= 5:
        for j in  range(gdalData.RasterXSize):
            for i in  range(gdalData.RasterYSize):
                #excepting value 0 (NoData) in data classification
                if lista[i,j] == 0:
                     lista[i,j] = 4
                elif (min) <= lista[i,j] < (min+0.7):
                    lista[i,j] = 1
                elif (min+0.7) <= lista[i,j] < (min+1.5):
                    lista[i,j] = 2
                elif (min+1.5) <= lista[i,j] <= (min+2.5):
                    lista[i,j] = 3
                else:
                    lista[i,j] = 4
    #Reclassification Rule for lower slope
    else:
        for j in  range(gdalData.RasterXSize):
            for i in  range(gdalData.RasterYSize):
                #excepting value 0 (NoData) in data classification
                if lista[i,j] == 0:
                    lista[i,j] = 4
                elif (min) <= lista[i,j] < (min+StdDev+0.7):
                    lista[i,j] = 1
                elif (min+StdDev+0.7) <= lista[i,j] < (min+StdDev+1.5):
                    lista[i,j] = 2
                elif (min+StdDev+1.5) <= lista[i,j] <= (min+StdDev+2.5):
                    lista[i,j] = 3
                else:
                    lista[i,j] = 4
    
    # create new file
    file2 = driver.Create(OUTPUT_RECLASS + infilename, gdalData.RasterXSize , gdalData.RasterYSize , 1)
    file2.GetRasterBand(1).WriteArray(lista)
    # spatial ref system of the new file
    proj = gdalData.GetProjection()
    georef = gdalData.GetGeoTransform()
    file2.SetProjection(proj)
    file2.SetGeoTransform(georef)
    file2.FlushCache()

########################################### POLYGONIZE RASTER ###################################################

#Looping raster masking by calling the reclassified raster path
os.chdir (OUTPUT_RECLASS)
def findRaster (path, filter):
    for root, dirs, files in os.walk(path, filter):
        for file in fnmatch.filter(files, filter):
            yield os.path.join (root, file)

for raster in findRaster (OUTPUT_RECLASS, "*.tif"):
    (infilepath, infilename)= os.path.split (raster)
    #Polygonize the script 
    processing.runalg('gdalogr:polygonize', raster, "KELAS", (OUTPUT_POLYGON + infilename [:13] + ".shp"))
    
    
##########################################MERGING POLYGON########################################################

#making hazard shapefile
fields = QgsFields()
fields.append(QgsField("KELAS", QVariant.Int))
mycrs = QgsCoordinateReferenceSystem(32748)
shp_writer= QgsVectorFileWriter(HAZARD, "CP1250", fields, QGis.WKBPolygon, mycrs, "ESRI Shapefile")
del shp_writer
hazard_shp = iface.addVectorLayer(HAZARD, "hazard", "ogr")

#Merging Polygon Hazard
os.chdir (OUTPUT_POLYGON)
def findPoly (path, filter):
    for root, dirs, files in os.walk(path, filter):
        for file in fnmatch.filter(files, filter):
            yield os.path.join (root, file)

hazard_shp.startEditing()
for Poly in findPoly (OUTPUT_POLYGON, "*.shp"):
    (infilepath, infilename)= os.path.split (Poly)
    open_layer = iface.addVectorLayer(Poly, infilename, "ogr")
    hfeatures = open_layer.getFeatures()
    for hfeat in hfeatures:
        hazard_shp.addFeatures([hfeat])
hazard_shp.commitChanges()

#Delete polygon NULL
hrequest = QgsFeatureRequest().setFilterExpression(u'"KELAS"=4')
hids = [f.id() for f in hazard_shp.getFeatures(hrequest)]
hazard_shp.startEditing()
for hfid in hids:
    hazard_shp.deleteFeature( hfid )
hazard_shp.commitChanges()