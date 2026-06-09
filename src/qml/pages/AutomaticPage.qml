/*
    Tela de controle inicial do modo automático.

    Autor:
        Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root

    required property QtObject automaticViewModel
    required property QtObject automaticCameraViewModel
    required property bool cameraConnected

    property color surfaceColor: "#ffffff"
    property color surfaceSecondaryColor: "#eef1f4"
    property color borderColor: "#d8dee4"
    property color textColor: "#101418"
    property color mutedTextColor: "#66737d"
    property color normalColor: "#2f855a"
    property color warningColor: "#d97706"
    property color dangerColor: "#dc2626"
    property color infoColor: "#2563eb"
    property color cameraBackgroundColor: "#101418"
    property color cameraTextColor: "#ffffff"

    function automaticState() {
        return root.automaticViewModel ? root.automaticViewModel.state : "stopped"
    }

    function automaticStateText() {
        return root.automaticViewModel
            ? root.automaticViewModel.stateText
            : "Parado"
    }

    function automaticMessage() {
        return root.automaticViewModel
            ? root.automaticViewModel.message
            : ""
    }

    function cameraPreviewRunning() {
        return root.automaticCameraViewModel
            ? root.automaticCameraViewModel.running
            : false
    }

    function cameraPreviewStatusText() {
        return root.automaticCameraViewModel
            ? root.automaticCameraViewModel.statusText
            : "Câmera desconectada."
    }

    function barrierReleaseCountdown() {
        return root.automaticCameraViewModel
            ? root.automaticCameraViewModel.barrierReleaseCountdown
            : 0
    }

    function operationalMessage() {
        if (root.barrierReleaseCountdown() > 0
                && root.automaticState() === "barrier_stopped") {
            return "Liberação automática em "
                + root.barrierReleaseCountdown()
                + "s."
        }

        if (root.automaticMessage().length > 0) {
            return root.automaticMessage()
        }

        return "Modo automático ativo."
    }

    function cameraFrameSource() {
        if (!root.cameraPreviewRunning()) {
            return ""
        }

        return "image://automaticCamera/frame/"
            + root.automaticCameraViewModel.frameRevision
    }

    function stateColor() {
        const state = root.automaticState()

        if (state === "running") {
            return root.normalColor
        }

        if (state === "barrier_stopped") {
            return root.dangerColor
        }

        if (state === "fault") {
            return root.dangerColor
        }

        return root.warningColor
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 16
        radius: 8
        color: root.surfaceColor
        border.color: root.borderColor

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            Rectangle {
                radius: 8
                color: root.cameraBackgroundColor
                border.color: root.borderColor
                Layout.minimumWidth: 620
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                Image {
                    anchors.fill: parent
                    cache: false
                    fillMode: Image.PreserveAspectCrop
                    source: root.cameraFrameSource()
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 8
                    visible: !root.cameraPreviewRunning()

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Câmera desconectada"
                        color: root.cameraTextColor
                        font.pixelSize: 20
                        font.bold: true
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 360
                        horizontalAlignment: Text.AlignHCenter
                        text: root.cameraPreviewStatusText()
                        color: root.mutedTextColor
                        font.pixelSize: 14
                        wrapMode: Text.WordWrap
                    }
                }
            }

            ColumnLayout {
                spacing: 12
                Layout.preferredWidth: 280
                Layout.maximumWidth: 300
                Layout.fillHeight: true

                Text {
                    text: "Modo Automático"
                    color: root.textColor
                    font.pixelSize: 24
                    font.bold: true
                    Layout.fillWidth: true
                }

                Rectangle {
                    radius: 8
                    color: root.surfaceSecondaryColor
                    border.color: root.borderColor
                    Layout.fillWidth: true
                    Layout.preferredHeight: 104

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 12

                        Rectangle {
                            width: 24
                            height: 24
                            radius: 12
                            color: root.stateColor()
                        }

                        ColumnLayout {
                            spacing: 4
                            Layout.fillWidth: true

                            Text {
                                text: root.automaticStateText()
                                color: root.textColor
                                font.pixelSize: 20
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            Text {
                                text: root.operationalMessage()
                                color: root.mutedTextColor
                                font.pixelSize: 14
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                Text {
                    text: root.cameraPreviewStatusText()
                    color: root.mutedTextColor
                    font.pixelSize: 13
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }

    Connections {
        target: root.automaticCameraViewModel

        function onBarrierBreachedChanged() {
            if (root.automaticCameraViewModel
                    && root.automaticCameraViewModel.barrierBreached
                    && root.automaticViewModel
                    && root.automaticState() === "running") {
                root.automaticViewModel.notifyBarrierBreached()
                return
            }

            if (root.automaticCameraViewModel
                    && !root.automaticCameraViewModel.barrierBreached
                    && root.automaticViewModel
                    && root.automaticState() === "barrier_stopped") {
                root.automaticViewModel.clearBarrierStop()
            }
        }
    }

    Component.onCompleted: {
        if (root.automaticCameraViewModel) {
            root.automaticCameraViewModel.startPreview()
        }

        if (root.automaticViewModel) {
            root.automaticViewModel.start()
        }
    }

    Component.onDestruction: {
        if (root.automaticCameraViewModel) {
            root.automaticCameraViewModel.pausePreview()
        }
    }
}
