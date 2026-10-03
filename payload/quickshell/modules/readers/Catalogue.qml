import QtQuick
import QtQml.Models
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.components
import qs.components.controls as Controls
import qs.services

Item {
    id: root
    required property var backend
    property bool novel: false
    property string category: novel ? "hot" : ""
    readonly property var books: novel ? backend.novelList : backend.mangaList
    readonly property bool busy: novel ? backend.isFetchingNovel : backend.isFetchingManga
    readonly property string error: novel ? backend.novelError : backend.mangaError
    property bool pendingSearch: false
    signal selected(string bookId)

    function refresh() {
        if (busy) { pendingSearch = true; return; }
        pendingSearch = false;
        const query = search.text.trim();
        if (novel) {
            if (query) backend.searchNovels(query, "", "All", true);
            else if (category === "hot") backend.fetchHot();
            else backend.fetchLatest(true);
        } else if (query) backend.searchManga(query, true);
        else backend.fetchByOrigin(category, true);
    }
    onBusyChanged: if (!busy && pendingSearch) debounce.restart()
    Timer { id: debounce; interval: 350; onTriggered: root.refresh() }

    Controls.Menu {
        id: providerMenu
        attachTo: providerButton
        items: providerItems.instances
    }
    Instantiator {
        id: providerItems
        model: root.novel ? root.backend.availableProviders : []
        delegate: Controls.MenuItem {
            required property var modelData
            text: modelData.label
            icon: "language"
            onClicked: { search.clear(); root.category = "hot"; root.backend.switchProvider(modelData.name); }
        }
        property list<Controls.MenuItem> instances: []
        onObjectAdded: (index, object) => instances = [...instances, object]
        onObjectRemoved: (index, object) => instances = instances.filter(item => item !== object)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Tokens.padding.large
        spacing: Tokens.spacing.small
        RowLayout {
            Layout.fillWidth: true
            StyledText {
                Layout.fillWidth: true
                text: root.novel ? "Discover novels" : "Discover manga"
                font: Tokens.font.headline.small
            }
            Controls.IconButton {
                id: providerButton
                visible: root.novel
                icon: "language"
                type: Controls.IconButton.Text
                onClicked: providerMenu.expanded = !providerMenu.expanded
                ToolTip.visible: hovered
                ToolTip.text: root.novel ? "Source: " + root.backend.activeProvider : ""
            }

        }
        Controls.SearchBar {
            id: search
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            placeholderText: root.novel ? "Search novels" : "Search manga"
            onTextChanged: debounce.restart()
            onAccepted: { debounce.stop(); root.refresh(); }
            Keys.onEscapePressed: { clear(); focus = false; }
        }
        Flickable {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            contentWidth: categories.implicitWidth
            contentHeight: height
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            Row {
                id: categories
                spacing: 8
                Repeater {
                    model: root.novel ? [{label: "Popular", value: "hot"}, {label: "Latest", value: "latest"}]
                        : [{label: "Popular", value: ""}, {label: "Latest", value: "latest"}, {label: "Manga", value: "ja"}, {label: "Manhwa", value: "ko"}, {label: "Manhua", value: "zh"}]
                    FilterChip {
                        required property var modelData
                        text: modelData.label
                        selected: root.category === modelData.value && !search.text.trim()
                        onClicked: {
                            root.category = modelData.value;
                            search.clear(); debounce.stop(); root.refresh();
                            grid.positionViewAtBeginning();
                        }
                    }
                }
            }
        }
        Controls.StyledProgressBar {
            Layout.fillWidth: true
            visible: root.busy && root.books.length > 0
            indeterminate: visible
        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            ReaderStatus {
                anchors.centerIn: parent
                width: Math.min(parent.width - 32, 360)
                visible: root.books.length === 0
                busy: root.busy
                icon: root.error ? "cloud_off" : "search_off"
                title: root.busy ? "Loading titles" : root.error ? "Couldn't load titles" : "No titles found"
                message: root.error || (root.busy ? "" : "Try another search or category.")
                action: root.error ? "Retry" : ""
                onActionRequested: root.refresh()
            }
            GridView {
                id: grid
                anchors.fill: parent
                visible: root.books.length > 0
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                cellWidth: width / Math.max(2, Math.floor(width / 180))
                cellHeight: cellWidth * 1.65
                model: ScriptModel { values: root.books }
                ScrollBar.vertical: Controls.StyledScrollBar { flickable: grid }
                onContentYChanged: {
                    if (contentY + height > contentHeight - cellHeight * 2 && !root.busy) {
                        if (root.novel) root.backend.fetchNextPage();
                        else root.backend.fetchNextMangaPage();
                    }
                }
                delegate: Item {
                    required property var modelData
                    width: grid.cellWidth
                    height: grid.cellHeight
                    CoverCard {
                        anchors.fill: parent
                        source: modelData.coverUrl || modelData.thumbUrl || ""
                        title: modelData.title || ""
                        gradientHeight: 0
                        onClicked: root.selected(modelData.id)
                    }
                }
            }
        }
    }
}
