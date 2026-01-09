import SwiftUI

struct NavigationPickerView: View {
    @Environment(DataManager.self) var dataManager
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedTheme") private var selectedTheme = "roseGold"
    
    @Binding var selectedBookId: Int
    @Binding var selectedChapter: Int
    
    @State private var currentStep: PickerStep = .book
    @State private var selectedTestament: BibleBook.Testament = .old
    @State private var tempBookId: Int = 1
    
    private var theme: ThemeColors {
        ThemeManager.theme(for: selectedTheme)
    }
    
    enum PickerStep {
        case book, chapter
    }
    
    private var filteredBooks: [BibleBook] {
        dataManager.bibleBooks.filter { $0.testament == selectedTestament }.sorted { $0.id < $1.id }
    }
    
    private var selectedBook: BibleBook? {
        dataManager.bibleBooks.first { $0.id == tempBookId }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Step Indicator
                    stepIndicator
                    
                    // Content
                    if currentStep == .book {
                        bookPickerContent
                    } else {
                        chapterPickerContent
                    }
                }
            }
            .navigationTitle(currentStep == .book ? "Select Book" : "Select Chapter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if currentStep == .chapter {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                currentStep = .book
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Book")
                            }
                            .font(.system(size: 15))
                            .foregroundColor(theme.primary)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(theme.text.opacity(0.6))
                }
            }
        }
        .onAppear {
            tempBookId = selectedBookId
            if let book = dataManager.bibleBooks.first(where: { $0.id == selectedBookId }) {
                selectedTestament = book.testament
            }
        }
    }
    
    // MARK: - Step Indicator
    private var stepIndicator: some View {
        HStack(spacing: 8) {
            stepDot(step: .book, label: "Book")
            
            Rectangle()
                .fill(currentStep == .chapter ? theme.primary : theme.text.opacity(0.2))
                .frame(width: 30, height: 2)
            
            stepDot(step: .chapter, label: "Chapter")
        }
        .padding(.vertical, 16)
    }
    
    private func stepDot(step: PickerStep, label: String) -> some View {
        VStack(spacing: 4) {
            Circle()
                .fill(currentStep == step || (step == .book && currentStep == .chapter) ? theme.primary : theme.text.opacity(0.2))
                .frame(width: 10, height: 10)
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(currentStep == step ? theme.primary : theme.text.opacity(0.5))
        }
    }
    
    // MARK: - Book Picker
    private var bookPickerContent: some View {
        VStack(spacing: 0) {
            // Testament Tabs
            testamentTabs
            
            // Books Grid
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    ForEach(filteredBooks) { book in
                        bookButton(book)
                    }
                }
                .padding(16)
            }
        }
    }
    
    private var testamentTabs: some View {
        HStack(spacing: 0) {
            testamentTab("Old Testament", testament: .old)
            testamentTab("New Testament", testament: .new)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
    
    private func testamentTab(_ title: String, testament: BibleBook.Testament) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTestament = testament
            }
        } label: {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(selectedTestament == testament ? .white : theme.text)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectedTestament == testament ? theme.primary : Color.clear)
                )
        }
    }
    
    private func bookButton(_ book: BibleBook) -> some View {
        Button {
            tempBookId = book.id
            withAnimation(.easeInOut(duration: 0.2)) {
                currentStep = .chapter
            }
        } label: {
            VStack(spacing: 4) {
                Text(book.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(tempBookId == book.id ? .white : theme.text)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
                
                Text("\(book.chapters)ch")
                    .font(.system(size: 11))
                    .foregroundColor(tempBookId == book.id ? .white.opacity(0.8) : theme.text.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(tempBookId == book.id ? theme.primary : theme.secondary.opacity(0.5))
            )
        }
    }
    
    // MARK: - Chapter Picker
    private var chapterPickerContent: some View {
        VStack(spacing: 16) {
            // Selected Book Info
            if let book = selectedBook {
                Text(book.name)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(theme.text)
            }
            
            // Chapters Grid
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 10) {
                    if let book = selectedBook {
                        ForEach(1...book.chapters, id: \.self) { chapter in
                            chapterButton(chapter)
                        }
                    }
                }
                .padding(16)
            }
        }
    }
    
    private func chapterButton(_ chapter: Int) -> some View {
        Button {
            // 直接更新并关闭
            selectedBookId = tempBookId
            selectedChapter = chapter
            dismiss()
        } label: {
            Text("\(chapter)")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(selectedBookId == tempBookId && selectedChapter == chapter ? .white : theme.text)
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedBookId == tempBookId && selectedChapter == chapter ? theme.primary : theme.secondary.opacity(0.5))
                )
        }
    }
}

#Preview {
    NavigationPickerView(selectedBookId: .constant(1), selectedChapter: .constant(1))
        .environment(DataManager())
}
