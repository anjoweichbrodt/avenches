# This startup script is designed to work with the Quick Attribution plugin
# 
#     https://github.com/opengisch/quick_attribution/
#
# If an attribute with the name 'surface' is changed on any layer via the quick
# attribution plugin, the layer will zoom to the respective feature on the layer
# "surfaces frontal"

import qgis
from qgis.core import QgsProject

iface = qgis.utils.iface

def openProject():
    def zoomTo(name):
        project = QgsProject.instance()
        layer = QgsProject.instance().mapLayersByName('surfaces frontal')[0]
        filter_expression = 'name = \'{name}\''.format(name=name)
        feature = next(layer.getFeatures(filter_expression))
        box = feature.geometry().boundingBox()
        box = box.buffered(box.width()/10)
        QgsExpressionContextUtils.setProjectVariable(project,'pseudo_atlas_feature',name)
        iface.mapCanvas().setExtent(box)
        iface.mapCanvas().refresh()

    def onCurrentValueChanged(field, value):
        if field == 'surface':
            zoomTo(value)

    currentValueConnection = qgis.utils.plugins['quick_attribution'].dockWidget.currentValueChanged.connect(onCurrentValueChanged)
    qgis.utils.plugins['quick_attribution'].__currentValueConnection = currentValueConnection


def saveProject():
    pass

def closeProject():
    currentValueConnection = qgis.utils.plugins['quick_attribution'].__currentValueConnection
    if currentValueConnection:
        qgis.utils.plugins['quick_attribution'].dockWidget.currentValueChanged.disconnect(currentValueConnection)

