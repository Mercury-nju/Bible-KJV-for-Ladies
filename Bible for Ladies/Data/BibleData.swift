import Foundation

struct BibleData {
    // MARK: - Books of the Bible (KJV)
    static let books: [BibleBook] = [
        // Old Testament
        BibleBook(id: 1, name: "Genesis", abbrev: "Gen", chapters: 50, testament: .old),
        BibleBook(id: 2, name: "Exodus", abbrev: "Exod", chapters: 40, testament: .old),
        BibleBook(id: 3, name: "Leviticus", abbrev: "Lev", chapters: 27, testament: .old),
        BibleBook(id: 4, name: "Numbers", abbrev: "Num", chapters: 36, testament: .old),
        BibleBook(id: 5, name: "Deuteronomy", abbrev: "Deut", chapters: 34, testament: .old),
        BibleBook(id: 6, name: "Joshua", abbrev: "Josh", chapters: 24, testament: .old),
        BibleBook(id: 7, name: "Judges", abbrev: "Judg", chapters: 21, testament: .old),
        BibleBook(id: 8, name: "Ruth", abbrev: "Ruth", chapters: 4, testament: .old),
        BibleBook(id: 9, name: "1 Samuel", abbrev: "1Sam", chapters: 31, testament: .old),
        BibleBook(id: 10, name: "2 Samuel", abbrev: "2Sam", chapters: 24, testament: .old),
        BibleBook(id: 11, name: "1 Kings", abbrev: "1Kgs", chapters: 22, testament: .old),
        BibleBook(id: 12, name: "2 Kings", abbrev: "2Kgs", chapters: 25, testament: .old),
        BibleBook(id: 13, name: "1 Chronicles", abbrev: "1Chr", chapters: 29, testament: .old),
        BibleBook(id: 14, name: "2 Chronicles", abbrev: "2Chr", chapters: 36, testament: .old),
        BibleBook(id: 15, name: "Ezra", abbrev: "Ezra", chapters: 10, testament: .old),
        BibleBook(id: 16, name: "Nehemiah", abbrev: "Neh", chapters: 13, testament: .old),
        BibleBook(id: 17, name: "Esther", abbrev: "Esth", chapters: 10, testament: .old),
        BibleBook(id: 18, name: "Job", abbrev: "Job", chapters: 42, testament: .old),
        BibleBook(id: 19, name: "Psalms", abbrev: "Ps", chapters: 150, testament: .old),
        BibleBook(id: 20, name: "Proverbs", abbrev: "Prov", chapters: 31, testament: .old),
        BibleBook(id: 21, name: "Ecclesiastes", abbrev: "Eccl", chapters: 12, testament: .old),
        BibleBook(id: 22, name: "Song of Solomon", abbrev: "Song", chapters: 8, testament: .old),
        BibleBook(id: 23, name: "Isaiah", abbrev: "Isa", chapters: 66, testament: .old),
        BibleBook(id: 24, name: "Jeremiah", abbrev: "Jer", chapters: 52, testament: .old),
        BibleBook(id: 25, name: "Lamentations", abbrev: "Lam", chapters: 5, testament: .old),
        BibleBook(id: 26, name: "Ezekiel", abbrev: "Ezek", chapters: 48, testament: .old),
        BibleBook(id: 27, name: "Daniel", abbrev: "Dan", chapters: 12, testament: .old),
        BibleBook(id: 28, name: "Hosea", abbrev: "Hos", chapters: 14, testament: .old),
        BibleBook(id: 29, name: "Joel", abbrev: "Joel", chapters: 3, testament: .old),
        BibleBook(id: 30, name: "Amos", abbrev: "Amos", chapters: 9, testament: .old),
        BibleBook(id: 31, name: "Obadiah", abbrev: "Obad", chapters: 1, testament: .old),
        BibleBook(id: 32, name: "Jonah", abbrev: "Jonah", chapters: 4, testament: .old),
        BibleBook(id: 33, name: "Micah", abbrev: "Mic", chapters: 7, testament: .old),
        BibleBook(id: 34, name: "Nahum", abbrev: "Nah", chapters: 3, testament: .old),
        BibleBook(id: 35, name: "Habakkuk", abbrev: "Hab", chapters: 3, testament: .old),
        BibleBook(id: 36, name: "Zephaniah", abbrev: "Zeph", chapters: 3, testament: .old),
        BibleBook(id: 37, name: "Haggai", abbrev: "Hag", chapters: 2, testament: .old),
        BibleBook(id: 38, name: "Zechariah", abbrev: "Zech", chapters: 14, testament: .old),
        BibleBook(id: 39, name: "Malachi", abbrev: "Mal", chapters: 4, testament: .old),
        // New Testament
        BibleBook(id: 40, name: "Matthew", abbrev: "Matt", chapters: 28, testament: .new),
        BibleBook(id: 41, name: "Mark", abbrev: "Mark", chapters: 16, testament: .new),
        BibleBook(id: 42, name: "Luke", abbrev: "Luke", chapters: 24, testament: .new),
        BibleBook(id: 43, name: "John", abbrev: "John", chapters: 21, testament: .new),
        BibleBook(id: 44, name: "Acts", abbrev: "Acts", chapters: 28, testament: .new),
        BibleBook(id: 45, name: "Romans", abbrev: "Rom", chapters: 16, testament: .new),
        BibleBook(id: 46, name: "1 Corinthians", abbrev: "1Cor", chapters: 16, testament: .new),
        BibleBook(id: 47, name: "2 Corinthians", abbrev: "2Cor", chapters: 13, testament: .new),
        BibleBook(id: 48, name: "Galatians", abbrev: "Gal", chapters: 6, testament: .new),
        BibleBook(id: 49, name: "Ephesians", abbrev: "Eph", chapters: 6, testament: .new),
        BibleBook(id: 50, name: "Philippians", abbrev: "Phil", chapters: 4, testament: .new),
        BibleBook(id: 51, name: "Colossians", abbrev: "Col", chapters: 4, testament: .new),
        BibleBook(id: 52, name: "1 Thessalonians", abbrev: "1Thess", chapters: 5, testament: .new),
        BibleBook(id: 53, name: "2 Thessalonians", abbrev: "2Thess", chapters: 3, testament: .new),
        BibleBook(id: 54, name: "1 Timothy", abbrev: "1Tim", chapters: 6, testament: .new),
        BibleBook(id: 55, name: "2 Timothy", abbrev: "2Tim", chapters: 4, testament: .new),
        BibleBook(id: 56, name: "Titus", abbrev: "Titus", chapters: 3, testament: .new),
        BibleBook(id: 57, name: "Philemon", abbrev: "Phlm", chapters: 1, testament: .new),
        BibleBook(id: 58, name: "Hebrews", abbrev: "Heb", chapters: 13, testament: .new),
        BibleBook(id: 59, name: "James", abbrev: "Jas", chapters: 5, testament: .new),
        BibleBook(id: 60, name: "1 Peter", abbrev: "1Pet", chapters: 5, testament: .new),
        BibleBook(id: 61, name: "2 Peter", abbrev: "2Pet", chapters: 3, testament: .new),
        BibleBook(id: 62, name: "1 John", abbrev: "1John", chapters: 5, testament: .new),
        BibleBook(id: 63, name: "2 John", abbrev: "2John", chapters: 1, testament: .new),
        BibleBook(id: 64, name: "3 John", abbrev: "3John", chapters: 1, testament: .new),
        BibleBook(id: 65, name: "Jude", abbrev: "Jude", chapters: 1, testament: .new),
        BibleBook(id: 66, name: "Revelation", abbrev: "Rev", chapters: 22, testament: .new)
    ]
    
    // MARK: - Cached Bible Data
    private static var cachedBible: [String: [[String]]]?
    
    private static func loadBible() -> [String: [[String]]]? {
        if let cached = cachedBible {
            return cached
        }
        
        guard let url = Bundle.main.url(forResource: "kjv", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let bible = try? JSONDecoder().decode([String: [[String]]].self, from: data) else {
            return nil
        }
        
        cachedBible = bible
        return bible
    }
    
    // MARK: - Load Chapter
    static func loadChapter(bookId: Int, chapter: Int) -> BibleChapter? {
        guard let bible = loadBible(),
              let book = books.first(where: { $0.id == bookId }),
              let bookData = bible[book.abbrev],
              chapter > 0 && chapter <= bookData.count else {
            return nil
        }
        
        let chapterVerses = bookData[chapter - 1]
        let verses = chapterVerses.enumerated().map { index, text in
            BibleVerse(bookId: bookId, chapter: chapter, verse: index + 1, text: text)
        }
        
        return BibleChapter(bookId: bookId, chapter: chapter, verses: verses)
    }
    
    // MARK: - Search
    static func search(query: String) -> [BibleVerse] {
        guard let bible = loadBible() else { return [] }
        
        var results: [BibleVerse] = []
        let lowercaseQuery = query.lowercased()
        
        for book in books {
            guard let bookData = bible[book.abbrev] else { continue }
            
            for (chapterIndex, chapter) in bookData.enumerated() {
                for (verseIndex, text) in chapter.enumerated() {
                    if text.lowercased().contains(lowercaseQuery) {
                        results.append(BibleVerse(
                            bookId: book.id,
                            chapter: chapterIndex + 1,
                            verse: verseIndex + 1,
                            text: text
                        ))
                    }
                }
            }
            
            if results.count >= 100 { break }
        }
        
        return results
    }
}
