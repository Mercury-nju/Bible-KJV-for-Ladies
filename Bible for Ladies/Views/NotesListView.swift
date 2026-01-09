import SwiftUI

struct NotesListView: View {
    @Environment(DataManager.self) var dataManager
    @AppStorage("selectedTheme") private var selectedTheme = "roseGold"
    
    @State private var notes: [Note] = []
    @State private var searchText = ""
    @State private var showNewNote = false
    @State private var selectedNote: Note?
    @State private var selectedFilter: NoteFilter = .all
    @State private var showDeleteConfirm = false
    @State private var noteToDelete: Note?
    
    private var theme: ThemeColors {
        ThemeManager.theme(for: selectedTheme)
    }
    
    enum NoteFilter: String, CaseIterable {
        case all = "All"
        case verse = "Verse Notes"
        case free = "Journal"
    }
    
    private var filteredNotes: [Note] {
        var result = notes
        
        switch selectedFilter {
        case .all: break
        case .verse: result = result.filter { !$0.isFreeNote }
        case .free: result = result.filter { $0.isFreeNote }
        }
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        return result
    }
    
    // Group notes by date
    private var groupedNotes: [(String, [Note])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredNotes) { note -> String in
            if calendar.isDateInToday(note.updatedAt) {
                return "Today"
            } else if calendar.isDateInYesterday(note.updatedAt) {
                return "Yesterday"
            } else if calendar.isDate(note.updatedAt, equalTo: Date(), toGranularity: .weekOfYear) {
                return "This Week"
            } else if calendar.isDate(note.updatedAt, equalTo: Date(), toGranularity: .month) {
                return "This Month"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM yyyy"
                return formatter.string(from: note.updatedAt)
            }
        }
        
        let order = ["Today", "Yesterday", "This Week", "This Month"]
        return grouped.sorted { a, b in
            let aIndex = order.firstIndex(of: a.key) ?? Int.max
            let bIndex = order.firstIndex(of: b.key) ?? Int.max
            if aIndex != Int.max || bIndex != Int.max {
                return aIndex < bIndex
            }
            return a.key > b.key
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background with decoration
                DecoratedBackground(theme: theme)
                
                VStack(spacing: 0) {
                    // Filter & Search
                    headerSection
                    
                    // Notes List
                    if filteredNotes.isEmpty {
                        emptyState
                    } else {
                        notesList
                    }
                }
                
                // Floating action button - bottom right
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showNewNote = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    Circle()
                                        .fill(theme.primary)
                                        .shadow(color: theme.primary.opacity(0.4), radius: 8, y: 4)
                                )
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Notes")
            .sheet(isPresented: $showNewNote) {
                FullNoteEditorView(existingNote: nil, isFreeNote: true)
                    .onDisappear { loadNotes() }
            }
            .sheet(item: $selectedNote) { note in
                FullNoteEditorView(existingNote: note, isFreeNote: note.isFreeNote)
                    .onDisappear { loadNotes() }
            }
            .alert("Delete Note", isPresented: $showDeleteConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let note = noteToDelete {
                        deleteNote(note)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this note? This action cannot be undone.")
            }
            .onAppear { loadNotes() }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Filter Tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(NoteFilter.allCases, id: \.self) { filter in
                        filterTab(filter)
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Search Bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15))
                    .foregroundColor(theme.text.opacity(0.4))
                
                TextField("Search notes...", text: $searchText)
                    .font(.system(size: 15))
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundColor(theme.text.opacity(0.3))
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.secondary.opacity(0.5))
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
    }
    
    private func filterTab(_ filter: NoteFilter) -> some View {
        let count = notes.filter { note in
            switch filter {
            case .all: return true
            case .verse: return !note.isFreeNote
            case .free: return note.isFreeNote
            }
        }.count
        
        return Button {
            withAnimation(.easeOut(duration: 0.2)) {
                selectedFilter = filter
            }
        } label: {
            HStack(spacing: 4) {
                Text(filter.rawValue)
                    .font(.system(size: 14, weight: .medium))
                
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(selectedFilter == filter ? Color.white.opacity(0.3) : theme.primary.opacity(0.15))
                        )
                }
            }
            .foregroundColor(selectedFilter == filter ? .white : theme.text)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(selectedFilter == filter ? theme.primary : theme.secondary.opacity(0.5))
            )
        }
    }
    
    // MARK: - Notes List
    private var notesList: some View {
        List {
            ForEach(groupedNotes, id: \.0) { section, sectionNotes in
                Section {
                    ForEach(sectionNotes) { note in
                        noteCard(note)
                            .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    noteToDelete = note
                                    showDeleteConfirm = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                } header: {
                    Text(section)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(theme.text.opacity(0.5))
                        .textCase(nil)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    // MARK: - Note Card
    private func noteCard(_ note: Note) -> some View {
        Button {
            selectedNote = note
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                // Header: Reference or Title + Time
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        // Reference (for verse notes)
                        if !note.isFreeNote, let bookId = note.bookId, let chapter = note.chapter, let verse = note.verse,
                           let book = dataManager.bibleBooks.first(where: { $0.id == bookId }) {
                            Text("\(book.name) \(chapter):\(verse)")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(theme.primary)
                        }
                        
                        // Title
                        if !note.title.isEmpty && (note.isFreeNote || note.title != "\(dataManager.bibleBooks.first(where: { $0.id == note.bookId })?.name ?? "") \(note.chapter ?? 0):\(note.verse ?? 0)") {
                            Text(note.title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(theme.text)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    // Time
                    Text(formatTime(note.updatedAt))
                        .font(.system(size: 12))
                        .foregroundColor(theme.text.opacity(0.4))
                }
                
                // Content Preview
                if !note.content.isEmpty {
                    Text(note.content)
                        .font(.system(size: 14))
                        .foregroundColor(theme.text.opacity(0.7))
                        .lineSpacing(4)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                
                // Tags
                if !note.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(note.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(theme.primary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        Capsule()
                                            .fill(theme.primary.opacity(0.1))
                                    )
                            }
                        }
                    }
                }
                
                // Images Preview
                if !note.imageData.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(note.imageData.prefix(3).indices, id: \.self) { index in
                                if let uiImage = UIImage(data: note.imageData[index]) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                            
                            if note.imageData.count > 3 {
                                Text("+\(note.imageData.count - 3)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(theme.text.opacity(0.5))
                                    .frame(width: 60, height: 60)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(theme.secondary)
                                    )
                            }
                        }
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.secondary.opacity(0.4))
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                selectedNote = note
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                noteToDelete = note
                showDeleteConfirm = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: selectedFilter == .free ? "book.closed" : "note.text")
                .font(.system(size: 56, weight: .thin))
                .foregroundColor(theme.primary.opacity(0.4))
            
            VStack(spacing: 8) {
                Text(emptyStateTitle)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(theme.text.opacity(0.7))
                
                Text(emptyStateSubtitle)
                    .font(.system(size: 14))
                    .foregroundColor(theme.text.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
            
            if selectedFilter == .free {
                Button {
                    showNewNote = true
                } label: {
                    Text("Write a Journal Entry")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule().fill(theme.primary)
                        )
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
    
    private var emptyStateTitle: String {
        if !searchText.isEmpty {
            return "No notes found"
        }
        switch selectedFilter {
        case .all: return "No notes yet"
        case .verse: return "No verse notes yet"
        case .free: return "No journal entries yet"
        }
    }
    
    private var emptyStateSubtitle: String {
        if !searchText.isEmpty {
            return "Try different keywords"
        }
        switch selectedFilter {
        case .all: return "Long press a verse while reading to add notes\nor tap the + button to write a journal"
        case .verse: return "Long press a verse while reading to add notes"
        case .free: return "Record your devotional thoughts and reflections"
        }
    }
    
    // MARK: - Helpers
    private func formatTime(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "M/d"
            return formatter.string(from: date)
        }
    }
    
    private func loadNotes() {
        notes = dataManager.fetchNotes()
    }
    
    private func deleteNote(_ note: Note) {
        withAnimation {
            dataManager.deleteNote(note)
            loadNotes()
        }
    }
}

#Preview {
    NotesListView()
        .environment(DataManager())
}
