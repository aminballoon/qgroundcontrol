import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

//-------------------------------------------------------------------------
//-- RC RSSI Indicator
Item {
    id:             control
    width:          rssiColumn.width

    property bool showIndicator: _activeVehicle.supports.radio && _rcRSSIAvailable

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property bool   _rcRSSIAvailable:   _activeVehicle.rcRSSI.rawValue > 0 && _activeVehicle.rcRSSI.rawValue <= 100

    Component {
        id: rcRSSIInfoPage

        ToolIndicatorPage {
            showExpand: false

            contentComponent: SettingsGroupLayout {
                heading: qsTr("RC RSSI Status")

                LabelledLabel {
                    label:      qsTr("RSSI")
                    labelText:  _activeVehicle.rcRSSI.rawValue + "%"
                }
            }
        }
    }

    Column {
        id:                     rssiColumn
        anchors.verticalCenter: parent.verticalCenter
        spacing:                1
        
        QGCColoredImage {
            id:                 rcIcon
            width:              ScreenTools.defaultFontPixelWidth * 1.8
            height:             width
            sourceSize.height:  height
            source:             "/qmlimages/RC.svg"
            fillMode:           Image.PreserveAspectFit
            opacity:            _rcRSSIAvailable ? 1 : 0.5
            color:              qgcPal.text
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        QGCLabel {
            text:               qsTr("RC Link")
            color:              Qt.rgba(1, 1, 1, 0.6)
            font.pointSize:     ScreenTools.smallFontPointSize
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    MouseArea {
        anchors.fill:   parent
        onClicked:      mainWindow.showIndicatorDrawer(rcRSSIInfoPage, control)
    }
}
