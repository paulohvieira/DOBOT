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

    property color surfaceColor: "#ffffff"
    property color borderColor: "#d8dee4"
    property color textColor: "#101418"
    property color mutedTextColor: "#66737d"
    property color cameraBackgroundColor: "#101418"
    property color cameraTextColor: "#ffffff"
    property color sliderTrackColor: "#d8dee4"
    property color sliderFillColor: "#00d6af"
    property color sliderHandleColor: "#101418"
    property color sliderHandleBorderColor: "#ffffff"

    Loader {
        id: pageLoader

        anchors.fill: parent
        sourceComponent: {
            if (root.currentPage === "manual") {
                return manualPageComponent
            }

            if (root.currentPage === "automatic") {
                return automaticPageComponent
            }

            if (root.currentPage === "config") {
                return configPageComponent
            }

            return manualPageComponent
        }
    }

    Component {
        id: manualPageComponent

        ManualPage {
            cameraConnected: root.cameraConnected
            surfaceColor: root.surfaceColor
            borderColor: root.borderColor
            textColor: root.textColor
            mutedTextColor: root.mutedTextColor
            cameraBackgroundColor: root.cameraBackgroundColor
            cameraTextColor: root.cameraTextColor
            sliderTrackColor: root.sliderTrackColor
            sliderFillColor: root.sliderFillColor
            sliderHandleColor: root.sliderHandleColor
            sliderHandleBorderColor: root.sliderHandleBorderColor
        }
    }

    Component {
        id: automaticPageComponent

        PlaceholderPage {
            title: "Modo Automático"
            textColor: root.textColor
        }
    }

    Component {
        id: configPageComponent

        PlaceholderPage {
            title: "Configurações"
            textColor: root.textColor
        }
    }
}
