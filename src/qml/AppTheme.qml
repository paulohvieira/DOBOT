import QtQuick

QtObject {
    id: root

    readonly property color cpqdYellow: "#ffd133"
    readonly property color cpqdGreen: "#92dd71"
    readonly property color cpqdTeal: "#00d6af"

    readonly property color background: "#f4f6f8"
    readonly property color surface: "#ffffff"
    readonly property color surfaceSecondary: "#eef1f4"
    readonly property color border: "#cfd6dd"
    readonly property color text: "#1f2933"
    readonly property color mutedText: "#5f6f7f"
    readonly property color selection: "#0b7285"
    readonly property color selectionSoft: "#d8f3f6"
    readonly property color normal: "#2f855a"
    readonly property color warning: "#d97706"
    readonly property color danger: "#dc2626"
    readonly property color info: "#2563eb"
    readonly property color acknowledged: "#7c3aed"
    readonly property color disabled: "#8a97a3"
    readonly property color unavailable: "#6b7280"

    readonly property color sliderBackground: "transparent"
    readonly property color sliderBorder: "transparent"
    readonly property color sliderTrack: border
    readonly property color sliderFill: selection
    readonly property color sliderHandle: surface
    readonly property color sliderHandleBorder: text
    readonly property color drawerHover: "#eef3f4"
    readonly property color drawerPressed: selectionSoft
    readonly property color cameraPreviewBackground: "#111827"
    readonly property color cameraPreviewText: surface
    readonly property color headerBackground: surface
    readonly property color headerText: text
    readonly property color headerMutedText: mutedText
    readonly property color menuButtonBackground: surfaceSecondary
    readonly property color menuButtonPressed: selectionSoft

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
