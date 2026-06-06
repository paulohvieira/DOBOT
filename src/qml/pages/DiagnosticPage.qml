/*
    Tela de diagnóstico dos subsistemas.

    Autor:
        Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
*/

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property string dobotStatus
    required property string cameraStatus
    required property string clpStatus
    required property string pailotStatus

    property color surfaceColor: "#ffffff"
    property color borderColor: "#cfd6dd"
    property color textColor: "#1f2933"
    property color mutedTextColor: "#5f6f7f"

    function statusLabel(status) {
        if (status === "connected") {
            return "Conectado"
        }

        if (status === "simulated") {
            return "Simulado"
        }

        if (status === "disabled") {
            return "Desabilitado"
        }

        if (status === "fault") {
            return "Falha"
        }

        if (status === "unavailable") {
            return "Indisponível"
        }

        return "Desconectado"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        Rectangle {
            color: root.surfaceColor
            border.color: root.borderColor
            radius: 8
            Layout.fillWidth: true
            Layout.preferredHeight: 96

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 4

                Text {
                    text: "Diagnóstico"
                    color: root.textColor
                    font.pixelSize: 30
                    font.bold: true
                }

                Text {
                    text: "Leitura operacional dos subsistemas e integrações"
                    color: root.mutedTextColor
                    font.pixelSize: 18
                }
            }
        }

        Rectangle {
            color: root.surfaceColor
            border.color: root.borderColor
            radius: 8
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 14

                DiagnosticRow {
                    subsystem: "DOBOT"
                    status: root.statusLabel(root.dobotStatus)
                    detail: root.dobotStatus === "simulated"
                        ? "MockDobotService em uso"
                        : "Aguardando integração com controlador real"
                    textColor: root.textColor
                    mutedTextColor: root.mutedTextColor
                }

                DiagnosticRow {
                    subsystem: "Câmera"
                    status: root.statusLabel(root.cameraStatus)
                    detail: "Detectada via Qt Multimedia"
                    textColor: root.textColor
                    mutedTextColor: root.mutedTextColor
                }

                DiagnosticRow {
                    subsystem: "CLP"
                    status: root.statusLabel(root.clpStatus)
                    detail: "Controlado pela configuração de integração"
                    textColor: root.textColor
                    mutedTextColor: root.mutedTextColor
                }

                DiagnosticRow {
                    subsystem: "PAILOT"
                    status: root.statusLabel(root.pailotStatus)
                    detail: "Integração ainda não implementada"
                    textColor: root.textColor
                    mutedTextColor: root.mutedTextColor
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }

    component DiagnosticRow: Rectangle {
        required property string subsystem
        required property string status
        required property string detail
        required property color textColor
        required property color mutedTextColor

        color: "transparent"
        border.color: "#cfd6dd"
        radius: 6
        Layout.fillWidth: true
        Layout.preferredHeight: 76

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 16

            Text {
                text: subsystem
                color: textColor
                font.pixelSize: 18
                font.bold: true
                Layout.preferredWidth: 120
            }

            Text {
                text: detail
                color: mutedTextColor
                font.pixelSize: 16
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: status
                color: textColor
                font.pixelSize: 16
                font.bold: true
                horizontalAlignment: Text.AlignRight
                Layout.preferredWidth: 140
            }
        }
    }
}
