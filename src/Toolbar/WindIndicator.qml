import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

Item {
    id:             control
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    width:          windIndicatorRow.width

    property var    _activeVehicle:           QGroundControl.multiVehicleManager.activeVehicle
    property var    _flyViewSettings:         QGroundControl.settingsManager.flyViewSettings
    property var    _vehicleFacts:            _activeVehicle ? _activeVehicle.vehicle : null
    property var    _localPosition:           _activeVehicle ? _activeVehicle.localPosition : null
    property var    _wind:                    _activeVehicle ? _activeVehicle.wind : null

    property bool   _hasWindTelemetry:        _wind && _wind.telemetryAvailable
    property bool   _hasWindSpeed:            _wind && !isNaN(_wind.speed.rawValue)
    property bool   _hasWindDirection:        _wind && !isNaN(_wind.direction.rawValue)
    property bool   _hasFlightDirection:      !isNaN(_flightDirection)

    property real   _windSpeed:               _hasWindSpeed ? _wind.speed.rawValue : NaN
    property real   _windDirection:           _hasWindDirection ? _wind.direction.rawValue : NaN
    property real   _flightDirection:         _calculateFlightDirection()
    property real   _alongTrackWind:          _calculateAlongTrackWind()
    property real   _crossTrackWind:          _calculateCrossTrackWind()

    property bool showIndicator: _activeVehicle
                                && _flyViewSettings.showWindIndicator.rawValue

    function _normalizeDegrees(degrees) {
        let normalized = degrees % 360
        if (normalized < 0) {
            normalized += 360
        }
        return normalized
    }

    function _factValueText(fact) {
        if (!fact || isNaN(fact.rawValue)) {
            return qsTr("--")
        }

        return fact.valueString + (fact.units ? " " + fact.units : "")
    }

    function _formatMetersPerSecond(value) {
        if (isNaN(value)) {
            return qsTr("--")
        }

        return value.toFixed(1) + " m/s"
    }

    function _calculateFlightDirection() {
        if (!_activeVehicle) {
            return NaN
        }

        const vx = _localPosition ? _localPosition.vx.rawValue : NaN
        const vy = _localPosition ? _localPosition.vy.rawValue : NaN
        if (!isNaN(vx) && !isNaN(vy)) {
            const horizontalSpeed = Math.sqrt((vx * vx) + (vy * vy))
            if (horizontalSpeed > 0.3) {
                return _normalizeDegrees(Math.atan2(vy, vx) * 180 / Math.PI)
            }
        }

        const heading = _vehicleFacts ? _vehicleFacts.heading.rawValue : NaN
        return isNaN(heading) ? NaN : _normalizeDegrees(heading)
    }

    function _calculateAlongTrackWind() {
        if (!_hasWindSpeed || !_hasWindDirection || !_hasFlightDirection) {
            return NaN
        }

        const deltaRadians = (_windDirection - _flightDirection) * Math.PI / 180
        return _windSpeed * Math.cos(deltaRadians)
    }

    function _calculateCrossTrackWind() {
        if (!_hasWindSpeed || !_hasWindDirection || !_hasFlightDirection) {
            return NaN
        }

        const deltaRadians = (_windDirection - _flightDirection) * Math.PI / 180
        return _windSpeed * Math.sin(deltaRadians)
    }

    function _windAssistText() {
        if (isNaN(_alongTrackWind)) {
            return qsTr("Head/Tail --")
        }

        if (Math.abs(_alongTrackWind) < 0.1) {
            return qsTr("Neutral")
        }

        return _alongTrackWind > 0
            ? qsTr("Tail %1").arg(_formatMetersPerSecond(_alongTrackWind))
            : qsTr("Head %1").arg(_formatMetersPerSecond(-_alongTrackWind))
    }

    function _crossWindText() {
        if (isNaN(_crossTrackWind)) {
            return qsTr("Crosswind: --")
        }

        return qsTr("Crosswind: %1").arg(_formatMetersPerSecond(Math.abs(_crossTrackWind)))
    }

    QGCPalette { id: qgcPal }

    Row {
        id:             windIndicatorRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        spacing:        ScreenTools.defaultFontPixelWidth * 0.4

        Item {
            width:   ScreenTools.defaultFontPixelHeight * 1.35
            height:  parent.height

            QGCColoredImage {
                anchors.fill:       parent
                anchors.margins:    ScreenTools.defaultFontPixelWidth * 0.25
                source:             "/res/ArrowDown.svg"
                sourceSize.height:  height
                fillMode:           Image.PreserveAspectFit
                color:              qgcPal.text
                rotation:           _hasWindDirection ? (_windDirection - 180) : 0
                opacity:            _hasWindDirection ? 1.0 : 0.45
                transformOrigin:    Item.Center
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing:                ScreenTools.defaultFontPixelHeight * 0.04

            QGCLabel {
                color:          qgcPal.text
                font.pointSize: ScreenTools.smallFontPointSize
                font.bold:      true
                text:           control._factValueText(control._wind ? control._wind.speed : null)
            }

            QGCLabel {
                color:          qgcPal.text
                font.pointSize: Math.max(ScreenTools.smallFontPointSize - 1, 8)
                text:           control._windAssistText()
            }
        }
    }

    MouseArea {
        anchors.fill:   parent
        onClicked:      mainWindow.showIndicatorDrawer(windIndicatorPage, control)
    }

    Component {
        id: windIndicatorPage

        ToolIndicatorPage {
            showExpand: false

            contentComponent: SettingsGroupLayout {
                heading: qsTr("Wind")

                LabelledLabel {
                    label:      qsTr("Wind speed:")
                    labelText:  control._factValueText(control._wind ? control._wind.speed : null)
                }

                LabelledLabel {
                    label:      qsTr("Wind direction:")
                    labelText:  control._factValueText(control._wind ? control._wind.direction : null)
                }

                LabelledLabel {
                    label:      qsTr("Flight direction:")
                    labelText:  isNaN(control._flightDirection) ? qsTr("--") : control._flightDirection.toFixed(0) + " deg"
                }

                LabelledLabel {
                    label:      qsTr("Wind assist:")
                    labelText:  control._windAssistText()
                }

                LabelledLabel {
                    label:      qsTr("Crosswind:")
                    labelText:  isNaN(control._crossTrackWind) ? qsTr("--") : control._formatMetersPerSecond(Math.abs(control._crossTrackWind))
                }

                LabelledLabel {
                    label:      qsTr("Vertical wind:")
                    labelText:  control._factValueText(control._wind ? control._wind.verticalSpeed : null)
                }
            }
        }
    }
}
