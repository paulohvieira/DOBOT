/*
    Hospeda a página ativa selecionada pela navegação principal.

    Autor:
        Paulo Henrique Vieira de Souza <phsouza@cpqd.com.br>
*/

import QtQuick
import "../pages"

Item {
    id: root

    required property string currentPage
    required property bool cameraConnected
    required property QtObject configViewModel
    required property QtObject alarmViewModel
    required property QtObject automaticViewModel
    required property QtObject automaticCameraViewModel
    required property string operationMode
    required property string dobotStatus
    required property string cameraStatus
    required property string clpStatus
    required property string pailotStatus

    property color surfaceColor: "#ffffff"
    property color surfaceSecondaryColor: "#eef1f4"
    property color borderColor: "#d8dee4"
    property color textColor: "#101418"
    property color mutedTextColor: "#66737d"
    property color normalColor: "#2f855a"
    property color warningColor: "#d97706"
    property color dangerColor: "#dc2626"
    property color disabledColor: "#8a97a3"
    property color unavailableColor: "#6b7280"
    property color infoColor: "#2563eb"
    property color cameraBackgroundColor: "#101418"
    property color cameraTextColor: "#ffffff"
    property color sliderBackgroundColor: "transparent"
    property color sliderBorderColor: "transparent"
    property color sliderTrackColor: "#d8dee4"
    property color sliderFillColor: "#00d6af"
    property color sliderHandleColor: "#101418"
    property color sliderHandleBorderColor: "#ffffff"

    Loader {
        id: pageLoader

        anchors.fill: parent
        sourceComponent: {
            if (root.currentPage === "overview") {
                return overviewPageComponent
            }

            if (root.currentPage === "manual") {
                return manualPageComponent
            }

            if (root.currentPage === "automatic") {
                return automaticPageComponent
            }

            if (root.currentPage === "config") {
                return configPageComponent
            }

            if (root.currentPage === "alarms") {
                return alarmPageComponent
            }

            if (root.currentPage === "diagnostic") {
                return diagnosticPageComponent
            }

            return overviewPageComponent
        }
    }

    Component {
        id: overviewPageComponent

        OverviewPage {
            operationMode: root.operationMode
            dobotStatus: root.dobotStatus
            cameraStatus: root.cameraStatus
            clpStatus: root.clpStatus
            pailotStatus: root.pailotStatus
            surfaceColor: root.surfaceColor
            surfaceSecondaryColor: root.surfaceSecondaryColor
            borderColor: root.borderColor
            textColor: root.textColor
            mutedTextColor: root.mutedTextColor
            normalColor: root.normalColor
            warningColor: root.warningColor
            dangerColor: root.dangerColor
            disabledColor: root.disabledColor
            unavailableColor: root.unavailableColor
            infoColor: root.infoColor
        }
    }

    Component {
        id: manualPageComponent

        ManualPage {
            cameraConnected: root.cameraConnected
            configViewModel: root.configViewModel
            surfaceColor: root.surfaceColor
            borderColor: root.borderColor
            textColor: root.textColor
            mutedTextColor: root.mutedTextColor
            cameraBackgroundColor: root.cameraBackgroundColor
            cameraTextColor: root.cameraTextColor
            sliderBackgroundColor: root.sliderBackgroundColor
            sliderBorderColor: root.sliderBorderColor
            sliderTrackColor: root.sliderTrackColor
            sliderFillColor: root.sliderFillColor
            sliderHandleColor: root.sliderHandleColor
            sliderHandleBorderColor: root.sliderHandleBorderColor
        }
    }

    Component {
        id: automaticPageComponent

        AutomaticPage {
            automaticViewModel: root.automaticViewModel
            automaticCameraViewModel: root.automaticCameraViewModel
            cameraConnected: root.cameraConnected
            surfaceColor: root.surfaceColor
            surfaceSecondaryColor: root.surfaceSecondaryColor
            borderColor: root.borderColor
            textColor: root.textColor
            mutedTextColor: root.mutedTextColor
            normalColor: root.normalColor
            warningColor: root.warningColor
            dangerColor: root.dangerColor
            infoColor: root.infoColor
            cameraBackgroundColor: root.cameraBackgroundColor
            cameraTextColor: root.cameraTextColor
        }
    }

    Component {
        id: alarmPageComponent

        AlarmPage {
            alarmViewModel: root.alarmViewModel
            surfaceColor: root.surfaceColor
            borderColor: root.borderColor
            textColor: root.textColor
            mutedTextColor: root.mutedTextColor
            normalColor: root.normalColor
            warningColor: root.warningColor
            dangerColor: root.dangerColor
            infoColor: root.infoColor
        }
    }

    Component {
        id: diagnosticPageComponent

        DiagnosticPage {
            dobotStatus: root.dobotStatus
            cameraStatus: root.cameraStatus
            clpStatus: root.clpStatus
            pailotStatus: root.pailotStatus
            surfaceColor: root.surfaceColor
            borderColor: root.borderColor
            textColor: root.textColor
            mutedTextColor: root.mutedTextColor
        }
    }

    Component {
        id: configPageComponent

        ConfigPage {
            configViewModel: root.configViewModel
            surfaceColor: root.surfaceColor
            borderColor: root.borderColor
            textColor: root.textColor
        }
    }
}
