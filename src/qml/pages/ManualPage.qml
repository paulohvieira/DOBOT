/*
    Tela de operação manual do Dobot Magician.

    Autor:
        Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
*/

import QtQuick
import QtQuick.Layouts
import "../components"

Item {
    id: root

    required property bool cameraConnected
    required property QtObject configViewModel
    property color sliderBackgroundColor: "transparent"
    property color sliderBorderColor: "transparent"
    property color sliderTrackColor: "#d8dee4"
    property color sliderFillColor: "#00d6af"
    property color sliderHandleColor: "#101418"
    property color sliderHandleBorderColor: "#ffffff"
    property color cameraBackgroundColor: "#101418"
    property color cameraTextColor: "#ffffff"
    property color mutedTextColor: "#66737d"
    property color surfaceColor: "#ffffff"
    property color borderColor: "#d8dee4"
    property color textColor: "#101418"

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        CameraStream {
            cameraConnected: root.cameraConnected
            backgroundColor: root.cameraBackgroundColor
            borderColor: root.borderColor
            textColor: root.cameraTextColor
            mutedTextColor: root.mutedTextColor
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        VerticalAxisSlider {
            axisLabel: "Z"
            from: root.configViewModel
                ? root.configViewModel.interpolationMin
                : 0
            to: root.configViewModel
                ? root.configViewModel.interpolationMax
                : 100
            stepSize: root.configViewModel
                ? root.configViewModel.zStep
                : 0.05
            value: root.configViewModel
                ? root.configViewModel.interpolationMin
                : 0
            backgroundColor: root.sliderBackgroundColor
            borderColor: root.sliderBorderColor
            textColor: root.textColor
            trackColor: root.sliderTrackColor
            fillColor: root.sliderFillColor
            handleColor: root.sliderHandleColor
            handleBorderColor: root.sliderHandleBorderColor
            Layout.preferredWidth: 96
            Layout.fillHeight: true

            onValueEdited: function(value) {
                console.log("Z:", value)
            }
        }
    }
}
