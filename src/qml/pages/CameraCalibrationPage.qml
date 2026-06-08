/*
    Tela para calibração de perspectiva da câmera.

    Autor:
        Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Item {
    id: root

    required property bool cameraConnected
    required property QtObject calibrationViewModel

    property color surfaceColor: "#ffffff"
    property color surfaceSecondaryColor: "#eef1f4"
    property color borderColor: "#d8dee4"
    property color textColor: "#101418"
    property color mutedTextColor: "#5f6f7f"
    property color normalColor: "#2f855a"
    property color warningColor: "#d97706"
    property color cameraBackgroundColor: "#101418"
    property color cameraTextColor: "#ffffff"

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        CameraStream {
            cameraConnected: root.cameraConnected
            backgroundColor: root.cameraBackgroundColor
            borderColor: root.borderColor
            textColor: root.cameraTextColor
            mutedTextColor: root.mutedTextColor
            Layout.fillWidth: true
            Layout.fillHeight: true

            onPointSelected: function(x, y) {
                root.calibrationViewModel.selectImagePoint(x, y)
            }
        }

        Rectangle {
            radius: 8
            color: root.surfaceColor
            border.color: root.borderColor
            Layout.preferredWidth: 360
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 14

                Text {
                    text: "Calibração"
                    color: root.textColor
                    font.pixelSize: 28
                    font.bold: true
                    Layout.fillWidth: true
                }

                Text {
                    text: root.calibrationViewModel.statusText
                    color: root.mutedTextColor
                    font.pixelSize: 16
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Rectangle {
                    radius: 6
                    color: root.surfaceSecondaryColor
                    border.color: root.borderColor
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56

                    Text {
                        anchors.centerIn: parent
                        text: root.calibrationViewModel.pendingPointText
                        color: root.textColor
                        font.pixelSize: 18
                    }
                }

                Text {
                    text: "Coordenada real"
                    color: root.textColor
                    font.pixelSize: 20
                    font.bold: true
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true

                    TextField {
                        id: worldXInput

                        placeholderText: "X"
                        font.pixelSize: 18
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                            | Qt.ImhPreferNumbers
                        validator: DoubleValidator {
                            notation: DoubleValidator.StandardNotation
                        }
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                    }

                    TextField {
                        id: worldYInput

                        placeholderText: "Y"
                        font.pixelSize: 18
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                            | Qt.ImhPreferNumbers
                        validator: DoubleValidator {
                            notation: DoubleValidator.StandardNotation
                        }
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                    }
                }

                Button {
                    text: "Adicionar ponto "
                        + root.calibrationViewModel.pointCount
                        + "/4"
                    font.pixelSize: 18
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56

                    onClicked: {
                        const worldX = Number(worldXInput.text.replace(",", "."))
                        const worldY = Number(worldYInput.text.replace(",", "."))

                        if (Number.isNaN(worldX) || Number.isNaN(worldY)) {
                            return
                        }

                        if (root.calibrationViewModel.addCalibrationPoint(
                            worldX,
                            worldY
                        )) {
                            worldXInput.clear()
                            worldYInput.clear()
                        }
                    }
                }

                Text {
                    text: root.calibrationViewModel.pointsSummary
                    color: root.textColor
                    font.pixelSize: 14
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                Item {
                    Layout.fillHeight: true
                }

                Button {
                    text: "Salvar calibração"
                    enabled: root.calibrationViewModel.canSave
                    font.pixelSize: 18
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56

                    onClicked: {
                        root.calibrationViewModel.saveCalibration()
                    }
                }

                Button {
                    text: "Reiniciar pontos"
                    font.pixelSize: 18
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56

                    onClicked: {
                        root.calibrationViewModel.reset()
                        worldXInput.clear()
                        worldYInput.clear()
                    }
                }
            }
        }
    }
}
