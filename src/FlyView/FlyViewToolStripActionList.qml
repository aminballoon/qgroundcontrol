import QtQml.Models

import QGroundControl
import QGroundControl.Controls
import QGroundControl.Viewer3D

ToolStripActionList {
    id: _root

    signal displayPreFlightChecklist
    signal showFlyView
    signal showPlanView
    signal showVehicleConfig
    signal showAnalyzeTool
    signal showSettingsTool

    model: [
        ToolStripAction {
            text:       qsTr("Fly")
            iconSource: "/res/icon_fly.svg"
            checkable:  true
            checked:    true
            onTriggered: _root.showFlyView()
        },
        ToolStripAction {
            text:       qsTr("Plan")
            iconSource: "/res/icon_plan.svg"
            checkable:  true
            onTriggered: _root.showPlanView()
        },
        ToolStripAction {
            text:       qsTr("Param")
            iconSource: "/res/icon_param.svg"
            checkable:  true
            onTriggered: _root.showVehicleConfig()
        },
        ToolStripAction {
            text:       qsTr("Analyze")
            iconSource: "/res/icon_analyze.svg"
            checkable:  true
            onTriggered: _root.showAnalyzeTool()
        },
        ToolStripAction {
            text:       qsTr("Camera")
            iconSource: "/res/icon_camera.svg"
            checkable:  true
            onTriggered: {
                // Camera view functionality can be added here
            }
        },
        ToolStripAction {
            text:       qsTr("Settings")
            iconSource: "/res/icon_settings.svg"
            checkable:  true
            onTriggered: _root.showSettingsTool()
        }
    ]
}
