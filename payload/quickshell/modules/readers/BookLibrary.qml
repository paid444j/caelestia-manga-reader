import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls as Controls
import qs.services

Item {
    id: root
    required property var backend
    signal selected(string bookId)
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Tokens.padding.large
        spacing: Tokens.spacing.large
        StyledText { text: "Your library"; font: Tokens.font.headline.small }
        Controls.SearchBar {
            id: search
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            visible: root.backend.libraryList.length > 0
            placeholderText: "Search your library"
        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            ReaderStatus {
                anchors.centerIn: parent
                width: Math.min(parent.width - 32, 360)
                visible: grid.count === 0
                busy: !root.backend.libraryLoaded
                icon: "bookmarks"
                title: !root.backend.libraryLoaded ? "Loading library" : search.text ? "No matching titles" : "Your library is empty"
                message: search.text ? "Try another title." : "Save a title from its details page to find it here."
            }
            GridView {
                id: grid
                anchors.fill: parent
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                cellWidth: width / Math.max(2, Math.floor(width / 180))
                cellHeight: cellWidth * 1.8
                model: root.backend.libraryList.filter(book => book.title.toLowerCase().includes(search.text.trim().toLowerCase()))
                ScrollBar.vertical: Controls.StyledScrollBar { flickable: grid }
                delegate: Item {
                    required property var modelData
                    width: grid.cellWidth
                    height: grid.cellHeight
                    CoverCard {
                        anchors.fill: parent
                        source: modelData.coverUrl || ""
                        title: modelData.title || ""
                        gradientHeight: 0
                        footerHeight: 36
                        StyledText {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.margins: 12
                            text: modelData.lastReadChapterNum ? "Chapter " + modelData.lastReadChapterNum : "Not started"
                            font: Tokens.font.label.medium
                            color: Colours.palette.m3onSurfaceVariant
                            elide: Text.ElideRight
                        }
                        onClicked: root.selected(modelData.id)
                    }
                }
            }
        }
    }
}
