import qs.modules.readers
import qs.services

BookLibrary {
    backend: Manga
    signal mangaSelected(string mangaId)
    onSelected: bookId => {
        Manga.fetchMangaDetail(bookId);
        mangaSelected(bookId);
    }
}
