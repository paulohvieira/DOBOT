import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.VirtualKeyboard
import QtQuick.VirtualKeyboard.Settings
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

        HeaderBar {
            dobotConnected: root.robotViewModel.connected
            robotStatusText: root.robotViewModel.statusText
            uiScale: root.uiScale
            backgroundColor: theme.surface
            textColor: theme.text
            mutedTextColor: theme.mutedText
            connectedColor: theme.cpqdTeal
            disconnectedColor: theme.danger
            headerHeight: theme.headerHeight
            spacing: theme.spacing
            onMenuRequested: sideDrawer.open()
        }

        Rectangle {
            color: theme.background
            Layout.fillWidth: true
            Layout.fillHeight: true

            PageHost {
                anchors.fill: parent
                currentPage: root.currentPage
                cameraConnected: root.cameraViewModel.cameraConnected
                surfaceColor: theme.surface
                borderColor: theme.border
                textColor: theme.text
                mutedTextColor: theme.mutedText
                cameraBackgroundColor: theme.cameraPreviewBackground
                cameraTextColor: theme.cameraPreviewText
                sliderTrackColor: theme.sliderTrack
                sliderFillColor: theme.sliderFill
                sliderHandleColor: theme.sliderHandle
                sliderHandleBorderColor: theme.sliderHandleBorder
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

        backgroundColor: theme.surface
        textColor: theme.text
        hoverColor: theme.drawerHover
        pressedColor: theme.drawerPressed
        onManualRequested: root.currentPage = "manual"
        onAutomaticRequested: root.currentPage = "automatic"
        onConfigRequested: root.requestProtectedAction("config")
        onExitRequested: root.requestProtectedAction("exit")
    }

    PasswordDialog {
        id: passwordDialog

        parent: Overlay.overlay
        expectedPassword: "3242"
        textColor: theme.text
        dangerColor: theme.danger
        keyboardHeight: Qt.inputMethod.visible ? inputPanel.height : 0
        onPasswordAccepted: root.executeProtectedAction()
    }

    InputPanel {
        id: inputPanel

        z: 99
        x: 0
        y: Qt.inputMethod.visible ? root.height - height : root.height
        width: root.width
    }

    Component.onCompleted: {
        VirtualKeyboardSettings.locale = "pt_BR"
    }
}
