import SwiftUI

struct BookmarksView: View {
    @Environment(DataManager.self) var dataManager
    @AppStorage("selectedTheme") private var selectedTheme = "roseGold"
    
    @State private var bookmarks: [Bookmark] = []
    @State private var showDeleteConfirm = false
    @State private var bookmarkToDelete: Bookmark?
    
    var onNavigate: ((Int, Int) -> Void)?
    
    private var theme: ThemeColors {
        ThemeManager.theme(for: selectedTheme)
    }
    
    // Group bookmarks by book
    private var groupedBookmarks: [(BibleBook, [Bookmark])] {
        let grouped = Dictionary(grouping: bookmarks) { $0.bookId }
        return grouped.compactMap { bookId, bookmarks -> (BibleBook, [Bookmark])? in
            guard let book = dataManager.bibleBooks.first(where: { $0.id == bookId }) else { return nil }
            let sorted = bookmarks.sorted { ($0.chapter, $0.verse ?? 0) < ($1.chapter, $1.verse ?? 0) }
            return (book, sorted)
        }.sorted { $0.0.id < $1.0.id }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background with decoration
                DecoratedBackground(theme: theme)
                
                if bookmarks.isEmpty {
                    emptyState
                } else {
                    bookmarksList
                }
            }
            .navigationTitle("Bookmarks")
            .alert("Delete Bookmark", isPresented: $showDeleteConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let bookmark = bookmarkToDelete {
                        deleteBookmark(bookmark)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this bookmark?")
            }
            .onAppear {
                loadBookmarks()
            }
        }
    }
    
    // MARK: - Bookmarks List
    private var bookmarksList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                ForEach(groupedBookmarks, id: \.0.id) { book, bookBookmarks in
                    Section {
                        ForEach(bookBookmarks, id: \.createdAt) { bookmark in
                            bookmarkRow(bookmark, book: book)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
                        }
                    } header: {
                        sectionHeader(book.name, count: bookBookmarks.count)
                    }
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
    }
    
    private func sectionHeader(_ title: String, count: Int) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(theme.text.opacity(0.6))
            
            Text("\(count)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(theme.primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    Capsule().fill(theme.primary.opacity(0.15))
                )
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(theme.background)
    }
    
    private func bookmarkRow(_ bookmark: Bookmark, book: BibleBook) -> some View {
        Button {
            onNavigate?(bookmark.bookId, bookmark.chapter)
        } label: {
            HStack(spacing: 14) {
                // Bookmark Icon
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 16))
                    .foregroundColor(theme.primary)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle().fill(theme.primary.opacity(0.15))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    // Reference
                    Text("\(book.name) \(bookmark.chapter)\(bookmark.verse.map { ":\($0)" } ?? "")")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(theme.text)
                    
                    // Date
                    Text(formatDate(bookmark.createdAt))
                        .font(.system(size: 12))
                        .foregroundColor(theme.text.opacity(0.4))
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .foregroundColor(theme.text.opacity(0.3))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(theme.secondary.opacity(0.4))
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                bookmarkToDelete = bookmark
                showDeleteConfirm = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                bookmarkToDelete = bookmark
                showDeleteConfirm = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "bookmark")
                .font(.system(size: 56, weight: .thin))
                .foregroundColor(theme.primary.opacity(0.4))
            
            VStack(spacing: 8) {
                Text("No bookmarks yet")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(theme.text.opacity(0.7))
                
                Text("Tap on a verse while reading to add bookmarks\nfor quick access later")
                    .font(.system(size: 14))
                    .foregroundColor(theme.text.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
    
    // MARK: - Helpers
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d  HH:mm"
        return formatter.string(from: date)
    }
    
    private func loadBookmarks() {
        bookmarks = dataManager.fetchBookmarks()
    }
    
    private func deleteBookmark(_ bookmark: Bookmark) {
        withAnimation {
            dataManager.deleteBookmark(bookmark)
            loadBookmarks()
        }
    }
}

#Preview {
    BookmarksView()
        .environment(DataManager())
}
