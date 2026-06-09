/*
    Tela de alarmes e eventos da HMI.

    Autor:
        Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
*/

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property QtObject alarmViewModel

    property color surfaceColor: "#ffffff"
    property color borderColor: "#cfd6dd"
    property color textColor: "#1f2933"
    property color mutedTextColor: "#5f6f7f"
    property color normalColor: "#2f855a"
    property color warningColor: "#d97706"
    property color dangerColor: "#dc2626"
    property color infoColor: "#2563eb"

    function activeCount() {
        return root.alarmViewModel ? root.alarmViewModel.activeCount : 0
    }

    function alarmItems() {
        return root.alarmViewModel ? root.alarmViewModel.alarms : []
    }

    function priorityColor(priority, active) {
        if (active) {
            return root.dangerColor
        }

        if (priority === "Info") {
            return root.infoColor
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
            Layout.preferredHeight: 96

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20

                ColumnLayout {
                    spacing: 4
                    Layout.fillWidth: true

                    Text {
                        text: "Alarmes"
                        color: root.textColor
                        font.pixelSize: 30
                        font.bold: true
                    }

                    Text {
                        text: "Eventos ativos e condições anormais"
                        color: root.mutedTextColor
                        font.pixelSize: 18
                    }
                }

                Text {
                    text: root.activeCount() + " ativos"
                    color: root.activeCount() > 0
                        ? root.dangerColor
                        : root.normalColor
                    font.pixelSize: 22
                    font.bold: true
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
                spacing: 12

                HeaderRow {
                    textColor: root.mutedTextColor
                }

                ListView {
                    id: alarmList

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 8
                    model: root.alarmItems()

                    delegate: Rectangle {
                        required property var modelData

                        width: alarmList.width
                        height: 76
                        color: "transparent"
                        border.color: root.borderColor
                        radius: 6

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            spacing: 16

                            Rectangle {
                                radius: 5
                                color: root.priorityColor(
                                    modelData.priority,
                                    modelData.active
                                )
                                Layout.preferredWidth: 10
                                Layout.preferredHeight: 10
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Text {
                                text: modelData.timestamp
                                color: root.textColor
                                font.pixelSize: 15
                                Layout.preferredWidth: 160
                            }

                            Text {
                                text: modelData.source
                                color: root.textColor
                                font.pixelSize: 15
                                font.bold: true
                                Layout.preferredWidth: 96
                            }

                            Text {
                                text: modelData.priority
                                color: root.priorityColor(
                                    modelData.priority,
                                    modelData.active
                                )
                                font.pixelSize: 15
                                font.bold: modelData.active
                                Layout.preferredWidth: 80
                            }

                            Text {
                                text: modelData.message
                                color: root.textColor
                                font.pixelSize: 17
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: modelData.state
                                color: modelData.active
                                    ? root.dangerColor
                                    : root.normalColor
                                font.pixelSize: 16
                                font.bold: modelData.active
                                horizontalAlignment: Text.AlignRight
                                Layout.preferredWidth: 96
                            }
                        }
                    }
                }

                Rectangle {
                    color: "transparent"
                    border.color: root.borderColor
                    radius: 6
                    visible: root.alarmItems().length === 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: 72

                    Text {
                        anchors.centerIn: parent
                        text: "Sistema sem alarmes registrados"
                        color: root.mutedTextColor
                        font.pixelSize: 18
                    }
                }
            }
        }
    }

    component HeaderRow: RowLayout {
        required property color textColor

        spacing: 16
        Layout.fillWidth: true

        Text {
            text: "Data/Hora"
            color: textColor
            font.pixelSize: 14
            font.bold: true
            Layout.preferredWidth: 186
        }

        Text {
            text: "Origem"
            color: textColor
            font.pixelSize: 14
            font.bold: true
            Layout.preferredWidth: 96
        }

        Text {
            text: "Prioridade"
            color: textColor
            font.pixelSize: 14
            font.bold: true
            Layout.preferredWidth: 80
        }

        Text {
            text: "Mensagem"
            color: textColor
            font.pixelSize: 14
            font.bold: true
            Layout.fillWidth: true
        }

        Text {
            text: "Estado"
            color: textColor
            font.pixelSize: 14
            font.bold: true
            horizontalAlignment: Text.AlignRight
            Layout.preferredWidth: 100
        }
    }
}
