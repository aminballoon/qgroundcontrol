import QtQml.Models
import QtQuick
import QtQuick.Controls

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlyView

ToolStrip {
    id: _root

    signal displayPreFlightChecklist

    FlyViewToolStripActionList {
        id: flyViewToolStripActionList

        onDisplayPreFlightChecklist: _root.displayPreFlightChecklist()
        onShowFlyView: {
            if (mainWindow.allowViewSwitch()) {
                mainWindow.showFlyView()
            }
        }
        onShowPlanView: {
            if (mainWindow.allowViewSwitch()) {
                mainWindow.showPlanView()
            }
        }
        onShowVehicleConfig: {
            if (mainWindow.allowViewSwitch()) {
                mainWindow.showVehicleConfigParametersPage()
            }
        }
        onShowAnalyzeTool: {
            if (mainWindow.allowViewSwitch()) {
                mainWindow.showAnalyzeTool()
            }
        }
        onShowSettingsTool: {
            if (mainWindow.allowViewSwitch()) {
                mainWindow.showSettingsTool()
            }
        }
    }

    model: flyViewToolStripActionList.model
}
