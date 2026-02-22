import Quickshell
import qs.Commons
import qs.Services.Location
import qs.Services.UI
import qs.Widgets

NIconButton {
  id: root

  property var pluginApi: null

  property ShellScreen screen
  property string widgetId: ""
  property string section: ""

  property var cfg: pluginApi?.pluginSettings || ({})
  property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

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

  icon: root.isDay ? "sun" : "moon-stars"
  tooltipText: `Sunrise: ${root.sunriseTime}  Sunset: ${root.sunsetTime}  Daylight: ${root.daylightDuration}`
  tooltipDirection: BarService.getTooltipDirection(screen?.name)
  baseSize: Style.getCapsuleHeightForScreen(screen?.name)
  applyUiScale: false
  customRadius: Style.radiusL
  colorBg: Style.capsuleColor

  border.color: Style.capsuleBorderColor
  border.width: Style.capsuleBorderWidth

  onClicked: {
    BarService.openPluginSettings(root.screen, pluginApi.manifest)
  }

  NPopupContextMenu {
    id: contextMenu

    model: [
      {
        "label": pluginApi?.tr("menu.settings"),
        "action": "settings",
        "icon": "settings"
      },
    ]

    onTriggered: function (action) {
      contextMenu.close();
      PanelService.closeContextMenu(screen);
      if (action === "settings") {
        BarService.openPluginSettings(root.screen, pluginApi.manifest);
      }
    }
  }

  onRightClicked: {
    PanelService.showContextMenu(contextMenu, root, screen);
  }
}
