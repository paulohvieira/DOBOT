import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    signal clicked()

    property string label: ""
    property url iconSource: ""
    property color backgroundColor: "transparent"
    property color hoverColor: "#eef3f4"
    property color pressedColor: "#dfe8ea"
    property color selectedColor: "#d8f3f6"
    property color textColor: "#101418"
    property bool selected: false
    property int buttonHeight: 56
    property int iconSize: 20
    property int horizontalPadding: 16

    Layout.fillWidth: true
    Layout.preferredHeight: root.buttonHeight

    radius: 8
    color: root.selected
        ? root.selectedColor
        : mouseArea.pressed
            ? root.pressedColor
            : mouseArea.containsMouse ? root.hoverColor : root.backgroundColor

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: root.horizontalPadding
        anchors.rightMargin: root.horizontalPadding
        spacing: 8

        Text {
            text: root.label
            color: root.textColor
            font.pixelSize: 18
            font.bold: root.selected
            verticalAlignment: Text.AlignVCenter
            Layout.fillWidth: true
        }

        Image {
            source: root.iconSource
            sourceSize.width: root.iconSize
            sourceSize.height: root.iconSize
            visible: root.iconSource.toString().length > 0
            Layout.preferredWidth: root.iconSize
            Layout.preferredHeight: root.iconSize
            Layout.alignment: Qt.AlignVCenter
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
