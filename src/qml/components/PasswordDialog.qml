import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: root

    signal passwordAccepted()

    property string expectedPassword: "3242"
    property string errorText: ""
    property color textColor: "#101418"
    property color dangerColor: "#d92d20"
    property real keyboardHeight: 0
    property real verticalMargin: 24
    title: "Senha requerida"
    modal: true
    standardButtons: Dialog.NoButton
    width: 360

    x: parent ? Math.round((parent.width - width) / 2) : 0
    y: {
        const availableHeight = parent
            ? parent.height - root.keyboardHeight
            : 0

        const centeredY = Math.round((availableHeight - height) / 2)

        return Math.max(root.verticalMargin, centeredY)
    }

    onOpened: {
        passwordInput.text = ""
        root.errorText = ""
        passwordInput.forceActiveFocus()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        Text {
            text: "Digite a senha para continuar"
            font.pixelSize: 16
            color: root.textColor
            Layout.fillWidth: true
        }

        TextField {
            id: passwordInput

            echoMode: TextInput.Password
            font.pixelSize: 18
            placeholderText: "Senha"
            Layout.fillWidth: true
            onAccepted: confirmButton.clicked()
        }

        Text {
            text: root.errorText
            color: root.dangerColor
            font.pixelSize: 14
            visible: root.errorText.length > 0
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true

            Button {
                text: "Cancelar"
                Layout.fillWidth: true
                onClicked: root.close()
            }

            Button {
                id: confirmButton

                text: "Confirmar"
                Layout.fillWidth: true
                onClicked: {
                    if (passwordInput.text === root.expectedPassword) {
                        root.close()
                        root.passwordAccepted()
                        return
                    }

                    root.errorText = "Senha inválida"
                    passwordInput.selectAll()
                    passwordInput.forceActiveFocus()
                }
            }
        }
    }
}
