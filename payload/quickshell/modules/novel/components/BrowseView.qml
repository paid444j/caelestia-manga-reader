import qs.modules.readers
import qs.services

Catalogue {
    backend: Novel
    novel: true
    signal novelSelected(string novelId)
    onSelected: bookId => {
        Novel.fetchNovelDetail(bookId);
        novelSelected(bookId);
    }
}
