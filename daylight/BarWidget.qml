import QtQuick
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

  // Track the location we last fetched for
  property string lastFetchedLocation: ""

  // Custom fetch results
  property bool customIsDay: true
  property var customSunrise: null
  property var customSunset: null

  // Use custom data if a location override is active, otherwise fall back to LocationService
  property bool isDay: lastFetchedLocation !== "" ? customIsDay : (LocationService.data?.weather?.current_weather?.is_day ?? true)
  property var sunrise: lastFetchedLocation !== "" ? customSunrise : (LocationService.data?.weather?.daily?.sunrise?.[0] ?? null)
  property var sunset: lastFetchedLocation !== "" ? customSunset : (LocationService.data?.weather?.daily?.sunset?.[0] ?? null)

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

  function checkAndFetch() {
    var loc = pluginApi?.pluginSettings?.location ?? ""
    if (loc !== root.lastFetchedLocation) {
      root.lastFetchedLocation = loc
      if (loc !== "") root.fetchForLocation(loc)
    }
  }

  function fetchForLocation(location) {
    var parts = location.split(",")
    var city = parts[0].trim()
    var countryCode = parts.length > 1 ? parts[1].trim() : ""
    var url = "https://geocoding-api.open-meteo.com/v1/search?name=" + encodeURIComponent(city) + "&count=1"
    if (countryCode !== "") url += "&countryCode=" + encodeURIComponent(countryCode)
    Logger.i("Daylight", "Geocoding:", city, countryCode ? "(" + countryCode + ")" : "")
    var xhr = new XMLHttpRequest()
    xhr.open("GET", url)
    xhr.onreadystatechange = function() {
      if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
        var data = JSON.parse(xhr.responseText)
        if (data.results && data.results.length > 0) {
          var r = data.results[0]
          Logger.i("Daylight", "Geocode result:", r.name, r.country, "lat:", r.latitude, "lon:", r.longitude)
          fetchWeather(r.latitude, r.longitude)
        } else {
          Logger.i("Daylight", "Geocode returned no results for:", location)
        }
      }
    }
    xhr.send()
  }

  function fetchWeather(lat, lon) {
    Logger.i("Daylight", "Fetching weather for lat:", lat, "lon:", lon)
    var xhr = new XMLHttpRequest()
    xhr.open("GET", "https://api.open-meteo.com/v1/forecast?latitude=" + lat + "&longitude=" + lon + "&daily=sunrise,sunset&current_weather=true&timezone=auto")
    xhr.onreadystatechange = function() {
      if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
        var data = JSON.parse(xhr.responseText)
        customIsDay = (data.current_weather?.is_day ?? 1) === 1
        customSunrise = data.daily?.sunrise?.[0] ?? null
        customSunset = data.daily?.sunset?.[0] ?? null
        Logger.i("Daylight", "Weather response — isDay:", customIsDay, "sunrise:", customSunrise, "sunset:", customSunset)
      }
    }
    xhr.send()
  }

  // Refresh data every hour so sunrise/sunset stays accurate
  Timer {
    interval: 3600000
    running: root.lastFetchedLocation !== ""
    repeat: true
    onTriggered: root.fetchForLocation(root.lastFetchedLocation)
  }

  Component.onCompleted: {
    var loc = pluginApi?.pluginSettings?.location ?? ""
    lastFetchedLocation = loc
    if (loc !== "") fetchForLocation(loc)
  }

  icon: root.isDay ? "sun" : "moon-stars"
  tooltipText: pluginApi?.tr("widget.tooltip") ?? "Daylight"
  tooltipDirection: BarService.getTooltipDirection(screen?.name)
  baseSize: Style.getCapsuleHeightForScreen(screen?.name)
  applyUiScale: false
  customRadius: Style.radiusL
  colorBg: Style.capsuleColor

  border.color: Style.capsuleBorderColor
  border.width: Style.capsuleBorderWidth

  onClicked: {
    checkAndFetch()
    if (pluginApi) pluginApi.openPanel(root.screen, this)
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

