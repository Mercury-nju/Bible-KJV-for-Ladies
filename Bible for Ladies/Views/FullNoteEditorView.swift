import SwiftUI
import PhotosUI
import SwiftData

struct FullNoteEditorView: View {
    @Environment(DataManager.self) var dataManager
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedTheme") private var selectedTheme = "roseGold"
    
    var existingNote: Note?
    var isFreeNote: Bool
    
    @State private var title = ""
    @State private var content = ""
    @State private var tags: [String] = []
    @State private var newTag = ""
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var imageData: [Data] = []
    @State private var showDiscardAlert = false
    @State private var showDeleteAlert = false
    
    // Original values for comparison
    @State private var originalTitle = ""
    @State private var originalContent = ""
    @State private var originalTags: [String] = []
    @State private var originalImageData: [Data] = []
    
    private var isEdited: Bool {
        title != originalTitle ||
        content != originalContent ||
        tags != originalTags ||
        imageData != originalImageData
    }
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case title, content, tag
    }
    
    private var theme: ThemeColors {
        ThemeManager.theme(for: selectedTheme)
    }
    
    private let suggestedTags = ["Insight", "Prayer", "Application", "Question", "Gratitude", "Praise", "Confession", "Resolution"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Title
                        titleSection
                        
                        // Content
                        contentSection
                        
                        // Tags
                        tagsSection
                        
                        // Images
                        imagesSection
                        
                        // Delete button (only for existing notes)
                        if existingNote != nil {
                            deleteSection
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 50)
                }
            }
            .navigationTitle(existingNote != nil ? "Edit Note" : "Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        if isEdited {
                            showDiscardAlert = true
                        } else {
                            dismiss()
                        }
                    }
                    .foregroundColor(theme.text.opacity(0.6))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNote()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(canSave ? theme.primary : theme.text.opacity(0.3))
                    .disabled(!canSave)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                    .foregroundColor(theme.primary)
                }
            }
            .alert("Discard Changes?", isPresented: $showDiscardAlert) {
                Button("Continue Editing", role: .cancel) {}
                Button("Discard", role: .destructive) {
                    dismiss()
                }
            } message: {
                Text("You have unsaved changes. Are you sure you want to discard them?")
            }
            .alert("Delete Note?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteNote()
                }
            } message: {
                Text("This action cannot be undone.")
            }
            .onAppear {
                loadExistingNote()
            }
            .onChange(of: selectedPhotos) { _, newItems in
                loadImages(from: newItems)
            }
        }
    }
    
    private var canSave: Bool {
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Title Section
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Title")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(theme.text.opacity(0.5))
            
            TextField("Give this note a title...", text: $title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(theme.text)
                .focused($focusedField, equals: .title)
        }
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Content")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(theme.text.opacity(0.5))
                
                Spacer()
                
                Text("\(content.count)  chars")
                    .font(.system(size: 12))
                    .foregroundColor(theme.text.opacity(0.3))
            }
            
            ZStack(alignment: .topLeading) {
                if content.isEmpty {
                    Text("Write your insights, reflections, or anything you want to remember...")
                        .font(.system(size: 16))
                        .foregroundColor(theme.text.opacity(0.3))
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }
                
                TextEditor(text: $content)
                    .font(.system(size: 16))
                    .foregroundColor(theme.text)
                    .lineSpacing(6)
                    .frame(minHeight: 200)
                    .scrollContentBackground(.hidden)
                    .focused($focusedField, equals: .content)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.secondary.opacity(0.3))
            )
        }
    }
    
    // MARK: - Tags Section
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tags")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(theme.text.opacity(0.5))
            
            // Selected Tags
            if !tags.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        selectedTagChip(tag)
                    }
                }
            }
            
            // Add Tag Input
            HStack(spacing: 8) {
                TextField("Add tag...", text: $newTag)
                    .font(.system(size: 14))
                    .focused($focusedField, equals: .tag)
                    .onSubmit { addTag() }
                
                if !newTag.isEmpty {
                    Button {
                        addTag()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(theme.primary)
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(theme.text.opacity(0.15), lineWidth: 1)
            )
            
            // Suggested Tags
            let availableSuggestions = suggestedTags.filter { !tags.contains($0) }
            if !availableSuggestions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Suggested Tags")
                        .font(.system(size: 12))
                        .foregroundColor(theme.text.opacity(0.4))
                    
                    FlowLayout(spacing: 8) {
                        ForEach(availableSuggestions, id: \.self) { tag in
                            suggestedTagChip(tag)
                        }
                    }
                }
            }
        }
    }
    
    private func selectedTagChip(_ tag: String) -> some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.system(size: 13, weight: .medium))
            
            Button {
                withAnimation(.easeOut(duration: 0.15)) {
                    tags.removeAll { $0 == tag }
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule().fill(theme.primary)
        )
    }
    
    private func suggestedTagChip(_ tag: String) -> some View {
        Button {
            withAnimation(.easeOut(duration: 0.15)) {
                tags.append(tag)
            }
        } label: {
            Text(tag)
                .font(.system(size: 13))
                .foregroundColor(theme.text.opacity(0.6))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .stroke(theme.text.opacity(0.2), lineWidth: 1)
                )
        }
    }
    
    // MARK: - Images Section
    private var imagesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Images")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(theme.text.opacity(0.5))
                
                Spacer()
                
                PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 9, matching: .images) {
                    HStack(spacing: 4) {
                        Image(systemName: "photo.badge.plus")
                        Text("Add")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(theme.primary)
                }
            }
            
            if !imageData.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(imageData.indices, id: \.self) { index in
                        imagePreview(index)
                    }
                }
            }
        }
    }
    
    // MARK: - Delete Section
    private var deleteSection: some View {
        Button {
            showDeleteAlert = true
        } label: {
            HStack {
                Image(systemName: "trash")
                Text("Delete Note")
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.red.opacity(0.1))
            )
        }
        .padding(.top, 20)
    }
    
    private func imagePreview(_ index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            if let uiImage = UIImage(data: imageData[index]) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            Button {
                withAnimation {
                    _ = imageData.remove(at: index)
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .shadow(radius: 2)
            }
            .offset(x: 6, y: -6)
        }
    }
    
    // MARK: - Actions
    private func loadExistingNote() {
        guard let note = existingNote else { return }
        title = note.title
        content = note.content
        tags = note.tags
        imageData = note.imageData
        
        // Save original values
        originalTitle = note.title
        originalContent = note.content
        originalTags = note.tags
        originalImageData = note.imageData
    }
    
    private func addTag() {
        let trimmed = newTag.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty && !tags.contains(trimmed) {
            withAnimation(.easeOut(duration: 0.15)) {
                tags.append(trimmed)
            }
        }
        newTag = ""
    }
    
    private func loadImages(from items: [PhotosPickerItem]) {
        Task {
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        imageData.append(data)
                    }
                }
            }
            selectedPhotos.removeAll()
        }
    }
    
    private func saveNote() {
        let finalTitle = title.isEmpty ? "Journal" : title
        
        if let existing = existingNote {
            existing.title = finalTitle
            existing.content = content
            existing.tags = tags
            existing.imageData = imageData
            existing.updatedAt = Date()
            try? dataManager.context.save()
        } else {
            let note = Note(
                bookId: nil,
                chapter: nil,
                verse: nil,
                title: finalTitle,
                content: content,
                tags: tags,
                isFreeNote: isFreeNote
            )
            note.imageData = imageData
            dataManager.context.insert(note)
            try? dataManager.context.save()
        }
        
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
        
        dismiss()
    }
    
    private func deleteNote() {
        guard let note = existingNote else { return }
        dataManager.deleteNote(note)
        
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
        
        dismiss()
    }
}

#Preview {
    FullNoteEditorView(existingNote: nil, isFreeNote: true)
        .environment(DataManager())
}


// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
                
                self.size.width = max(self.size.width, x)
            }
            
            self.size.height = y + rowHeight
        }
    }
}
