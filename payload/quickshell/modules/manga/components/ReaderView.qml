import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls as Controls
import qs.modules.readers
import qs.services

Item {
    id: root
    signal backRequested()
    property int pageNumber: 1
    readonly property var chapters: (Manga.currentManga?.chapters ?? []).slice().sort((a,b) => parseFloat(String(a.chapter).replace(/[^0-9.]/g, "")) - parseFloat(String(b.chapter).replace(/[^0-9.]/g, "")))
    readonly property int chapterIndex: chapters.findIndex(ch => ch.id === Manga.currentChapterId)
    function reset() { pages.positionViewAtBeginning(); pageNumber = 1; }
    function openChapter(index) {
        const chapter = chapters[index];
        if (!chapter) return;
        Manga.fetchChapterPages(chapter.id);
        if (Manga.currentManga && Manga.isInLibrary(Manga.currentManga.id))
            Manga.updateLastRead(Manga.currentManga.id, chapter.id, chapter.chapter);
        reset();
    }
    ColumnLayout {
        anchors.fill: parent
        spacing: Tokens.spacing.small
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: Tokens.padding.medium
            Controls.IconButton {
                icon: "arrow_back"
                type: Controls.IconButton.Text
                onClicked: root.backRequested()
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                StyledText {
                    Layout.fillWidth: true
                    text: Manga.currentManga?.title ?? ""
                    font: Tokens.font.title.small
                    elide: Text.ElideRight
                }
                StyledText {
                    Layout.fillWidth: true
                    text: root.chapters[root.chapterIndex]?.title || "Chapter " + (root.chapters[root.chapterIndex]?.chapter ?? "")
                    font: Tokens.font.body.small
                    color: Colours.palette.m3onSurfaceVariant
                    elide: Text.ElideRight
                }
            }
            StyledText {
                text: Manga.chapterPages.length ? root.pageNumber + " / " + Manga.chapterPages.length : ""
                font: Tokens.font.label.large
                color: Colours.palette.m3onSurfaceVariant
            }
        }
        Controls.StyledProgressBar {
            Layout.fillWidth: true
            Layout.leftMargin: Tokens.padding.large
            Layout.rightMargin: Tokens.padding.large
            indeterminate: Manga.isFetchingPages
            value: Manga.chapterPages.length ? root.pageNumber / Manga.chapterPages.length : 0
        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            ReaderStatus {
                anchors.centerIn: parent
                width: Math.min(parent.width - 32, 360)
                visible: Manga.isFetchingPages || Manga.pagesError.length > 0 || Manga.chapterPages.length === 0
                busy: Manga.isFetchingPages
                icon: "broken_image"
                title: Manga.isFetchingPages ? "Loading chapter" : "Pages unavailable"
                message: Manga.pagesError
                action: "Retry"
                onActionRequested: Manga.refreshChapterPages()
            }
            ListView {
                id: pages
                anchors.fill: parent
                visible: !Manga.isFetchingPages && !Manga.pagesError
                model: Manga.chapterPages
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                cacheBuffer: height
                ScrollBar.vertical: Controls.StyledScrollBar { flickable: pages }
                onContentYChanged: {
                    const index = indexAt(width / 2, contentY + height / 2);
                    if (index >= 0) root.pageNumber = index + 1;
                }
                delegate: Item {
                    required property var modelData
                    width: pages.width
                    height: page.implicitHeight > 0 ? page.implicitHeight * width / page.implicitWidth : width * 1.42
                    Image {
                        id: page
                        anchors.fill: parent
                        source: modelData.url || ""
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                    }
                    ReaderStatus {
                        anchors.centerIn: parent
                        width: Math.min(parent.width - 32, 320)
                        visible: page.status !== Image.Ready
                        busy: page.status === Image.Loading
                        icon: "broken_image"
                        title: page.status === Image.Error ? "Couldn't load page" : "Loading page"
                        action: page.status === Image.Error ? "Retry" : ""
                        onActionRequested: { const url = page.source; page.source = ""; page.source = url; }
                    }
                }
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: Tokens.padding.medium
            Controls.IconTextButton {
                icon: "chevron_left"
                text: "Previous"
                type: Controls.IconTextButton.Tonal
                disabled: root.chapterIndex <= 0 || Manga.isFetchingPages
                onClicked: root.openChapter(root.chapterIndex - 1)
            }
            Item { Layout.fillWidth: true }
            Controls.IconTextButton {
                icon: "chevron_right"
                text: "Next chapter"
                disabled: root.chapterIndex < 0 || root.chapterIndex + 1 >= root.chapters.length || Manga.isFetchingPages
                onClicked: root.openChapter(root.chapterIndex + 1)
            }
        }
    }
}
