import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

Item {
    id:             control
    width:          indicatorIcon.width * 1.1
    anchors.top:    parent.top
    anchors.bottom: parent.bottom

    property var    _activeVehicle:          QGroundControl.multiVehicleManager.activeVehicle
    property bool   showIndicator:           _activeVehicle !== null
    property bool   _landingTargetAvailable: _activeVehicle ? _activeVehicle.landingTargetAvailable : false

    QGCPalette { id: qgcPal }

    QGCColoredImage {
        id:                 indicatorIcon
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        width:              height
        sourceSize.height:  height
        source:             "/qmlimages/LandingTarget.svg"
        fillMode:           Image.PreserveAspectFit
        color:              _landingTargetAvailable ? qgcPal.colorGreen : qgcPal.colorGrey
    }

    MouseArea {
        anchors.fill:   parent
        onClicked:      mainWindow.showIndicatorDrawer(precisionLandIndicatorPage, control)
    }

    Component {
        id: precisionLandIndicatorPage

        ToolIndicatorPage {
            contentComponent: Component {
                SettingsGroupLayout {
                    heading: qsTr("Precision Landing")

                    LabelledLabel {
                        label: qsTr("LANDING_TARGET")
                        labelText: _landingTargetAvailable ? qsTr("Active") : qsTr("No data for 2 seconds")
                    }
                }
            }
        }
    }
}
