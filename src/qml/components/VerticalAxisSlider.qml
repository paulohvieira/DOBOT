/*
    Controle vertical reutilizável para ajuste de eixo em tela touch.

    Autor:
        Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    signal valueEdited(real value)

    required property string axisLabel

    property real from: 0
    property real to: 100
    property real value: 0
    property real stepSize: 0.05
    property color backgroundColor: "#ffffff"
    property color borderColor: "#d8dee4"
    property color textColor: "#101418"
    property color trackColor: "#d8dee4"
    property color fillColor: "#00d6af"
    property color handleColor: "#101418"
    property color handleBorderColor: "#ffffff"
    readonly property int valueDecimals: decimalsFromStep()

    radius: 0
    color: root.backgroundColor
    border.color: root.borderColor

    function normalizedValue() {
        if (root.to === root.from) {
            return 0
        }

        return (root.value - root.from) / (root.to - root.from)
    }

    function snapValue(value) {
        if (root.stepSize <= 0) {
            return clampValue(value)
        }

        const steps = Math.round((value - root.from) / root.stepSize)
        return clampValue(root.from + steps * root.stepSize)
    }

    function clampValue(value) {
        const lowerLimit = Math.min(root.from, root.to)
        const upperLimit = Math.max(root.from, root.to)

        return Math.max(lowerLimit, Math.min(value, upperLimit))
    }

    function formattedValue() {
        return root.value.toFixed(root.valueDecimals)
    }

    function decimalsFromStep() {
        if (root.stepSize <= 0) {
            return 2
        }

        const stepText = root.stepSize.toString()

        if (stepText.indexOf("e-") !== -1) {
            return Math.min(6, Number(stepText.split("e-")[1]))
        }

        const dotIndex = stepText.indexOf(".")

        if (dotIndex === -1) {
            return 0
        }

        return Math.min(6, stepText.length - dotIndex - 1)
    }

    function valueFromText(text) {
        const normalizedText = text.replace(",", ".")
        const parsedValue = Number(normalizedText)

        if (Number.isNaN(parsedValue)) {
            return Number.NaN
        }

        return snapValue(parsedValue)
    }

    function updateValueText(text) {
        const parsedValue = valueFromText(text)

        if (Number.isNaN(parsedValue)) {
            return
        }

        root.value = parsedValue
    }

    function commitValueText(text) {
        const parsedValue = valueFromText(text)

        if (Number.isNaN(parsedValue)) {
            valueInput.text = root.formattedValue()
            return
        }

        root.value = parsedValue
        valueInput.text = root.formattedValue()
        root.valueEdited(root.value)
    }

    // Confirma a edição numérica uma única vez por ciclo de evento.
    function commitValueInput() {
        if (valueInput.commitInProgress) {
            return
        }

        valueInput.commitInProgress = true
        valueInput.skipNextFocusCommit = true

        root.commitValueText(valueInput.text)
        valueInput.focus = false
        Qt.inputMethod.hide()

        Qt.callLater(function() {
            valueInput.commitInProgress = false
        })
    }

    function valueFromY(positionY) {
        const trackTop = sliderTrack.y
        const trackHeight = sliderTrack.height
        const clampedY = Math.max(trackTop, Math.min(positionY, trackTop + trackHeight))
        const normalized = 1 - ((clampedY - trackTop) / trackHeight)

        return snapValue(root.from + normalized * (root.to - root.from))
    }

    function updateValueFromY(positionY) {
        root.value = valueFromY(positionY)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 12
        anchors.bottomMargin: 12
        anchors.leftMargin: 4
        anchors.rightMargin: 4
        spacing: 12

        Text {
            text: root.axisLabel
            color: root.textColor
            font.pixelSize: 24
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        TextField {
            id: valueInput

            property bool commitInProgress: false
            property bool skipNextFocusCommit: false

            text: root.formattedValue()
            color: root.textColor
            font.pixelSize: 16
            horizontalAlignment: TextInput.AlignHCenter
            inputMethodHints: Qt.ImhFormattedNumbersOnly | Qt.ImhPreferNumbers
            selectByMouse: true
            Layout.fillWidth: true

            background: Item {}

            validator: DoubleValidator {
                bottom: Math.min(root.from, root.to)
                top: Math.max(root.from, root.to)
                decimals: root.valueDecimals
                notation: DoubleValidator.StandardNotation
            }

            onActiveFocusChanged: {
                if (activeFocus) {
                    selectAll()
                    return
                }

                if (skipNextFocusCommit) {
                    skipNextFocusCommit = false
                    return
                }

                root.commitValueText(text)
            }

            onAccepted: {
                root.commitValueInput()
            }

            onTextEdited: {
                root.updateValueText(text)
            }

            Keys.onReturnPressed: function(event) {
                root.commitValueInput()
                event.accepted = true
            }

            Keys.onEnterPressed: function(event) {
                root.commitValueInput()
                event.accepted = true
            }

            Connections {
                target: root

                function onValueChanged() {
                    if (!valueInput.activeFocus) {
                        valueInput.text = root.formattedValue()
                    }
                }
            }
        }

        Item {
            id: touchArea

            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                id: sliderTrack

                width: 32
                radius: width / 2
                color: root.trackColor
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: parent.height * root.normalizedValue()
                    radius: parent.radius
                    color: root.fillColor
                }
            }

            Rectangle {
                id: handle

                width: 64
                height: 64
                radius: 32
                color: root.handleColor
                border.color: root.handleBorderColor
                border.width: 2
                anchors.horizontalCenter: sliderTrack.horizontalCenter
                y: sliderTrack.y
                    + sliderTrack.height * (1 - root.normalizedValue())
                    - height / 2
            }

            MouseArea {
                anchors.fill: parent

                onPressed: function(mouse) {
                    valueInput.focus = false
                    root.updateValueFromY(mouse.y)
                }

                onPositionChanged: function(mouse) {
                    if (pressed) {
                        root.updateValueFromY(mouse.y)
                    }
                }

                onReleased: function(mouse) {
                    root.valueEdited(root.value)
                }

                onCanceled: function() {
                    root.valueEdited(root.value)
                }
            }
        }

    }
}
