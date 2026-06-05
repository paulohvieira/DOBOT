/*
    Exibe o streaming da câmera disponível no sistema.

    Recria o pipeline de captura quando a câmera é reconectada para garantir
    que o VideoOutput volte a receber frames após remoção do USB.

    Autor:
        Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
*/

import QtQuick
import QtQuick.Layouts
import QtMultimedia

Rectangle {
    id: root

    required property bool cameraConnected

    property url disconnectedIconSource: "../../assets/videocam_off_24.svg"
    property color backgroundColor: "#101418"
    property color borderColor: "#d8dee4"
    property color textColor: "#ffffff"
    property color mutedTextColor: "#66737d"
    property int disconnectedIconSize: 64

    radius: 8
    color: root.backgroundColor
    border.color: root.borderColor
    clip: true

    Loader {
        id: cameraLoader

        anchors.fill: parent
        active: root.cameraConnected
        sourceComponent: cameraStreamComponent
    }

    Component {
        id: cameraStreamComponent

        Item {
            id: cameraStream

            anchors.fill: parent

            CaptureSession {
                camera: Camera {
                    id: camera

                    active: true
                }

                videoOutput: videoOutput
            }

            VideoOutput {
                id: videoOutput

                anchors.fill: parent
                fillMode: VideoOutput.PreserveAspectCrop
            }

            Component.onDestruction: {
                camera.active = false
            }
        }
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
}