import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Shapes

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FactControls

// Three-panel right-side telemetry widget matching MockUI design (compact layout, dual GPS, attitude, wind)
ColumnLayout {
    id:         root
    spacing:    ScreenTools.defaultFontPixelHeight * 0.45
    width:      ScreenTools.defaultFontPixelWidth * 26

    property var  _vehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property real _panelRadius: 16
    property real _pad:         ScreenTools.defaultFontPixelWidth * 1.0
    property real _gaugeSize:   ScreenTools.defaultFontPixelHeight * 3.8

    // Wind Calculations
    property var    _wind:                    _vehicle ? _vehicle.wind : null
    property var    _localPosition:           _vehicle ? _vehicle.localPosition : null

    property bool   _hasWindSpeed:            _wind && !isNaN(_wind.speed.rawValue)
    property bool   _hasWindDirection:        _wind && !isNaN(_wind.direction.rawValue)
    property bool   _hasFlightDirection:      !isNaN(_flightDirection)

    property real   _windSpeed:               _hasWindSpeed ? _wind.speed.rawValue : NaN
    property real   _windDirection:           _hasWindDirection ? _wind.direction.rawValue : NaN
    property real   _flightDirection: {
        if (!_vehicle) return NaN
        const vx = _localPosition ? _localPosition.vx.rawValue : NaN
        const vy = _localPosition ? _localPosition.vy.rawValue : NaN
        if (!isNaN(vx) && !isNaN(vy)) {
            const horizontalSpeed = Math.sqrt((vx * vx) + (vy * vy))
            if (horizontalSpeed > 0.3) {
                let deg = Math.atan2(vy, vx) * 180 / Math.PI
                let norm = deg % 360
                return norm < 0 ? norm + 360 : norm
            }
        }
        const heading = _vehicle ? _vehicle.heading.rawValue : NaN
        if (isNaN(heading)) return NaN
        let norm = heading % 360
        return norm < 0 ? norm + 360 : norm
    }
    property real   _alongTrackWind: {
        if (!_hasWindSpeed || !_hasWindDirection || !_hasFlightDirection) return NaN
        const deltaRadians = (_windDirection - _flightDirection) * Math.PI / 180
        return _windSpeed * Math.cos(deltaRadians)
    }

    // ─────────────────────────────────────────────────────────────────
    // Circular Arc Gauge Component (speedometer-style)
    // pct: 0.0–1.0, accentColor: arc fill color
    // ─────────────────────────────────────────────────────────────────
    component ArcGauge: Item {
        id: arcRoot
        width:  _gaugeSize
        height: _gaugeSize
        property real pct:          0.0     // 0.0 – 1.0
        property color accentColor: "#6be2d6"
        property string label:      ""
        property string valueText:  ""

        // Background dark center glow
        Rectangle {
            anchors.centerIn: parent
            width:  parent.width - 6
            height: parent.height - 6
            radius: width / 2
            color:  Qt.rgba(1, 1, 1, 0.02)
        }

        // Background track arc (280° sweep starting from 130°)
        Shape {
            anchors.fill: parent
            antialiasing: true
            ShapePath {
                strokeColor:    Qt.rgba(1, 1, 1, 0.12)
                strokeWidth:    4
                fillColor:      "transparent"
                capStyle:       ShapePath.RoundCap
                PathAngleArc {
                    centerX:    arcRoot.width  / 2
                    centerY:    arcRoot.height / 2
                    radiusX:    arcRoot.width  / 2 - 3
                    radiusY:    arcRoot.height / 2 - 3
                    startAngle: 130
                    sweepAngle: 280
                }
            }
        }

        // Value arc
        Shape {
            anchors.fill: parent
            antialiasing: true
            ShapePath {
                strokeColor:    arcRoot.accentColor
                strokeWidth:    4
                fillColor:      "transparent"
                capStyle:       ShapePath.RoundCap
                PathAngleArc {
                    centerX:    arcRoot.width  / 2
                    centerY:    arcRoot.height / 2
                    radiusX:    arcRoot.width  / 2 - 3
                    radiusY:    arcRoot.height / 2 - 3
                    startAngle: 130
                    sweepAngle: Math.max(0, Math.min(280, 280 * arcRoot.pct))
                }
            }
        }

        // Needle dot at end of arc
        Rectangle {
            visible:    arcRoot.pct > 0.01
            width:      6; height: 6; radius: 3
            color:      "#ffffff"

            property real _angle: (130 + 280 * arcRoot.pct) * Math.PI / 180
            property real _r:     arcRoot.width / 2 - 3
            x: arcRoot.width  / 2 + _r * Math.cos(_angle) - width  / 2
            y: arcRoot.height / 2 + _r * Math.sin(_angle) - height / 2
        }

        // Center label
        Column {
            anchors.centerIn: parent
            spacing: 0
            QGCLabel {
                text:               arcRoot.valueText
                color:              "#ffffff"
                font.pointSize:     ScreenTools.defaultFontPointSize * 0.95
                font.bold:          true
                font.weight:        Font.Bold
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
            QGCLabel {
                text:               arcRoot.label
                color:              Qt.rgba(1, 1, 1, 0.6)
                font.pointSize:     ScreenTools.smallFontPointSize * 0.8
                font.weight:        Font.Medium
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // Glassmorphic panel base (simplified, border-friendly design)
    // ─────────────────────────────────────────────────────────────────
    component GlassPanel: Rectangle {
        id: panelBg
        Layout.fillWidth:   true
        color:              Qt.rgba(0.09, 0.11, 0.16, 0.94)
        radius:             _panelRadius
        border.width:       1
        border.color:       Qt.rgba(1, 1, 1, 0.16)
        clip:               false

        property color accentColor: "#6be2d6"
        property real barWidth: 4

        // Smooth rounded left accent bar container
        Item {
            id: accentContainer
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: parent.border.width
            anchors.topMargin: parent.border.width
            anchors.bottomMargin: parent.border.width
            width: parent.barWidth
            clip: true
            visible: parent.barWidth > 0

            Rectangle {
                x: 0
                y: 0
                width: parent.width + _panelRadius * 2
                height: parent.height
                radius: Math.max(0, _panelRadius - 1)
                color: panelBg.accentColor
                antialiasing: true
            }
        }
    }

    component SectionLabel: QGCLabel {
        color:              "#e1e1e6" // Clean off-white title
        font.pointSize:     ScreenTools.defaultFontPointSize * 0.8
        font.bold:          true
        font.weight:        Font.Bold
        font.letterSpacing: 1.0
    }

    component BigValue: QGCLabel {
        color:              "#ffffff"
        font.pointSize:     ScreenTools.largeFontPointSize * 1.15
        font.bold:          true
        font.weight:        Font.Bold
    }

    component SmallCaption: QGCLabel {
        color:              Qt.rgba(1, 1, 1, 0.65)
        font.pointSize:     ScreenTools.defaultFontPointSize * 0.76
        font.weight:        Font.Medium
        font.letterSpacing: 0.5
    }

    component Divider: Rectangle {
        Layout.fillWidth:   true
        height:             1
        color:              Qt.rgba(1, 1, 1, 0.12)
    }

    // ══════════════════════════════════════════════════════════════════
    // 1. REAL-TIME TELEMETRY
    // ══════════════════════════════════════════════════════════════════
    GlassPanel {
        id: telemetryPanel
        accentColor: "#e8a030" // Amber/Gold for Telemetry
        implicitHeight: telemetryCol.implicitHeight + _pad * 2

        ColumnLayout {
            id:      telemetryCol
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                leftMargin: _pad + 6
                rightMargin: _pad
                topMargin: _pad
                bottomMargin: _pad
            }
            spacing: ScreenTools.defaultFontPixelHeight * 0.35

            // Title Row
            RowLayout {
                spacing: 8
                SectionLabel { text: qsTr("REAL-TIME TELEMETRY") }
            }
            Divider {}

            // Altitude row + Climb rate pill
            RowLayout {
                Layout.fillWidth: true
                spacing:          ScreenTools.defaultFontPixelWidth

                ColumnLayout {
                    spacing: 0
                    SmallCaption { text: qsTr("ALTITUDE") }
                    RowLayout {
                        spacing: 2
                        BigValue {
                            id: altValue
                            text: _vehicle ? _vehicle.altitudeRelative.valueString : "—"
                        }
                        QGCLabel {
                            text:           _vehicle ? _vehicle.altitudeRelative.units : "m"
                            color:          Qt.rgba(1, 1, 1, 0.7)
                            font.pointSize: ScreenTools.defaultFontPointSize * 0.90
                            font.bold:      true
                            anchors.baseline: altValue.baseline
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Climb rate pill
                Rectangle {
                    width:  climbPillCol.implicitWidth + ScreenTools.defaultFontPixelWidth * 1.5
                    height: climbPillCol.implicitHeight + ScreenTools.defaultFontPixelHeight * 0.3
                    radius: 5
                    color:  {
                        var v = _vehicle ? _vehicle.climbRate.rawValue : 0
                        return v > 0.2 ? Qt.rgba(0.10, 0.75, 0.45, 0.12) : (v < -0.2 ? Qt.rgba(1.0, 0.32, 0.32, 0.12) : Qt.rgba(1.0, 1.0, 1.0, 0.08))
                    }
                    border.width: 1
                    border.color: {
                        var v = _vehicle ? _vehicle.climbRate.rawValue : 0
                        return v > 0.2 ? Qt.rgba(0.10, 0.75, 0.45, 0.4) : (v < -0.2 ? Qt.rgba(1.0, 0.32, 0.32, 0.4) : Qt.rgba(1.0, 1.0, 1.0, 0.2))
                    }
                    Layout.alignment: Qt.AlignVCenter

                    ColumnLayout {
                        id: climbPillCol
                        anchors.centerIn: parent
                        spacing: 0

                        QGCLabel {
                            Layout.alignment:   Qt.AlignHCenter
                            text: {
                                if (!_vehicle) return "+0.0"
                                var v = _vehicle.climbRate.rawValue
                                return (v >= 0 ? "+" : "") + _vehicle.climbRate.valueString
                            }
                            color: {
                                var v = _vehicle ? _vehicle.climbRate.rawValue : 0
                                return v > 0.2 ? "#3fda8f" : (v < -0.2 ? "#ff5252" : "#dddddd")
                            }
                            font.pointSize: ScreenTools.defaultFontPointSize * 0.85
                            font.bold:      true
                        }
                        SmallCaption {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("CLIMB")
                            font.pointSize: ScreenTools.defaultFontPointSize * 0.65
                            color: {
                                var v = _vehicle ? _vehicle.climbRate.rawValue : 0
                                return v > 0.2 ? Qt.rgba(0.25, 0.85, 0.55, 0.8) : (v < -0.2 ? Qt.rgba(1.0, 0.45, 0.45, 0.8) : Qt.rgba(1.0, 1.0, 1.0, 0.6))
                            }
                        }
                    }
                }
            }

            // Attitude row (Pitch & Roll)
            RowLayout {
                Layout.fillWidth: true
                spacing: 4
                
                SmallCaption { text: qsTr("PITCH:") }
                QGCLabel {
                    text: _vehicle ? _vehicle.pitch.rawValue.toFixed(1) + "°" : "—"
                    color: "#ffffff"
                    font.pointSize: ScreenTools.defaultFontPointSize * 0.85
                    font.bold: true
                }
                
                Item { width: 8 }
                
                SmallCaption { text: qsTr("ROLL:") }
                QGCLabel {
                    text: _vehicle ? _vehicle.roll.rawValue.toFixed(1) + "°" : "—"
                    color: "#ffffff"
                    font.pointSize: ScreenTools.defaultFontPointSize * 0.85
                    font.bold: true
                }
            }

            Divider {}

            // Speed row + Speedometer
            RowLayout {
                Layout.fillWidth: true
                spacing: ScreenTools.defaultFontPixelWidth

                ColumnLayout {
                    spacing: 0
                    SmallCaption { text: qsTr("SPEED") }
                    RowLayout {
                        spacing: 2
                        BigValue {
                            id: spdValue
                            text: _vehicle ? _vehicle.groundSpeed.valueString : "—"
                        }
                        QGCLabel {
                            text:           _vehicle ? _vehicle.groundSpeed.units : "m/s"
                            color:          Qt.rgba(1, 1, 1, 0.7)
                            font.pointSize: ScreenTools.defaultFontPointSize * 0.90
                            font.bold:      true
                            anchors.baseline: spdValue.baseline
                        }
                    }
                    SmallCaption { text: qsTr("GROUND SPEED"); font.pointSize: ScreenTools.defaultFontPointSize * 0.7 }
                }

                Item { Layout.fillWidth: true }

                // Speedometer gauge
                ArcGauge {
                    pct: {
                        if (!_vehicle) return 0
                        return Math.min(1.0, Math.max(0, _vehicle.groundSpeed.rawValue / 30))
                    }
                    accentColor: "#e8a030"
                    valueText:   _vehicle ? _vehicle.groundSpeed.valueString : "0"
                    label:       _vehicle ? _vehicle.groundSpeed.units : "m/s"
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            // Wind line (Wind Speed & Assist)
            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                visible: _hasWindSpeed

                SmallCaption { text: qsTr("WIND:") }
                
                RowLayout {
                    spacing: 2
                    QGCColoredImage {
                        width:              ScreenTools.defaultFontPixelHeight * 0.7
                        height:             width
                        source:             "/res/ArrowDown.svg"
                        color:              "#e8a030"
                        rotation:           _hasWindDirection ? (_windDirection - 180) : 0
                        fillMode:           Image.PreserveAspectFit
                    }
                    QGCLabel {
                        text:               _wind ? _wind.speed.valueString + " " + _wind.speed.units : ""
                        color:              "#ffffff"
                        font.pointSize:     ScreenTools.defaultFontPointSize * 0.85
                        font.bold:          true
                    }
                }

                Rectangle { width: 1; height: 10; color: Qt.rgba(1, 1, 1, 0.15); visible: !isNaN(_alongTrackWind) }

                QGCLabel {
                    text: {
                        if (isNaN(_alongTrackWind)) return "—"
                        if (Math.abs(_alongTrackWind) < 0.1) return qsTr("Neutral")
                        return _alongTrackWind > 0
                            ? qsTr("Tail %1").arg(_alongTrackWind.toFixed(1) + "m/s")
                            : qsTr("Head %1").arg((-_alongTrackWind).toFixed(1) + "m/s")
                    }
                    color: "#ffffff"
                    font.pointSize:     ScreenTools.defaultFontPointSize * 0.85
                    font.bold:          true
                }
            }
        }
    }

    // ══════════════════════════════════════════════════════════════════
    // 2. BATTERY
    // ══════════════════════════════════════════════════════════════════
    GlassPanel {
        id: batteryPanel
        accentColor: {
            if (_pct >= 50) return "#00d563"
            if (_pct >= 20) return "#f5a623"
            return "#f32836"
        }
        implicitHeight: batteryCol.implicitHeight + _pad * 2
        visible:        _vehicle !== null

        property var _bat: (_vehicle && _vehicle.batteries.count > 0) ? _vehicle.batteries.get(0) : null
        property real _pct: _bat && !isNaN(_bat.percentRemaining.rawValue) ? _bat.percentRemaining.rawValue : 0

        ColumnLayout {
            id:      batteryCol
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                leftMargin: _pad + 6
                rightMargin: _pad
                topMargin: _pad
                bottomMargin: _pad
            }
            spacing: ScreenTools.defaultFontPixelHeight * 0.35

            // Title Row
            RowLayout {
                spacing: 8
                SectionLabel { text: qsTr("BATTERY") }
            }
            Divider {}

            // Big % value
            RowLayout {
                spacing: 8
                BigValue {
                    text: {
                        var b = batteryPanel._bat
                        if (!b) return "—"
                        return isNaN(b.percentRemaining.rawValue) ? "—" : Math.round(b.percentRemaining.rawValue) + "%"
                    }
                }
                Item { Layout.fillWidth: true }
                QGCLabel {
                    text: {
                        var p = batteryPanel._pct
                        if (p >= 50) return "HEALTHY"
                        if (p >= 20) return "LOW"
                        return "CRITICAL"
                    }
                    color: batteryPanel.accentColor
                    font.pointSize: ScreenTools.defaultFontPointSize * 0.8
                    font.bold: true
                    font.weight: Font.Bold
                    font.letterSpacing: 1.0
                }
            }

            // Battery level bar
            Item {
                Layout.fillWidth: true
                height: ScreenTools.defaultFontPixelHeight * 0.45

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: Qt.rgba(1, 1, 1, 0.08)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.06)
                }

                Rectangle {
                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom; margins: 1 }
                    width: {
                        var p = batteryPanel._pct / 100
                        return (parent.width - 2) * Math.max(0, Math.min(1, p))
                    }
                    radius: height / 2
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: batteryPanel.accentColor }
                        GradientStop {
                            position: 1.0
                            color: {
                                var pct = batteryPanel._pct
                                if (pct >= 50) return "#26e07b"
                                if (pct >= 20) return "#ffb83d"
                                return "#ff4d5a"
                            }
                        }
                    }
                }
            }

            // Stats grid
            GridLayout {
                Layout.fillWidth: true
                columns:          2
                rowSpacing:       ScreenTools.defaultFontPixelHeight * 0.3
                columnSpacing:    ScreenTools.defaultFontPixelWidth

                SmallCaption { text: qsTr("VOLTAGE") }
                SmallCaption { text: qsTr("CURRENT"); horizontalAlignment: Text.AlignRight; Layout.fillWidth: true }

                QGCLabel {
                    text: {
                        var b = batteryPanel._bat
                        if (!b) return "—"
                        return isNaN(b.voltage.rawValue) ? "—" : b.voltage.valueString + " " + b.voltage.units
                    }
                    color: "#ffffff"; font.pointSize: ScreenTools.defaultFontPointSize * 0.95; font.bold: true; font.weight: Font.Bold
                }
                QGCLabel {
                    text: {
                        var b = batteryPanel._bat
                        if (!b) return "—"
                        return isNaN(b.current.rawValue) ? "—" : b.current.valueString + " " + b.current.units
                    }
                    color: "#ffffff"; font.pointSize: ScreenTools.defaultFontPointSize * 0.95; font.bold: true; font.weight: Font.Bold
                    horizontalAlignment: Text.AlignRight
                    Layout.fillWidth: true
                }

                SmallCaption { text: qsTr("EST. TIME REMAINING") }
                QGCLabel {
                    text: {
                        var b = batteryPanel._bat
                        if (!b || isNaN(b.timeRemaining.rawValue)) return "—"
                        return b.timeRemainingStr.value
                    }
                    color: "#ffffff"; font.pointSize: ScreenTools.defaultFontPointSize * 0.95; font.bold: true; font.weight: Font.Bold
                    horizontalAlignment: Text.AlignRight
                    Layout.fillWidth: true
                }
            }
        }
    }

    // ══════════════════════════════════════════════════════════════════
    // 3. GPS STATUS & DUAL SATELLITE RADAR
    // ══════════════════════════════════════════════════════════════════
    GlassPanel {
        id: gpsPanel
        accentColor: "#3fda8f" // Emerald green for GPS fix status
        implicitHeight: gpsCol.implicitHeight + _pad * 2
        visible:        _vehicle !== null

        ColumnLayout {
            id:      gpsCol
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                leftMargin: _pad + 6
                rightMargin: _pad
                topMargin: _pad
                bottomMargin: _pad
            }
            spacing: ScreenTools.defaultFontPixelHeight * 0.35

            // Title Row
            RowLayout {
                spacing: 8
                SectionLabel { text: qsTr("GPS STATUS") }
            }
            Divider {}

            RowLayout {
                Layout.fillWidth: true
                spacing:          ScreenTools.defaultFontPixelWidth

                // Left Column: GPS 1 & GPS 2 status stacked vertically
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing:          ScreenTools.defaultFontPixelHeight * 0.2

                    // GPS 1 info
                    ColumnLayout {
                        spacing: 0
                        SmallCaption { text: qsTr("GPS 1"); color: "#3fda8f"; font.bold: true }
                        RowLayout {
                            spacing: 4
                            QGCLabel {
                                text: {
                                    if (!_vehicle) return "No Fix"
                                    var fix = _vehicle.gps.lock.rawValue
                                    if (fix >= 3) return qsTr("3D Fix")
                                    if (fix === 2) return qsTr("2D Fix")
                                    return qsTr("No Fix")
                                }
                                color: {
                                    if (!_vehicle) return "#f32836"
                                    var fix = _vehicle.gps.lock.rawValue
                                    return fix >= 3 ? "#3fda8f" : fix === 2 ? "#f5a623" : "#f32836"
                                }
                                font.pointSize: ScreenTools.defaultFontPointSize * 0.95
                                font.bold: true
                            }
                            SmallCaption {
                                text: _vehicle ? "• S:" + _vehicle.gps.count.valueString + " H:" + _vehicle.gps.hdop.valueString : ""
                                font.pointSize: ScreenTools.defaultFontPointSize * 0.78
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Qt.rgba(1, 1, 1, 0.08)
                    }

                    // GPS 2 info
                    ColumnLayout {
                        spacing: 0
                        SmallCaption { text: qsTr("GPS 2"); color: "#3fda8f"; font.bold: true }
                        RowLayout {
                            spacing: 4
                            QGCLabel {
                                text: {
                                    if (!_vehicle || !_vehicle.gps2 || _vehicle.gps2.count.rawValue <= 0) return "No GPS"
                                    var fix = _vehicle.gps2.lock.rawValue
                                    if (fix >= 3) return qsTr("3D Fix")
                                    if (fix === 2) return qsTr("2D Fix")
                                    return qsTr("No Fix")
                                }
                                color: {
                                    if (!_vehicle || !_vehicle.gps2 || _vehicle.gps2.count.rawValue <= 0) return Qt.rgba(1, 1, 1, 0.4)
                                    var fix = _vehicle.gps2.lock.rawValue
                                    return fix >= 3 ? "#3fda8f" : fix === 2 ? "#f5a623" : "#f32836"
                                }
                                font.pointSize: ScreenTools.defaultFontPointSize * 0.95
                                font.bold: true
                            }
                            SmallCaption {
                                text: (_vehicle && _vehicle.gps2 && _vehicle.gps2.count.rawValue > 0) ? "• S:" + _vehicle.gps2.count.valueString + " H:" + _vehicle.gps2.hdop.valueString : ""
                                font.pointSize: ScreenTools.defaultFontPointSize * 0.78
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Right Column: Advanced Sci-Fi Tactical Radar
                Item {
                    width:  _gaugeSize
                    height: _gaugeSize
                    Layout.alignment: Qt.AlignVCenter

                    // Radar background grid (outer boundary)
                    Rectangle {
                        anchors.fill: parent
                        radius:       width / 2
                        color:        Qt.rgba(1, 1, 1, 0.01)
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.08)
                    }

                    // Radar Concentric Grid 1 (Outer circle)
                    Rectangle {
                        anchors.centerIn: parent
                        width:            parent.width * 0.95
                        height:           width
                        radius:           width / 2
                        color:            "transparent"
                        border.width:     1
                        border.color:     Qt.rgba(1, 1, 1, 0.04)
                    }

                    // Radar Concentric Grid 2 (Middle circle)
                    Rectangle {
                        anchors.centerIn: parent
                        width:            parent.width * 0.65
                        height:           width
                        radius:           width / 2
                        color:            "transparent"
                        border.width:     1
                        border.color:     Qt.rgba(1, 1, 1, 0.05)
                    }

                    // Radar Concentric Grid 3 (Inner circle)
                    Rectangle {
                        anchors.centerIn: parent
                        width:            parent.width * 0.35
                        height:           width
                        radius:           width / 2
                        color:            "transparent"
                        border.width:     1
                        border.color:     Qt.rgba(1, 1, 1, 0.06)
                    }

                    // Radar Grid Crosshairs & Radials
                    Rectangle { anchors.centerIn: parent; width: parent.width; height: 1; color: Qt.rgba(1, 1, 1, 0.04) }
                    Rectangle { anchors.centerIn: parent; width: 1; height: parent.height; color: Qt.rgba(1, 1, 1, 0.04) }
                    
                    // Diagonal lines
                    Rectangle {
                        anchors.centerIn: parent; width: parent.width; height: 1; color: Qt.rgba(1, 1, 1, 0.03)
                        transform: Rotation { origin.x: width/2; origin.y: 0.5; angle: 45 }
                    }
                    Rectangle {
                        anchors.centerIn: parent; width: parent.width; height: 1; color: Qt.rgba(1, 1, 1, 0.03)
                        transform: Rotation { origin.x: width/2; origin.y: 0.5; angle: 135 }
                    }

                    // Outer Fix Quality Arc
                    Shape {
                        anchors.fill: parent
                        antialiasing: true
                        property real _quality: {
                            if (!_vehicle) return 0
                            var fix = _vehicle.gps.lock.rawValue
                            var sats = _vehicle.gps.count.rawValue
                            if (fix >= 3 && sats >= 12) return 1.0
                            if (fix >= 3 && sats >= 8)  return 0.75
                            if (fix >= 3)               return 0.5
                            if (fix >= 2)               return 0.25
                            return 0.05
                        }
                        ShapePath {
                            strokeColor: gpsPanel.accentColor
                            strokeWidth: 3
                            fillColor:   "transparent"
                            capStyle:    ShapePath.RoundCap
                            PathAngleArc {
                                centerX:    _gaugeSize / 2
                                centerY:    _gaugeSize / 2
                                radiusX:    _gaugeSize / 2 - 2
                                radiusY:    _gaugeSize / 2 - 2
                                startAngle: -90
                                sweepAngle: 360 * parent._quality
                            }
                        }
                    }

                    // Radar Sweep Wedge Trail (drawn on canvas once, rotated dynamically)
                    Canvas {
                        id:             radarSweep
                        anchors.fill:   parent
                        antialiasing:   true
                        
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            var cx = width / 2
                            var cy = height / 2
                            var r = width / 2 - 2
                            
                            ctx.beginPath()
                            ctx.moveTo(cx, cy)
                            ctx.arc(cx, cy, r, -Math.PI / 4, 0)
                            ctx.closePath()
                            
                            var grad = ctx.createRadialGradient(cx, cy, r * 0.1, cx, cy, r)
                            grad.addColorStop(0, Qt.rgba(0.24, 0.85, 0.56, 0.45))
                            grad.addColorStop(1, Qt.rgba(0.24, 0.85, 0.56, 0.0))
                            ctx.fillStyle = grad
                            ctx.fill()
                        }

                        RotationAnimation on rotation {
                            from: 0
                            to: 360
                            duration: 3000
                            loops: Animation.Infinite
                            running: true
                        }
                    }

                    // Active Satellites Dots (simulated orbiting signal locations)
                    Repeater {
                        model: [
                            { rx: 0.28, ry: 0.32 },
                            { rx: 0.72, ry: 0.22 },
                            { rx: 0.18, ry: 0.68 },
                            { rx: 0.76, ry: 0.72 },
                            { rx: 0.58, ry: 0.84 }
                        ]
                        delegate: Item {
                            x: modelData.rx * parent.width
                            y: modelData.ry * parent.height
                            width: 6; height: 6
                            
                            // Glowing halo
                            Rectangle {
                                anchors.centerIn: parent
                                width:            8; height: 8; radius: 4
                                color:            "#3fda8f"
                                opacity:          0.4
                            }
                            // Solid core
                            Rectangle {
                                anchors.centerIn: parent
                                width:            4; height: 4; radius: 2
                                color:            "#3fda8f"
                            }
                        }
                    }

                    // Center Drone Position
                    Rectangle {
                        anchors.centerIn: parent
                        width:            6; height: 6; radius: 3
                        color:            "#ffffff"
                        
                        Rectangle {
                            anchors.centerIn: parent
                            width:            12; height: 12; radius: 6
                            color:            "#ffffff"
                            opacity:          0.25
                        }
                    }
                }
            }
        }
    }
}
