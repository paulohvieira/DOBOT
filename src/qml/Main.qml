import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root

    required property QtObject robotViewModel

    width: theme.screenWidth
    height: theme.screenHeight
    minimumWidth: theme.screenWidth
    minimumHeight: theme.screenHeight
    visible: true
    title: "DOBOT CPQD"
    color: theme.background

    AppTheme {
        id: theme
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            color: theme.surface
            Layout.fillWidth: true
            Layout.preferredHeight: theme.headerHeight

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: theme.spacing
                anchors.rightMargin: theme.spacing
                spacing: theme.spacing

                Text {
                    text: "CPQD"
                    color: theme.text
                    font.pixelSize: 28
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    text: "Controle Dobot Magician"
                    color: theme.mutedText
                    font.pixelSize: 20
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                }

                Rectangle {
                    width: 14
                    height: 14
                    radius: 7
                    color: root.robotViewModel.connected ? theme.cpqdTeal : theme.danger
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    text: root.robotViewModel.statusText
                    color: theme.text
                    font.pixelSize: 18
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }

        Rectangle {
            color: theme.background
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.centerIn: parent
                width: 420
                spacing: theme.spacing

                Text {
                    text: "Sistema de Controle"
                    color: theme.text
                    font.pixelSize: 32
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                Text {
                    text: root.robotViewModel.statusText
                    color: theme.mutedText
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                Button {
                    text: root.robotViewModel.connected ? "Desconectar" : "Conectar"
                    font.pixelSize: 20
                    Layout.fillWidth: true
                    Layout.preferredHeight: theme.controlHeight
                    onClicked: root.robotViewModel.toggleConnection()
                }
            }
        }
    }
}
