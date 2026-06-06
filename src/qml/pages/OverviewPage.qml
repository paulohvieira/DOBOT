/*
    Tela de visão geral operacional alinhada à filosofia ISA-101.

    Autor:
        Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
*/

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property string operationMode
    required property string dobotStatus
    required property string cameraStatus
    required property string clpStatus
    required property string pailotStatus

    property color surfaceColor: "#ffffff"
    property color surfaceSecondaryColor: "#eef1f4"
    property color borderColor: "#cfd6dd"
    property color textColor: "#1f2933"
    property color mutedTextColor: "#5f6f7f"
    property color normalColor: "#2f855a"
    property color warningColor: "#d97706"
    property color dangerColor: "#dc2626"
    property color disabledColor: "#8a97a3"
    property color unavailableColor: "#6b7280"
    property color infoColor: "#2563eb"

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

    function statusColor(status) {
        if (status === "connected") {
            return root.normalColor
        }

        if (status === "simulated") {
            return root.infoColor
        }

        if (status === "disabled") {
            return root.disabledColor
        }

        if (status === "fault") {
            return root.dangerColor
        }

        if (status === "unavailable") {
            return root.unavailableColor
        }

        return root.warningColor
    }

    function overallState() {
        if (root.dobotStatus === "fault"
                || root.cameraStatus === "fault"
                || root.clpStatus === "fault"
                || root.pailotStatus === "fault") {
            return "Falha"
        }

        if (root.dobotStatus === "simulated") {
            return "Simulado"
        }

        if (root.dobotStatus === "connected") {
            return "Pronto"
        }

        return "Bloqueado"
    }

    function overallColor() {
        const state = overallState()

        if (state === "Pronto") {
            return root.normalColor
        }

        if (state === "Simulado") {
            return root.infoColor
        }

        if (state === "Falha") {
            return root.dangerColor
        }

        return root.warningColor
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
            Layout.preferredHeight: 116

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                ColumnLayout {
                    spacing: 4
                    Layout.fillWidth: true

                    Text {
                        text: "Visão Geral"
                        color: root.textColor
                        font.pixelSize: 30
                        font.bold: true
                    }

                    Text {
                        text: "Modo atual: " + root.operationMode
                        color: root.mutedTextColor
                        font.pixelSize: 18
                    }
                }

                Rectangle {
                    radius: 6
                    color: root.overallColor()
                    Layout.preferredWidth: 160
                    Layout.preferredHeight: 52

                    Text {
                        anchors.centerIn: parent
                        text: root.overallState()
                        color: "#ffffff"
                        font.pixelSize: 20
                        font.bold: true
                    }
                }
            }
        }

        GridLayout {
            columns: 4
            columnSpacing: 16
            rowSpacing: 16
            Layout.fillWidth: true

            StatusPanel {
                title: "DOBOT"
                value: root.statusLabel(root.dobotStatus)
                detail: root.dobotStatus === "simulated"
                    ? "Serviço mockado em uso"
                    : "Controlador principal"
                statusColor: root.statusColor(root.dobotStatus)
                surfaceColor: root.surfaceColor
                borderColor: root.borderColor
                textColor: root.textColor
                mutedTextColor: root.mutedTextColor
                Layout.fillWidth: true
            }

            StatusPanel {
                title: "Câmera"
                value: root.statusLabel(root.cameraStatus)
                detail: "Captura de imagem"
                statusColor: root.statusColor(root.cameraStatus)
                surfaceColor: root.surfaceColor
                borderColor: root.borderColor
                textColor: root.textColor
                mutedTextColor: root.mutedTextColor
                Layout.fillWidth: true
            }

            StatusPanel {
                title: "CLP"
                value: root.statusLabel(root.clpStatus)
                detail: "Integração externa"
                statusColor: root.statusColor(root.clpStatus)
                surfaceColor: root.surfaceColor
                borderColor: root.borderColor
                textColor: root.textColor
                mutedTextColor: root.mutedTextColor
                Layout.fillWidth: true
            }

            StatusPanel {
                title: "PAILOT"
                value: root.statusLabel(root.pailotStatus)
                detail: "Serviço indisponível"
                statusColor: root.statusColor(root.pailotStatus)
                surfaceColor: root.surfaceColor
                borderColor: root.borderColor
                textColor: root.textColor
                mutedTextColor: root.mutedTextColor
                Layout.fillWidth: true
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

                Text {
                    text: "Resumo operacional"
                    color: root.textColor
                    font.pixelSize: 22
                    font.bold: true
                }

                InfoRow {
                    label: "Alarmes ativos"
                    value: "0"
                    valueColor: root.normalColor
                    textColor: root.textColor
                    mutedTextColor: root.mutedTextColor
                }

                InfoRow {
                    label: "Último comando"
                    value: "Nenhum comando executado nesta sessão"
                    valueColor: root.mutedTextColor
                    textColor: root.textColor
                    mutedTextColor: root.mutedTextColor
                }

                InfoRow {
                    label: "Permissivo de movimento"
                    value: root.dobotStatus === "connected" ? "Liberado" : "Bloqueado"
                    valueColor: root.dobotStatus === "connected"
                        ? root.normalColor
                        : root.warningColor
                    textColor: root.textColor
                    mutedTextColor: root.mutedTextColor
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }

    component StatusPanel: Rectangle {
        required property string title
        required property string value
        required property string detail
        required property color statusColor
        required property color surfaceColor
        required property color borderColor
        required property color textColor
        required property color mutedTextColor

        color: surfaceColor
        border.color: borderColor
        radius: 8
        Layout.preferredHeight: 128

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: title
                    color: textColor
                    font.pixelSize: 18
                    font.bold: true
                    Layout.fillWidth: true
                }

                Rectangle {
                    radius: 6
                    color: statusColor
                    Layout.preferredWidth: 12
                    Layout.preferredHeight: 12
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            Text {
                text: value
                color: statusColor
                font.pixelSize: 22
                font.bold: true
            }

            Text {
                text: detail
                color: mutedTextColor
                font.pixelSize: 14
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
    }

    component InfoRow: RowLayout {
        required property string label
        required property string value
        required property color valueColor
        required property color textColor
        required property color mutedTextColor

        spacing: 16
        Layout.fillWidth: true

        Text {
            text: label
            color: mutedTextColor
            font.pixelSize: 18
            Layout.preferredWidth: 220
        }

        Text {
            text: value
            color: valueColor
            font.pixelSize: 18
            font.bold: true
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }
}
