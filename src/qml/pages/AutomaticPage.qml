/*
    Tela de controle inicial do modo automático.

    Autor:
        Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property QtObject automaticViewModel

    property color surfaceColor: "#ffffff"
    property color surfaceSecondaryColor: "#eef1f4"
    property color borderColor: "#d8dee4"
    property color textColor: "#101418"
    property color mutedTextColor: "#66737d"
    property color normalColor: "#2f855a"
    property color warningColor: "#d97706"
    property color dangerColor: "#dc2626"
    property color infoColor: "#2563eb"

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

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 18

            Text {
                text: "Modo Automático"
                color: root.textColor
                font.pixelSize: 30
                font.bold: true
                Layout.fillWidth: true
            }

            Rectangle {
                radius: 8
                color: root.surfaceSecondaryColor
                border.color: root.borderColor
                Layout.fillWidth: true
                Layout.preferredHeight: 96

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 16

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: root.stateColor()
                    }

                    ColumnLayout {
                        spacing: 4
                        Layout.fillWidth: true

                        Text {
                            text: root.automaticViewModel.stateText
                            color: root.textColor
                            font.pixelSize: 24
                            font.bold: true
                            Layout.fillWidth: true
                        }

                        Text {
                            text: root.automaticViewModel.message.length > 0
                                ? root.automaticViewModel.message
                                : "Aguardando comando."
                            color: root.mutedTextColor
                            font.pixelSize: 16
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            GridLayout {
                columns: 2
                columnSpacing: 16
                rowSpacing: 16
                Layout.fillWidth: true

                Button {
                    text: "Iniciar"
                    enabled: root.automaticViewModel.state !== "running"
                        && root.automaticViewModel.state !== "barrier_stopped"
                    font.pixelSize: 20
                    Layout.fillWidth: true
                    Layout.preferredHeight: 72

                    onClicked: root.automaticViewModel.start()
                }

                Button {
                    text: "Parar"
                    enabled: root.automaticViewModel.state === "running"
                    font.pixelSize: 20
                    Layout.fillWidth: true
                    Layout.preferredHeight: 72

                    onClicked: root.automaticViewModel.stop()
                }

                Button {
                    text: "Simular barreira"
                    enabled: root.automaticViewModel.state === "running"
                    font.pixelSize: 20
                    Layout.fillWidth: true
                    Layout.preferredHeight: 72

                    onClicked: root.automaticViewModel.notifyBarrierBreached()
                }

                Button {
                    text: "Liberar barreira"
                    enabled: root.automaticViewModel.state === "barrier_stopped"
                    font.pixelSize: 20
                    Layout.fillWidth: true
                    Layout.preferredHeight: 72

                    onClicked: root.automaticViewModel.clearBarrierStop()
                }
            }

            Text {
                text: "Este controle ainda não executa o robô real."
                color: root.mutedTextColor
                font.pixelSize: 16
                Layout.fillWidth: true
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
