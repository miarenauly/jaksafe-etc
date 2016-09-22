# -*- coding: utf-8 -*-
"""
/***************************************************************************
 ContourDelineation
                                 A QGIS plugin
 Plugin to classify your DEM contour data based on each feature on your Shapefile
                             -------------------
        begin                : 2016-09-20
        copyright            : (C) 2016 by Mia Renauly
        email                : miarenauly@hotmail.com
        git sha              : $Format:%H$
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
 This script initializes the plugin, making it known to QGIS.
"""


# noinspection PyPep8Naming
def classFactory(iface):  # pylint: disable=invalid-name
    """Load ContourDelineation class from file ContourDelineation.

    :param iface: A QGIS interface instance.
    :type iface: QgsInterface
    """
    #
    from .ContourDelineation import ContourDelineation
    return ContourDelineation(iface)
