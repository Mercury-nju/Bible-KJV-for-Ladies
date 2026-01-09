import SwiftUI

struct QuickNoteSheet: View {
    @Environment(DataManager.self) var dataManager
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedTheme") private var selectedTheme = "roseGold"
    
    let verse: BibleVerse
    
    @State private var noteContent = ""
    @State private var existingNote: Note?
    @State private var selectedTags: Set<String> = []
    @FocusState private var isTextFieldFocused: Bool
    
    private var theme: ThemeColors {
        ThemeManager.theme(for: selectedTheme)
    }
    
    private var verseReference: String {
        guard let book = dataManager.bibleBooks.first(where: { $0.id == verse.bookId }) else {
            return ""
        }
        return "\(book.name) \(verse.chapter):\(verse.verse)"
    }
    
    private let quickTags = ["Insight", "Prayer", "Application", "Question", "Gratitude", "Praise"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Verse Preview
                        versePreview
                        
                        // Note Input
                        noteInput
                        
                        // Quick Tags
                        tagSelector
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(theme.text.opacity(0.6))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNote()
                    }
                    .font(.headline)
                    .foregroundColor(noteContent.isEmpty ? theme.text.opacity(0.3) : theme.primary)
                    .disabled(noteContent.isEmpty)
                }
            }
            .onAppear {
                loadExistingNote()
                isTextFieldFocused = true
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private var versePreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(verseReference)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(theme.primary)
            
            Text(verse.text)
                .font(.system(size: 15, design: .serif))
                .foregroundColor(theme.text.opacity(0.8))
                .lineSpacing(4)
                .lineLimit(3)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.secondary.opacity(0.5))
        )
    }
    
    private var noteInput: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Write your thoughts...")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(theme.text.opacity(0.5))
            
            TextEditor(text: $noteContent)
                .font(.system(size: 16))
                .foregroundColor(theme.text)
                .frame(minHeight: 150)
                .scrollContentBackground(.hidden)
                .focused($isTextFieldFocused)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.secondary.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.primary.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var tagSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tags")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(theme.text.opacity(0.5))
            
            FlowLayout(spacing: 8) {
                ForEach(quickTags, id: \.self) { tag in
                    tagButton(tag)
                }
            }
        }
    }
    
    private func tagButton(_ tag: String) -> some View {
        let isSelected = selectedTags.contains(tag)
        
        return Button {
            withAnimation(.easeOut(duration: 0.15)) {
                if isSelected {
                    selectedTags.remove(tag)
                } else {
                    selectedTags.insert(tag)
                }
            }
        } label: {
            Text(tag)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : theme.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? theme.primary : theme.primary.opacity(0.1))
                )
        }
    }
    
    private func loadExistingNote() {
        let notes = dataManager.fetchNotes(bookId: verse.bookId, chapter: verse.chapter, verse: verse.verse)
        if let note = notes.first {
            existingNote = note
            noteContent = note.content
            selectedTags = Set(note.tags)
        }
    }
    
    private func saveNote() {
        let tags = Array(selectedTags)
        
        if let existing = existingNote {
            dataManager.updateNote(existing, title: verseReference, content: noteContent, tags: tags)
        } else {
            dataManager.addNote(
                bookId: verse.bookId,
                chapter: verse.chapter,
                verse: verse.verse,
                title: verseReference,
                content: noteContent,
                tags: tags,
                isFreeNote: false
            )
        }
        
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
        
        dismiss()
    }
}

#Preview {
    QuickNoteSheet(verse: BibleVerse(bookId: 1, chapter: 1, verse: 1, text: "In the beginning God created the heaven and the earth."))
        .environment(DataManager())
}
