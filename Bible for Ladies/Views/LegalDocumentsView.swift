import SwiftUI

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedTheme") private var selectedTheme = "roseGold"
    
    private var theme: ThemeColors {
        ThemeManager.theme(for: selectedTheme)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Last Updated: January 2026")
                        .font(.system(size: 13))
                        .foregroundColor(theme.text.opacity(0.5))
                    
                    section("Introduction", content: """
                    Bible – KJV for Ladies ("we", "our", or "the App") is committed to protecting your privacy. This Privacy Policy explains how we handle information when you use our mobile application.
                    """)
                    
                    section("Information We Collect", content: """
                    We do not collect, store, or transmit any personal information to external servers. All data you create within the App (including notes, bookmarks, highlights, and reading progress) is stored locally on your device only.
                    """)
                    
                    section("Data Storage", content: """
                    • All your data is stored locally on your device
                    • We do not have access to your notes, bookmarks, or any personal content
                    • Your reading history and preferences remain private on your device
                    • No account registration is required to use the App
                    """)
                    
                    section("Third-Party Services", content: """
                    The App does not integrate with any third-party analytics, advertising, or tracking services. We do not share any information with third parties.
                    """)
                    
                    section("Notifications", content: """
                    If you enable daily reminders, the notification scheduling is handled entirely on your device. We do not receive or store any information about your notification preferences.
                    """)
                    
                    section("Children's Privacy", content: """
                    The App does not knowingly collect any information from children. The App is suitable for users of all ages.
                    """)
                    
                    section("Changes to This Policy", content: """
                    We may update this Privacy Policy from time to time. Any changes will be reflected in the "Last Updated" date above.
                    """)
                    
                    section("Contact Us", content: """
                    If you have any questions about this Privacy Policy, please contact us at:
                    66597405@qq.com
                    """)
                }
                .padding(20)
                .padding(.bottom, 40)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(theme.primary)
                }
            }
        }
    }
    
    private func section(_ title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(theme.text)
            
            Text(content)
                .font(.system(size: 15))
                .foregroundColor(theme.text.opacity(0.8))
                .lineSpacing(4)
        }
    }
}

// MARK: - Terms of Service View
struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedTheme") private var selectedTheme = "roseGold"
    
    private var theme: ThemeColors {
        ThemeManager.theme(for: selectedTheme)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Last Updated: January 2026")
                        .font(.system(size: 13))
                        .foregroundColor(theme.text.opacity(0.5))
                    
                    section("Acceptance of Terms", content: """
                    By downloading, installing, or using Bible – KJV for Ladies ("the App"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the App.
                    """)
                    
                    section("Description of Service", content: """
                    The App provides access to the King James Version (KJV) of the Holy Bible, along with features for reading, note-taking, bookmarking, and highlighting scripture passages. The KJV text is in the public domain.
                    """)
                    
                    section("User Content", content: """
                    You retain ownership of any notes, highlights, or other content you create within the App. This content is stored locally on your device and is your responsibility to back up.
                    """)
                    
                    section("Acceptable Use", content: """
                    You agree to use the App only for lawful purposes and in accordance with these Terms. You agree not to:
                    • Use the App in any way that violates applicable laws
                    • Attempt to reverse engineer or modify the App
                    • Use the App to distribute harmful content
                    """)
                    
                    section("Intellectual Property", content: """
                    The App's design, graphics, and original content (excluding the KJV Bible text) are protected by intellectual property rights. The King James Version Bible text is in the public domain and freely available.
                    """)
                    
                    section("Disclaimer of Warranties", content: """
                    The App is provided "as is" without warranties of any kind. We do not guarantee that the App will be error-free or uninterrupted. We are not responsible for any data loss that may occur.
                    """)
                    
                    section("Limitation of Liability", content: """
                    To the maximum extent permitted by law, we shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the App.
                    """)
                    
                    section("Changes to Terms", content: """
                    We reserve the right to modify these Terms at any time. Continued use of the App after changes constitutes acceptance of the new Terms.
                    """)
                    
                    section("Contact", content: """
                    For questions about these Terms, please contact us at:
                    66597405@qq.com
                    """)
                }
                .padding(20)
                .padding(.bottom, 40)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("Terms of Service")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(theme.primary)
                }
            }
        }
    }
    
    private func section(_ title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(theme.text)
            
            Text(content)
                .font(.system(size: 15))
                .foregroundColor(theme.text.opacity(0.8))
                .lineSpacing(4)
        }
    }
}

#Preview("Privacy Policy") {
    PrivacyPolicyView()
}

#Preview("Terms of Service") {
    TermsOfServiceView()
}
