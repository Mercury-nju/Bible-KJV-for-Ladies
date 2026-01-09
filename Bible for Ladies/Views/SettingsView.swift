import SwiftUI
import UserNotifications

struct SettingsView: View {
    @AppStorage("selectedTheme") private var selectedTheme = "roseGold"
    @AppStorage("fontSize") private var fontSize: Double = 18
    @AppStorage("lineSpacing") private var lineSpacing: Double = 8
    @AppStorage("reminderEnabled") private var reminderEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 8
    @AppStorage("reminderMinute") private var reminderMinute = 0
    
    @State private var showTimePicker = false
    @State private var tempDate = Date()
    
    private var theme: ThemeColors {
        ThemeManager.theme(for: selectedTheme)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background with decoration
                DecoratedBackground(theme: theme)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Theme Section
                        themeSection
                        
                        // Reading Section
                        readingSection
                        
                        // Preview
                        previewSection
                        
                        // Reminder Section
                        reminderSection
                        
                        // Legal Section
                        legalSection
                        
                        // About Section
                        aboutSection
                    }
                    .padding(20)
                    .padding(.bottom, 50)
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showTimePicker) {
                timePickerSheet
            }
        }
    }
    
    // MARK: - Theme Section
    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Theme Color", icon: "paintpalette")
            
            HStack(spacing: 0) {
                ForEach(["roseGold", "lavender", "mint"], id: \.self) { key in
                    themeOption(key)
                }
            }
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.secondary.opacity(0.4))
            )
        }
    }
    
    private func themeOption(_ key: String) -> some View {
        let themeColors = ThemeManager.themes[key]!
        let isSelected = selectedTheme == key
        
        return Button {
            withAnimation(.easeOut(duration: 0.2)) {
                selectedTheme = key
            }
        } label: {
            VStack(spacing: 8) {
                Circle()
                    .fill(themeColors.primary)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
                    )
                    .shadow(color: isSelected ? themeColors.primary.opacity(0.4) : .clear, radius: 6)
                
                Text(themeColors.name)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? theme.primary : theme.text.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? theme.primary.opacity(0.1) : Color.clear)
            )
        }
    }
    
    // MARK: - Reading Section
    private var readingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Reading Settings", icon: "textformat.size")
            
            VStack(spacing: 20) {
                // Font Size
                VStack(spacing: 12) {
                    HStack {
                        Text("Font Size")
                            .font(.system(size: 15))
                            .foregroundColor(theme.text)
                        
                        Spacer()
                        
                        Text("\(Int(fontSize))")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(theme.primary)
                    }
                    
                    HStack(spacing: 12) {
                        Text("A")
                            .font(.system(size: 12))
                            .foregroundColor(theme.text.opacity(0.4))
                        
                        Slider(value: $fontSize, in: 14...26, step: 1)
                            .tint(theme.primary)
                        
                        Text("A")
                            .font(.system(size: 20))
                            .foregroundColor(theme.text.opacity(0.4))
                    }
                }
                
                Divider()
                    .background(theme.text.opacity(0.1))
                
                // Line Spacing
                VStack(spacing: 12) {
                    HStack {
                        Text("Line Spacing")
                            .font(.system(size: 15))
                            .foregroundColor(theme.text)
                        
                        Spacer()
                        
                        Text("\(Int(lineSpacing))")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(theme.primary)
                    }
                    
                    HStack(spacing: 12) {
                        Image(systemName: "text.alignleft")
                            .font(.system(size: 12))
                            .foregroundColor(theme.text.opacity(0.4))
                        
                        Slider(value: $lineSpacing, in: 4...16, step: 2)
                            .tint(theme.primary)
                        
                        Image(systemName: "text.alignleft")
                            .font(.system(size: 16))
                            .foregroundColor(theme.text.opacity(0.4))
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.secondary.opacity(0.4))
            )
        }
    }
    
    // MARK: - Preview Section
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preview")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(theme.text.opacity(0.5))
            
            HStack(alignment: .top, spacing: 8) {
                Text("1")
                    .font(.system(size: fontSize * 0.65, weight: .medium, design: .rounded))
                    .foregroundColor(theme.primary.opacity(0.7))
                    .frame(width: 24, alignment: .trailing)
                
                Text("In the beginning God created the heaven and the earth.")
                    .font(.system(size: fontSize, design: .serif))
                    .foregroundColor(theme.text.opacity(0.9))
                    .lineSpacing(lineSpacing)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.secondary.opacity(0.3))
            )
        }
    }
    
    // MARK: - Reminder Section
    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Daily Reminder", icon: "bell")
            
            VStack(spacing: 0) {
                // Toggle
                HStack {
                    Text("Enable Reminder")
                        .font(.system(size: 15))
                        .foregroundColor(theme.text)
                    
                    Spacer()
                    
                    Toggle("", isOn: $reminderEnabled)
                        .tint(theme.primary)
                        .onChange(of: reminderEnabled) { _, newValue in
                            if newValue {
                                requestNotificationPermission()
                            } else {
                                cancelNotifications()
                            }
                        }
                }
                .padding(16)
                
                if reminderEnabled {
                    Divider()
                        .background(theme.text.opacity(0.1))
                        .padding(.horizontal, 16)
                    
                    // Time
                    Button {
                        var components = DateComponents()
                        components.hour = reminderHour
                        components.minute = reminderMinute
                        tempDate = Calendar.current.date(from: components) ?? Date()
                        showTimePicker = true
                    } label: {
                        HStack {
                            Text("Reminder Time")
                                .font(.system(size: 15))
                                .foregroundColor(theme.text)
                            
                            Spacer()
                            
                            Text(String(format: "%02d:%02d", reminderHour, reminderMinute))
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(theme.primary)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13))
                                .foregroundColor(theme.text.opacity(0.3))
                        }
                        .padding(16)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.secondary.opacity(0.4))
            )
        }
    }
    
    // MARK: - Time Picker Sheet
    private var timePickerSheet: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                
                DatePicker("", selection: $tempDate, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
            }
            .navigationTitle("Select Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showTimePicker = false
                    }
                    .foregroundColor(theme.text.opacity(0.6))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Confirm") {
                        let components = Calendar.current.dateComponents([.hour, .minute], from: tempDate)
                        reminderHour = components.hour ?? 8
                        reminderMinute = components.minute ?? 0
                        scheduleNotification()
                        showTimePicker = false
                    }
                    .font(.headline)
                    .foregroundColor(theme.primary)
                }
            }
        }
        .presentationDetents([.height(300)])
    }
    
    // MARK: - Legal Section
    private var legalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("Legal", icon: "doc.text")
            
            VStack(spacing: 0) {
                Button {
                    if let url = URL(string: "https://mercury-nju.github.io/Bible-KJV-for-Ladies/privacy-policy.html") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    legalRow("Privacy Policy")
                }
                
                Divider().background(theme.text.opacity(0.1)).padding(.horizontal, 16)
                
                Button {
                    if let url = URL(string: "https://mercury-nju.github.io/Bible-KJV-for-Ladies/terms-of-service.html") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    legalRow("Terms of Service")
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.secondary.opacity(0.4))
            )
        }
    }
    
    private func legalRow(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(theme.text)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13))
                .foregroundColor(theme.text.opacity(0.3))
        }
        .padding(16)
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader("About", icon: "info.circle")
            
            VStack(spacing: 0) {
                // App Name
                HStack {
                    Text("Bible – KJV for Ladies")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.text)
                    Spacer()
                }
                .padding(16)
                
                Divider().background(theme.text.opacity(0.1)).padding(.horizontal, 16)
                aboutRow("Version", value: "1.0.0")
                Divider().background(theme.text.opacity(0.1)).padding(.horizontal, 16)
                aboutRow("Bible Version", value: "KJV")
                Divider().background(theme.text.opacity(0.1)).padding(.horizontal, 16)
                aboutRow("Total Verses", value: "31,103")
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.secondary.opacity(0.4))
            )
        }
    }
    
    private func aboutRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(theme.text)
            Spacer()
            Text(value)
                .font(.system(size: 15))
                .foregroundColor(theme.text.opacity(0.5))
        }
        .padding(16)
    }
    
    // MARK: - Helpers
    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(theme.primary)
            
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(theme.text)
        }
    }
    
    // MARK: - Notifications
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                scheduleNotification()
            } else {
                DispatchQueue.main.async {
                    reminderEnabled = false
                }
            }
        }
    }
    
    private func scheduleNotification() {
        cancelNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Devotion Time ✨"
        content.body = "Take a moment to read God's Word and start your day blessed"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = reminderHour
        dateComponents.minute = reminderMinute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func cancelNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
    }
}

#Preview {
    SettingsView()
}
