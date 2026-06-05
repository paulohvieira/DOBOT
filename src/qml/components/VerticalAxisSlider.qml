/*
    Controle vertical reutilizável para ajuste de eixo.

    Autor:
        Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
*/

import QtQuick
import QtQuick.Controls
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

    radius: 8
    color: root.backgroundColor
    border.color: root.borderColor

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        Text {
            text: root.axisLabel
            color: root.textColor
            font.pixelSize: 22
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        Slider {
            id: slider

            from: root.from
            to: root.to
            value: root.value
            orientation: Qt.Vertical
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter

            onMoved: root.valueEdited(slider.value)
        }

        Text {
            text: slider.value.toFixed(1)
            color: root.textColor
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }
    }
}