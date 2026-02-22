import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root
    spacing: Style.marginM

    property var pluginApi: null

    // Access settings & defaults
    property var cfg: pluginApi?.pluginSettings || ({})
    property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

    // Pre-populate from global location if no plugin override is set
    property string location: cfg.location || Settings.data.location?.name || ""

    NText {
        text: "Location"
        font.pointSize: Style.fontSizeM
        font.weight: Font.Medium
    }

    NText {
        text: "Enter your location in format: city, ISO country code"
        font.pointSize: Style.fontSizeS
        font.weight: Font.Light
        color: Color.mOnSurfaceVariant
        Layout.bottomMargin: Style.marginS
    }

    NTextInput {
        id: locationField
        Layout.fillWidth: true
        placeholderText: "e.g., London, GB"
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
                    font.pointSize: Style.fontSizeS
                    font.weight: Font.Medium
                    color: Color.mOnSurface
                }
            }

            NText {
                Layout.fillWidth: true
                text: "Sunrise and sunset times are fetched from Open-Meteo via Noctalia's built-in Location Service. Setting a location here will override the default location determined by the Noctalia Location Service."
                font.pointSize: Style.fontSizeXS
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
