/*
    Controle vertical reutilizável para ajuste de eixo em tela touch.

    Autor:
        Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
*/

import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    signal valueEdited(real value)

    required property string axisLabel

    property real from: 0
    property real to: 100
    property real value: 0
    property color backgroundColor: "#ffffff"
    property color borderColor: "#d8dee4"
    property color textColor: "#101418"
    property color trackColor: "#d8dee4"
    property color fillColor: "#00d6af"
    property color handleColor: "#101418"
    property color handleBorderColor: "#ffffff"

    radius: 8
    color: root.backgroundColor
    border.color: root.borderColor

    function normalizedValue() {
        if (root.to === root.from) {
            return 0
        }

        return (root.value - root.from) / (root.to - root.from)
    }

    function valueFromY(positionY) {
        const trackTop = sliderTrack.y
        const trackHeight = sliderTrack.height
        const clampedY = Math.max(trackTop, Math.min(positionY, trackTop + trackHeight))
        const normalized = 1 - ((clampedY - trackTop) / trackHeight)

        return root.from + normalized * (root.to - root.from)
    }

    function updateValueFromY(positionY) {
        root.value = valueFromY(positionY)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        Text {
            text: root.axisLabel
            color: root.textColor
            font.pixelSize: 24
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        Item {
            id: touchArea

            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                id: sliderTrack

                width: 28
                radius: width / 2
                color: root.trackColor
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: parent.height * root.normalizedValue()
                    radius: parent.radius
                    color: root.fillColor
                }
            }

            Rectangle {
                id: handle

                width: 64
                height: 64
                radius: 32
                color: root.handleColor
                border.color: root.handleBorderColor
                border.width: 3
                anchors.horizontalCenter: sliderTrack.horizontalCenter
                y: sliderTrack.y
                    + sliderTrack.height * (1 - root.normalizedValue())
                    - height / 2
            }

        MouseArea {
            anchors.fill: parent

            onPressed: function(mouse) {
                root.updateValueFromY(mouse.y)
            }

            onPositionChanged: function(mouse) {
                if (pressed) {
                    root.updateValueFromY(mouse.y)
                }
            }

            onReleased: function(mouse) {
                root.valueEdited(root.value)
            }

            onCanceled: function() {
                root.valueEdited(root.value)
            }
        }
        }

        Text {
            text: root.value.toFixed(1)
            color: root.textColor
            font.pixelSize: 18
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }
    }
}
