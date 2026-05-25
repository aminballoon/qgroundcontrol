import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlyView

Item {
    required property var guidedValueSlider
    property var widgetLayer: null

    id:     control
    anchors.left:   parent.left
    anchors.right:  parent.right
    anchors.top:    parent.top
    height: ScreenTools.toolbarHeight

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property bool   _communicationLost: _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false
    property color  _mainStatusBGColor: qgcPal.brandingPurple
    property real   _leftRightMargin:   ScreenTools.defaultFontPixelWidth * 0.75
    property var    _guidedController:  globals.guidedControllerFlyView

    function dropMainStatusIndicatorTool() {
        mainStatusIndicator.dropMainStatusIndicator();
    }

    QGCPalette { id: qgcPal }

    // Dark glassmorphic toolbar background — always dark regardless of system theme
    Rectangle {
        anchors.fill:   parent
        color:          Qt.rgba(0.08, 0.08, 0.14, 0.92)
        border.width:   1
        border.color:   Qt.rgba(1, 1, 1, 0.12)

        // Subtle bottom border glow line
        Rectangle {
            anchors.left:   parent.left
            anchors.right:  parent.right
            anchors.bottom: parent.bottom
            height:         1
            color:          Qt.rgba(0.42, 0.88, 0.84, 0.25)
        }
    }

    QGCFlickable {
        anchors.fill:       parent
        anchors.leftMargin:   ScreenTools.defaultFontPixelWidth
        anchors.rightMargin:  ScreenTools.defaultFontPixelWidth
        anchors.topMargin:    2
        anchors.bottomMargin: 2
        contentWidth:       toolBarLayout.width
        flickableDirection: Flickable.HorizontalFlick

        Row {
            id:         toolBarLayout
            height:     parent.height
            spacing:    0

            // ── LEFT PANEL: Logo + Name + Status ──────────────────────
            Item {
                id:     leftPanel
                width:  leftPanelLayout.implicitWidth
                height: parent.height

                RowLayout {
                    id:         leftPanelLayout
                    height:     parent.height
                    spacing:    ScreenTools.defaultFontPixelWidth * 1.5

                    // Logo + "QGroundControl" branding
                    RowLayout {
                        spacing:            ScreenTools.defaultFontPixelWidth * 0.75
                        Layout.fillHeight:  true

                        QGCToolBarButton {
                            id:                 qgcButton
                            objectName:         "toolbar_qgcLogo"
                            Layout.fillHeight:  true
                            icon.source:        "/res/QGCLogoFull.svg"
                            logo:               true
                            onClicked:          mainWindow.showToolSelectDialog()
                        }

                        QGCLabel {
                            text:               qsTr("QGroundControl")
                            color:              "#ffffff"
                            font.pointSize:     ScreenTools.defaultFontPointSize
                            font.bold:          true
                            anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                            Layout.alignment:   Qt.AlignVCenter
                        }
                    }

                    // Separator
                    Rectangle {
                        width:              1
                        height:             parent.height * 0.55
                        color:              Qt.rgba(1, 1, 1, 0.15)
                        Layout.alignment:   Qt.AlignVCenter
                    }

                    // Connection Status Pill + Flight Mode
                    RowLayout {
                        id:         mainStatusLayout
                        height:     parent.height
                        spacing:    ScreenTools.defaultFontPixelWidth * 1.5
                        Layout.alignment: Qt.AlignVCenter

                        MainStatusIndicator {
                            id:                 mainStatusIndicator
                            Layout.fillHeight:  true
                        }

                        QGCButton {
                            id:         disconnectButton
                            text:       qsTr("Disconnect")
                            onClicked:  _activeVehicle.closeVehicle()
                            visible:    _activeVehicle && _communicationLost
                        }

                        FlightModeIndicator {
                            Layout.fillHeight:  true
                            visible:            _activeVehicle
                        }
                    }
                }
            }

            // ── CENTER PANEL: Guided action confirm ───────────────────
            Item {
                id:     centerPanel
                width:  Math.max(guidedActionConfirm.visible ? guidedActionConfirm.width : 0, control.width - (leftPanel.width + rightPanel.width))
                height: parent.height

                GuidedActionConfirm {
                    id:                         guidedActionConfirm
                    height:                     parent.height
                    anchors.horizontalCenter:   parent.horizontalCenter
                    guidedController:           control._guidedController
                    guidedValueSlider:          control.guidedValueSlider
                    messageDisplay:             guidedActionMessageDisplay
                }
            }

            // ── RIGHT PANEL: All telemetry indicators & config toggle ──
            Item {
                id:     rightPanel
                width:  rightPanelRow.width
                height: parent.height

                Row {
                    id:             rightPanelRow
                    height:         parent.height
                    spacing:        ScreenTools.defaultFontPixelWidth * 1.5

                    FlyViewToolBarIndicators {
                        id:     flyViewIndicators
                        height: parent.height
                    }

                    // Separator/Divider
                    Rectangle {
                        width:              1
                        height:             parent.height * 0.55
                        color:              Qt.rgba(1, 1, 1, 0.15)
                        anchors.verticalCenter: parent.verticalCenter
                        visible:            control.widgetLayer !== null
                    }

                    // Config UI toggle button
                    Rectangle {
                        id:                 configToggleBtn
                        width:              ScreenTools.defaultFontPixelHeight * 2.2
                        height:             width
                        radius:             8
                        color:              checked ? Qt.rgba(107, 226, 214, 0.12) : Qt.rgba(255, 255, 255, 0.05)
                        border.width:       1
                        border.color:       checked ? "#6be2d6" : Qt.rgba(255, 255, 255, 0.15)
                        anchors.verticalCenter: parent.verticalCenter

                        property bool checked: control.widgetLayer ? control.widgetLayer.showRightTelemetryPanel : true

                        QGCColoredImage {
                            anchors.centerIn: parent
                            width:            ScreenTools.defaultFontPixelHeight * 1.2
                            height:           width
                            source:           "/res/icon_settings.svg"
                            color:            configToggleBtn.checked ? "#6be2d6" : "#ffffff"
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered:    configToggleBtn.border.color = "#6be2d6"
                            onExited:     configToggleBtn.border.color = configToggleBtn.checked ? "#6be2d6" : Qt.rgba(255, 255, 255, 0.15)
                            onClicked: {
                                if (control.widgetLayer) {
                                    control.widgetLayer.showRightTelemetryPanel = !control.widgetLayer.showRightTelemetryPanel
                                }
                            }
                        }
                    }

                    // Spacer at the end to prevent sticking to the edge
                    Item {
                        width:              ScreenTools.defaultFontPixelWidth * 0.5
                        height:             1
                    }
                }
            }
        }
    }

    // Guided action message display — outside Flickable
    Rectangle {
        id:                         guidedActionMessageDisplay
        anchors.top:                control.bottom
        anchors.topMargin:          ScreenTools.defaultFontPixelWidth
        x:                          control.mapFromItem(guidedActionConfirm.parent, guidedActionConfirm.x, 0).x + (guidedActionConfirm.width - guidedActionMessageDisplay.width) / 2
        width:                      messageLabel.contentWidth + (ScreenTools.defaultFontPixelWidth * 2)
        height:                     messageLabel.contentHeight + (ScreenTools.defaultFontPixelWidth * 2)
        color:                      Qt.rgba(0.08, 0.08, 0.14, 0.92)
        radius:                     ScreenTools.defaultBorderRadius
        border.width:               1
        border.color:               Qt.rgba(1, 1, 1, 0.2)
        visible:                    guidedActionConfirm.visible

        QGCLabel {
            id:         messageLabel
            x:          ScreenTools.defaultFontPixelWidth
            y:          ScreenTools.defaultFontPixelWidth
            width:      ScreenTools.defaultFontPixelWidth * 30
            wrapMode:   Text.WordWrap
            text:       guidedActionConfirm.message
            color:      "#ffffff"
        }

        PropertyAnimation {
            id:         messageOpacityAnimation
            target:     guidedActionMessageDisplay
            property:   "opacity"
            from:       1
            to:         0
            duration:   500
        }

        Timer {
            id:             messageFadeTimer
            interval:       4000
            onTriggered:    messageOpacityAnimation.start()
        }
    }

    ParameterDownloadProgress {
        anchors.fill: parent
    }
}
