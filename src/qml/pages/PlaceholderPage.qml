/*
    Página temporária para fluxos ainda não implementados.

    Autor:
        Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
*/

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property string title

    property color textColor: "#101418"

    ColumnLayout {
        anchors.centerIn: parent

        Text {
            text: root.title
            color: root.textColor
            font.pixelSize: 32
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
