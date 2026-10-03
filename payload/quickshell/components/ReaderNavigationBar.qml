pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    required property int currentIndex
    signal destinationSelected(int index)

    implicitHeight: 80

    Rectangle {
        anchors.fill: parent
        color: "transparent"
    }

    Row {
        anchors.fill: parent
        anchors.horizontalCenter: parent.horizontalCenter

        Repeater {
            model: [
                { label: "Browse", icon: "explore" },
                { label: "Library", icon: "bookmarks" }
            ]

            delegate: Item {
                required property int index
                required property var modelData

                width: root.width / 2
                height: root.height
                readonly property bool selected: root.currentIndex === index

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    width: 64
                    height: 32
                    radius: Tokens.rounding.full
                    color: parent.selected ? Colours.palette.m3secondaryContainer : "transparent"
                    Behavior on color { ColorAnimation { duration: 180 } }
                }

                MaterialIcon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    text: modelData.icon
                    color: parent.selected ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
                    fontStyle: Qt.font({ pointSize: 18 })
                    fill: parent.selected ? 1 : 0
                    Behavior on fill { NumberAnimation { duration: 180 } }
                }

                StyledText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                    text: modelData.label
                    color: parent.selected ? Colours.palette.m3onSurface : Colours.palette.m3onSurfaceVariant
                    font.family: Tokens.font.label.medium.family
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }

                StateLayer {
                    anchors.fill: parent
                    radius: Tokens.rounding.medium
                    onClicked: root.destinationSelected(index)
                }
            }
        }
    }
}
