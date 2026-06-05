/*
    Tela de operação manual do Dobot Magician.

    Autor:
        Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
*/

import QtQuick
import QtQuick.Layouts
import "../components"

Item {
    id: root

    required property bool cameraConnected

    property color surfaceColor: "#ffffff"
    property color borderColor: "#d8dee4"
    property color textColor: "#101418"

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        CameraStream {
            cameraConnected: root.cameraConnected
            borderColor: root.borderColor
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        VerticalAxisSlider {
            axisLabel: "Z"
            from: -100
            to: 100
            value: 0
            backgroundColor: root.surfaceColor
            borderColor: root.borderColor
            textColor: root.textColor
            Layout.preferredWidth: 96
            Layout.fillHeight: true

            onValueEdited: function(value) {
                console.log("Z:", value)
            }
        }
    }
}