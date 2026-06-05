import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Drawer {
    id: root

    signal manualRequested()
    signal automaticRequested()
    signal configRequested()
    signal exitRequested()

    property color backgroundColor: "#ffffff"
    property color textColor: "#101418"
    property color hoverColor: "#eef3f4"
    property color pressedColor: "#dfe8ea"

    width: 260
    height: parent.height
    edge: Qt.LeftEdge
    modal: true
    interactive: true

    Rectangle {
        anchors.fill: parent
        color: root.backgroundColor

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Text {
                text: "Menu"
                font.pixelSize: 24
                font.bold: true
                color: root.textColor
                Layout.bottomMargin: 12
            }

            DrawerMenuButton {
                label: "Manual"
                textColor: root.textColor
                hoverColor: root.hoverColor
                pressedColor: root.pressedColor
                onClicked: {
                    root.close()
                    root.manualRequested()
                }
            }

            DrawerMenuButton {
                label: "Automático"
                textColor: root.textColor
                hoverColor: root.hoverColor
                pressedColor: root.pressedColor
                onClicked: {
                    root.close()
                    root.automaticRequested()
                }
            }

            DrawerMenuButton {
                label: "Configurações"
                iconSource: "../../assets/lock_24.svg"
                textColor: root.textColor
                hoverColor: root.hoverColor
                pressedColor: root.pressedColor
                onClicked: {
                    root.close()
                    root.configRequested()
                }
            }

            Item {
                Layout.fillHeight: true
            }

            DrawerMenuButton {
                label: "Sair"
                iconSource: "../../assets/lock_24.svg"
                textColor: root.textColor
                hoverColor: root.hoverColor
                pressedColor: root.pressedColor
                onClicked: {
                    root.close()
                    root.exitRequested()
                }
            }
        }
    }
}
