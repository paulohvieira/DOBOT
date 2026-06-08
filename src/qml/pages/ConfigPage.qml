/*
    Tela de configurações persistidas da aplicação.

    Autor:
        Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    signal cameraCalibrationRequested()

    required property QtObject configViewModel

    property color surfaceColor: "#ffffff"
    property color borderColor: "#d8dee4"
    property color textColor: "#101418"
    property color normalColor: "#2f855a"
    property color warningColor: "#d97706"

    Rectangle {
        anchors.fill: parent
        anchors.margins: 16
        radius: 8
        color: root.surfaceColor
        border.color: root.borderColor

        ScrollView {
            id: scrollView

            anchors.fill: parent
            anchors.margins: 24
            clip: true

            ColumnLayout {
                width: scrollView.availableWidth
                spacing: 18

                Text {
                    text: "Configurações"
                    color: root.textColor
                    font.pixelSize: 30
                    font.bold: true
                    Layout.fillWidth: true
                }

                Text {
                    text: "Movimento"
                    color: root.textColor
                    font.pixelSize: 22
                    font.bold: true
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "Passo do eixo Z"
                        font.pixelSize: 18
                        Layout.fillWidth: true
                    }

                    SpinBox {
                        id: zStepInput

                        from: 5
                        to: 10000
                        stepSize: 5
                        value: Math.round(root.configViewModel.zStep * 100)

                        textFromValue: function(value) {
                            return (value / 100).toFixed(2)
                        }

                        valueFromText: function(text) {
                            return Math.round(
                                Number(text.replace(",", ".")) * 100
                            )
                        }

                        onValueModified: {
                            root.configViewModel.zStep = value / 100
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "Interpolação mínima"
                        font.pixelSize: 18
                        Layout.fillWidth: true
                    }

                    SpinBox {
                        from: -100000
                        to: 100000
                        stepSize: 1
                        value: Math.round(root.configViewModel.interpolationMin)
                        onValueModified: {
                            root.configViewModel.interpolationMin = value
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "Interpolação máxima"
                        font.pixelSize: 18
                        Layout.fillWidth: true
                    }

                    SpinBox {
                        from: -100000
                        to: 100000
                        stepSize: 1
                        value: Math.round(root.configViewModel.interpolationMax)
                        onValueModified: {
                            root.configViewModel.interpolationMax = value
                        }
                    }
                }

                // Calibração usada para transformar pixels da câmera em coordenadas reais.
                Text {
                    text: "Calibração da câmera"
                    color: root.textColor
                    font.pixelSize: 22
                    font.bold: true
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "Status"
                        font.pixelSize: 18
                        Layout.fillWidth: true
                    }

                    Label {
                        text: root.configViewModel.cameraCalibrationStatusText
                        color: root.configViewModel.cameraCalibrated
                            ? root.normalColor
                            : root.warningColor
                        font.pixelSize: 18
                        font.bold: true
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Button {
                        text: "Iniciar calibração"
                        font.pixelSize: 18
                        Layout.preferredHeight: 56
                        Layout.fillWidth: true

                        onClicked: {
                            root.cameraCalibrationRequested()
                        }
                    }

                    Button {
                        text: "Limpar calibração"
                        enabled: root.configViewModel.cameraCalibrated
                        font.pixelSize: 18
                        Layout.preferredHeight: 56
                        Layout.fillWidth: true

                        onClicked: {
                            root.configViewModel.clearCameraCalibration()
                        }
                    }
                }

                Text {
                    text: "Integrações"
                    color: root.textColor
                    font.pixelSize: 22
                    font.bold: true
                    Layout.fillWidth: true
                }

                CheckBox {
                    text: "Habilitar conexão opcional com CLP"
                    checked: root.configViewModel.clpEnabled
                    font.pixelSize: 18
                    onToggled: {
                        root.configViewModel.clpEnabled = checked
                    }
                }

                Text {
                    text: root.configViewModel.message
                    color: root.textColor
                    font.pixelSize: 16
                    visible: text.length > 0
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true

                    Button {
                        text: "Recarregar"
                        font.pixelSize: 18
                        Layout.preferredHeight: 56
                        Layout.fillWidth: true
                        onClicked: root.configViewModel.reload()
                    }

                    Button {
                        text: "Salvar"
                        font.pixelSize: 18
                        Layout.preferredHeight: 56
                        Layout.fillWidth: true
                        onClicked: root.configViewModel.save()
                    }
                }
            }
        }
    }
}
