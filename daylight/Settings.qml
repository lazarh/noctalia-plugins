import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root
    spacing: Style.spacingM

    property var pluginApi: null

    // Access settings & defaults
    property var cfg: pluginApi?.pluginSettings || ({})
    property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

    // Reactive property
    property string location: cfg.location ?? defaults.location

    NText {
        text: "Location"
        fontSize: Style.textSizeL
        fontWeight: Font.Medium
    }

    NText {
        text: "Enter your location in format: city, country"
        fontSize: Style.textSizeS
        fontWeight: Font.Light
        textColor: Style.textColorMuted
        Layout.bottomMargin: Style.spacingS
    }

    NTextInput {
        id: locationField
        Layout.fillWidth: true
        placeholderText: "e.g., London, UK"
        text: root.location
        onTextChanged: root.location = text
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: infoCol.implicitHeight + Style.marginM * 2
        color: Color.mSurfaceVariant
        radius: Style.radiusM

        ColumnLayout {
            id: infoCol
            anchors {
                fill: parent
                margins: Style.marginM
            }
            spacing: Style.marginS

            RowLayout {
                spacing: Style.marginS

                NIcon {
                    icon: "info-circle"
                    pointSize: Style.fontSizeS
                    color: Color.mPrimary
                }

                NText {
                    text: "How it works"
                    pointSize: Style.fontSizeS
                    font.weight: Font.Medium
                    color: Color.mOnSurface
                }
            }

            NText {
                Layout.fillWidth: true
                text: "Sunrise and sunset times are fetched from Open-Meteo via Noctalia's built-in Location Service. Make sure Location Service is enabled in Noctalia settings."
                pointSize: Style.fontSizeXS
                color: Color.mOnSurfaceVariant
                wrapMode: Text.WordWrap
            }
        }
    }

    // Required: Save function called by framework
    function saveSettings() {
        if (!pluginApi) return

        pluginApi.pluginSettings.location = root.location
        pluginApi.saveSettings()
    }
}
