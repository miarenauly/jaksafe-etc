# -*- coding: utf-8 -*-
"""
/***************************************************************************
 ContourDelineation
                                 A QGIS plugin
 Plugin to classify your DEM contour data based on each feature on your Shapefile
                              -------------------
        begin                : 2016-09-20
        git sha              : $Format:%H$
        copyright            : (C) 2016 by Mia Renauly
        email                : miarenauly@hotmail.com
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
"""
from PyQt4.QtCore import QSettings, QTranslator, qVersion, QCoreApplication
from PyQt4.QtGui import QAction, QIcon, QFileDialog
# Initialize Qt resources from file resources.py
import resources
# Import the code for the dialog
from ContourDelineation_dialog import ContourDelineationDialog
import os.path

"""for running script we need to import this libs"""
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


class ContourDelineation:
    """QGIS Plugin Implementation."""
    	
    def select_output_folder(self):
		foldername = QFileDialog.getExistingDirectory(self.dlg, "Select output folder ","",QFileDialog.ShowDirsOnly)
		self.dlg.outputEdit.setText(foldername)

		
    def select_raster_file(self):
	    filename = QFileDialog.getSaveFileName(self.dlg, "Select output folder ","", '')
	    self.dlg.rasterEdit.setText(filename)
	
	
    def __init__(self, iface):
        """Constructor.

        :param iface: An interface instance that will be passed to this class
            which provides the hook by which you can manipulate the QGIS
            application at run time.
        :type iface: QgsInterface
        """
        # Save reference to the QGIS interface
        self.iface = iface
        # initialize plugin directory
        self.plugin_dir = os.path.dirname(__file__)
        # initialize locale
        locale = QSettings().value('locale/userLocale')[0:2]
        locale_path = os.path.join(
            self.plugin_dir,
            'i18n',
            'ContourDelineation_{}.qm'.format(locale))

        if os.path.exists(locale_path):
            self.translator = QTranslator()
            self.translator.load(locale_path)

            if qVersion() > '4.3.3':
                QCoreApplication.installTranslator(self.translator)

        # Create the dialog (after translation) and keep reference
        self.dlg = ContourDelineationDialog()

        # Declare instance attributes
        self.actions = []
        self.menu = self.tr(u'&Contour Delineation')
        # TODO: We are going to let the user set this up in a future iteration
        self.toolbar = self.iface.addToolBar(u'ContourDelineation')
        self.toolbar.setObjectName(u'ContourDelineation')
		
		#connect to self.dlg Raster & Output Folder to select_output_file method
        self.dlg.rasterEdit.clear()
        self.dlg.rasterPush.clicked.connect(self.select_raster_file)
        
        self.dlg.outputEdit.clear()
        self.dlg.outputPush.clicked.connect(self.select_output_folder)
		
				
    # noinspection PyMethodMayBeStatic
    def tr(self, message):
        """Get the translation for a string using Qt translation API.

        We implement this ourselves since we do not inherit QObject.

        :param message: String for translation.
        :type message: str, QString

        :returns: Translated version of message.
        :rtype: QString
        """
        # noinspection PyTypeChecker,PyArgumentList,PyCallByClass
        return QCoreApplication.translate('ContourDelineation', message)


    def add_action(
        self,
        icon_path,
        text,
        callback,
        enabled_flag=True,
        add_to_menu=True,
        add_to_toolbar=True,
        status_tip=None,
        whats_this=None,
        parent=None):
        """Add a toolbar icon to the toolbar.

        :param icon_path: Path to the icon for this action. Can be a resource
            path (e.g. ':/plugins/foo/bar.png') or a normal file system path.
        :type icon_path: str

        :param text: Text that should be shown in menu items for this action.
        :type text: str

        :param callback: Function to be called when the action is triggered.
        :type callback: function

        :param enabled_flag: A flag indicating if the action should be enabled
            by default. Defaults to True.
        :type enabled_flag: bool

        :param add_to_menu: Flag indicating whether the action should also
            be added to the menu. Defaults to True.
        :type add_to_menu: bool

        :param add_to_toolbar: Flag indicating whether the action should also
            be added to the toolbar. Defaults to True.
        :type add_to_toolbar: bool

        :param status_tip: Optional text to show in a popup when mouse pointer
            hovers over the action.
        :type status_tip: str

        :param parent: Parent widget for the new action. Defaults None.
        :type parent: QWidget

        :param whats_this: Optional text to show in the status bar when the
            mouse pointer hovers over the action.

        :returns: The action that was created. Note that the action is also
            added to self.actions list.
        :rtype: QAction
        """

        icon = QIcon(icon_path)
        action = QAction(icon, text, parent)
        action.triggered.connect(callback)
        action.setEnabled(enabled_flag)

        if status_tip is not None:
            action.setStatusTip(status_tip)

        if whats_this is not None:
            action.setWhatsThis(whats_this)

        if add_to_toolbar:
            self.toolbar.addAction(action)

        if add_to_menu:
            self.iface.addPluginToRasterMenu(
                self.menu,
                action)

        self.actions.append(action)

        return action

    def initGui(self):
        """Create the menu entries and toolbar icons inside the QGIS GUI."""

        icon_path = ':/plugins/ContourDelineation/icon.png'
        self.add_action(
            icon_path,
            text=self.tr(u'Contour Delineation'),
            callback=self.run,
            parent=self.iface.mainWindow())


    def unload(self):
        """Removes the plugin menu item and icon from QGIS GUI."""
        for action in self.actions:
            self.iface.removePluginRasterMenu(
                self.tr(u'&Contour Delineation'),
                action)
            self.iface.removeToolBarIcon(action)
        # remove the toolbar
        del self.toolbar


    def run(self):
		"""Run method that performs all the real work"""
		# Shp Combo Method
		self.dlg.shpCombo.clear()
		layers = self.iface.legendInterface().layers()
		layer_list = []
		for layer in layers:
			layerType = layer.type()
			if layerType == QgsMapLayer.VectorLayer:
				layer_list.append(layer.name())
		self.dlg.shpCombo.addItems(layer_list)
		# TAMBAHIN VARIABEL selected = 
		# show the dialog
		self.dlg.show()
        # Run the dialog event loop
		result = self.dlg.exec_()
		# See if OK was pressed
		if result:
			# Do something useful here - delete the line containing pass and
			# substitute with your code.
            
			"""Set the parameter"""
			#Input shapefile
			selectedLayerIndex = self.dlg.shpCombo.currentIndex()
			BOUNDARY_SHP = layers[selectedLayerIndex]
			#Input Raster
			selectedRaster = self.dlg.rasterEdit.text()
			INPUT_RASTER = selectedRaster
			#Output Folder
			selectedFolder = self.dlg.outputEdit.text()
			OUTPUT = selectedFolder
			#Output of feature iteration (spliting feature from one shapefile) and going to be used as masking zone on Raster Masking Process
			MASKING_FOLDER = str(OUTPUT) + ("/POLY RAW/")
			#Path for output of Masking Raster Process
			OUTPUT_MASKING= str(OUTPUT) + ("/MASK/")
			#Path for output of Raster Reclassification Process
			OUTPUT_RECLASS = str(OUTPUT) + ("/RECLASS/")
			#Path for output of Polygonize Raster Process
			OUTPUT_POLYGON = str(OUTPUT) + ("/POLYGON/")
			#Output shapefile hazard (final)
			HAZARD = str(OUTPUT) + ("hazard.shp")
			
			"""Shapefile Feature Iteration"""
			iter = BOUNDARY_SHP.getFeatures()
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
			
			"""Masking Raster"""
			#Finding shapefile for masking the raster
			os.chdir (MASKING_FOLDER)
			def findShp (path, filter):
				for root, dirs, files in os.walk(path, filter):
					for file in fnmatch.filter(files, filter):
						yield os.path.join (root, file)
			#Looping raster masking by calling the command line (GDAL script)
			for shp in findShp (MASKING_FOLDER, "*.shp"):
				(infilepath, infilename)= os.path.split (shp)
				inLayer = MASKING_FOLDER + infilename
				outRaster = OUTPUT_MASKING + infilename[:13] + ".tif"
				cmd= 'gdalwarp -dstnodata 0 -q -cutline "%s" -crop_to_cutline -of GTiff "%s" "%s"' % (inLayer, INPUT_RASTER, outRaster)
				call (cmd)
			
			"""Raster Reclassification"""
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
			
			"""Polygonize Raster"""
			os.chdir (OUTPUT_RECLASS)
			def findRaster (path, filter):
				for root, dirs, files in os.walk(path, filter):
					for file in fnmatch.filter(files, filter):
						yield os.path.join (root, file)
		
			for raster in findRaster (OUTPUT_RECLASS, "*.tif"):
				(infilepath, infilename)= os.path.split (raster)
				#Polygonize the script 
				processing.runalg('gdalogr:polygonize', raster, "KELAS", (OUTPUT_POLYGON + infilename [:13] + ".shp"))
		
			"""Merging Polygon"""
			#making hazard shapefile
			fields = QgsFields()
			fields.append(QgsField("KELAS", QVariant.Int))
			mycrs = QgsCoordinateReferenceSystem(32748)
			shp_writer= QgsVectorFileWriter(HAZARD, "CP1250", fields, QGis.WKBPolygon, mycrs, "ESRI Shapefile")
			del shp_writer
			hazard_shp = self.iface.addVectorLayer(HAZARD, "hazard", "ogr")
		
			#Merging Polygon Hazard
			os.chdir (OUTPUT_POLYGON)
			def findPoly (path, filter):
				for root, dirs, files in os.walk(path, filter):
					for file in fnmatch.filter(files, filter):
						yield os.path.join (root, file)
		
			hazard_shp.startEditing()
			for Poly in findPoly (OUTPUT_POLYGON, "*.shp"):
				(infilepath, infilename)= os.path.split (Poly)
				open_layer = self.iface.addVectorLayer(Poly, infilename, "ogr")
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
