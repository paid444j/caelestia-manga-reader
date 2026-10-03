import QtQuick
import QtQuick.Layouts
import qs.services
import qs.components
import qs.modules.manga.components

Item {
    id: root
    property bool fullscreen: false
    property int tabIndex: 0
    property int pageIndex: 0
    property string selectedBookId: ""
    function showDetails(bookId) {
        selectedBookId = bookId;
        pageIndex = 1;
    }
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.pageIndex
            StackLayout {
                currentIndex: root.tabIndex
                BrowseView { onMangaSelected: bookId => root.showDetails(bookId) }
                LibraryView { onMangaSelected: bookId => root.showDetails(bookId) }
            }
            DetailView {
                bookId: root.selectedBookId
                onBackRequested: root.pageIndex = 0
                onChapterSelected: { reader.reset(); root.pageIndex = 2; }
            }
            ReaderView {
                id: reader
                onBackRequested: { root.fullscreen = false; root.pageIndex = 1; }
            }
        }
        ReaderNavigationBar {
            Layout.fillWidth: true
            visible: root.pageIndex === 0
            currentIndex: root.tabIndex
            onDestinationSelected: index => root.tabIndex = index
        }
    }
}
