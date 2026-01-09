import SwiftUI

struct SearchView: View {
    @Environment(DataManager.self) var dataManager
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedTheme") private var selectedTheme = "roseGold"
    
    @State private var searchText = ""
    @State private var searchResults: [BibleVerse] = []
    @State private var isSearching = false
    @State private var recentSearches: [String] = []
    @State private var selectedVerse: BibleVerse?
    
    var onNavigate: ((Int, Int) -> Void)?
    
    @FocusState private var isSearchFocused: Bool
    
    private var theme: ThemeColors {
        ThemeManager.theme(for: selectedTheme)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background with decoration
                DecoratedBackground(theme: theme)
                
                VStack(spacing: 0) {
                    // Search Bar
                    searchBar
                    
                    // Content
                    if searchText.isEmpty {
                        recentSearchesView
                    } else if isSearching {
                        loadingView
                    } else if searchResults.isEmpty {
                        emptyResultsView
                    } else {
                        resultsListView
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(theme.primary)
                }
            }
            .sheet(item: $selectedVerse) { verse in
                VerseDetailSheet(verse: verse, onNavigate: { bookId, chapter in
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onNavigate?(bookId, chapter)
                    }
                })
            }
            .onAppear {
                loadRecentSearches()
                isSearchFocused = true
            }
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundColor(theme.text.opacity(0.4))
                
                TextField("Search Verses...", text: $searchText)
                    .font(.system(size: 16))
                    .focused($isSearchFocused)
                    .submitLabel(.search)
                    .onSubmit {
                        performSearch()
                    }
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        searchResults = []
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(theme.text.opacity(0.3))
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(theme.secondary.opacity(0.5))
            )
            
            if !searchText.isEmpty {
                Button("Search") {
                    performSearch()
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(theme.primary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    // MARK: - Recent Searches
    private var recentSearchesView: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !recentSearches.isEmpty {
                HStack {
                    Text("Recent Searches")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(theme.text.opacity(0.5))
                    
                    Spacer()
                    
                    Button("Clear") {
                        clearRecentSearches()
                    }
                    .font(.system(size: 13))
                    .foregroundColor(theme.primary)
                }
                .padding(.horizontal, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(recentSearches, id: \.self) { search in
                            recentSearchRow(search)
                        }
                    }
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48, weight: .thin))
                        .foregroundColor(theme.primary.opacity(0.3))
                    
                    Text("Enter keywords to search verses")
                        .font(.system(size: 15))
                        .foregroundColor(theme.text.opacity(0.5))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(.top, 16)
    }
    
    private func recentSearchRow(_ search: String) -> some View {
        Button {
            searchText = search
            performSearch()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 14))
                    .foregroundColor(theme.text.opacity(0.4))
                
                Text(search)
                    .font(.system(size: 15))
                    .foregroundColor(theme.text)
                
                Spacer()
                
                Image(systemName: "arrow.up.left")
                    .font(.system(size: 12))
                    .foregroundColor(theme.text.opacity(0.3))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(theme.primary)
            
            Text("Searching...")
                .font(.system(size: 14))
                .foregroundColor(theme.text.opacity(0.5))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty Results
    private var emptyResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48, weight: .thin))
                .foregroundColor(theme.primary.opacity(0.3))
            
            Text("No results found")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(theme.text.opacity(0.6))
            
            Text("Try different keywords")
                .font(.system(size: 14))
                .foregroundColor(theme.text.opacity(0.4))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Results List
    private var resultsListView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Results Count
            Text("Found \(searchResults.count) results")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(theme.text.opacity(0.5))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(searchResults) { verse in
                        resultCard(verse)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
            }
        }
    }
    
    private func resultCard(_ verse: BibleVerse) -> some View {
        Button {
            selectedVerse = verse
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                // Reference
                if let book = dataManager.bibleBooks.first(where: { $0.id == verse.bookId }) {
                    Text("\(book.name) \(verse.chapter):\(verse.verse)")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(theme.primary)
                }
                
                // Text with highlighted search term
                Text(highlightedText(verse.text))
                    .font(.system(size: 15, design: .serif))
                    .foregroundColor(theme.text.opacity(0.85))
                    .lineSpacing(4)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(theme.secondary.opacity(0.4))
            )
        }
        .buttonStyle(.plain)
    }
    
    private func highlightedText(_ text: String) -> AttributedString {
        var attributedString = AttributedString(text)
        
        if let range = attributedString.range(of: searchText, options: .caseInsensitive) {
            attributedString[range].backgroundColor = theme.primary.opacity(0.25)
            attributedString[range].foregroundColor = theme.primary
        }
        
        return attributedString
    }
    
    // MARK: - Actions
    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        isSearchFocused = false
        isSearching = true
        
        // Save to recent searches
        saveRecentSearch(searchText)
        
        DispatchQueue.global(qos: .userInitiated).async {
            let results = BibleData.search(query: searchText)
            DispatchQueue.main.async {
                searchResults = results
                isSearching = false
            }
        }
    }
    
    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: "recentSearches") ?? []
    }
    
    private func saveRecentSearch(_ search: String) {
        var searches = recentSearches
        searches.removeAll { $0.lowercased() == search.lowercased() }
        searches.insert(search, at: 0)
        searches = Array(searches.prefix(10))
        recentSearches = searches
        UserDefaults.standard.set(searches, forKey: "recentSearches")
    }
    
    private func clearRecentSearches() {
        recentSearches = []
        UserDefaults.standard.removeObject(forKey: "recentSearches")
    }
}

// MARK: - Verse Detail Sheet
struct VerseDetailSheet: View {
    @Environment(DataManager.self) var dataManager
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedTheme") private var selectedTheme = "roseGold"
    
    let verse: BibleVerse
    var onNavigate: ((Int, Int) -> Void)?
    
    @State private var showQuickNote = false
    
    private var theme: ThemeColors {
        ThemeManager.theme(for: selectedTheme)
    }
    
    private var verseReference: String {
        guard let book = dataManager.bibleBooks.first(where: { $0.id == verse.bookId }) else {
            return ""
        }
        return "\(book.name) \(verse.chapter):\(verse.verse)"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Verse Text
                        Text(verse.text)
                            .font(.system(size: 20, design: .serif))
                            .foregroundColor(theme.text)
                            .lineSpacing(8)
                        
                        // Actions
                        VStack(spacing: 12) {
                            if onNavigate != nil {
                                actionButton(icon: "book.fill", title: "Go to Chapter") {
                                    onNavigate?(verse.bookId, verse.chapter)
                                    dismiss()
                                }
                            }
                            
                            actionButton(icon: "note.text.badge.plus", title: "Add Note") {
                                showQuickNote = true
                            }
                            
                            actionButton(icon: "bookmark", title: "Add Bookmark") {
                                dataManager.addBookmark(bookId: verse.bookId, chapter: verse.chapter, verse: verse.verse, title: verseReference)
                                dismiss()
                            }
                            
                            actionButton(icon: "doc.on.doc", title: "Copy Verse") {
                                UIPasteboard.general.string = "\(verse.text)\n— \(verseReference) (KJV)"
                                dismiss()
                            }
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle(verseReference)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(theme.primary)
                }
            }
            .sheet(isPresented: $showQuickNote) {
                QuickNoteSheet(verse: verse)
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    private func actionButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(theme.primary)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(theme.text)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
                    .foregroundColor(theme.text.opacity(0.3))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.secondary.opacity(0.5))
            )
        }
    }
}

#Preview {
    SearchView()
        .environment(DataManager())
}
