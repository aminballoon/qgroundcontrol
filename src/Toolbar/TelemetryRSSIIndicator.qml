import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

//-------------------------------------------------------------------------
//-- Telemetry RSSI
Item {
    id:             control
    width:          telemColumn.width

    property bool showIndicator: _hasTelemetry

    property var  _activeVehicle:   QGroundControl.multiVehicleManager.activeVehicle
    property var  _radioStatus:     _activeVehicle.radioStatus
    property bool _hasTelemetry:    _radioStatus.lrssi.rawValue !== 0

    Column {
        id:                     telemColumn
        anchors.verticalCenter: parent.verticalCenter
        spacing:                1
        
        QGCColoredImage {
            id:                 telemIcon
            width:              ScreenTools.defaultFontPixelWidth * 1.8
            height:             width
            sourceSize.height:  height
            source:             "/qmlimages/TelemRSSI.svg"
            fillMode:           Image.PreserveAspectFit
            color:              qgcPal.text
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        QGCLabel {
            text:               qsTr("Datalink")
            color:              Qt.rgba(1, 1, 1, 0.6)
            font.pointSize:     ScreenTools.smallFontPointSize
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    MouseArea {
        anchors.fill:   parent
        onClicked:      mainWindow.showIndicatorDrawer(telemRSSIInfoPage, control)
    }

    Component {
        id: telemRSSIInfoPage

        ToolIndicatorPage {
            showExpand: false

            contentComponent: SettingsGroupLayout {
                heading: qsTr("Telemetry RSSI Status")

                LabelledLabel {
                    label:      qsTr("Local RSSI:")
                    labelText:  _radioStatus.lrssi.rawValue + " " + qsTr("dBm")
                }

                LabelledLabel {
                    label:      qsTr("Remote RSSI:")
                    labelText:  _radioStatus.rrssi.rawValue + " " + qsTr("dBm")
                }

                LabelledLabel {
                    label:      qsTr("RX Errors:")
                    labelText:  _radioStatus.rxErrors.rawValue
                }

                LabelledLabel {
                    label:      qsTr("Errors Fixed:")
                    labelText:  _radioStatus.fixed.rawValue
                }

                LabelledLabel {
                    label:      qsTr("TX Buffer:")
                    labelText:  _radioStatus.txBuffer.rawValue
                }

                LabelledLabel {
                    label:      qsTr("Local Noise:")
                    labelText:  _radioStatus.lNoise.rawValue
                }

                LabelledLabel {
                    label:      qsTr("Remote Noise:")
                    labelText:  _radioStatus.rNoise.rawValue
                }
            }
        }
    }
}
