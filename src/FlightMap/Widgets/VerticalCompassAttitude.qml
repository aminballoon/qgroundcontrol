import QtQuick

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlightMap

Rectangle {
    width:  ScreenTools.defaultFontPixelHeight * 10
    height: _outerRadius * 4
    radius: _outerRadius
    color:  Qt.rgba(0.09, 0.11, 0.16, 0.85)
    border.width: 1
    border.color: Qt.rgba(1, 1, 1, 0.15)

    property real extraInset:           0
    property real extraValuesWidth:     _outerRadius

    property real _outerMargin: (width * 0.05) / 2
    property real _outerRadius: width / 2
    property real _innerRadius: _outerRadius - _outerMargin

    // Prevent all clicks from going through to lower layers
    DeadMouseArea {
        anchors.fill: parent
    }

    QGCAttitudeWidget {
        id:                         attitude
        anchors.horizontalCenter:   parent.horizontalCenter
        anchors.topMargin:          _outerMargin
        anchors.top:                parent.top
        size:                       _innerRadius * 2
        vehicle:                    globals.activeVehicle
    }

    QGCCompassWidget {
        id:                         compass
        anchors.horizontalCenter:   parent.horizontalCenter
        anchors.topMargin:          _outerMargin * 2
        anchors.top:                attitude.bottom
        size:                       _innerRadius * 2
        vehicle:                    globals.activeVehicle
    }
}
