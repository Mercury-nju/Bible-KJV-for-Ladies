import Foundation
import SwiftData
import SwiftUI
import Observation

@MainActor
@Observable
class DataManager {
    let container: ModelContainer
    let context: ModelContext
    
    var bibleBooks: [BibleBook] = []
    var currentChapter: BibleChapter?
    var lastReadingPosition: ReadingProgress?
    
    init() {
        do {
            let schema = Schema([
                Bookmark.self,
                Highlight.self,
                Note.self,
                ReadingProgress.self
            ])
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: config)
            context = container.mainContext
            loadBibleBooks()
            loadLastReadingPosition()
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    // MARK: - Bible Loading
    func loadBibleBooks() {
        bibleBooks = BibleData.books
    }
    
    func loadChapter(bookId: Int, chapter: Int) {
        // 强制清除旧数据，确保视图更新
        currentChapter = nil
        // 加载新数据
        currentChapter = BibleData.loadChapter(bookId: bookId, chapter: chapter)
    }
    
    // MARK: - Reading Progress
    func loadLastReadingPosition() {
        let descriptor = FetchDescriptor<ReadingProgress>(
            sortBy: [SortDescriptor(\.lastReadAt, order: .reverse)]
        )
        lastReadingPosition = try? context.fetch(descriptor).first
    }
    
    func saveReadingPosition(bookId: Int, chapter: Int, verse: Int = 1) {
        if let existing = lastReadingPosition {
            existing.bookId = bookId
            existing.chapter = chapter
            existing.verse = verse
            existing.lastReadAt = Date()
        } else {
            let progress = ReadingProgress(bookId: bookId, chapter: chapter, verse: verse)
            context.insert(progress)
            lastReadingPosition = progress
        }
        try? context.save()
    }
    
    // MARK: - Bookmarks
    func addBookmark(bookId: Int, chapter: Int, verse: Int? = nil, title: String? = nil) {
        let bookmark = Bookmark(bookId: bookId, chapter: chapter, verse: verse, title: title)
        context.insert(bookmark)
        try? context.save()
    }
    
    func deleteBookmark(_ bookmark: Bookmark) {
        context.delete(bookmark)
        try? context.save()
    }
    
    func fetchBookmarks() -> [Bookmark] {
        let descriptor = FetchDescriptor<Bookmark>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
    
    // MARK: - Highlights
    func addHighlight(bookId: Int, chapter: Int, verse: Int, colorHex: String) {
        let predicate = #Predicate<Highlight> { h in
            h.bookId == bookId && h.chapter == chapter && h.verse == verse
        }
        let descriptor = FetchDescriptor<Highlight>(predicate: predicate)
        if let existing = try? context.fetch(descriptor).first {
            context.delete(existing)
        }
        
        let highlight = Highlight(bookId: bookId, chapter: chapter, verse: verse, colorHex: colorHex)
        context.insert(highlight)
        try? context.save()
    }
    
    func removeHighlight(bookId: Int, chapter: Int, verse: Int) {
        let predicate = #Predicate<Highlight> { h in
            h.bookId == bookId && h.chapter == chapter && h.verse == verse
        }
        let descriptor = FetchDescriptor<Highlight>(predicate: predicate)
        if let highlight = try? context.fetch(descriptor).first {
            context.delete(highlight)
            try? context.save()
        }
    }
    
    func fetchHighlights(bookId: Int, chapter: Int) -> [Highlight] {
        let predicate = #Predicate<Highlight> { h in
            h.bookId == bookId && h.chapter == chapter
        }
        let descriptor = FetchDescriptor<Highlight>(predicate: predicate)
        return (try? context.fetch(descriptor)) ?? []
    }
    
    // MARK: - Notes
    func addNote(bookId: Int? = nil, chapter: Int? = nil, verse: Int? = nil,
                 title: String, content: String, tags: [String] = [], isFreeNote: Bool = false) {
        let note = Note(bookId: bookId, chapter: chapter, verse: verse,
                       title: title, content: content, tags: tags, isFreeNote: isFreeNote)
        context.insert(note)
        try? context.save()
    }
    
    func updateNote(_ note: Note, title: String, content: String, tags: [String]) {
        note.title = title
        note.content = content
        note.tags = tags
        note.updatedAt = Date()
        try? context.save()
    }
    
    func deleteNote(_ note: Note) {
        context.delete(note)
        try? context.save()
    }
    
    func fetchNotes() -> [Note] {
        let descriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func fetchNotes(bookId: Int, chapter: Int, verse: Int) -> [Note] {
        let predicate = #Predicate<Note> { n in
            n.bookId == bookId && n.chapter == chapter && n.verse == verse
        }
        let descriptor = FetchDescriptor<Note>(predicate: predicate)
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func searchNotes(query: String) -> [Note] {
        let predicate = #Predicate<Note> { n in
            n.title.localizedStandardContains(query) || n.content.localizedStandardContains(query)
        }
        let descriptor = FetchDescriptor<Note>(predicate: predicate)
        return (try? context.fetch(descriptor)) ?? []
    }
}
