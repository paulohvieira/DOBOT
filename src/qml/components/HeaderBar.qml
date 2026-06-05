/*
    Barra superior da aplicação com acesso ao drawer e estado principal.

    Autor:
        Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    signal menuRequested()

    required property bool dobotConnected
    required property string robotStatusText
    required property real uiScale

    property color backgroundColor: "#ffffff"
    property color textColor: "#101418"
    property color mutedTextColor: "#66737d"
    property color connectedColor: "#00d6af"
    property color disconnectedColor: "#d92d20"
    property int headerHeight: 72
    property int spacing: 16

    function px(value) {
        return Math.round(value * root.uiScale)
    }

    color: root.backgroundColor
    Layout.fillWidth: true
    Layout.preferredHeight: root.px(root.headerHeight)

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: root.px(root.spacing)
        anchors.rightMargin: root.px(root.spacing)
        spacing: root.px(root.spacing)

        Button {
            text: "☰"
            font.pixelSize: root.px(24)
            Layout.preferredWidth: root.px(56)
            Layout.preferredHeight: root.px(48)
            Layout.alignment: Qt.AlignVCenter
            onClicked: root.menuRequested()
        }

        Text {
            text: "CPQD"
            color: root.textColor
            font.pixelSize: root.px(28)
            font.bold: true
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: "Controle Dobot Magician"
            color: root.mutedTextColor
            font.pixelSize: root.px(20)
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
        }

        Rectangle {
            width: root.px(14)
            height: root.px(14)
            radius: width / 2
            color: root.dobotConnected
                ? root.connectedColor
                : root.disconnectedColor
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: root.robotStatusText
            color: root.textColor
            font.pixelSize: root.px(18)
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
