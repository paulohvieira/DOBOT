/*
    Diálogo de confirmação para ações críticas.

    Autor:
        Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: root

    signal confirmed()

    property string message: ""
    property string confirmText: "Confirmar"
    property string cancelText: "Cancelar"
    property color textColor: "#101418"
    property color dangerColor: "#dc2626"
    property real keyboardHeight: 0
    property real verticalMargin: 24

    modal: true
    standardButtons: Dialog.NoButton
    width: 420

    x: parent ? Math.round((parent.width - width) / 2) : 0
    y: {
        const availableHeight = parent
            ? parent.height - root.keyboardHeight
            : 0
        const centeredY = Math.round((availableHeight - height) / 2)

        return Math.max(root.verticalMargin, centeredY)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 16

        Text {
            text: root.message
            color: root.textColor
            font.pixelSize: 17
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true

            Button {
                text: root.cancelText
                Layout.fillWidth: true
                onClicked: root.close()
            }

            Button {
                text: root.confirmText
                Layout.fillWidth: true
                onClicked: {
                    root.close()
                    root.confirmed()
                }
            }
        }
    }
}
