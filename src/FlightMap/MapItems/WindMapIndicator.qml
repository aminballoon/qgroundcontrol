import QtQuick
import QtLocation

import QGroundControl
import QGroundControl.Controls

MapQuickItem {
    id: root

    property var vehicle

    property var  _flyViewSettings:     QGroundControl.settingsManager.flyViewSettings
    property var  _wind:                vehicle ? vehicle.wind : null
    property bool _hasWindDirection:    _wind && !isNaN(_wind.direction.rawValue)
    property bool _hasWindSpeed:        _wind && !isNaN(_wind.speed.rawValue)
    property real _windDirection:       _hasWindDirection ? _wind.direction.rawValue : 0
    property color _accentColor:        "#43b649"
    property string _speedText:         _hasWindSpeed ? (_wind.speed.valueString + " " + _wind.speed.units) : "--"

    anchorPoint.x:  sourceItem.width * 0.72
    anchorPoint.y:  sourceItem.height * 0.5
    visible:        vehicle
                    && vehicle.coordinate.isValid
                    && _flyViewSettings.showWindIndicator.rawValue

    sourceItem: Item {
        width:   ScreenTools.defaultFontPixelWidth * 7.2
        height:  ScreenTools.defaultFontPixelHeight * 2.7

        Item {
            id:             arrowBadge
            width:          ScreenTools.defaultFontPixelHeight * 1.55
            height:         width
            x:              ScreenTools.defaultFontPixelWidth * 0.2
            y:              (parent.height - height) / 2

            Rectangle {
                anchors.centerIn:  parent
                width:             parent.width * 1.18
                height:            width
                radius:            width / 2
                color:             "#28000000"
                y:                 ScreenTools.defaultFontPixelHeight * 0.08
            }

            Rectangle {
                anchors.fill: parent
                radius:       width / 2
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: "#26ffffff" }
                    GradientStop { position: 0.5; color: "#12000000" }
                    GradientStop { position: 1.0; color: "#04000000" }
                }
                border.width: 1
                border.color: "#22ffffff"
            }

            QGCColoredImage {
                anchors.fill:       parent
                anchors.margins:    ScreenTools.defaultFontPixelWidth * 0.26
                anchors.verticalCenterOffset: ScreenTools.defaultFontPixelHeight * 0.06
                source:             "/res/ArrowDown.svg"
                sourceSize.height:  height
                fillMode:           Image.PreserveAspectFit
                color:              "#50000000"
                rotation:           root._hasWindDirection ? (root._windDirection - 180) : 0
                opacity:            root._hasWindDirection ? 0.9 : 0.35
                transformOrigin:    Item.Center
            }

            QGCColoredImage {
                anchors.fill:       parent
                anchors.margins:    ScreenTools.defaultFontPixelWidth * 0.32
                source:             "/res/ArrowDown.svg"
                sourceSize.height:  height
                fillMode:           Image.PreserveAspectFit
                color:              root._accentColor
                rotation:           root._hasWindDirection ? (root._windDirection - 180) : 0
                opacity:            root._hasWindDirection ? 1.0 : 0.45
                transformOrigin:    Item.Center
            }
        }

        Text {
            anchors.left:               arrowBadge.right
            anchors.leftMargin:         ScreenTools.defaultFontPixelWidth * 0.28
            anchors.verticalCenter:     parent.verticalCenter
            anchors.verticalCenterOffset: ScreenTools.defaultFontPixelHeight * 0.08
            color:                      "#50000000"
            text:                       root._speedText
            font.pixelSize:             ScreenTools.defaultFontPixelHeight * 0.76
            font.bold:                  true
        }

        Text {
            anchors.left:               arrowBadge.right
            anchors.leftMargin:         ScreenTools.defaultFontPixelWidth * 0.28
            anchors.verticalCenter:     parent.verticalCenter
            color:                      "white"
            text:                       root._speedText
            font.pixelSize:             ScreenTools.defaultFontPixelHeight * 0.76
            font.bold:                  true
            style:                      Text.Outline
            styleColor:                 "#99000000"
        }
    }
}
