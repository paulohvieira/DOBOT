/*
    Tela de alarmes e eventos da HMI.

    Autor:
        Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
*/

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property color surfaceColor: "#ffffff"
    property color borderColor: "#cfd6dd"
    property color textColor: "#1f2933"
    property color mutedTextColor: "#5f6f7f"
    property color normalColor: "#2f855a"
    property color infoColor: "#2563eb"

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
                    text: "0 ativos"
                    color: root.normalColor
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

                Rectangle {
                    color: "transparent"
                    border.color: root.borderColor
                    radius: 6
                    Layout.fillWidth: true
                    Layout.preferredHeight: 72

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 16

                        Rectangle {
                            radius: 5
                            color: root.normalColor
                            Layout.preferredWidth: 10
                            Layout.preferredHeight: 10
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Text {
                            text: "Sistema sem alarmes ativos"
                            color: root.textColor
                            font.pixelSize: 18
                            font.bold: true
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "Normal"
                            color: root.normalColor
                            font.pixelSize: 16
                        }
                    }
                }

                Text {
                    text: "A estrutura desta tela está preparada para receber prioridade, origem, data/hora, reconhecimento e mensagem de ação quando o AlarmViewModel for implementado."
                    color: root.mutedTextColor
                    font.pixelSize: 16
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }

    component HeaderRow: RowLayout {
        required property color textColor

        spacing: 16
        Layout.fillWidth: true

        Text {
            text: "Prioridade"
            color: textColor
            font.pixelSize: 14
            font.bold: true
            Layout.preferredWidth: 120
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
