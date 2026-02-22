import QtQuick
import QtQuick.Layouts
import qs.Commons
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

      // Sun icon
      NIcon {
        Layout.alignment: Qt.AlignHCenter
        icon: pluginApi?.barWidgetInstance?.isDay ?? true ? "sun" : "moon-stars"
        pointSize: Style.fontSizeXXL * Style.uiScaleRatio
        color: Color.mPrimary
      }

      // Data rows
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
              text: pluginApi?.barWidgetInstance?.sunriseTime ?? "--:--"
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
              text: pluginApi?.barWidgetInstance?.sunsetTime ?? "--:--"
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
              text: pluginApi?.barWidgetInstance?.daylightDuration ?? "--"
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
