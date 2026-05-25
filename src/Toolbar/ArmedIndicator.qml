import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

//-------------------------------------------------------------------------
//-- Armed Indicator
QGCComboBox {
    anchors.verticalCenter: parent.verticalCenter
    alternateText:          _armed ? qsTr("ARMED") : qsTr("DISARMED")
    model:                  [ qsTr("Arm"), qsTr("Disarm") ]
    currentIndex:           -1
    sizeToContents:         true

    property bool showIndicator: true

    property var    _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property bool   _armed:         _activeVehicle ? _activeVehicle.armed : false

    // Custom 2-line content matching Mockup UI
    contentItem: Column {
        anchors.verticalCenter: parent.verticalCenter
        spacing:                1
        
        QGCLabel {
            text:               qsTr("Arm Status:")
            color:              qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0, 0, 0, 0.5) : Qt.rgba(255, 255, 255, 0.6)
            font.pointSize:     ScreenTools.smallFontPointSize
        }
        
        QGCLabel {
            text:               _armed ? qsTr("ARMED") : qsTr("DISARMED")
            color:              _armed ? qgcPal.colorRed : qgcPal.text
            font.pointSize:     ScreenTools.defaultFontPointSize
            font.bold:          true
        }
    }

    // Hide background border/color
    background: Rectangle {
        color:                  "transparent"
        border.width:           0
    }

    // Hide dropdown arrow
    indicator: Item {}

    onActivated: (index) => {
        if (index == 0) {
            mainWindow.armVehicleRequest()
        } else {
            mainWindow.disarmVehicleRequest()
        }
        currentIndex = -1
    }
}
