import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

// Used as the base class control for nboth VehicleGPSIndicator and RTKGPSIndicator

Item {
    id:             control
    width:          gpsIndicatorRow.width
    anchors.top:    parent.top
    anchors.bottom: parent.bottom

    property var    _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property bool   _rtkConnected:  QGroundControl.gpsRtk.connected.value

    QGCPalette { id: qgcPal }

    Column {
        id:                     gpsIndicatorRow
        anchors.verticalCenter: parent.verticalCenter
        spacing:                1

        QGCLabel {
            text:               _rtkConnected ? qsTr("RTK GPS:") : qsTr("GPS:")
            color:              Qt.rgba(1, 1, 1, 0.6)
            font.pointSize:     ScreenTools.smallFontPointSize
        }

        QGCLabel {
            text:               _activeVehicle ? (_activeVehicle.gps.count.value >= 0 ? _activeVehicle.gps.count.valueString + " " + qsTr("Sats") : qsTr("No GPS")) : qsTr("No GPS")
            color:              "#ffffff"
            font.pointSize:     ScreenTools.defaultFontPointSize
            font.bold:          true
        }
    }

    MouseArea {
        anchors.fill:   parent
        onClicked:      mainWindow.showIndicatorDrawer(gpsIndicatorPage, control)
    }

    Component {
        id: gpsIndicatorPage

        GPSIndicatorPage { }
    }
}
