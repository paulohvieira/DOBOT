/*
    Sobreposição fullscreen do protetor de tela.

    Autor:
        Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
*/

import QtQuick
import QtMultimedia

Rectangle {
    id: root

    property url videoSource: "../../assets/screensaver.mp4"
    property url fallbackLogoSource: "../../assets/CPQD_Logo_Positivo_RGB.png"
    property color backgroundColor: "#000000"
    property bool videoAvailable: videoSource.toString().length > 0

    signal dismissed()

    color: root.backgroundColor
    visible: false
    z: 200

    function open() {
        root.visible = true

        if (root.videoAvailable) {
            mediaPlayer.play()
        }
    }

    function close() {
        if (!root.visible) {
            return
        }

        mediaPlayer.stop()
        root.visible = false
        root.dismissed()
    }

    MediaPlayer {
        id: mediaPlayer

        source: root.videoSource
        videoOutput: videoOutput
        loops: MediaPlayer.Infinite

        onErrorOccurred: {
            root.videoAvailable = false
        }
    }

    VideoOutput {
        id: videoOutput

        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
        visible: root.videoAvailable
    }

    Image {
        anchors.centerIn: parent
        source: root.fallbackLogoSource
        sourceSize.width: 260
        sourceSize.height: 120
        fillMode: Image.PreserveAspectFit
        width: 260
        height: 120
        visible: !root.videoAvailable
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.visible
        onClicked: root.close()
    }
}
