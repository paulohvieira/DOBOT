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

    function stateColor() {
        if (root.automaticViewModel.state === "running") {
            return root.normalColor
        }

        if (root.automaticViewModel.state === "barrier_stopped") {
            return root.dangerColor
        }

        if (root.automaticViewModel.state === "fault") {
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

                CameraStream {
                    anchors.fill: parent
                    cameraConnected: root.cameraConnected
                    backgroundColor: root.cameraBackgroundColor
                    borderColor: "transparent"
                    textColor: root.cameraTextColor
                    mutedTextColor: root.mutedTextColor
                }

                VirtualBarrierOverlay {
                    anchors.fill: parent
                    breached: root.automaticViewModel.state === "barrier_stopped"
                    barrierOneColor: root.dangerColor
                    barrierTwoColor: root.warningColor
                    breachedFillColor: root.dangerColor
                    visible: root.cameraConnected
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
                                text: root.automaticViewModel.stateText
                                color: root.textColor
                                font.pixelSize: 20
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            Text {
                                text: root.automaticViewModel.message.length > 0
                                    ? root.automaticViewModel.message
                                : "Aguardando comando."
                                color: root.mutedTextColor
                                font.pixelSize: 14
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                Button {
                    text: "Iniciar"
                    enabled: root.automaticViewModel.state !== "running"
                        && root.automaticViewModel.state !== "barrier_stopped"
                    font.pixelSize: 18
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56

                    onClicked: root.automaticViewModel.start()
                }

                Button {
                    text: "Parar"
                    enabled: root.automaticViewModel.state === "running"
                    font.pixelSize: 18
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56

                    onClicked: root.automaticViewModel.stop()
                }

                Button {
                    text: "Simular barreira"
                    enabled: root.automaticViewModel.state === "running"
                    font.pixelSize: 18
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56

                    onClicked: root.automaticViewModel.notifyBarrierBreached()
                }

                Button {
                    text: "Liberar barreira"
                    enabled: root.automaticViewModel.state === "barrier_stopped"
                    font.pixelSize: 18
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56

                    onClicked: root.automaticViewModel.clearBarrierStop()
                }

                Text {
                    text: "A visualização ainda usa a câmera do Qt com sobreposição da barreira. O processamento OpenCV será conectado na próxima etapa."
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
}
