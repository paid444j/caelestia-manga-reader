pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Config
import qs.components
import qs.components.controls as Controls
import qs.services
import qs.modules.manga
import qs.modules.novel
import qs.modules.bar as Bar

Item {
    id: root

    required property ScreenState screenState
    required property Bar.BarWrapper bar

    readonly property string activeReader: Readers.activeReader
    readonly property real panelWidth: Math.min(640, parent.width * 0.48)
    readonly property bool novelFullscreen: contentReader === "novel" && novelPanel.item !== null && novelPanel.item.fullscreen
    property string displayedReader: ""
    property string contentReader: ""
    property string pendingReader: ""
    property bool suppressBar: false
    property bool restoreBar: false
    property bool hadBarOwnership: false

    function close(): void { Readers.close(); }

    width: displayedReader ? (novelFullscreen ? parent.width : panelWidth) : 0
    height: parent.height
    x: 0
    clip: true
    visible: displayedReader !== "" || width > 0
    z: 10


    Behavior on width { Anim {} }

    function revealWhenBarClosed(): void {
        if (pendingReader && bar.implicitWidth <= Config.border.thickness + 0.5) {
            displayedReader = pendingReader;
            contentReader = pendingReader;
            pendingReader = "";
        }
    }

    function restoreBarWhenClosed(): void {
        if (activeReader === "" && width <= 0.5) {
            suppressBar = false;
            displayedReader = "";
            contentReader = "";
            if (hadBarOwnership)
                screenState.bar = restoreBar;
            hadBarOwnership = false;
        }
    }

    onActiveReaderChanged: {
        if (activeReader) {
            if (!hadBarOwnership) {
                restoreBar = screenState.bar;
                hadBarOwnership = true;
            }
            pendingReader = activeReader;
            if (displayedReader) {
                displayedReader = activeReader;
                contentReader = activeReader;
                pendingReader = "";
            } else {
                displayedReader = "";
                contentReader = "";
            }
            suppressBar = true;
            screenState.bar = false;
            Qt.callLater(revealWhenBarClosed);
        } else {
            pendingReader = "";
            displayedReader = "";
            Qt.callLater(restoreBarWhenClosed);
        }
    }

    onWidthChanged: restoreBarWhenClosed()

    Connections {
        target: root.bar
        function onImplicitWidthChanged(): void { root.revealWhenBarClosed(); }
    }

    Keys.onEscapePressed: Readers.close()

    Item {
        width: root.novelFullscreen ? root.parent.width : root.panelWidth
        height: root.height
        Item {
            id: flyoutHeader

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 64

            Divider {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
            }

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Tokens.padding.large
                text: root.contentReader === "manga" ? "Manga" : "Novels"
                color: Colours.palette.m3onSurface
                font: Tokens.font.title.medium
            }

            Controls.IconButton {
                anchors.right: parent.right
                anchors.rightMargin: Tokens.padding.medium
                anchors.verticalCenter: parent.verticalCenter
                icon: "close"
                type: Controls.IconButton.Text
                onClicked: Readers.close()
            }
        }

        Loader {
            id: mangaPanel
            anchors.top: flyoutHeader.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            active: root.contentReader === "manga"
            asynchronous: true

            sourceComponent: MangaReader {
                anchors.fill: parent
                visible: true
            }
        }

        Loader {
            id: novelPanel
            anchors.top: flyoutHeader.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            active: root.contentReader === "novel"
            asynchronous: true

            sourceComponent: NovelReader {
                anchors.fill: parent
                visible: true
            }
        }
    }
}
