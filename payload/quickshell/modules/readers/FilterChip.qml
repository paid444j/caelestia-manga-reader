import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

// M3 outlined filter chip: 32dp container, 48dp target, 8dp corners,
// 18dp selected icon, label-large, 8dp icon gap, 16dp trailing padding.
// https://m3.material.io/components/chips/specs
// material-components/material-web tokens/versions/v0_192/_md-comp-filter-chip.scss
Item {
    id: root
    required property string text
    property bool selected: false
    signal clicked()
    implicitWidth: label.implicitWidth + (selected ? 50 : 32)
    implicitHeight: 48
    activeFocusOnTab: true
    Accessible.role: Accessible.CheckBox
    Accessible.name: text
    Accessible.checkable: true
    Accessible.checked: selected
    Keys.onSpacePressed: clicked()
    Keys.onReturnPressed: clicked()
    StyledRect {
        id: container
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 32
        radius: 8
        color: !root.enabled ? (root.selected ? Qt.alpha(Colours.palette.m3onSurface, 0.12) : "transparent")
            : root.selected ? Colours.palette.m3secondaryContainer : "transparent"
        border.width: root.selected ? 0 : 1
        border.color: !root.enabled ? Qt.alpha(Colours.palette.m3onSurface, 0.12)
            : root.activeFocus ? Colours.palette.m3onSurfaceVariant : Colours.palette.m3outline
        RowLayout {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: root.selected ? -4 : 0
            spacing: 8
            MaterialIcon {
                visible: root.selected
                text: "check"
                fontStyle: Qt.font({ pointSize: 13.5 })
                color: label.color
            }
            StyledText {
                id: label
                text: root.text
                font.family: Tokens.font.label.large.family
                font.pixelSize: 14
                font.weight: Font.Medium
                font.letterSpacing: 0.1
                color: !root.enabled ? Qt.alpha(Colours.palette.m3onSurface, 0.38)
                    : root.selected ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
            }
        }
        StateLayer {
            id: stateLayer
            color: root.selected ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
            radius: 8
            manualHoverOverride: hit.containsMouse
            manualPressOverride: hit.pressed
            stateOpacity: root.activeFocus ? 0.12 : containsMouse || manualHoverOverride ? 0.08 : 0
            onClicked: root.clicked()
        }
    }
    MouseArea {
        id: hit
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: event => stateLayer.press(event.x, event.y - 8)
        onClicked: { root.forceActiveFocus(); root.clicked(); }
    }
}
