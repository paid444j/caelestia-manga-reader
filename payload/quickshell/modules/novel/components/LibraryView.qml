import qs.modules.readers
import qs.services

BookLibrary {
    backend: Novel
    signal novelSelected(string novelId)
    onSelected: bookId => {
        Novel.fetchNovelDetail(bookId);
        novelSelected(bookId);
    }
}
