import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    required property bool dobotConnected
    required property bool cameraConnected
    required property bool clpConnected
    required property bool pailotConnected

    property color connectedColor: "#00d6af"
    property color disconnectedColor: "#d92d20"
    property color backgroundColor: "#ffffff"
    property color borderColor: "#d8dee4"
    property color textColor: "#101418"

    height: 48
    color: root.backgroundColor

    Rectangle {
        anchors.top: parent.top
        width: parent.width
        height: 1
        color: root.borderColor
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 28

        StatusItem {
            label: "DOBOT"
            connected: root.dobotConnected
            connectedColor: root.connectedColor
            disconnectedColor: root.disconnectedColor
            textColor: root.textColor
        }

        StatusItem {
            label: "Câmera"
            connected: root.cameraConnected
            connectedColor: root.connectedColor
            disconnectedColor: root.disconnectedColor
            textColor: root.textColor
        }

        StatusItem {
            label: "CLP"
            connected: root.clpConnected
            connectedColor: root.connectedColor
            disconnectedColor: root.disconnectedColor
            textColor: root.textColor
        }

        StatusItem {
            label: "PAILOT"
            connected: root.pailotConnected
            connectedColor: root.connectedColor
            disconnectedColor: root.disconnectedColor
            textColor: root.textColor
        }

        Item {
            Layout.fillWidth: true
        }
    }

    component StatusItem: RowLayout {
        required property string label
        required property bool connected
        required property color connectedColor
        required property color disconnectedColor
        required property color textColor

        spacing: 8

        Rectangle {
            width: 12
            height: 12
            radius: 6
            color: connected ? connectedColor : disconnectedColor
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: label
            color: textColor
            font.pixelSize: 16
            Layout.alignment: Qt.AlignVCenter
        }
    }
}