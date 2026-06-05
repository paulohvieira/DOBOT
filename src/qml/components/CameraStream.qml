/*
    Exibe o streaming da câmera disponível no sistema.

    Autor:
        Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
*/

import QtQuick
import QtQuick.Layouts
import QtMultimedia

Rectangle {
    id: root

    required property bool cameraConnected

    property color backgroundColor: "#101418"
    property color borderColor: "#d8dee4"
    property color textColor: "#ffffff"
    property url disconnectedIconSource: "../../assets/videocam_off_24.svg"
    property color mutedTextColor: "#66737d"
    property int disconnectedIconSize: 64

    radius: 8
    color: root.backgroundColor
    border.color: root.borderColor
    clip: true

    CaptureSession {
        camera: Camera {
            id: camera

            active: root.cameraConnected
        }

        videoOutput: videoOutput
    }

    VideoOutput {
        id: videoOutput

        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
        visible: root.cameraConnected
    }

    Column {
        anchors.centerIn: parent
        spacing: 12
        visible: !root.cameraConnected

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            source: root.disconnectedIconSource
            sourceSize.width: root.disconnectedIconSize
            sourceSize.height: root.disconnectedIconSize
            opacity: 0.75
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Câmera desconectada"
            color: root.mutedTextColor
            font.pixelSize: 20
        }
    }

    Component.onDestruction: {
        camera.active = false
    }
}