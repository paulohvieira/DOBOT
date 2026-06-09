import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Drawer {
    id: root

    signal manualRequested()
    signal automaticRequested()
    signal overviewRequested()
    signal alarmsRequested()
    signal diagnosticRequested()
    signal configRequested()
    signal exitRequested()
    signal shutdownRequested()

    property string currentPage: "overview"
    property color backgroundColor: "#ffffff"
    property color textColor: "#101418"
    property color hoverColor: "#eef3f4"
    property color pressedColor: "#dfe8ea"
    property color selectedColor: "#d8f3f6"

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
                label: "Visão Geral"
                selected: root.currentPage === "overview"
                selectedColor: root.selectedColor
                textColor: root.textColor
                hoverColor: root.hoverColor
                pressedColor: root.pressedColor
                onClicked: {
                    root.close()
                    root.overviewRequested()
                }
            }

            DrawerMenuButton {
                label: "Manual"
                enabled: false
                selected: root.currentPage === "manual"
                selectedColor: root.selectedColor
                textColor: root.textColor
                hoverColor: root.hoverColor
                pressedColor: root.pressedColor
            }

            DrawerMenuButton {
                label: "Automático"
                selected: root.currentPage === "automatic"
                selectedColor: root.selectedColor
                textColor: root.textColor
                hoverColor: root.hoverColor
                pressedColor: root.pressedColor
                onClicked: {
                    root.close()
                    root.automaticRequested()
                }
            }

            DrawerMenuButton {
                label: "Alarmes"
                selected: root.currentPage === "alarms"
                selectedColor: root.selectedColor
                textColor: root.textColor
                hoverColor: root.hoverColor
                pressedColor: root.pressedColor
                onClicked: {
                    root.close()
                    root.alarmsRequested()
                }
            }

            DrawerMenuButton {
                label: "Diagnóstico"
                selected: root.currentPage === "diagnostic"
                selectedColor: root.selectedColor
                textColor: root.textColor
                hoverColor: root.hoverColor
                pressedColor: root.pressedColor
                onClicked: {
                    root.close()
                    root.diagnosticRequested()
                }
            }

            DrawerMenuButton {
                label: "Configurações"
                iconSource: "../../assets/lock_24.svg"
                selected: root.currentPage === "config"
                selectedColor: root.selectedColor
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

            DrawerMenuButton {
                label: "Desligar Raspberry"
                iconSource: "../../assets/lock_24.svg"
                textColor: root.textColor
                hoverColor: root.hoverColor
                pressedColor: root.pressedColor
                onClicked: {
                    root.close()
                    root.shutdownRequested()
                }
            }
        }
    }
}
