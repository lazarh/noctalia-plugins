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

    // Required: Save function called by framework
    function saveSettings() {
        if (!pluginApi) return

        pluginApi.pluginSettings.location = root.location
        pluginApi.saveSettings()
    }
}
