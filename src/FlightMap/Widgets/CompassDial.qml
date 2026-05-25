import QtQuick

import QGroundControl
import QGroundControl.Controls

/// This is the dial background for the compass

Item {
    id: control

    property real size:         width
    property real offsetRadius: width / 2 - ScreenTools.defaultFontPixelHeight / 2
    property int  _fontSize:    ScreenTools.defaultFontPointSize * (size / (ScreenTools.defaultFontPixelHeight * 10)) < 8 ? 8 : ScreenTools.defaultFontPointSize * (size / (ScreenTools.defaultFontPixelHeight * 10))

    function translateCenterToAngleX(radius, angle) {
        return radius * Math.sin(angle * (Math.PI / 180))
    }

    function translateCenterToAngleY(radius, angle) {
        return -radius * Math.cos(angle * (Math.PI / 180))
    }

    QGCLabel {
        anchors.centerIn:   parent
        text:               "N"
        color:              "#6be2d6" // Teal for North
        font.bold:          true
        font.weight:        Font.Bold
        font.pointSize:     control._fontSize
        rotation:           _lockNoseUpCompass ? _heading : 0

        transform: Translate {
            x: translateCenterToAngleX(control.offsetRadius, 0)
            y: translateCenterToAngleY(control.offsetRadius, 0)
        }
    }

    QGCLabel {
        anchors.centerIn:   parent
        text:               "E"
        color:              "#ffffff"
        font.bold:          true
        font.weight:        Font.Bold
        font.pointSize:     control._fontSize
        rotation:           _lockNoseUpCompass ? _heading : 0

        transform: Translate {
            x: translateCenterToAngleX(control.offsetRadius, 90)
            y: translateCenterToAngleY(control.offsetRadius, 90)
        }
    }

    QGCLabel {
        anchors.centerIn:   parent
        text:               "S"
        color:              "#ffffff"
        font.bold:          true
        font.weight:        Font.Bold
        font.pointSize:     control._fontSize
        rotation:           _lockNoseUpCompass ? _heading : 0

        transform: Translate {
            x: translateCenterToAngleX(control.offsetRadius, 180)
            y: translateCenterToAngleY(control.offsetRadius, 180)
        }
    }

    QGCLabel {
        anchors.centerIn:   parent
        text:               "W"
        color:              "#ffffff"
        font.bold:          true
        font.weight:        Font.Bold
        font.pointSize:     control._fontSize
        rotation:           _lockNoseUpCompass ? _heading : 0

        transform: Translate {
            x: translateCenterToAngleX(control.offsetRadius, 270)
            y: translateCenterToAngleY(control.offsetRadius, 270)
        }
    }

    // Major tick marks
    Repeater {
        model: 4

        Rectangle {
            x:                  size / 2
            width:              1.5
            height:             size * 0.08
            color:              Qt.rgba(1, 1, 1, 0.6)
            antialiasing:       true

            transform: Rotation {
                origin.x:   0
                origin.y:   size / 2
                angle:      45 + (90 * index)
            }
        }
    }

    // Minor tick marks
    Repeater {
        model: 8

        Rectangle {
            x:                  size / 2
            y:                  _margin
            width:              1
            height:             _margin
            color:              Qt.rgba(1, 1, 1, 0.35)
            antialiasing:       true

            property real _margin: size * 0.04

            transform: Rotation {
                origin.x:   0
                origin.y:   size / 2 - _margin
                angle:      45 / 2 + (45 * index)
            }
        }
    }
}
