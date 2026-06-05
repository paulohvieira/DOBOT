import QtQuick

QtObject {
    id: root

    readonly property color cpqdYellow: "#ffd133"
    readonly property color cpqdGreen: "#92dd71"
    readonly property color cpqdTeal: "#00d6af"

    readonly property color background: "#f5f7f8"
    readonly property color surface: "#ffffff"
    readonly property color border: "#d8dee4"
    readonly property color text: "#101418"
    readonly property color mutedText: "#66737d"
    readonly property color danger: "#d92d20"

    readonly property color sliderBackground: "transparent"
    readonly property color sliderBorder: "transparent"
    readonly property color sliderTrack: cpqdGreen
    readonly property color sliderFill: cpqdTeal
    readonly property color sliderHandle: cpqdYellow
    readonly property color sliderHandleBorder: text
    readonly property color drawerHover: "#eef3f4"
    readonly property color drawerPressed: "#dfe8ea"
    readonly property color cameraPreviewBackground: text
    readonly property color cameraPreviewText: surface
    readonly property color headerBackground: cpqdTeal
    readonly property color headerText: text
    readonly property color headerMutedText: text
    readonly property color menuButtonBackground: cpqdYellow
    readonly property color menuButtonPressed: cpqdGreen

    readonly property int designWidth: 1280
    readonly property int designHeight: 800
    readonly property int defaultWidth: 1024
    readonly property int defaultHeight: 728
    readonly property int minimumWidth: 800
    readonly property int minimumHeight: 480
    readonly property int spacing: 16
    readonly property int headerHeight: 72
    readonly property int controlHeight: 56
    readonly property int radius: 8
}
