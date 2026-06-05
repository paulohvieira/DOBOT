import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Drawer {
    id: root

    signal manualRequested()
    signal automaticRequested()
    signal configRequested()
    signal exitRequested()

    width: 260
    height: parent.height
    edge: Qt.LeftEdge
    modal: true
    interactive: true

    Rectangle {
        anchors.fill: parent
        color: "#ffffff"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Text {
                text: "Menu"
                font.pixelSize: 24
                font.bold: true
                color: "#101418"
                Layout.bottomMargin: 12
            }

            DrawerMenuButton {
                label: "Manual"
                onClicked: {
                    root.close()
                    root.manualRequested()
                }
            }

            DrawerMenuButton {
                label: "Automático"
                onClicked: {
                    root.close()
                    root.automaticRequested()
                }
            }

            DrawerMenuButton {
                label: "Configurações"
                iconSource: "../../assets/lock_24.svg"
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
                onClicked: {
                    root.close()
                    root.exitRequested()
                }
            }
        }
    }
}