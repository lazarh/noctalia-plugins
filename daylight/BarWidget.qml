import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.Location
import qs.Services.UI
import qs.Widgets

Item {
    id: root

    // Required properties
    property var pluginApi: null
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""

    readonly property string screenName: screen ? screen.name : ""
    readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
    readonly property bool isVertical: barPosition === "left" || barPosition === "right"
    readonly property real barHeight: Style.getBarHeightForScreen(screenName)
    readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screenName)
    readonly property real barFontSize: Style.getBarFontSizeForScreen(screenName)

    readonly property real contentWidth: isVertical ? root.barHeight : implicitWidth
    readonly property real contentHeight: isVertical ? implicitHeight : root.capsuleHeight

    implicitWidth: visualCapsule.width
    implicitHeight: visualCapsule.height

    // Settings
    property var cfg: pluginApi?.pluginSettings || ({})
    property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})
    property string location: cfg.location ?? defaults.location

    // Weather data
    property bool isDay: LocationService.data?.weather?.current_weather?.is_day ?? true
    property var sunrise: LocationService.data?.weather?.daily?.sunrise?.[0] ?? null
    property var sunset: LocationService.data?.weather?.daily?.sunset?.[0] ?? null

    // Computed values
    property string sunriseTime: {
        if (!sunrise) return "--:--"
        const date = new Date(sunrise)
        return I18n.locale.toString(date, "HH:mm")
    }

    property string sunsetTime: {
        if (!sunset) return "--:--"
        const date = new Date(sunset)
        return I18n.locale.toString(date, "HH:mm")
    }

    property string daylightDuration: {
        if (!sunrise || !sunset) return "--"
        const start = new Date(sunrise)
        const end = new Date(sunset)
        const diff = end - start
        const hours = Math.floor(diff / (1000 * 60 * 60))
        const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
        return `${hours}h ${minutes}m`
    }

    Rectangle {
        id: visualCapsule
        x: Style.pixelAlignCenter(parent.width, width)
        y: Style.pixelAlignCenter(parent.height, height)
        width: root.contentWidth
        height: root.contentHeight
        color: mouseArea.containsMouse ? Color.mHover : Style.capsuleColor
        radius: Style.radiusL
        border.color: Style.capsuleBorderColor
        border.width: Style.capsuleBorderWidth

        RowLayout {
            anchors.centerIn: parent
            spacing: Style.spacingS

            NIcon {
                id: icon
                iconName: root.isDay ? "weather-clear" : "weather-clear-night"
                iconSize: root.barFontSize * 1.2
                iconColor: Style.textColor
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onEntered: {
                const rows = [
                    ["Sunrise", root.sunriseTime],
                    ["Sunset", root.sunsetTime],
                    ["Daylight", root.daylightDuration]
                ]
                TooltipService.show(root, rows, BarService.getTooltipDirection(screenName))
            }

            onExited: {
                TooltipService.hide()
            }

            onClicked: {
                TooltipService.hide()
                PanelService.openPluginSettings(pluginApi)
            }
        }
    }
}
