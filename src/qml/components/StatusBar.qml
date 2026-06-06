import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    required property string dobotStatus
    required property string cameraStatus
    required property string clpStatus
    required property string pailotStatus

    property color normalColor: "#2f855a"
    property color warningColor: "#d97706"
    property color dangerColor: "#dc2626"
    property color infoColor: "#2563eb"
    property color disabledColor: "#8a97a3"
    property color unavailableColor: "#6b7280"
    property color backgroundColor: "#ffffff"
    property color borderColor: "#d8dee4"
    property color textColor: "#101418"
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

    height: 32
    color: root.backgroundColor

    Rectangle {
        anchors.top: parent.top
        width: parent.width
        height: 1
        color: root.borderColor
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 28

        StatusItem {
            label: "DOBOT"
            statusText: root.statusLabel(root.dobotStatus)
            statusColor: root.statusColor(root.dobotStatus)
            textColor: root.textColor
            mutedTextColor: root.mutedTextColor
        }

        StatusItem {
            label: "Câmera"
            statusText: root.statusLabel(root.cameraStatus)
            statusColor: root.statusColor(root.cameraStatus)
            textColor: root.textColor
            mutedTextColor: root.mutedTextColor
        }

        StatusItem {
            label: "CLP"
            statusText: root.statusLabel(root.clpStatus)
            statusColor: root.statusColor(root.clpStatus)
            textColor: root.textColor
            mutedTextColor: root.mutedTextColor
        }

        StatusItem {
            label: "PAILOT"
            statusText: root.statusLabel(root.pailotStatus)
            statusColor: root.statusColor(root.pailotStatus)
            textColor: root.textColor
            mutedTextColor: root.mutedTextColor
        }

        Item {
            Layout.fillWidth: true
        }
    }

    component StatusItem: RowLayout {
        required property string label
        required property string statusText
        required property color statusColor
        required property color textColor
        required property color mutedTextColor

        spacing: 8

        Rectangle {
            radius: 6
            color: statusColor
            Layout.preferredWidth: 12
            Layout.preferredHeight: 12
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: label + ":"
            color: mutedTextColor
            font.pixelSize: 15
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: statusText
            color: textColor
            font.pixelSize: 15
            font.bold: true
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
