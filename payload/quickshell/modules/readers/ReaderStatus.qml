import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls as Controls
import qs.services

// Screen state composed from the shell's existing text, icon, button and loader.
ColumnLayout {
    id: root
    property bool busy: false
    property string icon: "menu_book"
    property string title: ""
    property string message: ""
    property string action: ""
    signal actionRequested()
    spacing: Tokens.spacing.large
    Controls.CircularIndicator {
        Layout.alignment: Qt.AlignHCenter
        visible: root.busy
        running: root.visible && root.busy
    }
    MaterialIcon {
        Layout.alignment: Qt.AlignHCenter
        visible: !root.busy
        text: root.icon
        fontStyle: Tokens.font.icon.extraLarge
        color: Colours.palette.m3primary
    }
    StyledText {
        Layout.fillWidth: true
        text: root.title
        font: Tokens.font.title.medium
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }
    StyledText {
        Layout.fillWidth: true
        visible: text.length > 0
        text: root.message
        font: Tokens.font.body.small
        color: Colours.palette.m3onSurfaceVariant
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }
    Controls.TextButton {
        Layout.alignment: Qt.AlignHCenter
        visible: root.action.length > 0 && !root.busy
        text: root.action
        onClicked: root.actionRequested()
    }
}
