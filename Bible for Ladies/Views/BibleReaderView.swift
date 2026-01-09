import SwiftUI

struct BibleReaderView: View {
    @Environment(DataManager.self) var dataManager
    @AppStorage("selectedTheme") private var selectedTheme = "roseGold"
    @AppStorage("fontSize") private var fontSize: Double = 18
    @AppStorage("lineSpacing") private var lineSpacing: Double = 8
    
    // Navigation from other tabs
    @Binding var initialBookId: Int?
    @Binding var initialChapter: Int?
    
    @State private var selectedBookId: Int = 1
    @State private var selectedChapter: Int = 1
    @State private var showBookPicker = false
    @State private var showSearch = false
    @State private var selectedVerses: Set<Int> = []
    @State private var showVerseMenu = false
    @State private var highlights: [Int: String] = [:]
    @State private var verseNotes: [Int: Bool] = [:] // verse -> hasNote
    @State private var dragOffset: CGFloat = 0
    @State private var showQuickNote = false
    @State private var quickNoteVerse: BibleVerse?
    @State private var showVerseCard = false
    @State private var cardVerse: BibleVerse?
    @State private var showBookmarkToast = false
    
    init(initialBookId: Binding<Int?> = .constant(nil), initialChapter: Binding<Int?> = .constant(nil)) {
        self._initialBookId = initialBookId
        self._initialChapter = initialChapter
    }
    
    private var theme: ThemeColors {
        ThemeManager.theme(for: selectedTheme)
    }
    
    private var currentBook: BibleBook? {
        dataManager.bibleBooks.first { $0.id == selectedBookId }
    }
    
    var body: some View {
        ZStack {
            // Base background color
            theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Fixed Header area
                ZStack {
                    // Header content
                    VStack(alignment: .leading, spacing: 0) {
                        headerView
                        
                        // Chapter number
                        Text("\(selectedChapter)")
                            .font(.system(size: 64, weight: .thin, design: .serif))
                            .foregroundColor(theme.primary.opacity(0.3))
                            .padding(.leading, 24)
                        
                        Spacer()
                    }
                    
                    // Decoration in top-right (behind content, no hit testing)
                    HStack {
                        Spacer()
                        TopDecoration(theme: theme)
                            .padding(.trailing, 10)
                    }
                    .allowsHitTesting(false)
                }
                .frame(height: 150)
                
                // Scrollable content area
                chapterContentView
                
                // Bottom Action Bar (when verses selected)
                if !selectedVerses.isEmpty {
                    selectionActionBar
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .sheet(isPresented: $showBookPicker) {
            NavigationPickerView(
                selectedBookId: $selectedBookId,
                selectedChapter: $selectedChapter
            )
        }
        .sheet(isPresented: $showSearch) {
            SearchView(onNavigate: { bookId, chapter in
                selectedBookId = bookId
                selectedChapter = chapter
            })
        }
        .sheet(isPresented: $showQuickNote) {
            if let verse = quickNoteVerse {
                QuickNoteSheet(verse: verse)
                    .onDisappear { loadVerseNotes() }
            }
        }
        .sheet(isPresented: $showVerseCard) {
            if let verse = cardVerse {
                VerseCardView(verse: verse)
            }
        }
        .overlay(alignment: .top) {
            if showBookmarkToast {
                HStack(spacing: 8) {
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(.white)
                    Text("Bookmark added")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(theme.primary)
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.top, 60)
            }
        }
        .onAppear {
            loadInitialContent()
        }
        .onChange(of: selectedBookId) { _, _ in
            // 清除选中状态并重新加载
            selectedVerses.removeAll()
            highlights.removeAll()
            verseNotes.removeAll()
            loadChapterData()
        }
        .onChange(of: selectedChapter) { _, _ in
            // 清除选中状态并重新加载
            selectedVerses.removeAll()
            highlights.removeAll()
            verseNotes.removeAll()
            loadChapterData()
        }
        .onChange(of: initialBookId) { _, newValue in
            if let bookId = newValue {
                selectedBookId = bookId
                if let chapter = initialChapter {
                    selectedChapter = chapter
                }
                initialBookId = nil
                initialChapter = nil
            }
        }
        .animation(.spring(response: 0.3), value: selectedVerses.isEmpty)
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack(spacing: 0) {
            // Book & Chapter Selector
            Button {
                showBookPicker = true
            } label: {
                HStack(spacing: 6) {
                    Text(currentBook?.name ?? "")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                    Text("\(selectedChapter)")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(theme.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(theme.primary.opacity(0.15))
                        )
                }
                .foregroundColor(theme.text)
            }
            
            Spacer()
            
            // Search
            Button {
                showSearch = true
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(theme.text.opacity(0.6))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    // MARK: - Chapter Content
    private var chapterContentView: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    if let chapter = dataManager.currentChapter {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            // Verses
                            ForEach(chapter.verses) { verse in
                                verseView(verse)
                                    .id("\(chapter.bookId)_\(chapter.chapter)_\(verse.verse)")
                            }
                            
                            // Chapter Navigation
                            chapterNavigation
                                .padding(.top, 40)
                                .padding(.bottom, 100)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                        .id("\(selectedBookId)_\(selectedChapter)") // 强制重建视图
                    }
                }
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            handleSwipe(value.translation.width)
                            dragOffset = 0
                        }
                )
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Clear selection when tapping empty area
            if !selectedVerses.isEmpty {
                withAnimation(.easeOut(duration: 0.2)) {
                    selectedVerses.removeAll()
                }
            }
        }
    }
    
    // MARK: - Verse View
    private func verseView(_ verse: BibleVerse) -> some View {
        let isSelected = selectedVerses.contains(verse.verse)
        let hasNote = verseNotes[verse.verse] == true
        
        return HStack(alignment: .top, spacing: 0) {
            // Verse Number
            Text("\(verse.verse)")
                .font(.system(size: fontSize * 0.65, weight: .medium, design: .rounded))
                .foregroundColor(theme.primary.opacity(0.7))
                .frame(width: 28, alignment: .trailing)
                .padding(.trailing, 8)
                .padding(.top, 3)
            
            // Verse Text
            VStack(alignment: .leading, spacing: 4) {
                Text(verse.text)
                    .font(.system(size: fontSize, weight: .regular, design: .serif))
                    .foregroundColor(theme.text.opacity(0.9))
                    .lineSpacing(lineSpacing)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Note Indicator
                if hasNote {
                    HStack(spacing: 4) {
                        Image(systemName: "note.text")
                            .font(.system(size: 10))
                        Text("has note")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(theme.primary.opacity(0.7))
                    .padding(.top, 2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, lineSpacing / 2 + 4)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(verseBackground(isSelected: isSelected, highlightHex: highlights[verse.verse]))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? theme.primary.opacity(0.5) : Color.clear, lineWidth: 1.5)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            handleVerseTap(verse)
        }
        .onLongPressGesture(minimumDuration: 0.3) {
            handleVerseLongPress(verse)
        }
    }
    
    private func verseBackground(isSelected: Bool, highlightHex: String?) -> Color {
        if isSelected {
            return theme.primary.opacity(0.12)
        } else if let hex = highlightHex {
            return Color(hex: hex).opacity(0.25)
        }
        return Color.clear
    }
    
    // MARK: - Selection Action Bar
    private var selectionActionBar: some View {
        HStack(spacing: 0) {
            // Highlight Colors
            HStack(spacing: 12) {
                ForEach(ThemeManager.highlightColors.prefix(4)) { color in
                    Button {
                        applyHighlight(color.hex)
                    } label: {
                        Circle()
                            .fill(color.color)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle().stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                    }
                }
                
                // Remove Highlight
                Button {
                    removeHighlights()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(theme.text.opacity(0.5))
                        .frame(width: 28, height: 28)
                        .background(Circle().stroke(theme.text.opacity(0.2), lineWidth: 1))
                }
            }
            
            Spacer()
            
            // Actions
            HStack(spacing: 16) {
                // Note
                Button {
                    openNoteForSelection()
                } label: {
                    Image(systemName: "note.text.badge.plus")
                        .font(.system(size: 20))
                        .foregroundColor(theme.primary)
                }
                
                // Card
                Button {
                    openCardForSelection()
                } label: {
                    Image(systemName: "photo.artframe")
                        .font(.system(size: 20))
                        .foregroundColor(theme.primary)
                }
                
                // Bookmark
                Button {
                    addBookmarkForSelection()
                } label: {
                    Image(systemName: "bookmark")
                        .font(.system(size: 20))
                        .foregroundColor(theme.primary)
                }
                
                // Copy
                Button {
                    copySelectedVerses()
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 20))
                        .foregroundColor(theme.primary)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .fill(theme.secondary.opacity(0.5))
                )
                .shadow(color: .black.opacity(0.08), radius: 10, y: -5)
        )
    }
    
    // MARK: - Chapter Navigation
    private var chapterNavigation: some View {
        HStack(spacing: 20) {
            // Previous Chapter
            if selectedChapter > 1 || selectedBookId > 1 {
                Button {
                    goToPreviousChapter()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                        Text("Previous Chapter")
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(theme.primary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule().fill(theme.primary.opacity(0.1))
                    )
                }
            }
            
            Spacer()
            
            // Next Chapter
            if let book = currentBook, selectedChapter < book.chapters || selectedBookId < 66 {
                Button {
                    goToNextChapter()
                } label: {
                    HStack(spacing: 8) {
                        Text("Next Chapter")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(theme.primary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule().fill(theme.primary.opacity(0.1))
                    )
                }
            }
        }
    }

    // MARK: - Actions
    private func handleVerseTap(_ verse: BibleVerse) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        withAnimation(.easeOut(duration: 0.15)) {
            if selectedVerses.contains(verse.verse) {
                selectedVerses.remove(verse.verse)
            } else {
                selectedVerses.insert(verse.verse)
            }
        }
    }
    
    private func handleVerseLongPress(_ verse: BibleVerse) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // 长按时先选中该经文
        withAnimation(.easeOut(duration: 0.15)) {
            if !selectedVerses.contains(verse.verse) {
                selectedVerses.insert(verse.verse)
            }
        }
    }
    
    private func handleSwipe(_ translation: CGFloat) {
        let threshold: CGFloat = 80
        
        if translation > threshold {
            goToPreviousChapter()
        } else if translation < -threshold {
            goToNextChapter()
        }
    }
    
    private func goToPreviousChapter() {
        // 先清除选中状态
        selectedVerses.removeAll()
        highlights.removeAll()
        verseNotes.removeAll()
        
        withAnimation(.easeInOut(duration: 0.25)) {
            if selectedChapter > 1 {
                selectedChapter -= 1
            } else if selectedBookId > 1 {
                selectedBookId -= 1
                if let book = dataManager.bibleBooks.first(where: { $0.id == selectedBookId }) {
                    selectedChapter = book.chapters
                }
            }
        }
    }
    
    private func goToNextChapter() {
        // 先清除选中状态
        selectedVerses.removeAll()
        highlights.removeAll()
        verseNotes.removeAll()
        
        withAnimation(.easeInOut(duration: 0.25)) {
            if let book = currentBook, selectedChapter < book.chapters {
                selectedChapter += 1
            } else if selectedBookId < 66 {
                selectedBookId += 1
                selectedChapter = 1
            }
        }
    }
    
    private func applyHighlight(_ colorHex: String) {
        for verseNum in selectedVerses {
            dataManager.addHighlight(bookId: selectedBookId, chapter: selectedChapter, verse: verseNum, colorHex: colorHex)
            highlights[verseNum] = colorHex
        }
        
        withAnimation {
            selectedVerses.removeAll()
        }
    }
    
    private func removeHighlights() {
        for verseNum in selectedVerses {
            dataManager.removeHighlight(bookId: selectedBookId, chapter: selectedChapter, verse: verseNum)
            highlights.removeValue(forKey: verseNum)
        }
        
        withAnimation {
            selectedVerses.removeAll()
        }
    }
    
    private func openNoteForSelection() {
        if let firstVerse = selectedVerses.sorted().first,
           let chapter = dataManager.currentChapter,
           let verse = chapter.verses.first(where: { $0.verse == firstVerse }) {
            quickNoteVerse = verse
            showQuickNote = true
        }
    }
    
    private func openCardForSelection() {
        if let firstVerse = selectedVerses.sorted().first,
           let chapter = dataManager.currentChapter,
           let verse = chapter.verses.first(where: { $0.verse == firstVerse }) {
            cardVerse = verse
            selectedVerses.removeAll()
            showVerseCard = true
        }
    }
    
    private func addBookmarkForSelection() {
        if let firstVerse = selectedVerses.sorted().first {
            dataManager.addBookmark(
                bookId: selectedBookId,
                chapter: selectedChapter,
                verse: firstVerse,
                title: "\(currentBook?.name ?? "") \(selectedChapter):\(firstVerse)"
            )
        }
        
        withAnimation {
            selectedVerses.removeAll()
        }
        
        // Show toast
        withAnimation(.spring(response: 0.3)) {
            showBookmarkToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeOut(duration: 0.2)) {
                showBookmarkToast = false
            }
        }
        
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
    }
    
    private func copySelectedVerses() {
        guard let chapter = dataManager.currentChapter else { return }
        
        let sortedVerses = selectedVerses.sorted()
        let texts = sortedVerses.compactMap { verseNum -> String? in
            guard let verse = chapter.verses.first(where: { $0.verse == verseNum }) else { return nil }
            return "\(verseNum) \(verse.text)"
        }
        
        let reference = "\(currentBook?.name ?? "") \(selectedChapter):\(sortedVerses.map(String.init).joined(separator: ","))"
        let fullText = texts.joined(separator: "\n") + "\n— \(reference) (KJV)"
        
        UIPasteboard.general.string = fullText
        
        withAnimation {
            selectedVerses.removeAll()
        }
        
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
    }
    
    private func loadInitialContent() {
        if let progress = dataManager.lastReadingPosition {
            selectedBookId = progress.bookId
            selectedChapter = progress.chapter
        }
        loadChapterData()
    }
    
    private func loadChapterData() {
        // 确保先清除旧数据
        dataManager.loadChapter(bookId: selectedBookId, chapter: selectedChapter)
        dataManager.saveReadingPosition(bookId: selectedBookId, chapter: selectedChapter)
        loadHighlights()
        loadVerseNotes()
    }
    
    private func loadChapter() {
        selectedVerses.removeAll()
        highlights.removeAll()
        verseNotes.removeAll()
        loadChapterData()
    }
    
    private func loadHighlights() {
        let fetchedHighlights = dataManager.fetchHighlights(bookId: selectedBookId, chapter: selectedChapter)
        highlights = Dictionary(uniqueKeysWithValues: fetchedHighlights.map { ($0.verse, $0.colorHex) })
    }
    
    private func loadVerseNotes() {
        guard let chapter = dataManager.currentChapter else { return }
        verseNotes.removeAll()
        
        for verse in chapter.verses {
            let notes = dataManager.fetchNotes(bookId: selectedBookId, chapter: selectedChapter, verse: verse.verse)
            if !notes.isEmpty {
                verseNotes[verse.verse] = true
            }
        }
    }
}

#Preview {
    BibleReaderView()
        .environment(DataManager())
}
