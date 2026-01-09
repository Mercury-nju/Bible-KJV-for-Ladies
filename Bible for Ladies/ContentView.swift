import SwiftUI

struct ContentView: View {
    @Environment(DataManager.self) var dataManager
    @AppStorage("selectedTheme") private var selectedTheme = "roseGold"
    @State private var selectedTab = 0
    @State private var navigateToBookId: Int?
    @State private var navigateToChapter: Int?
    
    private var theme: ThemeColors {
        ThemeManager.theme(for: selectedTheme)
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            BibleReaderView(
                initialBookId: $navigateToBookId,
                initialChapter: $navigateToChapter
            )
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 0 ? "book.fill" : "book")
                        Text("Read")
                    }
                }
                .tag(0)
            
            NotesListView()
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 1 ? "square.and.pencil" : "square.and.pencil")
                        Text("Notes")
                    }
                }
                .tag(1)
            
            BookmarksView(onNavigate: { bookId, chapter in
                navigateToBookId = bookId
                navigateToChapter = chapter
                selectedTab = 0
            })
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 2 ? "bookmark.fill" : "bookmark")
                        Text("Bookmarks")
                    }
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 3 ? "gearshape.fill" : "gearshape")
                        Text("Settings")
                    }
                }
                .tag(3)
        }
        .tint(theme.primary)
        .onAppear {
            // Customize tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(theme.background)
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    ContentView()
        .environment(DataManager())
}
