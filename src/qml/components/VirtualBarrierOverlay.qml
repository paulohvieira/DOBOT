/*
    Sobreposição visual da barreira virtual na imagem da câmera.

    Autor:
        Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
*/

import QtQuick

Item {
    id: root

    property bool breached: false
    property color barrierOneColor: "#dc2626"
    property color barrierTwoColor: "#d97706"
    property color breachedFillColor: "#dc2626"

    Canvas {
        id: canvas

        anchors.fill: parent
        opacity: root.breached ? 0.95 : 0.8

        onPaint: {
            const context = getContext("2d")
            context.clearRect(0, 0, width, height)

            if (root.breached) {
                context.fillStyle = root.breachedFillColor
                context.globalAlpha = 0.12
                context.fillRect(0, 0, width, height)
                context.globalAlpha = 1
            }

            drawBarrierLine(
                context,
                root.barrierOneColor,
                width * 0.18,
                height * 0.22,
                width * 0.46,
                height * 0.78
            )
            drawBarrierLine(
                context,
                root.barrierTwoColor,
                width * 0.55,
                height * 0.78,
                width * 0.82,
                height * 0.22
            )
        }

        function drawBarrierLine(context, color, startX, startY, endX, endY) {
            context.strokeStyle = color
            context.lineWidth = root.breached ? 7 : 5
            context.lineCap = "round"
            context.beginPath()
            context.moveTo(startX, startY)
            context.lineTo(endX, endY)
            context.stroke()

            context.fillStyle = color
            context.beginPath()
            context.arc(startX, startY, 7, 0, Math.PI * 2)
            context.fill()
            context.beginPath()
            context.arc(endX, endY, 7, 0, Math.PI * 2)
            context.fill()
        }

        Connections {
            target: root

            function onBreachedChanged() {
                canvas.requestPaint()
            }
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 12
        width: statusText.implicitWidth + 20
        height: 34
        radius: 6
        color: root.breached ? root.barrierOneColor : "#1f2933"
        opacity: 0.9

        Text {
            id: statusText

            anchors.centerIn: parent
            text: root.breached ? "BARREIRA" : "Barreira virtual"
            color: "#ffffff"
            font.pixelSize: 14
            font.bold: root.breached
        }
    }
}
