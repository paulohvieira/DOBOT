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
    required property QtObject activityMonitor
    required property QtObject cameraViewModel
    required property QtObject configViewModel
    required property QtObject systemControlViewModel
    required property QtObject alarmViewModel
    required property QtObject automaticViewModel
    required property QtObject automaticCameraViewModel
    required property bool kioskMode

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
        } else if (root.protectedAction === "shutdown") {
            shutdownConfirmDialog.open()
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

    function screensaverTimeoutMs() {
        const timeoutSeconds = root.configViewModel
            ? root.configViewModel.screensaverTimeoutSeconds
            : 60

        return Math.max(30000, Math.min(300000, timeoutSeconds * 1000))
    }

    function screensaverEnabled() {
        return root.currentPage !== "automatic"
    }

    function resetScreensaverTimer() {
        if (!root.screensaverEnabled()) {
            inactivityTimer.stop()
            screenSaver.close()
            return
        }

        inactivityTimer.interval = root.screensaverTimeoutMs()
        inactivityTimer.restart()
    }

    width: theme.defaultWidth
    height: theme.defaultHeight
    minimumWidth: theme.minimumWidth
    minimumHeight: theme.minimumHeight
    visible: true
    visibility: root.kioskMode
        ? Window.FullScreen
        : Window.Windowed
    title: "DOBOT CPQD"
    color: theme.background

    AppTheme {
        id: theme
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        HeaderBar {
            uiScale: root.uiScale
            backgroundColor: theme.headerBackground
            textColor: theme.headerText
            mutedTextColor: theme.headerMutedText
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
                alarmViewModel: root.alarmViewModel
                automaticViewModel: root.automaticViewModel
                automaticCameraViewModel: root.automaticCameraViewModel
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
        onShutdownRequested: root.requestProtectedAction("shutdown")
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

    ConfirmationDialog {
        id: shutdownConfirmDialog

        parent: Overlay.overlay
        title: "Desligar Raspberry"
        message: "Tem certeza que deseja fechar a aplicação e desligar a Raspberry Pi?"
        confirmText: "Desligar"
        cancelText: "Cancelar"
        textColor: theme.text
        dangerColor: theme.danger
        keyboardHeight: Qt.inputMethod.visible ? inputPanel.height : 0
        onConfirmed: {
            if (!root.systemControlViewModel.shutdownSystem()) {
                shutdownFeedbackDialog.open()
            }
        }
    }

    Dialog {
        id: shutdownFeedbackDialog

        parent: Overlay.overlay
        title: "Desligamento indisponível"
        modal: true
        standardButtons: Dialog.Ok
        width: 420
        x: parent ? Math.round((parent.width - width) / 2) : 0
        y: parent ? Math.round((parent.height - height) / 2) : 0

        Text {
            text: root.systemControlViewModel
                ? root.systemControlViewModel.message
                : "Não foi possível solicitar o desligamento."
            color: theme.text
            font.pixelSize: 16
            wrapMode: Text.WordWrap
            width: parent ? parent.width : 360
        }
    }

    InputPanel {
        id: inputPanel

        Material.theme: Material.Light
        Material.accent: theme.selection
        Material.primary: theme.selection
        z: 99
        x: 0
        y: Qt.inputMethod.visible ? root.height - height : root.height
        width: root.width
    }

    ScreenSaverOverlay {
        id: screenSaver

        anchors.fill: parent
        onDismissed: root.resetScreensaverTimer()
    }

    Timer {
        id: inactivityTimer

        interval: root.screensaverTimeoutMs()
        running: true
        repeat: false
        onTriggered: {
            if (root.screensaverEnabled()) {
                screenSaver.open()
            }
        }
    }

    Component.onCompleted: {
        VirtualKeyboardSettings.locale = "pt_BR"
        root.resetScreensaverTimer()
    }

    onCurrentPageChanged: root.resetScreensaverTimer()

    Connections {
        target: root.configViewModel

        function onScreensaverTimeoutSecondsChanged() {
            root.resetScreensaverTimer()
        }
    }

    Connections {
        target: root.activityMonitor

        function onActivityDetected() {
            if (screenSaver.visible) {
                screenSaver.close()
                return
            }

            root.resetScreensaverTimer()
        }
    }

    Connections {
        target: root.automaticCameraViewModel

        function onBarrierBreachedChanged() {
            if (!root.alarmViewModel || !root.automaticCameraViewModel) {
                return
            }

            if (root.automaticCameraViewModel.barrierBreached) {
                root.alarmViewModel.logBarrierBreached()
            } else {
                root.alarmViewModel.logBarrierReleased()
            }
        }
    }
}
