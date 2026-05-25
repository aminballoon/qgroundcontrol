import QtQuick

import QGroundControl
import QGroundControl.Controls

Canvas {
    id:                 control
    anchors.centerIn:   parent
    width:              compassSize * 1/3
    height:             width
    antialiasing:       true

    property real compassSize
    property real heading
    property bool simplified:    false

    property var _qgcPal: QGroundControl.globalPalette

    Connections {
        target:                 _qgcPal
        function onGlobalThemeChanged() { control.requestPaint() }
    }

    onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)
        
        // Right side (neon red)
        ctx.fillStyle = "#ff3344"
        ctx.beginPath()
        ctx.moveTo(width / 2, 0)
        ctx.lineTo(width, height)
        ctx.lineTo(width / 2, height * 0.78)
        ctx.closePath()
        ctx.fill()

        // Left side (darker crimson)
        ctx.fillStyle = "#cc1122"
        ctx.beginPath()
        ctx.moveTo(width / 2, 0)
        ctx.lineTo(0, height)
        ctx.lineTo(width / 2, height * 0.78)
        ctx.closePath()
        ctx.fill()

        // Accent line down the middle (thin semi-transparent white)
        ctx.strokeStyle = "rgba(255, 255, 255, 0.4)"
        ctx.lineWidth = 1.5
        ctx.beginPath()
        ctx.moveTo(width / 2, 0)
        ctx.lineTo(width / 2, height * 0.78)
        ctx.stroke()
    }

    transform: Rotation {
        origin.x:   control.width / 2
        origin.y:   control.height / 2
        angle:      heading
    }
}
