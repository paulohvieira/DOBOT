import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.VirtualKeyboard
import QtQuick.VirtualKeyboard.Settings
import QtQuick.Controls.Material
import "components"

ApplicationWindow {
    id: root
    Material.theme: Material.Light
    Material.accent: theme.selection
    Material.primary: theme.selection
    required property QtObject robotViewModel
    required property QtObject cameraViewModel
    required property QtObject configViewModel
    required property QtObject calibrationViewModel

    property string currentPage: "overview"
    property string protectedAction: ""

    readonly property string dobotStatus: root.robotViewModel && root.robotViewModel.connected
        ? "simulated"
        : "disconnected"
    readonly property string cameraStatus: root.cameraViewModel && root.cameraViewModel.cameraConnected
        ? "connected"
        : "disconnected"
    readonly property string clpStatus: root.configViewModel && root.configViewModel.clpEnabled
        ? "disconnected"
        : "disabled"
    readonly property string pailotStatus: "unavailable"

    function operationModeLabel() {
        if (root.currentPage === "manual") {
            return "Manual"
        }

        if (root.currentPage === "automatic") {
            return "Automático"
        }

        if (root.currentPage === "config") {
            return "Configuração"
        }

        if (root.currentPage === "cameraCalibration") {
            return "Calibração"
        }

        if (root.currentPage === "alarms") {
            return "Alarmes"
        }

        if (root.currentPage === "diagnostic") {
            return "Diagnóstico"
        }

        return "Visão Geral"
    }

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
            dobotConnected: root.robotViewModel
                ? root.robotViewModel.connected
                : false
            robotStatusText: root.robotViewModel
                ? root.dobotStatus === "simulated"
                    ? "Simulado"
                    : root.robotViewModel.statusText
                : "Desconectado"
            uiScale: root.uiScale
            backgroundColor: theme.headerBackground
            textColor: theme.headerText
            mutedTextColor: theme.headerMutedText
            connectedColor: theme.normal
            disconnectedColor: theme.danger
            menuButtonBackgroundColor: theme.menuButtonBackground
            menuButtonPressedColor: theme.menuButtonPressed
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
                cameraConnected: root.cameraViewModel
                    ? root.cameraViewModel.cameraConnected
                    : false
                configViewModel: root.configViewModel
                calibrationViewModel: root.calibrationViewModel
                operationMode: root.operationModeLabel()
                dobotStatus: root.dobotStatus
                cameraStatus: root.cameraStatus
                clpStatus: root.clpStatus
                pailotStatus: root.pailotStatus
                surfaceColor: theme.surface
                surfaceSecondaryColor: theme.surfaceSecondary
                borderColor: theme.border
                textColor: theme.text
                mutedTextColor: theme.mutedText
                normalColor: theme.normal
                warningColor: theme.warning
                dangerColor: theme.danger
                disabledColor: theme.disabled
                unavailableColor: theme.unavailable
                infoColor: theme.info
                cameraBackgroundColor: theme.cameraPreviewBackground
                cameraTextColor: theme.cameraPreviewText
                sliderBackgroundColor: theme.sliderBackground
                sliderBorderColor: theme.sliderBorder
                sliderTrackColor: theme.sliderTrack
                sliderFillColor: theme.sliderFill
                sliderHandleColor: theme.sliderHandle
                sliderHandleBorderColor: theme.sliderHandleBorder
                onCameraCalibrationRequested: {
                    root.currentPage = "cameraCalibration"
                }
            }
        }

        StatusBar {
            dobotStatus: root.dobotStatus
            cameraStatus: root.cameraStatus
            clpStatus: root.clpStatus
            pailotStatus: root.pailotStatus

            normalColor: theme.normal
            warningColor: theme.warning
            dangerColor: theme.danger
            infoColor: theme.info
            disabledColor: theme.disabled
            unavailableColor: theme.unavailable
            backgroundColor: theme.surface
            borderColor: theme.border
            textColor: theme.text
            mutedTextColor: theme.mutedText

            Layout.fillWidth: true
        }
    }

    SideDrawer {
        id: sideDrawer

        backgroundColor: theme.surface
        textColor: theme.text
        hoverColor: theme.drawerHover
        pressedColor: theme.drawerPressed
        selectedColor: theme.selectionSoft
        currentPage: root.currentPage
        onOverviewRequested: root.currentPage = "overview"
        onManualRequested: root.currentPage = "manual"
        onAutomaticRequested: root.currentPage = "automatic"
        onAlarmsRequested: root.currentPage = "alarms"
        onDiagnosticRequested: root.currentPage = "diagnostic"
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
