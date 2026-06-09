/*
    Barra superior da aplicação com acesso ao drawer e estado principal.

    Autor:
        Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    signal menuRequested()
    property url menuIconSource: "../../assets/menu_24.svg"
    property url logoSource: "../../assets/CPQD_Logo_Positivo_RGB.png"
    property int menuIconSize: 24
    property int logoWidth: 150
    property int logoHeight: 44
    required property real uiScale

    property color backgroundColor: "#ffffff"
    property color textColor: "#101418"
    property color mutedTextColor: "#66737d"
    property color menuButtonBackgroundColor: "#ffd133"
    property color menuButtonPressedColor: "#92dd71"
    property int headerHeight: 52
    property int spacing: 16

    function px(value) {
        return Math.round(value * root.uiScale)
    }

    color: root.backgroundColor
    Layout.fillWidth: true
    Layout.preferredHeight: root.px(root.headerHeight)

    Item {
        anchors.fill: parent

        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: root.px(root.spacing)
            anchors.verticalCenter: parent.verticalCenter
            width: root.px(56)
            height: root.px(48)

            radius: root.px(8)
            color: menuMouseArea.pressed
                ? root.menuButtonPressedColor
                : root.menuButtonBackgroundColor

            Image {
                anchors.centerIn: parent
                source: root.menuIconSource
                sourceSize.width: root.px(root.menuIconSize)
                sourceSize.height: root.px(root.menuIconSize)
            }

            MouseArea {
                id: menuMouseArea

                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.menuRequested()
            }
        }

        Image {
            anchors.centerIn: parent
            source: root.logoSource
            sourceSize.width: root.px(root.logoWidth)
            sourceSize.height: root.px(root.logoHeight)
            fillMode: Image.PreserveAspectFit
            width: root.px(root.logoWidth)
            height: root.px(root.logoHeight)
        }
    }
}
