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

ToolIndicatorPage {
    showExpand: false

    property var    activeVehicle:  QGroundControl.multiVehicleManager.activeVehicle
    property string na:             qsTr("N/A", "No data to display")
    property string valueNA:        qsTr("–.––", "No data to display")

    contentComponent: Component {
        ColumnLayout {
            spacing: ScreenTools.defaultFontPixelHeight / 2

            SettingsGroupLayout {
                heading: qsTr("Vehicle GPS2 Status")
                visible: activeVehicle

                LabelledLabel {
                    label:      qsTr("Satellites")
                    labelText:  activeVehicle ? activeVehicle.gps2.count.valueString : na
                }

                LabelledLabel {
                    label:      qsTr("GPS Lock")
                    labelText:  activeVehicle ? activeVehicle.gps2.lock.enumStringValue : na
                }

                LabelledLabel {
                    label:      qsTr("HDOP")
                    labelText:  activeVehicle ? activeVehicle.gps2.hdop.valueString : valueNA
                }

                LabelledLabel {
                    label:      qsTr("VDOP")
                    labelText:  activeVehicle ? activeVehicle.gps2.vdop.valueString : valueNA
                }

                LabelledLabel {
                    label:      qsTr("Course Over Ground")
                    labelText:  activeVehicle ? activeVehicle.gps2.courseOverGround.valueString : valueNA
                }

                LabelledLabel {
                    label:      qsTr("Latitude")
                    labelText:  activeVehicle ? activeVehicle.gps2.lat.valueString : valueNA
                    visible:    activeVehicle && !isNaN(activeVehicle.gps2.lat.value)
                }

                LabelledLabel {
                    label:      qsTr("Longitude")
                    labelText:  activeVehicle ? activeVehicle.gps2.lon.valueString : valueNA
                    visible:    activeVehicle && !isNaN(activeVehicle.gps2.lon.value)
                }
            }
        }
    }
}
