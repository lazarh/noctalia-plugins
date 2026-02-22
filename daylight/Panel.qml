import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Services.Location
import qs.Services.UI
import qs.Widgets

Item {
  id: root

  property var pluginApi: null

  readonly property var geometryPlaceholder: panelContainer

  property real contentPreferredWidth: 260 * Style.uiScaleRatio
  property real contentPreferredHeight: 180 * Style.uiScaleRatio

  readonly property bool allowAttach: true

  anchors.fill: parent

  property string pluginLocation: pluginApi?.pluginSettings?.location ?? ""

  // Custom fetch results
  property bool customIsDay: true
  property var customSunrise: null
  property var customSunset: null
  property bool hasFetched: false

  // If a custom location is set, show nothing until fetch completes (avoids
  // showing stale LocationService data for a different location)
  property bool isDay: pluginLocation !== "" ? (hasFetched ? customIsDay : true) : (LocationService.data?.weather?.current_weather?.is_day ?? true)
  property var sunrise: pluginLocation !== "" ? (hasFetched ? customSunrise : null) : (LocationService.data?.weather?.daily?.sunrise?.[0] ?? null)
  property var sunset: pluginLocation !== "" ? (hasFetched ? customSunset : null) : (LocationService.data?.weather?.daily?.sunset?.[0] ?? null)

  property string sunriseTime: {
    if (!sunrise) return "--:--"
    return I18n.locale.toString(new Date(sunrise), "HH:mm")
  }

  property string sunsetTime: {
    if (!sunset) return "--:--"
    return I18n.locale.toString(new Date(sunset), "HH:mm")
  }

  property string daylightDuration: {
    if (!sunrise || !sunset) return "--"
    const diff = new Date(sunset) - new Date(sunrise)
    const hours = Math.floor(diff / (1000 * 60 * 60))
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
    return `${hours}h ${minutes}m`
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
        hasFetched = true
      }
    }
    xhr.send()
  }

  Component.onCompleted: {
    if (pluginLocation !== "") fetchForLocation(pluginLocation)
  }

  Rectangle {
    id: panelContainer
    anchors.fill: parent
    color: "transparent"

    ColumnLayout {
      anchors {
        fill: parent
        margins: Style.marginL
      }
      spacing: Style.marginM

      NIcon {
        Layout.alignment: Qt.AlignHCenter
        icon: root.isDay ? "sun" : "moon-stars"
        pointSize: Style.fontSizeXXL * Style.uiScaleRatio
        color: Color.mPrimary
      }

      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: dataColumn.implicitHeight + Style.marginM * 2
        color: Color.mSurfaceVariant
        radius: Style.radiusL

        ColumnLayout {
          id: dataColumn
          anchors {
            fill: parent
            margins: Style.marginM
          }
          spacing: Style.marginS

          RowLayout {
            Layout.fillWidth: true
            NText {
              text: pluginApi?.tr("panel.sunrise") ?? "Sunrise"
              font.pointSize: Style.fontSizeS
              color: Color.mOnSurfaceVariant
              Layout.fillWidth: true
            }
            NText {
              text: root.sunriseTime
              font.pointSize: Style.fontSizeS
              font.weight: Font.Medium
              color: Color.mOnSurface
            }
          }

          RowLayout {
            Layout.fillWidth: true
            NText {
              text: pluginApi?.tr("panel.sunset") ?? "Sunset"
              font.pointSize: Style.fontSizeS
              color: Color.mOnSurfaceVariant
              Layout.fillWidth: true
            }
            NText {
              text: root.sunsetTime
              font.pointSize: Style.fontSizeS
              font.weight: Font.Medium
              color: Color.mOnSurface
            }
          }

          RowLayout {
            Layout.fillWidth: true
            NText {
              text: pluginApi?.tr("panel.daylight") ?? "Daylight"
              font.pointSize: Style.fontSizeS
              color: Color.mOnSurfaceVariant
              Layout.fillWidth: true
            }
            NText {
              text: root.daylightDuration
              font.pointSize: Style.fontSizeS
              font.weight: Font.Medium
              color: Color.mOnSurface
            }
          }
        }
      }
    }
  }
}
