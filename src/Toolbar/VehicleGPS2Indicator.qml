/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

//-------------------------------------------------------------------------
//-- GPS2 Indicator (MAVLINK_MSG_ID_GPS2_RAW)
Item {
    id:             control
    width:          gps2IndicatorRow.width
    anchors.top:    parent.top
    anchors.bottom: parent.bottom

    property bool   showIndicator:  _activeVehicle ? _activeVehicle.gps2.telemetryAvailable : false

    property var    _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    QGCPalette { id: qgcPal }

    Row {
        id:             gps2IndicatorRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        spacing:        ScreenTools.defaultFontPixelWidth / 2

        Item {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            width:          gps2Icon.width

            QGCColoredImage {
                id:                 gps2Icon
                width:              height
                anchors.top:        parent.top
                anchors.bottom:     parent.bottom
                source:             "/qmlimages/Gps.svg"
                fillMode:           Image.PreserveAspectFit
                sourceSize.height:  height
                opacity:            (_activeVehicle && _activeVehicle.gps2.count.value >= 0) ? 1 : 0.5
                color:              qgcPal.text
            }

            QGCLabel {
                text:               qsTr("2")
                font.pointSize:     ScreenTools.smallFontPointSize
                color:              qgcPal.colorBlue
                anchors.right:      parent.right
                anchors.bottom:     parent.bottom
                anchors.bottomMargin: -ScreenTools.defaultFontPixelHeight * 0.1
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            visible:                _activeVehicle && !isNaN(_activeVehicle.gps2.hdop.value)
            spacing:                0

            QGCLabel {
                anchors.horizontalCenter:   hdop2Value.horizontalCenter
                color:                      qgcPal.text
                text:                       _activeVehicle ? _activeVehicle.gps2.count.valueString : ""
            }

            QGCLabel {
                id:                 hdop2Value
                color:              qgcPal.text
                text:               _activeVehicle ? _activeVehicle.gps2.hdop.value.toFixed(1) : ""
            }
        }
    }

    MouseArea {
        anchors.fill:   parent
        onClicked:      mainWindow.showIndicatorDrawer(gps2IndicatorPage, control)
    }

    Component {
        id: gps2IndicatorPage

        GPS2IndicatorPage { }
    }
}
