import qs.modules.readers
import qs.services

Catalogue {
    backend: Manga
    novel: false
    signal mangaSelected(string mangaId)
    onSelected: bookId => {
        Manga.fetchMangaDetail(bookId);
        mangaSelected(bookId);
    }
}
