import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

ApplicationWindow {
    id: root

    required property QtObject robotViewModel
    required property QtObject cameraViewModel

    property string currentPage: "manual"
    property string protectedAction: ""

    function requestProtectedAction(action) {
        root.protectedAction = action
        passwordDialog.open()
    }

    function executeProtectedAction() {
        if (root.protectedAction === "config") {
            root.currentPage = "config"
        } else if (root.protectedAction === "exit") {
            Qt.quit()
        }

        root.protectedAction = ""
    }

    readonly property real uiScale: Math.min(
        root.width / theme.designWidth,
        root.height / theme.designHeight
    )

    function px(value) {
        return Math.round(value * root.uiScale)
    }

    width: theme.defaultWidth
    height: theme.defaultHeight
    minimumWidth: theme.minimumWidth
    minimumHeight: theme.minimumHeight
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
            Layout.preferredHeight: root.px(theme.headerHeight)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: root.px(theme.spacing)
                anchors.rightMargin: root.px(theme.spacing)
                spacing: root.px(theme.spacing)

                Text {
                    text: "CPQD"
                    color: theme.text
                    font.pixelSize: root.px(28)
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    text: "Controle Dobot Magician"
                    color: theme.mutedText
                    font.pixelSize: root.px(20)
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                }

                Rectangle {
                    width: root.px(14)
                    height: root.px(14)
                    radius: width / 2
                    color: root.robotViewModel.connected ? theme.cpqdTeal : theme.danger
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    text: root.robotViewModel.statusText
                    color: theme.text
                    font.pixelSize: root.px(18)
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
                width: Math.min(root.px(420), parent.width - root.px(2 * theme.spacing))
                spacing: root.px(theme.spacing)

                Text {
                    text: "Sistema de Controle"
                    color: theme.text
                    font.pixelSize: root.px(32)
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                Text {
                    text: root.robotViewModel.statusText
                    color: theme.mutedText
                    font.pixelSize: root.px(20)
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                Button {
                    text: root.robotViewModel.connected ? "Desconectar" : "Conectar"
                    font.pixelSize: root.px(20)
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.px(theme.controlHeight)
                    onClicked: root.robotViewModel.toggleConnection()
                }
            }
        }

        StatusBar {
            dobotConnected: root.robotViewModel.connected
            cameraConnected: root.cameraViewModel.cameraConnected
            clpConnected: false
            pailotConnected: false

            connectedColor: theme.cpqdTeal
            disconnectedColor: theme.danger
            backgroundColor: theme.surface
            borderColor: theme.border
            textColor: theme.text

            Layout.fillWidth: true
        }
    }

    SideDrawer {
        id: sideDrawer

        onManualRequested: root.currentPage = "manual"
        onAutomaticRequested: root.currentPage = "automatic"
        onConfigRequested: root.requestProtectedAction("config")
        onExitRequested: root.requestProtectedAction("exit")
    }

    PasswordDialog {
        id: passwordDialog

        expectedPassword: "3242"
        onPasswordAccepted: root.executeProtectedAction()
    }
}
