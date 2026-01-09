import SwiftUI
import Photos

struct VerseCardView: View {
    @Environment(DataManager.self) var dataManager
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedTheme") private var selectedTheme = "roseGold"
    
    let verse: BibleVerse
    
    @State private var selectedTemplate = 0
    @State private var generatedImage: UIImage?
    @State private var showSaveSuccess = false
    @State private var showSaveError = false
    
    private var theme: ThemeColors {
        ThemeManager.theme(for: selectedTheme)
    }
    
    private var verseReference: String {
        guard let book = dataManager.bibleBooks.first(where: { $0.id == verse.bookId }) else {
            return ""
        }
        return "\(book.name) \(verse.chapter):\(verse.verse)"
    }
    
    private let templates = [
        CardTemplate(name: "Rose", bgColor: "FFF0F3", textColor: "8B4557", accentColor: "D4A5A5"),
        CardTemplate(name: "Lavender", bgColor: "F5F0FF", textColor: "5D4777", accentColor: "B8A5D4"),
        CardTemplate(name: "Mint", bgColor: "F0FFF4", textColor: "2D5A4A", accentColor: "A5D4B8"),
        CardTemplate(name: "Cream", bgColor: "FFFDF5", textColor: "6B5D45", accentColor: "D4C9A5")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Preview
                    cardPreview
                    
                    // Template Selector
                    templateSelector
                    
                    Spacer()
                    
                    // Actions
                    actionButtons
                }
                .padding(20)
            }
            .navigationTitle("Verse Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(theme.primary)
                }
            }
            .alert("Saved!", isPresented: $showSaveSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("The verse card has been saved to your photo library.")
            }
            .alert("Unable to Save", isPresented: $showSaveError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please allow photo library access in Settings to save verse cards.")
            }
        }
    }

    private var cardPreview: some View {
        let template = templates[selectedTemplate]
        
        return VStack(spacing: 16) {
            Text(verse.text)
                .font(.system(size: 16, weight: .medium, design: .serif))
                .foregroundColor(Color(hex: template.textColor))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
            
            Text("— \(verseReference)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: template.accentColor))
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: template.bgColor))
        )
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
    
    private var templateSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose Style")
                .font(.subheadline.weight(.medium))
                .foregroundColor(theme.text)
            
            HStack(spacing: 12) {
                ForEach(templates.indices, id: \.self) { index in
                    templateButton(index)
                }
            }
        }
    }
    
    private func templateButton(_ index: Int) -> some View {
        let template = templates[index]
        return Button {
            selectedTemplate = index
        } label: {
            VStack(spacing: 4) {
                Circle()
                    .fill(Color(hex: template.bgColor))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(selectedTemplate == index ? theme.primary : Color.clear, lineWidth: 2)
                    )
                Text(template.name)
                    .font(.caption2)
                    .foregroundColor(theme.text.opacity(0.7))
            }
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button {
                shareCard()
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.primary)
                    )
            }
            
            Button {
                saveCard()
            } label: {
                Label("Save", systemImage: "square.and.arrow.down")
                    .font(.headline)
                    .foregroundColor(theme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(theme.primary, lineWidth: 2)
                    )
            }
        }
    }
    
    private func shareCard() {
        let image = renderCard()
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func saveCard() {
        let image = renderCard()
        
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                if status == .authorized || status == .limited {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    showSaveSuccess = true
                    let notification = UINotificationFeedbackGenerator()
                    notification.notificationOccurred(.success)
                } else {
                    showSaveError = true
                }
            }
        }
    }
    
    @MainActor
    private func renderCard() -> UIImage {
        let template = templates[selectedTemplate]
        let renderer = ImageRenderer(content: cardContent(template: template))
        renderer.scale = 3.0
        return renderer.uiImage ?? UIImage()
    }
    
    private func cardContent(template: CardTemplate) -> some View {
        VStack(spacing: 16) {
            Text(verse.text)
                .font(.system(size: 18, weight: .medium, design: .serif))
                .foregroundColor(Color(hex: template.textColor))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
            
            Text("— \(verseReference)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: template.accentColor))
        }
        .padding(40)
        .frame(width: 350)
        .background(Color(hex: template.bgColor))
    }
}

struct CardTemplate {
    let name: String
    let bgColor: String
    let textColor: String
    let accentColor: String
}

#Preview {
    VerseCardView(verse: BibleVerse(bookId: 1, chapter: 1, verse: 1, text: "In the beginning God created the heaven and the earth."))
        .environment(DataManager())
}
