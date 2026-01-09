import Foundation
import SwiftData

// MARK: - Bible Structure
struct BibleBook: Codable, Identifiable {
    let id: Int
    let name: String
    let abbrev: String
    let chapters: Int
    let testament: Testament
    
    enum Testament: String, Codable {
        case old = "OT"
        case new = "NT"
    }
}

struct BibleChapter: Codable, Identifiable {
    var id: String { "\(bookId)_\(chapter)" }
    let bookId: Int
    let chapter: Int
    let verses: [BibleVerse]
}

struct BibleVerse: Codable, Identifiable {
    var id: String { "\(bookId)_\(chapter)_\(verse)" }
    let bookId: Int
    let chapter: Int
    let verse: Int
    let text: String
}

// MARK: - SwiftData Models
@Model
final class Bookmark {
    var bookId: Int
    var chapter: Int
    var verse: Int?
    var createdAt: Date
    var title: String?
    
    init(bookId: Int, chapter: Int, verse: Int? = nil, title: String? = nil) {
        self.bookId = bookId
        self.chapter = chapter
        self.verse = verse
        self.createdAt = Date()
        self.title = title
    }
}

@Model
final class Highlight {
    var bookId: Int
    var chapter: Int
    var verse: Int
    var colorHex: String
    var createdAt: Date
    
    init(bookId: Int, chapter: Int, verse: Int, colorHex: String) {
        self.bookId = bookId
        self.chapter = chapter
        self.verse = verse
        self.colorHex = colorHex
        self.createdAt = Date()
    }
}

@Model
final class Note {
    var id: UUID
    var bookId: Int?
    var chapter: Int?
    var verse: Int?
    var title: String
    var content: String
    var tags: [String]
    var imageData: [Data]
    var createdAt: Date
    var updatedAt: Date
    var isFreeNote: Bool
    
    init(bookId: Int? = nil, chapter: Int? = nil, verse: Int? = nil, 
         title: String = "", content: String = "", tags: [String] = [],
         isFreeNote: Bool = false) {
        self.id = UUID()
        self.bookId = bookId
        self.chapter = chapter
        self.verse = verse
        self.title = title
        self.content = content
        self.tags = tags
        self.imageData = []
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isFreeNote = isFreeNote
    }
}

@Model
final class ReadingProgress {
    var bookId: Int
    var chapter: Int
    var verse: Int
    var lastReadAt: Date
    
    init(bookId: Int, chapter: Int, verse: Int = 1) {
        self.bookId = bookId
        self.chapter = chapter
        self.verse = verse
        self.lastReadAt = Date()
    }
}
