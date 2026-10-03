import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls as Controls
import qs.modules.nexus.common as Nexus
import qs.services

Item {
    id: root
    required property var backend
    property bool novel: false
    property string bookId: ""
    readonly property var book: novel ? backend.currentNovel : backend.currentManga
    readonly property bool inLibrary: book ? backend.isInLibrary(book.id) : false
    readonly property var entry: book ? backend.getLibraryEntry(book.id) : null
    property string chapterQuery: ""
    property bool ascending: false
    property bool expandedDescription: false
    readonly property var chapters: (book?.chapters ?? []).slice().sort((a, b) => chapterNumber(a) - chapterNumber(b))
    readonly property var filteredChapters: {
        let items = chapters.filter(ch => ((ch.title || "") + " " + ch.chapter).toLowerCase().includes(chapterQuery.trim().toLowerCase()));
        return ascending ? items : items.reverse();
    }
    readonly property int resumeIndex: entry ? chapters.findIndex(ch => ch.id === entry.lastReadChapterId) : -1
    signal backRequested()
    signal chapterSelected(string chapterId)
    function chapterNumber(ch) {
        const match = String(ch.chapter || ch.title || "").match(/\d+(\.\d+)?/);
        return match ? Number(match[0]) : 0;
    }
    function openChapter(ch) {
        if (!ch) return;
        if (novel) backend.fetchChapter(ch.id); else backend.fetchChapterPages(ch.id);
        if (inLibrary) backend.updateLastRead(book.id, ch.id, ch.chapter);
        chapterSelected(ch.id);
    }
    function retry() {
        if (novel) backend.fetchNovelDetail(bookId); else backend.fetchMangaDetail(bookId);
    }
    function reset() { chapterQuery = ""; ascending = false; expandedDescription = false; }
    onBookIdChanged: { reset(); chaptersView.positionViewAtBeginning(); }

    ColumnLayout {
        anchors.fill: parent
        spacing: Tokens.spacing.small
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Tokens.padding.medium
            Layout.rightMargin: Tokens.padding.medium
            Layout.preferredHeight: 56
            Controls.IconButton {
                icon: "arrow_back"
                type: Controls.IconButton.Text
                onClicked: root.backRequested()
            }
            StyledText {
                Layout.fillWidth: true
                text: "Title details"
                font: Tokens.font.title.medium
            }
            Controls.IconTextButton {
                visible: root.book !== null
                icon: root.inLibrary ? "bookmark_added" : "bookmark_add"
                text: root.inLibrary ? "Saved" : "Save"
                type: Controls.IconTextButton.Tonal
                onClicked: {
                    if (root.inLibrary) root.backend.removeFromLibrary(root.book.id);
                    else root.backend.addToLibrary(root.book);
                }
            }
        }
        Controls.StyledProgressBar {
            Layout.fillWidth: true
            visible: root.backend.isFetchingDetail
            indeterminate: visible
        }
        ReaderStatus {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Tokens.padding.large
            visible: !root.book
            busy: root.backend.isFetchingDetail
            icon: "cloud_off"
            title: root.backend.isFetchingDetail ? "Loading details" : "Couldn't load this title"
            message: root.backend.detailError
            action: "Retry"
            onActionRequested: root.retry()
        }
        ListView {
            id: chaptersView
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: Tokens.padding.large
            Layout.rightMargin: Tokens.padding.large
            Layout.bottomMargin: Tokens.padding.large
            visible: root.book !== null
            model: root.filteredChapters
            spacing: Tokens.spacing.extraSmall
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: Controls.StyledScrollBar { flickable: chaptersView }
            header: ColumnLayout {
                width: chaptersView.width
                spacing: Tokens.spacing.large
                StyledRect {
                    Layout.fillWidth: true
                    implicitHeight: summary.implicitHeight + Tokens.padding.large * 2
                    radius: Tokens.rounding.large
                    color: Colours.tPalette.m3surfaceContainer
                    RowLayout {
                        id: summary
                        anchors.fill: parent
                        anchors.margins: Tokens.padding.large
                        spacing: Tokens.spacing.large
                        StyledClippingRect {
                            Layout.preferredWidth: 104
                            Layout.preferredHeight: 152
                            Layout.alignment: Qt.AlignTop
                            radius: Tokens.rounding.medium
                            color: Colours.tPalette.m3surfaceContainerHigh
                            Image {
                                anchors.fill: parent
                                source: root.book?.coverUrl ?? ""
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignTop
                            spacing: Tokens.spacing.small
                            StyledText {
                                Layout.fillWidth: true
                                text: root.book?.title ?? ""
                                textFormat: Text.PlainText
                                font: Tokens.font.title.large
                                wrapMode: Text.Wrap
                            }
                            StyledText {
                                Layout.fillWidth: true
                                text: root.novel ? root.book?.author ?? "" : (root.book?.authors ?? []).join(", ")
                                font: Tokens.font.body.small
                                color: Colours.palette.m3onSurfaceVariant
                                wrapMode: Text.Wrap
                            }
                            StyledText {
                                Layout.fillWidth: true
                                text: [root.book?.status ?? "", root.chapters.length + " chapters"].filter(Boolean).join(" · ")
                                font: Tokens.font.label.large
                                color: Colours.palette.m3primary
                                wrapMode: Text.Wrap
                            }
                        }
                    }
                }
                StyledText {
                    Layout.fillWidth: true
                    visible: root.novel && (root.book?.genres ?? []).length > 0
                    text: (root.book?.genres ?? []).join(" · ")
                    font: Tokens.font.label.large
                    color: Colours.palette.m3onSurfaceVariant
                    wrapMode: Text.Wrap
                }
                StyledText {
                    Layout.fillWidth: true
                    text: root.book?.description || "No synopsis available."
                    textFormat: Text.PlainText
                    font: Tokens.font.body.small
                    wrapMode: Text.Wrap
                    maximumLineCount: root.expandedDescription ? 10000 : 4
                    elide: Text.ElideRight
                }
                Controls.TextButton {
                    visible: (root.book?.description ?? "").length > 180
                    text: root.expandedDescription ? "Show less" : "Read synopsis"
                    type: Controls.TextButton.Text
                    onClicked: root.expandedDescription = !root.expandedDescription
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Tokens.spacing.small
                    Controls.IconTextButton {
                        Layout.fillWidth: true
                        icon: "play_arrow"
                        text: root.resumeIndex >= 0 ? "Continue reading" : "Start reading"
                        disabled: root.chapters.length === 0
                        onClicked: root.openChapter(root.chapters[Math.max(0, root.resumeIndex)])
                    }
                    Controls.IconTextButton {
                        visible: root.resumeIndex >= 0
                        icon: "skip_next"
                        text: "Next chapter"
                        type: Controls.IconTextButton.Tonal
                        disabled: root.resumeIndex + 1 >= root.chapters.length
                        onClicked: root.openChapter(root.chapters[root.resumeIndex + 1])
                    }
                }
                Nexus.RowButton {
                    visible: root.novel && !!root.book?.partial
                    first: true
                    last: true
                    text: "Load remaining chapters"
                    subtext: "The source returned an incomplete chapter list."
                    icon: "refresh"
                    onClicked: root.backend.retryDetail()
                }
                RowLayout {
                    Layout.fillWidth: true
                    StyledText {
                        Layout.fillWidth: true
                        text: "Chapters"
                        font: Tokens.font.title.medium
                    }
                    Controls.IconTextButton {
                        text: root.ascending ? "Oldest first" : "Newest first"
                        icon: root.ascending ? "arrow_upward" : "arrow_downward"
                        type: Controls.IconTextButton.Text
                        onClicked: root.ascending = !root.ascending
                    }
                }
                Controls.SearchBar {
                    id: chapterSearch
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    placeholderText: "Find a chapter"
                    text: root.chapterQuery
                    onTextChanged: root.chapterQuery = text
                }
                StyledText {
                    Layout.fillWidth: true
                    visible: root.filteredChapters.length === 0
                    text: root.chapters.length ? "No matching chapters" : "No chapters available"
                    font: Tokens.font.body.small
                    color: Colours.palette.m3onSurfaceVariant
                }
                Item { Layout.preferredHeight: Tokens.spacing.small }
            }
            delegate: Nexus.RowButton {
                required property var modelData
                required property int index
                width: chaptersView.width
                first: index === 0
                last: index === chaptersView.count - 1
                icon: root.entry?.lastReadChapterId === modelData.id ? "bookmark" : "menu_book"
                text: modelData.title || "Chapter " + modelData.chapter
                subtext: "Chapter " + (modelData.chapter || "—") + (modelData.publishAt ? " · " + Qt.formatDate(new Date(modelData.publishAt), "MMM d, yyyy") : "")
                trailingIcon: "chevron_right"
                label.font: Tokens.font.body.medium
                onClicked: root.openChapter(modelData)
            }
        }
    }
}
